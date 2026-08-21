-- Mapa de classificacao semantica das questoes validas de Constituição Federal de 1988
-- (curso_conteudos.id = 57, assunto_id = 70,
-- materia_id = 10), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/constituicao_federal_de_1988.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_constituicao_federal_de_1988_teste_rollback.sql
--   classificar_questoes_unidades_constituicao_federal_de_1988.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 57 (apos curadoria_unidades_constituicao_federal_de_1988.sql):
--   U1 682804b0-2762-4aff-87f9-d7a5a81757c2  ordem 1  Constituição Federal de 1988
--
-- Resultado da curadoria: 14/14 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (48, '682804b0-2762-4aff-87f9-d7a5a81757c2'::uuid, 1, 'Administração Pública', 'Analisa o art. 37, caput (principios da administracao publica) e regras de investidura, funcoes de confianca e teto remuneratorio do Poder Legislativo.', 'alta'),
    (111, '682804b0-2762-4aff-87f9-d7a5a81757c2'::uuid, 1, 'Organização do Estado', 'Competencia privativa da Uniao para legislar sobre transito e transportes — art. 22, XI.', 'alta'),
    (296, '682804b0-2762-4aff-87f9-d7a5a81757c2'::uuid, 1, 'Princípios Fundamentais', 'Reproduz o art. 1o, caput: a Republica Federativa do Brasil constitui-se em Estado Democratico de Direito.', 'alta'),
    (327, '682804b0-2762-4aff-87f9-d7a5a81757c2'::uuid, 1, 'Nacionalidade', 'Pede a alternativa INCORRETA sobre brasileiro nato — a alternativa-gabarito descreve, na verdade, hipotese de naturalizacao (art. 12, II, b), nao de nato (art. 12, I).', 'alta'),
    (647, '682804b0-2762-4aff-87f9-d7a5a81757c2'::uuid, 1, 'Organização do Estado', 'Poder constituinte decorrente: competencia dos Estados de elaborarem suas proprias Constituicoes, observados os principios da CF.', 'alta'),
    (649, '682804b0-2762-4aff-87f9-d7a5a81757c2'::uuid, 1, 'Organização do Estado', 'Separacao e harmonia entre os tres Poderes da Uniao — art. 2o.', 'alta'),
    (650, '682804b0-2762-4aff-87f9-d7a5a81757c2'::uuid, 1, 'Administração Pública', 'Caso concreto de publicacao de edital de concurso publico — principio da publicidade, art. 37, caput.', 'alta'),
    (651, '682804b0-2762-4aff-87f9-d7a5a81757c2'::uuid, 1, 'Princípios Fundamentais', 'Pede o fundamento da Republica que NAO consta do art. 1o (defesa da paz e principio das relacoes internacionais, art. 4o, nao fundamento do art. 1o).', 'alta'),
    (652, '682804b0-2762-4aff-87f9-d7a5a81757c2'::uuid, 1, 'Nacionalidade', 'Identifica corretamente hipotese de brasileiro nato nascido no exterior, filho de mae brasileira a servico do Brasil — art. 12, I, b.', 'alta'),
    (653, '682804b0-2762-4aff-87f9-d7a5a81757c2'::uuid, 1, 'Administração Pública', 'Disposicoes gerais do art. 37 (avaliacao de politicas publicas); distratores tocam teto remuneratorio/parcelas indenizatorias (art. 37, §12, EC 103/2019) — confirmar redacao vigente antes de publicar aula.', 'media'),
    (716, '682804b0-2762-4aff-87f9-d7a5a81757c2'::uuid, 1, 'Organização do Estado', 'Pede os tres Poderes da Uniao (Executivo, Legislativo, Judiciario) — art. 2o.', 'alta'),
    (717, '682804b0-2762-4aff-87f9-d7a5a81757c2'::uuid, 1, 'Administração Pública', 'Trata de readaptacao de servidor e regras previdenciarias — verificar se testa de fato a CF/88 ou se ha contaminacao com legislacao infraconstitucional (ex.: Lei 8.112/90) antes de publicar aula.', 'media'),
    (773, '682804b0-2762-4aff-87f9-d7a5a81757c2'::uuid, 1, 'Administração Pública', 'Servidor publico afastado para exercicio de mandato eletivo, tempo de servico nao contado para promocao por merecimento — art. 38, IV.', 'alta'),
    (794, '682804b0-2762-4aff-87f9-d7a5a81757c2'::uuid, 1, 'Princípios Fundamentais', 'Fundamentos do Estado Democratico de Direito, dignidade da pessoa humana — art. 1o, III.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (14/14).
-- 48,111,296,327,647,649,650,651,652,653,716,717,773,794

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Constituição Federal de 1988: 14 questoes distintas
-- Total de vinculos esperados: 14 (14 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
