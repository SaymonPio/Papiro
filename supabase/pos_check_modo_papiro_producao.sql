-- ============================================================================
-- PÓS-CHECK DE PRODUÇÃO — Modo Papiro por Unidades Pedagógicas
-- ============================================================================
--
-- SOMENTE LEITURA. Nenhum INSERT/UPDATE/DELETE/CREATE/ALTER/DROP — só
-- consultas a pg_catalog/information_schema e funções de inquérito de
-- privilégio (has_function_privilege/has_table_privilege), todas STRICT e
-- seguras mesmo quando o objeto não existe (nunca lança exceção; nesse caso
-- o check correspondente simplesmente vira false).
--
-- Confere exatamente o que as duas migrations abaixo deveriam ter criado,
-- com nomes/assinaturas extraídos diretamente dos arquivos reais:
--   - supabase/questao_unidades_pedagogicas.sql
--   - supabase/missao_pratica_papiro_rpc.sql
--
-- Cada verificação é calculada UMA ÚNICA VEZ (em CTEs) — tudo_ok só
-- referencia essas colunas já calculadas, nunca reescreve a lógica, para
-- não correr o risco de "tudo_ok" divergir de alguma coluna individual.
--
-- Cole no SQL Editor do Supabase e rode de uma vez. Resultado: 1 linha, uma
-- coluna booleana por verificação, terminando em tudo_ok.
-- ============================================================================

