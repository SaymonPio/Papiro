-- Mapa de classificacao semantica das questoes validas de Defesa do Estado e das Instituições Democráticas
-- (curso_conteudos.id = 48, assunto_id = 74,
-- materia_id = 10), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/defesa_do_estado_e_das_instituicoes_democraticas.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_defesa_do_estado_e_das_instituicoes_democraticas_teste_rollback.sql
--   classificar_questoes_unidades_defesa_do_estado_e_das_instituicoes_democraticas.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 48 (apos curadoria_unidades_defesa_do_estado_e_das_instituicoes_democraticas.sql):
--   U1 ecdb1d62-ef44-4407-b899-85911402bc90  ordem 1  Defesa do Estado e das Instituições Democráticas
--
-- Resultado da curadoria: 6/6 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (47, 'ecdb1d62-ef44-4407-b899-85911402bc90'::uuid, 1, 'Estado de defesa e estado de sítio', 'Questao INCORRETA: alt1 (verdadeira, prisao por crime contra o Estado comunicada ao juiz) art. 136, §3o, I. Alt2 (verdadeira, vedada incomunicabilidade) art. 136, §3o, IV. Alt3 (INCORRETA selecionada — real e ''prorrogado uma vez'', nao ''quantas vezes forem necessarias'') art. 136, §2o. Alt4 (verdadeira, decreto do estado de sitio) art. 138, caput. Alt5 (verdadeira, convocacao extraordinaria durante recesso) art. 138, §2o.', 'alta'),
    (113, 'ecdb1d62-ef44-4407-b899-85911402bc90'::uuid, 1, 'Estado de defesa e estado de sítio', 'Questao correta: alt1 (falsa — descreve estado de defesa rotulado como ''estado de sitio'') art. 136, caput. Alt2 (falsa — descreve estado de sitio rotulado como ''estado de defesa'') art. 137, I. Alt3 (gabarito, prisao por crime contra o Estado) art. 136, §3o, I. Alt4 (falsa — real e ''maioria absoluta'', nao ''tres quintos'') art. 136, §4o. Alt5 (falsa — mistura procedimento do estado de sitio com rotulo ''estado de defesa'' e quorum errado) art. 137, paragrafo unico.', 'alta'),
    (297, 'ecdb1d62-ef44-4407-b899-85911402bc90'::uuid, 1, 'Segurança pública', 'Seguranca publica e dever do Estado, direito e responsabilidade de todos — art. 144, caput. SOBREPOSICAO TEMATICA: mesma base normativa ja coberta no curso_conteudo_id 49 (Seguranca publica, questao 19) — nao e questao duplicada, mantida neste conteudo por decisao do usuario.', 'alta'),
    (654, 'ecdb1d62-ef44-4407-b899-85911402bc90'::uuid, 1, 'Conselho da República e Conselho de Defesa Nacional', 'Item I (verdadeiro, pronunciar-se sobre intervencao federal/estado de defesa/estado de sitio) art. 90, I. Item II (falso — essa competencia e do Conselho de Defesa Nacional, nao do Conselho da Republica) art. 91, §1o, II. Item III (verdadeiro, questoes relevantes para estabilidade das instituicoes democraticas) art. 90, II. NOTA CONSTITUCIONAL: arts. 89-91 pertencem ao Titulo IV (Organizacao dos Poderes, Capitulo II — Poder Executivo), NAO ao Titulo V. Questao mantida neste conteudo por relacao pedagogica com a defesa institucional, com a fonte normativa documentada como fora do Titulo V.', 'alta'),
    (655, 'ecdb1d62-ef44-4407-b899-85911402bc90'::uuid, 1, 'Forças Armadas', 'Questao correta: alt1 (falsa — eclesiasticos SAO isentos do servico militar obrigatorio em tempo de paz) art. 143, §2o. Alt2 (falsa — sindicalizacao e PROIBIDA ao militar) art. 142, §3o, IV. Alt3 (falsa — NAO cabe habeas corpus em relacao a punicoes disciplinares militares) art. 142, §2o. Alt4 (falsa — conviccao politica E imperativo de consciencia valido para servico alternativo) art. 143, §1o. Alt5 (gabarito, militar em servico ativo nao pode estar filiado a partidos politicos) art. 142, §3o, V.', 'alta'),
    (656, 'ecdb1d62-ef44-4407-b899-85911402bc90'::uuid, 1, 'Estado de defesa e estado de sítio', 'Questao correta: alt1 (falsa — oitiva dos Conselhos e obrigatoria) art. 136, caput. Alt2 (gabarito, restricao ao direito de reuniao ainda que no seio de associacoes) art. 136, §1o, I, alinea ''a''. Alt3 (falsa — pode ser prorrogado uma vez) art. 136, §2o. Alt4 (falsa — incomunicabilidade e vedada) art. 136, §3o, IV. Alt5 (falsa — locais devem ser restritos e determinados) art. 136, caput.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (6/6).
-- 47,113,297,654,655,656

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Defesa do Estado e das Instituições Democráticas: 6 questoes distintas
-- Total de vinculos esperados: 6 (6 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
