import test from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

const migration = await readFile(new URL("../supabase/unidades_pedagogicas.sql", import.meta.url), "utf8");
const generator = await readFile(new URL("../supabase/functions/gerar-aula/index.ts", import.meta.url), "utf8");
const reader = await readFile(new URL("../supabase/unidades_pedagogicas_leitura_rpc.sql", import.meta.url), "utf8");
const publisher = await readFile(new URL("../supabase/unidades_pedagogicas_publicacao_rpc.sql", import.meta.url), "utf8");
const curadoriaMariaPenha = await readFile(new URL("../supabase/curadoria_unidades_lei_maria_penha.sql", import.meta.url), "utf8");

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

test("gerador prioriza a redação legal vigente e versiona a mudança de prompt", () => {
  assert.match(generator, /const PROMPT_VERSION = "2j-c-v2"/);
  assert.match(generator, /REGRA DE VIGÊNCIA — OBRIGATÓRIA PARA FONTES LEGAIS/);
  assert.match(generator, /ensine SOMENTE a redação vigente mais recente/);
});
