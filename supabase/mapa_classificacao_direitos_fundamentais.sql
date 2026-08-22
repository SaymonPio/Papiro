-- Mapa de classificacao semantica das questoes validas de Direitos fundamentais
-- (curso_conteudos.id = 76, assunto_id = 25,
-- materia_id = 11), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/direitos_fundamentais.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_direitos_fundamentais_teste_rollback.sql
--   classificar_questoes_unidades_direitos_fundamentais.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 76 (apos curadoria_unidades_direitos_fundamentais.sql):
--   U1 325c5ca6-8165-472f-b02b-eb7b18c6f71d  ordem 1  Direitos fundamentais
--
-- Resultado da curadoria: 5/5 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (28, '325c5ca6-8165-472f-b02b-eb7b18c6f71d'::uuid, 1, 'Racismo como crime inafiançável e imprescritível', 'Gabarito ''Inafiançável e imprescritível'' — cópia literal do art. 5º, XLII (''a prática do racismo constitui crime inafiançável e imprescritível, sujeito à pena de reclusão, nos termos da lei''). Distratores sem correspondência (afiançável/prescrição de dois anos, apenas multa, autorização judicial prévia, infração administrativa).', 'alta'),
    (139, '325c5ca6-8165-472f-b02b-eb7b18c6f71d'::uuid, 1, 'Direitos e garantias individuais — verdadeiro/falso (multi-dispositivo)', 'Assertiva I (falsa — inverte ''salvo se invocar para eximir-se de obrigação legal e recusar-se a cumprir prestação alternativa'' para ''ainda que...ou'', retirando a condição de perda da proteção) art. 5º, VIII. Assertiva II (verdadeira, cópia literal sobre intimidade/vida privada/honra/imagem) art. 5º, X. Assertiva III (falsa — inverte ''vedada a de caráter paramilitar'' para ''incluindo as de caráter paramilitar'') art. 5º, XVII. Assertiva IV (verdadeira, cópia literal sobre inviolabilidade domiciliar) art. 5º, XI. Assertiva V (falsa — inverte ''inafiançável e imprescritível'' para ''afiançável e prescritível'') art. 5º, XLIV. Gabarito ''Apenas II e IV'' confere.', 'alta'),
    (292, '325c5ca6-8165-472f-b02b-eb7b18c6f71d'::uuid, 1, 'Aplicação imediata das normas de direitos e garantias fundamentais', 'Gabarito ''Aplicação imediata'' — cópia literal do art. 5º, §1º (''As normas definidoras dos direitos e garantias fundamentais têm aplicação imediata''). Distratores sem correspondência (lei complementar, caráter programático, restrição a natos, eficácia só vertical).', 'alta'),
    (342, '325c5ca6-8165-472f-b02b-eb7b18c6f71d'::uuid, 1, 'Objetivos fundamentais da República (EXCETO) — distinção com art. 4º', 'Comando EXCETO: pede o item que NÃO é objetivo fundamental do art. 3º. Alt1 ''construir sociedade livre, justa e solidária'' = art. 3º, I (verdadeira, não é o gabarito). Alt2 ''erradicar pobreza/marginalização e reduzir desigualdades'' = art. 3º, III (verdadeira). Alt3 (INCORRETA selecionada, gabarito) ''assegurar a autodeterminação dos povos'' — não é objetivo fundamental do art. 3º; corresponde ao art. 4º, III (princípio que rege as relações internacionais do Brasil) — distinção normativa testada pela questão. Alt4 ''promover o bem de todos, sem preconceitos...'' = art. 3º, IV (verdadeira). Alt5 ''garantir o desenvolvimento nacional'' = art. 3º, II (verdadeira). Gabarito confere: a alternativa 3 é a única que não pertence ao art. 3º.', 'alta'),
    (343, '325c5ca6-8165-472f-b02b-eb7b18c6f71d'::uuid, 1, 'Direitos e garantias individuais — verdadeiro/falso (multi-dispositivo)', 'Assertiva 1 (falsa — mesma inversão de ''salvo se invocar...e recusar-se'' para ''ainda que...e recusar-se'', retirando a condicionante de perda da proteção) art. 5º, VIII. Assertiva 2 (verdadeira, cópia literal sobre acesso à informação/sigilo da fonte) art. 5º, XIV — não art. 5º, X (que trata de intimidade/vida privada/honra/imagem, tema diferente). Assertiva 3 (verdadeira, cópia literal ''é plena a liberdade de associação para fins lícitos, vedada a de caráter paramilitar'') art. 5º, XVII. Assertiva 4 (verdadeira, cópia literal ''ninguém poderá ser compelido a associar-se ou a permanecer associado'') art. 5º, XX. Gabarito ''F–V–V–V'' confere.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (5/5).
-- 28,139,292,342,343

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Direitos fundamentais: 5 questoes distintas
-- Total de vinculos esperados: 5 (5 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
