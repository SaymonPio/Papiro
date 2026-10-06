-- Hotfix: iniciar_sessao_questoes_avulsa falhava com Postgres 42702
-- ("column reference \"status\" is ambiguous") ao criar uma sessão nova,
-- erro real capturado no navegador ao tentar iniciar sessão personalizada.
--
-- Causa: RETURNS TABLE(sessao_id bigint, status text, questao_ids bigint[],
-- recuperada boolean) faz o PL/pgSQL declarar implicitamente variáveis de
-- saída com esses 4 nomes, visíveis em toda a função. O trecho
--   insert into public.sessoes_estudo (..., status, ...) values (...)
--   returning id, status into v_sessao_id, v_status;
-- usa "status" sem qualificação na cláusula RETURNING — e "status" bate
-- tanto com a coluna sessoes_estudo.status quanto com a variável de saída
-- "status". "id" não ambiguava (não há variável com esse nome), só
-- "status". Auditoria completa do resto da função (select m.status,
-- s.status, s.id, sq.sessao_id, sq.questao_id, os dois return query, as
-- duas listas de colunas-alvo dos INSERT) não encontrou nenhuma outra
-- referência não qualificada que colida com sessao_id/status/
-- questao_ids/recuperada.
--
-- Correção: dar um alias à tabela-alvo do INSERT (sintaxe padrão do
-- Postgres, INSERT INTO tabela AS alias) e qualificar a RETURNING com
-- esse alias — mesmo padrão de alias explícito já usado no resto da
-- função. Nenhuma outra linha muda. Hotfix anterior (EXISTS contra
-- sessao_questoes_planejadas, filtro de matricula_id, FOR UPDATE,
-- criação atômica, nenhuma limpeza das 72 sessões órfãs) permanece
-- intacto.

create or replace function public.iniciar_sessao_questoes_avulsa(
  p_nivel_meta text,
  p_quantidade integer,
  p_materia_id bigint default null,
  p_assunto_id bigint default null
)
returns table(sessao_id bigint, status text, questao_ids bigint[], recuperada boolean)
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_usuario_id uuid := auth.uid();
  v_matricula_id uuid;
  v_sessao_id bigint;
  v_status text;
  v_ids bigint[];
  v_total_ids integer;
begin
  if v_usuario_id is null then
    raise exception 'Usuario nao autenticado';
  end if;

  if p_nivel_meta not in ('minima', 'normal', 'ideal', 'personalizada') then
    raise exception 'Nivel de meta invalido: %', p_nivel_meta;
  end if;

  if p_assunto_id is not null and p_materia_id is null then
    raise exception 'p_assunto_id informado sem p_materia_id';
  end if;

  select m.id into v_matricula_id
  from public.matriculas m
  join public.perfis p on p.curso_ativo_id = m.curso_id
  where p.usuario_id = v_usuario_id
    and m.usuario_id = v_usuario_id
    and m.status = 'ativa'
  limit 1;

  if v_matricula_id is null then
    raise exception 'Matricula ativa no curso ativo nao encontrada';
  end if;

  select s.id, s.status
  into v_sessao_id, v_status
  from public.sessoes_estudo s
  where s.usuario_id = v_usuario_id
    and s.matricula_id = v_matricula_id
    and s.missao_id is null
    and s.status = 'em_andamento'
    and s.nivel_meta = p_nivel_meta
    and s.materia_id is not distinct from p_materia_id
    and s.assunto_id is not distinct from p_assunto_id
    and exists (
      select 1
      from public.sessao_questoes_planejadas sq
      where sq.sessao_id = s.id
    )
  order by s.id desc
  limit 1
  for update;

  if v_sessao_id is not null then
    select array_agg(sq.questao_id order by sq.ordem)
    into v_ids
    from public.sessao_questoes_planejadas sq
    where sq.sessao_id = v_sessao_id;

    return query select v_sessao_id, v_status, v_ids, true;
    return;
  end if;

  select array_agg(q.questao_id)
  into v_ids
  from public.ids_questoes_para_usuario(p_quantidade, p_materia_id, p_assunto_id) as q(questao_id);

  v_total_ids := coalesce(cardinality(v_ids), 0);
  if v_total_ids = 0 then
    raise exception 'Nao ha questoes disponiveis para este filtro';
  end if;

  -- Alias "se" explícito na tabela-alvo para poder qualificar a
  -- RETURNING abaixo (se.id, se.status) e remover a ambiguidade com a
  -- variável de saída "status" da RETURNS TABLE.
  insert into public.sessoes_estudo as se (
    usuario_id, matricula_id, nivel_meta, status,
    inicio_em, minutos_revisao, questoes_planejadas,
    materia_id, assunto_id
  ) values (
    v_usuario_id, v_matricula_id, p_nivel_meta, 'em_andamento',
    clock_timestamp(), 0, v_total_ids,
    p_materia_id, p_assunto_id
  ) returning se.id, se.status into v_sessao_id, v_status;

  insert into public.sessao_questoes_planejadas (sessao_id, questao_id, ordem)
  select v_sessao_id, x.questao_id, x.ordem::integer
  from unnest(v_ids) with ordinality x(questao_id, ordem);

  return query select v_sessao_id, v_status, v_ids, false;
end;
$function$;

revoke all on function public.iniciar_sessao_questoes_avulsa(text, integer, bigint, bigint) from public, anon;
grant execute on function public.iniciar_sessao_questoes_avulsa(text, integer, bigint, bigint) to authenticated;
