-- Mapa de classificacao semantica das questoes validas de Constituição do Estado do Rio Grande do Sul
-- (curso_conteudos.id = 50, assunto_id = 80,
-- materia_id = 10), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/constituicao_do_estado_do_rio_grande_do_sul.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_constituicao_do_estado_do_rio_grande_do_sul_teste_rollback.sql
--   classificar_questoes_unidades_constituicao_do_estado_do_rio_grande_do_sul.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 50 (apos curadoria_unidades_constituicao_do_estado_do_rio_grande_do_sul.sql):
--   U1 83636594-c69f-4de0-bf46-0e75c2ec981c  ordem 1  Constituição do Estado do Rio Grande do Sul
--
-- Resultado da curadoria: 14/14 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (39, '83636594-c69f-4de0-bf46-0e75c2ec981c'::uuid, 1, 'Servidor Militar / Brigada Militar', 'Vinculacao do servidor militar (ativo, inativo e pensionista) ao RPPS/RS — respaldo no art. 41; gabarito D mantido pela banca FUNDATEC.', 'alta'),
    (52, '83636594-c69f-4de0-bf46-0e75c2ec981c'::uuid, 1, 'Administração Pública', 'Conselhos Populares, gerenciamento da documentacao governamental e transparencia, administracao indireta, acesso a informacao — art. 19.', 'alta'),
    (295, '83636594-c69f-4de0-bf46-0e75c2ec981c'::uuid, 1, 'Princípios Fundamentais', 'Interpretacao da Constituicao Estadual em conformidade com a Constituicao Federal — vinculo tentativo ao art. 1o (adocao dos principios fundamentais da CF); numero de artigo nao confirmado com certeza absoluta nesta rodada.', 'media'),
    (355, '83636594-c69f-4de0-bf46-0e75c2ec981c'::uuid, 1, 'Princípios Fundamentais', 'Soberania popular exercida por sufragio universal, iniciativa popular/referendo/plebiscito — art. 2o.', 'alta'),
    (356, '83636594-c69f-4de0-bf46-0e75c2ec981c'::uuid, 1, 'Administração Pública', 'Publicidade dos atos sem promocao pessoal, gerenciamento da documentacao governamental, Conselhos Populares — art. 19.', 'alta'),
    (357, '83636594-c69f-4de0-bf46-0e75c2ec981c'::uuid, 1, 'Servidores Públicos Civis', 'Questao EXCETO: art. 29, VI preve 8h diarias e 40h semanais; a alternativa-gabarito (44h) e a excecao pedida de proposito — OK_ATUAL, confirmado via auditoria juridica.', 'alta'),
    (359, '83636594-c69f-4de0-bf46-0e75c2ec981c'::uuid, 1, 'Administração Pública', 'Principios expressos aplicaveis a administracao publica (legalidade, moralidade, impessoalidade, publicidade, motivacao, seguranca juridica) — art. 19.', 'alta'),
    (718, '83636594-c69f-4de0-bf46-0e75c2ec981c'::uuid, 1, 'Segurança Pública', 'Organizacao e funcionamento dos orgaos de seguranca publica, Coordenadoria-Geral de Pericias, guardas municipais — art. 124.', 'alta'),
    (719, '83636594-c69f-4de0-bf46-0e75c2ec981c'::uuid, 1, 'Segurança Pública', 'Orgaos de seguranca publica (Brigada Militar, Policia Civil, Coordenadoria-Geral de Pericias, Corpo de Bombeiros Militar, Policia Penal) — art. 124; item II (custeio integral de despesas medicas a policiais feridos em servico) confirmado vigente pela EC 82/2022.', 'alta'),
    (720, '83636594-c69f-4de0-bf46-0e75c2ec981c'::uuid, 1, 'Segurança Pública', 'Estrutura da Policia Civil (delegados de carreira, Academia de Policia, Corregedoria-Geral, chefe de policia). Item III cita invalidacao pelo STF do foro especial do chefe de policia no TJ — doutrina real e recorrente em outros estados, mas nao localizada citacao especifica confirmando o RS; manter nota de cautela jurisprudencial para a futura aula.', 'media'),
    (795, '83636594-c69f-4de0-bf46-0e75c2ec981c'::uuid, 1, 'Segurança Pública', 'Servicos de transito de competencia do Estado executados pela Brigada Militar — numero exato do artigo nao confirmado nesta rodada de pesquisa.', 'media'),
    (842, '83636594-c69f-4de0-bf46-0e75c2ec981c'::uuid, 1, 'Princípios Fundamentais', 'Simbolos do Estado (art. 6o) e bens do Estado (art. 7o); pergunta pede a alternativa INCORRETA — a data magna real e 20 de setembro (Revolucao Farroupilha), a alternativa-gabarito (07 de setembro) e a excecao pedida de proposito.', 'alta'),
    (843, '83636594-c69f-4de0-bf46-0e75c2ec981c'::uuid, 1, 'Administração Pública', 'Administracao indireta (autarquias, sociedades de economia mista, empresas publicas, fundacoes) — art. 21; pergunta EXCETO, gabarito e a opcao que nao integra a administracao indireta (empresas privadas).', 'alta'),
    (844, '83636594-c69f-4de0-bf46-0e75c2ec981c'::uuid, 1, 'Servidores Públicos Civis', 'Questao EXCETO: art. 29, X preve licenca-gestante de 120 dias; a alternativa-gabarito (90 dias) e a excecao pedida de proposito — OK_ATUAL, confirmado via auditoria juridica.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (14/14).
-- 39,52,295,355,356,357,359,718,719,720,795,842,843,844

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Constituição do Estado do Rio Grande do Sul: 14 questoes distintas
-- Total de vinculos esperados: 14 (14 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
