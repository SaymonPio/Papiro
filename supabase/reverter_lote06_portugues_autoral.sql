-- REVERSAO REAL da IMPORTACAO LOTE06_PORTUGUES_AUTORAL. NUNCA executado
-- automaticamente. Disponivel para uso manual futuro caso a importacao
-- precise ser desfeita.
--
-- Identifica as 6 questoes pelo enunciado EXATO (congelado) + banca
-- 'Papiro' + vinculo a unidade Redação oficial — nunca por um range de ID.
-- Remove nesta ordem: vinculo (RPC sancionada
-- remover_classificacao_questao_unidade_admin) -> curso_questoes ->
-- alternativas -> questoes.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _enunciados_lote (enunciado text) on commit drop;
insert into _enunciados_lote (enunciado) values
  $ENREV1$Ao redigir um ofício da Brigada Militar destinado à Secretaria de Segurança Pública, um servidor deve preencher o campo assunto para informar, de modo sintético, o teor da comunicação. Assinale a alternativa que apresenta a formatação adequada desse campo, conforme o Manual de Redação da Presidência da República.$ENREV1$,
  $ENREV2$O Comandante de uma unidade da Brigada Militar encaminhará ofício ao Presidente da República. Considerando as regras do Manual de Redação da Presidência da República quanto ao fecho e à identificação do signatário, assinale a alternativa que apresenta o encerramento corretamente redigido.$ENREV2$,
  $ENREV3$Uma unidade administrativa da Brigada Militar pretende divulgar orientações sobre o acesso a um serviço eletrônico e, simultaneamente, encaminhar informações técnicas a outro órgão público. Considerando a definição de comunicação administrativa e o princípio da impessoalidade, assinale a alternativa correta.$ENREV3$,
  $ENREV4$Em uma capacitação sobre redação oficial, um servidor afirmou que o mnemônico “C-P-O-C-I” — clareza, precisão, objetividade, concisão e impessoalidade — esgota todos os atributos exigidos para a elaboração de comunicações oficiais. À luz do Manual de Redação da Presidência da República, assinale a alternativa correta.$ENREV4$,
  $ENREV5$Considerando exclusivamente a disciplina do Decreto nº 9.758/2019, assinale a alternativa correta acerca das comunicações escritas dirigidas a agentes públicos da administração pública federal direta e indireta.$ENREV5$,
  $ENREV6$À luz do Decreto nº 9.758/2019, que disciplina as comunicações com agentes públicos da administração pública federal, assinale a alternativa que apresenta formas incompatíveis com o padrão de tratamento instituído pelo decreto.$ENREV6$;

create temporary table _alvo (questao_id bigint primary key, unidade_pedagogica_id uuid) on commit drop;
insert into _alvo (questao_id, unidade_pedagogica_id)
select distinct q.id, qup.unidade_pedagogica_id
from public.questoes q
join public.questao_unidades_pedagogicas qup on qup.questao_id = q.id
where coalesce(lower(q.banca),'') like '%papiro%'
  and lower(q.enunciado) in (select lower(enunciado) from _enunciados_lote)
  and qup.unidade_pedagogica_id = '29bfb433-4013-4164-85de-fd847963199d';

do $$
declare v_qtd int;
begin
  select count(*) into v_qtd from _alvo;
  if v_qtd <> 6 then
    raise exception 'PRECOND: esperado localizar exatamente 6 questoes do lote, encontrado %', v_qtd;
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
  if v_count <> 6 then raise exception 'REVERSAO: vinculos removidos=% esperado 6', v_count; end if;
end $$;

do $$
declare v_count int;
begin
  delete from public.curso_questoes where curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and questao_id in (select questao_id from _alvo);
  get diagnostics v_count = row_count;
  if v_count <> 6 then raise exception 'REVERSAO: curso_questoes removidas=% esperado 6', v_count; end if;
end $$;

do $$
declare v_count int;
begin
  delete from public.alternativas where questao_id in (select questao_id from _alvo);
  get diagnostics v_count = row_count;
  if v_count <> 30 then raise exception 'REVERSAO: alternativas removidas=% esperado 30', v_count; end if;
end $$;

do $$
declare v_count int;
begin
  delete from public.questoes where id in (select questao_id from _alvo);
  get diagnostics v_count = row_count;
  if v_count <> 6 then raise exception 'REVERSAO: questoes removidas=% esperado 6', v_count; end if;
end $$;

commit;
