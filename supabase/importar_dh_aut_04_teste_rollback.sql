-- TESTE DE ROLLBACK do Lote DH-AUT-04 de Direitos Humanos e Cidadania — 18
-- questoes AUTORAL_PAPIRO + 90 alternativas + 18 vinculos (cc86,87,88).
--
-- Mirror exato de supabase/importar_dh_aut_04.sql, substituindo os
-- RAISE EXCEPTION por insercoes em uma tabela temporaria _relatorio, e
-- SEMPRE terminando em ROLLBACK — nenhuma linha e persistida, mesmo que
-- todos os checks passem. Uso: validar toda a logica de insercao,
-- precondicoes e pos-condicoes antes do apply real.

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _relatorio (item text, ok boolean, detalhe text) on commit drop;

create temporary table _snapshot_antes on commit drop as
select
  (select count(*) from public.questoes)                     as total_questoes,
  (select count(*) from public.alternativas)                 as total_alternativas,
  (select count(*) from public.unidades_pedagogicas)          as total_unidades,
  (select count(*) from public.curso_conteudos)               as total_conteudos,
  (select count(*) from public.curso_questoes)                as total_curso_questoes,
  (select count(*) from public.respostas_usuarios)            as total_respostas,
  (select count(*) from public.sessoes_estudo)                as total_sessoes,
  (select count(*) from public.questao_unidades_pedagogicas)  as total_vinculos,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 86) as cc86_uteis,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.questoes q on q.id = qup.questao_id where up.curso_conteudo_id = 86 and coalesce(lower(q.banca),'') not like '%papiro%') as cc86_real,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 87) as cc87_uteis,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.questoes q on q.id = qup.questao_id where up.curso_conteudo_id = 87 and coalesce(lower(q.banca),'') not like '%papiro%') as cc87_real,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 88) as cc88_uteis,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.questoes q on q.id = qup.questao_id where up.curso_conteudo_id = 88 and coalesce(lower(q.banca),'') not like '%papiro%') as cc88_real,
  (select count(distinct qup.questao_id)
     from public.questao_unidades_pedagogicas qup
     join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
     join public.curso_conteudos cc on cc.id = up.curso_conteudo_id
     join public.assuntos a on a.id = cc.assunto_id
     where a.materia_id = 11) as dh_uteis;

create temporary table _lote_questoes (
  ordem int primary key,
  codigo text,
  unidade_id uuid,
  assunto_id bigint,
  cc_id int,
  dificuldade text,
  fonte text,
  enunciado text
) on commit drop;

insert into _lote_questoes (ordem, codigo, unidade_id, assunto_id, cc_id, dificuldade, fonte, enunciado) values
(1,'cc86-01','7a9e1731-626a-44cc-90f0-004faed11e0f',87,86,'media','PAPIRO — DH-AUT-04 — cc86-01 — Carta OEA art.53 orgaos',
 'A Organização dos Estados Americanos (OEA) possui uma estrutura institucional delineada para a consecução de seus objetivos no continente. Nos termos expressos do artigo 53 de sua Carta, assinale a alternativa que indica corretamente um dos órgãos por intermédio dos quais a OEA realiza os seus fins.'),
(2,'cc86-02','7a9e1731-626a-44cc-90f0-004faed11e0f',87,86,'facil','PAPIRO — DH-AUT-04 — cc86-02 — Carta OEA art.2 a',
 'De acordo com o artigo 2º, alínea "a", da Carta da Organização dos Estados Americanos (OEA), a organização possui finalidades primordiais para com os seus membros. Dentre essas finalidades, destaca-se explicitamente o propósito essencial de:'),
(3,'cc86-03','7a9e1731-626a-44cc-90f0-004faed11e0f',87,86,'media','PAPIRO — DH-AUT-04 — cc86-03 — Carta OEA art.2 b',
 'Ao estipular seus propósitos essenciais, a Carta da OEA traz comandos fundamentais sobre o regime político a ser incentivado e as garantias de soberania. Nesse sentido, conforme o artigo 2º, alínea "b", a Organização propõe-se a:'),
(4,'cc86-04','7a9e1731-626a-44cc-90f0-004faed11e0f',87,86,'media','PAPIRO — DH-AUT-04 — cc86-04 — Carta OEA art.2 f',
 'Os propósitos da OEA não se limitam às áreas de segurança e regime político, alcançando também o plano do progresso coletivo das nações do continente. Nos termos do artigo 2º, "f", da Carta da OEA, é um dos propósitos essenciais da Organização:'),
(5,'cc86-05','7a9e1731-626a-44cc-90f0-004faed11e0f',87,86,'media','PAPIRO — DH-AUT-04 — cc86-05 — Carta OEA art.1 1o paragrafo',
 'Ao dispor sobre a natureza jurídica e a posição da Organização dos Estados Americanos (OEA) no cenário internacional, o artigo 1º, primeiro parágrafo, da Carta da OEA estabelece uma relação institucional declarada com as Nações Unidas. Segundo esse dispositivo legal, no âmbito internacional, a OEA:'),
(6,'cc86-06','7a9e1731-626a-44cc-90f0-004faed11e0f',87,86,'media','PAPIRO — DH-AUT-04 — cc86-06 — Carta OEA art.1 2o paragrafo',
 'A Carta da OEA define os limites de atuação da própria Organização em relação à soberania de seus membros. De acordo com o artigo 1º, segundo parágrafo do tratado, sobre as faculdades da OEA e o princípio da não-intervenção, é correto afirmar que:'),
(7,'cc86-07','7a9e1731-626a-44cc-90f0-004faed11e0f',87,86,'dificil','PAPIRO — DH-AUT-04 — cc86-07 — Carta OEA assertivas arts.1/2/53',
 E'Considere as seguintes assertivas sobre a estruturação e a natureza jurídica da Organização dos Estados Americanos (OEA), à luz de sua Carta:\n\nI. A OEA constitui um organismo regional dentro do sistema das Nações Unidas.\nII. Entre seus propósitos essenciais, a OEA busca garantir a paz e a segurança continentais, bem como promover e consolidar a democracia representativa, respeitado o princípio da não-intervenção.\nIII. A institucionalização da Comissão Interamericana de Direitos Humanos decorre exclusivamente da Convenção Americana sobre Direitos Humanos, não figurando entre os órgãos elencados no art. 53 da Carta da OEA.\n\nEstá correto o que se afirma em:'),
