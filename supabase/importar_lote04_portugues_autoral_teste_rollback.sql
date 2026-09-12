-- TESTE DE ROLLBACK REAL da IMPORTACAO LOTE04_PORTUGUES_AUTORAL. Executa, dentro de UMA
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
(1, 19, $D1$media$D1$, $FONTE1$PAPIRO — LOTE04_PORTUGUES_AUTORAL — CONC-01$FONTE1$, $ENUN1$No contexto das orientações internas de uma unidade policial, assinale a alternativa que apresenta correta concordância nominal.$ENUN1$),
(2, 19, $D2$media$D2$, $FONTE2$PAPIRO — LOTE04_PORTUGUES_AUTORAL — CONC-02$FONTE2$, $ENUN2$Assinale a alternativa que completa corretamente a frase, de acordo com a concordância nominal: “Para a segurança das operações, ________ as inspeções periódicas dos veículos oficiais.”$ENUN2$),
(3, 19, $D3$media$D3$, $FONTE3$PAPIRO — LOTE04_PORTUGUES_AUTORAL — CONC-03$FONTE3$, $ENUN3$Em um comunicado interno da corporação, assinale a alternativa redigida de acordo com a norma-padrão quanto à concordância nominal.$ENUN3$),
(4, 19, $D4$media$D4$, $FONTE4$PAPIRO — LOTE04_PORTUGUES_AUTORAL — CONC-04$FONTE4$, $ENUN4$Após o bloqueio de uma área isolada, assinale a alternativa correta quanto à concordância nominal.$ENUN4$),
(5, 19, $D5$media$D5$, $FONTE5$PAPIRO — LOTE04_PORTUGUES_AUTORAL — CONC-05$FONTE5$, $ENUN5$Em uma comunicação interna, pretende-se redigir corretamente a seguinte frase:

“A planilha está ___ ao memorando, e os comprovantes estão disponíveis ___.”

Assinale a alternativa que completa, correta e respectivamente, as lacunas.$ENUN5$),
(6, 19, $D6$media$D6$, $FONTE6$PAPIRO — LOTE04_PORTUGUES_AUTORAL — CONC-07$FONTE6$, $ENUN6$Durante o atendimento à ocorrência, as policiais ficaram ___ apreensivas, pois receberam apenas ___ diária para custear a alimentação. Assinale a alternativa que completa correta e respectivamente as lacunas.$ENUN6$),
(7, 19, $D7$media$D7$, $FONTE7$PAPIRO — LOTE04_PORTUGUES_AUTORAL — CONC-08$FONTE7$, $ENUN7$Em um memorando, consta a frase: "As fotografias seguem em anexo ao relatório." Pretende-se substituir a locução invariável "em anexo" por um adjetivo de sentido equivalente. Assinale a reescrita correta.$ENUN7$),
(8, 15, $D8$media$D8$, $FONTE8$PAPIRO — LOTE04_PORTUGUES_AUTORAL — CRASE-02$FONTE8$, $ENUN8$No período “Os policiais compareceram ___ audiência de custódia designada para a manhã”, assinale a alternativa que preenche corretamente a lacuna conforme a norma-padrão.$ENUN8$),
(9, 15, $D9$media$D9$, $FONTE9$PAPIRO — LOTE04_PORTUGUES_AUTORAL — CRASE-03$FONTE9$, $ENUN9$Complete corretamente a lacuna da frase a seguir:

"Durante o patrulhamento, a guarnição deu prioridade ___ ocorrências com risco imediato à população."$ENUN9$),
(10, 15, $D10$media$D10$, $FONTE10$PAPIRO — LOTE04_PORTUGUES_AUTORAL — CRASE-04$FONTE10$, $ENUN10$Complete corretamente a lacuna da frase a seguir:

"Após a análise interna, as inconsistências no relatório vieram ___, exigindo providências da administração."$ENUN10$),
(11, 15, $D11$media$D11$, $FONTE11$PAPIRO — LOTE04_PORTUGUES_AUTORAL — CRASE-05$FONTE11$, $ENUN11$No trecho abaixo, assinale a alternativa que preenche corretamente a lacuna, de acordo com o emprego da crase.

"Após a reunião, a chefia orientou os integrantes ___ registrar as ocorrências no sistema eletrônico antes do encerramento do turno."$ENUN11$),
(12, 15, $D12$media$D12$, $FONTE12$PAPIRO — LOTE04_PORTUGUES_AUTORAL — CRASE-07$FONTE12$, $ENUN12$Em qual das alternativas o emprego do acento grave indicativo de crase é obrigatório?$ENUN12$),
(13, 15, $D13$media$D13$, $FONTE13$PAPIRO — LOTE04_PORTUGUES_AUTORAL — CRASE-08$FONTE13$, $ENUN13$Assinale a alternativa correta quanto ao emprego da crase.$ENUN13$),
(14, 25, $D14$media$D14$, $FONTE14$PAPIRO — LOTE04_PORTUGUES_AUTORAL — IMPL-01$FONTE14$, $ENUN14$Leia o enunciado elaborado para uma comunicação interna:

"Durante o treinamento de atendimento ao público, até o agente mais resistente às atividades digitais concluiu o módulo sem solicitar auxílio."

No contexto apresentado, o emprego de "até" permite inferir que$ENUN14$),
(15, 25, $D15$media$D15$, $FONTE15$PAPIRO — LOTE04_PORTUGUES_AUTORAL — IMPL-02$FONTE15$, $ENUN15$Leia o trecho de um relatório administrativo:

"A campanha de atualização cadastral mobilizou os setores da unidade, inclusive a equipe responsável pelo arquivo histórico, que normalmente atua em tarefas de preservação documental."

A respeito do conteúdo implícito produzido por "inclusive", assinale a alternativa correta.$ENUN15$),
(16, 25, $D16$media$D16$, $FONTE16$PAPIRO — LOTE04_PORTUGUES_AUTORAL — IMPL-03$FONTE16$, $ENUN16$Leia o enunciado institucional a seguir.

"Após a substituição dos equipamentos, a seção de comunicação parou de utilizar os rádios antigos."

Considerando o conteúdo implícito produzido pela expressão destacada, assinale a alternativa correta.$ENUN16$),
(17, 25, $D17$media$D17$, $FONTE17$PAPIRO — LOTE04_PORTUGUES_AUTORAL — IMPL-04$FONTE17$, $ENUN17$Leia o enunciado institucional a seguir.

"Com a implantação do novo protocolo, o sistema começou a emitir alertas automáticos de ocorrência."

A partir da expressão “começou a emitir”, é correto inferir que$ENUN17$),
(18, 25, $D18$media$D18$, $FONTE18$PAPIRO — LOTE04_PORTUGUES_AUTORAL — IMPL-05$FONTE18$, $ENUN18$Leia o enunciado a seguir.

"Após a atualização do sistema de registros, a unidade voltou a encaminhar os relatórios semanais ao comando regional."

Considerando o conteúdo implícito desencadeado pela locução destacada, assinale a alternativa correta.$ENUN18$),
(19, 25, $D19$media$D19$, $FONTE19$PAPIRO — LOTE04_PORTUGUES_AUTORAL — IMPL-06$FONTE19$, $ENUN19$Leia o trecho de uma nota institucional.

"O programa de treinamento registrou novos recordes de participação nas atividades oferecidas neste semestre."

A respeito do conteúdo implícito associado ao emprego de "novos", assinale a alternativa correta.$ENUN19$),
(20, 23, $D20$media$D20$, $FONTE20$PAPIRO — LOTE04_PORTUGUES_AUTORAL — SIG-01$FONTE20$, $ENUN20$Leia o trecho a seguir:

“Após a reunião de planejamento, a proposta de redistribuição do efetivo foi acolhida com ressalvas pelos representantes das unidades.”

No contexto em que ocorre, o termo “ressalvas” indica que os representantes:$ENUN20$),
(21, 23, $D21$media$D21$, $FONTE21$PAPIRO — LOTE04_PORTUGUES_AUTORAL — SIG-02$FONTE21$, $ENUN21$Leia o trecho a seguir:

“Com a implantação do sistema digital, o setor conseguiu enxugar o fluxo de documentos encaminhados diariamente às unidades.”

No contexto apresentado, o verbo “enxugar” significa:$ENUN21$),
(22, 23, $D22$media$D22$, $FONTE22$PAPIRO — LOTE04_PORTUGUES_AUTORAL — SIG-03$FONTE22$, $ENUN22$Leia o trecho a seguir:

"A Seção de Recursos informou que as respostas seriam divulgadas oportunamente no portal institucional."

Considerando o sentido contextual e a estrutura da oração, assinale a alternativa correta acerca da substituição de "oportunamente" por "no momento adequado".$ENUN22$),
(23, 23, $D23$media$D23$, $FONTE23$PAPIRO — LOTE04_PORTUGUES_AUTORAL — SIG-04$FONTE23$, $ENUN23$Leia o trecho a seguir:

"A chefia orientou os servidores a não formularem acusações levianas contra colegas."

Assinale a alternativa correta acerca da substituição de "levianas" por "superficiais" no trecho.$ENUN23$),
(24, 23, $D24$media$D24$, $FONTE24$PAPIRO — LOTE04_PORTUGUES_AUTORAL — SIG-05$FONTE24$, $ENUN24$Leia o trecho de um memorando interno:

“Graças à atuação célere da guarnição, a ocorrência foi controlada antes de causar novos transtornos.”

Considerando o contexto apresentado, assinale a alternativa correta acerca da substituição de “célere” por “rápida”.$ENUN24$),
(25, 23, $D25$media$D25$, $FONTE25$PAPIRO — LOTE04_PORTUGUES_AUTORAL — SIG-08$FONTE25$, $ENUN25$Leia o trecho a seguir:

“Após analisar os documentos apresentados, a chefia decidiu deferir o pedido de troca de turno.”

No contexto, o verbo “deferir” significa:$ENUN25$);

