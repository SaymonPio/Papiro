-- Modo Papiro por unidades pedagógicas — fundação.
--
-- Problema real: hoje public.questoes só carrega materia_id/assunto_id.
-- Todas as 5 unidades pedagógicas da Lei Maria da Penha (curso_conteudos.id
-- = 53) compartilham o MESMO assunto_id — não há como public.
-- ids_questoes_para_usuario (funcoes_curso_ativo.sql) distinguir "questão da
-- Unidade 1" de "questão da Unidade 3". Esta migration cria a associação
-- questão <-> unidade pedagógica que faltava, SEM duplicar a questão
-- original e SEM inferir a classificação por texto/regex (risco real de
-- classificar errado uma questão jurídica) — a classificação é sempre um
-- ato humano (admin), via as RPCs no final deste arquivo.
--
-- Auditoria feita antes de escrever este arquivo (sem alterar nada):
--   - public.questoes: id, ativa, materia_id, assunto_id, usuario_id,
--     enunciado, banca, concurso, ano, dificuldade, explicacao, criado_em —
--     nenhuma coluna de artigo/dispositivo, nenhum vínculo com
--     curso_conteudos ou unidades_pedagogicas.
--   - public.curso_questoes: questao_id, curso_id, prioridade — escopo por
--     CURSO, não por conteúdo/unidade.
--   - public.unidades_pedagogicas (unidades_pedagogicas.sql): id uuid PK,
--     curso_conteudo_id -> curso_conteudos, titulo, ordem, escopo,
--     artigos_esperados, ativa, UNIQUE(curso_conteudo_id, ordem),
--     UNIQUE(id, curso_conteudo_id) — já usada para compor a FK composta
--     de aulas.unidade_pedagogica_id.
--   - public.respostas_usuarios: id, usuario_id, questao_id,
--     alternativa_id, sessao_id, acertou, tempo_segundos, respondida_em —
--     é a fonte real de "questão já vista/errada/há quanto tempo", usada
--     pelo algoritmo de seleção em missao_pratica_papiro_rpc.sql.
--
-- Esta migration é aditiva: nenhuma tabela existente é alterada em
-- comportamento, só ganham colunas novas opcionais (nullable) e uma tabela
-- nova. Nenhum dado de questao_unidades_pedagogicas é inserido aqui.
--
-- CREATE TABLE/CREATE FUNCTION sem IF NOT EXISTS/OR REPLACE, de propósito:
-- são objetos novos. Se já existir algo com esse nome, a migration deve
-- FALHAR em vez de prosseguir silenciosamente. Nenhuma migration histórica
-- é editada.
--
-- Envolvido em BEGIN/COMMIT — ou tudo aplica, ou nada aplica.

BEGIN;

-- ============================================================================
-- 1) questao_unidades_pedagogicas — associação N:N, uma questão pode
-- pertencer a mais de uma unidade (ex.: uma questão que atravessa dois
-- recortes), uma unidade tem várias questões. Nunca duplica a questão.
-- ============================================================================

create table public.questao_unidades_pedagogicas (
  questao_id bigint not null
    references public.questoes(id) on delete cascade,
  unidade_pedagogica_id uuid not null
    references public.unidades_pedagogicas(id) on delete cascade,
  classificado_por uuid null
    references auth.users(id) on delete set null,
  criado_em timestamptz not null default now(),
  primary key (questao_id, unidade_pedagogica_id)
);

create index questao_unidades_pedagogicas_unidade_idx
  on public.questao_unidades_pedagogicas (unidade_pedagogica_id);

-- Integridade "respeite curso/conteúdo/assunto": uma questão só pode ser
-- vinculada a uma unidade se pertencer à MESMA matéria do conteúdo dessa
-- unidade e, quando a questão tiver assunto_id definido, ao MESMO assunto
-- do conteúdo. Trigger (não CHECK) porque exige lookup cross-tabela, mesmo
-- princípio já usado em validar_assunto_da_curso_materia
-- (base_programatica_curso.sql) e validar_curso_do_progresso_conteudo.
create function public.validar_questao_unidade_pedagogica()
returns trigger
language plpgsql
security definer
set search_path to ''
as $$
declare
  v_materia_unidade bigint;
  v_assunto_unidade bigint;
  v_materia_questao bigint;
  v_assunto_questao bigint;
