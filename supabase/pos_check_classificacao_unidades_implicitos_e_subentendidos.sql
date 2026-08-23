-- Pos-check SOMENTE LEITURA da classificacao de questoes de
-- Implicitos e subentendidos (curso_conteudos.id = 25).
--
-- Nenhuma escrita. Cada consulta abaixo tem o valor esperado indicado no
-- comentario; qualquer divergencia deve ser reportada, nao corrigida aqui.
--
-- NOTA: artigos_esperados = NULL (metodologia nao juridica). 0 exclusoes.
-- Q878 e REAL (Fundatec) — unica incidencia real deste conteudo; Q234,
-- Q235 e Q236 sao AUTORAL_PAPIRO (cobertura suplementar). O vinculo de
-- Q878 ja existia antes desta curadoria, criado em operacao de
-- saneamento taxonomico separada e ja commitada (commit 5856a10) — as
-- consultas abaixo confirmam que ele permanece intacto e unico, sem
-- duplicacao.

-- 1) A unidade pedagogica do conteudo 25. Esperado: 1 linha, ordem 1,
--    artigos_esperados NULL, ativa.
select id, ordem, titulo, artigos_esperados, ativa
from public.unidades_pedagogicas
where curso_conteudo_id = 25
order by ordem;

-- 2) Contagem de questoes classificadas. Esperado: ordem 1 = 4.
select u.ordem, u.titulo, count(distinct qup.questao_id) as questoes_classificadas
from public.unidades_pedagogicas u
left join public.questao_unidades_pedagogicas qup on qup.unidade_pedagogica_id = u.id
where u.curso_conteudo_id = 25
group by u.ordem, u.titulo
order by u.ordem;

-- 3) Total de vinculos e questoes distintas. Esperado: 4 / 4.
select count(*) as total_vinculos, count(distinct qup.questao_id) as questoes_distintas
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 25;

-- 4) QIDs vinculados exatos, com contagem individual de vinculo por QID.
--    Esperado: 234, 235, 236, 878 — todos com exatamente 1 vinculo cada
--    (Q878 sem duplicacao do vinculo pre-existente do commit 5856a10).
select qup.questao_id, count(*) as vinculos_deste_qid
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 25
group by qup.questao_id
order by qup.questao_id;

-- 5) Multiunidade. Esperado: 0 linhas.
select qup.questao_id, array_agg(u.ordem order by u.ordem) as unidades
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 25
group by qup.questao_id
having count(*) > 1;

-- 6) Candidatas ativas sem classificacao. Esperado: 0 linhas.
select q.id, q.enunciado
from public.questoes q
where q.ativa = true
  and q.materia_id = 6
  and q.assunto_id = 46
  and not exists (
    select 1
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where qup.questao_id = q.id and u.curso_conteudo_id = 25
  );

-- 7) Vazamento entre conteudos. Esperado: 0 linhas.
select qup.questao_id, qup.unidade_pedagogica_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
join public.curso_conteudos cc on cc.id = u.curso_conteudo_id
join public.curso_materias cm on cm.id = cc.curso_materia_id
join public.questoes q on q.id = qup.questao_id
where u.curso_conteudo_id = 25
  and (q.materia_id <> cm.materia_id or (cc.assunto_id is not null and q.assunto_id <> cc.assunto_id));

-- 8) REAL x AUTORAL por questao. Esperado: 878 = Fundatec (REAL); 234,
--    235, 236 = Papiro (AUTORAL_PAPIRO).
select q.id, q.banca, q.concurso, q.ano
from public.questoes q
join public.questao_unidades_pedagogicas qup on qup.questao_id = q.id
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 25
order by q.id;

-- 9) Confirma artigos_esperados NULL e estado geral do sistema.
select
  (select artigos_esperados is null from public.unidades_pedagogicas where curso_conteudo_id = 25) as artigos_esperados_null,
  (select count(*) from public.curso_conteudos) as total_conteudos,
  (select count(*) from public.unidades_pedagogicas) as total_unidades_sistema,
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos_sistema;

-- 10) Classes de palavras (curso_conteudo_id 22, ja concluido) permanece
--     intocado por esta operacao. Esperado (baseline confirmado no
--     saneamento Q878, commit 5856a10): vinculos_22 = 16.
select
  (select count(*) from public.questao_unidades_pedagogicas qup
     join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
     where u.curso_conteudo_id = 22) as vinculos_classes_de_palavras;