create temporary table _lote_explicacoes (ordem int primary key, explicacao text) on commit drop;

insert into _lote_explicacoes (ordem, explicacao) values
(1, $EXPL1$Em “É obrigatória a identificação funcional”, o sujeito é “a identificação funcional”, determinado pelo artigo “a” e no feminino singular. Por isso, o predicativo “obrigatória” deve concordar com esse sujeito em gênero e número. A alternativa A emprega indevidamente o masculino; C, D e E apresentam discordância de número e/ou de gênero entre o verbo, o predicativo e o sujeito.

FUNDAMENTO: Em construções com verbo de ligação e sujeito determinado por artigo ou pronome, o predicativo do sujeito concorda obrigatoriamente com o núcleo do sujeito em gênero e número.$EXPL1$),
(2, $EXPL2$O sujeito da oração é “as inspeções periódicas dos veículos oficiais”. Seu núcleo, “inspeções”, está no feminino plural e é determinado pelo artigo “as”. Assim, tanto o verbo de ligação quanto o predicativo devem ir para o plural: “são indispensáveis”. A alternativa A deixa verbo e predicativo no singular; B combina verbo singular com predicativo plural; C mantém o predicativo no singular; e E apresenta forma gráfica incorreta do adjetivo.

FUNDAMENTO: Quando o sujeito determinado está no plural, o predicativo do sujeito concorda com ele em número e gênero. Com “as inspeções”, emprega-se “são indispensáveis”.$EXPL2$),
(3, $EXPL3$Na alternativa B, o substantivo “cautela” aparece sem determinante, isto é, sem artigo ou pronome que o especifique. Na formulação tradicional de concurso, nessa estrutura o predicativo permanece no masculino singular: “é necessário cautela”. A e D fazem o predicativo concordar no feminino com “cautela”, o que seria exigido se houvesse determinante, como em “É necessária a cautela”. C emprega indevidamente o plural em “necessários”. Em E, a presença do artigo “a” determina o substantivo e exigiria a forma “necessária”: “É necessária a cautela”.

FUNDAMENTO: Com substantivo empregado em sentido geral e sem determinante, construções como “é necessário cautela” tradicionalmente mantêm o predicativo no masculino singular. Havendo determinante antes do substantivo, o predicativo concorda com ele em gênero e número.$EXPL3$),
(4, $EXPL4$Em B, “circulação de veículos não autorizados” está sem determinante. Por isso, na construção tradicional, o predicativo “proibido” permanece no masculino singular: “Permaneceu proibido circulação...”. A traz a concordância no feminino, que seria adequada na presença de artigo: “Permaneceu proibida a circulação...”. C e D empregam formas plurais sem justificativa na estrutura apresentada. Em E, o artigo “a” determina “circulação”; nesse caso, a forma esperada seria “proibida”, e não “proibido”.

FUNDAMENTO: Em estruturas com verbo de ligação e substantivo sem determinante, a tradição gramatical registra o uso do predicativo no masculino singular, como em “é proibido entrada”. Se o substantivo vier determinado, o predicativo concordará em gênero e número com ele.$EXPL4$),
(5, $EXPL5$O termo “anexa” funciona como adjetivo e concorda com o substantivo feminino singular “planilha”: “A planilha está anexa ao memorando”. Já “em anexo” é uma locução adverbial invariável, razão pela qual não sofre flexão, mesmo quando se refere a “comprovantes”, substantivo masculino plural. Portanto, a forma correta é “anexa — em anexo”. A alternativa B erra a concordância do adjetivo com “planilha”; C flexiona indevidamente a locução “em anexo”; D troca as funções e ainda emprega “anexos” sem a estrutura adequada; E apresenta forma inexistente na locução.

FUNDAMENTO: Como adjetivo, “anexo” varia em gênero e número para concordar com o substantivo a que se refere. Na locução adverbial “em anexo”, o termo permanece invariável.$EXPL5$),
(6, $EXPL6$Na primeira lacuna, "meio" equivale a "um pouco" e funciona como advérbio de intensidade; por isso, é invariável: "meio apreensivas". Na segunda, "meia" é numeral fracionário e acompanha o substantivo feminino "diária": "meia diária". Estão incorretas as formas "meias apreensivas", pois tratam indevidamente o advérbio como variável, e "meio diária", pois o numeral deve concordar com o substantivo feminino.

FUNDAMENTO: O vocábulo "meio", quando empregado como advérbio com sentido de "um pouco", permanece invariável. Quando empregado como numeral fracionário, varia para concordar em gênero com o substantivo a que se refere.$EXPL6$),
(7, $EXPL7$Na substituição da locução "em anexo" pelo adjetivo "anexo", este deve concordar com o substantivo a que se refere: "fotografias", feminino plural. Portanto, emprega-se "anexas". A locução "em anexo" é invariável, mas não admite flexão interna, o que torna incorretas "em anexas" e "em anexos". As formas "anexo" e "anexos" também não concordam com "fotografias".

FUNDAMENTO: O adjetivo "anexo" concorda em gênero e número com o substantivo a que se liga. A expressão "em anexo", por ser locução adverbial, é invariável.$EXPL7$),
(8, $EXPL8$A forma correta é “à audiência”. O verbo “comparecer”, no sentido de estar presente em evento ou local, exige a preposição “a”: comparecer a algo. A expressão “a audiência de custódia designada para a manhã” contém substantivo feminino singular determinado, que admite o artigo definido “a”. Estão presentes, portanto, a preposição exigida pelo verbo e o artigo admitido pelo substantivo, resultando em “à”. A alternativa A deixa de registrar a fusão necessária; B e D estão no plural, em desacordo com “audiência”; e E é forma do verbo haver e não estabelece a relação de regência requerida.

FUNDAMENTO: Em contextos com substantivo feminino determinado, a fusão entre a preposição “a”, exigida pela regência, e o artigo definido “a” produz o acento grave indicativo de crase. O verbo “comparecer” rege preposição “a” nesse emprego.$EXPL8$),
(9, $EXPL9$A forma correta é “às”. O termo regente “dar prioridade” exige a preposição “a” (“dar prioridade a algo”), e o substantivo feminino plural determinado “ocorrências” admite o artigo definido “as”. Como a preposição e o artigo coexistem, ocorre a fusão: a + as = às. Em A, falta a preposição exigida pelo termo regente; em C, a fusão obrigatória foi indevidamente desfeita; em D, há discordância de número, pois “ocorrências” está no plural; em E, faltaria o artigo definido plural.

FUNDAMENTO: Emprega-se crase quando o termo anterior exige a preposição “a” e o termo seguinte, sendo substantivo feminino determinado, admite o artigo definido “a” ou “as”.$EXPL9$),
(10, $EXPL10$A expressão correta é “à tona”. Trata-se de uma locução adverbial feminina cristalizada, empregada com o sentido de “em evidência” ou “à vista”. Nessa locução, usa-se o acento grave indicativo de crase. Em A, falta o acento grave; em C, há duplicação indevida; em D, a forma não constitui locução correta; e em E, “tona” não se flexiona no plural nessa expressão.

FUNDAMENTO: Nas locuções adverbiais femininas cristalizadas, como “à tona”, emprega-se o acento grave indicativo de crase.$EXPL10$),
(11, $EXPL11$A forma correta é "orientou os integrantes a registrar". O verbo "orientar", nessa construção, rege a preposição "a" antes do infinitivo "registrar". Como verbo no infinitivo não admite artigo definido feminino, não há fusão de preposição com artigo e, portanto, não ocorre crase. A alternativa A emprega indevidamente o acento grave; C e D não se ajustam à estrutura da oração; E indica verbo haver e não pode preencher a lacuna.

FUNDAMENTO: Antes de verbo no infinitivo, em regra, há apenas a preposição exigida pelo termo anterior, pois o infinitivo não admite artigo definido feminino. Assim, escreve-se "a registrar", sem crase.$EXPL11$),
(12, $EXPL12$Em B, o verbo “entregar” estabelece, no contexto, relação com o destinatário por meio da preposição “a” (“entregue a alguém”), e “central de videomonitoramento” é um substantivo feminino determinado que admite o artigo “a”. Como coexistem preposição e artigo, ocorre obrigatoriamente a fusão: “à central”.

Em A, a crase é possível, mas não obrigatória, pois o artigo antes do possessivo feminino “sua” pode ser usado ou omitido: “a sua coordenadora” / “à sua coordenadora”. Em C, não há fusão de preposição com artigo feminino na expressão “lado a lado”. Em D, o termo seguinte é o infinitivo “organizar”, que não admite artigo feminino. Em E, “cavalo” é palavra masculina, não havendo artigo feminino com o qual a preposição pudesse fundir-se.

FUNDAMENTO: A crase ocorre quando a preposição “a”, exigida pelo termo anterior, funde-se ao artigo definido feminino “a/as”, admitido pelo termo seguinte. Antes de possessivo feminino, a presença do artigo pode ser facultativa; por isso, a crase não é necessariamente obrigatória nesse contexto.$EXPL12$),
(13, $EXPL13$A alternativa B está correta: em “começou a revisar”, há a preposição “a”, exigida pela locução verbal, seguida do infinitivo “revisar”. Como verbos no infinitivo não admitem artigo definido feminino, não há a fusão necessária para a crase.

Pelo mesmo motivo, estão incorretos os acentos graves em A (“passou a monitorar”), C (“voltou a preencher”), D (“aprendeu a reconhecer”) e E (“limitou-se a registrar”). Em todas essas construções, o elemento posterior é um verbo no infinitivo; portanto, escreve-se somente “a”, sem acento grave.

FUNDAMENTO: A crase pressupõe a coexistência da preposição “a” com o artigo definido feminino “a/as”. O verbo no infinitivo não admite artigo definido feminino; assim, ainda que o termo anterior exija a preposição “a”, não ocorre crase.$EXPL13$),
(14, $EXPL14$No enunciado, o operador escalar "até" destaca o agente mais resistente às atividades digitais como um caso cuja conclusão do módulo seria, no contexto, menos esperada. Também sugere inclusão: se até esse agente concluiu, outros participantes também o fizeram. A alternativa A erra ao afirmar exclusividade; C, D e E acrescentam informações não fornecidas pelo texto, como recusa anterior, ausência de auxílio para todos ou domínio integral das ferramentas.

FUNDAMENTO: Em construções concretas, "até" pode organizar uma escala de expectativa e apresentar o termo destacado como caso-limite ou menos esperado, sem autorizar inferências adicionais que não estejam sustentadas pelo enunciado.$EXPL14$),
(15, $EXPL15$No trecho, "inclusive" inclui a equipe do arquivo histórico no conjunto dos setores mobilizados. Como ela normalmente atua em preservação documental, sua participação na campanha é apresentada como um acréscimo contextualmente menos esperado. A alternativa A contraria o sentido inclusivo, pois houve mobilização dos setores da unidade; B afirma abandono definitivo de atividade, o que não foi dito; D generaliza uma característica atribuída apenas à equipe do arquivo; e E transforma a participação dessa equipe em exclusividade.

FUNDAMENTO: No contexto concreto, "inclusive" introduz um elemento pertencente ao conjunto já mencionado e pode destacá-lo por ocupar posição de menor expectativa na escala contextual construída pelo enunciado.$EXPL15$),
(16, $EXPL16$A expressão “parou de utilizar” indica uma mudança de estado: se a seção parou de utilizar os rádios antigos, pressupõe-se que os utilizava antes. Não se pode, porém, concluir a frequência ou a duração desse uso (B), a causa da substituição (C), o funcionamento dos equipamentos (D) nem uma proibição ou impossibilidade de uso futuro (E).

FUNDAMENTO: Na construção concreta, “parar de + infinitivo” pressupõe que a ação expressa pelo infinitivo ocorria anteriormente, sem autorizar inferências sobre motivo, frequência, duração ou consequências posteriores.$EXPL16$),
(17, $EXPL17$“Começou a emitir” apresenta o início de uma ação e permite recuperar que, antes do marco indicado, o sistema não emitia os alertas automáticos de ocorrência referidos. As demais alternativas acrescentam dados não informados: permanência da emissão (B), motivo da implantação (C), destinatários dos alertas (D) e abrangência total dos alertas emitidos (E).

FUNDAMENTO: Na construção concreta, “começar a + infinitivo” marca o início da ação e pressupõe que ela não ocorria anteriormente, sem permitir deduzir duração, causa, destinatários ou extensão da ação.$EXPL17$),
(18, $EXPL18$A locução "voltou a encaminhar" indica retomada de uma ação. Assim, permite recuperar que a unidade encaminhava os relatórios antes, houve uma interrupção e o encaminhamento foi retomado. A alternativa B contradiz a ideia de retomada. A alternativa C extrapola o enunciado, pois não informa o motivo da interrupção. A D acrescenta uma suposta aprovação dos relatórios, e a E altera indevidamente a periodicidade semanal para diária.

FUNDAMENTO: Em uma construção concreta, "voltar a + infinitivo" pressupõe que a ação ocorria anteriormente, foi interrompida e passou a ocorrer novamente, sem autorizar inferências sobre motivo, duração, frequência adicional ou resultado da retomada.$EXPL18$),
(19, $EXPL19$No contexto, "novos" qualifica "recordes", substantivo que designa itens de uma série. Essa construção autoriza a leitura de que existiam recordes de participação anteriores. A alternativa B transforma a informação sobre recordes em participação total, o que não foi dito. A C afirma uma anulação sem apoio textual. A D faz previsão futura indevida, e a E confunde novos recordes com atividades inéditas.

FUNDAMENTO: Quando "novos" qualifica, no contexto, um substantivo que designa itens de uma série, como "recordes", a construção permite recuperar a existência de outro ou outros itens anteriores da mesma série. Essa leitura depende da construção concreta.$EXPL19$),
(20, $EXPL20$No trecho, “acolhida com ressalvas” significa que a proposta foi aceita, porém não de maneira irrestrita: os representantes fizeram observações, apontaram limites ou condicionaram sua concordância a determinados aspectos. A alternativa A erra ao indicar aprovação plena; B confunde aceitação com rejeição; D e E apresentam informações que não decorrem do contexto.

FUNDAMENTO: O sentido de uma palavra é definido pela relação que estabelece com os demais elementos do enunciado. Na expressão “com ressalvas”, o contexto atribui a “ressalvas” o valor de restrições, objeções parciais ou ponderações.$EXPL20$),
(21, $EXPL21$No contexto administrativo, “enxugar o fluxo de documentos” significa torná-lo mais reduzido e eficiente, com diminuição de volume ou supressão de etapas desnecessárias. A alternativa B recupera um sentido literal inadequado ao contexto; C e D indicam ações específicas que não são expressas pelo verbo; E contraria a ideia de redução presente em “enxugar”.

FUNDAMENTO: Palavras empregadas em contextos institucionais podem assumir sentido não literal. Em “enxugar o fluxo”, o verbo equivale contextual e funcionalmente a reduzir ou simplificar, preservando a ideia global do enunciado.$EXPL21$),
(22, $EXPL22$A substituição é válida. No contexto, "oportunamente" significa "em momento oportuno, apropriado". A locução adverbial "no momento adequado" mantém esse valor temporal e modifica adequadamente a locução verbal "seriam divulgadas". A alternativa B está errada porque uma locução adverbial pode desempenhar a mesma função de um advérbio. A letra C erra ao reduzir "oportunamente" a "imediatamente", sentido mais restrito e não obrigatório. A letra D é incorreta porque "adequado" integra a locução "no momento adequado", que funciona como adjunto adverbial. A letra E propõe uma alteração verbal desnecessária e sem relação com a validade da substituição.

FUNDAMENTO: Uma substituição vocabular é aceitável quando preserva o sentido global do enunciado, a função sintática desempenhada pelo termo substituído e a correção gramatical da construção resultante.$EXPL22$),
(23, $EXPL23$A substituição não é válida no contexto apresentado. Em "acusações levianas", o adjetivo "levianas" caracteriza acusações feitas de modo irresponsável, imprudente ou sem fundamento. Já "superficiais" designa, em geral, algo pouco aprofundado ou pouco detalhado. Embora ambas sejam formas adjetivas, concordem corretamente com "acusações" e possam ocorrer antes ou depois de substantivos, elas não preservam o mesmo sentido nesse enunciado. A letra A atribui indevidamente a "levianas" o sentido de falta de detalhes. A letra C erra ao tratar as palavras como sinônimos absolutos. A letra D é falsa, pois "superficiais" concorda adequadamente com "acusações". A letra E é incorreta porque a regência de "acusações contra colegas" permanece gramatical, mas isso não resolve a alteração de sentido provocada pela troca lexical.

FUNDAMENTO: Palavras de mesma classe gramatical e com áreas de significado próximas não são necessariamente intercambiáveis. A substituição exige preservação do sentido específico assumido no contexto, além da adequação morfossintática da construção.$EXPL23$),
(24, $EXPL24$No trecho, “célere” caracteriza a atuação da guarnição como rápida, ágil. Assim, a troca por “rápida” preserva o sentido global e a função de adjetivo, sendo aceitável naquele contexto. Contudo, há diferença de registro: “célere” é mais formal e frequente em textos institucionais. Por isso, trata-se de sinonímia contextual, e não de sinonímia absoluta. A alternativa B erra ao restringir indevidamente os usos dos adjetivos; C erra porque sinônimos não são automaticamente intercambiáveis em todo contexto; D erra porque ambos são adjetivos e concordam com “atuação”; E erra porque “rápida” pode qualificar, entre outros substantivos, “atuação”.

FUNDAMENTO: A sinonímia é avaliada no contexto de uso: para que uma substituição seja adequada, devem ser preservados o sentido global, a classe gramatical, a função sintática e a compatibilidade de registro. A equivalência contextual não implica sinonímia absoluta.$EXPL24$),
(25, $EXPL25$No trecho, “deferir o pedido” significa acolhê-lo ou concedê-lo. A alternativa B é, portanto, a correta. A alternativa A associa-se à ideia de postergar uma decisão; a C remete a “retificar”, isto é, corrigir; a D aproxima-se de “diferir”, no sentido de divergir ou ser diferente; e a E corresponde a “indeferir”, que significa negar ou recusar um pedido. As formas semelhantes exigem atenção, pois possuem significados distintos.

FUNDAMENTO: Palavras parônimas apresentam semelhança gráfica e/ou sonora, mas possuem significados diferentes. A interpretação correta deve considerar o contexto de uso: “deferir” significa conceder ou acolher; “indeferir”, negar; e “diferir”, divergir ou adiar, conforme o contexto.$EXPL25$);

