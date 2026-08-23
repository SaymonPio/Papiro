-- Aplicação REAL do mapa aprovado em
-- config/implicitos_e_subentendidos.mapa.json,
-- validado pelo harness
-- classificar_questoes_unidades_implicitos_e_subentendidos_teste_rollback.sql
-- (tudo_ok = true confirmado antes de rodar este arquivo).
--
-- Vigésimo conteúdo de Língua Portuguesa da fila (ordem 73).
-- artigos_esperados desta unidade é NULL (metodologia não jurídica). 0
-- exclusões intencionais — as 4 questões ativas foram classificadas.
-- REAL × AUTORAL: Q878 é REAL (Fundatec, SUSEPE/RS nº 01/2022) — única
-- incidência histórica real deste conteúdo; Q234/Q235/Q236 são
-- AUTORAL_PAPIRO (cobertura suplementar).
--
-- AJUSTE LOCALIZADO (nao propagado ao gerador generico
-- gerar-rollback.mjs): ao contrario de todo conteudo anterior desta
-- fila, este conteudo NAO parte de zero classificacoes. A questao 878
-- ja foi saneada taxonomicamente e vinculada a esta mesma unidade em
-- operacao separada e ja commitada (assunto_id 47->46, RPC
-- classificar_questao_unidade_admin, commit 5856a10) ANTES desta
-- curadoria. Por isso, as precondicoes abaixo esperam explicitamente 1
-- classificacao previa (a propria Q878 ja saneada, nao uma falha) e a
-- poscondicao de crescimento de vinculos exige exatamente 3 (Q234,
-- Q235, Q236 — novos vinculos desta operacao), nao 4. O loop de
-- aplicacao via RPC abaixo cobre os 4 QIDs do mapa aprovado (inclusive
-- Q878): a RPC e ON CONFLICT DO NOTHING, entao reprocessar Q878 e um
-- no-op seguro, sem duplicar vinculo — validado explicitamente nas
-- pos-condicoes que o resultado final e exatamente 1 vinculo por QID.
--
-- Diferenca deste arquivo para o harness: termina em COMMIT, e cada
-- precondicao/pos-condicao usa RAISE EXCEPTION (nao apenas relatorio
-- booleano) — qualquer divergencia aborta a transacao inteira antes de
-- confirmar. Usa a mesma RPC administrativa oficial
-- classificar_questao_unidade_admin (nenhum INSERT direto em
-- questao_unidades_pedagogicas, nenhum DELETE, nenhuma alteracao em
-- questoes/alternativas/unidades_pedagogicas/aulas/historico).
--
-- PRE-REQUISITO: supabase/curadoria_unidades_implicitos_e_subentendidos.sql
-- ja foi aplicado (reaproveita unidade placeholder ja existente
-- 1a2158e8-f690-43ab-8ca5-051ba1c0fa3e — nao cria unidade nova).

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _snapshot_antes on commit drop as
select
  (select count(*) from public.questoes)                     as total_questoes,
  (select count(*) from public.alternativas)                 as total_alternativas,
  (select count(*) from public.unidades_pedagogicas)          as total_unidades,
  (select count(*) from public.curso_conteudos)               as total_conteudos,
  (select count(*) from public.curso_questoes)                as total_curso_questoes,
  (select count(*) from public.respostas_usuarios)            as total_respostas,
  (select count(*) from public.sessoes_estudo)                as total_sessoes,
  (select count(*) from public.questao_unidades_pedagogicas)  as total_vinculos;

create temporary table _mapa (
  questao_id bigint,
  unidade_pedagogica_id uuid,
  ordem_unidade int,
  confianca text
) on commit drop;

