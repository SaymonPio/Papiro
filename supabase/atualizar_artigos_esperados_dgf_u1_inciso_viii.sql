-- ATUALIZACAO DE artigos_esperados — unidade "Direitos Individuais e
-- Coletivos Fundamentais" (BM RS), incluindo o inciso VIII do art. 5º.
--
-- Mandato: "PAPIRO — FASE 8 — CORRECAO CIRURGICA DA PRIMEIRA AULA ASYNC".
-- Classificacao tecnica: UPDATE_CANONICAL_EXISTING_SCOPE (mesmo padrao ja
-- usado em atualizar_escopo_lei_tortura_art1_iii.sql — nao e schema
-- change/migration; artigos_esperados e text[] comparado como strings
-- opacas).
--
-- Achado da auditoria pedagogica/juridica (Fase 7): a aula gerada aborda
-- corretamente o inciso VIII (ninguem sera privado de direitos por
-- crenca/conviccao filosofica ou politica, ressalvada a recusa de
-- prestacao alternativa) — classificado como
-- VIII_CORRETO_E_ESCOPO_CONFIGURADO_INCOMPLETO. O campo `escopo` (texto
-- livre) ja descreve corretamente esse tema ("liberdade religiosa,
-- incluindo assistencia religiosa"), que abrange VI+VII+VIII como bloco
-- tematico unico. Só o array `artigos_esperados` (lista de rastreamento
-- separada, mantida à parte) estava incompleto.
--
-- Alteracao UNICA: artigos_esperados — adiciona "art. 5º, VIII" na
-- posicao numerica natural (apos "art. 5º, VII"), sem remover nenhum dos
-- 13 itens existentes. O campo `escopo` (texto livre) NAO e alterado —
-- ja esta correto, confirmado por leitura direta antes desta migration.
--
-- NAO toca: aulas, aula_versoes, questoes, curso_conteudos, ou qualquer
-- outra unidade_pedagogica.
--
-- ROLLBACK-TESTADO em atualizar_artigos_esperados_dgf_u1_inciso_viii_teste_rollback.sql

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _snapshot_old_unidade on commit drop as
select id, escopo, artigos_esperados
from public.unidades_pedagogicas
where id = '0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid;

create temporary table _hash_outras_unidades_antes on commit drop as
select md5(string_agg(id::text || coalesce(escopo,'') || coalesce(array_to_string(artigos_esperados, ','), ''), '|' order by id)) as h
from public.unidades_pedagogicas
where id <> '0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid;

-- ================= PRECONDICOES =================
do $$
declare
  v_escopo text;
  v_artigos text[];
  v_qtd int;
  v_hash_escopo text;
begin
  select escopo, artigos_esperados into v_escopo, v_artigos
  from public.unidades_pedagogicas where id = '0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid;

  if v_escopo is null then raise exception 'PRECOND: unidade nao encontrada'; end if;

  select md5(v_escopo) into v_hash_escopo;
  if v_hash_escopo <> '4803d8d80fd97f5c69ca12f64d44ce6b' then
    raise exception 'PRECOND: hash do escopo atual diverge do estado auditado na Fase 7 — possivel alteracao concorrente, abortar';
  end if;

  v_qtd := array_length(v_artigos, 1);
  if v_qtd <> 13 then raise exception 'PRECOND: esperado 13 artigos_esperados atuais, encontrado %', v_qtd; end if;
  if v_artigos <> ARRAY['art. 5º, caput', 'art. 5º, I', 'art. 5º, IV', 'art. 5º, VI', 'art. 5º, VII', 'art. 5º, IX', 'art. 5º, X', 'art. 5º, XI', 'art. 5º, XII', 'art. 5º, XVI', 'art. 5º, XVII', 'art. 5º, XVIII', 'art. 5º, XXI'] then
    raise exception 'PRECOND: artigos_esperados atual diverge do esperado (conteudo ou ordem) — abortar';
  end if;

  if 'art. 5º, VIII' = any(v_artigos) then raise exception 'PRECOND: art. 5º, VIII ja presente antes do apply — possivel reexecucao'; end if;

  raise notice 'PRECOND OK: escopo identico ao estado auditado (hash confere), artigos_esperados identico ao esperado (13 itens), art.5º,VIII ainda ausente';
end $$;

-- ================= APPLY =================
-- Somente artigos_esperados muda. O campo escopo NAO e tocado (nenhuma
-- clausula SET para ele) — ja esta correto.
update public.unidades_pedagogicas
set
  artigos_esperados = ARRAY['art. 5º, caput', 'art. 5º, I', 'art. 5º, IV', 'art. 5º, VI', 'art. 5º, VII', 'art. 5º, VIII', 'art. 5º, IX', 'art. 5º, X', 'art. 5º, XI', 'art. 5º, XII', 'art. 5º, XVI', 'art. 5º, XVII', 'art. 5º, XVIII', 'art. 5º, XXI']
where id = '0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid;

-- ================= POSCONDICOES =================
do $$
declare
  v_escopo text;
  v_hash_escopo text;
  v_artigos text[];
  v_qtd int;
  v_todos_antigos_presentes boolean;
  v_sem_duplicata boolean;
begin
  select escopo, artigos_esperados into v_escopo, v_artigos
  from public.unidades_pedagogicas where id = '0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid;

  select md5(v_escopo) into v_hash_escopo;
  if v_hash_escopo <> '4803d8d80fd97f5c69ca12f64d44ce6b' then
    raise exception 'POSCOND: o campo escopo foi alterado — este patch nunca deveria toca-lo';
  end if;

  v_qtd := array_length(v_artigos, 1);
  if v_qtd <> 14 then raise exception 'POSCOND: esperado 14 artigos_esperados, encontrado %', v_qtd; end if;

  select ARRAY['art. 5º, caput', 'art. 5º, I', 'art. 5º, IV', 'art. 5º, VI', 'art. 5º, VII', 'art. 5º, IX', 'art. 5º, X', 'art. 5º, XI', 'art. 5º, XII', 'art. 5º, XVI', 'art. 5º, XVII', 'art. 5º, XVIII', 'art. 5º, XXI'] <@ v_artigos into v_todos_antigos_presentes;
  if not v_todos_antigos_presentes then raise exception 'POSCOND: um ou mais artigos_esperados antigos foram perdidos'; end if;

  if not ('art. 5º, VIII' = any(v_artigos)) then raise exception 'POSCOND: art. 5º, VIII nao foi adicionado'; end if;

  select (select count(*) from unnest(v_artigos) x) = (select count(distinct x) from unnest(v_artigos) x) into v_sem_duplicata;
  if not v_sem_duplicata then raise exception 'POSCOND: ha duplicacao em artigos_esperados'; end if;

  if v_artigos <> ARRAY['art. 5º, caput', 'art. 5º, I', 'art. 5º, IV', 'art. 5º, VI', 'art. 5º, VII', 'art. 5º, VIII', 'art. 5º, IX', 'art. 5º, X', 'art. 5º, XI', 'art. 5º, XII', 'art. 5º, XVI', 'art. 5º, XVII', 'art. 5º, XVIII', 'art. 5º, XXI'] then
    raise exception 'POSCOND: ordem final de artigos_esperados diverge do esperado (VIII deve estar na posicao numerica natural, apos VII)';
  end if;

  raise notice 'POSCOND OK: 14 artigos_esperados (13 antigos preservados + art.5º,VIII na posicao correta), sem duplicatas, escopo textual inalterado (hash confere)';
end $$;

-- Confirma que NENHUMA outra unidade foi tocada.
do $$
declare
  v_total_depois int;
  v_total_antes int;
  v_hash_depois text;
  v_hash_antes text;
begin
  select count(*) into v_total_antes from public.unidades_pedagogicas;
  select count(*) into v_total_depois from public.unidades_pedagogicas;
  if v_total_depois <> v_total_antes then
    raise exception 'POSCOND: contagem total de unidades_pedagogicas mudou inesperadamente dentro da mesma transacao';
  end if;

  select h into v_hash_antes from _hash_outras_unidades_antes;
  select md5(string_agg(id::text || coalesce(escopo,'') || coalesce(array_to_string(artigos_esperados, ','), ''), '|' order by id))
  into v_hash_depois
  from public.unidades_pedagogicas
  where id <> '0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid;

  if v_hash_depois is distinct from v_hash_antes then
    raise exception 'POSCOND: conteudo de OUTRAS unidades_pedagogicas mudou — vazamento de escopo do UPDATE';
  end if;

  raise notice 'POSCOND OK: nenhuma outra unidade_pedagogica foi tocada (hash de conteudo identico)';
end $$;

commit;
