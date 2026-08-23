-- Mapa de classificacao semantica das questoes validas de Concordância nominal
-- (curso_conteudos.id = 19, assunto_id = 52,
-- materia_id = 6), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/concordancia_nominal.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_concordancia_nominal_teste_rollback.sql
--   classificar_questoes_unidades_concordancia_nominal.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 19 (apos curadoria_unidades_concordancia_nominal.sql):
--   U1 9a4936e1-a9a6-452c-9385-d5a5899ae5c5  ordem 1  Concordância nominal
--
-- Resultado da curadoria: 1/3 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: 222 (QUESTAO_HIBRIDA_MULTICONTEUDO — a alternativa B ('Segue anexas as certidões') possui concordância NOMINAL correta ('anexas' concorda com 'as certidões'), mas só pode ser eliminada por conhecimento independente de CONCORDÂNCIA VERBAL ('Segue', singular, em desacordo com o sujeito plural 'as certidões'). Teste contrafactual reprovado: um aluno que dominasse exclusivamente concordância nominal não conseguiria eliminar sozinho a alternativa B, vendo-a como igualmente válida à alternativa A do ponto de vista nominal. Origem AUTORAL_PAPIRO — não conta para incidência histórica em nenhuma hipótese (mesmo excluída, não gera registro de incidência multiconteúdo, conceito reservado a questões REAIS). Q222 permanece ativa e intacta, podendo ser reaproveitada futuramente em revisão integrada, simulado ou missão final. Não realocada nesta etapa.); 224 (QUESTAO_HIBRIDA_MULTICONTEUDO — a alternativa D ('As policiais estava meio cansadas') possui toda a parte nominal correta (artigo-substantivo 'As policiais', advérbio invariável 'meio', adjetivo 'cansadas' concordando), mas só pode ser eliminada por conhecimento independente de CONCORDÂNCIA VERBAL ('estava', singular, em desacordo com o sujeito plural 'As policiais'). Teste contrafactual reprovado: um aluno que dominasse exclusivamente concordância nominal não conseguiria eliminar sozinho a alternativa D, vendo-a como igualmente válida à alternativa A do ponto de vista nominal. Origem AUTORAL_PAPIRO — não conta para incidência histórica em nenhuma hipótese. Q224 permanece ativa e intacta, podendo ser reaproveitada futuramente em revisão integrada, simulado ou missão final. Não realocada nesta etapa.).

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (223, '9a4936e1-a9a6-452c-9385-d5a5899ae5c5'::uuid, 1, 'Concordância do predicativo com sujeito determinado ou não por artigo/pronome (única prática específica vinculável; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca=''Papiro'', concurso=''PAPIRO - Estilo Fundatec - BM RS'', 2026) — material suplementar de prática, NÃO conta para incidência histórica, frequência Fundatec, recência ou ocorrência real em concurso. Regra testada: nas estruturas formadas pelo verbo ''ser'' + predicativo (''é bom'', ''é necessário'', ''é proibido'', ''é permitido''), quando o sujeito vem determinado por artigo definido ou pronome (''a cautela''), a concordância nominal do predicativo é obrigatória (''É necessária a cautela''); sem determinante, a construção é tradicionalmente apresentada no masculino singular invariável (''É necessário cautela'') — regra tradicional de concurso, analisada pela estrutura concreta da frase, não como algoritmo universal cego. AUDITORIA ALTERNATIVA POR ALTERNATIVA CONFIRMOU VINCULABILIDADE: em nenhuma das 5 alternativas o verbo está desalinhado do respectivo sujeito reescrito (o verbo sempre concorda corretamente com o sujeito daquela alternativa específica); todo erro introduzido nos distratores é exclusivamente de concordância nominal (predicativo). Teste contrafactual aprovado: um aluno que soubesse apenas a regra do predicativo consegue eliminar sozinho B, C, D, E e chegar a A. EXPLICAÇÃO JÁ SANEADA em operação própria (commit 707682e) — a alternativa C (''São necessário as cautelas'') teve a atribuição de erro verbal corrigida: o verbo ''São'' concorda corretamente com ''as cautelas'' (plural); o erro é exclusivamente no predicativo ''necessário'' (deveria ser ''necessárias''). Gabarito: A. Categoria: A) regra tradicional de concurso.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (1/3).
-- 223

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): 222 (QUESTAO_HIBRIDA_MULTICONTEUDO — a alternativa B ('Segue anexas as certidões') possui concordância NOMINAL correta ('anexas' concorda com 'as certidões'), mas só pode ser eliminada por conhecimento independente de CONCORDÂNCIA VERBAL ('Segue', singular, em desacordo com o sujeito plural 'as certidões'). Teste contrafactual reprovado: um aluno que dominasse exclusivamente concordância nominal não conseguiria eliminar sozinho a alternativa B, vendo-a como igualmente válida à alternativa A do ponto de vista nominal. Origem AUTORAL_PAPIRO — não conta para incidência histórica em nenhuma hipótese (mesmo excluída, não gera registro de incidência multiconteúdo, conceito reservado a questões REAIS). Q222 permanece ativa e intacta, podendo ser reaproveitada futuramente em revisão integrada, simulado ou missão final. Não realocada nesta etapa.); 224 (QUESTAO_HIBRIDA_MULTICONTEUDO — a alternativa D ('As policiais estava meio cansadas') possui toda a parte nominal correta (artigo-substantivo 'As policiais', advérbio invariável 'meio', adjetivo 'cansadas' concordando), mas só pode ser eliminada por conhecimento independente de CONCORDÂNCIA VERBAL ('estava', singular, em desacordo com o sujeito plural 'As policiais'). Teste contrafactual reprovado: um aluno que dominasse exclusivamente concordância nominal não conseguiria eliminar sozinho a alternativa D, vendo-a como igualmente válida à alternativa A do ponto de vista nominal. Origem AUTORAL_PAPIRO — não conta para incidência histórica em nenhuma hipótese. Q224 permanece ativa e intacta, podendo ser reaproveitada futuramente em revisão integrada, simulado ou missão final. Não realocada nesta etapa.)

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Concordância nominal: 1 questoes distintas
-- Total de vinculos esperados: 1 (1 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
