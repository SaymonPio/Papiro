-- Mapa de classificacao semantica das questoes validas de Entendimentos do STF e STJ
-- (curso_conteudos.id = 80, assunto_id = 96,
-- materia_id = 11), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/entendimentos_do_stf_e_stj.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_entendimentos_do_stf_e_stj_teste_rollback.sql
--   classificar_questoes_unidades_entendimentos_do_stf_e_stj.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 80 (apos curadoria_unidades_entendimentos_do_stf_e_stj.sql):
--   U1 572c64ec-c7bb-412e-ab3d-94435ed7df12  ordem 1  Entendimentos do STF e STJ
--
-- Resultado da curadoria: 3/3 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (146, '572c64ec-c7bb-412e-ab3d-94435ed7df12'::uuid, 1, 'Súmula Vinculante nº 11 — uso de algemas', 'Fonte: Súmula Vinculante nº 11, STF (não cita artigo de lei/CF em seu próprio texto — fundamento puramente jurisprudencial, sem artigo artificial). Gabarito (preenchimento de lacunas) ''resistência – integridade física – excepcionalidade – nulidade da prisão'' — cópia literal da SV 11: ''Só é lícito o uso de algemas em casos de resistência e de fundado receio de fuga ou de perigo à integridade física própria ou alheia, por parte do preso ou de terceiros, justificada a excepcionalidade por escrito, sob pena de responsabilidade disciplinar civil e penal do agente ou da autoridade e de nulidade da prisão ou do ato processual a que se refere''. Sobreposição documentada (não duplicata): Q198 (conteúdo 69, já concluído) também testa a SV 11, mas com alternativas conceituais totalmente diferentes — não movida, conteúdo 69 não reaberto.', 'alta'),
    (253, '572c64ec-c7bb-412e-ab3d-94435ed7df12'::uuid, 1, 'Tema 280 (RE 603.616) — ingresso forçado em domicílio sem mandado', 'Fonte jurisprudencial: STF, RE 603.616/RO, Tema 280 de Repercussão Geral. Fundamento normativo estruturado: CF, art. 5º, XI. Gabarito ''Fundadas razões que indiquem situação de flagrante delito, justificadas posteriormente'' — corresponde à tese fixada: a entrada forçada em domicílio sem mandado judicial só é lícita, mesmo em período noturno, quando amparada em fundadas razões, devidamente justificadas a posteriori, que indiquem situação de flagrante delito no interior do imóvel. Microchecagem confirmada: as 5 alternativas tratam exclusivamente do requisito de fundadas razões/flagrante (art. 5º, XI) — nenhuma testa autonomamente devido processo legal (art. 5º, LV) ou inadmissibilidade de provas ilícitas (art. 5º, LVI), por isso não incluídos em artigos_esperados apesar de o cadastro do Tema 280 mencionar os três incisos. Distratores sem correspondência (denúncia anônima em qualquer situação, autorização genérica da autoridade policial, mandado judicial posterior obrigatório, suspeita subjetiva do agente).', 'alta'),
    (254, '572c64ec-c7bb-412e-ab3d-94435ed7df12'::uuid, 1, 'Não absolutividade da inviolabilidade domiciliar', 'Fonte jurisprudencial: entendimento consolidado do STF (autor da tese do Tema 280) e do STJ (que aplica e desenvolve essa orientação em casos concretos, examinando a presença de fundadas razões) — formulação segura adotada porque a questão fala genericamente em ''tribunais superiores'', sem atribuir ao STJ uma tese própria autônoma inexistente. Fundamento normativo: CF, art. 5º, XI. Gabarito ''Não impede ingresso sem mandado nas hipóteses constitucionais excepcionais'' — a inviolabilidade domiciliar não é absoluta, mas comporta apenas as hipóteses constitucionais excepcionais (flagrante delito, desastre, prestar socorro, determinação judicial durante o dia), com a exigência jurisprudencial adicional de fundadas razões para o ingresso forçado especificamente fundado em flagrante. Distratores invertem a regra (absoluta em qualquer circunstância; afastável por mera curiosidade policial; depende exclusivamente do horário; não se aplica a residências particulares).', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (3/3).
-- 146,253,254

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Entendimentos do STF e STJ: 3 questoes distintas
-- Total de vinculos esperados: 3 (3 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
