-- Harness de teste (SEMPRE termina em ROLLBACK) da classificacao de
-- questoes de Implícitos e subentendidos (curso_conteudos.id = 25)
-- nas 1 unidade(s) pedagogica(s) aprovada(s). Gerado pelo
-- pipeline automatico (scripts/curadoria-pedagogica/gerar-rollback.mjs) a
-- partir de config/implicitos_e_subentendidos.unidades.json + config/implicitos_e_subentendidos.mapa.json. Aplica o
-- mapa aprovado usando a RPC administrativa oficial
-- classificar_questao_unidade_admin (nenhum INSERT direto em
-- questao_unidades_pedagogicas), valida pre-condicoes e pos-condicoes, e
-- desfaz tudo ao final — nada aqui persiste no banco.
--
-- PRE-REQUISITO: supabase/curadoria_unidades_implicitos_e_subentendidos.sql precisa ja ter sido
-- aplicado antes de este harness ser executado — senao a precondicao de
-- unidades abaixo falha e o relatorio final aponta tudo_ok = false.
--
-- Diferenca deste arquivo para classificar_questoes_unidades_implicitos_e_subentendidos.sql
-- (etapa de aplicacao real): aqui cada verificacao alimenta um relatorio
-- booleano (tudo_ok), nunca aborta a transacao sozinha. Termina SEMPRE em
-- ROLLBACK, independentemente do resultado.
--
-- AJUSTE LOCALIZADO (2026-08-23, nao propagado ao gerador generico
-- gerar-rollback.mjs): ao contrario de todo conteudo anterior desta fila,
-- este conteudo NAO parte de zero classificacoes. A questao 878 ja foi
-- saneada taxonomicamente e vinculada a esta mesma unidade em operacao
-- separada e ja commitada (assunto_id 47->46, RPC classificar_questao_unidade_admin,
-- commit 5856a10) ANTES desta curadoria. Por isso, duas checagens do
-- template padrao foram corrigidas a mao para refletir o estado real
-- (marcadas abaixo com "AJUSTE"): a checagem de "sem classificacao
-- previa" (aqui ha exatamente 1, a propria Q878 ja saneada — nao e uma
-- falha) e a checagem de crescimento de vinculos (crescem exatamente 3
-- nesta operacao — Q234, Q235, Q236 — e nao 4, pois Q878 ja contava no
-- snapshot antes). O loop de aplicacao via RPC abaixo continua cobrindo
-- os 4 QIDs do mapa aprovado (inclusive Q878): a RPC e
-- ON CONFLICT DO NOTHING, entao reprocessar Q878 e um no-op seguro, sem
-- duplicar vinculo — o resultado final continua sendo exatamente 1
-- vinculo por QID, explicitamente validado nas pos-condicoes.

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
  (234, '1a2158e8-f690-43ab-8ca5-051ba1c0fa3e', 1, 'alta'),
  (235, '1a2158e8-f690-43ab-8ca5-051ba1c0fa3e', 1, 'alta'),
  (236, '1a2158e8-f690-43ab-8ca5-051ba1c0fa3e', 1, 'alta'),
  (878, '1a2158e8-f690-43ab-8ca5-051ba1c0fa3e', 1, 'alta');

create temporary table _relatorio (
  etapa text,
  ok boolean,
  detalhe text
) on commit drop;

