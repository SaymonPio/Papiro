-- Mapa de classificacao semantica das questoes validas de Denotação e conotação
-- (curso_conteudos.id = 24, assunto_id = 58,
-- materia_id = 6), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/denotacao_e_conotacao.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_denotacao_e_conotacao_teste_rollback.sql
--   classificar_questoes_unidades_denotacao_e_conotacao.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 24 (apos curadoria_unidades_denotacao_e_conotacao.sql):
--   U1 f1377f8b-348e-4da6-9713-e901ce5ea516  ordem 1  Denotação e conotação
--
-- Resultado da curadoria: 3/3 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (228, 'f1377f8b-348e-4da6-9713-e901ce5ea516'::uuid, 1, 'Reconhecimento do uso denotativo em contexto (cobertura suplementar; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca=''Papiro'', concurso=''PAPIRO - Estilo Fundatec - BM RS'', ano=2026) — material suplementar de prática, NÃO conta para incidência histórica, frequência Fundatec, recência ou ocorrência real em concurso; registrado como COBERTURA_SUPLEMENTAR_DENOTACAO_CONOTACAO. Regra testada: em ''O policial fechou a porta'', ''porta'' é empregada em uso literal/referencial — o objeto referido é literalmente uma porta e a ação (fechar) é compatível com seu sentido concreto, sem produzir leitura figurada relevante. CAUTELA PEDAGÓGICA: não classificar a PALAVRA isoladamente como ''denotativa'' — classificar sempre o USO dela neste contexto específico (a mesma palavra ''porta'' é conotativa em outro contexto, ver Q229). Gabarito: A (Denotativo). Categoria: A) regra conceitual.', 'alta'),
    (229, 'f1377f8b-348e-4da6-9713-e901ce5ea516'::uuid, 1, 'Reconhecimento do uso conotativo em expressão idiomática (cobertura suplementar; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca=''Papiro'', concurso=''PAPIRO - Estilo Fundatec - BM RS'', ano=2026) — material suplementar de prática, NÃO conta para incidência histórica; registrado como COBERTURA_SUPLEMENTAR_DENOTACAO_CONOTACAO. Regra testada: em ''A aprovação abriu portas para sua carreira'', a expressão ''abriu portas'' não se refere ao ato físico de abrir uma estrutura de madeira, mas a criar oportunidades/possibilidades profissionais — emprego figurado/associativo para além da referência literal imediata (não se restringe à nomenclatura técnica ''metáfora''; é reconhecimento de leitura contextual). A leitura literal é semanticamente implausível no contexto de uma carreira profissional, sinalizando o uso conotativo. Gabarito: A (Conotativo). Categoria: A) regra conceitual.', 'alta'),
    (230, 'f1377f8b-348e-4da6-9713-e901ce5ea516'::uuid, 1, 'Discriminação entre uso conotativo e denotativo em conjunto de frases (cobertura suplementar; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca=''Papiro'', concurso=''PAPIRO - Estilo Fundatec - BM RS'', ano=2026) — material suplementar de prática, NÃO conta para incidência histórica; registrado como COBERTURA_SUPLEMENTAR_DENOTACAO_CONOTACAO. Regra testada: em ''Ele carregava o peso da responsabilidade'', ''responsabilidade'' é entidade abstrata sem massa física mensurável — ''peso'' expressa carga/dificuldade/importância, caracterizando uso conotativo, em contraste com as 4 alternativas erradas, todas inequivocamente denotativas (peso físico mensurável em quilos, material do móvel, horário objetivo, quantidade de páginas). CAUTELA PEDAGÓGICA APLICADA: a heurística ''termo abstrato + propriedade física = conotação'' é tratada como PISTA/REGRA DE BOLSO, não regra universal absoluta — a decisão depende sempre do contexto concreto da frase, não de uma fórmula mecânica aplicável a qualquer combinação de abstrato com propriedade física. Gabarito: A. Categoria: D) contraste (frase conotativa em meio a distratores denotativos).', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (3/3).
-- 228,229,230

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Denotação e conotação: 3 questoes distintas
-- Total de vinculos esperados: 3 (3 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
