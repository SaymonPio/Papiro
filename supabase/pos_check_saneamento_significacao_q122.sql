-- Pos-check SOMENTE LEITURA do saneamento de fidelidade da questao 122
-- (curso_conteudo_id 23, Significacao das palavras). Nenhuma escrita.

-- 1) Marcadores de linha e ocorrencias lexicais restauradas.
--    Esperado: todas as flags true.
select
  position('[01]' in enunciado) > 0 as marcador_01,
  position('[02]' in enunciado) > 0 as marcador_02,
  position('[07]' in enunciado) > 0 as marcador_07,
  position('[16]' in enunciado) > 0 as marcador_16,
  position('[20]' in enunciado) > 0 as marcador_20,
  position('[21]' in enunciado) > 0 as marcador_21,
  position('[22]' in enunciado) > 0 as marcador_22,
  position('[27]' in enunciado) > 0 as marcador_27,
  position('[37]' in enunciado) > 0 as marcador_37,
  position('caquéticos' in enunciado) > 0 as tem_caqueticos,
  position('matusaléns' in enunciado) > 0 as tem_matusalens,
  position('avexar' in enunciado) > 0 as tem_avexar,
  position('à beça' in enunciado) > 0 as tem_a_beca,
  position('(l. 02 e 27)' in enunciado) > 0 as citacao_02_27,
  position('(l. 07)' in enunciado) > 0 as citacao_07,
  position('(l. 16)' in enunciado) > 0 as citacao_16,
  position('entre as linhas 20 e 22' in enunciado) > 0 as citacao_20_22,
  position('utilizados no texto-base' in enunciado) = 0 as redacao_reduzida_ausente
from public.questoes
where id = 122;

-- 2) Gabarito, alternativas, proveniencia, assunto_id e ativa inalterados.
--    Esperado: ordem_correta=4 (D), 5 alternativas, banca/concurso/ano/
--    assunto_id/ativa iguais aos originais.
select
  q.banca, q.concurso, q.ano, q.assunto_id, q.ativa,
  (select count(*) from public.alternativas a where a.questao_id = q.id) as total_alternativas,
  (select a.ordem from public.alternativas a where a.questao_id = q.id and a.correta = true) as ordem_correta
from public.questoes q
where q.id = 122;

-- 3) Explicacao contem a nota de saneamento e a nuance registrada.
--    Esperado: ambas as flags true.
select
  position('NOTA DE SANEAMENTO' in explicacao) > 0 as tem_nota_saneamento,
  position('sinonímia contextual' in explicacao) > 0 as tem_principio_sinonimia_contextual
from public.questoes
where id = 122;

-- 4) Q122 continua sem nenhum vinculo pedagogico. Esperado: 0 linhas.
select questao_id, unidade_pedagogica_id
from public.questao_unidades_pedagogicas
where questao_id = 122;

-- 5) Estado geral do sistema inalterado fora da questao 122.
select
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos_sistema;
