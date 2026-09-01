-- Pos-check SOMENTE LEITURA da classificacao de questoes de
-- Tabela-verdade (curso_conteudos.id = 2).
--
-- Nenhuma escrita. Cada consulta abaixo tem o valor esperado indicado no
-- comentario; qualquer divergencia deve ser reportada, nao corrigida aqui.
--
-- NOTA: artigos_esperados = NULL na unidade (metodologia nao juridica). 0
-- exclusoes. 2 questoes classificadas (2 rows REAL: Q75, Q89). A Q89 foi
-- previamente saneada por fidelidade estrutural (commit 1eb3fa9) e a
-- Q314 foi previamente reclassificada para Proposicoes e conectivos
-- (commit eee1f6b, assunto_id 38 -> 36) — por isso a fila historica
-- (ordem-curadoria.json, ordem 85) documenta 3 candidatas enquanto o
-- LIVE nesta curadoria e 2. Isso e cronologia, nao erro.

-- 1) A unidade pedagogica do conteudo 2. Esperado: 1 linha, ordem 1,
--    artigos_esperados NULL, ativa.
select id, ordem, titulo, artigos_esperados, ativa
from public.unidades_pedagogicas
where curso_conteudo_id = 2
order by ordem;

-- 2) Contagem de questoes classificadas. Esperado: ordem 1 = 2.
select u.ordem, u.titulo, count(distinct qup.questao_id) as questoes_classificadas
from public.unidades_pedagogicas u
left join public.questao_unidades_pedagogicas qup on qup.unidade_pedagogica_id = u.id
where u.curso_conteudo_id = 2
group by u.ordem, u.titulo
order by u.ordem;

-- 3) Total de vinculos e questoes distintas. Esperado: 2 / 2.
select count(*) as total_vinculos, count(distinct qup.questao_id) as questoes_distintas
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 2;

-- 4) QIDs vinculados exatos. Esperado: 75, 89.
select qup.questao_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 2
order by qup.questao_id;

-- 5) Multiunidade. Esperado: 0 linhas.
select qup.questao_id, array_agg(u.ordem order by u.ordem) as unidades
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 2
group by qup.questao_id
having count(*) > 1;

-- 6) Questoes ativas do conteudo (assunto_id=38) que ficaram SEM nenhuma
--    classificacao. Esperado: 0 linhas.
select q.id, q.enunciado
from public.questoes q
where q.ativa = true
  and q.materia_id = 18
  and q.assunto_id = 38
  and not exists (
    select 1
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where qup.questao_id = q.id and u.curso_conteudo_id = 2
  );

-- 7) Vazamento entre conteudos. Esperado: 0 linhas.
select qup.questao_id, qup.unidade_pedagogica_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
join public.curso_conteudos cc on cc.id = u.curso_conteudo_id
join public.curso_materias cm on cm.id = cc.curso_materia_id
join public.questoes q on q.id = qup.questao_id
where u.curso_conteudo_id = 2
  and (q.materia_id <> cm.materia_id or (cc.assunto_id is not null and q.assunto_id <> cc.assunto_id));

-- 8) Confirma banca das 2 candidatas (2 REAL) e vinculo neste conteudo.
--    Esperado: 2 linhas, ambas vinculo=1, banca='Fundatec'.
select q.id, q.banca, q.ano,
  (select count(*) from public.questao_unidades_pedagogicas qup2 join public.unidades_pedagogicas u2 on u2.id=qup2.unidade_pedagogica_id where qup2.questao_id=q.id and u2.curso_conteudo_id=2) as vinculo_neste_conteudo
from public.questoes q
where q.ativa = true and q.materia_id = 18 and q.assunto_id = 38
order by q.id;

-- 9) Confirma que a Q89 preserva o saneamento de fidelidade (commit
--    1eb3fa9): tabela de 8 linhas com lacunas nas linhas 2/4/6/8,
--    gabarito D, sem vazamento de resposta no enunciado. Esperado:
--    todas as checagens = true.
select
  position('| 2 | V | V | F | F | V | F | ? |' in enunciado) > 0 as linha2_lacuna_ok,
  position('| 4 | V | F | F | V | V | F | ? |' in enunciado) > 0 as linha4_lacuna_ok,
  position('| 6 | F | V | F | F | V | F | ? |' in enunciado) > 0 as linha6_lacuna_ok,
  position('| 8 | F | F | F | V | F | F | ? |' in enunciado) > 0 as linha8_lacuna_ok,
  position('F – F – F – V' in enunciado) = 0 as resposta_nao_vazada,
  position('NOTA DE SANEAMENTO' in explicacao) > 0 as contem_nota_saneamento
from public.questoes where id = 89;

-- 10) Confirma que a Q314 permanece corretamente reclassificada
--     (commit eee1f6b) e NAO pertence a este conteudo. Esperado:
--     assunto_id=36, vinculos_neste_conteudo=0, vinculos_conteudo_1=1.
select id, assunto_id,
  (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where qup.questao_id = q.id and u.curso_conteudo_id = 2) as vinculos_neste_conteudo,
  (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where qup.questao_id = q.id and u.curso_conteudo_id = 1) as vinculos_conteudo_1
from public.questoes q
where id = 314;

-- 11) Confirma artigos_esperados NULL na unidade e estado geral do
--     sistema.
select
  (select artigos_esperados is null from public.unidades_pedagogicas where curso_conteudo_id = 2) as artigos_esperados_null,
  (select count(*) from public.curso_conteudos) as total_conteudos,
  (select count(*) from public.unidades_pedagogicas) as total_unidades_sistema,
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos_sistema;
