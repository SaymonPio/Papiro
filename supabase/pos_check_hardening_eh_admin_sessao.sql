-- Pré/pós-check READ-ONLY do hardening de eh_admin(). Só leitura de catálogo; seguro de
-- rodar quantas vezes quiser. Uma linha; cada coluna *_ok deve ser true.
-- ANTES do apply: legado_ainda = true e hardened = false. DEPOIS: o inverso.
select
  (select count(*) from pg_proc where proname = 'eh_admin' and pronamespace = 'public'::regnamespace) = 1 as uma_funcao_ok,
  (select p.prosecdef and p.provolatile = 's' and p.prolang = (select oid from pg_language where lanname = 'sql')
     and p.proconfig = array['search_path=""'] and p.prorettype = 'boolean'::regtype and p.pronargs = 0
   from pg_proc p where p.oid = 'public.eh_admin()'::regprocedure) as propriedades_inalteradas_ok,
  (select p.proacl::text = '{postgres=X/postgres,anon=X/postgres,authenticated=X/postgres,service_role=X/postgres}'
   from pg_proc p where p.oid = 'public.eh_admin()'::regprocedure) as grants_inalterados_ok,
  (select md5(pg_get_functiondef('public.eh_admin()'::regprocedure)) = '13a7f536a885cf02c754249b0a1060ce') as legado_ainda,
  (select prosrc ~ 'auth\.jwt\(\) ->> ''session_id''' and prosrc ~ 'auth\.sessions' and prosrc ~ 's\.user_id = auth\.uid\(\)'
          and prosrc ~ 'public\.administradores' and prosrc ~ 'not_after'
   from pg_proc where oid = 'public.eh_admin()'::regprocedure) as hardened,
  -- dependentes intactos: 29 funcoes (incl. a propria) e 25 policies referenciam eh_admin
  (select count(*) from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where p.prokind = 'f' and n.nspname not in ('pg_catalog', 'information_schema') and pg_get_functiondef(p.oid) ~* 'eh_admin\s*\(') = 29 as dependentes_funcoes_29_ok,
  (select count(*) from pg_policies where coalesce(qual, '') || coalesce(with_check, '') ~* 'eh_admin') = 25 as dependentes_policies_25_ok,
  (select count(*) from cron.job where command ~* 'eh_admin') = 0 as cron_nao_usa_ok,
  (select count(*) from public.administradores) as admins,
  (select count(*) from auth.sessions s join public.administradores a on a.usuario_id = s.user_id
    where s.not_after is null or s.not_after > now()) as sessoes_ativas_de_admins;
