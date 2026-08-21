-- Mapa de classificacao semantica das questoes validas de Atos administrativos
-- (curso_conteudos.id = 54, assunto_id = 67,
-- materia_id = 10), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/atos_administrativos.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_atos_administrativos_teste_rollback.sql
--   classificar_questoes_unidades_atos_administrativos.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 54 (apos curadoria_unidades_atos_administrativos.sql):
--   U1 85323ce5-772b-4bf1-bc32-a79e2316158b  ordem 1  Atos administrativos
--
-- Resultado da curadoria: 8/8 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (44, '85323ce5-772b-4bf1-bc32-a79e2316158b'::uuid, 1, 'Requisitos/elementos do ato administrativo', 'Doutrinario (Hely Lopes Meirelles): os 5 requisitos/elementos sao competencia, finalidade, forma, motivo e objeto; ''motivacao'' nao e um deles (e a exteriorizacao formal do motivo, conceito distinto). Sem dispositivo legal.', 'alta'),
    (267, '85323ce5-772b-4bf1-bc32-a79e2316158b'::uuid, 1, 'Atributos do ato administrativo', 'Doutrinario: atributo da presuncao de legitimidade (ato presumido conforme o Direito ate prova em contrario). Sem dispositivo legal.', 'alta'),
    (268, '85323ce5-772b-4bf1-bc32-a79e2316158b'::uuid, 1, 'Anulação, revogação e convalidação', 'Doutrinario/jurisprudencial: revogacao por conveniencia e oportunidade administrativas, distinta da anulacao por ilegalidade (Sumula 473 do STF). Sumula nao e dispositivo legal, nao entra em artigos_esperados.', 'alta'),
    (358, '85323ce5-772b-4bf1-bc32-a79e2316158b'::uuid, 1, 'Atributos do ato administrativo', 'Doutrinario: atributos do ato administrativo (presuncao de legitimidade — gabarito; imperatividade, exigibilidade, autoexecutoriedade e exequibilidade testados por contraste/distorcao nas demais alternativas). Sem dispositivo legal.', 'alta'),
    (646, '85323ce5-772b-4bf1-bc32-a79e2316158b'::uuid, 1, 'Validade, eficácia e efetividade', 'A questao envolve a distincao doutrinaria entre validade, eficacia e efetividade e o principio constitucional da publicidade administrativa (art. 37, caput). Quando a publicidade/divulgacao for juridicamente exigida para que determinado ato produza efeitos externos, sua ausencia pode afetar sua eficacia, sem confundir publicidade com requisito universal de validade de todo ato administrativo.', 'alta'),
    (714, '85323ce5-772b-4bf1-bc32-a79e2316158b'::uuid, 1, 'Anulação, revogação e convalidação', 'Excesso, abuso e desvio de poder sao categorias doutrinarias (sem dispositivo legal). A alternativa selecionada como INCORRETA nega que a Administracao possa anular seus proprios atos — o fundamento real (autotutela) esta no art. 53 da Lei 9.784/1999 e na Sumula 473 do STF (mencionada apenas aqui e no escopo, nao em artigos_esperados).', 'alta'),
    (840, '85323ce5-772b-4bf1-bc32-a79e2316158b'::uuid, 1, 'Anulação, revogação e convalidação', 'Convalidacao de atos com defeitos sanaveis que nao lesem interesse publico nem terceiros — art. 55 da Lei no 9.784/1999 (citacao quase literal no proprio enunciado).', 'alta'),
    (841, '85323ce5-772b-4bf1-bc32-a79e2316158b'::uuid, 1, 'Atributos do ato administrativo', 'Doutrinario: atributo da coercibilidade (autorizacao para aplicar sancoes unilateralmente por descumprimento, distinto de autoexecutoriedade). Sem dispositivo legal.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (8/8).
-- 44,267,268,358,646,714,840,841

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Atos administrativos: 8 questoes distintas
-- Total de vinculos esperados: 8 (8 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
