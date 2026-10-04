-- Fase 1 do sistema global de horas líquidas de estudo (Papiro).
--
-- Cria a fundação server-side: `sessoes_tempo` (uma linha por período
-- contínuo de estudo medido por heartbeat, servidor como única fonte de
-- tempo) + `sessoes_tempo_dias` (distribuição do tempo de cada sessão pelos
-- dias locais — America/Sao_Paulo — que ela efetivamente ocupou, resolvendo
-- o caso de sessão que atravessa meia-noite) + 8 RPCs SECURITY DEFINER.
--
-- Escopo desta migration: 100% aditiva.
--   - Nenhuma tabela/coluna/RPC existente é alterada.
--   - Nenhuma integração de frontend.
--   - `progresso_diario_estudo` (agregado pré-computado por usuário,
--     independente de sessão) NÃO é criada nesta fase. `sessoes_tempo_dias`
--     não é esse agregado — é a distribuição por dia de CADA sessão
--     individual (granularidade sessão×dia, não usuário×dia); resumo/
--     histórico somam sobre ela em tempo de leitura, não é uma segunda
--     fonte independente de progresso.
--
-- Convenções replicadas do schema existente (confirmadas lendo
-- iniciar_ou_recuperar_missao_diaria, registrar_resposta e
-- estatisticas_do_curso_ativo antes de escrever este arquivo):
--   - LANGUAGE plpgsql, SECURITY DEFINER, SET search_path TO ''
--     (toda referência a tabela é sempre schema-qualificada: public.*).
--   - usuario_id SEMPRE de auth.uid() — nunca de parâmetro do cliente.
--   - RLS habilitada, mas sem INSERT/UPDATE/DELETE para o cliente — toda
--     escrita passa por RPC.
--   - "dia" de negócio sempre em America/Sao_Paulo (mesmo critério já usado
--     pelo DEFAULT de missoes.data_missao), nunca current_date puro.
--
-- Nomenclatura: os nomes de coluna seguem exatamente a lista fechada pedida
-- para esta fase (incluindo a mistura created_at/updated_at em inglês com
-- os demais campos em português, como iniciado_em/ultimo_heartbeat_em) — é
-- uma mistura deliberada da especificação desta funcionalidade, não um erro
-- de padronização; o restante do schema usa criado_em/atualizado_em.

-- ============================================================================
-- 1. TABELA sessoes_tempo
-- ============================================================================

create table public.sessoes_tempo (
  id bigint generated always as identity primary key,
  usuario_id uuid not null references auth.users (id) on delete cascade,
  matricula_id uuid not null references public.matriculas (id) on delete cascade,

  -- origem: o FLUXO DO PRODUTO pelo qual o estudo foi iniciado (de onde o
  -- aluno veio). tipo_atividade (abaixo): a MODALIDADE de estudo realizada
  -- nessa sessão (o que o aluno efetivamente fez). São duas dimensões
  -- independentes, não mutuamente substituíveis nem infereis uma da outra
  -- — ex.: origem='cronograma' pode ter tipo_atividade='teoria' OU
  -- 'questoes'; origem='estudo_livre' pode ter qualquer tipo_atividade,
  -- inclusive 'revisao', que não tem origem própria dedicada.
  origem text not null check (origem in ('cronograma', 'estudo_livre', 'questoes')),
  tipo_atividade text not null check (tipo_atividade in ('teoria', 'questoes', 'leitura', 'revisao')),
  status text not null default 'ativa' check (status in ('ativa', 'pausada', 'encerrada')),
  segundos_liquidos integer not null default 0 check (segundos_liquidos >= 0),

  iniciado_em timestamptz not null default now(),
  -- ultimo_heartbeat_em: instante REAL do último heartbeat/liveness
  -- recebido pelo servidor — usado EXCLUSIVAMENTE para decidir se houve gap
  -- de inatividade (>60s). Nunca usado como base de contabilização.
  ultimo_heartbeat_em timestamptz not null default now(),
  -- contabilizado_ate_em: instante até onde o tempo já foi efetivamente
  -- convertido em segundos_liquidos inteiros — é a baseline de todo cálculo
  -- de crédito, e carrega o resíduo subsegundo entre heartbeats normais.
  -- Mantida separada de ultimo_heartbeat_em de propósito: usar o mesmo
  -- campo para as duas responsabilidades (detectar liveness E guardar
  -- resíduo de contabilização) foi a causa de um bug de rounding em
  -- iterações anteriores desta migration.
  contabilizado_ate_em timestamptz not null default now(),
  pausado_em timestamptz,
  encerrado_em timestamptz,

  -- Contextos opcionais: nenhum é NOT NULL, porque estudo livre/questões
  -- soltas não têm missão, e nem toda origem preenche todos os campos.
  missao_id uuid references public.missoes (id) on delete set null,
  sessao_estudo_id bigint references public.sessoes_estudo (id) on delete set null,
  curso_conteudo_id bigint references public.curso_conteudos (id) on delete set null,
  materia_id bigint references public.materias (id) on delete set null,
  assunto_id bigint references public.assuntos (id) on delete set null,
  unidade_pedagogica_id uuid references public.unidades_pedagogicas (id) on delete set null,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint sessoes_tempo_pausado_em_coerente check (
    (status = 'pausada' and pausado_em is not null) or (status <> 'pausada')
  ),
  constraint sessoes_tempo_encerrado_em_coerente check (
    (status = 'encerrada' and encerrado_em is not null) or (status <> 'encerrada')
  )
);

comment on table public.sessoes_tempo is
  'Fase 1 do sistema de horas líquidas: 1 linha por período contínuo de estudo medido por heartbeat server-side. Fonte única da verdade sobre o total da sessão — a distribuição por dia local fica em sessoes_tempo_dias.';

-- Garante, no nível de banco (não só de RPC), no máximo UMA sessão aberta
-- (ativa OU pausada) por usuário — cobre multi-aba e corrida de criação
-- concorrente: a 2ª tentativa simultânea de INSERT recebe unique_violation,
-- tratado explicitamente em iniciar_sessao_tempo.
create unique index sessoes_tempo_usuario_aberta_unq
  on public.sessoes_tempo (usuario_id)
  where status in ('ativa', 'pausada');

-- Índices de consulta (padrão já usado em sessoes_usuario_data_idx /
-- respostas_usuario_data_idx): usuário+tempo para heartbeat/histórico,
-- matrícula+tempo para relatórios por curso, usuário+status para achar a
-- sessão aberta rapidamente.
create index sessoes_tempo_usuario_iniciado_idx
  on public.sessoes_tempo (usuario_id, iniciado_em desc);

