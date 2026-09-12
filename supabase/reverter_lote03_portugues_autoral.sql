-- REVERSAO REAL da IMPORTACAO LOTE03_PORTUGUES_AUTORAL. NUNCA executado
-- automaticamente. Disponivel para uso manual futuro caso a importacao
-- precise ser desfeita.
--
-- Identifica as 28 questoes pelo enunciado EXATO (congelado) + banca
-- 'Papiro' + vinculo a uma das 4 unidades do lote — nunca por um range
-- de ID. Remove nesta ordem: vinculo (RPC sancionada
-- remover_classificacao_questao_unidade_admin) -> curso_questoes ->
-- alternativas -> questoes.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _enunciados_lote (enunciado text) on commit drop;
insert into _enunciados_lote (enunciado) values
  $ENREV1$Leia o período a seguir.

“Durante a ocorrência, a guarnição isolou o local e registrou os dados das testemunhas.”

A análise correta da relação entre as orações do período é:$ENREV1$,
  $ENREV2$Leia o período a seguir.

“O rádio da viatura estava inoperante; portanto, a equipe utilizou o canal de reserva.”

Analise as afirmativas a respeito da relação entre as orações.

I. As orações são sintaticamente independentes, estabelecendo entre si uma relação de coordenação.

II. O conectivo “portanto” introduz uma conclusão decorrente da informação apresentada na oração anterior.

III. O conectivo “portanto” introduz uma justificativa para o fato de o rádio estar inoperante.

Quais afirmativas estão corretas?$ENREV2$,
  $ENREV3$Analise os períodos a seguir.

I. Não se aproxime, porque a área apresenta risco.
II. Porque a área apresentava risco, o acesso foi bloqueado.
III. Mantenha distância, que a área está isolada.

Considere as afirmativas a respeito da classificação das orações 'porque a área apresenta risco', 'Porque a área apresentava risco' e 'que a área está isolada', presentes, respectivamente, nos períodos I, II e III.

I. Em I e III, as orações introduzidas por “porque” e “que” são coordenadas sindéticas explicativas, pois justificam, respectivamente, a recomendação e a ordem expressas nas orações anteriores.
II. Em II, a oração introduzida por “Porque” é subordinada adverbial causal, pois indica a causa pela qual o acesso foi bloqueado.
III. A presença de “porque”, por si só, não determina a classificação da oração: é necessário verificar se ela explica uma enunciação independente ou se integra a estrutura da oração principal como circunstância de causa.

Quais estão corretas?$ENREV3$,
  $ENREV4$Analise os períodos a seguir.

I. Como a visibilidade diminuiu, a equipe reduziu a velocidade da viatura.
II. Embora a visibilidade tenha diminuído, a equipe seguiu para o local da ocorrência.
III. A operação foi adiada porque a visibilidade diminuiu.

Avalie as afirmativas.

I. As orações "Como a visibilidade diminuiu", em I, e "porque a visibilidade diminuiu", em III, são subordinadas adverbiais causais, pois apresentam a razão pela qual ocorreram, respectivamente, a redução da velocidade e o adiamento da operação.
II. A oração "Embora a visibilidade tenha diminuído", em II, é subordinada adverbial concessiva, porque apresenta uma circunstância que poderia dificultar o deslocamento, mas não impediu que a equipe seguisse para o local.
III. A diferença entre causa e concessão depende da relação lógica estabelecida: a causa explica a ocorrência do fato principal, enquanto a concessão apresenta um obstáculo que não impede sua realização.

Quais estão corretas?$ENREV4$,
  $ENREV5$Leia o período elaborado em contexto institucional:

“Caso o efetivo seja convocado, os policiais deverão apresentar-se no horário determinado.”

Assinale a alternativa correta acerca da oração destacada.$ENREV5$,
  $ENREV6$No período abaixo, a oração subordinada substantiva está destacada:

“A chefia manifestou a convicção de que a medida preventiva reduziria os riscos da operação.”

A oração “de que a medida preventiva reduziria os riscos da operação” classifica-se como subordinada substantiva$ENREV6$,
  $ENREV7$Leia a frase a seguir.