insert into _mapa (questao_id, unidade_pedagogica_id, ordem_unidade, confianca) values
  (234, '1a2158e8-f690-43ab-8ca5-051ba1c0fa3e'::uuid, 1, 'alta'),
  (235, '1a2158e8-f690-43ab-8ca5-051ba1c0fa3e'::uuid, 1, 'alta'),
  (236, '1a2158e8-f690-43ab-8ca5-051ba1c0fa3e'::uuid, 1, 'alta'),
  (878, '1a2158e8-f690-43ab-8ca5-051ba1c0fa3e'::uuid, 1, 'alta');

-- Lock deterministico das linhas envolvidas antes de revalidar.
select id from public.unidades_pedagogicas
where curso_conteudo_id = 25
order by id
for update;

select id from public.questoes
where id in (select distinct questao_id from _mapa)
order by id
for update;

-- Revalidacao de precondicoes — aborta a transacao em qualquer divergencia.
do $$
declare
  v_materia_id bigint;
  v_assunto_id bigint;
  v_total_candidatas int;
  v_classificacoes_previas int;
  v_q878_ja_saneada boolean;
begin
  select cm.materia_id, cc.assunto_id into v_materia_id, v_assunto_id
  from public.curso_conteudos cc
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where cc.id = 25;

  if v_materia_id is null then
    raise exception 'Precondicao falhou: curso_conteudos 25 nao existe';
  end if;
  if v_materia_id is distinct from 6 or v_assunto_id is distinct from 46 then
    raise exception 'Precondicao falhou: conteudo 25 materia_id=% assunto_id=% (esperado 6/46)', v_materia_id, v_assunto_id;
  end if;

  if not exists (select 1 from public.unidades_pedagogicas where id = '1a2158e8-f690-43ab-8ca5-051ba1c0fa3e' and curso_conteudo_id = 25 and ordem = 1 and ativa)
  then
    raise exception 'Precondicao falhou: a unidade oficial nao confere (id/ordem/conteudo/ativa) — curadoria_unidades_implicitos_e_subentendidos.sql precisa ter sido aplicado antes';
  end if;

  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 25) <> 1 then
    raise exception 'Precondicao falhou: nao ha exatamente 1 unidade pedagogica para o conteudo 25 — decisao aprovada foi manter unidade unica';
  end if;

  select count(*) into v_total_candidatas
  from public.questoes q
  join public.curso_conteudos cc on cc.id = 25
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where q.ativa = true
    and q.materia_id = cm.materia_id
    and (cc.assunto_id is null or q.assunto_id = cc.assunto_id);

  if v_total_candidatas <> 4 then
    raise exception 'Precondicao falhou: total de candidatas ativas = % (esperado 4)', v_total_candidatas;
  end if;

  select count(*) into v_classificacoes_previas
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 25
    and qup.questao_id in (select questao_id from _mapa);

  -- AJUSTE (ver nota no cabecalho): esperado exatamente 1 classificacao
  -- previa, e especificamente a da Q878 ja saneada (commit 5856a10),
  -- apontando para a unidade correta — nao 0 como nos conteudos
  -- anteriores desta fila, todos classificados a partir do zero.
  select exists (
    select 1 from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where u.curso_conteudo_id = 25
      and qup.questao_id = 878
      and u.id = '1a2158e8-f690-43ab-8ca5-051ba1c0fa3e'
  ) into v_q878_ja_saneada;

  if v_classificacoes_previas <> 1 or not v_q878_ja_saneada then
    raise exception 'Precondicao falhou: classificacoes_previas=% (esperado exatamente 1: Q878, ja saneada e vinculada no commit 5856a10)', v_classificacoes_previas;
  end if;
end $$;

-- Validacao do mapa em si — aborta a transacao em qualquer divergencia.
do $$
declare
  v_invalidas int;
  v_fora_do_candidato int;
  v_unidade_fora int;
  v_distintas int;
