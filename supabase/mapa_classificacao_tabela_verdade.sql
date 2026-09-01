-- Mapa de classificacao semantica das questoes validas de Tabela-verdade
-- (curso_conteudos.id = 2, assunto_id = 38,
-- materia_id = 18), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/tabela_verdade.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_tabela_verdade_teste_rollback.sql
--   classificar_questoes_unidades_tabela_verdade.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 2 (apos curadoria_unidades_tabela_verdade.sql):
--   U1 c2c7fffa-910f-4342-9e43-f7dad85ce8ab  ordem 1  Tabela-verdade
--
-- Resultado da curadoria: 2/2 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (75, 'c2c7fffa-910f-4342-9e43-f7dad85ce8ab'::uuid, 1, 'Construção de coluna de tabela-verdade para expressão composta com 2 proposições simples (origem=REAL)', 'ORIGEM: REAL (Fundatec, SUSEPE RS - Agente Penitenciário Administrativo, 2022). Fenômeno testado: dada a proposição ~(A → ~B) e as 4 linhas de valoração A/B na ordem V/V, V/F, F/V, F/F, determinar a coluna final da tabela-verdade. Recálculo independente confirmado linha a linha: linha 1 (A=V,B=V): ~B=F, A→~B=V→F=F, ~(F)=V; linha 2 (A=V,B=F): ~B=V, A→~B=V→V=V, ~(V)=F; linha 3 (A=F,B=V): ~B=F, A→~B=F→F=V, ~(V)=F; linha 4 (A=F,B=F): ~B=V, A→~B=F→V=V, ~(V)=F. Sequência V-F-F-F, gabarito C, confirmado também por via alternativa (equivalência ~(P→Q)≡P∧~Q, logo ~(A→~B)≡A∧B, que só é V na linha 1). A questão já fornece a expressão e a ordem explícita das 4 valorações no próprio enunciado — não depende de nenhuma imagem externa (AUTOSSUFICIENTE_CONFIRMADA). Habilidade nuclear: construir/determinar a coluna de uma tabela-verdade completa para uma expressão composta a partir da enumeração de todas as 2^2=4 combinações de 2 proposições simples — teste contrafactual: dominar apenas a condição de verdade isolada da condicional ou da negação (conteúdo de Proposições e conectivos) não basta; é necessário aplicar o procedimento de montagem/avaliação linha a linha da tabela completa. Categoria: C) procedimento de construção de tabela-verdade. Incidência pontual neste corpus (evento/concurso único, ver Q89) — não registrar como recorrente. Explicação armazenada NÃO alterada nesta curadoria.', 'alta'),
    (89, 'c2c7fffa-910f-4342-9e43-f7dad85ce8ab'::uuid, 1, 'Complementação de tabela-verdade parcialmente preenchida para expressão composta com 3 proposições simples (origem=REAL; SANEADA por fidelidade estrutural no commit 1eb3fa9)', 'ORIGEM: REAL (Fundatec, SUSEPE RS - Agente Penitenciário, 2022 — mesmo evento/concurso de Q75: SUSEPE/Polícia Penal RS 01/2022, caderno distinto). Fenômeno testado: dada a proposição composta (p ∨ q) → (r ∧ ~q) e uma tabela-verdade de 8 linhas (2^3, para p/q/r) já parcialmente preenchida (linhas 1,3,5,7 dadas; lacunas nas linhas 2,4,6,8, todas com r=F), determinar os quatro valores lógicos faltantes na ordem de cima para baixo. Recálculo independente confirmado: linha 2 (p=V,q=V,r=F): p∨q=V, ~q=F, r∧~q=F, V→F=F; linha 4 (p=V,q=F,r=F): p∨q=V, ~q=V, r∧~q=F, V→F=F; linha 6 (p=F,q=V,r=F): p∨q=V, ~q=F, r∧~q=F, V→F=F; linha 8 (p=F,q=F,r=F): p∨q=F, ~q=V, r∧~q=F, F→F=V (antecedente falso torna a condicional automaticamente verdadeira). Sequência F-F-F-V, gabarito D. Enunciado e explicação foram RESTAURADOS por saneamento dedicado de fidelidade estrutural (commit 1eb3fa9, fonte primária revalidada: Fundatec, SUSEPE/Polícia Penal RS 01/2022, caderno Agente Penitenciário, Questão 75) — o gabarito D já estava correto antes do saneamento; apenas o enunciado (que não expunha a tabela completa com fidelidade) e a explicação (que continha raciocínio internamente inconsistente sobre quais linhas faltavam) foram corrigidos. Esta curadoria NÃO propõe nenhuma alteração adicional ao conteúdo, apenas classifica o estado já saneado. Habilidade nuclear: completar uma tabela-verdade de 2^3=8 linhas para uma expressão composta com 3 proposições simples e 3 conectivos distintos (disjunção, conjunção, condicional) mais negação — teste contrafactual: dominar isoladamente as condições de verdade de cada conectivo (conteúdo de Proposições e conectivos) não basta; é necessário localizar corretamente as linhas fornecidas versus as lacunas dentro da estrutura tabular de 8 linhas e aplicar o procedimento completo a cada lacuna. Categoria: C) procedimento de construção/complementação de tabela-verdade, nível de maior complexidade que Q75 (3 proposições simples e preenchimento parcial, vs. 2 proposições simples e tabela integralmente a construir). Incidência pontual neste corpus (mesmo evento/concurso de Q75, portanto 1 único evento independente sustentando toda a incidência REAL desta unidade) — não registrar como recorrência de dois eventos.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (2/2).
-- 75,89

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Tabela-verdade: 2 questoes distintas
-- Total de vinculos esperados: 2 (2 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
