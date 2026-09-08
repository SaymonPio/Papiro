// Classificacao pos-geracao da Fase 2B (Secoes 20-25). Deliberadamente
// SEPARADA de audit-classifier.mjs (Fase 2A) — reusa validador-questoes.mjs
// e duplicate-utils.mjs, mas incorpora dois sinais que so existem depois de
// uma geracao real: tripwires gramaticais (grammar-tripwires.mjs) e
// correcao de slot pedagogico. audit-classifier.mjs continua intocado e
// vale para o fluxo generico de auditoria de lote (fora do escopo desta
// fase).
//
// Vocabulario proprio desta fase (Secao 25), nunca APROVADA_FINAL aqui:
//   REJECTED_PRE_AUDIT          — hard gate estrutural OU tripwire gramatical falhou;
//   REVIEW_REQUIRED_PRE_AUDIT   — estrutura+tripwires OK, mas ha sinal de
//                                 risco (duplicidade, slot trocado, warning
//                                 estrutural);
//   STRUCTURALLY_VALID_FOR_AUDIT — nenhum sinal de risco encontrado. A
//                                 aprovacao final depende da Fase 2C
//                                 (auditoria semantica) + revisao humana.

import { extrairSlotDoQuestionKey } from "./generation-enrichment.mjs";
import { verificarTripwiresGramaticais } from "./grammar-tripwires.mjs";
import { CODIGOS_MOTIVO } from "./duplicate-utils.mjs";

export const STATUS_PRE_AUDITORIA = Object.freeze({
  STRUCTURALLY_VALID_FOR_AUDIT: "STRUCTURALLY_VALID_FOR_AUDIT",
  REVIEW_REQUIRED_PRE_AUDIT: "REVIEW_REQUIRED_PRE_AUDIT",
  REJECTED_PRE_AUDIT: "REJECTED_PRE_AUDIT",
});

const CODIGOS_DUPLICIDADE_FORTES = new Set([
  CODIGOS_MOTIVO.EXACT_TEXT_DUPLICATE,
  CODIGOS_MOTIVO.NORMALIZED_TEXT_DUPLICATE,
  CODIGOS_MOTIVO.HIGH_LEXICAL_SIMILARITY,
]);

/**
 * Concatena os campos textuais de uma questao enriquecida para rodar os
 * tripwires gramaticais contra TODO o conteudo relevante (nao so o
 * enunciado) — Secao 21.
 */
export function textoCompletoParaTripwires(questaoEnriquecida) {
  const partes = [
    questaoEnriquecida.enunciado,
    ...(questaoEnriquecida.alternativas ?? []).map((a) => a?.texto),
    questaoEnriquecida.explicacao,
    questaoEnriquecida.fundamento?.descricao,
    questaoEnriquecida.fundamento?.referencia,
  ];
  return partes.filter((p) => typeof p === "string" && p.length > 0).join(" \n ");
}

/**
 * @param {{
 *   questaoEnriquecida: object,
 *   validacaoEstrutural: {ok:boolean, errors:Array, warnings:Array},
 *   slotEsperado: number,
 *   duplicidadeContraBaseline?: {codigo: string|null},
 *   duplicidadeContraIrma?: {codigo: string|null},
 * }} entrada
 * @returns {{ status: string, reason_codes: string[], tripwires: object }}
 */
export function classificarQuestaoPreAuditoria({
  questaoEnriquecida,
  validacaoEstrutural,
  slotEsperado,
  duplicidadeContraBaseline = null,
  duplicidadeContraIrma = null,
}) {
  const tripwires = verificarTripwiresGramaticais(textoCompletoParaTripwires(questaoEnriquecida));

  if (!validacaoEstrutural || validacaoEstrutural.ok !== true) {
    const codigos = (validacaoEstrutural?.errors ?? []).map((e) => e.codigo);
    return { status: STATUS_PRE_AUDITORIA.REJECTED_PRE_AUDIT, reason_codes: codigos.length > 0 ? codigos : ["STRUCTURAL_VALIDATION_FAILED"], tripwires };
  }

  // Secao 21: qualquer tripwire gramatical falhando REJEITA — nunca vira
  // REVIEW_REQUIRED (a regra congelada nao e negociavel por revisao
  // humana leve, e um erro factual conhecido).
  if (!tripwires.ok) {
    return { status: STATUS_PRE_AUDITORIA.REJECTED_PRE_AUDIT, reason_codes: tripwires.motivos, tripwires };
  }

  const reasonCodes = [];

  const slotReal = extrairSlotDoQuestionKey(questaoEnriquecida.question_key);
  if (slotReal !== slotEsperado) {
    reasonCodes.push("SLOT_MISMATCH");
  }

  if (duplicidadeContraBaseline?.codigo && CODIGOS_DUPLICIDADE_FORTES.has(duplicidadeContraBaseline.codigo)) {
    reasonCodes.push(`DUP_BASELINE_${duplicidadeContraBaseline.codigo}`);
  } else if (duplicidadeContraBaseline?.codigo === CODIGOS_MOTIVO.SEMANTIC_REVIEW_REQUIRED) {
    reasonCodes.push(`DUP_BASELINE_${duplicidadeContraBaseline.codigo}`);
  }

  if (duplicidadeContraIrma?.codigo && CODIGOS_DUPLICIDADE_FORTES.has(duplicidadeContraIrma.codigo)) {
    reasonCodes.push(`DUP_SIBLING_${duplicidadeContraIrma.codigo}`);
  } else if (duplicidadeContraIrma?.codigo === CODIGOS_MOTIVO.SEMANTIC_REVIEW_REQUIRED) {
    reasonCodes.push(`DUP_SIBLING_${duplicidadeContraIrma.codigo}`);
  }

  for (const aviso of validacaoEstrutural.warnings ?? []) {
    reasonCodes.push(aviso.codigo);
  }

  if (reasonCodes.length > 0) {
    return { status: STATUS_PRE_AUDITORIA.REVIEW_REQUIRED_PRE_AUDIT, reason_codes: reasonCodes, tripwires };
  }

  return { status: STATUS_PRE_AUDITORIA.STRUCTURALLY_VALID_FOR_AUDIT, reason_codes: [], tripwires };
}

/**
 * Secao 22: as duas questoes, juntas, precisam cobrir os slots 1 e 2 SEM
 * troca nem repeticao. Roda depois de classificarQuestaoPreAuditoria de
 * cada uma (nao substitui aquela checagem por questao) — este e o check
 * do PAR.
 */
export function verificarCoberturaDeSlots(questoesEnriquecidas) {
  const slots = questoesEnriquecidas.map((q) => extrairSlotDoQuestionKey(q.question_key));
  const slotsUnicos = new Set(slots);
  const cobreAmbos = slotsUnicos.has(1) && slotsUnicos.has(2) && slots.length === 2;
  return {
    ok: cobreAmbos,
    slots_encontrados: slots,
    motivo: cobreAmbos ? null : "slots devolvidos nao cobrem exatamente {1,2} sem repeticao",
  };
}
