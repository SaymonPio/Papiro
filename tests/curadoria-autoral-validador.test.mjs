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

// Reparo Lote 07 (mandato "REPAIR PASS SEM NOVA API", Secao 8) — os 6 casos
// deterministicos exigidos pelo mandato para o novo guard
// MISSING_NORMATIVE_DEVICE, acionado apenas via
// contexto.requiresNormativeDeviceReference (nunca por heuristica de
// materia_id/nome).

test("CASO 1 — legislativa com diploma + artigo identificaveis: PASS", () => {
  const questao = questaoValida({
    fundamento: { tipo: "dispositivo_normativo", referencia: "Lei Complementar nº 10.990/1997, art. 12", descricao: "Hierarquia e disciplina como base institucional." },
  });
  const resultado = validarQuestaoGerada(questao, { requiresNormativeDeviceReference: true });
  assert.equal(resultado.ok, true, JSON.stringify(resultado.errors));
});

test("CASO 2 — legislativa citando so o nome da lei, sem artigo: BLOCK", () => {
  const questao = questaoValida({
    fundamento: { tipo: "dispositivo_normativo", referencia: "Estatuto dos Militares Estaduais", descricao: "Trata da hierarquia." },
  });
  const resultado = validarQuestaoGerada(questao, { requiresNormativeDeviceReference: true });
  assert.equal(resultado.ok, false);
  assert.ok(resultado.errors.some((e) => e.codigo === "MISSING_NORMATIVE_DEVICE"));
});

test("CASO 3 — fundamento generico (gramatical/semantico): BLOCK", () => {
  const questao = questaoValida({
    fundamento: { tipo: "regra_gramatical", referencia: "Interpretação textual e semântica", descricao: "A correção decorre da compatibilidade semântica." },
  });
  const resultado = validarQuestaoGerada(questao, { requiresNormativeDeviceReference: true });
  assert.equal(resultado.ok, false);
  assert.ok(resultado.errors.some((e) => e.codigo === "MISSING_NORMATIVE_DEVICE"));
});

test("CASO 4 — materia nao normativa (Portugues) com fundamento gramatical, sem exigencia do contexto: PASS", () => {
  const questao = questaoValida({
    fundamento: { tipo: "regra_gramatical", referencia: "Regência verbal", descricao: "O verbo exige preposição." },
  });
  const resultado = validarQuestaoGerada(questao, { requiresNormativeDeviceReference: false });
  assert.equal(resultado.ok, true, JSON.stringify(resultado.errors));
});

test("CASO 5 — legislativa com artigo mas sem diploma identificavel: BLOCK", () => {
  const questao = questaoValida({
    fundamento: { tipo: "dispositivo_normativo", referencia: "art. 12", descricao: "Hierarquia e disciplina." },
  });
  const resultado = validarQuestaoGerada(questao, { requiresNormativeDeviceReference: true });
  assert.equal(resultado.ok, false);
  assert.ok(resultado.errors.some((e) => e.codigo === "MISSING_NORMATIVE_DEVICE"));
});

test("CASO 6 — legislativa com diploma mas sem artigo identificavel: BLOCK", () => {
  const questao = questaoValida({
    fundamento: { tipo: "dispositivo_normativo", referencia: "Lei Complementar nº 10.990/1997", descricao: "Estatuto dos Militares Estaduais em geral." },
  });
  const resultado = validarQuestaoGerada(questao, { requiresNormativeDeviceReference: true });
  assert.equal(resultado.ok, false);
  assert.ok(resultado.errors.some((e) => e.codigo === "MISSING_NORMATIVE_DEVICE"));
});

test("contexto omitido (chamada antiga) preserva comportamento: fundamento generico ainda passa", () => {
  const questao = questaoValida({
    fundamento: { tipo: "regra_gramatical", referencia: "Interpretação textual e semântica", descricao: "..." },
  });
  const resultado = validarQuestaoGerada(questao);
  assert.equal(resultado.ok, true, JSON.stringify(resultado.errors));
});

// Reparo Lote 09B (mandato "EXTENSAO CONTROLADA DO CONTRATO DE
// FUNDAMENTO", Secoes 9-11): os 2 novos tipos de fundamento tem checagem
// PROPRIA, dispensada de diploma+artigo (MISSING_NORMATIVE_DEVICE nao deve
// disparar para eles).

