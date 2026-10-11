-- PAPIRO — BETA 1.1 — Central de Revisões e Diagnóstico: revisão
-- PERSONALIZADA (filtros) ao lado da revisão automática já existente.
--
-- Esta migration NÃO toca em iniciar_revisao(), concluir_revisao(bigint),
-- registrar_resposta, classificar_erro, nem em nenhuma coluna/constraint
-- de sessoes_estudo/revisoes já criada por 20261008120000_revisao_
-- executavel.sql ou 20261010120000_corrigir_ambiguidade_revisao.sql —
-- nenhuma delas é editada, como instruído. O fluxo automático continua
-- 100% intacto.
--
-- Desenho (ver auditoria apresentada antes desta migration):
--   1) contar_revisoes_personalizadas(...): só leitura, devolve quantas
--      revisões (já reduzidas à regra de 1 marco por erro — Opção B)
--      combinam com os filtros. Usada pela "Central de Revisões" para o
--      preview "N questões disponíveis" ANTES do aluno clicar em
--      "Iniciar revisão" — nunca cria nada.
--   2) iniciar_revisao_personalizada(...): mesmo preâmbulo (auth/curso
--      ativo/matrícula/lock/recuperação idempotente) de iniciar_revisao(),
--      copiado literalmente — por isso as duas COMPARTILHAM a mesma
--      sessão em_andamento (nivel_meta='revisao'): se já existe uma
--      sessão de revisão em andamento, criada pelo fluxo automático OU
--      pelo personalizado, a outra chamada simplesmente a recupera,
--      nunca cria uma segunda. Só a SELEÇÃO das revisões muda: em vez de
--      "todas as pendentes vencidas hoje", aplica os filtros opcionais
--      (matéria/assunto/tipo de erro/situação) e limita a quantidade
--      pedida (clamp 1-50) — mantendo a MESMA regra de 1 marco por erro
--      (distinct on erro_id, ordem) e o MESMO congelamento de
--      revisao_ids na criação. concluir_revisao(bigint) é 100%
--      reaproveitada sem nenhuma mudança: ela só processa o que estiver
--      congelado em revisao_ids, não importa qual das duas RPCs criou a
--      sessão.
--
-- Validação server-side (nunca confia em texto/id vindo do cliente sem
-- checar pertencimento ao curso ativo):
--   - p_situacao: só 'vencidas' | 'hoje' | 'proximas' | 'todas';
--   - p_tipo_erro: só um dos 5 valores atuais de classificar_erro
--     (nao_sabia/duvida/chute/atencao/interpretacao) — nunca os valores
--     legados (ex.: falta_conhecimento) que só existem em dados antigos;
--   - p_assunto_id sem p_materia_id é rejeitado (mesma regra de
--     classificar_estudo_avulso);
--   - p_materia_id/p_assunto_id validados contra curso_materias/
--     curso_conteudos do curso ATIVO (relevante_para_preparacao=true) —
--     MESMO padrão e MESMAS mensagens de erro de
--     supabase/migrations/20261007180000_reforcar_materia_assunto_
--     classificar_estudo_avulso.sql — nunca "existe em algum lugar", só
--     "pertence a este curso".
--
-- Rollback (documentado, não executado por esta migration):
--   drop function if exists public.iniciar_revisao_personalizada(bigint, bigint, text, text, integer);
--   drop function if exists public.contar_revisoes_personalizadas(bigint, bigint, text, text);
--   (nenhuma linha de dado é alterada por este rollback — sessões de
--   revisão personalizada já criadas continuam válidas, só as duas RPCs
--   deixam de existir; nenhuma delas tem efeito sobre schema/constraints).

-- ----------------------------------------------------------------------------
-- contar_revisoes_personalizadas(): preview só-leitura, nunca cria sessão.
-- ----------------------------------------------------------------------------
create or replace function public.contar_revisoes_personalizadas(
  p_materia_id bigint default null,
  p_assunto_id bigint default null,
  p_tipo_erro text default null,
  p_situacao text default 'vencidas'
)
returns integer
language plpgsql
stable
security definer
set search_path to ''
as $function$
declare
  v_usuario_id uuid := auth.uid();
  v_curso_ativo_id uuid;
  v_matricula_id uuid;
  v_total integer;
