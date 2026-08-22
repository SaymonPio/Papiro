-- Mapa de classificacao semantica das questoes validas de Casos do Brasil na Corte Interamericana de Direitos Humanos
-- (curso_conteudos.id = 90, assunto_id = 97,
-- materia_id = 11), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/casos_do_brasil_na_corte_interamericana_de_direitos_humanos.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_casos_do_brasil_na_corte_interamericana_de_direitos_humanos_teste_rollback.sql
--   classificar_questoes_unidades_casos_do_brasil_na_corte_interamericana_de_direitos_humanos.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 90 (apos curadoria_unidades_casos_do_brasil_na_corte_interamericana_de_direitos_humanos.sql):
--   U1 420c8c2f-6f80-422a-9e63-d64aace51465  ordem 1  Casos do Brasil na Corte Interamericana de Direitos Humanos
--
-- Resultado da curadoria: 3/3 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (147, '420c8c2f-6f80-422a-9e63-d64aace51465'::uuid, 1, 'Caso Ximenes Lopes vs. Brasil', 'Precedente: Caso Ximenes Lopes vs. Brasil, Corte Interamericana de Direitos Humanos, sentença de 04/07/2006 — primeira condenação do Brasil na Corte IDH, por maus-tratos e morte de Damião Ximenes Lopes em estabelecimento psiquiátrico. Gabarito ''Caso Ximenes Lopes'' — correto; questão testa identificação de precedente concreto entre distratores de tribunais/casos totalmente estranhos ao Sistema Interamericano (Marbury v. Madison e Brown v. Board of Education — Suprema Corte dos EUA; Handyside — Tribunal Europeu de Direitos Humanos; Dreyfus — caso francês do século XIX). Não é necessário incluir os arts. 4, 5, 8 e 25 da CADH (violados na sentença) em artigos_esperados, pois a questão não os cobra. Nota complementar: a supervisão de cumprimento do caso foi encerrada e o processo arquivado pela Corte em 2023, o que não invalida a sentença de mérito de 2006.', 'alta'),
    (148, '420c8c2f-6f80-422a-9e63-d64aace51465'::uuid, 1, 'Caso Gomes Lund e outros ("Guerrilha do Araguaia") vs. Brasil', 'Precedente: Caso Gomes Lund e outros ("Guerrilha do Araguaia") vs. Brasil, Corte Interamericana de Direitos Humanos, sentença de 24/11/2010 — desaparecimento forçado de aproximadamente 70 opositores durante o regime militar (1972-1975), com reconhecimento do dever estatal de investigar graves violações de direitos humanos. Gabarito ''Desaparecimentos forçados e dever de investigar graves violações de direitos humanos'' — corresponde à tese central do caso. A Corte considerou incompatíveis com a Convenção Americana as disposições da Lei de Anistia (Lei 6.683/1979) que impeçam a investigação e punição das graves violações de direitos humanos abrangidas pelo caso, entendendo que não podem produzir efeitos jurídicos nesse sentido (formulação precisa — evitar ''a Corte anulou a Lei de Anistia'' ou ''a Lei 6.683/1979 deixou de existir''). Não incluídos em artigos_esperados os múltiplos artigos da CADH declarados violados (3, 4, 5, 7, 8, 13, 25, c/c 1.1), pois a questão cobra a tese/fato do precedente, não sua enumeração normativa.', 'alta'),
    (149, '420c8c2f-6f80-422a-9e63-d64aace51465'::uuid, 1, 'Caso Herzog e outros vs. Brasil', 'Precedente: Caso Herzog e outros vs. Brasil, Corte Interamericana de Direitos Humanos, sentença de 15/03/2018 — a Corte responsabilizou internacionalmente o Brasil, entre outros pontos, pela falta de investigação, julgamento e punição dos responsáveis pela tortura e morte do jornalista Vladimir Herzog no DOI-CODI/SP em 1975, durante o regime militar brasileiro, bem como pela aplicação de obstáculos incompatíveis com as obrigações internacionais pertinentes (formulação precisa que preserva a questão da competência temporal da Corte — evitar simplificação ''a Corte condenou o Brasil pela tortura e morte de Herzog'' sem qualificação). Gabarito ''O regime militar brasileiro'' — correto; distratores citam períodos históricos totalmente estranhos ao caso (Guerra do Paraguai, Revolução Farroupilha, República Velha exclusivamente, Constituição de 1824).', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (3/3).
-- 147,148,149

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Casos do Brasil na Corte Interamericana de Direitos Humanos: 3 questoes distintas
-- Total de vinculos esperados: 3 (3 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
