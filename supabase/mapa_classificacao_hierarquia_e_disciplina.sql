-- Mapa de classificacao semantica das questoes validas de Hierarquia e disciplina
-- (curso_conteudos.id = 52, assunto_id = 11,
-- materia_id = 10), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/hierarquia_e_disciplina.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_hierarquia_e_disciplina_teste_rollback.sql
--   classificar_questoes_unidades_hierarquia_e_disciplina.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 52 (apos curadoria_unidades_hierarquia_e_disciplina.sql):
--   U1 cbde0aeb-3df8-4c41-a82f-91b83b529668  ordem 1  Hierarquia e disciplina
--
-- Resultado da curadoria: 3/3 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (12, 'cbde0aeb-3df8-4c41-a82f-91b83b529668'::uuid, 1, 'Hierarquia e disciplina como base institucional', 'Gabarito: ''Bases institucionais da corporacao militar'' — art. 12, caput, da LC 10.990/1997 (''A hierarquia e a disciplina militares sao a base institucional da Brigada Militar, sendo que a autoridade e a responsabilidade crescem com o grau hierarquico''). SOBREPOSICAO: questao estruturalmente proxima de Q20 e Q300, ja classificadas no curso_conteudo_id 51 (Estatuto dos Militares Estaduais), mesmo dispositivo e mesma ideia central. Mantida neste conteudo por decisao do usuario — nenhuma movimentacao/exclusao. Distratores sem correspondencia (regras so para guerra, principios facultativos para temporarios, criterios so remuneratorios).', 'alta'),
    (45, 'cbde0aeb-3df8-4c41-a82f-91b83b529668'::uuid, 1, 'Hierarquia, disciplina, círculos hierárquicos e precedência (multi-dispositivo)', 'Questao ''assinale a correta'': alt1 (falsa, invertida — real e ''por postos ou graduacoes E... pela antiguidade'', nao ''exclusivamente'' por postos/graduacoes) art. 12, §1o. Alt2 (verdadeira, gabarito — copia quase literal ''a disciplina militar e a rigorosa observancia e o acatamento integral das leis, regulamentos, normas e disposicoes...'') art. 12, §2o. Alt3 (falsa, invertida — real e que disciplina/hierarquia sao mantidas incluindo reserva remunerada e reformados, nao excetuando-os) art. 12, §3o. Alt4 (falsa, invertida — real e ''mesma categoria'', nao ''distintas categorias'') art. 13, caput. Alt5 (falsa, invertida — real e ''salvo nos casos de precedencia funcional'', nao ''mesmo nos casos'') art. 15, caput. SOBREPOSICAO: o ponto da alt5 (precedencia funcional do Comandante-Geral/Subcomandante-Geral/Chefe do Estado-Maior) tambem e testado por Q53 (alt4) do curso_conteudo_id 51 — mesmo dispositivo, mantido neste conteudo por decisao do usuario, nenhuma movimentacao/exclusao.', 'alta'),
    (303, 'cbde0aeb-3df8-4c41-a82f-91b83b529668'::uuid, 1, 'Definição de hierarquia militar', 'Gabarito: ''Ordenacao da autoridade em niveis diferentes dentro da estrutura militar'' — parafrase do art. 12, §1o, da LC 10.990/1997 (''A hierarquia militar e a ordenacao da autoridade em niveis diferentes, dentro da estrutura da corporacao, sendo que a ordenacao se faz por postos ou graduacoes e, dentro de um mesmo posto ou de uma mesma graduacao, se faz pela antiguidade''). Distratores sem correspondencia (eliminacao de graus, igualdade absoluta, ausencia de subordinacao, autonomia irrestrita).', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (3/3).
-- 12,45,303

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Hierarquia e disciplina: 3 questoes distintas
-- Total de vinculos esperados: 3 (3 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
