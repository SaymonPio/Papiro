-- Mapa de classificacao semantica das questoes validas de Diagramas lógicos
-- (curso_conteudos.id = 11, assunto_id = 31,
-- materia_id = 18), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/diagramas_logicos.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_diagramas_logicos_teste_rollback.sql
--   classificar_questoes_unidades_diagramas_logicos.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 11 (apos curadoria_unidades_diagramas_logicos.sql):
--   U1 5544e77a-f186-4b1e-9a6d-5ebfbfd12ca9  ordem 1  Diagramas lógicos
--
-- Resultado da curadoria: 3/3 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (246, '5544e77a-f186-4b1e-9a6d-5ebfbfd12ca9'::uuid, 1, 'Interpretação de relação de inclusão total entre duas classes dada por diagrama lógico (origem=REAL)', 'ORIGEM: REAL (Fundatec, SUSEPE RS - Agente Penitenciário Administrativo, 2022). Fenômeno testado: ''Considere válido um diagrama lógico no qual o conjunto das pessoas que gostam de sorvete de creme está totalmente contido no conjunto das pessoas que gostam de sorvete de morango'' (C⊆M) — pede a alternativa necessariamente verdadeira entre 5 opções. Recálculo independente confirmado: (A) ''existem necessariamente pessoas exclusivas de morango'' é FALSO, pois C poderia ser igual a M; (B) inverte a relação (''todo M é C'') — FALSO; (C) presume vazio (''ninguém gosta de creme'') — não afirmado, FALSO; (D) ''todo C é M'' — VERDADEIRO por definição de inclusão, é a única alternativa necessária em TODO cenário compatível com a premissa; (E) extrapola para o universo inteiro (''todos gostam de morango'') — FALSO. Gabarito ''Todas as pessoas que gostam de creme gostam de morango'' (alternativa D) confirmado. Nenhuma importação existencial indevida (a explicação armazenada recusa corretamente presumir existência de elementos exclusivos de M). Dependência visual: enunciado textualmente autossuficiente, descreve por completo a relação diagramática sem exigir imagem — ausência de figura NÃO constitui PROBLEMA_DE_FIDELIDADE_VISUAL. Habilidade nuclear: dado UM diagrama/relação de inclusão entre duas classes, determinar o que ele entrega necessariamente e o que NÃO entrega — distinto do núcleo de Argumentação lógica (Q90/Q285/Q286, curso_conteudo_id 10), que exige combinar ≥2 premissas categóricas para derivar uma relação NOVA por encadeamento dedutivo; aqui há apenas uma relação dada, sem encadeamento multi-premissa. Única questão REAL do corpus (evento único) — não há base para declarar recorrência. Explicação armazenada NÃO alterada nesta curadoria.', 'alta'),
    (247, '5544e77a-f186-4b1e-9a6d-5ebfbfd12ca9'::uuid, 1, 'Interpretação de relação de inclusão total entre duas classes nomeadas, sem framing diagramático explícito (cobertura suplementar; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca="Papiro", concurso="PAPIRO - Estilo Fundatec - BM RS", ano=2026) — material suplementar de prática, NÃO conta para incidência histórica, recorrência, frequência ou recência da banca. Fenômeno testado: ''Considere os conjuntos A = pessoas que estudam Português e B = pessoas que estudam Raciocínio Lógico. Se A está totalmente contido em B'' (A⊆B) — pede a alternativa correta entre 5 opções. Recálculo confirmado: ''Toda pessoa que estuda Português também estuda Raciocínio Lógico'' é verdadeira por definição de inclusão (A∩B=A) — gabarito confirmado (alternativa A), uma universal vacuamente sustentável mesmo se A fosse vazio, sem importação existencial indevida. Distratores testam inversão da relação, presunção de interseção vazia (incompatível com A⊆B se A≠∅), presunção de conjuntos vazios e presunção de igualdade — todos corretamente falsos. Mesma categoria estrutural de Q246 (interpretação de relação de inclusão isolada), sem usar literalmente a palavra ''diagrama'' — pela metodologia do projeto (habilidade nuclear via teste contrafactual, nunca por palavra-chave), isso não desqualifica a questão. Dependência visual: enunciado textualmente autossuficiente, sem qualquer referência a imagem. Não é duplicata de Q246: catálogo de distratores parcialmente distinto e contexto narrativo diferente (progressão pedagógica próxima, não repetição). Explicação armazenada NÃO alterada nesta curadoria.', 'alta'),
    (248, '5544e77a-f186-4b1e-9a6d-5ebfbfd12ca9'::uuid, 1, 'Interpretação de relação de disjunção total (exclusão) entre duas classes (cobertura suplementar; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca="Papiro", concurso="PAPIRO - Estilo Fundatec - BM RS", ano=2026) — material suplementar de prática, NÃO conta para incidência histórica, recorrência, frequência ou recência da banca. Fenômeno testado: ''Em um diagrama, os conjuntos A e B não possuem qualquer interseção'' (A∩B=∅) — pede a alternativa correta entre 5 opções. Recálculo confirmado: ''Nenhum elemento de A pertence a B'' é verdadeiro por definição de disjunção — gabarito confirmado (alternativa A). Distratores testam inclusão em qualquer direção (incompatível com disjunção) e universalidade — todos corretamente falsos. Tipo de relação categórica distinto de Q246/Q247 (disjunção, não inclusão), acrescentando diversidade genuína ao corpus sem constituir duplicata. Dependência visual: enunciado textualmente autossuficiente, descreve por completo a relação sem exigir imagem. Explicação armazenada NÃO alterada nesta curadoria.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (3/3).
-- 246,247,248

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Diagramas lógicos: 3 questoes distintas
-- Total de vinculos esperados: 3 (3 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