(8,'cc87-01','1b84fd2f-93e4-46c1-868f-c8402e73bdf9',92,87,'media','PAPIRO — DH-AUT-04 — cc87-01 — CADH art.41 limites da Comissao',
 'A Comissão Interamericana de Direitos Humanos e a Corte Interamericana desempenham papéis estruturais distintos no sistema interamericano. Sobre a atuação da Comissão e seus limites funcionais de acordo com a Convenção Americana sobre Direitos Humanos (CADH), assinale a afirmativa correta.'),
(9,'cc87-02','1b84fd2f-93e4-46c1-868f-c8402e73bdf9',92,87,'media','PAPIRO — DH-AUT-04 — cc87-02 — CADH art.41 f',
 'A Convenção Americana sobre Direitos Humanos estabelece diversas atribuições para que a Comissão Interamericana realize sua missão principal. Com relação ao trâmite de denúncias de violações no continente, o artigo 41, alínea "f", da CADH estabelece expressamente que a Comissão:'),
(10,'cc87-03','1b84fd2f-93e4-46c1-868f-c8402e73bdf9',92,87,'media','PAPIRO — DH-AUT-04 — cc87-03 — CADH art.44 legitimidade',
 'No âmbito do sistema regional americano, a Convenção Americana assegura o acesso aos órgãos de proteção por meio da regulação precisa da legitimidade ativa perante a Comissão Interamericana. Nos termos do artigo 44 da Convenção, têm legitimidade para apresentar petições que contenham denúncias ou queixas de violação à CADH por um Estado Parte:'),
(11,'cc87-04','1b84fd2f-93e4-46c1-868f-c8402e73bdf9',92,87,'dificil','PAPIRO — DH-AUT-04 — cc87-04 — CADH art.44 aplicacao ONG',
 'Uma Organização Não Governamental (ONG) legalmente constituída e reconhecida no país "Alfa", que é Estado membro da OEA, decide apresentar à Comissão Interamericana de Direitos Humanos uma petição contendo denúncias de graves violações da Convenção Americana perpetradas pelo país "Beta" (que é Estado Parte da CADH). Sabe-se, no entanto, que referida ONG não possui registro legal, sede ou reconhecimento de utilidade pública no país "Beta". Considerando estritamente as regras de legitimidade previstas no artigo 44 da Convenção Americana, a ONG requerente:'),
(12,'cc87-05','1b84fd2f-93e4-46c1-868f-c8402e73bdf9',92,87,'dificil','PAPIRO — DH-AUT-04 — cc87-05 — CADH assertivas arts.41/44',
 E'Analise as afirmativas a seguir a respeito da atuação institucional da Comissão Interamericana de Direitos Humanos, conforme disposições da Convenção Americana:\n\nI. A função principal da Comissão é promover a observância e a defesa dos direitos humanos, funcionando como órgão do sistema interamericano na matéria.\nII. A Comissão atua a respeito das petições e outras comunicações, no exercício de sua autoridade, de conformidade com o disposto nos artigos 44 a 51 desta Convenção.\nIII. Qualquer pessoa ou grupo de pessoas, ou entidade não governamental legalmente reconhecida em um ou mais Estados membros da OEA, tem legitimidade para apresentar à Comissão petições que contenham denúncias ou queixas de violação da Convenção por um Estado Parte.\n\nNo contexto das normativas em tela, estão corretas as afirmativas:'),
(13,'cc88-01','9ab2c28c-2c1d-4d15-b134-a191ff946529',106,88,'dificil','PAPIRO — DH-AUT-04 — cc88-01 — Decreto 4463/2002 reconhecimento Brasil',
 'A submissão do Estado brasileiro à competência contenciosa da Corte Interamericana de Direitos Humanos obedeceu a um rito formal que gerou efeitos e parâmetros temporais bem definidos para a incidência da jurisdição desse tribunal internacional. Com relação à cronologia e aos limites do reconhecimento brasileiro do art. 62 da Convenção Americana, assinale a afirmativa correta.'),
(14,'cc88-02','9ab2c28c-2c1d-4d15-b134-a191ff946529',106,88,'media','PAPIRO — DH-AUT-04 — cc88-02 — CADH art.52.1 requisitos juizes',
 'A Convenção Americana estabelece requisitos pessoais e profissionais para a eleição dos juízes da Corte Interamericana de Direitos Humanos. Nos termos do artigo 52.1 da Convenção, a Corte é composta por juízes eleitos dentre juristas que devem reunir o seguinte perfil:'),
(15,'cc88-03','9ab2c28c-2c1d-4d15-b134-a191ff946529',106,88,'media','PAPIRO — DH-AUT-04 — cc88-03 — Estatuto Corte IDH art.1',
 'O Estatuto da Corte Interamericana de Direitos Humanos (art. 1º) traça, de modo objetivo, o perfil estrutural e a finalidade precípua do tribunal regional americano. De acordo com as diretrizes e natureza fixadas no normativo em tela, a Corte Interamericana de Direitos Humanos caracteriza-se formalmente como uma:'),
(16,'cc88-04','9ab2c28c-2c1d-4d15-b134-a191ff946529',106,88,'dificil','PAPIRO — DH-AUT-04 — cc88-04 — CADH art.68.1 aplicacao',
 'O Estado "Delta" é Estado Parte da Convenção Americana sobre Direitos Humanos e reconheceu formalmente a jurisdição contenciosa da Corte Interamericana. Delta foi parte em um caso submetido à Corte, que proferiu decisão definitiva a seu respeito. Com base estritamente no artigo 68.1 da CADH, o Estado "Delta":'),
(17,'cc88-05','9ab2c28c-2c1d-4d15-b134-a191ff946529',106,88,'facil','PAPIRO — DH-AUT-04 — cc88-05 — CADH art.52.1 nacionalidade titulo pessoal',
 'A magistratura da Corte Interamericana de Direitos Humanos observa critérios estabelecidos na Convenção Americana quanto à nacionalidade e à forma de investidura de seus membros. Em relação a esses dois aspectos, o artigo 52.1 da CADH preceitua que os juízes:'),
