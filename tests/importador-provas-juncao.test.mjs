import assert from "node:assert/strict";
import test from "node:test";
import { juntarQuestoesEGabarito } from "../scripts/importador-provas/lib/juncao.mjs";

// PAPIRO — PoC do importador de provas: junção questão <-> gabarito.
// Fixture 100% sintética — objetos construídos à mão, sem depender da
// extração real (isola a lógica de junção da lógica de extração).

function questao(numero, letras = ["A", "B", "C", "D"]) {
  return {
    numero_original: numero,
    enunciado: `Enunciado de teste da questão ${numero}`,
    alternativas: letras.map((letra) => ({ letra, texto: `alternativa ${letra} da questão ${numero}` })),
    pagina_origem: 1,
    atravessa_pagina: false,
    texto_base_id: null,
    texto_base: null,
    alternativa_faltante: letras.length < 4,
  };
}

function gabarito(numero, letra, extra = {}) {
  return { numero, alternativa_correta: letra, anulada: false, alterada: false, observacao: null, status: "ok", ...extra };
}

test("A) junção normal: cada questão recebe o gabarito do mesmo número, sem bloqueios", () => {
  const { juntadas, bloqueios } = juntarQuestoesEGabarito([questao(1), questao(2)], [gabarito(1, "A"), gabarito(2, "B")]);
  assert.equal(bloqueios.length, 0);
  assert.equal(juntadas[0].gabarito.alternativa_correta, "A");
  assert.equal(juntadas[1].gabarito.alternativa_correta, "B");
  assert.deepEqual(juntadas[0].motivos_juncao, []);
});

test("B) questão sem gabarito: motivo 'questao_sem_gabarito', gabarito fica null, nunca inventado", () => {
  const { juntadas } = juntarQuestoesEGabarito([questao(1), questao(2)], [gabarito(1, "A")]);
  const q2 = juntadas.find((j) => j.numero_original === 2);
  assert.equal(q2.gabarito, null);
  assert.ok(q2.motivos_juncao.includes("questao_sem_gabarito"));
});

test("C) gabarito sem questão correspondente é reportado como bloqueio global", () => {
  const { bloqueios } = juntarQuestoesEGabarito([questao(1)], [gabarito(1, "A"), gabarito(5, "B")]);
  assert.ok(bloqueios.some((b) => b.tipo === "gabarito_sem_questao" && b.numero === 5));
});

test("D) número de questão duplicado na extração gera bloqueio tipo 'numero_duplicado'", () => {
  const { bloqueios } = juntarQuestoesEGabarito([questao(1), questao(1)], [gabarito(1, "A")]);
  assert.ok(bloqueios.some((b) => b.tipo === "numero_duplicado" && b.numero === 1));
});

test("E) quantidade de questões incompatível com quantidade de gabaritos gera bloqueio", () => {
  const { bloqueios } = juntarQuestoesEGabarito([questao(1), questao(2), questao(3)], [gabarito(1, "A"), gabarito(2, "B")]);
  assert.ok(bloqueios.some((b) => b.tipo === "quantidade_incompativel"));
});

test("F) gabarito aponta para alternativa inexistente na questão (ex.: gabarito 'E' numa questão só A-D)", () => {
  const { juntadas } = juntarQuestoesEGabarito([questao(1, ["A", "B", "C", "D"])], [gabarito(1, "E")]);
  assert.ok(juntadas[0].motivos_juncao.includes("alternativa_correta_inexistente"));
});

test("G) questão anulada no gabarito nunca gera 'alternativa_correta_inexistente' (alternativa_correta é null por definição)", () => {
  const { juntadas } = juntarQuestoesEGabarito([questao(1)], [gabarito(1, null, { anulada: true, alternativa_correta: null })]);
  assert.deepEqual(juntadas[0].motivos_juncao, []);
});
