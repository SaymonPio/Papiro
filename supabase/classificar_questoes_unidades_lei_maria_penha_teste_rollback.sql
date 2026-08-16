-- ETAPA 6/7 do PROMPT MESTRE de curadoria das unidades pedagógicas da Lei
-- Maria da Penha — harness transacional que aplica o mapa aprovado em
-- supabase/mapa_classificacao_unidades_lei_maria_penha.sql e SEMPRE termina
-- em ROLLBACK. Nenhuma escrita deste arquivo sobrevive.
--
-- Objetivo: provar, dentro da própria transação, que a classificação das 28
-- questões (31 vínculos, 3 multiunidade) pode ser aplicada com segurança
-- pela RPC oficial classificar_questao_unidade_admin, sem violar nenhuma
-- precondição e sem efeito colateral em nenhuma outra tabela.
--
-- Usa a mesma RPC administrativa usada pelo app (não faz INSERT direto em
-- questao_unidades_pedagogicas). Como esta sessão roda como "postgres" via
-- MCP (sem sessão de auth do Supabase), auth.uid() viria NULL e a RPC
-- rejeitaria por eh_admin() = false; para respeitar o contrato de segurança
-- em vez de contorná-lo, a transação simula a claim JWT do único
-- administrador cadastrado em public.administradores (somente 'set local',
-- efeito restrito a esta transação).
begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

-- ----------------------------------------------------------------------------
-- Snapshot ANTES de qualquer escrita — para provar ausência de efeito
-- colateral em qualquer outra tabela ao final.
-- ----------------------------------------------------------------------------
create temporary table _snapshot_antes on commit drop as
select
  (select count(*) from public.questoes)                     as total_questoes,
  (select count(*) from public.alternativas)                 as total_alternativas,
  (select count(*) from public.unidades_pedagogicas)          as total_unidades,
  (select count(*) from public.curso_conteudos)               as total_conteudos,
  (select count(*) from public.curso_questoes)                as total_curso_questoes,
  (select count(*) from public.respostas_usuarios)            as total_respostas,
  (select count(*) from public.sessoes_estudo)                as total_sessoes,
  (select count(*) from public.questao_unidades_pedagogicas)  as total_vinculos;

-- ----------------------------------------------------------------------------
-- Mapa aprovado (fonte: supabase/mapa_classificacao_unidades_lei_maria_penha.sql)
-- ----------------------------------------------------------------------------
create temporary table _mapa (
  questao_id bigint,
  unidade_pedagogica_id uuid,
  ordem_unidade int,
  confianca text
) on commit drop;

