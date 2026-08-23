-- Aplicação REAL do mapa aprovado em
-- config/significacao_das_palavras.mapa.json,
-- validado pelo harness
-- classificar_questoes_unidades_significacao_das_palavras_teste_rollback.sql
-- (tudo_ok = true confirmado antes de rodar este arquivo).
--
-- Décimo segundo conteúdo de Língua Portuguesa da fila. artigos_esperados
-- desta unidade é NULL (metodologia não jurídica). 1 exclusão intencional
-- (Q68, QUESTAO_HIBRIDA_MULTICONTEUDO) — as outras 3 questões ativas
-- (Q122, Q308, Q317) foram classificadas.
--
-- Q68 e Q122 foram saneadas em fidelidade em operações próprias, já
-- commitadas separadamente ANTES desta curadoria (d6901ee e 1d8ad27,
-- respectivamente). Este arquivo NÃO altera enunciado/explicacao/
-- alternativas/gabarito de nenhuma questão — contém pós-condições extras
-- para confirmar que esses dois saneamentos permanecem intactos após o
-- apply da classificação.
--
-- Diferença deste arquivo para o harness: termina em COMMIT, e cada
-- precondição/pós-condição usa RAISE EXCEPTION (não apenas relatório
-- booleano) — qualquer divergência aborta a transação inteira antes de
-- confirmar. Usa a mesma RPC administrativa oficial
-- classificar_questao_unidade_admin (nenhum INSERT direto em
-- questao_unidades_pedagogicas, nenhum DELETE, nenhuma alteração em
-- questoes/alternativas/unidades_pedagogicas/aulas/histórico). Segue o
-- mesmo padrão de supabase/classificar_questoes_unidades_concordancia_verbal.sql.
--
-- PRÉ-REQUISITO: supabase/curadoria_unidades_significacao_das_palavras.sql
-- precisa já ter sido aplicado (reaproveita unidade placeholder já
-- existente 290650b5-0f55-49e1-871e-932003447e41 — não cria unidade
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

-- Snapshot dos saneamentos ja concluidos (Q68 e Q122), para confirmar nas
-- pos-condicoes que este apply nao os desfaz.
create temporary table _snapshot_saneamentos on commit drop as
select
  (select enunciado from public.questoes where id = 68)  as q68_enunciado,
  (select explicacao from public.questoes where id = 68) as q68_explicacao,
  (select enunciado from public.questoes where id = 122)  as q122_enunciado,
  (select explicacao from public.questoes where id = 122) as q122_explicacao;

create temporary table _mapa (
  questao_id bigint,
  unidade_pedagogica_id uuid,
  ordem_unidade int,
  confianca text
) on commit drop;

insert into _mapa (questao_id, unidade_pedagogica_id, ordem_unidade, confianca) values
  (122, '290650b5-0f55-49e1-871e-932003447e41'::uuid, 1, 'alta'),
  (308, '290650b5-0f55-49e1-871e-932003447e41', 1, 'alta'),
  (317, '290650b5-0f55-49e1-871e-932003447e41', 1, 'alta');

-- Lock determinístico das linhas envolvidas antes de revalidar.
select id from public.unidades_pedagogicas
where curso_conteudo_id = 23
order by id
for update;

select id from public.questoes
where id in (select distinct questao_id from _mapa) or id = 68
order by id
for update;

-- Revalidação de precondições — aborta a transação em qualquer divergência.
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
  where cc.id = 23;

  if v_materia_id is null then
    raise exception 'Precondicao falhou: curso_conteudos 23 nao existe';
  end if;
  if v_materia_id is distinct from 6 or v_assunto_id is distinct from 59 then
    raise exception 'Precondicao falhou: conteudo 23 materia_id=% assunto_id=% (esperado 6/59)', v_materia_id, v_assunto_id;
  end if;

  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 23) <> 1 then
    raise exception 'Precondicao falhou: nao ha exatamente 1 unidade pedagogica para o conteudo 23 — decisao aprovada foi manter unidade unica';
  end if;

  if not exists (select 1 from public.unidades_pedagogicas where id = '290650b5-0f55-49e1-871e-932003447e41' and curso_conteudo_id = 23 and ordem = 1 and ativa)
  then
    raise exception 'Precondicao falhou: a unidade oficial nao confere (id/ordem/conteudo/ativa) — curadoria_unidades_significacao_das_palavras.sql precisa ter sido aplicado antes';
  end if;

  select count(*) into v_total_candidatas
  from public.questoes q
  join public.curso_conteudos cc on cc.id = 23
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
  where u.curso_conteudo_id = 23
    and qup.questao_id in (select questao_id from _mapa);

  if v_classificacoes_previas <> 0 then
    raise exception 'Precondicao falhou: ja existe classificacao previa inesperada (% linhas) para questao(oes) do mapa', v_classificacoes_previas;
  end if;

  -- Q68 precisa estar ativa, no assunto correto, e sem nenhum vinculo — ela
  -- e a exclusao pedagogica intencional (QUESTAO_HIBRIDA_MULTICONTEUDO).
  if not exists (select 1 from public.questoes where id = 68 and ativa = true and assunto_id = 59) then
    raise exception 'Precondicao falhou: questao 68 nao esta ativa=true/assunto_id=59';
  end if;
  if exists (select 1 from public.questao_unidades_pedagogicas where questao_id = 68) then
    raise exception 'Precondicao falhou: questao 68 ja possui vinculo pedagogico (esperado: nenhum, ela e exclusao intencional)';
  end if;
  if position('[04]' in (select enunciado from public.questoes where id = 68)) = 0 then
    raise exception 'Precondicao falhou: saneamento da questao 68 (marcador [04]) nao esta presente antes do apply';
  end if;
  if position('[37]' in (select enunciado from public.questoes where id = 122)) = 0 then
    raise exception 'Precondicao falhou: saneamento da questao 122 (marcador [37]) nao esta presente antes do apply';
  end if;
