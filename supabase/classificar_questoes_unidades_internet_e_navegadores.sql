-- Aplicação REAL do mapa aprovado em
-- config/internet_e_navegadores.mapa.json,
-- validado pelo harness
-- classificar_questoes_unidades_internet_e_navegadores_teste_rollback.sql
-- (tudo_ok = true confirmado antes de rodar este arquivo).
--
-- Primeiro conteúdo de Informática da fila (ordem 77). artigos_esperados
-- de ambas as unidades é NULL (metodologia não jurídica). 21 candidatas
-- ativas (após saneamento taxonômico prévio de Q635 para Correio
-- eletrônico, commit de45a7b — Q635 não aparece aqui). 3 exclusões por
-- fidelidade (Q64, Q496, Q497 — não taxonomia, não multiconteúdo), 18
-- vinculadas. TODAS as 21 candidatas restantes são REAL (Fundatec) — 0
-- AUTORAL neste corpus.
--
-- Diferenca deste arquivo para o harness: termina em COMMIT, e cada
-- precondicao/pos-condicao usa RAISE EXCEPTION (nao apenas relatorio
-- booleano) — qualquer divergencia aborta a transacao inteira antes de
-- confirmar. Usa a mesma RPC administrativa oficial
-- classificar_questao_unidade_admin (nenhum INSERT direto em
-- questao_unidades_pedagogicas, nenhum DELETE, nenhuma alteracao em
-- questoes/alternativas/unidades_pedagogicas/aulas/historico).
--
-- PRE-REQUISITO: supabase/curadoria_unidades_internet_e_navegadores.sql
-- ja foi aplicado (atualiza a unidade placeholder ja existente
-- b66e09ca-3dc1-4b63-879d-c81292b94550 como Unidade 1, e ja criou a
-- Unidade 2 d9153747-6150-4a1f-8bb8-f4ea433f672f — nenhuma unidade nova
-- e criada por este arquivo).

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
  (63,  'b66e09ca-3dc1-4b63-879d-c81292b94550'::uuid, 1, 'alta'),
  (94,  'b66e09ca-3dc1-4b63-879d-c81292b94550'::uuid, 1, 'alta'),
  (98,  'b66e09ca-3dc1-4b63-879d-c81292b94550'::uuid, 1, 'alta'),
  (106, 'b66e09ca-3dc1-4b63-879d-c81292b94550'::uuid, 1, 'alta'),
  (107, 'b66e09ca-3dc1-4b63-879d-c81292b94550'::uuid, 1, 'média'),
  (634, 'b66e09ca-3dc1-4b63-879d-c81292b94550'::uuid, 1, 'alta'),
  (636, 'b66e09ca-3dc1-4b63-879d-c81292b94550'::uuid, 1, 'alta'),
  (770, 'b66e09ca-3dc1-4b63-879d-c81292b94550'::uuid, 1, 'alta'),
  (792, 'b66e09ca-3dc1-4b63-879d-c81292b94550'::uuid, 1, 'alta'),
  (833, 'b66e09ca-3dc1-4b63-879d-c81292b94550'::uuid, 1, 'alta'),
  (630, 'd9153747-6150-4a1f-8bb8-f4ea433f672f'::uuid, 2, 'alta'),
  (631, 'd9153747-6150-4a1f-8bb8-f4ea433f672f'::uuid, 2, 'alta'),
  (632, 'd9153747-6150-4a1f-8bb8-f4ea433f672f'::uuid, 2, 'alta'),
  (633, 'd9153747-6150-4a1f-8bb8-f4ea433f672f'::uuid, 2, 'alta'),
  (702, 'd9153747-6150-4a1f-8bb8-f4ea433f672f'::uuid, 2, 'alta'),
  (703, 'd9153747-6150-4a1f-8bb8-f4ea433f672f'::uuid, 2, 'alta'),
  (704, 'd9153747-6150-4a1f-8bb8-f4ea433f672f'::uuid, 2, 'alta'),
  (705, 'd9153747-6150-4a1f-8bb8-f4ea433f672f'::uuid, 2, 'alta');

-- Lock deterministico das linhas envolvidas antes de revalidar.
select id from public.unidades_pedagogicas
where curso_conteudo_id = 38
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
  v_unidades_ok boolean;
