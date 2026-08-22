-- Mapa de classificacao semantica das questoes validas de Organização dos Estados Americanos
-- (curso_conteudos.id = 86, assunto_id = 87,
-- materia_id = 11), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/organizacao_dos_estados_americanos.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_organizacao_dos_estados_americanos_teste_rollback.sql
--   classificar_questoes_unidades_organizacao_dos_estados_americanos.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 86 (apos curadoria_unidades_organizacao_dos_estados_americanos.sql):
--   U1 7a9e1731-626a-44cc-90f0-004faed11e0f  ordem 1  Organização dos Estados Americanos
--
-- Resultado da curadoria: 3/3 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (171, '7a9e1731-626a-44cc-90f0-004faed11e0f'::uuid, 1, 'Natureza da OEA como organismo regional', 'Gabarito ''Regional americano'' — cópia literal do art. 1 da Carta da OEA (''Dentro das Nações Unidas, a Organização dos Estados Americanos constitui um organismo regional''). Distratores citam outros âmbitos (europeu, africano, asiático, global exclusivamente).', 'alta'),
    (172, '7a9e1731-626a-44cc-90f0-004faed11e0f'::uuid, 1, 'Comissão Interamericana como órgão da OEA', 'Fundamento normativo: art. 53, alínea ''e'', da Carta da OEA, que lista os órgãos por meio dos quais a Organização realiza seus fins, incluindo a Comissão Interamericana de Direitos Humanos. Gabarito ''Organização dos Estados Americanos'' — confirma o vínculo institucional. Não antecipa competências/funções específicas da Comissão (destino: futuro curso_conteudo_id 87, ainda pendente). Distratores citam organismos sem relação (União Europeia, OTAN, OMC, OCDE).', 'alta'),
    (173, '7a9e1731-626a-44cc-90f0-004faed11e0f'::uuid, 1, 'Propósitos essenciais da OEA', 'Gabarito ''Paz, segurança, democracia e cooperação entre os Estados americanos'' — síntese de três propósitos essenciais do art. 2, caput (norma introdutória da enumeração): paz e segurança continentais (art. 2, "a"); promover e consolidar a democracia representativa (art. 2, "b"); promover, por meio da ação cooperativa, o desenvolvimento econômico, social e cultural (art. 2, "f"). Não inclui as demais alíneas do art. 2 (c, d, e, g, h), não exigidas pelo corpus. Distratores fabricam propósitos absurdos (moeda única mundial, unificação de exércitos, extinção de fronteiras, controle direto de governos).', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (3/3).
-- 171,172,173

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Organização dos Estados Americanos: 3 questoes distintas
-- Total de vinculos esperados: 3 (3 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
