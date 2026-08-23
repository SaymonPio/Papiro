-- Aplicação REAL do mapa aprovado em
-- config/concordancia_nominal.mapa.json,
-- validado pelo harness
-- classificar_questoes_unidades_concordancia_nominal_teste_rollback.sql
-- (tudo_ok = true confirmado antes de rodar este arquivo).
--
-- Decimo setimo conteudo de Lingua Portuguesa da fila. artigos_esperados
-- desta unidade e NULL (metodologia nao juridica). 2 exclusoes
-- intencionais (Q222, Q224 — QUESTAO_HIBRIDA_MULTICONTEUDO, confirmadas
-- via auditoria alternativa-por-alternativa e teste contrafactual) —
-- apenas Q223 foi classificada. Q223 ja teve sua explicacao saneada em
-- operacao separada (commit 707682e) — este apply NAO altera enunciado/
-- alternativas/gabarito/explicacao de nenhuma questao.
--
-- Diferenca deste arquivo para o harness: termina em COMMIT, e cada
-- precondicao/pos-condicao usa RAISE EXCEPTION (nao apenas relatorio
-- booleano) — qualquer divergencia aborta a transacao inteira antes de
-- confirmar. Usa a mesma RPC administrativa oficial
-- classificar_questao_unidade_admin (nenhum INSERT direto em
-- questao_unidades_pedagogicas, nenhum DELETE, nenhuma alteracao em
-- questoes/alternativas/unidades_pedagogicas/aulas/historico). Inclui
-- pos-condicoes extras confirmando que Q116/Q318 (vinculadas a
-- Concordancia verbal, conteudo 18 ja concluido) permanecem intactas.
--
-- PRE-REQUISITO: supabase/curadoria_unidades_concordancia_nominal.sql
-- precisa ja ter sido aplicado (reaproveita unidade placeholder ja
-- existente 9a4936e1-a9a6-452c-9385-d5a5899ae5c5 — nao cria unidade
-- nova).
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

-- Snapshot de Q116/Q318 (incidencia real externa, ja vinculadas a
-- Concordancia verbal) para confirmar nas pos-condicoes que este apply
-- nao as toca.
create temporary table _snapshot_q116_q318 on commit drop as
select
  (select count(*) from public.questao_unidades_pedagogicas where questao_id = 116) as q116_vinculos,
  (select count(*) from public.questao_unidades_pedagogicas where questao_id = 318) as q318_vinculos;

create temporary table _mapa (
  questao_id bigint,
  unidade_pedagogica_id uuid,
  ordem_unidade int,
  confianca text
) on commit drop;

insert into _mapa (questao_id, unidade_pedagogica_id, ordem_unidade, confianca) values
  (223, '9a4936e1-a9a6-452c-9385-d5a5899ae5c5'::uuid, 1, 'alta');

-- Lock deterministico das linhas envolvidas antes de revalidar.
select id from public.unidades_pedagogicas
where curso_conteudo_id = 19
order by id
for update;

select id from public.questoes
where id in (222, 223, 224)
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
  where cc.id = 19;

  if v_materia_id is null then
    raise exception 'Precondicao falhou: curso_conteudos 19 nao existe';
  end if;
  if v_materia_id is distinct from 6 or v_assunto_id is distinct from 52 then
    raise exception 'Precondicao falhou: conteudo 19 materia_id=% assunto_id=% (esperado 6/52)', v_materia_id, v_assunto_id;
  end if;

  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 19) <> 1 then
    raise exception 'Precondicao falhou: nao ha exatamente 1 unidade pedagogica para o conteudo 19 — decisao aprovada foi manter unidade unica';
  end if;

  if not exists (select 1 from public.unidades_pedagogicas where id = '9a4936e1-a9a6-452c-9385-d5a5899ae5c5' and curso_conteudo_id = 19 and ordem = 1 and ativa)
  then
    raise exception 'Precondicao falhou: a unidade oficial nao confere (id/ordem/conteudo/ativa) — curadoria_unidades_concordancia_nominal.sql precisa ter sido aplicado antes';
  end if;

  select count(*) into v_total_candidatas
  from public.questoes q
  join public.curso_conteudos cc on cc.id = 19
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where q.ativa = true
    and q.materia_id = cm.materia_id
    and (cc.assunto_id is null or q.assunto_id = cc.assunto_id);

  if v_total_candidatas <> 3 then
    raise exception 'Precondicao falhou: total de candidatas ativas = % (esperado 3)', v_total_candidatas;
  end if;

  select count(*) into v_classificacoes_previas
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 19
    and qup.questao_id in (select questao_id from _mapa);

  if v_classificacoes_previas <> 0 then
    raise exception 'Precondicao falhou: ja existe classificacao previa inesperada (% linhas) para questao(oes) do mapa', v_classificacoes_previas;
  end if;

  -- Q222 e Q224 precisam estar ativas, no assunto correto, e sem
  -- nenhum vinculo — sao as exclusoes pedagogicas intencionais
  -- (QUESTAO_HIBRIDA_MULTICONTEUDO).
  if not exists (select 1 from public.questoes where id = 222 and ativa = true and assunto_id = 52) then
    raise exception 'Precondicao falhou: questao 222 nao esta ativa=true/assunto_id=52';
  end if;
  if exists (select 1 from public.questao_unidades_pedagogicas where questao_id = 222) then
    raise exception 'Precondicao falhou: questao 222 ja possui vinculo pedagogico (esperado: nenhum, ela e exclusao intencional)';
  end if;
  if not exists (select 1 from public.questoes where id = 224 and ativa = true and assunto_id = 52) then
    raise exception 'Precondicao falhou: questao 224 nao esta ativa=true/assunto_id=52';
  end if;
  if exists (select 1 from public.questao_unidades_pedagogicas where questao_id = 224) then
    raise exception 'Precondicao falhou: questao 224 ja possui vinculo pedagogico (esperado: nenhum, ela e exclusao intencional)';
  end if;

  -- Q116/Q318 (incidencia real externa) devem permanecer vinculadas a
  -- Concordancia verbal, nao a esta unidade.
  if not exists (select 1 from public.questao_unidades_pedagogicas where questao_id = 116) then
    raise exception 'Precondicao falhou: questao 116 nao possui nenhum vinculo pedagogico (esperado: vinculo preexistente em Concordancia verbal)';
  end if;
  if not exists (select 1 from public.questao_unidades_pedagogicas where questao_id = 318) then
    raise exception 'Precondicao falhou: questao 318 nao possui nenhum vinculo pedagogico (esperado: vinculo preexistente em Concordancia verbal)';
  end if;
