-- ============================================================================
-- TESTE RUNTIME DA MIGRATION teoria_geracoes_admin_contexto.sql (Fase 2J-B,
-- segunda migration) — TRANSACIONAL, TUDO DESFEITO NO FINAL
-- ============================================================================
--
-- Este arquivo é SEPARADO da migration real (supabase/teoria_geracoes_
-- admin_contexto.sql, que continua terminando em COMMIT e é o arquivo a
-- aplicar de verdade quando chegar a hora). Este aqui é só para colar no
-- SQL Editor do Supabase, rodar de uma vez, ler o resultado e nunca
-- persistir nada — termina em ROLLBACK.
--
-- Mesma técnica de simulação de auth.uid() já usada nos harnesses
-- anteriores (Fases 2F/2I/2J-A): set_config de request.jwt.claims + SET
-- LOCAL ROLE, ambos "local" à transação, desfeitos automaticamente no
-- ROLLBACK final. NÃO cria/promove nenhum usuário a admin — procura um
-- real para quem public.eh_admin() já retorna true, igual ao harness da
-- Fase 2J-A. Se não houver nenhum, o teste funcional (seção 5) fica NULL
-- + NOTICE, nunca false (ausência de fixture não é uma falha).
--
-- Lição já aplicada nos harnesses anteriores desta fase, reaplicada aqui:
-- SET LOCAL ROLE authenticated bracket SOMENTE a chamada da RPC em si —
-- nunca uma leitura direta de tabela (authenticated não tem SELECT direto
-- em aula_geracoes) e nunca uma escrita em tabela temporária criada pelo
-- role privilegiado da própria sessão (que "authenticated" também não
-- teria privilégio para tocar). Por isso a captura do resultado da RPC é
-- feita em VARIÁVEIS PL/pgSQL locais (arrays), dentro do mesmo bloco DO,
-- e só depois de "reset role" é que qualquer leitura direta de tabela ou
-- gravação em tabela temporária acontece.
--
-- O que faz, em ordem:
--   1. PRÉ-CONDIÇÃO (seção 1): valida que a função REAL, ANTES de
--      qualquer DROP, está exatamente no estado hoje documentado —
--      existe com assinatura (bigint), é SECURITY DEFINER, authenticated
--      tem EXECUTE, anon/PUBLIC não têm. Se divergir, ABORTA o harness
--      inteiro com uma exceção clara (fora de qualquer bloco que
--      mascare erro) — nunca continua "mascarando" uma divergência.
--   2. Contexto: procura um admin real (nunca cria um) e um
--      curso_conteudos real para as fixtures de aula_geracoes.
--   3. Recria a função dentro da transação: DROP FUNCTION + CREATE
--      FUNCTION idêntico a teoria_geracoes_admin_contexto.sql, sem o
--      COMMIT final.
--   4. Testes de catálogo (seção 3) e de não regressão (seção 6): função
--      existe, assinatura bigint, SECURITY DEFINER, search_path vazio,
--      exatamente 9 colunas, as 8 antigas com mesmo nome/tipo/ordem,
--      "contexto" é a 9ª coluna e é jsonb.
--   5. Testes de privilégio (seção 4): authenticated pode executar,
--      anon/PUBLIC não podem.
--   6. Teste funcional (seção 5): se há admin real, cria 2 linhas de
--      fixture em aula_geracoes (mesmo conteúdo, iniciado_em distintos,
--      contexto distinto e identificável) e chama a RPC como o admin —
--      confirma que funciona, que voltou ordenada por iniciado_em desc,
--      e que o "contexto" de uma das linhas retornadas é exatamente
--      igual ao aula_geracoes.contexto real da mesma geracao_id.
--   7. UM SELECT final com todas as respostas em colunas booleanas
--      (NULL, não false, quando um teste não pôde ser executado por
--      ausência legítima de fixture).
--   8. ROLLBACK — desfaz tudo: a função volta à versão original, e
--      nenhuma fixture de aula_geracoes fica persistida.

BEGIN;

-- ============================================================================
-- SEÇÃO 1 — PRÉ-CONDIÇÃO: a função REAL, antes de qualquer DROP, precisa
-- estar exatamente no contrato hoje documentado. Se não estiver, aborta
-- aqui — fora de qualquer EXCEPTION que mascare a divergência.
-- ============================================================================
do $$
declare
  v_existe boolean;
  v_secdef boolean;
  v_auth_exec boolean;
  v_anon_exec boolean;
  v_public_exec boolean;
  v_problemas text := '';
