-- TESTE DE ROLLBACK REAL da IMPORTACAO LOTE05_PORTUGUES_AUTORAL. Executa, dentro de UMA
-- transacao controlada que termina em ROLLBACK externo, a sequencia
-- completa: OLD (baseline) -> APPLY (mesma logica do apply real) ->
-- TARGET (verifica) -> REVERSAO REAL (mesma logica do reverter real) ->
-- OLD_FINAL (verifica). Nenhuma linha e alterada permanentemente — tudo
-- e desfeito por ROLLBACK.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _relatorio (fase text, item text, ok boolean, detalhe text) on commit drop;

create temporary table _snapshot_antes on commit drop as
select
  (select count(*) from public.questoes) as total_questoes,
  (select count(*) from public.alternativas) as total_alternativas,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos,
  (select count(*) from public.curso_questoes) as total_curso_questoes;

create temporary table _lote_questoes (
  ordem int primary key, curso_conteudo_id bigint, dificuldade text, fonte text, enunciado text
) on commit drop;

insert into _lote_questoes (ordem, curso_conteudo_id, dificuldade, fonte, enunciado) values
(1, 32, $D1$media$D1$, $FONTE1$PAPIRO — LOTE05_PORTUGUES_AUTORAL — VOZ-01$FONTE1$, $ENUN1$Em um relatório de ocorrência, lê-se: “Durante o atendimento, o policial sofreu um ferimento no braço”. Quanto à voz verbal, assinale a alternativa correta.$ENUN1$),
(2, 32, $D2$media$D2$, $FONTE2$PAPIRO — LOTE05_PORTUGUES_AUTORAL — VOZ-02$FONTE2$, $ENUN2$Assinale a alternativa que apresenta a transposição correta para a voz passiva analítica da oração: “A corregedoria analisará os documentos da apuração”.$ENUN2$),
(3, 32, $D3$media$D3$, $FONTE3$PAPIRO — LOTE05_PORTUGUES_AUTORAL — VOZ-03$FONTE3$, $ENUN3$Em comunicados internos de uma unidade policial, constam as seguintes construções:

I. Divulgaram-se os locais de apresentação dos candidatos.
II. Necessita-se de servidores para o atendimento administrativo.

Considerando a estrutura sintática e o sentido das orações, assinale a alternativa correta.$ENUN3$),
(4, 17, $D4$media$D4$, $FONTE4$PAPIRO — LOTE05_PORTUGUES_AUTORAL — REG-01$FONTE4$, $ENUN4$Assinale a alternativa que completa corretamente a frase abaixo, de acordo com a regência verbal na oração relativa.

"Os pareceres ______ a comissão se baseou para elaborar o relatório final serão encaminhados ao comando."$ENUN4$),
(5, 17, $D5$media$D5$, $FONTE5$PAPIRO — LOTE05_PORTUGUES_AUTORAL — REG-03$FONTE5$, $ENUN5$Assinale a alternativa redigida de acordo com a regência verbal prescrita pela norma-padrão.$ENUN5$),
(6, 27, $D6$media$D6$, $FONTE6$PAPIRO — LOTE05_PORTUGUES_AUTORAL — TRANS-01$FONTE6$, $ENUN6$Durante o plantão, a equipe registrou cuidadosamente as ocorrências no sistema. O termo que exerce a função de objeto direto do verbo “registrou” é:$ENUN6$),
(7, 27, $D7$media$D7$, $FONTE7$PAPIRO — LOTE05_PORTUGUES_AUTORAL — TRANS-02$FONTE7$, $ENUN7$A direção homenageou a todos os policiais que se destacaram na operação. Assinale a alternativa que classifica corretamente o termo destacado.$ENUN7$),
(8, 27, $D8$media$D8$, $FONTE8$PAPIRO — LOTE05_PORTUGUES_AUTORAL — TRANS-03$FONTE8$, $ENUN8$No comunicado interno, lê-se: “A Direção comunicou aos candidatos o novo horário da avaliação”. Assinale a alternativa correta acerca da expressão destacada e de sua substituição pronominal.$ENUN8$),
(9, 27, $D9$media$D9$, $FONTE9$PAPIRO — LOTE05_PORTUGUES_AUTORAL — TRANS-04$FONTE9$, $ENUN9$Considere a oração de um procedimento administrativo: “Os relatórios de ocorrência foram conferidos pela comissão designada”. Assinale a alternativa que identifica corretamente o agente da passiva e apresenta a conversão adequada da oração para a voz ativa.$ENUN9$),
(10, 27, $D10$media$D10$, $FONTE10$PAPIRO — LOTE05_PORTUGUES_AUTORAL — TRANS-06$FONTE10$, $ENUN10$Analise as ocorrências destacadas nos períodos a seguir.

I. “O comando necessita de reforço para o patrulhamento.”
II. “A necessidade de reforço para o patrulhamento foi comunicada aos setores responsáveis.”

Quanto à função sintática das expressões destacadas, assinale a alternativa correta.$ENUN10$),
(11, 14, $D11$media$D11$, $FONTE11$PAPIRO — LOTE05_PORTUGUES_AUTORAL — CONECT-01$FONTE11$, $ENUN11$Em uma comunicação interna, lê-se: “O levantamento preliminar indicou redução das ocorrências; contudo, a análise definitiva dependerá da conferência dos registros.”

Assinale a alternativa correta acerca do emprego de “contudo” no período.$ENUN11$),
(12, 14, $D12$media$D12$, $FONTE12$PAPIRO — LOTE05_PORTUGUES_AUTORAL — CONECT-02$FONTE12$, $ENUN12$Leia o trecho de um relatório institucional:

“Conquanto o efetivo estivesse reduzido, o atendimento às ocorrências prioritárias foi mantido. Quando a operação foi encerrada, os dados foram encaminhados ao comando.”

Assinale a alternativa que classifica corretamente as relações semânticas introduzidas pelos conectores destacados.$ENUN12$),
(13, 14, $D13$media$D13$, $FONTE13$PAPIRO — LOTE05_PORTUGUES_AUTORAL — CONECT-03$FONTE13$, $ENUN13$Em um comunicado interno, lê-se: “Conquanto a equipe tenha recebido orientações prévias, o treinamento prático será mantido”.

A conjunção “conquanto” estabelece, entre as ideias do período, uma relação de$ENUN13$),
(14, 14, $D14$media$D14$, $FONTE14$PAPIRO — LOTE05_PORTUGUES_AUTORAL — CONECT-04$FONTE14$, $ENUN14$No relatório de serviço, registrou-se que “a comunicação entre as equipes foi tão eficiente que reduziu o tempo de resposta às ocorrências”.

No período, a estrutura “tão...que” expressa uma relação de$ENUN14$),
(15, 13, $D15$media$D15$, $FONTE15$PAPIRO — LOTE05_PORTUGUES_AUTORAL — COES-01$FONTE15$, $ENUN15$Leia a frase a seguir.

“A unidade operacional, cujos registros de manutenção foram revisados pela corregedoria, encaminhou o relatório ao comando.”

Quanto ao emprego do pronome relativo “cujos”, assinale a alternativa correta.$ENUN15$),
(16, 13, $D16$media$D16$, $FONTE16$PAPIRO — LOTE05_PORTUGUES_AUTORAL — COES-02$FONTE16$, $ENUN16$Leia o trecho a seguir.

“Durante a preparação para a operação, o comando revisou os mapas de risco, atualizou a escala de serviço e distribuiu lanternas às equipes. Essas providências buscaram ampliar a segurança do patrulhamento noturno.”

No contexto, a expressão “Essas providências” exerce a função de$ENUN16$),
(17, 13, $D17$media$D17$, $FONTE17$PAPIRO — LOTE05_PORTUGUES_AUTORAL — COES-03$FONTE17$, $ENUN17$Leia a frase a seguir.

"O capitão encaminhou à analista o parecer cuja conclusão ele contestou antes da assinatura."

Considerando os mecanismos de coesão referencial, o pronome pessoal "ele" retoma$ENUN17$);

