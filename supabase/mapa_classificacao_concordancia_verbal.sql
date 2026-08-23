-- Mapa de classificacao semantica das questoes validas de Concordância verbal
-- (curso_conteudos.id = 18, assunto_id = 14,
-- materia_id = 6), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/concordancia_verbal.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_concordancia_verbal_teste_rollback.sql
--   classificar_questoes_unidades_concordancia_verbal.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 18 (apos curadoria_unidades_concordancia_verbal.sql):
--   U1 834a820d-48a7-440f-a013-be375be8a62d  ordem 1  Concordância verbal
--
-- Resultado da curadoria: 4/4 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (16, '834a820d-48a7-440f-a013-be375be8a62d'::uuid, 1, 'Haver impessoal × existir pessoal × fazer impessoal (cobertura secundária/suplementar; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca=''Papiro — estilo Fundatec'', concurso=''Brigada Militar do Rio Grande do Sul'', ano ausente) — material suplementar de prática, NÃO conta para incidência histórica, frequência Fundatec, recência, concurso ou prioridade pedagógica baseada em provas reais; registrado como COBERTURA SECUNDÁRIA/SUPLEMENTAR no modo pré-edital, não como núcleo. Regra testada: ''Os candidatos chegaram'' (concordância normal, correta); ''Houveram muitos recursos'' incorreto (haver=existir é impessoal, sempre singular: ''Houve''); ''Fazem dois anos'' incorreto (fazer=tempo decorrido é impessoal, sempre singular: ''Faz''); ''Existe boas razões'' incorreto (existir é pessoal, concorda com o sujeito plural: ''Existem''). Categoria: A) regra produtiva.', 'alta'),
    (116, '834a820d-48a7-440f-a013-be375be8a62d'::uuid, 1, 'Concordância verbal em cadeia ao singularizar o sujeito (núcleo pré-edital primário — questão REAL)', 'Questão real (Fundatec, Brigada Militar RS - Soldado Nível III/2022). Regra testada: ao substituir ''os jovens'' (plural) por ''o jovem'' (singular) em ''os jovens renovam o vocabulário, reforçam sua superioridade sobre os caquéticos e mantêm a classificação de certo e errado sob seu domínio'', são necessárias 4 alterações — DISTINÇÃO NOMINAL × VERBAL explícita: 1) ''os''→''o'' é CONCORDÂNCIA NOMINAL (artigo concordando com o substantivo, não faz parte da concordância verbal em si); 2) ''renovam''→''renova'', 3) ''reforçam''→''reforça'' e 4) ''mantêm''→''mantém'' (com troca do acento circunflexo pelo agudo, marcando graficamente a oposição de número) são CONCORDÂNCIA VERBAL (3 de 4 alterações). A habilidade nuclear/discriminante da questão continua sendo concordância verbal em cadeia — não é questão híbrida a excluir. Gabarito: E (Quatro). Categoria: D) contraste.', 'alta'),
    (304, '834a820d-48a7-440f-a013-be375be8a62d'::uuid, 1, 'Haver impessoal × existir pessoal × fazer impessoal, incluindo locução verbal (cobertura secundária/suplementar; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca=''Papiro'', concurso=''PAPIRO - Adaptada do padrão Fundatec 2025/2026'', 2026) — material suplementar de prática, NÃO conta para incidência histórica; registrado como COBERTURA SECUNDÁRIA/SUPLEMENTAR. Regra testada: ''Faz dois anos que estudo'' correto (fazer=tempo decorrido, impessoal, singular); ''Fazem dois anos'' incorreto; ''Houveram muitos candidatos'' incorreto (haver=existir, impessoal, singular: ''Houve''); ''Existem muita gente'' incorreto (existir é pessoal, concorda com sujeito singular ''muita gente'': ''Existe''); ''Deve haverem vagas'' incorreto — em locução verbal com haver impessoal, o AUXILIAR (''deve'') permanece no singular, pois ''haver'' é o verbo principal no infinitivo empregado impessoalmente, não o auxiliar (correto: ''Deve haver vagas''). Categoria: A) regra produtiva.', 'alta'),
    (318, '834a820d-48a7-440f-a013-be375be8a62d'::uuid, 1, 'Concordância verbal em cadeia ao pluralizar o sujeito, com acento diferencial (núcleo pré-edital primário — questão REAL)', 'Questão real (Fundatec, GM Gravataí/RS/2025-2026). Regra testada: ao flexionar ''ponteiro'' (singular) para o plural em ''esse ponteiro tem duas horas de atraso em relação às crianças e adultos'', são necessárias 2 alterações — DISTINÇÃO NOMINAL × VERBAL explícita: 1) ''esse''→''esses'' é CONCORDÂNCIA NOMINAL (pronome demonstrativo concordando com o substantivo, não é concordância verbal); 2) ''tem''→''têm'' é CONCORDÂNCIA VERBAL (verbo com o sujeito, com acento circunflexo marcando graficamente a oposição de número). A habilidade nuclear/discriminante continua sendo concordância verbal (especificamente o acento diferencial), com o componente nominal explicitamente distinguido, não amalgamado. Gabarito: B (2). Categoria: D) contraste.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (4/4).
-- 16,116,304,318

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Concordância verbal: 4 questoes distintas
-- Total de vinculos esperados: 4 (4 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
