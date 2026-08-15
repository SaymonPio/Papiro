-- ============================================================================
-- TESTE RUNTIME DO MODO PAPIRO POR UNIDADES PEDAGÓGICAS — TRANSACIONAL,
-- TUDO DESFEITO NO FINAL
-- ============================================================================
--
-- Cobre as duas migrations novas do Modo Papiro:
--   - supabase/questao_unidades_pedagogicas.sql
--   - supabase/missao_pratica_papiro_rpc.sql
--
-- Este arquivo é SEPARADO das migrations reais (que continuam terminando em
-- COMMIT). Colar no SQL Editor do Supabase, rodar de uma vez, ler o
-- resultado, nunca persistir nada — termina em ROLLBACK.
--
-- Precisa de pelo menos: 1 matrícula ATIVA real (para achar curso/usuário
-- de teste) e o curso_conteudos real ligado a essa matrícula que já tenha a
-- "unidade padrão" (ordem 1, criada por unidades_pedagogicas.sql para todo
-- conteúdo existente). Se não houver, aborta ANTES de qualquer teste (fora
-- de bloco de exceção, mesmo princípio dos harnesses anteriores).
--
-- Fixtures criadas SÓ dentro desta transação (nunca tocam dado real):
--   - 2 unidades pedagógicas extras no MESMO conteúdo real (ordem 90/91,
--     tituladas "[TESTE PAPIRO] ..."), cada uma com sua própria aula/
--     aula_versao publicada (sem isso violaria UNIQUE(unidade_pedagogica_
--     id) de public.aulas se reaproveitássemos a unidade padrão real).
--   - 36 questões fixture (16 por unidade + 4 na sessão histórica), com
--     alternativas, vinculadas via curso_questoes ao curso real e
--     classificadas nas 2 unidades fixture via questao_unidades_pedagogicas:
--       * Unidade A: 14 inéditas ("volume", cobre "exatamente 10 quando
--         há banco suficiente" via iniciar_pratica_unidade de verdade) +
--         1 respondida ERRADA + 1 respondida CERTA no MESMO instante da
--         errada (par comparável — a única variável que difere entre as
--         duas é o acerto, cobrindo "erro anterior aumenta prioridade"
--         com uma comparação real, não apenas 1 candidata sobrando).
--       * Unidade B: 14 inéditas ("volume" — somada às de A, garante >= 30
--         candidatas reais para "Missão Final possui exatamente 30") + 1
--         respondida CERTA há muito tempo + 1 respondida CERTA
--         recentemente (par para o teste de recência).
--   - Histórico controlado de respostas do usuário de teste (1 sessão
--     fixture concluída, 4 respostas), para testar deterministicamente a
--     prioridade: inédita vs. vista, errada vs. certa (mesmo instante),
--     vista antiga vs. vista recente.
--   - 1 missão fixture (matricula real + o conteúdo real + data de hoje),
--     com progresso_teoria/progresso_questoes montados manualmente para
--     simular cada estágio do fluxo sem depender de gerar aulas de verdade.
--   - 1 unidade "Janela" isolada (ordem 92, ativa=false — nunca conta para
--     v_total_unidades) com 5 questões dedicadas aos 3 tiers de prioridade
--     (nunca respondida / vista fora da janela de repetição / repetição
--     especialmente recente, inclusive por vínculo com a missão atual).
--
-- Isolamento de dados reais (BLOCO 1B/2B): qualquer unidade_pedagogica que
-- já existisse para o conteúdo real escolhido é marcada ativa=false só
-- dentro desta transação, e uma asserção explícita confirma que
-- v_total_unidades = 2 (só A e B) antes de rodar os testes de Missão
-- Final — sem isso, os testes ficariam reféns do estado real do banco
-- (ex.: se o conteúdo escolhido já tivesse unidades reais publicadas).
--
-- Corpo das migrations reais é aplicado ANTES das fixtures (idêntico aos
-- arquivos, sem os COMMIT finais).

BEGIN;

do $$
begin
  if not exists (select 1 from public.matriculas where status = 'ativa') then
    raise exception 'Teste abortado: nenhuma matricula ativa real encontrada.';
  end if;
end $$;

-- ============================================================================
-- CORPO DE supabase/questao_unidades_pedagogicas.sql (sem o COMMIT final)
-- ============================================================================

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

-- ============================================================================
-- CORPO DE supabase/missao_pratica_papiro_rpc.sql (sem o COMMIT final)
-- ============================================================================

-- ============================================================================
-- 1) Algoritmo de seleção — 3 TIERS de prioridade (mais forte que "erro
-- vence sempre"), pensados para nunca deixar uma resposta errada de
-- segundos atrás furar a frente de uma questão vista há muito tempo:
--
--   TIER A — nunca respondida pelo usuário. Sempre primeiro.
--   TIER B — já respondida, mas FORA da janela de repetição imediata
--            (v_janela_repeticao, MVP = 24h) e não usada nas práticas de
--            unidade da MISSÃO ATUAL (quando p_missao_id é informado).
--            Dentro deste tier: erro/dificuldade primeiro
--            (bool_or acertou=false — mesmo proxy já usado antes; ver nota
--            abaixo), depois a mais antiga (max(respondida_em) asc).
--   TIER C — repetição "especialmente recente": dentro da janela de 24h OU
--            usada em alguma prática de unidade da MISSÃO ATUAL (mesmo que
--            fora da janela de tempo — ex.: aluno pratica as unidades em
--            dias diferentes e só faz a Missão Final dias depois; sem o
--            sinal por missão, o simples corte por tempo deixaria essa
--            questão voltar cedo demais na Missão Final). Só entra quando
--            os Tiers A/B não bastam para completar p_quantidade.
--
-- "erro/dificuldade" (regra 3 original) permanece um proxy por ja_errou —
-- não pela coluna literal questoes.dificuldade (facil/media/dificil, sem
-- ordem numérica natural) — mesma leitura já usada no comentário anterior
-- deste arquivo; a coluna dificuldade não entra na ordenação.
--
-- p_missao_id (novo, opcional — default null preserva qualquer chamada
-- existente) identifica "usada nas práticas de unidade da missão atual":
-- junta respostas_usuarios -> sessoes_estudo com sessoes_estudo.missao_id =
-- p_missao_id e tipo_pratica = 'unidade'. É o sinal usado por
-- iniciar_missao_final para evitar repetir, na Missão Final, questões que
-- o próprio aluno acabou de praticar nas unidades desta mesma missão —
-- reutiliza a questão só se o banco não oferecer alternativa suficiente
-- (Tier C, nunca uma exclusão permanente).
--
-- cq.prioridade (curso_questoes, já usada por ids_questoes_para_usuario)
-- entra só como ÚLTIMO desempate, depois de todas as regras pedidas —
-- preserva a curadoria de prioridade existente sem nunca sobrepor as regras
-- novas. random() é o desempate final, evita a mesma ordem sempre que os
-- critérios anteriores empatam de verdade.
--
-- REVOKE de todos os roles: helper interno, só chamado de dentro de outra
-- função SECURITY DEFINER deste mesmo arquivo (mesmo princípio já usado
-- pelas funções de trigger marcar_atualizacao_* deste projeto — revogar
-- EXECUTE não impede a chamada interna, porque quem executa nesse momento é
-- o DEFINER da função chamadora, não o cliente).
-- ============================================================================

create function public.selecionar_candidatas_unidade_pedagogica(
  p_usuario_id uuid,
  p_unidade_pedagogica_id uuid,
  p_curso_id uuid,
  p_quantidade integer,
  p_excluir bigint[],
  p_missao_id uuid default null
)
returns table (questao_id bigint)
language plpgsql
stable
security definer
set search_path to ''
as $function$
declare
  v_janela_repeticao constant interval := interval '24 hours';
begin
  return query
  select q.id
  from public.questoes q
  join public.questao_unidades_pedagogicas qup
    on qup.questao_id = q.id
   and qup.unidade_pedagogica_id = p_unidade_pedagogica_id
  join public.curso_questoes cq
    on cq.questao_id = q.id
   and cq.curso_id = p_curso_id
  left join lateral (
    select
      count(*) as vezes_respondida,
      bool_or(not ru.acertou) as ja_errou,
      max(ru.respondida_em) as ultima_vez
    from public.respostas_usuarios ru
    where ru.questao_id = q.id
      and ru.usuario_id = p_usuario_id
  ) hist on true
  left join lateral (
    select true as usada_na_missao_atual
    from public.respostas_usuarios ru
    join public.sessoes_estudo s on s.id = ru.sessao_id
    where ru.questao_id = q.id
      and ru.usuario_id = p_usuario_id
      and p_missao_id is not null
      and s.missao_id = p_missao_id
      and s.tipo_pratica = 'unidade'
    limit 1
  ) miss on true
  where q.ativa = true
    and not (q.id = any(coalesce(p_excluir, '{}'::bigint[])))
  order by
    -- Tier A: nunca respondida.
    (coalesce(hist.vezes_respondida, 0) = 0) desc,
    -- Separa Tier B (visto, fora da janela/missao atual) de Tier C (visto,
    -- repeticao especialmente recente) — Tier C só entra depois que A e B
    -- se esgotam, nunca antes.
    (
      coalesce(hist.vezes_respondida, 0) > 0
      and (
        coalesce(hist.ultima_vez, '-infinity'::timestamptz) >= now() - v_janela_repeticao
        or coalesce(miss.usada_na_missao_atual, false)
      )
    ) asc,
    -- Dentro do Tier B, erro/dificuldade primeiro, depois a mais antiga.
    coalesce(hist.ja_errou, false) desc,
    coalesce(hist.ultima_vez, '-infinity'::timestamptz) asc,
    cq.prioridade asc,
    random()
  limit greatest(0, p_quantidade);
end;
$function$;

revoke execute on function public.selecionar_candidatas_unidade_pedagogica(uuid, uuid, uuid, integer, bigint[], uuid)
  from public, anon, authenticated;

-- Mesmo algoritmo (mesmos 3 tiers), mas somando TODAS as unidades ativas/
-- publicadas de um conteúdo — usado só como preenchimento da Missão Final
-- quando alguma unidade isolada não tem banco suficiente para completar as
-- 30 (ver iniciar_missao_final). group by desduplica questões vinculadas a
-- mais de uma unidade do mesmo conteúdo.
create function public.selecionar_candidatas_conteudo(
  p_usuario_id uuid,
  p_conteudo_id bigint,
  p_curso_id uuid,
  p_quantidade integer,
  p_excluir bigint[],
  p_missao_id uuid default null
)
returns table (questao_id bigint)
language plpgsql
stable
security definer
set search_path to ''
as $function$
declare
  v_janela_repeticao constant interval := interval '24 hours';
begin
  return query
  select q.id
  from public.questoes q
  join public.questao_unidades_pedagogicas qup on qup.questao_id = q.id
  join public.unidades_pedagogicas u
    on u.id = qup.unidade_pedagogica_id
   and u.curso_conteudo_id = p_conteudo_id
   and u.ativa = true
  join public.curso_questoes cq
    on cq.questao_id = q.id
   and cq.curso_id = p_curso_id
  left join lateral (
    select
      count(*) as vezes_respondida,
      bool_or(not ru.acertou) as ja_errou,
      max(ru.respondida_em) as ultima_vez
    from public.respostas_usuarios ru
    where ru.questao_id = q.id
      and ru.usuario_id = p_usuario_id
  ) hist on true
  left join lateral (
    select true as usada_na_missao_atual
    from public.respostas_usuarios ru
    join public.sessoes_estudo s on s.id = ru.sessao_id
    where ru.questao_id = q.id
      and ru.usuario_id = p_usuario_id
      and p_missao_id is not null
      and s.missao_id = p_missao_id
      and s.tipo_pratica = 'unidade'
    limit 1
  ) miss on true
  where q.ativa = true
    and not (q.id = any(coalesce(p_excluir, '{}'::bigint[])))
  group by q.id, cq.prioridade, hist.vezes_respondida, hist.ja_errou, hist.ultima_vez, miss.usada_na_missao_atual
  order by
    (coalesce(hist.vezes_respondida, 0) = 0) desc,
    (
      coalesce(hist.vezes_respondida, 0) > 0
      and (
        coalesce(hist.ultima_vez, '-infinity'::timestamptz) >= now() - v_janela_repeticao
        or coalesce(miss.usada_na_missao_atual, false)
      )
    ) asc,
    coalesce(hist.ja_errou, false) desc,
    coalesce(hist.ultima_vez, '-infinity'::timestamptz) asc,
    cq.prioridade asc,
    random()
  limit greatest(0, p_quantidade);
end;
$function$;

revoke execute on function public.selecionar_candidatas_conteudo(uuid, bigint, uuid, integer, bigint[], uuid)
  from public, anon, authenticated;

-- ============================================================================
-- 2) iniciar_pratica_unidade — 10 questões exclusivas de UMA unidade.
--
-- Libera assim que a TEORIA DESSA UNIDADE (não das demais) estiver
-- concluída (progresso_teoria V2, já gravado por
-- registrar_unidade_teoria_concluida) — não exige nenhuma outra unidade,
-- exatamente como pedido ("a prática deve acontecer logo após cada
-- unidade").
-- ============================================================================

create function public.iniciar_pratica_unidade(
  p_missao_id uuid,
  p_unidade_pedagogica_id uuid,
  p_refazer boolean default false
)
returns table (
  sessao_id bigint,
  sessao_status text,
  unidade_pedagogica_id uuid,
  questao_ids bigint[],
  recuperada boolean
)
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_quantidade constant integer := 10;
  v_usuario_id uuid := auth.uid();
  v_matricula_id uuid;
  v_conteudo_id bigint;
  v_curso_id uuid;
  v_status_missao text;
  v_progresso_teoria jsonb;
  v_data_missao date;
  v_sessao_id bigint;
  v_sessao_status text;
  v_ids bigint[];
  v_unidade_ok boolean;
  v_teoria_unidade_ok boolean;
begin
  if v_usuario_id is null then
    raise exception 'Usuario nao autenticado';
  end if;

  select ms.matricula_id, ms.conteudo_id, ms.status, ms.progresso_teoria, ms.data_missao, m.curso_id
  into v_matricula_id, v_conteudo_id, v_status_missao, v_progresso_teoria, v_data_missao, v_curso_id
  from public.missoes ms
  join public.matriculas m on m.id = ms.matricula_id
  where ms.id = p_missao_id
    and m.usuario_id = v_usuario_id
    and m.status = 'ativa'
  for update of ms;

  if v_matricula_id is null then
    raise exception 'Missao nao encontrada, nao pertence ao usuario, ou a matricula nao esta ativa';
  end if;
  if v_status_missao = 'abandonada' then
    raise exception 'Missao abandonada';
  end if;
  if p_refazer and v_status_missao <> 'concluida' then
    raise exception 'A missao precisa estar concluida antes de ser refeita';
  end if;

  -- Unidade precisa pertencer a ESTE conteudo, estar ativa, e ter aula
  -- publicada — mesmo critério de escopo já usado em
  -- registrar_unidade_teoria_concluida (unidades_pedagogicas_progresso_
  -- rpc.sql). Nenhum dado sobre a unidade vem do cliente além do id.
  select true
  into v_unidade_ok
  from public.unidades_pedagogicas u
  join public.aulas a on a.unidade_pedagogica_id = u.id and a.ativa = true
  join public.aula_versoes av on av.aula_id = a.id and av.status = 'publicada'
  where u.id = p_unidade_pedagogica_id
    and u.curso_conteudo_id = v_conteudo_id
    and u.ativa = true;

  if v_unidade_ok is null then
    raise exception 'Unidade pedagogica nao encontrada ou sem aula publicada para o conteudo desta missao';
  end if;

  -- Idempotência: recupera a sessão desta unidade dentro desta missão. Sem
  -- índice único (ver questao_unidades_pedagogicas.sql) — "not p_refazer"
  -- recupera qualquer tentativa anterior; refazendo, só a que ainda está em
  -- andamento (mesmo padrão de iniciar_questoes_da_missao/missao_refazer_
  -- rpc.sql).
  select s.id, s.status
  into v_sessao_id, v_sessao_status
  from public.sessoes_estudo s
  where s.missao_id = p_missao_id
    and s.unidade_pedagogica_id = p_unidade_pedagogica_id
    and (not p_refazer or s.status = 'em_andamento')
  order by s.id desc
  limit 1
  for update;

  if v_sessao_id is not null then
    select array_agg(sq.questao_id order by sq.ordem)
    into v_ids
    from public.sessao_questoes_planejadas sq
    where sq.sessao_id = v_sessao_id;

    if coalesce(cardinality(v_ids), 0) = 0 then
      raise exception 'Sessao desta unidade sem lista de questoes planejadas';
    end if;

    return query select v_sessao_id, v_sessao_status, p_unidade_pedagogica_id, v_ids, true;
    return;
  end if;

  -- Primeira tentativa exige a teoria DESTA unidade concluída. Refazer
  -- parte de uma missão já concluída (logo, já cumpriu isso antes).
  if not p_refazer then
    select
      jsonb_typeof(v_progresso_teoria) = 'object'
      and (v_progresso_teoria -> 'schema_version') = to_jsonb(2::int)
      and exists (
        select 1
        from jsonb_array_elements(coalesce(v_progresso_teoria -> 'unidades_concluidas', '[]'::jsonb)) item
        where item ->> 'unidade_pedagogica_id' = p_unidade_pedagogica_id::text
      )
    into v_teoria_unidade_ok;

    if not coalesce(v_teoria_unidade_ok, false) then
      raise exception 'Conclua a teoria desta unidade antes de iniciar as questoes';
    end if;
  end if;

  -- Seleção AUTORITATIVA no servidor — nenhum id de questão vem do cliente.
  -- p_missao_id vai junto para o Tier C reconhecer "usada nas práticas de
  -- unidade desta mesma missão" (relevante sobretudo se esta unidade for
  -- refeita depois de outra unidade já ter reutilizado a mesma questão).
  select array_agg(x.questao_id)
  into v_ids
  from public.selecionar_candidatas_unidade_pedagogica(
    v_usuario_id, p_unidade_pedagogica_id, v_curso_id, v_quantidade, '{}'::bigint[], p_missao_id
  ) x(questao_id);

  if coalesce(cardinality(v_ids), 0) = 0 then
    raise exception 'Nao ha questoes cadastradas para esta unidade pedagogica ainda';
  end if;

  insert into public.sessoes_estudo (
    usuario_id, matricula_id, missao_id, unidade_pedagogica_id, tipo_pratica,
    data_sessao, nivel_meta, status, inicio_em, minutos_revisao, questoes_planejadas
  ) values (
    v_usuario_id, v_matricula_id, p_missao_id, p_unidade_pedagogica_id, 'unidade',
    v_data_missao, 'personalizada', 'em_andamento', now(), 0, cardinality(v_ids)
  ) returning id, status into v_sessao_id, v_sessao_status;

  insert into public.sessao_questoes_planejadas (sessao_id, questao_id, ordem)
  select v_sessao_id, x.questao_id, x.ordem::integer
  from unnest(v_ids) with ordinality x(questao_id, ordem);

  if v_status_missao = 'iniciada' then
    update public.missoes
    set status = 'questoes_iniciadas', questoes_iniciadas_em = coalesce(questoes_iniciadas_em, now())
    where id = p_missao_id;
  end if;

  return query select v_sessao_id, v_sessao_status, p_unidade_pedagogica_id, v_ids, false;
