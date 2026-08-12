-- ============================================================================
-- TESTE RUNTIME COMPLETO DA FASE 2F — TRANSACIONAL, TUDO DESFEITO NO FINAL
-- ============================================================================
--
-- Arquivo SEPARADO da migration real (supabase/teoria_leitura_rpc.sql, que
-- continua terminando em COMMIT). Este aqui é só para colar no SQL Editor
-- do Supabase, rodar de uma vez, ler o resultado, e nunca persistir nada.
--
-- Técnica usada para simular auth.uid() sem tocar em auth.users: o mesmo
-- padrão documentado pela própria Supabase para testar RLS/funções que
-- dependem de auth.uid() direto no SQL Editor —
--   select set_config('request.jwt.claims', json_build_object('sub', <uuid>, 'role', 'authenticated')::text, true);
--   set local role authenticated;
-- auth.uid() lê o claim "sub" desse GUC de sessão; SET LOCAL ROLE muda o
-- role efetivo (para os GRANT/REVOKE valerem de verdade, não só auth.uid()).
-- Ambos são "local" à transação — desfeitos automaticamente no ROLLBACK
-- final, mesmo que algum bloco esqueça de resetar explicitamente.
--
-- NÃO insere em auth.users. Usa um usuário/matrícula REAL já existente
-- (ativa) como contexto — só leitura dessas tabelas, nunca escrita nelas.
--
-- public.aulas tem UNIQUE(conteudo_id): o harness procura um
-- curso_conteudos do MESMO curso da matrícula de teste que ainda não tenha
-- nenhuma linha em public.aulas, para não colidir com uma aula real.
--
-- Se não houver: matrícula ativa real, conteúdo livre, RAISE EXCEPTION e
-- para (sem inventar dado). Segundo usuário real e segundo conteúdo livre
-- são OPCIONAIS — se não existirem, os testes que dependem deles são
-- pulados com um resultado NULL + RAISE NOTICE explicando, nunca inventados.

BEGIN;

-- ============================================================================
-- Contexto: matrícula ativa real, conteúdo(s) livre(s), segundo usuário (opcional)
-- ============================================================================
create temporary table teste_2f_contexto (
  chave text primary key,
  valor text
);

create temporary table teste_2f_resultados (
  chave text primary key,
  ok boolean  -- nullable de propósito: NULL = "não testável neste banco", nunca inventado
);

do $$
declare
  v_matricula_id uuid;
  v_usuario_id uuid;
  v_curso_id uuid;
  v_conteudo_livre_1 bigint;
  v_conteudo_livre_2 bigint;
  v_segundo_usuario_id uuid;
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

  select cc.id into v_conteudo_livre_1
  from public.curso_conteudos cc
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where cm.curso_id = v_curso_id
    and not exists (select 1 from public.aulas a where a.conteudo_id = cc.id)
  order by cc.id
  limit 1;

  if v_conteudo_livre_1 is null then
    raise exception 'Teste abortado: nenhum curso_conteudos livre (sem aula) encontrado para o curso da matricula de teste.';
  end if;

  -- Segundo conteúdo livre (distinto do primeiro) — só para o teste
  -- "missão válida sem aula publicada". Opcional.
  select cc.id into v_conteudo_livre_2
  from public.curso_conteudos cc
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where cm.curso_id = v_curso_id
    and cc.id <> v_conteudo_livre_1
    and not exists (select 1 from public.aulas a where a.conteudo_id = cc.id)
  order by cc.id
  limit 1;

  -- Segundo usuário real com matrícula própria (qualquer status), distinto
  -- do primeiro — só para o teste de missão de outro usuário. Opcional.
  select m2.usuario_id into v_segundo_usuario_id
  from public.matriculas m2
  where m2.usuario_id <> v_usuario_id
  order by m2.id
  limit 1;

  insert into teste_2f_contexto (chave, valor) values
    ('matricula_id', v_matricula_id::text),
    ('usuario_id', v_usuario_id::text),
    ('curso_id', v_curso_id::text),
    ('conteudo_livre_1', v_conteudo_livre_1::text),
    ('conteudo_livre_2', coalesce(v_conteudo_livre_2::text, '')),
    ('segundo_usuario_id', coalesce(v_segundo_usuario_id::text, ''));
