-- POS-CHECK — importacao LOTE05_PORTUGUES_AUTORAL.
--
-- READ-ONLY. Confirma, independentemente do apply, o estado das 17
-- questoes autorais nas 5 unidades. Nao corrige nada.

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
  $PC1$Em um relatório de ocorrência, lê-se: “Durante o atendimento, o policial sofreu um ferimento no braço”. Quanto à voz verbal, assinale a alternativa correta.$PC1$,
  $PC2$Assinale a alternativa que apresenta a transposição correta para a voz passiva analítica da oração: “A corregedoria analisará os documentos da apuração”.$PC2$,
  $PC3$Em comunicados internos de uma unidade policial, constam as seguintes construções:

I. Divulgaram-se os locais de apresentação dos candidatos.
II. Necessita-se de servidores para o atendimento administrativo.

Considerando a estrutura sintática e o sentido das orações, assinale a alternativa correta.$PC3$,
  $PC4$Assinale a alternativa que completa corretamente a frase abaixo, de acordo com a regência verbal na oração relativa.

"Os pareceres ______ a comissão se baseou para elaborar o relatório final serão encaminhados ao comando."$PC4$,
  $PC5$Assinale a alternativa redigida de acordo com a regência verbal prescrita pela norma-padrão.$PC5$,
  $PC6$Durante o plantão, a equipe registrou cuidadosamente as ocorrências no sistema. O termo que exerce a função de objeto direto do verbo “registrou” é:$PC6$,
  $PC7$A direção homenageou a todos os policiais que se destacaram na operação. Assinale a alternativa que classifica corretamente o termo destacado.$PC7$,
  $PC8$No comunicado interno, lê-se: “A Direção comunicou aos candidatos o novo horário da avaliação”. Assinale a alternativa correta acerca da expressão destacada e de sua substituição pronominal.$PC8$,
  $PC9$Considere a oração de um procedimento administrativo: “Os relatórios de ocorrência foram conferidos pela comissão designada”. Assinale a alternativa que identifica corretamente o agente da passiva e apresenta a conversão adequada da oração para a voz ativa.$PC9$,
  $PC10$Analise as ocorrências destacadas nos períodos a seguir.

I. “O comando necessita de reforço para o patrulhamento.”
II. “A necessidade de reforço para o patrulhamento foi comunicada aos setores responsáveis.”

Quanto à função sintática das expressões destacadas, assinale a alternativa correta.$PC10$,
  $PC11$Em uma comunicação interna, lê-se: “O levantamento preliminar indicou redução das ocorrências; contudo, a análise definitiva dependerá da conferência dos registros.”

Assinale a alternativa correta acerca do emprego de “contudo” no período.$PC11$,
  $PC12$Leia o trecho de um relatório institucional:

“Conquanto o efetivo estivesse reduzido, o atendimento às ocorrências prioritárias foi mantido. Quando a operação foi encerrada, os dados foram encaminhados ao comando.”

Assinale a alternativa que classifica corretamente as relações semânticas introduzidas pelos conectores destacados.$PC12$,
  $PC13$Em um comunicado interno, lê-se: “Conquanto a equipe tenha recebido orientações prévias, o treinamento prático será mantido”.

A conjunção “conquanto” estabelece, entre as ideias do período, uma relação de$PC13$,
  $PC14$No relatório de serviço, registrou-se que “a comunicação entre as equipes foi tão eficiente que reduziu o tempo de resposta às ocorrências”.

No período, a estrutura “tão...que” expressa uma relação de$PC14$,
  $PC15$Leia a frase a seguir.

“A unidade operacional, cujos registros de manutenção foram revisados pela corregedoria, encaminhou o relatório ao comando.”

Quanto ao emprego do pronome relativo “cujos”, assinale a alternativa correta.$PC15$,
  $PC16$Leia o trecho a seguir.

“Durante a preparação para a operação, o comando revisou os mapas de risco, atualizou a escala de serviço e distribuiu lanternas às equipes. Essas providências buscaram ampliar a segurança do patrulhamento noturno.”

No contexto, a expressão “Essas providências” exerce a função de$PC16$,
  $PC17$Leia a frase a seguir.

"O capitão encaminhou à analista o parecer cuja conclusão ele contestou antes da assinatura."

Considerando os mecanismos de coesão referencial, o pronome pessoal "ele" retoma$PC17$
)
order by q.id;
