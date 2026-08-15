-- Diagnóstico READ-ONLY para a curadoria de questões da Lei Maria da Penha
-- (curso_conteudos.id = 53) por unidade pedagógica.
--
-- Nenhuma instrução deste arquivo escreve em nada. Nada aqui é aplicado
-- automaticamente — é para colar no SQL Editor do Supabase, ler o
-- resultado, e decidir manualmente (ou com apoio de outra ferramenta) a
-- qual unidade cada questão pertence, usando depois
-- public.classificar_questao_unidade_admin(questao_id, unidade_pedagogica_id)
-- (ver supabase/questao_unidades_pedagogicas.sql) — nunca um INSERT direto
-- nem uma inferência automática por nome/regex/texto do enunciado.
--
-- ============================================================================
-- 1) Quantas questões existem hoje para a matéria/assunto deste conteúdo,
--    e quantas já estão classificadas em alguma unidade.
-- ============================================================================
select
  count(*) filter (where q.ativa) as questoes_ativas_total,
  count(*) filter (where q.ativa and qup.questao_id is not null) as ja_classificadas,
  count(*) filter (where q.ativa and qup.questao_id is null) as pendentes_de_classificacao
from public.questoes q
join public.curso_conteudos cc on cc.id = 53
join public.curso_materias cm on cm.id = cc.curso_materia_id
left join public.questao_unidades_pedagogicas qup
  on qup.questao_id = q.id
 and qup.unidade_pedagogica_id in (select id from public.unidades_pedagogicas where curso_conteudo_id = 53)
where q.materia_id = cm.materia_id
  and (cc.assunto_id is null or q.assunto_id = cc.assunto_id);

-- ============================================================================
-- 2) As 5 unidades pedagógicas já cadastradas para este conteúdo (ver
--    supabase/curadoria_unidades_lei_maria_penha.sql), para referência ao
--    classificar.
-- ============================================================================
select id as unidade_pedagogica_id, ordem, titulo, escopo, artigos_esperados
from public.unidades_pedagogicas
where curso_conteudo_id = 53
order by ordem;

-- ============================================================================
-- 3) Lista completa das questões pendentes de classificação, com os únicos
--    metadados estruturados disponíveis para decidir (banca/concurso/ano) e
--    o enunciado por extenso (para leitura humana). Equivalente ao que
--    listar_questoes_nao_classificadas_admin(53) devolve via RPC — aqui em
--    SQL direto, só para conferência.
--
--    NÃO existe hoje nenhuma coluna de artigo/dispositivo em
--    public.questoes — a única forma confiável de saber a qual unidade uma
--    questão pertence é ler o enunciado.
-- ============================================================================
select
  q.id as questao_id,
  q.banca,
  q.concurso,
  q.ano,
  q.dificuldade,
  q.enunciado
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
  )
order by q.id;

-- ============================================================================
-- 4) SUGESTÃO de artigo citado no enunciado — SOMENTE UMA PISTA VISUAL para
--    quem for classificar manualmente, NUNCA usada para gravar nada.
--    Extração ingênua via regex ("art. 12-A", "art. 7º", "arts. 10 a 12-D")
--    que pode facilmente errar (referência a "art. 5º da CF", enunciado que
--    cita vários artigos, artigo mencionado sem ser o tema central da
--    questão etc.) — por isso é só uma coluna auxiliar nesta consulta de
--    apoio, nunca uma classificação automática. A classificação real
--    continua exigindo leitura humana do enunciado inteiro.
-- ============================================================================
select
  q.id as questao_id,
  q.banca,
  q.ano,
  (regexp_matches(q.enunciado, 'art(?:igo)?\.?\s*\d+[º°]?(?:-[A-Za-z])?', 'i'))[1] as pista_primeiro_artigo_citado,
  left(q.enunciado, 200) as enunciado_resumo
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
  )
order by q.id;

-- ============================================================================
-- 5) Exemplo de como classificar UMA questão depois de decidido (rode uma
--    vez por questão, com os ids reais) — NÃO execute em lote sem conferir
--    cada uma:
--
--    select public.classificar_questao_unidade_admin(
--      <questao_id_real>,
--      (select id from public.unidades_pedagogicas where curso_conteudo_id = 53 and ordem = <1 a 5>)
--    );
-- ============================================================================
