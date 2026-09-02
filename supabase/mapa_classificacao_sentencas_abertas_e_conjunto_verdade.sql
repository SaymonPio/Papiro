-- Mapa de classificacao semantica das questoes validas de Sentenças abertas e conjunto-verdade
-- (curso_conteudos.id = 9, assunto_id = 32,
-- materia_id = 18), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/sentencas_abertas_e_conjunto_verdade.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_sentencas_abertas_e_conjunto_verdade_teste_rollback.sql
--   classificar_questoes_unidades_sentencas_abertas_e_conjunto_verdade.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 9 (apos curadoria_unidades_sentencas_abertas_e_conjunto_verdade.sql):
--   U1 4ed265ff-578a-4462-bce6-d756b8ad5838  ordem 1  Sentenças abertas e conjunto-verdade
--
-- Resultado da curadoria: 3/3 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (78, '4ed265ff-578a-4462-bce6-d756b8ad5838'::uuid, 1, 'Conjunto-verdade de sentença aberta composta (disjunção) sobre domínio finito explícito (origem=REAL)', 'ORIGEM: REAL (Fundatec, SUSEPE RS - Agente Penitenciário Administrativo, 2022). Fenômeno testado: dado o universo U={0,1,2,3,4,5}, determinar o conjunto-verdade da sentença composta aberta ''x²=4 ∨ x+3>6''. Recálculo independente elemento a elemento confirmado: x=0(F,F); x=1(F,F); x=2(V,F)->V; x=3(F,F); x=4(F,V)->V; x=5(F,V)->V. Conjunto-verdade = {2,4,5}, gabarito confirmado (alternativa ordem 2). Habilidade nuclear: testar sistematicamente cada elemento de um domínio explícito contra uma sentença composta (equação disjuntada com inequação) e determinar o subconjunto que a satisfaz, aplicando a regra de que o conjunto-verdade de uma disjunção é a união dos conjuntos-solução de cada componente. Teste contrafactual: a tarefa não é ''resolva x²=4'' isoladamente (isso seria Matemática) - é determinar o conjunto-verdade de uma sentença lógica composta sobre um domínio dado, com a álgebra como ferramenta, não como fim. Categoria: H) determinação de conjunto-verdade de sentença aberta sobre domínio explícito. Única questão REAL do corpus (evento único) — não há base para declarar recorrência. Explicação armazenada NÃO alterada nesta curadoria.', 'alta'),
    (289, '4ed265ff-578a-4462-bce6-d756b8ad5838'::uuid, 1, 'Conjunto-verdade de sentença aberta elementar (equação) com verificação de pertinência ao domínio (cobertura suplementar; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca="Papiro", concurso="PAPIRO - Adaptada do padrão Fundatec 2025/2026", ano=2026) — material suplementar de prática, NÃO conta para incidência histórica, recorrência, frequência ou recência da banca — registrada como COBERTURA_SUPLEMENTAR_SENTENCAS_ABERTAS. Fenômeno testado: dada a sentença aberta ''x+2=7'' no universo dos números inteiros, determinar seu conjunto-verdade. Recálculo confirmado: x=5, e 5 pertence aos inteiros, logo V={5} — gabarito confirmado (alternativa ordem 1). A alternativa distratora ''vazio'' (ordem 5) testa especificamente se o aluno verifica a pertinência da solução ao domínio, confirmando que essa verificação é parte viva da tarefa, não apenas resolver a equação isoladamente. É a candidata mais elementar do corpus (álgebra de 1 passo), mas mantém a entrega final explicitamente enquadrada como conjunto-verdade sobre um domínio nomeado, distinguindo-a de uma questão de Matemática pura. Categoria: H) determinação de conjunto-verdade de sentença aberta elementar. Explicação armazenada NÃO alterada nesta curadoria.', 'alta'),
    (290, '4ed265ff-578a-4462-bce6-d756b8ad5838'::uuid, 1, 'Conjunto-verdade de sentença aberta (inequação) com ênfase em desigualdade estrita (cobertura suplementar; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca="Papiro", concurso="PAPIRO - Adaptada do padrão Fundatec 2025/2026", ano=2026) — material suplementar de prática, NÃO conta para incidência histórica, recorrência, frequência ou recência da banca — registrada como COBERTURA_SUPLEMENTAR_SENTENCAS_ABERTAS. Fenômeno testado: dado o universo U={1,2,3,4,5}, determinar o conjunto-verdade da sentença aberta ''x>3''. Recálculo confirmado elemento a elemento: 1,2,3 não satisfazem (3 não é estritamente maior que 3); 4 e 5 satisfazem — V={4,5}, gabarito confirmado (alternativa ordem 1). A alternativa distratora que inclui o elemento 3 (ordem 3) testa especificamente a distinção entre desigualdade estrita (>) e não-estrita (≥), foco pedagógico explícito desta questão. Não é duplicata de Q78/Q289: sentença simples (não composta), inequação (não equação), com ênfase pedagógica distinta (precisão de desigualdade estrita). Categoria: H) determinação de conjunto-verdade de sentença aberta elementar. Explicação armazenada NÃO alterada nesta curadoria.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (3/3).
-- 78,289,290

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Sentenças abertas e conjunto-verdade: 3 questoes distintas
-- Total de vinculos esperados: 3 (3 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
