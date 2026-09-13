// Reparo Lote 09A ("CORREÇÃO DO GERADOR + REGENERAÇÃO CONTROLADA"): a
// suite de 213 testes anterior NUNCA inspecionava o TEXTO FINAL produzido
// por montarPromptGerador() — so testava metadados estruturais do prompt
// (slots, ausencia de enunciado REAL, ausencia de segredo). Por isso nao
// detectou que a instrucao de fundamento estava hardcoded para GRAMATICAL
// mesmo em payloads juridicos (source.legal_source_required=true), o que
// gerou 24/26 candidatas REJECTED_PRE_AUDIT no Lote09A por contradicao
// textual dentro do proprio prompt.
//
// Este arquivo fecha essa lacuna: inspeciona o texto efetivo do prompt para
// dois payloads reais (juridico e gramatical) e trava, de forma permanente,
// que as duas instrucoes NUNCA coexistam no mesmo prompt.
import assert from "node:assert/strict";
import test from "node:test";
import { montarPromptGerador, montarInstrucaoFundamento } from "../scripts/curadoria-autoral/lib/openai-provider.mjs";

function payloadBase(overrides = {}) {
  return {
    run_id: "run-teste-fundamento",
    course: { id: "curso-1", slug: "curso-teste", name: "Curso Teste" },
    bank: { name: "Fundatec", resolution_status: "RESOLVED" },
    subject: { id: "10", name: "Legislação Específica" },
    content: { course_content_id: "60", subject_topic_id: "69", name: "Poder de Polícia" },
    unit: { id: "unidade-juridica-1", title: "Poder de Polícia" },
    lesson: { id: null, exists: false },
    coverage: { missing: 6 },
    generation: {
      quantity: 2,
      origin: "AUTORAL_PAPIRO",
      pedagogical_objectives: [
        { slot: 1, nucleo: "Conceito legal", objetivo: "Testar o conceito legal de poder de policia.", dificuldade_sugerida: "media" },
        { slot: 2, nucleo: "Principios de atuacao", objetivo: "Testar principios da Lei9.784/99 art.2.", dificuldade_sugerida: "media" },
      ],
    },
    references: { real_question_ids: [] },
    pedagogical_context: { scope: "Poder de Polícia: escopo de teste." },
    source: { status: "SOURCE_VALIDATED", legal_source_required: true, validated_source_keys: ["fonte-teste"] },
    constraints: {
      requirements: ["exatamente 5 alternativas A-E", 'fundamento.tipo deve ser "regra_normativa" quando a materia for normativa/legislativa'],
      prohibitions: ["Não usar fonte diferente da validada."],
    },
    ...overrides,
  };
}

function payloadGramaticalFixture() {
  return payloadBase({
    subject: { id: "6", name: "Língua Portuguesa" },
    content: { course_content_id: "18", subject_topic_id: "14", name: "Concordância verbal" },
    unit: { id: "unidade-gramatical-1", title: "Concordância verbal" },
    pedagogical_context: { scope: "Concordância verbal: escopo de teste, sem PII." },
    source: { status: "SOURCE_VALIDATED", validated_source_keys: ["fonte-teste"] }, // sem legal_source_required
    constraints: {
      requirements: ["exatamente 5 alternativas A-E"],
      prohibitions: ["Não tratar o verbo existir como impessoal."],
    },
  });
}

const FRASE_PROIBICAO_GRAMATICAL = "NÃO cite lei, artigo jurídico ou jurisprudência em nenhum campo";
const FRASE_FUNDAMENTO_GRAMATICAL = "Fundamento desta questão é GRAMATICAL";

// ---------- CASO 1 — payload juridico ----------

test("CASO 1 (juridico) — prompt contem orientacao de regra_normativa", () => {
  const prompt = montarPromptGerador(payloadBase());
  assert.match(prompt, /regra_normativa/);
});

test("CASO 1 (juridico) — prompt exige diploma + artigo", () => {
  const prompt = montarPromptGerador(payloadBase());
  assert.match(prompt, /diploma/i);
  assert.match(prompt, /artigo/i);
});

