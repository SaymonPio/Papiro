-- ============================================================================
-- TESTE RUNTIME do pacote supabase/camada_ilustrada_base.sql —
-- TRANSACIONAL, TUDO DESFEITO NO FINAL (BEGIN ... ROLLBACK). NÃO EXECUTADO na Q9.
-- ============================================================================
--
-- Rodar de uma vez (env -u SUPABASE_ACCESS_TOKEN npx --no-install supabase db
-- query --linked -f supabase/camada_ilustrada_base_teste_rollback.sql), ler o
-- resultado e NUNCA persistir nada. Não há COMMIT neste arquivo.
--
-- Transacionalidade: CREATE TABLE/INDEX/FUNCTION, ALTER TABLE, REVOKE/GRANT, o
-- INSERT/DELETE em storage.buckets e set_config(..., true) são todos
-- transacionais no PostgreSQL; o ROLLBACK final desfaz o pacote inteiro
-- (nenhum objeto de Storage é enviado — nenhuma operação não transacional).
--
-- As seções PRECOND / CORPO / POSCOND abaixo são IDÊNTICAS às do arquivo de apply
-- e as seções REVERT_* são IDÊNTICAS às de reverter_camada_ilustrada_base.sql
-- (tests/camada-ilustrada-base.test.mjs compara byte a byte). Ordem:
--   V) escopo (só o pacote foi criado; aulas/RPCs existentes intactas);
--   M) hash (vetor SHA-256, trim, NFC, NULL/vazio);
--   C..I) constraints, com violações provocadas em sub-blocos;
--   helper da cena atual sobre o quadrinho piloto real (4 quadros);
--   N/O) RPC admin (todos os status, asset_atual, bloqueio de não-admin);
--   L/M) RPC do aluno (missão do usuário, matrícula ativa, versão publicada
--        acessível, aprovada + hash atual, cena alterada/reordenada, recusas);
--   papéis reais (SET LOCAL ROLE anon/authenticated) e ausência de policy;
--   REVERTER: o down-migration (guarda + remoção + pós-condição) roda ao final
--   e prova que relações, funções e buckets voltam exatamente ao snapshot inicial;
--   OLD_FINAL: fixtures restauradas na própria transação e estado == snapshot OLD
--   (matrículas, missões, aulas, versões, RPCs, policies, grants), antes do ROLLBACK.
-- Fixtures do aluno (matrícula 'ativa', quadrinho injetado na versão publicada)
-- existem só nesta transação. Qualquer falha aborta com a lista de testes.

BEGIN;

create temporary table teste_q9 (
  ordem serial,
  chave text primary key,
  ok boolean
);

-- Snapshot ANTES de qualquer criação: usado pelo teste de escopo (V).
create temporary table _q9_snap_rel on commit drop as
select c.relname::text as nome from pg_class c join pg_namespace n on n.oid = c.relnamespace where n.nspname = 'public';
create temporary table _q9_snap_fn on commit drop as
select p.oid::text as nome from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public';
create temporary table _q9_snap_pol on commit drop as
select schemaname::text || '.' || tablename::text || '.' || policyname::text as nome from pg_policies;
create temporary table _q9_snap_bucket on commit drop as
select id::text as nome from storage.buckets;
create temporary table _q9_snap_estado on commit drop as
select
  (select md5(string_agg(id::text || estrutura::text || status || numero_versao::text, '|' order by id)) from public.aula_versoes) as h_versoes,
  (select md5(string_agg(id::text || titulo || ativa::text, '|' order by id)) from public.aulas) as h_aulas,
  (select count(*) from public.aula_geracoes) as n_geracoes,
  (select count(*) from public.matriculas) as n_matriculas,
  (select count(*) from public.missoes) as n_missoes,
  md5(pg_get_functiondef('public.carregar_aula_publicada_da_missao(uuid)'::regprocedure)) as h_rpc_aula,
  md5(pg_get_functiondef('public.carregar_aula_rascunho_admin(uuid)'::regprocedure)) as h_rpc_rascunho,
  md5(pg_get_functiondef('public.eh_admin()'::regprocedure)) as h_eh_admin;

-- Cópias das linhas das fixtures (matrícula e versões de aula) para o OLD_FINAL.
create temporary table _q9_old_matriculas on commit drop as select id, status from public.matriculas;
create temporary table _q9_old_versoes on commit drop as select id, estrutura from public.aula_versoes;
create temporary table _q9_snap_estado2 on commit drop as
select
  (select md5(string_agg(id::text || status, '|' order by id)) from public.matriculas) as h_matriculas,
  (select md5(string_agg(id::text || status || conteudo_id::text, '|' order by id)) from public.missoes) as h_missoes,
  (select md5(string_agg(table_name::text || grantee::text || privilege_type::text, '|' order by table_name::text, grantee::text, privilege_type::text))
     from information_schema.role_table_grants where table_schema = 'public') as h_grants_tabelas,
  (select md5(string_agg(routine_name::text || grantee::text || privilege_type::text, '|' order by routine_name::text, grantee::text, privilege_type::text))
     from information_schema.role_routine_grants where routine_schema = 'public') as h_grants_funcoes;

-- >>> SECAO_PRECOND (identica no harness)
do $$
declare
  v_problemas text := '';
  v_def text;
begin
  if to_regclass('public.aula_quadrinho_assets') is not null then
    v_problemas := v_problemas || 'tabela public.aula_quadrinho_assets ja existe; ';
  end if;
  if exists (select 1 from storage.buckets where id = 'quadrinhos-aulas' or name = 'quadrinhos-aulas') then
    v_problemas := v_problemas || 'bucket quadrinhos-aulas ja existe; ';
  end if;
  if exists (
    select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.proname in ('hash_cena_quadrinho', 'hash_cena_atual_quadrinho', 'carregar_quadrinho_assets_aula', 'carregar_quadrinho_assets_admin')
  ) then
    v_problemas := v_problemas || 'ja existe funcao com nome reservado; ';
  end if;
  if exists (
    select 1 from pg_policies
    where schemaname = 'storage' and tablename = 'objects'
      and (coalesce(qual, '') || ' ' || coalesce(with_check, '')) like '%quadrinhos-aulas%'
  ) then
    v_problemas := v_problemas || 'ja existe policy de storage citando quadrinhos-aulas; ';
  end if;
  if to_regclass('public.aula_versoes') is null then
    v_problemas := v_problemas || 'public.aula_versoes ausente; ';
  end if;
  if to_regprocedure('public.eh_admin()') is null then
    v_problemas := v_problemas || 'public.eh_admin() ausente; ';
  end if;
  if to_regprocedure('public.carregar_aula_publicada_da_missao(uuid)') is null then
    v_problemas := v_problemas || 'carregar_aula_publicada_da_missao(uuid) ausente; ';
  else
    v_def := pg_get_functiondef('public.carregar_aula_publicada_da_missao(uuid)'::regprocedure);
    if position('auth.uid()' in v_def) = 0
       or position('m.usuario_id=v_usuario_id' in v_def) = 0
       or position('m.status=''ativa''' in v_def) = 0
       or position('av.status=''publicada''' in v_def) = 0
       or position('u.curso_conteudo_id=v_conteudo_id' in v_def) = 0 then
      v_problemas := v_problemas || 'autorizacao de carregar_aula_publicada_da_missao mudou — revisar a RPC de assets antes de aplicar; ';
    end if;
  end if;
  if normalize(chr(97) || chr(769), NFC) is distinct from chr(225) then
    v_problemas := v_problemas || 'normalize(..., NFC) indisponivel/incorreto; ';
  end if;
  if v_problemas <> '' then
    raise exception 'PRECOND: %', v_problemas;
  end if;
  raise notice 'PRECOND OK: nada a criar existe; autorizacao da RPC de leitura da aula confere; NFC disponivel';
end $$;
-- <<< SECAO_PRECOND

