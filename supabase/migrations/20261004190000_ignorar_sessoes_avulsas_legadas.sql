-- Hotfix: iniciar_sessao_questoes_avulsa estava considerando QUALQUER
-- sessoes_estudo 'em_andamento' (missao_id null) compatível como
-- recuperável, mesmo sem nenhuma linha em sessao_questoes_planejadas.
-- Isso inclui as 72 sessões avulsas legadas criadas pelo caminho antigo
-- (INSERT direto no cliente, anterior à migration 20261004180000), que
-- nunca persistiam a lista planejada. Resultado: toda nova tentativa de
-- meta diária/personalizada que batesse no mesmo filtro travava essa
-- sessão legada, encontrava lista vazia e abortava com
-- 'Sessao avulsa sem lista de questoes planejadas' — bloqueio
-- permanente, não transitório, pois a linha legada nunca muda de status.
--
-- Correção: a própria seleção da sessão recuperável agora exige, via
-- EXISTS, que já exista pelo menos uma linha em sessao_questoes_planejadas
-- para ela. Sessões legadas sem lista nunca são candidatas — são
-- ignoradas, nunca bloqueiam a criação de uma sessão nova. Também
-- adicionada a exigência de que a sessão recuperada pertença à MESMA
-- matrícula ativa (s.matricula_id = v_matricula_id), ausente na versão
-- anterior.
--
-- Nenhuma linha legada é alterada por esta migration (nenhum UPDATE/
-- DELETE) — o saneamento dos dados órfãos é deliberadamente deixado para
-- uma decisão de produto separada. Assinatura pública da função
-- inalterada; apenas o corpo é substituído.

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

  -- Assunto sem matéria não tem como ser validado contra o curso —
  -- mesma regra já aplicada dentro de ids_questoes_para_usuario.
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

  -- Recuperação idempotente: só é candidata uma sessão em_andamento que
  -- já tenha lista planejada persistida (EXISTS abaixo) — sessões
  -- legadas sem nenhuma linha em sessao_questoes_planejadas nunca
  -- entram aqui, então nunca bloqueiam a criação de uma sessão nova.
  -- Trava a linha encontrada para serializar contra uma segunda chamada
  -- concorrente (duplo clique, retry de rede, StrictMode).
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

  -- Nenhuma sessão compatível e válida em andamento: seleciona questões
  -- e cria do zero. ids_questoes_para_usuario já valida materia/assunto
  -- contra o curso ativo internamente (nunca confia em IDs arbitrários).
  select array_agg(q.questao_id)
  into v_ids
  from public.ids_questoes_para_usuario(p_quantidade, p_materia_id, p_assunto_id) as q(questao_id);

  v_total_ids := coalesce(cardinality(v_ids), 0);
  if v_total_ids = 0 then
    raise exception 'Nao ha questoes disponiveis para este filtro';
  end if;

  insert into public.sessoes_estudo (
    usuario_id, matricula_id, nivel_meta, status,
    inicio_em, minutos_revisao, questoes_planejadas,
    materia_id, assunto_id
  ) values (
    v_usuario_id, v_matricula_id, p_nivel_meta, 'em_andamento',
    clock_timestamp(), 0, v_total_ids,
    p_materia_id, p_assunto_id
  ) returning id, status into v_sessao_id, v_status;

  insert into public.sessao_questoes_planejadas (sessao_id, questao_id, ordem)
  select v_sessao_id, x.questao_id, x.ordem::integer
  from unnest(v_ids) with ordinality x(questao_id, ordem);

  return query select v_sessao_id, v_status, v_ids, false;
end;
$function$;

-- Assinatura inalterada (mesmos 4 parâmetros/tipos) — CREATE OR REPLACE
-- preserva os grants já concedidos pela migration 20261004180000.
-- Reafirmados explicitamente aqui apenas por clareza/auditoria, sem
-- mudança de efeito prático.
revoke all on function public.iniciar_sessao_questoes_avulsa(text, integer, bigint, bigint) from public, anon;
grant execute on function public.iniciar_sessao_questoes_avulsa(text, integer, bigint, bigint) to authenticated;
