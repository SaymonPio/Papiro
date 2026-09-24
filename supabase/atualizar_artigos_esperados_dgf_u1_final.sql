-- ATUALIZACAO DE artigos_esperados — unidade "Direitos Individuais e
-- Coletivos Fundamentais" (BM RS), incluindo os incisos XV e XIX do
-- art. 5º.
--
-- Mandato: "PAPIRO — FASE 9.0.1 — REVISAO FINAL DA CURADORIA DGF ANTES
-- DO ROLLBACK TEST". SUBSTITUI o patch da Fase 9
-- (atualizar_artigos_esperados_dgf_u1_inciso_xix.sql, removido nesta
-- rodada) — a revisao humana identificou que a questao real 847 (ja
-- vinculada a esta unidade) tem gabarito real em art. 5º, XV, nao
-- ensinado ate entao. Classificacao tecnica: UPDATE_CANONICAL_EXISTING_
-- SCOPE (mesmo padrao ja usado em
-- atualizar_artigos_esperados_dgf_u1_inciso_viii.sql).
--
-- Achados da curadoria Fase 9.0.1:
--   XIX -- questao real 46 (Fundatec, BM RS Soldado 1a Classe 2025), um
--   dos 4 itens V/F, testa "associacoes so poderao ser compulsoriamente
--   dissolvidas ou ter atividades suspensas por decisao judicial,
--   exigindo-se, no primeiro caso, transito em julgado" -- tema
--   contiguo ao XVII/XVIII/XXI, ja ensinados no componente "Liberdade
--   de associacao".
--   XV -- questao real 847 (Fundatec, TA Pol Pen PP RS 2022), gabarito
--   real e literal do art. 5º, XV ("e livre a locomocao no territorio
--   nacional EM TEMPO DE PAZ..." -- alternativa que estende a regra
--   tambem ao tempo de guerra e a INCORRETA pedida pelo enunciado).
--   Direito individual basico, coerente com o titulo da unidade,
--   incidencia real Fundatec, questao real ja selecionada -- os 4
--   criterios do mandato desta rodada. Exige NOVO componente (sem
--   relacao tematica com nenhum componente existente) -- ver patch
--   irmao ajustar_aula_dgf_u1_final.sql.
--
-- Alteracao UNICA: artigos_esperados -- adiciona "art. 5º, XV" e
-- "art. 5º, XIX" nas posicoes numericas naturais (XV entre XII e XVI;
-- XIX entre XVIII e XXI), sem remover nenhum dos 14 itens existentes.
-- O campo `escopo` (texto livre) NAO e alterado por este patch.
--
-- NAO toca: aulas, aula_versoes (ver patch irmao
-- ajustar_aula_dgf_u1_final.sql, que precisa ser aplicado em conjunto),
-- questoes, curso_conteudos, ou qualquer outra unidade_pedagogica.
--
-- ROLLBACK-TESTADO em
-- atualizar_artigos_esperados_dgf_u1_final_teste_rollback.sql
-- (preparado nesta mesma rodada; execucao contra LIVE fica para uma
-- fase de rollback-test dedicada, nao esta).

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _snapshot_old_unidade_u1_final on commit drop as
select id, escopo, artigos_esperados
from public.unidades_pedagogicas
where id = '0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid;

create temporary table _hash_outras_unidades_antes_u1_final on commit drop as
select md5(string_agg(id::text || coalesce(escopo,'') || coalesce(array_to_string(artigos_esperados, ','), ''), '|' order by id)) as h
from public.unidades_pedagogicas
where id <> '0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid;

-- ================= PRECONDICOES =================
do $$
declare
  v_escopo text;
  v_artigos text[];
  v_hash_escopo text;
