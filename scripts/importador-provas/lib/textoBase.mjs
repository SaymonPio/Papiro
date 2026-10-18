// Texto-base compartilhado (texto de apoio de várias questões) — o schema
// atual do Papiro não tem estrutura relacional para isso (questoes só tem
// enunciado/alternativas; nenhuma tabela de textos), e o legado já guarda
// questões de interpretação AUTOSSUFICIENTES, com o texto incorporado ao
// próprio enunciado (ex.: linhas numeradas "[01] ..."). Este módulo segue
// a mesma convenção: o texto é incorporado ao enunciado persistido só das
// questões que dependem dele, preservando as quebras de linha e a
// numeração de linhas impressa (questões citam "l. 34-35").
//
// Nada aqui decide sozinho que uma questão é importável: quando a
// dependência não é clara, ou o texto não pôde ser reconstruído com
// fidelidade, a questão é marcada para revisão manual.

import { normalizarTexto } from "./deduplicar.mjs";
import { candidatosPorProximidadeVertical, textoDaLinha } from "./extrairTextoPdfPosicionado.mjs";

// "texto"/"textos N" (nunca a expressão técnica "texto-base").
const REFERENCIA_TEXTO = /\btextos?\b(?![ \t]*-[ \t]*base)/i;
const REFERENCIA_TEXTO_NUMERADO = /\btextos?[ \t\n]+((?:\d{1,2}|[IVX]{1,4})(?:[ \t\n]*(?:,|e)[ \t\n]*(?:\d{1,2}|[IVX]{1,4}))*)\b/gi;
const REFERENCIA_LINHA = /(?:\bl\.|\bls\.|\blinhas?\b)[ \t\n]*\d{1,3}/i;
const REFERENCIA_INDIRETA = /\b(?:trechos?|fragmentos?|excertos?|passagem|par[áa]grafos?|supracitad[oa]s?|(?:segundo|para|conforme|de acordo com)[ \t\n]+(?:o|a)[ \t\n]+autor(?:a)?)\b/i;

const ROMANOS = { I: 1, V: 5, X: 10 };
function romanoParaNumero(romano) {
  let total = 0;
  for (let i = 0; i < romano.length; i++) {
    const valor = ROMANOS[romano[i]];
    const proximo = ROMANOS[romano[i + 1]] ?? 0;
    total += valor < proximo ? -valor : valor;
  }
  return total;
}

export function referenciasAoTexto(texto) {
  const numeros = new Set();
  for (const match of (texto ?? "").matchAll(REFERENCIA_TEXTO_NUMERADO)) {
    for (const parte of match[1].split(/[ \t\n]*(?:,|e)[ \t\n]*/)) {
      if (/^\d+$/.test(parte)) numeros.add(Number(parte));
      else if (/^[IVX]+$/.test(parte)) numeros.add(romanoParaNumero(parte));
    }
  }
  return {
    numeros,
    texto: REFERENCIA_TEXTO.test(texto ?? ""),
    linhas: REFERENCIA_LINHA.test(texto ?? ""),
    indireta: REFERENCIA_INDIRETA.test(texto ?? ""),
  };
}

// "Para responder às questões 07 e 08, considere..." / "Leia o texto a
// seguir para responder às questões de 1 a 5." — bloco de apoio com
// faixa DECLARADA pela própria prova (checado numa prova real: Fundatec/
// PP-RS 2026, entre a alternativa E da questão 6 e a questão 7).
const BLOCO_DE_APOIO = /^[ \t]*(?:aten[çc][ãa]o[ \t]*:?[ \t]*)?[^\n]{0,80}?\bresponder\b[^\n]{0,30}?\bquest(?:ão|ões|ao|oes)\b[ \t]*(?:de[ \t]+)?(?:n[úu]meros?[ \t]+|n[º°o.]+[ \t]*)?(\d{1,3}(?:[ \t]*(?:,|e|a|até|-|–)[ \t]*\d{1,3})*)/gim;

export function encontrarBlocosDeApoio(trecho) {
  const blocos = [];
  for (const match of trecho.matchAll(BLOCO_DE_APOIO)) {
    const numeros = new Set();
    const partes = match[1].split(/[ \t]*(,|e|a|até|-|–)[ \t]*/);
    for (let i = 0; i < partes.length; i += 2) {
      const numero = Number(partes[i]);
      const separador = partes[i - 1];
      if (separador && /^(?:a|até|-|–)$/.test(separador)) {
        const anterior = Number(partes[i - 2]);
        for (let n = anterior; n <= numero && n - anterior <= 50; n++) numeros.add(n);
      } else {
        numeros.add(numero);
      }
    }
    blocos.push({ offset: match.index + match[0].search(/\S/), numeros });
  }
  return blocos;
}

function multiconjunto(tokens) {
  const mapa = new Map();
  for (const t of tokens) mapa.set(t, (mapa.get(t) ?? 0) + 1);
  return mapa;
}

function tokens(texto) {
  return normalizarTexto(texto).split(" ").filter(Boolean);
}

const FATOR_LACUNA_INTERNA = 2.5; // mesma régua da reconstrução posicional ("\t")
const MINIMO_LINHAS_NUMERADAS = 5;