end;
$function$;

revoke execute on function public.iniciar_pratica_unidade(uuid, uuid, boolean) from public, anon;
grant execute on function public.iniciar_pratica_unidade(uuid, uuid, boolean) to authenticated;

-- ============================================================================
-- 3) concluir_pratica_unidade — fecha a sessão de UMA unidade e marca essa
-- unidade como praticada em missoes.progresso_questoes. NUNCA marca a
-- missão inteira como concluída — só a Missão Final faz isso.
-- ============================================================================

create function public.concluir_pratica_unidade(
  p_missao_id uuid,
  p_sessao_id bigint
)
returns table (
  missao_id uuid,
  unidade_pedagogica_id uuid,
  sessao_id bigint,
  sessao_status text,
  unidades_praticadas integer,
  total_unidades integer,
  missao_final_liberada boolean
)
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_usuario_id uuid := auth.uid();
  v_conteudo_id bigint;
  v_progresso_questoes jsonb;
  v_status_sessao text;
  v_unidade_id uuid;
  v_planejadas integer;
  v_respondidas integer;
  v_total_unidades integer;
begin
  if v_usuario_id is null then
    raise exception 'Usuario nao autenticado';
  end if;

  select ms.conteudo_id, ms.progresso_questoes
  into v_conteudo_id, v_progresso_questoes
  from public.missoes ms
  join public.matriculas m on m.id = ms.matricula_id
  where ms.id = p_missao_id
    and m.usuario_id = v_usuario_id
    and m.status = 'ativa'
  for update of ms;

  if v_conteudo_id is null then
    raise exception 'Missao indisponivel para este usuario';
  end if;

  select s.status, s.unidade_pedagogica_id
  into v_status_sessao, v_unidade_id
  from public.sessoes_estudo s
  where s.id = p_sessao_id
    and s.missao_id = p_missao_id
    and s.usuario_id = v_usuario_id
    and s.tipo_pratica = 'unidade'
  for update;

  if v_status_sessao is null or v_unidade_id is null then
    raise exception 'Sessao nao pertence a uma pratica de unidade desta missao';
  end if;

  if v_status_sessao <> 'concluida' then
    select count(*)::integer, count(ru.questao_id)::integer
    into v_planejadas, v_respondidas
    from public.sessao_questoes_planejadas sq
    left join public.respostas_usuarios ru
      on ru.sessao_id = sq.sessao_id and ru.questao_id = sq.questao_id
    where sq.sessao_id = p_sessao_id;

    if v_planejadas = 0 or v_respondidas <> v_planejadas then
      raise exception 'Responda todas as questoes planejadas antes de concluir esta unidade';
    end if;

    update public.sessoes_estudo
    set status = 'concluida', fim_em = coalesce(fim_em, now())
    where id = p_sessao_id;
    v_status_sessao := 'concluida';
  end if;

  if jsonb_typeof(v_progresso_questoes) <> 'object'
     or (v_progresso_questoes -> 'schema_version') is distinct from to_jsonb(1::int)
     or jsonb_typeof(v_progresso_questoes -> 'unidades_praticadas') <> 'array'
  then
    v_progresso_questoes := jsonb_build_object(
      'schema_version', 1,
      'unidades_praticadas', '[]'::jsonb,
      'missao_final', null
    );
  end if;

  if not exists (
    select 1
    from jsonb_array_elements(v_progresso_questoes -> 'unidades_praticadas') item
    where item ->> 'unidade_pedagogica_id' = v_unidade_id::text
  ) then
    v_progresso_questoes := jsonb_set(
      v_progresso_questoes,
      '{unidades_praticadas}',
      (v_progresso_questoes -> 'unidades_praticadas') || jsonb_build_array(
        jsonb_build_object('unidade_pedagogica_id', v_unidade_id::text, 'sessao_id', p_sessao_id::text)
      )
    );
  end if;

  update public.missoes
  set progresso_questoes = v_progresso_questoes
  where id = p_missao_id;

  select count(distinct u.id)::integer
  into v_total_unidades
  from public.unidades_pedagogicas u
  join public.aulas a on a.unidade_pedagogica_id = u.id and a.ativa = true
  join public.aula_versoes av on av.aula_id = a.id and av.status = 'publicada'
  where u.curso_conteudo_id = v_conteudo_id
    and u.ativa = true;

  return query
  select
    p_missao_id,
    v_unidade_id,
    p_sessao_id,
    v_status_sessao,
    jsonb_array_length(v_progresso_questoes -> 'unidades_praticadas'),
    v_total_unidades,
    (jsonb_array_length(v_progresso_questoes -> 'unidades_praticadas') >= v_total_unidades and v_total_unidades > 0);
end;
$function$;

revoke execute on function public.concluir_pratica_unidade(uuid, bigint) from public, anon;
grant execute on function public.concluir_pratica_unidade(uuid, bigint) to authenticated;

