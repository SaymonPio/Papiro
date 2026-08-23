-- Mapa de classificacao semantica das questoes validas de Regência verbal e nominal
-- (curso_conteudos.id = 17, assunto_id = 42,
-- materia_id = 6), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/regencia_verbal_e_nominal.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_regencia_verbal_e_nominal_teste_rollback.sql
--   classificar_questoes_unidades_regencia_verbal_e_nominal.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 17 (apos curadoria_unidades_regencia_verbal_e_nominal.sql):
--   U1 735f736a-37c0-477f-a555-dcd73d243d21  ordem 1  Regência verbal e nominal
--
-- Resultado da curadoria: 3/3 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (120, '735f736a-37c0-477f-a555-dcd73d243d21'::uuid, 1, 'Pronomes relativos e regência da oração subordinada — em que/que/cujo (núcleo pré-edital primário — questão REAL)', 'Questão REAL (Fundatec, BM RS Soldado Nível III, 2022, Questão 02). Nesta questão real do corpus, a Fundatec cobrou o emprego de pronomes relativos associado à regência da estrutura sintática — não deve ser apresentado como fenômeno recorrente na banca a partir de uma única ocorrência. Regra testada: (1) ''o cenário em que nos encontramos'' — reconstrução ''encontramo-nos EM [algo]'', o verbo ''encontrar-se'' rege a preposição ''em'' nesse sentido, logo ''em que''; (2) ''as transformações que presenciamos'' — reconstrução ''presenciamos [algo]'', ''presenciar'' é transitivo direto (sem preposição), logo apenas ''que''; (3) ''o autor ___ obra foi citada'' — a regra geral de CUJO estabelece relação de posse entre o antecedente possuidor (''autor'') e o substantivo posterior possuído (''obra''), concordando em gênero/número com este último (''cuja obra'', por ''obra'' ser feminino) e nunca admitindo artigo entre si e o substantivo posterior (''cujo o'', ''cuja a'' não existem). PENDÊNCIA DE FIDELIDADE A VERIFICAR (não bloqueante): a alternativa gabaritada armazenada no Papiro usa a forma invariável ''cujo'' nessa lacuna (não ''cuja''), padrão repetido nas 5 alternativas — pode refletir fielmente o caderno original (a variação testada entre as alternativas está no artigo/preposição/duplicação de ''qual'', não na concordância de ''cujo'') ou uma imprecisão de transcrição; recomenda-se checagem futura contra o caderno original antes de usar esta questão como exemplo textual literal na aula, sem que isso altere o gabarito relativo entre as alternativas (a de ordem 1 continua sendo a única sem erro adicional). Gabarito: A (em que – que – cujo). CORREÇÃO CONCEITUAL APLICADA: a preposição antes do relativo não decorre de ''regência do antecedente'' (formulação imprecisa), mas da regência do termo da oração subordinada que se relaciona com o relativo — procedimento: reconstruir a oração substituindo o relativo pelo antecedente, identificar o termo regente, e usar a preposição exigida por ele + ''que''. Regra de bolso: ''retire o relativo e reconstrua a frase''. Categoria: B) regra estrutural específica.', 'alta'),
    (281, '735f736a-37c0-477f-a555-dcd73d243d21'::uuid, 1, 'Regência verbal — assistir, aspirar, obedecer, preferir (cobertura suplementar; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca=''Papiro'', concurso=''PAPIRO - Adaptada do padrão Fundatec 2025/2026'', 2026) — material suplementar de prática, NÃO conta para incidência histórica, frequência Fundatec, recência ou prioridade baseada em prova real; registrado como cobertura suplementar. Regra testada, no padrão formal tradicional exigido em concursos: ''assistir'' (ver/presenciar) = VTI + ''a'' (''assistiu à palestra'', com crase decorrente); ''aspirar'' (cheirar/inalar) = VTD, sem preposição (''aspirou o perfume''); ''aspirar'' (almejar) = VTI + ''a''; ''obedecer/desobedecer'' = sempre VTI + ''a'' (''obedeceu ao regulamento''); ''preferir'' = VTD+VTI com ''a'', rejeitando construções comparativas redundantes como ''mais...do que'' (''preferiu estudar a trabalhar''). Gabarito: A. Categoria: A) regra produtiva/lexical + D) contraste de sentidos (aspirar cheirar × almejar).', 'alta'),
    (282, '735f736a-37c0-477f-a555-dcd73d243d21'::uuid, 1, 'Regência verbal com crase decorrente — obedecer, visar, chegar/ir, preferir (cobertura suplementar; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca=''Papiro'', concurso=''PAPIRO - Adaptada do padrão Fundatec 2025/2026'', 2026) — material suplementar de prática, NÃO conta para incidência histórica; registrado como cobertura suplementar. Regra testada, no padrão formal tradicional exigido em concursos: ''obedecer'' = VTI + ''a'', com crase decorrente da fusão com artigo feminino plural (''obedeceu às normas do edital'' = a + as); ''visar'' (almejar) = VTI + ''a'' no padrão tradicional de concurso (''visou ao cargo''; ''visar'' no sentido de mirar/apor visto é VTD — eventual divergência contemporânea entre gramáticas/dicionários sobre outros usos deve ser tratada como PADRÃO TRADICIONAL DE CONCURSO × USO CONTEMPORÂNEO ADMITIDO POR ALGUMAS FONTES, sem aprofundar agora); ''chegar/ir'' regem ''a'' para indicar destino no padrão formal tradicional cobrado em concursos (''chegou ao quartel'') — CAUTELA PEDAGÓGICA: não ensinar como regra absoluta ''nunca use em''; ''chegar em'' é amplamente utilizado na língua falada e em registros menos monitorados, sendo apenas a forma normativa tradicional a exigida pela questão de concurso, não uma forma inexistente; ''preferir'' rejeitando ''mais...do que''. Gabarito: A. DISTINÇÃO REGISTRADA: regência (a preposição exigida pelo verbo) é distinta de crase (fusão dessa preposição ''a'' com artigo feminino ''a/as'') — a regência fornece a preposição, a crase resulta da fusão. NOTA: a formulação ''Nunca use EM!'' presente na explicação armazenada desta questão NÃO foi alterada nesta curadoria (nenhum saneamento aprovado); a cautela pedagógica fica registrada neste mapa/escopo e deverá orientar a futura aula. Categoria: A) regra produtiva/lexical + D) contraste (regência × crase).', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (3/3).
-- 120,281,282

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Regência verbal e nominal: 3 questoes distintas
-- Total de vinculos esperados: 3 (3 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
