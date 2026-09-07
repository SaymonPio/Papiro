-- POS-CHECK — importação INFO-AUT-01.
--
-- READ-ONLY. Confirma, independentemente do apply, o estado das 2
-- questões autorais na unidade "Internet: conceitos, arquitetura e
-- protocolos". Não corrige nada.
--
-- Esperado após o apply: 2 linhas, todas com estrutura/vínculo/curso_questoes OK.

select
  q.id as questao_id,
  q.ativa,
  coalesce(lower(q.banca),'') like '%papiro%' as autoral,
  (select count(*) from public.alternativas a where a.questao_id = q.id) as n_alternativas,
  (select count(*) from public.alternativas a where a.questao_id = q.id and a.correta) as n_corretas,
  (select chr(64+ordem) from public.alternativas where questao_id=q.id and correta=true) as gabarito,
  exists(
    select 1 from public.questao_unidades_pedagogicas qup
    where qup.questao_id = q.id and qup.unidade_pedagogica_id = 'd9153747-6150-4a1f-8bb8-f4ea433f672f'
  ) as ok_vinculo_unidade_correta,
  exists(
    select 1 from public.curso_questoes cq
    where cq.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id = q.id
  ) as ok_curso_questoes,
  q.explicacao is not null and length(q.explicacao) > 0 as ok_explicacao
from public.questoes q
where q.enunciado in (
  'Em relação aos protocolos HTTP e HTTPS utilizados na Web, assinale a alternativa CORRETA.',
  'Em relação aos protocolos de transporte TCP (Transmission Control Protocol) e UDP (User Datagram Protocol), assinale a alternativa CORRETA.'
)
order by q.id;
