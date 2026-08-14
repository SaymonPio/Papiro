import test from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

const pagina = await readFile(new URL("../app/questoes/page.tsx", import.meta.url), "utf8");

test("a sessão não consulta nem exibe metadados internos da fonte da questão", () => {
  assert.doesNotMatch(pagina, /ano, fonte, materias/);
  assert.doesNotMatch(pagina, /questao\.fonte/);
  assert.doesNotMatch(pagina, /question-origin-detail/);
});

test("a identificação pedagógica pública permanece limitada a banca, concurso e ano", () => {
  assert.match(pagina, /const partes = \[banca, questao\.concurso\?\.trim\(\), questao\.ano/);
  assert.match(pagina, /return partes\.join\(" • "\)/);
});
