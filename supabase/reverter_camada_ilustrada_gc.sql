-- REVERSÃO PÓS-APPLY de supabase/camada_ilustrada_gc.sql — GENUÍNA down-migration
-- (não é teste transacional). NÃO EXECUTADO na Q11.2.
--
-- Remove SOMENTE o que o GC criou (7 funções) e RESTAURA reservar_quadrinho_asset e
-- concluir_quadrinho_asset para o texto EXATO do Q10 (embutido abaixo, extraído do
-- pacote camada_ilustrada_pipeline.sql e conferido contra o LIVE por md5 na pós-condição:
-- pg_get_functiondef idêntico ao validado). NÃO toca em tabela, colunas, constraints,
-- bucket, policies, RPC do aluno nem nas demais funções da Q9/Q10.
--
-- FAIL-SAFE: aborta se o GC não estiver aplicado como esperado; sem CASCADE (cada DROP
-- falha se algo inesperado depender do objeto). CREATE OR REPLACE preserva as
-- permissões (service_role executa; anon/authenticated não).
--
-- O corpo (guarda, restauração/remoção e pós-condição) é exercitado pelo harness
-- camada_ilustrada_gc_teste_rollback.sql, dentro de BEGIN ... ROLLBACK.

begin;

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

commit;
