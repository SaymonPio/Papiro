-- Mapa de classificacao semantica das questoes validas de Poderes da Administração Pública
-- (curso_conteudos.id = 59, assunto_id = 81,
-- materia_id = 10), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/poderes_da_administracao_publica.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_poderes_da_administracao_publica_teste_rollback.sql
--   classificar_questoes_unidades_poderes_da_administracao_publica.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 59 (apos curadoria_unidades_poderes_da_administracao_publica.sql):
--   U1 8cb82a8e-e0f4-4d46-a4a5-7443f31912a4  ordem 1  Poderes da Administração Pública
--
-- Resultado da curadoria: 4/4 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (207, '8cb82a8e-e0f4-4d46-a4a5-7443f31912a4'::uuid, 1, 'Poder hierárquico', 'Gabarito: ''Distribuir e escalonar funcoes e fiscalizar a atuacao interna'' — doutrina do poder hierarquico, sem dispositivo legal especifico atribuido. Distratores sem correspondencia normativa (criar crimes, julgar acoes judiciais, editar emendas constitucionais, aplicar pena a particular sem vinculo).', 'alta'),
    (208, '8cb82a8e-e0f4-4d46-a4a5-7443f31912a4'::uuid, 1, 'Poder disciplinar', 'Gabarito: ''Apurar infracoes e aplicar sancoes administrativas a servidores e demais pessoas sujeitas a disciplina administrativa'' — doutrina do poder disciplinar, sem dispositivo legal especifico atribuido. Distratores sem correspondencia normativa (alterar a Constituicao, criar tributos, prender qualquer cidadao sem lei, revogar leis).', 'alta'),
    (209, '8cb82a8e-e0f4-4d46-a4a5-7443f31912a4'::uuid, 1, 'Poder regulamentar', 'Gabarito: ''Expedir atos normativos destinados a fiel execucao da lei'' — CF art. 84, IV (''expedir decretos e regulamentos para sua fiel execucao''), correspondencia quase literal, verificada em fonte oficial. Distratores sem correspondencia (criar delitos, substituir o Poder Judiciario, revogar a Constituicao, dispensar a lei).', 'alta'),
    (360, '8cb82a8e-e0f4-4d46-a4a5-7443f31912a4'::uuid, 1, 'Abuso de poder: excesso de poder e desvio de finalidade', 'Assertiva I (verdadeira, doutrina): no desvio de poder/finalidade, o agente atua visando interesse alheio ao interesse publico — parafrase do art. 2o, paragrafo unico, ''e'', da Lei 4.717/1965. Assertiva II (verdadeira): comete excesso de poder o agente que exorbita de suas atribuicoes — o texto legal (art. 2o, paragrafo unico, ''a'', Lei 4.717/1965) usa literalmente o termo ''incompetencia'' (''quando o ato nao se incluir nas atribuicoes legais do agente''); a associacao com ''excesso de poder'' e da doutrina administrativista, nao do texto legal. Assertiva III (verdadeira, gabarito): desvio de finalidade/desvio de poder/tredestinacao ilicita torna nulo o ato quando praticado visando fim diverso do previsto na regra de competencia — correspondencia quase literal com o art. 2o, paragrafo unico, ''e'', da Lei 4.717/1965, verificada em fonte oficial. Gabarito ''I, II e III'' confere.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (4/4).
-- 207,208,209,360

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Poderes da Administração Pública: 4 questoes distintas
-- Total de vinculos esperados: 4 (4 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
