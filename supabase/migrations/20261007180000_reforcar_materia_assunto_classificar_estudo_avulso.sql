-- Fecha uma pendência de segurança apontada na auditoria de
-- classificar_estudo_avulso (20261007120000_criar_estudo_avulso.sql,
-- já aplicada): a validação original de p_materia_id/p_assunto_id só
-- confirmava EXISTÊNCIA global nas tabelas materias/assuntos — nunca que
-- a matéria/assunto pertence de fato ao curso da matrícula da própria
-- sessão. Isso bastava para "não é um ID inventado que não existe", mas
-- não para "pertence a um contexto válido para este usuário/matrícula/
-- curso", que é o que esta rodada pediu.
--
-- Reaproveita a relação REAL já usada e confiada pelo projeto para isso
-- — curso_materias (curso_id, materia_id, relevante_para_preparacao) e
-- curso_conteudos (curso_materia_id, assunto_id, relevante_para_preparacao)
-- — a MESMA relação que materias_do_curso_ativo()/assuntos_do_curso_ativo()
-- (supabase/sessao_personalizada_curso.sql) já usam para decidir o que
-- aparece nos seletores de /questoes. Não inventa nenhuma relação nova.
-- Única diferença deliberada: aqui não exige curso_questoes/questoes.ativa
-- (aquele filtro é específico de "tem questão de prova disponível agora",
-- irrelevante para só marcar que um estudo avulso foi sobre tal matéria).
--
-- v_curso_id vem da matrícula DA PRÓPRIA SESSÃO (st.matricula_id ->
-- matriculas.curso_id) — nunca de um parâmetro do cliente nem do curso
-- ativo atual do usuário (que poderia já ter mudado entre o fim do
-- estudo avulso e o momento de classificar).
--
-- Mesma assinatura de classificar_estudo_avulso — CREATE OR REPLACE,
-- sem precisar de DROP nem de novo grant.

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
  v_curso_id uuid;
  v_descricao text;
begin
  if v_usuario_id is null then
    raise exception 'Usuario nao autenticado';
  end if;

  if p_tipo_atividade not in ('teoria', 'questoes', 'leitura', 'revisao') then
    raise exception 'Tipo de atividade invalido para classificacao: %', p_tipo_atividade;
  end if;

  if p_assunto_id is not null and p_materia_id is null then
    raise exception 'p_assunto_id informado sem p_materia_id';
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

  -- Curso da matrícula DA SESSÃO — nunca do curso ativo atual do
  -- usuário nem de um parâmetro do cliente.
  select m.curso_id into v_curso_id
  from public.matriculas m
  where m.id = v_sessao.matricula_id;

  if p_materia_id is not null and not exists (
    select 1
    from public.curso_materias cm
    where cm.curso_id = v_curso_id
      and cm.materia_id = p_materia_id
      and cm.relevante_para_preparacao = true
  ) then
    raise exception 'Materia nao pertence ao curso desta matricula';
  end if;

  if p_assunto_id is not null and not exists (
    select 1
    from public.curso_conteudos cc
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cm.curso_id = v_curso_id
      and cm.materia_id = p_materia_id
      and cc.assunto_id = p_assunto_id
      and cc.relevante_para_preparacao = true
  ) then
    raise exception 'Assunto invalido para esta materia/curso';
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
