-- ============================================================================
-- TESTE RUNTIME COMPLETO DA FASE 2I — TRANSACIONAL, TUDO DESFEITO NO FINAL
-- ============================================================================
--
-- Arquivo SEPARADO da migration real (supabase/teoria_progresso_rpc.sql,
-- que continua terminando em COMMIT). Este aqui é só para colar no SQL
-- Editor do Supabase, rodar de uma vez, ler o resultado, e nunca persistir
-- nada.
--
-- Mesma técnica de simulação de auth.uid() já usada no harness da Fase 2F
-- (supabase/teoria_leitura_rpc_teste_rollback.sql): set_config de
-- request.jwt.claims + SET LOCAL ROLE, ambos "local" à transação, desfeitos
-- automaticamente no ROLLBACK final mesmo que algum bloco esqueça de
-- resetar explicitamente. NÃO insere em auth.users.
--
-- public.aulas tem UNIQUE(conteudo_id): o harness reserva, no início, até
-- 15 curso_conteudos do MESMO curso da matrícula de teste que ainda não
-- têm nenhuma linha em public.aulas. Cada cenário usa um conteúdo livre
-- PRÓPRIO — nunca reaproveita missão real preexistente (ver nota sobre
-- data_missao sintética abaixo). Se o banco real não tiver todos os 15
-- disponíveis, os testes que dependem dos índices faltantes são pulados
-- com NULL + RAISE NOTICE — nunca inventados. Só aborta tudo (RAISE
-- EXCEPTION) se não houver NENHUMA matrícula ativa real ou NENHUM
-- conteúdo livre (nem para o teste principal).
--
-- Missões de teste NUNCA reaproveitam uma missão real via ON CONFLICT: TODA
-- missão criada por este harness usa data_missao = date '2000-01-01' (data
-- sintética, fora de qualquer fluxo real do produto) em vez do default
-- (data de hoje) — como cada cenário usa um conteudo_id distinto, essa
-- data fixa nunca colide entre cenários, e o INSERT é direto (sem ON
-- CONFLICT DO NOTHING + fallback), então qualquer colisão inesperada falha
-- alto (capturada pelo handler do próprio bloco) em vez de silenciosamente
-- reutilizar dados de uma missão real. A missão principal (Aula A) também
-- recebe atualizado_em explicitamente antigo (now() - interval '1 day') no
-- INSERT — necessário porque now()/transaction_timestamp() NÃO avança
-- dentro de uma mesma transação no Postgres: comparar atualizado_em contra
-- um valor deliberadamente antigo prova que o trigger BEFORE UPDATE
-- realmente rodou, em vez de depender do relógio avançar (o que nunca
-- acontece aqui).
--
-- Segundo usuário real (para "outro usuário bloqueado") também é
-- OPCIONAL: se não existir, os testes que dependem dele ficam NULL +
-- NOTICE, sem inventar auth.users.

BEGIN;

create temporary table teste_2i_contexto (
  chave text primary key,
  valor text
);

create temporary table teste_2i_resultados (
  chave text primary key,
  ok boolean
);

create temporary table teste_2i_conteudos_livres (
  indice integer primary key,
  conteudo_id bigint
);

-- ============================================================================
-- Contexto: matrícula ativa real, até 15 curso_conteudos livres (sem
-- aula), segundo usuário real (opcional)
-- ============================================================================
do $$
declare
  v_matricula_id uuid;
  v_usuario_id uuid;
  v_curso_id uuid;
  v_segundo_usuario_id uuid;
  v_conteudo_id bigint;
  v_indice integer := 0;
begin
  select m.id, m.usuario_id, m.curso_id
  into v_matricula_id, v_usuario_id, v_curso_id
  from public.matriculas m
  where m.status = 'ativa'
  order by m.id
  limit 1;

  if v_matricula_id is null then
    raise exception 'Teste abortado: nenhuma matricula ativa real encontrada.';
  end if;

  select m2.usuario_id into v_segundo_usuario_id
  from public.matriculas m2
  where m2.usuario_id <> v_usuario_id
  order by m2.id
  limit 1;

  for v_conteudo_id in
    select cc.id
    from public.curso_conteudos cc
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cm.curso_id = v_curso_id
      and not exists (select 1 from public.aulas a where a.conteudo_id = cc.id)
    order by cc.id
    limit 15
  loop
    v_indice := v_indice + 1;
    insert into teste_2i_conteudos_livres (indice, conteudo_id) values (v_indice, v_conteudo_id);
  end loop;

  if v_indice = 0 then
    raise exception 'Teste abortado: nenhum curso_conteudos livre (sem aula) encontrado para o curso da matricula de teste.';
  end if;

  insert into teste_2i_contexto (chave, valor) values
    ('matricula_id', v_matricula_id::text),
    ('usuario_id', v_usuario_id::text),
    ('curso_id', v_curso_id::text),
    ('segundo_usuario_id', coalesce(v_segundo_usuario_id::text, '')),
    ('total_conteudos_livres', v_indice::text);
end $$;

-- ============================================================================
-- CORPO DA MIGRATION (idêntico a supabase/teoria_progresso_rpc.sql, sem o
-- COMMIT final)
-- ============================================================================