-- >>> SECAO_CORPO (identica no harness)
-- ================= 1) TABELA =================
create table public.aula_quadrinho_assets (
  id uuid primary key default gen_random_uuid(),
  aula_versao_id uuid not null references public.aula_versoes(id) on delete cascade,
  componente_id uuid not null,
  quadro_indice smallint not null,
  scene_hash text not null,
  status text not null default 'pendente',
  storage_path text null,
  modelo text null,
  prompt_version text null,
  prompt_visual text null,
  tentativas smallint not null default 0,
  lease_ate timestamptz null,
  erro_sanitizado text null,
  aprovado_por uuid null,
  aprovado_em timestamptz null,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),
  constraint aula_quadrinho_assets_chave_key unique (aula_versao_id, componente_id, quadro_indice),
  constraint aula_quadrinho_assets_quadro_indice_check check (quadro_indice between 0 and 5),
  constraint aula_quadrinho_assets_scene_hash_check check (scene_hash ~ '^[0-9a-f]{64}$'),
  constraint aula_quadrinho_assets_status_check check (status in ('pendente', 'gerando', 'gerada', 'aprovada', 'rejeitada', 'erro')),
  constraint aula_quadrinho_assets_tentativas_check check (tentativas between 0 and 3),
  constraint aula_quadrinho_assets_storage_path_check check (storage_path is null or (length(btrim(storage_path)) > 0 and storage_path !~ '(^/|\.\.)')),
  constraint aula_quadrinho_assets_gerada_exige_path_check check (status not in ('gerada', 'aprovada') or storage_path is not null),
  constraint aula_quadrinho_assets_aprovada_exige_data_check check (status <> 'aprovada' or aprovado_em is not null)
);

create unique index aula_quadrinho_assets_storage_path_key
  on public.aula_quadrinho_assets (storage_path)
  where storage_path is not null;

-- RLS ligado e zero acesso direto: escrita só por service_role (Edge) e por
-- RPCs SECURITY DEFINER; leitura só pelas RPCs abaixo. Nenhuma policy.
alter table public.aula_quadrinho_assets enable row level security;
revoke all on table public.aula_quadrinho_assets from public, anon, authenticated;

-- ================= 2) HASH CANONICO DA CENA =================
-- SHA-256 hex minúsculo de NFC(trim(cena)); trim = espaço, tab, CR e LF.
-- IMMUTABLE, sem dependência de usuário/sessão (search_path vazio).
create function public.hash_cena_quadrinho(p_cena text)
returns text
language plpgsql
immutable
set search_path to ''
as $$
declare
  v_norm text;
begin
  if p_cena is null then
    raise exception 'cena nula';
  end if;
  v_norm := normalize(btrim(p_cena, E' \t\r\n'), NFC);
  if length(v_norm) = 0 then
    raise exception 'cena vazia';
  end if;
  return encode(sha256(convert_to(v_norm, 'UTF8')), 'hex');
end;
$$;

-- ================= 3) HASH DA CENA ATUAL NA ESTRUTURA =================
-- Devolve NULL (nunca erro) se a versão/componente não existe, se o
-- componente não é quadrinho_didatico, se o índice está fora do array ou se a
-- cena não é um texto não vazio. Helper interno: sem grant para clientes.
create function public.hash_cena_atual_quadrinho(p_aula_versao_id uuid, p_componente_id uuid, p_quadro_indice smallint)
returns text
language plpgsql
stable
set search_path to ''
as $$
declare
  v_comp jsonb;
  v_quadro jsonb;
  v_cena text;
begin
  if p_aula_versao_id is null or p_componente_id is null or p_quadro_indice is null or p_quadro_indice < 0 then
    return null;
  end if;

  select c.value into v_comp
  from public.aula_versoes av
  cross join lateral jsonb_array_elements(
    case when jsonb_typeof(av.estrutura->'componentes') = 'array' then av.estrutura->'componentes' else '[]'::jsonb end
  ) with ordinality as c(value, ord)
  where av.id = p_aula_versao_id
    and jsonb_typeof(c.value) = 'object'
    and lower(c.value->>'id') = p_componente_id::text
    and c.value->>'tipo' = 'quadrinho_didatico'
  order by c.ord
  limit 1;

  if v_comp is null then return null; end if;
  if jsonb_typeof(v_comp->'quadros') is distinct from 'array' then return null; end if;
  if p_quadro_indice >= jsonb_array_length(v_comp->'quadros') then return null; end if;

  v_quadro := v_comp->'quadros'->(p_quadro_indice::int);
  if jsonb_typeof(v_quadro) is distinct from 'object' then return null; end if;
  if jsonb_typeof(v_quadro->'cena') is distinct from 'string' then return null; end if;

  v_cena := v_quadro->>'cena';
  if length(btrim(v_cena, E' \t\r\n')) = 0 then return null; end if;

  return public.hash_cena_quadrinho(v_cena);
end;
$$;

-- ================= 4) RPC DO ALUNO =================
-- Autorização = a de carregar_aula_publicada_da_missao (mesmas tabelas,
-- mesmos predicados, mesma seleção da versão): auth.uid() obrigatório; a
-- missão precisa ser do usuário com matrícula 'ativa'; a versão acessível é
-- a publicada da primeira unidade ativa do conteúdo da missão. Se
-- p_aula_versao_id NÃO for exatamente essa versão, não retorna nada.
create function public.carregar_quadrinho_assets_aula(p_missao_id uuid, p_aula_versao_id uuid)
returns table (
  asset_id uuid,
  componente_id uuid,
  quadro_indice smallint,
  storage_path text,
  scene_hash text
)
language plpgsql
stable
security definer
set search_path to ''
as $$
declare
  v_usuario_id uuid;
  v_missao_id uuid;
  v_conteudo_id bigint;
  v_versao_acessivel uuid;
begin
  v_usuario_id := auth.uid();
  if v_usuario_id is null then raise exception 'Usuario nao autenticado'; end if;

  select ms.id, ms.conteudo_id into v_missao_id, v_conteudo_id
  from public.missoes ms join public.matriculas m on m.id = ms.matricula_id
  where ms.id = p_missao_id and m.usuario_id = v_usuario_id and m.status = 'ativa';
  if v_missao_id is null then
    raise exception 'Missao nao encontrada, nao pertence ao usuario autenticado, ou a matricula nao esta ativa';
  end if;

  select av.id into v_versao_acessivel
  from public.unidades_pedagogicas u
  join public.aulas a on a.unidade_pedagogica_id = u.id and a.ativa
  join public.aula_versoes av on av.aula_id = a.id and av.status = 'publicada'
  where u.curso_conteudo_id = v_conteudo_id and u.ativa
  order by u.ordem
  limit 1;

  if v_versao_acessivel is null or p_aula_versao_id is distinct from v_versao_acessivel then
    return;
  end if;

  return query
  select q.id, q.componente_id, q.quadro_indice, q.storage_path, q.scene_hash
  from public.aula_quadrinho_assets q
  where q.aula_versao_id = v_versao_acessivel
    and q.status = 'aprovada'
    and q.storage_path is not null
    and q.scene_hash = public.hash_cena_atual_quadrinho(q.aula_versao_id, q.componente_id, q.quadro_indice)
  order by q.componente_id, q.quadro_indice;
end;
$$;

-- ================= 5) RPC DO ADMIN =================
create function public.carregar_quadrinho_assets_admin(p_aula_versao_id uuid)
returns table (
  id uuid,
  aula_versao_id uuid,
  componente_id uuid,
  quadro_indice smallint,
  scene_hash text,
  scene_hash_atual text,
  asset_atual boolean,
  status text,
  storage_path text,
  modelo text,
  prompt_version text,
  prompt_visual text,
  tentativas smallint,
  erro_sanitizado text,
  aprovado_por uuid,
  aprovado_em timestamptz,
  criado_em timestamptz,
  atualizado_em timestamptz
)
language plpgsql
stable
security definer
set search_path to ''
as $$
begin
  if not public.eh_admin() then
    raise exception 'Apenas administradores podem visualizar assets de quadrinhos';
  end if;

  return query
  select q.id, q.aula_versao_id, q.componente_id, q.quadro_indice, q.scene_hash,
    h.hash_atual,
    (h.hash_atual is not null and h.hash_atual = q.scene_hash),
    q.status, q.storage_path, q.modelo, q.prompt_version, q.prompt_visual, q.tentativas,
    q.erro_sanitizado, q.aprovado_por, q.aprovado_em, q.criado_em, q.atualizado_em
  from public.aula_quadrinho_assets q
  cross join lateral (
    select public.hash_cena_atual_quadrinho(q.aula_versao_id, q.componente_id, q.quadro_indice) as hash_atual
  ) h
  where q.aula_versao_id = p_aula_versao_id
  order by q.componente_id, q.quadro_indice;
end;
$$;

