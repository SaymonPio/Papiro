-- ============================================================================
-- TESTE RUNTIME do pacote supabase/camada_ilustrada_pipeline.sql —
-- TRANSACIONAL, TUDO DESFEITO NO FINAL (BEGIN ... ROLLBACK).
-- ============================================================================
--
-- Rodar de uma vez (env -u SUPABASE_ACCESS_TOKEN npx --no-install supabase db
-- query --linked -f supabase/camada_ilustrada_pipeline_teste_rollback.sql), ler o
-- resultado e NUNCA persistir nada. Não há COMMIT neste arquivo.
--
-- Transacionalidade: ALTER TABLE, CREATE FUNCTION, REVOKE/GRANT e as escritas nas
-- linhas de teste são transacionais no PostgreSQL; o ROLLBACK final desfaz o
-- pacote inteiro. Nenhuma chamada HTTP, Image API, Edge, cron, Vault ou Storage:
-- storage.objects é apenas LIDO (nenhum objeto é criado ou removido).
--
-- As seções PRECOND / CORPO / POSCOND são IDÊNTICAS às do arquivo de apply e as
-- REVERT_* são IDÊNTICAS às de reverter_camada_ilustrada_pipeline.sql
-- (tests/camada-ilustrada-pipeline.test.mjs compara byte a byte). Ordem:
--   V) escopo (só o pipeline foi criado; fundação Q9, aulas, cron e Vault intactos);
--   constraints novas; grants reais (SET LOCAL ROLE); RPCs admin bloqueadas p/ não-admin;
--   criar jobs (validações, criação, idempotência); worker (claim, lease, fencing,
--   tentativas, falha/sanitização, conclusão); cena que muda durante o pipeline;
--   admin (aprovar, rejeitar, regenerar, sincronizar, excluir em 2 fases);
--   REVERTER (down-migration real) e OLD_FINAL (estado == snapshot OLD).
-- Fixtures: SOMENTE linhas de public.aula_quadrinho_assets, usando a versão/
-- componente do piloto como referência. Mutações temporárias na estrutura do
-- piloto (cena/quadros) acontecem em sub-blocos desfeitos automaticamente.
-- Sem alterar matrículas, perfis ou objetivos.

BEGIN;

create temporary table teste_q10 (
  ordem serial,
  chave text primary key,
  ok boolean
);

-- Helpers temporários (somem com a transação): registrar resultado e provar exceções.
create function pg_temp.q10_reg(p_chave text, p_ok boolean) returns void language sql as $f$
  insert into teste_q10 (chave, ok) values (p_chave, coalesce(p_ok, false))
$f$;
create function pg_temp.q10_raises(p_sql text, p_padrao text) returns boolean language plpgsql as $f$
begin
  execute p_sql;
  return false;
exception when others then
  return sqlerrm like p_padrao;
end;
$f$;

-- Snapshot ANTES de qualquer criação.
create temporary table _q10_snap_rel on commit drop as
select c.relname::text as nome from pg_class c join pg_namespace n on n.oid = c.relnamespace where n.nspname = 'public';
create temporary table _q10_snap_fn on commit drop as
select p.oid::text as nome from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public';
create temporary table _q10_snap_pol on commit drop as
select schemaname::text || '.' || tablename::text || '.' || policyname::text as nome from pg_policies;
create temporary table _q10_snap_bucket on commit drop as
select id::text || ':' || public::text || ':' || coalesce(file_size_limit::text, '') || ':' || coalesce(allowed_mime_types::text, '') as nome from storage.buckets;
create temporary table _q10_snap_cons on commit drop as
select conname::text as nome from pg_constraint where conrelid = 'public.aula_quadrinho_assets'::regclass;
create temporary table _q10_old_versoes on commit drop as select id, estrutura from public.aula_versoes;
create temporary table _q10_snap_estado on commit drop as
select
  (select string_agg(column_name || ':' || data_type || ':' || is_nullable, ',' order by ordinal_position)
     from information_schema.columns where table_schema = 'public' and table_name = 'aula_quadrinho_assets') as colunas,
  (select count(*) from public.aula_quadrinho_assets) as n_assets,
  (select jsonb_object_agg(p.proname, md5(pg_get_functiondef(p.oid))) from pg_proc p join pg_namespace n on n.oid = p.pronamespace
     where n.nspname = 'public' and p.proname in ('hash_cena_quadrinho', 'hash_cena_atual_quadrinho', 'carregar_quadrinho_assets_aula', 'carregar_quadrinho_assets_admin', 'carregar_aula_publicada_da_missao', 'carregar_aula_rascunho_admin', 'eh_admin')) as h_funcoes,
  (select md5(string_agg(id::text || estrutura::text || status || numero_versao::text, '|' order by id)) from public.aula_versoes) as h_versoes,
  (select md5(string_agg(id::text || titulo || ativa::text, '|' order by id)) from public.aulas) as h_aulas,
  (select count(*) from public.matriculas) as n_matriculas,
  (select md5(string_agg(jobid::text || jobname || schedule || md5(command), '|' order by jobid)) from cron.job) as h_cron,
  (select md5(string_agg(name, '|' order by name)) from vault.secrets) as h_vault,
  (select md5(string_agg(table_name::text || grantee::text || privilege_type::text, '|' order by table_name::text, grantee::text, privilege_type::text))
     from information_schema.role_table_grants where table_schema = 'public') as h_grants_tabelas,
  (select count(*) from storage.objects where bucket_id = 'quadrinhos-aulas') as n_objetos_bucket;

-- >>> SECAO_PRECOND (identica no harness)
do $$
declare
  v_problemas text := '';
  v_colunas text;
  v_esperado text := 'id:uuid:NO,aula_versao_id:uuid:NO,componente_id:uuid:NO,quadro_indice:smallint:NO,scene_hash:text:NO,status:text:NO,storage_path:text:YES,modelo:text:YES,prompt_version:text:YES,prompt_visual:text:YES,tentativas:smallint:NO,lease_ate:timestamp with time zone:YES,erro_sanitizado:text:YES,aprovado_por:uuid:YES,aprovado_em:timestamp with time zone:YES,criado_em:timestamp with time zone:NO,atualizado_em:timestamp with time zone:NO';
  v_fn record;
begin
  if to_regclass('public.aula_quadrinho_assets') is null then
    raise exception 'PRECOND: fundacao Q9 ausente (public.aula_quadrinho_assets)';
  end if;

  select string_agg(column_name || ':' || data_type || ':' || is_nullable, ',' order by ordinal_position) into v_colunas
  from information_schema.columns where table_schema = 'public' and table_name = 'aula_quadrinho_assets';
  if v_colunas is distinct from v_esperado then
    v_problemas := v_problemas || 'colunas da tabela divergem da fundacao Q9 (' || coalesce(v_colunas, 'nenhuma') || '); ';
  end if;

  if (select count(*) from pg_constraint where conrelid = 'public.aula_quadrinho_assets'::regclass and contype = 'c') <> 7 then
    v_problemas := v_problemas || 'esperado 7 CHECKs da Q9; ';
  end if;

  -- as 4 funcoes da Q9 devem estar EXATAMENTE como foram validadas no LIVE
  for v_fn in
    select * from (values
      ('hash_cena_quadrinho', '2779b0d927b88a6946b31636dff13804'),
      ('hash_cena_atual_quadrinho', '0fd391aacd21da2eb83ad06ec38db44b'),
      ('carregar_quadrinho_assets_aula', 'ee2c134d44bdbb00e45f0973eb20e33b'),
      ('carregar_quadrinho_assets_admin', '4d6a052a6b05e49d585fe2c9360d3b84')
    ) as t(nome, md5_esperado)
  loop
    if (select count(*) from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public' and p.proname = v_fn.nome) <> 1
       or (select md5(pg_get_functiondef(p.oid)) from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public' and p.proname = v_fn.nome) is distinct from v_fn.md5_esperado then
      v_problemas := v_problemas || 'funcao da Q9 divergente/ausente: ' || v_fn.nome || '; ';
    end if;
  end loop;

  if not exists (select 1 from storage.buckets where id = 'quadrinhos-aulas' and public = false and file_size_limit = 262144 and allowed_mime_types = array['image/webp']) then
    v_problemas := v_problemas || 'bucket quadrinhos-aulas divergente/ausente; ';
  end if;
  if to_regprocedure('public.eh_admin()') is null then
    v_problemas := v_problemas || 'public.eh_admin() ausente; ';
  end if;

  -- nada deste pacote pode existir
  if exists (select 1 from information_schema.columns where table_schema = 'public' and table_name = 'aula_quadrinho_assets' and column_name in ('claim_token', 'storage_path_anterior')) then
    v_problemas := v_problemas || 'coluna deste pacote ja existe; ';
  end if;
  if exists (
    select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname in (
      'criar_jobs_quadrinho_admin', 'reservar_quadrinho_asset', 'concluir_quadrinho_asset', 'falhar_quadrinho_asset',
      'aprovar_quadrinho_asset_admin', 'rejeitar_quadrinho_asset_admin', 'regenerar_quadrinho_asset_admin',
      'preparar_exclusao_quadrinho_asset_admin', 'excluir_quadrinho_asset_admin',
      'quadrinho_asset_lease', 'quadrinho_componente', 'cena_atual_quadrinho', 'quadrinho_path_no_storage', 'quadrinho_asset_reiniciar')
  ) then
    v_problemas := v_problemas || 'ja existe funcao com nome reservado deste pacote; ';
  end if;
  if exists (select 1 from pg_constraint where conrelid = 'public.aula_quadrinho_assets'::regclass and conname in ('aula_quadrinho_assets_claim_coerente_check', 'aula_quadrinho_assets_path_anterior_check'))
     or to_regclass('public.aula_quadrinho_assets_path_anterior_key') is not null then
    v_problemas := v_problemas || 'constraint/indice deste pacote ja existe; ';
  end if;

  -- linhas existentes precisam caber no novo CHECK (gerando exige token, que ainda nao existe)
  if exists (select 1 from public.aula_quadrinho_assets where status = 'gerando' or lease_ate is not null) then
    v_problemas := v_problemas || 'ha linhas gerando/com lease incompativeis com o novo CHECK; ';
  end if;

  if v_problemas <> '' then
    raise exception 'PRECOND: %', v_problemas;
  end if;
  raise notice 'PRECOND OK: fundacao Q9 intacta, nada do pipeline existe';
end $$;
-- <<< SECAO_PRECOND

-- >>> SECAO_CORPO (identica no harness)
-- ================= 1) COLUNAS E CONSTRAINTS =================
alter table public.aula_quadrinho_assets
  add column claim_token uuid null,
  add column storage_path_anterior text null;

alter table public.aula_quadrinho_assets
  add constraint aula_quadrinho_assets_claim_coerente_check check (
    (status = 'gerando' and claim_token is not null and lease_ate is not null)
    or (status <> 'gerando' and claim_token is null and lease_ate is null)
  ),
  add constraint aula_quadrinho_assets_path_anterior_check check (
    storage_path_anterior is null
    or (length(btrim(storage_path_anterior)) > 0 and storage_path_anterior !~ '(^/|\.\.)' and storage_path_anterior is distinct from storage_path)
  );

create unique index aula_quadrinho_assets_path_anterior_key
  on public.aula_quadrinho_assets (storage_path_anterior)
  where storage_path_anterior is not null;

-- ================= 2) HELPERS INTERNOS (sem execute para clientes) =================
-- Configuração central do lease (único ponto de ajuste).
create function public.quadrinho_asset_lease()
returns interval
language sql
immutable
set search_path to ''
as $$ select interval '10 minutes' $$;

-- Componente quadrinho_didatico (jsonb) de uma versão, ou NULL.
create function public.quadrinho_componente(p_aula_versao_id uuid, p_componente_id uuid)
returns jsonb
language plpgsql
stable
set search_path to ''
as $$
declare
  v_comp jsonb;
begin
  if p_aula_versao_id is null or p_componente_id is null then return null; end if;
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
  return v_comp;
end;
$$;

-- Texto da cena ATUAL (NULL se versão/componente/índice/cena inválidos). O hash
-- dele é, por construção, o mesmo de hash_cena_atual_quadrinho (Q9).
create function public.cena_atual_quadrinho(p_aula_versao_id uuid, p_componente_id uuid, p_quadro_indice smallint)
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
  if p_quadro_indice is null or p_quadro_indice < 0 then return null; end if;
  v_comp := public.quadrinho_componente(p_aula_versao_id, p_componente_id);
  if v_comp is null then return null; end if;
  if jsonb_typeof(v_comp->'quadros') is distinct from 'array' then return null; end if;
  if p_quadro_indice >= jsonb_array_length(v_comp->'quadros') then return null; end if;
  v_quadro := v_comp->'quadros'->(p_quadro_indice::int);
  if jsonb_typeof(v_quadro) is distinct from 'object' then return null; end if;
  if jsonb_typeof(v_quadro->'cena') is distinct from 'string' then return null; end if;
  v_cena := v_quadro->>'cena';
  if length(btrim(v_cena, E' \t\r\n')) = 0 then return null; end if;
  return v_cena;
end;
$$;

-- O objeto existe de fato em storage.objects? (prova de "ainda existe / já removido")
create function public.quadrinho_path_no_storage(p_path text)
returns boolean
language sql
stable
set search_path to ''
as $$
  select p_path is not null and exists (
    select 1 from storage.objects o where o.bucket_id = 'quadrinhos-aulas' and o.name = p_path
  );