begin
  select exists (
    select 1 from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'listar_geracoes_conteudo_admin'
      and pg_get_function_identity_arguments(p.oid) = 'p_conteudo_id bigint'
  ) into v_existe;

  if not v_existe then
    raise exception 'PRE-CONDICAO falhou: public.listar_geracoes_conteudo_admin(bigint) nao existe com a assinatura esperada (p_conteudo_id bigint). Harness abortado ANTES de qualquer DROP — nada foi alterado.';
  end if;

  select p.prosecdef into v_secdef
  from pg_proc p join pg_namespace n on n.oid = p.pronamespace
  where n.nspname = 'public' and p.proname = 'listar_geracoes_conteudo_admin'
    and pg_get_function_identity_arguments(p.oid) = 'p_conteudo_id bigint';

  v_auth_exec := has_function_privilege('authenticated', 'public.listar_geracoes_conteudo_admin(bigint)', 'EXECUTE');
  v_anon_exec := has_function_privilege('anon', 'public.listar_geracoes_conteudo_admin(bigint)', 'EXECUTE');
  v_public_exec := has_function_privilege('public', 'public.listar_geracoes_conteudo_admin(bigint)', 'EXECUTE');

  if not v_secdef then v_problemas := v_problemas || 'funcao real NAO e SECURITY DEFINER (esperado ser); '; end if;
  if not v_auth_exec then v_problemas := v_problemas || 'authenticated NAO tem EXECUTE (esperado ter); '; end if;
  if v_anon_exec then v_problemas := v_problemas || 'anon TEM EXECUTE (esperado nao ter); '; end if;
  if v_public_exec then v_problemas := v_problemas || 'PUBLIC TEM EXECUTE (esperado nao ter); '; end if;

  if v_problemas <> '' then
    raise exception 'PRE-CONDICAO falhou, a funcao real diverge do contrato esperado ANTES do DROP — harness abortado, nada foi alterado. Divergencias: %', v_problemas;
  end if;
end $$;

-- ============================================================================
-- Tabelas de apoio do teste (não fazem parte da migration real).
-- ============================================================================
create temporary table teste_2jb2_resultados (
  chave text primary key,
  ok boolean
);

create temporary table teste_2jb2_contexto (
  chave text primary key,
  valor text
);

-- ============================================================================
-- Contexto: um admin real (se existir — nunca criado/promovido aqui) e um
-- curso_conteudos real para as fixtures de aula_geracoes do teste
-- funcional. Mesma técnica de descoberta de admin do harness da Fase 2J-A.
-- ============================================================================
do $$
declare
  v_admin_usuario_id uuid;
  v_candidato uuid;
  v_conteudo_id bigint;
begin
  for v_candidato in select id from auth.users order by created_at limit 50 loop
    perform set_config('request.jwt.claims', json_build_object('sub', v_candidato::text, 'role', 'authenticated')::text, true);
    set local role authenticated;
    if public.eh_admin() then
      v_admin_usuario_id := v_candidato;
    end if;
    reset role;
    exit when v_admin_usuario_id is not null;
  end loop;

  select id into v_conteudo_id from public.curso_conteudos order by id limit 1;

  insert into teste_2jb2_contexto (chave, valor) values
    ('admin_usuario_id', coalesce(v_admin_usuario_id::text, '')),
    ('conteudo_id', coalesce(v_conteudo_id::text, ''));
end $$;

-- ============================================================================
-- CORPO DA MIGRATION (idêntico a supabase/teoria_geracoes_admin_
-- contexto.sql, sem o COMMIT final)
-- ============================================================================

drop function public.listar_geracoes_conteudo_admin(bigint);

create function public.listar_geracoes_conteudo_admin(p_conteudo_id bigint)
returns table (
  geracao_id uuid,
  status text,
  iniciado_em timestamptz,
  finalizado_em timestamptz,
  aula_versao_id uuid,
  erro text,
  prompt_version text,
  modelo text,
  contexto jsonb
)
language plpgsql
security definer
set search_path to ''
as $function$
begin
  if not public.eh_admin() then
    raise exception 'Apenas administradores podem consultar geracoes de aula';
  end if;

  return query
  select
    g.id,
    g.status,
    g.iniciado_em,
    g.finalizado_em,
    g.aula_versao_id,
    g.erro,
    g.prompt_version,
    g.modelo,
    g.contexto
  from public.aula_geracoes g
  where g.conteudo_id = p_conteudo_id
  order by g.iniciado_em desc;
end;
$function$;