-- ================= 6) GRANTS DAS FUNCOES =================
revoke all on function public.hash_cena_quadrinho(text) from public, anon, authenticated;
revoke all on function public.hash_cena_atual_quadrinho(uuid, uuid, smallint) from public, anon, authenticated;
revoke all on function public.carregar_quadrinho_assets_aula(uuid, uuid) from public, anon;
revoke all on function public.carregar_quadrinho_assets_admin(uuid) from public, anon;
grant execute on function public.carregar_quadrinho_assets_aula(uuid, uuid) to authenticated;
grant execute on function public.carregar_quadrinho_assets_admin(uuid) to authenticated;

-- ================= 7) BUCKET PRIVADO =================
-- INSERT simples (a precondição garante que o bucket não existe): nunca
-- reconfigura um bucket alheio. 262144 bytes = 256 KiB. Sem policies.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('quadrinhos-aulas', 'quadrinhos-aulas', false, 262144, array['image/webp']);
-- <<< SECAO_CORPO

-- >>> SECAO_POSCOND (identica no harness)
do $$
declare
  v_colunas text;
  v_esperado text := 'id:uuid:NO,aula_versao_id:uuid:NO,componente_id:uuid:NO,quadro_indice:smallint:NO,scene_hash:text:NO,status:text:NO,storage_path:text:YES,modelo:text:YES,prompt_version:text:YES,prompt_visual:text:YES,tentativas:smallint:NO,lease_ate:timestamp with time zone:YES,erro_sanitizado:text:YES,aprovado_por:uuid:YES,aprovado_em:timestamp with time zone:YES,criado_em:timestamp with time zone:NO,atualizado_em:timestamp with time zone:NO';
  v_rel oid := 'public.aula_quadrinho_assets'::regclass;
  v_papel text;
  v_priv text;
  v_bucket record;
  v_fn text;
begin
  select string_agg(column_name || ':' || data_type || ':' || is_nullable, ',' order by ordinal_position) into v_colunas
  from information_schema.columns where table_schema = 'public' and table_name = 'aula_quadrinho_assets';
  if v_colunas is distinct from v_esperado then raise exception 'POSCOND: colunas divergem: %', v_colunas; end if;

  if not (select relrowsecurity from pg_class where oid = v_rel) then raise exception 'POSCOND: RLS nao habilitado'; end if;
  if exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'aula_quadrinho_assets') then
    raise exception 'POSCOND: nao deveria haver policy na tabela';
  end if;

  foreach v_papel in array array['anon', 'authenticated'] loop
    foreach v_priv in array array['select', 'insert', 'update', 'delete', 'truncate', 'references', 'trigger'] loop
      if has_table_privilege(v_papel, v_rel, v_priv) then raise exception 'POSCOND: % tem % direto na tabela', v_papel, v_priv; end if;
    end loop;
  end loop;

  if (select count(*) from pg_constraint where conrelid = v_rel and contype = 'p') <> 1 then raise exception 'POSCOND: PK'; end if;
  if not exists (select 1 from pg_constraint where conrelid = v_rel and contype = 'f' and confrelid = 'public.aula_versoes'::regclass and confdeltype = 'c') then
    raise exception 'POSCOND: FK aula_versao_id -> aula_versoes ON DELETE CASCADE';
  end if;
  if (select count(*) from pg_constraint where conrelid = v_rel and contype = 'f') <> 1 then raise exception 'POSCOND: deveria haver apenas 1 FK'; end if;
  if not exists (
    select 1 from pg_constraint c where c.conrelid = v_rel and c.contype = 'u' and c.conname = 'aula_quadrinho_assets_chave_key'
      and (select array_agg(a.attname::text order by k.ord) from unnest(c.conkey) with ordinality k(attnum, ord) join pg_attribute a on a.attrelid = c.conrelid and a.attnum = k.attnum)
          = array['aula_versao_id', 'componente_id', 'quadro_indice']
  ) then raise exception 'POSCOND: UNIQUE (aula_versao_id, componente_id, quadro_indice)'; end if;
  if (select count(*) from pg_constraint where conrelid = v_rel and contype = 'c') <> 7 then raise exception 'POSCOND: esperado 7 CHECKs'; end if;
  if not exists (select 1 from pg_indexes where schemaname = 'public' and tablename = 'aula_quadrinho_assets' and indexname = 'aula_quadrinho_assets_storage_path_key' and indexdef ilike '%UNIQUE%(storage_path)%WHERE%storage_path IS NOT NULL%') then
    raise exception 'POSCOND: indice unico parcial de storage_path';
  end if;

  foreach v_fn in array array['public.hash_cena_quadrinho(text)', 'public.hash_cena_atual_quadrinho(uuid,uuid,smallint)'] loop
    foreach v_papel in array array['anon', 'authenticated'] loop
      if has_function_privilege(v_papel, v_fn::regprocedure, 'execute') then raise exception 'POSCOND: % nao deveria executar %', v_papel, v_fn; end if;
    end loop;
  end loop;
  foreach v_fn in array array['public.carregar_quadrinho_assets_aula(uuid,uuid)', 'public.carregar_quadrinho_assets_admin(uuid)'] loop
    if has_function_privilege('anon', v_fn::regprocedure, 'execute') then raise exception 'POSCOND: anon executa %', v_fn; end if;
    if not has_function_privilege('authenticated', v_fn::regprocedure, 'execute') then raise exception 'POSCOND: authenticated nao executa %', v_fn; end if;
    if not (select p.prosecdef from pg_proc p where p.oid = v_fn::regprocedure) then raise exception 'POSCOND: % deveria ser SECURITY DEFINER', v_fn; end if;
    if not exists (select 1 from pg_proc p where p.oid = v_fn::regprocedure and p.proconfig @> array['search_path=""']) then raise exception 'POSCOND: % sem search_path vazio', v_fn; end if;
  end loop;

  select id, name, public, file_size_limit, allowed_mime_types into v_bucket from storage.buckets where id = 'quadrinhos-aulas';
  if v_bucket.id is null then raise exception 'POSCOND: bucket ausente'; end if;
  if v_bucket.public is distinct from false then raise exception 'POSCOND: bucket deveria ser privado'; end if;
  if v_bucket.file_size_limit is distinct from 262144 then raise exception 'POSCOND: limite do bucket'; end if;
  if v_bucket.allowed_mime_types is distinct from array['image/webp'] then raise exception 'POSCOND: MIME do bucket'; end if;
  if exists (
    select 1 from pg_policies where schemaname = 'storage' and tablename = 'objects'
      and (coalesce(qual, '') || ' ' || coalesce(with_check, '')) like '%quadrinhos-aulas%'
  ) then raise exception 'POSCOND: nao deveria existir policy de storage para quadrinhos-aulas'; end if;

  -- vetores de teste do hash: 'abc' (vetor publico SHA-256), trim e NFC equivalentes
  if public.hash_cena_quadrinho('abc') <> 'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad' then raise exception 'POSCOND: vetor SHA-256 de abc'; end if;
  if public.hash_cena_quadrinho('  Teste ' || E'\n') <> public.hash_cena_quadrinho('Teste') then raise exception 'POSCOND: trim'; end if;
  if public.hash_cena_quadrinho('Jos' || chr(233)) <> public.hash_cena_quadrinho('Jose' || chr(769)) then raise exception 'POSCOND: NFC composto x decomposto'; end if;

  raise notice 'POSCOND OK: tabela, constraints, RLS, revokes, funcoes, grants, bucket privado e hash conferem';
end $$;
-- <<< SECAO_POSCOND

-- ============================================================================
-- V) ESCOPO: nada além do pacote foi criado/alterado (antes de qualquer fixture)
-- ============================================================================
do $$
declare
  v_novas_rel text[];
  v_novas_fn text[];
  v_novas_pol text[];
  v_novos_buckets text[];
  v_snap record;
