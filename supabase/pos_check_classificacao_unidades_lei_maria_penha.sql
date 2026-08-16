-- ETAPA 9 do PROMPT MESTRE de curadoria das unidades pedagógicas da Lei
-- Maria da Penha — pós-check DEPOIS de aplicar
-- supabase/classificar_questoes_unidades_lei_maria_penha.sql com sucesso
-- (committed em produção).
--
-- SOMENTE LEITURA. Nenhum INSERT/UPDATE/DELETE.
--
-- Falta de 10 questões em determinada unidade NÃO torna tudo_ok=false —
-- isso é GAP PEDAGÓGICO DO BANCO (ver seção 2), não erro técnico.

-- ============================================================================
-- 1) Contagens gerais.
-- ============================================================================
select
  (
    select count(*) from public.questoes q
    join public.curso_conteudos cc on cc.id = 53
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where q.ativa = true and q.materia_id = cm.materia_id
      and (cc.assunto_id is null or q.assunto_id = cc.assunto_id)
  ) as candidatas_ativas,
  (
    select count(distinct qup.questao_id)
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where u.curso_conteudo_id = 53
  ) as questoes_classificadas,
  (
    select count(*)
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where u.curso_conteudo_id = 53
  ) as total_vinculos,
  (
    select count(*) from public.unidades_pedagogicas
    where curso_conteudo_id = 53 and ativa = true
  ) as unidades_ativas,
  (
    select count(*) from public.unidades_pedagogicas
    where curso_conteudo_id = 53
  ) as unidades_totais_sem_filtro_ativa;

-- ============================================================================
-- 2) Cobertura por unidade — questões distintas e vínculos.
-- ============================================================================
select
  u.ordem,
  u.titulo,
  coalesce(count(distinct qup.questao_id), 0) as questoes_distintas,
  coalesce(count(qup.questao_id), 0) as total_vinculos
from public.unidades_pedagogicas u
left join public.questao_unidades_pedagogicas qup on qup.unidade_pedagogica_id = u.id
where u.curso_conteudo_id = 53
group by u.ordem, u.titulo
order by u.ordem;

-- ============================================================================
-- 3) Multiunidade — esperado exatamente {51, 673, 799}.
-- ============================================================================
select qup.questao_id, array_agg(u.ordem order by u.ordem) as unidades
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = 53
group by qup.questao_id
having count(*) > 1
order by qup.questao_id;

-- ============================================================================
-- 4) Questões candidatas SEM classificação — esperado 0 linhas.
-- ============================================================================
select q.id as questao_id
from public.questoes q
join public.curso_conteudos cc on cc.id = 53
join public.curso_materias cm on cm.id = cc.curso_materia_id
where q.ativa = true
  and q.materia_id = cm.materia_id
  and (cc.assunto_id is null or q.assunto_id = cc.assunto_id)
  and not exists (
    select 1 from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where u.curso_conteudo_id = 53 and qup.questao_id = q.id
  )
order by q.id;

-- ============================================================================
-- 5) 738/863/864/865 seguem inativas e sem nenhum vínculo; 129/133/134 ativas.
-- ============================================================================
select
  q.id as questao_id,
  q.ativa,
  exists (select 1 from public.questao_unidades_pedagogicas where questao_id = q.id) as tem_vinculo
from public.questoes q
where q.id in (738, 863, 864, 865, 129, 133, 134)
order by q.id;