-- ============================================================================
-- 4) iniciar_missao_final — 30 questões, todas as unidades representadas
-- (não igualmente — "pode considerar quantidade de conteúdo, prioridade/
-- incidência e disponibilidade do banco"). Só libera depois de TODAS as
-- unidades ativas/publicadas terem teoria E prática concluídas.
-- ============================================================================

create function public.iniciar_missao_final(
  p_missao_id uuid,
  p_refazer boolean default false
)
returns table (
  sessao_id bigint,
  sessao_status text,
  missao_status text,
  questao_ids bigint[],
  recuperada boolean
)
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_quantidade constant integer := 30;
  v_usuario_id uuid := auth.uid();
  v_matricula_id uuid;
  v_conteudo_id bigint;
  v_curso_id uuid;
  v_status_missao text;
  v_progresso_teoria jsonb;
  v_progresso_questoes jsonb;
  v_data_missao date;
  v_sessao_id bigint;
  v_sessao_status text;
  v_ids bigint[] := '{}'::bigint[];
  v_extra bigint[];
  v_total_unidades integer;
  v_unidades_restantes integer;
  v_total_teoria_concluida integer;
  v_total_praticadas integer;
  v_restante integer;
  v_por_unidade integer;
  v_unidade record;
begin
  if v_usuario_id is null then
    raise exception 'Usuario nao autenticado';
  end if;

  select ms.matricula_id, ms.conteudo_id, ms.status, ms.progresso_teoria, ms.progresso_questoes, ms.data_missao, m.curso_id
  into v_matricula_id, v_conteudo_id, v_status_missao, v_progresso_teoria, v_progresso_questoes, v_data_missao, v_curso_id
  from public.missoes ms
  join public.matriculas m on m.id = ms.matricula_id
  where ms.id = p_missao_id
    and m.usuario_id = v_usuario_id
    and m.status = 'ativa'
  for update of ms;

  if v_matricula_id is null then
    raise exception 'Missao nao encontrada, nao pertence ao usuario, ou a matricula nao esta ativa';
  end if;
  if v_status_missao = 'abandonada' then
    raise exception 'Missao abandonada';
  end if;
  if p_refazer and v_status_missao <> 'concluida' then
    raise exception 'A missao precisa estar concluida antes de ser refeita';
  end if;

  select s.id, s.status
  into v_sessao_id, v_sessao_status
  from public.sessoes_estudo s
  where s.missao_id = p_missao_id
    and s.tipo_pratica = 'missao_final'
    and (not p_refazer or s.status = 'em_andamento')
  order by s.id desc
  limit 1
  for update;

  if v_sessao_id is not null then
    select array_agg(sq.questao_id order by sq.ordem)
    into v_ids
    from public.sessao_questoes_planejadas sq
    where sq.sessao_id = v_sessao_id;

    if coalesce(cardinality(v_ids), 0) = 0 then
      raise exception 'Sessao da Missao Final sem lista de questoes planejadas';
    end if;

    return query select v_sessao_id, v_sessao_status, v_status_missao, v_ids, true;
    return;
  end if;

  select count(distinct u.id)::integer
  into v_total_unidades
  from public.unidades_pedagogicas u
  join public.aulas a on a.unidade_pedagogica_id = u.id and a.ativa = true
  join public.aula_versoes av on av.aula_id = a.id and av.status = 'publicada'
  where u.curso_conteudo_id = v_conteudo_id
    and u.ativa = true;

  if v_total_unidades = 0 then
    raise exception 'Nenhuma unidade publicada para este conteudo';
  end if;

  if not p_refazer then
    select count(distinct item ->> 'unidade_pedagogica_id')::integer
    into v_total_teoria_concluida
    from jsonb_array_elements(coalesce(v_progresso_teoria -> 'unidades_concluidas', '[]'::jsonb)) item
    join public.unidades_pedagogicas u
      on item ->> 'unidade_pedagogica_id' = u.id::text
     and u.curso_conteudo_id = v_conteudo_id
     and u.ativa = true;

    select count(distinct item ->> 'unidade_pedagogica_id')::integer
    into v_total_praticadas
    from jsonb_array_elements(coalesce(v_progresso_questoes -> 'unidades_praticadas', '[]'::jsonb)) item
    join public.unidades_pedagogicas u
      on item ->> 'unidade_pedagogica_id' = u.id::text
     and u.curso_conteudo_id = v_conteudo_id
     and u.ativa = true;

    if coalesce(v_total_teoria_concluida, 0) <> v_total_unidades
       or coalesce(v_total_praticadas, 0) <> v_total_unidades
    then
      raise exception 'Conclua a teoria e a pratica de todas as unidades antes da Missao Final';
    end if;
  end if;

  -- Distribuição não igual: percorre as unidades tentando dividir o
  -- restante igualmente a cada passo (ceil sobre o que falta / unidades que
  -- ainda não foram visitadas) — uma unidade com menos questões cadastradas
  -- simplesmente contribui menos, sem travar a montagem da Missão Final.
  v_unidades_restantes := v_total_unidades;
  v_restante := v_quantidade;

  for v_unidade in
    select u.id as unidade_id
    from public.unidades_pedagogicas u
    join public.aulas a on a.unidade_pedagogica_id = u.id and a.ativa = true
    join public.aula_versoes av on av.aula_id = a.id and av.status = 'publicada'
    where u.curso_conteudo_id = v_conteudo_id
      and u.ativa = true
    order by u.ordem
  loop
    exit when v_restante <= 0;
    v_por_unidade := ceil(v_restante::numeric / greatest(1, v_unidades_restantes));

    select array_agg(x.questao_id)
    into v_extra
    from public.selecionar_candidatas_unidade_pedagogica(
      v_usuario_id, v_unidade.unidade_id, v_curso_id, v_por_unidade, v_ids, p_missao_id
    ) x(questao_id);

    if v_extra is not null then
      v_ids := v_ids || v_extra;
    end if;

    v_unidades_restantes := greatest(1, v_unidades_restantes - 1);
    v_restante := v_quantidade - coalesce(cardinality(v_ids), 0);
  end loop;

  -- Completa com repetição inteligente considerando TODAS as unidades do
  -- conteúdo juntas, caso alguma unidade isolada não tivesse banco
  -- suficiente para bater as 30. p_missao_id vai junto pelo mesmo motivo do
  -- laço acima.
  if coalesce(cardinality(v_ids), 0) < v_quantidade then
    select array_agg(x.questao_id)
    into v_extra
    from public.selecionar_candidatas_conteudo(
      v_usuario_id, v_conteudo_id, v_curso_id, v_quantidade - cardinality(v_ids), v_ids, p_missao_id
    ) x(questao_id);

    if v_extra is not null then
      v_ids := v_ids || v_extra;
    end if;
  end if;

  if coalesce(cardinality(v_ids), 0) = 0 then
    raise exception 'Nao ha questoes cadastradas para as unidades deste conteudo ainda';
  end if;

  insert into public.sessoes_estudo (
    usuario_id, matricula_id, missao_id, unidade_pedagogica_id, tipo_pratica,
    data_sessao, nivel_meta, status, inicio_em, minutos_revisao, questoes_planejadas
  ) values (
    v_usuario_id, v_matricula_id, p_missao_id, null, 'missao_final',
    v_data_missao, 'personalizada', 'em_andamento', now(), 0, cardinality(v_ids)
  ) returning id, status into v_sessao_id, v_sessao_status;

  insert into public.sessao_questoes_planejadas (sessao_id, questao_id, ordem)
  select v_sessao_id, x.questao_id, x.ordem::integer
  from unnest(v_ids) with ordinality x(questao_id, ordem);

  return query select v_sessao_id, v_sessao_status, v_status_missao, v_ids, false;
end;
$function$;

revoke execute on function public.iniciar_missao_final(uuid, boolean) from public, anon;
grant execute on function public.iniciar_missao_final(uuid, boolean) to authenticated;

-- ============================================================================
-- 5) concluir_missao_final — só isso encerra a missão (status='concluida').
-- ============================================================================

create function public.concluir_missao_final(
  p_missao_id uuid,
  p_sessao_id bigint
)
returns table (
  missao_id uuid,
  missao_status text,
  sessao_id bigint,
  sessao_status text
)
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_usuario_id uuid := auth.uid();
  v_status_missao text;
  v_progresso_questoes jsonb;
  v_status_sessao text;
  v_planejadas integer;
  v_respondidas integer;
begin
  if v_usuario_id is null then
    raise exception 'Usuario nao autenticado';
  end if;

  select ms.status, ms.progresso_questoes
  into v_status_missao, v_progresso_questoes
  from public.missoes ms
  join public.matriculas m on m.id = ms.matricula_id
  where ms.id = p_missao_id
    and m.usuario_id = v_usuario_id
    and m.status = 'ativa'
  for update of ms;

  if v_status_missao is null then
    raise exception 'Missao indisponivel para este usuario';
  end if;

  select s.status
  into v_status_sessao
  from public.sessoes_estudo s
  where s.id = p_sessao_id
    and s.missao_id = p_missao_id
    and s.usuario_id = v_usuario_id
    and s.tipo_pratica = 'missao_final'
  for update;

  if v_status_sessao is null then
    raise exception 'Sessao nao pertence a Missao Final desta missao';
  end if;

  if v_status_missao = 'concluida' and v_status_sessao = 'concluida' then
    return query select p_missao_id, v_status_missao, p_sessao_id, v_status_sessao;
    return;
  end if;

  if v_status_sessao <> 'em_andamento' then
    raise exception 'Estado incompativel com a conclusao da Missao Final';
  end if;

  select count(*)::integer, count(ru.questao_id)::integer
  into v_planejadas, v_respondidas
  from public.sessao_questoes_planejadas sq
  left join public.respostas_usuarios ru
    on ru.sessao_id = sq.sessao_id and ru.questao_id = sq.questao_id
  where sq.sessao_id = p_sessao_id;

  if v_planejadas = 0 or v_respondidas <> v_planejadas then
    raise exception 'Responda todas as questoes planejadas antes de concluir a Missao Final';
  end if;

  update public.sessoes_estudo
  set status = 'concluida', fim_em = coalesce(fim_em, now())
  where id = p_sessao_id;

  if jsonb_typeof(v_progresso_questoes) <> 'object'
     or (v_progresso_questoes -> 'schema_version') is distinct from to_jsonb(1::int)
  then
    v_progresso_questoes := jsonb_build_object('schema_version', 1, 'unidades_praticadas', '[]'::jsonb, 'missao_final', null);
  end if;

  v_progresso_questoes := jsonb_set(
    v_progresso_questoes,
    '{missao_final}',
    jsonb_build_object('sessao_id', p_sessao_id::text)
  );

  update public.missoes
  set progresso_questoes = v_progresso_questoes,
      status = 'concluida',
      concluida_em = coalesce(concluida_em, now())
  where id = p_missao_id;

  return query select p_missao_id, 'concluida'::text, p_sessao_id, 'concluida'::text;
end;
$function$;

revoke execute on function public.concluir_missao_final(uuid, bigint) from public, anon;
grant execute on function public.concluir_missao_final(uuid, bigint) to authenticated;

-- ============================================================================
-- FIM DO CORPO DAS 2 MIGRATIONS — daqui pra baixo é só o TEST HARNESS
-- ============================================================================

create temporary table teste_papiro_resultados (
  chave text primary key,
  ok boolean
);

create temporary table teste_papiro_contexto (
  chave text primary key,
  valor text
);

-- ---------------------------------------------------------------------------
-- BLOCO 1 — contexto real: matrícula ativa, curso, conteúdo dessa matrícula
-- (qualquer um — reaproveita a "unidade padrão" já existente para não medir
-- nada nela), e usuário admin real (se existir, para testar as RPCs de
-- classificação; se não existir, os testes de classificação via RPC ficam
-- NULL, e a fixture é criada por INSERT direto do próprio harness).
-- ---------------------------------------------------------------------------
do $$
declare
  v_matricula_id uuid;
  v_usuario_id uuid;
  v_curso_id uuid;
  v_conteudo_id bigint;
  v_admin_usuario_id uuid;
  v_candidato uuid;
