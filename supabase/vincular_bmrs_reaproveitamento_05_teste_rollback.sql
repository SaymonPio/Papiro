-- TESTE DE ROLLBACK REAL do reaproveitamento BMRS-05.
-- Executa, dentro de UMA transacao controlada que termina em ROLLBACK
-- externo: OLD -> APPLY (mesma logica do apply real) -> TARGET (verifica)
-- -> REVERSAO REAL (mesma logica do reverter real, incluindo o guard de
-- curso_questoes intacto) -> OLD (verifica) -> rollback.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _relatorio (fase text, item text, ok boolean, detalhe text) on commit drop;

create temporary table _matriz_05 (
  questao_id bigint primary key,
  unidade_id uuid not null,
  cq_preexistente_esperado boolean not null,
  cq_criado_em_esperado timestamptz,
  cq_prioridade_esperado int
) on commit drop;

insert into _matriz_05 (questao_id, unidade_id, cq_preexistente_esperado, cq_criado_em_esperado, cq_prioridade_esperado) values
(222, '9a4936e1-a9a6-452c-9385-d5a5899ae5c5'::uuid, true, '2026-08-10 04:07:21.948098+00'::timestamptz, 1),
(224, '9a4936e1-a9a6-452c-9385-d5a5899ae5c5'::uuid, true, '2026-08-10 04:07:21.948098+00'::timestamptz, 1),
(68, '290650b5-0f55-49e1-871e-932003447e41'::uuid, true, '2026-08-10 03:17:20.776559+00'::timestamptz, 1),
(1338, '53dc06a1-cd16-4004-a76b-8201d95a91c4'::uuid, true, '2026-08-17 02:21:37.476112+00'::timestamptz, 1),
(1342, '53dc06a1-cd16-4004-a76b-8201d95a91c4'::uuid, true, '2026-08-17 02:21:37.476112+00'::timestamptz, 1);

-- ===================== FASE OLD =====================
do $$
declare
  v_target int; v_cq int; v_uteis_conc int; v_uteis_sig int; v_uteis_rede int;
begin
  select count(*) into v_target from _matriz_05 m
    where exists(select 1 from public.questao_unidades_pedagogicas qup where qup.questao_id=m.questao_id and qup.unidade_pedagogica_id=m.unidade_id);
  insert into _relatorio values ('OLD','vinculos_target_0de5', v_target=0, v_target::text);

  select count(*) into v_cq from _matriz_05 m
    join public.curso_questoes cq2 on cq2.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq2.questao_id=m.questao_id
    where cq2.criado_em=m.cq_criado_em_esperado and cq2.prioridade=m.cq_prioridade_esperado;
  insert into _relatorio values ('OLD','curso_questoes_5de5_preexistente', v_cq=5, v_cq::text);

  select count(distinct q.id) into v_uteis_conc from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
    where qup.unidade_pedagogica_id='9a4936e1-a9a6-452c-9385-d5a5899ae5c5' and q.ativa=true
    and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('OLD','uteis_concordancia_1', v_uteis_conc=1, v_uteis_conc::text);

  select count(distinct q.id) into v_uteis_sig from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
    where qup.unidade_pedagogica_id='290650b5-0f55-49e1-871e-932003447e41' and q.ativa=true
    and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('OLD','uteis_significacao_3', v_uteis_sig=3, v_uteis_sig::text);

  select count(distinct q.id) into v_uteis_rede from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
    where qup.unidade_pedagogica_id='53dc06a1-cd16-4004-a76b-8201d95a91c4' and q.ativa=true
    and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('OLD','uteis_rede_justica_4', v_uteis_rede=4, v_uteis_rede::text);
end $$;

-- ===================== APPLY (mesma logica do script real) =====================
do $$
declare
  r record;
  v_rows int;
begin
  for r in select questao_id, unidade_id from _matriz_05 order by questao_id loop
    perform public.classificar_questao_unidade_admin(r.questao_id, r.unidade_id);
  end loop;

  select count(*) into v_rows from _matriz_05 m
    where exists(select 1 from public.questao_unidades_pedagogicas qup where qup.questao_id=m.questao_id and qup.unidade_pedagogica_id=m.unidade_id);
  insert into _relatorio values ('APPLY','vinculos_criados_5de5', v_rows=5, v_rows::text);
end $$;

-- ===================== FASE TARGET =====================
do $$
declare
  v_cq int; v_cq_intactas int; v_uteis_conc int; v_uteis_sig int; v_uteis_rede int;
