// Agregacao local da auditoria independente (Fase 2C, Secoes 15-16). Puro
// — sem I/O, sem rede. Principio central (Secao 15): a IA NUNCA decide o
// status final do Papiro sozinha — `recommended_action` do Auditor B e
// tratado como mais um sinal, nunca autoridade; sozinho, so pode ESCALAR
// para revisao, nunca produzir rejeicao sem uma base local concreta
// (check critico ou severidade CRITICAL) por tras.

import { NOMES_CHECKS_CRITIC } from "./openai-audit-provider.mjs";

export const STATUS_AUDITORIA_FINAL = Object.freeze({
  AUDIT_PASS_TO_HUMAN: "AUDIT_PASS_TO_HUMAN",
  AUDIT_REVIEW_REQUIRED: "AUDIT_REVIEW_REQUIRED",
  AUDIT_REJECTED: "AUDIT_REJECTED",
});

// As 2 checks que, sozinhas, ja rejeitam em qualquer severidade (Secao 16:
// "correção factual/gramatical FAIL; ou gabarito único FAIL").
const CHECKS_CRITICOS_PARA_REJEICAO = new Set(["CORRECAO_FATUAL_GRAMATICAL", "GABARITO_UNICO"]);

/**
 * Compara localmente a resposta do Auditor A contra o gabarito declarado
 * — NUNCA pedido a IA (Secao 7). Retorna reason codes, nunca decide
 * sozinho o status final (isso e responsabilidade de agregarResultadoAuditoria).
 */
export function compararRespostaBlind({ independentAnswer, gabaritoDeclarado, ambiguity, confidence, uniqueAnswer }) {
  const match = independentAnswer === gabaritoDeclarado;
  const codes = [match ? "BLIND_KEY_MATCH" : "BLIND_KEY_MISMATCH"];
  if (ambiguity === "MATERIAL") codes.push("BLIND_AMBIGUITY_MATERIAL");
  if (confidence === "LOW") codes.push("BLIND_CONFIDENCE_LOW");
  if (uniqueAnswer === false) codes.push("BLIND_NOT_UNIQUE");
  return { match, unique: uniqueAnswer !== false, reason_codes: codes };
}

/**
 * Agrega os sinais do Auditor A + Auditor B em UM dos 3 estados possiveis
 * desta fase (nunca APROVADA_FINAL). Regras de precedencia (Secao 16):
 *   1) REJECT sempre que houver base LOCAL concreta (mismatch, ambiguidade
 *      material, resposta nao unica, check critico FAIL em qualquer
 *      severidade, qualquer check FAIL com severity CRITICAL, ou
 *      critical_findings nao vazio);
 *   2) senao, REVIEW quando houver qualquer sinal de atencao (check
 *      REVIEW, FAIL com severity HIGH, confidence LOW, ou a propria IA
 *      recomendando revisao/rejeicao sem base local suficiente para
 *      rejeitar de fato);
 *   3) senao, PASS_TO_HUMAN (que NUNCA significa aprovado — so "pronto
 *      para revisao humana").
 *
 * @param {{
 *   blindComparison: { match: boolean, unique: boolean, reason_codes: string[] },
 *   criticChecks: Array<{ check: string, status: string, severity: string, reason: string }>,
 *   criticalFindings: string[],
 *   recommendedAction: string,
 * }} entrada
 */
export function agregarResultadoAuditoria({ blindComparison, criticChecks, criticalFindings, recommendedAction }) {
  const reasonCodes = [...blindComparison.reason_codes];
  const motivosRejeicao = [];
  const motivosRevisao = [];

  if (!blindComparison.match) motivosRejeicao.push("AGGREGATION_BLIND_MISMATCH");
  if (reasonCodes.includes("BLIND_AMBIGUITY_MATERIAL")) motivosRejeicao.push("AGGREGATION_MATERIAL_AMBIGUITY");
  if (!blindComparison.unique) motivosRejeicao.push("AGGREGATION_NOT_UNIQUE");

  for (const c of criticChecks ?? []) {
    if (c.status === "FAIL" && CHECKS_CRITICOS_PARA_REJEICAO.has(c.check)) {
      motivosRejeicao.push(`CRITIC_FAIL_${c.check}`);
    } else if (c.status === "FAIL" && c.severity === "CRITICAL") {
      motivosRejeicao.push(`CRITIC_CRITICAL_FAIL_${c.check}`);
    } else if (c.status === "FAIL" && c.severity === "HIGH") {
      motivosRevisao.push(`CRITIC_HIGH_FAIL_${c.check}`);
    } else if (c.status === "REVIEW") {
      motivosRevisao.push(`CRITIC_REVIEW_${c.check}`);
    }
  }

  if (criticalFindings && criticalFindings.length > 0) motivosRejeicao.push("CRITIC_CRITICAL_FINDINGS_PRESENT");
  if (reasonCodes.includes("BLIND_CONFIDENCE_LOW")) motivosRevisao.push("BLIND_CONFIDENCE_LOW");

  // recommended_action da IA nunca decide sozinho (Secao 15): se ela pede
  // REJECT mas nao ha NENHUMA base local de rejeicao, isso so escala para
  // revisao (com reason code proprio, para o humano ver a discrepancia) —
  // nunca produz AUDIT_REJECTED por conta propria.
  if (recommendedAction === "REJECT") {
    if (motivosRejeicao.length > 0) motivosRejeicao.push("CRITIC_RECOMMENDED_REJECT");
    else motivosRevisao.push("CRITIC_RECOMMENDED_REJECT_WITHOUT_LOCAL_BASIS");
  } else if (recommendedAction === "HUMAN_REVIEW_REQUIRED") {
    motivosRevisao.push("CRITIC_RECOMMENDED_REVIEW");
  }

  if (motivosRejeicao.length > 0) {
    return { status: STATUS_AUDITORIA_FINAL.AUDIT_REJECTED, reason_codes: [...new Set([...reasonCodes, ...motivosRejeicao])] };
  }
  if (motivosRevisao.length > 0) {
    return { status: STATUS_AUDITORIA_FINAL.AUDIT_REVIEW_REQUIRED, reason_codes: [...new Set([...reasonCodes, ...motivosRevisao])] };
  }
  return { status: STATUS_AUDITORIA_FINAL.AUDIT_PASS_TO_HUMAN, reason_codes: [...new Set(reasonCodes)] };
}

