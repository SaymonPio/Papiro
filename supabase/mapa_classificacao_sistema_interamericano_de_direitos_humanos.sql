-- Mapa de classificacao semantica das questoes validas de Sistema Interamericano de Direitos Humanos
-- (curso_conteudos.id = 85, assunto_id = 86,
-- materia_id = 11), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/sistema_interamericano_de_direitos_humanos.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_sistema_interamericano_de_direitos_humanos_teste_rollback.sql
--   classificar_questoes_unidades_sistema_interamericano_de_direitos_humanos.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 85 (apos curadoria_unidades_sistema_interamericano_de_direitos_humanos.sql):
--   U1 d815fc1f-82d3-4411-9dc5-63dae5373d2b  ordem 1  Sistema Interamericano de Direitos Humanos
--
-- Resultado da curadoria: 3/3 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (183, 'd815fc1f-82d3-4411-9dc5-63dae5373d2b'::uuid, 1, 'Órgãos do Sistema Interamericano', 'Fundamento normativo: CADH, art. 33 (''São competentes para conhecer dos assuntos relacionados ao cumprimento dos compromissos assumidos pelos Estados Partes na Convenção: a) a Comissão Interamericana de Direitos Humanos...; e b) a Corte Interamericana de Direitos Humanos''). Gabarito ''A Comissão Interamericana e a Corte Interamericana de Direitos Humanos'' — cópia literal dos dois órgãos elencados no art. 33. Distratores citam órgãos nacionais ou de outros sistemas (STF e STJ; ONU e OIT; Mercosul e Parlamento Europeu; FMI e Banco Mundial).', 'alta'),
    (184, 'd815fc1f-82d3-4411-9dc5-63dae5373d2b'::uuid, 1, 'CADH como instrumento do sistema interamericano', 'Fundamento predominantemente classificatório/institucional, sem artigo específico necessário. Gabarito ''Interamericano'' — correto, a CADH/Pacto de San José é um dos principais tratados do sistema interamericano. Distratores citam outros sistemas regionais (europeu, africano, asiático, da União Europeia).', 'alta'),
    (185, 'd815fc1f-82d3-4411-9dc5-63dae5373d2b'::uuid, 1, 'Complementaridade/subsidiariedade da proteção interamericana', 'Fundamento textual: Preâmbulo da CADH (''reconhecendo que os direitos essenciais do homem... justificam uma proteção internacional, de natureza convencional, coadjuvante ou complementar da que oferece o direito interno dos Estados americanos'') — por ser preâmbulo, não numerado como artigo, não entra em artigos_esperados. Gabarito ''Complementar à proteção interna dos Estados'' — correto, princípio da subsidiariedade/complementaridade (o sistema interamericano complementa a proteção nacional, sem substituir automaticamente o Judiciário interno, sem eximir o Estado de responsabilidade internacional quando a proteção interna falha). Distratores fabricam efeitos incorretos (substitutiva imediata de todo Judiciário nacional, exclusivamente penal, somente comercial, apenas consultiva sem mecanismo de responsabilização).', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (3/3).
-- 183,184,185

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Sistema Interamericano de Direitos Humanos: 3 questoes distintas
-- Total de vinculos esperados: 3 (3 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
