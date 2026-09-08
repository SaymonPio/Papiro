// Fase 2A.1 (hardening pre-OpenAI) — testes da separacao entre
// "contexto pedagogico" (sabemos o que ensinar?) e "validacao de fonte"
// (a informacao esta documentalmente validada por um humano?). Ver
// lib/eligibility.mjs e lib/source-manifest.mjs para as duas funcoes que
// respondem, respectivamente, cada uma dessas perguntas de forma
// independente — este arquivo existe para provar que elas realmente NAO
// se confundem mais (o bug original: artigos_esperados/escopo, sozinhos,
// produziam SOURCE_VALIDATED).

import assert from "node:assert/strict";
import test from "node:test";
import { avaliarContextoPedagogico, avaliarElegibilidade, materiaPareceNormativa } from "../scripts/curadoria-autoral/lib/eligibility.mjs";
import { avaliarValidacaoFonte, buscarFontesParaUnidade, carregarFontes } from "../scripts/curadoria-autoral/lib/source-manifest.mjs";
import { CODIGO_ABORTO_SESSAO_NAO_READONLY, travarSessaoSomenteLeituraOuAbortar } from "../scripts/curadoria-autoral/lib/context-resolver.mjs";
import { STATUS_BANCA, STATUS_CONTEXTO_PEDAGOGICO, STATUS_ELEGIBILIDADE, STATUS_VALIDACAO_FONTE } from "../scripts/curadoria-autoral/lib/schemas.mjs";

// Dados reais (confirmados via consulta direta ao Supabase nesta sessao,
// nao inventados) das duas unidades usadas como regressao — exatamente as
// que expuseram o bug original.
const LOB_BM_UNIDADE_ID = "3c033d9a-5543-422a-a935-c55095bdfc86";
const LOB_BM_ESCOPO = "Lei de Organização Básica da Brigada Militar: a Lei nº 10.991/1997, historicamente conhecida como Lei de Organização Básica da Brigada Militar, foi expressamente revogada pela Lei Complementar nº 16.450, de 24/12/2025 (art. 47), vigente desde 26/12/2025, que hoje disciplina a organização, a estrutura básica e o efetivo da Brigada Militar do Estado do Rio Grande do Sul.";
const LOB_BM_ARTIGOS_ESPERADOS = ["art. 10"];

const ESTATUTO_UNIDADE_ID = "bf13f365-3dd9-4d22-9ad7-f369a298eb19";
const ESTATUTO_ESCOPO = "Estatuto dos Militares Estaduais (Lei Complementar nº 10.990/1997): hierarquia e disciplina como base institucional da Brigada Militar (art. 12); serviço e carreira policial-militar, incluindo o regime próprio aplicável a Oficiais nomeados Juízes do Tribunal Militar do Estado e a precedência hierárquica entre servidores militares (arts. 4º, 5º, 8º, 15).";
const ESTATUTO_ARTIGOS_ESPERADOS = [
  "art. 4º, caput", "art. 5º, parágrafo único", "art. 8º, parágrafo único", "art. 12, caput",
  "art. 15, caput", "art. 15, §3º", "art. 35, caput", "art. 35, §2º", "art. 35, §3º",
  "art. 36, caput", "art. 46, VII", "art. 46, VIII", "art. 46, XIII", "art. 46, XIV", "art. 46, XV",
];

test("1. artigos_esperados sozinho NAO produz SOURCE_VALIDATED (so PEDAGOGICAL_CONTEXT_COMPLETE)", () => {
  const contexto = avaliarContextoPedagogico({
    escopoUnidade: "Escopo com dispositivo citado.",
    artigosEsperadosUnidade: ["art. 5º"],
    materialVersoesExistem: false,
  });
  assert.equal(contexto.status, STATUS_CONTEXTO_PEDAGOGICO.PEDAGOGICAL_CONTEXT_COMPLETE);

  // sem nenhuma fonte no manifesto para esta unidade fictícia:
  const validacao = avaliarValidacaoFonte({ fontesDaUnidade: [], artigosEsperados: contexto.artigos_esperados_efetivos });
  assert.equal(validacao.status, STATUS_VALIDACAO_FONTE.SOURCE_MISSING);
  assert.notEqual(validacao.status, STATUS_VALIDACAO_FONTE.SOURCE_VALIDATED);
});