$$;

-- Reinicia um quadro (novo ciclo) SEM apagar arquivo: o path atual vai para
-- storage_path_anterior. O chamador já segura o lock da linha. Recusa se o anterior
-- (outro arquivo) ainda existir no Storage — nunca se perde o ponteiro de um
-- arquivo vivo. Devolve o path arquivado (ou NULL).
create function public.quadrinho_asset_reiniciar(p_asset_id uuid, p_scene_hash text)
returns text
language plpgsql
volatile
set search_path to ''
as $$
declare
  v_atual text;
  v_ant text;
begin
  select q.storage_path, q.storage_path_anterior into v_atual, v_ant
  from public.aula_quadrinho_assets q where q.id = p_asset_id;

  if v_atual is not null and v_ant is not null and v_ant is distinct from v_atual and public.quadrinho_path_no_storage(v_ant) then
    raise exception 'LIMPEZA_PENDENTE: o arquivo anterior (%) ainda existe no Storage; remova-o antes de reiniciar este quadro', v_ant;
  end if;

  update public.aula_quadrinho_assets q
  set storage_path_anterior = coalesce(v_atual, q.storage_path_anterior),
      storage_path = null,
      scene_hash = p_scene_hash,
      status = 'pendente',
      tentativas = 0,
      lease_ate = null,
      claim_token = null,
      erro_sanitizado = null,
      aprovado_por = null,
      aprovado_em = null,
      modelo = null,
      prompt_version = null,
      prompt_visual = null,
      atualizado_em = now()
  where q.id = p_asset_id;

  return v_atual;
end;
$$;

-- ================= 3) RPCs ADMIN (authenticated + eh_admin()) =================
-- Cria/sincroniza 1 job por quadro. Idempotente: hash igual => não mexe; hash
-- diferente => reinicia (arquivo anterior arquivado, nunca apagado).
create function public.criar_jobs_quadrinho_admin(p_aula_versao_id uuid, p_componente_id uuid)
returns table (indice smallint, acao text, status_job text, hash_cena text)
language plpgsql
volatile
security definer
set search_path to ''
as $$
declare
  v_comp jsonb;
  v_n int;
  i int;
  v_hash text;
  v_id uuid;
  v_row record;
begin
  if not public.eh_admin() then
    raise exception 'Apenas administradores podem criar jobs de arte de quadrinhos';
  end if;
  if not exists (select 1 from public.aula_versoes av where av.id = p_aula_versao_id) then
    raise exception 'Versao de aula nao encontrada';
  end if;
  v_comp := public.quadrinho_componente(p_aula_versao_id, p_componente_id);
  if v_comp is null then
    raise exception 'Componente quadrinho_didatico nao encontrado nesta versao';
  end if;
  if jsonb_typeof(v_comp->'quadros') is distinct from 'array' then
    raise exception 'Componente sem lista de quadros';
  end if;
  v_n := jsonb_array_length(v_comp->'quadros');
  if v_n < 3 or v_n > 6 then
    raise exception 'O quadrinho deve ter entre 3 e 6 quadros (encontrado %)', v_n;
  end if;
  for i in 0 .. v_n - 1 loop
    if public.cena_atual_quadrinho(p_aula_versao_id, p_componente_id, i::smallint) is null then
      raise exception 'Quadro % sem cena valida', i + 1;
    end if;
  end loop;

  for i in 0 .. v_n - 1 loop
    v_hash := public.hash_cena_quadrinho(public.cena_atual_quadrinho(p_aula_versao_id, p_componente_id, i::smallint));
    v_id := null;
    insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash)
    values (p_aula_versao_id, p_componente_id, i, v_hash)
    on conflict on constraint aula_quadrinho_assets_chave_key do nothing
    returning id into v_id;

    if v_id is not null then
      indice := i; acao := 'criado'; status_job := 'pendente'; hash_cena := v_hash;
      return next;
      continue;
    end if;

    select q.id, q.scene_hash, q.status, q.lease_ate into v_row
    from public.aula_quadrinho_assets q
    where q.aula_versao_id = p_aula_versao_id and q.componente_id = p_componente_id and q.quadro_indice = i
    for update;

    if v_row.scene_hash = v_hash then
      indice := i; acao := 'inalterado'; status_job := v_row.status; hash_cena := v_hash;
      return next;
      continue;
    end if;

    if v_row.status = 'gerando' and v_row.lease_ate > now() then
      raise exception 'Quadro % esta em geracao (lease ativo); aguarde antes de sincronizar', i + 1;
    end if;
    perform public.quadrinho_asset_reiniciar(v_row.id, v_hash);
    indice := i; acao := 'invalidado'; status_job := 'pendente'; hash_cena := v_hash;
    return next;
  end loop;

  -- linhas antigas fora do array atual: apenas informadas (nunca alteradas aqui)
  for v_row in
    select q.quadro_indice, q.status
    from public.aula_quadrinho_assets q
    where q.aula_versao_id = p_aula_versao_id and q.componente_id = p_componente_id and q.quadro_indice >= v_n
    order by q.quadro_indice
  loop
    indice := v_row.quadro_indice; acao := 'fora_do_array'; status_job := v_row.status; hash_cena := null;
    return next;
  end loop;
  return;
end;
$$;

create function public.aprovar_quadrinho_asset_admin(p_asset_id uuid)
returns table (asset_id uuid, status_final text, data_aprovacao timestamptz)
language plpgsql
volatile
security definer
set search_path to ''
as $$
declare
  v_row record;
  v_hash_atual text;
begin
  if not public.eh_admin() then
    raise exception 'Apenas administradores podem aprovar assets de quadrinhos';
  end if;
  select q.* into v_row from public.aula_quadrinho_assets q where q.id = p_asset_id for update;
  if not found then raise exception 'Asset nao encontrado'; end if;
  if v_row.status <> 'gerada' then
    raise exception 'Somente um asset gerado pode ser aprovado (status atual: %)', v_row.status;
  end if;
  if v_row.storage_path is null then
    raise exception 'Asset gerado sem storage_path';
  end if;
  v_hash_atual := public.hash_cena_atual_quadrinho(v_row.aula_versao_id, v_row.componente_id, v_row.quadro_indice);
  if v_hash_atual is distinct from v_row.scene_hash then
    raise exception 'CENA_ALTERADA: a cena mudou depois da geracao; regenere a arte antes de aprovar';
  end if;

  update public.aula_quadrinho_assets q
  set status = 'aprovada', aprovado_por = auth.uid(), aprovado_em = now(), atualizado_em = now()
  where q.id = p_asset_id;

  asset_id := p_asset_id; status_final := 'aprovada'; data_aprovacao := now();
  return next;
end;
$$;

create function public.rejeitar_quadrinho_asset_admin(p_asset_id uuid)
returns table (asset_id uuid, status_final text, path_atual text)
language plpgsql
volatile
security definer
set search_path to ''
as $$
declare
  v_row record;
begin
  if not public.eh_admin() then
    raise exception 'Apenas administradores podem rejeitar assets de quadrinhos';
  end if;
  select q.* into v_row from public.aula_quadrinho_assets q where q.id = p_asset_id for update;
  if not found then raise exception 'Asset nao encontrado'; end if;
  if v_row.status not in ('gerada', 'aprovada') then
    raise exception 'Somente um asset gerado ou aprovado pode ser rejeitado (status atual: %)', v_row.status;
  end if;

  -- o arquivo permanece (inspeção/limpeza posterior); só deixa de ser servido
  update public.aula_quadrinho_assets q
  set status = 'rejeitada', aprovado_por = null, aprovado_em = null, atualizado_em = now()
  where q.id = p_asset_id;

  asset_id := p_asset_id; status_final := 'rejeitada'; path_atual := v_row.storage_path;
  return next;
end;
$$;

-- Novo ciclo de geração. Não interfere em job com lease válido. Devolve o path
-- anterior para a futura limpeza segura (nada é apagado aqui).
create function public.regenerar_quadrinho_asset_admin(p_asset_id uuid)
returns table (asset_id uuid, status_final text, hash_cena text, path_anterior text)
language plpgsql
volatile
security definer
set search_path to ''
as $$
declare
  v_row record;
  v_hash text;
  v_ant text;
begin
  if not public.eh_admin() then
    raise exception 'Apenas administradores podem regenerar assets de quadrinhos';
  end if;
  select q.* into v_row from public.aula_quadrinho_assets q where q.id = p_asset_id for update;
  if not found then raise exception 'Asset nao encontrado'; end if;
  if v_row.status = 'gerando' and v_row.lease_ate > now() then
    raise exception 'Asset em geracao (lease ativo); aguarde o termino ou a expiracao do lease';
  end if;
  v_hash := public.hash_cena_atual_quadrinho(v_row.aula_versao_id, v_row.componente_id, v_row.quadro_indice);
  if v_hash is null then
    raise exception 'A cena atual deste quadro nao existe mais na estrutura; sincronize os jobs do componente';
  end if;

  perform public.quadrinho_asset_reiniciar(p_asset_id, v_hash);
  select q.storage_path_anterior into v_ant from public.aula_quadrinho_assets q where q.id = p_asset_id;

  asset_id := p_asset_id; status_final := 'pendente'; hash_cena := v_hash; path_anterior := v_ant;
  return next;
end;
$$;

-- Exclusão em 2 fases (banco + Storage não são atômicos):
--   1) preparar_exclusao: tira o asset de circulação (rejeitada) e devolve os paths;
--   2) a Edge admin remove os objetos;
--   3) excluir: só apaga a linha se NENHUM dos paths ainda existir em storage.objects.
create function public.preparar_exclusao_quadrinho_asset_admin(p_asset_id uuid)
returns table (asset_id uuid, status_final text, path_atual text, path_anterior text)
language plpgsql
volatile
security definer
set search_path to ''
as $$
declare
  v_row record;
begin
  if not public.eh_admin() then
    raise exception 'Apenas administradores podem excluir assets de quadrinhos';
  end if;
  select q.* into v_row from public.aula_quadrinho_assets q where q.id = p_asset_id for update;
  if not found then raise exception 'Asset nao encontrado'; end if;
  if v_row.status = 'gerando' and v_row.lease_ate > now() then
    raise exception 'Asset em geracao (lease ativo); aguarde o termino ou a expiracao do lease';
  end if;

  if v_row.status in ('gerada', 'aprovada') then
    update public.aula_quadrinho_assets q
    set status = 'rejeitada', aprovado_por = null, aprovado_em = null, atualizado_em = now()
    where q.id = p_asset_id;
    v_row.status := 'rejeitada';
  elsif v_row.status = 'gerando' then
    update public.aula_quadrinho_assets q
    set status = 'erro', erro_sanitizado = 'exclusao solicitada', lease_ate = null, claim_token = null, atualizado_em = now()
    where q.id = p_asset_id;
    v_row.status := 'erro';
  end if;

  asset_id := p_asset_id; status_final := v_row.status; path_atual := v_row.storage_path; path_anterior := v_row.storage_path_anterior;
  return next;
end;
$$;

create function public.excluir_quadrinho_asset_admin(p_asset_id uuid)
returns table (asset_id uuid, excluido boolean)
language plpgsql
volatile
security definer
set search_path to ''
as $$
declare
  v_row record;
begin
  if not public.eh_admin() then
    raise exception 'Apenas administradores podem excluir assets de quadrinhos';
  end if;
  select q.* into v_row from public.aula_quadrinho_assets q where q.id = p_asset_id for update;
  if not found then raise exception 'Asset nao encontrado'; end if;
  if v_row.status = 'gerando' and v_row.lease_ate > now() then
    raise exception 'Asset em geracao (lease ativo); aguarde o termino ou a expiracao do lease';
  end if;
  if public.quadrinho_path_no_storage(v_row.storage_path) then
    raise exception 'ARQUIVO_AINDA_EXISTE: remova % do Storage antes de excluir a linha', v_row.storage_path;
  end if;
  if public.quadrinho_path_no_storage(v_row.storage_path_anterior) then
    raise exception 'ARQUIVO_AINDA_EXISTE: remova % do Storage antes de excluir a linha', v_row.storage_path_anterior;
  end if;

  delete from public.aula_quadrinho_assets q where q.id = p_asset_id;
  asset_id := p_asset_id; excluido := true;
  return next;
end;
$$;

-- ================= 4) RPCs DO WORKER (somente service_role) =================
-- Reserva UM job (pendente, ou gerando com lease expirado) com SKIP LOCKED.
-- Devolve só o necessário à geração: nunca a aula, questões, gabaritos ou dados pessoais.
create function public.reservar_quadrinho_asset(p_aula_versao_id uuid default null)
returns table (
  asset_id uuid,
  aula_versao_id uuid,
  componente_id uuid,
  quadro_indice smallint,
  scene_hash text,
  cena text,
  tentativa smallint,
  claim_token uuid,
  lease_ate timestamptz,
  storage_path_esperado text
)
language plpgsql
volatile
security definer
set search_path to ''
as $$
#variable_conflict use_column
declare
  v_row record;
  v_cena text;
  v_token uuid;
  v_lease_ate timestamptz;
