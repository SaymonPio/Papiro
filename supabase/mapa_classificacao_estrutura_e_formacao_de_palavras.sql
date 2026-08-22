-- Mapa de classificacao semantica das questoes validas de Estrutura e formação de palavras
-- (curso_conteudos.id = 33, assunto_id = 45,
-- materia_id = 6), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/estrutura_e_formacao_de_palavras.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_estrutura_e_formacao_de_palavras_teste_rollback.sql
--   classificar_questoes_unidades_estrutura_e_formacao_de_palavras.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 33 (apos curadoria_unidades_estrutura_e_formacao_de_palavras.sql):
--   U1 1a6bb75c-23d7-4110-be96-8803cbd85331  ordem 1  Estrutura e formação de palavras
--
-- Resultado da curadoria: 13/13 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (231, '1a6bb75c-23d7-4110-be96-8803cbd85331'::uuid, 1, 'Derivação prefixal: infeliz (origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO (banca=''Papiro'', concurso=''PAPIRO - Estilo Fundatec - BM RS'', 2026) — material suplementar de prática, NÃO conta como incidência histórica real. Regra testada: ''infeliz'' é formada por derivação prefixal (in-+feliz), prefixo de valor negativo antes do radical. Categoria: A) regra produtiva.', 'alta'),
    (232, '1a6bb75c-23d7-4110-be96-8803cbd85331'::uuid, 1, 'Derivação sufixal: felizmente (origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO — material suplementar de prática, NÃO conta como incidência histórica real. Regra testada: ''felizmente'' é formada por derivação sufixal (feliz+mente). CORREÇÃO APLICADA: -mente é sufixo produtivo característico de muitos advérbios (sobretudo de modo), não regra absoluta ''sempre a partir do feminino'' — em adjetivos uniformes nos dois gêneros (feliz, simples) não há etapa visível de passagem ao feminino. Categoria: A) regra produtiva.', 'alta'),
    (233, '1a6bb75c-23d7-4110-be96-8803cbd85331'::uuid, 1, 'Composição por justaposição: passatempo (origem=AUTORAL_PAPIRO)', 'ORIGEM: AUTORAL_PAPIRO — material suplementar de prática, NÃO conta como incidência histórica real. Regra testada: ''passatempo'' é composição por justaposição (passa+tempo), união de radicais sem perda fonética. Categoria: A) regra produtiva.', 'alta'),
    (336, '1a6bb75c-23d7-4110-be96-8803cbd85331'::uuid, 1, 'Falso prefixo ''in-'' em ''indicado'' × prefixo real de negação em ''indescritível''', 'Questão real (Fundatec, Corpo de Bombeiros Militar RS - Soldado 1ª Classe/2025). Regra testada: ''in-'' em ''indescritível'' é prefixo de negação; em ''indicado'', o segmento inicial ''in-'' é parte do radical latino primitivo (indicare), não prefixo. Categoria: D) contraste. PENDÊNCIA REGISTRADA (não saneada neste apply, nenhuma alteração de questão/alternativa/gabarito): OCR_CONTAMINACAO_ALTERNATIVA_Q336 — a alternativa E armazenada contém o texto ''Inativo.'' seguido de contaminação de OCR/importação (''MATEMÁTICA E RACIOCÍNIO LÓGICO'', cabeçalho da seção seguinte da prova original colado por erro de importação); não afeta a alternativa correta (B) nem a resolubilidade da questão; saneamento futuro proposto: manter apenas ''Inativo.''.', 'alta'),
    (685, '1a6bb75c-23d7-4110-be96-8803cbd85331'::uuid, 1, 'Derivação sufixal (temeroso) + prefixo IM- de negação (imateriais) × parassíntese refutada (componentes)', 'Questão real (Fundatec, Esc Pol PC-RS/2026). Regra testada: (I, correta) ''temeroso'' é formado por derivação sufixal (temor+oso); (II, correta) ''imateriais'' contém prefixo de negação — CORREÇÃO APLICADA: o alomorfe correto é IM- (in-+material, com assimilação fonológica do N ao M seguinte e posterior simplificação gráfica da geminada), não ''i-''; (III, incorreta) ''componentes'' não é parassíntese, é derivação simples a partir do radical latino de ''compor'' com sufixo participial ''-ente''. Categoria: A) regra produtiva + D) contraste. Gabarito: I e II.', 'alta'),
    (753, '1a6bb75c-23d7-4110-be96-8803cbd85331'::uuid, 1, 'Prefixo real de negação (incerteza) × falsos prefixos (início, incitando, importância, investir)', 'Questão real (Fundatec, Tec Per IGP RS/Técnico em Química/2025). Regra testada: ''incerteza'' tem prefixo de negação real (in-+certeza); ''início'', ''incitando'', ''importância'' e ''investir'' têm o segmento inicial como parte do radical latino primitivo, não prefixo. CORREÇÃO APLICADA: a remoção do segmento inicial (retirar ''in-'' e verificar se sobra palavra existente) é HEURÍSTICA AUXILIAR, não regra absoluta — a existência de uma base residual (ex.: investir→vestir, incitar→citar) não comprova sozinha prefixação sincrônica produtiva; é preciso também avaliar relação semântica entre base e derivada, produtividade do processo e a análise adotada pela banca. Categoria: D) contraste.', 'alta'),
    (754, '1a6bb75c-23d7-4110-be96-8803cbd85331'::uuid, 1, 'Prefixo sub- (posição inferior) + elemento de composição erudito -logia/logo (estudo, não ''tratamento'') + radical grego miso- (ódio)', 'Questão real (Fundatec, Del Pol PC-RS/2025). Regra testada: (I, correta) ''subnotificados'' tem prefixo ''sub-'' com valor de posição inferior/escassez; (II, incorreta) em ''psicóloga'', o elemento ''-logia/-logo'' (grego lógos) significa ''estudo/ciência/especialista'', não ''tratamento'' (que seria ''-terapia''); (III, correta) em ''misoginia'', o radical grego ''miso-'' significa ''ódio/aversão''. Categoria: A) regra produtiva + B) regra morfológica (elementos eruditos gregos). Gabarito: I e III.', 'alta'),
    (755, '1a6bb75c-23d7-4110-be96-8803cbd85331'::uuid, 1, 'Derivação sufixal -ando: vestibulando', 'Questão real (Fundatec, GCM Sant''Ana do Livramento/2025). Regra testada: ''vestibulando'' é formado por derivação sufixal (vestibular+ando). CORREÇÃO APLICADA: o sufixo nominal ''-ando'' não é regra universal de ''agente em preparação'' — o valor lexical efetivamente cobrado é pessoa na condição/processo relacionado ao vestibular (candidata a prestá-lo), com formações análogas (doutorando, graduando); não confundir com a terminação de gerúndio verbal (contraste útil apenas quando necessário ao corpus). Categoria: A) regra produtiva.', 'alta'),
    (807, '1a6bb75c-23d7-4110-be96-8803cbd85331'::uuid, 1, 'Palavra primitiva (mesa) × derivadas por sufixação (capacidade, aprendizado)', 'Questão real (Fundatec, GCM Uruguaiana/2023). Regra testada: ''mesa'' é palavra primitiva (não deriva de outra); ''capacidade'' (capaz+idade) e ''aprendizado'' (aprender+izado) são derivadas por sufixação. Categoria: A) regra produtiva. Gabarito: apenas I.', 'alta'),
    (880, '1a6bb75c-23d7-4110-be96-8803cbd85331'::uuid, 1, 'Prefixo grego anti- (oposição) + sufixo adverbial -mente × falso prefixo ''im-'' em importante', 'Questão real (Fundatec, Profis Pref Viamão/Magistério Ed. Infantil/2022). Regra testada: (I, correta) ''antiofídico'' tem prefixo grego ''anti-'' (oposição/combate); (II, correta) ''geralmente'' tem sufixo adverbial ''-mente''; (III, incorreta) em ''importante'', o segmento inicial ''im-'' é parte do radical latino primitivo (importare/importans), não prefixo de negação destacável. Categoria: A) regra produtiva + D) contraste. Gabarito: I e II.', 'alta'),
    (881, '1a6bb75c-23d7-4110-be96-8803cbd85331'::uuid, 1, 'Composição por justaposição (matéria-prima, guarda-chuva) × derivação prefixal (contra-/anti-/pós-/vice-)', 'Questão real (Fundatec, Profis Pref Viamão/Magistério Ed. Infantil/2022). Regra testada: ''matéria-prima'' e ''guarda-chuva'' são compostos por justaposição (elementos autônomos, sem conectivo); ''contra-ataque'', ''anti-inflamatório'', ''pós-graduação'' e ''vice-presidente'' são formados por derivação prefixal, conforme o critério adotado pela banca. NOTA CURTA: existe tradição gramatical que trata vice-/pós-/anti- como prefixoides/pseudoprefixos formadores de composição — para a prática do Papiro, ensinar prioritariamente o critério efetivamente adotado pela Fundatec nesta questão, sem transformar isso em controvérsia central da aula. Categoria: D) contraste. Gabarito: guarda-chuva.', 'alta'),
    (882, '1a6bb75c-23d7-4110-be96-8803cbd85331'::uuid, 1, 'Prefixo de negação in- (inimputabilidade) × outros valores semânticos de in- e outros prefixos', 'Questão real (Fundatec, Ag Sg Sc SEJUSP-MG/2022). Regra testada: ''inimputabilidade'' tem prefixo ''in-'' com valor de negação/privação (condição de quem não é imputável), distinto do ''in-'' de movimento para dentro (ingerir, invadir) e de outros prefixos de separação (des-/dis-) ou concomitância (co-/con-). Categoria: A) regra produtiva. Apenas 4 alternativas armazenadas (A/B/C/D) — consistente com a explicação, que não referencia alternativa E; não é problema de dado.', 'alta'),
    (883, '1a6bb75c-23d7-4110-be96-8803cbd85331'::uuid, 1, 'Desinência nominal de número (-s/-es) × ausência de desinência no singular', 'Questão real (Fundatec, TA Pol Pen PP-RS/2022). Regra testada: ''possível'', no singular, não possui desinência nominal de número (morfema zero); ''operadores'', ''nossos'', ''homens'' e ''mulheres'' têm desinência plural (-es/-s). Reaproveita o artigo ''RS Seguro'' já usado em Ortografia/Acentuação/Fonemas/Tempos e modos verbais (conteúdos 20/26/34/31, já concluídos). Categoria: B) regra morfológica (elemento de estrutura da palavra, distinto dos processos de formação).', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (13/13).
-- 231,232,233,336,685,753,754,755,807,880,881,882,883

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Estrutura e formação de palavras: 13 questoes distintas
-- Total de vinculos esperados: 13 (13 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
