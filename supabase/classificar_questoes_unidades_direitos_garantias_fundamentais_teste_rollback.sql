-- Harness de teste (SEMPRE termina em ROLLBACK) da classificação de
-- questões de Direitos e Garantias Fundamentais (curso_conteudos.id = 47)
-- nas duas unidades pedagógicas aprovadas. Aplica o mapa aprovado em
-- supabase/mapa_classificacao_unidades_direitos_garantias_fundamentais.sql
-- usando a RPC administrativa oficial classificar_questao_unidade_admin
-- (nenhum INSERT direto em questao_unidades_pedagogicas), valida
-- pré-condições e pós-condições, e desfaz tudo ao final — nada aqui
-- persiste no banco.
--
-- PRÉ-REQUISITO: supabase/curadoria_unidades_direitos_garantias_
-- fundamentais.sql precisa já ter sido aplicado (as duas unidades
-- pedagógicas do conteúdo 47 precisam existir com os ids esperados) antes
-- de este harness ser executado — senão a precondição de unidades abaixo
-- falha e o relatório final aponta tudo_ok = false.
--
-- Diferença deste arquivo para
-- classificar_questoes_unidades_direitos_garantias_fundamentais.sql (Etapa
-- de aplicação real): aqui cada verificação alimenta um relatório
-- booleano (tudo_ok), nunca aborta a transação sozinha — o roteiro
-- inteiro roda até o fim e só then decide, no relatório final, se teria
-- sido seguro aplicar de verdade. Termina SEMPRE em ROLLBACK,
-- independentemente do resultado.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

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

create temporary table _mapa (
  questao_id bigint,
  unidade_pedagogica_id uuid,
  ordem_unidade int,
  confianca text
) on commit drop;

