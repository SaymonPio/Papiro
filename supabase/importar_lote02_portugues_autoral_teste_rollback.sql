-- TESTE DE ROLLBACK REAL da IMPORTACAO LOTE02_PORTUGUES_AUTORAL. Executa, dentro de UMA
-- transacao controlada que termina em ROLLBACK externo, a sequencia
-- completa: OLD (baseline) -> APPLY (mesma logica do apply real) ->
-- TARGET (verifica) -> REVERSAO REAL (mesma logica do reverter real) ->
-- OLD_FINAL (verifica). Nenhuma linha e alterada permanentemente — tudo
-- e desfeito por ROLLBACK.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _relatorio (fase text, item text, ok boolean, detalhe text) on commit drop;

create temporary table _snapshot_antes on commit drop as
select
  (select count(*) from public.questoes) as total_questoes,
  (select count(*) from public.alternativas) as total_alternativas,
  (select count(*) from public.questao_unidades_pedagogicas) as total_vinculos,
  (select count(*) from public.curso_questoes) as total_curso_questoes;

create temporary table _lote_questoes (
  ordem int primary key, curso_conteudo_id bigint, dificuldade text, fonte text, enunciado text
) on commit drop;

insert into _lote_questoes (ordem, curso_conteudo_id, dificuldade, fonte, enunciado) values
(1, 21, 'media', $FONTE1$PAPIRO — LOTE02_PORTUGUES_AUTORAL — REESCRITA-01$FONTE1$, $ENUN1$Assinale a alternativa que apresenta a transposição correta para a voz passiva analítica da frase “A comissão revisava os procedimentos mensalmente”, preservando o tempo verbal e o sentido original.$ENUN1$),
(2, 21, 'media', $FONTE2$PAPIRO — LOTE02_PORTUGUES_AUTORAL — REESCRITA-02$FONTE2$, $ENUN2$Considere a frase ativa “As servidoras organizam o arquivo” e as seguintes propostas de reescrita na voz passiva analítica:

I. O arquivo é organizado pelas servidoras.
II. O arquivo é organizado para as servidoras.
III. Pelas servidoras, foi organizado o arquivo.
IV. Pelas servidoras, o arquivo é organizado.

Quais propostas introduzem corretamente o agente da passiva e preservam o sentido da frase original?$ENUN2$),
(3, 21, 'media', $FONTE3$PAPIRO — LOTE02_PORTUGUES_AUTORAL — REESCRITA-03$FONTE3$, $ENUN3$Considere o período na voz ativa:

“A equipe de inspeção lacrou o depósito, a equipe de inspeção catalogava os materiais e a equipe de inspeção encaminhará o relatório.”

Foi proposta a seguinte reescrita na voz passiva analítica:

“O depósito foi lacrado pela equipe de inspeção, os materiais foram catalogados pela equipe de inspeção e o relatório será encaminhado pela equipe de inspeção.”

Assinale a alternativa que avalia corretamente essa reescrita.$ENUN3$),
(4, 21, 'media', $FONTE4$PAPIRO — LOTE02_PORTUGUES_AUTORAL — REESCRITA-04$FONTE4$, $ENUN4$Considere a frase original e a proposta de reescrita:

Original: “O instrutor orientou os recrutas durante o exercício.”

Proposta: “O instrutor foi orientado pelos recrutas durante o exercício.”

Assinale a alternativa que identifica corretamente o problema da proposta.$ENUN4$),
(5, 21, 'media', $FONTE5$PAPIRO — LOTE02_PORTUGUES_AUTORAL — REESCRITA-05$FONTE5$, $ENUN5$Considere as frases a seguir:

I. Os peritos examinaram os documentos apreendidos.
II. Os soldados chegaram ao quartel antes do amanhecer.
III. A comissão concedeu medalhas aos agentes.
IV. Os moradores necessitam de proteção constante.

Quais frases admitem transposição natural e gramaticalmente adequada para a voz passiva analítica?$ENUN5$),
(6, 21, 'media', $FONTE6$PAPIRO — LOTE02_PORTUGUES_AUTORAL — REESCRITA-06$FONTE6$, $ENUN6$Considere a frase a seguir:

“Durante a operação, os agentes localizaram o veículo e entregaram as provas ao delegado.”

Assinale a alternativa que apresenta a transposição para a voz passiva analítica preservando integralmente o tempo verbal, os papéis semânticos e a indicação de quem praticou as ações.$ENUN6$),
(7, 21, 'media', $FONTE7$PAPIRO — LOTE02_PORTUGUES_AUTORAL — REESCRITA-07$FONTE7$, $ENUN7$Considere a frase: “A equipe de perícia recolheu, somente ao amanhecer e sob forte chuva, os vestígios deixados na estrada.” Assinale a alternativa que apresenta a correta transposição dessa frase para a voz passiva analítica, sem alteração do sentido original.$ENUN7$),
(8, 21, 'media', $FONTE8$PAPIRO — LOTE02_PORTUGUES_AUTORAL — REESCRITA-08$FONTE8$, $ENUN8$Considere a frase na voz ativa: “A equipe técnica refez as medições.” Na transposição para a voz passiva analítica, o auxiliar já foi corretamente empregado: “As medições foram ______ pela equipe técnica.” Assinale a alternativa que preenche corretamente a lacuna.$ENUN8$),
(9, 12, 'media', $FONTE9$PAPIRO — LOTE02_PORTUGUES_AUTORAL — INTERPRETACAO-02$FONTE9$, $ENUN9$Em um treinamento sobre atendimento a ocorrências, a instrutora afirmou que a rapidez é importante, mas não substitui a escuta atenta. Ela orientou os agentes a registrar as informações essenciais antes de encaminhar cada caso. Nas simulações, as equipes que confirmaram os dados cometeram menos falhas de comunicação. Ao final, a instrutora recomendou que o protocolo fosse revisto periodicamente, sem o abandono das etapas de conferência.

Assinale a alternativa que contraria diretamente uma informação explícita do texto.$ENUN9$),
(10, 12, 'media', $FONTE10$PAPIRO — LOTE02_PORTUGUES_AUTORAL — INTERPRETACAO-03$FONTE10$, $ENUN10$Leia o texto a seguir.

A ampliação do horário de funcionamento das bibliotecas municipais pode facilitar o acesso de trabalhadores que não conseguem frequentá-las durante o dia, desde que a medida seja acompanhada por transporte noturno adequado e por equipes suficientes para atender o público. Sem essas condições, a mudança tende a beneficiar sobretudo os moradores das proximidades, produzindo um alcance mais limitado.

Assinale a alternativa que representa corretamente o conteúdo do texto.$ENUN10$),
(11, 12, 'media', $FONTE11$PAPIRO — LOTE02_PORTUGUES_AUTORAL — INTERPRETACAO-04$FONTE11$, $ENUN11$Leia o texto a seguir.

Durante três meses, uma unidade de saúde passou a enviar lembretes de consultas com 48 horas de antecedência. No período, foram mantidos os mesmos horários de atendimento, a mesma equipe e os mesmos critérios de agendamento. A proporção de faltas caiu de 22% para 14%. Uma pesquisa posterior revelou, porém, que alguns usuários, por estarem com os dados de contato desatualizados, não receberam as mensagens. Entre os que confirmaram o recebimento, a redução das faltas foi mais acentuada. Os dados disponíveis não permitem saber se o resultado se manterá por períodos mais longos.

Considere as seguintes afirmativas:

I. Os dados sustentam a inferência de que os lembretes podem ter contribuído para a redução das faltas, embora não demonstrem que tenham sido sua única causa.
II. Todos os usuários que receberam os lembretes compareceram às consultas marcadas.
III. A manutenção dos horários, da equipe e dos critérios de agendamento reforça a interpretação de que a introdução dos lembretes está relacionada à mudança observada.
IV. A atualização dos dados de contato de todos os usuários eliminaria definitivamente as faltas às consultas.

Quais afirmativas apresentam inferências válidas com base no texto?$ENUN11$),
(12, 12, 'media', $FONTE12$PAPIRO — LOTE02_PORTUGUES_AUTORAL — INTERPRETACAO-05$FONTE12$, $ENUN12$Leia o texto a seguir:

Em instituições de segurança, a comunicação com a comunidade não deve ocorrer apenas em momentos de crise; ela precisa integrar permanentemente a prestação do serviço. Informações claras sobre mudanças de circulação ou ações preventivas, por exemplo, ajudam os moradores a organizar sua rotina. Além disso, explicar os objetivos e os limites de uma operação reduz rumores e favorece a cooperação. Por isso, avisos sobre bloqueios temporários devem ser divulgados com antecedência, sempre que possível.

Assinale a alternativa que expressa corretamente a tese defendida no texto.$ENUN12$),
(13, 12, 'media', $FONTE13$PAPIRO — LOTE02_PORTUGUES_AUTORAL — INTERPRETACAO-06$FONTE13$, $ENUN13$Leia o texto a seguir:

Em um centro de formação, a redução de desperdícios começou com a instalação de recipientes para separar resíduos. Nas primeiras semanas, porém, o volume enviado ao descarte comum quase não mudou. A equipe então passou a orientar os usuários, reposicionou os coletores e acompanhou mensalmente os resultados. Com essas medidas articuladas, a separação melhorou de forma gradual. A experiência mostrou que equipamentos, sozinhos, não alteram hábitos: mudanças consistentes dependem também de orientação e acompanhamento.

Considerando a compreensão global do texto, assinale a alternativa correta.$ENUN13$),
(14, 12, 'media', $FONTE14$PAPIRO — LOTE02_PORTUGUES_AUTORAL — INTERPRETACAO-07$FONTE14$, $ENUN14$Leia o texto a seguir.

Durante seis meses, metade das luminárias de um bairro foi substituída por modelos direcionados para o chão. Nas vias atendidas, o consumo de energia caiu 18%, e as reclamações de moradores sobre luz excessiva dentro das residências tornaram-se menos frequentes. A mudança, contudo, não eliminou todas as queixas. Alguns comerciantes perceberam maior circulação de pedestres ao anoitecer, mas o relatório do projeto considerou insuficientes os dados disponíveis para atribuir esse movimento à nova iluminação.

Com base exclusivamente no texto, analise as seguintes assertivas:

I. A substituição das luminárias reduziu o consumo de energia e a frequência de determinadas reclamações nas vias atendidas.
II. O relatório comprovou que a nova iluminação foi responsável pelo aumento da circulação de pedestres.
III. Nas vias atendidas, as reclamações sobre luz excessiva dentro das residências tornaram-se mais frequentes.
IV. O único resultado observado após a substituição das luminárias foi a redução do consumo de energia.

Quais assertivas são efetivamente sustentadas pelo texto?$ENUN14$),
(15, 12, 'media', $FONTE15$PAPIRO — LOTE02_PORTUGUES_AUTORAL — INTERPRETACAO-08$FONTE15$, $ENUN15$Leia o texto a seguir.

Uma escola realizou, por três meses, um projeto de empréstimo de tablets aos estudantes. Ao fim da experiência, o número de participantes permaneceu estável, mas a proporção de tarefas entregues no prazo passou de 62% para 81%. A coordenadora decidiu manter o projeto precisamente porque esse aumento indicava maior regularidade no acesso aos materiais fora da sala de aula. Os estudantes também elogiaram os tutoriais instalados nos aparelhos, e a equipe estuda ampliar o prazo de empréstimo na próxima etapa.

De acordo com o texto, qual dado foi apresentado como razão direta para a decisão de manter o projeto?$ENUN15$),
(16, 17, 'media', $FONTE16$PAPIRO — LOTE02_PORTUGUES_AUTORAL — REGENCIA-01$FONTE16$, $ENUN16$Assinale a alternativa que preenche, correta e respectivamente, as lacunas da frase a seguir.

As metas ___ a equipe aspirava, os recursos ___ os agentes contavam e o procedimento ___ o instrutor insistia foram registrados no relatório.$ENUN16$),
(17, 17, 'media', $FONTE17$PAPIRO — LOTE02_PORTUGUES_AUTORAL — REGENCIA-02$FONTE17$, $ENUN17$Considerando as regras de emprego do pronome relativo “cujo” e suas flexões, assinale a alternativa correta.$ENUN17$),
(18, 17, 'media', $FONTE18$PAPIRO — LOTE02_PORTUGUES_AUTORAL — REGENCIA-03$FONTE18$, $ENUN18$Assinale a alternativa que preenche correta e respectivamente as lacunas, de acordo com a regência do verbo “assistir” no padrão formal da Língua Portuguesa.

I. Após o treinamento, os soldados assistiram ___ documentário sobre segurança pública.
II. Durante o acidente, os socorristas assistiram ___ feridos até a chegada da equipe médica.$ENUN18$),
(19, 17, 'media', $FONTE19$PAPIRO — LOTE02_PORTUGUES_AUTORAL — REGENCIA-04$FONTE19$, $ENUN19$Analise as afirmativas a seguir quanto à regência dos verbos “obedecer” e “desobedecer” no padrão formal da Língua Portuguesa.

I. Os soldados obedeceram ao regulamento durante a operação.
II. O candidato desobedeceu o comando do instrutor.
III. Os subordinados devem obedecer aos superiores hierárquicos.
IV. O agente jamais desobedeceu ao protocolo de segurança.

Quais afirmativas estão corretas?$ENUN19$),
(20, 17, 'media', $FONTE20$PAPIRO — LOTE02_PORTUGUES_AUTORAL — REGENCIA-08$FONTE20$, $ENUN20$Assinale a alternativa em que o verbo “preferir” foi empregado corretamente de acordo com a norma-padrão tradicional.$ENUN20$),
(21, 32, 'media', $FONTE21$PAPIRO — LOTE02_PORTUGUES_AUTORAL — VOZES-01$FONTE21$, $ENUN21$Considere as seguintes orações:

I. Durante a inspeção, os fiscais vistoriaram cuidadosamente o local.
II. O local foi vistoriado pelos fiscais durante a inspeção.
III. A comissão aprovou, por unanimidade, o novo relatório.
IV. O relatório foi aprovado por unanimidade.

Quais estão construídas na voz ativa?$ENUN21$),
(22, 32, 'media', $FONTE22$PAPIRO — LOTE02_PORTUGUES_AUTORAL — VOZES-02$FONTE22$, $ENUN22$Considere a oração na voz ativa e a proposta de transposição para a voz passiva analítica:

Voz ativa: “A equipe de investigação conferia os registros todas as manhãs.”

Proposta: “Os registros foram conferidos pela equipe de investigação todas as manhãs.”

À luz da norma-padrão, assinale a alternativa que avalia corretamente a proposta.$ENUN22$),
(23, 32, 'media', $FONTE23$PAPIRO — LOTE02_PORTUGUES_AUTORAL — VOZES-03$FONTE23$, $ENUN23$Assinale a alternativa que preenche corretamente a lacuna, empregando a voz passiva sintética e o pretérito perfeito do indicativo.

“__________ novos equipamentos de comunicação para a unidade na semana passada.”$ENUN23$),
(24, 32, 'media', $FONTE24$PAPIRO — LOTE02_PORTUGUES_AUTORAL — VOZES-04$FONTE24$, $ENUN24$Considere as frases a seguir.

1. Divulgaram-se novas instruções aos integrantes da unidade.
2. Confia-se em profissionais experientes durante operações delicadas.

Analise as seguintes afirmativas:

I. Na frase 1, o pronome “se” é apassivador, e “novas instruções” funciona como sujeito paciente.
II. Na frase 1, o plural de “divulgaram-se” decorre da concordância com “novas instruções”.
III. Na frase 2, o pronome “se” é índice de indeterminação do sujeito, e o verbo deve permanecer na terceira pessoa do singular.
IV. Na frase 2, o plural de “profissionais experientes” exigiria a forma “confiam-se”.

Quais afirmativas estão corretas?$ENUN24$);

