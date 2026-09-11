-- REVERSAO REAL da IMPORTACAO LOTE02_PORTUGUES_AUTORAL. NUNCA executado
-- automaticamente. Disponivel para uso manual futuro caso a importacao
-- precise ser desfeita.
--
-- Identifica as 24 questoes pelo enunciado EXATO (congelado) + banca
-- 'Papiro' + vinculo a uma das 4 unidades do lote — nunca por um range
-- de ID. Remove nesta ordem: vinculo (RPC sancionada) -> curso_questoes
-- -> alternativas -> questoes.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _enunciados_lote (enunciado text) on commit drop;
insert into _enunciados_lote (enunciado) values
  $ENREV1$Assinale a alternativa que apresenta a transposição correta para a voz passiva analítica da frase “A comissão revisava os procedimentos mensalmente”, preservando o tempo verbal e o sentido original.$ENREV1$,
  $ENREV2$Considere a frase ativa “As servidoras organizam o arquivo” e as seguintes propostas de reescrita na voz passiva analítica:

I. O arquivo é organizado pelas servidoras.
II. O arquivo é organizado para as servidoras.
III. Pelas servidoras, foi organizado o arquivo.
IV. Pelas servidoras, o arquivo é organizado.

Quais propostas introduzem corretamente o agente da passiva e preservam o sentido da frase original?$ENREV2$,
  $ENREV3$Considere o período na voz ativa:

“A equipe de inspeção lacrou o depósito, a equipe de inspeção catalogava os materiais e a equipe de inspeção encaminhará o relatório.”

Foi proposta a seguinte reescrita na voz passiva analítica:

“O depósito foi lacrado pela equipe de inspeção, os materiais foram catalogados pela equipe de inspeção e o relatório será encaminhado pela equipe de inspeção.”

Assinale a alternativa que avalia corretamente essa reescrita.$ENREV3$,
  $ENREV4$Considere a frase original e a proposta de reescrita:

Original: “O instrutor orientou os recrutas durante o exercício.”

Proposta: “O instrutor foi orientado pelos recrutas durante o exercício.”

Assinale a alternativa que identifica corretamente o problema da proposta.$ENREV4$,
  $ENREV5$Considere as frases a seguir:

I. Os peritos examinaram os documentos apreendidos.
II. Os soldados chegaram ao quartel antes do amanhecer.
III. A comissão concedeu medalhas aos agentes.
IV. Os moradores necessitam de proteção constante.

Quais frases admitem transposição natural e gramaticalmente adequada para a voz passiva analítica?$ENREV5$,
  $ENREV6$Considere a frase a seguir:

“Durante a operação, os agentes localizaram o veículo e entregaram as provas ao delegado.”

Assinale a alternativa que apresenta a transposição para a voz passiva analítica preservando integralmente o tempo verbal, os papéis semânticos e a indicação de quem praticou as ações.$ENREV6$,
  $ENREV7$Considere a frase: “A equipe de perícia recolheu, somente ao amanhecer e sob forte chuva, os vestígios deixados na estrada.” Assinale a alternativa que apresenta a correta transposição dessa frase para a voz passiva analítica, sem alteração do sentido original.$ENREV7$,
  $ENREV8$Considere a frase na voz ativa: “A equipe técnica refez as medições.” Na transposição para a voz passiva analítica, o auxiliar já foi corretamente empregado: “As medições foram ______ pela equipe técnica.” Assinale a alternativa que preenche corretamente a lacuna.$ENREV8$,
  $ENREV9$Em um treinamento sobre atendimento a ocorrências, a instrutora afirmou que a rapidez é importante, mas não substitui a escuta atenta. Ela orientou os agentes a registrar as informações essenciais antes de encaminhar cada caso. Nas simulações, as equipes que confirmaram os dados cometeram menos falhas de comunicação. Ao final, a instrutora recomendou que o protocolo fosse revisto periodicamente, sem o abandono das etapas de conferência.

