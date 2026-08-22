-- Mapa de classificacao semantica das questoes validas de Coesão textual
-- (curso_conteudos.id = 13, assunto_id = 55,
-- materia_id = 6), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/coesao_textual.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_coesao_textual_teste_rollback.sql
--   classificar_questoes_unidades_coesao_textual.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 13 (apos curadoria_unidades_coesao_textual.sql):
--   U1 29a4bec1-2c3a-40f3-a86f-fa6bda25d04f  ordem 1  Coesão textual
--
-- Resultado da curadoria: 7/7 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (69, '29a4bec1-2c3a-40f3-a86f-fa6bda25d04f'::uuid, 1, 'Retomada pronominal em texto real: ''seus'', ''que'', ''se'' (eixo: coesão referencial)', 'Questão real (Fundatec, Brigada Militar RS - Soldado 1ª Classe/2025). Usa o texto-base já restaurado com marcadores [NN] (saneamento controlado, commit 51e5851) e a explicação já corrigida (par correto de assertivas verdadeiras: 2 e 3). Regra testada: ''seus'' (l.08) possui apenas ''cursos'', retomando ''rios'' — não estabelece relação com ''cidades'' (assertiva 1 falsa); ''que'' (l.12) retoma ''heróis anônimos'', confirmado pela concordância verbal de ''brotam'' (assertiva 2 verdadeira); ''heróis anônimos'' e ''seres humanos iluminados'' são correferentes (assertiva 3 verdadeira); ''se'' (l.26) é reflexivo e concorda com o sujeito ''a natureza'', não com ''homem'' (assertiva 4 falsa). Gabarito: C (soma 2+3=05). Categoria: D) contraste.', 'alta'),
    (275, '29a4bec1-2c3a-40f3-a86f-fa6bda25d04f'::uuid, 1, 'Definição de coesão referencial (origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca=''Papiro'', concurso=''PAPIRO - Adaptada do padrão Fundatec 2025/2026'', 2026) — material suplementar introdutório, NÃO conta como incidência histórica real. Regra testada: o emprego de pronomes para retomar termos anteriormente mencionados constitui coesão referencial, em contraste com ambiguidade, pontuação expressiva, derivação lexical e concordância nominal. Categoria: E) habilidade semântica/interpretativa (definição conceitual).', 'alta'),
    (276, '29a4bec1-2c3a-40f3-a86f-fa6bda25d04f'::uuid, 1, 'Conectivo ''portanto'' = valor conclusivo (subtópico: coesão sequencial; origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO — material suplementar introdutório de coesão sequencial, NÃO conta como incidência histórica real. Regra testada: ''portanto'' estabelece relação de conclusão, em contraste com oposição, causa, condição e concessão. Subtópico secundário desta unidade (não aprofundado — o aprofundamento de conectivos fica reservado ao conteúdo dedicado ''Conectores'', curso_conteudo_id 14, assunto_id 57, ainda pendente). Categoria: A) regra produtiva.', 'alta'),
    (319, '29a4bec1-2c3a-40f3-a86f-fa6bda25d04f'::uuid, 1, 'Pronome relativo ''cujos'' — retomada do possuidor antecedente (questão CANÔNICA)', 'Questão real (Fundatec, GM Gravataí/RS/2025-2026). CANÔNICA: idêntica byte a byte (enunciado, alternativas, gabarito, confirmado por hash SHA-256) a Q684, que permanece ativa e intacta mas sem vínculo em Classes de palavras (conteúdo 22, já concluído, saneamento controlado commit 51e5851, DUPLICATA_EXATA_DE_Q319 — não tocada novamente aqui). Regra testada: ''cujos'' introduz relação possessiva, retomando semanticamente o possuidor antecedente (''adolescentes'') e concordando com o elemento possuído subsequente (''relógios biológicos'') — nunca o inverso. Categoria: A) regra produtiva.', 'alta'),
    (324, '29a4bec1-2c3a-40f3-a86f-fa6bda25d04f'::uuid, 1, 'Anáfora, pronome relativo preposicionado e retomada pronominal em ''O avesso da pele''', 'Questão real (Fundatec, GM Esteio/RS/2022). Usa o texto-base já restaurado com marcadores [NN] (saneamento controlado, commit 51e5851). Regra testada: ''esse filho adulto'' (l.17) refere-se ao próprio narrador (Pedro) em relação a seus pais, não a um filho de Pedro (assertiva I falsa); ''em que'' (l.22) é substituível por ''no qual/na qual'' (assertiva II correta — NOTA TÉCNICA, não alterada no enunciado original: o antecedente ''comunidade'' é feminino, exigindo rigorosamente ''na qual'', mas a própria banca escreveu ''no qual''; a formulação da banca é preservada como está, sem correção do texto da prova); ''delas'' (l.32) retoma ''suposições'' (l.30) (assertiva III correta). Gabarito: E (Apenas II e III). Categoria: D) contraste.', 'alta'),
    (333, '29a4bec1-2c3a-40f3-a86f-fa6bda25d04f'::uuid, 1, 'Pronome relativo e anáfora sintetizadora em texto sobre história dos bombeiros', 'Questão real (Fundatec, Corpo de Bombeiros Militar RS - Soldado 1ª Classe/2025). Usa o texto-base já restaurado com marcadores [NN] (saneamento controlado, commit 51e5851). Regra testada: ''que'' (l.10) tem como referente ''máquinas hidráulicas'', não ''regiões'' (assertiva I falsa); ''Essas novas ferramentas'' (l.17) sintetiza e retoma ''bombas de incêndio'' (l.12) e ''primeira mangueira de combate a incêndio'' (l.14-15) — expressão anafórica sintetizadora, retomando mais de uma informação anterior (assertiva II correta); ''alcance vertical de até 36 m'' (l.25) refere-se a ''bombas manuais'', mesma linha (assertiva III correta). Gabarito: D (Apenas II e III). Categoria: D) contraste.', 'alta'),
    (683, '29a4bec1-2c3a-40f3-a86f-fa6bda25d04f'::uuid, 1, 'Reiteração lexical e anáfora pronominal em ''A finalidade da sociedade e o bem comum''', 'Questão real (Fundatec, Esc Pol PC-RS/2026). Usa assunto_id já corrigido para 55 (saneamento controlado, commit 51e5851 — antes classificada sob assunto_id=47, Classes de palavras, onde permanecia excluída por FORA_DE_ESCOPO_REFERENCIA_TEXTUAL). Regra testada: reiteração lexical de ''bem comum'' ao longo do primeiro parágrafo (mecanismo legítimo de manutenção do tópico, não defeito textual); anáfora pronominal de ''Ele'' (3º parágrafo) retomando ''bem comum'' (período anterior). Categoria: A) regra produtiva.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (7/7).
-- 69,275,276,319,324,333,683

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Coesão textual: 7 questoes distintas
-- Total de vinculos esperados: 7 (7 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
