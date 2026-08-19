-- ============================================================================
-- AUDITORIA GLOBAL -- LÍNGUA PORTUGUESA -- LOTE 1 (50 QUESTÕES)
-- Aplicação de 50 explicações pedagógicas (materia_id 6)
-- IDs: 6,16,17,18,34,65,66,67,68,69,70,71,72,73,114,115,116,117,118,119,120,121,122,123,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241
-- HARNESS TRANSACIONAL -- TERMINA SEMPRE EM ROLLBACK, NADA PERSISTE.
-- ============================================================================
--
-- Gerado automaticamente por scripts/generate-portugues-lote1-harness.mjs a partir de
-- scripts/portugues-lote1-explicacoes.mjs.
-- ============================================================================

BEGIN;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

-- ----------------------------------------------------------------------------
-- Staging: id -> nova explicacao (fonte: scripts/portugues-lote1-explicacoes.mjs).
-- ----------------------------------------------------------------------------
create temporary table _lp1_novas_explicacoes (id bigint primary key, explicacao text) on commit drop;
insert into _lp1_novas_explicacoes (id, explicacao) values
(6, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O verbo "dirigiu-se" rege preposição "a" (quem se dirige, dirige-se a algum lugar ou a alguém) e o substantivo feminino "autoridade" admite o artigo definido "a" ("a autoridade responsável"). Da fusão da preposição "a" com o artigo "a" resulta o acento indicativo de crase: "à autoridade".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Pé" é palavra masculina ("o pé"). A regra geral proíbe terminantemente o uso de crase antes de vocábulos masculinos, pois antes deles ocorre apenas a preposição "a" sem artigo feminino (o correto é "a pé").

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Em locuções formadas por palavras idênticas repetidas ("frente a frente", "cara a cara", "gota a gota", "dia a dia"), não há ocorrência de artigo feminino, havendo apenas a preposição "a". Logo, o uso da crase é incorreto.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Partir" é verbo no infinitivo. Não existe artigo definido antes de verbos na Língua Portuguesa; havendo apenas a preposição "a", a crase é proibida (o correto é "a partir de").

BIZU DE PROVA:
Lembre-se dos 4 casos clássicos de CRASE PROIBIDA: 1) Antes de verbo ("a partir"); 2) Antes de palavra masculina ("a pé", "a prazo"); 3) Entre palavras repetidas ("frente a frente"); 4) Antes de pronome que não aceita artigo ("a ela", "a mim").'),
(16, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O sujeito da oração é "Os candidatos", cujo núcleo é o substantivo plural "candidatos". A regra geral de concordância verbal estabelece que o verbo concorda com o seu sujeito em número e pessoa, logo o verbo "chegaram" está corretamente flexionado na 3ª pessoa do plural.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O verbo "haver", quando empregado no sentido de "existir", "ocorrer" ou "acontecer", é impessoal (não tem sujeito) e deve permanecer obrigatoriamente na 3ª pessoa do singular: o correto é "Houve muitos recursos".

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O verbo "fazer", quando empregado para indicar tempo decorrido ou fenômeno meteorológico, é impessoal e não flexiona para o plural: o correto é "Faz dois anos".

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O verbo "existir" é pessoal e admite sujeito com o qual deve concordar. Na frase, o sujeito é "boas razões" (plural), exigindo a flexão verbal no plural: o correto é "Existem boas razões".

BIZU DE PROVA:
Diferença de ouro em provas da Fundatec e concursos militares: HAVER (sentido de existir) = impessoal (fica sempre no singular: "Houve problemas"); EXISTIR = pessoal (concorda normalmente com o sujeito: "Existiram problemas").'),
(17, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Em um texto dissertativo-argumentativo, a tese é a ideia central, o ponto de vista ou posicionamento defendido pelo autor a respeito do tema. Toda a argumentação e os dados apresentados ao longo do texto têm como função exclusiva fundamentar, sustentar e comprovar essa tese.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Exemplos secundários são recursos argumentativos (estratégias de ilustração ou comprovação) e não se confundem com a tese em si.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O título pode sugerir ou sintetizar o tema, mas a tese é uma proposição articulada e fundamentada no corpo do texto, não restrita ao título.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A tese não se limita a uma repetição literal de palavras do primeiro parágrafo; ela é a linha mestra conceitual que permeia toda a estrutura textual.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A tese pode ser apresentada de forma explícita logo na introdução do texto; não é uma exigência que seja necessariamente implícita.

BIZU DE PROVA:
Fórmula do texto dissertativo-argumentativo: TEMA (o assunto geral) + TESE (a opinião/posicionamento do autor sobre o assunto) + ARGUMENTOS (os porquês que sustentam a opinião).'),
(18, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
De acordo com o Manual de Redação da Presidência da República (MRPR), a redação oficial é a maneira pela qual o Poder Público redige atos normativos e comunicações. São atributos fundamentais da redação oficial: clareza, precisão, objetividade, concisão, impessoalidade, formalidade, padronização e uso da norma-padrão da língua.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A redação oficial rejeita o uso de linguagem regional (regionalismos) e a subjetividade, exigindo impessoalidade e a norma-padrão de alcance nacional.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O Manual da Presidência orienta o uso de períodos concisos, frases de ordem direta e vocabulário simples e preciso, repudiando o preciosismo e o vocabulário rebuscado.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O princípio da impessoalidade veda a inclusão de impressões, juízos de valor subjetivos ou opiniões de cunho estritamente pessoal do redator.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A formalidade e o respeito às normas protocolares são obrigatórios na administração pública, sendo vedada a informalidade.

BIZU DE PROVA:
Pilares da Redação Oficial no MRPR: C-P-O-C-I (Clareza, Precisão, Objetividade, Concisão e Impessoalidade), sempre no padrão culto da língua portuguesa.'),
(34, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
1) "ao caçador": o verbo "devorar" é transitivo direto (quem devora, devora algo/alguém). Como o sujeito posposto "o leão" poderia causar ambiguidade de sentido quanto a quem devorou quem, empregou-se a preposição "a" para marcar o complemento, caracterizando um "objeto direto preposicionado".
2) "perseguiram-no": o verbo "perseguir" é transitivo direto (VTD) e o pronome oblíquo "o" (transformado em "-no" pela terminação nasal do verbo) atua como "objeto direto".
3) "trouxeram-no": o verbo "trazer" é transitivo direto (VTD) e o pronome "-no" desempenha a função sintática de "objeto direto".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Classifica "ao caçador" e "perseguiram-no" como objetos indiretos, mas ambos são objetos diretos (o primeiro preposicionado por clareza sintática e o segundo direto pronominal).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Erra ao classificar o primeiro complemento como objeto indireto e o terceiro como objeto indireto.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Erra ao classificar o segundo complemento ("perseguiram-no") como objeto indireto; o pronome "-no" exerce função estrita de objeto direto.

BIZU DE PROVA:
O Objeto Direto Preposicionado ocorre com verbos transitivos diretos acompanhados de preposição não exigida pela regência, principalmente para evitar ambiguidade ("Venceu ao inimigo o guerreiro") ou por motivos enfáticos/estilísticos.'),
(65, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
As assertivas I e III estão corretas. Assertiva I (correta): o primeiro parágrafo do texto descreve os impactos devastadores das enchentes de maio de 2024, enquanto o segundo parágrafo contrasta com as ações espontâneas de ajuda mútua e resgate. Assertiva III (correta): o texto conclui resgatando a perspectiva de esperança e reconstrução calcada nos atos de altruísmo coletivo demonstrados pela população.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Deixa de incluir a assertiva III, que também reflete com exatidão o conteúdo e a mensagem central do texto.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Inclui a assertiva II, que está incorreta: o autor menciona expressamente que, mesmo durante o caos, ocorreram saques e crimes, mostrando que a calamidade não eliminou a perversidade de alguns indivíduos.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Deixa de incluir a assertiva I, que descreve com precisão a estrutura temática de transição entre o primeiro e o segundo parágrafos.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Considera a assertiva II correta, contrariando o texto-base que pontua a persistência de atos reprováveis paralelamente à onda de solidariedade.

BIZU DE PROVA:
Em questões de interpretação da Fundatec com assertivas I, II e III, atente para palavras generalizantes ("desaparecer", "todos", "sempre") que costumam invalidar assertivas que extrapolam o texto.'),
(66, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
A sequência ortográfica correta para as lacunas do texto é "g – z – sc". A primeira lacuna exige "g" (grafia de palavras derivadas de radicais com ''g'', como coragem/gesto/fuligem); a segunda lacuna exige "z" (sufixo derivacional -izar em palavras sem ''s'' no radical base, como amenizar/cicatrizar); e a terceira exige o dígrafo "sc" (como em fascínio/renascer/impassível/florescer).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Propõe "s" para a segunda lacuna, contrariando a regra de sufixação em -izar, e erra a correspondência do texto.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Propõe "j" para a primeira palavra e "c" para a terceira, gerando erros ortográficos graves nas formas originais.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Propõe incorretamente "j" na primeira e "s" na segunda lacuna.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Propõe "c" simples para a terceira lacuna, quando o vocábulo original exige o dígrafo "sc".

BIZU DE PROVA:
Regra de ouro de formação com -IZAR x -ISAR: se a palavra primitiva já tem "S" na última sílaba (pesquisa, análise, aviso), grafa-se com "S" (pesquisar, analisar, avisar). Se a primitiva não tem "S" (fértil, canal, cicatriz), usa-se "Z" (fertilizar, canalizar, cicatrizar).'),
(67, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
1) "[...] tão incontrolável quanto pavorosamente banal": a estrutura correlativa "tão... quanto" estabelece valor semântico de COMPARAÇÃO (igualdade).
2) "[...] tão absurdas que uma legislação específica deveria punir": a estrutura "tão... que" introduz uma oração subordinada com valor de CONSEQUÊNCIA (efeito decorrente da intensidade).
3) "Mas também fez florescer...": a locução aditiva correlacionada a uma anterior ("não apenas... mas também") introduz ideia de ADIÇÃO/SOMA.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Classifica o item 1 como causa e o item 3 como alternativa, divergindo totalmente das relações semânticas de comparação e adição.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Classifica o item 1 como causa e o item 2 como condição, quando se trata de comparação e consequência.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Classifica o item 2 como condição e o item 3 como alternativa.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Classifica o item 1 como causa, o 2 como condição e o 3 como alternativa.

BIZU DE PROVA:
Conectivos estruturais de causa vs. consequência: se a causa vem na oração principal ("estava TÃO cansado..."), a oração com "QUE" é CONSEQUÊNCIA ("...QUE dormiu na aula"). Já "MAS TAMBÉM" é sempre aditivo quando vem após "não só/não apenas".'),
(68, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A sequência correta de preenchimento dos parênteses é V – F – V.
- 1º parêntese (Verdadeiro): no contexto de desastre natural e cheias, "calamidade" é sinônimo perfeitamente adequado de "catástrofe", "desastre" ou "tragédia".
- 2º parêntese (Falso): morfologicamente, "calamidade" é um SUBSTANTIVO feminino (o nome de um estado/evento), e não um adjetivo uniforme.
- 3º parêntese (Verdadeiro): a separação silábica é ca-la-mi-da-de (5 sílabas = polissílaba), sendo todas sílabas simples (consoante + vogal), sem nenhum dígrafo ou encontro consonantal.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Marca o 2º parêntese como verdadeiro, mas "calamidade" não é adjetivo, e sim substantivo.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Marca o 3º parêntese como falso, quando a palavra realmente tem 5 sílabas sem dígrafos nem encontros consonantais.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Marca o 1º parêntese como falso, negando a equivalência semântica evidente entre calamidade e catástrofe.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Inverte a veracidade do 1º e do 2º itens.

BIZU DE PROVA:
Atenção à morfologia vs. semântica: uma palavra que indica uma qualidade ou estado pode ser substantivo se ela nomeia o fenômeno ("a beleza", "a calamidade", "a tristeza") e só vira adjetivo quando qualifica outro termo ("situação calamitosa").'),
(69, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A soma das afirmações corretas resulta em 05 (afirmações 1 e 4 estão corretas, 1 + 4 = 5).
- Afirmação 1 (Correta): o pronome "seus" retoma anaforicamente os rios em relação às cidades por eles banhadas.
- Afirmação 2 (Incorreta): o pronome relativo "que" na linha 12 refere-se a outro elemento sintático precedente no período.
- Afirmação 3 (Incorreta): as expressões desempenham papéis coesivos distintos ao longo da argumentação.
- Afirmação 4 (Correta): o pronome "se" atua ligado ao sujeito "homem", que é o termo nuclear de referência.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O valor 03 não corresponde à soma das afirmações validadas pelo gabarito oficial da banca Fundatec.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O valor 04 implicaria considerar apenas a afirmação 4 ou uma combinação não correspondente ao texto.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O valor 06 decorreria da soma de afirmações incorretas (ex.: 2 + 4).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O valor 09 decorreria da inclusão de afirmações falsas no cômputo total.

BIZU DE PROVA:
Em questões de somatória da Fundatec, resolva cada item isoladamente com V/F e anote os valores ao lado antes de efetuar a soma final, conferindo rigorosamente os referentes pronominais no texto.'),
(70, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O preenchimento correto e respectivo das lacunas é "às – à – a".
- 1ª lacuna: exige "às" com crase por se tratar de locução ou regência com preposição "a" diante de substantivo feminino plural determinado ("às margens", "às pessoas").
- 2ª lacuna: exige "à" com crase por constituir locução adverbial feminina ("à tona", "à vista", "à deriva").
- 3ª lacuna: exige "a" sem crase, pois precede verbo no infinitivo ou palavra masculina/indeterminada, onde não ocorre artigo feminino.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Deixa de empregar o acento indicativo de crase nas duas primeiras lacunas, onde a fusão preposição + artigo é obrigatória.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Emprega crase indevidamente na terceira lacuna diante de vocábulo que não admite artigo feminino.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Omite a crase na primeira lacuna e a utiliza incorretamente na segunda.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Inverte o uso do acento indicativo de crase entre a segunda e a terceira lacunas.

BIZU DE PROVA:
Locuções prepositivas, conjuntivas e adverbiais femininas SEMPRE levam crase: "às vezes", "às claras", "à proporção que", "à medida que", "à vista de", "à procura de".'),
(71, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
No trecho "[...] algumas mentes podres aproveitaram o momento de desespero para roubar e depredar", o sujeito do verbo "aproveitaram" é "algumas mentes podres". Esse sintagma nominal possui um único núcleo substantivo ("mentes"), o que classifica sintaticamente o sujeito como SIMPLES.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O verbo possui sujeito expresso ("algumas mentes podres"), não se tratando de oração sem sujeito.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O sujeito está perfeitamente determinado e expresso na oração, logo não é indeterminado.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O sujeito está explícito na frase, não oculto/elíptico/desinencial.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O sujeito possui apenas um núcleo ("mentes"). Para ser composto, deveria possuir dois ou mais núcleos coordenados (ex.: "mentes e corações").

BIZU DE PROVA:
Não confunda sujeito no plural com sujeito composto! "Muitas pessoas chegaram" -> Sujeito SIMPLES (1 núcleo: pessoas). "O homem e a mulher chegaram" -> Sujeito COMPOSTO (2 núcleos: homem, mulher).'),
(72, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A frase original "A tragédia nos arrancou pontes, levou casas e plantações, tirou vidas de entes queridos" está na voz ativa, com sujeito agente "A tragédia" e três complementos diretos coordenados. A transposição para a voz passiva analítica preserva todas as relações de sentido e regras de concordância: "Pontes foram arrancadas de nós, casas e plantações foram levadas, vidas de entes queridos foram tiradas pela tragédia".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Altera o sentido original ao transformar "pelas vidas de entes queridos" em agente causador da destruição de casas e plantações.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Cria uma relação semântica sem nexo ("Pontes arrancaram de nós casas e plantações"), personificando as pontes como agentes da destruição.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Adulterou completamente o sentido da oração ao afirmar que "a tragédia foi tirada pela vida de entes queridos".

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Mantém o disparate semântico de atribuir às "pontes" a ação de arrancar casas e plantações.

BIZU DE PROVA:
Na transposição de voz ativa para passiva: 1) O objeto direto da ativa vira o sujeito paciente da passiva; 2) O sujeito da ativa vira o agente da passiva ("pela tragédia"); 3) O tempo verbal original é rigorosamente mantido no verbo auxiliar "ser" (passado simples "arrancou" -> "foram arrancadas").'),
(73, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A alternativa A é a INCORRETA (o que a questão pede). De acordo com o Manual de Redação da Presidência da República (3ª edição, 2018), o campo "Assunto:" deve ser uma síntese concisa do teor do documento, DEVE ser antecedido pela palavra "Assunto:" e apenas a primeira letra da frase que descreve o assunto deve ser maiúscula (além de nomes próprios), e não todas as palavras.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Está de acordo com o Manual (MRPR item 3.2.3): quando o documento não se destina a encaminhamento, a introdução apresenta o objetivo/finalidade da comunicação. Como o enunciado pede a opção incorreta, a B não pode ser o gabarito.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Está em conformidade com o Manual: em documentos de mero encaminhamento, a introdução deve indicar a finalidade e fazer referência expressa ao expediente que solicitou o envio.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Reproduz fielmente a regra dos fechos do MRPR: "Respeitosamente" para autoridades de hierarquia superior (inclusive o Presidente) e "Atenciosamente" para autoridades de mesma hierarquia ou inferior.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Está correta quanto às normas do MRPR: informa-se o nome da autoridade signatária em letras maiúsculas, sem negrito, e sem linha pontilhada ou traço para assinatura acima do nome.

BIZU DE PROVA:
Regra dos FECHOS oficiais no MRPR (apenas DOIS fechos existem):
1) RESPEITOSAMENTE: para autoridade SUPERIOR (inclusive Presidente).
2) ATENCIOSAMENTE: para mesma hierarquia, inferior ou público em geral.
Não existem mais fechos como "Cordialmente", "Saudações" ou "Sem mais para o momento".'),
(114, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A palavra "Dancinha" apresenta exatamente dois dígrafos:
1) "an": dígrafo vocálico/nasal (/ã/), em que a vogal "a" seguida de "n" na mesma sílaba representa um único fonema vocálico nasal.
2) "nh": dígrafo consonantal (/ɲ/), em que duas letras representam um único som consonantal palatal.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Questão" possui apenas 1 dígrafo consonantal ("qu", pois o "u" não é pronunciado antes de "e"). O encontro "ão" é ditongo nasal, não dígrafo.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Classificação" possui apenas 1 dígrafo consonantal ("ss"). "ão" é ditongo nasal descrescente.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Grandona" possui apenas 1 dígrafo vocálico ("an" em "gran-").

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Esquisitices" possui apenas 1 dígrafo consonantal ("qu" em "-qui-").

BIZU DE PROVA:
Dígrafo = 2 letras que representam 1 único fonema (som).
- Consonantais: ch, lh, nh, rr, ss, sc, sç, xc, xs, qu/gu (quando o u não soa).
- Vocálicos/Nasais: am, an, em, en, im, in, om, on, um, un (no interior ou fim de sílaba).'),
(115, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O preenchimento gramaticalmente correto das lacunas é "à – a – à – à – às":
- Linha 01: "à" com crase diante de substantivo feminino determinado por regência com preposição.
- Linha 12: "a" sem crase diante de verbo ou palavra masculina onde não há artigo feminino.
- Linha 24: "à" com crase em locução prepositiva feminina.
- Linha 33: "à" com crase por fusão da preposição com artigo em adjunto adverbial feminino.
- Linha 34: "às" com crase no plural diante de substantivo feminino plural determinado ("às normas", "às pessoas").

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Emprega indevidamente crase na segunda lacuna e omite a crase no plural da última lacuna.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Omite a crase na primeira, terceira e quarta lacunas, violando as regras de regência e locuções femininas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Apresenta incorreções na distribuição do acento indicativo de crase nas lacunas intermediárias e finais.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Inverte a ocorrência de crase entre as linhas 01 e 12 do texto.

BIZU DE PROVA:
Método da troca por palavra masculina para testar a crase: substitua o termo feminino por um equivalente masculino (ex.: "à escola" -> "ao colégio"). Se resultar em "AO", há crase obrigatória! Se resultar em "A" ou "O", não há crase.'),
(116, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
A frase original é: "os jovens renovam o vocabulário, reforçam sua superioridade sobre os caquéticos e mantêm a classificação de certo e errado sob seu domínio".
Substituindo a palavra "jovens" pelo singular "jovem", o período exige obrigatoriamente QUATRO outras alterações gramaticais para manter a concordância padrão:
1) O artigo que antecede o sujeito: "os" -> "o" ("o jovem");
2) O primeiro verbo coordenado: "renovam" -> "renova";
3) O segundo verbo coordenado: "reforçam" -> "reforça";
4) O terceiro verbo coordenado: "mantêm" (plural com acento circunflexo) -> "mantém" (singular com acento agudo).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Afirma que nenhuma alteração seria necessária, gerando erro crasso de concordância entre sujeito singular e verbos no plural.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Computa apenas uma alteração, ignorando os demais verbos e o determinante do sujeito.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Deixa de computar duas alterações obrigatórias na cadeia de concordância.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Computa apenas 3 alterações, esquecendo-se da flexão do acento diferencial no verbo manter ("mantém" x "mantêm") ou do artigo "o".

