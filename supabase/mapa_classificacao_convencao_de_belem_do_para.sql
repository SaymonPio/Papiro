-- Mapa de classificacao semantica das questoes validas de Convenção de Belém do Pará
-- (curso_conteudos.id = 89, assunto_id = 107,
-- materia_id = 11), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/convencao_de_belem_do_para.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_convencao_de_belem_do_para_teste_rollback.sql
--   classificar_questoes_unidades_convencao_de_belem_do_para.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 89 (apos curadoria_unidades_convencao_de_belem_do_para.sql):
--   U1 a2d8b683-1a53-451e-9072-525a147fed01  ordem 1  Convenção de Belém do Pará
--
-- Resultado da curadoria: 3/3 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (153, 'a2d8b683-1a53-451e-9072-525a147fed01'::uuid, 1, 'Objeto central da Convenção', 'Fundamento normativo: Convenção de Belém do Pará, art. 7, caput (''Os Estados Partes condenam todas as formas de violência contra a mulher e convêm em adotar, por todos os meios apropriados e sem demora, políticas destinadas a prevenir, punir e erradicar tal violência''). Gabarito ''Prevenir, punir e erradicar a violência contra a mulher'' — corresponde tanto à própria finalidade nominal da Convenção quanto ao texto operativo do art. 7, caput. Não ampliado para as alíneas ''a'' a ''h'' do art. 7, pois a questão não cobra as medidas específicas ali previstas. Distratores fabricam objetos totalmente estranhos à Convenção (relações comerciais, crimes tributários, moeda comum, direitos autorais).', 'alta'),
    (154, 'a2d8b683-1a53-451e-9072-525a147fed01'::uuid, 1, 'Âmbitos em que a violência contra a mulher pode ocorrer', 'Fundamento normativo: Convenção de Belém do Pará, art. 1 (''...qualquer ato ou conduta baseada no gênero, que cause morte, dano ou sofrimento físico, sexual ou psicológico à mulher, tanto na esfera pública como na esfera privada''). Gabarito ''Nos âmbitos público e privado'' — cópia parafraseada do art. 1. Mantido no art. 1, e NÃO substituído pelo art. 2 (que apenas detalha contextos específicos — familiar/doméstico, comunitário, estatal — em que essa violência definida no art. 1 pode ocorrer, sem repetir a expressão ''esfera pública e privada''). Distratores recortam artificialmente subcasos do art. 2 (apenas residência, apenas trabalho, apenas agente estatal) ou inventam limitação temporal inexistente (apenas em guerra).', 'alta'),
    (155, 'a2d8b683-1a53-451e-9072-525a147fed01'::uuid, 1, 'Inserção institucional da Convenção no Sistema Interamericano', 'AJUSTE APROVADO PELO USUARIO: a questão pergunta apenas a que sistema a Convenção pertence (''Interamericano de proteção dos direitos humanos''), sem cobrar competência consultiva da Corte Interamericana (art. 11) nem o procedimento de petições perante a Comissão Interamericana (art. 12) — por isso NENHUM artigo foi incluído em artigos_esperados para fundamentar isoladamente esta questão. Classificação registrada como institucional/contextual: a própria denominação ''Convenção Interamericana'', a adoção no âmbito da Organização dos Estados Americanos, o Capítulo IV da Convenção (''Mecanismos Interamericanos de Proteção'') e os arts. 11 (parecer consultivo da Corte Interamericana de Direitos Humanos) e 12 (petições à Comissão Interamericana de Direitos Humanos, processadas segundo as normas da Convenção Americana sobre Direitos Humanos e do Estatuto/Regulamento da CIDH) confirmam contextualmente o vínculo com o Sistema Interamericano, mas não são dispositivos efetivamente cobrados pela questão. Distratores citam outros sistemas regionais (europeu, africano) ou órgãos incompatíveis (ONU exclusivamente, Tribunal Penal Internacional).', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (3/3).
-- 153,154,155

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Convenção de Belém do Pará: 3 questoes distintas
-- Total de vinculos esperados: 3 (3 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
