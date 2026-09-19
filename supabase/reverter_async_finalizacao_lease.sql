-- Reversão pós-apply de supabase/async_finalizacao_lease.sql — GENUÍNA
-- down-migration (não um teste transacional). Só existe para o caso de a
-- migration precisar ser desfeita DEPOIS de já ter sido aplicada de
-- verdade no banco LIVE.
--
-- NÃO EXECUTAR AGORA. Nada nesta fase autoriza rodar este arquivo.
--
-- Precondição: recusa remover a coluna se existir qualquer geração com
-- uma lease genuinamente ativa (finalizacao_lease_ate no futuro) — nesse
-- caso um finalizador pode estar com a reivindicação em mãos neste exato
-- momento, e derrubar a coluna embaixo dele corromperia a execução em
-- andamento. Rodar de novo depois que a lease expirar/o trabalho
-- terminar.

BEGIN;

do $$
begin
  if exists (
    select 1 from public.aula_geracoes
    where finalizacao_lease_ate is not null and finalizacao_lease_ate > now()
  ) then
    raise exception 'Existe pelo menos uma geracao com lease de finalizacao ATIVA (finalizacao_lease_ate no futuro) — reversao abortada para nao corromper uma reivindicacao em andamento. Tente novamente depois que a lease expirar.';
  end if;
end $$;

ALTER TABLE public.aula_geracoes
  DROP COLUMN IF EXISTS finalizacao_lease_ate;

COMMIT;