BIZU DE PROVA:
Acentuação dos derivados de TER e VIR:
- No singular recebem ACENTO AGUDO: ele mantém, ele obtém, ele intervém.
- No plural recebem ACENTO CIRCUNFLEXO: eles mantêm, eles obtêm, eles intervêm.'),
(117, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
As afirmações I e II estão corretas e fundamentadas no Manual de Redação da Presidência da República:
- Item I (Correto): define a essência da redação oficial — o emissor é sempre o serviço público, o assunto decorre de suas competências e atribuições institucionais, e o receptor pode ser um cidadão, pessoa jurídica ou outro órgão público.
- Item II (Correto): a exigência do padrão culto, clareza e objetividade decorre diretamente do princípio constitucional da publicidade dos atos administrativos e do interesse público.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Ignora o item II, que é igualmente correto segundo a doutrina e o MRPR.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Ignora o item I, que traz a definição canônica dos polos da comunicação administrativa.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Considera apenas o item III, que está totalmente errado (a redação oficial é privativa da esfera pública e exige constante clareza e adequação à finalidade pública).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Inclui o item III, que é falso por afirmar que a redação oficial é adotada na esfera privada e dispensaria adequação.

BIZU DE PROVA:
A redação oficial é pautada pelo princípio da IMPESSOALIDADE em três dimensões: 1) Quem comunica (o órgão, nunca o servidor em nome próprio); 2) A quem se comunica (o cidadão/destinatário em caráter público); 3) O assunto comunicado (o interesse público).'),
(118, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Apenas a afirmação I está correta.
- Item I (Correto): em comunicações oficiais dirigidas aos Chefes dos três Poderes da República (Presidente da República, Presidente do Congresso/Câmara/Senado, Presidente do STF), o único vocativo formalmente admitido é "Excelentíssimo Senhor [Cargo]" (ex.: "Excelentíssimo Senhor Presidente da República"). Fórmulas de afeto como "Nosso Caríssimo" são absolutamente vedadas.
- Item II (Incorreto): para o Presidente da República, o pronome de tratamento correto é "Vossa Excelência" (e não "Sua Excelentíssima Autoridade", que sequer existe na língua portuguesa).
- Item III (Incorreto): o texto continha vocativo e tratamento informais/incompatíveis com a autoridade destinatária.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O item II é falso porque a expressão "Sua Excelentíssima Autoridade" é uma aberração não prevista no MRPR.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O item III é falso, pois tanto o vocativo quanto o pronome de tratamento originais estavam em desacordo com as normas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Inclui o item II, que propõe uma fórmula de tratamento inexistente.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Reúne apenas as assertivas que contêm erros conceituais (II e III).

BIZU DE PROVA:
Vocativos oficiais no MRPR 2018:
- "Excelentíssimo Senhor [Cargo]" -> EXCLUSIVO para Chefes de Poder (Presidente da República, Presidente do Congresso Nacional/Câmara/Senado e Presidente do STF).
- "Senhor [Cargo]" -> Para TODAS as demais autoridades (ex.: "Senhor Governador", "Senhor Ministro", "Senhor Juiz").'),
(119, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O preenchimento ortográfico correto é "mordazes – trás – ruborizando – quisermos":
1) "mordazes": plural do adjetivo "mordaz", grafado com "z" final no singular, mantendo o "z" no plural ("mordazes").
2) "trás": advérbio que indica situação posterior ou lugar ("por trás", "para trás"), grafado com "s" e acento circunflexo (diferente da forma verbal "traz", do verbo trazer).
3) "ruborizando": gerúndio derivado do verbo "ruborizar", formado com o sufixo "-izar" (já que o radical "rubor" não possui "s").
4) "quisermos": forma do futuro do subjuntivo do verbo "querer", cujas formas conjugadas mantêm sempre a consoante "s" do radical etimológico (quis, quisera, quisesse, quisermos).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Apresenta erros nas grafias de "mordases" (com s), "tráz" (com z) e "quizermos" (com z).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Erra a grafia de "traz" (empregado no lugar do advérbio trás), "ruborisando" (com s) e "quizermos" (com z).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Erra a grafia de "mordases", "traz" e "ruborisando".

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Erra a grafia de "mordases", "ruborisando" e "quizermos".

