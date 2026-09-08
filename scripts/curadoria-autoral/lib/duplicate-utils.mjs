// Utilitarios puros de deduplicacao deterministica — sem I/O, sem chamada
// de rede, sem dependencia externa. Reaproveita literalmente a logica de
// normalizacao e similaridade lexical ja provada em
// scripts/dedupe-lote1-vs-supabase.js (normalize/jaccard), so renomeada
// para o padrao em portugues do resto deste novo pipeline.
//
// Camadas (Fase 2A, Secao 25):
//   Camada 1: hash do texto normalizado (match exato, tolera acento/
//             maiuscula/espacamento);
//   Camada 2: texto normalizado identico string-a-string (mesma info que a
//             Camada 1 revela, exposta separadamente para quem quiser
//             comparar sem calcular hash);
//   Camada 3: similaridade lexical (Jaccard) acima do limiar;
//   Camada 4: nunca calculada aqui (exigiria embeddings/IA) — o unico sinal
//             determinista que esta camada pode emitir e um lembrete
//             estrutural (mesma unidade-alvo), nunca uma decisao de
//             duplicidade.

import crypto from "node:crypto";

export const LIMIAR_SIMILARIDADE = 0.35;

export const CODIGOS_MOTIVO = {
  EXACT_TEXT_DUPLICATE: "EXACT_TEXT_DUPLICATE",
  NORMALIZED_TEXT_DUPLICATE: "NORMALIZED_TEXT_DUPLICATE",
  HIGH_LEXICAL_SIMILARITY: "HIGH_LEXICAL_SIMILARITY",
  SEMANTIC_REVIEW_REQUIRED: "SEMANTIC_REVIEW_REQUIRED",
};

/**
 * Normaliza texto para comparacao: minusculas, sem acento, so alfanumerico
 * e espaco, espacos colapsados. Identico ao `normalize()` de
 * scripts/dedupe-lote1-vs-supabase.js.
 * @param {string} texto
 * @returns {string}
 */
