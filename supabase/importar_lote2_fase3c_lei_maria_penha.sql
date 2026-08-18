-- ============================================================================
-- LOTE 2 — FASE 3C — IMPORTACAO DAS 184 QUESTOES PRONTAS (SUB-LOTES 1-5 DA FASE 3B)
-- APLICACAO REAL — TERMINA EM COMMIT. So rodar depois que
-- supabase/importar_lote2_fase3c_lei_maria_penha_teste_rollback.sql tiver
-- rodado no SQL Editor com TODOS os asserts passando (RESUMO N/N).
-- Mantem TODOS os mesmos asserts do harness (nao removidos) — eles rodam
-- de novo aqui, dentro da MESMA transacao que efetivamente persiste, como
-- ultima revalidacao antes do COMMIT.
-- ============================================================================
--
-- Gerado automaticamente por scripts/generate-lote2-fase3c-harness.mjs a
-- partir de scripts/lote2-fase3b-sublote{1..5}-explicacoes.mjs e
-- supabase/lote2_fase3_estado/fase3b/fase3b_sublote{1..5}_conteudo.json.
-- NAO editar este arquivo a mao — editar a fonte e regerar.
--
-- Fase 3B concluida ate o sub-lote 5 de 14 (187 questoes com explicacao
-- pedagogica completa e validada). Sub-lotes 6-14 (333 candidatas restantes
-- do pool de 520 aprovadas na Fase 2/3A) NAO fazem parte desta importacao.
--
-- Reconciliacao contra o Supabase (assunto_id=19, 117 questoes existentes
-- antes desta importacao) feita nesta rodada, com comparacao robusta de
-- enunciado/alternativas (no minimo 3 metodos: tec_id citado no campo
-- fonte, hash exato do enunciado normalizado, e similaridade de palavras
-- Jaccard >= 0.5 com verificacao manual de cada par sinalizado):
--   - 3 duplicatas CONFIRMADAS (mesmo enunciado e mesmas alternativas de um
--     registro ja existente) — EXCLUIDAS desta importacao:
--       * caderno 303 (tec_id 3299442) = id existente 778
--       * caderno 231 (tec_id 3486856) = id existente 347
--       * caderno 232 (tec_id 3486853) = id existente 346
--   - 9 falsos-positivos identificados e descartados: questoes existentes
--     cujo campo fonte cita um tec_id que TAMBEM aparece em candidatas
--     deste lote, mas cujo enunciado/alternativas comparados na integra
--     provaram ser conteudo DIFERENTE (o numero de tec_id nao e um
--     identificador confiavel entre os dois lotes — foi reciclado/atribuido
--     a questoes distintas em algum ponto do historico). Essas 184 permanecem
--     aprovadas.
--
-- Composicao: 184 questoes novas, 766 alternativas. Todas entram como
-- "banco geral" (curso_questoes apenas, sem vinculo de unidade pedagogica —
-- essa classificacao, se desejada, seria uma curadoria separada, como foi
-- feito para o Lote 1). Elegiveis a Missao Final; nao aparecem na pratica
-- de nenhuma unidade especifica.
--
-- Usa a MESMA simulacao de claim JWT do admin cadastrado (via "set local"),
-- restrita a esta transacao, no mesmo padrao ja usado nos harnesses
-- anteriores desta materia.
--
-- Precisa rodar com um role de ESCRITA (nao funciona via MCP read-only).
-- ============================================================================

BEGIN;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

-- ----------------------------------------------------------------------------
-- Snapshot ANTES — prova de ausencia de efeito colateral fora do esperado.
-- ----------------------------------------------------------------------------
create temporary table _snapshot_antes on commit drop as
select
  (select count(*) from public.questoes)                     as total_questoes,
  (select count(*) filter (where assunto_id = 19) from public.questoes) as total_questoes_lmp,
  (select count(*) from public.alternativas)                 as total_alternativas,
  (select count(*) from public.unidades_pedagogicas)          as total_unidades,
  (select count(*) from public.curso_conteudos)               as total_conteudos,
  (select count(*) from public.curso_questoes)                as total_curso_questoes,
  (select count(*) from public.respostas_usuarios)            as total_respostas,
  (select count(*) from public.sessoes_estudo)                as total_sessoes,
  (select count(*) from public.questao_unidades_pedagogicas)  as total_vinculos;

-- ----------------------------------------------------------------------------
-- Staging: 184 questoes (chave local = tec_id, nunca usado como id real —
-- o id real vem do IDENTITY de public.questoes no INSERT abaixo).
-- ----------------------------------------------------------------------------
create temporary table _l2_questoes (
  tec_id bigint primary key,
  banca text,
  concurso text,
  ano int,
  enunciado text,
  explicacao text,
  fonte text
) on commit drop;

insert into _l2_questoes (tec_id, banca, concurso, ano, enunciado, explicacao, fonte) values
  (3627565, 'FEPESE', 'Pol Mun (Pref Chapecó)/Pref Chapecó/2025', 2025, 'De acordo com a Lei nº 11.340/2006 (Lei Maria da Penha), a violência contra a mulher que lhe cause dano emocional e diminuição da autoestima ou que lhe prejudique e perturbe o pleno desenvolvimento ou que vise degradar ou controlar suas ações, comportamentos, crenças e decisões, mediante ameaça, constrangimento, humilhação, manipulação, isolamento, vigilância constante, perseguição contumaz, insulto, chantagem, violação de sua intimidade, ridicularização, exploração e limitação do direito de ir e vir, ou qualquer outro meio, é denominada violência:', 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A definição do enunciado — dano emocional e diminuição da autoestima, prejuízo ao pleno desenvolvimento, degradar ou controlar ações mediante ameaça, constrangimento, humilhação, manipulação, isolamento, vigilância constante, perseguição contumaz, insulto, chantagem, violação de intimidade, ridicularização, exploração e limitação do direito de ir e vir — reproduz quase literalmente o art. 7º, II, da Lei 11.340/2006, que é a definição de violência psicológica.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Violência física é definida no art. 7º, I, como conduta que ofenda a integridade ou saúde corporal — nada no enunciado descreve agressão corporal.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Afetiva" não é modalidade nomeada pela Lei; a expressão "relação íntima de afeto" aparece no art. 5º, III, como âmbito de incidência, não como tipo de violência.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Emocional" não é o rótulo técnico usado pela Lei — o "dano emocional" é uma das consequências descritas dentro da própria definição de violência psicológica (art. 7º, II), mas o nome da modalidade é "psicológica".

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Violência moral é definida no art. 7º, V, como calúnia, difamação ou injúria — o enunciado não descreve ataque à honra/reputação, e sim controle e degradação psicológica.

BIZU DE PROVA:
Ameaça, constrangimento, humilhação, manipulação, isolamento, vigilância constante, perseguição contumaz, insulto, chantagem, violação de intimidade, ridicularização e limitação do direito de ir e vir = psicológica (art. 7º, II). "Emocional" e "afetiva" são pegadinhas de rótulo, não os nomes técnicos da Lei.', 'TEC Concursos — questão 3627565 — FEPESE — Pol Mun (Pref Chapecó)/Pref Chapecó/2025'),
  (3612926, 'FUNDATEC', 'Eng (Porto Mauá)/Pref Porto Mauá/Agrônomo/2025', 2025, 'Douglas e Andreia são namorados há três anos. Em um momento de fúria, Douglas agrediu Andreia na rua. A Lei Maria da Penha poderia ser aplicada nesse caso?', 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O art. 5º, III, c/c parágrafo único, da Lei 11.340/2006 configura violência doméstica em qualquer relação íntima de afeto na qual o agressor conviva ou tenha convivido com a ofendida, independentemente de coabitação — e o local da agressão (via pública, em vez de dentro de casa) é irrelevante, pois a Lei protege a relação entre as partes, não o espaço físico onde ocorre o fato.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A Lei não estabelece prazo mínimo de duração do relacionamento para caracterizar "relação íntima de afeto".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O local do fato não afasta a aplicação da Lei — o que importa é a natureza da relação entre agressor e vítima, não onde a agressão ocorreu.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não há exigência de coabitação, muito menos por prazo mínimo — o art. 5º, III, dispensa expressamente a coabitação.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A Lei se aplica desde a primeira ocorrência de violência — não exige reiteração/habitualidade para incidir.

BIZU DE PROVA:
"Relação íntima de afeto" é o âmbito mais amplo do art. 5º: dispensa coabitação, dispensa tempo mínimo de relacionamento, dispensa reiteração, e o local da agressão é irrelevante.', 'TEC Concursos — questão 3612926 — FUNDATEC — Eng (Porto Mauá)/Pref Porto Mauá/Agrônomo/2025'),
  (3607836, 'Instituto AVALIA', 'Ag Pol Jud (PC MS)/PC MS/Escrivão de Polícia Judiciária/2025', 2025, 'Durante uma discussão, Carla teve o celular destruído por seu ex-namorado Marcos, com quem não mantém mais convivência. Ele alegou que o aparelho continha mensagens ofensivas a ele. O fato ocorreu na casa de Carla. Inconformada, ela registrou ocorrência na delegacia. Considerando-se a situação narrada, é correto afirmar que', 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Destruir o celular de Carla configura violência patrimonial (art. 7º, IV — conduta que configure destruição parcial ou total de objeto da ofendida); o vínculo de ex-namorados se enquadra no art. 5º, III, que dispensa coabitação e alcança quem "tenha convivido" em relação íntima de afeto — o fim do relacionamento não afasta a Lei.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O art. 5º, III, dispensa expressamente a convivência atual — basta que o agressor "tenha convivido" com a ofendida em relação íntima de afeto.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Destruir um objeto da vítima é conduta que se enquadra tecnicamente na definição de violência patrimonial (art. 7º, IV); o motivo alegado por Marcos não reclassifica o fato como violência moral, pois o ato em si foi a destruição do bem, não uma ofensa à honra.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Por se tratar de violência doméstica e familiar (art. 5º, III), o fato não se limita a mero dano civil/penal comum — atrai o regime protetivo da Lei Maria da Penha.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A violência patrimonial é modalidade autônoma (art. 7º, IV) — não depende de lesão física concomitante para se configurar.

BIZU DE PROVA:
Destruir/reter/subtrair objeto, documento, instrumento de trabalho ou valor da vítima = patrimonial, independentemente do motivo alegado pelo agressor. "Ex" também é alcançado pela Lei — "tenha convivido" cobre relação já encerrada.', 'TEC Concursos — questão 3607836 — Instituto AVALIA — Ag Pol Jud (PC MS)/PC MS/Escrivão de Polícia Judiciária/2025'),
  (3605267, 'CEBRASPE (CESPE)', 'AJ (TJ PA)/TJ PA/Pedagogia/2025', 2025, 'Com base nas disposições do Programa Nacional de Direitos Humanos (PNDH-3), da Lei Maria da Penha (Lei n.º 11.340/2006) e da Lei da Mediação (Lei n.º 13.140/2015), julgue o item que se segue. São três os níveis de violência contra a mulher previstos na Lei Maria da Penha: violência física, violência psicológica e violência patrimonial.', 'GABARITO: ERRADO

POR QUE:
A Lei Maria da Penha prevê, no art. 7º, cinco formas de violência doméstica e familiar — física, psicológica, sexual, patrimonial e moral — e, desde a Lei 15.384/2026, uma sexta modalidade, a violência vicária (art. 7º, VI). A afirmativa erra tanto no número ("três") quanto no rol (já em 2025, quando a questão foi escrita, omitia sexual e moral; hoje omitiria também a vicária).

BIZU DE PROVA:
Sempre que a banca apresentar um número fechado de modalidades ("são X formas"), confira a lista completa: física, psicológica, sexual, patrimonial, moral e, desde 2026, vicária — seis ao todo. Enumeração incompleta ou com número diferente de 6 (salvo quando o enunciado disser "entre outras") deve ser tratada com desconfiança.

PEGADINHA:
A banca cita corretamente três das modalidades (física, psicológica e patrimonial), o que passa uma falsa sensação de precisão — o erro está em dizer que são SOMENTE essas três ("são três os níveis"), quando já em 2025 eram pelo menos cinco.', 'TEC Concursos — questão 3605267 — CEBRASPE (CESPE) — AJ (TJ PA)/TJ PA/Pedagogia/2025'),
  (3597162, 'IBAM', 'GCM (S Vicente)/Pref São Vicente/2025', 2025, 'A Lei Maria da Penha classifica diversas formas de agressão que afetam a dignidade da mulher no contexto familiar ou doméstico, considerando não apenas atos físicos, mas também aqueles que atingem sua integridade psíquica, moral e sexual. A correta identificação das condutas envolvidas é essencial para o adequado enfrentamento dessas violências. Sobre o tema, relacione corretamente os termos da Coluna A com as descrições da Coluna B. Coluna A (Termos) 1.Violência sexual. 2.Violência moral. 3.Violência psicológica. Coluna B (Descrições) (__)Impedir a mulher de sair de casa, controlar suas amizades ou telefonemas. (__)Impedir a mulher de usar contraceptivos. (__)Acusar falsamente a mulher de traição ou chamá-la publicamente de "prostituta". Assinale a alternativa que apresenta a sequência da associação correta dos itens acima.', 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A ordem correta é 3 (psicológica) – 1 (sexual) – 2 (moral). "Impedir a mulher de sair de casa, controlar suas amizades ou telefonemas" é violência psicológica (art. 7º, II — isolamento, limitação do direito de ir e vir). "Impedir a mulher de usar contraceptivos" é violência sexual (art. 7º, III — impedir o uso de método contraceptivo). "Acusar falsamente de traição ou chamar publicamente de ''prostituta''" é violência moral (art. 7º, V — calúnia e injúria).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A sequência "3, 2, 1" inverte sexual e moral: atribuiria moral ao segundo item (impedir contraceptivos) e sexual ao terceiro (chamar de "prostituta" publicamente), invertendo as definições legais.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A sequência "1, 2, 3" atribui sexual ao primeiro item (isolamento/controle de contatos), quando na verdade é psicológica; e psicológica ao terceiro (acusação pública), quando é moral.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A sequência "2, 3, 1" atribui moral ao primeiro item, psicológica ao segundo e sexual ao terceiro — nenhuma correspondência bate com as definições legais.

BIZU DE PROVA:
Isolamento/controle de contatos/vigilância = psicológica; impedir contracepção/constranger a ato sexual = sexual; calúnia/difamação/injúria (inclusive xingamento de cunho sexual dito publicamente, como "prostituta") = moral.', 'TEC Concursos — questão 3597162 — IBAM — GCM (S Vicente)/Pref São Vicente/2025'),
  (3596630, 'IBAM', 'Or So (Pref Franca)/Pref Franca/2025', 2025, 'A Lei nº 11.340, de 7 de agosto de 2006, também conhecida como Lei Maria da Penha representa um marco na luta contra a violência doméstica e familiar contra a mulher no Brasil. Nesse contexto, analise as formas de violência contra a mulher definidas na Lei Maria da Penha, a seguir. I. Violência psicológica. II. Violência patrimonial. III. Violência moral. Está correto o que se afirma em:', 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
As três modalidades citadas — psicológica (I), patrimonial (II) e moral (III) — são efetivamente formas de violência doméstica e familiar contra a mulher, previstas respectivamente nos incisos II, IV e V do art. 7º da Lei 11.340/2006.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Exclui indevidamente a violência moral (III), também prevista no art. 7º, V.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Exclui indevidamente a violência psicológica (I), prevista no art. 7º, II.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Exclui indevidamente a violência patrimonial (II), prevista no art. 7º, IV.

BIZU DE PROVA:
Quando a questão apenas confirma se as modalidades citadas SÃO formas de violência previstas na Lei — sem alegar que a lista é exaustiva — todas as alternativas que citarem psicológica, patrimonial, moral, física, sexual (e, desde 2026, vicária) estarão corretas; o cuidado é não excluir indevidamente nenhuma das citadas.', 'TEC Concursos — questão 3596630 — IBAM — Or So (Pref Franca)/Pref Franca/2025'),
  (3850498, 'FUNDATEC', 'AAd (Pref Imbé)/Pref Imbé/2025', 2025, 'Raíssa, mulher lésbica, foi injuriada por Ângela, colega de trabalho com quem Raíssa convive e mantém relação íntima de afeto, a despeito de não coabitarem. Considerando a situação hipotética, assinale a alternativa correta.', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
A injúria de Ângela contra Raíssa, no contexto de relação íntima de afeto entre as duas, configura violência doméstica e familiar na modalidade moral (art. 7º, V — calúnia, difamação ou injúria), aplicável independentemente de orientação sexual (art. 5º, parágrafo único) e de coabitação (art. 5º, III).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O parágrafo único do art. 5º dispõe que as relações pessoais ali enunciadas independem de orientação sexual, e o art. 5º, III, dispensa a coabitação — a Lei é plenamente aplicável ao caso.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A injúria configura especificamente violência moral (art. 7º, V), modalidade distinta e mais precisa do que a psicológica (art. 7º, II) — restringir apenas à psicológica ignora a tipificação específica dada pela Lei à calúnia/difamação/injúria.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Arma de fogo em poder do agressor pode ser objeto de apreensão imediata como medida protetiva de urgência (art. 22, I) — não há vedação a essa apreensão.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Quando necessário o afastamento do local de trabalho em razão da situação de violência doméstica, o art. 9º, §2º, II, assegura a manutenção do vínculo trabalhista de Raíssa por até seis meses.

BIZU DE PROVA:
Parágrafo único do art. 5º = orientação sexual da vítima é irrelevante para a incidência da Lei. Injúria/calúnia/difamação = sempre "moral" (art. 7º, V), nunca apenas "psicológica" quando a banca oferecer a opção mais específica.', 'TEC Concursos — questão 3850498 — FUNDATEC — AAd (Pref Imbé)/Pref Imbé/2025'),
  (3588587, 'VUNESP', 'GM (Itatiba)/Pref Itatiba/2025', 2025, 'A Lei nº 11.340/2006 – Lei Maria da Penha elenca, entre outras possíveis, as formas de violência doméstica e familiar contra a mulher. Sobre a violência moral, é correto afirmar que se caracteriza por qualquer conduta que configure', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
"Calúnia, difamação ou injúria contra a mulher" é a definição literal de violência moral dada pelo art. 7º, V, da Lei 11.340/2006.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Insulto, chantagem ou violação de intimidade" caracterizam violência PSICOLÓGICA (art. 7º, II), não moral.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Destruição parcial de objetos e documentos pessoais" caracteriza violência PATRIMONIAL (art. 7º, IV), não moral.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Ofensa à integridade ou saúde corporal" caracteriza violência FÍSICA (art. 7º, I), não moral.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Impedimento para uso de métodos contraceptivos" caracteriza violência SEXUAL (art. 7º, III), não moral.

BIZU DE PROVA:
Pegadinha clássica de "definição trocada" — a banca embaralha as definições das modalidades e pede a que pertence exatamente à modalidade perguntada. Palavras-chave: física=integridade/saúde corporal; psicológica=humilhação/isolamento/vigilância/insulto/chantagem/violação de intimidade; sexual=constranger/impedir contraceptivo; patrimonial=retenção/subtração/destruição de bens; moral=calúnia/difamação/injúria.', 'TEC Concursos — questão 3588587 — VUNESP — GM (Itatiba)/Pref Itatiba/2025'),
  (3586559, 'Instituto ACCESS', 'ASoc (Pref Apiaí)/Pref Apiaí/2025', 2025, 'A Lei Maria da Penha define os contextos em que se configura a violência doméstica e familiar contra a mulher, destacando que essa violência decorre da ação ou omissão baseada no gênero que lhe cause: I. Morte e/ou Lesão. II. Sofrimento físico, sexual ou psicológico. III. Dano moral ou patrimonial. Está correto o que se afirma em:', 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Os três itens reproduzem, em conjunto, o núcleo do art. 5º, caput — a violência doméstica e familiar é a ação ou omissão baseada no gênero que cause morte e/ou lesão (I), sofrimento físico, sexual ou psicológico (II) e dano moral ou patrimonial (III) — todos elementos literais do caput.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Exclui indevidamente o item III, também previsto no caput ("dano moral ou patrimonial").

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Exclui indevidamente o item I, também previsto no caput ("morte, lesão").

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Exclui indevidamente o item II, também previsto no caput ("sofrimento físico, sexual ou psicológico").

BIZU DE PROVA:
O caput do art. 5º descreve as CONSEQUÊNCIAS da violência doméstica (morte, lesão, sofrimento físico/sexual/psicológico, dano moral/patrimonial) — não confundir com o art. 7º, que descreve as MODALIDADES/formas de violência.', 'TEC Concursos — questão 3586559 — Instituto ACCESS — ASoc (Pref Apiaí)/Pref Apiaí/2025'),
  (3585297, 'VUNESP', 'ASoc (Pref Itatiba)/Pref Itatiba/2025', 2025, 'Um assistente social da Unidade Básica de Saúde atende a sra. Meire, 25 anos, casada com João e mãe de Sofia, de 03 anos, e de Luís, 05 anos. Ela relata que João é alcoolista crônico, está desempregado há muito tempo e, quando chega bêbado em casa, agride-a verbalmente, dizendo que ela é “uma inútil e que deve dar graças a Deus por tê-lo em sua vida”, profere palavrões e grita com as crianças. Além disso, João fica com o cartão bancário de Meire, por meio do qual recebe o Bolsa Família, e alega que faz isso porque “é o homem da casa”. Como ele nunca bateu em nenhum deles, ela nunca o denunciou. Marlene, sua vizinha, esclareceu que existem outras formas de violência além da física e pede que ela procure uma assistente social para maiores esclarecimentos. Assinale a alternativa que apresenta todas as formas de violência sofrida por Meire, com base na Lei Maria da Penha (Lei nº 11.340/2006).', 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Meire sofre violência psicológica (art. 7º, II — humilhação, insulto e xingamentos reiterados: "uma inútil", palavrões) e violência patrimonial (art. 7º, IV — retenção do cartão bancário e do valor do Bolsa Família, recurso econômico destinado a satisfazer suas necessidades). A Lei também define, separadamente, a violência moral como a conduta que configure calúnia, difamação ou injúria (art. 7º, V); como "insulto" (psicológica) e "injúria" (moral) descrevem, na prática, condutas de ofensa verbal muito próximas, a banca também classificou o relato sob o rótulo moral. Entre as cinco alternativas, B é a única que reúne psicológica e patrimonial sem incluir física ou sexual, que não ocorreram.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Não há relato de agressão física — o próprio enunciado esclarece que João "nunca bateu em nenhum deles".

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não há relato de agressão física nem sexual no caso.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não há relato de violência sexual, e "emocional" não é modalidade nomeada pela Lei (o efeito emocional integra a definição de violência psicológica, art. 7º, II).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Omite a violência psicológica, claramente presente na humilhação e nos xingamentos reiterados, e inclui física, que não ocorreu.

BIZU DE PROVA:
Quando o relato combinar humilhação/xingamento com retenção de cartão/benefício, pense primeiro em psicológica + patrimonial; desconfie de alternativas que "encaixem" física ou sexual sem qualquer relato de agressão corporal ou sexual.', 'TEC Concursos — questão 3585297 — VUNESP — ASoc (Pref Itatiba)/Pref Itatiba/2025'),
  (3574305, 'CPCON UEPB', 'Edu (Pref Pombal)/Pref Pombal/Social/2025', 2025, 'A Lei nº 11.340, de 07 de agosto de 2006, conhecida como a Lei Maria da Penha, considera como formas de violência doméstica e familiar contra a mulher, entre outras, a:', 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O art. 7º da Lei 11.340/2006 nomeia, "entre outras", as formas física, psicológica, sexual, patrimonial e moral de violência doméstica e familiar (incisos I a V) — exatamente o conjunto de termos corretos reunido pela alternativa B, sem inventar nem omitir nenhum dos cinco.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Emprega o termo "emocional", que não é modalidade nomeada pela Lei (o efeito emocional integra a definição da violência psicológica, mas o rótulo correto é "psicológica"), e ainda omite a violência física.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A palavra "apenas" está errada — o próprio enunciado alerta que a enumeração é "entre outras", e a Lei nomeia ao menos mais três modalidades (sexual, patrimonial, moral).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Além do "apenas" indevido, omite psicológica e patrimonial.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Acrescenta "violência religiosa", modalidade que não existe no rol do art. 7º.

BIZU DE PROVA:
O enunciado usa a expressão "entre outras" — isso já avisa que a lista não é fechada. Desconfie de qualquer alternativa com "apenas" e de qualquer termo que não seja um dos nomes técnicos da Lei: física, psicológica, sexual, patrimonial, moral e, desde 2026, vicária.', 'TEC Concursos — questão 3574305 — CPCON UEPB — Edu (Pref Pombal)/Pref Pombal/Social/2025'),
  (3564240, 'IGEDUC', 'ASoc (Pref Japaratinga)/Pref Japaratinga/2025', 2025, 'De acordo com o art. 6º da Lei nº 11.340/2006, assinale a alternativa CORRETA:', 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O art. 6º da Lei 11.340/2006 estabelece expressamente que "a violência doméstica e familiar contra a mulher constitui uma das formas de violação dos direitos humanos" — texto literal reproduzido pela alternativa.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Contraria diretamente o art. 6º, que reconhece a violência doméstica como violação de direitos humanos, e não como mero "conflito de natureza privada".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A Lei não trata a violência doméstica como questão "exclusivamente penal" — também estabelece políticas de prevenção, assistência social e educação (arts. 3º e 8º), além de vinculá-la expressamente aos direitos humanos.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A violência doméstica não se limita a infração administrativa — a Lei prevê, inclusive, o afastamento da Lei 9.099/1995 (art. 41) e mecanismos processuais penais próprios.

BIZU DE PROVA:
Art. 6º é curto e direto — decore a frase inteira: "constitui uma das formas de violação dos direitos humanos". Bancas costumam testá-lo isolado, com distratores que reduzem a violência doméstica a "problema privado" ou "questão exclusivamente penal/administrativa".', 'TEC Concursos — questão 3564240 — IGEDUC — ASoc (Pref Japaratinga)/Pref Japaratinga/2025'),
  (3543629, 'ESMAL', 'Est (MPE PI)/MPE PI/Graduação/Serviço Social/2025', 2025, 'Maria e João mantinham união estável há três anos, baseado na Lei Maria da Penha marque a alternativa CORRETA:', 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
João destruiu o celular de Maria, objeto que também servia de instrumento de trabalho dela — conduta que se enquadra literalmente na definição de violência patrimonial do art. 7º, IV (retenção, subtração, destruição parcial ou total de objetos, instrumentos de trabalho, bens, valores ou recursos econômicos).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O transtorno decorrente de dependência etílica não é causa de exclusão de responsabilidade nas medidas protetivas da Lei Maria da Penha nem impede a punição — a Lei não prevê essa hipótese de afastamento da resposta estatal.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A Lei não veda medida de privação de liberdade em razão da dependência financeira da vítima em relação ao agressor — essa dependência é fator de vulnerabilidade a ser considerado a favor da proteção da vítima, não do agressor.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Flagrante de violência física não é desviado para a rede de assistência social em substituição às medidas penais e protetivas cabíveis — o encaminhamento assistencial pode ocorrer de forma complementar, mas não no lugar das providências dos arts. 10 a 12.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O vínculo trabalhista assegurado pelo art. 9º, §2º, protege o emprego da MULHER em situação de violência quando ela precisa se afastar — não o emprego do agressor afastado por medida protetiva, e essa manutenção não é condicionada a ele ser "único provedor da família".

BIZU DE PROVA:
Destruição de instrumento de trabalho/objeto pessoal = patrimonial, mesmo que o motivo alegado pelo agressor seja outro. Dependência química/mental do agressor não é excludente de responsabilidade nem de medida protetiva na Lei Maria da Penha.', 'TEC Concursos — questão 3543629 — ESMAL — Est (MPE PI)/MPE PI/Graduação/Serviço Social/2025'),
  (3543432, 'ESMAL', 'Est (MPE PI)/MPE PI/Graduação/Psicologia/2025', 2025, 'violência doméstica contra a mulher pode assumir diversas formas. Analise as situações abaixo e assinale aquela que corresponde à violência moral, conforme descrito na Lei nº 11.340/2006.', 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Edson espalha para família e amigos comuns que Paula "é prostituta e adúltera" — conduta que atinge a honra e a reputação de Paula perante terceiros, ou seja, violência moral (art. 7º, V — calúnia/difamação/injúria).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Constranger o cônjuge a manter relações sexuais indesejadas mediante cobrança do "dever conjugal" configura violência sexual (art. 7º, III — constranger a manter relação sexual não desejada mediante coação), não moral.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Apropriar-se do cartão e trocar a senha da conta bancária, submetendo a vítima a prestar contas de gastos, configura violência patrimonial (art. 7º, IV — subtração de valores/recursos econômicos), não moral.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Impedir o uso de método contraceptivo configura violência sexual (art. 7º, III), não moral.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Perseguir a ex-companheira em local de trabalho, academia, redes sociais e por ligações de números diferentes configura violência psicológica ("perseguição contumaz" é expressamente citada no art. 7º, II), não moral.

BIZU DE PROVA:
Espalhar informação vexatória/falsa sobre a vítima para terceiros (família, amigos, redes sociais) = moral; perseguir/stalkear pessoalmente a vítima = psicológica ("perseguição contumaz" é termo literal do art. 7º, II).', 'TEC Concursos — questão 3543432 — ESMAL — Est (MPE PI)/MPE PI/Graduação/Psicologia/2025'),
  (3528682, 'IDCAP', 'FTNS (SESAB)/SESAB/Assistente Social/2025', 2025, 'De acordo com a Lei Maria da Penha, a violência doméstica contra a mulher deve ser abordada sob diversas formas. Nesse contexto assinale a alternativa que corresponde as formas de violência doméstica e familiar contra a mulher citadas nesta Lei.', 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
As cinco formas de violência doméstica e familiar contra a mulher nomeadas pelo art. 7º, incisos I a V, da Lei 11.340/2006 são física, psicológica, sexual, patrimonial e moral — exatamente o conjunto reunido pela alternativa E, sem nenhum termo inventado. (Ressalva: esta questão é de 2025, anterior à Lei 15.384/2026, que acrescentou a violência vicária como sexto inciso do art. 7º; à época os cinco incisos citados eram de fato o rol então vigente, e a alternativa E permanece a única redigida com termos tecnicamente corretos entre as opções oferecidas — nenhuma delas seria corrigida pela adição da vicária, pois nenhuma usa esse termo ou testa a completude do rol. Hoje, o rol completo do art. 7º tem seis modalidades.)

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Usa "social" e "fisiológica", termos que não correspondem a nenhuma modalidade nomeada pela Lei.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Usa "econômica", "social" e "emocional" — nenhum desses é o rótulo técnico usado pelo art. 7º (o efeito "econômico" integra a definição de patrimonial; "emocional" integra a de psicológica; mas os nomes das modalidades, tal como a Lei os nomeia, não são esses).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Usa "econômica" e "verbal", que também não são as modalidades nomeadas pela Lei.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Usa "econômica", "social" e "fisiológica" — mesmos termos equivocados de A e B combinados.

BIZU DE PROVA:
Memorize os cinco nomes EXATOS usados pela Lei até 2026: física, psicológica, sexual, patrimonial e moral (hoje, seis, com a vicária). Termos parecidos mas errados — "emocional", "fisiológica", "social", "econômica", "verbal" — são a pegadinha mais comum desse tipo de questão.', 'TEC Concursos — questão 3528682 — IDCAP — FTNS (SESAB)/SESAB/Assistente Social/2025'),
  (3520358, 'FACAPE', 'Ed Soc (Pref Afrânio)/Pref Afrânio/2025', 2025, 'A Lei Maria da Penha nº 11.340/2006 no Art. 5ª, caracteriza os espaços de violência doméstica e familiar praticados contra a mulher, sendo estes: I. No âmbito doméstico, compreendido como o espaço de convívio permanente de pessoas. II. No âmbito da família, compreendida como a comunidade formada por indivíduos que são ou se consideram aparentados. III. No âmbito público, que inclusive ocorra de forma esporadicamente. IV. Em qualquer relação intima de afeto, na qual o agressor conviva ou tenha convívio com a ofendida. V. As relações pessoais enunciadas neste artigo, dependerá da orientação sexual. Assinale alternativa CORRETA, conforme caracterizado pela Lei Maria da Penha:', 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Os itens I, II e IV reproduzem corretamente três âmbitos de incidência da Lei — I corresponde ao art. 5º, I (unidade doméstica); II corresponde ao art. 5º, II (família); IV corresponde ao art. 5º, III (relação íntima de afeto, na qual o agressor conviva ou tenha convivido com a ofendida).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Inclui o item III, falso — o art. 5º não prevê "âmbito público"; os âmbitos legais são unidade doméstica, família e relação íntima de afeto.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Inclui os itens III e V, ambos falsos — III inventa o "âmbito público" e V inverte o parágrafo único do art. 5º, que diz que as relações pessoais INDEPENDEM (não "dependerão") da orientação sexual.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Inclui os itens III e V, falsos pelos motivos acima.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Inclui o item V, falso pelo motivo acima, e omite o item I, verdadeiro.

BIZU DE PROVA:
Os três âmbitos do art. 5º são só estes: unidade doméstica (I), família (II) e relação íntima de afeto (III) — não existe "âmbito público" na Lei. O parágrafo único é categórico: as relações pessoais do artigo INDEPENDEM da orientação sexual.', 'TEC Concursos — questão 3520358 — FACAPE — Ed Soc (Pref Afrânio)/Pref Afrânio/2025'),
  (3517979, 'OBJETIVA CONCURSOS', 'MTP (Pref Lapa)/Pref Lapa/2025', 2025, 'Em concordância com a Lei nº 11.340/2006 - Lei Maria da Penha, são formas de violência doméstica e familiar contra a mulher, EXCETO:', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA (é a alternativa que NÃO é forma de violência doméstica e familiar prevista na Lei, pedida pelo enunciado):
"Institucional" não é uma das modalidades nomeadas pelo art. 7º da Lei 11.340/2006 — o rol legal nomeia física, psicológica, sexual, patrimonial e moral (e, desde a Lei 15.384/2026, também a vicária), mas não existe modalidade batizada de "institucional".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (é uma forma prevista, portanto não é a exceção pedida):
Física é modalidade expressamente prevista no art. 7º, I.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA (é uma forma prevista, portanto não é a exceção pedida):
Psicológica é modalidade expressamente prevista no art. 7º, II.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA (é uma forma prevista, portanto não é a exceção pedida):
Sexual é modalidade expressamente prevista no art. 7º, III.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA (é uma forma prevista, portanto não é a exceção pedida):
Patrimonial é modalidade expressamente prevista no art. 7º, IV.

BIZU DE PROVA:
Questões "EXCETO" pedem a alternativa que NÃO se encaixa — mesmo sem "moral" entre as opções aqui, "institucional" é claramente um nome inventado que não consta do art. 7º, então é ela a exceção.', 'TEC Concursos — questão 3517979 — OBJETIVA CONCURSOS — MTP (Pref Lapa)/Pref Lapa/2025'),
  (3500154, 'CEBRASPE (CESPE)', 'Psic (PF)/PF/Clínico/2025', 2025, 'Com base no disposto na Lei n.º 11.340/2006 (Lei Maria da Penha), julgue o item a seguir. Suponha que Juliana mantenha, há 7 anos, união estável com Marcos, o qual aparentava ser, nos primeiros anos de relacionamento, atencioso e gentil, tendo, com o passar do tempo, mudado de comportamento e passado a monitorar, mediante vigilância constante, as mensagens que Juliana recebia em seu celular, em violação de sua intimidade, tendo-lhe, inclusive, retido o aparelho celular. Suponha, ainda, que Marcos tenha passado a controlar as ações e os comportamentos de Juliana mediante manipulação. Nessa situação, de acordo com a Lei n.º 11.340/2006, Marcos praticou violência psicológica e violência patrimonial contra Juliana, restando configurada a violência doméstica e familiar na situação narrada.', 'GABARITO: CERTO

POR QUE:
Marcos pratica violência psicológica (art. 7º, II) ao monitorar mediante vigilância constante as mensagens de Juliana, violar sua intimidade e controlar suas ações e comportamentos mediante manipulação — condutas expressamente citadas no inciso II. Ao reter o aparelho celular de Juliana, Marcos também pratica violência patrimonial (art. 7º, IV — retenção de objeto/bem da ofendida). Como a relação é de união estável há 7 anos (âmbito da família e/ou relação íntima de afeto, art. 5º, II e III), está configurada a violência doméstica e familiar.

BIZU DE PROVA:
"Vigilância constante", "violação de intimidade" e "manipulação" são termos literais do art. 7º, II (psicológica); "retenção" de objeto é literal do art. 7º, IV (patrimonial). Quando o enunciado combina os dois tipos de conduta, a resposta certa reconhece AMBAS as modalidades.

PEGADINHA:
É fácil enxergar só a violência psicológica (vigilância, manipulação) e esquecer que reter o celular — impedir Juliana de usar seu próprio bem — também é, tecnicamente, violência patrimonial.', 'TEC Concursos — questão 3500154 — CEBRASPE (CESPE) — Psic (PF)/PF/Clínico/2025'),
  (3497447, 'COGEPS UNIOESTE', 'GM (Pref Cianorte)/Pref Cianorte/2025', 2025, 'De acordo com a Lei Federal nº 11.340 de 2006 (Lei Maria da Penha), pode-se dizer são formas de violência doméstica e familiar contra a mulher, entre outras:', 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
"Violência moral, entendida como qualquer conduta que configure calúnia, difamação ou injúria" reproduz corretamente a definição do art. 7º, V, associada ao rótulo certo.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Rotula como "violência sexual" a definição de "conduta que ofenda sua integridade ou saúde corporal" — essa é, na verdade, a definição de violência FÍSICA (art. 7º, I).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Rotula como "violência patrimonial" a definição de dano emocional/diminuição de autoestima/degradar-controlar mediante ameaça, humilhação etc. — essa é, na verdade, a definição de violência PSICOLÓGICA (art. 7º, II).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Rotula como "violência psicológica" a definição de retenção/subtração/destruição de objetos, bens e valores — essa é, na verdade, a definição de violência PATRIMONIAL (art. 7º, IV).

BIZU DE PROVA:
Essa questão testa se você decora o rótulo CERTO para cada definição — as bancas adoram trocar o nome da modalidade mantendo a definição de outra. Associe pela palavra-chave: corporal=física; emocional/autoestima/controle=psicológica; sexo/contracepção=sexual; objetos/bens/valores=patrimonial; calúnia/difamação/injúria=moral.', 'TEC Concursos — questão 3497447 — COGEPS UNIOESTE — GM (Pref Cianorte)/Pref Cianorte/2025'),
  (3496113, 'Instituto SECPLAN', 'GCM (Pref Pres Kennedy)/Pref Pres Kennedy/2025', 2025, 'O guarda municipal João atua, cotidianamente, em vigilância na área de determinada escola municipal, sendo pessoa querida dos professores, pais de alunos e dos próprios alunos. Nesse contexto, recebe informação de que uma das mães está recebendo agressões psicológicas no recinto do lar, por parte do seu esposo. Nos termos da Lei Maria da Penha, tal situação caracteriza:', 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Agressões psicológicas praticadas pelo esposo contra a mãe, no recinto do lar, configuram violência doméstica nos termos da Lei 11.340/2006 — o âmbito da unidade doméstica (art. 5º, I) e a modalidade psicológica (art. 7º, II) estão presentes.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A Lei rompe justamente com a ideia de que a violência doméstica seria "problema interno da família" a ser resolvido sem intervenção do Estado — o art. 6º define-a como violação de direitos humanos.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Pelo mesmo motivo, a Lei não trata a violência doméstica como algo "corriqueiro" ou normal dentro das relações familiares.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A Lei não reduz a violência doméstica a "mero litígio social" — tem tratamento jurídico próprio, com medidas protetivas e resposta penal específica.

BIZU DE PROVA:
Qualquer alternativa que minimize a violência doméstica como "problema privado", "corriqueiro" ou "mero litígio" estará sempre errada — o art. 6º é categórico ao classificá-la como violação de direitos humanos.', 'TEC Concursos — questão 3496113 — Instituto SECPLAN — GCM (Pref Pres Kennedy)/Pref Pres Kennedy/2025'),
  (3467391, 'Instituto Consulplan', 'Ass Soc (Niterói Prev)/Niterói Prev/2025', 2025, 'As Nações Unidas definem a violência contra as mulheres como “qualquer ato de violência de gênero que resulte ou possa resultar em danos ou sofrimentos físicos, sexuais ou mentais para as mulheres, inclusive ameaças de tais atos, coação ou privação arbitrária de liberdade, seja em vida pública ou privada”. No Brasil, considerando os mecanismos para coibir a violência doméstica e familiar contra a mulher, é correto afirmar que:', 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
"Violência moral, entendida como qualquer conduta que configure calúnia, difamação ou injúria" reproduz corretamente a definição do art. 7º, V.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Inverte o art. 5º, III — a relação íntima de afeto exige que o agressor CONVIVA ou TENHA CONVIVIDO com a ofendida; a alternativa erra ao dizer "não conviva e/ou não tenha convivido".

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O art. 8º, caput, estabelece que a política pública se dará por conjunto articulado de ações da União, dos Estados, do Distrito Federal, dos Municípios E de ações não governamentais — a alternativa erra ao excetuar justamente as ações não governamentais, que integram a política.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Atribui às violências física e psicológica a definição que, na verdade, é da violência PATRIMONIAL (art. 7º, IV — retenção/subtração/destruição de objetos, instrumentos de trabalho, bens, valores e recursos econômicos).

BIZU DE PROVA:
Art. 8º, caput — a política pública é feita por ações articuladas da União, Estados, DF, Municípios E de ações não governamentais (todos juntos). E lembre: "conviva OU tenha convivido" — não precisa ser relação atual.', 'TEC Concursos — questão 3467391 — Instituto Consulplan — Ass Soc (Niterói Prev)/Niterói Prev/2025'),
  (3464975, 'FUNDATEC', 'Cont (CRC RS)/CRC RS/2025', 2025, 'Considerando os aspectos gerais da Lei no 11.340/2006, Lei Maria da Penha, assinale a alternativa correta.', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O art. 5º, caput, admite expressamente que a violência doméstica e familiar se configure por "ação OU omissão" baseada no gênero — a alternativa reproduz corretamente essa possibilidade.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O Brasil não se recusou a ratificar convenções de proteção à mulher — pelo contrário, a própria ementa da Lei Maria da Penha invoca o cumprimento da Convenção sobre a Eliminação de Todas as Formas de Discriminação contra as Mulheres e da Convenção de Belém do Pará, ambas ratificadas pelo Brasil.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O art. 5º, III, dispensa expressamente a coabitação para configurar violência doméstica em relação íntima de afeto — não é requisito indispensável.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Ofender a saúde da mulher é justamente a definição de violência física do art. 7º, I — está, sim, entre as formas de violência doméstica e familiar.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O art. 8º, caput, estabelece justamente um "conjunto articulado de ações" integradas — a Lei busca a integração dos órgãos e instituições, não a independência entre eles.

BIZU DE PROVA:
"Ação OU omissão" (art. 5º, caput) é pegadinha recorrente — muita gente esquece que a omissão também configura violência doméstica, não só a ação.', 'TEC Concursos — questão 3464975 — FUNDATEC — Cont (CRC RS)/CRC RS/2025'),
  (3459059, 'Unifil', 'Op PS (Pref Alvorada do Sul)/Pref Alvorada do Sul/2025', 2025, 'Sobre as formas de violência doméstica e familiar contra a mulher, previstas na Lei Federal nº 11.340/2006, analise as assertivas e assinale a alternativa correta. I. Violência física, entendida como qualquer conduta que ofenda sua integridade ou saúde corporal. II. Violência patrimonial, entendida como qualquer conduta que configure retenção, subtração, destruição parcial ou total de seus objetos, instrumentos de trabalho, documentos pessoais, bens, valores e direitos ou recursos econômicos, incluindo os destinados a satisfazer suas necessidades. III. Violência psicológica, entendida como qualquer conduta que configure calúnia, difamação ou injúria.', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA (apenas I e II estão corretas):
I reproduz literalmente o art. 7º, I (violência física: conduta que ofenda integridade ou saúde corporal) e II reproduz literalmente o art. 7º, IV (violência patrimonial: retenção, subtração, destruição de objetos, instrumentos de trabalho, documentos, bens, valores e recursos econômicos).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (todas incorretas):
As assertivas I e II estão corretas, então nem todas as três podem estar incorretas.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA (todas corretas):
A assertiva III está errada — atribui à violência psicológica a definição de "calúnia, difamação ou injúria", que na verdade é a definição de violência MORAL (art. 7º, V), não psicológica.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA (apenas III):
A assertiva III está errada pelo motivo acima, e as assertivas I e II, que estão corretas, ficariam indevidamente excluídas.

BIZU DE PROVA:
Mais uma vez a troca de rótulo entre psicológica e moral — "calúnia, difamação ou injúria" é SEMPRE moral (art. 7º, V), nunca psicológica, mesmo que a conduta também cause sofrimento psíquico à vítima.', 'TEC Concursos — questão 3459059 — Unifil — Op PS (Pref Alvorada do Sul)/Pref Alvorada do Sul/2025'),
  (3453660, 'IBAM', 'GCM (Pref Arapiraca)/Pref Arapiraca/2025', 2025, 'A Lei nº 11.340 de 2006, Lei Maria da Penha, estabelece que “qualquer conduta que configure retenção, subtração, destruição parcial ou total de seus objetos, instrumentos de trabalho, documentos pessoais, bens, valores e direitos ou recursos econômicos” é forma de violência doméstica e familiar contra a mulher qualificada como:', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
A definição citada — "conduta que configure retenção, subtração, destruição parcial ou total de seus objetos, instrumentos de trabalho, documentos pessoais, bens, valores e direitos ou recursos econômicos" — reproduz literalmente o art. 7º, IV, definição de violência patrimonial.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A definição de violência moral (art. 7º, V) é "calúnia, difamação ou injúria" — não corresponde ao texto citado no enunciado.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A definição de violência física (art. 7º, I) é "conduta que ofenda sua integridade ou saúde corporal" — não corresponde ao texto citado.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A definição de violência psicológica (art. 7º, II) envolve dano emocional, diminuição de autoestima e condutas como ameaça, humilhação, isolamento e vigilância — não corresponde ao texto citado, que fala em retenção/destruição de bens.

BIZU DE PROVA:
Transcrição praticamente literal do art. 7º, IV — sempre que o enunciado citar "retenção, subtração, destruição de objetos/bens/valores/recursos econômicos", a resposta é patrimonial, sem exceção.', 'TEC Concursos — questão 3453660 — IBAM — GCM (Pref Arapiraca)/Pref Arapiraca/2025'),
  (3424637, 'VUNESP', 'Cuid Soc (Itapevi)/Pref Itapevi/2025', 2025, 'O artigo 7º da Lei Maria da Penha apresenta as formas de violência doméstica e familiar contra a mulher. São elas:', 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O art. 7º da Lei 11.340/2006 nomeia, em seus incisos I a V, as formas física, psicológica, sexual, patrimonial e moral de violência doméstica e familiar — exatamente os termos corretos reunidos pela alternativa A. (Ressalva: esta questão é de 2025, anterior à Lei 15.384/2026, que acrescentou a violência vicária como sexto inciso do art. 7º; à época os cinco incisos citados eram de fato o rol então vigente. A alternativa A permanece a única redigida com os termos tecnicamente corretos entre as opções oferecidas — nenhuma das demais seria corrigida pela adição da vicária, pois nenhuma delas usa esse termo; o teste real desta questão é precisão vocabular, não a contagem de modalidades.)

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Substitui "física" por "afetiva", termo que não é nome de nenhuma modalidade de violência da Lei.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Substitui "moral" por "imoral", palavra inexistente no rol legal.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Substitui "patrimonial" por "matrimonial" — palavra parecida, mas sem qualquer relação com a definição legal de violência patrimonial.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Combina os dois erros anteriores, substituindo "patrimonial" por "matrimonial" e "moral" por "imoral".

BIZU DE PROVA:
Essa questão testa precisão de vocabulário — preste atenção em trocas sutis de palavra parecida: "afetiva" no lugar de "física", "matrimonial" no lugar de "patrimonial", "imoral" no lugar de "moral". Hoje o rol completo do art. 7º tem seis modalidades (incluindo a vicária, desde a Lei 15.384/2026), mas nenhuma alternativa desta questão testa esse ponto.', 'TEC Concursos — questão 3424637 — VUNESP — Cuid Soc (Itapevi)/Pref Itapevi/2025'),
  (3407936, 'CEBRASPE (CESPE)', 'Ana (EMBRAPA)/EMBRAPA/Gestão de Pessoas/Saúde Ocupacional/2025', 2025, 'Com base nas disposições da lei que disciplina o Sistema Nacional de Políticas Públicas sobre Drogas e da Lei Maria da Penha, julgue o item a seguir. A configuração de violência doméstica e familiar contra a mulher no contexto de uma relação íntima de afeto entre agressor e ofendida independe de coabitação ou mesmo da época de ocorrência da convivência.', 'GABARITO: CERTO

POR QUE:
O art. 5º, III, da Lei 11.340/2006 dispõe que configura violência doméstica e familiar contra a mulher qualquer relação íntima de afeto na qual o agressor conviva OU TENHA CONVIVIDO com a ofendida, "independentemente de coabitação" — tanto a coabitação quanto a época em que a convivência ocorreu (passada ou presente) são irrelevantes para a configuração da violência doméstica nesse âmbito.

BIZU DE PROVA:
"Conviva ou tenha convivido" + "independentemente de coabitação" são os dois maiores "coringas" do art. 5º, III. Decore essa frase inteira; ela sozinha resolve boa parte das questões sobre o âmbito de incidência da Lei.

PEGADINHA:
Candidatos costumam achar que a relação precisa ser atual ou envolver coabitação para caracterizar violência doméstica — o item explora exatamente a generosidade do art. 5º, III, nesse ponto.', 'TEC Concursos — questão 3407936 — CEBRASPE (CESPE) — Ana (EMBRAPA)/EMBRAPA/Gestão de Pessoas/Saúde Ocupacional/2025'),
  (3379851, 'AVANÇASP', 'Ori Soc (Pref Caieiras)/Pref Caieiras/2025', 2025, 'Mariana vive um relacionamento abusivo com Roberto, que frequentemente a obriga a manter relações sexuais contra sua vontade, utilizando ameaças para intimidá-la. Além disso, ele a proíbe de utilizar métodos contraceptivos, afirmando que quer decidir sozinho sobre a possibilidade de ter filhos. Qual tipo de violência Mariana sofre, conforme a Lei Maria da Penha?', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Constranger Mariana a manter relações sexuais contra sua vontade mediante ameaça, e impedi-la de usar métodos contraceptivos, são condutas que se enquadram literalmente na definição de violência sexual do art. 7º, III (constranger a manter relação sexual não desejada mediante ameaça; impedir o uso de método contraceptivo).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Violência obstétrica é categoria distinta, relacionada a maus-tratos no contexto de parto/gestação por profissionais de saúde — não é modalidade nomeada pelo art. 7º da Lei Maria da Penha, e não é o que o caso narra.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Embora haja sofrimento psicológico envolvido, as condutas descritas — constranger a ato sexual e impedir contracepção — são especificamente tipificadas como violência sexual (art. 7º, III), classificação mais precisa.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não há relato de agressão à integridade física ou à saúde corporal de Mariana.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não há relato de calúnia, difamação ou injúria contra Mariana.

BIZU DE PROVA:
"Constranger a ato sexual não desejado" e "impedir uso de contraceptivo" são exemplos literais do art. 7º, III — sempre que aparecerem juntos no enunciado, a resposta é violência sexual.', 'TEC Concursos — questão 3379851 — AVANÇASP — Ori Soc (Pref Caieiras)/Pref Caieiras/2025'),
  (3379836, 'AVANÇASP', 'Ori Soc (Pref Caieiras)/Pref Caieiras/2025', 2025, 'Carla vive um relacionamento com Lucas, que frequentemente a manipula emocionalmente, fazendo-a sentir-se culpada por situações que não cometeu. Lucas também a isola de seus amigos e familiares, controla suas ações e impõe limitações ao seu direito de ir e vir, sempre utilizando insultos e humilhações para degradar sua autoestima. Esses comportamentos têm causado grande sofrimento emocional e dificuldade em tomar decisões. Qual tipo de violência Carla sofre, conforme a Lei Maria da Penha?', 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Manipular emocionalmente, isolar de amigos e familiares, controlar ações e limitar o direito de ir e vir, além de insultar e humilhar, reproduz quase integralmente o rol de condutas do art. 7º, II — definição de violência psicológica.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Violência de intimidação" não é modalidade nomeada pela Lei Maria da Penha.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não há relato de conduta sexual no caso de Carla.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Violência moral exige calúnia, difamação ou injúria (art. 7º, V) — ataque à honra/reputação perante terceiros; o relato de Carla descreve controle, isolamento e manipulação, que se enquadram mais precisamente como psicológica.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Violência de assédio" não é modalidade nomeada pela Lei Maria da Penha.

BIZU DE PROVA:
"Manipulação", "isolamento" e "limitação do direito de ir e vir" são termos literais do art. 7º, II — combinação típica de violência psicológica. Fique atento a nomes de modalidade "inventados" (intimidação, assédio) que soam plausíveis mas não existem no rol legal.', 'TEC Concursos — questão 3379836 — AVANÇASP — Ori Soc (Pref Caieiras)/Pref Caieiras/2025'),
  (3375655, 'FUNDATEC', 'Peda Soc (Pref Tangará da S)/Pref Tangará da S/2025', 2025, 'Em um relacionamento abusivo, o parceiro de uma mulher controla todas as suas redes sociais, impedindo-a de manter contato com amigos e familiares. Além disso, ela foi ridicularizada publicamente em postagens. Considerando o disposto na Lei Maria da Penha, o comportamento descrito caracteriza violência:', 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Controlar as redes sociais da vítima, impedindo-a de manter contato com amigos e familiares, é violência psicológica (art. 7º, II — isolamento, limitação do direito de ir e vir, controle de suas ações e comportamentos). Quanto à violência moral (art. 7º, V — calúnia, difamação ou injúria), sua fundamentação não decorre simplesmente da palavra "ridicularizada" — tomada isoladamente, "ridicularização" é ela própria um meio expressamente listado na definição de violência PSICOLÓGICA (art. 7º, II), não moral. O que desloca esse mesmo fato também para a violência moral é a natureza PÚBLICA da exposição: ridicularizar a vítima "em postagens", perante terceiros (o público das redes sociais), é o núcleo típico da ofensa à honra objetiva — atacar sua reputação/imagem diante de outras pessoas —, que é o que caracteriza a difamação (ou a injúria, conforme o conteúdo da postagem ofenda a reputação perante terceiros ou a dignidade da própria vítima). Em suma: o controle/isolamento sustenta psicológica; a exposição pública da ridicularização — não a ridicularização em si — sustenta moral.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Menciona apenas a violência psicológica, omitindo a violência moral decorrente da exposição pública da vítima ao ridículo perante terceiros (postagens).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não há relato de destruição/retenção de bens (patrimonial) nem de agressão corporal (física) — o controle descrito é sobre contatos e redes sociais, não sobre a posse do aparelho.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Menciona apenas a violência moral, omitindo a violência psicológica evidente no controle e isolamento social da vítima.

BIZU DE PROVA:
Cuidado: "ridicularização" sozinha é termo do art. 7º, II (psicológica), não do art. 7º, V (moral) — não conclua "moral" só porque a palavra "ridicularizar" apareceu. O que caracteriza moral é a ofensa à honra/reputação perante terceiros (calúnia, difamação, injúria); aqui, o elemento que sustenta "moral" é especificamente a publicização em postagens (exposição a um público), não a ridicularização em abstrato.', 'TEC Concursos — questão 3375655 — FUNDATEC — Peda Soc (Pref Tangará da S)/Pref Tangará da S/2025'),
  (3374318, 'CEBRASPE (CESPE)', 'Ana Min (MPE CE)/MPE CE/Direito/2025', 2025, 'Julgue o item que se segue, com base nas disposições das Leis n.º 9.613/1998, n.º 11.340/2006 e n.º 11.343/2006. A coabitação entre autor e vítima é prescindível para a configuração da violência doméstica e familiar.', 'GABARITO: CERTO

POR QUE:
O art. 5º, III, da Lei 11.340/2006 estabelece que a relação íntima de afeto configura violência doméstica e familiar "independentemente de coabitação" — ou seja, a coabitação é prescindível (dispensável) para a configuração da violência doméstica nesse âmbito.

BIZU DE PROVA:
"Prescindível" = dispensável, desnecessária. Sempre que a questão perguntar se a coabitação é "necessária", "indispensável" ou "requisito" para a violência doméstica em relação íntima de afeto, a resposta é NÃO — o art. 5º, III, é expresso ao dispensá-la.

PEGADINHA:
O uso da palavra "prescindível" (em vez de "dispensável", mais comum) pode confundir quem não conhece o termo — releia com atenção: prescindível = pode-se prescindir de = não é necessário.', 'TEC Concursos — questão 3374318 — CEBRASPE (CESPE) — Ana Min (MPE CE)/MPE CE/Direito/2025'),
  (3371310, 'OBJETIVA CONCURSOS', 'ACS (Pref Horizontina)/Pref Horizontina/2025', 2025, 'Segundo a Lei nº 11.340/2006 - Lei Maria da Penha, NÃO configura violência doméstica e familiar contra a mulher:', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA (é a alternativa que NÃO configura violência doméstica e familiar, pedida pelo enunciado):
Solicitar horas extras a funcionárias em razão de alto fluxo de trabalho é relação de natureza trabalhista comum, sem qualquer dos elementos do art. 5º (não há âmbito de unidade doméstica, de família ou de relação íntima de afeto entre chefe e funcionárias, nem ação/omissão baseada no gênero que cause dano) — não se trata de violência doméstica e familiar.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (configura violência doméstica, portanto não é a exceção pedida):
Impedir o uso de métodos contraceptivos pelo(a) parceiro(a) é violência sexual (art. 7º, III), praticada no âmbito de relação íntima de afeto (art. 5º, III).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA (configura violência doméstica, portanto não é a exceção pedida):
Usar os filhos para colocar em risco e perpetuar violência contra a ex-companheira é exatamente o padrão da violência vicária (art. 7º, VI, incluído pela Lei 15.384/2026) — violência praticada por meio de pessoa querida pela vítima, com o fim de atingi-la.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA (configura violência doméstica, portanto não é a exceção pedida):
Controlar, humilhar e isolar a própria filha, causando danos emocionais e psicológicos, configura violência psicológica (art. 7º, II) no âmbito da família (art. 5º, II); a proteção da Lei Maria da Penha alcança vítima do gênero feminino nessa relação familiar independentemente de sua idade, conforme o Tema Repetitivo 1.186 do STJ, que reconhece a incidência da Lei também quando a vítima é criança ou adolescente.

BIZU DE PROVA:
Questões "NÃO configura" pedem a única situação alheia ao gênero e aos âmbitos do art. 5º — aqui, a relação de trabalho comum (horas extras) é a única fora do alcance da Lei; todas as demais, inclusive mãe-filha e o uso dos filhos contra a ex-companheira (violência vicária), estão dentro da proteção da Lei Maria da Penha.', 'TEC Concursos — questão 3371310 — OBJETIVA CONCURSOS — ACS (Pref Horizontina)/Pref Horizontina/2025'),
  (3370534, 'OBJETIVA CONCURSOS', 'Mon Soc (Pref Galvão)/Pref Galvão/2025', 2025, 'Com base na Lei nº 11.340/2006 − Lei Maria da Penha, analisar o caso. G., ex-marido de E., publica em suas redes sociais que E. está utilizando os valores da pensão alimentícia dos filhos para proveito próprio, deixando-os passar necessidade. Na verdade, E. utiliza os valores exclusivamente para a subsistência dos filhos, sem abrir qualquer margem para o proveito próprio. Ao analisar o caso, conclui-se que G. está praticando o crime de:', 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Publicar informação falsa (calúnia) de que a ex-esposa desvia os valores da pensão alimentícia em proveito próprio, quando na verdade ela os utiliza integralmente para a subsistência dos filhos, configura violência moral (art. 7º, V — conduta caluniosa, que imputa falsamente um fato ofensivo à reputação de E.).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Não há retenção, subtração ou destruição de bens/valores de E. por parte de G. — o que ocorre é uma acusação falsa, não uma conduta patrimonial.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não há relato de agressão física.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Embora a publicação cause sofrimento psicológico, a conduta de G. se enquadra mais precisamente na definição específica de violência moral (calúnia) do art. 7º, V — "ridicularizar" não descreve com precisão o ato de imputar falsamente um fato desonroso.

BIZU DE PROVA:
Publicar acusação falsa que atinge a reputação da vítima perante terceiros = calúnia/difamação = moral (art. 7º, V). Não confunda com patrimonial só porque o tema de fundo é dinheiro/pensão — o que importa é a NATUREZA da conduta (uma acusação falsa), não o assunto de que ela trata.', 'TEC Concursos — questão 3370534 — OBJETIVA CONCURSOS — Mon Soc (Pref Galvão)/Pref Galvão/2025'),
  (3849975, 'FUNDATEC', 'Elet (Pref Imbé)/Pref Imbé/2025', 2025, 'Considerando as disposições da Lei nº 11.340/2006, Lei Maria da Penha, assinale a alternativa correta.', 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O parágrafo único do art. 5º da Lei 11.340/2006 estabelece que as relações pessoais enunciadas no artigo independem de orientação sexual — a alternativa reproduz corretamente essa regra.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A violência moral (calúnia, difamação ou injúria) é, sim, forma de violência doméstica e familiar prevista no art. 7º, V.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O art. 10 determina que a autoridade policial, ao tomar conhecimento da iminência de violência doméstica, adote de imediato as providências legais cabíveis — não há vedação a essa atuação imediata.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O art. 5º, III, dispensa expressamente a coabitação para configurar violência doméstica em relação íntima de afeto — a ausência de coabitação não afasta a proteção da Lei.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O art. 3º, §1º, atribui à família, à sociedade e ao poder público a criação das condições necessárias ao efetivo exercício, entre outros, do direito ao lazer da mulher — cabe, sim, à família essa responsabilidade.

BIZU DE PROVA:
Mais uma vez o parágrafo único do art. 5º — independência de orientação sexual é um dos pontos mais cobrados da parte introdutória da Lei.', 'TEC Concursos — questão 3849975 — FUNDATEC — Elet (Pref Imbé)/Pref Imbé/2025'),
  (3366976, 'Instituto CONSULPAM', 'GM (Pref Chorozinho)/Pref Chorozinho/2025', 2025, 'A Lei n.º 11.340/2006, ou Lei Maria da Penha, foi criada para prevenir e combater a violência doméstica e familiar contra a mulher, estabelecendo mecanismos de proteção e assistência às vítimas. A lei prevê medidas protetivas de urgência, penaliza agressores e busca garantir a integridade física, psicológica, moral e patrimonial das mulheres. Suas alterações ampliaram as formas de proteção, reforçando o compromisso do Estado na erradicação da violência de gênero. Sobre as disposições da lei Maria da Penha, assinale a alternativa CORRETA', 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A Lei Maria da Penha aplica-se independentemente da orientação sexual da vítima (art. 5º, parágrafo único), bastando que a violência tenha ocorrido no âmbito doméstico, familiar ou de relação íntima de afeto (art. 5º, I a III) — síntese correta dos critérios de incidência da Lei.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A Lei não exige vínculo matrimonial — abrange também relações informais e já encerradas, por força do art. 5º, III ("conviva ou tenha convivido", independentemente de coabitação).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A Lei não se limita a medidas penais — também prevê políticas de prevenção e mecanismos de assistência às vítimas (arts. 3º, 8º e 9º, entre outros).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
As medidas protetivas de urgência podem ser concedidas de forma autônoma, independentemente de inquérito ou processo penal em curso (art. 19), não exigindo o início prévio de ação penal.

BIZU DE PROVA:
Três blocos para fixar sobre o alcance da Lei: (1) independe de orientação sexual; (2) não exige matrimônio nem coabitação; (3) medidas protetivas podem ser concedidas de forma autônoma, sem depender de processo penal já iniciado.', 'TEC Concursos — questão 3366976 — Instituto CONSULPAM — GM (Pref Chorozinho)/Pref Chorozinho/2025'),
  (3363055, 'FUNDATEC', 'ASoc (Tangará S)/Pref Tangará da S/2025', 2025, 'Para os efeitos da Lei nº 10.741/2003, Lei Maria da Penha, configura violência doméstica e familiar contra a mulher qualquer ação ou omissão baseada no gênero que lhe cause morte, lesão, sofrimento físico, sexual ou psicológico e dano moral ou patrimonial, EXCETO:', 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA (é a alternativa que NÃO é um âmbito de incidência previsto no art. 5º, pedida pelo enunciado):
"Situação de vulnerabilidade social e econômica" não é um dos três âmbitos do art. 5º da Lei 11.340/2006 — os âmbitos legais são a unidade doméstica (I), a família (II) e a relação íntima de afeto (III); vulnerabilidade social/econômica não é, por si só, um âmbito de incidência da Lei. (Nota: o enunciado desta questão cita erroneamente a Lei Maria da Penha como "Lei nº 10.741/2003" — esse é o número do Estatuto do Idoso; a Lei Maria da Penha é a Lei nº 11.340, de 7 de agosto de 2006. O erro de citação é da banca original, mantido aqui tal como a prova apresentou, e não afeta o conteúdo cobrado, que reproduz corretamente os âmbitos do art. 5º.)

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (é um âmbito previsto, portanto não é a exceção pedida):
Reproduz literalmente o art. 5º, I — âmbito da unidade doméstica.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA (é um âmbito previsto, portanto não é a exceção pedida):
Reproduz literalmente o art. 5º, II — âmbito da família.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA (é um âmbito previsto, portanto não é a exceção pedida):
Reproduz literalmente o art. 5º, III — âmbito da relação íntima de afeto.

BIZU DE PROVA:
Os três âmbitos do art. 5º são só estes: unidade doméstica, família e relação íntima de afeto. Qualquer alternativa que fale em "vulnerabilidade social", "âmbito público" ou outro critério que não seja um desses três é sempre a exceção correta em questões desse formato. E fique atento: o número da Lei Maria da Penha é 11.340/2006 — "10.741/2003" é o Estatuto do Idoso.', 'TEC Concursos — questão 3363055 — FUNDATEC — ASoc (Tangará S)/Pref Tangará da S/2025'),
  (3349908, 'VUNESP', 'ASJ (TJ SP)/TJ SP/2025', 2025, 'A violência contra as mulheres constitui uma expressão da relação de desigualdade entre homens e mulheres. É uma violência baseada na afirmação da superioridade de um sexo sobre o outro, nomeadamente, dos homens sobre as mulheres. Trata-se de um fenômeno que afeta toda a sociedade, devendo ser considerado o contexto social em que esses atos de violência ocorrem. A Lei no 11.340/2006 (Lei Maria da Penha) define como formas de violência doméstica e familiar contra a mulher: a física, a psicológica, a sexual, a patrimonial e a moral. De acordo com o artigo art. 7o (V) da referida lei, a violência moral é entendida como qualquer conduta que configure calúnia, difamação ou', 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
O art. 7º, V, da Lei 11.340/2006 define violência moral como "qualquer conduta que configure calúnia, difamação ou injúria" — a alternativa E completa corretamente a frase com o termo literal da Lei. (Ressalva: o texto de apoio do enunciado apresenta "a física, a psicológica, a sexual, a patrimonial e a moral" como as formas de violência, sem o "entre outras" que consta do art. 7º, caput. Esta questão é de 2025, anterior à Lei 15.384/2026, que acrescentou a violência vicária como sexto inciso; a resposta pedida — completar a definição literal do inciso V — não depende dessa contagem, e nenhuma das alternativas seria alterada pela adição da vicária.)

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Desrespeito" não é o termo usado pelo art. 7º, V — a Lei fala especificamente em calúnia, difamação ou injúria, conceitos técnicos com definição própria no direito penal (Código Penal, arts. 138 a 140).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Humilhação" é termo do art. 7º, II (violência psicológica), não do inciso V.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Discriminação" não é o termo usado pelo art. 7º, V.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Ameaça" é um dos meios citados no art. 7º, II (violência psicológica: "mediante ameaça, constrangimento..."), não um termo do inciso V.

BIZU DE PROVA:
Calúnia, difamação e injúria são os três "crimes contra a honra" do Código Penal (arts. 138 a 140) — decore o trio junto com "moral" (art. 7º, V) e não confunda com os meios da violência psicológica (ameaça, humilhação, insulto etc., art. 7º, II).', 'TEC Concursos — questão 3349908 — VUNESP — ASJ (TJ SP)/TJ SP/2025'),
  (3340738, 'SELECON', 'Ass Soc (Pref Sinop)/Pref Sinop/2025', 2025, 'Fabrícia e Ana mantêm um relacionamento homoafetivo há 3 anos. Atualmente, Fabrícia tem se descontrolado muito, em função de ciúmes, levando a brigas em que, de forma recorrente, Ana é agredida. Em consonância com a Lei Maria da Penha, Lei nº 11.340/2006, no caso em tela, a proteção estabelecida:', 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O parágrafo único do art. 5º da Lei 11.340/2006 estabelece que as relações pessoais enunciadas no artigo independem de orientação sexual — a proteção da Lei Maria da Penha alcança Ana, vítima de agressão recorrente por parte de Fabrícia, independentemente de o relacionamento ser homoafetivo. Essa aplicação é também consolidada na jurisprudência do STJ e do STF, que reconhecem a incidência da Lei em relações homoafetivas.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O relacionamento homoafetivo não descaracteriza a violência doméstica — pelo contrário, o parágrafo único do art. 5º garante expressamente sua aplicação nesse contexto.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A Lei não condiciona sua aplicação a uma análise de "igualdade" entre as partes da relação — o critério é a existência de violência baseada no gênero dentro de uma relação íntima de afeto, independentemente da orientação sexual das envolvidas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A Lei não exige diferença de compleição física entre agressora e vítima como requisito de aplicação — esse critério não consta do art. 5º nem do art. 7º.

BIZU DE PROVA:
"Independe de orientação sexual" (art. 5º, parágrafo único) cobre tanto a vítima quanto, pela jurisprudência consolidada do STJ/STF, situações de violência entre parceiras em relações homoafetivas — a Lei protege a mulher em razão do gênero, não em razão da orientação sexual de quem quer que seja.', 'TEC Concursos — questão 3340738 — SELECON — Ass Soc (Pref Sinop)/Pref Sinop/2025'),
  (3259252, 'FGV', 'Del Pol (PC MG)/PC MG/2025', 2025, 'Carolina, Delegada de Polícia em uma unidade policial especializada em Belo Horizonte/MG, tomou as declarações, evitando-se a revitimização de uma mulher vítima de violência doméstica. A ofendida narrou que, em um primeiro momento, o seu companheiro lhe causou dano emocional e diminuição de autoestima, mediante constrangimento e manipulação. Na sequência, o agressor reteve os seus documentos pessoais, sempre agindo com dolo. Nesse cenário, considerando as disposições da Lei nº 11.340/2006, a conduta de causar dano emocional e diminuição de autoestima, mediante constrangimento e manipulação, caracteriza violência _____; por sua vez, a retenção de documentos pessoais configura violência _____. As lacunas são corretamente preenchidas, respectivamente, por', 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Causar dano emocional e diminuição de autoestima mediante constrangimento e manipulação é a definição literal de violência psicológica (art. 7º, II). Reter os documentos pessoais da ofendida é a definição literal de violência patrimonial (art. 7º, IV — retenção de documentos pessoais). A alternativa B preenche corretamente as duas lacunas, nessa ordem.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Física" não corresponde à primeira conduta descrita (dano emocional/diminuição de autoestima), que é psicológica, não física.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Moral" não corresponde à primeira conduta (é psicológica), e "física" não corresponde à segunda (retenção de documentos é patrimonial).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Inverte as respostas corretas: a primeira conduta é psicológica (não patrimonial) e a segunda é patrimonial (não moral).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Acerta a primeira lacuna (psicológica), mas erra a segunda — retenção de documentos pessoais é patrimonial (art. 7º, IV), não moral.

BIZU DE PROVA:
"Dano emocional/diminuição de autoestima mediante constrangimento e manipulação" = psicológica (art. 7º, II). "Retenção de documentos pessoais" = patrimonial (art. 7º, IV) — mesmo que o ato em si (reter um documento) pareça "controlar" a vítima, a Lei classifica a retenção de bens/documentos especificamente como patrimonial.', 'TEC Concursos — questão 3259252 — FGV — Del Pol (PC MG)/PC MG/2025'),
  (3238223, 'CEBRASPE (CESPE)', 'GAAPC (PC DF)/PC DF/Analista de Informática/Banco de Dados/2025', 2025, 'Considerando o disposto na Lei Maria da Penha (Lei n.º 11.340/2006) e, no que couber, o entendimento dos tribunais superiores, julgue o item a seguir. A violência doméstica e familiar contra a mulher praticada sob a forma moral compreende a conduta que lhe cause dano emocional e a diminuição de sua autoestima.', 'GABARITO: ERRADO

POR QUE:
A conduta que causa dano emocional e diminuição da autoestima é a definição literal de violência PSICOLÓGICA (art. 7º, II), não moral. A violência moral (art. 7º, V) é definida como qualquer conduta que configure calúnia, difamação ou injúria. O item erra ao atribuir a definição de uma modalidade a outra.

BIZU DE PROVA:
Mais uma vez a troca clássica de rótulo: "dano emocional e diminuição da autoestima" é sempre psicológica (art. 7º, II); "calúnia, difamação ou injúria" é sempre moral (art. 7º, V). Memorize esse par de definições distintas — é a pegadinha mais recorrente sobre as modalidades do art. 7º.

PEGADINHA:
O item usa linguagem técnica e precisa ("dano emocional e diminuição de sua autoestima"), dando aparência de transcrição fiel da Lei — mas troca deliberadamente o rótulo da modalidade (moral em vez de psicológica).', 'TEC Concursos — questão 3238223 — CEBRASPE (CESPE) — GAAPC (PC DF)/PC DF/Analista de Informática/Banco de Dados/2025'),
  (3237915, 'CEBRASPE (CESPE)', 'AAAPC (PC DF)/PC DF/Agente Administrativo/2025', 2025, 'Julgue o item a seguir, considerando as disposições da Lei Maria da Penha (Lei n.º 11.340/2006). Configura violência doméstica e familiar contra a mulher ação baseada no gênero que lhe cause dano patrimonial em relação íntima de afeto na qual o agressor tenha convivido com a ofendida, independentemente de coabitação.', 'GABARITO: CERTO

POR QUE:
O art. 5º, caput, da Lei 11.340/2006 inclui expressamente o dano patrimonial entre as consequências que caracterizam violência doméstica e familiar quando decorrentes de ação ou omissão baseada no gênero. O art. 5º, III, por sua vez, configura esse âmbito em qualquer relação íntima de afeto na qual o agressor tenha convivido com a ofendida, independentemente de coabitação. A situação descrita combina corretamente os dois dispositivos.

BIZU DE PROVA:
O caput do art. 5º não se limita a dano físico/psicológico — "dano moral ou patrimonial" também configura violência doméstica quando presentes o gênero como base da conduta e um dos três âmbitos (unidade doméstica, família ou relação íntima de afeto).

PEGADINHA:
É comum associar "violência doméstica" apenas a agressão física — este item testa se o candidato reconhece que dano exclusivamente patrimonial, dentro do âmbito adequado, já é suficiente para configurá-la.', 'TEC Concursos — questão 3237915 — CEBRASPE (CESPE) — AAAPC (PC DF)/PC DF/Agente Administrativo/2025'),
  (3824093, 'Instituto ACCESS', 'ASoc (Pref Rodeiro)/Pref Rodeiro/2025', 2025, 'A Lei Maria da Penha (Lei nº 11.3402006) tipifica as formas de violência doméstica e familiar contra a mulher, ampliando o entendimento para além da agressão física. O assistente social, ao atuar em equipes multidisciplinares, deve identificar corretamente a natureza das violações para intervir adequadamente. Com base nas definições legais dos tipos de violência, assinale a alternativa correta que descreve a violência moral.', 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
"Qualquer conduta que configure calúnia, difamação ou injúria" é a definição literal de violência moral dada pelo art. 7º, V, da Lei 11.340/2006.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Essa é a definição de violência patrimonial (art. 7º, IV — retenção, subtração, destruição de objetos, instrumentos de trabalho, documentos, bens, valores e recursos econômicos), não moral.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Essa é a definição de violência sexual (art. 7º, III — constranger a presenciar, manter ou participar de relação sexual não desejada), não moral.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Essa é a definição de violência psicológica (art. 7º, II — dano emocional, diminuição da autoestima, degradar ou controlar ações/comportamentos), não moral.

BIZU DE PROVA:
Clássica questão de "qual definição pertence à modalidade perguntada" — decore as palavras-chave: moral=calúnia/difamação/injúria; patrimonial=objetos/bens/documentos; sexual=constranger a ato sexual; psicológica=dano emocional/autoestima/controle.', 'TEC Concursos — questão 3824093 — Instituto ACCESS — ASoc (Pref Rodeiro)/Pref Rodeiro/2025'),
  (3168457, 'FEPESE', 'Mon (Pref São José)/Pref São José/2024', 2024, 'A Lei Maria da Penha (Lei nº 11.340/2006) é a principal legislação brasileira para enfrentar a violência contra a mulher. A norma é reconhecida pela ONU como uma das três melhores legislações do mundo no enfrentamento à violência de gênero. Assinale a alternativa correta com base no texto sobre a Lei Maria da Penha.', 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
"A Lei Maria da Penha classifica a violência doméstica nas categorias de violência patrimonial, violência sexual, violência física, violência moral e violência psicológica" é a única afirmativa verdadeira entre as cinco — reúne corretamente os cinco nomes então previstos no art. 7º, incisos I a V. (Ressalva: esta questão é de 2024, anterior à Lei 15.384/2026, que acrescentou a violência vicária como sexto inciso do art. 7º; a alternativa E permanece correta porque nenhuma das demais opções seria "corrigida" pela adição da vicária — todas têm defeitos independentes dessa contagem, como se vê abaixo.)

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A Lei Maria da Penha não é a única legislação brasileira sobre violência contra a mulher — há, por exemplo, o Código Penal (crimes contra a vida, contra a honra, contra a dignidade sexual) e a própria Lei do Feminicídio (Lei 13.104/2015), que a qualifica como circunstância do homicídio.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A violência doméstica não se limita à agressão física e ao estupro — o art. 7º prevê também as modalidades psicológica, patrimonial e moral (e, desde 2026, vicária).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A Lei do Feminicídio (Lei 13.104/2015) é lei distinta e posterior à Lei Maria da Penha (2006) — não foram sancionadas juntas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Contém dois erros: trata a Lei Maria da Penha como se fosse a "Lei do Feminicídio" (são leis diferentes) e inverte o fato histórico — o feminicídio foi INCLUÍDO no rol de crimes hediondos pela Lei 13.104/2015 (que alterou a Lei 8.072/1990), não excluído dele.

BIZU DE PROVA:
Lei Maria da Penha (11.340/2006) ≠ Lei do Feminicídio (13.104/2015) — são leis diferentes, com anos e finalidades distintas (a primeira cria mecanismos de proteção; a segunda qualifica o homicídio e o inclui entre os crimes hediondos). Bancas adoram confundir as duas.', 'TEC Concursos — questão 3168457 — FEPESE — Mon (Pref São José)/Pref São José/2024'),
  (3168235, 'FEPESE', 'Cuid (Pref São José)/Pref São José/2024', 2024, 'A Lei nº 11.340, de 7 de agosto de 2006, define a violência doméstica e familiar contra a mulher e os contextos em que ela pode ocorrer. Identifique abaixo as afirmativas verdadeiras ( V ) e as falsas ( F ) com base nos artigos 5º e 6º dessa Lei. ( ) Para os efeitos desta lei, configura violência doméstica e familiar contra a mulher qualquer ação ou omissão baseada no gênero que cause morte, lesão, sofrimento físico, sexual ou psicológico, bem como dano moral ou patrimonial. ( ) A violência doméstica e familiar contra a mulher pode ocorrer no âmbito da unidade doméstica, incluindo pessoas esporadicamente agregadas, mas excluindo aquelas sem vínculo familiar. ( ) A violência doméstica e familiar contra a mulher inclui situações que ocorrem no âmbito da família, sendo formada por indivíduos que são ou se consideram aparentados, unidos por laços naturais, por afinidade ou por vontade expressa. ( ) A violência doméstica e familiar contra a mulher pode ocorrer em qualquer relação íntima de afeto, independentemente de coabitação e orientação sexual. ( ) A violência doméstica e familiar contra a mulher não constitui uma violação dos direitos humanos, sendo considerada apenas uma questão de ordem privada. Assinale a alternativa que indica a sequência correta, de cima para baixo.', 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A sequência correta é V-F-V-V-F. Item 1: verdadeiro, reproduz o art. 5º, caput. Item 2: falso, pois o art. 5º, I, inclui as pessoas esporadicamente agregadas COM ou SEM vínculo familiar — o item erra ao dizer que exclui quem não tem vínculo familiar. Item 3: verdadeiro, reproduz o art. 5º, II. Item 4: verdadeiro, combina o art. 5º, III (independe de coabitação) com o parágrafo único (independe de orientação sexual). Item 5: falso, pois o art. 6º afirma exatamente o contrário — a violência doméstica constitui, sim, uma das formas de violação dos direitos humanos.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Marca o item 2 como verdadeiro e o item 5 como verdadeiro — ambos são falsos pelos motivos acima.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Marca o item 2 como verdadeiro (é falso) e o item 4 como falso (é verdadeiro).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Marca o item 1 como falso (é verdadeiro) e o item 4 como falso (é verdadeiro).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Marca o item 1 como falso (é verdadeiro) e o item 3 como falso (é verdadeiro).

BIZU DE PROVA:
Item 2 é a pegadinha central: o art. 5º, I, fala em unidade doméstica "com ou sem vínculo familiar, inclusive as esporadicamente agregadas" — é uma das definições mais abrangentes da Lei, e qualquer tentativa de restringi-la (excluindo quem não tem vínculo familiar) está errada.', 'TEC Concursos — questão 3168235 — FEPESE — Cuid (Pref São José)/Pref São José/2024'),
  (3167673, 'FGV', 'AJ (TJ RR)/TJ RR/Psicologia/2024', 2024, 'A violência doméstica contra a mulher pode assumir diversas formas. Analise as situações abaixo e assinale aquela que corresponde à violência moral, conforme descrita na Lei nº 11.340/2006.', 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Edson espalha para família e amigos comuns que Paula "é prostituta e adúltera" — conduta que atinge a honra e a reputação de Paula perante terceiros, configurando violência moral (art. 7º, V — calúnia, difamação ou injúria).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Constranger o cônjuge a manter relações sexuais indesejadas mediante cobrança do "dever conjugal" configura violência sexual (art. 7º, III), não moral.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Apropriar-se do cartão e trocar a senha da conta bancária, submetendo a vítima a prestar contas de gastos, configura violência patrimonial (art. 7º, IV), não moral.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Impedir o uso de método contraceptivo configura violência sexual (art. 7º, III), não moral.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Perseguir a ex-companheira em local de trabalho, academia, redes sociais e por ligações de números diferentes configura violência psicológica ("perseguição contumaz", art. 7º, II), não moral.

BIZU DE PROVA:
Espalhar informação vexatória/falsa sobre a vítima para terceiros = moral; perseguir/stalkear pessoalmente a vítima = psicológica ("perseguição contumaz" é termo literal do art. 7º, II).', 'TEC Concursos — questão 3167673 — FGV — AJ (TJ RR)/TJ RR/Psicologia/2024'),
  (3164311, 'Ibest', 'GCM (Pref Cristalina)/Pref Cristalina/2024', 2024, 'Com base na Lei n.º 11.340/2006, também conhecida como Lei Maria da Penha, que criou mecanismos para coibir a violência doméstica e familiar contra a mulher, em observância à Constituição Federal, à Convenção sobre a Eliminação de Todas as Formas de Discriminação contra as Mulheres e à Convenção Interamericana para Prevenir, Punir e Erradicar a Violência contra a Mulher, é correto afirmar que', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Reproduz literalmente o art. 5º, caput, combinado com o inciso III — configura violência doméstica e familiar qualquer ação ou omissão baseada no gênero que cause morte, lesão, sofrimento físico, sexual ou psicológico e dano moral ou patrimonial, em qualquer relação íntima de afeto na qual o agressor conviva ou tenha convivido com a ofendida, independentemente de coabitação.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Restringe indevidamente o âmbito da família a quem "coabite entre si por vontade expressa, ou seja, entre marido e mulher" — o art. 5º, II, é mais amplo (comunidade formada por indivíduos aparentados por laços naturais, afinidade OU vontade expressa) e não exige casamento nem coabitação.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Inventa uma exigência de comprovação de prejuízo físico efetivo para a violência psicológica, sob pena de "denunciação caluniosa" — não há essa exigência nem essa consequência na Lei.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Mistura a definição de violência sexual (art. 7º, III) com o rótulo "moral", e inventa uma causa de atipicidade ("se não houver cerceamento dos direitos sexuais") que não existe na Lei.

BIZU DE PROVA:
Quando a alternativa reproduzir o texto do art. 5º, caput + III quase palavra por palavra, geralmente é a correta — desconfie de alternativas que acrescentem exigências (coabitação, casamento, comprovação de dano físico) que a Lei não faz.', 'TEC Concursos — questão 3164311 — Ibest — GCM (Pref Cristalina)/Pref Cristalina/2024'),
  (3169874, 'VUNESP', 'GCM (Pref Peruíbe)/Pref Peruíbe/2024', 2024, 'Assinale a alternativa que, nos termos da Lei no 11.340, de 7 de agosto de 2006 (Lei “Maria da Penha”), contém, corretamente, uma forma de violência moral.', 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
"Cometer difamação" é uma das três condutas do art. 7º, V (calúnia, difamação ou injúria), que define violência moral.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Ofender a integridade física" corresponde à violência física (art. 7º, I), não moral.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Submeter a vítima à manipulação" corresponde à violência psicológica (art. 7º, II — "manipulação" é um dos meios ali listados), não moral.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Além de "isolamento" ser meio de violência psicológica (art. 7º, II), não moral, a alternativa erra a direção do sujeito: a Lei protege a vítima de isolamento, não "submete o acusado" a ele.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Além de "forçar ao matrimônio" ser elemento de violência sexual (art. 7º, III), não moral, a alternativa também erra a direção: a Lei trata de forçar a OFENDIDA ao matrimônio, não "obrigar o acusado".

BIZU DE PROVA:
Além de checar a modalidade certa, preste atenção em quem sofre a conduta — nas alternativas D e E deste tipo de pegadinha, a banca inverte o sujeito (fala em "o acusado" no lugar de "a vítima/ofendida"), o que já torna a alternativa incorreta por si só.', 'TEC Concursos — questão 3169874 — VUNESP — GCM (Pref Peruíbe)/Pref Peruíbe/2024'),
  (3171586, 'CEBRASPE (CESPE)', 'ACE (TC DF)/TC DF/Especializada/Arquivologia/2024', 2024, 'Acerca da Lei Maria da Penha (Lei n.º 11.340/2006), julgue o item a seguir, com base em seus dispositivos e na jurisprudência dos tribunais superiores. A aplicação da Lei Maria da Penha estende-se a mulheres trans.', 'GABARITO: CERTO

POR QUE:
A jurisprudência do Superior Tribunal de Justiça (6ª Turma, entendimento consolidado desde 2022) reconhece que a Lei Maria da Penha se aplica à violência doméstica e familiar contra mulheres trans, afastando o critério exclusivamente biológico e adotando a identidade de gênero como critério decisivo. O Supremo Tribunal Federal, em decisão de 2025, reafirmou e ampliou esse entendimento, estendendo as medidas protetivas da Lei também a homens em relações homoafetivas. Nenhuma alteração legislativa de 2026 reverteu esse entendimento.

BIZU DE PROVA:
O critério que define a proteção da Lei Maria da Penha é o GÊNERO (a condição de mulher, incluindo mulheres trans) e o contexto de relação doméstica/familiar/afetiva — não o sexo biológico atribuído ao nascimento. STJ (2022, reafirmado) e STF (2025) convergem nesse ponto.

PEGADINHA:
Questões desse tipo tentam levar o candidato a associar "Lei Maria da Penha" apenas a mulheres cisgênero — a jurisprudência atual rejeita expressamente esse critério biológico restritivo.

Fontes: [STJ decide que Lei Maria da Penha é aplicável também à violência contra mulheres trans](https://www.andes.org.br/conteudos/noticia/sTJ-define-que-lei-maria-da-penha-e-aplicavel-tambem-a-violencia-contra-mulheres-trans1); [STF estende proteção da Lei Maria da Penha a gays, travestis e mulheres trans](https://www.extraclasse.org.br/justica/2025/02/stf-estende-protecao-da-lei-maria-da-penha-a-gays-travestis-e-mulheres-trans/)', 'TEC Concursos — questão 3171586 — CEBRASPE (CESPE) — ACE (TC DF)/TC DF/Especializada/Arquivologia/2024'),
  (3163946, 'IBADE', 'AssSoc (Pref Recife)/Pref Recife/2024', 2024, 'De acordo com a Lei nº 11.340/2006, compreende-se por violência física:', 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
"Qualquer conduta que ofenda sua integridade ou saúde corporal" é a definição literal de violência física dada pelo art. 7º, I.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
É a definição de violência psicológica (art. 7º, II), não física.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
É a definição de violência patrimonial (art. 7º, IV), não física.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
É a definição de violência sexual (art. 7º, III), não física.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
É a definição de violência moral (art. 7º, V), não física.

BIZU DE PROVA:
Física é a definição mais curta e direta do art. 7º: "ofender integridade ou saúde corporal" — qualquer definição mais longa e elaborada (mencionando ameaça, isolamento, retenção de bens, constrangimento sexual ou calúnia) pertence a outra modalidade.', 'TEC Concursos — questão 3163946 — IBADE — AssSoc (Pref Recife)/Pref Recife/2024'),
  (3163528, 'IBADE', 'AssSoc (Pref Recife)/Pref Recife/2024', 2024, 'De acordo com a Lei Nº 11.340/2006, a violência sexual é compreendida como:', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Reproduz literalmente a definição de violência sexual do art. 7º, III — constranger a presenciar, manter ou participar de relação sexual não desejada; induzir a comercializar ou utilizar a sexualidade; impedir uso de contraceptivo; forçar ao matrimônio, gravidez, aborto ou prostituição; ou limitar/anular direitos sexuais e reprodutivos.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
É a definição de violência patrimonial (art. 7º, IV), não sexual.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
É a definição de violência física (art. 7º, I), não sexual.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
É a definição de violência psicológica (art. 7º, II), não sexual.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
É a definição de violência moral (art. 7º, V), não sexual.

BIZU DE PROVA:
Sexual é a definição mais longa e composta do art. 7º, III — reúne vários núcleos distintos (constranger a ato sexual, impedir contracepção, forçar matrimônio/gravidez/aborto/prostituição, limitar direitos reprodutivos). Se a definição falar em contracepção, gravidez ou prostituição, é sempre sexual.', 'TEC Concursos — questão 3163528 — IBADE — AssSoc (Pref Recife)/Pref Recife/2024'),
  (3178706, 'ICECE', 'GM (Pref Aratuba)/Pref Aratuba/2024', 2024, 'Qual das alternativas abaixo não constituem violência doméstica e familiar conforme Lei Maria da Penha?', 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA (é a que NÃO constitui violência doméstica e familiar, pedida pelo enunciado):
"Violência procedimental" não é modalidade nomeada pelo art. 7º da Lei 11.340/2006 — é termo inventado, sem correspondência legal.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (é uma forma prevista, portanto não é a exceção pedida):
Violência sexual é modalidade expressamente prevista no art. 7º, III.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA (é uma forma prevista, portanto não é a exceção pedida):
Violência psicológica é modalidade expressamente prevista no art. 7º, II.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA (é uma forma prevista, portanto não é a exceção pedida):
Violência patrimonial é modalidade expressamente prevista no art. 7º, IV.

BIZU DE PROVA:
Sempre que aparecer um nome de modalidade "diferente" e mais abstrato/processual (institucional, procedimental, cognitiva etc.) entre física, psicológica, sexual, patrimonial, moral e vicária, desconfie — provavelmente é a exceção inventada pela banca.', 'TEC Concursos — questão 3178706 — ICECE — GM (Pref Aratuba)/Pref Aratuba/2024'),
  (3135241, 'Instituto Verbena', 'Estag (MPE GO)/MPE GO/Residência Jurídica/2024', 2024, 'De acordo com a Lei nº 11.340/06 (Lei Maria da Penha), a violência patrimonial se configura como qualquer conduta que', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Reproduz literalmente a definição de violência patrimonial do art. 7º, IV — conduta que configure retenção, subtração, destruição parcial ou total de objetos, instrumentos de trabalho, documentos pessoais, bens, valores e direitos ou recursos econômicos.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Descreve violência física (art. 7º, I — bater, empurrar, sacudir, chutar etc.), não patrimonial.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Descreve violência moral (art. 7º, V — desonrar com mentiras/ofensas, acusar publicamente de crime = calúnia/difamação/injúria), não patrimonial.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Descreve violência psicológica (art. 7º, II — dano emocional, diminuição de autoestima, degradar/controlar mediante ameaça, constrangimento, humilhação), não patrimonial.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Descreve violência sexual (art. 7º, III — constranger a presenciar/manter/participar de relação sexual não desejada), não patrimonial.

BIZU DE PROVA:
Patrimonial é sempre sobre OBJETOS/BENS/DOCUMENTOS/VALORES/DINHEIRO da vítima — se a descrição menciona corpo, autoestima, sexo ou reputação, é outra modalidade.', 'TEC Concursos — questão 3135241 — Instituto Verbena — Estag (MPE GO)/MPE GO/Residência Jurídica/2024'),
  (3179836, 'Instituto Consulplan', 'CCLar (Pref Esmeraldas)/Pref Esmeraldas/2024', 2024, 'A Lei Maria da Penha, em seu Art. 2º dispõe: “toda mulher, independentemente de classe, raça, etnia, orientação sexual, renda, cultura, nível educacional, idade e religião, goza dos direitos fundamentais inerentes à pessoa humana, sendo-lhe asseguradas as oportunidades e facilidades para viver sem violência, preservar sua saúde física e mental e seu aperfeiçoamento moral, intelectual e social”. S é cuidadora da Casa Lar da Prefeitura Municipal de Esmeraldas e tem contato com várias mulheres que foram vítimas de violência doméstica e familiar. A organização de um projeto intersetorial e multiprofissional convidou S para contar sua experiência para um grupo de mulheres reunidas no salão paroquial. Considerando o exposto, as falas de S na palestra estão corretas, EXCETO:', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA (é a fala INCORRETA de S, pedida pelo enunciado "EXCETO"):
A violência patrimonial não está restrita a mulheres com maiores recursos financeiros — qualquer mulher, independentemente de sua condição econômica, pode ter objetos, documentos, instrumentos de trabalho ou valores retidos, subtraídos ou destruídos (art. 7º, IV). Vincular a violência patrimonial a maior poder aquisitivo é afirmação incorreta e não decorre da Lei.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (é fala correta de S, portanto não é a exceção pedida):
A violência doméstica pode, de fato, ocorrer em qualquer núcleo familiar, independentemente de sua composição — decorre da amplitude dos âmbitos do art. 5º.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA (é fala correta de S, portanto não é a exceção pedida):
Nem idade nem religião excluem a mulher da proteção da Lei — o art. 5º não estabelece essas restrições.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA (é fala correta de S, portanto não é a exceção pedida):
O parágrafo único do art. 5º garante expressamente que a proteção independe de orientação sexual, alcançando também mulheres da comunidade LGBTQIA+.

BIZU DE PROVA:
Questões "EXCETO" sobre quem a Lei protege costumam esconder a pegadinha em uma condição restritiva (só quem tem dinheiro, só quem é jovem, só quem é heterossexual) — a Lei Maria da Penha é deliberadamente ampla e não faz essas distinções.', 'TEC Concursos — questão 3179836 — Instituto Consulplan — CCLar (Pref Esmeraldas)/Pref Esmeraldas/2024'),
  (3126303, 'FAUEL', 'Psico (Pref Maringá)/Pref Maringá/2024', 2024, 'A Lei nº 11.340, de 7 de agosto de 2006, institui mecanismos para promover e proteger a igualdade de gênero, combatendo a violência doméstica e familiar contra a mulher. Mediante o exposto, é considerada uma forma de violência doméstica e familiar contra a mulher:', 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Violência patrimonial é modalidade expressamente prevista no art. 7º, IV, da Lei 11.340/2006.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Violência financeira" não é o nome usado pela Lei — o efeito financeiro/econômico integra a definição de violência PATRIMONIAL (art. 7º, IV), mas o rótulo correto é "patrimonial".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Violência anímica" não é modalidade nomeada pela Lei.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Violência corruptiva" não é modalidade nomeada pela Lei.

BIZU DE PROVA:
Termos parecidos com "patrimonial" mas tecnicamente errados (financeira, econômica) são pegadinha recorrente — o nome oficial usado pela Lei é sempre "patrimonial".', 'TEC Concursos — questão 3126303 — FAUEL — Psico (Pref Maringá)/Pref Maringá/2024'),
  (3125995, 'ITAME', 'AASoc (Pref Acreúna)/Pref Acreúna/2024', 2024, 'Dentre as formas elencadas, na Lei Maria da Penha, de violência doméstica e familiar contra a mulher está a violência moral, que é entendida como:', 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
"Qualquer conduta que configure calúnia, difamação ou injúria" é a definição literal de violência moral dada pelo art. 7º, V.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
É a definição de violência patrimonial (art. 7º, IV), não moral.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Combina trechos da definição de violência sexual (art. 7º, III — constranger a presenciar relação sexual, forçar ao matrimônio/gravidez/aborto/prostituição), não moral.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Parafraseia trechos da definição de violência psicológica (art. 7º, II — prejudicar o pleno desenvolvimento, limitar o direito de ir e vir, prejuízo à autodeterminação), não moral.

BIZU DE PROVA:
Quando as alternativas misturam pedaços de definições de modalidades diferentes (em vez de reproduzir uma definição inteira e correta), desconfie — normalmente só uma reproduz fielmente a modalidade perguntada.', 'TEC Concursos — questão 3125995 — ITAME — AASoc (Pref Acreúna)/Pref Acreúna/2024'),
  (3124680, 'FAUEL', 'Ed Soc (Pref Maringá)/Pref Maringá/2024', 2024, 'Com a Lei Maria da Penha (Lei nº 11.340, de 7 de agosto de 2006) define as formas de violência doméstica e familiar contra a mulher?', 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
"As violências física, psicológica, sexual, patrimonial e moral" reúne corretamente os cinco nomes então previstos no art. 7º, incisos I a V, da Lei 11.340/2006. (Ressalva: esta questão é de 2024, anterior à Lei 15.384/2026, que acrescentou a violência vicária como sexto inciso; a alternativa B permanece a única correta porque nenhuma das demais seria "corrigida" pela adição da vicária — todas têm defeitos independentes dessa contagem.)

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Restringe indevidamente a "apenas a violência física" — a Lei prevê expressamente mais modalidades.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Restringe indevidamente a "somente física e sexual" — omite psicológica, patrimonial e moral.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Substitui patrimonial e moral por "financeira, política e econômica", termos que não são os nomes usados pela Lei.

BIZU DE PROVA:
Memorize os cinco nomes exatos usados pela Lei até 2026: física, psicológica, sexual, patrimonial e moral (hoje, seis, com a vicária). Alternativas com "apenas"/"somente" ou com termos parecidos mas errados (financeira, política, econômica) são a pegadinha mais comum.', 'TEC Concursos — questão 3124680 — FAUEL — Ed Soc (Pref Maringá)/Pref Maringá/2024'),
  (3181496, 'Instituto Consulplan', 'Ed Soc (Pref Esmeraldas)/Pref Esmeraldas/2024', 2024, 'A Lei Maria da Penha, nº 11.340/2006, define que a violência doméstica contra a mulher é crime e aponta as formas de evitar, enfrentar e punir a agressão. Também indica a responsabilidade que cada órgão público tem para ajudar a mulher que está sofrendo a violência. Ao se tratar sobre formas de violência doméstica e familiar contra a mulher, entendida como qualquer conduta que configure retenção, subtração, destruição parcial ou total de seus objetos, instrumentos de trabalho, documentos pessoais, assim como aquela entendida como qualquer conduta que configure calúnia, difamação ou injúria, têm-se, respectivamente, as violências:', 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Retenção, subtração ou destruição de objetos, instrumentos de trabalho e documentos pessoais é a definição de violência patrimonial (art. 7º, IV); calúnia, difamação ou injúria é a definição de violência moral (art. 7º, V). A alternativa C nomeia corretamente as duas, na ordem em que aparecem no enunciado.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Econômica" não é o nome usado pela Lei para a segunda conduta (calúnia/difamação/injúria é moral, não econômica), e a ordem também está incorreta.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Erra a primeira conduta — retenção/destruição de objetos e documentos é patrimonial (art. 7º, IV), não moral.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Acerta a primeira conduta (patrimonial), mas erra a segunda — calúnia/difamação/injúria é moral (art. 7º, V), não psicológica.

BIZU DE PROVA:
Retenção/destruição de objetos e documentos = patrimonial; calúnia/difamação/injúria = moral. É a combinação mais cobrada em questões de "associe a conduta à modalidade".', 'TEC Concursos — questão 3181496 — Instituto Consulplan — Ed Soc (Pref Esmeraldas)/Pref Esmeraldas/2024'),
  (3105580, 'FGV', 'Psic (Pref Abreu e Lima)/Pref Abreu e Lima/2024', 2024, 'Helena é uma mulher trans e vive maritalmente com Murilo, que é um homem trans. Enciumado por ter encontrado a companheira com um ex-namorado na rua, Murilo passou a agredi-la com palavras de baixo calão, humilhando-a na via pública. Na perspectiva da violência contra a mulher, podemos afirmar acertadamente que', 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Murilo agride Helena verbalmente com palavras de baixo calão, humilhando-a em via pública — conduta que se enquadra na definição de violência psicológica (art. 7º, II — humilhação, insulto). A jurisprudência do STJ (6ª Turma, desde 2022) e do STF (2025) reconhece que a Lei Maria da Penha se aplica à violência doméstica e familiar contra mulheres trans, com base na identidade de gênero, não no sexo atribuído ao nascimento — Helena, mulher trans, está plenamente protegida.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Contraria diretamente a jurisprudência consolidada do STJ e do STF, que rejeita o critério exclusivamente biológico e reconhece a aplicação da Lei a mulheres trans.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O fato de Murilo ser um homem trans não afasta a caracterização de violência de gênero — o que importa é que a conduta tenha sido praticada contra Helena em razão de sua condição de mulher, dentro de uma relação íntima de afeto (art. 5º, III), independentemente da identidade de gênero de quem a pratica.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não há relato de agressão à integridade física ou saúde corporal — a conduta descrita (palavras de baixo calão, humilhação) é verbal/psicológica, não física.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Parte de premissa juridicamente equivocada e desrespeitosa — reduz Murilo a seu "sexo biológico" para tentar torná-lo vítima da situação, invertendo os fatos narrados (quem sofreu a humilhação foi Helena) e contrariando o próprio critério de identidade de gênero adotado pela jurisprudência do STJ/STF.

BIZU DE PROVA:
A identidade de gênero — não o sexo atribuído ao nascimento — é o critério que define quem a Lei Maria da Penha protege como mulher. Isso vale tanto para a vítima (mulher trans protegida) quanto para não admitir o inverso (reduzir alguém a "sexo biológico" para negar ou inverter a proteção).

Fontes: [STJ decide que Lei Maria da Penha é aplicável também à violência contra mulheres trans](https://www.andes.org.br/conteudos/noticia/sTJ-define-que-lei-maria-da-penha-e-aplicavel-tambem-a-violencia-contra-mulheres-trans1); [STF estende proteção da Lei Maria da Penha a gays, travestis e mulheres trans](https://www.extraclasse.org.br/justica/2025/02/stf-estende-protecao-da-lei-maria-da-penha-a-gays-travestis-e-mulheres-trans/)', 'TEC Concursos — questão 3105580 — FGV — Psic (Pref Abreu e Lima)/Pref Abreu e Lima/2024'),
  (3105199, 'Instituto AOCP', 'Esp SP (Pref Uberaba)/Pref Uberaba/Educador Social/2024', 2024, 'A educadora social Helena é uma das servidoras públicas de determinado município que está participando de uma campanha de combate à violência doméstica e familiar contra a mulher. Em uma das ações realizadas diretamente com o público, Helena explicou corretamente e com amparo na Lei Maria da Penha que a violência moral é uma das formas de violência doméstica e familiar contra a mulher, sendo entendida como', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
"Qualquer conduta que configure calúnia, difamação ou injúria" é a definição literal de violência moral dada pelo art. 7º, V.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
É a definição de violência física (art. 7º, I), não moral.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Exposição a contágio de moléstia venérea" não integra nenhuma das definições do art. 7º da Lei Maria da Penha — é elemento de outro tipo penal (Código Penal, art. 130, perigo de contágio venéreo), não a definição de violência moral.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
É a definição (parcial) de violência psicológica (art. 7º, II — dano emocional, diminuição da autoestima, isolamento, vigilância constante), não moral.

BIZU DE PROVA:
Cuidado com alternativas que trazem conceitos de OUTRAS leis penais (como contágio venéreo, do Código Penal) misturados às opções — se não é calúnia, difamação ou injúria, não é a definição de violência moral da Lei Maria da Penha.', 'TEC Concursos — questão 3105199 — Instituto AOCP — Esp SP (Pref Uberaba)/Pref Uberaba/Educador Social/2024'),
  (3199401, 'CEBRASPE (CESPE)', 'Proc (MPTC DF)/TC DF/2024', 2024, 'Com base nas disposições da Lei Maria da Penha (Lei n.º 11.340/2006), julgue os itens a seguir. Suponha que Carlos e Ana tenham sido namorados e que, após o término do relacionamento, Carlos tenha passado a enviar mensagens ameaçadoras a Ana e a persegui- la de maneira contumaz, a fim de convencê-la a retomar o relacionamento, causando-lhe dano emocional e sofrimento psicológico. Nessa situação, a conduta praticada por Carlos configura crime de violência doméstica e familiar contra a mulher.', 'GABARITO: CERTO

POR QUE:
Carlos e Ana mantiveram relação de namoro, o que se enquadra em "relação íntima de afeto" na qual o agressor tenha convivido com a ofendida, independentemente de coabitação (art. 5º, III) — o término do namoro não afasta a Lei. As mensagens ameaçadoras e a perseguição contumaz para reatar o relacionamento, causando dano emocional e sofrimento psicológico, são condutas expressamente descritas no art. 7º, II (ameaça, perseguição contumaz — violência psicológica), dentro do rol de consequências do art. 5º, caput (sofrimento psicológico). Presentes o vínculo, o gênero como base da conduta e a modalidade psicológica, a situação configura violência doméstica e familiar contra a mulher.

BIZU DE PROVA:
"Perseguição contumaz" (stalking) é termo literal do art. 7º, II — e desde a Lei 14.132/2021 também constitui o crime autônomo de perseguição (art. 147-A do Código Penal), que se soma à caracterização como violência doméstica quando praticado nesse contexto.

PEGADINHA:
Namoro encerrado ainda é "relação íntima de afeto" para os fins da Lei — o item testa se o candidato lembra que o art. 5º, III, alcança quem "tenha convivido" com a ofendida, não apenas relações atuais.', 'TEC Concursos — questão 3199401 — CEBRASPE (CESPE) — Proc (MPTC DF)/TC DF/2024'),
  (3097617, 'IBAM', 'GM (Pref Caruaru)/Pref Caruaru/2024', 2024, 'De acordo com a Lei nº 11.340 de 2006, conhecida como Lei Maria da Penha, qualquer conduta que configure calúnia, difamação ou injúria constitui violência doméstica e familiar classificada como:', 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Calúnia, difamação ou injúria é a definição literal de violência moral, dada pelo art. 7º, V, da Lei 11.340/2006.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Violência psicológica (art. 7º, II) tem definição própria, centrada em dano emocional/diminuição de autoestima mediante ameaça, humilhação, isolamento etc. — não é calúnia/difamação/injúria.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Violência patrimonial (art. 7º, IV) trata de retenção/destruição de bens, objetos e valores — não é calúnia/difamação/injúria.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Violência física (art. 7º, I) trata de ofensa à integridade ou saúde corporal — não é calúnia/difamação/injúria.

BIZU DE PROVA:
Calúnia, difamação e injúria (os três crimes contra a honra do Código Penal) = sempre violência moral, art. 7º, V — associação direta e sem exceção nesta Lei.', 'TEC Concursos — questão 3097617 — IBAM — GM (Pref Caruaru)/Pref Caruaru/2024'),
  (3097103, 'OBJETIVA CONCURSOS', 'Ag Ap (Pref Maripá)/Pref Maripá/2024', 2024, 'São formas de violência doméstica e familiar contra a mulher, alinhado com a Lei nº 11.340/2006 − Lei Maria da Penha, nas seguintes situações, EXCETO:', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA (é a alternativa que NÃO é forma de violência prevista na Lei, pedida pelo enunciado):
"Violência institucional" não é modalidade nomeada pelo art. 7º da Lei 11.340/2006 — o rol nomeia física, psicológica, sexual, patrimonial e moral (e, desde 2026, vicária), mas não existe modalidade batizada de "institucional".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (é uma forma prevista, portanto não é a exceção pedida):
Violência física é modalidade expressamente prevista no art. 7º, I.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA (é uma forma prevista, portanto não é a exceção pedida):
Violência sexual é modalidade expressamente prevista no art. 7º, III.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA (é uma forma prevista, portanto não é a exceção pedida):
Violência psicológica é modalidade expressamente prevista no art. 7º, II.

BIZU DE PROVA:
"Institucional" soa plausível (existe, por exemplo, o conceito de "violência institucional" em outros contextos de políticas públicas), mas não é uma das modalidades nomeadas pelo art. 7º da Lei Maria da Penha — cuidado para não confundir conceitos de áreas correlatas com o rol legal específico desta Lei.', 'TEC Concursos — questão 3097103 — OBJETIVA CONCURSOS — Ag Ap (Pref Maripá)/Pref Maripá/2024'),
  (3223384, 'Instituto Verbena', 'Enf (Pref Rio Branco (AC))/Pref Rio Branco (AC)/Sem Área (30h e 40h)/2024', 2024, 'A Lei nº 11.340/2006, conhecida como Lei Maria da Penha, trata especificamente da violência doméstica e familiar contra a mulher, e o seu art. 7º enumera algumas das formas de violências que as mulheres podem sofrer. São elas:', 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
"Física, psicológica, sexual, patrimonial e moral" são cinco das formas de violência doméstica e familiar contra a mulher enumeradas pelo art. 7º da Lei 11.340/2006. O próprio enunciado usa a expressão "enumera ALGUMAS das formas" — preservando o caráter não-exaustivo do art. 7º, caput, que também traz a expressão "entre outras" — por isso a alternativa C está correta ao apresentar esse conjunto sem que a questão dependa de uma contagem fechada.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Autoprovocada" não é modalidade nomeada pela Lei — a violência doméstica e familiar, por definição, é praticada por um agressor contra a vítima, não autoinfligida.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Homicídio" não é uma modalidade de violência do art. 7º — é um possível resultado/crime, categoria diferente das modalidades ali elencadas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Repete o termo inventado "autoprovocada" e omite "patrimonial", uma das modalidades reais.

BIZU DE PROVA:
Diferente de questões que apresentam a lista de 5 modalidades como se fosse fechada (que merecem nota sobre a violência vicária, incluída pela Lei 15.384/2026), esta questão já sinaliza no próprio enunciado que enumera "algumas das formas" — não afirma exaustividade, então não há tensão com a modalidade acrescida em 2026.', 'TEC Concursos — questão 3223384 — Instituto Verbena — Enf (Pref Rio Branco (AC))/Pref Rio Branco (AC)/Sem Área (30h e 40h)/2024'),
  (3096883, 'OBJETIVA CONCURSOS', 'Tel (Pref Maripá)/Pref Maripá/2024', 2024, 'De acordo com a Lei nº 11.340/2006 − Lei Maria da Penha, a retenção de documentos pessoais da mulher configura qual tipo de violência?', 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A retenção de documentos pessoais da mulher é conduta expressamente prevista no art. 7º, IV, como violência patrimonial.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Violência moral (art. 7º, V) trata de calúnia, difamação ou injúria — não de retenção de documentos.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Violência física (art. 7º, I) trata de ofensa à integridade ou saúde corporal — não de retenção de documentos.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Violência sexual (art. 7º, III) trata de constranger a ato sexual não desejado, entre outras condutas — não de retenção de documentos.

BIZU DE PROVA:
Documentos pessoais aparecem explicitamente no rol do art. 7º, IV — junto com objetos, instrumentos de trabalho, bens, valores e recursos econômicos. Sempre que a conduta envolver um "papel"/documento da vítima, pense em patrimonial.', 'TEC Concursos — questão 3096883 — OBJETIVA CONCURSOS — Tel (Pref Maripá)/Pref Maripá/2024'),
  (3229673, 'FADESP', 'GCM (Pref Capanema (PA))/Pref Capanema (PA)/2024', 2024, 'A Lei Maria da Penha cria mecanismos para coibir e prevenir a violência doméstica e familiar contra a mulher e as políticas públicas são elaboradas por meio de um conjunto articulado de ações de todas as esferas de poder. Qualquer conduta que configure calúnia, difamação ou injúria é violência', 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Calúnia, difamação ou injúria é a definição literal de violência moral, dada pelo art. 7º, V, da Lei 11.340/2006.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Violência psicológica (art. 7º, II) tem definição própria (dano emocional, diminuição de autoestima, isolamento etc.) — não é calúnia/difamação/injúria.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Violência patrimonial (art. 7º, IV) trata de retenção/destruição de bens e valores — não é calúnia/difamação/injúria.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Violência física (art. 7º, I) trata de ofensa à integridade ou saúde corporal — não é calúnia/difamação/injúria.

BIZU DE PROVA:
Mais uma vez, calúnia/difamação/injúria = moral, sempre. É uma das associações mais cobradas em provas objetivas sobre a Lei Maria da Penha — decore com prioridade.', 'TEC Concursos — questão 3229673 — FADESP — GCM (Pref Capanema (PA))/Pref Capanema (PA)/2024'),
  (3278936, 'AVANÇASP', 'Coor (SM Arcanjo)/Pref SM Arcanjo/CRAS/2024', 2024, 'No que tange à Lei nº 11.340/2006 (Lei Maria da Penha), a violência doméstica e familiar contra a mulher constitui:', 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O art. 6º da Lei 11.340/2006 estabelece expressamente que a violência doméstica e familiar contra a mulher constitui uma das formas de violação dos direitos humanos — texto literal reproduzido pela alternativa.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Iminência ou prática que viola preceitos institucionais" não é a caracterização dada pelo art. 6º — a Lei fala especificamente em violação dos direitos humanos.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Atentado à justiça" não é expressão usada pelo art. 6º.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Proibição temporária de direitos" é, na verdade, uma das espécies de pena restritiva de direitos do Código Penal (art. 43 e seguintes) — não a caracterização do art. 6º da Lei Maria da Penha.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Embora a violência doméstica também tenha relação com princípios constitucionais (art. 226, §8º, CF), o texto literal e específico do art. 6º da Lei fala em "violação dos direitos humanos", que é a formulação tecnicamente pedida — "violação à Constituição Federal" não é a expressão do dispositivo.

BIZU DE PROVA:
Art. 6º é curto e direto — "constitui uma das formas de violação dos direitos humanos". Decore essa frase literal; é frequentemente cobrada isolada, com distratores de aparência jurídica plausível mas que não reproduzem o texto exato.', 'TEC Concursos — questão 3278936 — AVANÇASP — Coor (SM Arcanjo)/Pref SM Arcanjo/CRAS/2024'),
  (3279521, 'AVANÇASP', 'Coor (SM Arcanjo)/Pref SM Arcanjo/CREAS/2024', 2024, 'Segundo a Lei nº 11.340/2006 (Lei Maria da Penha) a violência moral é uma das formas de violência doméstica e familiar contra a mulher e é entendida como:', 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
"Qualquer conduta que configure calúnia, difamação ou injúria" é a definição literal de violência moral dada pelo art. 7º, V.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
É a definição de violência física (art. 7º, I), não moral.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
É a definição (parcial) de violência psicológica (art. 7º, II), não moral.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
É a definição de violência sexual (art. 7º, III), não moral.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
É a definição de violência patrimonial (art. 7º, IV), não moral.

BIZU DE PROVA:
Questão de definição pura — decore a associação calúnia/difamação/injúria = moral (art. 7º, V) e as palavras-chave das demais para eliminar rapidamente as opções erradas.', 'TEC Concursos — questão 3279521 — AVANÇASP — Coor (SM Arcanjo)/Pref SM Arcanjo/CREAS/2024'),
  (3299190, 'OBJETIVA CONCURSOS', 'At (Pref S Leopoldina)/Pref S Leopoldina/2024', 2024, 'Segundo a Lei nº 11.340/2006 − Lei Maria da Penha, quando o agressor destrói total ou parcialmente os objetos da ofendida, configura forma de violência:', 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Destruir total ou parcialmente os objetos da ofendida é conduta expressamente prevista no art. 7º, IV, como violência patrimonial.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Violência moral (art. 7º, V) trata de calúnia, difamação ou injúria — não de destruição de objetos.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Violência física (art. 7º, I) trata de ofensa à integridade ou saúde corporal — não de destruição de objetos.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Violência psicológica (art. 7º, II) trata de dano emocional e diminuição de autoestima, entre outras condutas — não especificamente de destruição de objetos.

BIZU DE PROVA:
Destruir/reter/subtrair objeto, bem, documento ou valor da vítima = patrimonial, sempre, independentemente do motivo ou contexto emocional envolvido.', 'TEC Concursos — questão 3299190 — OBJETIVA CONCURSOS — At (Pref S Leopoldina)/Pref S Leopoldina/2024'),
  (3094833, 'OBJETIVA CONCURSOS', 'Ag (Pref Maripá)/Pref Maripá/Comunitário de Saúde/2024', 2024, 'Segundo a Lei nº 11.340/2006 − Lei Maria da Penha, a violência doméstica e familiar contra a mulher constitui uma das formas de violação dos:', 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O art. 6º da Lei 11.340/2006 estabelece que a violência doméstica e familiar contra a mulher constitui uma das formas de violação dos direitos humanos.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Direitos do trabalho" não é a formulação do art. 6º.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Direitos de seguridade social" não é a formulação do art. 6º.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Direitos da cultura" não é a formulação do art. 6º.

BIZU DE PROVA:
Mesma frase-chave do art. 6º de sempre: "uma das formas de violação dos direitos humanos" — memorize literalmente, é cobrada com frequência de forma isolada.', 'TEC Concursos — questão 3094833 — OBJETIVA CONCURSOS — Ag (Pref Maripá)/Pref Maripá/Comunitário de Saúde/2024'),
  (3315926, 'FEPESE', 'Ori Soc (Pref Mafra)/Pref Mafra/2024', 2024, 'Assinale a alternativa que indica corretamente as formas de violência doméstica e familiar contra a mulher, de acordo com a Lei nº 11.340, de 7 de agosto de 2006, mais conhecida como a Lei Maria da Penha.', 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
"Física, psicológica, sexual, patrimonial e moral" são as cinco formas de violência doméstica e familiar então nomeadas pelo art. 7º, incisos I a V, da Lei 11.340/2006. (Ressalva: lista fechada das 5 modalidades clássicas, sem hedge do tipo "entre outras"/"algumas" — esta questão é de 2024, anterior à Lei 15.384/2026, que acrescentou a violência vicária como sexto inciso; a alternativa A permanece a única plausível porque nenhuma das demais opções seria corrigida pela adição da vicária.)

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Usa "mental" e "dos bens", termos que não são os nomes técnicos usados pela Lei (os corretos são "psicológica" e "patrimonial").

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Usa "mental" e "religiosa" — "religiosa" não é modalidade nomeada pela Lei, e "mental" não substitui corretamente "psicológica".

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Usa "dos bens" no lugar de "patrimonial", termo que não é o nome técnico da Lei.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Usa "religiosa" no lugar de "moral" — "religiosa" não é modalidade nomeada pela Lei.

BIZU DE PROVA:
Os cinco nomes exatos até 2026: física, psicológica, sexual, patrimonial e moral (hoje, seis, com a vicária). "Mental", "dos bens" e "religiosa" são substituições parecidas mas tecnicamente erradas — pegadinha recorrente.', 'TEC Concursos — questão 3315926 — FEPESE — Ori Soc (Pref Mafra)/Pref Mafra/2024'),
  (3322429, 'FUNDEP', 'Ag Soc (Pref Cordisburgo)/Pref Cordisburgo/2024', 2024, 'Não constitui forma de violência contra a mulher, tipificada na Lei nº 11.340, de 7 de agosto de 2006 (Lei Maria da Penha):', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA (é a que NÃO constitui violência prevista na Lei, pedida pelo enunciado):
"Violência cognitiva" não é modalidade nomeada pelo art. 7º da Lei 11.340/2006.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (é uma forma prevista, portanto não é a exceção pedida):
Violência patrimonial é modalidade expressamente prevista no art. 7º, IV.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA (é uma forma prevista, portanto não é a exceção pedida):
Violência moral é modalidade expressamente prevista no art. 7º, V.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA (é uma forma prevista, portanto não é a exceção pedida):
Violência psicológica é modalidade expressamente prevista no art. 7º, II.

BIZU DE PROVA:
"Cognitiva" soa como um termo técnico de psicologia, mas não é uma das modalidades nomeadas pela Lei Maria da Penha — o efeito sobre a "cognição"/pensamento da vítima integra a definição de violência PSICOLÓGICA (art. 7º, II), não configura uma modalidade separada.', 'TEC Concursos — questão 3322429 — FUNDEP — Ag Soc (Pref Cordisburgo)/Pref Cordisburgo/2024'),
  (3324743, 'AVANÇASP', 'Coord (Pref Laranjal Pta)/Pref Laranjal Pta/Centro de Referência da Assistência Social - CRAS/2024', 2024, 'Acerca ao que dispõe a Lei Maria da Penha (Lei nº 11.340/2006) a violência moral é entendida como:', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
"Qualquer conduta que configure calúnia, difamação ou injúria" é a definição literal de violência moral dada pelo art. 7º, V.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
É a definição de violência física (art. 7º, I), não moral.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
É a definição (parcial) de violência psicológica (art. 7º, II), não moral.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
É a definição de violência sexual (art. 7º, III), não moral.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
É a definição (parcial) de violência patrimonial (art. 7º, IV), não moral.

BIZU DE PROVA:
Calúnia, difamação, injúria = moral, sem exceção. Elimine primeiro as alternativas com "palavras-chave" claramente de outra modalidade (corporal=física; relação sexual=sexual; objetos=patrimonial) para chegar mais rápido à correta.', 'TEC Concursos — questão 3324743 — AVANÇASP — Coord (Pref Laranjal Pta)/Pref Laranjal Pta/Centro de Referência da Assistência Social - CRAS/2024'),
  (3085547, 'VUNESP', 'CSoc (Pref Osasco)/Pref Osasco/2024', 2024, 'A Lei Maria da Penha (Lei Federal nº 11.340/2006) cria mecanismos para coibir e prevenir a violência doméstica e familiar contra a mulher, nos termos do § 8º do artigo 226 da Constituição Federal, da Convenção sobre a Eliminação de Todas as Formas de Violência contra a Mulher, da Convenção Interamericana para Prevenir, Punir e Erradicar a Violência contra a Mulher e de outros tratados internacionais ratificados pela República Federativa do Brasil; dispõe sobre a criação dos Juizados de Violência Doméstica e Familiar contra a Mulher; e estabelece medidas de assistência e proteção às mulheres em situação de violência doméstica e familiar. Conforme o artigo 7º, são formas de violência contra a mulher: a física, psicológica, sexual, patrimonial, e', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
"Moral" completa corretamente a frase "são formas de violência contra a mulher: a física, psicológica, sexual, patrimonial, e ___" — as cinco modalidades então nomeadas pelo art. 7º, incisos I a V, da Lei 11.340/2006. (Ressalva: o enunciado parafraseia o art. 7º, caput, omitindo o "entre outras" que consta do texto legal original ("São formas de violência doméstica e familiar contra a mulher, entre outras: ..."), apresentando a lista como se fosse fechada. Esta questão é de 2024, anterior à Lei 15.384/2026, que acrescentou a violência vicária como sexto inciso; a alternativa D permanece correta porque a pergunta pede apenas o termo que completa corretamente a lista de cinco iniciada no próprio enunciado, e nenhuma alternativa oferece "vicária" ou testa a completude do rol.)

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Espiritual" não é modalidade nomeada pelo art. 7º.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Intelectual" não é modalidade nomeada pelo art. 7º.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Comunitária" não é modalidade nomeada pelo art. 7º.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Familiar" não é modalidade nomeada pelo art. 7º — "família" é um dos ÂMBITOS de incidência da Lei (art. 5º, II), não uma modalidade de violência.

BIZU DE PROVA:
Cuidado com paráfrases do art. 7º, caput, que omitem o "entre outras" do texto original — isso não torna a lista de fato fechada, mas é um sinal de que vale registrar a ressalva sobre a violência vicária (Lei 15.384/2026) mesmo quando o gabarito continua correto.', 'TEC Concursos — questão 3085547 — VUNESP — CSoc (Pref Osasco)/Pref Osasco/2024'),
  (3324785, 'AVANÇASP', 'Coord (Pref Laranjal Pta)/Pref Laranjal Pta/Centro de Referência Especializada da Assistência Social - CREAS/2024', 2024, 'No que tange à Lei nº 11.340/2006 (Lei Maria da Penha), a violência doméstica e familiar contra a mulher constitui uma das formas de violação:', 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O art. 6º da Lei 11.340/2006 estabelece que a violência doméstica e familiar contra a mulher constitui uma das formas de violação dos direitos humanos — texto literal reproduzido pela alternativa.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Direitos fundamentais" é conceito próximo, mas não é a expressão literal usada pelo art. 6º, que fala especificamente em "direitos humanos".

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Direitos constitucionais" não é a expressão usada pelo art. 6º.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Direitos difusos" é categoria de direito processual coletivo, sem relação com a formulação do art. 6º.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Direitos institucionais" não é expressão usada pela Lei nem conceito jurídico correspondente ao art. 6º.

BIZU DE PROVA:
Decore a frase literal do art. 6º: "constitui uma das formas de violação dos direitos humanos" — quando a banca pede a expressão exata da Lei (não apenas um conceito próximo), só a opção com "direitos humanos" está certa.', 'TEC Concursos — questão 3324785 — AVANÇASP — Coord (Pref Laranjal Pta)/Pref Laranjal Pta/Centro de Referência Especializada da Assistência Social - CREAS/2024'),
  (3083884, 'CEBRASPE (CESPE)', 'Ass Soc (CAGEPA)/CAGEPA/2024', 2024, 'O fato de uma mulher sofrer, por parte do seu cônjuge, limitação do direito de ir e vir, retenção de documentos pessoais e subtração de economias caracteriza a prática de violências', 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Limitação do direito de ir e vir é conduta expressamente listada no art. 7º, II (violência psicológica). Retenção de documentos pessoais e subtração de economias são condutas expressamente listadas no art. 7º, IV (violência patrimonial). A situação combina as duas modalidades.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Não há relato de conduta sexual (art. 7º, III) — as condutas narradas são de controle (psicológica) e de bens/valores (patrimonial).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não há relato de agressão física (art. 7º, I) — nenhuma das condutas narradas ofende a integridade ou saúde corporal.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não há relato de calúnia, difamação ou injúria (art. 7º, V, violência moral), nem de agressão física.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não há relato de calúnia, difamação ou injúria — a limitação do direito de ir e vir é psicológica, não moral.

BIZU DE PROVA:
"Limitação do direito de ir e vir" = psicológica (art. 7º, II). "Retenção de documentos" e "subtração de economias/valores" = patrimonial (art. 7º, IV). Quando o relato combina as duas famílias de conduta, a resposta reconhece ambas as modalidades.', 'TEC Concursos — questão 3083884 — CEBRASPE (CESPE) — Ass Soc (CAGEPA)/CAGEPA/2024'),
  (3324796, 'AVANÇASP', 'Coord (Pref Laranjal Pta)/Pref Laranjal Pta/Centro de Referência Especializada da Assistência Social - CREAS/2024', 2024, 'No que tange à Lei nº 11.340/2006 (Lei Maria da Penha), a violência entendida como qualquer conduta que ofenda sua integridade ou saúde corporal é a:', 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
"Qualquer conduta que ofenda sua integridade ou saúde corporal" é a definição literal de violência física dada pelo art. 7º, I.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
É a definição de violência moral (art. 7º, V — calúnia, difamação ou injúria), não física.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
É a definição de violência sexual (art. 7º, III), não física.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
É a definição de violência patrimonial (art. 7º, IV), não física.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
É a definição de violência psicológica (art. 7º, II), não física.

BIZU DE PROVA:
Física é a definição mais curta e direta do art. 7º: "ofender integridade ou saúde corporal" — qualquer definição mais longa/elaborada pertence a outra modalidade.', 'TEC Concursos — questão 3324796 — AVANÇASP — Coord (Pref Laranjal Pta)/Pref Laranjal Pta/Centro de Referência Especializada da Assistência Social - CREAS/2024'),
  (3338000, 'SELECON', 'Vis Soc (Pref Nova Mutum)/Pref Nova Mutum/2024', 2024, 'Dona Regina recebeu o visitador social Daniel para acompanhar o desenvolvimento de seus filhos e sua rotina. Durante a entrevista relatou que não poderia fazer compras sem permissão, pois, estava sem seu cartão de banco, que foi arbitrariamente retirado por seu marido. O visitador social reportou o ocorrido ao técnico responsável, uma vez que, segundo a Lei Maria da Penha, Lei nº 11.340/2006, dona Regina está vivenciando uma situação de violência:', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O marido de dona Regina retirou arbitrariamente o cartão bancário dela, impedindo-a de fazer compras — conduta que se enquadra na definição de violência patrimonial (art. 7º, IV: retenção de objetos, bens, valores ou recursos econômicos).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Não há relato de agressão à integridade ou saúde corporal de dona Regina.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não há relato de conduta sexual.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Embora a retenção do cartão também tenha um componente de controle, a conduta especificamente descrita — reter o bem que permite o acesso a recursos econômicos — se enquadra mais precisamente na definição de violência patrimonial (art. 7º, IV), que trata especificamente de retenção de objetos/valores/recursos econômicos.

BIZU DE PROVA:
Reter cartão bancário, documentos ou qualquer bem que dê acesso a recursos econômicos da vítima = patrimonial (art. 7º, IV) — mesmo quando o efeito prático também restrinja sua autonomia, a Lei classifica a conduta sobre o BEM retido como patrimonial.', 'TEC Concursos — questão 3338000 — SELECON — Vis Soc (Pref Nova Mutum)/Pref Nova Mutum/2024'),
  (3077866, 'VUNESP', 'GM (Pref SJRP)/Pref SJRP/2024', 2024, 'Nos termos da Lei n° 11.340, de 07 de agosto de 2006 (Lei “Maria da Penha”), é correto afirmar que, para os efeitos da Lei, configura violência doméstica e familiar contra a mulher qualquer ação ou omissão baseada no gênero que lhe cause morte, lesão, sofrimento físico, sexual ou psicológico e dano moral ou patrimonial, no âmbito da', 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Reproduz literalmente o art. 5º, I — unidade doméstica, compreendida como o espaço de convívio permanente de pessoas, com ou sem vínculo familiar, inclusive as esporadicamente agregadas.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Inverte a regra ao exigir "obrigatoriamente com vínculo familiar" — o art. 5º, I, é expresso ao dizer "com OU SEM vínculo familiar".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Atribui à "família" a definição que, na verdade, é da unidade doméstica (art. 5º, I) — rótulo trocado.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Troca "convívio permanente" por "convívio temporário" — o art. 5º, I, exige convívio permanente, não temporário.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Combina dois erros: atribui à "família" a definição da unidade doméstica, e ainda exige "obrigatoriamente com vínculo familiar", invertendo a regra.

BIZU DE PROVA:
Unidade doméstica = convívio PERMANENTE, COM OU SEM vínculo familiar, inclusive esporadicamente agregadas. Família = comunidade de aparentados por laços naturais, afinidade OU vontade expressa. Bancas adoram trocar essas duas definições entre si ou inverter "com ou sem"/"permanente".', 'TEC Concursos — questão 3077866 — VUNESP — GM (Pref SJRP)/Pref SJRP/2024'),
  (3073912, 'FEPESE', 'ASE (Pref Brusque)/Pref Brusque/2024', 2024, 'A legislação vigente compreende violência doméstica e familiar praticada contra a mulher, qualquer ação ou omissão baseada no gênero que lhe cause morte, lesão, sofrimento físico, sexual ou psicológico e dano moral ou patrimonial. Diante do exposto, é correto afirmar:', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O parágrafo único do art. 5º estabelece que as relações pessoais enunciadas no artigo — incluindo o âmbito da unidade doméstica — independem de orientação sexual. A afirmativa é verdadeira mesmo formulada de modo mais específico (referida à unidade doméstica), pois essa independência vale para todos os âmbitos do art. 5º.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Inverte a regra do art. 5º, I, ao exigir "desde que tenha vínculo familiar" — a Lei diz "com ou sem vínculo familiar".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Descreve a unidade doméstica com a definição de família (comunidade de pessoas com laços consanguíneos) e ainda restringe indevidamente a "laços consanguíneos" — o art. 5º, II, é mais amplo (laços naturais, afinidade ou vontade expressa).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Inverte a regra do art. 5º, III, ao exigir "desde que se comprove a coabitação" — a Lei diz "independentemente de coabitação".

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Atribui a definição de violência moral (calúnia, difamação ou injúria, art. 7º, V) ao rótulo "psicológica" — mislabeling clássico.

BIZU DE PROVA:
Toda vez que uma alternativa inverter "independentemente de" para "desde que" (coabitação, orientação sexual, vínculo familiar), ela está errada — a Lei Maria da Penha é sistematicamente mais abrangente do que essas versões restritivas sugerem.', 'TEC Concursos — questão 3073912 — FEPESE — ASE (Pref Brusque)/Pref Brusque/2024'),
  (3392823, 'MS (SARMENTO)', 'Ass Soc (Pref Tabocão)/Pref Tabocão/2024', 2024, 'Carolina possuía uma união estável de 2 anos com Jorge, nos últimos 6 meses passaram a ter muitas brigas, ela não estava mais contente com a relação e rompeu o relacionamento. Após uma semana passou a receber mensagens ofensivas e ameaças de Jorge. Ao olhar seu extrato bancário observou que estava com saldo devedor em sua conta, à qual seu excompanheiro tinha acesso. Baseado neste breve relato e na Lei n.º 11.340/2006, Lei Maria da Penha, assinale a alternativa correta.', 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
As mensagens ofensivas e ameaças recebidas por Carolina após o término do relacionamento configuram violência psicológica (art. 7º, II — ameaça, dentre outras condutas). O saldo devedor decorrente do acesso do ex-companheiro à conta bancária de Carolina configura violência patrimonial (art. 7º, IV — subtração de valores/recursos econômicos).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Não há relato de agressão física — apenas mensagens ofensivas, ameaças e movimentação indevida da conta bancária.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não há relato de calúnia, difamação ou injúria (art. 7º, V) — a conduta relatada quanto à conta bancária é de natureza patrimonial (subtração de valores), não moral.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Omite a violência psicológica, evidente nas mensagens ofensivas e ameaças recebidas por Carolina, e classifica erroneamente a conduta patrimonial como moral.

BIZU DE PROVA:
Mensagens ofensivas/ameaças pós-término = psicológica (art. 7º, II, "ameaça" é termo literal); acesso indevido à conta com saldo devedor = patrimonial (art. 7º, IV, "subtração... valores... recursos econômicos"). União estável encerrada não afasta a Lei — o relacionamento "tenha convivido" (art. 5º, III) já é suficiente.', 'TEC Concursos — questão 3392823 — MS (SARMENTO) — Ass Soc (Pref Tabocão)/Pref Tabocão/2024'),
  (3415068, 'OBJETIVA CONCURSOS', 'ASoc (Pref Lebon Régis)/Pref Lebon Régis/2024', 2024, 'Configura violência doméstica e familiar contra a mulher qualquer ação ou omissão baseada no gênero que lhe cause morte, lesão, sofrimento físico, sexual ou psicológico e dano moral ou patrimonial. Quando compreendida no espaço de convívio permanente de pessoas, com ou sem vínculo familiar, trata-se da violência no âmbito da:', 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
"Espaço de convívio permanente de pessoas, com ou sem vínculo familiar" é a definição literal de unidade doméstica dada pelo art. 5º, I.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Família" (art. 5º, II) é definida como comunidade formada por indivíduos que são ou se consideram aparentados por laços naturais, afinidade ou vontade expressa — não como "espaço de convívio permanente de pessoas, com ou sem vínculo familiar", que é a definição de unidade doméstica.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Relação institucional" não é um dos três âmbitos do art. 5º.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Relação intrafamiliar e estrutural" não é expressão usada pela Lei nem corresponde a nenhum dos três âmbitos do art. 5º.

BIZU DE PROVA:
"Convívio permanente, com ou sem vínculo familiar, inclusive esporadicamente agregadas" = sempre unidade doméstica (art. 5º, I). Não confundir com família (art. 5º, II, que exige algum tipo de parentesco/vontade expressa de constituir família).', 'TEC Concursos — questão 3415068 — OBJETIVA CONCURSOS — ASoc (Pref Lebon Régis)/Pref Lebon Régis/2024'),
  (3072118, 'MS (SARMENTO)', 'ASoc (Pref Potim)/Pref Potim/2024', 2024, 'Silvia conheceu Paulo por aplicativo de mensagem, logo após se encontrarem pessoalmente, já passaram a morar juntos em sua casa. Com o passar do tempo, Paulo teve acesso às contas e senhas de Silvia e ser ele o responsável por fazer todas as movimentações bancárias, sempre alegando estar cuidando do patrimônio de ambos. Certo dia, ao chegar em casa, observou não haver mais nenhum pertence de seu marido e que ele havia levado suas joias do cofre. Enviou mensagens a ele sem êxito na resposta. Decidiu olhar suas contas bancárias e viu que estavam com saldo devedor, desesperada com auxilio de uma amiga foi até uma Delegacia da Mulher. Com base na Lei n.º 11340/2006, Lei Maria da Penha, qual violência foi sofrida por Silvia?', 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Paulo teve acesso às contas e senhas de Silvia, fez movimentações bancárias e, ao final, levou as joias dela e deixou a conta com saldo devedor — condutas que se enquadram na definição de violência patrimonial (art. 7º, IV: subtração de bens, valores e recursos econômicos).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Não há relato de agressão à integridade física de Silvia.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Violência institucional" não é modalidade nomeada pela Lei Maria da Penha.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não há relato de calúnia, difamação ou injúria — as condutas narradas envolvem bens e valores, não ataque à honra/reputação.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Violência verbal" não é modalidade nomeada pela Lei Maria da Penha.

BIZU DE PROVA:
Levar joias, esvaziar conta bancária, deixar saldo devedor = patrimonial, sempre — mesmo que o agressor alegue estar "cuidando do patrimônio de ambos" (como no relato), o que importa é a conduta objetiva de subtração de bens e valores da vítima.', 'TEC Concursos — questão 3072118 — MS (SARMENTO) — ASoc (Pref Potim)/Pref Potim/2024'),
  (3417429, 'UNESC', 'AEdu (Pref Cunhatai)/Pref Cunhatai/2024', 2024, 'A Lei n° 11.340/06 cria mecanismos para coibir a violência doméstica e familiar contra a mulher, também conhecida como Lei Maria da Penha, estabelece alguns tipos de violência as quais a mulher pode ser exposta, correlacione-as: Coluna I 1.Violência física. 2.Violência patrimonial. 3.Violência moral. Coluna II a. Entendida como qualquer conduta que configure retenção, subtração, destruição parcial ou total de seus objetos, instrumentos de trabalho, documentos pessoais, bens, valores e direitos ou recursos econômicos, incluindo os destinados a satisfazer suas necessidades. b. Entendida como qualquer conduta que configure calúnia, difamação ou injúria. c. Entendida como qualquer conduta que ofenda sua integridade ou saúde corporal. Correlacione as colunas I e II, e assinale a alternativa CORRETA.', 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A sequência correta é 1.c, 2.a, 3.b: violência física (1) corresponde a "ofenda sua integridade ou saúde corporal" (c); violência patrimonial (2) corresponde a "retenção, subtração, destruição... objetos, instrumentos de trabalho, documentos pessoais, bens, valores" (a); violência moral (3) corresponde a "calúnia, difamação ou injúria" (b).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Associa física (1) à definição de moral ("b"), o que é trocado — física é "ofensa à integridade/saúde corporal" (c).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Associa física (1) à definição de moral ("b") e moral (3) à definição de física ("c") — as duas trocadas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Associa física (1) à definição de patrimonial ("a") e patrimonial (2) à definição de moral ("b") — invertidas.

BIZU DE PROVA:
Física = corporal; patrimonial = objetos/bens/documentos; moral = calúnia/difamação/injúria. Monte essa "ficha" antes de casar as colunas — evita trocar rótulo por definição parecida.', 'TEC Concursos — questão 3417429 — UNESC — AEdu (Pref Cunhatai)/Pref Cunhatai/2024'),
  (2759639, 'FGV', 'Res (TJ RJ)/TJ RJ/Psicólogo/2024', 2024, 'Maristela vive relacionamento marital com Ivan há 3 anos e desde então observou-se nítida alteração em seu comportamento, pois ela deixou de se expressar de forma mais segura e mudou suas roupas, adequando-se ao gosto do companheiro. Seus amigos passaram a perceber que Ivan refere-se à companheira com palavras depreciativas e humilhantes, além de isolá-la do convívio com a família e amigos. Nesse caso, é correto afirmar que', 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Ivan refere-se a Maristela com palavras depreciativas e humilhantes e a isola do convívio com família e amigos — condutas expressamente listadas no art. 7º, II (humilhação, isolamento), configurando padrão de violência psicológica.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
As palavras depreciativas são dirigidas diretamente a Maristela, sem indicação de que Ivan tenha espalhado calúnia, difamação ou injúria sobre ela perante terceiros (art. 7º, V) — o que houve foi humilhação e isolamento direcionados a ela, não ataque à sua reputação perante outras pessoas.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não há relato de conduta sexual.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não há relato de retenção, subtração ou destruição de bens/valores.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Há, sim, indícios claros de violência doméstica (psicológica), dado o relacionamento marital de 3 anos e o padrão de humilhação e isolamento descrito.

BIZU DE PROVA:
Humilhação e isolamento DIRECIONADOS à vítima (mudança de comportamento, afastamento de amigos e família, palavras depreciativas ditas a ela) = psicológica. Só vire "moral" quando houver uma acusação/ofensa à reputação da vítima espalhada PARA TERCEIROS (calúnia, difamação, injúria) — não é o caso aqui.', 'TEC Concursos — questão 2759639 — FGV — Res (TJ RJ)/TJ RJ/Psicólogo/2024'),
  (2770925, 'IBFC', 'GM (Pref Manaus)/Pref Manaus/2024', 2024, 'Observando-se o que dispõe a Lei n. 11.340, de 7 de agosto de 2006, conhecida como Lei Maria da Penha, analise as afirmativas abaixo: I. Compreende-se como unidade doméstica a comunidade formada por indivíduos que são ou se consideram aparentados, unidos por laços naturais, por afinidade ou por vontade expressa. II. A violência doméstica e familiar contra a mulher constitui uma das formas de violação dos direitos humanos. III. São formas de violência doméstica e familiar contra a mulher, entre outras, a violência psicológica, entendida como qualquer conduta que configure calúnia, difamação ou injúria. IV. O juiz determinará, por prazo certo, a inclusão da mulher em situação de violência doméstica e familiar no cadastro de programas assistenciais do governo federal, estadual e municipal. Estão corretas as afirmativas:', 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Apenas os itens II e IV estão corretos. II reproduz literalmente o art. 6º (violação dos direitos humanos). IV reproduz o art. 9º, §1º (o juiz determinará, por prazo certo, a inclusão da mulher no cadastro de programas assistenciais do governo federal, estadual e municipal).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Inclui o item I, que está errado — o texto descrito no item I ("comunidade formada por indivíduos que são ou se consideram aparentados, unidos por laços naturais, por afinidade ou por vontade expressa") é a definição de FAMÍLIA (art. 5º, II), não de "unidade doméstica".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Inclui o item I (errado, pelo motivo acima) e exclui o item II (correto).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Inclui o item III, que está errado — "calúnia, difamação ou injúria" é a definição de violência MORAL (art. 7º, V), não psicológica.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Inclui o item III (errado, pelo motivo acima) e exclui o item II (correto).

BIZU DE PROVA:
Dois mislabelings clássicos nesta questão: item I troca "unidade doméstica" pela definição de "família", e item III troca "psicológica" pela definição de "moral" — fique atento a esse tipo de armadilha em questões de múltiplas assertivas.', 'TEC Concursos — questão 2770925 — IBFC — GM (Pref Manaus)/Pref Manaus/2024'),
  (2789972, 'CEBRASPE (CESPE)', 'Prof NU Jr (ITAIPU)/ITAIPU/Assistente Social/2024', 2024, 'Para os efeitos da Lei n.º 11.340/2006 (Lei Maria da Penha), configura violência doméstica e familiar contra a mulher qualquer ação ou omissão no âmbito da família que lhe cause I lesão. II sofrimento físico. III dano moral. IV sofrimento psicológico. Assinale a opção correta.', 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Todos os itens estão certos. O art. 5º, caput, lista exatamente essas consequências como caracterizadoras de violência doméstica e familiar quando decorrentes de ação ou omissão baseada no gênero: morte, lesão (I), sofrimento físico, sexual ou psicológico (II e IV) e dano moral ou patrimonial (III).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Exclui indevidamente o item IV (sofrimento psicológico), que também consta do art. 5º, caput.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Exclui indevidamente o item III (dano moral), que também consta do art. 5º, caput.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Exclui indevidamente o item II (sofrimento físico), que também consta do art. 5º, caput.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Exclui indevidamente o item I (lesão), que também consta do art. 5º, caput.

BIZU DE PROVA:
O caput do art. 5º reúne todas essas consequências em uma única frase: "morte, lesão, sofrimento físico, sexual ou psicológico e dano moral ou patrimonial" — se a questão fragmentar essa frase em itens I a IV, todos tendem a estar corretos, salvo se um deles for adulterado.', 'TEC Concursos — questão 2789972 — CEBRASPE (CESPE) — Prof NU Jr (ITAIPU)/ITAIPU/Assistente Social/2024'),
  (3449398, 'INSTITUTO MAIS', 'Ag Fisc (CRESS 9)/CRESS 9 (SP)/2024', 2024, 'De acordo com a Lei n.0 11.340/2006, conhecida como Lei Maria da Penha, qualquer conduta que cause dano emocional e diminuição da autoestima ou que prejudique e perturbe o pleno desenvolvimento ou que vise degradar ou controlar ações, comportamentos, crenças e decisões, contra a mulher, é entendida como violência', 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A definição do enunciado — dano emocional e diminuição da autoestima, prejuízo ao pleno desenvolvimento, degradar ou controlar ações, comportamentos, crenças e decisões — reproduz literalmente o art. 7º, II, que define violência psicológica.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Violência física (art. 7º, I) é definida como ofensa à integridade ou saúde corporal — não corresponde ao texto do enunciado.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Violência moral (art. 7º, V) é definida como calúnia, difamação ou injúria — não corresponde ao texto do enunciado.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Violência patrimonial (art. 7º, IV) é definida como retenção/subtração/destruição de bens e valores — não corresponde ao texto do enunciado.

BIZU DE PROVA:
"Dano emocional e diminuição da autoestima... degradar ou controlar ações, comportamentos, crenças e decisões" = sempre psicológica (art. 7º, II) — frase-chave para memorizar e reconhecer de imediato.', 'TEC Concursos — questão 3449398 — INSTITUTO MAIS — Ag Fisc (CRESS 9)/CRESS 9 (SP)/2024'),
  (3055885, 'UFMT', 'Psic (Pref Campos de Júlio)/Pref Campos de Júlio/Sem Área/2024', 2024, 'A violência contra a mulher que, no estado do Mato Grosso atinge números alarmantes, se configura como uma violação dos Direitos Humanos, exige uma resposta ativa de toda a sociedade. A Lei nº. 11.340, de 07 de agosto de 2006, visa coibir esse tipo de crime, bem como estabelecer medidas de assistência às suas vítimas. Analise as afirmativas abaixo, que versam sobre o conteúdo dessa lei. I. Considera violência contra a mulher qualquer ação ou omissão que lhe cause morte, lesão ou sofrimento físico, sexual ou psicológico, bem como dano moral ou patrimonial. II. Preconiza que a assistência à mulher seja realizada de forma articulada entre diferentes profissionais e os vários serviços e políticas públicas existentes. III. Dá ênfase ao atendimento às situações de violência já perpetradas, sendo a ausência de ações preventivas um dos principais pontos de crítica à lei. Está correto o que se afirma em', 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O item I descreve corretamente, em linhas gerais, as consequências que caracterizam violência contra a mulher previstas no art. 5º, caput (morte, lesão, sofrimento físico/sexual/psicológico, dano moral/patrimonial). O item II reproduz o art. 9º, caput, segundo o qual a assistência à mulher em situação de violência será prestada de forma articulada entre profissionais, serviços e políticas públicas.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Inclui o item III, que é falso — a Lei Maria da Penha não se limita ao atendimento pós-violência; ela expressamente cria mecanismos para "coibir e PREVENIR" a violência doméstica (art. 1º) e prevê medidas de prevenção (art. 8º), não sendo correto afirmar que a ausência de ações preventivas seja um dos principais pontos de crítica à Lei.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Considera apenas o item II, mas o item I também está correto.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Inclui os itens I, II e III — o item III é falso pelo motivo já exposto.

BIZU DE PROVA:
A Lei Maria da Penha se estrutura em dois eixos que sempre andam juntos: proteção/resposta (medidas protetivas, resposta penal) E prevenção (art. 1º e art. 8º) — qualquer alternativa que diga que a Lei "só" olha para o atendimento pós-violência, sem prevenção, está errada.', 'TEC Concursos — questão 3055885 — UFMT — Psic (Pref Campos de Júlio)/Pref Campos de Júlio/Sem Área/2024'),
  (3055293, 'OBJETIVA CONCURSOS', 'TEnf (Pref Pato Bragado)/Pref Pato Bragado/2024', 2024, 'A Lei nº 11.340/2006 — Lei Maria da Penha é uma lei federal brasileira, cujo objetivo principal é estipular punição adequada e coibir atos de violência doméstica contra a mulher. Assim, nos termos expressos da Lei, configura-se a violência doméstica e familiar contra a mulher qualquer ação ou omissão baseada no gênero que lhe cause morte, lesão, sofrimento físico, sexual ou psicológico e dano moral ou patrimonial: I. No âmbito da unidade doméstica, compreendida como o espaço de convívio permanente de pessoas, com ou sem vínculo familiar, inclusive as esporadicamente agregadas. II. Em qualquer relação íntima de afeto, na qual o agressor conviva ou tenha convivido com a ofendida, desde que haja coabitação. III. No âmbito da família, compreendida como a comunidade formada por indivíduos que são ou se consideram aparentados, unidos por laços naturais, por afinidade ou por vontade expressa. Estão CORRETOS:', 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Os itens I e III reproduzem literalmente o art. 5º, I e III (âmbito da unidade doméstica e âmbito da família, respectivamente). O item II está errado, pois exige "desde que haja coabitação", quando o art. 5º, III, dispensa expressamente a coabitação para o âmbito da relação íntima de afeto.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Inclui o item II, que é falso pelo motivo acima, e exclui o item III, que é verdadeiro.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Inclui o item II, falso, e exclui o item I, verdadeiro.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Inclui o item II, que é falso.

BIZU DE PROVA:
"Relação íntima de afeto" é o único dos três âmbitos que menciona expressamente a dispensa de coabitação (art. 5º, III) — qualquer versão que exija coabitação para esse âmbito específico está errada.', 'TEC Concursos — questão 3055293 — OBJETIVA CONCURSOS — TEnf (Pref Pato Bragado)/Pref Pato Bragado/2024'),
  (3050257, 'FGV', 'Aud CE (TCE-PA)/TCE PA/Administrativa/Psicologia/2024', 2024, 'Paula e Maurício são namorados e, em certa noite, após terem saído com amigos, Maurício teve uma crise de ciúmes, agredindo a namorada com palavras de baixo calão, constrangendo-a e humilhando-a na presença dos amigos em comum. Diante da hipótese apresentada, é correto afirmar que', 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Maurício agrediu Paula com palavras de baixo calão, constrangendo-a e humilhando-a — condutas expressamente listadas no art. 7º, II (constrangimento, humilhação), configurando violência psicológica. O fato de o namoro (não casamento) ser a natureza da relação não afasta a Lei, pois o art. 5º, III, alcança qualquer relação íntima de afeto.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A Lei Maria da Penha se aplica a qualquer relação íntima de afeto, não apenas ao casamento (art. 5º, III) — o namoro está incluído.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A humilhação foi dirigida diretamente a Paula, na presença de terceiros que apenas testemunharam a agressão verbal — não há relato de que Maurício tenha feito uma acusação falsa ou ofensiva à reputação dela perante os amigos (o que caracterizaria calúnia, difamação ou injúria, art. 7º, V). A presença de terceiros como testemunhas de uma humilhação direta não transforma, por si só, a conduta em violência moral — o núcleo da conduta (constranger e humilhar Paula) continua sendo psicológico.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não há relato de agressão à integridade física de Paula — apenas agressão verbal.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O próprio texto da alternativa é internamente contraditório: rotula a conduta como "psicológica", mas a justifica com "caluniou e difamou", que são, na verdade, os termos que definem violência MORAL (art. 7º, V), não psicológica. Além disso, não há relato de calúnia ou difamação no caso — apenas humilhação direta.

BIZU DE PROVA:
Humilhar/constranger a vítima diretamente, mesmo na presença de outras pessoas, é psicológica (art. 7º, II) — só vira moral quando há uma acusação/ofensa à reputação da vítima especificamente espalhada ou dirigida a terceiros (calúnia, difamação, injúria), o que é diferente de simplesmente humilhá-la "na frente" de alguém.', 'TEC Concursos — questão 3050257 — FGV — Aud CE (TCE-PA)/TCE PA/Administrativa/Psicologia/2024'),
  (3039026, 'FUNDATEC', 'Ag Con (Pref Londrina)/Pref Londrina/Funerário/2024', 2024, 'Atos de calúnia, difamação ou injúria configuram, nos termos da Lei Maria da Penha, violência:', 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Calúnia, difamação ou injúria é a definição literal de violência moral dada pelo art. 7º, V.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Violência física (art. 7º, I) trata de ofensa à integridade ou saúde corporal — não é calúnia/difamação/injúria.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Violência psicológica (art. 7º, II) tem definição própria (dano emocional, diminuição de autoestima etc.) — não é calúnia/difamação/injúria.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Violência sexual (art. 7º, III) trata de constranger a ato sexual, entre outras condutas — não é calúnia/difamação/injúria.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Violência patrimonial (art. 7º, IV) trata de bens e valores — não é calúnia/difamação/injúria.

BIZU DE PROVA:
Calúnia, difamação e injúria (os três crimes contra a honra do Código Penal, arts. 138-140) = sempre violência moral, art. 7º, V — associação direta, cobrada com muita frequência.', 'TEC Concursos — questão 3039026 — FUNDATEC — Ag Con (Pref Londrina)/Pref Londrina/Funerário/2024'),
  (3031784, 'OBJETIVA CONCURSOS', 'ACS (Pref Vila Boa)/Pref Vila Boa/2024', 2024, 'No que diz respeito às configurações de violência doméstica e familiar contra a mulher, conforme a Lei nº 11.340/2006 − Lei Maria da Penha, avaliar se as afirmativas são certas (C) ou erradas (E) e assinalar a sequência correspondente. ( ) No âmbito da unidade doméstica, compreendida como o espaço de convívio permanente de pessoas, com ou sem vínculo familiar, inclusive as esporadicamente agregadas. ( ) No ambiente de trabalho, no qual o agressor é superior hierárquico, sem qualquer relação íntima de afeto ou parentesco com a ofendida. ( ) No âmbito da família, compreendida como a comunidade formada por indivíduos que são ou se consideram aparentados, unidos por laços naturais, por afinidade ou por vontade expressa.', 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A sequência correta é C-E-C. O primeiro item reproduz literalmente o art. 5º, I (unidade doméstica) — certo. O segundo item descreve uma relação de trabalho, com superior hierárquico, sem qualquer relação íntima de afeto ou parentesco com a ofendida — essa situação não se enquadra em nenhum dos três âmbitos do art. 5º (não é unidade doméstica, não é família, não é relação íntima de afeto) — errado. O terceiro item reproduz literalmente o art. 5º, II (família) — certo.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Inverte o primeiro e o segundo itens — marca o item da unidade doméstica (correto) como errado e o item do ambiente de trabalho sem vínculo íntimo/familiar (que está fora do alcance dos três âmbitos) como certo.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Marca todos os itens como certos, incluindo o segundo, que descreve uma situação sem qualquer dos três âmbitos do art. 5º.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Marca todos os itens como errados, incluindo o primeiro e o terceiro, que reproduzem literalmente os incisos I e II do art. 5º.

BIZU DE PROVA:
Relação de trabalho com superior hierárquico, SEM relação íntima de afeto ou parentesco, não se enquadra em nenhum dos três âmbitos do art. 5º — casos assim (assédio moral/sexual no trabalho, por exemplo) são tratados por outras normas (CLT, Código Penal), não pela Lei Maria da Penha, salvo se também houver vínculo familiar ou afetivo entre agressor e vítima.', 'TEC Concursos — questão 3031784 — OBJETIVA CONCURSOS — ACS (Pref Vila Boa)/Pref Vila Boa/2024'),
  (2812702, 'Instituto Consulplan', 'Prom Jus (MPE SC)/MPE SC/2024', 2024, 'Sobre o Estatuto da Criança e do Adolescente, Lei nº 8.069/1990, julgue os itens a seguir. Ana afirmou ser vítima de violência doméstica praticada pelo seu ex-namorado, José, com quem se relacionou durante um ano, até romperem em decorrência dos ciúmes excessivos do rapaz. Nos meses subsequentes ao término, José, inconformado, começou a realizar diuturnas ligações telefônicas para o aparelho celular da ex-namorada pela manhã, tarde, noite e alta madrugada. Ana pediu a troca de número a sua operadora diversas vezes. José conseguiu obter os novos números, prosseguiu nas tentativas de contato telefônico e começou a enviar e-mails diários ao perceber que Ana não o respondia. Desesperada e atormentada psicologicamente, Ana procurou uma delegacia e obteve, da magistrada competente, medida protetiva de urgência que determinou que seu ex-namorado, José, não a procurasse por quaisquer meios de comunicação, determinação que ele, entretanto, descumpriu ao descobrir que Ana havia viajado para Jurerê Internacional no carnaval 2024. As formas de violência doméstica e familiar contra a mulher estão, taxativamente, previstas no Art. 7º da Lei nº 11.340/2006, não sendo objeto de medidas protetivas de urgência outras senão aquelas elencadas nesse dispositivo. O caso dá azo à aplicação da medida.', 'GABARITO: ERRADO

POR QUE:
O art. 7º da Lei 11.340/2006 é expresso ao dizer que "são formas de violência doméstica e familiar contra a mulher, ENTRE OUTRAS" — o rol é exemplificativo, não taxativo. A afirmativa do enunciado, ao dizer que as formas estão "taxativamente" previstas e que não pode haver medida protetiva para situações "outras senão aquelas elencadas", contraria diretamente essa característica da Lei. A própria Lei 15.384/2026, que acrescentou a violência vicária como um sexto inciso ao art. 7º, reforça essa conclusão: se o rol fosse mesmo taxativo e fechado, não seria juridicamente possível acrescentar uma nova modalidade quase 20 anos depois. (Nota: o enunciado cita, em seu preâmbulo, o "Estatuto da Criança e do Adolescente, Lei nº 8.069/1990" como lei de referência, mas todo o conteúdo tratado é da Lei Maria da Penha — erro histórico do enunciado original, preservado tal como a banca apresentou.)

BIZU DE PROVA:
"Entre outras" (art. 7º, caput) é a expressão que garante que o rol de modalidades de violência doméstica é exemplificativo, não exaustivo — sempre que uma questão afirmar que a lista é "taxativa" ou "exaustiva", desconfie.

PEGADINHA:
A perseguição contumaz por telefone/e-mail de José contra Ana, embora não seja o cerne do que a questão testa, de fato se enquadra perfeitamente em violência psicológica (art. 7º, II) — o erro do item não está em dizer que "o caso dá azo à aplicação da medida" (isso está correto), mas em afirmar que o rol do art. 7º é taxativo.', 'TEC Concursos — questão 2812702 — Instituto Consulplan — Prom Jus (MPE SC)/MPE SC/2024'),
  (3021691, 'OBJETIVA CONCURSOS', 'Enf (Pref Nonoai)/Pref Nonoai/2024', 2024, 'Sobre a violência doméstica e familiar contra a mulher, de acordo com a Lei nº 11.340/2006 – Lei Maria da Penha, assinalar a alternativa INCORRETA.', 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA (é a alternativa INCORRETA, pedida pelo enunciado):
O parágrafo único do art. 5º estabelece que as relações pessoais enunciadas no artigo INDEPENDEM de orientação sexual — a alternativa inverte essa regra ao afirmar que "dependem".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (é uma afirmação correta, portanto não é a exceção pedida):
Reproduz literalmente o art. 5º, I (unidade doméstica).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA (é uma afirmação correta, portanto não é a exceção pedida):
Reproduz literalmente o art. 5º, III (relação íntima de afeto, independentemente de coabitação).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA (é uma afirmação correta, portanto não é a exceção pedida):
Reproduz literalmente o art. 5º, II (família).

BIZU DE PROVA:
"Independem de orientação sexual" é a redação exata do parágrafo único do art. 5º — qualquer alternativa que inverta para "dependem" está automaticamente errada.', 'TEC Concursos — questão 3021691 — OBJETIVA CONCURSOS — Enf (Pref Nonoai)/Pref Nonoai/2024'),
  (3014724, 'OBJETIVA CONCURSOS', 'Fono (Pref Jaguariaíva)/Pref Jaguariaíva/2024', 2024, 'A respeito das formas de violência doméstica e familiar, conforme a Lei nº 11.340/2006 – Lei Maria da Penha, relacionar as colunas e assinalar a sequência correspondente. (1) Violência física. (2) Violência psicológica. (3) Violência moral. ( ) Entendida como qualquer conduta que lhe cause dano emocional e diminuição da autoestima ou que lhe prejudique e perturbe o pleno desenvolvimento ou que vise degradar ou controlar suas ações. ( ) Entendida como qualquer conduta que ofenda sua integridade ou saúde corporal. ( ) Entendida como qualquer conduta que configure calúnia, difamação ou injúria.', 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A sequência correta é 2-1-3: psicológica (2) corresponde a "dano emocional e diminuição da autoestima... degradar ou controlar suas ações" (art. 7º, II); física (1) corresponde a "ofenda sua integridade ou saúde corporal" (art. 7º, I); moral (3) corresponde a "calúnia, difamação ou injúria" (art. 7º, V).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A sequência "1-3-2" atribui física ao primeiro item (deveria ser psicológica) e moral ao segundo (deveria ser física).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A sequência "2-3-1" acerta o primeiro item (psicológica), mas troca física e moral nos itens seguintes.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A sequência "3-2-1" inverte totalmente a ordem correta.

BIZU DE PROVA:
Dano emocional/autoestima/controle = psicológica; integridade/saúde corporal = física; calúnia/difamação/injúria = moral. Monte essa associação antes de tentar casar a sequência numérica.', 'TEC Concursos — questão 3014724 — OBJETIVA CONCURSOS — Fono (Pref Jaguariaíva)/Pref Jaguariaíva/2024'),
  (3007260, 'ITAME', 'ASoc (Pref C Dourada (GO))/Pref C Dourada (GO)/2024', 2024, 'Preencha as lacunas a seguir, tomando por base a Lei nº 11.340/2006, também conhecida como Lei Maria da Penha e, em seguida, marque a alternativa que apresenta a sequência correta. 1) A ____________________ é entendida como qualquer conduta que cause à mulher dano emocional e diminuição da autoestima ou que lhe prejudique e perturbe o pleno desenvolvimento ou que vise degradar ou controlar suas ações, comportamentos, crenças e decisões, mediante ameaça, constrangimento, humilhação, manipulação, isolamento, vigilância constante, perseguição contumaz, insulto, chantagem, violação de sua intimidade, ridicularização, exploração e limitação do direito de ir e vir ou qualquer outro meio que lhe cause prejuízo à saúde psicológica e à autodeterminação. 2) A ___________________ é entendida como qualquer conduta que constranja a mulher a presenciar, a manter ou a participar de relação sexual não desejada, mediante intimidação, ameaça, coação ou uso da força; que a induza a comercializar ou a utilizar, de qualquer modo, a sua sexualidade, que a impeça de usar qualquer método contraceptivo ou que a force ao matrimônio, à gravidez, ao aborto ou à prostituição, mediante coação, chantagem, suborno ou manipulação; ou que limite ou anule o exercício de seus direitos sexuais e reprodutivos. 3) A ___________________ é entendida como qualquer conduta que configure calúnia, difamação ou injúria. 4) A ___________________ é entendida como qualquer conduta que configure retenção, subtração, destruição parcial ou total de seus objetos, instrumentos de trabalho, documentos pessoais, bens, valores e direitos ou recursos econômicos, incluindo os destinados a satisfazer suas necessidades.', 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
As quatro lacunas são preenchidas, respectivamente, por psicológica (definição literal do art. 7º, II), sexual (definição literal do art. 7º, III), moral (definição literal do art. 7º, V) e patrimonial (definição literal do art. 7º, IV) — a alternativa C reproduz corretamente essa sequência.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Usa "moral", "espiritual", "psicológica" e "parental" nessa ordem — não corresponde às definições literais apresentadas (a primeira definição, por exemplo, é de psicológica, não moral; "espiritual" e "parental" nem sequer são modalidades da Lei).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Usa termos inventados ("sentimental", "criminosa", "injuriosa", "transpessoal") que não são modalidades nomeadas pela Lei.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Usa termos inventados ("virtual", "militar", "profissional", "civil") que não são modalidades nomeadas pela Lei.

BIZU DE PROVA:
Cada definição do art. 7º é bastante característica — decore as palavras-chave (emocional/autoestima=psicológica; contraceptivo/gravidez/aborto/prostituição=sexual; calúnia/difamação/injúria=moral; objetos/bens/documentos=patrimonial) para preencher lacunas com segurança, mesmo em questões longas como esta.', 'TEC Concursos — questão 3007260 — ITAME — ASoc (Pref C Dourada (GO))/Pref C Dourada (GO)/2024'),
  (3509833, 'OBJETIVA CONCURSOS', 'Ag (Pref Guaraniaçu)/Pref Guaraniaçu/Comunitário de Saúde/2024', 2024, 'Sobre as formas de violência psicológica, conforme a Lei nº 11.340/2006 − Lei Maria da Penha, analisar os itens. I. Perseguição contumaz. II. Ridicularização. III. Manipulação. Está CORRETO o que se afirma:', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Perseguição contumaz, ridicularização e manipulação são todos meios expressamente listados no art. 7º, II, como formas de violência psicológica — os três itens estão corretos.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Considera apenas o item I, mas os itens II e III também são meios de violência psicológica citados no art. 7º, II.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Considera apenas o item III, mas os itens I e II também estão corretos.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Exclui indevidamente o item I, que também é meio de violência psicológica citado no art. 7º, II.

BIZU DE PROVA:
O art. 7º, II, lista um rol extenso de meios (ameaça, constrangimento, humilhação, manipulação, isolamento, vigilância constante, perseguição contumaz, insulto, chantagem, violação de intimidade, ridicularização, exploração, limitação do direito de ir e vir) — vale a pena memorizar essa lista inteira, pois costuma ser cobrada meio a meio.', 'TEC Concursos — questão 3509833 — OBJETIVA CONCURSOS — Ag (Pref Guaraniaçu)/Pref Guaraniaçu/Comunitário de Saúde/2024'),
  (2826549, 'AVANÇASP', 'Ag (Pref Laranjal P)/Pref Laranjal Pta/Social/2024', 2024, 'Analise os itens de acordo com a Lei Federal n.º 11.340/06. Configura-se violência doméstica e familiar contra a mulher qualquer ação ou omissão baseada no gênero que lhe cause morte, lesão, sofrimento físico, sexual ou psicológico e dano moral ou patrimonial: I - No âmbito da unidade doméstica, compreendida como o espaço de convívio temporário de pessoas, com ou sem vínculo familiar, inclusive as esporadicamente agregadas. II - No âmbito da família, compreendida como a comunidade formada por indivíduos que são ou aparentados, unidos por laços naturais, exceto por afinidade.', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
As asserções I e II são ambas falsas. A asserção I erra ao trocar "convívio permanente" por "convívio temporário" — o art. 5º, I, exige convívio permanente. A asserção II erra ao dizer que os laços que unem a família são "naturais, exceto por afinidade" — o art. 5º, II, inclui expressamente a afinidade e a vontade expressa como bases válidas, ao lado dos laços naturais, sem excluir nenhuma delas.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Considera a asserção I falsa e a II verdadeira — mas a II também está errada, pelo motivo acima.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Considera as duas verdadeiras e a II complemento da I — nenhuma das duas é verdadeira.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Considera a asserção I verdadeira — mas ela é falsa, pelo motivo acima.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Considera as duas verdadeiras — nenhuma das duas é verdadeira.

BIZU DE PROVA:
Unidade doméstica = convívio PERMANENTE (nunca temporário). Família = laços naturais, por afinidade OU por vontade expressa (nunca "exceto por afinidade" ou qualquer outra exclusão) — essas duas trocas de palavra são armadilhas muito recorrentes.', 'TEC Concursos — questão 2826549 — AVANÇASP — Ag (Pref Laranjal P)/Pref Laranjal Pta/Social/2024'),
  (2826587, 'AVANÇASP', 'Ag (Pref Laranjal P)/Pref Laranjal Pta/Social/2024', 2024, 'Camila e Rafael, após anos de namoro, decidiram romper o relacionamento. Entretanto, desde a separação, Rafael tem demonstrado comportamentos agressivos, ameaçando a integridade física e psicológica de Camila. Mesmo não compartilhando o mesmo espaço físico, a violência persiste. De acordo com a legislação, a situação de Camila e Rafael, configura-se como violência doméstica e familiar contra a mulher, especialmente quando a coabitação não está presente?', 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Reproduz literalmente o art. 5º, caput, combinado com o inciso III — configura violência doméstica e familiar contra a mulher qualquer ação ou omissão baseada no gênero que lhe cause morte, lesão, sofrimento físico, sexual ou psicológico e dano moral ou patrimonial, em qualquer relação íntima de afeto na qual o agressor conviva ou tenha convivido com a ofendida, independentemente de coabitação — exatamente a situação de Camila e Rafael, ex-namorados que não coabitam.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A Lei não se limita a agressões físicas — o art. 7º prevê expressamente as modalidades psicológica, sexual, patrimonial e moral também.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A Lei não exige casamento legal — o art. 5º, III, alcança qualquer relação íntima de afeto, incluindo namoro.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O art. 5º, III, inclui expressamente quem "tenha convivido" com a ofendida — situações passadas estão cobertas, não apenas relações atuais.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A Lei não se limita a violência sexual — abrange as demais modalidades do art. 7º.

BIZU DE PROVA:
Ameaças pós-término de namoro, mesmo sem coabitação, configuram violência doméstica: "conviva ou tenha convivido... independentemente de coabitação" (art. 5º, III) é a frase-chave que resolve esse tipo de questão.', 'TEC Concursos — questão 2826587 — AVANÇASP — Ag (Pref Laranjal P)/Pref Laranjal Pta/Social/2024'),
  (3532980, 'IDECAN', 'ASoc (PB Saúde)/PB Saúde/2024', 2024, 'Configura violência doméstica e familiar contra a mulher qualquer ação ou omissão baseada no gênero que lhe cause morte, lesão, sofrimento físico, sexual ou psicológico e dano moral ou patrimonial, o que apreende diferentes âmbitos, entre eles:', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Reproduz literalmente o art. 5º, III — em qualquer relação íntima de afeto, na qual o agressor conviva ou tenha convivido com a ofendida, independentemente de coabitação.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Mistura a definição de violência moral (calúnia, difamação ou injúria, art. 7º, V) com o rótulo errado "violência patrimonial", e ainda trata isso como um "âmbito" — calúnia/difamação/injúria é modalidade de violência, não âmbito de incidência.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Atribui à "família" a definição de unidade doméstica (art. 5º, I: "espaço de convívio permanente de pessoas, com ou sem vínculo familiar, inclusive as esporadicamente agregadas") — rótulo trocado.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Atribui à "unidade doméstica" a definição de família (art. 5º, II: "comunidade formada por indivíduos que são ou se consideram aparentados...") — rótulo trocado, espelhando o erro da alternativa B.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Mistura a definição de violência psicológica (art. 7º, II) com o rótulo errado "violência física", e trata isso como "âmbito" quando psicológica é modalidade, não âmbito.

BIZU DE PROVA:
As alternativas B e C trocam entre si as definições de "unidade doméstica" e "família" — leia com atenção redobrada quando duas opções parecerem "espelhadas": normalmente uma delas trocou os rótulos.', 'TEC Concursos — questão 3532980 — IDECAN — ASoc (PB Saúde)/PB Saúde/2024'),
  (3575952, 'ADM&TEC', 'ASoc (Pref São L Quitunde)/Pref São L Quitunde/2024', 2024, 'Por Violência Moral compreende-se:', 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
"Qualquer conduta que configure calúnia, difamação ou injúria" é a definição literal de violência moral dada pelo art. 7º, V.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
É a definição de violência patrimonial (art. 7º, IV), não moral.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
É a definição de violência sexual (art. 7º, III), não moral.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
É a definição de violência física (art. 7º, I), não moral.

BIZU DE PROVA:
Calúnia/difamação/injúria = moral, sempre. Uma das associações mais cobradas em provas objetivas sobre a Lei Maria da Penha.', 'TEC Concursos — questão 3575952 — ADM&TEC — ASoc (Pref São L Quitunde)/Pref São L Quitunde/2024'),
  (2983066, 'FGV', 'GM (Pref Vitória)/Pref Vitória/2024', 2024, 'Joana, casada com Caio há cinco anos, resolveu procurar um advogado para se divorciar, de forma a pôr fim ao vínculo matrimonial, pois, em diversas ocasiões, Caio pratica, em seu detrimento, condutas caracterizadoras de calúnia, difamação e injúria. Nesse cenário, considerando as disposições da Lei no 11.340/2006 (Lei Maria da Penha), é correto afirmar que Caio, ao caluniar, difamar e injuriar Joana, está cometendo uma violência', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Caluniar, difamar e injuriar Joana é exatamente a conduta definida pelo art. 7º, V, como violência moral.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Não há relato de retenção, subtração ou destruição de bens/valores — a conduta narrada é de ataque à honra, não patrimonial.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Calúnia, difamação e injúria são especificamente tipificadas pela Lei como violência moral (art. 7º, V) — não psicológica.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não há relato de conduta sexual.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não há relato de agressão física.

BIZU DE PROVA:
O próprio enunciado já nomeia as três condutas que definem violência moral (calúnia, difamação, injúria) — quando isso acontece, a resposta é sempre "moral" (art. 7º, V), mesmo que a pergunta pareça simples demais.', 'TEC Concursos — questão 2983066 — FGV — GM (Pref Vitória)/Pref Vitória/2024'),
  (2983038, 'CEBRASPE (CESPE)', 'ASoc (Pref Cach Itapemirim)/Pref Cach Itapemirim/2024', 2024, 'Maria, com 62 anos de idade, é casada com João, com 66 anos de idade. Moram com eles Antônio, filho de João e Maria, Ana, esposa de Antônio, e Júlio, filho de Antônio e Ana. Com referência a essa situação hipotética, julgue o seguinte item. Nesse sentido, considere que a sigla BPC, sempre que empregada, se refere ao benefício de prestação continuada. Ana tem o direito de usar métodos contraceptivos para o exercício de seus direitos sexuais e reprodutivos no âmbito do casamento. No caso de proibição por parte de Antônio, tal fato será considerado uma forma de violência doméstica, conforme a Lei Maria da Penha.', 'GABARITO: CERTO

POR QUE:
Impedir a mulher de usar métodos contraceptivos é conduta expressamente descrita no art. 7º, III, como violência sexual. A relação entre Ana e Antônio, marido e mulher, se enquadra no âmbito da relação íntima de afeto e/ou da família (art. 5º, II e III) — a eventual proibição de Antônio configura, sim, violência doméstica e familiar contra Ana, na modalidade sexual.

BIZU DE PROVA:
"Impedir uso de método contraceptivo" é um dos exemplos mais literais e diretos do art. 7º, III — sempre que aparecer esse tema (contracepção, gravidez, aborto, prostituição forçada), pense em violência sexual.

PEGADINHA:
O caso apresenta um núcleo familiar extenso (Maria, João, Antônio, Ana, Júlio) — não se distraia com os demais personagens; o item pergunta especificamente sobre Ana e Antônio, marido e mulher entre si.', 'TEC Concursos — questão 2983038 — CEBRASPE (CESPE) — ASoc (Pref Cach Itapemirim)/Pref Cach Itapemirim/2024'),
  (2983032, 'CEBRASPE (CESPE)', 'ASoc (Pref Cach Itapemirim)/Pref Cach Itapemirim/2024', 2024, 'Maria, com 62 anos de idade, é casada com João, com 66 anos de idade. Moram com eles Antônio, filho de João e Maria, Ana, esposa de Antônio, e Júlio, filho de Antônio e Ana. Com referência a essa situação hipotética, julgue o seguinte item. Nesse sentido, considere que a sigla BPC, sempre que empregada, se refere ao benefício de prestação continuada. Se Maria tiver seus documentos pessoais retidos e posteriormente destruídos por João, esse fato será considerado uma forma de violência patrimonial, de acordo com a Lei Maria da Penha.', 'GABARITO: CERTO

POR QUE:
Reter e destruir os documentos pessoais de Maria é conduta expressamente descrita no art. 7º, IV, como violência patrimonial. Sendo Maria casada com João, a relação se enquadra no âmbito familiar/da relação íntima de afeto (art. 5º, II e/ou III) exigido pela Lei.

BIZU DE PROVA:
"Retenção... de documentos pessoais" é termo literal do art. 7º, IV — documento pessoal retido ou destruído por familiar/cônjuge é sempre patrimonial, independentemente do valor financeiro do documento em si.

PEGADINHA:
Assim como no item anterior sobre este mesmo caso (caderno 351), não se distraia com o núcleo familiar extenso — o item pergunta especificamente sobre Maria e João, marido e mulher entre si.', 'TEC Concursos — questão 2983032 — CEBRASPE (CESPE) — ASoc (Pref Cach Itapemirim)/Pref Cach Itapemirim/2024'),
  (3595916, 'FUNDATEC', 'ASoc (Pref Alegria)/Pref Alegria/2024', 2024, 'Analise as seguintes asserções e a relação proposta entre elas, tendo por referência a Lei Federal nº 11.340/2006, Lei Maria da Penha: I. A violência doméstica e familiar contra a mulher constitui uma das formas de violação dos direitos humanos. PORQUE II. Os direitos das mulheres estão acima de todos os demais direitos. A respeito dessas asserções, assinale a alternativa correta.', 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A asserção I é verdadeira — reproduz literalmente o art. 6º (a violência doméstica e familiar contra a mulher constitui uma das formas de violação dos direitos humanos). A asserção II é falsa — a Lei Maria da Penha não estabelece que os direitos das mulheres estão "acima de todos os demais direitos"; a proteção da mulher em situação de violência doméstica coexiste com os demais direitos e princípios do ordenamento jurídico, sem instituir uma hierarquia absoluta desse tipo.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Considera a asserção I falsa — mas ela reproduz literalmente o art. 6º, sendo verdadeira.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Considera a asserção II verdadeira e ainda uma justificativa da I — a II é falsa, pelo motivo acima, e por isso não pode justificar nada.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Considera a asserção II verdadeira — ela é falsa.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Considera as duas falsas — a I é verdadeira (art. 6º).

BIZU DE PROVA:
Cuidado com asserções do tipo "PORQUE" que generalizam de forma absoluta ("acima de todos os demais direitos", "sempre", "em qualquer hipótese") — esse tipo de afirmação extrema raramente corresponde ao texto real da Lei, mesmo quando a primeira asserção (mais moderada) está correta.', 'TEC Concursos — questão 3595916 — FUNDATEC — ASoc (Pref Alegria)/Pref Alegria/2024'),
  (2968027, 'ITAME', 'Ag (Pref SLM Belos)/Pref SLM Belos/Comunitário de Saúde/2024', 2024, 'De acordo com a Lei Maria da Penha, são formas de violência doméstica e familiar contra a mulher:', 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Violência psicológica é modalidade expressamente prevista no art. 7º, II, da Lei 11.340/2006.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Violência imoral" não é o nome usado pela Lei — o termo correto é "violência moral" (art. 7º, V).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Violência matrimonial" não é modalidade nomeada pela Lei — o termo correto para bens/valores é "violência patrimonial" (art. 7º, IV).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Violência ortopédica" não é modalidade nomeada pela Lei nem conceito jurídico correspondente.

BIZU DE PROVA:
Termos parecidos com os nomes reais das modalidades — "imoral" (moral), "matrimonial" (patrimonial) — são pegadinha clássica de trocadilho sonoro; "ortopédica" é claramente inventado, mas serve para eliminar quem não está prestando atenção.', 'TEC Concursos — questão 2968027 — ITAME — Ag (Pref SLM Belos)/Pref SLM Belos/Comunitário de Saúde/2024'),
  (3595917, 'FUNDATEC', 'ASoc (Pref Alegria)/Pref Alegria/2024', 2024, 'Amélia, casada há 10 anos, compareceu à delegacia da cidade onde mora para denunciar prática de violência cometida contra ela por seu marido. Entre as atitudes descritas por Amélia, estão: “meu marido quebrou o meu celular e gastou todo o dinheiro que eu possuía na minha conta bancária, sem autorização”. Tendo em vista o que prevê a Lei Maria da Penha, qual é o tipo de violência narrada por Amélia?', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O marido de Amélia quebrou o celular dela e gastou o dinheiro da conta bancária dela sem autorização — condutas que se enquadram na definição de violência patrimonial (art. 7º, IV: destruição de objeto e subtração de valores/recursos econômicos).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Não há relato de conduta sexual.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Violência afetiva" não é modalidade nomeada pela Lei.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Embora as condutas narradas certamente causem sofrimento psicológico a Amélia, elas se enquadram mais precisamente na definição específica de violência patrimonial (destruição de objeto + subtração de valores), que é o que a Lei nomeia especificamente para esse tipo de conduta.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não há relato de calúnia, difamação ou injúria.

BIZU DE PROVA:
Quebrar objeto + gastar/subtrair dinheiro da vítima sem autorização = patrimonial, de forma bem direta — mesmo quando a narrativa é emocionalmente carregada (relato de denúncia na delegacia), identifique a conduta OBJETIVA descrita para classificar a modalidade.', 'TEC Concursos — questão 3595917 — FUNDATEC — ASoc (Pref Alegria)/Pref Alegria/2024'),
  (3596067, 'FUNDATEC', 'Coz (Pref Alegria)/Pref Alegria/2024', 2024, '“Ele pegou, veio para cima de mim. Aí começou a luta, foi aí que apareceram cinco pessoas tentando acalmar, bateram nele. Quando as pessoas saíram, ele voltou de novo. A polícia veio ligeiro. Quando os policiais chegaram, ele estava por cima de mim, me batendo”. Este é um trecho de uma reportagem publicada no G1 em 12/08/21, que apresenta o relato de uma mulher vítima de violência pelo seu marido. De acordo com a Lei Maria da Penha, Lei nº 11.340/2006, a mulher sofreu violência:', 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O relato descreve agressão física direta ("bateram nele", "ele estava por cima de mim, me batendo") — conduta que ofende a integridade corporal da vítima, configurando violência física (art. 7º, I).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Violência emocional" não é o nome usado pela Lei para nenhuma modalidade — o relato, de todo modo, descreve agressão física, não apenas dano emocional.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não há relato de conduta patrimonial (bens, objetos, valores).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Violência afetiva" não é modalidade nomeada pela Lei.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não há relato de conduta sexual.

BIZU DE PROVA:
Relatos com verbos de agressão corporal direta (bater, empurrar, segurar à força) = física, quase sempre a resposta mais imediata quando não há outro elemento (patrimonial, sexual) descrito.', 'TEC Concursos — questão 3596067 — FUNDATEC — Coz (Pref Alegria)/Pref Alegria/2024'),
  (2966706, 'Instituto Consulplan', 'Cuid Soc (Pref SM Jetibá)/Pref SM Jetibá/2024', 2024, 'A violência contra a mulher é uma realidade global que transcende fronteiras culturais e socioeconômicas, constituindo-se como uma grave violação dos direitos humanos. Manifestando-se de diversas formas, desde agressões físicas até abusos psicológicos, essa problemática persiste como um desafio persistente nas sociedades contemporâneas. Com base no trecho da Lei Maria da Penha, que aborda as formas de violência doméstica e familiar contra a mulher, assinale a afirmativa que define corretamente a violência psicológica.', 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Reproduz, de forma completa e literal, a definição de violência psicológica do art. 7º, II: conduta que causa dano emocional e diminuição da autoestima, controla ações, comportamentos, opiniões e decisões, por meio de ameaça, constrangimento, humilhação, dentre outros.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Usa a expressão "violação de intimidação" (assim mesmo redigida no enunciado original, preservada sem correção), que não corresponde ao termo legal "violação de sua intimidade" do art. 7º, II. Mesmo interpretada de forma benevolente, a alternativa oferece apenas um exemplo pontual, e não a definição completa de violência psicológica pedida pelo enunciado ("define corretamente").

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
É a definição de violência sexual (art. 7º, III — impedir uso de contraceptivo, forçar a matrimônio/gravidez/aborto/prostituição), oferecida como opção para a pergunta sobre psicológica.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
É a definição de violência patrimonial (art. 7º, IV — retenção/subtração/destruição de objetos, bens, valores), oferecida como opção para a pergunta sobre psicológica.

BIZU DE PROVA:
Quando o enunciado pede a definição COMPLETA de uma modalidade ("define corretamente"), prefira sempre a alternativa que reproduz o texto integral do artigo, não um exemplo isolado ou uma conduta específica — mesmo que essa conduta específica também estivesse tecnicamente correta se bem redigida.', 'TEC Concursos — questão 2966706 — Instituto Consulplan — Cuid Soc (Pref SM Jetibá)/Pref SM Jetibá/2024'),
  (3630576, 'FUNDATEC', 'Ass Soc (CM Passo Sobrado)/CM Passo Sobrado/2024', 2024, 'Julia engravidou de Rodrigo, e ele a forçou a abortar. Conforme previsto na Lei Maria da Penha, a atitude de Rodrigo é enquadrada como qual forma de violência doméstica e familiar?', 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O art. 7º, III, define violência sexual como, entre outras condutas, a que force a mulher "ao matrimônio, à gravidez, AO ABORTO ou à prostituição, mediante coação, chantagem, suborno ou manipulação" — forçar Julia a abortar se enquadra literalmente nesse dispositivo.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Embora a conduta cause evidente sofrimento psicológico a Julia, a Lei tipifica especificamente "forçar ao aborto" como uma das condutas de violência SEXUAL (art. 7º, III), não psicológica — é a classificação legal mais precisa.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não há relato de agressão à integridade física de Julia por meios diversos da coação para o aborto forçado, que a Lei classifica especificamente como sexual.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não há relato de conduta sobre bens, objetos ou valores.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não há relato de calúnia, difamação ou injúria.

BIZU DE PROVA:
"Forçar ao matrimônio, à gravidez, ao aborto ou à prostituição" é trecho literal do art. 7º, III — mesmo em cenários emocionalmente carregados, quando a conduta se encaixar textualmente nesse trecho, a classificação legal é sempre violência sexual.', 'TEC Concursos — questão 3630576 — FUNDATEC — Ass Soc (CM Passo Sobrado)/CM Passo Sobrado/2024'),
  (2962308, 'IBADE', 'Ass Soc (Pref Jaru)/Pref Jaru/2024', 2024, 'Associe as formas de violência doméstica e familiar contra a mulher (1ª coluna) com seus respectivos exemplos legais de acordo com a Lei Maria da Penha (2ª coluna) e, em seguida, assinale a alternativa que apresenta a sequência CORRETA: (1) Violência psicológica (2) Violência patrimonial (3) Violência moral ( ) Conduta que configure calúnia, difamação ou injúria. ( ) Conduta que causa dano emocional e diminuição da autoestima. ( ) Conduta que perturbe o pleno desenvolvimento ou que vise degradar ou controlar suas ações. ( ) Conduta que configure retenção de objetos, instrumentos de trabalho e documentos pessoais.', 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A sequência correta é 3-1-1-2: calúnia/difamação/injúria (3, moral); dano emocional/diminuição da autoestima (1, psicológica); perturbar o pleno desenvolvimento/degradar ou controlar ações (1, psicológica); retenção de objetos/instrumentos de trabalho/documentos (2, patrimonial).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A sequência "1-1-2-3" atribui psicológica ao primeiro item (calúnia/difamação/injúria), quando deveria ser moral (3).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A sequência "3-1-2-3" acerta os dois primeiros itens, mas atribui patrimonial (2) ao terceiro item (que é psicológica, 1) e moral (3) ao quarto (que é patrimonial, 2).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A sequência "2-1-2-3" atribui patrimonial ao primeiro item (calúnia/difamação/injúria), quando deveria ser moral.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A sequência "1-3-3-2" atribui psicológica ao primeiro item e moral ao segundo e terceiro — todos trocados em relação ao correto.

BIZU DE PROVA:
Calúnia/difamação/injúria = moral (3); dano emocional/autoestima/degradar-controlar = psicológica (1, aparece duas vezes nesta questão, em exemplos diferentes da mesma modalidade); retenção de objetos/instrumentos/documentos = patrimonial (2). Repare que "psicológica" pode aparecer mais de uma vez na sequência, pois o art. 7º, II, tem uma definição longa com vários elementos.', 'TEC Concursos — questão 2962308 — IBADE — Ass Soc (Pref Jaru)/Pref Jaru/2024'),
  (3630969, 'FUNDATEC', 'ASG (CM Passo Sobrado)/CM Passo Sobrado/2024', 2024, 'Com base na Lei Maria da Penha, “A violência          , forma de violência doméstica e familiar contra a mulher, é entendida como qualquer conduta que ofenda sua integridade ou saúde corporal”. Assinale a alternativa que preenche corretamente a lacuna do trecho acima.', 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
"Física" é a modalidade cuja definição legal é "qualquer conduta que ofenda sua integridade ou saúde corporal" (art. 7º, I, da Lei 11.340/2006) — exatamente o texto do trecho apresentado.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Espiritual" não é modalidade nomeada pela Lei.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Corporal" descreve o que é ofendido pela violência física (a saúde/integridade CORPORAL), mas não é o nome da modalidade — o nome correto é "física".

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Violência moral (art. 7º, V) é definida como calúnia, difamação ou injúria — não como ofensa à integridade/saúde corporal.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Violência psicológica (art. 7º, II) tem definição própria (dano emocional, diminuição de autoestima etc.) — não corresponde ao trecho apresentado.

BIZU DE PROVA:
"Corporal" é uma pegadinha inteligente — soa relacionado (a definição de física menciona "saúde corporal"), mas não é o NOME da modalidade. Sempre responda com o nome oficial: física, psicológica, sexual, patrimonial, moral (ou vicária, desde 2026).', 'TEC Concursos — questão 3630969 — FUNDATEC — ASG (CM Passo Sobrado)/CM Passo Sobrado/2024'),
  (2955765, 'Instituto Consulplan', 'Ori Soc (Pref Espera Feliz)/Pref Espera Feliz/2024', 2024, 'Sávio é orientador social da Prefeitura Municipal de Espera Feliz e uma de suas atribuições é desenvolver atividades socioeducativas, de convivência e socialização em uma instituição para mulheres vítimas de violência doméstica. Em uma das oficinas, Sávio trabalha conceitos relacionados à Lei nº 11.340/2006, também chamada de Lei Maria da Penha. Sobre esse dispositivo legal, assinale a afirmativa INCORRETA.', 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA (é a afirmativa INCORRETA, pedida pelo enunciado):
Atribui à violência patrimonial a definição que, na verdade, é da violência MORAL (art. 7º, V — calúnia, difamação ou injúria). A definição de violência patrimonial (art. 7º, IV) trata de retenção, subtração ou destruição de objetos, bens, valores e recursos econômicos — nada disso é mencionado na alternativa.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (é uma afirmativa correta, portanto não é a exceção pedida):
Reproduz literalmente a definição de violência física do art. 7º, I.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA (é uma afirmativa correta, portanto não é a exceção pedida):
Reproduz literalmente o art. 6º da Lei.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA (é uma afirmativa correta, portanto não é a exceção pedida):
Reproduz literalmente o art. 5º, caput, da Lei.

BIZU DE PROVA:
Mais uma vez o mislabeling clássico entre patrimonial e moral — sempre que "calúnia, difamação ou injúria" aparecer rotulado como "patrimonial" (ou qualquer modalidade que não seja "moral"), a alternativa está errada.', 'TEC Concursos — questão 2955765 — Instituto Consulplan — Ori Soc (Pref Espera Feliz)/Pref Espera Feliz/2024'),
  (3682521, 'CPCON UEPB', 'Ass Sc (Soledade PB)/Pref Soledade (PB)/2024', 2024, 'Maria é uma adolescente de 14 anos de idade, estudante da escola municipal do município ABCD, e faz o 8° ano do Ensino Fundamental. Sua mãe faleceu quando ela tinha cinco anos de idade, e atualmente Maria reside com seu pai e seus dois irmãos, também adolescentes. Maria está grávida de 15 semanas de gestação, cujo genitor do seu filho é o seu namorado, que estuda com ela na mesma série e escola. Após o pai de Maria ficar sabendo que ela estava grávida, ele danificou e jogou o celular e o material escolar de Maria no lixo, e começou a insultá-la e humilhá-la todos os dias em sua residência, difamando-a também periodicamente na vizinhança onde moram. De acordo com o relato da história apresentada, considerando Lei Maria da Penha - Lei nº 11.340/2006 e suas atualizações, a analise as afirmativas a seguir: I- Maria é vítima de violência doméstica e familiar contra a mulher, sofrendo exclusivamente violência psicológica, cujo agressor é o seu pai. II- O pai de Maria não pratica violência doméstica e familiar contra a mulher junto à sua filha, por não ter relação íntima de afeto com Maria. III- O pai de Maria não pratica violência doméstica e familiar contra a mulher junto à sua filha, por ser seu pai, cometendo apenas tratamento cruel ou degradante em relação à adolescente. IV- Maria é vítima de violência doméstica e familiar contra a mulher, sofrendo violência psicológica, patrimonial e moral, cujo agressor é seu pai. É CORRETO o que se afirma apenas em:', 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA (apenas o item IV está correto):
Maria sofre violência psicológica (o pai a insulta e humilha diariamente — art. 7º, II), violência patrimonial (o pai danifica e joga fora seu celular e material escolar — art. 7º, IV) e violência moral (o pai a difama periodicamente na vizinhança — art. 7º, V). O agressor é o pai de Maria, e a relação de parentesco (pai e filha) se enquadra no âmbito da família (art. 5º, II) — a Lei Maria da Penha se aplica a Maria mesmo sendo ela adolescente de 14 anos, pois protege vítima do gênero feminino em violência doméstica e familiar independentemente da idade (Tema Repetitivo 1.186 do STJ).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (considera apenas o item II, que é falso):
O item II está errado — o pai de Maria pratica, sim, violência doméstica e familiar, no âmbito da família (art. 5º, II: comunidade formada por indivíduos que são ou se consideram aparentados por laços naturais). Não é necessário haver "relação íntima de afeto" (art. 5º, III) quando já está configurado o âmbito da família — os três âmbitos do art. 5º são alternativos entre si, não cumulativos.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA (considera apenas o item III, que é falso):
O item III está errado pelo mesmo motivo: ser pai de Maria não exclui a aplicação da Lei — é justamente o vínculo de parentesco que configura o âmbito da família (art. 5º, II). O caso não se resume a "tratamento cruel ou degradante"; configura violência doméstica e familiar nos termos específicos da Lei Maria da Penha.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA (considera apenas o item II, que é falso pelo motivo já exposto):
Mesma razão da alternativa A.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA (considera apenas o item I, que é falso):
O item I está errado ao dizer que Maria sofre EXCLUSIVAMENTE violência psicológica — ela também sofre violência patrimonial (celular e material escolar destruídos) e moral (difamação na vizinhança), como descreve corretamente o item IV.

BIZU DE PROVA:
Os três âmbitos do art. 5º (unidade doméstica, família, relação íntima de afeto) são independentes entre si — não ter "relação íntima de afeto" com o agressor não afasta a Lei quando há vínculo familiar. E a Lei Maria da Penha protege vítima do gênero feminino em violência doméstica e familiar mesmo quando ela é criança ou adolescente (Tema 1.186/STJ) — nunca conclua que a idade da vítima, por si só, afasta a aplicação da Lei.', 'TEC Concursos — questão 3682521 — CPCON UEPB — Ass Sc (Soledade PB)/Pref Soledade (PB)/2024'),
  (2955256, 'Legalle', 'CTSP (BM RS)/BM RS/2024', 2024, 'De acordo com a Lei n.º 11 340/2006 (Lei Maria da Penha). assinale a alternativa CORRETA.', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
A Lei Maria da Penha pode incidir na agressão entre irmãos, pois "família" (art. 5º, II) é definida como a comunidade formada por indivíduos que são ou se consideram aparentados, unidos por laços naturais, por afinidade ou por vontade expressa — irmãos são aparentados por laços naturais, independentemente de coabitação atual.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O art. 17 veda a substituição da pena por pagamento ISOLADO de multa ou por prestação pecuniária/cesta básica, mas a afirmação de que a substituição por restritiva de direitos em geral "não é impedida" é excessivamente ampla — muitos crimes praticados em contexto de violência doméstica envolvem violência ou grave ameaça à pessoa, o que já impede a substituição por restritiva de direitos pela regra geral do art. 44, I, do Código Penal, independentemente do art. 17 da Lei Maria da Penha.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O art. 5º, III, dispensa expressamente a coabitação para a configuração da violência doméstica em relação íntima de afeto.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A competência do Juizado de Violência Doméstica não é afastada pela condição de "figura pública" da vítima — a Lei não estabelece essa exceção, e a proteção decorre da relação entre agressor e vítima (um dos âmbitos do art. 5º), não de uma análise casuística de vulnerabilidade social da ofendida.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Contraria o entendimento do STJ no Tema Repetitivo 983 (REsp 1.643.051-MS): nos casos de violência doméstica, a fixação de indenização mínima por dano moral é cabível com pedido expresso da acusação ou da ofendida, MAS dispensa tanto a instrução probatória específica quanto a especificação da quantia, por se tratar de dano psíquico in re ipsa (presumido pela própria natureza da agressão). A alternativa exige justamente o que o STJ dispensou, invertendo a regra.

BIZU DE PROVA:
"Família" (art. 5º, II) alcança qualquer parentesco por laços naturais, afinidade ou vontade expressa — inclui irmãos, pais, filhos, sogros etc., não apenas cônjuges/companheiros. E sobre indenização mínima em violência doméstica: pedido expresso é necessário, mas quantia especificada e instrução probatória são DISPENSÁVEIS (Tema 983/STJ, dano in re ipsa) — decore essa dispensa dupla, é armadilha recorrente.

Fontes: [Fixação do valor mínimo para reparação dos danos prevista no art. 387, IV, do CPP](https://buscadordizerodireito.com.br/jurisprudencia/5588/fixacao-do-valor-minimo-para-reparacao-dos-danos-prevista-no-art-387-iv-do-cpp); [STJ — Condenação por violência doméstica contra a mulher pode incluir dano moral mínimo mesmo sem prova específica](https://www.stj.jus.br/sites/portalp/Paginas/Comunicacao/Noticias-antigas/2018/2018-03-02_11-25_Condenacao-por-violencia-domestica-contra-a-mulher-pode-incluir-dano-moral-minimo-mesmo-sem-prova-especifica.aspx)', 'TEC Concursos — questão 2955256 — Legalle — CTSP (BM RS)/BM RS/2024'),
  (2941057, 'AVANÇASP', 'Coor CRAS (Pref Lorena)/Pref Lorena/2024', 2024, 'Sobre as formas de violência doméstica e familiar contra a mulher, entre outras, analise os itens a seguir: ( ) considera-se violência física, entendida como qualquer conduta que ofenda sua integridade ou que lhe cause dano emocional e diminuição da autoestima ou que lhe prejudique e perturbe o pleno desenvolvimento ou que vise degradar ou controlar suas ações. ( ) considera-se violência patrimonial, entendida como qualquer conduta que a constranja a presenciar, a manter ou a participar de relação sexual não desejada, mediante intimidação, ameaça, coação ou uso da força; que a induza a comercializar ou a utilizar, de qualquer modo, a sua sexualidade, que a impeça de usar qualquer método contraceptivo ou que a force ao matrimônio, à gravidez, ao aborto ou à prostituição, mediante coação, chantagem, suborno ou manipulação; ou que limite ou anule o exercício de seus direitos sexuais e reprodutivos. ( ) considera-se violência moral, entendida como qualquer conduta que configure calúnia, difamação ou injúria. Estão incorretas as assertivas.', 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA (I e II estão incorretas):
O item I rotula como "violência física" um texto que mistura o início da definição de física ("ofenda sua integridade") com quase toda a definição de violência PSICOLÓGICA (dano emocional, diminuição da autoestima, degradar ou controlar mediante ameaça, humilhação etc., art. 7º, II) — está incorreto. O item II rotula como "violência patrimonial" a definição de violência SEXUAL (constranger a presenciar/manter relação sexual não desejada, impedir contraceptivo, forçar a matrimônio/gravidez/aborto/prostituição, art. 7º, III) — também está incorreto. O item III, por sua vez, reproduz corretamente a definição de violência moral (calúnia, difamação ou injúria, art. 7º, V) — está correto.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Inclui o item III como incorreto, mas ele está corretamente definido (moral = calúnia, difamação, injúria).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Considera apenas o item III como incorreto, mas ele está correto; os itens I e II é que estão incorretos.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Inclui o item III como incorreto (ele está correto) e omite o item I (que está incorreto).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Considera os três itens incorretos, mas o item III está corretamente definido.

BIZU DE PROVA:
O item I desta questão é uma pegadinha "híbrida" rara: começa com a definição de física e termina com quase toda a definição de psicológica — leia a definição INTEIRA antes de decidir se o rótulo bate, não pare na primeira frase.', 'TEC Concursos — questão 2941057 — AVANÇASP — Coor CRAS (Pref Lorena)/Pref Lorena/2024'),
  (2847969, 'FUNDATEC', 'ASoc (Pref Alpestre)/Pref Alpestre/2024', 2024, 'Após a promulgação da Lei Maria da Penha, foram abertos mais espaços de discussão a respeito das várias formas de violência doméstica e familiar sofrida pelas mulheres, bem como ampliou-se os serviços de atendimento para as mulheres que sofrem ou sofreram violência doméstica e familiar. Com base na Lei Maria da Penha, assinale a alternativa correta.', 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
"A psicológica, a sexual, a física, a moral e a patrimonial" são as cinco formas de violência doméstica e familiar então nomeadas pelo art. 7º, incisos I a V, da Lei 11.340/2006. (Ressalva: lista fechada das 5 modalidades clássicas, sem hedge "entre outras"/"algumas" — esta questão é de 2024, anterior à Lei 15.384/2026, que acrescentou a violência vicária como sexto inciso; a alternativa A permanece a única plausível entre as opções dadas, pois nenhuma das demais seria corrigida pela adição da vicária — todas têm defeitos independentes dessa contagem.)

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Contraria diretamente o art. 6º, que reconhece a violência doméstica como uma das formas de violação dos direitos humanos.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O art. 8º, caput, estabelece que a política pública é realizada por um conjunto articulado de ações da União, dos Estados, do Distrito Federal, dos Municípios e de ações não governamentais — não apenas pelos municípios.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Atribui à violência moral a definição de violência física (ofensa à integridade física, art. 7º, I) — mislabeling clássico; moral é calúnia, difamação ou injúria (art. 7º, V).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O art. 25 da Lei estabelece que o Ministério Público intervirá, quando não for parte, nos processos que envolvam violência doméstica e familiar contra a mulher.

BIZU DE PROVA:
Memorize os cinco nomes exatos usados pela Lei até 2026: psicológica, sexual, física, moral e patrimonial (hoje, seis, com a vicária). E lembre: o MP tem papel ativo na Lei Maria da Penha, nunca é excluído dos processos.', 'TEC Concursos — questão 2847969 — FUNDATEC — ASoc (Pref Alpestre)/Pref Alpestre/2024'),
  (2932376, 'IGEDUC', 'GM (Pref Arcoverde)/Pref Arcoverde/2024', 2024, 'Julgue o item subsequente. A Lei Maria da Penha (Lei 11.340/2006) se aplica somente a mulheres que estejam legalmente casadas ou em união estável com o agressor.', 'GABARITO: ERRADO

POR QUE:
A Lei Maria da Penha não se limita a mulheres legalmente casadas ou em união estável. O art. 5º, III, estende a proteção a qualquer relação íntima de afeto, na qual o agressor conviva ou tenha convivido com a ofendida, independentemente de coabitação — abrangendo namoro, relacionamentos informais e até relações já encerradas.

BIZU DE PROVA:
"Relação íntima de afeto" (art. 5º, III) é o âmbito mais amplo da Lei — não exige casamento, união estável, coabitação ou relação atual.

PEGADINHA:
A palavra "somente" costuma ser a pista de que a afirmativa está restringindo indevidamente o alcance da Lei — sempre que aparecer, verifique se a Lei realmente impõe essa restrição (quase nunca impõe).', 'TEC Concursos — questão 2932376 — IGEDUC — GM (Pref Arcoverde)/Pref Arcoverde/2024'),
  (2932194, 'IGEDUC', 'GM (Pref Arcoverde)/Pref Arcoverde/2024', 2024, 'Julgue o item subsequente. De acordo com a Lei Maria da Penha, a violência doméstica e familiar contra a mulher é exclusiva das relações heterossexuais.', 'GABARITO: ERRADO

POR QUE:
O parágrafo único do art. 5º estabelece que as relações pessoais enunciadas no artigo independem de orientação sexual. A jurisprudência do STJ e do STF confirma a aplicação da Lei também a relações homoafetivas, entre mulheres ou entre homens.

BIZU DE PROVA:
"Independem de orientação sexual" (parágrafo único do art. 5º) é um dos pontos mais cobrados da parte introdutória da Lei — qualquer afirmativa que restrinja a proteção a relações heterossexuais está errada.

PEGADINHA:
A palavra "exclusiva" segue o mesmo padrão de "somente"/"apenas" — sinaliza uma restrição indevida ao alcance da Lei.', 'TEC Concursos — questão 2932194 — IGEDUC — GM (Pref Arcoverde)/Pref Arcoverde/2024'),
  (2932188, 'IGEDUC', 'GM (Pref Arcoverde)/Pref Arcoverde/2024', 2024, 'Julgue o item subsequente. Segundo a Lei Maria da Penha (Lei 11.340/2006), a violência física é a única forma de violência doméstica reconhecida legalmente contra a mulher.', 'GABARITO: ERRADO

POR QUE:
O art. 7º da Lei 11.340/2006 reconhece expressamente cinco formas de violência doméstica e familiar (física, psicológica, sexual, patrimonial e moral) e, desde a Lei 15.384/2026, uma sexta (vicária) — a violência física é apenas uma delas, não a única.

BIZU DE PROVA:
Sempre que uma afirmativa disser que apenas UMA modalidade é "reconhecida legalmente", desconfie — a Lei nomeia, no mínimo, cinco (hoje, seis).

PEGADINHA:
"A única forma" é a expressão-chave que denuncia o erro — a Lei Maria da Penha é conhecida justamente por reconhecer múltiplas formas de violência, não só a física.', 'TEC Concursos — questão 2932188 — IGEDUC — GM (Pref Arcoverde)/Pref Arcoverde/2024'),
  (2847886, 'FUNDATEC', 'Serv (CM Alpestre)/CM Alpestre/2024', 2024, 'Conforme disposto na Lei Maria da Penha, é uma forma de violência doméstica contra a mulher:', 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Violência sexual é modalidade expressamente prevista no art. 7º, III, da Lei 11.340/2006.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Violência procedimental" não é modalidade nomeada pela Lei.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Violência amiga" não é modalidade nomeada pela Lei nem expressão jurídica reconhecida.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Violência governamental" não é modalidade nomeada pela Lei.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Violência institucional" não é modalidade nomeada pela Lei Maria da Penha.

BIZU DE PROVA:
Entre nomes inventados e o único nome real oferecido (sexual), a resposta é sempre o nome real — memorizar os seis nomes oficiais (física, psicológica, sexual, patrimonial, moral, vicária) é a defesa mais segura contra esse tipo de pegadinha.', 'TEC Concursos — questão 2847886 — FUNDATEC — Serv (CM Alpestre)/CM Alpestre/2024'),
  (2924320, 'FGV', 'Psic (Pref Caraguatatuba)/Pref Caraguatatuba/30h/2024', 2024, 'Ana vive relacionamento amoroso com Camila, que é alcoolista. Ao chegar embriagada em casa, Camila proferiu palavras de baixo calão contra a companheira, humilhando-a verbalmente. Sobre essa situação, de acordo com as disposições da Lei Maria da Penha, assinale a afirmativa correta.', 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Camila proferiu palavras de baixo calão contra Ana, humilhando-a verbalmente — conduta que se enquadra no art. 7º, II (humilhação, insulto), configurando violência psicológica. A relação homoafetiva entre Ana e Camila está plenamente abrangida pela Lei, por força do parágrafo único do art. 5º e da jurisprudência consolidada do STJ/STF.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O fato de o casal ser homoafetivo não afasta a caracterização de violência contra a mulher — o parágrafo único do art. 5º garante expressamente essa aplicação.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A "mera altercação verbal" pode, sim, constituir violência doméstica — humilhação e insulto são meios expressamente listados no art. 7º, II, independentemente de agressão física.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A embriaguez voluntária (Camila estava "em estado alterado de consciência" por ter bebido) não é causa de exclusão da responsabilidade no direito penal brasileiro — o art. 28, II, do Código Penal é expresso ao dizer que a embriaguez voluntária ou culposa pelo álcool não exclui a imputabilidade penal.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A dependência do álcool, por si só, não torna a pessoa incapaz para todos os efeitos de direito — a incapacidade civil exige processo específico (interdição) com base em critérios próprios do Código Civil, não decorrendo automaticamente do alcoolismo.

BIZU DE PROVA:
Embriaguez voluntária NUNCA exclui a responsabilidade penal no Brasil (art. 28, II, CP) — só a embriaguez completamente fortuita/acidental, que retire por completo a capacidade de entendimento, pode ter efeito diferente, e mesmo assim depende de laudo específico. Não confunda "estava bêbado(a)" com "não teve culpa".', 'TEC Concursos — questão 2924320 — FGV — Psic (Pref Caraguatatuba)/Pref Caraguatatuba/30h/2024'),
  (2919563, 'MS (SARMENTO)', 'ASoc Sau (Pref Adustina)/Pref Adustina/2024', 2024, 'A Lei n.º 11.340, de 7 de agosto de 2006, (Lei Maria da Penha) traz em seu texto diversas formas de violência. Assinale a alternativa correta sobre os tipos de violência.', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Reproduz de forma completa e corretamente rotulada a definição de violência sexual do art. 7º, III — a única alternativa em que o nome da modalidade corresponde à sua definição legal real.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Rotula como "violência física" a definição completa de violência PSICOLÓGICA (dano emocional, diminuição da autoestima, degradar/controlar mediante ameaça, humilhação, isolamento etc., art. 7º, II).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Rotula como "violência psicológica" a definição de violência FÍSICA (ofender integridade ou saúde corporal, art. 7º, I) — invertendo o erro da alternativa A.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Rotula como "violência patrimonial" a definição de violência MORAL (calúnia, difamação ou injúria, art. 7º, V).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Rotula como "violência moral" a definição de violência PATRIMONIAL (retenção, subtração, destruição de objetos, bens, valores e recursos econômicos, art. 7º, IV).

BIZU DE PROVA:
Todas as cinco alternativas trazem definições REAIS da Lei, mas quatro delas com o rótulo TROCADO — e as trocas nem sempre são "vizinhas" (física↔psicológica, moral↔patrimonial). Leia a definição inteira e identifique a qual modalidade ela pertence ANTES de olhar o rótulo proposto.', 'TEC Concursos — questão 2919563 — MS (SARMENTO) — ASoc Sau (Pref Adustina)/Pref Adustina/2024'),
  (2910137, 'FGV', 'Tec NS (TJ MS)/TJ MS/Psicologia/2024', 2024, 'Inconformado com a decisão de Paula de pôr fim ao casamento, Carlos passou a fazer publicações em redes sociais acusando a ex-mulher de gastar todo o salário em bares e voltar para casa bêbada todos os dias. De acordo com o disposto na Lei nº 11.340/2006, Carlos está praticando violência:', 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Carlos publica nas redes sociais acusações contra Paula (gastar o salário em bares, voltar bêbada), buscando expor negativamente sua imagem perante terceiros após o fim do casamento — conduta que se enquadra na definição de violência moral (art. 7º, V), especificamente na modalidade de difamação (imputar fato ofensivo à reputação perante outras pessoas).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O texto é internamente inconsistente: rotula a conduta como "psicológica", mas a caracteriza como "calúnia" — calúnia é termo que define violência MORAL (art. 7º, V), não psicológica.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Violência virtual" não é modalidade nomeada pela Lei Maria da Penha — o meio pelo qual a violência ocorre (redes sociais) não altera sua classificação legal como uma das modalidades do art. 7º.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Carlos não está retendo, subtraindo ou destruindo bens/valores de Paula — está fazendo uma acusação pública sobre o uso que ela faz do próprio salário, o que configura ataque à reputação (moral), não controle patrimonial efetivo.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Violência de gênero" é o conceito sociológico mais amplo que fundamenta toda a Lei, não uma das modalidades específicas do art. 7º; e a conduta de Carlos não é primariamente uma violação de privacidade, mas sim uma exposição pública com conteúdo ofensivo à reputação de Paula.

BIZU DE PROVA:
Publicar em redes sociais acusações que expõem negativamente a reputação da ex-companheira/ex-cônjuge perante terceiros = moral, na forma de difamação (art. 7º, V) — o meio (redes sociais) não muda a modalidade legal, apenas o contexto fático.', 'TEC Concursos — questão 2910137 — FGV — Tec NS (TJ MS)/TJ MS/Psicologia/2024'),
  (2904890, 'VUNESP', 'ASoc (Pref Santo André)/Pref Santo André/2024', 2024, 'A Lei nº 11.340/2006, conhecida por Lei Maria da Penha, cria mecanismos para coibir a violência doméstica e familiar contra a mulher constituindo-se em importante marco normativo. Um dos tipos de violência mais comuns contra a mulher e que nem sempre é reconhecido como tal trata daquela entendida como qualquer conduta que configure calúnia, difamação ou injúria. Essa violência é denominada de', 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
"Qualquer conduta que configure calúnia, difamação ou injúria" é a definição literal de violência moral dada pelo art. 7º, V.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Violência sexual (art. 7º, III) tem definição própria, sem relação com calúnia/difamação/injúria.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Violência patrimonial (art. 7º, IV) trata de bens e valores — não é calúnia/difamação/injúria.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Violência familiar" não é modalidade nomeada pela Lei — "família" é um dos âmbitos de incidência (art. 5º, II), não uma modalidade do art. 7º.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Violência psicológica (art. 7º, II) tem definição própria (dano emocional, diminuição de autoestima etc.) — não é calúnia/difamação/injúria.

BIZU DE PROVA:
Calúnia/difamação/injúria = moral, sempre. Cuidado para não confundir "família" (âmbito, art. 5º) com uma modalidade de violência (art. 7º) — são conceitos de artigos diferentes.', 'TEC Concursos — questão 2904890 — VUNESP — ASoc (Pref Santo André)/Pref Santo André/2024'),
  (2898378, 'Instituto ACCESS', 'GM (Cariacica)/Pref Cariacica/2024', 2024, 'De acordo com a legislação pertinente, no contexto da violência doméstica, está incluído o listado nas alternativas a seguir, à exceção de uma. Assinale-a.', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA (é a exceção pedida pelo enunciado):
Um prestador de serviço que vai à residência executar um serviço específico e pontual não integra o "espaço de convívio permanente de pessoas" do art. 5º, I — não há vínculo pessoal, familiar ou afetivo entre ele e os moradores, apenas uma relação comercial/profissional eventual, alheia aos três âmbitos de incidência da Lei (unidade doméstica, família, relação íntima de afeto).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (está de fato incluída, portanto não é a exceção pedida):
Um hóspede, mesmo por curto período, se enquadra no conceito de "esporadicamente agregadas" do art. 5º, I — a Lei inclui expressamente essas pessoas no âmbito da unidade doméstica.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA (está de fato incluída, portanto não é a exceção pedida):
Um irmão que não mais reside na casa continua sendo parente por laços naturais — o âmbito da família (art. 5º, II) não exige coabitação, apenas o vínculo de parentesco.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA (está de fato incluída, portanto não é a exceção pedida):
Um ex-companheiro que não mais reside na casa se enquadra no âmbito da relação íntima de afeto (art. 5º, III), que alcança expressamente quem "tenha convivido" com a ofendida, independentemente de coabitação atual.

BIZU DE PROVA:
O critério que distingue a exceção das demais opções é o VÍNCULO PESSOAL: hóspede, irmão e ex-companheiro têm algum tipo de vínculo social, familiar ou afetivo com a vítima (mesmo que não morem mais juntos); o prestador de serviço tem apenas um vínculo comercial pontual, sem qualquer relação pessoal — por isso fica de fora dos três âmbitos do art. 5º.', 'TEC Concursos — questão 2898378 — Instituto ACCESS — GM (Cariacica)/Pref Cariacica/2024'),
  (2842551, 'IVIN', 'GM (Pref Curuçá)/Pref Curuçá/2024', 2024, 'De acordo com a Lei nº 11.340/2006, assinale a alternativa que indica correta e respectivamente a quais formas de violência doméstica e familiar cada item abaixo se refere: I. A conduta de um marido que insulta publicamente a esposa evangélica, em razão de sua religião, visando causar-lhe humilhação e ridicularização. II. A conduta do companheiro que difama a esposa nas mesas de bares. III. A conduta do namorado que, convivendo com a mulher, a impede de usar métodos contraceptivos. IV. A conduta do marido que retém o cartão de movimentação bancária da esposa.', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
I. Insultar publicamente a esposa, visando causar-lhe humilhação e ridicularização, é violência psicológica (art. 7º, II — insulto, humilhação, ridicularização são meios expressamente listados). II. Difamar a esposa nas mesas de bares é violência moral (art. 7º, V — difamação, imputação de fato ofensivo à reputação perante terceiros). III. Impedir o uso de métodos contraceptivos é violência sexual (art. 7º, III). IV. Reter o cartão de movimentação bancária é violência patrimonial (art. 7º, IV).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Violência religiosa" não é modalidade nomeada pela Lei — o item I, embora motivado pela religião da vítima, configura violência psicológica pela NATUREZA da conduta (insulto/humilhação), não pelo MOTIVO que a inspirou.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Inverte os itens I e II (psicológica e moral trocadas) e erra o item III, atribuindo-lhe violência física em vez de sexual.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Erra o item I (deveria ser psicológica, não física) e repete "física" também no item III, quando deveria ser sexual.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Repete "psicológica" nos itens I e II (o item II deveria ser moral) e erra o item IV, atribuindo-lhe violência moral em vez de patrimonial.

BIZU DE PROVA:
Insultar/humilhar DIRETAMENTE a vítima = psicológica (mesmo que "publicamente" e mesmo que motivado por preconceito religioso — o motivo não muda a modalidade). Espalhar informação difamatória PARA TERCEIROS (nas mesas de bares, por exemplo) = moral. Essa distinção entre "insulto direto" e "difamação para terceiros" é a chave de várias questões deste tipo.', 'TEC Concursos — questão 2842551 — IVIN — GM (Pref Curuçá)/Pref Curuçá/2024'),
  (2859577, 'IGEDUC', 'GM (Pref B Jardim)/Pref Belo Jardim/2024', 2024, 'A Lei Maria da Penha estabelece que a violência doméstica e familiar contra a mulher não se limita ao ambiente físico, reconhecendo como violência qualquer ação ou omissão baseada no gênero que cause sofrimento psicológico, lesão, morte, dano moral ou patrimonial à mulher, seja no âmbito da unidade doméstica, da família ou em qualquer relação íntima de afeto.', 'GABARITO: CERTO

POR QUE:
A afirmativa combina corretamente as consequências do art. 5º, caput (sofrimento psicológico, lesão, morte, dano moral ou patrimonial) com os três âmbitos de incidência dos incisos I a III (unidade doméstica, família, relação íntima de afeto), e ainda reforça corretamente que a violência doméstica "não se limita ao ambiente físico" — reconhecendo, portanto, outras formas de violência além da física.

BIZU DE PROVA:
Esta é uma das raras questões que reúne, de forma completa e correta, TODOS os elementos centrais do art. 5º em uma única frase — útil para revisar a estrutura inteira do artigo de uma vez.

PEGADINHA:
Não há pegadinha aqui — é uma afirmativa completa e tecnicamente correta, mas fique atento: questões parecidas costumam inserir pequenas restrições indevidas (como exigir coabitação ou vínculo de casamento) que não aparecem neste item.', 'TEC Concursos — questão 2859577 — IGEDUC — GM (Pref B Jardim)/Pref Belo Jardim/2024'),
  (2859690, 'IGEDUC', 'GM (Pref Garanhuns)/Pref Garanhuns/2024', 2024, 'Para os efeitos da Lei Maria da Penha, considera-se violência doméstica e familiar contra a mulher qualquer ação ou omissão que cause morte, lesão, sofrimento físico, sexual ou psicológico e dano moral ou patrimonial.', 'GABARITO: CERTO

POR QUE:
A afirmativa reproduz, de forma resumida, o núcleo do art. 5º, caput: considera-se violência doméstica e familiar contra a mulher qualquer ação ou omissão que cause morte, lesão, sofrimento físico, sexual ou psicológico e dano moral ou patrimonial. Embora a frase omita a exigência de que a conduta seja "baseada no gênero" e a ocorrência dentro de um dos três âmbitos do art. 5º (incisos I a III), essa omissão não introduz nenhuma afirmação falsa — o item não nega o critério de gênero nem afirma que a Lei se aplica independentemente dele; apenas não o menciona. Por isso, o item é considerado tecnicamente correto, ainda que incompleto.

BIZU DE PROVA:
Em itens Certo/Errado, uma afirmação INCOMPLETA (que omite elementos, sem afirmar nada de errado em seu lugar) geralmente continua sendo classificada como Certa — reserve o "Errado" para quando a banca afirmar algo que contraria a Lei. Mas fique atento: se uma questão FUTURA testar exatamente o elemento omitido aqui (a exigência de que a conduta seja "baseada no gênero", ou a necessidade de ocorrer em um dos três âmbitos do art. 5º), a resposta pode mudar — vale memorizar que esses dois elementos também são parte da definição completa.

PEGADINHA:
Esta afirmativa é uma paráfrase incompleta do art. 5º, caput — omite "baseada no gênero" e a exigência do âmbito (unidade doméstica, família ou relação íntima de afeto). Não confunda "incompleto" com "errado": por não afirmar nada de falso, o item permanece Certo, mas fique atento a variações da mesma questão que insiram uma restrição INDEVIDA nesses pontos — aí sim passaria a Errado.', 'TEC Concursos — questão 2859690 — IGEDUC — GM (Pref Garanhuns)/Pref Garanhuns/2024'),
  (2861901, 'RBO', 'GC (Pref Cotia)/Pref Cotia/2024', 2024, 'A violência doméstica e familiar contra a mulher, entendida como qualquer conduta que configure calúnia, difamação ou injúria denomina-se:', 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Calúnia, difamação ou injúria é a definição literal de violência moral, dada pelo art. 7º, V, da Lei 11.340/2006.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Violência psicológica (art. 7º, II) tem definição própria, centrada em dano emocional/diminuição de autoestima — não é calúnia/difamação/injúria.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Violência física (art. 7º, I) trata de ofensa à integridade ou saúde corporal — não é calúnia/difamação/injúria.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Violência emocional" não é modalidade nomeada pela Lei — o efeito "dano emocional" integra a definição de violência psicológica, mas o nome da modalidade é "psicológica".

BIZU DE PROVA:
Calúnia/difamação/injúria = moral, sempre. "Emocional" nunca é o nome de uma modalidade — é apenas um dos EFEITOS mencionados na definição de psicológica.', 'TEC Concursos — questão 2861901 — RBO — GC (Pref Cotia)/Pref Cotia/2024'),
  (2890074, 'FUNCERN', 'GCM (Pref Parnamirim)/Pref Parnamirim (RN)/2024', 2024, 'De acordo com a Lei Maria da Penha, Lei Federal No 11.340/2006, configura-se violência doméstica e familiar contra a mulher qualquer ação ou omissão baseada no gênero que lhe cause morte, lesão, sofrimento físico, sexual ou psicológico e dano moral ou patrimonial,', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Reproduz literalmente o art. 5º, I — no âmbito da unidade doméstica, compreendida como o espaço de convívio permanente de pessoas, com ou sem vínculo familiar, inclusive as esporadicamente agregadas.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Descreve uma situação "sem qualquer relação de afeto" ao mesmo tempo em que menciona convivência entre agressor e ofendida — descrição incoerente que não corresponde a nenhum dos três âmbitos do art. 5º, que exigem justamente algum vínculo (doméstico, familiar ou afetivo).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Âmbito externo familiar" e "comunidade de vizinhos unidos por laços geográficos" não correspondem a nenhum dos três âmbitos do art. 5º — mera proximidade geográfica entre vizinhos não gera, por si só, a incidência da Lei.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Ambiente de trabalho" não é um dos três âmbitos do art. 5º — relações de trabalho sem vínculo familiar ou afetivo entre as partes não se enquadram na Lei Maria da Penha (podem configurar outras figuras, como assédio moral/sexual no trabalho, tratadas por normas distintas).

BIZU DE PROVA:
Os três âmbitos do art. 5º são só estes: unidade doméstica, família e relação íntima de afeto. "Vizinhança" e "ambiente de trabalho", isoladamente, nunca configuram, por si só, nenhum dos três.', 'TEC Concursos — questão 2890074 — FUNCERN — GCM (Pref Parnamirim)/Pref Parnamirim (RN)/2024'),
  (2862259, 'FUNDATEC', 'Ag (Pref Paulo Bento)/Pref Paulo Bento/Administrativo/Sem Especialidade/2024', 2024, 'Nos termos da Lei Maria da Penha (Lei nº 11.340/2006), a violência contra a mulher constitui uma das formas de violação dos direitos:', 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O art. 6º da Lei 11.340/2006 estabelece que a violência contra a mulher constitui uma das formas de violação dos direitos humanos.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Direitos políticos" não é a expressão usada pelo art. 6º.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Direitos penais" não é a expressão usada pelo art. 6º nem categoria jurídica correspondente.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Direitos trabalhistas" não é a expressão usada pelo art. 6º.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Direitos econômicos" não é a expressão usada pelo art. 6º.

BIZU DE PROVA:
Art. 6º: "constitui uma das formas de violação dos direitos humanos" — frase literal, curta e muito cobrada isoladamente.', 'TEC Concursos — questão 2862259 — FUNDATEC — Ag (Pref Paulo Bento)/Pref Paulo Bento/Administrativo/Sem Especialidade/2024'),
  (2840121, 'FUNDATEC', 'Ag (Pref Jari)/Pref Jari/Combate às Endemias/2024', 2024, 'Conforme a Lei Maria da Penha, Lei nº 11.340/2006, relacione a Coluna 1 à Coluna 2, associando os conceitos apresentados às suas definições. Coluna 1 1. Unidade doméstica. 2. Família. 3. Relação íntima de afeto. Coluna 2 ( ) Comunidade formada por indivíduos que são ou se consideram aparentados, unidos por laços naturais, por afinidade ou por vontade expressa. ( ) Qualquer convivência entre vítima e agressor, independentemente de coabitação. ( ) Espaço de convívio permanente de pessoas, com ou sem vínculo familiar, inclusive as esporadicamente agregadas. A ordem correta de preenchimento dos parênteses, de cima para baixo, é:', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
A sequência correta é 2-3-1: família (2) corresponde a "comunidade formada por indivíduos que são ou se consideram aparentados, unidos por laços naturais, por afinidade ou por vontade expressa" (art. 5º, II); relação íntima de afeto (3) corresponde a "qualquer convivência entre vítima e agressor, independentemente de coabitação" (a expressão "independentemente de coabitação" é a marca distintiva do art. 5º, III); unidade doméstica (1) corresponde a "espaço de convívio permanente de pessoas, com ou sem vínculo familiar, inclusive as esporadicamente agregadas" (art. 5º, I).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A sequência "1-2-3" atribui unidade doméstica à definição de família e família à definição de relação íntima de afeto — nenhuma das duas associações está correta.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A sequência "1-3-2" acerta a segunda posição (relação íntima de afeto), mas erra a primeira e a terceira.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A sequência "2-1-3" acerta a primeira posição (família), mas troca unidade doméstica e relação íntima de afeto nas posições seguintes.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A sequência "3-2-1" inverte completamente família e relação íntima de afeto nas duas primeiras posições.

BIZU DE PROVA:
"Independentemente de coabitação" é a expressão-chave exclusiva da relação íntima de afeto (art. 5º, III) — sempre que aparecer, associe a essa modalidade, mesmo que a palavra "afeto" não seja repetida na paráfrase.', 'TEC Concursos — questão 2840121 — FUNDATEC — Ag (Pref Jari)/Pref Jari/Combate às Endemias/2024'),
  (2877475, 'FGV', 'AJ (TJ AP)/TJ AP/Apoio Especializado/Psicólogo/2024', 2024, 'A violência doméstica contra a mulher pode se manifestar de diferentes formas. Inconformada porque Clarice não aceitou suas propostas de reconciliação conjugal, Juliana passou a persegui-la em seu local de trabalho e a atacá-la em suas redes sociais, acusando-a falsamente de fazer programas sexuais por dinheiro. Considerando o disposto na Lei Maria da Penha, no caso narrado, é correto afirmar que:', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Juliana pratica violência psicológica ao perseguir Clarice no local de trabalho (perseguição contumaz, art. 7º, II) e violência moral ao acusá-la falsamente, nas redes sociais, de fazer programas sexuais por dinheiro (imputação de fato ofensivo à reputação perante terceiros, configurando difamação/injúria, art. 7º, V) — as duas modalidades estão claramente presentes e identificáveis no relato.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
As relações homoafetivas são, sim, objeto da Lei Maria da Penha, por força do parágrafo único do art. 5º e da jurisprudência consolidada do STJ e do STF.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O art. 5º, III, alcança quem "tenha convivido" com a ofendida — o fim do relacionamento não afasta a Lei.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Acerta ao identificar a perseguição (stalking) como presente, mas erra ao classificar a acusação falsa como "violência sexual" — a conduta de acusar falsamente alguém de exercer atividade sexual mediante pagamento é ataque à reputação perante terceiros (violência moral, art. 7º, V), não uma das condutas específicas do art. 7º, III (que trata de constranger a ato sexual, impedir contracepção, forçar matrimônio/gravidez/aborto/prostituição, ou limitar direitos sexuais e reprodutivos).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O art. 17 veda expressamente a aplicação de pena de cesta básica ou outra prestação pecuniária isolada nos casos de violência doméstica e familiar contra a mulher.

BIZU DE PROVA:
Perseguir a vítima pessoalmente (local de trabalho, redes sociais, ligações) = psicológica ("perseguição contumaz", art. 7º, II). Fazer acusação falsa/ofensiva sobre a vida da vítima para expô-la perante terceiros = moral (difamação/injúria, art. 7º, V) — mesmo quando a acusação tem conteúdo sexual, a classificação legal correta é moral, não sexual, pois o que a Lei chama de "violência sexual" (art. 7º, III) trata de coagir a própria vítima a atos/decisões sexuais, não de fazer afirmações sobre sua vida sexual para terceiros.', 'TEC Concursos — questão 2877475 — FGV — AJ (TJ AP)/TJ AP/Apoio Especializado/Psicólogo/2024'),
  (2718877, 'IBAM', 'CSoc (Pref Guarujá (SP))/Pref Guarujá (SP)/2023', 2023, 'Para os efeitos da Lei Maria da Penha, configura violência doméstica e familiar contra a mulher qualquer ação ou omissão baseada no gênero que lhe cause morte, lesão, sofrimento físico, sexual ou psicológico e dano moral ou patrimonial: I. no âmbito da unidade doméstica, compreendida como o espaço de convívio permanente de pessoas, com ou sem vinculo familiar, inclusive as esporadicamente agregadas; II. no âmbito da família, compreendida como a comunidade formada por indivíduos que são ou se consideram aparentados, unidos por laços naturais, por afinidade ou por vontade expressa; III. em qualquer relação intima de afeto, na qual o agressor conviva ou tenha convivido com a ofendida, independentemente de coabitação. Estão corretas:', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Os itens I, II e III reproduzem literalmente os três âmbitos do art. 5º: I corresponde ao inciso I (unidade doméstica), II corresponde ao inciso II (família), III corresponde ao inciso III (relação íntima de afeto) — todos os três estão corretos.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Exclui indevidamente o item I, que reproduz corretamente o art. 5º, I.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Exclui indevidamente o item III, que reproduz corretamente o art. 5º, III.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Exclui indevidamente o item II, que reproduz corretamente o art. 5º, II.

BIZU DE PROVA:
Quando uma questão apresentar os três âmbitos do art. 5º como itens separados, sem nenhuma alteração ao texto legal, o gabarito normalmente confirma todos os três como corretos — os três incisos são alternativos entre si (qualquer um configura violência doméstica), não é preciso que ocorram simultaneamente.', 'TEC Concursos — questão 2718877 — IBAM — CSoc (Pref Guarujá (SP))/Pref Guarujá (SP)/2023'),
  (3622849, 'URI', 'ASoc (Pref Entre-Ijuís)/Pref Entre-Ijuís/2023', 2023, 'Conforme a Lei Nº 11.340 de 07 de agosto de 2006, Lei MARIA DA PENHA, configura violência doméstica e familiar contra a mulher qualquer ação ou omissão baseada no gênero que lhe cause morte, lesão, sofrimento físico, sexual ou psicológico e dano moral ou patrimonial, podendo ocorrer nas seguintes situações: I. No âmbito da ............................, compreendida como o espaço de convívio permanente de pessoas, com ou sem vínculo familiar, inclusive as esporadicamente agregadas. II. No âmbito da ............................., compreendida como a comunidade formada por indivíduos que são ou se consideram aparentados, unidos por laços naturais, por afinidade ou por vontade expressa. Assinale a alternativa que preenche, correta e respectivamente, as lacunas dos itens referidos.', 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A primeira lacuna ("espaço de convívio permanente de pessoas, com ou sem vínculo familiar, inclusive as esporadicamente agregadas") corresponde à unidade doméstica (art. 5º, I). A segunda lacuna ("comunidade formada por indivíduos que são ou se consideram aparentados, unidos por laços naturais, por afinidade ou por vontade expressa") corresponde à família (art. 5º, II).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Inverte a ordem, atribuindo "família" à primeira lacuna (que é unidade doméstica) e "íntima relação" à segunda (que é família).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Atribui "íntima relação" à primeira lacuna e "unidade doméstica" à segunda — nenhuma das duas corresponde às definições apresentadas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Inverte a ordem correta, atribuindo "família" à primeira lacuna e "unidade doméstica" à segunda.

BIZU DE PROVA:
"Convívio permanente, com ou sem vínculo familiar" = unidade doméstica. "Comunidade de aparentados por laços naturais/afinidade/vontade expressa" = família. Essas duas definições costumam ser trocadas entre si — leia com atenção qual delas exige parentesco (família) e qual não exige (unidade doméstica).', 'TEC Concursos — questão 3622849 — URI — ASoc (Pref Entre-Ijuís)/Pref Entre-Ijuís/2023'),
  (3603257, 'SELECON', 'ASoc (Pref Nova Mutum)/Pref Nova Mutum/2023', 2023, 'Fernanda tem um companheiro muito apaixonado e muito ciumento, o Alan, que afirma ter medo de perdê-la. Assim, sempre que o casal se encontra com amigos, durante a conversa, Alan faz comentários de como a sua amada é tola, frágil, sem discernimento e de como precisa dele a todo momento por perto. Agindo assim, Alan intenta minimizar quaisquer interesses de outrem por sua companheira. Nessas circunstâncias, Fernanda se sente constrangida e humilhada, já sem desejo de se encontrar com outras pessoas, para não ter que passar por essa situação. De acordo com a Lei Maria da Penha, Lei nº 11.340/2006, essa conjuntura descrita configura:', 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Alan diminui Fernanda perante os amigos ("tola, frágil, sem discernimento"), buscando reduzir seu valor social e desencorajar o interesse de terceiros nela — conduta que a constrange e humilha, levando-a a se isolar do convívio social. Isso se enquadra na definição de violência psicológica do art. 7º, II: dano emocional e diminuição da autoestima, mediante constrangimento e humilhação, que resulta em isolamento.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Os comentários de Alan são caracterizações depreciativas ditas na presença de amigos com o objetivo de controlar/diminuir Fernanda, não uma acusação falsa ou ofensiva à sua reputação especificamente destinada a expô-la perante terceiros (o que configuraria calúnia, difamação ou injúria — moral, art. 7º, V). O núcleo da conduta é o controle e a diminuição da autoestima de Fernanda, típicos da violência psicológica.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não há relato de conduta sexual.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Comportamento inadequado" não é categoria da Lei Maria da Penha — a conduta narrada se enquadra especificamente como violência psicológica, com todas as consequências jurídicas e protetivas previstas na Lei.

BIZU DE PROVA:
Diminuir a autoestima e a autoconfiança da vítima diante de outras pessoas, com o objetivo de mantê-la isolada e dependente, é psicológica (art. 7º, II) — mesmo quando dito "com carinho" ou disfarçado de preocupação/ciúme, como no caso de Alan.', 'TEC Concursos — questão 3603257 — SELECON — ASoc (Pref Nova Mutum)/Pref Nova Mutum/2023'),
  (3534524, 'FUNDATEC', 'ASoc (IPASEM CB)/IPASEM CB/2023', 2023, 'A Lei Maria da Penha prevê mecanismos para coibir a violência doméstica e familiar contra a mulher. Nos termos do que estabelece a referida legislação, assinale a alternativa correta.', 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O confisco de documentos pessoais da ofendida pelo agressor é conduta expressamente prevista no art. 7º, IV, como violência patrimonial.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O art. 5º, I, admite expressamente a configuração de violência doméstica "com ou sem vínculo familiar" — não é necessário vínculo familiar ou amoroso para a aplicação da Lei, bastando um dos três âmbitos do art. 5º (que incluem, por exemplo, a unidade doméstica mesmo sem parentesco).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Dano emocional e diminuição de autoestima" é a definição de violência PSICOLÓGICA (art. 7º, II), não moral.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Calúnia, injúria ou difamação" é a definição de violência MORAL (art. 7º, V), não psicológica.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A Lei Maria da Penha se aplica, sim, a relações homoafetivas entre mulheres, por força do parágrafo único do art. 5º e da jurisprudência consolidada do STJ e do STF.

BIZU DE PROVA:
"Confisco/retenção de documentos pessoais" é termo literal do art. 7º, IV — sempre patrimonial, independentemente do valor financeiro do documento retido em si.', 'TEC Concursos — questão 3534524 — FUNDATEC — ASoc (IPASEM CB)/IPASEM CB/2023'),
  (3260966, 'COSEAC UFF', 'Ed Soc (FEMAR)/FEMAR/2023', 2023, 'Considere os seguintes itens sobre a violência doméstica e familiar contra a mulher: I violência física. II violência psicológica. III violência sexual IV violência patrimonial. V violência virtual. Estão listados no art. 7º do Capítulo II da Lei Maria da Penha os seguintes', 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Estão listados no art. 7º da Lei 11.340/2006 os itens I (física), II (psicológica), III (sexual) e IV (patrimonial) — todas modalidades expressamente nomeadas pelos incisos I a IV. O item V ("violência virtual") não é modalidade nomeada pelo art. 7º.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Inclui o item V (violência virtual), que não é modalidade nomeada pela Lei — o meio virtual pode ser instrumento de diversas modalidades já existentes (psicológica, moral etc.), mas não constitui, por si só, uma modalidade autônoma no art. 7º.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Exclui indevidamente o item III (violência sexual), que é modalidade expressamente prevista no art. 7º, III, e inclui o item V, que não é.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Exclui os itens II e IV (psicológica e patrimonial), ambas modalidades expressamente previstas.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Exclui os itens III e IV (sexual e patrimonial), ambas modalidades expressamente previstas, e inclui o item V, que não é.

BIZU DE PROVA:
"Violência virtual" não é um dos nomes oficiais das modalidades do art. 7º — o ambiente digital é apenas o MEIO pelo qual outras modalidades (psicológica, moral, e, se envolver conteúdo íntimo não consentido, também aspectos ligados à violação de intimidade) podem se manifestar.', 'TEC Concursos — questão 3260966 — COSEAC UFF — Ed Soc (FEMAR)/FEMAR/2023'),
  (3169677, 'OBJETIVA CONCURSOS', 'Enf (Pref Roque Gonzales)/Pref Roque Gonzales/2023', 2023, 'Em conformidade com a Lei nº 11.340/2006 — Lei Maria da Penha, caracteriza-se como violência psicológica contra a mulher qualquer conduta que:', 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
"Cause dano emocional e diminuição da autoestima" é o início da definição literal de violência psicológica dada pelo art. 7º, II.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Limite ou anule o exercício de seus direitos sexuais e reprodutivos" integra a definição de violência SEXUAL (art. 7º, III), não psicológica.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Configure calúnia, difamação ou injúria" é a definição de violência MORAL (art. 7º, V), não psicológica.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Ofenda sua integridade ou saúde corporal" é a definição de violência FÍSICA (art. 7º, I), não psicológica.

BIZU DE PROVA:
Cada alternativa desta questão é um trecho REAL de uma definição diferente da Lei — a habilidade testada é reconhecer a qual modalidade cada trecho pertence e escolher apenas o que corresponde à psicológica.', 'TEC Concursos — questão 3169677 — OBJETIVA CONCURSOS — Enf (Pref Roque Gonzales)/Pref Roque Gonzales/2023'),
  (3093006, 'Instituto AOCP', '2º Ten Adm (PM DF)/PM DF/2023', 2023, 'De acordo com a Lei Federal nº 11.340/2006 (Lei Maria da Penha), é forma de violência doméstica e familiar contra a mulher', 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Reproduz de forma completa e corretamente rotulada a definição de violência sexual do art. 7º, III — a única alternativa em que o rótulo corresponde à definição legal real.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Rotula como "violência física" a definição de violência PATRIMONIAL (retenção, subtração, destruição de objetos, bens, valores e recursos econômicos, art. 7º, IV).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Rotula como "violência psicológica" a definição de violência MORAL (calúnia, difamação ou injúria, art. 7º, V).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Rotula como "violência patrimonial" um trecho truncado da definição de violência PSICOLÓGICA ("qualquer conduta que lhe cause dano emocional", art. 7º, II).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Rotula como "violência moral" a definição de violência FÍSICA (ofender integridade ou saúde corporal, art. 7º, I).

BIZU DE PROVA:
Nenhuma das cinco alternativas desta questão usa o rótulo "sexual" incorretamente — a sexual é a única cuja definição completa está corretamente identificada; as outras quatro trocam rótulos entre si sistematicamente.', 'TEC Concursos — questão 3093006 — Instituto AOCP — 2º Ten Adm (PM DF)/PM DF/2023'),
  (3062789, 'FURB', 'Edu (Pref Blumenau)/Pref Blumenau/Social/Atuação em Transporte Escolar/2023', 2023, 'Analise as condutas a seguir e indique qual delas está de acordo com a Lei Maria da Penha:', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O art. 7º, III, define violência sexual como, entre outras condutas, a que force a mulher "ao matrimônio, à gravidez, AO ABORTO ou à prostituição, mediante coação, chantagem, suborno ou manipulação" — forçar uma mulher ao aborto se enquadra literalmente nesse dispositivo.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Ofensas verbais de cunho sexual em público podem, sim, configurar violência doméstica — dependendo do conteúdo, podem se enquadrar como violência psicológica (humilhação, constrangimento, art. 7º, II) ou moral (calúnia, difamação, injúria, art. 7º, V); a Lei não as exclui.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A ausência de suporte emocional, por si só, é vaga demais para configurar automaticamente uma das modalidades específicas do art. 7º, mas isso não significa que a Lei "não reconheça" formas de violência por omissão — o art. 5º, caput, admite expressamente que a violência doméstica se configure por ação OU omissão.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O art. 7º, III, trata especificamente de FORÇAR a mulher ao aborto (contra sua vontade de manter a gravidez) e de impedir o uso de métodos contraceptivos — não trata de impedir a realização de um aborto já desejado pela mulher, que é regulado por outras normas (Código Penal, arts. 124 a 128, sobre as hipóteses em que o aborto é ou não punível no Brasil).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O art. 7º, III, é expresso ao incluir, entre as condutas de violência sexual, impedir a mulher de usar qualquer método contraceptivo — omitir deliberadamente informações sobre métodos contraceptivos, como forma de limitar sua autonomia reprodutiva, também se relaciona a essa mesma proteção (direitos sexuais e reprodutivos), de modo que a Lei não deixa esse tipo de conduta fora de sua proteção.

BIZU DE PROVA:
"Forçar ao matrimônio, à gravidez, ao aborto ou à prostituição" é trecho literal do art. 7º, III — sempre que a conduta narrada for FORÇAR (contra a vontade da mulher) uma dessas quatro situações, a classificação é violência sexual.', 'TEC Concursos — questão 3062789 — FURB — Edu (Pref Blumenau)/Pref Blumenau/Social/Atuação em Transporte Escolar/2023'),
  (3057596, 'Fundação La Salle', 'MVet (Pref Serafina Corrêa)/Pref Serafina Corrêa/20h/2023', 2023, 'Janice está sofrendo escola d violência doméstica. Ela trabalha em uma escola da rede municipal e foi conversar com um advogado e, na oportunidade, comentou com ele que o companheiro retinha o seu salário para pagar as despesas mensais em um bar próximo a sua residência no qual ingeria bebida alcóolica diariamente. Essa é uma forma de violência perpetrada contra a mulher que, se segundo a Lei Maria da Penha, consiste em violência:', 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
O companheiro de Janice retinha o salário dela para pagar as próprias despesas com bebida alcoólica — conduta que se enquadra na definição de violência patrimonial (art. 7º, IV: retenção de valores/recursos econômicos destinados a satisfazer as necessidades da ofendida).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Não há relato de dano emocional específico, degradação ou controle de comportamento além da retenção do salário — a conduta central e objetivamente descrita é a apropriação do dinheiro de Janice, que a Lei classifica especificamente como patrimonial.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não há relato de calúnia, difamação ou injúria.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não há relato de conduta sexual.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não há relato de agressão à integridade física de Janice.

BIZU DE PROVA:
Reter o salário/dinheiro da vítima para gastar com as próprias despesas (inclusive vícios, como no caso do bar) é violência patrimonial, mesmo que o relato também sugira sofrimento — a Lei classifica pela NATUREZA objetiva da conduta (apropriação de recursos econômicos), não apenas pelo sofrimento emocional que ela também pode causar.', 'TEC Concursos — questão 3057596 — Fundação La Salle — MVet (Pref Serafina Corrêa)/Pref Serafina Corrêa/20h/2023'),
  (3000783, 'Instituto Consulplan', 'GCM (Pref Astolfo Dutra)/Pref Astolfo Dutra/Feminino/2023', 2023, 'A Lei Maria da Penha – Lei nº 11.340/2006, criou mecanismos para coibir a violência doméstica e familiar contra a mulher. A normativa, em seu Art. 7º, indica, dentre outras, formas de violência doméstica e familiar contra a mulher. Configura, nos termos da Lei, violência psicológica contra a mulher:', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Reproduz de forma completa e literal a definição de violência psicológica do art. 7º, II — dano emocional e diminuição da autoestima, prejuízo ao pleno desenvolvimento, degradar ou controlar ações/comportamentos/crenças/decisões, mediante ameaça, constrangimento, humilhação, manipulação, isolamento, vigilância constante, perseguição contumaz, insulto, chantagem, violação de intimidade, ridicularização, exploração e limitação do direito de ir e vir.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Mistura o início da definição de violência MORAL ("calúnia, difamação, injúria") com o final da definição de psicológica ("qualquer outro meio que lhe cause prejuízo à saúde psicológica e à autodeterminação") — composição incorreta, que não corresponde à definição real de nenhuma das duas modalidades.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Mistura o início da definição de violência FÍSICA ("ofenda sua integridade, saúde corporal") com o final da definição de psicológica — mesma composição incorreta.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Mistura o início da definição de violência PATRIMONIAL ("retenção, subtração, destruição... objetos... bens... recursos econômicos") com o final da definição de psicológica — mesma composição incorreta.

BIZU DE PROVA:
Três das quatro alternativas desta questão criam "definições Frankenstein", colando o início de uma modalidade com o final de outra — só a definição INTEIRA e genuína de psicológica (alternativa D) está correta. Desconfie de opções que pareçam "certas demais" no início, mas continuem com um trecho de outra modalidade.', 'TEC Concursos — questão 3000783 — Instituto Consulplan — GCM (Pref Astolfo Dutra)/Pref Astolfo Dutra/Feminino/2023'),
  (2976888, 'EPL Concursos', 'ASoc (Pref Sta Rita (PB))/Pref Sta Rita (PB)/2023', 2023, 'De acordo com a Lei Maria da Penha (Lei nº 11.340/2006), qual das alternativas abaixo NÃO é uma das formas de violência doméstica e familiar contra a mulher?', 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA (é a que NÃO é forma de violência prevista, pedida pelo enunciado):
"Violência racial" não é modalidade nomeada pelo art. 7º da Lei 11.340/2006 — questões de discriminação racial são tratadas por legislação específica (Lei 7.716/1989 e o crime de injúria racial do Código Penal), não pela Lei Maria da Penha.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA (é uma forma prevista, portanto não é a exceção pedida):
Violência psicológica é modalidade expressamente prevista no art. 7º, II.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA (é uma forma prevista, portanto não é a exceção pedida):
Violência patrimonial é modalidade expressamente prevista no art. 7º, IV.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA (é uma forma prevista, portanto não é a exceção pedida):
Violência física é modalidade expressamente prevista no art. 7º, I.

BIZU DE PROVA:
Embora a interseção entre raça e gênero seja uma dimensão social real e relevante da violência contra a mulher, a Lei Maria da Penha não nomeia "violência racial" como uma de suas modalidades específicas no art. 7º — não confunda a relevância social de um tema com a classificação técnica-legal pedida pela questão.', 'TEC Concursos — questão 2976888 — EPL Concursos — ASoc (Pref Sta Rita (PB))/Pref Sta Rita (PB)/2023'),
  (2925122, 'IBFC', 'ASoc (EBSERH)/HU Brasil/2023', 2023, 'A Lei de nº 11.340/2006 nos apresenta, no artigo 7º. quais seriam as formas de violência cometidas contra a mulher. E dentre elas, podemos citar a violência física e que deve ser compreendida:', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
"Qualquer conduta que ofenda sua integridade ou saúde corporal" é a definição literal de violência física dada pelo art. 7º, I.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Reproduz boa parte dos MEIOS listados na definição de violência PSICOLÓGICA (constrangimento, humilhação, manipulação, isolamento, vigilância constante, perseguição contumaz, insulto, chantagem, violação de intimidade, ridicularização, limitação do direito de ir e vir, art. 7º, II) — não corresponde à violência física.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Calúnia, difamação ou injúria" é a definição de violência MORAL (art. 7º, V), não física.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Constranja a presenciar... relação sexual não desejada" é parte da definição de violência SEXUAL (art. 7º, III), não física.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Dano emocional e diminuição da autoestima... pleno desenvolvimento" é o início da definição de violência PSICOLÓGICA (art. 7º, II), não física.

BIZU DE PROVA:
Física é a definição mais curta e objetiva do art. 7º — "ofender integridade ou saúde corporal". As alternativas A e E, juntas, formam quase a definição inteira de psicológica dividida em duas partes — mas nenhuma delas, isoladamente, corresponde à física.', 'TEC Concursos — questão 2925122 — IBFC — ASoc (EBSERH)/HU Brasil/2023'),
  (2891542, 'IGEDUC', 'ASoc (Pref Pombos)/Pref Pombos/Secretaria de Educação/2023', 2023, 'Julgue o item a seguir. A violência doméstica e familiar contra a mulher constitui uma das formas de violação dos direitos humanos.', 'GABARITO: CERTO

POR QUE:
O art. 6º da Lei 11.340/2006 estabelece expressamente que a violência doméstica e familiar contra a mulher constitui uma das formas de violação dos direitos humanos.

BIZU DE PROVA:
Frase literal do art. 6º — uma das mais cobradas isoladamente em itens Certo/Errado, justamente por ser curta e direta.

PEGADINHA:
Não há pegadinha nesta questão — é uma transcrição fiel e completa do art. 6º.', 'TEC Concursos — questão 2891542 — IGEDUC — ASoc (Pref Pombos)/Pref Pombos/Secretaria de Educação/2023'),
  (2890917, 'NTCS', 'GCM (Pref SJ da Baliza)/Pref SJ da Baliza/2023', 2023, 'A Lei 11.340/06, popularmente conhecida como “Lei Maria da Penha”, visa coibir a violência doméstica e familiar praticada contra a mulher. Considerando as previsões legais a este respeito, assinale a alternativa correta:', 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Reproduz literalmente o art. 6º — a violência doméstica e familiar contra a mulher constitui uma das formas de violação dos direitos humanos.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Inverte a regra do art. 5º, I, ao exigir "desde que haja vínculo familiar" — a Lei diz "com ou sem vínculo familiar".

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A Lei não prevê essa restrição — a agressora pode ser de qualquer gênero, desde que a vítima seja mulher e a conduta se baseie no gênero, dentro de um dos três âmbitos do art. 5º (como reconhecido pela jurisprudência em relações homoafetivas).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Restringe indevidamente o conceito de família a "obrigatoriamente aparentados... por laços naturais" — o art. 5º, II, admite também aparentamento por afinidade ou por vontade expressa, sem exigir que seja "obrigatório" apenas por laços naturais.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Inverte a regra do art. 5º, III, ao exigir coabitação "obrigatória" — a Lei diz "independentemente de coabitação".

BIZU DE PROVA:
Um padrão que se repete nesta e em várias outras questões: a alternativa correta costuma ser a transcrição literal e fiel de um dos artigos (aqui, o art. 6º), enquanto as demais introduzem pequenas restrições ("desde que", "obrigatoriamente", "apenas") que a Lei não faz.', 'TEC Concursos — questão 2890917 — NTCS — GCM (Pref SJ da Baliza)/Pref SJ da Baliza/2023'),
  (2885524, 'NTCS', 'GCM (Pref Bonfim RR)/Pref Bonfim (RR)/2023', 2023, 'A Lei 11.340/06, popularmente conhecida como “Lei Maria da Penha”, cria mecanismos para coibir a violência doméstica e familiar contra a mulher. Considerando a afirmativa, assinale a alternativa incorreta:', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA (é a alternativa INCORRETA, pedida pelo enunciado):
A vigilância constante e a perseguição contumaz praticadas pelo marido ou companheiro são meios expressamente listados na definição de violência PSICOLÓGICA (art. 7º, II), não patrimonial. Violência patrimonial (art. 7º, IV) trata de retenção, subtração ou destruição de objetos, bens, valores e recursos econômicos — nada disso está relacionado a vigilância ou perseguição.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (é uma afirmativa correta, portanto não é a exceção pedida):
As cinco modalidades citadas (física, psicológica, sexual, patrimonial e moral) são, de fato, formas de violência doméstica e familiar previstas no art. 7º.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA (é uma afirmativa correta, portanto não é a exceção pedida):
Reproduz literalmente a definição de violência física do art. 7º, I.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA (é uma afirmativa correta, portanto não é a exceção pedida):
Impedir o uso de método contraceptivo mediante constrangimento ou intimidação é, de fato, conduta prevista no art. 7º, III, como violência sexual — inclusive quando praticada pelo próprio marido ou companheiro.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA (é uma afirmativa correta, portanto não é a exceção pedida):
Reproduz literalmente a definição de violência moral do art. 7º, V.

BIZU DE PROVA:
"Vigilância constante" e "perseguição contumaz" são termos literais do art. 7º, II (psicológica) — sempre que aparecerem rotulados como "patrimonial" (ou qualquer modalidade que não seja psicológica), a alternativa está errada.', 'TEC Concursos — questão 2885524 — NTCS — GCM (Pref Bonfim RR)/Pref Bonfim (RR)/2023'),
  (2885113, 'FAU UNICENTRO', 'Ass Soc (UNIOESTE)/UNIOESTE/2023', 2023, 'Sobre a Lei Maria da Penha , marque (V) Verdadeiro ou (F) Falso e assinale a alternativa correspondente: ( ) A Lei cria mecanismos para coibir e prevenir a violência doméstica e familiar contra a mulher e estabelece que violência doméstica e familiar contra a mulher é qualquer ação ou omissão baseada no gênero que lhe cause morte, lesão, sofrimento físico, sexual ou psicológico e dano moral ou patrimonial. ( ) A violência doméstica e familiar pode ocorrer no âmbito da unidade doméstica, no âmbito da família ou em qualquer relação íntima de afeto. ( ) A Lei é específica para mulheres e depende da orientação sexual baseada no sistema biológico feminino. ( ) A assistência à mulher em situação de violência doméstica e familiar será prestada de forma articulada e conforme os princípios e as diretrizes previstos na Lei Orgânica da Assistência Social, no Sistema Único de Saúde, no Sistema Único de Segurança Pública, entre outras normas e políticas públicas de proteção, e emergencialmente quando for o caso.', 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A sequência correta é V-V-F-V. O primeiro item é verdadeiro, reproduzindo o art. 1º (coibir e prevenir) combinado com o art. 5º, caput. O segundo item é verdadeiro, reproduzindo os três âmbitos do art. 5º, incisos I a III. O terceiro item é falso: a Lei não é "dependente da orientação sexual baseada no sistema biológico feminino" — pelo contrário, o parágrafo único do art. 5º estabelece que as relações pessoais independem de orientação sexual, e a jurisprudência do STJ/STF reconhece a identidade de gênero (não o sexo biológico) como critério de proteção, inclusive para mulheres trans. O quarto item é verdadeiro, reproduzindo o art. 9º, caput.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Marca o terceiro item como verdadeiro, quando ele contraria diretamente o parágrafo único do art. 5º.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Marca o segundo item como falso, quando ele reproduz corretamente os três âmbitos do art. 5º.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Marca o primeiro item como falso, quando ele reproduz corretamente os arts. 1º e 5º, caput.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Marca o terceiro item como verdadeiro (é falso, pelo motivo já exposto) e o quarto como falso (é verdadeiro, reproduz o art. 9º).

BIZU DE PROVA:
O terceiro item desta questão é a pegadinha central: qualquer afirmação que vincule a proteção da Lei a um "sistema biológico" ou que a torne "dependente" de orientação sexual contraria diretamente o parágrafo único do art. 5º — a Lei é expressa ao dizer que essas relações INDEPENDEM de orientação sexual.', 'TEC Concursos — questão 2885113 — FAU UNICENTRO — Ass Soc (UNIOESTE)/UNIOESTE/2023'),
  (2880201, 'EDUCA PB', 'ASoc (Pref Pilões)/Pref Pilões/2023', 2023, 'Segundo a Lei nº 11.340/96, – Maria da Penha, Art. 7º “São formas de violência doméstica e familiar contra a mulher”, entre outras: I. A violência física, entendida como qualquer conduta que ofenda sua integridade ou saúde corporal. II. A violência psicológica, entendida como qualquer conduta que lhe cause dano emocional e diminuição da autoestima ou que lhe prejudique e perturbe o pleno desenvolvimento ou que vise degradar ou controlar suas ações, comportamentos, crenças e decisões, mediante ameaça, constrangimento, humilhação, manipulação, isolamento, vigilância constante, perseguição contumaz, insulto, chantagem, violação de sua intimidade, ridicularização, exploração e limitação do direito de ir e vir ou qualquer outro meio que lhe cause prejuízo à saúde psicológica e à autodeterminação. III. A violência sexual, entendida como qualquer conduta que a constranja a presenciar, a manter ou a participar de relação sexual não desejada, mediante intimidação, ameaça, coação ou uso da força; que a induza a comercializar ou a utilizar, de qualquer modo, a sua sexualidade, que a impeça de usar qualquer método contraceptivo ou que a force ao matrimônio, à gravidez, ao aborto ou à prostituição, mediante coação, chantagem, suborno ou manipulação; ou que limite ou anule o exercício de seus direitos sexuais e reprodutivos. IV. A violência patrimonial, entendida como qualquer conduta que configure retenção, subtração, destruição parcial ou total de seus objetos, instrumentos de trabalho, documentos pessoais, bens, valores e direitos ou recursos econômicos, incluindo os destinados a satisfazer suas necessidades. V. A violência moral, entendida como qualquer conduta que configure calúnia, difamação ou injúria. Estão CORRETOS:', 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Os cinco itens reproduzem, cada um, a definição literal e completa de uma das cinco modalidades então previstas no art. 7º, incisos I a V: I (física), II (psicológica), III (sexual), IV (patrimonial) e V (moral). O próprio enunciado já avisa que a lista é exemplificativa ("entre outras"), então não há problema em confirmar todos os cinco itens como corretos sem que isso implique exaustividade.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Exclui indevidamente os itens IV e V, que também reproduzem corretamente as definições legais de patrimonial e moral.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Exclui indevidamente os itens II e III, que também reproduzem corretamente as definições legais de psicológica e sexual.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Exclui indevidamente o item II, que também reproduz corretamente a definição legal de psicológica.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Exclui indevidamente os itens I e II, que também reproduzem corretamente as definições legais de física e psicológica.

BIZU DE PROVA:
Quando uma questão testar as cinco definições completas e literais, sem nenhuma distorção, o gabarito normalmente confirma todas — o cuidado aqui é ler cada definição INTEIRA (elas são longas, principalmente psicológica e sexual) para confirmar que nenhuma foi alterada.', 'TEC Concursos — questão 2880201 — EDUCA PB — ASoc (Pref Pilões)/Pref Pilões/2023'),
  (2873346, 'IGEDUC', 'ASoc (Pref Pombos)/Pref Pombos/Secretaria de Assistência Social/2023', 2023, 'Julgue o item a seguir. De acordo com a lei Maria da Penha, configura violência doméstica e familiar contra a mulher qualquer ação ou omissão baseada no gênero que lhe cause morte, lesão, sofrimento físico, sexual ou psicológico e dano moral ou patrimonial.', 'GABARITO: CERTO

POR QUE:
A afirmativa reproduz literalmente o art. 5º, caput, da Lei 11.340/2006: configura violência doméstica e familiar contra a mulher qualquer ação ou omissão baseada no gênero que lhe cause morte, lesão, sofrimento físico, sexual ou psicológico e dano moral ou patrimonial.

BIZU DE PROVA:
Esta é a transcrição mais completa e literal do caput do art. 5º entre as questões deste sub-lote — decore essa frase inteira, pois é a base de toda a Lei.

PEGADINHA:
Não há pegadinha nesta questão — é uma transcrição fiel e completa.', 'TEC Concursos — questão 2873346 — IGEDUC — ASoc (Pref Pombos)/Pref Pombos/Secretaria de Assistência Social/2023'),
  (2872545, 'IGEDUC', 'Ori Soc (Pref Ingá)/Pref Ingá/2023', 2023, 'Julgue o item a seguir. Forçar relação ou ato sexual (mesmo que com marido ou companheiro), manter relação com mulher inconsciente, obrigar a presenciar relação sexual de terceiro, impedir uso de método contraceptivo são exemplos de violência sexual.', 'GABARITO: CERTO

POR QUE:
Todos os exemplos citados se enquadram na definição de violência sexual do art. 7º, III: forçar relação ou ato sexual (inclusive dentro do casamento ou união estável — a Lei não presume consentimento permanente pelo vínculo conjugal), manter relação com mulher inconsciente (relação sexual necessariamente não desejada, já que ela não pode consentir), obrigar a presenciar relação sexual de terceiro ("constranja a presenciar... relação sexual não desejada") e impedir o uso de método contraceptivo.

BIZU DE PROVA:
Um ponto frequentemente mal compreendido: a violência sexual da Lei Maria da Penha se aplica mesmo dentro do casamento ou união estável — não existe "direito" do cônjuge/companheiro a relações sexuais independentemente do consentimento da mulher.

PEGADINHA:
A expressão "mesmo que com marido ou companheiro" é o ponto central testado — não deixe que o vínculo conjugal sugira uma presunção de consentimento permanente.', 'TEC Concursos — questão 2872545 — IGEDUC — Ori Soc (Pref Ingá)/Pref Ingá/2023'),
  (2872477, 'IGEDUC', 'Ori Soc (Pref Ingá)/Pref Ingá/2023', 2023, 'Julgue o item a seguir. São exemplos de violência psicológica contra mulheres: rasgar roupas, quebrar celular, destruir fotos, controlar salários e outros valores recebidos pela mulher.', 'GABARITO: ERRADO

POR QUE:
Rasgar roupas, quebrar celular, destruir fotos e controlar salários/valores recebidos pela mulher são exemplos de violência PATRIMONIAL (art. 7º, IV — destruição de objetos e controle/subtração de valores/recursos econômicos), não psicológica. Violência psicológica (art. 7º, II) tem definição própria, centrada em dano emocional, diminuição de autoestima, humilhação, isolamento, ameaça etc.

BIZU DE PROVA:
Sempre que os exemplos envolverem destruir/controlar OBJETOS, DINHEIRO ou DOCUMENTOS da vítima, pense em patrimonial, mesmo que o item tente rotular como outra modalidade.

PEGADINHA:
Os quatro exemplos oferecidos são reais e plausíveis (de fato, acontecem em contextos de violência doméstica), mas o rótulo "psicológica" está errado — todos são exemplos clássicos de violência patrimonial.', 'TEC Concursos — questão 2872477 — IGEDUC — Ori Soc (Pref Ingá)/Pref Ingá/2023'),
  (2872471, 'IGEDUC', 'Ori Soc (Pref Ingá)/Pref Ingá/2023', 2023, 'Julgue o item a seguir. Insultar, caluniar, difamar, mentir para expor a mulher, inclusive com o uso das redes sociais e, ainda, fotografar ou filmar cenas íntimas com autorização e expô-las são exemplos de violência física.', 'GABARITO: ERRADO

POR QUE:
Insultar, caluniar, difamar e mentir para expor a mulher (inclusive em redes sociais) e expor fotos/vídeos íntimos sem autorização para tanto são exemplos de violência PSICOLÓGICA (art. 7º, II — insulto, violação de intimidade, ridicularização) e/ou MORAL (art. 7º, V — calúnia, difamação), não física. Violência física (art. 7º, I) exige ofensa à integridade ou saúde corporal, o que não está descrito em nenhuma das condutas narradas.

BIZU DE PROVA:
Insultar, caluniar, difamar, mentir e expor fotos/vídeos íntimos sem autorização = psicológica e/ou moral, nunca física, mesmo quando praticados por meio de redes sociais.

PEGADINHA:
O item lista condutas verdadeiramente graves e reais (inclusive o que hoje se popularizou como exposição não consentida de conteúdo íntimo), mas erra deliberadamente o rótulo final ("violência física") — leia até o final antes de responder.', 'TEC Concursos — questão 2872471 — IGEDUC — Ori Soc (Pref Ingá)/Pref Ingá/2023'),
  (2852647, 'ASSEGE', 'ASoc (Pref Aramari)/Pref Aramari/2023', 2023, 'A Lei Maria da Penha cria mecanismos para coibir e prevenir a violência doméstica e familiar contra a mulher, nos termos do § 8º do art. 226 da Constituição Federal, da Convenção sobre a Eliminação de Todas as Formas de Violência contra a Mulher, da Convenção Interamericana para Prevenir, Punir e Erradicar a Violência contra a Mulher e de outros tratados internacionais ratificados pela República Federativa do Brasil; dispõe sobre a criação dos Juizados de Violência Doméstica e Familiar contra a Mulher; e estabelece medidas de assistência e proteção às mulheres em situação de violência doméstica e familiar. Consoante com a Lei Maria da Penha, são formas de violência doméstica e familiar contra a mulher, exceto:', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA (é a exceção pedida pelo enunciado):
"Violência matrimonial" não é modalidade nomeada pelo art. 7º da Lei 11.340/2006.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (é uma forma prevista, portanto não é a exceção pedida):
Violência física é modalidade expressamente prevista no art. 7º, I.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA (é uma forma prevista, portanto não é a exceção pedida):
Violência psicológica é modalidade expressamente prevista no art. 7º, II.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA (é uma forma prevista, portanto não é a exceção pedida):
Violência sexual é modalidade expressamente prevista no art. 7º, III.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA (é uma forma prevista, portanto não é a exceção pedida):
Violência moral é modalidade expressamente prevista no art. 7º, V.

BIZU DE PROVA:
"Matrimonial" é pegadinha sonora de "patrimonial" — soa parecido, mas não é modalidade nomeada pela Lei (nem sequer se refere ao mesmo conceito).', 'TEC Concursos — questão 2852647 — ASSEGE — ASoc (Pref Aramari)/Pref Aramari/2023'),
  (2844317, 'GSA', 'GCM (Pref Itapetininga)/Pref Itapetininga/2023', 2023, 'Em relação à Lei n. 11.340/06 que cria mecanismos para coibir a violência doméstica e familiar contra a mulher é correto afirmar que são formas de violência contra mulher, dentre outras: I. a violência física, entendida como qualquer conduta que ofenda sua integridade ou saúde corporal; II. a violência psicológica, entendida como qualquer conduta que lhe cause desconforto, mas não dano emocional, lhe diminua a autoestima, não incluída a perturbação ao pleno desenvolvimento mulher, mas sim a comportamento que vise degradar ou controlar suas ações, crenças e decisões, mediante ameaça, constrangimento, humilhação, manipulação, isolamento, vigilância constante, perseguição contumaz, insulto, chantagem, violação de sua intimidade, ridicularização, exploração e limitação do direito de ir e vir ou qualquer outro meio que lhe cause prejuízo à saúde psicológica e à autodeterminação. III. a violência sexual, entendida como qualquer conduta que a constranja a presenciar, a manter ou a participar de relação sexual não desejada, mediante intimidação, ameaça, coação ou uso da força; que a induza a comercializar ou a utilizar, de qualquer modo, a sua sexualidade, que a impeça de usar qualquer método contraceptivo ou que a force ao matrimônio, à gravidez, ao aborto ou à prostituição, mediante coação, chantagem, suborno ou manipulação; ou que limite ou anule o exercício de seus direitos sexuais e reprodutivos; IV. a violência patrimonial, nos termos da lei, é entendida como qualquer conduta que configure retenção, subtração, destruição parcial ou total de seus objetos, instrumentos de trabalho, documentos pessoais, bens, valores e direitos ou recursos econômicos, incluindo os destinados a satisfazer suas necessidades; V. a violência moral pode ser identificada como qualquer conduta que configure calúnia, difamação ou injúria.', 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA (apenas a afirmação II é incorreta):
A afirmação II distorce a definição de violência psicológica ao inserir negações que a Lei não faz: diz que a conduta causa "desconforto, MAS NÃO dano emocional" e que "NÃO inclui a perturbação ao pleno desenvolvimento" — mas o art. 7º, II, é claro ao incluir EXPRESSAMENTE tanto o dano emocional quanto o prejuízo/perturbação ao pleno desenvolvimento como elementos da definição. As afirmações I, III, IV e V reproduzem corretamente as definições de física, sexual, patrimonial e moral, respectivamente (art. 7º, incisos I, III, IV e V).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Considera a afirmação V incorreta (ela está correta, reproduz fielmente o art. 7º, V) e a II correta (ela está incorreta, pelo motivo já exposto) — inverte as duas.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Considera a afirmação I incorreta, mas ela reproduz corretamente o art. 7º, I.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Considera a afirmação II correta (ela é incorreta) e a III incorreta (ela reproduz corretamente o art. 7º, III, sendo, portanto, correta).

BIZU DE PROVA:
Fique atento a definições "quase certas" que inserem uma negação sutil ("mas não", "não incluída") no meio de um texto que, de resto, parece com a Lei — essa é a técnica usada na afirmação II desta questão para distorcer a definição de psicológica.', 'TEC Concursos — questão 2844317 — GSA — GCM (Pref Itapetininga)/Pref Itapetininga/2023'),
  (2844316, 'GSA', 'GCM (Pref Itapetininga)/Pref Itapetininga/2023', 2023, 'Em relação à Lei n. 11.340/06 que cria mecanismos para coibir a violência doméstica e familiar contra a mulher, cujo fundamento de proteção e defesa se extrai do texto constitucional e disposições normativas convencionais no âmbito internacional, é correto afirmar que:', 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A afirmação é uma paráfrase correta (embora não exaustiva) do art. 5º, caput — a violência doméstica pode importar, entre outros efeitos, em sofrimento psicológico, sem que isso exclua os demais efeitos previstos (morte, lesão, sofrimento físico/sexual, dano moral/patrimonial); a expressão "dentre outros efeitos" preserva corretamente essa abrangência.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Restringe indevidamente a unidade doméstica a "apenas as relações decorrentes de vínculo familiar" — o art. 5º, I, é expresso ao incluir também pessoas sem vínculo familiar ("com ou sem vínculo familiar, inclusive as esporadicamente agregadas").

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Exclui indevidamente o dano moral (que está expressamente incluído no art. 5º, caput) e a conduta omissiva (o art. 5º, caput, expressamente admite "ação OU omissão").

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Contraria diretamente o parágrafo único do art. 5º, que estabelece que as relações pessoais independem (não "dependem") de orientação sexual.

BIZU DE PROVA:
"Dentre outros efeitos" (ou "entre outras", "algumas") é expressão que preserva a abrangência da Lei — diferente de "apenas", "exclusivamente" ou "excluída", que costumam sinalizar uma restrição indevida introduzida pela banca.', 'TEC Concursos — questão 2844316 — GSA — GCM (Pref Itapetininga)/Pref Itapetininga/2023'),
  (2832187, 'FUNDATEC', 'Ag (Água de Ivoti)/Água de Ivoti/Administrativo/2023', 2023, 'Analise as seguintes asserções e a relação proposta entre elas, tendo por referência a Lei Maria da Penha (Lei Federal nº 11.340/2006): I. A violência doméstica e familiar contra a mulher constitui uma das formas de violação de direitos e garantias fundamentais, porém não se enquadra como forma de violação dos Direitos Humanos. PORQUE II. A violência doméstica e familiar é apenas a que ocorre no âmbito da unidade familiar, compreendida como a comunidade formada por indivíduos que são ou se consideram aparentados, unidos por laços naturais, por afinidade ou por vontade expressa. A respeito dessas asserções, assinale a alternativa correta.', 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
As asserções I e II são ambas falsas. A asserção I erra ao dizer que a violência doméstica "não se enquadra como forma de violação dos Direitos Humanos" — o art. 6º diz exatamente o contrário. A asserção II erra ao restringir a violência doméstica "apenas" ao âmbito da família — o art. 5º prevê três âmbitos alternativos (unidade doméstica, família e relação íntima de afeto), não somente a família.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Considera as duas verdadeiras — ambas são falsas, pelos motivos acima.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Considera as duas verdadeiras (mesmo erro da alternativa A) e ainda nega que a II justifique a I.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Considera a asserção I verdadeira — ela é falsa, pois contraria diretamente o art. 6º.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Considera a asserção I falsa (correto) mas a II verdadeira — a II também é falsa, pois restringe indevidamente a violência doméstica apenas ao âmbito familiar.

BIZU DE PROVA:
Duas pegadinhas nesta única questão: negar que a violência doméstica seja violação de direitos humanos (contraria o art. 6º) e restringir a Lei "apenas" a um dos três âmbitos do art. 5º (que são alternativos entre si, não exclusivos).', 'TEC Concursos — questão 2832187 — FUNDATEC — Ag (Água de Ivoti)/Água de Ivoti/Administrativo/2023'),
  (2832030, 'INSTITUTO MAIS', 'GM (Pref Cosmópolis)/Pref Cosmópolis/2023', 2023, 'De acordo com a Lei Maria da Penha, entendida como qualquer conduta que cause danos emocionais e diminuição da autoestima ou que lhe prejudique e perturbe o pleno desenvolvimento ou que vise degradar ou controlar suas ações, comportamentos, crenças e decisões, mediante ameaça, constrangimento, humilhação, manipulação, isolamento, vigilância constante, perseguição contumaz, insulto, chantagem, violação de sua intimidade, ridicularização, exploração e limitação do direito de ir e vir ou qualquer outro meio que lhe cause prejuízo à saúde psicológica e a autodeterminação é denominada de violência.', 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A definição apresentada — dano emocional e diminuição da autoestima, prejuízo ao pleno desenvolvimento, degradar ou controlar ações mediante ameaça, constrangimento, humilhação etc. — reproduz literalmente o art. 7º, II, que define violência psicológica.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Violência física (art. 7º, I) é definida como ofensa à integridade ou saúde corporal — não corresponde ao texto apresentado.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Violência sexual (art. 7º, III) tem definição própria, sem relação com o texto apresentado.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Violência moral (art. 7º, V) é definida como calúnia, difamação ou injúria — não corresponde ao texto apresentado.

BIZU DE PROVA:
"Dano emocional e diminuição da autoestima... degradar ou controlar ações, comportamentos, crenças e decisões" é a frase-chave de abertura da definição de psicológica — memorize-a para reconhecer de imediato.', 'TEC Concursos — questão 2832030 — INSTITUTO MAIS — GM (Pref Cosmópolis)/Pref Cosmópolis/2023'),
  (2831105, 'FUNDATEC', 'Serv (CM Agudo)/CM Agudo/2023', 2023, 'A Lei Maria da Penha (Lei nº 11.340/2006) ajuda a prevenir e impedir a violência doméstica e familiar contra a mulher. Segundo essa lei, violência doméstica e familiar contra a mulher é qualquer ação ou omissão que se embase no(a):', 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O art. 5º, caput, é expresso ao definir violência doméstica e familiar contra a mulher como qualquer ação ou omissão BASEADA NO GÊNERO.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Raça" não é o critério definidor da Lei Maria da Penha — discriminação racial é tratada por legislação específica (Lei 7.716/1989, injúria racial no Código Penal).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Cor" não é o critério definidor da Lei Maria da Penha.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Condição social" não é o critério definidor da Lei Maria da Penha.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Idade" não é o critério definidor da Lei Maria da Penha.

BIZU DE PROVA:
"Baseada no gênero" é o critério central e exclusivo do art. 5º, caput — é o elemento que distingue a violência doméstica e familiar de outras formas de violência ou conflito.', 'TEC Concursos — questão 2831105 — FUNDATEC — Serv (CM Agudo)/CM Agudo/2023'),
  (2830572, 'FUNDATEC', 'Aux Leg (CM Agudo)/CM Agudo/2023', 2023, 'Considerando as formas de violência especificadas pela Lei Maria da Penha, assinale a alternativa correta.', 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Impedir a vítima de usar método contraceptivo é conduta expressamente prevista no art. 7º, III, como violência sexual.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Calúnia, injúria ou difamação são condutas especificamente definidas pelo art. 7º, V, como violência MORAL — não psicológica. Embora toda violência doméstica cause algum sofrimento psíquico em sentido amplo, a Lei atribui essas condutas especificamente à modalidade moral, de forma distinta e exclusiva da psicológica.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A retenção de documentos (certidão de casamento, RG) é conduta especificamente definida pelo art. 7º, IV, como violência PATRIMONIAL — não psicológica.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Vigilância constante e controle de mensagens são condutas especificamente listadas no art. 7º, II, como meios de violência PSICOLÓGICA — não moral.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Impedir o uso de contraceptivo é especificamente atribuído pelo art. 7º, III, à violência SEXUAL — não moral.

BIZU DE PROVA:
O art. 7º atribui cada conduta a UMA modalidade específica e exclusiva, mesmo que, em sentido amplo, quase toda violência doméstica cause algum sofrimento psicológico — a classificação técnica-legal sempre segue a modalidade EXPRESSAMENTE indicada pelo inciso correspondente, não uma impressão geral de "isso também afeta psicologicamente a vítima".', 'TEC Concursos — questão 2830572 — FUNDATEC — Aux Leg (CM Agudo)/CM Agudo/2023'),
  (2828648, 'FCC', 'AJ (TJ BA)/TJ BA/Apoio Especializado/Pedagogo/2023', 2023, 'Nos termos da Lei nº 11.340/2006 (Lei Maria da Penha), a violência psicológica é', 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
"Toda ação ou omissão que causa ou visa causar dano à autoestima, à identidade ou ao pleno desenvolvimento da pessoa" é uma paráfrase fiel do núcleo do art. 7º, II — dano emocional e diminuição da autoestima, ou prejuízo/perturbação ao pleno desenvolvimento.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A Lei não estabelece hierarquia de gravidade entre as modalidades de violência, e caracterizar a submissão da vítima como "voluntária" desconsidera a própria natureza da violência psicológica, que opera justamente por controle e manipulação, não por escolha livre da vítima.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A Lei não estabelece essa regra de prova restritiva (comprovação exclusivamente por testemunhas imparciais) — a comprovação da violência psicológica pode se dar por qualquer meio de prova admitido em direito.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Mistura a definição de violência física ("integridade, saúde corporal") com "ou mental" (elemento que não consta do art. 7º, I) e ainda inventa um requisito de repetição por "extenso período" que a Lei não exige — um único ato pode configurar violência psicológica.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Atribui à violência psicológica a definição de violência MORAL (calúnia, difamação ou injúria, art. 7º, V) e ainda restringe indevidamente a uma finalidade específica ("desqualificar como mãe e pessoa do lar") que a Lei não exige.

BIZU DE PROVA:
Desconfie de alternativas que (1) hierarquizem a gravidade das modalidades, (2) inventem regras de prova específicas, (3) exijam repetição/duração mínima ou (4) misturem elementos de duas definições diferentes — nenhuma dessas restrições consta do texto real da Lei.', 'TEC Concursos — questão 2828648 — FCC — AJ (TJ BA)/TJ BA/Apoio Especializado/Pedagogo/2023'),
  (2824698, 'AVANÇASP', 'OSoc (Pref Itapecerica S)/Pref Itapecerica S/2023', 2023, 'De acordo com a Lei Maria da Penha (Lei Federal n.º 11.340/06), assinale a alternativa com a sequencia correta. _______________, entendida como qualquer conduta que ofenda sua integridade ou saúde corporal; ______________, entendida como qualquer conduta que configure retenção, subtração, destruição parcial ou total de seus objetos, instrumentos de trabalho, documentos pessoais, bens, valores e direitos ou recursos econômicos, incluindo os destinados a satisfazer suas necessidades; _______________, entendida como qualquer conduta que configure calúnia, difamação ou injúria.', 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A sequência correta é violência física (ofende integridade/saúde corporal, art. 7º, I) - violência patrimonial (retenção/subtração/destruição de objetos/bens, art. 7º, IV) - violência moral (calúnia/difamação/injúria, art. 7º, V).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Inverte completamente a ordem: atribui patrimonial à primeira definição (que é física), moral à segunda (que é patrimonial) e física à terceira (que é moral).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Atribui psicológica à primeira definição (que é física) e física à segunda (que é patrimonial).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Atribui moral à primeira definição (que é física) e patrimonial à segunda posição corretamente, mas física à terceira (que é moral).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Atribui sexual à primeira definição (que é física) e psicológica à terceira (que é moral).

BIZU DE PROVA:
"Ofende integridade/saúde corporal" = física; "retenção/subtração/destruição de objetos/bens" = patrimonial; "calúnia/difamação/injúria" = moral — a ordem em que essas três definições costumam aparecer juntas em questões de preenchimento é sempre a mesma: física, patrimonial, moral.', 'TEC Concursos — questão 2824698 — AVANÇASP — OSoc (Pref Itapecerica S)/Pref Itapecerica S/2023'),
  (2822362, 'FCC', 'AJ (TJ BA)/TJ BA/Apoio Especializado/Assistente Social/2023', 2023, 'Considera-se violência doméstica e familiar contra a mulher qualquer ação ou omissão baseada no gênero que lhe cause morte. lesão, sofrimento físico, sexual ou psicológico e dano moral ou patrimonial. Para fins de aplicação da Lei n° 11.340/2006 (Lei -Maria da Penha), as relações pessoais', 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O parágrafo único do art. 5º estabelece que as relações pessoais enunciadas no artigo independem de orientação sexual.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A Lei não exige registro formal da relação — o art. 5º, III, alcança qualquer relação íntima de afeto, com ou sem casamento/união estável formalizados.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A Lei não se limita a relações heterossexuais — o parágrafo único do art. 5º e a jurisprudência do STJ/STF garantem sua aplicação também a relações homoafetivas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Violência causal" não é conceito ou expressão utilizada pela Lei nem corresponde ao que está sendo perguntado (as características das relações pessoais protegidas).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Incidem nas ocorrências cotidianas de violência" é afirmação vaga que não responde à pergunta específica sobre a natureza das relações pessoais alcançadas pela Lei.

BIZU DE PROVA:
"Independem de orientação sexual" é a resposta correta sempre que a pergunta for sobre a natureza/alcance das relações pessoais protegidas pelo art. 5º — memorize essa frase literal do parágrafo único.', 'TEC Concursos — questão 2822362 — FCC — AJ (TJ BA)/TJ BA/Apoio Especializado/Assistente Social/2023'),
  (2813039, 'INTEGRI BRASIL', 'GC (Pref Socorro)/Pref Socorro/Estagiário/2023', 2023, 'De acordo com a Lei Federal nº 11.340, de 7 de agosto de 2006 - Art. 7º São formas de violência doméstica e familiar contra a mulher, entre outras: Assinale a alternativa FALSA:', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA (é a alternativa FALSA, pedida pelo enunciado):
"Violência cultural" não é modalidade nomeada pelo art. 7º, e a descrição oferecida ("dificulte o desenvolvimento escolar da mulher") também não corresponde a nenhum trecho da Lei.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (é uma afirmativa verdadeira, portanto não é a exceção pedida):
Reproduz literalmente a definição de violência física do art. 7º, I.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA (é uma afirmativa verdadeira, portanto não é a exceção pedida):
Reproduz literalmente a definição completa de violência psicológica do art. 7º, II.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA (é uma afirmativa verdadeira, portanto não é a exceção pedida):
Reproduz literalmente a definição completa de violência sexual do art. 7º, III.

BIZU DE PROVA:
"Violência cultural" não existe no rol do art. 7º — mesmo que o tema (acesso à educação) seja socialmente relevante, não é uma das modalidades nomeadas pela Lei Maria da Penha.', 'TEC Concursos — questão 2813039 — INTEGRI BRASIL — GC (Pref Socorro)/Pref Socorro/Estagiário/2023'),
  (2755533, 'IVIN', 'CSS (Pref Valença do PI)/Pref Valença do PI/2023', 2023, 'De acordo com a Lei Maria da Penha, é entendida como qualquer conduta que lhe cause dano emocional e diminuição da autoestima ou que lhe prejudique e perturbe o pleno desenvolvimento ou que vise degradar ou controlar suas ações, comportamentos, crenças e decisões, mediante ameaça, constrangimento, humilhação, manipulação, isolamento, vigilância constante, perseguição contumaz, insulto, chantagem, violação de sua intimidade, ridicularização, exploração e limitação do direito de ir e vir ou qualquer outro meio que lhe cause prejuízo à saúde psicológica e à autodeterminação:', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
A definição apresentada — dano emocional e diminuição da autoestima, prejuízo ao pleno desenvolvimento, degradar ou controlar ações mediante ameaça, constrangimento, humilhação, manipulação, isolamento, vigilância constante, perseguição contumaz, insulto, chantagem, violação de intimidade, ridicularização, exploração e limitação do direito de ir e vir — reproduz literalmente o art. 7º, II, que define violência psicológica.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Violência patrimonial (art. 7º, IV) trata de objetos, bens e valores — não corresponde ao texto apresentado.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Violência física (art. 7º, I) trata de ofensa à integridade ou saúde corporal — não corresponde ao texto apresentado.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Violência sexual (art. 7º, III) trata de constranger a ato sexual, entre outras condutas — não corresponde ao texto apresentado.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Violência moral (art. 7º, V) trata de calúnia, difamação ou injúria — não corresponde ao texto apresentado.

BIZU DE PROVA:
Esta é a definição mais longa do art. 7º — reconhecer sua estrutura completa (dano emocional/autoestima + degradar/controlar + rol extenso de meios) é suficiente para identificar psicológica mesmo sem ler a alternativa inteira.', 'TEC Concursos — questão 2755533 — IVIN — CSS (Pref Valença do PI)/Pref Valença do PI/2023'),
  (2749394, 'SELECON', 'Mon Soc (Pref Pri do Leste)/Pref Pri do Leste/2023', 2023, 'A Lei Maria da Penha (n.º 11.340 de 07/08/2006) estabelece que, dentre as formas de violência doméstica e familiar contra a mulher está a psicológica, entendida como qualquer conduta que:', 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
"Vise controlar suas ações, comportamentos, crenças e decisões, mediante ameaça, constrangimento, humilhação, manipulação, isolamento, vigilância constante" reproduz fielmente um trecho central da definição de violência psicológica do art. 7º, II.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Calúnia, difamação ou injúria" é a definição de violência MORAL (art. 7º, V), não psicológica — e a Lei não estende essa definição a "descendentes" da mulher; o art. 7º, V, refere-se a condutas contra a própria ofendida.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Retenção, subtração, destruição... de objetos, instrumentos de trabalho e documentos pessoais" é a definição de violência PATRIMONIAL (art. 7º, IV), não psicológica.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Impedir o uso de método contraceptivo... ou forçar ao matrimônio, à gravidez, ao aborto ou à prostituição" é a definição de violência SEXUAL (art. 7º, III), não psicológica.

BIZU DE PROVA:
"Controlar ações, comportamentos, crenças e decisões mediante ameaça/constrangimento/humilhação/manipulação/isolamento/vigilância" é o núcleo mais reconhecível da definição de psicológica — mesmo em trechos truncados (sem o restante da lista de meios), esse padrão já identifica a modalidade certa.', 'TEC Concursos — questão 2749394 — SELECON — Mon Soc (Pref Pri do Leste)/Pref Pri do Leste/2023'),
  (2739031, 'IGEDUC', 'GM (Pref Surubim)/Pref Surubim/2023', 2023, 'Julgue o item a seguir. Segundo a Lei Maria da Penha, a violência doméstica e familiar contra a mulher ocorre em âmbito físico, excluindo qualquer tipo de violência psicológica.', 'GABARITO: ERRADO

POR QUE:
A violência doméstica e familiar contra a mulher não se limita ao âmbito físico — o art. 7º prevê expressamente também as modalidades psicológica, sexual, patrimonial e moral (e, desde a Lei 15.384/2026, a vicária). A afirmativa erra ao dizer que a Lei "exclui qualquer tipo de violência psicológica".

BIZU DE PROVA:
Qualquer afirmativa que reduza a violência doméstica ao âmbito físico, excluindo as demais modalidades, está sempre errada — é precisamente o oposto do que a Lei Maria da Penha busca reconhecer.

PEGADINHA:
A palavra "excluindo" é a pista clara de que a afirmativa está tentando restringir indevidamente o alcance da Lei.', 'TEC Concursos — questão 2739031 — IGEDUC — GM (Pref Surubim)/Pref Surubim/2023'),
  (2736918, 'IGEDUC', 'GM (Pref SV Férrer)/Pref SV Férrer/2023', 2023, 'Julgue o item a seguir. São formas de violência doméstica e familiar contra a mulher, entre outras: violência física, violência psicológica, violência sexual, violência patrimonial e violência moral.', 'GABARITO: CERTO

POR QUE:
A afirmativa reproduz corretamente as cinco modalidades então nomeadas pelo art. 7º (física, psicológica, sexual, patrimonial e moral), preservando o caráter exemplificativo do rol ao usar a expressão "entre outras" — a mesma expressão usada pelo próprio art. 7º, caput.

BIZU DE PROVA:
"Entre outras" é a expressão que sinaliza que a lista não é fechada — quando presente, mesmo enumerar exatamente as cinco modalidades clássicas não gera nenhuma tensão com a violência vicária acrescentada pela Lei 15.384/2026, pois a afirmativa nunca alegou exaustividade.

PEGADINHA:
Não há pegadinha nesta questão — é uma afirmativa correta e fiel ao texto legal, incluindo o cuidado de preservar o "entre outras".', 'TEC Concursos — questão 2736918 — IGEDUC — GM (Pref SV Férrer)/Pref SV Férrer/2023'),
  (2736792, 'IGEDUC', 'GM (Pref SV Férrer)/Pref SV Férrer/2023', 2023, 'A violência sexual é entendida como qualquer conduta que constranja a mulher a presenciar, a manter ou a participar de relação sexual não desejada, mediante intimidação, ameaça, coação ou uso da força.', 'GABARITO: CERTO

POR QUE:
A afirmativa reproduz corretamente o núcleo do art. 7º, III — violência sexual é a conduta que constranja a mulher a presenciar, a manter ou a participar de relação sexual não desejada, mediante intimidação, ameaça, coação ou uso da força. O fato de a afirmativa não mencionar as demais condutas do mesmo inciso (impedir contraceptivo, forçar a matrimônio/gravidez/aborto/prostituição) não a torna incorreta, pois ela não afirma ser uma definição exaustiva.

BIZU DE PROVA:
Uma afirmação parcial, mas fiel ao texto legal, sem alegar exaustividade, continua correta — só fique atento a alternativas que insiram "apenas" ou "somente" antes de uma definição parcial, o que aí sim tornaria a afirmação errada.

PEGADINHA:
Não há pegadinha aqui — apenas um trecho fiel e parcial do art. 7º, III.', 'TEC Concursos — questão 2736792 — IGEDUC — GM (Pref SV Férrer)/Pref SV Férrer/2023'),
  (2736747, 'IGEDUC', 'GM (Pref SV Férrer)/Pref SV Férrer/2023', 2023, 'Julgue o item a seguir. A violência moral é entendida como qualquer conduta que ofenda sua integridade ou saúde corporal.', 'GABARITO: ERRADO

POR QUE:
"Qualquer conduta que ofenda sua integridade ou saúde corporal" é a definição de violência FÍSICA (art. 7º, I), não moral. Violência moral (art. 7º, V) é definida como qualquer conduta que configure calúnia, difamação ou injúria.

BIZU DE PROVA:
Mislabeling clássico entre física e moral — sempre que "ofender integridade/saúde corporal" aparecer rotulado como "moral" (ou qualquer modalidade que não seja física), a afirmativa está errada.

PEGADINHA:
A definição em si está correta (é, de fato, a definição legal de uma das modalidades) — o erro está apenas no rótulo atribuído a ela.', 'TEC Concursos — questão 2736747 — IGEDUC — GM (Pref SV Férrer)/Pref SV Férrer/2023'),
  (2735885, 'IDECAN', 'GC (Pref Serra)/Pref Serra (ES)/2023', 2023, 'A respeito das formas de violência doméstica e familiar contra a mulher, que se constituem em violação dos direitos humanos e se caracteriza por atos comissivos e omissivos baseados no gênero que lhe cause morte, lesão, sofrimento físico, sexual ou psicológico, bem como dano moral ou patrimonial, assinale a alternativa correspondente à violência psicológica contra a mulher, de acordo com a Lei nº 11.340/2006.', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Reproduz o núcleo da definição de violência psicológica do art. 7º, II — dano emocional e diminuição da autoestima, prejuízo/perturbação ao pleno desenvolvimento, degradar ou controlar ações e comportamentos, crenças e decisões, mediante ameaça ou constrangimento (entre outros meios previstos no dispositivo completo).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Mistura elementos da definição de violência física ("integridade física ou saúde corporal") com uma referência a dano patrimonial — combinação que não corresponde à definição de nenhuma modalidade isoladamente, e certamente não à psicológica.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
É a definição de violência sexual (art. 7º, III), não psicológica.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
É a definição de violência patrimonial (art. 7º, IV), não psicológica.

BIZU DE PROVA:
"Dano emocional e diminuição da autoestima... prejudique e perturbe o pleno desenvolvimento... degradar ou controlar" é o núcleo reconhecível da definição de psicológica, mesmo quando a lista de meios aparece truncada (como nesta questão, que cita apenas "ameaça ou constrangimento" em vez da lista completa).', 'TEC Concursos — questão 2735885 — IDECAN — GC (Pref Serra)/Pref Serra (ES)/2023'),
  (2666495, 'IGEDUC', 'ASoc (Pref Triunfo (PE))/Pref Triunfo (PE)/Todas as áreas/2023', 2023, 'Julgue o item a seguir. A violência doméstica e familiar contra a mulher não se constitui em violação dos direitos humanos.', 'GABARITO: ERRADO

POR QUE:
O art. 6º da Lei 11.340/2006 estabelece exatamente o contrário do afirmado: a violência doméstica e familiar contra a mulher CONSTITUI uma das formas de violação dos direitos humanos.

BIZU DE PROVA:
Sempre que a afirmativa negar a relação entre violência doméstica e direitos humanos, ela está errada — o art. 6º é categórico nesse ponto.

PEGADINHA:
A construção da frase com "não se constitui" inverte diretamente o texto literal do art. 6º — leia com atenção redobrada questões que neguem uma afirmação central e amplamente cobrada da Lei.', 'TEC Concursos — questão 2666495 — IGEDUC — ASoc (Pref Triunfo (PE))/Pref Triunfo (PE)/Todas as áreas/2023'),
  (2664350, 'IGEDUC', 'GM (Pref Triunfo (PE))/Pref Triunfo (PE)/2023', 2023, 'Julgue o item a seguir. A coabitação entre agressor e vítima é necessária para que se configure a violência doméstica.', 'GABARITO: ERRADO

POR QUE:
O art. 5º, III, dispensa expressamente a coabitação para a configuração da violência doméstica em relação íntima de afeto ("independentemente de coabitação"). A coabitação também não é exigida nos âmbitos da unidade doméstica ou da família nos mesmos termos absolutos sugeridos pela afirmativa.

BIZU DE PROVA:
"Independentemente de coabitação" (art. 5º, III) é uma das frases mais cobradas da Lei — qualquer afirmativa que exija coabitação como requisito necessário está errada.

PEGADINHA:
A palavra "necessária" é o ponto central testado — a Lei é desenhada justamente para NÃO exigir esse requisito.', 'TEC Concursos — questão 2664350 — IGEDUC — GM (Pref Triunfo (PE))/Pref Triunfo (PE)/2023'),
  (2641121, 'ADM&TEC', 'OSoc (Pref Timbaúba)/Pref Timbaúba/2023', 2023, 'Analise as afirmativas a seguir: I. Configura-se violência doméstica e familiar contra a mulher qualquer ação ou omissão baseada no gênero que lhe cause morte, lesão, sofrimento físico, sexual ou psicológico e dano moral ou patrimonial, em relações íntimas com coabitação. II. Violência psicológica é uma conduta que causa dano emocional, visando controlar as ações, comportamentos, crenças e decisões, mediante manipulação, forçamento ao matrimônio e à gravidez, isolamento, e com limitação do direito de ir e vir ou qualquer outro meio que lhe cause prejuízo à saúde psicológica e à autodeterminação. III. Violência patrimonial é entendida como qualquer conduta que configure retenção, subtração, destruição parcial ou total de seus objetos, instrumentos de trabalho, documentos pessoais, bens, valores e direitos ou recursos econômicos, incluindo os destinados a satisfazer suas necessidades. Marque a alternativa CORRETA:', 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA (apenas uma afirmativa está correta):
A afirmativa I está incorreta: exige "coabitação" para a configuração da violência doméstica em relações íntimas, quando o art. 5º, III, dispensa expressamente esse requisito ("independentemente de coabitação"). A afirmativa II está incorreta: insere na definição de violência psicológica o "forçamento ao matrimônio e à gravidez", que são, na verdade, condutas específicas da violência SEXUAL (art. 7º, III), não psicológica. A afirmativa III está correta: reproduz literalmente e por completo a definição de violência patrimonial do art. 7º, IV.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Considera as três corretas, mas I e II contêm os erros já apontados.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Considera nenhuma correta, mas a III está integralmente correta.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Considera duas corretas, mas apenas a III está livre de erro — I e II contêm distorções específicas e identificáveis.

BIZU DE PROVA:
A afirmativa II desta questão "contamina" a definição de psicológica com elementos de sexual (forçar a matrimônio/gravidez) — sempre que uma definição misturar elementos de duas modalidades diferentes, ela está incorreta, mesmo que cada elemento isoladamente seja real e verificável em algum lugar da Lei.', 'TEC Concursos — questão 2641121 — ADM&TEC — OSoc (Pref Timbaúba)/Pref Timbaúba/2023'),
  (2634262, 'IGEDUC', 'ASoc (Tupanatinga)/Pref Tupanatinga/2023', 2023, 'A violência patrimonial contra a mulher é entendida como qualquer conduta que configure retenção, subtração, destruição parcial ou total de seus objetos, instrumentos de trabalho, documentos pessoais, bens, valores e direitos ou recursos econômicos, incluindo os destinados a satisfazer suas necessidades (Lei nº 11.340, de 7 de agosto de 2006).', 'GABARITO: CERTO

POR QUE:
A afirmativa reproduz literalmente e por completo a definição de violência patrimonial dada pelo art. 7º, IV, da Lei 11.340/2006.

BIZU DE PROVA:
Transcrição literal e completa — reconhecer a definição inteira do art. 7º, IV é suficiente para confirmar a questão sem necessidade de análise adicional.

PEGADINHA:
Não há pegadinha nesta questão — apenas uma transcrição fiel e completa.', 'TEC Concursos — questão 2634262 — IGEDUC — ASoc (Tupanatinga)/Pref Tupanatinga/2023'),
  (2634226, 'IGEDUC', 'ASoc (Tupanatinga)/Pref Tupanatinga/2023', 2023, 'O conceito de violência sexual contra uma mulher, à luz da legislação atual, compreende qualquer conduta que a estimule a manter, a participar ou a presenciar alguma relação sexual desejada e aceita por ela. Ou seja, qualquer atitude com conotação sexual, realizada diante de uma mulher, ainda que com o seu consentimento, é tida como um ato de violência e, portanto, o seu autor deve ser punido na forma da lei.', 'GABARITO: ERRADO

POR QUE:
A afirmativa inverte completamente a definição legal de violência sexual. O art. 7º, III, trata de conduta que constranja a mulher a presenciar, manter ou participar de relação sexual NÃO DESEJADA — ou seja, o elemento central é a AUSÊNCIA de consentimento. A afirmativa descreve o oposto: relação sexual "desejada e aceita" pela mulher, "ainda que com o seu consentimento" — condutas consensuais não configuram violência sexual pela Lei Maria da Penha, pois a proteção da Lei tem exatamente a função de resguardar a autonomia e o consentimento da mulher, não de criminalizar o exercício livre e consentido de sua sexualidade.

BIZU DE PROVA:
O elemento definidor da violência sexual é sempre a AUSÊNCIA de consentimento/vontade da mulher — "relação sexual não desejada", "mediante intimidação, ameaça, coação ou uso da força". Qualquer definição que inverta isso para "consentida" ou "aceita" contraria o núcleo da proteção legal.

PEGADINHA:
Esta afirmativa tenta usar linguagem jurídica formal e um tom de "reforço protetivo" para mascarar uma inversão completa e grave da definição legal — releia sempre com atenção redobrada quando a alternativa parecer "proteger demais" a mulher a ponto de contrariar a lógica de consentimento que fundamenta toda a modalidade sexual.', 'TEC Concursos — questão 2634226 — IGEDUC — ASoc (Tupanatinga)/Pref Tupanatinga/2023'),
  (2629049, 'ADM&TEC', 'ASoc (Pref Timbaúba)/Pref Timbaúba/2023', 2023, 'Analise as afirmativas a seguir: I. À luz da Lei Maria da Penha, a violência doméstica e familiar contra a mulher não constitui uma das formas de violação dos direitos humanos. II. Configura violência doméstica e familiar contra a mulher qualquer ação ou omissão baseada no gênero que lhe cause morte, lesão, sofrimento físico, sexual ou psicológico e dano moral ou patrimonial. Marque a alternativa CORRETA:', 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA (a afirmativa II é verdadeira, e a I é falsa):
A afirmativa I é falsa: contraria diretamente o art. 6º, que estabelece que a violência doméstica e familiar contra a mulher CONSTITUI uma das formas de violação dos direitos humanos. A afirmativa II é verdadeira: reproduz literalmente o art. 5º, caput.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Considera as duas verdadeiras, mas a I contraria o art. 6º.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Inverte a avaliação correta: considera a I verdadeira (é falsa) e a II falsa (é verdadeira).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Considera as duas falsas, mas a II reproduz corretamente o art. 5º, caput.

BIZU DE PROVA:
Sempre que uma afirmativa negar a relação entre violência doméstica e direitos humanos (art. 6º), ela está errada — é uma das poucas certezas absolutas em questões sobre a Lei Maria da Penha.', 'TEC Concursos — questão 2629049 — ADM&TEC — ASoc (Pref Timbaúba)/Pref Timbaúba/2023'),
  (2622322, 'FUNDATEC', 'Ana Sup (CAU RS)/CAU RS/Sem Área/2023', 2023, 'Tendo por referência a Lei nº 11.340/2006, Lei Maria da Penha, analise as seguintes asserções e a relação proposta entre elas: I. A violência doméstica e familiar contra a mulher constitui uma das formas de violação dos direitos humanos. PORQUE II. Configura violência doméstica e familiar contra a mulher qualquer ação ou omissão baseada no gênero que lhe cause morte, lesão, sofrimento físico, sexual ou psicológico e dano moral ou patrimonial. A respeito dessas asserções, assinale a alternativa correta.', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA (as duas são verdadeiras, mas a II não justifica a I):
A asserção I é verdadeira (art. 6º: a violência doméstica constitui uma das formas de violação dos direitos humanos). A asserção II também é verdadeira (art. 5º, caput: definição dos elementos que configuram violência doméstica). Porém, a II não é o FUNDAMENTO ou a RAZÃO pela qual a I é verdadeira — a II apenas define os ELEMENTOS/requisitos da violência doméstica (ação/omissão baseada no gênero, causando determinados danos), enquanto a I faz uma afirmação normativa distinta (sobre a NATUREZA da violência doméstica como violação de direitos humanos), fundamentada em outras fontes (Constituição Federal, tratados internacionais como CEDAW e Convenção de Belém do Pará), não na mera definição do art. 5º.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Considera a II uma justificativa da I — mas definir os elementos de uma conduta não é o mesmo que explicar por que essa conduta viola direitos humanos.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Considera a I falsa — ela é verdadeira, reproduz o art. 6º.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Considera a II falsa — ela é verdadeira, reproduz o art. 5º, caput.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Considera as duas falsas — ambas são verdadeiras.

BIZU DE PROVA:
Em questões de asserção-razão, verificar se as duas afirmações são verdadeiras é só o primeiro passo — depois é preciso perguntar se a segunda EXPLICA CAUSALMENTE a primeira, ou se são apenas duas verdades independentes, extraídas de dispositivos diferentes da Lei (aqui, arts. 6º e 5º, que tratam de assuntos relacionados mas distintos).', 'TEC Concursos — questão 2622322 — FUNDATEC — Ana Sup (CAU RS)/CAU RS/Sem Área/2023'),
  (2614560, 'Legalle', 'AnaDP (DPE PA)/DPE PA/Serviço Social/2023', 2023, 'Analise as assertivas abaixo acerca da Lei n.º 11.340/2006 ( Lei Maria da Penha). I. A violência psicológica é entendida como qualquer conduta que ofenda a integridade ou saúde corporal da mulher. II. A violência moral-psicológica é entendida como qualquer conduta que configure retenção, subtração, destruição parcial ou total de objetos, instrumentos de trabalho, documentos pessoais, bens, valores e direitos ou recursos econômicos da mulher, incluindo os destinados a satisfazer suas necessidades. III. A violência física é entendida como qualquer conduta que configure calúnia, difamação ou injúria. Está(ão) INCORRETA(S):', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA (as três assertivas estão incorretas):
A assertiva I atribui à violência psicológica a definição de violência FÍSICA (ofender integridade ou saúde corporal, art. 7º, I). A assertiva II atribui a um rótulo inventado ("violência moral-psicológica", que não existe na Lei) a definição de violência PATRIMONIAL (retenção/subtração/destruição de objetos, bens e valores, art. 7º, IV). A assertiva III atribui à violência física a definição de violência MORAL (calúnia, difamação ou injúria, art. 7º, V). As três, portanto, estão incorretas.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Considera apenas I e II incorretas, mas a III também está incorreta (atribui a física a definição de moral).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Considera apenas I e III incorretas, mas a II também está incorreta (usa um rótulo inexistente e atribui a definição errada).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Considera apenas II e III incorretas, mas a I também está incorreta (atribui a psicológica a definição de física).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Considera apenas a II incorreta, mas I e III também estão incorretas.

BIZU DE PROVA:
Esta questão rotaciona sistematicamente as três definições entre três rótulos errados (psicológica↔física, "moral-psicológica"↔patrimonial, física↔moral) — quando isso acontece, geralmente TODAS as assertivas estão incorretas, já que nenhuma manteve seu rótulo original.', 'TEC Concursos — questão 2614560 — Legalle — AnaDP (DPE PA)/DPE PA/Serviço Social/2023'),
  (2596117, 'ITAME', 'Ag (Pref Nazário)/Pref Nazário/Saúde/2023', 2023, 'Sancionada em 7 de agosto de 2006, a Lei nº 11.340, conhecida como Lei Maria da Penha, objetiva proteger a mulher da violência doméstica e familiar. A lei recebeu esse nome devido à luta de Maria da Penha por reparação e justiça. Com intuito de disseminação de informações acerca do combate a violência a mulher, por parte do Agente Comunitário de Saúde, assinale a alternativa correta:', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
A Central de Atendimento à Mulher (Ligue 180) é, de fato, canal disponibilizado pelo governo brasileiro para denúncias sobre violência contra a mulher, podendo ser acionado tanto pela própria vítima quanto por terceiros que identifiquem a situação de violência.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A Lei Maria da Penha não se limita a casos de agressão física — abrange também as modalidades psicológica, sexual, patrimonial e moral (e, desde 2026, vicária).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O art. 17 da Lei veda expressamente a substituição da pena por pagamento isolado de multa ou por prestação pecuniária, incluindo doação de cestas básicas, nos casos de violência doméstica e familiar contra a mulher — a alternativa afirma exatamente o contrário do que a Lei estabelece.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O STF, no julgamento da ADI 4.424 (2012), firmou entendimento de que o crime de lesão corporal leve praticado em contexto de violência doméstica é de ação penal pública INCONDICIONADA — não depende de representação (autorização) da vítima para ser processado.

BIZU DE PROVA:
Três pontos institucionais importantes reunidos nesta questão: (1) o Ligue 180 aceita denúncias de terceiros, não só da vítima; (2) o art. 17 veda pena de cesta básica/multa isolada em violência doméstica; (3) lesão corporal leve em violência doméstica é ação penal pública incondicionada (ADI 4.424/STF), diferente da regra geral do Código Penal para lesão leve simples.', 'TEC Concursos — questão 2596117 — ITAME — Ag (Pref Nazário)/Pref Nazário/Saúde/2023'),
  (2596087, 'ITAME', 'Ag (Pref Nazário)/Pref Nazário/Combate às Endemias/2023', 2023, 'Considerando o ACE, como importante sujeito no processo de orientações acerca da violência contra a mulher, com foco em coibir tal prática, de acordo com a lei 11.340/2006, é considerado uma das formas de violência doméstica e familiar contra a mulher:', 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
"Qualquer conduta que ofenda sua integridade ou saúde corporal" é a definição literal e corretamente rotulada de violência física (art. 7º, I).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Atribui à violência patrimonial a definição de violência MORAL (calúnia, difamação ou injúria, art. 7º, V).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Atribui à violência psicológica a definição de violência SEXUAL (constranger a presenciar/manter relação sexual não desejada, art. 7º, III).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Atribui à violência psicológica a definição de violência PATRIMONIAL (retenção/subtração/destruição de objetos e bens, art. 7º, IV).

BIZU DE PROVA:
Das quatro alternativas, apenas a física está corretamente rotulada — as outras três trocam a definição de patrimonial, sexual e psicológica entre si (nenhuma delas usa o rótulo "moral", que fica de fora desta questão).', 'TEC Concursos — questão 2596087 — ITAME — Ag (Pref Nazário)/Pref Nazário/Combate às Endemias/2023'),
  (2593846, 'VUNESP', 'AgDP (DPE SP)/DPE SP/Cientista Social - Sociólogo/2023', 2023, 'A Lei Federal nº 11.340/2006, conhecida como Lei Maria da Penha, em seu artigo 7º, classifica os diferentes tipos de violência contra a mulher. Especificamente, define a violência moral contra a mulher como sendo', 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A calúnia, a difamação ou a injúria contra a mulher é a definição literal de violência moral dada pelo art. 7º, V.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Desrespeito aos valores éticos" é expressão vaga que não corresponde à definição técnica e precisa do art. 7º, V.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Desprezo pelos princípios religiosos" não é a definição legal de violência moral nem consta do art. 7º, V.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Agressões verbais", de forma genérica, é expressão mais ampla e imprecisa do que a definição específica do art. 7º, V — poderia até se confundir com meios de violência psicológica (insulto, humilhação), que também costumam ser verbais.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Instigação ou induzimento ao suicídio" é conduta tipificada separadamente pelo Código Penal (art. 122) — não é a definição de violência moral do art. 7º, V.

BIZU DE PROVA:
Calúnia, difamação e injúria são os três crimes contra a honra do Código Penal (arts. 138 a 140) — essa é a definição técnica e precisa de violência moral; termos genéricos como "desrespeito", "agressão verbal" ou "desprezo" nunca são a resposta certa quando a definição precisa está disponível como opção.', 'TEC Concursos — questão 2593846 — VUNESP — AgDP (DPE SP)/DPE SP/Cientista Social - Sociólogo/2023'),
  (2591112, 'VUNESP', 'AgDP (DPE SP)/DPE SP/Analista de Suporte/2023', 2023, 'Fulano de Tal, em razão de sua crença religiosa, não aceita a utilização de quaisquer métodos contraceptivos pela sua companheira, com a qual possui quatro filhos. Não desejando engravidar novamente, a sua companheira lhe comunica que não realizará mais sexo com ele sem que ele use preservativo. Fingindo aceitar a condição imposta pela mulher, Fulano de Tal começa o ato sexual usando contraceptivo, mas, sem que a sua companheira note, retira o preservativo no curso da relação sexual. A respeito desta situação hipotética, é correto afirmar com base na Lei nº 11.340/2006, que', 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Ao remover o preservativo sem o conhecimento ou consentimento de sua companheira, contrariando a condição por ela expressamente colocada para a continuidade do ato sexual, Fulano de Tal pratica ato ilícito (retirar, mediante manipulação/engano, o método contraceptivo que ela havia condicionado ao ato — conduta que se enquadra no art. 7º, III, como violência sexual, já que "manipulação" é um dos meios expressamente previstos nesse inciso). Configurado o ato ilícito, nasce o dever de indenizar (Código Civil, arts. 186 e 927), que abrange todos os danos decorrentes, inclusive despesas de saúde necessárias para tratar as consequências (por exemplo, gravidez não planejada ou risco de infecção sexualmente transmissível).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O consentimento inicial de Ana para o ato sexual foi condicionado ao uso do preservativo — a remoção secreta e não consentida do contraceptivo durante o ato altera substancialmente os termos daquilo a que ela consentiu, configurando impedimento ao uso de método contraceptivo mediante manipulação (art. 7º, III), independentemente do consentimento inicial para o início da relação sexual.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Violência moral" pressupõe calúnia, difamação ou injúria (art. 7º, V) — não corresponde à conduta descrita, que é de natureza sexual, não uma ofensa à honra/reputação.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A liberdade religiosa protege as convicções pessoais de Fulano, mas não autoriza que ele engane sua companheira quanto ao uso do contraceptivo durante o ato sexual — nada o impedia de, coerente com sua fé, simplesmente recusar-se a manter relações sexuais nos termos exigidos por ela; ao invés disso, ele optou por fingir concordância e agir de forma enganosa.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não há relato de ofensa à integridade física ou saúde corporal como núcleo da conduta (art. 7º, I) — o cerne da situação é a violação do consentimento quanto ao método contraceptivo, especificamente prevista como violência sexual (art. 7º, III), não física.

BIZU DE PROVA:
Consentimento para relação sexual COM proteção contraceptiva não é o mesmo que consentimento para relação sexual SEM proteção — remover o preservativo secretamente durante o ato ("stealthing") configura impedimento ao uso de contraceptivo mediante manipulação (art. 7º, III, violência sexual), gerando também dever de indenizar por danos, inclusive de saúde.', 'TEC Concursos — questão 2591112 — VUNESP — AgDP (DPE SP)/DPE SP/Analista de Suporte/2023');

create temporary table _l2_alternativas (
  tec_id bigint,
  ordem smallint,
  texto text,
  correta boolean
) on commit drop;

insert into _l2_alternativas (tec_id, ordem, texto, correta) values
  (3627565, 1, 'física.', false),
  (3627565, 2, 'afetiva.', false),
  (3627565, 3, 'psicológica.', true),
  (3627565, 4, 'emocional.', false),
  (3627565, 5, 'moral.', false),
  (3612926, 1, 'Não, porque o relacionamento tem menos de cinco anos.', false),
  (3612926, 2, 'Não, porque o fato ocorreu fora do ambiente doméstico.', false),
  (3612926, 3, 'Sim, pois se trata de violência contra a mulher no contexto de relação intima de afeto, independentemente de coabitação e do local dos fatos.', true),
  (3612926, 4, 'Sim, desde que houver coabitação mínima de dois anos.', false),
  (3612926, 5, 'Sim, desde que não tenha sido a primeira vez que Andreia sofreu agressão por parte de Douglas.', false),
  (3607836, 1, 'não há violência doméstica, pois não existe mais convivência entre os envolvidos.', false),
  (3607836, 2, 'Marcos cometeu violência moral, e não patrimonial, pois agiu motivado por ofensa.', false),
  (3607836, 3, 'o caso configura violência patrimonial nos termos da Lei nº 11.340/2006, pois há vínculo afetivo pretérito.', true),
  (3607836, 4, 'o fato deve ser apurado como mero dano, não havendo aplicação da Lei nº 11.340/2006.', false),
  (3607836, 5, 'só haverá aplicação da Lei nº 11.340/2006 se houver lesão física associada à destruição do objeto.', false),
  (3605267, 1, 'Certo', false),
  (3605267, 2, 'Errado', true),
  (3597162, 1, '3, 2, 1.', false),
  (3597162, 2, '3, 1, 2.', true),
  (3597162, 3, '1, 2, 3.', false),
  (3597162, 4, '2, 3, 1.', false),
  (3596630, 1, 'I e II, apenas.', false),
  (3596630, 2, 'II e III, apenas.', false),
  (3596630, 3, 'I, II e III.', true),
  (3596630, 4, 'I e III, apenas.', false),
  (3850498, 1, 'Por serem lésbicas e não coabitarem, são inaplicáveis as disposições da Lei Maria da Penha.', false),
  (3850498, 2, 'A injúria realizada por Ângela só poderá ser considerada como forma de violência psicológica.', false),
  (3850498, 3, 'Caso Raíssa requeira medida protetiva de urgência, eventual arma de fogo de Ângela não poderá ser imediatamente apreendida.', false),
  (3850498, 4, 'O ato cometido por Ângela poderá ser considerado forma de violência doméstica e familiar contra a mulher na modalidade violência moral.', true),
  (3850498, 5, 'Caso seja necessário que Raíssa se afaste do local de trabalho, não será assegurada a manutenção do vínculo trabalhista.', false),
  (3588587, 1, 'insulto, chantagem ou violação de intimidade da mulher.', false),
  (3588587, 2, 'destruição parcial de objetos e documentos pessoais da mulher.', false),
  (3588587, 3, 'ofensa à integridade ou saúde corporal da mulher.', false),
  (3588587, 4, 'calúnia, difamação ou injúria contra a mulher.', true),
  (3588587, 5, 'impedimento para que a mulher use métodos contraceptivos.', false),
  (3586559, 1, 'I e II, apenas.', false),
  (3586559, 2, 'II e III, apenas.', false),
  (3586559, 3, 'I, II e III.', true),
  (3586559, 4, 'I e III, apenas.', false),
  (3585297, 1, 'Violência psicológica e física.', false),
  (3585297, 2, 'Violência psicológica, patrimonial e moral.', true),
  (3585297, 3, 'Violência física, sexual e moral.', false),
  (3585297, 4, 'Violência patrimonial, sexual e emocional.', false),
  (3585297, 5, 'Violência patrimonial e física.', false),
  (3574305, 1, 'violência psicológica, sexual, patrimonial e emocional.', false),
  (3574305, 2, 'violência física, psicológica, sexual, patrimonial e moral.', true),
  (3574305, 3, 'violência física e psicológica, apenas.', false),
  (3574305, 4, 'violência física, sexual e moral, apenas.', false),
  (3574305, 5, 'violência física, psicológica, sexual, patrimonial, moral e religiosa.', false),
  (3564240, 1, 'A Lei nº 11.340/2006 não reconhece a violência doméstica e familiar como uma violação de direitos, mas apenas como um conflito de natureza privada.', false),
  (3564240, 2, 'A violência doméstica e familiar contra a mulher é uma questão exclusivamente penal, não relacionada aos direitos humanos.', false),
  (3564240, 3, 'A violência doméstica e familiar contra a mulher constitui uma das formas de violação dos direitos humanos.', true),
  (3564240, 4, 'A violência doméstica e familiar contra a mulher configura apenas infração administrativa, não sendo tratada como questão de direitos humanos.', false),
  (3543629, 1, 'João em uma crise de ciúmes quebrou o celular de Maria, objeto que tinha suas contas bancárias, utilizado também como instrumento de trabalho, por isto a ação dele foi considerada violência patrimonial.', true),
  (3543629, 2, 'João feriu Maria com arma branca (faca), mas não podia ser punido porque tem transtorno mental (disgnóstico de dependência etílica), assim foi sensibilizado por equipe multidisciplinar para realizar tratamento de saúde contra o vício em drogas (álcool).', false),
  (3543629, 3, 'João ameaçou Maria de morte por 02 vezes e em uma ocasião atentou contra sua vida, porém, como Maria dependia financeiramente de João, é vedado ao Juiz, determinar a medida de privação de liberdade, assim foi aplicado penas pecuniárias: doação de cestas básicas a comunidade carente e multas.', false),
  (3543629, 4, 'João praticou violência física contra Maria em local público, o ato foi considerado flagrante, diante disso foi conduzindo para a Delegacia, porém ao identificar que ele apresentava transtorno mental ( dependência em drogas lícitas), o agente público o encaminhou para os órgãos de assistência social para realizar o cadastro em programas assistenciais do governo federal, estadual e municipal.', false),
  (3543629, 5, 'Maria sofreu vários tipos de violência doméstica e para preservar sua integridade física e psicológica o Juiz aplicou a medida de proteção, afastando João de Maria, contudo assegurou a manutenção do vínculo trabalhista dele, uma vez que era o único provedor da família.', false),
  (3543432, 1, 'Mesmo sem vontade, Ana mantém relações sexuais com seu marido Carlos, porque ele cobra dela o cumprimento de seus deveres conjugais.', false),
  (3543432, 2, 'Após a separação conjugal, Paula começou a namorar Júlio. Seu ex-marido, Edson, fala para a família e amigos em comum, que Paula é prostituta e adúltera.', true),
  (3543432, 3, 'Bruno se apropriou do cartão e trocou a senha da conta bancária de Márcia, que agora precisa pedir dinheiro a ele e justificar todos os gastos domésticos que faz.', false),
  (3543432, 4, 'Lúcia está grávida de seu quarto filho e deseja fazer uma laqueadura de trompas, mas seu marido Olavo não concorda e não permite o uso de nenhum método contraceptivo.', false),
  (3543432, 5, 'Laura conseguiu se separar de seu marido Hugo, mas agora ele a persegue na porta do prédio, em seu local de trabalho, na academia, nas redes sociais e fazendo ligações telefônicas de diferentes números a qualquer hora.', false),
  (3528682, 1, 'Violência psicológica, social, fisiológica, patrimonial e sexual.', false),
  (3528682, 2, 'Violência econômica, social, emocional, patrimonial e sexual.', false),
  (3528682, 3, 'Violência psicológica, econômica, verbal, patrimonial e moral.', false),
  (3528682, 4, 'Violência econômica, social, fisiológica, patrimonial e sexual.', false),
  (3528682, 5, 'Violência física, psicológica, sexual, patrimonial e moral.', true),
  (3520358, 1, 'I, II e IV.', true),
  (3520358, 2, 'I, III e IV.', false),
  (3520358, 3, 'II, III, V.', false),
  (3520358, 4, 'III, IV, V.', false),
  (3520358, 5, 'II, IV e V', false),
  (3517979, 1, 'Física.', false),
  (3517979, 2, 'Psicológica.', false),
  (3517979, 3, 'Sexual.', false),
  (3517979, 4, 'Institucional.', true),
  (3517979, 5, 'Patrimonial.', false),
  (3500154, 1, 'Certo', true),
  (3500154, 2, 'Errado', false),
  (3497447, 1, 'A violência sexual, entendida como qualquer conduta que ofenda sua integridade ou saúde corporal.', false),
  (3497447, 2, 'A violência moral, entendida como qualquer conduta que configure calúnia, difamação ou injúria.', true),
  (3497447, 3, 'A violência patrimonial, entendida como qualquer conduta que lhe cause dano emocional e diminuição da autoestima ou que lhe prejudique e perturbe o pleno desenvolvimento ou que vise degradar ou controlar suas ações, comportamentos, crenças e decisões, mediante ameaça, constrangimento, humilhação, manipulação, isolamento, vigilância constante, perseguição contumaz, insulto, chantagem, violação de sua intimidade, ridicularização, exploração e limitação do direito de ir e vir ou qualquer outro meio que lhe cause prejuízo à saúde psicológica e à autodeterminação.', false),
  (3497447, 4, 'A violência psicológica, entendida como qualquer conduta que configure retenção, subtração, destruição parcial ou total de seus objetos, instrumentos de trabalho, documentos pessoais, bens, valores e direitos ou recursos econômicos, incluindo os destinados a satisfazer suas necessidades.', false),
  (3496113, 1, 'problema interno da família', false),
  (3496113, 2, 'relação familiar corriqueira', false),
  (3496113, 3, 'violência doméstica', true),
  (3496113, 4, 'mero litígio social', false),
  (3467391, 1, 'É forma de violência doméstica e familiar contra a mulher a violência moral, entendida como qualquer conduta que configure calúnia, difamação ou injúria.', true),
  (3467391, 2, 'A violência doméstica e familiar contra a mulher constitui uma das formas de violação dos direitos humanos em qualquer relação íntima de afeto, na qual o agressor não conviva e/ou não tenha convivido com a ofendida.', false),
  (3467391, 3, 'A política pública que visa coibir a violência doméstica e familiar contra a mulher far-se-á por meio de um conjunto articulado de ações da União, dos Estados, do Distrito Federal e dos Municípios, exceto de ações não governamentais.', false),
  (3467391, 4, 'As violências físicas e psicológicas são entendidas como qualquer conduta que configure retenção, subtração, destruição parcial ou total de seus objetos, instrumentos de trabalho, documentos pessoais, bens, valores e direitos ou recursos econômicos, incluindo os destinados a satisfazer suas necessidades.', false),
  (3464975, 1, 'Por entender possuir um instrumento adequado para a proteção de mulheres, o Brasil expressamente se recusou, no texto da Lei Maria da Penha, a ratificar a Convenção sobre a Eliminação de Todas as Formas de Violência contra a Mulher.', false),
  (3464975, 2, 'O chamado “requisito de coabitação”, pelo qual o agressor tem de estar residindo com a vítima, é requisito indispensável para a configuração de violência doméstica.', false),
  (3464975, 3, 'Ofender a saúde da mulher, embora sabidamente grave, não se enquadra em uma das formas de violência doméstica e familiar.', false),
  (3464975, 4, 'É possível que a configuração de violência doméstica e familiar contra a mulher se dê por omissão.', true),
  (3464975, 5, 'A Lei opta por enfatizar a independência dos órgãos e instituições e, por esse motivo, evita propor medidas de prevenção que sejam integradas.', false),
  (3459059, 1, 'Todas estão incorretas.', false),
  (3459059, 2, 'Todas estão corretas.', false),
  (3459059, 3, 'Apenas III está correta.', false),
  (3459059, 4, 'Apenas I e II estão corretas.', true),
  (3453660, 1, 'moral', false),
  (3453660, 2, 'física', false),
  (3453660, 3, 'psicológica', false),
  (3453660, 4, 'patrimonial', true),
  (3424637, 1, 'a violência física; a violência psicológica; a violência sexual; a violência patrimonial e a violência moral.', true),
  (3424637, 2, 'a violência afetiva; a violência psicológica; a violência sexual; a violência patrimonial e a violência moral.', false),
  (3424637, 3, 'a violência física; a violência psicológica; a violência sexual; a violência patrimonial e a violência imoral.', false),
  (3424637, 4, 'a violência física; a violência psicológica; a violência sexual; a violência matrimonial e a violência moral.', false),
  (3424637, 5, 'a violência física; a violência psicológica; a violência sexual; a violência matrimonial e a violência imoral.', false),
  (3407936, 1, 'Certo', true),
  (3407936, 2, 'Errado', false),
  (3379851, 1, 'Violência obstétrica.', false),
  (3379851, 2, 'Violência psicológica.', false),
  (3379851, 3, 'Violência física.', false),
  (3379851, 4, 'Violência sexual.', true),
  (3379851, 5, 'Violência moral.', false),
  (3379836, 1, 'Violência psicológica.', true),
  (3379836, 2, 'Violência de intimidação.', false),
  (3379836, 3, 'violência sexual.', false),
  (3379836, 4, 'Violência moral.', false),
  (3379836, 5, 'Violência de assédio.', false),
  (3375655, 1, 'Apenas psicológica, devido ao controle sobre suas ações e contatos.', false),
  (3375655, 2, 'Psicológica e moral, devido ao controle e à exposição pública.', true),
  (3375655, 3, 'Patrimonial e física, por limitar o uso de seus dispositivos eletrônicos pessoais.', false),
  (3375655, 4, 'Apenas moral, devido à ridicularização pública.', false),
  (3374318, 1, 'Certo', true),
  (3374318, 2, 'Errado', false),
  (3371310, 1, 'Namorado que impede/proíbe a namorada de usar métodos contraceptivos.', false),
  (3371310, 2, 'Ex-companheiro que coloca os filhos em risco e os utiliza para perpetuar violência contra a ex-companheira.', false),
  (3371310, 3, 'Mãe que, por meio de comportamentos abusivos, controla, humilha e isola sua filha, causando danos emocionais e psicológicos.', false),
  (3371310, 4, 'Chefe que, devido ao alto fluxo de trabalho, solicita que funcionárias realizem horas extras.', true),
  (3370534, 1, 'Violência patrimonial, pois o agressor retém o valor.', false),
  (3370534, 2, 'Violência moral, pois o agressor está agindo com conduta caluniosa.', true),
  (3370534, 3, 'Violência física, pois o agressor está agredindo a ofendida.', false),
  (3370534, 4, 'Violência psicológica, pois o agressor está ridicularizando a ofendida.', false),
  (3849975, 1, 'Não constitui forma de violência doméstica e familiar contra a mulher a violação moral, entendida como qualquer conduta que configure calúnia, difamação ou injúria.', false),
  (3849975, 2, 'Na hipótese da iminência da prática de violência doméstica e familiar contra a mulher, a autoridade policial que tomar conhecimento da ocorrência não poderá adotar, de imediato, as providências legais cabíveis.', false),
  (3849975, 3, 'Não há restrições à aplicação das disposições da Lei Maria da Penha de acordo com a orientação sexual da mulher.', true),
  (3849975, 4, 'Não configura violência doméstica a ação ou omissão baseada no gênero que lhe cause morte, lesão, sofrimento físico, sexual ou psicológico quando realizada em relação íntima de afeto sem que haja coabitação.', false),
  (3849975, 5, 'Não cabe à família criar as condições necessárias para o efetivo exercício do direito ao lazer da mulher.', false),
  (3366976, 1, 'A aplicação da Lei Maria da Penha depende da comprovação de que a vítima e o agressor possuíam vinculo matrimonial, sendo inaplicável em casos de relacionamentos informais ou encerrados.', false),
  (3366976, 2, 'A Lei Maria da Penha se limita a prever medidas de caráter penal contra os agressores, não abrangendo dispositivos voltados à prevenção da violência e à assistência às vitimas.', false),
  (3366976, 3, 'A Lei Maria da Penha pode ser aplicada da orientação sexual da vítima. independentemente bastando que a violência tenha ocorrido no âmbito doméstico, familiar ou de relação íntima de afeto.', true),
  (3366976, 4, 'As medidas protetivas de urgência previstas na Lei Maria da Penha somente podem ser concedidas após o início de um processo penal contra o agressor, não sendo admitida sua concessão de forma autônoma.', false),
  (3363055, 1, 'No âmbito da unidade doméstica, compreendida como o espaço de convívio permanente de pessoas, com ou sem vínculo familiar, inclusive as esporadicamente agregadas.', false),
  (3363055, 2, 'No âmbito da família, compreendida como a comunidade formada por indivíduos que são ou se consideram aparentados, unidos por laços naturais, por afinidade ou por vontade expressa.', false),
  (3363055, 3, 'No âmbito de situação de vulnerabilidade social e econômica, que se constituem violações de direitos humanos e sociais.', true),
  (3363055, 4, 'Em qualquer relação íntima de afeto, na qual o agressor conviva ou tenha convivido com a ofendida, independentemente de coabitação.', false),
  (3349908, 1, 'desrespeito.', false),
  (3349908, 2, 'humilhação.', false),
  (3349908, 3, 'discriminação.', false),
  (3349908, 4, 'ameaça.', false),
  (3349908, 5, 'injúria.', true),
  (3340738, 1, 'independe de orientação sexual', true),
  (3340738, 2, 'descaracteriza violência doméstica', false),
  (3340738, 3, 'considera que ambas estão em situação de igualdade', false),
  (3340738, 4, 'será pertinente em caso de diferença de compleição física', false),
  (3259252, 1, 'física / patrimonial', false),
  (3259252, 2, 'psicológica / patrimonial', true),
  (3259252, 3, 'moral / física', false),
  (3259252, 4, 'patrimonial / moral', false),
  (3259252, 5, 'psicológica / moral', false),
  (3238223, 1, 'Certo', false),
  (3238223, 2, 'Errado', true),
  (3237915, 1, 'Certo', true),
  (3237915, 2, 'Errado', false),
  (3824093, 1, 'Qualquer conduta que configure retenção, subtração, destruição parcial ou total de seus objetos, instrumentos de trabalho, documentos pessoais, bens, valores e direitos ou recursos econômicos.', false),
  (3824093, 2, 'Qualquer conduta que configure calúnia, difamação ou injúria.', true),
  (3824093, 3, 'Qualquer conduta que a constranja a presenciar, a manter ou a participar de relação sexual não desejada, mediante intimidação, ameaça, coação ou uso da força.', false),
  (3824093, 4, 'Qualquer conduta que lhe cause dano emocional e diminuição da autoestima ou que lhe prejudique e perturbe o pleno desenvolvimento ou que vise degradar ou controlar suas ações, comportamentos, crenças e decisões.', false),
  (3168457, 1, 'A Lei Maria da Penha é a única legislação no Brasil que trata da violência contra a mulher.', false),
  (3168457, 2, 'A violência doméstica é limitada apenas à agressão física e ao estupro, segundo a Lei Maria da Penha.', false),
  (3168457, 3, 'A Lei do Feminicídio foi sancionada em 2006 junto com a Lei Maria da Penha.', false),
  (3168457, 4, 'A Lei Maria da Penha, a Lei do Feminicídio, excluiu a morte de mulheres do rol de crimes hediondos e diminuiu a tolerância nesses casos.', false),
  (3168457, 5, 'A Lei Maria da Penha classifica a violência doméstica nas categorias de violência patrimonial, violência sexual, violência física, violência moral e violência psicológica.', true),
  (3168235, 1, 'V • V • F • V • V', false),
  (3168235, 2, 'V • V • F • F • V', false),
  (3168235, 3, 'V • F • V • V • F', true),
  (3168235, 4, 'F • V • V • F • V', false),
  (3168235, 5, 'F • V • F • V • F', false),
  (3167673, 1, 'Mesmo sem vontade, Ana mantém relações sexuais com seu marido José porque ele cobra dela o cumprimento de seus deveres conjugais.', false),
  (3167673, 2, 'Após a separação conjugal, Paula começou a namorar Júlio. Seu ex-marido, Edson, fala para a família e para os amigos em comum que Paula é prostituta e adúltera.', true),
  (3167673, 3, 'Bruno se apropriou do cartão e trocou a senha da conta bancária de Márcia, que agora precisa pedir dinheiro a ele e justificar todos os gastos domésticos que faz.', false),
  (3167673, 4, 'Lúcia está grávida de seu quarto filho e deseja fazer uma laqueadura de trompas, mas seu marido Olavo não concorda e não permite o uso de nenhum método contraceptivo.', false),
  (3167673, 5, 'Laura conseguiu se separar de seu marido Hugo, mas agora ele a persegue na porta do prédio, em seu local de trabalho, na academia, nas redes sociais e fazendo ligações telefônicas de diferentes números a qualquer hora.', false),
  (3164311, 1, 'a violência de que trata a Lei Maria da Penha deve ocorrer no âmbito da família, compreendida como a comunidade formada por indivíduos unidos por laços naturais e que coabitem entre si por vontade expressa, ou seja, entre marido e mulher.', false),
  (3164311, 2, 'a lei exige comprovação de que a violência psicológica tenha resultado no mundo fático, com prejuízos efetivos à saúde física da mulher, sob pena de esta incorrer em denunciação caluniosa.', false),
  (3164311, 3, 'a violência moral, ou seja, aquela que constranja a mulher a presenciar relação sexual, sem que dela participe, é causa de atipicidade, se não houver cerceamento dos direitos sexuais da mulher.', false),
  (3164311, 4, 'configura violência doméstica e familiar contra a mulher qualquer ação ou omissão baseada no gênero que lhe cause morte, lesão, sofrimento físico, sexual ou psicológico e dano moral ou patrimonial em qualquer relação íntima de afeto, na qual o agressor conviva ou tenha convivido com a ofendida, independentemente de coabitação.', true),
  (3169874, 1, 'Ofender a integridade física.', false),
  (3169874, 2, 'Submeter a vítima à manipulação.', false),
  (3169874, 3, 'Cometer difamação.', true),
  (3169874, 4, 'Submeter o acusado a isolamento.', false),
  (3169874, 5, 'Obrigar o acusado ao matrimônio.', false),
  (3171586, 1, 'Certo', true),
  (3171586, 2, 'Errado', false),
  (3163946, 1, 'qualquer conduta que lhe cause dano emocional e diminuição da autoestima ou que lhe prejudique e perturbe o pleno desenvolvimento ou que vise degradar ou controlar suas ações, comportamentos, crenças e decisões, mediante ameaça, constrangimento, humilhação, manipulação, isolamento, vigilância constante, perseguição contumaz, insulto, chantagem, violação de sua intimidade, ridicularização, exploração e limitação do direito de ir e vir ou qualquer outro meio que lhe cause prejuízo à saúde psicológica e à autodeterminação.', false),
  (3163946, 2, 'qualquer conduta que configure retenção, subtração, destruição parcial ou total de seus objetos, instrumentos de trabalho, documentos pessoais, bens, valores e direitos ou recursos econômicos, incluindo os destinados a satisfazer suas necessidades.', false),
  (3163946, 3, 'qualquer conduta que a constranja a presenciar, a manter ou a participar de relação sexual não desejada, mediante intimidação, ameaça, coação ou uso da força; que a induza a comercializar ou a utilizar, de qualquer modo, a sua sexualidade, que a impeça de usar qualquer método contraceptivo ou que a force ao matrimônio, à gravidez, ao aborto ou à prostituição, mediante coação, chantagem, suborno ou manipulação; ou que limite ou anule o exercício de seus direitos sexuais e reprodutivos.', false),
  (3163946, 4, 'qualquer conduta que configure calúnia, difamação ou injúria.', false),
  (3163946, 5, 'qualquer conduta que ofenda sua integridade ou saúde corporal.', true),
  (3163528, 1, 'qualquer conduta que configure retenção, subtração, destruição parcial ou total de seus objetos, instrumentos de trabalho, documentos pessoais, bens, valores e direitos ou recursos econômicos, incluindo os destinados a satisfazer suas necessidades.', false),
  (3163528, 2, 'qualquer conduta que ofenda sua integridade ou saúde corporal.', false),
  (3163528, 3, 'qualquer conduta que lhe cause dano emocional e diminuição da autoestima ou que lhe prejudique e perturbe o pleno desenvolvimento ou que vise degradar ou controlar suas ações, comportamentos, crenças e decisões, mediante ameaça, constrangimento, humilhação, manipulação, isolamento, vigilância constante, perseguição contumaz, insulto, chantagem, violação de sua intimidade, ridicularização, exploração e limitação do direito de ir e vir ou qualquer outro meio que lhe cause prejuízo à saúde psicológica e à autodeterminação.', false),
  (3163528, 4, 'qualquer conduta que a constranja a presenciar, a manter ou a participar de relação sexual não desejada, mediante intimidação, ameaça, coação ou uso da força; que a induza a comercializar ou a utilizar, de qualquer modo, a sua sexualidade, que a impeça de usar qualquer método contraceptivo ou que a force ao matrimônio, à gravidez, ao aborto ou à prostituição, mediante coação, chantagem, suborno ou manipulação; ou que limite ou anule o exercício de seus direitos sexuais e reprodutivos.', true),
  (3163528, 5, 'qualquer conduta que configure calúnia, difamação ou injúria.', false),
  (3178706, 1, 'Violência sexual.', false),
  (3178706, 2, 'Violência psicológica.', false),
  (3178706, 3, 'Violência procedimental.', true),
  (3178706, 4, 'Violência patrimonial.', false),
  (3135241, 1, 'ofenda a integridade ou a saúde do corpo, como bater ou espancar, empurrar, atirar objetos na direção da mulher, sacudir, chutar, apertar, queimar, cortar ou ferir.', false),
  (3135241, 2, 'desonre a mulher diante da sociedade com mentiras ou ofensas. É, também, acusá-la publicamente de ter praticado crime. São exemplos: xingar diante dos amigos, acusar de algo que não fez e falar coisas que não são verdades sobre ela para os outros.', false),
  (3135241, 3, 'cause danos emocionais e diminuição da autoestima, ou que visem degradar ou controlar seus comportamentos, crenças e decisões; mediante ameaça, constrangimento, humilhação.', false),
  (3135241, 4, 'configure retenção, subtração, destruição parcial ou total de seus objetos, instrumentos de trabalho, documentos pessoais, bens, valores e direitos ou recursos econômicos, incluindo os destinados a satisfazer suas necessidades.', true),
  (3135241, 5, 'constranja a presenciar, a manter ou a participar de relação sexual não desejada, mediante intimidação, ameaça, coação ou uso da força.', false),
  (3179836, 1, 'A violência doméstica pode ocorrer em qualquer núcleo familiar.', false),
  (3179836, 2, 'As mulheres idosas e religiosas também sofrem violência doméstica e familiar.', false),
  (3179836, 3, 'As mulheres da comunidade LGBTQIA+ também sofrem violência doméstica e familiar.', false),
  (3179836, 4, 'As mulheres que sofrem violência patrimonial são as que possuem maiores recursos financeiros.', true),
  (3126303, 1, 'a violência financeira.', false),
  (3126303, 2, 'a violência anímica.', false),
  (3126303, 3, 'a violência patrimonial.', true),
  (3126303, 4, 'a violência corruptiva.', false),
  (3125995, 1, 'qualquer conduta que configure calúnia, difamação ou injúria.', true),
  (3125995, 2, 'qualquer conduta que configure retenção, subtração, destruição parcial ou total de seus objetos, instrumentos de trabalho, documentos pessoais, bens, valores e direitos ou recursos econômicos, incluindo os destinados a satisfazer suas necessidades.', false),
  (3125995, 3, 'qualquer conduta que a constranja a presenciar, a manter ou a participar de relação sexual não desejada, mediante ameaça ou que a force ao matrimônio, à gravidez, ao aborto ou à prostituição, mediante coação, chantagem, suborno ou manipulação.', false),
  (3125995, 4, 'entendida como qualquer conduta que perturbe o pleno desenvolvimento ou limite o direito de ir e vir ou qualquer outro meio que lhe cause prejuízo à autogestação.', false),
  (3124680, 1, 'Apenas a violência física, entendida como qualquer conduta que ofenda sua integridade ou saúde corporal.', false),
  (3124680, 2, 'As violências física, psicológica, sexual, patrimonial e moral.', true),
  (3124680, 3, 'Somente as violências física e sexual.', false),
  (3124680, 4, 'As violências física, psicológica, sexual, financeira, política e econômica.', false),
  (3181496, 1, 'Moral e econômica.', false),
  (3181496, 2, 'Moral e psicológica.', false),
  (3181496, 3, 'Patrimonial e moral.', true),
  (3181496, 4, 'Patrimonial e psicológica.', false),
  (3105580, 1, 'não se trata de hipótese de violência contra a mulher pois Helena é trans.', false),
  (3105580, 2, 'Helena foi vítima de violência psicológica praticada pelo companheiro.', true),
  (3105580, 3, 'como Murilo é um homem trans seu comportamento não se caracteriza como violência de gênero.', false),
  (3105580, 4, 'trata-se de hipótese de violência física perpetrada por Murilo contra Helena.', false),
  (3105580, 5, 'como Murilo é biologicamente do sexo feminino pode-se considerar que ele foi vítima de violência psicológica.', false),
  (3105199, 1, 'qualquer conduta que ofenda sua integridade ou saúde corporal.', false),
  (3105199, 2, 'qualquer conduta que a exponha, por meio de relações sexuais ou ato libidinoso, a contágio de moléstia venérea.', false),
  (3105199, 3, 'qualquer conduta que cause dano emocional e diminuição da autoestima ou que lhe prejudique e perturbe o pleno desenvolvimento ou que vise degradar ou controlar suas ações, comportamentos, crenças e decisões, mediante ameaça, constrangimento, humilhação, manipulação, isolamento, vigilância constante e perseguição.', false),
  (3105199, 4, 'qualquer conduta que configure calúnia, difamação ou injúria.', true),
  (3199401, 1, 'Certo', true),
  (3199401, 2, 'Errado', false),
  (3097617, 1, 'psicológica', false),
  (3097617, 2, 'patrimonial', false),
  (3097617, 3, 'moral', true),
  (3097617, 4, 'física', false),
  (3097103, 1, 'Violência física.', false),
  (3097103, 2, 'Violência sexual.', false),
  (3097103, 3, 'Violência psicológica.', false),
  (3097103, 4, 'Violência institucional.', true),
  (3223384, 1, 'física, psicológica e autoprovocada.', false),
  (3223384, 2, 'física, sexual e homicídio.', false),
  (3223384, 3, 'física, psicológica, sexual, patrimonial e moral.', true),
  (3223384, 4, 'física, psicológica, sexual, moral e autoprovocada.', false),
  (3096883, 1, 'Moral.', false),
  (3096883, 2, 'Patrimonial.', true),
  (3096883, 3, 'Física.', false),
  (3096883, 4, 'Sexual.', false),
  (3229673, 1, 'moral.', true),
  (3229673, 2, 'psicológica.', false),
  (3229673, 3, 'patrimonial.', false),
  (3229673, 4, 'física.', false),
  (3278936, 1, 'Uma das formas de violação dos direitos humanos.', true),
  (3278936, 2, 'Iminência ou prática que viola preceitos institucionais.', false),
  (3278936, 3, 'Atentado à justiça.', false),
  (3278936, 4, 'Proibição temporária de direitos.', false),
  (3278936, 5, 'Violação à Constituição Federal de 1988.', false),
  (3279521, 1, 'Qualquer conduta que ofenda sua integridade ou saúde corporal.', false),
  (3279521, 2, 'Qualquer conduta que configure calúnia, difamação ou injúria.', true),
  (3279521, 3, 'Qualquer conduta que lhe cause dano emocional e diminuição da autoestima ou que lhe prejudique e perturbe o pleno desenvolvimento ou que vise degradar ou controlar suas ações, comportamentos, crenças e decisões.', false),
  (3279521, 4, 'Qualquer conduta que a constranja a presenciar, a manter ou a participar de relação sexual não desejada, mediante intimidação, ameaça, coação ou uso da força.', false),
  (3279521, 5, 'Qualquer conduta que configure retenção, subtração, destruição parcial ou total de seus objetos, instrumentos de trabalho, documentos pessoais, bens, valores e direitos ou recursos econômicos, incluindo os destinados a satisfazer suas necessidades.', false),
  (3299190, 1, 'Moral.', false),
  (3299190, 2, 'Patrimonial.', true),
  (3299190, 3, 'Física.', false),
  (3299190, 4, 'Psicológica.', false),
  (3094833, 1, 'Direitos do trabalhado.', false),
  (3094833, 2, 'Direitos humanos.', true),
  (3094833, 3, 'Direitos de seguridade social.', false),
  (3094833, 4, 'Direitos da cultura.', false),
  (3315926, 1, 'Física, psicológica, sexual, patrimonial e moral.', true),
  (3315926, 2, 'Física, mental, sexual, dos bens e moral.', false),
  (3315926, 3, 'Física, mental, sexual, patrimonial e religiosa.', false),
  (3315926, 4, 'Física, psicológica, sexual, dos bens e moral.', false),
  (3315926, 5, 'Física, psicológica, sexual, patrimonial e religiosa.', false),
  (3322429, 1, 'Violência patrimonial', false),
  (3322429, 2, 'Violência moral', false),
  (3322429, 3, 'Violência psicológica', false),
  (3322429, 4, 'Violência cognitiva', true),
  (3324743, 1, 'Qualquer conduta que ofenda sua integridade ou saúde corporal.', false),
  (3324743, 2, 'Qualquer conduta que lhe cause dano emocional e diminuição da autoestima ou que lhe prejudique e perturbe o pleno desenvolvimento.', false),
  (3324743, 3, 'Qualquer conduta que a constranja a presenciar, a manter ou a participar de relação sexual não desejada, mediante intimidação, ameaça, coação ou uso da força.', false),
  (3324743, 4, 'Qualquer conduta que configure calúnia, difamação ou injúria.', true),
  (3324743, 5, 'Qualquer conduta que configure retenção, subtração, destruição parcial ou total de seus objetos.', false),
  (3085547, 1, 'espiritual.', false),
  (3085547, 2, 'intelectual.', false),
  (3085547, 3, 'comunitária.', false),
  (3085547, 4, 'moral.', true),
  (3085547, 5, 'familiar.', false),
  (3324785, 1, 'Dos direitos fundamentais.', false),
  (3324785, 2, 'Dos direitos humanos.', true),
  (3324785, 3, 'Dos direitos constitucionais.', false),
  (3324785, 4, 'Dos direitos difusos.', false),
  (3324785, 5, 'Dos direitos institucionais.', false),
  (3083884, 1, 'sexual e psicológica.', false),
  (3083884, 2, 'patrimonial e psicológica.', true),
  (3083884, 3, 'patrimonial e física.', false),
  (3083884, 4, 'moral e física.', false),
  (3083884, 5, 'moral e psicológica.', false),
  (3324796, 1, 'Violência física.', true),
  (3324796, 2, 'Violência moral.', false),
  (3324796, 3, 'Violência sexual.', false),
  (3324796, 4, 'Violência patrimonial.', false),
  (3324796, 5, 'Violência psicológica.', false),
  (3338000, 1, 'física', false),
  (3338000, 2, 'sexual', false),
  (3338000, 3, 'psicológica', false),
  (3338000, 4, 'patrimonial', true),
  (3077866, 1, 'unidade doméstica, compreendida como o espaço de convívio permanente de pessoas, obrigatoriamente com vínculo familiar.', false),
  (3077866, 2, 'família, compreendida como o espaço de convívio permanente de pessoas, com ou sem vínculo familiar, inclusive as esporadicamente agregadas.', false),
  (3077866, 3, 'unidade doméstica, compreendida como o espaço de convívio temporário de pessoas, com ou sem vínculo familiar, inclusive as esporadicamente agregadas.', false),
  (3077866, 4, 'família, compreendida como o espaço de convívio permanente de pessoas, obrigatoriamente com vínculo familiar.', false),
  (3077866, 5, 'unidade doméstica, compreendida como o espaço de convívio permanente de pessoas, com ou sem vínculo familiar, inclusive as esporadicamente agregadas.', true),
  (3073912, 1, 'Quando a violência ocorre no contexto da unidade doméstica, compreendida como o espaço de convívio permanente de pessoas, desde que tenha o vínculo familiar.', false),
  (3073912, 2, 'Quando a violência ocorre no contexto da unidade doméstica, uma comunidade formada especificamente por pessoas que tenham laços consanguíneos ou que sejam unidas por laços naturais.', false),
  (3073912, 3, 'Quando a violência ocorre em qualquer relação intima de afeto, na qual o agressor esteja convivendo com a pessoa ofendida, desde que se comprove a coabitação.', false),
  (3073912, 4, 'Quando a violência ocorre no contexto da unidade doméstica, independente de orientação sexual.', true),
  (3073912, 5, 'Quando houver qualquer conduta que configure calúnia, difamação ou injúria será considerada como violência psicológica.', false),
  (3392823, 1, 'Violência psicológica e física.', false),
  (3392823, 2, 'Violência psicológica e patrimonial.', true),
  (3392823, 3, 'Violência psicológica e moral.', false),
  (3392823, 4, 'Violência moral e patrimonial.', false),
  (3415068, 1, 'Unidade doméstica.', true),
  (3415068, 2, 'Família.', false),
  (3415068, 3, 'Relação institucional.', false),
  (3415068, 4, 'Relação intrafamiliar e estrutural.', false),
  (3072118, 1, 'Violência Física.', false),
  (3072118, 2, 'Violência Institucional.', false),
  (3072118, 3, 'Violência Patrimonial.', true),
  (3072118, 4, 'Violência Moral.', false),
  (3072118, 5, 'Violência Verbal.', false),
  (3417429, 1, '1.c, 2.a, 3.b.', true),
  (3417429, 2, '1.b, 2.c, 3.a.', false),
  (3417429, 3, '1.b, 2.a, 3.c.', false),
  (3417429, 4, '1.a, 2.b, 3.c.', false),
  (2759639, 1, 'o quadro é indicativo de violência moral praticada por Ivan em face da companheira.', false),
  (2759639, 2, 'a situação descreve padrão de violência psicológica praticada por Ivan contra a mulher.', true),
  (2759639, 3, 'de acordo com a descrição, Maristela está sendo submetida a violência sexual por Ivan.', false),
  (2759639, 4, 'Ivan está cometendo violência patrimonial contra a companheira.', false),
  (2759639, 5, 'não há indícios de violência doméstica contra a mulher no caso descrito.', false),
  (2770925, 1, 'I e II apenas', false),
  (2770925, 2, 'I e IV apenas', false),
  (2770925, 3, 'II e IV apenas', true),
  (2770925, 4, 'II e III apenas', false),
  (2770925, 5, 'III e IV apenas', false),
  (2789972, 1, 'Apenas os itens I, II e III estão certos.', false),
  (2789972, 2, 'Apenas os itens I, II e IV estão certos.', false),
  (2789972, 3, 'Apenas os itens I, III e IV estão certos.', false),
  (2789972, 4, 'Apenas os itens II, III e IV estão certos.', false),
  (2789972, 5, 'Todos os itens estão certos.', true),
  (3449398, 1, 'física.', false),
  (3449398, 2, 'psicológica.', true),
  (3449398, 3, 'moral.', false),
  (3449398, 4, 'patrimonial.', false),
  (3055885, 1, 'I e III, apenas.', false),
  (3055885, 2, 'I e II, apenas.', true),
  (3055885, 3, 'II, apenas.', false),
  (3055885, 4, 'I, II e III.', false),
  (3055293, 1, 'Somente os itens I e II.', false),
  (3055293, 2, 'Somente os itens I e III.', true),
  (3055293, 3, 'Somente os itens II e III.', false),
  (3055293, 4, 'Todos os itens.', false),
  (3050257, 1, 'a violência contra a mulher só acontece em uma relação marital, não sendo possível em um namoro.', false),
  (3050257, 2, 'Maurício cometeu violência moral contra a namorada pois a humilhou diante dos amigos.', false),
  (3050257, 3, 'Paula foi vítima de violência psicológica cometida pelo namorado.', true),
  (3050257, 4, 'Paula foi submetida a dinâmica que se configura como violência física pelo namorado.', false),
  (3050257, 5, 'o namorado cometeu violência psicológica porque caluniou e difamou a namorada.', false),
  (3039026, 1, 'Física.', false),
  (3039026, 2, 'Moral.', true),
  (3039026, 3, 'Psicológica.', false),
  (3039026, 4, 'Sexual.', false),
  (3039026, 5, 'Patrimonial.', false),
  (3031784, 1, 'C - E - C.', true),
  (3031784, 2, 'E - C - E.', false),
  (3031784, 3, 'C - C - C.', false),
  (3031784, 4, 'E - E - E.', false),
  (2812702, 1, 'Certo', false),
  (2812702, 2, 'Errado', true),
  (3021691, 1, 'No âmbito da unidade doméstica, compreendida como o espaço de convívio permanente de pessoas, com ou sem vínculo familiar, inclusive as esporadicamente agregadas.', false),
  (3021691, 2, 'Em qualquer relação íntima de afeto, na qual o agressor conviva ou tenha convivido com a ofendida, independentemente de coabitação.', false),
  (3021691, 3, 'As relações pessoais dependem de orientação sexual.', true),
  (3021691, 4, 'No âmbito da família, compreendida como a comunidade formada por indivíduos que são ou se consideram aparentados, unidos por laços naturais, por afinidade ou por vontade expressa.', false),
  (3014724, 1, '2 - 1 - 3.', true),
  (3014724, 2, '1 - 3 - 2.', false),
  (3014724, 3, '2 - 3 - 1.', false),
  (3014724, 4, '3 - 2 - 1.', false),
  (3007260, 1, '1) Violência moral; 2) Violência espiritual; 3) Violência psicológica; e 4) Violência parental.', false),
  (3007260, 2, '1) Violência sentimental; 2) Violência criminosa; 3) Violência injuriosa; e 4) Violência transpessoal.', false),
  (3007260, 3, '1) Violência psicológica; 2) Violência sexual; 3) Violência moral; e 4) Violência patrimonial.', true),
  (3007260, 4, '1) Violência virtual; 2) Violência militar; 3) Violência profissional; e 4) Violência civil.', false),
  (3509833, 1, 'Apenas no item I.', false),
  (3509833, 2, 'Apenas no item III.', false),
  (3509833, 3, 'Apenas nos itens II e III.', false),
  (3509833, 4, 'Em todos os itens.', true),
  (2826549, 1, 'A asserção I é uma proposição falsa, e a II é uma proposição verdadeira.', false),
  (2826549, 2, 'As asserções I e II são proposições verdadeiras, e a II é um complemento da I.', false),
  (2826549, 3, 'A asserção I é uma proposição verdadeira, e a II é uma proposição falsa.', false),
  (2826549, 4, 'As asserções I e II são proposições falsas.', true),
  (2826549, 5, 'As asserções I e II são proposições verdadeiras, mas a II não é um complemento da I.', false),
  (2826587, 1, 'A legislação de violência doméstica abrange apenas casos de agressões físicas, não se aplica aos danos morais e psicológicos.', false),
  (2826587, 2, 'Para ser considerado violência doméstica, é necessário que o agressor e a vítima estejam casados legalmente.', false),
  (2826587, 3, 'A definição legal de violência doméstica não inclui situações em que o agressor e a vítima tenham convivido no passado.', false),
  (2826587, 4, 'A legislação de violência doméstica só reconhece casos de violência sexual, excluindo outras formas de agressão.', false),
  (2826587, 5, 'Configura-se violência doméstica e familiar contra a mulher qualquer ação ou omissão baseada no gênero que lhe cause morte, lesão, sofrimento físico, sexual ou psicológico e dano moral ou patrimonial, em qualquer relação íntima de afeto, na qual o agressor conviva ou tenha convivido com a ofendida, independentemente de coabitação.', true),
  (3532980, 1, 'em qualquer âmbito que configure calúnia, difamação ou injúria, enquanto violência patrimonial.', false),
  (3532980, 2, 'no âmbito da família, compreendida como o espaço de convívio permanente de pessoas, com ou sem vínculo familiar, inclusive as esporadicamente agregadas.', false),
  (3532980, 3, 'no âmbito da unidade doméstica, compreendida como a comunidade formada por indivíduos que são ou se consideram aparentados, unidos por laços naturais, por afinidade ou por vontade expressa.', false),
  (3532980, 4, 'em qualquer relação íntima de afeto, na qual o agressor conviva ou tenha convivido com a ofendida, independentemente de coabitação.', true),
  (3532980, 5, 'em qualquer âmbito que configure conduta que lhe cause dano emocional e diminuição da autoestima ou que lhe prejudique e perturbe o pleno desenvolvimento, enquanto violência física.', false),
  (3575952, 1, 'Qualquer conduta que configure retenção, subtração, destruição parcial ou total de seus objetos, instrumentos de trabalho, documentos pessoais, bens, valores e direitos ou recursos econômicos, incluindo os destinados a satisfazer suas necessidades.', false),
  (3575952, 2, 'Qualquer conduta que configure calúnia, difamação ou injúria.', true),
  (3575952, 3, 'Qualquer conduta que a constranja a presenciar, a manter ou a participar de relação sexual não desejada, mediante intimidação, ameaça, coação ou uso da força; que a induza a comercializar ou a utilizar, de qualquer modo, a sua sexualidade, que a impeça de usar qualquer método contraceptivo ou que a force ao matrimônio, à gravidez, ao aborto ou à prostituição, mediante coação, chantagem, suborno ou manipulação; ou que limite ou anule o exercício de seus direitos sexuais e reprodutivos.', false),
  (3575952, 4, 'Qualquer conduta que ofenda sua integridade ou saúde corporal.', false),
  (2983066, 1, 'patrimonial.', false),
  (2983066, 2, 'psicológica.', false),
  (2983066, 3, 'sexual.', false),
  (2983066, 4, 'moral.', true),
  (2983066, 5, 'física.', false),
  (2983038, 1, 'Certo', true),
  (2983038, 2, 'Errado', false),
  (2983032, 1, 'Certo', true),
  (2983032, 2, 'Errado', false),
  (3595916, 1, 'A asserção I é uma proposição verdadeira, e a II é uma proposição falsa.', true),
  (3595916, 2, 'A asserção I é uma proposição falsa, e a II é uma proposição verdadeira.', false),
  (3595916, 3, 'As asserções I e II são proposições verdadeiras, e a II é uma justificativa da I.', false),
  (3595916, 4, 'As asserções I e II são proposições verdadeiras, mas a II não é uma justificativa da I.', false),
  (3595916, 5, 'As asserções I e II são proposições falsas.', false),
  (2968027, 1, 'violência psicológica.', true),
  (2968027, 2, 'violência imoral.', false),
  (2968027, 3, 'violência matrimonial.', false),
  (2968027, 4, 'violência ortopédica.', false),
  (3595917, 1, 'Sexual.', false),
  (3595917, 2, 'Afetiva.', false),
  (3595917, 3, 'Psicológica.', false),
  (3595917, 4, 'Patrimonial.', true),
  (3595917, 5, 'Moral.', false),
  (3596067, 1, 'Emocional.', false),
  (3596067, 2, 'Patrimonial.', false),
  (3596067, 3, 'Física.', true),
  (3596067, 4, 'Afetiva.', false),
  (3596067, 5, 'Sexual.', false),
  (2966706, 1, 'Qualquer conduta que envolva violação de intimidação, como exposição pública de aspectos privados da vítima.', false),
  (2966706, 2, 'A violência que impede a mulher de usar métodos contraceptivos, forçando-a ao matrimônio, à gravidez, ao aborto ou à prostituição.', false),
  (2966706, 3, 'A conduta que causa dano emocional e diminuição da autoestima, controla suas ações, comportamentos, opiniões e decisões, por meio de ameaça, constrangimento, humilhação, dentre outros.', true),
  (2966706, 4, 'Qualquer conduta que configure retenção, subtração ou destruição parcial ou total de seus objetos, instrumentos de trabalho, documentos pessoais, bens, valores e direitos ou recursos econômicos.', false),
  (3630576, 1, 'Psicológica.', false),
  (3630576, 2, 'Física.', false),
  (3630576, 3, 'Sexual.', true),
  (3630576, 4, 'Patrimonial.', false),
  (3630576, 5, 'Moral.', false),
  (2962308, 1, '1 - 1 - 2 - 3;', false),
  (2962308, 2, '3 - 1 - 1 - 2;', true),
  (2962308, 3, '3 - 1 - 2 - 3;', false),
  (2962308, 4, '2 - 1 - 2 - 3;', false),
  (2962308, 5, '1 - 3 - 3 - 2.', false),
  (3630969, 1, 'física', true),
  (3630969, 2, 'espiritual', false),
  (3630969, 3, 'corporal', false),
  (3630969, 4, 'moral', false),
  (3630969, 5, 'psicológica', false),
  (2955765, 1, 'A violência física é entendida como qualquer conduta que ofenda a integridade ou a saúde corporal.', false),
  (2955765, 2, 'A violência patrimonial é entendida como qualquer conduta que configure calúnia, difamação ou injúria.', true),
  (2955765, 3, 'A violência doméstica e familiar contra a mulher constitui uma das formas de violação dos direitos humanos.', false),
  (2955765, 4, 'Configura como violência doméstica e familiar contra a mulher qualquer ação ou omissão baseada no gênero que lhe cause morte, lesão, sofrimento físico, sexual ou psicológico e dano moral ou patrimonial.', false),
  (3682521, 1, 'II e III.', false),
  (3682521, 2, 'III.', false),
  (3682521, 3, 'II.', false),
  (3682521, 4, 'I.', false),
  (3682521, 5, 'IV.', true),
  (2955256, 1, 'A prática de crime ou contravenção penal contra a mulher. com violência ou grave ameaça no ambiente doméstico, impossibilita a aplicação de pena de multa isoladamente, mas não impede a substituição da pena privativa de liberdade por restritiva de direitos.', false),
  (2955256, 2, 'Para a configuração da violência doméstica e familiar prevista no Artigo 5º. exige-se a coabitação entre autor e vitima.', false),
  (2955256, 3, 'O fato de a vitima ser figura pública renomada afasta a competência .do Juizado de Violência Doméstica para processar e Julgar o delito em razão da ausência de vulnerabilidade', false),
  (2955256, 4, 'A Lei Maria da Penha pode incidir na agressão perpetrada pelo irmão contra a irmã na hipótese de violência praticada no âmbito familiar', true),
  (2955256, 5, 'É possível a fixação de valor mínimo indenizatório por danos morais em favor da vítima de violência doméstica desde que haja instrução probatória para esse fim e seja especificada a quantia. em pedido formulado pela acusação ou pela parte ofendida', false),
  (2941057, 1, 'I e III apenas.', false),
  (2941057, 2, 'I e II apenas.', true),
  (2941057, 3, 'III apenas.', false),
  (2941057, 4, 'II e III apenas', false),
  (2941057, 5, 'I, II e III.', false),
  (2847969, 1, 'São consideradas formas de violência doméstica e familiar contra a mulher a psicológica, a sexual, a física, a moral e a patrimonial.', true),
  (2847969, 2, 'A violência doméstica e familiar cometida contra a mulher não pode ser considerada violação aos direitos humanos.', false),
  (2847969, 3, 'A política pública que visa coibir a violência doméstica e familiar contra a mulher deverá ser realizada apenas pelos municípios.', false),
  (2847969, 4, 'A violência moral é entendida como qualquer conduta que ofenda a integridade física da mulher.', false),
  (2847969, 5, 'O Ministério Público não poderá intervir nos processos judiciais que envolvam violência doméstica e familiar contra a mulher.', false),
  (2932376, 1, 'Certo', false),
  (2932376, 2, 'Errado', true),
  (2932194, 1, 'Certo', false),
  (2932194, 2, 'Errado', true),
  (2932188, 1, 'Certo', false),
  (2932188, 2, 'Errado', true),
  (2847886, 1, 'Violência procedimental.', false),
  (2847886, 2, 'Violência amiga.', false),
  (2847886, 3, 'Violência governamental.', false),
  (2847886, 4, 'Violência institucional.', false),
  (2847886, 5, 'Violência sexual.', true),
  (2924320, 1, 'Como se trata de casal homoafetivo não é possível caracterizar a violência contra a mulher.', false),
  (2924320, 2, 'A conduta de Camila é caracterizada como violência doméstica e familiar contra a mulher.', true),
  (2924320, 3, 'A mera altercação verbal não constitui forma de violência doméstica.', false),
  (2924320, 4, 'Como Camila é alcoolista e estava em estado alterado de consciência não se caracteriza o crime.', false),
  (2924320, 5, 'Camila é incapaz para todos os efeitos de direito em função de sua dependência do álcool.', false),
  (2919563, 1, 'Violência física, entendida como qualquer conduta que lhe cause dano emocional e diminuição da autoestima, que lhe prejudique e perturbe o pleno desenvolvimento, que vise degradar ou controlar suas ações, comportamentos, crenças e decisões, mediante ameaça, constrangimento, humilhação, manipulação, isolamento, vigilância constante, perseguição contumaz, insulto, chantagem, violação de sua intimidade, ridicularização, exploração e limitação do direito de ir e vir, ou qualquer outro meio que lhe cause prejuízo à saúde psicológica e à autodeterminação.', false),
  (2919563, 2, 'Violência psicológica entendida como qualquer conduta que ofenda sua integridade ou saúde corporal.', false),
  (2919563, 3, 'A violência patrimonial, entendida como qualquer conduta que configure calúnia, difamação ou injúria.', false),
  (2919563, 4, 'Violência sexual, entendida como qualquer conduta que a constranja a presenciar, a manter ou a participar de relação sexual não desejada, mediante intimidação, ameaça, coação ou uso da força; que a induza a comercializar ou a utilizar, de qualquer modo, a sua sexualidade, que a impeça de usar qualquer método contraceptivo ou que a force ao matrimônio, à gravidez, ao aborto ou à prostituição, mediante coação, chantagem, suborno ou manipulação; ou que limite ou anule o exercício de seus direitos sexuais e reprodutivos;', true),
  (2919563, 5, 'Violência moral, entendida como qualquer conduta que configure retenção, subtração, destruição parcial ou total de seus objetos, instrumentos de trabalho, documentos pessoais, bens, valores e direitos ou recursos econômicos, incluindo os destinados a satisfazer suas necessidades.', false),
  (2910137, 1, 'moral na forma de difamação;', true),
  (2910137, 2, 'psicológica na forma de calúnia;', false),
  (2910137, 3, 'virtual na forma de cyberbullying;', false),
  (2910137, 4, 'patrimonial na forma de controle de gastos;', false),
  (2910137, 5, 'de gênero na forma de violação da privacidade.', false),
  (2904890, 1, 'sexual.', false),
  (2904890, 2, 'moral.', true),
  (2904890, 3, 'patrimonial.', false),
  (2904890, 4, 'familiar.', false),
  (2904890, 5, 'psicológica.', false),
  (2898378, 1, 'hóspede que está na residência por curto período de tempo', false),
  (2898378, 2, 'irmão que não mais reside na casa, mas vai fazer uma visita', false),
  (2898378, 3, 'ex-companheiro que não mais reside na casa, mas vai buscar itens pessoais', false),
  (2898378, 4, 'prestador de serviço que vai a residência executar serviço específico', true),
  (2842551, 1, '(I) Violência religiosa; (II) Violência psicológica; (III) Violência sexual; (IV) Violência moral.', false),
  (2842551, 2, '(I) Violência moral; (II) Violência psicológica; (III) Violência física; (IV) Violência patrimonial.', false),
  (2842551, 3, '(I) Violência física; (II) Violência moral; (III) Violência física; (IV) Violência patrimonial.', false),
  (2842551, 4, '(I) Violência psicológica; (II) Violência moral; (III) Violência sexual; (IV) Violência patrimonial.', true),
  (2842551, 5, '(I) Violência psicológica; (II) Violência psicológica; (III) Violência sexual; (IV) Violência moral.', false),
  (2859577, 1, 'Certo', true),
  (2859577, 2, 'Errado', false),
  (2859690, 1, 'Certo', true),
  (2859690, 2, 'Errado', false),
  (2861901, 1, 'violência moral.', true),
  (2861901, 2, 'violência psicológica', false),
  (2861901, 3, 'violência física.', false),
  (2861901, 4, 'violência emocional.', false),
  (2890074, 1, 'sem qualquer relação de afeto, na qual o agressor tenha convivido com a ofendida.', false),
  (2890074, 2, 'no âmbito externo familiar, compreendido como uma comunidade de vizinhos, unidos por laços geográficos.', false),
  (2890074, 3, 'no ambiente de trabalho, compreendido como o espaço de convívio periódico de pessoas, inclusive as esporadicamente prestadoras de serviço externo.', false),
  (2890074, 4, 'no âmbito da unidade doméstica, compreendida como o espaço de convívio permanente de pessoas, com ou sem vínculo familiar, inclusive as esporadicamente agregadas.', true),
  (2862259, 1, 'Políticos.', false),
  (2862259, 2, 'Humanos.', true),
  (2862259, 3, 'Penais.', false),
  (2862259, 4, 'Trabalhistas.', false),
  (2862259, 5, 'Econômicos.', false),
  (2840121, 1, '1 – 2 – 3.', false),
  (2840121, 2, '1 – 3 – 2.', false),
  (2840121, 3, '2 – 1 – 3.', false),
  (2840121, 4, '2 – 3 – 1.', true),
  (2840121, 5, '3 – 2 – 1.', false),
  (2877475, 1, 'as relações homoafetivas não são objeto da Lei Maria da Penha;', false),
  (2877475, 2, 'a hipótese não é de violência doméstica, em se tratando de ex-casal;', false),
  (2877475, 3, 'a situação envolve a prática de stalking e violência sexual contra Clarice;', false),
  (2877475, 4, 'a violência psicológica e a violência moral praticadas por Juliana são claramente identificáveis;', true),
  (2877475, 5, 'Juliana pagará cestas básicas como parte das medidas restaurativas impostas pelo Juízo.', false),
  (2718877, 1, 'II e III, apenas.', false),
  (2718877, 2, 'I e II, apenas.', false),
  (2718877, 3, 'I e III, apenas.', false),
  (2718877, 4, 'I, II e III.', true),
  (3622849, 1, 'família; íntima relação', false),
  (3622849, 2, 'íntima relação; unidade doméstica', false),
  (3622849, 3, 'unidade doméstica; família', true),
  (3622849, 4, 'família; unidade doméstica', false),
  (3603257, 1, 'violência moral', false),
  (3603257, 2, 'violência sexual', false),
  (3603257, 3, 'violência psicológica', true),
  (3603257, 4, 'comportamento inadequado', false),
  (3534524, 1, 'Configura-se violência doméstica qualquer ação ou omissão baseada no gênero, sendo necessário, para tanto, a existência de vínculo familiar ou amoroso entre vítima e agressor para a aplicação das disposições da referida lei.', false),
  (3534524, 2, 'O confisco de documentos pessoais da ofendida pelo agressor caracteriza violência patrimonial.', true),
  (3534524, 3, 'Violência moral é aquela que causa dano emocional e diminuição de autoestima da ofendida.', false),
  (3534524, 4, 'Condutas que ofendam a honra da vítima por meio de calúnia, injúria ou difamação configuram violência psicológica nos termos da lei.', false),
  (3534524, 5, 'A Lei Maria da Penha não se aplica a relações homoafetivas, em que agressora e vítima são do gênero feminino.', false),
  (3260966, 1, 'I, II, III, IV, V', false),
  (3260966, 2, 'I, II, III, IV', true),
  (3260966, 3, 'I, II, IV, V', false),
  (3260966, 4, 'I, III, V', false),
  (3260966, 5, 'I, II, V', false),
  (3169677, 1, 'Cause dano emocional e diminuição da autoestima.', true),
  (3169677, 2, 'Limite ou anule o exercício de seus direitos sexuais e reprodutivos.', false),
  (3169677, 3, 'Configure calúnia, difamação ou injúria.', false),
  (3169677, 4, 'Ofenda sua integridade ou saúde corporal.', false),
  (3093006, 1, 'a violência física, entendida como qualquer conduta que configure retenção, subtração, destruição parcial ou total de seus objetos, instrumentos de trabalho, documentos pessoais, bens, valores e direitos ou recursos econômicos, incluindo os destinados a satisfazer suas necessidades.', false),
  (3093006, 2, 'a violência psicológica, entendida como qualquer conduta que configure calúnia, difamação ou injúria.', false),
  (3093006, 3, 'a violência sexual, entendida como qualquer conduta que a constranja a presenciar, a manter ou a participar de relação sexual não desejada, mediante intimidação, ameaça, coação ou uso da força; que a induza a comercializar ou a utilizar, de qualquer modo, a sua sexualidade, que a impeça de usar qualquer método contraceptivo ou que a force ao matrimônio, à gravidez, ao aborto ou à prostituição, mediante coação, chantagem, suborno ou manipulação; ou que limite ou anule o exercício de seus direitos sexuais e reprodutivos.', true),
  (3093006, 4, 'a violência patrimonial, entendida como qualquer conduta que lhe cause dano emocional.', false),
  (3093006, 5, 'a violência moral, entendida como qualquer conduta que ofenda sua integridade ou saúde corporal.', false),
  (3062789, 1, 'Ofensas verbais de cunho sexual em público não se enquadram na Lei Maria da Penha como violência doméstica.', false),
  (3062789, 2, 'A falta de suporte emocional não é reconhecida como uma forma de violência segundo a Lei Maria da Penha.', false),
  (3062789, 3, 'Condutas que impeçam mulheres de realizarem o aborto constituem violência sexual doméstica e familiar.', false),
  (3062789, 4, 'Condutas que forcem as mulheres ao aborto constituem violência sexual doméstica e familiar.', true),
  (3062789, 5, 'A omissão de informações sobre métodos contraceptivos não é considerada uma forma de violência doméstica.', false),
  (3057596, 1, 'Psicológica', false),
  (3057596, 2, 'Moral.', false),
  (3057596, 3, 'Sexual.', false),
  (3057596, 4, 'Física.', false),
  (3057596, 5, 'Patrimonial.', true),
  (3000783, 1, 'Qualquer conduta que configure calúnia, difamação, injúria ou qualquer outro meio que lhe cause prejuízo à saúde psicológica e à autodeterminação.', false),
  (3000783, 2, 'Qualquer conduta que ofenda sua integridade, saúde corporal, ou qualquer outro meio que lhe cause prejuízo à saúde psicológica e à autodeterminação.', false),
  (3000783, 3, 'Qualquer conduta que configure retenção, subtração, destruição parcial ou total de seus objetos, instrumentos de trabalho, documentos pessoais, bens, valores e direitos, recursos econômicos, incluindo os destinados a satisfazer suas necessidades, ou qualquer outro meio que lhe cause prejuízo à saúde psicológica e à autodeterminação.', false),
  (3000783, 4, 'Qualquer conduta que lhe cause dano emocional e diminuição da autoestima ou que lhe prejudique e perturbe o pleno desenvolvimento, ou que vise degradar ou controlar suas ações, comportamentos, crenças e decisões, mediante ameaça, constrangimento, humilhação, manipulação, isolamento, vigilância constante, perseguição contumaz, insulto, chantagem, violação de sua intimidade, ridicularização, exploração e limitação do direito de ir e vir ou qualquer outro meio que lhe cause prejuízo à saúde psicológica e à autodeterminação.', true),
  (2976888, 1, 'Violência racial.', true),
  (2976888, 2, 'Violência psicológica.', false),
  (2976888, 3, 'Violência patrimonial.', false),
  (2976888, 4, 'Violência física.', false),
  (2925122, 1, 'qualquer postura que cause constrangimento, humilhação, manipulação, isolamento, vigilância constante, perseguição contumaz, insulto, chantagem, violação de sua intimidade, ridicularização, exploração e limitação do direito de ir e vir ou qualquer outro meio que lhe cause prejuízo à saúde psicológica e à autodeterminação', false),
  (2925122, 2, 'qualquer conduta que configure calúnia, difamação ou injúria', false),
  (2925122, 3, 'qualquer conduta que a constranja a presenciar, a manter ou a participar de relação sexual não desejada', false),
  (2925122, 4, 'qualquer conduta que ofenda sua integridade ou saúde corporal', true),
  (2925122, 5, 'qualquer conduta que lhe cause dano emocional e diminuição da autoestima ou que lhe prejudique e perturbe o pleno desenvolvimento', false),
  (2891542, 1, 'Certo', true),
  (2891542, 2, 'Errado', false),
  (2890917, 1, 'A violência doméstica e familiar contra a mulher constitui uma das formas de violação dos direitos humanos.', true),
  (2890917, 2, 'Para os efeitos da Lei Maria Da Penha, a unidade doméstica é compreendida como o espaço de convívio permanente de pessoas, desde que haja vínculo familiar.', false),
  (2890917, 3, 'Conforme previsto expressamente na Lei Maria da Penha, só se considera violência contra a mulher aquela praticada por ho-mens.', false),
  (2890917, 4, 'Para os efeitos da Lei Maria Da Penha, a família é compreendida como a comunidade formada por indivíduos que são obrigatoriamente aparentados, unidos por laços naturais.', false),
  (2890917, 5, 'Para os efeitos da Lei Maria Da Penha, é considerada violência doméstica e familiar contra a mulher, aquela praticada em qualquer relação íntima de afeto, na qual o agressor conviva ou tenha convivido com a ofendida, sendo obrigatória a coabitação para sua caracterização.', false),
  (2885524, 1, 'A violência doméstica e familiar contra a mulher pode ser física, psicológica, sexual, patrimonial e moral.', false),
  (2885524, 2, 'A violência doméstica e familiar contra a mulher pode ser física, sendo entendida como qualquer conduta que ofenda a integridade ou a saúde corporal da mulher.', false),
  (2885524, 3, 'O impedimento de utilização de método contraceptivo, mediante constrangimento ou intimidação, praticado pelo marido ou companheiro em relação a mulher, é considerado violência sexual.', false),
  (2885524, 4, 'A vigilância constante e perseguição contumaz praticada pelo marido ou companheiro da mulher configura violência patrimonial.', true),
  (2885524, 5, 'A violência doméstica e familiar contra a mulher pode ser moral, sendo entendida como qualquer conduta que configure calúnia, difamação ou injúria.', false),
  (2885113, 1, 'V, V, V, V.', false),
  (2885113, 2, 'V, V, F, V.', true),
  (2885113, 3, 'V, F, F, V.', false),
  (2885113, 4, 'F, V, V, F.', false),
  (2885113, 5, 'V, V, V, F.', false),
  (2880201, 1, 'I, II, III, apenas.', false),
  (2880201, 2, 'I, IV, V, apenas.', false),
  (2880201, 3, 'I, III, IV, V, apenas.', false),
  (2880201, 4, 'III, IV, V, apenas.', false),
  (2880201, 5, 'I, II, III, IV, V.', true),
  (2873346, 1, 'Certo', true),
  (2873346, 2, 'Errado', false),
  (2872545, 1, 'Certo', true),
  (2872545, 2, 'Errado', false),
  (2872477, 1, 'Certo', false),
  (2872477, 2, 'Errado', true),
  (2872471, 1, 'Certo', false),
  (2872471, 2, 'Errado', true),
  (2852647, 1, 'Violência Física.', false),
  (2852647, 2, 'Violência Psicológica.', false),
  (2852647, 3, 'Violência sexual.', false),
  (2852647, 4, 'Violência matrimonial.', true),
  (2852647, 5, 'Violência moral.', false),
  (2844317, 1, 'Apenas a afirmação II é incorreta.', true),
  (2844317, 2, 'A afirmação V é incorreta e a afirmação II é correta.', false),
  (2844317, 3, 'As afirmações I e II são incorretas e V é correta.', false),
  (2844317, 4, 'As afirmações II e IV são corretas e a III é incorreta.', false),
  (2844316, 1, 'Para os efeitos da Lei, a violência doméstica contra a mulher se refere a qualquer ação ou omissão que possa importar, dentre outros efeitos, em sofrimento psicológico.', true),
  (2844316, 2, 'No âmbito da violência doméstica, compreendida como o espaço de convívio permanente de pessoas, inclui-se apenas as relações decorrentes de vínculo familiar.', false),
  (2844316, 3, 'Para efeito normativo considerar-se-á violência doméstica e familiar contra a mulher qualquer ação baseada no gênero que lhe cause morte, lesão, sofrimento físico, sexual ou psicológico, excluída a reparação moral bem como conduta omissiva ante a inexistência de previsão legal.', false),
  (2844316, 4, 'Embora constitua uma violação de direitos humanos, para efeito de proteção legal, as relações pessoais enunciadas no texto de lei serão dependentes, portanto, vinculadas à orientação sexual.', false),
  (2832187, 1, 'As asserções I e II são proposições verdadeiras, e a II é uma justificativa da I.', false),
  (2832187, 2, 'As asserções I e II são proposições verdadeiras, mas a II não é uma justificativa da I.', false),
  (2832187, 3, 'A asserção I é uma proposição verdadeira, e a II é uma proposição falsa.', false),
  (2832187, 4, 'A asserção I é uma proposição falsa, e a II é uma proposição verdadeira.', false),
  (2832187, 5, 'As asserções I e II são proposições falsas.', true),
  (2832030, 1, 'psicológica.', true),
  (2832030, 2, 'física.', false),
  (2832030, 3, 'sexual.', false),
  (2832030, 4, 'moral.', false),
  (2831105, 1, 'Gênero.', true),
  (2831105, 2, 'Raça.', false),
  (2831105, 3, 'Cor.', false),
  (2831105, 4, 'Condição social.', false),
  (2831105, 5, 'Idade.', false),
  (2830572, 1, 'Condutas que configuram calúnia, injúria ou difamação podem caracterizar violência psicológica.', false),
  (2830572, 2, 'A retenção da certidão de casamento e do RG da vítima por parte do agressor pode caracterizar violência psicológica.', false),
  (2830572, 3, 'Condutas de vigilância constante e controle de mensagens em aplicativos e redes sociais podem caracterizar violência moral.', false),
  (2830572, 4, 'A ação do agressor no sentido de impedir a vítima de usar medicamento contraceptivo pode configurar violência moral.', false),
  (2830572, 5, 'A ação do agressor no sentido de impedir a vítima de usar medicamento contraceptivo pode configurar violência sexual.', true),
  (2828648, 1, 'menos grave em relação à violência física, porque causa um vínculo de submissão voluntária do agredido ao agressor.', false),
  (2828648, 2, 'toda ação ou omissão que causa ou visa causar dano à autoestima, à identidade ou ao pleno desenvolvimento da pessoa.', true),
  (2828648, 3, 'uma forma de violência que não causa impactos físicos e por isso a comprovação é por depoimentos de testemunhas imparciais.', false),
  (2828648, 4, 'entendida como qualquer conduta que ofenda sua integridade, saúde corporal ou mental e desenvolvida repetidamente por extenso período.', false),
  (2828648, 5, 'qualquer conduta que configure calúnia, difamação ou injúria, visando desqualificar a mulher como mãe e pessoa do lar.', false),
  (2824698, 1, 'violência física - violência patrimonial - violência moral', true),
  (2824698, 2, 'Violência patrimonial - violência moral - violência física.', false),
  (2824698, 3, 'violência psicológica - violência física - violência moral.', false),
  (2824698, 4, 'Violência moral - violência patrimonial - violência física.', false),
  (2824698, 5, 'violência sexual - violência patrimonial - violência psicológica.', false),
  (2822362, 1, 'valem apenas no registro formal da relação (casamento civil ou união estável).', false),
  (2822362, 2, 'cabem apenas para as relações heterossexuais.', false),
  (2822362, 3, 'independem de orientação sexual.', true),
  (2822362, 4, 'aplicam-se também às situações de violência causal.', false),
  (2822362, 5, 'incidem nas ocorrências cotidianas de violência contra a mulher.', false),
  (2813039, 1, 'a violência física, entendida como qualquer conduta que ofenda sua integridade ou saúde corporal;', false),
  (2813039, 2, 'a violência psicológica, entendida como qualquer conduta que lhe cause dano emocional e diminuição da autoestima ou que lhe prejudique e perturbe o pleno desenvolvimento ou que vise degradar ou controlar suas ações, comportamentos, crenças e decisões, mediante ameaça, constrangimento, humilhação, manipulação, isolamento, vigilância constante, perseguição contumaz, insulto, chantagem, violação de sua intimidade, ridicularização, exploração e limitação do direito de ir e vir ou qualquer outro meio que lhe cause prejuízo à saúde psicológica e à autodeterminação;', false),
  (2813039, 3, 'a violência sexual, entendida como qualquer conduta que a constranja a presenciar, a manter ou a participar de relação sexual não desejada, mediante intimidação, ameaça, coação ou uso da força; que a induza a comercializar ou a utilizar, de qualquer modo, a sua sexualidade, que a impeça de usar qualquer método contraceptivo ou que a force ao matrimônio, à gravidez, ao aborto ou à prostituição, mediante coação, chantagem, suborno ou manipulação; ou que limite ou anule o exercício de seus direitos sexuais e reprodutivos;', false),
  (2813039, 4, 'a violência cultural, entendida como qualquer conduta que dificulte o desenvolvimento escolar da mulher.', true),
  (2755533, 1, 'Violência Patrimonial.', false),
  (2755533, 2, 'Violência Física.', false),
  (2755533, 3, 'Violência Sexual.', false),
  (2755533, 4, 'Violência Psicológica.', true),
  (2755533, 5, 'Violência Moral.', false),
  (2749394, 1, 'configure calúnia, difamação ou injúria, contra a própria mulher ou seus descendentes', false),
  (2749394, 2, 'resulte em retenção, subtração, destruição parcial ou total de seus objetos, instrumentos de trabalho e documentos pessoais', false),
  (2749394, 3, 'vise controlar suas ações, comportamentos, crenças e decisões, mediante ameaça, constrangimento, humilhação, manipulação, isolamento, vigilância constante', true),
  (2749394, 4, 'impeça a mulher de usar qualquer método contraceptivo ou que a force ao matrimônio, à gravidez, ao aborto ou à prostituição, mediante coação, chantagem, suborno ou manipulação', false),
  (2739031, 1, 'Certo', false),
  (2739031, 2, 'Errado', true),
  (2736918, 1, 'Certo', true),
  (2736918, 2, 'Errado', false),
  (2736792, 1, 'Certo', true),
  (2736792, 2, 'Errado', false),
  (2736747, 1, 'Certo', false),
  (2736747, 2, 'Errado', true),
  (2735885, 1, 'Qualquer conduta que ofenda sua integridade física ou saúde corporal, ou cause a mulher dano patrimonial.', false),
  (2735885, 2, 'Qualquer conduta que constranja a presenciar, a manter ou a participar de relação sexual não desejada, mediante intimidação, ameaça, coação ou uso de força.', false),
  (2735885, 3, 'Qualquer conduta que configure retenção, subtração, destruição parcial ou total de seus objetos, instrumentos de trabalho, documentos pessoais, bens, valores e direitos ou recursos econômicos, incluído os destinados a satisfazer suas necessidades.', false),
  (2735885, 4, 'Qualquer conduta que lhe cause dano emocional e diminuição da autoestima, ou que lhe prejudique e perturbe o pleno desenvolvimento, ou que vise degradar ou controlar suas ações e comportamentos, crenças e decisões, mediante ameaça ou constrangimento.', true),
  (2666495, 1, 'Certo', false),
  (2666495, 2, 'Errado', true),
  (2664350, 1, 'Certo', false),
  (2664350, 2, 'Errado', true),
  (2641121, 1, 'Todas as afirmativas estão corretas.', false),
  (2641121, 2, 'Nenhuma afirmativa está correta.', false),
  (2641121, 3, 'Apenas uma afirmativa está correta.', true),
  (2641121, 4, 'Apenas duas afirmativas estão corretas.', false),
  (2634262, 1, 'Certo', true),
  (2634262, 2, 'Errado', false),
  (2634226, 1, 'Certo', false),
  (2634226, 2, 'Errado', true),
  (2629049, 1, 'As duas afirmativas são verdadeiras.', false),
  (2629049, 2, 'A afirmativa I é verdadeira, e a II é falsa.', false),
  (2629049, 3, 'A afirmativa II é verdadeira, e a I é a falsa.', true),
  (2629049, 4, 'As duas afirmativas são falsas.', false),
  (2622322, 1, 'As asserções I e II são proposições verdadeiras, e a II é uma justificativa da I.', false),
  (2622322, 2, 'A asserção I é uma proposição falsa, e a II é uma proposição verdadeira.', false),
  (2622322, 3, 'A asserção I é uma proposição verdadeira, e a II é uma proposição falsa.', false),
  (2622322, 4, 'As asserções I e II são proposições verdadeiras, mas a II não é uma justificativa da I.', true),
  (2622322, 5, 'As asserções I e II são proposições falsas.', false),
  (2614560, 1, 'Apenas I e II.', false),
  (2614560, 2, 'Apenas I e III.', false),
  (2614560, 3, 'Apenas II e III.', false),
  (2614560, 4, 'I, II e III.', true),
  (2614560, 5, 'Apenas II.', false),
  (2596117, 1, 'A lei Maria da Penha contempla apenas os casos de agressão física.', false),
  (2596117, 2, 'A partir da lei Maria da Penha a violência doméstica passa a ser um agravante para aumentar a pena, sendo possível substituir a pena por doação de cestas básicas, trabalhos comunitários ou multas.', false),
  (2596117, 3, 'O crime de lesão corporal leve será objeto de apuração e processo, somente sob autorização da vítima.', false),
  (2596117, 4, 'Com a aprovação da lei, o governo brasileiro disponibilizou o canal de atendimento 180, voltado para denúncias sobre violência contra a mulher. O canal pode ser utilizado tanto pela vítima, quanto por alguém que identifique as agressões sofridas por uma mulher.', true),
  (2596087, 1, 'A violência patrimonial, entendida como qualquer conduta que configure calúnia, difamação ou injúria.', false),
  (2596087, 2, 'A violência psicológica, entendida como qualquer conduta que a constranja a presenciar, a manter ou a participar de relação sexual não desejada, mediante intimidação, ameaça, coação ou uso da força.', false),
  (2596087, 3, 'a violência psicológica, entendida como qualquer conduta que configure retenção, subtração, destruição parcial ou total de seus objetos, instrumentos de trabalho, documentos pessoais, bens, valores e direitos ou recursos econômicos, incluindo os destinados a satisfazer suas necessidades.', false),
  (2596087, 4, 'A violência física, entendida como qualquer conduta que ofenda sua integridade ou saúde corporal.', true),
  (2593846, 1, 'o desrespeito aos valores éticos da mulher.', false),
  (2593846, 2, 'a calúnia, a difamação ou a injúria contra a mulher.', true),
  (2593846, 3, 'o desprezo pelos princípios religiosos da mulher.', false),
  (2593846, 4, 'a prática de agressões verbais contra a mulher.', false),
  (2593846, 5, 'a instigação ou induzimento ao suicídio da mulher.', false),
  (2591112, 1, 'não se pode afirmar que a conduta represente violência de cunho sexual contra a mulher, pois, no início da relação sexual, ela consentiu com a prática do ato.', false),
  (2591112, 2, 'Fulano ficará obrigado a ressarcir todos os eventuais danos causados à sua companheira, incluídos os custos de serviços de saúde para o tratamento das consequências do ato.', true),
  (2591112, 3, 'se trata de situação típica de violência moral contra a companheira, entendida esta como qualquer conduta que cause sofrimento psíquico à mulher.', false),
  (2591112, 4, 'o ato praticado por Fulano de Tal está protegido pela liberdade religiosa, pois ninguém pode ser obrigado à utilização de preservativos contra a sua fé.', false),
  (2591112, 5, 'se trata de situação típica de violência física contra a companheira, pois lhe veda o direito de possuir suas próprias crenças em relação à maternidade e à contracepção.', false);

-- ----------------------------------------------------------------------------
-- Revalidacao de premissas dentro da propria transacao antes de qualquer
-- escrita real (RAISE EXCEPTION aborta tudo automaticamente).
-- ----------------------------------------------------------------------------
do $$
declare
  v_materia_id bigint;
  v_assunto_id bigint;
  v_curso_concurso text;
begin
  if (select count(*) from _l2_questoes) <> 184 then
    raise exception 'Precondicao falhou: staging nao tem exatamente 184 questoes';
  end if;

  select cm.materia_id, cc.assunto_id into v_materia_id, v_assunto_id
  from public.curso_conteudos cc
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where cc.id = 53;

  if v_materia_id is distinct from 10 or v_assunto_id is distinct from 19 then
    raise exception 'Precondicao falhou: conteudo 53 materia_id=% assunto_id=% (esperado 10/19)', v_materia_id, v_assunto_id;
  end if;

  select concurso into v_curso_concurso from public.cursos where id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'::uuid;
  if v_curso_concurso is distinct from 'Brigada Militar do Rio Grande do Sul' then
    raise exception 'Precondicao falhou: curso 7543be16-4c5b-4cb6-8724-8fbdfb96f2d4 concurso=% (esperado Brigada Militar do Rio Grande do Sul)', v_curso_concurso;
  end if;

  -- Deduplicacao por TEXTO (nao por tec_id — ver comentario no cabecalho
  -- deste arquivo sobre por que tec_id nao e confiavel). Compara contra
  -- TODAS as questoes existentes, nao so assunto_id=19, por seguranca.
  if exists (
    select 1
    from _l2_questoes l
    join public.questoes q
      on lower(regexp_replace(q.enunciado, '\s+', ' ', 'g')) = lower(regexp_replace(l.enunciado, '\s+', ' ', 'g'))
  ) then
    raise exception 'Precondicao falhou: alguma candidata do Lote 2 tem enunciado identico a uma questao ja existente (possivel duplicata nao capturada)';
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ESCRITA 1 — questoes (loop explicito para mapear tec_id -> id real de
-- forma inequivoca, sem depender de ordem implicita de RETURNING).
-- explicacao ja vai preenchida (Fase 3B ja escreveu o texto completo).
-- ----------------------------------------------------------------------------
create temporary table _l2_ids (tec_id bigint primary key, questao_id bigint) on commit drop;

do $$
declare
  r record;
  v_id bigint;
begin
  for r in select * from _l2_questoes order by tec_id loop
    insert into public.questoes (materia_id, assunto_id, banca, concurso, enunciado, explicacao, fonte, ano, ativa, dificuldade, gerada_por_ia)
    values (10, 19, r.banca, r.concurso, r.enunciado, r.explicacao, r.fonte, r.ano, true, 'media', false)
    returning id into v_id;

    insert into _l2_ids (tec_id, questao_id) values (r.tec_id, v_id);
  end loop;
end $$;

-- ----------------------------------------------------------------------------
-- ESCRITA 2 — alternativas.
-- ----------------------------------------------------------------------------
insert into public.alternativas (questao_id, texto, correta, ordem)
select m.questao_id, a.texto, a.correta, a.ordem
from _l2_alternativas a
join _l2_ids m using (tec_id);

-- ----------------------------------------------------------------------------
-- ESCRITA 3 — curso_questoes (todas as 184 no curso Brigada Militar RS, como
-- banco geral — sem vinculo de unidade pedagogica nesta rodada).
-- ----------------------------------------------------------------------------
insert into public.curso_questoes (curso_id, questao_id)
select '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'::uuid, questao_id
from _l2_ids;

-- ----------------------------------------------------------------------------
-- ASSERTS — tabela de apoio TEMPORARY com ON COMMIT DROP: some ao final da
-- transacao (ROLLBACK ou COMMIT), nunca persiste no schema public. Sem
-- procedure auxiliar (Postgres nao tem "procedure temporaria" — a unica
-- forma de garantir zero objeto permanente e nao criar procedure nenhuma) —
-- a logica de log/verificacao fica toda dentro dos blocos DO abaixo, que
-- ja sao, por natureza, transitorios.
-- ----------------------------------------------------------------------------
create temporary table _l2_asserts (ordem serial primary key, descricao text, ok boolean) on commit drop;

do $$
declare
  v_antes record;
  v_depois record;
  v_sem_correta int;
  v_com_vinculo_unidade int;
  v_ids_novas bigint[];
  v_missao_final bigint[];
  v_novas_na_missao int;
  v_novas_vazando_u1 int;
  v_u1_id uuid;
  v_duplicata_texto int;
begin
  select * into v_antes from _snapshot_antes;
  select
    (select count(*) from public.questoes)                     as total_questoes,
    (select count(*) filter (where assunto_id = 19) from public.questoes) as total_questoes_lmp,
    (select count(*) from public.alternativas)                 as total_alternativas,
    (select count(*) from public.unidades_pedagogicas)          as total_unidades,
    (select count(*) from public.curso_conteudos)               as total_conteudos,
    (select count(*) from public.curso_questoes)                as total_curso_questoes,
    (select count(*) from public.respostas_usuarios)            as total_respostas,
    (select count(*) from public.sessoes_estudo)                as total_sessoes,
    (select count(*) from public.questao_unidades_pedagogicas)  as total_vinculos
  into v_depois;

  insert into _l2_asserts (descricao, ok) values ('questoes +184', v_depois.total_questoes = v_antes.total_questoes + 184);
  insert into _l2_asserts (descricao, ok) values ('questoes com assunto_id=19 (Lei Maria da Penha) +184', v_depois.total_questoes_lmp = v_antes.total_questoes_lmp + 184);
  insert into _l2_asserts (descricao, ok) values ('alternativas +766', v_depois.total_alternativas = v_antes.total_alternativas + 766);
  insert into _l2_asserts (descricao, ok) values ('curso_questoes +184', v_depois.total_curso_questoes = v_antes.total_curso_questoes + 184);
  insert into _l2_asserts (descricao, ok) values ('unidades_pedagogicas inalterada (nenhuma unidade criada/removida)', v_depois.total_unidades = v_antes.total_unidades);
  insert into _l2_asserts (descricao, ok) values ('curso_conteudos inalterada', v_depois.total_conteudos = v_antes.total_conteudos);
  insert into _l2_asserts (descricao, ok) values ('questao_unidades_pedagogicas inalterada (banco geral, sem vinculo de unidade)', v_depois.total_vinculos = v_antes.total_vinculos);
  insert into _l2_asserts (descricao, ok) values ('respostas_usuarios inalterada', v_depois.total_respostas = v_antes.total_respostas);
  insert into _l2_asserts (descricao, ok) values ('sessoes_estudo inalterada', v_depois.total_sessoes = v_antes.total_sessoes);

  select count(*) into v_sem_correta
  from _l2_ids m
  where (select count(*) from public.alternativas a where a.questao_id = m.questao_id and a.correta) <> 1;
  insert into _l2_asserts (descricao, ok) values ('todas as 184 questoes tem exatamente 1 alternativa correta', v_sem_correta = 0);

  select count(*) into v_com_vinculo_unidade
  from _l2_ids m
  where exists (select 1 from public.questao_unidades_pedagogicas qup where qup.questao_id = m.questao_id);
  insert into _l2_asserts (descricao, ok) values ('nenhuma das 184 novas ganhou vinculo de unidade pedagogica (banco geral)', v_com_vinculo_unidade = 0);

  select count(*) into v_duplicata_texto
  from public.questoes q1
  join public.questoes q2 on q1.id < q2.id
    and lower(regexp_replace(q1.enunciado, '\s+', ' ', 'g')) = lower(regexp_replace(q2.enunciado, '\s+', ' ', 'g'))
  where q1.assunto_id = 19 and q2.assunto_id = 19
    and q1.id in (select questao_id from _l2_ids);
  insert into _l2_asserts (descricao, ok) values ('nenhuma das 184 novas ficou duplicada (texto identico) com outra questao de assunto_id=19 apos a insercao', v_duplicata_texto = 0);

  -- Ponta a ponta: confirma que as novas (banco geral) aparecem na Missao
  -- Final via public.selecionar_candidatas_conteudo, e NAO vazam para a
  -- pratica de nenhuma unidade especifica (checagem representativa em U1).
  select array_agg(questao_id) into v_ids_novas from _l2_ids;

  select array_agg(x.questao_id) into v_missao_final
  from public.selecionar_candidatas_conteudo(
    'e5523807-6cc8-4867-8a56-77c17552e56e'::uuid, 53::bigint, '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'::uuid, 1000, '{}'::bigint[], null
  ) x(questao_id);

  select count(*) into v_novas_na_missao
  from unnest(v_ids_novas) qid where qid = any(v_missao_final);

  insert into _l2_asserts (descricao, ok) values (
    'todas as 184 novas (banco geral) aparecem na Missao Final (conteudo 53)',
    v_novas_na_missao = 184
  );

  select id into v_u1_id from public.unidades_pedagogicas where curso_conteudo_id = 53 and ativa = true order by ordem limit 1;

  select count(*) into v_novas_vazando_u1
  from unnest(v_ids_novas) qid
  where qid = any(array(
    select x.questao_id from public.selecionar_candidatas_unidade_pedagogica(
      'e5523807-6cc8-4867-8a56-77c17552e56e'::uuid, v_u1_id, '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'::uuid, 1000, '{}'::bigint[], null
    ) x(questao_id)
  ));

  insert into _l2_asserts (descricao, ok) values (
    'nenhuma das 184 novas aparece na pratica de uma unidade especifica (checagem representativa em U1)',
    v_novas_vazando_u1 = 0
  );
end $$;

-- Segundo bloco: percorre os asserts na ordem em que foram inseridos,
-- reportando cada um (RAISE NOTICE) e abortando a transacao inteira no
-- primeiro que falhar (RAISE EXCEPTION), exatamente como o CALL a uma
-- procedure faria — so que sem precisar de nenhuma procedure. A tabela
-- _l2_asserts em si desaparece sozinha ao fim da transacao (ON COMMIT DROP).
do $$
declare
  r record;
  v_total integer;
  v_ok integer;
begin
  for r in select descricao, ok from _l2_asserts order by ordem loop
    if r.ok then
      raise notice 'OK: %', r.descricao;
    else
      raise exception 'FALHOU: %', r.descricao;
    end if;
  end loop;

  select count(*), count(*) filter (where ok) into v_total, v_ok from _l2_asserts;
  raise notice '=== RESUMO: % / % asserts passaram ===', v_ok, v_total;
  if v_ok <> v_total then
    raise exception 'Harness falhou: nem todos os asserts passaram (ver RESUMO acima).';
  end if;
end $$;

-- Todos os asserts acima passaram (senao a transacao já teria abortado por
-- RAISE EXCEPTION) — confirma as escritas: 184 questoes (com explicacao ja
-- preenchida), 766 alternativas, 184 vinculos de curso_questoes (banco
-- geral, sem vinculo de unidade pedagogica).
COMMIT;
