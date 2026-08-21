-- Mapa de classificacao semantica das questoes validas de Pacto de San José da Costa Rica
-- (curso_conteudos.id = 72, assunto_id = 90,
-- materia_id = 11), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/pacto_de_san_jose_da_costa_rica.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_pacto_de_san_jose_da_costa_rica_teste_rollback.sql
--   classificar_questoes_unidades_pacto_de_san_jose_da_costa_rica.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo 72 (apos curadoria_unidades_pacto_de_san_jose_da_costa_rica.sql):
--   U1 b918b069-8364-4412-80a6-07d78b369317  ordem 1  Pacto de San José da Costa Rica
--
-- Resultado da curadoria: 11/11 questoes ativas
-- classificadas, multiunidade: nenhuma, excluidas: nenhuma.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
    (56, 'b918b069-8364-4412-80a6-07d78b369317'::uuid, 1, 'Liberdade pessoal — detenção arbitrária, dever de informação e prisão por dívida', 'I (verdadeira) ''ninguem pode ser submetido a detencao ou encarceramento arbitrarios'' — art. 7o, item 3. II (verdadeira) ''toda pessoa detida ou retida deve ser informada das razoes da sua detencao e notificada, sem demora, da acusacao...'' — art. 7o, item 4. III (FALSA, corrigida na microchecagem): a assertiva afirma que o principio de vedacao a prisao por divida ''LIMITA'' os mandados por obrigacao alimentar; o texto oficial (art. 7o, item 7) diz o oposto — ''este principio NAO limita os mandados de autoridade judiciaria competente expedidos em virtude de inadimplemento de obrigacao alimentar''. Assertiva III, sem a negativa ''nao'', e falsa. Gabarito ''Apenas I e II'' confere.', 'alta'),
    (130, 'b918b069-8364-4412-80a6-07d78b369317'::uuid, 1, 'Pena de morte — limites etários', 'Gabarito ''18 – 70'' — art. 4o, item 5, da CADH (''Nao se deve impor a pena de morte a pessoa que, no momento da perpetracao do delito, for menor de dezoito anos, ou maior de setenta, nem aplica-la a mulher em estado de gravidez''). QUASE-DUPLICATA: enunciado e alternativas praticamente identicos aos da Q822 (mesmo fundamento, mesmo gabarito) — mantida classificada por decisao do usuario, nenhuma desativacao nesta curadoria.', 'alta'),
    (140, 'b918b069-8364-4412-80a6-07d78b369317'::uuid, 1, 'Integridade pessoal, escravidão, prisão por dívida e finalidade das penas (V/F múltiplo)', 'Item1 (V) ''toda pessoa tem direito a que se respeite sua integridade fisica, psiquica e moral'' — art. 5o, item 1. Item2 (F, invertido — real ''nao limita'', a assertiva afirma que o principio ''se aplica'' aos mandados alimentares, invertendo o sentido) art. 7o, item 7. Item3 (F, invertido — real ''sem demora'', a assertiva diz ''quando conveniente'') art. 7o, item 4. Item4 (V) ''ninguem podera ser submetido a escravidao ou servidao e tanto estas como o trafico de escravos e o trafico de mulheres sao proibidos em todas as suas formas'' — art. 6o, item 1. Item5 (F, invertido — real ''penas privativas de liberdade'', a assertiva diz ''penas restritivas de direito'') art. 5o, item 6. Gabarito ''V-F-F-V-F'' confere.', 'alta'),
    (144, 'b918b069-8364-4412-80a6-07d78b369317'::uuid, 1, 'Garantias judiciais, liberdade pessoal e liberdade religiosa dos pais (assinale a INCORRETA)', 'Alt1 (verdadeira) ''presuncao de inocencia'' — art. 8o, item 2 (caput). Alt2 (INCORRETA selecionada, gabarito): ''contraditorio e ampla defesa, com os meios e recursos a ela inerentes'' — esta formula NAO e texto da CADH; e redacao literal da Constituicao Federal, art. 5o, LV (documentado aqui, nao incluido em artigos_esperados desta unidade por pertencer a outro diploma — e justamente por nao ser texto do tratado que a alternativa e a INCORRETA, ja que a questao pede os ''exatos termos'' da Convencao). Alt3 (verdadeira) ''toda pessoa tem direito a liberdade e a seguranca pessoal'' — art. 7o, item 1. Alt4 (verdadeira) ''ninguem pode ser submetido a detencao ou encarceramento arbitrario'' — art. 7o, item 3. Alt5 (verdadeira) ''os pais... tem direito a que seus filhos ou pupilos recebam a educacao religiosa e moral que esteja acorde com suas proprias conviccoes'' — art. 12, item 4.', 'alta'),
    (819, 'b918b069-8364-4412-80a6-07d78b369317'::uuid, 1, 'Distinção entre direitos civis e direitos econômicos/sociais/culturais', 'Gabarito ''Educacao'' (excecao) — vida, integridade pessoal e liberdade pessoal sao direitos civis enumerados no Capitulo II da CADH (arts. 4o, 5o e 7o, respectivamente); educacao nao e enumerada nesse capitulo, estando associada ao desenvolvimento progressivo tratado de forma programatica no art. 26 (Capitulo III — Direitos Economicos, Sociais e Culturais) ou ao Protocolo Adicional de San Salvador. MICROCHECAGEM: a questao nao cita nem remete materialmente ao conteudo do art. 26 — exige apenas o reconhecimento estrutural de que educacao nao esta no rol do Capitulo II. Por isso o art. 26 NAO foi incluido em artigos_esperados, documentado so como contexto estrutural.', 'alta'),
    (820, 'b918b069-8364-4412-80a6-07d78b369317'::uuid, 1, 'Prisão por dívida e assistência de tradutor/intérprete (V/F múltiplo)', 'Item1 (F) ''a Convencao nao autoriza a prisao civil por dividas em NENHUMA hipotese'' — falso, pois ha excecao para obrigacao alimentar, art. 7o, item 7. Item2 (V) ''a Convencao autoriza a prisao em virtude do inadimplemento de obrigacao alimentar'' — verdadeiro, mesmo art. 7o, item 7. Item3 (V) ''toda pessoa acusada de delito tem direito de ser assistida gratuitamente por tradutor ou interprete, se nao compreender ou nao falar o idioma do juizo ou tribunal'' — art. 8o, item 2, ''a''. Gabarito ''F-V-V'' confere.', 'alta'),
    (821, 'b918b069-8364-4412-80a6-07d78b369317'::uuid, 1, 'Suspensão de garantias em situações de emergência', 'Gabarito: ''A vida; a liberdade de consciencia e de religiao; da crianca; politicos'' — corresponde exatamente ao rol de direitos NAO suspensiveis do art. 27, item 2 (''...nao autoriza a suspensao dos direitos determinados nos seguintes artigos: 3 [personalidade juridica], 4 [vida], 5 [integridade pessoal], 6 [escravidao e servidao], 9 [legalidade e retroatividade], 12 [liberdade de consciencia e religiao], 17 [protecao da familia], 18 [nome], 19 [crianca], 20 [nacionalidade] e 23 [politicos]''): vida=art.4, liberdade de consciencia e religiao=art.12, da crianca=art.19, politicos=art.23 — todos no rol. Distratores citam direitos FORA do rol (garantias judiciais=art.8; protecao da honra e dignidade=art.11; liberdade de expressao e pensamento=art.13), corretamente falsos.', 'alta'),
    (822, 'b918b069-8364-4412-80a6-07d78b369317'::uuid, 1, 'Pena de morte — limites etários', 'Gabarito ''18 (dezoito) – 70 (setenta)'' — art. 4o, item 5, da CADH. QUASE-DUPLICATA: enunciado e alternativas praticamente identicos aos da Q130 (mesmo fundamento, mesmo gabarito, apenas com os numeros escritos por extenso) — mantida classificada por decisao do usuario, nenhuma desativacao nesta curadoria.', 'alta'),
    (823, 'b918b069-8364-4412-80a6-07d78b369317'::uuid, 1, 'Integridade pessoal e tratamento de pessoas privadas de liberdade', 'Enunciado cita literalmente ''ninguem deve ser submetido a torturas, nem a penas ou tratos crueis, desumanos ou degradantes. Toda pessoa privada da liberdade deve ser tratada com o respeito devido a dignidade inerente ao ser humano'' — correspondencia exata ao art. 5o, item 2. Gabarito ''Artigo 5 – Direito a Integridade Pessoal'' confere.', 'alta'),
    (824, 'b918b069-8364-4412-80a6-07d78b369317'::uuid, 1, 'Direitos da criança, indenização por erro judiciário, circulação, família e separação de menores (assinale a correta)', 'Alt1 (verdadeira, gabarito) ''toda crianca tem direito as medidas de protecao que a sua condicao de menor requer por parte da sua familia, da sociedade e do Estado'' — art. 19. Alt2 (falsa, invertida — real ''tem direito a ser indenizada'', a alternativa nega esse direito) art. 10. Alt3 (falsa, invertida — real ''nem ser privado do direito de nele entrar'', a alternativa afirma que pode ser privado) art. 22, item 5. Alt4 (falsa, invertida — real ''deve ser protegida pela sociedade E pelo Estado'', a alternativa diz ''pela mesma e nao pelo Estado'') art. 17, item 1. Alt5 (falsa, invertida — real ''devem ser separados dos adultos'', a alternativa diz ''podem ficar junto dos adultos'') art. 5o, item 5.', 'alta'),
    (825, 'b918b069-8364-4412-80a6-07d78b369317'::uuid, 1, 'Pena de morte por delito político, direito de defesa, trabalho forçado, non bis in idem e indenização por erro judiciário (assinale a correta)', 'Alt1 (falsa, invertida — real ''em nenhum caso'' a pena de morte pode ser aplicada a delitos politicos, a alternativa afirma que pode) art. 4o, item 4. Alt2 (verdadeira, gabarito) ''o acusado tem direito de defender-se pessoalmente ou de ser assistido por um defensor de sua escolha e de comunicar-se, livremente e em particular, com seu defensor'' — art. 8o, item 2, ''d''. Alt3 (falsa, invertida — real ''NAO constituem trabalhos forcados'' os servicos exigidos de pessoa reclusa, a alternativa afirma que constituem) art. 6o, item 3, ''a''. Alt4 (falsa, invertida — real ''nao podera ser submetido a novo processo'', a alternativa afirma que podera) art. 8o, item 4. Alt5 (falsa, invertida — real ''tem direito a ser indenizada'', a alternativa nega esse direito) art. 10.', 'alta')
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (11/11).
-- 56,130,140,144,819,820,821,822,823,824,825

-- 2b) Questoes multiunidade: nenhuma

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): nenhuma

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
-- U1 Pacto de San José da Costa Rica: 11 questoes distintas
-- Total de vinculos esperados: 11 (11 questoes distintas
-- + 0 vinculo(s) extra(s) de multiunidade).