(18,'cc88-06','9ab2c28c-2c1d-4d15-b134-a191ff946529',106,88,'media','PAPIRO — DH-AUT-04 — cc88-06 — assertivas natureza/sede/composicao/dever',
 E'Considere as afirmações seguintes referentes ao perfil jurídico e institucional da Corte Interamericana de Direitos Humanos (Corte IDH):\n\nI. A Corte constitui-se em uma instituição judiciária autônoma, cuja sede formal se encontra estabelecida na cidade de San José (Costa Rica) e tem por finalidade objetiva a aplicação e a interpretação da CADH.\nII. A Corte é composta por sete juízes, nacionais de Estados membros da OEA, eleitos a título pessoal.\nIII. Os Estados Partes na Convenção comprometem-se a cumprir a decisão da Corte em todo caso em que forem partes.\n\nEstá correto o que se afirma em:');

create temporary table _lote_explicacoes (ordem int primary key, explicacao text) on commit drop;
insert into _lote_explicacoes (ordem, explicacao) values
(1, E'GABARITO: alternativa A\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO artigo 53 da Carta da Organização dos Estados Americanos dispõe que a OEA realiza os seus fins por intermédio de oito órgãos, entre eles, na alínea "e", a Comissão Interamericana de Direitos Humanos.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA Corte Interamericana de Direitos Humanos (B), embora integre o sistema interamericano, não consta do rol de órgãos do art. 53 da Carta da OEA — sua base institucional decorre da própria Convenção Americana (arts. 52 a 69), não da Carta da Organização. O Instituto Interamericano de Direitos Humanos (C) é entidade acadêmica internacional independente, tampouco previsto no art. 53. A Assembleia Parlamentar do Mercosul (D) pertence a bloco econômico distinto, e o Comitê Internacional da Cruz Vermelha (E) é organização humanitária autônoma, estranha à estrutura da OEA.'),
(2, E'GABARITO: alternativa C\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nA alternativa C reproduz o art. 2º, "a", da Carta da OEA: "Garantir a paz e a segurança continentais".\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nAs demais alternativas apontam finalidades não previstas na Carta: tribunal penal (A), união monetária (B), intervenção militar (D) ou integração judiciária civil (E).'),
(3, E'GABARITO: alternativa E\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nA alternativa E reproduz o art. 2º, "b", da Carta da OEA. A norma combina dois elementos: a promoção e consolidação da democracia representativa, e o limite imposto pelo respeito ao princípio da não-intervenção.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nAs alternativas A, B, C e D contrariam esse princípio, sugerindo mecanismos de intervenção armada, violação de jurisdição interna ou supressão de governos incompatíveis com o texto legal.'),
(4, E'GABARITO: alternativa B\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nA alternativa B reproduz literalmente o art. 2º, "f", da Carta da OEA: "Promover, por meio da ação cooperativa, seu desenvolvimento econômico, social e cultural" — o pronome "seu" refere-se aos Estados membros mencionados no caput do art. 2º.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nAs demais alternativas criam metas compulsórias (D), intervencionismo educacional (C), exclusão do foco social (E) e viés militar (A), incompatíveis com a ação cooperativa prevista.'),
(5, E'GABARITO: alternativa D\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nDe acordo com o art. 1º, primeiro parágrafo, da Carta da OEA: "Dentro das Nações Unidas, a Organização dos Estados Americanos constitui um organismo regional." Esse dispositivo qualifica a OEA como organismo regional dentro desse enquadramento internacional, sem que isso implique subordinação institucional à ONU.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nAs alternativas B, C e E erram ao estabelecerem vínculos de subordinação hierárquica administrativa ou delegação direta de poder executivo/militar que a Carta não prevê — a OEA possui foro e estrutura próprios. A alternativa A nega a previsão expressa da Carta.'),
(6, E'GABARITO: alternativa A\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nA alternativa A reproduz o art. 1º, segundo parágrafo, da Carta da OEA: "A Organização dos Estados Americanos não tem mais faculdades que aquelas expressamente conferidas por esta Carta, nenhuma de cujas disposições a autoriza a intervir em assuntos da jurisdição interna dos Estados membros."\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nAs demais alternativas atribuem à OEA poderes ilimitados, intervenção na jurisdição interna com base em poderes implícitos, atuação fora dos limites da Carta ou substituição de poderes executivos nacionais (B, C, D e E), nenhum deles previsto no dispositivo.'),
(7, E'GABARITO: alternativa C\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO item I está correto (art. 1º, primeiro parágrafo). O item II está correto (art. 2º, alíneas "a" e "b").\n\nPOR QUE O ITEM III ESTÁ INCORRETO:\nA Comissão Interamericana de Direitos Humanos está expressamente elencada como órgão da OEA no art. 53, alínea "e", da Carta — sua institucionalização não decorre exclusivamente da CADH, ostentando também base na própria Carta constitutiva da Organização. Sendo I e II verdadeiras, a alternativa correta é C.'),
(8, E'GABARITO: alternativa D\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO art. 41 da CADH estabelece que a função principal da Comissão é promover a observância e a defesa dos direitos humanos. No exercício de seu mandato, a Comissão processa petições, monitora a situação dos direitos humanos e elabora relatórios e recomendações. A Comissão não funciona como tribunal recursal que revoga decisões internas, tampouco profere sentenças condenatórias contenciosas, atribuição própria da Corte.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nAs demais alternativas atribuem à Comissão poderes de tribunal de apelação (A), corte criminal (B), órgão sem autonomia (C) ou juízo executório de indenizações (E), inexistentes em seu desenho jurídico.'),
(9, E'GABARITO: alternativa B\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nA alternativa B reproduz o art. 41, "f", da CADH: "atuar a respeito das petições e outras comunicações, no exercício de sua autoridade, de conformidade com o disposto nos artigos 44 a 51 desta Convenção."\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA Comissão não limita seu alcance a Chefes de Estado (A), não exige aprovação da Assembleia Geral para processar petições (C), não depende de notificação do executivo investigado (D) nem do Conselho de Segurança da ONU (E).'),
(10, E'GABARITO: alternativa E\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO artigo 44 da Convenção Americana regula a legitimidade para apresentar petições à Comissão: "Qualquer pessoa ou grupo de pessoas, ou entidade não governamental legalmente reconhecida em um ou mais Estados membros da Organização, pode apresentar à Comissão petições que contenham denúncias ou queixas de violação desta Convenção por um Estado-Parte."\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nAs alternativas A, B, C e D limitam indevidamente o acesso, exigindo falsos pressupostos (só vítima nacional, só MP, só organismos credenciados na ONU, só ONG sediada no Estado denunciado).'),
(11, E'GABARITO: alternativa C\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO artigo 44 da CADH exige que a entidade não governamental seja "legalmente reconhecida em um ou mais Estados-Membros da Organização" — não havendo exigência de que esse reconhecimento ocorra no Estado denunciado. A ONG do enunciado, reconhecida no Estado "Alfa" (Estado-Membro da OEA), possui legitimidade para denunciar o Estado "Beta", ainda que não possua registro ali. Esta questão resolve exclusivamente a legitimidade do peticionário nos termos do art. 44; os demais requisitos e regras de admissibilidade previstos na Convenção não são objeto desta questão.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nAs alternativas A, B, D e E criam exigências inexistentes no dispositivo.'),
(12, E'GABARITO: alternativa A\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nA assertiva I corresponde ao caput do art. 41 da CADH. A assertiva II corresponde ao art. 41, "f". A assertiva III corresponde à literalidade do art. 44. As três estão de acordo com os arts. 41 e 44 da Convenção, de modo que a alternativa correta é a letra A.'),
(13, E'GABARITO: alternativa B\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO Brasil depositou, junto à Secretaria-Geral da OEA, em 10 de dezembro de 1998, declaração reconhecendo como obrigatória, de pleno direito e por prazo indeterminado, sob reserva de reciprocidade, a competência da Corte nos termos do art. 62 da CADH, para fatos posteriores a essa data. Essa declaração foi promulgada internamente pelo Decreto nº 4.463, de 8 de novembro de 2002, após aprovação do Congresso Nacional.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA alternativa A confunde a data de assinatura da CADH (1969) com o reconhecimento da jurisdição contenciosa brasileira. A alternativa C confunde a data do decreto de promulgação (2002) com a data do depósito da declaração (1998), que é o marco temporal correto. A alternativa D inventa um prazo determinado de dez anos, quando o reconhecimento é por prazo indeterminado. A alternativa E confunde o Decreto nº 678/1992 (que incorporou a própria CADH ao ordenamento brasileiro) com o Decreto nº 4.463/2002 (que promulgou o reconhecimento da jurisdição contenciosa) — atos distintos e não simultâneos.'),
(14, E'GABARITO: alternativa E\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nA alternativa E reproduz o disposto no art. 52.1 da CADH: os juízes devem ser (1) juristas da mais alta autoridade moral, (2) de reconhecida competência em matéria de direitos humanos, e (3) que reúnam as condições requeridas para o exercício das mais elevadas funções judiciais, segundo a lei do Estado do qual sejam nacionais ou do Estado que os propuser como candidatos. A exigência é de qualificação jurídica e reputação — não de exercício prévio de magistratura em suprema corte, tampouco exclui docentes ou advogados.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nAs demais alternativas inventam exigência de mandato legislativo (A), exclusividade de origem judicial vedando professores/advogados (B), carreira diplomática sem formação jurídica (C) ou homologação por órgão da ONU, estranho ao sistema interamericano (D).'),
(15, E'GABARITO: alternativa A\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nA alternativa A reproduz o art. 1º do Estatuto da Corte Interamericana: "A Corte Interamericana de Direitos Humanos é uma instituição judiciária autônoma, cujo objetivo é a aplicação e a interpretação da Convenção Americana sobre Direitos Humanos."\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nAs alternativas B e D atribuem à Corte caráter meramente consultivo/não vinculante ou subordinação administrativa incompatíveis com sua autonomia judiciária; a C descreve uma função de "quarta instância" recursal que a Corte não exerce; a E remete a um distrator de arbitragem comercial estranho ao sistema interamericano.'),
(16, E'GABARITO: alternativa D\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nNos termos do art. 68.1 da CADH: "Os Estados Partes na Convenção comprometem-se a cumprir a decisão da Corte em todo caso em que forem partes." Tendo Delta reconhecido a jurisdição contenciosa e figurado como parte no caso, seu dever de cumprimento decorre diretamente do tratado.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nAs alternativas A, B, C e E criam condicionantes ao cumprimento (ato legislativo interno, juízo de compatibilidade constitucional, exame arbitral prévio, sanção confirmatória de tribunal nacional) que a Convenção não prevê.'),
(17, E'GABARITO: alternativa C\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO art. 52.1 da CADH dispõe que a Corte se compõe de sete juízes, "nacionais de Estados-Membros da Organização, eleitos a título pessoal dentre juristas...". Isso significa que os juízes não atuam como representantes ou delegados dos governos de seus Estados de nacionalidade, sendo eleitos a título pessoal.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nAs demais alternativas atribuem aos juízes vínculos de representação diplomática, subordinação partidária, restrição geográfica ou destituição administrativa discricionária, nenhum previsto no dispositivo.'),
(18, E'GABARITO: alternativa B\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nA assertiva I encontra amparo no art. 1º e no art. 3º do Estatuto da Corte IDH (instituição judiciária autônoma, sede em San José, objetivo de aplicar/interpretar a CADH). A assertiva II corresponde ao art. 52.1 da CADH (sete juízes, nacionais de Estados-Membros da OEA, eleitos a título pessoal). A assertiva III corresponde ao texto do art. 68.1 da CADH (dever de cumprimento pelo Estado que for parte no caso). Estando as três corretas, o gabarito é a alternativa B.');

