import assert from "node:assert/strict";
import test from "node:test";
import { extrairTextoPdf } from "../scripts/importador-provas/lib/extrairTextoPdf.mjs";

// PAPIRO — PoC do importador de provas: camada de extração de texto do
// PDF (pdf-parse). Usa PDFs sintéticos minúsculos, construídos à mão só
// para este teste (string de exemplo genérica, "QUESTAO 1 ..." — nenhum
// conteúdo real de prova/QConcursos).
//
// Escapa parênteses/barras do texto dentro do content stream PDF (regra
// do formato: "(", ")" e "\" precisam ser escapados dentro de uma string
// literal PDF) — só relevante para o texto de teste em si, não para a
// lógica do importador.
function escaparTextoPdf(texto) {
  return texto.replace(/\\/g, "\\\\").replace(/\(/g, "\\(").replace(/\)/g, "\\)");
}

function construirPdfMinimo(textosPorPagina) {
  const objetos = [];
  const indiceCatalogo = 1;
  const indicePaginas = 2;
  const primeiraPaginaIndice = 3;
  const totalPaginas = textosPorPagina.length;
  // Layout de índices: 1=Catalog, 2=Pages, depois para cada página i
  // (0-based): página = 3 + i*3, fonte = 4 + i*3, conteúdo = 5 + i*3.
  const kids = textosPorPagina.map((_, i) => `${primeiraPaginaIndice + i * 3} 0 R`).join(" ");

  objetos.push(`<< /Type /Catalog /Pages ${indicePaginas} 0 R >>`);
  objetos.push(`<< /Type /Pages /Kids [${kids}] /Count ${totalPaginas} >>`);

  for (const texto of textosPorPagina) {
    const paginaObjIndex = objetos.length + 1;
    const fonteObjIndex = paginaObjIndex + 1;
    const conteudoObjIndex = paginaObjIndex + 2;
    const linhas = texto.split("\n");
    const streamPartes = linhas.map((linha, i) => `${i === 0 ? "72 712" : "0 -16"} Td (${escaparTextoPdf(linha)}) Tj`);
    const content = `BT /F1 12 Tf ${streamPartes.join(" ")} ET`;
    objetos.push(
      `<< /Type /Page /Parent ${indicePaginas} 0 R /Resources << /Font << /F1 ${fonteObjIndex} 0 R >> >> /MediaBox [0 0 612 792] /Contents ${conteudoObjIndex} 0 R >>`,
    );
    objetos.push("<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>");
    objetos.push(`<< /Length ${content.length} >>\nstream\n${content}\nendstream`);
  }

  let pdf = "%PDF-1.4\n";
  const offsets = [];
  objetos.forEach((objeto, i) => {
    offsets.push(pdf.length);
    pdf += `${i + 1} 0 obj\n${objeto}\nendobj\n`;
  });
  const xrefStart = pdf.length;
  pdf += `xref\n0 ${objetos.length + 1}\n0000000000 65535 f \n`;
  offsets.forEach((offset) => {
    pdf += `${String(offset).padStart(10, "0")} 00000 n \n`;
  });
  pdf += `trailer\n<< /Size ${objetos.length + 1} /Root ${indiceCatalogo} 0 R >>\nstartxref\n${xrefStart}\n%%EOF`;
  return Buffer.from(pdf, "latin1");
}

function construirPdfSemTexto() {
  // Página válida mas sem nenhum content stream de texto — simula um PDF
  // escaneado (só imagem, sem camada de texto extraível).
  const objetos = [
    "<< /Type /Catalog /Pages 2 0 R >>",
    "<< /Type /Pages /Kids [3 0 R] /Count 1 >>",
    "<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Contents 4 0 R >>",
    "<< /Length 0 >>\nstream\n\nendstream",
  ];
  let pdf = "%PDF-1.4\n";
  const offsets = [];
  objetos.forEach((objeto, i) => {
    offsets.push(pdf.length);
    pdf += `${i + 1} 0 obj\n${objeto}\nendobj\n`;
  });
  const xrefStart = pdf.length;
  pdf += `xref\n0 ${objetos.length + 1}\n0000000000 65535 f \n`;
  offsets.forEach((offset) => {
    pdf += `${String(offset).padStart(10, "0")} 00000 n \n`;
  });
  pdf += `trailer\n<< /Size ${objetos.length + 1} /Root 1 0 R >>\nstartxref\n${xrefStart}\n%%EOF`;
  return Buffer.from(pdf, "latin1");
}

test("A) extrai texto de um PDF textual sintético de 1 página", async () => {
  const buffer = construirPdfMinimo(["QUESTAO 1 Isto e um teste sintetico de extracao."]);
  const resultado = await extrairTextoPdf(buffer);
  assert.equal(resultado.totalPaginas, 1);
  assert.equal(resultado.paginas.length, 1);
  assert.match(resultado.paginas[0].texto, /QUESTAO 1 Isto e um teste sintetico de extracao\./);
  assert.equal(resultado.requerOcr, false);
});

test("B) extrai texto de um PDF textual sintético de 2 páginas, preservando a separação por página", async () => {
  const buffer = construirPdfMinimo(["Conteudo da pagina um.", "Conteudo da pagina dois."]);
  const resultado = await extrairTextoPdf(buffer);
  assert.equal(resultado.totalPaginas, 2);
  assert.match(resultado.paginas[0].texto, /pagina um/);
  assert.match(resultado.paginas[1].texto, /pagina dois/);
  assert.equal(resultado.paginas[0].numero, 1);
  assert.equal(resultado.paginas[1].numero, 2);
});

test("C) PDF sem camada de texto (simulando escaneado) é marcado requerOcr=true, sem tentar OCR", async () => {
  const buffer = construirPdfSemTexto();
  const resultado = await extrairTextoPdf(buffer);
  assert.equal(resultado.requerOcr, true);
  assert.equal(resultado.paginas[0].texto.trim(), "");
});