begin
  select array_agg(c.relname::text) into v_novas_rel
  from pg_class c join pg_namespace n on n.oid = c.relnamespace
  where n.nspname = 'public' and c.relname::text not in (select nome from _q9_snap_rel);
  insert into teste_q9 (chave, ok) values ('escopo_relacoes_novas_exatas',
    v_novas_rel @> array['aula_quadrinho_assets', 'aula_quadrinho_assets_chave_key', 'aula_quadrinho_assets_pkey', 'aula_quadrinho_assets_storage_path_key'] and cardinality(v_novas_rel) = 4);

  select array_agg(p.proname::text) into v_novas_fn
  from pg_proc p join pg_namespace n on n.oid = p.pronamespace
  where n.nspname = 'public' and p.oid::text not in (select nome from _q9_snap_fn);
  insert into teste_q9 (chave, ok) values ('escopo_funcoes_novas_exatas',
    v_novas_fn @> array['carregar_quadrinho_assets_admin', 'carregar_quadrinho_assets_aula', 'hash_cena_atual_quadrinho', 'hash_cena_quadrinho'] and cardinality(v_novas_fn) = 4);

  select array_agg(nome order by nome) into v_novas_pol from (
    select schemaname::text || '.' || tablename::text || '.' || policyname::text as nome from pg_policies
    except select nome from _q9_snap_pol) x;
  insert into teste_q9 (chave, ok) values ('escopo_nenhuma_policy_nova', v_novas_pol is null);
  insert into teste_q9 (chave, ok) values ('escopo_nenhuma_policy_removida', not exists (
    select nome from _q9_snap_pol except select schemaname::text || '.' || tablename::text || '.' || policyname::text from pg_policies));

  select array_agg(id::text order by id::text) into v_novos_buckets from storage.buckets where id::text not in (select nome from _q9_snap_bucket);
  insert into teste_q9 (chave, ok) values ('escopo_bucket_novo_exato', v_novos_buckets = array['quadrinhos-aulas']);

  select * into v_snap from _q9_snap_estado;
  insert into teste_q9 (chave, ok) values ('escopo_aula_versoes_intactas',
    v_snap.h_versoes is not distinct from (select md5(string_agg(id::text || estrutura::text || status || numero_versao::text, '|' order by id)) from public.aula_versoes));
  insert into teste_q9 (chave, ok) values ('escopo_aulas_intactas',
    v_snap.h_aulas is not distinct from (select md5(string_agg(id::text || titulo || ativa::text, '|' order by id)) from public.aulas));
  insert into teste_q9 (chave, ok) values ('escopo_contagens_intactas',
    v_snap.n_geracoes = (select count(*) from public.aula_geracoes)
    and v_snap.n_matriculas = (select count(*) from public.matriculas)
    and v_snap.n_missoes = (select count(*) from public.missoes));
  insert into teste_q9 (chave, ok) values ('escopo_rpcs_existentes_intactas',
    v_snap.h_rpc_aula = md5(pg_get_functiondef('public.carregar_aula_publicada_da_missao(uuid)'::regprocedure))
    and v_snap.h_rpc_rascunho = md5(pg_get_functiondef('public.carregar_aula_rascunho_admin(uuid)'::regprocedure))
    and v_snap.h_eh_admin = md5(pg_get_functiondef('public.eh_admin()'::regprocedure)));
end $$;

-- ============================================================================
-- M) HASH: casos determinísticos
-- ============================================================================
do $$
declare
  v_ok boolean;
begin
  insert into teste_q9 (chave, ok) values ('hash_vetor_sha256_abc',
    public.hash_cena_quadrinho('abc') = 'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad');
  insert into teste_q9 (chave, ok) values ('hash_formato_hex64_minusculo', public.hash_cena_quadrinho('Teste') ~ '^[0-9a-f]{64}$');
  insert into teste_q9 (chave, ok) values ('hash_trim_equivalente',
    public.hash_cena_quadrinho('  Teste  ') = public.hash_cena_quadrinho('Teste')
    and public.hash_cena_quadrinho(E'\t Teste\r\n') = public.hash_cena_quadrinho('Teste'));
  insert into teste_q9 (chave, ok) values ('hash_nfc_composto_igual_decomposto',
    public.hash_cena_quadrinho('Jos' || chr(233)) = public.hash_cena_quadrinho('Jose' || chr(769)));
  insert into teste_q9 (chave, ok) values ('hash_diferencia_textos',
    public.hash_cena_quadrinho('Teste') <> public.hash_cena_quadrinho('teste'));
  insert into teste_q9 (chave, ok) values ('hash_deterministico',
    public.hash_cena_quadrinho('Noite. Uma cena.') = public.hash_cena_quadrinho('Noite. Uma cena.'));
  v_ok := false;
  begin perform public.hash_cena_quadrinho(null); exception when others then v_ok := true; end;
  insert into teste_q9 (chave, ok) values ('hash_rejeita_null', v_ok);
  v_ok := false;
  begin perform public.hash_cena_quadrinho('   '); exception when others then v_ok := true; end;
  insert into teste_q9 (chave, ok) values ('hash_rejeita_vazio', v_ok);
  insert into teste_q9 (chave, ok) values ('hash_e_immutable',
    (select p.provolatile = 'i' from pg_proc p where p.oid = 'public.hash_cena_quadrinho(text)'::regprocedure));
end $$;

-- ============================================================================
-- C..I) CONSTRAINTS (violações provocadas em sub-blocos; a tabela é esvaziada no fim)
-- ============================================================================
do $$
declare
  v_p constant uuid := '52756262-8be4-4fb2-a9f3-2f5a158ea1d4';
  v_c constant uuid := '1f4065f2-8fda-4f7d-8826-45955230678d';
  v_h constant text := repeat('a', 64);
  v_ok boolean;
begin
  if not exists (select 1 from public.aula_versoes av, jsonb_array_elements(av.estrutura->'componentes') c
                 where av.id = v_p and c.value->>'id' = v_c::text and c.value->>'tipo' = 'quadrinho_didatico') then
    raise exception 'FIXTURE: o quadrinho piloto (52756262/1f4065f2) nao esta na aula rascunho da U1';
  end if;

  v_ok := false;
  begin insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash) values (v_p, v_c, 0, v_h); v_ok := true; exception when others then v_ok := false; end;
  insert into teste_q9 (chave, ok) values ('insert_valido_aceito_com_defaults', v_ok
    and (select status = 'pendente' and tentativas = 0 and storage_path is null and aprovado_em is null from public.aula_quadrinho_assets where quadro_indice = 0));

  v_ok := false;
  begin insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash) values (v_p, v_c, 0, v_h);
  exception when unique_violation then v_ok := true; end;
  insert into teste_q9 (chave, ok) values ('unique_chave_aula_componente_indice', v_ok);

  v_ok := false;
  begin insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash) values (v_p, v_c, 6, v_h);
  exception when check_violation then v_ok := true; end;
  insert into teste_q9 (chave, ok) values ('check_quadro_indice_maximo_5', v_ok);

  v_ok := false;
  begin insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash) values (v_p, v_c, -1, v_h);
  exception when check_violation then v_ok := true; end;
  insert into teste_q9 (chave, ok) values ('check_quadro_indice_minimo_0', v_ok);

  v_ok := false;
  begin insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash) values (v_p, v_c, 1, upper(v_h));
  exception when check_violation then v_ok := true; end;
  insert into teste_q9 (chave, ok) values ('check_scene_hash_rejeita_maiuscula', v_ok);

  v_ok := false;
  begin insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash) values (v_p, v_c, 1, repeat('a', 63));
  exception when check_violation then v_ok := true; end;
  insert into teste_q9 (chave, ok) values ('check_scene_hash_rejeita_tamanho', v_ok);

  v_ok := false;
  begin insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash) values (v_p, v_c, 1, repeat('g', 64));
  exception when check_violation then v_ok := true; end;
  insert into teste_q9 (chave, ok) values ('check_scene_hash_rejeita_nao_hex', v_ok);

  v_ok := false;
  begin insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash, status) values (v_p, v_c, 1, v_h, 'publicada');
  exception when check_violation then v_ok := true; end;
  insert into teste_q9 (chave, ok) values ('check_status_invalido', v_ok);

  v_ok := true;
  begin
    insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash, status) values (v_p, v_c, 1, v_h, 'pendente');
    update public.aula_quadrinho_assets set status = 'gerando' where quadro_indice = 1;
    update public.aula_quadrinho_assets set status = 'rejeitada' where quadro_indice = 1;
    update public.aula_quadrinho_assets set status = 'erro' where quadro_indice = 1;
    update public.aula_quadrinho_assets set status = 'pendente' where quadro_indice = 1;
  exception when others then v_ok := false; end;
  insert into teste_q9 (chave, ok) values ('status_transicoes_legitimas_nao_bloqueadas', v_ok);

  v_ok := false;
  begin insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash, tentativas) values (v_p, v_c, 2, v_h, 4);
  exception when check_violation then v_ok := true; end;
  insert into teste_q9 (chave, ok) values ('check_tentativas_maximo_3', v_ok);

  v_ok := false;
  begin insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash, tentativas) values (v_p, v_c, 2, v_h, -1);
  exception when check_violation then v_ok := true; end;
  insert into teste_q9 (chave, ok) values ('check_tentativas_minimo_0', v_ok);

  v_ok := false;
  begin insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash, status) values (v_p, v_c, 2, v_h, 'gerada');
  exception when check_violation then v_ok := true; end;
  insert into teste_q9 (chave, ok) values ('coerencia_gerada_exige_storage_path', v_ok);

  v_ok := false;
  begin insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash, status, storage_path) values (v_p, v_c, 2, v_h, 'aprovada', 'q9/x.webp');
  exception when check_violation then v_ok := true; end;
  insert into teste_q9 (chave, ok) values ('coerencia_aprovada_exige_aprovado_em', v_ok);

  v_ok := false;
  begin insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash, storage_path) values (v_p, v_c, 2, v_h, '../fuga.webp');
  exception when check_violation then v_ok := true; end;
  insert into teste_q9 (chave, ok) values ('check_storage_path_rejeita_dotdot', v_ok);

  v_ok := false;
  begin insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash, storage_path) values (v_p, v_c, 2, v_h, '/absoluto.webp');
  exception when check_violation then v_ok := true; end;
  insert into teste_q9 (chave, ok) values ('check_storage_path_rejeita_absoluto', v_ok);

  v_ok := true;
  begin
    insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash, status, storage_path, aprovado_em) values (v_p, v_c, 2, v_h, 'aprovada', 'q9-dup/a.webp', now());
  exception when others then v_ok := false; end;
  insert into teste_q9 (chave, ok) values ('coerencia_aprovada_completa_aceita', v_ok);

  v_ok := false;
  begin insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash, storage_path) values (v_p, v_c, 3, v_h, 'q9-dup/a.webp');
  exception when unique_violation then v_ok := true; end;
  insert into teste_q9 (chave, ok) values ('unique_parcial_storage_path', v_ok);

  v_ok := true;
  begin
    insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash) values (v_p, v_c, 3, v_h);
    insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash) values (v_p, v_c, 4, v_h);
  exception when others then v_ok := false; end;
  insert into teste_q9 (chave, ok) values ('storage_path_null_repetido_permitido', v_ok);

  v_ok := false;
  begin insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash) values (gen_random_uuid(), v_c, 0, v_h);
  exception when foreign_key_violation then v_ok := true; end;
  insert into teste_q9 (chave, ok) values ('fk_aula_versao_id_existente', v_ok);

  v_ok := false;
  begin insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash) values (v_p, gen_random_uuid(), 0, v_h); v_ok := true;
  exception when others then v_ok := false; end;
  insert into teste_q9 (chave, ok) values ('componente_id_sem_fk_aceita_uuid_qualquer', v_ok);

  delete from public.aula_quadrinho_assets;
