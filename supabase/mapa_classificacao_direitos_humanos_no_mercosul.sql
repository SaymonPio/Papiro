-- Mapa de classificacao semantica das questoes validas de Direitos Humanos no Mercosul
-- (curso_conteudos.id = 91, assunto_id = 91,
-- materia_id = 11), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/direitos_humanos_no_mercosul.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_direitos_humanos_no_mercosul_teste_rollback.sql
--   classificar_questoes_unidades_direitos_humanos_no_mercosul.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 91 (apos curadoria_unidades_direitos_humanos_no_mercosul.sql):
--   U1 fec87f6c-c735-46f1-8bd1-7bbaf6f56e93  ordem 1  Direitos Humanos no Mercosul
--
-- Resultado da curadoria: 3/3 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (162, 'fec87f6c-c735-46f1-8bd1-7bbaf6f56e93'::uuid, 1, 'Direitos humanos como elemento do processo de integração', 'Fundamento normativo: Protocolo de Assunção sobre Compromisso com a Promoção e Proteção dos Direitos Humanos do MERCOSUL (2005, CMC/DEC nº 17/05), art. 1, que estabelece que a plena vigência das instituições democráticas e o respeito aos direitos humanos e às liberdades fundamentais são condições essenciais para a vigência e evolução do processo de integração entre as Partes. Gabarito ''É reconhecida como elemento relevante do processo de integração regional'' — corresponde diretamente à ideia de ''condição essencial para a vigência e evolução do processo de integração'' do art. 1. Distratores fabricam posições opostas ou absurdas (totalmente estranha aos objetivos do bloco, substitui sistemas nacionais de justiça, matéria exclusiva da ONU, expressamente proibida pelos Estados-membros). A Decisão CMC/DEC nº 40/04 (criação da RAADH) permanece documentada em escopo/_nota apenas como institucionalidade complementar, não como fundamento principal.', 'alta'),
    (163, 'fec87f6c-c735-46f1-8bd1-7bbaf6f56e93'::uuid, 1, 'Finalidade do compromisso democrático e com os direitos humanos', 'Fundamento normativo: Protocolo de Assunção sobre Compromisso com a Promoção e Proteção dos Direitos Humanos do MERCOSUL, art. 1 — combina expressamente democracia, direitos humanos e liberdades fundamentais como condições essenciais para a vigência e evolução do processo de integração. Gabarito ''Fortalecer valores essenciais à integração entre os Estados'' — corresponde à essência do art. 1, mais aderente que o Protocolo de Ushuaia isoladamente (cujo núcleo é apenas o compromisso democrático). O Protocolo de Ushuaia (1998) permanece documentado apenas como contexto histórico do compromisso democrático do bloco. Distratores fabricam objetivos absurdos ou incompatíveis com a natureza do Mercosul (eliminar Constituições nacionais, criar código penal único, substituir a OEA, extinguir o Poder Judiciário dos países). Não duplicar o art. 1 em artigos_esperados — já incluído uma única vez via Q162.', 'alta'),
    (164, 'fec87f6c-c735-46f1-8bd1-7bbaf6f56e93'::uuid, 1, 'Complementaridade da proteção regional de direitos humanos', 'Não foi localizado dispositivo único do Protocolo de Assunção (ou de qualquer outro instrumento do Mercosul) com a redação exata do gabarito. Fundamento institucional/doutrinário: a atuação do Mercosul em direitos humanos (RAADH — Decisão CMC/DEC nº 40/04; IPPDH — Decisão CMC nº 14/09) deve ser compreendida como complementar — e não substitutiva — às obrigações internacionais e constitucionais já assumidas pelos Estados Partes (mesmo princípio da complementaridade já tratado no conteúdo 82, aqui aplicado ao contexto Mercosul). Gabarito ''Complementar às obrigações internacionais e constitucionais dos Estados'' — correto sob essa lógica doutrinária/institucional. NÃO inventar artigo isolado para esta ideia. Distratores fabricam posições absurdas (substitutiva de todos os tratados universais, incompatível com o Sistema Interamericano, restrita a relações comerciais, aplicável apenas a empresas).', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (3/3).
-- 162,163,164

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Direitos Humanos no Mercosul: 3 questoes distintas
-- Total de vinculos esperados: 3 (3 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
