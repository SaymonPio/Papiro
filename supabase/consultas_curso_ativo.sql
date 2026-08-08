-- Etapa 4 do isolamento de dados por curso: consultas centralizadas de erros, revisões e
-- estatísticas do curso ativo (Opção B aprovada: lógica de isolamento no Supabase, não
-- repetida em cada página).
--
-- Nenhuma tabela é alterada, nenhuma coluna curso_id é adicionada em respostas_usuarios,
-- erros_usuarios ou revisoes. As 3 funções abaixo resolvem o curso pela cadeia já existente:
--   auth.uid() -> perfis.curso_ativo_id -> matriculas (usuario_id + curso_id + status='ativa')
--   -> sessoes_estudo.matricula_id -> respostas_usuarios.sessao_id -> erros_usuarios.resposta_id
--   -> revisoes.erro_id
-- Qualquer linha legada em que esse encadeamento esteja quebrado (sessao_id, matricula_id ou
-- erro_id nulos) fica naturalmente fora do resultado (os JOINs são INNER onde a cadeia é
-- exigida) — nenhum backfill, nenhuma alteração e nenhuma exclusão de dado é feita aqui.
--
-- Sem curso_id direto: se o usuário não tiver curso_ativo_id em perfis, ou não houver
-- matrícula ativa para esse curso, as 3 funções retornam vazio (nunca erro, nunca dado de
-- outro curso ou do histórico global).
--
-- Todas usam SECURITY DEFINER + SET search_path TO '' (mesmo padrão de
-- ids_questoes_para_usuario/registrar_resposta), com auth.uid() resolvendo o usuário
-- autenticado. Não é necessário GRANT EXECUTE explícito — segue o mesmo comportamento já
-- observado nas demais RPCs deste projeto (executáveis por "authenticated" por padrão).

-- ============================================================================
-- 1) erros_do_curso_ativo()
-- Usada por app/caderno-de-erros/page.tsx. Superset de campos que também cobre o
-- subconjunto (tipo_erro, corrigido, materia_nome, assunto_nome) usado dentro do JSON de
-- estatisticas_do_curso_ativo() — mesma fonte de dados, mesma regra de curso.
-- ============================================================================
create or replace function public.erros_do_curso_ativo()
returns table (
  id bigint,
  tipo_erro text,
  motivo_provavel text,
  corrigido boolean,
  criado_em timestamptz,
  enunciado text,
  materia_nome text,
  assunto_nome text,
  revisoes jsonb
)
language sql
stable
security definer
set search_path to ''
as $function$
  select
    eu.id,
    eu.tipo_erro,
    eu.motivo_provavel,
    eu.corrigido,
    eu.criado_em,
    q.enunciado,
    m.nome as materia_nome,
    a.nome as assunto_nome,
    coalesce(
      (
        select jsonb_agg(
          jsonb_build_object('agendada_para', r.agendada_para, 'ordem', r.ordem, 'status', r.status)
          order by r.ordem
        )
        from public.revisoes r
        where r.erro_id = eu.id
      ),
      '[]'::jsonb
    ) as revisoes
  from public.erros_usuarios eu
  join public.respostas_usuarios ru on ru.id = eu.resposta_id
  join public.sessoes_estudo se on se.id = ru.sessao_id
  join public.matriculas mat
    on mat.id = se.matricula_id
   and mat.usuario_id = auth.uid()
   and mat.status = 'ativa'
  join public.perfis p
    on p.usuario_id = auth.uid()
   and p.curso_ativo_id = mat.curso_id
  left join public.questoes q on q.id = eu.questao_id
  left join public.materias m on m.id = q.materia_id
  left join public.assuntos a on a.id = q.assunto_id
  where eu.usuario_id = auth.uid()
  order by eu.criado_em desc;
$function$;

-- ============================================================================
-- 2) revisoes_do_curso_ativo()
-- Não é consumida por nenhuma página nesta rodada (caderno de erros recebe revisões
-- aninhadas via erros_do_curso_ativo(); estatísticas recebe via o JSON de
-- estatisticas_do_curso_ativo()). Criada como peça reutilizável independente, já pronta
-- para telas futuras (ex.: cronograma, que não é alterado nesta etapa).
-- ============================================================================
create or replace function public.revisoes_do_curso_ativo()
returns table (
  id bigint,
  erro_id bigint,
  ordem smallint,
  intervalo_dias integer,
  agendada_para date,
  status text,
  concluida_em timestamptz,
  desempenho_pos_revisao numeric,
  materia_nome text,
  assunto_nome text
)
language sql
stable
security definer
set search_path to ''
as $function$
  select
    rv.id,
    rv.erro_id,
    rv.ordem,
    rv.intervalo_dias,
    rv.agendada_para,
    rv.status,
    rv.concluida_em,
    rv.desempenho_pos_revisao,
    m.nome as materia_nome,
    a.nome as assunto_nome
  from public.revisoes rv
  join public.erros_usuarios eu on eu.id = rv.erro_id
  join public.respostas_usuarios ru on ru.id = eu.resposta_id
  join public.sessoes_estudo se on se.id = ru.sessao_id
  join public.matriculas mat
    on mat.id = se.matricula_id
   and mat.usuario_id = auth.uid()
   and mat.status = 'ativa'
  join public.perfis p
    on p.usuario_id = auth.uid()
   and p.curso_ativo_id = mat.curso_id
  left join public.questoes q on q.id = eu.questao_id
  left join public.materias m on m.id = q.materia_id
  left join public.assuntos a on a.id = q.assunto_id
  where rv.usuario_id = auth.uid()
  order by rv.agendada_para asc;
