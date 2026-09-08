// Resolucao de banca sem migration (Fase 2A, Secao 13). Nao existe tabela
// `bancas` nem `banca_id` hoje (confirmado na Fase 1) — a unica fonte
// primaria e `cursos.banca` (texto livre, nullable), com `editais.banca`
// como fonte secundaria (tambem texto livre, extraida por IA do PDF do
// edital). Este modulo NUNCA substitui um pelo outro silenciosamente e
// NUNCA altera o dado original — so calcula um status de resolucao.
//
// Puro — sem I/O.

import { STATUS_BANCA } from "./schemas.mjs";

function normalizarParaComparacao(texto) {
  return (texto || "")
    .toLowerCase()
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .replace(/[^a-z0-9 ]+/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

// Duas bancas sao consideradas a mesma instituicao quando, depois de
// normalizadas, uma e identica a outra OU quando a mais curta aparece
// como palavra inteira dentro da mais longa (cobre o caso real observado
// na Fase 1: "Fundatec" vs "FUNDATEC – Fundacao Universidade Empresa de
// Tecnologia e Ciencias" — mesma banca, nomes de tamanhos diferentes).
function saoCompativeis(a, b) {
  const normA = normalizarParaComparacao(a);
  const normB = normalizarParaComparacao(b);
  if (!normA || !normB) return false;
  if (normA === normB) return true;

  const [curta, longa] = normA.length <= normB.length ? [normA, normB] : [normB, normA];
  const palavrasLonga = new Set(longa.split(" "));
  const palavrasCurta = curta.split(" ");
  return palavrasCurta.length > 0 && palavrasCurta.every((p) => palavrasLonga.has(p));
}

/**
 * @param {{ cursoBanca?: string|null, editalBanca?: string|null, override?: string|null }} entrada
 * @returns {{
 *   status: string,
 *   banca_resolvida: string|null,
 *   curso_banca: string|null,
 *   edital_banca: string|null,
 *   origem_da_resolucao: string,
 * }}
 */
export function resolverBanca({ cursoBanca = null, editalBanca = null, override = null } = {}) {
  if (override && override.trim().length > 0) {
    return {
      status: STATUS_BANCA.RESOLVED,
      banca_resolvida: override.trim(),
      curso_banca: cursoBanca ?? null,
      edital_banca: editalBanca ?? null,
      origem_da_resolucao: "MANUAL_OVERRIDE",
    };
  }

  const temCurso = typeof cursoBanca === "string" && cursoBanca.trim().length > 0;
  const temEdital = typeof editalBanca === "string" && editalBanca.trim().length > 0;

  if (temCurso && temEdital) {
    if (saoCompativeis(cursoBanca, editalBanca)) {
      return {
        status: STATUS_BANCA.RESOLVED,
        banca_resolvida: cursoBanca.trim(),
        curso_banca: cursoBanca,
        edital_banca: editalBanca,
        origem_da_resolucao: "cursos.banca (confirmado por editais.banca)",
      };
    }
    return {
      status: STATUS_BANCA.REVIEW_CONFLICT,
      banca_resolvida: null,
      curso_banca: cursoBanca,
      edital_banca: editalBanca,
      origem_da_resolucao: "cursos.banca e editais.banca divergem materialmente — requer revisao humana",
    };
  }

  if (temCurso) {
    return {
      status: STATUS_BANCA.RESOLVED,
      banca_resolvida: cursoBanca.trim(),
      curso_banca: cursoBanca,
      edital_banca: null,
      origem_da_resolucao: "cursos.banca",
    };
  }

  if (temEdital) {
    return {
      status: STATUS_BANCA.REVIEW_FALLBACK,
      banca_resolvida: editalBanca.trim(),
      curso_banca: null,
      edital_banca: editalBanca,
      origem_da_resolucao: "editais.banca (cursos.banca ausente — fallback, requer confirmacao humana)",
    };
  }

  return {
    status: STATUS_BANCA.BLOCKED_NO_BANK,
    banca_resolvida: null,
    curso_banca: null,
    edital_banca: null,
    origem_da_resolucao: "nenhuma fonte de banca disponivel",
  };
}
