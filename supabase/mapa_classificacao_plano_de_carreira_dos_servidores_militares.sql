-- Mapa de classificacao semantica das questoes validas de Plano de Carreira dos Servidores Militares
-- (curso_conteudos.id = 65, assunto_id = 77,
-- materia_id = 10), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/plano_de_carreira_dos_servidores_militares.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_plano_de_carreira_dos_servidores_militares_teste_rollback.sql
--   classificar_questoes_unidades_plano_de_carreira_dos_servidores_militares.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 65 (apos curadoria_unidades_plano_de_carreira_dos_servidores_militares.sql):
--   U1 9f8a76ec-2c8c-4bd8-9d72-9ecb7218a200  ordem 1  Plano de Carreira dos Servidores Militares
--
-- Resultado da curadoria: 4/4 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (201, '9f8a76ec-2c8c-4bd8-9d72-9ecb7218a200'::uuid, 1, 'Progressão funcional (genérico)', 'Gabarito: ''Os requisitos e criterios previstos na legislacao especifica'' — afirmacao generica sobre sujeicao a legislacao especifica, fundamento geral na LC Estadual no 10.992/1997, sem dispositivo numerado especifico testado. Distratores sem correspondencia (apenas vontade do servidor, promocao automatica diaria, dispensa de qualquer requisito, criterio exclusivamente politico).', 'alta'),
    (202, '9f8a76ec-2c8c-4bd8-9d72-9ecb7218a200'::uuid, 1, 'Plano de carreira (genérico)', 'Gabarito: ''Desenvolvimento funcional e progressao na carreira'' — afirmacao generica sobre o objeto do plano de carreira, fundamento geral na LC Estadual no 10.992/1997, sem dispositivo numerado especifico testado. Distratores sem correspondencia (somente regras eleitorais, apenas tributos, organizacao do Poder Judiciario, somente contratos privados).', 'alta'),
    (203, '9f8a76ec-2c8c-4bd8-9d72-9ecb7218a200'::uuid, 1, 'Promoção (genérico)', 'Gabarito: ''Esta sujeita a legislacao especifica e aos criterios nela estabelecidos'' — afirmacao generica sobre a promocao, fundamento geral na LC Estadual no 10.992/1997, sem dispositivo numerado especifico testado. Distratores sem correspondencia (direito automatico sem condicoes, depende exclusivamente de eleicao popular, concedida por empresa privada, sem disciplina legal).', 'alta'),
    (364, '9f8a76ec-2c8c-4bd8-9d72-9ecb7218a200'::uuid, 1, 'Estrutura da carreira QOEM/QOES: ingresso e promoção', 'Questao INCORRETA: alt1 (verdadeira, ingresso no Curso Superior de Policia Militar mediante concurso publico de provas e titulos com exigencia de diplomacao em Ciencias Juridicas e Sociais) art. 3o, §1o. Alt2 (INCORRETA selecionada — real e ''podera ser recusada'', nao ''nao podera ser recusada'', pelo servidor a inclusao no quadro de acesso a Coronel) art. 2o, §2o. Alt3 (verdadeira, aprovados no concurso publico, enquanto cursando o Curso Superior de PM de ate 2 anos, sao Alunos-Oficiais) art. 3o, §2o. Alt4 (verdadeira, promocao a Major exige 3 anos em orgao de execucao e conclusao do CAAPM) art. 5o, §1o. Alt5 (verdadeira, promocao a Coronel exige conclusao do CEPGSP) art. 5o, §2o. MICROCHECAGEM DE VIGENCIA: confirmado em versao oficial consolidada (atualizada ate LC 15.454/2020) que os 5 dispositivos permanecem com texto identico ao original de 1997; a LC 15.454/2020 so alterou os arts. 13/14/25-A (Pracas), sem impacto sobre os arts. 2o/3o/5o aqui testados.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (4/4).
-- 201,202,203,364

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Plano de Carreira dos Servidores Militares: 4 questoes distintas
-- Total de vinculos esperados: 4 (4 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