// Reconstrói o texto-base pela GEOMETRIA da página (linhas por Y, itens
// por X) e confere com o texto linear da mesma região: as duas versões
// precisam ter exatamente o mesmo multiconjunto de palavras — senão a
// reconstrução é recusada (confiavel=false) e a questão vai para revisão.
// Motivo (checado numa prova real: Fundatec/PP-RS 2026): a ordem linear
// do pdf-parse trocava uma linha do texto de lugar e soltava a numeração
// de linhas (01..49) num bloco separado, antes do texto.
//
// segmentos: [{ texto (linear, da região nesta página), itens|null }].
export function reconstruirTextoBase(segmentos) {
  const textoLinear = segmentos.map((s) => s.texto.trim()).filter(Boolean).join("\n");
  if (segmentos.some((s) => !Array.isArray(s.itens) || s.itens.length === 0)) {
    return { texto: textoLinear, geometrico: false, confiavel: true, motivo: null };
  }

  const restante = multiconjunto(tokens(textoLinear));
  const linhasSelecionadas = [];
  for (const segmento of segmentos) {
    const linhas = candidatosPorProximidadeVertical(segmento.itens.filter((i) => i.texto.length > 0)).sort((a, b) => b.y - a.y);
    const indices = [];
    for (const [indice, linha] of linhas.entries()) {
      // Juntar pela distância real entre itens (textoDaLinha): o PDF quebra
      // palavras em itens ("autoss" + "abotagem").
      const daLinha = multiconjunto(tokens(textoDaLinha(linha.itens)));
      if (daLinha.size === 0) continue;
      if (![...daLinha].every(([t, n]) => (restante.get(t) ?? 0) >= n)) continue;
      for (const [t, n] of daLinha) restante.set(t, restante.get(t) - n);
      indices.push(indice);
      linhasSelecionadas.push(linha);
    }
    if (indices.length > 0 && indices.at(-1) - indices[0] + 1 !== indices.length) {
      return { texto: textoLinear, geometrico: false, confiavel: false, motivo: "linhas do texto-base não são contíguas na página" };
    }
  }
  if ([...restante.values()].some((n) => n !== 0)) {
    return { texto: textoLinear, geometrico: false, confiavel: false, motivo: "reconstrução geométrica não reproduz as mesmas palavras do texto linear" };
  }

  // Numeração de linhas na margem: primeiro item só com número, afastado
  // do resto da linha, formando uma sequência +1 em +1.
  const numeracao = linhasSelecionadas.map((linha) => {
    const [primeiro, segundo] = linha.itens.filter((i) => i.texto.trim());
    if (!primeiro || !segundo || !/^\d{1,3}$/.test(primeiro.texto.trim())) return null;
    const lacuna = segundo.x - (primeiro.x + primeiro.largura);
    // Espaço entre palavras fica abaixo de ~0,4 da altura; a margem da
    // numeração, acima de 1 altura (checado: 1,3 nas linhas sem recuo de
    // parágrafo, 3,8 nas com recuo).
    return lacuna >= Math.max(primeiro.altura, 1) ? Number(primeiro.texto.trim()) : null;
  });
  const numeradas = numeracao.filter((n) => n !== null);
  const sequencial = numeradas.length >= MINIMO_LINHAS_NUMERADAS && numeradas.every((n, i) => i === 0 || n === numeradas[i - 1] + 1);

  // Parágrafo = linha recuada em relação à margem mais comum do texto
  // (questões citam "primeiro parágrafo", "parágrafo anterior"); vira uma
  // linha em branco antes dele, assim como a transição entre o bloco de
  // linhas numeradas e o título/fonte não numerados.
  const inicioDoConteudo = linhasSelecionadas.map((linha, i) => {
    const visiveis = linha.itens.filter((it) => it.texto.trim());
    const primeiro = sequencial && numeracao[i] !== null ? visiveis[1] : visiveis[0];
    return primeiro ? { x: primeiro.x, altura: Math.max(primeiro.altura, 1) } : null;
  });
  const frequencia = new Map();
  for (const inicio of inicioDoConteudo) if (inicio) frequencia.set(Math.round(inicio.x), (frequencia.get(Math.round(inicio.x)) ?? 0) + 1);
  const margem = [...frequencia].sort((a, b) => b[1] - a[1])[0]?.[0] ?? null;
  const iniciaParagrafo = (i) => {
    if (i === 0) return false;
    if (sequencial && (numeracao[i] !== null) !== (numeracao[i - 1] !== null)) return true;
    const inicio = inicioDoConteudo[i];
    return Boolean(sequencial && numeracao[i] !== null && inicio && margem !== null && inicio.x - margem >= inicio.altura);
  };

  const saida = [];
  for (const [i, linha] of linhasSelecionadas.entries()) {
    if (iniciaParagrafo(i)) saida.push("");
    const visiveis = linha.itens.filter((it) => it.texto.trim());
    const conteudo = sequencial && numeracao[i] !== null ? visiveis.slice(1) : visiveis;
    for (let k = 1; k < conteudo.length; k++) {
      if (conteudo[k].x - (conteudo[k - 1].x + conteudo[k - 1].largura) >= Math.max(conteudo[k - 1].altura, 1) * FATOR_LACUNA_INTERNA) {
        return { texto: textoLinear, geometrico: false, confiavel: false, motivo: "linha do texto-base com lacuna horizontal interna (possível multicoluna)" };
      }
    }
    let itensDoConteudo = linha.itens;
    if (sequencial && numeracao[i] !== null) {
      itensDoConteudo = itensDoConteudo.slice(itensDoConteudo.indexOf(visiveis[0]) + 1);
      while (itensDoConteudo.length > 0 && !itensDoConteudo[0].texto.trim()) itensDoConteudo = itensDoConteudo.slice(1);
    }
    const texto = textoDaLinha(itensDoConteudo).trim();
    saida.push(sequencial && numeracao[i] !== null ? `[${visiveis[0].texto.trim()}] ${texto}` : texto);
  }
  return { texto: saida.join("\n"), geometrico: true, confiavel: true, motivo: null, linhasNumeradas: sequencial };
}

export function comporEnunciado(textos, comando) {
  const blocos = textos.map((t) => t.texto.trim()).filter(Boolean);
  return blocos.length === 0 ? comando : `${blocos.join("\n\n")}\n\n${comando}`;
}
