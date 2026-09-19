-- Pós-check READ-ONLY para rodar DEPOIS de um apply real (futuro) de
-- supabase/teoria_geracoes_admin_tem_response_id.sql. Só SELECTs/leituras
-- de catálogo, nenhuma escrita.

select
  exists (
    select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'listar_geracoes_conteudo_admin'
      and pg_get_function_identity_arguments(p.oid) = 'p_conteudo_id bigint'
  ) as funcao_existe_com_assinatura_esperada,
  coalesce((
    select p.prosecdef from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'listar_geracoes_conteudo_admin'
      and pg_get_function_identity_arguments(p.oid) = 'p_conteudo_id bigint'
  ), false) as security_definer,
  has_function_privilege('authenticated', 'public.listar_geracoes_conteudo_admin(bigint)', 'EXECUTE') as authenticated_pode_executar,
  has_function_privilege('anon', 'public.listar_geracoes_conteudo_admin(bigint)', 'EXECUTE') as anon_pode_executar,
  has_function_privilege('public', 'public.listar_geracoes_conteudo_admin(bigint)', 'EXECUTE') as public_pode_executar,
  (
    select array_agg(x.nome order by x.ord)
    from (
      select p.proargnames[s] as nome, s as ord
      from pg_proc p
      join pg_namespace n on n.oid = p.pronamespace
      cross join lateral generate_subscripts(p.proargmodes, 1) as s
      where n.nspname = 'public' and p.proname = 'listar_geracoes_conteudo_admin'
        and p.proargmodes[s] = 't'
    ) x
  ) as colunas_retornadas_em_ordem;