test("2. escopo sozinho (sem artigos_esperados, sem fonte) NAO produz SOURCE_VALIDATED", () => {
  const contexto = avaliarContextoPedagogico({
    escopoUnidade: "Escopo textual detalhado, mas sem lista de artigos_esperados.",
    artigosEsperadosUnidade: null,
    materialVersoesExistem: false,
  });
  assert.equal(contexto.status, STATUS_CONTEXTO_PEDAGOGICO.PEDAGOGICAL_CONTEXT_PARTIAL);

  const validacao = avaliarValidacaoFonte({ fontesDaUnidade: [], artigosEsperados: contexto.artigos_esperados_efetivos });
  assert.equal(validacao.status, STATUS_VALIDACAO_FONTE.SOURCE_MISSING);
});

test("3. fonte explicitamente validated=true, cobrindo tudo, PRODUZ SOURCE_VALIDATED", () => {
  const fontesDaUnidade = [
    { source_key: "fonte-x", validated: true, covers_articles: ["art. 5º"] },
  ];
  const validacao = avaliarValidacaoFonte({ fontesDaUnidade, artigosEsperados: ["art. 5º"] });
  assert.equal(validacao.status, STATUS_VALIDACAO_FONTE.SOURCE_VALIDATED);
  assert.deepEqual(validacao.validated_sources, ["fonte-x"]);
});

test("4. fonte validated=true mas covers_articles PARCIAL produz SOURCE_PARTIAL", () => {
  const fontesDaUnidade = [
    { source_key: "fonte-parcial", validated: true, covers_articles: ["art. 5º"] },
  ];
  const validacao = avaliarValidacaoFonte({ fontesDaUnidade, artigosEsperados: ["art. 5º", "art. 6º"] });
  assert.equal(validacao.status, STATUS_VALIDACAO_FONTE.SOURCE_PARTIAL);
});

test("5. fonte presente mas NAO validada produz SOURCE_REQUIRES_HUMAN_VALIDATION (nunca SOURCE_VALIDATED)", () => {
  const fontesDaUnidade = [
    { source_key: "fonte-rascunho", validated: false, covers_articles: ["art. 5º"] },
  ];
  const validacao = avaliarValidacaoFonte({ fontesDaUnidade, artigosEsperados: ["art. 5º"] });
  assert.equal(validacao.status, STATUS_VALIDACAO_FONTE.SOURCE_REQUIRES_HUMAN_VALIDATION);
  assert.deepEqual(validacao.validated_sources, []);
});

test("6. nenhuma fonte no manifesto para a unidade produz SOURCE_MISSING", () => {
  const validacao = avaliarValidacaoFonte({ fontesDaUnidade: [], artigosEsperados: null });
  assert.equal(validacao.status, STATUS_VALIDACAO_FONTE.SOURCE_MISSING);
});

test("7. REGRESSAO LOB-BM: contexto pedagogico OK, mas source BLOQUEIA por falta de validacao humana", () => {
  const contexto = avaliarContextoPedagogico({
    escopoUnidade: LOB_BM_ESCOPO,
    artigosEsperadosUnidade: LOB_BM_ARTIGOS_ESPERADOS,
    materialVersoesExistem: false,
  });
  assert.equal(contexto.status, STATUS_CONTEXTO_PEDAGOGICO.PEDAGOGICAL_CONTEXT_COMPLETE);

  const todasFontes = carregarFontes();
  const fontesDaUnidade = buscarFontesParaUnidade(todasFontes, LOB_BM_UNIDADE_ID);
  const validacaoFonte = avaliarValidacaoFonte({ fontesDaUnidade, artigosEsperados: contexto.artigos_esperados_efetivos });

  // FALHA explicita se isto voltar a ser SOURCE_VALIDATED so por causa do
  // art. 10 estar em artigos_esperados (o bug original desta unidade).
  assert.notEqual(validacaoFonte.status, STATUS_VALIDACAO_FONTE.SOURCE_VALIDATED, "LOB-BM NAO pode ser SOURCE_VALIDATED sem uma fonte com validated=true");
  assert.equal(validacaoFonte.status, STATUS_VALIDACAO_FONTE.SOURCE_REQUIRES_HUMAN_VALIDATION);

  const requerFonteValidada = materiaPareceNormativa(LOB_BM_ESCOPO);
  assert.equal(requerFonteValidada, true, "escopo cita 'Lei nº ...'/'art. ...' — deve ser tratado como conteudo normativo");

  const elegibilidade = avaliarElegibilidade({
    unidadeAtiva: true,
    faltantes: 8,
    pedagogicalContextStatus: contexto.status,
    sourceValidationStatus: validacaoFonte.status,
    requerFonteValidada,
    bancaStatus: STATUS_BANCA.RESOLVED,
    aulaExiste: true,
    aulaPublicada: true,
  });
  assert.equal(elegibilidade.status, STATUS_ELEGIBILIDADE.BLOCKED);
  assert.ok(elegibilidade.blocking_reasons.includes("LEGAL_SOURCE_NOT_DOCUMENTALLY_VALIDATED"));
});

