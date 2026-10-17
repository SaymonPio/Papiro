import assert from "node:assert/strict";
import test from "node:test";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import path from "node:path";

// PAPIRO — Padronização visual do hero: /estatisticas ganha a mesma escala
// aprovada em .central-questoes .method-header, escopada só nesta tela.
// .stats-page/.stats-header são compartilhados com /meu-estudo (confirmado
// por auditoria) — por isso o teste central é "só /estatisticas ganhou a
// classe nova, /meu-estudo continua exatamente como estava".

const raizProjeto = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const estatisticasPage = readFileSync(path.join(raizProjeto, "app/estatisticas/page.tsx"), "utf8");
const meuEstudoPage = readFileSync(path.join(raizProjeto, "app/meu-estudo/page.tsx"), "utf8");
const globalsCss = readFileSync(path.join(raizProjeto, "app/globals.css"), "utf8");

function blocosDoSeletor(css, seletor) {
  const blocos = [];
  let cursor = 0;
  for (;;) {
    const inicio = css.indexOf(`${seletor} {`, cursor);
    if (inicio === -1) break;
    const fim = css.indexOf("}", inicio);
    blocos.push(css.slice(inicio, fim));
    cursor = fim + 1;
  }
  return blocos;
}

test("A) app/estatisticas/page.tsx ganhou a classe .central-estatisticas no <main>, sem perder .stats-page", () => {
  assert.match(estatisticasPage, /<main className="stats-page central-estatisticas">/);
});

test("B) app/meu-estudo/page.tsx NUNCA recebeu .central-estatisticas — também usa .stats-page/.stats-header, mas fica com o tamanho padrão", () => {
  assert.doesNotMatch(meuEstudoPage, /central-estatisticas/);
  assert.match(meuEstudoPage, /className="stats-page meu-estudo-page meu-estudo-entrada"/);
});

test("C) texto do hero preservado (label, h1, subtítulo) — nenhum conteúdo foi tocado, só CSS", () => {
  assert.match(estatisticasPage, /EVOLUÇÃO NO MÉTODO PAPIRO/);
  assert.match(estatisticasPage, /<h1>Consistência que pode ser medida\.<\/h1>/);
  assert.match(estatisticasPage, /Indicadores dos últimos 90 dias\./);
});

test("D) regra escopada .central-estatisticas .stats-header/h1 existe, reduz font-size/line-height/margin/min-height, nunca redefine .stats-header sozinho (que afetaria /meu-estudo)", () => {
  const blocoHeader = blocosDoSeletor(globalsCss, ".central-estatisticas .stats-header");
  const blocoH1 = blocosDoSeletor(globalsCss, ".central-estatisticas .stats-header h1");
  assert.equal(blocoHeader.length, 1);
  assert.equal(blocoH1.length, 1);
  assert.match(blocoHeader[0], /min-height:\s*180px/);
  assert.match(blocoHeader[0], /margin-bottom:\s*18px/);
  assert.match(blocoH1[0], /font-size:\s*clamp\(2\.5rem, 4\.8vw, 4\.4rem\)/);
  assert.match(blocoH1[0], /line-height:\s*0\.95/);
  assert.match(blocoH1[0], /max-width:\s*660px/);
});

test("E) o bloco .stats-header/.stats-header h1 genérico (sem escopo) permanece exatamente como antes — efeito em /meu-estudo preservado", () => {
  // Regex (não indexOf com \n literal) porque o arquivo usa CRLF.
  const blocoHeaderGenerico = globalsCss.match(
    /\.notices-header,\s*\.stats-header,\s*\.notice-result-header \{[\s\S]*?\}/,
  )?.[0];
  assert.ok(blocoHeaderGenerico, "esperava encontrar o bloco genérico .notices-header/.stats-header/.notice-result-header");
  assert.match(blocoHeaderGenerico, /min-height:\s*210px/);
  assert.match(blocoHeaderGenerico, /margin-bottom:\s*26px/);
  const blocoH1Generico = globalsCss.match(
    /\.notices-header h1,\s*\.stats-header h1,\s*\.notice-result-header h1 \{[\s\S]*?\}/,
  )?.[0];
  assert.ok(blocoH1Generico, "esperava encontrar o bloco genérico .notices-header h1/.stats-header h1/.notice-result-header h1");
  assert.match(blocoH1Generico, /font-size:\s*clamp\(3rem, 5\.4vw, 5\.2rem\)/);
  assert.match(blocoH1Generico, /max-width:\s*880px/);
});

test("F) nenhuma lógica/RPC/card/dado de /estatisticas foi tocado — só a classe no <main> e o CSS do hero", () => {
  for (const termo of [
    "stats-summary",
    "performance-panel",
    "consistency-panel",
    "reviews-panel",
    "errors-panel",
    "metric-track",
    "error-stat",
  ]) {
    assert.match(estatisticasPage, new RegExp(termo), `${termo} deveria continuar presente e intocado`);
  }
});