begin
  if v_usuario_id is null then
    raise exception 'Usuario nao autenticado';
  end if;

  select p.curso_ativo_id into v_curso_ativo_id
  from public.perfis p
  where p.usuario_id = v_usuario_id;

  if v_curso_ativo_id is null then
    raise exception 'Nenhum curso ativo selecionado';
  end if;

  select m.id into v_matricula_id
  from public.matriculas m
  where m.usuario_id = v_usuario_id
    and m.curso_id = v_curso_ativo_id
    and m.status = 'ativa';

  if v_matricula_id is null then
    raise exception 'Matricula ativa no curso ativo nao encontrada';
  end if;

  if p_situacao not in ('vencidas', 'hoje', 'proximas', 'todas') then
    raise exception 'Situacao invalida: %', p_situacao;
  end if;

  if p_tipo_erro is not null and p_tipo_erro not in ('nao_sabia', 'duvida', 'chute', 'atencao', 'interpretacao') then
    raise exception 'Tipo de erro invalido: %', p_tipo_erro;
  end if;

  if p_assunto_id is not null and p_materia_id is null then
    raise exception 'p_assunto_id informado sem p_materia_id';
  end if;

  if p_materia_id is not null and not exists (
    select 1
    from public.curso_materias cm
    where cm.curso_id = v_curso_ativo_id
      and cm.materia_id = p_materia_id
      and cm.relevante_para_preparacao = true
  ) then
    raise exception 'Materia nao pertence ao curso desta matricula';
  end if;

  if p_assunto_id is not null and not exists (
    select 1
    from public.curso_conteudos cc
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cm.curso_id = v_curso_ativo_id
      and cm.materia_id = p_materia_id
      and cc.assunto_id = p_assunto_id
      and cc.relevante_para_preparacao = true
  ) then
    raise exception 'Assunto invalido para esta materia/curso';
  end if;

  -- Mesma regra de 1 marco por erro (Opção B) de iniciar_revisao() —
  -- o preview precisa bater exatamente com o que iniciar_revisao_
  -- personalizada() de fato selecionaria com os mesmos filtros.
  select count(*) into v_total
  from (
    select distinct on (rv.erro_id) rv.id
    from public.revisoes rv
    join public.erros_usuarios eu on eu.id = rv.erro_id
    join public.respostas_usuarios ru on ru.id = eu.resposta_id
    join public.sessoes_estudo se on se.id = ru.sessao_id and se.matricula_id = v_matricula_id
    left join public.questoes q on q.id = eu.questao_id
    where rv.usuario_id = v_usuario_id
      and rv.status = 'pendente'
      and (
        (p_situacao = 'vencidas' and rv.agendada_para < current_date)
        or (p_situacao = 'hoje' and rv.agendada_para = current_date)
        or (p_situacao = 'proximas' and rv.agendada_para > current_date)
        or (p_situacao = 'todas')
      )
      and (p_tipo_erro is null or eu.tipo_erro = p_tipo_erro)
      and (p_materia_id is null or q.materia_id = p_materia_id)
      and (p_assunto_id is null or q.assunto_id = p_assunto_id)
    order by rv.erro_id, rv.ordem
  ) elegiveis;

  return coalesce(v_total, 0);
end;
$function$;

revoke all on function public.contar_revisoes_personalizadas(bigint, bigint, text, text) from public, anon;
grant execute on function public.contar_revisoes_personalizadas(bigint, bigint, text, text) to authenticated;

-- ----------------------------------------------------------------------------
-- iniciar_revisao_personalizada(): mesma sessão/idempotência/lock de
-- iniciar_revisao() — só a seleção de revisões muda (filtros + quantidade
-- em vez de "todas as vencidas hoje").
-- ----------------------------------------------------------------------------
create or replace function public.iniciar_revisao_personalizada(
  p_materia_id bigint default null,
  p_assunto_id bigint default null,
  p_tipo_erro text default null,
  p_situacao text default 'vencidas',
  p_quantidade integer default 20
)
returns table (
  sessao_id bigint,
  status text,
  questao_ids bigint[],
  recuperada boolean
)
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_usuario_id uuid := auth.uid();
  v_curso_ativo_id uuid;
  v_matricula_id uuid;
  v_sessao_id bigint;
  v_status text;
  v_revisao_ids bigint[];
  v_questao_ids bigint[];
  v_total integer;
  v_quantidade integer;
