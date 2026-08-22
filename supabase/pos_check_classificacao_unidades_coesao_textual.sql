-- Pos-check SOMENTE LEITURA da classificacao de questoes de Coesao
-- textual (curso_conteudos.id = 13) — gerado seguindo o mesmo template
-- de scripts/curadoria-pedagogica/gerar-pos-check.mjs.
--
-- Nenhuma escrita. Cada consulta abaixo tem o valor esperado indicado no
-- comentario; qualquer divergencia deve ser reportada, nao corrigida aqui.
--
-- NOTA: artigos_esperados = NULL (metodologia nao juridica). 0 exclusoes.
-- Depende de saneamento controlado ja concluido (commit 51e5851).

-- 1) A unidade pedagogica do conteudo 13. Esperado: 1 linha, ordem 1,
--    artigos_esperados NULL, ativa.
select id, ordem, titulo, artigos_esperados, ativa
from public.unidades_pedagogicas
where curso_conteudo_id = 13
order by ordem;

-- 2) Contagem de questoes classificadas. Esperado: ordem 1 = 7.
select u.ordem, u.titulo, count(distinct qup.questao_id) as questoes_classificadas
from public.unidades_pedagogicas u
left join public.questao_unidades_pedagogicas qup on qup.unidade_pedagogica_id = u.id
where u.curso_conteudo_id = 13
group by u.ordem, u.titulo
order by u.ordem;

-- 3) Total de vinculos e questoes distintas. Esperado: 7 / 7.
select count(*) as total_vinculos, count(distinct qup.questao_id) as questoes_distintas
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 13;

-- 4) Multiunidade. Esperado: 0 linhas.
select qup.questao_id, array_agg(u.ordem order by u.ordem) as unidades
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 13
group by qup.questao_id
having count(*) > 1;

-- 5) Candidatas ativas sem classificacao. Esperado: 0 linhas.
select q.id, q.enunciado
from public.questoes q
where q.ativa = true
  and q.materia_id = 6
  and q.assunto_id = 55
  and not exists (
    select 1
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where qup.questao_id = q.id and u.curso_conteudo_id = 13
  );

-- 6) Vazamento entre conteudos. Esperado: 0 linhas.
select qup.questao_id, qup.unidade_pedagogica_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
join public.curso_conteudos cc on cc.id = u.curso_conteudo_id
join public.curso_materias cm on cm.id = cc.curso_materia_id
join public.questoes q on q.id = qup.questao_id
where u.curso_conteudo_id = 13
  and (q.materia_id <> cm.materia_id or (cc.assunto_id is not null and q.assunto_id <> cc.assunto_id));

-- 7) Estado do saneamento controlado (commit 51e5851): Q683 assunto_id
--    e Q684 sem vinculo em nenhum conteudo.
select
  (select assunto_id from public.questoes where id = 683) as q683_assunto_id,
  (select count(*) from public.questao_unidades_pedagogicas where questao_id = 684) as q684_vinculos_total,
  (select position('[01]' in enunciado) > 0 from public.questoes where id = 69) as q69_tem_marcador;

-- 8) Estado LIVE do conteudo 22 (Classes de palavras, ja concluido).
--    Esperado: unidades_22=1, vinculos_22=16, candidatas_22_live=20.
select
  (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 22) as unidades_22,
  (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where u.curso_conteudo_id = 22) as vinculos_22,
  (
    select count(*) from public.questoes q
    join public.curso_conteudos cc on cc.id = 22
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where q.ativa = true and q.materia_id = cm.materia_id and (cc.assunto_id is null or q.assunto_id = cc.assunto_id)
  ) as candidatas_22_live;

-- 9) Conteudos 20, 26, 31, 33, 34 (ja concluidos) permanecem intocados.
--    Esperado (baseline): unidades_20=1 vinculos_20=22, unidades_26=1
--    vinculos_26=15, unidades_31=1 vinculos_31=11, unidades_33=1
--    vinculos_33=13, unidades_34=1 vinculos_34=13.
select
  (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 20) as unidades_20,
  (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where u.curso_conteudo_id = 20) as vinculos_20,
  (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 26) as unidades_26,
  (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where u.curso_conteudo_id = 26) as vinculos_26,
  (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 31) as unidades_31,
  (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where u.curso_conteudo_id = 31) as vinculos_31,
  (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 33) as unidades_33,
  (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where u.curso_conteudo_id = 33) as vinculos_33,
  (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 34) as unidades_34,
  (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where u.curso_conteudo_id = 34) as vinculos_34;

-- 10) Confirma artigos_esperados NULL e estado geral do sistema.
select
  (select artigos_esperados is null from public.unidades_pedagogicas where curso_conteudo_id = 13) as artigos_esperados_null,
  (select count(*) from public.curso_conteudos) as total_conteudos,
  (select count(*) from public.unidades_pedagogicas) as total_unidades_sistema,
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos_sistema;
