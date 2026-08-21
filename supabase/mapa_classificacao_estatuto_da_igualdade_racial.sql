-- Mapa de classificacao semantica das questoes validas de Estatuto da Igualdade Racial
-- (curso_conteudos.id = 97, assunto_id = 98,
-- materia_id = 11), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/estatuto_da_igualdade_racial.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_estatuto_da_igualdade_racial_teste_rollback.sql
--   classificar_questoes_unidades_estatuto_da_igualdade_racial.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 97 (apos curadoria_unidades_estatuto_da_igualdade_racial.sql):
--   U1 9cc42871-c31c-440a-88cb-32f0d4f232ff  ordem 1  Estatuto da Igualdade Racial
--
-- Resultado da curadoria: 9/9 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (131, '9cc42871-c31c-440a-88cb-32f0d4f232ff'::uuid, 1, 'Diretriz político-jurídica do Estatuto', 'Assertiva I (falsa — real e ''vitimas de desigualdade ETNICO-RACIAL'', a assertiva diz ''desigualdade social'') art. 3o, caput. Assertiva II (verdadeira, copia literal ''a valorizacao da igualdade etnica'') art. 3o, caput. Assertiva III (verdadeira, copia literal ''o fortalecimento da identidade nacional brasileira'') art. 3o, caput. Gabarito ''Apenas II e III'' confere. DUPLICATA EXATA de Q816 (mesmo enunciado, alternativas e gabarito) — mantida classificada, saneamento de duplicidade fica para etapa propria.', 'alta'),
    (255, '9cc42871-c31c-440a-88cb-32f0d4f232ff'::uuid, 1, 'Definição de discriminação racial', 'Gabarito: ''Distincao, exclusao, restricao ou preferencia baseada em raca, cor, descendencia ou origem nacional ou etnica que prejudique direitos'' — parafrase do art. 1o, paragrafo unico, I. SOBREPOSICAO: mesmo inciso ja testado em bloco pela Q350 do curso_conteudo_id 67 (que testou I, II, V e VI juntos) — mantida classificada aqui, conteudo 67 nao alterado. Distratores sem correspondencia (agressao fisica motivada por raca, tratamento desigual em concurso publico, conduta exclusiva de agente estatal, crime do Codigo Penal).', 'alta'),
    (256, '9cc42871-c31c-440a-88cb-32f0d4f232ff'::uuid, 1, 'Objeto da lei', 'Gabarito: ''Igualdade de oportunidades e defesa de direitos individuais, coletivos e difusos'' — art. 1o, caput. SOBREPOSICAO: tematicamente proxima de Q302 do curso_conteudo_id 67 (mesmo dispositivo, redacao de questao diferente) — mantida classificada aqui, conteudo 67 nao alterado. Distratores sem correspondencia (regime juridico penal especial, privilegio absoluto, isencao tributaria geral, acesso exclusivo a cargos publicos).', 'alta'),
    (695, '9cc42871-c31c-440a-88cb-32f0d4f232ff'::uuid, 1, 'Liberdade religiosa de matriz africana, quilombos e financiamento habitacional', 'Item1 (verdadeiro, copia literal sobre fundacao/manutencao de instituicoes beneficentes por iniciativa privada) art. 24, III. Item2 (verdadeiro, copia literal sobre politicas publicas para remanescentes de quilombos) art. 32, caput. Item3 (verdadeiro, copia literal sobre agentes financeiros e financiamentos habitacionais) art. 37, caput. Gabarito ''V-V-V'' confere.', 'alta'),
    (790, '9cc42871-c31c-440a-88cb-32f0d4f232ff'::uuid, 1, 'Segurança pública e acesso à Justiça', 'Alt1 (INCORRETA selecionada, gabarito — real e ''coibir'' a violencia policial, a alternativa diz ''implementar'') art. 53, caput. Alt2 (verdadeira, parcial) ''o Estado implementara acoes de protecao da juventude negra exposta a experiencias de exclusao social'' art. 53, paragrafo unico. Alt3 (verdadeira, parcial) ''acesso a Defensoria Publica'' art. 52, caput. Alt4 (verdadeira, parcial) ''acoes de ressocializacao da juventude negra em conflito com a lei'' art. 53, paragrafo unico. Alt5 (verdadeira, parcial) ''acesso ao Ministerio Publico'' art. 52, caput. SOBREPOSICAO: arts. 52 e 53 ja testados por Q54 do curso_conteudo_id 67, aqui com alternativas reformuladas — mantida classificada, conteudo 67 nao alterado.', 'alta'),
    (813, '9cc42871-c31c-440a-88cb-32f0d4f232ff'::uuid, 1, 'Ação afirmativa, saúde e educação/cultura/esporte/lazer', 'Alt1 (falsa — real e ''nas esferas publica e privada'', a alternativa diz ''somente na esfera privada'') art. 4o, paragrafo unico. Alt2 (verdadeira, gabarito, copia literal sobre direito a saude da populacao negra) art. 6o, caput. Alt3 (falsa, invertida — real ''o poder publico garantira'', a alternativa nega) art. 6o, §2o. Alt4 (falsa, invertida — real ''a populacao negra TEM direito a participar'', a alternativa nega) art. 9o, caput. Alt5 (falsa, invertida — real ''e OBRIGATORIO o estudo da historia geral da Africa'', a alternativa diz ''facultativo'') art. 11, caput.', 'alta'),
    (814, '9cc42871-c31c-440a-88cb-32f0d4f232ff'::uuid, 1, 'Saúde e educação', 'Item1 (verdadeiro, copia literal ''producao de conhecimento cientifico e tecnologico em saude da populacao negra'' como diretriz da Politica Nacional de Saude Integral da Populacao Negra) art. 7o, II. Item2 (falso, invertido — real: art. 10, II lista ''apoio a iniciativa de entidades...'' como providencia a ser adotada pelos governos, a assertiva diz que deve ser ''vedado'') art. 10, II. Item3 (verdadeiro, copia literal sobre incentivo a instituicoes de ensino superior a incorporar temas de pluralidade etnica e cultural nas matrizes curriculares de formacao de professores) art. 13, II. Gabarito ''V-F-V'' confere.', 'alta'),
    (815, '9cc42871-c31c-440a-88cb-32f0d4f232ff'::uuid, 1, 'Liberdade de consciência/crença e cultos de matriz africana', 'DUPLICATA EXATA da Q135, ja classificada e ativa no curso_conteudo_id 67 (Estatuto Nacional da Igualdade Racial, materia Legislacao Especifica) — mesmo enunciado, mesmas 5 alternativas, mesmo gabarito. Alt1 (verdadeira) art. 23, caput. Alt2 (verdadeira) art. 24, VII. Alt3 (verdadeira) art. 26, II. Alt4 (verdadeira) art. 24, II. Alt5 (INCORRETA selecionada, gabarito — real e ''inclusive'' presos com pena privativa de liberdade, nao ''exceto'') art. 25, caput. Mantida classificada neste conteudo (97); o conteudo 67 NAO foi reaberto ou alterado. Saneamento de duplicidade cruzada fica para etapa propria.', 'alta'),
    (816, '9cc42871-c31c-440a-88cb-32f0d4f232ff'::uuid, 1, 'Diretriz político-jurídica do Estatuto', 'Identica a Q131 (mesmo enunciado, alternativas e gabarito) — DUPLICATA EXATA. Assertiva I (falsa — real ''desigualdade etnico-racial'', a assertiva diz ''desigualdade social'') art. 3o, caput. Assertiva II (verdadeira) art. 3o, caput. Assertiva III (verdadeira) art. 3o, caput. Gabarito ''Apenas II e III'' confere. Mantida classificada, saneamento de duplicidade fica para etapa propria.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (9/9).
-- 131,255,256,695,790,813,814,815,816

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Estatuto da Igualdade Racial: 9 questoes distintas
-- Total de vinculos esperados: 9 (9 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
