-- Pos-check SOMENTE LEITURA da classificacao de questoes de
-- Tempos e modos verbais (curso_conteudos.id = 31) — gerado seguindo o
-- mesmo template de scripts/curadoria-pedagogica/gerar-pos-check.mjs.
--
-- Nenhuma escrita. Cada consulta abaixo tem o valor esperado indicado no
-- comentario; qualquer divergencia deve ser reportada, nao corrigida aqui.
--
-- NOTA: artigos_esperados = NULL para toda a unidade (metodologia nao
-- juridica). 2 exclusoes intencionais: Q693 (FORA_DE_ESCOPO_MORFOLOGIA_LOCUCAO_VERBAL)
-- e Q893 (QUESTAO_HIBRIDA_MULTICONTEUDO). Sobreposicao tematica (nao
-- duplicata) com os conteudos 20, 26 e 34 (ja concluidos).

-- 1) A(s) 1 unidade(s) pedagogica(s) do conteudo 31, com
--    titulo/escopo/artigos aplicados pela curadoria. Esperado: 1 linha(s),
--    ordem 1, artigos_esperados NULL, ativa.
select id, ordem, titulo, escopo, artigos_esperados, ativa
from public.unidades_pedagogicas
where curso_conteudo_id = 31
order by ordem;

-- 2) Contagem de questoes classificadas por unidade. Esperado:
--    ordem 1 = 11
select u.ordem, u.titulo, count(distinct qup.questao_id) as questoes_classificadas
from public.unidades_pedagogicas u
left join public.questao_unidades_pedagogicas qup on qup.unidade_pedagogica_id = u.id
where u.curso_conteudo_id = 31
group by u.ordem, u.titulo
order by u.ordem;

-- 3) Total de vinculos e questoes distintas classificadas no conteudo.
--    Esperado: total_vinculos = 11, questoes_distintas = 11.
select count(*) as total_vinculos, count(distinct qup.questao_id) as questoes_distintas
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 31;

-- 4) Questoes multiunidade (vinculadas a mais de uma unidade do conteudo).
--    Esperado: nenhuma (impossivel com 1 unica unidade).
select qup.questao_id, array_agg(u.ordem order by u.ordem) as unidades
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 31
group by qup.questao_id
having count(*) > 1;

-- 5) Questoes ativas do conteudo que ficaram SEM nenhuma classificacao,
--    exceto as exclusoes intencionais Q693 e Q893. Esperado: 2 linhas
--    (ids 693 e 893).
select q.id, q.enunciado
from public.questoes q
where q.ativa = true
  and q.materia_id = 6
  and q.assunto_id = 54
  and not exists (
    select 1
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where qup.questao_id = q.id and u.curso_conteudo_id = 31
  )
order by q.id;

-- 6) Confirma que nenhuma classificacao vazou de/para outro conteudo —
--    todo vinculo de uma unidade do conteudo 31 aponta para questao
--    com materia_id/assunto_id compativeis (a trigger
--    validar_questao_unidade_pedagogica ja impede isso na escrita; aqui e
--    so confirmacao). Esperado: 0 linhas.
select qup.questao_id, qup.unidade_pedagogica_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
join public.curso_conteudos cc on cc.id = u.curso_conteudo_id
join public.curso_materias cm on cm.id = cc.curso_materia_id
join public.questoes q on q.id = qup.questao_id
where u.curso_conteudo_id = 31
  and (q.materia_id <> cm.materia_id or (cc.assunto_id is not null and q.assunto_id <> cc.assunto_id));

-- 7) Q693 e Q893 permanecem ativas, intactas e sem vinculo no conteudo 31.
--    Esperado: 2 linhas, ativa = true, vinculo_conteudo_31 = false.
select
  q.id,
  q.ativa,
  exists (
    select 1 from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where qup.questao_id = q.id and u.curso_conteudo_id = 31
  ) as vinculo_conteudo_31
from public.questoes q
where q.id in (693, 893)
order by q.id;

-- 8) Conteudos 20 (Ortografia), 22 (Classes de palavras), 26
--    (Acentuação gráfica) e 34 (Fonemas e dígrafos), ja concluidos,
--    permanecem intocados por esta operacao. Esperado (baseline antes
--    desta operacao): unidades_20=1, vinculos_20=22, unidades_22=1,
--    vinculos_22=17, unidades_26=1, vinculos_26=15, unidades_34=1,
--    vinculos_34=13.
select
  (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 20) as unidades_20,
  (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where u.curso_conteudo_id = 20) as vinculos_20,
  (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 22) as unidades_22,
  (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where u.curso_conteudo_id = 22) as vinculos_22,
  (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 26) as unidades_26,
  (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where u.curso_conteudo_id = 26) as vinculos_26,
  (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 34) as unidades_34,
  (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where u.curso_conteudo_id = 34) as vinculos_34;

-- 9) Confirma que artigos_esperados permanece NULL.
--    Esperado: artigos_esperados_null = true.
select
  (artigos_esperados is null) as artigos_esperados_null
from public.unidades_pedagogicas
where curso_conteudo_id = 31;

-- 10) Estado geral de outras tabelas nao deveria ter mudado por esta
--     operacao alem do crescimento esperado de vinculos.
select
  (select count(*) from public.curso_conteudos) as total_conteudos,
  (select count(*) from public.unidades_pedagogicas) as total_unidades_sistema,
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos_sistema;
