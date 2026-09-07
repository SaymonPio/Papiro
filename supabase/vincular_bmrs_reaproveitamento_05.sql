-- REAPROVEITAMENTO PEDAGOGICO — vinculo das 5 questoes aprovadas na
-- auditoria semantica (BMRS_REAPROVEITAMENTO_BANCO_AUDITORIA_PEDAGOGICA_APROVADA).
--
-- Usa EXCLUSIVAMENTE o writer sancionado classificar_questao_unidade_admin
-- (ja corrigido para sincronizar curso_questoes automaticamente). Nenhum
-- INSERT direto em questao_unidades_pedagogicas ou curso_questoes.
--
-- Achado do baseline: as 5 questoes JA possuiam linha em curso_questoes
-- (BMRS) antes desta esteira — nenhuma delas veio do backfill de 245 da
-- esteira anterior. Logo o delta esperado em curso_questoes e 0 (ON
-- CONFLICT DO NOTHING em todas), e o pos-check verifica que as 5 linhas
-- preexistentes permanecem com o prioridade/criado_em exatos capturados
-- no baseline — prova de que nao foram tocadas.
--
-- NAO gera questao. NAO altera questoes/alternativas/explicacoes/
-- unidades_pedagogicas/curso_conteudos/curso_materias/aulas.
--
-- ROLLBACK-TESTADO em vincular_bmrs_reaproveitamento_05_teste_rollback.sql
-- REVERSAO REAL disponivel em reverter_bmrs_reaproveitamento_05.sql

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

-- ================= PRECONDICOES =================
do $$
declare
  v_staging int; v_invalidas int; v_ja_vinculadas int; v_cq_diverge int;
  v_deficit_lp int; v_deficit_leg int; v_deficit_info int;
begin
  select count(*) into v_staging from _matriz_05;
  if v_staging <> 5 then raise exception 'PRECOND: staging com % linhas, esperado 5', v_staging; end if;

  -- questao ativa, gabarito valido (exatamente 1 correta), unidade ativa,
  -- conteudo relevante, materia relevante
  select count(*) into v_invalidas
  from _matriz_05 m
  join public.questoes q on q.id = m.questao_id
  join public.unidades_pedagogicas up on up.id = m.unidade_id
  join public.curso_conteudos cc on cc.id = up.curso_conteudo_id
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where not (
    q.ativa = true
    and (select count(*) from public.alternativas a where a.questao_id = q.id and a.correta) = 1
    and up.ativa = true
    and cc.relevante_para_preparacao = true
    and cm.relevante_para_preparacao = true
    and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
  );
  if v_invalidas <> 0 then raise exception 'PRECOND: % das 5 falharam checagem de integridade (ativa/gabarito/unidade/relevancia)', v_invalidas; end if;

  -- 0/5 vinculos TARGET ja existem
  select count(*) into v_ja_vinculadas
  from _matriz_05 m
  where exists (select 1 from public.questao_unidades_pedagogicas qup where qup.questao_id = m.questao_id and qup.unidade_pedagogica_id = m.unidade_id);
  if v_ja_vinculadas <> 0 then raise exception 'PRECOND: % dos 5 vinculos TARGET ja existem — abortando', v_ja_vinculadas; end if;

  -- curso_questoes preexistente deve bater exatamente com o congelado
  select count(*) into v_cq_diverge
  from _matriz_05 m
  where m.cq_preexistente_esperado <> exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=m.questao_id)
     or (m.cq_preexistente_esperado and not exists(
        select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=m.questao_id
        and cq.criado_em = m.cq_criado_em_esperado and cq.prioridade = m.cq_prioridade_esperado
     ));
  if v_cq_diverge <> 0 then raise exception 'PRECOND: % das 5 com curso_questoes divergente do baseline congelado (preexistencia, criado_em ou prioridade)', v_cq_diverge; end if;

  -- baseline de cobertura por materia
  select greatest(10-coalesce((select count(distinct q.id) from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
      where qup.unidade_pedagogica_id='9a4936e1-a9a6-452c-9385-d5a5899ae5c5' and q.ativa=true
      and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id)),0),0)
    into v_deficit_lp;
  if v_deficit_lp <> 9 then raise exception 'PRECOND: deficit atual de Concordancia nominal=% esperado 9', v_deficit_lp; end if;

  raise notice 'PRECONDICOES OK: 5/5 questoes integras, 0/5 vinculos TARGET preexistentes, curso_questoes bate com baseline congelado (5/5 preexistentes, criado_em/prioridade intactos)';
