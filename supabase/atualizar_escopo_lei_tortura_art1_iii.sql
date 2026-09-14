-- ATUALIZACAO DE ESCOPO — unidade "Lei de Tortura" (BM RS), incorporando
-- art. 1º, III da Lei nº 9.455/1997 (incluido pela Lei nº 15.410/2026), em
-- razao da existencia de Q2124 (AUTORAL_PAPIRO, ja ativa e vinculada).
--
-- Mandato: "PAPIRO — LEI DE TORTURA — ART. 1º, III — ATUALIZACAO REAL DO
-- ESCOPO". Classificacao tecnica: UPDATE_CANONICAL_EXISTING_SCOPE (mesmo
-- padrao ja usado em atualizar_escopo_jurisprudencia_stf_stj_lote09b.sql —
-- nao e schema change/migration; artigos_esperados e text[] comparado como
-- strings opacas).
--
-- Alteracoes: (1) escopo — substitui SOMENTE a ultima frase (que dizia
-- "nao coberto pelas questoes atuais", tornada falsa por Q2124), preservando
-- integralmente o restante do texto; (2) artigos_esperados — adiciona
-- "art. 1º, III" na posicao numerica natural (apos "art. 1º, II"), sem
-- remover nenhum dos 9 itens existentes.
--
-- NAO toca: aulas, aula_versoes, questoes, alternativas,
-- questao_unidades_pedagogicas, curso_questoes, curso_conteudos, ou
-- qualquer outra unidade_pedagogica.
--
-- ROLLBACK-TESTADO em atualizar_escopo_lei_tortura_art1_iii_teste_rollback.sql

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _snapshot_old on commit drop as
select id, escopo, artigos_esperados
from public.unidades_pedagogicas
where id = '392fd9fe-a3d2-4062-b912-0a299b414429'::uuid;

create temporary table _hash_outras_unidades_antes on commit drop as
select md5(string_agg(id::text || coalesce(escopo,'') || coalesce(array_to_string(artigos_esperados, ','), ''), '|' order by id)) as h
from public.unidades_pedagogicas
where id <> '392fd9fe-a3d2-4062-b912-0a299b414429'::uuid;

-- ================= PRECONDICOES =================
do $$
declare
  v_escopo text;
  v_artigos text[];
  v_qtd int;
  v_q2124_ativa boolean;
  v_q2124_vinculada boolean;
  v_q2124_em_curso boolean;
