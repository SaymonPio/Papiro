-- POS-CHECK — saneamento LOB-BM (Q43, Q271, Q272), v2.
--
-- READ-ONLY. Confirma, independentemente do apply, o estado final das 3
-- questoes, incluindo a reclassificacao de assunto_id de Q272. Nao
-- corrige nada.

select 43 as questao_id, q.ativa, q.assunto_id,
  (select chr(64+ordem) from public.alternativas where questao_id=43 and correta=true) as gabarito,
  q.explicacao not like '%em todas as atividades institucionais e operacionais%' as sem_amplitude_nao_confirmada,
  q.explicacao like '%CONTEXTO HISTÓRICO%' and q.explicacao like '%CONTEXTO ATUAL%' as tem_distincao_temporal,
  exists(select 1 from public.questao_unidades_pedagogicas where questao_id=43 and unidade_pedagogica_id='3c033d9a-5543-422a-a935-c55095bdfc86') as ok_vinculo_lob
from public.questoes q where q.id = 43
union all
select 271, q.ativa, q.assunto_id,
  (select chr(64+ordem) from public.alternativas where questao_id=271 and correta=true),
  q.explicacao not ilike '%10.991/1997 e alterações%',
  q.explicacao ilike '%16.450/2025%',
  exists(select 1 from public.questao_unidades_pedagogicas where questao_id=271 and unidade_pedagogica_id='3c033d9a-5543-422a-a935-c55095bdfc86')
from public.questoes q where q.id = 271
union all
select 272, q.ativa, q.assunto_id,
  (select chr(64+ordem) from public.alternativas where questao_id=272 and correta=true),
  q.assunto_id = 17,
  not exists(select 1 from public.questao_unidades_pedagogicas where questao_id=272 and unidade_pedagogica_id='3c033d9a-5543-422a-a935-c55095bdfc86'),
  exists(select 1 from public.questao_unidades_pedagogicas where questao_id=272 and unidade_pedagogica_id='7cc8a187-da9b-457d-beeb-f496ddd32580')
from public.questoes q where q.id = 272
order by 1;

-- checagem separada da curso_questoes de Q272 (id/prioridade/criado_em congelados)
select
  cq.id = 307 and cq.prioridade = 1 and cq.criado_em = '2026-08-10 04:19:17.848316+00'::timestamptz as curso_questoes_q272_intacta
from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=272;
