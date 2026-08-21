-- Mapa de classificacao semantica das questoes validas de Jurisprudência do STF e STJ
-- (curso_conteudos.id = 69, assunto_id = 66,
-- materia_id = 10), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/jurisprudencia_do_stf_e_stj.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_jurisprudencia_do_stf_e_stj_teste_rollback.sql
--   classificar_questoes_unidades_jurisprudencia_do_stf_e_stj.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 69 (apos curadoria_unidades_jurisprudencia_do_stf_e_stj.sql):
--   U1 8e1d1204-1f66-431c-a95f-6403e77882dc  ordem 1  Jurisprudência do STF e STJ
--
-- Resultado da curadoria: 5/5 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (198, '8e1d1204-1f66-431c-a95f-6403e77882dc'::uuid, 1, 'Uso de algemas (Súmula Vinculante 11)', 'Gabarito: ''E excepcional e deve ser justificado nas hipoteses admitidas'' — Sumula Vinculante no 11/STF (''So e licito o uso de algemas em casos de resistencia e de fundado receio de fuga ou de perigo a integridade fisica propria ou alheia... justificada a excepcionalidade por escrito''). Sem dispositivo constitucional/legal-base unico e seguro; nao entra em artigos_esperados por decisao aprovada. Distratores sem correspondencia (obrigatorio em toda prisao, proibido sempre, depende da vontade do agente, sem controle judicial).', 'alta'),
    (199, '8e1d1204-1f66-431c-a95f-6403e77882dc'::uuid, 1, 'Entrada forçada em domicílio sem mandado (Tema 280/RE 603.616)', 'Gabarito: ''Houver fundadas razoes, devidamente justificadas posteriormente, que indiquem situacao de flagrante delito'' — Tema 280 de repercussao geral do STF (RE 603.616, rel. Min. Gilmar Mendes, 2015), interpretando CF art. 5o, XI. SOBREPOSICAO TEMATICA (nao duplicata): o curso_conteudo_id 47 (Direitos e Garantias Fundamentais) ja cobre art. 5o, XI pelo texto constitucional; aqui se testa o padrao jurisprudencial do que caracteriza ''fundadas razoes''. Distratores sem correspondencia (sempre que o policial desejar, apenas de dia, denuncia anonima isolada obrigatoriamente, nunca).', 'alta'),
    (200, '8e1d1204-1f66-431c-a95f-6403e77882dc'::uuid, 1, 'Presunção de inocência e execução da pena (ADCs 43, 44 e 54)', 'Gabarito: ''A execucao automatica da pena antes do transito em julgado, ressalvadas prisoes cautelares fundamentadas'' — ADCs 43, 44 e 54/STF (2019), que declararam a constitucionalidade do art. 283 do CPP (que so admite prisao por flagrante, ordem judicial cautelar fundamentada ou condenacao transitada em julgado) e a compatibilidade com CF art. 5o, LVII. MICROCHECAGEM: a questao usa ''impede, COMO REGRA'' e ja traz a ressalva de prisoes cautelares — nao e afirmacao universal, permanecendo compativel com a excecao posterior do Tema 1068 (soberania dos veredictos do Tribunal do Juri). Gabarito mantido sem alteracao. Distratores sem correspondencia (prisao em flagrante, prisao preventiva, investigacao criminal, medidas cautelares — nenhuma dessas e o que a presuncao de inocencia impede como regra).', 'alta'),
    (670, '8e1d1204-1f66-431c-a95f-6403e77882dc'::uuid, 1, 'Criminalização da homofobia e transfobia (ADO 26/MI 4733)', 'Gabarito (alt4): ''A pratica de atos de homofobia e transfobia foi equiparada ao crime de racismo, sendo aplicavel a Lei no 7.716/1989, ate que o Congresso Nacional edite legislacao especifica sobre o tema'' — ADO 26 e MI 4733/STF (2019, rel. Min. Celso de Mello). Sem dispositivo constitucional/legal-base unico e seguro; nao entra em artigos_esperados por decisao aprovada. Conexao tematica solta (nao duplicata) com o art. 54 da Lei 12.288/2010 (curso_conteudo_id 67), que apenas remete a Lei 7.716/1989 para servidores publicos. Demais alternativas falsas (criminalizacao dependeria de lei estadual, seria so na esfera civel, seria so crime de menor potencial ofensivo, seria so para agentes do Estado).', 'alta'),
    (733, '8e1d1204-1f66-431c-a95f-6403e77882dc'::uuid, 1, 'Estatuto jurídico-constitucional do policial civil: greve, subsídio e aposentadoria', 'Assertiva I (falsa): combina duas citacoes verdadeiras do Tema 541/STF (ARE 654.432) — vedacao ''sob qualquer forma ou modalidade'' e mediacao obrigatoria ''nos termos do art. 165 do CPC'' — com uma conclusao fabricada (mediacao malsucedida abriria excecao ao direito de greve condicionada a manutencao de metade do efetivo), que nao existe na tese do STF (a mediacao e so canal de vocalizacao, dentro da proibicao absoluta). Assertiva II (falsa): generaliza indevidamente o regime de subsidio (CF art. 144, §9o c/c art. 39, §4o), que se aplica aos servidores policiais, nao a ''todos os cargos que eventualmente estejam na estrutura da Policia Civil''. Assertiva III (verdadeira, gabarito): CF art. 40, §4o-B (EC 103/2019) — lei complementar do ente federativo pode estabelecer idade e tempo de contribuicao diferenciados para aposentadoria de policiais civis. Gabarito ''Apenas III'' confere.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (5/5).
-- 198,199,200,670,733

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Jurisprudência do STF e STJ: 5 questoes distintas
-- Total de vinculos esperados: 5 (5 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
