-- Mapa de classificacao semantica das questoes validas de Declaração Universal dos Direitos Humanos
-- (curso_conteudos.id = 83, assunto_id = 88,
-- materia_id = 11), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/declaracao_universal_dos_direitos_humanos.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_declaracao_universal_dos_direitos_humanos_teste_rollback.sql
--   classificar_questoes_unidades_declaracao_universal_dos_direitos_humanos.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 83 (apos curadoria_unidades_declaracao_universal_dos_direitos_humanos.sql):
--   U1 e7bef052-b882-4a2f-b1e6-88ce12740c26  ordem 1  Declaração Universal dos Direitos Humanos
--
-- Resultado da curadoria: 6/6 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (145, 'e7bef052-b882-4a2f-b1e6-88ce12740c26'::uuid, 1, 'Direitos civis fundamentais (multi-dispositivo)', 'Questao INCORRETA: alt1 (verdadeira, copia literal ''todos os seres humanos nascem livres e iguais em dignidade e direitos'') art. 1o. Alt2 (INCORRETA selecionada, gabarito — real e ''ninguem sera submetido a tortura nem a penas ou tratamentos crueis, desumanos ou degradantes'', SEM excecao para guerra; a alternativa acrescenta ''salvo em caso de guerra'', inexistente no texto) art. 5o. Alt3 (verdadeira, copia literal sobre direito a vida/liberdade/seguranca pessoal) art. 3o. Alt4 (verdadeira, copia literal sobre vedacao a escravidao/servidao) art. 4o. Alt5 (verdadeira, copia literal sobre igualdade perante a lei) art. 7o.', 'alta'),
    (251, 'e7bef052-b882-4a2f-b1e6-88ce12740c26'::uuid, 1, 'Igualdade em dignidade e direitos', 'Gabarito: ''Livres e iguais em dignidade e direitos'' — copia literal do art. 1o. Distratores sem correspondencia (direitos condicionados a nacionalidade, liberdade apenas apos maioridade, desiguais perante a lei, submetidos previamente ao Estado — todos contrariam o texto).', 'alta'),
    (252, 'e7bef052-b882-4a2f-b1e6-88ce12740c26'::uuid, 1, 'Vida, liberdade e segurança pessoal', 'Gabarito: ''A vida, a liberdade e a seguranca pessoal'' — copia literal do art. 3o. Distratores sem correspondencia (prisao sem fundamento legal, censura previa obrigatoria, distincao de direitos por origem nacional, escravidao em situacao excepcional — todos contrariam outros artigos da Declaracao).', 'alta'),
    (349, 'e7bef052-b882-4a2f-b1e6-88ce12740c26'::uuid, 1, 'Direitos políticos, culturais e deveres (multi-dispositivo)', 'Questao INCORRETA: alt1 (verdadeira, copia literal sobre liberdade de pensamento/consciencia/religiao) art. 18. Alt2 (verdadeira, copia literal sobre direito de tomar parte no governo do pais) art. 21, item 1. Alt3 (verdadeira, copia literal sobre participar da vida cultural da comunidade) art. 27, item 1. Alt4 (INCORRETA selecionada, gabarito — a DUDH nao estabelece garantia de gratuidade para o ensino superior; a gratuidade e expressamente assegurada, pelo menos, nos graus elementares e fundamentais, sendo o ensino superior baseado no merito e aberto a todos em igualdade, sem garantia de gratuidade; a alternativa afirma gratuidade tambem ''nos graus... superiores'', o que a Declaracao nao garante) art. 26. Alt5 (verdadeira, copia literal sobre deveres para com a comunidade) art. 29, item 1.', 'alta'),
    (788, 'e7bef052-b882-4a2f-b1e6-88ce12740c26'::uuid, 1, 'Presunção de inocência', 'Gabarito: ''Presuncao da inocencia'' — trecho citado no enunciado (''todo ser humano acusado de um ato delituoso tem o direito de ser presumido inocente ate que a sua culpabilidade tenha sido provada de acordo com a lei, em julgamento publico...'') e copia literal do art. 11, item 1. Distratores sem correspondencia direta com este trecho especifico (universalidade, igualdade, direito a vida/liberdade/seguranca, direito de ir e vir — todos sao outros direitos da Declaracao, nao o testado no enunciado).', 'alta'),
    (812, 'e7bef052-b882-4a2f-b1e6-88ce12740c26'::uuid, 1, 'Garantias judiciais e legalidade penal (multi-dispositivo)', 'Assertiva I (verdadeira, copia literal sobre julgamento equitativo e publico por tribunal independente e imparcial) art. 10. Assertiva II (verdadeira, copia literal sobre presuncao de inocencia) art. 11, item 1. Assertiva III (falsa — o texto real do art. 11, item 2, nao preve excecao alguma a irretroatividade penal; a assertiva acrescenta ''salvo quando se tratar de crime contra os direitos humanos'', inexistente no texto) art. 11, item 2. Gabarito ''Apenas I e II'' confere.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (6/6).
-- 145,251,252,349,788,812

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Declaração Universal dos Direitos Humanos: 6 questoes distintas
-- Total de vinculos esperados: 6 (6 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
