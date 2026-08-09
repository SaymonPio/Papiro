BEGIN;

-- Base programática do curso: curso_materias, curso_conteudos, curso_evidencias,
-- progresso_conteudo_matricula.
--
-- Envolvida explicitamente em BEGIN/COMMIT (ver final do arquivo): não depende da
-- suposição de que o SQL Editor do Supabase agrupa automaticamente múltiplas
-- instruções numa única transação. Nenhuma instrução deste arquivo exige execução
-- fora de transação (sem CREATE INDEX CONCURRENTLY, sem VACUUM, sem ALTER SYSTEM
-- ou equivalentes) — só DDL padrão (CREATE TABLE/INDEX/FUNCTION/TRIGGER/POLICY,
-- ALTER TABLE ADD COLUMN, DO blocks), todos seguros dentro de uma transação.
--
-- Reaproveita integralmente a taxonomia global já existente (materias, assuntos,
-- questoes) sem alterá-la. curso_conteudos, curso_evidencias e
-- progresso_conteudo_matricula são tabelas novas (aditivas). public.curso_materias
-- JÁ EXISTE no banco real, populada com dados (23 linhas em 3 cursos) — NÃO é
-- recriada aqui; só recebe colunas novas via ALTER TABLE ADD COLUMN IF NOT EXISTS,
-- todas nullable ou com default seguro, sem tocar em id/curso_id/nome/peso/ordem
-- nem no UNIQUE(curso_id, nome) já existente. A RLS real de curso_materias
-- ("Administrador gerencia matérias dos cursos", "Aluno visualiza matérias de
-- cursos publicados") também não é tocada nesta etapa.
-- Nenhum backfill, nenhuma migração de materias.peso_edital/frequencia_historica/
-- percentual_acertos, nenhuma alteração em editais, nenhuma alteração no cronograma.
--
-- Decisões arquiteturais desta etapa (para referência futura):
--   - curso_materias/curso_conteudos representam a base programática do curso,
--     independente de qualquer edital específico — sobrevivem à troca de edital.
--   - "Presença no edital vigente" NUNCA é armazenada como coluna: é sempre derivada
--     de curso_evidencias (tipo_origem relacionado a edital + edital_id) cruzado com
--     qual edital é hoje o vigente daquele curso. Por isso não existe aqui nenhum
--     campo "presente_no_edital_atual".
--   - curso_materias.relevante_para_preparacao e curso_conteudos.relevante_para_preparacao
--     representam uma decisão estratégica de admin ("vale estudar isso agora"),
--     desacoplada de estar ou não no edital vigente. Nomeado assim (em vez de "ativo")
--     para não sugerir "ativo no edital atual". Usado o mesmo nome nas duas tabelas
--     por consistência (a decisão original só citava curso_conteudos; estendi para
--     curso_materias pelo mesmo motivo semântico, sinalizado na resposta ao usuário).
--   - Nenhuma linha de curso_materias/curso_conteudos é apagada quando um conteúdo sai
--     do edital vigente — só relevante_para_preparacao pode mudar; o histórico
--     (evidências e progresso) permanece intacto.
--   - curso_evidencias é uma tabela separada (não uma coluna "origem"), porque um
--     mesmo conteúdo pode ter múltiplas evidências simultâneas (ex.: edital anterior +
--     várias provas anteriores + inclusão manual).
--   - progresso_conteudo_matricula é vinculado a matricula_id (não usuario_id
--     diretamente), preservando o isolamento por curso já estabelecido no projeto.
--     Não duplica questoes_respondidas/acertos/percentual/timestamps de estudo — esses
--     são deriváveis com segurança de respostas_usuarios/sessoes_estudo/revisoes via a
--     cadeia já validada em etapas anteriores. Só "estado" é armazenado, por ser uma
--     classificação que não é uma simples agregação.
--   - Nenhuma policy de INSERT/UPDATE/DELETE é criada para o aluno em
--     progresso_conteudo_matricula — a escrita de "estado" fica para uma função do
--     sistema a ser desenhada numa etapa futura. Só SELECT do dono da matrícula.
--
-- Duas triggers de integridade (Postgres não permite CHECK entre tabelas diferentes):
--   1) curso_conteudos: assunto_id precisa pertencer à mesma matéria de curso_materias.
--   2) progresso_conteudo_matricula: o curso da matrícula precisa ser o mesmo curso do
--      conteúdo referenciado (via curso_conteudos -> curso_materias.curso_id).
--
-- Idempotente e reexecutável com segurança: CREATE TABLE IF NOT EXISTS,
-- CREATE INDEX IF NOT EXISTS, CREATE OR REPLACE FUNCTION,
-- DROP TRIGGER IF EXISTS + CREATE TRIGGER, DROP POLICY IF EXISTS + CREATE POLICY.
--
-- Depende de public.eh_admin() (já usada em outras etapas deste projeto, não
-- definida em SQL versionado neste repositório) e de public.cursos/matriculas/
-- materias/assuntos/editais já existentes.

