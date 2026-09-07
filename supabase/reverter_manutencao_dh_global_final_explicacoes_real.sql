-- REVERSAO REAL, POS-APPLY, da MANUTENCAO GLOBAL FINAL DAS EXPLICACOES
-- REAL de Direitos Humanos (19 corrupcoes cruzadas + Q351).
--
-- NAO EXECUTAR agora. So deve ser usado se, no futuro, for necessario
-- desfazer o apply ja confirmado (commit) de
-- supabase/manutencao_dh_global_final_explicacoes_real.sql.
--
-- Restaura o texto EXATO de questoes.explicacao capturado do LIVE antes
-- do apply (nao reconstruido por memoria). Exige que as 20 questoes
-- estejam ainda no estado NEW (new_md5 + fingerprint) antes de reverter;
-- se qualquer uma tiver sido alterada por outro processo depois do
-- apply, ABORTA integralmente e nao sobrescreve estado divergente.
--
-- Termina em COMMIT. So deve ser executado apos autorizacao humana
-- explicita.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _revert_dh_global (
  questao_id bigint primary key,
  new_md5_esperado text not null,
  fingerprint_esperado text not null,
  old_md5_esperado text not null,
  explicacao_old text not null
) on commit drop;

insert into _revert_dh_global (questao_id, new_md5_esperado, fingerprint_esperado, old_md5_esperado, explicacao_old) values
(55, '0ce8fdb24699ba9f0e37ef5395021c35', 'c3bfb7f87f1317ee54d735c5a1be166c', 'b9d853e7582b79521e8aa96d9c1365a6', $OLDQ55$GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
De acordo com o Artigo 2º da DUDH/1948 (Princípio da Não Discriminação), todo ser humano tem capacidade para gozar os direitos e as liberdades estabelecidos na Declaração, sem distinção de qualquer espécie, seja de raça, cor, sexo, idioma, religião, opinião política ou de outra natureza, origem nacional ou social, riqueza, nascimento ou qualquer outra condição.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A DUDH veda expressamente restrições de direitos baseadas em religião ou crença.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A DUDH não admite exclusão ou restrição fundada em origem nacional ou etnia.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A DUDH protege expressamente as liberdades de opinião e convicção política (Art. 19).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A condição socioeconômica ou de riqueza não pode ser critério para privação de direitos humanos.

BIZU DE PROVA:
Princípio da Não Discriminação (Art. 2º da DUDH):
A titularidade dos direitos da DUDH é UNIVERSAL: veda-se distinção de raça, cor, sexo, língua, religião, opinião política, origem nacional, riqueza ou qualquer outra condição!$OLDQ55$),
(57, '7683f00e4809a3c54f7606256176bbac', '4911e04a702d4780d93813e0c8238bb7', '9cb83f71b4360847d452079cee20a06b', $OLDQ57$GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
A Convenção contra a Tortura e Outros Tratamentos ou Penas Cruéis, Desumanos ou Degradantes (ONU, 1984, promulgada no Brasil pelo Decreto nº 40/1991) e o Artigo 5º, III, da CF/88 estabelecem o caráter ABSOLUTO da proibição da tortura: nenhuma circunstância excepcional, seja estado de guerra, instabilidade política interna ou emergência pública, pode ser invocada para justificar a prática de tortura.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A tortura nunca é permitida sob alegação de ordem de superior hierárquico (não há excludente de ilicitude).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A proibição da tortura é absoluta e inderrogável mesmo em estado de sítio ou estado de defesa.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A confissão obtida mediante tortura é prova ilícita absoluta e inadmissível no processo penal (Art. 5º, LVI, CF).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A tortura constitui crime inafiançável e insuscetível de graça ou anistia (Art. 5º, XLIII, CF).

BIZU DE PROVA:
Vedação Absoluta da Tortura (Jus Cogens):
A proibição da tortura e do tratamento desumano/degradante é norma cogente internacional (jus cogens). NÃO admite exceção, relativização ou ponderação em hipótese alguma!$OLDQ57$),
(58, '555e3a083b20fa48832abf38a0fca6ca', '01c89f16c6bdccc6eab4caa06923437d', 'b085a336079acab0f1ce8babc5301b64', $OLDQ58$GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A Convenção sobre a Eliminação de Todas as Formas de Discriminação contra a Mulher (CEDAW/ONU, 1979) define discriminação contra a mulher como qualquer distinção, exclusão ou restrição baseada no sexo que tenha por objeto ou resultado prejudicar ou anular o reconhecimento, gozo ou exercício pela mulher dos direitos humanos e liberdades fundamentais nos campos político, econômico, social, cultural ou civil.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A CEDAW busca a igualdade substantiva (material) entre homens e mulheres, vedando discriminações.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A Convenção incentiva expressamente a adoção de ações afirmativas temporárias (medidas especiais) para acelerar a igualdade.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A proteção abrange tanto a esfera pública quanto a privada e familiar.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A CEDAW não se limita ao mercado de trabalho, abrangendo direitos civis, políticos e sociais.

BIZU DE PROVA:
Ações Afirmativas na CEDAW:
A adoção de medidas especiais de caráter temporário destinadas a acelerar a igualdade de fato entre o homem e a mulher NÃO é considerada discriminação (Art. 4º, 1, da CEDAW).$OLDQ58$),
(59, 'c53a3c87560fc8e94b912bd3959998ef', 'a8ab77b0b80daab07028ad649faaddae', '405e1a2469c60b186d908777cad4e1fd', $OLDQ59$GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
O Tribunal Penal Internacional (TPI), criado pelo Estatuto de Roma de 1998 (integrado ao Brasil pelo Decreto nº 4.388/2002 e previsto no art. 5º, §4º, da CF/88), possui competência restrita ao julgamento de pessoas físicas responsáveis pelos crimes mais graves de alcance internacional:
1) Crime de Genocídio;
2) Crimes contra a Humanidade;
3) Crimes de Guerra;
4) Crime de Agressão.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Crimes fiscais ou tributários não integram a jurisdição material do TPI.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Infrações de trânsito são da competência da justiça doméstica local.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Crimes contra o patrimônio ordinários não são julgados pelo TPI.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O TPI julga indivíduos (pessoas físicas), e não responsabilidade civil de empresas ou Estados.