create function public.registrar_componente_teoria_concluido(
  p_missao_id uuid,
  p_aula_versao_id uuid,
  p_componente_id uuid
)
returns table (
  missao_id uuid,
  status text,
  aula_versao_id uuid,
  componente_id uuid,
  total_componentes integer,
  componentes_concluidos integer,
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

  v_aula_versao_id_real uuid;
  v_estrutura jsonb;
  v_componentes jsonb;

  v_elem jsonb;
  v_id_texto text;
  v_id uuid;
  v_ids_validos uuid[] := '{}';
  v_total_componentes integer;

  v_progresso_aula_versao_id uuid;
  v_ids_concluidos uuid[] := '{}';
  v_total_concluidos integer;
  v_teoria_concluida boolean;

  v_novo_status text;
  v_novo_teoria_concluida_em timestamptz;
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

  select av.id, av.estrutura
  into v_aula_versao_id_real, v_estrutura
  from public.aula_versoes av
  join public.aulas a on a.id = av.aula_id
  where av.id = p_aula_versao_id
    and av.status = 'publicada'
    and a.conteudo_id = v_conteudo_id
    and a.ativa = true;

  if v_aula_versao_id_real is null then
    raise exception 'Aula publicada % nao encontrada para o conteudo desta missao', p_aula_versao_id;
  end if;

  v_componentes := v_estrutura -> 'componentes';

  if v_componentes is null or jsonb_typeof(v_componentes) <> 'array' then
    raise exception 'A versao publicada % nao possui "componentes" como array — nao segue o contrato V1 de progresso', p_aula_versao_id;
  end if;

  for v_elem in select * from jsonb_array_elements(v_componentes)
  loop
    if jsonb_typeof(v_elem) <> 'object' then
      raise exception 'Componente invalido na estrutura da versao % (nao e um objeto JSON)', p_aula_versao_id;
    end if;

    if jsonb_typeof(v_elem -> 'id') is distinct from 'string' then
      raise exception 'Componente sem "id" valido (precisa ser uma string JSON) na estrutura da versao %', p_aula_versao_id;
    end if;

    v_id_texto := v_elem ->> 'id';

    begin
      v_id := v_id_texto::uuid;
    exception when invalid_text_representation then
      raise exception 'Componente com "id" que nao e um UUID valido (%) na estrutura da versao %', v_id_texto, p_aula_versao_id;
    end;

    if jsonb_typeof(v_elem -> 'tipo') is distinct from 'string' then
      raise exception 'Componente % sem "tipo" valido (precisa ser uma string JSON) na estrutura da versao %', v_id, p_aula_versao_id;
    end if;

    if v_id = any(v_ids_validos) then
      raise exception 'Ids de componentes duplicados na estrutura da versao % (%)', p_aula_versao_id, v_id;
    end if;

    v_ids_validos := array_append(v_ids_validos, v_id);
  end loop;

  v_total_componentes := coalesce(array_length(v_ids_validos, 1), 0);

  if v_total_componentes = 0 or not (p_componente_id = any(v_ids_validos)) then
    raise exception 'Componente % nao existe na versao publicada %', p_componente_id, p_aula_versao_id;
  end if;

  if v_progresso_atual = '{}'::jsonb then
    v_ids_concluidos := '{}';
  elsif jsonb_typeof(v_progresso_atual) = 'object'
    and (v_progresso_atual -> 'schema_version') = to_jsonb(1::int)
    and jsonb_typeof(v_progresso_atual -> 'aula_versao_id') = 'string'
    and jsonb_typeof(v_progresso_atual -> 'componentes_concluidos') = 'array'
  then
    begin
      v_progresso_aula_versao_id := (v_progresso_atual ->> 'aula_versao_id')::uuid;
    exception when invalid_text_representation then
      raise exception 'progresso_teoria desta missao esta em formato invalido ou nao suportado';
    end;

    if v_progresso_aula_versao_id is distinct from p_aula_versao_id then
      raise exception 'Esta missao ja tem progresso de teoria registrado para a versao %; nao e possivel misturar com a versao % informada agora', v_progresso_aula_versao_id, p_aula_versao_id;
    end if;

    for v_elem in select * from jsonb_array_elements(v_progresso_atual -> 'componentes_concluidos')
    loop
      if jsonb_typeof(v_elem) is distinct from 'string' then
        raise exception 'progresso_teoria desta missao esta em formato invalido ou nao suportado';
      end if;

      begin
        v_id := (v_elem #>> '{}')::uuid;
      exception when invalid_text_representation then
        raise exception 'progresso_teoria desta missao esta em formato invalido ou nao suportado';
      end;

      if not (v_id = any(v_ids_validos)) then
        raise exception 'progresso_teoria desta missao esta em formato invalido ou nao suportado';
      end if;

      if v_id = any(v_ids_concluidos) then
        raise exception 'progresso_teoria desta missao esta em formato invalido ou nao suportado';
      end if;

      v_ids_concluidos := array_append(v_ids_concluidos, v_id);
    end loop;
  else
    raise exception 'progresso_teoria desta missao esta em formato invalido ou nao suportado';
  end if;

  if not (p_componente_id = any(v_ids_concluidos)) then
    v_ids_concluidos := array_append(v_ids_concluidos, p_componente_id);
  end if;

  v_total_concluidos := coalesce(array_length(v_ids_concluidos, 1), 0);
  v_teoria_concluida := v_total_concluidos = v_total_componentes;

  v_novo_status := v_status_atual;
  v_novo_teoria_concluida_em := v_teoria_concluida_em;

  if v_teoria_concluida and v_status_atual = 'iniciada' then
    v_novo_status := 'teoria_concluida';
    if v_novo_teoria_concluida_em is null then
      v_novo_teoria_concluida_em := now();
    end if;
  end if;

  v_novo_progresso := jsonb_build_object(
    'schema_version', 1,
    'aula_versao_id', p_aula_versao_id::text,
    'componentes_concluidos', to_jsonb(v_ids_concluidos)
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
    p_aula_versao_id,
    p_componente_id,
    v_total_componentes,
    v_total_concluidos,
    v_teoria_concluida,
    v_novo_progresso;
end;
$function$;

revoke execute on function public.registrar_componente_teoria_concluido(uuid, uuid, uuid) from public;
revoke execute on function public.registrar_componente_teoria_concluido(uuid, uuid, uuid) from anon;
grant execute on function public.registrar_componente_teoria_concluido(uuid, uuid, uuid) to authenticated;

-- ============================================================================
-- FIM DO CORPO DA MIGRATION — daqui pra baixo é só o TEST HARNESS
-- ============================================================================

-- ---------------------------------------------------------------------------
-- Checagens estruturais (catálogo do Postgres) — 1 a 4
-- ---------------------------------------------------------------------------

insert into teste_2i_resultados values (
  'rpc_existe',
  exists (
    select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'registrar_componente_teoria_concluido'
  )
);

insert into teste_2i_resultados values (
  'authenticated_pode_executar',
  has_function_privilege('authenticated', 'public.registrar_componente_teoria_concluido(uuid,uuid,uuid)', 'EXECUTE')
);

insert into teste_2i_resultados values (
  'anon_nao_pode_executar',
  not has_function_privilege('anon', 'public.registrar_componente_teoria_concluido(uuid,uuid,uuid)', 'EXECUTE')
);

insert into teste_2i_resultados values (
  'public_nao_pode_executar',
  not exists (
    select 1 from information_schema.routine_privileges
    where routine_schema = 'public' and routine_name = 'registrar_componente_teoria_concluido'
      and grantee = 'PUBLIC' and privilege_type = 'EXECUTE'
  )
);

-- ---------------------------------------------------------------------------
-- Aula A (índice 1) — versão 1 publicada com 2 componentes válidos
-- (COMP_A1, COMP_A2) + missão de teste PRÓPRIA (data_missao sintética,
-- atualizado_em deliberadamente antigo para o teste de trigger).
-- ---------------------------------------------------------------------------
do $$
declare
  v_conteudo_id bigint;
  v_matricula_id uuid;
  v_aula_id uuid;
  v_versao1_id uuid;
  v_comp_a1 uuid := gen_random_uuid();
  v_comp_a2 uuid := gen_random_uuid();
  v_missao_id uuid;
  v_atualizado_inicial timestamptz := now() - interval '1 day';
begin
  select conteudo_id into v_conteudo_id from teste_2i_conteudos_livres where indice = 1;
  select valor::uuid into v_matricula_id from teste_2i_contexto where chave = 'matricula_id';

  if v_conteudo_id is null then
    raise exception 'Sem conteudo livre no indice 1 -- necessario para os testes principais desta fase.';
  end if;

  insert into public.aulas (conteudo_id, titulo)
  values (v_conteudo_id, '[TESTE FASE 2I] Aula A')
  returning id into v_aula_id;

  insert into public.aula_versoes (aula_id, numero_versao, status, estrutura, publicado_em)
  values (
    v_aula_id, 1, 'publicada',
    jsonb_build_object('componentes', jsonb_build_array(
      jsonb_build_object('id', v_comp_a1::text, 'tipo', 'diagnostico'),
      jsonb_build_object('id', v_comp_a2::text, 'tipo', 'conceito')
    )),
    now()
  )
  returning id into v_versao1_id;

  -- data_missao sintetica (nunca a de hoje) + INSERT direto sem ON
  -- CONFLICT: garante uma missao de teste PROPRIA, nunca reaproveita uma
  -- missao real. atualizado_em deliberadamente antigo -- ver nota no
  -- cabecalho do arquivo sobre o teste de trigger. O baseline
  -- (v_atualizado_inicial) e guardado em teste_2i_contexto porque, dentro
  -- desta mesma transacao, now() nunca avanca -- um SELECT feito entre a
  -- 1a e a 2a chamada da RPC ja devolveria o atualizado_em posto pela 1a
  -- chamada (tambem now()), tornando a comparacao "depois > antes" sempre
  -- FALSE por construcao. Comparar sempre contra este baseline original
  -- (anterior a QUALQUER chamada da RPC) e o unico jeito de provar que o
  -- trigger rodou.
  insert into public.missoes (matricula_id, conteudo_id, data_missao, atualizado_em)
  values (v_matricula_id, v_conteudo_id, date '2000-01-01', v_atualizado_inicial)
  returning id into v_missao_id;

  insert into teste_2i_contexto (chave, valor) values
    ('aula_a_id', v_aula_id::text),
    ('aula_a_versao1_id', v_versao1_id::text),
    ('comp_a1', v_comp_a1::text),
    ('comp_a2', v_comp_a2::text),
    ('missao_1_id', v_missao_id::text),
    ('missao_1_atualizado_inicial', v_atualizado_inicial::text);
exception when others then
  raise notice 'Falha ao preparar Aula A / missao 1: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- Chamada sem auth.uid() deve falhar.
-- ---------------------------------------------------------------------------
do $$
declare
  v_missao_id uuid;
  v_aula_versao_id uuid;
  v_comp_a1 uuid;
  v_bloqueado boolean;
begin
  select valor::uuid into v_missao_id from teste_2i_contexto where chave = 'missao_1_id';
  select valor::uuid into v_aula_versao_id from teste_2i_contexto where chave = 'aula_a_versao1_id';
  select valor::uuid into v_comp_a1 from teste_2i_contexto where chave = 'comp_a1';

  if v_missao_id is null then
    insert into teste_2i_resultados values ('sem_auth_bloqueado', null);
    raise notice 'sem_auth_bloqueado pulado: dados da Aula A nao disponiveis.';
    return;
  end if;

  perform set_config('request.jwt.claims', json_build_object('role', 'authenticated')::text, true);
  set local role authenticated;

  begin
    perform * from public.registrar_componente_teoria_concluido(v_missao_id, v_aula_versao_id, v_comp_a1);
    v_bloqueado := false;
  exception when others then
    v_bloqueado := true;
  end;

  reset role;
  insert into teste_2i_resultados values ('sem_auth_bloqueado', v_bloqueado);
exception when others then
  reset role;
  insert into teste_2i_resultados values ('sem_auth_bloqueado', false);
  raise notice 'Teste sem_auth_bloqueado falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- Reforço dinâmico: anon tentando executar de verdade.
-- ---------------------------------------------------------------------------
do $$
declare
  v_missao_id uuid;
  v_aula_versao_id uuid;
  v_comp_a1 uuid;
  v_bloqueado boolean := false;
begin
  select valor::uuid into v_missao_id from teste_2i_contexto where chave = 'missao_1_id';
  select valor::uuid into v_aula_versao_id from teste_2i_contexto where chave = 'aula_a_versao1_id';
  select valor::uuid into v_comp_a1 from teste_2i_contexto where chave = 'comp_a1';

  if v_missao_id is null then
    return;
  end if;

  set local role anon;
  begin
    perform * from public.registrar_componente_teoria_concluido(v_missao_id, v_aula_versao_id, v_comp_a1);
    v_bloqueado := false;
  exception
    when insufficient_privilege then v_bloqueado := true;
    when others then v_bloqueado := false;
  end;
  reset role;

  update teste_2i_resultados set ok = (coalesce(ok, true) and v_bloqueado) where chave = 'anon_nao_pode_executar';
exception when others then
  reset role;
  update teste_2i_resultados set ok = false where chave = 'anon_nao_pode_executar';
  raise notice 'Reforco live de anon_nao_pode_executar falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- Conclui o 1º componente (COMP_A1) como o dono real da missão.
-- ---------------------------------------------------------------------------
do $$
declare
  v_usuario_id uuid;
  v_missao_id uuid;
  v_aula_versao_id uuid;
  v_comp_a1 uuid;
  r record;
  v_ok_dono boolean := false;
  v_ok_componente boolean := false;
  v_ok_schema_version boolean := false;
  v_ok_aula_versao boolean := false;
  v_ok_sem_duplicata boolean := false;
  v_ok_status_permanece boolean := false;
begin
  select valor::uuid into v_usuario_id from teste_2i_contexto where chave = 'usuario_id';
  select valor::uuid into v_missao_id from teste_2i_contexto where chave = 'missao_1_id';
  select valor::uuid into v_aula_versao_id from teste_2i_contexto where chave = 'aula_a_versao1_id';
  select valor::uuid into v_comp_a1 from teste_2i_contexto where chave = 'comp_a1';

  if v_usuario_id is null or v_missao_id is null then
    raise exception 'contexto ausente para o teste principal de conclusao de componente';
  end if;

  perform set_config('request.jwt.claims', json_build_object('sub', v_usuario_id::text, 'role', 'authenticated')::text, true);
  set local role authenticated;

  select * into r from public.registrar_componente_teoria_concluido(v_missao_id, v_aula_versao_id, v_comp_a1);

  v_ok_dono := (r.missao_id = v_missao_id);
  v_ok_componente := (
    r.componente_id = v_comp_a1
    and jsonb_typeof(r.progresso_teoria -> 'componentes_concluidos') = 'array'
    and exists (
      select 1 from jsonb_array_elements_text(r.progresso_teoria -> 'componentes_concluidos') x
      where x::uuid = v_comp_a1
    )
  );
  v_ok_schema_version := ((r.progresso_teoria -> 'schema_version') = to_jsonb(1::int));
  v_ok_aula_versao := (
    r.aula_versao_id = v_aula_versao_id
    and (r.progresso_teoria ->> 'aula_versao_id')::uuid = v_aula_versao_id
  );
  v_ok_sem_duplicata := (
    (select count(*) from jsonb_array_elements_text(r.progresso_teoria -> 'componentes_concluidos')) = 1
  );
  v_ok_status_permanece := (
    r.status = 'iniciada' and r.teoria_concluida = false
    and r.total_componentes = 2 and r.componentes_concluidos = 1
  );

  reset role;

  insert into teste_2i_resultados values ('usuario_dono_pode_registrar', v_ok_dono);
  insert into teste_2i_resultados values ('componente_existente_registrado', v_ok_componente);
  insert into teste_2i_resultados values ('progresso_schema_version_1', v_ok_schema_version);
  insert into teste_2i_resultados values ('aula_versao_id_correto', v_ok_aula_versao);
  insert into teste_2i_resultados values ('ids_concluidos_sem_duplicata', v_ok_sem_duplicata);
  insert into teste_2i_resultados values ('status_permanece_iniciada_antes_do_ultimo_componente', v_ok_status_permanece);
exception when others then
  reset role;
  insert into teste_2i_resultados values ('usuario_dono_pode_registrar', false);
  insert into teste_2i_resultados values ('componente_existente_registrado', false);
  insert into teste_2i_resultados values ('progresso_schema_version_1', false);
  insert into teste_2i_resultados values ('aula_versao_id_correto', false);
  insert into teste_2i_resultados values ('ids_concluidos_sem_duplicata', false);
  insert into teste_2i_resultados values ('status_permanece_iniciada_antes_do_ultimo_componente', false);
  raise notice 'Teste principal (conclusao do 1o componente) falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- Repete a MESMA chamada (COMP_A1 de novo) — precisa ser idempotente.
-- ---------------------------------------------------------------------------
do $$
declare
  v_usuario_id uuid;
  v_missao_id uuid;
  v_aula_versao_id uuid;
  v_comp_a1 uuid;
  r record;
  v_ok boolean;
begin
  select valor::uuid into v_usuario_id from teste_2i_contexto where chave = 'usuario_id';
  select valor::uuid into v_missao_id from teste_2i_contexto where chave = 'missao_1_id';
  select valor::uuid into v_aula_versao_id from teste_2i_contexto where chave = 'aula_a_versao1_id';
  select valor::uuid into v_comp_a1 from teste_2i_contexto where chave = 'comp_a1';

  perform set_config('request.jwt.claims', json_build_object('sub', v_usuario_id::text, 'role', 'authenticated')::text, true);
  set local role authenticated;

  select * into r from public.registrar_componente_teoria_concluido(v_missao_id, v_aula_versao_id, v_comp_a1);

  v_ok := (
    r.componentes_concluidos = 1
    and r.status = 'iniciada'
    and (select count(*) from jsonb_array_elements_text(r.progresso_teoria -> 'componentes_concluidos')) = 1
  );

  reset role;
  insert into teste_2i_resultados values ('chamada_repetida_idempotente', v_ok);
exception when others then
  reset role;
  insert into teste_2i_resultados values ('chamada_repetida_idempotente', false);
  raise notice 'Teste chamada_repetida_idempotente falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- Componente que não existe na versão publicada precisa ser bloqueado.
-- ---------------------------------------------------------------------------
do $$
declare
  v_usuario_id uuid;
  v_missao_id uuid;
  v_aula_versao_id uuid;
  v_bloqueado boolean;
begin
  select valor::uuid into v_usuario_id from teste_2i_contexto where chave = 'usuario_id';
  select valor::uuid into v_missao_id from teste_2i_contexto where chave = 'missao_1_id';
  select valor::uuid into v_aula_versao_id from teste_2i_contexto where chave = 'aula_a_versao1_id';

  perform set_config('request.jwt.claims', json_build_object('sub', v_usuario_id::text, 'role', 'authenticated')::text, true);
  set local role authenticated;

  begin
    perform * from public.registrar_componente_teoria_concluido(v_missao_id, v_aula_versao_id, gen_random_uuid());
    v_bloqueado := false;
  exception when others then
    v_bloqueado := true;
  end;

  reset role;
  insert into teste_2i_resultados values ('componente_inexistente_bloqueado', v_bloqueado);
exception when others then
  reset role;
  insert into teste_2i_resultados values ('componente_inexistente_bloqueado', false);
  raise notice 'Teste componente_inexistente_bloqueado falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- Missão de OUTRO usuário não pode ser lida/alterada.
-- ---------------------------------------------------------------------------
do $$
declare
  v_segundo_usuario text;
  v_missao_id uuid;
  v_aula_versao_id uuid;
  v_comp_a2 uuid;
  v_progresso_antes jsonb;
  v_progresso_depois jsonb;
  v_bloqueado boolean;
begin
  select valor into v_segundo_usuario from teste_2i_contexto where chave = 'segundo_usuario_id';
  select valor::uuid into v_missao_id from teste_2i_contexto where chave = 'missao_1_id';
  select valor::uuid into v_aula_versao_id from teste_2i_contexto where chave = 'aula_a_versao1_id';
  select valor::uuid into v_comp_a2 from teste_2i_contexto where chave = 'comp_a2';

  if v_segundo_usuario is null or v_segundo_usuario = '' then
    insert into teste_2i_resultados values ('outro_usuario_bloqueado', null);
    insert into teste_2i_resultados values ('nenhuma_missao_de_outro_usuario_alterada', null);
    raise notice 'Testes de outro usuario pulados: nao ha um segundo usuario/matricula real distinto neste banco. Nao inventamos usuario (auth.users nao e tocado).';
    return;
  end if;

  select progresso_teoria into v_progresso_antes from public.missoes where id = v_missao_id;

  perform set_config('request.jwt.claims', json_build_object('sub', v_segundo_usuario, 'role', 'authenticated')::text, true);
  set local role authenticated;

  begin
    perform * from public.registrar_componente_teoria_concluido(v_missao_id, v_aula_versao_id, v_comp_a2);
    v_bloqueado := false;
  exception when others then
    v_bloqueado := true;
  end;

  reset role;

  select progresso_teoria into v_progresso_depois from public.missoes where id = v_missao_id;

  insert into teste_2i_resultados values ('outro_usuario_bloqueado', v_bloqueado);
  insert into teste_2i_resultados values ('nenhuma_missao_de_outro_usuario_alterada', v_progresso_antes = v_progresso_depois);
exception when others then
  reset role;
  insert into teste_2i_resultados values ('outro_usuario_bloqueado', false);
  insert into teste_2i_resultados values ('nenhuma_missao_de_outro_usuario_alterada', false);
  raise notice 'Teste outro_usuario_bloqueado falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- Conclui o 2º e último componente (COMP_A2) — status muda para
-- 'teoria_concluida', teoria_concluida_em preenchido, atualizado_em
-- avança (comparado contra o valor deliberadamente antigo do INSERT).
-- ---------------------------------------------------------------------------
do $$
declare
  v_usuario_id uuid;
  v_missao_id uuid;
  v_aula_versao_id uuid;
  v_comp_a2 uuid;
  v_atualizado_baseline timestamptz;
  r record;
  v_ok_status boolean := false;
  v_ok_teoria_concluida_em boolean := false;
  v_ok_atualizado boolean := false;
begin
  select valor::uuid into v_usuario_id from teste_2i_contexto where chave = 'usuario_id';
  select valor::uuid into v_missao_id from teste_2i_contexto where chave = 'missao_1_id';
  select valor::uuid into v_aula_versao_id from teste_2i_contexto where chave = 'aula_a_versao1_id';
  select valor::uuid into v_comp_a2 from teste_2i_contexto where chave = 'comp_a2';

  -- Baseline ORIGINAL (o now() - 1 dia gravado no INSERT da Aula A, antes
  -- de QUALQUER chamada da RPC) -- nunca um SELECT feito agora, que já
  -- devolveria o atualizado_em posto pela 1ª chamada (também now(), já que
  -- now() não avança dentro desta transação). Comparar contra o baseline
  -- original é o único jeito de provar que o trigger rodou de verdade.
  select valor::timestamptz into v_atualizado_baseline
  from teste_2i_contexto where chave = 'missao_1_atualizado_inicial';

  perform set_config('request.jwt.claims', json_build_object('sub', v_usuario_id::text, 'role', 'authenticated')::text, true);
  set local role authenticated;

  select * into r from public.registrar_componente_teoria_concluido(v_missao_id, v_aula_versao_id, v_comp_a2);

  v_ok_status := (
    r.status = 'teoria_concluida' and r.teoria_concluida = true
    and r.componentes_concluidos = 2 and r.total_componentes = 2
  );

  reset role;

  v_ok_teoria_concluida_em := exists (
    select 1 from public.missoes where id = v_missao_id and teoria_concluida_em is not null
  );
  -- Não é possível provar que a 1ª e a 2ª chamada geraram atualizado_em
  -- diferentes ENTRE SI (now() é fixo durante toda a transação) — o que
  -- este teste prova é que pelo menos um UPDATE real da RPC avançou
  -- atualizado_em em relação ao baseline original (now() - 1 dia, gravado
  -- no INSERT, antes de qualquer chamada).
  v_ok_atualizado := exists (
    select 1 from public.missoes where id = v_missao_id and atualizado_em > v_atualizado_baseline
  );

  insert into teste_2i_resultados values ('ultimo_componente_muda_para_teoria_concluida', v_ok_status);
  insert into teste_2i_resultados values ('teoria_concluida_em_preenchido', v_ok_teoria_concluida_em);
  insert into teste_2i_resultados values ('atualizado_em_alterado_com_a_escrita', v_ok_atualizado);
exception when others then
  reset role;
  insert into teste_2i_resultados values ('ultimo_componente_muda_para_teoria_concluida', false);
  insert into teste_2i_resultados values ('teoria_concluida_em_preenchido', false);
  insert into teste_2i_resultados values ('atualizado_em_alterado_com_a_escrita', false);
  raise notice 'Teste conclusao do 2o componente falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- Republica a Aula A (versão 1 arquivada, versão 2 publicada com um
-- componente novo) — progresso já registrado contra a versão 1 bloqueia
-- tentar registrar contra a versão 2.
-- ---------------------------------------------------------------------------
do $$
declare
  v_usuario_id uuid;
  v_missao_id uuid;
  v_aula_a_id uuid;
  v_versao1_id uuid;
  v_versao2_id uuid;
  v_comp_a3 uuid := gen_random_uuid();
  v_bloqueado boolean;
begin
  select valor::uuid into v_usuario_id from teste_2i_contexto where chave = 'usuario_id';
  select valor::uuid into v_missao_id from teste_2i_contexto where chave = 'missao_1_id';
  select valor::uuid into v_aula_a_id from teste_2i_contexto where chave = 'aula_a_id';
  select valor::uuid into v_versao1_id from teste_2i_contexto where chave = 'aula_a_versao1_id';

  if v_missao_id is null then
    insert into teste_2i_resultados values ('versao_diferente_bloqueada', null);
    raise notice 'versao_diferente_bloqueada pulado: dados da Aula A nao disponiveis.';
    return;
  end if;

  update public.aula_versoes set status = 'arquivada' where id = v_versao1_id;

  insert into public.aula_versoes (aula_id, numero_versao, status, estrutura, publicado_em)
  values (
    v_aula_a_id, 2, 'publicada',
    jsonb_build_object('componentes', jsonb_build_array(
      jsonb_build_object('id', v_comp_a3::text, 'tipo', 'resumo_visual')
    )),
    now()
  )
  returning id into v_versao2_id;

  perform set_config('request.jwt.claims', json_build_object('sub', v_usuario_id::text, 'role', 'authenticated')::text, true);
  set local role authenticated;

  begin
    perform * from public.registrar_componente_teoria_concluido(v_missao_id, v_versao2_id, v_comp_a3);
    v_bloqueado := false;
  exception when others then
    v_bloqueado := true;
  end;

  reset role;
  insert into teste_2i_resultados values ('versao_diferente_bloqueada', v_bloqueado);
exception when others then
  reset role;
  insert into teste_2i_resultados values ('versao_diferente_bloqueada', false);
  raise notice 'Teste versao_diferente_bloqueada falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- Aula B (índice 2) — estrutura sem "componentes" como array.
-- ---------------------------------------------------------------------------
do $$
declare
  v_conteudo_id bigint;
  v_matricula_id uuid;
  v_usuario_id uuid;
  v_aula_id uuid;
  v_versao_id uuid;
  v_missao_id uuid;
  v_bloqueado boolean;
begin
  select conteudo_id into v_conteudo_id from teste_2i_conteudos_livres where indice = 2;
  select valor::uuid into v_matricula_id from teste_2i_contexto where chave = 'matricula_id';
  select valor::uuid into v_usuario_id from teste_2i_contexto where chave = 'usuario_id';

  if v_conteudo_id is null then
    insert into teste_2i_resultados values ('estrutura_sem_componentes_array_bloqueada', null);
    raise notice 'estrutura_sem_componentes_array_bloqueada pulado: sem conteudo livre no indice 2.';
    return;
  end if;

  insert into public.aulas (conteudo_id, titulo) values (v_conteudo_id, '[TESTE FASE 2I] Aula B')
  returning id into v_aula_id;

  insert into public.aula_versoes (aula_id, numero_versao, status, estrutura, publicado_em)
  values (v_aula_id, 1, 'publicada', '{"observacao": "sem componentes"}'::jsonb, now())
  returning id into v_versao_id;

  insert into public.missoes (matricula_id, conteudo_id, data_missao)
  values (v_matricula_id, v_conteudo_id, date '2000-01-01')
  returning id into v_missao_id;

  perform set_config('request.jwt.claims', json_build_object('sub', v_usuario_id::text, 'role', 'authenticated')::text, true);
  set local role authenticated;

  begin
    perform * from public.registrar_componente_teoria_concluido(v_missao_id, v_versao_id, gen_random_uuid());
    v_bloqueado := false;
  exception when others then
    v_bloqueado := true;
  end;

  reset role;
  insert into teste_2i_resultados values ('estrutura_sem_componentes_array_bloqueada', v_bloqueado);
exception when others then
  reset role;
  insert into teste_2i_resultados values ('estrutura_sem_componentes_array_bloqueada', false);
  raise notice 'Teste estrutura_sem_componentes_array_bloqueada falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- Aula C (índice 3) — componente sem "id".
-- ---------------------------------------------------------------------------
do $$
declare
  v_conteudo_id bigint;
  v_matricula_id uuid;
  v_usuario_id uuid;
  v_aula_id uuid;
  v_versao_id uuid;
  v_missao_id uuid;
  v_bloqueado boolean;
begin
  select conteudo_id into v_conteudo_id from teste_2i_conteudos_livres where indice = 3;
  select valor::uuid into v_matricula_id from teste_2i_contexto where chave = 'matricula_id';
  select valor::uuid into v_usuario_id from teste_2i_contexto where chave = 'usuario_id';

  if v_conteudo_id is null then
    insert into teste_2i_resultados values ('componente_sem_id_bloqueado', null);
    raise notice 'componente_sem_id_bloqueado pulado: sem conteudo livre no indice 3.';
    return;
  end if;

  insert into public.aulas (conteudo_id, titulo) values (v_conteudo_id, '[TESTE FASE 2I] Aula C')
  returning id into v_aula_id;

  insert into public.aula_versoes (aula_id, numero_versao, status, estrutura, publicado_em)
  values (v_aula_id, 1, 'publicada', '{"componentes": [{"tipo": "conceito"}]}'::jsonb, now())
  returning id into v_versao_id;

  insert into public.missoes (matricula_id, conteudo_id, data_missao)
  values (v_matricula_id, v_conteudo_id, date '2000-01-01')
  returning id into v_missao_id;

  perform set_config('request.jwt.claims', json_build_object('sub', v_usuario_id::text, 'role', 'authenticated')::text, true);
  set local role authenticated;

  begin
    perform * from public.registrar_componente_teoria_concluido(v_missao_id, v_versao_id, gen_random_uuid());
    v_bloqueado := false;
  exception when others then
    v_bloqueado := true;
  end;

  reset role;
  insert into teste_2i_resultados values ('componente_sem_id_bloqueado', v_bloqueado);
exception when others then
  reset role;
  insert into teste_2i_resultados values ('componente_sem_id_bloqueado', false);
  raise notice 'Teste componente_sem_id_bloqueado falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- Aula D (índice 4) — componente com "id" que não é UUID válido.
-- ---------------------------------------------------------------------------
do $$
declare
  v_conteudo_id bigint;
  v_matricula_id uuid;
  v_usuario_id uuid;
  v_aula_id uuid;
  v_versao_id uuid;
  v_missao_id uuid;
  v_bloqueado boolean;
begin
  select conteudo_id into v_conteudo_id from teste_2i_conteudos_livres where indice = 4;
  select valor::uuid into v_matricula_id from teste_2i_contexto where chave = 'matricula_id';
  select valor::uuid into v_usuario_id from teste_2i_contexto where chave = 'usuario_id';

  if v_conteudo_id is null then
    insert into teste_2i_resultados values ('componente_id_nao_uuid_bloqueado', null);
    raise notice 'componente_id_nao_uuid_bloqueado pulado: sem conteudo livre no indice 4.';
    return;
  end if;

  insert into public.aulas (conteudo_id, titulo) values (v_conteudo_id, '[TESTE FASE 2I] Aula D')
  returning id into v_aula_id;

  insert into public.aula_versoes (aula_id, numero_versao, status, estrutura, publicado_em)
  values (v_aula_id, 1, 'publicada', '{"componentes": [{"id": "nao-e-um-uuid", "tipo": "conceito"}]}'::jsonb, now())
  returning id into v_versao_id;

  insert into public.missoes (matricula_id, conteudo_id, data_missao)
  values (v_matricula_id, v_conteudo_id, date '2000-01-01')
  returning id into v_missao_id;

  perform set_config('request.jwt.claims', json_build_object('sub', v_usuario_id::text, 'role', 'authenticated')::text, true);
  set local role authenticated;

  begin
    perform * from public.registrar_componente_teoria_concluido(v_missao_id, v_versao_id, gen_random_uuid());
    v_bloqueado := false;
  exception when others then
    v_bloqueado := true;
  end;

  reset role;
  insert into teste_2i_resultados values ('componente_id_nao_uuid_bloqueado', v_bloqueado);
exception when others then
  reset role;
  insert into teste_2i_resultados values ('componente_id_nao_uuid_bloqueado', false);
  raise notice 'Teste componente_id_nao_uuid_bloqueado falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- Aula E (índice 5) — dois componentes com o MESMO "id" (duplicata).
-- ---------------------------------------------------------------------------
do $$
declare
  v_conteudo_id bigint;
  v_matricula_id uuid;
  v_usuario_id uuid;
  v_aula_id uuid;
  v_versao_id uuid;
  v_id_dup uuid := gen_random_uuid();
  v_missao_id uuid;
  v_bloqueado boolean;
begin
  select conteudo_id into v_conteudo_id from teste_2i_conteudos_livres where indice = 5;
  select valor::uuid into v_matricula_id from teste_2i_contexto where chave = 'matricula_id';
  select valor::uuid into v_usuario_id from teste_2i_contexto where chave = 'usuario_id';

  if v_conteudo_id is null then
    insert into teste_2i_resultados values ('ids_duplicados_na_estrutura_bloqueados', null);
    raise notice 'ids_duplicados_na_estrutura_bloqueados pulado: sem conteudo livre no indice 5.';
    return;
  end if;

  insert into public.aulas (conteudo_id, titulo) values (v_conteudo_id, '[TESTE FASE 2I] Aula E')
  returning id into v_aula_id;

  insert into public.aula_versoes (aula_id, numero_versao, status, estrutura, publicado_em)
  values (
    v_aula_id, 1, 'publicada',
    jsonb_build_object('componentes', jsonb_build_array(
      jsonb_build_object('id', v_id_dup::text, 'tipo', 'conceito'),
      jsonb_build_object('id', v_id_dup::text, 'tipo', 'recall')
    )),
    now()
  )
  returning id into v_versao_id;

  insert into public.missoes (matricula_id, conteudo_id, data_missao)
  values (v_matricula_id, v_conteudo_id, date '2000-01-01')
  returning id into v_missao_id;

  perform set_config('request.jwt.claims', json_build_object('sub', v_usuario_id::text, 'role', 'authenticated')::text, true);
  set local role authenticated;

  begin
    perform * from public.registrar_componente_teoria_concluido(v_missao_id, v_versao_id, v_id_dup);
    v_bloqueado := false;
  exception when others then
    v_bloqueado := true;
  end;

  reset role;
  insert into teste_2i_resultados values ('ids_duplicados_na_estrutura_bloqueados', v_bloqueado);
exception when others then
  reset role;
  insert into teste_2i_resultados values ('ids_duplicados_na_estrutura_bloqueados', false);
  raise notice 'Teste ids_duplicados_na_estrutura_bloqueados falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- Missão abandonada (índice 6) — nunca aceita novo progresso.
-- ---------------------------------------------------------------------------
do $$
declare
  v_conteudo_id bigint;
  v_matricula_id uuid;
  v_usuario_id uuid;
  v_missao_id uuid;
  v_bloqueado boolean;
begin
  select conteudo_id into v_conteudo_id from teste_2i_conteudos_livres where indice = 6;
  select valor::uuid into v_matricula_id from teste_2i_contexto where chave = 'matricula_id';
  select valor::uuid into v_usuario_id from teste_2i_contexto where chave = 'usuario_id';

  if v_conteudo_id is null then
    insert into teste_2i_resultados values ('missao_abandonada_bloqueada', null);
    raise notice 'missao_abandonada_bloqueada pulado: sem conteudo livre no indice 6.';
    return;
  end if;

  insert into public.missoes (matricula_id, conteudo_id, data_missao)
  values (v_matricula_id, v_conteudo_id, date '2000-01-01')
  returning id into v_missao_id;

  update public.missoes set status = 'abandonada' where id = v_missao_id;

  perform set_config('request.jwt.claims', json_build_object('sub', v_usuario_id::text, 'role', 'authenticated')::text, true);
  set local role authenticated;

  begin
    perform * from public.registrar_componente_teoria_concluido(v_missao_id, gen_random_uuid(), gen_random_uuid());
    v_bloqueado := false;
  exception when others then
    v_bloqueado := true;
  end;

  reset role;
  insert into teste_2i_resultados values ('missao_abandonada_bloqueada', v_bloqueado);
exception when others then
  reset role;
  insert into teste_2i_resultados values ('missao_abandonada_bloqueada', false);
  raise notice 'Teste missao_abandonada_bloqueada falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- Não regredir status (índice 7).
-- ---------------------------------------------------------------------------
do $$
declare
  v_conteudo_id bigint;
  v_matricula_id uuid;
  v_usuario_id uuid;
  v_aula_id uuid;
  v_versao_id uuid;
  v_comp_g1 uuid := gen_random_uuid();
  v_missao_id uuid;
  v_ok boolean;
begin
  select conteudo_id into v_conteudo_id from teste_2i_conteudos_livres where indice = 7;
  select valor::uuid into v_matricula_id from teste_2i_contexto where chave = 'matricula_id';
  select valor::uuid into v_usuario_id from teste_2i_contexto where chave = 'usuario_id';

  if v_conteudo_id is null then
    insert into teste_2i_resultados values ('nao_regredir_status', null);
    raise notice 'nao_regredir_status pulado: sem conteudo livre no indice 7.';
    return;
  end if;

  insert into public.aulas (conteudo_id, titulo) values (v_conteudo_id, '[TESTE FASE 2I] Aula G')
  returning id into v_aula_id;

  insert into public.aula_versoes (aula_id, numero_versao, status, estrutura, publicado_em)
  values (
    v_aula_id, 1, 'publicada',
    jsonb_build_object('componentes', jsonb_build_array(jsonb_build_object('id', v_comp_g1::text, 'tipo', 'diagnostico'))),
    now()
  )
  returning id into v_versao_id;

  insert into public.missoes (matricula_id, conteudo_id, data_missao)
  values (v_matricula_id, v_conteudo_id, date '2000-01-01')
  returning id into v_missao_id;

  update public.missoes set status = 'questoes_iniciadas' where id = v_missao_id;

  perform set_config('request.jwt.claims', json_build_object('sub', v_usuario_id::text, 'role', 'authenticated')::text, true);
  set local role authenticated;

  perform * from public.registrar_componente_teoria_concluido(v_missao_id, v_versao_id, v_comp_g1);

  reset role;

  v_ok := exists (
    select 1 from public.missoes where id = v_missao_id and status = 'questoes_iniciadas'
  );

  insert into teste_2i_resultados values ('nao_regredir_status', v_ok);
exception when others then
  reset role;
  insert into teste_2i_resultados values ('nao_regredir_status', false);
  raise notice 'Teste nao_regredir_status falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- Progresso em formato desconhecido/inválido (índice 8) — objeto que nem
-- se parece com V1.
-- ---------------------------------------------------------------------------
do $$
declare
  v_conteudo_id bigint;
  v_matricula_id uuid;
  v_usuario_id uuid;
  v_aula_id uuid;
  v_versao_id uuid;
  v_comp_h1 uuid := gen_random_uuid();
  v_missao_id uuid;
  v_bloqueado boolean;
begin
  select conteudo_id into v_conteudo_id from teste_2i_conteudos_livres where indice = 8;
  select valor::uuid into v_matricula_id from teste_2i_contexto where chave = 'matricula_id';
  select valor::uuid into v_usuario_id from teste_2i_contexto where chave = 'usuario_id';

  if v_conteudo_id is null then
    insert into teste_2i_resultados values ('progresso_formato_desconhecido_bloqueado', null);
    raise notice 'progresso_formato_desconhecido_bloqueado pulado: sem conteudo livre no indice 8.';
    return;
  end if;

  insert into public.aulas (conteudo_id, titulo) values (v_conteudo_id, '[TESTE FASE 2I] Aula H')
  returning id into v_aula_id;

  insert into public.aula_versoes (aula_id, numero_versao, status, estrutura, publicado_em)
  values (
    v_aula_id, 1, 'publicada',
    jsonb_build_object('componentes', jsonb_build_array(jsonb_build_object('id', v_comp_h1::text, 'tipo', 'recall'))),
    now()
  )
  returning id into v_versao_id;

  insert into public.missoes (matricula_id, conteudo_id, data_missao)
  values (v_matricula_id, v_conteudo_id, date '2000-01-01')
  returning id into v_missao_id;

  update public.missoes set progresso_teoria = '{"formato_antigo_hipotetico": true}'::jsonb where id = v_missao_id;

  perform set_config('request.jwt.claims', json_build_object('sub', v_usuario_id::text, 'role', 'authenticated')::text, true);
  set local role authenticated;

  begin
    perform * from public.registrar_componente_teoria_concluido(v_missao_id, v_versao_id, v_comp_h1);
    v_bloqueado := false;
  exception when others then
    v_bloqueado := true;
  end;

  reset role;
  insert into teste_2i_resultados values ('progresso_formato_desconhecido_bloqueado', v_bloqueado);
exception when others then
  reset role;
  insert into teste_2i_resultados values ('progresso_formato_desconhecido_bloqueado', false);
  raise notice 'Teste progresso_formato_desconhecido_bloqueado falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- Aula I (índice 9) — componente com "id" como NÚMERO JSON (123), não
-- string. Prova que a validação usa jsonb_typeof, não só ->>.
-- ---------------------------------------------------------------------------
do $$
declare
  v_conteudo_id bigint;
  v_matricula_id uuid;
  v_usuario_id uuid;
  v_aula_id uuid;
  v_versao_id uuid;
  v_missao_id uuid;
  v_bloqueado boolean;
begin
  select conteudo_id into v_conteudo_id from teste_2i_conteudos_livres where indice = 9;
  select valor::uuid into v_matricula_id from teste_2i_contexto where chave = 'matricula_id';
  select valor::uuid into v_usuario_id from teste_2i_contexto where chave = 'usuario_id';

  if v_conteudo_id is null then
    insert into teste_2i_resultados values ('componente_id_nao_string_bloqueado', null);
    raise notice 'componente_id_nao_string_bloqueado pulado: sem conteudo livre no indice 9.';
    return;
  end if;

  insert into public.aulas (conteudo_id, titulo) values (v_conteudo_id, '[TESTE FASE 2I] Aula I')
  returning id into v_aula_id;

  insert into public.aula_versoes (aula_id, numero_versao, status, estrutura, publicado_em)
  values (v_aula_id, 1, 'publicada', '{"componentes": [{"id": 123, "tipo": "conceito"}]}'::jsonb, now())
  returning id into v_versao_id;

  insert into public.missoes (matricula_id, conteudo_id, data_missao)
  values (v_matricula_id, v_conteudo_id, date '2000-01-01')
  returning id into v_missao_id;

  perform set_config('request.jwt.claims', json_build_object('sub', v_usuario_id::text, 'role', 'authenticated')::text, true);
  set local role authenticated;

  begin
    perform * from public.registrar_componente_teoria_concluido(v_missao_id, v_versao_id, gen_random_uuid());
    v_bloqueado := false;
  exception when others then
    v_bloqueado := true;
  end;

  reset role;
  insert into teste_2i_resultados values ('componente_id_nao_string_bloqueado', v_bloqueado);
exception when others then
  reset role;
  insert into teste_2i_resultados values ('componente_id_nao_string_bloqueado', false);
  raise notice 'Teste componente_id_nao_string_bloqueado falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- Aula J (índice 10) — componente com "tipo" como NÚMERO JSON (123).
-- ---------------------------------------------------------------------------
do $$
declare
  v_conteudo_id bigint;
  v_matricula_id uuid;
  v_usuario_id uuid;
  v_aula_id uuid;
  v_versao_id uuid;
  v_comp_j1 uuid := gen_random_uuid();
  v_missao_id uuid;
  v_bloqueado boolean;
begin
  select conteudo_id into v_conteudo_id from teste_2i_conteudos_livres where indice = 10;
  select valor::uuid into v_matricula_id from teste_2i_contexto where chave = 'matricula_id';
  select valor::uuid into v_usuario_id from teste_2i_contexto where chave = 'usuario_id';

  if v_conteudo_id is null then
    insert into teste_2i_resultados values ('componente_tipo_nao_string_bloqueado', null);
    raise notice 'componente_tipo_nao_string_bloqueado pulado: sem conteudo livre no indice 10.';
    return;
  end if;

  insert into public.aulas (conteudo_id, titulo) values (v_conteudo_id, '[TESTE FASE 2I] Aula J')
  returning id into v_aula_id;

  insert into public.aula_versoes (aula_id, numero_versao, status, estrutura, publicado_em)
  values (
    v_aula_id, 1, 'publicada',
    jsonb_build_object('componentes', jsonb_build_array(
      jsonb_build_object('id', v_comp_j1::text, 'tipo', 123)
    )),
    now()
  )
  returning id into v_versao_id;

  insert into public.missoes (matricula_id, conteudo_id, data_missao)
  values (v_matricula_id, v_conteudo_id, date '2000-01-01')
  returning id into v_missao_id;

  perform set_config('request.jwt.claims', json_build_object('sub', v_usuario_id::text, 'role', 'authenticated')::text, true);
  set local role authenticated;

  begin
    perform * from public.registrar_componente_teoria_concluido(v_missao_id, v_versao_id, v_comp_j1);
    v_bloqueado := false;
  exception when others then
    v_bloqueado := true;
  end;

  reset role;
  insert into teste_2i_resultados values ('componente_tipo_nao_string_bloqueado', v_bloqueado);
exception when others then
  reset role;
  insert into teste_2i_resultados values ('componente_tipo_nao_string_bloqueado', false);
  raise notice 'Teste componente_tipo_nao_string_bloqueado falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- Aula K (índice 11) — progresso_teoria pré-existente com schema_version
-- como STRING "1" (não o número JSON 1).
-- ---------------------------------------------------------------------------
do $$
declare
  v_conteudo_id bigint;
  v_matricula_id uuid;
  v_usuario_id uuid;
  v_aula_id uuid;
  v_versao_id uuid;
  v_comp_k1 uuid := gen_random_uuid();
  v_missao_id uuid;
  v_bloqueado boolean;
begin
  select conteudo_id into v_conteudo_id from teste_2i_conteudos_livres where indice = 11;
  select valor::uuid into v_matricula_id from teste_2i_contexto where chave = 'matricula_id';
  select valor::uuid into v_usuario_id from teste_2i_contexto where chave = 'usuario_id';

  if v_conteudo_id is null then
    insert into teste_2i_resultados values ('progresso_schema_version_string_bloqueado', null);
    raise notice 'progresso_schema_version_string_bloqueado pulado: sem conteudo livre no indice 11.';
    return;
  end if;

  insert into public.aulas (conteudo_id, titulo) values (v_conteudo_id, '[TESTE FASE 2I] Aula K')
  returning id into v_aula_id;

  insert into public.aula_versoes (aula_id, numero_versao, status, estrutura, publicado_em)
  values (
    v_aula_id, 1, 'publicada',
    jsonb_build_object('componentes', jsonb_build_array(jsonb_build_object('id', v_comp_k1::text, 'tipo', 'diagnostico'))),
    now()
  )
  returning id into v_versao_id;

  insert into public.missoes (matricula_id, conteudo_id, data_missao)
  values (v_matricula_id, v_conteudo_id, date '2000-01-01')
  returning id into v_missao_id;

  update public.missoes
  set progresso_teoria = jsonb_build_object(
    'schema_version', '1',
    'aula_versao_id', v_versao_id::text,
    'componentes_concluidos', '[]'::jsonb
  )
  where id = v_missao_id;

  perform set_config('request.jwt.claims', json_build_object('sub', v_usuario_id::text, 'role', 'authenticated')::text, true);
  set local role authenticated;

  begin
    perform * from public.registrar_componente_teoria_concluido(v_missao_id, v_versao_id, v_comp_k1);
    v_bloqueado := false;
  exception when others then
    v_bloqueado := true;
  end;

  reset role;
  insert into teste_2i_resultados values ('progresso_schema_version_string_bloqueado', v_bloqueado);
exception when others then
  reset role;
  insert into teste_2i_resultados values ('progresso_schema_version_string_bloqueado', false);
  raise notice 'Teste progresso_schema_version_string_bloqueado falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- Aula L (índice 12) — progresso_teoria pré-existente com aula_versao_id
-- que não é UUID válido.
-- ---------------------------------------------------------------------------
do $$
declare
  v_conteudo_id bigint;
  v_matricula_id uuid;
  v_usuario_id uuid;
  v_aula_id uuid;
  v_versao_id uuid;
  v_comp_l1 uuid := gen_random_uuid();
  v_missao_id uuid;
  v_bloqueado boolean;
begin
  select conteudo_id into v_conteudo_id from teste_2i_conteudos_livres where indice = 12;
  select valor::uuid into v_matricula_id from teste_2i_contexto where chave = 'matricula_id';
  select valor::uuid into v_usuario_id from teste_2i_contexto where chave = 'usuario_id';

  if v_conteudo_id is null then
    insert into teste_2i_resultados values ('progresso_aula_versao_id_nao_uuid_bloqueado', null);
    raise notice 'progresso_aula_versao_id_nao_uuid_bloqueado pulado: sem conteudo livre no indice 12.';
    return;
  end if;

  insert into public.aulas (conteudo_id, titulo) values (v_conteudo_id, '[TESTE FASE 2I] Aula L')
  returning id into v_aula_id;

  insert into public.aula_versoes (aula_id, numero_versao, status, estrutura, publicado_em)
  values (
    v_aula_id, 1, 'publicada',
    jsonb_build_object('componentes', jsonb_build_array(jsonb_build_object('id', v_comp_l1::text, 'tipo', 'diagnostico'))),
    now()
  )
  returning id into v_versao_id;

  insert into public.missoes (matricula_id, conteudo_id, data_missao)
  values (v_matricula_id, v_conteudo_id, date '2000-01-01')
  returning id into v_missao_id;

  update public.missoes
  set progresso_teoria = jsonb_build_object(
    'schema_version', 1,
    'aula_versao_id', 'nao-e-um-uuid',
    'componentes_concluidos', '[]'::jsonb
  )
  where id = v_missao_id;

  perform set_config('request.jwt.claims', json_build_object('sub', v_usuario_id::text, 'role', 'authenticated')::text, true);
  set local role authenticated;

  begin
    perform * from public.registrar_componente_teoria_concluido(v_missao_id, v_versao_id, v_comp_l1);
    v_bloqueado := false;
  exception when others then
    v_bloqueado := true;
  end;

  reset role;
  insert into teste_2i_resultados values ('progresso_aula_versao_id_nao_uuid_bloqueado', v_bloqueado);
exception when others then
  reset role;
  insert into teste_2i_resultados values ('progresso_aula_versao_id_nao_uuid_bloqueado', false);
  raise notice 'Teste progresso_aula_versao_id_nao_uuid_bloqueado falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- Aula M (índice 13) — progresso_teoria pré-existente com um item de
-- componentes_concluidos que é NÚMERO JSON (123), não string.
-- ---------------------------------------------------------------------------
do $$
declare
  v_conteudo_id bigint;
  v_matricula_id uuid;
  v_usuario_id uuid;
  v_aula_id uuid;
  v_versao_id uuid;
  v_comp_m1 uuid := gen_random_uuid();
  v_missao_id uuid;
  v_bloqueado boolean;
begin
  select conteudo_id into v_conteudo_id from teste_2i_conteudos_livres where indice = 13;
  select valor::uuid into v_matricula_id from teste_2i_contexto where chave = 'matricula_id';
  select valor::uuid into v_usuario_id from teste_2i_contexto where chave = 'usuario_id';

  if v_conteudo_id is null then
    insert into teste_2i_resultados values ('progresso_componente_nao_string_bloqueado', null);
    raise notice 'progresso_componente_nao_string_bloqueado pulado: sem conteudo livre no indice 13.';
    return;
  end if;

  insert into public.aulas (conteudo_id, titulo) values (v_conteudo_id, '[TESTE FASE 2I] Aula M')
  returning id into v_aula_id;

  insert into public.aula_versoes (aula_id, numero_versao, status, estrutura, publicado_em)
  values (
    v_aula_id, 1, 'publicada',
    jsonb_build_object('componentes', jsonb_build_array(jsonb_build_object('id', v_comp_m1::text, 'tipo', 'diagnostico'))),
    now()
  )
  returning id into v_versao_id;

  insert into public.missoes (matricula_id, conteudo_id, data_missao)
  values (v_matricula_id, v_conteudo_id, date '2000-01-01')
  returning id into v_missao_id;

  update public.missoes
  set progresso_teoria = jsonb_build_object(
    'schema_version', 1,
    'aula_versao_id', v_versao_id::text,
    'componentes_concluidos', jsonb_build_array(123)
  )
  where id = v_missao_id;

  perform set_config('request.jwt.claims', json_build_object('sub', v_usuario_id::text, 'role', 'authenticated')::text, true);
  set local role authenticated;

  begin
    perform * from public.registrar_componente_teoria_concluido(v_missao_id, v_versao_id, v_comp_m1);
    v_bloqueado := false;
  exception when others then
    v_bloqueado := true;
  end;

  reset role;
  insert into teste_2i_resultados values ('progresso_componente_nao_string_bloqueado', v_bloqueado);
exception when others then
  reset role;
  insert into teste_2i_resultados values ('progresso_componente_nao_string_bloqueado', false);
  raise notice 'Teste progresso_componente_nao_string_bloqueado falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- Aula N (índice 14) — progresso_teoria pré-existente citando um UUID que
-- não existe entre os componentes da versão.
-- ---------------------------------------------------------------------------
do $$
declare
  v_conteudo_id bigint;
  v_matricula_id uuid;
  v_usuario_id uuid;
  v_aula_id uuid;
  v_versao_id uuid;
  v_comp_n1 uuid := gen_random_uuid();
  v_comp_inexistente uuid := gen_random_uuid();
  v_missao_id uuid;
  v_bloqueado boolean;
begin
  select conteudo_id into v_conteudo_id from teste_2i_conteudos_livres where indice = 14;
  select valor::uuid into v_matricula_id from teste_2i_contexto where chave = 'matricula_id';
  select valor::uuid into v_usuario_id from teste_2i_contexto where chave = 'usuario_id';

  if v_conteudo_id is null then
    insert into teste_2i_resultados values ('progresso_componente_uuid_inexistente_bloqueado', null);
    raise notice 'progresso_componente_uuid_inexistente_bloqueado pulado: sem conteudo livre no indice 14.';
    return;
  end if;

  insert into public.aulas (conteudo_id, titulo) values (v_conteudo_id, '[TESTE FASE 2I] Aula N')
  returning id into v_aula_id;

  insert into public.aula_versoes (aula_id, numero_versao, status, estrutura, publicado_em)
  values (
    v_aula_id, 1, 'publicada',
    jsonb_build_object('componentes', jsonb_build_array(jsonb_build_object('id', v_comp_n1::text, 'tipo', 'diagnostico'))),
    now()
  )
  returning id into v_versao_id;

  insert into public.missoes (matricula_id, conteudo_id, data_missao)
  values (v_matricula_id, v_conteudo_id, date '2000-01-01')
  returning id into v_missao_id;

  update public.missoes
  set progresso_teoria = jsonb_build_object(
    'schema_version', 1,
    'aula_versao_id', v_versao_id::text,
    'componentes_concluidos', jsonb_build_array(v_comp_inexistente::text)
  )
  where id = v_missao_id;

  perform set_config('request.jwt.claims', json_build_object('sub', v_usuario_id::text, 'role', 'authenticated')::text, true);
  set local role authenticated;

  begin
    perform * from public.registrar_componente_teoria_concluido(v_missao_id, v_versao_id, v_comp_n1);
    v_bloqueado := false;
  exception when others then
    v_bloqueado := true;
  end;

  reset role;
  insert into teste_2i_resultados values ('progresso_componente_uuid_inexistente_bloqueado', v_bloqueado);
exception when others then
  reset role;
  insert into teste_2i_resultados values ('progresso_componente_uuid_inexistente_bloqueado', false);
  raise notice 'Teste progresso_componente_uuid_inexistente_bloqueado falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- Aula O (índice 15) — progresso_teoria pré-existente com o MESMO id
-- repetido duas vezes em componentes_concluidos.
-- ---------------------------------------------------------------------------
do $$
declare
  v_conteudo_id bigint;
  v_matricula_id uuid;
  v_usuario_id uuid;
  v_aula_id uuid;
  v_versao_id uuid;
  v_comp_o1 uuid := gen_random_uuid();
  v_missao_id uuid;
  v_bloqueado boolean;
begin
  select conteudo_id into v_conteudo_id from teste_2i_conteudos_livres where indice = 15;
  select valor::uuid into v_matricula_id from teste_2i_contexto where chave = 'matricula_id';
  select valor::uuid into v_usuario_id from teste_2i_contexto where chave = 'usuario_id';

  if v_conteudo_id is null then
    insert into teste_2i_resultados values ('progresso_componentes_duplicados_bloqueados', null);
    raise notice 'progresso_componentes_duplicados_bloqueados pulado: sem conteudo livre no indice 15.';
    return;
  end if;

  insert into public.aulas (conteudo_id, titulo) values (v_conteudo_id, '[TESTE FASE 2I] Aula O')
  returning id into v_aula_id;

  insert into public.aula_versoes (aula_id, numero_versao, status, estrutura, publicado_em)
  values (
    v_aula_id, 1, 'publicada',
    jsonb_build_object('componentes', jsonb_build_array(jsonb_build_object('id', v_comp_o1::text, 'tipo', 'diagnostico'))),
    now()
  )
  returning id into v_versao_id;

  insert into public.missoes (matricula_id, conteudo_id, data_missao)
  values (v_matricula_id, v_conteudo_id, date '2000-01-01')
  returning id into v_missao_id;

  update public.missoes
  set progresso_teoria = jsonb_build_object(
    'schema_version', 1,
    'aula_versao_id', v_versao_id::text,
    'componentes_concluidos', jsonb_build_array(v_comp_o1::text, v_comp_o1::text)
  )
  where id = v_missao_id;

  perform set_config('request.jwt.claims', json_build_object('sub', v_usuario_id::text, 'role', 'authenticated')::text, true);
  set local role authenticated;

  begin
    perform * from public.registrar_componente_teoria_concluido(v_missao_id, v_versao_id, v_comp_o1);
    v_bloqueado := false;
  exception when others then
    v_bloqueado := true;
  end;

  reset role;
  insert into teste_2i_resultados values ('progresso_componentes_duplicados_bloqueados', v_bloqueado);
exception when others then
  reset role;
  insert into teste_2i_resultados values ('progresso_componentes_duplicados_bloqueados', false);
  raise notice 'Teste progresso_componentes_duplicados_bloqueados falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ============================================================================
-- RESULTADO FINAL — esperado TRUE em tudo que for testável (NULL = não
-- testável neste banco agora, não conta contra tudo_ok)
-- ============================================================================
select
  (select ok from teste_2i_resultados where chave = 'rpc_existe') as rpc_existe,
  (select ok from teste_2i_resultados where chave = 'authenticated_pode_executar') as authenticated_pode_executar,
  (select ok from teste_2i_resultados where chave = 'anon_nao_pode_executar') as anon_nao_pode_executar,
  (select ok from teste_2i_resultados where chave = 'public_nao_pode_executar') as public_nao_pode_executar,
  (select ok from teste_2i_resultados where chave = 'usuario_dono_pode_registrar') as usuario_dono_pode_registrar,
  (select ok from teste_2i_resultados where chave = 'outro_usuario_bloqueado') as outro_usuario_bloqueado,
  (select ok from teste_2i_resultados where chave = 'sem_auth_bloqueado') as sem_auth_bloqueado,
  (select ok from teste_2i_resultados where chave = 'componente_existente_registrado') as componente_existente_registrado,
  (select ok from teste_2i_resultados where chave = 'componente_inexistente_bloqueado') as componente_inexistente_bloqueado,
  (select ok from teste_2i_resultados where chave = 'chamada_repetida_idempotente') as chamada_repetida_idempotente,
  (select ok from teste_2i_resultados where chave = 'progresso_schema_version_1') as progresso_schema_version_1,
  (select ok from teste_2i_resultados where chave = 'aula_versao_id_correto') as aula_versao_id_correto,
  (select ok from teste_2i_resultados where chave = 'ids_concluidos_sem_duplicata') as ids_concluidos_sem_duplicata,
  (select ok from teste_2i_resultados where chave = 'status_permanece_iniciada_antes_do_ultimo_componente') as status_permanece_iniciada_antes_do_ultimo_componente,
  (select ok from teste_2i_resultados where chave = 'ultimo_componente_muda_para_teoria_concluida') as ultimo_componente_muda_para_teoria_concluida,
  (select ok from teste_2i_resultados where chave = 'teoria_concluida_em_preenchido') as teoria_concluida_em_preenchido,
  (select ok from teste_2i_resultados where chave = 'atualizado_em_alterado_com_a_escrita') as atualizado_em_alterado_com_a_escrita,
  (select ok from teste_2i_resultados where chave = 'nao_regredir_status') as nao_regredir_status,
  (select ok from teste_2i_resultados where chave = 'missao_abandonada_bloqueada') as missao_abandonada_bloqueada,
  (select ok from teste_2i_resultados where chave = 'versao_diferente_bloqueada') as versao_diferente_bloqueada,
  (select ok from teste_2i_resultados where chave = 'estrutura_sem_componentes_array_bloqueada') as estrutura_sem_componentes_array_bloqueada,
  (select ok from teste_2i_resultados where chave = 'componente_sem_id_bloqueado') as componente_sem_id_bloqueado,
  (select ok from teste_2i_resultados where chave = 'componente_id_nao_uuid_bloqueado') as componente_id_nao_uuid_bloqueado,
  (select ok from teste_2i_resultados where chave = 'ids_duplicados_na_estrutura_bloqueados') as ids_duplicados_na_estrutura_bloqueados,
  (select ok from teste_2i_resultados where chave = 'progresso_formato_desconhecido_bloqueado') as progresso_formato_desconhecido_bloqueado,
  (select ok from teste_2i_resultados where chave = 'nenhuma_missao_de_outro_usuario_alterada') as nenhuma_missao_de_outro_usuario_alterada,
  (select ok from teste_2i_resultados where chave = 'componente_id_nao_string_bloqueado') as componente_id_nao_string_bloqueado,
  (select ok from teste_2i_resultados where chave = 'componente_tipo_nao_string_bloqueado') as componente_tipo_nao_string_bloqueado,
  (select ok from teste_2i_resultados where chave = 'progresso_schema_version_string_bloqueado') as progresso_schema_version_string_bloqueado,
  (select ok from teste_2i_resultados where chave = 'progresso_aula_versao_id_nao_uuid_bloqueado') as progresso_aula_versao_id_nao_uuid_bloqueado,
  (select ok from teste_2i_resultados where chave = 'progresso_componente_nao_string_bloqueado') as progresso_componente_nao_string_bloqueado,
  (select ok from teste_2i_resultados where chave = 'progresso_componente_uuid_inexistente_bloqueado') as progresso_componente_uuid_inexistente_bloqueado,
  (select ok from teste_2i_resultados where chave = 'progresso_componentes_duplicados_bloqueados') as progresso_componentes_duplicados_bloqueados,
  (select bool_and(ok) from teste_2i_resultados where ok is not null) as tudo_ok;

-- ============================================================================
-- DESFAZ TUDO — a RPC nova, os dados de teste, as missões/aulas/versões de
-- teste. Nada persiste, inclusive o SET LOCAL ROLE / request.jwt.claims
-- simulados.
-- ============================================================================
ROLLBACK;