end $$;

-- ============================================================================
-- CORPO DA MIGRATION (idêntico a supabase/teoria_leitura_rpc.sql, sem o
-- COMMIT final)
-- ============================================================================

create function public.carregar_aula_publicada_da_missao(p_missao_id uuid)
returns table (
  missao_id uuid,
  conteudo_id bigint,
  missao_status text,
  aula_id uuid,
  aula_titulo text,
  aula_versao_id uuid,
  numero_versao integer,
  publicado_em timestamptz,
  estrutura jsonb,
  fontes jsonb
)
language plpgsql
stable
security definer
set search_path to ''
as $function$
declare
  v_usuario_id uuid;
  v_missao_id uuid;
  v_conteudo_id bigint;
  v_missao_status text;
begin
  v_usuario_id := auth.uid();
  if v_usuario_id is null then
    raise exception 'Usuario nao autenticado';
  end if;

  select ms.id, ms.conteudo_id, ms.status
  into v_missao_id, v_conteudo_id, v_missao_status
  from public.missoes ms
  join public.matriculas m on m.id = ms.matricula_id
  where ms.id = p_missao_id
    and m.usuario_id = v_usuario_id
    and m.status = 'ativa';

  if v_missao_id is null then
    raise exception 'Missao nao encontrada, nao pertence ao usuario autenticado, ou a matricula nao esta ativa';
  end if;

  return query
  select
    v_missao_id,
    v_conteudo_id,
    v_missao_status,
    a.id,
    a.titulo,
    av.id,
    av.numero_versao,
    av.publicado_em,
    av.estrutura,
    coalesce(f.fontes, '[]'::jsonb) as fontes
  from public.aulas a
  join public.aula_versoes av
    on av.aula_id = a.id
   and av.status = 'publicada'
  left join lateral (
    select jsonb_agg(
      jsonb_build_object(
        'material_id', mv.material_id,
        'material_titulo', mat.titulo,
        'material_tipo', mat.tipo,
        'material_versao_id', mv.id,
        'numero_versao', mv.numero_versao,
        'titulo_versao', mv.titulo_versao,
        'arquivo_path', mv.arquivo_path,
        'checksum', mv.checksum,
        'vigente_desde', mv.vigente_desde,
        'vigente_ate', mv.vigente_ate,
        'ordem', avf.ordem,
        'observacao', avf.observacao
      )
      order by avf.ordem nulls last, mv.numero_versao, mv.id
    ) as fontes
    from public.aula_versao_fontes avf
    join public.material_versoes mv on mv.id = avf.material_versao_id
    join public.materiais mat on mat.id = mv.material_id
    where avf.aula_versao_id = av.id
  ) f on true
  where a.conteudo_id = v_conteudo_id
    and a.ativa = true;
end;
$function$;

revoke execute on function public.carregar_aula_publicada_da_missao(uuid) from public;
revoke execute on function public.carregar_aula_publicada_da_missao(uuid) from anon;
grant execute on function public.carregar_aula_publicada_da_missao(uuid) to authenticated;

-- ============================================================================
-- FIM DO CORPO DA MIGRATION — daqui pra baixo é só o TEST HARNESS
-- ============================================================================

-- ---------------------------------------------------------------------------
-- Checagens estruturais (catálogo do Postgres) — 1 a 4
-- ---------------------------------------------------------------------------

insert into teste_2f_resultados values (
  'rpc_existe',
  exists (
    select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'carregar_aula_publicada_da_missao'
  )
);

insert into teste_2f_resultados values (
  'authenticated_pode_executar',
  has_function_privilege('authenticated', 'public.carregar_aula_publicada_da_missao(uuid)', 'EXECUTE')
);

insert into teste_2f_resultados values (
  'anon_nao_pode_executar',
  not has_function_privilege('anon', 'public.carregar_aula_publicada_da_missao(uuid)', 'EXECUTE')
);