create index sessoes_tempo_matricula_iniciado_idx
  on public.sessoes_tempo (matricula_id, iniciado_em desc);

create index sessoes_tempo_usuario_status_idx
  on public.sessoes_tempo (usuario_id, status);

alter table public.sessoes_tempo enable row level security;

-- Somente leitura das próprias linhas. Sem policy de INSERT/UPDATE/DELETE
-- para nenhum papel de cliente — toda escrita é via RPC SECURITY DEFINER
-- (que roda com privilégio do dono da função e contorna RLS internamente,
-- mesmo padrão já usado por respostas_usuarios/missoes neste projeto).
create policy "Aluno visualiza as proprias sessoes de tempo"
  on public.sessoes_tempo
  for select
  using (usuario_id = auth.uid());

-- ============================================================================
-- 2. TABELA sessoes_tempo_dias
-- ============================================================================
--
-- Resolve o caso de sessão que atravessa meia-noite (America/Sao_Paulo):
-- uma linha de sessoes_tempo guarda só iniciado_em/ultimo_heartbeat_em/
-- encerrado_em/segundos_liquidos, que não bastam para saber quantos
-- segundos pertencem a CADA dia local quando a sessão cruza 00:00 — agrupar
-- só por iniciado_em ou encerrado_em jogaria o tempo todo num único dia
-- errado nesse caso.
--
-- Esta tabela representa a DISTRIBUIÇÃO DA SESSÃO POR DIA (granularidade
-- sessão×dia) — não é um agregado independente de progresso do usuário.
-- Cada heartbeat/pausa/encerramento credita o mesmo delta aplicado em
-- sessoes_tempo.segundos_liquidos, mas dividido pelos dias locais que a
-- janela [ultimo_heartbeat_em, agora) efetivamente atravessou.

