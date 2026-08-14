import test from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

const sql=await readFile(new URL("../supabase/questao_comentarios.sql",import.meta.url),"utf8");
const pagina=await readFile(new URL("../app/questoes/page.tsx",import.meta.url),"utf8");
const comentarios=await readFile(new URL("../components/questoes/ComentariosQuestao.tsx",import.meta.url),"utf8");
const estilos=await readFile(new URL("../app/globals.css",import.meta.url),"utf8");

test("comentários pertencem à questão e exigem matrícula em curso que a contenha",()=>{
  assert.match(sql,/questao_id bigint not null references public\.questoes/);
  assert.match(sql,/join public\.curso_questoes cq on cq\.questao_id=q\.id/);
  assert.match(sql,/m\.usuario_id=p_usuario_id/);
  assert.match(sql,/m\.status='ativa'/);
});

test("tabela permanece fechada e somente authenticated executa as RPCs",()=>{
  assert.match(sql,/revoke all on public\.questao_comentarios from anon, authenticated/);
  assert.match(sql,/revoke execute on function public\.listar_comentarios_questao\(bigint\) from public,anon/);
  assert.match(sql,/grant execute on function public\.listar_comentarios_questao\(bigint\) to authenticated/);
});

test("comunidade permite ler, publicar e remover o próprio comentário",()=>{
  assert.match(comentarios,/listar_comentarios_questao/);
  assert.match(comentarios,/comentar_questao/);
  assert.match(comentarios,/remover_meu_comentario_questao/);
  assert.match(comentarios,/Seja o primeiro a comentar!/);
  assert.match(comentarios,/maxLength=\{1000\}/);
  assert.match(pagina,/<ComentariosQuestao key=\{questaoAtual\.id\} questaoId=\{questaoAtual\.id\} \/>/);
});

test("cada alternativa pode ser riscada e restaurada sem virar resposta",()=>{
  assert.match(pagina,/alternativasEliminadas/);
  assert.match(pagina,/alternarAlternativaEliminada/);
  assert.match(pagina,/aria-pressed=\{eliminada\}/);
  assert.match(pagina,/eliminada\?"Restaurar":"Riscar"/);
  assert.match(estilos,/\.answer-option-row\.eliminated \.answer-choice span/);
  assert.match(estilos,/text-decoration: line-through/);
});

test("alternativas riscadas são restauradas ao avançar de questão",()=>{
  assert.match(pagina,/setAlternativasEliminadas\(new Set\(\)\)/);
});
