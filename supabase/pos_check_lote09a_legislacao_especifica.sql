-- POS-CHECK — importacao LOTE09A_LEGISLACAO_ESPECIFICA.
--
-- READ-ONLY. Confirma, independentemente do apply, o estado das 17
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
  $PC1$Uma lei federal disciplinou a concessão de determinado benefício administrativo e estabeleceu, de forma exaustiva, os requisitos para sua obtenção. Posteriormente, decreto presidencial editado para regulamentar a lei passou a exigir do interessado a apresentação de certidão adicional e a comprovação de condição não prevista no texto legal, sob pena de indeferimento do pedido. À luz do poder regulamentar, assinale a alternativa correta.$PC1$,
  $PC2$A lei que organiza determinado órgão público atribui expressamente ao Secretário da Pasta a competência para aplicar a sanção administrativa de suspensão a empresas contratadas pelo Poder Público. Durante a ausência temporária do Secretário, um diretor do órgão, sem delegação e sem previsão legal que lhe atribua essa competência, aplica diretamente a sanção a uma empresa. Nessa situação, o ato praticado pelo diretor caracteriza$PC2$,
  $PC3$Um prefeito determinou a remoção de um servidor para outra unidade administrativa. Embora a remoção estivesse formalmente dentro de sua esfera de atribuições, ficou comprovado que a medida foi adotada exclusivamente como retaliação às críticas feitas pelo servidor à gestão municipal, e não para atender a qualquer necessidade do serviço público. Nessa situação, o ato administrativo apresenta$PC3$,
  $PC4$Após a edição de uma lei federal que estabelece normas gerais sobre determinada atividade administrativa, pretende-se expedir decreto para detalhar os procedimentos necessários à sua fiel execução, sem inovar autonomamente na ordem jurídica. Nos termos da Constituição Federal, a competência para expedir esse decreto regulamentar é do$PC4$,
  $PC5$Nos termos do Código Tributário Nacional, uma atuação administrativa será considerada exercício regular do poder de polícia quando$PC5$,
  $PC6$De acordo com o conceito legal de poder de polícia previsto no Código Tributário Nacional, a limitação ou disciplina de direito, interesse ou liberdade pode ocorrer, entre outros motivos de interesse público, em razão de$PC6$,
  $PC7$No exercício de fiscalização administrativa de segurança, um agente público constata irregularidade em estabelecimento particular. Embora possa instaurar o procedimento cabível, afirma ao responsável que deixará de registrar a ocorrência caso receba vantagem pessoal. À luz dos princípios aplicáveis à atuação administrativa, assinale a alternativa correta.$PC7$,
  $PC8$Durante fiscalização urbanística, a Administração verifica que um comércio instalou uma placa em desacordo com exigência administrativa, mas a irregularidade pode ser corrigida mediante simples adequação do equipamento. Sem examinar medidas menos gravosas, a autoridade determina o fechamento integral e imediato do estabelecimento por prazo indeterminado. Considerando o princípio da proporcionalidade no exercício do poder de polícia, assinale a alternativa correta.$PC8$,
  $PC9$Durante fiscalização de segurança em estabelecimento particular, a autoridade administrativa determinou a suspensão imediata de uma atividade, limitando-se a registrar que a medida era “necessária ao interesse público”, sem apontar as circunstâncias verificadas nem a base jurídica da decisão. À luz do princípio da motivação, a conduta é$PC9$,
  $PC10$No planejamento de fiscalizações de segurança em estabelecimentos privados, a Administração dispõe de equipes limitadas e identifica locais com maior fluxo de pessoas e histórico de irregularidades. À luz do princípio da eficiência, a conduta mais adequada é:$PC10$,
  $PC11$Nos termos do Estatuto da Igualdade Racial, assinale a alternativa correta acerca da promoção da igualdade de oportunidades no mercado de trabalho.$PC11$,
  $PC12$De acordo com o Estatuto da Igualdade Racial, o Poder Executivo federal poderá implementar critérios para o provimento de cargos em comissão e funções de confiança com a finalidade de ampliar a participação de negros. Para tanto, tais critérios devem observar:$PC12$,
  $PC13$No âmbito da organização institucional da Política Nacional de Promoção da Igualdade Racial (PNPIR), assinale a alternativa correta acerca da elaboração das diretrizes das políticas nacional e regional de promoção da igualdade étnica.$PC13$,
  $PC14$Nos termos do Estatuto Nacional da Igualdade Racial, assinale a alternativa correta acerca dos critérios para o provimento de cargos em comissão e funções de confiança.$PC14$,
  $PC15$A respeito da relação entre as medidas previstas no Estatuto Nacional da Igualdade Racial e outras iniciativas estatais de promoção da igualdade racial, assinale a alternativa correta.$PC15$,
  $PC16$Durante a análise de um pedido administrativo, a autoridade competente observa todos os requisitos formais previstos e pratica ato que, em tese, está dentro de sua competência. Contudo, fica demonstrado que ela conduziu o procedimento com a intenção de prejudicar o requerente em razão de desavença pessoal antiga, valendo-se de justificativas apenas aparentes. Nessa situação, a conduta contraria principalmente o princípio da$PC16$,
  $PC17$Um gestor público determina que requerimentos administrativos de cidadãos identificados como opositores políticos de sua gestão sejam analisados somente depois dos requerimentos apresentados por seus apoiadores, embora todos preencham os mesmos requisitos e tenham sido protocolados na mesma data. Considerando a distinção entre impessoalidade e moralidade administrativa, assinale a alternativa correta.$PC17$
)
order by q.id;
