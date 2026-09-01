-- Mapa de classificacao semantica das questoes validas de Negação de proposições
-- (curso_conteudos.id = 3, assunto_id = 35,
-- materia_id = 18), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/negacao_de_proposicoes.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_negacao_de_proposicoes_teste_rollback.sql
--   classificar_questoes_unidades_negacao_de_proposicoes.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 3 (apos curadoria_unidades_negacao_de_proposicoes.sql):
--   U1 c6ccefae-14df-4760-8c1d-2822090a2a93  ordem 1  Negação de proposições
--
-- Resultado da curadoria: 4/4 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (81, 'c6ccefae-14df-4760-8c1d-2822090a2a93'::uuid, 1, 'Negação de quantificador universal (origem=REAL)', 'ORIGEM: REAL (Fundatec, SUSEPE RS - Agente Penitenciário Administrativo, 2022). Fenômeno testado: a negação de "Todos os alunos da turma 301 estão doentes" é "Existe pelo menos um aluno da turma 301 que não está doente" (gabarito C), formalizada por ¬∀x P(x) ≡ ∃x ¬P(x). Distratores testam exatamente a armadilha central do conteúdo: "Nenhum aluno... está doente" NÃO é a negação lógica do universal, e sim uma afirmação mais forte/contrária (se 1 aluno não estiver doente e os demais estiverem, "todos doentes" já é falso sem que "nenhum doente" seja verdadeiro); "Todos... saudáveis" é o extremo oposto; as demais alternativas invertem a relação de inclusão ou esquecem de negar o predicado. MICROAUDITORIA TAXONÔMICA: reavaliada e confirmada nesta unidade por teste contrafactual (habilidade nuclear = regra de negação do quantificador universal, sem exigir aparato mais amplo de Quantificadores como conteúdo). Categoria: A) regra conceitual. Incidência pontual neste corpus — não registrar como recorrente. Explicação armazenada NÃO alterada nesta curadoria.', 'alta'),
    (86, 'c6ccefae-14df-4760-8c1d-2822090a2a93'::uuid, 1, 'Negação de quantificador existencial (origem=REAL)', 'ORIGEM: REAL (Fundatec, SUSEPE RS - Agente Penitenciário, 2022 — mesmo evento/concurso de Q81 — SUSEPE/Polícia Penal RS 01/2022 —, caderno/cargo distinto). Fenômeno testado: a negação de "Existe pelo menos um aluno de lógica que foi vacinado" é "Todos os alunos de lógica não foram vacinados" (equivalente a "Nenhum aluno de lógica foi vacinado") (gabarito B), formalizada por ¬∃x P(x) ≡ ∀x ¬P(x). Distratores testam: mera paráfrase afirmativa da sentença original; "existe aluno que não foi vacinado" (compatível com existirem também vacinados, logo não é a negação contraditória); universalidade positiva; inversão de categorias lógicas. MICROAUDITORIA TAXONÔMICA: confirmada nesta unidade por teste contrafactual, mesma lógica de Q81. Categoria: A) regra conceitual. Incidência pontual neste corpus — não registrar como recorrente. Explicação armazenada NÃO alterada nesta curadoria.', 'alta'),
    (312, 'c6ccefae-14df-4760-8c1d-2822090a2a93'::uuid, 1, 'Negação de conjunção (cobertura suplementar; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca="Papiro", concurso="PAPIRO - Adaptada do padrão Fundatec 2025/2026", ano=2026) — material suplementar de prática, NÃO conta para incidência histórica, recorrência, frequência ou recência da banca — registrada como COBERTURA_SUPLEMENTAR_NEGACAO_DE_PROPOSICOES. Fenômeno testado: a negação de "João estuda e Maria trabalha" é "João não estuda ou Maria não trabalha" (gabarito A), formalizada por ¬(P∧Q) ≡ ¬P∨¬Q — negar cada proposição simples e trocar "e" por "ou". MICROAUDITORIA TAXONÔMICA DEDICADA: esta transformação é uma aplicação das Leis de De Morgan, mas, na taxonomia atual aprovada desta ordem, a questão permanece primariamente em Negação de proposições, por decisão explícita após teste contrafactual — não movida nem duplamente vinculada nesta operação (vínculo cruzado com Leis de De Morgan seria tecnicamente impossível sem saneamento de assunto_id, dado o trigger validar_questao_unidade_pedagogica). A mesma habilidade nuclear foi encontrada em 3 questões que compõem o corpus inteiro do conteúdo futuro Leis de De Morgan (Q77, Q88, Q311) — registrada como pendência de taxonomia externa a esta ordem, para decisão quando aquele conteúdo for auditado, sem nenhuma ação sobre essas questões agora. Categoria: B) regra factual/procedimental. Explicação armazenada NÃO alterada nesta curadoria.', 'alta'),
    (337, 'c6ccefae-14df-4760-8c1d-2822090a2a93'::uuid, 1, 'Negação de disjunção com termo negado (origem=REAL)', 'ORIGEM: REAL (Fundatec, Corpo de Bombeiros Militar RS - Soldado de Primeira Classe, 2025). Fenômeno testado: a negação de "O celular tem 64 gigabytes de memória ou a câmera não tem 8 megapixels" (P∨¬Q) é "O celular não tem 64 gigabytes de memória e a câmera tem 8 megapixels" (¬P∧Q) (gabarito B), formalizada por ¬(P∨¬Q) ≡ ¬P∧Q — trocar "ou" por "e", negar P, e resolver a dupla negação de ¬Q (que retorna à forma afirmativa Q). Distratores testam: manter o conectivo "ou"; não negar a primeira proposição; transformar em condicional; trocar os valores das proposições mantendo o conectivo original. Ensinado explicitamente pelos passos (trocar conectivo; negar cada termo; resolver dupla negação), não apenas como macete mecânico. Categoria: B) regra factual/procedimental. Incidência pontual neste corpus — não registrar como recorrente (evento/concurso distinto de Q81/Q86: Corpo de Bombeiros Militar RS 2025, não SUSEPE/Polícia Penal RS 2022). Explicação armazenada NÃO alterada nesta curadoria.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (4/4).
-- 81,86,312,337

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Negação de proposições: 4 questoes distintas
-- Total de vinculos esperados: 4 (4 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
