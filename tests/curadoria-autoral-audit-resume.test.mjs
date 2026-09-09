// Fase 2C.1 — testes do hardening resumivel da auditoria: fingerprint,
// resume planner, execucao de etapa com persistencia imediata e
// classificacao estruturada de erro. NENHUM teste aqui faz rede real —
// todas as chamadas usam fetchImpl injetado. Usa diretorios reais em
// os.tmpdir() (limpos ao final de cada teste) para provar persistencia em
// disco de verdade, nao so em memoria.

import assert from "node:assert/strict";
import test from "node:test";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import crypto from "node:crypto";

import { calcularFingerprintAuditoria, lerEstadoAuditoria, planejarRetomada, ACOES_RETOMADA } from "../scripts/curadoria-autoral/lib/audit-state.mjs";
import { STATUS_ETAPA, executarEtapaAuditoria } from "../scripts/curadoria-autoral/lib/audit-runner.mjs";
import { validarRespostaBlindLocalmente, validarRespostaCriticLocalmente } from "../scripts/curadoria-autoral/lib/audit-orchestrator.mjs";
import { NOMES_CHECKS_CRITIC } from "../scripts/curadoria-autoral/lib/openai-audit-provider.mjs";
import { escreverArtefatoJson } from "../scripts/curadoria-autoral/lib/artifact-writer.mjs";

function dirTemp() {
  return fs.mkdtempSync(path.join(os.tmpdir(), "papiro-audit-teste-"));
}

function limpar(dir) {
  fs.rmSync(dir, { recursive: true, force: true });
}

function fingerprintFixture(overrides = {}) {
  return calcularFingerprintAuditoria({
    questoesGeradasRaw: '{"questoes":[]}',
    runId: "run-teste",
    questionKeys: ["run-teste:q01", "run-teste:q02"],
    model: "gpt-5.6-sol",
    blindPromptVersion: "v1",
    criticPromptVersion: "v1",
    escopo: "escopo de teste",
    fontesValidadas: ["fonte-teste"],
    ...overrides,
  });
}

function respostaHttpOk(corpo) {
  return async () => ({ ok: true, status: 200, json: async () => corpo });
}

function respostaBlindValida() {
  return {
    id: "resp_blind_1",
    status: "completed",
    model: "gpt-5.6-sol",
    usage: { input_tokens: 10, output_tokens: 5, total_tokens: 15 },
    output: [{ content: [{ type: "output_text", text: JSON.stringify({
      answers: [
        { slot: 1, independent_answer: "B", unique_answer: true, ambiguity: "NONE", rule_applied: "x", reasoning_summary: "y", difficulty_observed: "media", confidence: "HIGH", issues: [] },
        { slot: 2, independent_answer: "C", unique_answer: true, ambiguity: "NONE", rule_applied: "x", reasoning_summary: "y", difficulty_observed: "media", confidence: "HIGH", issues: [] },
      ],
    }) }] }],
  };
}

function criticChecksTodosPass() {
  return NOMES_CHECKS_CRITIC.map((check) => ({ check, status: "PASS", severity: "NONE", reason: "ok" }));
}

function respostaCriticValida() {
  return {
    id: "resp_critic_1",
    status: "completed",
    model: "gpt-5.6-sol",
    usage: { input_tokens: 20, output_tokens: 10, total_tokens: 30 },
    output: [{ content: [{ type: "output_text", text: JSON.stringify({
      audits: [
        { slot: 1, checks: criticChecksTodosPass(), critical_findings: [], recommended_action: "PASS_TO_HUMAN", summary: "ok" },
        { slot: 2, checks: criticChecksTodosPass(), critical_findings: [], recommended_action: "PASS_TO_HUMAN", summary: "ok" },
      ],
    }) }] }],
  };
}

// ==================== FINGERPRINT ====================

test("1. calcularFingerprintAuditoria e deterministico e sensivel a cada componente", () => {
  const base = fingerprintFixture();
  assert.equal(base, fingerprintFixture(), "mesmo input produz o mesmo fingerprint");
  assert.notEqual(base, fingerprintFixture({ model: "outro-modelo" }));
  assert.notEqual(base, fingerprintFixture({ questoesGeradasRaw: '{"questoes":[{}]}' }));
  assert.notEqual(base, fingerprintFixture({ blindPromptVersion: "v2" }));
  assert.notEqual(base, fingerprintFixture({ escopo: "outro escopo" }));
  assert.notEqual(base, fingerprintFixture({ questionKeys: ["run-teste:q01"] }));
});

// ==================== RESUME PLANNER (5 acoes) ====================

