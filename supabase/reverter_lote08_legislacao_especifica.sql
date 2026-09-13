-- REVERSAO REAL da IMPORTACAO LOTE08_LEGISLACAO_ESPECIFICA. NUNCA
-- executado automaticamente. Disponivel para uso manual futuro caso a
-- importacao precise ser desfeita.
--
-- Identifica as 23 questoes pelo enunciado EXATO (congelado) + banca
-- 'Papiro' + vinculo a uma das 7 unidades do lote — nunca por um range
-- de ID. Remove nesta ordem: vinculo (RPC sancionada
-- remover_classificacao_questao_unidade_admin) -> curso_questoes ->
-- alternativas -> questoes.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _enunciados_lote (enunciado text) on commit drop;
insert into _enunciados_lote (enunciado) values
  $ENREV1$Durante patrulhamento realizado por agentes de um Município, uma viatura oficial colide com o veículo de um particular e lhe causa danos materiais. Comprovados o dano e o nexo causal entre a atuação dos agentes e o prejuízo, assinale a alternativa correta quanto à responsabilidade civil do Município.$ENREV1$,
  $ENREV2$Uma empresa privada concessionária de transporte coletivo urbano presta serviço público por delegação e, durante a execução do serviço, um de seus empregados causa dano a um passageiro. À luz da Constituição Federal, assinale a alternativa correta.$ENREV2$,
  $ENREV3$Um servidor público, em seu dia de folga, utiliza seu automóvel particular para tratar exclusivamente de assunto familiar. Durante o trajeto, colide com o veículo de um particular e causa-lhe prejuízo. Não há qualquer vínculo entre o deslocamento e as atribuições do cargo. À luz da responsabilidade civil prevista na Constituição Federal, assinale a alternativa correta.$ENREV3$,
  $ENREV4$Para os fins da regra de responsabilidade civil objetiva prevista no art. 37, § 6º, da Constituição Federal, a expressão “terceiros” refere-se, corretamente, a$ENREV4$,
  $ENREV5$Uma pessoa jurídica de direito público foi condenada a indenizar terceiro por dano causado por agente público no exercício de suas funções. À luz da responsabilidade civil do Estado, assinale a alternativa correta acerca da possibilidade de a pessoa jurídica buscar o ressarcimento do valor pago.$ENREV5$,
  $ENREV6$Em razão de ato praticado por seu agente nessa qualidade, uma pessoa jurídica prestadora de serviço público indenizou um particular pelos danos sofridos. Posteriormente, pretende ajuizar ação regressiva contra o agente. Para o êxito dessa ação regressiva, é indispensável que a pessoa jurídica comprove$ENREV6$,
  $ENREV7$À luz da responsabilidade civil do Estado prevista na Constituição Federal, analise as afirmativas a seguir.

I. As pessoas jurídicas de direito público e as pessoas jurídicas de direito privado prestadoras de serviços públicos respondem pelos danos que seus agentes, nessa qualidade, causem a terceiros.

II. Para a vítima obter indenização da pessoa jurídica, é indispensável comprovar o dolo ou a culpa do agente causador do dano.

III. Assegurado o direito de regresso contra o agente responsável, este depende da demonstração de dolo ou culpa do agente.

Quais estão corretas?$ENREV7$,
  $ENREV8$No âmbito de um processo administrativo, um servidor é acusado de infração funcional. Considerando o texto constitucional, assinale a alternativa correta acerca das garantias que lhe devem ser asseguradas.$ENREV8$,
  $ENREV9$A Constituição assegura determinada prerrogativa relacionada à cidadania, mas o seu exercício depende de lei regulamentadora que ainda não foi editada. Em razão dessa omissão normativa, torna-se inviável exercer a prerrogativa constitucional. Assinale o remédio constitucional cabível.$ENREV9$,
  $ENREV10$Nos termos da Constituição Federal, assinale a alternativa correta acerca do Conselho de Defesa Nacional.$ENREV10$,
  $ENREV11$Em relação ao estado de sítio, analise as assertivas a seguir, conforme a Constituição Federal.

I. O Presidente da República deve ouvir o Conselho da República e o Conselho de Defesa Nacional antes de solicitar autorização ao Congresso Nacional para decretar o estado de sítio.

II. A comoção grave de repercussão nacional e a ineficácia de medida tomada durante o estado de defesa constituem hipóteses para a solicitação de autorização para decretar o estado de sítio.

III. A declaração de guerra ou a resposta a agressão armada estrangeira também constituem hipóteses para a solicitação de autorização para decretar o estado de sítio.

