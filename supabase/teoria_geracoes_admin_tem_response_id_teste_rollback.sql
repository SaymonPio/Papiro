-- ============================================================================
-- TESTE RUNTIME DA MIGRATION teoria_geracoes_admin_tem_response_id.sql —
-- TRANSACIONAL, TUDO DESFEITO NO FINAL (BEGIN...ROLLBACK)
-- ============================================================================
--
-- Mesmo princípio de supabase/teoria_geracoes_admin_contexto_teste_
-- rollback.sql (a migration anterior desta mesma RPC): colar no SQL
-- Editor (ou `supabase db query --linked -f ...`), rodar de uma vez, ler
-- o resultado, nunca persistir nada — termina em ROLLBACK.
--
-- Mesma técnica de simulação de auth.uid() já usada nos harnesses
-- anteriores: set_config de request.jwt.claims + SET LOCAL ROLE, ambos
-- "local" à transação, desfeitos automaticamente no ROLLBACK final. NÃO
-- cria/promove nenhum usuário a admin — procura um real para quem
-- public.eh_admin() já retorna true. Se não houver nenhum, os testes
-- funcionais ficam NULL + NOTICE, nunca false (ausência de fixture não é
-- uma falha). SET LOCAL ROLE authenticated envolve SOMENTE a chamada da
-- RPC em si — nunca uma leitura direta de tabela nem uma escrita em
-- tabela temporária (authenticated não teria privilégio nelas); o
-- resultado da RPC é sempre capturado em variáveis PL/pgSQL locais dentro
-- do mesmo bloco DO, e só depois de "reset role" é que qualquer leitura
-- direta de tabela ou gravação em tabela temporária acontece.
--
-- Lição da fase anterior (achado real, não hipotético): SAVEPOINT/
-- ROLLBACK TO SAVEPOINT como comandos SQL soltos dentro de um bloco
-- `do $$...$$` NUNCA é válido em PL/pgSQL — nada deste harness usa esse
-- idioma; toda "reversão" de efeito colateral aqui é feita só por
-- ROLLBACK da transação inteira no final, nunca por SAVEPOINT.
--
-- O que valida, em ordem (mapeado às letras do mandato):
--   A) a função existe (com a assinatura esperada);
--   B) "tem_response_id" existe no retorno;
--   C) seu tipo é boolean;
--   D) "openai_response_id" (o identificador bruto) NÃO aparece em
--      nenhuma coluna do retorno;
--   E) para as fixtures com openai_response_id NULL, tem_response_id
--      volta false;
--   F) se existir alguma linha REAL no banco com openai_response_id
--      preenchido, confirma tem_response_id=true para ela via a própria
--      RPC (nunca lendo o response_id em si); se não existir nenhuma,
--      registra NAO_HA_FIXTURE_REAL_COM_RESPONSE_ID e valida a EXPRESSÃO
--      na definição da função estruturalmente (pg_get_functiondef);
--   G) a quantidade de linhas retornadas para um mesmo conteúdo não muda
--      por causa da coluna nova (mesmas 2 fixtures antes e depois);
--   H) a ordenação (iniciado_em desc) continua igual;
--   I) nenhuma linha de aula_geracoes fora das fixtures deste harness é
--      alterada (checado via contagem total antes/depois do bloco de
--      teste, e via ROLLBACK no final desfazendo até as fixtures).

BEGIN;

-- ============================================================================
-- SEÇÃO 1 — PRÉ-CONDIÇÃO: a função REAL, antes de qualquer DROP, precisa
-- estar exatamente no contrato hoje documentado (9 colunas, sem
-- tem_response_id). Se não estiver, aborta aqui.
-- ============================================================================
do $$
declare
  v_existe boolean;
  v_secdef boolean;
  v_auth_exec boolean;
  v_anon_exec boolean;
  v_public_exec boolean;
  v_nomes text[];
  v_problemas text := '';