create temporary table _lote_alternativas (
  ordem int,
  ordem_alt smallint,
  texto text,
  correta boolean
) on commit drop;

insert into _lote_alternativas (ordem, ordem_alt, texto, correta) values
(1,1,'A Comissão Interamericana de Direitos Humanos.',true),
(1,2,'A Corte Interamericana de Direitos Humanos.',false),
(1,3,'O Instituto Interamericano de Direitos Humanos.',false),
(1,4,'A Assembleia Parlamentar do Mercosul.',false),
(1,5,'O Comitê Internacional da Cruz Vermelha.',false),

(2,1,'instituir um tribunal penal supranacional.',false),
(2,2,'unificar as políticas monetárias e alfandegárias.',false),
(2,3,'garantir a paz e a segurança continentais.',true),
(2,4,'coordenar operações militares de intervenção armada.',false),
(2,5,'consolidar a unificação dos sistemas de justiça civil.',false),

(3,1,'impor a democracia representativa mediante o emprego de forças de intervenção regionais.',false),
(3,2,'suprimir a soberania dos Estados membros para assegurar governos provisórios não eleitos em tempos de crise.',false),
(3,3,'intervir nos assuntos da jurisdição interna dos Estados sempre que houver ruptura democrática, independentemente de autorização prévia.',false),
(3,4,'garantir regimes democráticos unicamente pelo estabelecimento de uma força-tarefa política unificada continental.',false),
(3,5,'promover e consolidar a democracia representativa, respeitado o princípio da não-intervenção.',true),