end $$;

-- ============================================================================
-- Helper da cena atual (piloto real: 4 quadros)
-- ============================================================================
do $$
declare
  v_p constant uuid := '52756262-8be4-4fb2-a9f3-2f5a158ea1d4';
  v_c constant uuid := '1f4065f2-8fda-4f7d-8826-45955230678d';
  v_conceito constant uuid := 'f0614831-dbff-4c68-b7f9-b3d31425adb4';
  v_cena0 text;
begin
  select c.value->'quadros'->0->>'cena' into v_cena0
  from public.aula_versoes av, jsonb_array_elements(av.estrutura->'componentes') c
  where av.id = v_p and c.value->>'id' = v_c::text;

  insert into teste_q9 (chave, ok) values ('cena_atual_quadro_0_confere',
    public.hash_cena_atual_quadrinho(v_p, v_c, 0::smallint) = public.hash_cena_quadrinho(v_cena0));
  insert into teste_q9 (chave, ok) values ('cena_atual_quatro_quadros_validos',
    public.hash_cena_atual_quadrinho(v_p, v_c, 3::smallint) is not null
    and public.hash_cena_atual_quadrinho(v_p, v_c, 4::smallint) is null);
  insert into teste_q9 (chave, ok) values ('cena_atual_indice_fora_do_array_nulo',
    public.hash_cena_atual_quadrinho(v_p, v_c, 5::smallint) is null and public.hash_cena_atual_quadrinho(v_p, v_c, 100::smallint) is null);
  insert into teste_q9 (chave, ok) values ('cena_atual_indice_negativo_nulo', public.hash_cena_atual_quadrinho(v_p, v_c, (-1)::smallint) is null);
  insert into teste_q9 (chave, ok) values ('cena_atual_componente_inexistente_nulo', public.hash_cena_atual_quadrinho(v_p, gen_random_uuid(), 0::smallint) is null);
  insert into teste_q9 (chave, ok) values ('cena_atual_componente_nao_quadrinho_nulo', public.hash_cena_atual_quadrinho(v_p, v_conceito, 0::smallint) is null);
  insert into teste_q9 (chave, ok) values ('cena_atual_versao_inexistente_nula', public.hash_cena_atual_quadrinho(gen_random_uuid(), v_c, 0::smallint) is null);
  insert into teste_q9 (chave, ok) values ('cena_atual_argumentos_nulos', public.hash_cena_atual_quadrinho(null, v_c, 0::smallint) is null and public.hash_cena_atual_quadrinho(v_p, null, 0::smallint) is null and public.hash_cena_atual_quadrinho(v_p, v_c, null) is null);
end $$;

-- ============================================================================
-- N/O) RPC ADMIN
-- ============================================================================
do $$
declare
  v_p constant uuid := '52756262-8be4-4fb2-a9f3-2f5a158ea1d4';
  v_c constant uuid := '1f4065f2-8fda-4f7d-8826-45955230678d';
  v_conceito constant uuid := 'f0614831-dbff-4c68-b7f9-b3d31425adb4';
  v_admin uuid;
  v_h0 text; v_h2 text; v_h3 text;
  v_n int;
  v_ok boolean;
  r record;
