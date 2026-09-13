-- REVERSAO REAL da IMPORTACAO LOTE09A_LEGISLACAO_ESPECIFICA. NUNCA
-- executado automaticamente. Disponivel para uso manual futuro caso a
-- importacao precise ser desfeita.
--
-- Identifica as 17 questoes pelo enunciado EXATO (congelado) + banca
-- 'Papiro' + vinculo a uma das 4 unidades do lote — nunca por um range
-- de ID. Remove nesta ordem: vinculo (RPC sancionada
-- remover_classificacao_questao_unidade_admin) -> curso_questoes ->
-- alternativas -> questoes.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _enunciados_lote (enunciado text) on commit drop;
insert into _enunciados_lote (enunciado) values
  $ENREV1$Uma lei federal disciplinou a concessão de determinado benefício administrativo e estabeleceu, de forma exaustiva, os requisitos para sua obtenção. Posteriormente, decreto presidencial editado para regulamentar a lei passou a exigir do interessado a apresentação de certidão adicional e a comprovação de condição não prevista no texto legal, sob pena de indeferimento do pedido. À luz do poder regulamentar, assinale a alternativa correta.$ENREV1$,
  $ENREV2$A lei que organiza determinado órgão público atribui expressamente ao Secretário da Pasta a competência para aplicar a sanção administrativa de suspensão a empresas contratadas pelo Poder Público. Durante a ausência temporária do Secretário, um diretor do órgão, sem delegação e sem previsão legal que lhe atribua essa competência, aplica diretamente a sanção a uma empresa. Nessa situação, o ato praticado pelo diretor caracteriza$ENREV2$,
  $ENREV3$Um prefeito determinou a remoção de um servidor para outra unidade administrativa. Embora a remoção estivesse formalmente dentro de sua esfera de atribuições, ficou comprovado que a medida foi adotada exclusivamente como retaliação às críticas feitas pelo servidor à gestão municipal, e não para atender a qualquer necessidade do serviço público. Nessa situação, o ato administrativo apresenta$ENREV3$,
  $ENREV4$Após a edição de uma lei federal que estabelece normas gerais sobre determinada atividade administrativa, pretende-se expedir decreto para detalhar os procedimentos necessários à sua fiel execução, sem inovar autonomamente na ordem jurídica. Nos termos da Constituição Federal, a competência para expedir esse decreto regulamentar é do$ENREV4$,
  $ENREV5$Nos termos do Código Tributário Nacional, uma atuação administrativa será considerada exercício regular do poder de polícia quando$ENREV5$,
  $ENREV6$De acordo com o conceito legal de poder de polícia previsto no Código Tributário Nacional, a limitação ou disciplina de direito, interesse ou liberdade pode ocorrer, entre outros motivos de interesse público, em razão de$ENREV6$,
  $ENREV7$No exercício de fiscalização administrativa de segurança, um agente público constata irregularidade em estabelecimento particular. Embora possa instaurar o procedimento cabível, afirma ao responsável que deixará de registrar a ocorrência caso receba vantagem pessoal. À luz dos princípios aplicáveis à atuação administrativa, assinale a alternativa correta.$ENREV7$,
  $ENREV8$Durante fiscalização urbanística, a Administração verifica que um comércio instalou uma placa em desacordo com exigência administrativa, mas a irregularidade pode ser corrigida mediante simples adequação do equipamento. Sem examinar medidas menos gravosas, a autoridade determina o fechamento integral e imediato do estabelecimento por prazo indeterminado. Considerando o princípio da proporcionalidade no exercício do poder de polícia, assinale a alternativa correta.$ENREV8$,
  $ENREV9$Durante fiscalização de segurança em estabelecimento particular, a autoridade administrativa determinou a suspensão imediata de uma atividade, limitando-se a registrar que a medida era “necessária ao interesse público”, sem apontar as circunstâncias verificadas nem a base jurídica da decisão. À luz do princípio da motivação, a conduta é$ENREV9$,
  $ENREV10$No planejamento de fiscalizações de segurança em estabelecimentos privados, a Administração dispõe de equipes limitadas e identifica locais com maior fluxo de pessoas e histórico de irregularidades. À luz do princípio da eficiência, a conduta mais adequada é:$ENREV10$,
  $ENREV11$Nos termos do Estatuto da Igualdade Racial, assinale a alternativa correta acerca da promoção da igualdade de oportunidades no mercado de trabalho.$ENREV11$,
  $ENREV12$De acordo com o Estatuto da Igualdade Racial, o Poder Executivo federal poderá implementar critérios para o provimento de cargos em comissão e funções de confiança com a finalidade de ampliar a participação de negros. Para tanto, tais critérios devem observar:$ENREV12$,
  $ENREV13$No âmbito da organização institucional da Política Nacional de Promoção da Igualdade Racial (PNPIR), assinale a alternativa correta acerca da elaboração das diretrizes das políticas nacional e regional de promoção da igualdade étnica.$ENREV13$,
  $ENREV14$Nos termos do Estatuto Nacional da Igualdade Racial, assinale a alternativa correta acerca dos critérios para o provimento de cargos em comissão e funções de confiança.$ENREV14$,
  $ENREV15$A respeito da relação entre as medidas previstas no Estatuto Nacional da Igualdade Racial e outras iniciativas estatais de promoção da igualdade racial, assinale a alternativa correta.$ENREV15$,
  $ENREV16$Durante a análise de um pedido administrativo, a autoridade competente observa todos os requisitos formais previstos e pratica ato que, em tese, está dentro de sua competência. Contudo, fica demonstrado que ela conduziu o procedimento com a intenção de prejudicar o requerente em razão de desavença pessoal antiga, valendo-se de justificativas apenas aparentes. Nessa situação, a conduta contraria principalmente o princípio da$ENREV16$,
  $ENREV17$Um gestor público determina que requerimentos administrativos de cidadãos identificados como opositores políticos de sua gestão sejam analisados somente depois dos requerimentos apresentados por seus apoiadores, embora todos preencham os mesmos requisitos e tenham sido protocolados na mesma data. Considerando a distinção entre impessoalidade e moralidade administrativa, assinale a alternativa correta.$ENREV17$;

