-- Pos-check SOMENTE LEITURA da classificacao de questoes de
-- Internet e navegadores (curso_conteudos.id = 38).
--
-- Nenhuma escrita. Cada consulta abaixo tem o valor esperado indicado no
-- comentario; qualquer divergencia deve ser reportada, nao corrigida aqui.
--
-- NOTA: artigos_esperados = NULL nas 2 unidades (metodologia nao
-- juridica). 3 exclusoes por fidelidade (Q64, Q496, Q497 —
-- PENDENCIA_DE_FIDELIDADE_VISUAL/PROBLEMA_DE_FIDELIDADE_IMAGEM, nao
-- taxonomia). Q635 ja foi saneada para Correio eletronico (commit
-- de45a7b) e nao consta aqui. Todas as 18 questoes classificadas sao
-- REAL (Fundatec) — 0 AUTORAL neste corpus.

-- 1) As 2 unidades pedagogicas do conteudo 38. Esperado: 2 linhas,
--    ordem 1 e 2, artigos_esperados NULL, ativas.
select id, ordem, titulo, artigos_esperados, ativa
from public.unidades_pedagogicas
where curso_conteudo_id = 38
order by ordem;

-- 2) Contagem de questoes classificadas por unidade. Esperado:
--    ordem 1 = 10, ordem 2 = 8.
select u.ordem, u.titulo, count(distinct qup.questao_id) as questoes_classificadas
from public.unidades_pedagogicas u
left join public.questao_unidades_pedagogicas qup on qup.unidade_pedagogica_id = u.id
where u.curso_conteudo_id = 38
group by u.ordem, u.titulo
order by u.ordem;

-- 3) Total de vinculos e questoes distintas no conteudo. Esperado:
--    total_vinculos = 18, questoes_distintas = 18.
select count(*) as total_vinculos, count(distinct qup.questao_id) as questoes_distintas
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 38;

-- 4) QIDs vinculados exatos, por unidade.
select u.ordem, qup.questao_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 38
order by u.ordem, qup.questao_id;

-- 5) Multiunidade (vinculadas a mais de uma unidade do conteudo).
--    Esperado: nenhuma.
select qup.questao_id, array_agg(u.ordem order by u.ordem) as unidades
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 38
group by qup.questao_id
having count(*) > 1;

-- 6) Questoes ativas do conteudo que ficaram SEM nenhuma classificacao
--    E NAO estao na lista de exclusoes por fidelidade (64, 496, 497).
--    Esperado: 0 linhas.
select q.id, q.enunciado
from public.questoes q
where q.ativa = true
  and q.materia_id = 9
  and q.assunto_id = 62
  and q.id not in (64, 496, 497)
  and not exists (
    select 1
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where qup.questao_id = q.id and u.curso_conteudo_id = 38
  );

-- 7) Vazamento entre conteudos. Esperado: 0 linhas.
select qup.questao_id, qup.unidade_pedagogica_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
join public.curso_conteudos cc on cc.id = u.curso_conteudo_id
join public.curso_materias cm on cm.id = cc.curso_materia_id
join public.questoes q on q.id = qup.questao_id
where u.curso_conteudo_id = 38
  and (q.materia_id <> cm.materia_id or (cc.assunto_id is not null and q.assunto_id <> cc.assunto_id));

-- 8) Confirma banca REAL (Fundatec) nas 18 vinculadas e nas 3
--    excluidas. Esperado: 21 linhas, todas banca='Fundatec'.
select q.id, q.banca,
  (select count(*) from public.questao_unidades_pedagogicas qup2 join public.unidades_pedagogicas u2 on u2.id=qup2.unidade_pedagogica_id where qup2.questao_id=q.id and u2.curso_conteudo_id=38) as vinculo_neste_conteudo
from public.questoes q
where q.ativa = true and q.materia_id = 9 and q.assunto_id = 62
order by q.id;

-- 9) Q64, Q496, Q497: permanecem ATIVAS, INTACTAS e SEM vinculo neste
--    conteudo. Esperado: ativa=true, assunto_id=62, vinculos=0.
select id, ativa, assunto_id,
  (select count(*) from public.questao_unidades_pedagogicas where questao_id = q.id) as vinculos
from public.questoes q
where id in (64, 496, 497)
order by id;

-- 10) Q635: confirma que permanece intacta em Correio eletronico
--     (curso_conteudo_id 39), fora deste conteudo. Esperado:
--     assunto_id=60, vinculo em unidade do conteudo 39, 0 vinculo aqui.
select id, assunto_id,
  (select unidade_pedagogica_id from public.questao_unidades_pedagogicas where questao_id = q.id) as unidade_vinculada
from public.questoes q where id = 635;

-- 11) Confirma artigos_esperados NULL nas 2 unidades e estado geral do
--     sistema.
select
  bool_and(artigos_esperados is null) as artigos_esperados_null_ambas,
  (select count(*) from public.curso_conteudos) as total_conteudos,
  (select count(*) from public.unidades_pedagogicas) as total_unidades_sistema,
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos_sistema
from public.unidades_pedagogicas
where curso_conteudo_id = 38;
