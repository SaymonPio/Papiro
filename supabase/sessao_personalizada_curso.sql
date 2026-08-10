-- Base da sessão personalizada em /questoes: curso ativo -> matéria -> assunto
-- opcional -> quantidade.
--
-- Este arquivo cobre os artefatos NOVOS desta etapa: o 4º valor de
-- sessoes_estudo.nivel_meta e as duas RPCs de listagem usadas para popular os
-- seletores de matéria/assunto. A extensão de ids_questoes_para_usuario (que já
-- existia) foi feita em supabase/funcoes_curso_ativo.sql, no próprio arquivo
-- onde a função já vivia, para não duplicar/dividir a evolução de uma função
-- já versionada em dois lugares.
--
-- Envolvido em BEGIN/COMMIT — ou tudo aplica, ou nada aplica.

BEGIN;

-- ============================================================================
-- 1) sessoes_estudo.nivel_meta — adiciona 'personalizada' ao CHECK, mantendo
-- os 3 valores atuais (minima, normal, ideal). Nome da constraint confirmado
-- no banco: sessoes_estudo_nivel_meta_check. Nenhum registro existente é
-- alterado — só a regra de validação da coluna.
-- ============================================================================

alter table public.sessoes_estudo
  drop constraint if exists sessoes_estudo_nivel_meta_check;

alter table public.sessoes_estudo
  add constraint sessoes_estudo_nivel_meta_check
  check (nivel_meta in ('minima', 'normal', 'ideal', 'personalizada'));

-- ============================================================================
-- 2) materias_do_curso_ativo() — lista só matérias que realmente têm questão
-- ativa disponível no curso ativo via curso_questoes + questoes E que estão
-- marcadas como relevantes para preparação em curso_materias
-- (relevante_para_preparacao = true).
--
-- CORREÇÃO (bug reportado na validação visual): a versão anterior só exigia
-- curso_questoes + questoes.ativa, sem checar curso_materias. Isso permitia
-- listar matérias como "Conhecimentos Gerais" e "Matemática", que têm
-- questões antigas ainda vinculadas ao curso via curso_questoes (histórico,
-- não removido) mas cuja curso_materias.relevante_para_preparacao já foi
-- marcada como false. relevante_para_preparacao continua intocada — só passa
-- a ser LIDA como filtro aqui, nunca escrita.
-- ============================================================================

create or replace function public.materias_do_curso_ativo()
returns table (
  materia_id bigint,
  materia_nome text,
  total_questoes bigint
)
language sql
stable
security definer
set search_path to 'public'
as $function$
  select
    m.id as materia_id,
    m.nome as materia_nome,
    count(*) as total_questoes
  from public.questoes q
  join public.curso_questoes cq on cq.questao_id = q.id
  join public.matriculas mat
    on mat.curso_id = cq.curso_id
   and mat.usuario_id = auth.uid()
   and mat.status = 'ativa'
  join public.perfis p
    on p.usuario_id = auth.uid()
   and p.curso_ativo_id = cq.curso_id
  join public.materias m on m.id = q.materia_id
  join public.curso_materias cm
    on cm.curso_id = cq.curso_id
   and cm.materia_id = q.materia_id
   and cm.relevante_para_preparacao = true
  where q.ativa = true
    and q.materia_id is not null
  group by m.id, m.nome
  order by m.nome;
$function$;

-- ============================================================================
-- 3) assuntos_do_curso_ativo(p_materia_id) — mesma lógica, restrita a uma
-- matéria, e agora também exige que o assunto seja um curso_conteudos
-- relevante (relevante_para_preparacao = true) pertencente à curso_materia
-- ativa (relevante_para_preparacao = true) daquele mesmo curso.
--
-- CORREÇÃO: mesmo bug do item 2 — sem essa checagem, um assunto de uma
-- matéria já marcada como não-relevante (ou um assunto sem curadoria em
-- curso_conteudos) poderia aparecer aqui só por ter questão ativa via
-- curso_questoes. relevante_para_preparacao continua só lida, nunca escrita.
-- ============================================================================

create or replace function public.assuntos_do_curso_ativo(p_materia_id bigint)
returns table (
  assunto_id bigint,
  assunto_nome text,
  total_questoes bigint
)
language sql
stable
security definer
set search_path to 'public'
as $function$
  select
    a.id as assunto_id,
    a.nome as assunto_nome,
    count(*) as total_questoes
  from public.questoes q
  join public.curso_questoes cq on cq.questao_id = q.id
  join public.matriculas mat
    on mat.curso_id = cq.curso_id
   and mat.usuario_id = auth.uid()
   and mat.status = 'ativa'
  join public.perfis p
    on p.usuario_id = auth.uid()
   and p.curso_ativo_id = cq.curso_id
  join public.assuntos a on a.id = q.assunto_id
  join public.curso_materias cm
    on cm.curso_id = cq.curso_id
   and cm.materia_id = p_materia_id
   and cm.relevante_para_preparacao = true
  join public.curso_conteudos cc
    on cc.curso_materia_id = cm.id
   and cc.assunto_id = q.assunto_id
   and cc.relevante_para_preparacao = true
  where q.ativa = true
    and q.assunto_id is not null
    and q.materia_id = p_materia_id
  group by a.id, a.nome
  order by a.nome;
$function$;

COMMIT;
