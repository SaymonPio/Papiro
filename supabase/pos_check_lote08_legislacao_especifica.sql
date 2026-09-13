-- POS-CHECK — importacao LOTE08_LEGISLACAO_ESPECIFICA.
--
-- READ-ONLY. Confirma, independentemente do apply, o estado das 23
-- questoes autorais nas 7 unidades. Nao corrige nada.

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
  $PC1$Durante patrulhamento realizado por agentes de um Município, uma viatura oficial colide com o veículo de um particular e lhe causa danos materiais. Comprovados o dano e o nexo causal entre a atuação dos agentes e o prejuízo, assinale a alternativa correta quanto à responsabilidade civil do Município.$PC1$,
  $PC2$Uma empresa privada concessionária de transporte coletivo urbano presta serviço público por delegação e, durante a execução do serviço, um de seus empregados causa dano a um passageiro. À luz da Constituição Federal, assinale a alternativa correta.$PC2$,
  $PC3$Um servidor público, em seu dia de folga, utiliza seu automóvel particular para tratar exclusivamente de assunto familiar. Durante o trajeto, colide com o veículo de um particular e causa-lhe prejuízo. Não há qualquer vínculo entre o deslocamento e as atribuições do cargo. À luz da responsabilidade civil prevista na Constituição Federal, assinale a alternativa correta.$PC3$,
  $PC4$Para os fins da regra de responsabilidade civil objetiva prevista no art. 37, § 6º, da Constituição Federal, a expressão “terceiros” refere-se, corretamente, a$PC4$,
  $PC5$Uma pessoa jurídica de direito público foi condenada a indenizar terceiro por dano causado por agente público no exercício de suas funções. À luz da responsabilidade civil do Estado, assinale a alternativa correta acerca da possibilidade de a pessoa jurídica buscar o ressarcimento do valor pago.$PC5$,
  $PC6$Em razão de ato praticado por seu agente nessa qualidade, uma pessoa jurídica prestadora de serviço público indenizou um particular pelos danos sofridos. Posteriormente, pretende ajuizar ação regressiva contra o agente. Para o êxito dessa ação regressiva, é indispensável que a pessoa jurídica comprove$PC6$,
  $PC7$À luz da responsabilidade civil do Estado prevista na Constituição Federal, analise as afirmativas a seguir.

I. As pessoas jurídicas de direito público e as pessoas jurídicas de direito privado prestadoras de serviços públicos respondem pelos danos que seus agentes, nessa qualidade, causem a terceiros.

II. Para a vítima obter indenização da pessoa jurídica, é indispensável comprovar o dolo ou a culpa do agente causador do dano.

III. Assegurado o direito de regresso contra o agente responsável, este depende da demonstração de dolo ou culpa do agente.

Quais estão corretas?$PC7$,
  $PC8$No âmbito de um processo administrativo, um servidor é acusado de infração funcional. Considerando o texto constitucional, assinale a alternativa correta acerca das garantias que lhe devem ser asseguradas.$PC8$,
  $PC9$A Constituição assegura determinada prerrogativa relacionada à cidadania, mas o seu exercício depende de lei regulamentadora que ainda não foi editada. Em razão dessa omissão normativa, torna-se inviável exercer a prerrogativa constitucional. Assinale o remédio constitucional cabível.$PC9$,
  $PC10$Nos termos da Constituição Federal, assinale a alternativa correta acerca do Conselho de Defesa Nacional.$PC10$,
  $PC11$Em relação ao estado de sítio, analise as assertivas a seguir, conforme a Constituição Federal.

I. O Presidente da República deve ouvir o Conselho da República e o Conselho de Defesa Nacional antes de solicitar autorização ao Congresso Nacional para decretar o estado de sítio.

II. A comoção grave de repercussão nacional e a ineficácia de medida tomada durante o estado de defesa constituem hipóteses para a solicitação de autorização para decretar o estado de sítio.

III. A declaração de guerra ou a resposta a agressão armada estrangeira também constituem hipóteses para a solicitação de autorização para decretar o estado de sítio.

Quais estão corretas?$PC11$,
  $PC12$Nos termos da redação atual do caput do art. 144 da Constituição Federal, assinale a alternativa que apresenta corretamente todos os órgãos responsáveis pelo exercício da segurança pública.$PC12$,
  $PC13$Em relação às restrições constitucionais aplicáveis aos militares, assinale a alternativa correta.$PC13$,
  $PC14$Para os efeitos da Lei nº 8.429/1992, assinale a alternativa que apresenta corretamente quem é considerado agente público.$PC14$,
  $PC15$Nos termos da Lei nº 8.429/1992, na hipótese de ato de improbidade administrativa que importe enriquecimento ilícito, assinale a alternativa que indica corretamente as sanções aplicáveis.$PC15$,
  $PC16$Nos termos da redação atual da Lei nº 8.429/1992, a ação para aplicação das sanções nela previstas prescreve em$PC16$,
  $PC17$Sobre o elemento subjetivo dos atos de improbidade administrativa na redação vigente da Lei nº 8.429/1992, assinale a alternativa correta.$PC17$,
  $PC18$Nos termos da Lei Maria da Penha, em uma causa cível decorrente de violência doméstica e familiar contra a mulher na qual o Ministério Público não figure como parte, sua atuação deverá ocorrer$PC18$,
  $PC19$Quando necessário, constitui atribuição do Ministério Público prevista na Lei nº 11.340/2006:$PC19$,
  $PC20$Nos termos da Lei Maria da Penha, assinale a alternativa correta acerca da assistência por advogado à mulher em situação de violência doméstica e familiar.$PC20$,
  $PC21$Considerando a garantia de assistência à mulher em situação de violência doméstica e familiar, prevista na Lei nº 11.340/2006, assinale a alternativa correta.$PC21$,
  $PC22$Considerando a autotutela administrativa, a autoridade competente concluiu que um ato válido deixou de ser conveniente para o interesse público. O ato já havia gerado direito adquirido a determinado administrado. Assinale a alternativa correta.$PC22$,
  $PC23$Uma autoridade administrativa verificou que determinado ato apresenta defeito sanável. Antes de decidir sobre sua manutenção, constatou que a convalidação não acarretará lesão ao interesse público nem prejuízo a terceiros. Nos termos da Lei nº 9.784/1999, é correto afirmar que o ato$PC23$
)
order by q.id;
