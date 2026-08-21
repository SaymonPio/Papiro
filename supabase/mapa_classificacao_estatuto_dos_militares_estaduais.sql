-- Mapa de classificacao semantica das questoes validas de Estatuto dos Militares Estaduais
-- (curso_conteudos.id = 51, assunto_id = 18,
-- materia_id = 10), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/estatuto_dos_militares_estaduais.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_estatuto_dos_militares_estaduais_teste_rollback.sql
--   classificar_questoes_unidades_estatuto_dos_militares_estaduais.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 51 (apos curadoria_unidades_estatuto_dos_militares_estaduais.sql):
--   U1 bf13f365-3dd9-4d22-9ad7-f369a298eb19  ordem 1  Estatuto dos Militares Estaduais
--
-- Resultado da curadoria: 5/5 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (20, 'bf13f365-3dd9-4d22-9ad7-f369a298eb19'::uuid, 1, 'Hierarquia e disciplina', 'Gabarito: ''Bases institucionais da Brigada Militar'' — art. 12, caput (''A hierarquia e a disciplina militares são a base institucional da Brigada Militar''). Distratores genéricos sem correspondência normativa (criterios de promocao, regras facultativas, principios de formacao, normas so para oficiais). QUASE-DUPLICATA TEMATICA com Q300 (mesmo dispositivo, enunciado e distratores diferentes) e com a Q212 do curso_conteudo_id 64 (RDBM, art. 3o) — mesma ideia juridica em diploma distinto. Mantida por decisao do usuario.', 'alta'),
    (53, 'bf13f365-3dd9-4d22-9ad7-f369a298eb19'::uuid, 1, 'Carreira, regime de Juízes do TJM e precedência hierárquica', 'Questao INCORRETA: alt1 (verdadeira, servico policial-militar e seus encargos) art. 4o, caput. Alt2 (verdadeira, carreira privativa do pessoal da ativa) art. 5o, paragrafo unico. Alt3 (INCORRETA selecionada — real e ''regidos por legislacao propria'', nao pelo Estatuto) art. 8o, paragrafo unico. Alt4 (verdadeira, precedencia por antiguidade salvo excecoes funcionais) art. 15, caput. Alt5 (verdadeira, ativa tem precedencia sobre inatividade) art. 15, §3o.', 'alta'),
    (300, 'bf13f365-3dd9-4d22-9ad7-f369a298eb19'::uuid, 1, 'Hierarquia e disciplina', 'Gabarito: ''Bases institucionais da organização militar'' — art. 12, caput. Distratores genéricos sem correspondencia normativa (elementos sem efeito juridico, principios de direito privado, regras tributarias, direitos disponiveis). QUASE-DUPLICATA TEMATICA com Q20 (mesmo dispositivo, enunciado e distratores diferentes) e com a Q212 do curso_conteudo_id 64 (RDBM, art. 3o). Mantida por decisao do usuario.', 'alta'),
    (362, 'bf13f365-3dd9-4d22-9ad7-f369a298eb19'::uuid, 1, 'Direitos dos servidores militares', 'Questao EXCETO: alt1 (verdadeira, assistencia social e medico-hospitalar) art. 46, XIV. Alt2 (verdadeira, saude/higiene/seguranca do trabalho) art. 46, XV. Alt3 (verdadeira, transferencia para reserva remunerada ou reforma) art. 46, VII. Alt4 (EXCETO selecionada — real restringe a assistencia judiciaria gratuita a ''quando processado em razao de atos praticados em objeto de servico'', a alternativa amplia indevidamente para ''em qualquer hipotese... ou fora dele'') art. 46, XIII. Alt5 (verdadeira, ferias e licencas) art. 46, VIII.', 'alta'),
    (363, 'bf13f365-3dd9-4d22-9ad7-f369a298eb19'::uuid, 1, 'Violação de deveres e responsabilidade disciplinar', 'Assertiva I (verdadeira, violacao constitui crime/contravencao/transgressao disciplinar conforme legislacao/regulamentacao especificas) art. 35, caput. Assertiva II (falsa, invertida — real e ''independente'', nao ''subordinada'') art. 35, §2o. Assertiva III (verdadeira, inadimplemento de obrigacoes pecuniarias da vida privada nao caracteriza violacao) art. 35, §3o. Assertiva IV (verdadeira, inobservancia dos deveres acarreta responsabilidade funcional/pecuniaria/disciplinar/penal) art. 36, caput. Gabarito ''Apenas I, III e IV'' correto.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (5/5).
-- 20,53,300,362,363

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Estatuto dos Militares Estaduais: 5 questoes distintas
-- Total de vinculos esperados: 5 (5 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