BIZU DE PROVA:
- Formas dos verbos QUERER e PÔR nunca levam "Z"! É sempre com "S": quis, quiser, quisesse, pus, puser, pusesse.
- TRÁS (com S e acento) = lugar/posição posterior ("olhou para trás").
- TRAZ (com Z, sem acento) = forma do verbo trazer ("ele traz o livro").'),
(120, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O preenchimento correto das lacunas é "em que – que – cujo":
1) "em que": o termo antecedente designa lugar/situação em que algo ocorre, exigindo a preposição "em" associada ao pronome relativo ("no qual" / "em que").
2) "que": pronome relativo de uso geral, exercendo função de sujeito ou objeto direto sem exigência de preposição.
3) "cujo": pronome relativo que estabelece relação de posse entre dois substantivos ("substantivo + cujo + substantivo possuído"), sem preposição antecedente e SEM emprego de artigo após o pronome.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Emprega a forma "cujo o", o que constitui erro gramatical grave: a norma culta proíbe expressamente o uso de artigo definido imediatamente após o pronome relativo "cujo" (não existe "cujo o", "cuja a").

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Emprega a preposição "de" indevidamente na primeira ("de que") e na terceira ("de cujo") lacunas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Apresenta a construção aglutinada "cujo o qual", completamente inexistente na norma-padrão.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Emprega a forma redundante "cujo qual".

