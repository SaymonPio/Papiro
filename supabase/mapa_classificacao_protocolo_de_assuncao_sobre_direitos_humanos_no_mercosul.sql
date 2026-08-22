-- Mapa de classificacao semantica das questoes validas de Protocolo de Assunção sobre Direitos Humanos no Mercosul
-- (curso_conteudos.id = 92, assunto_id = 93,
-- materia_id = 11), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/protocolo_de_assuncao_sobre_direitos_humanos_no_mercosul.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_protocolo_de_assuncao_sobre_direitos_humanos_no_mercosul_teste_rollback.sql
--   classificar_questoes_unidades_protocolo_de_assuncao_sobre_direitos_humanos_no_mercosul.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 92 (apos curadoria_unidades_protocolo_de_assuncao_sobre_direitos_humanos_no_mercosul.sql):
--   U1 655700d6-b585-468f-8d98-8143090cbafb  ordem 1  Protocolo de Assunção sobre Direitos Humanos no Mercosul
--
-- Resultado da curadoria: 3/3 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (180, '655700d6-b585-468f-8d98-8143090cbafb'::uuid, 1, 'Identificação do objeto do Protocolo de Assunção', 'Questão de identificação do próprio instrumento — o gabarito ''A promoção e proteção dos direitos humanos no Mercosul'' reproduz literalmente o título oficial do Protocolo de Assunção sobre Compromisso com a Promoção e Proteção dos Direitos Humanos do MERCOSUL (2005, CMC/DEC nº 17/05). Não testa um artigo específico, apenas o reconhecimento do nome/objeto do tratado, frente a distratores totalmente estranhos (criação de moeda única, unificação tributária, defesa militar comum obrigatória, extinção das fronteiras).', 'alta'),
    (181, '655700d6-b585-468f-8d98-8143090cbafb'::uuid, 1, 'Classificação da área normativa do Protocolo de Assunção', 'Questão de classificação da área/ramo normativo a que pertence o instrumento — gabarito ''Direitos humanos no Mercosul'' frente a distratores de áreas do direito completamente alheias (direito marítimo europeu, direito penal internacional da ONU, direito eleitoral brasileiro, política monetária do FMI). Não testa um artigo específico.', 'alta'),
    (182, '655700d6-b585-468f-8d98-8143090cbafb'::uuid, 1, 'Direitos humanos como condição do processo de integração', 'Fundamento normativo: Protocolo de Assunção, art. 1, que estabelece que a plena vigência das instituições democráticas e o respeito aos direitos humanos e às liberdades fundamentais são condições essenciais para a vigência e evolução do processo de integração entre as Partes. Gabarito ''O respeito aos direitos humanos é condição relevante para o processo de integração regional'' — corresponde diretamente à ideia do art. 1. Sobreposição temática (não duplicata) com o conteúdo 91: mesma tese jurídica do mesmo art. 1 já usada para Q162/Q163 do conteúdo 91, com enunciados diferentes e nenhuma duplicata exata de ID — recorte pedagógico legítimo e distinto (conteúdo 92 é estudo dedicado especificamente ao Protocolo de Assunção enquanto instrumento). Distratores fabricam posições opostas ou absurdas (direitos humanos não se relacionam à integração, somente comércio importa ao bloco, Estados renunciam às Constituições, Mercosul substitui a OEA).', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (3/3).
-- 180,181,182

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Protocolo de Assunção sobre Direitos Humanos no Mercosul: 3 questoes distintas
-- Total de vinculos esperados: 3 (3 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
