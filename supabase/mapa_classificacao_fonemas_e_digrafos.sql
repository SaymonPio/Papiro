-- Mapa de classificacao semantica das questoes validas de Fonemas e dígrafos
-- (curso_conteudos.id = 34, assunto_id = 56,
-- materia_id = 6), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/fonemas_e_digrafos.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_fonemas_e_digrafos_teste_rollback.sql
--   classificar_questoes_unidades_fonemas_e_digrafos.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 34 (apos curadoria_unidades_fonemas_e_digrafos.sql):
--   U1 61bd0288-38fe-45bc-9c1e-51c1ecc9a515  ordem 1  Fonemas e dígrafos
--
-- Resultado da curadoria: 13/14 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: 885 (FORA_DE_ESCOPO_ACENTUACAO_TONICIDADE — cobra classificacao quanto a tonicidade (identificacao de palavras paroxitonas: vacina, aumento), habilidade do conteudo 26 (Acentuacao grafica, ja concluido), sem envolver nenhum conceito de fonema, digrafo ou encontro vocalico/consonantal. Provavel destino futuro: conteudo 26, ja concluido, NAO reaberto nesta operacao. Nao realocada nesta etapa.).

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (114, '61bd0288-38fe-45bc-9c1e-51c1ecc9a515'::uuid, 1, 'Dancinha: dois dígrafos (nasal ''an'' + consonantal ''nh'')', 'Regra testada: ''dancinha'' tem o dígrafo vocálico/nasal ''an'' (dan-) e o dígrafo consonantal ''nh'' (-nha), somando 2 dígrafos, enquanto ''questão'', ''classificação'', ''grandona'' e ''esquisitices'' têm apenas 1 dígrafo cada. Categoria: A) regra produtiva — o aluno precisa reconhecer os dois fenômenos de dígrafo pelo som, não memorizar a palavra como item lexical isolado.', 'alta'),
    (277, '61bd0288-38fe-45bc-9c1e-51c1ecc9a515'::uuid, 1, 'Chuva: dígrafo consonantal ''ch''', 'Regra testada: ''ch'' em ''chuva'' representa um único fonema consonantal /ʃ/, dígrafo consonantal (5 letras, 4 fonemas). Categoria: A) regra produtiva. Distratores exploram confundir dígrafo com encontro consonantal.', 'alta'),
    (278, '61bd0288-38fe-45bc-9c1e-51c1ecc9a515'::uuid, 1, 'Guerra: dígrafo ''gu'' (U mudo antes de E)', 'Regra testada: em ''guerra'', o ''u'' não tem realização fonética própria antes de ''e'' — ''gu'' representa o único fonema consonantal /g/, dígrafo. Categoria: A) regra produtiva. Distratores exploram casos em que o U soa (ex.: água), quando gu/qu deixam de ser dígrafo.', 'alta'),
    (320, '61bd0288-38fe-45bc-9c1e-51c1ecc9a515'::uuid, 1, 'Horas: H mudo reduz fonemas sem ser dígrafo', 'Regra testada: o H inicial de ''horas'' não tem valor fonético próprio e não forma dígrafo isolado — reduz a contagem para 5 letras e 4 fonemas. Categoria: A) regra produtiva. Distratores testam se o aluno confunde H mudo com dígrafo ou com encontro consonantal.', 'alta'),
    (686, '61bd0288-38fe-45bc-9c1e-51c1ecc9a515'::uuid, 1, 'Indivíduos: dígrafo vocálico ''in'' e ditongo crescente ''-uo'' (análise adotada pela banca)', 'Regras testadas: (I, correta) ''indivíduos'' tem 10 letras e 9 fonemas; (II, correta) ''in'' é dígrafo vocálico/nasal; (III, incorreta) o ''-uos'' final é ditongo CRESCENTE (semivogal+vogal), não decrescente, na análise adotada pela banca para esta questão — sem universalizar essa leitura para toda sequência -u(o)- independentemente da divisão silábica adotada. Categoria: A) regra produtiva + D) contraste (inversão crescente/decrescente). Gabarito: I e II corretas.', 'alta'),
    (687, '61bd0288-38fe-45bc-9c1e-51c1ecc9a515'::uuid, 1, 'Vogal epentética em encontros consonantais imperfeitos', 'Regra testada: encontros consonantais de articulação mais difícil na fala brasileira (gn, ct, cn) podem receber vogal epentética na realização oral, fenômeno distinto da grafia oficial da palavra; ''excluindo'' (encontro consonantal perfeito ''cl'') é a exceção apresentada. Categoria: A) regra produtiva, ensinado sem absolutos do tipo ''todo encontro imperfeito sofre epêntese'' — apenas descrevendo o fenômeno da fala e distinguindo-o da ortografia.', 'alta'),
    (756, '61bd0288-38fe-45bc-9c1e-51c1ecc9a515'::uuid, 1, 'Conversada (9 fonemas) x convidada (8 fonemas); dígrafo ''ss'' em pessoa/possíveis; 2 dígrafos em ''assunto''', 'Regras testadas: (I, incorreta) ''conversada'' tem 9 fonemas e ''convidada'' tem 8 fonemas — não são iguais; (II, incorreta) ''ss'' em ''pessoa'' e ''possíveis'' é dígrafo consonantal, não encontro consonantal; (III, correta) ''assunto'' tem 2 dígrafos (''ss'' + ''un'' nasal), 7 letras e 5 fonemas. Categoria: A) regra produtiva + D) contraste (dígrafo x encontro consonantal). Gabarito: apenas III.', 'alta'),
    (757, '61bd0288-38fe-45bc-9c1e-51c1ecc9a515'::uuid, 1, 'Outras: exceção sem dígrafo entre palavras com dígrafo', 'Regra testada: ''outras'' não possui dígrafo (''ou'' é ditongo, ''tr'' é encontro consonantal), 6 letras = 6 fonemas — é a exceção entre ''violento'', ''categorizasse'', ''indivíduos'' e ''desenhar'', que têm dígrafo. Categoria: D) contraste. Distratores exploram confundir ditongo com dígrafo.', 'alta'),
    (785, '61bd0288-38fe-45bc-9c1e-51c1ecc9a515'::uuid, 1, 'Separação silábica de ''patrulhas'': encontro consonantal e dígrafo inseparáveis', 'Regra testada: em ''pa-tru-lhas'', o encontro consonantal ''tr'' e o dígrafo ''lh'' permanecem na mesma sílaba (inseparáveis), aplicando os mesmos conceitos de dígrafo/encontro consonantal à separação silábica. Categoria: A) regra produtiva. Distratores separam incorretamente dígrafos inseparáveis (lh) ou ditongos inseparáveis (ou, ei) em outras palavras.', 'alta'),
    (808, '61bd0288-38fe-45bc-9c1e-51c1ecc9a515'::uuid, 1, 'Possuir: hiato entre ''u'' e ''i'' em sílabas diferentes', 'Regra testada: em ''pos-su-ir'', o ''u'' e o ''i'' pertencem a sílabas diferentes, configurando hiato — mesmo padrão de verbos em -uir (influir, construir). Categoria: A) regra produtiva. Distratores exploram ditongo crescente (indivíduo, quadro) e ditongo decrescente (aumentar) como falsos hiatos.', 'alta'),
    (884, '61bd0288-38fe-45bc-9c1e-51c1ecc9a515'::uuid, 1, 'Enfraquecidos: 13 letras, 2 dígrafos (en + qu), 11 fonemas', 'Regra testada: ''enfraquecidos'' tem 13 letras e 2 dígrafos (''en'' nasal + ''qu'' antes de ''e''), resultando em 11 fonemas. Categoria: A) regra produtiva — aplicação do procedimento completo de contagem (letras, dígrafos, fonemas efetivos), não apenas a fórmula de atalho.', 'alta'),
    (886, '61bd0288-38fe-45bc-9c1e-51c1ecc9a515'::uuid, 1, 'Corpo: 5 letras e 5 fonemas; ''rp'' é encontro consonantal imperfeito/disjunto', 'CORREÇÃO APLICADA: ''corpo'' tem 5 letras e 5 fonemas, sem dígrafo — mas a classificação do encontro ''rp'' é ENCONTRO CONSONANTAL IMPERFEITO/DISJUNTO (não ''perfeito''), pois a separação silábica é ''cor-po'', com R e P em sílabas diferentes, cada um mantendo seu próprio fonema. Categoria: A) regra produtiva + D) contraste (perfeito/puro x imperfeito/disjunto). Nota não bloqueante: 2 das 5 alternativas (''Corpo'', ''Bombeiros'') não aparecem literalmente no trecho citado no enunciado — são palavras de trecho posterior do mesmo artigo já visto integralmente em Q891 (conteúdo 20/Ortografia); a análise fonêmica de cada palavra independe disso e o gabarito permanece verificável de forma independente.', 'alta'),
    (887, '61bd0288-38fe-45bc-9c1e-51c1ecc9a515'::uuid, 1, 'Simultaneamente: 15 letras, 14 fonemas (mais letras que fonemas)', 'CORREÇÃO APLICADA: ''simultaneamente'' tem 15 letras e 14 fonemas (não 13, como a explicação armazenada concluía) — o grupo ''en'' de ''-mente'' funciona como dígrafo vocálico/nasal, reduzindo em 1 a contagem. O gabarito permanece correto porque a alternativa afirma apenas ''tem mais letras que fonemas'' (15 > 14, verdadeiro independentemente do valor exato). Categoria: A) regra produtiva. PENDÊNCIA DE SANEAMENTO REGISTRADA (não executada neste apply, nenhuma alteração de questão/alternativa/explicação): EXPLICACAO_INCONSISTENTE_CONTAGEM_FONEMAS — a explicação armazenada conclui ''13 fonemas'', divergente da contagem correta de 14; não propagar ''13'' para a futura aula.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (13/14).
-- 114,277,278,320,686,687,756,757,785,808,884,886,887

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): 885 (FORA_DE_ESCOPO_ACENTUACAO_TONICIDADE — cobra classificacao quanto a tonicidade (identificacao de palavras paroxitonas: vacina, aumento), habilidade do conteudo 26 (Acentuacao grafica, ja concluido), sem envolver nenhum conceito de fonema, digrafo ou encontro vocalico/consonantal. Provavel destino futuro: conteudo 26, ja concluido, NAO reaberto nesta operacao. Nao realocada nesta etapa.)

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Fonemas e dígrafos: 13 questoes distintas
-- Total de vinculos esperados: 13 (13 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