create temporary table _lote_alternativas (ordem int, letra_ordem int, texto text, correta boolean) on commit drop;

insert into _lote_alternativas (ordem, letra_ordem, texto, correta) values
(1, 1, $ALT1_1$É obrigatório a identificação funcional na entrada da unidade.$ALT1_1$, false),
(1, 2, $ALT1_2$É obrigatória a identificação funcional na entrada da unidade.$ALT1_2$, true),
(1, 3, $ALT1_3$São obrigatória a identificação funcional na entrada da unidade.$ALT1_3$, false),
(1, 4, $ALT1_4$É obrigatórios a identificação funcional na entrada da unidade.$ALT1_4$, false),
(1, 5, $ALT1_5$São obrigatórias a identificação funcional na entrada da unidade.$ALT1_5$, false),
(2, 1, $ALT2_1$é indispensável$ALT2_1$, false),
(2, 2, $ALT2_2$é indispensáveis$ALT2_2$, false),
(2, 3, $ALT2_3$são indispensável$ALT2_3$, false),
(2, 4, $ALT2_4$são indispensáveis$ALT2_4$, true),
(2, 5, $ALT2_5$são indispensávels$ALT2_5$, false),
(3, 1, $ALT3_1$Em ocorrências de risco, é necessária cautela no registro das informações.$ALT3_1$, false),
(3, 2, $ALT3_2$Em ocorrências de risco, é necessário cautela no registro das informações.$ALT3_2$, true),
(3, 3, $ALT3_3$Em ocorrências de risco, é necessários cautela no registro das informações.$ALT3_3$, false),
(3, 4, $ALT3_4$Em ocorrências de risco, é necessárias cautela no registro das informações.$ALT3_4$, false),
(3, 5, $ALT3_5$Em ocorrências de risco, é necessário a cautela no registro das informações.$ALT3_5$, false),
(4, 1, $ALT4_1$Permaneceu proibida circulação de veículos não autorizados na área isolada.$ALT4_1$, false),
(4, 2, $ALT4_2$Permaneceu proibido circulação de veículos não autorizados na área isolada.$ALT4_2$, true),
(4, 3, $ALT4_3$Permaneceu proibidos circulação de veículos não autorizados na área isolada.$ALT4_3$, false),
(4, 4, $ALT4_4$Permaneceu proibidas circulação de veículos não autorizados na área isolada.$ALT4_4$, false),
(4, 5, $ALT4_5$Permaneceu proibido a circulação de veículos não autorizados na área isolada.$ALT4_5$, false),
(5, 1, $ALT5_1$anexa — em anexo$ALT5_1$, true),
(5, 2, $ALT5_2$anexo — em anexo$ALT5_2$, false),
(5, 3, $ALT5_3$anexa — em anexos$ALT5_3$, false),
(5, 4, $ALT5_4$em anexo — anexos$ALT5_4$, false),
(5, 5, $ALT5_5$em anexa — em anexo$ALT5_5$, false),
(6, 1, $ALT6_1$meio — meia$ALT6_1$, true),
(6, 2, $ALT6_2$meias — meia$ALT6_2$, false),
(6, 3, $ALT6_3$meia — meio$ALT6_3$, false),
(6, 4, $ALT6_4$meio — meio$ALT6_4$, false),
(6, 5, $ALT6_5$meias — meios$ALT6_5$, false),
(7, 1, $ALT7_1$As fotografias seguem anexo ao relatório.$ALT7_1$, false),
(7, 2, $ALT7_2$As fotografias seguem anexas ao relatório.$ALT7_2$, true),
(7, 3, $ALT7_3$As fotografias seguem em anexas ao relatório.$ALT7_3$, false),
(7, 4, $ALT7_4$As fotografias seguem anexos ao relatório.$ALT7_4$, false),
(7, 5, $ALT7_5$As fotografias seguem em anexos ao relatório.$ALT7_5$, false),
(8, 1, $ALT8_1$a$ALT8_1$, false),
(8, 2, $ALT8_2$as$ALT8_2$, false),
(8, 3, $ALT8_3$à$ALT8_3$, true),
(8, 4, $ALT8_4$às$ALT8_4$, false),
(8, 5, $ALT8_5$há$ALT8_5$, false),
(9, 1, $ALT9_1$as$ALT9_1$, false),
(9, 2, $ALT9_2$às$ALT9_2$, true),
(9, 3, $ALT9_3$a as$ALT9_3$, false),
(9, 4, $ALT9_4$à$ALT9_4$, false),
(9, 5, $ALT9_5$a$ALT9_5$, false),
(10, 1, $ALT10_1$a tona$ALT10_1$, false),
(10, 2, $ALT10_2$à tona$ALT10_2$, true),
(10, 3, $ALT10_3$à à tona$ALT10_3$, false),
(10, 4, $ALT10_4$as tona$ALT10_4$, false),
(10, 5, $ALT10_5$à tonas$ALT10_5$, false),
(11, 1, $ALT11_1$à$ALT11_1$, false),
(11, 2, $ALT11_2$a$ALT11_2$, true),
(11, 3, $ALT11_3$às$ALT11_3$, false),
(11, 4, $ALT11_4$as$ALT11_4$, false),
(11, 5, $ALT11_5$há$ALT11_5$, false),
(12, 1, $ALT12_1$A mensagem foi encaminhada à sua coordenadora.$ALT12_1$, false),
(12, 2, $ALT12_2$O rádio foi entregue à central de videomonitoramento.$ALT12_2$, true),
(12, 3, $ALT12_3$Os integrantes permaneceram lado a lado com os instrutores.$ALT12_3$, false),
(12, 4, $ALT12_4$A equipe começou a organizar o material apreendido.$ALT12_4$, false),
(12, 5, $ALT12_5$O soldado deslocou-se a cavalo até o posto.$ALT12_5$, false),
(13, 1, $ALT13_1$A equipe passou à monitorar o acesso ao prédio.$ALT13_1$, false),
(13, 2, $ALT13_2$A equipe começou a revisar os equipamentos de comunicação.$ALT13_2$, true),
(13, 3, $ALT13_3$O responsável voltou à preencher o formulário de ocorrência.$ALT13_3$, false),
(13, 4, $ALT13_4$O agente aprendeu à reconhecer sinais de risco.$ALT13_4$, false),
(13, 5, $ALT13_5$O servidor limitou-se à registrar os dados essenciais.$ALT13_5$, false),
(14, 1, $ALT14_1$somente o agente mais resistente às atividades digitais concluiu o módulo.$ALT14_1$, false),
(14, 2, $ALT14_2$a conclusão do módulo por esse agente era, comparativamente, menos esperada que a dos demais participantes.$ALT14_2$, true),
(14, 3, $ALT14_3$o agente mais resistente havia se recusado formalmente a participar do treinamento.$ALT14_3$, false),
(14, 4, $ALT14_4$nenhum dos outros participantes precisou de auxílio durante o módulo.$ALT14_4$, false),
(14, 5, $ALT14_5$o agente passou a dominar integralmente todas as ferramentas digitais utilizadas.$ALT14_5$, false),
(15, 1, $ALT15_1$A equipe responsável pelo arquivo histórico foi a única mobilizada pela campanha.$ALT15_1$, false),
(15, 2, $ALT15_2$A equipe responsável pelo arquivo histórico deixou definitivamente de realizar tarefas de preservação documental.$ALT15_2$, false),
(15, 3, $ALT15_3$A participação da equipe responsável pelo arquivo histórico é apresentada, naquele contexto, como um caso adicional e potencialmente menos esperado na mobilização.$ALT15_3$, true),
(15, 4, $ALT15_4$Todos os setores mobilizados exercem habitualmente tarefas de preservação documental.$ALT15_4$, false),
(15, 5, $ALT15_5$A campanha ocorreu exclusivamente no setor de arquivo histórico.$ALT15_5$, false),
(16, 1, $ALT16_1$A seção de comunicação utilizava os rádios antigos antes da substituição dos equipamentos.$ALT16_1$, true),
(16, 2, $ALT16_2$A seção de comunicação utilizava os rádios antigos diariamente e por longos períodos.$ALT16_2$, false),
(16, 3, $ALT16_3$A substituição dos equipamentos foi motivada por defeitos nos rádios antigos.$ALT16_3$, false),
(16, 4, $ALT16_4$Os rádios antigos deixaram de funcionar após a substituição dos equipamentos.$ALT16_4$, false),
(16, 5, $ALT16_5$A seção de comunicação jamais voltará a utilizar rádios antigos.$ALT16_5$, false),
(17, 1, $ALT17_1$o sistema não emitia alertas automáticos de ocorrência antes da implantação mencionada.$ALT17_1$, true),
(17, 2, $ALT17_2$o sistema emitirá alertas automáticos de ocorrência de forma permanente.$ALT17_2$, false),
(17, 3, $ALT17_3$a implantação do protocolo ocorreu porque havia falhas graves no sistema.$ALT17_3$, false),
(17, 4, $ALT17_4$os alertas automáticos serão enviados exclusivamente aos agentes em serviço.$ALT17_4$, false),
(17, 5, $ALT17_5$o sistema passou a emitir todos os tipos possíveis de alerta.$ALT17_5$, false),
(18, 1, $ALT18_1$Pressupõe-se que a unidade encaminhava relatórios semanais anteriormente, interrompeu esse encaminhamento e o retomou.$ALT18_1$, true),
(18, 2, $ALT18_2$Afirma-se que a unidade jamais havia encaminhado relatórios semanais antes da atualização do sistema.$ALT18_2$, false),
(18, 3, $ALT18_3$Pressupõe-se que a atualização do sistema foi o único motivo da interrupção dos encaminhamentos.$ALT18_3$, false),
(18, 4, $ALT18_4$Infere-se que os relatórios encaminhados após a atualização foram aprovados pelo comando regional.$ALT18_4$, false),
(18, 5, $ALT18_5$Afirma-se que a unidade passará a encaminhar relatórios diariamente.$ALT18_5$, false),
(19, 1, $ALT19_1$O trecho autoriza a leitura de que já haviam sido registrados recordes de participação anteriormente.$ALT19_1$, true),
(19, 2, $ALT19_2$O trecho afirma que todos os participantes compareceram a todas as atividades do programa.$ALT19_2$, false),
(19, 3, $ALT19_3$O trecho pressupõe que os recordes anteriores foram anulados pela instituição.$ALT19_3$, false),
(19, 4, $ALT19_4$O trecho informa que a participação aumentará obrigatoriamente nos próximos semestres.$ALT19_4$, false),
(19, 5, $ALT19_5$O trecho indica que as atividades oferecidas no semestre eram inéditas.$ALT19_5$, false),
(20, 1, $ALT20_1$aprovaram a proposta integralmente e sem condições.$ALT20_1$, false),
(20, 2, $ALT20_2$rejeitaram a proposta de modo definitivo.$ALT20_2$, false),
(20, 3, $ALT20_3$aceitaram a proposta, mas apresentaram restrições ou ponderações.$ALT20_3$, true),
(20, 4, $ALT20_4$desconheciam o conteúdo da proposta apresentada.$ALT20_4$, false),
(20, 5, $ALT20_5$adiaram a análise da proposta para outra reunião.$ALT20_5$, false),
(21, 1, $ALT21_1$reduzir a quantidade ou eliminar etapas desnecessárias.$ALT21_1$, true),
(21, 2, $ALT21_2$secar documentos que haviam sido molhados.$ALT21_2$, false),
(21, 3, $ALT21_3$arquivar definitivamente os documentos recebidos.$ALT21_3$, false),
(21, 4, $ALT21_4$corrigir erros de redação nos documentos.$ALT21_4$, false),
(21, 5, $ALT21_5$ampliar o número de documentos encaminhados.$ALT21_5$, false),
(22, 1, $ALT22_1$A substituição é válida, pois a locução "no momento adequado" exerce função adverbial e preserva a ideia de divulgação em ocasião apropriada.$ALT22_1$, true),
(22, 2, $ALT22_2$A substituição é inválida, pois um advérbio só pode ser substituído por outro advérbio formado por uma única palavra.$ALT22_2$, false),
(22, 3, $ALT22_3$A substituição é válida porque "oportunamente" significa, necessariamente, "imediatamente".$ALT22_3$, false),
(22, 4, $ALT22_4$A substituição é inválida, pois o adjetivo "adequado" não pode integrar uma expressão que modifique o verbo "divulgadas".$ALT22_4$, false),
(22, 5, $ALT22_5$A substituição é válida somente se a forma verbal "seriam divulgadas" for alterada para "divulgariam".$ALT22_5$, false),
(23, 1, $ALT23_1$A substituição é válida, pois, nesse contexto, ambos os adjetivos designam acusações que apresentam poucos detalhes.$ALT23_1$, false),
(23, 2, $ALT23_2$A substituição é inválida, pois "levianas" caracteriza acusações irresponsáveis ou sem fundamento, enquanto "superficiais" remete, predominantemente, à falta de profundidade ou de detalhamento.$ALT23_2$, true),
(23, 3, $ALT23_3$A substituição é válida, pois "levianas" e "superficiais" são sinônimos absolutos em qualquer contexto.$ALT23_3$, false),
(23, 4, $ALT23_4$A substituição é inválida, pois o adjetivo "superficiais" não pode concordar com o substantivo feminino plural "acusações".$ALT23_4$, false),
(23, 5, $ALT23_5$A substituição é válida, desde que a preposição "contra" seja obrigatoriamente substituída por "sobre".$ALT23_5$, false),
(24, 1, $ALT24_1$A substituição é contextual e preserva o sentido central do trecho, embora “célere” tenha registro mais formal; isso não permite afirmar que as palavras sejam sinônimas absolutas em qualquer contexto.$ALT24_1$, true),
(24, 2, $ALT24_2$A substituição é inadequada, pois “célere” designa exclusivamente uma pessoa, enquanto “rápida” se refere apenas a ações.$ALT24_2$, false),
(24, 3, $ALT24_3$As palavras são sinônimas absolutas, pois todo sinônimo de dicionário pode substituir outro termo em qualquer enunciado.$ALT24_3$, false),
(24, 4, $ALT24_4$A substituição altera obrigatoriamente a classe gramatical de “célere”, impedindo a concordância com “atuação”.$ALT24_4$, false),
(24, 5, $ALT24_5$A substituição é incorreta, pois “rápida” só pode qualificar deslocamentos físicos, e não a atuação de uma guarnição.$ALT24_5$, false),
(25, 1, $ALT25_1$adiar a decisão sobre o pedido.$ALT25_1$, false),
(25, 2, $ALT25_2$conceder ou acolher o pedido.$ALT25_2$, true),
(25, 3, $ALT25_3$corrigir uma informação do pedido.$ALT25_3$, false),
(25, 4, $ALT25_4$divergir da solicitação apresentada.$ALT25_4$, false),
(25, 5, $ALT25_5$recusar formalmente o pedido.$ALT25_5$, false);

