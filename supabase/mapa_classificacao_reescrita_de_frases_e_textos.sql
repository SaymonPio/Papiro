-- Mapa de classificacao semantica das questoes validas de Reescrita de frases e textos
-- (curso_conteudos.id = 21, assunto_id = 49,
-- materia_id = 6), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/reescrita_de_frases_e_textos.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_reescrita_de_frases_e_textos_teste_rollback.sql
--   classificar_questoes_unidades_reescrita_de_frases_e_textos.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 21 (apos curadoria_unidades_reescrita_de_frases_e_textos.sql):
--   U1 5cc30e49-890f-4b83-b96f-31724024ee24  ordem 1  Reescrita de frases e textos
--
-- Resultado da curadoria: 2/2 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (72, '5cc30e49-890f-4b83-b96f-31724024ee24'::uuid, 1, 'Transposição de voz ativa para passiva analítica, período com orações coordenadas (núcleo pré-edital primário — questão REAL)', 'Questão REAL (Fundatec, BM RS Soldado de Primeira Classe, 2025, Questão 08). Fidelidade confirmada byte a byte contra o caderno original (comando, trecho citado e as 5 alternativas idênticos ao real) — a ausência da citação ''(l. 30-31)'' não é problema de fidelidade funcional, pois a frase necessária já está integralmente reproduzida entre aspas no próprio enunciado (precedente Q332). Nesta questão real do corpus, a Fundatec cobrou a transposição da voz ativa para a passiva, com preservação dos papéis semânticos e da estrutura temporal, em período com 3 orações coordenadas (''A tragédia nos arrancou pontes, levou casas e plantações, tirou vidas de entes queridos''). Regra testada: o sujeito agente (''a tragédia'') vira agente da passiva (''pela tragédia''); cada objeto direto vira sujeito paciente de sua respectiva oração (''pontes'', ''casas e plantações'', ''vidas de entes queridos''); o tempo verbal (pretérito perfeito) é mantido no auxiliar ''ser'' (''foram arrancadas/levadas/tiradas''). Auditoria alternativa-por-alternativa confirmou que todos os distratores falham por erro constitutivo da própria transposição de voz (inversão de agente/paciente, personificação absurda de ''pontes'', reflexividade indevida), não exigindo conhecimento independente de outro conteúdo. Gabarito: A. Categoria: B) regra estrutural composta.', 'alta'),
    (280, '5cc30e49-890f-4b83-b96f-31724024ee24'::uuid, 1, 'Transposição de voz ativa para passiva analítica, período simples (cobertura suplementar; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca=''Papiro'', concurso=''PAPIRO - Adaptada do padrão Fundatec 2025/2026'', 2026) — material suplementar de prática, NÃO conta para incidência histórica, frequência Fundatec, recência ou ocorrência real em concurso; registrado como COBERTURA_SUPLEMENTAR_REESCRITA_VOZ_PASSIVA, reforçando a mesma operação de Q72 em período simples (''Os policiais analisaram o relatório'' → ''O relatório foi analisado pelos policiais''). Regra testada: objeto direto (''o relatório'') vira sujeito paciente; auxiliar ''ser'' no mesmo tempo do verbo original (''analisaram'', pretérito perfeito → ''foi analisado''); particípio concordando com o sujeito paciente; agente da passiva introduzido por ''pelos policiais''. Auditoria alternativa-por-alternativa confirmou que os componentes (agente, sujeito paciente, tempo do auxiliar, concordância do particípio, compatibilidade entre voz passiva sintética e agente expresso) são constitutivos da própria habilidade de transposição de voz — nenhuma alternativa concorrente exige conhecimento independente de outro conteúdo para ser eliminada (todos os erros são inversão de papéis semânticos, incompatibilidade estrutural sintética-agente, ausência de transposição ou distorção de tempo/modo). Gabarito: A. Categoria: B) regra estrutural composta.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (2/2).
-- 72,280

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Reescrita de frases e textos: 2 questoes distintas
-- Total de vinculos esperados: 2 (2 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