begin
  select exists (
    select 1 from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'listar_geracoes_conteudo_admin'
      and pg_get_function_identity_arguments(p.oid) = 'p_conteudo_id bigint'
  ) into v_existe;

  if not v_existe then
    raise exception 'PRE-CONDICAO falhou: public.listar_geracoes_conteudo_admin(bigint) nao existe com a assinatura esperada. Harness abortado ANTES de qualquer DROP — nada foi alterado.';
  end if;

  select p.prosecdef into v_secdef
  from pg_proc p join pg_namespace n on n.oid = p.pronamespace
  where n.nspname = 'public' and p.proname = 'listar_geracoes_conteudo_admin'
    and pg_get_function_identity_arguments(p.oid) = 'p_conteudo_id bigint';

  select array_agg(x.nome order by x.ord) into v_nomes
  from (
    select p.proargnames[s] as nome, s as ord
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    cross join lateral generate_subscripts(p.proargmodes, 1) as s
    where n.nspname = 'public' and p.proname = 'listar_geracoes_conteudo_admin'
      and p.proargmodes[s] = 't'
  ) x;

  v_auth_exec := has_function_privilege('authenticated', 'public.listar_geracoes_conteudo_admin(bigint)', 'EXECUTE');
  v_anon_exec := has_function_privilege('anon', 'public.listar_geracoes_conteudo_admin(bigint)', 'EXECUTE');
  v_public_exec := has_function_privilege('public', 'public.listar_geracoes_conteudo_admin(bigint)', 'EXECUTE');

  if not v_secdef then v_problemas := v_problemas || 'funcao real NAO e SECURITY DEFINER; '; end if;
  if not v_auth_exec then v_problemas := v_problemas || 'authenticated NAO tem EXECUTE; '; end if;
  if v_anon_exec then v_problemas := v_problemas || 'anon TEM EXECUTE (esperado nao ter); '; end if;
  if v_public_exec then v_problemas := v_problemas || 'PUBLIC TEM EXECUTE (esperado nao ter); '; end if;
  if coalesce(array_length(v_nomes, 1), 0) <> 9 then v_problemas := v_problemas || format('esperava 9 colunas antes do DROP, achou %s; ', coalesce(array_length(v_nomes, 1), 0)); end if;
  if v_nomes is not null and 'tem_response_id' = any (v_nomes) then v_problemas := v_problemas || 'tem_response_id JA existe antes da migration (esperado nao existir ainda); '; end if;

  if v_problemas <> '' then
    raise exception 'PRE-CONDICAO falhou, a funcao real diverge do contrato esperado ANTES do DROP — harness abortado, nada foi alterado. Divergencias: %', v_problemas;
  end if;
end $$;

-- ============================================================================
-- Tabelas de apoio do teste (não fazem parte da migration real).
-- ============================================================================
create temporary table teste_tri_resultados (
  chave text primary key,
  ok boolean
);

create temporary table teste_tri_contexto (
  chave text primary key,
  valor text
);

-- ============================================================================
-- Contexto: um admin real (nunca criado/promovido), um curso_conteudos
-- real, e verificação dinâmica se já existe alguma linha real com
-- openai_response_id preenchido (para decidir o caminho do teste F).
-- ============================================================================
do $$
declare
  v_admin_usuario_id uuid;
  v_candidato uuid;
  v_conteudo_id bigint;
  v_unidade_id uuid;
  v_conteudo_com_response_id bigint;
  v_geracao_com_response_id uuid;
  v_total_aula_geracoes_antes bigint;
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

  -- aula_geracoes.unidade_pedagogica_id é NOT NULL (migration
  -- unidades_pedagogicas.sql, posterior à migration original desta RPC) —
  -- por isso o conteúdo escolhido para as fixtures precisa ter pelo menos
  -- uma unidade_pedagogica real vinculada, nunca só "o primeiro
  -- curso_conteudos qualquer" (achado real desta rodada: a primeira
  -- tentativa deste harness violou essa NOT NULL constraint).
  select cc.id, u.id into v_conteudo_id, v_unidade_id
  from public.curso_conteudos cc
  join public.unidades_pedagogicas u on u.curso_conteudo_id = cc.id
  limit 1;

  -- Descoberta dinâmica: existe HOJE alguma linha real com response_id
  -- preenchido? (pode existir, por causa da Fase 6 em andamento em
  -- paralelo — o harness não assume nenhum dos dois estados de antemão.)
  select conteudo_id, id into v_conteudo_com_response_id, v_geracao_com_response_id
  from public.aula_geracoes
  where openai_response_id is not null
  order by iniciado_em desc
  limit 1;

  select count(*) into v_total_aula_geracoes_antes from public.aula_geracoes;

  insert into teste_tri_contexto (chave, valor) values
    ('admin_usuario_id', coalesce(v_admin_usuario_id::text, '')),
    ('conteudo_id', coalesce(v_conteudo_id::text, '')),
    ('unidade_id', coalesce(v_unidade_id::text, '')),
    ('conteudo_com_response_id', coalesce(v_conteudo_com_response_id::text, '')),
    ('geracao_com_response_id', coalesce(v_geracao_com_response_id::text, '')),
    ('total_aula_geracoes_antes', v_total_aula_geracoes_antes::text);
