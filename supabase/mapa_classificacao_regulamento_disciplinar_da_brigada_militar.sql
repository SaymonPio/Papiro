-- Mapa de classificacao semantica das questoes validas de Regulamento Disciplinar da Brigada Militar
-- (curso_conteudos.id = 64, assunto_id = 73,
-- materia_id = 10), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/regulamento_disciplinar_da_brigada_militar.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_regulamento_disciplinar_da_brigada_militar_teste_rollback.sql
--   classificar_questoes_unidades_regulamento_disciplinar_da_brigada_militar.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 64 (apos curadoria_unidades_regulamento_disciplinar_da_brigada_militar.sql):
--   U1 454f8501-7818-4dc4-b22a-337247678c58  ordem 1  Regulamento Disciplinar da Brigada Militar
--
-- Resultado da curadoria: 6/6 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (210, '454f8501-7818-4dc4-b22a-337247678c58'::uuid, 1, 'Finalidade do regulamento', 'Finalidade: disciplinar deveres, transgressoes e sancoes no ambito militar estadual — art. 1o, caput.', 'alta'),
    (211, '454f8501-7818-4dc4-b22a-337247678c58'::uuid, 1, 'Devido processo disciplinar', 'Aplicacao de sancoes deve observar principios e procedimentos do ordenamento aplicavel; o distrator ''ausencia total de defesa'' contrasta com a garantia de ampla defesa e contraditorio — art. 28, caput. Vinculo inferencial, confianca media.', 'media'),
    (212, '454f8501-7818-4dc4-b22a-337247678c58'::uuid, 1, 'Hierarquia e disciplina', 'Hierarquia e disciplina sao a base institucional da Brigada Militar — art. 3o. As demais alternativas sao distratores genericos (regras eleitorais, normas tributarias etc.), sem correspondencia com o art. 4o.', 'alta'),
    (368, '454f8501-7818-4dc4-b22a-337247678c58'::uuid, 1, 'Âmbito de aplicação e deveres/valores militares', 'Gabarito (INCORRETA selecionada): militares inativos NAO sao alcancados ''em qualquer hipotese'', a aplicacao e restrita a hipoteses especificas — art. 2o, §1o. Alternativa 2 (camaradagem) art. 1o, §1o. Alternativa 3 (superior incentiva harmonia/amizade) art. 1o, §2o. Alternativas 4 e 5 (civilidade/cortesia/urbanidade/justica, inclusive reciprocidade do subordinado) art. 1o, §3o. Nenhuma alternativa menciona Forcas Armadas ou outras Corporacoes, entao art. 1o §4o nao foi incluido.', 'alta'),
    (369, '454f8501-7818-4dc4-b22a-337247678c58'::uuid, 1, 'Sanções disciplinares', 'Alternativas 1 e 2 testam as definicoes de repreensao (art. 11) e advertencia (art. 10), com caracteristicas aparentemente trocadas entre as duas. Alternativa 3 testa a definicao de detencao (art. 12, caput). Alternativa 4 (gabarito) e a prisao administrativa (art. 13). Alternativa 5 testa licenciamento e exclusao a bem da disciplina (art. 9o, V e VI), com a afirmacao incorreta de que seriam ''a pedido''.', 'alta'),
    (370, '454f8501-7818-4dc4-b22a-337247678c58'::uuid, 1, 'Processo administrativo disciplinar', 'Gabarito (INCORRETA selecionada): comunicacao de fato contrario a disciplina exige confirmacao por escrito quando verbal, nao ''independentemente de confirmacao escrita'' — art. 26. Alternativa 4 (principios do processo: instrumentalidade, simplicidade, informalidade, economia procedimental, celeridade) art. 28, paragrafo unico. Alternativa 5 (autoridades competentes para instauracao/procedimento/julgamento) art. 29, caput. Alternativas 1 e 2 (competencia disciplinar inerente ao cargo; conflito entre autoridades de hierarquias diferentes) permanecem sem artigo atribuido por falta de confirmacao segura.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (6/6).
-- 210,211,212,368,369,370

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Regulamento Disciplinar da Brigada Militar: 6 questoes distintas
-- Total de vinculos esperados: 6 (6 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