begin
  select m.id, m.usuario_id, m.curso_id
  into v_matricula_id, v_usuario_id, v_curso_id
  from public.matriculas m
  where m.status = 'ativa'
  order by m.id
  limit 1;

  if v_matricula_id is null then
    raise exception 'Teste abortado: nenhuma matricula ativa real encontrada.';
  end if;

  select cc.id
  into v_conteudo_id
  from public.curso_conteudos cc
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where cm.curso_id = v_curso_id
  order by cc.id
  limit 1;

  if v_conteudo_id is null then
    raise exception 'Teste abortado: nenhum curso_conteudos encontrado para o curso da matricula de teste.';
  end if;

  for v_candidato in select id from auth.users order by created_at limit 50 loop
    perform set_config('request.jwt.claims', json_build_object('sub', v_candidato::text, 'role', 'authenticated')::text, true);
    set local role authenticated;
    if public.eh_admin() then
      v_admin_usuario_id := v_candidato;
    end if;
    reset role;
    exit when v_admin_usuario_id is not null;
  end loop;

  insert into teste_papiro_contexto (chave, valor) values
    ('matricula_id', v_matricula_id::text),
    ('usuario_id', v_usuario_id::text),
    ('curso_id', v_curso_id::text),
    ('conteudo_id', v_conteudo_id::text),
    ('admin_usuario_id', coalesce(v_admin_usuario_id::text, ''));
end $$;

-- ---------------------------------------------------------------------------
-- BLOCO 1B — isolamento do harness em relação a dados reais: iniciar_
-- missao_final/concluir_pratica_unidade contam v_total_unidades como TODAS
-- as unidades_pedagogicas ativas com aula publicada do conteúdo escolhido
-- no BLOCO 1 — inclusive as que já existiam ANTES desta transação (ex.: a
-- "unidade padrão" ordem=1 que a migration unidades_pedagogicas.sql criou
-- para todo curso_conteudos existente, ou — se o conteúdo escolhido por
-- acaso for a Lei Maria da Penha em produção — as 5 unidades reais já
-- publicadas). Sem neutralizar isso, os testes de "Missão Final possui
-- exatamente 30"/"todas as unidades representadas" ficariam reféns do
-- estado real do banco no momento em que o harness rodar.
--
-- Correção: dentro desta MESMA transação (nunca commitada, sempre desfeita
-- pelo ROLLBACK final — nenhum dado real é apagado ou alterado de forma
-- permanente), marca ativa=false qualquer unidade_pedagogica que já
-- pertencia a este conteúdo ANTES do harness rodar. As unidades fixture A/B
-- só são criadas no BLOCO 2, DEPOIS deste bloco, então nunca são atingidas
-- por este UPDATE.
-- ---------------------------------------------------------------------------
do $$
declare
  v_conteudo_id bigint := (select valor::bigint from teste_papiro_contexto where chave = 'conteudo_id');
  v_desativadas integer;
begin
  with atualizadas as (
    update public.unidades_pedagogicas
    set ativa = false
    where curso_conteudo_id = v_conteudo_id
      and ativa = true
    returning id
  )
  select count(*) into v_desativadas from atualizadas;

  insert into teste_papiro_contexto (chave, valor) values ('unidades_reais_desativadas', v_desativadas::text);
exception when others then
  raise exception 'BLOCO 1B (isolamento de unidades reais do conteudo) falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- BLOCO 2 — fixtures: 2 unidades pedagógicas extras (ordem 90/91) no
-- conteúdo real, cada uma com sua aula/aula_versao publicada; 32 questões
-- de volume (14 por unidade, cobrindo "exatamente 10"/"exatamente 30" com
-- banco de verdade) + 4 questões de comparação (par errada/certa no MESMO
-- instante em A; par antiga/recente em B) com alternativas + curso_questoes;
-- classificação via questao_unidades_pedagogicas (testa a trigger de
-- integridade materia/assunto de verdade); histórico controlado de
-- respostas.
-- ---------------------------------------------------------------------------
do $$
declare
  v_conteudo_id bigint := (select valor::bigint from teste_papiro_contexto where chave = 'conteudo_id');
  v_usuario_id uuid := (select valor::uuid from teste_papiro_contexto where chave = 'usuario_id');
  v_materia_id bigint;
  v_assunto_id bigint;
  v_unidade_a uuid;
  v_unidade_b uuid;
  v_aula_a uuid;
  v_aula_b uuid;
  v_versao_a uuid;
  v_versao_b uuid;
  v_q_a_unseen bigint[];
  v_q_a_errada bigint;
  v_q_a_certa bigint;
  v_q_b_unseen bigint[];
  v_q_b_certa_antiga bigint;
  v_q_b_certa_recente bigint;
  v_todas_a bigint[];
  v_todas_b bigint[];
  v_todas bigint[];
  v_sessao_hist bigint;
begin
  select cm.materia_id, cc.assunto_id
  into v_materia_id, v_assunto_id
  from public.curso_conteudos cc
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where cc.id = v_conteudo_id;

  insert into public.unidades_pedagogicas (curso_conteudo_id, titulo, ordem, escopo, ativa)
  values (v_conteudo_id, '[TESTE PAPIRO] Unidade A', 90, '[TESTE PAPIRO] escopo A', true)
  returning id into v_unidade_a;

  insert into public.unidades_pedagogicas (curso_conteudo_id, titulo, ordem, escopo, ativa)
  values (v_conteudo_id, '[TESTE PAPIRO] Unidade B', 91, '[TESTE PAPIRO] escopo B', true)
  returning id into v_unidade_b;

  insert into public.aulas (conteudo_id, unidade_pedagogica_id, titulo, ativa)
  values (v_conteudo_id, v_unidade_a, '[TESTE PAPIRO] Aula A', true)
  returning id into v_aula_a;
  insert into public.aula_versoes (aula_id, numero_versao, status, estrutura, publicado_em)
  values (v_aula_a, 1, 'publicada', '{"componentes":[]}'::jsonb, now())
  returning id into v_versao_a;

  insert into public.aulas (conteudo_id, unidade_pedagogica_id, titulo, ativa)
  values (v_conteudo_id, v_unidade_b, '[TESTE PAPIRO] Aula B', true)
  returning id into v_aula_b;
  insert into public.aula_versoes (aula_id, numero_versao, status, estrutura, publicado_em)
  values (v_aula_b, 1, 'publicada', '{"componentes":[]}'::jsonb, now())
  returning id into v_versao_b;

  -- Unidade A: 14 inéditas ("volume") + 1 respondida errada + 1 respondida
  -- certa NO MESMO INSTANTE da errada (par comparável: a única variável
  -- que difere entre as duas é o acerto, isolando o desempate ja_errou de
  -- qualquer efeito de recência).
  with ins as (
    insert into public.questoes (materia_id, assunto_id, enunciado, dificuldade, explicacao, banca, concurso, ano, ativa)
    select v_materia_id, v_assunto_id, '[TESTE PAPIRO] A volume-' || g, 'media', 'exp', 'PAPIRO', '[TESTE]', 2024, true
    from generate_series(1, 14) g
    returning id
  )
  select array_agg(id) into v_q_a_unseen from ins;

  insert into public.questoes (materia_id, assunto_id, enunciado, dificuldade, explicacao, banca, concurso, ano, ativa)
  values (v_materia_id, v_assunto_id, '[TESTE PAPIRO] A ja-errou', 'media', 'exp', 'PAPIRO', '[TESTE]', 2024, true)
  returning id into v_q_a_errada;
  insert into public.questoes (materia_id, assunto_id, enunciado, dificuldade, explicacao, banca, concurso, ano, ativa)
  values (v_materia_id, v_assunto_id, '[TESTE PAPIRO] A ja-acertou comparavel', 'media', 'exp', 'PAPIRO', '[TESTE]', 2024, true)
  returning id into v_q_a_certa;

  -- Unidade B: 14 inéditas ("volume" — somada às de A, garante >= 30
  -- candidatas reais para a Missão Final) + 1 respondida certa há muito
  -- tempo + 1 respondida certa recentemente (par para o teste de recência,
  -- sem nenhuma errada envolvida).
  with ins as (
    insert into public.questoes (materia_id, assunto_id, enunciado, dificuldade, explicacao, banca, concurso, ano, ativa)
    select v_materia_id, v_assunto_id, '[TESTE PAPIRO] B volume-' || g, 'media', 'exp', 'PAPIRO', '[TESTE]', 2024, true
    from generate_series(1, 14) g
    returning id
  )
  select array_agg(id) into v_q_b_unseen from ins;

  insert into public.questoes (materia_id, assunto_id, enunciado, dificuldade, explicacao, banca, concurso, ano, ativa)
  values (v_materia_id, v_assunto_id, '[TESTE PAPIRO] B certa-antiga', 'media', 'exp', 'PAPIRO', '[TESTE]', 2024, true)
  returning id into v_q_b_certa_antiga;
  insert into public.questoes (materia_id, assunto_id, enunciado, dificuldade, explicacao, banca, concurso, ano, ativa)
  values (v_materia_id, v_assunto_id, '[TESTE PAPIRO] B certa-recente', 'media', 'exp', 'PAPIRO', '[TESTE]', 2024, true)
  returning id into v_q_b_certa_recente;

  v_todas_a := v_q_a_unseen || array[v_q_a_errada, v_q_a_certa];
  v_todas_b := v_q_b_unseen || array[v_q_b_certa_antiga, v_q_b_certa_recente];
  v_todas := v_todas_a || v_todas_b;

  insert into public.alternativas (questao_id, texto, ordem, correta)
  select id, '[TESTE] correta', 1, true from public.questoes where id = any(v_todas);
  insert into public.alternativas (questao_id, texto, ordem, correta)
  select id, '[TESTE] errada', 2, false from public.questoes where id = any(v_todas);

  insert into public.curso_questoes (questao_id, curso_id, prioridade)
  select id, (select valor::uuid from teste_papiro_contexto where chave = 'curso_id'), 1
  from public.questoes where id = any(v_todas);

  -- Classificação via RPC de admin (testa a integridade REAL da RPC), se
  -- houver admin; senão, INSERT direto (o harness já é o role privilegiado)
  -- só como fallback pra não bloquear o resto do teste.
  if (select valor from teste_papiro_contexto where chave = 'admin_usuario_id') <> '' then
    perform set_config('request.jwt.claims', json_build_object('sub', (select valor from teste_papiro_contexto where chave = 'admin_usuario_id'), 'role', 'authenticated')::text, true);
    set local role authenticated;
    perform public.classificar_questao_unidade_admin(x, v_unidade_a) from unnest(v_todas_a) x;
    perform public.classificar_questao_unidade_admin(x, v_unidade_b) from unnest(v_todas_b) x;
    reset role;
  else
    insert into public.questao_unidades_pedagogicas (questao_id, unidade_pedagogica_id)
    select x, v_unidade_a from unnest(v_todas_a) x
    union all
    select x, v_unidade_b from unnest(v_todas_b) x;
  end if;

  -- Histórico controlado: 1 sessão livre com respostas diretamente
  -- inseridas (sem passar pela RPC registrar_resposta, que também exige
  -- 'em_andamento' — aqui só precisamos do FATO histórico). A trigger
  -- respostas_valida_sessao (validar_resposta_da_sessao, BEFORE INSERT em
  -- respostas_usuarios) exige sessoes_estudo.status='em_andamento' no
  -- MOMENTO do INSERT, inclusive para INSERT direto — criar a sessão já
  -- 'concluida' faz TODO INSERT em respostas_usuarios falhar com "Sessao
  -- nao esta em andamento". Por isso: cria 'em_andamento', insere as
  -- respostas (respondida_em controlado por linha), só DEPOIS marca
  -- 'concluida'. Sem desabilitar a trigger, sem contornar a validação.
  insert into public.sessoes_estudo (usuario_id, matricula_id, nivel_meta, status, inicio_em, minutos_revisao, questoes_planejadas)
  values (v_usuario_id, (select valor::uuid from teste_papiro_contexto where chave = 'matricula_id'), 'personalizada', 'em_andamento', now() - interval '10 days', 0, 4)
  returning id into v_sessao_hist;

  insert into public.respostas_usuarios (usuario_id, questao_id, alternativa_id, sessao_id, acertou, respondida_em)
  values
    (v_usuario_id, v_q_a_errada, (select id from public.alternativas where questao_id = v_q_a_errada and not correta), v_sessao_hist, false, now() - interval '5 days'),
    (v_usuario_id, v_q_a_certa, (select id from public.alternativas where questao_id = v_q_a_certa and correta), v_sessao_hist, true, now() - interval '5 days'),
    (v_usuario_id, v_q_b_certa_antiga, (select id from public.alternativas where questao_id = v_q_b_certa_antiga and correta), v_sessao_hist, true, now() - interval '10 days'),
    (v_usuario_id, v_q_b_certa_recente, (select id from public.alternativas where questao_id = v_q_b_certa_recente and correta), v_sessao_hist, true, now() - interval '1 hour');

  update public.sessoes_estudo
  set status = 'concluida',
      fim_em = (select max(respondida_em) from public.respostas_usuarios where sessao_id = v_sessao_hist)
  where id = v_sessao_hist;

  insert into teste_papiro_resultados values (
    'historico_fixture_bloco2_ok',
    (select status from public.sessoes_estudo where id = v_sessao_hist) = 'concluida'
    and (select count(*) from public.respostas_usuarios where sessao_id = v_sessao_hist) = 4
  );

  insert into teste_papiro_contexto (chave, valor) values
    ('unidade_a', v_unidade_a::text),
    ('unidade_b', v_unidade_b::text),
    ('versao_a', v_versao_a::text),
    ('versao_b', v_versao_b::text),
    ('q_a_unseen', array_to_string(v_q_a_unseen, ',')),
    ('q_a_errada', v_q_a_errada::text),
    ('q_a_certa', v_q_a_certa::text),
    ('q_b_unseen', array_to_string(v_q_b_unseen, ',')),
    ('q_b_certa_antiga', v_q_b_certa_antiga::text),
    ('q_b_certa_recente', v_q_b_certa_recente::text);
