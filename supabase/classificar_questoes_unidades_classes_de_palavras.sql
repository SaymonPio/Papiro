-- Aplicação REAL do mapa aprovado em
-- supabase/mapa_classificacao_classes_de_palavras.sql,
-- validado pelo harness
-- classificar_questoes_unidades_classes_de_palavras_teste_rollback.sql
-- (tudo_ok = true confirmado antes de rodar este arquivo).
--
-- Segundo conteudo de Lingua Portuguesa da fila. artigos_esperados
-- desta unidade e NULL (metodologia nao juridica ja consolidada no
-- piloto de Ortografia, conteudo 20).
--
-- EXCLUSOES INTENCIONAIS (nao classificadas por este arquivo, mas
-- permanecem ativas/intactas no banco):
--   Q71  — FORA_DE_ESCOPO_SINTAXE_SUJEITO
--   Q325 — PROBLEMA_DE_DADO_TEXTO_BASE_AUSENTE
--   Q683 — FORA_DE_ESCOPO_REFERENCIA_TEXTUAL
--   Q878 — FORA_DE_ESCOPO_SEMANTICA_PRESSUPOSICAO
--
-- Diferença deste arquivo para o harness: termina em COMMIT, e cada
-- precondição/pós-condição usa RAISE EXCEPTION (não apenas relatório
-- booleano) — qualquer divergência aborta a transação inteira antes de
-- confirmar. Usa a mesma RPC administrativa oficial
-- classificar_questao_unidade_admin (nenhum INSERT direto em
-- questao_unidades_pedagogicas, nenhum DELETE, nenhuma alteração em
-- questoes/alternativas/unidades_pedagogicas/aulas/histórico). Segue o
-- mesmo padrão de
-- supabase/classificar_questoes_unidades_ortografia.sql.
--
-- ATENÇÃO: sobreposição de texto-base (não duplicata) com o conteúdo
-- já concluído 20 (Ortografia) — Q876/Q877/Q879 compartilham
-- texto-base com Q888/Q889/Q892 lá, testando pontos diferentes. O
-- conteúdo 20 não é tocado por este arquivo.
--
-- PRÉ-REQUISITO: supabase/curadoria_unidades_classes_de_palavras.sql
-- precisa já ter sido aplicado (reaproveita unidade placeholder já
-- existente 3f215008-367b-4890-9588-525980baefc1 — não cria unidade
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

create temporary table _snapshot_sobrepostos_antes on commit drop as
select
  (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 20) as unidades_20,
  (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where u.curso_conteudo_id = 20) as vinculos_20;

create temporary table _mapa (
  questao_id bigint,
  unidade_pedagogica_id uuid,
  ordem_unidade int,
  confianca text
) on commit drop;

insert into _mapa (questao_id, unidade_pedagogica_id, ordem_unidade, confianca) values
  (273, '3f215008-367b-4890-9588-525980baefc1'::uuid, 1, 'alta'),
  (274, '3f215008-367b-4890-9588-525980baefc1', 1, 'alta'),
  (323, '3f215008-367b-4890-9588-525980baefc1', 1, 'alta'),
  (330, '3f215008-367b-4890-9588-525980baefc1', 1, 'alta'),
  (331, '3f215008-367b-4890-9588-525980baefc1', 1, 'alta'),
  (335, '3f215008-367b-4890-9588-525980baefc1', 1, 'alta'),
  (682, '3f215008-367b-4890-9588-525980baefc1', 1, 'alta'),
  (684, '3f215008-367b-4890-9588-525980baefc1', 1, 'alta'),
  (749, '3f215008-367b-4890-9588-525980baefc1', 1, 'alta'),
  (750, '3f215008-367b-4890-9588-525980baefc1', 1, 'alta'),
  (751, '3f215008-367b-4890-9588-525980baefc1', 1, 'alta'),
  (752, '3f215008-367b-4890-9588-525980baefc1', 1, 'alta'),
  (784, '3f215008-367b-4890-9588-525980baefc1', 1, 'alta'),
  (806, '3f215008-367b-4890-9588-525980baefc1', 1, 'alta'),
  (876, '3f215008-367b-4890-9588-525980baefc1', 1, 'alta'),
  (877, '3f215008-367b-4890-9588-525980baefc1', 1, 'alta'),
  (879, '3f215008-367b-4890-9588-525980baefc1', 1, 'alta');

-- Lock determinístico das linhas envolvidas antes de revalidar.
select id from public.unidades_pedagogicas
where curso_conteudo_id = 22
order by id
for update;

select id from public.questoes
where id in (select distinct questao_id from _mapa)
   or id in (71, 325, 683, 878)
order by id
for update;

-- Revalidação de precondições — aborta a transação em qualquer divergência.
do $$
declare
  v_materia_id bigint;
  v_assunto_id bigint;
  v_total_candidatas int;
  v_classificacoes_previas int;
  v_71_ativa boolean;
  v_325_ativa boolean;
  v_683_ativa boolean;
  v_878_ativa boolean;
begin
  select cm.materia_id, cc.assunto_id into v_materia_id, v_assunto_id
  from public.curso_conteudos cc
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where cc.id = 22;

  if v_materia_id is null then
    raise exception 'Precondicao falhou: curso_conteudos 22 nao existe';
  end if;
  if v_materia_id is distinct from 6 or v_assunto_id is distinct from 47 then
    raise exception 'Precondicao falhou: conteudo 22 materia_id=% assunto_id=% (esperado 6/47)', v_materia_id, v_assunto_id;
  end if;

  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 22) <> 1 then
    raise exception 'Precondicao falhou: nao ha exatamente 1 unidade pedagogica para o conteudo 22 — decisao aprovada foi manter unidade unica';
  end if;

  if not exists (select 1 from public.unidades_pedagogicas where id = '3f215008-367b-4890-9588-525980baefc1' and curso_conteudo_id = 22 and ordem = 1 and ativa)
  then
    raise exception 'Precondicao falhou: a unidade oficial nao confere (id/ordem/conteudo/ativa) — curadoria_unidades_classes_de_palavras.sql precisa ter sido aplicado antes';
  end if;

  select count(*) into v_total_candidatas
  from public.questoes q
  join public.curso_conteudos cc on cc.id = 22
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where q.ativa = true
    and q.materia_id = cm.materia_id
    and (cc.assunto_id is null or q.assunto_id = cc.assunto_id);

  if v_total_candidatas <> 21 then
    raise exception 'Precondicao falhou: total de candidatas ativas = % (esperado 21)', v_total_candidatas;
  end if;

  select count(*) into v_classificacoes_previas
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 22
    and qup.questao_id in (select questao_id from _mapa);

  if v_classificacoes_previas <> 0 then
    raise exception 'Precondicao falhou: ja existe classificacao previa inesperada (% linhas) para questao(oes) do mapa', v_classificacoes_previas;
  end if;

  select ativa into v_71_ativa from public.questoes where id = 71;
  select ativa into v_325_ativa from public.questoes where id = 325;
  select ativa into v_683_ativa from public.questoes where id = 683;
  select ativa into v_878_ativa from public.questoes where id = 878;
  if v_71_ativa is distinct from true then
    raise exception 'Precondicao falhou: Q71 nao esta ativa=true';
  end if;
  if v_325_ativa is distinct from true then
    raise exception 'Precondicao falhou: Q325 nao esta ativa=true';
  end if;
  if v_683_ativa is distinct from true then
    raise exception 'Precondicao falhou: Q683 nao esta ativa=true';
  end if;
  if v_878_ativa is distinct from true then
    raise exception 'Precondicao falhou: Q878 nao esta ativa=true';
  end if;

  if exists (select 1 from public.questao_unidades_pedagogicas where questao_id in (71, 325, 683, 878)) then
    raise exception 'Precondicao falhou: Q71/Q325/Q683/Q878 ja possuem vinculo pedagogico previo — exclusao intencional pressupoe ausencia de vinculo';
  end if;

  if not exists (select 1 from public.curso_conteudos where id = 20) then
    raise exception 'Precondicao falhou: curso_conteudos 20 (sobreposicao de texto-base Ortografia) nao existe mais — verificar integridade';
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
  where not (q.ativa = true and q.materia_id = 6 and q.assunto_id = 47);

  if v_invalidas <> 0 then
    raise exception 'Mapa invalido: % linha(s) apontam para questao que nao esta ativa=true/materia_id=6/assunto_id=47', v_invalidas;
  end if;

  select count(*) into v_distintas from (select distinct questao_id from _mapa) x;
  if v_distintas <> 17 then
    raise exception 'Mapa invalido: cobre % questoes distintas (esperado 17)', v_distintas;
  end if;

  select count(*) into v_contem_excluidas from _mapa where questao_id in (71, 325, 683, 878);
  if v_contem_excluidas <> 0 then
    raise exception 'Mapa invalido: contem questao(oes) excluida(s) intencionalmente (71/325/683/878) que nao deveriam ser classificadas';
  end if;

  select count(*) into v_fora_do_candidato
  from _mapa m
  where not exists (
    select 1
    from public.questoes q
    join public.curso_conteudos cc on cc.id = 22
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
  where m.unidade_pedagogica_id not in (select id from public.unidades_pedagogicas where curso_conteudo_id = 22);
  if v_unidade_fora <> 0 then
    raise exception 'Mapa invalido: % linha(s) referenciam unidade pedagogica fora do conteudo 22', v_unidade_fora;
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
  v_71_permanece boolean;
  v_325_permanece boolean;
  v_683_permanece boolean;
  v_878_permanece boolean;
  v_71_ativa_depois boolean;
  v_325_ativa_depois boolean;
  v_683_ativa_depois boolean;
  v_878_ativa_depois boolean;
begin
  select count(*) into v_total_vinculos
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 22;
  if v_total_vinculos <> 17 then
    raise exception 'Pos-condicao falhou: total_vinculos=% (esperado 17)', v_total_vinculos;
  end if;

  select count(distinct qup.questao_id) into v_questoes_classificadas
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 22;
  if v_questoes_classificadas <> 17 then
    raise exception 'Pos-condicao falhou: questoes_classificadas=% (esperado 17)', v_questoes_classificadas;
  end if;

  select count(*) into v_fora_do_mapa
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 22
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
    where u.curso_conteudo_id = 22
    group by qup.questao_id
    having count(*) > 1
  ) x;
  if v_multiunidade is not null then
    raise exception 'Pos-condicao falhou: multiunidade=% (esperado nenhuma — unidade unica)', v_multiunidade;
  end if;

  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 22) <> 1 then
    raise exception 'Pos-condicao falhou: quantidade de unidades do conteudo 22 != 1';
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
  if (select count(*) from public.questao_unidades_pedagogicas) <> (select total_vinculos from _snapshot_antes) + 17 then
    raise exception 'Pos-condicao falhou: total de vinculos nao cresceu exatamente 17';
  end if;

  -- Pos-condicao extra: artigos_esperados deve ser NULL.
  select artigos_esperados into v_artigos_esperados
  from public.unidades_pedagogicas
  where id = '3f215008-367b-4890-9588-525980baefc1';
  if v_artigos_esperados is not null then
    raise exception 'Pos-condicao falhou: artigos_esperados=% (esperado NULL)', v_artigos_esperados;
  end if;

  -- Pos-condicao extra: Q71/Q325/Q683/Q878 permanecem SEM vinculo, ATIVAS e INTACTAS.
  select not exists (select 1 from public.questao_unidades_pedagogicas where questao_id = 71) into v_71_permanece;
  select not exists (select 1 from public.questao_unidades_pedagogicas where questao_id = 325) into v_325_permanece;
  select not exists (select 1 from public.questao_unidades_pedagogicas where questao_id = 683) into v_683_permanece;
  select not exists (select 1 from public.questao_unidades_pedagogicas where questao_id = 878) into v_878_permanece;
  if not v_71_permanece then
    raise exception 'Pos-condicao falhou: Q71 recebeu vinculo pedagogico indevido';
  end if;
  if not v_325_permanece then
    raise exception 'Pos-condicao falhou: Q325 recebeu vinculo pedagogico indevido';
  end if;
  if not v_683_permanece then
    raise exception 'Pos-condicao falhou: Q683 recebeu vinculo pedagogico indevido';
  end if;
  if not v_878_permanece then
    raise exception 'Pos-condicao falhou: Q878 recebeu vinculo pedagogico indevido';
  end if;

  select ativa into v_71_ativa_depois from public.questoes where id = 71;
  select ativa into v_325_ativa_depois from public.questoes where id = 325;
  select ativa into v_683_ativa_depois from public.questoes where id = 683;
  select ativa into v_878_ativa_depois from public.questoes where id = 878;
  if v_71_ativa_depois is distinct from true or v_325_ativa_depois is distinct from true
     or v_683_ativa_depois is distinct from true or v_878_ativa_depois is distinct from true then
    raise exception 'Pos-condicao falhou: alguma das questoes excluidas intencionalmente nao esta mais ativa=true';
  end if;

  -- Pos-condicao extra: conteudo 20 (sobreposicao de texto-base) permanece intocado.
  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 20) <> (select unidades_20 from _snapshot_sobrepostos_antes) then
    raise exception 'Pos-condicao falhou: quantidade de unidades do conteudo 20 mudou — nao deveria ser tocado';
  end if;
  if (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where u.curso_conteudo_id = 20) <> (select vinculos_20 from _snapshot_sobrepostos_antes) then
    raise exception 'Pos-condicao falhou: quantidade de vinculos do conteudo 20 mudou — nao deveria ser tocado';
  end if;

  raise notice 'Pos-condicoes OK: 17 questoes classificadas / 17 vinculos / 0 multiunidade / artigos_esperados NULL / Q71,Q325,Q683,Q878 ativas/intactas/sem vinculo / conteudo 20 intocado.';
end $$;

commit;