create temporary table _lote_explicacoes (ordem int primary key, explicacao text) on commit drop;

insert into _lote_explicacoes (ordem, explicacao) values
(1, $EXPL1$Na oração ativa, “a comissão” pratica a ação, enquanto “os procedimentos” a sofrem. Na passagem para a voz passiva analítica, o objeto direto “os procedimentos” torna-se sujeito paciente, e o verbo principal passa ao particípio: “revisados”. Como “revisava” está no pretérito imperfeito do indicativo, o auxiliar “ser” deve permanecer nesse mesmo tempo e modo: “eram”. Assim, a forma correta é “Os procedimentos eram revisados mensalmente pela comissão”. A alternativa A emprega o presente; C, o pretérito perfeito; D, o futuro do pretérito; e E introduz uma forma composta que altera a perspectiva temporal da frase.

FUNDAMENTO: Na transposição da voz ativa para a passiva analítica, o objeto direto torna-se sujeito paciente, e o predicado verbal é formado pelo auxiliar “ser”, flexionado no mesmo tempo e modo do verbo da ativa, seguido do particípio do verbo principal.$EXPL1$),
(2, $EXPL2$Nesta transposição, “as servidoras” precisam continuar representando quem pratica a ação. Em I e IV, “pelas servidoras” preserva corretamente esse papel de agente da passiva, mantendo também o tempo presente do verbo (“organizam” corresponde a “é organizado”); a inversão da ordem em IV não altera quem pratica a ação. Em II, “para as servidoras” não apresenta as servidoras como agentes da ação: introduz valor de destinatário/beneficiário, alterando a relação semântica original. Em III, “pelas servidoras” preserva corretamente o agente, mas “foi organizado” muda o presente da frase original (“organizam”) para o pretérito perfeito, alterando o tempo verbal. Portanto, apenas I e IV preservam integralmente o agente e o tempo verbal da frase original.

FUNDAMENTO: Na transposição de uma oração para a voz passiva analítica, deve-se preservar o participante que pratica a ação. Na construção apresentada, “as servidoras”, sujeito da oração ativa, é adequadamente retomado como agente da passiva por “pelas servidoras”. Também deve ser preservado o tempo verbal: “organizam” corresponde a “é organizado”.$EXPL2$),
(3, $EXPL3$Na primeira oração, “lacrou” está no pretérito perfeito, corretamente correspondente a “foi lacrado”. Na segunda, porém, “catalogava” está no pretérito imperfeito e indica uma ação em curso ou habitual no passado; por isso, a forma passiva correspondente é “eram catalogados”, e não “foram catalogados”. Na terceira oração, “encaminhará” está no futuro do presente, corretamente mantido em “será encaminhado”. Em todas as orações, a equipe continua praticando as ações, enquanto o depósito, os materiais e o relatório continuam sofrendo-as. Assim, A ignora o erro temporal da segunda oração; C e D propõem tempos incompatíveis com os verbos originais; e E aponta uma inversão de papéis semânticos que não ocorreu.

FUNDAMENTO: Na passagem da ativa para a passiva analítica, o objeto direto torna-se sujeito paciente, o verbo principal assume a forma de particípio e o auxiliar “ser” deve ser flexionado no mesmo tempo e modo do verbo da oração ativa. Em períodos coordenados, essa correspondência deve ser verificada separadamente em cada oração.$EXPL3$),
(4, $EXPL4$Na frase original, o instrutor pratica a ação de orientar, e os recrutas recebem essa orientação. A proposta troca esses papéis: nela, os recrutas passam a praticar a ação, enquanto o instrutor passa a recebê-la. Portanto, não ocorreu somente uma mudança de estrutura ou de foco; houve alteração da cena representada e, consequentemente, do sentido. A não é correta porque a equivalência semântica foi perdida; C é falsa porque a expressão circunstancial permaneceu na mesma posição; D introduz uma reciprocidade inexistente; e E é falsa porque a estrutura da frase original é compatível com a passivização.

FUNDAMENTO: Uma reescrita equivalente da voz ativa para a passiva deve conservar quem pratica e quem sofre a ação. O participante que recebe a ação na construção ativa passa à posição de destaque na passiva, mas não pode trocar de papel sem que o sentido seja alterado.$EXPL4$),
(5, $EXPL5$As frases I e III admitem a transformação. Em I, o objeto direto “os documentos apreendidos” torna-se sujeito paciente: “Os documentos apreendidos foram examinados pelos peritos”. Em III, o objeto direto “medalhas” também pode ocupar essa função: “Medalhas foram concedidas aos agentes pela comissão”; o complemento “aos agentes” permanece ligado ao verbo. A frase II não admite essa transposição porque “chegar” é intransitivo no contexto e não apresenta objeto direto que possa tornar-se sujeito paciente. Na frase IV, “necessitar” rege a preposição “de”; portanto, “de proteção constante” é complemento preposicionado, e não objeto direto passivizável. Assim, apenas I e III admitem naturalmente a passiva analítica.

FUNDAMENTO: Na transposição, o objeto direto da oração ativa passa a sujeito paciente, o verbo principal assume o particípio e acrescenta-se o auxiliar “ser” no tempo e modo do verbo original. A transformação pressupõe uma estrutura verbal compatível, não sendo aplicada mecanicamente a verbos intransitivos ou a verbos que apresentem apenas complemento preposicionado.$EXPL5$),
(6, $EXPL6$Na frase original, “os agentes” praticam as duas ações; “o veículo” sofre a ação de localizar; e “as provas” sofrem a ação de entregar, mantendo-se “ao delegado” como complemento. Como os verbos estão no pretérito perfeito, a passiva deve empregar o auxiliar “ser” nesse mesmo tempo: “foi localizado” e “foram entregues”. A alternativa A preserva todos esses elementos. Em B, o futuro do presente altera o tempo verbal. Em C, os papéis semânticos da primeira oração são invertidos, pois o veículo passa indevidamente a praticar a ação. Em D, o agente é trocado: a frase original menciona os agentes, e não a equipe pericial. Em E, embora as construções passivas sejam gramaticais, omite-se a informação expressa sobre quem realizou as duas ações; por isso, o conteúdo original não é integralmente preservado.

FUNDAMENTO: Na voz passiva analítica, o objeto direto da ativa torna-se sujeito paciente, o sujeito da ativa pode aparecer como agente da passiva introduzido por “por”, e o auxiliar “ser” deve conservar o tempo e o modo do verbo original. A reescrita equivalente não pode inverter, substituir ou apagar informações relevantes sobre quem pratica e quem sofre a ação.$EXPL6$),
(7, $EXPL7$Na oração ativa, “a equipe de perícia” pratica a ação, enquanto “os vestígios deixados na estrada” sofrem a ação de recolher. Embora adjuntos adverbiais estejam intercalados entre o verbo e o objeto direto, este último deve passar a sujeito paciente da voz passiva. Como “recolheu” está no pretérito perfeito, emprega-se “foram”, seguido do particípio “recolhidos”, em concordância com o sujeito paciente. O agente é introduzido por “pela”: “pela equipe de perícia”. Em B, os papéis de agente e paciente são invertidos. Em C, “eram recolhidos” altera o valor temporal e aspectual da ação. Em D, “para a equipe” não expressa o agente responsável pela ação. Em E, falta concordância do auxiliar e do particípio com “os vestígios”.

FUNDAMENTO: O objeto direto da voz ativa torna-se sujeito paciente; o verbo ser deve ser flexionado no mesmo tempo e modo do verbo original; o verbo principal passa ao particípio e concorda com o sujeito paciente; o agente da passiva é normalmente introduzido por “por”, “pelo” ou “pela”.$EXPL7$),
(8, $EXPL8$O particípio do verbo “refazer” é “refeito”, formado a partir do particípio irregular “feito”, do verbo “fazer”. Na voz passiva analítica, o particípio concorda em gênero e número com o sujeito paciente. Como “as medições” está no feminino plural, a forma correta é “refeitas”. “Refazidas” e “refazida” não são formas adequadas do particípio de “refazer”. “Refeito” e “refeitos”, embora derivados do particípio correto, não apresentam a concordância feminina plural exigida pelo sujeito.

FUNDAMENTO: Na construção formada pelo auxiliar ser e pelo particípio, o verbo principal deve assumir seu particípio próprio, que concorda em gênero e número com o sujeito paciente. O particípio de “refazer” é “refeito”, com as flexões “refeita”, “refeitos” e “refeitas”.$EXPL8$),
(9, $EXPL9$A alternativa C contradiz diretamente o texto. A instrutora afirma que a rapidez, embora importante, não substitui a escuta atenta; a alternativa declara o oposto, isto é, que a rapidez torna essa escuta desnecessária. As alternativas A, B, D e E retomam fielmente informações explícitas: a importância da rapidez, o registro prévio das informações, a redução de falhas entre as equipes que confirmaram os dados e a revisão periódica do protocolo sem abandono das conferências.

FUNDAMENTO: Há contradição quando uma alternativa afirma o oposto de uma informação apresentada no texto. A verificação deve comparar precisamente o conteúdo da alternativa com o trecho correspondente, observando relações de negação e oposição.$EXPL9$),
(10, $EXPL10$A alternativa C preserva a nuance do texto: a ampliação do horário pode facilitar o acesso, mas seus resultados dependem de transporte noturno adequado e de equipes suficientes. A alternativa A elimina essa condição e transforma uma possibilidade em garantia universal. A alternativa B realiza uma redução indevida: o texto afirma que, sem as condições complementares, a medida tende a beneficiar sobretudo os moradores próximos, e não somente esse grupo. A alternativa D estabelece uma hierarquia entre transporte e pessoal que não aparece no texto. A alternativa E apresenta uma recomendação que o autor não formulou.

FUNDAMENTO: Na interpretação de textos, deve-se preservar o alcance de expressões condicionais e modalizadoras, como “pode”, “desde que”, “tende a” e “sobretudo”. Substituir “sobretudo” por “somente”, por exemplo, restringe indevidamente a afirmação original.$EXPL10$),
(11, $EXPL11$As afirmativas I e III são inferências válidas. A queda das faltas após a adoção dos lembretes, especialmente entre aqueles que confirmaram o recebimento, permite inferir uma possível contribuição das mensagens, sem provar que elas tenham sido a única causa. Além disso, a manutenção dos horários, da equipe e dos critérios de agendamento reduz a influência dessas variáveis na comparação e reforça a relação observada. A afirmativa II extrapola o texto: uma redução mais acentuada entre os destinatários não significa que todos tenham comparecido. A afirmativa IV também extrapola, pois não há base para concluir que a atualização dos contatos eliminaria definitivamente todas as faltas. O próprio texto ainda ressalta que não é possível assegurar a permanência do resultado no longo prazo.

FUNDAMENTO: Uma inferência válida decorre logicamente das informações apresentadas, mesmo sem estar formulada literalmente. Ela não pode converter indícios em certeza absoluta nem introduzir consequências universais ou definitivas que o texto não autorize.$EXPL11$),
(12, $EXPL12$A alternativa B apresenta a tese, isto é, o ponto de vista geral defendido pelo autor: a comunicação com a comunidade deve ser permanente, e não restrita às crises. A alternativa A reproduz um exemplo dos benefícios dessa comunicação. A alternativa C apresenta um argumento de apoio à tese. A alternativa D corresponde a uma recomendação específica formulada na conclusão do parágrafo, mas não abrange o posicionamento central. A alternativa E contradiz expressamente o texto, que rejeita a limitação da comunicação aos momentos de crise.

FUNDAMENTO: A tese é o posicionamento central defendido pelo autor. Ela deve ser distinguida do tema geral, dos exemplos, dos argumentos empregados para sustentá-la e das conclusões ou recomendações de alcance específico.$EXPL12$),
(13, $EXPL13$A alternativa E resume adequadamente o conteúdo global: a melhoria ocorreu quando os recipientes foram associados à orientação, ao reposicionamento e ao acompanhamento dos resultados. A alternativa A contradiz o texto, pois a instalação inicial quase não alterou o volume descartado. A alternativa B reduz indevidamente o resultado a uma única medida. A alternativa C transforma um detalhe secundário — o reposicionamento dos coletores — no objetivo central. A alternativa D extrapola o texto ao introduzir punições, assunto que não foi mencionado nem sugerido.

FUNDAMENTO: A compreensão global exige reconhecer a ideia que integra as informações centrais do texto, sem confundi-la com detalhes secundários e sem acrescentar, restringir ou contradizer o que foi efetivamente afirmado.$EXPL13$),
(14, $EXPL14$Apenas a assertiva I é sustentada pelo texto, pois reproduz os dois resultados expressamente informados: a queda do consumo de energia e a menor frequência de reclamações sobre luz excessiva. A assertiva II constitui extrapolação: houve apenas uma percepção dos comerciantes, e o relatório considerou os dados insuficientes para atribuir o movimento de pedestres à iluminação. A assertiva III contradiz o texto, que afirma que as reclamações se tornaram menos frequentes, e não mais frequentes. A assertiva IV apresenta redução indevida ao afirmar que a economia de energia foi o único resultado, ignorando a diminuição das reclamações. Portanto, a alternativa correta é A.

FUNDAMENTO: Na interpretação textual, uma assertiva é válida quando seu conteúdo é explicitamente afirmado ou pode ser inferido com segurança. Devem ser rejeitadas formulações que acrescentem conclusões não autorizadas, contrariem o texto ou restrinjam indevidamente uma informação mais ampla.$EXPL14$),
(15, $EXPL15$O comando não pergunta simplesmente o que aconteceu durante o projeto, mas qual dado foi apresentado como razão direta para sua continuidade. O texto estabelece essa relação ao afirmar que a coordenadora manteve o projeto “precisamente porque” a proporção de tarefas entregues no prazo aumentou de 62% para 81%. A alternativa A apresenta um dado verdadeiro, mas responde a outra pergunta: o que ocorreu com o número de participantes. Os elogios mencionados na alternativa C também constam do texto, porém não são apontados como a razão determinante da decisão. A ampliação do prazo, alternativa D, é apenas uma possibilidade futura. A alternativa E contradiz o texto, que associa o resultado a uma maior regularidade de acesso. Logo, a resposta correta é B.

FUNDAMENTO: A resolução de uma questão de interpretação exige identificar com precisão o que o comando solicita. Uma alternativa pode conter informação verdadeira e, ainda assim, estar errada por não responder ao aspecto específico perguntado, como causa, consequência, finalidade ou dado contextual.$EXPL15$),
(16, $EXPL16$A alternativa A é a correta. Para determinar cada preposição, deve-se retirar o pronome relativo e reconstruir a oração com o antecedente. Na primeira lacuna: “a equipe aspirava às metas”; no sentido de almejar, o verbo “aspirar” rege a preposição “a”, resultando em “metas a que a equipe aspirava”. Na segunda: “os agentes contavam com os recursos”; o verbo “contar”, nesse contexto, rege “com”, formando “recursos com que os agentes contavam”. Na terceira: “o instrutor insistia no procedimento”; o verbo “insistir” rege “em”, formando “procedimento em que o instrutor insistia”. As demais alternativas apresentam ao menos uma preposição incompatível com a regência do verbo da respectiva oração subordinada.

FUNDAMENTO: A preposição que antecede o pronome relativo é determinada pela regência do termo presente na oração subordinada. Para identificá-la, reconstrói-se a oração substituindo o relativo por seu antecedente: aspirar a algo, contar com algo e insistir em algo.$EXPL16$),
(17, $EXPL17$A alternativa C está correta. O pronome “cujas” estabelece uma relação de posse entre “museu” e “salas”, equivalente a “as salas do museu”. Ele concorda com o substantivo posterior, “salas”, que está no feminino plural, e não é seguido de artigo. Em A, é indevida a presença do artigo “a” entre “cuja” e “análise”. Em B, como o substantivo posterior é “decisões”, deve-se empregar “cujas”. Em D, o pronome deve concordar com “desempenho”, masculino singular, de modo que a forma adequada seria “cujo desempenho”. Em E, o artigo “os” não pode ser inserido entre “cujos” e “livros”.

FUNDAMENTO: O pronome relativo “cujo” estabelece relação de posse entre um antecedente possuidor e um substantivo posterior que designa a coisa possuída. Concorda em gênero e número com esse substantivo posterior e não admite artigo entre o pronome e o nome que o segue.$EXPL17$),
(18, $EXPL18$Na frase I, “assistir” significa ver ou presenciar. Nesse sentido, o verbo é transitivo indireto e exige a preposição “a”: quem assiste, no sentido de ver, assiste a algo. Como “documentário” está acompanhado do artigo masculino “o”, ocorre a contração “ao”: “assistiram ao documentário”. Na frase II, “assistir” significa ajudar ou prestar assistência. Nesse sentido, o verbo é transitivo direto, sem preposição: “assistiram os feridos”. Portanto, a sequência correta é “ao – os”. As alternativas B e D omitem indevidamente a preposição na primeira frase; B e C introduzem preposição inadequada antes do objeto direto da segunda frase; E emprega “no”, forma que não corresponde à regência formal de “assistir” no sentido de ver.

FUNDAMENTO: No sentido de ver ou presenciar, “assistir” é tradicionalmente transitivo indireto e rege a preposição “a”. No sentido de ajudar ou prestar assistência, é transitivo direto e recebe complemento sem preposição.$EXPL18$),
(19, $EXPL19$Os verbos “obedecer” e “desobedecer” são transitivos indiretos e exigem a preposição “a”. A afirmativa I está correta: “obedeceram ao regulamento”. A afirmativa II está incorreta, pois a preposição foi omitida; a construção adequada seria “desobedeceu ao comando do instrutor”. A afirmativa III está correta: “obedecer aos superiores hierárquicos”. A afirmativa IV também está correta: “desobedeceu ao protocolo de segurança”. Assim, estão corretas apenas I, III e IV.

FUNDAMENTO: No padrão formal, “obedecer” e “desobedecer” são verbos transitivos indiretos e regem complemento introduzido pela preposição “a”: obedecer a algo ou a alguém; desobedecer a algo ou a alguém.$EXPL19$),
(20, $EXPL20$A alternativa D está correta: na comparação entre duas opções, a construção tradicional é “preferir X a Y”, como em “preferir patrulhar as ruas a permanecer na base”. A alternativa A emprega a construção comparativa redundante “preferir mais... do que”. A alternativa B substitui indevidamente a preposição “a” por “do que”. A alternativa C introduz a preposição “de” antes da primeira opção, embora o primeiro complemento seja direto. A alternativa E omite a preposição “a” exigida antes da segunda opção.

FUNDAMENTO: Ao relacionar duas opções, “preferir” segue a estrutura “preferir X a Y”. A ideia de superioridade já está contida no verbo, razão pela qual construções como “preferir mais X do que Y” são evitadas no padrão tradicional.$EXPL20$),
(21, $EXPL21$Estão na voz ativa apenas I e III, pois em ambas o sujeito gramatical ocupa a posição característica da estrutura ativa em relação ao processo verbal (“os fiscais vistoriaram”, “a comissão aprovou”), independentemente dos adjuntos intercalados (“durante a inspeção”, “por unanimidade”). Em II e IV, o predicado verbal é formado pelo auxiliar “ser” + particípio (“foi vistoriado”, “foi aprovado”), estrutura própria da voz passiva analítica — em II o agente da passiva está expresso (“pelos fiscais”), e em IV o agente não está expresso, mas a estrutura “ser” + particípio já caracteriza a passiva independentemente disso.

FUNDAMENTO: A voz ativa caracteriza-se pela estrutura sujeito + verbo, em que o sujeito ocupa a posição característica dessa organização gramatical em relação ao processo verbal. A voz passiva analítica caracteriza-se pela estrutura auxiliar “ser” + particípio do verbo principal, com ou sem agente da passiva expresso.$EXPL21$),
(22, $EXPL22$Na oração original, “conferia” está no pretérito imperfeito do indicativo. Na transposição para a voz passiva analítica, “os registros”, objeto direto da construção ativa, passa a sujeito paciente; o auxiliar “ser” deve preservar o pretérito imperfeito do indicativo, assumindo a forma “eram”; e o verbo principal aparece no particípio, concordando com o sujeito: “conferidos”. O sujeito da ativa, “A equipe de investigação”, pode ser expresso como agente da passiva por meio de “pela”. Assim, a transposição adequada é: “Os registros eram conferidos pela equipe de investigação todas as manhãs.” A forma “foram conferidos” está no pretérito perfeito do indicativo e altera a perspectiva temporal da oração original. As alternativas C e D apresentam análises sintáticas incorretas, e a E é falsa porque “conferir” foi empregado como verbo transitivo passivizável nesse contexto.

FUNDAMENTO: Na transposição de uma construção ativa passivizável, o objeto direto é promovido a sujeito paciente; emprega-se o auxiliar “ser” no tempo e modo correspondentes aos do verbo original; o verbo principal assume a forma de particípio e concorda com o sujeito; e o sujeito da ativa pode tornar-se agente da passiva, normalmente introduzido pela preposição “por” e suas contrações.$EXPL22$),
(23, $EXPL23$Na construção “Adquiriram-se novos equipamentos”, o pronome “se” é apassivador, e “novos equipamentos de comunicação” funciona como sujeito paciente. A paráfrase “Novos equipamentos de comunicação foram adquiridos” confirma a análise passiva. Como o sujeito está no plural, o verbo também deve ser flexionado no plural: “adquiriram-se”. Além disso, o pretérito perfeito é adequado à indicação temporal “na semana passada”. A alternativa A apresenta indevidamente o verbo no singular. As alternativas C, D e E empregam tempos verbais diferentes do solicitado.

FUNDAMENTO: Na passiva sintética, o pronome apassivador “se” acompanha um verbo passivizável, e o sujeito paciente determina a concordância verbal. Se o sujeito paciente estiver no plural, o verbo deverá ser flexionado no plural.$EXPL23$),
(24, $EXPL24$As afirmativas I, II e III estão corretas. Na frase 1, “novas instruções” é sujeito paciente, e a oração admite a paráfrase passiva analítica “Novas instruções foram divulgadas aos integrantes da unidade”. Por isso, o “se” é apassivador, e o verbo concorda no plural com esse sujeito. Na frase 2, “confiar”, no sentido empregado, rege a preposição “em”. O termo “em profissionais experientes” não é sujeito paciente, e não se obtém uma passiva analítica semanticamente equivalente. O “se” funciona, portanto, como índice de indeterminação do sujeito, mantendo-se o verbo na terceira pessoa do singular: “confia-se”. A afirmativa IV está errada porque o número do complemento preposicionado “profissionais experientes” não determina a concordância do verbo nessa construção.

FUNDAMENTO: A distinção deve considerar a estrutura completa da oração. Com “se” apassivador, há sujeito paciente, possibilidade de paráfrase passiva analítica e concordância do verbo com esse sujeito. Com índice de indeterminação do sujeito, não há sujeito paciente, e o verbo permanece na terceira pessoa do singular.$EXPL24$);

