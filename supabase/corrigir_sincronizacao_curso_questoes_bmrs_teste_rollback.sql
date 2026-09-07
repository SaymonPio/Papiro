-- TESTE DE ROLLBACK REAL da sincronizacao curso_questoes (BMRS).
-- Executa, dentro de UMA transacao controlada que termina em ROLLBACK
-- externo, a sequencia completa:
--   OLD (baseline) -> APPLY (mesma logica do apply real, patch+backfill)
--   -> TARGET (verifica) -> TESTE FUNCIONAL da RPC nova (prova idempotencia
--   e recriacao de curso_questoes apos remocao pontual) -> REVERSAO REAL
--   (mesma logica do reverter real) -> OLD (verifica)
-- Nao e um "BEGIN/UPDATE/ROLLBACK" simplificado: reproduz literalmente a
-- logica de apply e de reversao real, com os mesmos guards. Nenhuma linha
-- e alterada permanentemente — tudo e desfeito por ROLLBACK ao final.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _relatorio (fase text, item text, ok boolean, detalhe text) on commit drop;

create temporary table _backfill_245 (questao_id bigint primary key) on commit drop;
insert into _backfill_245 (questao_id) values
(11),
(34),
(1936),
(1937),
(1938),
(1939),
(1940),
(1941),
(1942),
(1943),
(1973),
(1974),
(1975),
(1976),
(1977),
(1978),
(1979),
(1980),
(1981),
(1982),
(1983),
(1984),
(1985),
(1986),
(1987),
(1988),
(1989),
(1990),
(1991),
(1992),
(1993),
(1994),
(1995),
(1996),
(1997),
(1998),
(1999),
(2000),
(2001),
(2031),
(2032),
(2033),
(2034),
(2035),
(2036),
(2037),
(2038),
(2039),
(2040),
(2041),
(2042),
(2043),
(2044),
(2045),
(2046),
(2047),
(2048),
(2049),
(2050),
(2051),
(2052),
(2053),
(2054),
(2055),
(2056),
(2057),
(2058),
(2059),
(2064),
(2065),
(2067),
(2069),
(2073),
(2074),
(2075),
(2078),
(2079),
(2083),
(2115),
(2116),
(2117),
(2118),
(2119),
(2120),
(2121),
(2122),
(2123),
(2124),
(2125),
(2126),
(2127),
(2128),
(2129),
(2130),
(2131),
(2132),
(2133),
(2134),
(2135),
(2136),
(2137),
(2138),
(2139),
(2140),
(2141),
(2142),
(2143),
(2144),
(2145),
(2179),
(2180),
(2181),
(2182),
(2183),
(2184),
(2185),
(2186),
(2187),
(2188),
(2189),
(2190),
(2191),
(2192),
(2193),
(2194),
(2195),
(2196),
(2197),
(2198),
(2199),
(2200),
(2201),
(2202),
(2203),
(2204),
(2205),
(2206),
(2207),
(2208),
(2209),
(2210),
(2211),
(2234),
(2235),
(2236),
(2237),
(2238),
(2239),
(2240),
(2241),
(2242),
(2243),
(2244),
(2245),
(2246),
(2247),
(2248),
(2249),
(2250),
(2251),
(2252),
(2253),
(2254),
(2255),
(2274),
(2275),
(2276),
(2277),
(2278),
(2279),
(2280),
(2281),
(2282),
(2283),
(2284),
(2285),
(2286),
(2287),
(2288),
(2289),
(2290),
(2291),
(2313),
(2314),
(2315),
(2316),
(2317),
(2318),
(2319),
(2320),
(2321),
(2322),
(2323),
(2324),
(2325),
(2326),
(2327),
(2328),
(2329),
(2330),
(2331),
(2332),
(2333),
(2356),
(2357),
(2358),
(2359),
(2360),
(2361),
(2362),
(2363),
(2364),
(2365),
(2366),
(2367),
(2368),
(2369),
(2370),
(2371),
(2372),
(2373),
(2374),
(2375),
(2376),
(2377),
(2398),
(2399),
(2400),
(2401),
(2402),
(2403),
(2404),
(2405),
(2406),
(2407),
(2408),
(2409),
(2410),
(2411),
(2412),
(2413),
(2414),
(2415),
(2416),
(2417);

-- ===================== FASE OLD =====================
do $$
declare
  v_vinc_distinct int; v_eleg_distinct int; v_vinc int; v_eleg int; v_hash text;
