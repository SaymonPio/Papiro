-- ============================================================================
-- TESTE RUNTIME do pacote supabase/camada_ilustrada_gc.sql —
-- TRANSACIONAL, TUDO DESFEITO NO FINAL (BEGIN ... ROLLBACK).
-- ============================================================================
--
-- Rodar de uma vez (env -u SUPABASE_ACCESS_TOKEN npx --no-install supabase db
-- query --linked -f supabase/camada_ilustrada_gc_teste_rollback.sql), ler o
-- resultado e NUNCA persistir nada. Não há COMMIT neste arquivo.
--
-- Transacionalidade: CREATE [OR REPLACE] FUNCTION, DROP FUNCTION, REVOKE/GRANT e as
-- escritas nas linhas de teste são transacionais no PostgreSQL; o ROLLBACK final
-- desfaz o pacote inteiro. Nenhuma chamada HTTP, Image API, Edge, cron ou Vault.
-- storage.objects só é LIDO: nenhum objeto (físico ou linha) é criado ou removido.
--
-- As seções PRECOND / CORPO / POSCOND são IDÊNTICAS às do apply e as REVERT_* às de
-- reverter_camada_ilustrada_gc.sql (tests/camada-ilustrada-gc.test.mjs compara byte a
-- byte). Ordem: escopo; helpers puros (fórmula, canônico, grace); grants reais (SET LOCAL
-- ROLE); classificador com timestamps controlados (sem esperar 30 min); limites e
-- contrato das RPCs; regressão de reservar/concluir/falhar recriadas + proteções A/B/C,
-- lease expirado, token antigo e regeneração; REVERTER (restaura o texto EXATO do Q10,
-- md5 conferido) e OLD_FINAL (estado == snapshot OLD) antes do ROLLBACK.
-- LIMITE ASSUMIDO: sem criar objetos em storage.objects, o caminho "listar/confirmar
-- devolvem um órfão REAL" só é provado pelo classificador (mesma lógica usada pelas RPCs);
-- a prova com objetos reais fica para o teste LIVE com WebP sintético.
-- Fixtures: SOMENTE linhas de public.aula_quadrinho_assets; sem tocar aula_versoes,
-- matrículas, perfis, objetivos ou Storage.

BEGIN;

create temporary table teste_q112 (
  ordem serial,
  chave text primary key,
  ok boolean
);

-- Helpers temporários (somem com a transação): registrar resultado e provar exceções.
create function pg_temp.q112_reg(p_chave text, p_ok boolean) returns void language sql as $f$
  insert into teste_q112 (chave, ok) values (p_chave, coalesce(p_ok, false))
$f$;
create function pg_temp.q112_raises(p_sql text, p_padrao text) returns boolean language plpgsql as $f$
begin
  execute p_sql;
  return false;
exception when others then
  return sqlerrm like p_padrao;
end;
$f$;

-- Snapshot ANTES de qualquer criação.
create temporary table _q112_snap_rel on commit drop as
select c.relname::text as nome from pg_class c join pg_namespace n on n.oid = c.relnamespace where n.nspname = 'public';
create temporary table _q112_snap_fn on commit drop as
select p.oid::text as nome from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public';
create temporary table _q112_snap_pol on commit drop as
select schemaname::text || '.' || tablename::text || '.' || policyname::text as nome from pg_policies;
create temporary table _q112_snap_bucket on commit drop as
select id::text || ':' || public::text || ':' || coalesce(file_size_limit::text, '') || ':' || coalesce(allowed_mime_types::text, '') as nome from storage.buckets;
create temporary table _q112_snap_cons on commit drop as
select conname::text as nome from pg_constraint where conrelid = 'public.aula_quadrinho_assets'::regclass;
create temporary table _q112_snap_estado on commit drop as
select
  (select string_agg(column_name || ':' || data_type || ':' || is_nullable, ',' order by ordinal_position)
     from information_schema.columns where table_schema = 'public' and table_name = 'aula_quadrinho_assets') as colunas,
  (select count(*) from public.aula_quadrinho_assets) as n_assets,
  (select jsonb_object_agg(p.proname, md5(pg_get_functiondef(p.oid))) from pg_proc p join pg_namespace n on n.oid = p.pronamespace
     where n.nspname = 'public' and p.proname in ('hash_cena_quadrinho', 'hash_cena_atual_quadrinho', 'carregar_quadrinho_assets_aula', 'carregar_quadrinho_assets_admin',
       'quadrinho_asset_lease', 'quadrinho_componente', 'cena_atual_quadrinho', 'quadrinho_path_no_storage', 'quadrinho_asset_reiniciar',
       'reservar_quadrinho_asset', 'concluir_quadrinho_asset', 'falhar_quadrinho_asset', 'criar_jobs_quadrinho_admin', 'aprovar_quadrinho_asset_admin',
       'rejeitar_quadrinho_asset_admin', 'regenerar_quadrinho_asset_admin', 'preparar_exclusao_quadrinho_asset_admin', 'excluir_quadrinho_asset_admin',
       'carregar_aula_publicada_da_missao', 'carregar_aula_rascunho_admin', 'eh_admin')) as h_funcoes,
  (select md5(string_agg(id::text || estrutura::text || status || numero_versao::text, '|' order by id)) from public.aula_versoes) as h_versoes,
  (select md5(string_agg(id::text || titulo || ativa::text, '|' order by id)) from public.aulas) as h_aulas,
  (select count(*) from public.matriculas) as n_matriculas,
  (select md5(string_agg(jobid::text || jobname || schedule || md5(command), '|' order by jobid)) from cron.job) as h_cron,
  (select md5(string_agg(name, '|' order by name)) from vault.secrets) as h_vault,
  (select md5(string_agg(table_name::text || grantee::text || privilege_type::text, '|' order by table_name::text, grantee::text, privilege_type::text))
     from information_schema.role_table_grants where table_schema = 'public') as h_grants_tabelas,
  (select md5(string_agg(routine_name::text || grantee::text || privilege_type::text, '|' order by routine_name::text, grantee::text, privilege_type::text))
     from information_schema.role_routine_grants where routine_schema = 'public' and routine_name in ('reservar_quadrinho_asset', 'concluir_quadrinho_asset', 'falhar_quadrinho_asset')) as h_grants_worker,
  (select count(*) from storage.objects where bucket_id = 'quadrinhos-aulas') as n_objetos_bucket;

-- >>> SECAO_PRECOND (identica no harness)
do $$
declare
  v_problemas text := '';
  v_colunas text;
  v_esperado text := 'id:uuid:NO,aula_versao_id:uuid:NO,componente_id:uuid:NO,quadro_indice:smallint:NO,scene_hash:text:NO,status:text:NO,storage_path:text:YES,modelo:text:YES,prompt_version:text:YES,prompt_visual:text:YES,tentativas:smallint:NO,lease_ate:timestamp with time zone:YES,erro_sanitizado:text:YES,aprovado_por:uuid:YES,aprovado_em:timestamp with time zone:YES,criado_em:timestamp with time zone:NO,atualizado_em:timestamp with time zone:NO,claim_token:uuid:YES,storage_path_anterior:text:YES';
  v_fn record;