create temporary table _lote_alternativas (ordem int, letra_ordem int, texto text, correta boolean) on commit drop;

insert into _lote_alternativas (ordem, letra_ordem, texto, correta) values
(1, 1, $ALT1_0$Os procedimentos são revisados mensalmente pela comissão.$ALT1_0$, false),
(1, 2, $ALT1_1$Os procedimentos eram revisados mensalmente pela comissão.$ALT1_1$, true),
(1, 3, $ALT1_2$Os procedimentos foram revisados mensalmente pela comissão.$ALT1_2$, false),
(1, 4, $ALT1_3$Os procedimentos seriam revisados mensalmente pela comissão.$ALT1_3$, false),
(1, 5, $ALT1_4$Os procedimentos tinham sido revisados mensalmente pela comissão.$ALT1_4$, false),
(2, 1, $ALT2_0$Apenas I.$ALT2_0$, false),
(2, 2, $ALT2_1$Apenas II.$ALT2_1$, false),
(2, 3, $ALT2_2$Apenas I e IV.$ALT2_2$, true),
(2, 4, $ALT2_3$Apenas II e III.$ALT2_3$, false),
(2, 5, $ALT2_4$Apenas I, III e IV.$ALT2_4$, false),
(3, 1, $ALT3_0$A reescrita está correta, pois todas as orações preservam os papéis semânticos e os tempos verbais do período original.$ALT3_0$, false),
(3, 2, $ALT3_1$A reescrita está incorreta apenas na segunda oração, que deveria apresentar “os materiais eram catalogados”, em correspondência com “catalogava”.$ALT3_1$, true),
(3, 3, $ALT3_2$A reescrita está incorreta apenas na primeira oração, pois “lacrou” deveria ser transformado em “era lacrado”.$ALT3_2$, false),
(3, 4, $ALT3_3$A reescrita está incorreta apenas na terceira oração, pois “encaminhará” deveria ser transformado em “foi encaminhado”.$ALT3_3$, false),
(3, 5, $ALT3_4$A reescrita está incorreta porque a primeira e a terceira orações trocaram quem praticava e quem sofria as respectivas ações.$ALT3_4$, false),
(4, 1, $ALT4_0$A proposta preserva integralmente o sentido, pois apenas destaca um participante diferente da mesma ação.$ALT4_0$, false),
(4, 2, $ALT4_1$A proposta altera o sentido, pois apresenta os recrutas como responsáveis pela orientação e o instrutor como aquele que a recebeu.$ALT4_1$, true),
(4, 3, $ALT4_2$A proposta altera apenas a posição da expressão “durante o exercício”, sem modificar os papéis dos participantes.$ALT4_2$, false),
(4, 4, $ALT4_3$A frase original e a proposta indicam que instrutor e recrutas se orientaram reciprocamente.$ALT4_3$, false),
(4, 5, $ALT4_4$A frase original não admite reescrita na voz passiva, porque o verbo “orientar” não permite que o participante orientado seja colocado em destaque.$ALT4_4$, false),
(5, 1, $ALT5_0$Apenas I.$ALT5_0$, false),
(5, 2, $ALT5_1$Apenas I e II.$ALT5_1$, false),
(5, 3, $ALT5_2$Apenas I e III.$ALT5_2$, true),
(5, 4, $ALT5_3$Apenas II, III e IV.$ALT5_3$, false),
(5, 5, $ALT5_4$I, II, III e IV.$ALT5_4$, false),
(6, 1, $ALT6_0$Durante a operação, o veículo foi localizado pelos agentes e as provas foram entregues ao delegado pelos agentes.$ALT6_0$, true),
(6, 2, $ALT6_1$Durante a operação, o veículo será localizado pelos agentes e as provas serão entregues ao delegado pelos agentes.$ALT6_1$, false),
(6, 3, $ALT6_2$Durante a operação, os agentes foram localizados pelo veículo e as provas foram entregues ao delegado pelos agentes.$ALT6_2$, false),
(6, 4, $ALT6_3$Durante a operação, o veículo foi localizado pela equipe pericial e as provas foram entregues ao delegado pela equipe pericial.$ALT6_3$, false),
(6, 5, $ALT6_4$Durante a operação, o veículo foi localizado e as provas foram entregues ao delegado.$ALT6_4$, false),
(7, 1, $ALT7_0$Somente ao amanhecer e sob forte chuva, os vestígios deixados na estrada foram recolhidos pela equipe de perícia.$ALT7_0$, true),
(7, 2, $ALT7_1$Somente ao amanhecer e sob forte chuva, a equipe de perícia foi recolhida pelos vestígios deixados na estrada.$ALT7_1$, false),
(7, 3, $ALT7_2$Somente ao amanhecer e sob forte chuva, os vestígios deixados na estrada eram recolhidos pela equipe de perícia.$ALT7_2$, false),
(7, 4, $ALT7_3$Somente ao amanhecer e sob forte chuva, os vestígios deixados na estrada foram recolhidos para a equipe de perícia.$ALT7_3$, false),
(7, 5, $ALT7_4$Somente ao amanhecer e sob forte chuva, os vestígios deixados na estrada foi recolhido pela equipe de perícia.$ALT7_4$, false),
(8, 1, $ALT8_0$refeitas$ALT8_0$, true),
(8, 2, $ALT8_1$refazidas$ALT8_1$, false),
(8, 3, $ALT8_2$refeito$ALT8_2$, false),
(8, 4, $ALT8_3$refeitos$ALT8_3$, false),
(8, 5, $ALT8_4$refazida$ALT8_4$, false),
(9, 1, $ALT9_0$A rapidez foi considerada um aspecto importante no atendimento a ocorrências.$ALT9_0$, false),
(9, 2, $ALT9_1$Os agentes foram orientados a registrar informações essenciais antes do encaminhamento dos casos.$ALT9_1$, false),
(9, 3, $ALT9_2$Segundo a instrutora, a rapidez torna desnecessária a escuta atenta durante o atendimento.$ALT9_2$, true),
(9, 4, $ALT9_3$Nas simulações, a confirmação dos dados esteve associada a menos falhas de comunicação.$ALT9_3$, false),
(9, 5, $ALT9_4$A revisão periódica do protocolo foi recomendada sem a eliminação das etapas de conferência.$ALT9_4$, false),
(10, 1, $ALT10_0$A ampliação do horário das bibliotecas garante que todos os trabalhadores passem a frequentá-las no período noturno.$ALT10_0$, false),
(10, 2, $ALT10_1$Sem transporte noturno e equipes suficientes, somente os moradores das proximidades podem ser beneficiados pela ampliação do horário.$ALT10_1$, false),
(10, 3, $ALT10_2$A ampliação do horário pode facilitar o acesso de trabalhadores, mas o alcance da medida depende de condições complementares, como transporte e pessoal suficiente.$ALT10_2$, true),
(10, 4, $ALT10_3$A disponibilidade de transporte noturno é mais importante do que a existência de equipes suficientes nas bibliotecas.$ALT10_3$, false),
(10, 5, $ALT10_4$As bibliotecas municipais não devem ampliar seus horários enquanto houver trabalhadores impossibilitados de frequentá-las durante o dia.$ALT10_4$, false),
(11, 1, $ALT11_0$Apenas I.$ALT11_0$, false),
(11, 2, $ALT11_1$Apenas II.$ALT11_1$, false),
(11, 3, $ALT11_2$Apenas I e III.$ALT11_2$, true),
(11, 4, $ALT11_3$Apenas II e IV.$ALT11_3$, false),
(11, 5, $ALT11_4$Apenas I, III e IV.$ALT11_4$, false),
(12, 1, $ALT12_0$Informações sobre mudanças de circulação ajudam os moradores a organizar sua rotina.$ALT12_0$, false),
(12, 2, $ALT12_1$A comunicação com a comunidade deve integrar permanentemente a atuação das instituições de segurança, e não se limitar aos momentos de crise.$ALT12_1$, true),
(12, 3, $ALT12_2$A explicação dos objetivos e dos limites de uma operação reduz rumores e favorece a cooperação.$ALT12_2$, false),
(12, 4, $ALT12_3$Os avisos sobre bloqueios temporários devem ser divulgados antecipadamente, sempre que isso for possível.$ALT12_3$, false),
(12, 5, $ALT12_4$A comunicação institucional deve ser utilizada exclusivamente quando houver uma situação de crise.$ALT12_4$, false),
(13, 1, $ALT13_0$A simples instalação dos recipientes produziu uma redução imediata e expressiva do desperdício.$ALT13_0$, false),
(13, 2, $ALT13_1$O acompanhamento mensal foi o único responsável pela mudança de comportamento dos usuários.$ALT13_1$, false),
(13, 3, $ALT13_2$O objetivo central da iniciativa era apenas encontrar uma nova posição para os coletores.$ALT13_2$, false),
(13, 4, $ALT13_3$A mudança de hábitos em ambientes institucionais somente é possível mediante a aplicação de punições.$ALT13_3$, false),
(13, 5, $ALT13_4$A melhoria obtida resultou da articulação entre recursos adequados, orientação dos usuários e acompanhamento dos resultados.$ALT13_4$, true),
(14, 1, $ALT14_0$Apenas I.$ALT14_0$, true),
(14, 2, $ALT14_1$Apenas II.$ALT14_1$, false),
(14, 3, $ALT14_2$Apenas I e III.$ALT14_2$, false),
(14, 4, $ALT14_3$Apenas II e IV.$ALT14_3$, false),
(14, 5, $ALT14_4$Apenas I e IV.$ALT14_4$, false),
(15, 1, $ALT15_0$A estabilidade do número de estudantes participantes.$ALT15_0$, false),
(15, 2, $ALT15_1$O aumento da proporção de tarefas entregues no prazo.$ALT15_1$, true),
(15, 3, $ALT15_2$Os elogios dos estudantes aos tutoriais instalados.$ALT15_2$, false),
(15, 4, $ALT15_3$A ampliação do prazo de empréstimo dos aparelhos.$ALT15_3$, false),
(15, 5, $ALT15_4$A redução do acesso aos materiais fora da sala de aula.$ALT15_4$, false),
(16, 1, $ALT16_0$a que – com que – em que$ALT16_0$, true),
(16, 2, $ALT16_1$em que – de que – a que$ALT16_1$, false),
(16, 3, $ALT16_2$com que – em que – de que$ALT16_2$, false),
(16, 4, $ALT16_3$a que – de que – com que$ALT16_3$, false),
(16, 5, $ALT16_4$por que – a que – em que$ALT16_4$, false),
(17, 1, $ALT17_0$A pesquisadora cuja a análise foi publicada participará do seminário.$ALT17_0$, false),
(17, 2, $ALT17_1$O comandante cujo decisões foram elogiadas receberá a homenagem.$ALT17_1$, false),
(17, 3, $ALT17_2$Visitamos o museu cujas salas foram restauradas recentemente.$ALT17_2$, true),
(17, 4, $ALT17_3$Foram homenageadas as servidoras cuja desempenho se destacou no treinamento.$ALT17_3$, false),
(17, 5, $ALT17_4$Conheci os autores cujos os livros foram selecionados para a exposição.$ALT17_4$, false),
(18, 1, $ALT18_0$ao – os$ALT18_0$, true),
(18, 2, $ALT18_1$o – aos$ALT18_1$, false),
(18, 3, $ALT18_2$ao – aos$ALT18_2$, false),
(18, 4, $ALT18_3$o – os$ALT18_3$, false),
(18, 5, $ALT18_4$no – os$ALT18_4$, false),
(19, 1, $ALT19_0$Apenas I.$ALT19_0$, false),
(19, 2, $ALT19_1$Apenas II e III.$ALT19_1$, false),
(19, 3, $ALT19_2$Apenas I, III e IV.$ALT19_2$, true),
(19, 4, $ALT19_3$Apenas I, II e IV.$ALT19_3$, false),
(19, 5, $ALT19_4$Apenas II, III e IV.$ALT19_4$, false),
(20, 1, $ALT20_0$Prefiro mais patrulhar as ruas do que permanecer na base.$ALT20_0$, false),
(20, 2, $ALT20_1$Prefiro patrulhar as ruas do que permanecer na base.$ALT20_1$, false),
(20, 3, $ALT20_2$Prefiro de patrulhar as ruas a permanecer na base.$ALT20_2$, false),
(20, 4, $ALT20_3$Prefiro patrulhar as ruas a permanecer na base.$ALT20_3$, true),
(20, 5, $ALT20_4$Prefiro patrulhar as ruas que permanecer na base.$ALT20_4$, false),
(21, 1, $ALT21_0$Apenas I.$ALT21_0$, false),
(21, 2, $ALT21_1$Apenas II e IV.$ALT21_1$, false),
(21, 3, $ALT21_2$Apenas I e III.$ALT21_2$, true),
(21, 4, $ALT21_3$Apenas I, III e IV.$ALT21_3$, false),
(21, 5, $ALT21_4$I, II, III e IV.$ALT21_4$, false),
(22, 1, $ALT22_0$A proposta está inteiramente correta, pois “foram” conserva o mesmo tempo e modo de “conferia”, e “pela equipe de investigação” introduz adequadamente o agente da passiva.$ALT22_0$, false),
(22, 2, $ALT22_1$A proposta está incorreta apenas quanto à flexão do auxiliar “ser”: para conservar o pretérito imperfeito do indicativo, a forma adequada seria “eram conferidos”; a expressão “pela equipe de investigação” está correta.$ALT22_1$, true),
(22, 3, $ALT22_2$A proposta está incorreta apenas quanto à introdução do agente da passiva, que deveria ser expresso por “à equipe de investigação”; a forma “foram conferidos” conserva adequadamente o tempo verbal.$ALT22_2$, false),
(22, 4, $ALT22_3$A proposta está incorreta porque “os registros” deveria permanecer como objeto direto, sem assumir a posição de sujeito da nova oração.$ALT22_3$, false),
(22, 5, $ALT22_4$A transposição é impossível, pois o verbo “conferir”, no contexto apresentado, não admite que seu complemento seja promovido a sujeito.$ALT22_4$, false),
(23, 1, $ALT23_0$Adquiriu-se$ALT23_0$, false),
(23, 2, $ALT23_1$Adquiriram-se$ALT23_1$, true),
(23, 3, $ALT23_2$Adquiriam-se$ALT23_2$, false),
(23, 4, $ALT23_3$Adquirir-se-ão$ALT23_3$, false),
(23, 5, $ALT23_4$Adquirira-se$ALT23_4$, false),
(24, 1, $ALT24_0$Apenas I.$ALT24_0$, false),
(24, 2, $ALT24_1$Apenas II e IV.$ALT24_1$, false),
(24, 3, $ALT24_2$Apenas I e III.$ALT24_2$, false),
(24, 4, $ALT24_3$Apenas I, II e III.$ALT24_3$, true),
(24, 5, $ALT24_4$I, II, III e IV.$ALT24_4$, false);