$function$;

-- ============================================================================
-- 3) estatisticas_do_curso_ativo(p_dias integer default 90)
-- Usada por app/estatisticas/page.tsx. Retorna um único JSONB com 4 listas — os mesmos 4
-- conjuntos de linhas que a página buscava antes em 4 queries separadas — para que a lógica
-- de agregação client-side (aproveitamento, sequência, por matéria, por tipo de erro, últimos
-- 7 dias, abandonadas) permaneça exatamente a mesma, sem risco de recalcular diferente.
-- Preserva a assimetria original: respostas/sessoes respeitam a janela de p_dias (default 90,
-- igual ao "últimos 90 dias" já exibido); revisoes/erros continuam sem janela de tempo,
-- como já era antes.
-- ============================================================================
create or replace function public.estatisticas_do_curso_ativo(p_dias integer default 90)
returns jsonb
language plpgsql
stable
security definer
set search_path to ''
as $function$
declare
  v_curso_ativo_id uuid;
  v_matricula_id uuid;
  v_desde_ts timestamptz;
  v_desde_data date;
  v_resultado jsonb;
  v_dias integer := greatest(1, coalesce(p_dias, 90));
begin
  select p.curso_ativo_id into v_curso_ativo_id
  from public.perfis p
  where p.usuario_id = auth.uid();

  if v_curso_ativo_id is null then
    return jsonb_build_object('respostas', '[]'::jsonb, 'sessoes', '[]'::jsonb, 'revisoes', '[]'::jsonb, 'erros', '[]'::jsonb);
  end if;

  select mat.id into v_matricula_id
  from public.matriculas mat
  where mat.usuario_id = auth.uid()
    and mat.curso_id = v_curso_ativo_id
    and mat.status = 'ativa';

  if v_matricula_id is null then
    return jsonb_build_object('respostas', '[]'::jsonb, 'sessoes', '[]'::jsonb, 'revisoes', '[]'::jsonb, 'erros', '[]'::jsonb);
  end if;

  v_desde_ts := now() - (v_dias || ' days')::interval;
  v_desde_data := current_date - v_dias;

  select jsonb_build_object(
    'respostas', coalesce((
      select jsonb_agg(jsonb_build_object(
        'acertou', ru.acertou,
        'respondida_em', ru.respondida_em,
        'banca', q.banca,
        'materia_nome', m.nome,
        'assunto_nome', a.nome
      ) order by ru.respondida_em)
      from public.respostas_usuarios ru
      join public.sessoes_estudo se on se.id = ru.sessao_id and se.matricula_id = v_matricula_id
      left join public.questoes q on q.id = ru.questao_id
      left join public.materias m on m.id = q.materia_id
      left join public.assuntos a on a.id = q.assunto_id
      where ru.usuario_id = auth.uid()
        and ru.respondida_em >= v_desde_ts
    ), '[]'::jsonb),
    'sessoes', coalesce((
      select jsonb_agg(jsonb_build_object(
        'data_sessao', se.data_sessao,
        'status', se.status,
        'questoes_respondidas', se.questoes_respondidas,
        'acertos', se.acertos
      ) order by se.data_sessao)
      from public.sessoes_estudo se
      where se.matricula_id = v_matricula_id
        and se.usuario_id = auth.uid()
        and se.data_sessao >= v_desde_data
    ), '[]'::jsonb),
    'revisoes', coalesce((
      select jsonb_agg(jsonb_build_object(
        'status', rv.status,
        'agendada_para', rv.agendada_para
      ) order by rv.agendada_para)
      from public.revisoes rv
      join public.erros_usuarios eu on eu.id = rv.erro_id
      join public.respostas_usuarios ru on ru.id = eu.resposta_id
      join public.sessoes_estudo se on se.id = ru.sessao_id and se.matricula_id = v_matricula_id
      where rv.usuario_id = auth.uid()
    ), '[]'::jsonb),
    'erros', coalesce((
      select jsonb_agg(jsonb_build_object(
        'tipo_erro', eu.tipo_erro,
        'corrigido', eu.corrigido,
        'materia_nome', m.nome,
        'assunto_nome', a.nome
      ))
      from public.erros_usuarios eu
      join public.respostas_usuarios ru on ru.id = eu.resposta_id
      join public.sessoes_estudo se on se.id = ru.sessao_id and se.matricula_id = v_matricula_id
      left join public.questoes q on q.id = eu.questao_id
      left join public.materias m on m.id = q.materia_id
      left join public.assuntos a on a.id = q.assunto_id
      where eu.usuario_id = auth.uid()
    ), '[]'::jsonb)
  ) into v_resultado;

  return v_resultado;
end;
$function$;