end $$;

-- Validacao do mapa em si.
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
  where not (q.ativa = true and q.materia_id = 6 and q.assunto_id = 52);

  if v_invalidas <> 0 then
    raise exception 'Mapa invalido: % linha(s) apontam para questao que nao esta ativa=true/materia_id=6/assunto_id=52', v_invalidas;
  end if;

  select count(*) into v_distintas from (select distinct questao_id from _mapa) x;
  if v_distintas <> 1 then
    raise exception 'Mapa invalido: cobre % questoes distintas (esperado 1)', v_distintas;
  end if;

  if exists (select 1 from _mapa where questao_id in (222, 224)) then
    raise exception 'Mapa invalido: questoes 222/224 (exclusao pedagogica intencional) nao podem constar no mapa de vinculos';
  end if;

  select count(*) into v_fora_do_candidato
  from _mapa m
  where not exists (
    select 1
    from public.questoes q
    join public.curso_conteudos cc on cc.id = 19
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where q.id = m.questao_id
      and q.ativa = true
      and q.materia_id = cm.materia_id
      and (cc.assunto_id is null or q.assunto_id = cc.assunto_id)
  );
  if v_fora_do_candidato <> 0 then
    raise exception 'Mapa invalido: % linha(s) fora do conjunto candidato de 3 ativas', v_fora_do_candidato;
  end if;

  select count(*) into v_unidade_fora
  from _mapa m
  where m.unidade_pedagogica_id not in (select id from public.unidades_pedagogicas where curso_conteudo_id = 19);
  if v_unidade_fora <> 0 then
    raise exception 'Mapa invalido: % linha(s) referenciam unidade pedagogica fora do conteudo 19', v_unidade_fora;
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
begin
  select count(*) into v_total_vinculos
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 19;
  if v_total_vinculos <> 1 then
    raise exception 'Pos-condicao falhou: total_vinculos=% (esperado 1)', v_total_vinculos;
  end if;

  select count(distinct qup.questao_id) into v_questoes_classificadas
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 19;
  if v_questoes_classificadas <> 1 then
    raise exception 'Pos-condicao falhou: questoes_classificadas=% (esperado 1)', v_questoes_classificadas;
  end if;

  select count(*) into v_fora_do_mapa
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 19
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
    where u.curso_conteudo_id = 19
    group by qup.questao_id
    having count(*) > 1
  ) x;
  if v_multiunidade is not null then
    raise exception 'Pos-condicao falhou: multiunidade=% (esperado nenhuma — unidade unica)', v_multiunidade;
  end if;

  -- Q222 e Q224 permanecem sem nenhum vinculo (exclusao pedagogica intencional).
  if exists (select 1 from public.questao_unidades_pedagogicas where questao_id = 222) then
    raise exception 'Pos-condicao falhou: questao 222 recebeu vinculo pedagogico indevido (deveria permanecer exclusao intencional)';
  end if;
  if exists (select 1 from public.questao_unidades_pedagogicas where questao_id = 224) then
    raise exception 'Pos-condicao falhou: questao 224 recebeu vinculo pedagogico indevido (deveria permanecer exclusao intencional)';
  end if;

  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 19) <> 1 then
    raise exception 'Pos-condicao falhou: quantidade de unidades do conteudo 19 != 1';
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
  if (select count(*) from public.questao_unidades_pedagogicas) <> (select total_vinculos from _snapshot_antes) + 1 then
    raise exception 'Pos-condicao falhou: total de vinculos nao cresceu exatamente 1';
  end if;

  -- Pos-condicao extra: artigos_esperados deve ser NULL.
  select artigos_esperados into v_artigos_esperados
  from public.unidades_pedagogicas
  where id = '9a4936e1-a9a6-452c-9385-d5a5899ae5c5';
  if v_artigos_esperados is not null then
    raise exception 'Pos-condicao falhou: artigos_esperados=% (esperado NULL)', v_artigos_esperados;
  end if;

  -- Pos-condicao extra: Q116/Q318 (incidencia real externa) permanecem
  -- com os mesmos vinculos de antes (nenhum vinculo novo/removido).
  if (select count(*) from public.questao_unidades_pedagogicas where questao_id = 116) <> (select q116_vinculos from _snapshot_q116_q318) then
    raise exception 'Pos-condicao falhou: vinculos da questao 116 foram alterados indevidamente por este apply';
  end if;
  if (select count(*) from public.questao_unidades_pedagogicas where questao_id = 318) <> (select q318_vinculos from _snapshot_q116_q318) then
    raise exception 'Pos-condicao falhou: vinculos da questao 318 foram alterados indevidamente por este apply';
  end if;

  raise notice 'Pos-condicoes OK: 1 questao classificada (223) / 1 vinculo / 0 multiunidade / artigos_esperados NULL / questoes 222 e 224 permanecem exclusoes intencionais sem vinculo / vinculos de Q116 e Q318 preservados intactos.';
end $$;

commit;