create temporary table _unidades_ordem (ordem_min int, ordem_max int, unidade_pedagogica_id uuid) on commit drop;
insert into _unidades_ordem (ordem_min, ordem_max, unidade_pedagogica_id) values
(1, 8, '5cc30e49-890f-4b83-b96f-31724024ee24'::uuid),
(9, 15, '138aafa7-066c-40fd-9fa5-7f1b90406db2'::uuid),
(16, 20, '735f736a-37c0-477f-a555-dcd73d243d21'::uuid),
(21, 24, '1cb6bef3-1d8d-4cae-9ed9-eae9fe4d79b9'::uuid);

-- ===================== FASE OLD =====================
do $$
declare
  v_unidade_ok boolean;
  v_uteis int; v_real int; v_autoral int; v_gap int; v_dup int;
  r record;
begin
  for r in select unidade_pedagogica_id, ordem_min, ordem_max from _unidades_ordem loop
    select (up.ativa and cc.relevante_para_preparacao and cm.relevante_para_preparacao and cm.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4')
    into v_unidade_ok
    from public.unidades_pedagogicas up
    join public.curso_conteudos cc on cc.id = up.curso_conteudo_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where up.id = r.unidade_pedagogica_id;
    insert into _relatorio values ('OLD', 'unidade_ok_' || r.unidade_pedagogica_id, coalesce(v_unidade_ok,false), 'ativa+relevante');

    select count(distinct q.id) into v_uteis
    from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
    where qup.unidade_pedagogica_id = r.unidade_pedagogica_id and q.ativa=true
    and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
    insert into _relatorio values ('OLD', 'uteis_' || r.unidade_pedagogica_id, true, v_uteis::text);

    select count(*) into v_gap
    from (
      select distinct q.id from public.questoes q
      join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
      where qup.unidade_pedagogica_id = r.unidade_pedagogica_id and q.ativa
      and not exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id)
    ) g;
    insert into _relatorio values ('OLD', 'gap_0_' || r.unidade_pedagogica_id, v_gap = 0, v_gap::text);
  end loop;

  select count(*) into v_dup
  from public.questoes q
  where q.ativa = true
  and lower(q.enunciado) in (
  lower($DUP1$Assinale a alternativa que apresenta a transposição correta para a voz passiva analítica da frase “A comissão revisava os procedimentos mensalmente”, preservando o tempo verbal e o sentido original.$DUP1$),
  lower($DUP2$Considere a frase ativa “As servidoras organizam o arquivo” e as seguintes propostas de reescrita na voz passiva analítica:

I. O arquivo é organizado pelas servidoras.
II. O arquivo é organizado para as servidoras.
III. Pelas servidoras, foi organizado o arquivo.
IV. Pelas servidoras, o arquivo é organizado.

Quais propostas introduzem corretamente o agente da passiva e preservam o sentido da frase original?$DUP2$),
  lower($DUP3$Considere o período na voz ativa:

“A equipe de inspeção lacrou o depósito, a equipe de inspeção catalogava os materiais e a equipe de inspeção encaminhará o relatório.”

Foi proposta a seguinte reescrita na voz passiva analítica:

“O depósito foi lacrado pela equipe de inspeção, os materiais foram catalogados pela equipe de inspeção e o relatório será encaminhado pela equipe de inspeção.”

Assinale a alternativa que avalia corretamente essa reescrita.$DUP3$),
  lower($DUP4$Considere a frase original e a proposta de reescrita:

Original: “O instrutor orientou os recrutas durante o exercício.”

Proposta: “O instrutor foi orientado pelos recrutas durante o exercício.”

Assinale a alternativa que identifica corretamente o problema da proposta.$DUP4$),
  lower($DUP5$Considere as frases a seguir:

I. Os peritos examinaram os documentos apreendidos.
II. Os soldados chegaram ao quartel antes do amanhecer.
III. A comissão concedeu medalhas aos agentes.
IV. Os moradores necessitam de proteção constante.

Quais frases admitem transposição natural e gramaticalmente adequada para a voz passiva analítica?$DUP5$),
  lower($DUP6$Considere a frase a seguir:

“Durante a operação, os agentes localizaram o veículo e entregaram as provas ao delegado.”

Assinale a alternativa que apresenta a transposição para a voz passiva analítica preservando integralmente o tempo verbal, os papéis semânticos e a indicação de quem praticou as ações.$DUP6$),
  lower($DUP7$Considere a frase: “A equipe de perícia recolheu, somente ao amanhecer e sob forte chuva, os vestígios deixados na estrada.” Assinale a alternativa que apresenta a correta transposição dessa frase para a voz passiva analítica, sem alteração do sentido original.$DUP7$),
  lower($DUP8$Considere a frase na voz ativa: “A equipe técnica refez as medições.” Na transposição para a voz passiva analítica, o auxiliar já foi corretamente empregado: “As medições foram ______ pela equipe técnica.” Assinale a alternativa que preenche corretamente a lacuna.$DUP8$),
  lower($DUP9$Em um treinamento sobre atendimento a ocorrências, a instrutora afirmou que a rapidez é importante, mas não substitui a escuta atenta. Ela orientou os agentes a registrar as informações essenciais antes de encaminhar cada caso. Nas simulações, as equipes que confirmaram os dados cometeram menos falhas de comunicação. Ao final, a instrutora recomendou que o protocolo fosse revisto periodicamente, sem o abandono das etapas de conferência.

Assinale a alternativa que contraria diretamente uma informação explícita do texto.$DUP9$),
  lower($DUP10$Leia o texto a seguir.

A ampliação do horário de funcionamento das bibliotecas municipais pode facilitar o acesso de trabalhadores que não conseguem frequentá-las durante o dia, desde que a medida seja acompanhada por transporte noturno adequado e por equipes suficientes para atender o público. Sem essas condições, a mudança tende a beneficiar sobretudo os moradores das proximidades, produzindo um alcance mais limitado.

Assinale a alternativa que representa corretamente o conteúdo do texto.$DUP10$),
  lower($DUP11$Leia o texto a seguir.

Durante três meses, uma unidade de saúde passou a enviar lembretes de consultas com 48 horas de antecedência. No período, foram mantidos os mesmos horários de atendimento, a mesma equipe e os mesmos critérios de agendamento. A proporção de faltas caiu de 22% para 14%. Uma pesquisa posterior revelou, porém, que alguns usuários, por estarem com os dados de contato desatualizados, não receberam as mensagens. Entre os que confirmaram o recebimento, a redução das faltas foi mais acentuada. Os dados disponíveis não permitem saber se o resultado se manterá por períodos mais longos.

Considere as seguintes afirmativas:

I. Os dados sustentam a inferência de que os lembretes podem ter contribuído para a redução das faltas, embora não demonstrem que tenham sido sua única causa.
II. Todos os usuários que receberam os lembretes compareceram às consultas marcadas.
III. A manutenção dos horários, da equipe e dos critérios de agendamento reforça a interpretação de que a introdução dos lembretes está relacionada à mudança observada.
IV. A atualização dos dados de contato de todos os usuários eliminaria definitivamente as faltas às consultas.

Quais afirmativas apresentam inferências válidas com base no texto?$DUP11$),
  lower($DUP12$Leia o texto a seguir:

Em instituições de segurança, a comunicação com a comunidade não deve ocorrer apenas em momentos de crise; ela precisa integrar permanentemente a prestação do serviço. Informações claras sobre mudanças de circulação ou ações preventivas, por exemplo, ajudam os moradores a organizar sua rotina. Além disso, explicar os objetivos e os limites de uma operação reduz rumores e favorece a cooperação. Por isso, avisos sobre bloqueios temporários devem ser divulgados com antecedência, sempre que possível.

Assinale a alternativa que expressa corretamente a tese defendida no texto.$DUP12$),
  lower($DUP13$Leia o texto a seguir:

Em um centro de formação, a redução de desperdícios começou com a instalação de recipientes para separar resíduos. Nas primeiras semanas, porém, o volume enviado ao descarte comum quase não mudou. A equipe então passou a orientar os usuários, reposicionou os coletores e acompanhou mensalmente os resultados. Com essas medidas articuladas, a separação melhorou de forma gradual. A experiência mostrou que equipamentos, sozinhos, não alteram hábitos: mudanças consistentes dependem também de orientação e acompanhamento.

Considerando a compreensão global do texto, assinale a alternativa correta.$DUP13$),
  lower($DUP14$Leia o texto a seguir.

Durante seis meses, metade das luminárias de um bairro foi substituída por modelos direcionados para o chão. Nas vias atendidas, o consumo de energia caiu 18%, e as reclamações de moradores sobre luz excessiva dentro das residências tornaram-se menos frequentes. A mudança, contudo, não eliminou todas as queixas. Alguns comerciantes perceberam maior circulação de pedestres ao anoitecer, mas o relatório do projeto considerou insuficientes os dados disponíveis para atribuir esse movimento à nova iluminação.

Com base exclusivamente no texto, analise as seguintes assertivas:

I. A substituição das luminárias reduziu o consumo de energia e a frequência de determinadas reclamações nas vias atendidas.
II. O relatório comprovou que a nova iluminação foi responsável pelo aumento da circulação de pedestres.
III. Nas vias atendidas, as reclamações sobre luz excessiva dentro das residências tornaram-se mais frequentes.
IV. O único resultado observado após a substituição das luminárias foi a redução do consumo de energia.

Quais assertivas são efetivamente sustentadas pelo texto?$DUP14$),
  lower($DUP15$Leia o texto a seguir.

Uma escola realizou, por três meses, um projeto de empréstimo de tablets aos estudantes. Ao fim da experiência, o número de participantes permaneceu estável, mas a proporção de tarefas entregues no prazo passou de 62% para 81%. A coordenadora decidiu manter o projeto precisamente porque esse aumento indicava maior regularidade no acesso aos materiais fora da sala de aula. Os estudantes também elogiaram os tutoriais instalados nos aparelhos, e a equipe estuda ampliar o prazo de empréstimo na próxima etapa.

De acordo com o texto, qual dado foi apresentado como razão direta para a decisão de manter o projeto?$DUP15$),
  lower($DUP16$Assinale a alternativa que preenche, correta e respectivamente, as lacunas da frase a seguir.

As metas ___ a equipe aspirava, os recursos ___ os agentes contavam e o procedimento ___ o instrutor insistia foram registrados no relatório.$DUP16$),
  lower($DUP17$Considerando as regras de emprego do pronome relativo “cujo” e suas flexões, assinale a alternativa correta.$DUP17$),
  lower($DUP18$Assinale a alternativa que preenche correta e respectivamente as lacunas, de acordo com a regência do verbo “assistir” no padrão formal da Língua Portuguesa.

I. Após o treinamento, os soldados assistiram ___ documentário sobre segurança pública.
II. Durante o acidente, os socorristas assistiram ___ feridos até a chegada da equipe médica.$DUP18$),
  lower($DUP19$Analise as afirmativas a seguir quanto à regência dos verbos “obedecer” e “desobedecer” no padrão formal da Língua Portuguesa.

I. Os soldados obedeceram ao regulamento durante a operação.
II. O candidato desobedeceu o comando do instrutor.
III. Os subordinados devem obedecer aos superiores hierárquicos.
IV. O agente jamais desobedeceu ao protocolo de segurança.

Quais afirmativas estão corretas?$DUP19$),
  lower($DUP20$Assinale a alternativa em que o verbo “preferir” foi empregado corretamente de acordo com a norma-padrão tradicional.$DUP20$),
  lower($DUP21$Considere as seguintes orações:

I. Durante a inspeção, os fiscais vistoriaram cuidadosamente o local.
II. O local foi vistoriado pelos fiscais durante a inspeção.
III. A comissão aprovou, por unanimidade, o novo relatório.
IV. O relatório foi aprovado por unanimidade.

Quais estão construídas na voz ativa?$DUP21$),
  lower($DUP22$Considere a oração na voz ativa e a proposta de transposição para a voz passiva analítica:

Voz ativa: “A equipe de investigação conferia os registros todas as manhãs.”

Proposta: “Os registros foram conferidos pela equipe de investigação todas as manhãs.”

À luz da norma-padrão, assinale a alternativa que avalia corretamente a proposta.$DUP22$),
  lower($DUP23$Assinale a alternativa que preenche corretamente a lacuna, empregando a voz passiva sintética e o pretérito perfeito do indicativo.

“__________ novos equipamentos de comunicação para a unidade na semana passada.”$DUP23$),
  lower($DUP24$Considere as frases a seguir.

1. Divulgaram-se novas instruções aos integrantes da unidade.
2. Confia-se em profissionais experientes durante operações delicadas.

Analise as seguintes afirmativas:

I. Na frase 1, o pronome “se” é apassivador, e “novas instruções” funciona como sujeito paciente.
II. Na frase 1, o plural de “divulgaram-se” decorre da concordância com “novas instruções”.
III. Na frase 2, o pronome “se” é índice de indeterminação do sujeito, e o verbo deve permanecer na terceira pessoa do singular.
IV. Na frase 2, o plural de “profissionais experientes” exigiria a forma “confiam-se”.

Quais afirmativas estão corretas?$DUP24$)
  );
  insert into _relatorio values ('OLD', 'sem_duplicidade', v_dup = 0, v_dup::text);