test("2. planejarRetomada: nenhum artefato -> RUN_BLIND_THEN_CRITIC", () => {
  const plano = planejarRetomada({ fingerprintAtual: "fp1", blindPersistido: null, criticPersistido: null, resultPersistido: null });
  assert.equal(plano.action, ACOES_RETOMADA.RUN_BLIND_THEN_CRITIC);
});

test("3. planejarRetomada: blind valido, fingerprint bate, sem critic -> RUN_CRITIC_ONLY", () => {
  const plano = planejarRetomada({
    fingerprintAtual: "fp1",
    blindPersistido: { existe: true, valido: true, audit_input_fingerprint: "fp1" },
    criticPersistido: null,
    resultPersistido: null,
  });
  assert.equal(plano.action, ACOES_RETOMADA.RUN_CRITIC_ONLY);
});

test("4. planejarRetomada: blind+critic validos, sem result -> AGGREGATE_ONLY", () => {
  const plano = planejarRetomada({
    fingerprintAtual: "fp1",
    blindPersistido: { existe: true, valido: true, audit_input_fingerprint: "fp1" },
    criticPersistido: { existe: true, valido: true, audit_input_fingerprint: "fp1" },
    resultPersistido: null,
  });
  assert.equal(plano.action, ACOES_RETOMADA.AGGREGATE_ONLY);
});

test("5. planejarRetomada: tudo valido -> AUDIT_ALREADY_COMPLETE", () => {
  const plano = planejarRetomada({
    fingerprintAtual: "fp1",
    blindPersistido: { existe: true, valido: true, audit_input_fingerprint: "fp1" },
    criticPersistido: { existe: true, valido: true, audit_input_fingerprint: "fp1" },
    resultPersistido: { existe: true, valido: true, audit_input_fingerprint: "fp1" },
  });
  assert.equal(plano.action, ACOES_RETOMADA.AUDIT_ALREADY_COMPLETE);
});

test("6. planejarRetomada: fingerprint divergente em QUALQUER artefato -> BLOCKED_INCOMPATIBLE_PARTIAL (nunca reutilizado)", () => {
  const plano = planejarRetomada({
    fingerprintAtual: "fp-novo",
    blindPersistido: { existe: true, valido: true, audit_input_fingerprint: "fp-antigo" },
    criticPersistido: null,
    resultPersistido: null,
  });
  assert.equal(plano.action, ACOES_RETOMADA.BLOCKED_INCOMPATIBLE_PARTIAL);
});

test("6b. planejarRetomada: artefato existe mas reprova validacao local -> BLOCKED_INCOMPATIBLE_PARTIAL", () => {
  const plano = planejarRetomada({
    fingerprintAtual: "fp1",
    blindPersistido: { existe: true, valido: false, audit_input_fingerprint: "fp1", motivo_invalido: "corrompido" },
    criticPersistido: null,
    resultPersistido: null,
  });
  assert.equal(plano.action, ACOES_RETOMADA.BLOCKED_INCOMPATIBLE_PARTIAL);
});

// ==================== lerEstadoAuditoria (arquivos reais) ====================

test("7. lerEstadoAuditoria: arquivo ausente -> null; arquivo valido -> valido:true com fingerprint correto", () => {
  const dir = dirTemp();
  try {
    let estado = lerEstadoAuditoria(dir);
    assert.equal(estado.blind, null);

    const fp = fingerprintFixture();
    escreverArtefatoJson(path.join(dir, "audit_blind.json"), {
      schema_version: 1, audit_input_fingerprint: fp,
      answers: [
        { slot: 1, independent_answer: "B", unique_answer: true, ambiguity: "NONE", rule_applied: "x", reasoning_summary: "y", difficulty_observed: "media", confidence: "HIGH", issues: [] },
        { slot: 2, independent_answer: "C", unique_answer: true, ambiguity: "NONE", rule_applied: "x", reasoning_summary: "y", difficulty_observed: "media", confidence: "HIGH", issues: [] },
      ],
    });
    estado = lerEstadoAuditoria(dir);
    assert.equal(estado.blind.existe, true);
    assert.equal(estado.blind.valido, true);
    assert.equal(estado.blind.audit_input_fingerprint, fp);
  } finally {
    limpar(dir);
  }
});

test("8. lerEstadoAuditoria: JSON corrompido -> existe:true, valido:false", () => {
  const dir = dirTemp();
  try {
    fs.writeFileSync(path.join(dir, "audit_critic.json"), "{ isto nao e json valido", "utf8");
    const estado = lerEstadoAuditoria(dir);
    assert.equal(estado.critic.existe, true);
    assert.equal(estado.critic.valido, false);
  } finally {
    limpar(dir);
  }
});