BIZU DE PROVA:
Regras sagradas do pronome CUJO:
1) Fica sempre entre dois substantivos e indica posse ("autor cujo livro li").
2) NUNCA admite artigo depois de si: "cujo o", "cuja a", "cujos os" NÃO EXISTEM em português culto!'),
(121, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Apenas a afirmação II está correta.
- Item II (Correto): "porém" e "entretanto" são conjunções coordenativas adversativas sinônimas (junto a "mas", "contudo", "todavia", "no entanto"), podendo ser substituídas entre si sem qualquer alteração do valor semântico de oposição/contraste.
- Item I (Incorreto): "quando" introduz valor temporal, enquanto "conquanto" é uma conjunção subordinativa concessiva (sinônima de "embora", "ainda que"), alterando totalmente o sentido da oração.
- Item III (Incorreto): a partícula "se" no trecho expressa condição ou integração, não possuindo valor causal/explicativo próprio de "porque".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O item I é incorreto porque confunde conjunção temporal ("quando") com concessiva ("conquanto").

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O item III é incorreto porque "se" e "porque" possuem valores semânticos completamente distintos.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Inclui o item I como correto.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Inclui o item III como correto.

BIZU DE PROVA:
Cuidado com o falso amigo CONQUANTO:
- CONQUANTO = concessiva (equivale a "embora", "apesar de que").
- PORQUANTO = causal/explicativa (equivale a "porque", "já que").
- PORTANTO = conclusiva (equivale a "logo", "por isso").'),
(122, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Estão corretas as assertivas I e III.
- Assertiva I (Correta): no contexto figurado do texto, "caquéticos" e "matusaléns" são termos utilizados para designar pessoas muito velhas, idosas ou antiquadas, mantendo equivalência semântica e semântico-estilística.
- Assertiva III (Correta): a locução adverbial "à beça" significa em grande quantidade, com abundância, sendo sinônima perfeita de "à farta" ou "em profusão".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Deixa de incluir a assertiva III, que também é correta.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Aponta apenas a assertiva II, que está incorreta: "avexar" significa apressar, impacientar, apoquentar ou envergonhar (do linguajar regional e clássico), não equivalendo semanticamente a "sujeitar" (que significa submeter, subordinar).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Inclui a assertiva II, cuja correspondência de sentido é inadequada.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Inclui a assertiva II e exclui a assertiva I.

BIZU DE PROVA:
Em questões de sinonímia contextual da Fundatec, sempre verifique se a substituição preserva não só o sentido aproximado, mas a classe gramatical e a regência no trecho original.'),
(123, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Apenas a assertiva I está correta. Na frase “Quem for diferente da sua tribo lhes parecerá sem noção”:
- O verbo "parecerá" tem como sujeito toda a oração subordinada "Quem for diferente da sua tribo", tratando-se de uma Oração Subordinada Substantiva Subjetiva.
- Assertiva II (Incorreta): o pronome "quem" é pronome relativo indefinido e exerce a função de sujeito simples da oração subordinada ("quem for diferente"), e não sujeito indeterminado.
- Assertiva III (Incorreta): o pronome oblíquo "lhes" funciona sintaticamente como OBJETO INDIRETO (complemento com preposição implícita a eles/para eles), e não como objeto direto.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A assertiva II é falsa porque o pronome "quem" atua como sujeito determinado na sua própria oração.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A assertiva III é falsa porque o pronome "lhes" nunca exerce função de objeto direto na norma-padrão (é privativo de objeto indireto ou adjunto adnominal de posse).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Considera a assertiva II correta.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Considera as assertivas II e III corretas, quando ambas contêm erros sintáticos.

BIZU DE PROVA:
Função dos pronomes oblíquos átonos em provas de sintaxe:
- O, A, OS, AS = sempre OBJETO DIRETO (com variações -lo, -la, -no, -na).
- LHE, LHES = sempre OBJETO INDIRETO (ou adjunto adnominal com valor de posse: "beijou-lhe as mãos" = as mãos dela). Lhe NUNCA é objeto direto!'),
(216, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Todas as palavras da alternativa estão grafadas e acentuadas em perfeita consonância com as regras da Língua Portuguesa:
1) "saúde": acentua-se o "u" tônico em hiato com a vogal anterior ("sa-ú-de"), sozinho na sílaba.
2) "saída": acentua-se o "i" tônico em hiato ("sa-í-da"), formando sílaba sozinho.
3) "baú": acentua-se o "u" tônico em hiato na última sílaba ("ba-ú"), sem acompanhamento de consoante que não seja "s".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Omite o acento agudo obrigatório no hiato tônico de "saude" (correto: saúde) e "bau" (correto: baú).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Omite o acento agudo no hiato tônico de "saida" (correto: saída).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Omite o acento no oxítono/hiato de "bau" (correto: baú).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Apresenta "saude" e "saida" sem a acentuação gráfica obrigatória.

BIZU DE PROVA:
Regra do HIATO tônico: acentuam-se as letras "I" e "U" tônicas quando formam hiato com a vogal anterior, desde que estejam sozinhas na sílaba ou com "S", e não sejam seguidas por "NH" (ex.: sa-ú-de, fa-ís-ca, ba-ú, sa-í-da). Atenção: "ra-i-nha" e "ju-iz" não levam acento!'),
(217, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A divisão silábica da palavra é lâm-pa-da. A sílaba tônica é a antepenúltima ("lâm"), o que a classifica morfofonologicamente como PROPAROXÍTONA. Pela regra geral e absoluta da acentuação gráfica em língua portuguesa, TODAS as palavras proparoxítonas são obrigatoriamente acentuadas.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A palavra não é oxítona; a última sílaba ("da") é átona.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A palavra não é paroxítona nem termina em "r".

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A palavra é trissílaba (tem 3 sílabas), não sendo um monossílabo tônico.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A palavra não é oxítona nem termina em "em".

BIZU DE PROVA:
A regra mais fácil do Português: TODAS as palavras PROPAROXÍTONAS são acentuadas, sem exceção! (ex.: lâmpada, árvore, médico, polícia [quando tratada como proparoxítona aparente], ônibus, público).'),
(218, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A palavra "Paraná" tem a divisão silábica Pa-ra-ná. Sua sílaba tônica é a última ("ná"), caracterizando-a como OXÍTONA. Acentuam-se graficamente as oxítonas terminadas nas vogais tônicas "a", "e", "o" (seguidas ou não de "s"), e nas terminações "em", "ens". Portanto, sua acentuação justifica-se exatamente por ser oxítona terminada em "a".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Árvore" (ár-vo-re) é proparoxítona, acentuada pela regra das proparoxítonas.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Lâmpada" (lâm-pa-da) é proparoxítona, acentuada por ter a antepenúltima sílaba tônica.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"Fácil" (fá-cil) é paroxítona terminada em "l", acentuada pela regra das paroxítonas terminadas em L, N, R, X, PS.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"Tórax" (tó-rax) é paroxítona terminada em "x", acentuada pela regra das paroxítonas.

BIZU DE PROVA:
Regra das OXÍTONAS: acentuam-se as que terminam em:
- A(s): sofá, Paraná, cajá.
- E(s): café, você, jacarés.
- O(s): cipó, avô, paletós.
- EM/ENS: também, parabéns, armazém.'),
(219, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Na oração "Não me disseram a verdade", a palavra "Não" é um advérbio de sentido negativo. Na sintaxe de colocação pronominal, palavras e advérbios de sentido negativo atuam como fator obrigatório de atração, exigindo o emprego do pronome oblíquo átono antes do verbo (PRÓCLISE).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A posição "Disseram-me não a verdade" desestrutura a oração e viola a atração exercida pela partícula negativa.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A norma-padrão proíbe expressamente iniciar períodos ou orações com pronome oblíquo átono ("Me disseram..." é linguagem coloquial; no padrão culto formal exige-se "Disseram-me...").

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O verbo está no futuro do presente ("Direi"). Com verbos no futuro do presente ou do pretérito, a ênclise é terminantemente proibida na norma culta (o correto sem atrativo seria a mesóclise: "Dir-lhe-ei").

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Apresenta o pronome solto sem ligação sintática padrão ("Entregarei te"), violando as regras da mesóclise exigida para o futuro ("Entregar-te-ei").

BIZU DE PROVA:
Principais fatores que ATRAEM o pronome (PRÓCLISE obrigatória):
1) Palavras de sentido negativo: não, nunca, jamais, nada, ninguém.
2) Conjunções subordinativas: que, quando, se, embora, porque.
3) Pronomes relativos, indefinidos e demonstrativos: que, quem, tudo, isso.
4) Advérbios sem pausa por vírgula: ontem me disseram, sempre se ouviu.'),
(220, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Na oração "Jamais se esquecerá daquele dia", a palavra "Jamais" é um advérbio de valor semântico negativo. De acordo com as regras de colocação pronominal da norma-padrão, palavras de sentido negativo funcionam como elemento atrativo obrigatório, puxando o pronome oblíquo átono para antes do verbo (próclise).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O verbo "esquecerá" está flexionado no futuro do presente do indicativo, e não no infinitivo.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A regra é exatamente a oposta: após advérbio de sentido negativo é OBRIGATÓRIA a PRÓCLISE, sendo proibida a ênclise.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O verbo não inicia a oração; quem inicia a oração é o advérbio "Jamais".

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Mesóclise é o pronome colocado no meio do verbo (ex.: "esquecer-se-á"). Como o pronome está antes do verbo, trata-se de próclise.

BIZU DE PROVA:
Memorize a tríade de colocação pronominal:
- PRÓCLISE: pronome ANTES do verbo ("Jamais se esquecerá").
- MESÓCLISE: pronome no MEIO do verbo ("Esquecer-se-á").
- ÊNCLISE: pronome DEPOIS do verbo ("Esqueceu-se").'),
(221, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Na frase "Quando me chamarem, irei", a conjunção subordinativa temporal "Quando" exerce força atrativa obrigatória sobre o pronome oblíquo átono "me", exigindo a colocação em PRÓCLISE ("Quando me chamarem").

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Apresenta ênclise ("chamarem-me") após a conjunção subordinativa "Quando", o que é expressamente proibido pela norma-padrão.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Inicia a oração com pronome oblíquo átono ("Me chamaram"), o que contraria a regra clássica de colocação pronominal.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A palavra negativa "Não" exige próclise ("Não me disseram nada"), sendo incorreta a ênclise "Não disseram-me".

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O advérbio negativo "Jamais" exige próclise ("Jamais me esquecerei"), sendo incorreta a ênclise "esquecerei-me".

BIZU DE PROVA:
Havendo palavra atrativa (conjunção subordinativa, advérbio, palavra negativa), a PRÓCLISE é mandatória e anula qualquer outra regra (inclusive a preferência de mesóclise com verbos no futuro).'),
(222, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A palavra "anexo" tem natureza adjetiva e, portanto, deve concordar em gênero (feminino/masculino) e número (singular/plural) com o substantivo a que se refere. Como o substantivo é "as certidões" (feminino plural), o adjetivo flexiona para "anexas" e o verbo para "seguem": "Seguem anexas as certidões".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O verbo "Segue" está no singular, discordando do sujeito plural "as certidões".

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A palavra "anexo" ficou invariável no masculino singular, quando deveria concordar como adjetivo com "as certidões" (anexas).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Apresenta erro duplo: o verbo "Segue" e o adjetivo "anexo" ficaram no singular com sujeito no plural.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Apresenta o verbo "Seguem" e o adjetivo "anexos" no plural enquanto o substantivo "a certidão" está no singular.

BIZU DE PROVA:
Diferença essencial:
- "ANEXO" (adjetivo) = concorda com o substantivo: "Seguem anexas as cartas", "Segue anexo o relatório".
- "EM ANEXO" (locução adverbial) = fica sempre INVARIÁVEL: "Seguem em anexo as cartas", "Segue em anexo o relatório".'),
(223, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Nas estruturas formadas pelo verbo "ser" + predicativo ("é bom", "é necessário", "é proibido", "é permitido"), quando o substantivo sujeito vem determinado por artigo definido ou pronome ("a cautela"), a concordância nominal do predicativo é OBRIGATÓRIA: "É necessária a cautela".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Como o substantivo vem acompanhado do artigo feminino "a", o predicativo não pode ficar no masculino neutro "necessário" (deve ser "necessária").

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Apresenta discordância entre o verbo no plural "São", o adjetivo no singular "necessário" e o sujeito "as cautelas".

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Flexiona o predicativo no plural "necessárias" com sujeito no singular "a cautela".

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Apresenta o adjetivo no singular feminino com substantivo sem artigo ("cautelas"), onde a regra geral sem determinante exige o masculino neutro ("É necessário cautela").

BIZU DE PROVA:
A regra do "É NECESSÁRIO / É PROIBIDO":
- Sem artigo/determinante: fica no masculino singular invariável -> "É proibido entrada", "É necessário cautela".
- Com artigo/determinante: concorda obrigatoriamente -> "É proibida A entrada", "É necessária A cautela".'),
(224, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A palavra "meio", quando empregada com valor equivalente a "um pouco", "mais ou menos" ou "parcialmente", classifica-se como ADVÉRBIO de intensidade modificando o adjetivo "cansadas". Como todo advérbio, é uma palavra estritamente INVARIÁVEL, não sofrendo flexão de gênero ou número: "As policiais estavam meio cansadas".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Flexiona indevidamente o advérbio para o feminino plural ("meias cansadas"). "Meia" só varia quando for numeral fracionário ("comeu meia maçã") ou substantivo ("calçou as meias").

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Apresenta o substantivo no singular "policial" acompanhado de artigo no plural "As".

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Apresenta o verbo no singular "estava" discordando do sujeito plural "As policiais".

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Flexiona o advérbio no masculino plural ("meios cansadas"), violando a regra de invariabilidade.

BIZU DE PROVA:
Teste do "UM POUCO": se você puder substituir a palavra por "um pouco", ela é advérbio e NUNCA varia: "Elas estavam MEIO (um pouco) cansadas", "A porta está MEIO (um pouco) aberta".'),
(225, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
No período composto "Estudou bastante, mas não conseguiu a aprovação", as duas orações são independentes sintaticamente (coordenadas). A segunda oração é introduzida pela conjunção adversativa "mas", que estabelece uma relação de oposição/contraste em relação à primeira, classificando-se como ORAÇÃO COORDENADA SINDÉTICA ADVERSATIVA.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A oração não exprime ideia de adição ou soma de ações (aditiva), mas sim de quebra de expectativa e contrariedade.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A oração é sindética porque possui conectivo/síndeto expresso ("mas"); assindética é a oração que não possui conjunção.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não se trata de oração subordinada nem expressa a causa do estudo.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Embora próxima semanticamente, a conjunção "mas" é tipicamente coordenativa adversativa, e não subordinativa concessiva (concessiva seria: "Embora tenha estudado, não conseguiu...").

BIZU DE PROVA:
Conjunções COORDENADAS ADVERSATIVAS mais cobradas: mas, porém, contudo, todavia, entretanto, no entanto, não obstante. Sempre vêm precedidas de vírgula!'),
(226, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
No período "Quando o edital sair, intensificaremos os estudos", a oração introduzida pela conjunção subordinativa "Quando" expressa o momento ou a circunstância temporal em que ocorrerá a ação da oração principal ("intensificaremos os estudos"), classificando-se sintaticamente como ORAÇÃO SUBORDINADA ADVERBIAL TEMPORAL.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A oração não expressa o motivo ou a causa da intensificação dos estudos (causal seria: "Como o edital saiu, intensificamos...").

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A oração não expressa a finalidade ou objetivo da ação (final seria: "Para que o edital seja superado...").

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A oração não expressa a consequência de uma intensidade anterior.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A oração não estabelece termo de comparação entre dois elementos.

BIZU DE PROVA:
As 9 circunstâncias das ORAÇÕES SUBORDINADAS ADVERBIAIS (C-C-C-C-C-C-F-P-T): Causal, Comparativa, Concessiva, Condicional, Conformativa, Consecutiva, Final, Proporcional e Temporal.'),
(227, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Na frase "Embora estivesse cansado, continuou estudando", a conjunção "Embora" introduz uma Oração Subordinada Adverbial CONCESSIVA. A concessão exprime uma ideia de ressalva, obstáculo ou quebra de expectativa que, no entanto, não impede a realização do fato expresso na oração principal.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O cansaço não foi a causa de ele continuar estudando, mas sim uma circunstância adversa superada pelo sujeito.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A oração não expressa uma dedução ou conclusão lógica (conclusiva seria: "Estava cansado, logo descansou").

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A oração não justifica ou explica a oração principal.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A conjunção "embora" não adiciona informações cumulativas.

BIZU DE PROVA:
O que é CONCESSÃO? É o "apesar de". Uma oração concessiva admite um fato contrário que NÃO tem força suficiente para anular o resultado principal: "Embora chovesse (= apesar da chuva), fomos à praia".'),
(228, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Na frase "O policial fechou a porta", a palavra "porta" foi empregada em seu sentido literal, real, objetivo e dicionarizado (a estrutura física móvel que fecha uma entrada ou abertura). O uso literal das palavras caracteriza a linguagem DENOTATIVA (ou denotação).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Sentido conotativo é o sentido figurado, metafórico ou simbólico, o que não ocorre na ação física descrita.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não há metáfora; o objeto "porta" refere-se exatamente à estrutura física material.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não há exagero intencional (hipérbole) no fechamento de uma porta.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não há duplicidade de sentido com intuito sarcástico ou irônico na declaração.

BIZU DE PROVA:
Mnemônico infalível:
- D de DENOTAÇÃO = sentido do DICIONÁRIO (real, literal, objetivo).
- C de CONOTAÇÃO = sentido do CORAÇÃO / CRIATIVO (figurado, poético, metafórico).'),
(229, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Na frase "A aprovação abriu portas para sua carreira", a expressão "abriu portas" não se refere ao ato físico e mecânico de abrir uma estrutura de madeira, mas sim à criação de novas oportunidades, caminhos e possibilidades profissionais. Trata-se, portanto, de um emprego em sentido figurado e metafórico, caracterizando a linguagem CONOTATIVA.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O sentido denotativo exigiria a abertura literal de uma porta física, o que não é o caso de uma carreira profissional.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não se trata de um termo técnico ou jargão formal do Direito.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O uso não é literal, mas expressamente translato e simbólico.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não há aplicação em conceito formal das ciências exatas ou naturais.

BIZU DE PROVA:
Toda vez que uma palavra ou expressão for usada fora de seu significado primário para criar imagens mentais ou analogias no leitor, estamos diante do sentido CONOTATIVO (figurado).'),
(230, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Na oração "Ele carregava o peso da responsabilidade", a palavra "peso" foi empregada em sentido conotativo (figurado/metafórico). "Responsabilidade" é um dever moral ou funcional abstrato que não possui massa física aferível em balança; o termo "peso" expressa a sobrecarga emocional e o rigor dos deveres assumidos.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"A mochila pesa cinco quilos" emprega o verbo pesar em sentido estritamente literal/denotativo de mensuração de massa física.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"A mesa é de madeira" descreve objetivamente a matéria-prima do móvel (sentido denotativo).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"A prova começou às oito" indica horário objetivo e cronológico (sentido denotativo).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
"O livro tem cem páginas" apresenta dado quantitativo real (sentido denotativo).

BIZU DE PROVA:
Para identificar uso conotativo em provas, procure termos abstratos associados a propriedades materiais ("doce ilusão", "coração de pedra", "peso da culpa").'),
(231, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A palavra "infeliz" é formada pelo processo de DERIVAÇÃO PREFIXAL (ou prefixação), que consiste no acréscimo do prefixo de valor negativo/oposto "in-" antes da palavra primitiva e radical "feliz" (in + feliz = infeliz).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Derivação sufixal ocorre quando o afixo é acrescentado após o radical (ex.: felizmente, felicidade).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Composição por justaposição é a união de dois ou mais radicais sem perda fonética (ex.: passatempo, girassol).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Composição por aglutinação envolve união de radicais com alteração ou supressão de fonemas (ex.: planalto = plano + alto).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Derivação regressiva forma substantivos a partir de verbos pela redução da terminação verbal (ex.: o debate, do verbo debater; o corte, do verbo cortar).

BIZU DE PROVA:
Processos de Derivação:
- PREFIXAL: afixo antes da raiz (IN-feliz, DES-leal, RE-fazer).
- SUFIXAL: afixo depois da raiz (feliz-MENTE, leal-DADE, papel-ARIA).
- PARASSINTÉTICA: prefixo e sufixo adicionados simultaneamente, sem existir a palavra apenas com um deles (a-noit-ecer, en-trist-ecer).'),
(232, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A palavra "felizmente" é formada pelo processo de DERIVAÇÃO SUFIXAL (ou sufixação), no qual o sufixo formador de advérbios de modo "-mente" é anexado à forma feminina/base do adjetivo primitivo "feliz" (feliz + mente = felizmente).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Na derivação prefixal o afixo vem antes do radical (ex.: infeliz).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não se trata de composição por aglutinação, pois não há junção de duas palavras independentes com perda fonética.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
"-mente" é um sufixo gramatical derivacional, não um radical autônomo em processo de justaposição.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Abreviação vocabular é a redução da palavra até o limite de sua compreensão (ex.: foto de fotografia, moto de motocicleta).

BIZU DE PROVA:
Todo advérbio terminado em "-MENTE" é formado por DERIVAÇÃO SUFIXAL a partir de um adjetivo (rapidamente, calmamente, felizmente).'),
(233, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A palavra "passatempo" é formada pelo processo de COMPOSIÇÃO POR JUSTAPOSIÇÃO. Ocorre composição quando dois ou mais radicais ou palavras autônomas se unem para formar uma nova unidade de sentido. Na justaposição ("passa" + "tempo"), ambos os elementos conservam integralmente sua pronúncia e grafia, sem nenhuma perda ou alteração fonética.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Passa" e "tempo" são radicais independentes, não se tratando de prefixo associado a radical.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não se trata de acréscimo de sufixo, mas de junção de dois vocábulos da língua.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Parassíntese é a criação de palavras pela inclusão simultânea de prefixo e sufixo (ex.: envernizar, apodrecer).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Derivação regressiva cria substantivos deverbais (ex.: a compra, o alcance).

BIZU DE PROVA:
Composição: JUSTAPOSIÇÃO vs. AGLUTINAÇÃO:
- JUSTAPOSIÇÃO = sem perda de letras/sons ("passatempo", "guarda-chuva", "girassol", "segunda-feira").
- AGLUTINAÇÃO = com perda ou fusão de letras/sons ("planalto" = plano+alto; "boquiaberto" = boca+aberta; "embora" = em+boa+hora).'),
(234, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A palavra denotativa "até" atua no enunciado como um operador argumentativo de inclusão e ordenação em escala. Ao enunciar "Até João acertou a questão", coloca-se João no ápice da escala dos menos prováveis de acertar, o que gera o pressuposto implícito de que o acerto dele era um fato surpreendente ou pouco esperado pelos demais.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A partícula "até" é inclusiva e indica que outros também acertaram, não que ele foi o único (exclusão seria marcada por "Apenas João acertou").

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A frase afirma categoricamente que João fez a prova e acertou a questão.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não há qualquer menção ou inferência sobre anulação da questão.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O uso de "até" pressupõe que as outras pessoas também acertaram a questão antes de João ser incluído na contagem.

BIZU DE PROVA:
Palavras que geram IMPLÍCITOS e PRESSUPOSTOS em provas:
- Operadores de escala: "até", "inclusive", "mesmo" (pressupõem inclusão inesperada).
- Operadores de exclusão: "apenas", "somente", "só" (pressupõem que os demais não realizaram o ato).'),
(235, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Verbos que indicam mudança de estado ou interrupção de um processo (como "parar de", "deixar de", "cessar") funcionam linguisticamente como ativadores de pressuposição. Ao afirmar que "Pedro parou de fumar", a estrutura pressupõe necessariamente como fato prévio e incontroverso que Pedro fumava no período anterior.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Contradiz diretamente o significado do verbo de cessação; só pode parar quem praticava o hábito.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Parou" indica o término de uma ação, e não o seu início (que seria "começou a fumar").

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A frase informa a interrupção do consumo de tabaco, não o aumento da frequência.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Trata-se de uma extrapolação sem qualquer base no verbo utilizado.

BIZU DE PROVA:
Verbos de mudança de estado (começar, parar, deixar de, continuar, passar a) geram PRESSUPOSTOS linguísticos incontestáveis sobre a situação imediatamente anterior ao enunciado.'),
(236, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A locução verbal aspectual "voltou a estudar" carrega o valor semântico de reiteração ou retorno a uma condição anterior. A presença dessa estrutura gramatical ativa o pressuposto de que Maria já possuía o hábito de estudar no passado, havia interrompido essa atividade e agora a retomou.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Se ela nunca tivesse estudado, o verbo correto para indicar o início inédito da ação seria "começou a estudar" ou "passou a estudar".

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A frase informa apenas o retorno aos estudos, não trazendo elementos para inferir aprovação em concurso ou exame.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O enunciado indica a retomada dos estudos, não o seu abandono futuro.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Constitui extrapolação absurda e sem fundamento no texto.

BIZU DE PROVA:
Diferença semântica fundamental:
- PRESSUPOSTO = informação implícita decorrente de uma marca gramatical explícita no texto ("voltou", "deixou de", "ainda").
- SUBENTENDIDO = informação sugerida pelo contexto que depende da interpretação do leitor, sem marca linguística direta.'),
(237, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Na oração "Se chover, a prova será mantida", a oração subordinada adverbial condicional ("Se chover") encontra-se anteposta (deslocada para o início do período) em relação à oração principal ("a prova será mantida"). Pela norma-padrão de pontuação, o isolamento por vírgula de orações adverbiais deslocadas para o início do período é OBRIGATÓRIO.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A vírgula foi inserida incorretamente no meio do sintagma, separando o verbo do seu sujeito/complemento e gerando corte sintático indevido ("Se chover a prova, será mantida").

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Coloca a vírgula imediatamente após a conjunção condicional "Se", isolando a conjunção de sua oração.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Insere a vírgula entre o verbo auxiliar "será" e o particípio "mantida", o que é terminantemente proibido.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Insere a vírgula entre o artigo "a" e o substantivo "prova".

BIZU DE PROVA:
Regra de ouro da VÍRGULA com orações adverbiais:
- Na ordem direta (Principal + Adverbial): a vírgula é facultativa ("A prova será mantida se chover").
- Na ordem indireta/deslocada (Adverbial + Principal): a vírgula é OBRIGATÓRIA ("Se chover, a prova será mantida").'),
(238, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Na frase "João, que estudou muito, foi aprovado", a oração adjetiva "que estudou muito" possui valor explicativo (agrega uma qualidade/informação adicional sobre o sujeito João). Pela norma gramatical, toda oração subordinada adjetiva explicativa deve vir OBRIGATORIAMENTE isolada por vírgulas (uma antes do pronome relativo e outra ao término da oração).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Coloca a vírgula após o pronome relativo "que", cortando a ligação entre o conectivo e o predicado adjetivo.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Coloca a vírgula entre o verbo "estudou" e o advérbio "muito", separando o verbo de seu adjunto adverbial integrado.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Insere a vírgula entre o verbo de ligação/auxiliar "foi" e o predicativo/particípio "aprovado".

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Abriu a oração explicativa com vírgula após "João", mas esqueceu de fechá-la após "muito", deixando o período desbalanceado.

BIZU DE PROVA:
Diferença entre Orações Subordinadas ADJETIVAS:
- COM vírgulas = EXPLICATIVA: refere-se à totalidade do termo antecedente ("O homem, que é mortal, teme a morte").
- SEM vírgulas = RESTRITIVA: limita/restringe o universo do antecedente ("Os alunos que estudaram foram aprovados" -> apenas os que estudaram).'),
(239, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A regra basilar da sintaxe de pontuação na Língua Portuguesa veda terminantemente o uso de vírgula entre os termos essenciais e integrantes da oração que estão em sequência direta. Assim, NÃO se pode separar por vírgula simples o SUJEITO do seu respectivo VERBO (predicado), nem o verbo de seus complementos diretos ou indiretos.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O vocativo é um termo sintaticamente independente e deve vir OBRIGATORIAMENTE isolado por vírgula(s) em qualquer posição que ocupe na frase ("Soldado, apresente-se!").

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O aposto explicativo deve vir OBRIGATORIAMENTE isolado por vírgulas, travessões ou parênteses ("Brasília, a capital do país, foi planejada").

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Orações adverbiais e adjuntos adverbiais deslocados para o início ou meio da frase devem vir separados por vírgula.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Elementos coordenados assindéticos em enumeração devem ser separados por vírgula ("Comprou cadernos, canetas, livros e réguas").

BIZU DE PROVA:
A proibição número 1 da vírgula em qualquer prova de concurso:
NUNCA separe por vírgula:
1) Sujeito e Verbo ("O policial, agiu com bravura" -> ERRADO).
2) Verbo e Complemento ("Ele entregou, o documento" -> ERRADO).
3) Nome e Adjunto Adnominal/Complemento Nominal.'),
(240, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Na oração subordinada condicional "Se eu estudasse mais", a forma verbal "estudasse" está conjugada na 1ª pessoa do singular do PRETÉRITO IMPERFEITO DO SUBJUNTIVO. A desinência modo-temporal característica e inconfundível desse tempo é o morfema "-sse-", que expressa uma hipótese, desejo ou condição não concretizada no tempo passado/presente.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
No pretérito perfeito do indicativo a forma seria "estudei", que expressa uma ação concluída com certeza no passado.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
No presente do indicativo a forma seria "estudo", indicando ação habitual ou atual.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
No futuro do presente a forma seria "estudarei", expressando certeza futura.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
No imperativo a forma seria "estuda" (afirmativo tu) ou "estude" (você), expressando ordem ou conselho.

BIZU DE PROVA:
Identificação instantânea de tempos do SUBJUNTIVO:
- Terminação "-SSE-" = Pretérito Imperfeito do Subjuntivo ("se eu estudasse", "se você fizesse").
- Terminação "-R-" (com conjunção quando/se) = Futuro do Subjuntivo ("quando eu estudar", "se eu fizer").
- Vogal trocada (E vira A / A vira E) = Presente do Subjuntivo ("que eu estude", "que eu faça").'),
(241, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Na oração subordinada temporal "Quando eu chegar, avisarei", a forma verbal "chegar" está conjugada no FUTURO DO SUBJUNTIVO. O futuro do subjuntivo é introduzido tipicamente por conjunções como "quando" ou "se", expressando uma ação eventual, hipotética ou condicionada que poderá vir a ocorrer no futuro em relação ao momento da fala.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Embora a forma gráfica "chegar" coincida com o infinitivo pessoal nos verbos regulares da 1ª conjugação, a presença da conjunção subordinativa temporal "quando" com valor prospectivo e sujeito explícito define a flexão funcional do futuro do subjuntivo.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
No presente do indicativo a forma é "chego".

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
No pretérito perfeito do indicativo a forma é "cheguei".

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
No imperativo a forma seria "chega" ou "chegue".

BIZU DE PROVA:
Para distinguir Infinitivo de Futuro do Subjuntivo nos verbos regulares (onde as formas coincidem):
- Se vier introduzido por "QUANDO" ou "SE" com ideia de eventualidade futura, é FUTURO DO SUBJUNTIVO ("Quando eu chegar", "Se eu puder").
- Se vier após preposições como "para", "de", "por", "ao", é INFINITIVO ("Para eu chegar a tempo", "Ao chegar em casa").');

-- ----------------------------------------------------------------------------
-- Snapshot ANTES.
-- ----------------------------------------------------------------------------
-- 1) linha inteira das 50 (exceto explicacao/atualizado_em).
create temporary table _lp1_snap_questoes on commit drop as
select id, (to_jsonb(q) - 'explicacao' - 'atualizado_em') as dados_imutaveis
from public.questoes q
where q.id in (6,16,17,18,34,65,66,67,68,69,70,71,72,73,114,115,116,117,118,119,120,121,122,123,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241);

-- 2) alternativas completas das 50.
create temporary table _lp1_snap_alternativas on commit drop as
select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
from public.alternativas a
where a.questao_id in (6,16,17,18,34,65,66,67,68,69,70,71,72,73,114,115,116,117,118,119,120,121,122,123,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241)
group by questao_id;

-- 3) hash de explicacao de TODAS as questoes do banco.
create temporary table _lp1_snap_hash_todas on commit drop as
select id, md5(coalesce(explicacao, '')) as hash_explicacao
from public.questoes;

-- 4) contagens globais.
create temporary table _lp1_snap_global on commit drop as
select
  (select count(*) from public.questoes)            as total_questoes_antes,
  (select count(*) from public.questoes where ativa) as total_ativas_antes;

create temporary table _lp1_asserts (ordem serial primary key, descricao text, ok boolean) on commit drop;

-- ----------------------------------------------------------------------------
-- Precondicoes.
-- ----------------------------------------------------------------------------
do $$
declare
  v_qtd int;
begin
  if (select count(*) from _lp1_novas_explicacoes) <> 50 then
    raise exception 'PRECONDICAO FALHOU: staging nao tem exatamente 50 explicacoes';
  end if;

  select count(*) into v_qtd from public.questoes where id in (select id from _lp1_novas_explicacoes);
  if v_qtd <> 50 then
    raise exception 'PRECONDICAO FALHOU: esperado 50 questoes no banco, encontrado %', v_qtd;
  end if;

  if exists (
    select 1 from public.questoes q
    join _lp1_novas_explicacoes s on s.id = q.id
    where q.materia_id is distinct from 6 or q.ativa is distinct from true
  ) then
    raise exception 'PRECONDICAO FALHOU: alguma das 50 nao esta mais no estado auditado (materia_id=6, ativa=true)';
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ESCRITA: atualiza explicacao + atualizado_em das 50.
-- ----------------------------------------------------------------------------
create temporary table _lp1_ids_afetados (id bigint primary key) on commit drop;

do $$
declare
  v_linhas int;
begin
  with atualizado as (
    update public.questoes q
    set explicacao = s.explicacao, atualizado_em = now()
    from _lp1_novas_explicacoes s
    where q.id = s.id
    returning q.id
  )
  insert into _lp1_ids_afetados (id) select id from atualizado;

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
  insert into _lp1_asserts (descricao, ok)
  select 'exatamente 50 questoes afetadas pelo UPDATE', (select count(*) from _lp1_ids_afetados) = 50;

  insert into _lp1_asserts (descricao, ok)
  select 'os ids afetados sao exatamente os 50 esperados',
    (select array_agg(id order by id) from _lp1_ids_afetados) = ARRAY[6,16,17,18,34,65,66,67,68,69,70,71,72,73,114,115,116,117,118,119,120,121,122,123,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241]::bigint[];

  insert into _lp1_asserts (descricao, ok)
  select 'enunciado/alternativas-relacao/gabarito/materia/assunto/ativa/banca/concurso/ano/fonte preservados nas 50 (comparacao jsonb byte-a-byte, exceto explicacao/atualizado_em)',
    not exists (
      select 1 from public.questoes q
      join _lp1_snap_questoes s on s.id = q.id
      where (to_jsonb(q) - 'explicacao' - 'atualizado_em') <> s.dados_imutaveis
    );

  insert into _lp1_asserts (descricao, ok)
  select 'alternativas das 50 continuam byte-identicas (texto/correta/ordem)',
    not exists (
      select 1
      from _lp1_snap_alternativas s
      join (
        select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
        from public.alternativas a
        where a.questao_id in (select id from _lp1_novas_explicacoes)
        group by questao_id
      ) d on d.questao_id = s.questao_id
      where d.alternativas <> s.alternativas
    );

  select count(*) into v_sem_correta
  from _lp1_novas_explicacoes s
  where (select count(*) from public.alternativas a where a.questao_id = s.id and a.correta) <> 1;
  insert into _lp1_asserts (descricao, ok) values ('as 50 continuam com exatamente 1 alternativa correta cada', v_sem_correta = 0);

  -- Classificacao EXPLICACAO_COMPLETA das 50 apos o UPDATE
  with alt_stats as (
    select q.id as questao_id, count(a.id) as n_alt, count(a.id) filter (where a.correta) as n_corretas,
      bool_and(lower(btrim(a.texto)) in ('certo', 'errado')) and count(a.id) = 2 as eh_certo_errado
    from public.questoes q
    left join public.alternativas a on a.questao_id = q.id
    where q.id in (select id from _lp1_novas_explicacoes)
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
    where q.id in (select id from _lp1_novas_explicacoes)
  )
  select count(*) filter (where status = 'EXPLICACAO_COMPLETA') into v_completas from classificado;
  insert into _lp1_asserts (descricao, ok) values ('as 50 passam no classificador canonico como EXPLICACAO_COMPLETA', v_completas = 50);

  insert into _lp1_asserts (descricao, ok)
  select 'nenhuma outra questao do banco teve explicacao alterada',
    not exists (
      select 1 from public.questoes q
      join _lp1_snap_hash_todas s on s.id = q.id
      where md5(coalesce(q.explicacao, '')) <> s.hash_explicacao
        and q.id <> ALL(ARRAY[6,16,17,18,34,65,66,67,68,69,70,71,72,73,114,115,116,117,118,119,120,121,122,123,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241]::bigint[])
    );

  select count(*) into v_total_depois from public.questoes;
  insert into _lp1_asserts (descricao, ok) values ('total de questoes no banco inalterado (nenhuma criada/excluida)', v_total_depois = (select total_questoes_antes from _lp1_snap_global));

  select count(*) into v_ativas_depois from public.questoes where ativa = true;
  insert into _lp1_asserts (descricao, ok) values ('total de questoes ATIVAS do Papiro inalterado', v_ativas_depois = (select total_ativas_antes from _lp1_snap_global));
end $$;

-- Relatorio de asserts
do $$
declare
  r record;
  v_total integer;
  v_ok integer;
begin
  for r in select descricao, ok from _lp1_asserts order by ordem loop
    if r.ok then
      raise notice 'OK: %', r.descricao;
    else
      raise exception 'FALHOU: %', r.descricao;
    end if;
  end loop;

  select count(*), count(*) filter (where ok) into v_total, v_ok from _lp1_asserts;
  raise notice '=== RESUMO: % / % asserts passaram ===', v_ok, v_total;
  if v_ok <> v_total then
    raise exception 'Harness falhou: nem todos os asserts passaram.';
  end if;
end $$;

-- Nada commitado: tudo desfeito abaixo.
COMMIT;
