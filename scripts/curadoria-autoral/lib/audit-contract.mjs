// Contrato de auditoria (Fase 2A, Secao 23). Define SOMENTE a forma do
// resultado de auditoria por questao e a lista de checks previstos — a
// execucao real (semantica, por IA) fica para a Fase 2B. Nada aqui chama
// IA nem calcula os checks semanticos: so garante que, quando existirem,
// terao um lugar fixo para pousar.

export const CHECKS_AUDITORIA = Object.freeze([
  "aderencia_unidade",
  "aderencia_aula",
  "gabarito_unico",
  "ambiguidade",
  "distratores",
  "explicacao",
  "fundamento",
  "dificuldade",
  "estilo_banca",
  "duplicidade",
  "risco_normativo",
  "dependencia_visual",
]);

export const STATUS_AUDITORIA = Object.freeze({
  APROVADA: "APROVADA",
  REVISAR: "REVISAR",
  REJEITADA: "REJEITADA",
  // Estado intermediario desta fase — ver audit-classifier.mjs: nenhuma
  // questao pode virar APROVADA sem auditoria semantica real (Fase 2B) +
  // gate humano. STRUCTURALLY_VALID e o teto desta fase.
  STRUCTURALLY_VALID: "STRUCTURALLY_VALID",
});

/**
 * Cria um resultado de auditoria vazio (todos os checks "nao executado"),
 * pronto para a Fase 2B preencher check a check. Uso nesta fase: só para
 * os testes confirmarem a forma do contrato, nunca para fingir uma
 * auditoria real.
 *
 * @param {string} questionKey
 * @returns {object}
 */
export function criarResultadoAuditoriaVazio(questionKey) {
  const checks = {};
  for (const nome of CHECKS_AUDITORIA) checks[nome] = { executado: false, resultado: null };

  return {
    question_key: questionKey,
    status: null,
    hard_gate_failures: [],
    soft_warnings: [],
    reason_codes: [],
    checks,
    audit_model: null,
    audit_prompt_version: null,
    audited_at: null,
  };
}