Assinale a alternativa que contraria diretamente uma informação explícita do texto.$ENREV9$,
  $ENREV10$Leia o texto a seguir.

A ampliação do horário de funcionamento das bibliotecas municipais pode facilitar o acesso de trabalhadores que não conseguem frequentá-las durante o dia, desde que a medida seja acompanhada por transporte noturno adequado e por equipes suficientes para atender o público. Sem essas condições, a mudança tende a beneficiar sobretudo os moradores das proximidades, produzindo um alcance mais limitado.

Assinale a alternativa que representa corretamente o conteúdo do texto.$ENREV10$,
  $ENREV11$Leia o texto a seguir.

Durante três meses, uma unidade de saúde passou a enviar lembretes de consultas com 48 horas de antecedência. No período, foram mantidos os mesmos horários de atendimento, a mesma equipe e os mesmos critérios de agendamento. A proporção de faltas caiu de 22% para 14%. Uma pesquisa posterior revelou, porém, que alguns usuários, por estarem com os dados de contato desatualizados, não receberam as mensagens. Entre os que confirmaram o recebimento, a redução das faltas foi mais acentuada. Os dados disponíveis não permitem saber se o resultado se manterá por períodos mais longos.

Considere as seguintes afirmativas:

I. Os dados sustentam a inferência de que os lembretes podem ter contribuído para a redução das faltas, embora não demonstrem que tenham sido sua única causa.
II. Todos os usuários que receberam os lembretes compareceram às consultas marcadas.
III. A manutenção dos horários, da equipe e dos critérios de agendamento reforça a interpretação de que a introdução dos lembretes está relacionada à mudança observada.
IV. A atualização dos dados de contato de todos os usuários eliminaria definitivamente as faltas às consultas.

Quais afirmativas apresentam inferências válidas com base no texto?$ENREV11$,
  $ENREV12$Leia o texto a seguir:

Em instituições de segurança, a comunicação com a comunidade não deve ocorrer apenas em momentos de crise; ela precisa integrar permanentemente a prestação do serviço. Informações claras sobre mudanças de circulação ou ações preventivas, por exemplo, ajudam os moradores a organizar sua rotina. Além disso, explicar os objetivos e os limites de uma operação reduz rumores e favorece a cooperação. Por isso, avisos sobre bloqueios temporários devem ser divulgados com antecedência, sempre que possível.

Assinale a alternativa que expressa corretamente a tese defendida no texto.$ENREV12$,
  $ENREV13$Leia o texto a seguir:

Em um centro de formação, a redução de desperdícios começou com a instalação de recipientes para separar resíduos. Nas primeiras semanas, porém, o volume enviado ao descarte comum quase não mudou. A equipe então passou a orientar os usuários, reposicionou os coletores e acompanhou mensalmente os resultados. Com essas medidas articuladas, a separação melhorou de forma gradual. A experiência mostrou que equipamentos, sozinhos, não alteram hábitos: mudanças consistentes dependem também de orientação e acompanhamento.

Considerando a compreensão global do texto, assinale a alternativa correta.$ENREV13$,
  $ENREV14$Leia o texto a seguir.

Durante seis meses, metade das luminárias de um bairro foi substituída por modelos direcionados para o chão. Nas vias atendidas, o consumo de energia caiu 18%, e as reclamações de moradores sobre luz excessiva dentro das residências tornaram-se menos frequentes. A mudança, contudo, não eliminou todas as queixas. Alguns comerciantes perceberam maior circulação de pedestres ao anoitecer, mas o relatório do projeto considerou insuficientes os dados disponíveis para atribuir esse movimento à nova iluminação.

Com base exclusivamente no texto, analise as seguintes assertivas:

I. A substituição das luminárias reduziu o consumo de energia e a frequência de determinadas reclamações nas vias atendidas.
II. O relatório comprovou que a nova iluminação foi responsável pelo aumento da circulação de pedestres.
III. Nas vias atendidas, as reclamações sobre luz excessiva dentro das residências tornaram-se mais frequentes.
IV. O único resultado observado após a substituição das luminárias foi a redução do consumo de energia.