revoke execute on function public.listar_geracoes_conteudo_admin(bigint) from public;
revoke execute on function public.listar_geracoes_conteudo_admin(bigint) from anon;
grant execute on function public.listar_geracoes_conteudo_admin(bigint) to authenticated;

-- ============================================================================
-- FIM DO CORPO DA MIGRATION — daqui pra baixo é só o TEST HARNESS
-- ============================================================================

-- ---------------------------------------------------------------------------
-- SEÇÃO 3 + SEÇÃO 6 — catálogo: função existe, assinatura bigint,
-- SECURITY DEFINER, search_path vazio.
-- ---------------------------------------------------------------------------
do $$
begin
  insert into teste_2jb2_resultados values (
    'funcao_existe',
    exists (
      select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
      where n.nspname = 'public' and p.proname = 'listar_geracoes_conteudo_admin'
    )
  );
exception when others then
  insert into teste_2jb2_resultados values ('funcao_existe', false);
  raise notice 'funcao_existe: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

do $$
begin
  insert into teste_2jb2_resultados values (
    'assinatura_ok',
    exists (
      select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
      where n.nspname = 'public' and p.proname = 'listar_geracoes_conteudo_admin'
        and pg_get_function_identity_arguments(p.oid) = 'p_conteudo_id bigint'
    )
  );
exception when others then
  insert into teste_2jb2_resultados values ('assinatura_ok', false);
  raise notice 'assinatura_ok: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

do $$
begin
  insert into teste_2jb2_resultados values (
    'security_definer',
    coalesce((
      select p.prosecdef from pg_proc p join pg_namespace n on n.oid = p.pronamespace
      where n.nspname = 'public' and p.proname = 'listar_geracoes_conteudo_admin'
        and pg_get_function_identity_arguments(p.oid) = 'p_conteudo_id bigint'
    ), false)
  );
exception when others then
  insert into teste_2jb2_resultados values ('security_definer', false);
  raise notice 'security_definer: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- pg_proc.proconfig guarda cada entrada como texto bruto "nome=valor".
-- pg_options_to_table() é a forma robusta e canônica de separar isso em
-- option_name/option_value (evita comparar a string inteira do array, que
-- já se mostrou frágil). Confirmado via consulta real em produção que,
-- para search_path vazio, pg_options_to_table() NÃO desfaz as aspas do
-- valor: option_value chega literalmente como '""' (2 caracteres), não
-- como string vazia. Por isso a condição aceita EXPLICITAMENTE as duas
-- representações válidas de "search_path vazio" ('' e '""') — nunca uma
-- normalização permissiva (upper/trim/strip de aspas) que arriscaria
-- aceitar um search_path real não vazio como se fosse seguro.
do $$
begin
  insert into teste_2jb2_resultados values (
    'search_path_ok',
    exists (
      select 1 from pg_proc p
      join pg_namespace n on n.oid = p.pronamespace
      cross join lateral pg_options_to_table(p.proconfig) as opt
      where n.nspname = 'public' and p.proname = 'listar_geracoes_conteudo_admin'
        and pg_get_function_identity_arguments(p.oid) = 'p_conteudo_id bigint'
        and opt.option_name = 'search_path'
        and opt.option_value in ('', '""')
    )
  );
exception when others then
  insert into teste_2jb2_resultados values ('search_path_ok', false);
  raise notice 'search_path_ok: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- Colunas de retorno (RETURNS TABLE = OUT params, modo 't' em
-- proargmodes): comparação por ARRAY, não por texto formatado — evita
-- depender do formato exato de pg_get_function_result. Cobre de uma vez
-- "9 colunas", "contexto e a 9a", "contexto e jsonb" (secao 3) e "8
-- campos antigos preservados: mesmo nome/tipo/ordem" (secao 6).
-- ---------------------------------------------------------------------------
do $$
declare
  v_nomes text[];
  v_tipos text[];