end $$;

-- ================= APPLY: 5 chamadas ao writer sancionado =================
do $$
declare
  r record;
  v_antes int;
  v_depois int;
begin
  select count(*) into v_antes from public.questao_unidades_pedagogicas where questao_id in (222, 224, 68, 1338, 1342);

  for r in select questao_id, unidade_id from _matriz_05 order by questao_id loop
    perform public.classificar_questao_unidade_admin(r.questao_id, r.unidade_id);
  end loop;

  select count(*) into v_depois from public.questao_unidades_pedagogicas where questao_id in (222, 224, 68, 1338, 1342);

  if v_depois - v_antes <> 5 then
    raise exception 'APPLY: % vinculo(s) novo(s) criado(s), esperado exatamente 5', v_depois - v_antes;
  end if;
  raise notice 'APPLY OK: 5 vinculos criados via classificar_questao_unidade_admin';
end $$;

-- ================= POSCONDICOES =================
do $$
declare
  v_target int; v_cq_ok int; v_cq_intactas int;
  v_uteis_conc int; v_uteis_sig int; v_uteis_rede int;
begin
  select count(*) into v_target
  from _matriz_05 m
  where exists(select 1 from public.questao_unidades_pedagogicas qup where qup.questao_id=m.questao_id and qup.unidade_pedagogica_id=m.unidade_id);
  if v_target <> 5 then raise exception 'POSCOND: %/5 vinculos TARGET presentes', v_target; end if;

  select count(*) into v_cq_ok
  from _matriz_05 m
  where exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=m.questao_id);
  if v_cq_ok <> 5 then raise exception 'POSCOND: %/5 em curso_questoes(BMRS)', v_cq_ok; end if;

  select count(*) into v_cq_intactas
  from _matriz_05 m
  join public.curso_questoes cq on cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=m.questao_id
  where cq.criado_em = m.cq_criado_em_esperado and cq.prioridade = m.cq_prioridade_esperado;
  if v_cq_intactas <> 5 then raise exception 'POSCOND: %/5 linhas de curso_questoes preexistentes NAO estao mais intactas (criado_em/prioridade alterados)', v_cq_intactas; end if;

  select count(distinct q.id) into v_uteis_conc from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
    where qup.unidade_pedagogica_id='9a4936e1-a9a6-452c-9385-d5a5899ae5c5' and q.ativa=true
    and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  if v_uteis_conc <> 3 then raise exception 'POSCOND: uteis Concordancia nominal=% esperado 3', v_uteis_conc; end if;

  select count(distinct q.id) into v_uteis_sig from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
    where qup.unidade_pedagogica_id='290650b5-0f55-49e1-871e-932003447e41' and q.ativa=true
    and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  if v_uteis_sig <> 4 then raise exception 'POSCOND: uteis Significacao das palavras=% esperado 4', v_uteis_sig; end if;

  select count(distinct q.id) into v_uteis_rede from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
    where qup.unidade_pedagogica_id='53dc06a1-cd16-4004-a76b-8201d95a91c4' and q.ativa=true
    and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  if v_uteis_rede <> 6 then raise exception 'POSCOND: uteis Rede de justica=% esperado 6', v_uteis_rede; end if;

  raise notice 'POSCONDICOES OK: 5/5 vinculos TARGET, 5/5 curso_questoes (todas as 5 preexistentes intactas, 0 novas), coberturas 3/4/6 confirmadas';
end $$;

commit;
