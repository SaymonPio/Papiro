-- Mapa de classificacao semantica das questoes validas de Comissão Interamericana de Direitos Humanos
-- (curso_conteudos.id = 87, assunto_id = 92,
-- materia_id = 11), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/comissao_interamericana_de_direitos_humanos.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_comissao_interamericana_de_direitos_humanos_teste_rollback.sql
--   classificar_questoes_unidades_comissao_interamericana_de_direitos_humanos.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 87 (apos curadoria_unidades_comissao_interamericana_de_direitos_humanos.sql):
--   U1 1b84fd2f-93e4-46c1-868f-c8402e73bdf9  ordem 1  Comissão Interamericana de Direitos Humanos
--
-- Resultado da curadoria: 3/3 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (150, '1b84fd2f-93e4-46c1-868f-c8402e73bdf9'::uuid, 1, 'Posição da Comissão no sistema interamericano', 'Fundamento normativo: CADH, art. 33, que identifica expressamente a Comissão Interamericana de Direitos Humanos e a Corte Interamericana de Direitos Humanos como os órgãos competentes para conhecer dos assuntos relacionados ao cumprimento dos compromissos assumidos pelos Estados Partes na Convenção. Gabarito ''Interamericano de proteção dos direitos humanos'' — correto. Distratores citam outros sistemas regionais (europeu, africano, União Europeia, Mercosul).', 'alta'),
    (151, '1b84fd2f-93e4-46c1-868f-c8402e73bdf9'::uuid, 1, 'Função da Comissão quanto a petições', 'Fundamento normativo: CADH, art. 41, alínea ''f'' (''atuar com respeito às petições e outras comunicações, no exercício de sua autoridade, de conformidade com o disposto nos artigos 44 a 51 desta Convenção''), combinado com o art. 44 (legitimidade para apresentar petição: qualquer pessoa, grupo de pessoas, ou entidade não governamental legalmente reconhecida, contendo denúncias ou queixas de violação da Convenção por Estado Parte). Gabarito ''Receber e analisar petições sobre alegadas violações de direitos humanos'' — correto, combinação dos dois dispositivos. Art. 48 (processamento posterior da petição) não incluído, pois a questão não cobra procedimento/admissibilidade/investigação. Distratores fabricam competências inexistentes da Comissão (condenar criminalmente indivíduos, editar Constituições, substituir tribunais nacionais, criar impostos internacionais) — nenhuma se confunde com competências da Corte.', 'alta'),
    (152, '1b84fd2f-93e4-46c1-868f-c8402e73bdf9'::uuid, 1, 'Função principal da Comissão', 'Fundamento normativo PRINCIPAL: CADH, art. 41, caput (''A Comissão tem a função principal de promover a observância e a defesa dos direitos humanos e, no exercício do seu mandato, tem as seguintes funções e atribuições:...''). Gabarito ''A observância e a defesa dos direitos humanos nas Américas'' — cópia parafraseada do caput. FONTE COMPLEMENTAR (não inclusa em artigos_esperados): Estatuto da CIDH, art. 1, de redação muito semelhante (''A Comissão Interamericana de Direitos Humanos é um órgão da Organização dos Estados Americanos criado para promover a observância e a defesa dos direitos humanos e para servir como órgão consultivo da Organização nesta matéria''); mantido apenas o art. 41 caput da CADH como referência estruturada, para não introduzir diploma adicional desnecessariamente. Distratores fabricam funções absurdas (unificação de polícias, criação de moedas regionais, controle de fronteiras, política monetária da OEA).', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (3/3).
-- 150,151,152

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Comissão Interamericana de Direitos Humanos: 3 questoes distintas
-- Total de vinculos esperados: 3 (3 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
