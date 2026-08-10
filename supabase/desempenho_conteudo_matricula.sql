-- Desempenho do aluno por assunto, escopado exclusivamente à matrícula ativa do
-- curso ativo (auth.uid() -> perfis.curso_ativo_id -> matriculas ativa) — nunca
-- mistura dados entre usuários ou cursos. Duas matrículas 'ativa' para o mesmo
-- usuário+curso não podem existir (matriculas_usuario_id_curso_id_key já garante
-- isso no banco), então a resolução abaixo nunca é ambígua.
--
-- Conta TODAS as tentativas de resposta (sem deduplicar por questão), conforme
-- decisão explícita para esta primeira versão.
--
-- O assunto de um erro é resolvido pela cadeia erros_usuarios -> respostas_usuarios
-- -> questoes (join em questoes via respostas_usuarios.questao_id, não via
-- erros_usuarios.questao_id diretamente), usando
-- coalesce(eu.assunto_id, q.assunto_id) como assunto efetivo, porque
-- erros_usuarios.assunto_id é nullable.
--
-- SECURITY DEFINER, SET search_path TO '' e SEM GRANT/REVOKE EXECUTE explícito —
-- inspecionei ids_questoes_para_usuario, registrar_resposta, erros_do_curso_ativo,
-- revisoes_do_curso_ativo e estatisticas_do_curso_ativo (supabase/*.sql já
-- existentes neste repositório): nenhuma delas tem GRANT/REVOKE EXECUTE próprio,
-- todas dependem do EXECUTE padrão do Postgres para "authenticated" combinado com
-- a validação interna de auth.uid(). Replico exatamente esse padrão aqui, sem
-- introduzir uma permissão diferente das demais funções sem justificativa.
--
-- Nenhuma tabela existente é alterada por este arquivo.

create or replace function public.desempenho_conteudo_matricula_ativa()
returns table (
  assunto_id bigint,
  total_respondidas bigint,
  acertos bigint,
  erros_nao_corrigidos bigint
)
language plpgsql
stable
security definer
set search_path to ''
as $function$
declare
  v_curso_ativo_id uuid;
  v_matricula_id uuid;
begin
  select p.curso_ativo_id into v_curso_ativo_id
  from public.perfis p
  where p.usuario_id = auth.uid();

  if v_curso_ativo_id is null then
    return;
  end if;

  select m.id into v_matricula_id
  from public.matriculas m
  where m.usuario_id = auth.uid()
    and m.curso_id = v_curso_ativo_id
    and m.status = 'ativa';

  if v_matricula_id is null then
    return;
  end if;

  return query
  select
    coalesce(r.assunto_id, e.assunto_id) as assunto_id,
    coalesce(r.total_respondidas, 0) as total_respondidas,
    coalesce(r.acertos, 0) as acertos,
    coalesce(e.erros_nao_corrigidos, 0) as erros_nao_corrigidos
  from (
    select q.assunto_id, count(*) as total_respondidas, sum((ru.acertou)::int) as acertos
    from public.respostas_usuarios ru
    join public.sessoes_estudo se on se.id = ru.sessao_id and se.matricula_id = v_matricula_id
    join public.questoes q on q.id = ru.questao_id
    where ru.usuario_id = auth.uid()
      and q.assunto_id is not null
    group by q.assunto_id
  ) r
  full outer join (
    select coalesce(eu.assunto_id, q.assunto_id) as assunto_id, count(*) as erros_nao_corrigidos
    from public.erros_usuarios eu
    join public.respostas_usuarios ru on ru.id = eu.resposta_id
    join public.sessoes_estudo se on se.id = ru.sessao_id and se.matricula_id = v_matricula_id
    join public.questoes q on q.id = ru.questao_id
    where eu.usuario_id = auth.uid()
      and eu.corrigido = false
      and coalesce(eu.assunto_id, q.assunto_id) is not null
    group by coalesce(eu.assunto_id, q.assunto_id)
  ) e on e.assunto_id = r.assunto_id;
end;
$function$;
