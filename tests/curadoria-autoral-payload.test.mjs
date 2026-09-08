import assert from "node:assert/strict";
import test from "node:test";
import { resolverUnidadeNoCurso } from "../scripts/curadoria-autoral/lib/context-resolver.mjs";
import { avaliarElegibilidade } from "../scripts/curadoria-autoral/lib/eligibility.mjs";
import { construirPayload } from "../scripts/curadoria-autoral/lib/payload-builder.mjs";
import { STATUS_BANCA, STATUS_CONTEXTO_PEDAGOGICO, STATUS_ELEGIBILIDADE, STATUS_VALIDACAO_FONTE } from "../scripts/curadoria-autoral/lib/schemas.mjs";

function dadosBrutosDoisCursos() {
  return {
    cursoConteudos: [
      { id: 10, curso_materia_id: 1, assunto_id: 500, relevante_para_preparacao: true },
    ],
    cursoMaterias: [
      { id: 1, curso_id: "curso-A", nome: "Materia X" },
    ],
    unidadesPedagogicas: [
      { id: "unidade-1", curso_conteudo_id: 10, titulo: "Unidade 1", escopo: "Escopo.", artigos_esperados: null, ativa: true },
    ],
  };
}

test("12. payload nao aceita unidade de outro curso — resolverUnidadeNoCurso ABORTA", () => {
  const dados = dadosBrutosDoisCursos();
  const resolvidoCertoO = resolverUnidadeNoCurso(dados, { unidadeId: "unidade-1", cursoId: "curso-A" });
  assert.equal(resolvidoCertoO.ok, true);

  const resolvidoErrado = resolverUnidadeNoCurso(dados, { unidadeId: "unidade-1", cursoId: "curso-B" });
  assert.equal(resolvidoErrado.ok, false);
  assert.match(resolvidoErrado.motivo, /pertence ao curso curso-A, nao a curso-B/);
});

test("13. payload quantity > faltantes bloqueia com QUANTITY_EXCEEDS_DEFICIT", () => {
  const resultado = avaliarElegibilidade({
    unidadeAtiva: true,
    faltantes: 2,
    quantidadeSolicitada: 5,
    pedagogicalContextStatus: STATUS_CONTEXTO_PEDAGOGICO.PEDAGOGICAL_CONTEXT_COMPLETE,
    sourceValidationStatus: STATUS_VALIDACAO_FONTE.SOURCE_VALIDATED,
    requerFonteValidada: true,
    bancaStatus: STATUS_BANCA.RESOLVED,
    aulaExiste: true,
    aulaPublicada: true,
  });
  assert.equal(resultado.status, STATUS_ELEGIBILIDADE.BLOCKED);
  assert.ok(resultado.blocking_reasons.includes("QUANTITY_EXCEEDS_DEFICIT"));
});

test("13b. quantity <= faltantes nao bloqueia por quantidade", () => {
  const resultado = avaliarElegibilidade({
    unidadeAtiva: true,
    faltantes: 5,
    quantidadeSolicitada: 3,
    pedagogicalContextStatus: STATUS_CONTEXTO_PEDAGOGICO.PEDAGOGICAL_CONTEXT_COMPLETE,
    sourceValidationStatus: STATUS_VALIDACAO_FONTE.SOURCE_VALIDATED,
    requerFonteValidada: true,
    bancaStatus: STATUS_BANCA.RESOLVED,
    aulaExiste: true,
    aulaPublicada: true,
  });
  assert.equal(resultado.status, STATUS_ELEGIBILIDADE.ELIGIBLE_FOR_GENERATION);
});

