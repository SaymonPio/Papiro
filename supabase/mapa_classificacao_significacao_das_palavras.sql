-- Mapa de classificacao semantica das questoes validas de Significação das palavras
-- (curso_conteudos.id = 23, assunto_id = 59,
-- materia_id = 6), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/significacao_das_palavras.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_significacao_das_palavras_teste_rollback.sql
--   classificar_questoes_unidades_significacao_das_palavras.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 23 (apos curadoria_unidades_significacao_das_palavras.sql):
--   U1 290650b5-0f55-49e1-871e-932003447e41  ordem 1  Significação das palavras
--
-- Resultado da curadoria: 3/4 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: 68 (QUESTAO_HIBRIDA_MULTICONTEUDO — para obter o gabarito V-F-V, o aluno precisa dominar tres habilidades distintas e independentes sobre a palavra 'calamidade' (Fundatec, BM RS Soldado de Primeira Classe, 2025, texto 'Quando da tragédia brotam heróis e lições', l. 04): (I) significação lexical contextual ('calamidade' = catástrofe/desastre/tragédia, no contexto do texto sobre as enchentes do RS em maio de 2024) [Significação das palavras]; (II) classificação morfológica substantivo x adjetivo uniforme [Classes de palavras, conteúdo já concluído]; (III) contagem silábica e ausência de dígrafo/encontro consonantal em 'ca-la-mi-da-de' [Fonemas e dígrafos, conteúdo 34 já concluído]. O domínio exclusivo de Significação das palavras não basta para resolver integralmente a questão — por isso NÃO é vinculada como prática específica desta unidade. Mesmo sem vínculo, Q68 é questão REAL e CONTA COMO INCIDÊNCIA REAL de significação lexical contextual no raio-x histórico pré-edital, distinguindo explicitamente 'incidência real' de 'prática específica vinculada' (mesmo padrão dos precedentes Q893/Tempos e modos verbais e Q683/Coesão textual). Fidelidade já restaurada em operação de saneamento própria e separada (commit d6901ee) — não reaberta nem reaplicada nesta curadoria. Pode ser reaproveitada futuramente em revisão integrada, simulado ou missão final. Não realocada nesta etapa.).

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (122, '290650b5-0f55-49e1-871e-932003447e41'::uuid, 1, 'Sinonímia contextual × sinonímia absoluta — caquéticos/matusaléns, avexar, à beça (núcleo pré-edital primário — questão REAL)', 'Questão REAL (Fundatec, Brigada Militar RS, Soldado Nível III, 2022). Texto-base ''Modernidade de ocasião'' (M. Medeiros), restaurado com marcadores [01]-[37] e citações de linha do comando original em saneamento próprio (commit 1d8ad27), preservado intacto nesta curadoria. Regra testada: (I) ''caquéticos'' (l. 02 e 27) e ''matusaléns'' (l. 07) são aceitos como equivalentes SOMENTE dentro dos contextos específicos em que ocorrem — ''caquéticos'' é empregado pelos jovens, em tom pejorativo, para os mais velhos em geral; ''matusaléns'' é empregado pelo próprio narrador, em tom humorístico/afetivo, para os PRÓPRIOS pais; a questão considera equivalência semântica CONTEXTUAL, não sinonímia absoluta; (II) ''avexar'' (l. 16, sentido de incomodar-se/envergonhar-se) NÃO equivale a ''sujeitar'' (submeter, subordinar) — troca alteraria sentido e regência; (III) ''à beça'' (l. 20-22, intensificador de quantidade/abundância) é aceita como equivalente a ''à farta'' no contexto dado. Gabarito: D (Apenas I e III). HABILIDADE NUCLEAR: sinonímia/equivalência contextual — ensinar que sinônimo de dicionário não é substituição automaticamente válida; é preciso verificar sentido, contexto, registro/nuance, classe/função e manutenção do sentido global. Categoria: D) contraste (nuance de registro).', 'alta'),
    (308, '290650b5-0f55-49e1-871e-932003447e41'::uuid, 1, 'Paronímia clássica — eminente × iminente (cobertura secundária/suplementar; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca=''Papiro'', concurso=''PAPIRO - Adaptada do padrão Fundatec 2025/2026'', 2026) — material suplementar de prática, NÃO conta para incidência histórica, frequência Fundatec, recência, concurso ou prioridade pedagógica baseada em provas reais; registrado como COBERTURA_SECUNDARIA_PARONIMIA no modo pré-edital, não como núcleo. Regra testada: ''eminente'' (com E) significa alto, elevado, sublime, ilustre, notável; ''iminente'' (com I) significa prestes a ocorrer, a ponto de acontecer. Gabarito: A. Categoria: A) regra produtiva/lexical.', 'alta'),
    (317, '290650b5-0f55-49e1-871e-932003447e41'::uuid, 1, 'Sinonímia contextual — substituição lexical preservando sentido (núcleo pré-edital primário — questão REAL)', 'Questão REAL (Fundatec, Guarda Municipal de Gravataí/RS, Concurso Público nº 01/2025, prova aplicada em 2026). Enunciado auto-suficiente, citando o trecho exato do texto: "Saber amenizar os prejuízos disso é também um jeito de cuidar do psicológico da juventude". Regra testada: ''amenizar'' (abrandar, atenuar, minorar, tornar mais suave/menos danoso) pode ser substituído por ''suavizar'' sem prejuízo ao sentido original; distratores exploram antônimo (''intensificar'') e termos fora de sentido (''ignorar'', ''prolongar'', ''justificar''). Gabarito: C. HABILIDADE NUCLEAR: sinonímia contextual/substituição lexical — a troca deve preservar o sentido NO CONTEXTO, não bastando proximidade de dicionário. Categoria: A) regra produtiva/lexical.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (3/4).
-- 122,308,317

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): 68 (QUESTAO_HIBRIDA_MULTICONTEUDO — para obter o gabarito V-F-V, o aluno precisa dominar tres habilidades distintas e independentes sobre a palavra 'calamidade' (Fundatec, BM RS Soldado de Primeira Classe, 2025, texto 'Quando da tragédia brotam heróis e lições', l. 04): (I) significação lexical contextual ('calamidade' = catástrofe/desastre/tragédia, no contexto do texto sobre as enchentes do RS em maio de 2024) [Significação das palavras]; (II) classificação morfológica substantivo x adjetivo uniforme [Classes de palavras, conteúdo já concluído]; (III) contagem silábica e ausência de dígrafo/encontro consonantal em 'ca-la-mi-da-de' [Fonemas e dígrafos, conteúdo 34 já concluído]. O domínio exclusivo de Significação das palavras não basta para resolver integralmente a questão — por isso NÃO é vinculada como prática específica desta unidade. Mesmo sem vínculo, Q68 é questão REAL e CONTA COMO INCIDÊNCIA REAL de significação lexical contextual no raio-x histórico pré-edital, distinguindo explicitamente 'incidência real' de 'prática específica vinculada' (mesmo padrão dos precedentes Q893/Tempos e modos verbais e Q683/Coesão textual). Fidelidade já restaurada em operação de saneamento própria e separada (commit d6901ee) — não reaberta nem reaplicada nesta curadoria. Pode ser reaproveitada futuramente em revisão integrada, simulado ou missão final. Não realocada nesta etapa.)

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Significação das palavras: 3 questoes distintas
-- Total de vinculos esperados: 3 (3 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
