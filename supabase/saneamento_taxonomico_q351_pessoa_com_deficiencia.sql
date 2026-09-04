-- Aplicacao REAL do saneamento taxonomico da Q351 (Direitos Humanos e
-- Cidadania), validado pelo harness
-- supabase/saneamento_taxonomico_q351_pessoa_com_deficiencia_teste_rollback.sql
-- (tudo_ok = true confirmado antes de rodar este arquivo).
--
-- Reclassifica assunto_id de Q351 de 99 ("Tratados de Direitos Humanos com
-- forca de Emenda Constitucional", cc78) para 27 ("Pessoa com
-- deficiencia", cc71) e cria o vinculo pedagogico correspondente em
-- questao_unidades_pedagogicas.
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
-- de reclassificar o assunto_id antes do vinculo.
--
-- Escopo: UPDATE de questoes.assunto_id (99->27) + 1 INSERT via RPC oficial
-- classificar_questao_unidade_admin em questao_unidades_pedagogicas. NAO
-- altera enunciado, alternativas, gabarito, explicacao, banca, concurso,
-- ano, fonte, ativa. NAO toca em cc78 nem em nenhuma outra questao.
--
-- Diferenca deste arquivo para o harness: termina em COMMIT. Cada
-- precondicao/pos-condicao usa RAISE EXCEPTION — qualquer divergencia
-- aborta a transacao inteira antes de confirmar.

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

-- Precondicoes.
do $$
declare
  v_cc71_materia bigint;
  v_cc71_assunto bigint;
  v_cc71_unidade uuid;
  v_cc71_unidade_ativa boolean;
begin
  if not exists (select 1 from _snapshot_antes where id = 351 and ativa = true and assunto_id = 99 and n_alt = 5 and ordem_correta = 2 and vinculos = 0) then
    raise exception 'Precondicao falhou: Q351 nao esta no estado esperado (ativa=true, assunto_id=99, 5 alt, correta=ordem 2, vinculos=0)';
  end if;

  select a.materia_id, cc.assunto_id, up.id, up.ativa
    into v_cc71_materia, v_cc71_assunto, v_cc71_unidade, v_cc71_unidade_ativa
  from public.curso_conteudos cc
  join public.assuntos a on a.id = cc.assunto_id
  join public.unidades_pedagogicas up on up.curso_conteudo_id = cc.id
  where cc.id = 71;

  if v_cc71_materia is distinct from 11 or v_cc71_assunto is distinct from 27
     or v_cc71_unidade is distinct from '435543fe-bdc2-452a-be2d-ffa414c5e27d'::uuid
     or coalesce(v_cc71_unidade_ativa, false) is not true then
    raise exception 'Precondicao falhou: cc71 nao confere (materia_id=%, assunto_id=%, unidade_id=%, ativa=%)', v_cc71_materia, v_cc71_assunto, v_cc71_unidade, v_cc71_unidade_ativa;
  end if;
end $$;

-- Aplicacao: reclassificacao de assunto_id + vinculo via RPC oficial.
update public.questoes set assunto_id = 27 where id = 351;

select public.classificar_questao_unidade_admin(351, '435543fe-bdc2-452a-be2d-ffa414c5e27d'::uuid);

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

  if v_assunto_id is distinct from 27 then
    raise exception 'Pos-condicao falhou: assunto_id=% (esperado 27)', v_assunto_id;
  end if;
  if v_ativa is distinct from true then
    raise exception 'Pos-condicao falhou: ativa=% (esperado true)', v_ativa;
  end if;
  if not v_enunciado_igual then
    raise exception 'Pos-condicao falhou: enunciado foi alterado indevidamente';
  end if;
  if not v_explicacao_igual then
    raise exception 'Pos-condicao falhou: explicacao (saneada) foi alterada indevidamente';
  end if;

  select count(*) into v_n_alt from public.alternativas where questao_id = 351;
  if v_n_alt <> 5 then
    raise exception 'Pos-condicao falhou: n_alt=% (esperado 5)', v_n_alt;
  end if;

  select count(*) into v_alt_intactas
  from public.alternativas a
  join (select unnest((select ordens from _snapshot_antes)) as ordem, unnest((select textos from _snapshot_antes)) as texto) s
    on s.ordem = a.ordem and s.texto = a.texto
  where a.questao_id = 351;
  if v_alt_intactas <> 5 then
    raise exception 'Pos-condicao falhou: alt_intactas=% (esperado 5)', v_alt_intactas;
  end if;

  select ordem into v_ordem_correta from public.alternativas where questao_id = 351 and correta;
  if v_ordem_correta is distinct from 2 then
    raise exception 'Pos-condicao falhou: ordem_correta=% (esperado 2)', v_ordem_correta;
  end if;

  select count(*) into v_vinculos from public.questao_unidades_pedagogicas where questao_id = 351;
  if v_vinculos <> 1 then
    raise exception 'Pos-condicao falhou: vinculos=% (esperado 1)', v_vinculos;
  end if;

  select exists (
    select 1 from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    where qup.questao_id = 351 and up.curso_conteudo_id = 71
  ) into v_vinculo_cc71;
  if not coalesce(v_vinculo_cc71, false) then
    raise exception 'Pos-condicao falhou: o vinculo de Q351 nao aponta para a unidade de cc71';
  end if;

  select count(distinct qup.questao_id) into v_cc71_uteis_depois
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    where up.curso_conteudo_id = 71;
  if v_cc71_uteis_depois <> (select cc71_uteis from _totais_antes) + 1 then
    raise exception 'Pos-condicao falhou: cc71_uteis=% (esperado %)', v_cc71_uteis_depois, (select cc71_uteis from _totais_antes) + 1;
  end if;

  select count(distinct qup.questao_id) into v_cc71_real_depois
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.questoes q on q.id = qup.questao_id
    where up.curso_conteudo_id = 71 and lower(q.banca) not like '%papiro%';
  if v_cc71_real_depois <> (select cc71_real from _totais_antes) + 1 then
    raise exception 'Pos-condicao falhou: cc71_real=% (esperado %)', v_cc71_real_depois, (select cc71_real from _totais_antes) + 1;
  end if;

  select count(distinct qup.questao_id) into v_cc71_autoral_depois
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.questoes q on q.id = qup.questao_id
    where up.curso_conteudo_id = 71 and lower(q.banca) like '%papiro%';
  if v_cc71_autoral_depois <> (select cc71_autoral from _totais_antes) then
    raise exception 'Pos-condicao falhou: cc71_autoral=% (esperado inalterado %)', v_cc71_autoral_depois, (select cc71_autoral from _totais_antes);
  end if;

  select count(distinct qup.questao_id) into v_cc78_uteis_depois
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    where up.curso_conteudo_id = 78;
  if v_cc78_uteis_depois <> (select cc78_uteis from _totais_antes) then
    raise exception 'Pos-condicao falhou: cc78_uteis=% (nao deveria mudar, era %)', v_cc78_uteis_depois, (select cc78_uteis from _totais_antes);
  end if;

  select count(distinct qup.questao_id) into v_cc78_real_depois
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.questoes q on q.id = qup.questao_id
    where up.curso_conteudo_id = 78 and lower(q.banca) not like '%papiro%';
  if v_cc78_real_depois <> (select cc78_real from _totais_antes) then
    raise exception 'Pos-condicao falhou: cc78_real=% (nao deveria mudar)', v_cc78_real_depois;
  end if;

  select count(distinct qup.questao_id) into v_cc78_autoral_depois
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.questoes q on q.id = qup.questao_id
    where up.curso_conteudo_id = 78 and lower(q.banca) like '%papiro%';
  if v_cc78_autoral_depois <> (select cc78_autoral from _totais_antes) then
    raise exception 'Pos-condicao falhou: cc78_autoral=% (nao deveria mudar)', v_cc78_autoral_depois;
  end if;

  select count(distinct qup.questao_id) into v_dh_uteis_depois
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.curso_conteudos cc on cc.id = up.curso_conteudo_id
    join public.assuntos a on a.id = cc.assunto_id
    where a.materia_id = 11;
  if v_dh_uteis_depois <> (select dh_uteis from _totais_antes) + 1 then
    raise exception 'Pos-condicao falhou: dh_uteis=% (esperado %)', v_dh_uteis_depois, (select dh_uteis from _totais_antes) + 1;
  end if;

  if (select count(*) from public.questoes) <> (select total_questoes from _totais_antes) then
    raise exception 'Pos-condicao falhou: contagem total de questoes mudou';
  end if;
  if (select count(*) from public.alternativas) <> (select total_alternativas from _totais_antes) then
    raise exception 'Pos-condicao falhou: contagem total de alternativas mudou';
  end if;
  if (select count(*) from public.questao_unidades_pedagogicas) <> (select total_vinculos from _totais_antes) + 1 then
    raise exception 'Pos-condicao falhou: total de vinculos nao cresceu exatamente 1';
  end if;

  raise notice 'Pos-condicoes OK: Q351 reclassificada (assunto_id 99->27) e vinculada a cc71 (Pessoa com deficiencia). cc71: uteis %->%, real %->%. cc78 inalterada. DH: uteis %->%.',
    (select cc71_uteis from _totais_antes), v_cc71_uteis_depois,
    (select cc71_real from _totais_antes), v_cc71_real_depois,
    (select dh_uteis from _totais_antes), v_dh_uteis_depois;
end $$;

commit;