begin
  -- 1) lease expirado sem tentativas restantes: encerra como erro (nunca fica trancado)
  update public.aula_quadrinho_assets q
  set status = 'erro', erro_sanitizado = 'tempo limite excedido sem tentativas restantes',
      lease_ate = null, claim_token = null, atualizado_em = now()
  where q.id in (
    select x.id from public.aula_quadrinho_assets x
    where x.status = 'gerando' and x.lease_ate < now() and x.tentativas >= 3
      and (p_aula_versao_id is null or x.aula_versao_id = p_aula_versao_id)
    for update skip locked
  );

  loop
    select q.* into v_row
    from public.aula_quadrinho_assets q
    where (p_aula_versao_id is null or q.aula_versao_id = p_aula_versao_id)
      and q.tentativas < 3
      and (q.status = 'pendente' or (q.status = 'gerando' and q.lease_ate < now()))
    order by q.criado_em, q.aula_versao_id, q.componente_id, q.quadro_indice
    limit 1
    for update skip locked;

    if not found then return; end if;

    -- nunca gerar para uma cena que mudou (ou sumiu)
    v_cena := public.cena_atual_quadrinho(v_row.aula_versao_id, v_row.componente_id, v_row.quadro_indice);
    if v_cena is null or public.hash_cena_quadrinho(v_cena) is distinct from v_row.scene_hash then
      update public.aula_quadrinho_assets q
      set status = 'erro', erro_sanitizado = 'cena alterada; sincronize os jobs do componente',
          lease_ate = null, claim_token = null, atualizado_em = now()
      where q.id = v_row.id;
      continue;
    end if;

    v_token := gen_random_uuid();
    v_lease_ate := now() + public.quadrinho_asset_lease();
    update public.aula_quadrinho_assets q
    set status = 'gerando', tentativas = q.tentativas + 1, claim_token = v_token, lease_ate = v_lease_ate, atualizado_em = now()
    where q.id = v_row.id;

    asset_id := v_row.id;
    aula_versao_id := v_row.aula_versao_id;
    componente_id := v_row.componente_id;
    quadro_indice := v_row.quadro_indice;
    scene_hash := v_row.scene_hash;
    cena := v_cena;
    tentativa := (v_row.tentativas + 1)::smallint;
    claim_token := v_token;
    lease_ate := v_lease_ate;
    storage_path_esperado := v_row.aula_versao_id::text || '/' || v_row.componente_id::text || '/' || v_row.quadro_indice::text
      || '/' || left(v_row.scene_hash, 10) || '-' || v_token::text || '.webp';
    return next;
    return;
  end loop;
end;
$$;

-- Conclui a geração. FENCING: só o dono atual do claim_token conclui. Resultado
-- obsoleto (cena mudou) é recusado com aceito=false — o chamador então remove o
-- arquivo que acabou de enviar. Mesmo path já concluído => idempotente.
create function public.concluir_quadrinho_asset(
  p_asset_id uuid, p_claim_token uuid, p_scene_hash text, p_storage_path text,
  p_modelo text, p_prompt_version text, p_prompt_visual text
)
returns table (aceito boolean, motivo text, status_final text)
language plpgsql
volatile
security definer
set search_path to ''
as $$
declare
  v_row record;
  v_esperado text;
  v_cena text;
begin
  if p_asset_id is null or p_claim_token is null then
    raise exception 'asset_id e claim_token sao obrigatorios';
  end if;
  if p_storage_path is null or length(btrim(p_storage_path)) = 0 then
    raise exception 'storage_path obrigatorio';
  end if;
  if coalesce(length(btrim(p_modelo)), 0) = 0 or coalesce(length(btrim(p_prompt_version)), 0) = 0 or coalesce(length(btrim(p_prompt_visual)), 0) = 0 then
    raise exception 'modelo, prompt_version e prompt_visual sao obrigatorios (auditoria)';
  end if;
  if length(p_prompt_visual) > 8000 then
    raise exception 'prompt_visual excede 8000 caracteres';
  end if;

  select q.* into v_row from public.aula_quadrinho_assets q where q.id = p_asset_id for update;
  if not found then
    aceito := false; motivo := 'asset_inexistente'; status_final := null;
    return next; return;
  end if;

  if v_row.status = 'gerada' and v_row.storage_path = p_storage_path then
    aceito := true; motivo := 'ja_concluido'; status_final := 'gerada';
    return next; return;
  end if;
  if v_row.status <> 'gerando' or v_row.claim_token is distinct from p_claim_token then
    aceito := false; motivo := 'claim_invalido'; status_final := v_row.status;
    return next; return;
  end if;

  if p_scene_hash is distinct from v_row.scene_hash then
    raise exception 'scene_hash informado difere do scene_hash do job';
  end if;
  v_esperado := v_row.aula_versao_id::text || '/' || v_row.componente_id::text || '/' || v_row.quadro_indice::text
    || '/' || left(v_row.scene_hash, 10) || '-' || p_claim_token::text || '.webp';
  if p_storage_path <> v_esperado then
    raise exception 'storage_path fora do padrao esperado para este claim';
  end if;

  v_cena := public.cena_atual_quadrinho(v_row.aula_versao_id, v_row.componente_id, v_row.quadro_indice);
  if v_cena is null or public.hash_cena_quadrinho(v_cena) is distinct from v_row.scene_hash then
    update public.aula_quadrinho_assets q
    set status = 'erro', erro_sanitizado = 'cena alterada durante a geracao; sincronize os jobs do componente',
        lease_ate = null, claim_token = null, atualizado_em = now()
    where q.id = p_asset_id;
    aceito := false; motivo := 'cena_alterada'; status_final := 'erro';
    return next; return;
  end if;

  update public.aula_quadrinho_assets q
  set status = 'gerada', storage_path = p_storage_path, modelo = p_modelo, prompt_version = p_prompt_version,
      prompt_visual = p_prompt_visual, lease_ate = null, claim_token = null, erro_sanitizado = null, atualizado_em = now()
  where q.id = p_asset_id;

  aceito := true; motivo := 'concluido'; status_final := 'gerada';
  return next;
end;
$$;

-- Registra falha. FENCING igual ao concluir. Guarda SÓ erro sanitizado (defesa em
-- profundidade: a Edge já sanitiza; aqui se remove chave/Bearer/JWT/base64 e se
-- limita a 300 caracteres). Retry: tentativas < 3 => volta a `pendente`; senão `erro`.
create function public.falhar_quadrinho_asset(p_asset_id uuid, p_claim_token uuid, p_erro text)
returns table (aceito boolean, motivo text, status_final text, tentativas_usadas smallint)
language plpgsql
volatile
security definer
set search_path to ''
as $$
declare
  v_row record;
  v_erro text;
  v_final text;
begin
  if p_asset_id is null or p_claim_token is null then
    raise exception 'asset_id e claim_token sao obrigatorios';
  end if;
  select q.* into v_row from public.aula_quadrinho_assets q where q.id = p_asset_id for update;
  if not found then
    aceito := false; motivo := 'asset_inexistente'; status_final := null; tentativas_usadas := null;
    return next; return;
  end if;
  if v_row.status <> 'gerando' or v_row.claim_token is distinct from p_claim_token then
    aceito := false; motivo := 'claim_invalido'; status_final := v_row.status; tentativas_usadas := v_row.tentativas;
    return next; return;
  end if;

  v_erro := coalesce(nullif(btrim(p_erro), ''), 'erro desconhecido');
  v_erro := regexp_replace(v_erro, 'sk-[A-Za-z0-9_-]{8,}', '[chave]', 'g');
  v_erro := regexp_replace(v_erro, 'Bearer\s+[A-Za-z0-9._~+/=-]+', 'Bearer [token]', 'gi');
  v_erro := regexp_replace(v_erro, 'eyJ[A-Za-z0-9_-]{10,}(\.[A-Za-z0-9_-]+)*', '[jwt]', 'g');
  v_erro := regexp_replace(v_erro, '[A-Za-z0-9+/]{80,}={0,2}', '[dados]', 'g');
  v_erro := regexp_replace(v_erro, '[\r\n]+', ' ', 'g');
  v_erro := left(v_erro, 300);

  v_final := case when v_row.tentativas < 3 then 'pendente' else 'erro' end;
  update public.aula_quadrinho_assets q
  set status = v_final, erro_sanitizado = v_erro, lease_ate = null, claim_token = null, atualizado_em = now()
  where q.id = p_asset_id;

  aceito := true; motivo := 'falha_registrada'; status_final := v_final; tentativas_usadas := v_row.tentativas;
  return next;
end;
$$;

-- ================= 5) GRANTS =================
revoke all on function public.quadrinho_asset_lease() from public, anon, authenticated;
revoke all on function public.quadrinho_componente(uuid, uuid) from public, anon, authenticated;
revoke all on function public.cena_atual_quadrinho(uuid, uuid, smallint) from public, anon, authenticated;
revoke all on function public.quadrinho_path_no_storage(text) from public, anon, authenticated;
revoke all on function public.quadrinho_asset_reiniciar(uuid, text) from public, anon, authenticated;

revoke all on function public.reservar_quadrinho_asset(uuid) from public, anon, authenticated;
revoke all on function public.concluir_quadrinho_asset(uuid, uuid, text, text, text, text, text) from public, anon, authenticated;
revoke all on function public.falhar_quadrinho_asset(uuid, uuid, text) from public, anon, authenticated;
grant execute on function public.reservar_quadrinho_asset(uuid) to service_role;
grant execute on function public.concluir_quadrinho_asset(uuid, uuid, text, text, text, text, text) to service_role;
grant execute on function public.falhar_quadrinho_asset(uuid, uuid, text) to service_role;

revoke all on function public.criar_jobs_quadrinho_admin(uuid, uuid) from public, anon;
revoke all on function public.aprovar_quadrinho_asset_admin(uuid) from public, anon;
revoke all on function public.rejeitar_quadrinho_asset_admin(uuid) from public, anon;
revoke all on function public.regenerar_quadrinho_asset_admin(uuid) from public, anon;
revoke all on function public.preparar_exclusao_quadrinho_asset_admin(uuid) from public, anon;
revoke all on function public.excluir_quadrinho_asset_admin(uuid) from public, anon;
grant execute on function public.criar_jobs_quadrinho_admin(uuid, uuid) to authenticated;
grant execute on function public.aprovar_quadrinho_asset_admin(uuid) to authenticated;
grant execute on function public.rejeitar_quadrinho_asset_admin(uuid) to authenticated;
grant execute on function public.regenerar_quadrinho_asset_admin(uuid) to authenticated;
grant execute on function public.preparar_exclusao_quadrinho_asset_admin(uuid) to authenticated;
grant execute on function public.excluir_quadrinho_asset_admin(uuid) to authenticated;
-- <<< SECAO_CORPO

-- >>> SECAO_POSCOND (identica no harness)
do $$
declare
  v_rel oid := 'public.aula_quadrinho_assets'::regclass;
  v_colunas text;
  v_esperado text := 'id:uuid:NO,aula_versao_id:uuid:NO,componente_id:uuid:NO,quadro_indice:smallint:NO,scene_hash:text:NO,status:text:NO,storage_path:text:YES,modelo:text:YES,prompt_version:text:YES,prompt_visual:text:YES,tentativas:smallint:NO,lease_ate:timestamp with time zone:YES,erro_sanitizado:text:YES,aprovado_por:uuid:YES,aprovado_em:timestamp with time zone:YES,criado_em:timestamp with time zone:NO,atualizado_em:timestamp with time zone:NO,claim_token:uuid:YES,storage_path_anterior:text:YES';
  v_fn text;
  v_papel text;
  v_priv text;
  v_q9 record;
