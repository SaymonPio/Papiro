-- TESTE DE ROLLBACK REAL da IMPORTACAO LOTE03_PORTUGUES_AUTORAL. Executa, dentro de UMA
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
(1, 28, $D1$media$D1$, $FONTE1$PAPIRO — LOTE03_PORTUGUES_AUTORAL — COORD-01$FONTE1$, $ENUN1$Leia o período a seguir.

“Durante a ocorrência, a guarnição isolou o local e registrou os dados das testemunhas.”

A análise correta da relação entre as orações do período é:$ENUN1$),
(2, 28, $D2$media$D2$, $FONTE2$PAPIRO — LOTE03_PORTUGUES_AUTORAL — COORD-02$FONTE2$, $ENUN2$Leia o período a seguir.

“O rádio da viatura estava inoperante; portanto, a equipe utilizou o canal de reserva.”

Analise as afirmativas a respeito da relação entre as orações.

I. As orações são sintaticamente independentes, estabelecendo entre si uma relação de coordenação.

II. O conectivo “portanto” introduz uma conclusão decorrente da informação apresentada na oração anterior.

III. O conectivo “portanto” introduz uma justificativa para o fato de o rádio estar inoperante.

Quais afirmativas estão corretas?$ENUN2$),
(3, 28, $D3$media$D3$, $FONTE3$PAPIRO — LOTE03_PORTUGUES_AUTORAL — COORD-03$FONTE3$, $ENUN3$Analise os períodos a seguir.

I. Não se aproxime, porque a área apresenta risco.
II. Porque a área apresentava risco, o acesso foi bloqueado.
III. Mantenha distância, que a área está isolada.

Considere as afirmativas a respeito da classificação das orações 'porque a área apresenta risco', 'Porque a área apresentava risco' e 'que a área está isolada', presentes, respectivamente, nos períodos I, II e III.

I. Em I e III, as orações introduzidas por “porque” e “que” são coordenadas sindéticas explicativas, pois justificam, respectivamente, a recomendação e a ordem expressas nas orações anteriores.
II. Em II, a oração introduzida por “Porque” é subordinada adverbial causal, pois indica a causa pela qual o acesso foi bloqueado.
III. A presença de “porque”, por si só, não determina a classificação da oração: é necessário verificar se ela explica uma enunciação independente ou se integra a estrutura da oração principal como circunstância de causa.

Quais estão corretas?$ENUN3$),
(4, 28, $D4$media$D4$, $FONTE4$PAPIRO — LOTE03_PORTUGUES_AUTORAL — COORD-04$FONTE4$, $ENUN4$Analise os períodos a seguir.

I. Como a visibilidade diminuiu, a equipe reduziu a velocidade da viatura.
II. Embora a visibilidade tenha diminuído, a equipe seguiu para o local da ocorrência.
III. A operação foi adiada porque a visibilidade diminuiu.

Avalie as afirmativas.

I. As orações "Como a visibilidade diminuiu", em I, e "porque a visibilidade diminuiu", em III, são subordinadas adverbiais causais, pois apresentam a razão pela qual ocorreram, respectivamente, a redução da velocidade e o adiamento da operação.
II. A oração "Embora a visibilidade tenha diminuído", em II, é subordinada adverbial concessiva, porque apresenta uma circunstância que poderia dificultar o deslocamento, mas não impediu que a equipe seguisse para o local.
III. A diferença entre causa e concessão depende da relação lógica estabelecida: a causa explica a ocorrência do fato principal, enquanto a concessão apresenta um obstáculo que não impede sua realização.

Quais estão corretas?$ENUN4$),
(5, 28, $D5$media$D5$, $FONTE5$PAPIRO — LOTE03_PORTUGUES_AUTORAL — COORD-05$FONTE5$, $ENUN5$Leia o período elaborado em contexto institucional:

“Caso o efetivo seja convocado, os policiais deverão apresentar-se no horário determinado.”

Assinale a alternativa correta acerca da oração destacada.$ENUN5$),
(6, 28, $D6$media$D6$, $FONTE6$PAPIRO — LOTE03_PORTUGUES_AUTORAL — COORD-06$FONTE6$, $ENUN6$No período abaixo, a oração subordinada substantiva está destacada:

“A chefia manifestou a convicção de que a medida preventiva reduziria os riscos da operação.”

A oração “de que a medida preventiva reduziria os riscos da operação” classifica-se como subordinada substantiva$ENUN6$),
(7, 28, $D7$media$D7$, $FONTE7$PAPIRO — LOTE03_PORTUGUES_AUTORAL — COORD-07$FONTE7$, $ENUN7$Leia a frase a seguir.

"Os candidatos que apresentaram a documentação completa seguiram para a etapa seguinte."

A oração "que apresentaram a documentação completa" é corretamente classificada como$ENUN7$),
(8, 16, $D8$media$D8$, $FONTE8$PAPIRO — LOTE03_PORTUGUES_AUTORAL — PONT-01$FONTE8$, $ENUN8$Assinale a alternativa em que a pontuação está corretamente empregada.$ENUN8$),
(9, 16, $D9$media$D9$, $FONTE9$PAPIRO — LOTE03_PORTUGUES_AUTORAL — PONT-02$FONTE9$, $ENUN9$Em relação ao emprego da vírgula em períodos com orações adverbiais deslocadas, assinale a alternativa em que a pontuação está INCORRETA.$ENUN9$),
(10, 16, $D10$media$D10$, $FONTE10$PAPIRO — LOTE03_PORTUGUES_AUTORAL — PONT-03$FONTE10$, $ENUN10$No trecho abaixo, a oração introduzida por “que” tem valor explicativo, acrescentando uma informação sobre a totalidade da equipe de atendimento da unidade. Assinale a alternativa em que essa oração está corretamente isolada por vírgulas.

“A equipe de atendimento da unidade ___ já havia concluído o registro preliminar ___ encaminhou o comunicado ao setor responsável.”$ENUN10$),
(11, 16, $D11$media$D11$, $FONTE11$PAPIRO — LOTE03_PORTUGUES_AUTORAL — PONT-04$FONTE11$, $ENUN11$Observe as duas redações a seguir.

I. Os candidatos que entregaram a documentação completa seguiram para a etapa seguinte.
II. Os candidatos, que entregaram a documentação completa, seguiram para a etapa seguinte.

Considerando o efeito de sentido produzido pela pontuação, assinale a alternativa correta.$ENUN11$),
(12, 16, $D12$media$D12$, $FONTE12$PAPIRO — LOTE03_PORTUGUES_AUTORAL — PONT-05$FONTE12$, $ENUN12$Assinale a alternativa em que o emprego da vírgula está incorreto por separar indevidamente o sujeito de seu verbo.$ENUN12$),
(13, 16, $D13$media$D13$, $FONTE13$PAPIRO — LOTE03_PORTUGUES_AUTORAL — PONT-06$FONTE13$, $ENUN13$Analise as afirmativas relativas ao emprego da vírgula.

I. Em “A guarnição entregou, o relatório ao superior”, a vírgula é inadequada, pois separa o verbo “entregou” de seu complemento direto.

II. Em “A guarnição entregou ao superior, após a conferência dos dados, o relatório”, as vírgulas isolam adequadamente o adjunto adverbial intercalado “após a conferência dos dados”.

III. Em “Os policiais receberam, ao final da reunião, as novas instruções”, as vírgulas isolam adequadamente o adjunto adverbial intercalado.

IV. Em “O superior solicitou, informações complementares”, a vírgula é adequada, pois separa o verbo de uma informação que o completa.

Quais afirmativas estão corretas?$ENUN13$),
(14, 16, $D14$media$D14$, $FONTE14$PAPIRO — LOTE03_PORTUGUES_AUTORAL — PONT-07$FONTE14$, $ENUN14$Analise as frases quanto à pontuação das orações adverbiais deslocadas ou intercaladas.

I. Depois que o perímetro foi isolado, os policiais iniciaram a averiguação.

II. Os policiais, enquanto aguardavam reforço, mantiveram o bloqueio da via.

III. Caso a visibilidade diminua durante o deslocamento da equipe a patrulha reduzirá a velocidade.

IV. A patrulha seguirá, caso as condições da via permitam, até o ponto indicado.

Quais frases estão corretamente pontuadas?$ENUN14$),
(15, 24, $D15$media$D15$, $FONTE15$PAPIRO — LOTE03_PORTUGUES_AUTORAL — DENOT-01$FONTE15$, $ENUN15$Leia a frase a seguir.

"Antes da operação, o soldado conferiu o peso do colete de proteção." 

No contexto apresentado, a palavra "peso" foi empregada em sentido denotativo porque se refere$ENUN15$),
(16, 24, $D16$media$D16$, $FONTE16$PAPIRO — LOTE03_PORTUGUES_AUTORAL — DENOT-02$FONTE16$, $ENUN16$Leia a frase a seguir.

"O relatório da corregedoria foi um farol para a revisão dos procedimentos internos." 

No contexto apresentado, a expressão "foi um farol" indica que o relatório$ENUN16$),
(17, 24, $D17$media$D17$, $FONTE17$PAPIRO — LOTE03_PORTUGUES_AUTORAL — DENOT-03$FONTE17$, $ENUN17$Considere as ocorrências da palavra “linha” nas frases a seguir.

I. Os candidatos permaneceram atrás da linha de segurança durante a instrução.
II. A equipe seguiu uma nova linha de investigação após analisar as imagens.

Quanto aos sentidos assumidos pela palavra “linha”, assinale a alternativa correta.$ENUN17$),
(18, 24, $D18$media$D18$, $FONTE18$PAPIRO — LOTE03_PORTUGUES_AUTORAL — DENOT-04$FONTE18$, $ENUN18$Analise as frases a seguir, considerando o emprego das expressões destacadas.

I. A sirene emitiu um **grito** prolongado.
II. O agente guardou o **colete** no armário.
III. Após a notícia, o silêncio **pesou** na sala.
IV. O mecânico substituiu a **corrente** da motocicleta.

Em quais frases o emprego destacado é conotativo?$ENUN18$),
(19, 24, $D19$media$D19$, $FONTE19$PAPIRO — LOTE03_PORTUGUES_AUTORAL — DENOT-05$FONTE19$, $ENUN19$Analise as frases a seguir quanto ao emprego das expressões destacadas.

I. O perito recolheu a **lanterna** que estava sobre a mesa.
II. A notícia **voou** pelo quartel antes do comunicado oficial.
III. A decisão deixou um **gosto amargo** entre os servidores.
IV. A viatura parou diante do **prédio** administrativo.

Assinale a alternativa que apresenta a análise correta, considerando apenas a distinção entre sentido literal e sentido figurado.$ENUN19$),
(20, 24, $D20$media$D20$, $FONTE20$PAPIRO — LOTE03_PORTUGUES_AUTORAL — DENOT-06$FONTE20$, $ENUN20$Em cada alternativa, a palavra ou expressão destacada foi classificada quanto ao sentido empregado na frase. Assinale a alternativa em que a classificação está INCORRETA.$ENUN20$),
(21, 24, $D21$media$D21$, $FONTE21$PAPIRO — LOTE03_PORTUGUES_AUTORAL — DENOT-07$FONTE21$, $ENUN21$Considere as ocorrências da palavra **raiz** nas frases a seguir.

I. As crianças observaram a **raiz** exposta da árvore após a chuva forte.
II. A falta de diálogo era a **raiz** do desentendimento entre os vizinhos.

Assinale a alternativa correta quanto ao sentido de “raiz” nos dois contextos.$ENUN21$),
(22, 29, $D22$media$D22$, $FONTE22$PAPIRO — LOTE03_PORTUGUES_AUTORAL — COLOC-01$FONTE22$, $ENUN22$No trecho de uma comunicação interna, assinale a alternativa que completa corretamente a lacuna, de acordo com a norma-padrão tradicional: “O servidor que ___ o comunicado deverá registrar a entrega no sistema.”$ENUN22$),
(23, 29, $D23$media$D23$, $FONTE23$PAPIRO — LOTE03_PORTUGUES_AUTORAL — COLOC-02$FONTE23$, $ENUN23$Na norma-padrão tradicional, complete o período a seguir, mantendo o advérbio **ali** sem pausa e o verbo no pretérito imperfeito:

“Ali ___ os policiais responsáveis pela escolta.”

Assinale a alternativa correta.$ENUN23$),
(24, 29, $D24$media$D24$, $FONTE24$PAPIRO — LOTE03_PORTUGUES_AUTORAL — COLOC-03$FONTE24$, $ENUN24$Assinale a alternativa que completa corretamente o período de acordo com a norma-padrão tradicional:

“O setor nunca ___ a confirmação da inscrição.”$ENUN24$),
(25, 29, $D25$media$D25$, $FONTE25$PAPIRO — LOTE03_PORTUGUES_AUTORAL — COLOC-04$FONTE25$, $ENUN25$Assinale a alternativa que completa corretamente a frase, de acordo com a norma-padrão tradicional de colocação pronominal:

“A comissão informará ________ a lista final.”$ENUN25$),
(26, 29, $D26$media$D26$, $FONTE26$PAPIRO — LOTE03_PORTUGUES_AUTORAL — COLOC-05$FONTE26$, $ENUN26$Considerando-se a norma-padrão tradicional cobrada em concursos, assinale a alternativa que reescreve corretamente a oração abaixo, substituindo “o documento” pelo pronome oblíquo átono adequado.

“Em frase isolada, sem qualquer fator de próclise, a direção entregará o documento ao candidato.”$ENUN26$),
(27, 29, $D27$media$D27$, $FONTE27$PAPIRO — LOTE03_PORTUGUES_AUTORAL — COLOC-06$FONTE27$, $ENUN27$Em uma ordem dirigida diretamente a um soldado, deve-se empregar o verbo apresentar no imperativo afirmativo, acompanhado do pronome oblíquo átono se. Considerando a norma-padrão tradicional, assinale a redação correta.$ENUN27$),
(28, 29, $D28$media$D28$, $FONTE28$PAPIRO — LOTE03_PORTUGUES_AUTORAL — COLOC-07$FONTE28$, $ENUN28$Considerando a norma-padrão tradicional e mantendo o verbo no pretérito perfeito do indicativo, assinale a alternativa correta quanto à colocação do pronome oblíquo átono.$ENUN28$);

