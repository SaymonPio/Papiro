-- Mapa de classificacao semantica das questoes validas de Crase
-- (curso_conteudos.id = 15, assunto_id = 5,
-- materia_id = 6), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/crase.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_crase_teste_rollback.sql
--   classificar_questoes_unidades_crase.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 15 (apos curadoria_unidades_crase.sql):
--   U1 57bf73b4-ca89-4809-bc8d-7bf1ae7fa4c2  ordem 1  Crase
--
-- Resultado da curadoria: 4/4 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (6, '57bf73b4-ca89-4809-bc8d-7bf1ae7fa4c2'::uuid, 1, '4 casos clássicos de crase proibida (origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca=''Papiro — estilo Fundatec'', concurso=''Guarda Municipal de Alvorada'', ano ausente) — material suplementar de prática, NÃO conta como incidência histórica real. Regra testada: ''à autoridade responsável'' tem crase (regência do verbo ''dirigir-se a'' + substantivo feminino definido); ''a pé'' sem crase (palavra masculina); ''frente a frente'' sem crase (palavras repetidas); ''a partir de'' sem crase (antes de infinitivo/locução verbal). Categoria: A) regra produtiva.', 'alta'),
    (70, '57bf73b4-ca89-4809-bc8d-7bf1ae7fa4c2'::uuid, 1, 'Crase por regência + substantivo feminino plural; locução fixa ''à tona''; ausência antes de infinitivo', 'Questão real (Fundatec, Brigada Militar RS - Soldado 1ª Classe/2025). Regra testada: ''às margens da lagoa'' tem crase (regência + substantivo feminino plural determinado); ''à tona'' tem crase (locução adverbial feminina cristalizada); ''a percorrer'' não tem crase (verbo no infinitivo, sem artigo feminino). Categoria: A) regra produtiva.', 'alta'),
    (115, '57bf73b4-ca89-4809-bc8d-7bf1ae7fa4c2'::uuid, 1, 'Crase por regência (singular/plural) e caso de atenção em substantivo abstrato (''à pressa'')', 'Questão real (Fundatec, Brigada Militar RS - Soldado Nível III/2022). Regra testada: 5 lacunas envolvendo regência + substantivo feminino definido (singular e plural) e ausência antes de infinitivo. NOTA PEDAGÓGICA: a lacuna ''à pressa'' não deve ser generalizada para ''todo substantivo abstrato feminino recebe crase'' — a conclusão vem da estrutura concreta da regência e da possibilidade de artigo naquele contexto específico, não da categoria genérica ''abstrato''. Categoria: D) contraste.', 'alta'),
    (328, '57bf73b4-ca89-4809-bc8d-7bf1ae7fa4c2'::uuid, 1, 'Crase por regência (linhas 17 e 19-20) e variação normativa em ''motor à combustão'' (linha 28) — texto já saneado no commit 79e9c97', 'Questão real (Fundatec, Corpo de Bombeiros Militar RS - Soldado 1ª Classe/2025). Texto-base e explicação JÁ SANEADOS separadamente (commit 79e9c97, não reaplicado aqui). Regra testada: ''à utilização de baldes'' (l.17) e ''à disciplina militar'' (l.19-20) têm crase por regência + substantivo feminino definido; ''à combustão'' (l.28, ''motor à combustão'') é ZONA DE VARIAÇÃO NORMATIVA — a Fundatec manteve essa forma no gabarito definitivo (fundamentado em Bechara, com Cegalla citado como fonte de facultatividade doutrinária para locuções adverbiais de meio/instrumento), sem que isso represente regra consolidada e universal da língua. Gabarito: D (à–à–à). Categoria: D) contraste.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (4/4).
-- 6,70,115,328

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Crase: 4 questoes distintas
-- Total de vinculos esperados: 4 (4 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