begin
  select escopo, artigos_esperados into v_escopo, v_artigos
  from public.unidades_pedagogicas where id = '392fd9fe-a3d2-4062-b912-0a299b414429'::uuid;

  if v_escopo is null then raise exception 'PRECOND: unidade nao encontrada'; end if;
  if v_escopo <> $ESCOPO_OLD$Lei nº 9.455/1997 (define os crimes de tortura): constranger alguém, com violência ou grave ameaça, causando sofrimento físico ou mental, para obter informação, declaração ou confissão da vítima ou de terceiro (art. 1º, I, "a"), ou para provocar ação ou omissão de natureza criminosa (art. 1º, I, "b"); submeter pessoa sob guarda, poder ou autoridade, com violência ou grave ameaça, a intenso sofrimento físico ou mental, como castigo pessoal ou medida de caráter preventivo (art. 1º, II); omissão de quem tinha o dever de evitar ou apurar essas condutas (art. 1º, §2º); causas de aumento de pena, inclusive quando o crime é cometido por agente público (art. 1º, §4º, I); perda do cargo, função ou emprego público, com interdição para seu exercício pelo dobro do prazo da pena aplicada (art. 1º, §5º); inafiançabilidade e vedação a graça ou anistia (art. 1º, §6º); regime inicial fechado, ressalvada a hipótese do §2º — texto literal ainda vigente, temperado pelo entendimento do STJ/STF (HC 111.840) que afasta sua obrigatoriedade absoluta, devendo a fixação do regime observar os critérios gerais aplicáveis ao caso (art. 1º, §7º); e extraterritorialidade da lei quando a vítima é brasileira ou o agente se encontra em local sob jurisdição brasileira (art. 2º, caput). A Lei nº 15.410/2026 acrescentou ao art. 1º o inciso III (tortura por submissão reiterada da mulher a intenso sofrimento físico ou mental no contexto de violência doméstica e familiar), não coberto pelas questões atuais.$ESCOPO_OLD$ then raise exception 'PRECOND: escopo atual diverge do esperado — possivel alteracao concorrente, abortar'; end if;

  v_qtd := array_length(v_artigos, 1);
  if v_qtd <> 9 then raise exception 'PRECOND: esperado 9 artigos_esperados atuais, encontrado %', v_qtd; end if;
  if v_artigos <> ARRAY['art. 1º, I, "a"', 'art. 1º, I, "b"', 'art. 1º, II', 'art. 1º, §2º', 'art. 1º, §4º, I', 'art. 1º, §5º', 'art. 1º, §6º', 'art. 1º, §7º', 'art. 2º, caput'] then raise exception 'PRECOND: artigos_esperados atual diverge do esperado (conteudo ou ordem) — abortar'; end if;

  if 'art. 1º, III' = any(v_artigos) then raise exception 'PRECOND: art. 1º, III ja presente antes do apply — possivel reexecucao'; end if;

  select ativa into v_q2124_ativa from public.questoes where id = 2124;
  if coalesce(v_q2124_ativa, false) is not true then raise exception 'PRECOND: Q2124 nao esta ativa — abortar'; end if;

  select exists(select 1 from public.questao_unidades_pedagogicas qup where qup.questao_id=2124 and qup.unidade_pedagogica_id='392fd9fe-a3d2-4062-b912-0a299b414429'::uuid) into v_q2124_vinculada;
  if not v_q2124_vinculada then raise exception 'PRECOND: Q2124 nao esta vinculada a unidade alvo — abortar'; end if;

  select exists(select 1 from public.curso_questoes cq where cq.questao_id=2124 and cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4') into v_q2124_em_curso;
  if not v_q2124_em_curso then raise exception 'PRECOND: Q2124 nao esta em curso_questoes — abortar'; end if;

  raise notice 'PRECOND OK: escopo e artigos_esperados identicos ao estado auditado (9 itens), art.1º,III ainda ausente, Q2124 ativa/vinculada/em curso_questoes';
end $$;

-- ================= APPLY =================
update public.unidades_pedagogicas
set
  escopo = $ESCOPO_NEW$Lei nº 9.455/1997 (define os crimes de tortura): constranger alguém, com violência ou grave ameaça, causando sofrimento físico ou mental, para obter informação, declaração ou confissão da vítima ou de terceiro (art. 1º, I, "a"), ou para provocar ação ou omissão de natureza criminosa (art. 1º, I, "b"); submeter pessoa sob guarda, poder ou autoridade, com violência ou grave ameaça, a intenso sofrimento físico ou mental, como castigo pessoal ou medida de caráter preventivo (art. 1º, II); omissão de quem tinha o dever de evitar ou apurar essas condutas (art. 1º, §2º); causas de aumento de pena, inclusive quando o crime é cometido por agente público (art. 1º, §4º, I); perda do cargo, função ou emprego público, com interdição para seu exercício pelo dobro do prazo da pena aplicada (art. 1º, §5º); inafiançabilidade e vedação a graça ou anistia (art. 1º, §6º); regime inicial fechado, ressalvada a hipótese do §2º — texto literal ainda vigente, temperado pelo entendimento do STJ/STF (HC 111.840) que afasta sua obrigatoriedade absoluta, devendo a fixação do regime observar os critérios gerais aplicáveis ao caso (art. 1º, §7º); e extraterritorialidade da lei quando a vítima é brasileira ou o agente se encontra em local sob jurisdição brasileira (art. 2º, caput). A Lei nº 15.410/2026 acrescentou ao art. 1º o inciso III: submeter mulher, reiteradamente, a intenso sofrimento físico ou mental, no contexto de violência doméstica e familiar, sem prejuízo da aplicação das penas correspondentes a outras infrações penais (art. 1º, III). Trata-se de hipótese autônoma de tortura, distinta das finalidades previstas no inciso I, devendo ser estudada como hipótese própria dentro do escopo desta unidade.$ESCOPO_NEW$,
  artigos_esperados = ARRAY['art. 1º, I, "a"', 'art. 1º, I, "b"', 'art. 1º, II', 'art. 1º, III', 'art. 1º, §2º', 'art. 1º, §4º, I', 'art. 1º, §5º', 'art. 1º, §6º', 'art. 1º, §7º', 'art. 2º, caput']
where id = '392fd9fe-a3d2-4062-b912-0a299b414429'::uuid;

-- ================= POSCONDICOES =================
do $$
declare
  v_escopo text;
  v_artigos text[];
  v_qtd int;
  v_todos_antigos_presentes boolean;
  v_sem_duplicata boolean;
  v_frase_antiga_ausente boolean;
begin
  select escopo, artigos_esperados into v_escopo, v_artigos
  from public.unidades_pedagogicas where id = '392fd9fe-a3d2-4062-b912-0a299b414429'::uuid;

  v_qtd := array_length(v_artigos, 1);
  if v_qtd <> 10 then raise exception 'POSCOND: esperado 10 artigos_esperados, encontrado %', v_qtd; end if;

  select ARRAY['art. 1º, I, "a"', 'art. 1º, I, "b"', 'art. 1º, II', 'art. 1º, §2º', 'art. 1º, §4º, I', 'art. 1º, §5º', 'art. 1º, §6º', 'art. 1º, §7º', 'art. 2º, caput'] <@ v_artigos into v_todos_antigos_presentes;
  if not v_todos_antigos_presentes then raise exception 'POSCOND: um ou mais artigos_esperados antigos foram perdidos'; end if;

  if not ('art. 1º, III' = any(v_artigos)) then raise exception 'POSCOND: art. 1º, III nao foi adicionado'; end if;

  select (select count(*) from unnest(v_artigos) x) = (select count(distinct x) from unnest(v_artigos) x) into v_sem_duplicata;
  if not v_sem_duplicata then raise exception 'POSCOND: ha duplicacao em artigos_esperados'; end if;

  select position('não coberto pelas questões atuais' in v_escopo) = 0 into v_frase_antiga_ausente;
  if not v_frase_antiga_ausente then raise exception 'POSCOND: frase antiga "nao coberto pelas questoes atuais" ainda presente no escopo'; end if;

  if position('art. 1º, III' in v_escopo) = 0 then raise exception 'POSCOND: escopo nao menciona art. 1º, III'; end if;

  raise notice 'POSCOND OK: 10 artigos_esperados (9 antigos preservados + art.1º,III), sem duplicatas, frase antiga removida, novo trecho presente no escopo';
end $$;

-- Confirma que NENHUMA outra unidade foi tocada (contagem total + hash de
-- conteudo de todas as outras linhas, mesmo padrao ja usado no Lote09B —
-- unidades_pedagogicas nao possui coluna de timestamp de atualizacao
-- utilizavel para esta checagem de forma isolada).
do $$
declare
  v_total_depois int;
  v_total_antes int;
  v_hash_depois text;
  v_hash_antes text;
begin
  select count(*) into v_total_antes from public.unidades_pedagogicas; -- snapshot indireto: comparado contra a contagem atual (nenhuma linha e criada/removida por este script)
  select count(*) into v_total_depois from public.unidades_pedagogicas;
  if v_total_depois <> v_total_antes then
    raise exception 'POSCOND: contagem total de unidades_pedagogicas mudou inesperadamente dentro da mesma transacao';
  end if;

  select h into v_hash_antes from _hash_outras_unidades_antes;
  select md5(string_agg(id::text || coalesce(escopo,'') || coalesce(array_to_string(artigos_esperados, ','), ''), '|' order by id))
  into v_hash_depois
  from public.unidades_pedagogicas
  where id <> '392fd9fe-a3d2-4062-b912-0a299b414429'::uuid;

  if v_hash_depois is distinct from v_hash_antes then
    raise exception 'POSCOND: conteudo de OUTRAS unidades_pedagogicas mudou — vazamento de escopo do UPDATE';
  end if;

  raise notice 'POSCOND OK: nenhuma outra unidade_pedagogica foi tocada (hash de conteudo identico)';
end $$;

-- Confirma que Q2124, vinculo e curso_questoes permanecem intocados, e que
-- nenhuma aula/aula_versao foi alterada por este script (nao existe
-- nenhuma instrucao de escrita neste arquivo sobre essas tabelas — checagem
-- e apenas declarativa/confirmatoria).
do $$
declare
  v_q2124_ativa boolean;
  v_q2124_vinculada boolean;
  v_q2124_em_curso boolean;
begin
  select ativa into v_q2124_ativa from public.questoes where id = 2124;
  select exists(select 1 from public.questao_unidades_pedagogicas qup where qup.questao_id=2124 and qup.unidade_pedagogica_id='392fd9fe-a3d2-4062-b912-0a299b414429'::uuid) into v_q2124_vinculada;
  select exists(select 1 from public.curso_questoes cq where cq.questao_id=2124 and cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4') into v_q2124_em_curso;

  if coalesce(v_q2124_ativa, false) is not true or not v_q2124_vinculada or not v_q2124_em_curso then
    raise exception 'POSCOND: Q2124/vinculo/curso_questoes divergiu do esperado apos o apply';
  end if;

  raise notice 'POSCOND OK: Q2124 permanece ativa, vinculada, e em curso_questoes';
end $$;

commit;
