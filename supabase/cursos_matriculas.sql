-- Etapa 1 do isolamento de dados por curso: fundação aditiva (versão corrigida).
-- public.cursos e public.matriculas JÁ EXISTEM no banco e NÃO são recriadas nem alteradas aqui:
--   - cursos: id uuid, slug, carreira, concurso, cargo, banca, status, data_prova;
--   - matriculas: id uuid, usuario_id, curso_id, status, origem, matriculado_em, expira_em,
--     com FKs para auth.users/cursos e UNIQUE(usuario_id, curso_id) já existentes na tabela real.
-- public.cursos.id (uuid) é a chave oficial de curso em todo o Papiro; toda coluna curso_id
-- criada a partir de agora (aqui e em etapas futuras) deve ser uuid.
-- Só public.perfis é criada por este arquivo. Preferências de estudo (ex.: horas_diarias)
-- não ficam em matriculas — vivem em public.configuracoes_estudo (supabase/configuracoes_estudo.sql).
--
-- Este arquivo é idempotente e pode ser reexecutado com segurança:
--   - CREATE TABLE IF NOT EXISTS / CREATE INDEX IF NOT EXISTS para tabelas/índices;
--   - CREATE OR REPLACE FUNCTION para funções;
--   - DROP TRIGGER IF EXISTS + CREATE TRIGGER para triggers;
--   - DROP POLICY IF EXISTS + CREATE POLICY para policies.
-- Antes de criar/usar perfis (e de indexar matriculas), uma checagem defensiva aborta a
-- execução (RAISE EXCEPTION) caso encontre curso_id em um tipo diferente de uuid —
-- nenhuma conversão, exclusão ou alteração automática de dado é feita.
--
-- Depende da função public.eh_admin() já usada em app/admin/page.tsx
-- (não definida em SQL versionado neste repositório — confirme que existe no banco antes de aplicar).

-- Checagem defensiva: public.matriculas já existe na estrutura real (id uuid, usuario_id,
-- curso_id, status, origem, matriculado_em, expira_em). Não é recriada nem alterada aqui.
-- A checagem abaixo só confirma que curso_id continua uuid antes de criarmos o índice
-- e as policies que dependem disso.
do $$
declare
  tipo_atual text;
begin
  select data_type into tipo_atual
  from information_schema.columns
  where table_schema = 'public' and table_name = 'matriculas' and column_name = 'curso_id';

  if tipo_atual is not null and tipo_atual <> 'uuid' then
    raise exception 'public.matriculas.curso_id existe com tipo % (esperado uuid). Resolva manualmente antes de reexecutar esta migração.', tipo_atual;
  end if;
end;
$$;

create index if not exists matriculas_curso_id_idx on public.matriculas (curso_id);

-- Checagem defensiva: perfis.curso_ativo_id, se já existir, precisa ser uuid.
do $$
declare
  tipo_atual text;
begin
  select data_type into tipo_atual
  from information_schema.columns
  where table_schema = 'public' and table_name = 'perfis' and column_name = 'curso_ativo_id';

  if tipo_atual is not null and tipo_atual <> 'uuid' then
    raise exception 'public.perfis.curso_ativo_id já existe com tipo % (esperado uuid). Resolva manualmente antes de reexecutar esta migração.', tipo_atual;
  end if;
end;
$$;

create table if not exists public.perfis (
  usuario_id uuid primary key references auth.users(id) on delete cascade,
  curso_ativo_id uuid references public.cursos(id) on delete set null,
  atualizado_em timestamptz not null default now()
);

-- Garante que curso_ativo_id só aponte para um curso em que o usuário
-- realmente tenha matrícula. usuario_id nunca é alterado por esta trigger.
create or replace function public.validar_curso_ativo()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.curso_ativo_id is not null and not exists (
    select 1 from public.matriculas m
    where m.usuario_id = new.usuario_id
      and m.curso_id = new.curso_ativo_id
  ) then
    raise exception 'curso_ativo_id % não corresponde a uma matrícula do usuário %', new.curso_ativo_id, new.usuario_id
      using errcode = 'foreign_key_violation';
  end if;
  return new;
