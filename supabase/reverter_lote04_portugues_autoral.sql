-- REVERSAO REAL da IMPORTACAO LOTE04_PORTUGUES_AUTORAL. NUNCA executado
-- automaticamente. Disponivel para uso manual futuro caso a importacao
-- precise ser desfeita.
--
-- Identifica as 25 questoes pelo enunciado EXATO (congelado, incluindo a
-- edicao humana aplicada em CRASE-08) + banca 'Papiro' + vinculo a uma das
-- 4 unidades do lote — nunca por um range de ID. Remove nesta ordem: vinculo
-- (RPC sancionada remover_classificacao_questao_unidade_admin) ->
-- curso_questoes -> alternativas -> questoes.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _enunciados_lote (enunciado text) on commit drop;
insert into _enunciados_lote (enunciado) values
  $ENREV1$No contexto das orientações internas de uma unidade policial, assinale a alternativa que apresenta correta concordância nominal.$ENREV1$,
  $ENREV2$Assinale a alternativa que completa corretamente a frase, de acordo com a concordância nominal: “Para a segurança das operações, ________ as inspeções periódicas dos veículos oficiais.”$ENREV2$,
  $ENREV3$Em um comunicado interno da corporação, assinale a alternativa redigida de acordo com a norma-padrão quanto à concordância nominal.$ENREV3$,
  $ENREV4$Após o bloqueio de uma área isolada, assinale a alternativa correta quanto à concordância nominal.$ENREV4$,
  $ENREV5$Em uma comunicação interna, pretende-se redigir corretamente a seguinte frase:

“A planilha está ___ ao memorando, e os comprovantes estão disponíveis ___.”

Assinale a alternativa que completa, correta e respectivamente, as lacunas.$ENREV5$,
  $ENREV6$Durante o atendimento à ocorrência, as policiais ficaram ___ apreensivas, pois receberam apenas ___ diária para custear a alimentação. Assinale a alternativa que completa correta e respectivamente as lacunas.$ENREV6$,
  $ENREV7$Em um memorando, consta a frase: "As fotografias seguem em anexo ao relatório." Pretende-se substituir a locução invariável "em anexo" por um adjetivo de sentido equivalente. Assinale a reescrita correta.$ENREV7$,
  $ENREV8$No período “Os policiais compareceram ___ audiência de custódia designada para a manhã”, assinale a alternativa que preenche corretamente a lacuna conforme a norma-padrão.$ENREV8$,
  $ENREV9$Complete corretamente a lacuna da frase a seguir:

"Durante o patrulhamento, a guarnição deu prioridade ___ ocorrências com risco imediato à população."$ENREV9$,
  $ENREV10$Complete corretamente a lacuna da frase a seguir:

"Após a análise interna, as inconsistências no relatório vieram ___, exigindo providências da administração."$ENREV10$,
  $ENREV11$No trecho abaixo, assinale a alternativa que preenche corretamente a lacuna, de acordo com o emprego da crase.

"Após a reunião, a chefia orientou os integrantes ___ registrar as ocorrências no sistema eletrônico antes do encerramento do turno."$ENREV11$,
  $ENREV12$Em qual das alternativas o emprego do acento grave indicativo de crase é obrigatório?$ENREV12$,
  $ENREV13$Assinale a alternativa correta quanto ao emprego da crase.$ENREV13$,
  $ENREV14$Leia o enunciado elaborado para uma comunicação interna:

"Durante o treinamento de atendimento ao público, até o agente mais resistente às atividades digitais concluiu o módulo sem solicitar auxílio."

No contexto apresentado, o emprego de "até" permite inferir que$ENREV14$,
  $ENREV15$Leia o trecho de um relatório administrativo:

"A campanha de atualização cadastral mobilizou os setores da unidade, inclusive a equipe responsável pelo arquivo histórico, que normalmente atua em tarefas de preservação documental."

A respeito do conteúdo implícito produzido por "inclusive", assinale a alternativa correta.$ENREV15$,
  $ENREV16$Leia o enunciado institucional a seguir.

"Após a substituição dos equipamentos, a seção de comunicação parou de utilizar os rádios antigos."

Considerando o conteúdo implícito produzido pela expressão destacada, assinale a alternativa correta.$ENREV16$,
  $ENREV17$Leia o enunciado institucional a seguir.

"Com a implantação do novo protocolo, o sistema começou a emitir alertas automáticos de ocorrência."

A partir da expressão “começou a emitir”, é correto inferir que$ENREV17$,
  $ENREV18$Leia o enunciado a seguir.

"Após a atualização do sistema de registros, a unidade voltou a encaminhar os relatórios semanais ao comando regional."

