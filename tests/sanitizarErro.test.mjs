import assert from "node:assert/strict";
import test from "node:test";
import { mascararSegredos, sanitizarErro } from "../supabase/functions/_shared/gerar-aula/sanitizarErro.mjs";

// Achado de segurança confirmado em produção (Fase 3, diagnóstico
// arquitetural): 2 gerações reais (conteudo_id=57, 2026-09-14) gravaram
// em aula_geracoes.erro, e devolveram ao browser, a mensagem bruta da
// OpenAI para "Incorrect API key provided", que inclui prefixo/sufixo da
// própria chave. Estes testes cobrem exatamente esse caso real, mais
// variantes de formato de chave e o comportamento de preservação de
// categoria/status.

test("A) mascararSegredos remove uma chave sk-proj- completa de dentro de uma frase", () => {
  const bruta = "Incorrect API key provided: sk-proj-abcDEF123456789_-xyzABCDEF123456789m50A. You can find your API key at https://platform.openai.com/account/api-keys.";
  const mascarada = mascararSegredos(bruta);
  assert.ok(!mascarada.includes("sk-proj-abcDEF"), "não pode sobrar nenhum fragmento reconhecível da chave");
  assert.ok(!mascarada.includes("m50A"), "sufixo da chave não pode sobrar");
  assert.match(mascarada, /sk-\*\*\*REDACTED\*\*\*/);
  assert.ok(mascarada.includes("Incorrect API key provided"), "o resto da mensagem (não sensível) continua legível");
});

test("A) mascara variantes de prefixo (sk-svcacct-, sk-admin-, chave legada sem sufixo)", () => {
  for (const chave of ["sk-svcacct-AAAAAAAAAAAAAAAAAAAA", "sk-admin-BBBBBBBBBBBBBBBBBBBB", "sk-CCCCCCCCCCCCCCCCCCCCCCCCCC"]) {
    const mascarada = mascararSegredos(`erro com a chave ${chave} no meio`);
    assert.ok(!mascarada.includes(chave), `deveria mascarar ${chave}`);
  }
});

test("B) chaves curtas demais (< 10 chars após sk-) NÃO são mascaradas — evita falso positivo em texto comum contendo 'sk-' curto", () => {
  const texto = "erro sk-123 não é uma chave real";
  assert.equal(mascararSegredos(texto), texto);
});

test("C) mascararSegredos é idempotente (aplicar duas vezes não piora nada)", () => {
  const bruta = "Incorrect API key provided: sk-proj-abcDEF123456789xyzABCDEF123456789m50A.";
  const uma = mascararSegredos(bruta);
  const duas = mascararSegredos(uma);
  assert.equal(uma, duas);
});

test("D) mascararSegredos nunca lança para entrada não-string", () => {
  assert.equal(mascararSegredos(null), "");
  assert.equal(mascararSegredos(undefined), "");
  assert.equal(mascararSegredos(42), "");
  assert.equal(mascararSegredos({}), "");
});

test("E) sanitizarErro aceita Error, string e objeto de erro da OpenAI, sempre sanitizando", () => {
  const viaError = sanitizarErro(new Error("Incorrect API key provided: sk-proj-XXXXXXXXXXXXXXXXXXXXm50A."));
  assert.ok(!viaError.mensagem.includes("XXXXXXXXXXXXXXXXXXXX"));

  const viaString = sanitizarErro("Incorrect API key provided: sk-proj-YYYYYYYYYYYYYYYYYYYYm50A.");
  assert.ok(!viaString.mensagem.includes("YYYYYYYYYYYYYYYYYYYY"));

  const viaObjetoOpenAI = sanitizarErro({ error: { message: "Incorrect API key provided: sk-proj-ZZZZZZZZZZZZZZZZZZZZm50A.", type: "invalid_request_error", code: "invalid_api_key" } });
  assert.ok(!viaObjetoOpenAI.mensagem.includes("ZZZZZZZZZZZZZZZZZZZZ"));
  assert.equal(viaObjetoOpenAI.categoria, "invalid_request_error");
  assert.equal(viaObjetoOpenAI.codigo, "invalid_api_key");
});

