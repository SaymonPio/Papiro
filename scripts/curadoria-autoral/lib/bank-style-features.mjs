// Extracao PURA de features objetivas de UMA questao (Fase 2C.3, Secao 8).
// Nunca decide "e Fundatec" nem confianca — so descreve o que o texto
// contem, deterministicamente, via regex documentada. Cada padrao abaixo
// foi verificado contra uma amostra real do corpus Fundatec/Portugues
// desta sessao antes de ser escrito (nao inventado por plausibilidade —
// ver relatorio da Fase 2C.3 para a evidencia).

export const COMANDOS_CONHECIDOS = Object.freeze([
  "ASSINALE_CORRETA",
  "ASSINALE_INCORRETA",
  "PREENCHIMENTO_LACUNAS",
  "REESCRITA",
  "ITENS_I_II_III",
  "ANALISE_AFIRMATIVAS",
  "SUBSTITUICAO",
  "INTERPRETACAO",
  "RELACAO_TEXTO",
  "OUTRO",
]);

/**
 * Classifica o COMANDO da questao — ordem de prioridade importa: padroes
 * estruturais fortes (lacunas, reescrita, substituicao, itens numerados)
 * sao checados antes de fallbacks genericos ("assinale a alternativa").
 * Nunca forca uma classificacao sem evidencia textual real (Secao 8-B):
 * cai em OUTRO quando nenhum padrao bate.
 */
export function classificarComando(enunciado) {
  const texto = (enunciado || "").toLowerCase();

  if (/preench[ae].{0,30}lacuna|lacunas? (pontilhadas|dos? trechos?)|preencha.{0,20}corretamente as lacunas/.test(texto)) {
    return "PREENCHIMENTO_LACUNAS";
  }
  if (/reescrit[ae]|reescreva|reescrever/.test(texto)) {
    return "REESCRITA";
  }
  if (/pode ser substitu[ií]d[ao]|substitu[ií]d[ao] por|assinale.{0,40}substitu/.test(texto)) {
    return "SUBSTITUICAO";
  }
  // Itens numerados romanos (I., II., III. ...) — distingue ANALISE_AFIRMATIVAS
  // (quando o proprio enunciado fala em "afirmações"/"afirmativas") de
  // ITENS_I_II_III generico (itens numerados sem esse enquadramento).
  const temItensRomanos = /\bI\.\s|\bII\.\s|\bIII\.\s/.test(enunciado || "");
  // "afirmação" (singular, -ção) e "afirmações" (plural, -ções — vogal õ,
  // NUNCA ão) sao grafias diferentes; casar so [aã] apos o ç deixava o
  // plural de fora por engano.
  if (temItensRomanos && /afirma[cç][aã]o|afirma[cç][õo]es|afirmativ/.test(texto)) {
    return "ANALISE_AFIRMATIVAS";
  }
  if (temItensRomanos) {
    return "ITENS_I_II_III";
  }
  if (/incorret[ao]/.test(texto) && /assinale/.test(texto)) {
    return "ASSINALE_INCORRETA";
  }
  if (/\bexceto\b/.test(texto)) {
    return "ASSINALE_INCORRETA";
  }
  if (/no trecho|no texto|retirado do texto|de acordo com o texto|segundo o texto/.test(texto)) {
    return "RELACAO_TEXTO";
  }
  if (/assinale a alternativa/.test(texto)) {
    return "ASSINALE_CORRETA";
  }
  return "OUTRO";
}

/**
 * Detecta uso de texto-base (Secao 8-C). O padrao [NN] (linha numerada) e
 * a convencao ja estabelecida do projeto (ver memoria de curadoria) para
 * texto-base restaurado — presenca forte e inequivoca de texto-base longo.
 */