create temporary table _lote_explicacoes (ordem int primary key, explicacao text) on commit drop;

insert into _lote_explicacoes (ordem, explicacao) values
(1, $EXPL1$A oração está na voz ativa: o sujeito gramatical “o policial” ocupa a posição própria da estrutura ativa, e o verbo “sofreu” está empregado sem construção passiva. O fato de o policial ser afetado pelo ferimento não transforma a oração em passiva. A voz ativa não exige que o sujeito seja agente voluntário de uma ação; por isso, A é correta. Em B, faltam a estrutura canônica de passiva analítica, com “ser + particípio”, e um agente da passiva. C é incorreta porque não há pronome “se” nem sujeito paciente em construção pronominal. D é incorreta, pois não há elemento que indique que o sujeito praticou a ação sobre si mesmo. E é falsa porque a classificação da voz não depende de o verbo indicar ou não ação voluntária.

FUNDAMENTO: A voz ativa caracteriza-se pela organização sintática em que o sujeito ocupa a posição típica da construção ativa. Em contextos prototípicos, ele pode corresponder ao agente, mas isso não é requisito absoluto: verbos que exprimem experiência, sofrimento ou estado também podem ocorrer em construções ativas.$EXPL1$),
(2, $EXPL2$Na oração ativa, “a corregedoria” é o sujeito, “analisará” é o verbo transitivo direto no futuro do presente do indicativo, e “os documentos da apuração” é o objeto direto. Na passiva analítica, o objeto direto passa a sujeito paciente; emprega-se o auxiliar “ser” no futuro do presente (“serão”), seguido do particípio “analisados”, que concorda com “documentos”, e o sujeito da ativa é introduzido como agente da passiva: “pela corregedoria”. Portanto, A é correta. B altera o tempo verbal para o pretérito perfeito. C mantém uma estrutura ativa e atribui indevidamente a ação aos documentos. D inverte de modo incorreto os papéis sintáticos. E usa “estar + particípio”, construção que pode exprimir estado ou resultado, não a passiva analítica exigida na transposição.

FUNDAMENTO: Na transposição de uma oração ativa passivizável para a passiva analítica, o objeto direto torna-se sujeito paciente; emprega-se o verbo auxiliar “ser” com flexão compatível com o tempo e o modo da forma verbal original; o verbo principal vai ao particípio; e o sujeito da ativa pode ser expresso como agente da passiva, introduzido geralmente por “por”.$EXPL2$),
(3, $EXPL3$Em I, “divulgar” é empregado como verbo transitivo direto, e “os locais de apresentação dos candidatos” funciona como sujeito paciente. A concordância no plural em “divulgaram-se” confirma essa análise, que admite a paráfrase “Os locais de apresentação dos candidatos foram divulgados”. Portanto, o se é partícula apassivadora.

Em II, “necessitar” rege a preposição “de”, em “necessita-se de servidores”. O segmento “de servidores” não pode ser promovido a sujeito paciente em uma passiva analítica equivalente. Assim, o se indetermina o sujeito, e o verbo permanece na 3.ª pessoa do singular. As alternativas A e E invertem ou atribuem funções sintáticas indevidas aos termos; C e D ignoram as diferenças estruturais entre as duas orações.

FUNDAMENTO: Na passiva sintética, o se atua como partícula apassivadora, há sujeito paciente e o verbo concorda com esse sujeito, sendo possível uma paráfrase por passiva analítica. Nas construções com índice de indeterminação do sujeito, não há sujeito paciente, e o verbo fica na 3.ª pessoa do singular.$EXPL3$),
(4, $EXPL4$A forma correta é “em que”. Deve-se reconstruir a oração relativa: “A comissão se baseou nos pareceres para elaborar o relatório final”. O verbo pronominal “basear-se” rege a preposição “em”; portanto, o relativo deve ser precedido dessa preposição: “os pareceres em que a comissão se baseou”.

As demais alternativas empregam preposições não exigidas pelo verbo nesse contexto: “de que”, “a que”, “com que” e “por que” não correspondem à regência de “basear-se”. A escolha não decorre de o antecedente indicar lugar, mas da preposição requerida pelo verbo da oração subordinada.

FUNDAMENTO: O pronome relativo deve ser antecedido pela preposição exigida pelo termo regente na oração subordinada. O verbo pronominal “basear-se” rege a preposição “em”: basear-se em algo.$EXPL4$),
(5, $EXPL5$No sentido de escolher uma coisa em detrimento de outra, o verbo preferir rege a construção “preferir X a Y”, sem os reforços comparativos “mais” e “do que”. Assim, em “prefere o planejamento prévio à adoção”, a preposição a introduz o segundo termo da preferência. O acento grave em “à” decorre da fusão da preposição a com o artigo feminino a que acompanha “adoção”. As alternativas B, C, D e E empregam indevidamente “do que” e/ou “mais”, estruturas redundantes com o verbo preferir nesse padrão formal.

FUNDAMENTO: No padrão formal tradicional, preferir é empregado na estrutura “preferir X a Y”, sem intensificadores ou conectivos comparativos como “mais” e “do que”.$EXPL5$),
(6, $EXPL6$O verbo “registrou” é transitivo direto, pois quem registra, registra algo. Assim, “as ocorrências” completa diretamente o sentido do verbo, sem preposição, e exerce a função de objeto direto. “A equipe” é o sujeito da oração; “durante o plantão” e “no sistema” são adjuntos adverbiais; e “cuidadosamente” é advérbio, indicando o modo como se realizou a ação.

FUNDAMENTO: O objeto direto é o termo que completa o sentido de verbo transitivo direto, ligando-se a ele sem preposição obrigatória.$EXPL6$),
(7, $EXPL7$O verbo “homenagear” é transitivo direto: homenageia-se alguém. Na oração, “a todos os policiais que se destacaram na operação” completa esse verbo e equivale a “todos os policiais...”; portanto, é objeto direto preposicionado. A presença da preposição “a” não transforma automaticamente o termo em objeto indireto. Nesse caso, a preposição ocorre por uma construção enfática associada a “todos”. A alternativa A erra ao tomar a preposição como critério único; C é incorreta porque não há voz passiva analítica; D confunde complemento de nome com complemento verbal; e E erra porque o sujeito é “A direção”.

FUNDAMENTO: O objeto direto pode vir introduzido por preposição em determinados contextos, mantendo sua função de complemento de verbo transitivo direto.$EXPL7$),
(8, $EXPL8$O verbo “comunicar”, na construção apresentada, é transitivo direto e indireto: “o novo horário da avaliação” é objeto direto, e “aos candidatos” é objeto indireto. Por isso, a substituição adequada é “comunicou-lhes o novo horário”. Como regra prática, os pronomes o/a/os/as costumam retomar objetos diretos, enquanto lhe/lhes costumam retomar objetos indiretos. Essa regra, porém, não é absoluta: em certos contextos normativos, lhe/lhes podem expressar valor possessivo, não devendo sua mera ocorrência definir automaticamente a função sintática. A alternativa A emprega inadequadamente “os” para o objeto indireto; C confunde complemento verbal com complemento nominal; D erra tanto a substituição quanto a classificação baseada apenas na presença de preposição; E atribui indevidamente a função de agente da passiva.

FUNDAMENTO: Em construções com verbo transitivo direto e indireto, o objeto direto é, em regra, retomado por o/a/os/as, e o objeto indireto, por lhe/lhes. A associação é uma regra prática, pois lhe/lhes pode apresentar valor possessivo em usos específicos.$EXPL8$),
(9, $EXPL9$A oração está na voz passiva analítica: apresenta o sujeito paciente “os relatórios de ocorrência”, a locução verbal “foram conferidos” (verbo ser + particípio) e o termo “pela comissão designada”, que indica quem praticou a ação e funciona como agente da passiva. Na passagem para a voz ativa, o agente da passiva torna-se sujeito (“A comissão designada”), e o sujeito paciente passa a objeto direto (“os relatórios de ocorrência”): “A comissão designada conferiu os relatórios de ocorrência”. A contração “pela” é uma pista forte para o agente da passiva nesse contexto, mas não basta isoladamente para definir uma função sintática. As alternativas A e C trocam as funções dos termos; C ainda introduz pronome reflexivo indevido. D classifica equivocadamente o agente como objeto indireto, e E ignora a função que o sintagma efetivamente exerce na estrutura passiva.

FUNDAMENTO: Na voz passiva analítica, o sujeito paciente recebe a ação verbal, enquanto o agente da passiva, frequentemente introduzido por por/pelo/pela, pratica a ação. Na conversão para a voz ativa, o agente torna-se sujeito e o sujeito paciente torna-se objeto direto.$EXPL9$),
(10, $EXPL10$Em I, a expressão “de reforço” completa o sentido do verbo “necessita”; por isso, exerce a função de objeto indireto, exigido pela regência de “necessitar”, no sentido de precisar. Em II, a mesma expressão completa o sentido do substantivo abstrato “necessidade”; portanto, é complemento nominal.

A preposição “de” não determina, por si só, a função sintática. Assim, D está errada porque, em II, o termo não completa um verbo. C inverte as classificações. B classifica equivocadamente o termo de I como objeto direto preposicionado, embora ele seja exigido pelo verbo com preposição. E erra ao tratar o complemento verbal de I como complemento nominal.

FUNDAMENTO: O objeto indireto completa o sentido de um verbo transitivo indireto. O complemento nominal completa o sentido de um nome, como substantivo abstrato, adjetivo ou advérbio, geralmente por meio de preposição.$EXPL10$),
(11, $EXPL11$“Contudo” é uma conjunção coordenativa adversativa: contrapõe a informação de que o levantamento apontou redução das ocorrências à ressalva de que a conclusão definitiva ainda exige conferência. As conjunções adversativas compartilham, em termos gerais, o valor de oposição ou contraste. Isso não significa, porém, que sejam sempre intercambiáveis de modo automático: a possibilidade de substituição concreta depende da posição do conector, da pontuação, da construção sintática, do registro e da nuance discursiva. A alternativa A erra ao indicar adição; a B, ao apontar conclusão; a D transforma uma semelhança semântica geral em regra absoluta; e a E atribui valor causal ao conector.

FUNDAMENTO: Conjunções adversativas, como mas, porém, contudo, todavia, entretanto e no entanto, estabelecem relação geral de oposição ou contraste entre segmentos coordenados. A equivalência entre elas não é absoluta, pois depende do contexto sintático, pontuacional, discursivo e de registro.$EXPL11$),
(12, $EXPL12$“Conquanto” é uma conjunção subordinativa concessiva. No trecho, a manutenção do atendimento ocorreu apesar de o efetivo estar reduzido; a redução representa, portanto, uma circunstância que poderia dificultar o fato principal, mas não o impede. Já “quando” introduz uma relação temporal, situando o encaminhamento dos dados no momento posterior ao encerramento da operação. A alternativa A inverte os valores; C atribui relações de causa e consequência inexistentes; D confunde concessão com conclusão e tempo com condição; e E ignora o valor concessivo de “conquanto”. A semelhança gráfica entre “conquanto” e “quando” não determina que tenham a mesma função semântica.

FUNDAMENTO: “Conquanto” introduz oração subordinada concessiva, exprimindo fato que não impede a realização do conteúdo principal. “Quando”, em seu emprego típico, introduz oração subordinada temporal, situando um fato no tempo.$EXPL12$),
(13, $EXPL13$“Conquanto” introduz uma ideia concessiva: embora a equipe tenha recebido orientações prévias, o treinamento prático ainda será mantido. Há, portanto, um fato que poderia levar à expectativa de dispensa do treinamento, mas que não impede sua realização. A alternativa A está errada porque não há explicação de causa; a B, porque não se apresenta uma condição; a D, porque a conjunção não indica tempo; e a E, porque o segundo segmento não constitui conclusão lógica do primeiro.

FUNDAMENTO: Conjunções subordinativas concessivas, como “conquanto”, introduzem um fato que, embora pudesse contrariar ou dificultar o que se afirma na oração principal, não impede sua ocorrência.$EXPL13$),
(14, $EXPL14$A estrutura correlativa “tão...que” introduz uma consequência relacionada à intensidade de uma característica: a comunicação foi eficiente em grau tal que reduziu o tempo de resposta. A alternativa A seria adequada à estrutura “tão...quanto”, que estabelece comparação. As alternativas C, D e E não correspondem à relação de consequência presente entre os segmentos.

FUNDAMENTO: A construção “tão...que” expressa consequência: o segundo segmento decorre da intensidade indicada por “tão” no primeiro segmento.$EXPL14$),
(15, $EXPL15$O pronome relativo “cujos” estabelece uma relação de posse: os “registros de manutenção” pertencem à “unidade operacional”. Assim, “unidade operacional” é o antecedente semanticamente possuidor, enquanto “registros” é o elemento possuído. O relativo concorda com o elemento possuído, razão pela qual está no masculino plural: “cujos registros”.

A alternativa A erra ao indicar “registros” como antecedente de “cujos”. A alternativa B aponta um referente incompatível com o sentido da frase. A alternativa D erra porque “cujo” não concorda com o possuidor antecedente, mas com o nome subsequente. A alternativa E é incorreta, pois há retomada de um termo já mencionado, caracterizando anáfora.

FUNDAMENTO: O pronome relativo “cujo” introduz relação de posse: retoma o possuidor antecedente e concorda em gênero e número com o substantivo que designa o elemento possuído.$EXPL15$),
(16, $EXPL16$A expressão “Essas providências” resume as três medidas anteriormente apresentadas: a revisão dos mapas de risco, a atualização da escala de serviço e a distribuição de lanternas. Trata-se, portanto, de uma expressão sintetizadora, mecanismo de coesão referencial que recupera e organiza informações já mencionadas.

As alternativas A e E restringem indevidamente a retomada a apenas uma das ações. A alternativa B descreve catáfora, o que não ocorre, pois as informações retomadas já aparecem no período anterior. A alternativa C é incorreta porque não há repetição literal de “mapas de risco”, mas uma síntese de ações diversas.

FUNDAMENTO: Expressões sintetizadoras retomam uma ou mais informações precedentes por meio de um termo ou sintagma de sentido abrangente, contribuindo para a continuidade temática do texto.$EXPL16$),
(17, $EXPL17$O pronome "ele" retoma "o capitão". Embora o substantivo mais próximo seja "conclusão", a identificação do referente não pode ser feita apenas pela proximidade gráfica. É necessário verificar as possibilidades no contexto: "analista", "conclusão" e "assinatura" são termos femininos; "parecer", embora masculino, não pode, semanticamente, praticar a ação de contestar. Assim, o único referente compatível com o gênero do pronome e com o sentido da oração é "o capitão". Além disso, em "cuja conclusão", o pronome relativo "cuja" retoma "parecer", indicando que a conclusão pertence ao parecer; isso não determina o referente de "ele".

FUNDAMENTO: A determinação do antecedente de um pronome exige a análise conjunta de traços gramaticais, sentido e estrutura sintática do contexto, não se limitando ao substantivo mais próximo.$EXPL17$);