-- ============================================================================
-- 1) curso_materias — JÁ EXISTE (populada). Evolução aditiva apenas.
-- Schema real preservado: id bigint, curso_id uuid not null -> cursos(id),
-- nome text not null, peso numeric, ordem integer not null default 0,
-- unique(curso_id, nome). Nada disso é alterado aqui.
-- ============================================================================

-- Checagem defensiva: confirma os tipos reais de id/curso_id antes de evoluir a tabela.
do $$
declare
  v_tipo_id text;
  v_tipo_curso_id text;
begin
  select data_type into v_tipo_id
  from information_schema.columns
  where table_schema = 'public' and table_name = 'curso_materias' and column_name = 'id';

  select data_type into v_tipo_curso_id
  from information_schema.columns
  where table_schema = 'public' and table_name = 'curso_materias' and column_name = 'curso_id';

  if v_tipo_id is not null and v_tipo_id <> 'bigint' then
    raise exception 'public.curso_materias.id existe com tipo % (esperado bigint). Resolva manualmente antes de reexecutar esta migração.', v_tipo_id;
  end if;

  if v_tipo_curso_id is not null and v_tipo_curso_id <> 'uuid' then
    raise exception 'public.curso_materias.curso_id existe com tipo % (esperado uuid). Resolva manualmente antes de reexecutar esta migração.', v_tipo_curso_id;
  end if;
end;
$$;

-- Checagem defensiva: se materia_id já existir (de alguma tentativa anterior),
-- precisa ser bigint.
do $$
declare
  v_tipo_materia_id text;
begin
  select data_type into v_tipo_materia_id
  from information_schema.columns
  where table_schema = 'public' and table_name = 'curso_materias' and column_name = 'materia_id';

  if v_tipo_materia_id is not null and v_tipo_materia_id <> 'bigint' then
    raise exception 'public.curso_materias.materia_id existe com tipo % (esperado bigint). Resolva manualmente antes de reexecutar esta migração.', v_tipo_materia_id;
  end if;
end;
$$;

-- Colunas novas: todas nullable ou com default seguro. materia_id nasce NULL —
-- nenhum backfill, nenhum matching por nome é feito aqui (isso é curadoria manual
-- futura, fora deste arquivo). Nenhuma UNIQUE(curso_id, materia_id) é criada agora.
alter table public.curso_materias
  add column if not exists materia_id bigint references public.materias(id) on delete restrict;

alter table public.curso_materias
  add column if not exists quantidade_questoes integer;

alter table public.curso_materias
  add column if not exists frequencia_historica numeric;

alter table public.curso_materias
  add column if not exists prioridade_estrategica smallint;

alter table public.curso_materias
  add column if not exists relevante_para_preparacao boolean not null default true;

alter table public.curso_materias
  add column if not exists criado_em timestamptz not null default now();

alter table public.curso_materias
  add column if not exists atualizado_em timestamptz not null default now();

create index if not exists curso_materias_materia_id_idx on public.curso_materias (materia_id);

-- ============================================================================
-- 2) curso_conteudos
-- ============================================================================
create table if not exists public.curso_conteudos (
  id bigint generated by default as identity primary key,
  curso_materia_id bigint not null references public.curso_materias(id) on delete cascade,
  assunto_id bigint not null references public.assuntos(id) on delete restrict,
  ordem integer not null default 0,
  frequencia_historica numeric,
  prioridade_estrategica smallint,
  relevante_para_preparacao boolean not null default true,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),
  unique (curso_materia_id, assunto_id),
  check (ordem >= 0)
);

