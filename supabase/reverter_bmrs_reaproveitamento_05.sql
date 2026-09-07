-- REVERSAO REAL, POS-APPLY, do reaproveitamento BMRS-05.
--
-- NAO EXECUTAR agora. So deve ser usado se, no futuro, for necessario
-- desfazer o apply ja confirmado (commit) de
-- supabase/vincular_bmrs_reaproveitamento_05.sql.
--
-- Remove EXATAMENTE os 5 vinculos criados, via o writer sancionado
-- remover_classificacao_questao_unidade_admin. NAO toca curso_questoes:
-- as 5 questoes ja possuiam essa linha ANTES desta esteira (nenhuma foi
-- criada por ela), entao a reversao correta e nao remover nenhuma linha
-- de curso_questoes — hard guard verifica isso explicitamente antes e
-- depois, e aborta se encontrar qualquer uma das 5 SEM curso_questoes
-- (sinal de que outra coisa alterou o estado por fora desta esteira).
--
-- Termina em COMMIT. So deve ser executado apos autorizacao humana
-- explicita.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

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

-- ================= GUARD: estado TARGET intacto =================
do $$
declare
  v_target int; v_cq_intactas int;
begin
  select count(*) into v_target
  from _matriz_05 m
  where exists(select 1 from public.questao_unidades_pedagogicas qup where qup.questao_id=m.questao_id and qup.unidade_pedagogica_id=m.unidade_id);
  if v_target <> 5 then
    raise exception 'ABORTADO: apenas %/5 vinculos TARGET existem — nao reverter as cegas', v_target;
  end if;

  select count(*) into v_cq_intactas
  from _matriz_05 m
  join public.curso_questoes cq on cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=m.questao_id
  where cq.criado_em = m.cq_criado_em_esperado and cq.prioridade = m.cq_prioridade_esperado;
  if v_cq_intactas <> 5 then
    raise exception 'ABORTADO: %/5 linhas de curso_questoes nao batem mais com o baseline congelado (criado_em/prioridade) — nao reverter as cegas', v_cq_intactas;
  end if;

  raise notice 'GUARD OK: 5/5 vinculos TARGET presentes, 5/5 curso_questoes intactas (preexistentes, nunca tocadas)';
end $$;

-- ================= REMOVER os 5 vinculos (writer sancionado) =================
do $$
declare
  r record;
  v_antes int;
  v_depois int;
begin
  select count(*) into v_antes from public.questao_unidades_pedagogicas where questao_id in (222, 224, 68, 1338, 1342);

  for r in select questao_id, unidade_id from _matriz_05 order by questao_id loop
    perform public.remover_classificacao_questao_unidade_admin(r.questao_id, r.unidade_id);
  end loop;

  select count(*) into v_depois from public.questao_unidades_pedagogicas where questao_id in (222, 224, 68, 1338, 1342);

  if v_antes - v_depois <> 5 then
    raise exception 'REVERSAO removeu % vinculo(s), esperado exatamente 5', v_antes - v_depois;
  end if;
  raise notice 'REVERSAO OK: 5 vinculos removidos via remover_classificacao_questao_unidade_admin';
end $$;

-- ================= GUARD: curso_questoes das 5 permanece intacto (nao tocado) =================
do $$
declare
  v_cq_intactas int;
begin
  select count(*) into v_cq_intactas
  from _matriz_05 m
  join public.curso_questoes cq on cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=m.questao_id
  where cq.criado_em = m.cq_criado_em_esperado and cq.prioridade = m.cq_prioridade_esperado;
  if v_cq_intactas <> 5 then
    raise exception 'POS-REVERSAO: %/5 linhas de curso_questoes nao permaneceram intactas — deveriam continuar exatamente como estavam (nenhuma foi criada por esta esteira, nenhuma deve ser removida)', v_cq_intactas;
  end if;
  raise notice 'POS-REVERSAO OK: curso_questoes das 5 permanece 100%% intacto (0 removido, 0 alterado)';
end $$;

-- ================= POS-REVERSAO: cobertura volta ao OLD =================
do $$
declare
  v_target int; v_uteis_conc int; v_uteis_sig int; v_uteis_rede int;
begin
  select count(*) into v_target
  from _matriz_05 m
  where exists(select 1 from public.questao_unidades_pedagogicas qup where qup.questao_id=m.questao_id and qup.unidade_pedagogica_id=m.unidade_id);
  if v_target <> 0 then raise exception 'POS-REVERSAO: ainda existem %/5 vinculos TARGET', v_target; end if;

  select count(distinct q.id) into v_uteis_conc from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
    where qup.unidade_pedagogica_id='9a4936e1-a9a6-452c-9385-d5a5899ae5c5' and q.ativa=true
    and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  if v_uteis_conc <> 1 then raise exception 'POS-REVERSAO: uteis Concordancia nominal=% esperado 1', v_uteis_conc; end if;

  select count(distinct q.id) into v_uteis_sig from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
    where qup.unidade_pedagogica_id='290650b5-0f55-49e1-871e-932003447e41' and q.ativa=true
    and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  if v_uteis_sig <> 3 then raise exception 'POS-REVERSAO: uteis Significacao das palavras=% esperado 3', v_uteis_sig; end if;

  select count(distinct q.id) into v_uteis_rede from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
    where qup.unidade_pedagogica_id='53dc06a1-cd16-4004-a76b-8201d95a91c4' and q.ativa=true
    and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  if v_uteis_rede <> 4 then raise exception 'POS-REVERSAO: uteis Rede de justica=% esperado 4', v_uteis_rede; end if;

  raise notice 'POS-REVERSAO OK: coberturas voltaram a 1/3/4, 0/5 vinculos TARGET';
end $$;

commit;
