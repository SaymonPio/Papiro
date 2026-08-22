-- Mapa de classificacao semantica das questoes validas de Direito à cidadania na Constituição Federal
-- (curso_conteudos.id = 95, assunto_id = 100,
-- materia_id = 11), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/direito_a_cidadania_na_constituicao_federal.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_direito_a_cidadania_na_constituicao_federal_teste_rollback.sql
--   classificar_questoes_unidades_direito_a_cidadania_na_constituicao_federal.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 95 (apos curadoria_unidades_direito_a_cidadania_na_constituicao_federal.sql):
--   U1 c80fe9be-da9c-4e28-b2a1-27a04be17bf7  ordem 1  Direito à cidadania na Constituição Federal
--
-- Resultado da curadoria: 5/5 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (159, 'c80fe9be-da9c-4e28-b2a1-27a04be17bf7'::uuid, 1, 'Cidadania como fundamento da República', 'Gabarito ''Um fundamento da República Federativa do Brasil'' — cópia literal do art. 1º, II (''a cidadania'' entre os fundamentos elencados no art. 1º). Distratores sem correspondência (objetivo apenas econômico, competência municipal exclusiva, direito restrito a servidores, norma sem status constitucional).', 'alta'),
    (160, 'c80fe9be-da9c-4e28-b2a1-27a04be17bf7'::uuid, 1, 'Soberania popular e instrumentos de exercício direto', 'Gabarito ''Plebiscito, referendo e iniciativa popular'' — corresponde ao art. 14, caput (''a soberania popular será exercida pelo sufrágio universal e pelo voto direto e secreto... mediante:'') combinado com os incisos I (plebiscito), II (referendo) e III (iniciativa popular). Distratores confundem com remédios constitucionais (mandado de injunção, habeas corpus, ação popular) ou atos administrativos sem relação com soberania popular.', 'alta'),
    (161, 'c80fe9be-da9c-4e28-b2a1-27a04be17bf7'::uuid, 1, 'Direito de votar como direito político', 'Questão de natureza conceitual: pede o direito político diretamente relacionado ao exercício da cidadania. Gabarito ''O direito de votar, observados os requisitos constitucionais'' tem fundamento direto e seguro no art. 14, caput (sufrágio universal, voto direto e secreto), embora a questão não cobre reprodução literal exclusiva do dispositivo. Distratores são fabricações sem qualquer correspondência normativa (não cumprir decisões judiciais, dispensa automática de tributos, livre nomeação para qualquer cargo público, imunidade penal absoluta).', 'média'),
    (694, 'c80fe9be-da9c-4e28-b2a1-27a04be17bf7'::uuid, 1, 'Idade mínima de elegibilidade — Prefeito', 'Caso concreto (candidatura a Prefeito com 18 anos). Gabarito ''21 anos'' — corresponde ao art. 14, §3º, VI, "c" (''vinte e um anos para Deputado Federal, Deputado Estadual ou Distrital, Prefeito, Vice-Prefeito e juiz de paz''). Idade mínima constitucional inalterada pela Lei nº 15.230/2025, que só modificou o momento de aferição na Lei nº 9.504/1997, tema não coberto por esta questão.', 'alta'),
    (789, 'c80fe9be-da9c-4e28-b2a1-27a04be17bf7'::uuid, 1, 'Alistamento eleitoral e voto obrigatório', 'Gabarito ''Maiores de dezoito anos'' — corresponde ao art. 14, §1º, I (''o alistamento eleitoral e o voto são: I - obrigatórios para os maiores de dezoito anos''). Distratores são exatamente as categorias de voto facultativo previstas no §1º, II (analfabetos; maiores de setenta anos; maiores de dezesseis e menores de dezoito anos), mais ''estrangeiros'' (fabricado, sem relação com o dispositivo).', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (5/5).
-- 159,160,161,694,789

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Direito à cidadania na Constituição Federal: 5 questoes distintas
-- Total de vinculos esperados: 5 (5 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
