import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import { calcularHashArquivo, montarProveniencia } from "../scripts/importador-provas/lib/proveniencia.mjs";

// PAPIRO — importador de provas: proveniência do documento no formato de
// public.provas. Fixture 100% sintética.

const HASH_A = "a".repeat(64);
const HASH_B = "b".repeat(64);

function metadataBase(overrides = {}) {
  return {
    banca: "FEPESE",
    ano: 2014,
    orgao: "Prefeitura Municipal de Balneário Camboriú",
    cargo: "Guarda Municipal",
    nome_prova: "Prefeitura Municipal de Balneário Camboriú - 2014 - Guarda Municipal",
    fonte_url: "https://exemplo.org/prova.pdf",
    gabarito_url: "https://exemplo.org/gabarito.pdf",
    ...overrides,
  };
}

test("A) metadata completo + hashes válidos -> completa, no formato de public.provas", () => {
  const { prova, completa, faltando, invalidos } = montarProveniencia(metadataBase(), { hashProva: HASH_A, hashGabarito: HASH_B });
  assert.equal(completa, true);
  assert.deepEqual(faltando, []);
  assert.deepEqual(invalidos, []);
  assert.deepEqual(Object.keys(prova), ["banca", "orgao", "cargo", "ano", "nome", "fonte_url", "gabarito_url", "hash_prova", "hash_gabarito"]);
  assert.equal(prova.nome, "Prefeitura Municipal de Balneário Camboriú - 2014 - Guarda Municipal");
});

test("B) cada campo obrigatório ausente ou em branco é reportado e torna a proveniência incompleta", () => {
  for (const campo of ["banca", "orgao", "cargo", "nome_prova", "fonte_url"]) {
    const { completa, faltando } = montarProveniencia(metadataBase({ [campo]: "  " }), { hashProva: HASH_A, hashGabarito: HASH_B });
    assert.equal(completa, false, campo);
    assert.ok(faltando.includes(campo === "nome_prova" ? "nome" : campo), campo);
  }
  const semAno = montarProveniencia(metadataBase({ ano: null }), { hashProva: HASH_A, hashGabarito: HASH_B });
  assert.ok(semAno.faltando.includes("ano"));
});

test("C) hash ausente ou fora do formato SHA-256 hex nunca é aceito", () => {
  assert.ok(montarProveniencia(metadataBase(), { hashProva: HASH_A }).faltando.includes("hash_gabarito"));
  const invalido = montarProveniencia(metadataBase(), { hashProva: "ABC", hashGabarito: HASH_B });
  assert.equal(invalido.completa, false);
  assert.ok(invalido.invalidos.includes("hash_prova"));
});

test("D) gabarito_url é opcional (gabarito .txt local), mas se vier precisa ser http(s)", () => {
  assert.equal(montarProveniencia(metadataBase({ gabarito_url: null }), { hashProva: HASH_A, hashGabarito: HASH_B }).completa, true);
  const ruim = montarProveniencia(metadataBase({ gabarito_url: "arquivo.pdf" }), { hashProva: HASH_A, hashGabarito: HASH_B });
  assert.equal(ruim.completa, false);
  assert.ok(ruim.invalidos.includes("gabarito_url"));
});

test("E) ano fora de 1900..2200 é tratado como ausente (mesmo limite do CHECK do banco)", () => {
  assert.ok(montarProveniencia(metadataBase({ ano: 1800 }), { hashProva: HASH_A, hashGabarito: HASH_B }).faltando.includes("ano"));
});

test("F) calcularHashArquivo devolve o SHA-256 hex do conteúdo do arquivo", () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "papiro-proveniencia-"));
  const arquivo = path.join(dir, "x.txt");
  fs.writeFileSync(arquivo, "abc");
  assert.equal(calcularHashArquivo(arquivo), "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad");
  fs.rmSync(dir, { recursive: true });
});

test("PARTE) parte da prova na proveniência: válida entra; código/ordem inválidos ou ausentes deixam a proveniência incompleta; sem parte nada muda", () => {
  const meta = { banca: "B", orgao: "O", cargo: "C", ano: 2025, nome_prova: "N", fonte_url: "https://x.org/p.pdf", gabarito_url: "https://x.org/g.pdf" };
  const hashes = { hashProva: "a".repeat(64), hashGabarito: "b".repeat(64) };
  assert.equal("parte" in montarProveniencia(meta, hashes), false);
  const ok = montarProveniencia(meta, { ...hashes, parte: { codigo: "P2", nome: "Parte 2", ordem: 2 } });
  assert.deepEqual(ok.parte, { codigo: "P2", nome: "Parte 2", ordem: 2 });
  assert.equal(ok.completa, true);
  const ruim = montarProveniencia(meta, { ...hashes, parte: { codigo: "p 2", nome: "", ordem: 30 } });
  assert.equal(ruim.completa, false);
  assert.deepEqual([...ruim.faltando, ...ruim.invalidos].sort(), ["parte.codigo", "parte.nome", "parte.ordem"]);
});