begin
  if v_usuario_id is null then
    raise exception 'Usuario nao autenticado';
  end if;

  select p.curso_ativo_id into v_curso_ativo_id
  from public.perfis p
  where p.usuario_id = v_usuario_id;

  if v_curso_ativo_id is null then
    raise exception 'Nenhum curso ativo selecionado';
  end if;

  select m.id into v_matricula_id
  from public.matriculas m
  where m.usuario_id = v_usuario_id
    and m.curso_id = v_curso_ativo_id
    and m.status = 'ativa';

  if v_matricula_id is null then
    raise exception 'Matricula ativa no curso ativo nao encontrada';
  end if;

  if p_situacao not in ('vencidas', 'hoje', 'proximas', 'todas') then
    raise exception 'Situacao invalida: %', p_situacao;
  end if;

  if p_tipo_erro is not null and p_tipo_erro not in ('nao_sabia', 'duvida', 'chute', 'atencao', 'interpretacao') then
    raise exception 'Tipo de erro invalido: %', p_tipo_erro;
  end if;

  if p_assunto_id is not null and p_materia_id is null then
    raise exception 'p_assunto_id informado sem p_materia_id';
  end if;

  if p_materia_id is not null and not exists (
    select 1
    from public.curso_materias cm
    where cm.curso_id = v_curso_ativo_id
      and cm.materia_id = p_materia_id
      and cm.relevante_para_preparacao = true
  ) then
    raise exception 'Materia nao pertence ao curso desta matricula';
  end if;

  if p_assunto_id is not null and not exists (
    select 1
    from public.curso_conteudos cc
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cm.curso_id = v_curso_ativo_id
      and cm.materia_id = p_materia_id
      and cc.assunto_id = p_assunto_id
      and cc.relevante_para_preparacao = true
  ) then
    raise exception 'Assunto invalido para esta materia/curso';
  end if;

  -- Clamp server-side (nunca confia no número vindo do cliente) — mesmo
  -- intervalo [1, 50] usado como referência de "quantidade" em outros
  -- fluxos avulsos deste projeto.
  v_quantidade := greatest(1, least(50, coalesce(p_quantidade, 20)));

  -- Lock e recuperação IDÊNTICOS a iniciar_revisao() — mesma chave, então
  -- a automática e a personalizada disputam/recuperam a MESMA sessão
  -- em_andamento (nivel_meta='revisao'), nunca duas sessões paralelas.
  perform pg_advisory_xact_lock(
    hashtextextended('revisao:' || v_usuario_id::text || ':' || v_matricula_id::text, 0)
  );

  select s.id, s.status
  into v_sessao_id, v_status
  from public.sessoes_estudo s
  where s.usuario_id = v_usuario_id
    and s.matricula_id = v_matricula_id
    and s.missao_id is null
    and s.status = 'em_andamento'
    and s.nivel_meta = 'revisao'
  order by s.id desc
  limit 1
  for update;

  if v_sessao_id is not null then
    select array_agg(sq.questao_id order by sq.ordem)
    into v_questao_ids
    from public.sessao_questoes_planejadas sq
    where sq.sessao_id = v_sessao_id;

    if coalesce(cardinality(v_questao_ids), 0) = 0 then
      raise exception 'Sessao de revisao sem lista de questoes planejadas';
    end if;

    return query select v_sessao_id, v_status, v_questao_ids, true;
    return;
  end if;

  -- Mesma independência de marcos (Opção B) de iniciar_revisao(): no
  -- máximo 1 marco por erro_id, o mais antigo elegível — agora dentro do
  -- subconjunto que combina com os filtros. "elegiveis" decide QUAL marco
  -- de cada erro entra (distinct on erro_id); a ordenação por
  -- agendada_para só decide a PRIORIDADE entre erros diferentes ao
  -- aplicar o limite de quantidade.
  with elegiveis as (
    select distinct on (rv.erro_id) rv.id, rv.agendada_para
    from public.revisoes rv
    join public.erros_usuarios eu on eu.id = rv.erro_id
    join public.respostas_usuarios ru on ru.id = eu.resposta_id
    join public.sessoes_estudo se on se.id = ru.sessao_id and se.matricula_id = v_matricula_id
    left join public.questoes q on q.id = eu.questao_id
    where rv.usuario_id = v_usuario_id
      and rv.status = 'pendente'
      and (
        (p_situacao = 'vencidas' and rv.agendada_para < current_date)
        or (p_situacao = 'hoje' and rv.agendada_para = current_date)
        or (p_situacao = 'proximas' and rv.agendada_para > current_date)
        or (p_situacao = 'todas')
      )
      and (p_tipo_erro is null or eu.tipo_erro = p_tipo_erro)
      and (p_materia_id is null or q.materia_id = p_materia_id)
      and (p_assunto_id is null or q.assunto_id = p_assunto_id)
    order by rv.erro_id, rv.ordem
  )
  select array_agg(x.id)
  into v_revisao_ids
  from (
    select id from elegiveis order by agendada_para asc limit v_quantidade
  ) x;

  if coalesce(cardinality(v_revisao_ids), 0) = 0 then
    raise exception 'Nenhuma revisao encontrada para os filtros selecionados';
  end if;

  -- DISTINCT entre erros diferentes que apontam para a mesma questão —
  -- mesmo motivo/comentário de iniciar_revisao().
  select array_agg(distinct eu.questao_id)
  into v_questao_ids
  from public.revisoes rv
  join public.erros_usuarios eu on eu.id = rv.erro_id
  where rv.id = any(v_revisao_ids);

  v_total := coalesce(cardinality(v_questao_ids), 0);
  if v_total = 0 then
    raise exception 'Nenhuma questao associada as revisoes selecionadas';
  end if;

  insert into public.sessoes_estudo as se (
    usuario_id, matricula_id, nivel_meta, status,
    inicio_em, minutos_revisao, questoes_planejadas, revisao_ids
  ) values (
    v_usuario_id, v_matricula_id, 'revisao', 'em_andamento',
    clock_timestamp(), 0, v_total, v_revisao_ids
  ) returning se.id, se.status into v_sessao_id, v_status;

  insert into public.sessao_questoes_planejadas (sessao_id, questao_id, ordem)
  select v_sessao_id, x.questao_id, x.ordem::integer
  from unnest(v_questao_ids) with ordinality x(questao_id, ordem);

  return query select v_sessao_id, v_status, v_questao_ids, false;
end;
$function$;

revoke all on function public.iniciar_revisao_personalizada(bigint, bigint, text, text, integer) from public, anon;
grant execute on function public.iniciar_revisao_personalizada(bigint, bigint, text, text, integer) to authenticated;