create temporary table _lote_alternativas (ordem int, letra_ordem int, texto text, correta boolean) on commit drop;

insert into _lote_alternativas (ordem, letra_ordem, texto, correta) values
(1, 1, $ALT1_1$A oração está na voz ativa, embora o sujeito gramatical não corresponda ao agente de uma ação voluntária.$ALT1_1$, true),
(1, 2, $ALT1_2$A oração está na voz passiva analítica, pois o sujeito sofre os efeitos da ação verbal.$ALT1_2$, false),
(1, 3, $ALT1_3$A oração está na voz passiva sintética, pois o verbo indica um fato ocorrido com o sujeito.$ALT1_3$, false),
(1, 4, $ALT1_4$A oração está na voz reflexiva, pois o sujeito é afetado pelo processo expresso pelo verbo.$ALT1_4$, false),
(1, 5, $ALT1_5$A oração não apresenta voz verbal, pois o verbo “sofrer” não indica ação voluntária.$ALT1_5$, false),
(2, 1, $ALT2_1$Os documentos da apuração serão analisados pela corregedoria.$ALT2_1$, true),
(2, 2, $ALT2_2$Os documentos da apuração foram analisados pela corregedoria.$ALT2_2$, false),
(2, 3, $ALT2_3$Os documentos da apuração analisarão a corregedoria.$ALT2_3$, false),
(2, 4, $ALT2_4$A corregedoria será analisada pelos documentos da apuração.$ALT2_4$, false),
(2, 5, $ALT2_5$Os documentos da apuração estarão analisados pela corregedoria.$ALT2_5$, false),
(3, 1, $ALT3_1$Em I, o se é índice de indeterminação do sujeito; em II, é partícula apassivadora.$ALT3_1$, false),
(3, 2, $ALT3_2$Em I, o se é partícula apassivadora, e “os locais de apresentação dos candidatos” é sujeito paciente; em II, o se é índice de indeterminação do sujeito.$ALT3_2$, true),
(3, 3, $ALT3_3$Em ambas as orações, o se é partícula apassivadora, pois os verbos exprimem ações.$ALT3_3$, false),
(3, 4, $ALT3_4$Em ambas as orações, o se é índice de indeterminação do sujeito, pois o agente não foi expresso.$ALT3_4$, false),
(3, 5, $ALT3_5$Em I, “os locais de apresentação dos candidatos” é objeto direto; em II, “de servidores” é sujeito paciente.$ALT3_5$, false),
(4, 1, $ALT4_1$de que$ALT4_1$, false),
(4, 2, $ALT4_2$em que$ALT4_2$, true),
(4, 3, $ALT4_3$a que$ALT4_3$, false),
(4, 4, $ALT4_4$com que$ALT4_4$, false),
(4, 5, $ALT4_5$por que$ALT4_5$, false),
(5, 1, $ALT5_1$A chefia prefere o planejamento prévio à adoção de medidas improvisadas.$ALT5_1$, true),
(5, 2, $ALT5_2$A chefia prefere mais o planejamento prévio do que a adoção de medidas improvisadas.$ALT5_2$, false),
(5, 3, $ALT5_3$A chefia prefere o planejamento prévio do que a adoção de medidas improvisadas.$ALT5_3$, false),
(5, 4, $ALT5_4$A chefia prefere mais o planejamento prévio à adoção de medidas improvisadas.$ALT5_4$, false),
(5, 5, $ALT5_5$A chefia prefere o planejamento prévio do que à adoção de medidas improvisadas.$ALT5_5$, false),
(6, 1, $ALT6_1$“Durante o plantão”.$ALT6_1$, false),
(6, 2, $ALT6_2$“a equipe”.$ALT6_2$, false),
(6, 3, $ALT6_3$“cuidadosamente”.$ALT6_3$, false),
(6, 4, $ALT6_4$“as ocorrências”.$ALT6_4$, true),
(6, 5, $ALT6_5$“no sistema”.$ALT6_5$, false),
(7, 1, $ALT7_1$Objeto indireto, pois é introduzido pela preposição “a”.$ALT7_1$, false),
(7, 2, $ALT7_2$Objeto direto preposicionado, pois completa o verbo “homenageou”, que admite complemento direto.$ALT7_2$, true),
(7, 3, $ALT7_3$Agente da passiva, pois indica quem recebeu a homenagem.$ALT7_3$, false),
(7, 4, $ALT7_4$Complemento nominal, pois completa o sentido do substantivo “direção”.$ALT7_4$, false),
(7, 5, $ALT7_5$Sujeito simples da oração, pois pratica a ação de homenagear.$ALT7_5$, false),
(8, 1, $ALT8_1$“Aos candidatos” é objeto direto e pode ser substituído por “os”: “A Direção os comunicou o novo horário”.$ALT8_1$, false),
(8, 2, $ALT8_2$“Aos candidatos” é objeto indireto, e a redação “A Direção comunicou-lhes o novo horário” preserva essa função. Em regra, o/a/os/as substituem objetos diretos, e lhe/lhes, objetos indiretos; contudo, lhe/lhes também podem assumir valor possessivo em certos usos normativos.$ALT8_2$, true),
(8, 3, $ALT8_3$“Aos candidatos” é complemento nominal, pois completa o sentido do substantivo “Direção”.$ALT8_3$, false),
(8, 4, $ALT8_4$“Aos candidatos” é objeto indireto, mas deve ser substituído obrigatoriamente por “os”, já que todo termo preposicionado é objeto direto.$ALT8_4$, false),
(8, 5, $ALT8_5$“Aos candidatos” é agente da passiva, pois foi introduzido pela preposição “a”.$ALT8_5$, false),
(9, 1, $ALT9_1$O agente da passiva é “os relatórios de ocorrência”; na voz ativa: “Os relatórios de ocorrência conferiram a comissão designada”.$ALT9_1$, false),
(9, 2, $ALT9_2$O agente da passiva é “pela comissão designada”; na voz ativa: “A comissão designada conferiu os relatórios de ocorrência”.$ALT9_2$, true),
(9, 3, $ALT9_3$O agente da passiva é “foram conferidos”; na voz ativa: “A comissão designada se conferiu nos relatórios de ocorrência”.$ALT9_3$, false),
(9, 4, $ALT9_4$“Pela comissão designada” é objeto indireto, pois todo termo iniciado por “pela” desempenha essa função; na voz ativa: “Os relatórios de ocorrência foram conferidos à comissão designada”.$ALT9_4$, false),
(9, 5, $ALT9_5$Não há agente da passiva, pois a preposição “por” ou suas contrações nunca participa da identificação desse termo.$ALT9_5$, false),
(10, 1, $ALT10_1$Em I, “de reforço” é objeto indireto; em II, “de reforço” é complemento nominal.$ALT10_1$, true),
(10, 2, $ALT10_2$Em I, “de reforço” é objeto direto preposicionado; em II, “de reforço” é objeto indireto.$ALT10_2$, false),
(10, 3, $ALT10_3$Em I, “de reforço” é complemento nominal; em II, “de reforço” é objeto direto.$ALT10_3$, false),
(10, 4, $ALT10_4$Em I e em II, “de reforço” é objeto indireto, pois ambas as expressões são introduzidas por preposição.$ALT10_4$, false),
(10, 5, $ALT10_5$Em I e em II, “de reforço” é complemento nominal, pois ambas as expressões indicam uma necessidade.$ALT10_5$, false),
(11, 1, $ALT11_1$A conjunção estabelece relação de adição entre a redução indicada e a necessidade de conferência.$ALT11_1$, false),
(11, 2, $ALT11_2$A conjunção introduz uma conclusão inevitável decorrente do levantamento preliminar.$ALT11_2$, false),
(11, 3, $ALT11_3$A conjunção expressa oposição ou contraste entre as ideias, valor também associado a adversativas como “mas” e “porém”, sem que isso assegure substituição absoluta em todo contexto.$ALT11_3$, true),
(11, 4, $ALT11_4$A conjunção poderia ser substituída por qualquer adversativa, em qualquer posição e sem alteração de pontuação, registro ou nuance de sentido.$ALT11_4$, false),
(11, 5, $ALT11_5$A conjunção introduz a causa pela qual a análise definitiva dependerá da conferência dos registros.$ALT11_5$, false),
(12, 1, $ALT12_1$“Conquanto” introduz uma condição, e “quando” introduz uma concessão.$ALT12_1$, false),
(12, 2, $ALT12_2$“Conquanto” introduz uma concessão, e “quando” introduz uma relação temporal.$ALT12_2$, true),
(12, 3, $ALT12_3$“Conquanto” introduz uma causa, e “quando” introduz uma consequência.$ALT12_3$, false),
(12, 4, $ALT12_4$“Conquanto” introduz uma conclusão, e “quando” introduz uma condição.$ALT12_4$, false),
(12, 5, $ALT12_5$Ambos os conectores introduzem relações temporais, pois se referem a fatos ocorridos durante a operação.$ALT12_5$, false),
(13, 1, $ALT13_1$causa, pois explica o motivo de o treinamento prático ser mantido.$ALT13_1$, false),
(13, 2, $ALT13_2$condição, pois apresenta uma hipótese para a manutenção do treinamento.$ALT13_2$, false),
(13, 3, $ALT13_3$concessão, pois a orientação prévia não impede a manutenção do treinamento.$ALT13_3$, true),
(13, 4, $ALT13_4$tempo, pois situa cronologicamente a realização do treinamento.$ALT13_4$, false),
(13, 5, $ALT13_5$conclusão, pois introduz uma decorrência das orientações recebidas.$ALT13_5$, false),
(14, 1, $ALT14_1$comparação entre a eficiência da comunicação e o tempo de resposta.$ALT14_1$, false),
(14, 2, $ALT14_2$consequência, pois a redução do tempo de resposta decorre da intensidade da eficiência mencionada.$ALT14_2$, true),
(14, 3, $ALT14_3$adição, pois são apresentadas duas características independentes da comunicação.$ALT14_3$, false),
(14, 4, $ALT14_4$condição, pois a redução do tempo de resposta depende de uma hipótese futura.$ALT14_4$, false),
(14, 5, $ALT14_5$concessão, pois a eficiência da comunicação contrasta com a redução do tempo de resposta.$ALT14_5$, false),
(15, 1, $ALT15_1$O termo “cujos” retoma “registros de manutenção” e concorda com “unidade operacional”.$ALT15_1$, false),
(15, 2, $ALT15_2$O termo “cujos” introduz uma relação de posse, mas seu antecedente é “corregedoria”.$ALT15_2$, false),
(15, 3, $ALT15_3$O termo “cujos” retoma “unidade operacional”, indicando que os registros de manutenção pertencem a ela, e concorda com “registros”.$ALT15_3$, true),
(15, 4, $ALT15_4$O termo “cujos” concorda obrigatoriamente com o antecedente “unidade operacional”; por isso, deveria estar no feminino singular.$ALT15_4$, false),
(15, 5, $ALT15_5$O termo “cujos” realiza uma catáfora, pois anuncia um elemento que somente aparecerá depois dele no período.$ALT15_5$, false),
(16, 1, $ALT16_1$retomar exclusivamente a distribuição de lanternas às equipes.$ALT16_1$, false),
(16, 2, $ALT16_2$antecipar uma informação que será apresentada após o segundo período.$ALT16_2$, false),
(16, 3, $ALT16_3$repetir literalmente a expressão “mapas de risco”, mantendo esse único tópico textual.$ALT16_3$, false),
(16, 4, $ALT16_4$sintetizar as três ações mencionadas no período anterior.$ALT16_4$, true),
(16, 5, $ALT16_5$retomar apenas a atualização da escala de serviço por meio de uma expressão equivalente.$ALT16_5$, false),
(17, 1, $ALT17_1$o capitão.$ALT17_1$, true),
(17, 2, $ALT17_2$a analista.$ALT17_2$, false),
(17, 3, $ALT17_3$o parecer.$ALT17_3$, false),
(17, 4, $ALT17_4$a conclusão.$ALT17_4$, false),
(17, 5, $ALT17_5$a assinatura.$ALT17_5$, false);