begin
  select cm.materia_id, cc.assunto_id
  into v_materia_unidade, v_assunto_unidade
  from public.unidades_pedagogicas u
  join public.curso_conteudos cc on cc.id = u.curso_conteudo_id
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where u.id = new.unidade_pedagogica_id;

  if v_materia_unidade is null then
    raise exception 'Unidade pedagogica % nao encontrada', new.unidade_pedagogica_id;
  end if;

  select q.materia_id, q.assunto_id
  into v_materia_questao, v_assunto_questao
  from public.questoes q
  where q.id = new.questao_id;

  if v_materia_questao is null then
    raise exception 'Questao % nao encontrada', new.questao_id;
  end if;

  if v_materia_questao <> v_materia_unidade then
    raise exception 'Questao % nao pertence a mesma materia do conteudo da unidade pedagogica %', new.questao_id, new.unidade_pedagogica_id;
  end if;

  if v_assunto_questao is not null and v_assunto_unidade is not null and v_assunto_questao <> v_assunto_unidade then
    raise exception 'Questao % pertence a um assunto diferente do conteudo da unidade pedagogica %', new.questao_id, new.unidade_pedagogica_id;
  end if;

  return new;
end;
$$;

create trigger questao_unidades_pedagogicas_valida
  before insert or update on public.questao_unidades_pedagogicas
  for each row execute function public.validar_questao_unidade_pedagogica();

revoke execute on function public.validar_questao_unidade_pedagogica()
  from public, anon, authenticated;

alter table public.questao_unidades_pedagogicas enable row level security;
revoke all on public.questao_unidades_pedagogicas from anon, authenticated;

-- ============================================================================
-- 2) missoes.progresso_questoes — espelha o mesmo princípio de
-- missoes.progresso_teoria (contrato versionado, calculado e gravado
-- exclusivamente pelas RPCs SECURITY DEFINER de
-- missao_pratica_papiro_rpc.sql): registra quais unidades já tiveram sua
-- prática de questões concluída e o estado da Missão Final.
--
-- Contrato V1:
--   {"schema_version":1,
--    "unidades_praticadas":[{"unidade_pedagogica_id":"uuid","sessao_id":"123"}],
--    "missao_final": {"sessao_id":"123"} | null}
--
-- Aditivo: coluna nova, default '{}', não interfere em progresso_teoria nem
-- em nenhum outro campo de public.missoes.
-- ============================================================================

alter table public.missoes
  add column progresso_questoes jsonb not null default '{}'::jsonb
    check (jsonb_typeof(progresso_questoes) = 'object');

-- ============================================================================
-- 3) sessoes_estudo — identidade de sessão além de missao_id.
--
-- missao_questoes_rpc.sql/missao_refazer_rpc.sql já removeram o único
-- índice único que existia sobre missao_id (sessoes_estudo_missao_unica_idx)
-- para viabilizar "refazer" — este projeto já assumiu, antes desta
-- migration, que uma missão pode ter mais de uma sessão ao longo do tempo.
-- Esta migration só formaliza QUAL sessão é qual: unidade_pedagogica_id
-- (prática de uma unidade específica) ou tipo_pratica='missao_final'
-- (prática final, sem unidade única). Sessões antigas/livres/personalizadas
-- continuam com os dois campos NULL — nenhum dado existente muda de
-- significado.
--
-- Nenhum índice ÚNICO é criado sobre (missao_id, unidade_pedagogica_id) nem
-- sobre (missao_id) where tipo_pratica='missao_final' — de propósito: assim
-- como o flat flow, "refazer" precisa permitir mais de uma sessão para a
-- MESMA unidade/missão final ao longo do tempo. A idempotência real (não
-- criar uma segunda sessão em andamento para a mesma unidade) é
-- responsabilidade das RPCs (mesmo padrão de iniciar_questoes_da_missao/
-- missao_refazer_rpc.sql: busca a sessão mais recente com FOR UPDATE antes
-- de decidir se cria uma nova).
-- ============================================================================

alter table public.sessoes_estudo
  add column unidade_pedagogica_id uuid null
    references public.unidades_pedagogicas(id) on delete set null,
  add column tipo_pratica text null
    check (tipo_pratica in ('unidade', 'missao_final'));

alter table public.sessoes_estudo
  add constraint sessoes_estudo_tipo_pratica_coerente
  check (
    (tipo_pratica = 'unidade' and unidade_pedagogica_id is not null)
    or (tipo_pratica = 'missao_final' and unidade_pedagogica_id is null)
    or (tipo_pratica is null and unidade_pedagogica_id is null)
  );

create index sessoes_estudo_missao_unidade_idx
  on public.sessoes_estudo (missao_id, unidade_pedagogica_id);

create index sessoes_estudo_missao_tipo_idx
  on public.sessoes_estudo (missao_id, tipo_pratica);