create temporary table _unidades_ordem (ordem_min int, ordem_max int, unidade_pedagogica_id uuid) on commit drop;
insert into _unidades_ordem (ordem_min, ordem_max, unidade_pedagogica_id) values
(1, 7, '9a4936e1-a9a6-452c-9385-d5a5899ae5c5'::uuid),
(8, 13, '57bf73b4-ca89-4809-bc8d-7bf1ae7fa4c2'::uuid),
(14, 19, '1a2158e8-f690-43ab-8ca5-051ba1c0fa3e'::uuid),
(20, 25, '290650b5-0f55-49e1-871e-932003447e41'::uuid);

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
  lower($DUP1$No contexto das orientações internas de uma unidade policial, assinale a alternativa que apresenta correta concordância nominal.$DUP1$),
  lower($DUP2$Assinale a alternativa que completa corretamente a frase, de acordo com a concordância nominal: “Para a segurança das operações, ________ as inspeções periódicas dos veículos oficiais.”$DUP2$),
  lower($DUP3$Em um comunicado interno da corporação, assinale a alternativa redigida de acordo com a norma-padrão quanto à concordância nominal.$DUP3$),
  lower($DUP4$Após o bloqueio de uma área isolada, assinale a alternativa correta quanto à concordância nominal.$DUP4$),
  lower($DUP5$Em uma comunicação interna, pretende-se redigir corretamente a seguinte frase:

“A planilha está ___ ao memorando, e os comprovantes estão disponíveis ___.”

Assinale a alternativa que completa, correta e respectivamente, as lacunas.$DUP5$),
  lower($DUP6$Durante o atendimento à ocorrência, as policiais ficaram ___ apreensivas, pois receberam apenas ___ diária para custear a alimentação. Assinale a alternativa que completa correta e respectivamente as lacunas.$DUP6$),
  lower($DUP7$Em um memorando, consta a frase: "As fotografias seguem em anexo ao relatório." Pretende-se substituir a locução invariável "em anexo" por um adjetivo de sentido equivalente. Assinale a reescrita correta.$DUP7$),
  lower($DUP8$No período “Os policiais compareceram ___ audiência de custódia designada para a manhã”, assinale a alternativa que preenche corretamente a lacuna conforme a norma-padrão.$DUP8$),
  lower($DUP9$Complete corretamente a lacuna da frase a seguir:

"Durante o patrulhamento, a guarnição deu prioridade ___ ocorrências com risco imediato à população."$DUP9$),
  lower($DUP10$Complete corretamente a lacuna da frase a seguir:

"Após a análise interna, as inconsistências no relatório vieram ___, exigindo providências da administração."$DUP10$),
  lower($DUP11$No trecho abaixo, assinale a alternativa que preenche corretamente a lacuna, de acordo com o emprego da crase.

"Após a reunião, a chefia orientou os integrantes ___ registrar as ocorrências no sistema eletrônico antes do encerramento do turno."$DUP11$),
  lower($DUP12$Em qual das alternativas o emprego do acento grave indicativo de crase é obrigatório?$DUP12$),
  lower($DUP13$Assinale a alternativa correta quanto ao emprego da crase.$DUP13$),
  lower($DUP14$Leia o enunciado elaborado para uma comunicação interna:

"Durante o treinamento de atendimento ao público, até o agente mais resistente às atividades digitais concluiu o módulo sem solicitar auxílio."

No contexto apresentado, o emprego de "até" permite inferir que$DUP14$),
  lower($DUP15$Leia o trecho de um relatório administrativo:

"A campanha de atualização cadastral mobilizou os setores da unidade, inclusive a equipe responsável pelo arquivo histórico, que normalmente atua em tarefas de preservação documental."

A respeito do conteúdo implícito produzido por "inclusive", assinale a alternativa correta.$DUP15$),
  lower($DUP16$Leia o enunciado institucional a seguir.

"Após a substituição dos equipamentos, a seção de comunicação parou de utilizar os rádios antigos."

Considerando o conteúdo implícito produzido pela expressão destacada, assinale a alternativa correta.$DUP16$),
  lower($DUP17$Leia o enunciado institucional a seguir.

"Com a implantação do novo protocolo, o sistema começou a emitir alertas automáticos de ocorrência."

A partir da expressão “começou a emitir”, é correto inferir que$DUP17$),
  lower($DUP18$Leia o enunciado a seguir.

"Após a atualização do sistema de registros, a unidade voltou a encaminhar os relatórios semanais ao comando regional."

Considerando o conteúdo implícito desencadeado pela locução destacada, assinale a alternativa correta.$DUP18$),
  lower($DUP19$Leia o trecho de uma nota institucional.

"O programa de treinamento registrou novos recordes de participação nas atividades oferecidas neste semestre."

A respeito do conteúdo implícito associado ao emprego de "novos", assinale a alternativa correta.$DUP19$),
  lower($DUP20$Leia o trecho a seguir:

“Após a reunião de planejamento, a proposta de redistribuição do efetivo foi acolhida com ressalvas pelos representantes das unidades.”

No contexto em que ocorre, o termo “ressalvas” indica que os representantes:$DUP20$),
  lower($DUP21$Leia o trecho a seguir:

“Com a implantação do sistema digital, o setor conseguiu enxugar o fluxo de documentos encaminhados diariamente às unidades.”

No contexto apresentado, o verbo “enxugar” significa:$DUP21$),
  lower($DUP22$Leia o trecho a seguir:

"A Seção de Recursos informou que as respostas seriam divulgadas oportunamente no portal institucional."

Considerando o sentido contextual e a estrutura da oração, assinale a alternativa correta acerca da substituição de "oportunamente" por "no momento adequado".$DUP22$),
  lower($DUP23$Leia o trecho a seguir:

"A chefia orientou os servidores a não formularem acusações levianas contra colegas."

Assinale a alternativa correta acerca da substituição de "levianas" por "superficiais" no trecho.$DUP23$),
  lower($DUP24$Leia o trecho de um memorando interno:

“Graças à atuação célere da guarnição, a ocorrência foi controlada antes de causar novos transtornos.”

Considerando o contexto apresentado, assinale a alternativa correta acerca da substituição de “célere” por “rápida”.$DUP24$),
  lower($DUP25$Leia o trecho a seguir:

“Após analisar os documentos apresentados, a chefia decidiu deferir o pedido de troca de turno.”

No contexto, o verbo “deferir” significa:$DUP25$)
  );
  if v_dup <> 0 then raise exception 'PRECOND: % questao(oes) com enunciado identico ja existem — possivel reexecucao/duplicidade', v_dup; end if;

  raise notice 'PRECONDICOES GLOBAIS OK: 0 duplicidade de enunciado entre as 25';