begin
  select usuario_id into v_admin from public.administradores order by criado_em limit 1;
  if v_admin is null then raise exception 'FIXTURE: nenhum administrador'; end if;
  v_h0 := public.hash_cena_atual_quadrinho(v_p, v_c, 0::smallint);
  v_h2 := public.hash_cena_atual_quadrinho(v_p, v_c, 2::smallint);
  v_h3 := public.hash_cena_atual_quadrinho(v_p, v_c, 3::smallint);

  insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash, status, storage_path, aprovado_em, aprovado_por, modelo, prompt_version, prompt_visual)
    values (v_p, v_c, 0, v_h0, 'aprovada', 'q9-teste/p0.webp', now(), v_admin, 'modelo-teste', 'pv-teste', 'prompt visual de teste');
  insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash, status, storage_path, aprovado_em)
    values (v_p, v_c, 1, repeat('a', 64), 'aprovada', 'q9-teste/p1.webp', now());
  insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash, status)
    values (v_p, v_c, 2, v_h2, 'pendente');
  insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash, status, storage_path)
    values (v_p, v_c, 3, v_h3, 'gerada', 'q9-teste/p3.webp');
  insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash, status)
    values (v_p, v_conceito, 0, repeat('b', 64), 'pendente');
  insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash, status, erro_sanitizado, tentativas)
    values (v_p, v_c, 5, repeat('c', 64), 'erro', 'falha de teste', 3);

  perform set_config('request.jwt.claim.sub', v_admin::text, true);
  select count(*) into v_n from public.carregar_quadrinho_assets_admin(v_p);
  insert into teste_q9 (chave, ok) values ('admin_ve_todos_os_status', v_n = 6);

  select * into r from public.carregar_quadrinho_assets_admin(v_p) x where x.componente_id = v_c and x.quadro_indice = 0;
  insert into teste_q9 (chave, ok) values ('admin_asset_atual_true_quando_hash_bate',
    r.asset_atual is true and r.scene_hash = r.scene_hash_atual and r.status = 'aprovada' and r.modelo = 'modelo-teste' and r.prompt_visual = 'prompt visual de teste' and r.aprovado_por = v_admin and r.storage_path = 'q9-teste/p0.webp');
  select * into r from public.carregar_quadrinho_assets_admin(v_p) x where x.componente_id = v_c and x.quadro_indice = 1;
  insert into teste_q9 (chave, ok) values ('admin_asset_atual_false_quando_cena_mudou',
    r.asset_atual is false and r.scene_hash_atual is not null and r.scene_hash_atual <> r.scene_hash and r.status = 'aprovada');
  select * into r from public.carregar_quadrinho_assets_admin(v_p) x where x.componente_id = v_conceito;
  insert into teste_q9 (chave, ok) values ('admin_componente_nao_quadrinho_atual_false_hash_nulo', r.asset_atual is false and r.scene_hash_atual is null);
  select * into r from public.carregar_quadrinho_assets_admin(v_p) x where x.quadro_indice = 5;
  insert into teste_q9 (chave, ok) values ('admin_indice_fora_do_array_atual_false', r.asset_atual is false and r.scene_hash_atual is null and r.erro_sanitizado = 'falha de teste' and r.tentativas = 3);
  select count(*) into v_n from public.aula_quadrinho_assets where aula_versao_id = v_p;
  insert into teste_q9 (chave, ok) values ('admin_nao_exclui_asset_obsoleto', v_n = 6);
  insert into teste_q9 (chave, ok) values ('admin_versao_sem_assets_retorna_vazio',
    (select count(*) from public.carregar_quadrinho_assets_admin(gen_random_uuid())) = 0);
  select count(*) into v_n from public.carregar_quadrinho_assets_admin(v_p) x;
  insert into teste_q9 (chave, ok) values ('admin_colunas_esperadas', (
    select array_agg(k) from (select jsonb_object_keys(to_jsonb(y)) k from (select * from public.carregar_quadrinho_assets_admin(v_p) limit 1) y) z) @>
    array['aprovado_em', 'aprovado_por', 'asset_atual', 'aula_versao_id', 'atualizado_em', 'componente_id', 'criado_em', 'erro_sanitizado', 'id', 'modelo', 'prompt_version', 'prompt_visual', 'quadro_indice', 'scene_hash', 'scene_hash_atual', 'status', 'storage_path', 'tentativas']
    and (select count(*) from (select jsonb_object_keys(to_jsonb(y)) k from (select * from public.carregar_quadrinho_assets_admin(v_p) limit 1) y) z) = 18);

  v_ok := false;
  begin
    perform set_config('request.jwt.claim.sub', gen_random_uuid()::text, true);
    perform * from public.carregar_quadrinho_assets_admin(v_p);
  exception when others then v_ok := sqlerrm like 'Apenas administradores%'; end;
  insert into teste_q9 (chave, ok) values ('admin_rpc_bloqueia_nao_admin', v_ok);

  v_ok := false;
  begin
    perform set_config('request.jwt.claim.sub', '', true);
    perform * from public.carregar_quadrinho_assets_admin(v_p);
  exception when others then v_ok := sqlerrm like 'Apenas administradores%'; end;
  insert into teste_q9 (chave, ok) values ('admin_rpc_bloqueia_sem_autenticacao', v_ok);
end $$;

create temporary table _q9_fx (chave text primary key, valor text);

-- ============================================================================
-- L/M) RPC DO ALUNO: mesma autorização da leitura da aula
-- ============================================================================
do $$
declare
  v_p constant uuid := '52756262-8be4-4fb2-a9f3-2f5a158ea1d4';
  v_c constant uuid := '1f4065f2-8fda-4f7d-8826-45955230678d';
  v_m uuid; v_u uuid; v_mat uuid; v_conteudo bigint; v_v uuid; v_outra uuid;
  v_comp jsonb; v_idx int;
  v_h0 text; v_h1 text; v_h2 text; v_h3 text;
  v_n int; v_ok boolean; v_st text;
  r record;
begin
  select ms.id, m.usuario_id, m.id, ms.conteudo_id into v_m, v_u, v_mat, v_conteudo
  from public.missoes ms join public.matriculas m on m.id = ms.matricula_id
  where exists (
    select 1 from public.unidades_pedagogicas u
    join public.aulas a on a.unidade_pedagogica_id = u.id and a.ativa
    join public.aula_versoes av on av.aula_id = a.id and av.status = 'publicada'
    where u.curso_conteudo_id = ms.conteudo_id and u.ativa)
  order by (m.status = 'ativa') desc, ms.id
  limit 1;
  if v_m is null then raise exception 'FIXTURE: nenhuma missao em conteudo com aula publicada'; end if;

  update public.matriculas set status = 'ativa' where id = v_mat;   -- desfeito pelo ROLLBACK

  select av.id into v_v
  from public.unidades_pedagogicas u
  join public.aulas a on a.unidade_pedagogica_id = u.id and a.ativa
  join public.aula_versoes av on av.aula_id = a.id and av.status = 'publicada'
  where u.curso_conteudo_id = v_conteudo and u.ativa
  order by u.ordem limit 1;
  select av.id into v_outra from public.aula_versoes av where av.status = 'publicada' and av.id <> v_v limit 1;

  select c.value into v_comp from public.aula_versoes av, jsonb_array_elements(av.estrutura->'componentes') c
  where av.id = v_p and c.value->>'id' = v_c::text;
  update public.aula_versoes
  set estrutura = jsonb_set(estrutura, '{componentes}', (estrutura->'componentes') || jsonb_build_array(v_comp))
  where id = v_v;                                                     -- fixture temporária (ROLLBACK)
  v_idx := jsonb_array_length((select estrutura->'componentes' from public.aula_versoes where id = v_v)) - 1;

  v_h0 := public.hash_cena_atual_quadrinho(v_v, v_c, 0::smallint);
  v_h1 := public.hash_cena_atual_quadrinho(v_v, v_c, 1::smallint);
  v_h2 := public.hash_cena_atual_quadrinho(v_v, v_c, 2::smallint);
  v_h3 := public.hash_cena_atual_quadrinho(v_v, v_c, 3::smallint);
  insert into teste_q9 (chave, ok) values ('aluno_fixture_quadrinho_injetado_na_versao_publicada', v_h0 is not null and v_h3 is not null);

  insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash, status, storage_path, aprovado_em)
    values (v_v, v_c, 0, v_h0, 'aprovada', 'q9-teste/v0.webp', now());
  insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash, status, storage_path, aprovado_em)
    values (v_v, v_c, 1, repeat('a', 64), 'aprovada', 'q9-teste/v1.webp', now());            -- aprovada, mas hash obsoleto
  insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash, status, storage_path)
    values (v_v, v_c, 2, v_h2, 'gerada', 'q9-teste/v2.webp');                                 -- ainda nao aprovada
  insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash, status, storage_path)
    values (v_v, v_c, 3, v_h3, 'rejeitada', 'q9-teste/v3.webp');

  perform set_config('request.jwt.claim.sub', v_u::text, true);
  select count(*) into v_n from public.carregar_quadrinho_assets_aula(v_m, v_v);
  insert into teste_q9 (chave, ok) values ('aluno_recebe_somente_aprovada_com_hash_atual', v_n = 1);
  select * into r from public.carregar_quadrinho_assets_aula(v_m, v_v);
  insert into teste_q9 (chave, ok) values ('aluno_linha_correta',
    r.componente_id = v_c and r.quadro_indice = 0 and r.storage_path = 'q9-teste/v0.webp' and r.scene_hash = v_h0 and r.asset_id is not null);
  insert into teste_q9 (chave, ok) values ('aluno_retorna_apenas_5_colunas_sem_dados_internos', (
    select array_agg(k) from (select jsonb_object_keys(to_jsonb(y)) k from (select * from public.carregar_quadrinho_assets_aula(v_m, v_v) limit 1) y) z) @>
    array['asset_id', 'componente_id', 'quadro_indice', 'scene_hash', 'storage_path']
    and (select count(*) from (select jsonb_object_keys(to_jsonb(y)) k from (select * from public.carregar_quadrinho_assets_aula(v_m, v_v) limit 1) y) z) = 5);

  insert into teste_q9 (chave, ok) values ('aluno_versao_rascunho_nao_retorna_assets',
    (select count(*) from public.carregar_quadrinho_assets_aula(v_m, v_p)) = 0 and exists (select 1 from public.aula_quadrinho_assets where aula_versao_id = v_p and status = 'aprovada'));
  insert into teste_q9 (chave, ok) values ('aluno_versao_de_outra_aula_nao_retorna_assets',
    v_outra is null or (select count(*) from public.carregar_quadrinho_assets_aula(v_m, v_outra)) = 0);
  insert into teste_q9 (chave, ok) values ('aluno_versao_inexistente_nao_retorna_assets',
    (select count(*) from public.carregar_quadrinho_assets_aula(v_m, gen_random_uuid())) = 0 and (select count(*) from public.carregar_quadrinho_assets_aula(v_m, null)) = 0);

  v_ok := false;
  begin
    perform set_config('request.jwt.claim.sub', gen_random_uuid()::text, true);
    perform * from public.carregar_quadrinho_assets_aula(v_m, v_v);
  exception when others then v_ok := sqlerrm like 'Missao nao encontrada%'; end;
  insert into teste_q9 (chave, ok) values ('aluno_missao_de_outro_usuario_bloqueada', v_ok);

  v_ok := false;
  begin
    perform set_config('request.jwt.claim.sub', '', true);
    perform * from public.carregar_quadrinho_assets_aula(v_m, v_v);
  exception when others then v_ok := sqlerrm like 'Usuario nao autenticado%'; end;
  insert into teste_q9 (chave, ok) values ('aluno_sem_autenticacao_bloqueado', v_ok);

  insert into _q9_fx (chave, valor) values ('missao', v_m::text), ('usuario', v_u::text), ('versao', v_v::text), ('matricula', v_mat::text), ('componente_idx', v_idx::text);

  -- matrícula deixa de ser 'ativa' => mesma recusa da RPC que entrega o texto
  perform set_config('request.jwt.claim.sub', v_u::text, true);
  foreach v_st in array array['cancelada', 'expirada'] loop
    update public.matriculas set status = v_st where id = v_mat;
    v_ok := false;
    begin
      perform * from public.carregar_quadrinho_assets_aula(v_m, v_v);
    exception when others then v_ok := sqlerrm like 'Missao nao encontrada%'; end;
    insert into teste_q9 (chave, ok) values ('aluno_matricula_' || v_st || '_bloqueada', v_ok);
  end loop;
  update public.matriculas set status = 'ativa' where id = v_mat;

  -- cena do quadro 0 muda => o asset aprovado (hash antigo) deixa de ser servido
  update public.aula_versoes
  set estrutura = jsonb_set(estrutura, array['componentes', v_idx::text, 'quadros', '0', 'cena'], to_jsonb('Cena alterada depois da arte aprovada.'::text))
  where id = v_v;
  insert into teste_q9 (chave, ok) values ('aluno_cena_mudou_asset_obsoleto_nao_retorna',
    (select count(*) from public.carregar_quadrinho_assets_aula(v_m, v_v)) = 0);
  insert into teste_q9 (chave, ok) values ('admin_ve_asset_obsoleto_apos_mudar_cena', exists (
    select 1 from public.carregar_quadrinho_assets_admin(v_v) x where x.quadro_indice = 0 and x.asset_atual is false and x.status = 'aprovada'));

  -- quadro 2 (cena inalterada) aprovado => passa a ser servido; o 3 rejeitado nunca
  update public.aula_quadrinho_assets set status = 'aprovada', aprovado_em = now() where aula_versao_id = v_v and quadro_indice = 2;
  select * into r from public.carregar_quadrinho_assets_aula(v_m, v_v);
  insert into teste_q9 (chave, ok) values ('aluno_recebe_quadro_aprovado_depois', r.quadro_indice = 2 and r.storage_path = 'q9-teste/v2.webp'
    and (select count(*) from public.carregar_quadrinho_assets_aula(v_m, v_v)) = 1);

  -- ordem da estrutura alterada (quadros 2 e 3 trocam de lugar) => hash do índice não bate mais
  update public.aula_versoes
  set estrutura = jsonb_set(jsonb_set(estrutura,
      array['componentes', v_idx::text, 'quadros', '2'], estrutura->'componentes'->v_idx->'quadros'->3),
      array['componentes', v_idx::text, 'quadros', '3'], estrutura->'componentes'->v_idx->'quadros'->2)
  where id = v_v;
  insert into teste_q9 (chave, ok) values ('aluno_reordenacao_de_quadros_invalida_asset',
    (select count(*) from public.carregar_quadrinho_assets_aula(v_m, v_v)) = 0);