begin
  select count(*) into v_invalidas
  from _mapa m
  join public.questoes q on q.id = m.questao_id
  where not (q.ativa = true and q.materia_id = 6 and q.assunto_id = 46);

  if v_invalidas <> 0 then
    raise exception 'Mapa invalido: % linha(s) apontam para questao que nao esta ativa=true/materia_id=6/assunto_id=46', v_invalidas;
  end if;

  select count(*) into v_distintas from (select distinct questao_id from _mapa) x;
  if v_distintas <> 4 then
    raise exception 'Mapa invalido: cobre % questoes distintas (esperado 4)', v_distintas;
  end if;

  select count(*) into v_fora_do_candidato
  from _mapa m
  where not exists (
    select 1
    from public.questoes q
    join public.curso_conteudos cc on cc.id = 25
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where q.id = m.questao_id
      and q.ativa = true
      and q.materia_id = cm.materia_id
      and (cc.assunto_id is null or q.assunto_id = cc.assunto_id)
  );
  if v_fora_do_candidato <> 0 then
    raise exception 'Mapa invalido: % linha(s) fora do conjunto candidato de 4 ativas', v_fora_do_candidato;
  end if;

  select count(*) into v_unidade_fora
  from _mapa m
  where m.unidade_pedagogica_id not in (select id from public.unidades_pedagogicas where curso_conteudo_id = 25);
  if v_unidade_fora <> 0 then
    raise exception 'Mapa invalido: % linha(s) referenciam unidade pedagogica fora do conteudo 25', v_unidade_fora;
  end if;
end $$;

-- Aplicacao via RPC oficial. A RPC e ON CONFLICT DO NOTHING: para Q878
-- (ja vinculada em 5856a10) isto e um no-op seguro, nao gera erro nem
-- vinculo duplicado.
do $$
declare r record;
begin
  for r in select questao_id, unidade_pedagogica_id from _mapa order by questao_id, unidade_pedagogica_id loop
    perform public.classificar_questao_unidade_admin(r.questao_id, r.unidade_pedagogica_id);
  end loop;
end $$;

-- Pos-condicoes ENDURECIDAS: RAISE EXCEPTION em qualquer divergencia —
-- so chega ao COMMIT final se passar tudo.
do $$
declare
  v_total_vinculos int;
  v_questoes_classificadas int;
  v_fora_do_mapa int;
  v_faltando int;
  v_multiunidade bigint[];
  v_qtd_tmp int;
  v_artigos_esperados text[];
  v_vinc_234 int;
  v_vinc_235 int;
  v_vinc_236 int;
  v_vinc_878 int;