begin
  select string_agg(column_name || ':' || data_type || ':' || is_nullable, ',' order by ordinal_position) into v_colunas
  from information_schema.columns where table_schema = 'public' and table_name = 'aula_quadrinho_assets';
  if v_colunas is distinct from v_esperado then raise exception 'POSCOND: colunas divergem: %', v_colunas; end if;

  if (select count(*) from pg_constraint where conrelid = v_rel and contype = 'c') <> 9 then raise exception 'POSCOND: esperado 9 CHECKs'; end if;
  if not exists (select 1 from pg_constraint where conrelid = v_rel and conname = 'aula_quadrinho_assets_claim_coerente_check') then raise exception 'POSCOND: check de claim'; end if;
  if not exists (select 1 from pg_constraint where conrelid = v_rel and conname = 'aula_quadrinho_assets_path_anterior_check') then raise exception 'POSCOND: check de path anterior'; end if;
  if not exists (select 1 from pg_indexes where schemaname = 'public' and tablename = 'aula_quadrinho_assets' and indexname = 'aula_quadrinho_assets_path_anterior_key' and indexdef ilike '%UNIQUE%(storage_path_anterior)%WHERE%storage_path_anterior IS NOT NULL%') then
    raise exception 'POSCOND: indice unico parcial de storage_path_anterior';
  end if;

  -- fundacao Q9 intacta
  if not (select relrowsecurity from pg_class where oid = v_rel) then raise exception 'POSCOND: RLS'; end if;
  if exists (select 1 from pg_policies where schemaname = 'public' and tablename = 'aula_quadrinho_assets') then raise exception 'POSCOND: policy na tabela'; end if;
  foreach v_papel in array array['anon', 'authenticated'] loop
    foreach v_priv in array array['select', 'insert', 'update', 'delete', 'truncate', 'references', 'trigger'] loop
      if has_table_privilege(v_papel, v_rel, v_priv) then raise exception 'POSCOND: % tem % direto na tabela', v_papel, v_priv; end if;
    end loop;
  end loop;
  for v_q9 in
    select * from (values
      ('hash_cena_quadrinho', '2779b0d927b88a6946b31636dff13804'),
      ('hash_cena_atual_quadrinho', '0fd391aacd21da2eb83ad06ec38db44b'),
      ('carregar_quadrinho_assets_aula', 'ee2c134d44bdbb00e45f0973eb20e33b'),
      ('carregar_quadrinho_assets_admin', '4d6a052a6b05e49d585fe2c9360d3b84')
    ) as t(nome, md5_esperado)
  loop
    if (select md5(pg_get_functiondef(p.oid)) from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public' and p.proname = v_q9.nome) is distinct from v_q9.md5_esperado then
      raise exception 'POSCOND: funcao da Q9 alterada: %', v_q9.nome;
    end if;
  end loop;
  if not exists (select 1 from storage.buckets where id = 'quadrinhos-aulas' and public = false and file_size_limit = 262144 and allowed_mime_types = array['image/webp']) then raise exception 'POSCOND: bucket'; end if;
  if exists (select 1 from pg_policies where schemaname = 'storage' and tablename = 'objects' and (coalesce(qual, '') || ' ' || coalesce(with_check, '')) like '%quadrinhos-aulas%') then raise exception 'POSCOND: policy de storage para o bucket'; end if;

  -- helpers: fechados para clientes
  foreach v_fn in array array['public.quadrinho_asset_lease()', 'public.quadrinho_componente(uuid,uuid)', 'public.cena_atual_quadrinho(uuid,uuid,smallint)', 'public.quadrinho_path_no_storage(text)', 'public.quadrinho_asset_reiniciar(uuid,text)'] loop
    foreach v_papel in array array['anon', 'authenticated'] loop
      if has_function_privilege(v_papel, v_fn::regprocedure, 'execute') then raise exception 'POSCOND: % executa helper %', v_papel, v_fn; end if;
    end loop;
  end loop;

  -- worker: só service_role; SECURITY DEFINER; search_path vazio
  foreach v_fn in array array['public.reservar_quadrinho_asset(uuid)', 'public.concluir_quadrinho_asset(uuid,uuid,text,text,text,text,text)', 'public.falhar_quadrinho_asset(uuid,uuid,text)'] loop
    foreach v_papel in array array['anon', 'authenticated'] loop
      if has_function_privilege(v_papel, v_fn::regprocedure, 'execute') then raise exception 'POSCOND: % executa RPC de worker %', v_papel, v_fn; end if;
    end loop;
    if not has_function_privilege('service_role', v_fn::regprocedure, 'execute') then raise exception 'POSCOND: service_role sem execute em %', v_fn; end if;
    if not (select p.prosecdef from pg_proc p where p.oid = v_fn::regprocedure) then raise exception 'POSCOND: % deveria ser SECURITY DEFINER', v_fn; end if;
    if not exists (select 1 from pg_proc p where p.oid = v_fn::regprocedure and p.proconfig @> array['search_path=""']) then raise exception 'POSCOND: % sem search_path vazio', v_fn; end if;
  end loop;

  -- admin: authenticated (não anon); SECURITY DEFINER; search_path vazio; eh_admin
  foreach v_fn in array array['public.criar_jobs_quadrinho_admin(uuid,uuid)', 'public.aprovar_quadrinho_asset_admin(uuid)', 'public.rejeitar_quadrinho_asset_admin(uuid)', 'public.regenerar_quadrinho_asset_admin(uuid)', 'public.preparar_exclusao_quadrinho_asset_admin(uuid)', 'public.excluir_quadrinho_asset_admin(uuid)'] loop
    if has_function_privilege('anon', v_fn::regprocedure, 'execute') then raise exception 'POSCOND: anon executa %', v_fn; end if;
    if not has_function_privilege('authenticated', v_fn::regprocedure, 'execute') then raise exception 'POSCOND: authenticated sem execute em %', v_fn; end if;
    if not (select p.prosecdef from pg_proc p where p.oid = v_fn::regprocedure) then raise exception 'POSCOND: % deveria ser SECURITY DEFINER', v_fn; end if;
    if not exists (select 1 from pg_proc p where p.oid = v_fn::regprocedure and p.proconfig @> array['search_path=""']) then raise exception 'POSCOND: % sem search_path vazio', v_fn; end if;
    if position('public.eh_admin()' in pg_get_functiondef(v_fn::regprocedure)) = 0 then raise exception 'POSCOND: % sem eh_admin()', v_fn; end if;
  end loop;

  if public.quadrinho_asset_lease() <> interval '10 minutes' then raise exception 'POSCOND: lease'; end if;
  raise notice 'POSCOND OK: colunas, CHECKs, indice, funcoes, grants e fundacao Q9 intactos';
end $$;
-- <<< SECAO_POSCOND

-- ============================================================================
-- V) ESCOPO: só o pacote do pipeline foi criado; fundação Q9 e o resto intactos
-- ============================================================================
do $$
declare
  v_snap record;
  v_novas_rel text[];
  v_novas_fn text[];
begin
  select * into v_snap from _q10_snap_estado;

  select array_agg(c.relname::text) into v_novas_rel
  from pg_class c join pg_namespace n on n.oid = c.relnamespace
  where n.nspname = 'public' and c.relname::text not in (select nome from _q10_snap_rel);
  perform pg_temp.q10_reg('escopo_unica_relacao_nova_e_o_indice', v_novas_rel = array['aula_quadrinho_assets_path_anterior_key']);

  select array_agg(p.proname::text) into v_novas_fn
  from pg_proc p join pg_namespace n on n.oid = p.pronamespace
  where n.nspname = 'public' and p.oid::text not in (select nome from _q10_snap_fn);
  perform pg_temp.q10_reg('escopo_funcoes_novas_exatas',
    v_novas_fn @> array['criar_jobs_quadrinho_admin', 'reservar_quadrinho_asset', 'concluir_quadrinho_asset', 'falhar_quadrinho_asset',
      'aprovar_quadrinho_asset_admin', 'rejeitar_quadrinho_asset_admin', 'regenerar_quadrinho_asset_admin',
      'preparar_exclusao_quadrinho_asset_admin', 'excluir_quadrinho_asset_admin',
      'quadrinho_asset_lease', 'quadrinho_componente', 'cena_atual_quadrinho', 'quadrinho_path_no_storage', 'quadrinho_asset_reiniciar']
    and cardinality(v_novas_fn) = 14);

  perform pg_temp.q10_reg('escopo_nenhuma_policy_nova_ou_removida',
    not exists (select schemaname::text || '.' || tablename::text || '.' || policyname::text from pg_policies except select nome from _q10_snap_pol)
    and not exists (select nome from _q10_snap_pol except select schemaname::text || '.' || tablename::text || '.' || policyname::text from pg_policies));
  perform pg_temp.q10_reg('escopo_bucket_intacto',
    not exists (select id::text || ':' || public::text || ':' || coalesce(file_size_limit::text, '') || ':' || coalesce(allowed_mime_types::text, '') from storage.buckets except select nome from _q10_snap_bucket)
    and not exists (select nome from _q10_snap_bucket except select id::text || ':' || public::text || ':' || coalesce(file_size_limit::text, '') || ':' || coalesce(allowed_mime_types::text, '') from storage.buckets));
  perform pg_temp.q10_reg('escopo_funcoes_q9_e_rpcs_existentes_intactas',
    v_snap.h_funcoes = (select jsonb_object_agg(p.proname, md5(pg_get_functiondef(p.oid))) from pg_proc p join pg_namespace n on n.oid = p.pronamespace
      where n.nspname = 'public' and p.proname in ('hash_cena_quadrinho', 'hash_cena_atual_quadrinho', 'carregar_quadrinho_assets_aula', 'carregar_quadrinho_assets_admin', 'carregar_aula_publicada_da_missao', 'carregar_aula_rascunho_admin', 'eh_admin')));
  perform pg_temp.q10_reg('escopo_colunas_q9_preservadas_em_ordem_e_2_novas',
    (select string_agg(column_name || ':' || data_type || ':' || is_nullable, ',' order by ordinal_position)
       from information_schema.columns where table_schema = 'public' and table_name = 'aula_quadrinho_assets')
    = v_snap.colunas || ',claim_token:uuid:YES,storage_path_anterior:text:YES');
  perform pg_temp.q10_reg('escopo_constraints_q9_preservadas_e_2_novas',
    not exists (select nome from _q10_snap_cons except select conname::text from pg_constraint where conrelid = 'public.aula_quadrinho_assets'::regclass)
    and (select count(*) from pg_constraint where conrelid = 'public.aula_quadrinho_assets'::regclass) = (select count(*) from _q10_snap_cons) + 2);
  perform pg_temp.q10_reg('escopo_versoes_aulas_cron_vault_intactos',
    v_snap.h_versoes is not distinct from (select md5(string_agg(id::text || estrutura::text || status || numero_versao::text, '|' order by id)) from public.aula_versoes)
    and v_snap.h_aulas is not distinct from (select md5(string_agg(id::text || titulo || ativa::text, '|' order by id)) from public.aulas)
    and v_snap.h_cron is not distinct from (select md5(string_agg(jobid::text || jobname || schedule || md5(command), '|' order by jobid)) from cron.job)
    and v_snap.h_vault is not distinct from (select md5(string_agg(name, '|' order by name)) from vault.secrets)
    and v_snap.n_matriculas = (select count(*) from public.matriculas));
  perform pg_temp.q10_reg('escopo_tabela_continua_vazia_e_sem_objetos_no_bucket',
    (select count(*) from public.aula_quadrinho_assets) = 0 and (select count(*) from storage.objects where bucket_id = 'quadrinhos-aulas') = 0);
  perform pg_temp.q10_reg('lease_e_10_minutos', public.quadrinho_asset_lease() = interval '10 minutes');
end $$;

-- ============================================================================
-- CONSTRAINTS NOVAS (violações provocadas; a tabela é esvaziada no fim)
-- ============================================================================
do $$
declare
  v_p constant uuid := '52756262-8be4-4fb2-a9f3-2f5a158ea1d4';
  v_h constant text := repeat('a', 64);
  v_ok boolean;
begin
  perform pg_temp.q10_reg('check_gerando_exige_token_e_lease', pg_temp.q10_raises(
    format('insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash, status) values (%L, gen_random_uuid(), 0, %L, ''gerando'')', v_p, v_h), '%claim_coerente_check%'));
  perform pg_temp.q10_reg('check_gerando_sem_token_mesmo_com_lease', pg_temp.q10_raises(
    format('insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash, status, lease_ate) values (%L, gen_random_uuid(), 0, %L, ''gerando'', now())', v_p, v_h), '%claim_coerente_check%'));
  perform pg_temp.q10_reg('check_nao_gerando_nao_pode_ter_token', pg_temp.q10_raises(
    format('insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash, claim_token) values (%L, gen_random_uuid(), 0, %L, gen_random_uuid())', v_p, v_h), '%claim_coerente_check%'));
  perform pg_temp.q10_reg('check_nao_gerando_nao_pode_ter_lease', pg_temp.q10_raises(
    format('insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash, lease_ate) values (%L, gen_random_uuid(), 0, %L, now())', v_p, v_h), '%claim_coerente_check%'));

  v_ok := true;
  begin
    insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash, status, claim_token, lease_ate)
      values (v_p, gen_random_uuid(), 0, v_h, 'gerando', gen_random_uuid(), now() + interval '1 minute');
  exception when others then v_ok := false; end;
  perform pg_temp.q10_reg('check_gerando_completo_aceito', v_ok);

  perform pg_temp.q10_reg('check_path_anterior_diferente_do_atual', pg_temp.q10_raises(
    format('insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash, status, storage_path, storage_path_anterior) values (%L, gen_random_uuid(), 0, %L, ''rejeitada'', ''q10/x.webp'', ''q10/x.webp'')', v_p, v_h), '%path_anterior_check%'));
  perform pg_temp.q10_reg('check_path_anterior_rejeita_dotdot', pg_temp.q10_raises(
    format('insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash, storage_path_anterior) values (%L, gen_random_uuid(), 0, %L, ''../fuga.webp'')', v_p, v_h), '%path_anterior_check%'));
  perform pg_temp.q10_reg('check_path_anterior_rejeita_absoluto', pg_temp.q10_raises(
    format('insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash, storage_path_anterior) values (%L, gen_random_uuid(), 0, %L, ''/abs.webp'')', v_p, v_h), '%path_anterior_check%'));

  insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash, storage_path_anterior) values (v_p, gen_random_uuid(), 1, v_h, 'q10-ant/a.webp');
  perform pg_temp.q10_reg('unique_parcial_path_anterior', pg_temp.q10_raises(
    format('insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash, storage_path_anterior) values (%L, gen_random_uuid(), 2, %L, ''q10-ant/a.webp'')', v_p, v_h), '%path_anterior_key%'));

  delete from public.aula_quadrinho_assets;
end $$;

-- ============================================================================
-- GRANTS REAIS (SET LOCAL ROLE), sem jobs ainda
-- ============================================================================
create temporary table _q10_papeis (chave text primary key, ok boolean);

do $$
declare
  v_ok boolean;
  v_n int;
