-- Pos-check SOMENTE LEITURA do saneamento de fidelidade da questao 65
-- (curso_conteudo_id 12, Interpretacao de textos). Nenhuma escrita.

-- 1) Enunciado restaurado: marcadores [01]/[32], comando original
--    presente. Esperado: todas as flags true.
select
  position('[01]' in enunciado) > 0 as marcador_01,
  position('[11]' in enunciado) > 0 as marcador_11,
  position('[17]' in enunciado) > 0 as marcador_17,
  position('[32]' in enunciado) > 0 as marcador_32,
  position('Considerando o exposto pelo texto-base' in enunciado) > 0 as comando_original_presente
from public.questoes
where id = 65;

-- 2) Gabarito, alternativas, proveniencia, assunto_id e ativa inalterados.
--    Esperado: ordem_correta=3 (C), 5 alternativas, banca/concurso/ano/
--    assunto_id/ativa iguais aos originais.
select
  q.banca, q.concurso, q.ano, q.assunto_id, q.ativa,
  (select count(*) from public.alternativas a where a.questao_id = q.id) as total_alternativas,
  (select a.ordem from public.alternativas a where a.questao_id = q.id and a.correta = true) as ordem_correta
from public.questoes q
where q.id = 65;

-- 3) Q65 continua sem nenhum vinculo pedagogico. Esperado: 0 linhas.
select questao_id, unidade_pedagogica_id
from public.questao_unidades_pedagogicas
where questao_id = 65;

-- 4) Q68 e Q69 permanecem inalteradas (mesmo texto-base [01]-[32]).
--    Esperado: ambas as flags true.
select
  (select position('[32] um jardim de heroísmo' in enunciado) > 0 from public.questoes where id = 68) as q68_intacta,
  (select position('[32] um jardim de heroísmo' in enunciado) > 0 from public.questoes where id = 69) as q69_intacta;

-- 5) Estado geral do sistema inalterado fora da questao 65.
select
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos_sistema;
