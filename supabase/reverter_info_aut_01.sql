-- REVERSAO REAL, POS-APPLY, do lote AUTORAL INFO-AUT-01 (2 questoes,
-- unidade "Internet: conceitos, arquitetura e protocolos").
--
-- NAO EXECUTAR agora. So deve ser usado se, no futuro, for necessario
-- desfazer o apply ja confirmado (commit) de supabase/importar_info_aut_01.sql.
--
-- Identifica as 2 questoes exclusivamente pelo texto EXATO do enunciado
-- (mesma chave usada nas precondicoes do apply). Remove em ordem de FK:
-- vinculo -> alternativas -> questao. curso_questoes e removida junto por
-- ON DELETE CASCADE a partir de questoes, mas o guard abaixo confirma
-- explicitamente a contagem antes e depois, sem assumir o cascade.
--
-- Guard: aborta se o criterio de enunciado exato encontrar numero
-- diferente de 2 questoes — nunca reverte as cegas.
--
-- Termina em COMMIT. So deve ser executado apos autorizacao humana
-- explicita.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _info_aut_01_enunciados (enunciado text) on commit drop;
insert into _info_aut_01_enunciados (enunciado) values
($ENUNREV$Em relação aos protocolos HTTP e HTTPS utilizados na Web, assinale a alternativa CORRETA.$ENUNREV$),
($ENUNREV$Em relação aos protocolos de transporte TCP (Transmission Control Protocol) e UDP (User Datagram Protocol), assinale a alternativa CORRETA.$ENUNREV$);

do $$
declare
  v_cnt int;
begin
  select count(*) into v_cnt from public.questoes where enunciado in (select enunciado from _info_aut_01_enunciados);
  if v_cnt <> 2 then
    raise exception 'Abortado: % questao(oes) encontrada(s) pelo criterio de enunciado exato (esperado exatamente 2) — nao reverter as cegas', v_cnt;
  end if;
end $$;

do $$
declare
  v_ids bigint[];
  v_rows_qup int; v_rows_alt int; v_rows_cq int; v_rows_q int;
begin
  select array_agg(id) into v_ids from public.questoes where enunciado in (select enunciado from _info_aut_01_enunciados);

  delete from public.questao_unidades_pedagogicas where questao_id = any(v_ids);
  get diagnostics v_rows_qup = row_count;

  delete from public.curso_questoes where questao_id = any(v_ids);
  get diagnostics v_rows_cq = row_count;

  delete from public.alternativas where questao_id = any(v_ids);
  get diagnostics v_rows_alt = row_count;

  delete from public.questoes where id = any(v_ids);
  get diagnostics v_rows_q = row_count;

  if v_rows_q <> 2 then raise exception 'REVERSAO: % questoes removidas, esperado 2', v_rows_q; end if;
  if v_rows_alt <> 10 then raise exception 'REVERSAO: % alternativas removidas, esperado 10', v_rows_alt; end if;
  if v_rows_qup <> 2 then raise exception 'REVERSAO: % vinculos removidos, esperado 2', v_rows_qup; end if;
  if v_rows_cq <> 2 then raise exception 'REVERSAO: % curso_questoes removidas, esperado 2', v_rows_cq; end if;

  raise notice 'REVERSAO OK: 2 questoes, 10 alternativas, 2 vinculos, 2 curso_questoes removidos';
end $$;

do $$
declare
  v_uteis int;
begin
  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='d9153747-6150-4a1f-8bb8-f4ea433f672f' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  if v_uteis <> 8 then raise exception 'POS-REVERSAO: uteis da unidade=% esperado 8', v_uteis; end if;
  raise notice 'POS-REVERSAO OK: unidade voltou a 8 uteis';
end $$;

commit;
