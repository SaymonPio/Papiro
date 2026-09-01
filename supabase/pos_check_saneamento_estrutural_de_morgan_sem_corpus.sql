-- Pos-check SOMENTE LEITURA do saneamento estrutural dedicado de Leis
-- de De Morgan (curso_conteudo_id=4, sem corpus proprio).
--
-- Nenhuma escrita. Cada consulta abaixo tem o valor esperado indicado no
-- comentario; qualquer divergencia deve ser reportada, nao corrigida aqui.
--
-- Este saneamento NAO fecha a ordem 86 (ordem-curadoria.json
-- permanece intocado), NAO toca questoes/vinculos de Negacao de
-- proposicoes, e NAO altera a taxonomia do conteudo.

-- 1) Estado do conteudo. Esperado: relevante_para_preparacao=false;
--    assunto_id=34, prioridade_estrategica=5, frequencia_historica NULL
--    inalterados.
select id, assunto_id, curso_materia_id, relevante_para_preparacao, prioridade_estrategica, frequencia_historica
from public.curso_conteudos
where id = 4;

-- 2) Estado da unidade. Esperado: ativa=false; curso_conteudo_id=4,
--    ordem=1, titulo='Leis de De Morgan', escopo='Leis de De Morgan',
--    artigos_esperados NULL inalterados.
select id, curso_conteudo_id, ordem, titulo, escopo, artigos_esperados, ativa
from public.unidades_pedagogicas
where id = '5ad41c42-25b4-4853-b328-b562a9fc8076';

-- 3) Vinculos da unidade de De Morgan. Esperado: 0.
select count(*) as vinculos_de_morgan
from public.questao_unidades_pedagogicas
where unidade_pedagogica_id = '5ad41c42-25b4-4853-b328-b562a9fc8076';

-- 4) Candidatas ativas do assunto 34. Esperado: 0.
select count(*) as candidatas_assunto_34
from public.questoes
where ativa = true and assunto_id = 34;

-- 5) Unidade de Negacao de proposicoes permanece com exatamente 7
--    vinculos (77,81,86,88,311,312,337). Esperado: 7 linhas.
select qup.questao_id
from public.questao_unidades_pedagogicas qup
where qup.unidade_pedagogica_id = 'c6ccefae-14df-4760-8c1d-2822090a2a93'
order by qup.questao_id;

-- 6) Checagem semantica: reproduz o filtro exato do cronograma
--    (app/cronograma/page.tsx, .eq("relevante_para_preparacao", true))
--    e da RPC iniciar_ou_recuperar_missao_diaria. Esperado: 0 linhas —
--    o conteudo 4 nao aparece mais entre os relevantes.
select id
from public.curso_conteudos
where id = 4 and relevante_para_preparacao = true;

-- 7) Dependencias permanecem em zero (nenhuma foi criada por engano
--    entre a auditoria e este apply). Esperado: todos os campos = 0.
select
  (select count(*) from public.aulas where conteudo_id = 4 or unidade_pedagogica_id = '5ad41c42-25b4-4853-b328-b562a9fc8076') as aulas,
  (select count(*) from public.aula_geracoes where conteudo_id = 4 or unidade_pedagogica_id = '5ad41c42-25b4-4853-b328-b562a9fc8076') as aula_geracoes,
  (select count(*) from public.missoes where conteudo_id = 4) as missoes,
  (select count(*) from public.progresso_conteudo_matricula where conteudo_id = 4) as progresso,
  (select count(*) from public.revisoes where assunto_id = 34) as revisoes;

-- 8) Confirma que Q77/Q88/Q311/Q81/Q86/Q312/Q337 permanecem intactas
--    (assunto_id=35, ativas, com vinculo em Negacao). Esperado: 7
--    linhas, todas assunto_id=35, ativa=true, vinculo_negacao=1.
select q.id, q.assunto_id, q.ativa,
  (select count(*) from public.questao_unidades_pedagogicas qup where qup.questao_id = q.id and qup.unidade_pedagogica_id = 'c6ccefae-14df-4760-8c1d-2822090a2a93') as vinculo_negacao
from public.questoes q
where q.id in (77, 81, 86, 88, 311, 312, 337)
order by q.id;

-- 9) Confirma que o conteudo continua acessivel/listavel no contexto
--    admin (listar_conteudos_curso_admin nao filtra por
--    relevante_para_preparacao — reproduzido aqui via a mesma tabela).
--    Esperado: 1 linha (o conteudo continua existindo para gestao).
select id, relevante_para_preparacao
from public.curso_conteudos
where curso_materia_id = 24
  and id = 4;

-- 10) Estado geral do sistema para detectar qualquer efeito colateral
--     inesperado.
select
  (select count(*) from public.curso_conteudos) as total_conteudos,
  (select count(*) from public.unidades_pedagogicas) as total_unidades_sistema,
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos_sistema;
