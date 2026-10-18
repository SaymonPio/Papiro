// Expressões matemáticas posicionais (fração empilhada, sobrescrito,
// subscrito) reconstruídas a partir dos itens de texto X/Y do PDF — a
// extração linear perde a geometria e entrega o numerador e o denominador
// de uma fração como duas "linhas" ("7\n2"), o que vira "7 2" no texto
// final (checado numa prova real: Fundatec/PP-RS 2026, questão 40,
// "–7, 7/2, –14" saía "–7, 7 2 , –14").
//
// Sinal geométrico, nunca banca: um trecho em fonte MENOR que o corpo da
// linha, colado horizontalmente a texto de corpo normal, deslocado para
// cima e/ou para baixo da linha de base desses vizinhos. Dois desses
// trechos empilhados (mesma faixa X, um acima e outro abaixo da linha de
// base) = fração; um só, acima = sobrescrito; um só, abaixo = subscrito.
// Texto pequeno sem vizinho de corpo normal na mesma linha (nota de
// rodapé, fonte da citação) não é expressão e nunca é tocado.
//
// Regra do produto: o que não puder ser reconstruído com confiança vira
// "incerta" — a questão da página vai para revisão manual, nunca é
// transformada silenciosamente em texto errado.

const PROPORCAO_FONTE_PEQUENA = 0.85; // altura <= 85% do corpo da página
const PROPORCAO_FONTE_CORPO = 0.95; // vizinho só conta se for corpo normal
const DISTANCIA_MAXIMA_VIZINHO = 1.5; // em alturas de corpo
const DESLOCAMENTO_MINIMO = 0.15; // fração da altura do corpo para estar acima/abaixo da linha de base
const DESLOCAMENTO_MINIMO_SOBRESCRITO = 0.25;
const SOBREPOSICAO_MINIMA_FRACAO = 0.5; // sobreposição horizontal mínima entre numerador e denominador
const CONTEUDO_SIMPLES = /^[0-9A-Za-z.,+\-–−×·πθ√()]{1,12}$/;

const SOBRESCRITOS = { 0: "⁰", 1: "¹", 2: "²", 3: "³", 4: "⁴", 5: "⁵", 6: "⁶", 7: "⁷", 8: "⁸", 9: "⁹", "+": "⁺", "-": "⁻", "−": "⁻", "–": "⁻" };
const SUBSCRITOS = { 0: "₀", 1: "₁", 2: "₂", 3: "₃", 4: "₄", 5: "₅", 6: "₆", 7: "₇", 8: "₈", 9: "₉" };

function ehEspaco(item) {
  return item.texto.trim().length === 0;
}

function alturaDoCorpo(itens) {
  const contagem = new Map();
  for (const item of itens) {
    if (ehEspaco(item) || !(item.altura > 0)) continue;
    const chave = Math.round(item.altura * 2) / 2;
    contagem.set(chave, (contagem.get(chave) ?? 0) + item.texto.length);
  }
  let melhor = null;
  for (const [altura, peso] of contagem) if (!melhor || peso > melhor.peso) melhor = { altura, peso };
  return melhor?.altura ?? null;
}

// Itens pequenos colados na mesma altura ("1" "3" ou "x" "+" "1") viram
// um trecho só antes de qualquer decisão.
function agruparTrechosPequenos(pequenos, corpo) {
  const ordenados = [...pequenos].sort((a, b) => b.y - a.y || a.x - b.x);
  const trechos = [];
  for (const item of ordenados) {
    const anterior = trechos.at(-1);
    if (anterior && Math.abs(anterior.y - item.y) <= item.altura * 0.3 && item.x - (anterior.x + anterior.largura) <= corpo * 0.3) {
      anterior.texto += item.texto;
      anterior.largura = item.x + item.largura - anterior.x;
      anterior.itens.push(item);
    } else {
      trechos.push({ texto: item.texto, x: item.x, y: item.y, largura: item.largura, altura: item.altura, itens: [item] });
    }
  }
  for (const t of trechos) t.texto = t.texto.trim();
  return trechos.filter((t) => t.texto.length > 0);
}

function vizinhosDeCorpo(trecho, normais, corpo) {
  const alcance = corpo * DISTANCIA_MAXIMA_VIZINHO;
  const naFaixa = normais.filter((n) => Math.abs(n.y - trecho.y) <= corpo * 0.9);
  const esquerda = naFaixa
    .filter((n) => n.x + n.largura <= trecho.x + 1 && trecho.x - (n.x + n.largura) <= alcance)
    .sort((a, b) => b.x + b.largura - (a.x + a.largura))[0] ?? null;
  const direita = naFaixa
    .filter((n) => n.x >= trecho.x + trecho.largura - 1 && n.x - (trecho.x + trecho.largura) <= alcance)
    .sort((a, b) => a.x - b.x)[0] ?? null;
  return { esquerda, direita };
}