test("F) sanitizarErro classifica como auth_error quando a mensagem mascarada indica que havia uma chave, mesmo sem type/code estruturado", () => {
  const resultado = sanitizarErro("Incorrect API key provided: sk-proj-WWWWWWWWWWWWWWWWWWWWm50A.");
  assert.equal(resultado.categoria, "auth_error");
});

test("G) sanitizarErro preserva httpStatus quando fornecido", () => {
  const resultado = sanitizarErro({ status: 401, error: { message: "unauthorized" } });
  assert.equal(resultado.httpStatus, 401);
});

test("H) sanitizarErro nunca lança para entrada vazia/estranha", () => {
  assert.doesNotThrow(() => sanitizarErro(undefined));
  assert.doesNotThrow(() => sanitizarErro(null));
  assert.doesNotThrow(() => sanitizarErro(123));
  assert.doesNotThrow(() => sanitizarErro([]));
  const resultado = sanitizarErro(undefined);
  assert.equal(typeof resultado.mensagem, "string");
});

test("I) sanitizarErro inclui o rótulo de etapa quando fornecido, sem vazar segredo", () => {
  const resultado = sanitizarErro("Incorrect API key provided: sk-proj-VVVVVVVVVVVVVVVVVVVVm50A.", { etapa: "submissao_inicial" });
  assert.match(resultado.mensagem, /^\[submissao_inicial\]/);
  assert.ok(!resultado.mensagem.includes("VVVVVVVVVVVVVVVVVVVV"));
});

test("J) reprodução exata do caso real de produção (2026-09-14, conteudo_id=57): a mensagem histórica sanitizada não contém nenhum fragmento de chave", () => {
  const mensagemHistoricaReal = 'Incorrect API key provided: sk-proj-********************************************************************************************************************************************************m50A. You can find your API key at https://platform.openai.com/account/api-keys.';
  const resultado = sanitizarErro(mensagemHistoricaReal, { etapa: "submissao_inicial" });
  // A mensagem histórica real já vinha parcialmente mascarada pela
  // própria OpenAI (asteriscos no meio), mas ainda continha prefixo e
  // sufixo reais — o teste confirma que, mesmo essa variante "meio
  // mascarada", nosso sanitizador reconhece e substitui pelo marcador
  // canônico único.
  assert.ok(!resultado.mensagem.includes("m50A"));
  assert.match(resultado.mensagem, /sk-\*\*\*REDACTED\*\*\*/);
});

test("K) Fase 4 — auditoria final: as 3 fixtures explicitamente pedidas na auditoria de segurança, nenhuma sobrevive em sanitizarErro/mascararSegredos", () => {
  const fixtures = [
    "sk-proj-ABCDEF1234567890",
    "Incorrect API key provided: sk-proj-ABCDEF1234567890",
    "Bearer sk-12345678901234567890",
  ];
  for (const fixture of fixtures) {
    const mascarada = mascararSegredos(fixture);
    assert.ok(!mascarada.includes("ABCDEF1234567890") && !mascarada.includes("12345678901234567890"), `mascararSegredos deveria remover a chave de: "${fixture}"`);

    const viaSanitizarErro = sanitizarErro(fixture, { etapa: "teste_auditoria_fase4" });
    assert.ok(!viaSanitizarErro.mensagem.includes("ABCDEF1234567890") && !viaSanitizarErro.mensagem.includes("12345678901234567890"), `sanitizarErro deveria remover a chave de: "${fixture}"`);
    // Simula os dois destinos reais onde essa mensagem é escrita
    // (aula_geracoes.erro e o corpo da resposta HTTP) — ambos usam
    // literalmente o mesmo `mensagem` sanitizado, nunca o texto bruto (ver
    // gerar-aula/index.ts e finalizar-geracao-aula/index.ts: todo `erro:`
    // persistido e todo `json({ error: ... })` devolvido usam
    // erroSanitizado.mensagem, nunca a string original).
    const corpoHttpSimulado = JSON.stringify({ error: viaSanitizarErro.mensagem });
    const linhaBancoSimulada = JSON.stringify({ erro: viaSanitizarErro.mensagem });
    assert.ok(!corpoHttpSimulado.includes("ABCDEF1234567890") && !corpoHttpSimulado.includes("12345678901234567890"));
    assert.ok(!linhaBancoSimulada.includes("ABCDEF1234567890") && !linhaBancoSimulada.includes("12345678901234567890"));
  }
});
