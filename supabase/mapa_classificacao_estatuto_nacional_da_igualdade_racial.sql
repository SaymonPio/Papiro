-- Mapa de classificacao semantica das questoes validas de Estatuto Nacional da Igualdade Racial
-- (curso_conteudos.id = 67, assunto_id = 75,
-- materia_id = 10), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/estatuto_nacional_da_igualdade_racial.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_estatuto_nacional_da_igualdade_racial_teste_rollback.sql
--   classificar_questoes_unidades_estatuto_nacional_da_igualdade_racial.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 67 (apos curadoria_unidades_estatuto_nacional_da_igualdade_racial.sql):
--   U1 5bf890e1-8e09-4f7a-9410-7f5e5168d9c4  ordem 1  Estatuto Nacional da Igualdade Racial
--
-- Resultado da curadoria: 5/5 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (54, '5bf890e1-8e09-4f7a-9410-7f5e5168d9c4'::uuid, 1, 'Ouvidorias, acesso à justiça, violência policial e servidores públicos', 'Questao INCORRETA: alt1 (verdadeira, acoes de ressocializacao da juventude negra) art. 53, paragrafo unico. Alt2 (INCORRETA selecionada — real e ''entre outros instrumentos'', nao ''exclusivamente'') art. 55, caput. Alt3 (verdadeira, medidas para coibir violencia policial) art. 53, caput. Alt4 (verdadeira, acesso a Ouvidoria/Defensoria/MP/Judiciario) art. 52, caput. Alt5 (verdadeira, medidas contra discriminacao por servidores publicos, Lei 7.716/1989) art. 54, caput.', 'alta'),
    (135, '5bf890e1-8e09-4f7a-9410-7f5e5168d9c4'::uuid, 1, 'Liberdade de consciência/crença e cultos de matriz africana', 'Questao INCORRETA: alt1 (verdadeira, inviolabilidade da liberdade de consciencia e crenca) art. 23, caput. Alt2 (verdadeira, acesso a orgaos e meios de comunicacao) art. 24, VII. Alt3 (verdadeira, combate a intolerancia — inventariar/restaurar/proteger documentos e sitios) art. 26, II. Alt4 (verdadeira, celebracao de festividades e cerimonias) art. 24, II. Alt5 (INCORRETA selecionada — real e ''inclusive'' presos com pena privativa de liberdade, nao ''exceto'') art. 25, caput.', 'alta'),
    (302, '5bf890e1-8e09-4f7a-9410-7f5e5168d9c4'::uuid, 1, 'Objeto da lei', 'Gabarito: ''Efetivacao da igualdade de oportunidades e defesa de direitos'' — art. 1o, caput. Distratores sem correspondencia normativa (privilegio penal absoluto, imunidade tributaria geral, acesso exclusivo a cargos publicos, dispensa de deveres legais).', 'alta'),
    (348, '5bf890e1-8e09-4f7a-9410-7f5e5168d9c4'::uuid, 1, 'Mercado de trabalho, organização institucional e disposições finais', 'Questao INCORRETA: alt1 (verdadeira, politicas de formacao profissional/emprego/geracao de renda) art. 39, §1o. Alt2 (verdadeira, criterios para cargos em comissao ampliando participacao de negros) art. 42, caput. Alt3 (INCORRETA selecionada — real e ''nao excluem'' outras medidas, nao ''substituem'') art. 58, caput. Alt4 (verdadeira, diretrizes elaboradas por orgao colegiado com participacao da sociedade civil) art. 49, §3o. Alt5 (verdadeira, acoes de ressocializacao da juventude negra) art. 53, paragrafo unico.', 'alta'),
    (350, '5bf890e1-8e09-4f7a-9410-7f5e5168d9c4'::uuid, 1, 'Definições legais', 'Associacao Coluna 1/Coluna 2: discriminacao racial = art. 1o, paragrafo unico, I. Desigualdade racial = art. 1o, paragrafo unico, II. Politicas publicas = art. 1o, paragrafo unico, V. Acoes afirmativas = art. 1o, paragrafo unico, VI. Gabarito ''1-2-3-4'' confere com a ordem literal do texto.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (5/5).
-- 54,135,302,348,350

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Estatuto Nacional da Igualdade Racial: 5 questoes distintas
-- Total de vinculos esperados: 5 (5 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
