-- Pos-check SOMENTE LEITURA da classificacao de questoes de
-- Concordancia nominal (curso_conteudos.id = 19).
--
-- Nenhuma escrita. Cada consulta abaixo tem o valor esperado indicado no
-- comentario; qualquer divergencia deve ser reportada, nao corrigida aqui.
--
-- NOTA: artigos_esperados = NULL (metodologia nao juridica). 2 exclusoes
-- pedagogicas intencionais (Q222, Q224, QUESTAO_HIBRIDA_MULTICONTEUDO).

-- 1) A unidade pedagogica do conteudo 19. Esperado: 1 linha, ordem 1,
--    artigos_esperados NULL, ativa.
select id, ordem, titulo, artigos_esperados, ativa
from public.unidades_pedagogicas
where curso_conteudo_id = 19
order by ordem;

-- 2) Contagem de questoes classificadas. Esperado: ordem 1 = 1.
select u.ordem, u.titulo, count(distinct qup.questao_id) as questoes_classificadas
from public.unidades_pedagogicas u
left join public.questao_unidades_pedagogicas qup on qup.unidade_pedagogica_id = u.id
where u.curso_conteudo_id = 19
group by u.ordem, u.titulo
order by u.ordem;

-- 3) Total de vinculos e questoes distintas. Esperado: 1 / 1.
select count(*) as total_vinculos, count(distinct qup.questao_id) as questoes_distintas
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 19;

-- 4) QID vinculado exato. Esperado: 223 (e nenhum outro).
select qup.questao_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 19
order by qup.questao_id;

-- 5) Multiunidade. Esperado: 0 linhas.
select qup.questao_id, array_agg(u.ordem order by u.ordem) as unidades
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 19
group by qup.questao_id
having count(*) > 1;

-- 6) Candidatas ativas sem classificacao nem exclusao registrada.
--    Esperado: 0 linhas (Q222 e Q224 sao as exclusoes intencionais,
--    ja documentadas em config/concordancia_nominal.mapa.json).
select q.id, q.enunciado
from public.questoes q
where q.ativa = true
  and q.materia_id = 6
  and q.assunto_id = 52
  and q.id not in (222, 224)
  and not exists (
    select 1
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where qup.questao_id = q.id and u.curso_conteudo_id = 19
  );

-- 7) Q222 e Q224 permanecem ativas, no assunto correto, sem vinculo.
--    Esperado: 2 linhas, ativa=true, assunto_id=52, vinculos=0 cada.
select id, ativa, assunto_id,
  (select count(*) from public.questao_unidades_pedagogicas where questao_id = q.id) as vinculos
from public.questoes q
where q.id in (222, 224)
order by q.id;

-- 8) Vazamento entre conteudos. Esperado: 0 linhas.
select qup.questao_id, qup.unidade_pedagogica_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
join public.curso_conteudos cc on cc.id = u.curso_conteudo_id
join public.curso_materias cm on cm.id = cc.curso_materia_id
join public.questoes q on q.id = qup.questao_id
where u.curso_conteudo_id = 19
  and (q.materia_id <> cm.materia_id or (cc.assunto_id is not null and q.assunto_id <> cc.assunto_id));

-- 9) Q116/Q318 (incidencia real externa) permanecem vinculadas a
--    Concordancia verbal (conteudo 18), nao a este conteudo.
--    Esperado: 2 linhas, curso_conteudo_id = 18 para ambas.
select qup.questao_id, u.curso_conteudo_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where qup.questao_id in (116, 318)
order by qup.questao_id;

-- 10) Confirma artigos_esperados NULL e estado geral do sistema.
select
  (select artigos_esperados is null from public.unidades_pedagogicas where curso_conteudo_id = 19) as artigos_esperados_null,
  (select count(*) from public.curso_conteudos) as total_conteudos,
  (select count(*) from public.unidades_pedagogicas) as total_unidades_sistema,
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos_sistema;
