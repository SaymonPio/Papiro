-- Mapa de classificacao semantica das questoes validas de Condicional e contrapositiva
-- (curso_conteudos.id = 6, assunto_id = 39,
-- materia_id = 18), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/condicional_e_contrapositiva.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_condicional_e_contrapositiva_teste_rollback.sql
--   classificar_questoes_unidades_condicional_e_contrapositiva.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 6 (apos curadoria_unidades_condicional_e_contrapositiva.sql):
--   U1 42f5f55c-350a-4fb6-904c-184cde415d1e  ordem 1  Condicional e contrapositiva
--
-- Resultado da curadoria: 2/2 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (80, '42f5f55c-350a-4fb6-904c-184cde415d1e'::uuid, 1, 'Produção da contrapositiva de uma sentença condicional em linguagem natural (origem=REAL)', 'ORIGEM: REAL (Fundatec, SUSEPE RS - Agente Penitenciário Administrativo, 2022). Fenômeno testado: a sentença ''Se x+7=9 (P), então x é par (Q)'' deve ser transformada em sua contrapositiva. Recálculo independente confirmado: ¬Q→¬P = ''Se x é ímpar (¬Q), então x+7≠9 (¬P)'' — bate com a alternativa D (correta). As 4 alternativas incorretas testam exatamente as armadilhas clássicas da contraposição: negar só o consequente sem inverter a ordem (A), inversa ¬P→¬Q sem inverter (B), mistura sem negar o antecedente original (C), recíproca Q→P sem negar (E). A explicação armazenada distingue explicitamente contrapositiva de negação parcial, inversa e recíproca. Teste contrafactual: dominar apenas a condição de falsidade da condicional (P→Q falsa somente em V→F, competência de Proposições e conectivos) não basta — a tarefa central é a transformação estrutural para ¬Q→¬P, que nenhum outro conteúdo já curado exige. Categoria: E) transformação de equivalência estrutural (contraposição). Incidência pontual neste corpus (evento/concurso único) — não registrar como recorrente. Explicação armazenada NÃO alterada nesta curadoria.', 'alta'),
    (309, '42f5f55c-350a-4fb6-904c-184cde415d1e'::uuid, 1, 'Reconhecimento/recall da estrutura formal da contrapositiva, forma abstrata (cobertura suplementar; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca="Papiro", concurso="PAPIRO - Adaptada do padrão Fundatec 2025/2026", ano=2026) — material suplementar de prática, NÃO conta para incidência histórica, recorrência, frequência ou recência da banca — registrada como COBERTURA_SUPLEMENTAR_CONDICIONAL_E_CONTRAPOSITIVA. Fenômeno testado: forma puramente abstrata da mesma identidade de Q80 (P→Q≡¬Q→¬P), sem tradução de linguagem natural — ''A contrapositiva de Se P, então Q é: Se não Q, então não P'' (gabarito A). Distratores testam precisamente a recíproca (Q→P), a inversa (¬P→¬Q), conjunção e disjunção — a explicação armazenada nomeia e distingue cada uma corretamente. Não é duplicata de Q80: exige recordar a estrutura formal autonomamente (sem contexto narrativo a traduzir), progressão de exigência cognitiva em relação à aplicação contextualizada de Q80, mesmo padrão de ''reformulação não é duplicata'' já usado em ordens anteriores deste projeto. Categoria: E) transformação de equivalência estrutural (contraposição). Explicação armazenada NÃO alterada nesta curadoria.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (2/2).
-- 80,309

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Condicional e contrapositiva: 2 questoes distintas
-- Total de vinculos esperados: 2 (2 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
