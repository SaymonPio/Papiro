-- Pós-check READ-ONLY para rodar DEPOIS de um apply real (futuro) de
-- supabase/camada_ilustrada_pipeline.sql. Só SELECTs/leituras de catálogo, nenhuma
-- escrita, seguro de rodar quantas vezes quiser. Um único resultado: cada coluna
-- booleana deve ser true (contadores no fim). Substitui, para a tabela, o pós-check
-- da Q9 (que espera 17 colunas e 7 CHECKs).
select
  -- colunas e constraints novas
  (select string_agg(column_name || ':' || data_type || ':' || is_nullable, ',' order by ordinal_position)
     from information_schema.columns where table_schema = 'public' and table_name = 'aula_quadrinho_assets')
    = 'id:uuid:NO,aula_versao_id:uuid:NO,componente_id:uuid:NO,quadro_indice:smallint:NO,scene_hash:text:NO,status:text:NO,storage_path:text:YES,modelo:text:YES,prompt_version:text:YES,prompt_visual:text:YES,tentativas:smallint:NO,lease_ate:timestamp with time zone:YES,erro_sanitizado:text:YES,aprovado_por:uuid:YES,aprovado_em:timestamp with time zone:YES,criado_em:timestamp with time zone:NO,atualizado_em:timestamp with time zone:NO,claim_token:uuid:YES,storage_path_anterior:text:YES'
    as colunas_corretas,
  (select count(*) from pg_constraint where conrelid = 'public.aula_quadrinho_assets'::regclass and contype = 'c') = 9 as nove_checks,
  exists (select 1 from pg_constraint where conrelid = 'public.aula_quadrinho_assets'::regclass and conname = 'aula_quadrinho_assets_claim_coerente_check') as check_claim_coerente,
  exists (select 1 from pg_constraint where conrelid = 'public.aula_quadrinho_assets'::regclass and conname = 'aula_quadrinho_assets_path_anterior_check') as check_path_anterior,
  exists (select 1 from pg_indexes where schemaname = 'public' and tablename = 'aula_quadrinho_assets'
            and indexname = 'aula_quadrinho_assets_path_anterior_key' and indexdef ilike '%UNIQUE%(storage_path_anterior)%WHERE%storage_path_anterior IS NOT NULL%') as indice_unico_path_anterior,
  -- fundação Q9 intacta
  (select count(*) from pg_constraint where conrelid = 'public.aula_quadrinho_assets'::regclass and contype = 'p') = 1
    and exists (select 1 from pg_constraint where conrelid = 'public.aula_quadrinho_assets'::regclass and conname = 'aula_quadrinho_assets_chave_key' and contype = 'u')
    and exists (select 1 from pg_indexes where schemaname = 'public' and indexname = 'aula_quadrinho_assets_storage_path_key') as q9_pk_unique_indices,
  (select relrowsecurity from pg_class where oid = 'public.aula_quadrinho_assets'::regclass) as q9_rls_habilitado,
  not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'aula_quadrinho_assets') as q9_tabela_sem_policy,
  not (has_table_privilege('anon', 'public.aula_quadrinho_assets', 'select') or has_table_privilege('anon', 'public.aula_quadrinho_assets', 'insert')
    or has_table_privilege('anon', 'public.aula_quadrinho_assets', 'update') or has_table_privilege('anon', 'public.aula_quadrinho_assets', 'delete')
    or has_table_privilege('authenticated', 'public.aula_quadrinho_assets', 'select') or has_table_privilege('authenticated', 'public.aula_quadrinho_assets', 'insert')
    or has_table_privilege('authenticated', 'public.aula_quadrinho_assets', 'update') or has_table_privilege('authenticated', 'public.aula_quadrinho_assets', 'delete')) as q9_clientes_sem_acesso_direto,
  (select jsonb_object_agg(p.proname, md5(pg_get_functiondef(p.oid))) from pg_proc p join pg_namespace n on n.oid = p.pronamespace
     where n.nspname = 'public' and p.proname in ('hash_cena_quadrinho', 'hash_cena_atual_quadrinho', 'carregar_quadrinho_assets_aula', 'carregar_quadrinho_assets_admin'))
    = '{"hash_cena_quadrinho": "2779b0d927b88a6946b31636dff13804", "hash_cena_atual_quadrinho": "0fd391aacd21da2eb83ad06ec38db44b", "carregar_quadrinho_assets_aula": "ee2c134d44bdbb00e45f0973eb20e33b", "carregar_quadrinho_assets_admin": "4d6a052a6b05e49d585fe2c9360d3b84"}'::jsonb
    as q9_funcoes_inalteradas,
  exists (select 1 from storage.buckets where id = 'quadrinhos-aulas' and public = false and file_size_limit = 262144 and allowed_mime_types = array['image/webp']) as bucket_intacto,
  not exists (select 1 from pg_policies where schemaname = 'storage' and tablename = 'objects'
                and (coalesce(qual, '') || ' ' || coalesce(with_check, '')) like '%quadrinhos-aulas%') as sem_policy_de_storage_para_o_bucket,
  (select count(*) from pg_policies where schemaname = 'storage' and tablename = 'objects') = 6 as policies_de_storage_inalteradas,
  -- funções do pipeline: exatamente uma de cada
  (select count(*) from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public' and p.proname in (
      'criar_jobs_quadrinho_admin', 'reservar_quadrinho_asset', 'concluir_quadrinho_asset', 'falhar_quadrinho_asset',
      'aprovar_quadrinho_asset_admin', 'rejeitar_quadrinho_asset_admin', 'regenerar_quadrinho_asset_admin',
      'preparar_exclusao_quadrinho_asset_admin', 'excluir_quadrinho_asset_admin',
      'quadrinho_asset_lease', 'quadrinho_componente', 'cena_atual_quadrinho', 'quadrinho_path_no_storage', 'quadrinho_asset_reiniciar')) = 14 as quatorze_funcoes_sem_duplicata,
  -- grants: helpers e worker fechados; admin só authenticated
  not (has_function_privilege('anon', 'public.quadrinho_asset_lease()'::regprocedure, 'execute') or has_function_privilege('authenticated', 'public.quadrinho_asset_lease()'::regprocedure, 'execute')
    or has_function_privilege('anon', 'public.quadrinho_componente(uuid,uuid)'::regprocedure, 'execute') or has_function_privilege('authenticated', 'public.quadrinho_componente(uuid,uuid)'::regprocedure, 'execute')
    or has_function_privilege('anon', 'public.cena_atual_quadrinho(uuid,uuid,smallint)'::regprocedure, 'execute') or has_function_privilege('authenticated', 'public.cena_atual_quadrinho(uuid,uuid,smallint)'::regprocedure, 'execute')
    or has_function_privilege('anon', 'public.quadrinho_path_no_storage(text)'::regprocedure, 'execute') or has_function_privilege('authenticated', 'public.quadrinho_path_no_storage(text)'::regprocedure, 'execute')
    or has_function_privilege('anon', 'public.quadrinho_asset_reiniciar(uuid,text)'::regprocedure, 'execute') or has_function_privilege('authenticated', 'public.quadrinho_asset_reiniciar(uuid,text)'::regprocedure, 'execute')) as helpers_fechados_para_clientes,
  not (has_function_privilege('anon', 'public.reservar_quadrinho_asset(uuid)'::regprocedure, 'execute') or has_function_privilege('authenticated', 'public.reservar_quadrinho_asset(uuid)'::regprocedure, 'execute')
    or has_function_privilege('anon', 'public.concluir_quadrinho_asset(uuid,uuid,text,text,text,text,text)'::regprocedure, 'execute') or has_function_privilege('authenticated', 'public.concluir_quadrinho_asset(uuid,uuid,text,text,text,text,text)'::regprocedure, 'execute')
    or has_function_privilege('anon', 'public.falhar_quadrinho_asset(uuid,uuid,text)'::regprocedure, 'execute') or has_function_privilege('authenticated', 'public.falhar_quadrinho_asset(uuid,uuid,text)'::regprocedure, 'execute')) as worker_fechado_para_clientes,
  has_function_privilege('service_role', 'public.reservar_quadrinho_asset(uuid)'::regprocedure, 'execute')
    and has_function_privilege('service_role', 'public.concluir_quadrinho_asset(uuid,uuid,text,text,text,text,text)'::regprocedure, 'execute')
    and has_function_privilege('service_role', 'public.falhar_quadrinho_asset(uuid,uuid,text)'::regprocedure, 'execute') as worker_service_role_executa,
  (select bool_and(has_function_privilege('authenticated', p.oid, 'execute') and not has_function_privilege('anon', p.oid, 'execute') and p.prosecdef and p.proconfig @> array['search_path=""'])
     from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public' and p.proname in (
      'criar_jobs_quadrinho_admin', 'aprovar_quadrinho_asset_admin', 'rejeitar_quadrinho_asset_admin', 'regenerar_quadrinho_asset_admin',
      'preparar_exclusao_quadrinho_asset_admin', 'excluir_quadrinho_asset_admin')) as admin_rpcs_authenticated_definer,
  (select bool_and(p.prosecdef and p.proconfig @> array['search_path=""'])
     from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public' and p.proname in (
      'reservar_quadrinho_asset', 'concluir_quadrinho_asset', 'falhar_quadrinho_asset')) as worker_rpcs_definer_search_path_vazio,
  public.quadrinho_asset_lease() = interval '10 minutes' as lease_10_minutos,
  -- nenhuma mudança fora do pacote
  (select count(*) from cron.job) = 1 as cron_inalterado,
  (select count(*) from vault.secrets) = 2 as vault_inalterado,
  -- estado de dados esperado logo após o apply
  (select count(*) from public.aula_quadrinho_assets) as linhas_na_tabela,
  (select count(*) from storage.objects where bucket_id = 'quadrinhos-aulas') as objetos_no_bucket;