create temporary table _unidades_ordem (ordem_min int, ordem_max int, unidade_pedagogica_id uuid) on commit drop;
insert into _unidades_ordem (ordem_min, ordem_max, unidade_pedagogica_id) values
(1, 3, '1cb6bef3-1d8d-4cae-9ed9-eae9fe4d79b9'::uuid),
(4, 5, '735f736a-37c0-477f-a555-dcd73d243d21'::uuid),
(6, 10, '981e5d2c-3b59-48a0-a699-a53c03e500ee'::uuid),
(11, 14, 'd1e31767-d27d-431b-ba59-7a2008c7473d'::uuid),
(15, 17, '29a4bec1-2c3a-40f3-a86f-fa6bda25d04f'::uuid);

-- ================= PRECONDICOES =================
do $$
declare
  v_unidade_ok boolean;
  v_uteis int; v_real int; v_autoral int; v_gap int; v_dup int;
  r record;
begin
  for r in select unidade_pedagogica_id, ordem_min, ordem_max from _unidades_ordem loop
    select (up.ativa and cc.relevante_para_preparacao and cm.relevante_para_preparacao and cm.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4')
    into v_unidade_ok
    from public.unidades_pedagogicas up
    join public.curso_conteudos cc on cc.id = up.curso_conteudo_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where up.id = r.unidade_pedagogica_id;
    if not coalesce(v_unidade_ok, false) then raise exception 'PRECOND: unidade % nao esta ativa/relevante conforme esperado', r.unidade_pedagogica_id; end if;

    select count(distinct q.id) into v_uteis
    from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
    where qup.unidade_pedagogica_id = r.unidade_pedagogica_id and q.ativa=true
    and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);

    select count(distinct q.id) filter (where coalesce(lower(q.banca),'') not like '%papiro%'),
           count(distinct q.id) filter (where coalesce(lower(q.banca),'') like '%papiro%')
      into v_real, v_autoral
    from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
    where qup.unidade_pedagogica_id = r.unidade_pedagogica_id and q.ativa=true
    and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);

    select count(*) into v_gap
    from (
      select distinct q.id from public.questoes q
      join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
      where qup.unidade_pedagogica_id = r.unidade_pedagogica_id and q.ativa
      and not exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id)
    ) g;
    if v_gap <> 0 then raise exception 'PRECOND: gap curso_questoes na unidade %=% esperado 0', r.unidade_pedagogica_id, v_gap; end if;

    raise notice 'PRECOND unidade % OK: uteis=% real=% autoral=% gap=%', r.unidade_pedagogica_id, v_uteis, v_real, v_autoral, v_gap;
  end loop;

  select count(*) into v_dup
  from public.questoes q
  where q.ativa = true
  and lower(q.enunciado) in (
  lower($DUP1$Em um relatório de ocorrência, lê-se: “Durante o atendimento, o policial sofreu um ferimento no braço”. Quanto à voz verbal, assinale a alternativa correta.$DUP1$),
  lower($DUP2$Assinale a alternativa que apresenta a transposição correta para a voz passiva analítica da oração: “A corregedoria analisará os documentos da apuração”.$DUP2$),
  lower($DUP3$Em comunicados internos de uma unidade policial, constam as seguintes construções:

I. Divulgaram-se os locais de apresentação dos candidatos.
II. Necessita-se de servidores para o atendimento administrativo.

Considerando a estrutura sintática e o sentido das orações, assinale a alternativa correta.$DUP3$),
  lower($DUP4$Assinale a alternativa que completa corretamente a frase abaixo, de acordo com a regência verbal na oração relativa.

"Os pareceres ______ a comissão se baseou para elaborar o relatório final serão encaminhados ao comando."$DUP4$),
  lower($DUP5$Assinale a alternativa redigida de acordo com a regência verbal prescrita pela norma-padrão.$DUP5$),
  lower($DUP6$Durante o plantão, a equipe registrou cuidadosamente as ocorrências no sistema. O termo que exerce a função de objeto direto do verbo “registrou” é:$DUP6$),
  lower($DUP7$A direção homenageou a todos os policiais que se destacaram na operação. Assinale a alternativa que classifica corretamente o termo destacado.$DUP7$),
  lower($DUP8$No comunicado interno, lê-se: “A Direção comunicou aos candidatos o novo horário da avaliação”. Assinale a alternativa correta acerca da expressão destacada e de sua substituição pronominal.$DUP8$),
  lower($DUP9$Considere a oração de um procedimento administrativo: “Os relatórios de ocorrência foram conferidos pela comissão designada”. Assinale a alternativa que identifica corretamente o agente da passiva e apresenta a conversão adequada da oração para a voz ativa.$DUP9$),
  lower($DUP10$Analise as ocorrências destacadas nos períodos a seguir.

I. “O comando necessita de reforço para o patrulhamento.”
II. “A necessidade de reforço para o patrulhamento foi comunicada aos setores responsáveis.”

Quanto à função sintática das expressões destacadas, assinale a alternativa correta.$DUP10$),
  lower($DUP11$Em uma comunicação interna, lê-se: “O levantamento preliminar indicou redução das ocorrências; contudo, a análise definitiva dependerá da conferência dos registros.”

Assinale a alternativa correta acerca do emprego de “contudo” no período.$DUP11$),
  lower($DUP12$Leia o trecho de um relatório institucional:

“Conquanto o efetivo estivesse reduzido, o atendimento às ocorrências prioritárias foi mantido. Quando a operação foi encerrada, os dados foram encaminhados ao comando.”

Assinale a alternativa que classifica corretamente as relações semânticas introduzidas pelos conectores destacados.$DUP12$),
  lower($DUP13$Em um comunicado interno, lê-se: “Conquanto a equipe tenha recebido orientações prévias, o treinamento prático será mantido”.

A conjunção “conquanto” estabelece, entre as ideias do período, uma relação de$DUP13$),
  lower($DUP14$No relatório de serviço, registrou-se que “a comunicação entre as equipes foi tão eficiente que reduziu o tempo de resposta às ocorrências”.

No período, a estrutura “tão...que” expressa uma relação de$DUP14$),
  lower($DUP15$Leia a frase a seguir.

“A unidade operacional, cujos registros de manutenção foram revisados pela corregedoria, encaminhou o relatório ao comando.”

Quanto ao emprego do pronome relativo “cujos”, assinale a alternativa correta.$DUP15$),
  lower($DUP16$Leia o trecho a seguir.

“Durante a preparação para a operação, o comando revisou os mapas de risco, atualizou a escala de serviço e distribuiu lanternas às equipes. Essas providências buscaram ampliar a segurança do patrulhamento noturno.”

No contexto, a expressão “Essas providências” exerce a função de$DUP16$),
  lower($DUP17$Leia a frase a seguir.

"O capitão encaminhou à analista o parecer cuja conclusão ele contestou antes da assinatura."

Considerando os mecanismos de coesão referencial, o pronome pessoal "ele" retoma$DUP17$)
  );
  if v_dup <> 0 then raise exception 'PRECOND: % questao(oes) com enunciado identico ja existem — possivel reexecucao/duplicidade', v_dup; end if;

  raise notice 'PRECONDICOES GLOBAIS OK: 0 duplicidade de enunciado entre as 17';