"Os candidatos que apresentaram a documentação completa seguiram para a etapa seguinte."

A oração "que apresentaram a documentação completa" é corretamente classificada como$ENREV7$,
  $ENREV8$Assinale a alternativa em que a pontuação está corretamente empregada.$ENREV8$,
  $ENREV9$Em relação ao emprego da vírgula em períodos com orações adverbiais deslocadas, assinale a alternativa em que a pontuação está INCORRETA.$ENREV9$,
  $ENREV10$No trecho abaixo, a oração introduzida por “que” tem valor explicativo, acrescentando uma informação sobre a totalidade da equipe de atendimento da unidade. Assinale a alternativa em que essa oração está corretamente isolada por vírgulas.

“A equipe de atendimento da unidade ___ já havia concluído o registro preliminar ___ encaminhou o comunicado ao setor responsável.”$ENREV10$,
  $ENREV11$Observe as duas redações a seguir.

I. Os candidatos que entregaram a documentação completa seguiram para a etapa seguinte.
II. Os candidatos, que entregaram a documentação completa, seguiram para a etapa seguinte.

Considerando o efeito de sentido produzido pela pontuação, assinale a alternativa correta.$ENREV11$,
  $ENREV12$Assinale a alternativa em que o emprego da vírgula está incorreto por separar indevidamente o sujeito de seu verbo.$ENREV12$,
  $ENREV13$Analise as afirmativas relativas ao emprego da vírgula.

I. Em “A guarnição entregou, o relatório ao superior”, a vírgula é inadequada, pois separa o verbo “entregou” de seu complemento direto.

II. Em “A guarnição entregou ao superior, após a conferência dos dados, o relatório”, as vírgulas isolam adequadamente o adjunto adverbial intercalado “após a conferência dos dados”.

III. Em “Os policiais receberam, ao final da reunião, as novas instruções”, as vírgulas isolam adequadamente o adjunto adverbial intercalado.

IV. Em “O superior solicitou, informações complementares”, a vírgula é adequada, pois separa o verbo de uma informação que o completa.

Quais afirmativas estão corretas?$ENREV13$,
  $ENREV14$Analise as frases quanto à pontuação das orações adverbiais deslocadas ou intercaladas.

I. Depois que o perímetro foi isolado, os policiais iniciaram a averiguação.

II. Os policiais, enquanto aguardavam reforço, mantiveram o bloqueio da via.

III. Caso a visibilidade diminua durante o deslocamento da equipe a patrulha reduzirá a velocidade.

IV. A patrulha seguirá, caso as condições da via permitam, até o ponto indicado.

Quais frases estão corretamente pontuadas?$ENREV14$,
  $ENREV15$Leia a frase a seguir.

"Antes da operação, o soldado conferiu o peso do colete de proteção." 

No contexto apresentado, a palavra "peso" foi empregada em sentido denotativo porque se refere$ENREV15$,
  $ENREV16$Leia a frase a seguir.

"O relatório da corregedoria foi um farol para a revisão dos procedimentos internos." 

No contexto apresentado, a expressão "foi um farol" indica que o relatório$ENREV16$,
  $ENREV17$Considere as ocorrências da palavra “linha” nas frases a seguir.

I. Os candidatos permaneceram atrás da linha de segurança durante a instrução.
II. A equipe seguiu uma nova linha de investigação após analisar as imagens.

Quanto aos sentidos assumidos pela palavra “linha”, assinale a alternativa correta.$ENREV17$,
  $ENREV18$Analise as frases a seguir, considerando o emprego das expressões destacadas.

I. A sirene emitiu um **grito** prolongado.
II. O agente guardou o **colete** no armário.
III. Após a notícia, o silêncio **pesou** na sala.
IV. O mecânico substituiu a **corrente** da motocicleta.

Em quais frases o emprego destacado é conotativo?$ENREV18$,
  $ENREV19$Analise as frases a seguir quanto ao emprego das expressões destacadas.

I. O perito recolheu a **lanterna** que estava sobre a mesa.
II. A notícia **voou** pelo quartel antes do comunicado oficial.
III. A decisão deixou um **gosto amargo** entre os servidores.
IV. A viatura parou diante do **prédio** administrativo.

