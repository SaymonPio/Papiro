-- REVERSÃO PÓS-APPLY de supabase/camada_ilustrada_pipeline.sql — GENUÍNA down-migration
-- (não é teste transacional). NÃO EXECUTADO na Q10.1.
--
-- Remove SOMENTE o que o pipeline criou: 9 RPCs, 5 helpers, 2 CHECKs, o índice
-- único parcial e as colunas claim_token / storage_path_anterior. NÃO toca na
-- fundação da Q9 (tabela, hash_cena_*, RPCs de leitura, bucket, RLS, grants).
--
-- FAIL-SAFE (nunca destrói dado em silêncio):
--   * aborta se houver linha `gerando` ou com claim_token (worker em andamento);
--   * aborta se houver linha com storage_path_anterior (ponteiro para arquivo a
--     limpar — perder a coluna deixaria o objeto órfão sem rastro);
--   * sem CASCADE: cada DROP falha se algo inesperado depender do objeto.
-- As demais colunas (status, storage_path, aprovação...) NÃO são alteradas.
--
-- O corpo (guarda, remoção e pós-condição) é exercitado pelo harness
-- camada_ilustrada_pipeline_teste_rollback.sql, dentro de BEGIN ... ROLLBACK.

begin;

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

commit;
