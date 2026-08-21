-- Mapa de classificacao semantica das questoes validas de Estatuto Estadual da Igualdade Racial
-- (curso_conteudos.id = 68, assunto_id = 63,
-- materia_id = 10), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/estatuto_estadual_da_igualdade_racial.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_estatuto_estadual_da_igualdade_racial_teste_rollback.sql
--   classificar_questoes_unidades_estatuto_estadual_da_igualdade_racial.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 68 (apos curadoria_unidades_estatuto_estadual_da_igualdade_racial.sql):
--   U1 f0f6bae6-df70-450a-b4ee-3d9747962c2e  ordem 1  Estatuto Estadual da Igualdade Racial
--
-- Resultado da curadoria: 10/10 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (132, 'f0f6bae6-df70-450a-b4ee-3d9747962c2e'::uuid, 1, 'Educação e cultura', 'Item I: quesito raca/autoclassificacao obrigatoria em registros administrativos — art. 18, caput. Item II: datas comemorativas civicas — art. 11, caput. Item III (falso): troca capoeira por Kuduro — art. 14, caput (a participacao facultada dos mestres esta correta na alternativa; a falsidade e so a troca do nome da atividade). DUPLICATA de 852.', 'alta'),
    (136, 'f0f6bae6-df70-450a-b4ee-3d9747962c2e'::uuid, 1, 'Mercado de trabalho', 'Itens I e II: politicas afirmativas para cargos publicos e iniciativa privada — art. 17, caput. Item III: formacao profissional/emprego/geracao de renda — art. 17, paragrafo unico. DUPLICATA de 851.', 'alta'),
    (301, 'f0f6bae6-df70-450a-b4ee-3d9747962c2e'::uuid, 1, 'Objeto geral e definições', 'Objeto da lei: igualdade racial e combate a discriminacao — art. 1º, caput.', 'alta'),
    (365, 'f0f6bae6-df70-450a-b4ee-3d9747962c2e'::uuid, 1, 'Objeto geral e definições', 'Definicao de discriminacao racial (distincao/exclusao/restricao baseada em raca/cor/descendencia/origem nacional ou etnica) — art. 1º, §1º.', 'alta'),
    (366, 'f0f6bae6-df70-450a-b4ee-3d9747962c2e'::uuid, 1, 'Mercado de trabalho', 'Formacao profissional, emprego e geracao de renda para enfrentar desigualdade de oportunidades — art. 17, paragrafo unico.', 'alta'),
    (367, 'f0f6bae6-df70-450a-b4ee-3d9747962c2e'::uuid, 1, 'Saúde, educação e cultura', 'Questao INCORRETA, cada alternativa testa um dispositivo: alt1 (falsa, saude/doencas geneticamente determinadas) art. 4º, caput; alt2 (INCORRETA selecionada — capoeira com participacao ''obrigatoria'', quando o texto real diz ''facultada'') art. 14, caput; alt3 (falsa, saude de quilombolas) art. 5º, paragrafo unico; alt4 (falsa, ensino gratuito/atividades esportivas/apoio a entidades) art. 10, caput; alt5 (falsa, diversidade racial em debates — contem residuo de raspagem de dados sobre Decreto 43.245/2004, Regulamento Disciplinar da Brigada Militar, colado ao final do texto, documentado mas nao editado) art. 12, caput.', 'alta'),
    (798, 'f0f6bae6-df70-450a-b4ee-3d9747962c2e'::uuid, 1, 'Educação e cultura', 'Questao INCORRETO: item1 (verdadeiro, Hip-Hop) art. 16, caput; item2 (verdadeiro, nucleos de pesquisa pos-graduacao) art. 7º, II; item3 (INCORRETO selecionado — troca ''desigualdade'' por ''igualdade'' de oportunidades) art. 17, paragrafo unico; item4 (verdadeiro, literatura negra) art. 13, caput; item5 (verdadeiro, ensino Medio/Tecnico/Superior) art. 15, caput.', 'alta'),
    (850, 'f0f6bae6-df70-450a-b4ee-3d9747962c2e'::uuid, 1, 'Educação e cultura', 'Item I: literatura negra — art. 13, caput. Item II: ensino Medio/Tecnico/Superior — art. 15, caput. Item III: campanhas publicitarias e percentual de afrodescendentes conforme censo IBGE — art. 20, caput.', 'alta'),
    (851, 'f0f6bae6-df70-450a-b4ee-3d9747962c2e'::uuid, 1, 'Mercado de trabalho', 'Itens I e II: politicas afirmativas para cargos publicos e iniciativa privada — art. 17, caput. Item III: formacao profissional/emprego/geracao de renda — art. 17, paragrafo unico. DUPLICATA de 136.', 'alta'),
    (852, 'f0f6bae6-df70-450a-b4ee-3d9747962c2e'::uuid, 1, 'Educação e cultura', 'Item I: quesito raca/autoclassificacao obrigatoria em registros administrativos — art. 18, caput. Item II: datas comemorativas civicas — art. 11, caput. Item III (falso): troca capoeira por Kuduro — art. 14, caput. DUPLICATA de 132.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (10/10).
-- 132,136,301,365,366,367,798,850,851,852

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Estatuto Estadual da Igualdade Racial: 10 questoes distintas
-- Total de vinculos esperados: 10 (10 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
