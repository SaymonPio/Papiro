-- Pos-check SOMENTE LEITURA da classificacao de questoes de
-- Windows (curso_conteudos.id = 35).
--
-- Nenhuma escrita. Cada consulta abaixo tem o valor esperado indicado no
-- comentario; qualquer divergencia deve ser reportada, nao corrigida aqui.
--
-- NOTA: artigos_esperados = NULL na unidade (metodologia nao juridica). 1
-- exclusao (Q836, DUPLICATA_Q836 — mesma questao-fonte de Q101, nao e
-- taxonomia). 14 questoes classificadas: 14 rows REAL (Fundatec) + 1
-- AUTORAL (Q31, cobertura suplementar).

-- 1) A unidade pedagogica do conteudo 35. Esperado: 1 linha, ordem 1,
--    artigos_esperados NULL, ativa.
select id, ordem, titulo, artigos_esperados, ativa
from public.unidades_pedagogicas
where curso_conteudo_id = 35
order by ordem;

-- 2) Contagem de questoes classificadas. Esperado: ordem 1 = 14.
select u.ordem, u.titulo, count(distinct qup.questao_id) as questoes_classificadas
from public.unidades_pedagogicas u
left join public.questao_unidades_pedagogicas qup on qup.unidade_pedagogica_id = u.id
where u.curso_conteudo_id = 35
group by u.ordem, u.titulo
order by u.ordem;

-- 3) Total de vinculos e questoes distintas. Esperado: 14 / 14.
select count(*) as total_vinculos, count(distinct qup.questao_id) as questoes_distintas
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 35;

-- 4) QIDs vinculados exatos. Esperado: 31,60,101,102,103,108,338,339,494,
--    643,644,645,711,835.
select qup.questao_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 35
order by qup.questao_id;

-- 5) Multiunidade. Esperado: 0 linhas.
select qup.questao_id, array_agg(u.ordem order by u.ordem) as unidades
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 35
group by qup.questao_id
having count(*) > 1;

-- 6) Questoes ativas do conteudo que ficaram SEM nenhuma classificacao E
--    NAO estao na lista de exclusoes (836). Esperado: 0 linhas.
select q.id, q.enunciado
from public.questoes q
where q.ativa = true
  and q.materia_id = 9
  and q.assunto_id = 28
  and q.id <> 836
  and not exists (
    select 1
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where qup.questao_id = q.id and u.curso_conteudo_id = 35
  );

-- 7) Vazamento entre conteudos. Esperado: 0 linhas.
select qup.questao_id, qup.unidade_pedagogica_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
join public.curso_conteudos cc on cc.id = u.curso_conteudo_id
join public.curso_materias cm on cm.id = cc.curso_materia_id
join public.questoes q on q.id = qup.questao_id
where u.curso_conteudo_id = 35
  and (q.materia_id <> cm.materia_id or (cc.assunto_id is not null and q.assunto_id <> cc.assunto_id));

-- 8) Confirma banca de todas as 15 candidatas (14 REAL Fundatec + 1
--    AUTORAL Q31) e vinculo neste conteudo. Esperado: 15 linhas.
select q.id, q.banca, q.ano,
  (select count(*) from public.questao_unidades_pedagogicas qup2 join public.unidades_pedagogicas u2 on u2.id=qup2.unidade_pedagogica_id where qup2.questao_id=q.id and u2.curso_conteudo_id=35) as vinculo_neste_conteudo
from public.questoes q
where q.ativa = true and q.materia_id = 9 and q.assunto_id = 28
order by q.id;

-- 9) Q836: permanece ATIVA, INTACTA e SEM vinculo neste conteudo. Esperado:
--    ativa=true, assunto_id=28, vinculos_neste_conteudo=0.
select id, ativa, assunto_id, enunciado,
  (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where qup.questao_id = q.id and u.curso_conteudo_id = 35) as vinculos_neste_conteudo
from public.questoes q
where id = 836;

-- 10) Q101: confirma vinculo (questao canonica da duplicata). Esperado: 1
--     vinculo, unidade 936d2d9d-0f83-4a25-8066-9e035a12ca16.
select qup.questao_id, qup.unidade_pedagogica_id
from public.questao_unidades_pedagogicas qup
where qup.questao_id = 101;

-- 11) Q31: confirma vinculo apesar do metadado nao padronizado (banca,
--     ano). Esperado: 1 linha, banca='Papiro - estilo Fundatec', ano NULL,
--     1 vinculo.
select q.id, q.banca, q.ano,
  (select count(*) from public.questao_unidades_pedagogicas where questao_id = q.id) as vinculos
from public.questoes q where id = 31;

-- 12) Confirma artigos_esperados NULL na unidade e estado geral do
--     sistema.
select
  (select artigos_esperados is null from public.unidades_pedagogicas where curso_conteudo_id = 35) as artigos_esperados_null,
  (select count(*) from public.curso_conteudos) as total_conteudos,
  (select count(*) from public.unidades_pedagogicas) as total_unidades_sistema,
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos_sistema;
