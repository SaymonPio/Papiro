-- Fase 2J-E: progresso da teoria por unidade pedagógica.
--
-- O cliente informa somente a missão e a versão publicada que acabou de
-- estudar. Usuário, conteúdo, unidade, totais e estado final são resolvidos
-- no servidor. A linha da missão é travada durante toda a leitura/escrita.
begin;

create function public.registrar_unidade_teoria_concluida(
  p_missao_id uuid,
  p_aula_versao_id uuid
)
returns table (
  missao_id uuid,
  status text,
  unidade_pedagogica_id uuid,
  aula_versao_id uuid,
  total_unidades integer,
  unidades_concluidas integer,
  teoria_concluida boolean,
  progresso_teoria jsonb
)
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_usuario_id uuid;
  v_missao_id uuid;
  v_conteudo_id bigint;
  v_status_atual text;
  v_progresso_atual jsonb;
  v_teoria_concluida_em timestamptz;
  v_unidade_id uuid;

  v_item jsonb;
  v_item_unidade_id uuid;
  v_item_versao_id uuid;
  v_unidades_concluidas_ids uuid[] := '{}';
  v_versoes_concluidas_ids uuid[] := '{}';
  v_total_unidades integer;
  v_total_concluidas integer;
  v_teoria_concluida boolean;
  v_novo_status text;
  v_novo_teoria_concluida_em timestamptz;
  v_unidades_json jsonb;
  v_novo_progresso jsonb;