test("CASO JURISPRUDENCIAL 1 — tribunal + precedente identificaveis: PASS", () => {
  const questao = questaoValida({
    fundamento: { tipo: "regra_jurisprudencial", referencia: "STF, Tribunal Pleno, ADPF 635/RJ, Rel. Min. Edson Fachin, julgamento em 03/04/2025", descricao: "Homologação parcial do plano de redução da letalidade policial." },
  });
  const resultado = validarQuestaoGerada(questao, { requiresNormativeDeviceReference: true });
  assert.equal(resultado.ok, true, JSON.stringify(resultado.errors));
});

test("CASO JURISPRUDENCIAL 2 — referencia sem tribunal/identificador reconhecivel: BLOCK", () => {
  const questao = questaoValida({
    fundamento: { tipo: "regra_jurisprudencial", referencia: "Entendimento consolidado dos tribunais superiores", descricao: "..." },
  });
  const resultado = validarQuestaoGerada(questao, { requiresNormativeDeviceReference: true });
  assert.equal(resultado.ok, false);
  assert.ok(resultado.errors.some((e) => e.codigo === "MISSING_JURISPRUDENTIAL_REFERENCE"));
  assert.equal(resultado.errors.some((e) => e.codigo === "MISSING_NORMATIVE_DEVICE"), false, "fundamento jurisprudencial nao deve ser cobrado por diploma+artigo");
});

test("CASO OFFICIAL_PEDAGOGICAL 1 — instituicao + documento identificaveis: PASS", () => {
  const questao = questaoValida({
    fundamento: { tipo: "fonte_pedagogica_oficial", referencia: "ENAP, Poderes da Administração e dos Administradores, módulo 3", descricao: "Definição de poder hierárquico conforme material didático institucional." },
  });
  const resultado = validarQuestaoGerada(questao, { requiresNormativeDeviceReference: true });
  assert.equal(resultado.ok, true, JSON.stringify(resultado.errors));
});

test("CASO OFFICIAL_PEDAGOGICAL 2 — referencia vaga demais (sem segmentos rastreaveis): BLOCK", () => {
  const questao = questaoValida({
    fundamento: { tipo: "fonte_pedagogica_oficial", referencia: "doutrina administrativa", descricao: "..." },
  });
  const resultado = validarQuestaoGerada(questao, { requiresNormativeDeviceReference: true });
  assert.equal(resultado.ok, false);
  assert.ok(resultado.errors.some((e) => e.codigo === "MISSING_OFFICIAL_PEDAGOGICAL_REFERENCE"));
  assert.equal(resultado.errors.some((e) => e.codigo === "MISSING_NORMATIVE_DEVICE"), false, "fundamento pedagogico-oficial nao deve ser cobrado por diploma+artigo");
});

test("CASO CTN — TECH_DEBT_NORMATIVE_REFERENCE_CODE_NAME_REGEX resolvido genericamente: 'Código X, art. N' agora e reconhecido como normativo", () => {
  const questao = questaoValida({
    fundamento: { tipo: "dispositivo_normativo", referencia: "Código Tributário Nacional, art. 78, caput.", descricao: "Conceito legal de poder de polícia." },
  });
  const resultado = validarQuestaoGerada(questao, { requiresNormativeDeviceReference: true });
  assert.equal(resultado.ok, true, JSON.stringify(resultado.errors));
});

test("CASO CF POR EXTENSO — achado Lote09B (geração real): 'Constituição da República Federativa do Brasil de 1988, art. N' e reconhecido como normativo", () => {
  const questao = questaoValida({
    fundamento: {
      tipo: "regra_normativa",
      referencia: "Constituição da República Federativa do Brasil de 1988, art. 84, IV, primeira parte.",
      descricao: "Competência privativa do Presidente da República para sancionar, promulgar e fazer publicar as leis.",
    },
  });
  const resultado = validarQuestaoGerada(questao, { requiresNormativeDeviceReference: true });
  assert.equal(resultado.ok, true, JSON.stringify(resultado.errors));
});
