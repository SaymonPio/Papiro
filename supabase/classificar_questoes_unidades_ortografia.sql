-- Aplicação REAL do mapa aprovado em
-- supabase/mapa_classificacao_ortografia.sql,
-- validado pelo harness
-- classificar_questoes_unidades_ortografia_teste_rollback.sql
-- (tudo_ok = true confirmado antes de rodar este arquivo).
--
-- PRIMEIRO conteudo de Lingua Portuguesa da fila — piloto da
-- metodologia nao juridica (ver
-- scripts/curadoria-pedagogica/config/ortografia.unidades.json e
-- ortografia.mapa.json para o racional completo). artigos_esperados
-- desta unidade e NULL (decisao metodologica: o parser so reconhece
-- "art." e nao representa as Bases do Acordo Ortografico).
--
-- EXCLUSOES INTENCIONAIS (nao classificadas por este arquivo, mas
-- permanecem ativas/intactas no banco):
--   Q688 — PROBLEMA_DE_DADO_LACUNAS_AUSENTES
--   Q689 — DUPLICATA_EXATA_DE_Q321
--
-- Diferença deste arquivo para o harness: termina em COMMIT, e cada
-- precondição/pós-condição usa RAISE EXCEPTION (não apenas relatório
-- booleano) — qualquer divergência aborta a transação inteira antes de
-- confirmar. Usa a mesma RPC administrativa oficial
-- classificar_questao_unidade_admin (nenhum INSERT direto em
-- questao_unidades_pedagogicas, nenhum DELETE, nenhuma alteração em
-- questoes/alternativas/unidades_pedagogicas/aulas/histórico). Segue o
-- mesmo padrão de
-- supabase/classificar_questoes_unidades_prevencao_da_tortura.sql,
-- adaptado ao mecanismo de questoes_excluidas ja usado em
-- supabase/classificar_questoes_unidades_tratados_de_direitos_humanos_com_forca_de_emenda_constitucional.sql.
--
-- PRÉ-REQUISITO: supabase/curadoria_unidades_ortografia.sql precisa já
-- ter sido aplicado (reaproveita unidade placeholder já existente
-- dc6d39fb-5600-43d4-bad6-e3de2356236d — não cria unidade nova).
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
  (66,  'dc6d39fb-5600-43d4-bad6-e3de2356236d'::uuid, 1, 'alta'),
  (119, 'dc6d39fb-5600-43d4-bad6-e3de2356236d', 1, 'alta'),
  (307, 'dc6d39fb-5600-43d4-bad6-e3de2356236d', 1, 'alta'),
  (321, 'dc6d39fb-5600-43d4-bad6-e3de2356236d', 1, 'alta'),
  (322, 'dc6d39fb-5600-43d4-bad6-e3de2356236d', 1, 'alta'),
  (329, 'dc6d39fb-5600-43d4-bad6-e3de2356236d', 1, 'alta'),
  (690, 'dc6d39fb-5600-43d4-bad6-e3de2356236d', 1, 'alta'),
  (691, 'dc6d39fb-5600-43d4-bad6-e3de2356236d', 1, 'alta'),
  (758, 'dc6d39fb-5600-43d4-bad6-e3de2356236d', 1, 'alta'),
  (759, 'dc6d39fb-5600-43d4-bad6-e3de2356236d', 1, 'alta'),
  (760, 'dc6d39fb-5600-43d4-bad6-e3de2356236d', 1, 'alta'),
  (761, 'dc6d39fb-5600-43d4-bad6-e3de2356236d', 1, 'alta'),
  (762, 'dc6d39fb-5600-43d4-bad6-e3de2356236d', 1, 'alta'),
  (786, 'dc6d39fb-5600-43d4-bad6-e3de2356236d', 1, 'alta'),
  (787, 'dc6d39fb-5600-43d4-bad6-e3de2356236d', 1, 'alta'),
  (809, 'dc6d39fb-5600-43d4-bad6-e3de2356236d', 1, 'alta'),
  (810, 'dc6d39fb-5600-43d4-bad6-e3de2356236d', 1, 'alta'),
  (888, 'dc6d39fb-5600-43d4-bad6-e3de2356236d', 1, 'alta'),
  (889, 'dc6d39fb-5600-43d4-bad6-e3de2356236d', 1, 'alta'),
  (890, 'dc6d39fb-5600-43d4-bad6-e3de2356236d', 1, 'alta'),
  (891, 'dc6d39fb-5600-43d4-bad6-e3de2356236d', 1, 'alta'),
  (892, 'dc6d39fb-5600-43d4-bad6-e3de2356236d', 1, 'alta');