begin
  if to_regclass('public.aula_quadrinho_assets') is null then
    raise exception 'PRECOND: fundacao Q9/Q10 ausente (public.aula_quadrinho_assets)';
  end if;
  select string_agg(column_name || ':' || data_type || ':' || is_nullable, ',' order by ordinal_position) into v_colunas
  from information_schema.columns where table_schema = 'public' and table_name = 'aula_quadrinho_assets';
  if v_colunas is distinct from v_esperado then
    v_problemas := v_problemas || 'colunas divergem do esperado apos Q9+Q10 (' || coalesce(v_colunas, 'nenhuma') || '); ';
  end if;
  if (select count(*) from pg_constraint where conrelid = 'public.aula_quadrinho_assets'::regclass and contype = 'c') <> 9 then
    v_problemas := v_problemas || 'esperado 9 CHECKs (Q9+Q10); ';
  end if;

  -- as 18 funcoes de Q9 + Q10 devem estar EXATAMENTE como validadas no LIVE
  for v_fn in
    select * from (values
      ('hash_cena_quadrinho', '2779b0d927b88a6946b31636dff13804'),
      ('hash_cena_atual_quadrinho', '0fd391aacd21da2eb83ad06ec38db44b'),
      ('carregar_quadrinho_assets_aula', 'ee2c134d44bdbb00e45f0973eb20e33b'),
      ('carregar_quadrinho_assets_admin', '4d6a052a6b05e49d585fe2c9360d3b84'),
      ('quadrinho_asset_lease', 'a76262802dbb1697663c383565e8140c'),
      ('quadrinho_componente', '800ed4a3d4b69ae956dd3f6f0226e156'),
      ('cena_atual_quadrinho', 'd42813c97e079b7cc96bab6dd3fa513a'),
      ('quadrinho_path_no_storage', '8c90f2e67adb8f3da8426c6aafcb05e9'),
      ('quadrinho_asset_reiniciar', '0ac31e5664bb8d26f16002c2440aa332'),
      ('reservar_quadrinho_asset', '96bd1dff900e00997df38fff61b4ef22'),
      ('concluir_quadrinho_asset', 'd2ebbc27f62bef833048e1137e99bb70'),
      ('falhar_quadrinho_asset', 'ea019a77c4663648de04437fe8c929fa'),
      ('criar_jobs_quadrinho_admin', '6c834af49817ebf263fa07441ba139ef'),
      ('aprovar_quadrinho_asset_admin', '9855caa6a1485dd2bd323c291feb8ea0'),
      ('rejeitar_quadrinho_asset_admin', '99fc111dfd4d18e395d21ad987a8c307'),
      ('regenerar_quadrinho_asset_admin', '237ec790d15cdfcf29310858cb953ad1'),
      ('preparar_exclusao_quadrinho_asset_admin', 'ab629c0ac18cdaecba7a32cacda68a9a'),
      ('excluir_quadrinho_asset_admin', '3bad48fafb9b3a625a43732ee614f118')
    ) as t(nome, md5_esperado)
  loop
    if (select count(*) from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public' and p.proname = v_fn.nome) <> 1
       or (select md5(pg_get_functiondef(p.oid)) from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public' and p.proname = v_fn.nome) is distinct from v_fn.md5_esperado then
      v_problemas := v_problemas || 'funcao Q9/Q10 divergente/ausente: ' || v_fn.nome || '; ';
    end if;
  end loop;

  if not exists (select 1 from storage.buckets where id = 'quadrinhos-aulas' and public = false and file_size_limit = 262144 and allowed_mime_types = array['image/webp']) then
    v_problemas := v_problemas || 'bucket quadrinhos-aulas divergente/ausente; ';
  end if;
  if exists (select 1 from pg_policies where schemaname = 'storage' and tablename = 'objects' and (coalesce(qual, '') || ' ' || coalesce(with_check, '')) like '%quadrinhos-aulas%') then
    v_problemas := v_problemas || 'ja existe policy de storage citando o bucket; ';
  end if;
  if not exists (select 1 from information_schema.columns where table_schema = 'storage' and table_name = 'objects' and column_name in ('created_at', 'updated_at', 'is_delete_marker')
                 group by table_schema having count(*) = 3) then
    v_problemas := v_problemas || 'storage.objects sem created_at/updated_at/is_delete_marker; ';
  end if;

  -- nada deste pacote pode existir
  if exists (
    select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname in (
      'quadrinho_storage_path_claim', 'quadrinho_path_canonico', 'quadrinho_orphan_grace', 'quadrinho_storage_path_protegido',
      'quadrinho_upload_orfao_motivo', 'listar_quadrinho_uploads_orfaos', 'confirmar_quadrinho_upload_orfao')
  ) then
    v_problemas := v_problemas || 'ja existe funcao com nome reservado deste pacote; ';
  end if;

  if v_problemas <> '' then
    raise exception 'PRECOND: %', v_problemas;
  end if;
  raise notice 'PRECOND OK: Q9+Q10 exatamente como validadas; nada do GC existe';
end $$;
-- <<< SECAO_PRECOND

-- >>> SECAO_CORPO (identica no harness)
-- ================= 1) HELPERS DE PATH E GRACE =================
-- Único ponto de ajuste do grace period.
create function public.quadrinho_orphan_grace()
returns interval
language sql
immutable
set search_path to ''
as $$ select interval '30 minutes' $$;

-- FÓRMULA ÚNICA do path de um claim (idêntica à do Q10):
-- <aula_versao_id>/<componente_id>/<quadro_indice>/<scene_hash[0:10]>-<claim_token>.webp
create function public.quadrinho_storage_path_claim(p_aula_versao_id uuid, p_componente_id uuid, p_quadro_indice smallint, p_scene_hash text, p_claim_token uuid)
returns text
language sql
immutable
strict
set search_path to ''
as $$
  select p_aula_versao_id::text || '/' || p_componente_id::text || '/' || p_quadro_indice::text
    || '/' || left(p_scene_hash, 10) || '-' || p_claim_token::text || '.webp'
$$;

-- Formato canônico do objeto do pipeline: UUID/UUID/0-5/10hex-UUID.webp (minúsculo).
-- Qualquer outro nome no bucket é ignorado pelo GC automático.
create function public.quadrinho_path_canonico(p_path text)
returns boolean
language sql
immutable
set search_path to ''
as $$
  select coalesce(
    p_path ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/[0-5]/[0-9a-f]{10}-[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\.webp$',
    false)
$$;

-- ================= 2) PROTEÇÃO =================
-- TRUE se o path é referenciado: (A) storage_path, (B) storage_path_anterior ou
-- (C) path esperado do claim_token ATUAL de uma linha gerando. NÃO usa lease, nem
-- status de aprovação: se está referenciado, está protegido.
create function public.quadrinho_storage_path_protegido(p_path text)
returns boolean
language sql
stable
set search_path to ''
as $$
  select p_path is not null and (
    exists (select 1 from public.aula_quadrinho_assets q where q.storage_path = p_path)
    or exists (select 1 from public.aula_quadrinho_assets q where q.storage_path_anterior = p_path)
    or exists (
      select 1 from public.aula_quadrinho_assets q
      where q.status = 'gerando' and q.claim_token is not null
        and public.quadrinho_storage_path_claim(q.aula_versao_id, q.componente_id, q.quadro_indice, q.scene_hash, q.claim_token) = p_path
    )
  )
$$;

-- Classificador com timestamps EXPLÍCITOS (testável sem esperar 30 min). Interno:
-- nem service_role executa (as RPCs abaixo passam sempre now() e o grace real).
-- Ordem: padrão -> proteções -> existência -> idade.
create function public.quadrinho_upload_orfao_motivo(p_path text, p_criado_em timestamptz, p_agora timestamptz)
returns text
language plpgsql
stable
set search_path to ''
as $$
begin
  if p_agora is null then
    raise exception 'p_agora obrigatorio';
  end if;
  if not public.quadrinho_path_canonico(p_path) then
    return 'fora_do_padrao';
  end if;
  if public.quadrinho_storage_path_protegido(p_path) then
    if exists (select 1 from public.aula_quadrinho_assets q where q.storage_path = p_path) then
      return 'protegido_storage_path';
    end if;
    if exists (select 1 from public.aula_quadrinho_assets q where q.storage_path_anterior = p_path) then
      return 'protegido_storage_path_anterior';
    end if;
    return 'protegido_claim_atual';
  end if;
  if p_criado_em is null then
    return 'objeto_inexistente';
  end if;
  if p_agora - p_criado_em < public.quadrinho_orphan_grace() then
    return 'recente';
  end if;
  return 'orfao';
end;
$$;

-- ================= 3) RPCs PARA A FUTURA EDGE (somente service_role) =================
-- Lista candidatos a órfão (máx. 100 por chamada), mais antigos primeiro. Só leitura.
-- Retorna o mínimo: path, datas, tamanho e idade — nada de aula/usuário/conteúdo.
create function public.listar_quadrinho_uploads_orfaos(p_limite integer default 100)
returns table (storage_path text, criado_em timestamptz, atualizado_em timestamptz, tamanho_bytes bigint, idade_segundos integer)
language plpgsql
stable
security definer
set search_path to ''
as $$
declare
  v_agora timestamptz := now();
begin
  if p_limite is null or p_limite < 1 or p_limite > 100 then
    raise exception 'p_limite deve estar entre 1 e 100';
  end if;

  return query
  select o.name, o.created_at, o.updated_at,
    case when (o.metadata->>'size') ~ '^[0-9]+$' then (o.metadata->>'size')::bigint end,
    extract(epoch from (v_agora - greatest(o.created_at, o.updated_at)))::integer
  from storage.objects o
  where o.bucket_id = 'quadrinhos-aulas'
    and o.is_delete_marker is not true
    and public.quadrinho_upload_orfao_motivo(o.name, greatest(o.created_at, o.updated_at), v_agora) = 'orfao'
  order by greatest(o.created_at, o.updated_at), o.name
  limit p_limite;
end;
$$;

-- Reconfirmação IMEDIATA antes de cada delete físico: repete padrão, proteções,
-- existência e idade. orfao=true só se TUDO ainda valer.
create function public.confirmar_quadrinho_upload_orfao(p_storage_path text)
returns table (orfao boolean, motivo text)
language plpgsql
stable
security definer
set search_path to ''
as $$
declare
  v_criado timestamptz;
  v_motivo text;