end $$;

-- ================= INSERT das 17 questoes =================
create temporary table _mapa_ids (ordem int primary key, questao_id bigint, unidade_pedagogica_id uuid) on commit drop;

do $$
declare
  r record;
  v_novo_id bigint;
  v_uid uuid;
begin
  for r in select ordem, dificuldade, fonte, enunciado from _lote_questoes order by ordem loop
    select unidade_pedagogica_id into v_uid from _unidades_ordem where r.ordem between ordem_min and ordem_max;

    insert into public.questoes (materia_id, assunto_id, banca, concurso, ano, dificuldade, enunciado, explicacao, fonte, ativa, usuario_id)
    select cc.curso_materia_id_materia, cc.assunto_id, 'Papiro', 'PAPIRO - Curadoria LOTE05_PORTUGUES_AUTORAL - BM RS', 2026, r.dificuldade, r.enunciado,
      (select explicacao from _lote_explicacoes le where le.ordem = r.ordem),
      r.fonte, true, null
    from (
      select cm.materia_id as curso_materia_id_materia, cc2.assunto_id
      from public.curso_conteudos cc2
      join public.curso_materias cm on cm.id = cc2.curso_materia_id
      where cc2.id = (select curso_conteudo_id from _lote_questoes where ordem = r.ordem)
    ) cc
    returning id into v_novo_id;

    insert into _mapa_ids (ordem, questao_id, unidade_pedagogica_id) values (r.ordem, v_novo_id, v_uid);

    insert into public.alternativas (questao_id, texto, ordem, correta)
    select v_novo_id, la.texto, la.letra_ordem, la.correta
    from _lote_alternativas la
    where la.ordem = r.ordem;
  end loop;
