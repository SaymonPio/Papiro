// Auditoria NÃO BLOQUEANTE de escopo por artigo (Fase 2J-B).
//
// Sem I/O, sem chamada de rede, sem dependência de Deno nem de Node —
// mesmo princípio de validador.mjs: arquivo .mjs puro para poder ser
// importado tanto pela Edge Function (Deno) quanto pelos testes deste
// projeto (Node, node:test), sem duplicar a lógica em dois lugares.
//
// Esta auditoria NUNCA bloqueia a geração — é só um sinal para revisão
// humana (ver index.ts: mesmo com alerta, a aula_versao é criada
// normalmente, status continua 'rascunho', aula_geracoes nunca é marcada
// 'erro' por causa disso).
//
// Normalização deliberadamente simples (NÃO é um parser jurídico
// completo): extrai só "número base do artigo", opcionalmente com sufixo
// de letra (12-A, 12-B, 12-C — artigos aditados são dispositivos
// legalmente distintos do artigo numérico puro, por isso a letra é
// preservada). Tudo depois do número/sufixo (§, incisos, alíneas) é
// ignorado na comparação — "art. 19, § 5º" e "art. 19" são tratados como
// o mesmo artigo base para fins de auditoria de escopo.
const REGEX_ARTIGO_BASE = /^\s*(?:art(?:igo)?\.?\s*)?(\d+)\s*[º°]?\s*(?:-\s*([a-zA-Z]))?/i;

/**
 * Normaliza uma referência de artigo/dispositivo para seu "artigo base"
 * comparável (ex.: "Art. 19, § 5º" -> "19"; "art. 12-A" -> "12-A").
 * Referências sem nenhum número reconhecível no início (ex.: "Lei
 * 9.099/95", "Convenção de Belém do Pará") devolvem null — não são um
 * erro, só não entram na comparação (ver auditarEscopoArtigos).
 *
 * @param {unknown} referencia
 * @returns {string | null}
 */
export function normalizarArtigoBase(referencia) {
  if (typeof referencia !== "string") return null;
  const m = referencia.match(REGEX_ARTIGO_BASE);
  if (!m) return null;
  const numero = m[1];
  const letra = m[2];
  return letra ? `${numero}-${letra.toUpperCase()}` : numero;
}

/**
 * Compara os artigos efetivamente abordados numa geração contra os
 * artigos esperados cadastrados para a parte (teoria_escopos_conteudo.
 * artigos_esperados). NUNCA lança exceção, nunca bloqueia nada — só
 * calcula um sinal para revisão humana.
 *
 * artigosEsperados === null/undefined significa "sem metadado
 * suficiente" (nunca confundir com um array vazio, que significa
 * "nenhum artigo é esperado nesta parte") — nesse caso a auditoria
 * simplesmente não é executada.
 *
 * @param {string[]} artigosAbordados
 * @param {string[] | null | undefined} artigosEsperados
 * @returns {{ executada: false } | {
 *   executada: true,
 *   tem_alerta: boolean,
 *   artigos_abordados: string[],
 *   artigos_esperados: string[],
 *   artigos_fora_do_escopo: string[],
 *   referencias_nao_normalizadas: string[],
 * }}
 */
export function auditarEscopoArtigos(artigosAbordados, artigosEsperados) {
  const abordados = Array.isArray(artigosAbordados) ? artigosAbordados : [];

  if (artigosEsperados === null || artigosEsperados === undefined) {
    return { executada: false };
  }

  const basesEsperadas = new Set(
    artigosEsperados.map(normalizarArtigoBase).filter((base) => base !== null),
  );

  const artigosForaDoEscopo = [];
  const referenciasNaoNormalizadas = [];

  for (const artigo of abordados) {
    const base = normalizarArtigoBase(artigo);
    if (base === null) {
      referenciasNaoNormalizadas.push(artigo);
      continue;
    }
    if (!basesEsperadas.has(base)) {
      artigosForaDoEscopo.push(artigo);
    }
  }

  return {
    executada: true,
    tem_alerta: artigosForaDoEscopo.length > 0,
    artigos_abordados: abordados,
    artigos_esperados: artigosEsperados,
    artigos_fora_do_escopo: artigosForaDoEscopo,
    referencias_nao_normalizadas: referenciasNaoNormalizadas,
  };
}
