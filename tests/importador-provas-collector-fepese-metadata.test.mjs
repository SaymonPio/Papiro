import assert from "node:assert/strict";
import test from "node:test";
import { montarMetadataConcurso } from "../scripts/importador-provas/collectors/fepese/lib/metadata.mjs";

test("A) todos os campos obrigatórios presentes -> confidence alta, metadata completo", () => {
  const { metadata, confidence, camposFaltando } = montarMetadataConcurso({
    banca: "FEPESE",
    ano: 2014,
    orgao: "Prefeitura Municipal de Exemplo",
    cargo: "Guarda Municipal",
    nomeProva: "FEPESE - 2014 - Prefeitura Municipal de Exemplo - Guarda Municipal",
    fonteUrl: "https://exemplo.fepese.org.br/?go=download&arquivo=GM.pdf",
    fonteTipo: "oficial",
  });
  assert.equal(confidence, "alta");
  assert.deepEqual(camposFaltando, []);
  assert.equal(metadata.banca, "FEPESE");
  assert.equal(metadata.fonte_tipo, "oficial");
});

test("B) cargo não determinado com segurança -> confidence baixa, campo fica null (nunca inventado)", () => {
  const { metadata, confidence, camposFaltando } = montarMetadataConcurso({
    banca: "FEPESE",
    ano: 2014,
    orgao: "Prefeitura Municipal de Exemplo",
    cargo: null,
    fonteUrl: "https://exemplo.fepese.org.br/?go=download&arquivo=X.pdf",
  });
  assert.equal(confidence, "baixa");
  assert.ok(camposFaltando.includes("cargo"));
  assert.equal(metadata.cargo, null);
});

test("C) órgão ausente também reduz a confidence para baixa, mesmo com os outros campos presentes", () => {
  const { confidence, camposFaltando } = montarMetadataConcurso({
    banca: "FEPESE",
    ano: 2014,
    orgao: null,
    cargo: "Guarda Municipal",
    fonteUrl: "https://exemplo.fepese.org.br/?go=download&arquivo=X.pdf",
  });
  assert.equal(confidence, "baixa");
  assert.deepEqual(camposFaltando, ["orgao"]);
});

test("D) fonte_tipo default é 'oficial' quando não especificado explicitamente", () => {
  const { metadata } = montarMetadataConcurso({
    banca: "FEPESE", ano: 2014, orgao: "X", cargo: "Y", fonteUrl: "https://x",
  });
  assert.equal(metadata.fonte_tipo, "oficial");
});

test("E) string vazia conta como campo ausente, não como valor válido", () => {
  const { confidence, camposFaltando } = montarMetadataConcurso({
    banca: "FEPESE", ano: 2014, orgao: "", cargo: "Y", fonteUrl: "https://x",
  });
  assert.equal(confidence, "baixa");
  assert.ok(camposFaltando.includes("orgao"));
});
