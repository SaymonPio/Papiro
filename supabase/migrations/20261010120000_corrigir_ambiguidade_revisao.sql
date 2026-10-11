-- Hotfix: iniciar_revisao() falhava no E2E com Postgres 42702 ("column
-- reference \"status\" is ambiguous") ao criar uma sessão nova — mesma
-- classe de bug já corrigida antes em
-- 20261004200000_corrigir_ambiguidade_sessao_avulsa.sql, agora reaberta
-- porque 20261008120000_revisao_executavel.sql foi escrita copiando o
-- padrão da versão ANTES daquele hotfix (sem o alias).
--
-- Causa: RETURNS TABLE(sessao_id bigint, status text, questao_ids
-- bigint[], recuperada boolean) em iniciar_revisao() e RETURNS
-- TABLE(sessao_id bigint, status text, revisoes_concluidas integer) em
-- concluir_revisao() fazem o PL/pgSQL declarar implicitamente variáveis
-- de saída com esses nomes, visíveis em toda a função. "status" colide
-- com a coluna sessoes_estudo.status/revisoes.status nos 3 lugares em
-- que aparece SEM qualificação:
--
--   1) iniciar_revisao() — insert into public.sessoes_estudo (..., status,
--      ...) values (...) returning id, status into v_sessao_id, v_status;
--   2) concluir_revisao() — ramo idempotente: select count(*) ... from
--      public.revisoes where id = any(v_sessao.revisao_ids) and status =
--      'concluida';
--   3) concluir_revisao() — dentro do loop: update public.revisoes set
--      status = 'concluida', ... where id = v_revisao_id and usuario_id =
--      v_usuario_id and status = 'pendente'; (a cláusula SET em si nunca
--      ambígua — é sintaxe fixa do UPDATE — só o "status" da WHERE).
--
-- "id"/"usuario_id"/"revisoes_concluidas"/"questao_ids"/"recuperada" não
-- ambíguam em nenhum lugar (nenhuma outra coluna usada bate com esses
-- nomes de variável de saída) — auditoria completa das duas funções
-- inteiras não encontrou mais nenhuma ocorrência além das 3 acima
-- (confirmado também pelo UPDATE final de concluir_revisao, que fecha a
-- sessão: sua WHERE só usa id/usuario_id, nunca status, então não é
-- ambígua e não precisou de alias).
--
-- Correção: mesmo padrão já estabelecido no hotfix de 2026-10-04 — alias
-- explícito na tabela-alvo (INSERT INTO ... AS alias / UPDATE ... AS
-- alias, sintaxe padrão do Postgres) e qualificação de toda referência a
-- "status" com esse alias. Nenhuma outra regra de negócio muda: mesmo
-- SECURITY DEFINER, search_path, pg_advisory_xact_lock, seleção de no
-- máximo 1 marco por erro (opção B), revisao_ids congelado na criação da
-- sessão, validação NOT EXISTS de cobertura real, proteção contra
-- resposta ausente e idempotência — tudo copiado sem alteração da
-- migration anterior, só com os 3 pontos de ambiguidade qualificados.

