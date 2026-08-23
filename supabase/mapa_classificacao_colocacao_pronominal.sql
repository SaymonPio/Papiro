-- Mapa de classificacao semantica das questoes validas de Colocação pronominal
-- (curso_conteudos.id = 29, assunto_id = 43,
-- materia_id = 6), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/colocacao_pronominal.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_colocacao_pronominal_teste_rollback.sql
--   classificar_questoes_unidades_colocacao_pronominal.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 29 (apos curadoria_unidades_colocacao_pronominal.sql):
--   U1 c03b4993-601a-4c1e-b24d-c9e09d01db84  ordem 1  Colocação pronominal
--
-- Resultado da curadoria: 3/3 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (219, 'c03b4993-601a-4c1e-b24d-c9e09d01db84'::uuid, 1, 'Eixo 1 — Próclise por elemento negativo, subcaso "não" (cobertura suplementar; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca=''Papiro'', concurso=''PAPIRO - Estilo Fundatec - BM RS'', ano=2026) — material suplementar de prática, NÃO conta para incidência histórica, frequência Fundatec, recência ou ocorrência real em concurso; registrado como COBERTURA_SUPLEMENTAR_COLOCACAO_PRONOMINAL. Fenômeno testado: em ''Não me disseram a verdade'', a palavra negativa ''Não'' funciona como fator de atração obrigatório na norma tradicional cobrada em concursos, exigindo PRÓCLISE (gabarito A). Distratores cobrem ênclise indevida após negativa, início de período com pronome oblíquo átono (convenção da norma tradicional de concurso, não regra absoluta da língua — ''Me disseram...'' é construção corrente no português real), e ênclise/pronome solto com verbo em futuro sintético (deveria ser mesóclise, ''Dir-lhe-ei''/''Entregar-te-ei'', na ausência de fator de próclise). Mesmo eixo central de Q220 (elemento negativo), não uma habilidade independente. Categoria: A) regra conceitual. Explicação armazenada NÃO alterada nesta curadoria.', 'alta'),
    (220, 'c03b4993-601a-4c1e-b24d-c9e09d01db84'::uuid, 1, 'Eixo 1 — Próclise por elemento negativo, subcaso "jamais" (cobertura suplementar; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca=''Papiro'', concurso=''PAPIRO - Estilo Fundatec - BM RS'', ano=2026) — material suplementar de prática, NÃO conta para incidência histórica; registrado como COBERTURA_SUPLEMENTAR_COLOCACAO_PRONOMINAL. Fenômeno testado: em ''Jamais se esquecerá daquele dia'', o advérbio de valor negativo ''Jamais'' funciona como elemento atrativo obrigatório na norma tradicional de concurso, exigindo PRÓCLISE (gabarito A). Distratores cobrem confusão com infinitivo, inversão da regra (afirmar que seria obrigatória ênclise após negativa, quando é o oposto), sujeito incorreto (verbo não inicia a oração) e confusão conceitual com mesóclise (pronome antes do verbo = próclise, não mesóclise, que exigiria o pronome no MEIO da forma verbal). Mesmo eixo central de Q219 (elemento negativo), não uma habilidade independente. Categoria: A) regra conceitual. Explicação armazenada NÃO alterada nesta curadoria.', 'alta'),
    (221, 'c03b4993-601a-4c1e-b24d-c9e09d01db84'::uuid, 1, 'Eixo 2 — Próclise em contexto de subordinação, "quando" (cobertura suplementar; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca=''Papiro'', concurso=''PAPIRO - Estilo Fundatec - BM RS'', ano=2026) — material suplementar de prática, NÃO conta para incidência histórica; registrado como COBERTURA_SUPLEMENTAR_COLOCACAO_PRONOMINAL. Fenômeno testado: em ''Quando me chamarem, irei'', a conjunção subordinativa temporal ''Quando'' funciona como contexto de atração proclítica na norma tradicional de concurso, exigindo PRÓCLISE (gabarito A) — CAUTELA: não ensinar mecanicamente que toda ocorrência de ''quando'' sempre resolve a colocação pronominal da mesma forma sem analisar a construção concreta. Distratores revisam, em conjunto, os três gatilhos do corpus (ênclise indevida após ''quando''; início de período com pronome oblíquo átono; ênclise indevida após ''não'' e após ''jamais'', reforçando os outros dois eixos). Categoria: A) regra conceitual. Explicação armazenada NÃO alterada nesta curadoria.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (3/3).
-- 219,220,221

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Colocação pronominal: 3 questoes distintas
-- Total de vinculos esperados: 3 (3 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
