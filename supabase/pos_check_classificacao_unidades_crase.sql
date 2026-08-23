-- Pos-check SOMENTE LEITURA da classificacao de questoes de Crase
-- (curso_conteudos.id = 15) — gerado seguindo o mesmo template de
-- scripts/curadoria-pedagogica/gerar-pos-check.mjs.
--
-- Nenhuma escrita. Cada consulta abaixo tem o valor esperado indicado no
-- comentario; qualquer divergencia deve ser reportada, nao corrigida aqui.
--
-- NOTA: artigos_esperados = NULL (metodologia nao juridica). 0 exclusoes.
-- Q328 ja foi saneada separadamente (commit 79e9c97) e este apply nao
-- deveria ter alterado seu enunciado/explicacao/gabarito.

-- 1) A unidade pedagogica do conteudo 15. Esperado: 1 linha, ordem 1,
--    artigos_esperados NULL, ativa.
select id, ordem, titulo, artigos_esperados, ativa
from public.unidades_pedagogicas
where curso_conteudo_id = 15
order by ordem;

-- 2) Contagem de questoes classificadas. Esperado: ordem 1 = 4.
select u.ordem, u.titulo, count(distinct qup.questao_id) as questoes_classificadas
from public.unidades_pedagogicas u
left join public.questao_unidades_pedagogicas qup on qup.unidade_pedagogica_id = u.id
where u.curso_conteudo_id = 15
group by u.ordem, u.titulo
order by u.ordem;

-- 3) Total de vinculos e questoes distintas. Esperado: 4 / 4.
select count(*) as total_vinculos, count(distinct qup.questao_id) as questoes_distintas
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 15;

-- 4) Multiunidade. Esperado: 0 linhas.
select qup.questao_id, array_agg(u.ordem order by u.ordem) as unidades
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 15
group by qup.questao_id
having count(*) > 1;

-- 5) Candidatas ativas sem classificacao. Esperado: 0 linhas.
select q.id, q.enunciado
from public.questoes q
where q.ativa = true
  and q.materia_id = 6
  and q.assunto_id = 5
  and not exists (
    select 1
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where qup.questao_id = q.id and u.curso_conteudo_id = 15
  );

-- 6) Vazamento entre conteudos. Esperado: 0 linhas.
select qup.questao_id, qup.unidade_pedagogica_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
join public.curso_conteudos cc on cc.id = u.curso_conteudo_id
join public.curso_materias cm on cm.id = cc.curso_materia_id
join public.questoes q on q.id = qup.questao_id
where u.curso_conteudo_id = 15
  and (q.materia_id <> cm.materia_id or (cc.assunto_id is not null and q.assunto_id <> cc.assunto_id));

-- 7) VERIFICACAO ESPECIAL Q328: confirma que o saneamento (commit
--    79e9c97) permanece intacto apos este apply pedagogico.
select
  (position('[01]' in enunciado) > 0) as tem_01,
  (position('[17]' in enunciado) > 0) as tem_17,
  (position('[19]' in enunciado) > 0) as tem_19,
  (position('[20]' in enunciado) > 0) as tem_20,
  (position('[28]' in enunciado) > 0) as tem_28,
  (position('[36]' in enunciado) > 0) as tem_36,
  (position('adaptadas' in enunciado) > 0) as ainda_tem_parafrase_antiga,
  (position('Bechara' in explicacao) > 0) as expl_tem_bechara,
  (position('Cegalla' in explicacao) > 0) as expl_tem_cegalla
from public.questoes where id = 328;

select ordem, texto, correta from public.alternativas where questao_id = 328 order by ordem;

-- 8) Confirma artigos_esperados NULL e estado geral do sistema.
select
  (select artigos_esperados is null from public.unidades_pedagogicas where curso_conteudo_id = 15) as artigos_esperados_null,
  (select count(*) from public.curso_conteudos) as total_conteudos,
  (select count(*) from public.unidades_pedagogicas) as total_unidades_sistema,
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos_sistema;