// ==================== executarEtapaAuditoria: classificacao de erro + persistencia ====================

test("9. executarEtapaAuditoria: NETWORK_ERROR tem request_attempted=true, response_received=false (nunca cai em catch generico)", async () => {
  const dir = dirTemp();
  try {
    const fetchQueBrigaARede = async () => { throw new TypeError("fetch failed"); };
    const resultado = await executarEtapaAuditoria({
      apiKey: "sk-teste-nao-real",
      requestBody: { model: "gpt-5.6-sol" },
      caminhoArtefato: path.join(dir, "audit_blind.json"),
      fingerprint: "fp1",
      validarLocalmente: validarRespostaBlindLocalmente,
      montarConteudoArtefato: () => ({}),
      fetchImpl: fetchQueBrigaARede,
    });
    assert.equal(resultado.status, STATUS_ETAPA.NETWORK_ERROR);
    assert.equal(resultado.bookkeeping.request_attempted, true);
    assert.equal(resultado.bookkeeping.response_received, false);
    assert.equal(resultado.bookkeeping.error_type, "NETWORK_ERROR");
    assert.equal(fs.existsSync(path.join(dir, "audit_blind.json")), false, "nada pode ser persistido apos falha de rede");
  } finally {
    limpar(dir);
  }
});

test("10. executarEtapaAuditoria: HTTP_ERROR e distinto de NETWORK_ERROR", async () => {
  const dir = dirTemp();
  try {
    const fetchHttpErro = async () => ({ ok: false, status: 401, json: async () => ({ error: { message: "Incorrect API key provided" } }) });
    const resultado = await executarEtapaAuditoria({
      apiKey: "sk-teste-nao-real",
      requestBody: { model: "gpt-5.6-sol" },
      caminhoArtefato: path.join(dir, "audit_blind.json"),
      fingerprint: "fp1",
      validarLocalmente: validarRespostaBlindLocalmente,
      montarConteudoArtefato: () => ({}),
      fetchImpl: fetchHttpErro,
    });
    assert.equal(resultado.status, STATUS_ETAPA.HTTP_ERROR);
    assert.equal(resultado.bookkeeping.response_received, true, "HTTP_ERROR ainda recebeu uma resposta (so nao-ok)");
    assert.equal(resultado.bookkeeping.error_type, "HTTP_ERROR");
  } finally {
    limpar(dir);
  }
});

test("11. executarEtapaAuditoria: SCHEMA_ERROR (sem output_text) e LOCAL_VALIDATION_ERROR (schema ok mas regra de negocio falha) sao categorias separadas", async () => {
  const dir = dirTemp();
  try {
    const semOutputText = respostaHttpOk({ id: "r1", status: "completed", output: [] });
    const resultadoSchema = await executarEtapaAuditoria({
      apiKey: "x", requestBody: {}, caminhoArtefato: path.join(dir, "a.json"), fingerprint: "fp1",
      validarLocalmente: validarRespostaBlindLocalmente, montarConteudoArtefato: () => ({}), fetchImpl: semOutputText,
    });
    assert.equal(resultadoSchema.status, STATUS_ETAPA.SCHEMA_ERROR);

    const slotsRepetidos = respostaHttpOk({
      id: "r2", status: "completed", output: [{ content: [{ type: "output_text", text: JSON.stringify({
        answers: [
          { slot: 1, independent_answer: "B", unique_answer: true, ambiguity: "NONE", rule_applied: "x", reasoning_summary: "y", difficulty_observed: "media", confidence: "HIGH", issues: [] },
          { slot: 1, independent_answer: "C", unique_answer: true, ambiguity: "NONE", rule_applied: "x", reasoning_summary: "y", difficulty_observed: "media", confidence: "HIGH", issues: [] },
        ],
      }) }] }],
    });
    const resultadoLocal = await executarEtapaAuditoria({
      apiKey: "x", requestBody: {}, caminhoArtefato: path.join(dir, "b.json"), fingerprint: "fp1",
      validarLocalmente: validarRespostaBlindLocalmente, montarConteudoArtefato: () => ({}), fetchImpl: slotsRepetidos,
    });
    assert.equal(resultadoLocal.status, STATUS_ETAPA.LOCAL_VALIDATION_ERROR);
    assert.notEqual(resultadoLocal.status, resultadoSchema.status);
  } finally {
    limpar(dir);
  }
});

