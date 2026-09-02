-- Mapa de classificacao semantica das questoes validas de Argumentação lógica
-- (curso_conteudos.id = 10, assunto_id = 40,
-- materia_id = 18), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/argumentacao_logica.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_argumentacao_logica_teste_rollback.sql
--   classificar_questoes_unidades_argumentacao_logica.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 10 (apos curadoria_unidades_argumentacao_logica.sql):
--   U1 5e2d5159-41da-4af7-b75d-4dc21239177d  ordem 1  Argumentação lógica
--
-- Resultado da curadoria: 3/3 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (90, '5e2d5159-41da-4af7-b75d-4dc21239177d'::uuid, 1, 'Avaliação de validade de três argumentos categóricos por contraexemplo e prova de necessidade (origem=REAL)', 'ORIGEM: REAL (Fundatec, SUSEPE RS - Agente Penitenciário, 2022). Fenômeno testado: avaliar a validade de 3 argumentos: I. ''Todos os alunos de lógica foram vacinados. André foi vacinado. Logo, André é aluno de lógica'' (afirmação do consequente); II. ''Algum aluno de lógica foi vacinado. André é aluno de lógica. Portanto, André foi vacinado'' (termo médio não distribuído); III. ''Todos os alunos de lógica foram vacinados. André é aluno de lógica. Consequentemente, André foi vacinado'' (modus ponens categórico). Recálculo independente confirmado: para I e II, construí contraexemplos explícitos (André vacinado por outro motivo sem ser aluno; outro colega sendo o aluno vacinado, não André) provando que as premissas podem ser verdadeiras com a conclusão falsa — INVÁLIDOS. Para III, nenhum contraexemplo é logicamente possível (se 100% dos alunos são vacinados e André é aluno, ele necessariamente está vacinado) — VÁLIDO. Gabarito ''Somente o argumento III é válido'' confirmado (alternativa D). Habilidade nuclear: determinar, por construção de contraexemplo e prova de necessidade, se cada conclusão decorre necessariamente das premissas — não é reconhecimento de quantificador (Quantificadores), não é classificação de fórmula (Tautologia), não é interpretação de diagrama dado (Diagramas). Categoria: I) avaliação de consequência lógica necessária entre premissas e conclusão. Única questão REAL do corpus (evento único) — não há base para declarar recorrência. Explicação armazenada NÃO alterada nesta curadoria.', 'alta'),
    (285, '5e2d5159-41da-4af7-b75d-4dc21239177d'::uuid, 1, 'Silogismo categórico direto (modus ponens) sem detecção de falácia (cobertura suplementar; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca="Papiro", concurso="PAPIRO - Adaptada do padrão Fundatec 2025/2026", ano=2026) — material suplementar de prática, NÃO conta para incidência histórica, recorrência, frequência ou recência da banca — registrada como COBERTURA_SUPLEMENTAR_ARGUMENTACAO_LOGICA. Fenômeno testado: ''Todo policial é servidor público. João é policial. Logo, João é servidor público'' — silogismo categórico direto (P⊆S, João∈P ⊢ João∈S). Recálculo confirmado: nenhum contraexemplo é possível, argumento genuinamente VÁLIDO — gabarito ''Válido'' confirmado (alternativa A). Distratores testam nomes de falácias (afirmar consequente, negar antecedente) que na verdade NÃO estão presentes, verificando se o aluno reconhece corretamente uma forma válida genuína sem se confundir com rótulos de erro. Versão mais simples e direta do que Q90 (não exige detectar falácia, apenas confirmar validade), progressão pedagógica de entrada, não duplicata. Categoria: I) avaliação de consequência lógica necessária. Explicação armazenada NÃO alterada nesta curadoria.', 'alta'),
    (286, '5e2d5159-41da-4af7-b75d-4dc21239177d'::uuid, 1, 'Silogismo categórico de exclusão com três categorias, por transitividade de inclusão/disjunção (cobertura suplementar; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca="Papiro", concurso="PAPIRO - Adaptada do padrão Fundatec 2025/2026", ano=2026) — material suplementar de prática, NÃO conta para incidência histórica, recorrência, frequência ou recência da banca — registrada como COBERTURA_SUPLEMENTAR_ARGUMENTACAO_LOGICA. Fenômeno testado: ''Se todos os A são B e nenhum B é C, então é correto concluir que:'' (A⊆B, B∩C=∅). Recálculo confirmado por prova de necessidade: se a∈A, então a∈B (premissa 1); como B∩C=∅, a∉C; logo nenhum elemento de A está em C — ''Nenhum A é C'' é NECESSÁRIO, não apenas provável — gabarito confirmado (alternativa A). Verifiquei também que o distrator ''Algum A é C necessariamente'' não é apenas não-garantido, mas genuinamente IMPOSSÍVEL dadas as premissas — a explicação acerta essa distinção fina entre necessário/possível/impossível. FRONTEIRA COM DIAGRAMAS (auditada com rigor): o enunciado parte de PREMISSAS TEXTUAIS e pede uma CONCLUSÃO TEXTUAL entre 5 alternativas — nunca pede desenhar ou identificar um diagrama; o diagrama de Venn aparece somente no bizu como método de demonstração, nunca como entrega final. Confirmado por contraste direto com Q246 (Diagramas lógicos, assunto 31), cuja tarefa é estruturalmente diagrama-primeiro (parte de um diagrama dado, pede tradução textual da relação gráfica) — estrutura invertida e genuinamente distinta desta questão. Categoria: I) avaliação de consequência lógica necessária entre premissas categóricas e conclusão. Explicação armazenada NÃO alterada nesta curadoria.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (3/3).
-- 90,285,286

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Argumentação lógica: 3 questoes distintas
-- Total de vinculos esperados: 3 (3 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
