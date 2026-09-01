-- Mapa de classificacao semantica das questoes validas de Quantificadores
-- (curso_conteudos.id = 7, assunto_id = 33,
-- materia_id = 18), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/quantificadores.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_quantificadores_teste_rollback.sql
--   classificar_questoes_unidades_quantificadores.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 7 (apos curadoria_unidades_quantificadores.sql):
--   U1 b46a6a8e-d7bf-4c19-81f3-5f0fd3352f8c  ordem 1  Quantificadores
--
-- Resultado da curadoria: 2/2 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (83, 'b46a6a8e-d7bf-4c19-81f3-5f0fd3352f8c'::uuid, 1, 'Avaliação do valor lógico de sentenças quantificadas sobre domínio explícito (origem=REAL)', 'ORIGEM: REAL (Fundatec, SUSEPE RS - Agente Penitenciário, 2022). Fenômeno testado: avaliar o valor lógico de três sentenças quantificadas sobre conjuntos explícitos: I. ∀x∈{0,2,4,6}, x é par; II. ∃x∈{0,1,2,3,4,5}, x+2>5; III. ∃x∈{0,1,2,3}, x é primo. Recálculo independente confirmado: I é V (0,2,4,6 são todos pares); II é V (x=4 ou x=5 satisfazem x+2>5); III é V (2 e 3 são primos e pertencem ao conjunto). Sequência V-V-V, gabarito A. Habilidade nuclear: aplicar corretamente a semântica de ∀ (exige que a propriedade valha para TODOS os elementos do domínio) e de ∃ (basta UM elemento satisfazer) sobre conjuntos dados explicitamente — nenhuma negação está envolvida em nenhuma das três sentenças, o que distingue claramente esta questão de Negação de proposições. Teste contrafactual: dominar apenas a negação de sentenças quantificadas (Eixo A de Negação de proposições) não ajudaria em nada aqui — a tarefa é avaliação direta de verdade, não negação. Categoria: F) avaliação semântica de quantificador sobre domínio explícito. Única questão REAL do corpus (evento único) — não há base para declarar recorrência. Explicação armazenada NÃO alterada nesta curadoria.', 'alta'),
    (288, 'b46a6a8e-d7bf-4c19-81f3-5f0fd3352f8c'::uuid, 1, 'Reconhecimento do quantificador existencial em linguagem natural (cobertura suplementar; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca="Papiro", concurso="PAPIRO - Adaptada do padrão Fundatec 2025/2026", ano=2026) — material suplementar de prática, NÃO conta para incidência histórica, recorrência, frequência ou recência da banca — registrada como COBERTURA_SUPLEMENTAR_QUANTIFICADORES. Fenômeno testado: identificar que a expressão "Existe ao menos um servidor que não é policial" utiliza o quantificador EXISTENCIAL (∃) — gabarito A. Distratores testam a distinção categórica entre quantificador universal afirmativo ("Todo"), universal negativo ("Nenhum"), e conectivos lógicos (bicondicional, condicional), que não são quantificadores. O predicado da sentença já vem negado ("não é policial"), mas a TAREFA não é negar nada — é apenas identificar o tipo de quantificador da sentença como está, o que distingue esta questão de Negação de proposições. Categoria: F) reconhecimento/vocabulário de quantificador. Explicação armazenada NÃO alterada nesta curadoria.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (2/2).
-- 83,288

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Quantificadores: 2 questoes distintas
-- Total de vinculos esperados: 2 (2 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
