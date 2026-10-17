import assert from "node:assert/strict";
import test from "node:test";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import path from "node:path";
import { buscarConcursos } from "../scripts/importador-provas/collectors/fepese/index.mjs";

// PAPIRO — Coletor FEPESE: camada de DESCOBERTA. buscarConcursos() é
// 100% local (lê indice-concursos.json, nunca toca rede) — modelo
// híbrido explícito porque a listagem oficial da FEPESE não é crawlable
// de forma estável (confirmado no raio-x das bancas). Estes testes
// operam sobre o índice REAL do coletor (não um mock), então servem
// também como guarda de regressão do conteúdo desse arquivo.

const raizProjeto = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const indice = JSON.parse(
  readFileSync(path.join(raizProjeto, "scripts/importador-provas/collectors/fepese/indice-concursos.json"), "utf8"),
);

test("A) índice de descoberta tem pelo menos 1 concurso marcado como verificado (confirmado por fetch real, não só WebSearch)", () => {
  assert.ok(indice.some((c) => c.verificado === true));
});

test("B) todo concurso do índice tem slug, url e ano — nenhum campo essencial de descoberta ausente", () => {
  for (const concurso of indice) {
    assert.ok(concurso.slug, `concurso sem slug: ${JSON.stringify(concurso)}`);
    assert.ok(concurso.url?.startsWith("https://"), `concurso sem URL https: ${concurso.slug}`);
    assert.equal(typeof concurso.ano, "number");
  }
});

test("C) palavraChave padrão (sem informar nenhuma) encontra o concurso real de Guarda Municipal verificado", () => {
  const resultado = buscarConcursos({});
  assert.ok(resultado.some((c) => c.slug === "guardabc"));
});

test("D) palavraChave customizada filtra só concursos cujo texto bate com a palavra", () => {
  const resultado = buscarConcursos({ palavraChave: "perito" });
  assert.ok(resultado.length > 0);
  assert.ok(resultado.every((c) => /perito/i.test(`${c.orgao} ${c.titulo} ${(c.cargosConhecidos ?? []).join(" ")}`)));
});

test("E) palavraChave sem nenhuma correspondência devolve lista vazia, nunca inventa concurso", () => {
  const resultado = buscarConcursos({ palavraChave: "palavra-que-nao-existe-em-nenhum-concurso-xyz" });
  assert.deepEqual(resultado, []);
});

test("F) anoMin/anoMax filtram corretamente, combinados com palavraChave", () => {
  const resultado = buscarConcursos({ anoMin: 2020, anoMax: 2030 });
  assert.ok(resultado.every((c) => c.ano >= 2020 && c.ano <= 2030));
  assert.ok(!resultado.some((c) => c.slug === "guardabc")); // guardabc é 2014, fora da faixa
});

test("G) nenhum concurso do índice aponta para domínio fora de fepese.org.br (nunca QConcursos/agregador como fonte)", () => {
  for (const concurso of indice) {
    assert.match(concurso.url, /\.fepese\.org\.br\//);
  }
});
