-- Diagnóstico READ-ONLY para a curadoria de questões da Lei Maria da Penha
-- (curso_conteudos.id = 53) por unidade pedagógica.
--
-- SOMENTE SELECT. Nenhuma instrução deste arquivo escreve em nada — nenhum
-- INSERT/UPDATE/DELETE, nenhuma classificação automática por regex/palavra-
-- chave/IA. Cole no SQL Editor do Supabase e rode; cada bloco abaixo é uma
-- consulta independente (mesmo padrão já usado em
-- supabase/diagnostico_questoes_lei_maria_penha.sql) — rode um de cada vez,
-- ou o script inteiro, conforme o SQL Editor mostrar os resultados.
--
-- "Candidata" = mesma definição já usada em
-- diagnostico_questoes_lei_maria_penha.sql: questão ATIVA cuja materia_id
-- bate com a matéria real do conteúdo 53 (via curso_conteudos ->
-- curso_materias) e, quando o conteúdo tiver assunto_id definido, cujo
-- assunto_id também bate — a mesma regra que a trigger
-- validar_questao_unidade_pedagogica (questao_unidades_pedagogicas.sql)
-- exige para aceitar uma classificação.
--
-- Depois de decidir manualmente a unidade de cada questão, classificar com:
--   select public.classificar_questao_unidade_admin(<questao_id>, <unidade_pedagogica_id>);
-- (ver supabase/questao_unidades_pedagogicas.sql) — nunca um INSERT direto.

-- ============================================================================
-- 1) As 5 unidades pedagógicas reais do conteúdo 53.
-- ============================================================================
select
  id,
  ordem,
  titulo,
  escopo,
  artigos_esperados,
  ativa
from public.unidades_pedagogicas
where curso_conteudo_id = 53
order by ordem;

-- ============================================================================
-- 2) Quantidade total de questões candidatas (ativas, matéria/assunto reais
--    do conteúdo 53) — independente de já estarem classificadas ou não.
-- ============================================================================
select count(*) as questoes_candidatas_total
from public.questoes q
join public.curso_conteudos cc on cc.id = 53
join public.curso_materias cm on cm.id = cc.curso_materia_id
where q.ativa = true
  and q.materia_id = cm.materia_id
  and (cc.assunto_id is null or q.assunto_id = cc.assunto_id);

-- ============================================================================
-- 3) + 4) Lista completa das questões candidatas, EXATAMENTE uma linha por
--    questão (a modelagem permite uma questão pertencer a mais de uma
--    unidade — um JOIN direto em questao_unidades_pedagogicas duplicaria a
--    linha nesse caso; por isso os vínculos são agregados num único jsonb
--    por questão via LEFT JOIN LATERAL). Só entram vínculos com unidades do
--    PRÓPRIO conteúdo 53 (filtro dentro da subquery lateral) — vínculos da
--    mesma questão com unidades de OUTROS conteúdos nunca aparecem aqui,
--    nem geram linha nem contaminam o jsonb.
--
--    unidades_classificadas: array jsonb, um objeto {unidade_id, ordem,
--    titulo} por vínculo, ordenado por ordem; [] quando a questão ainda não
--    foi classificada em nenhuma unidade deste conteúdo.
--    classificada: true quando unidades_classificadas tem pelo menos 1
--    item; false quando está vazio.
-- ============================================================================
select
  q.id as questao_id,
  q.enunciado,
  q.banca,
  q.concurso,
  q.ano,
  q.dificuldade,
  q.materia_id,
  q.assunto_id,
  coalesce(uc.unidades_classificadas, '[]'::jsonb) as unidades_classificadas,
  coalesce(uc.unidades_classificadas, '[]'::jsonb) <> '[]'::jsonb as classificada
from public.questoes q
join public.curso_conteudos cc on cc.id = 53
join public.curso_materias cm on cm.id = cc.curso_materia_id
left join lateral (
  select jsonb_agg(
           jsonb_build_object('unidade_id', u.id, 'ordem', u.ordem, 'titulo', u.titulo)
           order by u.ordem
         ) as unidades_classificadas
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where qup.questao_id = q.id
    and u.curso_conteudo_id = 53
) uc on true
where q.ativa = true
  and q.materia_id = cm.materia_id
  and (cc.assunto_id is null or q.assunto_id = cc.assunto_id)
order by q.id;

-- ============================================================================
-- 5) Resumo por unidade: quantas questões já estão classificadas em cada
--    uma das 5 unidades do conteúdo 53.
-- ============================================================================
select
  u.id as unidade_id,
  u.ordem,
  u.titulo,
  count(qup.questao_id) as questoes_classificadas
from public.unidades_pedagogicas u
left join public.questao_unidades_pedagogicas qup on qup.unidade_pedagogica_id = u.id
where u.curso_conteudo_id = 53
group by u.id, u.ordem, u.titulo
order by u.ordem;

-- ============================================================================
-- 6) Quantidade de questões candidatas ainda não classificadas em nenhuma
--    das 5 unidades do conteúdo 53.
-- ============================================================================
select count(*) as questoes_pendentes_de_classificacao
from public.questoes q
join public.curso_conteudos cc on cc.id = 53
join public.curso_materias cm on cm.id = cc.curso_materia_id
where q.ativa = true
  and q.materia_id = cm.materia_id
  and (cc.assunto_id is null or q.assunto_id = cc.assunto_id)
  and not exists (
    select 1
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where qup.questao_id = q.id
      and u.curso_conteudo_id = 53
  );
