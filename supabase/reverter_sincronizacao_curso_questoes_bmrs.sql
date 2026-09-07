-- REVERSAO REAL, POS-APPLY, da sincronizacao curso_questoes (BMRS).
--
-- NAO EXECUTAR agora. So deve ser usado se, no futuro, for necessario
-- desfazer o apply ja confirmado (commit) de
-- supabase/corrigir_sincronizacao_curso_questoes_bmrs.sql.
--
-- Reverte as DUAS escritas daquele apply:
--   D) remove EXATAMENTE os 245 pares (curso_id, questao_id) inseridos;
--   E) restaura a definicao OLD, byte-a-byte, da RPC
--      classificar_questao_unidade_admin.
--
-- Guardas: exige que a RPC ainda esteja na definicao NEW desta esteira
-- (nao reverte se alguem ja alterou a funcao de novo por cima) e que os
-- 245 pares ainda existam com curso_id/questao_id/prioridade=1 intactos
-- (nao reverte se algo alterou essas linhas depois do apply). Se qualquer
-- guarda falhar, ABORTA integralmente — nunca sobrescreve estado
-- divergente.
--
-- Termina em COMMIT. So deve ser executado apos autorizacao humana
-- explicita.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

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

-- ================= GUARD A: RPC ainda na definicao NEW =================
do $$
declare v_hash text;
begin
  select md5(pg_get_functiondef('public.classificar_questao_unidade_admin(bigint, uuid)'::regprocedure)) into v_hash;
  if v_hash <> '67b4e3273eb87f751e7d94d05b4788f5' then
    raise exception 'ABORTADO: RPC nao esta mais na definicao NEW desta esteira (hash atual %, esperado %) — pode ja ter sido revertida ou alterada por outro processo; nao sobrescrever estado divergente', v_hash, '67b4e3273eb87f751e7d94d05b4788f5';
  end if;
  raise notice 'GUARD A OK: RPC confere com a definicao NEW';
end $$;

-- ================= GUARD B/C: os 245 pares intactos =================
do $$
declare
  v_staging int; v_presentes int; v_prioridade_ok int; v_curso_ok int;
begin
  select count(*) into v_staging from _backfill_245;
  if v_staging <> 245 then raise exception 'ABORTADO: staging com % linhas, esperado 245', v_staging; end if;

  select count(*) into v_presentes
    from _backfill_245 b
    where exists (select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=b.questao_id);
  if v_presentes <> 245 then
    raise exception 'ABORTADO: apenas % dos 245 pares ainda existem em curso_questoes — nao reverter as cegas', v_presentes;
  end if;

  select count(*) into v_prioridade_ok
    from _backfill_245 b
    join public.curso_questoes cq on cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=b.questao_id
    where cq.prioridade = 1;
  if v_prioridade_ok <> 245 then
    raise exception 'ABORTADO: % dos 245 pares nao estao mais com prioridade=1 (alteracao inesperada) — nao reverter as cegas', 245 - v_prioridade_ok;
  end if;

  raise notice 'GUARD B/C OK: 245/245 pares presentes, curso_id correto, prioridade=1 intacta';
end $$;

-- ================= D) DELETE dos 245 pares =================
do $$
declare v_rows int;
begin
  delete from public.curso_questoes cq
  using _backfill_245 b
  where cq.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id = b.questao_id;

  get diagnostics v_rows = row_count;
  if v_rows <> 245 then
    raise exception 'REVERSAO removeu % linha(s), esperado exatamente 245 — abortando', v_rows;
  end if;
  raise notice 'REVERSAO (D) OK: % linha(s) removida(s) de curso_questoes', v_rows;
end $$;

-- ================= E) restaurar RPC OLD =================
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
  if v_hash <> '19b83889d2c9402f349cfbb804776599' then
    raise exception 'REVERSAO (E): RPC restaurada nao bate com a definicao OLD esperada';
  end if;
  raise notice 'REVERSAO (E) OK: RPC restaurada byte-a-byte a definicao OLD';
end $$;

-- ================= POS-REVERSAO =================
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
  if v_vinc_distinct <> 920 then raise exception 'POS-REVERSAO: vinculadas distinct=% esperado 920', v_vinc_distinct; end if;
  if v_eleg_distinct <> 675 then raise exception 'POS-REVERSAO: elegiveis distinct=% esperado 675 (gap deve voltar a 245)', v_eleg_distinct; end if;

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
  if v_vinc <> 933 then raise exception 'POS-REVERSAO: vinculos=% esperado 933', v_vinc; end if;
  if v_eleg <> 688 then raise exception 'POS-REVERSAO: vinculos elegiveis=% esperado 688 (gap deve voltar a 245)', v_eleg; end if;

  raise notice 'POS-REVERSAO OK: gap DISTINCT voltou a 245, gap de vinculos voltou a 245, RPC na definicao OLD';
end $$;

commit;
