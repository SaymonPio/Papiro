-- Harness de teste (SEMPRE termina em ROLLBACK) do saneamento taxonomico da
-- Q351 (Direitos Humanos e Cidadania): reclassifica assunto_id de 99
-- ("Tratados de Direitos Humanos com forca de Emenda Constitucional", cc78)
-- para 27 ("Pessoa com deficiencia", cc71) e cria o vinculo pedagogico
-- correspondente em questao_unidades_pedagogicas.
--
-- Motivo: auditoria pedagogica (teste contrafactual) confirmou que o
-- objeto nuclear de Q351 e o conteudo substantivo da CDPD (adaptacao
-- razoavel x desenho universal, art. 2; igualdade e nao discriminacao,
-- art. 5; acessibilidade como principio, art. 3 "f"; direito de opiniao da
-- crianca com deficiencia, art. 7 §3) — coberto pelo escopo de cc71, e nao
-- pelo escopo de cc78 (que trata do rito/hierarquia constitucional dos
-- tratados, usando a CDPD apenas como exemplo de instrumento). A convencao
-- de curadoria do projeto (docs/REGRAS_CURADORIA_PAPIRO.md, pre-condicao
-- padrao "materia_id/assunto_id conferidos por valor exato") exige
-- q.assunto_id = cc.assunto_id para qualquer vinculo — daí a necessidade
-- de reclassificar o assunto_id antes do vinculo, e nao apenas vincular
-- por fora da regra.
--
-- Escopo: UPDATE de questoes.assunto_id (99->27) + 1 INSERT via RPC oficial
-- em questao_unidades_pedagogicas. NAO altera enunciado, alternativas,
-- gabarito, explicacao, banca, concurso, ano, fonte, ativa. NAO toca em
-- cc78 nem em nenhuma outra questao.
--
-- Termina SEMPRE em ROLLBACK — nada aqui persiste no banco.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _snapshot_antes on commit drop as
select id, ativa, assunto_id, banca, concurso, ano, fonte, enunciado, explicacao,
  (select count(*) from public.alternativas where questao_id = 351) as n_alt,
  (select array_agg(ordem order by ordem) from public.alternativas where questao_id = 351) as ordens,
  (select array_agg(texto order by ordem) from public.alternativas where questao_id = 351) as textos,
  (select ordem from public.alternativas where questao_id = 351 and correta) as ordem_correta,
  (select count(*) from public.questao_unidades_pedagogicas where questao_id = 351) as vinculos
from public.questoes
where id = 351;

create temporary table _totais_antes on commit drop as
select
  (select count(*) from public.questoes) as total_questoes,
  (select count(*) from public.alternativas) as total_alternativas,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos,
  (select count(distinct qup.questao_id)
     from public.questao_unidades_pedagogicas qup
     join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
     where up.curso_conteudo_id = 71) as cc71_uteis,
  (select count(distinct qup.questao_id)
     from public.questao_unidades_pedagogicas qup
     join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
     join public.questoes q on q.id = qup.questao_id
     where up.curso_conteudo_id = 71 and lower(q.banca) not like '%papiro%') as cc71_real,
  (select count(distinct qup.questao_id)
     from public.questao_unidades_pedagogicas qup
     join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
     join public.questoes q on q.id = qup.questao_id
     where up.curso_conteudo_id = 71 and lower(q.banca) like '%papiro%') as cc71_autoral,
  (select count(distinct qup.questao_id)
     from public.questao_unidades_pedagogicas qup
     join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
     where up.curso_conteudo_id = 78) as cc78_uteis,
  (select count(distinct qup.questao_id)
     from public.questao_unidades_pedagogicas qup
     join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
     join public.questoes q on q.id = qup.questao_id
     where up.curso_conteudo_id = 78 and lower(q.banca) not like '%papiro%') as cc78_real,
  (select count(distinct qup.questao_id)
     from public.questao_unidades_pedagogicas qup
     join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
     join public.questoes q on q.id = qup.questao_id
     where up.curso_conteudo_id = 78 and lower(q.banca) like '%papiro%') as cc78_autoral,
  (select count(distinct qup.questao_id)
     from public.questao_unidades_pedagogicas qup
     join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
     join public.curso_conteudos cc on cc.id = up.curso_conteudo_id
     join public.assuntos a on a.id = cc.assunto_id
     where a.materia_id = 11) as dh_uteis;

create temporary table _relatorio (
  etapa text,
  ok boolean,
  detalhe text
) on commit drop;

-- Precondicoes.
do $$
declare
  v_cc71_materia bigint;
  v_cc71_assunto bigint;
  v_cc71_unidade uuid;
  v_cc71_unidade_ativa boolean;
