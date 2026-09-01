-- Pos-check SOMENTE LEITURA do saneamento de fidelidade estrutural +
-- explicacao da Q89 (Tabela-verdade, curso_conteudo_id = 2).
--
-- Nenhuma escrita. Cada consulta abaixo tem o valor esperado indicado no
-- comentario; qualquer divergencia deve ser reportada, nao corrigida aqui.
--
-- Este saneamento NAO cria vinculo pedagogico algum. A curadoria final da
-- ordem 85 (Tabela-verdade) permanece pendente, como operacao separada.
-- Q314 nao e tocada por este arquivo.

-- 1) Enunciado e explicacao atuais da Q89, para inspecao visual.
select id, banca, concurso, ano, assunto_id, ativa, enunciado, explicacao, atualizado_em
from public.questoes
where id = 89;

-- 2) Confere as 8 linhas da tabela presentes no enunciado, com as 4
--    lacunas exatamente nas linhas 2, 4, 6, 8 (marcadas com "?") e as
--    outras 4 preenchidas (linhas 1,3,5,7). Esperado: todas as 8 checagens
--    = true.
select
  position('| 1 | V | V | V | F | V | F | F |' in enunciado) > 0 as linha1_ok,
  position('| 2 | V | V | F | F | V | F | ? |' in enunciado) > 0 as linha2_lacuna_ok,
  position('| 3 | V | F | V | V | V | V | V |' in enunciado) > 0 as linha3_ok,
  position('| 4 | V | F | F | V | V | F | ? |' in enunciado) > 0 as linha4_lacuna_ok,
  position('| 5 | F | V | V | F | V | F | F |' in enunciado) > 0 as linha5_ok,
  position('| 6 | F | V | F | F | V | F | ? |' in enunciado) > 0 as linha6_lacuna_ok,
  position('| 7 | F | F | V | V | F | V | V |' in enunciado) > 0 as linha7_ok,
  position('| 8 | F | F | F | V | F | F | ? |' in enunciado) > 0 as linha8_lacuna_ok
from public.questoes where id = 89;

-- 3) Confere que a resposta NAO vaza no enunciado (a sequencia
--    "F – F – F – V" nao deve aparecer no enunciado). Esperado: false.
select position('F – F – F – V' in enunciado) > 0 as resposta_vazada_no_enunciado
from public.questoes where id = 89;

-- 4) Confere que a explicacao identifica corretamente as linhas 2,4,6,8
--    (nao 5-8), conclui com a sequencia correta e contem a nota de
--    saneamento. Esperado: todas true.
select
  position('linhas 2, 4, 6 e 8' in explicacao) > 0 as identifica_linhas_corretas,
  position('Linha 5 (p=F, q=V, r=V)' in explicacao) = 0 as nao_contem_raciocinio_antigo,
  position('F – F – F – V' in explicacao) > 0 as conclui_com_gabarito_correto,
  position('NOTA DE SANEAMENTO' in explicacao) > 0 as contem_nota_saneamento
from public.questoes where id = 89;

-- 5) Confirma que todos os campos de proveniencia/estrutura permanecem
--    inalterados. Esperado: banca=Fundatec, concurso='SUSEPE RS - Agente
--    Penitenciário', ano=2022, assunto_id=38, ativa=true.
select banca, concurso, ano, assunto_id, ativa
from public.questoes where id = 89;

-- 6) Confirma as 5 alternativas e o gabarito (ordem 4, "F – F – F – V.").
--    Esperado: 5 linhas; a de ordem=4 com correta=true.
select ordem, texto, correta
from public.alternativas
where questao_id = 89
order by ordem;

-- 7) Confirma 0 vinculos pedagogicos para Q89 (curadoria final ainda
--    pendente). Esperado: 0.
select count(*) as vinculos_q89
from public.questao_unidades_pedagogicas
where questao_id = 89;

-- 8) Confirma que Q314 permanece totalmente intocada por esta operacao.
--    Esperado: assunto_id=38, ativa=true, vinculos=0.
select id, assunto_id, ativa,
  (select count(*) from public.questao_unidades_pedagogicas qup where qup.questao_id = q.id) as vinculos
from public.questoes q
where id = 314;
