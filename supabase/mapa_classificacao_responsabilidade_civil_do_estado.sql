-- Mapa de classificacao semantica das questoes validas de Responsabilidade civil do Estado
-- (curso_conteudos.id = 61, assunto_id = 76,
-- materia_id = 10), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/responsabilidade_civil_do_estado.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_responsabilidade_civil_do_estado_teste_rollback.sql
--   classificar_questoes_unidades_responsabilidade_civil_do_estado.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 61 (apos curadoria_unidades_responsabilidade_civil_do_estado.sql):
--   U1 d6f03d69-8943-4867-a2af-e37482d4ca99  ordem 1  Responsabilidade civil do Estado
--
-- Resultado da curadoria: 3/3 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (213, 'd6f03d69-8943-4867-a2af-e37482d4ca99'::uuid, 1, 'Natureza objetiva da responsabilidade estatal', 'Gabarito: ''Objetiva'' — responsabilidade civil das pessoas juridicas de direito publico perante terceiros, CF art. 37, §6o. Distratores sem correspondencia (subjetiva exclusivamente, inexistente, penal, contratual obrigatoriamente).', 'alta'),
    (214, 'd6f03d69-8943-4867-a2af-e37482d4ca99'::uuid, 1, 'Ação regressiva contra o agente — dolo ou culpa', 'Gabarito: ''Dolo ou culpa do agente'' — CF art. 37, §6o (''assegurado o direito de regresso contra o responsavel nos casos de dolo ou culpa''), reforcado pelo Tema 940 de repercussao geral do STF (RE 1.027.633/2019): a acao indenizatoria pelos danos causados pelo agente publico, nessa qualidade, deve ser ajuizada contra o Estado ou contra a pessoa juridica de direito privado prestadora de servico publico; o agente causador e parte ilegitima nessa acao; permanece assegurado o direito de regresso contra o responsavel nos casos de dolo ou culpa. Distratores sem correspondencia (responsabilidade objetiva do agente, apenas dano moral, condenacao criminal obrigatoria, autorizacao legislativa especifica).', 'alta'),
    (215, 'd6f03d69-8943-4867-a2af-e37482d4ca99'::uuid, 1, 'Elementos da responsabilidade objetiva', 'Gabarito: ''Dano e nexo causal com a atuacao estatal'' — na responsabilidade objetiva (CF art. 37, §6o), dispensa-se a demonstracao de dolo ou culpa do agente, devendo existir dano e nexo causal com a atuacao estatal juridicamente imputavel. Distratores sem correspondencia (dolo do agente obrigatoriamente, culpa grave do Estado sempre, condenacao criminal do servidor, enriquecimento ilicito).', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (3/3).
-- 213,214,215

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Responsabilidade civil do Estado: 3 questoes distintas
-- Total de vinculos esperados: 3 (3 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