begin
  select cm.materia_id, cc.assunto_id into v_materia_id, v_assunto_id
  from public.curso_conteudos cc
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where cc.id = 38;

  if v_materia_id is null then
    raise exception 'Precondicao falhou: curso_conteudos 38 nao existe';
  end if;
  if v_materia_id is distinct from 9 or v_assunto_id is distinct from 62 then
    raise exception 'Precondicao falhou: conteudo 38 materia_id=% assunto_id=% (esperado 9/62)', v_materia_id, v_assunto_id;
  end if;

  select bool_and(x.ok) into v_unidades_ok from (
    select exists (select 1 from public.unidades_pedagogicas where id = 'b66e09ca-3dc1-4b63-879d-c81292b94550' and curso_conteudo_id = 38 and ordem = 1 and ativa) as ok
    union all
    select exists (select 1 from public.unidades_pedagogicas where id = 'd9153747-6150-4a1f-8bb8-f4ea433f672f' and curso_conteudo_id = 38 and ordem = 2 and ativa) as ok
  ) x;
  if not coalesce(v_unidades_ok, false) then
    raise exception 'Precondicao falhou: as 2 unidades oficiais nao conferem (id/ordem/conteudo/ativa) — curadoria_unidades_internet_e_navegadores.sql precisa ter sido aplicado antes';
  end if;

  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 38) <> 2 then
    raise exception 'Precondicao falhou: nao ha exatamente 2 unidades pedagogicas para o conteudo 38';
  end if;

  select count(*) into v_total_candidatas
  from public.questoes q
  join public.curso_conteudos cc on cc.id = 38
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where q.ativa = true
    and q.materia_id = cm.materia_id
    and (cc.assunto_id is null or q.assunto_id = cc.assunto_id);

  if v_total_candidatas <> 21 then
    raise exception 'Precondicao falhou: total de candidatas ativas = % (esperado 21, apos saneamento previo de Q635)', v_total_candidatas;
  end if;

  select count(*) into v_classificacoes_previas
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 38
    and qup.questao_id in (select questao_id from _mapa);

  if v_classificacoes_previas <> 0 then
    raise exception 'Precondicao falhou: ja existe classificacao previa inesperada (% linhas) para questao(oes) do mapa', v_classificacoes_previas;
  end if;

  -- Confirma que Q635 (ja saneada para Correio eletronico) nao consta
  -- mais como candidata deste assunto e nao tem vinculo aqui.
  if exists (select 1 from public.questoes where id = 635 and ativa = true and materia_id = 9 and assunto_id = 62) then
    raise exception 'Precondicao falhou: Q635 ainda aparece como candidata do assunto 62 — saneamento previo nao confere';
  end if;
  if exists (
    select 1 from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where qup.questao_id = 635 and u.curso_conteudo_id = 38
  ) then
    raise exception 'Precondicao falhou: Q635 possui vinculo indevido em Internet e navegadores';
  end if;
end $$;

-- Validacao do mapa em si — aborta a transacao em qualquer divergencia.
do $$
declare
  v_invalidas int;
  v_fora_do_candidato int;
  v_unidade_fora int;
  v_distintas int;
  v_contem_excluida boolean;
begin
  select count(*) into v_invalidas
  from _mapa m
  join public.questoes q on q.id = m.questao_id
  where not (q.ativa = true and q.materia_id = 9 and q.assunto_id = 62);

  if v_invalidas <> 0 then
    raise exception 'Mapa invalido: % linha(s) apontam para questao que nao esta ativa=true/materia_id=9/assunto_id=62', v_invalidas;
  end if;

  select count(*) into v_distintas from (select distinct questao_id from _mapa) x;
  if v_distintas <> 18 then
    raise exception 'Mapa invalido: cobre % questoes distintas (esperado 18)', v_distintas;
  end if;

  select exists (select 1 from _mapa where questao_id in (64, 496, 497)) into v_contem_excluida;
  if coalesce(v_contem_excluida, false) then
    raise exception 'Mapa invalido: contem questao(oes) excluida(s) intencionalmente por fidelidade (64/496/497) que nao deveriam ser classificadas';
  end if;

  select count(*) into v_fora_do_candidato
  from _mapa m
  where not exists (
    select 1
    from public.questoes q
    join public.curso_conteudos cc on cc.id = 38
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where q.id = m.questao_id
      and q.ativa = true
      and q.materia_id = cm.materia_id
      and (cc.assunto_id is null or q.assunto_id = cc.assunto_id)
  );
  if v_fora_do_candidato <> 0 then
    raise exception 'Mapa invalido: % linha(s) fora do conjunto candidato de 21 ativas', v_fora_do_candidato;
  end if;

  select count(*) into v_unidade_fora
  from _mapa m
  where m.unidade_pedagogica_id not in (select id from public.unidades_pedagogicas where curso_conteudo_id = 38);
  if v_unidade_fora <> 0 then
    raise exception 'Mapa invalido: % linha(s) referenciam unidade pedagogica fora do conteudo 38', v_unidade_fora;
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
  v_qtd_u1 int;
  v_qtd_u2 int;
  v_excluida_64 boolean;
  v_excluida_496 boolean;
  v_excluida_497 boolean;
  v_artigos_u1 text[];
  v_artigos_u2 text[];
