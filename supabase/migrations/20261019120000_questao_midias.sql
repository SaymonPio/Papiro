-- PAPIRO — Mídias de questões (figuras, gráficos, charges...).
--
-- Necessidade real (importador de provas, scripts/importador-provas): a
-- GM Porto Alegre 2025 tem 3 questões que dependem de imagem (Q2 charge,
-- Q17 Figura 1, Q18 Figura 2) e a PC-PR 2026 também; hoje questoes só
-- guarda texto e essas questões ficam fora do banco.
--
-- Auditoria (2026-10-19):
--   - questoes: nenhuma coluna de mídia; enunciado é texto puro
--     (renderizado com white-space: pre-line em .question-card h1).
--   - Storage: 3 buckets, todos PRIVADOS (editais, materiais-teoria,
--     quadrinhos-aulas). O padrão de imagem já adotado é o da camada
--     ilustrada: bucket privado SEM policy em storage.objects, assinatura
--     de URL temporária por Edge Function depois de o usuário ser
--     autorizado pelo PRÓPRIO client (RLS/RPC) — service_role nunca
--     decide acesso.
--   - RLS de questoes/alternativas: aluno vê questão ativa e global (ou
--     própria); admin via eh_admin(). Este desenho repete exatamente isso.
--
-- Desenho (menor estrutura possível):
--   public.questao_midias — 0..N mídias por questão, ordem determinística.
--   - sha256 é a IDENTIDADE do arquivo; storage_path é derivado dele
--     (questoes/<sha256>.<ext>) — conteúdo-endereçado: a mesma mídia em
--     duas questões é UM objeto e duas linhas; reupload é idempotente.
--   - UNIQUE (questao_id, ordem) e UNIQUE (questao_id, sha256): ordem
--     única e a mesma mídia nunca duas vezes na mesma questão.
--   - Proveniência: prova_id + pagina_origem (juntos ou nenhum) e
--     origem_descricao (ex.: objetos do PDF compostos).
--   - Posição semântica: ancora_texto = linha do enunciado ANTES da qual a
--     mídia aparece (null = depois do enunciado, antes das alternativas).
--   - alt_text obrigatório; o pipeline o gera sem nunca usar o texto das
--     alternativas (não entrega a resposta). credito opcional.
--   - direito_uso: OFICIAL_PROVA | LICENCIADO | REVISAO_DIREITOS (padrão).
--     Crédito não é permissão: mídia de terceiro entra como
--     REVISAO_DIREITOS e NUNCA é visível ao aluno (RLS) nem pode estar
--     numa questão ativa (trigger).
--   - Tipos: FIGURA, GRAFICO, TABELA, MAPA, CHARGE (CHARGE sinaliza mídia
--     de terceiro; os demais só ajudam o texto alternativo).
--
-- Mídia removida não quebra a questão em silêncio (triggers):
--   - não se apaga mídia nem se rebaixa direito_uso de questão ATIVA
--     (desative a questão antes);
--   - não se insere mídia sem direito de publicação em questão ativa;
--   - não se ativa questão que tenha mídia sem direito de publicação;
--   - sha256/storage_path/questao_id são imutáveis (troca = nova linha).
--   Apagar a questão leva as mídias junto (ON DELETE CASCADE).
--
-- Storage: bucket PRIVADO questao-midias (png/jpeg/webp, 2 MiB), SEM
-- policy em storage.objects — só service_role grava (importador) e assina
-- (Edge assinar-questao-midias). Objeto físico nunca é apagado por SQL.
--
-- RLS/permissões: RLS ligado; nada para anon; authenticated lê só mídia
-- publicável de questão que ele já pode ver; admin gerencia via
-- eh_admin(); o importador grava com papel privilegiado.
--
-- Rollback (documentado, não executado):
--   drop trigger if exists questoes_ativa_exige_midias_publicaveis on public.questoes;
--   drop table if exists public.questao_midias;
--   drop function if exists public.questao_midias_proteger();
--   drop function if exists public.questoes_ativa_exige_midias_publicaveis();
--   delete from storage.buckets where id = 'questao-midias';  -- só se vazio
--   delete from supabase_migrations.schema_migrations where version = '20261019120000';