function sobreposicaoHorizontal(a, b) {
  const inicio = Math.max(a.x, b.x);
  const fim = Math.min(a.x + a.largura, b.x + b.largura);
  return Math.max(0, fim - inicio) / Math.max(Math.min(a.largura, b.largura), 0.01);
}

function precisaParenteses(parte) {
  return /\s/.test(parte) || /.[+\-–−×·]/.test(parte);
}

function textoFracao(numerador, denominador) {
  const n = precisaParenteses(numerador) ? `(${numerador})` : numerador;
  const d = precisaParenteses(denominador) ? `(${denominador})` : denominador;
  return `${n}/${d}`;
}

// "o"/"a" sobrescrito logo depois de um número ou de "n"/"N" é o
// indicador ordinal do português ("1º", "3ª", "nº") — checado numa prova
// real: FEPESE/PMBC 2014, "Lei nº 10.741 de 1º de outubro", "3ª Classe".
function indicadorOrdinal(texto, textoAnterior) {
  if (!/^[oa]$/.test(texto) || !/(?:\d|\bn|\bN)$/.test((textoAnterior ?? "").trimEnd())) return null;
  return texto === "o" ? "º" : "ª";
}

function converterPorTabela(texto, tabela) {
  const convertido = [...texto].map((c) => tabela[c]);
  return convertido.every(Boolean) ? convertido.join("") : null;
}

// Núcleo puro: itens de UMA página ({texto,x,y,largura,altura}) ->
// expressões detectadas + itens com cada expressão já fundida num item
// sintético na linha de base (para a reconstrução posicional) + trechos
// incertos.
export function detectarExpressoes(itens) {
  const corpo = alturaDoCorpo(itens);
  if (!corpo) return { expressoes: [], incertas: [], itens };

  const pequenos = itens.filter((i) => !ehEspaco(i) && i.altura > 0 && i.altura <= corpo * PROPORCAO_FONTE_PEQUENA);
  if (pequenos.length === 0) return { expressoes: [], incertas: [], itens };
  const normais = itens.filter((i) => !ehEspaco(i) && i.altura >= corpo * PROPORCAO_FONTE_CORPO);

  const trechos = agruparTrechosPequenos(pequenos, corpo).map((t) => {
    const { esquerda, direita } = vizinhosDeCorpo(t, normais, corpo);
    const base = esquerda ?? direita;
    return { ...t, esquerda, direita, linhaBase: base ? base.y : null, deslocamento: base ? t.y - base.y : null };
  });

  const expressoes = [];
  const incertas = [];
  const consumidos = new Set();

  // Fração: um trecho acima e outro abaixo da MESMA linha de base,
  // empilhados na mesma faixa X.
  for (const cima of trechos) {
    if (consumidos.has(cima) || cima.linhaBase === null || cima.deslocamento <= corpo * DESLOCAMENTO_MINIMO) continue;
    const baixo = trechos.find(
      (t) =>
        !consumidos.has(t) &&
        t !== cima &&
        t.linhaBase !== null &&
        Math.abs(t.linhaBase - cima.linhaBase) <= corpo * 0.2 &&
        t.deslocamento < -corpo * DESLOCAMENTO_MINIMO &&
        sobreposicaoHorizontal(cima, t) >= SOBREPOSICAO_MINIMA_FRACAO,
    );
    if (!baixo) continue;
    consumidos.add(cima);
    consumidos.add(baixo);
    const vizinhoEsquerda = cima.esquerda ?? baixo.esquerda;
    const vizinhoDireita = cima.direita ?? baixo.direita;
    const base = {
      numerador: cima.texto,
      denominador: baixo.texto,
      x: Math.min(cima.x, baixo.x),
      y: cima.linhaBase,
      largura: Math.max(cima.x + cima.largura, baixo.x + baixo.largura) - Math.min(cima.x, baixo.x),
      contextoAntes: vizinhoEsquerda?.texto ?? null,
      contextoDepois: vizinhoDireita?.texto ?? null,
      itensOriginais: [...cima.itens, ...baixo.itens],
    };
    if (!CONTEUDO_SIMPLES.test(cima.texto.replace(/\s+/g, "")) || !CONTEUDO_SIMPLES.test(baixo.texto.replace(/\s+/g, ""))) {
      incertas.push({ ...base, tipo: "fracao", motivo: "fração com conteúdo não trivial" });
      continue;
    }
    expressoes.push({ ...base, tipo: "fracao", partes: [cima.texto, baixo.texto], texto: textoFracao(cima.texto, baixo.texto) });
  }

  for (const t of trechos) {
    if (consumidos.has(t) || t.linhaBase === null) continue;
    const base = {
      x: t.x,
      y: t.linhaBase,
      largura: t.largura,
      contextoAntes: t.esquerda?.texto ?? null,
      contextoDepois: t.direita?.texto ?? null,
      itensOriginais: t.itens,
      partes: [t.texto],
    };
    if (t.deslocamento >= corpo * DESLOCAMENTO_MINIMO_SOBRESCRITO) {
      const convertido = converterPorTabela(t.texto, SOBRESCRITOS) ?? indicadorOrdinal(t.texto, t.esquerda?.texto);
      if (convertido) expressoes.push({ ...base, tipo: "sobrescrito", texto: convertido });
      else incertas.push({ ...base, tipo: "sobrescrito", motivo: `sobrescrito sem representação segura ("${t.texto}")` });
      consumidos.add(t);
    } else if (t.deslocamento <= -corpo * DESLOCAMENTO_MINIMO) {
      const convertido = converterPorTabela(t.texto, SUBSCRITOS);
      if (convertido) expressoes.push({ ...base, tipo: "subscrito", texto: convertido });
      else incertas.push({ ...base, tipo: "subscrito", motivo: `subscrito sem representação segura ("${t.texto}")` });
      consumidos.add(t);
    }
    // Deslocamento pequeno: só uma fonte menor na própria linha (sigla,
    // símbolo) — não é expressão, fica como está.
  }

  const originaisSubstituidos = new Set(expressoes.flatMap((e) => e.itensOriginais));
  const itensReconstruidos = [
    ...itens.filter((i) => !originaisSubstituidos.has(i)),
    ...expressoes.map((e) => ({ texto: e.texto, x: e.x, y: e.y, largura: e.largura, altura: corpo, sintetico: e.tipo })),
  ];

  const limpar = ({ itensOriginais, ...resto }) => resto;
  return { expressoes: expressoes.map(limpar), incertas: incertas.map(limpar), itens: itensReconstruidos };
}

