import assert from "node:assert/strict";
import test from "node:test";
import { classificarOrigemQuestao, inicioEnunciado } from "../app/admin/aulas/banco-unidade.ts";

// O projeto não tem infraestrutura de teste de React hoje (só node --test
// puro, ver tests/rendered-html.test.mjs) — por isso o painel "BANCO DA
// UNIDADE" (app/admin/aulas/page.tsx) teve sua lógica de classificação
// extraída para app/admin/aulas/banco-unidade.ts, testável aqui sem
// framework novo. O comportamento de efeito/chamada de RPC/estado React
// (seleção de unidade, guarda de corrida, estados de carregamento) foi
// validado por leitura de código + typecheck/lint, não por teste
// automatizado de componente.

test("classifica REAL para banca de banca real preenchida", () => {
  assert.equal(classificarOrigemQuestao("Fundatec"), "REAL");
  assert.equal(classificarOrigemQuestao("FGV"), "REAL");
});

test("classifica AUTORAL quando banca é null, undefined ou vazia", () => {
  assert.equal(classificarOrigemQuestao(null), "AUTORAL");
  assert.equal(classificarOrigemQuestao(undefined), "AUTORAL");
  assert.equal(classificarOrigemQuestao(""), "AUTORAL");
  assert.equal(classificarOrigemQuestao("   "), "AUTORAL");
});

test("classifica AUTORAL quando banca começa com \"papiro\" (case-insensitive, com variações)", () => {
  assert.equal(classificarOrigemQuestao("Papiro"), "AUTORAL");
  assert.equal(classificarOrigemQuestao("PAPIRO"), "AUTORAL");
  assert.equal(classificarOrigemQuestao("papiro - estilo Fundatec"), "AUTORAL");
  assert.equal(classificarOrigemQuestao("Papiro - Teste"), "AUTORAL");
});

test("classificação da unidade Lei de Tortura bate com o estado LIVE auditado (4 REAL, 6 AUTORAL)", () => {
  const bancasLiveLeiDeTortura = [
    "Fundatec", "Fundatec", "Papiro", "Fundatec", "Fundatec",
    "Papiro", "Papiro", "Papiro", "Papiro", "Papiro",
  ];
  const classificadas = bancasLiveLeiDeTortura.map(classificarOrigemQuestao);
  const real = classificadas.filter((c) => c === "REAL").length;
  const autoral = classificadas.filter((c) => c === "AUTORAL").length;
  assert.equal(real, 4);
  assert.equal(autoral, 6);
  assert.equal(real + autoral, 10);
});

test("inicioEnunciado mantém enunciados curtos intactos", () => {
  const curto = "Nos termos da Lei nº 9.455/1997, o crime de tortura é considerado:";
  assert.equal(inicioEnunciado(curto), curto);
});

test("inicioEnunciado trunca enunciados longos e adiciona reticências", () => {
  const longo = "a".repeat(200);
  const resultado = inicioEnunciado(longo, 110);
  assert.equal(resultado.length, 111); // 110 caracteres + "…"
  assert.ok(resultado.endsWith("…"));
});

test("inicioEnunciado remove espaços nas pontas antes de decidir truncar", () => {
  const comEspacos = `   ${"b".repeat(50)}   `;
  assert.equal(inicioEnunciado(comEspacos, 110), "b".repeat(50));
});