end $$;

-- ============================================================================
-- Papéis REAIS (grants efetivos), usando os valores da fixture acima
-- ============================================================================
create temporary table _q9_papeis (chave text primary key, ok boolean);

do $$
declare
  v_m uuid := (select valor::uuid from _q9_fx where chave = 'missao');
  v_u uuid := (select valor::uuid from _q9_fx where chave = 'usuario');
  v_v uuid := (select valor::uuid from _q9_fx where chave = 'versao');
  v_ok boolean;
begin
  perform set_config('request.jwt.claim.sub', v_u::text, true);

  v_ok := false;
  begin
    set local role authenticated;
    perform 1 from public.aula_quadrinho_assets limit 1;
  exception when insufficient_privilege then v_ok := true; end;
  reset role;
  insert into _q9_papeis values ('authenticated_sem_select_direto_na_tabela', v_ok);

  v_ok := false;
  begin
    set local role authenticated;
    insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash) values (v_v, gen_random_uuid(), 0, repeat('a', 64));
  exception when insufficient_privilege then v_ok := true; end;
  reset role;
  insert into _q9_papeis values ('authenticated_sem_insert_direto_na_tabela', v_ok);

  v_ok := false;
  begin
    set local role anon;
    perform 1 from public.aula_quadrinho_assets limit 1;
  exception when insufficient_privilege then v_ok := true; end;
  reset role;
  insert into _q9_papeis values ('anon_sem_select_direto_na_tabela', v_ok);

  v_ok := false;
  begin
    set local role anon;
    perform * from public.carregar_quadrinho_assets_aula(v_m, v_v);
  exception when insufficient_privilege then v_ok := true; end;
  reset role;
  insert into _q9_papeis values ('anon_nao_executa_rpc_aluno', v_ok);

  v_ok := false;
  begin
    set local role anon;
    perform * from public.carregar_quadrinho_assets_admin(v_v);
  exception when insufficient_privilege then v_ok := true; end;
  reset role;
  insert into _q9_papeis values ('anon_nao_executa_rpc_admin', v_ok);

  v_ok := false;
  begin
    set local role authenticated;
    perform public.hash_cena_quadrinho('abc');
  exception when insufficient_privilege then v_ok := true; end;
  reset role;
  insert into _q9_papeis values ('authenticated_nao_executa_helper_hash', v_ok);

  v_ok := false;
  begin
    set local role authenticated;
    perform public.hash_cena_atual_quadrinho(v_v, gen_random_uuid(), 0::smallint);
  exception when insufficient_privilege then v_ok := true; end;
  reset role;
  insert into _q9_papeis values ('authenticated_nao_executa_helper_cena_atual', v_ok);

  -- authenticated executa a RPC do aluno de ponta a ponta (SECURITY DEFINER lê a tabela fechada)
  v_ok := false;
  begin
    set local role authenticated;
    perform set_config('request.jwt.claim.sub', v_u::text, true);
    perform * from public.carregar_quadrinho_assets_aula(v_m, v_v);
    v_ok := true;
  exception when others then v_ok := false; end;
  reset role;
  insert into _q9_papeis values ('authenticated_executa_rpc_aluno_via_security_definer', v_ok);

  -- authenticated não-admin não passa na RPC admin
  v_ok := false;
  begin
    set local role authenticated;
    perform set_config('request.jwt.claim.sub', gen_random_uuid()::text, true);
    perform * from public.carregar_quadrinho_assets_admin(v_v);
  exception when others then v_ok := sqlerrm like 'Apenas administradores%'; end;
  reset role;
  insert into _q9_papeis values ('authenticated_nao_admin_bloqueado_na_rpc_admin', v_ok);
end $$;

insert into teste_q9 (chave, ok) select chave, ok from _q9_papeis;

-- ============================================================================
-- NENHUMA policy de storage para o bucket (reconfirma no fim)
-- ============================================================================
insert into teste_q9 (chave, ok) values ('storage_sem_policy_para_quadrinhos_aulas', not exists (
  select 1 from pg_policies where schemaname = 'storage' and tablename = 'objects'
    and (coalesce(qual, '') || ' ' || coalesce(with_check, '')) like '%quadrinhos-aulas%'));