Quais estão corretas?$ENREV11$,
  $ENREV12$Nos termos da redação atual do caput do art. 144 da Constituição Federal, assinale a alternativa que apresenta corretamente todos os órgãos responsáveis pelo exercício da segurança pública.$ENREV12$,
  $ENREV13$Em relação às restrições constitucionais aplicáveis aos militares, assinale a alternativa correta.$ENREV13$,
  $ENREV14$Para os efeitos da Lei nº 8.429/1992, assinale a alternativa que apresenta corretamente quem é considerado agente público.$ENREV14$,
  $ENREV15$Nos termos da Lei nº 8.429/1992, na hipótese de ato de improbidade administrativa que importe enriquecimento ilícito, assinale a alternativa que indica corretamente as sanções aplicáveis.$ENREV15$,
  $ENREV16$Nos termos da redação atual da Lei nº 8.429/1992, a ação para aplicação das sanções nela previstas prescreve em$ENREV16$,
  $ENREV17$Sobre o elemento subjetivo dos atos de improbidade administrativa na redação vigente da Lei nº 8.429/1992, assinale a alternativa correta.$ENREV17$,
  $ENREV18$Nos termos da Lei Maria da Penha, em uma causa cível decorrente de violência doméstica e familiar contra a mulher na qual o Ministério Público não figure como parte, sua atuação deverá ocorrer$ENREV18$,
  $ENREV19$Quando necessário, constitui atribuição do Ministério Público prevista na Lei nº 11.340/2006:$ENREV19$,
  $ENREV20$Nos termos da Lei Maria da Penha, assinale a alternativa correta acerca da assistência por advogado à mulher em situação de violência doméstica e familiar.$ENREV20$,
  $ENREV21$Considerando a garantia de assistência à mulher em situação de violência doméstica e familiar, prevista na Lei nº 11.340/2006, assinale a alternativa correta.$ENREV21$,
  $ENREV22$Considerando a autotutela administrativa, a autoridade competente concluiu que um ato válido deixou de ser conveniente para o interesse público. O ato já havia gerado direito adquirido a determinado administrado. Assinale a alternativa correta.$ENREV22$,
  $ENREV23$Uma autoridade administrativa verificou que determinado ato apresenta defeito sanável. Antes de decidir sobre sua manutenção, constatou que a convalidação não acarretará lesão ao interesse público nem prejuízo a terceiros. Nos termos da Lei nº 9.784/1999, é correto afirmar que o ato$ENREV23$;

create temporary table _unidades_lote (unidade_pedagogica_id uuid) on commit drop;
insert into _unidades_lote (unidade_pedagogica_id) values
  ('d6f03d69-8943-4867-a2af-e37482d4ca99'::uuid),
  ('f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63'::uuid),
  ('ecdb1d62-ef44-4407-b899-85911402bc90'::uuid),
  ('9d4c7a1e-3f68-4b52-8a91-6c0d5e2f7b84'::uuid),
  ('60927a85-1b4a-480a-b8da-8eb318520692'::uuid),
  ('53dc06a1-cd16-4004-a76b-8201d95a91c4'::uuid),
  ('85323ce5-772b-4bf1-bc32-a79e2316158b'::uuid);

create temporary table _alvo (questao_id bigint primary key, unidade_pedagogica_id uuid) on commit drop;
insert into _alvo (questao_id, unidade_pedagogica_id)
select distinct q.id, qup.unidade_pedagogica_id
from public.questoes q
join public.questao_unidades_pedagogicas qup on qup.questao_id = q.id
where coalesce(lower(q.banca),'') like '%papiro%'
  and lower(q.enunciado) in (select lower(enunciado) from _enunciados_lote)
  and qup.unidade_pedagogica_id in (select unidade_pedagogica_id from _unidades_lote);

do $$
declare v_qtd int;
begin
  select count(*) into v_qtd from _alvo;
  if v_qtd <> 23 then
    raise exception 'PRECOND: esperado localizar exatamente 23 questoes do lote, encontrado %', v_qtd;
  end if;
end $$;

do $$
declare
  r record;
  v_count int := 0;
begin
  for r in select questao_id, unidade_pedagogica_id from _alvo loop
    perform public.remover_classificacao_questao_unidade_admin(r.questao_id, r.unidade_pedagogica_id);
    v_count := v_count + 1;
  end loop;
  if v_count <> 23 then raise exception 'REVERSAO: vinculos removidos=% esperado 23', v_count; end if;
end $$;

do $$
declare v_count int;
begin
  delete from public.curso_questoes where curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and questao_id in (select questao_id from _alvo);
  get diagnostics v_count = row_count;
  if v_count <> 23 then raise exception 'REVERSAO: curso_questoes removidas=% esperado 23', v_count; end if;
end $$;

do $$
declare v_count int;
begin
  delete from public.alternativas where questao_id in (select questao_id from _alvo);
  get diagnostics v_count = row_count;
  if v_count <> 115 then raise exception 'REVERSAO: alternativas removidas=% esperado 115', v_count; end if;
end $$;

do $$
declare v_count int;
begin
  delete from public.questoes where id in (select questao_id from _alvo);
  get diagnostics v_count = row_count;
  if v_count <> 23 then raise exception 'REVERSAO: questoes removidas=% esperado 23', v_count; end if;
end $$;

commit;