test("12. executarEtapaAuditoria: PERSISTENCE_ERROR impede seguir adiante (caminho de artefato invalido)", async () => {
  const dir = dirTemp();
  try {
    const caminhoInvalido = path.join(dir, "subdir-que-vira-arquivo");
    fs.mkdirSync(caminhoInvalido); // torna o caminho do artefato um diretorio nao-vazio -> rename falha
    fs.writeFileSync(path.join(caminhoInvalido, "algo.txt"), "x");

    const resultado = await executarEtapaAuditoria({
      apiKey: "x", requestBody: {}, caminhoArtefato: caminhoInvalido, fingerprint: "fp1",
      validarLocalmente: validarRespostaBlindLocalmente,
      montarConteudoArtefato: () => ({ audit_input_fingerprint: "fp1", answers: respostaBlindValida() }),
      fetchImpl: respostaHttpOk(respostaBlindValida()),
    });
    assert.equal(resultado.status, STATUS_ETAPA.PERSISTENCE_ERROR);
    assert.equal(resultado.bookkeeping.error_type, "PERSISTENCE_ERROR");
  } finally {
    limpar(dir);
  }
});

test("13. executarEtapaAuditoria: sucesso persiste ATOMICAMENTE (nenhum .tmp residual, arquivo final completo e legivel)", async () => {
  const dir = dirTemp();
  try {
    const caminho = path.join(dir, "audit_blind.json");
    const resultado = await executarEtapaAuditoria({
      apiKey: "x", requestBody: {}, caminhoArtefato: caminho, fingerprint: "fp1",
      validarLocalmente: validarRespostaBlindLocalmente,
      montarConteudoArtefato: ({ dadosValidados, fingerprint }) => ({ audit_input_fingerprint: fingerprint, answers: dadosValidados.answers }),
      fetchImpl: respostaHttpOk(respostaBlindValida()),
    });
    assert.equal(resultado.status, STATUS_ETAPA.PERSISTED);
    assert.equal(fs.existsSync(caminho), true);
    const arquivos = fs.readdirSync(dir);
    assert.equal(arquivos.some((f) => f.includes(".tmp-")), false, "nenhum arquivo .tmp residual apos escrita bem-sucedida");
    const lido = JSON.parse(fs.readFileSync(caminho, "utf8"));
    assert.equal(lido.audit_input_fingerprint, "fp1");
    assert.equal(lido.answers.length, 2);
  } finally {
    limpar(dir);
  }
});

// ==================== SIMULACAO Secao 15: A sucesso + B network fail ====================

test("14. SIMULACAO: Call A sucesso + Call B network fail -> blind persistido e valido, critic/result ausentes, proximo plano = RUN_CRITIC_ONLY (zero API real)", async () => {
  const dir = dirTemp();
  try {
    const fp = fingerprintFixture();
    const caminhoBlind = path.join(dir, "audit_blind.json");
    const caminhoCritic = path.join(dir, "audit_critic.json");

    const resultadoA = await executarEtapaAuditoria({
      apiKey: "x", requestBody: {}, caminhoArtefato: caminhoBlind, fingerprint: fp,
      validarLocalmente: validarRespostaBlindLocalmente,
      montarConteudoArtefato: ({ dadosValidados, fingerprint: fpp }) => ({ audit_input_fingerprint: fpp, answers: dadosValidados.answers }),
      fetchImpl: respostaHttpOk(respostaBlindValida()),
    });
    assert.equal(resultadoA.status, STATUS_ETAPA.PERSISTED);

    const resultadoB = await executarEtapaAuditoria({
      apiKey: "x", requestBody: {}, caminhoArtefato: caminhoCritic, fingerprint: fp,
      validarLocalmente: validarRespostaCriticLocalmente,
      montarConteudoArtefato: () => ({}),
      fetchImpl: async () => { throw new TypeError("fetch failed"); },
    });
    assert.equal(resultadoB.status, STATUS_ETAPA.NETWORK_ERROR);

    assert.equal(fs.existsSync(caminhoBlind), true, "audit_blind.json permanece persistido apos a falha de B");
    assert.equal(fs.existsSync(caminhoCritic), false, "audit_critic.json nao pode existir — B falhou");
    assert.equal(fs.existsSync(path.join(dir, "audit_result.json")), false);

    const estado = lerEstadoAuditoria(dir);
    assert.equal(estado.blind.valido, true);
    const plano = planejarRetomada({ fingerprintAtual: fp, blindPersistido: estado.blind, criticPersistido: estado.critic, resultPersistido: estado.result });
    assert.equal(plano.action, ACOES_RETOMADA.RUN_CRITIC_ONLY);
  } finally {
    limpar(dir);
  }
});

