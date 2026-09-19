-- Reversão segura, PÓS-APPLY, de supabase/async_geracao_aula.sql.
--
-- NÃO EXECUTAR agora. Este arquivo só deve ser usado se, no futuro, for
-- necessário desfazer o apply já confirmado da migration real.
--
-- Ordem segura: primeiro a CONSTRAINT (depende das colunas), depois as
-- duas colunas. Pré-condição explícita: recusa reverter se existir
-- alguma geração 'processando' com openai_response_id preenchido — isso
-- indicaria uma geração assíncrona genuinamente em voo, cuja informação
-- de correlação com a OpenAI seria perdida por este DROP; nesse caso, o
-- rollback precisa esperar essa geração terminar (ou ser tratada
-- manualmente) antes de reverter o schema.
--
-- Termina em COMMIT. Só deve ser executado após autorização humana
-- explícita, e idealmente após rodar supabase/pos_check_async_geracao_
-- aula.sql antes e depois para confirmar o estado.

begin;

do $$
declare
  v_pendentes int;
begin
  select count(*) into v_pendentes
  from public.aula_geracoes
  where status = 'processando' and openai_response_id is not null;

  if v_pendentes > 0 then
    raise exception 'Abortado: % geracao(oes) processando com openai_response_id preenchido — reverta apos essas gerações terminarem (ou trate manualmente), nunca as cegas.', v_pendentes;
  end if;
end $$;

alter table public.aula_geracoes drop constraint if exists aula_geracoes_tentativa_ia_check;
alter table public.aula_geracoes drop column if exists tentativa_ia;
alter table public.aula_geracoes drop column if exists openai_response_id;

commit;