begin
  v_ok := false;
  begin set local role authenticated; perform * from public.reservar_quadrinho_asset(); exception when insufficient_privilege then v_ok := true; end;
  reset role; insert into _q10_papeis values ('authenticated_nao_executa_reservar', v_ok);

  v_ok := false;
  begin set local role authenticated; perform * from public.concluir_quadrinho_asset(gen_random_uuid(), gen_random_uuid(), repeat('a', 64), 'x/y.webp', 'm', 'p', 'v'); exception when insufficient_privilege then v_ok := true; end;
  reset role; insert into _q10_papeis values ('authenticated_nao_executa_concluir', v_ok);

  v_ok := false;
  begin set local role authenticated; perform * from public.falhar_quadrinho_asset(gen_random_uuid(), gen_random_uuid(), 'x'); exception when insufficient_privilege then v_ok := true; end;
  reset role; insert into _q10_papeis values ('authenticated_nao_executa_falhar', v_ok);

  v_ok := false;
  begin set local role anon; perform * from public.reservar_quadrinho_asset(); exception when insufficient_privilege then v_ok := true; end;
  reset role; insert into _q10_papeis values ('anon_nao_executa_reservar', v_ok);

  v_ok := false;
  begin set local role anon; perform * from public.criar_jobs_quadrinho_admin(gen_random_uuid(), gen_random_uuid()); exception when insufficient_privilege then v_ok := true; end;
  reset role; insert into _q10_papeis values ('anon_nao_executa_rpc_admin', v_ok);

  v_ok := false;
  begin set local role authenticated; perform public.quadrinho_asset_lease(); exception when insufficient_privilege then v_ok := true; end;
  reset role; insert into _q10_papeis values ('authenticated_nao_executa_helper', v_ok);

  v_ok := false;
  begin set local role authenticated; perform public.quadrinho_asset_reiniciar(gen_random_uuid(), repeat('a', 64)); exception when insufficient_privilege then v_ok := true; end;
  reset role; insert into _q10_papeis values ('authenticated_nao_executa_reiniciar', v_ok);

  v_ok := false;
  begin
    set local role service_role;
    select count(*) into v_n from public.reservar_quadrinho_asset();
    v_ok := (v_n = 0);
  exception when others then v_ok := false; end;
  reset role; insert into _q10_papeis values ('service_role_executa_reservar_sem_jobs_retorna_vazio', v_ok);

  v_ok := false;
  begin
    set local role authenticated;
    perform set_config('request.jwt.claim.sub', gen_random_uuid()::text, true);
    perform * from public.criar_jobs_quadrinho_admin(gen_random_uuid(), gen_random_uuid());
  exception when others then v_ok := sqlerrm like 'Apenas administradores%'; end;
  reset role; insert into _q10_papeis values ('authenticated_nao_admin_bloqueado_via_eh_admin', v_ok);
end $$;

insert into teste_q10 (chave, ok) select chave, ok from _q10_papeis;

-- ============================================================================
-- ADMIN: não-admin e sem autenticação bloqueados em TODAS as RPCs admin
-- ============================================================================
do $$
declare
  v_id constant uuid := gen_random_uuid();
  v_sql text;
  v_todos boolean := true;
  v_todos_sem_auth boolean := true;
begin
  foreach v_sql in array array[
    format('select * from public.criar_jobs_quadrinho_admin(%L, %L)', v_id, v_id),
    format('select * from public.aprovar_quadrinho_asset_admin(%L)', v_id),
    format('select * from public.rejeitar_quadrinho_asset_admin(%L)', v_id),
    format('select * from public.regenerar_quadrinho_asset_admin(%L)', v_id),
    format('select * from public.preparar_exclusao_quadrinho_asset_admin(%L)', v_id),
    format('select * from public.excluir_quadrinho_asset_admin(%L)', v_id)] loop
    perform set_config('request.jwt.claim.sub', gen_random_uuid()::text, true);
    if not pg_temp.q10_raises(v_sql, 'Apenas administradores%') then v_todos := false; end if;
    perform set_config('request.jwt.claim.sub', '', true);
    if not pg_temp.q10_raises(v_sql, 'Apenas administradores%') then v_todos_sem_auth := false; end if;
  end loop;
  perform pg_temp.q10_reg('admin_nao_admin_bloqueado_nas_6_rpcs', v_todos);
  perform pg_temp.q10_reg('admin_sem_autenticacao_bloqueado_nas_6_rpcs', v_todos_sem_auth);
end $$;

-- ============================================================================
-- CRIAR JOBS: validações, criação, idempotência
-- ============================================================================
do $$
declare
  v_p constant uuid := '52756262-8be4-4fb2-a9f3-2f5a158ea1d4';
  v_c constant uuid := '1f4065f2-8fda-4f7d-8826-45955230678d';
  v_conceito constant uuid := 'f0614831-dbff-4c68-b7f9-b3d31425adb4';
  v_admin uuid;
  v_ci int;
  v_ok boolean;
  v_n int;
  v_criados int;
  v_inalterados int;
  v_h_antes text;
begin
  select usuario_id into v_admin from public.administradores order by criado_em limit 1;
  select (c.ord - 1)::int into v_ci from public.aula_versoes av cross join lateral jsonb_array_elements(av.estrutura->'componentes') with ordinality c(value, ord)
    where av.id = v_p and c.value->>'id' = v_c::text;
  perform set_config('request.jwt.claim.sub', v_admin::text, true);
  select md5(estrutura::text) into v_h_antes from public.aula_versoes where id = v_p;

  perform pg_temp.q10_reg('criar_versao_inexistente_bloqueada', pg_temp.q10_raises(format('select * from public.criar_jobs_quadrinho_admin(%L, %L)', gen_random_uuid(), v_c), 'Versao de aula nao encontrada%'));
  perform pg_temp.q10_reg('criar_componente_inexistente_bloqueado', pg_temp.q10_raises(format('select * from public.criar_jobs_quadrinho_admin(%L, %L)', v_p, gen_random_uuid()), 'Componente quadrinho_didatico nao encontrado%'));
  perform pg_temp.q10_reg('criar_componente_de_outro_tipo_bloqueado', pg_temp.q10_raises(format('select * from public.criar_jobs_quadrinho_admin(%L, %L)', v_p, v_conceito), 'Componente quadrinho_didatico nao encontrado%'));

  -- menos de 3 quadros
  v_ok := false;
  begin
    update public.aula_versoes set estrutura = jsonb_set(estrutura, array['componentes', v_ci::text, 'quadros'], (estrutura->'componentes'->v_ci->'quadros') - 3 - 2) where id = v_p;
    v_ok := pg_temp.q10_raises(format('select * from public.criar_jobs_quadrinho_admin(%L, %L)', v_p, v_c), 'O quadrinho deve ter entre 3 e 6 quadros%');
    raise exception 'q10_desfazer';
  exception when others then if sqlerrm <> 'q10_desfazer' then raise; end if; end;
  perform pg_temp.q10_reg('criar_menos_de_3_quadros_bloqueado', v_ok);

  -- mais de 6 quadros
  v_ok := false;
  begin
    update public.aula_versoes set estrutura = jsonb_set(estrutura, array['componentes', v_ci::text, 'quadros'],
      (estrutura->'componentes'->v_ci->'quadros') || jsonb_build_array(estrutura->'componentes'->v_ci->'quadros'->0, estrutura->'componentes'->v_ci->'quadros'->0, estrutura->'componentes'->v_ci->'quadros'->0)) where id = v_p;
    v_ok := pg_temp.q10_raises(format('select * from public.criar_jobs_quadrinho_admin(%L, %L)', v_p, v_c), 'O quadrinho deve ter entre 3 e 6 quadros%');
    raise exception 'q10_desfazer';
  exception when others then if sqlerrm <> 'q10_desfazer' then raise; end if; end;
  perform pg_temp.q10_reg('criar_mais_de_6_quadros_bloqueado', v_ok);

  -- cena vazia
  v_ok := false;
  begin
    update public.aula_versoes set estrutura = jsonb_set(estrutura, array['componentes', v_ci::text, 'quadros', '1', 'cena'], to_jsonb('   '::text)) where id = v_p;
    v_ok := pg_temp.q10_raises(format('select * from public.criar_jobs_quadrinho_admin(%L, %L)', v_p, v_c), 'Quadro 2 sem cena valida%');
    raise exception 'q10_desfazer';
  exception when others then if sqlerrm <> 'q10_desfazer' then raise; end if; end;
  perform pg_temp.q10_reg('criar_cena_invalida_bloqueada_antes_de_escrever', v_ok);
  perform pg_temp.q10_reg('criar_validacoes_nao_deixaram_linhas', (select count(*) from public.aula_quadrinho_assets) = 0);

  -- criação real
  select count(*) filter (where acao = 'criado' and status_job = 'pendente'), count(*) into v_criados, v_n from public.criar_jobs_quadrinho_admin(v_p, v_c);
  perform pg_temp.q10_reg('criar_gera_exatamente_4_linhas_pendentes', v_criados = 4 and v_n = 4 and (select count(*) from public.aula_quadrinho_assets where aula_versao_id = v_p and componente_id = v_c) = 4);
  perform pg_temp.q10_reg('criar_scene_hash_bate_com_a_cena_atual_e_com_a_helper_da_Q9', not exists (
    select 1 from public.aula_quadrinho_assets q
    where q.aula_versao_id = v_p
      and (q.scene_hash is distinct from public.hash_cena_atual_quadrinho(q.aula_versao_id, q.componente_id, q.quadro_indice)
           or q.scene_hash is distinct from public.hash_cena_quadrinho(public.cena_atual_quadrinho(q.aula_versao_id, q.componente_id, q.quadro_indice)))));
  perform pg_temp.q10_reg('criar_estado_inicial_limpo', not exists (
    select 1 from public.aula_quadrinho_assets q where q.tentativas <> 0 or q.claim_token is not null or q.lease_ate is not null or q.storage_path is not null or q.storage_path_anterior is not null or q.aprovado_em is not null));
  perform pg_temp.q10_reg('criar_indices_0_a_3', (select array_agg(quadro_indice order by quadro_indice) from public.aula_quadrinho_assets) = array[0, 1, 2, 3]::smallint[]);

  -- idempotência
  select count(*) filter (where acao = 'inalterado'), count(*) into v_inalterados, v_n from public.criar_jobs_quadrinho_admin(v_p, v_c);
  perform pg_temp.q10_reg('criar_idempotente_nao_duplica', v_inalterados = 4 and v_n = 4 and (select count(*) from public.aula_quadrinho_assets) = 4);
  perform pg_temp.q10_reg('criar_nao_altera_a_estrutura_da_aula', v_h_antes = (select md5(estrutura::text) from public.aula_versoes where id = v_p));
  perform pg_temp.q10_reg('criar_admin_rpc_de_leitura_da_Q9_enxerga_os_4_jobs_atuais', (
    select count(*) filter (where asset_atual) from public.carregar_quadrinho_assets_admin(v_p)) = 4);
end $$;

-- ============================================================================
-- WORKER: claim, lease, fencing, tentativas, falha, conclusão
-- ============================================================================
create temporary table _q10_fx (chave text primary key, valor text);

do $$
declare
  v_p constant uuid := '52756262-8be4-4fb2-a9f3-2f5a158ea1d4';
  v_c constant uuid := '1f4065f2-8fda-4f7d-8826-45955230678d';
  a_id uuid[]; a_tok uuid[]; a_idx smallint[]; a_path text[];
  r record; r2 record;
  i int;
  v_ok boolean;
  v_tok_velho uuid;
  v_path_velho text;
  v_erro text;
  v_n int;