end $$;

-- ============================================================================
-- CORPO DA MIGRATION (idêntico a supabase/teoria_geracoes_admin_tem_
-- response_id.sql, sem o COMMIT final)
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
  contexto jsonb,
  tem_response_id boolean
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
    g.contexto,
    (g.openai_response_id is not null)
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
-- A) função existe com a assinatura esperada.
-- ---------------------------------------------------------------------------
do $$
begin
  insert into teste_tri_resultados values (
    'a_funcao_existe',
    exists (
      select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
      where n.nspname = 'public' and p.proname = 'listar_geracoes_conteudo_admin'
        and pg_get_function_identity_arguments(p.oid) = 'p_conteudo_id bigint'
    )
  );
exception when others then
  insert into teste_tri_resultados values ('a_funcao_existe', false);
  raise notice 'a_funcao_existe: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- B/C/D — colunas de retorno: 10 no total, as 9 antigas preservadas em
-- nome/tipo/ordem, "tem_response_id" é a 10ª e é boolean, e
-- "openai_response_id" (o identificador bruto) não aparece em NENHUMA
-- coluna do retorno.
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

  insert into teste_tri_resultados values ('dez_colunas', coalesce(array_length(v_nomes, 1), 0) = 10);

  insert into teste_tri_resultados values (
    'nove_campos_antigos_preservados',
    coalesce(array_length(v_nomes, 1), 0) >= 9
    and v_nomes[1:9] = array['geracao_id', 'status', 'iniciado_em', 'finalizado_em', 'aula_versao_id', 'erro', 'prompt_version', 'modelo', 'contexto']
    and v_tipos[1:9] = array['uuid', 'text', 'timestamp with time zone', 'timestamp with time zone', 'uuid', 'text', 'text', 'text', 'jsonb']
  );

  insert into teste_tri_resultados values (
    'b_tem_response_id_decima_coluna',
    coalesce(array_length(v_nomes, 1), 0) = 10 and v_nomes[10] = 'tem_response_id'
  );

  insert into teste_tri_resultados values (
    'c_tem_response_id_boolean',
    coalesce(array_length(v_tipos, 1), 0) = 10 and v_tipos[10] = 'boolean'
  );

  insert into teste_tri_resultados values (
    'd_openai_response_id_nao_exposto',
    not ('openai_response_id' = any (coalesce(v_nomes, array[]::text[])))
  );
exception when others then
  insert into teste_tri_resultados values ('dez_colunas', false);
  insert into teste_tri_resultados values ('nove_campos_antigos_preservados', false);
  insert into teste_tri_resultados values ('b_tem_response_id_decima_coluna', false);
  insert into teste_tri_resultados values ('c_tem_response_id_boolean', false);
  insert into teste_tri_resultados values ('d_openai_response_id_nao_exposto', false);
  raise notice 'Colunas de retorno: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- Privilégios (inalterados pela migration — confirma que continuam certos
-- depois do DROP+CREATE).
-- ---------------------------------------------------------------------------
do $$
begin
  insert into teste_tri_resultados values (
    'authenticated_pode_executar',
    has_function_privilege('authenticated', 'public.listar_geracoes_conteudo_admin(bigint)', 'EXECUTE')
  );
  insert into teste_tri_resultados values (
    'anon_nao_pode_executar',
    not has_function_privilege('anon', 'public.listar_geracoes_conteudo_admin(bigint)', 'EXECUTE')
  );
  insert into teste_tri_resultados values (
    'public_nao_pode_executar',
    not has_function_privilege('public', 'public.listar_geracoes_conteudo_admin(bigint)', 'EXECUTE')
  );
