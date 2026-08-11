import assert from "node:assert/strict";
import test from "node:test";
import { montarJanelaSemanal } from "../utils/cronograma.mjs";

const item = (materiaId, materiaNome, titulo, prioridade) => ({
  materiaId,
  materiaNome,
  titulo,
  prioridade,
  frequenciaHistorica: prioridade,
});

test("cobre todas as matérias relevantes da BM e preserva as maiores prioridades", () => {
  const legislacao = item(1, "Legislação Específica", "Estatuto da BM", 10);
  const portugues = item(2, "Língua Portuguesa", "Interpretação", 9);
  const direitosHumanos = item(3, "Direitos Humanos", "Dignidade humana", 8);
  const informatica = item(4, "Informática", "Segurança da informação", 6);
  const raciocinio = item(5, "Raciocínio Lógico", "Proposições", 6);
  const filaGlobal = [
    legislacao,
    portugues,
    direitosHumanos,
    legislacao,
    portugues,
    legislacao,
    direitosHumanos,
  ];

  const semana = montarJanelaSemanal(
    filaGlobal,
    [legislacao, portugues, direitosHumanos, informatica, raciocinio],
    100,
    7
  );
  const materias = semana.map((conteudo) => conteudo.materiaNome);

  for (const nome of [
    "Legislação Específica",
    "Língua Portuguesa",
    "Direitos Humanos",
    "Informática",
    "Raciocínio Lógico",
  ]) {
    assert.ok(materias.includes(nome), `${nome} deve aparecer nos próximos 7 dias`);
  }

  assert.equal(materias.filter((nome) => nome === "Legislação Específica").length, 2);
  assert.equal(materias.filter((nome) => nome === "Língua Portuguesa").length, 2);
});

test("limita a janela às sete matérias de maior prioridade quando há mais de sete", () => {
  const itens = Array.from({ length: 8 }, (_, indice) =>
    item(indice + 1, `Matéria ${indice + 1}`, `Conteúdo ${indice + 1}`, 10 - indice)
  );
  const semana = montarJanelaSemanal(itens, itens, 0, 7);

  assert.equal(semana.length, 7);
  assert.ok(!semana.some((conteudo) => conteudo.materiaNome === "Matéria 8"));
});
