-- Mapa de classificacao semantica das questoes validas de Abuso de Autoridade
-- (curso_conteudos.id = 62, assunto_id = 79,
-- materia_id = 10), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/abuso_de_autoridade.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_abuso_de_autoridade_teste_rollback.sql
--   classificar_questoes_unidades_abuso_de_autoridade.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 62 (apos curadoria_unidades_abuso_de_autoridade.sql):
--   U1 7f7298d6-c0b8-4907-8f72-1072a0796a5f  ordem 1  Abuso de Autoridade
--
-- Resultado da curadoria: 11/11 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (192, '7f7298d6-c0b8-4907-8f72-1072a0796a5f'::uuid, 1, 'Elemento geral do crime', 'Finalidade especifica exigida para a configuracao dos crimes de abuso de autoridade — art. 1o, §1o.', 'alta'),
    (193, '7f7298d6-c0b8-4907-8f72-1072a0796a5f'::uuid, 1, 'Elemento geral do crime', 'Divergencia na interpretacao da lei ou avaliacao de fatos/provas nao configura abuso de autoridade por si so — art. 1o, §2o.', 'alta'),
    (194, '7f7298d6-c0b8-4907-8f72-1072a0796a5f'::uuid, 1, 'Elemento geral do crime', 'Exclui ''atua sempre de forma culposa'' — reforca a exigencia de dolo especifico (finalidade especifica) do art. 1o, §1o.', 'alta'),
    (712, '7f7298d6-c0b8-4907-8f72-1072a0796a5f'::uuid, 1, 'Crimes em especie', 'Inovar artificiosamente o estado de lugar/coisa/pessoa em investigacao para se eximir de responsabilidade — art. 23, caput (crime proprio da Lei 13.869/2019, distinto do art. 347 do CP).', 'alta'),
    (713, '7f7298d6-c0b8-4907-8f72-1072a0796a5f'::uuid, 1, 'Crimes em especie', 'Constranger o abordado a submeter-se a revista intima vexatoria — art. 13, caput e II. Alternativa 5 tambem cobra, em tese, o art. 13, III (produzir prova contra si), embora mal rotulada na alternativa como ''art. 15'' — corrigido apos releitura; art. 9o e art. 15 nao foram mantidos por nao corresponderem, de fato, aos fatos narrados nem ao teor real do art. 15 (associacao equivocada).', 'alta'),
    (771, '7f7298d6-c0b8-4907-8f72-1072a0796a5f'::uuid, 1, 'Efeitos da condenacao e penas', 'Condenacao a perda do cargo motivada pela reincidencia, descrita na sentenca — art. 4o, III e paragrafo unico (inabilitacao do inciso II nao e testada em nenhuma alternativa).', 'alta'),
    (772, '7f7298d6-c0b8-4907-8f72-1072a0796a5f'::uuid, 1, 'Acao penal', 'Queixa apresentada 1 ano depois nao foi acolhida porque ja havia passado o prazo da acao privada subsidiaria — art. 3o, caput, §1o e §2o.', 'alta'),
    (793, '7f7298d6-c0b8-4907-8f72-1072a0796a5f'::uuid, 1, 'Elemento geral do crime', 'Mesma finalidade especifica do art. 1o, §1o (prejudicar, beneficiar ou mero capricho).', 'alta'),
    (837, '7f7298d6-c0b8-4907-8f72-1072a0796a5f'::uuid, 1, 'Crimes em especie', 'Expor a vitima presa/detida, com partes do corpo expostas a curiosidade publica — art. 13, caput e I.', 'alta'),
    (838, '7f7298d6-c0b8-4907-8f72-1072a0796a5f'::uuid, 1, 'Efeitos da condenacao e penas', 'Item I: perda do cargo — art. 4o, III. Item II: suspensao do exercicio do cargo/funcao (1 a 6 meses) e pena restritiva de direitos — art. 5o, II. Item III (falso): responsabilizacao civil/administrativa dependeria de condenacao criminal — testa exatamente a independencia dessas esferas em relacao a criminal, art. 7o, caput.', 'alta'),
    (839, '7f7298d6-c0b8-4907-8f72-1072a0796a5f'::uuid, 1, 'Crimes em especie', 'Pena do crime do art. 13 (detencao de 1 a 4 anos e multa, sem prejuizo da pena da violencia) — referencia mantida como ''art. 13'' (nivel de artigo), sem rotular como caput, por precisao tecnica ja que a clausula de pena vem apos os incisos.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (11/11).
-- 192,193,194,712,713,771,772,793,837,838,839

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Abuso de Autoridade: 11 questoes distintas
-- Total de vinculos esperados: 11 (11 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