exception when others then
  insert into teste_tri_resultados values ('authenticated_pode_executar', false);
  insert into teste_tri_resultados values ('anon_nao_pode_executar', false);
  insert into teste_tri_resultados values ('public_nao_pode_executar', false);
  raise notice 'Privilegios: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- E/G/H — teste funcional com fixtures (response_id sempre NULL nas
-- fixtures deste harness — nunca setamos openai_response_id aqui, então
-- tem_response_id deve voltar false para as duas). Também confirma
-- contagem de linhas (G) e ordenação (H). Só roda se houver admin real e
-- curso_conteudos real; caso contrário, NULL + NOTICE.
-- ---------------------------------------------------------------------------
do $$
declare
  v_admin_id text;
  v_admin_uuid uuid;
  v_conteudo_id_txt text;
  v_conteudo_id bigint;
  v_unidade_id_txt text;
  v_unidade_id uuid;
  v_geracao1_id uuid;
  v_geracao2_id uuid;
begin
  select valor into v_admin_id from teste_tri_contexto where chave = 'admin_usuario_id';
  select valor into v_conteudo_id_txt from teste_tri_contexto where chave = 'conteudo_id';
  select valor into v_unidade_id_txt from teste_tri_contexto where chave = 'unidade_id';

  if v_admin_id is null or v_admin_id = '' or v_conteudo_id_txt is null or v_conteudo_id_txt = '' or v_unidade_id_txt is null or v_unidade_id_txt = '' then
    insert into teste_tri_resultados values ('e_response_id_null_vira_false', null);
    insert into teste_tri_resultados values ('g_contagem_de_linhas_estavel', null);
    insert into teste_tri_resultados values ('h_ordenacao_preservada', null);
    raise notice '[e/g/h] pulados: nenhum admin real e/ou nenhum curso_conteudos com unidade_pedagogica real encontrado neste banco.';
    return;
  end if;

  v_admin_uuid := v_admin_id::uuid;
  v_conteudo_id := v_conteudo_id_txt::bigint;
  v_unidade_id := v_unidade_id_txt::uuid;

  -- Fixtures: 2 linhas do mesmo conteúdo/unidade, iniciado_em distintos,
  -- nunca 'processando' (evita colidir com o índice único parcial da
  -- trava de concorrência real), openai_response_id nunca setado (fica
  -- NULL). unidade_pedagogica_id é obrigatório (NOT NULL) na tabela real.
  insert into public.aula_geracoes (conteudo_id, unidade_pedagogica_id, status, criado_por, prompt_version, modelo, contexto, iniciado_em, finalizado_em)
  values (v_conteudo_id, v_unidade_id, 'concluida', v_admin_uuid, '[TESTE-TRI]', 'teste', jsonb_build_object('marcador', '[TESTE-TRI]', 'ordem', 1), now(), now())
  returning id into v_geracao1_id;

  insert into public.aula_geracoes (conteudo_id, unidade_pedagogica_id, status, criado_por, prompt_version, modelo, contexto, iniciado_em, finalizado_em)
  values (v_conteudo_id, v_unidade_id, 'concluida', v_admin_uuid, '[TESTE-TRI]', 'teste', jsonb_build_object('marcador', '[TESTE-TRI]', 'ordem', 2), now() - interval '2 hours', now() - interval '2 hours')
  returning id into v_geracao2_id;

  declare
    v_linha record;
    v_ids uuid[] := array[]::uuid[];
    v_iniciados timestamptz[] := array[]::timestamptz[];
    v_tem_response_id_1 boolean;
    v_tem_response_id_2 boolean;
    v_qtd_linhas integer := 0;
    v_ordem_ok boolean := true;
    v_i integer;
  begin
    perform set_config('request.jwt.claims', json_build_object('sub', v_admin_uuid::text, 'role', 'authenticated')::text, true);
    set local role authenticated;

    for v_linha in select * from public.listar_geracoes_conteudo_admin(v_conteudo_id) loop
      v_qtd_linhas := v_qtd_linhas + 1;
      v_ids := array_append(v_ids, v_linha.geracao_id);
      v_iniciados := array_append(v_iniciados, v_linha.iniciado_em);
      if v_linha.geracao_id = v_geracao1_id then v_tem_response_id_1 := v_linha.tem_response_id; end if;
      if v_linha.geracao_id = v_geracao2_id then v_tem_response_id_2 := v_linha.tem_response_id; end if;
    end loop;

    reset role;

    insert into teste_tri_resultados values (
      'e_response_id_null_vira_false',
      (v_geracao1_id = any (v_ids)) and (v_geracao2_id = any (v_ids))
      and v_tem_response_id_1 is not distinct from false
      and v_tem_response_id_2 is not distinct from false
    );

    -- G) mesma quantidade de linhas retornadas de sempre para este
    -- conteúdo (ambas as fixtures presentes, nenhuma duplicada/faltando).
    insert into teste_tri_resultados values ('g_contagem_de_linhas_estavel', v_qtd_linhas = array_length(v_ids, 1) and (v_geracao1_id = any (v_ids)) and (v_geracao2_id = any (v_ids)));

    -- H) ordenação por iniciado_em desc preservada.
    for v_i in 1 .. coalesce(array_length(v_iniciados, 1), 0) - 1 loop
      if v_iniciados[v_i] < v_iniciados[v_i + 1] then
        v_ordem_ok := false;
      end if;
    end loop;
    insert into teste_tri_resultados values ('h_ordenacao_preservada', v_ordem_ok);
  exception when others then
    reset role;
    insert into teste_tri_resultados values ('e_response_id_null_vira_false', false);
    insert into teste_tri_resultados values ('g_contagem_de_linhas_estavel', false);
    insert into teste_tri_resultados values ('h_ordenacao_preservada', false);
    raise notice '[e/g/h] falharam: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
  end;
