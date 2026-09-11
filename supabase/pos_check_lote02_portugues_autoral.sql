-- POS-CHECK — importacao LOTE02_PORTUGUES_AUTORAL.
--
-- READ-ONLY. Confirma, independentemente do apply, o estado das 24
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
  'Assinale a alternativa que apresenta a transposição correta para a voz passiva analítica da frase “A comissão revisava os procedimentos mensalmente”, preservando o tempo verbal e o sentido original.',
  'Considere a frase ativa “As servidoras organizam o arquivo” e as seguintes propostas de reescrita na voz passiva analítica:

I. O arquivo é organizado pelas servidoras.
II. O arquivo é organizado para as servidoras.
III. Pelas servidoras, foi organizado o arquivo.
IV. Pelas servidoras, o arquivo é organizado.

Quais propostas introduzem corretamente o agente da passiva e preservam o sentido da frase original?',
  'Considere o período na voz ativa:

“A equipe de inspeção lacrou o depósito, a equipe de inspeção catalogava os materiais e a equipe de inspeção encaminhará o relatório.”

Foi proposta a seguinte reescrita na voz passiva analítica:

“O depósito foi lacrado pela equipe de inspeção, os materiais foram catalogados pela equipe de inspeção e o relatório será encaminhado pela equipe de inspeção.”

Assinale a alternativa que avalia corretamente essa reescrita.',
  'Considere a frase original e a proposta de reescrita:

Original: “O instrutor orientou os recrutas durante o exercício.”

Proposta: “O instrutor foi orientado pelos recrutas durante o exercício.”

Assinale a alternativa que identifica corretamente o problema da proposta.',
  'Considere as frases a seguir:

I. Os peritos examinaram os documentos apreendidos.
II. Os soldados chegaram ao quartel antes do amanhecer.
III. A comissão concedeu medalhas aos agentes.
IV. Os moradores necessitam de proteção constante.

Quais frases admitem transposição natural e gramaticalmente adequada para a voz passiva analítica?',
  'Considere a frase a seguir:

“Durante a operação, os agentes localizaram o veículo e entregaram as provas ao delegado.”

Assinale a alternativa que apresenta a transposição para a voz passiva analítica preservando integralmente o tempo verbal, os papéis semânticos e a indicação de quem praticou as ações.',
  'Considere a frase: “A equipe de perícia recolheu, somente ao amanhecer e sob forte chuva, os vestígios deixados na estrada.” Assinale a alternativa que apresenta a correta transposição dessa frase para a voz passiva analítica, sem alteração do sentido original.',
  'Considere a frase na voz ativa: “A equipe técnica refez as medições.” Na transposição para a voz passiva analítica, o auxiliar já foi corretamente empregado: “As medições foram ______ pela equipe técnica.” Assinale a alternativa que preenche corretamente a lacuna.',
  'Em um treinamento sobre atendimento a ocorrências, a instrutora afirmou que a rapidez é importante, mas não substitui a escuta atenta. Ela orientou os agentes a registrar as informações essenciais antes de encaminhar cada caso. Nas simulações, as equipes que confirmaram os dados cometeram menos falhas de comunicação. Ao final, a instrutora recomendou que o protocolo fosse revisto periodicamente, sem o abandono das etapas de conferência.

Assinale a alternativa que contraria diretamente uma informação explícita do texto.',
  'Leia o texto a seguir.

A ampliação do horário de funcionamento das bibliotecas municipais pode facilitar o acesso de trabalhadores que não conseguem frequentá-las durante o dia, desde que a medida seja acompanhada por transporte noturno adequado e por equipes suficientes para atender o público. Sem essas condições, a mudança tende a beneficiar sobretudo os moradores das proximidades, produzindo um alcance mais limitado.

Assinale a alternativa que representa corretamente o conteúdo do texto.',
  'Leia o texto a seguir.

Durante três meses, uma unidade de saúde passou a enviar lembretes de consultas com 48 horas de antecedência. No período, foram mantidos os mesmos horários de atendimento, a mesma equipe e os mesmos critérios de agendamento. A proporção de faltas caiu de 22% para 14%. Uma pesquisa posterior revelou, porém, que alguns usuários, por estarem com os dados de contato desatualizados, não receberam as mensagens. Entre os que confirmaram o recebimento, a redução das faltas foi mais acentuada. Os dados disponíveis não permitem saber se o resultado se manterá por períodos mais longos.

Considere as seguintes afirmativas:

I. Os dados sustentam a inferência de que os lembretes podem ter contribuído para a redução das faltas, embora não demonstrem que tenham sido sua única causa.
II. Todos os usuários que receberam os lembretes compareceram às consultas marcadas.
III. A manutenção dos horários, da equipe e dos critérios de agendamento reforça a interpretação de que a introdução dos lembretes está relacionada à mudança observada.
IV. A atualização dos dados de contato de todos os usuários eliminaria definitivamente as faltas às consultas.

Quais afirmativas apresentam inferências válidas com base no texto?',
  'Leia o texto a seguir:

Em instituições de segurança, a comunicação com a comunidade não deve ocorrer apenas em momentos de crise; ela precisa integrar permanentemente a prestação do serviço. Informações claras sobre mudanças de circulação ou ações preventivas, por exemplo, ajudam os moradores a organizar sua rotina. Além disso, explicar os objetivos e os limites de uma operação reduz rumores e favorece a cooperação. Por isso, avisos sobre bloqueios temporários devem ser divulgados com antecedência, sempre que possível.