create temporary table _lote_explicacoes (ordem int primary key, explicacao text) on commit drop;

insert into _lote_explicacoes (ordem, explicacao) values
(1, $EXPL1$Primeiramente, delimitam-se as orações: “a guarnição isolou o local” e “(a guarnição) registrou os dados das testemunhas”. Cada uma possui estrutura verbal própria e não exerce função sintática em relação à outra, o que caracteriza coordenação. O conectivo “e”, no contexto, soma o segundo procedimento ao primeiro; por isso, a relação é de coordenação sindética aditiva.

As alternativas B e C atribuem sentidos de oposição e de obstáculo, inexistentes no período. A alternativa D transforma a soma de ações em consequência necessária, o que não é indicado pelo contexto. A alternativa E erra ao afirmar dependência sintática entre as orações.

FUNDAMENTO: Orações coordenadas são sintaticamente independentes. Na coordenação sindética aditiva, conectivos como “e” ligam orações e exprimem, no contexto, ideia de adição ou soma.$EXPL1$),
(2, $EXPL2$A afirmativa I está correta porque as duas orações têm autonomia sintática: “O rádio da viatura estava inoperante” e “a equipe utilizou o canal de reserva”. Há, portanto, coordenação.

A afirmativa II também está correta. O emprego de “portanto” apresenta a utilização do canal de reserva como conclusão decorrente da inoperância do rádio.

A afirmativa III está incorreta: o conectivo não justifica a inoperância do rádio. Ao contrário, a inoperância é a premissa, e o uso do canal de reserva é o fato concluído a partir dela. Assim, a alternativa C é a correta.

FUNDAMENTO: Na coordenação sindética conclusiva, conectivos como “logo”, “portanto”, “por conseguinte” e “assim” introduzem uma oração que expressa conclusão em relação ao enunciado anterior, sem dependência sintática entre as orações.$EXPL2$),
(3, $EXPL3$As três afirmativas estão corretas. Em I, “porque a área apresenta risco” explica e justifica a recomendação “Não se aproxime”; em III, “que a área está isolada” justifica a ordem “Mantenha distância”. Em ambos os casos, há coordenação sindética explicativa: as orações mantêm independência sintática, embora tenham relação semântica de explicação.

Em II, diferentemente, “Porque a área apresentava risco” exprime a causa do bloqueio e funciona como oração subordinada adverbial causal em relação a “o acesso foi bloqueado”. Portanto, não basta reconhecer a palavra “porque”: a classificação decorre da relação sintática e de sentido estabelecida no período. As alternativas A a D estão incorretas porque deixam de considerar uma ou mais afirmativas verdadeiras.

FUNDAMENTO: Orações coordenadas sindéticas explicativas apresentam justificativa ou explicação para uma declaração, ordem ou recomendação anterior. Orações subordinadas adverbiais causais exprimem a causa do fato indicado na oração principal. Um mesmo conectivo pode participar de classificações distintas conforme a estrutura e o sentido do período.$EXPL3$),
(4, $EXPL4$Todas as afirmativas estão corretas. Em I, a diminuição da visibilidade é a causa da redução da velocidade; em III, é a causa do adiamento da operação. Por isso, as respectivas orações são subordinadas adverbiais causais.

Em II, a diminuição da visibilidade poderia, em princípio, dificultar ou impedir o deslocamento, mas a equipe seguiu para o local. Essa quebra de expectativa caracteriza a relação concessiva, e não causal. Logo, a análise deve recair sobre o sentido concreto: a causa explica por que o fato principal ocorreu; a concessão introduz uma ressalva ou obstáculo que não impede esse fato. As alternativas A a D estão incorretas por excluírem afirmativas verdadeiras.

FUNDAMENTO: A oração subordinada adverbial causal indica o motivo ou a causa da ocorrência expressa na oração principal. A oração subordinada adverbial concessiva exprime um fato que poderia contrariar a realização da oração principal, mas não a impede.$EXPL4$),
(5, $EXPL5$A oração “Caso o efetivo seja convocado” depende da oração principal “os policiais deverão apresentar-se no horário determinado” e apresenta uma condição para a realização do fato nela expresso. Por isso, é subordinada adverbial condicional. O conectivo “caso” é uma pista importante desse valor condicional. A alternativa A está errada porque não há coordenação nem oposição; a C confunde condição com tempo; a D atribui valor de causa à oração; e a E classifica indevidamente a oração como substantiva.

FUNDAMENTO: A oração subordinada adverbial condicional expressa uma condição ou hipótese sob a qual se considera a ocorrência do fato enunciado na oração principal, sendo frequentemente introduzida por conectivos como 'se', 'caso' e 'contanto que'.$EXPL5$),
(6, $EXPL6$A oração introduzida por “de que” está ligada ao nome “convicção”, presente na expressão “a convicção de que...”. Ela completa o sentido desse nome abstrato e, por isso, classifica-se como oração subordinada substantiva completiva nominal. Não é subjetiva, pois não exerce o papel de sujeito de uma oração principal; não é objetiva direta ou indireta, pois não completa diretamente um verbo; e não é predicativa, pois não funciona como predicativo do sujeito após verbo de ligação.

FUNDAMENTO: A oração subordinada substantiva completiva nominal completa o sentido de um nome — substantivo, adjetivo ou advérbio — da oração principal, frequentemente sendo introduzida por preposição exigida pela construção nominal.$EXPL6$),
(7, $EXPL7$A oração "que apresentaram a documentação completa" caracteriza o antecedente "os candidatos" e seleciona, entre todos eles, apenas aqueles que cumpriram essa condição. Por isso, é uma oração subordinada adjetiva restritiva. A alternativa A está incorreta porque uma explicativa apenas acrescentaria uma informação sobre a totalidade dos candidatos, sem delimitar o grupo. As alternativas C e D atribuem à oração funções que ela não exerce, e a letra E é incorreta porque não há coordenação nem oposição entre orações.

FUNDAMENTO: A oração subordinada adjetiva restritiva delimita ou especifica o sentido do antecedente; a explicativa apresenta uma informação acessória sobre um antecedente já tomado em sua totalidade.$EXPL7$),
(8, $EXPL8$Em A, a vírgula separa adequadamente a oração adverbial deslocada para o início do período (“Quando receber a ordem”) da oração principal (“a guarnição iniciará o deslocamento”). Em B, falta essa vírgula. Em C, as vírgulas separam indevidamente elementos internos da oração inicial. Em D e E, a vírgula separa inadequadamente o sujeito “a guarnição” de seu verbo “iniciará”, sem haver termo intercalado que justifique esse isolamento.

FUNDAMENTO: Quando uma oração adverbial é antecipada e vem antes da oração principal, emprega-se vírgula para marcar a separação entre as duas estruturas oracionais.$EXPL8$),
(9, $EXPL9$Na alternativa C, a oração adverbial concessiva “embora o responsável tenha informado que a vistoria terminara” está intercalada entre o sujeito “A equipe” e o verbo principal “permaneceu”. Por isso, deve ser isolada por duas vírgulas: “A equipe, embora o responsável tenha informado que a vistoria terminara, permaneceu no local...”. A vírgula após “equipe” abre o isolamento, mas falta a vírgula que o fecha antes de “permaneceu”.

Em A e E, as orações adverbiais estão deslocadas para o início do período e são separadas da oração principal por vírgula. Em B, a oração adverbial está intercalada e aparece corretamente entre duas vírgulas. Em D, a oração causal vem após a oração principal, sem deslocamento, e a ausência de vírgula não configura erro.

FUNDAMENTO: Orações adverbiais deslocadas para o início do período ou intercaladas na oração principal são normalmente delimitadas por vírgula. Quando intercaladas, exigem marca de abertura e de fechamento, pois constituem um segmento inserido entre termos da oração principal.$EXPL9$),
(10, $EXPL10$A alternativa C está correta porque a oração “que já havia concluído o registro preliminar” é explicativa e está no interior do período. Assim, ela deve ser isolada por uma vírgula de abertura, antes de “que”, e outra de fechamento, após “preliminar”.

Em A, a ausência das vírgulas faz com que a oração assuma valor restritivo. Em B, há somente a vírgula de abertura; falta a de fechamento antes do verbo “encaminhou”. Em D, há apenas a vírgula de fechamento, sem a abertura. Em E, a vírgula após “atendimento” separa inadequadamente termos que integram o mesmo sintagma nominal e não isola corretamente a oração explicativa.

FUNDAMENTO: A oração adjetiva explicativa acrescenta uma informação sobre um referente já identificado. Quando aparece no meio do período, é delimitada por vírgula de abertura e vírgula de fechamento; diferentemente, a oração adjetiva restritiva não é isolada por vírgulas.$EXPL10$),
(11, $EXPL11$Na frase I, “que entregaram a documentação completa” seleciona, entre todos os candidatos, aqueles que cumpriram essa condição; por isso, não recebe vírgulas. Na frase II, o trecho entre vírgulas acrescenta uma explicação sobre “os candidatos”, sem delimitá-los: entende-se que a informação é apresentada como referente ao conjunto já mencionado. Assim, a alternativa B está correta. As alternativas A e E invertem os efeitos de sentido; C desconsidera que a pontuação altera a delimitação do referente; e D erra ao afirmar que toda oração introduzida por “que” deve ser isolada por vírgulas.

FUNDAMENTO: A oração adjetiva restritiva não é isolada por vírgulas, pois restringe ou delimita o referente do termo antecedente. A oração adjetiva explicativa é isolada por vírgulas, pois veicula informação adicional sobre um referente já identificado.$EXPL11$),
(12, $EXPL12$Em B, o sujeito é “A atuação coordenada das equipes”, e o verbo é “reduziu”. A vírgula foi inserida entre esses dois termos diretamente ligados, sem haver elemento deslocado ou intercalado que justificasse o sinal. A redação adequada é: “A atuação coordenada das equipes reduziu o tempo de resposta.” Nas demais alternativas, sujeito e verbo permanecem unidos, sem vírgula indevida.

FUNDAMENTO: Em construção simples, não se emprega vírgula para separar o sujeito de seu verbo. A pontuação pode isolar elementos adicionais em outros contextos, mas não deve romper, sem justificativa estrutural, a ligação direta entre esses termos.$EXPL12$),
(13, $EXPL13$Estão corretas as afirmativas I, II e III. Em I, a vírgula rompe indevidamente a ligação entre o verbo “entregou” e o complemento direto “o relatório”. Em II e III, as vírgulas não separam termos essenciais de modo indevido: elas delimitam adjuntos adverbiais intercalados (“após a conferência dos dados” e “ao final da reunião”), que constituem informações adicionais inseridas na estrutura principal. A afirmativa IV está incorreta, pois “informações complementares” é complemento direto de “solicitou”; não há termo intercalado que justifique a vírgula entre o verbo e esse complemento.

FUNDAMENTO: A vírgula pode delimitar um termo acessório ou uma oração intercalada. Entretanto, não deve separar diretamente o verbo de seu complemento, salvo quando houver, entre eles, um termo legitimamente isolado por vírgulas.$EXPL13$),
(14, $EXPL14$As frases I, II e IV estão corretamente pontuadas. Em I, a oração adverbial temporal foi deslocada para o início do período e vem seguida de vírgula. Em II e IV, as orações adverbiais estão intercaladas na oração principal e, por isso, são delimitadas por vírgulas de abertura e de fechamento. Na frase III, a oração condicional inicial “Caso a visibilidade diminua durante o deslocamento da equipe” deveria ser separada da oração principal por vírgula: “Caso a visibilidade diminua durante o deslocamento da equipe, a patrulha reduzirá a velocidade.”

FUNDAMENTO: Orações adverbiais antepostas à oração principal são normalmente separadas por vírgula, especialmente quando sua extensão e organização sintático-discursiva evidenciam o deslocamento. Quando intercaladas, devem ser isoladas por vírgulas.$EXPL14$),
(15, $EXPL15$Na frase, "peso" designa uma característica física e mensurável do colete de proteção: sua massa. A leitura literal é plenamente possível na situação descrita, pois conferir o peso de um equipamento é uma ação concreta. As alternativas B, C e E atribuem a "peso" os sentidos figurados de preocupação, responsabilidade ou carga emocional; a alternativa D propõe valor simbólico. Nenhuma dessas leituras é indicada pelo contexto.

FUNDAMENTO: Há emprego denotativo quando a palavra se refere diretamente a um elemento ou característica concreta da situação, sem efeito figurado relevante. A classificação decorre do uso da palavra na frase.$EXPL15$),
(16, $EXPL16$A expressão "foi um farol" não informa que o relatório seja literalmente um aparelho de iluminação. No contexto, "farol" assume valor figurado de orientação e referência, pois o documento auxiliou a conduzir a revisão dos procedimentos. As alternativas B, C e D dependem de uma leitura literal ligada à luz ou a sinalização, incompatível com "relatório"; a alternativa E introduz uma circunstância não mencionada na frase.

FUNDAMENTO: Há emprego conotativo quando uma palavra adquire, no contexto, valor associativo ou figurado além de sua referência literal imediata. A interpretação deve considerar a plausibilidade da leitura literal na frase.$EXPL16$),
(17, $EXPL17$Na frase I, “linha” refere-se diretamente a uma marcação ou limite físico de segurança, o que caracteriza emprego denotativo. Na frase II, “linha de investigação” não corresponde a uma linha material: a expressão indica uma orientação, um rumo ou uma abordagem investigativa, em emprego conotativo. As alternativas A e D erram ao atribuir a mesma classificação às duas ocorrências; B inverte as classificações; e E desconsidera que o sentido de uma palavra depende do contexto em que é usada.

FUNDAMENTO: A denotação ocorre quando o termo é empregado com referência direta e literal; a conotação ocorre quando, no contexto, o termo assume valor figurado ou associativo. A classificação deve considerar a frase inteira.$EXPL17$),
(18, $EXPL18$Em I, “grito” é empregado de modo figurado para caracterizar o som intenso da sirene, pois uma sirene não grita literalmente. Em III, “pesou” atribui ao silêncio uma sensação de opressão ou desconforto, e não um peso físico: há conotação. Já em II, “colete” designa diretamente o objeto guardado; em IV, “corrente” refere-se literalmente à peça da motocicleta. Portanto, somente I e III apresentam emprego conotativo. As alternativas que incluem II ou IV estão erradas porque esses termos são usados referencialmente, em sentido literal.

FUNDAMENTO: A classificação decorre do uso concreto da palavra na frase: há denotação quando o termo se refere diretamente ao elemento da situação e conotação quando adquire valor figurado, associativo ou expressivo.$EXPL18$),
(19, $EXPL19$Em II, a notícia não se desloca literalmente pelo ar: “voou” comunica que ela se espalhou com rapidez, em sentido figurado. Em III, “gosto amargo” não indica uma sensação física produzida pela decisão, mas uma impressão desagradável ou frustrante; também há conotação. Em I e IV, “lanterna” e “prédio” designam diretamente objetos da situação, com emprego denotativo. A alternativa C constitui uma armadilha: embora seja possível estudar figuras de linguagem em outro conteúdo, não é necessário atribuir rótulos técnicos para reconhecer aqui o contraste entre literal e figurado. A alternativa D ignora o valor figurado de “gosto amargo”, e a E confunde a possibilidade abstrata de mudança de sentido com o emprego efetivo nas frases dadas.

FUNDAMENTO: O reconhecimento de conotação depende de verificar se a leitura literal é plausível na situação enunciada e de identificar o valor associativo ou expressivo produzido pela expressão, sem necessidade de nomear figuras de linguagem.$EXPL19$),
(20, $EXPL20$A classificação incorreta está na alternativa E. Em “quebrou o recorde”, o verbo “quebrou” não indica a ruptura física de um objeto: significa superar uma marca anterior, em sentido figurado; portanto, seu emprego é conotativo. Nas demais alternativas, as classificações estão adequadas: “correia” e “frasco” designam objetos concretos no contexto, enquanto “semente de esperança” e “ferida na relação” apresentam valores figurados.

FUNDAMENTO: A denotação ocorre quando o termo é empregado com referência direta à situação descrita. A conotação ocorre quando o contexto atribui ao termo valor figurado, associativo ou expressivo. A classificação depende do uso concreto na frase.$EXPL20$),
(21, $EXPL21$Na frase I, “raiz” designa literalmente a parte da árvore que fica, em geral, sob o solo; trata-se de emprego denotativo. Na frase II, “raiz” não se refere a uma parte vegetal, mas à causa ou origem do desentendimento; trata-se de emprego conotativo. Assim, a alternativa B é a correta.

FUNDAMENTO: Uma mesma palavra pode assumir emprego denotativo em determinado contexto e conotativo em outro. A análise deve considerar se a referência literal é semanticamente plausível na situação apresentada.$EXPL21$),
(22, $EXPL22$A forma correta é “O servidor que me encaminhará o comunicado...”. O pronome relativo “que”, posicionado antes do verbo “encaminhará”, exerce atração proclítica e exige a colocação do pronome átono antes do verbo. Embora o verbo esteja no futuro do presente, a próclise prevalece sobre a mesóclise quando há elemento atrativo. Em B, a mesóclise (“encaminhar-me-á”) seria possível apenas sem fator de próclise; em C, a ênclise também desrespeita a atração do relativo. D altera o tempo verbal, e E troca o pronome e modifica o sentido da frase.

FUNDAMENTO: Na norma-padrão tradicional, o pronome relativo antes do verbo constitui fator de próclise. Havendo esse elemento atrativo, o pronome oblíquo átono deve anteceder o verbo, inclusive quando este está no futuro sintético.$EXPL22$),
(23, $EXPL23$Em “Ali me aguardavam os policiais responsáveis pela escolta”, o advérbio “ali”, empregado imediatamente antes do verbo e sem pausa, atua como fator de atração para o pronome átono. Por isso, a próclise é a colocação exigida na norma-padrão tradicional: “ali me aguardavam”.

A alternativa B traz ênclise (“aguardavam-me”), inadequada nesse contexto, pois ignora a atração exercida pelo advérbio sem pausa. As alternativas C, D e E, além de não preservarem o pretérito imperfeito solicitado, empregam formas verbais de futuro ou de futuro do pretérito. Caso houvesse pausa após o advérbio — por exemplo, “Ali, ...” —, ele não funcionaria, nessa análise tradicional, como atrativo obrigatório da próclise.

FUNDAMENTO: Advérbio anteposto ao verbo, sem pausa marcada por vírgula, constitui fator de atração proclítica. Assim, o pronome átono deve anteceder o verbo.$EXPL23$),
(24, $EXPL24$A forma correta é “O setor nunca lhe enviará a confirmação da inscrição”. O advérbio de negação “nunca” é fator de atração proclítica e exige que o pronome átono anteceda o verbo: “nunca lhe enviará”.

Embora “enviará” esteja no futuro do presente e a mesóclise seja prevista pela norma tradicional em contextos sem atrativo, a presença de “nunca” faz a próclise prevalecer. Por isso, B (“nunca enviar-lhe-á”) está incorreta. A alternativa C também coloca o pronome após o verbo, contrariando a atração negativa. D e E empregam o futuro do pretérito (“enviaria”), alterando o tempo verbal do enunciado.

FUNDAMENTO: Palavras de sentido negativo, como “nunca”, atraem o pronome oblíquo átono para antes do verbo. Essa próclise prevalece mesmo quando o verbo está no futuro sintético, contexto em que haveria mesóclise na ausência de elemento atrativo.$EXPL24$),
(25, $EXPL25$A forma correta é “quando se divulgará a lista final”. A conjunção subordinativa “quando” introduz uma oração subordinada e atua, nesse contexto, como fator de próclise, atraindo o pronome “se” para antes do verbo. Embora “divulgará” esteja no futuro do presente, a presença do atrativo proclítico faz prevalecer a próclise. A alternativa A apresenta mesóclise (“divulgar-se-á”), cabível na tradição normativa apenas se não houvesse fator de próclise. A alternativa C emprega ênclise indevida diante do atrativo. As alternativas D e E repetem indevidamente o pronome.

FUNDAMENTO: Em oração subordinada introduzida por conjunção subordinativa, o pronome oblíquo átono é colocado antes do verbo. Havendo fator de próclise, essa posição prevalece mesmo quando o verbo está no futuro sintético.$EXPL25$),
(26, $EXPL26$A alternativa correta é “A direção entregá-lo-á ao candidato”. O verbo “entregará” está no futuro do presente do indicativo, em forma sintética, e a frase não apresenta elemento que atraia o pronome para antes do verbo. Na norma-padrão tradicional, essa combinação exige mesóclise: entregar + lo + á = “entregá-lo-á”. A alternativa A usa próclise sem fator que a justifique no padrão tradicional. A alternativa D emprega ênclise com futuro sintético, posição não prevista nesse caso. A alternativa C troca o pronome acusativo “o”, referente a “o documento”, por “lhe”, que tem valor dativo. A alternativa E altera o sentido da oração. Na língua corrente, é frequente que os falantes evitem a mesóclise, mas a forma esperada no registro tradicional de concurso é a mesoclítica.

FUNDAMENTO: Na ausência de fator de próclise, o pronome oblíquo átono deve ocorrer em mesóclise com verbos no futuro do presente ou no futuro do pretérito em forma sintética. Com pronome “o”, a forma “entregará” resulta em “entregá-lo-á”.$EXPL26$),
(27, $EXPL27$A alternativa A está correta. Na oração iniciada pelo imperativo afirmativo “Apresente”, não há elemento que atraia o pronome para antes do verbo, nem se trata de futuro sintético. Na norma-padrão tradicional, emprega-se, nesse contexto, a ênclise: “Apresente-se”.

Em B, ocorre próclise no início da oração (“Se apresente”), construção frequente no português brasileiro falado, mas não é a forma preferida pela convenção normativa tradicional de concurso nesse contexto. C emprega infinitivo, e não o imperativo afirmativo exigido. D usa futuro do presente com mesóclise, alterando o modo e o sentido da ordem. E combina indevidamente a forma verbal do imperativo com a terminação própria de futuro.

FUNDAMENTO: No imperativo afirmativo sem elemento proclítico, a colocação tradicional do pronome oblíquo átono é enclítica, isto é, posterior ao verbo, com hífen: “apresente-se”.$EXPL27$),
(28, $EXPL28$A alternativa A está correta. O termo “isso” é pronome demonstrativo e, antes do verbo, exerce atração proclítica na norma-padrão tradicional. Por isso, o pronome oblíquo deve anteceder o verbo: “Isso me preocupou profundamente”.

Em B, a ênclise é inadequada porque há o pronome demonstrativo “isso” atraindo o pronome átono. C emprega mesóclise e, além disso, altera o tempo verbal para o futuro. D também altera o tempo verbal para o futuro, não correspondendo à frase no pretérito. Em E, além de contrariar a próclise exigida pelo demonstrativo, “lhe” não substitui adequadamente o complemento direto representado por “me” em “preocupar alguém”.

FUNDAMENTO: Pronome demonstrativo anteposto ao verbo pode atuar como fator de atração proclítica. Na estrutura “Isso me preocupou”, “isso” atrai o pronome átono “me” para antes do verbo.$EXPL28$);

