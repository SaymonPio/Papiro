// Extração de texto de PDF orientada por coordenadas X/Y — estratégia
// alternativa a extrairTextoPdf.mjs (que preserva a ordem linear bruta
// do pdf-parse). Usa pdfjs-dist diretamente (já presente via pdf-parse,
// nenhuma biblioteca nova) para ler, por item de texto: texto, posição
// (x, y) e dimensões (largura, altura) — e reconstrói a ordem de leitura
// correta em páginas de múltiplas colunas, algo que a extração linear
// não faz (confirmado numa prova real: FEPESE/PMBC 2014 intercala as
// colunas em granularidade de frase ao linearizar).
//
// Nenhum valor é específico de uma banca — colunas, gaps e tolerâncias
// são detectados a partir da própria distribuição geométrica de cada
// página, nunca de um número fixo como "FEPESE = 2 colunas".

import { readFileSync } from "node:fs";
import { alertasDeExpressao, detectarExpressoes } from "./expressoesPdf.mjs";

// URL local dos arquivos de fonte padrão já instalados junto do
// pdfjs-dist (node_modules/pdfjs-dist/standard_fonts/) — mesmo padrão
// usado internamente pelo pdf-parse (new URL(..., import.meta.url)).
// Sem isto, o pdfjs-dist emite um aviso (não fatal — a extração de
// texto em si já saiu correta nos testes) para todo PDF com fontes não
// embutidas.
const STANDARD_FONT_DATA_URL = new URL("../../../node_modules/pdfjs-dist/standard_fonts/", import.meta.url).href;

const FATOR_TOLERANCIA_LINHA = 0.6; // proporção da altura do item para agrupar em uma linha (mesma linha visual)
const PROPORCAO_GAP_COLUNA = 0.08; // gap horizontal >= 8% da largura da página, entre INÍCIOS de linha, é candidato a fronteira de coluna
const PROPORCAO_FULL_WIDTH = 0.6; // linha ocupando >=60% da largura da página é full-width
const MINIMO_LINHAS_POR_LADO = 2; // confiança alta exige pelo menos isto de linhas-candidatas de cada lado do split
const LIMIAR_DOMINANCIA_GAP = 2; // o maior gap entre inícios de linha precisa ser isto vezes maior que o segundo maior
const FATOR_TAB = 2.5; // gap horizontal >= altura*este fator DENTRO de uma linha já dividida por coluna vira "\t" na reconstrução textual

// Agrupa itens em "linhas-candidatas" só por proximidade vertical — pode
// conter itens de colunas DIFERENTES que coincidem em Y (ex.: o fim de
// um rótulo da coluna esquerda e o início da primeira linha da coluna
// direita, vistos numa prova real nessa mesma altura).
export function candidatosPorProximidadeVertical(itens) {
  const ordenados = [...itens].sort((a, b) => b.y - a.y);
  const candidatos = [];
  for (const item of ordenados) {
    const altura = Math.max(item.altura, 1);
    const existente = candidatos.find((c) => Math.abs(c.y - item.y) <= altura * FATOR_TOLERANCIA_LINHA);
    if (existente) existente.itens.push(item);
    else candidatos.push({ y: item.y, itens: [item] });
  }
  for (const c of candidatos) c.itens.sort((a, b) => a.x - b.x);
  return candidatos;
}

// Agrupa um array de valores x (aqui: só o INÍCIO de cada linha-
// candidata, nunca todo item — um rótulo alinhado mais à direita dentro
// da própria coluna, ex.: "Nome  N questões", não deveria contar como
// início de uma nova coluna) em clusters por gap — generaliza para 1, 2
// ou mais colunas sem nenhum número fixo.
function clustersPorGap(valores, larguraPagina) {
  const ordenados = [...new Set(valores)].sort((a, b) => a - b);
  const gapMinimo = larguraPagina * PROPORCAO_GAP_COLUNA;
  const grupos = [[ordenados[0]]];
  const gapsEncontrados = [];
  for (let i = 1; i < ordenados.length; i++) {
    const gap = ordenados[i] - ordenados[i - 1];
    if (gap >= gapMinimo) {
      grupos.push([]);
      gapsEncontrados.push(gap);
    }
    grupos.at(-1).push(ordenados[i]);
  }
  return {
    clusters: grupos.map((g) => ({ min: Math.min(...g), max: Math.max(...g), tamanho: g.length })),
    gaps: gapsEncontrados,
  };
}

