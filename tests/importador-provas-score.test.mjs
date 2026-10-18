import assert from "node:assert/strict";
import test from "node:test";
import { calcularStatus } from "../scripts/importador-provas/lib/score.mjs";

// PAPIRO — PoC do importador de provas: score/status final por questão.
// Fixture 100% sintética — objetos já no formato normalizado (ver
// normalizar.mjs), construídos à mão para isolar a lógica de score.

function questaoBase(overrides = {}) {
  return {
    numero_original: 1,
    enunciado: "Enunciado de teste",
    alternativas: [{ letra: "A" }, { letra: "B" }, { letra: "C" }, { letra: "D" }],
    confidence: "nenhuma",
    _interno: {
      alternativa_faltante: false,
      motivos_juncao: [],
      gabarito_status: "ok",
    },
    ...overrides,
  };
}

const DEDUP_NOVA = { status: "nova", motivo: "sem correspondencia", match_id: null };
const PROVENIENCIA_COMPLETA = { prova: {}, completa: true, faltando: [], invalidos: [] };

test("A) questão limpa (extração ok, gabarito ok, dedup 'nova') é PRONTA_PARA_REVISAO mesmo com classificação incerta", () => {
  const resultado = calcularStatus(questaoBase(), DEDUP_NOVA, [], PROVENIENCIA_COMPLETA);
  assert.equal(resultado.etapas.EXTRACAO_OK, true);
  assert.equal(resultado.etapas.GABARITO_OK, true);
  assert.equal(resultado.etapas.DEDUP_OK, true);
  assert.equal(resultado.etapas.CLASSIFICACAO_OK, false); // confidence "nenhuma" nunca é CLASSIFICACAO_OK
  assert.equal(resultado.status, "PRONTA_PARA_REVISAO");
});

test("B) alternativa faltante -> EXTRACAO_OK=false e status REVISAO_MANUAL, com motivo explícito", () => {
  const resultado = calcularStatus(questaoBase({ _interno: { ...questaoBase()._interno, alternativa_faltante: true } }), DEDUP_NOVA, [], PROVENIENCIA_COMPLETA);
  assert.equal(resultado.etapas.EXTRACAO_OK, false);
  assert.equal(resultado.status, "REVISAO_MANUAL");
  assert.ok(resultado.motivos.some((m) => /alternativa/.test(m)));
});

test("C) gabarito ausente -> GABARITO_OK=false e REVISAO_MANUAL", () => {
  const questao = questaoBase({ _interno: { ...questaoBase()._interno, motivos_juncao: ["questao_sem_gabarito"] } });
  const resultado = calcularStatus(questao, DEDUP_NOVA, [], PROVENIENCIA_COMPLETA);
  assert.equal(resultado.etapas.GABARITO_OK, false);
  assert.equal(resultado.status, "REVISAO_MANUAL");
});

test("D) matéria incerta (confidence baixa/nenhuma) nunca bloqueia por si só — só reduz CLASSIFICACAO_OK", () => {
  const resultado = calcularStatus(questaoBase({ confidence: "baixa" }), DEDUP_NOVA, [], PROVENIENCIA_COMPLETA);
  assert.equal(resultado.etapas.CLASSIFICACAO_OK, false);
  assert.equal(resultado.status, "PRONTA_PARA_REVISAO", "classificação incerta não deve, por si só, forçar revisão manual total");
});

test("E) provável duplicidade -> DEDUP_OK=false e REVISAO_MANUAL, motivo cita o id em conflito", () => {
  const dedup = { status: "provavel_duplicada", motivo: "similaridade Jaccard 0.40 com questoes.id=42", match_id: 42 };
  const resultado = calcularStatus(questaoBase(), dedup, [], PROVENIENCIA_COMPLETA);
  assert.equal(resultado.etapas.DEDUP_OK, false);
  assert.equal(resultado.status, "REVISAO_MANUAL");
  assert.ok(resultado.motivos.some((m) => m.includes("42")));
});

test("F) duplicada exata -> DEDUP_OK=false e REVISAO_MANUAL (nunca descartada silenciosamente)", () => {
  const dedup = { status: "duplicada", motivo: "enunciado identico", match_id: 7 };
  const resultado = calcularStatus(questaoBase(), dedup, [], PROVENIENCIA_COMPLETA);
  assert.equal(resultado.etapas.DEDUP_OK, false);
  assert.equal(resultado.status, "REVISAO_MANUAL");
});

test("G) bloqueio global específico desta questão (ex.: número duplicado) força REVISAO_MANUAL mesmo com as outras etapas OK", () => {
  const bloqueios = [{ tipo: "numero_duplicado", numero: 1, mensagem: "questão nº 1 aparece mais de uma vez" }];
  const resultado = calcularStatus(questaoBase(), DEDUP_NOVA, bloqueios, PROVENIENCIA_COMPLETA);
  assert.equal(resultado.status, "REVISAO_MANUAL");
  assert.ok(resultado.motivos.some((m) => m.includes("mais de uma vez")));
});

test("H) bloqueio global de OUTRA questão não afeta esta questão", () => {
  const bloqueios = [{ tipo: "numero_duplicado", numero: 99, mensagem: "questão nº 99 aparece mais de uma vez" }];
  const resultado = calcularStatus(questaoBase(), DEDUP_NOVA, bloqueios, PROVENIENCIA_COMPLETA);
  assert.equal(resultado.status, "PRONTA_PARA_REVISAO");
});

test("I) contagem de bloco/matéria divergente da declarada no cabeçalho -> EXTRACAO_OK=false e REVISAO_MANUAL, motivo cita a matéria", () => {
  const questao = questaoBase({
    _interno: { ...questaoBase()._interno, contagem_materia_divergente: true, materia_detectada: "Estudos Sociais" },
  });
  const resultado = calcularStatus(questao, DEDUP_NOVA, [], PROVENIENCIA_COMPLETA);
  assert.equal(resultado.etapas.EXTRACAO_OK, false);
  assert.equal(resultado.status, "REVISAO_MANUAL");
  assert.ok(resultado.motivos.some((m) => m.includes("Estudos Sociais")));
});

test("J) sem proveniência informada -> PROVENIENCIA_OK=false e REVISAO_MANUAL (proveniência é obrigatória)", () => {
  const resultado = calcularStatus(questaoBase(), DEDUP_NOVA, []);
  assert.equal(resultado.etapas.PROVENIENCIA_OK, false);
  assert.equal(resultado.status, "REVISAO_MANUAL");
  assert.ok(resultado.motivos.some((m) => /proveniência/.test(m)));
});

test("K) proveniência incompleta -> REVISAO_MANUAL, motivo cita os campos ausentes e inválidos", () => {
  const proveniencia = { prova: {}, completa: false, faltando: ["hash_gabarito"], invalidos: ["fonte_url"] };
  const resultado = calcularStatus(questaoBase(), DEDUP_NOVA, [], proveniencia);
  assert.equal(resultado.etapas.PROVENIENCIA_OK, false);
  assert.equal(resultado.status, "REVISAO_MANUAL");
  assert.ok(resultado.motivos.some((m) => m.includes("hash_gabarito ausente") && m.includes("fonte_url inválido")));
});
