-- PAPIRO — Proveniência de provas para o importador automático.
--
-- Menor alteração estrutural que dá rastreabilidade às questões NOVAS
-- do pipeline (scripts/importador-provas, commit 3e3cd60). Auditoria do
-- schema apresentada antes desta migration:
--   - questoes só tem fonte (text livre), banca/concurso/ano soltos —
--     nenhuma identidade de documento, nenhum número original.
--   - alternativas e curso_questoes não carregam proveniência e não
--     precisam: a origem é da questão, não da alternativa nem do vínculo
--     com curso. Nenhuma das duas é tocada aqui.
--
-- Desenho:
--   1) public.provas: um registro por DOCUMENTO de prova oficial.
--      Identidade = hash_prova (SHA-256 do PDF, UNIQUE) — nunca a URL:
--      o mesmo PDF pode estar em duas URLs, e a mesma URL pode servir um
--      PDF retificado. Segunda trava: chave natural normalizada
--      (banca, orgao, cargo, ano, nome), para o mesmo caderno
--      re-gerado com bytes diferentes não entrar duas vezes.
--      hash_gabarito NÃO é UNIQUE de propósito: um único gabarito
--      oficial pode cobrir vários cargos (visto em prova real:
--      FEPESE/PMBC 2014, gabarito único para "GM" e "AR"), e cada cargo
--      é uma prova distinta aqui.
--   2) questoes.prova_id + questoes.numero_original, ambos NULLABLE:
--      as 1.343 questões legadas ficam com NULL e não são
--      reconstruídas. CHECK exige os dois juntos ou nenhum (proveniência
--      pela metade não existe). UNIQUE parcial (prova_id,
--      numero_original) impede importar duas vezes a mesma questão da
--      mesma prova.
--   3) CHECK questoes_proveniencia_global: prova_id só em questão global
--      (usuario_id IS NULL). Sem isso, a policy "Aluno cria questoes
--      proprias" deixaria um aluno gravar prova_id/numero_original numa
--      questão privada e ocupar o slot do UNIQUE parcial, bloqueando a
--      importação oficial daquela questão. Feito como CHECK de tabela
--      (não como alteração de policy) para não tocar em nenhuma policy
--      existente de questoes.
--   4) questoes.fonte é preservado como está — o importador continua
--      podendo preenchê-lo, por compatibilidade com tudo que já lê esse
--      campo.
--   5) Sem tabela de lote: a prova já é a unidade de importação
--      (provas.criado_em + questoes.prova_id identificam o lote), e o
--      UNIQUE (prova_id, numero_original) já impede reimportação. Se um
--      dia uma mesma prova precisar de múltiplas execuções rastreadas,
--      isso entra numa migration própria.
--
-- RLS/permissões (mesmo padrão de unidades_pedagogicas + eh_admin()):
--   provas tem RLS ligado, nenhum acesso para anon, e para authenticated
--   só via policy eh_admin(). O importador escreve com service_role
--   (mesmo padrão de scripts/curadoria-pedagogica), que ignora RLS.
--   Aluno não lê provas por enquanto — nenhuma tela precisa disso ainda.
--   Nenhuma policy de questoes/alternativas/curso_questoes é alterada.
--
-- Impacto: ADD COLUMN nullable sem default não reescreve a tabela; os
-- CHECKs e a FK validam as 1.343 linhas atuais (todas com NULL —
-- passam trivialmente). Nenhuma linha existente é modificada.
--
-- Rollback (documentado, não executado por esta migration). PRÉ-
-- CONDIÇÃO: nenhuma questão com proveniência, senão o rollback apaga
-- rastreabilidade real —
--   select count(*) from public.questoes where prova_id is not null;  -- precisa ser 0
-- e então:
--   drop index if exists public.questoes_prova_numero_key;
--   alter table public.questoes
--     drop constraint if exists questoes_proveniencia_global,
--     drop constraint if exists questoes_proveniencia_completa,
--     drop constraint if exists questoes_numero_original_check,
--     drop column if exists numero_original,
--     drop column if exists prova_id;
--   drop table if exists public.provas;
--   delete from supabase_migrations.schema_migrations where version = '20261018120000';

create table public.provas (
  id bigint generated always as identity primary key,
  banca text not null check (btrim(banca) <> ''),
  orgao text not null check (btrim(orgao) <> ''),
  cargo text not null check (btrim(cargo) <> ''),
  ano integer not null check (ano between 1900 and 2200),
  nome text not null check (btrim(nome) <> ''),
  fonte_url text not null check (fonte_url ~ '^https?://'),
  gabarito_url text check (gabarito_url is null or gabarito_url ~ '^https?://'),
  hash_prova text not null check (hash_prova ~ '^[0-9a-f]{64}$'),
  hash_gabarito text not null check (hash_gabarito ~ '^[0-9a-f]{64}$'),
  criado_em timestamptz not null default now(),
  constraint provas_hash_prova_key unique (hash_prova)
);

create unique index provas_identidade_key on public.provas (
  lower(btrim(banca)),
  lower(btrim(orgao)),
  lower(btrim(cargo)),
  ano,
  lower(btrim(nome))
);

alter table public.provas enable row level security;
revoke all on public.provas from anon, authenticated;
grant select, insert, update, delete on public.provas to authenticated;

create policy "Admin gerencia provas"
  on public.provas
  for all
  to authenticated
  using (public.eh_admin())
  with check (public.eh_admin());

alter table public.questoes
  add column prova_id bigint references public.provas(id) on delete restrict,
  add column numero_original smallint;

alter table public.questoes
  add constraint questoes_numero_original_check
    check (numero_original is null or numero_original between 1 and 999),
  add constraint questoes_proveniencia_completa
    check ((prova_id is null) = (numero_original is null)),
  add constraint questoes_proveniencia_global
    check (prova_id is null or usuario_id is null);

create unique index questoes_prova_numero_key
  on public.questoes (prova_id, numero_original)
  where prova_id is not null;