insert into teste_2f_resultados values (
  'public_nao_pode_executar',
  not exists (
    select 1 from information_schema.routine_privileges
    where routine_schema = 'public' and routine_name = 'carregar_aula_publicada_da_missao'
      and grantee = 'PUBLIC' and privilege_type = 'EXECUTE'
  )
);

-- ---------------------------------------------------------------------------
-- Dados de teste: material vinculado + material NÃO vinculado + aula
-- publicada + fonte + missão real ligada ao conteúdo livre 1
-- ---------------------------------------------------------------------------
do $$
declare
  v_conteudo_livre_1 bigint;
  v_matricula_id uuid;
  v_material_id uuid;
  v_material_versao_id uuid;
  v_material_id_nao_vinculado uuid;
  v_material_versao_id_nao_vinculado uuid;
  v_aula_id uuid;
  v_aula_versao_id uuid;
  v_missao_id uuid;
  v_data_missao date;
begin
  select valor::bigint into v_conteudo_livre_1 from teste_2f_contexto where chave = 'conteudo_livre_1';
  select valor::uuid into v_matricula_id from teste_2f_contexto where chave = 'matricula_id';

  insert into public.materiais (titulo, tipo, descricao)
  values ('[TESTE FASE 2F] Material vinculado', 'teste', 'Ligado à aula publicada de teste.')
  returning id into v_material_id;

  insert into public.material_versoes (material_id, numero_versao, titulo_versao, conteudo_texto)
  values (v_material_id, 1, '[TESTE FASE 2F] v1', 'Conteudo de teste - NAO deve aparecer no retorno da RPC.')
  returning id into v_material_versao_id;

  insert into public.materiais (titulo, tipo, descricao)
  values ('[TESTE FASE 2F] Material NAO vinculado', 'teste', 'Nunca deve aparecer nas fontes retornadas pela RPC.')
  returning id into v_material_id_nao_vinculado;

  insert into public.material_versoes (material_id, numero_versao)
  values (v_material_id_nao_vinculado, 1)
  returning id into v_material_versao_id_nao_vinculado;

  insert into public.aulas (conteudo_id, titulo)
  values (v_conteudo_livre_1, '[TESTE FASE 2F] Aula publicada de teste')
  returning id into v_aula_id;

  insert into public.aula_versoes (aula_id, numero_versao, status, estrutura, publicado_em)
  values (v_aula_id, 1, 'publicada', '{"componentes": [{"tipo": "diagnostico"}]}'::jsonb, now())
  returning id into v_aula_versao_id;

  insert into public.aula_versao_fontes (aula_versao_id, material_versao_id, ordem, observacao)
  values (v_aula_versao_id, v_material_versao_id, 1, '[TESTE FASE 2F] fonte vinculada');

  v_data_missao := (timezone('America/Sao_Paulo', now()))::date;

  insert into public.missoes (matricula_id, conteudo_id)
  values (v_matricula_id, v_conteudo_livre_1)
  on conflict on constraint missoes_matricula_id_conteudo_id_data_missao_key
  do nothing
  returning id into v_missao_id;

  if v_missao_id is null then
    select id into v_missao_id from public.missoes
    where matricula_id = v_matricula_id
      and conteudo_id = v_conteudo_livre_1
      and data_missao = v_data_missao;
  end if;

  insert into teste_2f_contexto (chave, valor) values
    ('material_id', v_material_id::text),
    ('material_versao_id', v_material_versao_id::text),
    ('material_id_nao_vinculado', v_material_id_nao_vinculado::text),
    ('material_versao_id_nao_vinculado', v_material_versao_id_nao_vinculado::text),
    ('aula_id', v_aula_id::text),
    ('aula_versao_id', v_aula_versao_id::text),
    ('missao_id', v_missao_id::text);
exception when others then
  raise notice 'Falha ao criar dados de teste principais: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- Segunda missão (sem nenhuma aula) — só se houver um segundo conteúdo
-- livre; senão sinaliza NULL + NOTICE, sem inventar dado.
-- ---------------------------------------------------------------------------
do $$
declare
  v_conteudo_livre_2 text;
  v_matricula_id uuid;
  v_missao_sem_aula_id uuid;
  v_data_missao date;