(4,1,'implementar o livre comércio absoluto e o desenvolvimento bélico prioritário das nações.',false),
(4,2,'promover, por meio da ação cooperativa, seu desenvolvimento econômico, social e cultural.',true),
(4,3,'padronizar, por meio de intervenção unilateral executiva, os sistemas educacionais das nações sul-americanas.',false),
(4,4,'impor metas compulsórias de crescimento econômico que anulem a autonomia financeira dos países em desenvolvimento.',false),
(4,5,'ditar políticas de cooperação econômica externa a todos os entes, afastando o desenvolvimento social de sua alçada.',false),

(5,1,'atua de forma independente e isolada, sem qualquer relação ou enquadramento com o sistema das Nações Unidas.',false),
(5,2,'é um órgão administrativo da ONU, hierarquicamente subordinado e submetido aos ditames da Assembleia Geral das Nações Unidas.',false),
(5,3,'substitui a atuação do Conselho de Segurança da ONU nas Américas, operando como instância revisora mundial.',false),
(5,4,'constitui um organismo regional dentro do sistema das Nações Unidas.',true),
(5,5,'atua como uma agência executiva de operações de paz controlada diretamente pela Secretaria-Geral da ONU.',false),

(6,1,'a Organização não possui mais faculdades do que as que lhe são expressamente conferidas por sua Carta, a qual não a autoriza a intervir em assuntos da jurisdição interna dos Estados membros.',true),
(6,2,'a Organização possui faculdades implícitas plenas que a autorizam a intervir nos assuntos internos constitucionais dos Estados membros para assegurar direitos.',false),
(6,3,'a Organização detém poderes implícitos irrestritos que lhe permitem intervir na jurisdição interna dos Estados membros sempre que entender conveniente para a estabilidade regional, independentemente de previsão expressa na Carta.',false),
(6,4,'a Organização pode atuar fora dos limites do rol de sua Carta, uma vez que a proteção regional das garantias autoriza a intervenção direta nas políticas constitucionais internas.',false),
(6,5,'a Carta da OEA autoriza a substituição dos poderes executivos nacionais sempre que a Comissão constatar eventuais omissões na condução de políticas públicas.',false),

(7,1,'I, apenas.',false),
(7,2,'I e III, apenas.',false),
(7,3,'I e II, apenas.',true),
(7,4,'II e III, apenas.',false),
(7,5,'I, II e III.',false),

(8,1,'A Comissão funciona administrativamente como tribunal de apelação, ostentando o poder de reformar decisões cíveis transitadas em julgado nas supremas cortes nacionais.',false),
(8,2,'A Comissão exerce função jurisdicional originária, proferindo sentenças contenciosas criminais contra indivíduos acusados de crimes de guerra.',false),
(8,3,'A Comissão atua exclusivamente como órgão de instrução preparatório, não podendo emitir recomendações aos governos sem a prévia autorização judicial da Corte.',false),
(8,4,'A Comissão tem a função principal de promover a observância e a defesa dos direitos humanos, não atuando como tribunal recursal e tampouco proferindo sentenças contenciosas que são próprias da jurisdição da Corte.',true),
(8,5,'A Comissão atua como instância revisora superior capaz de fixar, diretamente em sentença sumária, indenizações pecuniárias com força de título executivo em desfavor dos Estados membros.',false),

(9,1,'atuará apenas em comunicações formuladas por chefes de estado, excluindo o atendimento a demandas formuladas pela sociedade civil.',false),
(9,2,'atuará a respeito das petições e outras comunicações, no exercício de sua autoridade, de conformidade com as disposições da Convenção nos artigos 44 a 51.',true),
(9,3,'processará as petições exclusivamente mediante prévia aprovação unânime de todos os Estados-Membros da Organização reunidos em Assembleia Geral.',false),
(9,4,'receberá petições apenas após o envio formal de notificação diplomática do chefe do Poder Executivo do país em que a violação ocorreu.',false),
(9,5,'remeterá todas as petições individuais originárias para o Conselho de Segurança da ONU antes de dar andamento à instrução do caso.',false),

(10,1,'unicamente os cidadãos natos do Estado denunciado que figurarem como vítimas diretas e exclusivas da violação apontada.',false),
(10,2,'apenas o Ministério Público ou as Defensorias Públicas atuantes no território e sob a jurisdição do Estado em que ocorreram os fatos.',false),
(10,3,'apenas os organismos internacionais formalmente credenciados junto à Organização das Nações Unidas, com anuência expressa do Estado denunciado.',false),
(10,4,'exclusivamente as entidades e organizações não governamentais sediadas em caráter permanente no próprio território do Estado contra o qual se apresenta a denúncia.',false),
(10,5,'qualquer pessoa ou grupo de pessoas, ou entidade não governamental legalmente reconhecida em um ou mais Estados membros da Organização.',true),

