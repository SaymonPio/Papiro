-- Pos-check SOMENTE LEITURA da classificacao de questoes de
-- Editor de textos (curso_conteudos.id = 36).
--
-- Nenhuma escrita. Cada consulta abaixo tem o valor esperado indicado no
-- comentario; qualquer divergencia deve ser reportada, nao corrigida aqui.
--
-- NOTA: artigos_esperados = NULL na unidade (metodologia nao juridica). 2
-- exclusoes (Q791 — PROBLEMA_DE_FIDELIDADE_IMAGEM_Q791 confirmado por
-- fonte primaria; Q832 — DUPLICATA_Q832, mesma questao-fonte de Q91). 13
-- questoes classificadas, todas REAL (Fundatec) — 0 AUTORAL neste corpus.

-- 1) A unidade pedagogica do conteudo 36. Esperado: 1 linha, ordem 1,
--    artigos_esperados NULL, ativa.
select id, ordem, titulo, artigos_esperados, ativa
from public.unidades_pedagogicas
where curso_conteudo_id = 36
order by ordem;

-- 2) Contagem de questoes classificadas. Esperado: ordem 1 = 13.
select u.ordem, u.titulo, count(distinct qup.questao_id) as questoes_classificadas
from public.unidades_pedagogicas u
left join public.questao_unidades_pedagogicas qup on qup.unidade_pedagogica_id = u.id
where u.curso_conteudo_id = 36
group by u.ordem, u.titulo
order by u.ordem;

-- 3) Total de vinculos e questoes distintas. Esperado: 13 / 13.
select count(*) as total_vinculos, count(distinct qup.questao_id) as questoes_distintas
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 36;

-- 4) QIDs vinculados exatos. Esperado: 61,91,92,96,104,110,341,627,628,
--    629,701,769,831.
select qup.questao_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 36
order by qup.questao_id;

-- 5) Multiunidade. Esperado: 0 linhas.
select qup.questao_id, array_agg(u.ordem order by u.ordem) as unidades
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 36
group by qup.questao_id
having count(*) > 1;

-- 6) Questoes ativas do conteudo que ficaram SEM nenhuma classificacao E
--    NAO estao na lista de exclusoes (791, 832). Esperado: 0 linhas.
select q.id, q.enunciado
from public.questoes q
where q.ativa = true
  and q.materia_id = 9
  and q.assunto_id = 61
  and q.id not in (791, 832)
  and not exists (
    select 1
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where qup.questao_id = q.id and u.curso_conteudo_id = 36
  );

-- 7) Vazamento entre conteudos. Esperado: 0 linhas.
select qup.questao_id, qup.unidade_pedagogica_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
join public.curso_conteudos cc on cc.id = u.curso_conteudo_id
join public.curso_materias cm on cm.id = cc.curso_materia_id
join public.questoes q on q.id = qup.questao_id
where u.curso_conteudo_id = 36
  and (q.materia_id <> cm.materia_id or (cc.assunto_id is not null and q.assunto_id <> cc.assunto_id));

-- 8) Confirma banca de todas as 15 candidatas (todas REAL Fundatec) e
--    vinculo neste conteudo. Esperado: 15 linhas.
select q.id, q.banca, q.ano,
  (select count(*) from public.questao_unidades_pedagogicas qup2 join public.unidades_pedagogicas u2 on u2.id=qup2.unidade_pedagogica_id where qup2.questao_id=q.id and u2.curso_conteudo_id=36) as vinculo_neste_conteudo
from public.questoes q
where q.ativa = true and q.materia_id = 9 and q.assunto_id = 61
order by q.id;

-- 9) Q791 e Q832: permanecem ATIVAS, INTACTAS e SEM vinculo neste
--    conteudo. Esperado: ativa=true, assunto_id=61, vinculos_neste_conteudo=0.
select id, ativa, assunto_id,
  (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where qup.questao_id = q.id and u.curso_conteudo_id = 36) as vinculos_neste_conteudo
from public.questoes q
where id in (791, 832)
order by id;

-- 10) Q91: confirma vinculo (questao canonica da duplicata). Esperado: 1
--     vinculo, unidade 71df17f6-18a9-49c8-a8da-025329e43bc7.
select qup.questao_id, qup.unidade_pedagogica_id
from public.questao_unidades_pedagogicas qup
where qup.questao_id = 91;

-- 11) Q831: confirma vinculo (reavaliada e confirmada autossuficiente).
--     Esperado: 1 vinculo.
select qup.questao_id, qup.unidade_pedagogica_id
from public.questao_unidades_pedagogicas qup
where qup.questao_id = 831;

-- 12) Confirma artigos_esperados NULL na unidade e estado geral do
--     sistema.
select
  (select artigos_esperados is null from public.unidades_pedagogicas where curso_conteudo_id = 36) as artigos_esperados_null,
  (select count(*) from public.curso_conteudos) as total_conteudos,
  (select count(*) from public.unidades_pedagogicas) as total_unidades_sistema,
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos_sistema;