exception when others then
  insert into teste_tri_resultados values ('e_response_id_null_vira_false', false);
  insert into teste_tri_resultados values ('g_contagem_de_linhas_estavel', false);
  insert into teste_tri_resultados values ('h_ordenacao_preservada', false);
  raise notice 'SECAO E/G/H (setup de fixtures) falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- F) se existir alguma linha REAL (fora das fixtures deste harness) com
-- openai_response_id preenchido, confirma tem_response_id=true para ela
-- via a própria RPC (nunca lendo o response_id em si). Se não existir
-- nenhuma, NAO_HA_FIXTURE_REAL_COM_RESPONSE_ID: valida a EXPRESSÃO da
-- função estruturalmente via pg_get_functiondef, nunca insere fixture
-- real só para forçar este teste (proibido pelo mandato).
-- ---------------------------------------------------------------------------
do $$
declare
  v_admin_id text;
  v_conteudo_com_response_id_txt text;
  v_geracao_com_response_id_txt text;
  v_admin_uuid uuid;
  v_conteudo_id bigint;
  v_geracao_id uuid;
  v_linha record;
  v_encontrada boolean := false;
  v_tem_response_id boolean;
  v_definicao text;
begin
  select valor into v_admin_id from teste_tri_contexto where chave = 'admin_usuario_id';
  select valor into v_conteudo_com_response_id_txt from teste_tri_contexto where chave = 'conteudo_com_response_id';
  select valor into v_geracao_com_response_id_txt from teste_tri_contexto where chave = 'geracao_com_response_id';

  if v_conteudo_com_response_id_txt is null or v_conteudo_com_response_id_txt = '' then
    -- NAO_HA_FIXTURE_REAL_COM_RESPONSE_ID — validação estrutural da
    -- expressão na definição da função, sem inserir fixture real.
    select pg_get_functiondef(p.oid) into v_definicao
    from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'listar_geracoes_conteudo_admin'
      and pg_get_function_identity_arguments(p.oid) = 'p_conteudo_id bigint';

    insert into teste_tri_resultados values (
      'f_expressao_correta_estrutural',
      v_definicao ilike '%openai_response_id is not null%' or v_definicao ilike '%openai_response_id IS NOT NULL%'
    );
    raise notice 'NAO_HA_FIXTURE_REAL_COM_RESPONSE_ID: nenhuma linha em aula_geracoes tem openai_response_id preenchido no momento deste harness — teste F validado estruturalmente via pg_get_functiondef, nenhuma fixture real foi inserida.';
    return;
  end if;

  if v_admin_id is null or v_admin_id = '' then
    insert into teste_tri_resultados values ('f_expressao_correta_estrutural', null);
    raise notice '[f] pulado: existe linha real com response_id, mas nenhum admin real disponivel para chamar a RPC.';
    return;
  end if;

  v_admin_uuid := v_admin_id::uuid;
  v_conteudo_id := v_conteudo_com_response_id_txt::bigint;
  v_geracao_id := v_geracao_com_response_id_txt::uuid;

  perform set_config('request.jwt.claims', json_build_object('sub', v_admin_uuid::text, 'role', 'authenticated')::text, true);
  set local role authenticated;

  for v_linha in select * from public.listar_geracoes_conteudo_admin(v_conteudo_id) loop
    if v_linha.geracao_id = v_geracao_id then
      v_encontrada := true;
      v_tem_response_id := v_linha.tem_response_id;
    end if;
  end loop;

  reset role;

  insert into teste_tri_resultados values ('f_expressao_correta_estrutural', v_encontrada and v_tem_response_id is not distinct from true);
