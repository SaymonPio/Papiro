import assert from "node:assert/strict";
import test from "node:test";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import path from "node:path";

// PAPIRO — Central Única de Questões: fusão de /questoes/buscar dentro da
// aba "Sessão personalizada" de /questoes (ver components/questoes/
// SessaoPersonalizadaBusca.tsx). Testes estáticos (leitura de código-fonte,
// sem renderização/pixel exato) — mesmo padrão já usado em
// texto-online-justificado.test.mjs e questao-ativa-robustez-layout.test.mjs.

const raizProjeto = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const questoesPage = readFileSync(path.join(raizProjeto, "app/questoes/page.tsx"), "utf8");
const buscarPage = readFileSync(path.join(raizProjeto, "app/questoes/buscar/page.tsx"), "utf8");
const componenteBusca = readFileSync(path.join(raizProjeto, "components/questoes/SessaoPersonalizadaBusca.tsx"), "utf8");

test("A) SessaoPersonalizadaBusca existe e é importado/usado em app/questoes/page.tsx", () => {
  assert.match(questoesPage, /import SessaoPersonalizadaBusca from "@\/components\/questoes\/SessaoPersonalizadaBusca";/);
  assert.match(questoesPage, /<SessaoPersonalizadaBusca/);
  assert.match(questoesPage, /onSessaoIniciada=/);
});

test("B) o formulário antigo (.custom-session) só é renderizado no ramo origemCronograma — nunca no fluxo manual modoInicio===\"personalizada\"", () => {
  const idxTernario = questoesPage.indexOf('modoInicio === "metas" ? (');
  const idxOrigemCronograma = questoesPage.indexOf("origemCronograma ? (", idxTernario);
  const idxCustomSession = questoesPage.indexOf('className="custom-session"', idxTernario);
  const idxSessaoPersonalizadaBuscaNoJsx = questoesPage.indexOf("<SessaoPersonalizadaBusca", idxTernario);
  assert.ok(idxTernario > -1 && idxOrigemCronograma > -1 && idxCustomSession > -1 && idxSessaoPersonalizadaBuscaNoJsx > -1);
  // Ordem textual do ternário de 3 vias: metas -> origemCronograma (custom-session) -> manual (SessaoPersonalizadaBusca).
  assert.ok(idxTernario < idxOrigemCronograma, "ramo origemCronograma deveria vir depois do ramo metas");
  assert.ok(idxOrigemCronograma < idxCustomSession, ".custom-session deveria estar dentro do ramo origemCronograma");
  assert.ok(idxCustomSession < idxSessaoPersonalizadaBuscaNoJsx, "SessaoPersonalizadaBusca deveria vir depois (ramo manual, último da cadeia)");
});

test("C) iniciarSessaoPersonalizada continua contendo, intocados, os caminhos de unidade pedagógica, Missão Final, missão/cronograma e o ramo ad-hoc antigo", () => {
  const inicioFuncao = questoesPage.indexOf("const iniciarSessaoPersonalizada = useCallback(");
  assert.ok(inicioFuncao > -1, "esperava encontrar iniciarSessaoPersonalizada");
  const fimFuncao = questoesPage.indexOf(
    "}, [assuntoSelecionado, materiaSelecionada, missionId, quantidadePersonalizada, refazerMissao, unidadePedagogicaId, missaoFinal]);",
    inicioFuncao,
  );
  assert.ok(fimFuncao > -1, "esperava encontrar o fechamento do useCallback com a MESMA lista de dependências de antes da fusão");
  const corpo = questoesPage.slice(inicioFuncao, fimFuncao);
  assert.match(corpo, /iniciar_pratica_unidade/);
  assert.match(corpo, /iniciar_missao_final/);
  assert.match(corpo, /ids_questoes_para_usuario/);
  assert.match(corpo, /iniciar_questoes_da_missao/);
  assert.match(corpo, /iniciar_sessao_questoes_avulsa/, "ramo ad-hoc antigo (p_nivel_meta: \"personalizada\") deve continuar presente, mesmo sem botão manual chamando-o");
});

test("D) app/questoes/buscar/page.tsx vira um Server Component que só redireciona para /questoes?modo=personalizada — rota preservada, nunca apagada", () => {
  // Regex ancorada na diretiva de verdade (linha própria), não numa busca
  // solta — o arquivo PODE mencionar "use client" em prosa/comentário
  // explicando a remoção, sem que isso seja a diretiva real.
  assert.doesNotMatch(buscarPage, /^"use client";\s*$/m);
  assert.match(buscarPage, /from "next\/navigation"/);
  assert.match(buscarPage, /redirect\("\/questoes\?modo=personalizada"\)/);
  // Nunca redireciona pra si mesma (risco de loop).
  assert.doesNotMatch(buscarPage, /redirect\("\/questoes\/buscar/);
});

test("E) NivelMeta aceita \"pesquisa\" (dívida técnica do raio-X corrigida)", () => {
  assert.match(questoesPage, /type NivelMeta = MetaPreset \| "personalizada" \| "revisao" \| "pesquisa";/);
});

test("F) o link antigo \"Pesquisar questões por banca, ano e dificuldade\" (.free-search-link) não aparece mais em /questoes", () => {
  assert.doesNotMatch(questoesPage, /Pesquisar questões por banca, ano e dificuldade/);
  assert.doesNotMatch(questoesPage, /free-search-link/);
});

test("G) SessaoPersonalizadaBusca chama iniciar_sessao_questoes_pesquisa e só devolve o id via onSessaoIniciada — nunca navega sozinho, nunca monta a lista de questões no cliente", () => {
  assert.match(componenteBusca, /iniciar_sessao_questoes_pesquisa/);
  assert.match(componenteBusca, /onSessaoIniciada\(Number\(linha\.sessao_id\)\)/);
  assert.doesNotMatch(componenteBusca, /router\.push/);
  assert.doesNotMatch(componenteBusca, /buscarDetalhesQuestoes/);
  // Sinal real de uso (import/JSX), não busca solta — o arquivo PODE
  // mencionar "StudentAppShell" em prosa/comentário explicando a remoção.
  assert.doesNotMatch(componenteBusca, /from "@\/components\/layout\/StudentAppShell"/);
  assert.doesNotMatch(componenteBusca, /<StudentAppShell/);
});

test("H) o callback em app/questoes/page.tsx reusa o mecanismo existente de ?sessaoAvulsa= (navegação real, não duplica busca/montagem da lista de questões)", () => {
  const idxCallback = questoesPage.indexOf("onSessaoIniciada={(sessaoId)");
  assert.ok(idxCallback > -1);
  const trecho = questoesPage.slice(idxCallback, idxCallback + 200);
  assert.match(trecho, /\/questoes\?sessaoAvulsa=\$\{sessaoId\}/);
});