BIZU DE PROVA:
4 Crimes sob a Jurisdição do TPI (Art. 5º do Estatuto de Roma):
1. Genocídio;
2. Crimes contra a Humanidade;
3. Crimes de Guerra;
4. Crime de Agressão.
Mnemônico: "G-C-G-A" (Guerra, Crimes contra humanidade, Genocídio, Agressão).$OLDQ59$),
(124, 'b467c4d408f45a686f30237439f4ba69', '0840e0cd3f7ade312391dcdf6eba63e8', 'bcd85954dbe6eb1acdcea137ee754b8f', $OLDQ124$GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Na Constituição Federal de 1988, os direitos e garantias fundamentais possuem aplicabilidade imediata (art. 5º, §1º), integram o rol de cláusulas pétreas (art. 60, §4º, IV) e representam o núcleo material de proteção do indivíduo, vinculando diretamente a atuação de todos os Poderes do Estado (Executivo, Legislativo e Judiciário).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Os direitos fundamentais não são meramente programáticos; possuem eficácia plena/contida e aplicabilidade imediata (art. 5º, §1º).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não podem ser abolidos por emenda constitucional por serem cláusulas pétreas (art. 60, §4º, IV).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Aplicam-se tanto aos brasileiros quanto aos estrangeiros residentes ou em trânsito no país.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A titularidade não se restringe a agentes estatais.

BIZU DE PROVA:
Art. 5º, §1º, da CF/88:
"As normas definidoras dos direitos e garantias fundamentais têm APLICAÇÃO IMEDIATA."$OLDQ124$),
(125, '27bde3630cbfc24c5d44280d41ca7875', '9a34597f5d3c735ae9a6734b828c3f76', 'e6d7660842777effcfbf254a6e847ef4', $OLDQ125$GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Nos termos do Artigo 1º, inciso III, da Constituição Federal de 1988, a DIGNIDADE DA PESSOA HUMANA é expressamente consagrada como um dos FUNDAMENTOS estruturantes da República Federativa do Brasil, servindo de vetor hermenêutico e base principiológica de todo o ordenamento jurídico nacional.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A dignidade humana é um fundamento basilar da República, não uma competência privativa da União.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não é um mero objetivo programático secundário, mas princípio fundamental explícito.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não é uma regra processual temporária.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Possui status constitucional originário e máxima hierarquia jurídica.

BIZU DE PROVA:
Fundamentos da República (Art. 1º da CF/88 - Mnemônico SO-CI-DI-VA-PLU):
- SOberania;
- CIdadania;
- DIgnidade da pessoa humana;
- VAlores sociais do trabalho e da livre iniciativa;
- PLUralismo político.$OLDQ125$),
(126, '049f07129a6945c2066e09bfb1a72f78', '361fb785533b7e82c94ba81ecfc03152', '48a0bd076215311e086f217d83121e6f', $OLDQ126$GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
Na consagrada teoria das gerações/dimensões dos direitos humanos (Karel Vasak):
- 1ª Geração (Liberdade): Direitos civis e políticos (liberdades negativas, não intervenção do Estado);
- 2ª Geração (Igualdade): Direitos sociais, econômicos e culturais (prestações positivas do Estado);
- 3ª Geração (Fraternidade/Solidariedade): Direitos difusos e coletivos (meio ambiente equilibrado, paz, autodeterminação dos povos, progresso).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
1ª geração relaciona-se à liberdade (direitos civis/políticos), e não a direitos sociais.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
2ª geração relaciona-se à igualdade (direitos sociais), e não à solidariedade difusa.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Inverte a correspondência conceitual histórica das dimensões.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Direitos difusos pertencem à 3ª geração, e não à 1ª.

BIZU DE PROVA:
Gerações de Direitos Humanos (Lema da Revolução Francesa):
- 1ª Geração: LIBERDADE (Civis e Políticos - Estado Absenteísta);
- 2ª Geração: IGUALDADE (Sociais, Econômicos e Culturais - Estado Prestacional);
- 3ª Geração: FRATERNIDADE (Difusos e Coletivos - Meio Ambiente, Paz).$OLDQ126$),
(127, '6b0838e5431521929e9cb9f996b96d22', '86f0ecfd05d40b1eb10bc906f741a5a5', 'e4ed2b0789471d6dba7246aa922e4352', $OLDQ127$GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
A UNIVERSALIDADE é a característica basilar dos direitos humanos segundo a qual toda e qualquer pessoa humana, independentemente de nacionalidade, etnia, gênero, orientação, crença ou classe social, é titular dos direitos humanos universais, decorrendo da dignidade intrínseca a todo indivíduo.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A renunciabilidade absoluta não é característica dos direitos humanos (são IRRENUNCIÁVEIS).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A alienabilidade é rejeitada pela doutrina (são INALIENÁVEIS e indisponíveis).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A prescritibilidade não se aplica (os direitos humanos fundamentais são IMPRESCRITÍVEIS).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A seletividade estrita contraria o princípio fundamental da universalidade.

BIZU DE PROVA:
Características dos Direitos Humanos:
- Universalidade (pertencem a todos);
- Inerência (nascem com a pessoa);
- Imprescritibilidade (não se perdem com o tempo);
- Inalienabilidade (não se vendem/transferem);
- Irrenunciabilidade (não se pode abrir mão);
- Indivisibilidade e Interdependência.$OLDQ127$),
(128, 'f77afc44704c77e183c2a76ba3e0a31f', '5e6b14a86fa0fab2f314083de15ee359', 'b159fdc707cfc67cf4cbbe405186d198', $OLDQ128$GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
O Pacto Internacional sobre Direitos Civis e Políticos (PIDCP/ONU, 1966, promulgado no Brasil pelo Decreto nº 592/1992) consagra direitos de primeira dimensão (liberdades clássicas), tais como: o direito à vida, à integridade física, a não ser submetido à tortura ou escravidão, a liberdade de pensamento, consciência, religião, reunião pacífica e a participação política através do sufrágio.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O PIDCP protege os direitos civis e políticos, e não relações meramente mercantis.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não trata de tarifas aduaneiras ou barreiras alfandegárias.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Direitos sindicais e previdenciários foram tratados precipuamente no Pacto Internacional dos Direitos Econômicos, Sociais e Culturais (PIDESC).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não se destina a regulamentar aviação civil ou telecomunicações comerciais.

BIZU DE PROVA:
Pactos de Nova York (1966) - A DUDH dividida em 2 tratados vinculantes:
1. PIDCP: Direitos Civis e Políticos (1ª geração - eficácia imediata).
2. PIDESC: Direitos Econômicos, Sociais e Culturais (2ª geração - realização progressiva).$OLDQ128$),
(138, '4d107458e2fcab373db1a3bf99726e9d', '7cd27773cc39edcf999224798bf54eea', '6e785a54703f6d33b600868e70eff139', $OLDQ138$GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Nos termos do Artigo 5º, §3º, da Constituição Federal de 1988 (incluído pela Emenda Constitucional nº 45/2004), os tratados e convenções internacionais sobre direitos humanos que forem aprovados, em cada Casa do Congresso Nacional (Câmara dos Deputados e Senado Federal), em dois turnos, por três quintos dos votos dos respectivos membros, serão equivalentes às EMENDAS CONSTITUCIONAIS.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não equivalem a leis ordinárias (que exigem maioria simples).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não possuem hierarquia de leis complementares.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não equivalem a decretos regulamentares.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O quórum qualificado confere status de emenda constitucional, e não mera resolução.

BIZU DE PROVA:
Rito Especial do Art. 5º, §3º da CF/88 (Regra do 2-2-3/5):
- 2 Casas (Câmara e Senado);
- 2 Turnos de votação em cada casa;
- 3/5 dos votos dos membros.
Aprovado nesse rito = STATUS DE EMENDA CONSTITUCIONAL!$OLDQ138$),
(140, 'ceac5f1921e8da83582f0dd08609bfc7', 'c9ef0280a016614c6f5df454fb78b937', '655ff889975c8fb150359807f52df0e9', $OLDQ140$GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
As Regras Mínimas das Nações Unidas para o Tratamento de Presos (Regras de Nelson Mandela, atualizadas pela ONU em 2015) estabelecem padrões internacionais fundamentais para garantir a dignidade humana no sistema penitenciário, prescrevendo que todos os presos devem ser tratados com o respeito devido à sua dignidade e valor inerentes como seres humanos, proibindo absolutamente a tortura, tratamentos cruéis, desumanos ou degradantes.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
As Regras de Mandela proíbem expressamente penas corporais e castigos cruéis ou degradantes.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
As regras exigem acomodação salubre, alimentação adequada, higiene e assistência médica aos custodiados.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Garantem expressamente o contato do preso com o mundo exterior (visitas de familiares e correspondência).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Asseguram o direito à assistência religiosa e a não sofrer discriminação.

BIZU DE PROVA:
Regras de Mandela (ONU):
- Regra 1: Todos os presos devem ser tratados com respeito à sua DIGNIDADE inerente.
- Vedação absoluta de tortura e castigos corporais.
- Acomodação condigna, higiene, saúde e reintegração social.$OLDQ140$),
(141, '0084398dd8b0a96791f50783b87b6d48', 'd7ca63b9d0576d1c40981309d38cf7c2', 'd44b343658fc2196d3249ecd30ce2c45', $OLDQ141$GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
A Convenção sobre os Direitos das Pessoas com Deficiência (CDPD/ONU, 2006, promulgada pelo Decreto nº 6.949/2009 com equivalência de Emenda Constitucional) adota o MODELO SOCIAL da deficiência, definindo pessoas com deficiência como aquelas que têm impedimentos de longo prazo de natureza física, mental, intelectual ou sensorial, os quais, em interação com diversas barreiras, podem obstruir sua participação plena e efetiva na sociedade em igualdade de condições com as demais pessoas.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A deficiência não é vista como mera doença médica, mas pela interação entre impedimentos e barreiras sociais.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A Convenção visa garantir a inclusão e acessibilidade, repudiando a segregação ou exclusão.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A Convenção assegura plena capacidade civil e igualdade perante a lei (Artigo 12).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Acessibilidade e desenho universal são princípios estruturantes da CDPD.

BIZU DE PROVA:
Conceito Biopsicossocial da Deficiência (CDPD e Estatuto da PcD):
Deficiência = Impedimento de longo prazo (físico/mental/sensorial) + BARREIRAS do meio social.$OLDQ141$),
(144, '1b2e7240e6daae50d2e1e62441b679a6', 'e38a5a241cf1120466282b49f0cca696', '87e687197e7ea8cc3572e9dd3d5cca45', $OLDQ144$GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A Convenção sobre os Direitos da Criança (ONU, 1989, promulgada no Brasil pelo Decreto nº 99.710/1990) e o Artigo 227 da CF/88 consagram a DOUTRINA DA PROTEÇÃO INTEGRAL e o Princípio do Melhor Interesse da Criança, reconhecendo crianças e adolescentes como sujeitos plenos de direitos que gozam de prioridade absoluta em todas as ações concernentes a eles conduzidas por instituições públicas ou privadas.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Crianças e adolescentes não são objetos de tutela patrimonial, mas sujeitos de direitos fundamentais.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A doutrina da situação irregular foi superada pela doutrina da proteção integral da Convenção e do ECA.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A proteção integral abrange todas as crianças e adolescentes sem qualquer discriminação.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O dever de proteção é compartilhado entre Família, Sociedade e Estado (Art. 227 da CF/88).

BIZU DE PROVA:
Doutrina da Proteção Integral (Art. 227 da CF/88 e Convenção da ONU):
Crianças e adolescentes são SUJEITOS DE DIREITOS, pessoas em desenvolvimento e titulares de PRIORIDADE ABSOLUTA!$OLDQ144$),
(145, '8f27e9084a165d173b4be6ae78950d58', '1a7792f83c7365045268001e2986b5ef', 'c44a50d704a33e165a563a7fffb34389', $OLDQ145$GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
A Convenção Americana sobre Direitos Humanos (Pacto de San José da Costa Rica de 1969, promulgada no Brasil pelo Decreto nº 678/1992), em seu Artigo 7º, item 7, veda a prisão civil por dívida, ressalvando unicamente a hipótese do devedor de obrigação alimentar. Essa norma ensejou a edição da Súmula Vinculante nº 25 do STF, que declarou ilícita a prisão civil do depositário infiel.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A Convenção Americana não autoriza a prisão civil por qualquer modalidade de dívida contratual.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A prisão do depositário infiel foi considerada ilícita pelo STF em virtude do status supralegal do Pacto de San José.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A Convenção não extinguiu a prisão alimentar, que permanece plenamente válida (Art. 7.7).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O Pacto de San José não trata de prisão administrativa para cobrança de tributos.

BIZU DE PROVA:
Súmula Vinculante nº 25 do STF:
"É ilícita a prisão civil de depositário infiel, qualquer que seja a modalidade do depósito."
Única prisão civil admitida no Brasil: Devedor inescusável de pensão ALIMENTÍCIA!$OLDQ145$),
(146, '74aa28c6dd2a536d11187e7c95bbf277', '28d83622b533f7073276bdbdb3b6d81c', '2a33959679786dbe840427f33e3a796e', $OLDQ146$GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
O Direito Internacional Humanitário (DIH / Direito da Guerra ou de Haia e Genebra), consubstanciado principalmente nas quatro Convenções de Genebra de 1949 e seus Protocolos Adicionais, tem por escopo limitar os efeitos dos conflitos armados por razões humanitárias, protegendo as pessoas que não participam ou deixaram de participar das hostilidades (feridos, enfermos, náufragos, prisioneiros de guerra e população civil) e restringindo os meios e métodos de combate.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O DIH aplica-se especificamente durante conflitos armados (internacionais ou não internacionais).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O DIH não autoriza ataques indiscriminados contra a população civil (proíbe-os veementemente).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Ataques a hospitais, ambulâncias e pessoal de socorro são crimes de guerra graves.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O uso de armas que causem sofrimento desnecessário ou danos supérfluos é expressamente vedado.

BIZU DE PROVA:
Direito Internacional Humanitário (DIH):
- Aplicação: Conflitos Armados (Jus in Bello).
- Princípios: Distinção (alvos militares vs civis), Proporcionalidade, Humanidade e Precaução.$OLDQ146$),
(342, '627a793f408fa0c7491f0a5da529478c', 'bf912e0a2d5521a6a74c708994026077', '226a3f97a81f4f0eaa4d59d8b8d5a00b', $OLDQ342$GABARITO: alternativa C

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
5. MOral.$OLDQ342$),
(343, '528a18ca9762feb92875e489a77dae02', '507e7a003fe7bd60e2232ad06f6b6608', '2cf2fba94e23ad368f475063e7f02fc3', $OLDQ343$GABARITO: alternativa E

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
3. Finalidade da pena: REABILITAÇÃO e readaptação social dos condenados!$OLDQ343$),
(349, 'a9eed6ad960d50b89711a337dc59ac80', '894deb7adf634d43830deb7f51dc2efb', 'c232c92d797e12a6bbb66f09d6589b5b', $OLDQ349$GABARITO: alternativa D

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
- Ações afirmativas para equidade em saúde, educação e trabalho.$OLDQ349$),
(812, '0eae236e764acaf756cd342d70db775a', '8fd03204544594e0f3f50b0040c548a5', 'e7955bf33cae5be87af33fb7013e10c5', $OLDQ812$GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
Estão corretas apenas as assertivas I e II:
- Item I (Correto): A valorização da cultura e participação social da população negra são objetivos do Estatuto (Lei nº 12.288/2010).
- Item II (Correto): O fortalecimento de políticas públicas e ações afirmativas é diretriz expressa da lei.
- Item III (Incorreto): A assertiva extrapola o texto legal ao impor restrições incompatíveis com os direitos fundamentais.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Incompleta, pois o item II também está correto.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Incorreta na delimitação das diretrizes normativas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O item III não está correto.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O item III invalida a alternativa.

BIZU DE PROVA:
Estatuto da Igualdade Racial:
Diretrizes pautadas na inclusão social, ações afirmativas e reparação de desigualdades históricas.$OLDQ812$),
(351, 'ce34bb5e290fed8d63e14e6af7845d06', '092a6d193dad1898dc28aaee29597478', '780daad14352ffb05743e2691a2949e6', $OLDQ351$GABARITO: alternativa 2 (a segunda das cinco alternativas)

POR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:
Reproduz o Art. 7º, §3º, da Convenção Internacional sobre os Direitos das Pessoas com Deficiência (Decreto nº 6.949/2009, com status de emenda constitucional pelo rito do art. 5º, §3º, da CF): os Estados Partes assegurarão que as crianças com deficiência tenham o direito de expressar livremente sua opinião sobre todos os assuntos que lhes disserem respeito, tenham essa opinião devidamente valorizada de acordo com sua idade e maturidade, em igualdade de oportunidades com as demais crianças, e recebam atendimento adequado à sua deficiência e idade para que possam exercer tal direito.

POR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:
Alternativa 1: descreve, na verdade, a definição de ADAPTAÇÃO RAZOÁVEL (Art. 2º da Convenção) — as modificações e ajustes necessários e adequados, sem ônus desproporcional, para assegurar às pessoas com deficiência o gozo dos direitos humanos em igualdade de condições. DESENHO UNIVERSAL é conceito distinto: concepção de produtos, ambientes, programas e serviços a serem usados por todos, na maior medida possível, sem necessidade de adaptação ou projeto específico.
Alternativa 3: a acessibilidade é, sim, um dos princípios gerais da Convenção, previsto expressamente no Art. 3º, alínea "f".
Alternativa 4: o Art. 5º, §4º, da Convenção estabelece o oposto — as medidas específicas necessárias para acelerar ou alcançar a efetiva igualdade das pessoas com deficiência NÃO serão consideradas discriminatórias, ou seja, são expressamente permitidas, não vedadas.
Alternativa 5: a definição de "discriminação por motivo de deficiência" (Art. 2º) abrange todas as formas de discriminação, INCLUSIVE a recusa de adaptação razoável — e não a excetua, como afirma a alternativa.

BIZU DE PROVA:
Memorize o par de conceitos que a banca gosta de trocar: ADAPTAÇÃO RAZOÁVEL (ajuste sob medida, caso a caso) × DESENHO UNIVERSAL (concepção já acessível a todos, sem necessidade de ajuste posterior). E lembre-se: a Convenção sempre trata medidas afirmativas e a recusa de adaptação razoável como favoráveis à inclusão das pessoas com deficiência — nunca como proibidas ou excluídas do conceito de discriminação.$OLDQ351$);

