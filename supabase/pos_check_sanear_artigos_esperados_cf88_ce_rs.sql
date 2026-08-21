-- Pos-check SOMENTE LEITURA do saneamento de metadados de artigos_esperados
-- das unidades pedagogicas de Constituicao Federal de 1988 (curso_conteudos
-- .id = 57) e Constituicao do Estado do Rio Grande do Sul (curso_conteudos
-- .id = 50). Nenhuma escrita. Cada consulta abaixo tem o valor esperado
-- indicado no comentario; qualquer divergencia deve ser reportada, nao
-- corrigida aqui.

-- 1) As 2 unidades, com titulo/escopo/ordem/ativa inalterados e
--    artigos_esperados atualizado. Esperado: 2 linhas, CF com 27 itens,
--    RS com 37 itens, titulo/escopo iguais aos de antes do saneamento.
select id, curso_conteudo_id, ordem, titulo, ativa, array_length(artigos_esperados, 1) as qtd_artigos_esperados
from public.unidades_pedagogicas
where id in ('682804b0-2762-4aff-87f9-d7a5a81757c2', '83636594-c69f-4de0-bf46-0e75c2ec981c')
order by curso_conteudo_id;

-- 2) artigos_esperados completo de cada unidade, para conferencia visual.
select curso_conteudo_id, artigos_esperados
from public.unidades_pedagogicas
where id in ('682804b0-2762-4aff-87f9-d7a5a81757c2', '83636594-c69f-4de0-bf46-0e75c2ec981c')
order by curso_conteudo_id;

-- 3) Vinculos questao-unidade dos 2 conteudos NAO devem ter mudado.
--    Esperado: total_vinculos_57 = 14, total_vinculos_50 = 14 (inalterados
--    desde as curadorias originais).
select
  (select count(*) from public.questao_unidades_pedagogicas qup
     join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
     where u.curso_conteudo_id = 57) as total_vinculos_57,
  (select count(*) from public.questao_unidades_pedagogicas qup
     join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
     where u.curso_conteudo_id = 50) as total_vinculos_50;

-- 4) Nenhuma unidade nova foi criada para os conteudos 57 ou 50.
--    Esperado: 1 unidade cada.
select curso_conteudo_id, count(*) as total_unidades
from public.unidades_pedagogicas
where curso_conteudo_id in (57, 50)
group by curso_conteudo_id
order by curso_conteudo_id;

-- 5) Estado geral de outras tabelas nao deveria ter mudado por esta
--    operacao. Totais consultados AO VIVO em 2026-08-21 (leitura direta),
--    ANTES deste saneamento: curso_conteudos=93, unidades_pedagogicas=99,
--    questoes=915, alternativas=4330, questao_unidades_pedagogicas=28
--    (14 do conteudo 57 + 14 do conteudo 50). Nenhum desses numeros deveria
--    ter mudado, pois este saneamento so escreve em artigos_esperados.
select
  (select count(*) from public.curso_conteudos) as total_conteudos,
  (select count(*) from public.unidades_pedagogicas) as total_unidades_sistema,
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos_sistema;
