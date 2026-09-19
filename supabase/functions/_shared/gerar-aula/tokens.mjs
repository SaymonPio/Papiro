// Agregação de tokens entre tentativas (Fase 4 — auditoria final pré-
// deploy). Achado real: quando a correção automática (tentativa_ia=2)
// termina, o `usage` retornado pela OpenAI descreve só AQUELA Response —
// nunca a soma com a Response original (tentativa_ia=1). Sem agregação
// explícita, o UPDATE final de aula_geracoes.tokens_entrada/tokens_saida
// SOBRESCREVIA (nunca somava) o valor já gravado pela tentativa 1, então o
// consumo real registrado ficava menor do que o efetivamente gasto — dado
// de custo silenciosamente incorreto, sem nenhum erro visível.
//
// Uso: sempre que o finalizador vai gravar tokens_entrada/tokens_saida,
// passa o valor JÁ ARMAZENADO na linha (lido antes, no mesmo SELECT que
// trouxe a geração) como `anterior` e o valor da CHAMADA ATUAL como
// `atual` — o resultado é o total agregado a persistir.
//
// Nunca estima: se as duas pontas forem desconhecidas (null), o resultado
// continua null (nunca vira um 0 fabricado). Se só uma ponta for
// conhecida, o resultado é essa ponta (a outra contribui 0 — o melhor
// piso honesto disponível quando a OpenAI não informa usage para aquela
// chamada específica).

/**
 * @param {number | null | undefined} anterior
 * @param {number | null | undefined} atual
 * @returns {number | null}
 */
export function agregarTokens(anterior, atual) {
  if (anterior == null && atual == null) return null;
  return (anterior ?? 0) + (atual ?? 0);
}