begin
  if p_storage_path is null or length(btrim(p_storage_path)) = 0 then
    raise exception 'p_storage_path obrigatorio';
  end if;

  select greatest(o.created_at, o.updated_at) into v_criado
  from storage.objects o
  where o.bucket_id = 'quadrinhos-aulas' and o.name = p_storage_path and o.is_delete_marker is not true;

  v_motivo := public.quadrinho_upload_orfao_motivo(p_storage_path, v_criado, now());
  orfao := (v_motivo = 'orfao');
  motivo := v_motivo;
  return next;
end;
$$;

-- ================= 4) CENTRALIZAR A FÓRMULA NO CLAIM E NA CONCLUSÃO =================
-- Mesmo texto do Q10; só a expressão do path passa a usar o helper único.
create or replace function public.reservar_quadrinho_asset(p_aula_versao_id uuid default null)
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
    storage_path_esperado := public.quadrinho_storage_path_claim(v_row.aula_versao_id, v_row.componente_id, v_row.quadro_indice, v_row.scene_hash, v_token);
    return next;
    return;
  end loop;
end;
$$;

create or replace function public.concluir_quadrinho_asset(
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
  v_esperado := public.quadrinho_storage_path_claim(v_row.aula_versao_id, v_row.componente_id, v_row.quadro_indice, v_row.scene_hash, p_claim_token);
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

-- ================= 5) GRANTS =================
revoke all on function public.quadrinho_orphan_grace() from public, anon, authenticated;
revoke all on function public.quadrinho_storage_path_claim(uuid, uuid, smallint, text, uuid) from public, anon, authenticated;
revoke all on function public.quadrinho_path_canonico(text) from public, anon, authenticated;
revoke all on function public.quadrinho_storage_path_protegido(text) from public, anon, authenticated;
revoke all on function public.quadrinho_upload_orfao_motivo(text, timestamptz, timestamptz) from public, anon, authenticated, service_role;
revoke all on function public.listar_quadrinho_uploads_orfaos(integer) from public, anon, authenticated;
revoke all on function public.confirmar_quadrinho_upload_orfao(text) from public, anon, authenticated;
grant execute on function public.listar_quadrinho_uploads_orfaos(integer) to service_role;
grant execute on function public.confirmar_quadrinho_upload_orfao(text) to service_role;
-- <<< SECAO_CORPO

-- >>> SECAO_POSCOND (identica no harness)
do $$
declare
  v_fn text;
  v_papel text;
  v_q record;
  v_tok constant uuid := '11111111-2222-3333-4444-555555555555';
  v_v constant uuid := 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee';
  v_c constant uuid := 'ffffffff-0000-1111-2222-333333333333';
  v_h constant text := repeat('ab', 32);
  v_path text;
begin
  -- funcoes Q9 e as 12 de Q10 NAO substituidas: inalteradas
  for v_q in
    select * from (values
      ('hash_cena_quadrinho', '2779b0d927b88a6946b31636dff13804'),
      ('hash_cena_atual_quadrinho', '0fd391aacd21da2eb83ad06ec38db44b'),
      ('carregar_quadrinho_assets_aula', 'ee2c134d44bdbb00e45f0973eb20e33b'),
      ('carregar_quadrinho_assets_admin', '4d6a052a6b05e49d585fe2c9360d3b84'),
      ('quadrinho_asset_lease', 'a76262802dbb1697663c383565e8140c'),
      ('quadrinho_componente', '800ed4a3d4b69ae956dd3f6f0226e156'),
      ('cena_atual_quadrinho', 'd42813c97e079b7cc96bab6dd3fa513a'),
      ('quadrinho_path_no_storage', '8c90f2e67adb8f3da8426c6aafcb05e9'),
      ('quadrinho_asset_reiniciar', '0ac31e5664bb8d26f16002c2440aa332'),
      ('falhar_quadrinho_asset', 'ea019a77c4663648de04437fe8c929fa'),
      ('criar_jobs_quadrinho_admin', '6c834af49817ebf263fa07441ba139ef'),
      ('aprovar_quadrinho_asset_admin', '9855caa6a1485dd2bd323c291feb8ea0'),
      ('rejeitar_quadrinho_asset_admin', '99fc111dfd4d18e395d21ad987a8c307'),
      ('regenerar_quadrinho_asset_admin', '237ec790d15cdfcf29310858cb953ad1'),
      ('preparar_exclusao_quadrinho_asset_admin', 'ab629c0ac18cdaecba7a32cacda68a9a'),
      ('excluir_quadrinho_asset_admin', '3bad48fafb9b3a625a43732ee614f118')
    ) as t(nome, md5_esperado)
  loop
    if (select md5(pg_get_functiondef(p.oid)) from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public' and p.proname = v_q.nome) is distinct from v_q.md5_esperado then
      raise exception 'POSCOND: funcao alterada indevidamente: %', v_q.nome;
    end if;
  end loop;

  -- reservar/concluir: agora usam o helper; nenhuma formula/literal .webp restante
  foreach v_fn in array array['public.reservar_quadrinho_asset(uuid)', 'public.concluir_quadrinho_asset(uuid,uuid,text,text,text,text,text)'] loop
    if position('public.quadrinho_storage_path_claim' in pg_get_functiondef(v_fn::regprocedure)) = 0 then raise exception 'POSCOND: % nao usa o helper de path', v_fn; end if;
    if position('.webp' in pg_get_functiondef(v_fn::regprocedure)) > 0 then raise exception 'POSCOND: % ainda contem a formula de path', v_fn; end if;
    if not (select p.prosecdef from pg_proc p where p.oid = v_fn::regprocedure) then raise exception 'POSCOND: % deveria ser SECURITY DEFINER', v_fn; end if;
    if not exists (select 1 from pg_proc p where p.oid = v_fn::regprocedure and p.proconfig @> array['search_path=""']) then raise exception 'POSCOND: % sem search_path vazio', v_fn; end if;
    foreach v_papel in array array['anon', 'authenticated'] loop
      if has_function_privilege(v_papel, v_fn::regprocedure, 'execute') then raise exception 'POSCOND: % executa %', v_papel, v_fn; end if;
    end loop;
    if not has_function_privilege('service_role', v_fn::regprocedure, 'execute') then raise exception 'POSCOND: service_role sem execute em %', v_fn; end if;
  end loop;

  -- grants do GC
  foreach v_fn in array array['public.quadrinho_orphan_grace()', 'public.quadrinho_storage_path_claim(uuid,uuid,smallint,text,uuid)', 'public.quadrinho_path_canonico(text)', 'public.quadrinho_storage_path_protegido(text)', 'public.quadrinho_upload_orfao_motivo(text,timestamptz,timestamptz)', 'public.listar_quadrinho_uploads_orfaos(integer)', 'public.confirmar_quadrinho_upload_orfao(text)'] loop
    foreach v_papel in array array['anon', 'authenticated'] loop
      if has_function_privilege(v_papel, v_fn::regprocedure, 'execute') then raise exception 'POSCOND: % executa %', v_papel, v_fn; end if;
    end loop;
  end loop;
  foreach v_fn in array array['public.listar_quadrinho_uploads_orfaos(integer)', 'public.confirmar_quadrinho_upload_orfao(text)'] loop
    if not has_function_privilege('service_role', v_fn::regprocedure, 'execute') then raise exception 'POSCOND: service_role sem execute em %', v_fn; end if;
    if not (select p.prosecdef from pg_proc p where p.oid = v_fn::regprocedure) then raise exception 'POSCOND: % deveria ser SECURITY DEFINER', v_fn; end if;
    if not exists (select 1 from pg_proc p where p.oid = v_fn::regprocedure and p.proconfig @> array['search_path=""']) then raise exception 'POSCOND: % sem search_path vazio', v_fn; end if;
  end loop;
  if has_function_privilege('service_role', 'public.quadrinho_upload_orfao_motivo(text,timestamptz,timestamptz)'::regprocedure, 'execute') then
    raise exception 'POSCOND: o classificador com timestamp explicito nao pode ser executavel por service_role';
  end if;

  -- comportamento puro (somente leitura)
  if public.quadrinho_orphan_grace() <> interval '30 minutes' then raise exception 'POSCOND: grace'; end if;
  v_path := public.quadrinho_storage_path_claim(v_v, v_c, 3::smallint, v_h, v_tok);
  if v_path <> 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee/ffffffff-0000-1111-2222-333333333333/3/ababababab-11111111-2222-3333-4444-555555555555.webp' then
    raise exception 'POSCOND: formula do path: %', v_path;
  end if;
  if not public.quadrinho_path_canonico(v_path) then raise exception 'POSCOND: path do helper nao e canonico'; end if;
  if public.quadrinho_path_canonico('_testes/q11-1/x.webp') or public.quadrinho_path_canonico(null) then raise exception 'POSCOND: canonico aceitou path invalido'; end if;
  if public.quadrinho_upload_orfao_motivo('_testes/q11-1/x.webp', now() - interval '1 year', now()) <> 'fora_do_padrao' then raise exception 'POSCOND: fora_do_padrao'; end if;
  if public.quadrinho_upload_orfao_motivo(v_path, now() - interval '5 minutes', now()) <> 'recente' then raise exception 'POSCOND: recente'; end if;
  if public.quadrinho_upload_orfao_motivo(v_path, now() - interval '31 minutes', now()) <> 'orfao' then raise exception 'POSCOND: orfao'; end if;

  raise notice 'POSCOND OK: helpers, RPCs de GC, reservar/concluir centralizados, grants e Q9/Q10 intactos';
end $$;
-- <<< SECAO_POSCOND

-- ============================================================================
-- V) ESCOPO: só o GC foi criado/alterado; sem colunas, policies, cron, bucket
-- ============================================================================
do $$
declare
  v_snap record;
  v_novas_rel text[];
  v_novas_fn text[];
  v_h_atual jsonb;