end $$;

-- ================= VINCULO via RPC sancionada =================
do $$
declare
  r record;
begin
  for r in select questao_id, unidade_pedagogica_id from _mapa_ids order by ordem loop
    perform public.classificar_questao_unidade_admin(r.questao_id, r.unidade_pedagogica_id);
  end loop;
end $$;

-- ===================== FASE TARGET (apos o apply, dentro da mesma transacao) =====================
do $$
declare
  v_questoes int; v_alternativas int; v_vinculos int; v_curso_questoes int;
  v_snap record;
  v_uteis int; v_real int; v_autoral int;
  v_vinc_ok int; v_cq_ok int;
  v_gabaritos text;
begin
  select * into v_snap from _snapshot_antes;

  select count(*) into v_questoes from public.questoes;
  select count(*) into v_alternativas from public.alternativas;
  select count(*) into v_vinculos from public.questao_unidades_pedagogicas;
  select count(*) into v_curso_questoes from public.curso_questoes;

  insert into _relatorio values ('TARGET', 'questoes_delta_17', v_questoes - v_snap.total_questoes = 17, (v_questoes - v_snap.total_questoes)::text);
  insert into _relatorio values ('TARGET', 'alternativas_delta_85', v_alternativas - v_snap.total_alternativas = 85, (v_alternativas - v_snap.total_alternativas)::text);
  insert into _relatorio values ('TARGET', 'vinculos_delta_17', v_vinculos - v_snap.total_vinculos = 17, (v_vinculos - v_snap.total_vinculos)::text);
  insert into _relatorio values ('TARGET', 'curso_questoes_delta_17', v_curso_questoes - v_snap.total_curso_questoes = 17, (v_curso_questoes - v_snap.total_curso_questoes)::text);

  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='1cb6bef3-1d8d-4cae-9ed9-eae9fe4d79b9' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET', 'uteis_10_1cb6bef3-1d8d-4cae-9ed9-eae9fe4d79b9', v_uteis = 10, v_uteis::text);

  select count(distinct q.id) filter (where coalesce(lower(q.banca),'') not like '%papiro%'),
         count(distinct q.id) filter (where coalesce(lower(q.banca),'') like '%papiro%')
    into v_real, v_autoral
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='1cb6bef3-1d8d-4cae-9ed9-eae9fe4d79b9' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET', 'uteis10_1cb6bef3-1d8d-4cae-9ed9-eae9fe4d79b9', v_real + v_autoral = 10, (v_real + v_autoral)::text);

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=m.questao_id and correta=true), '' order by m.ordem)
    into v_gabaritos from _mapa_ids m where m.unidade_pedagogica_id = '1cb6bef3-1d8d-4cae-9ed9-eae9fe4d79b9';
  insert into _relatorio values ('TARGET', 'gabaritos_1cb6bef3-1d8d-4cae-9ed9-eae9fe4d79b9', v_gabaritos = 'AAB', v_gabaritos);

  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='735f736a-37c0-477f-a555-dcd73d243d21' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET', 'uteis_10_735f736a-37c0-477f-a555-dcd73d243d21', v_uteis = 10, v_uteis::text);

  select count(distinct q.id) filter (where coalesce(lower(q.banca),'') not like '%papiro%'),
         count(distinct q.id) filter (where coalesce(lower(q.banca),'') like '%papiro%')
    into v_real, v_autoral
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='735f736a-37c0-477f-a555-dcd73d243d21' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET', 'uteis10_735f736a-37c0-477f-a555-dcd73d243d21', v_real + v_autoral = 10, (v_real + v_autoral)::text);

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=m.questao_id and correta=true), '' order by m.ordem)
    into v_gabaritos from _mapa_ids m where m.unidade_pedagogica_id = '735f736a-37c0-477f-a555-dcd73d243d21';
  insert into _relatorio values ('TARGET', 'gabaritos_735f736a-37c0-477f-a555-dcd73d243d21', v_gabaritos = 'BA', v_gabaritos);

  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='981e5d2c-3b59-48a0-a699-a53c03e500ee' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET', 'uteis_10_981e5d2c-3b59-48a0-a699-a53c03e500ee', v_uteis = 10, v_uteis::text);

  select count(distinct q.id) filter (where coalesce(lower(q.banca),'') not like '%papiro%'),
         count(distinct q.id) filter (where coalesce(lower(q.banca),'') like '%papiro%')
    into v_real, v_autoral
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='981e5d2c-3b59-48a0-a699-a53c03e500ee' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET', 'uteis10_981e5d2c-3b59-48a0-a699-a53c03e500ee', v_real + v_autoral = 10, (v_real + v_autoral)::text);

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=m.questao_id and correta=true), '' order by m.ordem)
    into v_gabaritos from _mapa_ids m where m.unidade_pedagogica_id = '981e5d2c-3b59-48a0-a699-a53c03e500ee';
  insert into _relatorio values ('TARGET', 'gabaritos_981e5d2c-3b59-48a0-a699-a53c03e500ee', v_gabaritos = 'DBBBA', v_gabaritos);

  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='d1e31767-d27d-431b-ba59-7a2008c7473d' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET', 'uteis_10_d1e31767-d27d-431b-ba59-7a2008c7473d', v_uteis = 10, v_uteis::text);

  select count(distinct q.id) filter (where coalesce(lower(q.banca),'') not like '%papiro%'),
         count(distinct q.id) filter (where coalesce(lower(q.banca),'') like '%papiro%')
    into v_real, v_autoral
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='d1e31767-d27d-431b-ba59-7a2008c7473d' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET', 'uteis10_d1e31767-d27d-431b-ba59-7a2008c7473d', v_real + v_autoral = 10, (v_real + v_autoral)::text);

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=m.questao_id and correta=true), '' order by m.ordem)
    into v_gabaritos from _mapa_ids m where m.unidade_pedagogica_id = 'd1e31767-d27d-431b-ba59-7a2008c7473d';
  insert into _relatorio values ('TARGET', 'gabaritos_d1e31767-d27d-431b-ba59-7a2008c7473d', v_gabaritos = 'CBCB', v_gabaritos);

  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='29a4bec1-2c3a-40f3-a86f-fa6bda25d04f' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET', 'uteis_10_29a4bec1-2c3a-40f3-a86f-fa6bda25d04f', v_uteis = 10, v_uteis::text);

  select count(distinct q.id) filter (where coalesce(lower(q.banca),'') not like '%papiro%'),
         count(distinct q.id) filter (where coalesce(lower(q.banca),'') like '%papiro%')
    into v_real, v_autoral
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='29a4bec1-2c3a-40f3-a86f-fa6bda25d04f' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET', 'uteis10_29a4bec1-2c3a-40f3-a86f-fa6bda25d04f', v_real + v_autoral = 10, (v_real + v_autoral)::text);

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=m.questao_id and correta=true), '' order by m.ordem)
    into v_gabaritos from _mapa_ids m where m.unidade_pedagogica_id = '29a4bec1-2c3a-40f3-a86f-fa6bda25d04f';
  insert into _relatorio values ('TARGET', 'gabaritos_29a4bec1-2c3a-40f3-a86f-fa6bda25d04f', v_gabaritos = 'CDA', v_gabaritos);

  select count(*) into v_vinc_ok from _mapa_ids m
    where exists(select 1 from public.questao_unidades_pedagogicas qup where qup.questao_id=m.questao_id and qup.unidade_pedagogica_id=m.unidade_pedagogica_id)
    and not exists(select 1 from public.questao_unidades_pedagogicas qup2 where qup2.questao_id=m.questao_id and qup2.unidade_pedagogica_id <> m.unidade_pedagogica_id);
  insert into _relatorio values ('TARGET', 'vinculos_17_corretos', v_vinc_ok = 17, v_vinc_ok::text);

  select count(*) into v_cq_ok from _mapa_ids m
    where exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=m.questao_id);
  insert into _relatorio values ('TARGET', 'curso_questoes_17', v_cq_ok = 17, v_cq_ok::text);

  insert into _relatorio values ('TARGET', 'ativa_17de17',
    (select count(*) from _mapa_ids m join public.questoes q on q.id=m.questao_id where q.ativa) = 17, 'ativa');
  insert into _relatorio values ('TARGET', 'origem_papiro_17de17',
    (select count(*) from _mapa_ids m join public.questoes q on q.id=m.questao_id where coalesce(lower(q.banca),'') like '%papiro%') = 17, 'banca papiro');
