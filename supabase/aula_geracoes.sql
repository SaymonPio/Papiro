-- Fundação da Teoria Interativa (Fase 2J-A): controle de geração de aulas
-- por IA — trava de concorrência/idempotência e auditoria do contexto de
-- cada geração.
--
-- Esta tabela NÃO é lida/escrita pelo aluno em nenhuma hipótese: é
-- infraestrutura exclusivamente administrativa, escrita pela Edge Function
-- gerar-aula (via service_role, mesmo padrão de supabase/functions/
-- processar-edital/index.ts escrevendo em public.editais) e lida pelo
-- admin só através da RPC listar_geracoes_conteudo_admin (ver
-- supabase/teoria_geracao_admin_rpc.sql).
--
-- Trava de concorrência: no máximo UMA geração 'processando' por
-- conteudo_id, garantida por ÍNDICE ÚNICO PARCIAL — mesmo padrão já usado
-- em aula_versoes_uma_publicada_idx (teoria_versionada.sql). Uma segunda
-- tentativa de INSERT enquanto já existe uma linha 'processando' para o
-- mesmo conteudo_id falha com unique_violation ANTES de qualquer chamada à
-- OpenAI ter acontecido — a trava é a própria constraint do banco, não uma
-- checagem de aplicação que poderia perder uma corrida.
--
-- Recuperação de geração travada (crash da function, timeout de rede,
-- etc.): uma geração 'processando' iniciada há mais de 10 MINUTOS é
-- considerada expirada. 10 minutos foi escolhido por exceder com folga o
-- tempo real de uma geração bem-sucedida (uma única chamada a
-- api.openai.com/v1/responses, tipicamente segundos a poucos minutos) e o
-- teto de execução de uma Supabase Edge Function — não é um valor
-- arbitrário sem documentação, é a mesma margem de segurança usada em
-- decisões de timeout já revisadas neste projeto. A recuperação é feita
-- via UPDATE (nunca DELETE, preserva histórico) condicionado a
-- status='processando' AND iniciado_em < now() - 10 min: esse UPDATE é
-- atômico a nível de linha — duas tentativas concorrentes de recuperação
-- competem pela mesma linha, só uma realmente muda o status, a segunda não
-- encontra mais a linha em 'processando' e não faz nada. Essa lógica vive
-- na Edge Function (chamada antes de tentar o INSERT da nova geração), não
-- nesta migration — este arquivo só cria a estrutura que permite isso.
--
-- contexto jsonb: snapshot COMPACTO do contexto usado nesta geração
-- (curso/conteúdo/matéria/banca/concurso/cargo, ids de curso_evidencias e
-- material_versoes consultados) — nunca o prompt inteiro nem o texto bruto
-- das fontes, para não duplicar volume de dado sem necessidade, mas
-- suficiente para responder "com qual contexto esta aula foi gerada"
-- depois. Gravado mesmo em caso de erro (grava-se o contexto ANTES de
-- chamar a OpenAI).
--
-- CREATE TABLE sem IF NOT EXISTS, de propósito: esta tabela é nova e não
-- existe hoje. Se já existir algo com esse nome, a migration deve FALHAR
-- em vez de prosseguir silenciosamente. Sem DROP TABLE. Nenhuma migration
-- histórica é editada.
--
-- Envolvido em BEGIN/COMMIT — ou tudo aplica, ou nada aplica.

BEGIN;

create table public.aula_geracoes (
  id uuid primary key default gen_random_uuid(),

  conteudo_id bigint not null
    references public.curso_conteudos(id) on delete restrict,

  status text not null default 'processando'
    check (status in ('processando', 'concluida', 'erro')),

  criado_por uuid not null
    references auth.users(id) on delete restrict,

  prompt_version text not null,
  modelo text null,

  contexto jsonb not null default '{}'::jsonb
    check (jsonb_typeof(contexto) = 'object'),

  tokens_entrada integer null check (tokens_entrada is null or tokens_entrada >= 0),
  tokens_saida integer null check (tokens_saida is null or tokens_saida >= 0),

  -- Preenchido só quando status = 'concluida'. ON DELETE RESTRICT: uma
  -- aula_versao referenciada pelo histórico de geração nunca pode
  -- desaparecer silenciosamente por baixo dessa auditoria.
  aula_versao_id uuid null
    references public.aula_versoes(id) on delete restrict,

  erro text null,

  iniciado_em timestamptz not null default now(),
  finalizado_em timestamptz null,

  criado_em timestamptz not null default now()
);

-- Índice único parcial: a trava de concorrência em si.
create unique index aula_geracoes_uma_processando_idx
  on public.aula_geracoes (conteudo_id)
  where status = 'processando';

-- Suporta a consulta "histórico de gerações deste conteúdo" (RPC
-- listar_geracoes_conteudo_admin) sem depender só do índice parcial acima
-- (que só cobre linhas 'processando').
create index aula_geracoes_conteudo_id_idx
  on public.aula_geracoes (conteudo_id);

-- RLS ativo, ZERO acesso direto para anon/authenticated — mesmo princípio
-- de fechamento total já usado nas 5 tabelas da Fase 2E (teoria_versionada.
-- sql): escrita só pela Edge Function (service_role, ignora RLS), leitura
-- administrativa só pela RPC SECURITY DEFINER listar_geracoes_conteudo_
-- admin (que reimplementa a checagem de eh_admin() explicitamente, não
-- delega a nenhuma policy aqui).
alter table public.aula_geracoes enable row level security;
revoke all on public.aula_geracoes from anon, authenticated;

COMMIT;
