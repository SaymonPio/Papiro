-- ROLLBACK MANUAL — NÃO EXECUTADO AUTOMATICAMENTE, NÃO FAZ PARTE DE
-- supabase/migrations/ DE PROPÓSITO: um rollback manual nunca pode ficar no
-- diretório de migrations, pois uma execução futura de `db push`/
-- `migration up` poderia interpretá-lo como uma migration válida e remover
-- a feature.
--
-- Reverte exatamente a migration
-- supabase/migrations/20261003120000_criar_sessoes_tempo.sql.
-- Seguro a qualquer momento enquanto nenhum frontend depender destas RPCs
-- (nenhuma integração foi feita nesta fase): tudo na migration é aditivo,
-- então remover é equivalente a nunca ter existido, sem efeito em nenhuma
-- tabela pré-existente.
--
-- Se já houver dados reais em sessoes_tempo/sessoes_tempo_dias quando este
-- rollback for considerado, avalie antes exportar/arquivar as linhas — este
-- script apaga as duas tabelas e todo o seu conteúdo.

drop function if exists public.historico_tempo_estudo(integer);
drop function if exists public.resumo_tempo_estudo();
drop function if exists public.obter_sessao_tempo_aberta();
drop function if exists public.encerrar_sessao_tempo(bigint);
drop function if exists public.retomar_sessao_tempo(bigint);
drop function if exists public.pausar_sessao_tempo(bigint);
drop function if exists public.heartbeat_sessao_tempo(bigint);
drop function if exists public.iniciar_sessao_tempo(text, uuid, text, uuid, bigint, bigint, bigint, bigint, uuid);
drop function if exists public._distribuir_segundos_por_dia(bigint, uuid, uuid, timestamptz, timestamptz);

-- sessoes_tempo_dias tem FK ON DELETE CASCADE para sessoes_tempo, mas o
-- drop explícito (em vez de depender só do CASCADE) deixa a ordem de
-- remoção clara para quem revisar este script.
drop table if exists public.sessoes_tempo_dias;
drop table if exists public.sessoes_tempo;
