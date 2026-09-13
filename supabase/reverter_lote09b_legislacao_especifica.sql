-- REVERSAO REAL — importacao LOTE09B_LEGISLACAO_ESPECIFICA.
--
-- Remove EXATAMENTE as 7 questoes importadas por
-- importar_lote09b_legislacao_especifica.sql (identificadas por enunciado
-- + prefixo de fonte, nunca um DELETE amplo). Cascata (FKs) remove
-- alternativas, questao_unidades_pedagogicas e curso_questoes associados.
-- NAO usar em condicoes normais — apenas se for necessario desfazer esta
-- importacao especifica. NAO apaga nenhuma outra questao das 2 unidades.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

do $$
declare
  v_ids bigint[];
  v_count int;
begin
  select array_agg(id) into v_ids
  from public.questoes
  where fonte like 'PAPIRO — LOTE09B_LEGISLACAO_ESPECIFICA — %'
  and enunciado in (
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
  );

  v_count := coalesce(array_length(v_ids, 1), 0);
  if v_count <> 7 then
    raise exception 'REVERTER: esperado encontrar exatamente 7 questoes para reverter, encontrado %', v_count;
  end if;

  delete from public.curso_questoes where questao_id = any(v_ids);
  delete from public.questao_unidades_pedagogicas where questao_id = any(v_ids);
  delete from public.alternativas where questao_id = any(v_ids);
  delete from public.questoes where id = any(v_ids);

  raise notice 'REVERSAO OK: % questoes removidas (com alternativas/vinculos/curso_questoes em cascata)', v_count;
end $$;

commit;