begin
  -- 4 claims => 4 assets DISTINTOS; o 5º não recebe nada (leases válidos não são roubados)
  for i in 1 .. 4 loop
    select * into r from public.reservar_quadrinho_asset(v_p);
    a_id[i] := r.asset_id; a_tok[i] := r.claim_token; a_idx[i] := r.quadro_indice;
    a_path[i] := r.storage_path_esperado;
    if i = 1 then
      perform pg_temp.q10_reg('claim_retorna_somente_o_contrato_do_worker',
        (select array_agg(k) from jsonb_object_keys(to_jsonb(r)) as k)
          @> array['asset_id', 'aula_versao_id', 'componente_id', 'quadro_indice', 'scene_hash', 'cena', 'tentativa', 'claim_token', 'lease_ate', 'storage_path_esperado']
        and (select count(*) from jsonb_object_keys(to_jsonb(r)) as k) = 10);
      perform pg_temp.q10_reg('claim_1_estado_gerando_tentativa_1_lease_10min', (
        select q.status = 'gerando' and q.tentativas = 1 and q.claim_token = r.claim_token and q.lease_ate > now() + interval '9 minutes' and q.lease_ate <= now() + interval '10 minutes' + interval '1 second'
        from public.aula_quadrinho_assets q where q.id = r.asset_id) and r.tentativa = 1);
      perform pg_temp.q10_reg('claim_cena_e_a_cena_atual_e_hash_confere', r.cena = public.cena_atual_quadrinho(r.aula_versao_id, r.componente_id, r.quadro_indice)
        and public.hash_cena_quadrinho(r.cena) = r.scene_hash);
      perform pg_temp.q10_reg('claim_path_esperado_com_claim_token_e_hash10', r.storage_path_esperado =
        r.aula_versao_id::text || '/' || r.componente_id::text || '/' || r.quadro_indice::text || '/' || left(r.scene_hash, 10) || '-' || r.claim_token::text || '.webp');
    end if;
  end loop;
  perform pg_temp.q10_reg('claims_sequenciais_obtem_4_assets_distintos', (select count(distinct x) from unnest(a_id) x) = 4 and (select count(distinct x) from unnest(a_tok) x) = 4);
  select count(*) into v_n from public.reservar_quadrinho_asset(v_p);
  perform pg_temp.q10_reg('claim_5_nao_recebe_nada_lease_valido_nao_e_roubado', v_n = 0);
  perform pg_temp.q10_reg('claim_atualiza_todas_as_linhas_para_gerando', (select count(*) from public.aula_quadrinho_assets where status = 'gerando' and tentativas = 1) = 4);

  -- ---------- asset 1: fencing básico e conclusão ----------
  select * into r from public.concluir_quadrinho_asset(a_id[1], gen_random_uuid(), (select scene_hash from public.aula_quadrinho_assets where id = a_id[1]), a_path[1], 'modelo-teste', 'pv-teste', 'prompt visual de teste');
  perform pg_temp.q10_reg('concluir_token_errado_recusado_sem_tocar_na_linha', r.aceito is false and r.motivo = 'claim_invalido'
    and (select status = 'gerando' and claim_token = a_tok[1] and storage_path is null from public.aula_quadrinho_assets where id = a_id[1]));
  perform pg_temp.q10_reg('concluir_path_fora_do_padrao_falha', pg_temp.q10_raises(
    format('select * from public.concluir_quadrinho_asset(%L, %L, %L, %L, ''m'', ''p'', ''v'')', a_id[1], a_tok[1], (select scene_hash from public.aula_quadrinho_assets where id = a_id[1]), 'q10/qualquer.webp'), 'storage_path fora do padrao%'));
  perform pg_temp.q10_reg('concluir_scene_hash_informado_diferente_falha', pg_temp.q10_raises(
    format('select * from public.concluir_quadrinho_asset(%L, %L, %L, %L, ''m'', ''p'', ''v'')', a_id[1], a_tok[1], repeat('b', 64), a_path[1]), 'scene_hash informado difere%'));
  perform pg_temp.q10_reg('concluir_exige_auditoria_modelo_prompt', pg_temp.q10_raises(
    format('select * from public.concluir_quadrinho_asset(%L, %L, %L, %L, '''', ''p'', ''v'')', a_id[1], a_tok[1], (select scene_hash from public.aula_quadrinho_assets where id = a_id[1]), a_path[1]), 'modelo, prompt_version e prompt_visual sao obrigatorios%'));
  perform pg_temp.q10_reg('concluir_storage_path_obrigatorio', pg_temp.q10_raises(
    format('select * from public.concluir_quadrinho_asset(%L, %L, %L, null, ''m'', ''p'', ''v'')', a_id[1], a_tok[1], (select scene_hash from public.aula_quadrinho_assets where id = a_id[1])), 'storage_path obrigatorio%'));
  perform pg_temp.q10_reg('falhas_de_contrato_nao_alteraram_a_linha', (select status = 'gerando' and claim_token = a_tok[1] from public.aula_quadrinho_assets where id = a_id[1]));

  update public.aula_quadrinho_assets set atualizado_em = timestamptz '2000-01-01' where id = a_id[1];
  select * into r from public.concluir_quadrinho_asset(a_id[1], a_tok[1], (select scene_hash from public.aula_quadrinho_assets where id = a_id[1]), a_path[1], 'modelo-teste', 'pv-teste', 'prompt visual de teste');
  perform pg_temp.q10_reg('concluir_claim_atual_aceito', r.aceito is true and r.motivo = 'concluido' and r.status_final = 'gerada');
  perform pg_temp.q10_reg('concluir_estado_final_correto_sem_aprovar', (
    select q.status = 'gerada' and q.storage_path = a_path[1] and q.modelo = 'modelo-teste' and q.prompt_version = 'pv-teste' and q.prompt_visual = 'prompt visual de teste'
       and q.lease_ate is null and q.claim_token is null and q.erro_sanitizado is null and q.aprovado_em is null and q.aprovado_por is null and q.atualizado_em > timestamptz '2000-01-01'
    from public.aula_quadrinho_assets q where q.id = a_id[1]));
  select * into r from public.concluir_quadrinho_asset(a_id[1], a_tok[1], (select scene_hash from public.aula_quadrinho_assets where id = a_id[1]), a_path[1], 'modelo-teste', 'pv-teste', 'prompt visual de teste');
  perform pg_temp.q10_reg('concluir_duas_vezes_mesmo_path_e_idempotente', r.aceito is true and r.motivo = 'ja_concluido');
  select * into r from public.concluir_quadrinho_asset(a_id[1], gen_random_uuid(), (select scene_hash from public.aula_quadrinho_assets where id = a_id[1]), 'q10/outro.webp', 'm', 'p', 'v');
  perform pg_temp.q10_reg('concluir_depois_de_gerada_com_outro_path_recusado', r.aceito is false
    and (select storage_path = a_path[1] from public.aula_quadrinho_assets where id = a_id[1]));

  -- ---------- asset 2: worker antigo x recuperação de lease ----------
  v_tok_velho := a_tok[2];
  v_path_velho := a_path[2];
  update public.aula_quadrinho_assets set lease_ate = now() - interval '1 minute' where id = a_id[2];
  select * into r from public.reservar_quadrinho_asset(v_p);
  perform pg_temp.q10_reg('lease_expirado_e_recuperavel_com_novo_token_e_tentativa_2', r.asset_id = a_id[2] and r.claim_token <> v_tok_velho and r.tentativa = 2);
  perform pg_temp.q10_reg('claim_recuperado_muda_o_path_esperado_e_nao_sobrescreve_o_anterior', r.storage_path_esperado <> v_path_velho);
  a_tok[2] := r.claim_token; a_path[2] := r.storage_path_esperado;
  select * into r2 from public.concluir_quadrinho_asset(a_id[2], v_tok_velho,
    (select scene_hash from public.aula_quadrinho_assets where id = a_id[2]),
    (select aula_versao_id::text || '/' || componente_id::text || '/' || quadro_indice::text || '/' || left(scene_hash, 10) || '-' || v_tok_velho::text || '.webp' from public.aula_quadrinho_assets where id = a_id[2]),
    'm', 'p', 'v');
  perform pg_temp.q10_reg('worker_antigo_nao_conclui_apos_perder_o_claim', r2.aceito is false and r2.motivo = 'claim_invalido'
    and (select status = 'gerando' and claim_token = a_tok[2] and storage_path is null from public.aula_quadrinho_assets where id = a_id[2]));
  select * into r2 from public.falhar_quadrinho_asset(a_id[2], v_tok_velho, 'erro do worker antigo');
  perform pg_temp.q10_reg('worker_antigo_nao_falha_a_linha_do_novo_dono', r2.aceito is false and (select status = 'gerando' and claim_token = a_tok[2] and erro_sanitizado is null from public.aula_quadrinho_assets where id = a_id[2]));
  select * into r2 from public.concluir_quadrinho_asset(a_id[2], a_tok[2], (select scene_hash from public.aula_quadrinho_assets where id = a_id[2]), a_path[2], 'm', 'p', 'v');
  perform pg_temp.q10_reg('novo_dono_do_claim_conclui', r2.aceito is true and (select status = 'gerada' and storage_path = a_path[2] from public.aula_quadrinho_assets where id = a_id[2]));

  -- ---------- asset 3: limite de 3 tentativas ----------
  update public.aula_quadrinho_assets set lease_ate = now() - interval '1 minute' where id = a_id[3];
  select * into r from public.reservar_quadrinho_asset(v_p);
  perform pg_temp.q10_reg('tentativa_2_do_asset_3', r.asset_id = a_id[3] and r.tentativa = 2);
  update public.aula_quadrinho_assets set lease_ate = now() - interval '1 minute' where id = a_id[3];
  select * into r from public.reservar_quadrinho_asset(v_p);
  perform pg_temp.q10_reg('tentativa_3_do_asset_3', r.asset_id = a_id[3] and r.tentativa = 3);
  update public.aula_quadrinho_assets set lease_ate = now() - interval '1 minute' where id = a_id[3];
  select count(*) into v_n from public.reservar_quadrinho_asset(v_p);
  perform pg_temp.q10_reg('tentativa_4_nunca_ocorre_e_lease_expirado_sem_tentativas_vira_erro', v_n = 0 and (
    select q.status = 'erro' and q.tentativas = 3 and q.lease_ate is null and q.claim_token is null and q.erro_sanitizado like 'tempo limite%' from public.aula_quadrinho_assets q where q.id = a_id[3]));
  select count(*) into v_n from public.reservar_quadrinho_asset(v_p);
  perform pg_temp.q10_reg('erro_esgotado_nao_e_reservado_de_novo', v_n = 0);

  -- ---------- asset 4: falha, sanitização e retry ----------
  select * into r from public.falhar_quadrinho_asset(a_id[4], gen_random_uuid(), 'x');
  perform pg_temp.q10_reg('falhar_token_errado_recusado', r.aceito is false and r.motivo = 'claim_invalido' and (select status = 'gerando' from public.aula_quadrinho_assets where id = a_id[4]));
  select * into r from public.falhar_quadrinho_asset(a_id[4], a_tok[4],
    'Incorrect API key provided: s' || 'k-proj-ABCDEFGH12345678xyz. Authorization: Bearer abc.def-ghi123 e e' || 'yJhbGciOiJIUzI1NiJ9.e' || 'yJzdWIiOiJ4In0.assinatura' || E'\nlinha2 ' || repeat('QUJD', 40) || repeat(' fim', 100));
  select erro_sanitizado into v_erro from public.aula_quadrinho_assets where id = a_id[4];
  perform pg_temp.q10_reg('falhar_1_de_3_volta_a_pendente_para_retry', r.aceito is true and r.status_final = 'pendente' and r.tentativas_usadas = 1
    and (select status = 'pendente' and lease_ate is null and claim_token is null and tentativas = 1 from public.aula_quadrinho_assets where id = a_id[4]));
  perform pg_temp.q10_reg('falhar_guarda_apenas_erro_sanitizado', v_erro is not null and length(v_erro) <= 300 and v_erro !~ 'sk-' and v_erro !~ 'Bearer abc' and v_erro !~ 'eyJ' and v_erro !~ '[\r\n]' and v_erro !~ 'QUJDQUJD'
    and v_erro like '%[chave]%' and v_erro like '%Bearer [token]%' and v_erro like '%[jwt]%');
  select * into r from public.reservar_quadrinho_asset(v_p);
  perform pg_temp.q10_reg('retry_reserva_o_mesmo_asset_com_tentativa_2', r.asset_id = a_id[4] and r.tentativa = 2);
  select * into r2 from public.falhar_quadrinho_asset(a_id[4], r.claim_token, 'segunda falha');
  select * into r from public.reservar_quadrinho_asset(v_p);
  perform pg_temp.q10_reg('retry_tentativa_3', r.asset_id = a_id[4] and r.tentativa = 3);
  select * into r2 from public.falhar_quadrinho_asset(a_id[4], r.claim_token, 'terceira falha');
  perform pg_temp.q10_reg('falhar_na_3a_tentativa_vira_erro_terminal', r2.aceito is true and r2.status_final = 'erro' and r2.tentativas_usadas = 3
    and (select status = 'erro' and tentativas = 3 and erro_sanitizado = 'terceira falha' from public.aula_quadrinho_assets where id = a_id[4]));
  select count(*) into v_n from public.reservar_quadrinho_asset(v_p);
  perform pg_temp.q10_reg('nenhuma_tentativa_passa_de_3_em_nenhuma_linha', v_n = 0 and not exists (select 1 from public.aula_quadrinho_assets where tentativas > 3));

  insert into _q10_fx values ('a1', a_id[1]::text), ('a2', a_id[2]::text), ('a3', a_id[3]::text), ('a4', a_id[4]::text),
    ('i1', a_idx[1]::text), ('i2', a_idx[2]::text), ('i3', a_idx[3]::text), ('i4', a_idx[4]::text),
    ('p1', a_path[1]), ('p2', a_path[2]);
end $$;

-- ============================================================================
-- CENA MUDA durante o pipeline (sub-blocos desfeitos automaticamente)
-- ============================================================================
do $$
declare
  v_p constant uuid := '52756262-8be4-4fb2-a9f3-2f5a158ea1d4';
  v_c constant uuid := '1f4065f2-8fda-4f7d-8826-45955230678d';
  a3 uuid := (select valor::uuid from _q10_fx where chave = 'a3');
  i3 int := (select valor::int from _q10_fx where chave = 'i3');
  v_ci int;
  r record;
  v_ok boolean;
  v_ok2 boolean;
  v_n int;
begin
  select (c.ord - 1)::int into v_ci from public.aula_versoes av cross join lateral jsonb_array_elements(av.estrutura->'componentes') with ordinality c(value, ord)
    where av.id = v_p and c.value->>'id' = v_c::text;

  -- claim: cena mudou depois de criar o job => nunca gera; marca erro
  v_ok := false; v_ok2 := false;
  begin
    update public.aula_quadrinho_assets set status = 'pendente', tentativas = 0, erro_sanitizado = null where id = a3;
    update public.aula_versoes set estrutura = jsonb_set(estrutura, array['componentes', v_ci::text, 'quadros', i3::text, 'cena'], to_jsonb('Cena alterada antes do claim.'::text)) where id = v_p;
    select count(*) into v_n from public.reservar_quadrinho_asset(v_p);
    v_ok := (v_n = 0);
    v_ok2 := (select status = 'erro' and erro_sanitizado like 'cena alterada%' and claim_token is null and lease_ate is null and tentativas = 0 from public.aula_quadrinho_assets where id = a3);
    raise exception 'q10_desfazer';
  exception when others then if sqlerrm <> 'q10_desfazer' then raise; end if; end;
  perform pg_temp.q10_reg('claim_com_cena_alterada_nao_gera_e_marca_erro', v_ok and v_ok2);

  -- concluir: cena mudou DURANTE a geração => resultado obsoleto recusado
  v_ok := false; v_ok2 := false;
  begin
    update public.aula_quadrinho_assets set status = 'pendente', tentativas = 0, erro_sanitizado = null where id = a3;
    select * into r from public.reservar_quadrinho_asset(v_p);
    update public.aula_versoes set estrutura = jsonb_set(estrutura, array['componentes', v_ci::text, 'quadros', i3::text, 'cena'], to_jsonb('Cena alterada durante a geracao.'::text)) where id = v_p;
    select * into r from public.concluir_quadrinho_asset(r.asset_id, r.claim_token, r.scene_hash, r.storage_path_esperado, 'm', 'p', 'v');
    v_ok := (r.aceito is false and r.motivo = 'cena_alterada' and r.status_final = 'erro');
    v_ok2 := (select status = 'erro' and storage_path is null and claim_token is null and lease_ate is null from public.aula_quadrinho_assets where id = a3);
    raise exception 'q10_desfazer';
  exception when others then if sqlerrm <> 'q10_desfazer' then raise; end if; end;
  perform pg_temp.q10_reg('concluir_com_cena_alterada_recusa_resultado_obsoleto', v_ok and v_ok2);
  perform pg_temp.q10_reg('sub_blocos_nao_deixaram_rastro', (select status = 'erro' and tentativas = 3 from public.aula_quadrinho_assets where id = a3)
    and (select md5(estrutura::text) from public.aula_versoes where id = v_p) = (select md5(estrutura::text) from _q10_old_versoes where id = v_p));
end $$;

-- ============================================================================
-- ADMIN: aprovar, rejeitar, regenerar, sincronizar, excluir
-- ============================================================================
do $$
declare
  v_p constant uuid := '52756262-8be4-4fb2-a9f3-2f5a158ea1d4';
  v_c constant uuid := '1f4065f2-8fda-4f7d-8826-45955230678d';
  a1 uuid := (select valor::uuid from _q10_fx where chave = 'a1');
  a2 uuid := (select valor::uuid from _q10_fx where chave = 'a2');
  a3 uuid := (select valor::uuid from _q10_fx where chave = 'a3');
  a4 uuid := (select valor::uuid from _q10_fx where chave = 'a4');
  i1 int := (select valor::int from _q10_fx where chave = 'i1');
  i2 int := (select valor::int from _q10_fx where chave = 'i2');
  i3 int := (select valor::int from _q10_fx where chave = 'i3');
  p1 text := (select valor from _q10_fx where chave = 'p1');
  p2 text := (select valor from _q10_fx where chave = 'p2');
  v_admin uuid;
  v_ci int;
  r record;
  v_ok boolean;
  v_n int;
  v_m int;
  v_path_novo text;
  v_tok uuid;
begin
  select usuario_id into v_admin from public.administradores order by criado_em limit 1;
  select (c.ord - 1)::int into v_ci from public.aula_versoes av cross join lateral jsonb_array_elements(av.estrutura->'componentes') with ordinality c(value, ord)
    where av.id = v_p and c.value->>'id' = v_c::text;
  perform set_config('request.jwt.claim.sub', v_admin::text, true);
  -- estado herdado: a1 e a2 = gerada; a3 e a4 = erro

  -- aprovação só de `gerada`
  perform pg_temp.q10_reg('aprovar_asset_em_erro_bloqueado', pg_temp.q10_raises(format('select * from public.aprovar_quadrinho_asset_admin(%L)', a3), 'Somente um asset gerado pode ser aprovado%'));
  update public.aula_quadrinho_assets set status = 'pendente', tentativas = 0 where id = a4;
  perform pg_temp.q10_reg('aprovar_asset_pendente_bloqueado', pg_temp.q10_raises(format('select * from public.aprovar_quadrinho_asset_admin(%L)', a4), 'Somente um asset gerado pode ser aprovado%'));
  perform pg_temp.q10_reg('aprovar_asset_inexistente_bloqueado', pg_temp.q10_raises(format('select * from public.aprovar_quadrinho_asset_admin(%L)', gen_random_uuid()), 'Asset nao encontrado%'));

  -- aprovação exige hash atual
  v_ok := false;
  begin
    update public.aula_versoes set estrutura = jsonb_set(estrutura, array['componentes', v_ci::text, 'quadros', i1::text, 'cena'], to_jsonb('Cena alterada apos a geracao.'::text)) where id = v_p;
    v_ok := pg_temp.q10_raises(format('select * from public.aprovar_quadrinho_asset_admin(%L)', a1), 'CENA_ALTERADA%')
      and (select status = 'gerada' and aprovado_em is null from public.aula_quadrinho_assets where id = a1);
    raise exception 'q10_desfazer';
  exception when others then if sqlerrm <> 'q10_desfazer' then raise; end if; end;
  perform pg_temp.q10_reg('aprovar_com_cena_alterada_bloqueado_e_nao_aprova', v_ok);

  update public.aula_quadrinho_assets set atualizado_em = timestamptz '2000-01-01' where id = a1;
  select * into r from public.aprovar_quadrinho_asset_admin(a1);
  perform pg_temp.q10_reg('aprovar_gerada_com_hash_atual', r.status_final = 'aprovada' and (
    select q.status = 'aprovada' and q.aprovado_por = v_admin and q.aprovado_em is not null and q.atualizado_em > timestamptz '2000-01-01' and q.storage_path = p1
    from public.aula_quadrinho_assets q where q.id = a1));
  perform pg_temp.q10_reg('aprovar_de_novo_bloqueado', pg_temp.q10_raises(format('select * from public.aprovar_quadrinho_asset_admin(%L)', a1), 'Somente um asset gerado pode ser aprovado%'));
  perform pg_temp.q10_reg('rpc_admin_da_Q9_mostra_aprovada_atual', exists (select 1 from public.carregar_quadrinho_assets_admin(v_p) x where x.id = a1 and x.status = 'aprovada' and x.asset_atual and x.storage_path = p1));

  -- rejeição
  perform pg_temp.q10_reg('rejeitar_asset_pendente_bloqueado', pg_temp.q10_raises(format('select * from public.rejeitar_quadrinho_asset_admin(%L)', a4), 'Somente um asset gerado ou aprovado pode ser rejeitado%'));
  update public.aula_quadrinho_assets set atualizado_em = timestamptz '2000-01-01' where id = a1;
  select * into r from public.rejeitar_quadrinho_asset_admin(a1);
  perform pg_temp.q10_reg('rejeitar_aprovada_limpa_aprovacao_e_mantem_arquivo', r.status_final = 'rejeitada' and (
    select q.status = 'rejeitada' and q.aprovado_por is null and q.aprovado_em is null and q.storage_path = p1 and q.atualizado_em > timestamptz '2000-01-01'
    from public.aula_quadrinho_assets q where q.id = a1));
  select * into r from public.rejeitar_quadrinho_asset_admin(a2);
  perform pg_temp.q10_reg('rejeitar_gerada', r.status_final = 'rejeitada' and (select status = 'rejeitada' and storage_path = p2 from public.aula_quadrinho_assets where id = a2));

  -- aprovar de novo para provar que regenerar remove a aprovação: a2 (rejeitada) -> não aprova; a1 idem. Usa fluxo: regenerar -> claim -> concluir -> aprovar -> regenerar
  update public.aula_quadrinho_assets set atualizado_em = timestamptz '2000-01-01' where id = a1;
  select * into r from public.regenerar_quadrinho_asset_admin(a1);
  perform pg_temp.q10_reg('regenerar_rejeitada_novo_ciclo_e_devolve_path_anterior', r.status_final = 'pendente' and r.path_anterior = p1 and r.hash_cena is not null and (
    select q.status = 'pendente' and q.storage_path is null and q.storage_path_anterior = p1 and q.tentativas = 0 and q.aprovado_em is null and q.aprovado_por is null
       and q.modelo is null and q.prompt_version is null and q.prompt_visual is null and q.erro_sanitizado is null and q.claim_token is null and q.lease_ate is null
       and q.atualizado_em > timestamptz '2000-01-01' from public.aula_quadrinho_assets q where q.id = a1));
  perform pg_temp.q10_reg('regenerar_nao_apaga_nem_serve_o_arquivo_antigo', (select storage_path is null and storage_path_anterior = p1 from public.aula_quadrinho_assets where id = a1)
    and not exists (select 1 from public.carregar_quadrinho_assets_admin(v_p) x where x.id = a1 and x.storage_path is not null));

  -- regenerar não interfere em claim válido
  select * into r from public.reservar_quadrinho_asset(v_p);
  v_tok := r.claim_token; v_path_novo := r.storage_path_esperado;
  perform pg_temp.q10_reg('claim_pega_o_asset_regenerado_indice_0_antes_do_pendente_de_indice_3', r.asset_id = a1);
  perform pg_temp.q10_reg('regenerar_com_lease_valido_bloqueado', pg_temp.q10_raises(format('select * from public.regenerar_quadrinho_asset_admin(%L)', r.asset_id), 'Asset em geracao (lease ativo)%')
    and (select status = 'gerando' and claim_token = v_tok from public.aula_quadrinho_assets where id = r.asset_id));
  perform pg_temp.q10_reg('excluir_com_lease_valido_bloqueado', pg_temp.q10_raises(format('select * from public.excluir_quadrinho_asset_admin(%L)', r.asset_id), 'Asset em geracao (lease ativo)%'));
  perform pg_temp.q10_reg('preparar_exclusao_com_lease_valido_bloqueado', pg_temp.q10_raises(format('select * from public.preparar_exclusao_quadrinho_asset_admin(%L)', r.asset_id), 'Asset em geracao (lease ativo)%'));

  -- concluir o novo ciclo do a1
  select * into r from public.concluir_quadrinho_asset(a1, v_tok, (select scene_hash from public.aula_quadrinho_assets where id = a1), v_path_novo, 'modelo-2', 'pv-2', 'prompt 2');
  perform pg_temp.q10_reg('novo_ciclo_conclui_com_path_diferente_do_anterior', r.aceito is true and (
    select storage_path = v_path_novo and storage_path <> p1 and storage_path_anterior = p1 from public.aula_quadrinho_assets where id = a1));
  select * into r from public.aprovar_quadrinho_asset_admin(a1);
  perform pg_temp.q10_reg('novo_ciclo_aprovado', r.status_final = 'aprovada');

  -- regenerar uma APROVADA remove a aprovação; anterior já sem objeto no Storage => pode ser sobrescrito pelo atual
  select * into r from public.regenerar_quadrinho_asset_admin(a1);
  perform pg_temp.q10_reg('regenerar_aprovada_remove_aprovacao_e_move_atual_para_anterior', r.status_final = 'pendente' and r.path_anterior = v_path_novo and (
    select status = 'pendente' and aprovado_em is null and aprovado_por is null and storage_path is null and storage_path_anterior = v_path_novo from public.aula_quadrinho_assets where id = a1));
  perform pg_temp.q10_reg('aluno_nunca_recebe_pendente_nem_arquivo_anterior', not exists (
    select 1 from public.carregar_quadrinho_assets_admin(v_p) x where x.id = a1 and (x.status = 'aprovada' or x.storage_path is not null)));

  -- sincronização por cena alterada (criar_jobs): erro/rejeitada => invalida e arquiva o path atual
  v_ok := false;
  begin
    update public.aula_versoes set estrutura = jsonb_set(estrutura, array['componentes', v_ci::text, 'quadros', i2::text, 'cena'], to_jsonb('Cena nova para sincronizar.'::text)) where id = v_p;
    select count(*) filter (where acao = 'invalidado' and indice = i2), count(*) filter (where acao = 'inalterado') into v_n, v_m from public.criar_jobs_quadrinho_admin(v_p, v_c);
    select (q.status = 'pendente' and q.storage_path is null and q.storage_path_anterior = p2 and q.tentativas = 0 and q.aprovado_em is null
            and q.scene_hash = public.hash_cena_atual_quadrinho(q.aula_versao_id, q.componente_id, q.quadro_indice)) into v_ok
      from public.aula_quadrinho_assets q where q.id = a2;
    v_ok := v_ok and v_n = 1 and v_m = 3;
    raise exception 'q10_desfazer';
  exception when others then if sqlerrm <> 'q10_desfazer' then raise; end if; end;
  perform pg_temp.q10_reg('sincronizar_cena_alterada_invalida_e_arquiva_arquivo_sem_apagar', v_ok);

  -- sincronização bloqueada se o quadro alterado estiver em geração com lease válido
  v_ok := false;
  begin
    update public.aula_quadrinho_assets set status = 'gerando', claim_token = gen_random_uuid(), lease_ate = now() + interval '5 minutes', storage_path = null where id = a3;
    update public.aula_versoes set estrutura = jsonb_set(estrutura, array['componentes', v_ci::text, 'quadros', i3::text, 'cena'], to_jsonb('Cena nova durante a geracao.'::text)) where id = v_p;
    v_ok := pg_temp.q10_raises(format('select * from public.criar_jobs_quadrinho_admin(%L, %L)', v_p, v_c), 'Quadro % esta em geracao (lease ativo)%');
    raise exception 'q10_desfazer';
  exception when others then if sqlerrm <> 'q10_desfazer' then raise; end if; end;
  perform pg_temp.q10_reg('sincronizar_bloqueada_com_lease_valido', v_ok);

  -- exclusão em duas fases
  perform pg_temp.q10_reg('preparar_exclusao_asset_inexistente_bloqueado', pg_temp.q10_raises(format('select * from public.preparar_exclusao_quadrinho_asset_admin(%L)', gen_random_uuid()), 'Asset nao encontrado%'));
  select * into r from public.preparar_exclusao_quadrinho_asset_admin(a2);
  perform pg_temp.q10_reg('preparar_exclusao_devolve_paths_e_deixa_de_servir', r.path_atual = p2 and r.status_final = 'rejeitada' and (select status = 'rejeitada' and aprovado_em is null from public.aula_quadrinho_assets where id = a2));
  select * into r from public.preparar_exclusao_quadrinho_asset_admin(a2);
  perform pg_temp.q10_reg('preparar_exclusao_e_idempotente', r.path_atual = p2 and r.status_final = 'rejeitada');
  select * into r from public.excluir_quadrinho_asset_admin(a2);
  perform pg_temp.q10_reg('excluir_apaga_a_linha_quando_o_arquivo_nao_existe_mais_no_storage', r.excluido is true and not exists (select 1 from public.aula_quadrinho_assets where id = a2));
  perform pg_temp.q10_reg('excluir_de_novo_asset_inexistente_bloqueado', pg_temp.q10_raises(format('select * from public.excluir_quadrinho_asset_admin(%L)', a2), 'Asset nao encontrado%'));
  perform pg_temp.q10_reg('helper_de_storage_nao_encontra_paths_de_teste', not public.quadrinho_path_no_storage(p1) and not public.quadrinho_path_no_storage(null));

  -- resíduos: nenhum arquivo foi criado; nenhuma linha fora do esperado
  perform pg_temp.q10_reg('nenhum_objeto_no_bucket_durante_todo_o_teste', (select count(*) from storage.objects where bucket_id = 'quadrinhos-aulas') = 0);
end $$;

-- ============================================================================
-- REVERTER: o down-migration real é exercitado aqui (sem linhas em geração)
-- ============================================================================
delete from public.aula_quadrinho_assets;

-- >>> SECAO_REVERT_GUARDA (identica no harness)
do $$
declare
  v_n bigint;
begin
  if not exists (select 1 from information_schema.columns where table_schema = 'public' and table_name = 'aula_quadrinho_assets' and column_name = 'claim_token') then
    raise exception 'REVERT: pipeline ausente (claim_token nao existe) — nada a reverter (ou ja revertido)';
  end if;

  select count(*) into v_n from public.aula_quadrinho_assets where status = 'gerando' or claim_token is not null;
  if v_n > 0 then
    raise exception 'REVERT: % linha(s) em geracao (gerando/claim_token); aguarde ou encerre os jobs antes', v_n;
  end if;

  select count(*) into v_n from public.aula_quadrinho_assets where storage_path_anterior is not null;
  if v_n > 0 then
    raise exception 'REVERT: % linha(s) com storage_path_anterior (arquivo a limpar); limpe o Storage e zere a coluna conscientemente antes', v_n;
  end if;
end $$;
-- <<< SECAO_REVERT_GUARDA

-- >>> SECAO_REVERT_CORPO (identica no harness)
drop function public.criar_jobs_quadrinho_admin(uuid, uuid);
drop function public.aprovar_quadrinho_asset_admin(uuid);
drop function public.rejeitar_quadrinho_asset_admin(uuid);
drop function public.regenerar_quadrinho_asset_admin(uuid);
drop function public.preparar_exclusao_quadrinho_asset_admin(uuid);
drop function public.excluir_quadrinho_asset_admin(uuid);
drop function public.reservar_quadrinho_asset(uuid);
drop function public.concluir_quadrinho_asset(uuid, uuid, text, text, text, text, text);
drop function public.falhar_quadrinho_asset(uuid, uuid, text);
drop function public.quadrinho_asset_reiniciar(uuid, text);
drop function public.quadrinho_path_no_storage(text);
drop function public.cena_atual_quadrinho(uuid, uuid, smallint);
drop function public.quadrinho_componente(uuid, uuid);
drop function public.quadrinho_asset_lease();

drop index public.aula_quadrinho_assets_path_anterior_key;
alter table public.aula_quadrinho_assets
  drop constraint aula_quadrinho_assets_claim_coerente_check,
  drop constraint aula_quadrinho_assets_path_anterior_check;
alter table public.aula_quadrinho_assets
  drop column claim_token,
  drop column storage_path_anterior;
-- <<< SECAO_REVERT_CORPO

-- >>> SECAO_REVERT_POSCOND (identica no harness)
do $$
declare
  v_colunas text;
  v_esperado text := 'id:uuid:NO,aula_versao_id:uuid:NO,componente_id:uuid:NO,quadro_indice:smallint:NO,scene_hash:text:NO,status:text:NO,storage_path:text:YES,modelo:text:YES,prompt_version:text:YES,prompt_visual:text:YES,tentativas:smallint:NO,lease_ate:timestamp with time zone:YES,erro_sanitizado:text:YES,aprovado_por:uuid:YES,aprovado_em:timestamp with time zone:YES,criado_em:timestamp with time zone:NO,atualizado_em:timestamp with time zone:NO';
begin
  select string_agg(column_name || ':' || data_type || ':' || is_nullable, ',' order by ordinal_position) into v_colunas
  from information_schema.columns where table_schema = 'public' and table_name = 'aula_quadrinho_assets';
  if v_colunas is distinct from v_esperado then raise exception 'REVERT POSCOND: colunas nao voltaram ao estado da Q9: %', v_colunas; end if;
  if (select count(*) from pg_constraint where conrelid = 'public.aula_quadrinho_assets'::regclass and contype = 'c') <> 7 then
    raise exception 'REVERT POSCOND: CHECKs nao voltaram a 7';
  end if;
  if to_regclass('public.aula_quadrinho_assets_path_anterior_key') is not null then raise exception 'REVERT POSCOND: indice ainda existe'; end if;
  if exists (
    select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname in (
      'criar_jobs_quadrinho_admin', 'reservar_quadrinho_asset', 'concluir_quadrinho_asset', 'falhar_quadrinho_asset',
      'aprovar_quadrinho_asset_admin', 'rejeitar_quadrinho_asset_admin', 'regenerar_quadrinho_asset_admin',
      'preparar_exclusao_quadrinho_asset_admin', 'excluir_quadrinho_asset_admin',
      'quadrinho_asset_lease', 'quadrinho_componente', 'cena_atual_quadrinho', 'quadrinho_path_no_storage', 'quadrinho_asset_reiniciar')
  ) then raise exception 'REVERT POSCOND: ainda existem funcoes do pipeline'; end if;
  if (select count(*) from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public'
        and p.proname in ('hash_cena_quadrinho', 'hash_cena_atual_quadrinho', 'carregar_quadrinho_assets_aula', 'carregar_quadrinho_assets_admin')) <> 4 then
    raise exception 'REVERT POSCOND: a fundacao Q9 foi afetada';
  end if;
  raise notice 'REVERT POSCOND OK: pipeline removido; fundacao Q9 intacta';
end $$;
-- <<< SECAO_REVERT_POSCOND

-- ============================================================================
-- OLD_FINAL: estado == snapshot OLD (ainda dentro da transação, antes do ROLLBACK)
-- ============================================================================
update public.aula_versoes av set estrutura = o.estrutura from _q10_old_versoes o where av.id = o.id and av.estrutura is distinct from o.estrutura;

insert into teste_q10 (chave, ok) values ('old_final_colunas_da_tabela_como_na_Q9',
  (select colunas from _q10_snap_estado) is not distinct from (select string_agg(column_name || ':' || data_type || ':' || is_nullable, ',' order by ordinal_position)
     from information_schema.columns where table_schema = 'public' and table_name = 'aula_quadrinho_assets'));
insert into teste_q10 (chave, ok) values ('old_final_constraints_da_tabela_como_na_Q9',
  not exists (select nome from _q10_snap_cons except select conname::text from pg_constraint where conrelid = 'public.aula_quadrinho_assets'::regclass)
  and not exists (select conname::text from pg_constraint where conrelid = 'public.aula_quadrinho_assets'::regclass except select nome from _q10_snap_cons));
insert into teste_q10 (chave, ok) values ('old_final_relacoes_e_funcoes_iguais_ao_snapshot',
  not exists (select c.relname::text from pg_class c join pg_namespace n on n.oid = c.relnamespace where n.nspname = 'public' and c.relname::text not in (select nome from _q10_snap_rel))
  and not exists (select nome from _q10_snap_rel except select c.relname::text from pg_class c join pg_namespace n on n.oid = c.relnamespace where n.nspname = 'public')
  and not exists (select p.oid::text from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public' and p.oid::text not in (select nome from _q10_snap_fn))
  and not exists (select nome from _q10_snap_fn except select p.oid::text from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public'));
insert into teste_q10 (chave, ok) values ('old_final_funcoes_q9_e_rpcs_existentes_identicas',
  (select h_funcoes from _q10_snap_estado) = (select jsonb_object_agg(p.proname, md5(pg_get_functiondef(p.oid))) from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname in ('hash_cena_quadrinho', 'hash_cena_atual_quadrinho', 'carregar_quadrinho_assets_aula', 'carregar_quadrinho_assets_admin', 'carregar_aula_publicada_da_missao', 'carregar_aula_rascunho_admin', 'eh_admin')));
insert into teste_q10 (chave, ok) values ('old_final_policies_e_bucket_iguais',
  not exists (select nome from _q10_snap_pol except select schemaname::text || '.' || tablename::text || '.' || policyname::text from pg_policies)
  and not exists (select schemaname::text || '.' || tablename::text || '.' || policyname::text from pg_policies except select nome from _q10_snap_pol)
  and not exists (select id::text || ':' || public::text || ':' || coalesce(file_size_limit::text, '') || ':' || coalesce(allowed_mime_types::text, '') from storage.buckets except select nome from _q10_snap_bucket)
  and not exists (select nome from _q10_snap_bucket except select id::text || ':' || public::text || ':' || coalesce(file_size_limit::text, '') || ':' || coalesce(allowed_mime_types::text, '') from storage.buckets));
insert into teste_q10 (chave, ok) values ('old_final_aula_versoes_e_aulas_identicas',
  (select h_versoes from _q10_snap_estado) is not distinct from (select md5(string_agg(id::text || estrutura::text || status || numero_versao::text, '|' order by id)) from public.aula_versoes)
  and (select h_aulas from _q10_snap_estado) is not distinct from (select md5(string_agg(id::text || titulo || ativa::text, '|' order by id)) from public.aulas));
insert into teste_q10 (chave, ok) values ('old_final_grants_cron_vault_matriculas_iguais',
  (select h_grants_tabelas from _q10_snap_estado) is not distinct from (select md5(string_agg(table_name::text || grantee::text || privilege_type::text, '|' order by table_name::text, grantee::text, privilege_type::text)) from information_schema.role_table_grants where table_schema = 'public')
  and (select h_cron from _q10_snap_estado) is not distinct from (select md5(string_agg(jobid::text || jobname || schedule || md5(command), '|' order by jobid)) from cron.job)
  and (select h_vault from _q10_snap_estado) is not distinct from (select md5(string_agg(name, '|' order by name)) from vault.secrets)
  and (select n_matriculas from _q10_snap_estado) = (select count(*) from public.matriculas));
insert into teste_q10 (chave, ok) values ('old_final_tabela_e_bucket_vazios_como_no_inicio',
  (select n_assets from _q10_snap_estado) = (select count(*) from public.aula_quadrinho_assets)
  and (select n_objetos_bucket from _q10_snap_estado) = (select count(*) from storage.objects where bucket_id = 'quadrinhos-aulas'));

-- ============================================================================
-- RESULTADO FINAL (falha aborta com a lista; tudo é desfeito de qualquer forma)
-- ============================================================================
do $$
declare
  v_falhas text;
begin
  select string_agg(chave, ', ' order by ordem) into v_falhas from teste_q10 where ok is distinct from true;
  if v_falhas is not null then
    raise exception 'HARNESS Q10: testes com falha: %', v_falhas;
  end if;
  raise notice 'HARNESS Q10 OK: % verificacoes passaram', (select count(*) from teste_q10);
end $$;

select
  count(*) as verificacoes,
  count(*) filter (where ok) as aprovadas,
  bool_and(ok) as tudo_ok,
  (select jsonb_agg(chave order by ordem) from teste_q10 where ok is distinct from true) as falhas
from teste_q10;

ROLLBACK;
