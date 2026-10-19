// Quebras de linha artificiais do PDF (fim da linha física no meio de uma
// frase: "qual\nopção de configuração") — com o enunciado exibido em
// white-space: pre-line elas aparecem como quebras de verdade. Junta SÓ
// a continuação sintática da mesma frase; toda quebra estrutural fica:
//   - bloco com linhas numeradas "[NN]" (texto-base) não é tocado;
//   - linha em branco (parágrafo) nunca é removida;
//   - linha recuada (começa com espaço) é item/parágrafo — fica;
//   - item de lista ("I.", "2)", "b)", "•", "- ") — fica;
//   - linha anterior terminada em . : ; ! ? … (com ou sem aspas/
//     parêntese de fechamento) — fica, mesmo quando ambígua;
//   - linha anterior CURTA (título, autoria, expressão isolada) — fica:
//     só é continuação a linha que chegou perto da largura útil do texto
//     (a maior linha do próprio enunciado).
// Só espaço em branco muda: as palavras e a pontuação são exatamente as
// mesmas (checado pelo chamador antes de gravar qualquer saneamento).

const LINHA_NUMERADA = /^\[\d{1,3}\]/;
const ITEM_DE_LISTA = /^(?:[IVXLC]{1,6}[.)–-]\s|\d{1,3}[.)]\s|[a-eA-E]\)\s|[•▪◦●]\s?|[-–—]\s)/;
const TERMINA_FRASE = /[.:;!?…][”"’'»)\]]*$/;
const PROPORCAO_LINHA_CHEIA = 0.6;
// Próxima linha com maiúscula só continua a frase quando a anterior acaba
// em vírgula ou em palavra que não fecha sintagma ("para o\nExcel",
// "então\nLiz", "Ana,\nCarol"). Sem isso, subtítulo + corpo do texto
// ("...se for vítima\nO golpe") e fonte + comando ("acesso em 16.8.26\nNa
// construção") eram fundidos — checado numa prova real: FGV/PCPR 2026.
const PALAVRA_DE_LIGACAO = /(?:,|\b(?:o|a|os|as|um|uma|uns|umas|de|do|da|dos|das|em|no|na|nos|nas|ao|aos|à|às|por|pelo|pela|pelos|pelas|para|com|sem|sob|sobre|entre|e|ou|nem|que|se|então|como|quando|onde|seu|sua|seus|suas|este|esta|esse|essa|cujo|cuja))$/i;
const COMECA_MAIUSCULA = /^[A-ZÀ-ÖØ-Þ]/;

function juntarBloco(linhas, larguraUtil) {
  const saida = [linhas[0]];
  for (let i = 1; i < linhas.length; i++) {
    const anterior = saida.at(-1);
    const atual = linhas[i];
    const continua =
      anterior.trim().length > 0 &&
      atual.trim().length > 0 &&
      !/^\s/.test(atual) &&
      !ITEM_DE_LISTA.test(atual) &&
      !TERMINA_FRASE.test(anterior.trimEnd()) &&
      anterior.trimEnd().length >= larguraUtil * PROPORCAO_LINHA_CHEIA &&
      (!COMECA_MAIUSCULA.test(atual) || PALAVRA_DE_LIGACAO.test(anterior.trimEnd()));
    const base = anterior.trimEnd();
    // Hífen no fim da linha: dentro de URL ("...o-cerebro-\nquando-...") é
    // parte do endereço e junta SEM espaço; fora de URL é ambíguo (separação
    // silábica "auto-\nridade" x palavra composta) e, como só espaço em
    // branco pode mudar, a quebra fica.
    const hifen = /\S-$/.test(base);
    const emUrl = hifen && /(?:https?:\/\/|www\.)\S*-$/.test(base);
    if (!continua || (hifen && !emUrl)) {
      saida.push(atual);
      continue;
    }
    saida[saida.length - 1] = emUrl ? base + atual : `${base} ${atual}`;
  }
  return saida;
}

export function juntarQuebrasArtificiais(texto) {
  if (!texto || !texto.includes("\n")) return texto;
  const linhas = texto.split("\n");
  const larguraUtil = Math.max(...linhas.map((l) => l.trimEnd().length));
  // Blocos separados por linha em branco; o separador é preservado tal e qual.
  const partes = texto.split(/(\n[ \t]*\n)/);
  return partes
    .map((parte, i) => {
      if (i % 2 === 1) return parte;
      const linhasDoBloco = parte.split("\n");
      if (linhasDoBloco.some((l) => LINHA_NUMERADA.test(l.trim()))) return parte;
      return juntarBloco(linhasDoBloco, larguraUtil).join("\n");
    })
    .join("");
}

// Garantia usada antes de gravar: mesmo texto, só espaço em branco diferente.
export function soMudouEspacoEmBranco(antes, depois) {
  const semEspaco = (t) => (t ?? "").replace(/\s+/g, "");
  return semEspaco(antes) === semEspaco(depois);
}
