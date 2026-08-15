-- Modo Papiro por unidades pedagógicas — regra oficial:
--   Unidade N (aula) -> 10 questões exclusivas da Unidade N
--   ... para cada unidade ativa e publicada do conteúdo ...
--   Missão Final Papiro -> 30 questões misturando todas as unidades
--
-- Este arquivo assume supabase/questao_unidades_pedagogicas.sql já aplicado
-- (questao_unidades_pedagogicas, missoes.progresso_questoes,
-- sessoes_estudo.unidade_pedagogica_id/tipo_pratica).
--
-- NÃO substitui nem edita public.iniciar_questoes_da_missao/
-- concluir_questoes_da_missao (missao_questoes_rpc.sql/missao_refazer_
-- rpc.sql) — aquele fluxo continua servindo, sem nenhuma mudança, todo
-- conteúdo com EXATAMENTE UMA unidade pedagógica ativa/publicada (a grande
-- maioria do currículo hoje: toda migration de unidades_pedagogicas.sql
-- cria uma "unidade padrão" ordem=1 para cada curso_conteudos existente).
-- As RPCs deste arquivo só entram em jogo quando o frontend detecta MAIS DE
-- UMA unidade publicada (app/teoria/page.tsx já carrega essa lista via
-- carregar_unidades_publicadas_da_missao) — hoje, só a Lei Maria da Penha
-- (conteúdo 53, 5 unidades).
--
-- Segurança (mesmo princípio de TODAS as RPCs deste projeto): a seleção de
-- questões é decidida INTEIRAMENTE no servidor — os RETURNS TABLE devolvem
-- questao_ids para o cliente exibir, mas nenhuma RPC deste arquivo aceita
-- ids de questão como parâmetro de entrada. usuário autenticado, matrícula
-- ativa, missão do próprio usuário, unidade pertencente ao conteúdo da
-- missão e questão vinculada à unidade (garantido pela própria consulta:
-- só junta em questao_unidades_pedagogicas) são todos validados no
-- servidor, nunca confiados ao cliente.
--
-- Envolvido em BEGIN/COMMIT — ou tudo aplica, ou nada aplica.

BEGIN;

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

COMMIT;
