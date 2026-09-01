-- Aplicação REAL do mapa aprovado em config/tabela_verdade.mapa.json,
-- validado pelo harness
-- classificar_questoes_unidades_tabela_verdade_teste_rollback.sql
-- (tudo_ok = true confirmado antes de rodar este arquivo).
--
-- Terceiro conteúdo do bloco final de Raciocínio Lógico/Matemática, após
-- Negação de proposições (ordem 83) e Proposições e conectivos (ordem
-- 84). artigos_esperados desta unidade é NULL (metodologia não
-- jurídica). 0 exclusões — as 2 questões ativas LIVE foram classificadas
-- (2 rows REAL Fundatec: Q75, Q89).
--
-- DIVERGÊNCIA FILA×LIVE (cronologia, não erro): a fila histórica
-- (ordem-curadoria.json, ordem 85) documenta questoes_ativas=3, retrato
-- de antes do saneamento taxonômico dedicado da Q314 (commit eee1f6b,
-- assunto_id 38 -> 36, reclassificada para Proposições e conectivos por
-- não testar nenhuma habilidade de tabela-verdade). O estado LIVE nesta
-- curadoria final é 2 candidatas. A Q89 foi previamente saneada por
-- fidelidade estrutural (commit 1eb3fa9) — este apply classifica o
-- conteúdo JÁ SANEADO, sem alterá-lo.
--
-- Diferenca deste arquivo para o harness: termina em COMMIT, e cada
-- precondicao/pos-condicao usa RAISE EXCEPTION (nao apenas relatorio
-- booleano) — qualquer divergencia aborta a transacao inteira antes de
-- confirmar. Usa a mesma RPC administrativa oficial
-- classificar_questao_unidade_admin (nenhum INSERT direto em
-- questao_unidades_pedagogicas, nenhum DELETE, nenhuma alteracao em
-- questoes/alternativas/unidades_pedagogicas/aulas/historico).
--
-- PRE-REQUISITO: supabase/curadoria_unidades_tabela_verdade.sql ja foi
-- aplicado (reaproveita unidade placeholder ja existente
-- c2c7fffa-910f-4342-9e43-f7dad85ce8ab — nao cria unidade nova).

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
  (75, 'c2c7fffa-910f-4342-9e43-f7dad85ce8ab'::uuid, 1, 'alta'),
  (89, 'c2c7fffa-910f-4342-9e43-f7dad85ce8ab'::uuid, 1, 'alta');

-- Lock deterministico das linhas envolvidas antes de revalidar.
select id from public.unidades_pedagogicas
where curso_conteudo_id = 2
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
  v_assunto_314 bigint;
  v_vinculos_314_aqui int;
begin
  select cm.materia_id, cc.assunto_id into v_materia_id, v_assunto_id
  from public.curso_conteudos cc
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where cc.id = 2;

  if v_materia_id is null then
    raise exception 'Precondicao falhou: curso_conteudos 2 nao existe';
  end if;
  if v_materia_id is distinct from 18 or v_assunto_id is distinct from 38 then
    raise exception 'Precondicao falhou: conteudo 2 materia_id=% assunto_id=% (esperado 18/38)', v_materia_id, v_assunto_id;
  end if;

  if not exists (select 1 from public.unidades_pedagogicas where id = 'c2c7fffa-910f-4342-9e43-f7dad85ce8ab' and curso_conteudo_id = 2 and ordem = 1 and ativa)
  then
    raise exception 'Precondicao falhou: a unidade oficial nao confere (id/ordem/conteudo/ativa) — curadoria_unidades_tabela_verdade.sql precisa ter sido aplicado antes';
  end if;

  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 2) <> 1 then
    raise exception 'Precondicao falhou: nao ha exatamente 1 unidade pedagogica para o conteudo 2 — decisao aprovada foi manter unidade unica';
  end if;

  select count(*) into v_total_candidatas
  from public.questoes q
  join public.curso_conteudos cc on cc.id = 2
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where q.ativa = true
    and q.materia_id = cm.materia_id
    and (cc.assunto_id is null or q.assunto_id = cc.assunto_id);

  if v_total_candidatas <> 2 then
    raise exception 'Precondicao falhou: total de candidatas ativas LIVE = % (esperado 2 — apos saneamento taxonomico da Q314 no commit eee1f6b)', v_total_candidatas;
  end if;

  select count(*) into v_classificacoes_previas
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 2
    and qup.questao_id in (select questao_id from _mapa);

  if v_classificacoes_previas <> 0 then
    raise exception 'Precondicao falhou: ja existe classificacao previa inesperada (% linhas) para questao(oes) do mapa', v_classificacoes_previas;
  end if;

  -- Q314 (reclassificada para Proposicoes e conectivos no commit
  -- eee1f6b) NAO faz parte desta ordem: precisa continuar com
  -- assunto_id=36 (nao 38) e sem nenhum vinculo neste conteudo.
  select assunto_id into v_assunto_314 from public.questoes where id = 314;
  if v_assunto_314 is distinct from 36 then
    raise exception 'Precondicao falhou: Q314 assunto_id=% (esperado 36 — ja deveria estar reclassificada antes desta curadoria)', v_assunto_314;
  end if;

  select count(*) into v_vinculos_314_aqui
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 2 and qup.questao_id = 314;
  if v_vinculos_314_aqui <> 0 then
    raise exception 'Precondicao falhou: Q314 possui vinculo neste conteudo (Tabela-verdade), nao deveria';
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
  where not (q.ativa = true and q.materia_id = 18 and q.assunto_id = 38);

  if v_invalidas <> 0 then
    raise exception 'Mapa invalido: % linha(s) apontam para questao que nao esta ativa=true/materia_id=18/assunto_id=38', v_invalidas;
  end if;

  select count(*) into v_distintas from (select distinct questao_id from _mapa) x;
  if v_distintas <> 2 then
    raise exception 'Mapa invalido: cobre % questoes distintas (esperado 2)', v_distintas;
  end if;

  select count(*) into v_fora_do_candidato
  from _mapa m
  where not exists (
    select 1
    from public.questoes q
    join public.curso_conteudos cc on cc.id = 2
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where q.id = m.questao_id
      and q.ativa = true
      and q.materia_id = cm.materia_id
      and (cc.assunto_id is null or q.assunto_id = cc.assunto_id)
  );
  if v_fora_do_candidato <> 0 then
    raise exception 'Mapa invalido: % linha(s) fora do conjunto candidato de 2 ativas', v_fora_do_candidato;
  end if;

  select count(*) into v_unidade_fora
  from _mapa m
  where m.unidade_pedagogica_id not in (select id from public.unidades_pedagogicas where curso_conteudo_id = 2);
  if v_unidade_fora <> 0 then
    raise exception 'Mapa invalido: % linha(s) referenciam unidade pedagogica fora do conteudo 2', v_unidade_fora;
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
  v_assunto_314 bigint;
  v_vinculos_314_conteudo2 int;
  v_vinculos_314_conteudo1 int;
  v_q89_ok boolean;
