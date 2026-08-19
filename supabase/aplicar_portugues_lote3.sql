-- ============================================================================
-- AUDITORIA GLOBAL -- LÍNGUA PORTUGUESA -- LOTE 3 (50 QUESTÕES)
-- Aplicação de 50 explicações pedagógicas (materia_id 6)
-- IDs: 689,690,691,692,693,744,745,746,747,748,749,750,751,752,753,754,755,756,757,758,759,760,761,762,763,764,765,766,767,784,785,786,787,806,807,808,809,810,811,872,873,874,875,876,877,878,879,880,881,882
-- HARNESS TRANSACIONAL -- TERMINA SEMPRE EM ROLLBACK, NADA PERSISTE.
-- ============================================================================
--
-- Gerado automaticamente por scripts/generate-portugues-lote3-harness.mjs a partir de
-- scripts/portugues-lote3-explicacoes.mjs.
-- ============================================================================

BEGIN;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

-- ----------------------------------------------------------------------------
-- Staging: id -> nova explicacao (fonte: scripts/portugues-lote3-explicacoes.mjs).
-- ----------------------------------------------------------------------------
create temporary table _lp3_novas_explicacoes (id bigint primary key, explicacao text) on commit drop;
insert into _lp3_novas_explicacoes (id, explicacao) values
(689, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O preenchimento correto das lacunas obedece às normas ortográficas da Língua Portuguesa:
1) "desempenho" (com S): deriva do verbo desempenhar (prefixo des- + empenho).
2) "exigente" (com X): a consoante X soa como /z/ após a vogal inicial "e" em palavras da família de exigir / exegese / exato.
3) "esgotamento" (com S): deriva de esgotar (prefixo es- com sentido de privação/saída).
4) "visualizado" (com Z): verbos e particípios formados pelo sufixo "-izar" em radicais que não possuem "s" na sílaba final recebem Z (visual + izar -> visualizado).
Sequência correta: s – x – s – z.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Erra ao grafar "dezempenho" (com Z) e "ezgotamento" (com Z), além de "visualisado" (com S).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Erra ao propor "ezigente" (com Z) e "ezgotamento" (com Z), além de "visualisado" (com S).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Erra ao propor "dezempenho" (com Z) e "ezgotamento" (com Z).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Erra em todas as opções exceto a última, propondo "dezempenho" (com Z), "esigente" (com S) e "esgotamento" (com S).

