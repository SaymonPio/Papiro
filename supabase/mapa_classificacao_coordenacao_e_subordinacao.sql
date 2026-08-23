-- Mapa de classificacao semantica das questoes validas de Coordenação e subordinação
-- (curso_conteudos.id = 28, assunto_id = 50,
-- materia_id = 6), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/coordenacao_e_subordinacao.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_coordenacao_e_subordinacao_teste_rollback.sql
--   classificar_questoes_unidades_coordenacao_e_subordinacao.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 28 (apos curadoria_unidades_coordenacao_e_subordinacao.sql):
--   U1 bfeaf283-09fc-4f14-9d0c-41ff0db4eab7  ordem 1  Coordenação e subordinação
--
-- Resultado da curadoria: 3/3 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (225, 'bfeaf283-09fc-4f14-9d0c-41ff0db4eab7'::uuid, 1, 'Eixo 1 — Coordenação sindética adversativa (cobertura suplementar; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca=''Papiro'', concurso=''PAPIRO - Estilo Fundatec - BM RS'', ano=2026) — material suplementar de prática, NÃO conta para incidência histórica, frequência Fundatec, recência ou ocorrência real em concurso; registrado como COBERTURA_SUPLEMENTAR_COORDENACAO_E_SUBORDINACAO. Fenômeno testado: em ''Estudou bastante, mas não conseguiu a aprovação'', as duas orações são sintaticamente independentes (coordenação); a segunda é introduzida pelo conectivo ''mas'' (síndeto expresso), com valor semântico de oposição/contraste em relação à primeira — ORAÇÃO COORDENADA SINDÉTICA ADVERSATIVA (gabarito A). Ensino em duas etapas: (1) reconhecer a relação de coordenação; (2) reconhecer o valor semântico adversativo do conectivo — não apenas o algoritmo mecânico ''viu MAS = adversativa'' sem analisar a relação entre as orações. Categoria: A) regra conceitual. Explicação armazenada NÃO alterada nesta curadoria.', 'alta'),
    (226, 'bfeaf283-09fc-4f14-9d0c-41ff0db4eab7'::uuid, 1, 'Eixo 2 — Subordinação adverbial temporal (cobertura suplementar; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca=''Papiro'', concurso=''PAPIRO - Estilo Fundatec - BM RS'', ano=2026) — material suplementar de prática, NÃO conta para incidência histórica; registrado como COBERTURA_SUPLEMENTAR_COORDENACAO_E_SUBORDINACAO. Fenômeno testado: em ''Quando o edital sair, intensificaremos os estudos'', a oração introduzida pela conjunção subordinativa ''quando'' expressa a circunstância temporal em que ocorrerá a ação da oração principal — ORAÇÃO SUBORDINADA ADVERBIAL TEMPORAL (gabarito A). CAUTELA PEDAGÓGICA: não tratar ''quando = sempre temporal'' como regra absoluta — dependendo da construção concreta, conectivos podem assumir valores contextuais menos prototípicos; a classificação depende sempre da relação semântica efetiva no período, não de memorização mecânica do conectivo isolado. Categoria: A) regra conceitual. Explicação armazenada NÃO alterada nesta curadoria.', 'alta'),
    (227, 'bfeaf283-09fc-4f14-9d0c-41ff0db4eab7'::uuid, 1, 'Eixo 3 — Subordinação adverbial concessiva (cobertura suplementar; origem=AUTORAL_PAPIRO; mesma frase-base de Q279/Conectores, não duplicata)', 'ORIGEM: AUTORAL_PAPIRO (banca=''Papiro'', concurso=''PAPIRO - Estilo Fundatec - BM RS'', ano=2026) — material suplementar de prática, NÃO conta para incidência histórica; registrado como COBERTURA_SUPLEMENTAR_COORDENACAO_E_SUBORDINACAO. Fenômeno testado: em ''Embora estivesse cansado, continuou estudando'', a conjunção ''embora'' introduz uma ORAÇÃO SUBORDINADA ADVERBIAL CONCESSIVA — circunstância que apresenta um obstáculo/ressalva que NÃO impede a realização do fato expresso na oração principal (gabarito A: concessão). Distinguir de causa (que explicaria por que o fato ocorreu) — a concessão apresenta uma circunstância que poderia contrariar o esperado, mas não impede o fato principal. NÃO É DUPLICATA de Q279 (já classificada em Conectores, curso_conteudo_id 14, commit bed8641), embora compartilhe a mesma frase-exemplo: Q279 testa reconhecimento de equivalência semântica via reescrita (5 alternativas reescritas, foco no valor lógico-semântico do conectivo isolado); Q227 testa diretamente a classificação da oração como um todo dentro do período composto, sem nenhuma tarefa de reescrita — habilidades nucleares diferentes decidem taxonomias diferentes, não a frase-exemplo compartilhada. Categoria: A) regra conceitual. Explicação armazenada NÃO alterada nesta curadoria.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (3/3).
-- 225,226,227

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Coordenação e subordinação: 3 questoes distintas
-- Total de vinculos esperados: 3 (3 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
