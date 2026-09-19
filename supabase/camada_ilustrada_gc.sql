-- CAMADA ILUSTRADA — GC SEGURO DE UPLOADS ÓRFÃOS (APPLY REAL — NÃO EXECUTADO)
--
-- Fase Q11.2. Camada de DETECÇÃO (banco) para o GC de uploads órfãos:
--
--   worker tem claim -> gera imagem -> faz upload WebP -> processo MORRE antes de
--   concluir_quadrinho_asset  =>  objeto físico no bucket sem referência na tabela.
--
-- Este pacote NÃO remove nada: nenhuma função aqui apaga objeto de Storage (o SQL
-- nunca toca storage.objects com DELETE). O SQL só DETECTA, CLASSIFICA e RECONFIRMA;
-- a remoção física é da futura Edge, por Storage API, path a path.
--
-- PROTEÇÕES (um path NUNCA é órfão se qualquer uma valer):
--   A) é o storage_path atual de algum asset;
--   B) é o storage_path_anterior de algum asset (limpeza de regeneração é do fluxo admin);
--   C) é o path esperado do claim_token ATUAL de uma linha `gerando` — mesmo com o
--      lease vencido: o token é a identidade do worker, o lease só mede tempo.
--   + GRACE de 30 min (quadrinho_orphan_grace(), único ponto de ajuste) sobre a idade
--     do objeto: lease normal = 10 min; a margem cobre upload lento e comportamento
--     inesperado. Objetos FORA do padrão canônico são ignorados pelo GC automático.
--
-- FÓRMULA DO PATH CENTRALIZADA: quadrinho_storage_path_claim(...) produz EXATAMENTE o
-- path do Q10 (<versao>/<componente>/<indice>/<hash10>-<claim_token>.webp). A fórmula
-- estava DUPLICADA em reservar_quadrinho_asset e concluir_quadrinho_asset; agora as
-- duas (recriadas com CREATE OR REPLACE, texto idêntico exceto a expressão do path)
-- e a proteção C usam o mesmo helper — claim e GC nunca divergem. Assinaturas, grants,
-- fencing, lease, tentativas e semântica preservados; o reverter restaura o texto EXATO
-- do Q10 (md5 conferido).
--
-- CORRIDA listagem -> reconfirmação -> delete: um path órfão nunca volta a ser
-- referenciado pelo fluxo normal. O path contém o claim_token da tentativa; tokens são
-- gen_random_uuid() novos a cada reserva e nunca reutilizados; concluir_quadrinho_asset
-- só aceita o path calculado com o token ATUAL da linha (fencing provado na Q11.1). Se o
-- token do path não é o atual (substituído ou zerado), nenhum worker consegue concluir
-- com ele, e nenhuma RPC aceita path vindo de cliente. Logo o estado "órfão" é
-- absorvente. A Edge ainda reconfirma (confirmar_quadrinho_upload_orfao) imediatamente
-- antes de cada delete, e uma falha de delete é inofensiva (idempotente).
--
-- Sem colunas novas, sem status novos, sem policies, sem cron, sem alterar bucket ou
-- RPC do aluno. Grants: tudo interno; RPCs de listagem/confirmação SÓ service_role; o
-- classificador com timestamp explícito (usado pelo harness) nem service_role executa.
--
-- Fail-safe: ABORTA se Q9/Q10 divergirem do esperado (colunas, CHECKs, md5 das 18
-- funções, bucket) ou se algo deste pacote já existir. Reversão:
-- reverter_camada_ilustrada_gc.sql.

begin;

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

commit;