do $$
declare
  v_staging int; v_bad_md5 int; v_bad_fp int;
begin
  select count(*) into v_staging from _revert_dh_global;
  if v_staging <> 20 then raise exception 'ABORTADO: staging de reversao com % linhas, esperado 20', v_staging; end if;

  with atual as (
    select q.id,
      md5(coalesce(q.explicacao,'')) as cur_md5,
      md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.materia_id::text, q.assunto_id::text,
      coalesce(q.banca,''), coalesce(q.concurso,''), q.ano::text,
      (select string_agg(up.id::text, ',' order by up.id) from public.questao_unidades_pedagogicas qup2 join public.unidades_pedagogicas up on up.id = qup2.unidade_pedagogica_id where qup2.questao_id = q.id),
      (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)
    )) as cur_fp
    from public.questoes q
    where q.id in (select questao_id from _revert_dh_global)
  )
  select count(*) filter (where atual.cur_md5 <> l.new_md5_esperado),
         count(*) filter (where atual.cur_fp  <> l.fingerprint_esperado)
    into v_bad_md5, v_bad_fp
  from _revert_dh_global l join atual on atual.id = l.questao_id;

  if v_bad_md5 <> 0 then
    raise exception 'ABORTADO: % questao(oes) nao estao no estado NEW esperado (ja revertidas ou alteradas por outro processo) — nao sobrescrever estado divergente', v_bad_md5;
  end if;
  if v_bad_fp <> 0 then
    raise exception 'ABORTADO: % questao(oes) com FINGERPRINT_IMUTAVEL divergente antes da reversao', v_bad_fp;
  end if;

  raise notice 'GUARD PRE-REVERSAO OK: 20/20 NEW_MD5, 20/20 FINGERPRINT_IMUTAVEL';