begin
  select valor into v_conteudo_livre_2 from teste_2f_contexto where chave = 'conteudo_livre_2';
  select valor::uuid into v_matricula_id from teste_2f_contexto where chave = 'matricula_id';

  if v_conteudo_livre_2 is null or v_conteudo_livre_2 = '' then
    insert into teste_2f_resultados values ('sem_aula_publicada_retorna_zero', null);
    raise notice 'Teste "sem aula publicada" pulado: nao ha um segundo curso_conteudos livre no curso da matricula de teste.';
    return;
  end if;

  v_data_missao := (timezone('America/Sao_Paulo', now()))::date;

  insert into public.missoes (matricula_id, conteudo_id)
  values (v_matricula_id, v_conteudo_livre_2::bigint)
  on conflict on constraint missoes_matricula_id_conteudo_id_data_missao_key
  do nothing
  returning id into v_missao_sem_aula_id;

  if v_missao_sem_aula_id is null then
    select id into v_missao_sem_aula_id from public.missoes
    where matricula_id = v_matricula_id
      and conteudo_id = v_conteudo_livre_2::bigint
      and data_missao = v_data_missao;
  end if;

  insert into teste_2f_contexto (chave, valor) values ('missao_sem_aula_id', v_missao_sem_aula_id::text);
exception when others then
  insert into teste_2f_resultados values ('sem_aula_publicada_retorna_zero', false);
  raise notice 'Falha ao preparar missao sem aula: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- Teste funcional principal: chama a RPC simulando auth.uid() = usuário
-- real dono da missão. Valida retorno inteiro + confirma que nada em
-- public.missoes mudou (status/progresso_teoria/atualizado_em).
--
-- Todo trabalho sob "set local role authenticated" fica em variáveis locais
-- — só depois de "reset role" é que gravamos em teste_2f_resultados
-- (tabela temporária pertence ao role original; authenticated não teria
-- INSERT nela).
-- ---------------------------------------------------------------------------
do $$
declare
  v_usuario_id uuid;
  v_missao_id uuid;
  v_conteudo_livre_1 bigint;
  v_aula_id uuid;
  v_aula_versao_id uuid;
  v_material_versao_id uuid;
  v_material_versao_id_nao_vinculado uuid;
  v_status_antes text;
  v_progresso_antes jsonb;
  v_atualizado_antes timestamptz;
  v_status_depois text;
  v_progresso_depois jsonb;
  v_atualizado_depois timestamptz;
  v_linhas integer;
  r record;
  v_fontes jsonb;
  v_ok_uma_linha boolean := false;
  v_ok_ids boolean := false;
  v_ok_estrutura boolean := false;
  v_ok_fontes_array boolean := false;
  v_ok_fonte_vinculada boolean := false;
  v_ok_fonte_nao_vaza boolean := false;