test("CASO 1 (juridico) — prompt NAO contem a instrucao gramatical hardcoded", () => {
  const prompt = montarPromptGerador(payloadBase());
  assert.equal(prompt.includes(FRASE_FUNDAMENTO_GRAMATICAL), false, "prompt juridico nao pode instruir fundamento gramatical");
});

test("CASO 1 (juridico) — prompt NAO contem proibicao de citar lei/artigo", () => {
  const prompt = montarPromptGerador(payloadBase());
  assert.equal(prompt.includes(FRASE_PROIBICAO_GRAMATICAL), false, 'prompt juridico nao pode conter "NAO cite lei"');
  assert.doesNotMatch(prompt, /n[ãa]o cite lei/i);
});

test("CASO 1 (juridico) — prompt proibe explicitamente fundamento.tipo regra_gramatical", () => {
  const prompt = montarPromptGerador(payloadBase());
  assert.match(prompt, /regra_gramatical/);
  assert.match(prompt, /n[ãa]o use fundamento\.tipo="regra_gramatical"/i);
});

// ---------- CASO 2 — payload gramatical (Portugues) ----------

test("CASO 2 (gramatical) — Portugues continua recebendo a instrucao gramatical original", () => {
  const prompt = montarPromptGerador(payloadGramaticalFixture());
  assert.equal(prompt.includes(FRASE_FUNDAMENTO_GRAMATICAL), true, "correcao juridica nao pode remover o comportamento gramatical existente");
  assert.equal(prompt.includes(FRASE_PROIBICAO_GRAMATICAL), true);
});

test("CASO 2 (gramatical) — Portugues NAO recebe instrucao normativa indevida", () => {
  const prompt = montarPromptGerador(payloadGramaticalFixture());
  assert.equal(prompt.includes('fundamento.tipo DEVE ser exatamente "regra_normativa"'), false, "materia gramatical nao pode ser instruida a produzir fundamento normativo");
});

// ---------- CASO 3 — contradicao nunca pode coexistir ----------

test("CASO 3 (contradicao) — nenhum prompt pode conter simultaneamente instrucao normativa E proibicao de citar lei", () => {
  for (const payload of [payloadBase(), payloadGramaticalFixture()]) {
    const prompt = montarPromptGerador(payload);
    const temInstrucaoNormativa = /fundamento\.tipo\s*DEVE ser exatamente "regra_normativa"/i.test(prompt);
    const temProibicaoCitarLei = /n[ãa]o cite lei/i.test(prompt);
    assert.equal(
      temInstrucaoNormativa && temProibicaoCitarLei,
      false,
      `payload ${payload.unit.id}: prompt nao pode conter as duas instrucoes contraditorias ao mesmo tempo`
    );
  }
});

test("CASO 3 (contradicao) — montarInstrucaoFundamento e a unica fonte da instrucao de fundamento no prompt (funcao pura, sem I/O)", () => {
  const instrucaoJuridica = montarInstrucaoFundamento(payloadBase());
  const instrucaoGramatical = montarInstrucaoFundamento(payloadGramaticalFixture());
  assert.notEqual(instrucaoJuridica, instrucaoGramatical);
  assert.match(instrucaoJuridica, /regra_normativa/);
  assert.match(instrucaoGramatical, /GRAMATICAL/);
});

// ---------- Smoke test explicito (Secao 12 do mandato) ----------

test("SMOKE TEST — prompt juridico real do Lote09A: os 4 sinais esperados", () => {
  const prompt = montarPromptGerador(payloadBase());
  const sinais = {
    contains_regra_normativa_instruction: /regra_normativa/.test(prompt),
    contains_diploma_article_requirement: /diploma/i.test(prompt) && /artigo/i.test(prompt),
    contains_grammatical_foundation_instruction: prompt.includes(FRASE_FUNDAMENTO_GRAMATICAL),
    contains_do_not_cite_law_instruction: /n[ãa]o cite lei/i.test(prompt),
  };
  assert.equal(sinais.contains_regra_normativa_instruction, true);
  assert.equal(sinais.contains_diploma_article_requirement, true);
  assert.equal(sinais.contains_grammatical_foundation_instruction, false);
  assert.equal(sinais.contains_do_not_cite_law_instruction, false);
});
