import fs from 'fs';

// Vamos montar as 50 explicações com alto rigor técnico e jurídico
const explicacoes = [
  {
    id: 13,
    explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A Declaração Universal dos Direitos Humanos (DUDH), adotada em 10 de dezembro de 1948 pela Assembleia Geral da ONU (Resolução 217 A III), estabelece expressamente em seu Artigo 1º que "todos os seres humanos nascem livres e iguais em dignidade e em direitos. Dotados de razão e de consciência, devem agir uns para com os outros em espírito de fraternidade". A dignidade da pessoa humana é a matriz axiológica e o postulado central de todo o sistema internacional de proteção dos direitos humanos.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A DUDH é um documento universal voltado à proteção de todos os seres humanos, e não restrito a agentes públicos ou servidores do Estado.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Os direitos humanos caracterizam-se pela inalienabilidade e irrenunciabilidade, não podendo ser comercializados ou transferidos entre particulares.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A DUDH possui aplicação permanente e universal, incidindo tanto em tempos de paz quanto em quaisquer contextos de convivência civilizatória.

BIZU DE PROVA:
DUDH (1948) - Artigo 1º:
"Todos os seres humanos nascem LIVRES e IGUAIS em DIGNIDADE e DIREITOS."
Tríade iluminista: Liberdade, Igualdade e Fraternidade!`
  },
  {
    id: 28,
    explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A Declaração Universal dos Direitos Humanos (DUDH) foi proclamada e adotada pela Assembleia Geral da Organização das Nações Unidas (ONU) em Paris, no dia 10 de dezembro de 1948 (em resposta às atrocidades cometidas durante a Segunda Guerra Mundial), estabelecendo pela primeira vez os direitos humanos fundamentais a serem universalmente protegidos.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A DUDH não foi criada pela União Europeia (que surgiu décadas depois).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A DUDH não foi formulada pela Organização Mundial do Comércio (OMC).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A DUDH não é um tratado exclusivo do Mercosul, mas uma declaração universal da ONU.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A DUDH não foi instituída pela OTAN (que é uma aliança militar regional).

BIZU DE PROVA:
Marco Histórico da DUDH:
- Proclamada em: 10 de dezembro de 1948.
- Órgão: Assembleia Geral da ONU.
- Contexto: Pós-Segunda Guerra Mundial (1939-1945).`
  },
  {
    id: 29,
    explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 1º da DUDH/1948 consagra os ideais de liberdade, igualdade e fraternidade ao prescrever: "Todos os seres humanos nascem livres e iguais em dignidade e em direitos. Dotados de razão e de consciência, devem agir uns para com os outros em espírito de fraternidade."

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A DUDH não prevê hierarquia de superioridade entre seres humanos; consagra a igualdade absoluta em dignidade.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A proteção aos direitos humanos independe de nacionalidade, classe social, gênero ou vínculo funcional.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Os direitos humanos são universais e inalienáveis, não sendo passíveis de renúncia tácita.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A DUDH não condiciona a dignidade humana à aprovação de leis municipais.

BIZU DE PROVA:
Artigo 1º da DUDH:
Consagra expressamente:
1. Liberdade ("nascem livres");
2. Igualdade ("iguais em dignidade e direitos");
3. Fraternidade ("espírito de fraternidade").`
  },
  {
    id: 30,
    explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Os direitos humanos são prerrogativas fundamentais e universais intrínsecas a qualquer ser humano simplesmente por sua condição humana, destinadas a resguardar a dignidade, a integridade física, psíquica e moral, a liberdade e a justiça social perante o poder estatal e a coletividade.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Os direitos humanos não são privilégios corporativos de governantes ou autoridades públicas.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Os direitos humanos não se destinam à proteção de bens de empresas comerciais.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não se trata de privilégio financeiro de arrecadação fiscal.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não são prerrogativas militares ou de forças de segurança exclusivas.

BIZU DE PROVA:
Conceito de Direitos Humanos:
São direitos essenciais para uma vida digna, universais, imprescritíveis, inalienáveis e irrenunciáveis, titularizados por todos os seres humanos sem distinção.`
  },
  {
    id: 55,
    explicacao: `GABARITO: alternativa A

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
A titularidade dos direitos da DUDH é UNIVERSAL: veda-se distinção de raça, cor, sexo, língua, religião, opinião política, origem nacional, riqueza ou qualquer outra condição!`
  },
  {
    id: 56,
    explicacao: `GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A Convenção Americana sobre Direitos Humanos (Pacto de San José da Costa Rica, 1969), em seu Artigo 4º, item 1, consagra: "Toda pessoa tem o direito de que se respeite sua vida. Esse direito deve ser protegido pela lei e, em geral, desde o momento da concepção. Ninguém pode ser privado da vida arbitrariamente."

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
O direito à vida é a base primordial de todos os direitos civis na Convenção Americana.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A Convenção estabelece severas restrições e proíbe o restabelecimento da pena de morte nos Estados que a aboliram (Art. 4º, 3).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A privação arbitrária da vida é peremptoriamente vedada no Pacto de San José.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A proteção da vida é assegurada expressamente pela norma internacional.

BIZU DE PROVA:
Artigo 4º do Pacto de San José da Costa Rica:
Proteção do direito à vida:
- Em regra, "desde o momento da concepção";
- Proibição da privação arbitrária da vida;
- Vedação à aplicação de pena de morte a menores de 18 anos, maiores de 70 anos e mulheres grávidas.`
  },
  {
    id: 57,
    explicacao: `GABARITO: alternativa D

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
A proibição da tortura e do tratamento desumano/degradante é norma cogente internacional (jus cogens). NÃO admite exceção, relativização ou ponderação em hipótese alguma!`
  },
  {
    id: 58,
    explicacao: `GABARITO: alternativa B

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
A adoção de medidas especiais de caráter temporário destinadas a acelerar a igualdade de fato entre o homem e a mulher NÃO é considerada discriminação (Art. 4º, 1, da CEDAW).`
  },
  {
    id: 59,
    explicacao: `GABARITO: alternativa E

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
Mnemônico: "G-C-G-A" (Guerra, Crimes contra humanidade, Genocídio, Agressão).`
  },
  {
    id: 124,
    explicacao: `GABARITO: alternativa B

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
"As normas definidoras dos direitos e garantias fundamentais têm APLICAÇÃO IMEDIATA."`
  },
  {
    id: 125,
    explicacao: `GABARITO: alternativa A

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
- PLUralismo político.`
  },
  {
    id: 126,
    explicacao: `GABARITO: alternativa C

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
- 3ª Geração: FRATERNIDADE (Difusos e Coletivos - Meio Ambiente, Paz).`
  },
  {
    id: 127,
    explicacao: `GABARITO: alternativa D

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
- Indivisibilidade e Interdependência.`
  },
  {
    id: 128,
    explicacao: `GABARITO: alternativa C

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
2. PIDESC: Direitos Econômicos, Sociais e Culturais (2ª geração - realização progressiva).`
  },
  {
    id: 130,
    explicacao: `GABARITO: alternativa B

POR QUE A ALTERNATIVA B ESTÁ CORRETA:
No Sistema Interamericano de Direitos Humanos (OEA), a COMISSÃO Interamericana de Direitos Humanos (CIDH, sediada em Washington) e a CORTE Interamericana de Direitos Humanos (Corte IDH, sediada em San José da Costa Rica) são os dois órgãos principais de proteção e promoção dos direitos humanos nas Américas. Indivíduos e ONGs podem apresentar petições à Comissão, que após exame pode submeter o caso à jurisdição contenciosa da Corte.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
Indivíduos não acionam diretamente a Corte Interamericana; o acesso à Corte é feito exclusivamente pelos Estados-partes ou pela Comissão Interamericana.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A Corte IDH é um tribunal internacional autônomo, não vinculado ao Poder Executivo brasileiro.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
As decisões de mérito da Corte IDH possuem caráter obrigatório e vinculante para o Estado que aceitou sua jurisdição (Art. 68.1 da CADH).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A Comissão não julga crimes comuns de particulares, mas analisa a responsabilidade internacional do Estado.

BIZU DE PROVA:
Acesso ao Sistema Interamericano:
- Vítima / ONG -> peticiona perante a COMISSÃO Interamericana (CIDH - Washington).
- COMISSÃO / Estado -> submete o caso à CORTE Interamericana (Corte IDH - San José).`
  },
  {
    id: 131,
    explicacao: `GABARITO: alternativa D

POR QUE A ALTERNATIVA D ESTÁ CORRETA:
A Declaração Universal dos Direitos Humanos de 1948 inovou historicamente ao consagrar no mesmo texto tanto os direitos civis e políticos (arts. 3º ao 21) quanto os direitos econômicos, sociais e culturais (arts. 22 ao 27), tais como: direito à previdência social (art. 22), ao trabalho e repouso (arts. 23 e 24), a um padrão de vida adequado e saúde (art. 25), e à EDUCAÇÃO gratuita nos graus elementares (art. 26).

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A DUDH protege expressamente os direitos sociais (arts. 22 a 27), não se restringindo aos direitos civis.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O direito à educação é expressamente assegurado no Artigo 26 da DUDH.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A saúde e o bem-estar integram o padrão de vida digno do Artigo 25.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A DUDH prevê direitos sociais e trabalhistas fundamentais.

BIZU DE PROVA:
Estrutura da DUDH (30 Artigos):
- Arts. 1º e 2º: Princípios da Dignidade, Liberdade, Igualdade e Não Discriminação;
- Arts. 3º a 21: Direitos Civis e Políticos (1ª dimensão);
- Arts. 22 a 27: Direitos Econômicos, Sociais e Culturais (2ª dimensão);
- Arts. 28 a 30: Deveres e Ordem Internacional.`
  },
  {
    id: 138,
    explicacao: `GABARITO: alternativa A

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
Aprovado nesse rito = STATUS DE EMENDA CONSTITUCIONAL!`
  },
  {
    id: 139,
    explicacao: `GABARITO: alternativa C

POR QUE A ALTERNATIVA C ESTÁ CORRETA:
A Convenção Interamericana contra o Racismo, a Discriminação Racial e Formas Correlatas de Intolerância (adotada pela OEA em 2013 e promulgada no Brasil pelo Decreto nº 10.932/2022, após aprovação pelo rito do art. 5º, §3º da CF/88) possui status de EMENDA CONSTITUCIONAL e compromete o Estado brasileiro a prevenir, eliminar e punir todos os atos e manifestações de racismo e discriminação racial.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A Convenção visa combater e erradicar o racismo, e não legitimá-lo.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O Brasil ratificou expressamente o tratado, que ingressou com hierarquia constitucional.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não se trata de mero tratado econômico, mas de direitos humanos.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O combate ao racismo é compromisso central e imprescritível no direito brasileiro (Art. 5º, XLII, CF).

BIZU DE PROVA:
Tratados de Direitos Humanos com Status de Emenda Constitucional no Brasil:
1. Convenção sobre os Direitos das Pessoas com Deficiência e seu Protocolo Facultativo (Dec. 6.949/2009);
2. Tratado de Marraqueche (Dec. 9.522/2018);
3. Convenção Interamericana contra o Racismo (Dec. 10.932/2022).`
  },
  {
    id: 140,
    explicacao: `GABARITO: alternativa B

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
- Acomodação condigna, higiene, saúde e reintegração social.`
  },
  {
    id: 141,
    explicacao: `GABARITO: alternativa E

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
Deficiência = Impedimento de longo prazo (físico/mental/sensorial) + BARREIRAS do meio social.`
  },
  {
    id: 144,
    explicacao: `GABARITO: alternativa B

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
Crianças e adolescentes são SUJEITOS DE DIREITOS, pessoas em desenvolvimento e titulares de PRIORIDADE ABSOLUTA!`
  },
  {
    id: 145,
    explicacao: `GABARITO: alternativa B

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
Única prisão civil admitida no Brasil: Devedor inescusável de pensão ALIMENTÍCIA!`
  },
  {
    id: 146,
    explicacao: `GABARITO: alternativa E

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
- Princípios: Distinção (alvos militares vs civis), Proporcionalidade, Humanidade e Precaução.`
  },
  {
    id: 147,
    explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A Declaração Universal dos Direitos Humanos de 1948 consagra formalmente em seu preâmbulo e no Artigo 1º que o reconhecimento da DIGNIDADE INERENTE a todos os membros da família humana e de seus direitos iguais e inalienáveis é o fundamento da liberdade, da justiça e da paz no mundo.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A dignidade não depende de titulação nobiliárquica, classe social ou poder econômico.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A dignidade humana é inerente a qualquer ser humano, sem distinção de nacionalidade.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A dignidade é irrenunciável e não se perde por vontade individual.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A proteção é permanente em qualquer território.

BIZU DE PROVA:
Dignidade da Pessoa Humana na DUDH:
É valor axiológico UNIVERSAL e INERENTE: todo indivíduo possui dignidade pelo simples fato de existir como pessoa humana!`
  },
  {
    id: 148,
    explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A DUDH é uma declaração formal de direitos universais adotada pela Assembleia Geral da ONU, instituindo os princípios e normas ético-jurídicas internacionais indispensáveis para salvaguardar a vida, a liberdade e a dignidade humana em todas as nações.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A DUDH não é um tratado militar de defesa mútua.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não é um acordo de comércio tarifário.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não é um estatuto bancário internacional.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não se restringe a matérias aduaneiras ou fiscais.

BIZU DE PROVA:
Natureza da DUDH (1948):
Embora originariamente aprovada sob a forma de Resolução da Assembleia Geral da ONU, hoje é reconhecida como norma consuetudinária internacional de valor universal (Jus Cogens).`
  },
  {
    id: 149,
    explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A Convenção Americana sobre Direitos Humanos (Pacto de San José da Costa Rica, 1969) integra o SISTEMA REGIONAL INTERAMERICANO de proteção aos direitos humanos, adotada no âmbito da Organização dos Estados Americanos (OEA).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não integra o sistema europeu (que possui a Convenção Europeia de Direitos Humanos).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não integra o sistema africano (Carta Africana dos Direitos do Homem e dos Povos).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não é um tratado privativo do sistema asiático.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Embora dialogue com o sistema global da ONU, a CADH é a espinha dorsal do Sistema Interamericano (OEA).

BIZU DE PROVA:
Sistemas de Proteção dos Direitos Humanos:
- Sistema Global: ONU (DUDH, PIDCP, PIDESC).
- Sistemas Regionais:
  1. Interamericano (OEA / Pacto de San José);
  2. Europeu (Conselho da Europa);
  3. Africano (União Africana).`
  },
  {
    id: 150,
    explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Pacto de San José da Costa Rica (CADH/1969) estabelece como seu objetivo central a consolidação de um regime de liberdade pessoal e justiça social nas Américas, fundado no respeito aos direitos humanos essenciais da pessoa, vinculando os Estados-partes ao dever de respeitar e garantir tais direitos a todos sob sua jurisdição (Artigo 1.1).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não possui finalidade de regulação cambial ou monetária.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não visa criar alianças bélicas de ataque.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não disciplina competências tributárias internas dos Estados.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não se restringe ao comércio interestadual.

BIZU DE PROVA:
Art. 1.1 da CADH:
Os Estados-partes comprometem-se a respeitar os direitos reconhecidos na Convenção e a garantir seu livre e pleno exercício a toda pessoa que esteja sujeita à sua jurisdição, sem discriminação.`
  },
  {
    id: 151,
    explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Nos termos do Artigo 41 e seguintes da Convenção Americana sobre Direitos Humanos, a principal função da COMISSÃO Interamericana de Direitos Humanos (CIDH) é estimular a observância e a defesa dos direitos humanos nas Américas, tendo como competência receber, analisar e investigar petições e comunicações de indivíduos ou ONGs que contenham denúncias ou queixas de violação da Convenção por um Estado-parte.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A Comissão não possui competência criminal para condenar indivíduos (responsabilidade penal individual é do TPI ou da justiça interna).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não possui atribuição legislativa para editar constituições nacionais.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Atua sob o princípio da subsidiariedade/complementaridade, não substituindo o Poder Judiciário nacional.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não cria tributos ou encargos fiscais.

BIZU DE PROVA:
Função da Comissão Interamericana (CIDH):
- Órgão quase-judicial e investigativo;
- Recebe petições individuais de vítimas de violações de direitos humanos;
- Realiza recomendações, medidas cautelares e pode encaminhar o caso à Corte IDH.`
  },
  {
    id: 152,
    explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Conforme o Artigo 106 da Carta da OEA e o Artigo 41 da CADH, a Comissão Interamericana de Direitos Humanos é um órgão principal da OEA cuja função primordial é promover a observância, a conscientização e a defesa intransigente dos direitos humanos em todos os países do continente americano.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A CIDH não unifica e nem comanda corporações policiais nacionais.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não atua em política monetária ou criação de moedas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não exerce funções de controle de imigração ou patrulhamento de fronteiras.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não gere finanças ou políticas econômicas da OEA.

BIZU DE PROVA:
Mandato da CIDH:
Promover e defender os direitos humanos em TODAS as Américas (órgão da Carta da OEA e da Convenção Americana).`
  },
  {
    id: 153,
    explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A Convenção Interamericana para Prevenir, Punir e Erradicar a Violência contra a Mulher (Convenção de Belém do Pará, OEA, 1994, promulgada no Brasil pelo Decreto nº 1.973/1996) tem como propósito primordial e expresso assegurar o direito de toda mulher a uma vida livre de violência, estabelecendo obrigações aos Estados para prevenir, punir e erradicar a violência contra a mulher nas esferas pública e privada (servindo de alicerce para a Lei Maria da Penha).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não regula comércio ou contratos empresariais.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não trata de crimes fiscais ou tributários.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não institui moedas econômicas.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não versa sobre propriedade intelectual ou direitos autorais.

BIZU DE PROVA:
Convenção de Belém do Pará (1994):
- Objeto: Prevenir, Punir e Erradicar a Violência contra a Mulher.
- Inspirou diretamente a edição da Lei Maria da Penha (Lei nº 11.340/2006) no Brasil após a condenação internacional do país na CIDH (Caso Maria da Penha).`
  },
  {
    id: 154,
    explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Nos termos do Artigo 2º da Convenção de Belém do Pará, a violência contra a mulher inclui a violência física, sexual e psicológica que tenha ocorrido no âmbito da família ou unidade doméstica (âmbito privado), bem como na comunidade, no local de trabalho, instituições educacionais ou serviços de saúde, ou que seja perpetrada ou tolerada pelo Estado ou seus agentes, onde quer que ocorra (âmbito público).

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não se restringe à residência privada, ocorrendo também na comunidade e em espaços públicos.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não se limita ao ambiente corporativo ou de trabalho.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Abrange a violência cometida por particulares e por agentes estatais.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Aplica-se em tempos de paz e em qualquer contexto civil.

BIZU DE PROVA:
Âmbitos da Violência contra a Mulher (Art. 2º da Convenção de Belém do Pará):
1. Âmbito Doméstico / Familiar (privado);
2. Âmbito da Comunidade (trabalho, escola, vias públicas);
3. Praticada ou tolerada pelo ESTADO (âmbito público).`
  },
  {
    id: 155,
    explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A Convenção de Belém do Pará é um tratado de direitos humanos de âmbito regional adotado pela Assembleia Geral da Organização dos Estados Americanos (OEA), integrando formalmente o Sistema Interamericano de Proteção dos Direitos Humanos.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não integra o sistema europeu.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não faz parte do sistema regional africano.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
É um tratado da OEA (regional interamericano), não do sistema global da ONU.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não é estatuto do Tribunal Penal Internacional.

BIZU DE PROVA:
Convenção de Belém do Pará = SISTEMA INTERAMERICANO (OEA).
Adotada em Belém do Pará (Brasil) em 1994 no âmbito da Organização dos Estados Americanos.`
  },
  {
    id: 156,
    explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A Corte Interamericana de Direitos Humanos (Corte IDH) é uma instituição judicial internacional autônoma instituída pela Convenção Americana sobre Direitos Humanos (Art. 33, b, e Art. 52), cujo objetivo é a aplicação e interpretação da Convenção Americana no âmbito do Sistema Interamericano de Direitos Humanos.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A Corte IDH é um tribunal internacional, não integrando a estrutura do Poder Judiciário nacional brasileiro (art. 92 da CF/88).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não é comissão parlamentar do Poder Legislativo.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não faz parte da União Europeia (que possui o Tribunal Europeu de Direitos Humanos em Estrasburgo).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não é órgão do Mercosul.

BIZU DE PROVA:
Corte Interamericana de Direitos Humanos (Corte IDH):
- Tribunal judicial internacional do Sistema Interamericano (OEA);
- Sede: San José, Costa Rica;
- Composta por 7 juízes nacionais de Estados-membros da OEA.`
  },
  {
    id: 157,
    explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Conforme o Artigo 68, item 1, da Convenção Americana sobre Direitos Humanos, "os Estados-Partes na Convenção comprometem-se a cumprir a decisão da Corte em todo caso em que forem partes". As sentenças da Corte IDH proferidas no exercício de sua jurisdição contenciosa são definitivas, inapeláveis e vinculantes para o Estado condenado, que tem a obrigação jurídica internacional de executá-las de boa-fé.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
As sentenças contenciosas da Corte não são meras recomendações, mas decisões judiciais vinculantes.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
As sentenças condenam internacionalmente o Estado responsável pelas violações.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O cumprimento da decisão da Corte internacional independe de aprovação posterior do Congresso Nacional.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O Estado não pode invocar disposições de seu direito interno para justificar o descumprimento de obrigações internacionais (Art. 27 da Convenção de Viena sobre Direito dos Tratados).

BIZU DE PROVA:
Sentenças da Corte IDH (Art. 68 da CADH):
- Definitivas e Inapeláveis;
- Obrigatórias e VINCULANTES para o Estado condenado;
- Possuem eficácia de título executivo em relação a indenizações patrimoniais (Art. 68.2).`
  },
  {
    id: 158,
    explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A Corte Interamericana de Direitos Humanos (Corte IDH), conforme estabelecido no Artigo 52 e seguintes da Convenção Americana sobre Direitos Humanos e no Estatuto da Corte, tem sua sede permanente instalada na cidade de San José, capital da Costa Rica.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Em Washington, D.C. (EUA) fica a sede da Comissão Interamericana de Direitos Humanos (CIDH) e da OEA.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Em Nova York fica a sede principal da Organização das Nações Unidas (ONU).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Em Genebra (Suíça) fica o Conselho de Direitos Humanos da ONU e a sede europeia da ONU.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Em Montevidéu (Uruguai) fica a sede da Secretaria do Mercosul.

BIZU DE PROVA:
Sedes dos Órgãos do Sistema Interamericano:
- COMISSÃO Interamericana (CIDH): Washington, D.C. (Estados Unidos).
- CORTE Interamericana (Corte IDH): San José (Costa Rica).`
  },
  {
    id: 159,
    explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Nos termos expressos do Artigo 1º, inciso II, da Constituição Federal de 1988, a CIDADANIA constitui um dos cinco FUNDAMENTOS da República Federativa do Brasil, representando a consagração do cidadão como titular de direitos civis, políticos e sociais e participante ativo da vida do Estado.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A cidadania não é objetivo meramente econômico, mas postulado democrático e fundamento republicano.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A cidadania é fundamento da República como um todo, não competência restrita municipal.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
É direito e dever titularizado por toda a coletividade de cidadãos, não restrito a servidores.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Possui o mais elevado status constitucional originário (Art. 1º, II).

BIZU DE PROVA:
Art. 1º da CF/88 (Fundamentos da República):
I - a soberania;
II - a CIDADANIA;
III - a dignidade da pessoa humana;
IV - os valores sociais do trabalho e da livre iniciativa;
V - o pluralismo político.`
  },
  {
    id: 160,
    explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 14 da Constituição Federal de 1988 consagra que a soberania popular é exercida pelo sufrágio universal e pelo voto direto e secreto, com valor igual para todos, e, nos termos da lei, mediante os instrumentos de democracia semidireta:
I - plebiscito;
II - referendo;
III - iniciativa popular.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Mandado de injunção e habeas corpus são remédios constitucionais jurisdicionais de defesa de direitos, não instrumentos de democracia direta do art. 14.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Decretos, portarias e resoluções são atos normativos infralegais do Poder Executivo.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Licitações e convênios são procedimentos administrativos patrimoniais.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
O rol do art. 14 da CF elenca formalmente plebiscito, referendo e iniciativa popular.

BIZU DE PROVA:
Instrumentos de Soberania Popular (Art. 14, I a III, CF/88):
- Plebiscito (consulta prévia ao povo);
- Referendo (consulta posterior à aprovação de ato legislativo);
- Iniciativa Popular de Leis (apresentação de projeto de lei pelo povo com 1% do eleitorado nacional).`
  },
  {
    id: 161,
    explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O direito de sufrágio ativo (o direito de VOTAR), atendidas as condições de elegibilidade e alistamento previstas nos Artigos 14 e 15 da Constituição Federal, constitui o direito político por excelência e a expressão mais direta do exercício da cidadania e da soberania popular no Estado Democrático de Direito.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O cumprimento das ordens e decisões judiciais é dever de todo cidadão e exigência do Estado de Direito.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O dever fundamental de pagar tributos legalmente instituídos é inerente à cidadania e solidariedade social.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O acesso a cargos públicos depende de concurso público de provas ou de provas e títulos (art. 37, II, CF).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não existe imunidade penal absoluta na ordem jurídica republicana (todos são iguais perante a lei).

BIZU DE PROVA:
Direitos Políticos (Art. 14 da CF/88):
- Capacidade Eleitoral Ativa = Direito de VOTAR (Alistabilidade).
- Capacidade Eleitoral Passiva = Direito de SER VOTADO (Elegibilidade).`
  },
  {
    id: 162,
    explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
No âmbito do Mercosul (Mercado Comum do Sul), a proteção dos direitos humanos e o compromisso democrático foram formalmente incorporados ao processo de integração regional (conforme o Protocolo de Ushuaia sobre Compromisso Democrático de 1998 e o Protocolo de Assunção sobre Compromisso com a Promoção e Proteção dos Direitos Humanos de 2005), estabelecendo que a plena vigência das instituições democráticas e o respeito aos direitos humanos são condições essenciais para a integração dos Estados-partes.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A dimensão dos direitos humanos é elemento indispensável e reconhecido na integração regional do Mercosul.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O Mercosul não substitui os sistemas nacionais de justiça nem os tribunais dos países membros.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A proteção aos direitos humanos é promovida tanto em nível global (ONU) quanto em blocos e sistemas regionais (OEA, Mercosul).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Ao contrário, foi expressamente pactuada e promovida pelos Estados-membros.

BIZU DE PROVA:
Direitos Humanos no Mercosul:
A Cláusula Democrática (Protocolo de Ushuaia) e os Direitos Humanos (Protocolo de Assunção) são pilares fundamentais do bloco: a ruptura democrática acarreta a suspensão do Estado-membro no Mercosul!`
  },
  {
    id: 163,
    explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O compromisso com a democracia e com os direitos humanos no Mercosul visa consolidar a paz, o Estado de Direito, o desenvolvimento social e fortalecer os valores axiológicos essenciais que unem os povos dos Estados participantes no processo de integração sul-americana.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O Mercosul respeita a soberania e as Constituições nacionais dos Estados-membros.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não visa criar um código penal unificado obrigatório.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não tem a finalidade de substituir a Organização dos Estados Americanos (OEA).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não extingue os Poderes Judiciários dos países participantes.

BIZU DE PROVA:
Compromisso Democrático do Mercosul:
O objetivo primordial é a cooperação harmônica, estabilidade institucional e fortalecimento da cidadania regional e dos direitos fundamentais nos países membros.`
  },
  {
    id: 164,
    explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Os mecanismos e declarações de direitos humanos desenvolvidos no Mercosul atuam de forma COMPLEMENTAR e harmônica em relação às ordens constitucionais internas dos Estados-membros e aos tratados internacionais de proteção do Sistema Interamericano (OEA) e Global (ONU), somando esforços na salvaguarda da dignidade humana.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Não revoga nem substitui os tratados universais da ONU.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
É plenamente compatível e cooperativo com o Sistema Interamericano de Direitos Humanos.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
O Mercosul ultrapassou a dimensão meramente comercial, alcançando aspectos sociais, educacionais e de direitos humanos.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Aplica-se à proteção de todos os cidadãos e pessoas sob a jurisdição dos Estados participantes.

BIZU DE PROVA:
Princípio da Complementaridade dos Sistemas de Direitos Humanos:
As normas internacionais e regionais de direitos humanos SOMAM-SE (princípio pro homine / pro persona): prevalece sempre a norma mais favorável à vítima da violação!`
  },
  {
    id: 165,
    explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Artigo 5º, §3º, da Constituição Federal estabelece: "Os tratados e convenções internacionais sobre direitos humanos que forem aprovados, em cada Casa do Congresso Nacional, em dois turnos, por três quintos dos votos dos respectivos membros, serão equivalentes às EMENDAS CONSTITUCIONAIS."

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Leis ordinárias exigem quórum de maioria simples (art. 47 da CF).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Decretos municipais são atos infralegais do Poder Executivo local.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Medidas provisórias são atos normativos primários com força de lei expedidos pelo Presidente da República.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Resoluções administrativas não possuem status constitucional.

BIZU DE PROVA:
Hierarquia dos Tratados de Direitos Humanos na CF/88:
- Aprovados pelo rito do art. 5º, §3º (2 casas, 2 turnos, 3/5) = STATUS CONSTITUCIONAL (Emenda Constitucional).
- Aprovados pelo rito comum (maioria simples) = STATUS SUPRALEGAL (acima das leis, abaixo da CF - RE 466.343/STF).`
  },
  {
    id: 166,
    explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Conforme jurisprudência pacificada e histórica do Supremo Tribunal Federal (leading case RE 466.343/SP, Rel. Min. Cezar Peluso, julgado em 2008), os tratados internacionais de direitos humanos ratificados e incorporados pelo Brasil pelo rito ordinário comum (sem o procedimento do art. 5º, §3º da CF) possuem STATUS SUPRALEGAL: situam-se abaixo da Constituição Federal, porém ACIMA de toda a legislação ordinária interna, gerando a paralisia da eficácia de quaisquer leis infraconstitucionais com eles incompatíveis.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O status de emenda constitucional exige a aprovação estrita pelo quórum qualificado do art. 5º, §3º da CF.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Estão acima de todas as leis e decretos internos.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não possuem status de lei municipal.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Possuem plena vigência e eficácia jurídica interna no ordenamento brasileiro.

BIZU DE PROVA:
Pirâmide Normativa Brasileira (Jurisprudência do STF):
1. Topo: Constituição Federal + Tratados de Direitos Humanos do art. 5º, §3º (Bloco de Constitucionalidade);
2. Nível Intermediário: Tratados de Direitos Humanos comuns (STATUS SUPRALEGAL);
3. Nível Infraconstitucional: Leis Complementares, Leis Ordinárias, Leis Delegadas;
4. Nível Infralegal: Decretos, Portarias, Resoluções.`
  },
  {
    id: 167,
    explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O processo de incorporação de tratados internacionais no Brasil é complexo e bifásico/misto, envolvendo a participação harmônica dos Poderes constitucionais:
1) Negociação e assinatura pelo Presidente da República (Poder Executivo - Art. 84, VIII, CF);
2) Aprovação pelo Congresso Nacional mediante Decreto Legislativo (Poder Legislativo - Art. 49, I, CF);
3) Ratificação internacional e promulgação pelo Presidente da República mediante Decreto Presidencial publicado no Diário Oficial da União.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Prefeitos municipais não possuem competência em relações exteriores ou tratados internacionais.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O Poder Judiciário não celebra tratados; exerce apenas o controle de constitucionalidade/convencionalidade.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A aprovação não exige plebiscito popular obrigatório, sendo atribuição do Congresso Nacional (art. 49, I).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A incorporação depende de procedimentos soberanos dos Poderes da República brasileira.