exception when others then
  raise exception 'BLOCO 2 (fixtures de unidades/questoes/historico) falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- BLOCO 2B — assercao EXPLICITA de que o isolamento do BLOCO 1B funcionou:
-- recalcula, de forma independente (mesma consulta usada por
-- iniciar_missao_final/concluir_pratica_unidade, mas escrita aqui de novo,
-- não reaproveitada, para não confiar cegamente no cálculo interno da
-- própria RPC), que exatamente as 2 unidades fixture (A e B) contam como
-- ativas/publicadas para o conteúdo escolhido — nem mais, nem menos.
-- ---------------------------------------------------------------------------
do $$
declare
  v_conteudo_id bigint := (select valor::bigint from teste_papiro_contexto where chave = 'conteudo_id');
  v_unidade_a uuid := (select valor::uuid from teste_papiro_contexto where chave = 'unidade_a');
  v_unidade_b uuid := (select valor::uuid from teste_papiro_contexto where chave = 'unidade_b');
  v_total_unidades integer;
  v_ids_unidades uuid[];
begin
  select count(distinct u.id)::integer, array_agg(distinct u.id)
  into v_total_unidades, v_ids_unidades
  from public.unidades_pedagogicas u
  join public.aulas a on a.unidade_pedagogica_id = u.id and a.ativa = true
  join public.aula_versoes av on av.aula_id = a.id and av.status = 'publicada'
  where u.curso_conteudo_id = v_conteudo_id
    and u.ativa = true;

  insert into teste_papiro_resultados values (
    'isolamento_total_unidades_exatamente_dois',
    v_total_unidades = 2
    and v_ids_unidades @> array[v_unidade_a, v_unidade_b]
    and array_length(v_ids_unidades, 1) = 2
  );
exception when others then
  raise exception 'BLOCO 2B (assercao de isolamento) falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- BLOCO 3 — testes puros do algoritmo de seleção (chamado diretamente,
-- fora de qualquer sessão, como o próprio role do harness — a função é
-- STABLE/SECURITY DEFINER e não depende de estar "logado" para ser
-- exercitada aqui).
-- ---------------------------------------------------------------------------
do $$
declare
  v_usuario_id uuid := (select valor::uuid from teste_papiro_contexto where chave = 'usuario_id');
  v_curso_id uuid := (select valor::uuid from teste_papiro_contexto where chave = 'curso_id');
  v_unidade_a uuid := (select valor::uuid from teste_papiro_contexto where chave = 'unidade_a');
  v_unidade_b uuid := (select valor::uuid from teste_papiro_contexto where chave = 'unidade_b');
  v_q_a_unseen bigint[] := string_to_array((select valor from teste_papiro_contexto where chave = 'q_a_unseen'), ',')::bigint[];
  v_q_a_errada bigint := (select valor::bigint from teste_papiro_contexto where chave = 'q_a_errada');
  v_q_a_certa bigint := (select valor::bigint from teste_papiro_contexto where chave = 'q_a_certa');
  v_q_b_unseen bigint[] := string_to_array((select valor from teste_papiro_contexto where chave = 'q_b_unseen'), ',')::bigint[];
  v_q_b_certa_antiga bigint := (select valor::bigint from teste_papiro_contexto where chave = 'q_b_certa_antiga');
  v_q_b_certa_recente bigint := (select valor::bigint from teste_papiro_contexto where chave = 'q_b_certa_recente');
  v_todas_a bigint[];
  v_ids bigint[];
begin
  v_todas_a := v_q_a_unseen || array[v_q_a_errada, v_q_a_certa];

  -- "unidade so recebe questoes vinculadas a ela": com limite alto, a
  -- unidade A devolve exatamente o conjunto das suas 16 questoes fixture
  -- (14 ineditas + errada + certa comparavel), nem uma a mais nem a menos.
  select array_agg(x.questao_id) into v_ids
  from public.selecionar_candidatas_unidade_pedagogica(v_usuario_id, v_unidade_a, v_curso_id, 100, '{}'::bigint[]) x(questao_id);
  insert into teste_papiro_resultados values (
    'unidade_so_recebe_suas_questoes',
    coalesce(cardinality(v_ids), 0) = 16
    and (select array_agg(x order by x) from unnest(v_ids) x) = (select array_agg(x order by x) from unnest(v_todas_a) x)
  );

  -- "inéditas são priorizadas mesmo com vistas elegíveis disponíveis":
  -- exclui 13 das 14 inéditas de A via p_excluir, deixando como
  -- candidatas [1 inédita, errada, certa] — 1 inédita entre 2 vistas.
  -- Pedindo 1, tem que vir a inédita, provando que a regra vence mesmo
  -- quando há vistas "disponíveis" para escolher (não apenas quando são a
  -- única opção).
  select array_agg(x.questao_id) into v_ids
  from public.selecionar_candidatas_unidade_pedagogica(
    v_usuario_id, v_unidade_a, v_curso_id, 1, v_q_a_unseen[2:14]
  ) x(questao_id);
  insert into teste_papiro_resultados values (
    'ineditas_priorizadas',
    coalesce(cardinality(v_ids), 0) = 1 and v_ids[1] = v_q_a_unseen[1]
  );

  -- "fallback funciona com menos ineditas do que o pedido / mais antiga
  -- antes da mais recente": exclui 13 das 14 inéditas de B via p_excluir,
  -- deixando [1 inédita, certa-antiga, certa-recente]. Pedindo 3: a
  -- inédita vem primeiro; entre as 2 vistas (ambas certas, sem nenhuma
  -- errada aqui), o desempate é só por tempo — a mais ANTIGA (10 dias)
  -- antes da mais RECENTE (1 hora).
  select array_agg(x.questao_id) into v_ids
  from public.selecionar_candidatas_unidade_pedagogica(
    v_usuario_id, v_unidade_b, v_curso_id, 3, v_q_b_unseen[2:14]
  ) x(questao_id);
  insert into teste_papiro_resultados values (
    'fallback_com_menos_de_dez_ineditas',
    coalesce(cardinality(v_ids), 0) = 3 and v_ids[1] = v_q_b_unseen[1]
  );
  insert into teste_papiro_resultados values (
    'vista_mais_antiga_antes_da_mais_recente',
    coalesce(cardinality(v_ids), 0) = 3
    and array_position(v_ids, v_q_b_certa_antiga) < array_position(v_ids, v_q_b_certa_recente)
  );

  -- "erro anterior aumenta prioridade no fallback de vistas", agora com
  -- uma COMPARAÇÃO real (não apenas 1 candidata sobrando): excluindo as
  -- 14 inéditas de A via p_excluir, sobram só as 2 vistas — uma errada e
  -- uma certa, respondidas no MESMO instante (5 dias atrás), então a
  -- ÚNICA variável que diferencia as duas é o acerto. Pedindo as 2, a
  -- errada tem que vir ANTES da certa.
  select array_agg(x.questao_id) into v_ids
  from public.selecionar_candidatas_unidade_pedagogica(
    v_usuario_id, v_unidade_a, v_curso_id, 2, v_q_a_unseen
  ) x(questao_id);
  insert into teste_papiro_resultados values (
    'erro_anterior_aumenta_prioridade',
    coalesce(cardinality(v_ids), 0) = 2
    and v_ids[1] = v_q_a_errada
    and v_ids[2] = v_q_a_certa
  );

  -- "questao nao repete dentro da mesma selecao": pedindo mais do que
  -- existe na unidade A (100 > 16), nenhum id duplicado.
  select array_agg(x.questao_id) into v_ids
  from public.selecionar_candidatas_unidade_pedagogica(v_usuario_id, v_unidade_a, v_curso_id, 100, '{}'::bigint[]) x(questao_id);
  insert into teste_papiro_resultados values (
    'sem_duplicata_na_selecao',
    coalesce(cardinality(v_ids), 0) = (select count(distinct x) from unnest(v_ids) x)
  );
exception when others then
  raise exception 'BLOCO 3 (algoritmo de selecao) falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- BLOCO 3B — tiers de prioridade (nunca respondida > vista fora da janela
-- > repetição especialmente recente). Usa uma unidade fixture PRÓPRIA
-- ("Unidade Janela", ativa=false) para não interferir em nenhuma contagem
-- de v_total_unidades (BLOCO 2B) nem em nenhuma asserção de cardinalidade
-- das unidades A/B — selecionar_candidatas_unidade_pedagogica não filtra
-- por unidades_pedagogicas.ativa (só iniciar_pratica_unidade/
-- iniciar_missao_final filtram, para decidir o que é "unidade praticável"),
-- então esta unidade fica 100% isolada e mesmo assim é candidata válida
-- para chamadas diretas do algoritmo aqui.
-- ---------------------------------------------------------------------------
do $$
declare
  v_conteudo_id bigint := (select valor::bigint from teste_papiro_contexto where chave = 'conteudo_id');
  v_usuario_id uuid := (select valor::uuid from teste_papiro_contexto where chave = 'usuario_id');
  v_curso_id uuid := (select valor::uuid from teste_papiro_contexto where chave = 'curso_id');
  v_matricula_id uuid := (select valor::uuid from teste_papiro_contexto where chave = 'matricula_id');
  v_materia_id bigint;
  v_assunto_id bigint;
  v_unidade_janela uuid;
  v_q_j_nunca_1 bigint; v_q_j_nunca_2 bigint;
  v_q_j_certa_antiga bigint; v_q_j_errada_recente bigint; v_q_j_usada_na_missao bigint;
  v_todas_j bigint[];
  v_hoje date := (timezone('America/Sao_Paulo', now()))::date;
  v_data_missao_teste_janela date;
  v_missoes_antes integer;
  v_missoes_depois integer;
  v_missao_janela uuid;
  v_sessao_hist_janela bigint;
  v_sessao_pratica_janela bigint;
  v_ids bigint[];
