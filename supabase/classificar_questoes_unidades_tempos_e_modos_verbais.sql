-- Aplicação REAL do mapa aprovado em
-- config/tempos_e_modos_verbais.mapa.json,
-- validado pelo harness
-- classificar_questoes_unidades_tempos_e_modos_verbais_teste_rollback.sql
-- (tudo_ok = true confirmado antes de rodar este arquivo).
--
-- Quinto conteudo de Lingua Portuguesa da fila. artigos_esperados
-- desta unidade e NULL (metodologia nao juridica). 2 exclusoes
-- intencionais: Q693 (FORA_DE_ESCOPO_MORFOLOGIA_LOCUCAO_VERBAL — cobra
-- classificacao morfologica de locucao verbal, nao tempo/modo) e Q893
-- (QUESTAO_HIBRIDA_MULTICONTEUDO — mistura tempos/modos verbais com
-- formacao de palavras e fonemas/digrafos; permanece registrada como
-- evidencia real de incidencia, mas sem vinculo de pratica especifica
-- desta unidade).
--
-- ATENCAO: sobreposicao tematica (nao duplicata) com os conteudos ja
-- concluidos 20 (Ortografia), 26 (Acentuação gráfica) e 34 (Fonemas e
-- dígrafos) — Q894 reaproveita o artigo "RS Seguro" ja usado la; Q893
-- (nao vinculada) reaproveita o mesmo fenomeno de digrafo (lh+an em
-- "trabalhando") ja classificado no conteudo 34. Os conteudos 20, 22,
-- 26 e 34 nao sao tocados por este arquivo.
--
-- Diferença deste arquivo para o harness: termina em COMMIT, e cada
-- precondição/pós-condição usa RAISE EXCEPTION (não apenas relatório
-- booleano) — qualquer divergência aborta a transação inteira antes de
-- confirmar. Usa a mesma RPC administrativa oficial
-- classificar_questao_unidade_admin (nenhum INSERT direto em
-- questao_unidades_pedagogicas, nenhum DELETE, nenhuma alteração em
-- questoes/alternativas/unidades_pedagogicas/aulas/histórico). Segue o
-- mesmo padrão de
-- supabase/classificar_questoes_unidades_fonemas_e_digrafos.sql.
--
-- PRÉ-REQUISITO: supabase/curadoria_unidades_tempos_e_modos_verbais.sql
-- precisa já ter sido aplicado (reaproveita unidade placeholder já
-- existente d54fb675-78a8-4efb-a99a-44359555d28f — não cria unidade
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
  (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where u.curso_conteudo_id = 20) as vinculos_20,
  (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 22) as unidades_22,
  (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where u.curso_conteudo_id = 22) as vinculos_22,
  (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 26) as unidades_26,
  (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where u.curso_conteudo_id = 26) as vinculos_26,
  (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 34) as unidades_34,
  (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where u.curso_conteudo_id = 34) as vinculos_34;

create temporary table _mapa (
  questao_id bigint,
  unidade_pedagogica_id uuid,
  ordem_unidade int,
  confianca text
) on commit drop;

insert into _mapa (questao_id, unidade_pedagogica_id, ordem_unidade, confianca) values
  (240, 'd54fb675-78a8-4efb-a99a-44359555d28f'::uuid, 1, 'alta'),
  (241, 'd54fb675-78a8-4efb-a99a-44359555d28f', 1, 'alta'),
  (242, 'd54fb675-78a8-4efb-a99a-44359555d28f', 1, 'alta'),
  (692, 'd54fb675-78a8-4efb-a99a-44359555d28f', 1, 'alta'),
  (763, 'd54fb675-78a8-4efb-a99a-44359555d28f', 1, 'alta'),
  (764, 'd54fb675-78a8-4efb-a99a-44359555d28f', 1, 'alta'),
  (765, 'd54fb675-78a8-4efb-a99a-44359555d28f', 1, 'alta'),
  (766, 'd54fb675-78a8-4efb-a99a-44359555d28f', 1, 'alta'),
  (767, 'd54fb675-78a8-4efb-a99a-44359555d28f', 1, 'alta'),
  (811, 'd54fb675-78a8-4efb-a99a-44359555d28f', 1, 'alta'),
  (894, 'd54fb675-78a8-4efb-a99a-44359555d28f', 1, 'alta');

-- Lock determinístico das linhas envolvidas antes de revalidar.
select id from public.unidades_pedagogicas
where curso_conteudo_id = 31
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
begin
  select cm.materia_id, cc.assunto_id into v_materia_id, v_assunto_id
  from public.curso_conteudos cc
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where cc.id = 31;

  if v_materia_id is null then
    raise exception 'Precondicao falhou: curso_conteudos 31 nao existe';
  end if;
  if v_materia_id is distinct from 6 or v_assunto_id is distinct from 54 then
    raise exception 'Precondicao falhou: conteudo 31 materia_id=% assunto_id=% (esperado 6/54)', v_materia_id, v_assunto_id;
  end if;

  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 31) <> 1 then
    raise exception 'Precondicao falhou: nao ha exatamente 1 unidade pedagogica para o conteudo 31 — decisao aprovada foi manter unidade unica';
  end if;

  if not exists (select 1 from public.unidades_pedagogicas where id = 'd54fb675-78a8-4efb-a99a-44359555d28f' and curso_conteudo_id = 31 and ordem = 1 and ativa)
  then
    raise exception 'Precondicao falhou: a unidade oficial nao confere (id/ordem/conteudo/ativa) — curadoria_unidades_tempos_e_modos_verbais.sql precisa ter sido aplicado antes';
  end if;

  select count(*) into v_total_candidatas
  from public.questoes q
  join public.curso_conteudos cc on cc.id = 31
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where q.ativa = true
    and q.materia_id = cm.materia_id
    and (cc.assunto_id is null or q.assunto_id = cc.assunto_id);

  if v_total_candidatas <> 13 then
    raise exception 'Precondicao falhou: total de candidatas ativas = % (esperado 13)', v_total_candidatas;
  end if;

  select count(*) into v_classificacoes_previas
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 31
    and qup.questao_id in (select questao_id from _mapa);

  if v_classificacoes_previas <> 0 then
    raise exception 'Precondicao falhou: ja existe classificacao previa inesperada (% linhas) para questao(oes) do mapa', v_classificacoes_previas;
  end if;

  if not exists (select 1 from public.curso_conteudos where id = 20) then
    raise exception 'Precondicao falhou: curso_conteudos 20 (sobreposicao tematica Ortografia) nao existe mais — verificar integridade';
  end if;
  if not exists (select 1 from public.curso_conteudos where id = 22) then
    raise exception 'Precondicao falhou: curso_conteudos 22 (Classes de palavras — possivel destino futuro de Q693) nao existe mais — verificar integridade';
  end if;
  if not exists (select 1 from public.curso_conteudos where id = 26) then
    raise exception 'Precondicao falhou: curso_conteudos 26 (Acentuação gráfica) nao existe mais — verificar integridade';
  end if;
  if not exists (select 1 from public.curso_conteudos where id = 34) then
    raise exception 'Precondicao falhou: curso_conteudos 34 (Fonemas e dígrafos) nao existe mais — verificar integridade';
  end if;
