-- Pos-check SOMENTE LEITURA da OPERACAO A (restauracao dos textos-base de
-- Q69, Q324 e Q333, conteudo 13 - Coesao textual).
--
-- Nenhuma escrita.

-- 1) Confirma presenca dos marcadores de linha exigidos e do comando
--    original (uma unica vez) em cada questao.
select
  q.id,
  q.ativa,
  q.banca,
  q.concurso,
  q.ano,
  q.assunto_id,
  (position('[01]' in q.enunciado) > 0) as tem_marcador_01,
  length(q.enunciado) as tamanho_enunciado
from public.questoes q
where q.id in (69, 324, 333)
order by q.id;

-- 2) Confirma que nenhuma alternativa/gabarito mudou (contagem e status
--    'correta' por questao). Esperado: 5 alternativas cada, 1 correta cada.
select questao_id, count(*) as total_alternativas, count(*) filter (where correta) as total_corretas
from public.alternativas
where questao_id in (69, 324, 333)
group by questao_id
order by questao_id;

-- 3) Amostra do novo enunciado (primeiros 500 caracteres) para conferencia
--    visual rapida.
select id, left(enunciado, 500) as inicio
from public.questoes
where id in (69, 324, 333)
order by id;

-- 4) Confirma presenca de trechos-chave especificos usados pelas assercoes
--    de cada questao.
select
  (select count(*) from public.questoes where id=69 and enunciado ilike '%[08]%') as q69_tem_l08,
  (select count(*) from public.questoes where id=69 and enunciado ilike '%[12]%') as q69_tem_l12,
  (select count(*) from public.questoes where id=69 and enunciado ilike '%[26]%') as q69_tem_l26,
  (select count(*) from public.questoes where id=324 and enunciado ilike '%[17]%') as q324_tem_l17,
  (select count(*) from public.questoes where id=324 and enunciado ilike '%[22]%') as q324_tem_l22,
  (select count(*) from public.questoes where id=324 and enunciado ilike '%[30]%') as q324_tem_l30,
  (select count(*) from public.questoes where id=333 and enunciado ilike '%[10]%') as q333_tem_l10,
  (select count(*) from public.questoes where id=333 and enunciado ilike '%[17]%') as q333_tem_l17,
  (select count(*) from public.questoes where id=333 and enunciado ilike '%[25]%') as q333_tem_l25;

-- 5) Estado geral do sistema nao deveria ter mudado alem dos 3 enunciados.
select
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos_sistema;