create index if not exists curso_conteudos_assunto_id_idx on public.curso_conteudos (assunto_id);

-- Trigger de integridade: o assunto precisa pertencer à mesma matéria da curso_materia pai.
create or replace function public.validar_assunto_da_curso_materia()
returns trigger
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_materia_id_assunto bigint;
  v_materia_id_curso_materia bigint;
begin
  select cm.materia_id into v_materia_id_curso_materia
  from public.curso_materias cm
  where cm.id = new.curso_materia_id;

  if v_materia_id_curso_materia is null then
    raise exception 'curso_materia % ainda não tem materia_id definido (curadoria pendente) — não é possível associar conteúdo antes da curadoria.', new.curso_materia_id
      using errcode = 'check_violation';
  end if;

  select a.materia_id into v_materia_id_assunto
  from public.assuntos a
  where a.id = new.assunto_id;

  if v_materia_id_assunto is distinct from v_materia_id_curso_materia then
    raise exception 'assunto_id % pertence a uma matéria diferente da curso_materia %', new.assunto_id, new.curso_materia_id
      using errcode = 'check_violation';
  end if;

  return new;
end;
$function$;

drop trigger if exists curso_conteudos_valida_assunto on public.curso_conteudos;
create trigger curso_conteudos_valida_assunto
  before insert or update of curso_materia_id, assunto_id on public.curso_conteudos
  for each row
  execute function public.validar_assunto_da_curso_materia();

-- ============================================================================
-- 3) curso_evidencias
-- ============================================================================
create table if not exists public.curso_evidencias (
  id bigint generated by default as identity primary key,
  curso_materia_id bigint references public.curso_materias(id) on delete cascade,
  curso_conteudo_id bigint references public.curso_conteudos(id) on delete cascade,
  tipo_origem text not null check (tipo_origem in ('edital_atual', 'edital_anterior', 'prova_anterior', 'historico_banca', 'manual')),
  edital_id uuid references public.editais(id) on delete set null,
  frequencia integer,
  descricao text,
  criado_em timestamptz not null default now(),
  check (
    (curso_materia_id is not null and curso_conteudo_id is null)
    or
    (curso_materia_id is null and curso_conteudo_id is not null)
  ),
  check (frequencia is null or frequencia >= 0)
);

create index if not exists curso_evidencias_curso_materia_id_idx on public.curso_evidencias (curso_materia_id);
create index if not exists curso_evidencias_curso_conteudo_id_idx on public.curso_evidencias (curso_conteudo_id);
create index if not exists curso_evidencias_edital_id_idx on public.curso_evidencias (edital_id);

-- ============================================================================
-- 4) progresso_conteudo_matricula
-- ============================================================================
create table if not exists public.progresso_conteudo_matricula (
  id bigint generated by default as identity primary key,
  matricula_id uuid not null references public.matriculas(id) on delete cascade,
  conteudo_id bigint not null references public.curso_conteudos(id) on delete cascade,
  estado text not null default 'nao_iniciado' check (estado in ('nao_iniciado', 'em_estudo', 'estudado', 'em_revisao', 'consolidado')),
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),
  unique (matricula_id, conteudo_id)
);

create index if not exists progresso_conteudo_matricula_conteudo_id_idx on public.progresso_conteudo_matricula (conteudo_id);

-- Trigger de integridade: o curso da matrícula precisa ser o mesmo curso do conteúdo.
create or replace function public.validar_curso_do_progresso_conteudo()
returns trigger
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_curso_matricula uuid;
  v_curso_conteudo uuid;
begin
  select m.curso_id into v_curso_matricula
  from public.matriculas m
  where m.id = new.matricula_id;

  select cm.curso_id into v_curso_conteudo
  from public.curso_conteudos cc
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where cc.id = new.conteudo_id;

  if v_curso_matricula is distinct from v_curso_conteudo then
    raise exception 'conteudo_id % não pertence ao curso da matrícula %', new.conteudo_id, new.matricula_id
      using errcode = 'check_violation';
  end if;

  return new;
end;
$function$;

drop trigger if exists progresso_conteudo_valida_curso on public.progresso_conteudo_matricula;
create trigger progresso_conteudo_valida_curso
  before insert or update of matricula_id, conteudo_id on public.progresso_conteudo_matricula
  for each row
  execute function public.validar_curso_do_progresso_conteudo();

