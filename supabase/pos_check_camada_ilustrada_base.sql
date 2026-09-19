-- Pós-check READ-ONLY para rodar DEPOIS de um apply real (futuro) de
-- supabase/camada_ilustrada_base.sql. Só SELECTs/leituras de catálogo, nenhuma
-- escrita, seguro de rodar quantas vezes quiser. Um único resultado:
-- cada coluna booleana deve ser true e `tudo_ok` deve ser true.
select
  -- tabela e colunas
  to_regclass('public.aula_quadrinho_assets') is not null as tabela_existe,
  (select string_agg(column_name || ':' || data_type || ':' || is_nullable, ',' order by ordinal_position)
     from information_schema.columns where table_schema = 'public' and table_name = 'aula_quadrinho_assets')
    = 'id:uuid:NO,aula_versao_id:uuid:NO,componente_id:uuid:NO,quadro_indice:smallint:NO,scene_hash:text:NO,status:text:NO,storage_path:text:YES,modelo:text:YES,prompt_version:text:YES,prompt_visual:text:YES,tentativas:smallint:NO,lease_ate:timestamp with time zone:YES,erro_sanitizado:text:YES,aprovado_por:uuid:YES,aprovado_em:timestamp with time zone:YES,criado_em:timestamp with time zone:NO,atualizado_em:timestamp with time zone:NO'
    as colunas_corretas,
  -- constraints e índices
  (select count(*) from pg_constraint where conrelid = 'public.aula_quadrinho_assets'::regclass and contype = 'p') = 1 as pk_unica,
  exists (select 1 from pg_constraint where conrelid = 'public.aula_quadrinho_assets'::regclass and contype = 'f'
            and confrelid = 'public.aula_versoes'::regclass and confdeltype = 'c') as fk_aula_versoes_cascade,
  (select count(*) from pg_constraint where conrelid = 'public.aula_quadrinho_assets'::regclass and contype = 'f') = 1 as apenas_uma_fk,
  exists (select 1 from pg_constraint c where c.conrelid = 'public.aula_quadrinho_assets'::regclass and c.contype = 'u'
            and c.conname = 'aula_quadrinho_assets_chave_key'
            and (select array_agg(a.attname::text order by k.ord) from unnest(c.conkey) with ordinality k(attnum, ord)
                   join pg_attribute a on a.attrelid = c.conrelid and a.attnum = k.attnum)
                = array['aula_versao_id', 'componente_id', 'quadro_indice']) as unique_chave,
  (select count(*) from pg_constraint where conrelid = 'public.aula_quadrinho_assets'::regclass and contype = 'c') = 7 as sete_checks,
  (select count(*) from pg_constraint where conrelid = 'public.aula_quadrinho_assets'::regclass and conname in (
     'aula_quadrinho_assets_quadro_indice_check', 'aula_quadrinho_assets_scene_hash_check', 'aula_quadrinho_assets_status_check',
     'aula_quadrinho_assets_tentativas_check', 'aula_quadrinho_assets_storage_path_check',
     'aula_quadrinho_assets_gerada_exige_path_check', 'aula_quadrinho_assets_aprovada_exige_data_check')) = 7 as checks_nomeados,
  exists (select 1 from pg_indexes where schemaname = 'public' and tablename = 'aula_quadrinho_assets'
            and indexname = 'aula_quadrinho_assets_storage_path_key' and indexdef ilike '%UNIQUE%(storage_path)%WHERE%storage_path IS NOT NULL%') as indice_unico_storage_path,
  -- RLS e grants da tabela
  (select relrowsecurity from pg_class where oid = 'public.aula_quadrinho_assets'::regclass) as rls_habilitado,
  not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'aula_quadrinho_assets') as tabela_sem_policy,
  not (has_table_privilege('anon', 'public.aula_quadrinho_assets', 'select')
    or has_table_privilege('anon', 'public.aula_quadrinho_assets', 'insert')
    or has_table_privilege('anon', 'public.aula_quadrinho_assets', 'update')
    or has_table_privilege('anon', 'public.aula_quadrinho_assets', 'delete')) as anon_sem_acesso_direto,
  not (has_table_privilege('authenticated', 'public.aula_quadrinho_assets', 'select')
    or has_table_privilege('authenticated', 'public.aula_quadrinho_assets', 'insert')
    or has_table_privilege('authenticated', 'public.aula_quadrinho_assets', 'update')
    or has_table_privilege('authenticated', 'public.aula_quadrinho_assets', 'delete')) as authenticated_sem_acesso_direto,
  -- funções: exatamente uma de cada, grants, SECURITY DEFINER, search_path
  (select count(*) from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public'
     and p.proname in ('hash_cena_quadrinho', 'hash_cena_atual_quadrinho', 'carregar_quadrinho_assets_aula', 'carregar_quadrinho_assets_admin')) = 4 as quatro_funcoes_sem_duplicata,
  not (has_function_privilege('anon', 'public.hash_cena_quadrinho(text)'::regprocedure, 'execute')
    or has_function_privilege('authenticated', 'public.hash_cena_quadrinho(text)'::regprocedure, 'execute')
    or has_function_privilege('anon', 'public.hash_cena_atual_quadrinho(uuid,uuid,smallint)'::regprocedure, 'execute')
    or has_function_privilege('authenticated', 'public.hash_cena_atual_quadrinho(uuid,uuid,smallint)'::regprocedure, 'execute')) as helpers_fechados_para_clientes,
  (select p.prosecdef and p.proconfig @> array['search_path=""'] from pg_proc p where p.oid = 'public.carregar_quadrinho_assets_aula(uuid,uuid)'::regprocedure) as rpc_aluno_definer_search_path_vazio,
  (select p.prosecdef and p.proconfig @> array['search_path=""'] from pg_proc p where p.oid = 'public.carregar_quadrinho_assets_admin(uuid)'::regprocedure) as rpc_admin_definer_search_path_vazio,
  has_function_privilege('authenticated', 'public.carregar_quadrinho_assets_aula(uuid,uuid)'::regprocedure, 'execute')
    and not has_function_privilege('anon', 'public.carregar_quadrinho_assets_aula(uuid,uuid)'::regprocedure, 'execute') as rpc_aluno_grants,
  has_function_privilege('authenticated', 'public.carregar_quadrinho_assets_admin(uuid)'::regprocedure, 'execute')
    and not has_function_privilege('anon', 'public.carregar_quadrinho_assets_admin(uuid)'::regprocedure, 'execute') as rpc_admin_grants,
  (select p.provolatile = 'i' from pg_proc p where p.oid = 'public.hash_cena_quadrinho(text)'::regprocedure) as hash_immutable,
  public.hash_cena_quadrinho('abc') = 'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad'
    and public.hash_cena_quadrinho('Jos' || chr(233)) = public.hash_cena_quadrinho('Jose' || chr(769)) as hash_vetores_ok,
  -- bucket e storage
  (select count(*) from storage.buckets where id = 'quadrinhos-aulas') = 1 as bucket_unico,
  exists (select 1 from storage.buckets where id = 'quadrinhos-aulas' and name = 'quadrinhos-aulas' and public = false) as bucket_privado,
  exists (select 1 from storage.buckets where id = 'quadrinhos-aulas' and file_size_limit = 262144) as bucket_limite_256kib,
  exists (select 1 from storage.buckets where id = 'quadrinhos-aulas' and allowed_mime_types = array['image/webp']) as bucket_somente_webp,
  not exists (select 1 from pg_policies where schemaname = 'storage' and tablename = 'objects'
                and (coalesce(qual, '') || ' ' || coalesce(with_check, '')) like '%quadrinhos-aulas%') as sem_policy_de_storage_para_o_bucket,
  -- seguranças gerais (o pacote não deve ter alterado o resto)
  (select count(*) from pg_policies where schemaname = 'storage' and tablename = 'objects') = 6 as policies_de_storage_inalteradas,
  -- estado de dados esperado logo após o apply: nenhuma linha, nenhum objeto
  (select count(*) from public.aula_quadrinho_assets) as linhas_na_tabela,
  (select count(*) from storage.objects where bucket_id = 'quadrinhos-aulas') as objetos_no_bucket;
