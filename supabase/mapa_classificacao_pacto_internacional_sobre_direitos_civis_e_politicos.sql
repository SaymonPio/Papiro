-- Mapa de classificacao semantica das questoes validas de Pacto Internacional sobre Direitos Civis e Políticos
-- (curso_conteudos.id = 74, assunto_id = 85,
-- materia_id = 11), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/pacto_internacional_sobre_direitos_civis_e_politicos.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_pacto_internacional_sobre_direitos_civis_e_politicos_teste_rollback.sql
--   classificar_questoes_unidades_pacto_internacional_sobre_direitos_civis_e_politicos.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 74 (apos curadoria_unidades_pacto_internacional_sobre_direitos_civis_e_politicos.sql):
--   U1 8d4e4b20-37ac-4df0-a7ac-57cb016c44d6  ordem 1  Pacto Internacional sobre Direitos Civis e Políticos
--
-- Resultado da curadoria: 3/3 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (58, '8d4e4b20-37ac-4df0-a7ac-57cb016c44d6'::uuid, 1, 'Direitos civis fundamentais do PIDCP (multi-dispositivo, alternativa INCORRETA)', 'Alt1 (verdadeira, cópia literal sobre direito à vida/vedação a privação arbitrária) art. 6º, item 1. Alt2 (INCORRETA selecionada, gabarito — o texto real do art. 7º afirma ''será proibido, sobretudo, submeter uma pessoa, sem seu livre consentimento, a experiências médicas ou científicas''; a alternativa inverte para ''é autorizado submeter uma pessoa...'') art. 7º. Alt3 (verdadeira, cópia literal sobre direito à reparação por prisão/encarceramento ilegais) art. 9º, item 5. Alt4 (verdadeira, cópia literal sobre tratamento humano e respeito à dignidade da pessoa privada de liberdade) art. 10, item 1. Alt5 (verdadeira — o texto real veda a prisão fundada exclusivamente na incapacidade de cumprir obrigação contratual, sem ampliar para ''descumprimento de obrigação contratual'' em sentido genérico) art. 11.', 'alta'),
    (259, '8d4e4b20-37ac-4df0-a7ac-57cb016c44d6'::uuid, 1, 'Direito à vida', 'Gabarito ''À vida'' — cópia literal do art. 6º, item 1. Distratores são inversões de proibições reais do Pacto: ''à escravidão'' (o Pacto proíbe, não protege, a escravidão — art. 8º), ''à tortura em situação excepcional'' (a proibição do art. 7º é absoluta, sem exceção), ''à prisão arbitrária'' (o Pacto proíbe a prisão arbitrária, não a protege como direito — art. 9º), ''à censura obrigatória'' (fabricação sem correspondência, o Pacto protege liberdade de expressão, art. 19).', 'alta'),
    (260, '8d4e4b20-37ac-4df0-a7ac-57cb016c44d6'::uuid, 1, 'Proibição de tortura e tratamentos cruéis, desumanos ou degradantes', 'Gabarito ''À tortura nem a penas ou tratamentos cruéis, desumanos ou degradantes'' — cópia literal do art. 7º. Distratores trocam a categoria: são direitos positivos (processo judicial regular, identificação civil, responsabilização legal, aplicação de lei previamente existente), não vedações do tipo ''ninguém poderá ser submetido a''.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (3/3).
-- 58,259,260

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Pacto Internacional sobre Direitos Civis e Políticos: 3 questoes distintas
-- Total de vinculos esperados: 3 (3 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