test("8. REGRESSAO Estatuto dos Militares Estaduais (piloto Fase 2A): NAO deve mais ser SOURCE_VALIDATED", () => {
  const contexto = avaliarContextoPedagogico({
    escopoUnidade: ESTATUTO_ESCOPO,
    artigosEsperadosUnidade: ESTATUTO_ARTIGOS_ESPERADOS,
    materialVersoesExistem: false,
  });
  // Isto SEMPRE foi verdade e continua sendo — 15 artigos_esperados sao
  // metadado pedagogico solido. O que muda e que isto NUNCA mais decide
  // sozinho o status de fonte.
  assert.equal(contexto.status, STATUS_CONTEXTO_PEDAGOGICO.PEDAGOGICAL_CONTEXT_COMPLETE);

  const todasFontes = carregarFontes();
  const fontesDaUnidade = buscarFontesParaUnidade(todasFontes, ESTATUTO_UNIDADE_ID);
  const validacaoFonte = avaliarValidacaoFonte({ fontesDaUnidade, artigosEsperados: contexto.artigos_esperados_efetivos });

  assert.notEqual(
    validacaoFonte.status,
    STATUS_VALIDACAO_FONTE.SOURCE_VALIDATED,
    "classificacao SOURCE_VALIDATED do piloto da Fase 2A era o bug — nao pode se repetir sem um humano validar de fato"
  );

  const elegibilidade = avaliarElegibilidade({
    unidadeAtiva: true,
    faltantes: 5,
    pedagogicalContextStatus: contexto.status,
    sourceValidationStatus: validacaoFonte.status,
    requerFonteValidada: materiaPareceNormativa(ESTATUTO_ESCOPO),
    bancaStatus: STATUS_BANCA.RESOLVED,
    aulaExiste: false,
    aulaPublicada: false,
  });
  assert.equal(elegibilidade.status, STATUS_ELEGIBILIDADE.BLOCKED);
  assert.ok(elegibilidade.blocking_reasons.includes("LEGAL_SOURCE_NOT_DOCUMENTALLY_VALIDATED"));
});

test("9. conteudo juridico sem fonte validada BLOQUEIA (LEGAL_SOURCE_NOT_DOCUMENTALLY_VALIDATED)", () => {
  const elegibilidade = avaliarElegibilidade({
    unidadeAtiva: true,
    faltantes: 4,
    pedagogicalContextStatus: STATUS_CONTEXTO_PEDAGOGICO.PEDAGOGICAL_CONTEXT_COMPLETE,
    sourceValidationStatus: STATUS_VALIDACAO_FONTE.SOURCE_MISSING,
    requerFonteValidada: true,
    bancaStatus: STATUS_BANCA.RESOLVED,
    aulaExiste: true,
    aulaPublicada: true,
  });
  assert.equal(elegibilidade.status, STATUS_ELEGIBILIDADE.BLOCKED);
  assert.ok(elegibilidade.blocking_reasons.includes("LEGAL_SOURCE_NOT_DOCUMENTALLY_VALIDATED"));
});

test("10. conteudo NAO juridico sem fonte validada so AVISA, nao bloqueia (assimetria pedida na Secao 6)", () => {
  const elegibilidade = avaliarElegibilidade({
    unidadeAtiva: true,
    faltantes: 4,
    pedagogicalContextStatus: STATUS_CONTEXTO_PEDAGOGICO.PEDAGOGICAL_CONTEXT_COMPLETE,
    sourceValidationStatus: STATUS_VALIDACAO_FONTE.SOURCE_MISSING,
    requerFonteValidada: false,
    bancaStatus: STATUS_BANCA.RESOLVED,
    aulaExiste: true,
    aulaPublicada: true,
  });
  assert.equal(elegibilidade.status, STATUS_ELEGIBILIDADE.ELIGIBLE_FOR_GENERATION);
  assert.ok(elegibilidade.warnings.includes(STATUS_VALIDACAO_FONTE.SOURCE_MISSING));
});