(11,1,'não possui legitimidade, pois a norma exige que entidades não governamentais estejam sediadas e reconhecidas exclusivamente no próprio Estado denunciado.',false),
(11,2,'não possui legitimidade, pois o artigo 44 exige que a denúncia seja formulada diretamente pela vítima, vedada a atuação de terceiros ou entidades representativas.',false),
(11,3,'possui legitimidade, pois o artigo 44 exige apenas que a entidade não governamental seja legalmente reconhecida em um ou mais Estados-Membros da Organização, não impondo que esse reconhecimento ocorra no Estado denunciado.',true),
(11,4,'possui legitimidade apenas se comprovar autorização prévia, por escrito, expedida pelo Ministério da Justiça do Estado "Beta" para monitorar fatos em seu território.',false),
(11,5,'não possui legitimidade, pois compete exclusivamente ao Ministério das Relações Exteriores do país "Alfa" formalizar petições de natureza transnacional em nome de entidades sediadas em seu território.',false),

(12,1,'I, II e III.',true),
(12,2,'I e II, apenas.',false),
(12,3,'II e III, apenas.',false),
(12,4,'I e III, apenas.',false),
(12,5,'I, apenas.',false),

(13,1,'O Brasil reconheceu a competência contenciosa da Corte com efeitos retroativos a 1969, ano de assinatura da Convenção Americana pelos Estados fundadores do sistema.',false),
(13,2,'O Brasil, cuja declaração de reconhecimento foi depositada junto à Secretaria-Geral da OEA em 10 de dezembro de 1998 e posteriormente promulgada pelo Decreto nº 4.463, de 8 de novembro de 2002, reconheceu como obrigatória, de pleno direito e por prazo indeterminado, sob reserva de reciprocidade, a competência da Corte para fatos posteriores a 10 de dezembro de 1998.',true),
(13,3,'O reconhecimento brasileiro alcançou vigência estrita com o Decreto nº 4.463/2002, motivo pelo qual a Corte pode julgar fatos posteriores a 2002, rechaçando incidentes de 1998.',false),
(13,4,'O Brasil reconheceu a competência da Corte por prazo determinado de dez anos a contar do depósito da declaração em 1998, tendo essa competência se extinguido automaticamente em 2008 sem possibilidade de renovação.',false),
(13,5,'O reconhecimento brasileiro retroagiu para alcançar fatos ocorridos desde a promulgação do Decreto nº 678, de 1992, que incorporou a Convenção Americana ao ordenamento interno.',false),

(14,1,'membros detentores de mandatos políticos vigentes no corpo legislativo nacional, visando estreitar o laço diplomático para com a OEA.',false),
(14,2,'juristas indicados de forma exclusiva por entre as supremas cortes dos seus países de origem, proibindo-se a eleição de professores ou advogados.',false),
(14,3,'diplomatas de carreira sem exigência de conhecimento jurídico específico, desde que detentores de experiência pregressa no Conselho de Segurança das Nações Unidas.',false),
(14,4,'indivíduos com ampla experiência na defesa administrativa, desde que submetidos à homologação do Comitê de Direitos Humanos da ONU.',false),
(14,5,'juristas da mais alta autoridade moral, de reconhecida competência em matéria de direitos humanos, que reúnam as condições requeridas para o exercício das mais elevadas funções judiciais de acordo com a lei do Estado do qual sejam nacionais, ou do Estado que os propuser como candidatos.',true),

(15,1,'instituição judiciária autônoma, cujo objetivo é a aplicação e a interpretação da Convenção Americana sobre Direitos Humanos.',true),
(15,2,'órgão consultivo subordinado à Comissão Interamericana, cujas decisões possuem caráter de mera recomendação não vinculante em qualquer hipótese.',false),
(15,3,'instância de segundo grau do Poder Judiciário dos Estados americanos, encarregada de rejulgar recursos ordinários oriundos das Supremas Cortes nacionais.',false),
(15,4,'agência puramente administrativa subordinada à Assembleia Geral, que detém o poder de criar impostos regionais indenizatórios nas Américas.',false),
(15,5,'câmara arbitral comercial independente, gerida pela ONU, cujo papel é dirimir perdas pecuniárias empresariais atreladas aos direitos aduaneiros.',false),

(16,1,'poderá abster-se de cumprir a decisão caso o Poder Legislativo nacional aprove ato interno em sentido contrário, em respeito à soberania.',false),
(16,2,'tem a faculdade discricionária de cumprir apenas as partes da decisão que considerar compatíveis com sua ordem constitucional interna.',false),
(16,3,'deverá submeter previamente a decisão a exame de compatibilidade por um tribunal arbitral da OEA antes de qualquer cumprimento.',false),
(16,4,'compromete-se a cumprir a decisão da Corte, por ter sido parte no caso em que foi proferida.',true),
(16,5,'somente estará obrigado a cumpri-la mediante prévia sanção confirmatória de sua própria Suprema Corte nacional.',false),

(17,1,'são eleitos como representantes diplomáticos oficiais de seus respectivos governos, devendo relatar os feitos às embaixadas originárias.',false),
(17,2,'compõem o corpo de relatores temporários da OEA, vinculados aos pactos partidários dos parlamentos nacionais.',false),
(17,3,'devem ser nacionais de Estados membros da OEA e são eleitos a título pessoal.',true),
(17,4,'devem ser magistrados natos ou naturalizados de países exclusivos da América Central, eleitos a título estrito do governo de plantão.',false),
(17,5,'figuram como servidores delegados da presidência do Estado, que podem ser removidos administrativamente a qualquer tempo, sem rito.',false),

(18,1,'I e II, apenas.',false),
(18,2,'I, II e III.',true),
(18,3,'II e III, apenas.',false),
(18,4,'I e III, apenas.',false),
(18,5,'I, apenas.',false);

-- Precondicoes.
insert into _relatorio select 'staging_total_18', (select count(*) from _lote_questoes) = 18, (select count(*) from _lote_questoes)::text;

insert into _relatorio select 'enunciado_sem_duplicata',
  (select count(*) from _lote_questoes lq where exists (select 1 from public.questoes q where q.enunciado = lq.enunciado)) = 0,
  (select count(*) from _lote_questoes lq where exists (select 1 from public.questoes q where q.enunciado = lq.enunciado))::text;

