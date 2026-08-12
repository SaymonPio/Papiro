-- Fundação da Teoria Interativa (Fase 2B): entidade public.missoes.
--
-- Uma missão representa UMA execução diária de um conteúdo (curso_conteudos)
-- por uma matrícula — a identidade que faltava para ligar Teoria e Questões
-- sob o mesmo id (ver diagnóstico da Fase 1). NÃO é a mesma coisa que
-- public.sessoes_estudo: sessoes_estudo continua representando prática de
-- questões (nada nela é alterado aqui). NÃO é a mesma coisa que
-- public.progresso_conteudo_matricula: aquela é progresso GLOBAL da
-- matrícula sobre um conteúdo (1 linha por conteúdo, para sempre);
-- public.missoes é progresso de UMA EXECUÇÃO específica (1 linha por
-- dia/conteúdo/matrícula). Nenhuma das duas tabelas é tocada neste arquivo.
--
-- Esta etapa cria SOMENTE a fundação: a tabela, sua identidade/duplicidade,
-- validação de integridade e RLS de leitura. Nenhuma RPC, nenhum gatilho de
-- escrita para authenticated, nenhuma alteração em outra tabela.
--
-- Envolvido em BEGIN/COMMIT — ou tudo aplica, ou nada aplica.

BEGIN;

-- ============================================================================
-- 1) Tabela
-- ============================================================================
--
-- matricula_id / conteudo_id: NOT NULL, sem coluna redundante de
-- materia_id/assunto_id/curso_id/usuario_id — todas deriváveis via
-- matricula_id -> matriculas (usuario_id/curso_id) e conteudo_id ->
-- curso_conteudos -> curso_materias (assunto_id/curso_id/materia_id).
-- Evita inconsistência por dado duplicado, mesmo critério já usado em
-- progresso_conteudo_matricula.
--
-- status: texto livre + CHECK explícito da lista fechada de valores. NUNCA
-- comparar como 'iniciada' < 'teoria_concluida' (comparação lexical não
-- reflete a máquina de estados) — a ordem/transição válida é
-- responsabilidade das RPCs futuras (ainda não criadas), não de uma
-- ordenação textual aqui no banco.
--
-- progresso_teoria: jsonb do estado de execução da Teoria DESTA missão
-- (ex.: diagnóstico respondido, componentes vistos). Não é o lugar do
-- progresso global do conteúdo — isso continua exclusivamente em
-- progresso_conteudo_matricula.estado, não implementado nesta etapa.
-- CREATE TABLE sem IF NOT EXISTS, de propósito: public.missoes não existe
-- hoje. Se já existir algo com esse nome, a migration deve FALHAR em vez de
-- prosseguir silenciosamente sobre uma estrutura desconhecida.
create table public.missoes (
  id uuid primary key default gen_random_uuid(),

  matricula_id uuid not null
    references public.matriculas(id) on delete restrict,

  conteudo_id bigint not null
    references public.curso_conteudos(id) on delete restrict,

  -- Data de negócio da missão em America/Sao_Paulo, não UTC. O banco roda em
  -- UTC — current_date puro viraria o dia seguinte a partir das 21h de
  -- Brasília (ex.: 20:40 em Brasília = 23:40 UTC), quebrando a identidade
  -- (matricula_id, conteudo_id, data_missao) horas antes da meia-noite
  -- local. Nesta primeira versão do Papiro a data de negócio é fixa em
  -- America/Sao_Paulo; timestamps continuam timestamptz normalmente.
  data_missao date not null
    default (timezone('America/Sao_Paulo', now())::date),

  status text not null default 'iniciada'
    check (status in ('iniciada', 'teoria_concluida', 'questoes_iniciadas', 'concluida', 'abandonada')),

  progresso_teoria jsonb not null default '{}'::jsonb
    check (jsonb_typeof(progresso_teoria) = 'object'),

  iniciada_em timestamptz not null default now(),
  teoria_concluida_em timestamptz null,
  questoes_iniciadas_em timestamptz null,
  concluida_em timestamptz null,

  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),

  -- mesma matrícula + mesmo conteúdo + mesmo dia = mesma missão. Base para
  -- uma futura RPC idempotente "iniciar_ou_recuperar_missao_diaria" (não
  -- criada nesta etapa) fazer um upsert seguro.
  unique (matricula_id, conteudo_id, data_missao)
);

-- ============================================================================
-- 2) Índices
-- ============================================================================
--
-- O UNIQUE acima já cria um índice composto (matricula_id, conteudo_id,
-- data_missao), mas ele não atende bem uma consulta futura do cronograma
-- por "todas as missões de uma matrícula num intervalo de datas" (que não
-- filtra por conteudo_id) — daí o índice dedicado abaixo. Nenhum outro
-- índice além deste foi adicionado, para não duplicar cobertura sem uso
-- concreto ainda. Sem IF NOT EXISTS, mesmo princípio fail-fast do resto
-- desta migration nova: uma colisão inesperada de nome deve gerar erro, não
-- ser ignorada silenciosamente.
create index missoes_matricula_data_idx
  on public.missoes (matricula_id, data_missao);

