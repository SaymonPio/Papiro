-- Mapa de classificacao semantica das questoes validas de Estatuto da Pessoa com Deficiência
-- (curso_conteudos.id = 75, assunto_id = 94,
-- materia_id = 11), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/estatuto_da_pessoa_com_deficiencia.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_estatuto_da_pessoa_com_deficiencia_teste_rollback.sql
--   classificar_questoes_unidades_estatuto_da_pessoa_com_deficiencia.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 75 (apos curadoria_unidades_estatuto_da_pessoa_com_deficiencia.sql):
--   U1 128d9183-6188-4ca1-abdb-fc5c57e78d28  ordem 1  Estatuto da Pessoa com Deficiência
--
-- Resultado da curadoria: 3/3 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (126, '128d9183-6188-4ca1-abdb-fc5c57e78d28'::uuid, 1, 'Definição de profissional de apoio escolar', 'Gabarito ''Profissional de apoio escolar'' — cópia literal da definição do art. 3º, XIII (''pessoa que exerce atividades de alimentação, higiene e locomoção do estudante com deficiência e atua em todas as atividades escolares nas quais se fizer necessária, em todos os níveis e modalidades de ensino, em instituições públicas e privadas, excluídas as técnicas ou os procedimentos identificados com profissões legalmente estabelecidas''). Distratores fabricam nomenclaturas inexistentes na lei (atendente pessoal, acompanhante, ajudante escolar, professor assistente).', 'alta'),
    (257, '128d9183-6188-4ca1-abdb-fc5c57e78d28'::uuid, 1, 'Plena capacidade civil da pessoa com deficiência', 'Gabarito ''Não afeta a plena capacidade civil da pessoa, inclusive para casar-se e constituir união estável'' — cópia literal do art. 6º, caput (''A deficiência não afeta a plena capacidade civil da pessoa, inclusive para:'') combinado com o inciso I (''casar-se e constituir união estável''). Distratores invertem incisos reais do mesmo artigo: ''impede exercício de direitos sexuais e reprodutivos'' (inverte o inciso II, que garante esse direito), ''proíbe a adoção'' (inverte o inciso VI, que garante o direito à adoção em igualdade de condições), ''impõe curatela obrigatória'' (fabricação — curatela não é automática, é medida excepcional).', 'alta'),
    (258, '128d9183-6188-4ca1-abdb-fc5c57e78d28'::uuid, 1, 'Curatela como medida extraordinária e seu alcance limitado', 'Gabarito ''É medida extraordinária e proporcional às necessidades e circunstâncias de cada caso'' — cópia literal do art. 84, §3º (''A definição de curatela de pessoa com deficiência constitui medida protetiva extraordinária, proporcional às necessidades e às circunstâncias de cada caso, e durará o menor tempo possível''). Distratores: ''é automática'' (falso, é medida excepcional dependente de processo judicial) e ''é sempre permanente'' (falso, contradiz a duração pelo menor tempo possível do próprio §3º) — ambos relacionados ao art. 84, §3º; ''substitui integralmente a autonomia'' (inverte o art. 85, caput, que restringe a curatela aos atos de natureza patrimonial e negocial); ''abrange obrigatoriamente direitos ao corpo e à sexualidade'' (inverte o art. 85, §1º, que exclui expressamente corpo/sexualidade/matrimônio/privacidade/educação/saúde/trabalho/voto do alcance da curatela).', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (3/3).
-- 126,257,258

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Estatuto da Pessoa com Deficiência: 3 questoes distintas
-- Total de vinculos esperados: 3 (3 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
