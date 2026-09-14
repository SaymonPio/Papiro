import assert from "node:assert/strict";
import test from "node:test";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import path from "node:path";

// Justificação seletiva do texto pedagógico exibido DENTRO do site (aula
// interativa online + questões online + revisão/caderno de erros) —
// contraparte do que já existe no PDF (.impressao-*), mas em seletores
// .teoria-*/.question-*/.answer-*/.error-list próprios da experiência
// online. Nunca um seletor global (`p {}`, `body {}`): cada regra abaixo
// está amarrada a uma classe/descendente já usado exclusivamente pelo
// componente pedagógico correto.

const raizProjeto = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const globalsCss = readFileSync(path.join(raizProjeto, "app/globals.css"), "utf8");
const componenteAulaView = readFileSync(path.join(raizProjeto, "components/teoria/ComponenteAulaView.tsx"), "utf8");
const questoesPage = readFileSync(path.join(raizProjeto, "app/questoes/page.tsx"), "utf8");

function blocoDoSeletor(css, seletor) {
  const inicio = css.indexOf(`${seletor} {`);
  if (inicio === -1) return null;
  const fim = css.indexOf("}", inicio);
  return css.slice(inicio, fim);
}

test("A) texto corrido da aula (.teoria-texto, .teoria-pergunta, .teoria-dica, .teoria-revelar-conteudo, .teoria-resumo-item) recebe justificação", () => {
  for (const seletor of [".teoria-texto", ".teoria-pergunta", ".teoria-dica", ".teoria-revelar-conteudo", ".teoria-resumo-item"]) {
    const bloco = blocoDoSeletor(globalsCss, seletor);
    assert.ok(bloco, `seletor "${seletor}" deveria existir em globals.css`);
    assert.match(bloco, /text-align:\s*justify/, `"${seletor}" deveria estar justificado`);
    assert.match(bloco, /text-justify:\s*inter-word/);
    assert.match(bloco, /hyphens:\s*auto/);
  }
});

test("B) enunciado da questão (.question-card h1) recebe justificação, sem afetar títulos de página (.method-header h1/.result-card h1)", () => {
  const blocoEnunciado = blocoDoSeletor(globalsCss, ".question-card h1");
  assert.ok(blocoEnunciado, "esperava um bloco .question-card h1 próprio (mais específico que o agrupado com method-header/result-card)");
  assert.match(blocoEnunciado, /text-align:\s*justify/);
  // O seletor AGRUPADO (.method-header h1, .question-card h1, .result-card
  // h1 { ... }) é compartilhado com títulos de página — não pode ganhar
  // justify ali, senão título de página também justificaria.
  const casamentoAgrupado = globalsCss.match(/\.method-header h1,\s*\n\.question-card h1,\s*\n\.result-card h1\s*\{([^}]*)\}/);
  assert.ok(casamentoAgrupado, "esperava encontrar o seletor agrupado com method-header/result-card");
  assert.doesNotMatch(casamentoAgrupado[1], /text-align:\s*justify/);
});

test("C) explicação pós-resposta da questão (.answer-feedback p) recebe justificação", () => {
  const bloco = globalsCss.slice(globalsCss.indexOf(".answer-feedback p {"), globalsCss.indexOf("}", globalsCss.indexOf(".answer-feedback p {")) + 1);
  assert.match(bloco, /text-align:\s*justify/);
});

test("C) enunciado da revisão/caderno de erros (.error-list article > p) recebe justificação", () => {
  const bloco = globalsCss.slice(globalsCss.indexOf(".error-list article > p {"), globalsCss.indexOf("}", globalsCss.indexOf(".error-list article > p {")) + 1);
  assert.match(bloco, /text-align:\s*justify/);
});

test("D) alternativas (aula e questões) NUNCA recebem justificação", () => {
  for (const seletor of [".answer-choice", ".answer-option-row", ".teoria-alternativa", ".teoria-alternativa-corpo", ".teoria-alternativas"]) {
    const bloco = blocoDoSeletor(globalsCss, seletor);
    if (!bloco) continue; // seletor pode não ter bloco próprio (estado via classe composta) — nada a checar
    assert.doesNotMatch(bloco, /text-align:\s*justify/, `"${seletor}" não deveria ser justificado`);
  }
});

test("E) títulos/rótulos/kickers da aula e das questões continuam NÃO justificados", () => {
  for (const seletor of [
    ".teoria-bloco-kicker",
    ".teoria-bloco h3",
    ".teoria-subtitulo",
    ".teoria-jurisprudencia-meta",
    ".teoria-jurisprudencia-fonte",
    ".teoria-jurisprudencia-rotulo",
    ".question-meta span",
    ".question-origin-main",
  ]) {
    const bloco = blocoDoSeletor(globalsCss, seletor);
    if (!bloco) continue;
    assert.doesNotMatch(bloco, /text-align:\s*justify/, `"${seletor}" não deveria ser justificado`);
  }
});

test("F) o PDF (.impressao-*) permanece com suas próprias regras, inalteradas por esta rodada", () => {
  // As 3 regras .impressao-* que já eram justificadas continuam sendo,
  // exatamente como antes — nenhuma foi removida nem alterada aqui.
  for (const seletor of [".impressao-texto", ".impressao-pergunta", ".impressao-resumo-lista li"]) {
    const bloco = blocoDoSeletor(globalsCss, seletor);
    assert.ok(bloco, `"${seletor}" deveria continuar existindo`);
    assert.match(bloco, /text-align:\s*justify/);
  }
  // .impressao-secao-titulo (título interno do PDF) continua sem justify —
  // reforço de peso/tamanho da rodada anterior preservado, nada novo aqui.
  const blocoTituloPdf = blocoDoSeletor(globalsCss, ".impressao-secao-titulo");
  assert.ok(blocoTituloPdf);
  assert.doesNotMatch(blocoTituloPdf, /text-align:\s*justify/);
  assert.match(blocoTituloPdf, /font-weight:\s*700/);
});

test("G) nenhum seletor global perigoso (p {}, body {}) foi introduzido", () => {
  assert.doesNotMatch(globalsCss, /^p\s*\{[^}]*justify/m);
  assert.doesNotMatch(globalsCss, /^body\s*\{[^}]*justify/m);
  assert.doesNotMatch(globalsCss, /^\*\s*\{[^}]*justify/m);
});

test("nenhuma alteração de JSX foi feita — só CSS (ComponenteAulaView.tsx e app/questoes/page.tsx sem novas classes de justificação)", () => {
  assert.ok(!componenteAulaView.includes("justificado"));
  assert.ok(!questoesPage.includes("justificado"));
});
