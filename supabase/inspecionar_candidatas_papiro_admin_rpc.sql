-- Inspeção administrativa, somente leitura, do PERCURSO COMPLETO do Modo
-- Papiro (prática de cada unidade + Missão Final) — usada exclusivamente
-- pela prévia em app/admin/aulas/preview/page.tsx. Nenhuma RPC de produção é
-- alterada por esta migration: public.selecionar_candidatas_unidade_
-- pedagogica e public.selecionar_candidatas_conteudo (missao_pratica_
-- papiro_rpc.sql) continuam exatamente como estão, chamadas só de dentro de
-- iniciar_pratica_unidade/iniciar_missao_final.
--
-- Esta função replica o MESMO critério de elegibilidade dessas duas RPCs
-- (revalidado por leitura direta do código-fonte antes de escrever este
-- arquivo, e por consulta manual contra o banco real: U1=51, U2=24, U3=25,
-- U4=11, U5=4 candidatas; Missão Final=113 no total, 9 banco geral + 104
-- vinculadas — todos batendo com os números já auditados nesta mesma
-- sessão), com duas diferenças deliberadas, ambas exigidas pelo caso de uso
-- de auditoria de conteúdo (nunca simula um aluno real):
--   1. Sem a personalização por histórico de resposta (tiers de "nunca
--      respondida"/"errada"/"janela de repetição", `random()`) — não existe
--      usuário real sendo inspecionado, então a ordenação é só
--      cq.prioridade, q.id (determinística, reproduzível a cada reload).
--   2. Sem LIMIT — devolve TODAS as elegíveis, nunca só uma amostra. A
--      tela cliente decide quantas mostrar (10 por unidade, 30 na Missão
--      Final) e usa o total real para avisar quando faltar candidata
--      (ex.: "U5 possui apenas 4 questões vinculadas"), nunca completa
--      artificialmente nem esconde o problema.
--
-- p_unidade_pedagogica_id NULL => modo Missão Final (mesmo critério de
-- selecionar_candidatas_conteudo: vinculada a unidade ativa OU banco geral
-- do mesmo assunto sem nenhum vínculo neste conteúdo). Não NULL => modo
-- prática de unidade (mesmo critério de
-- selecionar_candidatas_unidade_pedagogica: vínculo direto com a unidade,
-- sem checar se a unidade está ativa — a própria RPC original também não
-- checa, confia em quem a chama).
--
-- curso_id é resolvido internamente a partir de p_conteudo_id (curso_
-- conteudos -> curso_materias.curso_id), então o cliente nunca precisa
-- adivinhar ou hardcodar o curso.
--
-- v2 (mesma sessão): acrescenta questoes.explicacao à saída, para o admin
-- revisar se cada questão está bem explicada -- só leitura, nunca chama
-- registrar_resposta nem grava em respostas_usuarios/erros_usuarios.
-- RETURNS TABLE mudou (coluna nova), por isso é DROP + CREATE em vez de
-- CREATE OR REPLACE (Postgres não permite alterar o tipo de retorno de uma
-- função existente com REPLACE). Nenhuma outra função depende desta.

begin;

drop function if exists public.inspecionar_candidatas_papiro_admin(bigint, uuid);

create function public.inspecionar_candidatas_papiro_admin(
  p_conteudo_id bigint,
  p_unidade_pedagogica_id uuid default null
)
returns table (
  questao_id bigint,
  origem text,
  enunciado text,
  fonte text,
  banca text,
  concurso text,
  explicacao text,
  alternativas jsonb
)
language plpgsql
stable
security definer
set search_path to ''
as $function$
declare
  v_curso_id uuid;
  v_assunto_id bigint;
begin
  if not public.eh_admin() then
    raise exception 'Apenas administradores podem inspecionar candidatas do Modo Papiro';
  end if;

  select cm.curso_id, cc.assunto_id
  into v_curso_id, v_assunto_id
  from public.curso_conteudos cc
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where cc.id = p_conteudo_id;

  if v_curso_id is null then
    raise exception 'Conteudo % nao encontrado', p_conteudo_id;
  end if;

  if p_unidade_pedagogica_id is not null then
    return query
    select
      q.id,
      'unidade'::text,
      q.enunciado,
      q.fonte,
      q.banca,
      q.concurso,
      q.explicacao,
      alt.alternativas
    from public.questoes q
    join public.questao_unidades_pedagogicas qup
      on qup.questao_id = q.id
     and qup.unidade_pedagogica_id = p_unidade_pedagogica_id
    join public.curso_questoes cq
      on cq.questao_id = q.id
     and cq.curso_id = v_curso_id
    join lateral (
      select jsonb_agg(
        jsonb_build_object('ordem', a.ordem, 'texto', a.texto, 'correta', a.correta)
        order by a.ordem
      ) as alternativas
      from public.alternativas a
      where a.questao_id = q.id
    ) alt on true
    where q.ativa = true
    order by cq.prioridade asc, q.id asc;
  else
    return query
    select
      q.id,
      case when exists (
        select 1
        from public.questao_unidades_pedagogicas qup
        join public.unidades_pedagogicas u
          on u.id = qup.unidade_pedagogica_id
         and u.curso_conteudo_id = p_conteudo_id
         and u.ativa = true
        where qup.questao_id = q.id
      ) then 'vinculada' else 'banco_geral' end,
      q.enunciado,
      q.fonte,
      q.banca,
      q.concurso,
      q.explicacao,
      alt.alternativas
    from public.questoes q
    join public.curso_questoes cq
      on cq.questao_id = q.id
     and cq.curso_id = v_curso_id
    join lateral (
      select jsonb_agg(
        jsonb_build_object('ordem', a.ordem, 'texto', a.texto, 'correta', a.correta)
        order by a.ordem
      ) as alternativas
      from public.alternativas a
      where a.questao_id = q.id
    ) alt on true
    where q.ativa = true
      and (
        exists (
          select 1
          from public.questao_unidades_pedagogicas qup
          join public.unidades_pedagogicas u
            on u.id = qup.unidade_pedagogica_id
           and u.curso_conteudo_id = p_conteudo_id
           and u.ativa = true
          where qup.questao_id = q.id
        )
        or (
          v_assunto_id is not null
          and q.assunto_id = v_assunto_id
          and not exists (
            select 1
            from public.questao_unidades_pedagogicas qup2
            join public.unidades_pedagogicas u2
              on u2.id = qup2.unidade_pedagogica_id
             and u2.curso_conteudo_id = p_conteudo_id
            where qup2.questao_id = q.id
          )
        )
      )
    order by cq.prioridade asc, q.id asc;
  end if;
end;
$function$;

revoke execute on function public.inspecionar_candidatas_papiro_admin(bigint, uuid) from public, anon;
grant execute on function public.inspecionar_candidatas_papiro_admin(bigint, uuid) to authenticated;

commit;