begin
  select count(*) into v_total_vinculos
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 38;
  if v_total_vinculos <> 18 then
    raise exception 'Pos-condicao falhou: total_vinculos=% (esperado 18)', v_total_vinculos;
  end if;

  select count(distinct qup.questao_id) into v_questoes_classificadas
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 38;
  if v_questoes_classificadas <> 18 then
    raise exception 'Pos-condicao falhou: questoes_classificadas=% (esperado 18)', v_questoes_classificadas;
  end if;

  select count(*) into v_fora_do_mapa
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 38
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
    where u.curso_conteudo_id = 38
    group by qup.questao_id
    having count(*) > 1
  ) x;
  if v_multiunidade is not null then
    raise exception 'Pos-condicao falhou: multiunidade=% (esperado nenhuma)', v_multiunidade;
  end if;

  select count(distinct qup.questao_id) into v_qtd_u1
  from public.questao_unidades_pedagogicas qup
  where qup.unidade_pedagogica_id = 'b66e09ca-3dc1-4b63-879d-c81292b94550';
  if v_qtd_u1 <> 10 then
    raise exception 'Pos-condicao falhou: u1_questoes=% (esperado 10)', v_qtd_u1;
  end if;

  select count(distinct qup.questao_id) into v_qtd_u2
  from public.questao_unidades_pedagogicas qup
  where qup.unidade_pedagogica_id = 'd9153747-6150-4a1f-8bb8-f4ea433f672f';
  if v_qtd_u2 <> 8 then
    raise exception 'Pos-condicao falhou: u2_questoes=% (esperado 8)', v_qtd_u2;
  end if;

  -- Q64, Q496, Q497 permanecem SEM vinculo neste conteudo (exclusao por
  -- fidelidade, nao aplicada pelo mapa).
  select not exists (select 1 from public.questao_unidades_pedagogicas where questao_id = 64) into v_excluida_64;
  select not exists (select 1 from public.questao_unidades_pedagogicas where questao_id = 496) into v_excluida_496;
  select not exists (select 1 from public.questao_unidades_pedagogicas where questao_id = 497) into v_excluida_497;
  if not (v_excluida_64 and v_excluida_496 and v_excluida_497) then
    raise exception 'Pos-condicao falhou: Q64/Q496/Q497 nao deveriam ter recebido vinculo pedagogico (64:% 496:% 497:%)', v_excluida_64, v_excluida_496, v_excluida_497;
  end if;

  -- Q635 (saneada em operacao separada, commit de45a7b) permanece fora
  -- deste conteudo.
  if exists (
    select 1 from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where qup.questao_id = 635 and u.curso_conteudo_id = 38
  ) then
    raise exception 'Pos-condicao falhou: Q635 nao deveria ter vinculo em Internet e navegadores (ja pertence a Correio eletronico)';
  end if;
  if not exists (
    select 1 from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where qup.questao_id = 635 and u.curso_conteudo_id = 39
  ) then
    raise exception 'Pos-condicao falhou: Q635 deveria continuar vinculada em Correio eletronico (curso_conteudo_id 39), sem alteracao';
  end if;

  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 38) <> 2 then
    raise exception 'Pos-condicao falhou: quantidade de unidades do conteudo 38 != 2';
  end if;
  if (select count(*) from public.unidades_pedagogicas) <> (select total_unidades from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: quantidade de unidades pedagogicas mudou (nenhuma unidade nova deveria ter sido criada por este arquivo)';
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
  if (select count(*) from public.questao_unidades_pedagogicas) <> (select total_vinculos from _snapshot_antes) + 18 then
    raise exception 'Pos-condicao falhou: total de vinculos nao cresceu exatamente 18';
  end if;

  -- Pos-condicao extra: artigos_esperados deve ser NULL em ambas.
  select artigos_esperados into v_artigos_u1 from public.unidades_pedagogicas where id = 'b66e09ca-3dc1-4b63-879d-c81292b94550';
  select artigos_esperados into v_artigos_u2 from public.unidades_pedagogicas where id = 'd9153747-6150-4a1f-8bb8-f4ea433f672f';
  if v_artigos_u1 is not null or v_artigos_u2 is not null then
    raise exception 'Pos-condicao falhou: artigos_esperados nao esta NULL em ambas as unidades (u1=% u2=%)', v_artigos_u1, v_artigos_u2;
  end if;

  raise notice 'Pos-condicoes OK: 18 questoes classificadas (10 em U1 + 8 em U2) / 0 multiunidade / Q64,Q496,Q497 sem vinculo / Q635 intacta em Correio eletronico / artigos_esperados NULL nas 2 unidades.';
end $$;

commit;
