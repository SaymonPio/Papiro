-- IMPORTACAO LOTE08_LEGISLACAO_ESPECIFICA — 23 questoes autorais para 7
-- unidades de Legislacao Especifica (curso Brigada Militar RS):
-- Responsabilidade Civil do Estado (+7), Garantias e Remedios
-- Constitucionais (+2), Defesa do Estado e das Instituicoes Democraticas
-- (+4), Sujeitos/Sancoes/Processo de Improbidade (+3), Atos de
-- Improbidade Administrativa (+1), Lei Maria da Penha/Rede de Justica
-- (+4), Atos Administrativos (+2).
--
-- Human sign-off explicito, revisao final unica (mandato "PAPIRO — LOTE 08 —
-- HUMAN REVIEW FINAL — FREEZE 23 + IMPORTACAO + POS-CHECK + COMMIT/PUSH").
-- 23 SELECTED. 7 APPROVED_RESERVE (RC-08, GAR-01, GAR-03, DEF-03, DEF-04,
-- IAT-01, AA-04) — NAO importadas nesta fase, preservadas apenas no
-- review/frozen-support. 1 HUMAN_CURRENT_LAW_BLOCK (ISSP-03 — legitimidade
-- exclusiva do MP no art. 17, superada pelas ADIs 7042/7043 do STF) — NAO
-- importada. 1 HUMAN_EDIT_REQUIRED (AA-01) — NAO importada nesta fase.
--
-- Padrao identico aos lotes precedentes (multi-unidade, igual ao Lote07):
-- staging de questoes/explicacoes/alternativas, insercao por INSERT direto
-- em questoes/alternativas (nunca em questao_unidades_pedagogicas), vinculo
-- exclusivamente via classificar_questao_unidade_admin (RPC que sincroniza
-- curso_questoes automaticamente).
--
-- NAO altera nenhuma questao existente nas 7 unidades.
-- NAO altera unidades/conteudos/materias/aulas. NAO cria migration/schema.
--
-- Texto final persistido em
-- outputs/curadoria-autoral/review/LOTE08-LEGISLACAO-HUMAN-REVIEW.md,
-- congelado em outputs/curadoria-autoral/review/LOTE08-FROZEN-23.json
-- (corpus_hash 8c987d2a7f2017817bdc64ea7e26bbe5b4de1bc36b267f2efdd8f51b6d2f1939).
--
-- ROLLBACK-TESTADO em importar_lote08_legislacao_especifica_teste_rollback.sql
-- REVERSAO REAL disponivel em reverter_lote08_legislacao_especifica.sql

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

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
(1, 61, $D1$media$D1$, $FONTE1$PAPIRO — LOTE08_LEGISLACAO_ESPECIFICA — RC-01$FONTE1$, $ENUN1$Durante patrulhamento realizado por agentes de um Município, uma viatura oficial colide com o veículo de um particular e lhe causa danos materiais. Comprovados o dano e o nexo causal entre a atuação dos agentes e o prejuízo, assinale a alternativa correta quanto à responsabilidade civil do Município.$ENUN1$),
(2, 61, $D2$media$D2$, $FONTE2$PAPIRO — LOTE08_LEGISLACAO_ESPECIFICA — RC-02$FONTE2$, $ENUN2$Uma empresa privada concessionária de transporte coletivo urbano presta serviço público por delegação e, durante a execução do serviço, um de seus empregados causa dano a um passageiro. À luz da Constituição Federal, assinale a alternativa correta.$ENUN2$),
(3, 61, $D3$media$D3$, $FONTE3$PAPIRO — LOTE08_LEGISLACAO_ESPECIFICA — RC-03$FONTE3$, $ENUN3$Um servidor público, em seu dia de folga, utiliza seu automóvel particular para tratar exclusivamente de assunto familiar. Durante o trajeto, colide com o veículo de um particular e causa-lhe prejuízo. Não há qualquer vínculo entre o deslocamento e as atribuições do cargo. À luz da responsabilidade civil prevista na Constituição Federal, assinale a alternativa correta.$ENUN3$),
(4, 61, $D4$media$D4$, $FONTE4$PAPIRO — LOTE08_LEGISLACAO_ESPECIFICA — RC-04$FONTE4$, $ENUN4$Para os fins da regra de responsabilidade civil objetiva prevista no art. 37, § 6º, da Constituição Federal, a expressão “terceiros” refere-se, corretamente, a$ENUN4$),
(5, 61, $D5$media$D5$, $FONTE5$PAPIRO — LOTE08_LEGISLACAO_ESPECIFICA — RC-05$FONTE5$, $ENUN5$Uma pessoa jurídica de direito público foi condenada a indenizar terceiro por dano causado por agente público no exercício de suas funções. À luz da responsabilidade civil do Estado, assinale a alternativa correta acerca da possibilidade de a pessoa jurídica buscar o ressarcimento do valor pago.$ENUN5$),
(6, 61, $D6$media$D6$, $FONTE6$PAPIRO — LOTE08_LEGISLACAO_ESPECIFICA — RC-06$FONTE6$, $ENUN6$Em razão de ato praticado por seu agente nessa qualidade, uma pessoa jurídica prestadora de serviço público indenizou um particular pelos danos sofridos. Posteriormente, pretende ajuizar ação regressiva contra o agente. Para o êxito dessa ação regressiva, é indispensável que a pessoa jurídica comprove$ENUN6$),
(7, 61, $D7$media$D7$, $FONTE7$PAPIRO — LOTE08_LEGISLACAO_ESPECIFICA — RC-07$FONTE7$, $ENUN7$À luz da responsabilidade civil do Estado prevista na Constituição Federal, analise as afirmativas a seguir.

I. As pessoas jurídicas de direito público e as pessoas jurídicas de direito privado prestadoras de serviços públicos respondem pelos danos que seus agentes, nessa qualidade, causem a terceiros.

II. Para a vítima obter indenização da pessoa jurídica, é indispensável comprovar o dolo ou a culpa do agente causador do dano.

III. Assegurado o direito de regresso contra o agente responsável, este depende da demonstração de dolo ou culpa do agente.

Quais estão corretas?$ENUN7$),
(8, 47, $D8$media$D8$, $FONTE8$PAPIRO — LOTE08_LEGISLACAO_ESPECIFICA — GAR-02$FONTE8$, $ENUN8$No âmbito de um processo administrativo, um servidor é acusado de infração funcional. Considerando o texto constitucional, assinale a alternativa correta acerca das garantias que lhe devem ser asseguradas.$ENUN8$),
(9, 47, $D9$media$D9$, $FONTE9$PAPIRO — LOTE08_LEGISLACAO_ESPECIFICA — GAR-04$FONTE9$, $ENUN9$A Constituição assegura determinada prerrogativa relacionada à cidadania, mas o seu exercício depende de lei regulamentadora que ainda não foi editada. Em razão dessa omissão normativa, torna-se inviável exercer a prerrogativa constitucional. Assinale o remédio constitucional cabível.$ENUN9$),
(10, 48, $D10$media$D10$, $FONTE10$PAPIRO — LOTE08_LEGISLACAO_ESPECIFICA — DEF-01$FONTE10$, $ENUN10$Nos termos da Constituição Federal, assinale a alternativa correta acerca do Conselho de Defesa Nacional.$ENUN10$),
(11, 48, $D11$media$D11$, $FONTE11$PAPIRO — LOTE08_LEGISLACAO_ESPECIFICA — DEF-02$FONTE11$, $ENUN11$Em relação ao estado de sítio, analise as assertivas a seguir, conforme a Constituição Federal.

I. O Presidente da República deve ouvir o Conselho da República e o Conselho de Defesa Nacional antes de solicitar autorização ao Congresso Nacional para decretar o estado de sítio.

II. A comoção grave de repercussão nacional e a ineficácia de medida tomada durante o estado de defesa constituem hipóteses para a solicitação de autorização para decretar o estado de sítio.

III. A declaração de guerra ou a resposta a agressão armada estrangeira também constituem hipóteses para a solicitação de autorização para decretar o estado de sítio.

Quais estão corretas?$ENUN11$),
(12, 48, $D12$media$D12$, $FONTE12$PAPIRO — LOTE08_LEGISLACAO_ESPECIFICA — DEF-05$FONTE12$, $ENUN12$Nos termos da redação atual do caput do art. 144 da Constituição Federal, assinale a alternativa que apresenta corretamente todos os órgãos responsáveis pelo exercício da segurança pública.$ENUN12$),
(13, 48, $D13$media$D13$, $FONTE13$PAPIRO — LOTE08_LEGISLACAO_ESPECIFICA — DEF-06$FONTE13$, $ENUN13$Em relação às restrições constitucionais aplicáveis aos militares, assinale a alternativa correta.$ENUN13$),
(14, 55, $D14$media$D14$, $FONTE14$PAPIRO — LOTE08_LEGISLACAO_ESPECIFICA — ISSP-01$FONTE14$, $ENUN14$Para os efeitos da Lei nº 8.429/1992, assinale a alternativa que apresenta corretamente quem é considerado agente público.$ENUN14$),
(15, 55, $D15$media$D15$, $FONTE15$PAPIRO — LOTE08_LEGISLACAO_ESPECIFICA — ISSP-02$FONTE15$, $ENUN15$Nos termos da Lei nº 8.429/1992, na hipótese de ato de improbidade administrativa que importe enriquecimento ilícito, assinale a alternativa que indica corretamente as sanções aplicáveis.$ENUN15$),
(16, 55, $D16$media$D16$, $FONTE16$PAPIRO — LOTE08_LEGISLACAO_ESPECIFICA — ISSP-04$FONTE16$, $ENUN16$Nos termos da redação atual da Lei nº 8.429/1992, a ação para aplicação das sanções nela previstas prescreve em$ENUN16$),
(17, 55, $D17$media$D17$, $FONTE17$PAPIRO — LOTE08_LEGISLACAO_ESPECIFICA — IAT-02$FONTE17$, $ENUN17$Sobre o elemento subjetivo dos atos de improbidade administrativa na redação vigente da Lei nº 8.429/1992, assinale a alternativa correta.$ENUN17$),
(18, 53, $D18$media$D18$, $FONTE18$PAPIRO — LOTE08_LEGISLACAO_ESPECIFICA — LMP-01$FONTE18$, $ENUN18$Nos termos da Lei Maria da Penha, em uma causa cível decorrente de violência doméstica e familiar contra a mulher na qual o Ministério Público não figure como parte, sua atuação deverá ocorrer$ENUN18$),
(19, 53, $D19$media$D19$, $FONTE19$PAPIRO — LOTE08_LEGISLACAO_ESPECIFICA — LMP-02$FONTE19$, $ENUN19$Quando necessário, constitui atribuição do Ministério Público prevista na Lei nº 11.340/2006:$ENUN19$),
(20, 53, $D20$media$D20$, $FONTE20$PAPIRO — LOTE08_LEGISLACAO_ESPECIFICA — LMP-03$FONTE20$, $ENUN20$Nos termos da Lei Maria da Penha, assinale a alternativa correta acerca da assistência por advogado à mulher em situação de violência doméstica e familiar.$ENUN20$),
(21, 53, $D21$media$D21$, $FONTE21$PAPIRO — LOTE08_LEGISLACAO_ESPECIFICA — LMP-04$FONTE21$, $ENUN21$Considerando a garantia de assistência à mulher em situação de violência doméstica e familiar, prevista na Lei nº 11.340/2006, assinale a alternativa correta.$ENUN21$),
(22, 54, $D22$media$D22$, $FONTE22$PAPIRO — LOTE08_LEGISLACAO_ESPECIFICA — AA-02$FONTE22$, $ENUN22$Considerando a autotutela administrativa, a autoridade competente concluiu que um ato válido deixou de ser conveniente para o interesse público. O ato já havia gerado direito adquirido a determinado administrado. Assinale a alternativa correta.$ENUN22$),
(23, 54, $D23$media$D23$, $FONTE23$PAPIRO — LOTE08_LEGISLACAO_ESPECIFICA — AA-03$FONTE23$, $ENUN23$Uma autoridade administrativa verificou que determinado ato apresenta defeito sanável. Antes de decidir sobre sua manutenção, constatou que a convalidação não acarretará lesão ao interesse público nem prejuízo a terceiros. Nos termos da Lei nº 9.784/1999, é correto afirmar que o ato$ENUN23$);

create temporary table _lote_explicacoes (ordem int primary key, explicacao text) on commit drop;

insert into _lote_explicacoes (ordem, explicacao) values
(1, $EXPL1$A pessoa jurídica de direito público responde objetivamente pelos danos que seus agentes, nessa qualidade, causem a terceiros. Assim, demonstrados o dano e o nexo causal com a atuação estatal, a vítima não precisa provar dolo ou culpa dos agentes para buscar a responsabilização do Município. As alternativas B e C incorretamente exigem elemento subjetivo do agente; a D exclui indevidamente a responsabilidade da pessoa jurídica; e a E cria requisito de autorização expressa não previsto na norma.

FUNDAMENTO: Constituição Federal de 1988, art. 37, §6º. — As pessoas jurídicas de direito público respondem pelos danos que seus agentes, nessa qualidade, causem a terceiros, segundo a responsabilidade objetiva.$EXPL1$),
(2, $EXPL2$A Constituição Federal estende expressamente a responsabilidade objetiva às pessoas jurídicas de direito privado prestadoras de serviços públicos. Portanto, a concessionária pode responder pelos danos causados a terceiros por seus agentes na prestação do serviço, bastando a demonstração do dano e do nexo causal, sem necessidade de provar dolo ou culpa do empregado. A alternativa A ignora a previsão constitucional aplicável às prestadoras privadas; C exige prova indevida de dolo; D restringe a regra aos entes públicos; e E limita sem fundamento a responsabilidade a atos de sócios administradores.

FUNDAMENTO: Constituição Federal de 1988, art. 37, §6º. — A responsabilidade objetiva também incide sobre as pessoas jurídicas de direito privado prestadoras de serviços públicos pelos danos causados por seus agentes, nessa qualidade, a terceiros.$EXPL2$),
(3, $EXPL3$A responsabilidade objetiva prevista no art. 37, § 6º, da Constituição alcança danos causados por agentes públicos nessa qualidade, isto é, no exercício da função pública ou em razão dela. No caso, o servidor estava em atividade estritamente particular, sem conexão com suas atribuições, de modo que o dano não se enquadra nessa responsabilização constitucional. As alternativas A e B erram ao transformar o simples vínculo funcional em critério suficiente. A alternativa D introduz exigência de dolo que não decorre da regra de responsabilidade objetiva perante a vítima. A alternativa E cria requisito inexistente, pois uniforme ou crachá não definem, por si sós, a atuação nessa qualidade.

FUNDAMENTO: Constituição Federal de 1988, art. 37, §6º. — O dispositivo atribui responsabilidade objetiva às pessoas jurídicas indicadas pelos danos que seus agentes, nessa qualidade, causarem a terceiros.$EXPL3$),
(4, $EXPL4$No art. 37, § 6º, “terceiro” é o lesado que não integra a relação entre a pessoa jurídica responsável e seu agente causador do dano. É essa vítima externa à relação Estado-agente que recebe a proteção da regra constitucional. A alternativa A confunde terceiro com o próprio agente público. A alternativa C restringe indevidamente o conceito aos usuários cadastrados. A alternativa D exclui sem fundamento as pessoas jurídicas, que também podem sofrer danos. A alternativa E limita o dispositivo aos contratantes da Administração, restrição inexistente no texto constitucional.

FUNDAMENTO: Constituição Federal de 1988, art. 37, §6º. — O dispositivo prevê a responsabilidade das pessoas jurídicas indicadas pelos danos que seus agentes, nessa qualidade, causarem a terceiros.$EXPL4$),
(5, $EXPL5$A Constituição assegura à pessoa jurídica o direito de regresso contra o agente responsável pelo dano, mas condiciona seu exercício à demonstração de dolo ou culpa do agente. A responsabilidade objetiva da pessoa jurídica perante o terceiro não elimina esse direito. A alternativa A é incorreta porque nega o regresso; a C restringe indevidamente o regresso ao dolo, excluindo a culpa; a D exige condição não prevista; e a E ignora a necessidade de apuração de dolo ou culpa.

FUNDAMENTO: Constituição Federal de 1988, art. 37, §6º. — As pessoas jurídicas respondem pelos danos causados por seus agentes a terceiros e é assegurado o direito de regresso contra o agente responsável nos casos de dolo ou culpa.$EXPL5$),
(6, $EXPL6$Na relação entre o terceiro lesado e a pessoa jurídica, a responsabilidade é objetiva: em regra, discutem-se dano e nexo causal, sem necessidade de provar dolo ou culpa do agente. Já no regresso contra o agente, o regime é subjetivo, sendo indispensável demonstrar dolo ou culpa. Por isso, a alternativa A descreve indevidamente requisito suficiente para a responsabilização da pessoa jurídica perante o terceiro, mas não para o regresso. A B aponta circunstância que não fundamenta o regresso; a D estabelece exigência inexistente; e a E exclui erroneamente a culpa como fundamento possível.

FUNDAMENTO: Constituição Federal de 1988, art. 37, §6º. — O direito de regresso da pessoa jurídica contra o agente responsável é assegurado nos casos de dolo ou culpa, diferentemente da responsabilidade objetiva da pessoa jurídica perante o terceiro lesado.$EXPL6$),
(7, $EXPL7$Estão corretas I e III. O art. 37, §6º, da Constituição alcança tanto as pessoas jurídicas de direito público quanto as pessoas jurídicas de direito privado prestadoras de serviços públicos, desde que o dano tenha sido causado por agente nessa qualidade. Na relação entre a vítima e a pessoa jurídica, a responsabilidade é objetiva: exigem-se dano e nexo causal, sem necessidade de prova de dolo ou culpa do agente. Por isso, a afirmativa II está incorreta. Já a ação regressiva contra o agente somente é cabível se houver dolo ou culpa, tornando correta a afirmativa III.

FUNDAMENTO: Constituição Federal de 1988, art. 37, §6º. — O dispositivo estabelece a responsabilidade objetiva das pessoas jurídicas de direito público e das pessoas jurídicas de direito privado prestadoras de serviços públicos pelos danos causados por seus agentes, nessa qualidade, assegurando o direito de regresso contra o agente nos casos de dolo ou culpa.$EXPL7$),
(8, $EXPL8$A Constituição assegura expressamente o contraditório e a ampla defesa tanto aos litigantes em processo judicial quanto em processo administrativo, além dos acusados em geral, abrangendo os meios e recursos inerentes à defesa. Por isso, a alternativa C reproduz corretamente a garantia constitucional. As alternativas A e E excluem indevidamente o processo administrativo; B condiciona a garantia a uma consequência penal inexistente no texto constitucional; e D admite afastamento incompatível com a garantia assegurada pela Constituição.

FUNDAMENTO: Constituição Federal de 1988, art. 5º, LV. — Aos litigantes, em processo judicial ou administrativo, e aos acusados em geral são assegurados o contraditório e a ampla defesa, com os meios e recursos a ela inerentes.$EXPL8$),
(9, $EXPL9$O mandado de injunção é cabível quando a ausência de norma regulamentadora impede o exercício de direitos e liberdades constitucionais ou de prerrogativas inerentes à nacionalidade, à soberania e à cidadania. Logo, a alternativa D está correta. O habeas corpus tutela a liberdade de locomoção, razão pela qual as alternativas A e E estão incorretas. O habeas data possui finalidade ligada a informações pessoais em registros ou bancos de dados. Já o mandado de segurança não se destina, nos termos constitucionais, a suprir a falta de norma regulamentadora que inviabilize o exercício do direito.

FUNDAMENTO: Constituição Federal de 1988, art. 5º, LXXI — Conceder-se-á mandado de injunção sempre que a falta de norma regulamentadora torne inviável o exercício dos direitos e liberdades constitucionais e das prerrogativas inerentes à nacionalidade, à soberania e à cidadania.$EXPL9$),
(10, $EXPL10$O Conselho de Defesa Nacional é órgão de consulta do Presidente da República nos assuntos relacionados à soberania nacional e à defesa do Estado democrático. Entre suas atribuições, está a de opinar sobre a decretação do estado de defesa, do estado de sítio e da intervenção federal. Não lhe cabe deliberar ou decretar tais medidas. A autorização para o estado de sítio é atribuída ao Congresso Nacional, e o Conselho não atua exclusivamente em matéria de segurança pública.

FUNDAMENTO: Constituição Federal de 1988, art. 91, caput e §1º, II. — Define o Conselho de Defesa Nacional como órgão de consulta do Presidente da República e prevê sua competência para opinar sobre a decretação do estado de defesa, do estado de sítio e da intervenção federal.$EXPL10$),
(11, $EXPL11$As três assertivas estão corretas. Para decretar o estado de sítio, o Presidente da República, depois de ouvir o Conselho da República e o Conselho de Defesa Nacional, deve solicitar autorização ao Congresso Nacional. As hipóteses constitucionais abrangem: comoção grave de repercussão nacional; ineficácia de medida tomada durante o estado de defesa; declaração de guerra; ou resposta a agressão armada estrangeira. A exigência de autorização prévia do Congresso diferencia o procedimento do estado de sítio daquele previsto para o estado de defesa.

FUNDAMENTO: Constituição Federal de 1988, art. 137, caput e incisos I e II. — Estabelece a necessidade de o Presidente da República ouvir os Conselhos da República e de Defesa Nacional e solicitar autorização ao Congresso Nacional para decretar o estado de sítio, além de enumerar as respectivas hipóteses de cabimento.$EXPL11$),
(12, $EXPL12$A alternativa B reproduz integralmente a relação constitucional atual dos órgãos que exercem a segurança pública. O caput do art. 144 inclui, além das polícias federal, rodoviária federal, ferroviária federal, civis, militares e dos corpos de bombeiros militares, as polícias penais federal, estaduais e distrital. A alternativa A omite a polícia ferroviária federal e separa indevidamente as polícias militares dos corpos de bombeiros militares. A C acrescenta as guardas municipais à lista do caput. A D omite a polícia penal distrital. A E prevê polícias penais municipais, categoria não contemplada no dispositivo.

FUNDAMENTO: Constituição Federal de 1988, art. 144, caput. — O dispositivo enumera os órgãos por meio dos quais a segurança pública é exercida, incluindo as polícias penais federal, estaduais e distrital, inseridas pela EC nº 104/2019.$EXPL12$),
(13, $EXPL13$A alternativa A está correta. A Constituição proíbe ao militar a sindicalização e a greve. Também determina que o militar, enquanto em serviço ativo, não pode estar filiado a partidos políticos. A B erra ao admitir sindicalização e ao tornar absoluta a vedação de filiação partidária, que possui como marco constitucional o serviço ativo. As alternativas C, D e E contrariam diretamente as proibições de sindicalização e greve ou permitem indevidamente a filiação partidária durante o serviço ativo.

FUNDAMENTO: Constituição Federal de 1988, art. 142, § 3º, IV e V. — O inciso IV proíbe ao militar a sindicalização e a greve; o inciso V veda a filiação a partidos políticos enquanto o militar estiver em serviço ativo.$EXPL13$),
(14, $EXPL14$A alternativa B reproduz o conceito legal amplo de agente público para fins de improbidade administrativa. Ele abrange expressamente agente político e servidor público, bem como qualquer pessoa que exerça mandato, cargo, emprego ou função nas entidades alcançadas pela Lei, inclusive de forma transitória ou sem remuneração, desde que o exercício decorra das formas de investidura ou vínculo indicadas. As alternativas A, C e E restringem indevidamente o conceito a vínculos permanentes, remunerados ou efetivos. A alternativa D também é incorreta porque o dispositivo não limita o conceito ao particular contratado nem exige remuneração estatal.

FUNDAMENTO: Lei nº 8.429/1992, art. 2º. — Define agente público, para os efeitos da Lei, incluindo expressamente agente político, servidor público e aquele que exerça, ainda que transitoriamente ou sem remuneração, mandato, cargo, emprego ou função nas entidades referidas no art. 1º.$EXPL14$),
(15, $EXPL15$A alternativa A apresenta as sanções previstas para o ato de improbidade que importe enriquecimento ilícito: perda dos bens ou valores acrescidos ilicitamente, perda da função pública, suspensão dos direitos políticos até 14 anos, multa civil equivalente ao valor do acréscimo patrimonial e proibição de contratar com o poder público ou receber benefícios ou incentivos fiscais por prazo não superior a 14 anos. A alternativa B utiliza prazos e critério de multa diversos dos vigentes. A C omite a perda dos bens ou valores ilicitamente acrescidos e adota parâmetro inadequado para a multa. A D indica os limites de 12 anos e vincula a multa ao dano ao erário, o que não corresponde ao inciso I. A E prevê multa em dobro e exclui indevidamente a vedação relativa a benefícios ou incentivos fiscais.

FUNDAMENTO: Lei nº 8.429/1992, art. 12, caput e inciso I. — Estabelece, para os atos previstos no art. 9º, as sanções de perda dos bens ou valores acrescidos ilicitamente, perda da função pública, suspensão dos direitos políticos até 14 anos, multa civil equivalente ao valor do acréscimo patrimonial e proibição de contratar com o poder público ou receber benefícios ou incentivos fiscais por prazo não superior a 14 anos.$EXPL15$),
(16, $EXPL16$A alternativa C está correta. O art. 23, caput, da Lei nº 8.429/1992 estabelece prazo prescricional de 8 anos, contado da ocorrência do fato. Quando se tratar de infração permanente, o prazo começa no dia em que cessar a permanência. As alternativas A e B incorrem na utilização do antigo prazo de 5 anos, que não corresponde ao regime vigente. A alternativa D adota como termo inicial a ciência pelo Ministério Público, hipótese não prevista no caput. A alternativa E indica prazo e marco inicial diversos daqueles fixados pela Lei.

FUNDAMENTO: Lei nº 8.429/1992, art. 23, caput. — A ação para aplicação das sanções previstas na Lei prescreve em 8 anos, contados da ocorrência do fato ou, nas infrações permanentes, do dia em que cessou a permanência.$EXPL16$),
(17, $EXPL17$A alternativa D está correta. Na redação vigente, os atos descritos nos arts. 9º, 10 e 11 exigem conduta dolosa. A reforma promovida pela Lei nº 14.230/2021 eliminou a antiga previsão de improbidade culposa no art. 10; portanto, não basta negligência, imprudência ou imperícia. Além disso, o dolo legalmente definido não se confunde com a mera voluntariedade no exercício da função: exige vontade livre e consciente de alcançar o resultado ilícito tipificado nos arts. 9º, 10 e 11. Assim, A, B e C mantêm indevidamente a culpa como modalidade atual, e E adota conceito insuficiente de dolo.

FUNDAMENTO: Lei nº 8.429/1992, art. 1º, § 2º, combinado com o art. 10, caput. — Dolo é a vontade livre e consciente de alcançar o resultado ilícito tipificado nos arts. 9º, 10 e 11, não bastando a voluntariedade do agente. O art. 10 vigente exige ação ou omissão dolosa para a configuração de lesão ao erário.$EXPL17$),
(18, $EXPL18$A alternativa B está correta: o Ministério Público intervirá, quando não for parte, nas causas cíveis e criminais decorrentes da violência doméstica e familiar contra a mulher. A intervenção não depende de representação da ofendida (A), não se restringe ao cumprimento de sentença (C), não corresponde à assistência da defesa (D) e tampouco fica condicionada a requisição judicial (E).

FUNDAMENTO: Lei nº 11.340/2006, art. 25. — O dispositivo determina a intervenção do Ministério Público, quando não for parte, nas causas cíveis e criminais decorrentes de violência doméstica e familiar contra a mulher.$EXPL18$),
(19, $EXPL19$A alternativa A reúne as três atribuições previstas: requisitar força policial e serviços públicos de saúde, educação, assistência social e segurança; fiscalizar os estabelecimentos de atendimento à mulher e adotar, de imediato, as medidas cabíveis; e cadastrar os casos de violência doméstica e familiar contra a mulher. As demais alternativas inserem competências não previstas, como determinar prisão preventiva ou instaurar inquérito, ou restringem indevidamente as atribuições legais.

FUNDAMENTO: Lei nº 11.340/2006, art. 26, incisos I, II e III. — Compete ao Ministério Público, quando necessário, requisitar força policial e serviços públicos indicados; fiscalizar estabelecimentos de atendimento à mulher e adotar medidas cabíveis; e cadastrar os casos de violência doméstica e familiar contra a mulher.$EXPL19$),
(20, $EXPL20$A alternativa B está correta, pois a Lei nº 11.340/2006 determina que a mulher em situação de violência doméstica e familiar esteja acompanhada de advogado em todos os atos processuais, tanto cíveis quanto criminais, ressalvada a previsão do art. 19. A alternativa A restringe indevidamente a regra aos atos criminais; C cria condicionamento relacionado à Defensoria Pública que não consta do dispositivo; D transforma a obrigatoriedade ampla em faculdade ou exigência limitada; e E fixa marco processual inexistente na norma.

FUNDAMENTO: Lei nº 11.340/2006, art. 27 — Estabelece que, em todos os atos processuais, cíveis e criminais, a mulher em situação de violência doméstica e familiar deverá estar acompanhada de advogado, ressalvado o previsto no art. 19 da Lei.$EXPL20$),
(21, $EXPL21$A alternativa C reproduz corretamente a garantia legal: toda mulher em situação de violência doméstica e familiar tem acesso aos serviços de Defensoria Pública ou de Assistência Judiciária Gratuita, nos termos da lei, tanto em sede policial quanto judicial, com atendimento específico e humanizado. As alternativas A, B, D e E restringem indevidamente esse direito, seja limitando-o à fase judicial ou criminal, seja impondo condição não prevista no art. 28, seja excluindo a sede policial.

FUNDAMENTO: Lei nº 11.340/2006, art. 28 — Garante à mulher em situação de violência doméstica e familiar acesso aos serviços de Defensoria Pública ou de Assistência Judiciária Gratuita, nos termos da lei, em sede policial e judicial, mediante atendimento específico e humanizado.$EXPL21$),
(22, $EXPL22$A revogação incide sobre ato válido que, por razões de conveniência ou oportunidade, deixa de atender ao interesse público. Trata-se de providência própria da Administração Pública, que deve respeitar os direitos adquiridos. A alternativa A é incorreta porque o Poder Judiciário não revoga atos administrativos com base no mérito administrativo. A alternativa B confunde inconveniência com ilegalidade, hipótese própria de anulação. A alternativa D desconsidera o limite expresso dos direitos adquiridos. A alternativa E também troca os fundamentos dos institutos, pois vício de legalidade enseja anulação, não revogação.

FUNDAMENTO: Lei nº 9.784/1999, art. 53. — A Administração pode revogar seus atos por motivo de conveniência ou oportunidade, respeitados os direitos adquiridos.$EXPL22$),
(23, $EXPL23$A convalidação exige, cumulativamente, que o ato apresente defeito sanável, que a medida não acarrete lesão ao interesse público e que não cause prejuízo a terceiros. Estando presentes esses pressupostos, a própria Administração poderá convalidar o ato. As alternativas C e D erram por tratarem como dispensável uma das duas condições cumulativas. A alternativa A ignora a possibilidade legal de convalidação de vícios sanáveis, e a E erra porque a convalidação pode ser realizada pela própria Administração.

FUNDAMENTO: Lei nº 9.784, de 29 de janeiro de 1999, art. 55. — O art. 55 autoriza a própria Administração a convalidar atos com defeitos sanáveis, desde que a decisão não acarrete lesão ao interesse público nem prejuízo a terceiros.$EXPL23$);

create temporary table _lote_alternativas (ordem int, letra_ordem int, texto text, correta boolean) on commit drop;

insert into _lote_alternativas (ordem, letra_ordem, texto, correta) values
(1, 1, $ALT1_1$O Município responde objetivamente pelos danos, não sendo necessária, para a indenização da vítima, a prova de dolo ou culpa dos agentes.$ALT1_1$, true),
(1, 2, $ALT1_2$O Município somente responde se a vítima comprovar que os agentes agiram com dolo.$ALT1_2$, false),
(1, 3, $ALT1_3$O Município somente responde se a vítima demonstrar culpa grave dos agentes envolvidos.$ALT1_3$, false),
(1, 4, $ALT1_4$A responsabilidade é exclusivamente pessoal dos agentes, pois foram eles que conduziram a viatura.$ALT1_4$, false),
(1, 5, $ALT1_5$O Município responde apenas se tiver autorizado expressamente a conduta que ocasionou o dano.$ALT1_5$, false),
(2, 1, $ALT2_1$A empresa não se submete à responsabilidade objetiva, pois possui personalidade jurídica de direito privado.$ALT2_1$, false),
(2, 2, $ALT2_2$A empresa responde objetivamente pelo dano causado por seu agente na prestação do serviço público, desde que demonstrados o dano e o nexo causal.$ALT2_2$, true),
(2, 3, $ALT2_3$A empresa somente poderá ser responsabilizada se o passageiro provar dolo do empregado.$ALT2_3$, false),
(2, 4, $ALT2_4$A responsabilidade objetiva alcança somente a União, os Estados, o Distrito Federal e os Municípios.$ALT2_4$, false),
(2, 5, $ALT2_5$A empresa responde apenas quando o dano decorrer de ato praticado diretamente por seu sócio administrador.$ALT2_5$, false),
(3, 1, $ALT3_1$A pessoa jurídica de direito público responde objetivamente, pois todo dano causado por servidor público é imputável ao Estado.$ALT3_1$, false),
(3, 2, $ALT3_2$A pessoa jurídica de direito público responde objetivamente, pois basta que o autor do dano possua vínculo funcional com o Estado.$ALT3_2$, false),
(3, 3, $ALT3_3$A responsabilidade objetiva estatal prevista no dispositivo não incide, pois o dano não foi causado pelo agente nessa qualidade.$ALT3_3$, true),
(3, 4, $ALT3_4$A responsabilidade estatal depende da demonstração de dolo do servidor, ainda que o fato tenha ocorrido em sua vida privada.$ALT3_4$, false),
(3, 5, $ALT3_5$A pessoa jurídica de direito público somente responde se o particular provar que o servidor estava identificado por uniforme ou crachá.$ALT3_5$, false),
(4, 1, $ALT4_1$qualquer agente público que sofra dano durante o desempenho de suas atribuições, independentemente da relação jurídica envolvida.$ALT4_1$, false),
(4, 2, $ALT4_2$a pessoa estranha à relação entre a pessoa jurídica responsável e o agente causador do dano, que sofre os prejuízos decorrentes da atuação estatal.$ALT4_2$, true),
(4, 3, $ALT4_3$somente o usuário formalmente cadastrado em serviço público prestado pela pessoa jurídica responsável.$ALT4_3$, false),
(4, 4, $ALT4_4$exclusivamente a pessoa física, não abrangendo pessoas jurídicas que sofram dano.$ALT4_4$, false),
(4, 5, $ALT4_5$apenas quem tenha firmado contrato administrativo diretamente com o Poder Público.$ALT4_5$, false),
(5, 1, $ALT5_1$A pessoa jurídica não possui direito de regresso contra o agente, pois a responsabilidade estatal perante o terceiro é objetiva.$ALT5_1$, false),
(5, 2, $ALT5_2$A pessoa jurídica possui direito de regresso contra o agente responsável, desde que demonstrados dolo ou culpa deste.$ALT5_2$, true),
(5, 3, $ALT5_3$A pessoa jurídica somente possui direito de regresso se o terceiro lesado comprovar que o agente agiu com dolo.$ALT5_3$, false),
(5, 4, $ALT5_4$O direito de regresso depende de prévia condenação criminal definitiva do agente responsável.$ALT5_4$, false),
(5, 5, $ALT5_5$A pessoa jurídica possui direito de regresso automático contra o agente, ainda que ele tenha atuado sem dolo ou culpa.$ALT5_5$, false),
(6, 1, $ALT6_1$apenas a ocorrência do dano e o nexo causal entre a atuação do agente e o prejuízo.$ALT6_1$, false),
(6, 2, $ALT6_2$a culpa exclusiva da vítima pelo evento danoso.$ALT6_2$, false),
(6, 3, $ALT6_3$o dolo ou a culpa do agente responsável.$ALT6_3$, true),
(6, 4, $ALT6_4$a existência de condenação penal transitada em julgado contra o agente.$ALT6_4$, false),
(6, 5, $ALT6_5$a intenção específica do agente de causar dano, sendo insuficiente a culpa.$ALT6_5$, false),
(7, 1, $ALT7_1$Apenas I.$ALT7_1$, false),
(7, 2, $ALT7_2$Apenas II e III.$ALT7_2$, false),
(7, 3, $ALT7_3$Apenas I e III.$ALT7_3$, true),
(7, 4, $ALT7_4$Apenas I e II.$ALT7_4$, false),
(7, 5, $ALT7_5$I, II e III.$ALT7_5$, false),
(8, 1, $ALT8_1$O contraditório e a ampla defesa são garantias exclusivas dos processos judiciais.$ALT8_1$, false),
(8, 2, $ALT8_2$O acusado somente terá direito de defesa se o processo administrativo puder resultar em sanção penal.$ALT8_2$, false),
(8, 3, $ALT8_3$Aos litigantes em processo judicial ou administrativo e aos acusados em geral são assegurados o contraditório e a ampla defesa, com os meios e recursos a ela inerentes.$ALT8_3$, true),
(8, 4, $ALT8_4$Em processo administrativo, a Administração pode afastar a ampla defesa por decisão fundamentada da autoridade competente.$ALT8_4$, false),
(8, 5, $ALT8_5$O contraditório é assegurado aos litigantes, mas a ampla defesa é garantia restrita ao processo judicial.$ALT8_5$, false),
(9, 1, $ALT9_1$Habeas corpus, pois há restrição decorrente de ato estatal.$ALT9_1$, false),
(9, 2, $ALT9_2$Habeas data, pois se busca tornar efetivo um direito previsto na Constituição.$ALT9_2$, false),
(9, 3, $ALT9_3$Mandado de segurança, pois todo direito constitucional sem regulamentação configura direito líquido e certo.$ALT9_3$, false),
(9, 4, $ALT9_4$Mandado de injunção, pois a falta de norma regulamentadora inviabiliza o exercício de prerrogativa inerente à cidadania.$ALT9_4$, true),
(9, 5, $ALT9_5$Mandado de injunção, desde que haja ameaça à liberdade de locomoção.$ALT9_5$, false),
(10, 1, $ALT10_1$É órgão de consulta do Congresso Nacional e delibera sobre a decretação do estado de defesa.$ALT10_1$, false),
(10, 2, $ALT10_2$É órgão consultivo do Presidente da República nos assuntos relacionados à soberania nacional e à defesa do Estado democrático, competindo-lhe opinar sobre a decretação do estado de defesa, do estado de sítio e da intervenção federal.$ALT10_2$, true),
(10, 3, $ALT10_3$É órgão consultivo do Presidente da República, incumbido de autorizar previamente a decretação do estado de sítio.$ALT10_3$, false),
(10, 4, $ALT10_4$É órgão de consulta do Presidente da República exclusivamente em matérias relativas à segurança pública.$ALT10_4$, false),
(10, 5, $ALT10_5$É órgão consultivo do Presidente da República, ao qual compete decretar a intervenção federal e o estado de defesa.$ALT10_5$, false),
(11, 1, $ALT11_1$Apenas I.$ALT11_1$, false),
(11, 2, $ALT11_2$Apenas II.$ALT11_2$, false),
(11, 3, $ALT11_3$Apenas I e III.$ALT11_3$, false),
(11, 4, $ALT11_4$Apenas II e III.$ALT11_4$, false),
(11, 5, $ALT11_5$I, II e III.$ALT11_5$, true),
(12, 1, $ALT12_1$Polícia federal; polícia rodoviária federal; polícias civis; polícias militares; corpos de bombeiros militares; e polícias penais federal, estaduais e distrital.$ALT12_1$, false),
(12, 2, $ALT12_2$Polícia federal; polícia rodoviária federal; polícia ferroviária federal; polícias civis; polícias militares e corpos de bombeiros militares; e polícias penais federal, estaduais e distrital.$ALT12_2$, true),
(12, 3, $ALT12_3$Polícia federal; polícia rodoviária federal; polícia ferroviária federal; guardas municipais; polícias civis; polícias militares e corpos de bombeiros militares; e polícias penais.$ALT12_3$, false),
(12, 4, $ALT12_4$Polícia federal; polícia rodoviária federal; polícia ferroviária federal; polícias civis; polícias militares e corpos de bombeiros militares; e polícias penais federais e estaduais.$ALT12_4$, false),
(12, 5, $ALT12_5$Polícia federal; polícia rodoviária federal; polícia ferroviária federal; polícias civis; polícias militares; corpos de bombeiros militares; e polícias penais federal, estaduais e municipais.$ALT12_5$, false),
(13, 1, $ALT13_1$Ao militar são proibidas a sindicalização e a greve, bem como, enquanto em serviço ativo, a filiação a partidos políticos.$ALT13_1$, true),
(13, 2, $ALT13_2$Ao militar é assegurado o direito de sindicalização, mas é proibido o exercício do direito de greve e a filiação a partidos políticos em qualquer situação.$ALT13_2$, false),
(13, 3, $ALT13_3$Ao militar são proibidas a sindicalização e a greve, mas a filiação a partidos políticos é permitida enquanto estiver em serviço ativo.$ALT13_3$, false),
(13, 4, $ALT13_4$Ao militar é proibida somente a greve; a sindicalização e a filiação partidária são permitidas, desde que não haja exercício de cargo de direção partidária.$ALT13_4$, false),
(13, 5, $ALT13_5$Ao militar são proibidas a sindicalização e a greve apenas durante operações militares, sendo livre a filiação partidária no serviço ativo.$ALT13_5$, false),
(14, 1, $ALT14_1$Somente o servidor público ocupante de cargo efetivo nas entidades abrangidas pela Lei.$ALT14_1$, false),
(14, 2, $ALT14_2$O agente político, o servidor público e todo aquele que exerça, ainda que transitoriamente ou sem remuneração, por eleição, nomeação, designação, contratação ou outra forma de investidura ou vínculo, mandato, cargo, emprego ou função nas entidades referidas na Lei.$ALT14_2$, true),
(14, 3, $ALT14_3$Exclusivamente quem exerça cargo ou emprego público mediante remuneração e vínculo permanente com a Administração.$ALT14_3$, false),
(14, 4, $ALT14_4$Apenas o particular contratado pela Administração para executar serviço público, desde que receba remuneração estatal.$ALT14_4$, false),
(14, 5, $ALT14_5$Somente o agente político e o servidor público investidos em cargo de provimento efetivo.$ALT14_5$, false),
(15, 1, $ALT15_1$Perda dos bens ou valores acrescidos ilicitamente ao patrimônio, perda da função pública, suspensão dos direitos políticos até 14 anos, multa civil equivalente ao valor do acréscimo patrimonial e proibição de contratar com o poder público ou de receber benefícios ou incentivos fiscais pelo prazo não superior a 14 anos.$ALT15_1$, true),
(15, 2, $ALT15_2$Perda dos bens ou valores acrescidos ilicitamente ao patrimônio, perda da função pública, suspensão dos direitos políticos por até 8 anos, multa civil de até três vezes o valor do acréscimo patrimonial e proibição de contratar com o poder público por até 10 anos.$ALT15_2$, false),
(15, 3, $ALT15_3$Perda da função pública, suspensão dos direitos políticos até 14 anos e multa civil de até duas vezes o valor do dano, sem perda dos bens ou valores acrescidos ilicitamente.$ALT15_3$, false),
(15, 4, $ALT15_4$Perda dos bens ou valores acrescidos ilicitamente ao patrimônio, suspensão dos direitos políticos até 12 anos, multa civil equivalente ao dano ao erário e proibição de contratar com o poder público por até 12 anos.$ALT15_4$, false),
(15, 5, $ALT15_5$Ressarcimento integral do dano, perda da função pública, suspensão dos direitos políticos até 14 anos e multa civil equivalente ao dobro do acréscimo patrimonial, vedada a proibição de receber incentivos fiscais.$ALT15_5$, false),
(16, 1, $ALT16_1$5 anos, contados do término do mandato, do cargo em comissão ou da função de confiança.$ALT16_1$, false),
(16, 2, $ALT16_2$5 anos, contados da ocorrência do fato, independentemente de a infração ser permanente.$ALT16_2$, false),
(16, 3, $ALT16_3$8 anos, contados da ocorrência do fato ou, tratando-se de infração permanente, do dia em que cessou a permanência.$ALT16_3$, true),
(16, 4, $ALT16_4$8 anos, contados exclusivamente da ciência do fato pelo Ministério Público.$ALT16_4$, false),
(16, 5, $ALT16_5$10 anos, contados da ocorrência do fato ou da prestação de contas final pelo agente público.$ALT16_5$, false),
(17, 1, $ALT17_1$Os atos de enriquecimento ilícito, de lesão ao erário e de violação a princípios administrativos admitem dolo ou culpa, conforme a gravidade do resultado.$ALT17_1$, false),
(17, 2, $ALT17_2$A modalidade culposa permanece aplicável exclusivamente aos atos que causam lesão ao erário, previstos no art. 10.$ALT17_2$, false),
(17, 3, $ALT17_3$Somente os atos de enriquecimento ilícito exigem dolo; os demais podem decorrer de negligência, imprudência ou imperícia.$ALT17_3$, false),
(17, 4, $ALT17_4$Os atos previstos nos arts. 9º, 10 e 11 exigem conduta dolosa, não subsistindo modalidade culposa, inclusive para a lesão ao erário.$ALT17_4$, true),
(17, 5, $ALT17_5$A mera voluntariedade do agente no exercício de suas atribuições é suficiente para caracterizar o dolo exigido pela lei.$ALT17_5$, false),
(18, 1, $ALT18_1$somente se houver representação expressa da ofendida.$ALT18_1$, false),
(18, 2, $ALT18_2$como interveniente, assim como ocorre nas causas criminais decorrentes dessa violência.$ALT18_2$, true),
(18, 3, $ALT18_3$apenas na fase de cumprimento de sentença, para fiscalizar medidas protetivas.$ALT18_3$, false),
(18, 4, $ALT18_4$como assistente da defesa, desde que a parte requerida não possua advogado.$ALT18_4$, false),
(18, 5, $ALT18_5$somente se o juiz requisitar formalmente sua manifestação.$ALT18_5$, false),
(19, 1, $ALT19_1$requisitar força policial e serviços públicos de saúde, educação, assistência social e segurança; fiscalizar estabelecimentos de atendimento à mulher; e cadastrar os casos de violência doméstica e familiar contra a mulher.$ALT19_1$, true),
(19, 2, $ALT19_2$determinar a prisão preventiva do agressor, fiscalizar delegacias especializadas e elaborar cadastro nacional de medidas protetivas.$ALT19_2$, false),
(19, 3, $ALT19_3$requisitar exclusivamente serviços de saúde, aplicar sanções administrativas a estabelecimentos e cadastrar somente os casos com sentença condenatória.$ALT19_3$, false),
(19, 4, $ALT19_4$requisitar força policial apenas por ordem judicial, administrar os estabelecimentos de atendimento e cadastrar os agressores reincidentes.$ALT19_4$, false),
(19, 5, $ALT19_5$instaurar inquérito policial, fiscalizar somente abrigos públicos e cadastrar as vítimas mediante autorização judicial.$ALT19_5$, false),
(20, 1, $ALT20_1$O acompanhamento por advogado é obrigatório somente nos atos processuais de natureza criminal.$ALT20_1$, false),
(20, 2, $ALT20_2$A mulher deverá estar acompanhada de advogado em todos os atos processuais, cíveis e criminais, ressalvada a hipótese prevista na própria Lei.$ALT20_2$, true),
(20, 3, $ALT20_3$O acompanhamento por advogado é exigido apenas quando a mulher não estiver assistida pela Defensoria Pública.$ALT20_3$, false),
(20, 4, $ALT20_4$A presença de advogado é facultativa nos atos cíveis e obrigatória exclusivamente na audiência de instrução criminal.$ALT20_4$, false),
(20, 5, $ALT20_5$A mulher somente deverá constituir advogado após o oferecimento da denúncia pelo Ministério Público.$ALT20_5$, false),
(21, 1, $ALT21_1$O acesso à Defensoria Pública é assegurado apenas em processos judiciais criminais, conforme avaliação da autoridade policial.$ALT21_1$, false),
(21, 2, $ALT21_2$A assistência judiciária gratuita é cabível somente após o ajuizamento de ação judicial pela vítima.$ALT21_2$, false),
(21, 3, $ALT21_3$É garantido o acesso aos serviços de Defensoria Pública ou de Assistência Judiciária Gratuita, nos termos da lei, em sede policial e judicial, mediante atendimento específico e humanizado.$ALT21_3$, true),
(21, 4, $ALT21_4$O atendimento pela Defensoria Pública depende de representação criminal formalmente apresentada pela mulher.$ALT21_4$, false),
(21, 5, $ALT21_5$O atendimento específico é previsto somente para mulheres que comprovem incapacidade econômica, não se aplicando à sede policial.$ALT21_5$, false),
(22, 1, $ALT22_1$O Poder Judiciário poderá revogar o ato, pois a inconveniência administrativa autoriza sua atuação substitutiva.$ALT22_1$, false),
(22, 2, $ALT22_2$A Administração deverá anular o ato, pois a inconveniência caracteriza vício de legalidade.$ALT22_2$, false),
(22, 3, $ALT22_3$A Administração poderá revogar o ato por motivo de conveniência ou oportunidade, devendo respeitar os direitos adquiridos.$ALT22_3$, true),
(22, 4, $ALT22_4$A Administração poderá revogar o ato e desconstituir livremente os direitos adquiridos, em razão da supremacia do interesse público.$ALT22_4$, false),
(22, 5, $ALT22_5$A revogação somente é cabível quando o ato estiver eivado de vício de legalidade.$ALT22_5$, false),
(23, 1, $ALT23_1$deverá ser anulado, pois todo defeito em ato administrativo impede sua preservação.$ALT23_1$, false),
(23, 2, $ALT23_2$poderá ser convalidado pela própria Administração, diante da natureza sanável do defeito e da ausência de lesão ao interesse público e de prejuízo a terceiros.$ALT23_2$, true),
(23, 3, $ALT23_3$poderá ser convalidado desde que não haja lesão ao interesse público, sendo irrelevante eventual prejuízo a terceiros.$ALT23_3$, false),
(23, 4, $ALT23_4$poderá ser convalidado desde que não haja prejuízo a terceiros, ainda que a medida cause lesão ao interesse público.$ALT23_4$, false),
(23, 5, $ALT23_5$somente poderá ser convalidado por decisão judicial, ainda que o defeito seja sanável.$ALT23_5$, false);

create temporary table _unidades_ordem (ordem_min int, ordem_max int, unidade_pedagogica_id uuid) on commit drop;
insert into _unidades_ordem (ordem_min, ordem_max, unidade_pedagogica_id) values
(1, 7, 'd6f03d69-8943-4867-a2af-e37482d4ca99'::uuid),
(8, 9, 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63'::uuid),
(10, 13, 'ecdb1d62-ef44-4407-b899-85911402bc90'::uuid),
(14, 16, '9d4c7a1e-3f68-4b52-8a91-6c0d5e2f7b84'::uuid),
(17, 17, '60927a85-1b4a-480a-b8da-8eb318520692'::uuid),
(18, 21, '53dc06a1-cd16-4004-a76b-8201d95a91c4'::uuid),
(22, 23, '85323ce5-772b-4bf1-bc32-a79e2316158b'::uuid);

-- ================= PRECONDICOES =================
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
    if not coalesce(v_unidade_ok, false) then raise exception 'PRECOND: unidade % nao esta ativa/relevante conforme esperado', r.unidade_pedagogica_id; end if;

    select count(distinct q.id) into v_uteis
    from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
    where qup.unidade_pedagogica_id = r.unidade_pedagogica_id and q.ativa=true
    and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);

    select count(distinct q.id) filter (where coalesce(lower(q.banca),'') not like '%papiro%'),
           count(distinct q.id) filter (where coalesce(lower(q.banca),'') like '%papiro%')
      into v_real, v_autoral
    from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
    where qup.unidade_pedagogica_id = r.unidade_pedagogica_id and q.ativa=true
    and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);

    select count(*) into v_gap
    from (
      select distinct q.id from public.questoes q
      join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
      where qup.unidade_pedagogica_id = r.unidade_pedagogica_id and q.ativa
      and not exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id)
    ) g;
    if v_gap <> 0 then raise exception 'PRECOND: gap curso_questoes na unidade %=% esperado 0', r.unidade_pedagogica_id, v_gap; end if;

    raise notice 'PRECOND unidade % OK: uteis=% real=% autoral=% gap=%', r.unidade_pedagogica_id, v_uteis, v_real, v_autoral, v_gap;
  end loop;

  select count(*) into v_dup
  from public.questoes q
  where q.ativa = true
  and lower(q.enunciado) in (
  lower($DUP1$Durante patrulhamento realizado por agentes de um Município, uma viatura oficial colide com o veículo de um particular e lhe causa danos materiais. Comprovados o dano e o nexo causal entre a atuação dos agentes e o prejuízo, assinale a alternativa correta quanto à responsabilidade civil do Município.$DUP1$),
  lower($DUP2$Uma empresa privada concessionária de transporte coletivo urbano presta serviço público por delegação e, durante a execução do serviço, um de seus empregados causa dano a um passageiro. À luz da Constituição Federal, assinale a alternativa correta.$DUP2$),
  lower($DUP3$Um servidor público, em seu dia de folga, utiliza seu automóvel particular para tratar exclusivamente de assunto familiar. Durante o trajeto, colide com o veículo de um particular e causa-lhe prejuízo. Não há qualquer vínculo entre o deslocamento e as atribuições do cargo. À luz da responsabilidade civil prevista na Constituição Federal, assinale a alternativa correta.$DUP3$),
  lower($DUP4$Para os fins da regra de responsabilidade civil objetiva prevista no art. 37, § 6º, da Constituição Federal, a expressão “terceiros” refere-se, corretamente, a$DUP4$),
  lower($DUP5$Uma pessoa jurídica de direito público foi condenada a indenizar terceiro por dano causado por agente público no exercício de suas funções. À luz da responsabilidade civil do Estado, assinale a alternativa correta acerca da possibilidade de a pessoa jurídica buscar o ressarcimento do valor pago.$DUP5$),
  lower($DUP6$Em razão de ato praticado por seu agente nessa qualidade, uma pessoa jurídica prestadora de serviço público indenizou um particular pelos danos sofridos. Posteriormente, pretende ajuizar ação regressiva contra o agente. Para o êxito dessa ação regressiva, é indispensável que a pessoa jurídica comprove$DUP6$),
  lower($DUP7$À luz da responsabilidade civil do Estado prevista na Constituição Federal, analise as afirmativas a seguir.

I. As pessoas jurídicas de direito público e as pessoas jurídicas de direito privado prestadoras de serviços públicos respondem pelos danos que seus agentes, nessa qualidade, causem a terceiros.

II. Para a vítima obter indenização da pessoa jurídica, é indispensável comprovar o dolo ou a culpa do agente causador do dano.

III. Assegurado o direito de regresso contra o agente responsável, este depende da demonstração de dolo ou culpa do agente.

Quais estão corretas?$DUP7$),
  lower($DUP8$No âmbito de um processo administrativo, um servidor é acusado de infração funcional. Considerando o texto constitucional, assinale a alternativa correta acerca das garantias que lhe devem ser asseguradas.$DUP8$),
  lower($DUP9$A Constituição assegura determinada prerrogativa relacionada à cidadania, mas o seu exercício depende de lei regulamentadora que ainda não foi editada. Em razão dessa omissão normativa, torna-se inviável exercer a prerrogativa constitucional. Assinale o remédio constitucional cabível.$DUP9$),
  lower($DUP10$Nos termos da Constituição Federal, assinale a alternativa correta acerca do Conselho de Defesa Nacional.$DUP10$),
  lower($DUP11$Em relação ao estado de sítio, analise as assertivas a seguir, conforme a Constituição Federal.

I. O Presidente da República deve ouvir o Conselho da República e o Conselho de Defesa Nacional antes de solicitar autorização ao Congresso Nacional para decretar o estado de sítio.

II. A comoção grave de repercussão nacional e a ineficácia de medida tomada durante o estado de defesa constituem hipóteses para a solicitação de autorização para decretar o estado de sítio.

III. A declaração de guerra ou a resposta a agressão armada estrangeira também constituem hipóteses para a solicitação de autorização para decretar o estado de sítio.

Quais estão corretas?$DUP11$),
  lower($DUP12$Nos termos da redação atual do caput do art. 144 da Constituição Federal, assinale a alternativa que apresenta corretamente todos os órgãos responsáveis pelo exercício da segurança pública.$DUP12$),
  lower($DUP13$Em relação às restrições constitucionais aplicáveis aos militares, assinale a alternativa correta.$DUP13$),
  lower($DUP14$Para os efeitos da Lei nº 8.429/1992, assinale a alternativa que apresenta corretamente quem é considerado agente público.$DUP14$),
  lower($DUP15$Nos termos da Lei nº 8.429/1992, na hipótese de ato de improbidade administrativa que importe enriquecimento ilícito, assinale a alternativa que indica corretamente as sanções aplicáveis.$DUP15$),
  lower($DUP16$Nos termos da redação atual da Lei nº 8.429/1992, a ação para aplicação das sanções nela previstas prescreve em$DUP16$),
  lower($DUP17$Sobre o elemento subjetivo dos atos de improbidade administrativa na redação vigente da Lei nº 8.429/1992, assinale a alternativa correta.$DUP17$),
  lower($DUP18$Nos termos da Lei Maria da Penha, em uma causa cível decorrente de violência doméstica e familiar contra a mulher na qual o Ministério Público não figure como parte, sua atuação deverá ocorrer$DUP18$),
  lower($DUP19$Quando necessário, constitui atribuição do Ministério Público prevista na Lei nº 11.340/2006:$DUP19$),
  lower($DUP20$Nos termos da Lei Maria da Penha, assinale a alternativa correta acerca da assistência por advogado à mulher em situação de violência doméstica e familiar.$DUP20$),
  lower($DUP21$Considerando a garantia de assistência à mulher em situação de violência doméstica e familiar, prevista na Lei nº 11.340/2006, assinale a alternativa correta.$DUP21$),
  lower($DUP22$Considerando a autotutela administrativa, a autoridade competente concluiu que um ato válido deixou de ser conveniente para o interesse público. O ato já havia gerado direito adquirido a determinado administrado. Assinale a alternativa correta.$DUP22$),
  lower($DUP23$Uma autoridade administrativa verificou que determinado ato apresenta defeito sanável. Antes de decidir sobre sua manutenção, constatou que a convalidação não acarretará lesão ao interesse público nem prejuízo a terceiros. Nos termos da Lei nº 9.784/1999, é correto afirmar que o ato$DUP23$)
  );
  if v_dup <> 0 then raise exception 'PRECOND: % questao(oes) com enunciado identico ja existem — possivel reexecucao/duplicidade', v_dup; end if;

  raise notice 'PRECONDICOES GLOBAIS OK: 0 duplicidade de enunciado entre as 23';
