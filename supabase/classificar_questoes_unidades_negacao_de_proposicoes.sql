-- Aplicação REAL do mapa aprovado em
-- config/negacao_de_proposicoes.mapa.json,
-- validado pelo harness
-- classificar_questoes_unidades_negacao_de_proposicoes_teste_rollback.sql
-- (tudo_ok = true confirmado antes de rodar este arquivo).
--
-- Primeiro conteúdo do bloco final de Raciocínio Lógico/Matemática, após
-- a conclusão de Informática (100%). artigos_esperados desta unidade é
-- NULL (metodologia não jurídica). 0 exclusões — as 4 questões ativas
-- foram classificadas (3 rows REAL Fundatec + 1 AUTORAL Q312).
--
-- MICROAUDITORIA TAXONÔMICA DEDICADA (executada e aprovada antes deste
-- apply): confirmou que as 4 candidatas permanecem corretamente
-- classificadas em Negação de proposições, por teste contrafactual de
-- habilidade nuclear (nunca pelo texto do comando isoladamente).
-- Registradas, como achado EXTERNO a esta ordem e SEM NENHUMA AÇÃO sobre
-- elas aqui: PENDENCIA_DE_TAXONOMIA_Q77, PENDENCIA_DE_TAXONOMIA_Q88 e
-- PENDENCIA_DE_TAXONOMIA_Q311 (corpus inteiro do conteúdo futuro Leis de
-- De Morgan, curso_conteudo_id 4, ordem 86 — suspeita forte de
-- sobreposição com a habilidade de negação de conjunção já praticada
-- aqui via Q312) e uma nota branda sobre Q287 (conteúdo futuro
-- Quantificadores, curso_conteudo_id 7, ordem 89 — risco de sobreposição
-- bem menor, já que aquele conteúdo mostrou identidade própria
-- genuína). Nenhuma dessas 4 questões externas é tocada por este
-- arquivo.
--
-- Diferenca deste arquivo para o harness: termina em COMMIT, e cada
-- precondicao/pos-condicao usa RAISE EXCEPTION (nao apenas relatorio
-- booleano) — qualquer divergencia aborta a transacao inteira antes de
-- confirmar. Usa a mesma RPC administrativa oficial
-- classificar_questao_unidade_admin (nenhum INSERT direto em
-- questao_unidades_pedagogicas, nenhum DELETE, nenhuma alteracao em
-- questoes/alternativas/unidades_pedagogicas/aulas/historico).
--
-- PRE-REQUISITO: supabase/curadoria_unidades_negacao_de_proposicoes.sql
-- ja foi aplicado (reaproveita unidade placeholder ja existente
-- c6ccefae-14df-4760-8c1d-2822090a2a93 — nao cria unidade nova).

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
  (81, 'c6ccefae-14df-4760-8c1d-2822090a2a93'::uuid, 1, 'alta'),
  (86, 'c6ccefae-14df-4760-8c1d-2822090a2a93'::uuid, 1, 'alta'),
  (312, 'c6ccefae-14df-4760-8c1d-2822090a2a93'::uuid, 1, 'alta'),
  (337, 'c6ccefae-14df-4760-8c1d-2822090a2a93'::uuid, 1, 'alta');

-- Lock deterministico das linhas envolvidas antes de revalidar.
select id from public.unidades_pedagogicas
where curso_conteudo_id = 3
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
begin
  select cm.materia_id, cc.assunto_id into v_materia_id, v_assunto_id
  from public.curso_conteudos cc
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where cc.id = 3;

  if v_materia_id is null then
    raise exception 'Precondicao falhou: curso_conteudos 3 nao existe';
  end if;
  if v_materia_id is distinct from 18 or v_assunto_id is distinct from 35 then
    raise exception 'Precondicao falhou: conteudo 3 materia_id=% assunto_id=% (esperado 18/35)', v_materia_id, v_assunto_id;
  end if;

  if not exists (select 1 from public.unidades_pedagogicas where id = 'c6ccefae-14df-4760-8c1d-2822090a2a93' and curso_conteudo_id = 3 and ordem = 1 and ativa)
  then
    raise exception 'Precondicao falhou: a unidade oficial nao confere (id/ordem/conteudo/ativa) — curadoria_unidades_negacao_de_proposicoes.sql precisa ter sido aplicado antes';
  end if;

  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 3) <> 1 then
    raise exception 'Precondicao falhou: nao ha exatamente 1 unidade pedagogica para o conteudo 3 — decisao aprovada foi manter unidade unica';
  end if;

  select count(*) into v_total_candidatas
  from public.questoes q
  join public.curso_conteudos cc on cc.id = 3
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
  where u.curso_conteudo_id = 3
    and qup.questao_id in (select questao_id from _mapa);

  if v_classificacoes_previas <> 0 then
    raise exception 'Precondicao falhou: ja existe classificacao previa inesperada (% linhas) para questao(oes) do mapa', v_classificacoes_previas;
  end if;

  -- Q77/Q88/Q311/Q287 (pendencias externas de taxonomia) nao devem ter
  -- sido tocadas: continuam sem vinculo neste conteudo (nao fazem parte
  -- do mapa) e mantem seu assunto_id original.
  if exists (
    select 1 from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where u.curso_conteudo_id = 3 and qup.questao_id in (77, 88, 311, 287)
  ) then
    raise exception 'Precondicao falhou: alguma das questoes externas (77/88/311/287) ja possui vinculo neste conteudo — nao deveria';
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
  where not (q.ativa = true and q.materia_id = 18 and q.assunto_id = 35);

  if v_invalidas <> 0 then
    raise exception 'Mapa invalido: % linha(s) apontam para questao que nao esta ativa=true/materia_id=18/assunto_id=35', v_invalidas;
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
    join public.curso_conteudos cc on cc.id = 3
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
  where m.unidade_pedagogica_id not in (select id from public.unidades_pedagogicas where curso_conteudo_id = 3);
  if v_unidade_fora <> 0 then
    raise exception 'Mapa invalido: % linha(s) referenciam unidade pedagogica fora do conteudo 3', v_unidade_fora;
  end if;