export function detectarTextoBase(enunciado) {
  const texto = enunciado || "";
  const usaMarcadorLinha = /\[\d{2}\]/.test(texto);
  const usaReferenciaLinhas = /\(l\.\s*\d+|linha\s+\d+/i.test(texto);
  const usaFragmento = /"\s*\[\.\.\.\]|…|retirad[ao] do texto/i.test(texto);
  const dependeImagemTabela = /figura\s+\d|tabela\s+\d|imagem\s+(abaixo|acima)|quadro\s+\d/i.test(texto);
  const usaTextoBase = usaMarcadorLinha || usaReferenciaLinhas || texto.length > 1200; // itens autocontidos observados no corpus real ficam bem abaixo disso

  return {
    autocontida: !usaTextoBase && !dependeImagemTabela,
    usa_texto_base: usaTextoBase,
    usa_referencia_linhas: usaReferenciaLinhas,
    usa_fragmento: usaFragmento,
    depende_imagem_tabela: dependeImagemTabela,
  };
}

/**
 * Detecta marcadores ESTRUTURAIS (Secao 8-E) — lacunas, negacao, EXCETO,
 * correta/incorreta, itens numerados, frase unica x multiplas sentencas.
 */
export function detectarEstrutura(enunciado) {
  const texto = (enunciado || "").toLowerCase();
  const bruto = enunciado || "";

  const lacunas = /_{2,}|\.{3,}(?=\s|$)|lacunas?\b/.test(bruto);
  const negacao = /\bn[aã]o\b/.test(texto);
  const excecaoExceto = /\bexceto\b/.test(texto);
  const corretaIncorreta = /\bcorret[ao]\b|\bincorret[ao]\b/.test(texto);
  const itensNumerados = /\bI\.\s|\bII\.\s|\bIII\.\s|\bIV\.\s/.test(bruto);
  const combinacaoItens = itensNumerados && /apenas|somente|est[aã]o corret|est[aã]o incorret/.test(texto);

  // Frase unica x multiplas sentencas: conta terminadores de sentenca fora
  // de aspas/parenteses de forma aproximada (heuristica simples, nao um
  // parser gramatical completo).
  const terminadores = (bruto.match(/[.!?](?=\s|$)/g) || []).length;
  const fraseUnica = terminadores <= 1;

  return {
    lacunas,
    negacao,
    excecao_exceto: excecaoExceto,
    correta_incorreta: corretaIncorreta,
    itens_numerados: itensNumerados,
    combinacao_itens: combinacaoItens,
    frase_unica: fraseUnica,
    multiplas_sentencas: !fraseUnica,
  };
}

/**
 * Conta alternativas e calcula comprimentos (Secao 8-A/8-D). Nunca
 * retorna o texto das alternativas — so os tamanhos.
 */
export function calcularComprimentos(enunciado, alternativas) {
  const comprimentosAlternativas = (alternativas || []).map((a) => (a.texto || "").length);
  const media = comprimentosAlternativas.length > 0 ? comprimentosAlternativas.reduce((s, v) => s + v, 0) / comprimentosAlternativas.length : 0;
  const desvio =
    comprimentosAlternativas.length > 0
      ? Math.sqrt(comprimentosAlternativas.reduce((s, v) => s + (v - media) ** 2, 0) / comprimentosAlternativas.length)
      : 0;

  return {
    enunciado_chars: (enunciado || "").length,
    alternativa_chars: comprimentosAlternativas,
    alternativa_chars_media: Math.round(media),
    alternativa_chars_desvio: Math.round(desvio),
    // homogeneidade aproximada: desvio baixo em relacao a media = alternativas de tamanho parecido.
    alternativas_homogeneas: media > 0 ? desvio / media < 0.4 : null,
  };
}

/**
 * Extrai TODAS as features de uma questao de uma vez — usado pelo
 * perfilador (agregacao) e pelo classificador de fidelidade (comparacao
 * individual), para nunca haver duas implementacoes divergentes da mesma
 * extracao.
 */
export function extrairFeaturesQuestao({ enunciado, alternativas }) {
  return {
    comando: classificarComando(enunciado),
    texto_base: detectarTextoBase(enunciado),
    estrutura: detectarEstrutura(enunciado),
    n_alternativas: (alternativas || []).length,
    comprimentos: calcularComprimentos(enunciado, alternativas),
  };
}
