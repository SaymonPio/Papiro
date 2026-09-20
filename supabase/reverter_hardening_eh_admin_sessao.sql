-- Reverte supabase/hardening_eh_admin_sessao.sql: restaura EXATAMENTE a definição legada
-- de public.eh_admin() (md5 de pg_get_functiondef = 13a7f536a885cf02c754249b0a1060ce,
-- medida no LIVE antes do hardening). ACL e propriedades não mudam (CREATE OR REPLACE).
begin;

create or replace function public.eh_admin()
returns boolean
language sql
stable
security definer
set search_path to ''
as $$
  select exists (
    select 1
    from public.administradores
    where usuario_id = auth.uid()
  );
$$;

do $$
begin
  if md5(pg_get_functiondef('public.eh_admin()'::regprocedure)) <> '13a7f536a885cf02c754249b0a1060ce' then
    raise exception 'REVERT: definicao restaurada difere da legada medida no LIVE';
  end if;
  raise notice 'REVERT OK: eh_admin identica a legada';
end $$;

commit;
