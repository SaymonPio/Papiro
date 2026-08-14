import test from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

const rpc = await readFile(new URL("../supabase/unidades_pedagogicas_navegacao_rpc.sql", import.meta.url), "utf8");
const pagina = await readFile(new URL("../app/teoria/page.tsx", import.meta.url), "utf8");
const estilos = await readFile(new URL("../app/globals.css", import.meta.url), "utf8");

test("RPC lista todas as unidades publicadas da missão em ordem pedagógica", () => {
  assert.match(rpc, /carregar_unidades_publicadas_da_missao\(p_missao_id uuid\)/);
  assert.match(rpc, /u\.id,\s+u\.titulo,\s+u\.ordem/);
  assert.match(rpc, /u\.curso_conteudo_id = v_conteudo_id/);
  assert.match(rpc, /av\.status = 'publicada'/);
  assert.match(rpc, /order by u\.ordem, u\.id/);
  assert.doesNotMatch(rpc, /limit 1/);
});

test("RPC deriva usuário, conteúdo e unidades no servidor", () => {
  assert.match(rpc, /v_usuario_id := auth\.uid\(\)/);
  assert.match(rpc, /m\.usuario_id = v_usuario_id/);
  assert.match(rpc, /m\.status = 'ativa'/);
  assert.match(rpc, /security definer/);
  assert.match(rpc, /revoke execute .* from public/);
  assert.match(rpc, /revoke execute .* from anon/);
  assert.match(rpc, /grant execute .* to authenticated/);
});

test("tela do aluno oferece seletor e navegação entre as unidades", () => {
  assert.match(pagina, /carregar_unidades_publicadas_da_missao/);
  assert.match(pagina, /role="tablist"/);
  assert.match(pagina, /aria-selected=\{indice === indiceUnidade\}/);
  assert.match(pagina, /Unidade \{indiceUnidade \+ 1\} de \{unidadesPublicadas\.length\}/);
  assert.match(pagina, /Unidade anterior/);
  assert.match(pagina, /Próxima unidade/);
});

test("cada unidade usa a própria aula para a conversa da comunidade", () => {
  assert.match(pagina, /<ComentariosAula aulaId=\{aula\.aula_id\} \/>/);
});

test("navegação se adapta a telas menores", () => {
  assert.match(estilos, /\.teoria-unidades-lista/);
  assert.match(estilos, /overflow-x: auto/);
  assert.match(estilos, /scroll-snap-type: x proximity/);
});
