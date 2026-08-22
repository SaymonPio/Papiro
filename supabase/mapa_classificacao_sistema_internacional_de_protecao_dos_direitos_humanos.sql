-- Mapa de classificacao semantica das questoes validas de Sistema Internacional de Proteção dos Direitos Humanos
-- (curso_conteudos.id = 82, assunto_id = 83,
-- materia_id = 11), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/sistema_internacional_de_protecao_dos_direitos_humanos.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_sistema_internacional_de_protecao_dos_direitos_humanos_teste_rollback.sql
--   classificar_questoes_unidades_sistema_internacional_de_protecao_dos_direitos_humanos.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 82 (apos curadoria_unidades_sistema_internacional_de_protecao_dos_direitos_humanos.sql):
--   U1 522f7c40-b95e-4c91-b0d6-cf4a6f012c16  ordem 1  Sistema Internacional de Proteção dos Direitos Humanos
--
-- Resultado da curadoria: 3/3 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (186, '522f7c40-b95e-4c91-b0d6-cf4a6f012c16'::uuid, 1, 'Sistema universal — desenvolvimento institucional no âmbito da ONU', 'Fundamento: doutrina de Direito Internacional dos Direitos Humanos, sem dispositivo normativo específico. Gabarito ''Organização das Nações Unidas'' — correto: o sistema universal de proteção dos direitos humanos desenvolveu-se institucionalmente no âmbito da ONU. Distratores citam organismos regionais (OEA, União Europeia) ou de natureza distinta, sem relação com direitos humanos como objeto central (Mercosul, OTAN).', 'alta'),
    (187, '522f7c40-b95e-4c91-b0d6-cf4a6f012c16'::uuid, 1, 'Declaração Universal dos Direitos Humanos como marco do sistema universal', 'Fundamento: doutrina + contexto histórico do sistema universal, sem dispositivo normativo específico. Gabarito ''Universal de proteção dos direitos humanos'' — correto: a DUDH (1948) constitui um dos marcos centrais da consolidação do sistema universal de proteção dos direitos humanos (ajuste de redação: não se afirma que é o marco fundacional absoluto, já que a ONU e sua Carta constitutiva são anteriores, de 1945). Distratores atribuem a DUDH exclusivamente a sistemas regionais (interamericano, europeu, africano) ou ao Mercosul, o que é historicamente incorreto.', 'alta'),
    (188, '522f7c40-b95e-4c91-b0d6-cf4a6f012c16'::uuid, 1, 'Complementaridade entre sistemas universal e regionais', 'Fundamento: doutrina de Direito Internacional dos Direitos Humanos, sem dispositivo normativo específico. Gabarito ''Podem coexistir e atuar de forma complementar'' — princípio consolidado: os sistemas universal, regionais e a proteção nacional dos direitos humanos não são excludentes entre si. Distratores fabricam incompatibilidade ou efeitos absurdos (impedem proteção nacional, eliminam Constituições, tratam apenas de comércio).', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (3/3).
-- 186,187,188

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Sistema Internacional de Proteção dos Direitos Humanos: 3 questoes distintas
-- Total de vinculos esperados: 3 (3 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
