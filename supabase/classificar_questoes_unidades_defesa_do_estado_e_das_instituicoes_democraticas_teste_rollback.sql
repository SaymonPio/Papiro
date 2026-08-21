-- Harness de teste (SEMPRE termina em ROLLBACK) da classificacao de
-- questoes de Defesa do Estado e das Instituições Democráticas (curso_conteudos.id = 48)
-- nas 1 unidade(s) pedagogica(s) aprovada(s). Gerado pelo
-- pipeline automatico (scripts/curadoria-pedagogica/gerar-rollback.mjs) a
-- partir de config/defesa_do_estado_e_das_instituicoes_democraticas.unidades.json + config/defesa_do_estado_e_das_instituicoes_democraticas.mapa.json. Aplica o
-- mapa aprovado usando a RPC administrativa oficial
-- classificar_questao_unidade_admin (nenhum INSERT direto em
-- questao_unidades_pedagogicas), valida pre-condicoes e pos-condicoes, e
-- desfaz tudo ao final — nada aqui persiste no banco.
--
-- PRE-REQUISITO: supabase/curadoria_unidades_defesa_do_estado_e_das_instituicoes_democraticas.sql precisa ja ter sido
-- aplicado antes de este harness ser executado — senao a precondicao de
-- unidades abaixo falha e o relatorio final aponta tudo_ok = false.
--
-- Diferenca deste arquivo para classificar_questoes_unidades_defesa_do_estado_e_das_instituicoes_democraticas.sql
-- (etapa de aplicacao real): aqui cada verificacao alimenta um relatorio
-- booleano (tudo_ok), nunca aborta a transacao sozinha. Termina SEMPRE em
-- ROLLBACK, independentemente do resultado.

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
  (47, 'ecdb1d62-ef44-4407-b899-85911402bc90', 1, 'alta'),
  (113, 'ecdb1d62-ef44-4407-b899-85911402bc90', 1, 'alta'),
  (297, 'ecdb1d62-ef44-4407-b899-85911402bc90', 1, 'alta'),
  (654, 'ecdb1d62-ef44-4407-b899-85911402bc90', 1, 'alta'),
  (655, 'ecdb1d62-ef44-4407-b899-85911402bc90', 1, 'alta'),
  (656, 'ecdb1d62-ef44-4407-b899-85911402bc90', 1, 'alta');

create temporary table _relatorio (
  etapa text,
  ok boolean,
  detalhe text
) on commit drop;

-- Lock deterministico das linhas envolvidas antes de revalidar.
do $$
begin
  perform 1 from public.unidades_pedagogicas
  where curso_conteudo_id = 48
  order by id
  for update;
end $$;

do $$
begin
  perform 1 from public.questoes
  where id in (select distinct questao_id from _mapa)
  order by id
  for update;
end $$;

-- Precondicoes.
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
  where cc.id = 48;

  insert into _relatorio values (
    'conteudo_48_materia_assunto',
    v_materia_id is not distinct from 10 and v_assunto_id is not distinct from 74,
    format('materia_id=%s assunto_id=%s (esperado 10/74)', v_materia_id, v_assunto_id)
  );

  select bool_and(x.ok) into v_unidades_ok from (
    select exists (select 1 from public.unidades_pedagogicas where id = 'ecdb1d62-ef44-4407-b899-85911402bc90' and curso_conteudo_id = 48 and ordem = 1 and ativa) as ok
  ) x;

  insert into _relatorio values (
    'unidades_oficiais_existem',
    coalesce(v_unidades_ok, false),
    'todas as 1 unidade(s) oficial(is) precisam existir, ativas, no conteudo 48 — depende de curadoria_unidades_defesa_do_estado_e_das_instituicoes_democraticas.sql ja aplicado'
  );

  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 48) <> 1 then
    insert into _relatorio values ('exatamente_1_unidade_s', false,
      format('unidades do conteudo 48 = %s (esperado 1)', (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 48)));
  else
    insert into _relatorio values ('exatamente_1_unidade_s', true, 'ok');
  end if;

  select count(*) into v_total_candidatas
  from public.questoes q
  join public.curso_conteudos cc on cc.id = 48
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where q.ativa = true
    and q.materia_id = cm.materia_id
    and (cc.assunto_id is null or q.assunto_id = cc.assunto_id);

  insert into _relatorio values (
    'total_candidatas_6',
    v_total_candidatas = 6,
    format('total_candidatas=%s (esperado 6)', v_total_candidatas)
  );

  select count(*) into v_classificacoes_previas
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 48
    and qup.questao_id in (select questao_id from _mapa);

  insert into _relatorio values (
    'sem_classificacao_previa',
    v_classificacoes_previas = 0,
    format('classificacoes_previas=%s (esperado 0)', v_classificacoes_previas)
  );