begin
  select * into v_snap from _q112_snap_estado;

  select array_agg(c.relname::text) into v_novas_rel
  from pg_class c join pg_namespace n on n.oid = c.relnamespace
  where n.nspname = 'public' and c.relname::text not in (select nome from _q112_snap_rel);
  perform pg_temp.q112_reg('escopo_nenhuma_relacao_nova', v_novas_rel is null);

  select array_agg(p.proname::text) into v_novas_fn
  from pg_proc p join pg_namespace n on n.oid = p.pronamespace
  where n.nspname = 'public' and p.oid::text not in (select nome from _q112_snap_fn);
  perform pg_temp.q112_reg('escopo_exatamente_7_funcoes_novas',
    v_novas_fn @> array['quadrinho_storage_path_claim', 'quadrinho_path_canonico', 'quadrinho_orphan_grace', 'quadrinho_storage_path_protegido',
      'quadrinho_upload_orfao_motivo', 'listar_quadrinho_uploads_orfaos', 'confirmar_quadrinho_upload_orfao'] and cardinality(v_novas_fn) = 7);

  perform pg_temp.q112_reg('escopo_sem_novas_colunas_e_constraints_iguais',
    (select string_agg(column_name || ':' || data_type || ':' || is_nullable, ',' order by ordinal_position)
       from information_schema.columns where table_schema = 'public' and table_name = 'aula_quadrinho_assets') = v_snap.colunas
    and not exists (select nome from _q112_snap_cons except select conname::text from pg_constraint where conrelid = 'public.aula_quadrinho_assets'::regclass)
    and not exists (select conname::text from pg_constraint where conrelid = 'public.aula_quadrinho_assets'::regclass except select nome from _q112_snap_cons));
  perform pg_temp.q112_reg('escopo_nenhuma_policy_nova_ou_removida',
    not exists (select schemaname::text || '.' || tablename::text || '.' || policyname::text from pg_policies except select nome from _q112_snap_pol)
    and not exists (select nome from _q112_snap_pol except select schemaname::text || '.' || tablename::text || '.' || policyname::text from pg_policies));
  perform pg_temp.q112_reg('escopo_bucket_intacto',
    not exists (select id::text || ':' || public::text || ':' || coalesce(file_size_limit::text, '') || ':' || coalesce(allowed_mime_types::text, '') from storage.buckets except select nome from _q112_snap_bucket)
    and not exists (select nome from _q112_snap_bucket except select id::text || ':' || public::text || ':' || coalesce(file_size_limit::text, '') || ':' || coalesce(allowed_mime_types::text, '') from storage.buckets));

  select jsonb_object_agg(p.proname, md5(pg_get_functiondef(p.oid))) into v_h_atual from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname in ('hash_cena_quadrinho', 'hash_cena_atual_quadrinho', 'carregar_quadrinho_assets_aula', 'carregar_quadrinho_assets_admin',
       'quadrinho_asset_lease', 'quadrinho_componente', 'cena_atual_quadrinho', 'quadrinho_path_no_storage', 'quadrinho_asset_reiniciar',
       'reservar_quadrinho_asset', 'concluir_quadrinho_asset', 'falhar_quadrinho_asset', 'criar_jobs_quadrinho_admin', 'aprovar_quadrinho_asset_admin',
       'rejeitar_quadrinho_asset_admin', 'regenerar_quadrinho_asset_admin', 'preparar_exclusao_quadrinho_asset_admin', 'excluir_quadrinho_asset_admin',
       'carregar_aula_publicada_da_missao', 'carregar_aula_rascunho_admin', 'eh_admin');
  perform pg_temp.q112_reg('escopo_so_reservar_e_concluir_mudaram_entre_as_funcoes_existentes',
    (select array_agg(k order by k) from jsonb_object_keys(v_h_atual) k where v_h_atual->>k is distinct from v_snap.h_funcoes->>k) = array['concluir_quadrinho_asset', 'reservar_quadrinho_asset']);
  perform pg_temp.q112_reg('escopo_reservar_e_concluir_agora_usam_o_helper_e_nao_tem_mais_a_formula',
    position('public.quadrinho_storage_path_claim' in pg_get_functiondef('public.reservar_quadrinho_asset(uuid)'::regprocedure)) > 0
    and position('public.quadrinho_storage_path_claim' in pg_get_functiondef('public.concluir_quadrinho_asset(uuid,uuid,text,text,text,text,text)'::regprocedure)) > 0
    and position('.webp' in pg_get_functiondef('public.reservar_quadrinho_asset(uuid)'::regprocedure)) = 0
    and position('.webp' in pg_get_functiondef('public.concluir_quadrinho_asset(uuid,uuid,text,text,text,text,text)'::regprocedure)) = 0);
  perform pg_temp.q112_reg('escopo_grants_do_worker_preservados',
    v_snap.h_grants_worker is not distinct from (select md5(string_agg(routine_name::text || grantee::text || privilege_type::text, '|' order by routine_name::text, grantee::text, privilege_type::text))
       from information_schema.role_routine_grants where routine_schema = 'public' and routine_name in ('reservar_quadrinho_asset', 'concluir_quadrinho_asset', 'falhar_quadrinho_asset')));
  perform pg_temp.q112_reg('escopo_versoes_aulas_cron_vault_e_grants_de_tabela_intactos',
    v_snap.h_versoes is not distinct from (select md5(string_agg(id::text || estrutura::text || status || numero_versao::text, '|' order by id)) from public.aula_versoes)
    and v_snap.h_aulas is not distinct from (select md5(string_agg(id::text || titulo || ativa::text, '|' order by id)) from public.aulas)
    and v_snap.h_cron is not distinct from (select md5(string_agg(jobid::text || jobname || schedule || md5(command), '|' order by jobid)) from cron.job)
    and v_snap.h_vault is not distinct from (select md5(string_agg(name, '|' order by name)) from vault.secrets)
    and v_snap.h_grants_tabelas is not distinct from (select md5(string_agg(table_name::text || grantee::text || privilege_type::text, '|' order by table_name::text, grantee::text, privilege_type::text)) from information_schema.role_table_grants where table_schema = 'public'));
  perform pg_temp.q112_reg('escopo_tabela_vazia_e_bucket_sem_objetos',
    (select count(*) from public.aula_quadrinho_assets) = 0 and (select count(*) from storage.objects where bucket_id = 'quadrinhos-aulas') = 0);
end $$;

-- ============================================================================
-- HELPERS PUROS: fórmula, formato canônico, grace
-- ============================================================================
do $$
declare
  v_v constant uuid := 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee';
  v_c constant uuid := 'ffffffff-0000-1111-2222-333333333333';
  v_t constant uuid := '11111111-2222-3333-4444-555555555555';
  v_h constant text := repeat('0123456789abcdef', 4);
  v_ok text := v_v::text || '/' || v_c::text || '/2/' || left(v_h, 10) || '-' || v_t::text || '.webp';
  v_p text;
  v_todos boolean := true;
  v_nenhum boolean := true;
