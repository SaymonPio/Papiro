-- Mapa de classificacao semantica das questoes validas de Redação oficial
-- (curso_conteudos.id = 30, assunto_id = 16,
-- materia_id = 6), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/redacao_oficial.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_redacao_oficial_teste_rollback.sql
--   classificar_questoes_unidades_redacao_oficial.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 30 (apos curadoria_unidades_redacao_oficial.sql):
--   U1 29bfb433-4013-4164-85de-fd847963199d  ordem 1  Redação oficial
--
-- Resultado da curadoria: 4/4 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (18, '29bfb433-4013-4164-85de-fd847963199d'::uuid, 1, 'Atributos/pilares da redação oficial (cobertura secundária/suplementar; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca=''Papiro - estilo Fundatec'', concurso=''Brigada Militar do Rio Grande do Sul'', ano e fonte ausentes — METADADO_PROVENIENCIA_INCOMPLETO_Q18, não preenchido por inferência) — material suplementar de prática, NÃO conta para incidência histórica, frequência Fundatec, recência ou ocorrência real em concurso. Regra testada: a comunicação administrativa deve priorizar clareza, objetividade e impessoalidade, em contraste com linguagem regional/subjetiva, períodos longos/vocabulário rebuscado, opiniões pessoais do redator e informalidade. RESSALVA PEDAGÓGICA APLICADA: o mnemônico ''C-P-O-C-I'' (Clareza, Precisão, Objetividade, Concisão, Impessoalidade) presente na explicação armazenada deve ser tratado como MNEMÔNICO PARCIAL, não como lista exaustiva — o MRPR e o Manual de Redação Oficial do Poder Executivo do RS listam também uniformidade, coesão, coerência, uso da norma culta, simplicidade, formalidade e padronização entre os atributos da redação oficial. Categoria: A) regra normativa/doutrinária.', 'alta'),
    (73, '29bfb433-4013-4164-85de-fd847963199d'::uuid, 1, 'Formatação do documento padrão ofício — assunto, introdução, fecho e assinatura (núcleo pré-edital primário — questão REAL)', 'Questão REAL (Fundatec, BM RS Soldado de Primeira Classe, 2025, Questão 10). Fidelidade confirmada byte a byte contra o caderno original da prova (mesmo exame de Q68/Q69, já recuperado nesta sessão). Regra testada: pede a alternativa INCORRETA sobre formatação padrão ofício segundo o MRPR 2018 — campo ''Assunto:'' deve ser síntese concisa com apenas a primeira letra maiúscula (não todas as palavras); introdução apresenta o objetivo quando não há encaminhamento, ou referencia o expediente solicitante quando há encaminhamento; fechos restritos a ''Respeitosamente'' (autoridade superior) e ''Atenciosamente'' (mesma hierarquia/inferior); nome do signatário em maiúsculas, sem negrito, sem linha de assinatura. ATENÇÃO À POLARIDADE: o gabarito (A) é a alternativa que diverge do MRPR — checado e confirmado, sem inversão indevida. Categoria: B) regra estrutural específica.', 'alta'),
    (117, '29bfb433-4013-4164-85de-fd847963199d'::uuid, 1, 'Comunicação administrativa, seus polos e impessoalidade (núcleo pré-edital primário — questão REAL)', 'Questão REAL (Fundatec, BM RS Soldado Nível III, 2022, Questão 09). Regra testada: (I) na redação oficial, quem comunica é sempre o serviço público, o assunto decorre de suas atribuições institucionais, e o destinatário pode ser público, entidade privada ou outro órgão público [correto]; (II) o nível de linguagem decorre do caráter público dos atos, exigindo clareza e objetividade [correto]; (III) a redação oficial também seria usada pela administração privada, sem necessidade de adequação [incorreto — é exclusiva da esfera pública e exige constante adequação à finalidade pública]. Gabarito: D (I e II). Não extrapolar a explicação além do que a doutrina/MRPR estabelece. Categoria: A) regra normativa/doutrinária.', 'alta'),
    (118, '29bfb433-4013-4164-85de-fd847963199d'::uuid, 1, 'Vocativo e pronome de tratamento para o Presidente da República (núcleo pré-edital primário — questão REAL)', 'Questão REAL (Fundatec, BM RS Soldado Nível III, 2022, Questão 10). Regra testada: (I) o vocativo ''Excelentíssimo Senhor Presidente da República'' é o correto — ''Nosso Caríssimo Presidente'' é fórmula afetiva vedada [correto]; (II) o pronome correto é ''Vossa Excelência'', não a fórmula inexistente ''Sua Excelentíssima Autoridade'' [incorreto]; (III) nem o vocativo nem o pronome do texto original estavam adequados [incorreto]. Gabarito: A (apenas I). AUDITORIA NORMATIVA DEDICADA REALIZADA antes da vinculação: verificado que o Decreto Federal nº 9.758/2019 (que estabelece ''senhor'' como pronome único) disciplina comunicações COM agentes públicos da administração pública federal e estabelece hipóteses específicas de não aplicação; o Manual de Redação Oficial do Poder Executivo do RS (2024) confirma expressamente esse âmbito federal, preserva a autonomia normativa dos demais entes federativos nos casos não abrangidos, e mantém em seus próprios quadros protocolares (posteriores ao decreto) as formas do MRPR — ''Excelentíssimo Senhor Presidente da República'' / ''Vossa Excelência'' — para este caso. Como o curso trata da Brigada Militar do RS (agente de ente federativo distinto do federal), a questão permanece normativamente correta e didaticamente segura dentro do âmbito efetivamente aplicável a este curso; a distinção MRPR × Decreto 9.758/2019 × Manual RS deve ser explicitamente ensinada na futura aula, sem apresentar o vocativo/pronome do MRPR como regra universal desvinculada da fonte e do âmbito normativo. Categoria: D) contraste (fórmulas inexistentes/vedadas).', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (4/4).
-- 18,73,117,118

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Redação oficial: 4 questoes distintas
-- Total de vinculos esperados: 4 (4 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
