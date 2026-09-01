-- Pos-check SOMENTE LEITURA da classificacao de questoes de
-- Quantificadores (curso_conteudos.id = 7).
--
-- Nenhuma escrita. Cada consulta abaixo tem o valor esperado indicado no
-- comentario; qualquer divergencia deve ser reportada, nao corrigida aqui.
--
-- NOTA: artigos_esperados = NULL na unidade (metodologia nao juridica). 0
-- exclusoes. 2 questoes classificadas: 1 row REAL (Fundatec: Q83) + 1
-- AUTORAL (Q288). Q287 foi previamente reclassificada para Negacao de
-- proposicoes (commit 4295319, assunto_id 33 -> 35) — por isso a fila
-- historica (ordem-curadoria.json, ordem 89) documenta 3 candidatas
-- enquanto o LIVE nesta curadoria e 2. Isso e cronologia, nao erro.

-- 1) A unidade pedagogica do conteudo 7. Esperado: 1 linha, ordem 1,
--    artigos_esperados NULL, ativa.
select id, ordem, titulo, artigos_esperados, ativa
from public.unidades_pedagogicas
where curso_conteudo_id = 7
order by ordem;

-- 2) Contagem de questoes classificadas. Esperado: ordem 1 = 2.
select u.ordem, u.titulo, count(distinct qup.questao_id) as questoes_classificadas
from public.unidades_pedagogicas u
left join public.questao_unidades_pedagogicas qup on qup.unidade_pedagogica_id = u.id
where u.curso_conteudo_id = 7
group by u.ordem, u.titulo
order by u.ordem;

-- 3) Total de vinculos e questoes distintas. Esperado: 2 / 2.
select count(*) as total_vinculos, count(distinct qup.questao_id) as questoes_distintas
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 7;

-- 4) QIDs vinculados exatos. Esperado: 83, 288.
select qup.questao_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 7
order by qup.questao_id;

-- 5) Multiunidade. Esperado: 0 linhas.
select qup.questao_id, array_agg(u.ordem order by u.ordem) as unidades
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 7
group by qup.questao_id
having count(*) > 1;

-- 6) Questoes ativas do conteudo (assunto_id=33) que ficaram SEM nenhuma
--    classificacao. Esperado: 0 linhas.
select q.id, q.enunciado
from public.questoes q
where q.ativa = true
  and q.materia_id = 18
  and q.assunto_id = 33
  and not exists (
    select 1
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where qup.questao_id = q.id and u.curso_conteudo_id = 7
  );

-- 7) Vazamento entre conteudos. Esperado: 0 linhas.
select qup.questao_id, qup.unidade_pedagogica_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
join public.curso_conteudos cc on cc.id = u.curso_conteudo_id
join public.curso_materias cm on cm.id = cc.curso_materia_id
join public.questoes q on q.id = qup.questao_id
where u.curso_conteudo_id = 7
  and (q.materia_id <> cm.materia_id or (cc.assunto_id is not null and q.assunto_id <> cc.assunto_id));

-- 8) Confirma banca das 2 candidatas (1 REAL + 1 AUTORAL) e vinculo
--    neste conteudo. Esperado: 2 linhas, ambas vinculo=1.
select q.id, q.banca, q.ano,
  (select count(*) from public.questao_unidades_pedagogicas qup2 join public.unidades_pedagogicas u2 on u2.id=qup2.unidade_pedagogica_id where qup2.questao_id=q.id and u2.curso_conteudo_id=7) as vinculo_neste_conteudo
from public.questoes q
where q.ativa = true and q.materia_id = 18 and q.assunto_id = 33
order by q.id;

-- 9) Confirma que a Q287 (reclassificada no commit 4295319) permanece
--    corretamente fora deste conteudo. Esperado: assunto_id=35,
--    vinculos_neste_conteudo=0, vinculos_conteudo_3=1.
select id, assunto_id,
  (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where qup.questao_id = q.id and u.curso_conteudo_id = 7) as vinculos_neste_conteudo,
  (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where qup.questao_id = q.id and u.curso_conteudo_id = 3) as vinculos_conteudo_3
from public.questoes q
where id = 287;

-- 10) Confirma que a unidade de Negacao de proposicoes permanece com
--     exatamente 8 vinculos (77,81,86,88,287,311,312,337) — nao tocada
--     por esta curadoria. Esperado: 8 linhas.
select qup.questao_id
from public.questao_unidades_pedagogicas qup
where qup.unidade_pedagogica_id = 'c6ccefae-14df-4760-8c1d-2822090a2a93'
order by qup.questao_id;

-- 11) Confirma artigos_esperados NULL na unidade e estado geral do
--     sistema.
select
  (select artigos_esperados is null from public.unidades_pedagogicas where curso_conteudo_id = 7) as artigos_esperados_null,
  (select count(*) from public.curso_conteudos) as total_conteudos,
  (select count(*) from public.unidades_pedagogicas) as total_unidades_sistema,
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos_sistema;