begin
  perform pg_temp.q112_reg('grace_e_30_minutos', public.quadrinho_orphan_grace() = interval '30 minutes');
  perform pg_temp.q112_reg('path_helper_igual_a_formula_literal_do_Q10', public.quadrinho_storage_path_claim(v_v, v_c, 2::smallint, v_h, v_t) = v_ok);
  perform pg_temp.q112_reg('path_helper_estrito_nulo_devolve_nulo', public.quadrinho_storage_path_claim(v_v, v_c, 2::smallint, v_h, null) is null);
  perform pg_temp.q112_reg('path_helper_gera_path_canonico', public.quadrinho_path_canonico(v_ok));
  for i in 0 .. 5 loop
    if not public.quadrinho_path_canonico(public.quadrinho_storage_path_claim(v_v, v_c, i::smallint, v_h, v_t)) then v_todos := false; end if;
  end loop;
  perform pg_temp.q112_reg('canonico_aceita_indices_0_a_5', v_todos);
  foreach v_p in array array[
    v_ok || 'x', upper(v_ok), '/' || v_ok, replace(v_ok, '/2/', '/6/'), replace(v_ok, '/2/', '/22/'), replace(v_ok, '.webp', '.png'), replace(v_ok, '.webp', ''),
    replace(v_ok, left(v_h, 10), left(v_h, 9)), replace(v_ok, left(v_h, 10), 'ABCDEF0123'), v_ok || '/extra', 'extra/' || v_ok, v_v::text || '/' || v_ok,
    '_testes/q11-1/x.webp', '../' || v_ok, replace(v_ok, v_c::text, '..'), 'a/b/c/d.webp', '', '   ', '.emptyFolderPlaceholder'] loop
    if public.quadrinho_path_canonico(v_p) then v_nenhum := false; end if;
  end loop;
  perform pg_temp.q112_reg('canonico_rejeita_variacoes_e_paths_fora_do_padrao', v_nenhum);
  perform pg_temp.q112_reg('canonico_null_e_false', public.quadrinho_path_canonico(null) is false);
end $$;

-- ============================================================================
-- GRANTS REAIS (SET LOCAL ROLE)
-- ============================================================================
create temporary table _q112_papeis (chave text primary key, ok boolean);

do $$
declare
  v_ok boolean;
  v_n int;
begin
  v_ok := false;
  begin set local role authenticated; perform * from public.listar_quadrinho_uploads_orfaos(10); exception when insufficient_privilege then v_ok := true; end;
  reset role; insert into _q112_papeis values ('authenticated_nao_executa_listar', v_ok);
  v_ok := false;
  begin set local role anon; perform * from public.listar_quadrinho_uploads_orfaos(10); exception when insufficient_privilege then v_ok := true; end;
  reset role; insert into _q112_papeis values ('anon_nao_executa_listar', v_ok);
  v_ok := false;
  begin set local role authenticated; perform * from public.confirmar_quadrinho_upload_orfao('x'); exception when insufficient_privilege then v_ok := true; end;
  reset role; insert into _q112_papeis values ('authenticated_nao_executa_confirmar', v_ok);
  v_ok := false;
  begin set local role anon; perform * from public.confirmar_quadrinho_upload_orfao('x'); exception when insufficient_privilege then v_ok := true; end;
  reset role; insert into _q112_papeis values ('anon_nao_executa_confirmar', v_ok);
  v_ok := false;
  begin set local role authenticated; perform public.quadrinho_storage_path_protegido('x'); exception when insufficient_privilege then v_ok := true; end;
  reset role; insert into _q112_papeis values ('authenticated_nao_executa_protegido', v_ok);
  v_ok := false;
  begin set local role authenticated; perform public.quadrinho_upload_orfao_motivo('x', now(), now()); exception when insufficient_privilege then v_ok := true; end;
  reset role; insert into _q112_papeis values ('authenticated_nao_executa_classificador', v_ok);
  v_ok := false;
  begin set local role service_role; perform public.quadrinho_upload_orfao_motivo('x', now(), now()); exception when insufficient_privilege then v_ok := true; end;
  reset role; insert into _q112_papeis values ('service_role_nao_executa_classificador_com_timestamp_explicito', v_ok);
  v_ok := false;
  begin set local role authenticated; perform public.quadrinho_storage_path_claim(gen_random_uuid(), gen_random_uuid(), 0::smallint, repeat('a', 64), gen_random_uuid()); exception when insufficient_privilege then v_ok := true; end;
  reset role; insert into _q112_papeis values ('authenticated_nao_executa_helper_de_path', v_ok);
  v_ok := false;
  begin set local role authenticated; perform * from public.reservar_quadrinho_asset(); exception when insufficient_privilege then v_ok := true; end;
  reset role; insert into _q112_papeis values ('authenticated_continua_sem_reservar', v_ok);
  v_ok := false;
  begin
    set local role service_role;
    select count(*) into v_n from public.listar_quadrinho_uploads_orfaos(100);
    v_ok := (v_n = 0);
  exception when others then v_ok := false; end;
  reset role; insert into _q112_papeis values ('service_role_executa_listar_bucket_vazio_retorna_zero', v_ok);
  v_ok := false;
  begin
    set local role service_role;
    select (select count(*) from public.confirmar_quadrinho_upload_orfao('_testes/q11-1/x.webp') where orfao is false and motivo = 'fora_do_padrao') = 1 into v_ok;
  exception when others then v_ok := false; end;
  reset role; insert into _q112_papeis values ('service_role_executa_confirmar', v_ok);
end $$;

insert into teste_q112 (chave, ok) select chave, ok from _q112_papeis;

-- ============================================================================
-- CLASSIFICADOR: padrão, grace (com timestamps controlados), inexistente
-- ============================================================================
do $$
declare
  v_agora constant timestamptz := timestamptz '2030-01-01 12:00:00+00';
  v_p constant text := 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee/ffffffff-0000-1111-2222-333333333333/1/0123456789-99999999-8888-7777-6666-555555555555.webp';
begin
  perform pg_temp.q112_reg('classificador_fora_do_padrao_nunca_e_candidato_mesmo_antigo',
    public.quadrinho_upload_orfao_motivo('_testes/q11-1/x.webp', v_agora - interval '10 years', v_agora) = 'fora_do_padrao'
    and public.quadrinho_upload_orfao_motivo('Documento Administrativo.webp', v_agora - interval '10 years', v_agora) = 'fora_do_padrao'
    and public.quadrinho_upload_orfao_motivo(upper(v_p), v_agora - interval '10 years', v_agora) = 'fora_do_padrao'
    and public.quadrinho_upload_orfao_motivo(null, v_agora - interval '10 years', v_agora) = 'fora_do_padrao');
  perform pg_temp.q112_reg('classificador_canonico_recente_nao_e_candidato',
    public.quadrinho_upload_orfao_motivo(v_p, v_agora - interval '5 minutes', v_agora) = 'recente'
    and public.quadrinho_upload_orfao_motivo(v_p, v_agora, v_agora) = 'recente'
    and public.quadrinho_upload_orfao_motivo(v_p, v_agora + interval '1 hour', v_agora) = 'recente');
  perform pg_temp.q112_reg('classificador_grace_no_limite_exato',
    public.quadrinho_upload_orfao_motivo(v_p, v_agora - interval '29 minutes 59 seconds', v_agora) = 'recente'
    and public.quadrinho_upload_orfao_motivo(v_p, v_agora - interval '30 minutes', v_agora) = 'orfao');
  perform pg_temp.q112_reg('classificador_canonico_antigo_sem_referencia_e_orfao', public.quadrinho_upload_orfao_motivo(v_p, v_agora - interval '1 day', v_agora) = 'orfao');
  perform pg_temp.q112_reg('classificador_sem_objeto_e_inexistente', public.quadrinho_upload_orfao_motivo(v_p, null, v_agora) = 'objeto_inexistente');
  perform pg_temp.q112_reg('classificador_exige_agora', pg_temp.q112_raises(format('select public.quadrinho_upload_orfao_motivo(%L, now(), null)', v_p), 'p_agora obrigatorio%'));
  perform pg_temp.q112_reg('protegido_null_e_falso_e_path_desconhecido_e_falso', public.quadrinho_storage_path_protegido(null) is false and public.quadrinho_storage_path_protegido(v_p) is false);
end $$;

-- ============================================================================
-- LIMITES E CONTRATO DAS RPCs (bucket vazio)
-- ============================================================================
do $$
declare
  v_n int;
