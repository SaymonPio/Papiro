-- Pos-check SOMENTE LEITURA do saneamento de fidelidade das explicacoes
-- das questoes 11 e 15 (curso_conteudo_id 40, Seguranca da informacao).
-- Nenhuma escrita.

-- 1) Nova explicacao coerente com a habilidade real de cada questao.
--    Esperado: todas as flags true.
select
  position('PHISHING' in explicacao) > 0 as q11_menciona_phishing,
  position('O backup (cópia de segurança) consiste em duplicar dados' in explicacao) = 0 as q11_nao_justifica_mais_backup,
  position('NOTA DE SANEAMENTO' in explicacao) > 0 as q11_tem_nota_saneamento
from public.questoes where id = 11;

select
  position('AUTENTICAÇÃO EM DOIS FATORES' in explicacao) > 0 as q15_menciona_2fa,
  position('NOTA DE SANEAMENTO' in explicacao) > 0 as q15_tem_nota_saneamento
from public.questoes where id = 15;

-- 2) Enunciado, banca, concurso, ano, assunto_id, ativa inalterados.
--    Esperado: valores originais preservados.
select id, enunciado, banca, concurso, ano, assunto_id, ativa
from public.questoes where id in (11, 15) order by id;

-- 3) Gabarito e alternativas inalterados. Esperado: 4 alternativas cada,
--    correta = 'Phishing' (Q11) e 'Ativar autenticação em dois fatores' (Q15).
select questao_id, count(*) as total_alternativas,
  (select texto from public.alternativas a2 where a2.questao_id = a.questao_id and a2.correta = true) as gabarito
from public.alternativas a
where questao_id in (11, 15)
group by questao_id
order by questao_id;

-- 4) Q11 e Q15 continuam SEM nenhum vinculo pedagogico. Esperado: 0 linhas.
select questao_id, unidade_pedagogica_id
from public.questao_unidades_pedagogicas
where questao_id in (11, 15);

-- 5) Estado geral do sistema inalterado fora das questoes 11 e 15.
select
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos_sistema;