begin
  select array_agg(x.nome order by x.ord), array_agg(x.tipo order by x.ord)
  into v_nomes, v_tipos
  from (
    select
      p.proargnames[s] as nome,
      format_type(p.proallargtypes[s], null) as tipo,
      s as ord
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    cross join lateral generate_subscripts(p.proargmodes, 1) as s
    where n.nspname = 'public' and p.proname = 'listar_geracoes_conteudo_admin'
      and p.proargmodes[s] = 't'
  ) x;

  insert into teste_2jb2_resultados values ('nove_colunas', coalesce(array_length(v_nomes, 1), 0) = 9);

  insert into teste_2jb2_resultados values (
    'oito_campos_antigos_preservados',
    coalesce(array_length(v_nomes, 1), 0) >= 8
    and v_nomes[1:8] = array['geracao_id', 'status', 'iniciado_em', 'finalizado_em', 'aula_versao_id', 'erro', 'prompt_version', 'modelo']
    and v_tipos[1:8] = array['uuid', 'text', 'timestamp with time zone', 'timestamp with time zone', 'uuid', 'text', 'text', 'text']
  );

  insert into teste_2jb2_resultados values (
    'contexto_nona_coluna',
    coalesce(array_length(v_nomes, 1), 0) = 9 and v_nomes[9] = 'contexto'
  );

  insert into teste_2jb2_resultados values (
    'contexto_jsonb',
    coalesce(array_length(v_tipos, 1), 0) = 9 and v_tipos[9] = 'jsonb'
  );
exception when others then
  insert into teste_2jb2_resultados values ('nove_colunas', false);
  insert into teste_2jb2_resultados values ('oito_campos_antigos_preservados', false);
  insert into teste_2jb2_resultados values ('contexto_nona_coluna', false);
  insert into teste_2jb2_resultados values ('contexto_jsonb', false);
  raise notice 'Colunas de retorno: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- SEÇÃO 4 — privilégios.
-- ---------------------------------------------------------------------------
do $$
begin
  insert into teste_2jb2_resultados values (
    'authenticated_pode_executar',
    has_function_privilege('authenticated', 'public.listar_geracoes_conteudo_admin(bigint)', 'EXECUTE')
  );
exception when others then
  insert into teste_2jb2_resultados values ('authenticated_pode_executar', false);
  raise notice 'authenticated_pode_executar: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

do $$
begin
  insert into teste_2jb2_resultados values (
    'anon_nao_pode_executar',
    not has_function_privilege('anon', 'public.listar_geracoes_conteudo_admin(bigint)', 'EXECUTE')
  );
exception when others then
  insert into teste_2jb2_resultados values ('anon_nao_pode_executar', false);
  raise notice 'anon_nao_pode_executar: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

do $$
begin
  insert into teste_2jb2_resultados values (
    'public_nao_pode_executar',
    not has_function_privilege('public', 'public.listar_geracoes_conteudo_admin(bigint)', 'EXECUTE')
  );
exception when others then
  insert into teste_2jb2_resultados values ('public_nao_pode_executar', false);
  raise notice 'public_nao_pode_executar: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- SEÇÃO 5 — teste funcional admin. Só roda se um admin real foi
-- encontrado no bloco de contexto; caso contrário, NULL + NOTICE (nunca
-- false — ausência de fixture não é uma falha da migration).
-- ---------------------------------------------------------------------------
do $$
declare
  v_admin_id text;
  v_admin_uuid uuid;
  v_conteudo_id_txt text;
  v_conteudo_id bigint;
  v_geracao1_id uuid;
  v_geracao2_id uuid;
  v_contexto1 jsonb;
  v_contexto2 jsonb;