insert into _mapa (questao_id, unidade_pedagogica_id, ordem_unidade, confianca) values
  (21,  'e260b54c-6a75-4398-97f6-7a432c405041', 1, 'alta'),
  (40,  '4d593bc4-6e4f-4c1f-8817-e41c78fe9491', 3, 'alta'),
  (51,  'ab29ba89-1dcc-46c2-9659-f5808be3d976', 2, 'alta'),
  (51,  '4d593bc4-6e4f-4c1f-8817-e41c78fe9491', 3, 'alta'),
  (129, '4d593bc4-6e4f-4c1f-8817-e41c78fe9491', 3, 'alta'),
  (133, '7164d7f2-86f7-413e-b0fc-64070dd2e2f5', 4, 'alta'),
  (134, 'ab29ba89-1dcc-46c2-9659-f5808be3d976', 2, 'alta'),
  (344, 'ab29ba89-1dcc-46c2-9659-f5808be3d976', 2, 'alta'),
  (345, 'e260b54c-6a75-4398-97f6-7a432c405041', 1, 'alta'),
  (346, 'e260b54c-6a75-4398-97f6-7a432c405041', 1, 'alta'),
  (347, 'e260b54c-6a75-4398-97f6-7a432c405041', 1, 'alta'),
  (671, '4d593bc4-6e4f-4c1f-8817-e41c78fe9491', 3, 'alta'),
  (672, '4d593bc4-6e4f-4c1f-8817-e41c78fe9491', 3, 'alta'),
  (673, 'e260b54c-6a75-4398-97f6-7a432c405041', 1, 'alta'),
  (673, 'ab29ba89-1dcc-46c2-9659-f5808be3d976', 2, 'alta'),
  (734, 'e260b54c-6a75-4398-97f6-7a432c405041', 1, 'alta'),
  (735, 'e260b54c-6a75-4398-97f6-7a432c405041', 1, 'alta'),
  (736, '4d593bc4-6e4f-4c1f-8817-e41c78fe9491', 3, 'alta'),
  (737, 'ab29ba89-1dcc-46c2-9659-f5808be3d976', 2, 'alta'),
  (739, 'e260b54c-6a75-4398-97f6-7a432c405041', 1, 'alta'),
  (778, 'e260b54c-6a75-4398-97f6-7a432c405041', 1, 'alta'),
  (779, '4d593bc4-6e4f-4c1f-8817-e41c78fe9491', 3, 'alta'),
  (780, 'e260b54c-6a75-4398-97f6-7a432c405041', 1, 'alta'),
  (799, 'e260b54c-6a75-4398-97f6-7a432c405041', 1, 'alta'),
  (799, 'ab29ba89-1dcc-46c2-9659-f5808be3d976', 2, 'media'),
  (800, '4d593bc4-6e4f-4c1f-8817-e41c78fe9491', 3, 'alta'),
  (801, '7164d7f2-86f7-413e-b0fc-64070dd2e2f5', 4, 'alta'),
  (802, 'e260b54c-6a75-4398-97f6-7a432c405041', 1, 'alta'),
  (861, 'e260b54c-6a75-4398-97f6-7a432c405041', 1, 'alta'),
  (862, 'e260b54c-6a75-4398-97f6-7a432c405041', 1, 'alta'),
  (866, '4d593bc4-6e4f-4c1f-8817-e41c78fe9491', 3, 'alta');

-- ----------------------------------------------------------------------------
-- Lock determinístico das linhas envolvidas (ordem ascendente por id),
-- antes de revalidar qualquer premissa.
-- ----------------------------------------------------------------------------
select id from public.unidades_pedagogicas
where curso_conteudo_id = 53
order by id
for update;

select id from public.questoes
where id in (select distinct questao_id from _mapa)
order by id
for update;

-- ----------------------------------------------------------------------------
-- ETAPA 1 (revalidação dentro da própria transação) — RAISE EXCEPTION aborta
-- tudo automaticamente se qualquer premissa não bater.
-- ----------------------------------------------------------------------------
do $$
declare
  v_materia_id bigint;
  v_assunto_id bigint;
  v_total_candidatas int;
  v_classificacoes_previas int;
