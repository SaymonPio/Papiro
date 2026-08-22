-- Mapa de classificacao semantica das questoes validas de Corte Interamericana de Direitos Humanos
-- (curso_conteudos.id = 88, assunto_id = 106,
-- materia_id = 11), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/corte_interamericana_de_direitos_humanos.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_corte_interamericana_de_direitos_humanos_teste_rollback.sql
--   classificar_questoes_unidades_corte_interamericana_de_direitos_humanos.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 88 (apos curadoria_unidades_corte_interamericana_de_direitos_humanos.sql):
--   U1 9ab2c28c-2c1d-4d15-b134-a191ff946529  ordem 1  Corte Interamericana de Direitos Humanos
--
-- Resultado da curadoria: 4/4 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (156, '9ab2c28c-2c1d-4d15-b134-a191ff946529'::uuid, 1, 'Natureza jurídica da Corte IDH', 'Fonte: Estatuto da Corte Interamericana de Direitos Humanos, art. 1 (''A Corte Interamericana de Direitos Humanos é uma instituição judiciária autônoma cujo objetivo é a aplicação e a interpretação da Convenção Americana sobre Direitos Humanos''). Gabarito ''Um tribunal internacional do sistema interamericano'' é caracterização doutrinária alinhada a esse dispositivo, não cópia literal. NÃO inserido em artigos_esperados: o art. 1 do Estatuto colidiria, para fins de parser, com o art. 1 da própria CADH (Obrigação de Respeitar os Direitos), conteúdo totalmente diferente. Distratores sem correspondência (órgão do Judiciário brasileiro, comissão do Congresso, tribunal da UE, órgão do Mercosul).', 'média'),
    (157, '9ab2c28c-2c1d-4d15-b134-a191ff946529'::uuid, 1, 'Cumprimento das decisões da Corte IDH', 'Gabarito ''Obrigatórias para o Estado condenado'' — corresponde ao art. 68, item 1, da CADH: ''Os Estados Partes na Convenção comprometem-se a cumprir a decisão da Corte em todo caso em que forem partes.'' A redação da alternativa é uma simplificação pedagógica da regra técnica (Estado Parte compromete-se a cumprir a decisão em caso que seja parte); em contexto de processo contencioso, o Estado responsabilizado deve cumprir a decisão. Distratores sem correspondência (meras sugestões sem efeito, aplicável só a particulares, dependente de aprovação do Congresso em cada caso, nula se houver lei interna diferente).', 'alta'),
    (158, '9ab2c28c-2c1d-4d15-b134-a191ff946529'::uuid, 1, 'Sede da Corte IDH', 'Fonte: Estatuto da Corte Interamericana de Direitos Humanos, art. 3, item 1 (''A Corte tem sede em San José, Costa Rica''). A CADH, art. 58, remete apenas à decisão da Assembleia Geral da OEA, sem nomear a cidade diretamente — o fundamento literal e preciso está no Estatuto. NÃO inserido em artigos_esperados pela mesma razão de ambiguidade de numeração com o art. 3 da CADH (Direito ao Reconhecimento da Personalidade Jurídica), conteúdo totalmente diferente. Gabarito ''San José, Costa Rica'' confere; distratores citam sedes de outros organismos internacionais (Washington/OEA, Nova York/ONU, Genebra/diversos órgãos ONU, Montevidéu/Mercosul).', 'alta'),
    (826, '9ab2c28c-2c1d-4d15-b134-a191ff946529'::uuid, 1, 'Composição da Corte IDH', 'Gabarito ''Sete'' — cópia literal do art. 52, item 1, da CADH: ''A Corte compor-se-á de sete juízes, nacionais dos Estados membros da Organização, eleitos a título pessoal dentre juristas da mais alta autoridade moral, de reconhecida competência em matéria de direitos humanos...''', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (4/4).
-- 156,157,158,826

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Corte Interamericana de Direitos Humanos: 4 questoes distintas
-- Total de vinculos esperados: 4 (4 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
