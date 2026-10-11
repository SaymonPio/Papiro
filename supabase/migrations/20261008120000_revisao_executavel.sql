-- PAPIRO — BETA 1 — Revisão executável.
--
-- Até aqui, public.revisoes só existia como DADO (criado automaticamente por
-- registrar_resposta a cada resposta errada, 3 linhas por erro — ordem 1/2/3,
-- intervalo_dias 1/7/30, agendada_para = hoje+esse intervalo — ver
-- supabase/funcoes_curso_ativo.sql) e como EXIBIÇÃO (painel, cronograma,
-- caderno de erros, via revisoes_do_curso_ativo). Não existia nenhuma RPC que
-- permitisse ao aluno de fato executar uma revisão — só leitura e um UPDATE
-- de 4 colunas liberado pela RLS (supabase/erros_revisoes_policies.sql), sem
-- nenhuma validação atômica de "todas as questões respondidas"/"não concluir
-- duas vezes".
--
-- Esta migration NÃO toca em registrar_resposta nem em classificar_erro — o
-- motor de perguntas/respostas/diagnóstico é 100% reaproveitado como já
-- está. Se o aluno errar de novo uma questão DURANTE uma revisão,
-- registrar_resposta já cria um novo erro + um novo ciclo de 3 revisões,
-- exatamente como já fazia antes; nenhuma mudança de comportamento ali.
--
-- Desenho (ver auditoria completa apresentada antes desta migration):
--   1) sessoes_estudo ganha nivel_meta='revisao' (mesmo padrão de
--      'personalizada', adicionado antes em
--      supabase/sessao_personalizada_curso.sql) e uma coluna nova
--      revisao_ids bigint[] — só preenchida para sessões de revisão, guarda
--      EXATAMENTE quais linhas de public.revisoes esta sessão vai concluir
--      (decidido no início, nunca re-derivado na conclusão — evita que uma
--      revisão que ficou pendente DEPOIS do início seja fechada por engano).
--   2) iniciar_revisao(): idêntica em espírito a
--      iniciar_sessao_questoes_avulsa (idempotente — recupera sessão
--      nivel_meta='revisao' em_andamento antes de criar nova; valida curso
--      ativo pela MESMA cadeia de revisoes_do_curso_ativo). Seleciona as
--      revisões pendentes e vencidas hoje (status='pendente' and
--      agendada_para<=current_date) do curso ativo, mas NO MÁXIMO UM marco
--      por erro_id (o mais antigo vencido — distinct on erro_id order by
--      ordem): se ordem 1/2/3 do mesmo erro estiverem todas vencidas ao
--      mesmo tempo, esta sessão consome só a mais antiga; as demais
--      continuam pendentes e voltam a aparecer numa próxima chamada
--      (decisão confirmada após a auditoria pré-apply — preserva a
--      independência dos 3 marcos em vez de quitar todos de uma vez).
--      Monta a lista de questões (DISTINCT — agora só relevante ENTRE
--      erros diferentes que apontam para a mesma questão; dentro do mesmo
--      erro já não há mais de 1 marco selecionado) e persiste em
--      sessao_questoes_planejadas (tabela já existente, sem nenhuma coluna
--      nova nela).
--   3) concluir_revisao(p_sessao_id): exige todas as questões planejadas
--      respondidas; para cada revisao_id da sessão, localiza a resposta
--      correspondente (pela questão original do erro) e marca
--      status='concluida', concluida_em=now(),
--      desempenho_pos_revisao=1/0. Idempotente: chamar de novo numa sessão
--      já concluída não reabre nem reprocessa nada, só devolve o mesmo
--      resultado.
--
-- Rollback (documentado, não executado por esta migration):
--   drop function if exists public.concluir_revisao(bigint);
--   drop function if exists public.iniciar_revisao();
--   alter table public.sessoes_estudo drop column if exists revisao_ids;
--   alter table public.sessoes_estudo drop constraint if exists sessoes_estudo_nivel_meta_check;
--   alter table public.sessoes_estudo add constraint sessoes_estudo_nivel_meta_check
--     check (nivel_meta in ('minima', 'normal', 'ideal', 'personalizada'));
--   (nenhuma linha de dado é alterada por este rollback — sessões de revisão
--   já criadas ficariam com nivel_meta inválido para o CHECK restaurado;
--   por isso o rollback só deve ser aplicado se nenhuma sessão de revisão
--   real tiver sido criada ainda, ou após migrar/apagar essas linhas.)
--
-- CORREÇÃO PRÉ-APPLY (auditoria antes do primeiro db push — este arquivo
-- nunca chegou a ser aplicado, por isso é corrigido no próprio lugar, não
-- com uma segunda migration por cima):
--   a) concluir_revisao validava só COUNT(*) agregado de respostas vs.
--      planejadas — respostas duplicadas da MESMA questão podiam mascarar
--      outra questão planejada nunca respondida. Trocado por um NOT
--      EXISTS de cobertura real (cada questao_id planejada precisa de ao
--      menos 1 resposta do próprio usuário nesta sessão).
--   b) no loop de conclusão, v_questao_id/v_acertou podiam reter o valor
--      da iteração ANTERIOR quando uma busca não encontrava linha (SELECT
--      INTO sem match não limpa a variável em plpgsql) — uma revisão
--      poderia ser concluída com desempenho_pos_revisao de outra questão.
--      Agora reiniciadas a null a cada iteração, com exception explícita
--      se alguma das duas buscas não encontrar nada.
--   c) iniciar_revisao serializava só a RECUPERAÇÃO de uma sessão já
--      existente (FOR UPDATE numa linha que só existe depois de criada) —
--      duas chamadas concorrentes sem sessão prévia podiam criar duas
--      sessões de revisão. Agora um pg_advisory_xact_lock (chave
--      usuario_id+matricula_id+'revisao', escopo da própria transação do
--      RPC) serializa a abertura inteira antes da primeira leitura.
--   d) decisão de produto confirmada (opção B, entre A/B/C apresentadas):
--      quando ordem 1/2/3 do MESMO erro estão todas vencidas ao mesmo
--      tempo, esta sessão consome só UM marco (o mais antigo) — os demais
--      continuam pendentes para uma próxima sessão, preservando a
--      independência real dos 3 marcos em vez de quitar todos de uma
--      única resposta. Implementado na seleção de iniciar_revisao via
--      "distinct on (rv.erro_id) ... order by rv.erro_id, rv.ordem".