insert into teste_q9 (chave, ok) values ('bucket_privado_webp_256kib', exists (
  select 1 from storage.buckets where id = 'quadrinhos-aulas' and public = false and file_size_limit = 262144 and allowed_mime_types = array['image/webp']));

-- ============================================================================
-- REVERTER: o down-migration real é exercitado aqui (tabela vazia, bucket vazio)
-- ============================================================================
delete from public.aula_quadrinho_assets;

-- >>> SECAO_REVERT_GUARDA (identica no harness)
do $$
declare
  v_linhas bigint;
  v_objetos bigint;
begin
  if to_regclass('public.aula_quadrinho_assets') is null then
    raise exception 'REVERT: tabela public.aula_quadrinho_assets ausente — nada a reverter (ou ja revertido)';
  end if;

  select count(*) into v_linhas from public.aula_quadrinho_assets;
  if v_linhas > 0 then
    raise exception 'REVERT: a tabela possui % linha(s); nao sera apagada em silencio', v_linhas;
  end if;

  select count(*) into v_objetos from storage.objects where bucket_id = 'quadrinhos-aulas';
  if v_objetos > 0 then
    raise exception 'REVERT: o bucket quadrinhos-aulas possui % objeto(s); imagens nao sao apagadas por este script', v_objetos;
  end if;

  if exists (
    select 1 from pg_policies
    where schemaname = 'storage' and tablename = 'objects'
      and (coalesce(qual, '') || ' ' || coalesce(with_check, '')) like '%quadrinhos-aulas%'
  ) then
    raise exception 'REVERT: existe policy de storage citando quadrinhos-aulas; remova-a conscientemente antes';
  end if;
end $$;
-- <<< SECAO_REVERT_GUARDA

-- >>> SECAO_REVERT_CORPO (identica no harness)
drop function public.carregar_quadrinho_assets_aula(uuid, uuid);
drop function public.carregar_quadrinho_assets_admin(uuid);
drop function public.hash_cena_atual_quadrinho(uuid, uuid, smallint);
drop function public.hash_cena_quadrinho(text);
drop table public.aula_quadrinho_assets;

-- Bucket VAZIO (provado pela guarda): flag local só para este DELETE.
select set_config('storage.allow_delete_query', 'true', true);
delete from storage.buckets where id = 'quadrinhos-aulas';
select set_config('storage.allow_delete_query', 'false', true);
-- <<< SECAO_REVERT_CORPO

-- >>> SECAO_REVERT_POSCOND (identica no harness)
do $$
begin
  if to_regclass('public.aula_quadrinho_assets') is not null then raise exception 'REVERT POSCOND: tabela ainda existe'; end if;
  if exists (select 1 from storage.buckets where id = 'quadrinhos-aulas') then raise exception 'REVERT POSCOND: bucket ainda existe'; end if;
  if exists (
    select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.proname in ('hash_cena_quadrinho', 'hash_cena_atual_quadrinho', 'carregar_quadrinho_assets_aula', 'carregar_quadrinho_assets_admin')
  ) then raise exception 'REVERT POSCOND: ainda existem funcoes do pacote'; end if;
  raise notice 'REVERT POSCOND OK: tabela, funcoes e bucket removidos';
end $$;
-- <<< SECAO_REVERT_POSCOND

insert into teste_q9 (chave, ok) values ('reverter_restaura_relacoes_funcoes_e_buckets',
  not exists (select c.relname::text from pg_class c join pg_namespace n on n.oid = c.relnamespace where n.nspname = 'public' and c.relname::text not in (select nome from _q9_snap_rel))
  and not exists (select nome from _q9_snap_rel except select c.relname::text from pg_class c join pg_namespace n on n.oid = c.relnamespace where n.nspname = 'public')
  and not exists (select p.oid::text from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public' and p.oid::text not in (select nome from _q9_snap_fn))
  and not exists (select nome from _q9_snap_fn except select p.oid::text from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public')
  and not exists (select id::text from storage.buckets where id::text not in (select nome from _q9_snap_bucket))
  and not exists (select nome from _q9_snap_bucket except select id::text from storage.buckets));

-- ============================================================================
-- OLD_FINAL: fixtures restauradas DENTRO da transação e estado == snapshot OLD
-- (o ROLLBACK seguinte é a garantia final; aqui prova-se que o pacote + o
-- reverter não deixam resíduo próprio nem nas fixtures restauradas).
-- ============================================================================
update public.matriculas m set status = o.status from _q9_old_matriculas o where m.id = o.id and m.status is distinct from o.status;
update public.aula_versoes av set estrutura = o.estrutura from _q9_old_versoes o where av.id = o.id and av.estrutura is distinct from o.estrutura;

insert into teste_q9 (chave, ok) values ('old_final_matriculas_restauradas',
  (select h_matriculas from _q9_snap_estado2) is not distinct from (select md5(string_agg(id::text || status, '|' order by id)) from public.matriculas));
insert into teste_q9 (chave, ok) values ('old_final_missoes_intactas',
  (select h_missoes from _q9_snap_estado2) is not distinct from (select md5(string_agg(id::text || status || conteudo_id::text, '|' order by id)) from public.missoes));
insert into teste_q9 (chave, ok) values ('old_final_aula_versoes_identicas',
  (select h_versoes from _q9_snap_estado) is not distinct from (select md5(string_agg(id::text || estrutura::text || status || numero_versao::text, '|' order by id)) from public.aula_versoes));
insert into teste_q9 (chave, ok) values ('old_final_aulas_identicas',
  (select h_aulas from _q9_snap_estado) is not distinct from (select md5(string_agg(id::text || titulo || ativa::text, '|' order by id)) from public.aulas));
insert into teste_q9 (chave, ok) values ('old_final_contagens_iguais',
  (select n_geracoes from _q9_snap_estado) = (select count(*) from public.aula_geracoes)
  and (select n_matriculas from _q9_snap_estado) = (select count(*) from public.matriculas)
  and (select n_missoes from _q9_snap_estado) = (select count(*) from public.missoes));
insert into teste_q9 (chave, ok) values ('old_final_rpcs_existentes_identicas',
  (select h_rpc_aula from _q9_snap_estado) = md5(pg_get_functiondef('public.carregar_aula_publicada_da_missao(uuid)'::regprocedure))
  and (select h_rpc_rascunho from _q9_snap_estado) = md5(pg_get_functiondef('public.carregar_aula_rascunho_admin(uuid)'::regprocedure))
  and (select h_eh_admin from _q9_snap_estado) = md5(pg_get_functiondef('public.eh_admin()'::regprocedure)));
insert into teste_q9 (chave, ok) values ('old_final_policies_iguais_ao_baseline',
  not exists (select nome from _q9_snap_pol except select schemaname::text || '.' || tablename::text || '.' || policyname::text from pg_policies)
  and not exists (select schemaname::text || '.' || tablename::text || '.' || policyname::text from pg_policies except select nome from _q9_snap_pol));
insert into teste_q9 (chave, ok) values ('old_final_grants_iguais_ao_baseline',
  (select h_grants_tabelas from _q9_snap_estado2) is not distinct from (select md5(string_agg(table_name::text || grantee::text || privilege_type::text, '|' order by table_name::text, grantee::text, privilege_type::text)) from information_schema.role_table_grants where table_schema = 'public')
  and (select h_grants_funcoes from _q9_snap_estado2) is not distinct from (select md5(string_agg(routine_name::text || grantee::text || privilege_type::text, '|' order by routine_name::text, grantee::text, privilege_type::text)) from information_schema.role_routine_grants where routine_schema = 'public'));

-- ============================================================================
-- RESULTADO FINAL (falha aborta com a lista; tudo é desfeito de qualquer forma)
-- ============================================================================
do $$
declare
  v_falhas text;
begin
  select string_agg(chave, ', ' order by ordem) into v_falhas from teste_q9 where ok is distinct from true;
  if v_falhas is not null then
    raise exception 'HARNESS Q9: testes com falha: %', v_falhas;
  end if;
  raise notice 'HARNESS Q9 OK: % verificacoes passaram', (select count(*) from teste_q9);
end $$;

select
  count(*) as verificacoes,
  count(*) filter (where ok) as aprovadas,
  bool_and(ok) as tudo_ok,
  (select jsonb_agg(chave order by ordem) from teste_q9 where ok is distinct from true) as falhas
from teste_q9;

ROLLBACK;
