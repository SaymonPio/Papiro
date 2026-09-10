-- REVERSAO REAL da IMPORTACAO CV-AUT-01. NUNCA executado
-- automaticamente. Disponivel para uso manual futuro caso a importacao
-- precise ser desfeita.
--
-- Identifica as 6 questoes pelo enunciado EXATO (congelado) + banca
-- 'Papiro' + vinculo a unidade '834a820d-48a7-440f-a013-be375be8a62d' — nunca por um range de ID,
-- para nunca arriscar apagar questao de outro lote. Remove nesta ordem:
-- vinculo (RPC sancionada) -> curso_questoes -> alternativas -> questoes.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _enunciados_lote (enunciado text) on commit drop;
insert into _enunciados_lote (enunciado) values
  $ENREV1$Considere as frases a seguir quanto à concordância verbal.

I. A sequência de treinamentos prepara os recrutas para a avaliação.
II. Os resultados do último simulado demonstra a evolução da turma.
III. O comandante, referência para os novos soldados, orientou a equipe.
IV. A presença dos instrutores garantem maior segurança durante a atividade.

Quais estão corretas?$ENREV1$,
  $ENREV2$Assinale a alternativa que preenche corretamente as lacunas da frase a seguir:

A equipe ______ a rotina de treinamento, o novo instrutor ______ ao quartel logo cedo e os supervisores ______ autonomia para ajustar as atividades.$ENREV2$,
  $ENREV3$Assinale a alternativa que preenche corretamente as lacunas da frase abaixo.

O relatório ______ dados sigilosos, enquanto os anexos ______ informações complementares.$ENREV3$,
  $ENREV4$Considere a frase:

“A revisão dos procedimentos operacionais começaram na segunda-feira.”

Sem alterar o sujeito nem o tempo verbal empregado, assinale a alternativa que identifica corretamente a existência de erro de concordância verbal e, se houver, apresenta a correção necessária.$ENREV4$,
  $ENREV5$Analise as afirmativas a seguir quanto à concordância verbal.

I. Naquela região, deve haver rotas alternativas para o resgate.
II. Podem existir falhas no sistema de comunicação.
III. Haviam obstáculos imprevistos durante a operação.
IV. Pode existirem soluções mais seguras para o deslocamento.

Quais afirmativas estão corretas?$ENREV5$,
  $ENREV6$Assinale a alternativa que preenche corretamente as lacunas da frase: “Pelos registros, ______ quatro meses que terminou a última capacitação; desde então, os instrutores ______ atividades de revisão semanalmente.”$ENREV6$;

create temporary table _alvo (questao_id bigint primary key) on commit drop;
insert into _alvo (questao_id)
select q.id from public.questoes q
where q.ativa = true
and coalesce(lower(q.banca),'') like '%papiro%'
and q.enunciado in (select enunciado from _enunciados_lote)
and exists (select 1 from public.questao_unidades_pedagogicas qup where qup.questao_id = q.id and qup.unidade_pedagogica_id = '834a820d-48a7-440f-a013-be375be8a62d');

-- ================= GUARD =================
do $$
declare
  v_n int;
  v_gabaritos text;
begin
  select count(*) into v_n from _alvo;
  if v_n <> 6 then raise exception 'GUARD: % questao(oes) encontradas pelo enunciado congelado, esperado exatamente 6 — abortando reversao', v_n; end if;

  if (select count(*) from public.alternativas a join _alvo x on x.questao_id = a.questao_id) <> 30 then
    raise exception 'GUARD: total de alternativas das 6 nao e 30 — abortando reversao';
  end if;

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=x.questao_id and correta=true), '' order by x.questao_id)
    into v_gabaritos from _alvo x;
  raise notice 'GUARD OK: 6 questoes encontradas pelo enunciado congelado, 30 alternativas, gabaritos (ordem por id) = %', v_gabaritos;
end $$;

-- ================= REVERSAO =================
do $$
declare
  r record;
  v_count int := 0;
begin
  for r in select questao_id from _alvo loop
    perform public.remover_classificacao_questao_unidade_admin(r.questao_id, '834a820d-48a7-440f-a013-be375be8a62d'::uuid);
    v_count := v_count + 1;
  end loop;
  raise notice 'REVERSAO: % vinculo(s) removido(s)', v_count;
end $$;

do $$
declare
  v_count int;
begin
  delete from public.curso_questoes where curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and questao_id in (select questao_id from _alvo);
  get diagnostics v_count = row_count;
  if v_count <> 6 then raise exception 'REVERSAO: % curso_questoes removidas, esperado 6', v_count; end if;
  raise notice 'REVERSAO: % linha(s) removidas de curso_questoes', v_count;
end $$;

do $$
declare
  v_count int;
begin
  delete from public.alternativas where questao_id in (select questao_id from _alvo);
  get diagnostics v_count = row_count;
  if v_count <> 30 then raise exception 'REVERSAO: % alternativas removidas, esperado 30', v_count; end if;
  raise notice 'REVERSAO: % alternativa(s) removida(s)', v_count;
end $$;

do $$
declare
  v_count int;
begin
  delete from public.questoes where id in (select questao_id from _alvo);
  get diagnostics v_count = row_count;
  if v_count <> 6 then raise exception 'REVERSAO: % questoes removidas, esperado 6', v_count; end if;
  raise notice 'REVERSAO: % questao(oes) removida(s)', v_count;
end $$;

-- ================= POS-CHECK DA REVERSAO =================
do $$
declare
  v_uteis int;
begin
  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='834a820d-48a7-440f-a013-be375be8a62d' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  if v_uteis <> 4 then raise exception 'POSCOND: uteis da unidade apos reversao=% esperado 4', v_uteis; end if;
  raise notice 'POSCONDICOES OK: unidade restaurada a 4 uteis (2 REAL + 2 AUTORAL)';
end $$;

commit;