begin
  select cm.materia_id, cc.assunto_id
  into v_materia_id, v_assunto_id
  from public.curso_conteudos cc
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where cc.id = v_conteudo_id;

  insert into public.unidades_pedagogicas (curso_conteudo_id, titulo, ordem, escopo, ativa)
  values (v_conteudo_id, '[TESTE PAPIRO] Unidade Janela', 92, '[TESTE PAPIRO] escopo janela', false)
  returning id into v_unidade_janela;

  insert into public.questoes (materia_id, assunto_id, enunciado, dificuldade, explicacao, banca, concurso, ano, ativa)
  values (v_materia_id, v_assunto_id, '[TESTE PAPIRO] Janela nunca-1', 'media', 'exp', 'PAPIRO', '[TESTE]', 2024, true)
  returning id into v_q_j_nunca_1;
  insert into public.questoes (materia_id, assunto_id, enunciado, dificuldade, explicacao, banca, concurso, ano, ativa)
  values (v_materia_id, v_assunto_id, '[TESTE PAPIRO] Janela nunca-2', 'media', 'exp', 'PAPIRO', '[TESTE]', 2024, true)
  returning id into v_q_j_nunca_2;
  insert into public.questoes (materia_id, assunto_id, enunciado, dificuldade, explicacao, banca, concurso, ano, ativa)
  values (v_materia_id, v_assunto_id, '[TESTE PAPIRO] Janela certa-antiga', 'media', 'exp', 'PAPIRO', '[TESTE]', 2024, true)
  returning id into v_q_j_certa_antiga;
  insert into public.questoes (materia_id, assunto_id, enunciado, dificuldade, explicacao, banca, concurso, ano, ativa)
  values (v_materia_id, v_assunto_id, '[TESTE PAPIRO] Janela errada-recente', 'media', 'exp', 'PAPIRO', '[TESTE]', 2024, true)
  returning id into v_q_j_errada_recente;
  insert into public.questoes (materia_id, assunto_id, enunciado, dificuldade, explicacao, banca, concurso, ano, ativa)
  values (v_materia_id, v_assunto_id, '[TESTE PAPIRO] Janela usada-na-missao', 'media', 'exp', 'PAPIRO', '[TESTE]', 2024, true)
  returning id into v_q_j_usada_na_missao;

  v_todas_j := array[v_q_j_nunca_1, v_q_j_nunca_2, v_q_j_certa_antiga, v_q_j_errada_recente, v_q_j_usada_na_missao];

  insert into public.alternativas (questao_id, texto, ordem, correta)
  select id, '[TESTE] correta', 1, true from public.questoes where id = any(v_todas_j);
  insert into public.alternativas (questao_id, texto, ordem, correta)
  select id, '[TESTE] errada', 2, false from public.questoes where id = any(v_todas_j);

  insert into public.curso_questoes (questao_id, curso_id, prioridade)
  select id, v_curso_id, 1 from public.questoes where id = any(v_todas_j);

  insert into public.questao_unidades_pedagogicas (questao_id, unidade_pedagogica_id)
  select x, v_unidade_janela from unnest(v_todas_j) x;

  -- Sessão livre genérica (missao_id nulo) só para pendurar as respostas
  -- "comuns" (certa-antiga / errada-recente) — nenhuma das duas pertence a
  -- uma prática de unidade de missão nenhuma. Mesma lição do BLOCO 2: a
  -- trigger respostas_valida_sessao exige status='em_andamento' no
  -- momento do INSERT em respostas_usuarios (inclusive para INSERT
  -- direto) — cria 'em_andamento', insere as respostas, só depois marca
  -- 'concluida'.
  insert into public.sessoes_estudo (usuario_id, matricula_id, nivel_meta, status, inicio_em, minutos_revisao, questoes_planejadas)
  values (v_usuario_id, v_matricula_id, 'personalizada', 'em_andamento', now() - interval '30 days', 0, 2)
  returning id into v_sessao_hist_janela;

  insert into public.respostas_usuarios (usuario_id, questao_id, alternativa_id, sessao_id, acertou, respondida_em)
  values
    (v_usuario_id, v_q_j_certa_antiga, (select id from public.alternativas where questao_id = v_q_j_certa_antiga and correta), v_sessao_hist_janela, true, now() - interval '30 days'),
    (v_usuario_id, v_q_j_errada_recente, (select id from public.alternativas where questao_id = v_q_j_errada_recente and not correta), v_sessao_hist_janela, false, now() - interval '2 minutes');

  update public.sessoes_estudo
  set status = 'concluida',
      fim_em = (select max(respondida_em) from public.respostas_usuarios where sessao_id = v_sessao_hist_janela)
  where id = v_sessao_hist_janela;

  -- Missão fixture PRÓPRIA (independente da missão do BLOCO 4/5) só para
  -- provar o sinal "usada nas práticas de unidade da missão atual" —
  -- respondida há 2 DIAS (fora da janela de 24h) de propósito: se o teste
  -- passar mesmo assim, prova que é o vínculo por missao_id/tipo_pratica
  -- que está classificando como recente, não o relógio.
  --
  -- public.missoes tem UNIQUE(matricula_id, conteudo_id, data_missao) — a
  -- mesma matrícula/conteúdo real do BLOCO 1 pode já ter uma missão para
  -- "hoje" (ou qualquer outra data fixa). Mesmo princípio do BLOCO 4: busca
  -- dinamicamente a primeira data livre para esta combinação, nunca
  -- reaproveita/atualiza/apaga uma missão existente. Roda ANTES do BLOCO 4
  -- nesta mesma transação, então a busca do BLOCO 4 por sua vez já vai
  -- enxergar esta linha e escolher uma data diferente automaticamente.
  select d::date
  into v_data_missao_teste_janela
  from generate_series(v_hoje - 1, v_hoje - 3650, interval '-1 day') d
  where not exists (
    select 1
    from public.missoes m
    where m.matricula_id = v_matricula_id
      and m.conteudo_id = v_conteudo_id
      and m.data_missao = d::date
  )
  limit 1;

  if v_data_missao_teste_janela is null then
    raise exception 'Teste abortado: nenhuma data livre encontrada nos ultimos 3650 dias para matricula_id=% / conteudo_id=% (UNIQUE(matricula_id, conteudo_id, data_missao)).', v_matricula_id, v_conteudo_id;
  end if;

  select count(*) into v_missoes_antes from public.missoes where matricula_id = v_matricula_id and conteudo_id = v_conteudo_id;

  insert into public.missoes (matricula_id, conteudo_id, data_missao, status, progresso_teoria)
  values (v_matricula_id, v_conteudo_id, v_data_missao_teste_janela, 'iniciada', '{}'::jsonb)
  returning id into v_missao_janela;

  select count(*) into v_missoes_depois from public.missoes where matricula_id = v_matricula_id and conteudo_id = v_conteudo_id;

  insert into teste_papiro_resultados values (
    'missao_fixture_janela_usa_data_livre',
    v_missao_janela is not null
    and (select data_missao from public.missoes where id = v_missao_janela) = v_data_missao_teste_janela
    and v_missoes_depois = v_missoes_antes + 1
  );

  insert into teste_papiro_contexto (chave, valor) values ('data_missao_teste_janela', v_data_missao_teste_janela::text);

  insert into public.sessoes_estudo (usuario_id, matricula_id, missao_id, unidade_pedagogica_id, tipo_pratica, nivel_meta, status, inicio_em, minutos_revisao, questoes_planejadas)
  values (v_usuario_id, v_matricula_id, v_missao_janela, v_unidade_janela, 'unidade', 'personalizada', 'em_andamento', now() - interval '2 days', 0, 1)
  returning id into v_sessao_pratica_janela;

  -- v_sessao_pratica_janela tem missao_id preenchido: a mesma trigger
  -- também exige a questão em sessao_questoes_planejadas para sessões de
  -- missão (senão "Questao nao planejada para esta missao") — diferente
  -- das sessões livres acima (missao_id nulo), que pulam essa checagem.
  insert into public.sessao_questoes_planejadas (sessao_id, questao_id, ordem)
  values (v_sessao_pratica_janela, v_q_j_usada_na_missao, 1);

  insert into public.respostas_usuarios (usuario_id, questao_id, alternativa_id, sessao_id, acertou, respondida_em)
  values (v_usuario_id, v_q_j_usada_na_missao, (select id from public.alternativas where questao_id = v_q_j_usada_na_missao and correta), v_sessao_pratica_janela, true, now() - interval '2 days');

  update public.sessoes_estudo
  set status = 'concluida',
      fim_em = (select max(respondida_em) from public.respostas_usuarios where sessao_id = v_sessao_pratica_janela)
  where id = v_sessao_pratica_janela;

  insert into teste_papiro_resultados values (
    'historico_fixture_janela_ok',
    (select status from public.sessoes_estudo where id = v_sessao_hist_janela) = 'concluida'
    and (select count(*) from public.respostas_usuarios where sessao_id = v_sessao_hist_janela) = 2
    and (select status from public.sessoes_estudo where id = v_sessao_pratica_janela) = 'concluida'
    and (select count(*) from public.respostas_usuarios where sessao_id = v_sessao_pratica_janela) = 1
  );

  -- "inéditas ainda vencem tudo": sem excluir nada, pedindo 2, só as 2
  -- nunca-respondidas voltam (nenhuma das 3 vistas, mesmo a mais antiga).
  select array_agg(x.questao_id) into v_ids
  from public.selecionar_candidatas_unidade_pedagogica(v_usuario_id, v_unidade_janela, v_curso_id, 2, '{}'::bigint[]) x(questao_id);
  insert into teste_papiro_resultados values (
    'unidade_janela_ineditas_ainda_vencem_tudo',
    coalesce(cardinality(v_ids), 0) = 2 and v_ids @> array[v_q_j_nunca_1, v_q_j_nunca_2]
  );

  -- "errada recente NÃO vence vista antiga quando existe alternativa":
  -- exclui as 2 inéditas e a usada-na-missão, sobram só certa-antiga (30
  -- dias, correta) e errada-recente (2 minutos, errada). Mesmo sendo
  -- errada, a recente PERDE — ela está na janela de repetição imediata
  -- (Tier C), a antiga não (Tier B), e Tier B sempre vence Tier C.
  select array_agg(x.questao_id) into v_ids
  from public.selecionar_candidatas_unidade_pedagogica(
    v_usuario_id, v_unidade_janela, v_curso_id, 1,
    array[v_q_j_nunca_1, v_q_j_nunca_2, v_q_j_usada_na_missao]
  ) x(questao_id);
  insert into teste_papiro_resultados values (
    'errada_recente_nao_vence_vista_antiga',
    coalesce(cardinality(v_ids), 0) = 1 and v_ids[1] = v_q_j_certa_antiga
  );

  -- "a recente entra quando necessária para completar a quantidade": mesmo
  -- par (só 2 candidatas possíveis nesta exclusão), pedindo as 2 -> as 2
  -- voltam, prova que Tier C não é uma exclusão permanente.
  select array_agg(x.questao_id) into v_ids
  from public.selecionar_candidatas_unidade_pedagogica(
    v_usuario_id, v_unidade_janela, v_curso_id, 2,
    array[v_q_j_nunca_1, v_q_j_nunca_2, v_q_j_usada_na_missao]
  ) x(questao_id);
  insert into teste_papiro_resultados values (
    'recente_entra_quando_necessaria',
    coalesce(cardinality(v_ids), 0) = 2 and v_ids @> array[v_q_j_certa_antiga, v_q_j_errada_recente]
  );

  -- "Missão Final evita questões das práticas da mesma missão quando há
  -- candidatas suficientes": exclui as 2 inéditas e a errada-recente,
  -- sobram certa-antiga (30 dias, sem nenhum vínculo de missão) e
  -- usada-na-missao (2 dias — FORA da janela de 24h, mas usada numa
  -- prática de unidade da v_missao_janela). Passando p_missao_id =
  -- v_missao_janela e pedindo 1, tem que voltar a certa-antiga — a
  -- usada-na-missao perde mesmo sendo, por relógio, mais antiga que os 2
  -- minutos do teste anterior, porque o vínculo por missão a classifica
  -- como Tier C aqui.
  select array_agg(x.questao_id) into v_ids
  from public.selecionar_candidatas_unidade_pedagogica(
    v_usuario_id, v_unidade_janela, v_curso_id, 1,
    array[v_q_j_nunca_1, v_q_j_nunca_2, v_q_j_errada_recente],
    v_missao_janela
  ) x(questao_id);
  insert into teste_papiro_resultados values (
    'missao_final_evita_questoes_da_propria_missao',
    coalesce(cardinality(v_ids), 0) = 1 and v_ids[1] = v_q_j_certa_antiga
  );

  -- "se não houver banco suficiente, pode reutilizá-las": mesmo par e
  -- mesmo p_missao_id, pedindo as 2 -> as 2 voltam (a usada-na-missao
  -- também não é uma exclusão permanente, só de baixa prioridade).
  select array_agg(x.questao_id) into v_ids
  from public.selecionar_candidatas_unidade_pedagogica(
    v_usuario_id, v_unidade_janela, v_curso_id, 2,
    array[v_q_j_nunca_1, v_q_j_nunca_2, v_q_j_errada_recente],
    v_missao_janela
  ) x(questao_id);
  insert into teste_papiro_resultados values (
    'missao_final_reutiliza_se_banco_insuficiente',
    coalesce(cardinality(v_ids), 0) = 2 and v_ids @> array[v_q_j_certa_antiga, v_q_j_usada_na_missao]
  );
exception when others then
  raise exception 'BLOCO 3B (tiers de prioridade / janela de repeticao) falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- BLOCO 4 — fluxo completo via RPCs, como o usuário real (role trocado