end $$;

-- ================= INSERT das 23 questoes =================
create temporary table _mapa_ids (ordem int primary key, questao_id bigint, unidade_pedagogica_id uuid) on commit drop;

do $$
declare
  r record;
  v_novo_id bigint;
  v_uid uuid;
begin
  for r in select ordem, dificuldade, fonte, enunciado from _lote_questoes order by ordem loop
    select unidade_pedagogica_id into v_uid from _unidades_ordem where r.ordem between ordem_min and ordem_max;

    insert into public.questoes (materia_id, assunto_id, banca, concurso, ano, dificuldade, enunciado, explicacao, fonte, ativa, usuario_id)
    select cc.curso_materia_id_materia, cc.assunto_id, 'Papiro', 'PAPIRO - Curadoria LOTE08_LEGISLACAO_ESPECIFICA - BM RS', 2026, r.dificuldade, r.enunciado,
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
  end loop;
end $$;

-- ================= VINCULO via RPC sancionada =================
do $$
declare
  r record;
begin
  for r in select questao_id, unidade_pedagogica_id from _mapa_ids order by ordem loop
    perform public.classificar_questao_unidade_admin(r.questao_id, r.unidade_pedagogica_id);
  end loop;
end $$;

-- ================= POSCONDICOES =================
do $$
declare
  v_questoes int; v_alternativas int; v_vinculos int; v_curso_questoes int;
  v_snap record;
  v_uteis int;
  v_vinc_ok int; v_cq_ok int;
  v_gabaritos text;
