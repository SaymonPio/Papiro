-- CORRECAO ESTRUTURAL + BACKFILL — sincronizacao curso_questoes (BMRS)
--
-- DUAS escritas nesta transacao, ambas necessarias e nenhuma opcional:
--   A) CREATE OR REPLACE FUNCTION classificar_questao_unidade_admin — adiciona
--      sincronizacao automatica de curso_questoes ao vinculo pedagogico,
--      preservando 100% do comportamento anterior (mesma checagem de admin,
--      mesmo INSERT em questao_unidades_pedagogicas).
--   B) INSERT de exatamente 245 linhas em curso_questoes — as questoes que
--      ja estavam corretamente vinculadas mas invisiveis as RPCs de selecao
--      por falta dessa linha.
--
-- NAO gera questao. NAO altera questoes/alternativas/unidades_pedagogicas/
-- curso_conteudos/curso_materias/aulas. NAO altera
-- remover_classificacao_questao_unidade_admin. NAO altera linha
-- preexistente de curso_questoes (so INSERT novo, ON CONFLICT DO NOTHING).
--
-- ROLLBACK-TESTADO em corrigir_sincronizacao_curso_questoes_bmrs_teste_rollback.sql
-- REVERSAO REAL disponivel em reverter_sincronizacao_curso_questoes_bmrs.sql

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

-- ================= PRECONDICOES =================
do $$
declare
  v_conteudos int; v_unidades int; v_vinc_distinct int; v_eleg_distinct int;
  v_vinc int; v_eleg int; v_staging int; v_ja_existentes int;
  v_inativas int; v_unidade_invalida int;
begin
  select count(distinct cc.id) into v_conteudos
    from public.curso_conteudos cc
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cm.relevante_para_preparacao = true
    and cc.relevante_para_preparacao = true;
  if v_conteudos <> 92 then raise exception 'PRECOND: conteudos relevantes=% esperado 92', v_conteudos; end if;

  select count(distinct up.id) into v_unidades
    from public.unidades_pedagogicas up
    join public.curso_conteudos cc on cc.id = up.curso_conteudo_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cm.relevante_para_preparacao = true
    and cc.relevante_para_preparacao = true and up.ativa = true;
  if v_unidades <> 99 then raise exception 'PRECOND: unidades ativas relevantes=% esperado 99', v_unidades; end if;

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
  if v_vinc_distinct <> 920 then raise exception 'PRECOND: vinculadas distinct=% esperado 920', v_vinc_distinct; end if;
  if v_eleg_distinct <> 675 then raise exception 'PRECOND: elegiveis distinct=% esperado 675', v_eleg_distinct; end if;

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
  if v_vinc <> 933 then raise exception 'PRECOND: vinculos=% esperado 933', v_vinc; end if;
  if v_eleg <> 688 then raise exception 'PRECOND: vinculos elegiveis=% esperado 688', v_eleg; end if;

  select count(*) into v_staging from _backfill_245;
  if v_staging <> 245 then raise exception 'PRECOND: staging com % linhas, esperado 245', v_staging; end if;

  select count(*) into v_ja_existentes
    from _backfill_245 b where exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=b.questao_id);
  if v_ja_existentes <> 0 then raise exception 'PRECOND: % dos 245 ja possuem curso_questoes — abortando', v_ja_existentes; end if;

  select count(*) into v_inativas
    from _backfill_245 b join public.questoes q on q.id = b.questao_id where not q.ativa;
  if v_inativas <> 0 then raise exception 'PRECOND: % dos 245 correspondem a questao inativa', v_inativas; end if;

  select count(*) into v_unidade_invalida
    from _backfill_245 b
    where not exists (
      select 1 from public.questao_unidades_pedagogicas qup
      join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id and up.ativa = true
      join public.curso_conteudos cc on cc.id = up.curso_conteudo_id and cc.relevante_para_preparacao = true
      join public.curso_materias cm on cm.id = cc.curso_materia_id and cm.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cm.relevante_para_preparacao = true
      where qup.questao_id = b.questao_id
    );
  if v_unidade_invalida <> 0 then raise exception 'PRECOND: % dos 245 sem unidade ativa/relevante valida', v_unidade_invalida; end if;

  raise notice 'PRECONDICOES OK: curso/conteudos/unidades/vinculos/elegibilidade batem com o baseline congelado; 245/245 ausentes confirmados; 0 inativas; 0 sem unidade valida';