Assinale a alternativa que expressa corretamente a tese defendida no texto.',
  'Leia o texto a seguir:

Em um centro de formação, a redução de desperdícios começou com a instalação de recipientes para separar resíduos. Nas primeiras semanas, porém, o volume enviado ao descarte comum quase não mudou. A equipe então passou a orientar os usuários, reposicionou os coletores e acompanhou mensalmente os resultados. Com essas medidas articuladas, a separação melhorou de forma gradual. A experiência mostrou que equipamentos, sozinhos, não alteram hábitos: mudanças consistentes dependem também de orientação e acompanhamento.

Considerando a compreensão global do texto, assinale a alternativa correta.',
  'Leia o texto a seguir.

Durante seis meses, metade das luminárias de um bairro foi substituída por modelos direcionados para o chão. Nas vias atendidas, o consumo de energia caiu 18%, e as reclamações de moradores sobre luz excessiva dentro das residências tornaram-se menos frequentes. A mudança, contudo, não eliminou todas as queixas. Alguns comerciantes perceberam maior circulação de pedestres ao anoitecer, mas o relatório do projeto considerou insuficientes os dados disponíveis para atribuir esse movimento à nova iluminação.

Com base exclusivamente no texto, analise as seguintes assertivas:

I. A substituição das luminárias reduziu o consumo de energia e a frequência de determinadas reclamações nas vias atendidas.
II. O relatório comprovou que a nova iluminação foi responsável pelo aumento da circulação de pedestres.
III. Nas vias atendidas, as reclamações sobre luz excessiva dentro das residências tornaram-se mais frequentes.
IV. O único resultado observado após a substituição das luminárias foi a redução do consumo de energia.

Quais assertivas são efetivamente sustentadas pelo texto?',
  'Leia o texto a seguir.

Uma escola realizou, por três meses, um projeto de empréstimo de tablets aos estudantes. Ao fim da experiência, o número de participantes permaneceu estável, mas a proporção de tarefas entregues no prazo passou de 62% para 81%. A coordenadora decidiu manter o projeto precisamente porque esse aumento indicava maior regularidade no acesso aos materiais fora da sala de aula. Os estudantes também elogiaram os tutoriais instalados nos aparelhos, e a equipe estuda ampliar o prazo de empréstimo na próxima etapa.

De acordo com o texto, qual dado foi apresentado como razão direta para a decisão de manter o projeto?',
  'Assinale a alternativa que preenche, correta e respectivamente, as lacunas da frase a seguir.

As metas ___ a equipe aspirava, os recursos ___ os agentes contavam e o procedimento ___ o instrutor insistia foram registrados no relatório.',
  'Considerando as regras de emprego do pronome relativo “cujo” e suas flexões, assinale a alternativa correta.',
  'Assinale a alternativa que preenche correta e respectivamente as lacunas, de acordo com a regência do verbo “assistir” no padrão formal da Língua Portuguesa.

I. Após o treinamento, os soldados assistiram ___ documentário sobre segurança pública.
II. Durante o acidente, os socorristas assistiram ___ feridos até a chegada da equipe médica.',
  'Analise as afirmativas a seguir quanto à regência dos verbos “obedecer” e “desobedecer” no padrão formal da Língua Portuguesa.

I. Os soldados obedeceram ao regulamento durante a operação.
II. O candidato desobedeceu o comando do instrutor.
III. Os subordinados devem obedecer aos superiores hierárquicos.
IV. O agente jamais desobedeceu ao protocolo de segurança.

Quais afirmativas estão corretas?',
  'Assinale a alternativa em que o verbo “preferir” foi empregado corretamente de acordo com a norma-padrão tradicional.',
  'Considere as seguintes orações:

I. Durante a inspeção, os fiscais vistoriaram cuidadosamente o local.
II. O local foi vistoriado pelos fiscais durante a inspeção.
III. A comissão aprovou, por unanimidade, o novo relatório.
IV. O relatório foi aprovado por unanimidade.

Quais estão construídas na voz ativa?',
  'Considere a oração na voz ativa e a proposta de transposição para a voz passiva analítica:

Voz ativa: “A equipe de investigação conferia os registros todas as manhãs.”

Proposta: “Os registros foram conferidos pela equipe de investigação todas as manhãs.”

À luz da norma-padrão, assinale a alternativa que avalia corretamente a proposta.',
  'Assinale a alternativa que preenche corretamente a lacuna, empregando a voz passiva sintética e o pretérito perfeito do indicativo.

“__________ novos equipamentos de comunicação para a unidade na semana passada.”',
  'Considere as frases a seguir.

1. Divulgaram-se novas instruções aos integrantes da unidade.
2. Confia-se em profissionais experientes durante operações delicadas.

Analise as seguintes afirmativas:

I. Na frase 1, o pronome “se” é apassivador, e “novas instruções” funciona como sujeito paciente.
II. Na frase 1, o plural de “divulgaram-se” decorre da concordância com “novas instruções”.
III. Na frase 2, o pronome “se” é índice de indeterminação do sujeito, e o verbo deve permanecer na terceira pessoa do singular.
IV. Na frase 2, o plural de “profissionais experientes” exigiria a forma “confiam-se”.

Quais afirmativas estão corretas?'
)
order by q.id;
