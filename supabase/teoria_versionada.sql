-- Fundação da Teoria Interativa (Fase 2E): materiais, versionamento de
-- materiais, identidade/versionamento de aulas, e o vínculo exato entre uma
-- versão de aula e as versões de material usadas para produzi-la.
--
-- Auditoria feita antes de escrever este arquivo (sem alterar nada):
--   - Nenhuma tabela/rota/estrutura chamada materiais, material_versoes,
--     aulas, aula_versoes, aula_versao_fontes, arquivos, documentos, fontes,
--     teoria, conteudos_teoricos, resumos, versoes ou edital_arquivos existe
--     hoje em lugar nenhum do projeto (grep exaustivo em app/, utils/,
--     supabase/, scripts/, public/). Sem colisão de nome ou de conceito.
--   - app/teoria/page.tsx é hoje um placeholder puro — mostra texto estático
--     e não busca nenhum conteúdo didático; é o consumidor natural futuro
--     deste modelo, mas NADA no frontend é alterado por este arquivo.
--   - public.curso_conteudos (base_programatica_curso.sql) é a identidade
--     programática do conteúdo dentro de um curso — id bigint, sem trigger
--     de atualizado_em própria, com RLS de leitura para aluno matriculado
--     ativo. aulas.conteudo_id referencia essa tabela, sem alterá-la.
--   - Nenhum bucket de Storage existe hoje para materiais/aulas (só
--     "editais", exclusivo de PDF de edital) — nenhum Storage é criado
--     aqui, conforme pedido.
--   - Não existe função genérica de atualizado_em no projeto — o padrão
--     documentado (ver missoes.sql) é uma função dedicada por tabela; esse
--     padrão é seguido aqui: materiais e aulas ganham cada uma sua própria
--     função de trigger. material_versoes/aula_versoes/aula_versao_fontes
--     não têm atualizado_em — são, por desenho, linhas que não devem ser
--     alteradas depois de criadas (nova revisão = nova linha, nunca UPDATE).
--
-- O que este arquivo NÃO faz: não altera public.missoes, public.
-- sessoes_estudo, public.progresso_conteudo_matricula, public.
-- curso_conteudos, nem nenhum arquivo de frontend. Não cria Storage. Não
-- cria nenhuma RPC (leitura/escrita ficam para uma etapa futura). Não
-- insere nenhum dado.
--
-- Convenção de PK: uuid em todas as 5 tabelas novas (materiais,
-- material_versoes, aulas, aula_versoes — aula_versao_fontes é tabela de
-- junção pura, sem id próprio, PK composta). O projeto não tem uma regra
-- única documentada (tabelas "identidade de topo" como editais/missoes usam
-- uuid; tabelas "filhas" de uma hierarquia curso/matéria como
-- curso_conteudos/edital_materias usam bigint identity) — optei por uuid
-- uniforme em toda a nova subárea, seguindo exatamente os campos sugeridos
-- na especificação desta fase, por consistência interna do novo subsistema.
--
-- Convenção de migration nova (mesmo padrão de missoes.sql/missoes_rpc.sql):
-- CREATE TABLE/CREATE FUNCTION sem IF NOT EXISTS/OR REPLACE — fail-fast se
-- já existir algo inesperado com esse nome, em vez de prosseguir
-- silenciosamente. Sem DROP TABLE/DROP FUNCTION.
--
-- Envolvido em BEGIN/COMMIT — ou tudo aplica, ou nada aplica. Este arquivo
-- NÃO é executado por esta etapa (só criado, para revisão).

BEGIN;

-- ============================================================================
-- 1) materiais — identidade lógica de uma fonte de estudo (uma lei, uma
-- apostila, um resumo etc.), independente de versão. "tipo" fica como text
-- livre, SEM CHECK: o projeto ainda não tem uma taxonomia fechada (valores
-- esperados por enquanto: lei, pdf, apostila, resumo, edital, manual,
-- jurisprudencia, outro — documentado aqui só como guia, não imposto pelo
-- banco, pra não travar a curadoria com uma lista prematura).
-- ============================================================================

