-- ============================================================================
-- AUDITORIA GLOBAL -- LÍNGUA PORTUGUESA -- LOTE 2 (50 QUESTÕES)
-- Aplicação de 50 explicações pedagógicas (materia_id 6)
-- IDs: 242,243,244,245,273,274,275,276,277,278,279,280,281,282,283,284,304,305,306,307,308,316,317,318,319,320,321,322,323,324,325,328,329,330,331,332,333,334,335,336,679,680,681,682,683,684,685,686,687,688
-- HARNESS TRANSACIONAL -- TERMINA SEMPRE EM ROLLBACK, NADA PERSISTE.
-- ============================================================================
--
-- Gerado automaticamente por scripts/generate-portugues-lote2-harness.mjs a partir de
-- scripts/portugues-lote2-explicacoes.mjs.
-- ============================================================================

BEGIN;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

-- ----------------------------------------------------------------------------
-- Staging: id -> nova explicacao (fonte: scripts/portugues-lote2-explicacoes.mjs).
-- ----------------------------------------------------------------------------
create temporary table _lp2_novas_explicacoes (id bigint primary key, explicacao text) on commit drop;
insert into _lp2_novas_explicacoes (id, explicacao) values
(242, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A forma verbal "faria" (verbo fazer) está conjugada na 1ª ou 3ª pessoa do singular do FUTURO DO PRETÉRITO DO INDICATIVO. O futuro do pretérito é caracterizado pela desinência modo-temporal "-ria-" e expressa uma ação futura condicionada a um fato passado ou uma hipótese ("se eu pudesse, faria").

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
No futuro do presente do indicativo a forma verbal correspondente é "fará" (ou "farei"), caracterizada pelo morfema "-rá-/-rei".

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
No pretérito perfeito do indicativo a forma verbal é "fez" (ou "fiz"), indicando ação pontual e concluída no passado.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
No presente do subjuntivo a forma é "faça" (que eu faça, que ele faça), expressando desejo ou dúvida presente.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
No imperativo negativo a forma é "não faças" (tu) ou "não faça" (você), derivada diretamente do presente do subjuntivo.

BIZU DE PROVA:
Desinências modo-temporais infalíveis do Indicativo:
- Desinência "-RIA-" = Futuro do Pretérito (estudaria, faria, iria).
- Desinência "-RÁ-/-REI-" = Futuro do Presente (estudará, fará, irá).
- Desinência "-VA-/-IA-" = Pretérito Imperfeito (estudava, fazia, ia).'),
(243, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Na oração "A equipe concluiu o relatório", o sujeito sintático "A equipe" é o AGENTE da ação verbal, isto é, pratica ativamente a ação expressa pelo verbo transitivo direto "concluiu". Essa estrutura define tipicamente a VOZ ATIVA.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Na voz passiva analítica o sujeito é paciente e a estrutura é formada por verbo auxiliar + particípio ("O relatório foi concluído pela equipe").

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Na voz passiva sintética (ou pronominal) emprega-se o verbo transitivo direto acompanhado do pronome apassivador "se" ("Concluiu-se o relatório").

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Na voz reflexiva o sujeito pratica e recebe simultaneamente a ação verbal sobre si mesmo ("O homem feriu-se").

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Na voz recíproca dois ou mais agentes praticam e sofrem a ação mutuamente ("Os candidatos cumprimentaram-se").

BIZU DE PROVA:
Vozes Verbais em 1 minuto:
1) ATIVA: Sujeito PRATICA a ação ("A equipe concluiu o relatório").
2) PASSIVA: Sujeito RECEBE a ação ("O relatório foi concluído").
3) REFLEXIVA: Sujeito pratica e sofre EM SI MESMO ("O jovem cortou-se").
4) RECÍPROCA: Ação mútua entre dois ou mais sujeitos ("Eles abraçaram-se").'),
(244, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Na oração ativa "Os candidatos (sujeito agente) resolveram (VTD no pretérito perfeito) as questões (objeto direto)", a transposição para a voz passiva analítica segue rigorosamente a regra gramatical:
1) O objeto direto torna-se sujeito paciente: "As questões";
2) O verbo principal vira locução passiva com o verbo auxiliar "ser" no mesmo tempo do original (pretérito perfeito plural) + particípio: "foram resolvidas";
3) O sujeito agente torna-se agente da passiva preposicionado: "pelos candidatos".
Forma resultante: "As questões foram resolvidas pelos candidatos".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Mantém a estrutura na voz ativa e inverte o sentido, colocando "As questões" praticando a ação de resolver os candidatos.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Apresenta estrutura de passiva sintética truncada ("Resolveram-se os candidatos"), alterando completamente o sentido original.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Inverte os papéis semânticos, transformando os candidatos em sujeito paciente que foi resolvido pelas questões.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Apresenta construção agramatical ("tinham resolver") sem qualquer respaldo na norma culta.

