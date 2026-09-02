-- Mapa de classificacao semantica das questoes validas de Tautologia, contradição e contingência
-- (curso_conteudos.id = 8, assunto_id = 37,
-- materia_id = 18), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/tautologia_contradicao_contingencia.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_tautologia_contradicao_contingencia_teste_rollback.sql
--   classificar_questoes_unidades_tautologia_contradicao_contingencia.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 8 (apos curadoria_unidades_tautologia_contradicao_contingencia.sql):
--   U1 ae60f2db-49d0-4326-980c-df1617a0bc35  ordem 1  Tautologia, contradição e contingência
--
-- Resultado da curadoria: 3/3 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (76, 'ae60f2db-49d0-4326-980c-df1617a0bc35'::uuid, 1, 'Comparação de alegações de classificação sobre múltiplas fórmulas de 1 variável (origem=REAL)', 'ORIGEM: REAL (Fundatec, SUSEPE RS - Agente Penitenciário Administrativo, 2022). Fenômeno testado: dadas 5 alegações de classificação sobre fórmulas diferentes (P→~P, P↔~P, ~P∨P), identificar qual alegação é verdadeira. Recálculo independente das 5 fórmulas confirmado: P→~P é contingência (P=V dá F, P=F dá V); P↔~P é contradição (sempre F, pois P e ~P nunca coincidem); ~P∨P é tautologia (Princípio do Terceiro Excluído, sempre V). Apenas a alegação ''P↔~P representa uma contradição'' é verdadeira — gabarito B, confirmado. Habilidade nuclear: avaliar o comportamento em TODAS as valorações de cada fórmula candidata e classificá-la corretamente como tautologia/contradição/contingência para identificar qual alegação de classificação é logicamente verdadeira — vai além de avaliar uma única linha (Proposições e conectivos) e não pede construir/completar tabela (Tabela-verdade) nem encontrar forma equivalente (Equivalências lógicas). Categoria: G) classificação de comportamento global de proposição composta. Incidência pontual neste corpus (evento/concurso único, ver Q85) — não registrar como recorrente. Explicação armazenada NÃO alterada nesta curadoria.', 'alta'),
    (85, 'ae60f2db-49d0-4326-980c-df1617a0bc35'::uuid, 1, 'Comparação de alegações de classificação sobre fórmula composta de 2 variáveis (origem=REAL)', 'ORIGEM: REAL (Fundatec, SUSEPE RS - Agente Penitenciário, 2022 — mesmo evento/concurso de Q76: SUSEPE/Polícia Penal RS 01/2022, caderno distinto). Fenômeno testado: dadas 5 alegações de classificação envolvendo P→~Q, ~Q→P e (P→~Q)∨(~Q→P), identificar qual é verdadeira. Recálculo independente das 4 valorações de (P→~Q)∨(~Q→P) confirmado: V,V,V,V em todas as combinações de P,Q — genuína tautologia, confirmando também por prova geral (uma disjunção de condicionais cruzadas A→B∨B→A é sempre tautológica, pois quando A→B é falsa (único caso A=V,B=F), B→A vale F→V=V). Gabarito E confirmado (''(P→~Q)∨(~Q→P) representa uma tautologia''). P→~Q isolada e ~Q→P isoladas confirmadas como contingências (valores mistos), consistente com a explicação armazenada. Habilidade nuclear: mesma categoria de Q76, elevada para fórmula de 2 variáveis (8 combinações a considerar via 2 subfórmulas de 2 variáveis cada) — teste contrafactual: dominar apenas avaliação de conectivos isolados (Proposições e conectivos) ou construção de tabela de uma única expressão (Tabela-verdade) não basta; é necessário reconhecer o comportamento global da disjunção completa. Categoria: G) classificação de comportamento global de proposição composta. Incidência pontual neste corpus (mesmo evento/concurso de Q76, portanto 1 único evento independente sustentando toda a incidência REAL desta unidade) — não registrar como recorrência de dois eventos. Explicação armazenada NÃO alterada nesta curadoria.', 'alta'),
    (315, 'ae60f2db-49d0-4326-980c-df1617a0bc35'::uuid, 1, 'Classificação direta de fórmula elementar (cobertura suplementar; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca="Papiro", concurso="PAPIRO - Adaptada do padrão Fundatec 2025/2026", ano=2026) — material suplementar de prática, NÃO conta para incidência histórica, recorrência, frequência ou recência da banca — registrada como COBERTURA_SUPLEMENTAR_TAUTOLOGIA_CONTRADICAO_CONTINGENCIA. Fenômeno testado: classificar diretamente P∨~P (Princípio do Terceiro Excluído) como tautologia, contradição ou contingência — sem comparação com alegações concorrentes sobre outras fórmulas (diferente de Q76/Q85). Recálculo confirmado: P=V→V∨F=V; P=F→F∨V=V — sempre V, genuína tautologia, gabarito A confirmado. Não é duplicata de Q76 (que também usa ~P∨P como uma das 5 alegações, mas ali apenas como distrator dentro de uma questão de eliminação múltipla, nunca como pergunta direta) — aqui a tarefa é a forma mais elementar e direta de classificação, servindo como progressão pedagógica de entrada antes das questões reais mais complexas. Categoria: G) classificação de comportamento global de proposição composta. Explicação armazenada NÃO alterada nesta curadoria.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (3/3).
-- 76,85,315

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Tautologia, contradição e contingência: 3 questoes distintas
-- Total de vinculos esperados: 3 (3 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