end $$;

do $$
declare
  v_rows int;
begin
  update public.questoes q
  set explicacao = l.explicacao_old
  from _revert_dh_global l
  where q.id = l.questao_id;

  get diagnostics v_rows = row_count;
  if v_rows <> 20 then
    raise exception 'REVERSAO afetou % linha(s), esperado exatamente 20 — abortando', v_rows;
  end if;
  raise notice 'REVERSAO aplicada: % linha(s) restaurada(s) ao texto OLD', v_rows;
end $$;

do $$
declare
  v_bad_md5 int; v_bad_fp int;
begin
  with atual as (
    select q.id,
      md5(coalesce(q.explicacao,'')) as cur_md5,
      md5(concat_ws('|', q.id::text, q.enunciado, q.dificuldade, q.materia_id::text, q.assunto_id::text,
      coalesce(q.banca,''), coalesce(q.concurso,''), q.ano::text,
      (select string_agg(up.id::text, ',' order by up.id) from public.questao_unidades_pedagogicas qup2 join public.unidades_pedagogicas up on up.id = qup2.unidade_pedagogica_id where qup2.questao_id = q.id),
      (select string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '||' order by a.ordem) from public.alternativas a where a.questao_id = q.id)
    )) as cur_fp
    from public.questoes q
    where q.id in (select questao_id from _revert_dh_global)
  )
  select count(*) filter (where atual.cur_md5 <> l.old_md5_esperado),
         count(*) filter (where atual.cur_fp  <> l.fingerprint_esperado)
    into v_bad_md5, v_bad_fp
  from _revert_dh_global l join atual on atual.id = l.questao_id;

  if v_bad_md5 <> 0 then raise exception 'POS-REVERSAO: % questao(oes) nao bateram com OLD_MD5', v_bad_md5; end if;
  if v_bad_fp  <> 0 then raise exception 'POS-REVERSAO: FINGERPRINT_IMUTAVEL nao preservado em % questao(oes)', v_bad_fp; end if;

  raise notice 'POS-REVERSAO OK: 20/20 OLD_MD5 restaurado, 20/20 FINGERPRINT_IMUTAVEL preservado';
end $$;

commit;
