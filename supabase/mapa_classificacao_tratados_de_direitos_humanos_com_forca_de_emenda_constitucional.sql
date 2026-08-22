-- Mapa de classificacao semantica das questoes validas de Tratados de Direitos Humanos com força de Emenda Constitucional
-- (curso_conteudos.id = 78, assunto_id = 99,
-- materia_id = 11), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/tratados_de_direitos_humanos_com_forca_de_emenda_constitucional.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_tratados_de_direitos_humanos_com_forca_de_emenda_constitucional_teste_rollback.sql
--   classificar_questoes_unidades_tratados_de_direitos_humanos_com_forca_de_emenda_constitucional.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 78 (apos curadoria_unidades_tratados_de_direitos_humanos_com_forca_de_emenda_constitucional.sql):
--   U1 e996e440-4508-4878-8acd-c805b718b27c  ordem 1  Tratados de Direitos Humanos com força de Emenda Constitucional
--
-- Resultado da curadoria: 3/4 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: 351 (Materialmente aderente ao conteudo substantivo da Convencao sobre os Direitos das Pessoas com Deficiencia (CDPD) — testa art. 2, art. 3, art. 5 item 4 e art. 7 item 3 da Convencao, nao o rito do art. 5o, SS3o da CF nem a distincao entre status de emenda constitucional e status supralegal, que sao o objeto real deste curso_conteudo_id. Destino pedagogico provavel: curso_conteudo_id 71 (Pessoa com Deficiencia), ja concluido — nao reaberto/alterado nesta curadoria. Questao permanece ativa e intacta.).

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (127, 'e996e440-4508-4878-8acd-c805b718b27c'::uuid, 1, 'Status de emenda constitucional vs. supralegalidade (alternativa INCORRETA)', 'Comando: assinale a alternativa INCORRETA sobre tratados equiparados a emendas constitucionais pelo rito do art. 5º, §3º. Alt1 (Tratado de Marraqueche possui status de EC) verdadeira — Decreto 9.522/2018, segundo tratado aprovado sob esse rito. Alt2 (CDPD possui status de EC) verdadeira — Decreto 6.949/2009, primeiro tratado aprovado sob esse rito. Alt3 (Protocolo Facultativo à CDPD possui status de EC) verdadeira — aprovado conjuntamente com a Convenção sob o mesmo rito. Alt4 (INCORRETA selecionada, gabarito: Pacto de San José da Costa Rica possui status de EC) falsa — o Pacto de San José foi internalizado sem o rito qualificado do art. 5º, §3º e possui, segundo a jurisprudência do STF (RE 466.343/SP), status supralegal, não equivalente a emenda constitucional. Alt5 (PIDCP possui status supralegal) verdadeira, pela mesma razão jurídica (não aprovado pelo rito qualificado).', 'alta'),
    (265, 'e996e440-4508-4878-8acd-c805b718b27c'::uuid, 1, 'Efeito jurídico do rito do art. 5º, §3º', 'Gabarito ''Equivalem às emendas constitucionais'' — cópia literal do art. 5º, §3º da CF/88, para tratados de direitos humanos aprovados em cada Casa do Congresso, em dois turnos, por três quintos dos votos.', 'alta'),
    (266, 'e996e440-4508-4878-8acd-c805b718b27c'::uuid, 1, 'Exemplo de tratado aprovado pelo rito qualificado', 'Comando conferido literalmente: pede identificação de UM exemplo válido de tratado com status equivalente a EC, sem termo de exclusividade (''o único'', ''apenas''). Gabarito ''Convenção sobre os Direitos das Pessoas com Deficiência e seu Protocolo Facultativo'' — exemplo correto e válido (Decreto 6.949/2009, aprovado pelo rito do art. 5º, §3º), mantido mesmo com a existência atual de outros tratados também aprovados sob esse rito (Tratado de Marraqueche; Convenção Interamericana contra o Racismo). Distratores sem correspondência: Pacto de San José pelo rito ordinário (não é EC), Código Civil, Código Penal, Lei Maria da Penha (nenhum é tratado internacional).', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (3/4).
-- 127,265,266

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): 351 (Materialmente aderente ao conteudo substantivo da Convencao sobre os Direitos das Pessoas com Deficiencia (CDPD) — testa art. 2, art. 3, art. 5 item 4 e art. 7 item 3 da Convencao, nao o rito do art. 5o, SS3o da CF nem a distincao entre status de emenda constitucional e status supralegal, que sao o objeto real deste curso_conteudo_id. Destino pedagogico provavel: curso_conteudo_id 71 (Pessoa com Deficiencia), ja concluido — nao reaberto/alterado nesta curadoria. Questao permanece ativa e intacta.)

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Tratados de Direitos Humanos com força de Emenda Constitucional: 3 questoes distintas
-- Total de vinculos esperados: 3 (3 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
