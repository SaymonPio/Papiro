-- Mapa de classificacao semantica das questoes validas de Segurança pública
-- (curso_conteudos.id = 49, assunto_id = 17,
-- materia_id = 10), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/seguranca_publica.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_seguranca_publica_teste_rollback.sql
--   classificar_questoes_unidades_seguranca_publica.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 49 (apos curadoria_unidades_seguranca_publica.sql):
--   U1 7cc8a187-da9b-457d-beeb-f496ddd32580  ordem 1  Segurança pública
--
-- Resultado da curadoria: 9/9 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (19, '7cc8a187-da9b-457d-beeb-f496ddd32580'::uuid, 1, 'Segurança pública (CF, art. 144)', 'Preservacao da ordem publica e da incolumidade das pessoas e do patrimonio — CF, art. 144, caput.', 'alta'),
    (38, '7cc8a187-da9b-457d-beeb-f496ddd32580'::uuid, 1, 'Segurança pública (CF, art. 144)', 'Questao INCORRETA: alt1 (verdadeira) CF art.144 §5º-A; alt2 (verdadeira) §4º; alt3 (verdadeira) §5º; alt4 (INCORRETA selecionada — diz ''lei complementar'', mas o texto constitucional exige apenas ''lei'') §7º; alt5 (verdadeira) §8º.', 'alta'),
    (41, '7cc8a187-da9b-457d-beeb-f496ddd32580'::uuid, 1, 'Segurança pública (CF, art. 144)', 'Questao EXCETO: alt1 (PF/PRF/PFF) incisos I/II/III; alt2 (policias civis) inciso IV; alt3 (policias militares) parte do inciso V; alt4 (EXCETO selecionada — ''corpos de bombeiros civis'' nao existe, o inciso V fala em corpos de bombeiros MILITARES) inciso V; alt5 (policias penais) inciso VI. Testa o caput e todos os incisos.', 'alta'),
    (675, '7cc8a187-da9b-457d-beeb-f496ddd32580'::uuid, 1, 'Segurança pública — questão híbrida CF/CE-RS', 'QUESTAO HIBRIDA: item I (dever do Estado, preservacao da ordem publica) e CF, art. 144, caput. Item II (Policia Civil, apuracao de infracoes penais, ressalvadas as militares) e CF, art. 144, §4º. Item III (Conselhos de Defesa e Seguranca da Comunidade como via de participacao da sociedade) NAO e da Constituicao Federal — e da Constituicao do Estado do Rio Grande do Sul, art. 126, caput (''A sociedade participara, atraves dos Conselhos de Defesa e Seguranca da Comunidade, no encaminhamento e solucao dos problemas atinentes a seguranca publica, na forma da lei.''). Os tres itens sao dados como corretos pelo gabarito (I, II e III).', 'alta'),
    (676, '7cc8a187-da9b-457d-beeb-f496ddd32580'::uuid, 1, 'Segurança pública (CF, art. 144)', 'Guarda Municipal, orgao para protecao de bens/servicos/instalacoes dos municipios — CF, art. 144, §8º.', 'alta'),
    (677, '7cc8a187-da9b-457d-beeb-f496ddd32580'::uuid, 1, 'Segurança pública (CF, art. 144)', 'Gabarito (alt1, PF prevenir/reprimir trafico de entorpecentes) CF art.144 §1º, II. Alt2 (distrator, PC apuraria infracoes penais militares — invertido) §4º. Alt3 (distrator, PF exerceria ''concorrentemente'' funcoes de policia judiciaria da Uniao — real e ''com exclusividade'') §1º, IV. Alt4 (distrator, PM ''nao se subordinam'' aos Governadores — invertido) §6º. Alt5 (distrator, funde atribuicoes de PM e CBM) §5º.', 'alta'),
    (678, '7cc8a187-da9b-457d-beeb-f496ddd32580'::uuid, 1, 'Segurança pública (CF, art. 144)', 'Questao ''NAO indica um orgao'': alt1 (PM) inciso V; alt2 (PC) inciso IV; alt3 (selecionada — ''policia ferroviaria ESTADUAL'' nao existe, so a federal, inciso III) inciso III; alt4 (CBM) inciso V; alt5 (policia penal distrital) inciso VI.', 'alta'),
    (743, '7cc8a187-da9b-457d-beeb-f496ddd32580'::uuid, 1, 'Segurança pública (CF, art. 144) — jurisprudência STF/STJ', 'Item I (verdadeiro — jurisprudencia STF/STJ: rol do art.144 nao e taxativo, Guardas Municipais podem exercer policiamento ostensivo comunitario, excluida policia judiciaria) CF art.144 §8º. Item II (verdadeiro — jurisprudencia: funcao investigativa residual da Policia Civil) §4º. Item III (falso — as policias penais tem atribuicao constitucional de ''seguranca'' dos estabelecimentos penais, nao de ''administracao''; a palavra extra torna o item falso) §5º-A.', 'alta'),
    (805, '7cc8a187-da9b-457d-beeb-f496ddd32580'::uuid, 1, 'Segurança pública (CF, art. 144)', 'Competencia de instituir guardas municipais cabe ao Governo Municipal — CF, art. 144, §8º.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (9/9).
-- 19,38,41,675,676,677,678,743,805

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Segurança pública: 9 questoes distintas
-- Total de vinculos esperados: 9 (9 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