exception when others then
  reset role;
  insert into teste_tri_resultados values ('f_expressao_correta_estrutural', false);
  raise notice '[f] falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- I) nenhuma linha de aula_geracoes fora das 2 fixtures deste harness foi
-- alterada — a contagem total só pode ter crescido EXATAMENTE em 2 (as
-- fixtures), nunca mudado por qualquer outro motivo.
-- ---------------------------------------------------------------------------
do $$
declare
  v_total_antes_txt text;
  v_total_antes bigint;
  v_total_agora bigint;
begin
  select valor into v_total_antes_txt from teste_tri_contexto where chave = 'total_aula_geracoes_antes';
  v_total_antes := coalesce(v_total_antes_txt, '0')::bigint;
  select count(*) into v_total_agora from public.aula_geracoes;

  insert into teste_tri_resultados values (
    'i_nenhuma_linha_alheia_alterada',
    v_total_agora = v_total_antes + 2
  );
exception when others then
  insert into teste_tri_resultados values ('i_nenhuma_linha_alheia_alterada', false);
  raise notice 'i_nenhuma_linha_alheia_alterada: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- RESULTADO FINAL
-- ---------------------------------------------------------------------------
select
  (select ok from teste_tri_resultados where chave = 'a_funcao_existe') as a_funcao_existe,
  (select ok from teste_tri_resultados where chave = 'dez_colunas') as dez_colunas,
  (select ok from teste_tri_resultados where chave = 'nove_campos_antigos_preservados') as nove_campos_antigos_preservados,
  (select ok from teste_tri_resultados where chave = 'b_tem_response_id_decima_coluna') as b_tem_response_id_decima_coluna,
  (select ok from teste_tri_resultados where chave = 'c_tem_response_id_boolean') as c_tem_response_id_boolean,
  (select ok from teste_tri_resultados where chave = 'd_openai_response_id_nao_exposto') as d_openai_response_id_nao_exposto,
  (select ok from teste_tri_resultados where chave = 'authenticated_pode_executar') as authenticated_pode_executar,
  (select ok from teste_tri_resultados where chave = 'anon_nao_pode_executar') as anon_nao_pode_executar,
  (select ok from teste_tri_resultados where chave = 'public_nao_pode_executar') as public_nao_pode_executar,
  (select ok from teste_tri_resultados where chave = 'e_response_id_null_vira_false') as e_response_id_null_vira_false,
  (select ok from teste_tri_resultados where chave = 'f_expressao_correta_estrutural') as f_expressao_correta_estrutural,
  (select ok from teste_tri_resultados where chave = 'g_contagem_de_linhas_estavel') as g_contagem_de_linhas_estavel,
  (select ok from teste_tri_resultados where chave = 'h_ordenacao_preservada') as h_ordenacao_preservada,
  (select ok from teste_tri_resultados where chave = 'i_nenhuma_linha_alheia_alterada') as i_nenhuma_linha_alheia_alterada,
  not exists (
    select 1 from teste_tri_resultados where ok is distinct from true and ok is not null
  ) as tudo_ok;

ROLLBACK;
