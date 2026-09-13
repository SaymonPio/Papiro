-- TESTE DE ROLLBACK (NAO APLICA NADA PERMANENTE — termina em ROLLBACK).
-- Simula, dentro de UMA transacao que sera revertida ao final:
--   OLD -> TARGET (aplica a mesma UPDATE do script real) ->
--   REVERT (desfaz manualmente) -> OLD_FINAL (confirma que voltou ao
--   estado exatamente igual ao OLD original).
-- Objetivo: provar que a operacao de UPDATE tem reversao trivial e segura
-- ANTES de aplicar de verdade em atualizar_escopo_jurisprudencia_stf_stj_lote09b.sql.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

-- ============ OLD ============
create temporary table _t_old on commit drop as
select id, titulo, escopo, artigos_esperados
from public.unidades_pedagogicas
where id = '8e1d1204-1f66-431c-a95f-6403e77882dc';

do $$
declare v_qtd int;
begin
  select array_length(artigos_esperados,1) into v_qtd from _t_old;
  if v_qtd <> 6 then raise exception 'OLD: esperado 6 artigos_esperados, encontrado %', v_qtd; end if;
  raise notice 'OLD OK: 6 artigos_esperados capturados';
end $$;

-- ============ TARGET (mesma logica do apply real) ============
update public.unidades_pedagogicas
set
  escopo = escopo || $ESCOPO_ADD$ Em complemento (Lote09B), o escopo desta unidade passa a incluir também: ADPF 635/RJ do STF ("ADPF das Favelas", julgamento em 03/04/2025) sobre parâmetros de redução da letalidade policial e uso da força em operações; ADPF 347/DF do STF sobre a obrigatoriedade de audiência de custódia em até 24 horas da prisão, em qualquer modalidade; Tema 998 de repercussão geral do STF (ARE 959.620/RS, tese fixada em 14/08/2025) sobre a inadmissibilidade de revista íntima vexatória de visitantes em estabelecimentos prisionais; Súmula 145 do STF, que distingue o flagrante preparado (crime impossível) do flagrante esperado; e o HC 653.515/RJ do STJ (Sexta Turma, julgado em 23/11/2021) sobre as consequências da quebra da cadeia de custódia da prova (arts. 158-A a 158-F do CPP).$ESCOPO_ADD$,
  artigos_esperados = artigos_esperados || ARRAY[
    'STF ADPF 635/RJ',
    'STF ADPF 347/DF',
    'STF Tema 998 RG - ARE 959.620',
    'STF Súmula 145',
    'STJ HC 653.515/RJ'
  ]
where id = '8e1d1204-1f66-431c-a95f-6403e77882dc';

do $$
declare v_qtd int;
begin
  select array_length(artigos_esperados,1) into v_qtd
  from public.unidades_pedagogicas where id = '8e1d1204-1f66-431c-a95f-6403e77882dc';
  if v_qtd <> 11 then raise exception 'TARGET: esperado 11 artigos_esperados, encontrado %', v_qtd; end if;
  raise notice 'TARGET OK: 11 artigos_esperados (6+5)';
end $$;

-- ============ REVERT (restaura a partir do snapshot OLD) ============
update public.unidades_pedagogicas up
set
  escopo = t.escopo,
  artigos_esperados = t.artigos_esperados
from _t_old t
where up.id = t.id;

-- ============ OLD_FINAL (confirma identidade byte-a-byte com OLD) ============
do $$
declare
  v_escopo_igual boolean;
  v_artigos_igual boolean;
begin
  select (up.escopo = t.escopo), (up.artigos_esperados = t.artigos_esperados)
  into v_escopo_igual, v_artigos_igual
  from public.unidades_pedagogicas up
  join _t_old t on t.id = up.id
  where up.id = '8e1d1204-1f66-431c-a95f-6403e77882dc';

  if not v_escopo_igual then raise exception 'OLD_FINAL: escopo NAO retornou identico ao original'; end if;
  if not v_artigos_igual then raise exception 'OLD_FINAL: artigos_esperados NAO retornou identico ao original'; end if;

  raise notice 'OLD_FINAL OK: escopo e artigos_esperados identicos ao estado OLD original — reversao comprovada';
end $$;

-- Nunca commitar este teste — a reversao real, se necessaria depois do
-- apply de verdade, deve usar reverter_escopo_jurisprudencia_stf_stj_lote09b.sql.
rollback;