Considerando o conteúdo implícito desencadeado pela locução destacada, assinale a alternativa correta.$ENREV18$,
  $ENREV19$Leia o trecho de uma nota institucional.

"O programa de treinamento registrou novos recordes de participação nas atividades oferecidas neste semestre."

A respeito do conteúdo implícito associado ao emprego de "novos", assinale a alternativa correta.$ENREV19$,
  $ENREV20$Leia o trecho a seguir:

“Após a reunião de planejamento, a proposta de redistribuição do efetivo foi acolhida com ressalvas pelos representantes das unidades.”

No contexto em que ocorre, o termo “ressalvas” indica que os representantes:$ENREV20$,
  $ENREV21$Leia o trecho a seguir:

“Com a implantação do sistema digital, o setor conseguiu enxugar o fluxo de documentos encaminhados diariamente às unidades.”

No contexto apresentado, o verbo “enxugar” significa:$ENREV21$,
  $ENREV22$Leia o trecho a seguir:

"A Seção de Recursos informou que as respostas seriam divulgadas oportunamente no portal institucional."

Considerando o sentido contextual e a estrutura da oração, assinale a alternativa correta acerca da substituição de "oportunamente" por "no momento adequado".$ENREV22$,
  $ENREV23$Leia o trecho a seguir:

"A chefia orientou os servidores a não formularem acusações levianas contra colegas."

Assinale a alternativa correta acerca da substituição de "levianas" por "superficiais" no trecho.$ENREV23$,
  $ENREV24$Leia o trecho de um memorando interno:

“Graças à atuação célere da guarnição, a ocorrência foi controlada antes de causar novos transtornos.”

Considerando o contexto apresentado, assinale a alternativa correta acerca da substituição de “célere” por “rápida”.$ENREV24$,
  $ENREV25$Leia o trecho a seguir:

“Após analisar os documentos apresentados, a chefia decidiu deferir o pedido de troca de turno.”

No contexto, o verbo “deferir” significa:$ENREV25$;

create temporary table _unidades_lote (unidade_pedagogica_id uuid) on commit drop;
insert into _unidades_lote (unidade_pedagogica_id) values
  ('9a4936e1-a9a6-452c-9385-d5a5899ae5c5'::uuid),
  ('57bf73b4-ca89-4809-bc8d-7bf1ae7fa4c2'::uuid),
  ('1a2158e8-f690-43ab-8ca5-051ba1c0fa3e'::uuid),
  ('290650b5-0f55-49e1-871e-932003447e41'::uuid);

create temporary table _alvo (questao_id bigint primary key, unidade_pedagogica_id uuid) on commit drop;
insert into _alvo (questao_id, unidade_pedagogica_id)
select distinct q.id, qup.unidade_pedagogica_id
from public.questoes q
join public.questao_unidades_pedagogicas qup on qup.questao_id = q.id
where coalesce(lower(q.banca),'') like '%papiro%'
  and lower(q.enunciado) in (select lower(enunciado) from _enunciados_lote)
  and qup.unidade_pedagogica_id in (select unidade_pedagogica_id from _unidades_lote);

do $$
declare v_qtd int;
begin
  select count(*) into v_qtd from _alvo;
  if v_qtd <> 25 then
    raise exception 'PRECOND: esperado localizar exatamente 25 questoes do lote, encontrado %', v_qtd;
  end if;
end $$;

do $$
declare
  r record;
  v_count int := 0;
begin
  for r in select questao_id, unidade_pedagogica_id from _alvo loop
    perform public.remover_classificacao_questao_unidade_admin(r.questao_id, r.unidade_pedagogica_id);
    v_count := v_count + 1;
  end loop;
  if v_count <> 25 then raise exception 'REVERSAO: vinculos removidos=% esperado 25', v_count; end if;
end $$;

do $$
declare v_count int;
begin
  delete from public.curso_questoes where curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and questao_id in (select questao_id from _alvo);
  get diagnostics v_count = row_count;
  if v_count <> 25 then raise exception 'REVERSAO: curso_questoes removidas=% esperado 25', v_count; end if;
end $$;

do $$
declare v_count int;
begin
  delete from public.alternativas where questao_id in (select questao_id from _alvo);
  get diagnostics v_count = row_count;
  if v_count <> 125 then raise exception 'REVERSAO: alternativas removidas=% esperado 125', v_count; end if;
end $$;

do $$
declare v_count int;
begin
  delete from public.questoes where id in (select questao_id from _alvo);
  get diagnostics v_count = row_count;
  if v_count <> 25 then raise exception 'REVERSAO: questoes removidas=% esperado 25', v_count; end if;
end $$;

commit;
