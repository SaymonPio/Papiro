-- REVERSAO REAL da IMPORTACAO LEG-AUT-HIERARQUIA-01. NUNCA executado
-- automaticamente. Disponivel para uso manual futuro caso a importacao
-- precise ser desfeita.
--
-- Identifica as 7 questoes pelo enunciado EXATO (congelado) + banca
-- 'Papiro' + vinculo a unidade 'cbde0aeb-3df8-4c41-a82f-91b83b529668' — nunca por um range de ID,
-- para nunca arriscar apagar questao de outro lote. Remove nesta ordem:
-- vinculo (RPC sancionada) -> curso_questoes -> alternativas -> questoes.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _enunciados_lote (enunciado text) on commit drop;
insert into _enunciados_lote (enunciado) values
  $ENREV1$A Lei Complementar Estadual RS nº 10.990/1997 dispõe sobre o Estatuto dos Militares Estaduais da Brigada Militar. Um Soldado recém-incorporado observa que, na rotina de sua unidade, os oficiais de posto mais elevado respondem por decisões e consequências institucionais que não recaem sobre os militares de grau hierárquico inferior. Sobre o fundamento dessa organização, à luz do art. 12, caput, da referida Lei Complementar, assinale a alternativa CORRETA.$ENREV1$,
  $ENREV2$Segundo o art. 12, §3º, da LC Estadual RS nº 10.990/1997, assinale a alternativa que reproduz corretamente a extensão da disciplina militar e do respeito à hierarquia prevista nesse dispositivo.$ENREV2$,
  $ENREV3$Sobre os círculos hierárquicos na Brigada Militar, nos termos do art. 13 da LC Estadual RS nº 10.990/1997, assinale a alternativa CORRETA.$ENREV3$,
  $ENREV4$Dois Capitães da Brigada Militar, ambos da ativa, possuem o mesmo grau hierárquico. Nos termos do art. 15, caput, da LC Estadual RS nº 10.990/1997, qual é a regra geral aplicável para fins de precedência entre eles?$ENREV4$,
  $ENREV5$Nos termos do art. 15, caput, da LC Estadual RS nº 10.990/1997, a ressalva de precedência funcional à regra geral da antiguidade é expressamente prevista para quais funções?$ENREV5$,
  $ENREV6$Em uma ocorrência policial-militar, encontram-se presentes os seguintes servidores militares da Brigada Militar, todos da ativa: Alpha, Capitão mais antigo no posto; Bravo, Capitão mais moderno no posto; Charlie, 1º Tenente; e Delta, Sargento. Considerando exclusivamente a ordenação hierárquica prevista no art. 12, §1º, da LC Estadual RS nº 10.990/1997, assinale a alternativa CORRETA.$ENREV6$,
  $ENREV7$Sobre a hierarquia e a disciplina na Brigada Militar, considere as assertivas abaixo, à luz da LC Estadual RS nº 10.990/1997:

I. A disciplina militar traduz-se pelo cumprimento do dever por parte de todos e de cada um dos componentes da corporação.

II. Os círculos hierárquicos são âmbitos de convivência entre militares da mesma categoria, destinados a desenvolver o espírito de camaradagem em ambiente de estima e confiança, sem prejuízo do respeito mútuo.

III. A disciplina militar e o respeito à hierarquia devem ser mantidos exclusivamente entre os militares da ativa.

Está(ão) correta(s):$ENREV7$;

create temporary table _alvo (questao_id bigint primary key) on commit drop;
insert into _alvo (questao_id)
select q.id from public.questoes q
where q.ativa = true
and coalesce(lower(q.banca),'') like '%papiro%'
and q.enunciado in (select enunciado from _enunciados_lote)
and exists (select 1 from public.questao_unidades_pedagogicas qup where qup.questao_id = q.id and qup.unidade_pedagogica_id = 'cbde0aeb-3df8-4c41-a82f-91b83b529668');

-- ================= GUARD =================
do $$
declare
  v_n int;
  v_gabaritos text;
begin
  select count(*) into v_n from _alvo;
  if v_n <> 7 then raise exception 'GUARD: % questao(oes) encontradas pelo enunciado congelado, esperado exatamente 7 — abortando reversao', v_n; end if;

  if (select count(*) from public.alternativas a join _alvo x on x.questao_id = a.questao_id) <> 35 then
    raise exception 'GUARD: total de alternativas das 7 nao e 35 — abortando reversao';
  end if;

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=x.questao_id and correta=true), '' order by x.questao_id)
    into v_gabaritos from _alvo x;
  raise notice 'GUARD OK: 7 questoes encontradas pelo enunciado congelado, 35 alternativas, gabaritos (ordem por id) = %', v_gabaritos;
end $$;

-- ================= REVERSAO =================
do $$
declare
  r record;
  v_count int := 0;
begin
  for r in select questao_id from _alvo loop
    perform public.remover_classificacao_questao_unidade_admin(r.questao_id, 'cbde0aeb-3df8-4c41-a82f-91b83b529668'::uuid);
    v_count := v_count + 1;
  end loop;
  if v_count <> 7 then raise exception 'REVERSAO: % vinculo(s) removidos, esperado 7', v_count; end if;
  raise notice 'REVERSAO: % vinculo(s) removidos via RPC sancionada', v_count;
end $$;

do $$
declare
  v_count int;
begin
  delete from public.curso_questoes where curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and questao_id in (select questao_id from _alvo);
  get diagnostics v_count = row_count;
  if v_count <> 7 then raise exception 'REVERSAO: % curso_questoes removidas, esperado 7', v_count; end if;
  raise notice 'REVERSAO: % linha(s) removidas de curso_questoes', v_count;
end $$;

do $$
declare
  v_count int;
begin
  delete from public.alternativas where questao_id in (select questao_id from _alvo);
  get diagnostics v_count = row_count;
  if v_count <> 35 then raise exception 'REVERSAO: % alternativas removidas, esperado 35', v_count; end if;
  raise notice 'REVERSAO: % alternativa(s) removida(s)', v_count;
end $$;

do $$
declare
  v_count int;
begin
  delete from public.questoes where id in (select questao_id from _alvo);
  get diagnostics v_count = row_count;
  if v_count <> 7 then raise exception 'REVERSAO: % questoes removidas, esperado 7', v_count; end if;
  raise notice 'REVERSAO: % questao(oes) removida(s)', v_count;
end $$;

-- ================= POS-CHECK DA REVERSAO =================
do $$
declare
  v_uteis int;
begin
  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='cbde0aeb-3df8-4c41-a82f-91b83b529668' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  if v_uteis <> 3 then raise exception 'POSCOND: uteis da unidade apos reversao=% esperado 3', v_uteis; end if;
  raise notice 'POSCONDICOES OK: unidade restaurada a 3 uteis (1 REAL + 2 AUTORAL)';
end $$;

commit;