begin
  select cm.materia_id, cc.assunto_id into v_materia_id, v_assunto_id
  from public.curso_conteudos cc
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where cc.id = 53;

  if v_materia_id is null then
    raise exception 'Precondicao falhou: curso_conteudos 53 nao existe';
  end if;
  if v_materia_id is distinct from 10 or v_assunto_id is distinct from 19 then
    raise exception 'Precondicao falhou: conteudo 53 materia_id=% assunto_id=% (esperado 10/19)', v_materia_id, v_assunto_id;
  end if;

  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 53 and ativa = true) <> 5 then
    raise exception 'Precondicao falhou: nao ha exatamente 5 unidades pedagogicas ativas para o conteudo 53';
  end if;

  if not exists (select 1 from public.unidades_pedagogicas where id = 'e260b54c-6a75-4398-97f6-7a432c405041' and curso_conteudo_id = 53 and ordem = 1 and ativa)
  or not exists (select 1 from public.unidades_pedagogicas where id = 'ab29ba89-1dcc-46c2-9659-f5808be3d976' and curso_conteudo_id = 53 and ordem = 2 and ativa)
  or not exists (select 1 from public.unidades_pedagogicas where id = '4d593bc4-6e4f-4c1f-8817-e41c78fe9491' and curso_conteudo_id = 53 and ordem = 3 and ativa)
  or not exists (select 1 from public.unidades_pedagogicas where id = '7164d7f2-86f7-413e-b0fc-64070dd2e2f5' and curso_conteudo_id = 53 and ordem = 4 and ativa)
  or not exists (select 1 from public.unidades_pedagogicas where id = '53dc06a1-cd16-4004-a76b-8201d95a91c4' and curso_conteudo_id = 53 and ordem = 5 and ativa)
  then
    raise exception 'Precondicao falhou: uma ou mais das 5 unidades oficiais nao confere (id/ordem/conteudo/ativa)';
  end if;

  select count(*) into v_total_candidatas
  from public.questoes q
  join public.curso_conteudos cc on cc.id = 53
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where q.ativa = true
    and q.materia_id = cm.materia_id
    and (cc.assunto_id is null or q.assunto_id = cc.assunto_id);

  if v_total_candidatas <> 28 then
    raise exception 'Precondicao falhou: total de candidatas ativas = % (esperado 28)', v_total_candidatas;
  end if;

  if exists (select 1 from public.questoes where id in (738, 863, 864, 865) and ativa = true) then
    raise exception 'Precondicao falhou: alguma de 738/863/864/865 esta ativa';
  end if;

  if exists (select 1 from public.questoes where id in (129, 133, 134) and ativa = false) then
    raise exception 'Precondicao falhou: alguma de 129/133/134 esta inativa';
  end if;

  select count(*) into v_classificacoes_previas
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 53
    and qup.questao_id in (select questao_id from _mapa);

  if v_classificacoes_previas <> 0 then
    raise exception 'Precondicao falhou: ja existe classificacao previa inesperada (% linhas) para questao(oes) do mapa', v_classificacoes_previas;
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- Validação do MAPA em si: toda linha aponta para questão ativa,
-- materia_id=10, assunto_id=19, dentro do conjunto de 28 candidatas, e
-- unidade pertencente ao conteúdo 53. Nenhuma questão fora do mapa será
-- tocada porque o loop de aplicação usa exclusivamente _mapa.
-- ----------------------------------------------------------------------------
do $$
declare
  v_invalidas int;
  v_fora_do_candidato int;
  v_unidade_fora int;
  v_distintas int;
begin
  select count(*) into v_invalidas
  from _mapa m
  join public.questoes q on q.id = m.questao_id
  where not (q.ativa = true and q.materia_id = 10 and q.assunto_id = 19);

  if v_invalidas <> 0 then
    raise exception 'Mapa invalido: % linha(s) apontam para questao que nao esta ativa=true/materia_id=10/assunto_id=19', v_invalidas;
  end if;

  select count(*) into v_distintas from (select distinct questao_id from _mapa) x;
  if v_distintas <> 28 then
    raise exception 'Mapa invalido: cobre % questoes distintas (esperado 28)', v_distintas;
  end if;

  select count(*) into v_fora_do_candidato
  from _mapa m
  where not exists (
    select 1
    from public.questoes q
    join public.curso_conteudos cc on cc.id = 53
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where q.id = m.questao_id
      and q.ativa = true
      and q.materia_id = cm.materia_id
      and (cc.assunto_id is null or q.assunto_id = cc.assunto_id)
  );
  if v_fora_do_candidato <> 0 then
    raise exception 'Mapa invalido: % linha(s) fora do conjunto candidato de 28', v_fora_do_candidato;
  end if;

  select count(*) into v_unidade_fora
  from _mapa m
  where m.unidade_pedagogica_id not in (select id from public.unidades_pedagogicas where curso_conteudo_id = 53);
  if v_unidade_fora <> 0 then
    raise exception 'Mapa invalido: % linha(s) referenciam unidade pedagogica fora do conteudo 53', v_unidade_fora;
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- Aplicação via RPC oficial (arquitetura existente) — dentro da transação.
-- ----------------------------------------------------------------------------
do $$
declare r record;
begin
  for r in select questao_id, unidade_pedagogica_id from _mapa order by questao_id, unidade_pedagogica_id loop
    perform public.classificar_questao_unidade_admin(r.questao_id, r.unidade_pedagogica_id);
  end loop;