begin
  with rel as (select cm.id as cmid from public.curso_materias cm where cm.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cm.relevante_para_preparacao),
  vinc as (
    select distinct q.id as questao_id
    from public.questoes q
    join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
    join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id and up.ativa
    join public.curso_conteudos cc on cc.id=up.curso_conteudo_id and cc.relevante_para_preparacao
    join rel on rel.cmid = cc.curso_materia_id
    where q.ativa
  )
  select count(*), count(*) filter (where exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=vinc.questao_id))
    into v_vinc_distinct, v_eleg_distinct from vinc;
  insert into _relatorio values ('OLD','vinculadas_distinct_920', v_vinc_distinct=920, v_vinc_distinct::text);
  insert into _relatorio values ('OLD','elegiveis_distinct_675', v_eleg_distinct=675, v_eleg_distinct::text);

  with rel as (select cm.id as cmid from public.curso_materias cm where cm.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cm.relevante_para_preparacao),
  vinctot as (
    select q.id as questao_id
    from public.questoes q
    join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
    join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id and up.ativa
    join public.curso_conteudos cc on cc.id=up.curso_conteudo_id and cc.relevante_para_preparacao
    join rel on rel.cmid = cc.curso_materia_id
    where q.ativa
  )
  select count(*), count(*) filter (where exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=vinctot.questao_id))
    into v_vinc, v_eleg from vinctot;
  insert into _relatorio values ('OLD','vinculos_933', v_vinc=933, v_vinc::text);
  insert into _relatorio values ('OLD','vinculos_elegiveis_688', v_eleg=688, v_eleg::text);

  select md5(pg_get_functiondef('public.classificar_questao_unidade_admin(bigint, uuid)'::regprocedure)) into v_hash;
  insert into _relatorio values ('OLD','rpc_hash_old', v_hash = '19b83889d2c9402f349cfbb804776599', v_hash);
end $$;

-- ===================== APPLY (mesma logica do script real) =====================
CREATE OR REPLACE FUNCTION public.classificar_questao_unidade_admin(p_questao_id bigint, p_unidade_pedagogica_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_curso_id uuid;
  v_questao_ativa boolean;
begin
  if not public.eh_admin() then
    raise exception 'Apenas administradores podem classificar questoes por unidade pedagogica';
  end if;

  insert into public.questao_unidades_pedagogicas (questao_id, unidade_pedagogica_id, classificado_por)
  values (p_questao_id, p_unidade_pedagogica_id, auth.uid())
  on conflict (questao_id, unidade_pedagogica_id) do nothing;

  -- Sincronizacao de curso_questoes: as RPCs de selecao (prova/missao)
  -- exigem presenca nessa tabela alem do vinculo pedagogico. Resolve o
  -- curso da unidade classificada e garante a linha, apenas quando questao,
  -- unidade, conteudo e materia estao todos ativos/relevantes. ON CONFLICT
  -- DO NOTHING: nunca sobrescreve prioridade nem qualquer outro campo de
  -- linha ja existente (nem a de outro curso, nem a deste).
  select cm.curso_id
  into v_curso_id
  from public.unidades_pedagogicas up
  join public.curso_conteudos cc on cc.id = up.curso_conteudo_id
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where up.id = p_unidade_pedagogica_id
    and up.ativa = true
    and cc.relevante_para_preparacao = true
    and cm.relevante_para_preparacao = true;

  if v_curso_id is not null then
    select q.ativa into v_questao_ativa from public.questoes q where q.id = p_questao_id;

    if coalesce(v_questao_ativa, false) then
      insert into public.curso_questoes (curso_id, questao_id)
      values (v_curso_id, p_questao_id)
      on conflict (curso_id, questao_id) do nothing;
    end if;
  end if;
end;
$function$
;
do $$
declare v_rows int;
begin
  insert into public.curso_questoes (curso_id, questao_id)
  select '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4', b.questao_id from _backfill_245 b
  on conflict (curso_id, questao_id) do nothing;
  get diagnostics v_rows = row_count;
  insert into _relatorio values ('APPLY','backfill_rows_245', v_rows=245, v_rows::text);
end $$;

-- ===================== FASE TARGET =====================
do $$
declare
  v_vinc_distinct int; v_eleg_distinct int; v_vinc int; v_eleg int; v_hash text;
begin
  with rel as (select cm.id as cmid from public.curso_materias cm where cm.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cm.relevante_para_preparacao),
  vinc as (
    select distinct q.id as questao_id
    from public.questoes q
    join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
    join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id and up.ativa
    join public.curso_conteudos cc on cc.id=up.curso_conteudo_id and cc.relevante_para_preparacao
    join rel on rel.cmid = cc.curso_materia_id
    where q.ativa
  )
  select count(*), count(*) filter (where exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=vinc.questao_id))
    into v_vinc_distinct, v_eleg_distinct from vinc;
  insert into _relatorio values ('TARGET','vinculadas_distinct_920', v_vinc_distinct=920, v_vinc_distinct::text);
  insert into _relatorio values ('TARGET','elegiveis_distinct_920', v_eleg_distinct=920, v_eleg_distinct::text);

  with rel as (select cm.id as cmid from public.curso_materias cm where cm.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cm.relevante_para_preparacao),
  vinctot as (
    select q.id as questao_id
    from public.questoes q
    join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
    join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id and up.ativa
    join public.curso_conteudos cc on cc.id=up.curso_conteudo_id and cc.relevante_para_preparacao
    join rel on rel.cmid = cc.curso_materia_id
    where q.ativa
  )
  select count(*), count(*) filter (where exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=vinctot.questao_id))
    into v_vinc, v_eleg from vinctot;
  insert into _relatorio values ('TARGET','vinculos_933', v_vinc=933, v_vinc::text);
  insert into _relatorio values ('TARGET','vinculos_elegiveis_933', v_eleg=933, v_eleg::text);

  select md5(pg_get_functiondef('public.classificar_questao_unidade_admin(bigint, uuid)'::regprocedure)) into v_hash;
  insert into _relatorio values ('TARGET','rpc_hash_new', v_hash = '67b4e3273eb87f751e7d94d05b4788f5', v_hash);