-- SOMENTE ao redor das chamadas de RPC — nunca em leitura direta de
-- tabela, mesma lição já aplicada nos harnesses anteriores desta fase).
-- Cria a missão fixture e simula progresso_teoria já concluído para as
-- duas unidades extras (sem precisar rodar o fluxo de teoria completo).
-- ---------------------------------------------------------------------------
do $$
declare
  v_usuario_id uuid := (select valor::uuid from teste_papiro_contexto where chave = 'usuario_id');
  v_matricula_id uuid := (select valor::uuid from teste_papiro_contexto where chave = 'matricula_id');
  v_conteudo_id bigint := (select valor::bigint from teste_papiro_contexto where chave = 'conteudo_id');
  v_unidade_a uuid := (select valor::uuid from teste_papiro_contexto where chave = 'unidade_a');
  v_unidade_b uuid := (select valor::uuid from teste_papiro_contexto where chave = 'unidade_b');
  v_versao_a uuid := (select valor::uuid from teste_papiro_contexto where chave = 'versao_a');
  v_versao_b uuid := (select valor::uuid from teste_papiro_contexto where chave = 'versao_b');
  v_hoje date := (timezone('America/Sao_Paulo', now()))::date;
  v_data_missao_teste date;
  v_missoes_antes integer;
  v_missoes_depois integer;
  v_missao_id uuid;
  v_progresso_teoria jsonb;
  v_sessao_a bigint;
  v_sessao_a2 bigint;
  v_ids_a bigint[];
  v_alt_ids_a bigint[];
  v_recuperada boolean;
  v_pratica_ok boolean;