begin
  select count(*) into v_total_vinculos
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 25;
  if v_total_vinculos <> 4 then
    raise exception 'Pos-condicao falhou: total_vinculos=% (esperado 4)', v_total_vinculos;
  end if;

  select count(distinct qup.questao_id) into v_questoes_classificadas
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 25;
  if v_questoes_classificadas <> 4 then
    raise exception 'Pos-condicao falhou: questoes_classificadas=% (esperado 4)', v_questoes_classificadas;
  end if;

  -- Pos-condicao extra explicita (exigida pela curadoria): exatamente 1
  -- vinculo por QID — sem duplicacao de Q878, sem falha de insercao para
  -- Q234/Q235/Q236.
  select count(*) into v_vinc_234 from public.questao_unidades_pedagogicas where questao_id = 234;
  select count(*) into v_vinc_235 from public.questao_unidades_pedagogicas where questao_id = 235;
  select count(*) into v_vinc_236 from public.questao_unidades_pedagogicas where questao_id = 236;
  select count(*) into v_vinc_878 from public.questao_unidades_pedagogicas where questao_id = 878;
  if v_vinc_234 <> 1 or v_vinc_235 <> 1 or v_vinc_236 <> 1 or v_vinc_878 <> 1 then
    raise exception 'Pos-condicao falhou: vinculos por QID = 234:% 235:% 236:% 878:% (esperado exatamente 1 cada)', v_vinc_234, v_vinc_235, v_vinc_236, v_vinc_878;
  end if;

  select count(*) into v_fora_do_mapa
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 25
    and not exists (
      select 1 from _mapa m
      where m.questao_id = qup.questao_id and m.unidade_pedagogica_id = qup.unidade_pedagogica_id
    );
  if v_fora_do_mapa <> 0 then
    raise exception 'Pos-condicao falhou: % vinculo(s) fora do mapa aprovado', v_fora_do_mapa;
  end if;

  select count(*) into v_faltando
  from _mapa m
  where not exists (
    select 1 from public.questao_unidades_pedagogicas qup
    where qup.questao_id = m.questao_id and qup.unidade_pedagogica_id = m.unidade_pedagogica_id
  );
  if v_faltando <> 0 then
    raise exception 'Pos-condicao falhou: % linha(s) do mapa nao foram aplicadas', v_faltando;
  end if;

  select array_agg(questao_id order by questao_id) into v_multiunidade
  from (
    select qup.questao_id
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where u.curso_conteudo_id = 25
    group by qup.questao_id
    having count(*) > 1
  ) x;
  if v_multiunidade is not null then
    raise exception 'Pos-condicao falhou: multiunidade=% (esperado nenhuma — unidade unica)', v_multiunidade;
  end if;

  select count(distinct qup.questao_id) into v_qtd_tmp
  from public.questao_unidades_pedagogicas qup
  where qup.unidade_pedagogica_id = '1a2158e8-f690-43ab-8ca5-051ba1c0fa3e';
  if v_qtd_tmp <> 4 then
    raise exception 'Pos-condicao falhou: u1_questoes=% (esperado 4)', v_qtd_tmp;
  end if;

  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 25) <> 1 then
    raise exception 'Pos-condicao falhou: quantidade de unidades do conteudo 25 != 1';
  end if;
  if (select count(*) from public.unidades_pedagogicas) <> (select total_unidades from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: quantidade de unidades pedagogicas mudou';
  end if;
  if (select count(*) from public.questoes) <> (select total_questoes from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: quantidade de questoes mudou';
  end if;
  if (select count(*) from public.alternativas) <> (select total_alternativas from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: quantidade de alternativas mudou';
  end if;
  if (select count(*) from public.curso_conteudos) <> (select total_conteudos from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: quantidade de curso_conteudos mudou';
  end if;
  if (select count(*) from public.curso_questoes) <> (select total_curso_questoes from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: curso_questoes sofreu alteracao indevida';
  end if;
  if (select count(*) from public.respostas_usuarios) <> (select total_respostas from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: historico de respostas_usuarios mudou';
  end if;
  if (select count(*) from public.sessoes_estudo) <> (select total_sessoes from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: sessoes_estudo mudou';
  end if;

  -- AJUSTE (ver nota no cabecalho): crescimento esperado e 3 (Q234,
  -- Q235, Q236 — novos vinculos nesta operacao), nao 4, pois o vinculo
  -- de Q878 ja existia no snapshot antes (saneada em operacao separada
  -- no commit 5856a10).
  if (select count(*) from public.questao_unidades_pedagogicas) <> (select total_vinculos from _snapshot_antes) + 3 then
    raise exception 'Pos-condicao falhou: total de vinculos nao cresceu exatamente 3 (Q234/Q235/Q236 — Q878 ja contava no snapshot)';
  end if;

  -- Pos-condicao extra: artigos_esperados deve ser NULL.
  select artigos_esperados into v_artigos_esperados
  from public.unidades_pedagogicas
  where id = '1a2158e8-f690-43ab-8ca5-051ba1c0fa3e';
  if v_artigos_esperados is not null then
    raise exception 'Pos-condicao falhou: artigos_esperados=% (esperado NULL)', v_artigos_esperados;
  end if;

  raise notice 'Pos-condicoes OK: 4 questoes classificadas / 4 vinculos (3 novos: Q234/Q235/Q236 + 1 pre-existente: Q878) / 0 multiunidade / artigos_esperados NULL / exatamente 1 vinculo por QID.';
end $$;

commit;
