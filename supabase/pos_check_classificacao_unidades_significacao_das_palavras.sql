-- Pos-check SOMENTE LEITURA da classificacao de questoes de
-- Significacao das palavras (curso_conteudos.id = 23).
--
-- Nenhuma escrita. Cada consulta abaixo tem o valor esperado indicado no
-- comentario; qualquer divergencia deve ser reportada, nao corrigida aqui.
--
-- NOTA: artigos_esperados = NULL (metodologia nao juridica). 1 exclusao
-- pedagogica intencional (Q68, QUESTAO_HIBRIDA_MULTICONTEUDO).

-- 1) A unidade pedagogica do conteudo 23. Esperado: 1 linha, ordem 1,
--    artigos_esperados NULL, ativa.
select id, ordem, titulo, artigos_esperados, ativa
from public.unidades_pedagogicas
where curso_conteudo_id = 23
order by ordem;

-- 2) Contagem de questoes classificadas. Esperado: ordem 1 = 3.
select u.ordem, u.titulo, count(distinct qup.questao_id) as questoes_classificadas
from public.unidades_pedagogicas u
left join public.questao_unidades_pedagogicas qup on qup.unidade_pedagogica_id = u.id
where u.curso_conteudo_id = 23
group by u.ordem, u.titulo
order by u.ordem;

-- 3) Total de vinculos e questoes distintas. Esperado: 3 / 3.
select count(*) as total_vinculos, count(distinct qup.questao_id) as questoes_distintas
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 23;

-- 4) QIDs vinculados exatos. Esperado: 122, 308, 317 (e nenhum outro).
select qup.questao_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 23
order by qup.questao_id;

-- 5) Multiunidade. Esperado: 0 linhas.
select qup.questao_id, array_agg(u.ordem order by u.ordem) as unidades
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 23
group by qup.questao_id
having count(*) > 1;

-- 6) Candidatas ativas sem classificacao nem exclusao registrada.
--    Esperado: 0 linhas (Q68 e a unica exclusao intencional, ja
--    documentada em config/significacao_das_palavras.mapa.json).
select q.id, q.enunciado
from public.questoes q
where q.ativa = true
  and q.materia_id = 6
  and q.assunto_id = 59
  and q.id <> 68
  and not exists (
    select 1
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where qup.questao_id = q.id and u.curso_conteudo_id = 23
  );

-- 7) Q68 permanece ativa, no assunto correto, sem vinculo. Esperado:
--    1 linha, ativa=true, assunto_id=59, vinculos=0.
select id, ativa, assunto_id,
  (select count(*) from public.questao_unidades_pedagogicas where questao_id = 68) as vinculos
from public.questoes
where id = 68;

-- 8) Vazamento entre conteudos. Esperado: 0 linhas.
select qup.questao_id, qup.unidade_pedagogica_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
join public.curso_conteudos cc on cc.id = u.curso_conteudo_id
join public.curso_materias cm on cm.id = cc.curso_materia_id
join public.questoes q on q.id = qup.questao_id
where u.curso_conteudo_id = 23
  and (q.materia_id <> cm.materia_id or (cc.assunto_id is not null and q.assunto_id <> cc.assunto_id));

-- 9) Saneamentos de Q68 e Q122 preservados. Esperado: todas as flags true.
select
  (select position('[04]' in enunciado) > 0 from public.questoes where id = 68) as q68_marcador_04,
  (select position('(l. 04)' in enunciado) > 0 from public.questoes where id = 68) as q68_citacao_04,
  (select position('[37]' in enunciado) > 0 from public.questoes where id = 122) as q122_marcador_37,
  (select position('NOTA DE SANEAMENTO' in explicacao) > 0 from public.questoes where id = 122) as q122_nota_saneamento;

-- 10) Confirma artigos_esperados NULL e estado geral do sistema.
select
  (select artigos_esperados is null from public.unidades_pedagogicas where curso_conteudo_id = 23) as artigos_esperados_null,
  (select count(*) from public.curso_conteudos) as total_conteudos,
  (select count(*) from public.unidades_pedagogicas) as total_unidades_sistema,
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos_sistema;