-- ----------------------------------------------------------------------------
-- 1) Schema aditivo em sessoes_estudo.
-- ----------------------------------------------------------------------------
alter table public.sessoes_estudo
  drop constraint if exists sessoes_estudo_nivel_meta_check;
alter table public.sessoes_estudo
  add constraint sessoes_estudo_nivel_meta_check
  check (nivel_meta in ('minima', 'normal', 'ideal', 'personalizada', 'revisao'));

alter table public.sessoes_estudo
  add column if not exists revisao_ids bigint[];

-- ----------------------------------------------------------------------------
-- iniciar_revisao(): único ponto de entrada para abrir/recuperar a sessão de
-- revisão do curso ativo. Nunca recebe nenhum id do cliente — toda a seleção
-- (quais revisões, quais questões) é resolvida no servidor a partir de
-- auth.uid() + perfis.curso_ativo_id + matriculas, mesmo padrão de
-- iniciar_pratica_unidade/iniciar_missao_final.
-- ----------------------------------------------------------------------------
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

  insert into public.sessoes_estudo (
    usuario_id, matricula_id, nivel_meta, status,
    inicio_em, minutos_revisao, questoes_planejadas, revisao_ids
  ) values (
    v_usuario_id, v_matricula_id, 'revisao', 'em_andamento',
    clock_timestamp(), 0, v_total, v_revisao_ids
  ) returning id, status into v_sessao_id, v_status;

  insert into public.sessao_questoes_planejadas (sessao_id, questao_id, ordem)
  select v_sessao_id, x.questao_id, x.ordem::integer
  from unnest(v_questao_ids) with ordinality x(questao_id, ordem);

  return query select v_sessao_id, v_status, v_questao_ids, false;
end;
$function$;

revoke all on function public.iniciar_revisao() from public, anon;
grant execute on function public.iniciar_revisao() to authenticated;

-- ----------------------------------------------------------------------------
-- concluir_revisao(p_sessao_id): operação atômica e idempotente. Exige que
-- TODAS as questões planejadas já tenham resposta registrada (mesma regra de
-- concluir_pratica_unidade/concluir_missao_final). Nunca recebe resultado
-- calculado pelo cliente — acertou/errou é sempre relido de
-- respostas_usuarios.
-- ----------------------------------------------------------------------------
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
  -- estão concluídas.
  if v_sessao.status = 'concluida' then
    select count(*) into v_concluidas
    from public.revisoes
    where id = any(v_sessao.revisao_ids) and status = 'concluida';

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

    update public.revisoes
    set status = 'concluida',
        concluida_em = now(),
        desempenho_pos_revisao = case when v_acertou then 1 else 0 end
    where id = v_revisao_id
      and usuario_id = v_usuario_id
      and status = 'pendente';

    if found then
      v_concluidas := v_concluidas + 1;
    end if;
  end loop;

  update public.sessoes_estudo
  set status = 'concluida', fim_em = now()
  where id = p_sessao_id and usuario_id = v_usuario_id;

  return query select p_sessao_id, 'concluida'::text, v_concluidas;
end;
$function$;

revoke all on function public.concluir_revisao(bigint) from public, anon;
grant execute on function public.concluir_revisao(bigint) to authenticated;
