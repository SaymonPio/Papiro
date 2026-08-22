-- Aplicação REAL do mapa aprovado em
-- supabase/mapa_classificacao_nocoes_de_direitos_humanos.sql,
-- validado pelo harness
-- classificar_questoes_unidades_nocoes_de_direitos_humanos_teste_rollback.sql
-- (tudo_ok = true confirmado antes de rodar este arquivo, incluindo as
-- checagens de exclusao intencional de Q624/Q697).
--
-- Diferença deste arquivo para o harness: termina em COMMIT, e cada
-- precondição/pós-condição usa RAISE EXCEPTION (não apenas relatório
-- booleano) — qualquer divergência aborta a transação inteira antes de
-- confirmar. Usa a mesma RPC administrativa oficial
-- classificar_questao_unidade_admin (nenhum INSERT direto em
-- questao_unidades_pedagogicas, nenhum DELETE, nenhuma alteração em
-- questoes/alternativas/unidades_pedagogicas/aulas/histórico).
--
-- EXCLUSÃO INTENCIONAL POR FORA DE ESCOPO: das 7 questões ativas do
-- assunto, apenas 5 (168, 169, 170, 623, 696) são classificadas nesta
-- unidade. Q624 (Estatuto Nacional da Igualdade Racial, art. 52) e Q697
-- (Estatuto do Idoso, art. 34) são materialmente incompatíveis com
-- "Noções de Direitos Humanos" e permanecem propositalmente FORA do
-- mapa — não são desativadas, não têm assunto_id alterado, não são
-- movidas para outro curso_conteudo e não têm enunciado/gabarito
-- alterado nesta operação. Sinalizadas para saneamento futuro de
-- assunto_id. Segue o mesmo padrão de
-- supabase/classificar_questoes_unidades_pessoa_com_deficiencia.sql,
-- adaptado para exclusões intencionais no estilo de
-- supabase/classificar_questoes_unidades_lei_drogas.sql.
--
-- PRÉ-REQUISITO: supabase/curadoria_unidades_nocoes_de_direitos_humanos.sql
-- precisa já ter sido aplicado.
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
  (168, 'df8d133f-ddd6-4b85-941d-60b4d4967c06'::uuid, 1, 'alta'),
  (169, 'df8d133f-ddd6-4b85-941d-60b4d4967c06', 1, 'alta'),
  (170, 'df8d133f-ddd6-4b85-941d-60b4d4967c06', 1, 'alta'),
  (623, 'df8d133f-ddd6-4b85-941d-60b4d4967c06', 1, 'alta'),
  (696, 'df8d133f-ddd6-4b85-941d-60b4d4967c06', 1, 'alta');

-- Lock determinístico das linhas envolvidas antes de revalidar.
select id from public.unidades_pedagogicas
where curso_conteudo_id = 81
order by id
for update;

select id from public.questoes
where id in (select distinct questao_id from _mapa)
order by id
for update;

-- Revalidação de precondições — aborta a transação em qualquer divergência.
do $$
declare
  v_materia_id bigint;
  v_assunto_id bigint;
  v_total_candidatas int;
  v_classificacoes_previas int;
  v_excluida_ja_classificada int;
begin
  select cm.materia_id, cc.assunto_id into v_materia_id, v_assunto_id
  from public.curso_conteudos cc
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where cc.id = 81;

  if v_materia_id is null then
    raise exception 'Precondicao falhou: curso_conteudos 81 nao existe';
  end if;
  if v_materia_id is distinct from 11 or v_assunto_id is distinct from 89 then
    raise exception 'Precondicao falhou: conteudo 81 materia_id=% assunto_id=% (esperado 11/89)', v_materia_id, v_assunto_id;
  end if;

  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 81) <> 1 then
    raise exception 'Precondicao falhou: nao ha exatamente 1 unidade pedagogica para o conteudo 81 — decisao aprovada foi manter unidade unica';
  end if;

  if not exists (select 1 from public.unidades_pedagogicas where id = 'df8d133f-ddd6-4b85-941d-60b4d4967c06' and curso_conteudo_id = 81 and ordem = 1 and ativa)
  then
    raise exception 'Precondicao falhou: a unidade oficial nao confere (id/ordem/conteudo/ativa) — curadoria_unidades_nocoes_de_direitos_humanos.sql precisa ter sido aplicado antes';
  end if;

  select count(*) into v_total_candidatas
  from public.questoes q
  join public.curso_conteudos cc on cc.id = 81
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where q.ativa = true
    and q.materia_id = cm.materia_id
    and (cc.assunto_id is null or q.assunto_id = cc.assunto_id);

  if v_total_candidatas <> 7 then
    raise exception 'Precondicao falhou: total de candidatas ativas = % (esperado 7 — 5 classificadas + 2 exclusoes intencionais Q624/Q697)', v_total_candidatas;
  end if;

  select count(*) into v_classificacoes_previas
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 81
    and qup.questao_id in (select questao_id from _mapa);

  if v_classificacoes_previas <> 0 then
    raise exception 'Precondicao falhou: ja existe classificacao previa inesperada (% linhas) para questao(oes) do mapa', v_classificacoes_previas;
  end if;

  -- Confirma que as exclusoes intencionais (624, 697) nao possuem
  -- vinculo previo com este conteudo, e que estao ativas e intactas.
  select count(*) into v_excluida_ja_classificada
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 81
    and qup.questao_id in (624, 697);

  if v_excluida_ja_classificada <> 0 then
    raise exception 'Precondicao falhou: as questoes excluidas intencionalmente (624, 697) ja possuem vinculo com o conteudo 81 (%s linhas) — nao deveriam', v_excluida_ja_classificada;
  end if;

  if (select count(*) from public.questoes where id in (624, 697) and ativa = true) <> 2 then
    raise exception 'Precondicao falhou: Q624/Q697 precisam permanecer ativas=true (exclusao e apenas de classificacao pedagogica, nao de dado)';
  end if;
