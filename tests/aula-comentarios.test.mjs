import test from "node:test";
import assert from "node:assert/strict";
import {readFile} from "node:fs/promises";
const sql=await readFile(new URL("../supabase/aula_comentarios.sql",import.meta.url),"utf8");
const ui=await readFile(new URL("../components/teoria/ComentariosAula.tsx",import.meta.url),"utf8");
test("comentários pertencem à aula lógica e têm limite",()=>{assert.match(sql,/aula_id uuid not null references public\.aulas/);assert.match(sql,/between 2 and 1000/);});
test("leitura e escrita exigem matrícula ativa",()=>{assert.match(sql,/m\.status='ativa'/);assert.match(sql,/usuario_pode_comentar_aula/);});
test("aluno remove somente o próprio comentário e admin pode moderar",()=>{assert.match(sql,/usuario_id=v_usuario and status='ativo'/);assert.match(sql,/if not public\.eh_admin\(\)/);});
test("interface distingue primeira participação de conversa existente",()=>{assert.match(ui,/Seja o primeiro a comentar!/);assert.match(ui,/O que os alunos estão dizendo/);assert.match(ui,/maxLength=\{1000\}/);assert.match(ui,/Remover meu comentário/);});
