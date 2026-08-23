-- Mapa de classificacao semantica das questoes validas de Interpretação de textos
-- (curso_conteudos.id = 12, assunto_id = 15,
-- materia_id = 6), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/interpretacao_de_textos.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_interpretacao_de_textos_teste_rollback.sql
--   classificar_questoes_unidades_interpretacao_de_textos.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 12 (apos curadoria_unidades_interpretacao_de_textos.sql):
--   U1 138aafa7-066c-40fd-9fa5-7f1b90406db2  ordem 1  Interpretação de textos
--
-- Resultado da curadoria: 3/3 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (17, '138aafa7-066c-40fd-9fa5-7f1b90406db2'::uuid, 1, 'Identificação da tese em texto dissertativo-argumentativo (cobertura suplementar; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca=''Papiro - estilo Fundatec'', concurso=''Brigada Militar do Rio Grande do Sul'', ano e fonte ausentes — METADADO_PROVENIENCIA_INCOMPLETO_Q17, não preenchido por inferência) — material suplementar de prática, NÃO conta para incidência histórica, ocorrência Fundatec, recência ou prioridade pré-edital baseada em prova real; registrado como COBERTURA_SUPLEMENTAR_TESE. Regra testada: em um texto dissertativo-argumentativo, a tese corresponde ao posicionamento central defendido pelo autor — distinta de exemplo secundário, título, repetição literal do primeiro parágrafo ou informação necessariamente implícita. Categoria: A) habilidade conceitual/doutrinária.', 'alta'),
    (65, '138aafa7-066c-40fd-9fa5-7f1b90406db2'::uuid, 1, 'Compreensão global e fidelidade ao texto — distinção entre afirmação sustentada e generalização indevida (núcleo pré-edital primário — questão REAL)', 'Questão REAL (Fundatec, BM RS Soldado de Primeira Classe, 2025, Questão 01). Texto-base ''Quando da tragédia brotam heróis e lições'' (Oscar Bessi), restaurado com marcadores [01]-[32] em saneamento próprio (commit ac67dd1), preservado intacto nesta curadoria. Nesta questão real do corpus, a Fundatec exigiu: (I) reconhecer a transição estrutural entre o primeiro parágrafo (resultados nefastos da tragédia) e o segundo (eventos positivos em meio ao caos) [correto]; (II) identificar que a assertiva generaliza indevidamente ao afirmar que a solidariedade fez ''desaparecer'' a prática de atos reprováveis, quando o texto menciona explicitamente saques e crimes durante o caos — extrapolação clássica sinalizada por palavra generalizante [incorreto]; (III) reconhecer a conclusão do texto sobre esperança e o lado bom do ser humano, sustentada pelo próprio texto [correto]. Gabarito: C (I e III). HABILIDADE NUCLEAR: compreensão global/fidelidade textual — distinguir o que o texto sustenta do que extrapola, com atenção a palavras generalizantes (''desaparecer'', ''todos'', ''sempre''). A evidência real disponível neste corpus mostra exatamente esse fenômeno, sem que se possa afirmar recorrência a partir de uma única ocorrência. Categoria: E) habilidade semântica/interpretativa.', 'alta'),
    (306, '138aafa7-066c-40fd-9fa5-7f1b90406db2'::uuid, 1, 'Inferência válida × extrapolação × redução × contradição (cobertura suplementar; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca=''Papiro'', concurso=''PAPIRO - Adaptada do padrão Fundatec 2025/2026'', 2026) — material suplementar de prática, NÃO conta para incidência histórica; registrado como COBERTURA_SUPLEMENTAR_INFERENCIA — esta habilidade não possui questão REAL específica neste corpus atual. Regra testada: uma inferência válida deve ser sustentada por elementos presentes no texto, nunca contradizer as premissas do autor, ser objetiva (não subjetiva), considerar o contexto e não se basear em informação inexistente. Os 3 erros clássicos de interpretação: extrapolação (inventar dado além do texto), redução (considerar só um detalhe, perder a ideia geral), contradição (concluir o inverso do que o autor afirmou). Categoria: A) habilidade conceitual/doutrinária.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (3/3).
-- 17,65,306

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Interpretação de textos: 3 questoes distintas
-- Total de vinculos esperados: 3 (3 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