begin
  select valor into v_admin_id from teste_2jb2_contexto where chave = 'admin_usuario_id';
  select valor into v_conteudo_id_txt from teste_2jb2_contexto where chave = 'conteudo_id';

  if v_admin_id is null or v_admin_id = '' or v_conteudo_id_txt is null or v_conteudo_id_txt = '' then
    insert into teste_2jb2_resultados values ('admin_rpc_funciona', null);
    insert into teste_2jb2_resultados values ('contexto_corresponde', null);
    raise notice '[admin_rpc_funciona/contexto_corresponde] pulados: nenhum admin real e/ou nenhum curso_conteudos real encontrado neste banco.';
    return;
  end if;

  v_admin_uuid := v_admin_id::uuid;
  v_conteudo_id := v_conteudo_id_txt::bigint;

  -- Fixtures de aula_geracoes: 2 linhas do mesmo conteudo, iniciado_em
  -- distintos (para o teste de ordenacao) e contexto identificavel
  -- ("[TESTE 2J-B2]"), nunca 'processando' (evita colidir com o indice
  -- unico parcial da trava de concorrencia real).
  v_contexto1 := jsonb_build_object('marcador', '[TESTE 2J-B2]', 'ordem', 1);
  v_contexto2 := jsonb_build_object('marcador', '[TESTE 2J-B2]', 'ordem', 2);

  insert into public.aula_geracoes (conteudo_id, status, criado_por, prompt_version, modelo, contexto, iniciado_em, finalizado_em)
  values (v_conteudo_id, 'concluida', v_admin_uuid, 'teste-2jb2', 'teste', v_contexto1, now(), now())
  returning id into v_geracao1_id;

  insert into public.aula_geracoes (conteudo_id, status, criado_por, prompt_version, modelo, contexto, iniciado_em, finalizado_em)
  values (v_conteudo_id, 'concluida', v_admin_uuid, 'teste-2jb2', 'teste', v_contexto2, now() - interval '2 hours', now() - interval '2 hours')
  returning id into v_geracao2_id;

  declare
    v_linha record;
    v_ids uuid[] := array[]::uuid[];
    v_iniciados timestamptz[] := array[]::timestamptz[];
    v_contexto_retornado jsonb;
    v_contexto_real jsonb;
    v_rpc_ok boolean;
    v_ordem_ok boolean := true;
    v_i integer;
  begin
    perform set_config('request.jwt.claims', json_build_object('sub', v_admin_uuid::text, 'role', 'authenticated')::text, true);
    set local role authenticated;

    -- SOMENTE a chamada da RPC acontece enquanto o role está trocado —
    -- tudo é acumulado em variáveis PL/pgSQL locais, nunca gravado em
    -- tabela temporária aqui (authenticated não teria privilégio nela).
    for v_linha in select * from public.listar_geracoes_conteudo_admin(v_conteudo_id) loop
      v_ids := array_append(v_ids, v_linha.geracao_id);
      v_iniciados := array_append(v_iniciados, v_linha.iniciado_em);
      if v_linha.geracao_id = v_geracao1_id then
        v_contexto_retornado := v_linha.contexto;
      end if;
    end loop;

    reset role;

    v_rpc_ok := (v_geracao1_id = any (v_ids)) and (v_geracao2_id = any (v_ids));

    for v_i in 1 .. coalesce(array_length(v_iniciados, 1), 0) - 1 loop
      if v_iniciados[v_i] < v_iniciados[v_i + 1] then
        v_ordem_ok := false;
      end if;
    end loop;

    -- Leitura direta em aula_geracoes só depois do reset role, como o
    -- role privilegiado da própria sessão de teste.
    select contexto into v_contexto_real from public.aula_geracoes where id = v_geracao1_id;

    insert into teste_2jb2_resultados values ('admin_rpc_funciona', v_rpc_ok and v_ordem_ok);
    insert into teste_2jb2_resultados values ('contexto_corresponde', v_contexto_retornado is not distinct from v_contexto_real);
  exception when others then
    reset role;
    insert into teste_2jb2_resultados values ('admin_rpc_funciona', false);
    insert into teste_2jb2_resultados values ('contexto_corresponde', false);
    raise notice '[admin_rpc_funciona/contexto_corresponde] falharam: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
  end;
exception when others then
  insert into teste_2jb2_resultados values ('admin_rpc_funciona', false);
  insert into teste_2jb2_resultados values ('contexto_corresponde', false);
  raise notice 'SECAO 5 (setup de fixtures) falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- RESULTADO FINAL
-- ---------------------------------------------------------------------------
select
  (select ok from teste_2jb2_resultados where chave = 'funcao_existe') as funcao_existe,
  (select ok from teste_2jb2_resultados where chave = 'assinatura_ok') as assinatura_ok,
  (select ok from teste_2jb2_resultados where chave = 'security_definer') as security_definer,
  (select ok from teste_2jb2_resultados where chave = 'search_path_ok') as search_path_ok,
  (select ok from teste_2jb2_resultados where chave = 'nove_colunas') as nove_colunas,
  (select ok from teste_2jb2_resultados where chave = 'oito_campos_antigos_preservados') as oito_campos_antigos_preservados,
  (select ok from teste_2jb2_resultados where chave = 'contexto_nona_coluna') as contexto_nona_coluna,
  (select ok from teste_2jb2_resultados where chave = 'contexto_jsonb') as contexto_jsonb,
  (select ok from teste_2jb2_resultados where chave = 'authenticated_pode_executar') as authenticated_pode_executar,
  (select ok from teste_2jb2_resultados where chave = 'anon_nao_pode_executar') as anon_nao_pode_executar,
  (select ok from teste_2jb2_resultados where chave = 'public_nao_pode_executar') as public_nao_pode_executar,
  (select ok from teste_2jb2_resultados where chave = 'admin_rpc_funciona') as admin_rpc_funciona,
  (select ok from teste_2jb2_resultados where chave = 'contexto_corresponde') as contexto_corresponde,
  not exists (
    select 1 from teste_2jb2_resultados where ok is distinct from true and ok is not null
  ) as tudo_ok;

ROLLBACK;
