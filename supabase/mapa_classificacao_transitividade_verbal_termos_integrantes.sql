-- Mapa de classificacao semantica das questoes validas de Transitividade Verbal e Termos Integrantes (Objeto Direto e Indireto, Complemento Nominal e Agente da Passiva)
-- (curso_conteudos.id = 27, assunto_id = 30,
-- materia_id = 6), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/transitividade_verbal_termos_integrantes.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_transitividade_verbal_termos_integrantes_teste_rollback.sql
--   classificar_questoes_unidades_transitividade_verbal_termos_integrantes.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 27 (apos curadoria_unidades_transitividade_verbal_termos_integrantes.sql):
--   U1 981e5d2c-3b59-48a0-a699-a53c03e500ee  ordem 1  Transitividade Verbal e Termos Integrantes (Objeto Direto e Indireto, Complemento Nominal e Agente da Passiva)
--
-- Resultado da curadoria: 5/5 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (34, '981e5d2c-3b59-48a0-a699-a53c03e500ee'::uuid, 1, 'Objeto direto preposicionado × objeto direto pronominal (bloco A: transitividade e complementos verbais)', 'Questão real (Fundatec — PENDÊNCIA DE METADADO: concurso e ano ausentes no banco, motivo METADADO_PROVENIENCIA_INCOMPLETO_Q34, não saneada nesta etapa; conta como evidência qualitativa de que o fenômeno é cobrado pela Fundatec, mas sem peso de recência/distribuição por concurso-carreira-ano no futuro Raio-X). Regra testada: ''ao caçador'' é objeto direto preposicionado (VTD com ordem invertida, preposição usada para evitar ambiguidade sobre quem pratica a ação — mecanismo específico desta construção, não regra universal); ''perseguiram-no'' e ''trouxeram-no'' são objetos diretos pronominais. Categoria: A) regra produtiva.', 'alta'),
    (123, '981e5d2c-3b59-48a0-a699-a53c03e500ee'::uuid, 1, '''Lhes'' sempre objeto indireto; ''quem'' como sujeito determinado em oração subjetiva (bloco A)', 'Questão real (Fundatec, Brigada Militar RS - Soldado Nível III/2022). Regra testada: ''Quem for diferente da sua tribo'' exerce função de sujeito da oração subordinada substantiva subjetiva (assertiva I correta); ''quem'' é sujeito determinado desta oração, não sujeito indeterminado (assertiva II incorreta); ''lhes'' funciona como objeto indireto, nunca como objeto direto na norma-padrão (assertiva III incorreta). Categoria: D) contraste.', 'alta'),
    (283, '981e5d2c-3b59-48a0-a699-a53c03e500ee'::uuid, 1, 'VTDI: objeto direto × objeto indireto (bloco A; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca=''Papiro'', concurso=''PAPIRO - Adaptada do padrão Fundatec 2025/2026'', 2026) — material suplementar de prática, NÃO conta como incidência histórica real. Regra testada: em ''O servidor entregou o documento ao chefe'' (verbo transitivo direto e indireto), ''o documento'' é objeto direto (a coisa entregue, sem preposição exigida) e ''ao chefe'' é objeto indireto (o destinatário, com preposição exigida). Categoria: A) regra produtiva.', 'alta'),
    (284, '981e5d2c-3b59-48a0-a699-a53c03e500ee'::uuid, 1, 'Agente da passiva (bloco B; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO — material suplementar de prática, NÃO conta como incidência histórica real. Regra testada: em ''A decisão foi tomada pelo comandante'' (voz passiva analítica), ''pelo comandante'' exerce função de agente da passiva, identificado pela preposição ''pelo'' (pista forte, não definição isolada) e pela conversão coerente para a ativa (''o comandante tomou a decisão''). Categoria: A) regra produtiva.', 'alta'),
    (332, '981e5d2c-3b59-48a0-a699-a53c03e500ee'::uuid, 1, 'Agente da passiva, sujeito paciente e erro de reescrita na conversão para ativa (bloco B)', 'Questão real (Fundatec, Corpo de Bombeiros Militar RS - Soldado 1ª Classe/2025). CONFIRMADA AUTOSSUFICIENTE nesta curadoria: a notação ''(l. 02-03)'' é apenas indicação de proveniência do trecho já integralmente citado entre aspas no próprio enunciado — removida da lista de pendências globais de referência de linha sem marcador navegável (que passa a conter apenas Q758, Q810, Q879, Q894); nenhuma alteração de dado foi feita. Regra testada: no trecho ''[...] quando a capital foi devastada por um grande incêndio'', ''por um grande incêndio'' é o agente da passiva (assertiva II correta); ''a capital'' é o sujeito paciente (assertiva III correta); a reescrita proposta na assertiva I (''um grande incêndio devastou-se pela capital'') introduz reflexividade indevida, tornando a conversão para a ativa incorreta (a forma correta seria ''um grande incêndio devastou a capital'') — assertiva I incorreta. Categoria: D) contraste.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (5/5).
-- 34,123,283,284,332

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Transitividade Verbal e Termos Integrantes (Objeto Direto e Indireto, Complemento Nominal e Agente da Passiva): 5 questoes distintas
-- Total de vinculos esperados: 5 (5 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
