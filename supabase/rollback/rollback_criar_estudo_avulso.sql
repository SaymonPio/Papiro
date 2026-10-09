-- Rollback manual de 20261007120000_criar_estudo_avulso.sql
--
-- ATENÇÃO: se já existir qualquer sessoes_tempo com origem='estudo_avulso'
-- ou tipo_atividade='nao_classificado' (ou seja, se o Cronômetro Livre já
-- foi usado em produção), restaurar as constraints originais abaixo vai
-- FALHAR com violação de check constraint — e restaurar a definição
-- antiga de iniciar_sessao_tempo, mesmo que funcione, deixa essas linhas
-- já existentes "soltas" (um estado que a função antiga nunca teria
-- criado). Nunca executar este rollback em produção sem primeiro decidir
-- o que fazer com essas linhas (nenhuma é apagada por este script —
-- DROP destrutivo não é feito aqui de propósito).
--
-- Reverte, na ordem inversa da migration:
--   4. remove classificar_estudo_avulso (função nova — DROP, não existia antes);
--   3. restaura iniciar_sessao_tempo ao corpo anterior (sem estudo_avulso/nao_classificado);
--   2. remove descricao_estudo (coluna nova — DROP, perde qualquer texto já salvo);
--   1. restaura as constraints de origem/tipo_atividade aos valores antigos
--      (sem 'estudo_avulso'/'nao_classificado') e remove a constraint
--      composta nova.

-- ----------------------------------------------------------------------------
-- 4. Remove a RPC nova (sem equivalente anterior a restaurar).
-- ----------------------------------------------------------------------------
drop function if exists public.classificar_estudo_avulso(bigint, text, bigint, bigint, text);

-- ----------------------------------------------------------------------------
-- 3. Restaura iniciar_sessao_tempo à definição anterior a esta migration
--    (idêntica à de 20261003120000_criar_sessoes_tempo.sql — nenhuma outra
--    migration alterou esta função entre as duas).
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

  if not exists (
    select 1 from public.matriculas m
    where m.id = p_matricula_id
      and m.usuario_id = v_usuario_id
      and m.status = 'ativa'
  ) then
    raise exception 'Matricula invalida ou inativa';
  end if;

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

  begin
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
    select st.* into v_existente
    from public.sessoes_tempo st
    where st.usuario_id = v_usuario_id
      and st.status in ('ativa', 'pausada')
    limit 1;

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

    raise exception 'Ja existe uma sessao de tempo aberta (id=%, status=%, origem=%) para este usuario',
      v_existente.id, v_existente.status, v_existente.origem
      using errcode = '23505';
  end;
end;
$function$;

-- ----------------------------------------------------------------------------
-- 2. Remove a coluna nova (DROP — perde qualquer descrição já salva).
-- ----------------------------------------------------------------------------
alter table public.sessoes_tempo drop constraint if exists sessoes_tempo_descricao_estudo_tamanho;
alter table public.sessoes_tempo drop column if exists descricao_estudo;

-- ----------------------------------------------------------------------------
-- 1. Restaura as constraints de origem/tipo_atividade aos valores
--    originais e remove a constraint composta nova. FALHA (violação de
--    check) se já existir alguma linha com origem='estudo_avulso' ou
--    tipo_atividade='nao_classificado' — ver aviso no topo deste arquivo.
-- ----------------------------------------------------------------------------
alter table public.sessoes_tempo drop constraint if exists sessoes_tempo_nao_classificado_so_avulso;
alter table public.sessoes_tempo drop constraint if exists sessoes_tempo_origem_check;
alter table public.sessoes_tempo drop constraint if exists sessoes_tempo_tipo_atividade_check;

alter table public.sessoes_tempo
  add constraint sessoes_tempo_origem_check
  check (origem in ('cronograma', 'estudo_livre', 'questoes'));

alter table public.sessoes_tempo
  add constraint sessoes_tempo_tipo_atividade_check
  check (tipo_atividade in ('teoria', 'questoes', 'leitura', 'revisao'));
