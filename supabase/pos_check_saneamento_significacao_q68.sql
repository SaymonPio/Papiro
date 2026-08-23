-- Pos-check SOMENTE LEITURA do saneamento de fidelidade da questao 68
-- (curso_conteudo_id 23, Significacao das palavras). Nenhuma escrita.

-- 1) Enunciado restaurado: marcadores [01]/[04]/[32], citacao "(l. 04)",
--    ocorrencia real da palavra "calamidade" na linha 04, comando original
--    presente. Esperado: todas as flags true.
select
  position('[01]' in enunciado) > 0 as marcador_01,
  position('[04]' in enunciado) > 0 as marcador_04,
  position('[32]' in enunciado) > 0 as marcador_32,
  position('(l. 04)' in enunciado) > 0 as citacao_linha_04,
  position('numa calamidade desgovernada' in enunciado) > 0 as ocorrencia_real_calamidade,
  position('A ordem correta de preenchimento dos parênteses' in enunciado) > 0 as comando_original_presente
from public.questoes
where id = 68;

-- 2) Gabarito, alternativas, proveniencia, assunto_id e ativa inalterados.
--    Esperado: correta=true na ordem 3 (C), 5 alternativas, banca/concurso/
--    ano/assunto_id/ativa iguais aos originais.
select
  q.banca, q.concurso, q.ano, q.assunto_id, q.ativa,
  (select count(*) from public.alternativas a where a.questao_id = q.id) as total_alternativas,
  (select a.ordem from public.alternativas a where a.questao_id = q.id and a.correta = true) as ordem_correta
from public.questoes q
where q.id = 68;

-- 3) Q68 continua sem nenhum vinculo pedagogico. Esperado: 0 linhas.
select questao_id, unidade_pedagogica_id
from public.questao_unidades_pedagogicas
where questao_id = 68;

-- 4) Estado geral do sistema inalterado fora da questao 68.
select
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos_sistema;