end $$;

-- Validação do mapa em si.
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
  where not (q.ativa = true and q.materia_id = 6 and q.assunto_id = 59);

  if v_invalidas <> 0 then
    raise exception 'Mapa invalido: % linha(s) apontam para questao que nao esta ativa=true/materia_id=6/assunto_id=59', v_invalidas;
  end if;

  select count(*) into v_distintas from (select distinct questao_id from _mapa) x;
  if v_distintas <> 3 then
    raise exception 'Mapa invalido: cobre % questoes distintas (esperado 3)', v_distintas;
  end if;

  if exists (select 1 from _mapa where questao_id = 68) then
    raise exception 'Mapa invalido: questao 68 (exclusao pedagogica intencional) nao pode constar no mapa de vinculos';
  end if;

  select count(*) into v_fora_do_candidato
  from _mapa m
  where not exists (
    select 1
    from public.questoes q
    join public.curso_conteudos cc on cc.id = 23
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
  where m.unidade_pedagogica_id not in (select id from public.unidades_pedagogicas where curso_conteudo_id = 23);
  if v_unidade_fora <> 0 then
    raise exception 'Mapa invalido: % linha(s) referenciam unidade pedagogica fora do conteudo 23', v_unidade_fora;
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
begin
  select count(*) into v_total_vinculos
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 23;
  if v_total_vinculos <> 3 then
    raise exception 'Pos-condicao falhou: total_vinculos=% (esperado 3)', v_total_vinculos;
  end if;

  select count(distinct qup.questao_id) into v_questoes_classificadas
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 23;
  if v_questoes_classificadas <> 3 then
    raise exception 'Pos-condicao falhou: questoes_classificadas=% (esperado 3)', v_questoes_classificadas;
  end if;

  select count(*) into v_fora_do_mapa
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 23
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
    where u.curso_conteudo_id = 23
    group by qup.questao_id
    having count(*) > 1
  ) x;
  if v_multiunidade is not null then
    raise exception 'Pos-condicao falhou: multiunidade=% (esperado nenhuma — unidade unica)', v_multiunidade;
  end if;

  -- Q68 permanece sem nenhum vinculo (exclusao pedagogica intencional).
  if exists (select 1 from public.questao_unidades_pedagogicas where questao_id = 68) then
    raise exception 'Pos-condicao falhou: questao 68 recebeu vinculo pedagogico indevido (deveria permanecer exclusao intencional)';
  end if;

  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 23) <> 1 then
    raise exception 'Pos-condicao falhou: quantidade de unidades do conteudo 23 != 1';
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
  if (select count(*) from public.questao_unidades_pedagogicas) <> (select total_vinculos from _snapshot_antes) + 3 then
    raise exception 'Pos-condicao falhou: total de vinculos nao cresceu exatamente 3';
  end if;

  -- Pos-condicao extra: artigos_esperados deve ser NULL.
  select artigos_esperados into v_artigos_esperados
  from public.unidades_pedagogicas
  where id = '290650b5-0f55-49e1-871e-932003447e41';
  if v_artigos_esperados is not null then
    raise exception 'Pos-condicao falhou: artigos_esperados=% (esperado NULL)', v_artigos_esperados;
  end if;

  -- Pos-condicoes extras: os saneamentos de Q68 (d6901ee) e Q122 (1d8ad27)
  -- permanecem byte a byte identicos ao snapshot tirado antes deste apply.
  if (select enunciado from public.questoes where id = 68) is distinct from (select q68_enunciado from _snapshot_saneamentos) then
    raise exception 'Pos-condicao falhou: enunciado da questao 68 foi alterado por este apply (saneamento d6901ee desfeito)';
  end if;
  if (select explicacao from public.questoes where id = 68) is distinct from (select q68_explicacao from _snapshot_saneamentos) then
    raise exception 'Pos-condicao falhou: explicacao da questao 68 foi alterada por este apply (saneamento d6901ee desfeito)';
  end if;
  if (select enunciado from public.questoes where id = 122) is distinct from (select q122_enunciado from _snapshot_saneamentos) then
    raise exception 'Pos-condicao falhou: enunciado da questao 122 foi alterado por este apply (saneamento 1d8ad27 desfeito)';
  end if;
  if (select explicacao from public.questoes where id = 122) is distinct from (select q122_explicacao from _snapshot_saneamentos) then
    raise exception 'Pos-condicao falhou: explicacao da questao 122 foi alterada por este apply (saneamento 1d8ad27 desfeito)';
  end if;
  if not exists (select 1 from public.alternativas where questao_id = 68 and ordem = 3 and correta = true) then
    raise exception 'Pos-condicao falhou: gabarito da questao 68 nao e mais a alternativa de ordem 3 (C)';
  end if;
  if not exists (select 1 from public.alternativas where questao_id = 122 and ordem = 4 and correta = true) then
    raise exception 'Pos-condicao falhou: gabarito da questao 122 nao e mais a alternativa de ordem 4 (D)';
  end if;

  raise notice 'Pos-condicoes OK: 3 questoes classificadas / 3 vinculos / 0 multiunidade / artigos_esperados NULL / questao 68 permanece exclusao intencional sem vinculo / saneamentos de Q68 e Q122 preservados intactos.';
end $$;

commit;