BIZU DE PROVA:
Passo a Passo da Incorporação de Tratados no Brasil:
1. Executivo: Assina o tratado;
2. Legislativo: Congresso aprova (Decreto Legislativo);
3. Executivo: Ratifica no plano externo e Promulga internamente (Decreto Presidencial).`
  },
  {
    id: 168,
    explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A UNIVERSALIDADE é o princípio fundamental e estruturante do Direito Internacional dos Direitos Humanos, consagrado na Declaração de Viena de 1993, segundo o qual todos os direitos humanos são universais, indivisíveis, interdependentes e inter-relacionados, pertencendo a todas as pessoas humanas pelo simples fato de sua existência, sem discriminação de qualquer natureza.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Os direitos humanos são IRRENUNCIÁVEIS (ninguém pode abrir mão de sua dignidade ou condição humana).

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Aplicam-se a nacionais, estrangeiros, refugiados e apátridas (são universais).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
São INDISPONÍVEIS (não podem ser alienados ou negociados).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Vigoram permanentemente em tempos de paz e de normalidade institucional.

BIZU DE PROVA:
Declaração de Viena (1993):
"Todos os direitos humanos são UNIVERSAIS, INDIVISÍVEIS, INTERDEPENDENTES e INTER-RELACIONADOS."
Universalidade: Não há ser humano sem direitos humanos!`
  },
  {
    id: 169,
    explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O princípio da INDIVISIBILIDADE (consagrado na Conferência Mundial de Direitos Humanos de Viena, 1993) estabelece que os direitos humanos compõem um sistema único e integrado, no qual os direitos civis e políticos não podem ser dissociados nem hierarquizados em relação aos direitos econômicos, sociais e culturais, pois a fruição de uma categoria depende diretamente da realização da outra.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
Tanto direitos civis quanto direitos sociais, econômicos e difusos são protegidos com igual dignidade.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Direitos sociais são direitos humanos fundamentais reconhecidos nos principais tratados da ONU (PIDESC) e na CF/88 (art. 6º).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Os direitos humanos possuem titularidade universal e abrangente.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Os direitos humanos coexistem de forma harmônica e integrada.

BIZU DE PROVA:
Indivisibilidade e Interdependência:
Não existe hierarquia entre direitos civis (vida, liberdade) e direitos sociais (saúde, educação, trabalho): todos formam um conjunto indissociável para a garantia da dignidade humana!`
  },
  {
    id: 170,
    explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A DIGNIDADE DA PESSOA HUMANA é o valor supremo, a fonte ética e o fundamento axiológico universal que justifica a existência e a proteção de todos os direitos humanos, tendo por finalidade salvaguardar a vida digna, a integridade, a autonomia e o pleno desenvolvimento de cada indivíduo contra abusos de poder e exclusões sociais.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A finalidade não é fiscal ou arrecadatória do Estado.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não se destinam a resguardar hierarquias corporativas de empresas.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Não visam tutelar com exclusividade o patrimônio estatal.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não constituem instrumentos de regulação de câmbio ou moeda.

BIZU DE PROVA:
Fundamento Supremo dos Direitos Humanos:
DIGNIDADE DA PESSOA HUMANA (Kant: a pessoa humana tem dignidade e não preço; é um fim em si mesma, nunca mero meio ou instrumento).`
  },
  {
    id: 171,
    explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
A Organização dos Estados Americanos (OEA), fundada em 1948 na IX Conferência Internacional Americana em Bogotá (Colômbia), é a mais antiga organização internacional de caráter REGIONAL do mundo, congregando os Estados soberanos das Américas do Sul, Central, Norte e Caribe com o objetivo de promover a paz, a democracia, a cooperação e a defesa dos direitos humanos no continente americano.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O continente europeu é congregado pelo Conselho da Europa e pela União Europeia.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
O continente africano é organizado pela União Africana (UA).

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A região asiática possui fóruns próprios (como ASEAN).

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A OEA é uma organização regional americana, enquanto a ONU é a organização universal/global.

BIZU DE PROVA:
OEA (Organização dos Estados Americanos):
- Âmbito: REGIONAL AMERICANO.
- Criação: Carta de Bogotá (1948).
- Finalidades: Democracia, Direitos Humanos, Segurança e Desenvolvimento Integral.`
  },
  {
    id: 172,
    explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
O Sistema Interamericano de Proteção dos Direitos Humanos está institucionalmente vinculado à Organização dos Estados Americanos (OEA). A Comissão Interamericana de Direitos Humanos (CIDH) é órgão da Carta da OEA e a Corte Interamericana de Direitos Humanos (Corte IDH) foi instituída pela Convenção Americana sobre Direitos Humanos no âmbito da OEA.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A União Europeia mantém o sistema europeu de direitos humanos.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A OTAN é uma aliança militar de segurança mútua do Tratado do Atlântico Norte.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A OMC disciplina o comércio internacional de bens e serviços.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
A OCDE é a organização de cooperação e desenvolvimento econômico.

BIZU DE PROVA:
Sistema Interamericano = OEA.
Composto por:
1. Comissão Interamericana de Direitos Humanos (CIDH);
2. Corte Interamericana de Direitos Humanos (Corte IDH).`
  },
  {
    id: 173,
    explicacao: `GABARITO: alternativa A

POR QUE A ALTERNATIVA A ESTÁ CORRETA:
Conforme o Artigo 1º e 2º da Carta da Organização dos Estados Americanos (Carta de Bogotá de 1948), os propósitos essenciais da OEA incluem: assegurar a paz e a segurança continentais; promover e consolidar a democracia representativa respeitado o princípio da não intervenção; prevenir possíveis causas de dificuldades e assegurar a solução pacífica de controvérsias; e promover o desenvolvimento econômico, social e cultural mediante ação cooperativa.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
A OEA não tem propósito de criar moeda única global.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
Não busca a unificação de forças armadas nacionais em um exército único.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
Respeita a soberania, integridade territorial e fronteiras de todos os Estados membros.

POR QUE A ALTERNATIVA E ESTÁ INCORRETA:
Não substitui nem controla diretamente os governos internos soberanos.

BIZU DE PROVA:
Pilares da OEA:
1. Democracia;
2. Direitos Humanos;
3. Segurança;
4. Desenvolvimento Sustentável.`
  }
];

const codeContent = `// Explicações pedagógicas do Lote 1 de Direitos Humanos e Cidadania (50 questões)
// Conformidade canônica com supabase/classificar_explicacoes_questoes.sql

export const explicacoes = ${JSON.stringify(explicacoes, null, 2)};
`;

fs.writeFileSync('scripts/dh-lote1-explicacoes.mjs', codeContent, 'utf8');
console.log('Arquivo scripts/dh-lote1-explicacoes.mjs gerado com sucesso! Total:', explicacoes.length);