create or replace function public.iniciar_revisao()
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

  -- Serializa a ABERTURA da sessão (não só a recuperação de uma que já
  -- existe): um FOR UPDATE sozinho só trava uma linha já existente — duas
  -- chamadas concorrentes que encontrem ZERO sessões em_andamento passariam
  -- as duas pelo bloco abaixo e inseririam duas sessões (mesma falha já
  -- presente em iniciar_sessao_questoes_avulsa, não corrigida ali por estar
  -- fora do escopo desta migration). O lock é de escopo de TRANSAÇÃO
  -- (liberado automaticamente no commit/rollback do próprio RPC — nunca
  -- precisa de unlock manual) e serializa qualquer chamada desta mesma
  -- combinação usuario+matrícula+'revisao': a segunda chamada só lê o
  -- estado depois que a primeira já terminou de criar (ou recuperar) a
  -- sessão.
  perform pg_advisory_xact_lock(
    hashtextextended('revisao:' || v_usuario_id::text || ':' || v_matricula_id::text, 0)
  );

  -- Recuperação idempotente (retry/duplo clique/F5 nunca cria uma segunda
  -- sessão de revisão) — agora dentro da região serializada pelo lock acima.
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

  -- Independência dos 3 marcos (decisão confirmada após a auditoria
  -- pré-apply, opção B): quando ordem 1/2/3 do MESMO erro estão todas
  -- pendentes e vencidas ao mesmo tempo (aluno ficou muito tempo sem
  -- revisar), esta sessão consome só UM marco por erro — o mais antigo
  -- vencido (menor ordem, que é sempre a menor agendada_para também,
  -- porque os 3 nascem juntos em registrar_resposta com intervalos
  -- crescentes). Os demais marcos continuam 'pendente' e vencidos, e
  -- voltam a aparecer numa PRÓXIMA chamada de iniciar_revisao (mesmo dia
  -- ou depois) — nunca quitados de uma vez por uma única resposta. Pela
  -- MESMA cadeia de isolamento por curso já usada em
  -- revisoes_do_curso_ativo (erro_id -> erros_usuarios ->
  -- respostas_usuarios -> sessoes_estudo.matricula_id).
  select array_agg(x.id)
  into v_revisao_ids
  from (
    select distinct on (rv.erro_id) rv.id
    from public.revisoes rv
    join public.erros_usuarios eu on eu.id = rv.erro_id
    join public.respostas_usuarios ru on ru.id = eu.resposta_id
    join public.sessoes_estudo se on se.id = ru.sessao_id and se.matricula_id = v_matricula_id
    where rv.usuario_id = v_usuario_id
      and rv.status = 'pendente'
      and rv.agendada_para <= current_date
    order by rv.erro_id, rv.ordem
  ) x;

  if coalesce(cardinality(v_revisao_ids), 0) = 0 then
    raise exception 'Nenhuma revisao pendente para hoje';
  end if;

  -- DISTINCT ainda necessário para o caso ENTRE erros diferentes: se o
  -- aluno errou a MESMA questão em dois erros distintos (dias diferentes,
  -- antes de revisar o primeiro), cada erro contribui seu próprio marco
  -- (um por erro_id, pela regra acima) mas os dois marcos apontam para a
  -- mesma questão — ela entra uma única vez na sessão, e
  -- concluir_revisao() fecha os dois marcos a partir dessa única resposta.
  -- Isso é diferente da independência DENTRO do mesmo erro (resolvida
  -- acima pelo distinct on) — este DISTINCT nunca colapsa ordem 1/2/3 do
  -- mesmo erro, porque a seleção acima já garante no máximo 1 linha por
  -- erro_id.
  select array_agg(distinct eu.questao_id)
  into v_questao_ids
  from public.revisoes rv
  join public.erros_usuarios eu on eu.id = rv.erro_id
  where rv.id = any(v_revisao_ids);

  v_total := coalesce(cardinality(v_questao_ids), 0);
  if v_total = 0 then
    raise exception 'Nenhuma questao associada as revisoes pendentes';
  end if;

  -- Alias "se" explícito na tabela-alvo para poder qualificar a
  -- RETURNING abaixo (se.id, se.status) e remover a ambiguidade com a
  -- variável de saída "status" da RETURNS TABLE (mesmo padrão do hotfix
  -- de 20261004200000_corrigir_ambiguidade_sessao_avulsa.sql).
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

revoke all on function public.iniciar_revisao() from public, anon;
grant execute on function public.iniciar_revisao() to authenticated;

create or replace function public.concluir_revisao(p_sessao_id bigint)
returns table (
  sessao_id bigint,
  status text,
  revisoes_concluidas integer
)
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_usuario_id uuid := auth.uid();
  v_sessao public.sessoes_estudo%rowtype;
  v_concluidas integer := 0;
  v_revisao_id bigint;
  v_questao_id bigint;
  v_acertou boolean;
