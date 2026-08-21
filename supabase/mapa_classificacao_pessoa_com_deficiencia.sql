-- Mapa de classificacao semantica das questoes validas de Pessoa com deficiência
-- (curso_conteudos.id = 71, assunto_id = 27,
-- materia_id = 11), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/pessoa_com_deficiencia.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_pessoa_com_deficiencia_teste_rollback.sql
--   classificar_questoes_unidades_pessoa_com_deficiencia.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 71 (apos curadoria_unidades_pessoa_com_deficiencia.sql):
--   U1 435543fe-bdc2-452a-be2d-ffa414c5e27d  ordem 1  Pessoa com deficiência
--
-- Resultado da curadoria: 8/8 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (30, '435543fe-bdc2-452a-be2d-ffa414c5e27d'::uuid, 1, 'Definição de adaptação razoável', 'Gabarito: ''Adaptacao razoavel'' — Convencao sobre os Direitos das Pessoas com Deficiencia, art. 2 (''Adaptacao razoavel significa as modificacoes e os ajustes necessarios e adequados que nao acarretem onus desproporcional ou indevido, quando requeridos em cada caso, a fim de assegurar que as pessoas com deficiencia possam gozar ou exercer... todos os direitos humanos e liberdades fundamentais''). Distratores sem correspondencia (curatela obrigatoria, segregacao protetiva, capacidade condicionada, acessibilidade facultativa).', 'alta'),
    (55, '435543fe-bdc2-452a-be2d-ffa414c5e27d'::uuid, 1, 'Definições e direitos substantivos da Convenção', 'Questao INCORRETA: alt1 (INCORRETA selecionada, gabarito — o texto e literalmente a definicao de ''DESENHO UNIVERSAL'' (''concepcao de produtos, ambientes, programas e servicos... sem necessidade de adaptacao ou projeto especifico''), rotulado erroneamente como ''adaptacao razoavel'') art. 2. Alt2 (verdadeira, copia literal da definicao de ''discriminacao por motivo de deficiencia'') art. 2. Alt3 (verdadeira, copia literal — ''os Estados Partes adotarao todas as medidas apropriadas para garantir que a adaptacao razoavel seja oferecida'') art. 5, item 3. Alt4 (verdadeira, copia literal sobre protecao da integridade fisica e mental) art. 17. Alt5 (verdadeira, parafrase sobre participacao na vida cultural) art. 30, item 1.', 'alta'),
    (141, '435543fe-bdc2-452a-be2d-ffa414c5e27d'::uuid, 1, 'Crimes em razão da deficiência — Lei 7.853/1989, art. 8º', 'Item I (verdadeiro, copia literal — ''negar ou obstar emprego, trabalho ou promocao a pessoa em razao de sua deficiencia'') art. 8o, III (redacao vigente pos-Lei 13.146/2015). Item II (verdadeiro, copia literal sobre recusa/cobranca adicional/suspensao de inscricao escolar) art. 8o, I. Item III (verdadeiro, copia literal sobre obstar inscricao em concurso publico ou acesso a cargo/emprego publico) art. 8o, II. Gabarito ''V-V-V'' confere. QUASE-DUPLICATA da Q827 (mesmos 3 itens, mesmo fundamento, mesmo resultado juridico, comando redigido de forma ligeiramente diferente) — mantida classificada, saneamento de duplicidade fica para etapa propria.', 'alta'),
    (352, '435543fe-bdc2-452a-be2d-ffa414c5e27d'::uuid, 1, 'Proteção contra exploração, violência e abuso', 'Questao INCORRETA: alt1 (verdadeira, copia literal sobre medidas legislativas/administrativas/sociais/educacionais de protecao) art. 16, item 1. Alt2 (INCORRETA selecionada, gabarito — real e ''monitorados por autoridades INDEPENDENTES'', a alternativa diz ''autoridades publicas vinculadas ao Poder Executivo'', justamente o oposto do proposito da norma) art. 16, item 3. Alt3 (verdadeira, copia literal sobre leis e politicas efetivas para investigacao/julgamento de casos) art. 16, item 5. Alt4 (verdadeira, copia literal — primeira parte — sobre recuperacao fisica/cognitiva/psicologica) art. 16, item 4. Alt5 (verdadeira, copia literal — segunda parte — sobre ambientes de recuperacao e reinsercao) art. 16, item 4.', 'alta'),
    (353, '435543fe-bdc2-452a-be2d-ffa414c5e27d'::uuid, 1, 'Protocolo Facultativo — sistema de comunicações ao Comitê', 'Questao INCORRETA sobre o PROTOCOLO FACULTATIVO (numeracao propria, distinta da Convencao — NAO inserida em artigos_esperados por ambiguidade estrutural do parser, documentada apenas aqui). Alt1 (INCORRETA selecionada, gabarito — real e ''sessoes FECHADAS'', a alternativa diz ''sessoes abertas'') Protocolo Facultativo, art. 5. Alt2 (verdadeira, copia literal sobre reconhecimento da competencia do Comite para receber comunicacoes) Protocolo Facultativo, art. 1, item 1. Alt3 (verdadeira, copia literal — inadmissibilidade por comunicacao anonima) Protocolo Facultativo, art. 2, alinea ''a''. Alt4 (verdadeira, copia literal sobre medidas de natureza cautelar) Protocolo Facultativo, art. 4, item 1. Alt5 (verdadeira, copia literal — segunda frase do mesmo art. 5 do alt1 — sobre envio de sugestoes e recomendacoes ao Estado Parte e ao requerente) Protocolo Facultativo, art. 5.', 'alta'),
    (827, '435543fe-bdc2-452a-be2d-ffa414c5e27d'::uuid, 1, 'Crimes em razão da deficiência — Lei 7.853/1989, art. 8º', 'Identica em conteudo a Q141 (mesmos 3 itens, mesmo fundamento) — QUASE-DUPLICATA, mantida classificada, saneamento de duplicidade fica para etapa propria. Item 1 (verdadeiro) art. 8o, III. Item 2 (verdadeiro) art. 8o, I. Item 3 (verdadeiro) art. 8o, II. Gabarito ''V-V-V'' confere.', 'alta'),
    (828, '435543fe-bdc2-452a-be2d-ffa414c5e27d'::uuid, 1, 'Direitos básicos e medidas na área da saúde — Lei 7.853/1989, art. 2º', 'Item I (verdadeiro, copia literal — nao alterado pela Lei 15.155/2025 — sobre desenvolvimento de programas de saude com participacao da sociedade e integracao social) art. 2o, paragrafo unico, II, ''f''. Item II (verdadeiro, MAS com terminologia ANTERIOR a Lei 15.155/2025 — a assertiva usa ''pessoas portadoras de deficiencia'', enquanto a redacao vigente pos-2025 usa ''pessoas com deficiencia'' — mudanca apenas terminologica, sem alteracao substantiva do direito de acesso a estabelecimentos de saude publicos e privados) art. 2o, paragrafo unico, II, ''d''. Item III (verdadeiro, copia literal — nao alterado pela Lei 15.155/2025 — sobre programas de prevencao de acidente de trabalho/transito) art. 2o, paragrafo unico, II, ''b''. Gabarito ''I, II e III'' confere, materialmente correto apesar da desatualizacao textual pontual do item II.', 'alta'),
    (829, '435543fe-bdc2-452a-be2d-ffa414c5e27d'::uuid, 1, 'Crimes em razão da deficiência — Lei 7.853/1989, art. 8º', 'Item I (verdadeiro, copia literal — recusar/retardar/dificultar internacao ou deixar de prestar assistencia medico-hospitalar e ambulatorial) art. 8o, IV (redacao vigente pos-Lei 13.146/2015). Item II (verdadeiro, copia literal — recusar/retardar/omitir dados tecnicos indispensaveis a acao civil publica) art. 8o, VI. Item III (verdadeiro, copia literal — impedir ou dificultar ingresso em planos privados de assistencia a saude, inclusive com cobranca de valores diferenciados) art. 8o, §3o (incluido pela Lei 13.146/2015). Gabarito ''I, II e III'' confere.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (8/8).
-- 30,55,141,352,353,827,828,829

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Pessoa com deficiência: 8 questoes distintas
-- Total de vinculos esperados: 8 (8 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