BIZU DE PROVA:
Mecânica da Voz Passiva Analítica:
Objeto Direto da Ativa $\rightarrow$ Sujeito Paciente da Passiva.
Verbo Ativo (passado simples "resolveram") $\rightarrow$ Verbo SER no mesmo tempo + Particípio ("foram resolvidas").
Sujeito da Ativa $\rightarrow$ Agente da Passiva ("pelos candidatos").'),
(245, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Na oração "Vendem-se apartamentos", o verbo "vender" é transitivo direto (VTD) e está acompanhado da partícula apassivadora "se". O termo "apartamentos" funciona sintaticamente como SUJEITO PACIENTE (equivale a "Apartamentos são vendidos"). A estrutura formada por "VTD + se + sujeito paciente" caracteriza a VOZ PASSIVA SINTÉTICA (ou pronominal).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não se trata de voz ativa, pois quem vende não está expresso como sujeito praticante da ação; "apartamentos" é termo paciente.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não há reflexividade; os apartamentos não realizam a ação de vender a si próprios.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A voz passiva analítica correspondente seria "Apartamentos são vendidos" (com verbo auxiliar ser + particípio). Como a oração utiliza o pronome "se", é passiva sintética.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não há reciprocidade de ação entre múltiplos sujeitos.

BIZU DE PROVA:
Identificação do SE Apassivador vs. Índice de Indeterminação:
- VTD + SE + Substantivo $\rightarrow$ Partícula Apassivadora / Passiva Sintética. O substantivo é sujeito e o verbo concorda: "Vende-se casa" / "Vendem-se casas".
- VTI / VI / VL + SE $\rightarrow$ Índice de Indeterminação do Sujeito. Verbo sempre no singular: "Precisa-se de funcionários".'),
(273, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Na frase "Os candidatos estudaram bastante", a palavra "bastante" modifica o verbo "estudaram", intensificando a ação verbal com o sentido de "muito" ou "em grande quantidade". Palavras que modificam verbos, adjetivos ou outros advérbios exprimindo circunstância (aqui de intensidade) classificam-se morfologicamente como ADVÉRBIO (e permanecem invariáveis).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Substantivo é a classe que dá nome aos seres e objetos; "bastante" não funciona como núcleo substantivo na frase.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Artigo é determinante que define ou indefine substantivos (o, a, um, uma).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Preposição é conectivo que liga termos em dependência sintática (de, em, por, para).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Pronome relativo introduz oração subordinada adjetiva retomando termo antecedente (que, quem, cujo, onde).

BIZU DE PROVA:
Diferença entre BASTANTE Advérbio vs. Pronome:
- Ligado a VERBO (sentido de "muito") = ADVÉRBIO $\rightarrow$ Fica INVARIÁVEL: "Eles estudaram bastante".
- Ligado a SUBSTANTIVO (sentido de "muitos/muitas") = PRONOME INDEFINIDO $\rightarrow$ Flexiona no plural: "Eles leram bastantes livros" (= muitos livros).'),
(274, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Na frase "Aquela prova estava difícil", a palavra "Aquela" acompanha o substantivo "prova", situando-o no espaço e no discurso como algo distante tanto do emissor quanto do receptor. Trata-se de um PRONOME DEMONSTRATIVO adjetivo.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Advérbio modifica verbo, adjetivo ou advérbio, enquanto "aquela" determina diretamente um substantivo.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Conjunção é conectivo que liga orações ou termos de mesma função sintática.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Preposição é elemento de ligação invariável que introduz complementos.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O substantivo da frase é "prova"; "aquela" é apenas o seu pronome determinante.

BIZU DE PROVA:
Pronomes Demonstrativos e a posição espacial/temporal:
- ESTE, ESTA, ISTO: perto de quem fala (1ª pessoa) / presente imediato.
- ESSE, ESSA, ISSO: perto de quem ouve (2ª pessoa) / passado ou futuro próximo.
- AQUELE, AQUELA, AQUILO: distante de ambos (3ª pessoa) / passado remoto.'),
(275, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Em linguística e análise textual, o mecanismo pelo qual pronomes (e outros termos gramaticais) recuperam, remetem ou substituem referentes e conceitos já introduzidos previamente no texto denomina-se COESÃO REFERENCIAL (anafórica ou catafórica), garantindo a continuidade temática sem repetições desnecessárias.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Ambiguidade é um vício de linguagem que gera duplo sentido e prejudica a clareza; não é um mecanismo coesivo positivo.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Pontuação expressiva diz respeito ao uso estilístico de sinais de pontuação (reticências, exclamações), não à retomada pronominal de referentes.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Derivação lexical é processo morfológico de formação de novas palavras a partir de radicais.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Concordância nominal é a adequação de gênero e número entre o substantivo e seus modificadores.

BIZU DE PROVA:
Tipos de Coesão Textual:
- COESÃO REFERENCIAL: retomada de termos por pronomes, sinônimos, hiperônimos ou elipses ("O policial agiu rápido. Ele evitou o roubo").
- COESÃO SEQUENCIAL: encadeamento e articulação das ideias por meio de conjunções e conectivos ("Estudou, portanto foi aprovado").'),
(276, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O vocábulo "portanto" é classicamente classificado como uma conjunção coordenativa CONCLUSIVA. Ele introduz uma oração que expressa o desfecho, a dedução lógica ou a consequência necessária decorrente dos fatos apresentados na oração anterior ("Estudou muito; portanto, foi aprovado").

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A relação de oposição/contraste é expressa por conjunções adversativas (mas, porém, contudo, todavia).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A relação de causa é introduzida por conjunções causais (porque, já que, visto que, como).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A relação de condição é introduzida por conjunções condicionais (se, caso, contanto que).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A relação de concessão é introduzida por conjunções concessivas (embora, conquanto, ainda que).

BIZU DE PROVA:
Família das Conjunções CONCLUSIVAS: portanto, logo, por isso, por conseguinte, dessarte, destarte, pois (posposto ao verbo). Todas indicam a conclusão lógica do pensamento anterior.'),
(277, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Na palavra "Chuva", o grupo de letras "ch" constitui um DÍGRAFO CONSONANTAL, pois essas duas letras representam um único fonema consonantal fricativo palatal (/ʃ/). A palavra tem 5 letras e 4 fonemas (/ʃ/ /u/ /v/ /a/).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Em "Casa", cada letra representa um fonema distinto (/k/ /a/ /z/ /a/), não havendo dígrafo.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Em "Pato", todas as 4 letras correspondem aos seus respectivos 4 fonemas, sem ocorrência de dígrafo.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Em "Livro", a sequência "vr" constitui um encontro consonantal (ambas as consoantes /v/ e /r/ são pronunciadas), e não um dígrafo.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Em "Mesa", há 4 letras e 4 fonemas (/m/ /e/ /z/ /a/), sem dígrafos.

BIZU DE PROVA:
Diferença crucial:
- ENCONTRO CONSONANTAL = 2 letras e 2 sons distintos (ex.: p-r-a-t-o, l-i-v-r-o).
- DÍGRAFO = 2 letras que produzem apenas 1 som (ex.: ch-u-v-a, n-h-o-q-u-e, c-a-rr-o, p-a-ss-o).'),
(278, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Na palavra "guerra", a sequência de letras "gu" é seguida da vogal "e" e a letra "u" não é pronunciada (não constitui fonema). Portanto, "gu" funciona como um DÍGRAFO CONSONANTAL, no qual duas letras grafam o único fonema oclusivo velar sonoro (/g/).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Hiato é o encontro de duas vogais em sílabas separadas (ex.: sa-ú-de), o que não ocorre na sequência "gu".

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não é ditongo, pois o "u" não é pronunciado como semivogal (se o "u" soasse, como em "água" ou "aguentar", haveria ditongo; em "guerra", o "u" é mudo).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não é encontro consonantal porque a letra "u" é grafema vocálico componente do dígrafo, não uma consoante articulada.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Tritongo é a união de semivogal + vogal + semivogal na mesma sílaba (ex.: Paraguai), o que não ocorre em "guerra".

BIZU DE PROVA:
Regra de ouro de GU e QU:
- São DÍGRAFOS quando o "U" NÃO é pronunciado (ex.: g-u-e-rr-a, q-u-e-i-j-o, g-u-i-a).
- São DITONGOS quando o "U" É pronunciado (ex.: á-g-u-a, e-n-xá-g-u-e, q-u-a-s-e, a-g-u-e-n-t-a-r).'),
(279, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A oração original "Embora estivesse cansado, continuou estudando" é estruturada por uma oração subordinada adverbial CONCESSIVA ("Embora estivesse cansado"). A locução "Mesmo estando cansado" (com gerúndio precedido de operador concessivo "mesmo") preserva integralmente o sentido original de ressalva/concessão e a relação de coerência do período.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Altera o sentido ao introduzir valor de causa ("Como estava cansado") e inverter o desfecho ("deixou de estudar").

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Altera o sentido original para relação de causa e conclusão ("por isso não estudou").

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Altera o sentido para uma hipótese/condição ("Se estivesse cansado...").

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Afirma categoricamente que ele não estava cansado, contrariando o fato expresso no texto original.

BIZU DE PROVA:
Reescritas de CONCESSÃO (ideia de obstáculo superado):
"Embora estivesse cansado..." = "Mesmo estando cansado..." = "Ainda que estivesse cansado..." = "Apesar de estar cansado..." = "Conquanto estivesse cansado...". Todas mantêm o valor concessivo!'),
(280, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A oração "Os policiais analisaram o relatório" está na voz ativa (sujeito agente + VTD + objeto direto). A sua transposição para a voz passiva analítica mantém rigorosamente o sentido proposicional e as relações sintático-semânticas: o objeto direto torna-se sujeito paciente ("O relatório"), o verbo vira locução com auxiliar ser no pretérito perfeito ("foi analisado") e o sujeito agente passa a agente da passiva ("pelos policiais").

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Inverte os papéis semânticos da oração, afirmando absurdamente que os policiais foram analisados pelo relatório.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Apresenta erro de concordância e estrutura incoerente com o sentido original.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Transforma o relatório em sujeito ativo que pratica a ação de analisar os policiais.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Altera o modo e o tempo verbal para o futuro do pretérito com acréscimo de modalizador restritivo ("analisariam, necessariamente"), distorcendo o fato consumado no passado.

BIZU DE PROVA:
Na conversão entre voz ativa e passiva analítica, o tempo do verbo auxiliar SER deve ser estritamente IDÊNTICO ao do verbo principal da ativa:
- analisaram (pretérito perfeito) $\rightarrow$ foi analisado.
- analisam (presente) $\rightarrow$ é analisado.
- analisarão (futuro do presente) $\rightarrow$ será analisado.'),
(281, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O verbo "assistir", quando empregado no sentido de "ver", "presenciar" ou "assistir a um evento/espetáculo", é TRANSITIVO INDIRETO e exige a preposição "a" (quem assiste, assiste a algo). Diante do substantivo feminino "palestra" determinado pelo artigo definido "a", ocorre a fusão obrigatória gerando crase: "assistiu à palestra".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
No sentido de ver/presenciar, a norma culta exige obrigatoriamente a regência com preposição "a" (o uso direto sem preposição é coloquial e incorreto no padrão formal).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O verbo "aspirar", no sentido de cheirar, absorver ou inalar ar/odor, é TRANSITIVO DIRETO (sem preposição): o correto é "aspirou o perfume" (só rege preposição "a" no sentido de desejar/almejar).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O verbo "obedecer" é TRANSITIVO INDIRETO e rege obrigatoriamente a preposição "a": o correto é "obedeceu ao regulamento".

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O verbo "preferir" é transitivo direto e indireto, regendo a preposição "a" e rejeitando termos enfáticos como "mais", "muito mais" ou "do que": o correto é "preferiu estudar a trabalhar".

BIZU DE PROVA:
Pegadinhas clássicas de REGÊNCIA VERBAL da Fundatec:
- ASSISTIR (ver) = VTI com preposição A ("assistir ao filme", "assistir à aula").
- ASPIRAR (cheirar) = VTD sem preposição ("aspirar o perfume") / ASPIRAR (almejar) = VTI com A ("aspirar ao cargo").
- PREFERIR = VTD e VTI com preposição A, sem "mais... que" ("Prefiro café a chá").'),
(282, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O verbo "obedecer" é TRANSITIVO INDIRETO e exige a preposição "a" para introduzir o seu complemento (quem obedece, obedece a algo ou a alguém). Como o termo regido é o substantivo feminino plural "as normas", a junção da preposição "a" com o artigo definido plural "as" resulta no acento indicativo de crase: "Ele obedeceu às normas do edital".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Omite o acento indicativo de crase exigido pela regência transitiva indireta do verbo obedecer ("obedeceu às normas").

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O verbo "visar", no sentido de almejar, ter como objetivo ou pretender, é TRANSITIVO INDIRETO e exige preposição "a": o correto é "Ele visou ao cargo" (só é VTD no sentido de mirar ou apor visto).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Verbos de movimento como "chegar" e "ir" regem a preposição "a" no padrão culto formal ("chegou ao quartel"), sendo o uso de "em/no" restrito à linguagem coloquial.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A regência culta do verbo preferir proíbe o uso de "mais... do que": o correto é "preferiu Português a Matemática".

BIZU DE PROVA:
Regência dos verbos campeões de concurso:
- OBEDECER / DESOBEDECER = sempre VTI com preposição A ("obedeceu ao pai", "obedeceu às leis").
- CHEGAR / IR = regem preposição A para indicar destino ("cheguei à cidade", "fui ao quartel"). Nunca use "em"!'),
(283, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Na oração "O servidor entregou o documento ao chefe", o verbo "entregar" é transitivo direto e indireto (VTDI). O complemento "o documento" completa o sentido do verbo sem auxílio de preposição obrigatória, funcionando como OBJETO DIRETO (a coisa entregue), enquanto "ao chefe" funciona como objeto indireto (a quem se entregou).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O objeto indireto da oração é "ao chefe", que se conecta ao verbo por meio da preposição "a".

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Complemento nominal completa o sentido de um nome (substantivo abstrato, adjetivo ou advérbio) com preposição, enquanto "o documento" completa diretamente um verbo.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A oração está na voz ativa; agente da passiva só ocorre na voz passiva.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Predicativo do sujeito é o termo que atribui uma qualidade ou estado ao sujeito, não se confundindo com o complemento do verbo.

BIZU DE PROVA:
Verbos Transitivos Diretos e Indiretos (VTDI):
- Pedem dois complementos: uma COISA (Objeto Direto - sem preposição) e uma PESSOA/DESTINATÁRIO (Objeto Indireto - com preposição).
"Entregou o documento (OD) ao chefe (OI)".'),
(284, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A oração "A decisão foi tomada pelo comandante" está na voz passiva analítica (sujeito paciente "A decisão" + locução verbal passiva "foi tomada"). O termo preposicionado "pelo comandante" designa o ser que pratica ativamente a ação expressa pelo verbo passivo, exercendo com exatidão a função sintática de AGENTE DA PASSIVA.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Objeto direto é complemento de verbo transitivo direto na voz ativa, sem preposição obrigatória.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Objeto indireto completa verbos transitivos indiretos na voz ativa, não atuando como agente causador de verbo passivo.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Complemento nominal liga-se a substantivos abstratos, adjetivos ou advérbios, ao passo que "pelo comandante" liga-se diretamente à locução verbal "foi tomada".

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Aposto é termo de natureza substantiva que explica, resume ou detalha outro termo substantivo.

BIZU DE PROVA:
Como identificar o AGENTE DA PASSIVA:
1) A frase está na voz passiva analítica ("foi tomada", "foi aprovado").
2) O termo vem introduzido pela preposição "POR" (ou pela contração "pelo/pela") e indica quem realizou o ato.
3) Ao converter para a voz ativa, ele vira o sujeito: "O comandante tomou a decisão".'),
(304, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O verbo "fazer", quando empregado para indicar tempo transcorrido ou decorrido (assim como fenômenos da natureza), é IMPESSOAL (não admite sujeito). Por ser impessoal, deve permanecer obrigatoriamente flexionado na 3ª pessoa do singular: "Faz dois anos que estudo para concursos".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Flexiona indevidamente o verbo impessoal para o plural ("Fazem dois anos"), o que constitui erro crasso de concordância na norma-padrão.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O verbo "haver", no sentido de existir ou ocorrer, é impessoal e não admite plural: o correto é "Houve muitos candidatos".

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O verbo "existir" é pessoal e concorda com o sujeito: como o sujeito "muita gente" está no singular, o verbo deve ficar no singular ("Existe muita gente").

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Em locuções verbais com verbo impessoal principal (como "haver"), a impessoalidade é transmitida ao verbo auxiliar: o correto é "Deve haver vagas".

BIZU DE PROVA:
Regra de ouro da Impessoalidade Verbal:
- FAZER (tempo decorrido/clima) = SEMPRE no singular ("Faz 5 anos", "Fazia dias quentes").
- HAVER (existir/ocorrer/tempo) = SEMPRE no singular ("Houve problemas", "Há meses estudo").
- Em locução verbal ("deve haver", "vai fazer"), o auxiliar fica OBRIGATORIAMENTE no singular!'),
(305, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O conectivo "contudo" é uma conjunção coordenativa ADVERSATIVA. Sua função sintático-semântica no período é introduzir uma oração que expressa oposição, quebra de expectativa, restrição ou contraste em relação à ideia expressa anteriormente.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Relação de conclusão é introduzida por conectivos conclusivos (portanto, logo, por isso).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Relação de causa é introduzida por conectivos causais (porque, já que, uma vez que).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Relação de adição é introduzida por conectivos aditivos (e, nem, não só... mas também).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Relação de finalidade é introduzida por conectivos finais (para que, a fim de que).

BIZU DE PROVA:
As 7 principais Conjunções ADVERSATIVAS de prova:
MAS, PORÉM, CONTUDO, TODAVIA, ENTRETANTO, NO ENTANTO, NÃO OBSTANTE.
Todas expressam ideia de OPOSIÇÃO e admitem substituição mútua sem prejuízo de sentido!'),
(306, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Na teoria da interpretação e compreensão textual, uma INFERÊNCIA VÁLIDA (ou dedução legítima) consiste em concluir logicamente uma informação implícita a partir de pistas, marcas linguísticas e premissas expressamente fornecidas pelo texto-base. Portanto, toda inferência válida deve ser rigorosamente sustentada por elementos presentes no próprio texto.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Uma inferência jamais pode contradizer as informações e premissas assentadas pelo autor no texto.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A inferência em provas de concurso deve ser objetiva e ancorada no texto, não dependendo de juízos de valor subjetivos ou opiniões externas do leitor.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O contexto situacional e linguístico é elemento essencial para delimitar o sentido das proposições e inferências.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Concluir a partir de informações inexistentes no texto constitui o erro clássico de "extrapolação".

BIZU DE PROVA:
Os 3 principais erros de Interpretação em Concursos:
1) EXTRAPOLAÇÃO: inventar dados além do que o texto informou.
2) REDUÇÃO: considerar apenas um detalhe e esquecer a ideia geral.
3) CONTRADIÇÃO: concluir o inverso do que o autor afirmou.'),
(307, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A palavra "Exceção" é grafada corretamente com o dígrafo "xc" na primeira sílaba e a letra "ç" na terminação "-ção". O vocábulo origina-se do latim *exceptio, -onis*, mantendo a correspondência ortográfica fixada no Vocabulário Ortográfico da Língua Portuguesa (VOLP).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Apresenta a forma incorreta "Excessão", grafada erroneamente com "ss" (confundindo com a família do verbo exceder/excesso).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Apresenta a forma bizarra "Excesssão", com três letras "s".

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Apresenta a grafia incorreta "Esceção", omitindo a letra "x".

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Apresenta erros múltiplos de duplicação indevida.

BIZU DE PROVA:
Não confunda na hora da prova:
- EXCEÇÃO: com "XC" e "Ç" (aquilo que foge à regra).
- EXCESSO / EXCESSIVO: com "XC" e "SS" (o que sobra, exagero).'),
(308, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
As palavras "eminente" e "iminente" são parônimas (possuem grafia e pronúncia semelhantes, mas significados completamente distintos):
- EMINENTE (com "E"): significa alto, elevado, sublime, ilustre, notável, consagrado (ex.: "um jurista eminente").
- IMINENTE (com "I"): significa prestes a ocorrer, que está a ponto de acontecer a qualquer momento (ex.: "perigo iminente").

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Inverte os significados dos dois termos parônimos.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Os termos não são sinônimos nem idênticos, possuindo semântica estritamente diversa.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não guardam relação com antiguidade e modernidade.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não guardam correlação com claro e escuro.

BIZU DE PROVA:
Mnemônico para Parônimos clássicos:
- EMINENTE (com E) = EXCELENTE / ELEVADO / ILUSTRE.
- IMINENTE (com I) = IMEDIATO / PRESTES A ACONTECER.'),
(316, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
No trecho "Uma boa rotina de sono pode mais que dobrar esse benefício [...]. Há de se reconhecer, contudo, que esse é um privilégio para poucos", o conectivo "contudo" é uma conjunção coordenativa ADVERSATIVA. Ele introduz uma ressalva, contraste e oposição em relação à afirmação anterior, ponderando que, apesar dos inúmeros benefícios comprovados do sono, ter uma boa rotina é difícil para a maioria.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Conjunções conclusivas (portanto, logo, por isso) exprimem dedução ou fechamento de raciocínio, e não ressalva adversativa.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Conjunções explicativas (porque, que, pois) justificam uma proposição precedente, o que não é o papel de "contudo".

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Conjunções aditivas (e, nem) expressam acúmulo de informações, sem estabelecer contrariedade.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Conjunções alternativas (ou, ora... ora) marcam alternância ou mútua exclusão de opções.

BIZU DE PROVA:
Conjunções adversativas deslocadas entre vírgulas (como ", contudo, ", ", porém, ", ", todavia, ") mantêm integralmente seu valor de OPOSIÇÃO / RESSALVA!'),
(317, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
No trecho "Saber amenizar os prejuízos disso é também um jeito de cuidar do psicológico da juventude", o verbo "amenizar" está empregado no sentido de abrandar, atenuar, minorar, tornar mais suave ou menos danoso. Portanto, sua substituição por "Suavizar" preserva com exatidão a relação de sentido e a coerência do texto original.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Ignorar" significa fingir que algo não existe ou desconsiderar voluntariamente, o que alteraria completamente a ideia de ação preventiva expressa pelo autor.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Intensificar" significa aumentar, agravar ou potencializar, representando o antônimo exato de amenizar.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Prolongar" significa estender no tempo ou dilatar a duração.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Justificar" significa dar razões, escusar ou legitimar.

BIZU DE PROVA:
Sinônimos perfeitos de AMENIZAR para a Fundatec:
Suavizar, atenuar, abrandar, mitigar, minorar, aplacar. Guarde especialmente o verbo MITIGAR!'),
(318, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A frase original é: "Durante a fase de crescimento, esse ponteiro tem duas horas de atraso em relação às crianças e adultos".
Se a palavra "ponteiro" for flexionada no plural ("ponteiros"), serão necessárias exatamente DUAS outras alterações na oração para preservar a correta concordância gramatical:
1) O pronome demonstrativo determinante: "esse" $\rightarrow$ "esses" ("esses ponteiros");
2) O verbo principal: "tem" (singular) $\rightarrow$ "têm" (com acento circunflexo diferencial de 3ª pessoa do plural).
Frase resultante: "Durante a fase de crescimento, esses ponteiros têm duas horas de atraso...".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Computa apenas 1 alteração, deixando de flexionar ou o pronome demonstrativo ou o acento diferencial do verbo ter.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Computa 3 alterações, quando os demais termos do período ("durante", "fase", "duas horas", "atraso") permanecem inalterados.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Superestima o número de modificações necessárias.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Incorreta por apontar 5 alterações onde apenas 2 termos concordam sintaticamente com o núcleo do sujeito.

BIZU DE PROVA:
Acento diferencial do verbo TER e VIR no plural:
- Ele TEM (singular, sem acento) $\rightarrow$ Eles TÊM (plural, com acento circunflexo).
- Ele VEM (singular, sem acento) $\rightarrow$ Eles VÊM (plural, com acento circunflexo).'),
(319, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
No trecho "...principalmente no caso dos adolescentes, cujos relógios biológicos tendem a discordar com os horários das escolas", o pronome relativo "cujos" estabelece uma relação sintática e semântica de POSSE, conectando o termo possuidor antecedente ("adolescentes") ao substantivo possuído consequente ("relógios biológicos"). Portanto, o termo anafórico retomado por "cujos" é expressamente "adolescentes" (os relógios biológicos DOS ADOLESCENTES).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Relógios biológicos" é o termo subsequente determinado pelo pronome, e não o referente antecedente retomado.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Poucos" integra a oração principal anterior, não sendo o termo imediato de vínculo do pronome relativo.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Horários" é complemento do verbo discordar, posposto na oração.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Escolas" é adjunto adnominal/complemento posposto em relação a horários.

BIZU DE PROVA:
Estrutura rígida do pronome CUJO:
[Termo Possuidor/Retomado] + CUJO(S)/CUJA(S) + [Termo Possuído].
O pronome SEMPRE retoma o antecedente (possuidor) e concorda em gênero e número com o consequente (possuído).'),
(320, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Na palavra "horas", temos:
- Letras (grafemas): 5 letras (h - o - r - a - s).
- Fonemas (sons): 4 fonemas (/ɔ/ /r/ /a/ /s/).
A letra inicial "h" na Língua Portuguesa não possui valor fonético próprio (é etimológica e muda). Por isso, a palavra apresenta MENOS FONEMAS DO QUE LETRAS.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Não há nenhum encontro consonantal na palavra; as consoantes "r" e "s" estão intercaladas por vogais em sílabas distintas (ho-ras).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não há dígrafo na palavra ("h" isolado no início não é dígrafo; dígrafo ocorre em "ch", "lh", "nh").

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não há encontro vocálico (hiato ou ditongo), pois as vogais "o" e "a" estão em sílabas separadas e intercaladas por consoante.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A palavra possui fonemas orais (/ɔ/, /r/, /a/, /s/), não se constituindo de fonemas nasais.

BIZU DE PROVA:
Contagem de Fonemas com H inicial:
Toda palavra iniciada pela letra "H" mudo (horas, homem, hoje, hábito, honra) terá sempre no mínimo 1 fonema a menos que o total de letras, pois o "H" inicial não emite som algum!'),
(321, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O preenchimento ortográfico correto e respectivo das quatro palavras é: "s – x – s – z".
1) "desempenho": grafada com "s", com o prefixo "des-" associado à raiz (des + empenho = desempenho).
2) "exigente": grafada com "x", pertencente à família etimológica do verbo exigir (*exigere*).
3) "esgotamento": grafada com "s", derivada do verbo esgotar (com prefixo es-).
4) "visualizado": grafada com "z", particípio do verbo derivado visual + sufixo "-izar" (visualizar $\rightarrow$ visualizado).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Erra a grafia ao empregar "z" em "dezempenho", "z" em "ezgotamento" e "s" em "visualisado".

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Erra ao propor "z" para exigente, "z" para esgotamento e "s" para visualizado.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Erra a primeira letra ao propor "z" para desempenho e a terceira com "z" em esgotamento.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Erra a primeira com "z", a segunda com "s" e a terceira com "s".

BIZU DE PROVA:
Regra do sufixo -IZAR com palavras primitivas sem S:
- Visual $\rightarrow$ Visualizar $\rightarrow$ Visualizado (com Z).
- Canal $\rightarrow$ Canalizar $\rightarrow$ Canalizado (com Z).
- Se a raiz já tem "S", mantém o S: Pesquisa $\rightarrow$ Pesquisar $\rightarrow$ Pesquisado.'),
(322, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
A palavra "Paralisar" está grafada de forma 100% correta. O substantivo primitivo é "paralisia", que já possui a letra "s" em seu radical; ao formar o verbo cognato pela adição do sufixo verbal "-ar", a consoante "s" do radical é obrigatoriamente preservada (paralisi- + ar = paralisar).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A grafia correta é "Utilizar" (com "z"), pois a palavra base "útil" não possui "s" no radical, exigindo o sufixo "-izar".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A grafia correta é "Ascensão" (com "s" e "ão"), derivada do verbo ascender.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A grafia correta é "Exceção" (com "xc" e "ç").

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A grafia correta é "Pretensioso" (com "s"), derivado de pretensão.

BIZU DE PROVA:
A clássica pegadinha do PARALISAR vs. UTILIZAR:
- PARALISIA (tem S) $\rightarrow$ PARALISAR (mantém S!).
- ÚTIL (não tem S) $\rightarrow$ UTILIZAR (leva Z!).
- ANÁLISE (tem S) $\rightarrow$ ANALISAR (mantém S!).'),
(323, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
No trecho “Pedro tem seu pai, Henrique, assassinado em uma operação policial, tal fato o leva para o recolher-se e assim poder nascer para o novo momento que irá viver”, há exatamente DOIS artigos definidos:
1) O primeiro artigo definido "o" surge em "o recolher-se", onde atua substantivando o verbo "recolher";
2) O segundo artigo definido "o" surge em "o novo momento", determinando o substantivo "momento".
Atenção: o termo "o" em "tal fato o leva" é um PRONOME OBLÍQUO ÁTONO (equivale a "leva Pedro" / "leva-o"), e não artigo.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Incorreta pois existem 2 artigos definidos legítimos no período.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Computa apenas 1 artigo, esquecendo o artigo substantivador em "o recolher-se" ou o artigo em "o novo momento".

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Computa 3 artigos por classificar erroneamente o pronome oblíquo "o" de "o leva" como artigo.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Superestima o número de artigos presentes no trecho.

BIZU DE PROVA:
Como não confundir ARTIGO com PRONOME OBLÍQUO:
- ARTIGO definido "o/a": antecede SUBSTANTIVO (ou palavra substantivada) $\rightarrow$ "o novo momento", "o recolher".
- PRONOME oblíquo "o/a": acompanha ou substitui um VERBO e equivale a "ele/ela" $\rightarrow$ "o fato o leva" (= leva a ele).'),
(324, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Estão corretas as assertivas II e III:
- Assertiva II (Correta): a locução pronominal relativa preposicionada "em que" refere-se a um termo antecedente circunstancial e pode ser substituída sem alteração de sentido ou prejuízo gramatical por "no qual" (em + o qual).
- Assertiva III (Correta): o pronome anafórico "delas" retoma perfeitamente o substantivo "suposições" apresentado na linha anterior, que passa a ser exemplificado na sequência.
- Assertiva I (Incorreta): no texto, a expressão "esse filho adulto" refere-se a Henrique/ao próprio personagem em relação a seus pais, e não ao filho de Pedro.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Aponta apenas a assertiva I, que possui erro de referência textual.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Deixa de incluir a assertiva III, que é igualmente correta.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Deixa de incluir a assertiva II, que trata da substituição de "em que" por "no qual".

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Inclui a assertiva I, cujo referente está equivocado.

BIZU DE PROVA:
Equivalência dos Pronomes Relativos:
"EM QUE" = "NO QUAL / NA QUAL / NOS QUAIS / NAS QUAIS".
Sempre que o antecedente admitir a preposição "em", a troca é válida e mantém a correção gramatical.'),
(325, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Na opção E ("que essa ação"), o vocábulo "que" funciona como uma CONJUNÇÃO INTEGRANTE (ou conectivo oracional), introduzindo uma oração subordinada substantiva e não retomando nenhum substantivo antecedente. Como a questão pede a alternativa em que "que" NÃO é pronome relativo, a alternativa E é o gabarito.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Em "que se recolhe em suas lembranças", a palavra "que" é pronome relativo que retoma o sujeito/antecedente humano ("Pedro / o homem").

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Em "que ouviu de e sobre seus pais", "que" é pronome relativo retomando os relatos/histórias antecedentes.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Em "que consiste em submeter o sujeito", "que" é pronome relativo conectando o conceito antecedente.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Em "que estrutura a essência da sociedade", "que" é pronome relativo com função de sujeito da oração adjetiva.

BIZU DE PROVA:
Teste infalível do PRONOME RELATIVO vs. CONJUNÇÃO INTEGRANTE:
- PRONOME RELATIVO: pode ser substituído por "O QUAL / A QUAL / OS QUAIS / AS QUAIS" e retoma um substantivo anterior.
- CONJUNÇÃO INTEGRANTE: introduz oração que pode ser substituída pela palavra "ISSO" ("afirmou QUE essa ação..." $\rightarrow$ "afirmou ISSO").'),
(328, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O preenchimento correto das lacunas das linhas 17, 19 e 28 é "à – à – à" (todas com crase):
- Lacuna da linha 17: ocorre crase ("à") diante de substantivo feminino determinado por regência com preposição "a".
- Lacuna da linha 19: ocorre crase ("à") em locução adverbial ou prepositiva feminina que exige acento indicativo de crase.
- Lacuna da linha 28: ocorre crase ("à") por fusão da preposição "a" exigida pelo termo regente com o artigo feminino "a" do termo regido.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Omite a crase nas duas primeiras lacunas, violando as regras obrigatórias de regência e locução feminina.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Omite a crase na segunda e na terceira lacunas.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Omite a crase na primeira e na terceira lacunas.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Omite a crase na primeira lacuna.

BIZU DE PROVA:
Nas questões da Fundatec para a Brigada Militar e Bombeiros, verifique as 3 regras fundamentais:
1) Verbo transitivo indireto com preposição "A" + Palavra feminina com artigo "A" = CRASE (à).
2) Locuções adverbiais, prepositivas e conjuntivas femininas = SEMPRE CRASE ("à proporção que", "à noite", "à disposição").'),
(329, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A sequência ortográfica que preenche correta e respectivamente as lacunas das linhas 09, 11 e 19 é "x – ç – z":
- 1ª lacuna (l. 09): exige a letra "x" (vocábulo grafado com "x" após ditongo ou na raiz etimológica correspondente).
- 2ª lacuna (l. 11): exige a letra "ç" (sufixo de substantivação -ção em vocábulo da língua).
- 3ª lacuna (l. 19): exige a letra "z" (sufixo derivacional verbalizador -izar ou terminação em -eza/-izar).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Propõe incorretamente "ss" para a segunda lacuna.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Propõe "ch" na primeira, "ss" na segunda e "s" na terceira lacuna.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Propõe "ch" na primeira e "ss" na segunda lacuna.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Propõe "s" na terceira lacuna, onde a ortografia oficial prescreve "z".

BIZU DE PROVA:
Regra de ouro do "X" após DITONGO:
Após ditongo decrescente oral, grafa-se sempre com "X":
- Caixa, feixe, peixe, frouxo, ameixa, desleixo.'),
(330, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Analisando os três elementos solicitados no enunciado:
1) Classe gramatical: a palavra "extremidades" nomeia uma parte/limite físico, classificando-se morfologicamente como SUBSTANTIVO feminino plural;
2) Grafia: a lacuna de "e...tremidades" deve ser preenchida com a letra "x" ("extremidades", derivada do latim *extremitas*);
3) Sinonímia contextual: "extremidades" apresenta como sinônimo direto e adequado no contexto o vocábulo "pontas".
Sequência correta: substantivo – “x” – “pontas”.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Classifica a palavra como adjetivo, quando na oração funciona como substantivo.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Propõe a letra "s" para a grafia e o sinônimo inadequado "soleiras".

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Erra a classe (adjetivo), a grafia (com s) e o sinônimo.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Erra a classe gramatical (adjetivo) e a letra da grafia (s).

BIZU DE PROVA:
Família de EXTREMO:
Extremo, extremidade, extremo-oriental, estreme (atenção: "estreme" sem x significa puro/sem mistura, mas tudo que vem de limite é com X: extremo, extremista, extremidade).'),
(331, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
As circunstâncias expressas pelos termos adverbiais sublinhados são:
1) "A partir do século XVI": exprime a circunstância de TEMPO (marcação temporal de início histórico).
2) "na Inglaterra": exprime a circunstância de LUGAR (localização geográfica do acontecimento).
3) "mais desenvolvidas": o advérbio "mais" modifica o adjetivo "desenvolvidas", exprimindo circunstância de INTENSIDADE.
Ordem respectiva correta: Tempo – lugar – intensidade.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Classifica o segundo trecho ("na Inglaterra") como tempo, quando é inequivocamente lugar.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Classifica o primeiro como modo e o terceiro como afirmação.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Classifica o primeiro como modo, o segundo como tempo e o terceiro como afirmação.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Classifica o primeiro trecho como modo, quando indica tempo histórico.

BIZU DE PROVA:
Para identificar a circunstância adverbial, faça a pergunta ao verbo/adjetivo:
- QUANDO? $\rightarrow$ TEMPO ("no século XVI", "em 1905").
- ONDE? $\rightarrow$ LUGAR ("na Inglaterra", "no quartel").
- QUANTO? $\rightarrow$ INTENSIDADE ("mais desenvolvidas", "muito forte").
- COMO? $\rightarrow$ MODO ("com cuidado", "rapidamente").'),
(332, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Estão corretas as assertivas II e III:
- Assertiva II (Correta): o trecho "[...] quando a capital foi devastada por um grande incêndio" está na voz passiva analítica (verbo auxiliar "foi" + particípio "devastada"), sendo "por um grande incêndio" o agente da passiva introduzido pela preposição "por".
- Assertiva III (Correta): o termo "a capital" funciona sintaticamente como sujeito paciente da locução verbal passiva.
- Assertiva I (Incorreta): a reescrita "um grande incêndio devastou-se pela capital" utiliza reflexividade indevida ("devastou-se"), gerando nonsense e rompendo a correlação de sentido com a oração original (o correto na ativa seria: "um grande incêndio devastou a capital").

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Considera apenas a assertiva I, que está gramatical e semanticamente errada.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Inclui a assertiva I como correta.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Inclui a assertiva I e omite a II.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Considera todas corretas, ignorando o erro na assertiva I.

BIZU DE PROVA:
Conversão da Passiva para a Ativa:
- Passiva: "A capital (sujeito paciente) foi devastada (locução passiva) por um grande incêndio (agente da passiva)".
- Ativa correta: "Um grande incêndio (sujeito agente) devastou (verbo ativo) a capital (objeto direto)".'),
(333, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Estão corretas as assertivas II e III:
- Assertiva II (Correta): a expressão anafórica plural "Essas novas ferramentas" retoma em síntese coesiva os instrumentos e inovações citados nas linhas imediatamente anteriores ("bombas de incêndio" e "primeira mangueira de combate a incêndio").
- Assertiva III (Correta): a especificação técnica de capacidade "alcance vertical de até 36 m" qualifica e refere-se ao desempenho operacional das "bombas manuais" mencionadas no mesmo período.
- Assertiva I (Incorreta): na linha 10, o pronome relativo "que" retoma o núcleo do sintagma antecedentemente qualificado, e não simplesmente "regiões".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Aponta apenas a assertiva I, que identifica incorretamente o referente.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Deixa de incluir a assertiva II, que é plenamente correta.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Inclui a assertiva I como verdadeira.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Considera todas verdadeiras, incluindo a assertiva I que é falsa.

BIZU DE PROVA:
Em questões de Coesão Referencial com pronomes demonstrativos ("essas ferramentas", "esses dados"):
O pronome com "SS" (esse, essa, isso) opera a ANAFORA, retomando termos já apresentados no parágrafo ou período anterior.'),
(334, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A conjunção "mas" pertence à classe das conjunções coordenativas ADVERSATIVAS (expressa ideia de oposição, restrição ou quebra de expectativa). A palavra "Caso" pertence à classe das conjunções subordinativas CONDICIONAIS (expressa ideia de condição ou hipótese). Portanto, "Caso" NÃO substitui a conjunção "mas", pois descaracteriza a oposição e altera radicalmente o sentido original do período.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Porém" é conjunção adversativa e substitui "mas" perfeitamente sem alteração de sentido.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Contudo" é conjunção adversativa sinônima de "mas".

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Entretanto" é conjunção adversativa que mantém integralmente o valor opositivo.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Todavia" é conjunção adversativa equivalente a "mas".

BIZU DE PROVA:
Tabela de equivalência das ADVERSATIVAS:
MAS = PORÉM = CONTUDO = TODAVIA = ENTRETANTO = NO ENTANTO.
Qualquer conjunção fora desse grupo (como "caso", "porque", "portanto", "embora") altera o sentido da oração!'),
(335, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
No trecho "[...] desenvolveu a primeira mangueira de combate (1) a incêndio, confeccionada em (2) couro e bronze (3)":
1) "combate": funciona como SUBSTANTIVO comum abstrato (núcleo da locução que especifica o tipo de mangueira).
2) "em": é uma PREPOSIÇÃO essencial que introduz o adjunto de matéria ("em couro e bronze").
3) "bronze": funciona como SUBSTANTIVO concreto que nomeia a liga metálica utilizada na confecção.
Ordem morfológica correta: Substantivo – preposição – substantivo.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Classifica "combate" como verbo e "bronze" como adjetivo.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Classifica "em" como conjunção e "bronze" como adjetivo.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Classifica "combate" como verbo no trecho, onde claramente atua como substantivo.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Classifica "em" como conjunção, quando é preposição essencial.

BIZU DE PROVA:
Diferença de classe contextual:
- "COMBATE" = Substantivo em "mangueira de combate", "pronto para o combate" / Verbo em "ele combate o crime".
- "EM" = Preposição essencial invariável (a, ante, após, até, com, contra, de, desde, em, entre, para, per, perante, por, sem, sob, sobre, trás).'),
(336, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Na palavra "indescritível", o elemento mórfico "in-" funciona como um PREFIXO DE NEGAÇÃO ou privação (in + descritível = aquilo que não se pode descrever).
Na palavra "Indicado", o segmento inicial "in-" NÃO é um prefixo de negação; trata-se da raiz do verbo latino *indicare* (apontar, mostrar, designar). Portanto, em "indicado" não ocorre o prefixo com sentido negativo.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Em "Indizível", o prefixo "in-" expressa negação (in + dizível = o que não se pode dizer).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Em "Injusto", o prefixo "in-" expressa privação/negação (in + justo = que não é justo).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Em "Invisível", o prefixo "in-" expressa negação (in + visível = que não se pode ver).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Em "Inativo", o prefixo "in-" expressa negação (in + ativo = que não está ativo).

BIZU DE PROVA:
Cuidado com falsos prefixos de negação:
- "IN-" com valor de NÃO: inativo, infeliz, invisível, indescritível, injusto.
- "IN-" como raiz ou direção/movimento para dentro: indicado, induzir, ingerir, invadir.'),
(679, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A palavra "Também" é uma palavra OXÍTONA terminada em "-em", acentuada pela regra geral das oxítonas terminadas em -em/-ens (assim como alguém, armazém, parabéns).
Todas as demais palavras da questão ("Critério", "Excelência", "Referências", "Incumbência") são PAROXÍTONAS terminadas em DITONGO CRESCENTE (ou proparoxítonas aparentes). Portanto, "Também" é a única acentuada por regra distinta, constituindo a exceção pedida.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Critério" (cri-té-rio) é paroxítona terminada em ditongo crescente, seguindo a mesma regra de excelência, referências e incumbência.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Excelência" (ex-ce-lên-cia) é paroxítona terminada em ditongo crescente.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Referências" (re-fe-rên-cias) é paroxítona terminada em ditongo crescente seguido de s.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Incumbência" (in-cum-bên-cia) é paroxítona terminada em ditongo crescente.

BIZU DE PROVA:
Regras mais cobradas pela Fundatec em Acentuação:
1) Oxítonas terminadas em A, E, O (seguidos ou não de S), EM, ENS.
2) Paroxítonas terminadas em DITONGO CRESCENTE (história, critério, série, polícia).
Ao pedir o "EXCETO", separe as oxítonas das paroxítonas terminadas em ditongo!'),
(680, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
As palavras "biológicos" (bi-o-ló-gi-cos) e "acadêmicas" (a-ca-dê-mi-cas) têm como sílaba tônica a antepenúltima sílaba, sendo ambas classificadas como PROPAROXÍTONAS. Pela regra de acentuação gráfica, todas as proparoxítonas são acentuadas. A palavra "Psicológico" (psi-co-ló-gi-co) também tem a antepenúltima sílaba tônica, sendo acentuada rigorosamente pela mesma regra das proparoxítonas.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Até" é oxítona terminada em "-e", acentuada pela regra das oxítonas.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Possível" é paroxítona terminada em "-l", acentuada pela regra das paroxítonas.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Prejuízo" é acentuada pela regra do hiato tônico (i tônico em hiato sozinho na sílaba).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Saúde" é acentuada pela regra especial do hiato tônico (u tônico em hiato).

BIZU DE PROVA:
Regra absoluta das Proparoxítonas:
Contam-se as sílabas do fim para o começo: última (oxítona), penúltima (paroxítona), antepenúltima (proparoxítona).
Se a antepenúltima for a mais forte $\rightarrow$ É PROPAROXÍTONA e leva acento SEMPRE!'),
(681, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
A palavra "astrofísico" (as-tro-fí-si-co) é uma palavra PROPAROXÍTONA (antepenúltima sílaba tônica).
Na alternativa D, todas as três palavras são igualmente PROPAROXÍTONAS:
1) "Júpiter" (Jú-pi-ter): antepenúltima tônica $\rightarrow$ proparoxítona.
2) "astrônomo" (as-trô-no-mo): antepenúltima tônica $\rightarrow$ proparoxítona.
3) "últimas" (úl-ti-mas): antepenúltima tônica $\rightarrow$ proparoxítona.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Série" é paroxítona terminada em ditongo crescente e "televisão" não possui acento gráfico (o til é marca de nasalidade).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Trás" é monossílabo tônico e "milhões" é oxítona nasal.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Vênus" e "palatável" são paroxítonas (terminadas em -us e -l).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Observatório" é paroxítona terminada em ditongo e "países" é acentuada pela regra do hiato.

BIZU DE PROVA:
Todas as palavras proparoxítonas recebem acento gráfico, independentemente de sua terminação. Para identificar com rapidez, faça a divisão silábica e localize o pico de tonicidade na antepenúltima sílaba.'),
(682, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
No trecho “E, infelizmente (1), são muitas as circunstâncias que (2) dificultam o desenvolvimento integral (3) de cada (4) pessoa”, a classificação morfológica rigorosa dos termos sublinhados é:
1) "infelizmente": ADVÉRBIO de modo (formado com sufixo -mente a partir de infeliz).
2) "que": PRONOME relativo que introduz a oração subordinada adjetiva retomando o substantivo antecedente "circunstâncias".
3) "integral": ADJETIVO que qualifica o substantivo "desenvolvimento".
4) "cada": PRONOME indefinido adjetivo que acompanha o substantivo "pessoa".
Sequência respectiva: Advérbio – pronome – adjetivo – pronome.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Classifica "que" como conjunção e "cada" como numeral.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Classifica "infelizmente" como adjetivo e "cada" como numeral.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Classifica "infelizmente" como adjetivo e "que" como conjunção.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Classifica "que" como conjunção, quando é pronome relativo.

BIZU DE PROVA:
Morfologia dos termos-chave:
- Terminado em "-MENTE" ligado à oração = ADVÉRBIO ("infelizmente").
- "QUE" que substitui substantivo anterior ("circunstâncias as quais dificultam") = PRONOME RELATIVO.
- "CADA" = PRONOME INDEFINIDO (nunca confunda com numeral!).'),
(683, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Estão corretas as assertivas I e III:
- Assertiva I (Correta): no primeiro parágrafo do texto, o autor emprega a expressão "bem comum" repetidas vezes para fixar e enfatizar o tema central da discussão e delimitar o escopo da reflexão.
- Assertiva III (Correta): no início do 3º parágrafo ("Quando se excluem algumas possibilidades, fica mais fácil definir o que é o bem comum. Ele é uma situação..."), o pronome pessoal reto "Ele" retoma anaforicamente a expressão "bem comum" do período imediatamente anterior.
- Assertiva II (Incorreta): o texto não usa "prosperidade material" como sinônimo substitutivo de "bem comum"; pelo contrário, o autor adverte expressamente que reduzir o bem comum à prosperidade material é um equívoco conceitual.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Deixa de incluir a assertiva III, que também é correta.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Aponta a assertiva II, que é contrária à argumentação do texto.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Inclui a assertiva II, que comete erro de compreensão textual.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Considera todas corretas, incluindo a assertiva II que distorce o texto-base.

BIZU DE PROVA:
Em questões de interpretação da Fundatec sobre relação entre conceitos, verifique se o autor está igualando os conceitos ou contrastando-os ("equívoco", "erro", "distinção"). No texto, prosperidade material é apenas uma parte secundária do bem comum.'),
(684, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
No trecho “Há de se reconhecer, contudo, que esse é um privilégio para poucos – principalmente no caso dos adolescentes, cujos relógios biológicos tendem a discordar com os horários das escolas”, o pronome relativo possessivo "cujos" tem como referente sintático e semântico o substantivo antecedente "adolescentes". A estrutura expressa que os relógios biológicos pertencem aos adolescentes.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Relógios biológicos" é o termo possuído com o qual o pronome concorda em gênero e número, e não o elemento possuidor antecedente retomado.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Poucos" é pronome indefinido que atua em oração anterior sem ligação direta com a posse dos relógios.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Horários" é o objeto indireto regido pelo verbo discordar.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Escolas" é o adjunto adnominal do substantivo horários.

BIZU DE PROVA:
Regra do Pronome Relativo CUJO:
O pronome relativo CUJO sempre retoma o termo antecedente (o possuidor). Logo, ao perguntar "quem é retomado por cujos?", a resposta é invariavelmente o substantivo que vem IMEDIATAMENTE ANTES dele no texto ("adolescentes").'),
(685, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Estão corretas as assertivas I e II:
- Assertiva I (Correta): a palavra "temeroso" é formada pelo processo de DERIVAÇÃO SUFIXAL pelo acréscimo do sufixo formador de adjetivos "-oso" ao radical do substantivo temor (temor + oso = temeroso).
- Assertiva II (Correta): no vocábulo "imateriais" (in + materiais), o prefixo "i-" (variação alomórfica de "in-" antes de "m") expressa valor semântico de NEGAÇÃO / privação (aquilo que não é material).
- Assertiva III (Incorreta): a palavra "componentes" não é formada por parassíntese ou prefixo e sufixo concomitantes; trata-se de derivação a partir do verbo compor / radical latino *componere* com sufixo participial/adjetival "-ente".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Deixa de incluir a assertiva II, que é igualmente verdadeira.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Deixa de incluir a assertiva I, que descreve corretamente a sufixação em temeroso.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Aponta apenas a assertiva III, que é falsa.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Inclui a assertiva III como correta.

BIZU DE PROVA:
Processos de Formação de Palavras na Fundatec:
- Derivação Sufixal: acréscimo de sufixo a uma palavra existente (temor $\rightarrow$ temor-oso).
- Prefixo de Negação: IN- / I- / IM- / DES- (imaterial, infeliz, desleal).
- Parassíntese: inclusão obrigatória e simultânea de prefixo e sufixo (se tirar um, a palavra não existe: a-noit-ecer).'),
(686, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Estão corretas as assertivas I e II:
- Assertiva I (Correta): a palavra "indivíduos" possui 10 letras (i - n - d - i - v - í - d - u - o - s) e 9 fonemas (/ĩ/ /d/ /i/ /v/ /i/ /d/ /w/ /o/ /s/), pois as duas primeiras letras ("in") formam um dígrafo vocálico que representa um único som (/ĩ/).
- Assertiva II (Correta): o encontro "in" no início da palavra é um DÍGRAFO VOCÁLICO (ou nasal), no qual a vogal "i" seguida de "n" na mesma sílaba representa a vogal nasalizada.
- Assertiva III (Incorreta): a terminação "-uos" em "in-di-ví-duos" (ou "-uo") forma tradicionalmente um DITONGO CRESCENTE (semivogal /w/ + vogal /o/), e não decrescente.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Deixa de incluir a assertiva II, que é plenamente verdadeira.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Deixa de incluir a assertiva I, que traz a contagem exata de letras e fonemas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Inclui a assertiva III, que erra a classificação do ditongo.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Considera a assertiva III verdadeira.

BIZU DE PROVA:
Diferença entre Ditongo Crescente e Decrescente:
- DITONGO CRESCENTE: Semivogal + Vogal (o som cresce: -ua, -ue, -uo, -ia, -ie, -io) $\rightarrow$ in-di-ví-duo, his-tó-ria.
- DITONGO DECRESCENTE: Vogal + Semivogal (o som decresce: -ai, -ei, -ou, -au) $\rightarrow$ pai, noi-te, pau-sa.'),
(687, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A vogal epentética (suarabácti / epêntese) é o acréscimo de uma vogal de apoio (geralmente o som /i/) na pronúncia de encontros consonantais impróprios/imperfeitos em que a consoante fica muda e travada no meio ou início da sílaba.
- Em "Estagnado", ocorre epêntese popular no encontro "gn" (/ista-gi-nado/);
- Em "Expectativas", ocorre epêntese no encontro "ct" (/es-peki-tativas/);
- Em "Intelectual", ocorre epêntese no encontro "ct" (/inteleki-tual/);
- Em "Tecnológicos", ocorre epêntese no encontro "cn" (/teki-nológicos/).
Na palavra "Excluindo", o encontro consonantal "cl" é próprio/perfeito (consoante oclusiva + líquida na mesma sílaba: ex-cluin-do), não havendo inserção de vogal epentética na pronúncia padrão. Por isso, é a única que constitui a exceção solicitada.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Estagnado" apresenta encontro impróprio "gn", sujeito à epêntese (/gn/ $\rightarrow$ /gin/).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Expectativas" apresenta encontro impróprio "ct", sujeito à epêntese (/kt/ $\rightarrow$ /kit/).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Intelectual" apresenta encontro impróprio "ct", sofrendo frequentemente vocalização epentética.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Tecnológicos" apresenta encontro impróprio "cn", sujeito à epêntese (/kn/ $\rightarrow$ /kin/).

BIZU DE PROVA:
Encontros Consonantais e Epêntese:
- Encontros PERFEITOS (consoante + L / R na mesma sílaba: cl, bl, fl, pr, tr, br) $\rightarrow$ NÃO sofrem epêntese ("ex-cluir", "pra-to", "blu-sa").
- Encontros IMPERFEITOS/IMPRÓPRIOS (gn, ct, cn, tm, ps, dv, dj, pt) $\rightarrow$ Podem gerar VOGAL EPENTÉTICA de apoio na fala coloquial ("ad-vogado" $\rightarrow$ "adi-vogado", "pneu" $\rightarrow$ "pineu").'),
(688, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
A alternativa que preenche correta e respectivamente as lacunas do texto é: "concepção – dimensão – caos".
1) "concepção": grafada com "c", "p" mudo e "ç" (do latim *conceptio, -onis*);
2) "dimensão": substantivo feminino grafado com "s" e "ão" (derivado do latim *dimensio*);
3) "caos": substantivo masculino que significa desordem, desorganização ou confusão generalizada, grafado com "o" e "s" final ("no caos normativo e institucional"), em oposição à forma parônima "calos" ou ao regionalismo "caus".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Apresenta as formas incorretas "concepsão" (com ps) e "caus" (com u).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Erra a grafia de "concepsão" e "dimenção" (com ç).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Erra a grafia de "consepção" (com s).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Apresenta erros ortográficos em todas as palavras ("consepção", "dimenção", "caus").

BIZU DE PROVA:
Atenção à ortografia de palavras terminadas em -SÃO vs. -ÇÃO:
- Verbos terminados em -NDER, -NDIR formam substantivos em -SÃO (expandir $\rightarrow$ expansão; ascender $\rightarrow$ ascensão; dimensão).
- Raízes latinas com -PT formam substantivos em -PÇÃO (conceber/concept $\rightarrow$ concepção; exceto/except $\rightarrow$ excepção/exceção; optar $\rightarrow$ opção).');

-- ----------------------------------------------------------------------------
-- Snapshot ANTES.
-- ----------------------------------------------------------------------------
-- 1) linha inteira das 50 (exceto explicacao/atualizado_em).
create temporary table _lp2_snap_questoes on commit drop as
select id, (to_jsonb(q) - 'explicacao' - 'atualizado_em') as dados_imutaveis
from public.questoes q
where q.id in (242,243,244,245,273,274,275,276,277,278,279,280,281,282,283,284,304,305,306,307,308,316,317,318,319,320,321,322,323,324,325,328,329,330,331,332,333,334,335,336,679,680,681,682,683,684,685,686,687,688);

-- 2) alternativas completas das 50.
create temporary table _lp2_snap_alternativas on commit drop as
select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
from public.alternativas a
where a.questao_id in (242,243,244,245,273,274,275,276,277,278,279,280,281,282,283,284,304,305,306,307,308,316,317,318,319,320,321,322,323,324,325,328,329,330,331,332,333,334,335,336,679,680,681,682,683,684,685,686,687,688)
group by questao_id;

-- 3) hash de explicacao de TODAS as questoes do banco.
create temporary table _lp2_snap_hash_todas on commit drop as
select id, md5(coalesce(explicacao, '')) as hash_explicacao
from public.questoes;

-- 4) contagens globais.
create temporary table _lp2_snap_global on commit drop as
select
  (select count(*) from public.questoes)            as total_questoes_antes,
  (select count(*) from public.questoes where ativa) as total_ativas_antes;

create temporary table _lp2_asserts (ordem serial primary key, descricao text, ok boolean) on commit drop;

-- ----------------------------------------------------------------------------
-- Precondicoes.
-- ----------------------------------------------------------------------------
do $$
declare
  v_qtd int;
begin
  if (select count(*) from _lp2_novas_explicacoes) <> 50 then
    raise exception 'PRECONDICAO FALHOU: staging nao tem exatamente 50 explicacoes';
  end if;

  select count(*) into v_qtd from public.questoes where id in (select id from _lp2_novas_explicacoes);
  if v_qtd <> 50 then
    raise exception 'PRECONDICAO FALHOU: esperado 50 questoes no banco, encontrado %', v_qtd;
  end if;

  if exists (
    select 1 from public.questoes q
    join _lp2_novas_explicacoes s on s.id = q.id
    where q.materia_id is distinct from 6 or q.ativa is distinct from true
  ) then
    raise exception 'PRECONDICAO FALHOU: alguma das 50 nao esta mais no estado auditado (materia_id=6, ativa=true)';
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ESCRITA: atualiza explicacao + atualizado_em das 50.
-- ----------------------------------------------------------------------------
create temporary table _lp2_ids_afetados (id bigint primary key) on commit drop;

do $$
declare
  v_linhas int;
begin
  with atualizado as (
    update public.questoes q
    set explicacao = s.explicacao, atualizado_em = now()
    from _lp2_novas_explicacoes s
    where q.id = s.id
    returning q.id
  )
  insert into _lp2_ids_afetados (id) select id from atualizado;

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
  insert into _lp2_asserts (descricao, ok)
  select 'exatamente 50 questoes afetadas pelo UPDATE', (select count(*) from _lp2_ids_afetados) = 50;

  insert into _lp2_asserts (descricao, ok)
  select 'os ids afetados sao exatamente os 50 esperados',
    (select array_agg(id order by id) from _lp2_ids_afetados) = ARRAY[242,243,244,245,273,274,275,276,277,278,279,280,281,282,283,284,304,305,306,307,308,316,317,318,319,320,321,322,323,324,325,328,329,330,331,332,333,334,335,336,679,680,681,682,683,684,685,686,687,688]::bigint[];

  insert into _lp2_asserts (descricao, ok)
  select 'enunciado/alternativas-relacao/gabarito/materia/assunto/ativa/banca/concurso/ano/fonte preservados nas 50 (comparacao jsonb byte-a-byte, exceto explicacao/atualizado_em)',
    not exists (
      select 1 from public.questoes q
      join _lp2_snap_questoes s on s.id = q.id
      where (to_jsonb(q) - 'explicacao' - 'atualizado_em') <> s.dados_imutaveis
    );

  insert into _lp2_asserts (descricao, ok)
  select 'alternativas das 50 continuam byte-identicas (texto/correta/ordem)',
    not exists (
      select 1
      from _lp2_snap_alternativas s
      join (
        select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
        from public.alternativas a
        where a.questao_id in (select id from _lp2_novas_explicacoes)
        group by questao_id
      ) d on d.questao_id = s.questao_id
      where d.alternativas <> s.alternativas
    );

  select count(*) into v_sem_correta
  from _lp2_novas_explicacoes s
  where (select count(*) from public.alternativas a where a.questao_id = s.id and a.correta) <> 1;
  insert into _lp2_asserts (descricao, ok) values ('as 50 continuam com exatamente 1 alternativa correta cada', v_sem_correta = 0);

  -- Classificacao EXPLICACAO_COMPLETA das 50 apos o UPDATE
  with alt_stats as (
    select q.id as questao_id, count(a.id) as n_alt, count(a.id) filter (where a.correta) as n_corretas,
      bool_and(lower(btrim(a.texto)) in ('certo', 'errado')) and count(a.id) = 2 as eh_certo_errado
    from public.questoes q
    left join public.alternativas a on a.questao_id = q.id
    where q.id in (select id from _lp2_novas_explicacoes)
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
    where q.id in (select id from _lp2_novas_explicacoes)
  )
  select count(*) filter (where status = 'EXPLICACAO_COMPLETA') into v_completas from classificado;
  insert into _lp2_asserts (descricao, ok) values ('as 50 passam no classificador canonico como EXPLICACAO_COMPLETA', v_completas = 50);

  insert into _lp2_asserts (descricao, ok)
  select 'nenhuma outra questao do banco teve explicacao alterada',
    not exists (
      select 1 from public.questoes q
      join _lp2_snap_hash_todas s on s.id = q.id
      where md5(coalesce(q.explicacao, '')) <> s.hash_explicacao
        and q.id <> ALL(ARRAY[242,243,244,245,273,274,275,276,277,278,279,280,281,282,283,284,304,305,306,307,308,316,317,318,319,320,321,322,323,324,325,328,329,330,331,332,333,334,335,336,679,680,681,682,683,684,685,686,687,688]::bigint[])
    );

  select count(*) into v_total_depois from public.questoes;
  insert into _lp2_asserts (descricao, ok) values ('total de questoes no banco inalterado (nenhuma criada/excluida)', v_total_depois = (select total_questoes_antes from _lp2_snap_global));

  select count(*) into v_ativas_depois from public.questoes where ativa = true;
  insert into _lp2_asserts (descricao, ok) values ('total de questoes ATIVAS do Papiro inalterado', v_ativas_depois = (select total_ativas_antes from _lp2_snap_global));
end $$;

-- Relatorio de asserts
do $$
declare
  r record;
  v_total integer;
  v_ok integer;
begin
  for r in select descricao, ok from _lp2_asserts order by ordem loop
    if r.ok then
      raise notice 'OK: %', r.descricao;
    else
      raise exception 'FALHOU: %', r.descricao;
    end if;
  end loop;

  select count(*), count(*) filter (where ok) into v_total, v_ok from _lp2_asserts;
  raise notice '=== RESUMO: % / % asserts passaram ===', v_ok, v_total;
  if v_ok <> v_total then
    raise exception 'Harness falhou: nem todos os asserts passaram.';
  end if;
end $$;

-- Nada commitado: tudo desfeito abaixo.
COMMIT;
