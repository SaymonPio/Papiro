-- POS-CHECK — importacao LOTE03_PORTUGUES_AUTORAL.
--
-- READ-ONLY. Confirma, independentemente do apply, o estado das 28
-- questoes autorais nas 4 unidades. Nao corrige nada.

select
  q.id as questao_id,
  q.ativa,
  q.dificuldade,
  coalesce(lower(q.banca),'') like '%papiro%' as autoral,
  (select count(*) from public.alternativas a where a.questao_id = q.id) as n_alternativas,
  (select count(*) from public.alternativas a where a.questao_id = q.id and a.correta) as n_corretas,
  (select chr(64+ordem) from public.alternativas where questao_id=q.id and correta=true) as gabarito,
  (select up.titulo from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where qup.questao_id = q.id limit 1) as unidade_vinculada,
  (select count(*) from public.questao_unidades_pedagogicas qup where qup.questao_id = q.id) as n_vinculos_totais,
  exists(
    select 1 from public.curso_questoes cq
    where cq.curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id = q.id
  ) as ok_curso_questoes,
  q.explicacao is not null and length(q.explicacao) > 0 as ok_explicacao
from public.questoes q
where q.enunciado in (
  $PC1$Leia o período a seguir.

“Durante a ocorrência, a guarnição isolou o local e registrou os dados das testemunhas.”

A análise correta da relação entre as orações do período é:$PC1$,
  $PC2$Leia o período a seguir.

“O rádio da viatura estava inoperante; portanto, a equipe utilizou o canal de reserva.”

Analise as afirmativas a respeito da relação entre as orações.

I. As orações são sintaticamente independentes, estabelecendo entre si uma relação de coordenação.

II. O conectivo “portanto” introduz uma conclusão decorrente da informação apresentada na oração anterior.

III. O conectivo “portanto” introduz uma justificativa para o fato de o rádio estar inoperante.

Quais afirmativas estão corretas?$PC2$,
  $PC3$Analise os períodos a seguir.

I. Não se aproxime, porque a área apresenta risco.
II. Porque a área apresentava risco, o acesso foi bloqueado.
III. Mantenha distância, que a área está isolada.

Considere as afirmativas a respeito da classificação das orações 'porque a área apresenta risco', 'Porque a área apresentava risco' e 'que a área está isolada', presentes, respectivamente, nos períodos I, II e III.

I. Em I e III, as orações introduzidas por “porque” e “que” são coordenadas sindéticas explicativas, pois justificam, respectivamente, a recomendação e a ordem expressas nas orações anteriores.
II. Em II, a oração introduzida por “Porque” é subordinada adverbial causal, pois indica a causa pela qual o acesso foi bloqueado.
III. A presença de “porque”, por si só, não determina a classificação da oração: é necessário verificar se ela explica uma enunciação independente ou se integra a estrutura da oração principal como circunstância de causa.

Quais estão corretas?$PC3$,
  $PC4$Analise os períodos a seguir.

I. Como a visibilidade diminuiu, a equipe reduziu a velocidade da viatura.
II. Embora a visibilidade tenha diminuído, a equipe seguiu para o local da ocorrência.
III. A operação foi adiada porque a visibilidade diminuiu.

Avalie as afirmativas.

I. As orações "Como a visibilidade diminuiu", em I, e "porque a visibilidade diminuiu", em III, são subordinadas adverbiais causais, pois apresentam a razão pela qual ocorreram, respectivamente, a redução da velocidade e o adiamento da operação.
II. A oração "Embora a visibilidade tenha diminuído", em II, é subordinada adverbial concessiva, porque apresenta uma circunstância que poderia dificultar o deslocamento, mas não impediu que a equipe seguisse para o local.
III. A diferença entre causa e concessão depende da relação lógica estabelecida: a causa explica a ocorrência do fato principal, enquanto a concessão apresenta um obstáculo que não impede sua realização.

Quais estão corretas?$PC4$,
  $PC5$Leia o período elaborado em contexto institucional:

“Caso o efetivo seja convocado, os policiais deverão apresentar-se no horário determinado.”

Assinale a alternativa correta acerca da oração destacada.$PC5$,
  $PC6$No período abaixo, a oração subordinada substantiva está destacada:

“A chefia manifestou a convicção de que a medida preventiva reduziria os riscos da operação.”

A oração “de que a medida preventiva reduziria os riscos da operação” classifica-se como subordinada substantiva$PC6$,
  $PC7$Leia a frase a seguir.

"Os candidatos que apresentaram a documentação completa seguiram para a etapa seguinte."

A oração "que apresentaram a documentação completa" é corretamente classificada como$PC7$,
  $PC8$Assinale a alternativa em que a pontuação está corretamente empregada.$PC8$,
  $PC9$Em relação ao emprego da vírgula em períodos com orações adverbiais deslocadas, assinale a alternativa em que a pontuação está INCORRETA.$PC9$,
  $PC10$No trecho abaixo, a oração introduzida por “que” tem valor explicativo, acrescentando uma informação sobre a totalidade da equipe de atendimento da unidade. Assinale a alternativa em que essa oração está corretamente isolada por vírgulas.

“A equipe de atendimento da unidade ___ já havia concluído o registro preliminar ___ encaminhou o comunicado ao setor responsável.”$PC10$,
  $PC11$Observe as duas redações a seguir.

I. Os candidatos que entregaram a documentação completa seguiram para a etapa seguinte.
II. Os candidatos, que entregaram a documentação completa, seguiram para a etapa seguinte.

Considerando o efeito de sentido produzido pela pontuação, assinale a alternativa correta.$PC11$,
  $PC12$Assinale a alternativa em que o emprego da vírgula está incorreto por separar indevidamente o sujeito de seu verbo.$PC12$,
  $PC13$Analise as afirmativas relativas ao emprego da vírgula.

I. Em “A guarnição entregou, o relatório ao superior”, a vírgula é inadequada, pois separa o verbo “entregou” de seu complemento direto.

II. Em “A guarnição entregou ao superior, após a conferência dos dados, o relatório”, as vírgulas isolam adequadamente o adjunto adverbial intercalado “após a conferência dos dados”.

III. Em “Os policiais receberam, ao final da reunião, as novas instruções”, as vírgulas isolam adequadamente o adjunto adverbial intercalado.

IV. Em “O superior solicitou, informações complementares”, a vírgula é adequada, pois separa o verbo de uma informação que o completa.

Quais afirmativas estão corretas?$PC13$,
  $PC14$Analise as frases quanto à pontuação das orações adverbiais deslocadas ou intercaladas.

I. Depois que o perímetro foi isolado, os policiais iniciaram a averiguação.

II. Os policiais, enquanto aguardavam reforço, mantiveram o bloqueio da via.

III. Caso a visibilidade diminua durante o deslocamento da equipe a patrulha reduzirá a velocidade.

IV. A patrulha seguirá, caso as condições da via permitam, até o ponto indicado.

Quais frases estão corretamente pontuadas?$PC14$,
  $PC15$Leia a frase a seguir.

"Antes da operação, o soldado conferiu o peso do colete de proteção." 

No contexto apresentado, a palavra "peso" foi empregada em sentido denotativo porque se refere$PC15$,
  $PC16$Leia a frase a seguir.

"O relatório da corregedoria foi um farol para a revisão dos procedimentos internos." 

No contexto apresentado, a expressão "foi um farol" indica que o relatório$PC16$,
  $PC17$Considere as ocorrências da palavra “linha” nas frases a seguir.

I. Os candidatos permaneceram atrás da linha de segurança durante a instrução.
II. A equipe seguiu uma nova linha de investigação após analisar as imagens.

Quanto aos sentidos assumidos pela palavra “linha”, assinale a alternativa correta.$PC17$,
  $PC18$Analise as frases a seguir, considerando o emprego das expressões destacadas.

I. A sirene emitiu um **grito** prolongado.
II. O agente guardou o **colete** no armário.
III. Após a notícia, o silêncio **pesou** na sala.
IV. O mecânico substituiu a **corrente** da motocicleta.

Em quais frases o emprego destacado é conotativo?$PC18$,
  $PC19$Analise as frases a seguir quanto ao emprego das expressões destacadas.

I. O perito recolheu a **lanterna** que estava sobre a mesa.
II. A notícia **voou** pelo quartel antes do comunicado oficial.
III. A decisão deixou um **gosto amargo** entre os servidores.
IV. A viatura parou diante do **prédio** administrativo.

Assinale a alternativa que apresenta a análise correta, considerando apenas a distinção entre sentido literal e sentido figurado.$PC19$,
  $PC20$Em cada alternativa, a palavra ou expressão destacada foi classificada quanto ao sentido empregado na frase. Assinale a alternativa em que a classificação está INCORRETA.$PC20$,
  $PC21$Considere as ocorrências da palavra **raiz** nas frases a seguir.

I. As crianças observaram a **raiz** exposta da árvore após a chuva forte.
II. A falta de diálogo era a **raiz** do desentendimento entre os vizinhos.

Assinale a alternativa correta quanto ao sentido de “raiz” nos dois contextos.$PC21$,
  $PC22$No trecho de uma comunicação interna, assinale a alternativa que completa corretamente a lacuna, de acordo com a norma-padrão tradicional: “O servidor que ___ o comunicado deverá registrar a entrega no sistema.”$PC22$,
  $PC23$Na norma-padrão tradicional, complete o período a seguir, mantendo o advérbio **ali** sem pausa e o verbo no pretérito imperfeito:

“Ali ___ os policiais responsáveis pela escolta.”

Assinale a alternativa correta.$PC23$,
  $PC24$Assinale a alternativa que completa corretamente o período de acordo com a norma-padrão tradicional:

“O setor nunca ___ a confirmação da inscrição.”$PC24$,
  $PC25$Assinale a alternativa que completa corretamente a frase, de acordo com a norma-padrão tradicional de colocação pronominal:

“A comissão informará ________ a lista final.”$PC25$,
  $PC26$Considerando-se a norma-padrão tradicional cobrada em concursos, assinale a alternativa que reescreve corretamente a oração abaixo, substituindo “o documento” pelo pronome oblíquo átono adequado.

“Em frase isolada, sem qualquer fator de próclise, a direção entregará o documento ao candidato.”$PC26$,
  $PC27$Em uma ordem dirigida diretamente a um soldado, deve-se empregar o verbo apresentar no imperativo afirmativo, acompanhado do pronome oblíquo átono se. Considerando a norma-padrão tradicional, assinale a redação correta.$PC27$,
  $PC28$Considerando a norma-padrão tradicional e mantendo o verbo no pretérito perfeito do indicativo, assinale a alternativa correta quanto à colocação do pronome oblíquo átono.$PC28$
)
order by q.id;
