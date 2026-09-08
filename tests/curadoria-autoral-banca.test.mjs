import assert from "node:assert/strict";
import test from "node:test";
import { resolverBanca } from "../scripts/curadoria-autoral/lib/banca-resolver.mjs";
import { STATUS_BANCA } from "../scripts/curadoria-autoral/lib/schemas.mjs";

test("9. banca do curso resolvida (cursos.banca presente, sem edital)", () => {
  const resultado = resolverBanca({ cursoBanca: "Fundatec", editalBanca: null });
  assert.equal(resultado.status, STATUS_BANCA.RESOLVED);
  assert.equal(resultado.banca_resolvida, "Fundatec");
  assert.equal(resultado.origem_da_resolucao, "cursos.banca");
});

test("9b. banca do curso resolvida e confirmada por edital com nome mais longo (caso real: Fundatec vs FUNDATEC - Fundacao...)", () => {
  const resultado = resolverBanca({
    cursoBanca: "Fundatec",
    editalBanca: "FUNDATEC – Fundação Universidade Empresa de Tecnologia e Ciências",
  });
  assert.equal(resultado.status, STATUS_BANCA.RESOLVED);
  assert.equal(resultado.banca_resolvida, "Fundatec");
});

test("10. banca null (curso e edital ausentes): BLOCKED_NO_BANK", () => {
  const resultado = resolverBanca({ cursoBanca: null, editalBanca: null });
  assert.equal(resultado.status, STATUS_BANCA.BLOCKED_NO_BANK);
  assert.equal(resultado.banca_resolvida, null);
});

test("10b. banca null no curso, mas edital tem banca: REVIEW_FALLBACK (nunca promovido a RESOLVED sozinho)", () => {
  const resultado = resolverBanca({ cursoBanca: null, editalBanca: "FGV" });
  assert.equal(resultado.status, STATUS_BANCA.REVIEW_FALLBACK);
  assert.equal(resultado.banca_resolvida, "FGV");
});

test("11. conflito curso.banca x edital.banca: REVIEW_CONFLICT", () => {
  const resultado = resolverBanca({ cursoBanca: "Fundatec", editalBanca: "FGV" });
  assert.equal(resultado.status, STATUS_BANCA.REVIEW_CONFLICT);
  assert.equal(resultado.banca_resolvida, null, "em conflito, nao escolhe um lado silenciosamente");
});

test("override manual sempre vence e registra origem MANUAL_OVERRIDE", () => {
  const resultado = resolverBanca({ cursoBanca: "Fundatec", editalBanca: "FGV", override: "Cebraspe" });
  assert.equal(resultado.status, STATUS_BANCA.RESOLVED);
  assert.equal(resultado.banca_resolvida, "Cebraspe");
  assert.equal(resultado.origem_da_resolucao, "MANUAL_OVERRIDE");
});

test("nunca hardcoda Fundatec como fallback — banca vazia sem override continua BLOCKED_NO_BANK", () => {
  const resultado = resolverBanca({});
  assert.equal(resultado.status, STATUS_BANCA.BLOCKED_NO_BANK);
});