end $$;

-- ----------------------------------------------------------------------------
-- ETAPA 7 — asserts detalhados + tudo_ok. NÃO usa RAISE aqui (o harness é
-- diagnóstico): queremos ler o relatório completo mesmo que algo divirja.
-- ----------------------------------------------------------------------------
with vinculos_novos as (
  select qup.questao_id, qup.unidade_pedagogica_id
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 53
),
multiunidade as (
  select questao_id from vinculos_novos group by questao_id having count(*) > 1
),
asserts as (
  select
    (select count(*) from vinculos_novos) = 31                                            as total_vinculos_e_31,
    (select count(distinct questao_id) from vinculos_novos) = 28                           as total_questoes_classificadas_e_28,
    not exists (select 1 from vinculos_novos v where v.questao_id not in (select questao_id from _mapa)) as nenhuma_questao_fora_do_mapa,
    not exists (
      select 1 from _mapa m
      where not exists (
        select 1 from vinculos_novos v
        where v.questao_id = m.questao_id and v.unidade_pedagogica_id = m.unidade_pedagogica_id
      )
    )                                                                                       as todas_as_linhas_do_mapa_aplicadas,
    (select array_agg(questao_id order by questao_id) from multiunidade) = array[51,673,799]::bigint[] as multiunidade_exatamente_51_673_799,
    not exists (select 1 from public.questoes where id in (738,863,864,865) and ativa = true)          as inativas_738_863_864_865_seguem_inativas,
    not exists (select 1 from public.questao_unidades_pedagogicas where questao_id in (738,863,864,865)) as inativas_sem_vinculo,
    (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 53 and ativa = true) = 5 as cinco_unidades_ativas,
    (select count(*) from public.unidades_pedagogicas) = (select total_unidades from _snapshot_antes)   as nenhuma_unidade_extra_criada,
    (select count(*) from public.questoes) = (select total_questoes from _snapshot_antes)                as questoes_inalteradas_em_quantidade,
    (select count(*) from public.alternativas) = (select total_alternativas from _snapshot_antes)        as alternativas_inalteradas,
    (select count(*) from public.curso_conteudos) = (select total_conteudos from _snapshot_antes)        as conteudos_inalterados,
    (select count(*) from public.curso_questoes) = (select total_curso_questoes from _snapshot_antes)    as curso_questoes_inalterado,
    (select count(*) from public.respostas_usuarios) = (select total_respostas from _snapshot_antes)     as respostas_usuarios_inalterado,
    (select count(*) from public.sessoes_estudo) = (select total_sessoes from _snapshot_antes)           as sessoes_estudo_inalterado,
    (select count(*) from public.questao_unidades_pedagogicas) = (select total_vinculos from _snapshot_antes) + 31 as vinculos_cresceu_exatamente_31
)
select
  *,
  (
    total_vinculos_e_31 and total_questoes_classificadas_e_28 and nenhuma_questao_fora_do_mapa
    and todas_as_linhas_do_mapa_aplicadas and multiunidade_exatamente_51_673_799
    and inativas_738_863_864_865_seguem_inativas and inativas_sem_vinculo and cinco_unidades_ativas
    and nenhuma_unidade_extra_criada and questoes_inalteradas_em_quantidade and alternativas_inalteradas
    and conteudos_inalterados and curso_questoes_inalterado and respostas_usuarios_inalterado
    and sessoes_estudo_inalterado and vinculos_cresceu_exatamente_31
  ) as tudo_ok
from asserts;

-- SEMPRE termina em ROLLBACK — este arquivo é só o harness de validação.
rollback;