-- Lock deterministico das linhas envolvidas antes de revalidar.
do $$
begin
  perform 1 from public.unidades_pedagogicas
  where curso_conteudo_id = 25
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
  where cc.id = 25;

  insert into _relatorio values (
    'conteudo_25_materia_assunto',
    v_materia_id is not distinct from 6 and v_assunto_id is not distinct from 46,
    format('materia_id=%s assunto_id=%s (esperado 6/46)', v_materia_id, v_assunto_id)
  );

  select bool_and(x.ok) into v_unidades_ok from (
    select exists (select 1 from public.unidades_pedagogicas where id = '1a2158e8-f690-43ab-8ca5-051ba1c0fa3e' and curso_conteudo_id = 25 and ordem = 1 and ativa) as ok
  ) x;

  insert into _relatorio values (
    'unidades_oficiais_existem',
    coalesce(v_unidades_ok, false),
    'todas as 1 unidade(s) oficial(is) precisam existir, ativas, no conteudo 25 — depende de curadoria_unidades_implicitos_e_subentendidos.sql ja aplicado'
  );

  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 25) <> 1 then
    insert into _relatorio values ('exatamente_1_unidade_s', false,
      format('unidades do conteudo 25 = %s (esperado 1)', (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 25)));
  else
    insert into _relatorio values ('exatamente_1_unidade_s', true, 'ok');
  end if;

  select count(*) into v_total_candidatas
  from public.questoes q
  join public.curso_conteudos cc on cc.id = 25
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where q.ativa = true
    and q.materia_id = cm.materia_id
    and (cc.assunto_id is null or q.assunto_id = cc.assunto_id);

  insert into _relatorio values (
    'total_candidatas_4',
    v_total_candidatas = 4,
    format('total_candidatas=%s (esperado 4)', v_total_candidatas)
  );

  select count(*) into v_classificacoes_previas
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 25
    and qup.questao_id in (select questao_id from _mapa);

  -- AJUSTE (ver nota no cabecalho): esperado exatamente 1 classificacao
  -- previa, e especificamente a da Q878 ja saneada (commit 5856a10),
  -- apontando para a unidade correta — nao 0 como no template generico.
  insert into _relatorio values (
    'classificacao_previa_e_apenas_q878_ja_saneada',
    v_classificacoes_previas = 1
      and exists (
        select 1 from public.questao_unidades_pedagogicas qup
        join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
        where u.curso_conteudo_id = 25
          and qup.questao_id = 878
          and u.id = '1a2158e8-f690-43ab-8ca5-051ba1c0fa3e'
      ),
    format('classificacoes_previas=%s (esperado exatamente 1: Q878, ja saneada e vinculada no commit 5856a10, antes desta curadoria)', v_classificacoes_previas)
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
  where not (q.ativa = true and q.materia_id = 6 and q.assunto_id = 46);

  insert into _relatorio values (
    'mapa_todas_questoes_validas',
    v_invalidas = 0,
    format('%s linha(s) apontam para questao fora de ativa=true/materia_id=6/assunto_id=46', v_invalidas)
  );

  select count(*) into v_distintas from (select distinct questao_id from _mapa) x;
  insert into _relatorio values (
    'mapa_cobre_4_distintas',
    v_distintas = 4,
    format('mapa cobre %s questoes distintas (esperado 4)', v_distintas)
  );


  select count(*) into v_fora_do_candidato
  from _mapa m
  where not exists (
    select 1
    from public.questoes q
    join public.curso_conteudos cc on cc.id = 25
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where q.id = m.questao_id
      and q.ativa = true
      and q.materia_id = cm.materia_id
      and (cc.assunto_id is null or q.assunto_id = cc.assunto_id)
  );
  insert into _relatorio values (
    'mapa_sem_linhas_fora_do_candidato',
    v_fora_do_candidato = 0,
    format('%s linha(s) fora do conjunto candidato de 4 ativas', v_fora_do_candidato)
  );

  select count(*) into v_unidade_fora
  from _mapa m
  where m.unidade_pedagogica_id not in (select id from public.unidades_pedagogicas where curso_conteudo_id = 25);
  insert into _relatorio values (
    'mapa_unidades_pertencem_ao_conteudo',
    v_unidade_fora = 0,
    format('%s linha(s) referenciam unidade pedagogica fora do conteudo 25', v_unidade_fora)
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
  where u.curso_conteudo_id = 25;
  insert into _relatorio values ('total_vinculos_4', v_total_vinculos = 4, format('total_vinculos=%s (esperado 4)', v_total_vinculos));

  select count(distinct qup.questao_id) into v_questoes_classificadas
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 25;
  insert into _relatorio values ('questoes_classificadas_4', v_questoes_classificadas = 4, format('questoes_classificadas=%s (esperado 4)', v_questoes_classificadas));

  select count(*) into v_fora_do_mapa
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 25
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
    where u.curso_conteudo_id = 25
    group by qup.questao_id
    having count(*) > 1
  ) x;

  insert into _relatorio values ('nenhuma_multiunidade', v_multiunidade is null, format('multiunidade=%s (esperado nenhuma)', v_multiunidade));

  select count(distinct qup.questao_id) into v_qtd_tmp
  from public.questao_unidades_pedagogicas qup
  where qup.unidade_pedagogica_id = '1a2158e8-f690-43ab-8ca5-051ba1c0fa3e';
  insert into _relatorio values ('u1_4_questoes', v_qtd_tmp = 4, format('u1_questoes=%s (esperado 4)', v_qtd_tmp));


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
  -- AJUSTE (ver nota no cabecalho): crescimento esperado e 3 (Q234, Q235,
  -- Q236 — novos vinculos nesta operacao), nao 4, pois o vinculo de Q878
  -- ja existia no snapshot antes (saneada em operacao separada).
  insert into _relatorio values ('vinculos_cresceram_exatamente_3',
    (select count(*) from public.questao_unidades_pedagogicas) = (select total_vinculos from _snapshot_antes) + 3,
    'total de vinculos deve crescer exatamente 3 em relacao ao snapshot antes (Q234/Q235/Q236 — Q878 ja contava no snapshot)');
end $$;

-- Relatorio final — nunca aborta a transacao; so relata.
do $$
declare
  v_tudo_ok boolean;
  r record;
begin
  select bool_and(ok) into v_tudo_ok from _relatorio;

  raise notice '=== RELATORIO DO TESTE (classificar_questoes_unidades_implicitos_e_subentendidos) ===';
  for r in select * from _relatorio order by etapa loop
    raise notice '% => % (%)', r.etapa, r.ok, r.detalhe;
  end loop;
  raise notice 'tudo_ok = %', coalesce(v_tudo_ok, false);
end $$;

-- SEMPRE desfaz — este arquivo nunca persiste nada.
rollback;
