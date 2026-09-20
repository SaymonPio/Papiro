-- Harness do hardening de eh_admin(): aplica o corpo NOVO dentro de uma transação, cria
-- sessões FICTÍCIAS em auth.sessions (para o admin real e outro usuário existente),
-- exercita sessão ativa / revogada / expirada / ausente / de outro usuário / malformada e
-- termina com ROLLBACK. NÃO usa nenhum access_token real: os claims são montados com
-- set_config('request.jwt.claims', ...) na própria transação.
-- Pré-requisito: existe ao menos 1 linha em public.administradores. NÃO foi executado.
-- Resultado: uma tabela caso/ok (todas as linhas devem ter ok = true) antes do rollback.
begin;

-- >>> SECAO_CORPO (identica ao apply)
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

create temp table t_res (ordem serial, caso text, ok boolean) on commit drop;
create function pg_temp.ctx(p_sub text, p_sid text, p_legado_only boolean default false) returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claim.sub', case when p_legado_only then coalesce(p_sub, '') else '' end, true);
  if p_legado_only then
    perform set_config('request.jwt.claims', '', true);
  else
    perform set_config('request.jwt.claims',
      jsonb_strip_nulls(jsonb_build_object('sub', p_sub, 'role', 'authenticated', 'session_id', p_sid))::text, true);
  end if;
end $$;

do $$
declare
  v_admin uuid;
  v_outro uuid;
  v_s_ok uuid := gen_random_uuid();
  v_s_rev uuid := gen_random_uuid();
  v_s_exp uuid := gen_random_uuid();
  v_s_outro uuid := gen_random_uuid();
  v_r boolean;
  v_erro text;
begin
  select usuario_id into v_admin from public.administradores order by criado_em limit 1;
  if v_admin is null then raise exception 'HARNESS: sem administrador para testar'; end if;
  select u.id into v_outro from auth.users u where u.id <> v_admin and not exists (select 1 from public.administradores a where a.usuario_id = u.id) limit 1;

  insert into auth.sessions (id, user_id, created_at, updated_at) values (v_s_ok, v_admin, now(), now());
  insert into auth.sessions (id, user_id, created_at, updated_at, not_after) values (v_s_exp, v_admin, now(), now(), now() - interval '1 minute');
  -- v_s_rev NUNCA é inserida: representa sessão revogada (linha apagada) com JWT ainda no prazo

  -- 1) admin + sessão ativa => true
  perform pg_temp.ctx(v_admin::text, v_s_ok::text);
  insert into t_res(caso, ok) values ('1 admin com sessao ativa => true', public.eh_admin() is true);

  -- 2) admin + sessão revogada (linha inexistente) => false
  perform pg_temp.ctx(v_admin::text, v_s_rev::text);
  insert into t_res(caso, ok) values ('2 admin com sessao revogada => false', public.eh_admin() is false);

  -- 3) admin + sessão expirada por not_after => false
  perform pg_temp.ctx(v_admin::text, v_s_exp::text);
  insert into t_res(caso, ok) values ('3 admin com sessao expirada (not_after) => false', public.eh_admin() is false);

  -- 4) admin sem claim session_id => false
  perform pg_temp.ctx(v_admin::text, null);
  insert into t_res(caso, ok) values ('4 admin sem session_id => false', public.eh_admin() is false);

  -- 5) session_id malformado => false, sem erro de cast
  perform pg_temp.ctx(v_admin::text, 'nao-e-uuid');
  begin
    v_r := public.eh_admin();
    insert into t_res(caso, ok) values ('5 session_id malformado => false sem excecao', v_r is false);
  exception when others then
    insert into t_res(caso, ok) values ('5 session_id malformado => false sem excecao', false);
  end;

  -- 6) só o GUC legado request.jwt.claim.sub (sem claims JSON) => false
  perform pg_temp.ctx(v_admin::text, null, true);
  insert into t_res(caso, ok) values ('6 so request.jwt.claim.sub (legado, sem session_id) => false', public.eh_admin() is false);

  -- 7) sem sub (service_role/postgres/anon) => false
  perform pg_temp.ctx(null, v_s_ok::text);
  insert into t_res(caso, ok) values ('7 sem sub => false', public.eh_admin() is false);
  perform set_config('request.jwt.claims', '', true);
  insert into t_res(caso, ok) values ('7b sem claims nenhum => false', public.eh_admin() is false);

  -- 8) usuário não-admin com sessão própria válida => false (regra administrativa preservada)
  if v_outro is not null then
    insert into auth.sessions (id, user_id, created_at, updated_at) values (v_s_outro, v_outro, now(), now());
    perform pg_temp.ctx(v_outro::text, v_s_outro::text);
    insert into t_res(caso, ok) values ('8 nao-admin com sessao propria valida => false', public.eh_admin() is false);
    -- 9) admin (sub) usando session_id de OUTRO usuário => false (vínculo sessão↔usuário)
    perform pg_temp.ctx(v_admin::text, v_s_outro::text);
    insert into t_res(caso, ok) values ('9 admin com session_id de outro usuario => false', public.eh_admin() is false);
  else
    insert into t_res(caso, ok) values ('8/9 sem segundo usuario no projeto: casos de outro usuario nao exercitados', true);
  end if;

  -- 10) dependentes: RPC admin de leitura aceita sessão ativa e recusa a revogada
  perform pg_temp.ctx(v_admin::text, v_s_ok::text);
  begin
    perform 1 from public.carregar_quadrinho_assets_admin('00000000-0000-0000-0000-000000000000'::uuid);
    insert into t_res(caso, ok) values ('10a carregar_quadrinho_assets_admin com sessao ativa => executa', true);
  exception when others then
    insert into t_res(caso, ok) values ('10a carregar_quadrinho_assets_admin com sessao ativa => executa', false);
  end;
  perform pg_temp.ctx(v_admin::text, v_s_rev::text);
  begin
    perform 1 from public.carregar_quadrinho_assets_admin('00000000-0000-0000-0000-000000000000'::uuid);
    insert into t_res(caso, ok) values ('10b carregar_quadrinho_assets_admin com sessao revogada => recusa', false);
  exception when others then
    get stacked diagnostics v_erro = message_text;
    insert into t_res(caso, ok) values ('10b carregar_quadrinho_assets_admin com sessao revogada => recusa', v_erro like 'Apenas administradores%');
  end;

  -- 11) propriedades e ACL preservadas
  insert into t_res(caso, ok)
  select '11 assinatura/propriedades/ACL inalteradas',
    p.prosecdef and p.provolatile = 's' and p.proconfig = array['search_path=""'] and p.prorettype = 'boolean'::regtype and p.pronargs = 0
    and p.proacl::text = '{postgres=X/postgres,anon=X/postgres,authenticated=X/postgres,service_role=X/postgres}'
  from pg_proc p where p.oid = 'public.eh_admin()'::regprocedure;
end $$;

select ordem, caso, ok from t_res order by ordem;
select bool_and(ok) as todos_ok, count(*) as casos from t_res;

rollback;
