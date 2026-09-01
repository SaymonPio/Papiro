-- Mapa de classificacao semantica das questoes validas de Proposições e conectivos
-- (curso_conteudos.id = 1, assunto_id = 36,
-- materia_id = 18), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/proposicoes_e_conectivos.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_proposicoes_e_conectivos_teste_rollback.sql
--   classificar_questoes_unidades_proposicoes_e_conectivos.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 1 (apos curadoria_unidades_proposicoes_e_conectivos.sql):
--   U1 6683c484-74a7-4b07-9cda-1a72190e6445  ordem 1  Proposições e conectivos
--
-- Resultado da curadoria: 3/3 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (74, '6683c484-74a7-4b07-9cda-1a72190e6445'::uuid, 1, 'Avaliação de proposição composta a partir de proposições simples (origem=REAL)', 'ORIGEM: REAL (Fundatec, SUSEPE RS - Agente Penitenciário Administrativo, 2022). Fenômeno testado: dadas as proposições simples p ("Eduardo Leite é o atual prefeito de Porto Alegre" — FALSA) e q ("Porto Alegre é a capital do Rio Grande do Sul" — VERDADEIRA), identificar qual proposição composta entre 5 alternativas (p∧q, q→p, p∨¬q, p→q, p∧¬q) é verdadeira. Recálculo independente confirmado: p∧q=F∧V=F; q→p=V→F=F; p∨¬q=F∨F=F; p→q=F→V=V (correta, gabarito D — condicional com antecedente falso é sempre verdadeira); p∧¬q=F∧F=F. O núcleo da questão é lógico (avaliar a composta a partir do valor V/F já determinado da simples) — o fato político em si (Eduardo Leite é governador do RS, não prefeito de Porto Alegre) não precisa virar conteúdo pedagógico à parte, apenas serve para determinar objetivamente que p=F. Categoria: B) regra factual de produto lógico (aplicação de tabela-verdade da condicional). Incidência pontual neste corpus (evento/concurso único, ver Q87) — não registrar como recorrente. Explicação armazenada NÃO alterada nesta curadoria.', 'alta'),
    (87, '6683c484-74a7-4b07-9cda-1a72190e6445'::uuid, 1, 'Avaliação de expressões compostas com múltiplos conectivos e negação aninhada (origem=REAL)', 'ORIGEM: REAL (Fundatec, SUSEPE RS - Agente Penitenciário, 2022 — mesmo evento/concurso de Q74: SUSEPE/Polícia Penal RS 01/2022, caderno distinto). Fenômeno testado: dados P=V, Q=F, R=V, avaliar o valor lógico de três expressões compostas: I. (¬P∨Q)∧R; II. ¬P∧(Q∨R); III. P→(¬R∨Q). Recálculo independente confirmado passo a passo: I. (¬V∨F)∧V=(F∨F)∧V=F∧V=F; II. ¬V∧(F∨V)=F∧V=F; III. V→(¬V∨F)=V→(F∨F)=V→F=F. Sequência F-F-F, gabarito E. Procedimento ensinado explicitamente por etapas (negações primeiro, depois parênteses internos, depois conectivo externo), não por chute ou memorização isolada. Teste contrafactual: dominar apenas as definições dos 5 conectivos (ensinadas nesta unidade) basta para resolver, sem exigir o aparato mais amplo de Negação de proposições (regras de De Morgan para simplificar) nem de Tabela-verdade (construção de tabela completa com enumeração de todas as combinações). Categoria: B) regra factual de produto lógico (aplicação combinada de tabelas-verdade). Incidência pontual neste corpus (mesmo evento/concurso de Q74, portanto 1 único evento independente sustentando toda a incidência REAL desta unidade) — não registrar como recorrência de dois eventos. Explicação armazenada NÃO alterada nesta curadoria.', 'alta'),
    (313, '6683c484-74a7-4b07-9cda-1a72190e6445'::uuid, 1, 'Identificação do conectivo da disjunção (cobertura suplementar; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca="Papiro", concurso="PAPIRO - Adaptada do padrão Fundatec 2025/2026", ano=2026) — material suplementar de prática, NÃO conta para incidência histórica, recorrência, frequência ou recência da banca — registrada como COBERTURA_SUPLEMENTAR_PROPOSICOES_E_CONECTIVOS. Fenômeno testado: o conectivo lógico da disjunção (inclusiva, símbolo ∨) é representado na linguagem natural pela palavra "ou" (gabarito A) — distinto de "e" (conjunção), "se...então" (condicional), "se e somente se" (bicondicional) e "não" (modificador unário de negação). Categoria: A) regra conceitual. Explicação armazenada NÃO alterada nesta curadoria.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (3/3).
-- 74,87,313

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Proposições e conectivos: 3 questoes distintas
-- Total de vinculos esperados: 3 (3 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