end $$;

-- ===================== APPLY (mesma logica do script real) =====================
create temporary table _mapa_ids (ordem int primary key, questao_id bigint, unidade_pedagogica_id uuid) on commit drop;

do $$
declare
  r record;
  v_novo_id bigint;
  v_uid uuid;
  v_count int := 0;
begin
  for r in select ordem, dificuldade, fonte, enunciado from _lote_questoes order by ordem loop
    select unidade_pedagogica_id into v_uid from _unidades_ordem where r.ordem between ordem_min and ordem_max;

    insert into public.questoes (materia_id, assunto_id, banca, concurso, ano, dificuldade, enunciado, explicacao, fonte, ativa, usuario_id)
    select cc.curso_materia_id_materia, cc.assunto_id, 'Papiro', 'PAPIRO - Curadoria LOTE02_PORTUGUES_AUTORAL - BM RS', 2026, r.dificuldade, r.enunciado,
      (select explicacao from _lote_explicacoes le where le.ordem = r.ordem),
      r.fonte, true, null
    from (
      select cm.materia_id as curso_materia_id_materia, cc2.assunto_id
      from public.curso_conteudos cc2
      join public.curso_materias cm on cm.id = cc2.curso_materia_id
      where cc2.id = (select curso_conteudo_id from _lote_questoes where ordem = r.ordem)
    ) cc
    returning id into v_novo_id;

    insert into _mapa_ids (ordem, questao_id, unidade_pedagogica_id) values (r.ordem, v_novo_id, v_uid);

    insert into public.alternativas (questao_id, texto, ordem, correta)
    select v_novo_id, la.texto, la.letra_ordem, la.correta
    from _lote_alternativas la
    where la.ordem = r.ordem;

    v_count := v_count + 1;
  end loop;
  insert into _relatorio values ('APPLY', 'questoes_criadas_24', v_count = 24, v_count::text);