begin
  if v_usuario_id is null then
    raise exception 'Usuario nao autenticado';
  end if;

  select s.* into v_sessao
  from public.sessoes_estudo s
  where s.id = p_sessao_id
    and s.usuario_id = v_usuario_id
    and s.nivel_meta = 'revisao'
  for update;

  if not found then
    raise exception 'Sessao de revisao nao encontrada';
  end if;

  -- Idempotente: conclusão repetida (retry/duplo clique) nunca reabre nem
  -- reprocessa — só confirma de novo quantas das revisões desta sessão já
  -- estão concluídas. Alias "rv" explícito: sem ele, "status" ambíguava
  -- com a variável de saída "status" da RETURNS TABLE (hotfix desta
  -- migration).
  if v_sessao.status = 'concluida' then
    select count(*) into v_concluidas
    from public.revisoes rv
    where rv.id = any(v_sessao.revisao_ids) and rv.status = 'concluida';

    return query select v_sessao.id, v_sessao.status, v_concluidas;
    return;
  end if;

  -- Cobertura REAL por questão — nunca só a contagem agregada: respostas
  -- duplicadas da MESMA questão (retry de rede, chamada direta repetida)
  -- inflariam um COUNT(*) simples e mascarariam outra questão planejada
  -- nunca respondida. Falha se existir qualquer questão planejada sem
  -- nenhuma resposta do próprio usuário nesta sessão.
  if exists (
    select 1
    from public.sessao_questoes_planejadas sq
    where sq.sessao_id = p_sessao_id
      and not exists (
        select 1
        from public.respostas_usuarios ru
        where ru.sessao_id = sq.sessao_id
          and ru.usuario_id = v_usuario_id
          and ru.questao_id = sq.questao_id
      )
  ) then
    raise exception 'Responda todas as questoes planejadas antes de concluir a revisao';
  end if;

  if v_sessao.revisao_ids is null or cardinality(v_sessao.revisao_ids) = 0 then
    raise exception 'Sessao de revisao sem revisoes associadas';
  end if;

  foreach v_revisao_id in array v_sessao.revisao_ids loop
    -- Reiniciadas a NULL em TODA iteração: um SELECT INTO sem match não
    -- limpa a variável em plpgsql, então sem este reset uma revisão sem
    -- correspondência herdaria silenciosamente questao_id/acertou da
    -- iteração ANTERIOR do loop (bug real identificado na auditoria
    -- pré-apply — nunca deveria acontecer após a checagem de cobertura
    -- acima, mas aborta em vez de supor).
    v_questao_id := null;
    v_acertou := null;

    select eu.questao_id into v_questao_id
    from public.revisoes rv
    join public.erros_usuarios eu on eu.id = rv.erro_id
    where rv.id = v_revisao_id;

    if v_questao_id is null then
      raise exception 'Revisao % sem questao associada (erro_id invalido)', v_revisao_id;
    end if;

    select ru.acertou into v_acertou
    from public.respostas_usuarios ru
    where ru.sessao_id = p_sessao_id
      and ru.usuario_id = v_usuario_id
      and ru.questao_id = v_questao_id
    order by ru.respondida_em desc
    limit 1;

    if v_acertou is null then
      raise exception 'Questao % da revisao % sem resposta registrada nesta sessao', v_questao_id, v_revisao_id;
    end if;

    -- Alias "rv" explícito: a cláusula SET nunca é ambígua (sintaxe fixa
    -- do UPDATE, resolve sempre contra a tabela-alvo), mas a WHERE usava
    -- "status" sem qualificação, ambíguo com a variável de saída "status"
    -- (hotfix desta migration).
    update public.revisoes as rv
    set status = 'concluida',
        concluida_em = now(),
        desempenho_pos_revisao = case when v_acertou then 1 else 0 end
    where rv.id = v_revisao_id
      and rv.usuario_id = v_usuario_id
      and rv.status = 'pendente';

    if found then
      v_concluidas := v_concluidas + 1;
    end if;
  end loop;

  -- Sem alias aqui: a WHERE só usa id/usuario_id (nenhum dos dois bate
  -- com sessao_id/status/revisoes_concluidas), nunca foi ambígua.
  update public.sessoes_estudo
  set status = 'concluida', fim_em = now()
  where id = p_sessao_id and usuario_id = v_usuario_id;

  return query select p_sessao_id, 'concluida'::text, v_concluidas;
end;
$function$;

revoke all on function public.concluir_revisao(bigint) from public, anon;
grant execute on function public.concluir_revisao(bigint) to authenticated;