end $$;

-- ================= A) PATCH DA RPC =================
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
declare v_hash text;
begin
  select md5(pg_get_functiondef('public.classificar_questao_unidade_admin(bigint, uuid)'::regprocedure)) into v_hash;
  if v_hash <> '67b4e3273eb87f751e7d94d05b4788f5' then
    raise exception 'PATCH: hash da RPC pos-CREATE OR REPLACE nao bate com o esperado (%), obtido %', '67b4e3273eb87f751e7d94d05b4788f5', v_hash;
  end if;
  raise notice 'RPC PATCH OK: classificar_questao_unidade_admin agora sincroniza curso_questoes (hash confere)';
end $$;

-- ================= B) BACKFILL (unico INSERT, guardado) =================
do $$
declare
  v_rows int;
begin
  insert into public.curso_questoes (curso_id, questao_id)
  select '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4', b.questao_id
  from _backfill_245 b
  on conflict (curso_id, questao_id) do nothing;

  get diagnostics v_rows = row_count;
  if v_rows <> 245 then
    raise exception 'BACKFILL inseriu % linha(s), esperado exatamente 245 — abortando', v_rows;
  end if;
  raise notice 'BACKFILL OK: % linha(s) inserida(s) em curso_questoes', v_rows;
end $$;

-- ================= POSCONDICOES =================
do $$
declare
  v_vinc_distinct int; v_eleg_distinct int; v_vinc int; v_eleg int;
  v_multi int; v_multi_conteudo int; v_prioridade_alterada int; v_hash text;
begin
  with rel as (select cm.id as cmid from public.curso_materias cm where cm.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cm.relevante_para_preparacao),
  vinc as (
    select distinct q.id as questao_id, up.id as unidade_id, cc.id as curso_conteudo_id
    from public.questoes q
    join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
    join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id and up.ativa
    join public.curso_conteudos cc on cc.id=up.curso_conteudo_id and cc.relevante_para_preparacao
    join rel on rel.cmid = cc.curso_materia_id
    where q.ativa
  )
  select count(distinct questao_id), count(distinct questao_id) filter (where exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=vinc.questao_id))
    into v_vinc_distinct, v_eleg_distinct from vinc;
  if v_vinc_distinct <> 920 then raise exception 'POSCOND: vinculadas distinct=% esperado 920', v_vinc_distinct; end if;
  if v_eleg_distinct <> 920 then raise exception 'POSCOND: elegiveis distinct=% esperado 920 (gap deve ser 0)', v_eleg_distinct; end if;

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
  if v_vinc <> 933 then raise exception 'POSCOND: vinculos=% esperado 933', v_vinc; end if;
  if v_eleg <> 933 then raise exception 'POSCOND: vinculos elegiveis=% esperado 933 (gap deve ser 0)', v_eleg; end if;

  select count(*) into v_prioridade_alterada
    from public.curso_questoes cq
    where cq.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4'
      and not exists (select 1 from _backfill_245 b where b.questao_id = cq.questao_id)
      and cq.prioridade <> 1;
  -- nota: esta checagem so detecta prioridade<>1 fora do lote novo; a ausencia
  -- de UPDATE no script ja garante estruturalmente que nenhuma linha
  -- preexistente foi tocada (nenhum comando UPDATE existe neste arquivo).

  select md5(pg_get_functiondef('public.classificar_questao_unidade_admin(bigint, uuid)'::regprocedure)) into v_hash;
  if v_hash <> '67b4e3273eb87f751e7d94d05b4788f5' then
    raise exception 'POSCOND: RPC nao esta mais na definicao NEW esperada';
  end if;

  raise notice 'POSCONDICOES OK: gap DISTINCT=0, gap de vinculos=0, RPC confirmada na definicao NEW (933 vinculos = 933 elegiveis)';
end $$;

commit;
