-- Mapa de classificacao semantica das questoes validas de Dignidade humana
-- (curso_conteudos.id = 98, assunto_id = 12,
-- materia_id = 11), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/dignidade_humana.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_dignidade_humana_teste_rollback.sql
--   classificar_questoes_unidades_dignidade_humana.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 98 (apos curadoria_unidades_dignidade_humana.sql):
--   U1 70bd2ed8-e947-4050-b1aa-e1ceb2c0be1f  ordem 1  Dignidade humana
--
-- Resultado da curadoria: 3/3 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (13, '70bd2ed8-e947-4050-b1aa-e1ceb2c0be1f'::uuid, 1, 'Dignidade humana na Declaração Universal dos Direitos Humanos', 'Fundamento normativo: Declaração Universal dos Direitos Humanos (ONU, 1948), art. 1 — ''Todos os seres humanos nascem livres e iguais em dignidade e direitos.'' Gabarito ''Livres e iguais em dignidade e direitos'' — cópia direta do dispositivo. NÃO incluído em artigos_esperados por decisão aprovada sobre colisão de parser com o art. 1º, III da CF/88 (mesmo array desta unidade) — o parser identifica apenas o número-base do artigo e não distingue diplomas; isso é limitação técnica, não reflete fundamento secundário ou dispensável. A DUDH art. 1 deve aparecer explicitamente na futura aula como fundamento pleno desta questão. Distratores fabricam condicionantes inexistentes (submetidos a direitos da profissão, condicionados à nacionalidade, iguais apenas perante autoridades administrativas).', 'alta'),
    (648, '70bd2ed8-e947-4050-b1aa-e1ceb2c0be1f'::uuid, 1, 'Dignidade da pessoa humana como fundamento constitucional (cenário de violência)', 'Fundamento normativo: CF/88, art. 1º, III — a dignidade da pessoa humana é fundamento da República Federativa do Brasil. Gabarito ''A dignidade da pessoa humana'' — correto diante do cenário de violência com exposição da vítima. Distratores fabricam pseudo-fundamentos inexistentes (soberania patrimonial, cidadania moral, valores do livre arbítrio, vontade da iniciativa popular — nenhum corresponde literalmente aos incisos reais do art. 1º). Quase-duplicata interna com Q715 (mesmo conteúdo, mesmo fundamento, cenário distinto) e sobreposição temática (não duplicata) com Q794 do conteúdo 57 (Constituição Federal de 1988, já concluído, matéria Legislação Específica), que testa a mesma tese jurídica.', 'alta'),
    (715, '70bd2ed8-e947-4050-b1aa-e1ceb2c0be1f'::uuid, 1, 'Dignidade da pessoa humana como fundamento constitucional (cenário de vulnerabilidade)', 'Fundamento normativo: CF/88, art. 1º, III — mesmo fundamento de Q648, aplicado a situação concreta distinta (pessoa em situação de rua tratada com respeito por agente público). Gabarito ''A dignidade da pessoa humana'' — correto. Distratores usam fundamentos reais de outros incisos do mesmo art. 1º (soberania — I, pluralismo político — V, valores sociais do trabalho e da livre iniciativa — IV) e uma combinação fabricada (''pluralismo da livre iniciativa''); úteis para a futura aula apresentar brevemente os cinco fundamentos do art. 1º, sem que os incisos I, II, IV e V entrem em artigos_esperados como referências independentes. Quase-duplicata interna com Q648; sobreposição temática (não duplicata) com Q794 e Q651 do conteúdo 57 (Q651 usa comando EXCETO, onde dignidade aparece como alternativa errada).', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (3/3).
-- 13,648,715

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Dignidade humana: 3 questoes distintas
-- Total de vinculos esperados: 3 (3 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
