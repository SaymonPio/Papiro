import assert from "node:assert/strict";
import test from "node:test";
import { extrairDocumentosDoHtml } from "../scripts/importador-provas/collectors/fepese/lib/parseHtml.mjs";

// PAPIRO — Coletor FEPESE: parsing da listagem de documentos.
// Fixture 100% sintética, mas na MESMA estrutura HTML real confirmada em
// guardabc.fepese.org.br (2026-10-17): <a href="?go=download&arquivo=
// NOME.pdf" class="inscricao"><b>RÓTULO</b>[<br>CARGO]</a>. Nenhum nome
// de arquivo ou texto real de concurso foi copiado — só o PADRÃO.

const BASE_URL = "https://exemplo-concurso.fepese.org.br/";

function paginaDeExemplo() {
  return `
    <html><body>
    <table>
      <tr><td><a href="?go=download&arquivo=Edital_001_2020.pdf" class="inscricao"><b>Edital</b></a></td></tr>
      <tr><td><a href="?go=download&arquivo=Gabarito_Definitivo_XY.pdf" class="inscricao"><b>Gabarito Definitivo</b></a></td></tr>
      <tr><td><a href="?go=download&arquivo=Gabarito_Provisorio_XY.pdf" class="inscricao"><b>Gabarito Provisório</b></a></td></tr>
      <tr><td><a href="?go=download&arquivo=XY_Cargo_Exemplo.pdf" class="inscricao"><b>Prova</b><br>Cargo Exemplo</a></td></tr>
      <tr><td><a href="?go=download&arquivo=ZZ_Outro_Cargo.pdf" class="inscricao"><b>Prova</b><br>Outro Cargo</a></td></tr>
    </table>
    </body></html>
  `;
}

test("A) reconhece documento tipo 'prova' com cargo (texto depois do <br>)", () => {
  const documentos = extrairDocumentosDoHtml(paginaDeExemplo(), BASE_URL);
  const prova = documentos.find((d) => d.arquivo === "XY_Cargo_Exemplo.pdf");
  assert.equal(prova.tipo, "prova");
  assert.equal(prova.cargo, "Cargo Exemplo");
  assert.equal(prova.rotulo, "Prova Cargo Exemplo");
});

test("B) reconhece documento tipo 'gabarito' — nunca atribui cargo a gabarito (rótulo real nunca menciona cargo)", () => {
  const documentos = extrairDocumentosDoHtml(paginaDeExemplo(), BASE_URL);
  const gabarito = documentos.find((d) => d.arquivo === "Gabarito_Definitivo_XY.pdf");
  assert.equal(gabarito.tipo, "gabarito");
  assert.equal(gabarito.cargo, null);
});

test("C) documento que não começa com 'Prova'/'Gabarito' (ex.: Edital) vira tipo 'outro'", () => {
  const documentos = extrairDocumentosDoHtml(paginaDeExemplo(), BASE_URL);
  const edital = documentos.find((d) => d.arquivo === "Edital_001_2020.pdf");
  assert.equal(edital.tipo, "outro");
});

test("D) URL final é absoluta, resolvida contra a base do concurso", () => {
  const documentos = extrairDocumentosDoHtml(paginaDeExemplo(), BASE_URL);
  const prova = documentos.find((d) => d.arquivo === "XY_Cargo_Exemplo.pdf");
  assert.equal(prova.url, "https://exemplo-concurso.fepese.org.br/?go=download&arquivo=XY_Cargo_Exemplo.pdf");
});

test("E) concurso com múltiplos cargos: cada prova listada separadamente, cada uma com seu próprio cargo", () => {
  const documentos = extrairDocumentosDoHtml(paginaDeExemplo(), BASE_URL);
  const provas = documentos.filter((d) => d.tipo === "prova");
  assert.equal(provas.length, 2);
  assert.deepEqual(provas.map((p) => p.cargo), ["Cargo Exemplo", "Outro Cargo"]);
});

test("F) nome de arquivo com espaço literal (visto no real: 'Gabarito GM BC_definitivo.pdf') é preservado corretamente", () => {
  const html = `<a href="?go=download&arquivo=Gabarito XY Z_definitivo.pdf" class="inscricao"><b>Gabarito Definitivo</b></a>`;
  const documentos = extrairDocumentosDoHtml(html, BASE_URL);
  assert.equal(documentos[0].arquivo, "Gabarito XY Z_definitivo.pdf");
});

test("G) página sem nenhum link de documento devolve lista vazia, nunca lança erro", () => {
  const documentos = extrairDocumentosDoHtml("<html><body>sem documentos aqui</body></html>", BASE_URL);
  assert.deepEqual(documentos, []);
});

test("H) href malformado é ignorado silenciosamente, nunca quebra a extração dos outros links", () => {
  const html = `
    <a href="?go=download&arquivo=Valido.pdf" class="inscricao"><b>Prova</b><br>Cargo A</a>
    <a href="://invalido" class="inscricao"><b>Prova</b><br>Cargo B</a>
  `;
  const documentos = extrairDocumentosDoHtml(html, BASE_URL);
  assert.equal(documentos.length, 1);
  assert.equal(documentos[0].arquivo, "Valido.pdf");
});