end $$;

-- ===================== REVERSAO REAL (mesma logica do reverter real) =====================
do $$
declare
  v_uteis int;
  r record;
begin
  for r in select unidade_pedagogica_id from _unidades_ordem loop
    select count(distinct q.id) into v_uteis
    from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
    where qup.unidade_pedagogica_id = r.unidade_pedagogica_id and q.ativa=true
    and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
    insert into _relatorio values ('REVERSAO_GUARD', 'uteis_antes_de_reverter_' || r.unidade_pedagogica_id, v_uteis > 0, v_uteis::text);
  end loop;
end $$;

do $$
declare
  r record;
  v_count int := 0;
begin
  for r in select questao_id, unidade_pedagogica_id from _mapa_ids order by ordem loop
    perform public.remover_classificacao_questao_unidade_admin(r.questao_id, r.unidade_pedagogica_id);
    v_count := v_count + 1;
  end loop;
  insert into _relatorio values ('REVERSAO', 'vinculos_removidos_17', v_count = 17, v_count::text);
end $$;

do $$
declare v_count int;
begin
  delete from public.curso_questoes where curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and questao_id in (select questao_id from _mapa_ids);
  get diagnostics v_count = row_count;
  insert into _relatorio values ('REVERSAO', 'curso_questoes_removidas_17', v_count = 17, v_count::text);
