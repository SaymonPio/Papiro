-- REVERSAO REAL da IMPORTACAO LOTE05_PORTUGUES_AUTORAL. NUNCA executado
-- automaticamente. Disponivel para uso manual futuro caso a importacao
-- precise ser desfeita.
--
-- Identifica as 17 questoes pelo enunciado EXATO (congelado) + banca
-- 'Papiro' + vinculo a uma das 5 unidades do lote — nunca por um range
-- de ID. Remove nesta ordem: vinculo (RPC sancionada
-- remover_classificacao_questao_unidade_admin) -> curso_questoes ->
-- alternativas -> questoes.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _enunciados_lote (enunciado text) on commit drop;
insert into _enunciados_lote (enunciado) values
  $ENREV1$Em um relatório de ocorrência, lê-se: “Durante o atendimento, o policial sofreu um ferimento no braço”. Quanto à voz verbal, assinale a alternativa correta.$ENREV1$,
  $ENREV2$Assinale a alternativa que apresenta a transposição correta para a voz passiva analítica da oração: “A corregedoria analisará os documentos da apuração”.$ENREV2$,
  $ENREV3$Em comunicados internos de uma unidade policial, constam as seguintes construções:

I. Divulgaram-se os locais de apresentação dos candidatos.
II. Necessita-se de servidores para o atendimento administrativo.

Considerando a estrutura sintática e o sentido das orações, assinale a alternativa correta.$ENREV3$,
  $ENREV4$Assinale a alternativa que completa corretamente a frase abaixo, de acordo com a regência verbal na oração relativa.

"Os pareceres ______ a comissão se baseou para elaborar o relatório final serão encaminhados ao comando."$ENREV4$,
  $ENREV5$Assinale a alternativa redigida de acordo com a regência verbal prescrita pela norma-padrão.$ENREV5$,
  $ENREV6$Durante o plantão, a equipe registrou cuidadosamente as ocorrências no sistema. O termo que exerce a função de objeto direto do verbo “registrou” é:$ENREV6$,
  $ENREV7$A direção homenageou a todos os policiais que se destacaram na operação. Assinale a alternativa que classifica corretamente o termo destacado.$ENREV7$,
  $ENREV8$No comunicado interno, lê-se: “A Direção comunicou aos candidatos o novo horário da avaliação”. Assinale a alternativa correta acerca da expressão destacada e de sua substituição pronominal.$ENREV8$,
  $ENREV9$Considere a oração de um procedimento administrativo: “Os relatórios de ocorrência foram conferidos pela comissão designada”. Assinale a alternativa que identifica corretamente o agente da passiva e apresenta a conversão adequada da oração para a voz ativa.$ENREV9$,
  $ENREV10$Analise as ocorrências destacadas nos períodos a seguir.

I. “O comando necessita de reforço para o patrulhamento.”
II. “A necessidade de reforço para o patrulhamento foi comunicada aos setores responsáveis.”

Quanto à função sintática das expressões destacadas, assinale a alternativa correta.$ENREV10$,
  $ENREV11$Em uma comunicação interna, lê-se: “O levantamento preliminar indicou redução das ocorrências; contudo, a análise definitiva dependerá da conferência dos registros.”

Assinale a alternativa correta acerca do emprego de “contudo” no período.$ENREV11$,
  $ENREV12$Leia o trecho de um relatório institucional:

“Conquanto o efetivo estivesse reduzido, o atendimento às ocorrências prioritárias foi mantido. Quando a operação foi encerrada, os dados foram encaminhados ao comando.”

Assinale a alternativa que classifica corretamente as relações semânticas introduzidas pelos conectores destacados.$ENREV12$,
  $ENREV13$Em um comunicado interno, lê-se: “Conquanto a equipe tenha recebido orientações prévias, o treinamento prático será mantido”.

A conjunção “conquanto” estabelece, entre as ideias do período, uma relação de$ENREV13$,
  $ENREV14$No relatório de serviço, registrou-se que “a comunicação entre as equipes foi tão eficiente que reduziu o tempo de resposta às ocorrências”.

No período, a estrutura “tão...que” expressa uma relação de$ENREV14$,
  $ENREV15$Leia a frase a seguir.

“A unidade operacional, cujos registros de manutenção foram revisados pela corregedoria, encaminhou o relatório ao comando.”

Quanto ao emprego do pronome relativo “cujos”, assinale a alternativa correta.$ENREV15$,
  $ENREV16$Leia o trecho a seguir.

“Durante a preparação para a operação, o comando revisou os mapas de risco, atualizou a escala de serviço e distribuiu lanternas às equipes. Essas providências buscaram ampliar a segurança do patrulhamento noturno.”

No contexto, a expressão “Essas providências” exerce a função de$ENREV16$,
  $ENREV17$Leia a frase a seguir.

"O capitão encaminhou à analista o parecer cuja conclusão ele contestou antes da assinatura."

Considerando os mecanismos de coesão referencial, o pronome pessoal "ele" retoma$ENREV17$;

create temporary table _unidades_lote (unidade_pedagogica_id uuid) on commit drop;
insert into _unidades_lote (unidade_pedagogica_id) values
  ('1cb6bef3-1d8d-4cae-9ed9-eae9fe4d79b9'::uuid),
  ('735f736a-37c0-477f-a555-dcd73d243d21'::uuid),
  ('981e5d2c-3b59-48a0-a699-a53c03e500ee'::uuid),
  ('d1e31767-d27d-431b-ba59-7a2008c7473d'::uuid),
  ('29a4bec1-2c3a-40f3-a86f-fa6bda25d04f'::uuid);

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
  if v_qtd <> 17 then
    raise exception 'PRECOND: esperado localizar exatamente 17 questoes do lote, encontrado %', v_qtd;
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
  if v_count <> 17 then raise exception 'REVERSAO: vinculos removidos=% esperado 17', v_count; end if;
end $$;

do $$
declare v_count int;
begin
  delete from public.curso_questoes where curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and questao_id in (select questao_id from _alvo);
  get diagnostics v_count = row_count;
  if v_count <> 17 then raise exception 'REVERSAO: curso_questoes removidas=% esperado 17', v_count; end if;
end $$;

do $$
declare v_count int;
begin
  delete from public.alternativas where questao_id in (select questao_id from _alvo);
  get diagnostics v_count = row_count;
  if v_count <> 85 then raise exception 'REVERSAO: alternativas removidas=% esperado 85', v_count; end if;
end $$;

do $$
declare v_count int;
begin
  delete from public.questoes where id in (select questao_id from _alvo);
  get diagnostics v_count = row_count;
  if v_count <> 17 then raise exception 'REVERSAO: questoes removidas=% esperado 17', v_count; end if;
end $$;

commit;