end $$;

-- Aplicacao via RPC oficial.
do $$
declare r record;
begin
  for r in select questao_id, unidade_pedagogica_id from _mapa order by questao_id loop
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
  v_artigos_esperados text[];
  v_externas_vinculos int;
  v_assunto_77 bigint;
  v_assunto_88 bigint;
  v_assunto_311 bigint;
  v_assunto_287 bigint;
begin
  select count(*) into v_total_vinculos
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 3;
  if v_total_vinculos <> 4 then
    raise exception 'Pos-condicao falhou: total_vinculos=% (esperado 4)', v_total_vinculos;
  end if;

  select count(distinct qup.questao_id) into v_questoes_classificadas
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 3;
  if v_questoes_classificadas <> 4 then
    raise exception 'Pos-condicao falhou: questoes_classificadas=% (esperado 4)', v_questoes_classificadas;
  end if;

  select count(*) into v_fora_do_mapa
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 3
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
    where u.curso_conteudo_id = 3
    group by qup.questao_id
    having count(*) > 1
  ) x;
  if v_multiunidade is not null then
    raise exception 'Pos-condicao falhou: multiunidade=% (esperado nenhuma — unidade unica)', v_multiunidade;
  end if;

  -- Pos-condicao extra: as 4 questoes externas continuam sem vinculo
  -- neste conteudo e com seu assunto_id original intacto (Q77/Q88/Q311
  -- em 34, Q287 em 33) — nenhum saneamento foi feito por este arquivo.
  select count(*) into v_externas_vinculos
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 3 and qup.questao_id in (77, 88, 311, 287);
  if v_externas_vinculos <> 0 then
    raise exception 'Pos-condicao falhou: questoes externas (77/88/311/287) ganharam vinculo neste conteudo (%), nao deveriam', v_externas_vinculos;
  end if;

  select assunto_id into v_assunto_77 from public.questoes where id = 77;
  select assunto_id into v_assunto_88 from public.questoes where id = 88;
  select assunto_id into v_assunto_311 from public.questoes where id = 311;
  select assunto_id into v_assunto_287 from public.questoes where id = 287;
  if v_assunto_77 is distinct from 34 or v_assunto_88 is distinct from 34 or v_assunto_311 is distinct from 34 or v_assunto_287 is distinct from 33 then
    raise exception 'Pos-condicao falhou: assunto_id de questao externa foi alterado indevidamente (77=%,88=%,311=%,287=%)', v_assunto_77, v_assunto_88, v_assunto_311, v_assunto_287;
  end if;

  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 3) <> 1 then
    raise exception 'Pos-condicao falhou: quantidade de unidades do conteudo 3 != 1';
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
  if (select count(*) from public.questao_unidades_pedagogicas) <> (select total_vinculos from _snapshot_antes) + 4 then
    raise exception 'Pos-condicao falhou: total de vinculos nao cresceu exatamente 4';
  end if;

  -- Pos-condicao extra: artigos_esperados deve ser NULL.
  select artigos_esperados into v_artigos_esperados
  from public.unidades_pedagogicas
  where id = 'c6ccefae-14df-4760-8c1d-2822090a2a93';
  if v_artigos_esperados is not null then
    raise exception 'Pos-condicao falhou: artigos_esperados=% (esperado NULL)', v_artigos_esperados;
  end if;

  raise notice 'Pos-condicoes OK: 4 questoes classificadas / 4 vinculos / 0 multiunidade / artigos_esperados NULL / questoes externas (77/88/311/287) intactas e sem vinculo neste conteudo.';
end $$;

commit;