end $$;

do $$
declare v_count int;
begin
  delete from public.alternativas where questao_id in (select questao_id from _mapa_ids);
  get diagnostics v_count = row_count;
  insert into _relatorio values ('REVERSAO', 'alternativas_removidas_85', v_count = 85, v_count::text);
end $$;

do $$
declare v_count int;
begin
  delete from public.questoes where id in (select questao_id from _mapa_ids);
  get diagnostics v_count = row_count;
  insert into _relatorio values ('REVERSAO', 'questoes_removidas_17', v_count = 17, v_count::text);
end $$;

-- ===================== FASE OLD_FINAL (pos-reversao) =====================
do $$
declare
  v_snap record;
  v_questoes int; v_alternativas int; v_vinculos int; v_curso_questoes int;
begin
  select * into v_snap from _snapshot_antes;

  select count(*) into v_questoes from public.questoes;
  select count(*) into v_alternativas from public.alternativas;
  select count(*) into v_vinculos from public.questao_unidades_pedagogicas;
  select count(*) into v_curso_questoes from public.curso_questoes;

  insert into _relatorio values ('OLD_FINAL', 'questoes_restauradas', v_questoes = v_snap.total_questoes, v_questoes::text);
  insert into _relatorio values ('OLD_FINAL', 'alternativas_restauradas', v_alternativas = v_snap.total_alternativas, v_alternativas::text);
  insert into _relatorio values ('OLD_FINAL', 'vinculos_restaurados', v_vinculos = v_snap.total_vinculos, v_vinculos::text);
  insert into _relatorio values ('OLD_FINAL', 'curso_questoes_restauradas', v_curso_questoes = v_snap.total_curso_questoes, v_curso_questoes::text);
end $$;

-- ===================== RESUMO =====================
select fase, count(*) as total, count(*) filter (where ok) as ok_count
from _relatorio group by fase order by min(ctid);

select * from _relatorio where not ok;

do $$
declare
  v_total int; v_ok int;
begin
  select count(*), count(*) filter (where ok) into v_total, v_ok from _relatorio;
  if v_total = v_ok then
    raise notice 'TESTE DE ROLLBACK: %/% checks OK — LOTE05_PORTUGUES_AUTORAL_ROLLBACK_TEST_APROVADO', v_ok, v_total;
  else
    raise notice 'TESTE DE ROLLBACK: %/% checks OK — HA FALHAS, ver _relatorio', v_ok, v_total;
  end if;
end $$;

rollback;