// Expressões incertas/não aplicadas de uma página no formato de alerta
// que extrairQuestoes.mjs propaga para as questões daquela página.
export function alertasDeExpressao(numeroPagina, expressoes) {
  return expressoes.map((e) => ({
    tipo: "expressao_incerta",
    pagina: numeroPagina,
    motivo: e.motivo,
    contexto: [e.contextoAntes, ...(e.partes ?? [e.numerador, e.denominador]), e.contextoDepois].filter(Boolean).join(" "),
  }));
}

function escaparRegex(texto) {
  return texto.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

// Aplica as expressões detectadas ao texto LINEAR da mesma página: a
// forma linearizada (partes separadas por espaço/quebra de linha) só é
// substituída quando aparece EXATAMENTE uma vez entre os mesmos vizinhos
// de corpo normal — qualquer outra situação vira "nao_aplicada" (revisão
// manual), nunca uma substituição por aproximação.
export function aplicarExpressoesAoTexto(texto, expressoes) {
  let resultado = texto;
  const aplicadas = [];
  const naoAplicadas = [];
  for (const expressao of expressoes) {
    const antes = expressao.contextoAntes ? escaparRegex(expressao.contextoAntes.trim().slice(-8)) : "";
    const depois = expressao.contextoDepois ? escaparRegex(expressao.contextoDepois.trim().slice(0, 4)) : "";
    if (!antes && !depois) {
      naoAplicadas.push({ ...expressao, motivo: "sem vizinho de corpo normal para localizar a expressão no texto" });
      continue;
    }
    const miolo = expressao.partes.map(escaparRegex).join("[ \\t]*\\n?[ \\t]*");
    const padrao = new RegExp(`(${antes}[ \\t]*\\n?[ \\t]*)(${miolo})(?=[ \\t]*\\n?[ \\t]*${depois})`, "g");
    const ocorrencias = [...resultado.matchAll(padrao)];
    if (ocorrencias.length !== 1) {
      naoAplicadas.push({ ...expressao, motivo: `forma linear encontrada ${ocorrencias.length} vez(es) — esperado exatamente 1` });
      continue;
    }
    const [ocorrencia] = ocorrencias;
    const inicio = ocorrencia.index + ocorrencia[1].length;
    resultado = resultado.slice(0, inicio) + expressao.texto + resultado.slice(inicio + ocorrencia[2].length);
    aplicadas.push(expressao);
  }
  return { texto: resultado, aplicadas, naoAplicadas };
}