end $$;

-- ===================== VINCULO via RPC sancionada =====================
do $$
declare
  r record;
  v_count int := 0;
begin
  for r in select questao_id, unidade_pedagogica_id from _mapa_ids order by ordem loop
    perform public.classificar_questao_unidade_admin(r.questao_id, r.unidade_pedagogica_id);
    v_count := v_count + 1;
  end loop;
  insert into _relatorio values ('APPLY', 'vinculos_criados_24', v_count = 24, v_count::text);
end $$;

-- ===================== FASE TARGET =====================
do $$
declare
  v_snap record;
  v_questoes int; v_alternativas int; v_vinculos int; v_curso_questoes int;
  v_uteis int; v_real int; v_autoral int;
  v_vinc_ok int; v_cq_ok int;
  v_gabaritos text;
  r record;
begin
  select * into v_snap from _snapshot_antes;

  select count(*) into v_questoes from public.questoes;
  select count(*) into v_alternativas from public.alternativas;
  select count(*) into v_vinculos from public.questao_unidades_pedagogicas;
  select count(*) into v_curso_questoes from public.curso_questoes;

  insert into _relatorio values ('TARGET', 'questoes_delta_24', v_questoes - v_snap.total_questoes = 24, (v_questoes - v_snap.total_questoes)::text);
  insert into _relatorio values ('TARGET', 'alternativas_delta_120', v_alternativas - v_snap.total_alternativas = 120, (v_alternativas - v_snap.total_alternativas)::text);
  insert into _relatorio values ('TARGET', 'vinculos_delta_24', v_vinculos - v_snap.total_vinculos = 24, (v_vinculos - v_snap.total_vinculos)::text);
  insert into _relatorio values ('TARGET', 'curso_questoes_delta_24', v_curso_questoes - v_snap.total_curso_questoes = 24, (v_curso_questoes - v_snap.total_curso_questoes)::text);

  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='5cc30e49-890f-4b83-b96f-31724024ee24' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET', 'uteis_10_5cc30e49-890f-4b83-b96f-31724024ee24', v_uteis = 10, v_uteis::text);

  select count(distinct q.id) filter (where coalesce(lower(q.banca),'') not like '%papiro%'),
         count(distinct q.id) filter (where coalesce(lower(q.banca),'') like '%papiro%')
    into v_real, v_autoral
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='5cc30e49-890f-4b83-b96f-31724024ee24' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET', 'real_1_5cc30e49-890f-4b83-b96f-31724024ee24', v_real = 1, v_real::text);
  insert into _relatorio values ('TARGET', 'autoral_9_5cc30e49-890f-4b83-b96f-31724024ee24', v_autoral = 9, v_autoral::text);

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=m.questao_id and correta=true), '' order by m.ordem)
    into v_gabaritos from _mapa_ids m where m.unidade_pedagogica_id = '5cc30e49-890f-4b83-b96f-31724024ee24';
  insert into _relatorio values ('TARGET', 'gabaritos_5cc30e49-890f-4b83-b96f-31724024ee24', v_gabaritos = 'BCBBCAAA', v_gabaritos);

  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='138aafa7-066c-40fd-9fa5-7f1b90406db2' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET', 'uteis_10_138aafa7-066c-40fd-9fa5-7f1b90406db2', v_uteis = 10, v_uteis::text);

  select count(distinct q.id) filter (where coalesce(lower(q.banca),'') not like '%papiro%'),
         count(distinct q.id) filter (where coalesce(lower(q.banca),'') like '%papiro%')
    into v_real, v_autoral
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='138aafa7-066c-40fd-9fa5-7f1b90406db2' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET', 'real_1_138aafa7-066c-40fd-9fa5-7f1b90406db2', v_real = 1, v_real::text);
  insert into _relatorio values ('TARGET', 'autoral_9_138aafa7-066c-40fd-9fa5-7f1b90406db2', v_autoral = 9, v_autoral::text);

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=m.questao_id and correta=true), '' order by m.ordem)
    into v_gabaritos from _mapa_ids m where m.unidade_pedagogica_id = '138aafa7-066c-40fd-9fa5-7f1b90406db2';
  insert into _relatorio values ('TARGET', 'gabaritos_138aafa7-066c-40fd-9fa5-7f1b90406db2', v_gabaritos = 'CCCBEAB', v_gabaritos);

  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='735f736a-37c0-477f-a555-dcd73d243d21' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET', 'uteis_8_735f736a-37c0-477f-a555-dcd73d243d21', v_uteis = 8, v_uteis::text);

  select count(distinct q.id) filter (where coalesce(lower(q.banca),'') not like '%papiro%'),
         count(distinct q.id) filter (where coalesce(lower(q.banca),'') like '%papiro%')
    into v_real, v_autoral
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='735f736a-37c0-477f-a555-dcd73d243d21' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET', 'real_1_735f736a-37c0-477f-a555-dcd73d243d21', v_real = 1, v_real::text);
  insert into _relatorio values ('TARGET', 'autoral_7_735f736a-37c0-477f-a555-dcd73d243d21', v_autoral = 7, v_autoral::text);

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=m.questao_id and correta=true), '' order by m.ordem)
    into v_gabaritos from _mapa_ids m where m.unidade_pedagogica_id = '735f736a-37c0-477f-a555-dcd73d243d21';
  insert into _relatorio values ('TARGET', 'gabaritos_735f736a-37c0-477f-a555-dcd73d243d21', v_gabaritos = 'ACACD', v_gabaritos);

  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='1cb6bef3-1d8d-4cae-9ed9-eae9fe4d79b9' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET', 'uteis_7_1cb6bef3-1d8d-4cae-9ed9-eae9fe4d79b9', v_uteis = 7, v_uteis::text);

  select count(distinct q.id) filter (where coalesce(lower(q.banca),'') not like '%papiro%'),
         count(distinct q.id) filter (where coalesce(lower(q.banca),'') like '%papiro%')
    into v_real, v_autoral
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='1cb6bef3-1d8d-4cae-9ed9-eae9fe4d79b9' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  insert into _relatorio values ('TARGET', 'real_0_1cb6bef3-1d8d-4cae-9ed9-eae9fe4d79b9', v_real = 0, v_real::text);
  insert into _relatorio values ('TARGET', 'autoral_7_1cb6bef3-1d8d-4cae-9ed9-eae9fe4d79b9', v_autoral = 7, v_autoral::text);

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=m.questao_id and correta=true), '' order by m.ordem)
    into v_gabaritos from _mapa_ids m where m.unidade_pedagogica_id = '1cb6bef3-1d8d-4cae-9ed9-eae9fe4d79b9';
  insert into _relatorio values ('TARGET', 'gabaritos_1cb6bef3-1d8d-4cae-9ed9-eae9fe4d79b9', v_gabaritos = 'CBBD', v_gabaritos);

  select count(*) into v_vinc_ok from _mapa_ids m
    where exists(select 1 from public.questao_unidades_pedagogicas qup where qup.questao_id=m.questao_id and qup.unidade_pedagogica_id=m.unidade_pedagogica_id)
    and not exists(select 1 from public.questao_unidades_pedagogicas qup2 where qup2.questao_id=m.questao_id and qup2.unidade_pedagogica_id <> m.unidade_pedagogica_id);
  insert into _relatorio values ('TARGET', 'vinculos_24_corretos', v_vinc_ok = 24, v_vinc_ok::text);

  select count(*) into v_cq_ok from _mapa_ids m
    where exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=m.questao_id);
  insert into _relatorio values ('TARGET', 'curso_questoes_24', v_cq_ok = 24, v_cq_ok::text);

  insert into _relatorio values ('TARGET', 'ativa_24de24',
    (select count(*) from _mapa_ids m join public.questoes q on q.id=m.questao_id where q.ativa) = 24, 'ativa');
  insert into _relatorio values ('TARGET', 'origem_papiro_24de24',
    (select count(*) from _mapa_ids m join public.questoes q on q.id=m.questao_id where coalesce(lower(q.banca),'') like '%papiro%') = 24, 'banca papiro');
