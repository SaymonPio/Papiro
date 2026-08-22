-- Mapa de classificacao semantica das questoes validas de Programa Nacional de Direitos Humanos - PNDH-3
-- (curso_conteudos.id = 96, assunto_id = 95,
-- materia_id = 11), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/programa_nacional_de_direitos_humanos_pndh_3.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_programa_nacional_de_direitos_humanos_pndh_3_teste_rollback.sql
--   classificar_questoes_unidades_programa_nacional_de_direitos_humanos_pndh_3.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 96 (apos curadoria_unidades_programa_nacional_de_direitos_humanos_pndh_3.sql):
--   U1 384edb2e-1b4a-4028-99f3-c6e54b154826  ordem 1  Programa Nacional de Direitos Humanos - PNDH-3
--
-- Resultado da curadoria: 4/4 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (177, '384edb2e-1b4a-4028-99f3-c6e54b154826'::uuid, 1, 'Finalidade geral do PNDH-3', 'Gabarito ''Promoção e proteção dos direitos humanos no Brasil'' — caracterização geral do PNDH-3, não reprodução literal do art. 1º; fundamento: Decreto 7.037/2009, art. 1º, caput (''Fica aprovado o Programa Nacional de Direitos Humanos - PNDH-3...'') combinado com a finalidade geral do Programa. Distratores sem correspondência (política monetária, administração tributária, defesa comercial, regulação exclusiva de partidos).', 'média-alta'),
    (178, '384edb2e-1b4a-4028-99f3-c6e54b154826'::uuid, 1, 'Instrumento normativo de instituição do PNDH-3', 'Gabarito ''Decreto federal'' — corresponde ao art. 1º, caput, do Decreto nº 7.037/2009, que aprovou o PNDH-3. Distratores sem correspondência (emenda constitucional, lei complementar estadual, resolução municipal, sentença internacional — nenhum é o instrumento real).', 'alta'),
    (179, '384edb2e-1b4a-4028-99f3-c6e54b154826'::uuid, 1, 'Estrutura organizacional do PNDH-3', 'Gabarito ''Eixos orientadores, diretrizes, objetivos estratégicos e ações programáticas'' — corresponde ao art. 1º, caput (menciona diretrizes/objetivos estratégicos/ações programáticas) combinado com art. 2º, caput (enumera os Eixos Orientadores). Microchecagem confirmada: nem o enunciado nem nenhuma alternativa nomeiam Eixo específico (I a VI) — cobre apenas a estrutura geral, sem necessidade de inciso adicional. Distratores sem correspondência (tipos penais, regras tributárias, normas militares, metas fiscais).', 'alta'),
    (625, '384edb2e-1b4a-4028-99f3-c6e54b154826'::uuid, 1, 'Eixo III / Diretriz 10 — Garantia da igualdade na diversidade', 'Fundamento normativo: art. 2º, III, "d" do Decreto 7.037/2009 (identificação formal do Eixo Orientador III e da Diretriz 10, ''Garantia da igualdade na diversidade''); o conteúdo substantivo da Diretriz 10 está no Anexo do Decreto. Gabarito (alt3) é caracterização/síntese pedagógica da Diretriz 10 (''reconhece a diversidade como dimensão constitutiva da dignidade da pessoa humana... ações afirmativas, mecanismos de participação social e revisão de práticas estatais potencialmente discriminatórias''), não citação literal. Distratores invertem/negam o conteúdo real: alt1 afirma que o Programa rejeita políticas diferenciadas (falso — promove ações afirmativas); alt2 afirma caráter meramente programático sem repercussão (falso — orienta políticas públicas efetivas); alt4 restringe a diversidade a direitos culturais, afastando segurança pública/justiça (falso); alt5 propõe flexibilizar garantias fundamentais em contextos de segurança (falso, inversão perigosa). VIGÊNCIA: o Decreto nº 7.177/2010 revogou especificamente a ação programática ''c'' do Objetivo Estratégico VI da Diretriz 10 (sobre ostentação de símbolos religiosos em estabelecimentos públicos da União) — não revogou a Diretriz 10, o Eixo III, nem a caracterização geral testada; gabarito permanece válido.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (4/4).
-- 177,178,179,625

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Programa Nacional de Direitos Humanos - PNDH-3: 4 questoes distintas
-- Total de vinculos esperados: 4 (4 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
