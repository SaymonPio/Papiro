// Payload builder (Fase 2A, Secoes 17, 18, 19). Puro: recebe pecas ja
// resolvidas (curso, banca, cobertura de unidade, referencias) e monta o
// payload canonico exatamente na forma da Secao 18 do mandato. Nao busca
// nada no Supabase sozinho — quem faz isso e o CLI, via
// context-resolver.mjs + coverage-scanner.mjs + banca-resolver.mjs.
//
// Secao 19 (questoes REAL como referencia): NUNCA copia enunciado
// integral automaticamente — so metadados (id/banca/ano/dificuldade) sao
// aceitos aqui. Se o chamador passar um objeto de referencia com um
// enunciado completo, ele e removido explicitamente (nunca propagado por
// engano).
//
// Fase 2A.1 (Secao 9): o payload original tinha um unico bloco `source`
// que misturava "sabemos o que ensinar" (artigos_esperados/escopo) com "a
// informacao esta documentalmente validada". Agora sao dois blocos de
// primeiro nivel, cada um alimentado por uma avaliacao independente
// (eligibility.mjs#avaliarContextoPedagogico e
// source-manifest.mjs#avaliarValidacaoFonte): `pedagogical_context`
// (metadado, nunca prova fonte) e `source` (so reflete o manifesto local
// de fontes validadas por humano — nunca expected_articles).

import { PAYLOAD_SCHEMA_VERSION } from "./schemas.mjs";

function sanitizarReferenciaReal(ref) {
  return {
    question_id: ref.question_id ?? ref.id ?? null,
    banca: ref.banca ?? null,
    ano: ref.ano ?? null,
    dificuldade: ref.dificuldade ?? null,
    nucleo: ref.nucleo ?? null,
  };
}

/**
 * @param {object} entrada ver assinatura completa abaixo — cada campo e
 *   uma peca ja resolvida por outro modulo (nunca calculada aqui).
 * @returns {object} payload no formato da Secao 18
 */
export function construirPayload({
  runId,
  curso,
  banca,
  materia,
  conteudo,
  unidade,
  licao,
  cobertura,
  geracao,
  referenciasReal = [],
  cursoEvidenciaIds = [],
  contextoPedagogico,
  validacaoFonte,
  requerFonteValidada,
  constraints,
  auditPolicy,
  // Fase 2C.3, Secao 24: referencia OPCIONAL a um bank_style_profile ja
  // construido (bank-style-profiler.mjs) — {path, hash, confidence} ou
  // null. Nunca inventado aqui; so populado quando o chamador ja
  // construiu um perfil evidence-based real. Ausente = null, igual ao
  // comportamento anterior a esta fase (nunca fabrica regra de banca).
  bankStyleProfileRef = null,
}) {
  return {
    schema_version: PAYLOAD_SCHEMA_VERSION,
    run_id: runId,

    course: {
      id: curso.id,
      slug: curso.slug,
      name: curso.concurso ?? curso.slug,
    },

    bank: {
      name: banca.banca_resolvida,
      resolution_status: banca.status,
      resolution_source: banca.origem_da_resolucao,
      style_profile: bankStyleProfileRef,
      criteria: [],
    },

    subject: {
      id: materia.id,
      name: materia.nome,
    },

    content: {
      course_content_id: conteudo.curso_conteudo_id,
      subject_topic_id: conteudo.assunto_id,
      name: conteudo.nome,
      scope: conteudo.escopo ?? null,
    },

    unit: {
      id: unidade.id,
      title: unidade.titulo,
      scope: unidade.escopo,
      expected_articles: unidade.artigos_esperados ?? [],
    },

    lesson: {
      id: licao?.id ?? null,
      exists: Boolean(licao?.exists),
      published: Boolean(licao?.published),
      version_id: licao?.version_id ?? null,
      base_content: null,
    },

    coverage: {
      useful_current: cobertura.uteis_atual,
      real_current: cobertura.real_atual,
      authored_current: cobertura.autoral_atual,
      ai_generated_current: cobertura.gerada_por_ia_atual,
      target_bank_size: cobertura.target_bank_size,
      missing: cobertura.faltantes,
    },

    generation: {
      quantity: geracao.quantidade,
      origin: geracao.origem,
      difficulty_plan: geracao.dificuldades ?? [],
    },

    references: {
      real_question_ids: referenciasReal.map(sanitizarReferenciaReal),
      course_evidence_ids: cursoEvidenciaIds,
      style_summary: [],
    },

    // "Sabemos O QUE ensinar?" — metadado pedagogico, NUNCA fonte validada.
    pedagogical_context: {
      status: contextoPedagogico.status,
      reason: contextoPedagogico.reason,
      scope: contextoPedagogico.escopo_efetivo ?? null,
      expected_articles: contextoPedagogico.artigos_esperados_efetivos ?? [],
    },

    // "A informacao esta documentalmente validada por um humano?" — SOMENTE
    // o manifesto local (sources/*.json) alimenta isto. legal_source_required
    // documenta se a ausencia de fonte validada bloqueia (juridico) ou so
    // avisa (demais materias) — decidido por eligibility.mjs, nunca aqui.
    source: {
      status: validacaoFonte.status,
      legal_source_required: Boolean(requerFonteValidada),
      validated_source_keys: validacaoFonte.validated_sources ?? [],
      reason: validacaoFonte.reason,
      validated_content: null,
    },

    constraints: {
      requirements: constraints?.requisitos ?? [],
      prohibitions: constraints?.proibicoes ?? [],
    },

    audit_policy: {
      hard_gates: auditPolicy?.hard_gates ?? true,
      soft_gates: auditPolicy?.soft_gates ?? true,
    },
  };
}
