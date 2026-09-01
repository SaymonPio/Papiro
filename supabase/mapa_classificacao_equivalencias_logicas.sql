-- Mapa de classificacao semantica das questoes validas de Equivalências lógicas
-- (curso_conteudos.id = 5, assunto_id = 41,
-- materia_id = 18), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/equivalencias_logicas.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_equivalencias_logicas_teste_rollback.sql
--   classificar_questoes_unidades_equivalencias_logicas.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 5 (apos curadoria_unidades_equivalencias_logicas.sql):
--   U1 56df08f8-0f22-48c1-a64d-df11ebfc5ae9  ordem 1  Equivalências lógicas
--
-- Resultado da curadoria: 3/3 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (79, '56df08f8-0f22-48c1-a64d-df11ebfc5ae9'::uuid, 1, 'Reconhecimento de equivalência por comparação de comportamentos lógicos (origem=REAL)', 'ORIGEM: REAL (Fundatec, SUSEPE RS - Agente Penitenciário Administrativo, 2022). Fenômeno testado: dado que uma proposição composta A produz os valores V,F,F,F para p/q nas valorações V/V, V/F, F/V, F/F, identificar qual das 5 fórmulas candidatas (p↔q; ~p↔q; p↔~q; (p↔~q)∧q; (p↔q)∧p) reproduz exatamente esse comportamento. Recálculo independente confirmado linha a linha para as 5 alternativas: p↔q=V,F,F,V (diverge); ~p↔q=F,V,V,F (diverge); p↔~q=F,V,V,F (diverge); (p↔~q)∧q=F,F,V,F (diverge); (p↔q)∧p=V,F,F,F (bate exatamente, gabarito E). O enunciado é textualmente autossuficiente: apesar de mencionar ''tabela-verdade abaixo'', os 4 valores da proposição A já estão declarados por extenso no texto (''V, F, F e F''), sem depender de nenhuma imagem — mesmo padrão de fidelidade já validado em Q75 (Tabela-verdade, ordem 85). Teste contrafactual: dominar apenas ''construir/completar a tabela de uma expressão dada'' (habilidade nuclear de Tabela-verdade) não basta — a tarefa central aqui é comparar múltiplas fórmulas contra um comportamento-alvo e reconhecer a equivalente, o que exige o conceito de equivalência lógica como objeto da pergunta, não apenas como subproduto do cálculo. Categoria: D) reconhecimento de equivalência por comparação. Incidência pontual neste corpus (evento/concurso único, ver Q82) — não registrar como recorrente. Explicação armazenada NÃO alterada nesta curadoria.', 'alta'),
    (82, '56df08f8-0f22-48c1-a64d-df11ebfc5ae9'::uuid, 1, 'Aplicação da equivalência disjuntiva da condicional em linguagem natural, com regra fornecida (origem=REAL)', 'ORIGEM: REAL (Fundatec, SUSEPE RS - Agente Penitenciário, 2022 — mesmo evento/concurso de Q79: SUSEPE/Polícia Penal RS 01/2022, caderno distinto). Fenômeno testado: o próprio enunciado fornece a regra P→Q≡¬P∨Q e pede sua aplicação à sentença ''Se Pedro tem olhos azuis, então o filho de Pedro tem olhos azuis''. Recálculo independente confirmado: P=''Pedro tem olhos azuis'', Q=''filho de Pedro tem olhos azuis''; P→Q≡¬P∨Q=''Pedro não tem olhos azuis ou o filho de Pedro tem olhos azuis'' (gabarito C). Distratores testam armadilhas plausíveis: manter a estrutura condicional sem transformar (A), negar o termo errado (B), usar conjunção com dupla negação em vez de disjunção (D), usar bicondicional (E). Teste contrafactual e distinção de fronteiras: a tarefa NÃO é negar a condicional (a negação de P→Q é P∧¬Q, uma proposição diferente de ¬P∨Q — não pertence a Negação de proposições) nem produzir a contrapositiva (¬Q→¬P, identidade diferente, testada por Q80/Q309 em Condicional e contrapositiva, corretamente classificadas lá) nem apenas ''saber quando a condicional é falsa'' (a questão nunca pergunta valor-verdade). Mesmo com a regra fornecida no enunciado, a tarefa cognitiva remanescente — aplicar corretamente uma transformação de equivalência a uma sentença em linguagem natural, sem confundir com conjunção/bicondicional/condicional mal-negada — é o núcleo genuíno de Equivalências lógicas. Categoria: D) reconhecimento/aplicação de equivalência lógica. Incidência pontual neste corpus (mesmo evento/concurso de Q79, portanto 1 único evento independente sustentando toda a incidência REAL desta unidade) — não registrar como recorrência de dois eventos. Explicação armazenada NÃO alterada nesta curadoria.', 'alta'),
    (310, '56df08f8-0f22-48c1-a64d-df11ebfc5ae9'::uuid, 1, 'Aplicação autônoma da equivalência disjuntiva da condicional, forma abstrata sem regra fornecida (cobertura suplementar; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca="Papiro", concurso="PAPIRO - Adaptada do padrão Fundatec 2025/2026", ano=2026) — material suplementar de prática, NÃO conta para incidência histórica, recorrência, frequência ou recência da banca — registrada como COBERTURA_SUPLEMENTAR_EQUIVALENCIAS_LOGICAS. Fenômeno testado: forma puramente abstrata da mesma identidade de Q82 (P→Q≡¬P∨Q), mas SEM a regra ser fornecida no enunciado e sem tradução de linguagem natural — ''Se P, então Q'' é equivalente a ''Não P ou Q'' (gabarito A). Distrator relevante: a alternativa ''P ou não Q'' é a forma disjuntiva de Q→P (a recíproca), testando precisão sobre qual termo é negado, não apenas memorização superficial da regra. Não é duplicata de Q82: exige recordar a identidade autonomamente (sem scaffold), em forma abstrata — progressão de exigência cognitiva (aplicação guiada em Q82 vs. recall + aplicação não guiada aqui), mesmo padrão de ''reformulação não é duplicata'' já usado em ordens anteriores deste projeto. Categoria: D) reconhecimento/aplicação de equivalência lógica. Explicação armazenada NÃO alterada nesta curadoria.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (3/3).
-- 79,82,310

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Equivalências lógicas: 3 questoes distintas
-- Total de vinculos esperados: 3 (3 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
