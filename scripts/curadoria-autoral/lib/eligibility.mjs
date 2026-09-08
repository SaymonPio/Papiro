// Avaliacao de contexto pedagogico, validacao de fonte, elegibilidade e
// prioridade (Fase 2A Secoes 12, 16, 30, 31, 32; Fase 2A.1 Secoes 2-6 —
// hardening que separa as duas perguntas que a Fase 2A original
// confundia). Puro — sem I/O, sem chamada de rede.
//
// Principio central (Fase 2A, Secao 11): aula publicada NUNCA bloqueia
// geracao — so vira warning. Principio central do hardening (Fase 2A.1):
// escopo/artigos_esperados NUNCA bloqueiam nem liberam sozinhos uma
// classificacao de FONTE — eles so respondem "sabemos o que ensinar?",
// nunca "a informacao esta documentalmente validada?". A segunda pergunta
// so pode ser respondida por lib/source-manifest.mjs (registro humano
// explicito).
//
// Politica de "isto e conteudo normativo/juridico?" (Secao 5/6/32): NUNCA
// decidida por materia_id hardcoded. Inferida do PROPRIO TEXTO do escopo
// (presenca de citacao tipo "art.", "lei n.", "decreto", "constituicao",
// "sumula") — extensivel, nao um if fixo por disciplina.

import { STATUS_BANCA, STATUS_CONTEXTO_PEDAGOGICO, STATUS_ELEGIBILIDADE, STATUS_VALIDACAO_FONTE } from "./schemas.mjs";

const PADRAO_ESCOPO_NORMATIVO = /\bart(igo)?s?\.?\s*\d|\blei\s+n[ºo°]?\.?\s*\d|\bdecreto\b|\bconstitui[cç][aã]o\b|\bsumula\b|\bsúmula\b/i;

/**
 * Heuristica extensivel (nao hardcoded por materia_id) para "este escopo
 * parece depender de uma norma/dispositivo especifico?". Usada so para
 * decidir se FALTAR fonte validada deve BLOQUEAR (juridico) ou apenas
 * AVISAR (Portugues/RLM/Informatica em geral).
 * @param {string} escopoTexto
 * @returns {boolean}
 */
export function materiaPareceNormativa(escopoTexto) {
  return PADRAO_ESCOPO_NORMATIVO.test(escopoTexto || "");
}

/**
 * "Sabemos O QUE ensinar/cobrar nesta unidade?" — NUNCA prova fonte
 * factual validada, so completude do metadado pedagogico.
 *
 * @param {{
 *   escopoUnidade: string,
 *   artigosEsperadosUnidade: string[]|null,
 *   teoriaEscopoConteudo?: { escopo?: string, artigos_esperados?: string[]|null } | null,
 *   materialVersoesExistem: boolean,
 * }} entrada
 */
export function avaliarContextoPedagogico({ escopoUnidade, artigosEsperadosUnidade, teoriaEscopoConteudo = null, materialVersoesExistem = false }) {
  const escopoEfetivo = (teoriaEscopoConteudo?.escopo && teoriaEscopoConteudo.escopo.trim().length > 0)
    ? teoriaEscopoConteudo.escopo
    : escopoUnidade;

  const artigosEfetivos = Array.isArray(teoriaEscopoConteudo?.artigos_esperados) && teoriaEscopoConteudo.artigos_esperados.length > 0
    ? teoriaEscopoConteudo.artigos_esperados
    : (artigosEsperadosUnidade ?? null);

  const escopoVazio = !escopoEfetivo || escopoEfetivo.trim().length === 0;
  if (escopoVazio) {
    return {
      status: STATUS_CONTEXTO_PEDAGOGICO.PEDAGOGICAL_CONTEXT_INSUFFICIENT,
      reason: "EMPTY_SCOPE",
      escopo_efetivo: escopoEfetivo ?? "",
      artigos_esperados_efetivos: artigosEfetivos,
    };
  }

  const temArtigosEsperados = Array.isArray(artigosEfetivos) && artigosEfetivos.length > 0;
  if (temArtigosEsperados || materialVersoesExistem) {
    return {
      status: STATUS_CONTEXTO_PEDAGOGICO.PEDAGOGICAL_CONTEXT_COMPLETE,
      reason: temArtigosEsperados ? "artigos_esperados presentes (metadado pedagogico, NAO fonte validada)" : "material_versoes anexado (fonte de conteudo-base, ainda nao necessariamente validada)",
      escopo_efetivo: escopoEfetivo,
      artigos_esperados_efetivos: artigosEfetivos,
    };
  }

  return {
    status: STATUS_CONTEXTO_PEDAGOGICO.PEDAGOGICAL_CONTEXT_PARTIAL,
    reason: "escopo textual presente, sem artigos_esperados/material anexado",
    escopo_efetivo: escopoEfetivo,
    artigos_esperados_efetivos: artigosEfetivos,
  };
}