create table public.materiais (
  id uuid primary key default gen_random_uuid(),
  titulo text not null,
  tipo text not null,
  descricao text null,
  origem text null,
  ativo boolean not null default true,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

create function public.marcar_atualizacao_material()
returns trigger
language plpgsql
as $$
begin
  new.atualizado_em := now();
  return new;
end;
$$;

drop trigger if exists materiais_marca_atualizacao on public.materiais;
create trigger materiais_marca_atualizacao
  before update on public.materiais
  for each row
  execute function public.marcar_atualizacao_material();

-- Detalhe interno do trigger, não é uma RPC pública — revoga a exposição
-- padrão de EXECUTE só depois de criar o trigger (CREATE TRIGGER exige
-- EXECUTE na função no momento da criação).
revoke execute on function public.marcar_atualizacao_material()
  from public, anon, authenticated;

-- ============================================================================
-- 2) material_versoes — snapshot IMUTÁVEL de um material. Nova revisão =
-- nova linha; nenhuma coluna atualizado_em, nenhum UPDATE esperado depois
-- de criada (reforçado adiante por RLS/GRANT, não por trigger — não existe
-- hoje um jeito de bloquear UPDATE a nível de tabela sem impedir o owner/
-- service_role, e não é isso que se quer bloquear).
--
-- arquivo_path (nullable, sem UNIQUE): mesmo nome de coluna já usado em
-- public.editais.arquivo_path (path relativo dentro de um bucket do
-- Storage), reservado aqui só como espaço no schema — NENHUM bucket de
-- Storage é criado nesta fase; upload/arquivo fica para quando esse fluxo
-- for desenhado.
-- ============================================================================

create table public.material_versoes (
  id uuid primary key default gen_random_uuid(),
  material_id uuid not null references public.materiais(id) on delete restrict,
  numero_versao integer not null check (numero_versao > 0),
  titulo_versao text null,
  conteudo_texto text null,
  arquivo_path text null,
  checksum text null,
  vigente_desde date null,
  vigente_ate date null,
  criado_em timestamptz not null default now(),
  unique (material_id, numero_versao),
  check (vigente_desde is null or vigente_ate is null or vigente_ate >= vigente_desde)
);

-- Sem índice extra em material_id: a UNIQUE(material_id, numero_versao)
-- acima já cobre buscas por material_id sozinho (coluna líder do índice
-- composto) — mesmo princípio de missoes.sql, não duplicar cobertura.

-- ============================================================================
-- 3) aulas — identidade lógica da aula, vinculada ao conteúdo programático
-- (curso_conteudos, a mesma referência que public.missoes.conteudo_id já
-- usa). ON DELETE RESTRICT: apagar um curso_conteudos não pode arrastar
-- silenciosamente uma aula autoral já publicada.
--
-- UNIQUE(conteudo_id): decisão explícita para o MVP da missão diária — uma
-- única aula lógica por curso_conteudos, para que missao.conteudo_id resolva
-- a aula sem ambiguidade (sem precisar escolher entre várias aulas
-- possíveis). Auditoria não encontrou nada em conflito com essa escolha.
-- Reversível depois (é só um DROP CONSTRAINT numa migration futura) se um
-- dia for preciso ter mais de uma aula lógica por conteúdo (ex.: trilhas
-- diferentes).
-- ============================================================================

create table public.aulas (
  id uuid primary key default gen_random_uuid(),
  conteudo_id bigint not null references public.curso_conteudos(id) on delete restrict,
  titulo text not null,
  ativa boolean not null default true,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),
  unique (conteudo_id)
);

create function public.marcar_atualizacao_aula()
returns trigger
language plpgsql
as $$
begin
  new.atualizado_em := now();
  return new;
end;
$$;

drop trigger if exists aulas_marca_atualizacao on public.aulas;
create trigger aulas_marca_atualizacao
  before update on public.aulas
  for each row
  execute function public.marcar_atualizacao_aula();

revoke execute on function public.marcar_atualizacao_aula()
  from public, anon, authenticated;

-- ============================================================================
-- 4) aula_versoes — versão publicável de uma aula. ON DELETE RESTRICT em
-- aula_id: apagar a identidade da aula não pode arrastar silenciosamente
-- versões já publicadas (histórico).
--
-- estrutura jsonb: só garante "é um objeto JSON" (jsonb_typeof = 'object')
-- — NENHUM schema interno é imposto nesta fase. O formato conceitual
-- (componentes ordenados: diagnostico/conceito/recall/questao_resolvida/
-- resumo_visual) é só documentação, não é validado pelo banco agora.
--
-- Índice único parcial (aula_id) where status = 'publicada': garante, a
-- nível de banco, que uma aula nunca tem duas versões "publicada" ao mesmo
-- tempo — decisão adicional, não pedida explicitamente na especificação,
-- sinalizada abaixo para sua aprovação explícita (fácil de remover depois
-- se não for desejada: é só um DROP INDEX).
-- ============================================================================

