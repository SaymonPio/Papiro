-- Q12.3-SEC — hardening de public.eh_admin(): a sessão do JWT precisa AINDA existir.
--
-- PREPARADO, NÃO APLICADO. Um access_token só morre no `exp` (~1 h) mesmo depois do
-- logout/revogação; com este patch, apagar a linha em auth.sessions invalida também os
-- access_tokens já emitidos para uma conta admin (a validação é ADICIONAL à regra atual).
--
-- eh_admin() passa a exigir, simultaneamente:
--   a) auth.uid() não nulo;
--   b) a regra administrativa de hoje (public.administradores.usuario_id = auth.uid());
--   c) o JWT tem claim `session_id`;
--   d) existe auth.sessions com id = session_id, user_id = auth.uid() e não expirada (not_after).
--
-- Mantidos IDÊNTICOS: assinatura, retorno boolean, LANGUAGE sql, STABLE, SECURITY DEFINER,
-- search_path vazio e GRANTs (CREATE OR REPLACE preserva a ACL: anon/authenticated/service_role/postgres).
-- Comparação por texto (s.id::text = claim) — um session_id malformado NUNCA levanta erro de cast.
-- Ordem de curto-circuito: quem não é admin nem chega a consultar auth.sessions.
--
-- Efeitos conhecidos (ver relatório): service_role/cron/postgres (sem auth.uid()) já eram
-- `false` e continuam; harnesses SQL que só definem request.jwt.claim.sub deixam de valer como
-- admin (precisam de request.jwt.claims com session_id + linha em auth.sessions dentro da
-- transação de teste). Reverter: supabase/reverter_hardening_eh_admin_sessao.sql.

begin;

-- >>> SECAO_PRECOND
do $$
declare
  v_src text;
  v_n int;
begin
  select regexp_replace(p.prosrc, '\s+', ' ', 'g') into v_src
  from pg_proc p where p.oid = 'public.eh_admin()'::regprocedure;
  if v_src is distinct from ' select exists ( select 1 from public.administradores where usuario_id = auth.uid() ); ' then
    raise exception 'PRECOND: public.eh_admin() nao esta na definicao legada esperada (ja aplicado ou alterado); nada foi feito';
  end if;
  select count(*) into v_n from pg_proc where proname = 'eh_admin' and pronamespace = 'public'::regnamespace;
  if v_n <> 1 then raise exception 'PRECOND: esperada exatamente 1 funcao public.eh_admin (encontradas %)', v_n; end if;
  if not has_table_privilege('postgres', 'auth.sessions', 'SELECT') then
    raise exception 'PRECOND: o dono da funcao (postgres) nao le auth.sessions';
  end if;
  raise notice 'PRECOND OK: eh_admin legado, 1 sobrecarga, auth.sessions legivel';
end $$;
-- <<< SECAO_PRECOND

-- >>> SECAO_CORPO (identica no harness)
create or replace function public.eh_admin()
returns boolean
language sql
stable
security definer
set search_path to ''
as $$
  select
    auth.uid() is not null
    and exists (
      select 1
      from public.administradores a
      where a.usuario_id = auth.uid()
    )
    and nullif(auth.jwt() ->> 'session_id', '') is not null
    and exists (
      select 1
      from auth.sessions s
      where s.id::text = (auth.jwt() ->> 'session_id')
        and s.user_id = auth.uid()
        and (s.not_after is null or s.not_after > now())
    );
$$;
-- <<< SECAO_CORPO

commit;
