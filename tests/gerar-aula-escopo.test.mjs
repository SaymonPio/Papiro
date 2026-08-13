import assert from "node:assert/strict";
import test from "node:test";
import { normalizarArtigoBase, auditarEscopoArtigos } from "../supabase/functions/gerar-aula/escopo.mjs";

// Nenhum destes testes chama a OpenAI ou o banco — validam só a lógica
// pura de normalização/auditoria de escopo (Fase 2J-B).

test('normalizarArtigoBase: "art. 19, § 5º" -> artigo base "19"', () => {
  assert.equal(normalizarArtigoBase("art. 19, § 5º"), "19");
});

test('normalizarArtigoBase: "Art. 19, § 5º" (maiúscula) -> "19"', () => {
  assert.equal(normalizarArtigoBase("Art. 19, § 5º"), "19");
});

test('normalizarArtigoBase: "art. 5º" -> "5"', () => {
  assert.equal(normalizarArtigoBase("art. 5º"), "5");
});

test('normalizarArtigoBase: "art. 22, III" -> "22"', () => {
  assert.equal(normalizarArtigoBase("art. 22, III"), "22");
});

test('normalizarArtigoBase: "art. 12-A" -> "12-A"', () => {
  assert.equal(normalizarArtigoBase("art. 12-A"), "12-A");
});

test('normalizarArtigoBase: "art. 12-C" -> normaliza "12-C"', () => {
  assert.equal(normalizarArtigoBase("art. 12-C"), "12-C");
});

test('normalizarArtigoBase: "12-B" sem prefixo "art." -> "12-B"', () => {
  assert.equal(normalizarArtigoBase("12-B"), "12-B");
});

test('normalizarArtigoBase: letra minúscula normaliza para maiúscula ("art. 12-c" -> "12-C")', () => {
  assert.equal(normalizarArtigoBase("art. 12-c"), "12-C");
});

test('normalizarArtigoBase: referência sem número reconhecível -> null', () => {
  assert.equal(normalizarArtigoBase("Lei 9.099/95"), null);
  assert.equal(normalizarArtigoBase("Convenção de Belém do Pará"), null);
});

test("normalizarArtigoBase: valor não-string -> null", () => {
  assert.equal(normalizarArtigoBase(null), null);
  assert.equal(normalizarArtigoBase(undefined), null);
  assert.equal(normalizarArtigoBase(19), null);
});

test("auditarEscopoArtigos: todos os artigos abordados dentro do esperado -> sem alerta", () => {
  const resultado = auditarEscopoArtigos(["art. 5º", "art. 7º"], ["art. 5º", "art. 6º", "art. 7º"]);
  assert.equal(resultado.executada, true);
  assert.equal(resultado.tem_alerta, false);
  assert.deepEqual(resultado.artigos_fora_do_escopo, []);
  assert.deepEqual(resultado.referencias_nao_normalizadas, []);
});

test("auditarEscopoArtigos: um artigo abordado fora do esperado -> alerta", () => {
  const resultado = auditarEscopoArtigos(["art. 5º", "art. 7º", "art. 19"], ["art. 5º", "art. 6º", "art. 7º"]);
  assert.equal(resultado.executada, true);
  assert.equal(resultado.tem_alerta, true);
  assert.deepEqual(resultado.artigos_fora_do_escopo, ["art. 19"]);
});

test("auditarEscopoArtigos: artigos_esperados null -> executada=false, nada mais calculado", () => {
  const resultado = auditarEscopoArtigos(["art. 5º"], null);
  assert.deepEqual(resultado, { executada: false });
});

test("auditarEscopoArtigos: artigos_esperados undefined -> executada=false", () => {
  const resultado = auditarEscopoArtigos(["art. 5º"], undefined);
  assert.deepEqual(resultado, { executada: false });
});

test("auditarEscopoArtigos: artigos_esperados [] (vazio, não null) -> executada=true, qualquer citação vira alerta", () => {
  const resultado = auditarEscopoArtigos(["art. 5º"], []);
  assert.equal(resultado.executada, true);
  assert.equal(resultado.tem_alerta, true);
  assert.deepEqual(resultado.artigos_fora_do_escopo, ["art. 5º"]);
});

test("auditarEscopoArtigos: nenhum artigo abordado -> sem alerta", () => {
  const resultado = auditarEscopoArtigos([], ["art. 5º", "art. 7º"]);
  assert.equal(resultado.executada, true);
  assert.equal(resultado.tem_alerta, false);
  assert.deepEqual(resultado.artigos_fora_do_escopo, []);
});

test("auditarEscopoArtigos: referência não reconhecida não bloqueia e entra em referencias_nao_normalizadas", () => {
  const resultado = auditarEscopoArtigos(["art. 5º", "Lei 9.099/95"], ["art. 5º"]);
  assert.equal(resultado.executada, true);
  assert.equal(resultado.tem_alerta, false);
  assert.deepEqual(resultado.artigos_fora_do_escopo, []);
  assert.deepEqual(resultado.referencias_nao_normalizadas, ["Lei 9.099/95"]);
});

test("auditarEscopoArtigos: artigos_abordados 12-A e 12-C são tratados como artigos distintos", () => {
  const resultado = auditarEscopoArtigos(["art. 12-A", "art. 12-C"], ["art. 12-A", "art. 12-B"]);
  assert.equal(resultado.tem_alerta, true);
  assert.deepEqual(resultado.artigos_fora_do_escopo, ["art. 12-C"]);
});
