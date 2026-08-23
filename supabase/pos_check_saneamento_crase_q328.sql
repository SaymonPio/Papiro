-- Pos-check SOMENTE LEITURA do saneamento de fidelidade da Q328 (Crase).
-- Nenhuma escrita.

select id, ativa, assunto_id, banca, concurso, ano, length(enunciado) as len_enunciado
from public.questoes where id = 328;

select ordem, texto, correta from public.alternativas where questao_id = 328 order by ordem;

select left(enunciado, 400) as inicio, right(enunciado, 250) as fim
from public.questoes where id = 328;

select
  (position('[01]' in enunciado) > 0) as tem_01,
  (position('[17]' in enunciado) > 0) as tem_17,
  (position('[19]' in enunciado) > 0) as tem_19,
  (position('[20]' in enunciado) > 0) as tem_20,
  (position('[28]' in enunciado) > 0) as tem_28,
  (position('[36]' in enunciado) > 0) as tem_36,
  (position('colocaram fim ___ utilização' in enunciado) > 0) as tem_trecho_17,
  (position('estavam sujeitos ___' in enunciado) > 0) as tem_trecho_19,
  (position('motor ___ combustão' in enunciado) > 0) as tem_trecho_28,
  (position('adaptadas' in enunciado) > 0) as ainda_tem_parafrase_antiga
from public.questoes where id = 328;

select
  (position('Bechara' in explicacao) > 0) as tem_bechara,
  (position('Cegalla' in explicacao) > 0) as tem_cegalla,
  (position('ENTENDIMENTO ESPECÍFICO ADOTADO PELA BANCA' in explicacao) > 0) as tem_nota_nao_universal,
  (position('NOTA DE SANEAMENTO' in explicacao) > 0) as tem_nota_saneamento
from public.questoes where id = 328;

select count(*) as vinculos_q328 from public.questao_unidades_pedagogicas where questao_id = 328;

select
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos_sistema;
