// Camada fina sobre pdf-parse (PDFParse.getText) — estratégia "linear":
// preserva a ordem bruta em que o pdf-parse entrega o texto (correta
// para PDFs de 1 coluna; confirmado que embaralha PDFs de 2+ colunas em
// granularidade de frase — ver extrairTextoPdfPosicionado.mjs para a
// estratégia alternativa, orientada por coordenadas X/Y).
//
// Tudo que vem depois (extrairQuestoes, extrairGabarito) opera só sobre
// texto já extraído, puro e testável sem nenhum PDF real — nenhuma das
// duas estratégias muda esse contrato: ambas devolvem
// { totalPaginas, paginas: [{numero, texto}], mediaCaracteresPorPagina, requerOcr }.
//
// Heurística requer_ocr: PDFs escaneados (sem camada de texto) devolvem
// páginas vazias ou quase vazias em QUALQUER estratégia — nunca tentamos
// OCR aqui (decisão explícita do produto), só marcamos a página/
// documento para revisão manual futura.

import { PDFParse } from "pdf-parse";
import { extrairTextoPdfPosicionado, lerItensDoPdf } from "./extrairTextoPdfPosicionado.mjs";
import { alertasDeExpressao, aplicarExpressoesAoTexto, detectarExpressoes } from "./expressoesPdf.mjs";

const MEDIA_MINIMA_CARACTERES_POR_PAGINA = 20;

async function extrairTextoPdfLinear(caminhoArquivoOuBuffer) {
  const dados =
    typeof caminhoArquivoOuBuffer === "string"
      ? (await import("node:fs")).readFileSync(caminhoArquivoOuBuffer)
      : caminhoArquivoOuBuffer;

  const parser = new PDFParse({ data: dados });
  try {
    const resultado = await parser.getText();
    // A geometria (itens X/Y) acompanha cada página: as expressões
    // posicionais são aplicadas ao texto linear, e os itens servem à
    // reconstrução de textos-base (extrairQuestoes.mjs). Uma expressão
    // detectada que não pôde ser localizada no texto linear vira alerta
    // da página — nunca texto alterado por aproximação.
    const paginasDeItens = await lerItensDoPdf(dados);
    const paginas = resultado.pages.map((pagina, i) => {
      const { expressoes, incertas, itens } = detectarExpressoes(paginasDeItens[i]?.itens ?? []);
      const { texto, aplicadas, naoAplicadas } = aplicarExpressoesAoTexto(pagina.text ?? "", expressoes);
      return { numero: pagina.num, texto, itens, expressoes: aplicadas, alertas: alertasDeExpressao(pagina.num, [...incertas, ...naoAplicadas]) };
    });

    const totalCaracteres = paginas.reduce((soma, p) => soma + p.texto.trim().length, 0);
    const mediaCaracteresPorPagina = paginas.length > 0 ? totalCaracteres / paginas.length : 0;
    const requerOcr = mediaCaracteresPorPagina < MEDIA_MINIMA_CARACTERES_POR_PAGINA;

    return {
      totalPaginas: resultado.total,
      paginas,
      mediaCaracteresPorPagina,
      requerOcr,
    };
  } finally {
    await parser.destroy();
  }
}

// "auto": decide entre linear/posicional a partir da própria estrutura
// geométrica do documento — nunca por banca. Roda a detecção de colunas
// (parte do próprio extrairTextoPdfPosicionado, custo baixo) e só usa a
// reconstrução posicional quando o documento é CONFIANTEMENTE
// multicoluna (2+ colunas, confidence "alta"); em qualquer outro caso
// (1 coluna, ou confidence "media"/"baixa") usa a estratégia linear já
// validada — "se a confiança for baixa, não adivinhar" aplicado aqui
// como "prefira o caminho já comprovado em vez de arriscar o novo".
async function extrairTextoPdfAuto(caminhoArquivoOuBuffer) {
  const resultadoPosicional = await extrairTextoPdfPosicionado(caminhoArquivoOuBuffer);
  const { totalColunas, confidence } = resultadoPosicional.deteccaoColunas;

  if (totalColunas > 1 && confidence === "alta") {
    return resultadoPosicional;
  }
  return extrairTextoPdfLinear(caminhoArquivoOuBuffer);
}

export async function extrairTextoPdf(caminhoArquivoOuBuffer, opcoes = {}) {
  const estrategia = opcoes.estrategia ?? "linear";
  if (estrategia === "linear") return extrairTextoPdfLinear(caminhoArquivoOuBuffer);
  if (estrategia === "posicional") return extrairTextoPdfPosicionado(caminhoArquivoOuBuffer, opcoes);
  if (estrategia === "auto") return extrairTextoPdfAuto(caminhoArquivoOuBuffer);
  throw new Error(`Estratégia de extração de PDF desconhecida: "${estrategia}" (use "linear", "posicional" ou "auto")`);
}
