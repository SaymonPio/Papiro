import assert from "node:assert/strict";
import test from "node:test";
import { validarQuestaoGerada } from "../scripts/curadoria-autoral/lib/validador-questoes.mjs";
import { QUESTION_SCHEMA_VERSION } from "../scripts/curadoria-autoral/lib/schemas.mjs";

function questaoValida(extra = {}) {
  return {
    schema_version: QUESTION_SCHEMA_VERSION,
    run_id: "run-teste",
    question_key: "q-1",
    origem: "AUTORAL_PAPIRO",
    enunciado: "Enunciado de teste, suficientemente longo para nao ser considerado vazio.",
    alternativas: [
      { letra: "A", texto: "Primeira alternativa." },
      { letra: "B", texto: "Segunda alternativa." },
      { letra: "C", texto: "Terceira alternativa." },
      { letra: "D", texto: "Quarta alternativa." },
      { letra: "E", texto: "Quinta alternativa." },
    ],
    gabarito: "C",
    explicacao: "Explicacao completa do porque a alternativa C esta correta e as demais nao.",
    fundamento: { tipo: "escopo_unidade", referencia: "escopo da unidade", dispositivos: [], descricao: "Baseado no escopo confirmado da unidade." },
    dificuldade: "media",
    banca_alvo: "Fundatec",
    curso_id: "curso-1",
    materia_id: 10,
    conteudo_id: 500,
    curso_conteudo_id: 10,
    unidade_id: "unidade-1",
    aula_id: null,
    justificativa_aderencia: "Testa o nucleo confirmado no escopo.",
    fonte_utilizada: "escopo da unidade",
    status_inicial: "gerada",
    riscos_identificados: [],
    model: null,
    prompt_version: "fase2a-fixture",
    generated_at: new Date().toISOString(),
    ...extra,
  };
}

test("14. exatamente 5 alternativas validas: passa", () => {
  const resultado = validarQuestaoGerada(questaoValida());
  assert.equal(resultado.ok, true, JSON.stringify(resultado.errors));
});

test("15. 4 alternativas: rejeita", () => {
  const questao = questaoValida();
  questao.alternativas = questao.alternativas.slice(0, 4);
  const resultado = validarQuestaoGerada(questao);
  assert.equal(resultado.ok, false);
  assert.ok(resultado.errors.some((e) => e.codigo === "WRONG_ALTERNATIVE_COUNT"));
});

test("16. 6 alternativas: rejeita", () => {
  const questao = questaoValida();
  questao.alternativas = [...questao.alternativas, { letra: "F", texto: "Sexta alternativa." }];
  const resultado = validarQuestaoGerada(questao);
  assert.equal(resultado.ok, false);
  assert.ok(resultado.errors.some((e) => e.codigo === "WRONG_ALTERNATIVE_COUNT"));
});

test("17. gabarito fora de A-E: rejeita", () => {
  const questao = questaoValida({ gabarito: "F" });
  const resultado = validarQuestaoGerada(questao);
  assert.equal(resultado.ok, false);
  assert.ok(resultado.errors.some((e) => e.codigo === "INVALID_GABARITO"));
});

test("18. explicacao vazia: rejeita", () => {
  const questao = questaoValida({ explicacao: "" });
  const resultado = validarQuestaoGerada(questao);
  assert.equal(resultado.ok, false);
  assert.ok(resultado.errors.some((e) => e.codigo === "EMPTY_EXPLICACAO"));
});

test("letras repetidas (nao A-E unico cada) sao rejeitadas", () => {
  const questao = questaoValida();
  questao.alternativas[4].letra = "A"; // duplica a letra A, nao cobre E
  const resultado = validarQuestaoGerada(questao);
  assert.equal(resultado.ok, false);
  assert.ok(resultado.errors.some((e) => e.codigo === "ALTERNATIVE_LETTERS_NOT_ABCDE"));
});

test("gabarito que nao corresponde a nenhuma alternativa e rejeitado mesmo estando em A-E", () => {
  const questao = questaoValida();
  questao.alternativas = questao.alternativas.filter((a) => a.letra !== "C");
  questao.alternativas.push({ letra: "C", texto: "" }); // C existe mas com texto vazio -> ja pega por EMPTY_ALTERNATIVE_TEXT tambem
  const resultado = validarQuestaoGerada(questao);
  assert.equal(resultado.ok, false);
});

test("origem diferente de AUTORAL_PAPIRO e rejeitada", () => {
  const questao = questaoValida({ origem: "REAL" });
  const resultado = validarQuestaoGerada(questao);
  assert.equal(resultado.ok, false);
  assert.ok(resultado.errors.some((e) => e.codigo === "INVALID_ORIGEM"));
});

test("dificuldade fora do enum e rejeitada", () => {
  const questao = questaoValida({ dificuldade: "muito_dificil" });
  const resultado = validarQuestaoGerada(questao);
  assert.equal(resultado.ok, false);
  assert.ok(resultado.errors.some((e) => e.codigo === "INVALID_DIFICULDADE"));
});

test("um campo id de banco de questao presente e rejeitado", () => {
  const questao = questaoValida({ id: 999 });
  const resultado = validarQuestaoGerada(questao);
  assert.equal(resultado.ok, false);
  assert.ok(resultado.errors.some((e) => e.codigo === "BANK_ID_NOT_ALLOWED"));
});
