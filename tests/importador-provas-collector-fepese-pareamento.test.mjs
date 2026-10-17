import assert from "node:assert/strict";
import test from "node:test";
import { casarProvaComGabarito, tokenizarNomeArquivo } from "../scripts/importador-provas/collectors/fepese/lib/pareamento.mjs";

// PAPIRO — Coletor FEPESE: pareamento prova <-> gabarito. Regra
// inegociável: nunca parear só por ano/concurso. Casos sintéticos
// baseados no padrão REAL de nomenclatura observado em guardabc.fepese.
// org.br (prefixo de cargo compartilhado entre prova e gabarito), mas
// com nomes de concurso/cargo fictícios.

function doc(tipo, arquivo, rotulo, cargo = null) {
  return { tipo, arquivo, rotulo, cargo, url: `https://exemplo.fepese.org.br/?go=download&arquivo=${arquivo}` };
}

test("A) concurso com uma prova e um gabarito, nomes claramente relacionados -> confidence alta", () => {
  const documentos = [
    doc("prova", "GM_Guarda_Municipal.pdf", "Prova Guarda Municipal", "Guarda Municipal"),
    doc("gabarito", "Gabarito_GM_definitivo.pdf", "Gabarito Definitivo"),
  ];
  const [par] = casarProvaComGabarito(documentos);
  assert.equal(par.gabarito.arquivo, "Gabarito_GM_definitivo.pdf");
  assert.equal(par.confidence, "alta");
});

test("B) concurso com VÁRIOS CARGOS: cada prova pareia só com o gabarito de nome relacionado, nunca por estar na mesma página", () => {
  const documentos = [
    doc("prova", "GM_Guarda_Municipal.pdf", "Prova Guarda Municipal", "Guarda Municipal"),
    doc("prova", "AR_Armeiro.pdf", "Prova Armeiro", "Armeiro"),
    doc("gabarito", "Gabarito_GM_definitivo.pdf", "Gabarito Definitivo"),
  ];
  const pares = casarProvaComGabarito(documentos);
  const gm = pares.find((p) => p.prova.cargo === "Guarda Municipal");
  const ar = pares.find((p) => p.prova.cargo === "Armeiro");
  assert.equal(gm.gabarito.arquivo, "Gabarito_GM_definitivo.pdf");
  assert.equal(gm.confidence, "alta");
  // Armeiro não compartilha nenhum token com o único gabarito da página
  // — nunca escolhido por exclusão/posição.
  assert.equal(ar.gabarito, null);
  assert.equal(ar.confidence, "baixa");
});

test("C) gabarito ausente (nenhum gabarito na página inteira) -> confidence baixa, gabarito null, nunca inventado", () => {
  const documentos = [doc("prova", "GM_Guarda_Municipal.pdf", "Prova Guarda Municipal", "Guarda Municipal")];
  const [par] = casarProvaComGabarito(documentos);
  assert.equal(par.gabarito, null);
  assert.equal(par.confidence, "baixa");
});

test("D) duas VERSÕES do mesmo gabarito (definitivo + provisório, mesmo cargo) não são tratadas como ambíguas — escolhe a mais oficial, confidence alta", () => {
  const documentos = [
    doc("prova", "GM_Guarda_Municipal.pdf", "Prova Guarda Municipal", "Guarda Municipal"),
    doc("gabarito", "Gabarito_Provisorio_GM.pdf", "Gabarito Provisório"),
    doc("gabarito", "Gabarito_GM_definitivo.pdf", "Gabarito Definitivo"),
  ];
  const [par] = casarProvaComGabarito(documentos);
  assert.equal(par.gabarito.arquivo, "Gabarito_GM_definitivo.pdf");
  assert.equal(par.confidence, "alta");
});

test("E) DOIS GABARITOS genuinamente ambíguos (conteúdo de nome diferente, mas empatam na correspondência) -> confidence media, nunca escolhido com confiança total", () => {
  const documentos = [
    doc("prova", "AG_Agente_Exemplo.pdf", "Prova Agente Exemplo", "Agente Exemplo"),
    doc("gabarito", "Gabarito_AG_Turno_Manha.pdf", "Gabarito Definitivo"),
    doc("gabarito", "Gabarito_AG_Turno_Tarde.pdf", "Gabarito Definitivo"),
  ];
  const [par] = casarProvaComGabarito(documentos);
  assert.equal(par.confidence, "media");
  assert.ok(par.gabarito, "ainda deve escolher um candidato, só com confiança reduzida");
  assert.match(par.motivo, /revisão humana/);
});

test("F) único par no concurso inteiro, sem nenhum token de nome compartilhado -> confidence media (nunca alta, nunca baixa)", () => {
  const documentos = [
    doc("prova", "ProvaObjetiva.pdf", "Prova Agente Único"),
    doc("gabarito", "RespostasOficiais.pdf", "Gabarito Definitivo"),
  ];
  const [par] = casarProvaComGabarito(documentos);
  assert.equal(par.gabarito.arquivo, "RespostasOficiais.pdf");
  assert.equal(par.confidence, "media");
  assert.match(par.motivo, /único par/);
});

test("G) nunca pareia usando só o ano/edital como sinal — dois documentos do mesmo edital mas cargos diferentes não se misturam", () => {
  const documentos = [
    doc("prova", "2020_CP001_Delegado.pdf", "Prova Delegado", "Delegado"),
    doc("prova", "2020_CP001_Escrivao.pdf", "Prova Escrivão", "Escrivão"),
    doc("gabarito", "2020_CP001_Gabarito_Delegado.pdf", "Gabarito Definitivo Delegado"),
  ];
  const pares = casarProvaComGabarito(documentos);
  const delegado = pares.find((p) => p.prova.cargo === "Delegado");
  const escrivao = pares.find((p) => p.prova.cargo === "Escrivão");
  assert.equal(delegado.gabarito.arquivo, "2020_CP001_Gabarito_Delegado.pdf");
  assert.equal(delegado.confidence, "alta");
  // "2020" e "cp001" são compartilhados por TODOS os documentos do
  // edital — mas isso nunca basta para parear Escrivão com o gabarito do
  // Delegado (o token distintivo "delegado" não aparece no nome da
  // prova de Escrivão).
  assert.equal(escrivao.gabarito, null);
});

test("H) tokenizarNomeArquivo normaliza extensão, caixa e separadores", () => {
  assert.deepEqual(tokenizarNomeArquivo("GM_Guarda-Municipal.PDF"), new Set(["gm", "guarda", "municipal"]));
});