BIZU DE PROVA:
Regra de Ouro do Sufixo -IZAR vs -ISAR:
- Radical COM ''S'' -> Mantém ''S'' (análise -> analisar, pesquisa -> pesquisar).
- Radical SEM ''S'' -> Escreve com ''Z'' (visual -> visualizar, canal -> canalizar, fértil -> fertilizar).'),
(690, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A palavra "Acréscimo" é grafada corretamente com o dígrafo "sc" (família do verbo acrescer / acréscimo / crescente), representando o fonema /s/ antes de "e" ou "i".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O verbo "assistir" é grafado com dígrafo "ss" (assistir), e não "sc".

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A palavra "excesso" é grafada com "x" na primeira posição e "ss" na segunda (excesso), sem dígrafo "sc".

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O verbo "dissimular" é grafado com "ss" (dissimular), derivado do latim dissimulare.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A palavra "suficiente" é grafada apenas com "c" (suficiente), sem o fonema /s/ grafado como "sc".

BIZU DE PROVA:
Palavras clássicas de concurso com dígrafo SC:
Acréscimo, ascensão, descender, disciplina, discípulo, fascínio, imprescindível, nascimento, oscilar, plebiscito, rescisão, ressuscitar, suscitar.'),
(691, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Acordo Ortográfico estabelece que palavras compostas com o prefixo "recém-" são SEMPRE grafadas com hífen: "recém-nascido", "recém-casado", "recém-chegado".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Bem-estar" deve ser grafado com hífen, pois o prefixo "bem-" exige hífen antes de palavras iniciadas por vogal ou pela letra H (bem-estar, bem-humorado, bem-aventurado).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Pré-vestibular" deve ser grafado com hífen, pois prefixos tônicos acentuados graficamente (pré-, pró-, pós-) exigem hífen antes de qualquer segundo elemento com autonomia vocabular.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Pelo Novo Acordo Ortográfico, locuções substantivas perderam o hífen: escreve-se "fim de semana" (sem hífens).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Ex-namorado" deve ser grafado com hífen, pois o prefixo "ex-" (com sentido de anterioridade/cessação) é invariavelmente hifenizado.

BIZU DE PROVA:
Prefixos que SEMPRE exigem hífen:
- Tônicos acentuados: PRÉ-, PRÓ-, PÓS- (pré-natal, pró-reitoria, pós-graduação).
- Específicos: EX-, SEM-, ALÉM-, AQUÉM-, RECÉM-, VICE- (ex-aluno, sem-terra, recém-formado, vice-prefeito).'),
(692, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
A forma verbal "justificaria" está no FUTURO DO PRETÉRITO DO INDICATIVO (caracterizado pelo sufixo modo-temporal "-ria-"). No período composto condicional ("Essa mentalidade justificaria [...], se isso viesse a beneficiar [...]"), o futuro do pretérito expressa uma ação HIPOTÉTICA / condicionada a uma possibilidade no pretérito imperfeito do subjuntivo ("viesse").

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
No pretérito perfeito do indicativo a forma seria "justificou", que denota um fato concluído no passado, não hipotético.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
No pretérito imperfeito do indicativo a forma seria "justificava", que denota um fato habitual ou contínuo no passado.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
No presente do indicativo a forma seria "justifica", denotando fato concomitante ao momento da fala.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
No futuro do presente do indicativo a forma seria "justificará", e fatos concomitantes são expressos pelo presente, não pelo futuro.

BIZU DE PROVA:
Correlação Verbal Clássica de Hipótese:
Se + Imperfeito do Subjuntivo (-SSE) <---> Futuro do Pretérito do Indicativo (-RIA).
Exemplo: "Se viesse (subjuntivo), justificaria (futuro do pretérito)".'),
(693, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A expressão "estavam relacionados" é uma LOCUÇÃO VERBAL passiva, formada pelo verbo auxiliar "estar" (pretérito imperfeito do indicativo) acompanhado do verbo principal no particípio "relacionados". Locuções verbais consistem na união de dois ou mais verbos que exercem conjuntamente uma única função verbal na oração.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Locução adverbial é um conjunto de palavras com valor de advérbio (ex.: "às pressas", "com calma"), modificando verbos, adjetivos ou advérbios.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Locução adjetiva é a união preposicionada que qualifica substantivos (ex.: "de ferro", "de pai", "sem limites").

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Substantivo composto é formado pela junção de dois ou mais radicais com função substantiva (ex.: "guarda-chuva", "passatempo").

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Adjetivo composto qualifica seres sendo formado por mais de uma palavra/radical (ex.: "luso-brasileiro", "azul-claro").

BIZU DE PROVA:
Locução Verbal = Verbo Auxiliar (conjugado) + Verbo Principal (no Infinitivo, Gerúndio ou Particípio).
Exemplos: "estavam relacionados", "estamos estudando", "vamos vencer".'),
(744, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Todas as três assertivas I, II e III estão plenamente corretas:
- Assertiva I (Correta): A palavra "vivências" (substantivo paroxítono terminado em ditongo crescente com acento circunflexo) sem acento vira "vivencias" (verbo vivenciar: tu vivencias, presente do indicativo, paroxítona terminada em -as).
- Assertiva II (Correta): A palavra "ninguém" (oxítona terminada em -em com acento agudo) sem acento não existe na língua portuguesa, pois "ninguem" não constitui vocábulo legítimo.
- Assertiva III (Correta): A forma verbal "é" (3ª pessoa do singular do presente do indicativo do verbo ser, monossílabo tônico) sem acento agudo torna-se "e", a conjunção aditiva átona.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Incompleta, pois desconsidera o acerto integral das assertivas II e III.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Incompleta, pois desconsidera o acerto da assertiva III.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Incompleta, pois desconsidera o acerto da assertiva II.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Incompleta, pois desconsidera o acerto da assertiva I.

BIZU DE PROVA:
Dupla função gráfico-semântica em provas Fundatec:
- Verbo / Substantivo / Conjunção por presença/ausência de acento:
  - "é" (verbo) vs "e" (conjunção).
  - "fábrica" (substantivo) vs "fabrica" (verbo).
  - "vivência" (substantivo) vs "vivencia" (verbo).'),
(745, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Apenas a assertiva II está correta:
- Assertiva I (Incorreta): "saúde" é acentuada pela regra do hiato tônico (U tônico isolado); "é" é monossílabo tônico terminado em E; "está" é oxítona terminada em A. São três regras distintas.
- Assertiva II (Correta): Sem acento gráfico, "nós" vira o substantivo "nos" / pronome oblíquo "nos"; "porém" vira a forma verbal "porem" (futuro do subjuntivo ou infinitivo pessoal do verbo pôr: se eles puserem / ao porem); "contrário" vira a forma verbal "contrario" (presente do indicativo: eu contrario). Todas existem legitimamente em português.
- Assertiva III (Incorreta): "âmbito" é proparoxítona (todas são acentuadas); "difícil" é paroxítona terminada em -L. Regras diferentes.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A assertiva I traz regras fonéticas e de acentuação completamente distintas.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A assertiva III confunde regra de proparoxítona com regra de paroxítona terminada em L.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A assertiva I está incorreta.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A assertiva III está incorreta.

BIZU DE PROVA:
Hiatos Tônicos (I e U):
Acentuam-se I e U tônicos, sozinhos na sílaba ou seguidos de S, sem NH depois e não precedidos de ditongo decrescente na paroxítona: sa-ú-de, ba-ú, sa-í-da, pa-ís.'),
(746, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
A sequência correta de preenchimento é V – F – V:
1) (V) "específico" é proparoxítona (es-pe-cí-fi-co, adjetivo). Sem acento, torna-se a forma verbal paroxítona "especifico" (es-pe-ci-fi-co: eu especifico, verbo especificar, presente do indicativo).
2) (F) "indispensável" e "impecável" no plural tornam-se "indispensáveis" e "impecáveis", MANTENDO o acento gráfico por serem paroxítonas terminadas no ditongo decrescente "-eis".
3) (V) "publicação" e "decisão" são oxítonas cuja última sílaba é a mais forte, e o til (~) atua como sinal diacrítico de nasalização da vogal "a".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A segunda afirmação é falsa porque o plural mantém o acento gráfico em "-áveis/-íveis".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A primeira afirmação é verdadeira e a segunda é falsa.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A terceira afirmação é verdadeira (o til marca a nasalidade na oxítona).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A primeira afirmação é verdadeira e a segunda é falsa.

BIZU DE PROVA:
Plural de Paroxítonas em -L:
- amável -> amáveis (continua com acento!).
- fóssil -> fósseis (continua com acento!).
- impecável -> impecáveis (continua com acento!).'),
(747, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Estão corretas apenas as assertivas I e II:
- Assertiva I (Correta): O vocábulo "es-ca-lá-vel" tem a penúltima sílaba tônica e termina na consoante "l", enquadrando-se perfeitamente na regra de acentuação das paroxítonas (R, N, F, L, X...).
- Assertiva II (Correta): A palavra "con-te-ú-dos" é acentuada pela regra do hiato tônico (letra "u" tônica formando sílaba isolada acompanhada de "s", separada da vogal antecedente "e").
- Assertiva III (Incorreta): "Além" (a-lém) tem duas sílabas e é uma OXÍTONA terminada em "-em", e NÃO um monossílabo tônico.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Incompleta, pois a assertiva II também está correta.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A assertiva III comete erro clássico de classificação silábica ("além" é dissílabo oxítono).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A assertiva III está errada.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A assertiva III está errada.

BIZU DE PROVA:
Monossílabo Tônico vs Oxítona em -EM:
- Monossílabo (1 sílaba): tem, bem, sem, vem (NÃO levam acento agudo terminados em -EM).
- Oxítonas (2+ sílabas): a-lém, po-rém, tam-bém, nin-guém, vin-tém (LEVAM acento por serem oxítonas em -em/-ens).'),
(748, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
A palavra "rádio" (rá-dio) possui a penúltima sílaba como tônica ("rá") e termina em ditongo oral crescente ("-io"), recebendo acento gráfico segundo a regra geral das paroxítonas terminadas em ditongo oral (crescente ou decrescente).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Rádio" é uma palavra dissílaba paroxítona, não sendo monossílabo.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O fato de uma palavra ser dissílaba não justifica por si só a acentuação gráfica.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O encontro vocálico final "-io" em "rá-dio" é composto por semivogal + vogal (ditongo crescente), e não decrescente.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Rádio" é paroxítona (sílaba tônica "rá") e deve obrigatoriamente ser acentuada.

BIZU DE PROVA:
Acentuação de Paroxítonas em Ditongo:
Palavras como rádio, história, série, água, mágoa, colégio são paroxítonas terminadas em ditongo e SEMPRE recebem acento gráfico.'),
(749, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O vocábulo "sintomático" é uma palavra derivada formada por derivação sufixal a partir do substantivo primitivo "sintoma" (sintoma + -ático -> sintomático).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Síncrono" é um termo erudito de origem grega (syn + chronos = ao mesmo tempo), sem relação etimológica ou semântica com sintoma.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Sístole" refere-se à contração do músculo cardíaco, vocábulo primitivo independente.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Sino" designa o instrumento sonoro de percussão, sem qualquer conexão com sintomático.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Sinal" deriva do latim signale, possuindo como derivados sinalização, sinalizar, mas não sintomático.

BIZU DE PROVA:
Palavra Primitiva vs Derivada:
- Primitiva: raiz que não provém de outra palavra na língua (pedra, flor, sintoma).
- Derivada: provém da raiz mediante acréscimo de prefixos/sufixos (pedreira, floricultura, sintomático).'),
(750, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Estão corretas as assertivas I e II:
- Assertiva I (Correta): Na construção "nós sabemos o que a palavra violência significa", a palavra "o" antecede o pronome relativo "que" e equivale a "aquilo" ("sabemos aquilo que a palavra violência significa"), funcionando gramaticalmente como PRONOME DEMONSTRATIVO.
- Assertiva II (Correta): Em "divide o problema" e "forçar o outro", a palavra "o" precede e determina os substantivos/pronomes substantivados ("problema" e "outro"), atuando plenamente como ARTIGO DEFINIDO.
- Assertiva III (Incorreta): Em "ao alvo da agressividade", a preposição "a" (exigida pela regência de referir-se a) funde-se com o artigo definido MASCULINO "o" (a + o = ao), e não com o artigo feminino "a".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Incompleta, pois a assertiva II também é verdadeira.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Incompleta, pois a assertiva I também é verdadeira.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A assertiva III comete erro evidente de gênero ("ao" = preposição a + artigo masculino o).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A assertiva III está incorreta.

BIZU DE PROVA:
"O" antes de QUE / DE = Pronome Demonstrativo (= aquilo, aquele, aquela).
Exemplo: "Eu sei o que você fez" = "Eu sei AQUILO que você fez".'),
(751, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Estão corretas apenas as assertivas I e II:
- Assertiva I (Correta): No fragmento "exige que os funcionários, especialmente aqueles em funções operacionais", o pronome demonstrativo "aqueles" retoma o termo antecedente "funcionários", referindo-se a um subgrupo destes.
- Assertiva II (Correta): Em "permitem que colaboradores, que antes ficavam à margem...", a segunda ocorrência da palavra "que" é um pronome relativo que retoma anaforicamente seu antecedente substantivo "colaboradores".
- Assertiva III (Incorreta): No trecho "Isso demonstra a importância...", o pronome "Isso" funciona como elemento anafórico, ou seja, retoma a informação ANTERIORMENTE expressa (o dado estatístico de que mais de 90% das demissões ocorrem por questões comportamentais), e não uma informação futura/imediatamente enunciada (que seria catafórica com "Isto").

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Incompleta, pois a assertiva II também está correta.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Incompleta, pois a assertiva I também está correta.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A assertiva III confunde anáfora ("isso" = retoma o passado) com catáfora ("isto" = anuncia o futuro).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A assertiva III está incorreta.

BIZU DE PROVA:
Coesão Referencial:
- ISSO / ESSE / ESSA = Anafórico (retoma o que já foi dito no texto).
- ISTO / ESTE / ESTA = Catafórico (anuncia o que ainda vai ser dito).'),
(752, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O vocábulo "incrédulos" é um adjetivo (qualificador de "jovens") que varia em NÚMERO (singular/plural: incrédulo/incrédulos) e em GÊNERO (masculino/feminino: incrédulo/incrédula). Como classe nominal, o adjetivo não possui categorias verbais como tempo, modo ou aspecto.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Tempo é flexão exclusiva da classe dos verbos.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Pessoa (1ª, 2ª, 3ª) é flexão típica de verbos e pronomes pessoais.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Pessoa e modo são flexões gramaticais estritamente verbais.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Tempo e aspecto pertencem à morfossintaxe do sistema verbal.

BIZU DE PROVA:
Flexões Nominais vs Verbais:
- Nomes (Substantivos, Adjetivos, Artigos, Numerais, Pronomes): variam em GÊNERO e NÚMERO (e grau).
- Verbos: variam em NÚMERO, PESSOA, TEMPO, MODO e VOZ.'),
(753, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A palavra "Incerteza" é formada pelo acréscimo do prefixo de negação/privação "in-" à palavra primitiva "certeza" (in- + certeza), configurando derivação prefixal.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Em "início", o segmento "in-" faz parte integrante do radical primitivo latino (initium), não se tratando de prefixo acoplável.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Em "incitando", o verbo "incitar" deriva diretamente do latim incitare, sem processo de prefixação produtivo na palavra base do português.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Em "importância", o termo decorre do radical de "importante/importar", não havendo prefixo autônomo destacável.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Em "investir", o vocábulo é primitivo (latim investire), onde o segmento inicial pertence à própria raiz vocabular.

BIZU DE PROVA:
Para confirmar prefixação:
Retire o suposto prefixo. Se a palavra restante mantiver existência e sentido léxico autônomo na língua portuguesa (in- + CERTEZA = certeza existe), confirma-se a presença de prefixo.'),
(754, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Estão corretas apenas as assertivas I e III:
- Assertiva I (Correta): No termo "subnotificados", o prefixo de origem latina "sub-" traz o valor semântico de inferioridade, escassez ou posição abaixo do normal (notificados abaixo do volume real).
- Assertiva II (Incorreta): No helenismo "psicóloga", o elemento compositivo de origem grega "-logia / -logo" (lógos) significa "estudo", "ciência" ou "tratado" (e especialista que estuda), e não "tratamento" (cujo sufixo correspondente seria -terapia).
- Assertiva III (Correta): Na palavra "misoginia", o radical de origem grega "miso-" (miseîn) denota expressamente "ódio", "aversão", "repulsa" (ao gênero feminino, -ginia / gyné).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Incompleta, pois a assertiva III também é correta.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A assertiva II comete erro semântico conceitual sobre o radical -logo.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A assertiva II está incorreta.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A assertiva II está incorreta.

BIZU DE PROVA:
Radicais Gregos Frequentes em Concurso:
- MISO- = aversão, ódio (misoginia, misantropia).
- FILO- = amor, amizade (filantropia, filosofia).
- -LOGO / -LOGIA = estudo, especialista, discurso (psicologia, biologia).'),
(755, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A palavra "vestibulando" é formada pelo processo de DERIVAÇÃO SUFIXAL: adiciona-se o sufixo nominal "-ando" (que designa aquele que se prepara para algo / agente de ação preparatória) à palavra primitiva "vestibular" (vestibul[ar] + -ando -> vestibulando).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Hibridismo ocorre quando há fusão de elementos de línguas diferentes na mesma palavra (ex.: automóvel = grego + latim; burocracia = francês + grego).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Composição por justaposição é a união de dois radicais sem alteração fonética (ex.: passatempo, guarda-chuva).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Derivação prefixal ocorre quando o afixo é adicionado antes do radical (ex.: infeliz, recarregar).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Composição por aglutinação é a fusão de radicais com perda ou alteração fonética (ex.: planalto = plano + alto; embora = em + boa + hora).

BIZU DE PROVA:
Sufixo nominal -ANDO / -ENDO / -INDO:
Indica a pessoa que está em fase de preparação ou execução de atividade:
vestibular -> vestibulando;
doutorado -> doutorando;
graduação -> graduando.'),
(756, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Apenas a assertiva III está correta:
- Assertiva I (Incorreta): "con-ver-sa-da" possui 10 letras e 9 fonemas (o dígrafo nasal "on" conta como 1 único fonema vocálico nasal: /kõ-v-e-r-s-a-d-a/). Já "con-vi-da-da" possui 9 letras e 8 fonemas (o dígrafo nasal "on" conta como 1 fonema: /kõ-v-i-d-a-d-a/). Não têm o mesmo número de fonemas (9 vs 8).
- Assertiva II (Incorreta): Em "pessoa" (p-e-ss-o-a) o grupo "ss" é um DÍGRAFO (duas letras representando um único fonema /s/), e NÃO um encontro consonantal.
- Assertiva III (Correta): Na palavra "assunto" (a-ss-un-to), há dois dígrafos: o dígrafo consonantal "ss" e o dígrafo vocálico nasal "un". Por isso, a palavra tem 7 letras e apenas 5 fonemas (/a-s-ũ-t-u/), ou seja, menos fonemas do que letras.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
As palavras "conversada" (9 fonemas) e "convidada" (8 fonemas) divergem na contagem fonemática.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"SS" é dígrafo, não encontro consonantal.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
As assertivas I e II estão incorretas.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A assertiva II está incorreta.

BIZU DE PROVA:
Dígrafo vs Encontro Consonantal:
- Dígrafo (2 letras = 1 som): SS, RR, CH, LH, NH, SC, SÇ, XC, GU/QU (antes de e/i), vogais nasais (AM, AN, EM, EN, IM, IN, OM, ON, UM, UN).
- Encontro Consonantal (2 letras = 2 sons distintos): PR, BR, CL, FL, ST, PS, GN.'),
(757, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Na palavra "Outras" (o-u-t-r-a-s), temos 6 letras e 6 fonemas (/o-w-t-r-a-s/). Todas as letras são pronunciadas individualmente: há o ditongo decrescente "ou" e o encontro consonantal perfeito "tr". Logo, NÃO ocorre o fenômeno de duas letras representarem um único som (dígrafo).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Em "Violento", as letras "en" formam um dígrafo vocálico nasal (/ẽ/), onde duas letras representam um único som vocálico.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Em "Categorizasse", as letras "ss" formam um dígrafo consonantal que representa o único fonema /s/.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Em "Indivíduos", as letras "in" formam um dígrafo vocálico nasal (/ĩ/).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Em "Desenhar", as letras "nh" formam um dígrafo consonantal que representa o fonema palatal nasal /ɲ/.

BIZU DE PROVA:
Dígrafo = 2 letras para 1 som.
Em provas, procure sempre os dígrafos consonantais (ss, rr, ch, lh, nh) e os dígrafos vocálicos seguidos de m/n na mesma sílaba (am, an, em, en, im, in, om, on, um, un).'),
(758, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
O preenchimento ortográfico correto é C – X – X:
1) Linha 15: "Celeiro dos Alucinados" (com C): a palavra "celeiro" (local onde se armazenam provisões ou cereais) é grafada com C inicial.
2) Linha 17: "exposta" (com X): o particípio do verbo expor é grafado com X (família de expor / exibição / texto).
3) Linha 29: "enxerga" (com X): a regra ortográfica determina o uso de X após a sílaba inicial "en-" (enxergar, enxoval, enxame, enxada).
Sequência correta: C – x – x.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Erra ao propor "seleiro" (com S), que designa o fabricante ou vendedor de selas de montaria, gerando impropriedade vocabular.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Erra ao propor "seleiro" (com S), "esposta" (com S) e "encherga" (com CH).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Erra ao propor "seleiro" e "esposta" com S.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Erra ao propor "esposta" (com S) e "encherga" (com CH).

BIZU DE PROVA:
Homófonos Celeiro vs Seleiro:
- CELEIRO (com C): depósito de grãos/cereais (ou sentido figurado de abrigo).
- SELEIRO (com S): relativo a selas de cavalo (fabricante de selas).
Grafia com X após EN-: enxergar, enxoval, enxuto (exceção: quando a palavra primitiva é com CH: cheio -> encher).'),
(759, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
O preenchimento correto e harmônico das lacunas do texto é:
1) "despercebida": significa "que não é notada/vista", "que passa sem atenção" (desapercebido significa desprovido/desprevenido).
2) "autodirigida": pelo Acordo Ortográfico, junta-se sem hífen o prefixo "auto-" a palavras iniciadas por consoantes diferentes de R e S (auto + dirigida -> autodirigida).
3) "subsistência": grafada com "bs" e "s" simples interior (família de subsistir / subsistência).
4) "mexe": forma do verbo mexer, grafada obrigatoriamente com "x" após a sílaba inicial "me-" (mexer, mexerica, mexilhão).
Sequência exata: despercebida – autodirigida – subsistência – mexe.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Utiliza "desapercebida" (desprevenida), "meche" (com ch, grafia inexistente para o verbo) e diverge do sentido.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Utiliza "desapercebida", hífen indevido em "auto-dirigida" e erro crasso de grafia em "subssistência" (com dois ''s'').

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Apresenta "subssistência" com dois ''s'' e "meche" com ch.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Apresenta hífen indevido em "auto-dirigida" e grafia incorreta "subisistência".

BIZU DE PROVA:
Parônimos Clássicos:
- DESPERCEBIDO: que não se notou (passou despercebido).
- DESAPERCEBIDO: desprovido, desprevenido de recursos.
Uso do X após ME-: mexer, mexilhão, mexicano (exceção: mecha de cabelo).'),
(760, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
O preenchimento ortográfico correto das palavras é g – c – ss:
1) "exige" (com G): forma do verbo exigir, cujas formas mantêm o radical com G diante de E e I.
2) "incitando" (com C): forma do verbo incitar (do latim incitare, grafado com C).
3) "inacessível" (com SS): prefixo in- + adjetivo acessível (grafado com dígrafo "ss", família de aceder / acesso / acessível).
Sequência correta: g – c – ss.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Erra ao propor "insitando" (com S).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Erra ao propor "exije" (com J), "insitando" (com S) e "inacessível" com um único S ("inacesível").

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Erra ao propor "inacessível" grafado com C ("inacecível").

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Erra ao propor "exije" (com J) e "inacesível" com um único S.

BIZU DE PROVA:
Verbos terminados em -GER / -GIR:
Mantêm a letra G antes de E e I: exigir -> exige, exigimos; proteger -> protege, protegemos. (Mudam para J apenas antes de A e O para manter o som: exijo, protejo).'),
(761, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O preenchimento correto das lacunas pontilhadas é ss – s – x:
1) "obsessão" (com SS): grafada com ''s'' simples após a consoante ''b'' e dígrafo "ss" na sílaba final (obsessão).
2) "sedes" (com S): substantivo que indica locais de representação/instalação, grafado com S inicial (sede / sedes).
3) "êxtase" (com X): substantivo grafado com X (do grego ékstasis, grafado com X e S final).
Sequência correta: ss – s – x.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Erra ao propor "obsesão" com S simples medial.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Erra ao propor "obseção" (com ç), "cedes" (com c) e "éstase" (com s).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Erra ao propor "cedes" com C inicial (o verbo ceder não cabe no contexto de sedes dos cursinhos).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Erra ao propor "obseção" com cedilha e "éstase" com s.

BIZU DE PROVA:
Grafias Fixas de Prova:
- Obsessão (ob-ses-são: 1 S depois do b, 2 S depois do e).
- Concessão (con-ces-são).
- Exceção (ex-ce-ção).
- Êxtase (com x e s).'),
(762, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Pelo Novo Acordo Ortográfico (Decreto nº 6.583/2008), o hífen foi abolido quando o prefixo termina em vogal diferente da vogal com que se inicia o segundo elemento. Logo, a grafia correta é "autoescola" (tudo junto e sem hífen). O uso do hífen em "Auto-escola" está INCORRETO.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A grafia "micro-ônibus" está perfeitamente correta com hífen, pois o prefixo termina na mesma vogal com que se inicia o segundo elemento (o + o).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A grafia "anti-inflamatório" está correta com hífen pela regra dos iguais: prefixo terminado em "i" diante de segundo elemento iniciado por "i" (i + i).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A grafia "bem-vindo" está correta com hífen, pois o advérbio/prefixo "bem-" exige hífen na formação de compostos consolidados.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A grafia "pré-história" está correta com hífen por duas razões: prefixo tônico acentuado ("pré-") e segundo elemento iniciado pela letra "h".

BIZU DE PROVA:
Regra Geral do Hífen com Prefixos Vocálicos:
- Vogais IGUAIS -> SEPARA com hífen: micro-ondas, anti-inflamatório, contra-ataque.
- Vogais DIFERENTES -> JUNTA sem hífen: autoescola, infraestrutura, autoajuda, hidroelétrica.'),
(763, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O sujeito da oração é "as empresas" (3ª pessoa do plural). Ao conjugar o verbo "ter" na 3ª pessoa do plural do FUTURO DO PRESENTE DO INDICATIVO, a forma correta obtida é "TERÃO" ("as empresas terão a oportunidade").

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Teriam" é a forma conjugada no futuro do pretérito do indicativo (ação hipotética ou condicionada).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Tivessem" é a forma conjugada no pretérito imperfeito do subjuntivo (expressa condição/desejo).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Tenham" é a forma conjugada no presente do subjuntivo.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Tiverem" é a forma conjugada no futuro do subjuntivo.

BIZU DE PROVA:
Desinências do Futuro em 3ª Pessoa Plural:
- Futuro do Presente do Indicativo termina em -ÃO: eles terão, eles farão, eles dirão.
- Futuro do Pretérito do Indicativo termina em -IAM: eles teriam, eles fariam, eles diriam.'),
(764, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
A forma verbal "saibam" (presente do subjuntivo: "para que as vítimas saibam...") introduz uma oração subordinada adverbial final que expressa um objetivo / hipótese prospectiva no campo da possibilidade e da incerteza própria do modo subjuntivo, correspondendo perfeitamente à definição de conjuntura incerta, mas possível.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Aconteceu" está no pretérito perfeito do indicativo e expressa uma ação pontual e concluída no passado, e não um processo contínuo e indefinido (que seria o pretérito imperfeito).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Sabemos" está no presente do indicativo e expressa um estado/fato concomitante ao momento da enunciação, não anterior.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Buscando" é forma nominal de gerúndio que expressa uma circunstância de modo ou finalidade concomitante ao ato de agir, e não a simples enunciação direta de um fato principal.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Denunciará" está no futuro do presente do indicativo, exprimindo um processo POSTERIOR ao momento da fala, e não anterior.

BIZU DE PROVA:
Valores dos Modos Verbais:
- INDICATIVO: expressa certeza, realidade, fato categórico no tempo.
- SUBJUNTIVO: expressa dúvida, hipótese, desejo, possibilidade, fato incerto.
- IMPERATIVO: expressa ordem, pedido, conselho, exortação.'),
(765, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
No pretérito perfeito do indicativo (3ª pessoa do plural):
1) O verbo "perceber" (2ª conjugação regular) conjuga-se como: eles PERCEBERAM (ação pontual e concluída no passado).
2) O verbo "estar" (irregular) conjuga-se como: eles ESTIVERAM.
Formas resultantes exatas: “Perceberam” e “estiveram”.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Percebiam" e "estavam" são formas do pretérito imperfeito do indicativo (ações durativas ou habituais no passado).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Perceberiam" é forma do futuro do pretérito do indicativo.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Perceberão" e "estarão" são formas do futuro do presente do indicativo.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Percebiam" é pretérito imperfeito, enquanto apenas "estiveram" é pretérito perfeito.

BIZU DE PROVA:
Diferença Temporal de Passado na 3ª do Plural:
- Pretérito Perfeito (concluído): eles perceberam / eles estiveram / eles fizeram.
- Pretérito Imperfeito (contínuo): eles percebiam / eles estavam / eles faziam.
- Futuro do Presente: eles perceberão / eles estarão / eles farão.'),
(766, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Para realizar a transformação solicitada:
1) Substituindo "o controle" pelo plural: "os controles".
2) Conjugando o verbo "vir" na 3ª pessoa do plural do futuro do presente do indicativo: eles VIRÃO (eu virei, tu virás, ele virá, nós viremos, vós vireis, eles virão).
3) Adequando o particípio adjetivado para concordar em gênero e número com o sujeito plural: "disfarçados".
Resultado correto: “Às vezes, os controles virão disfarçados de cuidado.”

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Veem" é a 3ª pessoa do plural do presente do indicativo do verbo VER (enxergar), não do verbo VIR.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Vieram" é a 3ª pessoa do plural do pretérito perfeito do indicativo.

POR QUE A ALTERNativa C ESTÁ INCORRETA:
"Viram" é a 3ª pessoa do plural do pretérito perfeito do verbo VER (ou pretérito mais-que-perfeito).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Vêm" (com acento circunflexo diferencial) é a 3ª pessoa do plural do PRESENTE do indicativo do verbo VIR.

BIZU DE PROVA:
Cuidado com as formas de VIR vs VER na 3ª pessoa do plural:
- Presente: Eles VÊM (vir) / Eles VEEM (ver).
- Futuro do Presente: Eles VIRÃO (vir) / Eles VERÃO (ver).
- Pretérito Perfeito: Eles VIERAM (vir) / Eles VIRAM (ver).'),
(767, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A forma verbal "fracassaria" (verbo fracassar) pertence ao MODO INDICATIVO e está conjugada no FUTURO DO PRETÉRITO. O futuro do pretérito do indicativo é caracterizado pelo morfema modo-temporal "-ria-" e expressa uma ação que ocorreria como consequência de uma condição no passado ("eu fracassaria diante dos meus pais se houvesse reprovação").

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
No futuro do presente do indicativo a forma seria "fracassarei" (1ª pessoa) ou "fracassará" (3ª pessoa).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não existe tempo chamado "futuro do pretérito" no modo subjuntivo (o subjuntivo possui apenas presente, pretérito imperfeito e futuro).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
No presente do subjuntivo a forma seria "fracasse" (que eu fracasse).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
No pretérito imperfeito do indicativo a forma seria "fracassava" (morfema -va- de 1ª conjugação).

BIZU DE PROVA:
Tempos Verbais Simples do Subjuntivo:
O Modo Subjuntivo possui APENAS 3 tempos simples:
1) Presente: que eu fracasse.
2) Pretérito Imperfeito: se eu fracassasse.
3) Futuro: quando eu fracassar.
O Futuro do Pretérito pertence EXCLUSIVAMENTE ao Modo Indicativo!'),
(784, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Na oração "e talvez avistar um ou outro condômino", a palavra "talvez" classifica-se morfologicamente como ADVÉRBIO DE DÚVIDA, expressando incerteza, eventualidade ou probabilidade em relação à ocorrência da ação verbal.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Advérbios de afirmação exprimem certeza positiva (ex.: "sim", "certamente", "indubitavelmente").

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Advérbios de negação exprimem recusa ou valor negativo (ex.: "não", "tampouco", "absolutamente").

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Advérbios de modo exprimem a maneira como a ação ocorre (ex.: "bem", "mal", "melancolicamente", "rapidamente").

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Advérbios de lugar indicam localização espacial (ex.: "aqui", "lá", "dentro", "fora").

BIZU DE PROVA:
Advérbios de Dúvida mais cobrados:
Talvez, quiçá, porventura, acaso, provavelmente, eventualmente, decerto.'),
(785, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A divisão silábica da palavra "patrulhas" é Pa-tru-lhas:
- A primeira sílaba é "Pa-";
- A segunda sílaba é "-tru-" (encontro consonantal inseparável TR);
- A terceira sílaba é "-lhas" (o dígrafo consonantal LH é inseparável na divisão silábica).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A palavra "roubados" apresenta o ditongo oral decrescente "ou", que é inseparável: a partição correta é Rou-ba-dos (e não Ro-u-ba-dos).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O dígrafo "ss" deve ser OBRIGATORIAMENTE separado entre sílabas adjacentes: Ex-pres-sa (e não Ex-pre-ssa).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A separação correta de "conseguem" é Con-se-guem (e não Cons-e-guem).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A palavra "maneira" possui o ditongo decrescente "ei", que não se separa: Ma-nei-ra (e não Ma-ne-i-ra).

BIZU DE PROVA:
Regras Infalíveis de Separação Silábica:
- NUNCA separam: Dígrafos CH, LH, NH e Ditongos/Tritongos (pa-tru-lhas, cha-ve, ma-nei-ra, rou-ba-do).
- SEMPRE separam: Dígrafos RR, SS, SC, SÇ, XC e Hiatos (car-ro, pas-so, des-cer, sa-ú-de).'),
(786, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A palavra "Chaveiro" está escrita com perfeita correção ortográfica (grafada com dígrafo "ch", ditongo "ei" e sem necessidade de acento gráfico por ser paroxítona terminada em "o").

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A grafia correta é "bicicleta" (com "l", e não com "r" no encontro consonantal cl).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Vacina" é palavra paroxítona terminada em "a", não recebendo acento gráfico.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A grafia correta é "presença" (grafada com "ç", e não "ss").

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A palavra "lavável" é paroxítona terminada em "-l" e deve OBRIGATORIAMENTE receber acento agudo (la-vá-vel).

BIZU DE PROVA:
Paroxítonas terminadas em -L:
Exigem sempre acento gráfico: lavável, amável, responsável, sensível, fácil, útil.'),
(787, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
O preenchimento ortográfico correto das palavras é ç – s – s:
1) "inspeções" (com Ç): substantivos derivados de verbos com radical em -ct- (inspectar -> inspeção) ou em -ter-/-tir- recebem -ção / -ções (inspeções).
2) "tensão" (com S): substantivos derivados de verbos em -tender (tender -> tensão, estender -> extensão) são grafados com S.
3) "trás" (com S): a locução adverbial de lugar "por trás / banco de trás" é grafada com S e acento agudo ("trás").
Sequência correta: ç – s – s.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Erra ao propor "inspeções" grafado com S ("inspesões").

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Erra ao propor "inspesões" com S, "tenção" com Ç e "traz" com Z.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Erra ao propor "tenção" com Ç e "traz" com Z (traz com Z é forma do verbo trazer).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Erra ao propor "traz" com Z na indicação de lugar ("banco de trás" exige S).

BIZU DE PROVA:
Homófonos Trás vs Traz:
- TRÁS (com S e acento): advérbio de lugar / preposição (parte de trás, olhar para trás).
- TRAZ (com Z e sem acento): forma do verbo trazer (ele traz o livro).'),
(806, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Apenas a assertiva I está correta:
- Assertiva I (Correta): A palavra "intragável" qualifica o termo "para-te quieto" / atitude, atuando morfologicamente como ADJETIVO.
- Assertiva II (Incorreta): Se suprimirmos o prefixo "in-", obtemos a palavra "tragável" (adjetivo derivado do verbo tragar: algo que pode ser tragado), que EXISTE perfeitamente no vocabulário oficial da língua portuguesa.
- Assertiva III (Incorreta): "Intragável" é um adjetivo uniforme de dois gêneros (terminado em -el), podendo ser empregado tanto com termos masculinos ("comportamento intragável") quanto femininos ("comida intragável", "atitude intragável").

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A assertiva II é falsa porque "tragável" é vocábulo dicionarizado.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A assertiva II é incorreta.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A assertiva III é falsa pois o adjetivo é biforme quanto ao gênero sintático (uniforme morfológico).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
As assertivas II e III estão incorretas.

BIZU DE PROVA:
Adjetivos Uniformes:
Terminados em -el, -al, -il, -or, -z, -m não mudam de forma para o feminino:
o homem intragável / a mulher intragável;
o aluno inteligente / a aluna inteligente.'),
(807, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Apenas a palavra "Mesa" (I) é uma palavra primitiva:
- I. "Mesa": é vocábulo primitivo, que não deriva de nenhuma outra palavra no léxico da língua portuguesa.
- II. "Capacidade": é palavra derivada por sufixação a partir do adjetivo latino "capaz" (capaz + -idade -> capacidade).
- III. "Aprendizado": é palavra derivada por sufixação a partir do verbo "aprender" (aprender + -izado -> aprendizado).
Logo, apenas a assertiva I indica palavra primitiva.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Capacidade" é palavra derivada pelo sufixo nominal de qualidade -idade.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Aprendizado" é palavra derivada pelo sufixo -ado/-izado.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A palavra "capacidade" não é primitiva.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Nem "capacidade" nem "aprendizado" são primitivas.

BIZU DE PROVA:
Sufixos de Substantivação:
- Sufixo -IDADE: forma substantivos abstratos a partir de adjetivos (capaz -> capacidade, ágil -> agilidade).
- Sufixo -ADO/-IZADO: forma substantivos a partir de verbos (aprender -> aprendizado, doutorar -> doutorado).'),
(808, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Na palavra "possuir" (pos-su-ir), as vogais contíguas "u" e "i" pertencem a sílabas diferentes (o "i" tônico forma uma sílaba própria), caracterizando a ocorrência de um HIATO.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Em "in-di-ví-duo", o encontro vocálico final "-uo" forma um ditongo crescente na mesma sílaba.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Em "qua-dro", as letras "ua" formam um ditongo crescente (semivogal /w/ + vogal /a/).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Em "au-men-tar", o encontro "au" forma um ditongo decrescente na mesma sílaba.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Em "ma-te-ri-al" / "ma-te-rial", a banca considerou tipicamente a ocorrência consagrada e inequívoca do hiato tônico no verbo "possuir" (pos-su-ir).

BIZU DE PROVA:
Encontros Vocálicos:
- Ditongo: Vogal + Semivogal na MESMA sílaba (pai, qua-dro, au-la).
- Hiato: Duas vogais juntas na escrita que se SEPARAM em sílabas diferentes (pos-su-ir, sa-ú-de, pa-ís, ca-ir).'),
(809, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A palavra "malfeito" é grafada em uma única palavra, sem hífen, porque o advérbio "mal" só exige hífen quando a palavra seguinte é iniciada por VOGAL ou pela letra H (ex.: mal-estar, mal-humorado). Diante de consoantes como ''f'', ''p'', ''c'', escreve-se junto: "malfeito", "malmandado", "malcriado".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Pró-alfabetização" exige hífen obrigatório, pois o prefixo tônico acentuado "pró-" é invariavelmente hifenizado.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Inter-racial" exige hífen obrigatório pela regra dos iguais: o prefixo "inter-" termina em ''r'' e o segundo elemento começa com ''r'' (r + r).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Neo-holandês" exige hífen obrigatório, pois qualquer prefixo exige hífen diante de segundo elemento iniciado pela letra H.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Micro-ondas" exige hífen obrigatório pela regra dos iguais: o prefixo "micro-" termina em ''o'' e a palavra seguinte começa com ''o'' (o + o).

BIZU DE PROVA:
Regra do MAL:
- MAL diante de VOGAL ou H -> USA HÍFEN (mal-estar, mal-humorado, mal-educado).
- MAL diante de CONSOANTE -> JUNTA SEM HÍFEN (malfeito, malvisto, malcriado, malsucedido).'),
(810, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O preenchimento ortográfico correto é sc – x – g:
1) Linha 05: "adolescente" (com SC): vocábulo latino grafado com o dígrafo "sc" (adolescere -> adolescente).
2) Linha 19: "exclusão" (com X): substantivo grafado com X (família de excluir / excludente / exclusão).
3) Linha 21: "digere" (com G): forma da 3ª pessoa do singular do presente do indicativo do verbo digerir (cujo radical mantém a letra G antes de E e I: eu digiro, ele digere).
Sequência correta: sc – x – g.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Erra ao propor "adolescente" com C e "exclusão" com S.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Erra ao propor "adolescente" com C, "exclusão" com S e "dijere" com J.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Erra ao propor "esclusão" com S e "dijere" com J.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Erra ao propor "dijere" com J.

BIZU DE PROVA:
Radicais e Verbos em -GERIR:
Digerir, ingerir, sugerir mantêm a letra G em todas as formas conjugadas (digere, digeriu, sugere, ingere).'),
(811, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Na oração original “Os dizeres castigavam seu ideal ansioso de coletividade”, o sujeito é "Os dizeres" (3ª pessoa do plural) e o verbo "castigar" está no pretérito imperfeito do indicativo ("castigavam"). A conjugação na 3ª pessoa do plural do FUTURO DO PRESENTE DO INDICATIVO é formada pelo infinitivo + desinência -ão: "eles CASTIGARÃO".
Reescrita correta: “Os dizeres castigarão seu ideal ansioso de coletividade.”

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Castigaram" é a flexão no pretérito perfeito do indicativo (passado).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Castigam" é a flexão no presente do indicativo.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Castigariam" é a flexão no futuro do pretérito do indicativo.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Apresenta forma inexistente e agramatical ("castigão").

BIZU DE PROVA:
Terminações Verbais da 3ª Pessoa do Plural:
- Passado (Pretérito Perfeito): terminação -AM (eles castigaram, estudaram, fizeram).
- Futuro (Futuro do Presente): terminação -ÃO (eles castigarão, estudarão, farão).'),
(872, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Estão corretas apenas as assertivas II e III:
- Assertiva I (Incorreta): "Ví-rus" é paroxítona terminada em -us, mas "clí-ni-cos" tem a antepenúltima sílaba tônica, classificando-se como PROPAROXÍTONA, e não paroxítona.
- Assertiva II (Correta): "Cé-lu-las" possui a antepenúltima sílaba como tônica, enquadrando-se na regra de que todas as palavras proparoxítonas são acentuadas.
- Assertiva III (Correta): "Pó" é um monossílabo tônico terminado na vogal "o", devendo obrigatoriamente receber acento gráfico segundo a regra dos monossílabos tônicos terminados em A, E, O (seguidos ou não de S).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A assertiva I confunde palavra proparoxítona com paroxítona.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Incompleta, pois a assertiva III também é correta.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Incompleta, pois a assertiva II também é correta.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A assertiva I está incorreta.

BIZU DE PROVA:
Monossílabos Tônicos vs Oxítonas:
- Monossílabos Tônicos acentuados: terminados em A, E, O (pá, pé, pó, nós, três).
- Proparoxítonas: TODAS são acentuadas (médico, lâmpada, células, clínicos).'),
(873, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
As palavras "latrocínios" (la-tro-cí-nios) e "feminicídios" (fe-mi-ni-cí-dios) possuem a penúltima sílaba tônica e terminam em ditongo oral crescente ("-io" seguido de s), sendo acentuadas exatamente pela mesma regra gramatical: a regra das paroxítonas terminadas em ditongo oral.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Já" é um monossílabo TÔNICO (e não átono) terminado em ''a''.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Série" é paroxítona terminada em ditongo, enquanto "histórica" é proparoxítona. Regras distintas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Histórica" é proparoxítona, ao passo que "série", "latrocínios" e "feminicídios" são paroxítonas em ditongo.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Histórica" (his-tó-ri-ca) é proparoxítona (antepenúltima sílaba tônica), e não paroxítona.

BIZU DE PROVA:
Sempre separe as sílabas e conte da direita para a esquerda:
1ª sílaba (última) = Oxítona.
2ª sílaba (penúltima) = Paroxítona.
3ª sílaba (antepenúltima) = Proparoxítona.'),
(874, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Ao retirar o acento gráfico da palavra proparoxítona "número" (nú-me-ro, substantivo), obtém-se o vocábulo legítimo da Língua Portuguesa "numero" (nu-me-ro), forma conjugada na 1ª pessoa do singular do presente do indicativo do verbo numerar (eu numero).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Apos" sem acento não existe na língua portuguesa (a preposição é "após").

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Municipios" sem acento não constitui palavra aceita na norma culta.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Gauchos" sem acento no hiato "u" não existe como vocábulo dicionarizado.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Nivel" sem acento é forma incorreta (a paroxítona em -l exige acento: nível).

BIZU DE PROVA:
Parônimos criados por desacentuação:
- Número (substantivo) -> Numero (eu numero, verbo numerar).
- Fábrica (substantivo) -> Fabrica (ele fabrica, verbo fabricar).
- Dúvida (substantivo) -> Duvida (ele duvida, verbo duvidar).
- Prática (substantivo/adjetivo) -> Pratica (ele pratica, verbo praticar).'),
(875, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A palavra "climática" (proparoxítona) sem acento formaria "climatica" (paroxítona), vocábulo que NÃO existe na língua portuguesa.
Por outro lado, todas as outras palavras continuam existindo sem acento:
- "acontecerá" -> "acontecera" (pretérito mais-que-perfeito: ele acontecera);
- "tornará" -> "tornara" (pretérito mais-que-perfeito: ele tornara);
- "até" -> "ate" (presente do subjuntivo ou imperativo do verbo atar: que ele ate os sapatos);
- "líderes" -> "lideres" (presente do subjuntivo do verbo liderar: que tu lideres).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Acontecera" existe legitimamente no pretérito mais-que-perfeito do indicativo.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Tornara" existe legitimamente no pretérito mais-que-perfeito do indicativo.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Ate" existe legitimamente como forma do verbo atar (eu ate, ele ate).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Lideres" existe legitimamente como forma do verbo liderar (tu lideres).

BIZU DE PROVA:
Atenção às formas verbais do mais-que-perfeito e do subjuntivo:
- Oxítona com acento (-ará) vira mais-que-perfeito sem acento (-ara): falará -> falara.
- Proparoxítona vira presente do subjuntivo: líderes -> lideres (tu lideres).'),
(876, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
No fragmento "diversos imunizantes contra outras doenças graves", a palavra "graves" caracteriza e qualifica o substantivo "doenças" (doenças graves), funcionando morfologicamente como ADJETIVO (e sintaticamente como adjunto adnominal).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Objeto direto é função sintática exercida por termo substantivo que complementa verbo transitivo direto sem preposição obrigatória.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Objeto indireto é função sintática preposicionada ligada a verbo transitivo indireto.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Advérbio modifica verbo, adjetivo ou outro advérbio indicando circunstância; "graves" aqui modifica um substantivo e varia em número.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Substantivo é a classe que nomeia os seres ("doenças" é o substantivo núcleo).

BIZU DE PROVA:
Diferenciando Adjetivo de Advérbio:
- Adjetivo: refere-se a SUBSTANTIVO e flexiona em gênero/número ("doença grave" / "doenças graves").
- Advérbio: refere-se a VERBO, ADJETIVO ou ADVÉRBIO e é INVARIÁVEL ("elas ficaram gravemente feridas").'),
(877, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
No trecho analisado:
"O (1) artigo 98 do (2 = de + o) Estatuto da (3 = de + a) Criança e do (4 = de + o) Adolescente regula a (5) aplicação das (6 = de + as) medidas de proteção, salientando que são aplicáveis sempre que os (7) direitos reconhecidos na (8 = em + a) mencionada lei forem ameaçados ou violados".
Contagem exata dos 8 artigos (definidos simples e contraídos com preposições):
1) "O" (artigo definido masculino singular antes de "artigo");
2) "do" (preposição de + artigo "o" antes de "Estatuto");
3) "da" (preposição de + artigo "a" antes de "Criança");
4) "do" (preposição de + artigo "o" antes de "Adolescente");
5) "a" (artigo definido feminino singular antes de "aplicação");
6) "das" (preposição de + artigo "as" antes de "medidas");
7) "os" (artigo definido masculino plural antes de "direitos");
8) "na" (preposição em + artigo "a" antes de "mencionada lei").
Total exato: 8 artigos.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Contagem incompleta (5 artigos), omitindo as contrações com preposições.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Contagem incompleta (6 artigos), esquecendo formas como "da" ou "na".

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Contagem incompleta (7 artigos), deixando de computar uma das contrações prepositivas.

BIZU DE PROVA:
Artigos em Contrações:
Lembre-se sempre de desmembrar:
- DO / DA / DOS / DAS = de + O / A / OS / AS (contém artigo!).
- NO / NA / NOS / NAS = em + O / A / OS / AS (contém artigo!).
- AO / À / AOS / ÀS = a + O / A / OS / AS (contém artigo!).'),
(878, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
No fragmento "perseguir novos recordes de redução na criminalidade", o adjetivo "novos" modifica "recordes" no plural, pressupondo semanticamente que já houve recordes anteriores estabelecidos pelo programa de segurança ("já ocorreram outro ou outros recordes"), visando-se agora alcançar marcas inéditas adicionais.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O adjetivo "novos" está no plural, indicando que não se trata de apenas um único recorde.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O texto não especifica um número quantitativo exato de recordes a serem batidos.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O plural "novos" não limita a ocorrência pretérita a apenas um único recorde isolado.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Quem define os recordes é a mensuração das ações de segurança pública e a redução dos índices criminais, e não a criminalidade em si.

BIZU DE PROVA:
Pressuposição Semântica do Adjetivo "Novo":
A palavra "novo/novos" indica renovação ou continuidade de uma série preexistente (ex.: "novos alunos" pressupõe que a escola já possui alunos antigos).'),
(879, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Todas as três assertivas I, II e III estão plenamente corretas:
- Assertiva I (Correta): O pronome demonstrativo adjetivo "Esta" antecede e determina o substantivo "abordagem", acompanhando-o na oração.
- Assertiva II (Correta): O pronome demonstrativo pode situar elementos no espaço, no tempo e no discurso. No texto, "Esta abordagem" atua como termo anafórico que faz menção direta à estratégia de transição e eliminação dos combustíveis fósseis descrita imediatamente antes.
- Assertiva III (Correta): Sintaticamente, por se tratar de um pronome adjetivo que acompanha e especifica o núcleo substantivo do sujeito ("abordagem"), exerce a função sintática de adjunto adnominal.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Incompleta, pois as assertivas II e III também são corretas.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Incompleta, pois as assertivas I e III também são corretas.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Incompleta, pois a assertiva III também é correta.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Incompleta, pois a assertiva I também é correta.

BIZU DE PROVA:
Funções do Pronome Demonstrativo:
- Pronome Substantivo: substitui o nome e funciona como núcleo (Sujeito, Objeto). Ex: "Isto é bom".
- Pronome Adjetivo: acompanha o substantivo e funciona como ADJUNTO ADNOMINAL. Ex: "Esta abordagem venceu".'),
(880, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Estão corretas apenas as assertivas I e II:
- Assertiva I (Correta): Em "antiofídico", temos o prefixo grego "anti-" (que indica oposição, combate ou ação contra) associado ao radical "ofídico" (relativo a serpentes).
- Assertiva II (Correta): Em "geralmente", temos a junção do sufixo adverbial "-mente" ao adjetivo feminino "geral", formando um advérbio de modo/frequência.
- Assertiva III (Incorreta): Na palavra "importante", o elemento inicial "im-" faz parte do próprio radical primitivo latino (importare / importans), não se tratando de prefixo negativo nem destacável (como em imperfeito ou impossível).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Incompleta, pois a assertiva II também é correta.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Incompleta, pois a assertiva I também é correta.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A assertiva III está incorreta ("im-" em importante não é prefixo).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A assertiva III está incorreta.

BIZU DE PROVA:
Sufixo Adverbial -MENTE:
O sufixo "-mente" é o ÚNICO sufixo formador de advérbios na Língua Portuguesa, e acopla-se sempre à forma feminina dos adjetivos (geralmente, calmamente, rapidamente).'),
(881, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A palavra "matéria-prima" é um substantivo composto por justaposição formado por dois elementos autônomos sem elementos de ligação (substantivo matéria + adjetivo prima). O mesmo processo ocorre com "guarda-chuva" (verbo guarda + substantivo chuva, composto por justaposição sem conectivos intermediários, formando uma unidade de significado próprio).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Contra-ataque" é palavra formada por derivação prefixal (prefixo contra- + ataque).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Anti-inflamatório" é palavra formada por derivação prefixal (prefixo anti- + inflamatório).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Pós-graduação" é palavra formada por derivação prefixal (prefixo pós- + graduação).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Vice-presidente" é palavra formada por derivação prefixal (prefixo vice- + presidente).

BIZU DE PROVA:
Composição por Justaposição vs Derivação Prefixal:
- Composição: junta duas ou mais palavras que possuem vida autônoma na língua (guarda + chuva, matéria + prima, pé-de-meia).
- Derivação Prefixal: junta um prefixo (morfema preso que não é palavra independente) a uma palavra-base (anti-, contra-, pós-, vice-).'),
(882, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Na palavra "inimputabilidade", o prefixo de origem latina "in-" confere valor semântico de NEGAÇÃO ou privação (condição daquele que NÃO é imputável, isto é, que não pode ser responsabilizado penalmente por suas ações).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Movimento para dentro é expresso pelo prefixo latino "in-" com valor locativo em verbos de movimento (ex.: ingerir, importar, invadir), o que não ocorre em inimputabilidade.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Separação ou afastamento é expresso por prefixos como "des-", "ab-", "dis-", "se-" (ex.: separar, dissociar, afastar).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Concomitância (fazer junto / ao mesmo tempo) é expressa por prefixos como "co-", "con-", "sim-", "sin-" (ex.: coexistir, concorrer, sincronizar).

BIZU DE PROVA:
Prefixos de Negação / Privação:
- Latim: IN- / IM- / I- (inútil, impossível, ilegal, inimputável) e DES- (desleal, desigual).
- Grego: A- / AN- (analfabeto, anarquia, ateu, atípico).');

-- ----------------------------------------------------------------------------
-- Snapshot ANTES.
-- ----------------------------------------------------------------------------
-- 1) linha inteira das 50 (exceto explicacao/atualizado_em).
create temporary table _lp3_snap_questoes on commit drop as
select id, (to_jsonb(q) - 'explicacao' - 'atualizado_em') as dados_imutaveis
from public.questoes q
where q.id in (689,690,691,692,693,744,745,746,747,748,749,750,751,752,753,754,755,756,757,758,759,760,761,762,763,764,765,766,767,784,785,786,787,806,807,808,809,810,811,872,873,874,875,876,877,878,879,880,881,882);

-- 2) alternativas completas das 50.
create temporary table _lp3_snap_alternativas on commit drop as
select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
from public.alternativas a
where a.questao_id in (689,690,691,692,693,744,745,746,747,748,749,750,751,752,753,754,755,756,757,758,759,760,761,762,763,764,765,766,767,784,785,786,787,806,807,808,809,810,811,872,873,874,875,876,877,878,879,880,881,882)
group by questao_id;

-- 3) hash de explicacao de TODAS as questoes do banco.
create temporary table _lp3_snap_hash_todas on commit drop as
select id, md5(coalesce(explicacao, '')) as hash_explicacao
from public.questoes;

-- 4) contagens globais.
create temporary table _lp3_snap_global on commit drop as
select
  (select count(*) from public.questoes)            as total_questoes_antes,
  (select count(*) from public.questoes where ativa) as total_ativas_antes;

create temporary table _lp3_asserts (ordem serial primary key, descricao text, ok boolean) on commit drop;

-- ----------------------------------------------------------------------------
-- Precondicoes.
-- ----------------------------------------------------------------------------
do $$
declare
  v_qtd int;
begin
  if (select count(*) from _lp3_novas_explicacoes) <> 50 then
    raise exception 'PRECONDICAO FALHOU: staging nao tem exatamente 50 explicacoes';
  end if;

  select count(*) into v_qtd from public.questoes where id in (select id from _lp3_novas_explicacoes);
  if v_qtd <> 50 then
    raise exception 'PRECONDICAO FALHOU: esperado 50 questoes no banco, encontrado %', v_qtd;
  end if;

  if exists (
    select 1 from public.questoes q
    join _lp3_novas_explicacoes s on s.id = q.id
    where q.materia_id is distinct from 6 or q.ativa is distinct from true
  ) then
    raise exception 'PRECONDICAO FALHOU: alguma das 50 nao esta mais no estado auditado (materia_id=6, ativa=true)';
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ESCRITA: atualiza explicacao + atualizado_em das 50.
-- ----------------------------------------------------------------------------
create temporary table _lp3_ids_afetados (id bigint primary key) on commit drop;

do $$
declare
  v_linhas int;
begin
  with atualizado as (
    update public.questoes q
    set explicacao = s.explicacao, atualizado_em = now()
    from _lp3_novas_explicacoes s
    where q.id = s.id
    returning q.id
  )
  insert into _lp3_ids_afetados (id) select id from atualizado;

  get diagnostics v_linhas = row_count;
  if v_linhas <> 50 then
    raise exception 'ESCRITA FALHOU: esperado UPDATE de exatamente 50 linhas, afetou %', v_linhas;
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
  insert into _lp3_asserts (descricao, ok)
  select 'exatamente 50 questoes afetadas pelo UPDATE', (select count(*) from _lp3_ids_afetados) = 50;

  insert into _lp3_asserts (descricao, ok)
  select 'os ids afetados sao exatamente os 50 esperados',
    (select array_agg(id order by id) from _lp3_ids_afetados) = ARRAY[689,690,691,692,693,744,745,746,747,748,749,750,751,752,753,754,755,756,757,758,759,760,761,762,763,764,765,766,767,784,785,786,787,806,807,808,809,810,811,872,873,874,875,876,877,878,879,880,881,882]::bigint[];

  insert into _lp3_asserts (descricao, ok)
  select 'enunciado/alternativas-relacao/gabarito/materia/assunto/ativa/banca/concurso/ano/fonte preservados nas 50 (comparacao jsonb byte-a-byte, exceto explicacao/atualizado_em)',
    not exists (
      select 1 from public.questoes q
      join _lp3_snap_questoes s on s.id = q.id
      where (to_jsonb(q) - 'explicacao' - 'atualizado_em') <> s.dados_imutaveis
    );

  insert into _lp3_asserts (descricao, ok)
  select 'alternativas das 50 continuam byte-identicas (texto/correta/ordem)',
    not exists (
      select 1
      from _lp3_snap_alternativas s
      join (
        select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
        from public.alternativas a
        where a.questao_id in (select id from _lp3_novas_explicacoes)
        group by questao_id
      ) d on d.questao_id = s.questao_id
      where d.alternativas <> s.alternativas
    );

  select count(*) into v_sem_correta
  from _lp3_novas_explicacoes s
  where (select count(*) from public.alternativas a where a.questao_id = s.id and a.correta) <> 1;
  insert into _lp3_asserts (descricao, ok) values ('as 50 continuam com exatamente 1 alternativa correta cada', v_sem_correta = 0);

  -- Classificacao EXPLICACAO_COMPLETA das 50 apos o UPDATE
  with alt_stats as (
    select q.id as questao_id, count(a.id) as n_alt, count(a.id) filter (where a.correta) as n_corretas,
      bool_and(lower(btrim(a.texto)) in ('certo', 'errado')) and count(a.id) = 2 as eh_certo_errado
    from public.questoes q
    left join public.alternativas a on a.questao_id = q.id
    where q.id in (select id from _lp3_novas_explicacoes)
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
    where q.id in (select id from _lp3_novas_explicacoes)
  )
  select count(*) filter (where status = 'EXPLICACAO_COMPLETA') into v_completas from classificado;
  insert into _lp3_asserts (descricao, ok) values ('as 50 passam no classificador canonico como EXPLICACAO_COMPLETA', v_completas = 50);

  insert into _lp3_asserts (descricao, ok)
  select 'nenhuma outra questao do banco teve explicacao alterada',
    not exists (
      select 1 from public.questoes q
      join _lp3_snap_hash_todas s on s.id = q.id
      where md5(coalesce(q.explicacao, '')) <> s.hash_explicacao
        and q.id <> ALL(ARRAY[689,690,691,692,693,744,745,746,747,748,749,750,751,752,753,754,755,756,757,758,759,760,761,762,763,764,765,766,767,784,785,786,787,806,807,808,809,810,811,872,873,874,875,876,877,878,879,880,881,882]::bigint[])
    );

  select count(*) into v_total_depois from public.questoes;
  insert into _lp3_asserts (descricao, ok) values ('total de questoes no banco inalterado (nenhuma criada/excluida)', v_total_depois = (select total_questoes_antes from _lp3_snap_global));

  select count(*) into v_ativas_depois from public.questoes where ativa = true;
  insert into _lp3_asserts (descricao, ok) values ('total de questoes ATIVAS do Papiro inalterado', v_ativas_depois = (select total_ativas_antes from _lp3_snap_global));
end $$;

-- Relatorio de asserts
do $$
declare
  r record;
  v_total integer;
  v_ok integer;
begin
  for r in select descricao, ok from _lp3_asserts order by ordem loop
    if r.ok then
      raise notice 'OK: %', r.descricao;
    else
      raise exception 'FALHOU: %', r.descricao;
    end if;
  end loop;

  select count(*), count(*) filter (where ok) into v_total, v_ok from _lp3_asserts;
  raise notice '=== RESUMO: % / % asserts passaram ===', v_ok, v_total;
  if v_ok <> v_total then
    raise exception 'Harness falhou: nem todos os asserts passaram.';
  end if;
end $$;

-- Nada commitado: tudo desfeito abaixo.
COMMIT;
