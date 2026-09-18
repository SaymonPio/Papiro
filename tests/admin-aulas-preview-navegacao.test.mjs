import assert from "node:assert/strict";
import test from "node:test";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import path from "node:path";

// Regressão do bug: o botão "Ver aula completa" em /admin/aulas montava a
// URL de /admin/aulas/preview corretamente (?conteudo=&unidade=&versao=&
// nome=), mas a própria página de preview lia esses parâmetros via
// `window.location.search` dentro de um lazy initializer de useState — que
// só roda UMA vez, no primeiro render. Numa navegação client-side (Link),
// o roteador (vinext, o shim de next/navigation usado neste projeto) só
// atualiza window.location (history.pushState) DEPOIS que a página de
// destino já renderizou pela primeira vez (o pushState roda num efeito
// "pre-paint", posterior ao corpo da função do componente). Ou seja: o
// primeiro (e único) render via lazy initializer sempre via a URL ANTERIOR
// (ex.: /admin/aulas, sem ?conteudo=), travando "Nenhum conteúdo
// informado" para sempre — mesmo com conteúdo e unidade corretamente
// selecionados no gerador. Corrigido lendo os parâmetros via
// useSearchParams() (next/navigation), a mesma fonte reativa que o
// roteador já sincroniza a cada navegação (ver app/admin/aulas/preview/
// page.tsx).
//
// Este teste é estrutural (lê o código-fonte), no mesmo padrão já usado
// por tests/admin-aulas-preview-pdf-link.test.mjs -- não há harness de
// DOM/roteador neste projeto para montar os componentes de verdade.

const raizProjeto = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const geradorPagina = readFileSync(path.join(raizProjeto, "app/admin/aulas/page.tsx"), "utf8");
const previewPagina = readFileSync(path.join(raizProjeto, "app/admin/aulas/preview/page.tsx"), "utf8");

test("A/C) o gerador monta o link 'Ver aula completa' com os MESMOS nomes de parâmetro que o preview lê (conteudo, unidade, versao, nome)", () => {
  const trechoLink = geradorPagina.slice(
    geradorPagina.indexOf("Ver aula completa") - 400,
    geradorPagina.indexOf("Ver aula completa"),
  );
  assert.match(trechoLink, /\/admin\/aulas\/preview\?conteudo=\$\{conteudoId\}&unidade=\$\{unidadeId\}/);
  assert.match(trechoLink, /&versao=\$\{rascunho\.aula_versao_id\}/);
  assert.match(trechoLink, /&nome=\$\{encodeURIComponent/);

  assert.match(previewPagina, /searchParams\.get\("conteudo"\)/);
  assert.match(previewPagina, /searchParams\.get\("unidade"\)/);
  assert.match(previewPagina, /searchParams\.get\("versao"\)/);
  assert.match(previewPagina, /searchParams\.get\("nome"\)/);
});

test("B) o link só é renderizado quando conteudoId e unidadeId já estão selecionados (nunca gera 'undefined' na URL)", () => {
  const posicaoLink = geradorPagina.indexOf("Ver aula completa");
  const trechoAntes = geradorPagina.slice(0, posicaoLink);
  const aberturaCondicaoConteudo = trechoAntes.lastIndexOf("{conteudoId && (");
  const aberturaCondicaoUnidade = trechoAntes.lastIndexOf("{unidadeId && (");
  assert.ok(aberturaCondicaoConteudo > -1, "o bloco do link deveria estar dentro de {conteudoId && (...)}");
  assert.ok(aberturaCondicaoUnidade > -1, "o bloco do link deveria estar dentro de {unidadeId && (...)}");
  assert.ok(aberturaCondicaoConteudo < aberturaCondicaoUnidade && aberturaCondicaoUnidade < posicaoLink);
});

test("REGRESSÃO DIRETA DO BUG: o preview NUNCA lê window.location.search diretamente para resolver o contexto da URL — usa useSearchParams() (reativo)", () => {
  assert.doesNotMatch(previewPagina, /new URLSearchParams\(window\.location\.search\)/);
  assert.match(previewPagina, /import\s*\{\s*useSearchParams\s*\}\s*from\s*"next\/navigation"/);
  assert.match(previewPagina, /const searchParams = useSearchParams\(\);/);
});

test("D) a resolução de conteudoId/unidade/versao/nome não está congelada num useState com lazy initializer (recalcula a cada render, refletindo a seleção atual)", () => {
  assert.doesNotMatch(previewPagina, /useState\(lerContextoDaUrl\)/);
  assert.doesNotMatch(previewPagina, /function lerContextoDaUrl/);
});

test("E) abrir o preview nunca dispara geração de aula nem chama a Edge Function/RPC de geração (gerar-aula)", () => {
  assert.doesNotMatch(previewPagina, /functions\.invoke\(\s*["']gerar-aula["']/);
  assert.doesNotMatch(previewPagina, /\brpc\(\s*["']gerar_aula/);
});

test("conteudoId no preview continua validado como inteiro (protege contra query param malformado virar NaN/string)", () => {
  assert.match(previewPagina, /\/\^\\d\+\$\/\.test\(conteudoParam\)/);
});
