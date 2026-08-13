-- Fase 2J-B — modelagem mínima e genérica de escopo por parte da Teoria
-- Interativa.
--
-- Problema real observado em runtime: leis extensas cadastradas em partes
-- (ex.: "Lei Maria da Penha — Parte 1" ... "Parte 5") vazavam conteúdo de
-- outras partes na geração por IA (recall citando medidas protetivas na
-- Parte 1, questão resolvida sobre art. 19 fora do escopo, etc.).
--
-- Auditoria feita ANTES desta migration (sem alterar nada, sem reabrir
-- nenhuma migration histórica): public.curso_conteudos
-- (base_programatica_curso.sql) tem só curso_materia_id, assunto_id,
-- ordem, frequencia_historica, prioridade_estrategica,
-- relevante_para_preparacao — NÃO existe hoje nenhuma relação estrutural
-- entre "partes" do mesmo conjunto pedagógico (sem parent_id/grupo_id/
-- conteudo_pai) nem nenhum campo de escopo textual, faixa de artigos
-- esperados ou descrição programática específica de uma parte.
--
-- Esta tabela preenche SÓ essa lacuna, de forma mínima e genérica — não
-- amarrada a nenhuma lei/matéria específica, e opcional (um
-- curso_conteudo sem linha aqui simplesmente não tem metadado de escopo,
-- o que é um estado normal, não um erro):
--   - grupo_id: identifica quais curso_conteudos são partes do MESMO
--     conjunto pedagógico (ex.: as 5 partes da Lei Maria da Penha
--     compartilhariam o mesmo grupo_id). uuid livre, sem significado
--     próprio além de agrupar — a relação entre partes vem SOMENTE deste
--     campo, nunca inferida por nome/substring/regex.
--   - parte_ordem: ordem da parte dentro do grupo (1, 2, 3...). Opcional
--     (NULL permitido) para não forçar ordenação em conjuntos onde ela
--     não fizer sentido.
--   - escopo: descrição textual do que essa parte especificamente
--     autoriza ensinar — usada pelo prompt-mestre da Edge Function
--     gerar-aula para delimitar a geração.
--   - artigos_esperados: dispositivos normalmente pertencentes a esta
--     parte, usados pela auditoria NÃO BLOQUEANTE de escopo (Edge
--     Function gerar-aula). NULL tem significado próprio: "não há
--     metadado suficiente para executar auditoria automática" — NUNCA
--     convertido para array vazio automaticamente (um array vazio
--     afirmaria "nenhum artigo é esperado", o que é uma informação
--     diferente de "não sabemos").
--
-- Esta migration é puramente aditiva e NÃO popula nenhuma linha: nenhum
-- INSERT baseado em nome/LIKE/substring/regex, nenhum hardcode de lei
-- específica. Descobrir e cadastrar os curso_conteudo_id reais de cada
-- grupo é uma decisão humana, feita depois, com uma query READ-ONLY
-- separada (ver comentário no fim deste arquivo) — nunca automática.
--
-- Esta tabela NÃO é lida/escrita pelo aluno em nenhuma hipótese: leitura
-- privilegiada só via service_role na Edge Function gerar-aula. Qualquer
-- manutenção administrativa futura (cadastrar/editar escopos) exigiria
-- uma RPC SECURITY DEFINER dedicada — fora do escopo desta migration.
--
-- CREATE TABLE sem IF NOT EXISTS, de propósito: esta tabela é nova e não
-- existe hoje. Se já existir algo com esse nome, a migration deve FALHAR
-- em vez de prosseguir silenciosamente. Sem DROP TABLE. Nenhuma migration
-- histórica é editada.
--
-- Envolvido em BEGIN/COMMIT — ou tudo aplica, ou nada aplica.

BEGIN;