end $$;

-- ===================== REVERSAO REAL (mesma logica do reverter real) =====================
do $$
declare
  v_uteis int;
  r record;
begin
  for r in select unidade_pedagogica_id from _unidades_ordem loop
    select count(distinct q.id) into v_uteis
    from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
    where qup.unidade_pedagogica_id = r.unidade_pedagogica_id and q.ativa=true
    and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
    insert into _relatorio values ('REVERSAO_GUARD', 'uteis_antes_de_reverter_' || r.unidade_pedagogica_id, v_uteis > 0, v_uteis::text);
  end loop;
end $$;

do $$
declare
  r record;
  v_count int := 0;
begin
  for r in select questao_id, unidade_pedagogica_id from _mapa_ids order by ordem loop
    perform public.remover_classificacao_questao_unidade_admin(r.questao_id, r.unidade_pedagogica_id);
    v_count := v_count + 1;
  end loop;
  insert into _relatorio values ('REVERSAO', 'vinculos_removidos_24', v_count = 24, v_count::text);
end $$;

do $$
declare v_count int;
begin
  delete from public.curso_questoes where curso_id = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and questao_id in (select questao_id from _mapa_ids);
  get diagnostics v_count = row_count;
  insert into _relatorio values ('REVERSAO', 'curso_questoes_removidas_24', v_count = 24, v_count::text);
