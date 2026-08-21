-- Mapa de classificacao semantica das questoes validas de Poder de Polícia
-- (curso_conteudos.id = 60, assunto_id = 69,
-- materia_id = 10), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/poder_de_policia.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_poder_de_policia_teste_rollback.sql
--   classificar_questoes_unidades_poder_de_policia.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 60 (apos curadoria_unidades_poder_de_policia.sql):
--   U1 2f0d3b9c-fe22-4173-a712-cfb9e1060b8c  ordem 1  Poder de Polícia
--
-- Resultado da curadoria: 4/4 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (204, '2f0d3b9c-fe22-4173-a712-cfb9e1060b8c'::uuid, 1, 'Conceito legal de poder de polícia', 'Gabarito: ''Limita ou condiciona direitos e atividades em beneficio do interesse publico'' — CTN (Lei no 5.172/1966), art. 78, caput (''atividade da administracao publica que, limitando ou disciplinando direito, interesse ou liberdade, regula a pratica de ato ou abstencao de fato, em razao de interesse publico''), correspondencia verificada em fonte oficial. Distratores sem correspondencia (criar crimes sem lei, julgar definitivamente processos judiciais, elaborar a Constituicao, atuar somente em relacoes privadas).', 'alta'),
    (205, '2f0d3b9c-fe22-4173-a712-cfb9e1060b8c'::uuid, 1, 'Atributos do poder de polícia (doutrina)', 'Gabarito: ''Discricionariedade, autoexecutoriedade e coercibilidade'' — classificacao doutrinaria tradicional dos atributos do poder de policia, sem dispositivo legal especifico atribuido. A incidencia concreta desses atributos depende da natureza e do regime juridico do ato praticado (nao estao necessariamente presentes em todo e qualquer ato de policia). Distratores sem correspondencia (vitaliciedade/inamovibilidade/irredutibilidade sao garantias de magistratura; generalidade/abstracao/novacao e tipicidade penal/culpabilidade/ilicitude sao institutos de outras areas).', 'alta'),
    (206, '2f0d3b9c-fe22-4173-a712-cfb9e1060b8c'::uuid, 1, 'Princípios e limites da atuação administrativa', 'Gabarito: ''Legalidade, proporcionalidade e interesse publico'' — subconjunto exato dos principios listados no art. 2o, caput, da Lei no 9.784/1999 (''legalidade, finalidade, motivacao, razoabilidade, proporcionalidade, moralidade, ampla defesa, contraditorio, seguranca juridica, interesse publico e eficiencia''), correspondencia verificada em fonte oficial. Sao principios/limites gerais da atuacao administrativa aplicaveis ao exercicio do poder de policia, NAO classificados como ''atributos do poder de policia'' (distincao terminologica de Q205). Distratores sem correspondencia (arbitrariedade, ausencia de motivacao em qualquer hipotese, interesse privado do agente, sigilo absoluto sao todos condutas vedadas, nao principios).', 'alta'),
    (871, '2f0d3b9c-fe22-4173-a712-cfb9e1060b8c'::uuid, 1, 'Exemplos de exercício e distinção com o poder hierárquico', 'Questao NAO-exemplo: gabarito ''Fiscalizacao de atos e comportamento dos subalternos'' e corretamente identificado como NAO exemplo de poder de policia — e exemplo de poder hierarquico/disciplinar (atuacao interna sobre subordinados), doutrina pura, sem dispositivo legal especifico atribuido. As demais alternativas (apreensao de produtos deteriorados, fechamento de estabelecimento por falta de higiene, fechamento de teatro por falta de seguranca, embargo de obra) sao exemplos classicos e corretos de poder de policia (fiscalizacao sanitaria, urbanistica e de seguranca sobre particulares).', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (4/4).
-- 204,205,206,871

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Poder de Polícia: 4 questoes distintas
-- Total de vinculos esperados: 4 (4 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
