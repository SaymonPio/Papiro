-- POS-CHECK — importacao LOTE04_PORTUGUES_AUTORAL.
--
-- READ-ONLY. Confirma, independentemente do apply, o estado das 25
-- questoes autorais nas 4 unidades. Nao corrige nada.

select
  q.id as questao_id,
  q.ativa,
  q.dificuldade,
  coalesce(lower(q.banca),'') like '%papiro%' as autoral,
  (select count(*) from public.alternativas a where a.questao_id = q.id) as n_alternativas,
  (select count(*) from public.alternativas a where a.questao_id = q.id and a.correta) as n_corretas,
  (select chr(64+ordem) from public.alternativas where questao_id=q.id and correta=true) as gabarito,
  (select up.titulo from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where qup.questao_id = q.id limit 1) as unidade_vinculada,
  (select count(*) from public.questao_unidades_pedagogicas qup where qup.questao_id = q.id) as n_vinculos_totais,
  exists(
    select 1 from public.curso_questoes cq
    where cq.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id = q.id
  ) as ok_curso_questoes,
  q.explicacao is not null and length(q.explicacao) > 0 as ok_explicacao
from public.questoes q
where q.enunciado in (
  $PC1$No contexto das orientações internas de uma unidade policial, assinale a alternativa que apresenta correta concordância nominal.$PC1$,
  $PC2$Assinale a alternativa que completa corretamente a frase, de acordo com a concordância nominal: “Para a segurança das operações, ________ as inspeções periódicas dos veículos oficiais.”$PC2$,
  $PC3$Em um comunicado interno da corporação, assinale a alternativa redigida de acordo com a norma-padrão quanto à concordância nominal.$PC3$,
  $PC4$Após o bloqueio de uma área isolada, assinale a alternativa correta quanto à concordância nominal.$PC4$,
  $PC5$Em uma comunicação interna, pretende-se redigir corretamente a seguinte frase:

“A planilha está ___ ao memorando, e os comprovantes estão disponíveis ___.”

Assinale a alternativa que completa, correta e respectivamente, as lacunas.$PC5$,
  $PC6$Durante o atendimento à ocorrência, as policiais ficaram ___ apreensivas, pois receberam apenas ___ diária para custear a alimentação. Assinale a alternativa que completa correta e respectivamente as lacunas.$PC6$,
  $PC7$Em um memorando, consta a frase: "As fotografias seguem em anexo ao relatório." Pretende-se substituir a locução invariável "em anexo" por um adjetivo de sentido equivalente. Assinale a reescrita correta.$PC7$,
  $PC8$No período “Os policiais compareceram ___ audiência de custódia designada para a manhã”, assinale a alternativa que preenche corretamente a lacuna conforme a norma-padrão.$PC8$,
  $PC9$Complete corretamente a lacuna da frase a seguir:

"Durante o patrulhamento, a guarnição deu prioridade ___ ocorrências com risco imediato à população."$PC9$,
  $PC10$Complete corretamente a lacuna da frase a seguir:

"Após a análise interna, as inconsistências no relatório vieram ___, exigindo providências da administração."$PC10$,
  $PC11$No trecho abaixo, assinale a alternativa que preenche corretamente a lacuna, de acordo com o emprego da crase.

"Após a reunião, a chefia orientou os integrantes ___ registrar as ocorrências no sistema eletrônico antes do encerramento do turno."$PC11$,
  $PC12$Em qual das alternativas o emprego do acento grave indicativo de crase é obrigatório?$PC12$,
  $PC13$Assinale a alternativa correta quanto ao emprego da crase.$PC13$,
  $PC14$Leia o enunciado elaborado para uma comunicação interna:

"Durante o treinamento de atendimento ao público, até o agente mais resistente às atividades digitais concluiu o módulo sem solicitar auxílio."

No contexto apresentado, o emprego de "até" permite inferir que$PC14$,
  $PC15$Leia o trecho de um relatório administrativo:

"A campanha de atualização cadastral mobilizou os setores da unidade, inclusive a equipe responsável pelo arquivo histórico, que normalmente atua em tarefas de preservação documental."

A respeito do conteúdo implícito produzido por "inclusive", assinale a alternativa correta.$PC15$,
  $PC16$Leia o enunciado institucional a seguir.

"Após a substituição dos equipamentos, a seção de comunicação parou de utilizar os rádios antigos."

Considerando o conteúdo implícito produzido pela expressão destacada, assinale a alternativa correta.$PC16$,
  $PC17$Leia o enunciado institucional a seguir.

"Com a implantação do novo protocolo, o sistema começou a emitir alertas automáticos de ocorrência."

A partir da expressão “começou a emitir”, é correto inferir que$PC17$,
  $PC18$Leia o enunciado a seguir.

"Após a atualização do sistema de registros, a unidade voltou a encaminhar os relatórios semanais ao comando regional."

Considerando o conteúdo implícito desencadeado pela locução destacada, assinale a alternativa correta.$PC18$,
  $PC19$Leia o trecho de uma nota institucional.

"O programa de treinamento registrou novos recordes de participação nas atividades oferecidas neste semestre."

A respeito do conteúdo implícito associado ao emprego de "novos", assinale a alternativa correta.$PC19$,
  $PC20$Leia o trecho a seguir:

“Após a reunião de planejamento, a proposta de redistribuição do efetivo foi acolhida com ressalvas pelos representantes das unidades.”

No contexto em que ocorre, o termo “ressalvas” indica que os representantes:$PC20$,
  $PC21$Leia o trecho a seguir:

“Com a implantação do sistema digital, o setor conseguiu enxugar o fluxo de documentos encaminhados diariamente às unidades.”

No contexto apresentado, o verbo “enxugar” significa:$PC21$,
  $PC22$Leia o trecho a seguir:

"A Seção de Recursos informou que as respostas seriam divulgadas oportunamente no portal institucional."

Considerando o sentido contextual e a estrutura da oração, assinale a alternativa correta acerca da substituição de "oportunamente" por "no momento adequado".$PC22$,
  $PC23$Leia o trecho a seguir:

"A chefia orientou os servidores a não formularem acusações levianas contra colegas."

Assinale a alternativa correta acerca da substituição de "levianas" por "superficiais" no trecho.$PC23$,
  $PC24$Leia o trecho de um memorando interno:

“Graças à atuação célere da guarnição, a ocorrência foi controlada antes de causar novos transtornos.”

Considerando o contexto apresentado, assinale a alternativa correta acerca da substituição de “célere” por “rápida”.$PC24$,
  $PC25$Leia o trecho a seguir:

“Após analisar os documentos apresentados, a chefia decidiu deferir o pedido de troca de turno.”

No contexto, o verbo “deferir” significa:$PC25$
)
order by q.id;