Quais assertivas são efetivamente sustentadas pelo texto?$ENREV14$,
  $ENREV15$Leia o texto a seguir.

Uma escola realizou, por três meses, um projeto de empréstimo de tablets aos estudantes. Ao fim da experiência, o número de participantes permaneceu estável, mas a proporção de tarefas entregues no prazo passou de 62% para 81%. A coordenadora decidiu manter o projeto precisamente porque esse aumento indicava maior regularidade no acesso aos materiais fora da sala de aula. Os estudantes também elogiaram os tutoriais instalados nos aparelhos, e a equipe estuda ampliar o prazo de empréstimo na próxima etapa.

De acordo com o texto, qual dado foi apresentado como razão direta para a decisão de manter o projeto?$ENREV15$,
  $ENREV16$Assinale a alternativa que preenche, correta e respectivamente, as lacunas da frase a seguir.

As metas ___ a equipe aspirava, os recursos ___ os agentes contavam e o procedimento ___ o instrutor insistia foram registrados no relatório.$ENREV16$,
  $ENREV17$Considerando as regras de emprego do pronome relativo “cujo” e suas flexões, assinale a alternativa correta.$ENREV17$,
  $ENREV18$Assinale a alternativa que preenche correta e respectivamente as lacunas, de acordo com a regência do verbo “assistir” no padrão formal da Língua Portuguesa.

I. Após o treinamento, os soldados assistiram ___ documentário sobre segurança pública.
II. Durante o acidente, os socorristas assistiram ___ feridos até a chegada da equipe médica.$ENREV18$,
  $ENREV19$Analise as afirmativas a seguir quanto à regência dos verbos “obedecer” e “desobedecer” no padrão formal da Língua Portuguesa.

I. Os soldados obedeceram ao regulamento durante a operação.
II. O candidato desobedeceu o comando do instrutor.
III. Os subordinados devem obedecer aos superiores hierárquicos.
IV. O agente jamais desobedeceu ao protocolo de segurança.

Quais afirmativas estão corretas?$ENREV19$,
  $ENREV20$Assinale a alternativa em que o verbo “preferir” foi empregado corretamente de acordo com a norma-padrão tradicional.$ENREV20$,
  $ENREV21$Considere as seguintes orações:

I. Durante a inspeção, os fiscais vistoriaram cuidadosamente o local.
II. O local foi vistoriado pelos fiscais durante a inspeção.
III. A comissão aprovou, por unanimidade, o novo relatório.
IV. O relatório foi aprovado por unanimidade.

Quais estão construídas na voz ativa?$ENREV21$,
  $ENREV22$Considere a oração na voz ativa e a proposta de transposição para a voz passiva analítica:

Voz ativa: “A equipe de investigação conferia os registros todas as manhãs.”

Proposta: “Os registros foram conferidos pela equipe de investigação todas as manhãs.”

À luz da norma-padrão, assinale a alternativa que avalia corretamente a proposta.$ENREV22$,
  $ENREV23$Assinale a alternativa que preenche corretamente a lacuna, empregando a voz passiva sintética e o pretérito perfeito do indicativo.

“__________ novos equipamentos de comunicação para a unidade na semana passada.”$ENREV23$,
  $ENREV24$Considere as frases a seguir.

1. Divulgaram-se novas instruções aos integrantes da unidade.
2. Confia-se em profissionais experientes durante operações delicadas.

Analise as seguintes afirmativas:

I. Na frase 1, o pronome “se” é apassivador, e “novas instruções” funciona como sujeito paciente.
II. Na frase 1, o plural de “divulgaram-se” decorre da concordância com “novas instruções”.
III. Na frase 2, o pronome “se” é índice de indeterminação do sujeito, e o verbo deve permanecer na terceira pessoa do singular.
IV. Na frase 2, o plural de “profissionais experientes” exigiria a forma “confiam-se”.