create table public.questao_midias (
  id bigint generated always as identity primary key,
  questao_id bigint not null references public.questoes(id) on delete cascade,
  ordem smallint not null check (ordem between 1 and 20),
  tipo text not null check (tipo in ('FIGURA', 'GRAFICO', 'TABELA', 'MAPA', 'CHARGE')),
  sha256 text not null check (sha256 ~ '^[0-9a-f]{64}$'),
  mime_type text not null check (mime_type in ('image/png', 'image/jpeg', 'image/webp')),
  storage_path text not null,
  largura integer not null check (largura between 1 and 8000),
  altura integer not null check (altura between 1 and 8000),
  prova_id bigint references public.provas(id) on delete restrict,
  pagina_origem smallint check (pagina_origem between 1 and 2000),
  ancora_texto text check (ancora_texto is null or length(btrim(ancora_texto)) > 0),
  legenda text,
  alt_text text not null check (length(btrim(alt_text)) between 3 and 300),
  credito text,
  direito_uso text not null default 'REVISAO_DIREITOS' check (direito_uso in ('OFICIAL_PROVA', 'LICENCIADO', 'REVISAO_DIREITOS')),
  origem_descricao text,
  criado_em timestamptz not null default now(),
  constraint questao_midias_path_check check (
    storage_path = 'questoes/' || sha256 || case mime_type when 'image/png' then '.png' when 'image/jpeg' then '.jpg' else '.webp' end
  ),
  constraint questao_midias_proveniencia_check check ((prova_id is null) = (pagina_origem is null)),
  constraint questao_midias_ordem_key unique (questao_id, ordem),
  constraint questao_midias_sha_key unique (questao_id, sha256)
);

create index questao_midias_sha_idx on public.questao_midias (sha256);

create function public.questao_midias_proteger() returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_ativa boolean;
begin
  select q.ativa into v_ativa from public.questoes q where q.id = coalesce(new.questao_id, old.questao_id);
  if tg_op = 'DELETE' then
    if v_ativa then
      raise exception 'questao_midias: a questão % está ativa — desative-a antes de remover a mídia', old.questao_id;
    end if;
    return old;
  end if;
  if tg_op = 'UPDATE' and (new.questao_id <> old.questao_id or new.sha256 <> old.sha256 or new.storage_path <> old.storage_path) then
    raise exception 'questao_midias: questao_id/sha256/storage_path são imutáveis — insira uma nova mídia';
  end if;
  if v_ativa and new.direito_uso = 'REVISAO_DIREITOS' then
    raise exception 'questao_midias: a questão % está ativa e esta mídia não tem direito de publicação', new.questao_id;
  end if;
  return new;
end;
$$;

create trigger questao_midias_proteger
  before insert or update or delete on public.questao_midias
  for each row execute function public.questao_midias_proteger();

create function public.questoes_ativa_exige_midias_publicaveis() returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.ativa and exists (
    select 1 from public.questao_midias m where m.questao_id = new.id and m.direito_uso = 'REVISAO_DIREITOS'
  ) then
    raise exception 'questoes: a questão % tem mídia sem direito de publicação — não pode ficar ativa', new.id;
  end if;
  return new;
end;
$$;

create trigger questoes_ativa_exige_midias_publicaveis
  before update of ativa on public.questoes
  for each row when (new.ativa and not old.ativa)
  execute function public.questoes_ativa_exige_midias_publicaveis();

alter table public.questao_midias enable row level security;
revoke all on public.questao_midias from anon, authenticated;
grant select, insert, update, delete on public.questao_midias to authenticated;

create policy "Admin gerencia midias de questoes"
  on public.questao_midias
  for all
  to authenticated
  using (public.eh_admin())
  with check (public.eh_admin());

create policy "Midias publicaveis de questoes visiveis"
  on public.questao_midias
  for select
  to authenticated
  using (
    direito_uso in ('OFICIAL_PROVA', 'LICENCIADO')
    and exists (
      select 1 from public.questoes q
       where q.id = questao_midias.questao_id
         and q.ativa
         and (q.usuario_id is null or q.usuario_id = (select auth.uid()))
    )
  );

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('questao-midias', 'questao-midias', false, 2097152, array['image/png', 'image/jpeg', 'image/webp']);