create temporary table _lote_alternativas (ordem int, letra_ordem int, texto text, correta boolean) on commit drop;

insert into _lote_alternativas (ordem, letra_ordem, texto, correta) values
(1, 1, $ALT1_0$Há coordenação sindética aditiva, pois as duas orações são sintaticamente independentes, e o conectivo acrescenta uma ação à outra.$ALT1_0$, true),
(1, 2, $ALT1_1$A segunda oração expressa uma ação que se opõe à primeira.$ALT1_1$, false),
(1, 3, $ALT1_2$A segunda oração apresenta um obstáculo que impede a realização da primeira.$ALT1_2$, false),
(1, 4, $ALT1_3$O conectivo indica que o registro dos dados é consequência necessária do isolamento do local.$ALT1_3$, false),
(1, 5, $ALT1_4$A segunda oração funciona como complemento sintaticamente exigido pela primeira.$ALT1_4$, false),
(2, 1, $ALT2_0$Apenas I.$ALT2_0$, false),
(2, 2, $ALT2_1$Apenas II.$ALT2_1$, false),
(2, 3, $ALT2_2$Apenas I e II.$ALT2_2$, true),
(2, 4, $ALT2_3$Apenas I e III.$ALT2_3$, false),
(2, 5, $ALT2_4$I, II e III.$ALT2_4$, false),
(3, 1, $ALT3_0$Apenas I.$ALT3_0$, false),
(3, 2, $ALT3_1$Apenas II.$ALT3_1$, false),
(3, 3, $ALT3_2$Apenas I e II.$ALT3_2$, false),
(3, 4, $ALT3_3$Apenas II e III.$ALT3_3$, false),
(3, 5, $ALT3_4$I, II e III.$ALT3_4$, true),
(4, 1, $ALT4_0$Apenas I.$ALT4_0$, false),
(4, 2, $ALT4_1$Apenas II.$ALT4_1$, false),
(4, 3, $ALT4_2$Apenas I e II.$ALT4_2$, false),
(4, 4, $ALT4_3$Apenas II e III.$ALT4_3$, false),
(4, 5, $ALT4_4$I, II e III.$ALT4_4$, true),
(5, 1, $ALT5_0$É uma oração coordenada sindética adversativa, pois estabelece contraste com a oração seguinte.$ALT5_0$, false),
(5, 2, $ALT5_1$É uma oração subordinada adverbial condicional, pois exprime a condição sob a qual os policiais deverão apresentar-se no horário determinado.$ALT5_1$, true),
(5, 3, $ALT5_2$É uma oração subordinada adverbial temporal, pois informa o momento em que os policiais deverão apresentar-se.$ALT5_2$, false),
(5, 4, $ALT5_3$É uma oração subordinada adverbial causal, pois explica a razão da convocação do efetivo.$ALT5_3$, false),
(5, 5, $ALT5_4$É uma oração subordinada substantiva objetiva direta, pois completa o sentido do verbo “convocado”.$ALT5_4$, false),
(6, 1, $ALT6_0$subjetiva.$ALT6_0$, false),
(6, 2, $ALT6_1$objetiva direta.$ALT6_1$, false),
(6, 3, $ALT6_2$objetiva indireta.$ALT6_2$, false),
(6, 4, $ALT6_3$completiva nominal.$ALT6_3$, true),
(6, 5, $ALT6_4$predicativa.$ALT6_4$, false),
(7, 1, $ALT7_0$oração subordinada adjetiva explicativa, pois acrescenta uma informação sobre todos os candidatos.$ALT7_0$, false),
(7, 2, $ALT7_1$oração subordinada adjetiva restritiva, pois delimita o grupo de candidatos que seguiu para a etapa seguinte.$ALT7_1$, true),
(7, 3, $ALT7_2$oração subordinada adverbial temporal, pois indica o momento em que os candidatos seguiram.$ALT7_2$, false),
(7, 4, $ALT7_3$oração subordinada substantiva objetiva direta, pois completa o sentido do verbo "seguiram".$ALT7_3$, false),
(7, 5, $ALT7_4$oração coordenada sindética adversativa, pois contrapõe dois fatos.$ALT7_4$, false),
(8, 1, $ALT8_0$Quando receber a ordem, a guarnição iniciará o deslocamento.$ALT8_0$, true),
(8, 2, $ALT8_1$Quando receber a ordem a guarnição iniciará o deslocamento.$ALT8_1$, false),
(8, 3, $ALT8_2$Quando, receber a ordem, a guarnição iniciará o deslocamento.$ALT8_2$, false),
(8, 4, $ALT8_3$Quando receber a ordem, a guarnição, iniciará o deslocamento.$ALT8_3$, false),
(8, 5, $ALT8_4$Quando receber a ordem a guarnição, iniciará o deslocamento.$ALT8_4$, false),
(9, 1, $ALT9_0$Quando a central comunicou que o acesso fora liberado, a equipe prosseguiu com o deslocamento e informou ao comandante que mudaria o itinerário.$ALT9_0$, false),
(9, 2, $ALT9_1$A equipe, quando recebeu confirmação de que todos os moradores haviam saído, iniciou a vistoria e registrou as informações repassadas.$ALT9_1$, false),
(9, 3, $ALT9_2$A equipe, embora o responsável tenha informado que a vistoria terminara permaneceu no local até que recebesse nova orientação.$ALT9_2$, true),
(9, 4, $ALT9_3$A equipe permaneceu no local porque o superior determinou que o perímetro fosse preservado até a chegada do reforço.$ALT9_3$, false),
(9, 5, $ALT9_4$Se o superior determinar que a área seja isolada, os policiais manterão o bloqueio até que o reforço chegue.$ALT9_4$, false),
(10, 1, $ALT10_0$A equipe de atendimento da unidade que já havia concluído o registro preliminar encaminhou o comunicado ao setor responsável.$ALT10_0$, false),
(10, 2, $ALT10_1$A equipe de atendimento da unidade, que já havia concluído o registro preliminar encaminhou o comunicado ao setor responsável.$ALT10_1$, false),
(10, 3, $ALT10_2$A equipe de atendimento da unidade, que já havia concluído o registro preliminar, encaminhou o comunicado ao setor responsável.$ALT10_2$, true),
(10, 4, $ALT10_3$A equipe de atendimento da unidade que já havia concluído o registro preliminar, encaminhou o comunicado ao setor responsável.$ALT10_3$, false),
(10, 5, $ALT10_4$A equipe de atendimento, da unidade que já havia concluído o registro preliminar, encaminhou o comunicado ao setor responsável.$ALT10_4$, false),
(11, 1, $ALT11_0$Em I, todos os candidatos entregaram a documentação completa; em II, apenas parte deles a entregou.$ALT11_0$, false),
(11, 2, $ALT11_1$Em I, a ausência de vírgulas delimita o grupo de candidatos que seguiu para a etapa seguinte; em II, as vírgulas apresentam a entrega da documentação como informação adicional sobre os candidatos.$ALT11_1$, true),
(11, 3, $ALT11_2$Em I e em II, a pontuação não altera o sentido, pois as duas frases informam exatamente o mesmo.$ALT11_2$, false),
(11, 4, $ALT11_3$Em I, as vírgulas foram apenas omitidas; em II, seu emprego é obrigatório porque toda oração iniciada por “que” deve ser isolada.$ALT11_3$, false),
(11, 5, $ALT11_4$Em II, as vírgulas indicam que somente os candidatos que entregaram a documentação completa seguiram para a etapa seguinte.$ALT11_4$, false),
(12, 1, $ALT12_0$O planejamento das operações exige atenção permanente.$ALT12_0$, false),
(12, 2, $ALT12_1$A atuação coordenada das equipes, reduziu o tempo de resposta.$ALT12_1$, true),
(12, 3, $ALT12_2$Os servidores concluíram o atendimento ao público.$ALT12_2$, false),
(12, 4, $ALT12_3$A comunicação eficiente favorece decisões mais seguras.$ALT12_3$, false),
(12, 5, $ALT12_4$Os relatórios da ocorrência registraram os fatos apurados.$ALT12_4$, false),
(13, 1, $ALT13_0$Apenas I e II.$ALT13_0$, false),
(13, 2, $ALT13_1$Apenas I e IV.$ALT13_1$, false),
(13, 3, $ALT13_2$Apenas II e III.$ALT13_2$, false),
(13, 4, $ALT13_3$Apenas I, II e III.$ALT13_3$, true),
(13, 5, $ALT13_4$Apenas II, III e IV.$ALT13_4$, false),
(14, 1, $ALT14_0$Apenas I e II.$ALT14_0$, false),
(14, 2, $ALT14_1$Apenas I e III.$ALT14_1$, false),
(14, 3, $ALT14_2$Apenas II e IV.$ALT14_2$, false),
(14, 4, $ALT14_3$Apenas I, II e IV.$ALT14_3$, true),
(14, 5, $ALT14_4$I, II, III e IV.$ALT14_4$, false),
(15, 1, $ALT15_0$à massa física do colete, passível de medição.$ALT15_0$, true),
(15, 2, $ALT15_1$à preocupação causada pelo uso obrigatório do equipamento.$ALT15_1$, false),
(15, 3, $ALT15_2$à responsabilidade atribuída ao soldado durante a operação.$ALT15_2$, false),
(15, 4, $ALT15_3$à importância simbólica do colete para a corporação.$ALT15_3$, false),
(15, 5, $ALT15_4$ao desgaste emocional provocado pela atividade policial.$ALT15_4$, false),
(16, 1, $ALT16_0$orientou e serviu de referência para a revisão dos procedimentos.$ALT16_0$, true),
(16, 2, $ALT16_1$era um equipamento luminoso instalado no prédio da corregedoria.$ALT16_1$, false),
(16, 3, $ALT16_2$precisava ser acionado para alertar os servidores.$ALT16_2$, false),
(16, 4, $ALT16_3$iluminava fisicamente os documentos analisados pela equipe.$ALT16_3$, false),
(16, 5, $ALT16_4$foi produzido durante uma operação realizada no litoral.$ALT16_4$, false),
(17, 1, $ALT17_0$Em I e em II, “linha” é empregada denotativamente, pois designa algo delimitado em ambos os contextos.$ALT17_0$, false),
(17, 2, $ALT17_1$Em I, “linha” é empregada conotativamente; em II, denotativamente.$ALT17_1$, false),
(17, 3, $ALT17_2$Em I, “linha” é empregada denotativamente; em II, conotativamente.$ALT17_2$, true),
(17, 4, $ALT17_3$Em I e em II, “linha” é empregada conotativamente, pois possui mais de um sentido possível.$ALT17_3$, false),
(17, 5, $ALT17_4$Não é possível classificar os empregos, pois uma mesma palavra deve conservar o mesmo sentido em qualquer frase.$ALT17_4$, false),
(18, 1, $ALT18_0$Apenas I e II.$ALT18_0$, false),
(18, 2, $ALT18_1$Apenas I e III.$ALT18_1$, true),
(18, 3, $ALT18_2$Apenas II e IV.$ALT18_2$, false),
(18, 4, $ALT18_3$Apenas II, III e IV.$ALT18_3$, false),
(18, 5, $ALT18_4$I, II, III e IV.$ALT18_4$, false),
(19, 1, $ALT19_0$Apenas I e IV apresentam emprego conotativo.$ALT19_0$, false),
(19, 2, $ALT19_1$Apenas II e III apresentam emprego conotativo; para concluir isso, basta observar o sentido figurado assumido pelas expressões no contexto.$ALT19_1$, true),
(19, 3, $ALT19_2$Apenas II e III apresentam emprego conotativo, mas essa conclusão só é possível após nomear tecnicamente II como metáfora e III como sinestesia.$ALT19_2$, false),
(19, 4, $ALT19_3$Apenas II apresenta emprego conotativo, pois notícias não podem voar; em III, “gosto amargo” é necessariamente literal.$ALT19_3$, false),
(19, 5, $ALT19_4$I, II, III e IV apresentam emprego conotativo, pois todas as palavras podem adquirir sentidos diferentes em outros contextos.$ALT19_4$, false),
(20, 1, $ALT20_0$O mecânico substituiu a **correia** desgastada do motor. — emprego denotativo.$ALT20_0$, false),
(20, 2, $ALT20_1$Após a conversa, uma **semente** de esperança permaneceu no grupo. — emprego conotativo.$ALT20_1$, false),
(20, 3, $ALT20_2$A pesquisadora guardou as amostras em um **frasco** identificado. — emprego denotativo.$ALT20_2$, false),
(20, 4, $ALT20_3$Aquela decisão abriu uma **ferida** na relação entre os irmãos. — emprego conotativo.$ALT20_3$, false),
(20, 5, $ALT20_4$O nadador **quebrou** o recorde estadual da prova. — emprego denotativo.$ALT20_4$, true),
(21, 1, $ALT21_0$Em I e em II, “raiz” foi empregada em sentido denotativo.$ALT21_0$, false),
(21, 2, $ALT21_1$Em I, “raiz” foi empregada em sentido denotativo; em II, em sentido conotativo.$ALT21_1$, true),
(21, 3, $ALT21_2$Em I, “raiz” foi empregada em sentido conotativo; em II, em sentido denotativo.$ALT21_2$, false),
(21, 4, $ALT21_3$Em I e em II, “raiz” foi empregada em sentido conotativo.$ALT21_3$, false),
(21, 5, $ALT21_4$Em ambas as frases, “raiz” não apresenta referência identificável no contexto.$ALT21_4$, false),
(22, 1, $ALT22_0$me encaminhará$ALT22_0$, true),
(22, 2, $ALT22_1$encaminhar-me-á$ALT22_1$, false),
(22, 3, $ALT22_2$encaminhará-me$ALT22_2$, false),
(22, 4, $ALT22_3$me encaminharia$ALT22_3$, false),
(22, 5, $ALT22_4$se encaminhará$ALT22_4$, false),
(23, 1, $ALT23_0$me aguardavam$ALT23_0$, true),
(23, 2, $ALT23_1$aguardavam-me$ALT23_1$, false),
(23, 3, $ALT23_2$me aguardarão$ALT23_2$, false),
(23, 4, $ALT23_3$aguardar-me-ão$ALT23_3$, false),
(23, 5, $ALT23_4$aguardariam-me$ALT23_4$, false),
(24, 1, $ALT24_0$lhe enviará$ALT24_0$, true),
(24, 2, $ALT24_1$enviar-lhe-á$ALT24_1$, false),
(24, 3, $ALT24_2$enviará-lhe$ALT24_2$, false),
(24, 4, $ALT24_3$lhe enviaria$ALT24_3$, false),
(24, 5, $ALT24_4$enviar-lhe-ia$ALT24_4$, false),
(25, 1, $ALT25_0$quando divulgar-se-á$ALT25_0$, false),
(25, 2, $ALT25_1$quando se divulgará$ALT25_1$, true),
(25, 3, $ALT25_2$quando divulgará-se$ALT25_2$, false),
(25, 4, $ALT25_3$quando se divulgar-se-á$ALT25_3$, false),
(25, 5, $ALT25_4$quando se divulgará-se$ALT25_4$, false),
(26, 1, $ALT26_0$A direção o entregará ao candidato.$ALT26_0$, false),
(26, 2, $ALT26_1$A direção entregá-lo-á ao candidato.$ALT26_1$, true),
(26, 3, $ALT26_2$A direção entregar-lhe-á ao candidato.$ALT26_2$, false),
(26, 4, $ALT26_3$A direção entregará-o ao candidato.$ALT26_3$, false),
(26, 5, $ALT26_4$A direção se entregará ao candidato.$ALT26_4$, false),
(27, 1, $ALT27_0$Apresente-se ao superior imediatamente.$ALT27_0$, true),
(27, 2, $ALT27_1$Se apresente ao superior imediatamente.$ALT27_1$, false),
(27, 3, $ALT27_2$Apresentar-se ao superior imediatamente.$ALT27_2$, false),
(27, 4, $ALT27_3$Apresentar-se-á ao superior imediatamente.$ALT27_3$, false),
(27, 5, $ALT27_4$Apresente-se-á ao superior imediatamente.$ALT27_4$, false),
(28, 1, $ALT28_0$Isso me preocupou profundamente.$ALT28_0$, true),
(28, 2, $ALT28_1$Isso preocupou-me profundamente.$ALT28_1$, false),
(28, 3, $ALT28_2$Isso preocupar-me-á profundamente.$ALT28_2$, false),
(28, 4, $ALT28_3$Isso me preocupará profundamente.$ALT28_3$, false),
(28, 5, $ALT28_4$Isso preocupou-lhe profundamente.$ALT28_4$, false);