function confiancaDaDeteccao(clusters, gaps) {
  if (clusters.length === 1) return { confidence: "alta", motivo: "nenhum gap significativo entre inícios de linha — página de 1 coluna" };
  const todasComMinimo = clusters.every((c) => c.tamanho >= MINIMO_LINHAS_POR_LADO);
  if (!todasComMinimo) return { confidence: "baixa", motivo: "algum cluster de coluna tem poucas linhas — split pouco confiável" };
  const gapsOrdenados = [...gaps].sort((a, b) => b - a);
  const dominancia = gapsOrdenados.length < 2 ? Infinity : gapsOrdenados[0] / gapsOrdenados[1];
  const confidence = dominancia >= LIMIAR_DOMINANCIA_GAP ? "alta" : "media";
  return { confidence, motivo: `${clusters.length} coluna(s) por gap entre início de linha (dominância ${dominancia === Infinity ? "única" : dominancia.toFixed(2)})` };
}

// Dentro de uma linha-candidata (possivelmente de colunas coincidentes
// em Y), decide os pontos de corte: a coluna "vigente" só muda quando um
// item cai claramente DENTRO da faixa confirmada de outra coluna; um
// item numa zona neutra (ex.: aquele rótulo alinhado à direita dentro da
// própria coluna esquerda) herda a coluna vigente, nunca força uma
// troca. Isso evita que um gap grande DENTRO de uma coluna seja
// confundido com a fronteira real entre colunas.
function dividirCandidatoPorColuna(candidato, clusters, tolerancia) {
  function colunaDoX(x) {
    for (let i = 0; i < clusters.length; i++) {
      if (x >= clusters[i].min - tolerancia && x <= clusters[i].max + tolerancia) return i;
    }
    return null;
  }

  const sublinhas = [];
  let colunaVigente = colunaDoX(candidato.itens[0].x) ?? 0;
  let grupoAtual = [candidato.itens[0]];
  for (let i = 1; i < candidato.itens.length; i++) {
    const colunaDoItem = colunaDoX(candidato.itens[i].x);
    if (colunaDoItem !== null && colunaDoItem !== colunaVigente) {
      sublinhas.push({ itens: grupoAtual, coluna: colunaVigente });
      grupoAtual = [];
      colunaVigente = colunaDoItem;
    }
    grupoAtual.push(candidato.itens[i]);
  }
  sublinhas.push({ itens: grupoAtual, coluna: colunaVigente });
  return sublinhas;
}

export function textoDaLinha(itensDaLinha) {
  let texto = "";
  let fimAnterior = null;
  let alturaAnterior = 10;
  for (const item of itensDaLinha) {
    if (fimAnterior !== null) {
      const gap = item.x - fimAnterior;
      if (gap >= alturaAnterior * FATOR_TAB) texto += "\t";
      else if (gap > alturaAnterior * 0.25 && !texto.endsWith(" ") && !item.texto.startsWith(" ")) texto += " ";
    }
    texto += item.texto;
    fimAnterior = item.x + item.largura;
    alturaAnterior = Math.max(item.altura, 1);
  }
  return texto.replace(/[ \t]+$/g, "");
}

