-- Mapa de classificacao semantica das questoes validas de Pacto Internacional sobre Direitos Econômicos, Sociais e Culturais
-- (curso_conteudos.id = 77, assunto_id = 84,
-- materia_id = 11), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/pacto_internacional_sobre_direitos_economicos_sociais_e_culturais.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_pacto_internacional_sobre_direitos_economicos_sociais_e_culturais_teste_rollback.sql
--   classificar_questoes_unidades_pacto_internacional_sobre_direitos_economicos_sociais_e_culturais.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 77 (apos curadoria_unidades_pacto_internacional_sobre_direitos_economicos_sociais_e_culturais.sql):
--   U1 f33221cc-f53c-4f91-88e4-a6d8440beca0  ordem 1  Pacto Internacional sobre Direitos Econômicos, Sociais e Culturais
--
-- Resultado da curadoria: 3/3 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (125, 'f33221cc-f53c-4f91-88e4-a6d8440beca0'::uuid, 1, 'Limites, garantias e direitos do PIDESC (multi-dispositivo, alternativa CORRETA)', 'Alt1 (CORRETA selecionada, gabarito — cópia literal): as limitações ao exercício dos direitos do Pacto sujeitam-se unicamente às estabelecidas em lei, na medida compatível com a natureza desses direitos e exclusivamente para favorecer o bem-estar geral em sociedade democrática — art. 4º. Alt2 (falsa — inverte o art. 5º, item 2, que veda restringir/suspender direitos humanos fundamentais já reconhecidos ou vigentes sob pretexto de o Pacto não os reconhecer ou reconhecê-los em menor grau) art. 5º, item 2. Alt3 (falsa — nega indevidamente que o art. 6º, item 2, preveja expressamente orientação e formação técnica e profissional entre as medidas para assegurar o direito ao trabalho do item 1 — a previsão existe) art. 6º, item 1 e item 2. Alt4 (falsa — fabrica a expressão ''independentemente de contribuição'' no direito à previdência social/seguro social, ausente do texto real) art. 9º. Alt5 (falsa — inverte o art. 15, item 1, ''c'', que exige que o indivíduo seja o autor da produção científica/literária/artística para se beneficiar da proteção dos interesses morais e materiais, ao contrário do que a alternativa afirma) art. 15, item 1, "c".', 'alta'),
    (261, 'f33221cc-f53c-4f91-88e4-a6d8440beca0'::uuid, 1, 'Direito ao trabalho', 'Gabarito ''Ao trabalho'' — cópia literal do art. 6º, item 1. Distratores são condutas vedadas pelo Pacto (escravidão, prisão arbitrária, censura política, tortura), não direitos por ele reconhecidos — questão testa qual direito é efetivamente reconhecido pelo PIDESC, sem necessidade de mapear os distratores a outros tratados.', 'alta'),
    (262, 'f33221cc-f53c-4f91-88e4-a6d8440beca0'::uuid, 1, 'Direito à educação', 'Gabarito ''O direito à educação'' — cópia literal do art. 13, item 1 (''Os Estados Partes do presente Pacto reconhecem o direito de toda pessoa à educação''). Distratores fabricam ''direitos'' inexistentes ou vedados (detenção arbitrária, tortura, proibição de associação, censura de opinião); não ampliado para os demais itens do art. 13, não testados.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (3/3).
-- 125,261,262

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Pacto Internacional sobre Direitos Econômicos, Sociais e Culturais: 3 questoes distintas
-- Total de vinculos esperados: 3 (3 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