create temporary table _unidades_ordem (ordem_min int, ordem_max int, unidade_pedagogica_id uuid) on commit drop;
insert into _unidades_ordem (ordem_min, ordem_max, unidade_pedagogica_id) values
(1, 7, 'bfeaf283-09fc-4f14-9d0c-41ff0db4eab7'::uuid),
(8, 14, 'dca4fe2e-50e9-41db-abeb-0ef6b388c5af'::uuid),
(15, 21, 'f1377f8b-348e-4da6-9713-e901ce5ea516'::uuid),
(22, 28, 'c03b4993-601a-4c1e-b24d-c9e09d01db84'::uuid);

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
  lower($DUP1$Leia o período a seguir.

“Durante a ocorrência, a guarnição isolou o local e registrou os dados das testemunhas.”

A análise correta da relação entre as orações do período é:$DUP1$),
  lower($DUP2$Leia o período a seguir.

“O rádio da viatura estava inoperante; portanto, a equipe utilizou o canal de reserva.”

Analise as afirmativas a respeito da relação entre as orações.

I. As orações são sintaticamente independentes, estabelecendo entre si uma relação de coordenação.

II. O conectivo “portanto” introduz uma conclusão decorrente da informação apresentada na oração anterior.

III. O conectivo “portanto” introduz uma justificativa para o fato de o rádio estar inoperante.

Quais afirmativas estão corretas?$DUP2$),
  lower($DUP3$Analise os períodos a seguir.

I. Não se aproxime, porque a área apresenta risco.
II. Porque a área apresentava risco, o acesso foi bloqueado.
III. Mantenha distância, que a área está isolada.

Considere as afirmativas a respeito da classificação das orações 'porque a área apresenta risco', 'Porque a área apresentava risco' e 'que a área está isolada', presentes, respectivamente, nos períodos I, II e III.

I. Em I e III, as orações introduzidas por “porque” e “que” são coordenadas sindéticas explicativas, pois justificam, respectivamente, a recomendação e a ordem expressas nas orações anteriores.
II. Em II, a oração introduzida por “Porque” é subordinada adverbial causal, pois indica a causa pela qual o acesso foi bloqueado.
III. A presença de “porque”, por si só, não determina a classificação da oração: é necessário verificar se ela explica uma enunciação independente ou se integra a estrutura da oração principal como circunstância de causa.

Quais estão corretas?$DUP3$),
  lower($DUP4$Analise os períodos a seguir.

I. Como a visibilidade diminuiu, a equipe reduziu a velocidade da viatura.
II. Embora a visibilidade tenha diminuído, a equipe seguiu para o local da ocorrência.
III. A operação foi adiada porque a visibilidade diminuiu.

Avalie as afirmativas.

I. As orações "Como a visibilidade diminuiu", em I, e "porque a visibilidade diminuiu", em III, são subordinadas adverbiais causais, pois apresentam a razão pela qual ocorreram, respectivamente, a redução da velocidade e o adiamento da operação.
II. A oração "Embora a visibilidade tenha diminuído", em II, é subordinada adverbial concessiva, porque apresenta uma circunstância que poderia dificultar o deslocamento, mas não impediu que a equipe seguisse para o local.
III. A diferença entre causa e concessão depende da relação lógica estabelecida: a causa explica a ocorrência do fato principal, enquanto a concessão apresenta um obstáculo que não impede sua realização.

Quais estão corretas?$DUP4$),
  lower($DUP5$Leia o período elaborado em contexto institucional:

“Caso o efetivo seja convocado, os policiais deverão apresentar-se no horário determinado.”

Assinale a alternativa correta acerca da oração destacada.$DUP5$),
  lower($DUP6$No período abaixo, a oração subordinada substantiva está destacada:

“A chefia manifestou a convicção de que a medida preventiva reduziria os riscos da operação.”

A oração “de que a medida preventiva reduziria os riscos da operação” classifica-se como subordinada substantiva$DUP6$),
  lower($DUP7$Leia a frase a seguir.

"Os candidatos que apresentaram a documentação completa seguiram para a etapa seguinte."

A oração "que apresentaram a documentação completa" é corretamente classificada como$DUP7$),
  lower($DUP8$Assinale a alternativa em que a pontuação está corretamente empregada.$DUP8$),
  lower($DUP9$Em relação ao emprego da vírgula em períodos com orações adverbiais deslocadas, assinale a alternativa em que a pontuação está INCORRETA.$DUP9$),
  lower($DUP10$No trecho abaixo, a oração introduzida por “que” tem valor explicativo, acrescentando uma informação sobre a totalidade da equipe de atendimento da unidade. Assinale a alternativa em que essa oração está corretamente isolada por vírgulas.

“A equipe de atendimento da unidade ___ já havia concluído o registro preliminar ___ encaminhou o comunicado ao setor responsável.”$DUP10$),
  lower($DUP11$Observe as duas redações a seguir.

I. Os candidatos que entregaram a documentação completa seguiram para a etapa seguinte.
II. Os candidatos, que entregaram a documentação completa, seguiram para a etapa seguinte.

Considerando o efeito de sentido produzido pela pontuação, assinale a alternativa correta.$DUP11$),
  lower($DUP12$Assinale a alternativa em que o emprego da vírgula está incorreto por separar indevidamente o sujeito de seu verbo.$DUP12$),
  lower($DUP13$Analise as afirmativas relativas ao emprego da vírgula.

I. Em “A guarnição entregou, o relatório ao superior”, a vírgula é inadequada, pois separa o verbo “entregou” de seu complemento direto.

II. Em “A guarnição entregou ao superior, após a conferência dos dados, o relatório”, as vírgulas isolam adequadamente o adjunto adverbial intercalado “após a conferência dos dados”.

III. Em “Os policiais receberam, ao final da reunião, as novas instruções”, as vírgulas isolam adequadamente o adjunto adverbial intercalado.

IV. Em “O superior solicitou, informações complementares”, a vírgula é adequada, pois separa o verbo de uma informação que o completa.

Quais afirmativas estão corretas?$DUP13$),
  lower($DUP14$Analise as frases quanto à pontuação das orações adverbiais deslocadas ou intercaladas.

I. Depois que o perímetro foi isolado, os policiais iniciaram a averiguação.

II. Os policiais, enquanto aguardavam reforço, mantiveram o bloqueio da via.

III. Caso a visibilidade diminua durante o deslocamento da equipe a patrulha reduzirá a velocidade.

IV. A patrulha seguirá, caso as condições da via permitam, até o ponto indicado.

Quais frases estão corretamente pontuadas?$DUP14$),
  lower($DUP15$Leia a frase a seguir.

"Antes da operação, o soldado conferiu o peso do colete de proteção." 

No contexto apresentado, a palavra "peso" foi empregada em sentido denotativo porque se refere$DUP15$),
  lower($DUP16$Leia a frase a seguir.

"O relatório da corregedoria foi um farol para a revisão dos procedimentos internos." 

No contexto apresentado, a expressão "foi um farol" indica que o relatório$DUP16$),
  lower($DUP17$Considere as ocorrências da palavra “linha” nas frases a seguir.

I. Os candidatos permaneceram atrás da linha de segurança durante a instrução.
II. A equipe seguiu uma nova linha de investigação após analisar as imagens.

Quanto aos sentidos assumidos pela palavra “linha”, assinale a alternativa correta.$DUP17$),
  lower($DUP18$Analise as frases a seguir, considerando o emprego das expressões destacadas.

I. A sirene emitiu um **grito** prolongado.
II. O agente guardou o **colete** no armário.
III. Após a notícia, o silêncio **pesou** na sala.
IV. O mecânico substituiu a **corrente** da motocicleta.

Em quais frases o emprego destacado é conotativo?$DUP18$),
  lower($DUP19$Analise as frases a seguir quanto ao emprego das expressões destacadas.

I. O perito recolheu a **lanterna** que estava sobre a mesa.
II. A notícia **voou** pelo quartel antes do comunicado oficial.
III. A decisão deixou um **gosto amargo** entre os servidores.
IV. A viatura parou diante do **prédio** administrativo.

Assinale a alternativa que apresenta a análise correta, considerando apenas a distinção entre sentido literal e sentido figurado.$DUP19$),
  lower($DUP20$Em cada alternativa, a palavra ou expressão destacada foi classificada quanto ao sentido empregado na frase. Assinale a alternativa em que a classificação está INCORRETA.$DUP20$),
  lower($DUP21$Considere as ocorrências da palavra **raiz** nas frases a seguir.

I. As crianças observaram a **raiz** exposta da árvore após a chuva forte.
II. A falta de diálogo era a **raiz** do desentendimento entre os vizinhos.

Assinale a alternativa correta quanto ao sentido de “raiz” nos dois contextos.$DUP21$),
  lower($DUP22$No trecho de uma comunicação interna, assinale a alternativa que completa corretamente a lacuna, de acordo com a norma-padrão tradicional: “O servidor que ___ o comunicado deverá registrar a entrega no sistema.”$DUP22$),
  lower($DUP23$Na norma-padrão tradicional, complete o período a seguir, mantendo o advérbio **ali** sem pausa e o verbo no pretérito imperfeito:

“Ali ___ os policiais responsáveis pela escolta.”

Assinale a alternativa correta.$DUP23$),
  lower($DUP24$Assinale a alternativa que completa corretamente o período de acordo com a norma-padrão tradicional:

“O setor nunca ___ a confirmação da inscrição.”$DUP24$),
  lower($DUP25$Assinale a alternativa que completa corretamente a frase, de acordo com a norma-padrão tradicional de colocação pronominal:

“A comissão informará ________ a lista final.”$DUP25$),
  lower($DUP26$Considerando-se a norma-padrão tradicional cobrada em concursos, assinale a alternativa que reescreve corretamente a oração abaixo, substituindo “o documento” pelo pronome oblíquo átono adequado.

“Em frase isolada, sem qualquer fator de próclise, a direção entregará o documento ao candidato.”$DUP26$),
  lower($DUP27$Em uma ordem dirigida diretamente a um soldado, deve-se empregar o verbo apresentar no imperativo afirmativo, acompanhado do pronome oblíquo átono se. Considerando a norma-padrão tradicional, assinale a redação correta.$DUP27$),
  lower($DUP28$Considerando a norma-padrão tradicional e mantendo o verbo no pretérito perfeito do indicativo, assinale a alternativa correta quanto à colocação do pronome oblíquo átono.$DUP28$)
  );
  if v_dup <> 0 then raise exception 'PRECOND: % questao(oes) com enunciado identico ja existem — possivel reexecucao/duplicidade', v_dup; end if;

  raise notice 'PRECONDICOES GLOBAIS OK: 0 duplicidade de enunciado entre as 28';