-- ============================================================================
-- RLS
-- ============================================================================
alter table public.curso_materias enable row level security;
alter table public.curso_conteudos enable row level security;
alter table public.curso_evidencias enable row level security;
alter table public.progresso_conteudo_matricula enable row level security;

-- curso_materias: RLS real já existe e NÃO é tocada nesta etapa — preservadas
-- exatamente "Administrador gerencia matérias dos cursos" (ALL, eh_admin()) e
-- "Aluno visualiza matérias de cursos publicados" (SELECT). Nenhuma policy nova
-- criada aqui, nenhuma removida.

-- curso_conteudos: mesmo padrão que eu proponho (leitura para aluno matriculado
-- ativo, escrita só admin), via curso_materias -> curso_id.
drop policy if exists "Aluno matriculado visualiza conteúdos do curso" on public.curso_conteudos;
create policy "Aluno matriculado visualiza conteúdos do curso"
  on public.curso_conteudos for select to authenticated
  using (exists (
    select 1 from public.curso_materias cm
    join public.matriculas m on m.curso_id = cm.curso_id
    where cm.id = curso_conteudos.curso_materia_id
      and m.usuario_id = auth.uid()
      and m.status = 'ativa'
  ));

drop policy if exists "Administrador cria conteúdos do curso" on public.curso_conteudos;
create policy "Administrador cria conteúdos do curso"
  on public.curso_conteudos for insert to authenticated
  with check (public.eh_admin());

drop policy if exists "Administrador atualiza conteúdos do curso" on public.curso_conteudos;
create policy "Administrador atualiza conteúdos do curso"
  on public.curso_conteudos for update to authenticated
  using (public.eh_admin())
  with check (public.eh_admin());

drop policy if exists "Administrador exclui conteúdos do curso" on public.curso_conteudos;
create policy "Administrador exclui conteúdos do curso"
  on public.curso_conteudos for delete to authenticated
  using (public.eh_admin());

-- curso_evidencias: mesmo padrão, via qualquer um dos dois pais possíveis.
drop policy if exists "Aluno matriculado visualiza evidências do curso" on public.curso_evidencias;
create policy "Aluno matriculado visualiza evidências do curso"
  on public.curso_evidencias for select to authenticated
  using (
    exists (
      select 1 from public.curso_materias cm
      join public.matriculas m on m.curso_id = cm.curso_id
      where cm.id = curso_evidencias.curso_materia_id
        and m.usuario_id = auth.uid()
        and m.status = 'ativa'
    )
    or exists (
      select 1 from public.curso_conteudos cc
      join public.curso_materias cm on cm.id = cc.curso_materia_id
      join public.matriculas m on m.curso_id = cm.curso_id
      where cc.id = curso_evidencias.curso_conteudo_id
        and m.usuario_id = auth.uid()
        and m.status = 'ativa'
    )
  );

drop policy if exists "Administrador cria evidências do curso" on public.curso_evidencias;
create policy "Administrador cria evidências do curso"
  on public.curso_evidencias for insert to authenticated
  with check (public.eh_admin());

drop policy if exists "Administrador atualiza evidências do curso" on public.curso_evidencias;
create policy "Administrador atualiza evidências do curso"
  on public.curso_evidencias for update to authenticated
  using (public.eh_admin())
  with check (public.eh_admin());

drop policy if exists "Administrador exclui evidências do curso" on public.curso_evidencias;
create policy "Administrador exclui evidências do curso"
  on public.curso_evidencias for delete to authenticated
  using (public.eh_admin());

-- progresso_conteudo_matricula: aluno só SELECT da própria matrícula.
-- Nenhuma policy de INSERT/UPDATE/DELETE para o cliente — escrita fica para função
-- do sistema, a desenhar em etapa futura.
drop policy if exists "Aluno visualiza o próprio progresso de conteúdo" on public.progresso_conteudo_matricula;
create policy "Aluno visualiza o próprio progresso de conteúdo"
  on public.progresso_conteudo_matricula for select to authenticated
  using (exists (
    select 1 from public.matriculas m
    where m.id = progresso_conteudo_matricula.matricula_id
      and m.usuario_id = auth.uid()
  ));

COMMIT;
