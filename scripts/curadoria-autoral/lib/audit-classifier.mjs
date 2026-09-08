// Classificador deterministico (Fase 2A, Secao 24). NAO executa auditoria
// semantica nenhuma — so combina o resultado do validador estrutural
// (validador-questoes.mjs) com o sinal deterministico de duplicidade
// (duplicate-utils.mjs) para decidir entre os 3 unicos estados que esta
// fase pode produzir honestamente:
//
//   REJEITADA            — hard gate estrutural falhou;
//   REVISAR               — estrutura valida, mas ha sinal de risco
//                            deterministico (ex.: duplicidade textual);
//   STRUCTURALLY_VALID     — estrutura valida, nenhum sinal de risco
//                            deterministico encontrado. NUNCA vira
//                            APROVADA aqui: aprovacao final depende de
//                            auditoria semantica (Fase 2B) + gate humano.

import { STATUS_AUDITORIA } from "./audit-contract.mjs";
import { CODIGOS_MOTIVO } from "./duplicate-utils.mjs";

// Sinais de duplicidade que, mesmo deterministicos, nao sao fortes o
// bastante para forcar REVISAR sozinhos (ex.: SEMANTIC_REVIEW_REQUIRED e
// so um lembrete estrutural, nao uma deteccao de texto igual/parecido).
const CODIGOS_DUPLICIDADE_FORTES = new Set([
  CODIGOS_MOTIVO.EXACT_TEXT_DUPLICATE,
  CODIGOS_MOTIVO.NORMALIZED_TEXT_DUPLICATE,
  CODIGOS_MOTIVO.HIGH_LEXICAL_SIMILARITY,
]);

/**
 * @param {{ validacaoEstrutural: {ok:boolean, errors:Array, warnings:Array}, duplicidade?: {codigo:string|null} }} entrada
 * @returns {{ status: string, reason_codes: string[] }}
 */
export function classificarDeterministico({ validacaoEstrutural, duplicidade }) {
  if (!validacaoEstrutural || validacaoEstrutural.ok !== true) {
    const codigos = (validacaoEstrutural?.errors ?? []).map((e) => e.codigo);
    return { status: STATUS_AUDITORIA.REJEITADA, reason_codes: codigos.length > 0 ? codigos : ["STRUCTURAL_VALIDATION_FAILED"] };
  }

  const reasonCodes = [];
  if (duplicidade?.codigo && CODIGOS_DUPLICIDADE_FORTES.has(duplicidade.codigo)) {
    reasonCodes.push(duplicidade.codigo);
  }
  if (duplicidade?.codigo === CODIGOS_MOTIVO.SEMANTIC_REVIEW_REQUIRED) {
    reasonCodes.push(duplicidade.codigo);
  }
  for (const aviso of validacaoEstrutural.warnings ?? []) {
    reasonCodes.push(aviso.codigo);
  }

  if (reasonCodes.length > 0) {
    return { status: STATUS_AUDITORIA.REVISAR, reason_codes: reasonCodes };
  }

  return { status: STATUS_AUDITORIA.STRUCTURALLY_VALID, reason_codes: [] };
}
