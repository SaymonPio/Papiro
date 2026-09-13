-- POS-CHECK — importacao LOTE07_LEGISLACAO_INSTITUCIONAL.
--
-- READ-ONLY. Confirma, independentemente do apply, o estado das 23
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
  $PC1$Sobre a relação da Brigada Militar com a organização estadual de segurança pública, assinale a alternativa correta.$PC1$,
  $PC2$No contexto da organização institucional da Brigada Militar, a expressão “competências da instituição” refere-se, corretamente, ao conjunto de$PC2$,
  $PC3$A estrutura organizacional da Brigada Militar é composta por três níveis. Assinale a alternativa que apresenta corretamente essa composição.$PC3$,
  $PC4$Considerando a organização da Brigada Militar, assinale a alternativa que caracteriza corretamente a expressão Órgão de Polícia Militar (OPM).$PC4$,
  $PC5$Assinale a alternativa que apresenta corretamente a competência do Chefe do Estado-Maior da Brigada Militar.$PC5$,
  $PC6$Nos termos da Lei Complementar nº 16.450/2025, assinale a alternativa correta acerca do Estado-Maior da Brigada Militar.$PC6$,
  $PC7$Nos termos da Lei Complementar nº 16.450/2025, assinale a alternativa que apresenta corretamente atribuições do Subcomandante-Geral da Brigada Militar.$PC7$,
  $PC8$A respeito do Conselho Superior da Brigada Militar, conforme a Lei Complementar nº 16.450/2025, assinale a alternativa correta.$PC8$,
  $PC9$No âmbito da carreira dos Servidores Militares Estaduais de Nível Superior, assinale a alternativa que apresenta corretamente os quadros que compõem sua estrutura.$PC9$,
  $PC10$Considerando a inclusão no quadro de acesso destinado à promoção ao posto de Coronel, assinale a alternativa correta.$PC10$,
  $PC11$Para ingressar no Curso Superior de Polícia Militar, exige-se que o candidato seja aprovado em concurso público e possua qual formação?$PC11$,
  $PC12$Em relação à situação dos candidatos aprovados no concurso para ingresso no quadro de oficiais, assinale a alternativa correta quanto à denominação recebida durante a frequência do Curso Superior de Polícia Militar e à duração máxima desse curso.$PC12$,
  $PC13$No contexto das regras de promoção da carreira, assinale a situação em que um Capitão preenche, simultaneamente, as condições específicas exigidas para a promoção ao posto de Major.$PC13$,
  $PC14$Para que um Tenente-Coronel tenha acesso à promoção ao posto de Coronel, qual condição relativa à formação deve estar cumprida?$PC14$,
  $PC15$Assinale a alternativa que apresenta corretamente, de forma conjunta, as características do serviço policial-militar e da carreira de servidor militar.$PC15$,
  $PC16$Considerando as regras sobre os Oficiais nomeados Juízes do Tribunal Militar do Estado e sobre a precedência entre servidores militares, assinale a alternativa correta.$PC16$,
  $PC17$A respeito das consequências decorrentes da violação de obrigações e deveres policiais-militares, assinale a alternativa correta.$PC17$,
  $PC18$No rol de direitos dos servidores militares estaduais, assinale a alternativa que apresenta corretamente os direitos relacionados à inatividade e aos períodos de afastamento regular.$PC18$,
  $PC19$Quanto aos direitos assistenciais dos servidores militares estaduais, assinale a alternativa correta.$PC19$,
  $PC20$No tocante às sanções disciplinares e às respectivas formas de aplicação, assinale a alternativa correta.$PC20$,
  $PC21$Considerando as características da detenção e da prisão administrativa, assinale a alternativa correta.$PC21$,
  $PC22$Um militar estadual tomou conhecimento de fato contrário à disciplina e optou por comunicá-lo verbalmente ao seu superior imediato. Nessa situação, assinale a alternativa correta quanto à formalização da comunicação.$PC22$,
  $PC23$Em relação ao processo administrativo disciplinar militar, assinale a alternativa correta.$PC23$
)
order by q.id;