end $$;

-- Validação do mapa em si.
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
  where not (q.ativa = true and q.materia_id = 6 and q.assunto_id = 54);

  if v_invalidas <> 0 then
    raise exception 'Mapa invalido: % linha(s) apontam para questao que nao esta ativa=true/materia_id=6/assunto_id=54', v_invalidas;
  end if;

  select count(*) into v_distintas from (select distinct questao_id from _mapa) x;
  if v_distintas <> 11 then
    raise exception 'Mapa invalido: cobre % questoes distintas (esperado 11)', v_distintas;
  end if;

  select exists (select 1 from _mapa where questao_id in (693, 893)) into v_contem_excluida;
  if coalesce(v_contem_excluida, false) then
    raise exception 'Mapa invalido: contem questao(oes) que devem permanecer excluidas (693 FORA_DE_ESCOPO_MORFOLOGIA_LOCUCAO_VERBAL, 893 QUESTAO_HIBRIDA_MULTICONTEUDO)';
  end if;

  select count(*) into v_fora_do_candidato
  from _mapa m
  where not exists (
    select 1
    from public.questoes q
    join public.curso_conteudos cc on cc.id = 31
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where q.id = m.questao_id
      and q.ativa = true
      and q.materia_id = cm.materia_id
      and (cc.assunto_id is null or q.assunto_id = cc.assunto_id)
  );
  if v_fora_do_candidato <> 0 then
    raise exception 'Mapa invalido: % linha(s) fora do conjunto candidato de 13 ativas', v_fora_do_candidato;
  end if;

  select count(*) into v_unidade_fora
  from _mapa m
  where m.unidade_pedagogica_id not in (select id from public.unidades_pedagogicas where curso_conteudo_id = 31);
  if v_unidade_fora <> 0 then
    raise exception 'Mapa invalido: % linha(s) referenciam unidade pedagogica fora do conteudo 31', v_unidade_fora;
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
  v_693_classificada boolean;
  v_893_classificada boolean;
