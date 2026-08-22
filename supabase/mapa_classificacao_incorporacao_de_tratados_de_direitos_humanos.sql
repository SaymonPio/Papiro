-- Mapa de classificacao semantica das questoes validas de Incorporação de tratados de Direitos Humanos
-- (curso_conteudos.id = 93, assunto_id = 101,
-- materia_id = 11), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/incorporacao_de_tratados_de_direitos_humanos.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_incorporacao_de_tratados_de_direitos_humanos_teste_rollback.sql
--   classificar_questoes_unidades_incorporacao_de_tratados_de_direitos_humanos.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 93 (apos curadoria_unidades_incorporacao_de_tratados_de_direitos_humanos.sql):
--   U1 98b10517-14a2-4efe-8360-960cae263ad5  ordem 1  Incorporação de tratados de Direitos Humanos
--
-- Resultado da curadoria: 3/3 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (165, '98b10517-14a2-4efe-8360-960cae263ad5'::uuid, 1, 'Equivalência dos tratados de DH aprovados pelo rito qualificado a emendas constitucionais', 'Fundamento normativo: CF/88, art. 5º, §3º (EC 45/2004) — ''Os tratados e convenções internacionais sobre direitos humanos que forem aprovados, em cada Casa do Congresso Nacional, em dois turnos, por três quintos dos votos dos respectivos membros, serão equivalentes às emendas constitucionais.'' Gabarito ''Emendas constitucionais'' — cópia direta do dispositivo. Distratores fabricam hierarquias inexistentes (leis ordinárias, decretos municipais, medidas provisórias, resoluções administrativas). Sobreposição temática (não duplicata) com Q265 do conteúdo 78 (Tratados de Direitos Humanos com força de Emenda Constitucional, já concluído): mesma regra do art. 5º, §3º, questão diferente, sem duplicata exata de ID.', 'alta'),
    (166, '98b10517-14a2-4efe-8360-960cae263ad5'::uuid, 1, 'Status supralegal dos tratados de DH sem o rito do art. 5º, §3º', 'Fundamento jurisprudencial: STF, RE 466.343/SP, Rel. Min. Cezar Peluso, Tribunal Pleno, julgamento concluído em 03/12/2008 — tese da supralegalidade dos tratados internacionais de direitos humanos internalizados sem o rito do art. 5º, §3º (hierarquicamente inferiores à Constituição, mas superiores à legislação ordinária/infraconstitucional). Gabarito ''Supralegal'' — correto. O art. 5º, §3º aparece no enunciado apenas como elemento de CONTRASTE entre as duas categorias de tratados (com e sem o rito qualificado), não como dispositivo cujo teor esteja sendo testado diretamente nesta questão — permanece em artigos_esperados apenas por força da Q165, não desta questão isoladamente. Distratores fabricam status incompatíveis (emenda constitucional automática, inferior a decreto, de lei municipal, sem qualquer efeito interno). Contexto complementar não obrigatório para responder (documentar na aula, sem entrar em artigos_esperados): RE 349.703, HC 87.585, Súmula Vinculante 25 (consequência da orientação sobre o Pacto de San José e a prisão civil do depositário infiel).', 'alta'),
    (167, '98b10517-14a2-4efe-8360-960cae263ad5'::uuid, 1, 'Participação dos Poderes competentes na incorporação de tratados', 'Fundamento normativo: CF/88, art. 84, VIII (''Compete privativamente ao Presidente da República: ... celebrar tratados, convenções e atos internacionais, sujeitos a referendo do Congresso Nacional'') combinado com art. 49, I (''É da competência exclusiva do Congresso Nacional: resolver definitivamente sobre tratados, acordos ou atos internacionais...''). Gabarito ''Participação dos Poderes competentes segundo o procedimento constitucional'' — corresponde à repartição de competências entre Executivo (celebração) e Legislativo (referendo/aprovação) prevista nesses dois dispositivos. PRECISÃO PEDAGÓGICA: a questão diz ''em linhas gerais'', cobrando apenas a ideia de participação dos Poderes competentes — a futura aula pode explicar o fluxo geral (Executivo celebra; Legislativo aprova/referenda; posterior conclusão dos atos necessários à vinculação/inserção interna), mas sem apresentar art. 84 VIII e art. 49 I como se esgotassem tecnicamente todas as etapas de internalização, nem ampliar o corpus para um estudo completo de Direito Internacional Público. Distratores fabricam procedimentos que excluem a repartição constitucional de competências (apenas decisão de prefeito, somente ato do Judiciário, apenas votação popular obrigatória, aprovação por tribunal estrangeiro).', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (3/3).
-- 165,166,167

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Incorporação de tratados de Direitos Humanos: 3 questoes distintas
-- Total de vinculos esperados: 3 (3 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
