-- ============================================================================
-- AUDITORIA GLOBAL -- PRIORIDADE 1 (LEGISLACAO ESPECIFICA) -- LE-1a
-- Aplicacao de 21 explicacoes pedagogicas -- Direitos e Garantias
-- Fundamentais (assunto_id 71, materia_id 10)
-- IDs: 46,112,298,326,657,658,660,661,662,663,723,724,725,726,727,775,797,846,847,848,849
-- HARNESS TRANSACIONAL -- TERMINA SEMPRE EM ROLLBACK, NADA PERSISTE.
-- ============================================================================
--
-- Gerado automaticamente por scripts/generate-le1a-harness.mjs a partir de
-- scripts/le1a-direitos-garantias-fundamentais-explicacoes.mjs. NAO editar
-- este arquivo a mao -- editar a fonte e regerar.
--
-- Contexto: primeiro sublote (LE-1a) da Prioridade 1 (Legislacao Especifica)
-- da auditoria global de explicacoes do Papiro. Das 22 questoes do assunto
-- "Direitos e Garantias Fundamentais", 21 foram auditadas juridicamente e
-- classificadas VALIDA (texto do art. 5o e art. 1o da CF/88 conferido
-- dispositivo a dispositivo; nenhuma Emenda Constitucional entre 2023-2026
-- alterou os incisos testados). A questao id 659 foi classificada
-- PROBLEMATICA (enunciado truncado/corrompido: termina em "...e garantido("
-- com parenteses nao fechado) e fica INTEIRAMENTE FORA deste harness --
-- nao recebe explicacao, nao e tocada de forma alguma.
--
-- Escopo estrito: altera SOMENTE `explicacao` (+ `atualizado_em` -- esta
-- tabela nao tem trigger de auto-atualizacao, por isso e setado
-- explicitamente) para exatamente os 21 ids listados acima. Nenhuma outra
-- coluna, nenhuma outra linha, nenhuma tabela relacionada (alternativas,
-- curso_questoes, questao_unidades_pedagogicas) e tocada. Os asserts abaixo
-- provam isso por comparacao jsonb byte-a-byte (incluindo um controle
-- negativo explicito sobre a questao 659) e por hash de explicacao de TODAS
-- as questoes do banco, nao so pela leitura do UPDATE em si.
--
-- Sem objetos permanentes: todo o rastreio de asserts usa apenas CREATE
-- TEMPORARY TABLE ... ON COMMIT DROP e blocos DO $$ ... $$ inline (sem
-- CREATE FUNCTION/PROCEDURE), mesmo padrao adotado na Fase 3C e na
-- desativacao das questoes 1337/1340.
--
-- Usa a MESMA simulacao de claim JWT do admin cadastrado (via "set local"),
-- restrita a esta transacao, no mesmo padrao ja usado nos harnesses
-- anteriores. Precisa rodar com um role de ESCRITA (nao funciona via MCP
-- read-only).
--
-- ESTE ARQUIVO TERMINA SEMPRE EM ROLLBACK. Nenhuma alteracao real e
-- persistida ao rodar este arquivo -- e apenas o harness de validacao.
-- ============================================================================

BEGIN;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

