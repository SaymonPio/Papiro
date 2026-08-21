-- Harness de teste (SEMPRE termina em ROLLBACK) da classificação de
-- questões de Lei de Drogas (curso_conteudos.id = 66) na única unidade
-- pedagógica aprovada. Aplica o mapa aprovado em
-- supabase/mapa_classificacao_lei_drogas.sql usando a RPC administrativa
-- oficial classificar_questao_unidade_admin (nenhum INSERT direto em
-- questao_unidades_pedagogicas), valida pré-condições e pós-condições, e
-- desfaz tudo ao final — nada aqui persiste no banco.
--
-- PRÉ-REQUISITO: supabase/curadoria_unidades_lei_drogas.sql precisa já
-- ter sido aplicado (a unidade pedagógica do conteúdo 66 precisa existir
-- com o id esperado, ordem 1, ativa) antes de este harness ser executado
-- — senão a precondição de unidade abaixo falha e o relatório final
-- aponta tudo_ok = false.
--
-- Diferença deste arquivo para
-- classificar_questoes_unidades_lei_drogas.sql (Etapa de aplicação
-- real): aqui cada verificação alimenta um relatório booleano (tudo_ok),
-- nunca aborta a transação sozinha — o roteiro inteiro roda até o fim e
-- só então decide, no relatório final, se teria sido seguro aplicar de
-- verdade. Termina SEMPRE em ROLLBACK, independentemente do resultado.

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
  (143, 'ba2341c7-0598-48f1-99dd-484692c1dfdb', 1, 'alta'),
  (269, 'ba2341c7-0598-48f1-99dd-484692c1dfdb', 1, 'alta'),
  (270, 'ba2341c7-0598-48f1-99dd-484692c1dfdb', 1, 'alta'),
  (740, 'ba2341c7-0598-48f1-99dd-484692c1dfdb', 1, 'alta'),
  (741, 'ba2341c7-0598-48f1-99dd-484692c1dfdb', 1, 'alta'),
  (742, 'ba2341c7-0598-48f1-99dd-484692c1dfdb', 1, 'media'),
  (781, 'ba2341c7-0598-48f1-99dd-484692c1dfdb', 1, 'alta'),
  (782, 'ba2341c7-0598-48f1-99dd-484692c1dfdb', 1, 'alta'),
  (783, 'ba2341c7-0598-48f1-99dd-484692c1dfdb', 1, 'alta'),
  (803, 'ba2341c7-0598-48f1-99dd-484692c1dfdb', 1, 'alta'),
  (804, 'ba2341c7-0598-48f1-99dd-484692c1dfdb', 1, 'alta'),
  (867, 'ba2341c7-0598-48f1-99dd-484692c1dfdb', 1, 'alta'),
  (868, 'ba2341c7-0598-48f1-99dd-484692c1dfdb', 1, 'alta'),
  (869, 'ba2341c7-0598-48f1-99dd-484692c1dfdb', 1, 'alta'),
  (870, 'ba2341c7-0598-48f1-99dd-484692c1dfdb', 1, 'alta');

create temporary table _relatorio (
  etapa text,
  ok boolean,
  detalhe text
) on commit drop;

-- Lock determinístico das linhas envolvidas antes de revalidar.
do $$
begin
  perform 1 from public.unidades_pedagogicas
  where curso_conteudo_id = 66
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

-- Precondições.
do $$
declare
  v_materia_id bigint;
  v_assunto_id bigint;
  v_total_candidatas int;
  v_classificacoes_previas int;
  v_unidade_ok boolean;
begin
  select cm.materia_id, cc.assunto_id into v_materia_id, v_assunto_id
  from public.curso_conteudos cc
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where cc.id = 66;

  insert into _relatorio values (
    'conteudo_66_materia_assunto',
    v_materia_id is not distinct from 10 and v_assunto_id is not distinct from 78,
    format('materia_id=%s assunto_id=%s (esperado 10/78)', v_materia_id, v_assunto_id)
  );

  select exists (
    select 1 from public.unidades_pedagogicas
    where id = 'ba2341c7-0598-48f1-99dd-484692c1dfdb' and curso_conteudo_id = 66 and ordem = 1 and ativa
  ) into v_unidade_ok;

  insert into _relatorio values (
    'unidade_oficial_existe',
    coalesce(v_unidade_ok, false),
    'unidade ordem=1 (ba2341c7...) precisa existir, ativa, no conteudo 66 — depende de curadoria_unidades_lei_drogas.sql já aplicado'
  );

  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 66) <> 1 then
    insert into _relatorio values ('exatamente_1_unidade', false,
      format('unidades do conteudo 66 = %s (esperado 1 — decisao aprovada foi manter unidade unica)', (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 66)));
  else
    insert into _relatorio values ('exatamente_1_unidade', true, 'ok');
  end if;

  select count(*) into v_total_candidatas
  from public.questoes q
  join public.curso_conteudos cc on cc.id = 66
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where q.ativa = true
    and q.materia_id = cm.materia_id
    and (cc.assunto_id is null or q.assunto_id = cc.assunto_id);

  insert into _relatorio values (
    'total_candidatas_16',
    v_total_candidatas = 16,
    format('total_candidatas=%s (esperado 16 — inclui a 674 excluida do mapa)', v_total_candidatas)
  );

  select count(*) into v_classificacoes_previas
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 66
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
  v_contem_674 boolean;