begin
  insert into _relatorio values (
    'q351_estado_inicial_esperado',
    exists (select 1 from _snapshot_antes where id = 351 and ativa = true and assunto_id = 99 and n_alt = 5 and ordem_correta = 2 and vinculos = 0),
    'esperado: Q351 ativa=true, assunto_id=99, 5 alternativas, correta=ordem 2, vinculos=0'
  );

  select a.materia_id, cc.assunto_id, up.id, up.ativa
    into v_cc71_materia, v_cc71_assunto, v_cc71_unidade, v_cc71_unidade_ativa
  from public.curso_conteudos cc
  join public.assuntos a on a.id = cc.assunto_id
  join public.unidades_pedagogicas up on up.curso_conteudo_id = cc.id
  where cc.id = 71;

  insert into _relatorio values (
    'cc71_confere',
    v_cc71_materia is not distinct from 11 and v_cc71_assunto is not distinct from 27
      and v_cc71_unidade is not distinct from '435543fe-bdc2-452a-be2d-ffa414c5e27d'::uuid
      and coalesce(v_cc71_unidade_ativa, false),
    format('materia_id=%s assunto_id=%s unidade_id=%s ativa=%s (esperado 11/27/435543fe-.../true)', v_cc71_materia, v_cc71_assunto, v_cc71_unidade, v_cc71_unidade_ativa)
  );
end $$;

-- Aplicacao (dentro do teste): reclassificacao + vinculo.
do $$
begin
  update public.questoes set assunto_id = 27 where id = 351;

  begin
    perform public.classificar_questao_unidade_admin(351, '435543fe-bdc2-452a-be2d-ffa414c5e27d'::uuid);
  exception when others then
    insert into _relatorio values ('rpc_sem_erro', false, format('erro ao classificar: %s', sqlerrm));
  end;
end $$;

-- Pos-condicoes.
do $$
declare
  v_assunto_id bigint;
  v_ativa boolean;
  v_enunciado_igual boolean;
  v_explicacao_igual boolean;
  v_n_alt int;
  v_alt_intactas int;
  v_ordem_correta int;
  v_vinculos int;
  v_vinculo_cc71 boolean;
  v_multiunidade boolean;
  v_cc71_uteis_depois int;
  v_cc71_real_depois int;
  v_cc71_autoral_depois int;
  v_cc78_uteis_depois int;
  v_cc78_real_depois int;
  v_cc78_autoral_depois int;
  v_dh_uteis_depois int;
