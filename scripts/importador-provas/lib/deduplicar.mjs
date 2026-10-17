// Deduplicação contra o banco atual — mesmo algoritmo de 3 camadas já
// validado em scripts/dedupe-lote1-vs-supabase.js (Camada A: igualdade
// exata de enunciado normalizado; Camada B seria por ID de fonte externa,
// não aplicável ainda aqui pois o banco atual não tem fonte_externa_id —
// ver proposta de schema; Camada C: similaridade Jaccard, nunca resolvida
// automaticamente). Renomeado para o vocabulário desta fase (nova /
// provavel_duplicada / duplicada) e adaptado para comparar contra um
// snapshot local de `questoes` (modo SOMENTE LEITURA — este módulo nunca
// escreve, nunca faz UPDATE/DELETE, só compara dois arrays em memória).

export function normalizarTexto(valor) {
  return (valor ?? "")
    .toLowerCase()
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .replace(/[^a-z0-9 ]+/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

export function jaccard(a, b) {
  const setA = new Set(normalizarTexto(a).split(" ").filter(Boolean));
  const setB = new Set(normalizarTexto(b).split(" ").filter(Boolean));
  if (setA.size === 0 || setB.size === 0) return 0;
  let intersecao = 0;
  for (const palavra of setA) if (setB.has(palavra)) intersecao++;
  const uniao = setA.size + setB.size - intersecao;
  return uniao === 0 ? 0 : intersecao / uniao;
}

const LIMIAR_SIMILARIDADE = 0.35;
const LIMIAR_ALTERNATIVAS_COMPATIVEIS = 0.6;

function textoAlternativas(alternativas) {
  return (alternativas ?? []).map((a) => a.texto).join(" ");
}

export function classificarDuplicidade(questaoNormalizada, bancoExistente) {
  const enunciadoNovo = normalizarTexto(questaoNormalizada.enunciado);
  const alternativasNovo = textoAlternativas(questaoNormalizada.alternativas);

  for (const existente of bancoExistente) {
    if (normalizarTexto(existente.enunciado) === enunciadoNovo) {
      const simAlternativas = jaccard(alternativasNovo, textoAlternativas(existente.alternativas));
      if (simAlternativas >= LIMIAR_ALTERNATIVAS_COMPATIVEIS) {
        return { status: "duplicada", motivo: `enunciado identico e alternativas compativeis (questoes.id=${existente.id})`, match_id: existente.id };
      }
      // Mesmo enunciado "stub" mas alternativas muito diferentes: não é
      // considerado a mesma questão — segue para a camada de similaridade
      // combinada abaixo em vez de decidir aqui.
    }
  }

  let melhor = null;
  for (const existente of bancoExistente) {
    const combinadoNovo = `${questaoNormalizada.enunciado} ${alternativasNovo}`;
    const combinadoExistente = `${existente.enunciado ?? ""} ${textoAlternativas(existente.alternativas)}`;
    const similaridade = jaccard(combinadoNovo, combinadoExistente);
    if (similaridade >= LIMIAR_SIMILARIDADE && (!melhor || similaridade > melhor.similaridade)) {
      melhor = { existente, similaridade };
    }
  }

  if (melhor) {
    return {
      status: "provavel_duplicada",
      motivo: `similaridade Jaccard ${melhor.similaridade.toFixed(2)} com questoes.id=${melhor.existente.id} — requer leitura manual antes de decidir`,
      match_id: melhor.existente.id,
    };
  }

  return { status: "nova", motivo: "nenhuma correspondencia exata nem similaridade relevante contra o snapshot fornecido", match_id: null };
}