create table public.sessoes_tempo_dias (
  id bigint generated always as identity primary key,
  sessao_tempo_id bigint not null references public.sessoes_tempo (id) on delete cascade,
  usuario_id uuid not null references auth.users (id) on delete cascade,
  matricula_id uuid not null references public.matriculas (id) on delete cascade,
  dia date not null,
  segundos_liquidos integer not null default 0 check (segundos_liquidos >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  -- No máximo uma linha por sessão por dia — cada heartbeat faz upsert
  -- nesta constraint, nunca insere uma segunda linha para o mesmo par.
  constraint sessoes_tempo_dias_sessao_dia_unq unique (sessao_tempo_id, dia)
);

comment on table public.sessoes_tempo_dias is
  'Distribuição por dia local (America/Sao_Paulo) do tempo líquido de cada sessoes_tempo — resolve sessões que atravessam meia-noite. SUM(segundos_liquidos) por sessao_tempo_id deve ser sempre igual a sessoes_tempo.segundos_liquidos.';

create index sessoes_tempo_dias_usuario_dia_idx
  on public.sessoes_tempo_dias (usuario_id, dia);

create index sessoes_tempo_dias_matricula_dia_idx
  on public.sessoes_tempo_dias (matricula_id, dia);

alter table public.sessoes_tempo_dias enable row level security;

-- Mesmo padrão seguro de sessoes_tempo: só SELECT do próprio dono, sem
-- escrita direta pelo cliente — mutations só pelas RPCs SECURITY DEFINER
-- (via a função interna _distribuir_segundos_por_dia, chamada de dentro de
-- heartbeat/pausar/encerrar).
create policy "Aluno visualiza os proprios dias de sessao de tempo"
  on public.sessoes_tempo_dias
  for select
  using (usuario_id = auth.uid());

-- ============================================================================
-- 3. FUNÇÃO INTERNA: divisão do delta por dia local
-- ============================================================================
--
-- NÃO é uma RPC pública — sem grant para authenticated/anon/public (ver
-- seção de grants). Só é alcançável de dentro de outra função SECURITY
-- DEFINER já autenticada (heartbeat/pausar/encerrar), que já validou que
-- p_usuario_id/p_matricula_id/p_sessao_tempo_id pertencem ao chamador. Se
-- fosse chamável diretamente pelo cliente, um usuário malicioso poderia
-- creditar segundos para qualquer sessão/usuário — por isso o revoke
-- explícito é obrigatório, não opcional.
--
-- Divide [p_inicio, p_fim) em fatias por dia local (America/Sao_Paulo) e
-- faz upsert de cada fatia em sessoes_tempo_dias. Genérico: funciona para
-- qualquer duração, não assume que o intervalo cruza no máximo um dia —
-- embora na prática o teto de 60s do heartbeat torne isso raro além de 2
-- dias, a função não depende dessa hipótese.
--
-- IMPORTANTE sobre precisão: NÃO arredondamos/truncamos cada fatia de
-- forma independente (floor(fatia1) + floor(fatia2) pode somar MENOS que
-- floor(total) quando o instante de corte cai num ponto fracionário de
-- segundo — ex.: p_inicio=23:59:30.35, +60s, cruzando a meia-noite: a
-- fatia do dia 1 dura 29.65s e a do dia 2 dura 30.35s; floor() em cada uma
-- separadamente daria 29+30=59, perdendo 1s do total). Em vez disso,
-- calculamos o total de segundos INTEIROS uma única vez (v_total_segundos)
-- e vamos descontando desse orçamento único conforme cada dia é creditado
-- — isso garante, por construção, que a soma das fatias é sempre
-- exatamente igual ao total, nunca menos.
--
-- Cada instante usado para achar a meia-noite local é construído via
-- `timezone('America/Sao_Paulo', timestamptz)` / `date AT TIME ZONE
-- 'America/Sao_Paulo'` — a forma explícita e documentada do Postgres para
-- converter entre timestamptz e hora de parede numa zona específica; não
-- depende em nenhum ponto do `timezone` da sessão/conexão atual (diferente
-- de usar CURRENT_DATE/NOW() sem conversão, ou de um cast direto
-- timestamptz::date, que ambos usariam a zona da sessão implicitamente).
create or replace function public._distribuir_segundos_por_dia(
  p_sessao_tempo_id bigint,
  p_usuario_id uuid,
  p_matricula_id uuid,
  p_inicio timestamptz,
  p_fim timestamptz
)
returns void
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_total_segundos integer;
  v_restante integer;
  v_cursor timestamptz := p_inicio;
  v_dia date;
  v_fim_dia_local timestamptz;
  v_segundos_ate_meia_noite integer;
  v_segundos_fatia integer;
begin
  v_total_segundos := greatest(0, floor(extract(epoch from (p_fim - p_inicio)))::integer);
  if v_total_segundos <= 0 then
    return;
  end if;

  v_restante := v_total_segundos;

  while v_restante > 0 loop
    v_dia := (timezone('America/Sao_Paulo', v_cursor))::date;
    -- Meia-noite local do dia SEGUINTE ao do cursor, convertida de volta
    -- para timestamptz (instante UTC equivalente) — limite superior
    -- (exclusivo) da fatia do dia atual. `(date)::timestamp` é uma
    -- reinterpretação pura (sem zona envolvida: só agrega 00:00:00); o
    -- `AT TIME ZONE` seguinte é que converte essa hora de parede local
    -- para o instante absoluto (timestamptz) correto, de forma explícita.
    v_fim_dia_local := (v_dia + 1)::timestamp at time zone 'America/Sao_Paulo';

    -- Segundos INTEIROS entre o cursor e a meia-noite local seguinte.
    v_segundos_ate_meia_noite := greatest(0, floor(extract(epoch from (v_fim_dia_local - v_cursor)))::integer);
    v_segundos_fatia := least(v_restante, v_segundos_ate_meia_noite);

    if v_segundos_fatia > 0 then
      insert into public.sessoes_tempo_dias (sessao_tempo_id, usuario_id, matricula_id, dia, segundos_liquidos)
      values (p_sessao_tempo_id, p_usuario_id, p_matricula_id, v_dia, v_segundos_fatia)
      on conflict on constraint sessoes_tempo_dias_sessao_dia_unq
      do update set
        segundos_liquidos = sessoes_tempo_dias.segundos_liquidos + excluded.segundos_liquidos,
        updated_at = now();

      v_restante := v_restante - v_segundos_fatia;
      v_cursor := v_cursor + make_interval(secs => v_segundos_fatia);
    else
      -- Resta menos de 1 segundo inteiro antes da meia-noite local: esse
      -- resquício fracionário não forma um segundo completo em nenhum dos
      -- dois dias. Avança o cursor direto para a meia-noite sem creditar
      -- nada (v_restante só é decrementado quando um segundo inteiro é
      -- efetivamente atribuído a algum dia, então o total nunca diverge) —
      -- e isso garante que o cursor sempre avança, evitando loop infinito.
      v_cursor := v_fim_dia_local;
    end if;
  end loop;
end;
$function$;

-- ============================================================================
-- 4. RPCs
-- ============================================================================

-- ----------------------------------------------------------------------------
-- iniciar_sessao_tempo: cria (ou recupera, se idêntica) a sessão de tempo
-- ativa do usuário. Nunca encerra outra sessão aberta silenciosamente —
-- se já existir uma sessão aberta com contexto DIFERENTE (incluindo
-- tipo_atividade — ex.: Português/Crase/teoria não é a mesma atividade que
-- Português/Crase/questoes), retorna conflito. Não credita segundos
-- (segundos_liquidos começa em 0), então não toca em sessoes_tempo_dias.
--
-- Uma sessão representa um período contínuo com contexto ESTÁVEL: não há
-- (e não deve haver) nenhuma RPC para trocar matéria/conteúdo/unidade/
-- origem/tipo_atividade numa sessão já ativa. Se o aluno mudar de
-- conteúdo/atividade, o fluxo esperado é encerrar a sessão atual e iniciar
-- uma nova — preserva a atribuição histórica corretamente sem precisar de
-- segmentos nesta primeira versão.
-- ----------------------------------------------------------------------------
create or replace function public.iniciar_sessao_tempo(
  p_origem text,
  p_matricula_id uuid,
  p_tipo_atividade text,
  p_missao_id uuid default null,
  p_sessao_estudo_id bigint default null,
  p_curso_conteudo_id bigint default null,
  p_materia_id bigint default null,
  p_assunto_id bigint default null,
  p_unidade_pedagogica_id uuid default null
)
returns table (
  id bigint,
  status text,
  origem text,
  tipo_atividade text,
  segundos_liquidos integer,
  iniciado_em timestamptz,
  ultimo_heartbeat_em timestamptz,
  ja_existente boolean
)
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_usuario_id uuid := auth.uid();
  v_existente public.sessoes_tempo%rowtype;
  v_nova_id bigint;
  v_agora timestamptz := clock_timestamp();
begin
  if v_usuario_id is null then
    raise exception 'Usuario nao autenticado';
  end if;

  if p_origem not in ('cronograma', 'estudo_livre', 'questoes') then
    raise exception 'Origem invalida: %', p_origem;
  end if;

  if p_tipo_atividade not in ('teoria', 'questoes', 'leitura', 'revisao') then
    raise exception 'Tipo de atividade invalido: %', p_tipo_atividade;
  end if;

  -- Matrícula: do próprio usuário autenticado, e ativa. Nunca confiar em
  -- p_matricula_id sem validar o dono.
  if not exists (
    select 1 from public.matriculas m
    where m.id = p_matricula_id
      and m.usuario_id = v_usuario_id
      and m.status = 'ativa'
  ) then
    raise exception 'Matricula invalida ou inativa';
  end if;

  -- Cada contexto opcional, quando informado, precisa existir e (quando
  -- aplicável) pertencer ao usuário — nunca presumir que o cliente mandou
  -- IDs corretos.
  if p_missao_id is not null and not exists (
    select 1 from public.missoes ms
    join public.matriculas m on m.id = ms.matricula_id
    where ms.id = p_missao_id and m.usuario_id = v_usuario_id
  ) then
    raise exception 'Missao invalida';
  end if;

  if p_sessao_estudo_id is not null and not exists (
    select 1 from public.sessoes_estudo se
    where se.id = p_sessao_estudo_id and se.usuario_id = v_usuario_id
  ) then
    raise exception 'Sessao de questoes invalida';
  end if;

  if p_curso_conteudo_id is not null and not exists (
    select 1 from public.curso_conteudos cc where cc.id = p_curso_conteudo_id
  ) then
    raise exception 'Conteudo invalido';
  end if;

  if p_materia_id is not null and not exists (
    select 1 from public.materias mt where mt.id = p_materia_id
  ) then
    raise exception 'Materia invalida';
  end if;

  if p_assunto_id is not null and not exists (
    select 1 from public.assuntos a where a.id = p_assunto_id
  ) then
    raise exception 'Assunto invalido';
  end if;

  if p_unidade_pedagogica_id is not null and not exists (
    select 1 from public.unidades_pedagogicas up where up.id = p_unidade_pedagogica_id
  ) then
    raise exception 'Unidade pedagogica invalida';
  end if;

  -- Tentativa otimista de INSERT: o índice único parcial é a fonte real de
  -- verdade contra corrida (duas abas/requisições quase simultâneas). Um
  -- SELECT de pré-checagem sozinho teria uma janela de corrida (TOCTOU);
  -- aqui, se perder a corrida, cai no EXCEPTION abaixo.
  begin
    -- iniciado_em, ultimo_heartbeat_em e contabilizado_ate_em partem do
    -- mesmo instante capturado uma única vez (v_agora) — nunca de 3
    -- chamadas separadas a now()/clock_timestamp().
    insert into public.sessoes_tempo (
      usuario_id, matricula_id, origem, tipo_atividade, status,
      iniciado_em, ultimo_heartbeat_em, contabilizado_ate_em,
      missao_id, sessao_estudo_id, curso_conteudo_id, materia_id, assunto_id, unidade_pedagogica_id
    ) values (
      v_usuario_id, p_matricula_id, p_origem, p_tipo_atividade, 'ativa',
      v_agora, v_agora, v_agora,
      p_missao_id, p_sessao_estudo_id, p_curso_conteudo_id, p_materia_id, p_assunto_id, p_unidade_pedagogica_id
    )
    returning sessoes_tempo.id into v_nova_id;

    return query
    select st.id, st.status, st.origem, st.tipo_atividade, st.segundos_liquidos, st.iniciado_em, st.ultimo_heartbeat_em, false
    from public.sessoes_tempo st
    where st.id = v_nova_id;
    return;
  exception when unique_violation then
    -- Já existe sessão aberta (ativa ou pausada) para este usuário.
    select st.* into v_existente
    from public.sessoes_tempo st
    where st.usuario_id = v_usuario_id
      and st.status in ('ativa', 'pausada')
    limit 1;

    -- Idempotente SE o pedido for exatamente o mesmo contexto da sessão já
    -- aberta — devolve-a sem duplicar nem encerrar nada. tipo_atividade faz
    -- parte da identidade contextual: Português/Crase/teoria NÃO é a mesma
    -- atividade que Português/Crase/questoes, mesmo com todo o resto igual.
    if v_existente.origem = p_origem
      and v_existente.tipo_atividade = p_tipo_atividade
      and v_existente.missao_id is not distinct from p_missao_id
      and v_existente.sessao_estudo_id is not distinct from p_sessao_estudo_id
      and v_existente.curso_conteudo_id is not distinct from p_curso_conteudo_id
      and v_existente.materia_id is not distinct from p_materia_id
      and v_existente.assunto_id is not distinct from p_assunto_id
      and v_existente.unidade_pedagogica_id is not distinct from p_unidade_pedagogica_id
    then
      return query
      select v_existente.id, v_existente.status, v_existente.origem, v_existente.tipo_atividade,
             v_existente.segundos_liquidos, v_existente.iniciado_em,
             v_existente.ultimo_heartbeat_em, true;
      return;
    end if;

    -- Contexto diferente (incluindo só tipo_atividade diferente): conflito
    -- explícito. Nunca modificamos a sessão existente silenciosamente —
    -- não há RPC para trocar tipo_atividade/origem/contexto numa sessão já
    -- ativa; o fluxo esperado é o frontend encerrar a sessão atual e
    -- iniciar uma nova quando o aluno muda de atividade/conteúdo.

    -- Contexto diferente: conflito explícito. Nunca encerramos a sessão
    -- aberta existente silenciosamente para abrir uma nova.
    raise exception 'Ja existe uma sessao de tempo aberta (id=%, status=%, origem=%) para este usuario',
      v_existente.id, v_existente.status, v_existente.origem
      using errcode = '23505';
  end;
end;
$function$;

-- ----------------------------------------------------------------------------
-- heartbeat_sessao_tempo: credita o delta desde o último heartbeat (teto de
-- 60s), só quando a sessão está ativa, distribuindo o MESMO delta por dia
-- local em sessoes_tempo_dias, na mesma transação (a função inteira roda
-- numa única transação implícita — não há BEGIN/COMMIT explícito dentro de
-- PL/pgSQL, mas isso já garante atomicidade). `for update` trava a linha —
-- dois heartbeats concorrentes da mesma sessão serializam aqui, o segundo
-- calcula seu delta a partir do ultimo_heartbeat_em já atualizado pelo
-- primeiro, nunca duplicando (nem em sessoes_tempo, nem em
-- sessoes_tempo_dias, já que a chamada de distribuição também só acontece
-- depois da trava ser obtida).
--
-- Dois caminhos distintos para não perder fração de segundo por drift
-- acumulativo (floor() de um delta sub-inteiro descartaria 0.x segundos a
-- CADA heartbeat se o resíduo nunca fosse carregado adiante):
--   - normal (delta real <= teto): credita floor(delta_real), mas grava
--     ultimo_heartbeat_em = ultimo_heartbeat_em + delta segundos inteiros
--     (não v_agora) — o resíduo fracionário fica implícito na diferença
--     entre esse valor e v_agora, e é automaticamente incorporado no
--     cálculo do PRÓXIMO heartbeat.
--   - gap (delta real > teto): credita só o teto; o resto é inatividade
--     real, descartado para sempre.
--
-- ultimo_heartbeat_em vs. contabilizado_ate_em: duas responsabilidades
-- separadas de propósito (ver comentário da coluna na tabela). A decisão
-- de "houve gap de inatividade >60s?" usa EXCLUSIVAMENTE
-- ultimo_heartbeat_em (o instante real do heartbeat anterior) — nunca
-- contabilizado_ate_em, que é só a baseline de contabilização e carrega o
-- resíduo subsegundo. Misturar as duas no mesmo campo foi a causa de um
-- bug de rounding em iteração anterior desta migration (ver histórico do
-- arquivo).
-- ----------------------------------------------------------------------------
create or replace function public.heartbeat_sessao_tempo(p_sessao_tempo_id bigint)
returns table (
  id bigint,
  status text,
  segundos_liquidos integer,
  ultimo_heartbeat_em timestamptz
)
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_usuario_id uuid := auth.uid();
  v_sessao public.sessoes_tempo%rowtype;
  v_gap_heartbeat double precision;
  v_delta_real double precision;
  v_delta integer;
  v_agora timestamptz; -- só atribuído APÓS o lock (ver comentário abaixo)
  v_inicio_creditado timestamptz;
  v_fim_creditado timestamptz;
  v_teto constant integer := 60; -- teto creditavel entre heartbeats, em segundos
begin
  if v_usuario_id is null then
    raise exception 'Usuario nao autenticado';
  end if;

  select st.* into v_sessao
  from public.sessoes_tempo st
  where st.id = p_sessao_tempo_id
    and st.usuario_id = v_usuario_id
  for update;

  if not found then
    raise exception 'Sessao de tempo invalida';
  end if;

  -- clock_timestamp() (hora real, reavaliada a cada chamada) só é lida
  -- DEPOIS de adquirir o lock — nunca now() (hora de início da transação).
  -- Se duas transações disputam a mesma sessão, a que esperou o lock pode
  -- ter now() anterior ao ultimo_heartbeat_em já gravado pela vencedora;
  -- usar now() aqui faria o timestamp salvo regredir. clock_timestamp()
  -- pós-lock garante que v_agora é sempre >= qualquer timestamp já
  -- commitado por quem segurava o lock antes.
  v_agora := clock_timestamp();

  if v_sessao.status <> 'ativa' then
    -- Heartbeat em sessão pausada/encerrada é no-op (idempotente) — nunca
    -- soma tempo fora do estado ativo, e não mexe em nenhum timestamp.
    return query
    select v_sessao.id, v_sessao.status, v_sessao.segundos_liquidos, v_sessao.ultimo_heartbeat_em;
    return;
  end if;

  -- Gap de LIVENESS: exclusivamente a partir de ultimo_heartbeat_em (o
  -- heartbeat real anterior) — decide só se houve inatividade, nunca
  -- quanto contabilizar.
  v_gap_heartbeat := extract(epoch from (v_agora - v_sessao.ultimo_heartbeat_em));

  if v_gap_heartbeat <= v_teto then
    -- Caminho NORMAL: contabilização a partir de contabilizado_ate_em (que
    -- carrega o resíduo subsegundo de heartbeats anteriores) — nunca a
    -- partir de ultimo_heartbeat_em. Por construção, com resíduo <1s e
    -- gap<=60s, v_delta nunca excede o teto aqui.
    v_delta_real := extract(epoch from (v_agora - v_sessao.contabilizado_ate_em));
    v_delta := greatest(0, floor(v_delta_real))::integer;

    if v_delta > 0 then
      v_inicio_creditado := v_sessao.contabilizado_ate_em;
      v_fim_creditado := v_inicio_creditado + make_interval(secs => v_delta);

      perform public._distribuir_segundos_por_dia(
        p_sessao_tempo_id, v_usuario_id, v_sessao.matricula_id,
        v_inicio_creditado, v_fim_creditado
      );

      update public.sessoes_tempo
      set segundos_liquidos = sessoes_tempo.segundos_liquidos + v_delta,
          contabilizado_ate_em = v_fim_creditado, -- preserva o resíduo (v_agora - v_fim_creditado) pro próximo heartbeat
          ultimo_heartbeat_em = v_agora,          -- SEMPRE atualizado: um heartbeat real chegou, independente de v_delta
          updated_at = v_agora
      where sessoes_tempo.id = p_sessao_tempo_id;
    else
      -- v_delta = 0 (resíduo ainda não completou 1s): nada a contabilizar,
      -- mas o heartbeat real ainda aconteceu — ultimo_heartbeat_em avança
      -- de qualquer forma, contabilizado_ate_em fica como estava.
      update public.sessoes_tempo
      set ultimo_heartbeat_em = v_agora,
          updated_at = v_agora
      where sessoes_tempo.id = p_sessao_tempo_id;
    end if;
  else
    -- Caminho de GAP (>60s de liveness): inatividade real (aba esquecida,
    -- suspensão, etc.). Credita só o teto, a partir de
    -- contabilizado_ate_em (preservando qualquer resíduo legítimo anterior
    -- a essa inatividade) — e descarta tudo além disso reancorando os DOIS
    -- timestamps em v_agora, para que o excedente nunca reapareça.
    v_delta := v_teto;
    v_inicio_creditado := v_sessao.contabilizado_ate_em;
    v_fim_creditado := v_inicio_creditado + make_interval(secs => v_delta);

    perform public._distribuir_segundos_por_dia(
      p_sessao_tempo_id, v_usuario_id, v_sessao.matricula_id,
      v_inicio_creditado, v_fim_creditado
    );

    update public.sessoes_tempo
    set segundos_liquidos = sessoes_tempo.segundos_liquidos + v_delta,
        contabilizado_ate_em = v_agora,
        ultimo_heartbeat_em = v_agora,
        updated_at = v_agora
    where sessoes_tempo.id = p_sessao_tempo_id;
  end if;

  return query
  select st.id, st.status, st.segundos_liquidos, st.ultimo_heartbeat_em
  from public.sessoes_tempo st
  where st.id = p_sessao_tempo_id;
end;
$function$;

-- ----------------------------------------------------------------------------
-- pausar_sessao_tempo: credita o último delta válido (mesmo teto, mesma
-- distribuição por dia), muda para pausada. Idempotente se já estiver
-- pausada.
-- ----------------------------------------------------------------------------
create or replace function public.pausar_sessao_tempo(p_sessao_tempo_id bigint)
returns table (
  id bigint,
  status text,
  segundos_liquidos integer,
  pausado_em timestamptz
)
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_usuario_id uuid := auth.uid();
  v_sessao public.sessoes_tempo%rowtype;
  v_delta integer;
  v_agora timestamptz; -- só atribuído APÓS o lock (ver heartbeat_sessao_tempo)
  v_inicio_creditado timestamptz;
  v_fim_creditado timestamptz;
  v_teto constant integer := 60;
begin
  if v_usuario_id is null then
    raise exception 'Usuario nao autenticado';
  end if;

  select st.* into v_sessao
  from public.sessoes_tempo st
  where st.id = p_sessao_tempo_id
    and st.usuario_id = v_usuario_id
  for update;

  if not found then
    raise exception 'Sessao de tempo invalida';
  end if;

  -- clock_timestamp() pós-lock, nunca now() — mesma razão documentada em
  -- heartbeat_sessao_tempo: evita que o timestamp salvo regrida sob
  -- concorrência.
  v_agora := clock_timestamp();

  if v_sessao.status = 'pausada' then
    return query
    select v_sessao.id, v_sessao.status, v_sessao.segundos_liquidos, v_sessao.pausado_em;
    return;
  end if;

  if v_sessao.status = 'encerrada' then
    raise exception 'Sessao ja encerrada';
  end if;

  -- Gap de liveness (exclusivamente via ultimo_heartbeat_em) decide só o
  -- TETO do crédito; a janela em si parte de contabilizado_ate_em — mesma
  -- separação de responsabilidades de heartbeat_sessao_tempo.
  if extract(epoch from (v_agora - v_sessao.ultimo_heartbeat_em)) <= v_teto then
    v_delta := greatest(0, floor(extract(epoch from (v_agora - v_sessao.contabilizado_ate_em)))::integer);
  else
    v_delta := v_teto;
  end if;

  if v_delta > 0 then
    -- Janela creditada: exatamente v_delta segundos a partir de
    -- contabilizado_ate_em já gravado — nunca o intervalo real inteiro.
    v_inicio_creditado := v_sessao.contabilizado_ate_em;
    v_fim_creditado := v_inicio_creditado + make_interval(secs => v_delta);

    perform public._distribuir_segundos_por_dia(
      p_sessao_tempo_id, v_usuario_id, v_sessao.matricula_id,
      v_inicio_creditado, v_fim_creditado
    );
  end if;

  -- Pausa sempre reancora os dois timestamps em v_agora — nenhum resíduo é
  -- preservado depois de pausar (comportamento conservador, pedido
  -- explicitamente: diferente do heartbeat normal, que carrega o resíduo
  -- adiante).
  update public.sessoes_tempo
  set segundos_liquidos = sessoes_tempo.segundos_liquidos + v_delta,
      status = 'pausada',
      pausado_em = v_agora,
      ultimo_heartbeat_em = v_agora,
      contabilizado_ate_em = v_agora,
      updated_at = v_agora
  where sessoes_tempo.id = p_sessao_tempo_id;

  return query
  select st.id, st.status, st.segundos_liquidos, st.pausado_em
  from public.sessoes_tempo st
  where st.id = p_sessao_tempo_id;
end;
$function$;

-- ----------------------------------------------------------------------------
-- retomar_sessao_tempo: reancora os dois timestamps (ultimo_heartbeat_em E
-- contabilizado_ate_em) em AGORA, sem NUNCA creditar tempo. Cobre dois
-- casos:
--   1. pausada -> ativa (retomada normal após pausa explícita);
--   2. ativa -> ativa (RECUPERAÇÃO/reancoragem após refresh, fechar/reabrir
--      aba, ou qualquer reconexão onde a sessão ficou "ativa" no banco mas
--      sem heartbeat real por um período — ex.: navegador fechado por
--      horas com a linha ainda status='ativa'). Sem este caso, o PRIMEIRO
--      heartbeat depois de reabrir creditaria até 60s de um período que na
--      verdade era só o navegador fechado, não estudo real.
--
-- Fluxo esperado do frontend: ao montar a tela, chamar
-- obter_sessao_tempo_aberta(); se houver sessão aberta (ativa OU pausada),
-- chamar retomar_sessao_tempo NELA antes de iniciar o heartbeat — mesmo se
-- já estiver 'ativa'. Só depois começar a mandar heartbeats. Uma sessão
-- reaberta horas depois nunca deve receber crédito automático pela
-- ausência.
--
-- Idempotente por construção: repetir a chamada (ex.: retry de rede)
-- apenas reancora de novo, sem somar tempo — na pior hipótese perde uma
-- fração mínima do intervalo entre as chamadas repetidas, o que é
-- aceitável (preferimos subcontagem mínima a contabilizar período offline
-- falso).
-- ----------------------------------------------------------------------------
create or replace function public.retomar_sessao_tempo(p_sessao_tempo_id bigint)
returns table (
  id bigint,
  status text,
  ultimo_heartbeat_em timestamptz
)
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_usuario_id uuid := auth.uid();
  v_sessao public.sessoes_tempo%rowtype;
  v_agora timestamptz; -- só atribuído APÓS o lock (ver heartbeat_sessao_tempo)
begin
  if v_usuario_id is null then
    raise exception 'Usuario nao autenticado';
  end if;

  select st.* into v_sessao
  from public.sessoes_tempo st
  where st.id = p_sessao_tempo_id
    and st.usuario_id = v_usuario_id
  for update;

  if not found then
    raise exception 'Sessao de tempo invalida';
  end if;

  if v_sessao.status = 'encerrada' then
    raise exception 'Sessao ja encerrada';
  end if;

  -- clock_timestamp() pós-lock, nunca now() — mesma razão documentada em
  -- heartbeat_sessao_tempo.
  v_agora := clock_timestamp();

  -- Reancora SEMPRE (pausada->ativa OU ativa->ativa) — nunca credita
  -- tempo, nunca chama _distribuir_segundos_por_dia.
  update public.sessoes_tempo
  set status = 'ativa',
      pausado_em = null,
      ultimo_heartbeat_em = v_agora,
      contabilizado_ate_em = v_agora,
      updated_at = v_agora
  where sessoes_tempo.id = p_sessao_tempo_id;

  return query
  select st.id, st.status, st.ultimo_heartbeat_em
  from public.sessoes_tempo st
  where st.id = p_sessao_tempo_id;
end;
$function$;

-- ----------------------------------------------------------------------------
-- encerrar_sessao_tempo: ativa -> credita último delta (com distribuição
-- por dia) e encerra; pausada -> só encerra (sem creditar mais nada); já
-- encerrada -> idempotente.
-- ----------------------------------------------------------------------------
create or replace function public.encerrar_sessao_tempo(p_sessao_tempo_id bigint)
returns table (
  id bigint,
  status text,
  segundos_liquidos integer,
  encerrado_em timestamptz
)
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_usuario_id uuid := auth.uid();
  v_sessao public.sessoes_tempo%rowtype;
  v_delta integer;
  v_agora timestamptz; -- só atribuído APÓS o lock (ver heartbeat_sessao_tempo)
  v_inicio_creditado timestamptz;
  v_fim_creditado timestamptz;
  v_teto constant integer := 60;
begin
  if v_usuario_id is null then
    raise exception 'Usuario nao autenticado';
  end if;

  select st.* into v_sessao
  from public.sessoes_tempo st
  where st.id = p_sessao_tempo_id
    and st.usuario_id = v_usuario_id
  for update;

  if not found then
    raise exception 'Sessao de tempo invalida';
  end if;

  -- clock_timestamp() pós-lock, nunca now() — mesma razão documentada em
  -- heartbeat_sessao_tempo.
  v_agora := clock_timestamp();

  if v_sessao.status = 'encerrada' then
    return query
    select v_sessao.id, v_sessao.status, v_sessao.segundos_liquidos, v_sessao.encerrado_em;
    return;
  end if;

  if v_sessao.status = 'ativa' then
    -- Mesma política temporal de pausar_sessao_tempo: gap de liveness via
    -- ultimo_heartbeat_em decide o teto; a janela parte de
    -- contabilizado_ate_em.
    if extract(epoch from (v_agora - v_sessao.ultimo_heartbeat_em)) <= v_teto then
      v_delta := greatest(0, floor(extract(epoch from (v_agora - v_sessao.contabilizado_ate_em)))::integer);
    else
      v_delta := v_teto;
    end if;
  else
    v_delta := 0; -- pausada: nao credita tempo (politica explicita desta fase)
  end if;

  if v_delta > 0 then
    -- Janela creditada: exatamente v_delta segundos a partir de
    -- contabilizado_ate_em já gravado — nunca o intervalo real inteiro.
    v_inicio_creditado := v_sessao.contabilizado_ate_em;
    v_fim_creditado := v_inicio_creditado + make_interval(secs => v_delta);

    perform public._distribuir_segundos_por_dia(
      p_sessao_tempo_id, v_usuario_id, v_sessao.matricula_id,
      v_inicio_creditado, v_fim_creditado
    );
  end if;

  update public.sessoes_tempo
  set segundos_liquidos = sessoes_tempo.segundos_liquidos + v_delta,
      status = 'encerrada',
      encerrado_em = v_agora,
      ultimo_heartbeat_em = v_agora,
      contabilizado_ate_em = v_agora,
      updated_at = v_agora
  where sessoes_tempo.id = p_sessao_tempo_id;

  return query
  select st.id, st.status, st.segundos_liquidos, st.encerrado_em
  from public.sessoes_tempo st
  where st.id = p_sessao_tempo_id;
end;
$function$;

-- ----------------------------------------------------------------------------
-- obter_sessao_tempo_aberta: devolve a sessão ativa/pausada do usuário, se
-- houver (zero linhas caso contrário). Usado no load/refresh da tela para
-- retomar a sessão certa em vez de criar uma nova.
--
-- IMPORTANTE para o frontend: se esta função devolver uma sessão, SEMPRE
-- chamar retomar_sessao_tempo nela antes de iniciar o heartbeat (mesmo se
-- status já for 'ativa') — é isso que reancora ultimo_heartbeat_em antes
-- do primeiro heartbeat, evitando creditar inatividade de navegador
-- fechado como se fosse estudo real. Ver comentário completo em
-- retomar_sessao_tempo.
-- ----------------------------------------------------------------------------
create or replace function public.obter_sessao_tempo_aberta()
returns table (
  id bigint,
  matricula_id uuid,
  origem text,
  tipo_atividade text,
  status text,
  segundos_liquidos integer,
  iniciado_em timestamptz,
  ultimo_heartbeat_em timestamptz,
  pausado_em timestamptz,
  missao_id uuid,
  sessao_estudo_id bigint,
  curso_conteudo_id bigint,
  materia_id bigint,
  assunto_id bigint,
  unidade_pedagogica_id uuid
)
language plpgsql
stable
security definer
set search_path to ''
as $function$
declare
  v_usuario_id uuid := auth.uid();
begin
  if v_usuario_id is null then
    raise exception 'Usuario nao autenticado';
  end if;

  return query
  select st.id, st.matricula_id, st.origem, st.tipo_atividade, st.status, st.segundos_liquidos,
         st.iniciado_em, st.ultimo_heartbeat_em, st.pausado_em,
         st.missao_id, st.sessao_estudo_id, st.curso_conteudo_id,
         st.materia_id, st.assunto_id, st.unidade_pedagogica_id
  from public.sessoes_tempo st
  where st.usuario_id = v_usuario_id
    and st.status in ('ativa', 'pausada')
  limit 1;
end;
$function$;

-- ----------------------------------------------------------------------------
-- resumo_tempo_estudo: segundos hoje/semana/mês + meta diária (em segundos,
-- derivada de configuracoes_estudo.horas_diarias) para a matrícula ativa do
-- usuário autenticado. Lê de sessoes_tempo_dias (não de sessoes_tempo
-- diretamente) — é o que torna o resultado correto mesmo quando uma sessão
-- atravessou meia-noite, já que cada dia já vem pré-dividido pela própria
-- distribuição feita no heartbeat/pausa/encerramento.
--
-- Mesmo padrão de resolução de curso ativo já usado em
-- estatisticas_do_curso_ativo: sem matrícula ativa, devolve zeros (não
-- lança exceção) — é uma RPC de leitura/dashboard.
--
-- Semana definida como segunda-feira a domingo (ISO 8601). Mês = mês
-- calendário corrente. Fuso fixo America/Sao_Paulo nesta fase.
-- ----------------------------------------------------------------------------
create or replace function public.resumo_tempo_estudo()
returns jsonb
language plpgsql
stable
security definer
set search_path to ''
as $function$
declare
  v_usuario_id uuid := auth.uid();
  v_curso_ativo_id uuid;
  v_matricula_id uuid;
  v_horas_diarias numeric;
  v_hoje date;
  v_inicio_semana date;
  v_inicio_mes date;
  v_segundos_hoje integer;
  v_segundos_semana integer;
  v_segundos_mes integer;
begin
  if v_usuario_id is null then
    raise exception 'Usuario nao autenticado';
  end if;

  select p.curso_ativo_id into v_curso_ativo_id
  from public.perfis p
  where p.usuario_id = v_usuario_id;

  if v_curso_ativo_id is null then
    return jsonb_build_object('segundos_hoje', 0, 'segundos_semana', 0, 'segundos_mes', 0, 'meta_diaria_segundos', 0);
  end if;

  select m.id into v_matricula_id
  from public.matriculas m
  where m.usuario_id = v_usuario_id
    and m.curso_id = v_curso_ativo_id
    and m.status = 'ativa';

  if v_matricula_id is null then
    return jsonb_build_object('segundos_hoje', 0, 'segundos_semana', 0, 'segundos_mes', 0, 'meta_diaria_segundos', 0);
  end if;

  select ce.horas_diarias into v_horas_diarias
  from public.configuracoes_estudo ce
  where ce.matricula_id = v_matricula_id;

  v_hoje := (timezone('America/Sao_Paulo', now()))::date;
  v_inicio_semana := v_hoje - (extract(isodow from v_hoje)::integer - 1);
  v_inicio_mes := date_trunc('month', v_hoje)::date;

  select coalesce(sum(std.segundos_liquidos), 0) into v_segundos_hoje
  from public.sessoes_tempo_dias std
  where std.usuario_id = v_usuario_id
    and std.matricula_id = v_matricula_id
    and std.dia = v_hoje;

  select coalesce(sum(std.segundos_liquidos), 0) into v_segundos_semana
  from public.sessoes_tempo_dias std
  where std.usuario_id = v_usuario_id
    and std.matricula_id = v_matricula_id
    and std.dia >= v_inicio_semana
    and std.dia <= v_hoje;

  select coalesce(sum(std.segundos_liquidos), 0) into v_segundos_mes
  from public.sessoes_tempo_dias std
  where std.usuario_id = v_usuario_id
    and std.matricula_id = v_matricula_id
    and std.dia >= v_inicio_mes
    and std.dia <= v_hoje;

  return jsonb_build_object(
    'segundos_hoje', v_segundos_hoje,
    'segundos_semana', v_segundos_semana,
    'segundos_mes', v_segundos_mes,
    'meta_diaria_segundos', round(coalesce(v_horas_diarias, 0) * 3600)
  );
end;
$function$;

-- ----------------------------------------------------------------------------
-- historico_tempo_estudo: agregação diária num intervalo limitado (default
-- 30 dias, teto defensivo de 366 por chamada) para a matrícula ativa. Lê de
-- sessoes_tempo_dias (correto mesmo com sessões que atravessam meia-noite);
-- o JOIN com sessoes_tempo é só para obter `origem` por fatia — não
-- duplica agregação, já que cada (sessao_tempo_id, dia) é uma linha única
-- em sessoes_tempo_dias e o JOIN é 1:1 em sessao_tempo_id -> st.id (chave
-- primária do lado direito).
-- ----------------------------------------------------------------------------
create or replace function public.historico_tempo_estudo(p_dias integer default 30)
returns table (
  dia date,
  segundos_liquidos integer,
  segundos_cronograma integer,
  segundos_estudo_livre integer,
  segundos_questoes integer,
  quantidade_sessoes integer
)
language plpgsql
stable
security definer
set search_path to ''
as $function$
declare
  v_usuario_id uuid := auth.uid();
  v_curso_ativo_id uuid;
  v_matricula_id uuid;
  v_dias integer := least(366, greatest(1, coalesce(p_dias, 30)));
  v_hoje date;
  v_desde date;
begin
  if v_usuario_id is null then
    raise exception 'Usuario nao autenticado';
  end if;

  select p.curso_ativo_id into v_curso_ativo_id
  from public.perfis p
  where p.usuario_id = v_usuario_id;

  if v_curso_ativo_id is null then
    return;
  end if;

  select m.id into v_matricula_id
  from public.matriculas m
  where m.usuario_id = v_usuario_id
    and m.curso_id = v_curso_ativo_id
    and m.status = 'ativa';

  if v_matricula_id is null then
    return;
  end if;

  v_hoje := (timezone('America/Sao_Paulo', now()))::date;
  v_desde := v_hoje - v_dias;

  return query
  select
    std.dia,
    sum(std.segundos_liquidos)::integer as segundos_liquidos,
    coalesce(sum(std.segundos_liquidos) filter (where st.origem = 'cronograma'), 0)::integer as segundos_cronograma,
    coalesce(sum(std.segundos_liquidos) filter (where st.origem = 'estudo_livre'), 0)::integer as segundos_estudo_livre,
    coalesce(sum(std.segundos_liquidos) filter (where st.origem = 'questoes'), 0)::integer as segundos_questoes,
    count(distinct std.sessao_tempo_id)::integer as quantidade_sessoes
  from public.sessoes_tempo_dias std
  join public.sessoes_tempo st on st.id = std.sessao_tempo_id
  where std.usuario_id = v_usuario_id
    and std.matricula_id = v_matricula_id
    and std.dia >= v_desde
    and std.dia <= v_hoje
  group by std.dia
  order by std.dia;
end;
$function$;

-- ============================================================================
-- 5. GRANTS MÍNIMOS
-- ============================================================================
-- Diferente do restante do schema (onde as RPCs ficam com o grant implícito
-- de EXECUTE a PUBLIC, já que auth.uid() null-check faz o papel de guarda),
-- aqui revogamos explicitamente de PUBLIC/anon e concedemos só a
-- `authenticated`, por ser pedido explícito desta fase ("grants mínimos").
--
-- A função interna _distribuir_segundos_por_dia NÃO recebe grant nenhum
-- para authenticated/anon — ela confia que quem a chama (as 3 RPCs de
-- heartbeat/pausar/encerrar) já validou usuario_id/matricula_id/sessão; se
-- fosse chamável diretamente pelo cliente, permitiria creditar segundos em
-- sessões/usuários arbitrários.

revoke all on function public._distribuir_segundos_por_dia(bigint, uuid, uuid, timestamptz, timestamptz) from public, anon, authenticated;

revoke all on function public.iniciar_sessao_tempo(text, uuid, text, uuid, bigint, bigint, bigint, bigint, uuid) from public, anon;
grant execute on function public.iniciar_sessao_tempo(text, uuid, text, uuid, bigint, bigint, bigint, bigint, uuid) to authenticated;

revoke all on function public.heartbeat_sessao_tempo(bigint) from public, anon;
grant execute on function public.heartbeat_sessao_tempo(bigint) to authenticated;

revoke all on function public.pausar_sessao_tempo(bigint) from public, anon;
grant execute on function public.pausar_sessao_tempo(bigint) to authenticated;

revoke all on function public.retomar_sessao_tempo(bigint) from public, anon;
grant execute on function public.retomar_sessao_tempo(bigint) to authenticated;

revoke all on function public.encerrar_sessao_tempo(bigint) from public, anon;
grant execute on function public.encerrar_sessao_tempo(bigint) to authenticated;

revoke all on function public.obter_sessao_tempo_aberta() from public, anon;
grant execute on function public.obter_sessao_tempo_aberta() to authenticated;

revoke all on function public.resumo_tempo_estudo() from public, anon;
grant execute on function public.resumo_tempo_estudo() to authenticated;

revoke all on function public.historico_tempo_estudo(integer) from public, anon;
grant execute on function public.historico_tempo_estudo(integer) to authenticated;
