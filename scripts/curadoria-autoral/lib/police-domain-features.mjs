// Features de DOMINIO/RACIOCINIO (Fase 2C.4, Secao 8-C/E) — distintas de
// ESTILO DE BANCA (bank-style-features.mjs). Aqui a pergunta e "que tipo
// de conhecimento/raciocinio esta questao cobra", nunca "como esta banca
// formata suas questoes".
//
// classificarPadraoRaciocinio REUTILIZA classificarComando de
// bank-style-features.mjs (nunca reimplementa a deteccao de comando) e
// apenas reagrupa o mesmo sinal estrutural sob uma lente de raciocinio —
// o formato de comando ja e, por si so, um sinal de que tipo de raciocinio
// e exigido (preencher lacuna = completar sentenca; reescrever = validar
// reescrita), independente de qual banca escreveu a questao.

import { classificarComando } from "./bank-style-features.mjs";

export const REASONING_PATTERNS = Object.freeze([
  "RULE_APPLICATION",
  "ERROR_IDENTIFICATION",
  "SENTENCE_COMPLETION",
  "REWRITE_VALIDATION",
  "CONTEXTUAL_ANALYSIS",
  "MULTI_STATEMENT",
  "OTHER",
]);

const COMANDO_PARA_RACIOCINIO = Object.freeze({
  PREENCHIMENTO_LACUNAS: "SENTENCE_COMPLETION",
  REESCRITA: "REWRITE_VALIDATION",
  SUBSTITUICAO: "REWRITE_VALIDATION",
  ASSINALE_INCORRETA: "ERROR_IDENTIFICATION",
  ITENS_I_II_III: "MULTI_STATEMENT",
  ANALISE_AFIRMATIVAS: "MULTI_STATEMENT",
  RELACAO_TEXTO: "CONTEXTUAL_ANALYSIS",
  ASSINALE_CORRETA: "RULE_APPLICATION",
  OUTRO: "OTHER",
});

/**
 * Deriva o padrao de raciocinio a partir do comando ja detectado por
 * bank-style-features.mjs — nunca uma segunda deteccao independente.
 */
export function classificarPadraoRaciocinio(enunciado) {
  const comando = classificarComando(enunciado);
  return COMANDO_PARA_RACIOCINIO[comando] ?? "OTHER";
}

// Subtemas de CONCORDANCIA VERBAL (Fase 2C.4, Secao 7-8C) — taxonomy
// restrita ao piloto desta fase (assunto "Concordância verbal", materia
// Lingua Portuguesa). Nunca aplicada a outros assuntos: fora deste
// contexto, o chamador nao deve invocar esta funcao (Secao 8-C do
// mandato: "NAO inventar taxonomy se o dado nao permitir" — aqui so
// definimos taxonomy para o unico assunto explicitamente pedido).
export const SUBTEMAS_CONCORDANCIA_VERBAL = Object.freeze([
  "SUJEITO_NUCLEO",
  "HAVER_EXISTENCIAL",
  "EXISTIR_PESSOAL",
  "FAZER_TEMPORAL",
  "CONCORDANCIA_EM_CADEIA",
  "ACENTO_DIFERENCIAL",
  "OUTRO",
]);

export function classificarSubtemaConcordanciaVerbal(enunciado) {
  const texto = (enunciado || "").toLowerCase();

  if (/acento diferencial|t[êe]m\s*[\/\-–]\s*t[êe]m|v[êe]m\s*[\/\-–]\s*v[êe]m|mant[êe]m\s*[\/\-–]\s*mant[êe]m/i.test(texto)) {
    return "ACENTO_DIFERENCIAL";
  }
  // NOTA: "\b" logo apos uma vogal acentuada (á) NAO funciona em regex
  // JS — \w/\b sao definidos so em ASCII por padrao, entao a posicao
  // imediatamente apos "á" nunca e uma fronteira de palavra valida (\W
  // para \W nunca aciona \b). Por isso usamos um lookahead negativo
  // explicito "(?![a-zà-ÿ])" no lugar de "\b" sempre que a palavra pode
  // terminar em vogal acentuada (ex.: "há").
  if (/\bh[aá](?![a-zà-ÿ]).{0,25}(anos?|dias?|meses|semanas)\b.{0,10}que\b|\bfaz(em)?\b.{0,20}(anos?|dias?|meses|semanas|tempo)\b/i.test(texto)) {
    return "FAZER_TEMPORAL";
  }
  if (/\bh[aá](?![a-zà-ÿ]).{0,25}(problemas?|pessoas?|quest(õ|o)es|d[uú]vidas?|motivos?)|haver.{0,15}(existir|ocorrer|acontecer)/i.test(texto)) {
    return "HAVER_EXISTENCIAL";
  }
  if (/\bexist(e|em|ir|ência|entes)\b/i.test(texto)) {
    return "EXISTIR_PESSOAL";
  }
  if (/passa(sse|ssem|r)?\s+(a|para)\s+o\s+(singular|plural)|outras?\s+altera[cç][õo]es|v[áa]rios verbos|verbos?\s+(coordenados|em cadeia)/i.test(texto)) {
    return "CONCORDANCIA_EM_CADEIA";
  }
  if (/sujeito|n[uú]cleo do sujeito|concord[aâ]ncia (do|com o) verbo/i.test(texto)) {
    return "SUJEITO_NUCLEO";
  }
  return "OUTRO";
}