/**
 * @param {{
 *   unidadeAtiva: boolean,
 *   faltantes: number,
 *   quantidadeSolicitada?: number|null,
 *   pedagogicalContextStatus: string,
 *   sourceValidationStatus: string,
 *   requerFonteValidada: boolean,
 *   bancaStatus: string,
 *   aulaExiste: boolean,
 *   aulaPublicada: boolean,
 * }} entrada
 * @returns {{ status: string, blocking_reasons: string[], warnings: string[] }}
 */
export function avaliarElegibilidade({
  unidadeAtiva,
  faltantes,
  quantidadeSolicitada = null,
  pedagogicalContextStatus,
  sourceValidationStatus,
  requerFonteValidada,
  bancaStatus,
  aulaExiste,
  aulaPublicada,
}) {
  const blocking = [];
  const warnings = [];

  if (!unidadeAtiva) blocking.push("UNIT_INACTIVE");
  if (!(faltantes > 0)) blocking.push("NO_DEFICIT");
  if (pedagogicalContextStatus === STATUS_CONTEXTO_PEDAGOGICO.PEDAGOGICAL_CONTEXT_INSUFFICIENT) blocking.push("PEDAGOGICAL_CONTEXT_INSUFFICIENT");
  if (bancaStatus !== STATUS_BANCA.RESOLVED) blocking.push(bancaStatus === STATUS_BANCA.BLOCKED_NO_BANK ? "BLOCKED_NO_BANK" : bancaStatus);
  if (quantidadeSolicitada !== null && quantidadeSolicitada !== undefined) {
    if (!(quantidadeSolicitada > 0)) blocking.push("QUANTITY_MUST_BE_POSITIVE");
    if (quantidadeSolicitada > faltantes) blocking.push("QUANTITY_EXCEEDS_DEFICIT");
  }

  const fonteValidada = sourceValidationStatus === STATUS_VALIDACAO_FONTE.SOURCE_VALIDATED;
  if (!fonteValidada) {
    if (requerFonteValidada) {
      // Conteudo normativo/juridico: falta de fonte documentalmente
      // validada BLOQUEIA geracao automatica (Fase 2A.1, Secao 5).
      blocking.push("LEGAL_SOURCE_NOT_DOCUMENTALLY_VALIDATED");
    } else {
      // Outras materias: contexto pedagogico pode bastar — falta de fonte
      // validada vira warning, nao bloqueio (Secao 6).
      warnings.push(sourceValidationStatus);
    }
  } else if (sourceValidationStatus === STATUS_VALIDACAO_FONTE.SOURCE_PARTIAL) {
    warnings.push("SOURCE_PARTIAL_COVERAGE");
  }

  if (pedagogicalContextStatus === STATUS_CONTEXTO_PEDAGOGICO.PEDAGOGICAL_CONTEXT_PARTIAL) warnings.push("PEDAGOGICAL_CONTEXT_PARTIAL");
  if (!aulaExiste) warnings.push("LESSON_DOES_NOT_EXIST");
  else if (!aulaPublicada) warnings.push("LESSON_NOT_PUBLISHED");

  return {
    status: blocking.length === 0 ? STATUS_ELEGIBILIDADE.ELIGIBLE_FOR_GENERATION : STATUS_ELEGIBILIDADE.BLOCKED,
    blocking_reasons: blocking,
    warnings,
  };
}

/**
 * Ranking simples e explicavel — nunca calculado por IA (Secao 16).
 * Precedencia fixa, sempre documentada via reason_codes:
 *   1) bloqueado -> BLOCKED
 *   2) deficit pequeno (<=2) -> P3
 *   3) fonte REALMENTE validada, sem warnings -> P0
 *   4) fonte validada, com warnings -> P1
 *   5) elegivel sem exigir fonte validada (materia nao normativa) -> P2
 *
 * @param {{ elegibilidade: {status:string, blocking_reasons:string[], warnings:string[]}, faltantes: number, sourceValidationStatus: string }} entrada
 */
export function calcularPrioridade({ elegibilidade, faltantes, sourceValidationStatus }) {
  if (elegibilidade.status === STATUS_ELEGIBILIDADE.BLOCKED) {
    return { prioridade: "BLOCKED", reason_codes: elegibilidade.blocking_reasons };
  }

  if (faltantes <= 2) {
    return { prioridade: "P3", reason_codes: ["LOW_ABSOLUTE_DEFICIT"] };
  }

  const fonteValidada = sourceValidationStatus === STATUS_VALIDACAO_FONTE.SOURCE_VALIDATED;
  if (fonteValidada && elegibilidade.warnings.length === 0) {
    return { prioridade: "P0", reason_codes: ["SOURCE_VALIDATED", "NO_WARNINGS"] };
  }
  if (fonteValidada) {
    return { prioridade: "P1", reason_codes: ["SOURCE_VALIDATED", ...elegibilidade.warnings] };
  }

  return { prioridade: "P2", reason_codes: [sourceValidationStatus, ...elegibilidade.warnings] };
}
