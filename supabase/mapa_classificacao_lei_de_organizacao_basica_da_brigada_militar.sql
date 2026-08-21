-- Mapa de classificacao semantica das questoes validas de Lei de Organização Básica da Brigada Militar
-- (curso_conteudos.id = 63, assunto_id = 72,
-- materia_id = 10), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/lei_de_organizacao_basica_da_brigada_militar.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_lei_de_organizacao_basica_da_brigada_militar_teste_rollback.sql
--   classificar_questoes_unidades_lei_de_organizacao_basica_da_brigada_militar.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 63 (apos curadoria_unidades_lei_de_organizacao_basica_da_brigada_militar.sql):
--   U1 3c033d9a-5543-422a-a935-c55095bdfc86  ordem 1  Lei de Organização Básica da Brigada Militar
--
-- Resultado da curadoria: 3/3 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (43, '3c033d9a-5543-422a-a935-c55095bdfc86'::uuid, 1, 'Competência do Chefe do Estado-Maior (sucessão normativa)', 'Gabarito: ''Assessorar o Comandante-Geral'' — o enunciado da questao cita nominalmente a Lei no 10.991/1997 (Organizacao Basica da Brigada Militar), REVOGADA pelo art. 47 da Lei Complementar no 16.450/2025 (vigente desde 26/12/2025). A competencia testada foi preservada com redacao praticamente identica no art. 10 da lei sucessora: ''Compete ao Chefe do Estado-Maior assessorar o Comandante-Geral nos assuntos de ordem estrategica da Instituicao e coordenar, em carater geral, as atividades dos Orgaos do Nivel de Direcao Setorial''. Gabarito materialmente valido sob a norma vigente; referencia normativa do enunciado (Lei 10.991/1997) sinalizada para saneamento textual futuro, fora desta curadoria — questao e gabarito NAO alterados. Distratores sem correspondencia com a competencia do Chefe do Estado-Maior (apuracao de responsabilidade, regulamento de estagio probatorio, requisicao de certidoes a autoridades, cumprir atividades atribuidas pelo Comandante-Geral).', 'alta'),
    (271, '3c033d9a-5543-422a-a935-c55095bdfc86'::uuid, 1, 'Objeto geral da lei orgânica (genérico)', 'Gabarito: ''A estrutura, organizacao e funcionamento institucional da Brigada Militar'' — compativel com a ementa da Lei Complementar no 16.450/2025 (''Dispoe sobre a Organizacao, a Estrutura Basica e o efetivo da Brigada Militar''), norma hoje vigente. Afirmacao generica, sem dispositivo numerado especifico testado — nao se insere art. 1o/2o em artigos_esperados apenas por contexto. Distratores sem correspondencia (organizacao do Poder Judiciario, eleicoes estaduais, arrecadacao tributaria, contratos privados de seguranca).', 'alta'),
    (272, '3c033d9a-5543-422a-a935-c55095bdfc86'::uuid, 1, 'Competências conforme legislação estadual aplicável (genérico)', 'Gabarito: ''As competencias e atribuicoes definidas pela legislacao estadual aplicavel'' — afirmacao generica e tautologica, compativel com qualquer versao da lei organica (antiga ou vigente), sem dispositivo numerado especifico testado. Distratores sem correspondencia (somente normas municipais, vontade individual de cada unidade, legislacao trabalhista privada exclusivamente, regras eleitorais).', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (3/3).
-- 43,271,272

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Lei de Organização Básica da Brigada Militar: 3 questoes distintas
-- Total de vinculos esperados: 3 (3 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