export function normalizarTexto(texto) {
  return (texto || "")
    .toLowerCase()
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .replace(/[^a-z0-9 ]+/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

/**
 * Hash sha256 hex do texto ja normalizado — usado para comparacao O(1) via
 * Map/Set em vez de comparar strings longas repetidamente.
 * @param {string} texto
 * @returns {string}
 */
export function hashTextoNormalizado(texto) {
  return crypto.createHash("sha256").update(normalizarTexto(texto), "utf8").digest("hex");
}

/**
 * Similaridade de Jaccard sobre o conjunto de palavras normalizadas.
 * Identico ao `jaccard()` de scripts/dedupe-lote1-vs-supabase.js.
 * @param {string} a
 * @param {string} b
 * @returns {number} entre 0 e 1
 */
export function similaridadeLexical(a, b) {
  const setA = new Set(normalizarTexto(a).split(" ").filter(Boolean));
  const setB = new Set(normalizarTexto(b).split(" ").filter(Boolean));
  if (setA.size === 0 || setB.size === 0) return 0;
  let intersecao = 0;
  for (const palavra of setA) if (setB.has(palavra)) intersecao += 1;
  const uniao = setA.size + setB.size - intersecao;
  return uniao === 0 ? 0 : intersecao / uniao;
}

/**
 * Classifica um texto candidato (tipicamente enunciado, ou
 * enunciado+alternativas concatenados) contra uma lista de candidatos
 * existentes, retornando o sinal MAIS FORTE encontrado. Nunca lanca
 * excecao, nunca decide "e duplicata" sozinho — so calcula o sinal
 * deterministico; a decisao final (REJEITADA/REVISAR) e do
 * audit-classifier.
 *
 * @param {string} textoNovo
 * @param {Array<{ id: number|string, texto: string, mesmaUnidade?: boolean }>} candidatos
 * @returns {{ codigo: string | null, similaridade: number | null, candidato_id: (number|string|null) }}
 */
export function classificarDuplicidade(textoNovo, candidatos) {
  if (!Array.isArray(candidatos) || candidatos.length === 0) {
    return { codigo: null, similaridade: null, candidato_id: null };
  }

  const hashNovo = hashTextoNormalizado(textoNovo);
  const normNovo = normalizarTexto(textoNovo);

  for (const candidato of candidatos) {
    if (hashTextoNormalizado(candidato.texto) === hashNovo) {
      return { codigo: CODIGOS_MOTIVO.EXACT_TEXT_DUPLICATE, similaridade: 1, candidato_id: candidato.id };
    }
  }

  for (const candidato of candidatos) {
    if (normalizarTexto(candidato.texto) === normNovo) {
      return { codigo: CODIGOS_MOTIVO.NORMALIZED_TEXT_DUPLICATE, similaridade: 1, candidato_id: candidato.id };
    }
  }

  let melhor = null;
  for (const candidato of candidatos) {
    const sim = similaridadeLexical(textoNovo, candidato.texto);
    if (sim >= LIMIAR_SIMILARIDADE && (!melhor || sim > melhor.sim)) {
      melhor = { sim, id: candidato.id };
    }
  }
  if (melhor) {
    return { codigo: CODIGOS_MOTIVO.HIGH_LEXICAL_SIMILARITY, similaridade: melhor.sim, candidato_id: melhor.id };
  }

  // Nenhum sinal lexical — mas se algum candidato pertence explicitamente
  // a mesma unidade-alvo, sinaliza para revisao semantica humana (esta
  // sessao ja confirmou repetidas vezes que mesmo assunto_id/unidade NAO
  // implica mesmo conteudo, mas tambem nao pode ser ignorado por default).
  const mesmaUnidade = candidatos.some((c) => c.mesmaUnidade === true);
  if (mesmaUnidade) {
    return { codigo: CODIGOS_MOTIVO.SEMANTIC_REVIEW_REQUIRED, similaridade: null, candidato_id: null };
  }

  return { codigo: null, similaridade: null, candidato_id: null };
}

/**
 * Variante de classificarDuplicidade para quando so existe o HASH do texto
 * normalizado do candidato — nunca o texto bruto (Fase 2B, Secoes 11/13:
 * dedup_baseline.json guarda so `texto_normalizado_hash` das questoes REAL
 * existentes, de proposito, para nunca persistir o enunciado integral
 * delas em nenhum artefato deste pipeline).
 *
 * So consegue emitir Camada 1 (EXACT_TEXT_DUPLICATE, por igualdade de
 * hash — que ja cobre a Camada 2, pois o hash e do texto normalizado).
 * Nunca calcula Jaccard (Camada 3): sem o texto bruto do candidato isso e
 * matematicamente impossivel, nao so indisponivel por escolha —
 * `camada_3_indisponivel: true` deixa isso explicito para quem ler o
 * resultado, em vez de sugerir silenciosamente "nenhuma similaridade".
 *
 * @param {string} textoNovo
 * @param {Array<{ id: number|string, texto_normalizado_hash: string }>} candidatosComHash
 */
export function compararContraHashesExistentes(textoNovo, candidatosComHash) {
  if (!Array.isArray(candidatosComHash) || candidatosComHash.length === 0) {
    return { codigo: null, similaridade: null, candidato_id: null, camada_3_indisponivel: true };
  }

  const hashNovo = hashTextoNormalizado(textoNovo);
  for (const candidato of candidatosComHash) {
    if (candidato.texto_normalizado_hash === hashNovo) {
      return { codigo: CODIGOS_MOTIVO.EXACT_TEXT_DUPLICATE, similaridade: 1, candidato_id: candidato.id, camada_3_indisponivel: true };
    }
  }

  return { codigo: null, similaridade: null, candidato_id: null, camada_3_indisponivel: true };
}
