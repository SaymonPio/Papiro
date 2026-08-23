-- Mapa de classificacao semantica das questoes validas de Pontuação
-- (curso_conteudos.id = 16, assunto_id = 48,
-- materia_id = 6), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/pontuacao.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_pontuacao_teste_rollback.sql
--   classificar_questoes_unidades_pontuacao.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 16 (apos curadoria_unidades_pontuacao.sql):
--   U1 dca4fe2e-50e9-41db-abeb-0ef6b388c5af  ordem 1  Pontuação
--
-- Resultado da curadoria: 3/3 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (237, 'dca4fe2e-50e9-41db-abeb-0ef6b388c5af'::uuid, 1, 'Vírgula em oração adverbial deslocada/anteposta (cobertura suplementar; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca=''Papiro'', concurso=''PAPIRO - Estilo Fundatec - BM RS'', ano=2026) — material suplementar de prática, NÃO conta para incidência histórica, frequência Fundatec, recência ou ocorrência real em concurso; registrado como COBERTURA_SUPLEMENTAR_PONTUACAO. Regra testada: em ''Se chover, a prova será mantida'', a oração adverbial condicional ''Se chover'' está anteposta à oração principal, exigindo vírgula obrigatória; na ordem direta (''A prova será mantida se chover''), a vírgula seria facultativa. CAUTELA PEDAGÓGICA: não transformar essa formulação em regra absoluta desvinculada da estrutura — orações adverbiais antepostas ou intercaladas são tipicamente isoladas por vírgula, mas a decisão depende da posição, extensão e organização sintático-discursiva da construção específica, não apenas da ordem direta/indireta mecanicamente aplicada. Categoria: B) regra estrutural específica.', 'alta'),
    (238, 'dca4fe2e-50e9-41db-abeb-0ef6b388c5af'::uuid, 1, 'Vírgula em oração adjetiva explicativa × restritiva (cobertura suplementar; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca=''Papiro'', concurso=''PAPIRO - Estilo Fundatec - BM RS'', ano=2026) — material suplementar de prática, NÃO conta para incidência histórica; registrado como COBERTURA_SUPLEMENTAR_PONTUACAO. Regra testada: em ''João, que estudou muito, foi aprovado'', a oração adjetiva ''que estudou muito'' tem valor explicativo (agrega informação sobre o sujeito já identificado) e deve vir isolada por vírgulas de abertura e fechamento; a restritiva (''Os alunos que estudaram foram aprovados'') delimita o referente e não é isolada por vírgulas. CAUTELA PEDAGÓGICA: não reduzir a ''explicativa sempre leva duas vírgulas'' — o princípio é o ISOLAMENTO da oração explicativa; quando ela está no meio do período, há vírgula de abertura e fechamento, mas quando termina o período, a segunda delimitação pode ser feita pela pontuação terminal (ponto final, por exemplo), não necessariamente por uma segunda vírgula literal. Categoria: B) regra estrutural específica.', 'alta'),
    (239, 'dca4fe2e-50e9-41db-abeb-0ef6b388c5af'::uuid, 1, 'Estruturas que a vírgula não deve romper, em contraste com os casos obrigatórios (cobertura suplementar; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca=''Papiro'', concurso=''PAPIRO - Estilo Fundatec - BM RS'', ano=2026) — material suplementar de prática, NÃO conta para incidência histórica; registrado como COBERTURA_SUPLEMENTAR_PONTUACAO. Regra testada: a vírgula não separa sujeito de verbo, nem verbo de complemento, nem nome de adjunto adnominal/complemento nominal, em contraste com os casos em que ela é obrigatória (vocativo, aposto explicativo, oração adverbial deslocada, itens de enumeração). CAUTELA PEDAGÓGICA: não formular como ''existe vírgula entre sujeito e verbo = sempre erro'' — em ''O aluno, cansado, saiu.'', as vírgulas isolam um termo intercalado (aposto/aposição adjetiva), sem romper a relação direta entre sujeito e verbo; a formulação correta é ''não se rompe com vírgula a relação direta sujeito-verbo sem que exista estrutura intercalada que justifique a pontuação''. Categoria: D) contraste (regra negativa × casos obrigatórios de vírgula).', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (3/3).
-- 237,238,239

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Pontuação: 3 questoes distintas
-- Total de vinculos esperados: 3 (3 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