begin
  perform pg_temp.q112_reg('listar_limite_zero_bloqueado', pg_temp.q112_raises('select * from public.listar_quadrinho_uploads_orfaos(0)', 'p_limite deve estar entre 1 e 100%'));
  perform pg_temp.q112_reg('listar_limite_101_bloqueado', pg_temp.q112_raises('select * from public.listar_quadrinho_uploads_orfaos(101)', 'p_limite deve estar entre 1 e 100%'));
  perform pg_temp.q112_reg('listar_limite_negativo_bloqueado', pg_temp.q112_raises('select * from public.listar_quadrinho_uploads_orfaos(-5)', 'p_limite deve estar entre 1 e 100%'));
  perform pg_temp.q112_reg('listar_limite_nulo_bloqueado', pg_temp.q112_raises('select * from public.listar_quadrinho_uploads_orfaos(null)', 'p_limite deve estar entre 1 e 100%'));
  select count(*) into v_n from public.listar_quadrinho_uploads_orfaos();
  perform pg_temp.q112_reg('listar_default_100_sem_objetos_retorna_vazio', v_n = 0);
  select count(*) into v_n from public.listar_quadrinho_uploads_orfaos(1);
  perform pg_temp.q112_reg('listar_limites_1_e_100_aceitos', v_n = 0 and (select count(*) from public.listar_quadrinho_uploads_orfaos(100)) = 0);
  perform pg_temp.q112_reg('listar_retorna_apenas_colunas_de_auditoria_minimas',
    (select array_agg(x.nome order by x.ord) from pg_proc p, unnest(p.proargnames, p.proargmodes) with ordinality as x(nome, modo, ord)
      where p.oid = 'public.listar_quadrinho_uploads_orfaos(integer)'::regprocedure and x.modo = 't')
    = array['storage_path', 'criado_em', 'atualizado_em', 'tamanho_bytes', 'idade_segundos']);
  perform pg_temp.q112_reg('confirmar_path_nulo_ou_vazio_bloqueado', pg_temp.q112_raises('select * from public.confirmar_quadrinho_upload_orfao(null)', 'p_storage_path obrigatorio%')
    and pg_temp.q112_raises('select * from public.confirmar_quadrinho_upload_orfao(''   '')', 'p_storage_path obrigatorio%'));
  perform pg_temp.q112_reg('confirmar_fora_do_padrao_e_falso', (select orfao is false and motivo = 'fora_do_padrao' from public.confirmar_quadrinho_upload_orfao('_testes/q11-1/x.webp')));
  perform pg_temp.q112_reg('confirmar_canonico_sem_objeto_no_bucket_e_falso_objeto_inexistente', (
    select orfao is false and motivo = 'objeto_inexistente' from public.confirmar_quadrinho_upload_orfao('aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee/ffffffff-0000-1111-2222-333333333333/1/0123456789-99999999-8888-7777-6666-555555555555.webp')));
end $$;

-- ============================================================================
-- REGRESSÃO de reservar/concluir/falhar (recriadas) + PROTEÇÕES A/B/C + stale token
-- Fixtures: SOMENTE linhas de public.aula_quadrinho_assets (piloto como referência)
-- ============================================================================
do $$
declare
  v_p constant uuid := '52756262-8be4-4fb2-a9f3-2f5a158ea1d4';
  v_c constant uuid := '1f4065f2-8fda-4f7d-8826-45955230678d';
  v_agora constant timestamptz := timestamptz '2030-01-01 12:00:00+00';
  v_antigo constant timestamptz := timestamptz '2020-01-01 12:00:00+00';
  v_asset uuid; v_h text; v_admin uuid;
  v_tok_a uuid; v_path_a text; v_tok_b uuid; v_path_b text;
  r record; r2 record;
  v_n int; i int;
  v_md5_antes text;
begin
  select usuario_id into v_admin from public.administradores order by criado_em limit 1;
  v_h := public.hash_cena_atual_quadrinho(v_p, v_c, 0::smallint);
  insert into public.aula_quadrinho_assets (aula_versao_id, componente_id, quadro_indice, scene_hash) values (v_p, v_c, 0, v_h) returning id into v_asset;

  -- ---- claim A: comportamento do Q10 preservado, path = helper = formula literal ----
  select * into r from public.reservar_quadrinho_asset(v_p);
  v_tok_a := r.claim_token; v_path_a := r.storage_path_esperado;
  perform pg_temp.q112_reg('reservar_continua_retornando_as_10_colunas_do_contrato',
    (select array_agg(k) from jsonb_object_keys(to_jsonb(r)) as k) @> array['asset_id', 'aula_versao_id', 'componente_id', 'quadro_indice', 'scene_hash', 'cena', 'tentativa', 'claim_token', 'lease_ate', 'storage_path_esperado']
    and (select count(*) from jsonb_object_keys(to_jsonb(r)) as k) = 10);
  perform pg_temp.q112_reg('reservar_estado_gerando_tentativa_1_lease_10min', r.tentativa = 1 and (
    select q.status = 'gerando' and q.tentativas = 1 and q.claim_token = v_tok_a and q.lease_ate = now() + interval '10 minutes' from public.aula_quadrinho_assets q where q.id = v_asset));
  perform pg_temp.q112_reg('reservar_path_igual_ao_helper', v_path_a = public.quadrinho_storage_path_claim(v_p, v_c, 0::smallint, v_h, v_tok_a));
  perform pg_temp.q112_reg('reservar_path_igual_a_formula_literal_do_Q10', v_path_a = v_p::text || '/' || v_c::text || '/0/' || left(v_h, 10) || '-' || v_tok_a::text || '.webp');
  perform pg_temp.q112_reg('reservar_path_e_canonico', public.quadrinho_path_canonico(v_path_a));

  -- ---- C: claim atual protege (lease valido e, depois, lease EXPIRADO) ----
  perform pg_temp.q112_reg('C_claim_atual_com_lease_valido_e_protegido', public.quadrinho_storage_path_protegido(v_path_a)
    and public.quadrinho_upload_orfao_motivo(v_path_a, v_antigo, v_agora) = 'protegido_claim_atual');
  update public.aula_quadrinho_assets set lease_ate = now() - interval '2 hours' where id = v_asset;
  perform pg_temp.q112_reg('D_claim_atual_com_lease_expirado_continua_protegido', public.quadrinho_storage_path_protegido(v_path_a)
    and public.quadrinho_upload_orfao_motivo(v_path_a, v_antigo, v_agora) = 'protegido_claim_atual'
    and (select orfao is false and motivo = 'protegido_claim_atual' from public.confirmar_quadrinho_upload_orfao(v_path_a)));

  -- ---- E: worker B substitui o claim; token A deixa de proteger ----
  select * into r from public.reservar_quadrinho_asset(v_p);
  v_tok_b := r.claim_token; v_path_b := r.storage_path_esperado;
  perform pg_temp.q112_reg('lease_expirado_recuperavel_com_token_novo_e_path_novo', r.asset_id = v_asset and r.tentativa = 2 and v_tok_b <> v_tok_a and v_path_b <> v_path_a);
  perform pg_temp.q112_reg('E_token_A_antigo_deixa_de_proteger_o_path_A', not public.quadrinho_storage_path_protegido(v_path_a));
  perform pg_temp.q112_reg('E_path_A_dentro_do_grace_nao_e_candidato', public.quadrinho_upload_orfao_motivo(v_path_a, v_agora - interval '5 minutes', v_agora) = 'recente');
  perform pg_temp.q112_reg('E_path_A_com_grace_vencido_e_candidato', public.quadrinho_upload_orfao_motivo(v_path_a, v_agora - interval '31 minutes', v_agora) = 'orfao');
  perform pg_temp.q112_reg('E_path_B_do_claim_atual_protegido', public.quadrinho_storage_path_protegido(v_path_b)
    and public.quadrinho_upload_orfao_motivo(v_path_b, v_antigo, v_agora) = 'protegido_claim_atual');
  perform pg_temp.q112_reg('confirmar_path_A_sem_objeto_nao_e_orfao_pois_objeto_inexistente', (select orfao is false and motivo = 'objeto_inexistente' from public.confirmar_quadrinho_upload_orfao(v_path_a)));

  -- ---- fencing do Q10 preservado (concluir/falhar com o token velho) ----
  select * into r2 from public.concluir_quadrinho_asset(v_asset, v_tok_a, v_h, v_path_a, 'teste-q112', 'teste-q112', 'fixture harness');
  perform pg_temp.q112_reg('fencing_concluir_token_A_recusado', r2.aceito is false and r2.motivo = 'claim_invalido');
  select * into r2 from public.falhar_quadrinho_asset(v_asset, v_tok_a, 'erro do worker antigo');
  perform pg_temp.q112_reg('fencing_falhar_token_A_recusado', r2.aceito is false and r2.motivo = 'claim_invalido');
  perform pg_temp.q112_reg('fencing_linha_continua_do_worker_B', (select status = 'gerando' and claim_token = v_tok_b and storage_path is null from public.aula_quadrinho_assets where id = v_asset));
  perform pg_temp.q112_reg('concluir_path_fora_do_padrao_do_claim_falha', pg_temp.q112_raises(
    format('select * from public.concluir_quadrinho_asset(%L, %L, %L, %L, ''m'', ''p'', ''v'')', v_asset, v_tok_b, v_h, 'q/outro.webp'), 'storage_path fora do padrao%'));
  perform pg_temp.q112_reg('concluir_com_path_do_token_A_e_recusado_para_o_claim_B', pg_temp.q112_raises(
    format('select * from public.concluir_quadrinho_asset(%L, %L, %L, %L, ''m'', ''p'', ''v'')', v_asset, v_tok_b, v_h, v_path_a), 'storage_path fora do padrao%'));

  -- ---- conclusão aceita o path do helper; A protege para sempre ----
  select * into r2 from public.concluir_quadrinho_asset(v_asset, v_tok_b, v_h, v_path_b, 'teste-q112', 'teste-q112', 'fixture harness');
  perform pg_temp.q112_reg('concluir_aceita_o_path_do_helper', r2.aceito is true and r2.motivo = 'concluido'
    and (select status = 'gerada' and storage_path = v_path_b and claim_token is null and lease_ate is null from public.aula_quadrinho_assets where id = v_asset));
  perform pg_temp.q112_reg('A_storage_path_atual_protegido_mesmo_meses_depois', public.quadrinho_storage_path_protegido(v_path_b)
    and public.quadrinho_upload_orfao_motivo(v_path_b, v_antigo, v_agora + interval '1 year') = 'protegido_storage_path'
    and (select orfao is false and motivo = 'protegido_storage_path' from public.confirmar_quadrinho_upload_orfao(v_path_b)));
  perform pg_temp.q112_reg('concluir_repetido_com_mesmo_path_e_idempotente', (select aceito is true and motivo = 'ja_concluido'
    from public.concluir_quadrinho_asset(v_asset, gen_random_uuid(), v_h, v_path_b, 'x', 'x', 'x')));
  perform pg_temp.q112_reg('path_A_continua_desprotegido_apos_a_conclusao_de_B', not public.quadrinho_storage_path_protegido(v_path_a));

  -- ---- B: regenerar move o atual para storage_path_anterior (continua protegido) ----
  perform set_config('request.jwt.claim.sub', v_admin::text, true);
  select * into r2 from public.regenerar_quadrinho_asset_admin(v_asset);
  perform pg_temp.q112_reg('regenerar_move_o_path_atual_para_anterior', r2.path_anterior = v_path_b and (select storage_path is null and storage_path_anterior = v_path_b from public.aula_quadrinho_assets where id = v_asset));
  perform pg_temp.q112_reg('B_storage_path_anterior_protegido_mesmo_meses_depois', public.quadrinho_storage_path_protegido(v_path_b)
    and public.quadrinho_upload_orfao_motivo(v_path_b, v_antigo, v_agora + interval '1 year') = 'protegido_storage_path_anterior'
    and (select orfao is false and motivo = 'protegido_storage_path_anterior' from public.confirmar_quadrinho_upload_orfao(v_path_b)));

  -- ---- limite de 3 tentativas e reaper continuam como no Q10 ----
  for i in 1 .. 3 loop
    select * into r from public.reservar_quadrinho_asset(v_p);
    update public.aula_quadrinho_assets set lease_ate = now() - interval '1 minute' where id = v_asset;
  end loop;
  select count(*) into v_n from public.reservar_quadrinho_asset(v_p);
  perform pg_temp.q112_reg('tentativa_4_nunca_ocorre_e_lease_expirado_sem_tentativas_vira_erro', v_n = 0 and (
    select status = 'erro' and tentativas = 3 and claim_token is null and lease_ate is null from public.aula_quadrinho_assets where id = v_asset));
  perform pg_temp.q112_reg('claim_zerado_desprotege_o_path_mas_anterior_continua_protegido', not public.quadrinho_storage_path_protegido(r.storage_path_esperado)
    and public.quadrinho_storage_path_protegido(v_path_b));

  -- ---- falhar: retry/erro como no Q10 ----
  update public.aula_quadrinho_assets set status = 'pendente', tentativas = 0, erro_sanitizado = null where id = v_asset;
  select * into r from public.reservar_quadrinho_asset(v_p);
  select * into r2 from public.falhar_quadrinho_asset(v_asset, r.claim_token, 'falha do teste');
  perform pg_temp.q112_reg('falhar_1_de_3_volta_a_pendente_e_desprotege_o_path_do_claim', r2.aceito is true and r2.status_final = 'pendente'
    and not public.quadrinho_storage_path_protegido(r.storage_path_esperado));

  -- ---- RPCs de GC são somente leitura: nada mudou nas linhas ----
  select md5(string_agg(to_jsonb(q)::text, '|' order by q.id)) into v_md5_antes from public.aula_quadrinho_assets q;
  perform * from public.listar_quadrinho_uploads_orfaos(100);
  perform * from public.confirmar_quadrinho_upload_orfao(v_path_a);
  perform * from public.confirmar_quadrinho_upload_orfao(v_path_b);
  perform pg_temp.q112_reg('rpcs_de_gc_nao_alteram_nenhuma_linha', v_md5_antes = (select md5(string_agg(to_jsonb(q)::text, '|' order by q.id)) from public.aula_quadrinho_assets q));
  perform pg_temp.q112_reg('gc_nao_criou_nem_removeu_objetos_no_bucket', (select count(*) from storage.objects where bucket_id = 'quadrinhos-aulas') = 0);