-- ============================================================================
-- 3) Validação de integridade: matrícula e conteúdo do mesmo curso
-- ============================================================================
--
-- Reaproveita, SEM modificar, a função já existente
-- public.validar_curso_do_progresso_conteudo() (criada para
-- progresso_conteudo_matricula em base_programatica_curso.sql). A função já
-- é genérica o bastante para isso: ela só lê new.matricula_id/new.conteudo_id
-- e compara o curso de cada lado (matriculas.curso_id vs curso_conteudos ->
-- curso_materias.curso_id) — não referencia progresso_conteudo_matricula em
-- lugar nenhum do próprio corpo, e public.missoes tem colunas
-- matricula_id/conteudo_id com os mesmos nomes e tipos. Nenhum CREATE OR
-- REPLACE dessa função aparece aqui — só um novo trigger que a invoca.
--
-- Deliberadamente SEM checar matriculas.status = 'ativa': uma missão
-- histórica precisa continuar íntegra mesmo que a matrícula seja cancelada/
-- expirada depois. Exigir matrícula ATIVA é responsabilidade da futura RPC
-- que CRIA uma missão nova, não desta trava de integridade estrutural.
drop trigger if exists missoes_valida_curso on public.missoes;
create trigger missoes_valida_curso
  before insert or update of matricula_id, conteudo_id on public.missoes
  for each row
  execute function public.validar_curso_do_progresso_conteudo();

-- ============================================================================
-- 4) atualizado_em — trigger dedicada, mesmo padrão de
-- configuracoes_estudo_marca_atualizacao (configuracoes_estudo.sql): cada
-- tabela deste projeto que precisa desse comportamento tem sua própria
-- função (não existe um helper genérico compartilhado hoje) — mantido aqui
-- para não introduzir um padrão novo nem depender de uma função pensada
-- para outra tabela.
-- ============================================================================
-- CREATE FUNCTION sem OR REPLACE, de propósito: esta função é nova e não
-- existe hoje. Se já existir algo com esse nome, a migration deve FALHAR em
-- vez de substituir silenciosamente uma função desconhecida. (A função já
-- existente public.validar_curso_do_progresso_conteudo(), reaproveitada na
-- seção 3, não é tocada.)
create function public.marcar_atualizacao_missao()
returns trigger
language plpgsql
as $$
begin
  new.atualizado_em := now();
  return new;
end;
$$;

drop trigger if exists missoes_marca_atualizacao on public.missoes;
create trigger missoes_marca_atualizacao
  before update on public.missoes
  for each row
  execute function public.marcar_atualizacao_missao();

-- Detalhe interno do trigger, não é uma RPC pública — revoga a exposição
-- padrão de EXECUTE só depois de criar o trigger (CREATE TRIGGER exige
-- EXECUTE na função no momento da criação). Feito isso, a função não
-- precisa mais ficar diretamente executável pelos roles da aplicação.
revoke execute on function public.marcar_atualizacao_missao()
  from public, anon, authenticated;

-- ============================================================================
-- 5) RLS — só leitura para authenticated nesta etapa
-- ============================================================================
--
-- SELECT: aluno vê as missões das próprias matrículas — sem checar
-- matriculas.status, pelo mesmo motivo já explicado na seção 3 (missão
-- histórica continua visível mesmo com matrícula cancelada/expirada).
--
-- Nenhuma policy de INSERT/UPDATE/DELETE é criada para authenticated: a
-- escrita será feita só por RPCs SECURITY DEFINER futuras (não criadas
-- nesta etapa).
alter table public.missoes enable row level security;

drop policy if exists "Aluno visualiza as próprias missões" on public.missoes;
create policy "Aluno visualiza as próprias missões"
  on public.missoes for select to authenticated
  using (exists (
    select 1 from public.matriculas m
    where m.id = missoes.matricula_id
      and m.usuario_id = auth.uid()
  ));

-- Privilégios explícitos, não deixados no default do schema: revoga TUDO
-- (insert/update/delete/truncate/references/trigger, além de select) de
-- anon e authenticated, depois concede de volta só select para
-- authenticated — sujeito à policy de RLS acima. anon fica sem nenhum
-- privilégio direto na tabela. Escrita continua exclusiva de RPCs SECURITY
-- DEFINER futuras.
revoke all on public.missoes from anon, authenticated;
grant select on public.missoes to authenticated;

COMMIT;