end $$;

-- Validação do mapa em si.
do $$
declare
  v_invalidas int;
  v_fora_do_candidato int;
  v_unidade_fora int;
  v_distintas int;
  v_contem_excluida int;
begin
  select count(*) into v_invalidas
  from _mapa m
  join public.questoes q on q.id = m.questao_id
  where not (q.ativa = true and q.materia_id = 11 and q.assunto_id = 89);

  if v_invalidas <> 0 then
    raise exception 'Mapa invalido: % linha(s) apontam para questao que nao esta ativa=true/materia_id=11/assunto_id=89', v_invalidas;
  end if;

  select count(*) into v_distintas from (select distinct questao_id from _mapa) x;
  if v_distintas <> 5 then
    raise exception 'Mapa invalido: cobre % questoes distintas (esperado 5)', v_distintas;
  end if;

  select count(*) into v_fora_do_candidato
  from _mapa m
  where not exists (
    select 1
    from public.questoes q
    join public.curso_conteudos cc on cc.id = 81
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where q.id = m.questao_id
      and q.ativa = true
      and q.materia_id = cm.materia_id
      and (cc.assunto_id is null or q.assunto_id = cc.assunto_id)
  );
  if v_fora_do_candidato <> 0 then
    raise exception 'Mapa invalido: % linha(s) fora do conjunto candidato de 7 ativas', v_fora_do_candidato;
  end if;

  select count(*) into v_unidade_fora
  from _mapa m
  where m.unidade_pedagogica_id not in (select id from public.unidades_pedagogicas where curso_conteudo_id = 81);
  if v_unidade_fora <> 0 then
    raise exception 'Mapa invalido: % linha(s) referenciam unidade pedagogica fora do conteudo 81', v_unidade_fora;
  end if;

  select count(*) into v_contem_excluida from _mapa where questao_id in (624, 697);
  if v_contem_excluida <> 0 then
    raise exception 'Mapa invalido: as questoes excluidas intencionalmente (624, 697) nao devem constar no mapa';
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
  v_excluida_classificada int;
begin
  select count(*) into v_total_vinculos
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 81;
  if v_total_vinculos <> 5 then
    raise exception 'Pos-condicao falhou: total_vinculos=% (esperado 5)', v_total_vinculos;
  end if;

  select count(distinct qup.questao_id) into v_questoes_classificadas
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 81;
  if v_questoes_classificadas <> 5 then
    raise exception 'Pos-condicao falhou: questoes_classificadas=% (esperado 5)', v_questoes_classificadas;
  end if;

  select count(*) into v_fora_do_mapa
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 81
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
    where u.curso_conteudo_id = 81
    group by qup.questao_id
    having count(*) > 1
  ) x;
  if v_multiunidade is not null then
    raise exception 'Pos-condicao falhou: multiunidade=% (esperado nenhuma — unidade unica)', v_multiunidade;
  end if;

  -- Confirma que as exclusoes intencionais continuam SEM vinculo com
  -- este conteudo apos a aplicacao (esta operacao nao classifica Q624/Q697).
  select count(*) into v_excluida_classificada
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 81
    and qup.questao_id in (624, 697);
  if v_excluida_classificada <> 0 then
    raise exception 'Pos-condicao falhou: as questoes excluidas intencionalmente (624, 697) foram classificadas indevidamente neste conteudo';
  end if;

  if (select count(*) from public.questoes where id in (624, 697) and ativa = true) <> 2 then
    raise exception 'Pos-condicao falhou: Q624/Q697 nao permaneceram ativas=true';
  end if;

  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 81) <> 1 then
    raise exception 'Pos-condicao falhou: quantidade de unidades do conteudo 81 != 1';
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
  if (select count(*) from public.questao_unidades_pedagogicas) <> (select total_vinculos from _snapshot_antes) + 5 then
    raise exception 'Pos-condicao falhou: total de vinculos nao cresceu exatamente 5';
  end if;

  raise notice 'Pos-condicoes OK: 5 questoes classificadas / 5 vinculos / 0 multiunidade / Q624 e Q697 permanecem excluidas intencionalmente, ativas e intactas.';
end $$;

commit;