create temporary table _unidades_lote (unidade_pedagogica_id uuid) on commit drop;
insert into _unidades_lote (unidade_pedagogica_id) values
  ('8cb82a8e-e0f4-4d46-a4a5-7443f31912a4'::uuid),
  ('2f0d3b9c-fe22-4173-a712-cfb9e1060b8c'::uuid),
  ('5bf890e1-8e09-4f7a-9410-7f5e5168d9c4'::uuid),
  ('1172a885-1419-4ad8-b728-1a0c7492c133'::uuid);

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
  if v_qtd <> 17 then
    raise exception 'PRECOND: esperado localizar exatamente 17 questoes do lote, encontrado %', v_qtd;
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
  if v_count <> 17 then raise exception 'REVERSAO: vinculos removidos=% esperado 17', v_count; end if;
end $$;

do $$
declare v_count int;
begin
  delete from public.curso_questoes where curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and questao_id in (select questao_id from _alvo);
  get diagnostics v_count = row_count;
  if v_count <> 17 then raise exception 'REVERSAO: curso_questoes removidas=% esperado 17', v_count; end if;
end $$;

do $$
declare v_count int;
begin
  delete from public.alternativas where questao_id in (select questao_id from _alvo);
  get diagnostics v_count = row_count;
  if v_count <> 85 then raise exception 'REVERSAO: alternativas removidas=% esperado 85', v_count; end if;
end $$;

do $$
declare v_count int;
begin
  delete from public.questoes where id in (select questao_id from _alvo);
  get diagnostics v_count = row_count;
  if v_count <> 17 then raise exception 'REVERSAO: questoes removidas=% esperado 17', v_count; end if;
end $$;

commit;
