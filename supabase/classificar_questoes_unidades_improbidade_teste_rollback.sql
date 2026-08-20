-- Harness de teste (SEMPRE termina em ROLLBACK) da classificação de
-- questões de Improbidade Administrativa (curso_conteudos.id = 55) nas
-- duas unidades pedagógicas aprovadas. Aplica o mapa aprovado em
-- supabase/mapa_classificacao_improbidade.sql usando a RPC administrativa
-- oficial classificar_questao_unidade_admin (nenhum INSERT direto em
-- questao_unidades_pedagogicas), valida pré-condições e pós-condições, e
-- desfaz tudo ao final — nada aqui persiste no banco.
--
-- PRÉ-REQUISITO: supabase/curadoria_unidades_improbidade.sql precisa já
-- ter sido aplicado (as duas unidades pedagógicas do conteúdo 55 precisam
-- existir com os ids esperados) antes de este harness ser executado —
-- senão a precondição de unidades abaixo falha e o relatório final aponta
-- tudo_ok = false.
--
-- Diferença deste arquivo para
-- classificar_questoes_unidades_improbidade.sql (Etapa de aplicação real):
-- aqui cada verificação alimenta um relatório booleano (tudo_ok), nunca
-- aborta a transação sozinha — o roteiro inteiro roda até o fim e só então
-- decide, no relatório final, se teria sido seguro aplicar de verdade.
-- Termina SEMPRE em ROLLBACK, independentemente do resultado.

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
  (42,  '9d4c7a1e-3f68-4b52-8a91-6c0d5e2f7b84', 2, 'alta'),
  (49,  '9d4c7a1e-3f68-4b52-8a91-6c0d5e2f7b84', 2, 'media'),
  (137, '60927a85-1b4a-480a-b8da-8eb318520692', 1, 'alta'),
  (361, '9d4c7a1e-3f68-4b52-8a91-6c0d5e2f7b84', 2, 'alta'),
  (666, '60927a85-1b4a-480a-b8da-8eb318520692', 1, 'alta'),
  (667, '60927a85-1b4a-480a-b8da-8eb318520692', 1, 'alta'),
  (668, '60927a85-1b4a-480a-b8da-8eb318520692', 1, 'alta'),
  (669, '9d4c7a1e-3f68-4b52-8a91-6c0d5e2f7b84', 2, 'alta'),
  (731, '9d4c7a1e-3f68-4b52-8a91-6c0d5e2f7b84', 2, 'media'),
  (732, '60927a85-1b4a-480a-b8da-8eb318520692', 1, 'media'),
  (732, '9d4c7a1e-3f68-4b52-8a91-6c0d5e2f7b84', 2, 'media'),
  (856, '60927a85-1b4a-480a-b8da-8eb318520692', 1, 'alta'),
  (857, '60927a85-1b4a-480a-b8da-8eb318520692', 1, 'alta'),
  (858, '60927a85-1b4a-480a-b8da-8eb318520692', 1, 'media'),
  (859, '60927a85-1b4a-480a-b8da-8eb318520692', 1, 'alta'),
  (860, '9d4c7a1e-3f68-4b52-8a91-6c0d5e2f7b84', 2, 'alta');

create temporary table _relatorio (
  etapa text,
  ok boolean,
  detalhe text
) on commit drop;

-- Lock determinístico das linhas envolvidas antes de revalidar.
select id from public.unidades_pedagogicas
where curso_conteudo_id = 55
order by id
for update;

select id from public.questoes
where id in (select distinct questao_id from _mapa)
order by id
for update;