/**
 * Validacao local do formato devolvido pelo Auditor A (Secao 23) — nunca
 * confia so no Structured Outputs da API. Retorna {ok, errors}.
 */
export function validarRespostaBlindLocalmente(dados) {
  const errors = [];
  if (!dados || !Array.isArray(dados.answers)) {
    return { ok: false, errors: ["answers ausente ou nao e array"] };
  }
  if (dados.answers.length !== 2) errors.push(`esperado 2 respostas, encontrado ${dados.answers.length}`);

  const slots = new Set();
  for (const a of dados.answers) {
    if (![1, 2].includes(a.slot)) errors.push(`slot invalido: ${a.slot}`);
    slots.add(a.slot);
    if (!["A", "B", "C", "D", "E"].includes(a.independent_answer)) errors.push(`independent_answer invalido para slot ${a.slot}: ${a.independent_answer}`);
    if (typeof a.unique_answer !== "boolean") errors.push(`unique_answer nao booleano para slot ${a.slot}`);
    if (!["NONE", "LOW", "MATERIAL"].includes(a.ambiguity)) errors.push(`ambiguity invalido para slot ${a.slot}: ${a.ambiguity}`);
    if (!["HIGH", "MEDIUM", "LOW"].includes(a.confidence)) errors.push(`confidence invalido para slot ${a.slot}: ${a.confidence}`);
    if (!Array.isArray(a.issues)) errors.push(`issues nao e array para slot ${a.slot}`);
  }
  if (slots.size !== 2) errors.push("slots das respostas nao cobrem exatamente {1,2} sem repeticao");

  return { ok: errors.length === 0, errors };
}

/**
 * Validacao local do formato devolvido pelo Auditor B (Secao 23) — exige
 * exatamente as 12 checks nomeadas, cada uma exatamente uma vez.
 */
export function validarRespostaCriticLocalmente(dados) {
  const errors = [];
  if (!dados || !Array.isArray(dados.audits)) {
    return { ok: false, errors: ["audits ausente ou nao e array"] };
  }
  if (dados.audits.length !== 2) errors.push(`esperado 2 auditorias, encontrado ${dados.audits.length}`);

  const slots = new Set();
  const nomesEsperados = new Set(NOMES_CHECKS_CRITIC);
  for (const auditoria of dados.audits) {
    if (![1, 2].includes(auditoria.slot)) errors.push(`slot invalido: ${auditoria.slot}`);
    slots.add(auditoria.slot);

    if (!Array.isArray(auditoria.checks) || auditoria.checks.length !== 12) {
      errors.push(`slot ${auditoria.slot}: esperado exatamente 12 checks, encontrado ${auditoria.checks?.length}`);
    } else {
      const nomesVistos = new Set();
      for (const c of auditoria.checks) {
        if (!nomesEsperados.has(c.check)) errors.push(`slot ${auditoria.slot}: check desconhecida "${c.check}"`);
        nomesVistos.add(c.check);
        if (!["PASS", "REVIEW", "FAIL"].includes(c.status)) errors.push(`slot ${auditoria.slot}: status invalido em ${c.check}: ${c.status}`);
        if (!["NONE", "LOW", "MEDIUM", "HIGH", "CRITICAL"].includes(c.severity)) errors.push(`slot ${auditoria.slot}: severity invalida em ${c.check}: ${c.severity}`);
      }
      if (nomesVistos.size !== 12) errors.push(`slot ${auditoria.slot}: as 12 checks precisam ser distintas (sem repeticao/omissao)`);
    }

    if (!Array.isArray(auditoria.critical_findings)) errors.push(`slot ${auditoria.slot}: critical_findings nao e array`);
    if (!["PASS_TO_HUMAN", "HUMAN_REVIEW_REQUIRED", "REJECT"].includes(auditoria.recommended_action)) {
      errors.push(`slot ${auditoria.slot}: recommended_action invalido: ${auditoria.recommended_action}`);
    }
  }
  if (slots.size !== 2) errors.push("slots das auditorias nao cobrem exatamente {1,2} sem repeticao");

  return { ok: errors.length === 0, errors };
}