begin
  select * into v_snap from _snapshot_antes;

  select count(*) into v_questoes from public.questoes;
  select count(*) into v_alternativas from public.alternativas;
  select count(*) into v_vinculos from public.questao_unidades_pedagogicas;
  select count(*) into v_curso_questoes from public.curso_questoes;

  if v_questoes - v_snap.total_questoes <> 23 then raise exception 'POSCOND: questoes criadas=% esperado 23', v_questoes - v_snap.total_questoes; end if;
  if v_alternativas - v_snap.total_alternativas <> 115 then raise exception 'POSCOND: alternativas criadas=% esperado 115', v_alternativas - v_snap.total_alternativas; end if;
  if v_vinculos - v_snap.total_vinculos <> 23 then raise exception 'POSCOND: vinculos criados=% esperado 23', v_vinculos - v_snap.total_vinculos; end if;
  if v_curso_questoes - v_snap.total_curso_questoes <> 23 then raise exception 'POSCOND: curso_questoes criadas=% esperado 23', v_curso_questoes - v_snap.total_curso_questoes; end if;

  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='d6f03d69-8943-4867-a2af-e37482d4ca99' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  if v_uteis <> 10 then raise exception 'POSCOND: uteis unidade Responsabilidade Civil do Estado=% esperado 10', v_uteis; end if;

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=m.questao_id and correta=true), '' order by m.ordem)
    into v_gabaritos from _mapa_ids m where m.unidade_pedagogica_id = 'd6f03d69-8943-4867-a2af-e37482d4ca99';
  if v_gabaritos <> 'ABCBBCC' then raise exception 'POSCOND: gabaritos unidade Responsabilidade Civil do Estado=% esperado ABCBBCC', v_gabaritos; end if;


  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  if v_uteis <> 10 then raise exception 'POSCOND: uteis unidade Garantias e Remedios Constitucionais=% esperado 10', v_uteis; end if;

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=m.questao_id and correta=true), '' order by m.ordem)
    into v_gabaritos from _mapa_ids m where m.unidade_pedagogica_id = 'f3a6d9c2-8b41-4e0a-9c7d-2b5e8f1a4d63';
  if v_gabaritos <> 'CD' then raise exception 'POSCOND: gabaritos unidade Garantias e Remedios Constitucionais=% esperado CD', v_gabaritos; end if;


  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='ecdb1d62-ef44-4407-b899-85911402bc90' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  if v_uteis <> 10 then raise exception 'POSCOND: uteis unidade Defesa do Estado e das Instituicoes Democraticas=% esperado 10', v_uteis; end if;

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=m.questao_id and correta=true), '' order by m.ordem)
    into v_gabaritos from _mapa_ids m where m.unidade_pedagogica_id = 'ecdb1d62-ef44-4407-b899-85911402bc90';
  if v_gabaritos <> 'BEBA' then raise exception 'POSCOND: gabaritos unidade Defesa do Estado e das Instituicoes Democraticas=% esperado BEBA', v_gabaritos; end if;


  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='9d4c7a1e-3f68-4b52-8a91-6c0d5e2f7b84' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  if v_uteis <> 10 then raise exception 'POSCOND: uteis unidade Sujeitos/Sancoes/Processo de Improbidade=% esperado 10', v_uteis; end if;

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=m.questao_id and correta=true), '' order by m.ordem)
    into v_gabaritos from _mapa_ids m where m.unidade_pedagogica_id = '9d4c7a1e-3f68-4b52-8a91-6c0d5e2f7b84';
  if v_gabaritos <> 'BAC' then raise exception 'POSCOND: gabaritos unidade Sujeitos/Sancoes/Processo de Improbidade=% esperado BAC', v_gabaritos; end if;


  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='60927a85-1b4a-480a-b8da-8eb318520692' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  if v_uteis <> 10 then raise exception 'POSCOND: uteis unidade Atos de Improbidade Administrativa=% esperado 10', v_uteis; end if;

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=m.questao_id and correta=true), '' order by m.ordem)
    into v_gabaritos from _mapa_ids m where m.unidade_pedagogica_id = '60927a85-1b4a-480a-b8da-8eb318520692';
  if v_gabaritos <> 'D' then raise exception 'POSCOND: gabaritos unidade Atos de Improbidade Administrativa=% esperado D', v_gabaritos; end if;


  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='53dc06a1-cd16-4004-a76b-8201d95a91c4' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  if v_uteis <> 10 then raise exception 'POSCOND: uteis unidade Lei Maria da Penha / Rede de Justica=% esperado 10', v_uteis; end if;

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=m.questao_id and correta=true), '' order by m.ordem)
    into v_gabaritos from _mapa_ids m where m.unidade_pedagogica_id = '53dc06a1-cd16-4004-a76b-8201d95a91c4';
  if v_gabaritos <> 'BABC' then raise exception 'POSCOND: gabaritos unidade Lei Maria da Penha / Rede de Justica=% esperado BABC', v_gabaritos; end if;


  select count(distinct q.id) into v_uteis
  from public.questoes q join public.questao_unidades_pedagogicas qup on qup.questao_id=q.id
  where qup.unidade_pedagogica_id='85323ce5-772b-4bf1-bc32-a79e2316158b' and q.ativa=true
  and exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=q.id);
  if v_uteis <> 10 then raise exception 'POSCOND: uteis unidade Atos Administrativos=% esperado 10', v_uteis; end if;

  select string_agg((select chr(64+ordem) from public.alternativas where questao_id=m.questao_id and correta=true), '' order by m.ordem)
    into v_gabaritos from _mapa_ids m where m.unidade_pedagogica_id = '85323ce5-772b-4bf1-bc32-a79e2316158b';
  if v_gabaritos <> 'CB' then raise exception 'POSCOND: gabaritos unidade Atos Administrativos=% esperado CB', v_gabaritos; end if;


  select count(*) into v_vinc_ok from _mapa_ids m
    where exists(select 1 from public.questao_unidades_pedagogicas qup where qup.questao_id=m.questao_id and qup.unidade_pedagogica_id=m.unidade_pedagogica_id)
    and not exists(select 1 from public.questao_unidades_pedagogicas qup2 where qup2.questao_id=m.questao_id and qup2.unidade_pedagogica_id <> m.unidade_pedagogica_id);
  if v_vinc_ok <> 23 then raise exception 'POSCOND: %/23 vinculos corretos (unidade unica) confirmados', v_vinc_ok; end if;

  select count(*) into v_cq_ok from _mapa_ids m
    where exists(select 1 from public.curso_questoes cq where cq.curso_id='7543be16-4c5b-4cb6-8724-8fbdfb96f2d4' and cq.questao_id=m.questao_id);
  if v_cq_ok <> 23 then raise exception 'POSCOND: %/23 curso_questoes novas confirmadas', v_cq_ok; end if;

  raise notice 'POSCONDICOES OK: +23 questoes, +115 alternativas, +23 vinculos, +23 curso_questoes; 7 unidades com gabaritos e contagens confirmadas';
end $$;

commit;
