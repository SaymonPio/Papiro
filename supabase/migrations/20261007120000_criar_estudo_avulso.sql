-- Fase 2 do sistema de horas líquidas: adiciona o fluxo "Cronômetro
-- Livre" (estudo avulso, feito FORA do Papiro — PDF, livro, caderno,
-- videoaula, questões em outra plataforma). Reaproveita 100% do motor
-- já existente (sessoes_tempo + heartbeat_sessao_tempo/
-- pausar_sessao_tempo/retomar_sessao_tempo/encerrar_sessao_tempo) —
-- nenhuma tabela nova, nenhum motor paralelo. Os quatro RPCs acima NÃO
-- são alterados por esta migration.
--
-- ATENÇÃO (risco real de confusão de nomenclatura): "estudo_avulso"
-- aqui é um conceito NOVO e DIFERENTE de "sessão avulsa de questões"
-- (iniciar_sessao_questoes_avulsa / sessoes_estudo / sessao_questoes_
-- planejadas, migrations 20261004180000 em diante) — aquela é uma
-- sessão de QUESTÕES sem missão (personalizada/meta diária), já
-- existente antes desta migration. Esta aqui é tempo medido fora do
-- Papiro, sem NENHUMA relação com sessoes_estudo ou com o motor de
-- questões. Os dois nomes coexistem no schema por coincidência de
-- vocabulário ("avulso"/"avulsa"), não por parentesco — nenhum dos dois
-- fluxos lê ou escreve na tabela do outro.
--
-- Escopo: 100% aditivo sobre sessoes_tempo (migration
-- 20261003120000_criar_sessoes_tempo.sql).

-- ============================================================================
-- 1. NOVA ORIGEM ('estudo_avulso') + NOVO TIPO_ATIVIDADE TÉCNICO ('nao_classificado')
-- ============================================================================
--
-- As duas constraints CHECK de origem/tipo_atividade foram criadas
-- inline (sem `constraint <nome>` explícito) em 20261003120000 — lendo
-- essa migration, nenhuma das duas tem nome dado pelo autor, então o
-- Postgres atribuiu o nome padrão "<tabela>_<coluna>_check". Em vez de
-- assumir esse nome às cegas, o bloco abaixo DESCOBRE o nome real pela
-- única constraint CHECK cujo conkey é exatamente a coluna em questão —
-- continua correto mesmo que o nome real divirja do padrão esperado, e
-- aborta a migration (em vez de seguir silenciosamente) se não achar
-- exatamente uma constraint para cada coluna.
do $$
declare
  v_nome_origem text;
  v_nome_tipo text;
  v_attnum_origem smallint;
  v_attnum_tipo smallint;
begin
  select attnum into v_attnum_origem
  from pg_attribute
  where attrelid = 'public.sessoes_tempo'::regclass and attname = 'origem';

  select attnum into v_attnum_tipo
  from pg_attribute
  where attrelid = 'public.sessoes_tempo'::regclass and attname = 'tipo_atividade';

  select con.conname into v_nome_origem
  from pg_constraint con
  where con.conrelid = 'public.sessoes_tempo'::regclass
    and con.contype = 'c'
    and con.conkey = array[v_attnum_origem];

  select con.conname into v_nome_tipo
  from pg_constraint con
  where con.conrelid = 'public.sessoes_tempo'::regclass
    and con.contype = 'c'
    and con.conkey = array[v_attnum_tipo];

  if v_nome_origem is null then
    raise exception 'Constraint CHECK de origem nao encontrada em sessoes_tempo — abortando migration';
  end if;
  if v_nome_tipo is null then
    raise exception 'Constraint CHECK de tipo_atividade nao encontrada em sessoes_tempo — abortando migration';
  end if;

  raise notice 'Substituindo constraint % (origem) e % (tipo_atividade) em sessoes_tempo', v_nome_origem, v_nome_tipo;

  execute format('alter table public.sessoes_tempo drop constraint %I', v_nome_origem);
  execute format('alter table public.sessoes_tempo drop constraint %I', v_nome_tipo);
