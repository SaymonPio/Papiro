import test from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

const migration = await readFile(new URL("../supabase/unidades_pedagogicas.sql", import.meta.url), "utf8");
const generator = await readFile(new URL("../supabase/functions/gerar-aula/index.ts", import.meta.url), "utf8");
// Fase 3A: PROMPT_VERSION, montarPromptContexto e a configuração de
// modelo/fallback saíram de gerar-aula/index.ts para o módulo
// compartilhado (agora usado também pelo finalizador) — mesma mudança já
// refletida nos testes gerar-aula-{escopo,jurisprudencia,validador}.test.mjs.
const openaiResponses = await readFile(new URL("../supabase/functions/_shared/gerar-aula/openaiResponses.mjs", import.meta.url), "utf8");
const reader = await readFile(new URL("../supabase/unidades_pedagogicas_leitura_rpc.sql", import.meta.url), "utf8");
const publisher = await readFile(new URL("../supabase/unidades_pedagogicas_publicacao_rpc.sql", import.meta.url), "utf8");
const curadoriaMariaPenha = await readFile(new URL("../supabase/curadoria_unidades_lei_maria_penha.sql", import.meta.url), "utf8");
const adminAulas = await readFile(new URL("../app/admin/aulas/page.tsx", import.meta.url), "utf8");
const publisherFix = await readFile(new URL("../supabase/unidades_pedagogicas_publicacao_fix.sql", import.meta.url), "utf8");

test("unidade pertence a um conteúdo real e tem ordem única", () => {
  assert.match(migration, /references public\.curso_conteudos\(id\) on delete restrict/);
  assert.match(migration, /unique \(curso_conteudo_id, ordem\)/);
});

test("aula passa a ser única por unidade, não por conteúdo", () => {
  assert.match(migration, /drop constraint aulas_conteudo_id_key/);
  assert.match(migration, /unique \(unidade_pedagogica_id\)/);
  assert.match(migration, /foreign key \(unidade_pedagogica_id, conteudo_id\)/);
});

test("gerador valida a unidade no servidor e cria aula vinculada", () => {
  assert.match(generator, /\.from\("unidades_pedagogicas"\)/);
  assert.match(generator, /\.eq\("curso_conteudo_id", conteudoId\)/);
  assert.match(generator, /unidade_pedagogica_id: unidadePedagogicaId/);
  assert.match(generator, /demais unidades do MESMO curso_conteudo/);
});

test("leitura do aluno resolve aula por unidade ativa e ordem", () => {
  assert.match(reader, /join public\.aulas a on a\.unidade_pedagogica_id=u\.id/);
  assert.match(reader, /order by u\.ordem/);
  assert.match(reader, /limit 1/);
});

test("publicação é administrativa, transacional e mantém uma versão publicada", () => {
  assert.match(publisher, /if not public\.eh_admin\(\)/);
  assert.match(publisher, /v_status <> 'rascunho'/);
  assert.match(publisher, /set status='arquivada'/);
  assert.match(publisher, /set status='publicada', publicado_em=v_publicado_em/);
});

test("curadoria da Lei Maria da Penha usa somente artigos existentes e destaca alterações vigentes", () => {
  assert.doesNotMatch(curadoriaMariaPenha, /'art\. 8º-A'/);
  assert.match(curadoriaMariaPenha, /caráter prioritário no SUS e no Susp/);
  assert.match(curadoriaMariaPenha, /Lei 15\.455\/2026/);
  assert.match(curadoriaMariaPenha, /Leis 15\.380, 15\.438, 15\.383 e 15\.412/);
});

test("gerador prioriza a redação legal vigente e versiona a mudança de prompt (Fase 3A: PROMPT_VERSION e o texto do prompt agora vivem em _shared/gerar-aula/openaiResponses.mjs)", () => {
  assert.match(openaiResponses, /export const PROMPT_VERSION = "3b-quadrinho-v1"/);
  assert.match(openaiResponses, /REGRA DE VIGÊNCIA — OBRIGATÓRIA PARA FONTES LEGAIS/);
  assert.match(openaiResponses, /ensine SOMENTE a redação vigente mais recente/);
  assert.match(generator, /PROMPT_VERSION\b/, "o gerador deve continuar usando PROMPT_VERSION (importado), não uma cópia local");
});

test("gerador permite configurar o modelo e preserva o Luna como padrão (Fase 3A: resolverConfiguracaoModelo em _shared/gerar-aula/openaiResponses.mjs)", () => {
  assert.match(openaiResponses, /const MODELO_PADRAO = "gpt-5\.6-luna"/);
  assert.match(openaiResponses, /getEnv\("OPENAI_MODEL"\)\?\.trim\(\) \|\| MODELO_PADRAO/);
  assert.match(openaiResponses, /model: modelo/);
  assert.doesNotMatch(generator, /ainda NÃO aplicada/);
  assert.doesNotMatch(openaiResponses, /ainda NÃO aplicada/);
});

test("painel administrativo mostra somente gerações da unidade selecionada", () => {
  assert.match(adminAulas, /g\.contexto\?\.unidade_pedagogica_id === unidadeId/);
  assert.match(adminAulas, /geracoesDaUnidade\.map/);
  assert.match(adminAulas, /geração\(ões\) desta unidade/);
  assert.match(adminAulas, /g\.contexto\?\.unidade_pedagogica \?\? "Unidade pedagógica não registrada"/);
});

test("publicação qualifica colunas que colidem com os parâmetros de retorno", () => {
  assert.match(publisherFix, /versao_anterior\.aula_id=v_aula_id/);
  assert.match(publisherFix, /versao_anterior\.status='publicada'/);
  assert.match(publisherFix, /versao_revisada\.id=p_aula_versao_id/);
});