test("11. materiaPareceNormativa nao depende de materia_id — decide pelo texto do escopo", () => {
  assert.equal(materiaPareceNormativa("Concordância verbal e nominal em português."), false);
  assert.equal(materiaPareceNormativa("Lógica proposicional e tabelas-verdade."), false);
  assert.equal(materiaPareceNormativa("Art. 5º da Constituição Federal — direitos e garantias fundamentais."), true);
  assert.equal(materiaPareceNormativa("Decreto nº 1.234, sobre procedimentos administrativos."), true);
});

test("12. sessao Postgres CONFIRMADA read-only nao aborta (SHOW retorna 'on')", async () => {
  const chamadas = [];
  const clienteFalsoReadOnly = {
    query: async (sql) => {
      chamadas.push(sql);
      if (/^SET/.test(sql)) return { rows: [] };
      return { rows: [{ transaction_read_only: "on" }] };
    },
  };
  const resultado = await travarSessaoSomenteLeituraOuAbortar(clienteFalsoReadOnly);
  assert.equal(resultado, "on");
  assert.equal(chamadas.length, 2);
  assert.match(chamadas[0], /SET default_transaction_read_only = on/);
  assert.match(chamadas[1], /SHOW transaction_read_only/);
});

test("13. sessao Postgres NAO read-only ABORTA com PG_SESSION_NOT_READ_ONLY, sem seguir adiante", async () => {
  const clienteFalsoEscrita = {
    query: async (sql) => {
      if (/^SET/.test(sql)) return { rows: [] };
      return { rows: [{ transaction_read_only: "off" }] };
    },
  };
  await assert.rejects(
    () => travarSessaoSomenteLeituraOuAbortar(clienteFalsoEscrita),
    (erro) => {
      assert.match(erro.message, new RegExp(CODIGO_ABORTO_SESSAO_NAO_READONLY));
      return true;
    }
  );
});

test("14. manifesto local de fontes (sources/*.json): fontes JURIDICAS (official_law) continuam validated=false", () => {
  // Fase 2A.1: nenhuma fonte de LEGISLACAO pode virar validated=true so por
  // pesquisa da IA (WebSearch) — exige leitura humana do texto oficial
  // primario, que ainda nao aconteceu para LOB-BM/Estatuto.
  const fontes = carregarFontes();
  const juridicas = fontes.filter((f) => f.type === "official_law");
  assert.ok(juridicas.length >= 2, "esperado pelo menos os 2 rascunhos juridicos desta sessao (LOB-BM e Estatuto/LC10990)");
  for (const fonte of juridicas) {
    assert.equal(fonte.validated, false, `fonte juridica ${fonte.source_key} nao deveria estar validated=true sem leitura humana do texto oficial primario`);
    assert.equal(fonte.validated_by, null);
  }
});

test("15. manifesto local de fontes: fonte PEDAGOGICA (Concordancia verbal, Fase 2A.2) pode ser validated=true quando o conteudo-base foi verificado ao vivo no projeto", () => {
  const fontes = carregarFontes();
  const pedagogica = fontes.find((f) => f.source_key === "BMRS_PT_CONCORDANCIA_VERBAL_ESCOPO_UNIDADE");
  assert.ok(pedagogica, "esperado o manifesto do piloto Concordancia verbal");
  assert.equal(pedagogica.type, "pedagogical_reference");
  assert.equal(pedagogica.validated, true);
  assert.equal(pedagogica.validated_by, "human_curated_project_context");
  assert.ok(Array.isArray(pedagogica.applies_to_unit_ids) && pedagogica.applies_to_unit_ids.includes("834a820d-48a7-440f-a013-be375be8a62d"));

  const validacao = avaliarValidacaoFonte({
    fontesDaUnidade: buscarFontesParaUnidade(fontes, "834a820d-48a7-440f-a013-be375be8a62d"),
    artigosEsperados: null,
  });
  assert.equal(validacao.status, STATUS_VALIDACAO_FONTE.SOURCE_VALIDATED, "Portugues nao tem artigos_esperados — fonte validated=true sem covers_articles deve bastar");
});