-- ============================================================================
-- 6) As 5 unidades — nenhuma extra, nenhuma alterada (id/ordem/titulo/escopo/
--    artigos_esperados/ativa idênticos aos oficiais).
-- ============================================================================
with esperado (unidade_id, ordem_esperada, titulo_esperado) as (
  values
    ('e260b54c-6a75-4398-97f6-7a432c405041'::uuid, 1, 'Fundamentos e campo de aplicação'),
    ('ab29ba89-1dcc-46c2-9659-f5808be3d976'::uuid, 2, 'Prevenção e assistência à mulher'),
    ('4d593bc4-6e4f-4c1f-8817-e41c78fe9491'::uuid, 3, 'Atendimento policial e providências imediatas'),
    ('7164d7f2-86f7-413e-b0fc-64070dd2e2f5'::uuid, 4, 'Procedimentos e medidas protetivas de urgência'),
    ('53dc06a1-cd16-4004-a76b-8201d95a91c4'::uuid, 5, 'Rede de justiça, equipe multidisciplinar e disposições finais')
)
select
  e.unidade_id,
  (u.id is not null) as existe,
  (u.ordem = e.ordem_esperada) as ordem_ok,
  (regexp_replace(lower(btrim(u.titulo)), '\s+', ' ', 'g') = regexp_replace(lower(btrim(e.titulo_esperado)), '\s+', ' ', 'g')) as titulo_ok,
  u.ativa,
  u.curso_conteudo_id
from esperado e
left join public.unidades_pedagogicas u on u.id = e.unidade_id
order by e.ordem_esperada;

select count(*) as unidades_extras_no_conteudo_53
from public.unidades_pedagogicas
where curso_conteudo_id = 53
  and id not in (
    'e260b54c-6a75-4398-97f6-7a432c405041','ab29ba89-1dcc-46c2-9659-f5808be3d976',
    '4d593bc4-6e4f-4c1f-8817-e41c78fe9491','7164d7f2-86f7-413e-b0fc-64070dd2e2f5',
    '53dc06a1-cd16-4004-a76b-8201d95a91c4'
  );

-- ============================================================================
-- 7) RESUMO booleano final — tudo_ok.
--    Gap de cobertura (< 10 questões numa unidade) NÃO entra no tudo_ok.
-- ============================================================================
with vinculos as (
  select qup.questao_id, qup.unidade_pedagogica_id
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 53
),
multiunidade as (
  select questao_id from vinculos group by questao_id having count(*) > 1
),
sem_classificacao as (
  select q.id
  from public.questoes q
  join public.curso_conteudos cc on cc.id = 53
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where q.ativa = true and q.materia_id = cm.materia_id
    and (cc.assunto_id is null or q.assunto_id = cc.assunto_id)
    and not exists (select 1 from vinculos v where v.questao_id = q.id)
)
select
  (select count(*) from vinculos) = 31 as total_vinculos_e_31,
  (select count(distinct questao_id) from vinculos) = 28 as questoes_classificadas_e_28,
  (select array_agg(questao_id order by questao_id) from multiunidade) = array[51,673,799]::bigint[] as multiunidade_e_51_673_799,
  (select count(*) from sem_classificacao) = 0 as sem_classificacao_e_0,
  not exists (select 1 from public.questoes where id in (738,863,864,865) and ativa = true) as inativas_seguem_inativas,
  not exists (select 1 from public.questao_unidades_pedagogicas where questao_id in (738,863,864,865)) as inativas_sem_vinculo,
  not exists (select 1 from public.questoes where id in (129,133,134) and ativa = false) as ativas_129_133_134_seguem_ativas,
  (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 53 and ativa = true) = 5 as cinco_unidades_ativas,
  (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 53) = 5 as nenhuma_unidade_extra,
  (
    (select count(*) from vinculos) = 31
    and (select count(distinct questao_id) from vinculos) = 28
    and (select array_agg(questao_id order by questao_id) from multiunidade) = array[51,673,799]::bigint[]
    and (select count(*) from sem_classificacao) = 0
    and not exists (select 1 from public.questoes where id in (738,863,864,865) and ativa = true)
    and not exists (select 1 from public.questao_unidades_pedagogicas where questao_id in (738,863,864,865))
    and not exists (select 1 from public.questoes where id in (129,133,134) and ativa = false)
    and (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 53 and ativa = true) = 5
    and (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 53) = 5
  ) as tudo_ok;