end $$;

-- ============================================================================
-- REVERTER: o down-migration real é exercitado aqui (restaura o texto EXATO do Q10)
-- ============================================================================
delete from public.aula_quadrinho_assets;

-- >>> SECAO_REVERT_GUARDA (identica no harness)
do $$
begin
  if to_regprocedure('public.quadrinho_storage_path_claim(uuid,uuid,smallint,text,uuid)') is null then
    raise exception 'REVERT: GC ausente (quadrinho_storage_path_claim nao existe) — nada a reverter (ou ja revertido)';
  end if;
  if position('public.quadrinho_storage_path_claim' in pg_get_functiondef('public.reservar_quadrinho_asset(uuid)'::regprocedure)) = 0
     or position('public.quadrinho_storage_path_claim' in pg_get_functiondef('public.concluir_quadrinho_asset(uuid,uuid,text,text,text,text,text)'::regprocedure)) = 0 then
    raise exception 'REVERT: reservar/concluir nao estao no estado do GC aplicado; nao restaurar as cegas';
  end if;
end $$;
-- <<< SECAO_REVERT_GUARDA

-- >>> SECAO_REVERT_CORPO (identica no harness)
-- 1) restaura o texto EXATO do Q10 (as duas funções que usavam o helper)
create or replace function public.reservar_quadrinho_asset(p_aula_versao_id uuid default null)
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

create or replace function public.concluir_quadrinho_asset(
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

-- 2) remove o que o GC criou (sem CASCADE)
drop function public.listar_quadrinho_uploads_orfaos(integer);
drop function public.confirmar_quadrinho_upload_orfao(text);
drop function public.quadrinho_upload_orfao_motivo(text, timestamptz, timestamptz);
drop function public.quadrinho_storage_path_protegido(text);
drop function public.quadrinho_path_canonico(text);
drop function public.quadrinho_storage_path_claim(uuid, uuid, smallint, text, uuid);
drop function public.quadrinho_orphan_grace();
-- <<< SECAO_REVERT_CORPO

-- >>> SECAO_REVERT_POSCOND (identica no harness)
do $$
declare
  v_q record;
  v_fn text;
  v_papel text;