-- ============================================================================
-- 4) Curadoria administrativa — classificação é SEMPRE um ato humano
-- (eh_admin()). Nenhuma RPC aqui infere unidade por nome/regex/texto do
-- enunciado. listar_questoes_nao_classificadas_admin devolve os metadados
-- reais (enunciado, banca, concurso, ano) para o admin decidir; nada é
-- gravado até uma chamada explícita de classificar_questao_unidade_admin.
-- ============================================================================

create function public.classificar_questao_unidade_admin(
  p_questao_id bigint,
  p_unidade_pedagogica_id uuid
)
returns void
language plpgsql
security definer
set search_path to ''
as $$
begin
  if not public.eh_admin() then
    raise exception 'Apenas administradores podem classificar questoes por unidade pedagogica';
  end if;

  insert into public.questao_unidades_pedagogicas (questao_id, unidade_pedagogica_id, classificado_por)
  values (p_questao_id, p_unidade_pedagogica_id, auth.uid())
  on conflict (questao_id, unidade_pedagogica_id) do nothing;
end;
$$;

revoke execute on function public.classificar_questao_unidade_admin(bigint, uuid) from public, anon;
grant execute on function public.classificar_questao_unidade_admin(bigint, uuid) to authenticated;

create function public.remover_classificacao_questao_unidade_admin(
  p_questao_id bigint,
  p_unidade_pedagogica_id uuid
)
returns void
language plpgsql
security definer
set search_path to ''
as $$
begin
  if not public.eh_admin() then
    raise exception 'Apenas administradores podem remover classificacao de questoes';
  end if;

  delete from public.questao_unidades_pedagogicas
  where questao_id = p_questao_id
    and unidade_pedagogica_id = p_unidade_pedagogica_id;
end;
$$;

revoke execute on function public.remover_classificacao_questao_unidade_admin(bigint, uuid) from public, anon;
grant execute on function public.remover_classificacao_questao_unidade_admin(bigint, uuid) to authenticated;

create function public.listar_questoes_unidade_admin(p_unidade_pedagogica_id uuid)
returns table (
  questao_id bigint,
  enunciado text,
  banca text,
  concurso text,
  ano integer
)
language plpgsql
security definer
set search_path to ''
as $$
begin
  if not public.eh_admin() then
    raise exception 'Apenas administradores podem listar questoes de uma unidade pedagogica';
  end if;

  return query
  select q.id, q.enunciado, q.banca, q.concurso, q.ano
  from public.questoes q
  join public.questao_unidades_pedagogicas qup on qup.questao_id = q.id
  where qup.unidade_pedagogica_id = p_unidade_pedagogica_id
  order by q.id;
end;
$$;

revoke execute on function public.listar_questoes_unidade_admin(uuid) from public, anon;
grant execute on function public.listar_questoes_unidade_admin(uuid) to authenticated;

-- Diagnóstico de curadoria: questões ATIVAS da mesma matéria (e do mesmo
-- assunto, quando o conteúdo tiver um assunto_id definido) do conteúdo
-- informado que AINDA não foram vinculadas a nenhuma unidade pedagógica
-- deste conteúdo. Só leitura — nunca classifica nada sozinha. É o ponto de
-- partida real da curadoria da Lei Maria da Penha (ver
-- supabase/diagnostico_questoes_lei_maria_penha.sql).
create function public.listar_questoes_nao_classificadas_admin(p_conteudo_id bigint)
returns table (
  questao_id bigint,
  enunciado text,
  banca text,
  concurso text,
  ano integer
)
language plpgsql
security definer
set search_path to ''
as $$
declare
  v_materia_id bigint;
  v_assunto_id bigint;
begin
  if not public.eh_admin() then
    raise exception 'Apenas administradores podem listar questoes pendentes de classificacao';
  end if;

  select cm.materia_id, cc.assunto_id
  into v_materia_id, v_assunto_id
  from public.curso_conteudos cc
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where cc.id = p_conteudo_id;

  if v_materia_id is null then
    raise exception 'Conteudo % nao encontrado', p_conteudo_id;
  end if;

  return query
  select q.id, q.enunciado, q.banca, q.concurso, q.ano
  from public.questoes q
  where q.ativa = true
    and q.materia_id = v_materia_id
    and (v_assunto_id is null or q.assunto_id = v_assunto_id)
    and not exists (
      select 1
      from public.questao_unidades_pedagogicas qup
      join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
      where qup.questao_id = q.id
        and u.curso_conteudo_id = p_conteudo_id
    )
  order by q.id;
end;
$$;

revoke execute on function public.listar_questoes_nao_classificadas_admin(bigint) from public, anon;
grant execute on function public.listar_questoes_nao_classificadas_admin(bigint) to authenticated;

COMMIT;
