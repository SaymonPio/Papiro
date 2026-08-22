-- Pos-check SOMENTE LEITURA da OPERACAO B (correcao da fundamentacao
-- item-a-item da explicacao da questao 69). Nenhuma escrita.

select id, ativa, banca, ano, assunto_id,
  (position('2 + 3' in explicacao) > 0) as tem_soma_corrigida,
  (position('Afirmação 1 (Incorreta)' in explicacao) > 0) as item1_incorreta,
  (position('Afirmação 2 (Correta)' in explicacao) > 0) as item2_correta,
  (position('Afirmação 3 (Correta)' in explicacao) > 0) as item3_correta,
  (position('Afirmação 4 (Incorreta)' in explicacao) > 0) as item4_incorreta,
  (position('GABARITO: alternativa C' in explicacao) > 0) as gabarito_letra_c
from public.questoes where id = 69;

select questao_id, texto, correta from public.alternativas where questao_id = 69 order by ordem;

select
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema;
