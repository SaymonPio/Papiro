-- Mapa de classificacao semantica das questoes validas de Acentuação gráfica
-- (curso_conteudos.id = 26, assunto_id = 44,
-- materia_id = 6), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/acentuacao_grafica.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_acentuacao_grafica_teste_rollback.sql
--   classificar_questoes_unidades_acentuacao_grafica.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 26 (apos curadoria_unidades_acentuacao_grafica.sql):
--   U1 d100427d-d567-43e8-8ec8-81d44e5e3afe  ordem 1  Acentuação gráfica
--
-- Resultado da curadoria: 15/15 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (216, 'd100427d-d567-43e8-8ec8-81d44e5e3afe'::uuid, 1, 'Hiato tônico I/U: saúde, saída, baú', 'Regra testada: ''saúde'', ''saída'' e ''baú'' têm o I/U tônico formando sílaba própria (isolado ou seguido apenas de S), sem NH seguinte — recebem acento pela regra do hiato tônico. Categoria: A) regra produtiva, com limites relevantes a ensinar na futura aula (rainha/moinho não acentuam por causa do NH seguinte; juiz/raiz não acentuam nessa configuração). Distratores omitem o acento em uma das três palavras.', 'alta'),
    (217, 'd100427d-d567-43e8-8ec8-81d44e5e3afe'::uuid, 1, 'Proparoxítona: lâmpada', 'Regra testada: ''lâmpada'' (lâm-pa-da) tem a antepenúltima sílaba tônica, classificando-se como proparoxítona — regra absoluta, todas as proparoxítonas são acentuadas, sem exceção. Categoria: A) regra produtiva. Distratores propõem classificações de tonicidade incompatíveis com a contagem correta de sílabas.', 'alta'),
    (218, 'd100427d-d567-43e8-8ec8-81d44e5e3afe'::uuid, 1, 'Oxítona terminada em ''a'': Paraná', 'Regra testada: ''Paraná'' (pa-ra-NÁ) é oxítona terminada em ''a'' tônico, recebendo acento pela regra das oxítonas terminadas em A/E/O (seguidas ou não de S). Categoria: A) regra produtiva. Distratores são palavras reais mas com regras de acentuação diferentes (proparoxítona, paroxítona em L/X).', 'alta'),
    (679, 'd100427d-d567-43e8-8ec8-81d44e5e3afe'::uuid, 1, '''Também'' segue regra diferente por ser oxítona (não é ''exceção de paroxítona'')', 'CORREÇÃO APLICADA: ''também'' NÃO é descrita como ''exceção entre as paroxítonas'' — ela segue uma REGRA DIFERENTE porque é OXÍTONA terminada em -em (mesma regra de além, porém, ninguém), acentuada por essa razão. As demais palavras da questão (''Critério'', ''Excelência'', ''Referências'', ''Incumbência'') seguem a regra das paroxítonas terminadas em ditongo crescente (ou proparoxítonas aparentes, conforme a análise silábica adotada). Categoria: D) contraste (identificar que duas regras de acentuação diferentes coexistem no mesmo grupo de palavras). Pegadinha central: mesma aparência gráfica não significa mesma regra de acentuação.', 'alta'),
    (680, 'd100427d-d567-43e8-8ec8-81d44e5e3afe'::uuid, 1, 'Proparoxítonas: biológicos, acadêmicas, psicológico', 'Regra testada: ''biológicos'', ''acadêmicas'' e ''psicológico'' têm a antepenúltima sílaba tônica — todas proparoxítonas, mesma regra de acentuação. Categoria: A) regra produtiva. Distratores usam palavras com regras diferentes (oxítona -e, paroxítona -l, hiato tônico).', 'alta'),
    (681, 'd100427d-d567-43e8-8ec8-81d44e5e3afe'::uuid, 1, 'Proparoxítonas: astrofísico, Júpiter, astrônomo, últimas', 'Regra testada: ''astrofísico'', ''Júpiter'', ''astrônomo'' e ''últimas'' têm a antepenúltima sílaba tônica — todas proparoxítonas. Categoria: A) regra produtiva. Distratores misturam paroxítonas em ditongo, monossílabos tônicos e oxítonas nasais com proparoxítonas.', 'alta'),
    (744, 'd100427d-d567-43e8-8ec8-81d44e5e3afe'::uuid, 1, 'Efeitos da ausência do acento: vivências/vivencias, ninguém/inexistente, é/e', 'Regras testadas (efeitos da presença/ausência do acento, NÃO rotulado genericamente como ''acento diferencial''): (I) ''vivências'' sem acento forma ''vivencias'', 2ª pessoa do singular do verbo vivenciar — mudança de classe gramatical (substantivo→verbo); (II) ''ninguém'' sem acento (''ninguem'') não constitui palavra existente em português; (III) ''é'' (forma do verbo ser) sem acento vira ''e'', a conjunção aditiva — mudança de classe gramatical e sentido. Categoria: D) contraste (itens I e III) + C) grafia/uso lexical (item II — reconhecimento de existência da forma). Todas as três assertivas corretas.', 'alta'),
    (745, 'd100427d-d567-43e8-8ec8-81d44e5e3afe'::uuid, 1, 'Regras distintas de acentuação e efeitos da ausência do acento: saúde/é/está, nós/porém/contrário, âmbito/difícil', 'Regras testadas: (I, incorreta) ''saúde'' (hiato tônico), ''é'' (monossílabo tônico) e ''está'' (oxítona -a) seguem TRÊS regras distintas, não a mesma; (II, correta) ''nós'', ''porém'' e ''contrário'' sem acento continuam existindo como palavras legítimas (nos/pronome, porem/forma verbal de pôr, contrario/forma verbal de contrariar) — efeito de mudança de classe gramatical, não rotulado como ''acento diferencial'' genérico; (III, incorreta) ''âmbito'' (proparoxítona) e ''difícil'' (paroxítona terminada em L) seguem regras diferentes. Categoria: D) contraste (itens I e III) + C) grafia/uso lexical (item II). Sobreposição temática com Q786 do conteúdo 20 (Ortografia): mesma regra da paroxítona em L já testada lá para ''lavável'', aqui para ''difícil''.', 'alta'),
    (746, 'd100427d-d567-43e8-8ec8-81d44e5e3afe'::uuid, 1, 'Proparoxítona + plural de paroxítona em -vel + til como nasalidade', 'Regras testadas: (V) ''específico'' (proparoxítona) sem acento forma ''especifico'', forma verbal (verbo especificar) — mudança de classe gramatical; (F) ''indispensável'' e ''impecável'' no plural MANTÊM o acento (''indispensáveis'', ''impecáveis'') — a manutenção decorre da preservação da sílaba tônica dentro das regras gerais de acentuação, não é fenômeno isolado; (V) ''publicação'' e ''decisão'' são oxítonas, e o til marca nasalidade da vogal, não é sinal de tonicidade. Categoria: A) regra produtiva (proparoxítona; plural de -vel) + D) contraste (til nasalidade × acento tonicidade). Sequência V-F-V.', 'alta'),
    (747, 'd100427d-d567-43e8-8ec8-81d44e5e3afe'::uuid, 1, 'Paroxítona em L, hiato tônico, e ''além'' não é monossílabo', 'Regras testadas: (I, correta) ''escalável'' é paroxítona terminada em L; (II, correta) ''conteúdos'' é acentuada pela regra do hiato tônico (U tônico isolado, seguido de S); (III, incorreta) ''além'' NÃO é monossílabo tônico — é dissílabo (a-LÉM), oxítona terminada em -em, mesma regra de porém/também/ninguém. Categoria: A) regra produtiva. Sobreposição temática com Q786 do conteúdo 20 (Ortografia): mesma regra da paroxítona em L já testada lá para ''lavável'', aqui para ''escalável''. Distratores confundem monossílabo tônico com oxítona dissílaba.', 'alta'),
    (748, 'd100427d-d567-43e8-8ec8-81d44e5e3afe'::uuid, 1, '''Rádio'' — paroxítona terminada em ditongo (nota: paroxítona em ditongo × proparoxítona aparente)', 'Regra testada: ''rádio'' (RÁ-dio) tem a penúltima sílaba tônica e termina em ditongo oral crescente (''-io''), recebendo acento pela regra das paroxítonas terminadas em ditongo. NOTA PEDAGÓGICA (aplicada conforme correção aprovada): a análise tradicional escolar trata ''rádio'' como paroxítona terminada em ditongo crescente, mas o Acordo Ortográfico também admite a categoria de proparoxítona aparente para sequências pós-tônicas como ''-io'' — a futura aula deve ensinar o padrão adotado pela banca (Fundatec, neste caso: paroxítona) sem tratar a análise alternativa como erro. Categoria: A) regra produtiva.', 'alta'),
    (872, 'd100427d-d567-43e8-8ec8-81d44e5e3afe'::uuid, 1, 'Vírus (paroxítona em -US) × clínicos (proparoxítona); células (proparoxítona); pó (monossílabo tônico)', 'Regras testadas: (I, incorreta) ''vírus'' é paroxítona terminada em -US (terminação a documentar explicitamente no mapa, não apenas L/N/R/X/PS/ÃO — o corpus deste conteúdo cobre também -US), mas ''clínicos'' é proparoxítona — a assertiva erra ao classificar ambas como paroxítonas; (II, correta) ''células'' tem a antepenúltima sílaba tônica, proparoxítona; (III, correta) ''pó'' é monossílabo tônico terminado em ''o''. Categoria: A) regra produtiva + D) contraste (item I). Gabarito: apenas II e III corretas.', 'alta'),
    (873, 'd100427d-d567-43e8-8ec8-81d44e5e3afe'::uuid, 1, 'Latrocínios/feminicídios (paroxítona em ditongo) × histórica (proparoxítona) — nota: paroxítona em ditongo × proparoxítona aparente', 'Regra testada: ''latrocínios'' e ''feminicídios'' têm a penúltima sílaba tônica e terminam em ditongo oral crescente (''-ios''), mesma regra de acentuação (paroxítona em ditongo); ''histórica'' (proparoxítona, antepenúltima tônica) segue regra diferente; ''já'' é monossílabo TÔNICO (não átono). NOTA PEDAGÓGICA (mesma da Q748): análise tradicional trata como paroxítona em ditongo, com a ressalva de que o Acordo Ortográfico também admite proparoxítona aparente para essas sequências. Categoria: D) contraste. Fragmento autossuficiente, sem dependência de texto-base externo ausente.', 'alta'),
    (874, 'd100427d-d567-43e8-8ec8-81d44e5e3afe'::uuid, 1, 'Efeito da ausência do acento: número (proparoxítona) → numero (forma verbal existente)', 'Regra testada: ''número'' (proparoxítona) sem acento forma ''numero'', 1ª pessoa do singular do presente do indicativo do verbo numerar — forma legítima da língua (mudança de classe gramatical, substantivo→verbo), NÃO rotulada genericamente como ''acento diferencial''. Categoria: C) grafia/uso lexical + D) contraste. Distratores (''após'', ''municípios'', ''gaúchos'', ''nível'') não formam palavras existentes sem o acento — o corpus explora exatamente a diferença entre proparoxítonas que geram outra forma legítima e as que simplesmente deixam de existir sem acento.', 'alta'),
    (875, 'd100427d-d567-43e8-8ec8-81d44e5e3afe'::uuid, 1, 'Efeito da ausência do acento: climática (proparoxítona) → forma inexistente, ao contrário das demais', 'Regra testada: ''climática'' (proparoxítona) sem acento forma ''climatica'', que NÃO existe na língua portuguesa; já ''acontecerá''→''acontecera'', ''tornará''→''tornara'', ''até''→''ate'' e ''líderes''→''lideres'' sem acento formam palavras/formas verbais legítimas (pretérito mais-que-perfeito e presente do subjuntivo). Categoria: C) grafia/uso lexical + D) contraste. NÃO rotulado genericamente como ''acento diferencial'' — trata-se do efeito de existência/inexistência da forma sem acento.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (15/15).
-- 216,217,218,679,680,681,744,745,746,747,748,872,873,874,875

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Acentuação gráfica: 15 questoes distintas
-- Total de vinculos esperados: 15 (15 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
