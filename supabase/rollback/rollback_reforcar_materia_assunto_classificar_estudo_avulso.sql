-- Rollback manual de
-- 20261007180000_reforcar_materia_assunto_classificar_estudo_avulso.sql
--
-- Restaura classificar_estudo_avulso à validação anterior (só existência
-- global em materias/assuntos, sem checar curso_materias/curso_conteudos).
-- Nenhum DDL de tabela/índice/grant a desfazer — só o corpo da função.
--
-- ATENÇÃO: isto reintroduz a lacuna de segurança corrigida por esta
-- migration (materia_id/assunto_id aceitos mesmo sem pertencer ao curso
-- da matrícula). Não executar em produção sem entender essa consequência.

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
