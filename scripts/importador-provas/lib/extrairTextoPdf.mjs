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
import { comprimentoDaSequenciaDeQuestoes, extrairQuestoesDoTexto } from "./extrairQuestoes.mjs";
import { compararQuestoes } from "./integridade.mjs";

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
      const { expressoes, incertas, itens } = detectarExpressoes(paginasDeItens[i]?.itens ?? [], paginasDeItens[i]?.regras ?? []);
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
  // Ordem linear do PDF que não segue a ordem visual (checado numa prova
  // real: Fundatec/GM Porto Alegre 2025, 1 coluna, questões saindo
  // 1, 4, 2, 5, 3...): a leitura geométrica de 1 coluna só substitui a
  // linear quando recupera uma sequência de questões MAIOR — empate fica
  // com o caminho linear já validado.
  const linear = await extrairTextoPdfLinear(caminhoArquivoOuBuffer);
  const umaColuna = await extrairTextoPdfPosicionado(caminhoArquivoOuBuffer, { umaColuna: true });
  const sequenciaGeometrica = comprimentoDaSequenciaDeQuestoes(umaColuna.paginas);
  const sequenciaLinear = comprimentoDaSequenciaDeQuestoes(linear.paginas);
  const geometrica = { ...umaColuna, estrategiaEscolhida: "posicional-1-coluna", leituraAlternativa: { estrategia: "linear", paginas: linear.paginas } };
  if (sequenciaGeometrica > sequenciaLinear) return geometrica;
  // Empate: a ordem do stream do PDF pode divergir da ordem visual SEM
  // perder nenhuma questão — uma linha do fim do enunciado saindo depois da
  // alternativa E da questão anterior (checado numa prova real: Fundatec/GM
  // Sant'Ana do Livramento 2025, 7 questões). Quando TODA diferença entre as
  // duas leituras é só de ordem (as mesmas linhas, ver integridade.mjs), a
  // posição na página decide; leituras idênticas ou com diferença de
  // conteúdo continuam no caminho linear já validado.
  if (sequenciaGeometrica === sequenciaLinear && sequenciaLinear > 0) {
    const comparacao = [...compararQuestoes(extrairQuestoesDoTexto(umaColuna.paginas).questoes, extrairQuestoesDoTexto(linear.paginas).questoes).values()];
    if (comparacao.some((c) => c.tipo === "reordenada") && comparacao.every((c) => c.tipo !== "divergente")) return geometrica;
  }
  return { ...linear, estrategiaEscolhida: "linear", leituraAlternativa: { estrategia: "posicional-1-coluna", paginas: umaColuna.paginas } };
}

export async function extrairTextoPdf(caminhoArquivoOuBuffer, opcoes = {}) {
  const estrategia = opcoes.estrategia ?? "linear";
  if (estrategia === "linear") return extrairTextoPdfLinear(caminhoArquivoOuBuffer);
  if (estrategia === "posicional") return extrairTextoPdfPosicionado(caminhoArquivoOuBuffer, opcoes);
  if (estrategia === "auto") return extrairTextoPdfAuto(caminhoArquivoOuBuffer);
  throw new Error(`Estratégia de extração de PDF desconhecida: "${estrategia}" (use "linear", "posicional" ou "auto")`);
}