Quais afirmativas estão corretas?$ENREV24$;

create temporary table _alvo (questao_id bigint primary key, unidade_pedagogica_id uuid) on commit drop;
insert into _alvo (questao_id, unidade_pedagogica_id)
select q.id, qup.unidade_pedagogica_id from public.questoes q
join public.questao_unidades_pedagogicas qup on qup.questao_id = q.id
where q.ativa = true
and coalesce(lower(q.banca),'') like '%papiro%'
and q.enunciado in (select enunciado from _enunciados_lote)
and qup.unidade_pedagogica_id in ('5cc30e49-890f-4b83-b96f-31724024ee24', '138aafa7-066c-40fd-9fa5-7f1b90406db2', '735f736a-37c0-477f-a555-dcd73d243d21', '1cb6bef3-1d8d-4cae-9ed9-eae9fe4d79b9');

-- ================= GUARD =================
do $$
declare
  v_n int;
begin
  select count(*) into v_n from _alvo;
  if v_n <> 24 then raise exception 'GUARD: % questao(oes) encontradas pelo enunciado congelado, esperado exatamente 24 — abortando reversao', v_n; end if;

  if (select count(*) from public.alternativas a join _alvo x on x.questao_id = a.questao_id) <> 120 then
    raise exception 'GUARD: total de alternativas das 24 nao e 120 — abortando reversao';
  end if;

  raise notice 'GUARD OK: 24 questoes encontradas pelo enunciado congelado, 120 alternativas';
end $$;

-- ================= REVERSAO =================
do $$
declare
  r record;
  v_count int := 0;
begin
  for r in select questao_id, unidade_pedagogica_id from _alvo loop
    perform public.remover_classificacao_questao_unidade_admin(r.questao_id, r.unidade_pedagogica_id);
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
  if v_count <> 24 then raise exception 'REVERSAO: % curso_questoes removidas, esperado 24', v_count; end if;
  raise notice 'REVERSAO: % linha(s) removidas de curso_questoes', v_count;
end $$;

do $$
declare
  v_count int;
begin
  delete from public.alternativas where questao_id in (select questao_id from _alvo);
  get diagnostics v_count = row_count;
  if v_count <> 120 then raise exception 'REVERSAO: % alternativas removidas, esperado 120', v_count; end if;
  raise notice 'REVERSAO: % alternativa(s) removida(s)', v_count;
end $$;

do $$
declare
  v_count int;
begin
  delete from public.questoes where id in (select questao_id from _alvo);
  get diagnostics v_count = row_count;
  if v_count <> 24 then raise exception 'REVERSAO: % questoes removidas, esperado 24', v_count; end if;
  raise notice 'REVERSAO: % questao(oes) removida(s)', v_count;
end $$;

-- ================= POS-CHECK DA REVERSAO =================
do $$
declare
  v_uteis int;
  r record;
begin
  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='5cc30e49-890f-4b83-b96f-31724024ee24' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  if v_uteis <> 2 then raise exception 'POSCOND: uteis unidade Reescrita de frases e textos apos reversao=% esperado 2', v_uteis; end if;

  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='138aafa7-066c-40fd-9fa5-7f1b90406db2' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  if v_uteis <> 3 then raise exception 'POSCOND: uteis unidade Interpretação de textos apos reversao=% esperado 3', v_uteis; end if;

  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='735f736a-37c0-477f-a555-dcd73d243d21' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  if v_uteis <> 3 then raise exception 'POSCOND: uteis unidade Regência verbal e nominal apos reversao=% esperado 3', v_uteis; end if;

  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='1cb6bef3-1d8d-4cae-9ed9-eae9fe4d79b9' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  if v_uteis <> 3 then raise exception 'POSCOND: uteis unidade Vozes verbais apos reversao=% esperado 3', v_uteis; end if;

  raise notice 'POSCONDICOES OK: todas as 4 unidades restauradas aos totais uteis originais';
end $$;

commit;