end $$;

do $$
declare v_count int;
begin
  delete from public.alternativas where questao_id in (select questao_id from _mapa_ids);
  get diagnostics v_count = row_count;
  insert into _relatorio values ('REVERSAO', 'alternativas_removidas_120', v_count = 120, v_count::text);
end $$;

do $$
declare v_count int;
begin
  delete from public.questoes where id in (select questao_id from _mapa_ids);
  get diagnostics v_count = row_count;
  insert into _relatorio values ('REVERSAO', 'questoes_removidas_24', v_count = 24, v_count::text);
end $$;

-- ===================== FASE OLD_FINAL (pos-reversao) =====================
do $$
declare
  v_snap record;
  v_questoes int; v_alternativas int; v_vinculos int; v_curso_questoes int;
begin
  select * into v_snap from _snapshot_antes;

  select count(*) into v_questoes from public.questoes;
  select count(*) into v_alternativas from public.alternativas;
  select count(*) into v_vinculos from public.questao_unidades_pedagogicas;
  select count(*) into v_curso_questoes from public.curso_questoes;

  insert into _relatorio values ('OLD_FINAL', 'questoes_restauradas', v_questoes = v_snap.total_questoes, v_questoes::text);
  insert into _relatorio values ('OLD_FINAL', 'alternativas_restauradas', v_alternativas = v_snap.total_alternativas, v_alternativas::text);
  insert into _relatorio values ('OLD_FINAL', 'vinculos_restaurados', v_vinculos = v_snap.total_vinculos, v_vinculos::text);
  insert into _relatorio values ('OLD_FINAL', 'curso_questoes_restauradas', v_curso_questoes = v_snap.total_curso_questoes, v_curso_questoes::text);
end $$;

-- ===================== RESUMO =====================
select fase, count(*) as total, count(*) filter (where ok) as ok_count
from _relatorio group by fase order by min(ctid);

select * from _relatorio where not ok;

do $$
declare
  v_total int; v_ok int;
begin
  select count(*), count(*) filter (where ok) into v_total, v_ok from _relatorio;
  if v_total = v_ok then
    raise notice 'TESTE DE ROLLBACK: %/% checks OK — LOTE02_PORTUGUES_AUTORAL_ROLLBACK_TEST_APROVADO', v_ok, v_total;
  else
    raise notice 'TESTE DE ROLLBACK: %/% checks OK — HA FALHAS, ver _relatorio', v_ok, v_total;
  end if;
end $$;

rollback;
