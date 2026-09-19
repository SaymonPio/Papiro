import assert from "node:assert/strict";
import test from "node:test";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import path from "node:path";
import {
  montarPromptContexto,
  PROMPT_VERSION,
  resolverConfiguracaoModelo,
  submeterResponseBackground,
} from "../supabase/functions/_shared/gerar-aula/openaiResponses.mjs";
import {
  QUADRINHO_LIMITES,
  TIPOS_COMPONENTE_OBRIGATORIOS,
  validarRespostaGerador,
} from "../supabase/functions/_shared/gerar-aula/validador.mjs";

// Fase Q4 — o PROMPT ensina a IA a criar quadrinho_didatico (opcional).
// Tudo local e determinístico: nenhuma chamada à OpenAI (fetch é mockado
// onde necessário).

const raiz = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const codigoPrompt = readFileSync(path.join(raiz, "supabase/functions/_shared/gerar-aula/openaiResponses.mjs"), "utf8");
const codigoValidador = readFileSync(path.join(raiz, "supabase/functions/_shared/gerar-aula/validador.mjs"), "utf8");

function montar(materiaNome = "Direito Constitucional", conteudoNome = "Direitos Fundamentais") {
  return montarPromptContexto(
    { concurso: "X", cargo: "Y", banca: "Z", materiaNome, conteudoNome },
    [],
    [],
    [],
    { temMetadata: true, escopoAutorizado: "escopo autorizado de teste", partesIrmasTitulos: [] },
    "bloco de jurisprudência",
  );
}

const prompt = montar();
const L = QUADRINHO_LIMITES;

function blocoQuadrinho(texto) {
  const i = texto.indexOf('QUADRINHO DIDÁTICO ("quadrinho_didatico")');
  const f = texto.indexOf("Responda SOMENTE em JSON válido");
  assert.ok(i > -1 && f > i, "bloco do quadrinho não encontrado");
  return texto.slice(i, f);
}

const bloco = blocoQuadrinho(prompt);
const formatoQuadrinho = prompt.match(/\{ "tipo": "quadrinho_didatico"[^\n]*?"fechamento": "" \}/)?.[0] ?? "";

test("Q4-1: o prompt conhece quadrinho_didatico e o inclui no formato JSON", () => {
  assert.match(prompt, /"tipo": "quadrinho_didatico"/);
  assert.ok(formatoQuadrinho.length > 0, "formato JSON do quadrinho não encontrado");
});

test("Q4-2..7,9: o schema declara titulo, quadros, cena, falas, emissor, texto e fechamento", () => {
  for (const campo of ['"titulo": ""', '"quadros": [', '"cena": ""', '"falas": [', '"emissor": ""', '"texto": ""', '"fechamento": ""']) {
    assert.ok(formatoQuadrinho.includes(campo), `formato do quadrinho sem ${campo}`);
  }
});

test("Q4-8: legenda é apresentada como opcional (string ou null)", () => {
  assert.ok(formatoQuadrinho.includes('"legenda": "" | null'));
  assert.match(bloco, /"legenda": opcional/);
});

test("Q4-10/11: o prompt proíbe id, imagem e assets na V1 (e qualquer outro campo)", () => {
  assert.match(prompt, /NUNCA inclua em "quadrinho_didatico"/);
  for (const campo of ['"id"', "imagem", '"alt"', '"asset_id"', '"url"', '"html"', '"fundamento"', '"objetivo_pedagogico"', '"ordem"']) {
    assert.ok(prompt.includes(campo), `prompt deveria citar a proibição de ${campo}`);
  }
  assert.match(prompt, /nesta versão não existe imagem/);
  assert.match(prompt, /NÃO envie número de ordem/);
  assert.match(prompt, /EXATAMENTE os campos "tipo", "titulo", "quadros" e "fechamento"/);
});