end $$;

-- Validacao do mapa em si.
do $$
declare
  v_invalidas int;
  v_fora_do_candidato int;
  v_unidade_fora int;
  v_distintas int;
  v_contem_excluida boolean;
begin
  select count(*) into v_invalidas
  from _mapa m
  join public.questoes q on q.id = m.questao_id
  where not (q.ativa = true and q.materia_id = 10 and q.assunto_id = 74);

  insert into _relatorio values (
    'mapa_todas_questoes_validas',
    v_invalidas = 0,
    format('%s linha(s) apontam para questao fora de ativa=true/materia_id=10/assunto_id=74', v_invalidas)
  );

  select count(*) into v_distintas from (select distinct questao_id from _mapa) x;
  insert into _relatorio values (
    'mapa_cobre_6_distintas',
    v_distintas = 6,
    format('mapa cobre %s questoes distintas (esperado 6)', v_distintas)
  );


  select count(*) into v_fora_do_candidato
  from _mapa m
  where not exists (
    select 1
    from public.questoes q
    join public.curso_conteudos cc on cc.id = 48
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where q.id = m.questao_id
      and q.ativa = true
      and q.materia_id = cm.materia_id
      and (cc.assunto_id is null or q.assunto_id = cc.assunto_id)
  );
  insert into _relatorio values (
    'mapa_sem_linhas_fora_do_candidato',
    v_fora_do_candidato = 0,
    format('%s linha(s) fora do conjunto candidato de 6 ativas', v_fora_do_candidato)
  );

  select count(*) into v_unidade_fora
  from _mapa m
  where m.unidade_pedagogica_id not in (select id from public.unidades_pedagogicas where curso_conteudo_id = 48);
  insert into _relatorio values (
    'mapa_unidades_pertencem_ao_conteudo',
    v_unidade_fora = 0,
    format('%s linha(s) referenciam unidade pedagogica fora do conteudo 48', v_unidade_fora)
  );
end $$;

-- Aplicacao via RPC oficial (so prossegue com efeito real se as unidades
-- existirem — se a precondicao acima falhou, este loop simplesmente nao
-- encontra o que classificar corretamente e o relatorio final reprova).
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

-- Pos-condicoes.
do $$
declare
  v_total_vinculos int;
  v_questoes_classificadas int;
  v_fora_do_mapa int;
  v_faltando int;
  v_multiunidade bigint[];
  v_qtd_tmp int;
  v_excluida_tmp boolean;
begin
  select count(*) into v_total_vinculos
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 48;
  insert into _relatorio values ('total_vinculos_6', v_total_vinculos = 6, format('total_vinculos=%s (esperado 6)', v_total_vinculos));

  select count(distinct qup.questao_id) into v_questoes_classificadas
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 48;
  insert into _relatorio values ('questoes_classificadas_6', v_questoes_classificadas = 6, format('questoes_classificadas=%s (esperado 6)', v_questoes_classificadas));

  select count(*) into v_fora_do_mapa
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 48
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
    where u.curso_conteudo_id = 48
    group by qup.questao_id
    having count(*) > 1
  ) x;

  insert into _relatorio values ('nenhuma_multiunidade', v_multiunidade is null, format('multiunidade=%s (esperado nenhuma)', v_multiunidade));

  select count(distinct qup.questao_id) into v_qtd_tmp
  from public.questao_unidades_pedagogicas qup
  where qup.unidade_pedagogica_id = 'ecdb1d62-ef44-4407-b899-85911402bc90';
  insert into _relatorio values ('u1_6_questoes', v_qtd_tmp = 6, format('u1_questoes=%s (esperado 6)', v_qtd_tmp));


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
  insert into _relatorio values ('vinculos_cresceram_exatamente_6',
    (select count(*) from public.questao_unidades_pedagogicas) = (select total_vinculos from _snapshot_antes) + 6,
    'total de vinculos deve crescer exatamente 6 em relacao ao snapshot antes');
end $$;

-- Relatorio final — nunca aborta a transacao; so relata.
do $$
declare
  v_tudo_ok boolean;
  r record;
begin
  select bool_and(ok) into v_tudo_ok from _relatorio;

  raise notice '=== RELATORIO DO TESTE (classificar_questoes_unidades_defesa_do_estado_e_das_instituicoes_democraticas) ===';
  for r in select * from _relatorio order by etapa loop
    raise notice '% => % (%)', r.etapa, r.ok, r.detalhe;
  end loop;
  raise notice 'tudo_ok = %', coalesce(v_tudo_ok, false);
end $$;

-- SEMPRE desfaz — este arquivo nunca persiste nada.
rollback;