end $$;

-- ================= INSERT das 25 questoes =================
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
    select cc.curso_materia_id_materia, cc.assunto_id, 'Papiro', 'PAPIRO - Curadoria LOTE04_PORTUGUES_AUTORAL - BM RS', 2026, r.dificuldade, r.enunciado,
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

  insert into _relatorio values ('TARGET', 'questoes_delta_25', v_questoes - v_snap.total_questoes = 25, (v_questoes - v_snap.total_questoes)::text);
  insert into _relatorio values ('TARGET', 'alternativas_delta_125', v_alternativas - v_snap.total_alternativas = 125, (v_alternativas - v_snap.total_alternativas)::text);
  insert into _relatorio values ('TARGET', 'vinculos_delta_25', v_vinculos - v_snap.total_vinculos = 25, (v_vinculos - v_snap.total_vinculos)::text);
  insert into _relatorio values ('TARGET', 'curso_questoes_delta_25', v_curso_questoes - v_snap.total_curso_questoes = 25, (v_curso_questoes - v_snap.total_curso_questoes)::text);

  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='9a4936e1-a9a6-452c-9385-d5a5899ae5c5' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET', 'uteis_10_9a4936e1-a9a6-452c-9385-d5a5899ae5c5', v_uteis = 10, v_uteis::text);

  select count(distinct q.id) filter (where coalesce(lower(q.banca),'') not like '%papiro%'),
         count(distinct q.id) filter (where coalesce(lower(q.banca),'') like '%papiro%')
    into v_real, v_autoral
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='9a4936e1-a9a6-452c-9385-d5a5899ae5c5' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET', 'uteis10_9a4936e1-a9a6-452c-9385-d5a5899ae5c5', v_real + v_autoral = 10, (v_real + v_autoral)::text);

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=m.questao_id and correta=true), '' order by m.ordem)
    into v_gabaritos from _mapa_ids m where m.unidade_pedagogica_id = '9a4936e1-a9a6-452c-9385-d5a5899ae5c5';
  insert into _relatorio values ('TARGET', 'gabaritos_9a4936e1-a9a6-452c-9385-d5a5899ae5c5', v_gabaritos = 'BDBBAAB', v_gabaritos);

  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='57bf73b4-ca89-4809-bc8d-7bf1ae7fa4c2' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET', 'uteis_10_57bf73b4-ca89-4809-bc8d-7bf1ae7fa4c2', v_uteis = 10, v_uteis::text);

  select count(distinct q.id) filter (where coalesce(lower(q.banca),'') not like '%papiro%'),
         count(distinct q.id) filter (where coalesce(lower(q.banca),'') like '%papiro%')
    into v_real, v_autoral
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='57bf73b4-ca89-4809-bc8d-7bf1ae7fa4c2' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET', 'uteis10_57bf73b4-ca89-4809-bc8d-7bf1ae7fa4c2', v_real + v_autoral = 10, (v_real + v_autoral)::text);

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=m.questao_id and correta=true), '' order by m.ordem)
    into v_gabaritos from _mapa_ids m where m.unidade_pedagogica_id = '57bf73b4-ca89-4809-bc8d-7bf1ae7fa4c2';
  insert into _relatorio values ('TARGET', 'gabaritos_57bf73b4-ca89-4809-bc8d-7bf1ae7fa4c2', v_gabaritos = 'CBBBBB', v_gabaritos);

  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='1a2158e8-f690-43ab-8ca5-051ba1c0fa3e' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET', 'uteis_10_1a2158e8-f690-43ab-8ca5-051ba1c0fa3e', v_uteis = 10, v_uteis::text);

  select count(distinct q.id) filter (where coalesce(lower(q.banca),'') not like '%papiro%'),
         count(distinct q.id) filter (where coalesce(lower(q.banca),'') like '%papiro%')
    into v_real, v_autoral
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='1a2158e8-f690-43ab-8ca5-051ba1c0fa3e' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET', 'uteis10_1a2158e8-f690-43ab-8ca5-051ba1c0fa3e', v_real + v_autoral = 10, (v_real + v_autoral)::text);

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=m.questao_id and correta=true), '' order by m.ordem)
    into v_gabaritos from _mapa_ids m where m.unidade_pedagogica_id = '1a2158e8-f690-43ab-8ca5-051ba1c0fa3e';
  insert into _relatorio values ('TARGET', 'gabaritos_1a2158e8-f690-43ab-8ca5-051ba1c0fa3e', v_gabaritos = 'BCAAAA', v_gabaritos);

  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='290650b5-0f55-49e1-871e-932003447e41' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET', 'uteis_10_290650b5-0f55-49e1-871e-932003447e41', v_uteis = 10, v_uteis::text);

  select count(distinct q.id) filter (where coalesce(lower(q.banca),'') not like '%papiro%'),
         count(distinct q.id) filter (where coalesce(lower(q.banca),'') like '%papiro%')
    into v_real, v_autoral
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='290650b5-0f55-49e1-871e-932003447e41' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET', 'uteis10_290650b5-0f55-49e1-871e-932003447e41', v_real + v_autoral = 10, (v_real + v_autoral)::text);

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=m.questao_id and correta=true), '' order by m.ordem)
    into v_gabaritos from _mapa_ids m where m.unidade_pedagogica_id = '290650b5-0f55-49e1-871e-932003447e41';
  insert into _relatorio values ('TARGET', 'gabaritos_290650b5-0f55-49e1-871e-932003447e41', v_gabaritos = 'CAABAB', v_gabaritos);

  select count(*) into v_vinc_ok from _mapa_ids m
    where exists(select 1 from public.questao_unidades_pedagogicas qup where qup.questao_id=m.questao_id and qup.unidade_pedagogica_id=m.unidade_pedagogica_id)
    and not exists(select 1 from public.questao_unidades_pedagogicas qup2 where qup2.questao_id=m.questao_id and qup2.unidade_pedagogica_id <> m.unidade_pedagogica_id);
  insert into _relatorio values ('TARGET', 'vinculos_25_corretos', v_vinc_ok = 25, v_vinc_ok::text);

  select count(*) into v_cq_ok from _mapa_ids m
    where exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=m.questao_id);
  insert into _relatorio values ('TARGET', 'curso_questoes_25', v_cq_ok = 25, v_cq_ok::text);

  insert into _relatorio values ('TARGET', 'ativa_25de25',
    (select count(*) from _mapa_ids m join public.questoes q on q.id=m.questao_id where q.ativa) = 25, 'ativa');
  insert into _relatorio values ('TARGET', 'origem_papiro_25de25',
    (select count(*) from _mapa_ids m join public.questoes q on q.id=m.questao_id where coalesce(lower(q.banca),'') like '%papiro%') = 25, 'banca papiro');
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
  insert into _relatorio values ('REVERSAO', 'vinculos_removidos_25', v_count = 25, v_count::text);
end $$;

do $$
declare v_count int;
begin
  delete from public.curso_questoes where curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and questao_id in (select questao_id from _mapa_ids);
  get diagnostics v_count = row_count;
  insert into _relatorio values ('REVERSAO', 'curso_questoes_removidas_25', v_count = 25, v_count::text);
end $$;

do $$
declare v_count int;
begin
  delete from public.alternativas where questao_id in (select questao_id from _mapa_ids);
  get diagnostics v_count = row_count;
  insert into _relatorio values ('REVERSAO', 'alternativas_removidas_125', v_count = 125, v_count::text);
end $$;

do $$
declare v_count int;
begin
  delete from public.questoes where id in (select questao_id from _mapa_ids);
  get diagnostics v_count = row_count;
  insert into _relatorio values ('REVERSAO', 'questoes_removidas_25', v_count = 25, v_count::text);
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
    raise notice 'TESTE DE ROLLBACK: %/% checks OK — LOTE04_PORTUGUES_AUTORAL_ROLLBACK_TEST_APROVADO', v_ok, v_total;
  else
    raise notice 'TESTE DE ROLLBACK: %/% checks OK — HA FALHAS, ver _relatorio', v_ok, v_total;
  end if;
end $$;

rollback;