test("Q4-12/13: os limites do prompt são exatamente os do validador (3–6 quadros, 0–3 falas, tamanhos)", () => {
  assert.match(bloco, new RegExp(`de ${L.quadrosMin} a ${L.quadrosMax} quadros`));
  assert.match(prompt, new RegExp(`"quadros" tem de ${L.quadrosMin} a ${L.quadrosMax} itens`));
  assert.match(bloco, new RegExp(`de 0 a ${L.falasPorQuadroMax} por quadro`));
  for (const [rotulo, valor] of [
    ["cena", L.cenaMax], ["emissor", L.emissorMax], ["texto", L.falaTextoMax],
    ["legenda", L.legendaMax], ["fechamento", L.fechamentoMax], ["titulo", L.tituloMax],
  ]) {
    assert.match(bloco, new RegExp(`até ${valor} caracteres`), `limite de ${rotulo} (${valor})`);
  }
  assert.ok(!/\$\{|undefined|NaN/.test(prompt), "prompt sem placeholders não resolvidos");
});

test("Q4-12b: os limites vêm do módulo do validador (fonte única), sem cópia numérica no prompt", () => {
  assert.match(codigoPrompt, /import \{ QUADRINHO_LIMITES \} from "\.\/validador\.mjs"/);
  assert.doesNotMatch(codigoValidador, /openaiResponses/, "sem dependência circular");
  for (const chave of Object.keys(QUADRINHO_LIMITES)) {
    assert.ok(codigoPrompt.includes(`QUADRINHO_LIMITES.${chave}`), `o prompt deve interpolar QUADRINHO_LIMITES.${chave}`);
  }
});

test("Q4-14/15/16: opcional, zero é válido e no máximo 3 por aula", () => {
  assert.match(bloco, /COMPONENTE OPCIONAL/);
  assert.match(bloco, /A AUSÊNCIA de quadrinho é uma resposta perfeita/);
  assert.match(bloco, /na dúvida, o correto é NÃO gerar/);
  assert.match(prompt, /zero quadrinhos é uma resposta válida/);
  assert.match(bloco, /padrão é de 0 a 2 quadrinhos por aula/);
  assert.match(bloco, /excepcionalmente até 3/);
  assert.match(bloco, /NUNCA mais de 3 por aula/);
});

test("Q4-17: decisão por ganho pedagógico concreto, sem score numérico", () => {
  assert.match(bloco, /ganho pedagógico concreto/);
  for (const sinal of ["situação prática facilmente representável", "interação entre duas ou mais pessoas", "regra com exceção", "pegadinha recorrente de prova", "confusão comum"]) {
    assert.ok(bloco.includes(sinal), sinal);
  }
  assert.doesNotMatch(bloco, /pontuação|score|nota mínima/i);
});

test("Q4-18: NÃO gerar quando o exemplo já basta, quando outro visual é melhor ou quando seria preciso inventar", () => {
  assert.match(bloco, /NÃO crie quadrinho quando/);
  assert.match(bloco, /campo "exemplo" do próprio conceito já resolver bem a compreensão/);
  assert.match(bloco, /tabela, fórmula, diagrama ou tela real/);
  assert.match(bloco, /for preciso inventar regra, exceção ou interpretação/);
  assert.match(bloco, /o campo "exemplo" do conceito continua existindo normalmente/);
});

test("Q4-19/20: trava de escopo crítica e jurisprudência proibida no quadrinho", () => {
  assert.match(bloco, /TRAVA DE ESCOPO DO QUADRINHO — CRÍTICA/);
  assert.match(bloco, /ESCOPO AUTORIZADO desta aula/);
  for (const proibido of ["acrescentar dispositivo", "criar exceção", "criar requisito", "ampliar ou restringir direito", "inventar jurisprudência", "ensinar conteúdo de outra unidade"]) {
    assert.ok(bloco.includes(proibido), proibido);
  }
  assert.match(bloco, /NÃO use jurisprudência dentro do quadrinho/);
  assert.match(bloco, /somente no componente "jurisprudencia_essencial"/);
  assert.match(bloco, /NÃO gere o quadrinho/);
  assert.match(prompt, /quadrinho_didatico \(quando existir\): cena, falas, legenda e fechamento ilustram SOMENTE/);
});

test("Q4-21: posicionamento imediatamente depois do conceito que ilustra, nunca no fim", () => {
  assert.match(bloco, /IMEDIATAMENTE depois do "conceito" que ele ilustra/);
  assert.match(bloco, /conceito → quadrinho_didatico → recall/);
  assert.match(bloco, /NUNCA acumule quadrinhos no fim da aula/);
  assert.match(bloco, /NUNCA crie uma seção separada/);
});

test("Q4-22: sem hardcode por matéria/curso — o bloco é idêntico para qualquer matéria e não é obrigatório", () => {
  const outro = blocoQuadrinho(montar("Matemática", "Porcentagem"));
  assert.equal(outro, bloco);
  assert.match(bloco, /Não é obrigatório em nenhuma aula, matéria ou curso/);
  assert.match(bloco, /cálculo, raciocínio lógico, fórmulas, tabelas, interface de software/);
  assert.doesNotMatch(bloco, /materia_id|curso_id|Lei Maria da Penha|Direitos e Garantias/);
});

test("Q4-22b: orientação para contexto policial (cenas neutras) e personagens fictícios não são fonte jurídica", () => {
  assert.match(bloco, /nada gráfico, sensacionalista, humilhante ou estereotipado/);
  assert.match(bloco, /agente ouve pedido de socorro vindo de uma residência/);
  assert.match(bloco, /personagens fictícios[^.]*não são fonte jurídica/);
});

test("Q4-23: os tipos obrigatórios e a regra da jurisprudência foram preservados", () => {
  assert.match(prompt, /pelo menos um componente de cada um dos 5 tipos \(diagnostico, conceito, recall, questao_resolvida, resumo_visual\) é OBRIGATÓRIO/);
  assert.match(prompt, /o componente "jurisprudencia_essencial" é OPCIONAL/);
  assert.match(prompt, /NUNCA crie este componente sem jurisprudência validada/);
  assert.match(prompt, /NÃO altera a obrigatoriedade dos 5 tipos acima/);
  assert.match(prompt, /NUNCA inclua um campo "id" em nenhum componente/);
  assert.deepEqual(TIPOS_COMPONENTE_OBRIGATORIOS, ["diagnostico", "conceito", "recall", "questao_resolvida", "resumo_visual"]);
});

test("Q4-24: PROMPT_VERSION foi incrementada (3a-async-v1 → 3b-quadrinho-v1)", () => {
  assert.notEqual(PROMPT_VERSION, "3a-async-v1");
  assert.equal(PROMPT_VERSION, "3b-quadrinho-v1");
});

test("Q4-25: nenhuma configuração da Responses API mudou (modelo, reasoning, tokens, background, store, endpoint, formato)", async () => {
  const config = resolverConfiguracaoModelo(() => undefined);
  assert.deepEqual(config, { modelo: "gpt-5.6-luna", reasoningEffort: "high", maxOutputTokens: 12000 });

  const original = globalThis.fetch;
  let chamada;
  globalThis.fetch = async (url, init) => {
    chamada = { url, corpo: JSON.parse(init.body) };
    return { ok: true, status: 200, json: async () => ({ id: "resp_mock", status: "queued" }) };
  };
  try {
    const r = await submeterResponseBackground({
      openaiKey: "chave-falsa-de-teste", modelo: "m", reasoningEffort: "high", maxOutputTokens: 12000, textoPrompt: prompt, anexos: [],
    });
    assert.equal(r.ok, true);
  } finally {
    globalThis.fetch = original;
  }
  assert.equal(chamada.url, "https://api.openai.com/v1/responses");
  assert.deepEqual(Object.keys(chamada.corpo).sort(), ["background", "input", "max_output_tokens", "model", "reasoning", "store", "text"]);
  assert.equal(chamada.corpo.background, true);
  assert.equal(chamada.corpo.store, true);
  assert.deepEqual(chamada.corpo.text, { format: { type: "json_object" } });
});

// ---------- integração local: fixture → validador real → ids do servidor ----------

function fixtureComQuadrinho() {
  return {
    artigos_abordados: ["art. 5º, XI"],
    componentes: [
      { tipo: "diagnostico", titulo: "O que você já sabe?", introducao: "Antes de decorar, pense na prática.", pergunta: "Pode entrar na casa à noite?", resposta_esperada: "Depende da situação." },
      { tipo: "conceito", titulo: "Inviolabilidade do domicílio", explicacao: "A casa é asilo inviolável; a regra é o consentimento do morador.", exemplo: "Incêndio permite entrar.", ponto_de_prova: "Só ordem judicial exige o dia.", pegadinha: "Ordem judicial não vale à noite." },
      {
        tipo: "quadrinho_didatico",
        titulo: "Socorro à noite",
        quadros: [
          { cena: "Agente passa em frente a uma residência à noite e ouve pedido de socorro.", falas: [{ emissor: "Voz", texto: "Socorro!" }], legenda: null },
          { cena: "O agente hesita por não ter ordem judicial.", falas: [] },
          { cena: "O agente entra para prestar socorro.", falas: [{ emissor: "Agente", texto: "Vou entrar para socorrer." }], legenda: "Socorro autoriza a qualquer hora." },
        ],
        fechamento: "Flagrante, desastre e socorro: a qualquer hora. Ordem judicial: só de dia.",
      },
      { tipo: "recall", titulo: "Recupere", pergunta: "Quais são as hipóteses?", resposta: "Flagrante, desastre, socorro e ordem judicial de dia.", dica: null },
      { tipo: "questao_resolvida", enunciado: "Assinale a correta.", alternativas: [{ letra: "A", texto: "a" }, { letra: "B", texto: "b" }, { letra: "C", texto: "c" }, { letra: "D", texto: "d" }], gabarito: "B", raciocinio: "B está correta.", pegadinha: null },
      { tipo: "resumo_visual", titulo: "Resumo", pontos: ["Casa: consentimento é a regra.", "Exceções: flagrante, desastre, socorro."] },
    ],
  };
}

test("Q4-integração: resposta com quadrinho entre conceito e recall passa no validador real, na posição correta", () => {
  const r = validarRespostaGerador(fixtureComQuadrinho());
  assert.equal(r.ok, true, r.erro);
  assert.deepEqual(r.componentes.map((c) => c.tipo), ["diagnostico", "conceito", "quadrinho_didatico", "recall", "questao_resolvida", "resumo_visual"]);
});

test("Q4-integração: o servidor adiciona ids (mesma regra do persistirAulaGerada) sem mudar o contrato", () => {
  const r = validarRespostaGerador(fixtureComQuadrinho());
  const comId = r.componentes.map((c) => ({ id: crypto.randomUUID(), ...c }));
  const quadrinho = comId.find((c) => c.tipo === "quadrinho_didatico");
  assert.match(quadrinho.id, /^[0-9a-f-]{36}$/);
  assert.equal(quadrinho.quadros.length, 3);
  assert.deepEqual(Object.keys(quadrinho).sort(), ["fechamento", "id", "quadros", "tipo", "titulo"]);
  assert.equal(new Set(comId.map((c) => c.id)).size, comId.length);
  // a mesma resposta, agora com id vindo da IA, continua sendo rejeitada
  const invalida = fixtureComQuadrinho();
  invalida.componentes[2].id = "x";
  assert.equal(validarRespostaGerador(invalida).ok, false);
});

test("Q4-integração: uma aula sem quadrinho (resposta antiga) continua válida com o prompt novo", () => {
  const dados = fixtureComQuadrinho();
  dados.componentes.splice(2, 1);
  assert.equal(validarRespostaGerador(dados).ok, true);
});