// Monta as linhas finais de uma página a partir de CLUSTERS DE COLUNA JÁ
// CONHECIDOS (ver reconstruirDocumento — agregados de todas as páginas,
// porque um documento de várias páginas reaproveita o mesmo template
// físico de colunas; detectar isso página a página isoladamente é mais
// frágil quando uma página específica amostra poucos pontos de uma
// coluna). Agrupa por Y, divide linhas que coincidem em Y mas são de
// colunas diferentes, marca full-width (linhas largas que não foram
// divididas — um cabeçalho/rodapé real nunca entra na faixa confirmada
// de outra coluna) e devolve na ordem de leitura: trechos full-width na
// posição em que aparecem, trechos em coluna emitidos coluna a coluna
// (esquerda -> direita -> ...), generalizando para qualquer número de
// divisores full-width no meio da página.
function reconstruirPagina(itens, larguraPagina, clusters, tolerancia) {
  const candidatos = candidatosPorProximidadeVertical(itens);

  const linhasDivididas = [];
  for (const candidato of candidatos) {
    const sublinhas = clusters.length > 1 ? dividirCandidatoPorColuna(candidato, clusters, tolerancia) : [{ itens: candidato.itens, coluna: 0 }];
    for (const sub of sublinhas) {
      const xInicio = Math.min(...sub.itens.map((i) => i.x));
      const xFim = Math.max(...sub.itens.map((i) => i.x + i.largura));
      linhasDivididas.push({ y: candidato.y, xInicio, xFim, itens: sub.itens, coluna: sub.coluna });
    }
  }

  const linhasOrdenadas = linhasDivididas.sort((a, b) => b.y - a.y);
  const classificadas = linhasOrdenadas.map((linha) => ({
    linha,
    fullWidth: linha.xFim - linha.xInicio >= larguraPagina * PROPORCAO_FULL_WIDTH,
  }));

  const trechos = [];
  for (const item of classificadas) {
    const tipo = item.fullWidth || clusters.length <= 1 ? "fullwidth" : "coluna";
    const ultimo = trechos.at(-1);
    if (ultimo && ultimo.tipo === tipo) ultimo.linhas.push(item.linha);
    else trechos.push({ tipo, linhas: [item.linha] });
  }

  const linhasFinais = [];
  for (const trecho of trechos) {
    if (trecho.tipo === "fullwidth") {
      linhasFinais.push(...trecho.linhas);
      continue;
    }
    const porColuna = new Map();
    for (const linha of trecho.linhas) {
      if (!porColuna.has(linha.coluna)) porColuna.set(linha.coluna, []);
      porColuna.get(linha.coluna).push(linha);
    }
    for (const coluna of [...porColuna.keys()].sort((a, b) => a - b)) {
      linhasFinais.push(...porColuna.get(coluna));
    }
  }

  return linhasFinais;
}

// Orquestra a detecção de colunas no nível do DOCUMENTO (não de uma
// página isolada): agrupa cada página em linhas-candidatas, reúne os
// inícios de linha de TODAS as páginas (exceto páginas sem conteúdo
// relevante) e detecta clusters uma única vez sobre esse conjunto maior
// — um documento de várias páginas reaproveita o mesmo template físico
// de colunas, então mais dados agregados tornam a fronteira entre
// colunas mais confiável do que analisar cada página isoladamente
// (checado numa prova real: uma página cuja coluna direita amostra só 3
// linhas tinha uma faixa de coluna artificialmente estreita, fazendo um
// texto legitimamente dessa coluna, só um pouco mais indentado, ficar de
// fora da tolerância e ser erroneamente herdado pela coluna esquerda).
// Usa só o início do PRIMEIRO item de cada linha-candidata — é o sinal
// mais limpo de onde as colunas físicas ficam (qualquer início
// "secundário" dentro de uma linha fundida tende a capturar também
// posições de alinhamento interno, como um rótulo "N questões" alinhado
// mais à direita dentro da própria coluna esquerda, e pode "preencher a
// ponte" entre duas colunas reais com pontos intermediários, fundindo-as
// numa só — checado numa prova real). O caso em que DUAS colunas
// coincidem perfeitamente em Y em TODA linha da página nunca apareceu
// nos documentos reais testados; é uma limitação conhecida, não
// corrigida aqui para não arriscar o caso real que já funciona.
function detectarColunasDoDocumento(candidatosPorPagina, larguraPagina) {
  const xIniciosGlobais = candidatosPorPagina.flatMap((candidatos) => candidatos.map((c) => c.itens[0].x));
  const { clusters, gaps } = clustersPorGap(xIniciosGlobais, larguraPagina);
  const deteccao = confiancaDaDeteccao(clusters, gaps);
  const tolerancia = larguraPagina * 0.03;
  return { clusters, deteccao, tolerancia };
}

