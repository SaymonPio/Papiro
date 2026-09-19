-- Pós-check READ-ONLY para rodar DEPOIS de um apply real (futuro) de
-- supabase/camada_ilustrada_gc.sql. Só SELECTs/leituras de catálogo (e chamadas às
-- funções puras/de leitura do GC), nenhuma escrita, seguro de rodar quantas vezes
-- quiser. Um único resultado: cada coluna booleana deve ser true (contadores no fim).
select
  -- 7 funções do GC: exatamente uma de cada
  (select count(*) from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public' and p.proname in (
      'quadrinho_storage_path_claim', 'quadrinho_path_canonico', 'quadrinho_orphan_grace', 'quadrinho_storage_path_protegido',
      'quadrinho_upload_orfao_motivo', 'listar_quadrinho_uploads_orfaos', 'confirmar_quadrinho_upload_orfao')) = 7 as sete_funcoes_gc_sem_duplicata,
  -- sem colunas novas, sem CHECK novo
  (select string_agg(column_name || ':' || data_type || ':' || is_nullable, ',' order by ordinal_position)
     from information_schema.columns where table_schema = 'public' and table_name = 'aula_quadrinho_assets')
    = 'id:uuid:NO,aula_versao_id:uuid:NO,componente_id:uuid:NO,quadro_indice:smallint:NO,scene_hash:text:NO,status:text:NO,storage_path:text:YES,modelo:text:YES,prompt_version:text:YES,prompt_visual:text:YES,tentativas:smallint:NO,lease_ate:timestamp with time zone:YES,erro_sanitizado:text:YES,aprovado_por:uuid:YES,aprovado_em:timestamp with time zone:YES,criado_em:timestamp with time zone:NO,atualizado_em:timestamp with time zone:NO,claim_token:uuid:YES,storage_path_anterior:text:YES'
    as colunas_inalteradas_19,
  (select count(*) from pg_constraint where conrelid = 'public.aula_quadrinho_assets'::regclass and contype = 'c') = 9 as nove_checks_inalterados,
  -- Q9 e as 14 de Q10 não substituídas: definição idêntica à validada
  (select jsonb_object_agg(p.proname, md5(pg_get_functiondef(p.oid))) from pg_proc p join pg_namespace n on n.oid = p.pronamespace
     where n.nspname = 'public' and p.proname in ('hash_cena_quadrinho', 'hash_cena_atual_quadrinho', 'carregar_quadrinho_assets_aula', 'carregar_quadrinho_assets_admin',
       'quadrinho_asset_lease', 'quadrinho_componente', 'cena_atual_quadrinho', 'quadrinho_path_no_storage', 'quadrinho_asset_reiniciar', 'falhar_quadrinho_asset',
       'criar_jobs_quadrinho_admin', 'aprovar_quadrinho_asset_admin', 'rejeitar_quadrinho_asset_admin', 'regenerar_quadrinho_asset_admin',
       'preparar_exclusao_quadrinho_asset_admin', 'excluir_quadrinho_asset_admin'))
    = '{"hash_cena_quadrinho": "2779b0d927b88a6946b31636dff13804", "hash_cena_atual_quadrinho": "0fd391aacd21da2eb83ad06ec38db44b", "carregar_quadrinho_assets_aula": "ee2c134d44bdbb00e45f0973eb20e33b", "carregar_quadrinho_assets_admin": "4d6a052a6b05e49d585fe2c9360d3b84", "quadrinho_asset_lease": "a76262802dbb1697663c383565e8140c", "quadrinho_componente": "800ed4a3d4b69ae956dd3f6f0226e156", "cena_atual_quadrinho": "d42813c97e079b7cc96bab6dd3fa513a", "quadrinho_path_no_storage": "8c90f2e67adb8f3da8426c6aafcb05e9", "quadrinho_asset_reiniciar": "0ac31e5664bb8d26f16002c2440aa332", "falhar_quadrinho_asset": "ea019a77c4663648de04437fe8c929fa", "criar_jobs_quadrinho_admin": "6c834af49817ebf263fa07441ba139ef", "aprovar_quadrinho_asset_admin": "9855caa6a1485dd2bd323c291feb8ea0", "rejeitar_quadrinho_asset_admin": "99fc111dfd4d18e395d21ad987a8c307", "regenerar_quadrinho_asset_admin": "237ec790d15cdfcf29310858cb953ad1", "preparar_exclusao_quadrinho_asset_admin": "ab629c0ac18cdaecba7a32cacda68a9a", "excluir_quadrinho_asset_admin": "3bad48fafb9b3a625a43732ee614f118"}'::jsonb
    as q9_e_q10_nao_substituidas_inalteradas,
  -- reservar/concluir centralizadas (o único texto alterado do Q10)
  position('public.quadrinho_storage_path_claim' in pg_get_functiondef('public.reservar_quadrinho_asset(uuid)'::regprocedure)) > 0
    and position('.webp' in pg_get_functiondef('public.reservar_quadrinho_asset(uuid)'::regprocedure)) = 0 as reservar_usa_o_helper_de_path,
  position('public.quadrinho_storage_path_claim' in pg_get_functiondef('public.concluir_quadrinho_asset(uuid,uuid,text,text,text,text,text)'::regprocedure)) > 0
    and position('.webp' in pg_get_functiondef('public.concluir_quadrinho_asset(uuid,uuid,text,text,text,text,text)'::regprocedure)) = 0 as concluir_usa_o_helper_de_path,
  -- fórmula, formato canônico e grace
  public.quadrinho_storage_path_claim('aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee', 'ffffffff-0000-1111-2222-333333333333', 3::smallint, repeat('ab', 32), '11111111-2222-3333-4444-555555555555')
    = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee/ffffffff-0000-1111-2222-333333333333/3/ababababab-11111111-2222-3333-4444-555555555555.webp' as formula_do_path,
  public.quadrinho_path_canonico('aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee/ffffffff-0000-1111-2222-333333333333/3/ababababab-11111111-2222-3333-4444-555555555555.webp')
    and not public.quadrinho_path_canonico('_testes/q11-1/x.webp') and not public.quadrinho_path_canonico(null) as formato_canonico,
  public.quadrinho_orphan_grace() = interval '30 minutes' as grace_30_minutos,
  -- grants: tudo interno; só listar/confirmar para service_role; classificador nem service_role
  not (has_function_privilege('anon', 'public.quadrinho_orphan_grace()'::regprocedure, 'execute') or has_function_privilege('authenticated', 'public.quadrinho_orphan_grace()'::regprocedure, 'execute')
    or has_function_privilege('anon', 'public.quadrinho_storage_path_claim(uuid,uuid,smallint,text,uuid)'::regprocedure, 'execute') or has_function_privilege('authenticated', 'public.quadrinho_storage_path_claim(uuid,uuid,smallint,text,uuid)'::regprocedure, 'execute')
    or has_function_privilege('anon', 'public.quadrinho_path_canonico(text)'::regprocedure, 'execute') or has_function_privilege('authenticated', 'public.quadrinho_path_canonico(text)'::regprocedure, 'execute')
    or has_function_privilege('anon', 'public.quadrinho_storage_path_protegido(text)'::regprocedure, 'execute') or has_function_privilege('authenticated', 'public.quadrinho_storage_path_protegido(text)'::regprocedure, 'execute')
    or has_function_privilege('anon', 'public.quadrinho_upload_orfao_motivo(text,timestamptz,timestamptz)'::regprocedure, 'execute') or has_function_privilege('authenticated', 'public.quadrinho_upload_orfao_motivo(text,timestamptz,timestamptz)'::regprocedure, 'execute')
    or has_function_privilege('anon', 'public.listar_quadrinho_uploads_orfaos(integer)'::regprocedure, 'execute') or has_function_privilege('authenticated', 'public.listar_quadrinho_uploads_orfaos(integer)'::regprocedure, 'execute')
    or has_function_privilege('anon', 'public.confirmar_quadrinho_upload_orfao(text)'::regprocedure, 'execute') or has_function_privilege('authenticated', 'public.confirmar_quadrinho_upload_orfao(text)'::regprocedure, 'execute')) as gc_fechado_para_clientes,
  has_function_privilege('service_role', 'public.listar_quadrinho_uploads_orfaos(integer)'::regprocedure, 'execute')
    and has_function_privilege('service_role', 'public.confirmar_quadrinho_upload_orfao(text)'::regprocedure, 'execute') as service_role_executa_listar_e_confirmar,
  not has_function_privilege('service_role', 'public.quadrinho_upload_orfao_motivo(text,timestamptz,timestamptz)'::regprocedure, 'execute') as classificador_com_timestamp_nem_service_role,
  (select bool_and(p.prosecdef and p.proconfig @> array['search_path=""']) from pg_proc p join pg_namespace n on n.oid = p.pronamespace
     where n.nspname = 'public' and p.proname in ('listar_quadrinho_uploads_orfaos', 'confirmar_quadrinho_upload_orfao', 'reservar_quadrinho_asset', 'concluir_quadrinho_asset')) as rpcs_definer_search_path_vazio,
  (select bool_and(p.proconfig @> array['search_path=""']) from pg_proc p join pg_namespace n on n.oid = p.pronamespace
     where n.nspname = 'public' and p.proname in ('quadrinho_storage_path_claim', 'quadrinho_path_canonico', 'quadrinho_orphan_grace', 'quadrinho_storage_path_protegido', 'quadrinho_upload_orfao_motivo')) as helpers_search_path_vazio,
  not (has_function_privilege('anon', 'public.reservar_quadrinho_asset(uuid)'::regprocedure, 'execute') or has_function_privilege('authenticated', 'public.reservar_quadrinho_asset(uuid)'::regprocedure, 'execute')
    or has_function_privilege('anon', 'public.concluir_quadrinho_asset(uuid,uuid,text,text,text,text,text)'::regprocedure, 'execute') or has_function_privilege('authenticated', 'public.concluir_quadrinho_asset(uuid,uuid,text,text,text,text,text)'::regprocedure, 'execute'))
    and has_function_privilege('service_role', 'public.reservar_quadrinho_asset(uuid)'::regprocedure, 'execute')
    and has_function_privilege('service_role', 'public.concluir_quadrinho_asset(uuid,uuid,text,text,text,text,text)'::regprocedure, 'execute') as grants_do_worker_preservados,
  -- nada fora do pacote
  (select relrowsecurity from pg_class where oid = 'public.aula_quadrinho_assets'::regclass) as rls_da_tabela_intacto,
  not exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'aula_quadrinho_assets') as tabela_sem_policy,
  exists (select 1 from storage.buckets where id = 'quadrinhos-aulas' and public = false and file_size_limit = 262144 and allowed_mime_types = array['image/webp']) as bucket_intacto,
  not exists (select 1 from pg_policies where schemaname = 'storage' and tablename = 'objects' and (coalesce(qual, '') || ' ' || coalesce(with_check, '')) like '%quadrinhos-aulas%') as sem_policy_de_storage_para_o_bucket,
  (select count(*) from pg_policies where schemaname = 'storage' and tablename = 'objects') = 6 as policies_de_storage_inalteradas,
  (select count(*) from cron.job) = 1 as cron_inalterado,
  (select count(*) from vault.secrets) = 2 as vault_inalterado,
  -- estado de dados (informativo)
  (select count(*) from public.aula_quadrinho_assets) as linhas_na_tabela,
  (select count(*) from storage.objects where bucket_id = 'quadrinhos-aulas') as objetos_no_bucket,
  (select count(*) from public.listar_quadrinho_uploads_orfaos(100)) as candidatos_a_orfao_agora;