-- Lock determinístico das linhas envolvidas antes de revalidar.
select id from public.unidades_pedagogicas
where curso_conteudo_id = 20
order by id
for update;

select id from public.questoes
where id in (select distinct questao_id from _mapa)
   or id in (688, 689)
order by id
for update;

-- Revalidação de precondições — aborta a transação em qualquer divergência.
do $$
declare
  v_materia_id bigint;
  v_assunto_id bigint;
  v_total_candidatas int;
  v_classificacoes_previas int;
  v_688_ativa boolean;
  v_689_ativa boolean;
begin
  select cm.materia_id, cc.assunto_id into v_materia_id, v_assunto_id
  from public.curso_conteudos cc
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where cc.id = 20;

  if v_materia_id is null then
    raise exception 'Precondicao falhou: curso_conteudos 20 nao existe';
  end if;
  if v_materia_id is distinct from 6 or v_assunto_id is distinct from 53 then
    raise exception 'Precondicao falhou: conteudo 20 materia_id=% assunto_id=% (esperado 6/53)', v_materia_id, v_assunto_id;
  end if;

  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 20) <> 1 then
    raise exception 'Precondicao falhou: nao ha exatamente 1 unidade pedagogica para o conteudo 20 — decisao aprovada foi manter unidade unica';
  end if;

  if not exists (select 1 from public.unidades_pedagogicas where id = 'dc6d39fb-5600-43d4-bad6-e3de2356236d' and curso_conteudo_id = 20 and ordem = 1 and ativa)
  then
    raise exception 'Precondicao falhou: a unidade oficial nao confere (id/ordem/conteudo/ativa) — curadoria_unidades_ortografia.sql precisa ter sido aplicado antes';
  end if;

  select count(*) into v_total_candidatas
  from public.questoes q
  join public.curso_conteudos cc on cc.id = 20
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where q.ativa = true
    and q.materia_id = cm.materia_id
    and (cc.assunto_id is null or q.assunto_id = cc.assunto_id);

  if v_total_candidatas <> 24 then
    raise exception 'Precondicao falhou: total de candidatas ativas = % (esperado 24)', v_total_candidatas;
  end if;

  select count(*) into v_classificacoes_previas
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 20
    and qup.questao_id in (select questao_id from _mapa);

  if v_classificacoes_previas <> 0 then
    raise exception 'Precondicao falhou: ja existe classificacao previa inesperada (% linhas) para questao(oes) do mapa', v_classificacoes_previas;
  end if;

  select ativa into v_688_ativa from public.questoes where id = 688;
  select ativa into v_689_ativa from public.questoes where id = 689;
  if v_688_ativa is distinct from true then
    raise exception 'Precondicao falhou: Q688 nao esta ativa=true — verificar antes de prosseguir com a exclusao intencional';
  end if;
  if v_689_ativa is distinct from true then
    raise exception 'Precondicao falhou: Q689 nao esta ativa=true — verificar antes de prosseguir com a exclusao intencional';
  end if;

  if exists (select 1 from public.questao_unidades_pedagogicas where questao_id in (688, 689)) then
    raise exception 'Precondicao falhou: Q688 ou Q689 ja possuem vinculo pedagogico previo — exclusao intencional pressupoe ausencia de vinculo';
  end if;
end $$;

-- Validação do mapa em si.
do $$
declare
  v_invalidas int;
  v_fora_do_candidato int;
  v_unidade_fora int;
  v_distintas int;
  v_contem_excluidas int;
begin
  select count(*) into v_invalidas
  from _mapa m
  join public.questoes q on q.id = m.questao_id
  where not (q.ativa = true and q.materia_id = 6 and q.assunto_id = 53);

  if v_invalidas <> 0 then
    raise exception 'Mapa invalido: % linha(s) apontam para questao que nao esta ativa=true/materia_id=6/assunto_id=53', v_invalidas;
  end if;

  select count(*) into v_distintas from (select distinct questao_id from _mapa) x;
  if v_distintas <> 22 then
    raise exception 'Mapa invalido: cobre % questoes distintas (esperado 22)', v_distintas;
  end if;

  select count(*) into v_contem_excluidas from _mapa where questao_id in (688, 689);
  if v_contem_excluidas <> 0 then
    raise exception 'Mapa invalido: contem questao(oes) excluida(s) intencionalmente (688/689) que nao deveriam ser classificadas';
  end if;

  select count(*) into v_fora_do_candidato
  from _mapa m
  where not exists (
    select 1
    from public.questoes q
    join public.curso_conteudos cc on cc.id = 20
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where q.id = m.questao_id
      and q.ativa = true
      and q.materia_id = cm.materia_id
      and (cc.assunto_id is null or q.assunto_id = cc.assunto_id)
  );
  if v_fora_do_candidato <> 0 then
    raise exception 'Mapa invalido: % linha(s) fora do conjunto candidato de 24 ativas', v_fora_do_candidato;
  end if;

  select count(*) into v_unidade_fora
  from _mapa m
  where m.unidade_pedagogica_id not in (select id from public.unidades_pedagogicas where curso_conteudo_id = 20);
  if v_unidade_fora <> 0 then
    raise exception 'Mapa invalido: % linha(s) referenciam unidade pedagogica fora do conteudo 20', v_unidade_fora;
  end if;
