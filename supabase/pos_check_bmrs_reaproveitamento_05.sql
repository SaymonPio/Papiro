-- POS-CHECK — reaproveitamento BMRS-05.
--
-- READ-ONLY. Confirma, independentemente do apply, que os 5 vínculos da
-- matriz congelada existem exatamente nas unidades corretas, que as 5
-- questões estão em curso_questoes(BMRS), e que nenhuma delas foi
-- vinculada a uma unidade errada. Não corrige nada.
--
-- Esperado após o apply: 5 linhas, todas ok_vinculo=true, ok_curso_questoes=true.
-- Antes do apply (baseline OLD): 5 linhas, todas ok_vinculo=false.

with matriz as (
  select * from (values
    (222,  '9a4936e1-a9a6-452c-9385-d5a5899ae5c5'::uuid, 'Concordância nominal'),
    (224,  '9a4936e1-a9a6-452c-9385-d5a5899ae5c5'::uuid, 'Concordância nominal'),
    (68,   '290650b5-0f55-49e1-871e-932003447e41'::uuid, 'Significação das palavras'),
    (1338, '53dc06a1-cd16-4004-a76b-8201d95a91c4'::uuid, 'Rede de justiça, equipe multidisciplinar e disposições finais'),
    (1342, '53dc06a1-cd16-4004-a76b-8201d95a91c4'::uuid, 'Rede de justiça, equipe multidisciplinar e disposições finais')
  ) as t(questao_id, unidade_id_esperada, unidade_titulo_esperado)
)
select
  m.questao_id,
  m.unidade_titulo_esperado,
  exists(
    select 1 from public.questao_unidades_pedagogicas qup
    where qup.questao_id = m.questao_id and qup.unidade_pedagogica_id = m.unidade_id_esperada
  ) as ok_vinculo,
  (
    select count(*) from public.questao_unidades_pedagogicas qup2
    where qup2.questao_id = m.questao_id and qup2.unidade_pedagogica_id <> m.unidade_id_esperada
  ) as vinculos_em_outra_unidade,
  exists(
    select 1 from public.curso_questoes cq
    where cq.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id = m.questao_id
  ) as ok_curso_questoes
from matriz m
order by m.questao_id;