begin
  select valor::uuid into v_usuario_id from teste_2f_contexto where chave = 'usuario_id';
  select valor::uuid into v_missao_id from teste_2f_contexto where chave = 'missao_id';
  select valor::bigint into v_conteudo_livre_1 from teste_2f_contexto where chave = 'conteudo_livre_1';
  select valor::uuid into v_aula_id from teste_2f_contexto where chave = 'aula_id';
  select valor::uuid into v_aula_versao_id from teste_2f_contexto where chave = 'aula_versao_id';
  select valor::uuid into v_material_versao_id from teste_2f_contexto where chave = 'material_versao_id';
  select valor::uuid into v_material_versao_id_nao_vinculado from teste_2f_contexto where chave = 'material_versao_id_nao_vinculado';

  if v_usuario_id is null or v_missao_id is null then
    raise exception 'contexto ausente para o teste funcional principal';
  end if;

  select status, progresso_teoria, atualizado_em
  into v_status_antes, v_progresso_antes, v_atualizado_antes
  from public.missoes where id = v_missao_id;

  perform set_config('request.jwt.claims', json_build_object('sub', v_usuario_id::text, 'role', 'authenticated')::text, true);
  set local role authenticated;

  select count(*) into v_linhas from public.carregar_aula_publicada_da_missao(v_missao_id);
  v_ok_uma_linha := (v_linhas = 1);

  select * into r from public.carregar_aula_publicada_da_missao(v_missao_id) limit 1;

  v_ok_ids := (
    r.missao_id = v_missao_id
    and r.conteudo_id = v_conteudo_livre_1
    and r.aula_id = v_aula_id
    and r.aula_versao_id = v_aula_versao_id
    and r.numero_versao = 1
  );

  v_ok_estrutura := (r.estrutura = '{"componentes": [{"tipo": "diagnostico"}]}'::jsonb);

  v_fontes := r.fontes;
  v_ok_fontes_array := (jsonb_typeof(v_fontes) = 'array');

  v_ok_fonte_vinculada := (
    jsonb_typeof(v_fontes) = 'array'
    and jsonb_array_length(v_fontes) >= 1
    and exists (
      select 1 from jsonb_array_elements(v_fontes) elem
      where (elem ->> 'material_versao_id')::uuid = v_material_versao_id
        and (elem ->> 'ordem')::int = 1
    )
  );

  v_ok_fonte_nao_vaza := (
    jsonb_typeof(v_fontes) = 'array'
    and not exists (
      select 1 from jsonb_array_elements(v_fontes) elem
      where (elem ->> 'material_versao_id')::uuid = v_material_versao_id_nao_vinculado
    )
  );

  reset role;

  select status, progresso_teoria, atualizado_em
  into v_status_depois, v_progresso_depois, v_atualizado_depois
  from public.missoes where id = v_missao_id;

  insert into teste_2f_resultados values ('missao_propria_retorna_uma_linha', v_ok_uma_linha);
  insert into teste_2f_resultados values ('ids_corretos', v_ok_ids);
  insert into teste_2f_resultados values ('estrutura_ok', v_ok_estrutura);
  insert into teste_2f_resultados values ('fontes_array_ok', v_ok_fontes_array);
  insert into teste_2f_resultados values ('fonte_vinculada_ok', v_ok_fonte_vinculada);
  insert into teste_2f_resultados values ('fonte_nao_vinculada_nao_vaza', v_ok_fonte_nao_vaza);
  insert into teste_2f_resultados values ('missao_status_inalterado', v_status_depois = v_status_antes);
  insert into teste_2f_resultados values ('progresso_inalterado', v_progresso_depois = v_progresso_antes);
  insert into teste_2f_resultados values ('atualizado_em_inalterado', v_atualizado_depois = v_atualizado_antes);
exception when others then
  reset role;
  insert into teste_2f_resultados values ('missao_propria_retorna_uma_linha', false);
  insert into teste_2f_resultados values ('ids_corretos', false);
  insert into teste_2f_resultados values ('estrutura_ok', false);
  insert into teste_2f_resultados values ('fontes_array_ok', false);
  insert into teste_2f_resultados values ('fonte_vinculada_ok', false);
  insert into teste_2f_resultados values ('fonte_nao_vinculada_nao_vaza', false);
  insert into teste_2f_resultados values ('missao_status_inalterado', false);
  insert into teste_2f_resultados values ('progresso_inalterado', false);
  insert into teste_2f_resultados values ('atualizado_em_inalterado', false);
  raise notice 'Teste funcional principal falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- Missão válida sem aula publicada -> zero linhas (só se o segundo
-- conteúdo livre existia e a segunda missão foi criada acima).
-- ---------------------------------------------------------------------------
do $$
declare
  v_usuario_id uuid;
  v_missao_sem_aula_id text;
  v_linhas integer;
begin
  select valor into v_missao_sem_aula_id from teste_2f_contexto where chave = 'missao_sem_aula_id';
  select valor::uuid into v_usuario_id from teste_2f_contexto where chave = 'usuario_id';

  if v_missao_sem_aula_id is null or v_missao_sem_aula_id = '' then
    return; -- já sinalizado (NULL) ou já marcado false no bloco de preparação
  end if;

  perform set_config('request.jwt.claims', json_build_object('sub', v_usuario_id::text, 'role', 'authenticated')::text, true);
  set local role authenticated;

  select count(*) into v_linhas
  from public.carregar_aula_publicada_da_missao(v_missao_sem_aula_id::uuid);

  reset role;

  insert into teste_2f_resultados values ('sem_aula_publicada_retorna_zero', v_linhas = 0);
