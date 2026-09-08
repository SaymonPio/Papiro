import assert from "node:assert/strict";
import test from "node:test";
import {
  calcularCoberturaUnidade,
  calcularDeficit,
  distintasUteisCurso,
  escanearCursoCompleto,
  questoesUteisDaUnidade,
} from "../scripts/curadoria-autoral/lib/coverage-scanner.mjs";
import { STATUS_CURSO_SEM_ANDAIME } from "../scripts/curadoria-autoral/lib/schemas.mjs";

// Fixture minima e autoconsistente — nenhum id/numero real do banco. Uma
// unidade com N questoes uteis fictícias, criadas via helper para os
// testes nao repetirem a mesma estrutura 20 vezes.
function questaoFicticia(id, { ativa = true, banca = "Fundatec", geradaPorIa = false } = {}) {
  return { id, ativa, banca, gerada_por_ia: geradaPorIa };
}

function dadosBrutosFixture(overrides = {}) {
  return {
    cursos: [{ id: "curso-1", slug: "curso-teste", banca: "Fundatec", edital_id: null }],
    cursoMaterias: [{ id: 1, curso_id: "curso-1", nome: "Materia X", materia_id: 100, relevante_para_preparacao: true }],
    cursoConteudos: [{ id: 10, curso_materia_id: 1, assunto_id: 500, relevante_para_preparacao: true }],
    unidadesPedagogicas: [
      { id: "unidade-1", curso_conteudo_id: 10, titulo: "Unidade 1", escopo: "Escopo textual simples, sem citacao normativa.", artigos_esperados: null, ativa: true },
    ],
    aulas: [],
    aulaVersoes: [],
    aulaVersaoFontes: [],
    teoriaEscoposConteudo: [],
    cursoEvidencias: [],
    questoes: [],
    questaoUnidadesPedagogicas: [],
    cursoQuestoes: [],
    editais: [],
    materias: [{ id: 100, nome: "Materia X" }],
    ...overrides,
  };
}

function comOitoUteis() {
  const questoes = Array.from({ length: 8 }, (_, i) => questaoFicticia(i + 1));
  return dadosBrutosFixture({
    questoes,
    questaoUnidadesPedagogicas: questoes.map((q) => ({ questao_id: q.id, unidade_pedagogica_id: "unidade-1" })),
    cursoQuestoes: questoes.map((q) => ({ curso_id: "curso-1", questao_id: q.id })),
  });
}

test("1. curso com 0 unidades: deficit_total=0 e BLOCKED_NO_PEDAGOGICAL_SCAFFOLD", () => {
  const dados = dadosBrutosFixture({ cursoConteudos: [], unidadesPedagogicas: [] });
  const resultado = escanearCursoCompleto(dados, { cursoId: "curso-1", targetBankSize: 10 });
  assert.equal(resultado.status, STATUS_CURSO_SEM_ANDAIME);
  assert.equal(resultado.deficit_total, 0);
  assert.deepEqual(resultado.unidades, []);
});

test("2. unidade com 8 uteis e target 10: faltantes=2", () => {
  const dados = comOitoUteis();
  const cobertura = calcularCoberturaUnidade(dados, { unidadeId: "unidade-1", cursoId: "curso-1", targetBankSize: 10, bancaCurso: "Fundatec" });
  assert.equal(cobertura.questoes_uteis, 8);
  assert.equal(cobertura.faltantes, 2);
});

test("3. target_bank_size e configuravel", () => {
  assert.equal(calcularDeficit(8, 8), 0);
  assert.equal(calcularDeficit(8, 12), 4);
  assert.equal(calcularDeficit(8, 10), 2);
});

test("4. multiunidade nao duplica COUNT DISTINCT no agregado do curso", () => {
  const dados = comOitoUteis();
  dados.unidadesPedagogicas.push({ id: "unidade-2", curso_conteudo_id: 10, titulo: "Unidade 2", escopo: "Outro escopo.", artigos_esperados: null, ativa: true });
  // questao 1 tambem vinculada a unidade-2 (multiunidade legitima)
  dados.questaoUnidadesPedagogicas.push({ questao_id: 1, unidade_pedagogica_id: "unidade-2" });

  const uteisUnidade1 = questoesUteisDaUnidade(dados, "unidade-1", "curso-1");
  const uteisUnidade2 = questoesUteisDaUnidade(dados, "unidade-2", "curso-1");
  assert.equal(uteisUnidade1.size, 8);
  assert.equal(uteisUnidade2.size, 1);

  const distintasNoCurso = distintasUteisCurso(dados, "curso-1", ["unidade-1", "unidade-2"]);
  assert.equal(distintasNoCurso.size, 8, "questao 1 esta em 2 unidades, mas conta 1 vez no total do curso");
});

test("5. questao inativa nao conta como util", () => {
  const dados = comOitoUteis();
  dados.questoes[0].ativa = false;
  const uteis = questoesUteisDaUnidade(dados, "unidade-1", "curso-1");
  assert.equal(uteis.size, 7);
  assert.equal(uteis.has(1), false);
});

test("6. sem curso_questoes nao conta como util", () => {
  const dados = comOitoUteis();
  dados.cursoQuestoes = dados.cursoQuestoes.filter((cq) => cq.questao_id !== 2);
  const uteis = questoesUteisDaUnidade(dados, "unidade-1", "curso-1");
  assert.equal(uteis.size, 7);
  assert.equal(uteis.has(2), false);
});

test("7. conteudo irrelevante nao conta", () => {
  const dados = comOitoUteis();
  dados.cursoConteudos[0].relevante_para_preparacao = false;
  const uteis = questoesUteisDaUnidade(dados, "unidade-1", "curso-1");
  assert.equal(uteis.size, 0);
});

test("8. materia irrelevante nao conta", () => {
  const dados = comOitoUteis();
  dados.cursoMaterias[0].relevante_para_preparacao = false;
  const uteis = questoesUteisDaUnidade(dados, "unidade-1", "curso-1");
  assert.equal(uteis.size, 0);
});

test("unidade inativa tambem nao conta (defensivo, alem dos 20 casos pedidos)", () => {
  const dados = comOitoUteis();
  dados.unidadesPedagogicas[0].ativa = false;
  const uteis = questoesUteisDaUnidade(dados, "unidade-1", "curso-1");
  assert.equal(uteis.size, 0);
});
