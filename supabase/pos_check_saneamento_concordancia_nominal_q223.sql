-- Pos-check SOMENTE LEITURA do micro-saneamento de explicacao da
-- questao 223 (curso_conteudo_id 19, Concordancia nominal). Nenhuma
-- escrita.

-- 1) Q223 intacta em enunciado/gabarito/metadados/vinculos.
--    Esperado: enunciado original, ordem_correta=1, 5 alternativas,
--    banca/concurso/ano/assunto_id/ativa originais, vinculos=0.
select
  q.enunciado,
  q.banca, q.concurso, q.ano, q.assunto_id, q.ativa,
  (select count(*) from public.alternativas a where a.questao_id = q.id) as total_alternativas,
  (select a.ordem from public.alternativas a where a.questao_id = q.id and a.correta = true) as ordem_correta,
  (select count(*) from public.questao_unidades_pedagogicas qup where qup.questao_id = q.id) as vinculos
from public.questoes q
where q.id = 223;

-- 2) Explicacao corrigida. Esperado: ambas as flags true.
select
  position('não há erro de concordância verbal' in explicacao) > 0 as correcao_presente,
  position('Apresenta discordância entre o verbo no plural' in explicacao) = 0 as texto_antigo_ausente
from public.questoes
where id = 223;

-- 3) Explicacao registra claramente VERBAL correto / NOMINAL incorreto
--    para a alternativa C, e a forma esperada "São necessárias as
--    cautelas". Esperado: ambas as flags true.
select
  position('São" concorda corretamente com o sujeito plural' in explicacao) > 0 as verbal_correto_registrado,
  position('São necessárias as cautelas' in explicacao) > 0 as forma_esperada_registrada
from public.questoes
where id = 223;

-- 4) Estado geral do sistema inalterado fora da questao 223.
select
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos_sistema;