begin
  select escopo, artigos_esperados into v_escopo, v_artigos
  from public.unidades_pedagogicas where id = '0c5d1d64-0cae-406e-be19-b03d387bee8a'::uuid;

  if v_escopo is null then raise exception 'PRECOND: unidade nao encontrada'; end if;

  select md5(v_escopo) into v_hash_escopo;
  if v_hash_escopo <> '4803d8d80fd97f5c69ca12f64d44ce6b' then
    raise exception 'PRECOND: hash do escopo atual diverge do estado auditado na Fase 9/9.0.1 — possivel alteracao concorrente, abortar';
  end if;

  if v_artigos <> ARRAY['art. 5º, caput', 'art. 5º, I', 'art. 5º, IV', 'art. 5º, VI', 'art. 5º, VII', 'art. 5º, VIII', 'art. 5º, IX', 'art. 5º, X', 'art. 5º, XI', 'art. 5º, XII', 'art. 5º, XVI', 'art. 5º, XVII', 'art. 5º, XVIII', 'art. 5º, XXI'] then
    raise exception 'PRECOND: artigos_esperados atual diverge do esperado (conteudo ou ordem) — abortar';
  end if;

  if 'art. 5º, XV' = any(v_artigos) then raise exception 'PRECOND: art. 5º, XV ja presente antes do apply — possivel reexecucao'; end if;
  if 'art. 5º, XIX' = any(v_artigos) then raise exception 'PRECOND: art. 5º, XIX ja presente antes do apply — possivel reexecucao'; end if;

  raise notice 'PRECOND OK: escopo identico ao estado auditado (hash confere), artigos_esperados identico ao esperado (14 itens), XV e XIX ainda ausentes';
end $$;

-- ================= APPLY =================
update public.unidades_pedagogicas
set
  artigos_esperados = ARRAY['art. 5º, caput', 'art. 5º, I', 'art. 5º, IV', 'art. 5º, VI', 'art. 5º, VII', 'art. 5º, VIII', 'art. 5º, IX', 'art. 5º, X', 'art. 5º, XI', 'art. 5º, XII', 'art. 5º, XV', 'art. 5º, XVI', 'art. 5º, XVII', 'art. 5º, XVIII', 'art. 5º, XIX', 'art. 5º, XXI']
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
  if v_qtd <> 16 then raise exception 'POSCOND: esperado 16 artigos_esperados, encontrado %', v_qtd; end if;

  select ARRAY['art. 5º, caput', 'art. 5º, I', 'art. 5º, IV', 'art. 5º, VI', 'art. 5º, VII', 'art. 5º, VIII', 'art. 5º, IX', 'art. 5º, X', 'art. 5º, XI', 'art. 5º, XII', 'art. 5º, XVI', 'art. 5º, XVII', 'art. 5º, XVIII', 'art. 5º, XXI'] <@ v_artigos into v_todos_antigos_presentes;
  if not v_todos_antigos_presentes then raise exception 'POSCOND: um ou mais artigos_esperados antigos foram perdidos'; end if;

  if not ('art. 5º, XV' = any(v_artigos)) then raise exception 'POSCOND: art. 5º, XV nao foi adicionado'; end if;
  if not ('art. 5º, XIX' = any(v_artigos)) then raise exception 'POSCOND: art. 5º, XIX nao foi adicionado'; end if;

  select (select count(*) from unnest(v_artigos) x) = (select count(distinct x) from unnest(v_artigos) x) into v_sem_duplicata;
  if not v_sem_duplicata then raise exception 'POSCOND: ha duplicacao em artigos_esperados'; end if;

  if v_artigos <> ARRAY['art. 5º, caput', 'art. 5º, I', 'art. 5º, IV', 'art. 5º, VI', 'art. 5º, VII', 'art. 5º, VIII', 'art. 5º, IX', 'art. 5º, X', 'art. 5º, XI', 'art. 5º, XII', 'art. 5º, XV', 'art. 5º, XVI', 'art. 5º, XVII', 'art. 5º, XVIII', 'art. 5º, XIX', 'art. 5º, XXI'] then
    raise exception 'POSCOND: ordem final de artigos_esperados diverge do esperado';
  end if;

  raise notice 'POSCOND OK: 16 artigos_esperados (14 antigos preservados + XV e XIX nas posicoes corretas), sem duplicatas, escopo textual inalterado (hash confere)';
end $$;

-- Confirma que NENHUMA outra unidade foi tocada.
do $$
declare
  v_hash_depois text;
  v_hash_antes text;
begin
  select h into v_hash_antes from _hash_outras_unidades_antes_u1_final;
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