begin
  if exists (
    select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname in (
      'quadrinho_storage_path_claim', 'quadrinho_path_canonico', 'quadrinho_orphan_grace', 'quadrinho_storage_path_protegido',
      'quadrinho_upload_orfao_motivo', 'listar_quadrinho_uploads_orfaos', 'confirmar_quadrinho_upload_orfao')
  ) then raise exception 'REVERT POSCOND: ainda existem funcoes do GC'; end if;

  -- as 18 funcoes Q9/Q10 voltam EXATAMENTE ao estado validado (inclui reservar e concluir originais)
  for v_q in
    select * from (values
      ('hash_cena_quadrinho', '2779b0d927b88a6946b31636dff13804'),
      ('hash_cena_atual_quadrinho', '0fd391aacd21da2eb83ad06ec38db44b'),
      ('carregar_quadrinho_assets_aula', 'ee2c134d44bdbb00e45f0973eb20e33b'),
      ('carregar_quadrinho_assets_admin', '4d6a052a6b05e49d585fe2c9360d3b84'),
      ('quadrinho_asset_lease', 'a76262802dbb1697663c383565e8140c'),
      ('quadrinho_componente', '800ed4a3d4b69ae956dd3f6f0226e156'),
      ('cena_atual_quadrinho', 'd42813c97e079b7cc96bab6dd3fa513a'),
      ('quadrinho_path_no_storage', '8c90f2e67adb8f3da8426c6aafcb05e9'),
      ('quadrinho_asset_reiniciar', '0ac31e5664bb8d26f16002c2440aa332'),
      ('reservar_quadrinho_asset', '96bd1dff900e00997df38fff61b4ef22'),
      ('concluir_quadrinho_asset', 'd2ebbc27f62bef833048e1137e99bb70'),
      ('falhar_quadrinho_asset', 'ea019a77c4663648de04437fe8c929fa'),
      ('criar_jobs_quadrinho_admin', '6c834af49817ebf263fa07441ba139ef'),
      ('aprovar_quadrinho_asset_admin', '9855caa6a1485dd2bd323c291feb8ea0'),
      ('rejeitar_quadrinho_asset_admin', '99fc111dfd4d18e395d21ad987a8c307'),
      ('regenerar_quadrinho_asset_admin', '237ec790d15cdfcf29310858cb953ad1'),
      ('preparar_exclusao_quadrinho_asset_admin', 'ab629c0ac18cdaecba7a32cacda68a9a'),
      ('excluir_quadrinho_asset_admin', '3bad48fafb9b3a625a43732ee614f118')
    ) as t(nome, md5_esperado)
  loop
    if (select count(*) from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public' and p.proname = v_q.nome) <> 1
       or (select md5(pg_get_functiondef(p.oid)) from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public' and p.proname = v_q.nome) is distinct from v_q.md5_esperado then
      raise exception 'REVERT POSCOND: funcao nao voltou ao texto validado: %', v_q.nome;
    end if;
  end loop;

  -- permissoes de reservar/concluir preservadas pelo CREATE OR REPLACE
  foreach v_fn in array array['public.reservar_quadrinho_asset(uuid)', 'public.concluir_quadrinho_asset(uuid,uuid,text,text,text,text,text)'] loop
    foreach v_papel in array array['anon', 'authenticated'] loop
      if has_function_privilege(v_papel, v_fn::regprocedure, 'execute') then raise exception 'REVERT POSCOND: % executa %', v_papel, v_fn; end if;
    end loop;
    if not has_function_privilege('service_role', v_fn::regprocedure, 'execute') then raise exception 'REVERT POSCOND: service_role sem execute em %', v_fn; end if;
  end loop;
  raise notice 'REVERT POSCOND OK: GC removido; Q9/Q10 com o texto validado';
end $$;
-- <<< SECAO_REVERT_POSCOND

insert into teste_q112 (chave, ok) values ('reverter_restaura_funcoes_do_Q10_com_md5_exato_e_remove_as_7_do_GC',
  (select h_funcoes from _q112_snap_estado) = (select jsonb_object_agg(p.proname, md5(pg_get_functiondef(p.oid))) from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname in ('hash_cena_quadrinho', 'hash_cena_atual_quadrinho', 'carregar_quadrinho_assets_aula', 'carregar_quadrinho_assets_admin',
       'quadrinho_asset_lease', 'quadrinho_componente', 'cena_atual_quadrinho', 'quadrinho_path_no_storage', 'quadrinho_asset_reiniciar',
       'reservar_quadrinho_asset', 'concluir_quadrinho_asset', 'falhar_quadrinho_asset', 'criar_jobs_quadrinho_admin', 'aprovar_quadrinho_asset_admin',
       'rejeitar_quadrinho_asset_admin', 'regenerar_quadrinho_asset_admin', 'preparar_exclusao_quadrinho_asset_admin', 'excluir_quadrinho_asset_admin',
       'carregar_aula_publicada_da_missao', 'carregar_aula_rascunho_admin', 'eh_admin'))
  and not exists (select p.oid::text from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public' and p.oid::text not in (select nome from _q112_snap_fn))
  and not exists (select nome from _q112_snap_fn except select p.oid::text from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public'));

-- ============================================================================
-- OLD_FINAL: estado == snapshot OLD (ainda dentro da transação, antes do ROLLBACK)
-- ============================================================================
insert into teste_q112 (chave, ok) values ('old_final_colunas_e_constraints_da_tabela_iguais',
  (select colunas from _q112_snap_estado) is not distinct from (select string_agg(column_name || ':' || data_type || ':' || is_nullable, ',' order by ordinal_position)
     from information_schema.columns where table_schema = 'public' and table_name = 'aula_quadrinho_assets')
  and not exists (select nome from _q112_snap_cons except select conname::text from pg_constraint where conrelid = 'public.aula_quadrinho_assets'::regclass)
  and not exists (select conname::text from pg_constraint where conrelid = 'public.aula_quadrinho_assets'::regclass except select nome from _q112_snap_cons));
insert into teste_q112 (chave, ok) values ('old_final_relacoes_iguais_ao_snapshot',
  not exists (select c.relname::text from pg_class c join pg_namespace n on n.oid = c.relnamespace where n.nspname = 'public' and c.relname::text not in (select nome from _q112_snap_rel))
  and not exists (select nome from _q112_snap_rel except select c.relname::text from pg_class c join pg_namespace n on n.oid = c.relnamespace where n.nspname = 'public'));
insert into teste_q112 (chave, ok) values ('old_final_policies_e_bucket_iguais',
  not exists (select nome from _q112_snap_pol except select schemaname::text || '.' || tablename::text || '.' || policyname::text from pg_policies)
  and not exists (select schemaname::text || '.' || tablename::text || '.' || policyname::text from pg_policies except select nome from _q112_snap_pol)
  and not exists (select id::text || ':' || public::text || ':' || coalesce(file_size_limit::text, '') || ':' || coalesce(allowed_mime_types::text, '') from storage.buckets except select nome from _q112_snap_bucket)
  and not exists (select nome from _q112_snap_bucket except select id::text || ':' || public::text || ':' || coalesce(file_size_limit::text, '') || ':' || coalesce(allowed_mime_types::text, '') from storage.buckets));
insert into teste_q112 (chave, ok) values ('old_final_aula_versoes_aulas_cron_vault_grants_iguais',
  (select h_versoes from _q112_snap_estado) is not distinct from (select md5(string_agg(id::text || estrutura::text || status || numero_versao::text, '|' order by id)) from public.aula_versoes)
  and (select h_aulas from _q112_snap_estado) is not distinct from (select md5(string_agg(id::text || titulo || ativa::text, '|' order by id)) from public.aulas)
  and (select h_cron from _q112_snap_estado) is not distinct from (select md5(string_agg(jobid::text || jobname || schedule || md5(command), '|' order by jobid)) from cron.job)
  and (select h_vault from _q112_snap_estado) is not distinct from (select md5(string_agg(name, '|' order by name)) from vault.secrets)
  and (select h_grants_tabelas from _q112_snap_estado) is not distinct from (select md5(string_agg(table_name::text || grantee::text || privilege_type::text, '|' order by table_name::text, grantee::text, privilege_type::text)) from information_schema.role_table_grants where table_schema = 'public')
  and (select h_grants_worker from _q112_snap_estado) is not distinct from (select md5(string_agg(routine_name::text || grantee::text || privilege_type::text, '|' order by routine_name::text, grantee::text, privilege_type::text)) from information_schema.role_routine_grants where routine_schema = 'public' and routine_name in ('reservar_quadrinho_asset', 'concluir_quadrinho_asset', 'falhar_quadrinho_asset'))
  and (select n_matriculas from _q112_snap_estado) = (select count(*) from public.matriculas));
insert into teste_q112 (chave, ok) values ('old_final_tabela_e_bucket_vazios_como_no_inicio',
  (select n_assets from _q112_snap_estado) = (select count(*) from public.aula_quadrinho_assets)
  and (select n_objetos_bucket from _q112_snap_estado) = (select count(*) from storage.objects where bucket_id = 'quadrinhos-aulas'));

-- ============================================================================
-- RESULTADO FINAL (falha aborta com a lista; tudo é desfeito de qualquer forma)
-- ============================================================================
do $$
declare
  v_falhas text;
begin
  select string_agg(chave, ', ' order by ordem) into v_falhas from teste_q112 where ok is distinct from true;
  if v_falhas is not null then
    raise exception 'HARNESS Q11.2: testes com falha: %', v_falhas;
  end if;
  raise notice 'HARNESS Q11.2 OK: % verificacoes passaram', (select count(*) from teste_q112);
end $$;

select
  count(*) as verificacoes,
  count(*) filter (where ok) as aprovadas,
  bool_and(ok) as tudo_ok,
  (select jsonb_agg(chave order by ordem) from teste_q112 where ok is distinct from true) as falhas
from teste_q112;

ROLLBACK;