Assinale a alternativa que apresenta a análise correta, considerando apenas a distinção entre sentido literal e sentido figurado.$ENREV19$,
  $ENREV20$Em cada alternativa, a palavra ou expressão destacada foi classificada quanto ao sentido empregado na frase. Assinale a alternativa em que a classificação está INCORRETA.$ENREV20$,
  $ENREV21$Considere as ocorrências da palavra **raiz** nas frases a seguir.

I. As crianças observaram a **raiz** exposta da árvore após a chuva forte.
II. A falta de diálogo era a **raiz** do desentendimento entre os vizinhos.

Assinale a alternativa correta quanto ao sentido de “raiz” nos dois contextos.$ENREV21$,
  $ENREV22$No trecho de uma comunicação interna, assinale a alternativa que completa corretamente a lacuna, de acordo com a norma-padrão tradicional: “O servidor que ___ o comunicado deverá registrar a entrega no sistema.”$ENREV22$,
  $ENREV23$Na norma-padrão tradicional, complete o período a seguir, mantendo o advérbio **ali** sem pausa e o verbo no pretérito imperfeito:

“Ali ___ os policiais responsáveis pela escolta.”

Assinale a alternativa correta.$ENREV23$,
  $ENREV24$Assinale a alternativa que completa corretamente o período de acordo com a norma-padrão tradicional:

“O setor nunca ___ a confirmação da inscrição.”$ENREV24$,
  $ENREV25$Assinale a alternativa que completa corretamente a frase, de acordo com a norma-padrão tradicional de colocação pronominal:

“A comissão informará ________ a lista final.”$ENREV25$,
  $ENREV26$Considerando-se a norma-padrão tradicional cobrada em concursos, assinale a alternativa que reescreve corretamente a oração abaixo, substituindo “o documento” pelo pronome oblíquo átono adequado.

“Em frase isolada, sem qualquer fator de próclise, a direção entregará o documento ao candidato.”$ENREV26$,
  $ENREV27$Em uma ordem dirigida diretamente a um soldado, deve-se empregar o verbo apresentar no imperativo afirmativo, acompanhado do pronome oblíquo átono se. Considerando a norma-padrão tradicional, assinale a redação correta.$ENREV27$,
  $ENREV28$Considerando a norma-padrão tradicional e mantendo o verbo no pretérito perfeito do indicativo, assinale a alternativa correta quanto à colocação do pronome oblíquo átono.$ENREV28$;

create temporary table _unidades_lote (unidade_pedagogica_id uuid) on commit drop;
insert into _unidades_lote (unidade_pedagogica_id) values
  ('bfeaf283-09fc-4f14-9d0c-41ff0db4eab7'::uuid),
  ('dca4fe2e-50e9-41db-abeb-0ef6b388c5af'::uuid),
  ('f1377f8b-348e-4da6-9713-e901ce5ea516'::uuid),
  ('c03b4993-601a-4c1e-b24d-c9e09d01db84'::uuid);

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
  if v_qtd <> 28 then
    raise exception 'PRECOND: esperado localizar exatamente 28 questoes do lote, encontrado %', v_qtd;
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
  if v_count <> 28 then raise exception 'REVERSAO: vinculos removidos=% esperado 28', v_count; end if;
end $$;

do $$
declare v_count int;
begin
  delete from public.curso_questoes where curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and questao_id in (select questao_id from _alvo);
  get diagnostics v_count = row_count;
  if v_count <> 28 then raise exception 'REVERSAO: curso_questoes removidas=% esperado 28', v_count; end if;
end $$;

do $$
declare v_count int;
begin
  delete from public.alternativas where questao_id in (select questao_id from _alvo);
  get diagnostics v_count = row_count;
  if v_count <> 140 then raise exception 'REVERSAO: alternativas removidas=% esperado 140', v_count; end if;
end $$;

do $$
declare v_count int;
begin
  delete from public.questoes where id in (select questao_id from _alvo);
  get diagnostics v_count = row_count;
  if v_count <> 28 then raise exception 'REVERSAO: questoes removidas=% esperado 28', v_count; end if;
end $$;

commit;