-- Precondições.
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
  where cc.id = 55;

  insert into _relatorio values (
    'conteudo_55_materia_assunto',
    v_materia_id is not distinct from 10 and v_assunto_id is not distinct from 64,
    format('materia_id=%s assunto_id=%s (esperado 10/64)', v_materia_id, v_assunto_id)
  );

  select bool_and(x.ok) into v_unidades_ok from (
    select exists (select 1 from public.unidades_pedagogicas where id = '60927a85-1b4a-480a-b8da-8eb318520692' and curso_conteudo_id = 55 and ordem = 1 and ativa) as ok
    union all
    select exists (select 1 from public.unidades_pedagogicas where id = '9d4c7a1e-3f68-4b52-8a91-6c0d5e2f7b84' and curso_conteudo_id = 55 and ordem = 2 and ativa)
  ) x;

  insert into _relatorio values (
    'duas_unidades_oficiais_existem',
    coalesce(v_unidades_ok, false),
    'unidade ordem=1 (60927a85...) e ordem=2 (9d4c7a1e...) precisam existir, ativas, no conteudo 55 — depende de curadoria_unidades_improbidade.sql já aplicado'
  );

  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 55 and ativa = true) <> 2 then
    insert into _relatorio values ('exatamente_2_unidades_ativas', false,
      format('unidades ativas do conteudo 55 = %s (esperado 2)', (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 55 and ativa = true)));
  else
    insert into _relatorio values ('exatamente_2_unidades_ativas', true, 'ok');
  end if;

  select count(*) into v_total_candidatas
  from public.questoes q
  join public.curso_conteudos cc on cc.id = 55
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where q.ativa = true
    and q.materia_id = cm.materia_id
    and (cc.assunto_id is null or q.assunto_id = cc.assunto_id);

  insert into _relatorio values (
    'total_candidatas_15',
    v_total_candidatas = 15,
    format('total_candidatas=%s (esperado 15)', v_total_candidatas)
  );

  select count(*) into v_classificacoes_previas
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 55
    and qup.questao_id in (select questao_id from _mapa);

  insert into _relatorio values (
    'sem_classificacao_previa',
    v_classificacoes_previas = 0,
    format('classificacoes_previas=%s (esperado 0)', v_classificacoes_previas)
  );
end $$;

-- Validação do mapa em si.
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
  where not (q.ativa = true and q.materia_id = 10 and q.assunto_id = 64);

  insert into _relatorio values (
    'mapa_todas_questoes_validas',
    v_invalidas = 0,
    format('%s linha(s) apontam para questao fora de ativa=true/materia_id=10/assunto_id=64', v_invalidas)
  );

  select count(*) into v_distintas from (select distinct questao_id from _mapa) x;
  insert into _relatorio values (
    'mapa_cobre_15_distintas',
    v_distintas = 15,
    format('mapa cobre %s questoes distintas (esperado 15)', v_distintas)
  );

  select count(*) into v_fora_do_candidato
  from _mapa m
  where not exists (
    select 1
    from public.questoes q
    join public.curso_conteudos cc on cc.id = 55
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where q.id = m.questao_id
      and q.ativa = true
      and q.materia_id = cm.materia_id
      and (cc.assunto_id is null or q.assunto_id = cc.assunto_id)
  );
  insert into _relatorio values (
    'mapa_sem_linhas_fora_do_candidato',
    v_fora_do_candidato = 0,
    format('%s linha(s) fora do conjunto candidato de 15', v_fora_do_candidato)
  );

  select count(*) into v_unidade_fora
  from _mapa m
  where m.unidade_pedagogica_id not in (select id from public.unidades_pedagogicas where curso_conteudo_id = 55);
  insert into _relatorio values (
    'mapa_unidades_pertencem_ao_conteudo',
    v_unidade_fora = 0,
    format('%s linha(s) referenciam unidade pedagogica fora do conteudo 55', v_unidade_fora)
  );
end $$;

-- Aplicação via RPC oficial (só prossegue com efeito real se as unidades
-- existirem — se a precondição acima falhou, este loop simplesmente não
-- encontra o que classificar corretamente e o relatório final reprova).
do $$
declare r record;
begin
  for r in select questao_id, unidade_pedagogica_id from _mapa order by questao_id, unidade_pedagogica_id loop
    begin
      perform public.classificar_questao_unidade_admin(r.questao_id, r.unidade_pedagogica_id);
    exception when others then
      insert into _relatorio values (
        'aplicacao_rpc_sem_erro',
        false,
        format('erro ao classificar questao_id=%s unidade=%s: %s', r.questao_id, r.unidade_pedagogica_id, sqlerrm)
      );
    end;
  end loop;
end $$;

-- Pós-condições.
do $$
declare
  v_total_vinculos int;
  v_questoes_classificadas int;
  v_fora_do_mapa int;
  v_faltando int;
  v_multiunidade bigint[];
  v_u1_qtd int;
  v_u2_qtd int;
