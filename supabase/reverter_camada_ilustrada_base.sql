-- REVERSÃO PÓS-APPLY de supabase/camada_ilustrada_base.sql — GENUÍNA down-migration
-- (não é teste transacional). NÃO EXECUTADO na Q9. Só existe para o caso de o
-- pacote precisar ser desfeito DEPOIS de aplicado de verdade no LIVE.
--
-- FAIL-SAFE (nunca apaga dados ou imagens em silêncio):
--   * aborta se public.aula_quadrinho_assets tiver QUALQUER linha (asset,
--     aprovação, histórico de tentativas) — decida conscientemente o destino
--     desses dados antes;
--   * aborta se houver QUALQUER objeto em storage.objects no bucket
--     quadrinhos-aulas — imagens nunca são apagadas por este script;
--   * aborta se alguém tiver criado policy de storage citando o bucket;
--   * sem CASCADE: cada DROP falha se algo inesperado depender do objeto.
--
-- Remoção do bucket: o Supabase bloqueia DELETE direto em storage.buckets pelo
-- trigger storage.protect_delete (a menos que storage.allow_delete_query seja
-- 'true'). Como a guarda acima já provou que o bucket está VAZIO, este script
-- liga essa flag SÓ localmente (set_config ... true) para esse único DELETE e
-- volta a 'false' em seguida. Se preferir, remova o bucket vazio pelo painel
-- ou pela Storage API e apague o bloco correspondente antes de rodar.
--
-- O corpo (guarda, remoção e pós-condição) é exercitado pelo harness
-- camada_ilustrada_base_teste_rollback.sql, dentro de BEGIN ... ROLLBACK.

begin;

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

commit;
