-- ============================================================================
-- AUDITORIA GLOBAL -- DIREITOS HUMANOS -- LOTE 2 (50 QUESTÕES)
-- Aplicação de 50 explicações pedagógicas (materia_id 11)
-- IDs: 174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,249,250,251,252,253,254,255,256,257,258,259,260,261,262,263,264,265,266,291,292,293,342,343,349,351,352,353,354,623,624,625,648
-- HARNESS TRANSACIONAL -- TERMINA SEMPRE EM ROLLBACK, NADA PERSISTE.
-- ============================================================================
--
-- Gerado automaticamente por scripts/generate-dh-lote2-harness.mjs a partir de
-- scripts/dh-lote2-explicacoes.mjs.
-- ============================================================================

BEGIN;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

-- ----------------------------------------------------------------------------
-- Staging: id -> nova explicacao (fonte: scripts/dh-lote2-explicacoes.mjs).
-- ----------------------------------------------------------------------------
create temporary table _dh2_novas_explicacoes (id bigint primary key, explicacao text) on commit drop;
insert into _dh2_novas_explicacoes (id, explicacao) values
(174, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Sistema Interamericano de Proteção dos Direitos Humanos adota uma estrutura institucional de proteção composta por dois órgãos principais complementares no âmbito da Organização dos Estados Americanos (OEA): a COMISSÃO Interamericana de Direitos Humanos (CIDH, órgão de promoção, consulta e investigação de denúncias) e a CORTE Interamericana de Direitos Humanos (Corte IDH, órgão judicial internacional contencioso e consultivo).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não se restringe a um conselho de segurança militar regional.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não é gerido por um tribunal tributário.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não se limita a um conselho bancário internacional.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não é constituído exclusivamente por assembleias parlamentares internas.

BIZU DE PROVA:
Estrutura do Sistema Interamericano (OEA):
1. Comissão Interamericana de Direitos Humanos (CIDH - Washington);
2. Corte Interamericana de Direitos Humanos (Corte IDH - San José).'),
(175, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A Carta da Organização dos Estados Americanos (Carta de Bogotá de 1948) consagra expressamente entre seus princípios fundamentais que "a solidariedade dos Estados americanos e os altos fins que ela visa requerem a organização política dos mesmos sobre a base do exercício efetivo da democracia representativa" e o respeito intransigente aos direitos fundamentais da pessoa humana.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A Carta não apoia regimes totalitários ou supressão de garantias fundamentais.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A OEA não visa à anexação ou eliminação territorial de Estados.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não determina a submissão das Américas a governos imperiais ou estrangeiros.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não restringe seus fins a acordos monetários privados.

BIZU DE PROVA:
Princípio Democrático da OEA:
A democracia representativa e o respeito aos direitos humanos são condições basilares de convivência entre os Estados americanos.'),
(176, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A Convenção Americana sobre Direitos Humanos (Pacto de San José da Costa Rica, 1969) prevê em seu Artigo 2º o "Dever de Adotar Disposições de Direito Interno", pelo qual os Estados-partes se comprometem a adotar, em conformidade com seus processos constitucionais, as medidas legislativas ou de outra natureza necessárias para tornar efetivos os direitos e liberdades reconhecidos na Convenção.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Os Estados não podem restringir arbitrariamente garantias mínimas convencionais.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A CADH proíbe medidas regressivas que violem o núcleo essencial dos direitos protegidos.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O dever de proteção vincula a ordem interna soberana sem subordinação a regimes de força.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não se trata de mero acordo comercial facultativo.

BIZU DE PROVA:
Dever de Implementação Interna (Art. 2º da CADH):
O Estado deve adequar suas leis internas para conferir eficácia plena aos direitos do Pacto de San José (Princípio do Efeito Útil).'),
(177, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A Convenção de Belém do Pará (1994) consagra em seu Artigo 3º que toda mulher tem o direito a uma vida livre de violência, tanto no âmbito público quanto no privado, incluindo o direito de ser livre de qualquer forma de discriminação e de ser valorizada e educada livre de padrões estereotipados de comportamento.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A proteção não se restringe à esfera patrimonial ou empresarial.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A Convenção protege todas as mulheres, e não apenas servidoras estatais.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A norma veda a violência em qualquer espaço, não se limitando ao domicílio conjugal.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A Convenção é permanente e não depende de declaração de estado de emergência.

BIZU DE PROVA:
Art. 3º da Convenção de Belém do Pará:
"Toda mulher tem direito a uma vida livre de violência, na esfera pública e na esfera privada."'),
(178, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Nos termos da Convenção de Belém do Pará (Art. 7º), os Estados-partes comprometem-se a adotar políticas orientadas a prevenir, punir e erradicar a violência contra a mulher, incluindo a criação de serviços especializados de atendimento, capacitação de agentes públicos e mecanismos judiciais céleres e eficazes de proteção às vítimas.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A Convenção rechaça expressamente a inércia, a impunidade e a tolerância estatal à violência.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não prevê anistia a agressores de mulheres.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A proteção abrange todas as mulheres sem distinção de renda ou nacionalidade.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O tratado impõe deveres de agir concretos ao Estado, e não mera faculdade discricionária.

BIZU DE PROVA:
Deveres do Estado na Convenção de Belém do Pará:
Dever de agir com DEVIDA DILIGÊNCIA para prevenir, investigar e punir a violência contra a mulher.'),
(179, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A Comissão Interamericana de Direitos Humanos (CIDH) atua como órgão consultivo da OEA e possui a atribuição formal de realizar visitas in loco aos países membros para examinar a situação dos direitos humanos, publicar relatórios temáticos e de país e emitir recomendações aos governos para o aprimoramento de suas políticas públicas e instituições.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A CIDH não comanda operações militares estrangeiras.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não exerce funções de auditoria financeira empresarial.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não possui competência para legislar ou alterar constituições nacionais.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não impõe penalidades alfandegárias aos Estados.

BIZU DE PROVA:
Instrumentos de Atuação da CIDH:
- Visitas in loco nos países;
- Relatórios Gerais e Temáticos;
- Recomendações e Medidas Cautelares.'),
(180, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A Corte Interamericana de Direitos Humanos exerce duas funções precípuas: a função CONTENCIOSA (julgar casos concretos de violação da CADH por Estados que tenham reconhecido sua competência) e a função CONSULTIVA (interpretar a Convenção Americana e outros tratados de direitos humanos nas Américas, a pedido de Estados membros da OEA).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A Corte IDH não atua como órgão de fixação de tarifas alfandegárias.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não julga causas exclusivamente trabalhistas internas de empresas privadas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não tem competência de tribunal penal militar.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não atua como órgão bancário de empréstimos.

BIZU DE PROVA:
Competências da Corte IDH:
1. Contenciosa (julga litígios contra Estados e fixa reparações/indenizações);
2. Consultiva (emite Opiniões Consultivas sobre normas de direitos humanos).'),
(181, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Conforme o Artigo 62 da Convenção Americana sobre Direitos Humanos, a jurisdição contenciosa da Corte Interamericana de Direitos Humanos aplica-se aos Estados-partes que tenham declarado expressamente que reconhecem como obrigatória, de pleno direito e sem convenção especial, a competência da Corte para todos os casos relativos à interpretação ou aplicação da Convenção.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A jurisdição contenciosa não é imposta a Estados que não ratificaram o tratado ou não reconheceram a competência da Corte.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não se aplica a conflitos privados de empresas multinacionais sem envolvimento de direitos humanos.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não substitui a competência originária penal interna sobre crimes comuns de particulares.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não depende de autorização prévia de empresas comerciais.

BIZU DE PROVA:
Reconhecimento da Jurisdição da Corte IDH pelo Brasil:
O Brasil reconheceu a jurisdição contenciosa e obrigatória da Corte IDH em dezembro de 1998 (Decreto Legislativo nº 89/1998 e Decreto Presidencial nº 4.463/2002).'),
(182, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
No Sistema Interamericano, o princípio do ESGOTAMENTO DOS RECURSOS DA JURISDIÇÃO INTERNA (Art. 46.1.a da CADH) estabelece que, para que uma petição seja admitida pela Comissão Interamericana, é necessário que tenham sido interpostos e esgotados os recursos ordinários previstos na legislação do Estado, ressalvadas as exceções de inexistência de devido processo, recusa injustificada de justiça ou demora injustificada da decisão.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A regra não exige pagamento de custas financeiras abusivas à OEA.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A petição independe de prévia aprovação do parlamento do país denunciado.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não se exige aval de tribunais estrangeiros não vinculados à OEA.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não é restrita a denúncias formuladas por chefes de Estado.

BIZU DE PROVA:
Requisito de Admissibilidade perante a CIDH (Art. 46 da CADH):
Esgotamento prévio dos recursos internos (princípio da subsidiariedade).
Exceções: se a lei interna não assegura o devido processo, se não permitiram acesso aos recursos ou se houver demora injustificada!'),
(183, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A DUDH/1948 estabelece em seu Artigo 3º que "todo ser humano tem direito à vida, à liberdade e à segurança pessoal", consagrando os direitos civis e liberdades fundamentais mais elementares do ser humano.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A DUDH veda a escravidão, servidão e trabalhos forçados (Art. 4º).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Proíbe expressamente tortura ou tratamentos cruéis e desumanos (Art. 5º).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Veda prisões e detenções arbitrárias (Art. 9º).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Assegura a presunção de inocência e o devido processo legal (Art. 11).

BIZU DE PROVA:
Art. 3º da DUDH:
"Todo indivíduo tem direito à VIDA, à LIBERDADE e à SEGURANÇA PESSOAL."'),
(184, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 4º da Declaração Universal dos Direitos Humanos estabelece de forma categórica e universal: "Ninguém será mantido em escravidão ou servidão; a escravidão e o tráfico de escravos serão proibidos em todas as suas formas."

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A proibição é absoluta e não admite exceções econômicas ou comerciais.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A DUDH veda qualquer modalidade de trabalho escravo ou degradante.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A proteção alcança a totalidade dos seres humanos sem qualquer distinção.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A norma aplica-se tanto no âmbito privado quanto no estatal.

BIZU DE PROVA:
Artigo 4º da DUDH:
Proibição ABSOLUTA da escravidão e do tráfico de escravos em todas as suas formas.'),
(185, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 5º da DUDH prescreve expressamente: "Ninguém será submetido a tortura, nem a tratamento ou castigo cruel, desumano ou degradante." Trata-se de vedação absoluta e universal à violação da integridade física e moral da pessoa humana.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A DUDH proíbe a tortura em qualquer situação, sem exceções de emergência pública.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A proibição é irrestrita e não depende de ordem judicial.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A norma protege cidadãos e custodiados em qualquer circunstância.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não se admite relativização de direitos absolutos contra a tortura.

BIZU DE PROVA:
Artigo 5º da DUDH = Art. 5º, III da CF/88:
"Ninguém será submetido a tortura, nem a tratamento ou castigo cruel, desumano ou degradante."'),
(186, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 9º da DUDH/1948 estabelece: "Ninguém será arbitrariamente preso, detido ou exilado." A garantia contra a privação arbitrária da liberdade assegura que qualquer prisão deve fundar-se estritamente na lei e no devido processo legal.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A DUDH veda expressamente prisões arbitrárias desprovidas de base legal.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O exílio político arbitrário é proibido pelo diploma internacional.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A proteção alcança todos os indivíduos, inclusive opositores políticos e minorias.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A detenção estatal sujeita-se ao controle de legalidade e garantias judiciais.

BIZU DE PROVA:
Artigo 9º da DUDH:
Vedação expressa de prisão, detenção ou exílio ARBITRÁRIOS.'),
(187, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 10 da DUDH estabelece que "todo ser humano tem direito, em plena igualdade, a uma justa e pública audiência por parte de um tribunal independente e imparcial, para decidir de seus direitos e deveres ou do fundamento de qualquer acusação criminal contra ele".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A DUDH rejeita tribunais secretos ou de exceção desprovidos de imparcialidade.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A garantia do juiz natural e imparcial é universal, não restrita a governantes.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O direito a julgamento justo aplica-se a matérias criminais e cíveis.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A publicidade dos atos processuais e a ampla defesa são garantias asseguradas.

BIZU DE PROVA:
Artigo 10 da DUDH:
Direito ao Devido Processo Legal perante Tribunal INDEPENDENTE e IMPARCIAL.'),
(188, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 11, item 1, da DUDH consagra o PRINCÍPIO DA PRESUNÇÃO DE INOCÊNCIA (ou de não culpabilidade): "Todo ser humano acusado de um ato delituoso tem o direito de ser presumido inocente até que a sua culpabilidade tenha sido provada de acordo com a lei, em julgamento público no qual lhe tenham sido asseguradas todas as garantias necessárias à sua defesa."

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A presunção de culpa viola frontalmente o princípio consagrado na DUDH.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A presunção de inocência aplica-se a qualquer acusação penal, independentemente da gravidade.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O ônus da prova de culpabilidade cabe à acusação, e não ao réu provar previamente sua inocência.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A condenação sem processo legítimo é proibida no direito internacional.

BIZU DE PROVA:
Presunção de Inocência (Art. 11.1 DUDH e Art. 5º, LVII CF):
Ninguém será considerado culpado até o trânsito em julgado de sentença penal condenatória.'),
(189, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 11, item 2, da DUDH consagra o PRINCÍPIO DA LEGALIDADE PENAL E ANTERIORIDADE DA LEI: "Ninguém poderá ser culpado por qualquer ação ou omissão que, no momento, não constituíam delito perante o direito nacional ou internacional. Tampouco será imposta pena mais forte do que aquela que, no momento da prática, era aplicável ao ato delituoso."

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A aplicação retroativa de lei penal mais severa é expressamente vedada.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não se admite punição por conduta que não era crime na data do fato.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A legalidade penal é garantia irrenunciável do cidadão contra o arbítrio estatal.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A tipicidade formal e anterior é requisito de validade penal.

BIZU DE PROVA:
Princípio da Anterioridade e Legalidade Penal (Art. 11.2 DUDH e Art. 5º, XXXIX CF):
Não há crime sem lei anterior que o defina, nem pena sem prévia cominação legal (Nullum crimen, nulla poena sine praevia lege).'),
(190, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 12 da DUDH protege a INTIMIDADE, a VIDA PRIVADA, a HONRA e o DOMICÍLIO: "Ninguém será sujeito à interferência na sua vida privada, na sua família, no seu lar ou na sua correspondência, nem a ataque à sua honra e reputação. Todo ser humano tem direito à proteção da lei contra tais interferências ou ataques."

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A DUDH proíbe invasões e devassas arbitrárias na vida privada e no lar dos indivíduos.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A correspondência e as comunicações privadas são resguardadas contra interceptações ilegais.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A honra e a imagem das pessoas gozam de proteção jurídica universal.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A inviolabilidade domiciliar é garantia essencial do indivíduo.

BIZU DE PROVA:
Artigo 12 da DUDH = Art. 5º, X e XI da CF/88:
Proteção da intimidade, vida privada, honra, imagem, correspondência e inviolabilidade do lar.'),
(191, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 13 da DUDH consagra a LIBERDADE DE LOCOMOÇÃO e circulação: "1. Todo ser humano tem direito à liberdade de locomoção e residência dentro das fronteiras de cada Estado. 2. Todo ser humano tem o direito de deixar qualquer país, inclusive o próprio, e a este regressar."

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A DUDH assegura o direito de circular livremente e fixar residência no território do Estado.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O direito de sair do próprio país e a ele regressar é expressamente garantido.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não se admite confinamento geográfico discriminatório.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A liberdade de trânsito é protegida no plano nacional e internacional.

BIZU DE PROVA:
Artigo 13 da DUDH = Art. 5º, XV da CF/88:
Direito de ir, vir, ficar e regressar ao país de origem.'),
(249, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 14 da DUDH/1948 estabelece o DIREITO DE ASILO: "1. Todo ser humano, vítima de perseguição, tem o direito de procurar e de gozar asilo em outros países. 2. Este direito não pode ser invocado em caso de perseguição legitimamente motivada por crimes de direito comum ou por atos contrários aos objetivos e princípios das Nações Unidas."

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O asilo não é concedido a criminosos comuns em fuga da justiça legítima.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A DUDH protege expressamente as vítimas de perseguições políticas e ideológicas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O asilo político é tradicional instituto humanitário do direito internacional e princípio das relações exteriores do Brasil (art. 4º, X, CF).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O direito de asilo pressupõe perseguição injusta ou fundada em motivos de raça, religião ou opinião política.

BIZU DE PROVA:
Direito de Asilo (Art. 14 da DUDH):
- Assegurado a vítimas de perseguição política/ideológica;
- VEDADO a autores de crimes comuns ou atos contrários aos princípios da ONU.'),
(250, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 15 da DUDH consagra o DIREITO À NACIONALIDADE: "1. Todo ser humano tem direito a uma nacionalidade. 2. Ninguém será arbitrariamente privado de sua nacionalidade, nem do direito de mudar de nacionalidade." O direito à nacionalidade é o vínculo jurídico-político que confere a condição de cidadão e o acesso a direitos fundamentais.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A DUDH proíbe a privação arbitrária da nacionalidade de qualquer indivíduo.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O direito de alterar voluntariamente a nacionalidade é assegurado.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A comunidade internacional combate a apatridia (ausência de nacionalidade).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A nacionalidade é prerrogativa de todo ser humano, e não concessão arbitrária.

BIZU DE PROVA:
Artigo 15 da DUDH:
- Direito a uma nacionalidade;
- Vedação da perda arbitrária da nacionalidade;
- Direito de mudar de nacionalidade.'),
(251, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 16 da DUDH consagra o DIREITO AO CASAMENTO E À FAMÍLIA: homens e mulheres de maioridade têm o direito de casar e fundar uma família com livre e pleno consentimento dos nubentes, gozando de iguais direitos quanto ao casamento, durante o casamento e por ocasião de sua dissolução, sendo a família o núcleo natural e fundamental da sociedade com direito à proteção da sociedade e do Estado.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A DUDH veda o casamento forçado ou sem consentimento livre dos cônjuges.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Assegura plena igualdade de direitos entre os cônjuges no matrimônio.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Reconhece a família como núcleo fundamental protegido pelo Estado.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A proteção não discrimina nubentes por raça, nacionalidade ou religião.

BIZU DE PROVA:
Artigo 16 da DUDH:
- Consentimento LIVRE e PLENO dos nubentes;
- IGUALDADE de direitos entre homens e mulheres no casamento;
- Proteção da família pelo Estado.'),
(252, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 17 da DUDH consagra o DIREITO DE PROPRIEDADE: "1. Todo ser humano tem direito à propriedade, só ou em sociedade com outros. 2. Ninguém será arbitrariamente privado de sua propriedade."

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A DUDH veda a privação e o confisco arbitrário de bens legítimos.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Reconhece a propriedade individual e a propriedade coletiva/comunitária.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A proteção da propriedade aplica-se a nacionais e estrangeiros.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A desapropriação requer procedimento legal devido e justa compensação.

BIZU DE PROVA:
Artigo 17 da DUDH:
Direito de ter propriedade e proibição de ser privado dela de forma arbitrária.'),
(253, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 18 da DUDH consagra a LIBERDADE DE PENSAMENTO, CONSCIÊNCIA E RELIGIÃO: "Todo ser humano tem direito à liberdade de pensamento, consciência e religião; este direito inclui a liberdade de mudar de religião ou crença e a liberdade de manifestar essa religião ou crença, pelo ensino, pela prática, pelo culto e pela observância, em público ou em particular."

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A DUDH proíbe a imposição de religiões estatais obrigatórias ou perseguição a crenças.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O direito de mudar de religião ou não adotar religião alguma é plenamente garantido.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A manifestação da crença é autorizada tanto em ambiente privado quanto público.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A liberdade de culto é inviolável perante o poder público.

BIZU DE PROVA:
Artigo 18 da DUDH = Art. 5º, VI da CF/88:
Inviolabilidade da liberdade de consciência, crença e livre exercício dos cultos religiosos.'),
(254, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 19 da DUDH consagra a LIBERDADE DE OPINIÃO E DE EXPRESSÃO: "Todo ser humano tem direito à liberdade de opinião e expressão; este direito inclui a liberdade de, sem interferência, ter opiniões e de procurar, receber e transmitir informações e ideias por quaisquer meios e independentemente de fronteiras."

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A DUDH rejeita a censura prévia arbitrária e o controle governamental da informação.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O direito de buscar e divulgar ideias é assegurado sem limitação de fronteiras.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A livre manifestação do pensamento é direito de todo cidadão.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A imprensa livre e a comunicação social plural são protegidas.

BIZU DE PROVA:
Artigo 19 da DUDH = Art. 5º, IV e IX da CF/88:
Liberdade de manifestação do pensamento, vedado o anonimato, e livre expressão da atividade intelectual, artística, científica e de comunicação.'),
(255, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 20 da DUDH consagra a LIBERDADE DE REUNIÃO E ASSOCIAÇÃO PACÍFICA: "1. Todo ser humano tem direito à liberdade de reunião e associação pacíficas. 2. Ninguém pode ser obrigado a fazer parte de uma associação."

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A filiação obrigatória ou compulsória a associações é expressamente proibida (Art. 20, 2).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A liberdade de reunião protege manifestações de caráter pacífico e sem armas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Associações paramilitares ou de fins ilícitos não gozam de proteção.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O direito de desfiliação voluntária é assegurado a qualquer tempo.

BIZU DE PROVA:
Artigo 20 da DUDH = Art. 5º, XVI a XX da CF/88:
- Liberdade de reunião pacífica sem armas;
- Plena liberdade de associação para fins lícitos;
- NINGUÉM poderá ser compelido a associar-se ou a permanecer associado!'),
(256, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 21 da DUDH consagra a PARTICIPAÇÃO POLÍTICA e a SOBERANIA POPULAR: "1. Todo ser humano tem o direito de tomar parte no governo de seu país, diretamente ou por intermédio de representantes livremente escolhidos. 2. Todo ser humano tem igual direito de acesso ao serviço público do seu país. 3. A vontade do povo é a base da autoridade do governo; esta vontade será expressa em eleições periódicas e legítimas, por sufrágio universal, com voto secreto ou processo equivalente."

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A DUDH rechaça regimes de governos absolutistas ou vitalícios sem respaldo popular.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O voto secreto e periódico é a forma essencial de manifestação da soberania.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O acesso aos cargos públicos deve ser aberto em condições de igualdade a todos.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A vontade popular é a matriz de legitimação de todo poder político.

BIZU DE PROVA:
Artigo 21 da DUDH:
"A vontade do povo é a BASE da autoridade do governo; esta vontade será expressa em eleições periódicas e legítimas por sufrágio universal e voto secreto."'),
(257, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 22 da DUDH inaugura o bloco dos direitos sociais ao proclamar que "todo ser humano, como membro da sociedade, tem direito à segurança social, à realização pelo esforço nacional e pela cooperação internacional dos direitos econômicos, sociais e culturais indispensáveis à sua dignidade e ao livre desenvolvimento da sua personalidade".

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A previdência e seguridade social são asseguradas a todos os membros da sociedade.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A dignidade e o livre desenvolvimento humano exigem amparo social coletivo.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A assistência social independe de privilégios de casta ou classe.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A cooperação internacional para desenvolvimento humano é dever compartilhado.

BIZU DE PROVA:
Artigo 22 da DUDH:
Direito fundamental à SEGURANÇA SOCIAL e à garantia das condições materiais para uma existência digna.'),
(258, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 23 da DUDH consagra os DIREITOS TRABALHISTAS FUNDAMENTAIS: direito ao trabalho, à livre escolha de emprego, a condições justas e favoráveis de trabalho, à proteção contra o desemprego, a igual remuneração por igual trabalho sem discriminação, a remuneração equitativa que assegure existência digna, e a liberdade de fundar sindicatos e a eles filiar-se.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A discriminação salarial para mesmo trabalho viola expressamente o Artigo 23, 2 da DUDH.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O direito de livre associação sindical é assegurado no Artigo 23, 4.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O trabalho forçado é terminantemente proibido.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O trabalhador tem direito a condições laborais que garantam dignidade a si e sua família.

BIZU DE PROVA:
Artigo 23 da DUDH = Art. 7º da CF/88:
- Livre escolha de emprego;
- Igual salário para igual trabalho;
- Proteção contra o desemprego;
- Liberdade sindical.'),
(259, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 24 da DUDH estabelece: "Todo ser humano tem direito a repouso e lazer, inclusive a limitação razoável das horas de trabalho e a férias remuneradas periódicas." A limitação da jornada e o repouso são indispensáveis à integridade física e mental do trabalhador.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Jornadas exaustivas sem limitação legal violam os direitos humanos fundamentais.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O direito a férias periódicas remuneradas é garantia explícita do Artigo 24.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O repouso semanal e o descanso diário são direitos de todo trabalhador.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O lazer integra o rol de direitos sociais básicos de bem-estar.

BIZU DE PROVA:
Artigo 24 da DUDH:
Direito ao REPOUSO, ao LAZER, à LIMITAÇÃO RAZOÁVEL DA JORNADA e a FÉRIAS REMUNERADAS periódicas.'),
(260, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 25 da DUDH consagra o DIREITO A UM PADRÃO DE VIDA DIGNO: "1. Todo ser humano tem direito a um padrão de vida capaz de assegurar a si e a sua família saúde e bem-estar, inclusive alimentação, vestuário, habitação, cuidados médicos e os serviços sociais necessários (...). 2. A maternidade e a infância têm direito a cuidados e assistência especiais. Todas as crianças, nascidas dentro ou fora do matrimônio, gozam da mesma proteção social."

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A DUDH assegura igualdade total de direitos a todas as crianças, nascidas dentro ou fora do casamento (Art. 25, 2).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A maternidade e a infância gozam de proteção e assistência especiais do Estado.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O direito à saúde e à alimentação adequada é indispensável à vida digna.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A seguridade social protege em casos de velhice, viuvez, doença ou invalidez.

BIZU DE PROVA:
Artigo 25 da DUDH:
- Direito à Saúde, Habitação, Alimentação e Vestuário;
- Proteção especial à Maternidade e à Infância;
- IGUALDADE ABSOLUTA entre filhos nascidos dentro ou fora do casamento!'),
(261, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 26 da DUDH estabelece as diretrizes fundamentais do DIREITO À EDUCAÇÃO: "1. Todo ser humano tem direito à instrução. A instrução será gratuita, pelo menos nos graus elementares e fundamentais. A instrução elementar será obrigatória. A instrução técnico-profissional será acessível a todos, bem como a instrução superior, esta baseada no mérito. 2. A instrução será orientada no sentido do pleno desenvolvimento da personalidade humana e do fortalecimento do respeito pelos direitos humanos e pelas liberdades fundamentais."

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A educação elementar/fundamental deve ser gratuita e OBRIGATÓRIA.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O acesso ao ensino superior deve ser baseado no mérito e aberto em igualdade de condições.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Os pais têm prioridade de direito na escolha do gênero de instrução a ministrar a seus filhos (Art. 26, 3).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A educação visa promover a compreensão, a tolerância e a paz entre todas as nações.

BIZU DE PROVA:
Artigo 26 da DUDH (Regras do Ensino):
- Ensino Elementar/Fundamental: GRATUITO e OBRIGATÓRIO;
- Ensino Técnico: ACESSÍVEL A TODOS;
- Ensino Superior: BASEADO NO MÉRITO;
- Pais: PRIORIDADE na escolha do gênero de instrução dos filhos!'),
(262, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 27 da DUDH consagra os DIREITOS CULTURAIS E CIENTÍFICOS: "1. Todo ser humano tem o direito de participar livremente da vida cultural da comunidade, de fruir as artes e de participar do progresso científico e de seus benefícios. 2. Todo ser humano tem direito à proteção dos interesses morais e materiais decorrentes de qualquer produção científica, literária ou artística da qual seja autor."

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O acesso à ciência e cultura é aberto a toda a comunidade, e não restrito a elites.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Os direitos autorais morais e patrimoniais são expressamente tutelados pelo Artigo 27, 2.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O benefício do desenvolvimento tecnológico e científico deve ser compartilhado por todos.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A liberdade de criação artística e cultural é resguardada contra a censura.

BIZU DE PROVA:
Artigo 27 da DUDH:
- Direito de participar da vida cultural e dos avanços científicos;
- Proteção aos Direitos de Autor (interesses morais e materiais da criação).'),
(263, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 28 da DUDH estabelece: "Todo ser humano tem direito a uma ordem social e internacional na qual os direitos e liberdades estabelecidos nesta Declaração possam ser plenamente realizados." Esse artigo consagra a dimensão estrutural e cosmopolita da garantia dos direitos humanos em âmbito global.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A ordem internacional deve ser orientada à cooperação, paz e efetivação de direitos, e não ao domínio belicista.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A responsabilidade de construir uma ordem justa vincula todos os Estados e instituições internacionais.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A DUDH exige condições sociais reais para que as liberdades não sejam meramente formais.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A solidariedade internacional é indispensável para o cumprimento dos direitos humanos.

BIZU DE PROVA:
Artigo 28 da DUDH:
Direito a uma ORDEM SOCIAL E INTERNACIONAL justa que viabilize a plena eficácia de todos os direitos humanos.'),
(264, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 29 da DUDH consagra os DEVERES DO INDIVÍDUO e os limites legítimos aos direitos: "1. Todo ser humano tem deveres para com a comunidade, na qual o livre e pleno desenvolvimento da sua personalidade é possível. 2. No exercício de seus direitos e liberdades, todo ser humano estará sujeito apenas às limitações determinadas pela lei, exclusivamente com o fim de assegurar o devido reconhecimento e respeito dos direitos e liberdades de outrem e de satisfazer as justas exigências da moral, da ordem pública e do bem-estar geral numa sociedade democrática."

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Os direitos humanos não são absolutos e ilimitados perante os direitos alheios e a ordem democrática.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O indivíduo possui deveres de solidariedade para com a comunidade onde vive.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
As limitações devem ser previstas em lei em prol do bem-estar em sociedade democrática.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não se admite o abuso de direito para destruir liberdades fundamentais.

BIZU DE PROVA:
Artigo 29 da DUDH:
- Deveres do indivíduo perante a comunidade;
- Limites legítimos aos direitos humanos: apenas por LEI para garantir os direitos de outrem e a ordem pública numa SOCIEDADE DEMOCRÁTICA.'),
(265, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 30 da DUDH (Cláusula de Vedação do Abuso de Direito / Proteção contra Interpretações Destrutivas) estabelece: "Nenhuma disposição da presente Declaração pode ser interpretada como reconhecendo a qualquer Estado, grupo ou pessoa o direito de exercer qualquer atividade ou praticar qualquer ato destinado à destruição de quaisquer dos direitos e liberdades aqui estabelecidos."

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Nenhum governo ou grupo pode invocar a DUDH para suprimir direitos de opositores ou minorias.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A DUDH é um sistema harmônico protetivo, vedada a interpretação fraudulenta regressiva.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O abuso de direito é terminantemente repelido pela hermenêutica dos direitos humanos.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A proteção visa preservar a integridade integral do catálogo de direitos.

BIZU DE PROVA:
Artigo 30 da DUDH (Último Artigo):
CLÁUSULA DE SALVAGUARDA: Nenhum direito da DUDH pode ser usado como pretexto para DESTRUIR outros direitos humanos!'),
(266, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A Convenção Internacional sobre a Eliminação de Todas as Formas de Discriminação Racial (ONU, 1965, promulgada no Brasil pelo Decreto nº 65.810/1969) define discriminação racial como qualquer distinção, exclusão, restrição ou preferência baseada em raça, cor, descendência ou origem nacional ou étnica que tenha por objetivo ou efeito anular ou restringir o reconhecimento, gozo ou exercício em igualdade de condições de direitos humanos e liberdades fundamentais nos campos político, econômico, social, cultural ou civil.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A Convenção compromete os Estados a proibir e punir toda manifestação de ódio e segregação racial.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
As ações afirmativas temporárias para igualar grupos vulneráveis são autorizadas e incentivadas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A proteção aplica-se a todos os grupos étnicos e raciais da sociedade.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O racismo constitui grave violação da dignidade e crime imprescritível no Brasil (art. 5º, XLII, CF).

BIZU DE PROVA:
Convenção contra a Discriminação Racial (ONU/1965):
Proíbe qualquer distinção baseada em RAÇA, COR, DESCENDÊNCIA ou ORIGEM NACIONAL/ÉTNICA. Ações afirmativas para reparar desigualdades históricas são plenamente válidas!'),
(291, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A Constituição Federal de 1988 consagra o PRINCÍPIO DA NÃO DISCRIMINAÇÃO E IGUALDADE no Artigo 3º, inciso IV (promover o bem de todos, sem preconceitos de origem, raça, sexo, cor, idade e quaisquer outras formas de discriminação) e no Artigo 5º, caput (todos são iguais perante a lei, sem distinção de qualquer natureza), vinculando o Estado a garantir a igualdade formal e material.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A Constituição veda qualquer discriminação odiosa ou preconceito.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A igualdade vincula o legislador, o juiz e a administração pública.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A proteção à igualdade abrange todas as pessoas sob jurisdição brasileira.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O princípio da isonomia veda privilégios injustificados e perseguições.

BIZU DE PROVA:
Objetivo Fundamental da República (Art. 3º, IV da CF/88):
Promover o bem de todos, SEM preconceitos de origem, raça, sexo, cor, idade e quaisquer outras formas de discriminação!'),
(292, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Conforme o Artigo 5º, inciso XLII, da Constituição Federal de 1988, "a prática do racismo constitui crime inafiançável e imprescritível, sujeito à pena de reclusão, nos termos da lei". Essa previsão reflete o repúdio constitucional intransigente à discriminação racial e étnica.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O racismo é expressamente INAFIANÇÁVEL (não admite fiança).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O racismo é IMPRESCRITÍVEL (pode ser processado e punido a qualquer tempo, não prescreve).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A pena cominada na CF é de RECLUSÃO (e não mera detenção ou multa isolada).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O racismo é crime de ação penal pública incondicionada.

BIZU DE PROVA:
Crime de Racismo na CF/88 (Art. 5º, XLII - Mnemônico RA-ÇÃO):
- RA = RAcismo;
- ÇÃO = AÇÃO de grupos armados contra a ordem constitucional.
Ambos são INAFIANÇÁVEIS e IMPRESCRITÍVEIS!'),
(293, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Nos termos do Artigo 5º, inciso XLIII, da Constituição Federal de 1988, a lei considerará crimes INAFIANÇÁVEIS e INSUSCETÍVEIS DE GRAÇA OU ANISTIA a prática da tortura, o tráfico ilícito de entorpecentes e drogas afins, o terrorismo e os definidos como crimes hediondos, por eles respondendo os mandantes, os executores e os que, podendo evitá-los, se omitirem.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A tortura e o tráfico não admitem fiança nem graça/anistia constitucional.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A Constituição pune mandantes, executores e os que se omitem quando podiam agir.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A vedação a graça e anistia é imposição constitucional expressa.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
São tratados com especial rigor punitivo pelo ordenamento republicano.

BIZU DE PROVA:
Crimes Inafiançáveis e Insuscetíveis de Graça ou Anistia (Art. 5º, XLIII - Mnemônico 3T + H):
- Tortura;
- Tráfico de drogas;
- Terrorismo;
- Hediondos.
(São inafiançáveis e insuscetíveis de graça/anistia, mas PRESCREVEM, diferentemente do racismo e da ação de grupos armados).'),
(342, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O Artigo 7º da Lei Federal nº 11.340/2006 (Lei Maria da Penha) tipifica expressamente cinco formas de violência doméstica e familiar contra a mulher:
I - Violência FÍSICA (ofensa à integridade ou saúde corporal);
II - Violência PSICOLÓGICA (dano emocional, diminuição da autoestima, constrangimento, humilhação, manipulação, vigilância constante);
III - Violência SEXUAL (induzir a presenciar, a manter ou a participar de relação sexual não desejada, mediante coação, força ou ameaça);
IV - Violência PATRIMONIAL (retenção, subtração, destruição parcial ou total de objetos, instrumentos de trabalho, documentos, bens e valores);
V - Violência MORAL (calúnia, difamação ou injúria).
A descrição apresentada na questão corresponde exatamente à caracterização legal da VIOLÊNCIA PATRIMONIAL / PSICOLÓGICA no rol taxativo do art. 7º.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Não se limita à agressão física direta; a lei prevê proteção integral contra danos emocionais e materiais.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A violência psicológica e patrimonial independe de lesão física corporal prévia.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
As condutas descritas no art. 7º da Lei Maria da Penha configuram violência doméstica independentemente da coabitação atual das partes (Súmula 600 do STJ).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A proteção legal abrange todas as mulheres em situação de vulnerabilidade pelo gênero no âmbito doméstico/familiar.

BIZU DE PROVA:
As 5 Formas de Violência Doméstica (Art. 7º da Lei Maria da Penha - Mnemônico FÍ-PSI-SEX-PA-MO):
1. FÍsica;
2. PSIcológica;
3. SEXual;
4. PAtrimonial;
5. MOral.'),
(343, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
A Convenção Americana sobre Direitos Humanos (Pacto de San José da Costa Rica de 1969) estabelece:
- Artigo 5º (Direito à Integridade Pessoal): Toda pessoa tem o direito de que se respeite sua integridade física, psíquica e moral; ninguém deve ser submetido a torturas, penas ou tratamentos cruéis, desumanos ou degradantes; os processados devem ficar separados dos condenados e os menores dos adultos.
- Artigo 7º (Direito à Liberdade Pessoal): Ninguém pode ser privado de sua liberdade física, salvo pelas causas e nas condições fixadas previamente pela lei; toda pessoa detida deve ser informada das razões de sua prisão e levada sem demora à presença de um juiz (audiência de custódia).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A CADH proíbe expressamente a mistura promíscua de presos condenados com réus provisórios (Art. 5.4).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A audiência perante a autoridade judicial é garantia mandatória e imediata da CADH (Art. 7.5).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A tortura e os castigos corporais são vedados de forma absoluta no Pacto de San José.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Menores infratores devem ser obrigatoriamente separados dos adultos e conduzidos a tribunal especializado (Art. 5.5).

BIZU DE PROVA:
Regras Penitenciárias na Convenção Americana (Art. 5º da CADH):
1. Processados SEPARADOS de condenados;
2. Menores SEPARADOS de adultos;
3. Finalidade da pena: REABILITAÇÃO e readaptação social dos condenados!'),
(349, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
O Estatuto da Igualdade Racial (Lei nº 12.288/2010) dispõe expressamente que o poder público adotará políticas públicas específicas para o desenvolvimento integral das comunidades quilombolas e tradicionais de matriz africana, assegurando-lhes a titulação definitiva de suas terras tradicionalmente ocupadas (Art. 31), o acesso à saúde diferenciada (Art. 7º), a preservação de seu patrimônio cultural e religioso (Art. 24) e a implementação de diretrizes curriculares que valorizem a história e cultura afro-brasileira (Art. 11).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O Estatuto assegura a titulação definitiva e gratuita das terras quilombolas, vedando a expropriação arbitrária.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A proteção ao patrimônio cultural afro-brasileiro é obrigação legal do Estado (art. 215 da CF e art. 24 da Lei 12.288/2010).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O ensino de História da África e das Culturas Afro-Brasileira e Indígena é obrigatório no currículo escolar (Art. 11 da Lei 12.288/2010).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O acesso à saúde e ao Sistema Único de Saúde deve contemplar políticas de atenção integral à saúde da população negra.

BIZU DE PROVA:
Estatuto da Igualdade Racial (Lei 12.288/2010):
- Art. 31: Reconhecimento e titulação definitiva das terras das comunidades de quilombos;
- Ações afirmativas para equidade em saúde, educação e trabalho.'),
(351, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
O Artigo 16 da Convenção sobre os Direitos das Pessoas com Deficiência (CDPD) prescreve que "os Estados Partes tomarão todas as medidas apropriadas de natureza legislativa, administrativa, social, educacional e outras para proteger as pessoas com deficiência, tanto dentro como fora do lar, contra todas as formas de exploração, violência e abuso, incluindo aspectos relacionados ao gênero".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A proteção não se limita ao espaço domiciliar, abrangendo o ambiente externo, instituições e comunidade.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A Convenção impõe a proteção a todas as pessoas com deficiência, com atenção especial a mulheres e crianças.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O dever de fiscalização e punição de abusos é imperativo internacional para os Estados-partes.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não se trata de mera orientação programática, mas de obrigação convencional vinculante com status constitucional.

BIZU DE PROVA:
Artigo 16 da CDPD (Status de Emenda Constitucional):
Proteção integral das pessoas com deficiência contra EXPLORAÇÃO, VIOLÊNCIA e ABUSO, dentro e fora do lar, com perspectiva de gênero e idade.'),
(352, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Nos termos do Artigo 16, item 4, da Convenção sobre os Direitos das Pessoas com Deficiência, os Estados-partes devem tomar todas as medidas apropriadas para promover a recuperação física, cognitiva e psicológica, a reabilitação e a reinserção social de pessoas com deficiência vítimas de qualquer forma de exploração, violência ou abuso, ocorrendo essa recuperação em ambientes que promovam a saúde, o bem-estar, a dignidade, a autonomia e levem em consideração as necessidades específicas de gênero e idade.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A recuperação deve ser integral, biopsicossocial, e não puramente física.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A internação compulsória desprovida de critérios terapêuticos e garantias viola a Convenção.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Os serviços de acolhimento e reinserção social são dever do Estado e da rede de proteção.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
As medidas de apoio devem respeitar a autonomia, vontade e dignidade da pessoa com deficiência.

BIZU DE PROVA:
Reabilitação de Vítimas com Deficiência (Art. 16.4 da CDPD):
Recuperação física, cognitiva e psicológica em ambiente digno que promova a AUTONOMIA e considere GÊNERO e IDADE.'),
(353, 'GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A alternativa A está INCORRETA (sendo o gabarito da questão) porque o Artigo 5º do Protocolo Facultativo à Convenção sobre os Direitos das Pessoas com Deficiência (promulgado pelo Decreto nº 6.949/2009 com equivalência de Emenda Constitucional) estabelece expressamente que "o Comitê realizará sessões FECHADAS [e não abertas] para examinar as comunicações a ele submetidas em conformidade com o presente Protocolo", preservando a privacidade das vítimas e o sigilo processual preliminar.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Afirmativa verdadeira: o Artigo 1º do Protocolo reconhece a competência do Comitê para receber comunicações individuais.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Afirmativa verdadeira: o Artigo 2º, a, declara inadmissível qualquer comunicação anônima.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Afirmativa verdadeira: o Artigo 4º autoriza o Comitê a solicitar medidas cautelares urgentes ao Estado Parte.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Afirmativa verdadeira: o Artigo 5º prevê o envio de sugestões e recomendações ao Estado e ao requerente.

BIZU DE PROVA:
Protocolo Facultativo à CDPD (Artigo 5º):
O exame de comunicações e denúncias individuais pelo Comitê da ONU sobre os Direitos das Pessoas com Deficiência ocorre em SESSÕES FECHADAS (confidenciais)!'),
(354, 'GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
Estão corretas apenas as situações I e II:
- Situação I (Crime - Art. 15-A da Lei nº 13.869/2019): Submeter vítima de infração penal ou testemunha de crimes violentos a procedimentos desnecessários, repetitivos ou invasivos, que a leve a reviver sem estrita necessidade a situação de violência, configura o crime de VIOLÊNCIA INSTITUCIONAL (incluído pela Lei nº 14.321/2022).
- Situação II (Crime - Art. 23 da Lei nº 13.869/2019): Inovar artificiosamente, no curso de diligência, de investigação ou de processo, o estado de lugar, de coisa ou de pessoa, com o fim de eximir-se de responsabilidade ou de agravar a de outrem, configura crime de abuso de autoridade (Fraude Processual Funcional).
- Situação III (Não configura crime - Excludente Constitucional): O ingresso em domicílio alheio sem consentimento, durante o dia ou à noite, em situação de DESASTRE ou para prestar SOCORRO a terceiro, é expressamente autorizado pelo Artigo 5º, inciso XI, da Constituição Federal e pelo Artigo 22, §2º, da Lei nº 13.869/2019.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Incompleta, pois a situação II também constitui crime de abuso de autoridade.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Incompleta, pois a situação I também é crime (violência institucional).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A situação III é lícita (salvamento em desastre/prestação de socorro).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A situação III não configura crime.

BIZU DE PROVA:
Inviolabilidade Domiciliar e Abuso de Autoridade:
Entrar na casa em caso de DESASTRE, PRESTAÇÃO DE SOCORRO ou FLAGRANTE DELITO é LÍCITO a qualquer hora (dia ou noite) e NÃO constitui crime de abuso de autoridade!'),
(623, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Estão corretas apenas as assertivas I e III:
- Assertiva I (Correta): As Diretrizes Nacionais de Promoção e Defesa dos Direitos Humanos dos Profissionais de Segurança Pública (Portaria Interministerial SEDH/MJ nº 2/2010) determinam que o Estado deve implementar políticas de saúde física e mental, atenção psicossocial permanente e programas de prevenção do suicídio.
- Assertiva II (Incorreta): A formação continuada em saúde ocupacional, biossegurança e condições de trabalho NÃO é facultativa, mas componente estruturante e obrigatório das diretrizes formativas.
- Assertiva III (Correta): Condições dignas de trabalho, equipamentos de proteção individual (EPIs) adequados, jornada compatível e remuneração condigna são pressupostos indispensáveis para a atuação policial em conformidade com os direitos humanos.
- Assertiva IV (Incorreta): A responsabilização por desvios e abusos é plenamente compatível com os direitos humanos e integra o controle da atividade policial (não se admite blindagem corporativa).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A assertiva II é falsa (saúde ocupacional não é facultativa).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
As assertivas II e IV estão incorretas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A assertiva II está incorreta.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A assertiva IV é falsa (a responsabilização não é incompatível com direitos humanos).

BIZU DE PROVA:
Diretrizes de Direitos Humanos para Profissionais de Segurança:
- Cuidar da saúde física, mental e prevenção ao suicídio do policial;
- EPIs de qualidade e ambiente seguro de trabalho;
- Responsabilização de abusos mantida (sem corporativismo impune).'),
(624, 'GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Conforme o Artigo 53 do Estatuto da Igualdade Racial (Lei nº 12.288/2010), "é assegurado às vítimas de discriminação étnica ou desigualdade racial o acesso aos órgãos de Ouvidoria Permanente, à Defensoria Pública, ao Ministério Público e ao Poder Judiciário, em todas as suas instâncias, para a garantia do cumprimento de seus direitos".

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O Artigo 51 estabelece que o poder público federal "instituirá" (e não apenas mera faculdade restrita) mecanismos e ouvidorias.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O Estado deve garantir assistência física, psíquica, jurídica, social e habitacional integral, e não "apenas física e psíquica".

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
As medidas aplicam-se a todos os servidores públicos, civis E militares (não há exclusão de militares).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A proteção coletiva faz-se principalmente mediante Ação Civil Pública e Ação Popular, e não habeas corpus (que tutela exclusivamente a liberdade de locomoção).

BIZU DE PROVA:
Artigo 53 da Lei nº 12.288/2010:
Acesso integral da vítima de racismo a:
- Ouvidorias Permanentes;
- Defensoria Pública;
- Ministério Público;
- Poder Judiciário.'),
(625, 'GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O Programa Nacional de Direitos Humanos – PNDH-3 (Decreto Federal nº 7.037/2009), estruturado em seu Eixo Orientador III ("Universalizar direitos em um contexto de desigualdades"), consagra a diversidade e a equidade étnico-racial, de gênero e orientação sexual como dimensões constitutivas da dignidade humana, orientando a formulação de políticas públicas intersetoriais, ações afirmativas reparatórias e a revisão de práticas institucionais discriminatórias.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O PNDH-3 adota a igualdade substancial/material e fomenta ativamente ações afirmativas para grupos historicamente vulnerabilizados.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O Programa estabelece metas, diretrizes e ações programáticas concretas que vinculam a administração pública federal.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A transversalidade da diversidade abrange expressamente a segurança pública, sistema de justiça e penitenciário.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O PNDH-3 proíbe a flexibilização de garantias fundamentais sob pretexto de eficiência da ordem pública.

BIZU DE PROVA:
PNDH-3 (Decreto 7.037/2009):
- 6 Eixos Orientadores;
- Eixo III: Universalizar direitos em um contexto de desigualdades;
- Políticas afirmativas e proteção integral da diversidade humana.'),
(648, 'GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
Forçar a vítima a despir-se completamente durante a prática de um crime de roubo constitui ato ultrajante de humilhação, aviltamento moral e constrangimento vexatório desnecessário que atenta de forma direta e contundente contra o FUNDAMENTO DA DIGNIDADE DA PESSOA HUMANA (Artigo 1º, inciso III, da Constituição Federal de 1988) e contra a garantia de integridade física e moral (Artigo 5º, inciso X e XLIX, da CF).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
"Soberania patrimonial" não é fundamento da República Federativa do Brasil.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
"Cidadania moral" não existe como nomenclatura de fundamento constitucional.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
"Valores do livre arbítrio" não compõem o rol do Artigo 1º da CF/88.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Iniciativa popular é instrumento de exercício da soberania (art. 14, III), não o fundamento violado pelo ultraje à integridade da vítima.

BIZU DE PROVA:
Art. 1º, III da CF/88:
A DIGNIDADE DA PESSOA HUMANA é o valor ético supremo que veda qualquer forma de tratamento degradante, vexatório ou desumanizador!');

-- ----------------------------------------------------------------------------
-- Snapshot ANTES.
-- ----------------------------------------------------------------------------
-- 1) linha inteira das 50 (exceto explicacao/atualizado_em).
create temporary table _dh2_snap_questoes on commit drop as
select id, (to_jsonb(q) - 'explicacao' - 'atualizado_em') as dados_imutaveis
from public.questoes q
where q.id in (174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,249,250,251,252,253,254,255,256,257,258,259,260,261,262,263,264,265,266,291,292,293,342,343,349,351,352,353,354,623,624,625,648);

-- 2) alternativas completas das 50.
create temporary table _dh2_snap_alternativas on commit drop as
select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
from public.alternativas a
where a.questao_id in (174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,249,250,251,252,253,254,255,256,257,258,259,260,261,262,263,264,265,266,291,292,293,342,343,349,351,352,353,354,623,624,625,648)
group by questao_id;

-- 3) hash de explicacao de TODAS as questoes do banco.
create temporary table _dh2_snap_hash_todas on commit drop as
select id, md5(coalesce(explicacao, '')) as hash_explicacao
from public.questoes;

-- 4) contagens globais.
create temporary table _dh2_snap_global on commit drop as
select
  (select count(*) from public.questoes)            as total_questoes_antes,
  (select count(*) from public.questoes where ativa) as total_ativas_antes;

create temporary table _dh2_asserts (ordem serial primary key, descricao text, ok boolean) on commit drop;

-- ----------------------------------------------------------------------------
-- Precondicoes.
-- ----------------------------------------------------------------------------
do $$
declare
  v_qtd int;
begin
  if (select count(*) from _dh2_novas_explicacoes) <> 50 then
    raise exception 'PRECONDICAO FALHOU: staging nao tem exatamente 50 explicacoes';
  end if;

  select count(*) into v_qtd from public.questoes where id in (select id from _dh2_novas_explicacoes);
  if v_qtd <> 50 then
    raise exception 'PRECONDICAO FALHOU: esperado 50 questoes no banco, encontrado %', v_qtd;
  end if;

  if exists (
    select 1 from public.questoes q
    join _dh2_novas_explicacoes s on s.id = q.id
    where q.materia_id not in (11, 19) or q.ativa is distinct from true
  ) then
    raise exception 'PRECONDICAO FALHOU: alguma das 50 nao esta mais no estado auditado (materia_id in (11, 19), ativa=true)';
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ESCRITA: atualiza explicacao + atualizado_em das 50.
-- ----------------------------------------------------------------------------
create temporary table _dh2_ids_afetados (id bigint primary key) on commit drop;

do $$
declare
  v_linhas int;
begin
  with atualizado as (
    update public.questoes q
    set explicacao = s.explicacao, atualizado_em = now()
    from _dh2_novas_explicacoes s
    where q.id = s.id
    returning q.id
  )
  insert into _dh2_ids_afetados (id) select id from atualizado;

  get diagnostics v_linhas = row_count;
  if v_linhas <> 50 then
    raise exception 'ESCRITA FALHOU: esperado UPDATE de exatamente 50 linhas, afetou %', v_linhas;
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ASSERTS pos-escrita.
-- ----------------------------------------------------------------------------
do $$
declare
  v_completas int;
  v_total_depois int;
  v_ativas_depois int;
  v_sem_correta int;
begin
  insert into _dh2_asserts (descricao, ok)
  select 'exatamente 50 questoes afetadas pelo UPDATE', (select count(*) from _dh2_ids_afetados) = 50;

  insert into _dh2_asserts (descricao, ok)
  select 'os ids afetados sao exatamente os 50 esperados',
    (select array_agg(id order by id) from _dh2_ids_afetados) = ARRAY[174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,249,250,251,252,253,254,255,256,257,258,259,260,261,262,263,264,265,266,291,292,293,342,343,349,351,352,353,354,623,624,625,648]::bigint[];

  insert into _dh2_asserts (descricao, ok)
  select 'enunciado/alternativas-relacao/gabarito/materia/assunto/ativa/banca/concurso/ano/fonte preservados nas 50 (comparacao jsonb byte-a-byte, exceto explicacao/atualizado_em)',
    not exists (
      select 1 from public.questoes q
      join _dh2_snap_questoes s on s.id = q.id
      where (to_jsonb(q) - 'explicacao' - 'atualizado_em') <> s.dados_imutaveis
    );

  insert into _dh2_asserts (descricao, ok)
  select 'alternativas das 50 continuam byte-identicas (texto/correta/ordem)',
    not exists (
      select 1
      from _dh2_snap_alternativas s
      join (
        select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
        from public.alternativas a
        where a.questao_id in (select id from _dh2_novas_explicacoes)
        group by questao_id
      ) d on d.questao_id = s.questao_id
      where d.alternativas <> s.alternativas
    );

  select count(*) into v_sem_correta
  from _dh2_novas_explicacoes s
  where (select count(*) from public.alternativas a where a.questao_id = s.id and a.correta) <> 1;
  insert into _dh2_asserts (descricao, ok) values ('as 50 continuam com exatamente 1 alternativa correta cada', v_sem_correta = 0);

  -- Classificacao EXPLICACAO_COMPLETA das 50 apos o UPDATE
  with alt_stats as (
    select q.id as questao_id, count(a.id) as n_alt, count(a.id) filter (where a.correta) as n_corretas,
      bool_and(lower(btrim(a.texto)) in ('certo', 'errado')) and count(a.id) = 2 as eh_certo_errado
    from public.questoes q
    left join public.alternativas a on a.questao_id = q.id
    where q.id in (select id from _dh2_novas_explicacoes)
    group by q.id
  ),
  classificado as (
    select q.id,
      case
        when q.explicacao is null or btrim(q.explicacao) = '' then 'SEM_EXPLICACAO'
        when s.n_corretas <> 1 or s.n_alt = 0 then 'PROBLEMATICA'
        when s.eh_certo_errado then
          case
            when q.explicacao ~* 'GABARITO\s*:\s*(CERTO|ERRADO)' and q.explicacao ~* 'POR QUE\s*:' and q.explicacao ~* 'BIZU DE PROVA'
              then 'EXPLICACAO_COMPLETA'
            else 'OUTRO'
          end
        else
          case
            when q.explicacao ~* 'GABARITO\s*:' and q.explicacao ~* 'BIZU DE PROVA'
             and (select count(distinct m[1]) from regexp_matches(q.explicacao, 'POR QUE A ALTERNATIVA\s+([A-E])\s+EST[ÁA]\s+(CORRETA|INCORRETA)', 'gi') as m) >= s.n_alt
              then 'EXPLICACAO_COMPLETA'
            else 'OUTRO'
          end
      end as status
    from public.questoes q
    join alt_stats s on s.questao_id = q.id
    where q.id in (select id from _dh2_novas_explicacoes)
  )
  select count(*) filter (where status = 'EXPLICACAO_COMPLETA') into v_completas from classificado;
  insert into _dh2_asserts (descricao, ok) values ('as 50 passam no classificador canonico como EXPLICACAO_COMPLETA', v_completas = 50);

  insert into _dh2_asserts (descricao, ok)
  select 'nenhuma outra questao do banco teve explicacao alterada',
    not exists (
      select 1 from public.questoes q
      join _dh2_snap_hash_todas s on s.id = q.id
      where md5(coalesce(q.explicacao, '')) <> s.hash_explicacao
        and q.id <> ALL(ARRAY[174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,249,250,251,252,253,254,255,256,257,258,259,260,261,262,263,264,265,266,291,292,293,342,343,349,351,352,353,354,623,624,625,648]::bigint[])
    );

  select count(*) into v_total_depois from public.questoes;
  insert into _dh2_asserts (descricao, ok) values ('total de questoes no banco inalterado (nenhuma criada/excluida)', v_total_depois = (select total_questoes_antes from _dh2_snap_global));

  select count(*) into v_ativas_depois from public.questoes where ativa = true;
  insert into _dh2_asserts (descricao, ok) values ('total de questoes ATIVAS do Papiro inalterado', v_ativas_depois = (select total_ativas_antes from _dh2_snap_global));
end $$;

-- Relatorio de asserts
do $$
declare
  r record;
  v_total integer;
  v_ok integer;
begin
  for r in select descricao, ok from _dh2_asserts order by ordem loop
    if r.ok then
      raise notice 'OK: %', r.descricao;
    else
      raise exception 'FALHOU: %', r.descricao;
    end if;
  end loop;

  select count(*), count(*) filter (where ok) into v_total, v_ok from _dh2_asserts;
  raise notice '=== RESUMO: % / % asserts passaram ===', v_ok, v_total;
  if v_ok <> v_total then
    raise exception 'Harness falhou: nem todos os asserts passaram.';
  end if;
end $$;

-- Nada commitado: tudo desfeito abaixo.
COMMIT;