-- ----------------------------------------------------------------------------
-- Staging: id -> nova explicacao (fonte: scripts/le1a-direitos-garantias-fundamentais-explicacoes.mjs).
-- ----------------------------------------------------------------------------
create temporary table _le1a_novas_explicacoes (id bigint primary key, explicacao text) on commit drop;
insert into _le1a_novas_explicacoes (id, explicacao) values
(46, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A sequência correta é V-F-V-V. Item 1 (verdadeiro): reproduz literalmente o art. 5º, X, da CF/88 — "são invioláveis a intimidade, a vida privada, a honra e a imagem das pessoas, assegurado o direito a indenização pelo dano material ou moral decorrente de sua violação". Item 2 (falso): o art. 5º, XVI, exige "prévio aviso à autoridade competente" para o exercício do direito de reunião — a assertiva erra ao afirmar que a reunião independe de prévio aviso, quando esse aviso é condição expressa do dispositivo (o que é dispensado é a AUTORIZAÇÃO, não o aviso). Item 3 (verdadeiro): reproduz literalmente o art. 5º, XIX — associações só podem ser dissolvidas compulsoriamente ou ter atividades suspensas por decisão judicial, exigindo trânsito em julgado no caso de dissolução. Item 4 (verdadeiro): reproduz literalmente o art. 5º, XXXIX — princípio da legalidade/anterioridade penal.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Marca o item 2 como verdadeiro, mas ele é falso — a Constituição exige prévio aviso à autoridade competente, e a assertiva nega essa exigência.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Marca os itens 1, 3 e 4 como falsos, quando na verdade todos os três reproduzem literalmente incisos do art. 5º e são verdadeiros.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Marca o item 1 e o item 4 como falsos, quando na verdade ambos são verdadeiros, e não acerta a combinação completa dos quatro itens.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Marca o item 3 como falso, quando na verdade reproduz literalmente o art. 5º, XIX, e é verdadeiro.

BIZU DE PROVA:
No direito de reunião (art. 5º, XVI), memorize a diferença entre "autorização" (dispensada) e "aviso prévio" (exigido) — a Constituição não exige que o Estado autorize a reunião, mas exige que o organizador avise previamente a autoridade competente, para não frustrar outra reunião já convocada para o mesmo local.'),
(112, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Reproduz literalmente o art. 5º, XXXIII, da CF/88: "todos têm direito a receber dos órgãos públicos informações de seu interesse particular, ou de interesse coletivo ou geral, que serão prestadas no prazo da lei, sob pena de responsabilidade, ressalvadas aquelas cujo sigilo seja imprescindível à segurança da sociedade e do Estado".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O art. 5º, XII, ressalva a possibilidade de quebra de sigilo mediante ordem judicial apenas "no último caso" (comunicações telefônicas) — a alternativa erra ao estender essa exceção também às comunicações de dados ("nos dois últimos casos"), quando a correspondência, as comunicações telegráficas e os dados permanecem invioláveis sem essa exceção textual.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O art. 5º, XVI, exige apenas prévio AVISO à autoridade competente, não prévia AUTORIZAÇÃO — a reunião pacífica e sem armas independe de autorização estatal.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A regra geral de desapropriação por necessidade ou utilidade pública, ou por interesse social (art. 5º, XXIV), exige indenização justa e prévia EM DINHEIRO, não em títulos da dívida pública — pagamento em títulos é modalidade excepcional da reforma agrária (art. 184), não a regra geral do inciso XXIV.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O art. 5º, XXVI, protege a pequena propriedade rural trabalhada pela família contra penhora justamente PARA pagamento de débitos decorrentes de sua atividade produtiva — a alternativa inverte a proteção ao inserir essa hipótese como se fosse uma exceção que permite a penhora, quando é exatamente o débito que o dispositivo protege.

BIZU DE PROVA:
Decore os "invertidos clássicos" do art. 5º: "no último caso" (XII) vira "nos dois últimos casos"; "prévio aviso" (XVI) vira "prévia autorização"; indenização "em dinheiro" (XXIV) vira "em títulos da dívida pública". Bancas adoram trocar uma palavra-chave para inverter o sentido do inciso.'),
(298, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O art. 5º, XI, da CF/88 estabelece que "a casa é asilo inviolável do indivíduo, ninguém nela podendo penetrar sem consentimento do morador, salvo em caso de flagrante delito ou desastre, ou para prestar socorro, ou, durante o dia, por determinação judicial". O flagrante delito é uma das hipóteses expressas que autorizam o ingresso sem consentimento do morador, a qualquer hora do dia ou da noite.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Mera suspeita não é hipótese autorizadora de ingresso em domicílio sem consentimento — a Constituição exige uma das situações taxativas do art. 5º, XI, não bastando suspeita genérica.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Curiosidade administrativa" não é hipótese prevista no art. 5º, XI, nem em qualquer outro dispositivo constitucional que autorize o ingresso em domicílio alheio.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Ordem verbal de servidor não supre a exigência constitucional de determinação judicial nem se equipara a flagrante delito, desastre ou socorro.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Fiscalização sem fundamento não é hipótese autorizadora de ingresso — qualquer ingresso em domicílio precisa se enquadrar em uma das hipóteses taxativas do art. 5º, XI.

BIZU DE PROVA:
Decore as 4 hipóteses taxativas do art. 5º, XI, que autorizam o ingresso em domicílio sem consentimento do morador: flagrante delito, desastre, prestar socorro (essas três, a qualquer hora) e determinação judicial (só durante o dia).'),
(326, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A sequência correta é V-F-V-F. Item 1 (verdadeiro): reproduz corretamente o art. 5º, XII — sigilo de correspondência, comunicações telegráficas, de dados e telefônicas, ressalvada a quebra por ordem judicial apenas "no último caso" (telefônicas), para investigação criminal ou instrução processual penal. Item 2 (falso): o art. 5º, XXV, dispõe que, no caso de iminente perigo público, a autoridade competente PODERÁ usar de propriedade particular, assegurada indenização ulterior se houver dano — a assertiva inverte o comando ao afirmar que "não poderá". Item 3 (verdadeiro): sintetiza corretamente o direito de acesso a informações do art. 5º, XXXIII, com a ressalva das hipóteses constitucionais de sigilo. Item 4 (falso): o art. 5º, XXXIV, "b", assegura a obtenção de certidões em repartições públicas independentemente do pagamento de taxas — a assertiva inverte o comando ao vincular obrigatoriamente a certidão ao pagamento de taxas.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Marca o item 1 como falso, quando na verdade reproduz corretamente o art. 5º, XII, e é verdadeiro.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Marca o item 3 como falso e trata o item 2 como verdadeiro, invertendo a avaliação correta — o item 2 é falso e o item 3 é verdadeiro.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Marca o item 4 como verdadeiro, quando o art. 5º, XXXIV, "b", garante certidões independentemente de pagamento de taxas, tornando falsa a assertiva que vincula a certidão ao pagamento.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Marca todos os itens como falsos, mas os itens 1 e 3 reproduzem corretamente dispositivos constitucionais e são verdadeiros.

BIZU DE PROVA:
O art. 5º, XXXIV, "a" e "b" (petição aos Poderes Públicos e obtenção de certidões) são gratuitos "independentemente do pagamento de taxas" — é um dos poucos direitos do art. 5º com gratuidade expressa no próprio caput do inciso, e bancas adoram inverter isso para "mediante pagamento de taxas".'),
(657, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O habeas data (art. 5º, LXXII) assegura o conhecimento de informações relativas à pessoa do impetrante constantes de registros de entidades governamentais ou de caráter público, ou a retificação de dados, quando não se prefira fazê-lo por processo sigiloso, judicial ou administrativo. O habeas corpus (art. 5º, LXVIII) é concedido sempre que alguém sofrer ou se achar ameaçado de sofrer violência ou coação em sua liberdade de locomoção, por ilegalidade ou abuso de poder.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O mandado de segurança (art. 5º, LXIX) protege direito líquido e certo não amparado por habeas corpus ou habeas data, e a ação popular (art. 5º, LXXIII) serve para anular ato lesivo ao patrimônio público — nenhum dos dois é o instrumento de acesso/correção de dados pessoais nem o de proteção à locomoção descritos no enunciado.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O mandado de injunção (art. 5º, LXXI) serve para suprir a falta de norma regulamentadora que inviabilize direitos constitucionais — não é o instrumento de acesso a dados pessoais descrito na primeira lacuna.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Inverte os dois instrumentos: a ação popular não serve para acesso a dados pessoais, e o mandado de injunção não protege a liberdade de locomoção.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Inverte os dois remédios constitucionais: quem protege a liberdade de locomoção é o habeas corpus, e quem dá acesso/retificação de dados pessoais é o habeas data — a alternativa troca as posições.

BIZU DE PROVA:
Associe pelo objeto: "data" (dado) → habeas DATA (informação/dados pessoais); "corpus" (corpo) → habeas CORPUS (liberdade física/locomoção). Os nomes em latim já entregam a resposta.'),
(658, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O art. 5º, XI, autoriza o ingresso em domicílio sem consentimento do morador, independentemente de horário e sem mandado judicial, em caso de flagrante delito, desastre ou para prestar socorro — só a determinação judicial está condicionada ao período diurno. Gritos de socorro ouvidos pelo policial configuram justamente a hipótese de prestação de socorro, autorizando o ingresso imediato, a qualquer hora.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A vedação ao ingresso noturno sem mandado se aplica apenas à hipótese de determinação judicial — flagrante delito, desastre e socorro continuam autorizando o ingresso a qualquer hora, inclusive à noite.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A licitude do ingresso para prestar socorro decorre diretamente do art. 5º, XI, e independe de autorização ou validação posterior do delegado de polícia.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O socorro não é excluído das hipóteses de ingresso noturno sem mandado — é uma das hipóteses que a Constituição autoriza expressamente a qualquer hora, ao lado do flagrante e do desastre.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A Constituição não condiciona a licitude da prova colhida em ingresso por socorro à expedição posterior de mandado judicial em 24 horas — essa exigência não existe no art. 5º, XI, para essa hipótese.

BIZU DE PROVA:
"Flagrante, desastre ou socorro: a qualquer hora. Determinação judicial: só de dia." É a frase-chave para resolver qualquer questão sobre inviolabilidade de domicílio (art. 5º, XI).'),
(660, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O art. 5º, VII, da CF/88 assegura, nos termos da lei, a prestação de assistência religiosa nas entidades civis E militares de internação coletiva — o texto constitucional expressamente abrange as duas espécies de entidade, sem restringir o direito apenas a uma delas.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O art. 5º, VII, garante a assistência religiosa tanto em entidades civis quanto militares de internação coletiva — não há restrição do direito apenas às entidades civis, nem exclusão das militares.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Existe disposição expressa sobre o tema no art. 5º, VII, da Constituição Federal.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A liberdade de consciência e de crença é assegurada pelo art. 5º, VI, sendo inviolável, garantido o livre exercício dos cultos religiosos.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O direito à assistência religiosa em entidades de internação coletiva vale tanto para as militares quanto para as civis — não há restrição que exclua as entidades civis.

BIZU DE PROVA:
O art. 5º, VII, é um dos poucos incisos que menciona expressamente "entidades civis E militares" lado a lado — memorize que o direito à assistência religiosa em internação coletiva não distingue civil de militar.'),
(661, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O art. 5º, XVI, assegura que todos podem reunir-se pacificamente, sem armas, em locais abertos ao público, independentemente de autorização, desde que não frustrem outra reunião anteriormente convocada para o mesmo local, exigindo-se apenas prévio aviso à autoridade competente. O caráter político da manifestação não restringe esse direito, desde que observados os requisitos constitucionais.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A reunião protegida pelo art. 5º, XVI, deve ser necessariamente "sem armas" — reunião armada não está amparada por esse direito fundamental.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O direito de reunião independe de autorização do Poder Público — a Constituição exige apenas prévio aviso à autoridade competente, não autorização prévia.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Se já houver outra reunião anteriormente convocada para o mesmo local, a nova reunião não pode frustrá-la — esse é um dos requisitos expressos do art. 5º, XVI.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O prévio aviso à autoridade competente é exigência expressa do art. 5º, XVI — não é dispensável.

BIZU DE PROVA:
Os 4 requisitos do direito de reunião (art. 5º, XVI) formam um combo que cai sempre junto: pacífica, sem armas, local aberto ao público, prévio aviso à autoridade (sem frustrar reunião já convocada para o mesmo local). Falhar em qualquer um tira a proteção constitucional.'),
(662, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Reproduz literalmente o art. 5º, L, da CF/88: "às presidiárias serão asseguradas condições para que possam permanecer com seus filhos durante o período de amamentação".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O art. 5º, XLVI, determina que a lei regulará a individualização da pena e ADOTARÁ, entre outras, a pena de interdição de direitos (alínea "d") — a alternativa erra ao afirmar que a lei "não poderá" adotar essa modalidade de pena.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O art. 5º, XL, estabelece que a lei penal não retroagirá, SALVO para beneficiar o réu — a retroatividade benéfica é a regra, não a vedação absoluta que a alternativa afirma.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O art. 5º, XLV, dispõe que nenhuma pena passará da pessoa do condenado, mas a obrigação de reparar o dano e a decretação do perdimento de bens PODERÃO ser, nos termos da lei, estendidas aos sucessores, até o limite do valor do patrimônio transferido — a alternativa inverte o comando ao afirmar que não poderá ser estendida.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O art. 5º, XLII, estabelece imprescritibilidade apenas para o crime de racismo, e o art. 5º, XLIV, para a ação de grupos armados contra a ordem constitucional — o tráfico ilícito de entorpecentes é classificado pelo art. 5º, XLIII, como inafiançável e insuscetível de graça ou anistia, não como imprescritível.

BIZU DE PROVA:
Só dois crimes são expressamente imprescritíveis no art. 5º: racismo (XLII) e ação de grupos armados civis ou militares contra a ordem constitucional e o Estado Democrático (XLIV). Tráfico de drogas, tortura e terrorismo são inafiançáveis e insuscetíveis de graça/anistia (XLIII) — mas não imprescritíveis. Não confunda as duas listas.'),
(663, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O art. 5º, LXXII, "b", concede habeas data para a retificação de dados, quando não se prefira fazê-lo por processo sigiloso, judicial ou administrativo — exatamente a hipótese descrita no enunciado.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O habeas corpus (art. 5º, LXVIII) protege a liberdade de locomoção contra ilegalidade ou abuso de poder, não a retificação de dados pessoais.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O mandado de injunção (art. 5º, LXXI) é cabível quando a falta de norma regulamentadora torna inviável o exercício de direitos e liberdades constitucionais, não para retificação de dados.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O mandado de segurança (art. 5º, LXIX) protege direito líquido e certo não amparado por habeas corpus ou habeas data — justamente por isso não é cabível quando a hipótese já se enquadra no habeas data, como no caso do enunciado.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A ação popular (art. 5º, LXXIII) serve para anular ato lesivo ao patrimônio público, à moralidade administrativa, ao meio ambiente ou ao patrimônio histórico e cultural — não é o instrumento de retificação de dados pessoais.

BIZU DE PROVA:
O habeas data (art. 5º, LXXII) tem duas alíneas que sempre caem separadas: "a" (conhecer as informações) e "b" (retificar dados, quando não se prefira processo sigiloso/judicial/administrativo). Essa questão testa exatamente a alínea "b".'),
(723, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
A pichação de monumento público não se enquadra na liberdade de expressão da atividade intelectual, artística, científica ou de comunicação (art. 5º, IX) porque envolve dano ao patrimônio público, conduta tipificada como crime pelo art. 65 da Lei 9.605/1998 (pichar, grafitar ou por outro meio conspurcar edificação ou monumento urbano sem autorização) — a liberdade de expressão protege o conteúdo manifestado, não o meio ilícito de manifestá-lo sobre bem público sem consentimento.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Discurso em praça pública sobre qualquer tema, incluindo temas polêmicos, está amparado pela livre manifestação do pensamento (art. 5º, IV) e pela liberdade de expressão (art. 5º, IX) — enquadra-se no disposto pelo artigo, não sendo a exceção pedida.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Reunião pacífica para defender determinada ideia, ainda que controversa, é exercício do direito de reunião (art. 5º, XVI) combinado com a liberdade de expressão — está amparada pelo artigo.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Exibição de música e canto religioso em via pública é manifestação artística e de culto, amparada pelo art. 5º, VI e IX — está dentro do disposto pelo artigo.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Exposição de escultura, ainda que de temática sexual, é atividade artística amparada pelo art. 5º, IX, que veda expressamente a censura prévia a manifestações artísticas.

BIZU DE PROVA:
A liberdade de expressão artística protege o CONTEÚDO controverso ou chocante — mas não protege o MEIO ilícito de expressá-lo, como danificar patrimônio público. Pichar um monumento não é "arte protegida", é crime contra o patrimônio público (Lei 9.605/98, art. 65).'),
(724, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O art. 5º, XI, autoriza o ingresso em domicílio sem consentimento do morador em caso de desastre — uma inundação que impede as pessoas de saírem de casa configura essa hipótese, autorizando o ingresso a qualquer hora para retirada dos ocupantes.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Som alto incomodando vizinhos não é flagrante delito, desastre ou situação de socorro que autorize o ingresso em domicílio alheio sem consentimento.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Buscar um animal doméstico no quintal do vizinho não se enquadra em nenhuma das hipóteses do art. 5º, XI.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Gritos de pessoa com doença mental grave, isoladamente e sem outros elementos, não configuram por si só flagrante delito ou desastre que autorizem o ingresso.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Pedido de vizinhos relatando luzes acesas durante viagem dos proprietários não configura flagrante delito, desastre ou socorro — não autoriza por si só o ingresso no domicílio.

BIZU DE PROVA:
"Desastre" no art. 5º, XI, abrange qualquer situação de calamidade que coloque em risco a vida ou a integridade de quem está dentro do imóvel (incêndio, desabamento, inundação) — pense em "risco físico iminente às pessoas dentro do imóvel" para reconhecer essa hipótese.'),
(725, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O art. 5º, XI, autoriza o ingresso em domicílio sem consentimento do morador em caso de flagrante delito, a qualquer hora do dia ou da noite. Um estupro em curso, presenciado ou fundadamente indicado por gritos de socorro no momento em que ocorre, configura flagrante delito, autorizando o ingresso imediato do agente público, independentemente de mandado judicial ou do horário noturno.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Não há abuso de autoridade quando o ingresso decorre de hipótese constitucionalmente autorizada — pelo contrário, a omissão do agente diante de crime em curso é que poderia gerar responsabilização.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A situação relatada não se limita a "socorro" isolado: há um crime em curso sendo presenciado por meio dos gritos, o que caracteriza diretamente flagrante delito, também previsto no mesmo inciso XI como autorizador do ingresso a qualquer hora.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O impedimento ao ingresso noturno sem mandado não se aplica apenas aos casos de desastre — só existe para a hipótese de determinação judicial; flagrante delito, desastre e socorro autorizam o ingresso a qualquer hora, inclusive à noite.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O ingresso amparado por flagrante delito não configura invasão ilegal — é hipótese expressamente autorizada pelo art. 5º, XI, da Constituição Federal.

BIZU DE PROVA:
Crime sendo cometido NO MOMENTO em que o agente ingressa (mesmo sem vê-lo diretamente, mas com fortes indícios como gritos de socorro durante a prática do crime) é flagrante delito — não confunda com "socorro" isolado, que se aplica quando não há necessariamente um crime em curso, como um acidente doméstico.'),
(726, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA (é a alternativa INCORRETA, pedida pelo enunciado):
O art. 5º, XI, autoriza a determinação judicial como hipótese de ingresso em domicílio apenas "durante o dia" — a alternativa erra ao substituir essa restrição temporal por "a qualquer tempo", como se a determinação judicial autorizasse o ingresso também à noite. As demais hipóteses do mesmo inciso (flagrante delito, desastre, socorro) é que valem a qualquer hora — a determinação judicial, isoladamente, só vale de dia.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (é uma afirmativa correta, portanto não é a exceção pedida):
Reproduz literalmente o art. 5º, X, da CF/88.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA (é uma afirmativa correta, portanto não é a exceção pedida):
Reproduz literalmente o art. 5º, XXVII, da CF/88.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA (é uma afirmativa correta, portanto não é a exceção pedida):
Reproduz literalmente o art. 5º, LI, da CF/88.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA (é uma afirmativa correta, portanto não é a exceção pedida):
Reproduz literalmente o art. 5º, LVIII, da CF/88.

BIZU DE PROVA:
No art. 5º, XI, apenas a hipótese de determinação judicial é restrita a "durante o dia" — flagrante delito, desastre e socorro valem a qualquer hora. Trocar "durante o dia" por "a qualquer tempo" é um dos erros mais comuns inseridos pelas bancas nesse inciso.'),
(727, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA (é a alternativa INCORRETA, pedida pelo enunciado):
O art. 5º, XVII, assegura que é plena a liberdade de associação para fins lícitos, mas VEDA expressamente a de caráter paramilitar — a alternativa inverte o comando ao afirmar que a liberdade de associação "inclui" a de caráter paramilitar, quando a Constituição proíbe exatamente esse tipo de associação.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (é uma afirmativa correta, portanto não é a exceção pedida):
Reproduz literalmente o art. 5º, IV, da CF/88.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA (é uma afirmativa correta, portanto não é a exceção pedida):
Reproduz literalmente o art. 5º, XXV, da CF/88.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA (é uma afirmativa correta, portanto não é a exceção pedida):
Reproduz literalmente o art. 5º, XLI, da CF/88.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA (é uma afirmativa correta, portanto não é a exceção pedida):
Reproduz literalmente o art. 5º, LX, da CF/88.

BIZU DE PROVA:
No art. 5º, XVII, a liberdade de associação é "plena para fins lícitos", mas com uma vedação expressa: caráter PARAMILITAR. É a única restrição textual desse inciso, e é o alvo preferido das bancas para inverter o sentido (de "vedada" para "permitida"/"inclusive").'),
(775, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A vedação à tortura e a tratamento desumano ou degradante (art. 5º, III) é expressão direta do princípio da dignidade da pessoa humana, fundamento da República Federativa do Brasil previsto no art. 1º, III, da CF/88 — a integridade física e moral do indivíduo é um dos núcleos mais diretos de proteção da dignidade humana.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Soberania (art. 1º, I) é o fundamento relativo à independência do Estado brasileiro nas relações internas e externas, sem relação direta com a vedação à tortura.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Cidadania (art. 1º, II) refere-se à participação política e ao vínculo jurídico-político do indivíduo com o Estado, não é o fundamento mais diretamente relacionado à vedação de tratamento desumano.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Valores sociais do trabalho e da livre iniciativa (art. 1º, IV) dizem respeito à ordem econômica, sem relação direta com a proteção contra tortura ou tratamento degradante.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Pluralismo político (art. 1º, V) trata da diversidade de ideias e organizações políticas, sem relação direta com a integridade física e moral da pessoa.

BIZU DE PROVA:
Sempre que a questão perguntar qual fundamento da República sustenta a proteção contra tortura/tratamento degradante/violação da integridade física ou moral, a resposta quase sempre é dignidade da pessoa humana (art. 1º, III) — é o fundamento "guarda-chuva" de praticamente todos os direitos individuais do art. 5º.'),
(797, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
A sequência correta é V-F-V. Item 1 (verdadeiro): reproduz parte do art. 5º, XXI — as entidades associativas, quando expressamente autorizadas, têm legitimidade para representar seus filiados judicialmente. Item 2 (falso): o art. 5º, XXI, exige expressamente autorização — a assertiva erra ao dispensar essa exigência. Item 3 (verdadeiro): reproduz a outra parte do mesmo inciso — as entidades associativas, quando expressamente autorizadas, também têm legitimidade para representar seus filiados extrajudicialmente.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Marca o item 1 como falso, quando na verdade é verdadeiro.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Marca todos os itens como falsos, mas os itens 1 e 3 descrevem corretamente o alcance do art. 5º, XXI, e são verdadeiros.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Marca o item 3 como falso, quando na verdade é verdadeiro.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Marca o item 2 como verdadeiro, quando na verdade é falso — a exigência de autorização expressa não pode ser dispensada.

BIZU DE PROVA:
O art. 5º, XXI, tem duas exigências que sempre andam juntas: autorização EXPRESSA dos filiados, e abrangência JUDICIAL OU EXTRAJUDICIAL. Questões que retiram a exigência de autorização expressa, ou que restringem o alcance só ao judicial ou só ao extrajudicial, estão erradas.'),
(846, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A sequência correta é V-F-V. Item 1 (verdadeiro): reproduz o art. 5º, XLIX — "é assegurado aos presos o respeito à integridade física e moral". Item 2 (falso): o art. 5º, §1º, estabelece que as normas definidoras dos direitos e garantias fundamentais têm aplicação IMEDIATA, não eficácia limitada — a assertiva inverte o comando constitucional expresso. Item 3 (verdadeiro): reproduz o art. 5º, L — "às presidiárias serão asseguradas condições para que possam permanecer com seus filhos durante o período de amamentação".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Marca o item 2 como verdadeiro, quando na verdade é falso — o art. 5º, §1º, determina aplicação imediata, não eficácia limitada.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Marca o item 1 como falso, quando na verdade reproduz literalmente o art. 5º, XLIX, e é verdadeiro.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Marca todos os itens como falsos, mas os itens 1 e 3 reproduzem literalmente incisos do art. 5º e são verdadeiros.

BIZU DE PROVA:
O art. 5º, §1º ("aplicação imediata") é um dos pontos mais cobrados sobre direitos fundamentais e frequentemente aparece disfarçado como "eficácia limitada". Memorize: direitos e garantias fundamentais têm aplicação IMEDIATA por comando constitucional expresso, não dependem de lei regulamentadora para produzir efeitos.'),
(847, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA (é a alternativa INCORRETA, pedida pelo enunciado):
O art. 5º, XV, assegura a livre locomoção no território nacional apenas EM TEMPO DE PAZ — a alternativa erra ao estender essa liberdade também ao "tempo de guerra", hipótese em que a Constituição admite restrições à locomoção.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA (é uma afirmativa correta, portanto não é a exceção pedida):
Reproduz literalmente o art. 5º, IX, da CF/88.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA (é uma afirmativa correta, portanto não é a exceção pedida):
Reproduz literalmente o art. 5º, XIII, da CF/88.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA (é uma afirmativa correta, portanto não é a exceção pedida):
Reproduz literalmente o art. 5º, X, da CF/88.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA (é uma afirmativa correta, portanto não é a exceção pedida):
Reproduz literalmente o art. 5º, XXII, da CF/88.

BIZU DE PROVA:
O direito de livre locomoção (art. 5º, XV) só vale expressamente "em tempo de paz" — é um dos poucos incisos do art. 5º com essa condicionante temporal explícita, e bancas gostam de apagá-la ou de estendê-la também ao tempo de guerra para forçar o erro.'),
(848, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O art. 5º, XLVII, "a", veda a pena de morte, salvo em caso de guerra declarada, nos termos do art. 84, XIX, da CF/88.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A pena de caráter perpétuo é vedada pelo art. 5º, XLVII, "b", sem exceção para caso de guerra — vedação absoluta, diferente da pena de morte.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A pena cruel é vedada pelo art. 5º, XLVII, "e", também sem exceção para caso de guerra — vedação absoluta.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A pena de banimento é vedada pelo art. 5º, XLVII, "d", sem exceção para caso de guerra — vedação absoluta.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A pena de trabalhos forçados é vedada pelo art. 5º, XLVII, "c", sem exceção para caso de guerra — vedação absoluta.

BIZU DE PROVA:
Das 5 penas vedadas pelo art. 5º, XLVII (morte, caráter perpétuo, trabalhos forçados, banimento, cruéis), APENAS a pena de morte tem exceção constitucional (guerra declarada, nos termos do art. 84, XIX). As outras quatro são vedações absolutas, sem exceção nenhuma.'),
(849, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Apenas o item I é literalmente texto da Constituição Federal de 1988 — reproduz o art. 5º, L ("às presidiárias serão asseguradas condições para que possam permanecer com seus filhos durante o período de amamentação"). Os itens II, III e IV, apesar de expressarem valores humanísticos relevantes, não são texto da CF/88: reproduzem, respectivamente, os artigos 1º, 16(2) e 23(3) da Declaração Universal dos Direitos Humanos de 1948 — documento internacional distinto da Constituição brasileira, ainda que compatível em espírito com vários de seus princípios (como a dignidade da pessoa humana, art. 1º, III, CF).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Inclui os itens II e III como corretos, mas nenhum dos dois é texto literal da Constituição Federal — são trechos da Declaração Universal dos Direitos Humanos.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Inclui os itens III e IV como corretos, mas nenhum dos dois é texto literal da Constituição Federal — são trechos da Declaração Universal dos Direitos Humanos.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Inclui os itens II e IV como corretos junto com o item I, mas II e IV não são texto literal da Constituição Federal — são trechos da Declaração Universal dos Direitos Humanos.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Inclui todos os itens como corretos, mas apenas o item I é texto literal da Constituição — II, III e IV pertencem à Declaração Universal dos Direitos Humanos, não à CF/88.

BIZU DE PROVA:
Questões que pedem "literalidade do texto constitucional" são pegadinhas clássicas para misturar CF/88 com Declaração Universal dos Direitos Humanos, tratados internacionais ou doutrina — desconfie de frases muito "bonitas"/genéricas de direitos humanos que não soam com o estilo técnico-jurídico brasileiro; pode ser sinal de que são de outro documento.');

-- ----------------------------------------------------------------------------
-- Snapshot ANTES.
-- ----------------------------------------------------------------------------
-- 1) linha inteira das 21 (exceto explicacao/atualizado_em -- os unicos
-- campos autorizados a mudar).
create temporary table _le1a_snap_questoes on commit drop as
select id, (to_jsonb(q) - 'explicacao' - 'atualizado_em') as dados_imutaveis
from public.questoes q
where q.id in (46,112,298,326,657,658,660,661,662,663,723,724,725,726,727,775,797,846,847,848,849);

-- 2) alternativas completas das 21.
create temporary table _le1a_snap_alternativas on commit drop as
select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
from public.alternativas a
where a.questao_id in (46,112,298,326,657,658,660,661,662,663,723,724,725,726,727,775,797,846,847,848,849)
group by questao_id;

-- 3) controle negativo -- linha COMPLETA (inclusive explicacao/atualizado_em)
-- e alternativas da questao 659, que NAO deve ser tocada por este harness
-- em hipotese alguma.
create temporary table _le1a_snap_659 on commit drop as
select to_jsonb(q) as linha_completa
from public.questoes q where q.id = 659;

create temporary table _le1a_snap_659_alt on commit drop as
select jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
from public.alternativas a where a.questao_id = 659;

-- 4) hash de explicacao de TODAS as questoes do banco, para provar depois
-- que nenhuma linha fora das 21 teve explicacao alterada.
create temporary table _le1a_snap_hash_todas on commit drop as
select id, md5(coalesce(explicacao, '')) as hash_explicacao
from public.questoes;

-- 5) contagens globais.
create temporary table _le1a_snap_global on commit drop as
select
  (select count(*) from public.questoes)            as total_questoes_antes,
  (select count(*) from public.questoes where ativa) as total_ativas_antes;

create temporary table _le1a_asserts (ordem serial primary key, descricao text, ok boolean) on commit drop;

-- ----------------------------------------------------------------------------
-- Precondicoes.
-- ----------------------------------------------------------------------------
do $$
declare
  v_qtd int;
begin
  if (select count(*) from _le1a_novas_explicacoes) <> 21 then
    raise exception 'PRECONDICAO FALHOU: staging nao tem exatamente 21 explicacoes';
  end if;

  select count(*) into v_qtd from public.questoes where id in (select id from _le1a_novas_explicacoes);
  if v_qtd <> 21 then
    raise exception 'PRECONDICAO FALHOU: esperado 21 questoes no banco, encontrado %', v_qtd;
  end if;

  if exists (
    select 1 from public.questoes q
    join _le1a_novas_explicacoes s on s.id = q.id
    where q.assunto_id is distinct from 71 or q.materia_id is distinct from 10 or q.ativa is distinct from true
  ) then
    raise exception 'PRECONDICAO FALHOU: alguma das 21 nao esta mais no estado auditado (assunto_id=71, materia_id=10, ativa=true)';
  end if;

  if not exists (select 1 from public.questoes where id = 659) then
    raise exception 'PRECONDICAO FALHOU: questao 659 nao encontrada -- o controle negativo depende dela existir';
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ESCRITA (unica): atualiza explicacao + atualizado_em das 21, capturando os
-- ids efetivamente afetados. Questao 659 nunca aparece em _le1a_novas_explicacoes,
-- logo nunca pode ser tocada por este UPDATE.
-- ----------------------------------------------------------------------------
create temporary table _le1a_ids_afetados (id bigint primary key) on commit drop;

do $$
declare
  v_linhas int;
begin
  with atualizado as (
    update public.questoes q
    set explicacao = s.explicacao, atualizado_em = now()
    from _le1a_novas_explicacoes s
    where q.id = s.id
    returning q.id
  )
  insert into _le1a_ids_afetados (id) select id from atualizado;

  get diagnostics v_linhas = row_count;
  if v_linhas <> 21 then
    raise exception 'ESCRITA FALHOU: esperado UPDATE de exatamente 21 linhas, afetou %', v_linhas;
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ASSERTS pos-escrita.
-- ----------------------------------------------------------------------------
do $$
declare
  v_completas int;
  v_total_depois int;
  v_ativas_depois int;
  v_sem_correta int;
begin
  insert into _le1a_asserts (descricao, ok)
  select 'exatamente 21 questoes afetadas pelo UPDATE', (select count(*) from _le1a_ids_afetados) = 21;

  insert into _le1a_asserts (descricao, ok)
  select 'os ids afetados sao exatamente os 21 esperados',
    (select array_agg(id order by id) from _le1a_ids_afetados) = ARRAY[46,112,298,326,657,658,660,661,662,663,723,724,725,726,727,775,797,846,847,848,849]::bigint[];

  insert into _le1a_asserts (descricao, ok)
  select 'questao 659 nao foi alterada (linha inteira identica, inclusive explicacao/atualizado_em)',
    (select to_jsonb(q) from public.questoes q where q.id = 659) = (select linha_completa from _le1a_snap_659);

  insert into _le1a_asserts (descricao, ok)
  select 'alternativas da questao 659 continuam identicas',
    (select jsonb_agg(to_jsonb(a) order by a.ordem) from public.alternativas a where a.questao_id = 659) = (select alternativas from _le1a_snap_659_alt);

  insert into _le1a_asserts (descricao, ok)
  select 'enunciado/alternativas-relacao/gabarito/materia/assunto/ativa/banca/concurso/ano/fonte preservados nas 21 (comparacao jsonb byte-a-byte, exceto explicacao/atualizado_em)',
    not exists (
      select 1 from public.questoes q
      join _le1a_snap_questoes s on s.id = q.id
      where (to_jsonb(q) - 'explicacao' - 'atualizado_em') <> s.dados_imutaveis
    );

  insert into _le1a_asserts (descricao, ok)
  select 'alternativas das 21 continuam byte-identicas (texto/correta/ordem)',
    not exists (
      select 1
      from _le1a_snap_alternativas s
      join (
        select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
        from public.alternativas a
        where a.questao_id in (select id from _le1a_novas_explicacoes)
        group by questao_id
      ) d on d.questao_id = s.questao_id
      where d.alternativas <> s.alternativas
    );

  select count(*) into v_sem_correta
  from _le1a_novas_explicacoes s
  where (select count(*) from public.alternativas a where a.questao_id = s.id and a.correta) <> 1;
  insert into _le1a_asserts (descricao, ok) values ('as 21 continuam com exatamente 1 alternativa correta cada', v_sem_correta = 0);

  -- Classificacao EXPLICACAO_COMPLETA das 21 apos o UPDATE (mesma logica de
  -- supabase/classificar_explicacoes_questoes.sql).
  with alt_stats as (
    select q.id as questao_id, count(a.id) as n_alt, count(a.id) filter (where a.correta) as n_corretas,
      bool_and(lower(btrim(a.texto)) in ('certo', 'errado')) and count(a.id) = 2 as eh_certo_errado
    from public.questoes q
    left join public.alternativas a on a.questao_id = q.id
    where q.id in (select id from _le1a_novas_explicacoes)
    group by q.id
  ),
  classificado as (
    select q.id,
      case
        when q.explicacao is null or btrim(q.explicacao) = '' then 'SEM_EXPLICACAO'
        when s.n_corretas <> 1 or s.n_alt = 0 then 'PROBLEMATICA'
        when s.eh_certo_errado then
          case
            when q.explicacao ~* 'GABARITO\s*:\s*(CERTO|ERRADO)' and q.explicacao ~* 'POR QUE\s*:' and q.explicacao ~* 'BIZU DE PROVA'
              then 'EXPLICACAO_COMPLETA'
            else 'OUTRO'
          end
        else
          case
            when q.explicacao ~* 'GABARITO\s*:' and q.explicacao ~* 'BIZU DE PROVA'
             and (select count(distinct m[1]) from regexp_matches(q.explicacao, 'POR QUE A ALTERNATIVA\s+([A-E])\s+EST[ÁA]\s+(CORRETA|INCORRETA)', 'gi') as m) >= s.n_alt
              then 'EXPLICACAO_COMPLETA'
            else 'OUTRO'
          end
      end as status
    from public.questoes q
    join alt_stats s on s.questao_id = q.id
    where q.id in (select id from _le1a_novas_explicacoes)
  )
  select count(*) filter (where status = 'EXPLICACAO_COMPLETA') into v_completas from classificado;
  insert into _le1a_asserts (descricao, ok) values ('as 21 passam no classificador canonico como EXPLICACAO_COMPLETA', v_completas = 21);

  insert into _le1a_asserts (descricao, ok)
  select 'nenhuma outra questao do banco teve explicacao alterada',
    not exists (
      select 1 from public.questoes q
      join _le1a_snap_hash_todas s on s.id = q.id
      where md5(coalesce(q.explicacao, '')) <> s.hash_explicacao
        and q.id <> ALL(ARRAY[46,112,298,326,657,658,660,661,662,663,723,724,725,726,727,775,797,846,847,848,849]::bigint[])
    );

  select count(*) into v_total_depois from public.questoes;
  insert into _le1a_asserts (descricao, ok) values ('total de questoes no banco inalterado (nenhuma criada/excluida)', v_total_depois = (select total_questoes_antes from _le1a_snap_global));

  select count(*) into v_ativas_depois from public.questoes where ativa = true;
  insert into _le1a_asserts (descricao, ok) values ('total de questoes ATIVAS do Papiro inalterado', v_ativas_depois = (select total_ativas_antes from _le1a_snap_global));
end $$;

-- Percorre os asserts na ordem em que foram inseridos, reportando cada um
-- (RAISE NOTICE) e abortando a transacao inteira no primeiro que falhar
-- (RAISE EXCEPTION). A tabela _le1a_asserts desaparece sozinha ao fim da
-- transacao (ON COMMIT DROP).
do $$
declare
  r record;
  v_total integer;
  v_ok integer;
begin
  for r in select descricao, ok from _le1a_asserts order by ordem loop
    if r.ok then
      raise notice 'OK: %', r.descricao;
    else
      raise exception 'FALHOU: %', r.descricao;
    end if;
  end loop;

  select count(*), count(*) filter (where ok) into v_total, v_ok from _le1a_asserts;
  raise notice '=== RESUMO: % / % asserts passaram ===', v_ok, v_total;
  if v_ok <> v_total then
    raise exception 'Harness falhou: nem todos os asserts passaram (ver RESUMO acima).';
  end if;
end $$;

-- Nada commitado: staging, snapshots e o UPDATE em si -- tudo desfeito abaixo.
ROLLBACK;