create table public.teoria_escopos_conteudo (
  -- Um curso_conteudo tem NO MÁXIMO um escopo cadastrado (relação 1:1) —
  -- por isso a própria FK é a chave primária, não uma coluna id separada.
  curso_conteudo_id bigint primary key
    references public.curso_conteudos(id) on delete cascade,

  grupo_id uuid not null,

  parte_ordem smallint null
    check (parte_ordem is null or parte_ordem > 0),

  escopo text not null,

  artigos_esperados text[] null,

  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

-- Descobrir todas as partes irmãs de um grupo (Edge Function gerar-aula)
-- sem depender de nenhuma inferência por nome.
create index teoria_escopos_conteudo_grupo_id_idx
  on public.teoria_escopos_conteudo (grupo_id);

-- Dentro do MESMO grupo, cada posição (parte_ordem) só pode existir uma
-- vez — mas grupos diferentes são independentes entre si (podem repetir o
-- mesmo parte_ordem sem conflito nenhum). Parcial: parte_ordem NULL nunca
-- entra nesse conflito (várias partes do mesmo grupo podem deixar
-- parte_ordem em branco sem colidir).
create unique index teoria_escopos_conteudo_grupo_parte_idx
  on public.teoria_escopos_conteudo (grupo_id, parte_ordem)
  where parte_ordem is not null;

-- ============================================================================
-- atualizado_em — trigger dedicada, mesmo padrão de
-- marcar_atualizacao_missao (missoes.sql) / configuracoes_estudo_marca_
-- atualizacao (configuracoes_estudo.sql): cada tabela deste projeto que
-- precisa desse comportamento tem sua própria função (não existe um
-- helper genérico compartilhado hoje).
-- ============================================================================
-- CREATE FUNCTION sem OR REPLACE, de propósito: esta função é nova e não
-- existe hoje. Se já existir algo com esse nome, a migration deve FALHAR
-- em vez de substituir silenciosamente uma função desconhecida.
create function public.marcar_atualizacao_teoria_escopos_conteudo()
returns trigger
language plpgsql
as $$
begin
  new.atualizado_em = now();
  return new;
end;
$$;

drop trigger if exists teoria_escopos_conteudo_marca_atualizacao on public.teoria_escopos_conteudo;
create trigger teoria_escopos_conteudo_marca_atualizacao
  before update on public.teoria_escopos_conteudo
  for each row
  execute function public.marcar_atualizacao_teoria_escopos_conteudo();

-- Detalhe interno do trigger, não é uma RPC pública — revoga a exposição
-- padrão de EXECUTE só depois de criar o trigger (CREATE TRIGGER exige
-- EXECUTE na função no momento da criação).
revoke execute on function public.marcar_atualizacao_teoria_escopos_conteudo()
  from public, anon, authenticated;

-- RLS ativo, ZERO acesso direto para anon/authenticated — mesmo princípio
-- de fechamento total já usado em aula_geracoes/as 5 tabelas da Fase 2E:
-- leitura só pela Edge Function (service_role, ignora RLS). Nenhuma
-- policy é criada para nenhum role — manutenção administrativa futura
-- (cadastrar/editar escopos) precisa de uma RPC SECURITY DEFINER
-- dedicada, não criada nesta migration.
alter table public.teoria_escopos_conteudo enable row level security;
revoke all on public.teoria_escopos_conteudo from anon, authenticated;

COMMIT;

-- ============================================================================
-- Query READ-ONLY sugerida para descobrir os curso_conteudo_id reais das
-- partes de uma norma específica (ex.: Lei Maria da Penha), para decisão
-- HUMANA de quais grupo_id/parte_ordem/escopo cadastrar depois — NUNCA
-- executada automaticamente por esta migration, e NUNCA usada para gerar
-- um INSERT automático:
--
--   select cc.id as curso_conteudo_id, cc.curso_materia_id, cc.ordem,
--          a.nome as assunto_nome, cm.nome as materia_nome
--   from public.curso_conteudos cc
--   join public.assuntos a on a.id = cc.assunto_id
--   join public.curso_materias cm on cm.id = cc.curso_materia_id
--   where a.nome ilike '%Maria da Penha%'
--   order by cc.curso_materia_id, cc.ordem;
-- ============================================================================
