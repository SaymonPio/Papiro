-- POS-CHECK — importacao LOTE09B_LEGISLACAO_ESPECIFICA.
--
-- READ-ONLY. Confirma, independentemente do apply, o estado das 7
-- questoes autorais nas 2 unidades. Nao corrige nada.

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
  q.explicacao is not null and length(q.explicacao) > 0 as ok_explicacao,
  position(chr(92)||'n' in q.enunciado) = 0 and position(chr(92)||'n' in q.explicacao) = 0 as ok_sem_escape_literal
from public.questoes q
where q.enunciado in (
  $PC1$Após a aprovação de um projeto de lei pelo Congresso Nacional, o Presidente da República pratica o ato de sancioná-lo, promulgá-lo e determinar sua publicação. Posteriormente, para viabilizar a execução fiel dessa lei, expede decreto com disposições operacionais compatíveis com seu conteúdo. À luz do art. 84, IV, da Constituição Federal, os dois atos correspondem, respectivamente, a:$PC1$,
  $PC2$Considere as situações a seguir:

I. A chefia de uma coordenadoria acompanhou a execução de atividades por órgão subordinado e, diante de falhas verificadas, chamou para si a análise de procedimento que estava em curso naquele órgão.

II. A Administração instaurou procedimento para apurar conduta funcional incompatível com os deveres do cargo e, assegurada a apuração cabível, aplicou sanção ao servidor responsável.

A classificação correta dos poderes que fundamentam as situações I e II é, respectivamente,$PC2$,
  $PC3$No julgamento da ADPF 635/RJ, conhecido como “ADPF das Favelas”, o STF examinou medidas voltadas à redução da letalidade policial no Estado do Rio de Janeiro. Considerando os limites e o alcance da decisão, assinale a alternativa correta.$PC3$,
  $PC4$À luz do entendimento firmado pelo STF na ADPF 347/DF sobre audiência de custódia, assinale a alternativa correta.$PC4$,
  $PC5$Em um estabelecimento prisional, a direção determina que todos os visitantes, indistintamente, sejam submetidos a desnudamento e a procedimentos corporais invasivos antes do ingresso, embora existam meios tecnológicos e outras formas menos invasivas de vistoria. À luz da tese final firmada pelo STF no Tema 998 da repercussão geral, assinale a alternativa correta.$PC5$,
  $PC6$Considere as situações a seguir.

I. Policiais persuadem Renata a oferecer uma caixa supostamente contendo mercadorias ilícitas a um comprador indicado pelos próprios agentes. A caixa, contudo, fora previamente esvaziada e mantida sob integral controle policial, de modo que a entrega do objeto era inviável.

II. Após receberem informação de que Otávio, por iniciativa própria, realizaria uma venda ilícita em determinado local, policiais apenas passam a observar o ponto, sem qualquer contato ou estímulo ao suspeito, e efetuam a prisão quando ele inicia a entrega do objeto ao comprador.

Conforme a Súmula 145 do STF, assinale a alternativa correta.$PC6$,
  $PC7$Em processo criminal, a defesa sustenta que determinada prova deve ser automaticamente desconsiderada porque houve falhas na documentação de sua cadeia de custódia. À luz do entendimento exposto pela Sexta Turma do STJ no HC 653.515/RJ, assinale a alternativa correta.$PC7$
)
order by q.id;
