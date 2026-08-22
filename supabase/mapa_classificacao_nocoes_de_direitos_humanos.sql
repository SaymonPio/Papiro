-- Mapa de classificacao semantica das questoes validas de Noções de Direitos Humanos
-- (curso_conteudos.id = 81, assunto_id = 89,
-- materia_id = 11), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/nocoes_de_direitos_humanos.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_nocoes_de_direitos_humanos_teste_rollback.sql
--   classificar_questoes_unidades_nocoes_de_direitos_humanos.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 81 (apos curadoria_unidades_nocoes_de_direitos_humanos.sql):
--   U1 df8d133f-ddd6-4b85-941d-60b4d4967c06  ordem 1  Noções de Direitos Humanos
--
-- Resultado da curadoria: 5/7 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: 624 (fora de escopo — testa o Estatuto Nacional da Igualdade Racial (Lei no 12.288/2010, art. 52, caput), ja classificado nos curso_conteudo_id 67 e 97; materialmente incompativel com 'Nocoes de Direitos Humanos'; sinalizada para saneamento futuro de assunto_id); 697 (fora de escopo — testa o Estatuto do Idoso (Lei no 10.741/2003, art. 34, caput); materialmente incompativel com 'Nocoes de Direitos Humanos'; sinalizada para saneamento futuro de assunto_id).

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (168, 'df8d133f-ddd6-4b85-941d-60b4d4967c06'::uuid, 1, 'Universalidade dos direitos humanos', 'Gabarito: ''Universalidade'' — caracteristica classica dos direitos humanos (aplicam-se a todas as pessoas, independentemente de nacionalidade, origem etc.), doutrina, sem dispositivo legal especifico. Distratores sem correspondencia (renunciabilidade absoluta, aplicacao apenas a nacionais, disponibilidade irrestrita, vigencia apenas em guerra — todos contrariam a propria nocao de direitos humanos).', 'alta'),
    (169, 'df8d133f-ddd6-4b85-941d-60b4d4967c06'::uuid, 1, 'Indivisibilidade dos direitos humanos', 'Gabarito: ''As diferentes categorias de direitos se inter-relacionam e nao devem ser artificialmente separadas'' — definicao doutrinaria classica de indivisibilidade (direitos civis/politicos e sociais/economicos/culturais formam um conjunto unico e interdependente), sem dispositivo legal especifico. Distratores sem correspondencia (apenas direitos civis protegidos, direitos sociais nao sao direitos humanos, cada direito vale para um unico grupo, direitos humanos nao podem coexistir).', 'alta'),
    (170, 'df8d133f-ddd6-4b85-941d-60b4d4967c06'::uuid, 1, 'Fundamento dos direitos humanos', 'Gabarito: ''Dignidade da pessoa humana'' — fundamento doutrinario classico dos direitos humanos, sem dispositivo legal especifico. Distratores sem correspondencia (arrecadacao tributaria, hierarquia empresarial, propriedade estatal exclusiva, politica monetaria).', 'alta'),
    (623, 'df8d133f-ddd6-4b85-941d-60b4d4967c06'::uuid, 1, 'Diretrizes de proteção dos direitos humanos dos profissionais de segurança pública', 'Assertiva I (verdadeira): promocao dos DH dos profissionais inclui reconhecimento do risco, politicas de protecao a vida/saude fisica e mental, prevencao do suicidio e acompanhamento psicossocial — Lei no 13.675/2018, art. 42, §§1o-3o, e art. 42-A (diretrizes de prevencao da violencia autoprovocada e do suicidio). Assertiva II (falsa — real: a lei trata a abordagem de saude ocupacional/condicoes de trabalho na formacao como estrategia obrigatoria de prevencao primaria, nao facultativa) art. 42-A, §4o, V. Assertiva III (verdadeira): condicoes dignas de trabalho — jornada, remuneracao, EPIs, instalacoes seguras — Lei no 13.675/2018, art. 42-B, IV e V, e art. 42-A, §2o, XIII e XIV. Assertiva IV (falsa, sem base legal — contraria o proprio proposito de responsabilizacao/controle inerente a qualquer politica de direitos humanos). Gabarito ''Apenas I e III'' confere. Tema originalmente estabelecido pela Portaria Interministerial SEDH/MJ no 2/2010, hoje com base estatutaria vigente na Lei no 13.675/2018 (arts. 42-A e 42-B, inseridos pela Lei no 14.531/2023).', 'alta'),
    (696, 'df8d133f-ddd6-4b85-941d-60b4d4967c06'::uuid, 1, 'Conceito de violação de direitos humanos (caso negativo)', 'Gabarito: ''Direito a vida e a seguranca'' — unica alternativa que NAO configura um caso de desrespeito/violacao aos preceitos dos Direitos Humanos, pois e o proprio direito protegido, nao uma violacao. Doutrina, sem dispositivo legal especifico. Distratores corretamente identificados como violacoes (intolerancia religiosa, discriminacao de raca e cor, exploracao do trabalho infantil, tortura).', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (5/7).
-- 168,169,170,623,696

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): 624 (fora de escopo — testa o Estatuto Nacional da Igualdade Racial (Lei no 12.288/2010, art. 52, caput), ja classificado nos curso_conteudo_id 67 e 97; materialmente incompativel com 'Nocoes de Direitos Humanos'; sinalizada para saneamento futuro de assunto_id); 697 (fora de escopo — testa o Estatuto do Idoso (Lei no 10.741/2003, art. 34, caput); materialmente incompativel com 'Nocoes de Direitos Humanos'; sinalizada para saneamento futuro de assunto_id)

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Noções de Direitos Humanos: 5 questoes distintas
-- Total de vinculos esperados: 5 (5 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