insert into _relatorio select 'unidades_alvo_ativas',
  (select count(*) from _lote_questoes lq where not exists (select 1 from public.unidades_pedagogicas u where u.id = lq.unidade_id and u.ativa)) = 0,
  (select count(*) from _lote_questoes lq where not exists (select 1 from public.unidades_pedagogicas u where u.id = lq.unidade_id and u.ativa))::text;

insert into _relatorio select 'assunto_compativel',
  (select count(*) from _lote_questoes lq join public.unidades_pedagogicas u on u.id = lq.unidade_id join public.curso_conteudos cc on cc.id = u.curso_conteudo_id where cc.assunto_id is distinct from lq.assunto_id) = 0,
  (select count(*) from _lote_questoes lq join public.unidades_pedagogicas u on u.id = lq.unidade_id join public.curso_conteudos cc on cc.id = u.curso_conteudo_id where cc.assunto_id is distinct from lq.assunto_id)::text;

insert into _relatorio select 'dificuldade_dominio',
  (select count(*) from _lote_questoes where dificuldade not in ('facil','media','dificil')) = 0,
  (select count(*) from _lote_questoes where dificuldade not in ('facil','media','dificil'))::text;

insert into _relatorio select 'staging_cc86_7', (select count(*) from _lote_questoes where cc_id=86) = 7, (select count(*) from _lote_questoes where cc_id=86)::text;
insert into _relatorio select 'staging_cc87_5', (select count(*) from _lote_questoes where cc_id=87) = 5, (select count(*) from _lote_questoes where cc_id=87)::text;
insert into _relatorio select 'staging_cc88_6', (select count(*) from _lote_questoes where cc_id=88) = 6, (select count(*) from _lote_questoes where cc_id=88)::text;

insert into _relatorio select 'snapshot_cc86_uteis_3', (select cc86_uteis from _snapshot_antes) = 3, (select cc86_uteis from _snapshot_antes)::text;
insert into _relatorio select 'snapshot_cc87_uteis_5', (select cc87_uteis from _snapshot_antes) = 5, (select cc87_uteis from _snapshot_antes)::text;
insert into _relatorio select 'snapshot_cc88_uteis_4', (select cc88_uteis from _snapshot_antes) = 4, (select cc88_uteis from _snapshot_antes)::text;

-- Insercao das questoes + alternativas.
create temporary table _mapa_ids (ordem int primary key, questao_id bigint) on commit drop;

do $$
declare r record; v_id bigint;
begin
  for r in select * from _lote_questoes order by ordem loop
    insert into public.questoes (materia_id, assunto_id, banca, concurso, ano, enunciado, dificuldade, explicacao, fonte, ativa, gerada_por_ia)
    values (11, r.assunto_id, 'Papiro', 'PAPIRO - Curadoria DH-AUT-04 - BM RS', 2026, r.enunciado, r.dificuldade,
            (select explicacao from _lote_explicacoes le where le.ordem = r.ordem),
            r.fonte, true, true)
    returning id into v_id;
    insert into _mapa_ids (ordem, questao_id) values (r.ordem, v_id);

    insert into public.alternativas (questao_id, texto, correta, ordem)
    select v_id, la.texto, la.correta, la.ordem_alt
    from _lote_alternativas la
    where la.ordem = r.ordem
    order by la.ordem_alt;
  end loop;
end $$;

-- Vinculos via RPC oficial.
do $$
declare r record;
begin
  for r in select m.questao_id, lq.unidade_id from _mapa_ids m join _lote_questoes lq on lq.ordem = m.ordem loop
    perform public.classificar_questao_unidade_admin(r.questao_id, r.unidade_id);
  end loop;
end $$;

-- Pos-condicoes (registradas em _relatorio, sem RAISE EXCEPTION).
insert into _relatorio select 'pos_questoes_novas_18',
  (select count(*) from public.questoes where id in (select questao_id from _mapa_ids)) = 18,
  (select count(*) from public.questoes where id in (select questao_id from _mapa_ids))::text;

insert into _relatorio select 'pos_materia_id_11',
  (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and materia_id <> 11) = 0,
  (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and materia_id <> 11)::text;

insert into _relatorio select 'pos_assunto_id_correto',
  (select count(*) from public.questoes q join _mapa_ids m on m.questao_id = q.id join _lote_questoes lq on lq.ordem = m.ordem where q.assunto_id <> lq.assunto_id) = 0,
  (select count(*) from public.questoes q join _mapa_ids m on m.questao_id = q.id join _lote_questoes lq on lq.ordem = m.ordem where q.assunto_id <> lq.assunto_id)::text;

insert into _relatorio select 'pos_ativa_true',
  (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and ativa is distinct from true) = 0,
  (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and ativa is distinct from true)::text;

insert into _relatorio select 'pos_todas_papiro',
  (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and coalesce(lower(banca),'') not like '%papiro%') = 0,
  (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and coalesce(lower(banca),'') not like '%papiro%')::text;

insert into _relatorio select 'pos_alternativas_90',
  (select count(*) from public.alternativas where questao_id in (select questao_id from _mapa_ids)) = 90,
  (select count(*) from public.alternativas where questao_id in (select questao_id from _mapa_ids))::text;

insert into _relatorio select 'pos_uma_correta_por_questao',
  (select count(*) from (select questao_id from public.alternativas where questao_id in (select questao_id from _mapa_ids) group by questao_id having count(*) filter (where correta) <> 1) x) = 0,
  (select count(*) from (select questao_id from public.alternativas where questao_id in (select questao_id from _mapa_ids) group by questao_id having count(*) filter (where correta) <> 1) x)::text;

insert into _relatorio select 'pos_dificuldade_2_11_5',
  (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and dificuldade='facil') = 2
  and (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and dificuldade='media') = 11
  and (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and dificuldade='dificil') = 5,
  format('facil=%s media=%s dificil=%s',
    (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and dificuldade='facil'),
    (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and dificuldade='media'),
    (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and dificuldade='dificil'));