begin
  select count(*) into v_cq from _matriz_05 m
    where exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=m.questao_id);
  insert into _relatorio values ('TARGET','curso_questoes_5de5', v_cq=5, v_cq::text);

  select count(*) into v_cq_intactas from _matriz_05 m
    join public.curso_questoes cq2 on cq2.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq2.questao_id=m.questao_id
    where cq2.criado_em=m.cq_criado_em_esperado and cq2.prioridade=m.cq_prioridade_esperado;
  insert into _relatorio values ('TARGET','curso_questoes_preexistentes_intactas_5de5', v_cq_intactas=5, v_cq_intactas::text);

  select count(distinct q.id) into v_uteis_conc from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
    where qup.unidade_pedagogica_id='9a4936e1-a9a6-452c-9385-d5a5899ae5c5' and q.ativa=true
    and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET','uteis_concordancia_3', v_uteis_conc=3, v_uteis_conc::text);

  select count(distinct q.id) into v_uteis_sig from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
    where qup.unidade_pedagogica_id='290650b5-0f55-49e1-871e-932003447e41' and q.ativa=true
    and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET','uteis_significacao_4', v_uteis_sig=4, v_uteis_sig::text);

  select count(distinct q.id) into v_uteis_rede from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
    where qup.unidade_pedagogica_id='53dc06a1-cd16-4004-a76b-8201d95a91c4' and q.ativa=true
    and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET','uteis_rede_justica_6', v_uteis_rede=6, v_uteis_rede::text);
end $$;

-- ===================== REVERSAO REAL (mesma logica do reverter real) =====================
do $$
declare
  v_target int; v_cq_intactas int; v_rows int; v_antes int; v_depois int;
  r record;
begin
  select count(*) into v_target from _matriz_05 m
    where exists(select 1 from public.questao_unidades_pedagogicas qup where qup.questao_id=m.questao_id and qup.unidade_pedagogica_id=m.unidade_id);
  insert into _relatorio values ('REVERSAO_GUARD','vinculos_target_5de5', v_target=5, v_target::text);

  select count(*) into v_cq_intactas from _matriz_05 m
    join public.curso_questoes cq2 on cq2.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq2.questao_id=m.questao_id
    where cq2.criado_em=m.cq_criado_em_esperado and cq2.prioridade=m.cq_prioridade_esperado;
  insert into _relatorio values ('REVERSAO_GUARD','curso_questoes_intactas_5de5', v_cq_intactas=5, v_cq_intactas::text);

  select count(*) into v_antes from public.questao_unidades_pedagogicas where questao_id in (222, 224, 68, 1338, 1342);
  for r in select questao_id, unidade_id from _matriz_05 order by questao_id loop
    perform public.remover_classificacao_questao_unidade_admin(r.questao_id, r.unidade_id);
  end loop;
  select count(*) into v_depois from public.questao_unidades_pedagogicas where questao_id in (222, 224, 68, 1338, 1342);
  insert into _relatorio values ('REVERSAO','vinculos_removidos_5', (v_antes - v_depois) = 5, (v_antes - v_depois)::text);
end $$;

do $$
declare v_cq_intactas int;
begin
  select count(*) into v_cq_intactas from _matriz_05 m
    join public.curso_questoes cq2 on cq2.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq2.questao_id=m.questao_id
    where cq2.criado_em=m.cq_criado_em_esperado and cq2.prioridade=m.cq_prioridade_esperado;
  insert into _relatorio values ('REVERSAO','curso_questoes_permanece_intacto_5de5', v_cq_intactas=5, v_cq_intactas::text);
end $$;

-- ===================== FASE OLD (novamente, pos-reversao) =====================
do $$
declare
  v_target int; v_uteis_conc int; v_uteis_sig int; v_uteis_rede int;
begin
  select count(*) into v_target from _matriz_05 m
    where exists(select 1 from public.questao_unidades_pedagogicas qup where qup.questao_id=m.questao_id and qup.unidade_pedagogica_id=m.unidade_id);
  insert into _relatorio values ('OLD_FINAL','vinculos_target_0de5', v_target=0, v_target::text);

  select count(distinct q.id) into v_uteis_conc from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
    where qup.unidade_pedagogica_id='9a4936e1-a9a6-452c-9385-d5a5899ae5c5' and q.ativa=true
    and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('OLD_FINAL','uteis_concordancia_1', v_uteis_conc=1, v_uteis_conc::text);

  select count(distinct q.id) into v_uteis_sig from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
    where qup.unidade_pedagogica_id='290650b5-0f55-49e1-871e-932003447e41' and q.ativa=true
    and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('OLD_FINAL','uteis_significacao_3', v_uteis_sig=3, v_uteis_sig::text);

  select count(distinct q.id) into v_uteis_rede from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
    where qup.unidade_pedagogica_id='53dc06a1-cd16-4004-a76b-8201d95a91c4' and q.ativa=true
    and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('OLD_FINAL','uteis_rede_justica_4', v_uteis_rede=4, v_uteis_rede::text);
end $$;

-- ===================== RESUMO =====================
select fase, count(*) as total, count(*) filter (where ok) as ok_count
from _relatorio group by fase order by min(ctid);

select * from _relatorio where not ok;

do $$
declare
  v_total int; v_ok int;
begin
  select count(*), count(*) filter (where ok) into v_total, v_ok from _relatorio;
  if v_total = v_ok then
    raise notice 'TESTE DE ROLLBACK: %/% checks OK — BMRS_REAPROVEITAMENTO_05_ROLLBACK_TEST_APROVADO', v_ok, v_total;
  else
    raise notice 'TESTE DE ROLLBACK: %/% checks OK — HA FALHAS, ver _relatorio', v_ok, v_total;
  end if;
end $$;

rollback;