with alvo_funcoes (categoria, assinatura, espera_authenticated, espera_stable) as (
  values
    -- trigger function de questao_unidades_pedagogicas.sql — interna, sem
    -- EXECUTE para ninguém (só chamada pelo próprio trigger).
    ('interna',  'public.validar_questao_unidade_pedagogica()',                                                        false, false),
    -- helpers de seleção de missao_pratica_papiro_rpc.sql — internos, sem
    -- EXECUTE para ninguém (só chamados de dentro de outra SECURITY DEFINER
    -- deste mesmo arquivo).
    ('interna',  'public.selecionar_candidatas_unidade_pedagogica(uuid, uuid, uuid, integer, bigint[], uuid)',          false, true),
    ('interna',  'public.selecionar_candidatas_conteudo(uuid, bigint, uuid, integer, bigint[], uuid)',                  false, true),
    -- RPCs administrativas de curadoria de questao_unidades_pedagogicas.sql
    -- — públicas, só para authenticated.
    ('publica',  'public.classificar_questao_unidade_admin(bigint, uuid)',                                              true,  false),
    ('publica',  'public.remover_classificacao_questao_unidade_admin(bigint, uuid)',                                    true,  false),
    ('publica',  'public.listar_questoes_unidade_admin(uuid)',                                                          true,  false),
    ('publica',  'public.listar_questoes_nao_classificadas_admin(bigint)',                                              true,  false),
    -- RPCs de fluxo de missao_pratica_papiro_rpc.sql — públicas, só para
    -- authenticated.
    ('publica',  'public.iniciar_pratica_unidade(uuid, uuid, boolean)',                                                 true,  false),
    ('publica',  'public.concluir_pratica_unidade(uuid, bigint)',                                                       true,  false),
    ('publica',  'public.iniciar_missao_final(uuid, boolean)',                                                          true,  false),
    ('publica',  'public.concluir_missao_final(uuid, bigint)',                                                          true,  false)
),
resolvidas as (
  select
    categoria,
    assinatura,
    espera_authenticated,
    espera_stable,
    to_regprocedure(assinatura) as oid_func
  from alvo_funcoes
),
propriedades as (
  select
    r.categoria,
    r.assinatura,
    r.espera_authenticated,
    r.espera_stable,
    (r.oid_func is not null) as existe,
    coalesce(p.prosecdef, false) as secdef_ok,
    coalesce(p.oid is not null and exists (
      select 1 from pg_options_to_table(p.proconfig) opt
      where opt.option_name = 'search_path' and opt.option_value in ('', '""')
    ), false) as search_path_ok,
    coalesce(p.provolatile = 's', false) as stable_ok,
    coalesce(has_function_privilege('authenticated', r.oid_func, 'EXECUTE'), false) as grant_authenticated,
    coalesce(has_function_privilege('anon', r.oid_func, 'EXECUTE'), false) as grant_anon,
    coalesce(p.oid is not null and exists (
      select 1 from aclexplode(coalesce(p.proacl, acldefault('f', p.proowner))) a
      where a.grantee = 0 and a.privilege_type = 'EXECUTE'
    ), false) as grant_public
  from resolvidas r
  left join pg_proc p on p.oid = r.oid_func
),
resumo_funcoes as (
  select
    bool_and(existe) as rpcs_todas_existem_com_assinatura_exata,
    bool_and(secdef_ok and search_path_ok) as rpcs_security_definer_search_path_vazio_ok,
    bool_and(stable_ok) filter (where espera_stable) as rpcs_selecionar_candidatas_sao_stable_ok,
    bool_and(grant_authenticated) filter (where espera_authenticated) as rpcs_publicas_tem_grant_authenticated_ok,
    bool_and(not grant_authenticated) filter (where not espera_authenticated) as rpcs_internas_sem_grant_authenticated_ok,
    bool_and(not grant_anon and not grant_public) as rpcs_todas_sem_grant_anon_nem_public_ok
  from propriedades
),
checks_estruturais as (
  select
    -- ------------------------------------------------------------------
    -- public.questao_unidades_pedagogicas (tabela + PK/FKs + RLS + índice)
    -- ------------------------------------------------------------------
    (to_regclass('public.questao_unidades_pedagogicas') is not null)
      as qup_tabela_existe,

    (
      select count(*) = 4
      from information_schema.columns c
      where c.table_schema = 'public' and c.table_name = 'questao_unidades_pedagogicas'
        and (
          (c.column_name = 'questao_id' and c.data_type = 'bigint' and c.is_nullable = 'NO')
          or (c.column_name = 'unidade_pedagogica_id' and c.data_type = 'uuid' and c.is_nullable = 'NO')
          or (c.column_name = 'classificado_por' and c.data_type = 'uuid' and c.is_nullable = 'YES')
          or (c.column_name = 'criado_em' and c.data_type = 'timestamp with time zone' and c.is_nullable = 'NO' and c.column_default ilike 'now()%')
        )
    ) as qup_colunas_tipos_ok,

    (exists (
      select 1 from pg_constraint c
      where c.conrelid = to_regclass('public.questao_unidades_pedagogicas')
        and c.contype = 'p'
        and pg_get_constraintdef(c.oid) ilike '%PRIMARY KEY (questao_id, unidade_pedagogica_id)%'
    )) as qup_pk_ok,

    (exists (
      select 1 from pg_constraint c
      where c.conrelid = to_regclass('public.questao_unidades_pedagogicas')
        and c.contype = 'f'
        and pg_get_constraintdef(c.oid) ilike '%FOREIGN KEY (questao_id) REFERENCES%questoes(id)%ON DELETE CASCADE%'
    )) as qup_fk_questao_ok,

    (exists (
      select 1 from pg_constraint c
      where c.conrelid = to_regclass('public.questao_unidades_pedagogicas')
        and c.contype = 'f'
        and pg_get_constraintdef(c.oid) ilike '%FOREIGN KEY (unidade_pedagogica_id) REFERENCES%unidades_pedagogicas(id)%ON DELETE CASCADE%'
    )) as qup_fk_unidade_ok,

    (exists (
      select 1 from pg_constraint c
      where c.conrelid = to_regclass('public.questao_unidades_pedagogicas')
        and c.contype = 'f'
        and pg_get_constraintdef(c.oid) ilike '%FOREIGN KEY (classificado_por) REFERENCES auth.users(id)%ON DELETE SET NULL%'
    )) as qup_fk_classificado_por_ok,

    coalesce((select relrowsecurity from pg_class where oid = to_regclass('public.questao_unidades_pedagogicas')), false)
      as qup_rls_habilitado,

    (exists (
      select 1 from pg_indexes
      where schemaname = 'public' and tablename = 'questao_unidades_pedagogicas'
        and indexname = 'questao_unidades_pedagogicas_unidade_idx'
        and indexdef ilike '%(unidade_pedagogica_id)%'
    )) as qup_indice_unidade_ok,

    not coalesce(has_table_privilege('anon', to_regclass('public.questao_unidades_pedagogicas'), 'SELECT,INSERT,UPDATE,DELETE'), false)
      as qup_sem_grant_anon,

    not coalesce(has_table_privilege('authenticated', to_regclass('public.questao_unidades_pedagogicas'), 'SELECT,INSERT,UPDATE,DELETE'), false)
      as qup_sem_grant_authenticated,

    -- ------------------------------------------------------------------
    -- trigger de integridade materia/assunto
    -- ------------------------------------------------------------------
    (exists (
      select 1
      from pg_trigger tg
      join pg_class t on t.oid = tg.tgrelid
      join pg_namespace n on n.oid = t.relnamespace
      where n.nspname = 'public' and t.relname = 'questao_unidades_pedagogicas'
        and tg.tgname = 'questao_unidades_pedagogicas_valida'
        and not tg.tgisinternal
        and tg.tgenabled <> 'D'
        and pg_get_triggerdef(tg.oid) ilike '%before insert or update%'
        and pg_get_triggerdef(tg.oid) ilike '%for each row%'
        and pg_get_triggerdef(tg.oid) ilike '%validar_questao_unidade_pedagogica%'
    )) as trigger_valida_habilitado_ok,

    -- ------------------------------------------------------------------
    -- public.missoes.progresso_questoes
    -- ------------------------------------------------------------------
    (exists (
      select 1 from information_schema.columns c
      where c.table_schema = 'public' and c.table_name = 'missoes' and c.column_name = 'progresso_questoes'
        and c.data_type = 'jsonb' and c.is_nullable = 'NO'
        and c.column_default ilike '%{}%jsonb%'
    )) as missoes_coluna_progresso_questoes_ok,

    (exists (
      select 1 from pg_constraint c
      where c.conrelid = to_regclass('public.missoes')
        and c.contype = 'c'
        and pg_get_constraintdef(c.oid) ilike '%progresso_questoes%object%'
    )) as missoes_check_progresso_questoes_ok,

    -- ------------------------------------------------------------------
    -- public.sessoes_estudo — colunas novas, FK, constraint de coerência,
    -- índices novos
    -- ------------------------------------------------------------------
    (exists (
      select 1 from information_schema.columns c
      where c.table_schema = 'public' and c.table_name = 'sessoes_estudo' and c.column_name = 'unidade_pedagogica_id'
        and c.data_type = 'uuid' and c.is_nullable = 'YES'
    )) as sessoes_estudo_coluna_unidade_ok,

    (exists (
      select 1 from information_schema.columns c
      where c.table_schema = 'public' and c.table_name = 'sessoes_estudo' and c.column_name = 'tipo_pratica'
        and c.data_type = 'text' and c.is_nullable = 'YES'
    )) as sessoes_estudo_coluna_tipo_pratica_ok,

    (exists (
      select 1 from pg_constraint c
      where c.conrelid = to_regclass('public.sessoes_estudo')
        and c.contype = 'c'
        and pg_get_constraintdef(c.oid) ilike '%tipo_pratica%unidade%missao_final%'
    )) as sessoes_estudo_check_tipo_pratica_valores_ok,

    (exists (
      select 1 from pg_constraint c
      where c.conrelid = to_regclass('public.sessoes_estudo')
        and c.conname = 'sessoes_estudo_tipo_pratica_coerente'
        and c.contype = 'c'
        and pg_get_constraintdef(c.oid) ilike '%unidade_pedagogica_id%'
        and pg_get_constraintdef(c.oid) ilike '%tipo_pratica%'
    )) as sessoes_estudo_constraint_coerente_ok,

    (exists (
      select 1 from pg_constraint c
      where c.conrelid = to_regclass('public.sessoes_estudo')
        and c.contype = 'f'
        and pg_get_constraintdef(c.oid) ilike '%FOREIGN KEY (unidade_pedagogica_id) REFERENCES%unidades_pedagogicas(id)%ON DELETE SET NULL%'
    )) as sessoes_estudo_fk_unidade_ok,

    (exists (
      select 1 from pg_indexes
      where schemaname = 'public' and tablename = 'sessoes_estudo'
        and indexname = 'sessoes_estudo_missao_unidade_idx'
        and indexdef ilike '%(missao_id, unidade_pedagogica_id)%'
    )) as sessoes_estudo_indice_missao_unidade_ok,

    (exists (
      select 1 from pg_indexes
      where schemaname = 'public' and tablename = 'sessoes_estudo'
        and indexname = 'sessoes_estudo_missao_tipo_idx'
        and indexdef ilike '%(missao_id, tipo_pratica)%'
    )) as sessoes_estudo_indice_missao_tipo_ok
)
select
  ce.qup_tabela_existe,
  ce.qup_colunas_tipos_ok,
  ce.qup_pk_ok,
  ce.qup_fk_questao_ok,
  ce.qup_fk_unidade_ok,
  ce.qup_fk_classificado_por_ok,
  ce.qup_rls_habilitado,
  ce.qup_indice_unidade_ok,
  ce.qup_sem_grant_anon,
  ce.qup_sem_grant_authenticated,
  ce.trigger_valida_habilitado_ok,
  ce.missoes_coluna_progresso_questoes_ok,
  ce.missoes_check_progresso_questoes_ok,
  ce.sessoes_estudo_coluna_unidade_ok,
  ce.sessoes_estudo_coluna_tipo_pratica_ok,
  ce.sessoes_estudo_check_tipo_pratica_valores_ok,
  ce.sessoes_estudo_constraint_coerente_ok,
  ce.sessoes_estudo_fk_unidade_ok,
  ce.sessoes_estudo_indice_missao_unidade_ok,
  ce.sessoes_estudo_indice_missao_tipo_ok,
  -- Todas as 11 funções das 2 migrations (1 trigger fn + 2 helpers
  -- internos + 4 RPCs administrativas + 4 RPCs de fluxo): existência com
  -- assinatura EXATA, SECURITY DEFINER + search_path vazio, STABLE onde
  -- previsto, e grants corretos (authenticated só nas públicas; nenhuma
  -- delas com EXECUTE para anon ou para PUBLIC).
  rf.rpcs_todas_existem_com_assinatura_exata,
  rf.rpcs_security_definer_search_path_vazio_ok,
  rf.rpcs_selecionar_candidatas_sao_stable_ok,
  rf.rpcs_publicas_tem_grant_authenticated_ok,
  rf.rpcs_internas_sem_grant_authenticated_ok,
  rf.rpcs_todas_sem_grant_anon_nem_public_ok,
  (
    ce.qup_tabela_existe
    and ce.qup_colunas_tipos_ok
    and ce.qup_pk_ok
    and ce.qup_fk_questao_ok
    and ce.qup_fk_unidade_ok
    and ce.qup_fk_classificado_por_ok
    and ce.qup_rls_habilitado
    and ce.qup_indice_unidade_ok
    and ce.qup_sem_grant_anon
    and ce.qup_sem_grant_authenticated
    and ce.trigger_valida_habilitado_ok
    and ce.missoes_coluna_progresso_questoes_ok
    and ce.missoes_check_progresso_questoes_ok
    and ce.sessoes_estudo_coluna_unidade_ok
    and ce.sessoes_estudo_coluna_tipo_pratica_ok
    and ce.sessoes_estudo_check_tipo_pratica_valores_ok
    and ce.sessoes_estudo_constraint_coerente_ok
    and ce.sessoes_estudo_fk_unidade_ok
    and ce.sessoes_estudo_indice_missao_unidade_ok
    and ce.sessoes_estudo_indice_missao_tipo_ok
    and rf.rpcs_todas_existem_com_assinatura_exata
    and rf.rpcs_security_definer_search_path_vazio_ok
    and rf.rpcs_selecionar_candidatas_sao_stable_ok
    and rf.rpcs_publicas_tem_grant_authenticated_ok
    and rf.rpcs_internas_sem_grant_authenticated_ok
    and rf.rpcs_todas_sem_grant_anon_nem_public_ok
  ) as tudo_ok
from checks_estruturais ce, resumo_funcoes rf;
