-- Pos-check SOMENTE LEITURA do saneamento taxonomico dedicado da Q84
-- (Condicional e contrapositiva -> Proposicoes e conectivos).
--
-- Nenhuma escrita. Cada consulta abaixo tem o valor esperado indicado no
-- comentario; qualquer divergencia deve ser reportada, nao corrigida aqui.
--
-- Este saneamento NAO fecha a ordem 88, NAO toca Q80/Q309, e NAO reabre
-- a curadoria da ordem 84.

-- 1) Estado atual da Q84: assunto_id, ativa, conteudo/gabarito/metadados.
--    Esperado: assunto_id=36, ativa=true, banca='Fundatec', concurso=
--    'SUSEPE RS - Agente Penitenciário', ano=2022.
select id, assunto_id, ativa, banca, concurso, ano, enunciado
from public.questoes
where id = 84;

-- 2) Vinculos da Q84. Esperado: exatamente 1 linha, apontando para
--    6683c484-74a7-4b07-9cda-1a72190e6445.
select qup.questao_id, qup.unidade_pedagogica_id, u.titulo, u.curso_conteudo_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where qup.questao_id = 84;

-- 3) Confirma que Q84 NAO possui vinculo em Condicional e contrapositiva
--    (curso_conteudo_id = 6). Esperado: 0 linhas.
select qup.questao_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where qup.questao_id = 84 and u.curso_conteudo_id = 6;

-- 4) Vinculos totais da unidade destino (Proposicoes e conectivos).
--    Esperado: 5 linhas — 74, 84, 87, 313, 314.
select qup.questao_id
from public.questao_unidades_pedagogicas qup
where qup.unidade_pedagogica_id = '6683c484-74a7-4b07-9cda-1a72190e6445'
order by qup.questao_id;

-- 5) Gabarito e alternativas da Q84 inalterados. Esperado: 5 linhas,
--    ordem 3 com correta=true e texto='Pedro é aluno da turma B.'.
select ordem, texto, correta
from public.alternativas
where questao_id = 84
order by ordem;

-- 6) Confirma que a explicacao da Q84 nao foi tocada (mesmo raciocinio
--    sobre a condicao de falsidade da condicional). Esperado: true.
select position('Condicional Falsa (V → F)' in explicacao) > 0 as contem_bizu_original
from public.questoes where id = 84;

-- 7) Confirma que Q80 e Q309 permanecem intactas: ambas assunto_id=39,
--    ativas, e 0 vinculos (curadoria final da ordem 88 ainda
--    pendente). Esperado: id 80 e 309, assunto_id=39, ativa=true,
--    vinculos=0 para ambas.
select q.id, q.assunto_id, q.ativa,
  (select count(*) from public.questao_unidades_pedagogicas qup where qup.questao_id = q.id) as vinculos
from public.questoes q
where q.id in (80, 309)
order by q.id;

-- 8) Candidatas LIVE remanescentes do assunto 39 (Condicional e
--    contrapositiva) apos o saneamento. Esperado: exatamente 2 linhas
--    (80, 309).
select id, ativa
from public.questoes
where ativa = true and assunto_id = 39
order by id;

-- 9) Confirma que a unidade da ordem 88 permanece intocada (ativa, 0
--    vinculos, titulo/escopo/artigos_esperados inalterados) e que a
--    unidade de Proposicoes e conectivos permanece ativa. Confirma
--    tambem contagem geral do sistema.
select
  (select ativa from public.unidades_pedagogicas where id = '42f5f55c-350a-4fb6-904c-184cde415d1e') as unidade_ordem88_ativa,
  (select count(*) from public.questao_unidades_pedagogicas where unidade_pedagogica_id = '42f5f55c-350a-4fb6-904c-184cde415d1e') as vinculos_ordem88,
  (select ativa from public.unidades_pedagogicas where id = '6683c484-74a7-4b07-9cda-1a72190e6445') as unidade_proposicoes_ativa,
  (select count(*) from public.curso_conteudos) as total_conteudos,
  (select count(*) from public.unidades_pedagogicas) as total_unidades_sistema,
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos_sistema;