end $$;

alter table public.sessoes_tempo
  add constraint sessoes_tempo_origem_check
  check (origem in ('cronograma', 'estudo_livre', 'questoes', 'estudo_avulso'));

alter table public.sessoes_tempo
  add constraint sessoes_tempo_tipo_atividade_check
  check (tipo_atividade in ('teoria', 'questoes', 'leitura', 'revisao', 'nao_classificado'));

-- 'nao_classificado' é um valor EXCLUSIVAMENTE técnico (estudo avulso
-- ainda sem classificação do aluno, entre o fim do cronômetro e o envio
-- do formulário "o que você estudou") — nunca pode aparecer em nenhuma
-- outra origem, e nenhuma origem além de estudo_avulso pode usá-lo.
-- Toda linha hoje em sessoes_tempo satisfaz isso trivialmente (o valor
-- nunca existiu antes desta migration).
alter table public.sessoes_tempo
  add constraint sessoes_tempo_nao_classificado_so_avulso
  check (tipo_atividade <> 'nao_classificado' or origem = 'estudo_avulso');

-- ============================================================================
-- 2. DESCRIÇÃO LIVRE (preenchida só na classificação posterior)
-- ============================================================================
-- Nenhum campo equivalente existe hoje em sessoes_tempo — adiciona
-- apenas este, conforme pedido ("não criar várias colunas
-- desnecessárias"). Nulo para toda sessão que não for estudo avulso
-- classificado; sem constraint de origem porque isso já é garantido no
-- único lugar que escreve este campo (classificar_estudo_avulso, seção
-- 4 abaixo).
alter table public.sessoes_tempo
  add column descricao_estudo text null;

alter table public.sessoes_tempo
  add constraint sessoes_tempo_descricao_estudo_tamanho
  check (descricao_estudo is null or char_length(descricao_estudo) <= 500);

comment on column public.sessoes_tempo.descricao_estudo is
  'Texto livre opcional (máx. 500 caracteres), preenchido só pela RPC classificar_estudo_avulso — ex.: "Lei Maria da Penha, arts. 5 a 12" ou "50 questões de Direito Penal no Tec Concursos". Sempre NULL para qualquer sessão que não seja estudo avulso já classificado.';

-- ============================================================================
-- 3. iniciar_sessao_tempo: aceitar estudo_avulso/nao_classificado
-- ============================================================================
-- Reaproveita a RPC existente por completo — mesma assinatura, mesma
-- lógica de conflito/idempotência/matrícula/validação de contexto
-- opcional (nada disso precisa mudar: um estudo avulso nunca preenche
-- missao_id/sessao_estudo_id/curso_conteudo_id/materia_id/assunto_id/
-- unidade_pedagogica_id ao iniciar — todos ficam null, e os `if ... is
-- not null and not exists (...)` abaixo simplesmente não disparam).
-- Único acréscimo real: as duas listas de valores aceitos, mais a regra
-- de que só estudo_avulso pode iniciar como nao_classificado (e
-- vice-versa) — redundante com a constraint da seção 1, mas aqui dá uma
-- mensagem de erro clara em vez de uma violação de constraint genérica
-- do Postgres.
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

  if p_origem not in ('cronograma', 'estudo_livre', 'questoes', 'estudo_avulso') then
    raise exception 'Origem invalida: %', p_origem;
  end if;

  if p_tipo_atividade not in ('teoria', 'questoes', 'leitura', 'revisao', 'nao_classificado') then
    raise exception 'Tipo de atividade invalido: %', p_tipo_atividade;
  end if;

  if p_tipo_atividade = 'nao_classificado' and p_origem <> 'estudo_avulso' then
    raise exception 'nao_classificado so e valido para origem estudo_avulso';
  end if;

  if p_origem = 'estudo_avulso' and p_tipo_atividade <> 'nao_classificado' then
    raise exception 'estudo_avulso deve iniciar como nao_classificado — classifique depois de encerrar, via classificar_estudo_avulso';
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
    -- Para estudo_avulso (tipo_atividade sempre 'nao_classificado', todo o
    -- resto do contexto sempre null dos dois lados), isto sempre devolve a
    -- MESMA sessão aberta — nunca cria conflito contra si mesma, porque só
    -- pode existir uma sessão aberta por usuário (índice único parcial).
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
    raise exception 'Ja existe uma sessao de tempo aberta (id=%, status=%, origem=%) para este usuario',
      v_existente.id, v_existente.status, v_existente.origem
      using errcode = '23505';
  end;
end;
$function$;

-- ============================================================================
-- 4. classificar_estudo_avulso: classificação posterior (nova RPC)
-- ============================================================================
-- iniciar_sessao_tempo (reaproveitada acima) cobre o início; nenhum RPC
-- existente cobre "mudar tipo_atividade/matéria/assunto/descrição de uma
-- sessão já ENCERRADA" — por isso esta é uma RPC nova, não um wrapper
-- alternativo de outra já existente. Nunca toca segundos_liquidos,
-- iniciado_em, encerrado_em, usuario_id, contabilizado_ate_em,
-- ultimo_heartbeat_em, origem ou status — só metadados de classificação.
create or replace function public.classificar_estudo_avulso(
  p_sessao_tempo_id bigint,
  p_tipo_atividade text,
  p_materia_id bigint default null,
  p_assunto_id bigint default null,
  p_descricao_estudo text default null
)
returns table (
  id bigint,
  tipo_atividade text,
  materia_id bigint,
  assunto_id bigint,
  descricao_estudo text
)
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_usuario_id uuid := auth.uid();
  v_sessao public.sessoes_tempo%rowtype;
  v_descricao text;
begin
  if v_usuario_id is null then
    raise exception 'Usuario nao autenticado';
  end if;

  if p_tipo_atividade not in ('teoria', 'questoes', 'leitura', 'revisao') then
    raise exception 'Tipo de atividade invalido para classificacao: %', p_tipo_atividade;
  end if;

  -- usuario_id = v_usuario_id no WHERE (não um check separado depois):
  -- sessão de outro usuário simplesmente não é encontrada — mesmo padrão
  -- de ownership de heartbeat_sessao_tempo/pausar_sessao_tempo/etc.
  select st.* into v_sessao
  from public.sessoes_tempo st
  where st.id = p_sessao_tempo_id
    and st.usuario_id = v_usuario_id
  for update;

  if not found then
    raise exception 'Sessao de tempo invalida';
  end if;

  if v_sessao.origem <> 'estudo_avulso' then
    raise exception 'Esta sessao nao e um estudo avulso e nao pode ser classificada por esta RPC';
  end if;

  if v_sessao.status <> 'encerrada' then
    raise exception 'Encerre a sessao antes de classifica-la';
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

  -- Trim + string vazia -> NULL + limite defensivo de 500 caracteres
  -- (mesmo limite da constraint sessoes_tempo_descricao_estudo_tamanho —
  -- validado aqui também só para dar uma mensagem de erro clara em vez
  -- de uma violação de constraint genérica).
  v_descricao := nullif(btrim(coalesce(p_descricao_estudo, '')), '');
  if v_descricao is not null and char_length(v_descricao) > 500 then
    raise exception 'Descricao excede o limite de 500 caracteres';
  end if;

  update public.sessoes_tempo
  set tipo_atividade = p_tipo_atividade,
      materia_id = p_materia_id,
      assunto_id = p_assunto_id,
      descricao_estudo = v_descricao,
      updated_at = clock_timestamp()
  where sessoes_tempo.id = p_sessao_tempo_id;

  return query
  select st.id, st.tipo_atividade, st.materia_id, st.assunto_id, st.descricao_estudo
  from public.sessoes_tempo st
  where st.id = p_sessao_tempo_id;
end;
$function$;

revoke all on function public.classificar_estudo_avulso(bigint, text, bigint, bigint, text) from public, anon, authenticated;
grant execute on function public.classificar_estudo_avulso(bigint, text, bigint, bigint, text) to authenticated;
