// Classificador de fidelidade de estilo de UMA questao gerada contra um
// perfil de banca ja construido (Fase 2C.3, Secoes 15-17). Puro — nunca
// chama IA, nunca decide "aprovada". So compara features objetivas
// (mesma extracao de bank-style-features.mjs, nunca uma segunda copia)
// contra o que o corpus REAL realmente sustenta.

import { extrairFeaturesQuestao } from "./bank-style-features.mjs";

export const STATUS_FIDELIDADE_ESTILO = Object.freeze({
  BANK_STYLE_MATCH: "BANK_STYLE_MATCH",
  BANK_STYLE_REVIEW: "BANK_STYLE_REVIEW",
  BANK_STYLE_MISMATCH: "BANK_STYLE_MISMATCH",
  BANK_STYLE_INSUFFICIENT_EVIDENCE: "BANK_STYLE_INSUFFICIENT_EVIDENCE",
});

/**
 * @param {{ enunciado: string, alternativas: Array<{ letra?: string, texto: string }> }} questaoGerada
 * @param {object} perfil — saida de bank-style-profiler.mjs#construirPerfilBanca
 */
export function avaliarFidelidadeEstilo(questaoGerada, perfil) {
  // Fase 2C.3.1: LOW e INSUFFICIENT (< 1 confirmada) recebem o mesmo
  // fallback — a amostra confirmada estritamente e pequena/zero demais
  // para sustentar qualquer MATCH/MISMATCH honesto (Secao 7: "NAO manter
  // MATCH por inercia").
  if (!perfil || perfil.confidence === "LOW" || perfil.confidence === "INSUFFICIENT" || (perfil.sample.real_official_confirmed ?? 0) === 0) {
    return {
      format_classification: null,
      command_classification: null,
      length_position: null,
      alternative_count_match: null,
      base_text_pattern_match: null,
      observed_format_support: null,
      style_fidelity_status: STATUS_FIDELIDADE_ESTILO.BANK_STYLE_INSUFFICIENT_EVIDENCE,
      reason_codes: ["PROFILE_CONFIDENCE_LOW_OR_EMPTY"],
    };
  }

  const reasonCodes = [];
  const features = extrairFeaturesQuestao(questaoGerada);
  const comando = features.comando;

  const commandInfo = perfil.command_patterns.find((c) => c.format === comando);
  const observedCount = commandInfo ? commandInfo.count : 0;
  const observedPercent = commandInfo ? commandInfo.percent : 0;

  if (observedCount === 0) {
    reasonCodes.push("COMMAND_FORMAT_UNSUPPORTED_BY_CORPUS");
  } else if (observedPercent < 5) {
    reasonCodes.push("COMMAND_FORMAT_RARE_IN_CORPUS");
  } else if (commandInfo && commandInfo.robust_multi_exam_support === false) {
    // Fase 2C.3.4, Secao 13/15: contagem/percentual sozinhos nao bastam —
    // um formato so aparecendo em UMA prova nao sustenta "e assim que esta
    // banca escreve", so "e assim que ESTA prova especifica escreveu".
    // Evita confirmation bias (Secao 15: nunca forcar MATCH so porque a
    // questao gerada usa o mesmo formato que se queria confirmar).
    reasonCodes.push("COMMAND_FORMAT_SINGLE_EXAM_ONLY");
  }

  // Contagem de alternativas
  const nAlt = features.n_alternativas;
  const distribuicaoAlt = perfil.alternative_count_distribution ?? {};
  const totalAlt = Object.values(distribuicaoAlt).reduce((soma, v) => soma + v, 0);
  const contagemParaEsteN = distribuicaoAlt[nAlt] ?? distribuicaoAlt[String(nAlt)] ?? 0;
  const alternativeCountMatch = totalAlt > 0 ? contagemParaEsteN / totalAlt >= 0.5 : null;
  if (totalAlt > 0 && contagemParaEsteN === 0) reasonCodes.push("ALTERNATIVE_COUNT_UNSUPPORTED_BY_CORPUS");

  // Posicao de tamanho do enunciado em relacao ao corpus (IQR)
  const lp = perfil.length_profile?.enunciado_chars ?? {};
  let lengthPosition = "UNKNOWN";
  if (lp.min !== null && lp.min !== undefined) {
    const v = features.comprimentos.enunciado_chars;
    if (v < lp.min || v > lp.max) lengthPosition = "OUTLIER";
    else if (v < lp.p25) lengthPosition = "BELOW_P25";
    else if (v > lp.p75) lengthPosition = "ABOVE_P75";
    else lengthPosition = "WITHIN_IQR";
  }
  if (lengthPosition === "OUTLIER") reasonCodes.push("LENGTH_OUTLIER");

  // Padrao de texto-base: se a questao gerada usa texto-base longo mas o
  // corpus real quase nunca usa (ou vice-versa), sinaliza.
  const corpusUsaTextoBaseFreq = perfil.sample.real_official_confirmed > 0 ? (perfil.base_text_usage?.usa_texto_base ?? 0) / perfil.sample.real_official_confirmed : 0;
  const baseTextPatternMatch = features.texto_base.usa_texto_base ? corpusUsaTextoBaseFreq > 0 : true;
  if (features.texto_base.usa_texto_base && corpusUsaTextoBaseFreq === 0) reasonCodes.push("BASE_TEXT_UNSUPPORTED_BY_CORPUS");

  let status;
  if (reasonCodes.includes("COMMAND_FORMAT_UNSUPPORTED_BY_CORPUS") || reasonCodes.includes("BASE_TEXT_UNSUPPORTED_BY_CORPUS")) {
    status = STATUS_FIDELIDADE_ESTILO.BANK_STYLE_MISMATCH;
  } else if (reasonCodes.length > 0) {
    status = STATUS_FIDELIDADE_ESTILO.BANK_STYLE_REVIEW;
  } else {
    status = STATUS_FIDELIDADE_ESTILO.BANK_STYLE_MATCH;
  }

  return {
    format_classification: comando,
    command_classification: comando,
    length_position: lengthPosition,
    alternative_count_match: alternativeCountMatch,
    base_text_pattern_match: baseTextPatternMatch,
    observed_format_support: { count: observedCount, percent: observedPercent },
    style_fidelity_status: status,
    reason_codes: reasonCodes,
  };
}