begin
  v_usuario_id := auth.uid();
  if v_usuario_id is null then
    raise exception 'Usuario nao autenticado';
  end if;

  select ms.id, ms.conteudo_id, ms.status, ms.progresso_teoria, ms.teoria_concluida_em
  into v_missao_id, v_conteudo_id, v_status_atual, v_progresso_atual, v_teoria_concluida_em
  from public.missoes ms
  join public.matriculas m on m.id = ms.matricula_id
  where ms.id = p_missao_id
    and m.usuario_id = v_usuario_id
    and m.status = 'ativa'
  for update of ms;

  if v_missao_id is null then
    raise exception 'Missao nao encontrada, nao pertence ao usuario autenticado, ou a matricula nao esta ativa';
  end if;

  if v_status_atual = 'abandonada' then
    raise exception 'Esta missao esta abandonada e nao aceita novo progresso de teoria';
  end if;

  -- A versão precisa ser a versão publicada atual de uma aula ativa ligada a
  -- uma unidade ativa do conteúdo canônico da missão.
  select u.id
  into v_unidade_id
  from public.aula_versoes av
  join public.aulas a on a.id = av.aula_id and a.ativa = true
  join public.unidades_pedagogicas u
    on u.id = a.unidade_pedagogica_id
   and u.curso_conteudo_id = a.conteudo_id
   and u.ativa = true
  where av.id = p_aula_versao_id
    and av.status = 'publicada'
    and a.conteudo_id = v_conteudo_id;

  if v_unidade_id is null then
    raise exception 'Versao publicada nao encontrada para o conteudo desta missao';
  end if;

  select count(*)::integer
  into v_total_unidades
  from public.unidades_pedagogicas u
  join public.aulas a on a.unidade_pedagogica_id = u.id and a.ativa = true
  join public.aula_versoes av on av.aula_id = a.id and av.status = 'publicada'
  where u.curso_conteudo_id = v_conteudo_id
    and u.ativa = true;

  -- Contrato V2:
  -- {"schema_version":2,"unidades_concluidas":[
  --   {"unidade_pedagogica_id":"uuid","aula_versao_id":"uuid"}
  -- ]}
  -- Não há progresso V1 gravado em produção no momento desta migration.
  if v_progresso_atual = '{}'::jsonb then
    null;
  elsif jsonb_typeof(v_progresso_atual) = 'object'
    and (v_progresso_atual -> 'schema_version') = to_jsonb(2::integer)
    and jsonb_typeof(v_progresso_atual -> 'unidades_concluidas') = 'array'
  then
    for v_item in select * from jsonb_array_elements(v_progresso_atual -> 'unidades_concluidas')
    loop
      if jsonb_typeof(v_item) <> 'object'
        or jsonb_typeof(v_item -> 'unidade_pedagogica_id') is distinct from 'string'
        or jsonb_typeof(v_item -> 'aula_versao_id') is distinct from 'string'
      then
        raise exception 'progresso_teoria desta missao esta em formato invalido ou nao suportado';
      end if;

      begin
        v_item_unidade_id := (v_item ->> 'unidade_pedagogica_id')::uuid;
        v_item_versao_id := (v_item ->> 'aula_versao_id')::uuid;
      exception when invalid_text_representation then
        raise exception 'progresso_teoria desta missao esta em formato invalido ou nao suportado';
      end;

      if v_item_unidade_id = any(v_unidades_concluidas_ids) then
        raise exception 'progresso_teoria desta missao esta em formato invalido ou nao suportado';
      end if;

      -- Se uma versão foi substituída depois da conclusão, a entrada antiga é
      -- descartada e a nova versão volta a aparecer como pendente.
      if exists (
        select 1
        from public.unidades_pedagogicas u
        join public.aulas a on a.unidade_pedagogica_id = u.id and a.ativa = true
        join public.aula_versoes av on av.aula_id = a.id and av.status = 'publicada'
        where u.id = v_item_unidade_id
          and u.curso_conteudo_id = v_conteudo_id
          and u.ativa = true
          and av.id = v_item_versao_id
      ) then
        v_unidades_concluidas_ids := array_append(v_unidades_concluidas_ids, v_item_unidade_id);
        v_versoes_concluidas_ids := array_append(v_versoes_concluidas_ids, v_item_versao_id);
      end if;
    end loop;
  else
    raise exception 'progresso_teoria desta missao esta em formato invalido ou nao suportado';
  end if;

  if not (v_unidade_id = any(v_unidades_concluidas_ids)) then
    v_unidades_concluidas_ids := array_append(v_unidades_concluidas_ids, v_unidade_id);
    v_versoes_concluidas_ids := array_append(v_versoes_concluidas_ids, p_aula_versao_id);
  end if;

  v_total_concluidas := coalesce(array_length(v_unidades_concluidas_ids, 1), 0);
  v_teoria_concluida := v_total_unidades > 0 and v_total_concluidas = v_total_unidades;
  v_novo_status := v_status_atual;
  v_novo_teoria_concluida_em := v_teoria_concluida_em;

  if v_teoria_concluida and v_status_atual = 'iniciada' then
    v_novo_status := 'teoria_concluida';
    v_novo_teoria_concluida_em := coalesce(v_teoria_concluida_em, now());
  end if;

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'unidade_pedagogica_id', x.unidade_id::text,
        'aula_versao_id', x.versao_id::text
      )
      order by u.ordem, x.unidade_id
    ),
    '[]'::jsonb
  )
  into v_unidades_json
  from unnest(v_unidades_concluidas_ids, v_versoes_concluidas_ids) x(unidade_id, versao_id)
  join public.unidades_pedagogicas u on u.id = x.unidade_id;

  v_novo_progresso := jsonb_build_object(
    'schema_version', 2,
    'unidades_concluidas', v_unidades_json
  );

  update public.missoes
  set progresso_teoria = v_novo_progresso,
      status = v_novo_status,
      teoria_concluida_em = v_novo_teoria_concluida_em
  where id = v_missao_id;

  return query
  select
    v_missao_id,
    v_novo_status,
    v_unidade_id,
    p_aula_versao_id,
    v_total_unidades,
    v_total_concluidas,
    v_teoria_concluida,
    v_novo_progresso;
end;
$function$;

revoke execute on function public.registrar_unidade_teoria_concluida(uuid, uuid) from public;
revoke execute on function public.registrar_unidade_teoria_concluida(uuid, uuid) from anon;
grant execute on function public.registrar_unidade_teoria_concluida(uuid, uuid) to authenticated;

commit;