exception when others then
  reset role;
  insert into teste_2f_resultados values ('sem_aula_publicada_retorna_zero', false);
  raise notice 'Teste sem_aula_publicada falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- Missão de OUTRO usuário não pode ser lida — só se existir um segundo
-- usuário real com matrícula própria. A checagem é a autorização EXPLÍCITA
-- dentro da função (usuario_id da matrícula), não o RLS — a função é
-- SECURITY DEFINER e o RLS de public.missoes nem chega a ser avaliado
-- dentro dela.
-- ---------------------------------------------------------------------------
do $$
declare
  v_segundo_usuario text;
  v_missao_id uuid;
  v_bloqueado boolean;
begin
  select valor into v_segundo_usuario from teste_2f_contexto where chave = 'segundo_usuario_id';
  select valor::uuid into v_missao_id from teste_2f_contexto where chave = 'missao_id';

  if v_segundo_usuario is null or v_segundo_usuario = '' then
    insert into teste_2f_resultados values ('outra_missao_bloqueada', null);
    raise notice 'Teste "outra missao bloqueada" pulado: nao ha um segundo usuario/matricula real distinto neste banco. Nao inventamos usuario (auth.users nao e tocado). Assim que existir uma segunda matricula real de outro usuario, este harness roda o teste automaticamente.';
    return;
  end if;

  if v_missao_id is null then
    raise exception 'contexto ausente (missao_id)';
  end if;

  perform set_config('request.jwt.claims', json_build_object('sub', v_segundo_usuario, 'role', 'authenticated')::text, true);
  set local role authenticated;

  begin
    perform * from public.carregar_aula_publicada_da_missao(v_missao_id);
    v_bloqueado := false; -- nao lancou excecao = NAO foi bloqueado = teste falhou
  exception when others then
    v_bloqueado := true; -- RAISE EXCEPTION esperado da propria funcao
  end;

  reset role;

  insert into teste_2f_resultados values ('outra_missao_bloqueada', v_bloqueado);
exception when others then
  reset role;
  insert into teste_2f_resultados values ('outra_missao_bloqueada', false);
  raise notice 'Teste outra_missao_bloqueada falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- Chamada sem auth.uid() deve falhar (claims sem "sub").
-- ---------------------------------------------------------------------------
do $$
declare
  v_missao_id uuid;
  v_bloqueado boolean;
begin
  select valor::uuid into v_missao_id from teste_2f_contexto where chave = 'missao_id';
  if v_missao_id is null then raise exception 'contexto ausente'; end if;

  -- JSON válido, mas sem "sub" -> auth.uid() resolve para NULL de forma
  -- limpa (->> em chave ausente retorna NULL, nunca erro de cast).
  perform set_config('request.jwt.claims', json_build_object('role', 'authenticated')::text, true);
  set local role authenticated;

  begin
    perform * from public.carregar_aula_publicada_da_missao(v_missao_id);
    v_bloqueado := false;
  exception when others then
    v_bloqueado := true; -- esperado: 'Usuario nao autenticado'
  end;

  reset role;

  insert into teste_2f_resultados values ('sem_auth_bloqueado', v_bloqueado);
exception when others then
  reset role;
  insert into teste_2f_resultados values ('sem_auth_bloqueado', false);
  raise notice 'Teste sem_auth_bloqueado falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- Reforço dinâmico: anon tentando executar de verdade (além da checagem
-- estática de grant já feita acima) — combina os dois com AND na mesma chave.
-- ---------------------------------------------------------------------------
do $$
declare
  v_missao_id uuid;
  v_bloqueado boolean := false;
begin
  select valor::uuid into v_missao_id from teste_2f_contexto where chave = 'missao_id';
  if v_missao_id is null then raise exception 'contexto ausente'; end if;

  set local role anon;
  begin
    perform * from public.carregar_aula_publicada_da_missao(v_missao_id);
    v_bloqueado := false;
  exception
    when insufficient_privilege then v_bloqueado := true;
    when others then v_bloqueado := false;
  end;
  reset role;

  update teste_2f_resultados set ok = (coalesce(ok, true) and v_bloqueado) where chave = 'anon_nao_pode_executar';
