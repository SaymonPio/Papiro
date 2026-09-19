-- Fase 3A — infraestrutura mínima para geração assíncrona de aulas
-- (background:true na Responses API da OpenAI), resolvendo o estouro do
-- teto de execução (~150s) de uma Edge Function síncrona já observado em
-- produção (aula_geracoes.id f2a0d24c-9a2d-4adc-ad09-680e686bb31a, preso
-- em 'processando' após HTTP 546 do runtime).
--
-- DECISÃO EXPLÍCITA: NÃO criar um status novo ("aguardando_ia" etc.).
-- 'processando' passa a significar, sem ambiguidade nova, "geração ativa"
-- em qualquer uma das suas sub-fases (enviada à OpenAI, aguardando
-- background, aguardando finalização, em correção) — exatamente o que já
-- significava antes, só que agora a fase "aguardando a IA" pode durar
-- minutos em vez de segundos. Isso preserva:
--   - o CHECK de status em ('processando','concluida','erro'), sem
--     alteração nenhuma;
--   - o índice único parcial aula_geracoes_uma_unidade_processando_idx
--     (unidade_pedagogica_id) WHERE status='processando' — a MESMA trava
--     de concorrência de hoje continua valendo sem mudança nenhuma de
--     definição, só que agora protege uma janela de tempo maior.
-- Nenhum consumidor existente (RPC listar_geracoes_conteudo_admin, UI em
-- app/admin/aulas/page.tsx) precisa mudar por causa deste arquivo.
--
-- Duas colunas novas, aditivas, nullable/com default seguro — nenhuma
-- linha existente muda de valor:
--   - openai_response_id text null: id da Response da OpenAI em
--     background, usado pelo finalizador para localizar/recuperar o
--     resultado (GET /v1/responses/{id}). NULL para toda geração
--     histórica (síncrona, sem response_id) e continua NULL até o
--     iniciador gravar o id retornado pela OpenAI. Fica FORA de
--     "contexto" jsonb de propósito — é um dado técnico-operacional de
--     correlação com o provedor externo, não um snapshot pedagógico, e
--     precisa ser filtrável/indexável pelo finalizador sem depender de
--     um índice de expressão sobre JSONB.
--   - tentativa_ia smallint not null default 1, CHECK entre 1 e 2: conta
--     quantas Responses já foram submetidas para esta geração (a inicial
--     + no máximo 1 correção automática — a MESMA regra de "exatamente 1
--     tentativa de correção" que já existe hoje no código síncrono,
--     agora expressa também como invariante de banco, não só de
--     aplicação). Default 1 preserva o significado para toda geração
--     histórica (todas tiveram exatamente 1 tentativa registrada).
--
-- Sem alteração de FK, sem alteração de RLS (já fechado para
-- anon/authenticated desde a migration original), sem DROP, sem
-- renomear/remover nada. Envolvido em BEGIN/COMMIT — ou tudo aplica, ou
-- nada aplica. NÃO aplicado nesta fase (ver mandato: só preparar).

BEGIN;

ALTER TABLE public.aula_geracoes
  ADD COLUMN openai_response_id text NULL;

ALTER TABLE public.aula_geracoes
  ADD COLUMN tentativa_ia smallint NOT NULL DEFAULT 1;

ALTER TABLE public.aula_geracoes
  ADD CONSTRAINT aula_geracoes_tentativa_ia_check
    CHECK (tentativa_ia BETWEEN 1 AND 2);

COMMIT;