end $$;

-- ===================== TESTE FUNCIONAL DA RPC NOVA =====================
do $$
declare
  v_questao_id bigint;
  v_unidade_id uuid;
  v_vinculo_antes boolean;
  v_n1 int; v_n2 int; v_prio int;
begin
  -- Escolhe 1 questao do lote congelado + sua unidade valida (resolvida
  -- pela mesma logica de elegibilidade, nao hardcoded).
  select b.questao_id, up.id
  into v_questao_id, v_unidade_id
  from _backfill_245 b
  join public.questao_unidades_pedagogicas qup on qup.questao_id = b.questao_id
  join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id and up.ativa = true
  join public.curso_conteudos cc on cc.id = up.curso_conteudo_id and cc.relevante_para_preparacao = true
  join public.curso_materias cm on cm.id = cc.curso_materia_id and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cm.relevante_para_preparacao = true
  order by b.questao_id
  limit 1;

  insert into _relatorio values ('TESTE_RPC','1_questao_e_unidade_escolhidas', v_questao_id is not null and v_unidade_id is not null, v_questao_id::text || '/' || v_unidade_id::text);

  -- 1) remove SOMENTE a linha curso_questoes dessa questao, dentro da transacao
  delete from public.curso_questoes where curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and questao_id = v_questao_id;
  insert into _relatorio values ('TESTE_RPC','2_curso_questoes_removida_pontualmente', not exists(select 1 from public.curso_questoes where curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and questao_id=v_questao_id), 'removida');

  -- 2) confirma que o vinculo questao-unidade CONTINUA existindo
  select exists(select 1 from public.questao_unidades_pedagogicas where questao_id=v_questao_id and unidade_pedagogica_id=v_unidade_id) into v_vinculo_antes;
  insert into _relatorio values ('TESTE_RPC','3_vinculo_pedagogico_preservado', v_vinculo_antes, v_vinculo_antes::text);

  -- 3) chama a RPC para o MESMO vinculo ja existente
  perform public.classificar_questao_unidade_admin(v_questao_id, v_unidade_id);

  -- 4/5) confirma que curso_questoes foi recriada, exatamente 1 linha
  select count(*) into v_n1 from public.curso_questoes where curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and questao_id=v_questao_id;
  insert into _relatorio values ('TESTE_RPC','4_curso_questoes_recriada_pela_rpc', v_n1 = 1, v_n1::text);

  -- 6) confirma prioridade=1
  select prioridade into v_prio from public.curso_questoes where curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and questao_id=v_questao_id;
  insert into _relatorio values ('TESTE_RPC','5_prioridade_default_1', v_prio = 1, v_prio::text);

  -- 7) chama a RPC de novo
  perform public.classificar_questao_unidade_admin(v_questao_id, v_unidade_id);

  -- 8) confirma que continua exatamente 1 linha (sem duplicar)
  select count(*) into v_n2 from public.curso_questoes where curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and questao_id=v_questao_id;
  insert into _relatorio values ('TESTE_RPC','6_idempotente_sem_duplicar', v_n2 = 1, v_n2::text);
