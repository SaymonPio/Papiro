import assert from "node:assert/strict";
import test from "node:test";
import { agregarTokens } from "../supabase/functions/_shared/gerar-aula/tokens.mjs";

// Fase 4 — auditoria final: prova de que tokens da tentativa 1 nunca são
// perdidos/sobrescritos quando a tentativa 2 (correção automática) é
// avaliada — achado real: o `usage` da OpenAI descreve só a Response
// atual, não um total já acumulado.

test("A) primeira tentativa (nada gravado ainda) — total é só o valor atual", () => {
  assert.equal(agregarTokens(null, 1000), 1000);
  assert.equal(agregarTokens(undefined, 500), 500);
});

test("B) segunda tentativa — soma com o que já estava gravado, nunca sobrescreve", () => {
  assert.equal(agregarTokens(1000, 1200), 2200);
  assert.equal(agregarTokens(500, 600), 1100);
});

test("C) as duas pontas desconhecidas continuam null — nunca fabrica um 0 fictício", () => {
  assert.equal(agregarTokens(null, null), null);
  assert.equal(agregarTokens(undefined, undefined), null);
});

test("D) só uma ponta conhecida — usa essa ponta, a outra contribui 0", () => {
  assert.equal(agregarTokens(1000, null), 1000);
  assert.equal(agregarTokens(null, 700), 700);
});

test("E) idempotência não é esperada aqui de propósito — chamar duas vezes com o mesmo `atual` soma de novo (o chamador é responsável por chamar exatamente uma vez por resposta nova)", () => {
  const primeiraChamada = agregarTokens(0, 100);
  const segundaChamadaAcidental = agregarTokens(primeiraChamada, 100);
  assert.equal(segundaChamadaAcidental, 200, "documenta o comportamento: a função em si é uma soma pura, a garantia de 'uma vez por resposta' é do chamador (processarGeracao chama isto uma única vez por execução, sobre um usage novo)");
});
