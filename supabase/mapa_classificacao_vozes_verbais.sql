-- Mapa de classificacao semantica das questoes validas de Vozes verbais
-- (curso_conteudos.id = 32, assunto_id = 51,
-- materia_id = 6), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/vozes_verbais.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_vozes_verbais_teste_rollback.sql
--   classificar_questoes_unidades_vozes_verbais.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 32 (apos curadoria_unidades_vozes_verbais.sql):
--   U1 1cb6bef3-1d8d-4cae-9ed9-eae9fe4d79b9  ordem 1  Vozes verbais
--
-- Resultado da curadoria: 3/3 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (243, '1cb6bef3-1d8d-4cae-9ed9-eae9fe4d79b9'::uuid, 1, 'Reconhecimento de voz ativa (cobertura suplementar; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca=''Papiro'', concurso=''PAPIRO - Estilo Fundatec - BM RS'', ano=2026) — material suplementar de prática, NÃO conta para incidência histórica, frequência Fundatec, recência ou ocorrência real em concurso; registrado como COBERTURA_SUPLEMENTAR_VOZES_VERBAIS. Fenômeno testado: em ''A equipe concluiu o relatório'', o sujeito ''A equipe'' ocupa a posição característica da estrutura ativa (aqui, coincidindo com o papel de agente da ação verbal) — VOZ ATIVA (gabarito A). CAUTELA PEDAGÓGICA: não definir voz ativa de forma absoluta como ''sujeito = agente'' — em exemplos prototípicos de ação o sujeito costuma corresponder ao agente, mas isso não é universal (ex.: ''João sofreu muito'' é ativa sem que ''João'' seja agente de ação voluntária). Distratores cobrem passiva analítica, passiva sintética, reflexiva e recíproca como categorias distintas — sem inflar a cobertura do banco, já que somente o reconhecimento de voz ATIVA é o núcleo desta questão. Categoria: A) regra conceitual. Explicação armazenada NÃO alterada nesta curadoria.', 'alta'),
    (244, '1cb6bef3-1d8d-4cae-9ed9-eae9fe4d79b9'::uuid, 1, 'Transformação ativa → passiva analítica (cobertura suplementar; origem=AUTORAL_PAPIRO; decisão taxonômica definitiva: não é Reescrita)', 'ORIGEM: AUTORAL_PAPIRO (banca=''Papiro'', concurso=''PAPIRO - Estilo Fundatec - BM RS'', ano=2026) — material suplementar de prática, NÃO conta para incidência histórica; registrado como COBERTURA_SUPLEMENTAR_VOZES_VERBAIS. Fenômeno testado: transposição mecânica de ''Os candidatos resolveram as questões'' (ativa) para ''As questões foram resolvidas pelos candidatos'' (passiva analítica, gabarito A) — objeto direto (''as questões'') vira sujeito paciente; SER preserva tempo/modo da forma original + particípio (''foram resolvidas''); sujeito da ativa vira agente da passiva (''pelos candidatos''). DECISÃO TAXONÔMICA DEFINITIVA (aprovada pelo usuário, não realocar): permanece em Vozes verbais, não em Reescrita de frases e textos (onde estão Q72/Q280, também sobre transposição de voz) — a fronteira correta é pela habilidade nuclear: o comando de Q244 (''A forma passiva de X é:'') já determina explicitamente a transformação exigida, dispensando que o aluno descubra por conta própria qual estratégia de reescrita preserva o sentido (habilidade mais ampla, própria de Reescrita, exigida por Q72/Q280, cujo comando é aberto: ''assinale a reescrita que... não apresente divergência de sentido''). Teste contrafactual aprovado: aluno que domina somente Vozes verbais resolve Q244 sem precisar do conteúdo mais amplo de Reescrita. LIMITE: não ensinar que qualquer oração ativa admite essa transformação mecanicamente — pressupõe estrutura passivizável. Distratores cobrem inversão de papéis semânticos (ativa mantida com sentido invertido; passiva analítica com papéis trocados), passiva sintética truncada com o termo errado como sujeito, e erro gramatical de conjugação — nenhum exige conhecimento independente de Reescrita como técnica geral de paráfrase. Categoria: B) regra morfológica (mecânica de transformação). Explicação armazenada NÃO alterada nesta curadoria.', 'alta'),
    (245, '1cb6bef3-1d8d-4cae-9ed9-eae9fe4d79b9'::uuid, 1, 'Reconhecimento de passiva sintética/pronominal, com distinção de análises concorrentes (cobertura suplementar; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca=''Papiro'', concurso=''PAPIRO - Estilo Fundatec - BM RS'', ano=2026) — material suplementar de prática, NÃO conta para incidência histórica; registrado como COBERTURA_SUPLEMENTAR_VOZES_VERBAIS. Fenômeno testado: em ''Vendem-se apartamentos'', o verbo transitivo direto ''vender'' + partícula ''se'' + ''apartamentos'' como sujeito paciente (verbo concordando no plural) caracteriza VOZ PASSIVA SINTÉTICA/PRONOMINAL (gabarito A), equivalente à passiva analítica ''Apartamentos são vendidos''. CAUTELA CONTRA ALGORITMO MECÂNICO: a regra ''VTD+SE+substantivo = partícula apassivadora'' e ''VTI/VI/VL+SE = índice de indeterminação'' (mencionada no BIZU armazenado) deve ser tratada como pista inicial útil, não fórmula infalível — a análise completa considera transitividade no uso concreto, estrutura sintática, existência de sujeito paciente, concordância, e a possibilidade de reconstruir uma paráfrase em passiva analítica equivalente como teste de análise (não algoritmo isolado). Distratores cobrem confusão com voz ativa, com reflexividade (apartamentos não vendem a si próprios) e com passiva analítica (mesma ideia, estrutura diferente — ''são vendidos'' vs. ''vendem-se''). Categoria: A) regra conceitual. Explicação armazenada NÃO alterada nesta curadoria.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (3/3).
-- 243,244,245

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Vozes verbais: 3 questoes distintas
-- Total de vinculos esperados: 3 (3 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
