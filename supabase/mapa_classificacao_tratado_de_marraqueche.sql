-- Mapa de classificacao semantica das questoes validas de Tratado de Marraqueche
-- (curso_conteudos.id = 94, assunto_id = 105,
-- materia_id = 11), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/tratado_de_marraqueche.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_tratado_de_marraqueche_teste_rollback.sql
--   classificar_questoes_unidades_tratado_de_marraqueche.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 94 (apos curadoria_unidades_tratado_de_marraqueche.sql):
--   U1 389ff0e7-38f5-4fe5-b66d-4ebbbb5ee9bf  ordem 1  Tratado de Marraqueche
--
-- Resultado da curadoria: 3/3 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (189, '389ff0e7-38f5-4fe5-b66d-4ebbbb5ee9bf'::uuid, 1, 'Beneficiários do Tratado de Marraqueche', 'Fundamento normativo: Tratado de Marraqueche, art. 3º (Beneficiários), que define em três alíneas quem são os beneficiários: (a) pessoa cega; (b) pessoa com deficiência visual ou outra deficiência de percepção ou leitura que não possa ser corrigida para alcançar função visual substancialmente equivalente à de uma pessoa sem essa deficiência; (c) pessoa que, por deficiência física, não consiga sustentar ou manipular um livro ou focar ou mover os olhos ao ponto normalmente necessário para a leitura. Gabarito ''Cegas, com deficiência visual ou outras dificuldades para ter acesso ao texto impresso'' — síntese das três alíneas em conjunto, mapeada a ''art. 3º'' sem subdivisão adicional (não há cobrança isolada de uma única alínea). Distratores fabricam categorias de beneficiários totalmente estranhas ao tratado (apenas estrangeiras, somente maiores de 70 anos, apenas servidores públicos, exclusivamente autores de livros).', 'alta'),
    (190, '389ff0e7-38f5-4fe5-b66d-4ebbbb5ee9bf'::uuid, 1, 'Status constitucional do Tratado de Marraqueche no Brasil', 'Fundamento normativo: CF/88, art. 5º, §3º — o Tratado de Marraqueche foi aprovado pelo Congresso Nacional (Decreto Legislativo nº 261/2015) segundo o rito qualificado (dois turnos, três quintos dos votos em cada Casa), conferindo-lhe equivalência a emenda constitucional; promulgado pelo Decreto nº 9.522/2018. Gabarito ''Emenda constitucional'' — correto. Distratores fabricam hierarquias incompatíveis (lei ordinária, decreto municipal, portaria, resolução administrativa). Sobreposição temática (não duplicata) com Q127 do conteúdo 78 (já concluído): lá o Tratado de Marraqueche aparece como uma das alternativas sobre status de EC de diversos tratados; aqui a questão é específica e direta sobre o rito de aprovação do Marraqueche.', 'alta'),
    (191, '389ff0e7-38f5-4fe5-b66d-4ebbbb5ee9bf'::uuid, 1, 'Propósito do Tratado de Marraqueche', 'A questão cobra genericamente o propósito/preâmbulo do Tratado (participação na vida cultural, desfrute das artes, acesso à informação, ampliação de obras em formatos acessíveis), não o mecanismo técnico do art. 4º (limitações e exceções aos direitos autorais para produção/disponibilização de exemplares em formato acessível). Por isso NENHUM artigo foi incluído para esta questão; o art. 4º permanece documentado apenas como contexto operacional em escopo/_nota, sem entrar em artigos_esperados — decisão mantida da auditoria original e confirmada pelo usuário. Gabarito ''Acesso à cultura e à informação em formatos acessíveis'' — correto. Distratores de áreas completamente alheias (liberdade tributária, porte de arma, direito eleitoral passivo, política monetária).', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (3/3).
-- 189,190,191

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Tratado de Marraqueche: 3 questoes distintas
-- Total de vinculos esperados: 3 (3 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