begin
  -- Progresso de teoria simulado já com AS 2 unidades extras concluídas
  -- (não passa pela RPC de teoria — esse fluxo já é testado em
  -- unidades-pedagogicas-progresso.test.mjs/*_teste_rollback.sql).
  v_progresso_teoria := jsonb_build_object(
    'schema_version', 2,
    'unidades_concluidas', jsonb_build_array(
      jsonb_build_object('unidade_pedagogica_id', v_unidade_a::text, 'aula_versao_id', v_versao_a::text),
      jsonb_build_object('unidade_pedagogica_id', v_unidade_b::text, 'aula_versao_id', v_versao_b::text)
    )
  );

  -- public.missoes tem UNIQUE(matricula_id, conteudo_id, data_missao). Usar
  -- "hoje" fixo já quebrou em produção porque a matrícula/conteúdo real
  -- escolhidos no BLOCO 1 já tinham uma missão real para a data de hoje —
  -- e travar numa data fixa qualquer teria o mesmo risco. Em vez disso,
  -- procura dinamicamente a primeira data (voltando no tempo a partir de
  -- ontem, até 3650 dias) ainda LIVRE para esta combinação exata — nunca
  -- reaproveita, atualiza ou apaga uma missão real existente, só evita a
  -- data que ela ocupa.
  select d::date
  into v_data_missao_teste
  from generate_series(v_hoje - 1, v_hoje - 3650, interval '-1 day') d
  where not exists (
    select 1
    from public.missoes m
    where m.matricula_id = v_matricula_id
      and m.conteudo_id = v_conteudo_id
      and m.data_missao = d::date
  )
  limit 1;

  if v_data_missao_teste is null then
    raise exception 'Teste abortado: nenhuma data livre encontrada nos ultimos 3650 dias para matricula_id=% / conteudo_id=% (UNIQUE(matricula_id, conteudo_id, data_missao)).', v_matricula_id, v_conteudo_id;
  end if;

  select count(*) into v_missoes_antes from public.missoes where matricula_id = v_matricula_id and conteudo_id = v_conteudo_id;

  insert into public.missoes (matricula_id, conteudo_id, data_missao, status, progresso_teoria)
  values (v_matricula_id, v_conteudo_id, v_data_missao_teste, 'iniciada', v_progresso_teoria)
  returning id into v_missao_id;

  select count(*) into v_missoes_depois from public.missoes where matricula_id = v_matricula_id and conteudo_id = v_conteudo_id;

  -- Prova que a fixture foi CRIADA (não reaproveitou/atualizou nenhuma
  -- missão real): a contagem para esta combinação tem que ter aumentado em
  -- exatamente 1 — se tivéssemos sobrescrito uma linha existente em vez de
  -- inserir, a contagem teria ficado igual.
  insert into teste_papiro_resultados values (
    'missao_fixture_bloco4_usa_data_livre',
    v_missao_id is not null
    and (select data_missao from public.missoes where id = v_missao_id) = v_data_missao_teste
    and v_missoes_depois = v_missoes_antes + 1
  );

  insert into teste_papiro_contexto (chave, valor) values ('data_missao_teste', v_data_missao_teste::text);

  perform set_config('request.jwt.claims', json_build_object('sub', v_usuario_id::text, 'role', 'authenticated')::text, true);
  set local role authenticated;

  -- "exatamente 10 quando houver banco suficiente": unidade A tem 16
  -- questões fixture (14 inéditas + 2 vistas) — banco real e suficiente.
  -- iniciar_pratica_unidade tem que congelar exatamente 10 ids distintos
  -- (não 16, não menos).
  select sessao_id, questao_ids, recuperada into v_sessao_a, v_ids_a, v_recuperada
  from public.iniciar_pratica_unidade(v_missao_id, v_unidade_a);

  reset role;

  insert into teste_papiro_resultados values (
    'iniciar_pratica_unidade_ok',
    v_sessao_a is not null
    and coalesce(cardinality(v_ids_a), 0) = 10
    and cardinality(v_ids_a) = (select count(distinct x) from unnest(v_ids_a) x)
    and not v_recuperada
  );

  -- "sessao iniciada e recuperada com os mesmos ids": chamando de novo,
  -- sem responder nada, tem que devolver a MESMA sessao e os MESMOS 10 ids
  -- (congelados, não recalculados).
  perform set_config('request.jwt.claims', json_build_object('sub', v_usuario_id::text, 'role', 'authenticated')::text, true);
  set local role authenticated;
  select sessao_id, questao_ids, recuperada into v_sessao_a2, v_ids_a, v_recuperada
  from public.iniciar_pratica_unidade(v_missao_id, v_unidade_a);
  reset role;

  insert into teste_papiro_resultados values (
    'sessao_recuperada_mesmos_ids',
    v_sessao_a2 = v_sessao_a and v_recuperada and coalesce(cardinality(v_ids_a), 0) = 10
  );

  -- "duas unidades da mesma missao podem possuir sessoes diferentes".
  -- teste_papiro_resultados pertence ao role do harness, não a
  -- authenticated — o INSERT tem que acontecer só DEPOIS do reset role,
  -- nunca dentro do trecho simulando o aluno (SQLSTATE 42501 se ficar
  -- dentro: "permission denied for table teste_papiro_resultados").
  perform set_config('request.jwt.claims', json_build_object('sub', v_usuario_id::text, 'role', 'authenticated')::text, true);
  set local role authenticated;
  declare
    v_sessao_b bigint;
  begin
    select sessao_id into v_sessao_b from public.iniciar_pratica_unidade(v_missao_id, v_unidade_b);
    reset role;
    insert into teste_papiro_resultados values ('unidades_tem_sessoes_diferentes', v_sessao_b is not null and v_sessao_b <> v_sessao_a);
  end;

  -- "usuario nao consegue iniciar sessao para missao de outro usuario":
  -- tenta com um usuario_id qualquer (uuid aleatorio, garantidamente sem
  -- matricula igual) — tem que falhar.
  begin
    perform set_config('request.jwt.claims', json_build_object('sub', gen_random_uuid()::text, 'role', 'authenticated')::text, true);
    set local role authenticated;
    perform public.iniciar_pratica_unidade(v_missao_id, v_unidade_a);
    reset role;
    insert into teste_papiro_resultados values ('outro_usuario_bloqueado', false);
  exception when others then
    reset role;
    insert into teste_papiro_resultados values ('outro_usuario_bloqueado', true);
  end;

  -- "concluir uma unidade nao conclui a missao inteira": responde as 10
  -- questoes planejadas da unidade A e conclui — status da missao NAO pode
  -- virar 'concluida'. public.alternativas é lida FORA de authenticated —
  -- resolve v_alt_ids_a com o role do harness, e só então volta a simular
  -- o aluno para registrar as respostas.
  reset role;

  select array_agg(a.id order by x.ord)
  into v_alt_ids_a
  from unnest(v_ids_a) with ordinality x(questao_id, ord)
  join public.alternativas a
    on a.questao_id = x.questao_id
   and a.correta = true;

  if coalesce(cardinality(v_alt_ids_a), 0) <> coalesce(cardinality(v_ids_a), 0) then
    raise exception 'Fixture invalida: % questoes planejadas da unidade A mas % alternativas corretas resolvidas', cardinality(v_ids_a), cardinality(v_alt_ids_a);
  end if;

  perform set_config('request.jwt.claims', json_build_object('sub', v_usuario_id::text, 'role', 'authenticated')::text, true);
  set local role authenticated;
  perform public.registrar_resposta(q.questao_id, alt.alternativa_id, v_sessao_a, null)
  from unnest(v_ids_a) with ordinality q(questao_id, ord)
  join unnest(v_alt_ids_a) with ordinality alt(alternativa_id, ord)
    using (ord);
  select missao_final_liberada into v_pratica_ok from public.concluir_pratica_unidade(v_missao_id, v_sessao_a);
  reset role;

  insert into teste_papiro_resultados values (
    'concluir_unidade_nao_conclui_missao',
    (select status from public.missoes where id = v_missao_id) <> 'concluida'
    and coalesce(v_pratica_ok, true) = false
  );

  -- "missao final so libera quando todas as unidades e praticas
  -- obrigatorias estiverem concluidas": só a unidade A foi praticada até
  -- aqui (B ainda está em andamento) — iniciar a Missão Final tem que
  -- falhar.
  begin
    perform set_config('request.jwt.claims', json_build_object('sub', v_usuario_id::text, 'role', 'authenticated')::text, true);
    set local role authenticated;
    perform public.iniciar_missao_final(v_missao_id);
    reset role;
    insert into teste_papiro_resultados values ('missao_final_bloqueada_sem_todas_unidades', false);
  exception when others then
    reset role;
    insert into teste_papiro_resultados values ('missao_final_bloqueada_sem_todas_unidades', true);
  end;

  insert into teste_papiro_contexto (chave, valor) values ('missao_id', v_missao_id::text);
exception when others then
  reset role;
  raise exception 'BLOCO 4 (fluxo via RPC) falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- BLOCO 5 — conclui a unidade B também, libera e roda a Missão Final
-- inteira; A(16) + B(16) = 32 candidatas reais classificadas, suficiente
-- para testar "cardinality(questao_ids) = 30" com banco de verdade, e não
-- apenas ">0". Também confirma que ambas as unidades ficam representadas
-- no resultado.
-- ---------------------------------------------------------------------------
do $$
declare
  v_usuario_id uuid := (select valor::uuid from teste_papiro_contexto where chave = 'usuario_id');
  v_missao_id uuid := (select valor::uuid from teste_papiro_contexto where chave = 'missao_id');
  v_unidade_a uuid := (select valor::uuid from teste_papiro_contexto where chave = 'unidade_a');
  v_unidade_b uuid := (select valor::uuid from teste_papiro_contexto where chave = 'unidade_b');
  v_sessao_b bigint;
  v_ids_b bigint[];
  v_alt_ids_b bigint[];
  v_sessao_final bigint;
  v_ids_final bigint[];
  v_alt_ids_final bigint[];
begin
  -- (1-2) authenticated só para iniciar a prática da unidade B — a RPC
  -- decide e congela v_ids_b no servidor.
  perform set_config('request.jwt.claims', json_build_object('sub', v_usuario_id::text, 'role', 'authenticated')::text, true);
  set local role authenticated;
  select sessao_id, questao_ids into v_sessao_b, v_ids_b from public.iniciar_pratica_unidade(v_missao_id, v_unidade_b);

  -- (3-4) RESET ROLE antes de ler public.alternativas — a tabela pertence
  -- ao role do harness, não a authenticated (mesma lição do BLOCO 4).
  reset role;

  select array_agg(a.id order by x.ord)
  into v_alt_ids_b
  from unnest(v_ids_b) with ordinality x(questao_id, ord)
  join public.alternativas a
    on a.questao_id = x.questao_id
   and a.correta = true;

  if coalesce(cardinality(v_alt_ids_b), 0) <> coalesce(cardinality(v_ids_b), 0) then
    raise exception 'Fixture invalida: % questoes planejadas da unidade B mas % alternativas corretas resolvidas', cardinality(v_ids_b), cardinality(v_alt_ids_b);
  end if;

  -- (5-8) volta a authenticated para registrar as respostas de B, concluir
  -- a prática de B, e iniciar a Missão Final — tudo ainda como o aluno.
  perform set_config('request.jwt.claims', json_build_object('sub', v_usuario_id::text, 'role', 'authenticated')::text, true);
  set local role authenticated;
  perform public.registrar_resposta(q.questao_id, alt.alternativa_id, v_sessao_b, null)
  from unnest(v_ids_b) with ordinality q(questao_id, ord)
  join unnest(v_alt_ids_b) with ordinality alt(alternativa_id, ord)
    using (ord);
  perform public.concluir_pratica_unidade(v_missao_id, v_sessao_b);
  select sessao_id, questao_ids into v_sessao_final, v_ids_final from public.iniciar_missao_final(v_missao_id);

  -- (9-10) RESET ROLE de novo antes de ler public.alternativas para as 30
  -- questões da Missão Final.
  reset role;

  select array_agg(a.id order by x.ord)
  into v_alt_ids_final
  from unnest(v_ids_final) with ordinality x(questao_id, ord)
  join public.alternativas a
    on a.questao_id = x.questao_id
   and a.correta = true;

  if coalesce(cardinality(v_alt_ids_final), 0) <> coalesce(cardinality(v_ids_final), 0) then
    raise exception 'Fixture invalida: % questoes da Missao Final mas % alternativas corretas resolvidas', cardinality(v_ids_final), cardinality(v_alt_ids_final);
  end if;

  -- (11-13) authenticated de novo para registrar as 30 respostas da Missão
  -- Final e concluí-la.
  perform set_config('request.jwt.claims', json_build_object('sub', v_usuario_id::text, 'role', 'authenticated')::text, true);
  set local role authenticated;
  perform public.registrar_resposta(q.questao_id, alt.alternativa_id, v_sessao_final, null)
  from unnest(v_ids_final) with ordinality q(questao_id, ord)
  join unnest(v_alt_ids_final) with ordinality alt(alternativa_id, ord)
    using (ord);
  perform public.concluir_missao_final(v_missao_id, v_sessao_final);

  -- (14) RESET ROLE antes de qualquer assert.
  reset role;

  -- (15) todos os asserts já existentes, agora só depois do reset role.
  insert into teste_papiro_resultados values (
    'missao_final_ok',
    v_sessao_final is not null
    and coalesce(cardinality(v_ids_final), 0) = 30
    and cardinality(v_ids_final) = (select count(distinct x) from unnest(v_ids_final) x)
  );
  insert into teste_papiro_resultados values (
    'missao_final_representa_todas_unidades',
    exists (select 1 from public.questao_unidades_pedagogicas where unidade_pedagogica_id = v_unidade_a and questao_id = any(v_ids_final))
    and exists (select 1 from public.questao_unidades_pedagogicas where unidade_pedagogica_id = v_unidade_b and questao_id = any(v_ids_final))
  );
  insert into teste_papiro_resultados values ('missao_final_conclui_missao', (select status from public.missoes where id = v_missao_id) = 'concluida');
exception when others then
  reset role;
  raise exception 'BLOCO 5 (Missao Final) falhou: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- BLOCO 6 — refazer preserva histórico; sessão livre/personalizada
-- continua funcionando; usuário não usa questão de outro curso.
-- ---------------------------------------------------------------------------
do $$
declare
  v_usuario_id uuid := (select valor::uuid from teste_papiro_contexto where chave = 'usuario_id');
  v_missao_id uuid := (select valor::uuid from teste_papiro_contexto where chave = 'missao_id');
  v_unidade_a uuid := (select valor::uuid from teste_papiro_contexto where chave = 'unidade_a');
  v_sessoes_antes integer;
  v_sessoes_depois integer;
  v_sessao_refeita bigint;
begin
  select count(*) into v_sessoes_antes from public.sessoes_estudo where missao_id = v_missao_id;

  perform set_config('request.jwt.claims', json_build_object('sub', v_usuario_id::text, 'role', 'authenticated')::text, true);
  set local role authenticated;
  select sessao_id into v_sessao_refeita from public.iniciar_pratica_unidade(v_missao_id, v_unidade_a, true);
  reset role;

  select count(*) into v_sessoes_depois from public.sessoes_estudo where missao_id = v_missao_id;

  insert into teste_papiro_resultados values (
    'refazer_preserva_historico',
    v_sessoes_depois = v_sessoes_antes + 1 and v_sessao_refeita is not null
  );
exception when others then
  reset role;
  insert into teste_papiro_resultados values ('refazer_preserva_historico', false);
  raise notice 'BLOCO 6 (refazer): SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

do $$
declare
  v_usuario_id uuid := (select valor::uuid from teste_papiro_contexto where chave = 'usuario_id');
  v_curso_id uuid := (select valor::uuid from teste_papiro_contexto where chave = 'curso_id');
  v_curso_ativo_id uuid;
  v_materia_id bigint;
  v_ids bigint[];
begin
  -- ids_questoes_para_usuario exige perfis.curso_ativo_id = curso da
  -- matricula (funcoes_curso_ativo.sql) — dado real que este harness não
  -- controla. Se o usuário de teste não tiver o curso ativo apontando para
  -- este mesmo curso, o resultado vazio seria uma falsa falha (não um bug
  -- desta fase) — marcado NULL + NOTICE nesse caso, nunca false.
  select p.curso_ativo_id into v_curso_ativo_id
  from public.perfis p
  where p.usuario_id = v_usuario_id;

  if v_curso_ativo_id is distinct from v_curso_id then
    insert into teste_papiro_resultados values ('sessao_livre_continua_funcionando', null);
    raise notice 'sessao_livre_continua_funcionando pulado: perfis.curso_ativo_id do usuario de teste nao aponta para o curso desta matricula (dado real fora do controle deste harness).';
  else
    select materia_id into v_materia_id
    from public.questoes
    where id = (select string_to_array(valor, ',')::bigint[] from teste_papiro_contexto where chave = 'q_a_unseen')[1];

    perform set_config('request.jwt.claims', json_build_object('sub', v_usuario_id::text, 'role', 'authenticated')::text, true);
    set local role authenticated;
    select array_agg(x.questao_id) into v_ids
    from public.ids_questoes_para_usuario(50, v_materia_id, null) x(questao_id);
    reset role;

    insert into teste_papiro_resultados values (
      'sessao_livre_continua_funcionando',
      v_ids is not null and cardinality(v_ids) > 0
    );
  end if;
exception when others then
  reset role;
  insert into teste_papiro_resultados values ('sessao_livre_continua_funcionando', false);
  raise notice 'sessao_livre_continua_funcionando: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

do $$
declare
  v_usuario_id uuid := (select valor::uuid from teste_papiro_contexto where chave = 'usuario_id');
  v_unidade_a uuid := (select valor::uuid from teste_papiro_contexto where chave = 'unidade_a');
  v_outro_curso_id uuid;
  v_ids bigint[];
begin
  select id into v_outro_curso_id from public.cursos where id <> (select valor::uuid from teste_papiro_contexto where chave = 'curso_id') limit 1;

  if v_outro_curso_id is null then
    insert into teste_papiro_resultados values ('nao_usa_questoes_de_outro_curso', null);
    raise notice 'nao_usa_questoes_de_outro_curso pulado: so existe 1 curso real neste banco.';
  else
    select array_agg(x.questao_id) into v_ids
    from public.selecionar_candidatas_unidade_pedagogica(v_usuario_id, v_unidade_a, v_outro_curso_id, 10, '{}'::bigint[]) x(questao_id);
    insert into teste_papiro_resultados values ('nao_usa_questoes_de_outro_curso', coalesce(cardinality(v_ids), 0) = 0);
  end if;
exception when others then
  insert into teste_papiro_resultados values ('nao_usa_questoes_de_outro_curso', false);
  raise notice 'nao_usa_questoes_de_outro_curso: SQLSTATE=%, erro=%', sqlstate, sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- RESULTADO FINAL
-- ---------------------------------------------------------------------------
select
  (select ok from teste_papiro_resultados where chave = 'historico_fixture_bloco2_ok') as historico_fixture_bloco2_ok,
  (select ok from teste_papiro_resultados where chave = 'historico_fixture_janela_ok') as historico_fixture_janela_ok,
  (select ok from teste_papiro_resultados where chave = 'missao_fixture_janela_usa_data_livre') as missao_fixture_janela_usa_data_livre,
  (select ok from teste_papiro_resultados where chave = 'missao_fixture_bloco4_usa_data_livre') as missao_fixture_bloco4_usa_data_livre,
  (select ok from teste_papiro_resultados where chave = 'isolamento_total_unidades_exatamente_dois') as isolamento_total_unidades_exatamente_dois,
  (select ok from teste_papiro_resultados where chave = 'unidade_so_recebe_suas_questoes') as unidade_so_recebe_suas_questoes,
  (select ok from teste_papiro_resultados where chave = 'ineditas_priorizadas') as ineditas_priorizadas,
  (select ok from teste_papiro_resultados where chave = 'fallback_com_menos_de_dez_ineditas') as fallback_com_menos_de_dez_ineditas,
  (select ok from teste_papiro_resultados where chave = 'vista_mais_antiga_antes_da_mais_recente') as vista_mais_antiga_antes_da_mais_recente,
  (select ok from teste_papiro_resultados where chave = 'erro_anterior_aumenta_prioridade') as erro_anterior_aumenta_prioridade,
  (select ok from teste_papiro_resultados where chave = 'sem_duplicata_na_selecao') as sem_duplicata_na_selecao,
  (select ok from teste_papiro_resultados where chave = 'unidade_janela_ineditas_ainda_vencem_tudo') as unidade_janela_ineditas_ainda_vencem_tudo,
  (select ok from teste_papiro_resultados where chave = 'errada_recente_nao_vence_vista_antiga') as errada_recente_nao_vence_vista_antiga,
  (select ok from teste_papiro_resultados where chave = 'recente_entra_quando_necessaria') as recente_entra_quando_necessaria,
  (select ok from teste_papiro_resultados where chave = 'missao_final_evita_questoes_da_propria_missao') as missao_final_evita_questoes_da_propria_missao,
  (select ok from teste_papiro_resultados where chave = 'missao_final_reutiliza_se_banco_insuficiente') as missao_final_reutiliza_se_banco_insuficiente,
  (select ok from teste_papiro_resultados where chave = 'iniciar_pratica_unidade_ok') as iniciar_pratica_unidade_ok,
  (select ok from teste_papiro_resultados where chave = 'sessao_recuperada_mesmos_ids') as sessao_recuperada_mesmos_ids,
  (select ok from teste_papiro_resultados where chave = 'unidades_tem_sessoes_diferentes') as unidades_tem_sessoes_diferentes,
  (select ok from teste_papiro_resultados where chave = 'outro_usuario_bloqueado') as outro_usuario_bloqueado,
  (select ok from teste_papiro_resultados where chave = 'concluir_unidade_nao_conclui_missao') as concluir_unidade_nao_conclui_missao,
  (select ok from teste_papiro_resultados where chave = 'missao_final_bloqueada_sem_todas_unidades') as missao_final_bloqueada_sem_todas_unidades,
  (select ok from teste_papiro_resultados where chave = 'missao_final_ok') as missao_final_ok,
  (select ok from teste_papiro_resultados where chave = 'missao_final_representa_todas_unidades') as missao_final_representa_todas_unidades,
  (select ok from teste_papiro_resultados where chave = 'missao_final_conclui_missao') as missao_final_conclui_missao,
  (select ok from teste_papiro_resultados where chave = 'refazer_preserva_historico') as refazer_preserva_historico,
  (select ok from teste_papiro_resultados where chave = 'sessao_livre_continua_funcionando') as sessao_livre_continua_funcionando,
  (select ok from teste_papiro_resultados where chave = 'nao_usa_questoes_de_outro_curso') as nao_usa_questoes_de_outro_curso,
  not exists (
    select 1 from teste_papiro_resultados where ok is distinct from true and ok is not null
  ) as tudo_ok;

ROLLBACK;