create table public.aula_versoes (
  id uuid primary key default gen_random_uuid(),
  aula_id uuid not null references public.aulas(id) on delete restrict,
  numero_versao integer not null check (numero_versao > 0),
  status text not null default 'rascunho'
    check (status in ('rascunho', 'publicada', 'arquivada')),
  estrutura jsonb not null check (jsonb_typeof(estrutura) = 'object'),
  criado_em timestamptz not null default now(),
  publicado_em timestamptz null,
  -- 'publicada' exige publicado_em preenchido; 'rascunho'/'arquivada' não
  -- têm restrição — uma arquivada pode (e deve) preservar a data histórica
  -- em que foi publicada, só não pode ser NULL especificamente quando o
  -- status atual é 'publicada'.
  check (status <> 'publicada' or publicado_em is not null),
  unique (aula_id, numero_versao)
);

-- DECISÃO A APROVAR: no máximo uma versão "publicada" por aula ao mesmo
-- tempo, garantido pelo próprio banco (índice único parcial).
create unique index aula_versoes_uma_publicada_idx
  on public.aula_versoes (aula_id)
  where status = 'publicada';

-- ============================================================================
-- 5) aula_versao_fontes — N:N entre aula_versoes e material_versoes: registra
-- EXATAMENTE quais snapshots de material foram usados para produzir aquela
-- versão de aula. Tabela de junção pura, sem id próprio — PK composta.
--
-- ON DELETE CASCADE em aula_versao_id: apagar uma linha de aula_versoes
-- (bloqueada por padrão em outros lugares, mas não impedida aqui) arrasta
-- só os próprios vínculos de fonte dela — nunca a linha de material_versoes
-- em si.
-- ON DELETE RESTRICT em material_versao_id: uma versão de material citada
-- por qualquer aula_versao nunca pode ser apagada enquanto citada — é
-- exatamente essa trava que garante que uma aula publicada fica presa às
-- versões exatas das fontes usadas nela.
-- ============================================================================

create table public.aula_versao_fontes (
  aula_versao_id uuid not null references public.aula_versoes(id) on delete cascade,
  material_versao_id uuid not null references public.material_versoes(id) on delete restrict,
  ordem integer null check (ordem is null or ordem > 0),
  observacao text null,
  criado_em timestamptz not null default now(),
  primary key (aula_versao_id, material_versao_id)
);

-- Índice extra (não redundante com a PK, que lidera por aula_versao_id):
-- suporta a consulta futura "quais aula_versoes citam este material_versao"
-- (base para detectar aula desatualizada quando existir material_versao
-- mais nova — não implementado nesta fase, só o modelo permite).
create index aula_versao_fontes_material_versao_id_idx
  on public.aula_versao_fontes (material_versao_id);

-- ============================================================================
-- 6) RLS — todas as 5 tabelas com RLS ativo e ZERO acesso para
-- anon/authenticated nesta fundação, de propósito.
--
-- Por quê: uma policy de SELECT correta pra aluno exigiria atravessar
-- aula_versoes -> aulas -> curso_conteudos -> curso_materias -> curso_id ->
-- matriculas (status ativa) só pra decidir se uma aula é "do curso do
-- aluno" — e materiais/material_versoes não têm NENHUM vínculo direto com
-- curso/matrícula (são conteúdo global, só citados indiretamente via
-- aula_versao_fontes). Escrever essa policy agora, sem ainda ter dado real
-- populando essas tabelas pra validar contra, é o tipo de policy complexa
-- que a instrução desta fase pediu explicitamente pra evitar. A leitura
-- para aluno será aberta numa fase futura via RPC SECURITY DEFINER (mesmo
-- padrão já usado por materias_do_curso_ativo/assuntos_do_curso_ativo/
-- iniciar_ou_recuperar_missao_diaria) — não via policy de RLS direta nem
-- via SELECT solto do cliente.
--
-- Nenhuma policy de INSERT/UPDATE/DELETE para authenticated é criada —
-- aluno não deve inserir materiais, editar materiais, criar versões, editar
-- aulas nem publicar aulas, exatamente como pedido. Autoria (admin) também
-- fica de fora nesta fundação — decidir se a escrita será por policy
-- eh_admin() direta na tabela ou por RPC de autoria é uma decisão de uma
-- fase futura, não tomada aqui.
-- ============================================================================

alter table public.materiais enable row level security;
alter table public.material_versoes enable row level security;
alter table public.aulas enable row level security;
alter table public.aula_versoes enable row level security;
alter table public.aula_versao_fontes enable row level security;

revoke all on public.materiais from anon, authenticated;
revoke all on public.material_versoes from anon, authenticated;
revoke all on public.aulas from anon, authenticated;
revoke all on public.aula_versoes from anon, authenticated;
revoke all on public.aula_versao_fontes from anon, authenticated;

COMMIT;
