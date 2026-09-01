-- Pos-check SOMENTE LEITURA da classificacao de questoes de
-- Equivalências lógicas (curso_conteudos.id = 5).
--
-- Nenhuma escrita. Cada consulta abaixo tem o valor esperado indicado no
-- comentario; qualquer divergencia deve ser reportada, nao corrigida aqui.
--
-- NOTA: artigos_esperados = NULL na unidade (metodologia nao juridica). 0
-- exclusoes. 3 questoes classificadas: 2 rows REAL (Fundatec: Q79, Q82)
-- + 1 AUTORAL (Q310). Diagnostico: GAP_DE_PRATICA (identidade
-- pedagogica propria, distinto de SEM_CORPUS_PROPRIO_POR_SOBREPOSICAO_
-- CURRICULAR, ver ordem 86/De Morgan). Q80/Q309 (assunto 39, Condicional
-- e contrapositiva) NAO fazem parte deste conteudo e NAO devem ser
-- tocadas.

-- 1) A unidade pedagogica do conteudo 5. Esperado: 1 linha, ordem 1,
--    artigos_esperados NULL, ativa.
select id, ordem, titulo, artigos_esperados, ativa
from public.unidades_pedagogicas
where curso_conteudo_id = 5
order by ordem;

-- 2) Contagem de questoes classificadas. Esperado: ordem 1 = 3.
select u.ordem, u.titulo, count(distinct qup.questao_id) as questoes_classificadas
from public.unidades_pedagogicas u
left join public.questao_unidades_pedagogicas qup on qup.unidade_pedagogica_id = u.id
where u.curso_conteudo_id = 5
group by u.ordem, u.titulo
order by u.ordem;

-- 3) Total de vinculos e questoes distintas. Esperado: 3 / 3.
select count(*) as total_vinculos, count(distinct qup.questao_id) as questoes_distintas
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 5;

-- 4) QIDs vinculados exatos. Esperado: 79, 82, 310.
select qup.questao_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 5
order by qup.questao_id;

-- 5) Multiunidade. Esperado: 0 linhas.
select qup.questao_id, array_agg(u.ordem order by u.ordem) as unidades
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 5
group by qup.questao_id
having count(*) > 1;

-- 6) Questoes ativas do conteudo (assunto_id=41) que ficaram SEM nenhuma
--    classificacao. Esperado: 0 linhas.
select q.id, q.enunciado
from public.questoes q
where q.ativa = true
  and q.materia_id = 18
  and q.assunto_id = 41
  and not exists (
    select 1
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where qup.questao_id = q.id and u.curso_conteudo_id = 5
  );

-- 7) Vazamento entre conteudos. Esperado: 0 linhas.
select qup.questao_id, qup.unidade_pedagogica_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
join public.curso_conteudos cc on cc.id = u.curso_conteudo_id
join public.curso_materias cm on cm.id = cc.curso_materia_id
join public.questoes q on q.id = qup.questao_id
where u.curso_conteudo_id = 5
  and (q.materia_id <> cm.materia_id or (cc.assunto_id is not null and q.assunto_id <> cc.assunto_id));

-- 8) Confirma banca das 3 candidatas (2 REAL + 1 AUTORAL) e vinculo
--    neste conteudo. Esperado: 3 linhas, todas vinculo=1.
select q.id, q.banca, q.ano,
  (select count(*) from public.questao_unidades_pedagogicas qup2 join public.unidades_pedagogicas u2 on u2.id=qup2.unidade_pedagogica_id where qup2.questao_id=q.id and u2.curso_conteudo_id=5) as vinculo_neste_conteudo
from public.questoes q
where q.ativa = true and q.materia_id = 18 and q.assunto_id = 41
order by q.id;

-- 9) Confirma que Q80/Q309 (candidatas externas descartadas pela
--    microauditoria) permanecem intactas: ativas, com seu assunto_id
--    original, e SEM vinculo neste conteudo. Esperado: assunto_id=39
--    para ambas; vinculos_neste_conteudo=0 para ambas.
select id, ativa, assunto_id,
  (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where qup.questao_id = q.id and u.curso_conteudo_id = 5) as vinculos_neste_conteudo
from public.questoes q
where id in (80, 309)
order by id;

-- 10) Confirma artigos_esperados NULL na unidade e estado geral do
--     sistema.
select
  (select artigos_esperados is null from public.unidades_pedagogicas where curso_conteudo_id = 5) as artigos_esperados_null,
  (select count(*) from public.curso_conteudos) as total_conteudos,
  (select count(*) from public.unidades_pedagogicas) as total_unidades_sistema,
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos_sistema;
