-- PAPIRO — Partes de uma mesma prova oficial (P1, P2...).
--
-- Caso real que motivou: Fundatec/PC-RS 2025 Delegado. O PDF oficial é um
-- só documento (um hash), mas a prova tem duas partes com numeração
-- própria — P1 (Língua Portuguesa, Q1–40) e P2 (Conhecimentos Específicos,
-- Q1–80). O número mostrado ao candidato precisa continuar sendo o
-- numero_original (nunca P2 renumerada para 41–120), e o UNIQUE atual
-- (prova_id, numero_original) não comporta dois "Q1" na mesma prova.
--
-- Desenho (menor alteração genérica):
--   1) public.prova_partes: uma linha por parte da prova (codigo "P1",
--      nome, ordem). UNIQUE (prova_id, codigo) e (prova_id, ordem); e
--      UNIQUE (id, prova_id) só para servir de alvo da FK composta.
--   2) questoes.prova_parte_id NULLABLE. FK composta (prova_parte_id,
--      prova_id) -> prova_partes (id, prova_id): a parte sempre pertence à
--      MESMA prova da questão. MATCH SIMPLE deixa passar quando
--      prova_parte_id é NULL; o CHECK questoes_prova_parte_exige_prova
--      impede parte sem prova (caso que a FK simples não pegaria).
--   3) Unicidade em dois índices parciais:
--        - modelo atual (sem parte): (prova_id, numero_original)
--          WHERE prova_id IS NOT NULL AND prova_parte_id IS NULL;
--        - prova com partes: (prova_id, prova_parte_id, numero_original)
--          WHERE prova_parte_id IS NOT NULL.
--      O índice antigo questoes_prova_numero_key é recriado com o filtro
--      novo (mesmo nome). Todas as questões atuais têm prova_parte_id
--      NULL e continuam sob exatamente a mesma regra.
--   4) Tipos de caderno (1–4) NÃO são partes: o tipo 1 é a representação
--      canônica; os outros só servem para conferência no importador.
--
-- RLS/permissões: mesmo padrão de public.provas (RLS ligado, nada para
-- anon, authenticated só via eh_admin(); o importador usa service_role).
-- Nenhuma policy existente é alterada.
--
-- Impacto: ADD COLUMN nullable sem default não reescreve a tabela; a FK e
-- o CHECK validam as linhas atuais (todas com NULL — passam trivialmente).
-- Nenhuma linha existente é modificada.
--
-- Rollback (documentado, não executado por esta migration). PRÉ-
-- CONDIÇÃO: nenhuma questão com parte —
--   select count(*) from public.questoes where prova_parte_id is not null;  -- precisa ser 0
-- e então:
--   drop index if exists public.questoes_prova_parte_numero_key;
--   drop index if exists public.questoes_prova_numero_key;
--   alter table public.questoes
--     drop constraint if exists questoes_prova_parte_exige_prova,
--     drop constraint if exists questoes_prova_parte_fkey,
--     drop column if exists prova_parte_id;
--   create unique index questoes_prova_numero_key on public.questoes (prova_id, numero_original) where prova_id is not null;
--   drop table if exists public.prova_partes;
--   delete from supabase_migrations.schema_migrations where version = '20261021120000';

create table public.prova_partes (
  id bigint generated always as identity primary key,
  prova_id bigint not null references public.provas(id) on delete restrict,
  codigo text not null check (codigo ~ '^[A-Z0-9][A-Z0-9_-]{0,15}$'),
  nome text not null check (btrim(nome) <> ''),
  ordem smallint not null check (ordem between 1 and 20),
  criado_em timestamptz not null default now(),
  constraint prova_partes_codigo_key unique (prova_id, codigo),
  constraint prova_partes_ordem_key unique (prova_id, ordem),
  constraint prova_partes_id_prova_key unique (id, prova_id)
);

alter table public.prova_partes enable row level security;

revoke all on public.prova_partes from anon, authenticated;
grant select, insert, update, delete on public.prova_partes to authenticated;

create policy "Admin gerencia partes de provas"
  on public.prova_partes
  for all
  to authenticated
  using (public.eh_admin())
  with check (public.eh_admin());

alter table public.questoes
  add column prova_parte_id bigint;

alter table public.questoes
  add constraint questoes_prova_parte_fkey
    foreign key (prova_parte_id, prova_id) references public.prova_partes (id, prova_id) on delete restrict,
  add constraint questoes_prova_parte_exige_prova
    check (prova_parte_id is null or prova_id is not null);

drop index public.questoes_prova_numero_key;

create unique index questoes_prova_numero_key
  on public.questoes (prova_id, numero_original)
  where prova_id is not null and prova_parte_id is null;

create unique index questoes_prova_parte_numero_key
  on public.questoes (prova_id, prova_parte_id, numero_original)
  where prova_parte_id is not null;
