-- Fase 4.1 — lease recuperável de reivindicação do finalizador.
--
-- Problema real identificado por auditoria (Fase 4): a reivindicação
-- atômica anterior reaproveitava `finalizado_em` como marcador de "estou
-- processando isto agora". Isso funciona contra duas execuções
-- CONCORRENTES, mas cria um novo risco: se o worker que reivindicou
-- morrer (crash, timeout do runtime, etc.) DEPOIS de preencher
-- finalizado_em mas ANTES de realmente concluir/errar a geração, a linha
-- fica para sempre com status='processando' E finalizado_em preenchido —
-- um estado que nenhuma execução futura sabe reconhecer como "reivindicação
-- morta, pode tentar de novo", porque a condição de reivindicação exigia
-- justamente finalizado_em IS NULL. A geração fica presa permanentemente,
-- o mesmo problema de fundo que motivou toda a Fase 3A, só que um nível
-- acima.
--
-- Decisão: `finalizado_em` volta a significar EXCLUSIVAMENTE "esta
-- geração terminou de forma terminal" (status='concluida' ou status=
-- 'erro') — nunca mais um mutex/claim. A reivindicação passa a usar uma
-- coluna dedicada, com expiração automática por tempo (lease): uma
-- reivindicação "morta" (worker que travou) libera sozinha depois de
-- LEASE_FINALIZACAO_MINUTOS (5 minutos, ver
-- _shared/gerar-aula/idempotencia.mjs) — nenhuma limpeza manual
-- necessária, nenhum estado permanentemente preso.
--
-- Coluna aditiva, nullable, sem default — linhas existentes ficam NULL
-- naturalmente (nenhuma delas está "reivindicada" por definição, já que a
-- lease é um conceito novo). Sem alteração de status, do CHECK de status,
-- do índice de trava por unidade, de FKs, ou de qualquer dado existente.
-- Não modifica supabase/async_geracao_aula.sql (já aplicada e validada em
-- produção) — esta é uma migration NOVA, independente.

BEGIN;

ALTER TABLE public.aula_geracoes
  ADD COLUMN finalizacao_lease_ate timestamptz NULL;

COMMIT;
