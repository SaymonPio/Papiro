// Classificador de DOMINIO POLICIAL — PURO, multibanca (Fase 2C.4, Secoes
// 3-4). Nunca hardcoda uma banca especifica: qualquer banca real presente
// no corpus e elegivel, a classificacao decide apenas se o CONCURSO e da
// area policial/seguranca publica, nao quem a organizou.
//
// So examina o campo `concurso` (metadado), NUNCA o texto do enunciado —
// mesma disciplina de pareceConcursoPolicialOuSegurancaPublica em
// bank-style-profiler.mjs (Secao 19 daquele mandato: nunca assumir so por
// parecer plausivel). Regex por PALAVRA (com bordas), nunca substring
// livre, para nao classificar um concurso administrativo como policial so
// por coincidencia textual (Secao 4 do mandato 2C.4).
//
// Cada padrao abaixo foi conferido contra os concursos REAIS observados
// no corpus Fundatec/Portugues desta sessao antes de ser incluido — nunca
// inventado por plausibilidade.

export const DOMAIN_CATEGORIES = Object.freeze([
  "POLICIA_MILITAR",
  "POLICIA_CIVIL",
  "POLICIA_PENAL",
  "POLICIA_FEDERAL",
  "POLICIA_RODOVIARIA",
  "GUARDA_MUNICIPAL",
  "CORPO_DE_BOMBEIROS",
  "PERICIA_OFICIAL",
  "SEGURANCA_PUBLICA_EQUIVALENTE",
]);

// Ordem importa: categorias mais especificas sao checadas antes do
// catch-all generico (SEGURANCA_PUBLICA_EQUIVALENTE), para que um
// concurso de Corpo de Bombeiros nunca caia no generico so porque
// "bombeiro" tambem e seguranca publica em sentido amplo.
const PADROES_POR_CATEGORIA = Object.freeze([
  ["POLICIA_MILITAR", [/brigada militar/i, /pol[ií]cia militar/i, /\bpmerj\b/i, /\bpmesp\b/i]],
  ["CORPO_DE_BOMBEIROS", [/corpo de bombeiros/i, /\bbombeiro/i, /\bcbm\b/i, /\bcbmerj\b/i]],
  ["POLICIA_PENAL", [/pol[ií]cia penal/i, /\bpol\s*pen\b/i, /\bpp\s*rs\b/i, /penitenci[aá]ri/i]],
  ["POLICIA_FEDERAL", [/pol[ií]cia federal/i, /\bdpf\b/i]],
  ["POLICIA_RODOVIARIA", [/pol[ií]cia rodovi[aá]ria/i, /\bprf\b/i, /\bdprf\b/i]],
  ["PERICIA_OFICIAL", [/per[ií]ci[ao]/i, /\bigp\b/i, /\bper\s*crim\b/i, /\btec\s*per\b/i]],
  ["POLICIA_CIVIL", [/pol[ií]cia civil/i, /\bdel\s*pol\b/i, /\besc\s*pol\b/i, /\bpc\s*rs\b/i, /\bescriv[aã]o de pol[ií]cia\b/i, /\binspetor de pol[ií]cia\b/i, /\bdelegado\b/i]],
  ["GUARDA_MUNICIPAL", [/guarda municipal/i, /\bgcm\b/i, /\bgm\s*\(/i]],
  ["SEGURANCA_PUBLICA_EQUIVALENTE", [/seguran[cç]a p[uú]blica/i, /socioeducativ/i, /\bsejusp\b/i]],
]);

/**
 * Classifica se um `concurso` (metadado real, nunca o enunciado) pertence
 * a area policial/seguranca publica e, se sim, a qual categoria.
 *
 * @param {{ concurso?: string|null }} questaoRaw
 * @returns {{ isPolice: boolean, category: string|null, reason: string }}
 *   reason documenta explicitamente o padrao/motivo da decisao
 *   (domain_classification_reason do mandato) — nunca uma decisao muda,
 *   sempre rastreavel a um regex especifico ou a ausencia de match.
 */
export function classificarDominioPolicial(questaoRaw) {
  const concurso = (questaoRaw?.concurso || "").toString().trim();
  if (!concurso) {
    return { isPolice: false, category: null, reason: "concurso ausente/vazio — sem metadado suficiente para classificar dominio" };
  }
  for (const [categoria, padroes] of PADROES_POR_CATEGORIA) {
    const padraoCasado = padroes.find((p) => p.test(concurso));
    if (padraoCasado) {
      return { isPolice: true, category: categoria, reason: `concurso "${concurso}" casa com padrao ${padraoCasado} -> ${categoria}` };
    }
  }
  return { isPolice: false, category: null, reason: `concurso "${concurso}" nao casa com nenhum padrao de dominio policial/seguranca publica conhecido` };
}