function payloadBase(referenciasReal) {
  return construirPayload({
    runId: "run-teste",
    curso: { id: "curso-A", slug: "curso-teste", concurso: "Concurso Teste" },
    banca: { banca_resolvida: "Fundatec", status: STATUS_BANCA.RESOLVED, origem_da_resolucao: "cursos.banca" },
    materia: { id: 10, nome: "Materia X" },
    conteudo: { curso_conteudo_id: 10, assunto_id: 500, nome: "Conteudo X", escopo: "Escopo do conteudo." },
    unidade: { id: "unidade-1", titulo: "Unidade 1", escopo: "Escopo da unidade.", artigos_esperados: ["art. 5"] },
    licao: { id: null, exists: false, published: false, version_id: null },
    cobertura: { uteis_atual: 8, real_atual: 5, autoral_atual: 3, gerada_por_ia_atual: 0, target_bank_size: 10, faltantes: 2 },
    geracao: { quantidade: 2, origem: "AUTORAL_PAPIRO", dificuldades: ["media", "dificil"] },
    referenciasReal,
    cursoEvidenciaIds: [],
    contextoPedagogico: { status: STATUS_CONTEXTO_PEDAGOGICO.PEDAGOGICAL_CONTEXT_COMPLETE, reason: "artigos_esperados presentes", escopo_efetivo: "Escopo da unidade.", artigos_esperados_efetivos: ["art. 5"] },
    validacaoFonte: { status: STATUS_VALIDACAO_FONTE.SOURCE_VALIDATED, reason: "fonte validada cobre o escopo esperado", validated_sources: ["fonte-teste"] },
    requerFonteValidada: true,
    constraints: { requisitos: [], proibicoes: [] },
    auditPolicy: { hard_gates: true, soft_gates: true },
  });
}

test("19. questao REAL integral nao e despejada automaticamente no payload", () => {
  const referenciaComEnunciadoCompleto = {
    question_id: 43,
    banca: "Fundatec",
    ano: 2022,
    dificuldade: "media",
    enunciado: "Isto e um enunciado integral que NAO deveria aparecer no payload.",
    alternativas: ["A", "B", "C", "D", "E"],
  };
  const payload = payloadBase([referenciaComEnunciadoCompleto]);
  const referenciaSanitizada = payload.references.real_question_ids[0];

  assert.equal(referenciaSanitizada.question_id, 43);
  assert.equal("enunciado" in referenciaSanitizada, false, "enunciado integral nao pode vazar para o payload");
  assert.equal("alternativas" in referenciaSanitizada, false, "alternativas integrais nao podem vazar para o payload");
});

test("20. nenhum dado pessoal entra no payload serializado", () => {
  const payload = payloadBase([]);
  const serializado = JSON.stringify(payload).toLowerCase();

  const chavesProibidas = [
    "usuario_id",
    "email",
    "nome_aluno",
    "respostas_usuarios",
    "erros_usuarios",
    "revisoes",
    "matricula",
    "cpf",
    "senha",
    "password",
  ];
  for (const chave of chavesProibidas) {
    assert.equal(serializado.includes(chave), false, `payload nao pode conter a chave/termo proibido "${chave}"`);
  }
});

test("21. payload separa pedagogical_context de source (Fase 2A.1) — nunca um unico bloco fonte", () => {
  const payload = payloadBase([]);

  assert.ok("pedagogical_context" in payload, "payload precisa ter a chave pedagogical_context");
  assert.ok("source" in payload, "payload precisa ter a chave source");

  assert.equal(payload.pedagogical_context.status, STATUS_CONTEXTO_PEDAGOGICO.PEDAGOGICAL_CONTEXT_COMPLETE);
  assert.deepEqual(payload.pedagogical_context.expected_articles, ["art. 5"]);

  assert.equal(payload.source.status, STATUS_VALIDACAO_FONTE.SOURCE_VALIDATED);
  assert.deepEqual(payload.source.validated_source_keys, ["fonte-teste"]);
  assert.equal(payload.source.legal_source_required, true);

  // artigos_esperados nunca deve aparecer disfarcado de "referencia de fonte" —
  // so validated_source_keys (vindo do manifesto local) prova validacao.
  assert.equal("references" in payload.source, false, "source nao pode reter o campo antigo references (era preenchido com expected_articles)");
});
