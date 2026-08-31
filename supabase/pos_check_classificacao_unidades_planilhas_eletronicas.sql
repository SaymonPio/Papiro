-- Pos-check SOMENTE LEITURA da classificacao de questoes de
-- Planilhas eletrônicas (curso_conteudos.id = 37).
--
-- Nenhuma escrita. Cada consulta abaixo tem o valor esperado indicado no
-- comentario; qualquer divergencia deve ser reportada, nao corrigida aqui.
--
-- NOTA: artigos_esperados = NULL na unidade (metodologia nao juridica). 2
-- exclusoes (Q495 — PROBLEMA_DE_FIDELIDADE_IMAGEM_Q495 confirmado por
-- fonte primaria; Q499 — DUPLICATA_DE_FONTE_REFORMULADA, canonica Q105).
-- 13 questoes classificadas: 12 rows REAL (Fundatec) + 1 AUTORAL (Q33).

-- 1) A unidade pedagogica do conteudo 37. Esperado: 1 linha, ordem 1,
--    artigos_esperados NULL, ativa.
select id, ordem, titulo, artigos_esperados, ativa
from public.unidades_pedagogicas
where curso_conteudo_id = 37
order by ordem;

-- 2) Contagem de questoes classificadas. Esperado: ordem 1 = 13.
select u.ordem, u.titulo, count(distinct qup.questao_id) as questoes_classificadas
from public.unidades_pedagogicas u
left join public.questao_unidades_pedagogicas qup on qup.unidade_pedagogica_id = u.id
where u.curso_conteudo_id = 37
group by u.ordem, u.titulo
order by u.ordem;

-- 3) Total de vinculos e questoes distintas. Esperado: 13 / 13.
select count(*) as total_vinculos, count(distinct qup.questao_id) as questoes_distintas
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 37;

-- 4) QIDs vinculados exatos. Esperado: 33,62,93,97,105,109,340,492,493,
--    498,637,638,834.
select qup.questao_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 37
order by qup.questao_id;

-- 5) Multiunidade. Esperado: 0 linhas.
select qup.questao_id, array_agg(u.ordem order by u.ordem) as unidades
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 37
group by qup.questao_id
having count(*) > 1;

-- 6) Questoes ativas do conteudo que ficaram SEM nenhuma classificacao E
--    NAO estao na lista de exclusoes (495, 499). Esperado: 0 linhas.
select q.id, q.enunciado
from public.questoes q
where q.ativa = true
  and q.materia_id = 9
  and q.assunto_id = 29
  and q.id not in (495, 499)
  and not exists (
    select 1
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where qup.questao_id = q.id and u.curso_conteudo_id = 37
  );

-- 7) Vazamento entre conteudos. Esperado: 0 linhas.
select qup.questao_id, qup.unidade_pedagogica_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
join public.curso_conteudos cc on cc.id = u.curso_conteudo_id
join public.curso_materias cm on cm.id = cc.curso_materia_id
join public.questoes q on q.id = qup.questao_id
where u.curso_conteudo_id = 37
  and (q.materia_id <> cm.materia_id or (cc.assunto_id is not null and q.assunto_id <> cc.assunto_id));

-- 8) Confirma banca de todas as 15 candidatas (14 REAL Fundatec + 1
--    AUTORAL Q33) e vinculo neste conteudo. Esperado: 15 linhas.
select q.id, q.banca, q.ano,
  (select count(*) from public.questao_unidades_pedagogicas qup2 join public.unidades_pedagogicas u2 on u2.id=qup2.unidade_pedagogica_id where qup2.questao_id=q.id and u2.curso_conteudo_id=37) as vinculo_neste_conteudo
from public.questoes q
where q.ativa = true and q.materia_id = 9 and q.assunto_id = 29
order by q.id;

-- 9) Q495 e Q499: permanecem ATIVAS, INTACTAS e SEM vinculo neste
--    conteudo. Esperado: ativa=true, assunto_id=29, vinculos_neste_conteudo=0.
select id, ativa, assunto_id,
  (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where qup.questao_id = q.id and u.curso_conteudo_id = 37) as vinculos_neste_conteudo
from public.questoes q
where id in (495, 499)
order by id;

-- 10) Q105: confirma vinculo (questao canonica da duplicata de fonte
--     reformulada). Esperado: 1 vinculo.
select qup.questao_id, qup.unidade_pedagogica_id
from public.questao_unidades_pedagogicas qup
where qup.questao_id = 105;

-- 11) Q498: confirma vinculo apesar da pendencia de fidelidade visual
--     nao bloqueante. Esperado: 1 vinculo.
select qup.questao_id, qup.unidade_pedagogica_id
from public.questao_unidades_pedagogicas qup
where qup.questao_id = 498;

-- 12) Q492/Q493: confirmam vinculo (reavaliadas e confirmadas
--     autossuficientes). Esperado: 1 vinculo cada.
select qup.questao_id, qup.unidade_pedagogica_id
from public.questao_unidades_pedagogicas qup
where qup.questao_id in (492, 493)
order by qup.questao_id;

-- 13) Confirma artigos_esperados NULL na unidade e estado geral do
--     sistema.
select
  (select artigos_esperados is null from public.unidades_pedagogicas where curso_conteudo_id = 37) as artigos_esperados_null,
  (select count(*) from public.curso_conteudos) as total_conteudos,
  (select count(*) from public.unidades_pedagogicas) as total_unidades_sistema,
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos_sistema;
