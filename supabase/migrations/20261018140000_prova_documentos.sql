-- PAPIRO — Documentos complementares que determinam o gabarito final de
-- uma prova.
--
-- Necessidade real (importador de provas, scripts/importador-provas): a
-- Polícia Penal RS 2026 tem o gabarito definitivo (Edital 24/2026) e uma
-- retificação posterior (Edital 27/2026) que anula a questão 15. Hoje
-- public.provas só guarda UM documento de gabarito (gabarito_url /
-- hash_gabarito) — a retificação muda o resultado gravado, mas não fica
-- registrada em lugar nenhum do banco.
--
-- Auditoria de public.provas (20261018120000_proveniencia_provas.sql):
--   - identidade do caderno = hash_prova (UNIQUE) + chave natural;
--   - gabarito = gabarito_url + hash_gabarito, um só;
--   - FK questoes.prova_id ON DELETE RESTRICT;
--   - RLS: nada para anon; authenticated só via eh_admin(); importador
--     grava com papel privilegiado (ignora RLS).
--
-- Desenho (menor estrutura possível):
--   public.prova_documentos — um registro por documento que participou
--   da determinação do gabarito final, 0..N por prova.
--   - tipo GABARITO (ordem 0): o gabarito base. Repete hash_gabarito de
--     provas de propósito — provas.gabarito_url/hash_gabarito continuam
--     como estão, por compatibilidade, e o executor confere que os dois
--     batem.
--   - tipo RETIFICACAO (ordem >= 1): aplicadas em ordem crescente. A
--     ordem é explícita, nunca derivada do nome do arquivo.
--   - hash_sha256 é a identidade do documento (obrigatório); url é só
--     auditoria (opcional, nunca identidade).
--   - UNIQUE (prova_id, tipo, ordem): um gabarito base por prova e uma
--     posição por retificação. UNIQUE (prova_id, hash_sha256): o mesmo
--     documento nunca entra duas vezes na mesma prova. O mesmo PDF pode
--     servir a provas diferentes (um edital cobre vários cargos) — por
--     isso o hash não é UNIQUE global.
--   - ON DELETE CASCADE: o documento é metadado da prova e não tem
--     sentido sozinho (diferente de questoes, que são conteúdo e usam
--     RESTRICT — apagar uma prova com questões continua bloqueado por
--     elas).
--   - Sem descrição/nome de arquivo: nada aqui depende do nome.
--
-- RLS/permissões: mesmo padrão de public.provas (RLS ligado, revoke de
-- anon/authenticated, só admin via eh_admin()); o importador grava com
-- papel privilegiado. Nenhuma tabela existente é alterada; legado não é
-- reconstruído (public.provas está vazia nesta data).
--
-- Rollback (documentado, não executado):
--   drop table if exists public.prova_documentos;
--   delete from supabase_migrations.schema_migrations where version = '20261018140000';

create table public.prova_documentos (
  id bigint generated always as identity primary key,
  prova_id bigint not null references public.provas(id) on delete cascade,
  tipo text not null check (tipo in ('GABARITO', 'RETIFICACAO')),
  ordem smallint not null,
  url text check (url is null or url ~ '^https?://'),
  hash_sha256 text not null check (hash_sha256 ~ '^[0-9a-f]{64}$'),
  criado_em timestamptz not null default now(),
  constraint prova_documentos_ordem_check check ((tipo = 'GABARITO' and ordem = 0) or (tipo = 'RETIFICACAO' and ordem between 1 and 99)),
  constraint prova_documentos_posicao_key unique (prova_id, tipo, ordem),
  constraint prova_documentos_hash_key unique (prova_id, hash_sha256)
);

alter table public.prova_documentos enable row level security;
revoke all on public.prova_documentos from anon, authenticated;
grant select, insert, update, delete on public.prova_documentos to authenticated;

create policy "Admin gerencia documentos de provas"
  on public.prova_documentos
  for all
  to authenticated
  using (public.eh_admin())
  with check (public.eh_admin());
