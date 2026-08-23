-- Mapa de classificacao semantica das questoes validas de Conectores
-- (curso_conteudos.id = 14, assunto_id = 57,
-- materia_id = 6), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/conectores.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_conectores_teste_rollback.sql
--   classificar_questoes_unidades_conectores.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 14 (apos curadoria_unidades_conectores.sql):
--   U1 d1e31767-d27d-431b-ba59-7a2008c7473d  ordem 1  Conectores
--
-- Resultado da curadoria: 6/6 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (67, 'd1e31767-d27d-431b-ba59-7a2008c7473d'::uuid, 1, 'Estruturas correlativas: comparação, consecutiva e adição com nuance contrastiva', 'Questão real (Fundatec, Brigada Militar RS - Soldado 1ª Classe/2025). Regra testada: ''tão...quanto'' estabelece comparação (igualdade); ''tão...que'' introduz ORAÇÃO/ESTRUTURA CONSECUTIVA (consequência decorrente da intensidade); ''Mas também fez florescer...'' tem valor PREDOMINANTEMENTE ADITIVO, com nuance adversativa/contrastiva no contexto (o ''mas'' mantém componente discursivo de contraste com o conteúdo negativo do parágrafo anterior) — não ensinar como ''mas também = sempre adição pura''. Gabarito e enunciado original preservados sem alteração. Categoria: A) regra produtiva.', 'alta'),
    (121, 'd1e31767-d27d-431b-ba59-7a2008c7473d'::uuid, 1, 'Falsos amigos entre conjunções: quando×conquanto, porém=entretanto, se×porque', 'Questão real (Fundatec, Brigada Militar RS - Soldado Nível III/2022). Regra testada: ''quando'' (tipicamente temporal no uso cobrado) não equivale a ''conquanto'' (concessivo) — assertiva I falsa; ''porém'' e ''entretanto'' são adversativos sinônimos no contexto pertinente — assertiva II correta; ''se'' (condicional) não equivale a ''porque'' (causal/explicativo conforme a estrutura) — assertiva III falsa. A banca explora palavras parecidas que não têm relações semânticas iguais. Categoria: D) contraste.', 'alta'),
    (279, 'd1e31767-d27d-431b-ba59-7a2008c7473d'::uuid, 1, 'Concessão × causa × condição × conclusão × negação do fato — teste de substituição (origem=AUTORAL_PAPIRO; incorporada via saneamento taxonômico)', 'ORIGEM: AUTORAL_PAPIRO (banca=''Papiro'', concurso=''PAPIRO - Adaptada do padrão Fundatec 2025/2026'', 2026) — material suplementar de prática, NÃO conta como incidência histórica real da Fundatec no raio-x pré-edital. INCORPORADA A ESTE CONTEÚDO VIA SANEAMENTO TAXONÔMICO PRÓPRIO (originalmente cadastrada em Reescrita de frases e textos, assunto_id 49) — a auditoria da ordem 71 identificou que a habilidade nuclear e discriminante da questão é reconhecimento do valor semântico de conectores/locuções, não uma operação própria de reescrita (transposição de voz, mudança de sujeito/objeto). Regra testada: ''Embora estivesse cansado'' (concessiva) é preservada por ''Mesmo estando cansado'' (gerúndio + operador concessivo ''mesmo''), mas não por ''Como estava cansado'' (causal), ''por isso não estudou'' (conclusiva), ''Se estivesse cansado'' (condicional/hipotética) nem pela negação categórica do fato pressuposto (''Não estava cansado''). Pedagogicamente indistinguível de Q121 e Q334 (mesmo tipo de tarefa: substituir conector/locução e verificar se a relação lógica se mantém). Categoria: D) contraste.', 'alta'),
    (305, 'd1e31767-d27d-431b-ba59-7a2008c7473d'::uuid, 1, '''Contudo'' = adversativa (origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca=''Papiro'', concurso=''PAPIRO - Adaptada do padrão Fundatec 2025/2026'', 2026) — material suplementar introdutório, NÃO conta como incidência histórica real, não aumenta artificialmente a frequência da Fundatec, não justifica sozinha nenhum núcleo pedagógico. Regra testada: ''contudo'' é conjunção adversativa, expressando oposição/contraste. Categoria: A) regra produtiva.', 'alta'),
    (316, 'd1e31767-d27d-431b-ba59-7a2008c7473d'::uuid, 1, '''Contudo'' = adversativa, em texto real', 'Questão real (Fundatec, GM Gravataí/RS/2025-2026). Regra testada: ''contudo'', deslocado entre vírgulas, mantém integralmente seu valor de oposição/ressalva em relação à ideia anterior. Reaproveita o mesmo texto-base de Q319 (Coesão textual, conteúdo 13, já concluído), aqui testando valor semântico do conectivo, não referenciação. Categoria: A) regra produtiva.', 'alta'),
    (334, 'd1e31767-d27d-431b-ba59-7a2008c7473d'::uuid, 1, '''Mas'' × ''caso'' (adversativa × condicional) — teste de substituição', 'Questão real (Fundatec, Corpo de Bombeiros Militar RS - Soldado 1ª Classe/2025). Regra testada: ''mas'' é adversativa (oposição); ''caso'' é condicional (hipótese) — a substituição altera a relação lógico-semântica, não apenas a ''aparência'' da palavra. Método ensinado: perguntar ''qual relação entre as ideias é criada?'', não apenas se a palavra parece caber. Categoria: D) contraste.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (6/6).
-- 67,121,279,305,316,334

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Conectores: 6 questoes distintas
-- Total de vinculos esperados: 6 (6 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