begin
  select count(*) into v_total_vinculos
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 55;
  insert into _relatorio values ('total_vinculos_16', v_total_vinculos = 16, format('total_vinculos=%s (esperado 16)', v_total_vinculos));

  select count(distinct qup.questao_id) into v_questoes_classificadas
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 55;
  insert into _relatorio values ('questoes_classificadas_15', v_questoes_classificadas = 15, format('questoes_classificadas=%s (esperado 15)', v_questoes_classificadas));

  select count(*) into v_fora_do_mapa
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 55
    and not exists (select 1 from _mapa m where m.questao_id = qup.questao_id and m.unidade_pedagogica_id = qup.unidade_pedagogica_id);
  insert into _relatorio values ('sem_vinculo_fora_do_mapa', v_fora_do_mapa = 0, format('%s vinculo(s) fora do mapa aprovado', v_fora_do_mapa));

  select count(*) into v_faltando
  from _mapa m
  where not exists (select 1 from public.questao_unidades_pedagogicas qup where qup.questao_id = m.questao_id and qup.unidade_pedagogica_id = m.unidade_pedagogica_id);
  insert into _relatorio values ('mapa_aplicado_integralmente', v_faltando = 0, format('%s linha(s) do mapa nao foram aplicadas', v_faltando));

  select array_agg(questao_id order by questao_id) into v_multiunidade
  from (
    select qup.questao_id
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where u.curso_conteudo_id = 55
    group by qup.questao_id
    having count(*) > 1
  ) x;
  insert into _relatorio values ('multiunidade_e_apenas_732', v_multiunidade is not distinct from array[732]::bigint[], format('multiunidade=%s (esperado {732})', v_multiunidade));

  select count(distinct qup.questao_id) into v_u1_qtd
  from public.questao_unidades_pedagogicas qup
  where qup.unidade_pedagogica_id = '60927a85-1b4a-480a-b8da-8eb318520692';
  insert into _relatorio values ('u1_9_questoes', v_u1_qtd = 9, format('u1_questoes=%s (esperado 9)', v_u1_qtd));

  select count(distinct qup.questao_id) into v_u2_qtd
  from public.questao_unidades_pedagogicas qup
  where qup.unidade_pedagogica_id = '9d4c7a1e-3f68-4b52-8a91-6c0d5e2f7b84';
  insert into _relatorio values ('u2_7_questoes', v_u2_qtd = 7, format('u2_questoes=%s (esperado 7)', v_u2_qtd));

  insert into _relatorio values ('unidades_pedagogicas_inalteradas_em_qtd',
    (select count(*) from public.unidades_pedagogicas) = (select total_unidades from _snapshot_antes),
    'esperado: nenhuma unidade nova criada por este arquivo (curadoria e um arquivo separado)');
  insert into _relatorio values ('questoes_inalteradas',
    (select count(*) from public.questoes) = (select total_questoes from _snapshot_antes), 'contagem de questoes nao deve mudar');
  insert into _relatorio values ('alternativas_inalteradas',
    (select count(*) from public.alternativas) = (select total_alternativas from _snapshot_antes), 'contagem de alternativas nao deve mudar');
  insert into _relatorio values ('conteudos_inalterados',
    (select count(*) from public.curso_conteudos) = (select total_conteudos from _snapshot_antes), 'contagem de curso_conteudos nao deve mudar');
  insert into _relatorio values ('curso_questoes_inalterado',
    (select count(*) from public.curso_questoes) = (select total_curso_questoes from _snapshot_antes), 'curso_questoes nao deve sofrer alteracao');
  insert into _relatorio values ('respostas_inalteradas',
    (select count(*) from public.respostas_usuarios) = (select total_respostas from _snapshot_antes), 'historico de respostas_usuarios nao deve mudar');
  insert into _relatorio values ('sessoes_inalteradas',
    (select count(*) from public.sessoes_estudo) = (select total_sessoes from _snapshot_antes), 'sessoes_estudo nao deve mudar');
  insert into _relatorio values ('vinculos_cresceram_exatamente_16',
    (select count(*) from public.questao_unidades_pedagogicas) = (select total_vinculos from _snapshot_antes) + 16,
    'total de vinculos deve crescer exatamente 16 em relacao ao snapshot antes');
end $$;

-- Relatório final — nunca aborta a transação; só relata.
do $$
declare
  v_tudo_ok boolean;
  r record;
begin
  select bool_and(ok) into v_tudo_ok from _relatorio;

  raise notice '=== RELATORIO DO TESTE (classificar_questoes_unidades_improbidade) ===';
  for r in select * from _relatorio order by etapa loop
    raise notice '% => % (%)', r.etapa, r.ok, r.detalhe;
  end loop;
  raise notice 'tudo_ok = %', coalesce(v_tudo_ok, false);
end $$;

-- SEMPRE desfaz — este arquivo nunca persiste nada.
rollback;
