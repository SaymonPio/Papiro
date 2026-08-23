-- Pos-check SOMENTE LEITURA do saneamento de fidelidade da questao 120
-- (curso_conteudo_id 17, Regencia verbal e nominal). Nenhuma escrita.

-- 1) Enunciado restaurado: marcadores, citacao de linhas, ausencia dos
--    fragmentos artificiais antigos. Esperado: todas as flags true,
--    exceto as de "ausencia" que ja sao formuladas como esperado true
--    quando o fragmento antigo NAO esta presente.
select
  position('[01]' in enunciado) > 0 as marcador_01,
  position('[04]' in enunciado) > 0 as marcador_04,
  position('[09]' in enunciado) > 0 as marcador_09,
  position('[20]' in enunciado) > 0 as marcador_20,
  position('[37]' in enunciado) > 0 as marcador_37,
  position('linhas 04, 09 e 20' in enunciado) > 0 as citacao_linhas,
  position('o cenário' in enunciado) = 0 as fragmento_cenario_ausente,
  position('as transformações' in enunciado) = 0 as fragmento_transformacoes_ausente,
  position('obra foi citada' in enunciado) = 0 as fragmento_obra_ausente
from public.questoes
where id = 120;

-- 2) Gabarito, alternativas, proveniencia, assunto_id e ativa inalterados.
--    Esperado: ordem_correta=1 (A), 5 alternativas, banca/concurso/ano/
--    assunto_id/ativa iguais aos originais.
select
  q.banca, q.concurso, q.ano, q.assunto_id, q.ativa,
  (select count(*) from public.alternativas a where a.questao_id = q.id) as total_alternativas,
  (select a.ordem from public.alternativas a where a.questao_id = q.id and a.correta = true) as ordem_correta
from public.questoes q
where q.id = 120;

-- 3) Explicacao contem a analise das linhas reais e a nota de saneamento.
--    Esperado: ambas as flags true.
select
  position('linha 04' in explicacao) > 0 as tem_linha_04,
  position('NOTA DE SANEAMENTO' in explicacao) > 0 as tem_nota_saneamento
from public.questoes
where id = 120;

-- 4) Vinculo pedagogico preservado (exatamente 1, mesma unidade).
--    Esperado: 1 linha, unidade 735f736a-37c0-477f-a555-dcd73d243d21.
select questao_id, unidade_pedagogica_id
from public.questao_unidades_pedagogicas
where questao_id = 120;

-- 5) Q122 (fonte reaproveitada) permanece intacta.
--    Esperado: ambas as flags true.
select
  position('[04] Eu devia ter uns 14 anos' in enunciado) > 0 as q122_linha_04_intacta,
  position('[37] os braços para o alto' in enunciado) > 0 as q122_linha_37_intacta
from public.questoes
where id = 122;

-- 6) Estado geral do sistema inalterado fora da questao 120.
select
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos_sistema;
