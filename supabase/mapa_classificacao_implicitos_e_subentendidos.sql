-- Mapa de classificacao semantica das questoes validas de Implícitos e subentendidos
-- (curso_conteudos.id = 25, assunto_id = 46,
-- materia_id = 6), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/implicitos_e_subentendidos.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_implicitos_e_subentendidos_teste_rollback.sql
--   classificar_questoes_unidades_implicitos_e_subentendidos.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 25 (apos curadoria_unidades_implicitos_e_subentendidos.sql):
--   U1 1a2158e8-f690-43ab-8ca5-051ba1c0fa3e  ordem 1  Implícitos e subentendidos
--
-- Resultado da curadoria: 4/4 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (234, '1a2158e8-f690-43ab-8ca5-051ba1c0fa3e'::uuid, 1, 'Eixo 1 — Efeito/leitura escalar do operador "até" (cobertura suplementar; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca=''Papiro'', concurso=''PAPIRO - Estilo Fundatec - BM RS'', ano=2026) — material suplementar de prática, NÃO conta para incidência histórica, frequência Fundatec, recência ou ocorrência real em concurso; registrado como COBERTURA_SUPLEMENTAR_IMPLICITOS_E_SUBENTENDIDOS. Fenômeno testado: em ''Até João acertou a questão'', o operador ''até'' introduz uma escala contextual e sinaliza que o elemento destacado (João) ocupa uma posição de menor expectativa — o acerto dele era pouco esperado (gabarito A). CUIDADO TERMINOLÓGICO: tratado como EFEITO/LEITURA ESCALAR (conteúdo implícito escalar/implicatura), não rotulado de modo simplista e uniforme como ''pressuposição'' — a explicação armazenada da questão já menciona também a dimensão inclusiva do operador (elimina a leitura de exclusividade da alternativa B). Categoria: A) regra conceitual. Explicação armazenada NÃO alterada nesta curadoria.', 'alta'),
    (235, '1a2158e8-f690-43ab-8ca5-051ba1c0fa3e'::uuid, 1, 'Eixo 2 — Pressuposto por mudança de estado (cobertura suplementar; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca=''Papiro'', concurso=''PAPIRO - Estilo Fundatec - BM RS'', ano=2026) — material suplementar de prática, NÃO conta para incidência histórica; registrado como COBERTURA_SUPLEMENTAR_IMPLICITOS_E_SUBENTENDIDOS. Fenômeno testado: em ''Pedro parou de fumar'', o verbo de mudança de estado ''parar de'' ativa o PRESSUPOSTO de que Pedro fumava no período anterior (gabarito A) — pressuposto genuíno (sobrevive à negação: ''Pedro não parou de fumar'' ainda pressupõe que ele fumava). Regra de bolso: ''PARAR DE X pressupõe, na construção concreta, que X ocorria antes''. A explicação armazenada já evita corretamente extrapolar frequência, motivo, duração ou resultado posterior. Categoria: A) regra conceitual. Explicação armazenada NÃO alterada nesta curadoria.', 'alta'),
    (236, '1a2158e8-f690-43ab-8ca5-051ba1c0fa3e'::uuid, 1, 'Eixo 3 — Pressuposto de retomada (cobertura suplementar; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca=''Papiro'', concurso=''PAPIRO - Estilo Fundatec - BM RS'', ano=2026) — material suplementar de prática, NÃO conta para incidência histórica; registrado como COBERTURA_SUPLEMENTAR_IMPLICITOS_E_SUBENTENDIDOS. Fenômeno testado: em ''Maria voltou a estudar'', a locução aspectual ''voltou a'' ativa o PRESSUPOSTO de que Maria já estudava antes, houve descontinuidade, e agora retomou (gabarito A) — pressuposto genuíno (sobrevive à negação). A explicação armazenada já evita corretamente extrapolar aprovação, motivo da interrupção, frequência ou duração — e já registra a distinção pressuposto (marca gramatical explícita) × subentendido (inferência contextual sem marca direta, mas ainda limitada pelo contexto e pelas condições comunicativas, não ''opinião subjetiva''). Categoria: A) regra conceitual. Explicação armazenada NÃO alterada nesta curadoria.', 'alta'),
    (878, '1a2158e8-f690-43ab-8ca5-051ba1c0fa3e'::uuid, 1, 'Eixo 4 — Pressuposto/gatilho lexical seriado via adjetivo "novos" (REAL, Fundatec; primeira e única incidência real do conteúdo)', 'ORIGEM: REAL (banca=''Fundatec'', concurso=''TA Pol Pen (PP RS)/PP RS/2022'', ano=2022) — SUSEPE/RS Concurso Público nº 01/2022, cargo Agente Penitenciário Administrativo/Técnico Administrativo da Polícia Penal, Questão 18 do caderno original, gabarito oficial A confirmado por fonte primária (fidelidade verificada em microauditoria dedicada: fragmento e as 5 alternativas literais, gabarito oficial A). CONTA como incidência real e prática específica real deste conteúdo — primeira e única do corpus até o momento. Fenômeno testado: no fragmento ''perseguir novos recordes de redução na criminalidade'', o adjetivo ''novos'' — já entregue pronto pelo comando como adjetivo, sem exigir classificação morfológica do aluno — ativa, no contexto concreto (aplicado a ''recordes'', substantivo que designa itens de uma série), o PRESSUPOSTO de que já havia outro ou outros recordes anteriormente (gabarito A). Habilidade nuclear: semântico-pragmática (interpretação do implícito), não classificação morfológica — PROBLEMA_DE_TAXONOMIA_Q878 confirmado e já saneado (assunto_id 47→46, operação separada, commit 5856a10) antes desta curadoria; este vínculo apenas formaliza, nos artefatos canônicos, a classificação já aprovada e já aplicada ao vivo. LIMITE PEDAGÓGICO OBRIGATÓRIO: não ensinar ''novo sempre pressupõe algo anterior'' como regra universal — a leitura depende da construção concreta (contraste: ''carro novo'' tipicamente indica apenas ''não usado'', sem pressupor série); a formulação segura e contextualizada é ''o emprego de novos aplicado a recordes autoriza a leitura de que já havia recorde(s) anterior(es)''. NÚCLEO HISTÓRICO: formulação permitida — ''Nesta questão real do corpus, a Fundatec cobrou a interpretação de conteúdo implícito associado ao emprego contextual de novos recordes, cujo uso sinaliza a existência de recorde(s) anterior(es)'' — SEM afirmar recorrência, frequência ou padrão típico da Fundatec a partir de uma amostra de 1 questão. Categoria: A) regra conceitual. Enunciado, alternativas, gabarito, explicação, banca, concurso, ano, fonte e ativa NÃO alterados nesta curadoria (já corretos desde o saneamento).', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (4/4).
-- 234,235,236,878

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Implícitos e subentendidos: 4 questoes distintas
-- Total de vinculos esperados: 4 (4 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