// Núcleo puro — nenhum I/O de PDF aqui, só a lógica de reconstrução
// geométrica. Recebe os itens já extraídos de cada página
// ({numero, larguraPagina, itens: [{texto,x,y,largura,altura}]}) e
// devolve o texto reconstruído na ordem de leitura correta. Exportado
// separadamente para ser testável com fixtures 100% sintéticas, sem
// precisar gerar nenhum PDF real.
export function reconstruirDocumentoPosicionado(paginasDeItens, opcoes = {}) {
  const debugPorPagina = opcoes.debug ? [] : null;

  const dadosPorPagina = paginasDeItens.map((p) => ({
    numero: p.numero,
    larguraPagina: p.larguraPagina,
    itens: p.itens,
    candidatos: candidatosPorProximidadeVertical(p.itens),
  }));
  const larguraReferencia = Math.max(...dadosPorPagina.map((p) => p.larguraPagina), 0);

  const { clusters, deteccao, tolerancia } = detectarColunasDoDocumento(
    dadosPorPagina.map((p) => p.candidatos),
    larguraReferencia,
  );

  const paginas = [];
  for (const dados of dadosPorPagina) {
    const linhasFinais = reconstruirPagina(dados.itens, dados.larguraPagina, clusters, tolerancia);
    const texto = linhasFinais.map((l) => textoDaLinha(l.itens)).join("\n");

    paginas.push({ numero: dados.numero, texto });
    if (debugPorPagina) {
      debugPorPagina.push({
        pagina: dados.numero,
        larguraPagina: dados.larguraPagina,
        colunas: { ...deteccao, clusters },
        linhas: linhasFinais.map((linha, ordem) => ({
          texto: textoDaLinha(linha.itens),
          y: linha.y,
          xInicio: linha.xInicio,
          xFim: linha.xFim,
          coluna: linha.coluna,
          ordem,
        })),
      });
    }
  }

  const totalCaracteres = paginas.reduce((soma, p) => soma + p.texto.trim().length, 0);
  const mediaCaracteresPorPagina = paginas.length > 0 ? totalCaracteres / paginas.length : 0;
  const requerOcr = mediaCaracteresPorPagina < 20;

  return {
    totalPaginas: paginas.length,
    paginas,
    mediaCaracteresPorPagina,
    requerOcr,
    // Resumo da detecção de colunas no nível do documento — sempre
    // presente (não só em modo debug), para permitir que a estratégia
    // "auto" (extrairTextoPdf.mjs) decida entre linear/posicional sem
    // precisar reprocessar nada.
    deteccaoColunas: { ...deteccao, totalColunas: clusters.length },
    ...(debugPorPagina ? { debug: debugPorPagina } : {}),
  };
}

// Camada de I/O — abre o PDF real via pdfjs-dist e extrai os itens de
// texto (com posição) de cada página. Também usada pela estratégia
// linear, que precisa da geometria para expressões e textos-base.
export async function lerItensDoPdf(caminhoArquivoOuBuffer) {
  const pdfjsLib = await import("pdfjs-dist/legacy/build/pdf.mjs");
  const dados = typeof caminhoArquivoOuBuffer === "string" ? readFileSync(caminhoArquivoOuBuffer) : caminhoArquivoOuBuffer;

  const doc = await pdfjsLib.getDocument({
    data: new Uint8Array(dados),
    useWorkerFetch: false,
    isEvalSupported: false,
    disableFontFace: true,
    standardFontDataUrl: STANDARD_FONT_DATA_URL,
  }).promise;

  const paginasDeItens = [];
  for (let numero = 1; numero <= doc.numPages; numero++) {
    const pagina = await doc.getPage(numero);
    const viewport = pagina.getViewport({ scale: 1 });
    const conteudo = await pagina.getTextContent();

    const itens = conteudo.items
      .filter((item) => typeof item.str === "string" && item.str.length > 0)
      .map((item) => ({
        texto: item.str,
        x: item.transform[4],
        y: item.transform[5],
        largura: item.width,
        altura: item.height || 10,
      }));

    paginasDeItens.push({ numero, larguraPagina: viewport.width, itens });
  }

  await doc.destroy();
  return paginasDeItens;
}

// Expressões posicionais (fração empilhada, sobrescrito, subscrito) são
// fundidas num item só ANTES do agrupamento em linhas — sem isso o
// numerador e o denominador caem em linhas diferentes.
export async function extrairTextoPdfPosicionado(caminhoArquivoOuBuffer, opcoes = {}) {
  const paginasDeItens = await lerItensDoPdf(caminhoArquivoOuBuffer);
  const expressoesPorPagina = paginasDeItens.map((p) => {
    const { expressoes, incertas, itens } = detectarExpressoes(p.itens);
    p.itens = itens;
    return { expressoes, incertas };
  });
  const resultado = reconstruirDocumentoPosicionado(paginasDeItens, opcoes);
  resultado.paginas = resultado.paginas.map((pagina, i) => ({
    ...pagina,
    expressoes: expressoesPorPagina[i].expressoes,
    alertas: alertasDeExpressao(pagina.numero, expressoesPorPagina[i].incertas),
  }));
  return resultado;
}