end $$;

-- Aplicação via RPC oficial.
do $$
declare r record;
begin
  for r in select questao_id, unidade_pedagogica_id from _mapa order by questao_id loop
    perform public.classificar_questao_unidade_admin(r.questao_id, r.unidade_pedagogica_id);
  end loop;
end $$;

-- Pós-condições ENDURECIDAS: RAISE EXCEPTION em qualquer divergência —
-- só chega ao COMMIT final se passar tudo.
do $$
declare
  v_total_vinculos int;
  v_questoes_classificadas int;
  v_fora_do_mapa int;
  v_faltando int;
  v_multiunidade bigint[];
  v_artigos_esperados text[];
  v_688_permanece_nao_classificada boolean;
  v_689_permanece_nao_classificada boolean;
  v_688_ativa_depois boolean;
  v_689_ativa_depois boolean;
  v_688_enunciado_antes text;
  v_689_enunciado_antes text;
begin
  select count(*) into v_total_vinculos
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 20;
  if v_total_vinculos <> 22 then
    raise exception 'Pos-condicao falhou: total_vinculos=% (esperado 22)', v_total_vinculos;
  end if;

  select count(distinct qup.questao_id) into v_questoes_classificadas
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 20;
  if v_questoes_classificadas <> 22 then
    raise exception 'Pos-condicao falhou: questoes_classificadas=% (esperado 22)', v_questoes_classificadas;
  end if;

  select count(*) into v_fora_do_mapa
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 20
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
    where u.curso_conteudo_id = 20
    group by qup.questao_id
    having count(*) > 1
  ) x;
  if v_multiunidade is not null then
    raise exception 'Pos-condicao falhou: multiunidade=% (esperado nenhuma — unidade unica)', v_multiunidade;
  end if;

  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 20) <> 1 then
    raise exception 'Pos-condicao falhou: quantidade de unidades do conteudo 20 != 1';
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
  if (select count(*) from public.questao_unidades_pedagogicas) <> (select total_vinculos from _snapshot_antes) + 22 then
    raise exception 'Pos-condicao falhou: total de vinculos nao cresceu exatamente 22';
  end if;

  -- Pos-condicao extra: artigos_esperados deve ser NULL.
  select artigos_esperados into v_artigos_esperados
  from public.unidades_pedagogicas
  where id = 'dc6d39fb-5600-43d4-bad6-e3de2356236d';
  if v_artigos_esperados is not null then
    raise exception 'Pos-condicao falhou: artigos_esperados=% (esperado NULL)', v_artigos_esperados;
  end if;

  -- Pos-condicao extra: Q688 e Q689 permanecem SEM vinculo, ATIVAS e INTACTAS.
  select not exists (select 1 from public.questao_unidades_pedagogicas where questao_id = 688) into v_688_permanece_nao_classificada;
  select not exists (select 1 from public.questao_unidades_pedagogicas where questao_id = 689) into v_689_permanece_nao_classificada;
  if not v_688_permanece_nao_classificada then
    raise exception 'Pos-condicao falhou: Q688 recebeu vinculo pedagogico indevido (deveria permanecer exclusao intencional)';
  end if;
  if not v_689_permanece_nao_classificada then
    raise exception 'Pos-condicao falhou: Q689 recebeu vinculo pedagogico indevido (deveria permanecer exclusao intencional, DUPLICATA_EXATA_DE_Q321)';
  end if;

  select ativa into v_688_ativa_depois from public.questoes where id = 688;
  select ativa into v_689_ativa_depois from public.questoes where id = 689;
  if v_688_ativa_depois is distinct from true then
    raise exception 'Pos-condicao falhou: Q688 nao esta mais ativa=true';
  end if;
  if v_689_ativa_depois is distinct from true then
    raise exception 'Pos-condicao falhou: Q689 nao esta mais ativa=true';
  end if;

  raise notice 'Pos-condicoes OK: 22 questoes classificadas / 22 vinculos / 0 multiunidade / artigos_esperados NULL / Q688 e Q689 ativas, intactas e sem vinculo (exclusao intencional preservada).';
end $$;

commit;
