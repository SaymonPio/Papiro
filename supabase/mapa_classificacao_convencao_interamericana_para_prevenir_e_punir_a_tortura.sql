-- Mapa de classificacao semantica das questoes validas de Convenção Interamericana para Prevenir e Punir a Tortura
-- (curso_conteudos.id = 79, assunto_id = 104,
-- materia_id = 11), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/convencao_interamericana_para_prevenir_e_punir_a_tortura.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_convencao_interamericana_para_prevenir_e_punir_a_tortura_teste_rollback.sql
--   classificar_questoes_unidades_convencao_interamericana_para_prevenir_e_punir_a_tortura.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 79 (apos curadoria_unidades_convencao_interamericana_para_prevenir_e_punir_a_tortura.sql):
--   U1 af995205-bb67-49e4-8ad1-151e339e892a  ordem 1  Convenção Interamericana para Prevenir e Punir a Tortura
--
-- Resultado da curadoria: 3/3 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (124, 'af995205-bb67-49e4-8ad1-151e339e892a'::uuid, 1, 'Definição de tortura, responsabilidade e vedação de justificativas (multi-dispositivo, alternativa CORRETA)', 'Alt1 (falsa — adiciona ''em qualquer hipótese'' ao art. 2, que na verdade condiciona a exclusão do conceito de tortura a ''que não incluam a realização dos atos ou a aplicação dos métodos'' do próprio artigo — fabricação de absolutização) art. 2. Alt2 (CORRETA selecionada, gabarito — cópia parafraseada do art. 3, alínea ''a'': funcionário público que, podendo impedir a tortura, não o faz, é igualmente responsável pelo delito) art. 3, "a". Alt3 (falsa — inverte o art. 4, que diz que ordens superiores NÃO eximem da responsabilidade penal) art. 4. Alt4 (falsa — inverte o art. 5, que diz que periculosidade do detido/insegurança do estabelecimento NÃO podem justificar tortura) art. 5. Alt5 (falsa — inverte o art. 5, que diz que circunstâncias excepcionais como estado de guerra NÃO justificam tortura) art. 5.', 'alta'),
    (249, 'af995205-bb67-49e4-8ad1-151e339e892a'::uuid, 1, 'Dever estatal de prevenir e punir a tortura no âmbito da jurisdição', 'Gabarito ''Os Estados devem prevenir e punir a tortura dentro de sua jurisdição'' — corresponde ao art. 6, que dispõe expressamente que os Estados Partes tomarão ''medidas efetivas a fim de prevenir e punir a tortura no âmbito de sua jurisdição''. CORREÇÃO: não é o art. 1 (que apenas estabelece ''os Estados Partes obrigam-se a prevenir e a punir a tortura, nos termos desta Convenção'', sem qualificador de jurisdição) — a formulação literal do gabarito, com o qualificador territorial, corresponde exclusivamente ao art. 6; nenhuma alternativa testa o art. 1 de forma autônoma. Distratores sem correspondência (tortura admitida em guerra, convenção trata só de danos patrimoniais, só particulares podem torturar, convenção não impõe deveres estatais).', 'alta'),
    (250, 'af995205-bb67-49e4-8ad1-151e339e892a'::uuid, 1, 'Vedação de circunstâncias excepcionais como justificativa', 'Gabarito ''Não justificam a prática de tortura'' — cópia do art. 5 (circunstâncias excepcionais como estado de guerra ou ameaça à segurança nacional não justificam a prática de tortura). Distratores invertem/fabricam consequências inexistentes (autorizam tortura mediante ordem superior, permitem tortura somente durante interrogatório, suspendem integralmente a Convenção, transformam a tortura em infração administrativa).', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (3/3).
-- 124,249,250

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Convenção Interamericana para Prevenir e Punir a Tortura: 3 questoes distintas
-- Total de vinculos esperados: 3 (3 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