end $$;

-- ================= INSERT das 28 questoes =================
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
    select cc.curso_materia_id_materia, cc.assunto_id, 'Papiro', 'PAPIRO - Curadoria LOTE03_PORTUGUES_AUTORAL - BM RS', 2026, r.dificuldade, r.enunciado,
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

  insert into _relatorio values ('TARGET', 'questoes_delta_28', v_questoes - v_snap.total_questoes = 28, (v_questoes - v_snap.total_questoes)::text);
  insert into _relatorio values ('TARGET', 'alternativas_delta_140', v_alternativas - v_snap.total_alternativas = 140, (v_alternativas - v_snap.total_alternativas)::text);
  insert into _relatorio values ('TARGET', 'vinculos_delta_28', v_vinculos - v_snap.total_vinculos = 28, (v_vinculos - v_snap.total_vinculos)::text);
  insert into _relatorio values ('TARGET', 'curso_questoes_delta_28', v_curso_questoes - v_snap.total_curso_questoes = 28, (v_curso_questoes - v_snap.total_curso_questoes)::text);

  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='bfeaf283-09fc-4f14-9d0c-41ff0db4eab7' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET', 'uteis_10_bfeaf283-09fc-4f14-9d0c-41ff0db4eab7', v_uteis = 10, v_uteis::text);

  select count(distinct q.id) filter (where coalesce(lower(q.banca),'') not like '%papiro%'),
         count(distinct q.id) filter (where coalesce(lower(q.banca),'') like '%papiro%')
    into v_real, v_autoral
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='bfeaf283-09fc-4f14-9d0c-41ff0db4eab7' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET', 'real_0_bfeaf283-09fc-4f14-9d0c-41ff0db4eab7', v_real = 0, v_real::text);
  insert into _relatorio values ('TARGET', 'autoral_10_bfeaf283-09fc-4f14-9d0c-41ff0db4eab7', v_autoral = 10, v_autoral::text);

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=m.questao_id and correta=true), '' order by m.ordem)
    into v_gabaritos from _mapa_ids m where m.unidade_pedagogica_id = 'bfeaf283-09fc-4f14-9d0c-41ff0db4eab7';
  insert into _relatorio values ('TARGET', 'gabaritos_bfeaf283-09fc-4f14-9d0c-41ff0db4eab7', v_gabaritos = 'ACEEBDB', v_gabaritos);


  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='dca4fe2e-50e9-41db-abeb-0ef6b388c5af' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET', 'uteis_10_dca4fe2e-50e9-41db-abeb-0ef6b388c5af', v_uteis = 10, v_uteis::text);

  select count(distinct q.id) filter (where coalesce(lower(q.banca),'') not like '%papiro%'),
         count(distinct q.id) filter (where coalesce(lower(q.banca),'') like '%papiro%')
    into v_real, v_autoral
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='dca4fe2e-50e9-41db-abeb-0ef6b388c5af' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET', 'real_0_dca4fe2e-50e9-41db-abeb-0ef6b388c5af', v_real = 0, v_real::text);
  insert into _relatorio values ('TARGET', 'autoral_10_dca4fe2e-50e9-41db-abeb-0ef6b388c5af', v_autoral = 10, v_autoral::text);

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=m.questao_id and correta=true), '' order by m.ordem)
    into v_gabaritos from _mapa_ids m where m.unidade_pedagogica_id = 'dca4fe2e-50e9-41db-abeb-0ef6b388c5af';
  insert into _relatorio values ('TARGET', 'gabaritos_dca4fe2e-50e9-41db-abeb-0ef6b388c5af', v_gabaritos = 'ACCBBDD', v_gabaritos);


  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='f1377f8b-348e-4da6-9713-e901ce5ea516' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET', 'uteis_10_f1377f8b-348e-4da6-9713-e901ce5ea516', v_uteis = 10, v_uteis::text);

  select count(distinct q.id) filter (where coalesce(lower(q.banca),'') not like '%papiro%'),
         count(distinct q.id) filter (where coalesce(lower(q.banca),'') like '%papiro%')
    into v_real, v_autoral
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='f1377f8b-348e-4da6-9713-e901ce5ea516' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET', 'real_0_f1377f8b-348e-4da6-9713-e901ce5ea516', v_real = 0, v_real::text);
  insert into _relatorio values ('TARGET', 'autoral_10_f1377f8b-348e-4da6-9713-e901ce5ea516', v_autoral = 10, v_autoral::text);

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=m.questao_id and correta=true), '' order by m.ordem)
    into v_gabaritos from _mapa_ids m where m.unidade_pedagogica_id = 'f1377f8b-348e-4da6-9713-e901ce5ea516';
  insert into _relatorio values ('TARGET', 'gabaritos_f1377f8b-348e-4da6-9713-e901ce5ea516', v_gabaritos = 'AACBBEB', v_gabaritos);


  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='c03b4993-601a-4c1e-b24d-c9e09d01db84' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET', 'uteis_10_c03b4993-601a-4c1e-b24d-c9e09d01db84', v_uteis = 10, v_uteis::text);

  select count(distinct q.id) filter (where coalesce(lower(q.banca),'') not like '%papiro%'),
         count(distinct q.id) filter (where coalesce(lower(q.banca),'') like '%papiro%')
    into v_real, v_autoral
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='c03b4993-601a-4c1e-b24d-c9e09d01db84' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET', 'real_0_c03b4993-601a-4c1e-b24d-c9e09d01db84', v_real = 0, v_real::text);
  insert into _relatorio values ('TARGET', 'autoral_10_c03b4993-601a-4c1e-b24d-c9e09d01db84', v_autoral = 10, v_autoral::text);

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=m.questao_id and correta=true), '' order by m.ordem)
    into v_gabaritos from _mapa_ids m where m.unidade_pedagogica_id = 'c03b4993-601a-4c1e-b24d-c9e09d01db84';
  insert into _relatorio values ('TARGET', 'gabaritos_c03b4993-601a-4c1e-b24d-c9e09d01db84', v_gabaritos = 'AAABBAA', v_gabaritos);

  select count(*) into v_vinc_ok from _mapa_ids m
    where exists(select 1 from public.questao_unidades_pedagogicas qup where qup.questao_id=m.questao_id and qup.unidade_pedagogica_id=m.unidade_pedagogica_id)
    and not exists(select 1 from public.questao_unidades_pedagogicas qup2 where qup2.questao_id=m.questao_id and qup2.unidade_pedagogica_id <> m.unidade_pedagogica_id);
  insert into _relatorio values ('TARGET', 'vinculos_28_corretos', v_vinc_ok = 28, v_vinc_ok::text);

  select count(*) into v_cq_ok from _mapa_ids m
    where exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=m.questao_id);
  insert into _relatorio values ('TARGET', 'curso_questoes_28', v_cq_ok = 28, v_cq_ok::text);

  insert into _relatorio values ('TARGET', 'ativa_28de28',
    (select count(*) from _mapa_ids m join public.questoes q on q.id=m.questao_id where q.ativa) = 28, 'ativa');
  insert into _relatorio values ('TARGET', 'origem_papiro_28de28',
    (select count(*) from _mapa_ids m join public.questoes q on q.id=m.questao_id where coalesce(lower(q.banca),'') like '%papiro%') = 28, 'banca papiro');
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
  insert into _relatorio values ('REVERSAO', 'vinculos_removidos_28', v_count = 28, v_count::text);
end $$;

do $$
declare v_count int;
begin
  delete from public.curso_questoes where curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and questao_id in (select questao_id from _mapa_ids);
  get diagnostics v_count = row_count;
  insert into _relatorio values ('REVERSAO', 'curso_questoes_removidas_28', v_count = 28, v_count::text);
end $$;

do $$
declare v_count int;
begin
  delete from public.alternativas where questao_id in (select questao_id from _mapa_ids);
  get diagnostics v_count = row_count;
  insert into _relatorio values ('REVERSAO', 'alternativas_removidas_140', v_count = 140, v_count::text);
end $$;

do $$
declare v_count int;
begin
  delete from public.questoes where id in (select questao_id from _mapa_ids);
  get diagnostics v_count = row_count;
  insert into _relatorio values ('REVERSAO', 'questoes_removidas_28', v_count = 28, v_count::text);
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
    raise notice 'TESTE DE ROLLBACK: %/% checks OK — LOTE03_PORTUGUES_AUTORAL_ROLLBACK_TEST_APROVADO', v_ok, v_total;
  else
    raise notice 'TESTE DE ROLLBACK: %/% checks OK — HA FALHAS, ver _relatorio', v_ok, v_total;
  end if;
end $$;

rollback;