// ==================== SIMULACAO Secao 16: retomada com blind ja persistido ====================

test("15. SIMULACAO: retomada com blind persistido -> Call A NAO e re-executada (0 chamadas), so Call B (1 chamada simulada), depois agrega (zero API real)", async () => {
  const dir = dirTemp();
  try {
    const fp = fingerprintFixture();
    const caminhoBlind = path.join(dir, "audit_blind.json");
    const caminhoCritic = path.join(dir, "audit_critic.json");

    escreverArtefatoJson(caminhoBlind, { audit_input_fingerprint: fp, answers: JSON.parse(respostaBlindValida().output[0].content[0].text).answers });

    const estadoAntes = lerEstadoAuditoria(dir);
    const plano = planejarRetomada({ fingerprintAtual: fp, blindPersistido: estadoAntes.blind, criticPersistido: estadoAntes.critic, resultPersistido: estadoAntes.result });
    assert.equal(plano.action, ACOES_RETOMADA.RUN_CRITIC_ONLY);

    // Simula exatamente a logica do CLI: so chama A se plano === RUN_BLIND_THEN_CRITIC.
    let chamadasA = 0;
    let chamadasB = 0;
    if (plano.action === ACOES_RETOMADA.RUN_BLIND_THEN_CRITIC) {
      chamadasA += 1;
      // (nao deveria rodar neste teste)
    }
    if (plano.action === ACOES_RETOMADA.RUN_BLIND_THEN_CRITIC || plano.action === ACOES_RETOMADA.RUN_CRITIC_ONLY) {
      chamadasB += 1;
      const resultadoB = await executarEtapaAuditoria({
        apiKey: "x", requestBody: {}, caminhoArtefato: caminhoCritic, fingerprint: fp,
        validarLocalmente: validarRespostaCriticLocalmente,
        montarConteudoArtefato: ({ dadosValidados, fingerprint: fpp }) => ({ audit_input_fingerprint: fpp, audits: dadosValidados.audits }),
        fetchImpl: respostaHttpOk(respostaCriticValida()),
      });
      assert.equal(resultadoB.status, STATUS_ETAPA.PERSISTED);
    }

    assert.equal(chamadasA, 0, "Call A nao pode ser reexecutada quando o blind ja esta persistido e valido");
    assert.equal(chamadasB, 1);
    assert.equal(fs.existsSync(caminhoCritic), true);

    const estadoDepois = lerEstadoAuditoria(dir);
    assert.equal(estadoDepois.blind.valido, true);
    assert.equal(estadoDepois.critic.valido, true);
    const planoFinal = planejarRetomada({ fingerprintAtual: fp, blindPersistido: estadoDepois.blind, criticPersistido: estadoDepois.critic, resultPersistido: estadoDepois.result });
    assert.equal(planoFinal.action, ACOES_RETOMADA.AGGREGATE_ONLY);
  } finally {
    limpar(dir);
  }
});

// ==================== SEGREDOS E IMUTABILIDADE ====================

test("16. nenhum segredo aparece em nenhum artefato persistido pelos testes acima", async () => {
  const dir = dirTemp();
  try {
    const fp = fingerprintFixture();
    const caminhoBlind = path.join(dir, "audit_blind.json");
    await executarEtapaAuditoria({
      apiKey: "sk-super-secreta-nao-pode-vazar",
      requestBody: {},
      caminhoArtefato: caminhoBlind,
      fingerprint: fp,
      validarLocalmente: validarRespostaBlindLocalmente,
      montarConteudoArtefato: ({ dadosValidados, fingerprint: fpp }) => ({ audit_input_fingerprint: fpp, answers: dadosValidados.answers }),
      fetchImpl: respostaHttpOk(respostaBlindValida()),
    });
    const conteudo = fs.readFileSync(caminhoBlind, "utf8");
    assert.equal(conteudo.includes("sk-super-secreta-nao-pode-vazar"), false);
  } finally {
    limpar(dir);
  }
});

test("17. CLI de auditoria nunca escreve em questoes_geradas.json (varredura estatica do codigo-fonte)", () => {
  const caminhoCli = new URL("../scripts/curadoria-autoral/cli/auditar-questoes.mjs", import.meta.url);
  const codigo = fs.readFileSync(caminhoCli, "utf8");
  const escritasParaQuestoes = /escreverArtefatoJson\(\s*caminhoQuestoes/;
  assert.equal(escritasParaQuestoes.test(codigo), false, "cli/auditar-questoes.mjs nao pode ter nenhuma chamada de escrita em caminhoQuestoes");
});