begin
  select count(*) into v_total_vinculos
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 2;
  if v_total_vinculos <> 2 then
    raise exception 'Pos-condicao falhou: total_vinculos=% (esperado 2)', v_total_vinculos;
  end if;

  select count(distinct qup.questao_id) into v_questoes_classificadas
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 2;
  if v_questoes_classificadas <> 2 then
    raise exception 'Pos-condicao falhou: questoes_classificadas=% (esperado 2)', v_questoes_classificadas;
  end if;

  select count(*) into v_fora_do_mapa
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 2
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
    where u.curso_conteudo_id = 2
    group by qup.questao_id
    having count(*) > 1
  ) x;
  if v_multiunidade is not null then
    raise exception 'Pos-condicao falhou: multiunidade=% (esperado nenhuma — unidade unica)', v_multiunidade;
  end if;

  -- Pos-condicao extra: Q314 (ja reclassificada no commit eee1f6b)
  -- continua fora deste conteudo, com assunto_id=36 intacto e seu 1
  -- vinculo em Proposicoes e conectivos (conteudo 1) preservado — este
  -- arquivo nao a toca.
  select assunto_id into v_assunto_314 from public.questoes where id = 314;
  if v_assunto_314 is distinct from 36 then
    raise exception 'Pos-condicao falhou: assunto_id da Q314 foi alterado indevidamente (%), esperado 36', v_assunto_314;
  end if;

  select count(*) into v_vinculos_314_conteudo2
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 2 and qup.questao_id = 314;
  if v_vinculos_314_conteudo2 <> 0 then
    raise exception 'Pos-condicao falhou: Q314 ganhou vinculo neste conteudo (Tabela-verdade), nao deveria';
  end if;

  select count(*) into v_vinculos_314_conteudo1
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 1 and qup.questao_id = 314;
  if v_vinculos_314_conteudo1 <> 1 then
    raise exception 'Pos-condicao falhou: Q314 deveria manter exatamente 1 vinculo em Proposicoes e conectivos (conteudo 1), atual=%', v_vinculos_314_conteudo1;
  end if;

  -- Pos-condicao extra: o saneamento de fidelidade da Q89 (commit
  -- 1eb3fa9) precisa continuar intacto — este arquivo nao reescreve
  -- enunciado/explicacao.
  select (position('| 2 | V | V | F | F | V | F | ? |' in enunciado) > 0
      and position('| 4 | V | F | F | V | V | F | ? |' in enunciado) > 0
      and position('| 6 | F | V | F | F | V | F | ? |' in enunciado) > 0
      and position('| 8 | F | F | F | V | F | F | ? |' in enunciado) > 0
      and position('NOTA DE SANEAMENTO' in explicacao) > 0)
    into v_q89_ok
  from public.questoes where id = 89;
  if not coalesce(v_q89_ok, false) then
    raise exception 'Pos-condicao falhou: o saneamento de fidelidade da Q89 (commit 1eb3fa9) nao esta mais intacto';
  end if;

  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 2) <> 1 then
    raise exception 'Pos-condicao falhou: quantidade de unidades do conteudo 2 != 1';
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
  if (select count(*) from public.questao_unidades_pedagogicas) <> (select total_vinculos from _snapshot_antes) + 2 then
    raise exception 'Pos-condicao falhou: total de vinculos nao cresceu exatamente 2';
  end if;

  -- Pos-condicao extra: artigos_esperados deve ser NULL.
  select artigos_esperados into v_artigos_esperados
  from public.unidades_pedagogicas
  where id = 'c2c7fffa-910f-4342-9e43-f7dad85ce8ab';
  if v_artigos_esperados is not null then
    raise exception 'Pos-condicao falhou: artigos_esperados=% (esperado NULL)', v_artigos_esperados;
  end if;

  raise notice 'Pos-condicoes OK: 2 questoes classificadas (Q75/Q89) / 2 vinculos / 0 multiunidade / artigos_esperados NULL / Q314 intocada (assunto_id=36, 1 vinculo em Proposicoes e conectivos) / saneamento de fidelidade da Q89 intacto.';
end $$;

commit;
