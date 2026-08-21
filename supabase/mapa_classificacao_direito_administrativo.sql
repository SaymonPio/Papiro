-- Mapa de classificacao semantica das questoes validas de Direito Administrativo
-- (curso_conteudos.id = 58, assunto_id = 65,
-- materia_id = 10), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/direito_administrativo.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_direito_administrativo_teste_rollback.sql
--   classificar_questoes_unidades_direito_administrativo.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 58 (apos curadoria_unidades_direito_administrativo.sql):
--   U1 1172a885-1419-4ad8-b728-1a0c7492c133  ordem 1  Direito Administrativo
--
-- Resultado da curadoria: 8/8 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (195, '1172a885-1419-4ad8-b728-1a0c7492c133'::uuid, 1, 'Princípios da Administração Pública', 'Principio da legalidade: a Administracao deve atuar conforme a lei e o Direito — Constituicao Federal, art. 37, caput.', 'alta'),
    (196, '1172a885-1419-4ad8-b728-1a0c7492c133'::uuid, 1, 'Organização administrativa', 'Autarquia integra a administracao indireta — Decreto-Lei no 200/1967, art. 4o, II.', 'alta'),
    (197, '1172a885-1419-4ad8-b728-1a0c7492c133'::uuid, 1, 'Poderes administrativos / autotutela', 'Autotutela administrativa: anular atos ilegais e revogar atos validos por conveniencia e oportunidade — art. 53 da Lei 9.784/1999 e Sumula 473 do STF (sumula so no escopo/justificativa, nao em artigos_esperados). SOBREPOSICAO TEMATICA: mesmo instituto ja testado no curso_conteudo_id 54 (Atos administrativos, questoes 268 e 714) — nao e questao duplicada, mantida neste conteudo por decisao do usuario.', 'alta'),
    (721, '1172a885-1419-4ad8-b728-1a0c7492c133'::uuid, 1, 'Princípios da Administração Pública', 'Ausencia de edital de concurso fere o principio da publicidade — Constituicao Federal, art. 37, caput. SOBREPOSICAO TEMATICA: mesmo artigo (com outros incisos/enfoque) tambem coberto pelo curso_conteudo_id 57 (Constituicao Federal de 1988) — mantida neste conteudo por decisao do usuario, tema proprio de Direito Administrativo.', 'alta'),
    (722, '1172a885-1419-4ad8-b728-1a0c7492c133'::uuid, 1, 'Agentes públicos e provimento de cargos', 'Doutrinario: servidor contratado e regido pela CLT, ocupante de emprego permanente ou em comissao, denomina-se empregado publico (distinto de funcionario/servidor estatutario). Sem dispositivo legal especifico atribuido.', 'alta'),
    (774, '1172a885-1419-4ad8-b728-1a0c7492c133'::uuid, 1, 'Princípios da Administração Pública', 'Estabelecer criterios de avaliacao de desempenho e execucao das atividades poe em pratica o principio da eficiencia — Constituicao Federal, art. 37, caput. SOBREPOSICAO TEMATICA com o curso_conteudo_id 57, mantida por decisao do usuario.', 'alta'),
    (796, '1172a885-1419-4ad8-b728-1a0c7492c133'::uuid, 1, 'Agentes públicos e provimento de cargos', 'Prazo de validade do concurso publico: ate 2 anos, prorrogavel uma vez por igual periodo — Constituicao Federal, art. 37, III. SOBREPOSICAO TEMATICA com o curso_conteudo_id 57, mantida por decisao do usuario.', 'alta'),
    (845, '1172a885-1419-4ad8-b728-1a0c7492c133'::uuid, 1, 'Organização administrativa', 'Autarquias, fundacoes publicas e sociedades de economia mista integram a administracao indireta — Decreto-Lei no 200/1967, art. 4o, II.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (8/8).
-- 195,196,197,721,722,774,796,845

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Direito Administrativo: 8 questoes distintas
-- Total de vinculos esperados: 8 (8 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