exception when others then
  reset role;
  update teste_2f_resultados set ok = false where chave = 'anon_nao_pode_executar';
  raise notice 'Reforco live de anon_nao_pode_executar falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- authenticated continua sem SELECT direto nas 5 tabelas da Fase 2E.
-- ---------------------------------------------------------------------------
do $$
declare
  v_ok boolean := true;
begin
  set local role authenticated;

  begin
    perform 1 from public.materiais limit 1;
    v_ok := false;
  exception when insufficient_privilege then null; when others then v_ok := false; end;

  begin
    perform 1 from public.material_versoes limit 1;
    v_ok := false;
  exception when insufficient_privilege then null; when others then v_ok := false; end;

  begin
    perform 1 from public.aulas limit 1;
    v_ok := false;
  exception when insufficient_privilege then null; when others then v_ok := false; end;

  begin
    perform 1 from public.aula_versoes limit 1;
    v_ok := false;
  exception when insufficient_privilege then null; when others then v_ok := false; end;

  begin
    perform 1 from public.aula_versao_fontes limit 1;
    v_ok := false;
  exception when insufficient_privilege then null; when others then v_ok := false; end;

  reset role;
  insert into teste_2f_resultados values ('sem_select_direto', v_ok);
exception when others then
  reset role;
  insert into teste_2f_resultados values ('sem_select_direto', false);
  raise notice 'Teste sem_select_direto falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ============================================================================
-- RESULTADO FINAL — esperado TRUE em tudo que for testável (NULL = não
-- testável neste banco agora, não conta contra tudo_ok)
-- ============================================================================
select
  (select ok from teste_2f_resultados where chave = 'rpc_existe') as rpc_existe,
  (select ok from teste_2f_resultados where chave = 'authenticated_pode_executar') as authenticated_pode_executar,
  (select ok from teste_2f_resultados where chave = 'anon_nao_pode_executar') as anon_nao_pode_executar,
  (select ok from teste_2f_resultados where chave = 'public_nao_pode_executar') as public_nao_pode_executar,
  (select ok from teste_2f_resultados where chave = 'missao_propria_retorna_uma_linha') as missao_propria_retorna_uma_linha,
  (select ok from teste_2f_resultados where chave = 'ids_corretos') as ids_corretos,
  (select ok from teste_2f_resultados where chave = 'estrutura_ok') as estrutura_ok,
  (select ok from teste_2f_resultados where chave = 'fontes_array_ok') as fontes_array_ok,
  (select ok from teste_2f_resultados where chave = 'fonte_vinculada_ok') as fonte_vinculada_ok,
  (select ok from teste_2f_resultados where chave = 'fonte_nao_vinculada_nao_vaza') as fonte_nao_vinculada_nao_vaza,
  (select ok from teste_2f_resultados where chave = 'sem_aula_publicada_retorna_zero') as sem_aula_publicada_retorna_zero,
  (select ok from teste_2f_resultados where chave = 'outra_missao_bloqueada') as outra_missao_bloqueada,
  (select ok from teste_2f_resultados where chave = 'sem_auth_bloqueado') as sem_auth_bloqueado,
  (select ok from teste_2f_resultados where chave = 'missao_status_inalterado') as missao_status_inalterado,
  (select ok from teste_2f_resultados where chave = 'progresso_inalterado') as progresso_inalterado,
  (select ok from teste_2f_resultados where chave = 'atualizado_em_inalterado') as atualizado_em_inalterado,
  (select ok from teste_2f_resultados where chave = 'sem_select_direto') as sem_select_direto,
  (select bool_and(ok) from teste_2f_resultados where ok is not null) as tudo_ok;

-- ============================================================================
-- DESFAZ TUDO — a RPC nova, os dados de teste, as missões de teste. Nada
-- persiste, inclusive o SET LOCAL ROLE / request.jwt.claims simulados.
-- ============================================================================
ROLLBACK;