begin
  select count(*) into v_total_vinculos
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 31;
  if v_total_vinculos <> 11 then
    raise exception 'Pos-condicao falhou: total_vinculos=% (esperado 11)', v_total_vinculos;
  end if;

  select count(distinct qup.questao_id) into v_questoes_classificadas
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 31;
  if v_questoes_classificadas <> 11 then
    raise exception 'Pos-condicao falhou: questoes_classificadas=% (esperado 11)', v_questoes_classificadas;
  end if;

  select count(*) into v_fora_do_mapa
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 31
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
    where u.curso_conteudo_id = 31
    group by qup.questao_id
    having count(*) > 1
  ) x;
  if v_multiunidade is not null then
    raise exception 'Pos-condicao falhou: multiunidade=% (esperado nenhuma — unidade unica)', v_multiunidade;
  end if;

  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 31) <> 1 then
    raise exception 'Pos-condicao falhou: quantidade de unidades do conteudo 31 != 1';
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
  if (select count(*) from public.questao_unidades_pedagogicas) <> (select total_vinculos from _snapshot_antes) + 11 then
    raise exception 'Pos-condicao falhou: total de vinculos nao cresceu exatamente 11';
  end if;

  -- Pos-condicao extra: artigos_esperados deve ser NULL.
  select artigos_esperados into v_artigos_esperados
  from public.unidades_pedagogicas
  where id = 'd54fb675-78a8-4efb-a99a-44359555d28f';
  if v_artigos_esperados is not null then
    raise exception 'Pos-condicao falhou: artigos_esperados=% (esperado NULL)', v_artigos_esperados;
  end if;

  -- Pos-condicao extra: Q693 e Q893 (exclusoes intencionais) permanecem SEM vinculo neste conteudo.
  select exists (
    select 1 from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where u.curso_conteudo_id = 31 and qup.questao_id = 693
  ) into v_693_classificada;
  if coalesce(v_693_classificada, false) then
    raise exception 'Pos-condicao falhou: questao 693 (FORA_DE_ESCOPO_MORFOLOGIA_LOCUCAO_VERBAL) foi classificada indevidamente neste conteudo';
  end if;

  select exists (
    select 1 from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where u.curso_conteudo_id = 31 and qup.questao_id = 893
  ) into v_893_classificada;
  if coalesce(v_893_classificada, false) then
    raise exception 'Pos-condicao falhou: questao 893 (QUESTAO_HIBRIDA_MULTICONTEUDO) foi classificada indevidamente neste conteudo';
  end if;

  if not exists (select 1 from public.questoes where id = 693 and ativa = true) then
    raise exception 'Pos-condicao falhou: questao 693 nao esta mais ativa=true — nao deveria ter sido alterada';
  end if;
  if not exists (select 1 from public.questoes where id = 893 and ativa = true) then
    raise exception 'Pos-condicao falhou: questao 893 nao esta mais ativa=true — nao deveria ter sido alterada';
  end if;

  -- Pos-condicao extra: conteudos 20, 22, 26 e 34 (sobreposicao tematica) permanecem intocados.
  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 20) <> (select unidades_20 from _snapshot_sobrepostos_antes) then
    raise exception 'Pos-condicao falhou: quantidade de unidades do conteudo 20 mudou — nao deveria ser tocado';
  end if;
  if (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where u.curso_conteudo_id = 20) <> (select vinculos_20 from _snapshot_sobrepostos_antes) then
    raise exception 'Pos-condicao falhou: quantidade de vinculos do conteudo 20 mudou — nao deveria ser tocado';
  end if;
  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 22) <> (select unidades_22 from _snapshot_sobrepostos_antes) then
    raise exception 'Pos-condicao falhou: quantidade de unidades do conteudo 22 mudou — nao deveria ser tocado';
  end if;
  if (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where u.curso_conteudo_id = 22) <> (select vinculos_22 from _snapshot_sobrepostos_antes) then
    raise exception 'Pos-condicao falhou: quantidade de vinculos do conteudo 22 mudou — nao deveria ser tocado';
  end if;
  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 26) <> (select unidades_26 from _snapshot_sobrepostos_antes) then
    raise exception 'Pos-condicao falhou: quantidade de unidades do conteudo 26 mudou — nao deveria ser tocado';
  end if;
  if (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where u.curso_conteudo_id = 26) <> (select vinculos_26 from _snapshot_sobrepostos_antes) then
    raise exception 'Pos-condicao falhou: quantidade de vinculos do conteudo 26 mudou — nao deveria ser tocado';
  end if;
  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 34) <> (select unidades_34 from _snapshot_sobrepostos_antes) then
    raise exception 'Pos-condicao falhou: quantidade de unidades do conteudo 34 mudou — nao deveria ser tocado';
  end if;
  if (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where u.curso_conteudo_id = 34) <> (select vinculos_34 from _snapshot_sobrepostos_antes) then
    raise exception 'Pos-condicao falhou: quantidade de vinculos do conteudo 34 mudou — nao deveria ser tocado';
  end if;

  raise notice 'Pos-condicoes OK: 11 questoes classificadas / 11 vinculos / 0 multiunidade / artigos_esperados NULL / Q693 e Q893 excluidas e intactas / conteudos 20, 22, 26 e 34 intocados.';
end $$;

commit;