insert into _relatorio select 'pos_gabarito_A4_B4_C4_D3_E3',
  (select count(*) from public.alternativas a join _mapa_ids m on a.questao_id=m.questao_id where a.correta and a.ordem=1) = 4
  and (select count(*) from public.alternativas a join _mapa_ids m on a.questao_id=m.questao_id where a.correta and a.ordem=2) = 4
  and (select count(*) from public.alternativas a join _mapa_ids m on a.questao_id=m.questao_id where a.correta and a.ordem=3) = 4
  and (select count(*) from public.alternativas a join _mapa_ids m on a.questao_id=m.questao_id where a.correta and a.ordem=4) = 3
  and (select count(*) from public.alternativas a join _mapa_ids m on a.questao_id=m.questao_id where a.correta and a.ordem=5) = 3,
  format('A=%s B=%s C=%s D=%s E=%s',
    (select count(*) from public.alternativas a join _mapa_ids m on a.questao_id=m.questao_id where a.correta and a.ordem=1),
    (select count(*) from public.alternativas a join _mapa_ids m on a.questao_id=m.questao_id where a.correta and a.ordem=2),
    (select count(*) from public.alternativas a join _mapa_ids m on a.questao_id=m.questao_id where a.correta and a.ordem=3),
    (select count(*) from public.alternativas a join _mapa_ids m on a.questao_id=m.questao_id where a.correta and a.ordem=4),
    (select count(*) from public.alternativas a join _mapa_ids m on a.questao_id=m.questao_id where a.correta and a.ordem=5));

insert into _relatorio select 'pos_vinculos_novos_18',
  (select count(*) from public.questao_unidades_pedagogicas where questao_id in (select questao_id from _mapa_ids)) = 18,
  (select count(*) from public.questao_unidades_pedagogicas where questao_id in (select questao_id from _mapa_ids))::text;

insert into _relatorio select 'pos_sem_multivinculo',
  (select count(*) from (select questao_id from public.questao_unidades_pedagogicas where questao_id in (select questao_id from _mapa_ids) group by questao_id having count(*) > 1) x) = 0,
  (select count(*) from (select questao_id from public.questao_unidades_pedagogicas where questao_id in (select questao_id from _mapa_ids) group by questao_id having count(*) > 1) x)::text;

insert into _relatorio select 'pos_vinculo_cc_correto',
  not exists (
    select 1 from _mapa_ids m join _lote_questoes lq on lq.ordem = m.ordem
    where not exists (
      select 1 from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
      where qup.questao_id = m.questao_id and up.curso_conteudo_id = lq.cc_id
    )
  ), 'ok';

insert into _relatorio select 'pos_cc86_uteis_10',
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id where up.curso_conteudo_id=86) = 10,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id where up.curso_conteudo_id=86)::text;
insert into _relatorio select 'pos_cc87_uteis_10',
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id where up.curso_conteudo_id=87) = 10,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id where up.curso_conteudo_id=87)::text;
insert into _relatorio select 'pos_cc88_uteis_10',
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id where up.curso_conteudo_id=88) = 10,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id where up.curso_conteudo_id=88)::text;

insert into _relatorio select 'pos_real_inalterado',
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id join public.questoes q on q.id=qup.questao_id where up.curso_conteudo_id=86 and coalesce(lower(q.banca),'') not like '%papiro%') = (select cc86_real from _snapshot_antes)
  and (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id join public.questoes q on q.id=qup.questao_id where up.curso_conteudo_id=87 and coalesce(lower(q.banca),'') not like '%papiro%') = (select cc87_real from _snapshot_antes)
  and (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id join public.questoes q on q.id=qup.questao_id where up.curso_conteudo_id=88 and coalesce(lower(q.banca),'') not like '%papiro%') = (select cc88_real from _snapshot_antes),
  'ok';

insert into _relatorio select 'pos_dh_uteis_delta_18',
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.curso_conteudos cc on cc.id = up.curso_conteudo_id join public.assuntos a on a.id = cc.assunto_id where a.materia_id = 11) = (select dh_uteis from _snapshot_antes) + 18,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.curso_conteudos cc on cc.id = up.curso_conteudo_id join public.assuntos a on a.id = cc.assunto_id where a.materia_id = 11)::text;

insert into _relatorio select 'pos_total_questoes_delta_18', (select count(*) from public.questoes) = (select total_questoes from _snapshot_antes) + 18, (select count(*) from public.questoes)::text;
insert into _relatorio select 'pos_total_alternativas_delta_90', (select count(*) from public.alternativas) = (select total_alternativas from _snapshot_antes) + 90, (select count(*) from public.alternativas)::text;
insert into _relatorio select 'pos_total_vinculos_delta_18', (select count(*) from public.questao_unidades_pedagogicas) = (select total_vinculos from _snapshot_antes) + 18, (select count(*) from public.questao_unidades_pedagogicas)::text;
insert into _relatorio select 'pos_unidades_inalteradas', (select count(*) from public.unidades_pedagogicas) = (select total_unidades from _snapshot_antes), (select count(*) from public.unidades_pedagogicas)::text;
insert into _relatorio select 'pos_conteudos_inalterados', (select count(*) from public.curso_conteudos) = (select total_conteudos from _snapshot_antes), (select count(*) from public.curso_conteudos)::text;
insert into _relatorio select 'pos_curso_questoes_inalterado', (select count(*) from public.curso_questoes) = (select total_curso_questoes from _snapshot_antes), (select count(*) from public.curso_questoes)::text;
insert into _relatorio select 'pos_respostas_inalteradas', (select count(*) from public.respostas_usuarios) = (select total_respostas from _snapshot_antes), (select count(*) from public.respostas_usuarios)::text;
insert into _relatorio select 'pos_sessoes_inalteradas', (select count(*) from public.sessoes_estudo) = (select total_sessoes from _snapshot_antes), (select count(*) from public.sessoes_estudo)::text;

do $$
declare r record; v_todos_ok boolean := true;
begin
  for r in select * from _relatorio order by item loop
    raise notice '% => % (%)', r.item, r.ok, r.detalhe;
    if not r.ok then v_todos_ok := false; end if;
  end loop;
  raise notice 'tudo_ok = %', v_todos_ok;
end $$;

rollback;