end;
$$;

drop trigger if exists perfis_valida_curso_ativo on public.perfis;
create trigger perfis_valida_curso_ativo
  before insert or update of curso_ativo_id, usuario_id on public.perfis
  for each row
  execute function public.validar_curso_ativo();

-- Quando uma matrícula que estava marcada como curso ativo é removida,
-- zera somente curso_ativo_id — usuario_id do perfil permanece intacto.
create or replace function public.limpar_curso_ativo_ao_remover_matricula()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.perfis
    set curso_ativo_id = null,
        atualizado_em = now()
    where usuario_id = old.usuario_id
      and curso_ativo_id = old.curso_id;
  return old;
end;
$$;

drop trigger if exists matriculas_apos_exclusao on public.matriculas;
create trigger matriculas_apos_exclusao
  after delete on public.matriculas
  for each row
  execute function public.limpar_curso_ativo_ao_remover_matricula();

-- Etapa 3: fecha o gap em que perfis.curso_ativo_id podia continuar apontando para um curso
-- cuja matrícula deixou de estar 'ativa' (ex.: cancelada), sem nada limpar automaticamente.
-- Reaproveita a MESMA função da trigger acima (mesma lógica: zera só curso_ativo_id, nunca
-- usuario_id), agora também disparada quando o status de uma matrícula deixa de ser 'ativa'.
drop trigger if exists matriculas_status_alterado on public.matriculas;
create trigger matriculas_status_alterado
  after update of status on public.matriculas
  for each row
  when (old.status = 'ativa' and new.status is distinct from 'ativa')
  execute function public.limpar_curso_ativo_ao_remover_matricula();

alter table public.cursos enable row level security;
alter table public.matriculas enable row level security;
alter table public.perfis enable row level security;

-- cursos: schema preservado como está; apenas RLS/policies são geridas aqui.
-- Catálogo visível a qualquer usuário autenticado; escrita restrita a administradores.
drop policy if exists "Qualquer usuário autenticado visualiza cursos" on public.cursos;
create policy "Qualquer usuário autenticado visualiza cursos" on public.cursos for select to authenticated using (true);

drop policy if exists "Administrador cria cursos" on public.cursos;
create policy "Administrador cria cursos" on public.cursos for insert to authenticated with check (public.eh_admin());

drop policy if exists "Administrador atualiza cursos" on public.cursos;
create policy "Administrador atualiza cursos" on public.cursos for update to authenticated using (public.eh_admin()) with check (public.eh_admin());

drop policy if exists "Administrador exclui cursos" on public.cursos;
create policy "Administrador exclui cursos" on public.cursos for delete to authenticated using (public.eh_admin());

-- matriculas: aluno só visualiza as próprias matrículas; criação e remoção ficam restritas ao administrador.
-- Nenhuma policy de UPDATE é criada agora — aluno não pode alterar curso_id/usuario_id, e a liberação
-- de horas_diarias editável pelo aluno fica para uma etapa futura.
drop policy if exists "Aluno visualiza as próprias matrículas" on public.matriculas;
create policy "Aluno visualiza as próprias matrículas" on public.matriculas for select to authenticated using (auth.uid() = usuario_id);

drop policy if exists "Administrador cria matrícula" on public.matriculas;
create policy "Administrador cria matrícula" on public.matriculas for insert to authenticated with check (public.eh_admin());

drop policy if exists "Administrador remove matrícula" on public.matriculas;
create policy "Administrador remove matrícula" on public.matriculas for delete to authenticated using (public.eh_admin());

-- perfis: cada aluno só vê e gerencia o próprio perfil (curso ativo).
drop policy if exists "Aluno gerencia o próprio perfil" on public.perfis;
create policy "Aluno gerencia o próprio perfil" on public.perfis for all to authenticated using (auth.uid() = usuario_id) with check (auth.uid() = usuario_id);
