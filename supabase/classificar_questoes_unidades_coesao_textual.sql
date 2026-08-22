-- Aplicação REAL do mapa aprovado em
-- config/coesao_textual.mapa.json,
-- validado pelo harness
-- classificar_questoes_unidades_coesao_textual_teste_rollback.sql
-- (tudo_ok = true confirmado antes de rodar este arquivo).
--
-- Setimo conteudo de Lingua Portuguesa da fila. artigos_esperados desta
-- unidade e NULL (metodologia nao juridica). 0 exclusoes intencionais —
-- todas as 7 questoes ativas foram classificadas.
--
-- PRE-REQUISITO CRITICO: este conteudo depende de um saneamento
-- controlado ja concluido e commitado separadamente (commit 51e5851):
-- restauracao do texto-base de Q69/Q324/Q333, correcao da explicacao de
-- Q69, correcao do assunto_id de Q683 (47->55) e remocao do vinculo de
-- Q684 no conteudo 22 (duplicata de Q319). Este arquivo NAO reaplica
-- nenhum desses saneamentos — apenas classifica pedagogicamente o corpus
-- ja saneado. As pos-condicoes abaixo verificam explicitamente que o
-- estado saneado do conteudo 22 (20 candidatas live / 16 vinculos) e de
-- Q683/Q684/Q69 permanece intacto, sem reverter o saneamento.
--
-- Diferença deste arquivo para o harness: termina em COMMIT, e cada
-- precondição/pós-condição usa RAISE EXCEPTION (não apenas relatório
-- booleano) — qualquer divergência aborta a transação inteira antes de
-- confirmar. Usa a mesma RPC administrativa oficial
-- classificar_questao_unidade_admin (nenhum INSERT direto em
-- questao_unidades_pedagogicas, nenhum DELETE, nenhuma alteração em
-- questoes/alternativas/unidades_pedagogicas/aulas/histórico). Segue o
-- mesmo padrão de
-- supabase/classificar_questoes_unidades_estrutura_e_formacao_de_palavras.sql.
--
-- PRÉ-REQUISITO: supabase/curadoria_unidades_coesao_textual.sql
-- precisa já ter sido aplicado (reaproveita unidade placeholder já
-- existente 29a4bec1-2c3a-40f3-a86f-fa6bda25d04f — não cria unidade
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
  (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 31) as unidades_31,
  (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where u.curso_conteudo_id = 31) as vinculos_31,
  (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 33) as unidades_33,
  (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where u.curso_conteudo_id = 33) as vinculos_33,
  (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 34) as unidades_34,
  (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where u.curso_conteudo_id = 34) as vinculos_34;

create temporary table _mapa (
  questao_id bigint,
  unidade_pedagogica_id uuid,
  ordem_unidade int,
  confianca text
) on commit drop;

insert into _mapa (questao_id, unidade_pedagogica_id, ordem_unidade, confianca) values
  (69, '29a4bec1-2c3a-40f3-a86f-fa6bda25d04f'::uuid, 1, 'alta'),
  (275, '29a4bec1-2c3a-40f3-a86f-fa6bda25d04f', 1, 'alta'),
  (276, '29a4bec1-2c3a-40f3-a86f-fa6bda25d04f', 1, 'alta'),
  (319, '29a4bec1-2c3a-40f3-a86f-fa6bda25d04f', 1, 'alta'),
  (324, '29a4bec1-2c3a-40f3-a86f-fa6bda25d04f', 1, 'alta'),
  (333, '29a4bec1-2c3a-40f3-a86f-fa6bda25d04f', 1, 'alta'),
  (683, '29a4bec1-2c3a-40f3-a86f-fa6bda25d04f', 1, 'alta');

-- Lock determinístico das linhas envolvidas antes de revalidar.
select id from public.unidades_pedagogicas
where curso_conteudo_id = 13
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
  v_assunto_683 bigint;
  v_vinculos_684 int;
begin
  select cm.materia_id, cc.assunto_id into v_materia_id, v_assunto_id
  from public.curso_conteudos cc
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where cc.id = 13;

  if v_materia_id is null then
    raise exception 'Precondicao falhou: curso_conteudos 13 nao existe';
  end if;
  if v_materia_id is distinct from 6 or v_assunto_id is distinct from 55 then
    raise exception 'Precondicao falhou: conteudo 13 materia_id=% assunto_id=% (esperado 6/55)', v_materia_id, v_assunto_id;
  end if;

  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 13) <> 1 then
    raise exception 'Precondicao falhou: nao ha exatamente 1 unidade pedagogica para o conteudo 13 — decisao aprovada foi manter unidade unica';
  end if;

  if not exists (select 1 from public.unidades_pedagogicas where id = '29a4bec1-2c3a-40f3-a86f-fa6bda25d04f' and curso_conteudo_id = 13 and ordem = 1 and ativa)
  then
    raise exception 'Precondicao falhou: a unidade oficial nao confere (id/ordem/conteudo/ativa) — curadoria_unidades_coesao_textual.sql precisa ter sido aplicado antes';
  end if;

  select count(*) into v_total_candidatas
  from public.questoes q
  join public.curso_conteudos cc on cc.id = 13
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where q.ativa = true
    and q.materia_id = cm.materia_id
    and (cc.assunto_id is null or q.assunto_id = cc.assunto_id);

  if v_total_candidatas <> 7 then
    raise exception 'Precondicao falhou: total de candidatas ativas = % (esperado 7) — saneamento controlado (commit 51e5851) precisa ter sido aplicado antes (Q683 assunto_id=55)', v_total_candidatas;
  end if;

  select count(*) into v_classificacoes_previas
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 13
    and qup.questao_id in (select questao_id from _mapa);

  if v_classificacoes_previas <> 0 then
    raise exception 'Precondicao falhou: ja existe classificacao previa inesperada (% linhas) para questao(oes) do mapa', v_classificacoes_previas;
  end if;

  -- Confirma explicitamente que o saneamento controlado (commit 51e5851)
  -- permanece em vigor e nao sera reaplicado nem revertido por este apply.
  select assunto_id into v_assunto_683 from public.questoes where id = 683;
  if v_assunto_683 is distinct from 55 then
    raise exception 'Precondicao falhou: questao 683 tem assunto_id=% (esperado 55 — saneamento controlado precisa ter sido aplicado)', v_assunto_683;
  end if;

  select count(*) into v_vinculos_684 from public.questao_unidades_pedagogicas where questao_id = 684;
  if v_vinculos_684 <> 0 then
    raise exception 'Precondicao falhou: questao 684 possui % vinculo(s) — esperado 0 (deveria ter sido removido pelo saneamento controlado)', v_vinculos_684;
  end if;

  if not exists (select 1 from public.questoes where id = 69 and enunciado like '[01]%') then
    raise exception 'Precondicao falhou: questao 69 nao tem o texto-base restaurado com marcador [01] — saneamento controlado precisa ter sido aplicado antes';
  end if;

  if not exists (select 1 from public.curso_conteudos where id = 20) then
    raise exception 'Precondicao falhou: curso_conteudos 20 (Ortografia) nao existe mais — verificar integridade';
  end if;
  if not exists (select 1 from public.curso_conteudos where id = 22) then
    raise exception 'Precondicao falhou: curso_conteudos 22 (Classes de palavras) nao existe mais — verificar integridade';
  end if;
  if not exists (select 1 from public.curso_conteudos where id = 26) then
    raise exception 'Precondicao falhou: curso_conteudos 26 (Acentuação gráfica) nao existe mais — verificar integridade';
  end if;
  if not exists (select 1 from public.curso_conteudos where id = 31) then
    raise exception 'Precondicao falhou: curso_conteudos 31 (Tempos e modos verbais) nao existe mais — verificar integridade';
  end if;
  if not exists (select 1 from public.curso_conteudos where id = 33) then
    raise exception 'Precondicao falhou: curso_conteudos 33 (Estrutura e formação de palavras) nao existe mais — verificar integridade';
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
begin
  select count(*) into v_invalidas
  from _mapa m
  join public.questoes q on q.id = m.questao_id
  where not (q.ativa = true and q.materia_id = 6 and q.assunto_id = 55);

  if v_invalidas <> 0 then
    raise exception 'Mapa invalido: % linha(s) apontam para questao que nao esta ativa=true/materia_id=6/assunto_id=55', v_invalidas;
  end if;

  select count(*) into v_distintas from (select distinct questao_id from _mapa) x;
  if v_distintas <> 7 then
    raise exception 'Mapa invalido: cobre % questoes distintas (esperado 7)', v_distintas;
  end if;

  select count(*) into v_fora_do_candidato
  from _mapa m
  where not exists (
    select 1
    from public.questoes q
    join public.curso_conteudos cc on cc.id = 13
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
  where m.unidade_pedagogica_id not in (select id from public.unidades_pedagogicas where curso_conteudo_id = 13);
  if v_unidade_fora <> 0 then
    raise exception 'Mapa invalido: % linha(s) referenciam unidade pedagogica fora do conteudo 13', v_unidade_fora;
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
  v_assunto_683 bigint;
  v_vinculos_684 int;
  v_candidatas_22_live int;
  v_vinculos_22_live int;
begin
  select count(*) into v_total_vinculos
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 13;
  if v_total_vinculos <> 7 then
    raise exception 'Pos-condicao falhou: total_vinculos=% (esperado 7)', v_total_vinculos;
  end if;

  select count(distinct qup.questao_id) into v_questoes_classificadas
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 13;
  if v_questoes_classificadas <> 7 then
    raise exception 'Pos-condicao falhou: questoes_classificadas=% (esperado 7)', v_questoes_classificadas;
  end if;

  select count(*) into v_fora_do_mapa
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 13
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
    where u.curso_conteudo_id = 13
    group by qup.questao_id
    having count(*) > 1
  ) x;
  if v_multiunidade is not null then
    raise exception 'Pos-condicao falhou: multiunidade=% (esperado nenhuma — unidade unica)', v_multiunidade;
  end if;

  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 13) <> 1 then
    raise exception 'Pos-condicao falhou: quantidade de unidades do conteudo 13 != 1';
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
  if (select count(*) from public.questao_unidades_pedagogicas) <> (select total_vinculos from _snapshot_antes) + 7 then
    raise exception 'Pos-condicao falhou: total de vinculos nao cresceu exatamente 7';
  end if;

  -- Pos-condicao extra: artigos_esperados deve ser NULL.
  select artigos_esperados into v_artigos_esperados
  from public.unidades_pedagogicas
  where id = '29a4bec1-2c3a-40f3-a86f-fa6bda25d04f';
  if v_artigos_esperados is not null then
    raise exception 'Pos-condicao falhou: artigos_esperados=% (esperado NULL)', v_artigos_esperados;
  end if;

  -- Pos-condicao extra: o saneamento controlado (commit 51e5851)
  -- permanece intacto, nao revertido por este apply.
  select assunto_id into v_assunto_683 from public.questoes where id = 683;
  if v_assunto_683 is distinct from 55 then
    raise exception 'Pos-condicao falhou: assunto_id da questao 683 mudou para % (esperado permanecer 55)', v_assunto_683;
  end if;

  select count(*) into v_vinculos_684 from public.questao_unidades_pedagogicas where questao_id = 684;
  if v_vinculos_684 <> 0 then
    raise exception 'Pos-condicao falhou: questao 684 ganhou % vinculo(s) inesperado(s) — nao deveria reaparecer vinculada em nenhum conteudo', v_vinculos_684;
  end if;

  select count(*) into v_candidatas_22_live
  from public.questoes q
  join public.curso_conteudos cc on cc.id = 22
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where q.ativa = true and q.materia_id = cm.materia_id and (cc.assunto_id is null or q.assunto_id = cc.assunto_id);
  if v_candidatas_22_live <> 20 then
    raise exception 'Pos-condicao falhou: candidatas ativas live do conteudo 22 = % (esperado 20, estado saneado apos Q683 sair do assunto 47)', v_candidatas_22_live;
  end if;

  select count(*) into v_vinculos_22_live
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 22;
  if v_vinculos_22_live <> 16 then
    raise exception 'Pos-condicao falhou: vinculos live do conteudo 22 = % (esperado 16, apos remocao do vinculo de Q684)', v_vinculos_22_live;
  end if;

  -- Pos-condicao extra: conteudos 20, 26, 31, 33 e 34 (sobreposicao
  -- tematica) permanecem intocados.
  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 20) <> (select unidades_20 from _snapshot_sobrepostos_antes) then
    raise exception 'Pos-condicao falhou: quantidade de unidades do conteudo 20 mudou — nao deveria ser tocado';
  end if;
  if (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where u.curso_conteudo_id = 20) <> (select vinculos_20 from _snapshot_sobrepostos_antes) then
    raise exception 'Pos-condicao falhou: quantidade de vinculos do conteudo 20 mudou — nao deveria ser tocado';
  end if;
  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 26) <> (select unidades_26 from _snapshot_sobrepostos_antes) then
    raise exception 'Pos-condicao falhou: quantidade de unidades do conteudo 26 mudou — nao deveria ser tocado';
  end if;
  if (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where u.curso_conteudo_id = 26) <> (select vinculos_26 from _snapshot_sobrepostos_antes) then
    raise exception 'Pos-condicao falhou: quantidade de vinculos do conteudo 26 mudou — nao deveria ser tocado';
  end if;
  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 31) <> (select unidades_31 from _snapshot_sobrepostos_antes) then
    raise exception 'Pos-condicao falhou: quantidade de unidades do conteudo 31 mudou — nao deveria ser tocado';
  end if;
  if (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where u.curso_conteudo_id = 31) <> (select vinculos_31 from _snapshot_sobrepostos_antes) then
    raise exception 'Pos-condicao falhou: quantidade de vinculos do conteudo 31 mudou — nao deveria ser tocado';
  end if;
  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 33) <> (select unidades_33 from _snapshot_sobrepostos_antes) then
    raise exception 'Pos-condicao falhou: quantidade de unidades do conteudo 33 mudou — nao deveria ser tocado';
  end if;
  if (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where u.curso_conteudo_id = 33) <> (select vinculos_33 from _snapshot_sobrepostos_antes) then
    raise exception 'Pos-condicao falhou: quantidade de vinculos do conteudo 33 mudou — nao deveria ser tocado';
  end if;
  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 34) <> (select unidades_34 from _snapshot_sobrepostos_antes) then
    raise exception 'Pos-condicao falhou: quantidade de unidades do conteudo 34 mudou — nao deveria ser tocado';
  end if;
  if (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id where u.curso_conteudo_id = 34) <> (select vinculos_34 from _snapshot_sobrepostos_antes) then
    raise exception 'Pos-condicao falhou: quantidade de vinculos do conteudo 34 mudou — nao deveria ser tocado';
  end if;

  raise notice 'Pos-condicoes OK: 7 questoes classificadas / 7 vinculos / 0 multiunidade / artigos_esperados NULL / saneamento controlado (Q683 assunto_id=55, Q684 sem vinculo) intacto / conteudo 22 live com 20 candidatas / 16 vinculos / conteudos 20, 26, 31, 33 e 34 intocados.';
end $$;

commit;
