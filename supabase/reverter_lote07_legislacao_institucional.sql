-- REVERSAO REAL da IMPORTACAO LOTE07_LEGISLACAO_INSTITUCIONAL. NUNCA
-- executado automaticamente. Disponivel para uso manual futuro caso a
-- importacao precise ser desfeita.
--
-- Identifica as 23 questoes pelo enunciado EXATO (congelado) + banca
-- 'Papiro' + vinculo a uma das 4 unidades do lote — nunca por um range
-- de ID. Remove nesta ordem: vinculo (RPC sancionada
-- remover_classificacao_questao_unidade_admin) -> curso_questoes ->
-- alternativas -> questoes.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _enunciados_lote (enunciado text) on commit drop;
insert into _enunciados_lote (enunciado) values
  $ENREV1$Sobre a relação da Brigada Militar com a organização estadual de segurança pública, assinale a alternativa correta.$ENREV1$,
  $ENREV2$No contexto da organização institucional da Brigada Militar, a expressão “competências da instituição” refere-se, corretamente, ao conjunto de$ENREV2$,
  $ENREV3$A estrutura organizacional da Brigada Militar é composta por três níveis. Assinale a alternativa que apresenta corretamente essa composição.$ENREV3$,
  $ENREV4$Considerando a organização da Brigada Militar, assinale a alternativa que caracteriza corretamente a expressão Órgão de Polícia Militar (OPM).$ENREV4$,
  $ENREV5$Assinale a alternativa que apresenta corretamente a competência do Chefe do Estado-Maior da Brigada Militar.$ENREV5$,
  $ENREV6$Nos termos da Lei Complementar nº 16.450/2025, assinale a alternativa correta acerca do Estado-Maior da Brigada Militar.$ENREV6$,
  $ENREV7$Nos termos da Lei Complementar nº 16.450/2025, assinale a alternativa que apresenta corretamente atribuições do Subcomandante-Geral da Brigada Militar.$ENREV7$,
  $ENREV8$A respeito do Conselho Superior da Brigada Militar, conforme a Lei Complementar nº 16.450/2025, assinale a alternativa correta.$ENREV8$,
  $ENREV9$No âmbito da carreira dos Servidores Militares Estaduais de Nível Superior, assinale a alternativa que apresenta corretamente os quadros que compõem sua estrutura.$ENREV9$,
  $ENREV10$Considerando a inclusão no quadro de acesso destinado à promoção ao posto de Coronel, assinale a alternativa correta.$ENREV10$,
  $ENREV11$Para ingressar no Curso Superior de Polícia Militar, exige-se que o candidato seja aprovado em concurso público e possua qual formação?$ENREV11$,
  $ENREV12$Em relação à situação dos candidatos aprovados no concurso para ingresso no quadro de oficiais, assinale a alternativa correta quanto à denominação recebida durante a frequência do Curso Superior de Polícia Militar e à duração máxima desse curso.$ENREV12$,
  $ENREV13$No contexto das regras de promoção da carreira, assinale a situação em que um Capitão preenche, simultaneamente, as condições específicas exigidas para a promoção ao posto de Major.$ENREV13$,
  $ENREV14$Para que um Tenente-Coronel tenha acesso à promoção ao posto de Coronel, qual condição relativa à formação deve estar cumprida?$ENREV14$,
  $ENREV15$Assinale a alternativa que apresenta corretamente, de forma conjunta, as características do serviço policial-militar e da carreira de servidor militar.$ENREV15$,
  $ENREV16$Considerando as regras sobre os Oficiais nomeados Juízes do Tribunal Militar do Estado e sobre a precedência entre servidores militares, assinale a alternativa correta.$ENREV16$,
  $ENREV17$A respeito das consequências decorrentes da violação de obrigações e deveres policiais-militares, assinale a alternativa correta.$ENREV17$,
  $ENREV18$No rol de direitos dos servidores militares estaduais, assinale a alternativa que apresenta corretamente os direitos relacionados à inatividade e aos períodos de afastamento regular.$ENREV18$,
  $ENREV19$Quanto aos direitos assistenciais dos servidores militares estaduais, assinale a alternativa correta.$ENREV19$,
  $ENREV20$No tocante às sanções disciplinares e às respectivas formas de aplicação, assinale a alternativa correta.$ENREV20$,
  $ENREV21$Considerando as características da detenção e da prisão administrativa, assinale a alternativa correta.$ENREV21$,
  $ENREV22$Um militar estadual tomou conhecimento de fato contrário à disciplina e optou por comunicá-lo verbalmente ao seu superior imediato. Nessa situação, assinale a alternativa correta quanto à formalização da comunicação.$ENREV22$,
  $ENREV23$Em relação ao processo administrativo disciplinar militar, assinale a alternativa correta.$ENREV23$;

create temporary table _unidades_lote (unidade_pedagogica_id uuid) on commit drop;
insert into _unidades_lote (unidade_pedagogica_id) values
  ('3c033d9a-5543-422a-a935-c55095bdfc86'::uuid),
  ('9f8a76ec-2c8c-4bd8-9d72-9ecb7218a200'::uuid),
  ('bf13f365-3dd9-4d22-9ad7-f369a298eb19'::uuid),
  ('454f8501-7818-4dc4-b22a-337247678c58'::uuid);

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