insert into _mapa (questao_id, unidade_pedagogica_id, ordem_unidade, confianca) values
  (46,  '0c5d1d64-0cae-406e-be19-b03d387bee8a', 1, 'alta'),
  (46,  'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63', 2, 'media'),
  (112, '0c5d1d64-0cae-406e-be19-b03d387bee8a', 1, 'alta'),
  (298, '0c5d1d64-0cae-406e-be19-b03d387bee8a', 1, 'alta'),
  (326, '0c5d1d64-0cae-406e-be19-b03d387bee8a', 1, 'alta'),
  (657, 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63', 2, 'alta'),
  (658, '0c5d1d64-0cae-406e-be19-b03d387bee8a', 1, 'alta'),
  (660, '0c5d1d64-0cae-406e-be19-b03d387bee8a', 1, 'alta'),
  (661, '0c5d1d64-0cae-406e-be19-b03d387bee8a', 1, 'alta'),
  (662, 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63', 2, 'alta'),
  (663, 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63', 2, 'alta'),
  (723, '0c5d1d64-0cae-406e-be19-b03d387bee8a', 1, 'alta'),
  (724, '0c5d1d64-0cae-406e-be19-b03d387bee8a', 1, 'alta'),
  (725, '0c5d1d64-0cae-406e-be19-b03d387bee8a', 1, 'alta'),
  (726, '0c5d1d64-0cae-406e-be19-b03d387bee8a', 1, 'media'),
  (727, '0c5d1d64-0cae-406e-be19-b03d387bee8a', 1, 'media'),
  (775, 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63', 2, 'media'),
  (797, '0c5d1d64-0cae-406e-be19-b03d387bee8a', 1, 'media'),
  (846, 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63', 2, 'alta'),
  (847, '0c5d1d64-0cae-406e-be19-b03d387bee8a', 1, 'media'),
  (848, 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63', 2, 'alta'),
  (849, 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63', 2, 'alta');

create temporary table _relatorio (
  etapa text,
  ok boolean,
  detalhe text
) on commit drop;

-- Lock determinístico das linhas envolvidas antes de revalidar.
select id from public.unidades_pedagogicas
where curso_conteudo_id = 47
order by id
for update;

select id from public.questoes
where id in (select distinct questao_id from _mapa)
order by id
for update;

-- Precondições (estritamente ANTES do loop RPC).
do $$
declare
  v_materia_id bigint;
  v_assunto_id bigint;
  v_total_candidatas int;
  v_classificacoes_previas int;
  v_unidades_ok boolean;
begin
  select cm.materia_id, cc.assunto_id into v_materia_id, v_assunto_id
  from public.curso_conteudos cc
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where cc.id = 47;

  insert into _relatorio values (
    '01_conteudo_47_materia_assunto',
    v_materia_id is not distinct from 10 and v_assunto_id is not distinct from 71,
    format('materia_id=%s assunto_id=%s (esperado 10/71)', v_materia_id, v_assunto_id)
  );

  select bool_and(x.ok) into v_unidades_ok from (
    select exists (select 1 from public.unidades_pedagogicas where id = '0c5d1d64-0cae-406e-be19-b03d387bee8a' and curso_conteudo_id = 47 and ordem = 1 and ativa) as ok
    union all
    select exists (select 1 from public.unidades_pedagogicas where id = 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63' and curso_conteudo_id = 47 and ordem = 2 and ativa)
  ) x;

  insert into _relatorio values (
    '02_duas_unidades_oficiais_existem',
    coalesce(v_unidades_ok, false),
    'unidade ordem=1 (0c5d1d64...) e ordem=2 (f3a6d9c2...) precisam existir, ativas, no conteudo 47'
  );

  select count(*) into v_total_candidatas
  from public.questoes q
  join public.curso_conteudos cc on cc.id = 47
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where q.ativa = true
    and q.materia_id = cm.materia_id
    and (cc.assunto_id is null or q.assunto_id = cc.assunto_id);

  insert into _relatorio values (
    '03_total_candidatas_21',
    v_total_candidatas = 21,
    format('total_candidatas=%s (esperado 21)', v_total_candidatas)
  );

  -- Verificação sem_classificacao_previa executada antes de qualquer chamada RPC
  select count(*) into v_classificacoes_previas
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 47
    and qup.questao_id in (select questao_id from _mapa);

  insert into _relatorio values (
    '04_sem_classificacao_previa',
    v_classificacoes_previas = 0,
    format('classificacoes_previas=%s (esperado 0 antes do apply)', v_classificacoes_previas)
  );
end $$;

-- Validação do mapa em si (estritamente ANTES do loop RPC).
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
  where not (q.ativa = true and q.materia_id = 10 and q.assunto_id = 71);

  insert into _relatorio values (
    '05_mapa_todas_questoes_validas',
    v_invalidas = 0,
    format('%s linha(s) apontam para questao fora de ativa=true/materia_id=10/assunto_id=71', v_invalidas)
  );

  select count(*) into v_distintas from (select distinct questao_id from _mapa) x;
  insert into _relatorio values (
    '06_mapa_cobre_21_distintas',
    v_distintas = 21,
    format('mapa cobre %s questoes distintas (esperado 21)', v_distintas)
  );

  select count(*) into v_fora_do_candidato
  from _mapa m
  where not exists (
    select 1
    from public.questoes q
    join public.curso_conteudos cc on cc.id = 47
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where q.id = m.questao_id
      and q.ativa = true
      and q.materia_id = cm.materia_id
      and (cc.assunto_id is null or q.assunto_id = cc.assunto_id)
  );
  insert into _relatorio values (
    '07_mapa_sem_linhas_fora_do_candidato',
    v_fora_do_candidato = 0,
    format('%s linha(s) fora do conjunto candidato de 21', v_fora_do_candidato)
  );

  select count(*) into v_unidade_fora
  from _mapa m
  where m.unidade_pedagogica_id not in (select id from public.unidades_pedagogicas where curso_conteudo_id = 47);
  insert into _relatorio values (
    '08_mapa_unidades_pertencem_ao_conteudo',
    v_unidade_fora = 0,
    format('%s linha(s) referenciam unidade pedagogica fora do conteudo 47', v_unidade_fora)
  );
end $$;

-- Aplicação simulada via RPC oficial.
do $$
declare
  r record;
  v_erros int := 0;
  v_msg text := '';
begin
  for r in select questao_id, unidade_pedagogica_id from _mapa order by questao_id, unidade_pedagogica_id loop
    begin
      perform public.classificar_questao_unidade_admin(r.questao_id, r.unidade_pedagogica_id);
    exception when others then
      v_erros := v_erros + 1;
      v_msg := format('erro ao classificar questao_id=%s unidade=%s: %s', r.questao_id, r.unidade_pedagogica_id, sqlerrm);
    end;
  end loop;

  insert into _relatorio values (
    '09_aplicacao_rpc_sem_erro',
    v_erros = 0,
    case
      when v_erros = 0 then '22 chamadas a classificar_questao_unidade_admin executadas com sucesso'
      else format('%s erro(s) durante as chamadas RPC: %s', v_erros, v_msg)
    end
  );
end $$;

-- Pós-condições: validadas durante a simulação (ANTES do ROLLBACK).
do $$
declare
  v_total_vinculos int;
  v_questoes_classificadas int;
  v_fora_do_mapa int;
  v_faltando int;
  v_multiunidade bigint[];
  v_u1_qtd int;
  v_u2_qtd int;
  v_vinculos_antes int;
  v_vinculos_simulacao int;
begin
  select count(*) into v_total_vinculos
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 47;
  insert into _relatorio values ('10_total_vinculos_22', v_total_vinculos = 22, format('total_vinculos=%s (esperado 22)', v_total_vinculos));

  select count(distinct qup.questao_id) into v_questoes_classificadas
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 47;
  insert into _relatorio values ('11_questoes_classificadas_21', v_questoes_classificadas = 21, format('questoes_classificadas=%s (esperado 21)', v_questoes_classificadas));

  select count(*) into v_fora_do_mapa
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 47
    and not exists (select 1 from _mapa m where m.questao_id = qup.questao_id and m.unidade_pedagogica_id = qup.unidade_pedagogica_id);
  insert into _relatorio values ('12_sem_vinculo_fora_do_mapa', v_fora_do_mapa = 0, format('%s vinculo(s) fora do mapa aprovado', v_fora_do_mapa));

  select count(*) into v_faltando
  from _mapa m
  where not exists (select 1 from public.questao_unidades_pedagogicas qup where qup.questao_id = m.questao_id and qup.unidade_pedagogica_id = m.unidade_pedagogica_id);
  insert into _relatorio values ('13_mapa_aplicado_integralmente', v_faltando = 0, format('%s linha(s) do mapa nao foram aplicadas', v_faltando));

  select array_agg(questao_id order by questao_id) into v_multiunidade
  from (
    select qup.questao_id
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where u.curso_conteudo_id = 47
    group by qup.questao_id
    having count(*) > 1
  ) x;
  insert into _relatorio values ('14_multiunidade_e_apenas_46', v_multiunidade is not distinct from array[46]::bigint[], format('multiunidade=%s (esperado {46})', v_multiunidade));

  select count(distinct qup.questao_id) into v_u1_qtd
  from public.questao_unidades_pedagogicas qup
  where qup.unidade_pedagogica_id = '0c5d1d64-0cae-406e-be19-b03d387bee8a';
  insert into _relatorio values ('15_u1_14_questoes', v_u1_qtd = 14, format('u1_questoes=%s (esperado 14)', v_u1_qtd));

  select count(distinct qup.questao_id) into v_u2_qtd
  from public.questao_unidades_pedagogicas qup
  where qup.unidade_pedagogica_id = 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63';
  insert into _relatorio values ('16_u2_8_questoes', v_u2_qtd = 8, format('u2_questoes=%s (esperado 8)', v_u2_qtd));

  insert into _relatorio values ('17_unidades_pedagogicas_inalteradas_em_qtd',
    (select count(*) from public.unidades_pedagogicas) = (select total_unidades from _snapshot_antes),
    format('antes=%s agora=%s (esperado inalterado)', (select total_unidades from _snapshot_antes), (select count(*) from public.unidades_pedagogicas)));
  insert into _relatorio values ('18_questoes_inalteradas',
    (select count(*) from public.questoes) = (select total_questoes from _snapshot_antes),
    format('antes=%s agora=%s (esperado inalterado)', (select total_questoes from _snapshot_antes), (select count(*) from public.questoes)));
  insert into _relatorio values ('19_alternativas_inalteradas',
    (select count(*) from public.alternativas) = (select total_alternativas from _snapshot_antes),
    format('antes=%s agora=%s (esperado inalterado)', (select total_alternativas from _snapshot_antes), (select count(*) from public.alternativas)));
  insert into _relatorio values ('20_conteudos_inalterados',
    (select count(*) from public.curso_conteudos) = (select total_conteudos from _snapshot_antes),
    format('antes=%s agora=%s (esperado inalterado)', (select total_conteudos from _snapshot_antes), (select count(*) from public.curso_conteudos)));
  insert into _relatorio values ('21_curso_questoes_inalterado',
    (select count(*) from public.curso_questoes) = (select total_curso_questoes from _snapshot_antes),
    format('antes=%s agora=%s (esperado inalterado)', (select total_curso_questoes from _snapshot_antes), (select count(*) from public.curso_questoes)));
  insert into _relatorio values ('22_respostas_inalteradas',
    (select count(*) from public.respostas_usuarios) = (select total_respostas from _snapshot_antes),
    format('antes=%s agora=%s (esperado inalterado)', (select total_respostas from _snapshot_antes), (select count(*) from public.respostas_usuarios)));
  insert into _relatorio values ('23_sessoes_inalteradas',
    (select count(*) from public.sessoes_estudo) = (select total_sessoes from _snapshot_antes),
    format('antes=%s agora=%s (esperado inalterado)', (select total_sessoes from _snapshot_antes), (select count(*) from public.sessoes_estudo)));

  -- Validação de crescimento dos vínculos durante a simulação (antes do rollback)
  select total_vinculos into v_vinculos_antes from _snapshot_antes;
  select count(*) into v_vinculos_simulacao from public.questao_unidades_pedagogicas;

  insert into _relatorio values (
    '24_vinculos_cresceram_exatamente_22',
    v_vinculos_simulacao = v_vinculos_antes + 22,
    format('vinculos_antes=%s vinculos_simulacao=%s (crescimento exato de +22 durante a simulacao)', v_vinculos_antes, v_vinculos_simulacao)
  );
end $$;

-- Relatório final — nunca aborta a transação; só relata.
do $$
declare
  v_tudo_ok boolean;
  r record;
begin
  select bool_and(ok) into v_tudo_ok from _relatorio;

  raise notice '=== RELATORIO DO TESTE (classificar_questoes_unidades_direitos_garantias_fundamentais) ===';
  for r in select * from _relatorio order by etapa loop
    raise notice '% => % (%)', r.etapa, r.ok, r.detalhe;
  end loop;
  raise notice 'tudo_ok = %', coalesce(v_tudo_ok, false);
end $$;

-- Exibição do relatório em SELECT tabular (visível no Supabase SQL Editor).
select
  etapa,
  ok,
  detalhe
from _relatorio
union all
select
  '99_RESULTADO_CONSOLIDADO' as etapa,
  bool_and(ok) as ok,
  case
    when bool_and(ok) then 'tudo_ok = true (todas as 24 etapas passaram com sucesso)'
    else 'tudo_ok = false (uma ou mais etapas falharam)'
  end as detalhe
from _relatorio
order by etapa;

-- SEMPRE desfaz — este arquivo nunca persiste nada.
rollback;