begin
  select q.assunto_id, q.ativa,
         (q.enunciado = sa.enunciado),
         (q.explicacao is not distinct from sa.explicacao)
    into v_assunto_id, v_ativa, v_enunciado_igual, v_explicacao_igual
  from public.questoes q, _snapshot_antes sa
  where q.id = 351 and sa.id = 351;

  insert into _relatorio values ('assunto_id_alterado_99_para_27', v_assunto_id = 27, format('assunto_id=%s (esperado 27)', v_assunto_id));
  insert into _relatorio values ('ativa_permanece_true', v_ativa is distinct from false, format('ativa=%s (esperado true)', v_ativa));
  insert into _relatorio values ('enunciado_intacto', v_enunciado_igual, 'enunciado nao deve mudar');
  insert into _relatorio values ('explicacao_intacta', v_explicacao_igual, 'explicacao (saneada) nao deve mudar');

  select count(*) into v_n_alt from public.alternativas where questao_id = 351;
  insert into _relatorio values ('alternativas_5', v_n_alt = 5, format('n_alt=%s (esperado 5)', v_n_alt));

  select count(*) into v_alt_intactas
  from public.alternativas a
  join (select unnest((select ordens from _snapshot_antes)) as ordem, unnest((select textos from _snapshot_antes)) as texto) s
    on s.ordem = a.ordem and s.texto = a.texto
  where a.questao_id = 351;
  insert into _relatorio values ('alternativas_intactas', v_alt_intactas = 5, format('alt_intactas=%s (esperado 5)', v_alt_intactas));

  select ordem into v_ordem_correta from public.alternativas where questao_id = 351 and correta;
  insert into _relatorio values ('gabarito_intacto_ordem_2', v_ordem_correta is not distinct from 2, format('ordem_correta=%s (esperado 2)', v_ordem_correta));

  select count(*) into v_vinculos from public.questao_unidades_pedagogicas where questao_id = 351;
  insert into _relatorio values ('exatamente_1_vinculo', v_vinculos = 1, format('vinculos=%s (esperado 1)', v_vinculos));

  select exists (
    select 1 from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    where qup.questao_id = 351 and up.curso_conteudo_id = 71
  ) into v_vinculo_cc71;
  insert into _relatorio values ('vinculo_e_com_cc71', coalesce(v_vinculo_cc71, false), 'vinculo deve apontar para a unidade de cc71');

  select (count(*) > 1) into v_multiunidade from public.questao_unidades_pedagogicas where questao_id = 351;
  insert into _relatorio values ('sem_multiunidade', not coalesce(v_multiunidade, false), 'Q351 deve ter no maximo 1 vinculo');

  select count(distinct qup.questao_id) into v_cc71_uteis_depois
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    where up.curso_conteudo_id = 71;
  insert into _relatorio values ('cc71_uteis_8_para_9', v_cc71_uteis_depois = (select cc71_uteis from _totais_antes) + 1, format('cc71_uteis=%s', v_cc71_uteis_depois));

  select count(distinct qup.questao_id) into v_cc71_real_depois
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.questoes q on q.id = qup.questao_id
    where up.curso_conteudo_id = 71 and lower(q.banca) not like '%papiro%';
  insert into _relatorio values ('cc71_real_7_para_8', v_cc71_real_depois = (select cc71_real from _totais_antes) + 1, format('cc71_real=%s', v_cc71_real_depois));

  select count(distinct qup.questao_id) into v_cc71_autoral_depois
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.questoes q on q.id = qup.questao_id
    where up.curso_conteudo_id = 71 and lower(q.banca) like '%papiro%';
  insert into _relatorio values ('cc71_autoral_permanece_1', v_cc71_autoral_depois = (select cc71_autoral from _totais_antes), format('cc71_autoral=%s', v_cc71_autoral_depois));

  select count(distinct qup.questao_id) into v_cc78_uteis_depois
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    where up.curso_conteudo_id = 78;
  insert into _relatorio values ('cc78_uteis_inalterado', v_cc78_uteis_depois = (select cc78_uteis from _totais_antes), format('cc78_uteis=%s (nao deve mudar)', v_cc78_uteis_depois));

  select count(distinct qup.questao_id) into v_cc78_real_depois
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.questoes q on q.id = qup.questao_id
    where up.curso_conteudo_id = 78 and lower(q.banca) not like '%papiro%';
  insert into _relatorio values ('cc78_real_inalterado', v_cc78_real_depois = (select cc78_real from _totais_antes), format('cc78_real=%s (nao deve mudar)', v_cc78_real_depois));

  select count(distinct qup.questao_id) into v_cc78_autoral_depois
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.questoes q on q.id = qup.questao_id
    where up.curso_conteudo_id = 78 and lower(q.banca) like '%papiro%';
  insert into _relatorio values ('cc78_autoral_inalterado', v_cc78_autoral_depois = (select cc78_autoral from _totais_antes), format('cc78_autoral=%s (nao deve mudar)', v_cc78_autoral_depois));

  select count(distinct qup.questao_id) into v_dh_uteis_depois
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.curso_conteudos cc on cc.id = up.curso_conteudo_id
    join public.assuntos a on a.id = cc.assunto_id
    where a.materia_id = 11;
  insert into _relatorio values ('dh_uteis_123_para_124', v_dh_uteis_depois = (select dh_uteis from _totais_antes) + 1, format('dh_uteis=%s', v_dh_uteis_depois));

  insert into _relatorio values ('total_questoes_inalterado',
    (select count(*) from public.questoes) = (select total_questoes from _totais_antes), 'contagem de questoes nao deve mudar');
  insert into _relatorio values ('total_alternativas_inalterado',
    (select count(*) from public.alternativas) = (select total_alternativas from _totais_antes), 'contagem de alternativas nao deve mudar');
  insert into _relatorio values ('total_vinculos_cresceu_1',
    (select count(*) from public.questao_unidades_pedagogicas) = (select total_vinculos from _totais_antes) + 1, 'total de vinculos deve crescer exatamente 1');
end $$;

-- Relatorio final — nunca aborta a transacao; so relata.
do $$
declare
  v_tudo_ok boolean;
  r record;
begin
  select bool_and(ok) into v_tudo_ok from _relatorio;

  raise notice '=== RELATORIO DO TESTE (saneamento_taxonomico_q351_pessoa_com_deficiencia) ===';
  for r in select * from _relatorio order by etapa loop
    raise notice '% => % (%)', r.etapa, r.ok, r.detalhe;
  end loop;
  raise notice 'tudo_ok = %', coalesce(v_tudo_ok, false);
end $$;

-- SEMPRE desfaz — este arquivo nunca persiste nada.
rollback;