begin
  select count(*) into v_invalidas
  from _mapa m
  join public.questoes q on q.id = m.questao_id
  where not (q.ativa = true and q.materia_id = 10 and q.assunto_id = 78);

  insert into _relatorio values (
    'mapa_todas_questoes_validas',
    v_invalidas = 0,
    format('%s linha(s) apontam para questao fora de ativa=true/materia_id=10/assunto_id=78', v_invalidas)
  );

  select count(*) into v_distintas from (select distinct questao_id from _mapa) x;
  insert into _relatorio values (
    'mapa_cobre_15_distintas',
    v_distintas = 15,
    format('mapa cobre %s questoes distintas (esperado 15)', v_distintas)
  );

  select exists (select 1 from _mapa where questao_id = 674) into v_contem_674;
  insert into _relatorio values (
    'mapa_nao_contem_674',
    not coalesce(v_contem_674, false),
    'a questao 674 (fora de escopo, achado da auditoria) nao deve constar no mapa'
  );

  select count(*) into v_fora_do_candidato
  from _mapa m
  where not exists (
    select 1
    from public.questoes q
    join public.curso_conteudos cc on cc.id = 66
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where q.id = m.questao_id
      and q.ativa = true
      and q.materia_id = cm.materia_id
      and (cc.assunto_id is null or q.assunto_id = cc.assunto_id)
  );
  insert into _relatorio values (
    'mapa_sem_linhas_fora_do_candidato',
    v_fora_do_candidato = 0,
    format('%s linha(s) fora do conjunto candidato de 16 ativas', v_fora_do_candidato)
  );

  select count(*) into v_unidade_fora
  from _mapa m
  where m.unidade_pedagogica_id not in (select id from public.unidades_pedagogicas where curso_conteudo_id = 66);
  insert into _relatorio values (
    'mapa_unidade_pertence_ao_conteudo',
    v_unidade_fora = 0,
    format('%s linha(s) referenciam unidade pedagogica fora do conteudo 66', v_unidade_fora)
  );
end $$;

-- Aplicação via RPC oficial (só prossegue com efeito real se a unidade
-- existir — se a precondição acima falhou, este loop simplesmente não
-- encontra o que classificar corretamente e o relatório final reprova).
do $$
declare r record;
begin
  for r in select questao_id, unidade_pedagogica_id from _mapa order by questao_id loop
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
  v_674_classificada boolean;
begin
  select count(*) into v_total_vinculos
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 66;
  insert into _relatorio values ('total_vinculos_15', v_total_vinculos = 15, format('total_vinculos=%s (esperado 15)', v_total_vinculos));

  select count(distinct qup.questao_id) into v_questoes_classificadas
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 66;
  insert into _relatorio values ('questoes_classificadas_15', v_questoes_classificadas = 15, format('questoes_classificadas=%s (esperado 15)', v_questoes_classificadas));

  select count(*) into v_fora_do_mapa
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 66
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
    where u.curso_conteudo_id = 66
    group by qup.questao_id
    having count(*) > 1
  ) x;
  insert into _relatorio values ('nenhuma_multiunidade', v_multiunidade is null, format('multiunidade=%s (esperado nenhuma — unidade unica)', v_multiunidade));

  select exists (
    select 1 from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where u.curso_conteudo_id = 66 and qup.questao_id = 674
  ) into v_674_classificada;
  insert into _relatorio values ('674_permanece_nao_classificada', not coalesce(v_674_classificada, false), 'a questao 674 nao deve ter sido classificada por este arquivo');

  insert into _relatorio values ('unidades_pedagogicas_inalteradas_em_qtd',
    (select count(*) from public.unidades_pedagogicas) = (select total_unidades from _snapshot_antes),
    'esperado: nenhuma unidade nova criada por este arquivo (nem pela curadoria, que so faz UPDATE)');
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
  insert into _relatorio values ('vinculos_cresceram_exatamente_15',
    (select count(*) from public.questao_unidades_pedagogicas) = (select total_vinculos from _snapshot_antes) + 15,
    'total de vinculos deve crescer exatamente 15 em relacao ao snapshot antes');
end $$;

-- Relatório final — nunca aborta a transação; só relata.
do $$
declare
  v_tudo_ok boolean;
  r record;
begin
  select bool_and(ok) into v_tudo_ok from _relatorio;

  raise notice '=== RELATORIO DO TESTE (classificar_questoes_unidades_lei_drogas) ===';
  for r in select * from _relatorio order by etapa loop
    raise notice '% => % (%)', r.etapa, r.ok, r.detalhe;
  end loop;
  raise notice 'tudo_ok = %', coalesce(v_tudo_ok, false);
end $$;

-- SEMPRE desfaz — este arquivo nunca persiste nada.
rollback;