end $$;

-- ===================== REVERSAO REAL (mesma logica do reverter real) =====================
do $$
declare
  v_hash text; v_presentes int; v_prioridade_ok int; v_rows int;
begin
  select md5(pg_get_functiondef('public.classificar_questao_unidade_admin(bigint, uuid)'::regprocedure)) into v_hash;
  insert into _relatorio values ('REVERSAO_GUARD','rpc_ainda_new', v_hash = '67b4e3273eb87f751e7d94d05b4788f5', v_hash);

  select count(*) into v_presentes from _backfill_245 b where exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=b.questao_id);
  insert into _relatorio values ('REVERSAO_GUARD','245_pares_presentes', v_presentes = 245, v_presentes::text);

  select count(*) into v_prioridade_ok from _backfill_245 b join public.curso_questoes cq on cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=b.questao_id where cq.prioridade=1;
  insert into _relatorio values ('REVERSAO_GUARD','245_prioridade_1', v_prioridade_ok = 245, v_prioridade_ok::text);

  delete from public.curso_questoes cq using _backfill_245 b where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=b.questao_id;
  get diagnostics v_rows = row_count;
  insert into _relatorio values ('REVERSAO','delete_245', v_rows = 245, v_rows::text);
end $$;

CREATE OR REPLACE FUNCTION public.classificar_questao_unidade_admin(p_questao_id bigint, p_unidade_pedagogica_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  if not public.eh_admin() then
    raise exception 'Apenas administradores podem classificar questoes por unidade pedagogica';
  end if;

  insert into public.questao_unidades_pedagogicas (questao_id, unidade_pedagogica_id, classificado_por)
  values (p_questao_id, p_unidade_pedagogica_id, auth.uid())
  on conflict (questao_id, unidade_pedagogica_id) do nothing;
end;
$function$
;
do $$
declare v_hash text;
begin
  select md5(pg_get_functiondef('public.classificar_questao_unidade_admin(bigint, uuid)'::regprocedure)) into v_hash;
  insert into _relatorio values ('REVERSAO','rpc_restaurada_old', v_hash = '19b83889d2c9402f349cfbb804776599', v_hash);
end $$;

-- ===================== FASE OLD (novamente, pos-reversao) =====================
do $$
declare
  v_vinc_distinct int; v_eleg_distinct int; v_vinc int; v_eleg int;
begin
  with rel as (select cm.id as cmid from public.curso_materias cm where cm.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cm.relevante_para_preparacao),
  vinc as (
    select distinct q.id as questao_id
    from public.questoes q
    join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
    join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id and up.ativa
    join public.curso_conteudos cc on cc.id=up.curso_conteudo_id and cc.relevante_para_preparacao
    join rel on rel.cmid = cc.curso_materia_id
    where q.ativa
  )
  select count(*), count(*) filter (where exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=vinc.questao_id))
    into v_vinc_distinct, v_eleg_distinct from vinc;
  insert into _relatorio values ('OLD_FINAL','vinculadas_distinct_920', v_vinc_distinct=920, v_vinc_distinct::text);
  insert into _relatorio values ('OLD_FINAL','elegiveis_distinct_675', v_eleg_distinct=675, v_eleg_distinct::text);

  with rel as (select cm.id as cmid from public.curso_materias cm where cm.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cm.relevante_para_preparacao),
  vinctot as (
    select q.id as questao_id
    from public.questoes q
    join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
    join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id and up.ativa
    join public.curso_conteudos cc on cc.id=up.curso_conteudo_id and cc.relevante_para_preparacao
    join rel on rel.cmid = cc.curso_materia_id
    where q.ativa
  )
  select count(*), count(*) filter (where exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=vinctot.questao_id))
    into v_vinc, v_eleg from vinctot;
  insert into _relatorio values ('OLD_FINAL','vinculos_933', v_vinc=933, v_vinc::text);
  insert into _relatorio values ('OLD_FINAL','vinculos_elegiveis_688', v_eleg=688, v_eleg::text);
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
    raise notice 'TESTE DE ROLLBACK: %/% checks OK — BMRS_CURSO_QUESTOES_ROLLBACK_TEST_APROVADO', v_ok, v_total;
  else
    raise notice 'TESTE DE ROLLBACK: %/% checks OK — HA FALHAS, ver _relatorio', v_ok, v_total;
  end if;
end $$;

rollback;
