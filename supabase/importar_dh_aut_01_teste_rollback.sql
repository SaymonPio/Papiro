-- Harness de teste (SEMPRE termina em ROLLBACK) do Lote AUTORAL DH-AUT-01
-- de Direitos Humanos e Cidadania — 31 questoes novas AUTORAL_PAPIRO + 155
-- alternativas + 31 vinculos.
--
-- Fecha o deficit_para_10 de 6 unidades de Direitos Humanos e Cidadania
-- (cc70 Abuso de Autoridade, cc71 Pessoa com deficiencia, cc73 Lei de
-- Tortura, cc74 PIDCP, cc75 Estatuto da Pessoa com Deficiencia, cc76
-- Direitos fundamentais), levando cada uma a exatamente 10 uteis.
--
-- Fonte da verdade: auditoria independente Claude DH-AUT-01 (auditoria +
-- patch final pos-auditoria), com verificacao direta da legislacao
-- oficial vigente (planalto.gov.br).
--
-- Origem: AUTORAL_PAPIRO em todas as 31 (banca='Papiro') — nunca REAL.
--
-- Termina SEMPRE em ROLLBACK — nada aqui persiste no banco. NAO EXECUTADO
-- neste turno (preparacao/empacotamento apenas).

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

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
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 70) as cc70_uteis,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.questoes q on q.id = qup.questao_id where up.curso_conteudo_id = 70 and coalesce(lower(q.banca),'') not like '%papiro%') as cc70_real,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 71) as cc71_uteis,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.questoes q on q.id = qup.questao_id where up.curso_conteudo_id = 71 and coalesce(lower(q.banca),'') not like '%papiro%') as cc71_real,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 73) as cc73_uteis,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.questoes q on q.id = qup.questao_id where up.curso_conteudo_id = 73 and coalesce(lower(q.banca),'') not like '%papiro%') as cc73_real,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 74) as cc74_uteis,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.questoes q on q.id = qup.questao_id where up.curso_conteudo_id = 74 and coalesce(lower(q.banca),'') not like '%papiro%') as cc74_real,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 75) as cc75_uteis,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.questoes q on q.id = qup.questao_id where up.curso_conteudo_id = 75 and coalesce(lower(q.banca),'') not like '%papiro%') as cc75_real,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 76) as cc76_uteis,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.questoes q on q.id = qup.questao_id where up.curso_conteudo_id = 76 and coalesce(lower(q.banca),'') not like '%papiro%') as cc76_real,
  (select count(distinct qup.questao_id)
     from public.questao_unidades_pedagogicas qup
     join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
     join public.curso_conteudos cc on cc.id = up.curso_conteudo_id
     join public.assuntos a on a.id = cc.assunto_id
     where a.materia_id = 11) as dh_uteis;

create temporary table _relatorio (etapa text, ok boolean, detalhe text) on commit drop;

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
(1,'cc70-01','d4d8a1fc-4c52-4c85-879c-031d0085be88',103,70,'facil','PAPIRO — DH-AUT-01 — cc70-01 — Lei 13.869/2019 art.4 I',
 'Nos termos da Lei nº 13.869/2019, constitui efeito da condenação por crime de abuso de autoridade:'),
(2,'cc70-02','d4d8a1fc-4c52-4c85-879c-031d0085be88',103,70,'media','PAPIRO — DH-AUT-01 — cc70-02 — Lei 13.869/2019 art.4 II/III/par.único',
 'Um servidor público foi condenado pela prática de crime previsto na Lei nº 13.869/2019. Sobre a eventual decretação da perda do cargo e da inabilitação para o exercício de cargo, mandato ou função pública pelo período de 1 a 5 anos, assinale a afirmativa correta segundo a referida lei:'),
(3,'cc70-03','d4d8a1fc-4c52-4c85-879c-031d0085be88',103,70,'media','PAPIRO — DH-AUT-01 — cc70-03 — Lei 13.869/2019 art.16 par.único',
 'Durante a realização de interrogatório formal em sede de inquérito policial (procedimento investigatório de infração penal), uma autoridade pública devidamente designada para conduzir o ato omitiu deliberadamente sua verdadeira identificação ao investigado preso, atribuindo a si nome fictício e função pertencente a outra carreira, com a finalidade específica de prejudicar e intimidar o preso, dissimulando sua real atribuição funcional. Diante do caso concreto e dos preceitos da Lei nº 13.869/2019, a conduta descrita:'),
(4,'cc70-04','d4d8a1fc-4c52-4c85-879c-031d0085be88',103,70,'facil','PAPIRO — DH-AUT-01 — cc70-04 — Lei 13.869/2019 art.15-A',
 'Em uma investigação de um crime violento de grande repercussão, um agente público, encarregado de colher o depoimento de uma testemunha de crimes violentos, submeteu-a sucessivas vezes a questionamentos invasivos sobre sua vida íntima e a situações vexatórias desnecessárias à elucidação dos fatos; mesmo ciente da desnecessidade dos atos, o agente prosseguiu com a finalidade específica de prejudicar e humilhar a testemunha, gerando-lhe sofrimento psíquico indevido decorrente dos atos da própria inquirição oficial. Nos termos da Lei nº 13.869/2019, é correto afirmar que:'),
(5,'cc70-05','d4d8a1fc-4c52-4c85-879c-031d0085be88',103,70,'media','PAPIRO — DH-AUT-01 — cc70-05 — Lei 13.869/2019 art.23',
 'Com o propósito deliberado de responsabilizar criminalmente um desafeto que não cometeu qualquer delito, um agente estatal, antes da chegada dos peritos oficiais ao local onde ocorrera um tiroteio, posicionou intencionalmente um cartucho deflagrado nas proximidades dos pertences desse cidadão, alterando a cena dos fatos para induzir a perícia em erro. Nos termos estritos da Lei nº 13.869/2019, a conduta amolda-se ao crime de:'),
(6,'cc70-06','d4d8a1fc-4c52-4c85-879c-031d0085be88',103,70,'dificil','PAPIRO — DH-AUT-01 — cc70-06 — Lei 13.869/2019 art.22 par.2',
 'Policiais em patrulhamento ostensivo ingressaram, sem mandado judicial e sem consentimento do morador, no pátio interno e na residência de uma família às 22h, ao escutarem gritos desesperados e constatarem fumaça densa e chamas altas originadas de um botijão de gás acidentado na cozinha, efetuando o resgate de duas crianças que estavam sozinhas no recinto. Considerando estritamente a disciplina do art. 22 e seus parágrafos da Lei nº 13.869/2019, assinale a afirmativa correta:'),
(7,'cc71-01','435543fe-bdc2-452a-be2d-ffa414c5e27d',27,71,'facil','PAPIRO — DH-AUT-01 — cc71-01 — Lei 7.853/1989 art.8 par.3',
 'A operadora de um plano privado de assistência à saúde impôs regras administrativas especiais que resultaram em embaraço e recusa de adesão contratual a uma pessoa em razão exclusiva de sua deficiência, estipulando ainda a cobrança de mensalidade substancialmente majorada. À luz da Lei nº 7.853/1989, a conduta descrita:'),
(8,'cc73-01','392fd9fe-a3d2-4062-b912-0a299b414429',102,73,'facil','PAPIRO — DH-AUT-01 — cc73-01 — Lei 9.455/1997 art.1 par.2',
 'Um agente público investido do dever legal de fiscalizar a custódia de presos presencia atos reiterados de violência física praticados por terceiros contra um detento, com o intuito de obter confissão. Ciente do ocorrido e dispondo de meios concretos e imediatos para agir, esse agente voluntariamente se abstém de intervir e de adotar qualquer providência posterior para apurar o delito. De acordo com a Lei nº 9.455/1997, a conduta desse agente omisso:'),
(9,'cc73-02','392fd9fe-a3d2-4062-b912-0a299b414429',102,73,'media','PAPIRO — DH-AUT-01 — cc73-02 — Lei 9.455/1997 art.2',
 'Em território estrangeiro, um cidadão brasileiro é vítima de atos de tortura executados por agentes forâneos em razão de sua nacionalidade e atividade profissional. O crime não foi cometido no Brasil nem por agente a serviço do Estado brasileiro, mas a vítima encontrava-se em área de jurisdição externa. Em conformidade estrita com o art. 2º da Lei nº 9.455/1997, a lei aplicar-se-á ao fato:'),
(10,'cc73-03','392fd9fe-a3d2-4062-b912-0a299b414429',102,73,'dificil','PAPIRO — DH-AUT-01 — cc73-03 — Lei 9.455/1997 art.1 III (Lei 15.410/2026)',
 'No âmbito de sua convivência matrimonial e prevalecendo-se das relações domésticas, um homem submete de modo continuado e reiterado sua esposa a agressões corporais severas e torturas psicológicas constantes, provocando-lhe intenso sofrimento físico e mental como forma de humilhação e castigo habitual, sem prejuízo de outros ilícitos penais perpetrados no mesmo período. Considerando as disposições vigentes da Lei nº 9.455/1997, a conduta descrita:'),
(11,'cc73-04','392fd9fe-a3d2-4062-b912-0a299b414429',102,73,'media','PAPIRO — DH-AUT-01 — cc73-04 — Lei 9.455/1997 art.1 par.5/6',
 'Um agente penitenciário foi condenado em caráter definitivo pela prática de crime de tortura cometido no exercício de suas atribuições. A respeito dos efeitos dessa condenação e das garantias penais aplicáveis, conforme a Lei nº 9.455/1997:'),
(12,'cc73-05','392fd9fe-a3d2-4062-b912-0a299b414429',102,73,'media','PAPIRO — DH-AUT-01 — cc73-05 — Lei 9.455/1997 art.1 par.4 I',
 'No que concerne às causas de aumento de pena disciplinadas na Lei nº 9.455/1997, aumenta-se a pena de um sexto até um terço se o crime de tortura:'),
(13,'cc74-01','8d4e4b20-37ac-4df0-a7ac-57cb016c44d6',85,74,'facil','PAPIRO — DH-AUT-01 — cc74-01 — PIDCP art.9 item5',
 'O Pacto Internacional sobre Direitos Civis e Políticos, promulgado pelo Decreto nº 592/1992, estabelece garantias essenciais relativas à liberdade e à segurança pessoais. Segundo o art. 9º, item 5, qualquer pessoa que tenha sido vítima de prisão ou detenção ilegal:'),
(14,'cc74-02','8d4e4b20-37ac-4df0-a7ac-57cb016c44d6',85,74,'media','PAPIRO — DH-AUT-01 — cc74-02 — PIDCP art.10 item1',
 'No que concerne ao regime de execução das medidas de custódia e ao tratamento daqueles submetidos à restrição de locomoção, o art. 10, item 1, do PIDCP preconiza que:'),
(15,'cc74-03','8d4e4b20-37ac-4df0-a7ac-57cb016c44d6',85,74,'media','PAPIRO — DH-AUT-01 — cc74-03 — PIDCP art.11',
 'Um cidadão celebrou contrato de compra e venda de bens móveis com um particular. Em razão de desemprego superveniente, tornou-se inadimplente. O credor requereu em juízo a prisão do devedor para coagi-lo ao pagamento. À luz do art. 11 do PIDCP, a pretensão de prisão:'),
(16,'cc74-04','8d4e4b20-37ac-4df0-a7ac-57cb016c44d6',85,74,'dificil','PAPIRO — DH-AUT-01 — cc74-04 — PIDCP art.6 item1',
 'O art. 6º, item 1, do PIDCP enuncia os contornos basilares da proteção internacional à vida humana. De acordo com a disciplina desse dispositivo:'),
(17,'cc74-05','8d4e4b20-37ac-4df0-a7ac-57cb016c44d6',85,74,'dificil','PAPIRO — DH-AUT-01 — cc74-05 — PIDCP art.7',
 'Sob o prisma do art. 7º do PIDCP, a proteção conferida ao indivíduo abrange a seguinte vedação expressa:'),
(18,'cc74-06','8d4e4b20-37ac-4df0-a7ac-57cb016c44d6',85,74,'dificil','PAPIRO — DH-AUT-01 — cc74-06 — PIDCP arts.7 e 10 item1',
 'Ao analisar a estrutura dos direitos de proteção à integridade e à custódia previstos no PIDCP, constata-se relação sistemática entre os arts. 7º e 10, item 1. A respeito da distinção e do alcance desses preceitos, é correto afirmar que:'),
(19,'cc74-07','8d4e4b20-37ac-4df0-a7ac-57cb016c44d6',85,74,'media','PAPIRO — DH-AUT-01 — cc74-07 — PIDCP arts.9 item5/10 item1/11',
 'Considere as afirmativas: I. Qualquer pessoa vítima de prisão ou encarceramento ilegais terá direito à reparação. II. Toda pessoa privada de sua liberdade deverá ser tratada com humanidade e com respeito à dignidade inerente à pessoa humana. III. Ninguém poderá ser preso apenas por não poder cumprir com uma obrigação contratual. Está correto o que se afirma em:'),
(20,'cc75-01','128d9183-6188-4ca1-abdb-fc5c57e78d28',94,75,'facil','PAPIRO — DH-AUT-01 — cc75-01 — Lei 13.146/2015 art.85 caput',
 'A Lei Brasileira de Inclusão da Pessoa com Deficiência redefiniu substancialmente o instituto da curatela. Consoante o art. 85, caput, a curatela afetará tão somente os atos relacionados aos direitos de natureza:'),
(21,'cc75-02','128d9183-6188-4ca1-abdb-fc5c57e78d28',94,75,'media','PAPIRO — DH-AUT-01 — cc75-02 — Lei 13.146/2015 art.85 par.1 (corpo/sexualidade/matrimônio)',
 'Uma pessoa maior de idade com deficiência foi submetida judicialmente à curatela. Meses depois, manifestou vontade de se casar e de decidir sobre cuidados médicos relativos ao próprio corpo e à sexualidade. À luz do art. 85, §1º, a definição desses atos:'),
(22,'cc75-03','128d9183-6188-4ca1-abdb-fc5c57e78d28',94,75,'media','PAPIRO — DH-AUT-01 — cc75-03 — Lei 13.146/2015 art.85 par.1 (privacidade/educação/saúde)',
 'Determinado curador, instituído para gerir os bens de um adulto com deficiência, pretendeu proibi-lo de frequentar curso educacional de sua escolha e passou a violar sua correspondência privada e suas consultas médicas, sob a alegação de que a sentença de curatela lhe conferiu representação universal sobre a vida do curatelado. Considerando o art. 85, §1º, a conduta do curador é juridicamente:'),
(23,'cc75-04','128d9183-6188-4ca1-abdb-fc5c57e78d28',94,75,'facil','PAPIRO — DH-AUT-01 — cc75-04 — Lei 13.146/2015 art.85 par.1 (trabalho/voto)',
 'No que concerne aos efeitos jurídicos da curatela sobre a cidadania da pessoa com deficiência, o art. 85, §1º, dispõe expressamente que a definição da curatela não alcança o direito:'),
(24,'cc75-05','128d9183-6188-4ca1-abdb-fc5c57e78d28',94,75,'media','PAPIRO — DH-AUT-01 — cc75-05 — Lei 13.146/2015 art.3 XIII',
 'Para os fins da Lei nº 13.146/2015, o "profissional de apoio escolar" é legalmente definido como a pessoa que:'),
(25,'cc75-06','128d9183-6188-4ca1-abdb-fc5c57e78d28',94,75,'dificil','PAPIRO — DH-AUT-01 — cc75-06 — Lei 13.146/2015 arts.6/85',
 'Um cidadão adulto com deficiência intelectual encontra-se sujeito à curatela deferida judicialmente. Ele decide casar-se e, concomitantemente, pretende alienar um imóvel de elevado valor recebido por herança para integralizar capital em sociedade empresária. Com base na Lei nº 13.146/2015, assinale a correta:'),
(26,'cc75-07','128d9183-6188-4ca1-abdb-fc5c57e78d28',94,75,'media','PAPIRO — DH-AUT-01 — cc75-07 — Lei 13.146/2015 art.84 par.3',
 'Segundo o art. 84, §3º, da Lei nº 13.146/2015, a definição de curatela de pessoa com deficiência constitui medida:'),
(27,'cc76-01','325c5ca6-8165-472f-b02b-eb7b18c6f71d',25,76,'media','PAPIRO — DH-AUT-01 — cc76-01 — CF art.5 XI',
 'Durante o dia, policiais militares receberam mandado de busca e apreensão expedido por autoridade judiciária competente para ingressar na residência de um suspeito de furto continuado. O morador recusou-se a franquear a entrada. À luz do art. 5º, XI, os agentes:'),
(28,'cc76-02','325c5ca6-8165-472f-b02b-eb7b18c6f71d',25,76,'media','PAPIRO — DH-AUT-01 — cc76-02 — CF art.5 XIV',
 'Um jornalista publicou reportagem investigativa baseada em documentos recebidos de informante anônimo. Intimado a revelar a fonte sob pena de prisão, recusou-se. À luz do art. 5º, XIV, a recusa é:'),
(29,'cc76-03','325c5ca6-8165-472f-b02b-eb7b18c6f71d',25,76,'facil','PAPIRO — DH-AUT-01 — cc76-03 — CF art.5 XX',
 'Uma associação de moradores exigiu compulsoriamente que todos os proprietários locais se filiassem, com sanções patrimoniais aos que pretendessem se desfiliar. Nos termos do art. 5º, XX:'),
(30,'cc76-04','325c5ca6-8165-472f-b02b-eb7b18c6f71d',25,76,'facil','PAPIRO — DH-AUT-01 — cc76-04 — CF art.3 III',
 'O art. 3º da Constituição Federal de 1988 elenca os objetivos fundamentais da República Federativa do Brasil. Constitui expressamente um objetivo fundamental previsto no art. 3º, inciso III:'),
(31,'cc76-05','325c5ca6-8165-472f-b02b-eb7b18c6f71d',25,76,'dificil','PAPIRO — DH-AUT-01 — cc76-05 — CF arts.3 e 4 III',
 'A Constituição Federal estabelece, no Título I, preceitos que orientam tanto a atuação estatal interna quanto a conduta do Brasil perante a comunidade internacional. A respeito da distinção sistemática entre os objetivos fundamentais da República e os princípios das relações internacionais, assinale a correta:');

create temporary table _lote_explicacoes (ordem int primary key, explicacao text) on commit drop;
insert into _lote_explicacoes (ordem, explicacao) values
(1, E'GABARITO: alternativa E\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nA alternativa E reproduz fielmente o art. 4º, I, da Lei nº 13.869/2019: "tornar certa a obrigação de indenizar o dano causado pelo crime, devendo o juiz, a requerimento do ofendido, fixar na sentença o valor mínimo para reparação dos danos causados pela infração, considerando os prejuízos por ele sofridos."\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA: a perda do cargo (art.4º,II) não é automática (parágrafo único).\nB: a inabilitação (art.4º,III) é de 1 a 5 anos, não dez fixos.\nC: não existe cassação de direitos políticos prevista.\nD: prestação de serviços não é efeito do art. 4º.'),
(2, E'GABARITO: alternativa A\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO parágrafo único do art. 4º da Lei nº 13.869/2019 condiciona os efeitos dos incisos II e III à reincidência específica em crime de abuso de autoridade, vedando a automaticidade e exigindo motivação expressa na sentença.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nB, C, D e E contrariam um ou mais desses três requisitos cumulativos (reincidência específica, não automaticidade, motivação expressa).'),
(3, E'GABARITO: alternativa D\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO art. 16, parágrafo único, da Lei nº 13.869/2019 estabelece: "Incorre na mesma pena quem, como responsável por interrogatório em sede de procedimento investigatório de infração penal, deixa de identificar-se ao preso ou atribui a si mesmo falsa identidade, cargo ou função." O cenário também satisfaz o elemento subjetivo geral do art. 1º, §1º, da mesma lei — a conduta foi praticada com a finalidade específica de prejudicar o preso, uma das finalidades alternativas exigidas para a configuração de qualquer crime de abuso de autoridade —, mas esse dispositivo é pressuposto geral, não a habilidade determinante desta questão, que permanece o art. 16, parágrafo único.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA, B, C, E descaracterizam a tipicidade formal e autônoma do dispositivo.'),
(4, E'GABARITO: alternativa C\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO art. 15-A, caput, da Lei nº 13.869/2019 tipifica submeter a vítima de infração penal ou a testemunha de crimes violentos a procedimentos desnecessários, repetitivos ou invasivos, que a leve a reviver, sem estrita necessidade, a situação de violência ou outras situações potencialmente geradoras de sofrimento ou estigmatização. O cenário também satisfaz o elemento subjetivo geral do art. 1º, §1º (finalidade específica de prejudicar a testemunha), pressuposto geral da lei, sem deslocar a habilidade determinante do art. 15-A.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA, B, D, E descaracterizam o bem jurídico tutelado pelo art. 15-A.'),
(5, E'GABARITO: alternativa D\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nTranscreve com exatidão o art. 23, caput, da Lei nº 13.869/2019: "Inovar artificiosamente, no curso de diligência, de investigação ou de processo, o estado de lugar, de coisa ou de pessoa, com o fim de eximir-se de responsabilidade ou de responsabilizar criminalmente alguém ou agravar-lhe a responsabilidade."\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA, B, C, E não correspondem à conduta narrada nem a qualquer tipo penal descrito na Lei nº 13.869/2019.'),
(6, E'GABARITO: alternativa E\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nTexto oficial exato do art. 22, §2º: "Não haverá crime se o ingresso for para prestar socorro, ou quando houver fundados indícios que indiquem a necessidade do ingresso em razão de situação de flagrante delito ou de desastre."\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA, B, C, D contrariam essa excludente expressa de tipicidade.'),
(7, E'GABARITO: alternativa D\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO art. 8º, §3º, da Lei nº 7.853/1989 (incluído pela Lei nº 13.146/2015) é expresso ao punir com as mesmas penas do caput quem impede ou dificulta o ingresso de pessoa com deficiência em planos privados de assistência à saúde, inclusive com cobrança de valores diferenciados.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA, B, C, E descaracterizam a tipicidade penal expressa do §3º.'),
(8, E'GABARITO: alternativa E\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nTexto oficial exato do art. 1º, §2º, da Lei nº 9.455/1997: "Aquele que se omite em face dessas condutas, quando tinha o dever de evitá-las ou apurá-las, incorre na pena de detenção de um a quatro anos."\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA, B, C, D contrariam a tipificação omissiva própria e a pena específica do §2º.'),
(9, E'GABARITO: alternativa B\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nTexto oficial exato do art. 2º da Lei nº 9.455/1997: "O disposto nesta Lei aplica-se ainda quando o crime não tenha sido cometido em território nacional, sendo a vítima brasileira ou encontrando-se o agente em local sob jurisdição brasileira."\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA, C, D, E inventam condicionantes inexistentes na norma de extraterritorialidade.'),
(10, E'GABARITO: alternativa B\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO art. 1º, III, da Lei nº 9.455/1997 (incluído pela Lei nº 15.410/2026, vigente) tipifica: "submeter mulher, reiteradamente, a intenso sofrimento físico ou mental, no contexto de violência doméstica e familiar, sem prejuízo da aplicação das penas correspondentes a outras infrações penais."\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA: a conduta atinge gravidade de crime de tortura, não mera contravenção.\nC: o inciso III não exige finalidade de obtenção de confissão (isso é o inciso I,a).\nD: a figura independe de qualidade de agente público.\nE: a norma expressamente afasta a consunção por outras infrações penais.'),
(11, E'GABARITO: alternativa C\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nTextos oficiais exatos: §5º ("a condenação acarretará a perda do cargo, função ou emprego público e a interdição para seu exercício pelo dobro do prazo da pena aplicada") e §6º ("o crime de tortura é inafiançável e insuscetível de graça ou anistia").\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA, B, D, E contrariam um ou ambos os dispositivos.'),
(12, E'GABARITO: alternativa A\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nTexto oficial exato do art. 1º, §4º, I: "aumenta-se a pena de um sexto até um terço se o crime é cometido por agente público."\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nB, C, D, E não correspondem a nenhuma majorante do §4º da Lei nº 9.455/1997.'),
(13, E'GABARITO: alternativa D\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nTexto oficial exato do art. 9º, item 5, do PIDCP (Decreto 592/1992): "Qualquer pessoa vítima de prisão ou encarceramento ilegais terá direito à reparação."\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA, B, C, E inventam condições ou formatos de reparação não previstos no tratado.'),
(14, E'GABARITO: alternativa D\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nTexto oficial exato do art. 10, item 1, do PIDCP: "Toda pessoa privada de sua liberdade deverá ser tratada com humanidade e com respeito à dignidade inerente à pessoa humana."\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA, B, C, E contrariam a garantia incondicional de tratamento digno a toda pessoa privada de liberdade.'),
(15, E'GABARITO: alternativa B\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nTexto oficial exato do art. 11 do PIDCP: "Ninguém poderá ser preso apenas por não poder cumprir com uma obrigação contratual."\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA, C, D, E criam exceções inexistentes à vedação absoluta de prisão civil por dívida contratual.'),
(16, E'GABARITO: alternativa C\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nTexto oficial exato do art. 6º, item 1, do PIDCP: "O direito à vida é inerente à pessoa humana. Este direito deverá ser protegido pela lei. Ninguém poderá ser arbitrariamente privado de sua vida."\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA, B, D, E contrariam a inderrogabilidade e a titularidade universal do direito à vida.'),
(17, E'GABARITO: alternativa E\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nTexto oficial exato do art. 7º do PIDCP: "Ninguém poderá ser submetido à tortura, nem a penas ou tratamento cruéis, desumanos ou degradantes. Será proibido, sobretudo, submeter uma pessoa, sem seu livre consentimento, a experiências médicas ou científicas."\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA, B, C, D não correspondem ao conteúdo do art. 7º.'),
(18, E'GABARITO: alternativa C\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO art. 7º consagra uma proibição geral dirigida a qualquer pessoa (vedando tortura, penas ou tratamentos cruéis, desumanos ou degradantes); o art. 10, item 1, veicula comando específico aplicável a toda pessoa privada de liberdade, impondo tratamento humano e respeito à dignidade inerente. Não há antinomia — os dispositivos convivem cumulativamente.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA, B, D, E distorcem o âmbito de aplicação ou a relação entre os dois artigos.'),
(19, E'GABARITO: alternativa B\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nAs três assertivas correspondem corretamente ao conteúdo dos arts. 9º, item 5, 10, item 1, e 11 do PIDCP, todos confirmados na fonte oficial (Decreto 592/1992).\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA, C, D, E excluem indevidamente alguma das três assertivas verdadeiras.'),
(20, E'GABARITO: alternativa A\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nTexto oficial exato do art. 85, caput, da Lei nº 13.146/2015: "A curatela afetará tão somente os atos relacionados aos direitos de natureza patrimonial e negocial."\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nB, C, D, E extrapolam o recorte estritamente patrimonial/negocial da curatela.'),
(21, E'GABARITO: alternativa C\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nTexto oficial exato do art. 85, §1º: "A definição da curatela não alcança o direito ao próprio corpo, à sexualidade, ao matrimônio, à privacidade, à educação, à saúde, ao trabalho e ao voto."\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA, B, D, E atribuem ao curador poderes sobre direitos existenciais que a lei expressamente preserva.'),
(22, E'GABARITO: alternativa B\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nTexto oficial exato do art. 85, §1º, que preserva expressamente privacidade, educação e saúde da abrangência da curatela.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA, C, D, E legitimam indevidamente a ingerência do curador sobre esses direitos existenciais.'),
(23, E'GABARITO: alternativa E\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO art. 85, §1º, resguarda explicitamente os direitos ao trabalho e ao voto da abrangência da curatela.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA, B, C, D descrevem atos de natureza patrimonial/negocial, efetivamente alcançados pela curatela (art.85,caput), ao contrário de trabalho e voto.'),
(24, E'GABARITO: alternativa A\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nTexto oficial exato do art. 3º, XIII, da Lei nº 13.146/2015, incluindo a expressão final "profissões legalmente estabelecidas".\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nB, C, D, E atribuem ao profissional de apoio escolar funções privativas de outras profissões, o que a lei expressamente exclui.'),
(25, E'GABARITO: alternativa B\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO art. 6º, I, assegura o direito de casar-se; o art. 85, §1º, preserva o matrimônio da abrangência da curatela; o art. 85, caput, restringe a curatela a atos patrimoniais e negociais, no qual se insere a alienação imobiliária para integralização de capital.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA, C, D, E invertem a distribuição legal entre autonomia existencial (preservada) e atos patrimoniais (sujeitos à curatela).'),
(26, E'GABARITO: alternativa C\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nTexto oficial exato do art. 84, §3º: "A definição de curatela de pessoa com deficiência constitui medida protetiva extraordinária, proporcional às necessidades e às circunstâncias de cada caso, e durará o menor tempo possível."\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA, B, D, E contrariam a natureza extraordinária, proporcional e temporalmente limitada da curatela.'),
(27, E'GABARITO: alternativa A\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nTexto constitucional exato do art. 5º, XI: "a casa é asilo inviolável do indivíduo, ninguém nela podendo penetrar sem consentimento do morador, salvo em caso de flagrante delito ou desastre, ou para prestar socorro, ou, durante o dia, por determinação judicial."\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nB, C, D, E contrariam a autorização expressa de ingresso diurno por determinação judicial, independente de consentimento.'),
(28, E'GABARITO: alternativa A\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nTexto constitucional exato do art. 5º, XIV: "é assegurado a todos o acesso à informação e resguardado o sigilo da fonte, quando necessário ao exercício profissional."\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nB, C, D, E contrariam a garantia constitucional expressa de sigilo da fonte jornalística.'),
(29, E'GABARITO: alternativa B\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nTexto constitucional exato do art. 5º, XX: "ninguém poderá ser compelido a associar-se ou a permanecer associado."\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA, C, D, E legitimam indevidamente a filiação ou permanência associativa compulsória, vedada pela Constituição.'),
(30, E'GABARITO: alternativa E\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO art. 3º, III, da CF/88 estabelece: "erradicar a pobreza e a marginalização e reduzir as desigualdades sociais e regionais."\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA, B, C correspondem, respectivamente, aos incisos I, II e IV do próprio art. 3º (objetivos fundamentais, mas de outros incisos). D corresponde ao art. 4º, III — princípio das relações internacionais, não objetivo fundamental do art. 3º.'),
(31, E'GABARITO: alternativa D\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO art. 4º, III, fixa a autodeterminação dos povos como princípio das relações internacionais; o art. 3º, I, fixa "construir uma sociedade livre, justa e solidária" como objetivo fundamental interno.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA, B, C, E invertem ou distorcem essa distribuição entre objetivos fundamentais (art.3º) e princípios de relações internacionais (art.4º).');

create temporary table _lote_alternativas (
  ordem int,
  ordem_alt smallint,
  texto text,
  correta boolean
) on commit drop;

insert into _lote_alternativas (ordem, ordem_alt, texto, correta) values
(1,1,'a perda compulsória do cargo público, operada de modo automático e independentemente de pedido expresso da vítima.',false),
(1,2,'a inabilitação para o exercício de cargo, mandato ou função pública pelo prazo fixo e improrrogável de dez anos.',false),
(1,3,'a cassação definitiva dos direitos políticos do condenado pelo período correspondente ao dobro da pena privativa de liberdade aplicada.',false),
(1,4,'a obrigação de prestar serviços comunitários exclusivamente junto a entidades de proteção aos direitos humanos.',false),
(1,5,'tornar certa a obrigação de indenizar o dano causado pelo crime, devendo o juiz, a requerimento do ofendido, fixar na sentença o valor mínimo para reparação dos prejuízos por este sofridos.',true),

(2,1,'Esses efeitos são condicionados à ocorrência de reincidência em crime de abuso de autoridade e não são automáticos, devendo ser declarados motivadamente na sentença.',true),
(2,2,'A perda do cargo opera-se de forma automática a partir do trânsito em julgado da condenação, ao passo que a inabilitação exige reincidência em qualquer delito comum doloso.',false),
(2,3,'A inabilitação prescinde de fundamentação expressa na sentença por se tratar de efeito secundário estritamente objetivo da pena privativa de liberdade.',false),
(2,4,'Ambos os efeitos podem incidir desde a primeira condenação, bastando que o magistrado justifique genericamente a gravidade em abstrato do crime de abuso de autoridade.',false),
(2,5,'A reincidência exigida pela lei para a incidência de tais efeitos abrange a condenação anterior transitada em julgado por qualquer crime hediondo.',false),

(3,1,'configura mera falta disciplinar residual, não havendo previsão penal expressa de abuso de autoridade quando o investigado está ciente de que o ato se realiza em repartição pública.',false),
(3,2,'subsume-se unicamente ao crime de falsa identidade do Código Penal, restando afastada a disciplina da Lei de Abuso de Autoridade por ausência de tipo penal especial.',false),
(3,3,'é atípica se o interrogando permanecer em silêncio durante todo o procedimento investigatório.',false),
(3,4,'amolda-se à conduta típica daquele que, sendo responsável pelo interrogatório em procedimento investigatório de infração penal, deixa de identificar-se ao preso ou atribui a si falsa identidade, cargo ou função.',true),
(3,5,'somente constituirá infração penal caso o ato resulte comprovadamente em confissão involuntária do interrogando.',false),

(4,1,'não tipifica crime, sendo admitida a repetição de atos inquisitoriais a critério exclusivo da autoridade na busca da verdade real.',false),
(4,2,'configura crime de constrangimento ilegal do Código Penal, visto que a Lei de Abuso de Autoridade não prevê proteção a testemunhas.',false),
(4,3,'configura o crime de abuso de autoridade consistente em submeter testemunha de crimes violentos a procedimentos desnecessários, repetitivos ou invasivos, que a leve a reviver, sem estrita necessidade, a situação de violência ou outras situações potencialmente geradoras de sofrimento ou estigmatização.',true),
(4,4,'é atípica se o Delegado comprovar que não houve lesão física à testemunha e que as perguntas se mantiveram no escopo do caso.',false),
(4,5,'tipifica crime de abuso de autoridade apenas se ficar provado o recebimento de vantagem econômica indevida pelo agente público.',false),

(5,1,'coação no curso do processo administrativo.',false),
(5,2,'dano qualificado ao patrimônio público.',false),
(5,3,'usurpação de função pública privativa da carreira pericial.',false),
(5,4,'inovar artificiosamente, no curso de diligência, de investigação ou de processo, o estado de lugar, de coisa ou de pessoa, com o fim de eximir-se de responsabilidade ou de responsabilizar criminalmente alguém ou agravar-lhe a responsabilidade.',true),
(5,5,'violação imotivada de sigilo funcional probatório.',false),

(6,1,'A conduta é criminosa, pois a lei só autoriza o ingresso noturno não consentido se houver ordem escrita e fundamentada do juiz competente.',false),
(6,2,'Houve crime consumado de abuso de autoridade, cabendo aos policiais unicamente postular o perdão judicial.',false),
(6,3,'O fato só deixa de ser crime se a prestação de socorro tiver sido precedida de autorização telefônica do delegado de plantão.',false),
(6,4,'Configura-se abuso de autoridade formal, atenuado unicamente pela inexistência de dolo de prejudicar o proprietário do imóvel.',false),
(6,5,'Não há crime de abuso de autoridade, porquanto a lei expressamente prevê que não haverá crime quando o ingresso for para prestar socorro, ou quando houver fundados indícios que indiquem a necessidade do ingresso em razão de situação de flagrante delito ou de desastre.',true),

(7,1,'constitui mero descumprimento de regulação setorial da agência reguladora de saúde, passível de sanção exclusivamente civil e administrativa.',false),
(7,2,'sujeita o responsável apenas à reparação moral na esfera cível, sendo atípica a discriminação contratual no âmbito estritamente privado.',false),
(7,3,'caracteriza crime apenas se a recusa decorrer de decisão colegiada da diretoria da operadora de saúde.',false),
(7,4,'faz incorrer nas mesmas penas cominadas aos crimes do art. 8º da referida lei quem impede ou dificulta o ingresso de pessoa com deficiência em planos privados de assistência à saúde, inclusive mediante cobrança de valores diferenciados.',true),
(7,5,'é formalmente ilícita, mas a lei isenta de pena os administradores caso comprovem cálculo atuarial de risco financeiro individual.',false),

(8,1,'sujeita o infrator às mesmas penas do autor direto da tortura, haja vista a incidência incondicional das regras gerais do concurso de pessoas.',false),
(8,2,'configura mera infração aos regulamentos penitenciários, haja vista que a lei especial só incrimina quem executa diretamente a tortura.',false),
(8,3,'subsume-se ao crime de prevaricação do Código Penal, restando afastada a disciplina da Lei nº 9.455/1997.',false),
(8,4,'é atípica se o preso já possuía condenação penal transitada em julgado.',false),
(8,5,'sujeita o infrator à pena de detenção de um a quatro anos, em virtude de sua omissão frente a fatos que tinha o dever de evitar ou apurar.',true),

(9,1,'unicamente se o autor da infração for funcionário diplomático brasileiro em missão oficial.',false),
(9,2,'ainda quando não cometido no território nacional, sendo a vítima brasileira ou encontrando-se o agente em local sob jurisdição brasileira.',true),
(9,3,'somente após autorização expressa do Conselho de Segurança das Nações Unidas ou do Tribunal Penal Internacional.',false),
(9,4,'desde que o fato também seja capitulado como contravenção penal segundo as leis do local da conduta.',false),
(9,5,'apenas se o autor do fato renunciar voluntariamente à jurisdição de seu país de origem perante autoridade consular.',false),

(10,1,'subsume-se exclusivamente a contravenção de vias de fato qualificada, por prevalecer o princípio da especialidade familiar.',false),
(10,2,'amolda-se ao crime de tortura consistente em submeter mulher, reiteradamente, a intenso sofrimento físico ou mental, no contexto de violência doméstica e familiar, sem prejuízo das penas correspondentes a outras infrações penais.',true),
(10,3,'não pode ser classificada como tortura, haja vista que a lei exige obrigatoriamente que a finalidade do agente seja a obtenção de confissão sobre crime precedente.',false),
(10,4,'depende, para ser tipificada como tortura, de que o agente público tenha participado como coautor dos atos.',false),
(10,5,'afasta a punibilidade de quaisquer outros crimes praticados em concurso, por absorção integral pela esfera cível da Lei Maria da Penha.',false),

(11,1,'a condenação acarreta a perda do cargo público somente se houver reincidência específica declarada pelo tribunal do júri.',false),
(11,2,'o crime admite concessão de fiança e liberdade provisória com arbitramento pelo delegado de polícia.',false),
(11,3,'a condenação acarretará a perda do cargo, função ou emprego público e a interdição para seu exercício pelo dobro do prazo da pena aplicada, sendo o crime inafiançável e insuscetível de graça ou anistia.',true),
(11,4,'a interdição para o exercício de cargo público opera-se pelo prazo fixo de três anos, admitindo-se a extinção da punibilidade por anistia parlamentar.',false),
(11,5,'a perda do cargo é faculdade judicial que pode ser substituída por admoestação escrita.',false),

(12,1,'é cometido por agente público.',true),
(12,2,'ocorre em período noturno ou em local ermo.',false),
(12,3,'é praticado mediante emprego de arma de fogo ou substância entorpecente.',false),
(12,4,'envolve mais de três agentes em associação previamente constituída.',false),
(12,5,'tem como resultado exclusivamente danos de natureza patrimonial contra a vítima.',false),

(13,1,'poderá pleitear retratação solene perante os tribunais, sem repercussão patrimonial direta.',false),
(13,2,'terá direito à anulação de seus antecedentes civis, cabendo reparação pecuniária unicamente se demonstrar insuficiência econômica.',false),
(13,3,'deverá submeter previamente o pedido a corte internacional de arbitragem antes do acesso à jurisdição local.',false),
(13,4,'terá direito a reparação.',true),
(13,5,'fará jus à percepção de pensão estatal vitalícia correspondente ao salário médio de sua categoria profissional.',false),

(14,1,'a privação da liberdade suspende automaticamente todos os direitos individuais do custodiado.',false),
(14,2,'os presos em regime fechado não titularizam garantias contra atos vexatórios.',false),
(14,3,'a dignidade pessoal de quem se encontra preso depende do cumprimento de metas de trabalho e bom comportamento.',false),
(14,4,'toda pessoa privada de sua liberdade deverá ser tratada com humanidade e com respeito à dignidade inerente à pessoa humana.',true),
(14,5,'o tratamento digno é exigível exclusivamente após sentença condenatória transitada em julgado.',false),

(15,1,'pode ser acolhida se o valor da dívida superar cinquenta salários mínimos.',false),
(15,2,'não pode ser acolhida, pois ninguém poderá ser preso apenas por não poder cumprir com uma obrigação contratual.',true),
(15,3,'é admissível pelo prazo máximo de trinta dias como medida executiva coercitiva atípica.',false),
(15,4,'depende unicamente de prévia notificação cartorária do débito.',false),
(15,5,'é legítima desde que o devedor não possua bens penhoráveis.',false),

(16,1,'o direito à vida pode ser suspenso de maneira ampla e irrestrita mediante simples ato administrativo em momentos de convulsão social.',false),
(16,2,'a vida é um direito disponível outorgado pelo Estado aos cidadãos que preencham requisitos de cidadania ativa.',false),
(16,3,'o direito à vida é inerente à pessoa humana; este direito deverá ser protegido pela lei; ninguém poderá ser arbitrariamente privado de sua vida.',true),
(16,4,'a privação da vida torna-se legítima sempre que decorrer de ato de autoridade policial, sem apuração das circunstâncias.',false),
(16,5,'os Estados Partes ficam desobrigados de prever em lei a salvaguarda da vida em políticas de emergência.',false),

(17,1,'proibição de aplicação de penas privativas de liberdade que ultrapassem dez anos.',false),
(17,2,'impedimento de condução coercitiva de testemunhas em processos de apuração funcional.',false),
(17,3,'impossibilidade de exames clínicos de rotina para ingresso em cursos de formação civis.',false),
(17,4,'vedação de impor trabalho penitenciário produtivo remunerado e regulado em lei.',false),
(17,5,'proibição de que qualquer pessoa seja submetida a tortura ou a penas ou tratamentos cruéis, desumanos ou degradantes, vedando-se em particular submeter alguém, sem seu livre consentimento, a experiências médicas ou científicas.',true),

(18,1,'o art. 7º aplica-se unicamente a indivíduos que estejam cumprindo pena em estabelecimentos prisionais militares.',false),
(18,2,'o art. 10, item 1, autoriza castigos corporais a detentos em caso de rebelião ou grave indisciplina.',false),
(18,3,'enquanto o art. 7º enuncia uma proibição geral dirigida a qualquer pessoa (vedando tortura, penas ou tratamentos cruéis, desumanos ou degradantes), o art. 10, item 1, veicula comando específico aplicável a toda pessoa privada de liberdade, impondo que seja tratada com humanidade e com respeito à dignidade inerente à pessoa humana.',true),
(18,4,'o art. 10, item 1, revoga a aplicação do art. 7º quanto aos indivíduos sob custódia cautelar.',false),
(18,5,'ambos os dispositivos vedam apenas o sofrimento físico visível, não alcançando violência moral ou psicológica.',false),

(19,1,'I, apenas.',false),
(19,2,'I, II e III.',true),
(19,3,'II, apenas.',false),
(19,4,'III, apenas.',false),
(19,5,'I e II, apenas.',false),

(20,1,'patrimonial e negocial.',true),
(20,2,'existencial e personalíssima.',false),
(20,3,'política e eleitoral.',false),
(20,4,'penal e sancionatória.',false),
(20,5,'familiar pura e afetiva.',false),

(21,1,'transfere-se inteiramente ao curador, a quem compete consentir ou recusar tais atos.',false),
(21,2,'exige anuência prévia e expressa do Ministério Público para ter validade jurídica.',false),
(21,3,'não é alcançada pela curatela, que não priva a pessoa da titularidade e do exercício dessas decisões existenciais.',true),
(21,4,'depende de laudo pericial atestando plena capacidade financeira da pessoa curatelada.',false),
(21,5,'subordina-se à concordância unânime dos ascendentes de primeiro grau do curatelado.',false),

(22,1,'age corretamente, porquanto os ditames da educação, por demandarem investimento financeiro, e os da saúde se encontram abarcados pela curatela.',false),
(22,2,'excede seus poderes legais, visto que o alcance da curatela afeta atos negociais ou patrimoniais, não alcançando o direito à privacidade, à educação e à saúde.',true),
(22,3,'age validamente, desde que preste contas anuais dos gastos efetuados nessas áreas perante o juiz da interdição.',false),
(22,4,'está amparado pela presunção legal de incapacidade existencial total atribuída a todo indivíduo submetido a curatela.',false),
(22,5,'age corretamente, salvo se o curatelado tiver concluído anteriormente ensino superior com diploma reconhecido.',false),

(23,1,'à alienação de bens imóveis sem prévia avaliação judicial.',false),
(23,2,'à celebração desregulada de empréstimos bancários consignados de alto risco financeiro.',false),
(23,3,'ao encerramento unilateral de contas correntes bancárias conjuntas.',false),
(23,4,'à outorga de procuração irrevogável de cunho exclusivamente comercial.',false),
(23,5,'ao trabalho e ao voto.',true),

(24,1,'exerce atividades de alimentação, higiene e locomoção do estudante com deficiência e atua em todas as atividades escolares nas quais se fizer necessária, em todos os níveis e modalidades de ensino, em instituições públicas e privadas, excluídas as técnicas ou os procedimentos identificados com profissões legalmente estabelecidas.',true),
(24,2,'substitui o professor regente da classe comum nas atividades pedagógicas formais e na elaboração de provas e notas avaliativas do aluno com deficiência.',false),
(24,3,'atua exclusivamente como terapeuta ocupacional habilitado, aplicando procedimentos clínicos de reabilitação psicossocial dentro da sala de aula.',false),
(24,4,'desempenha tarefas de segurança patrimonial e condução de veículos automotores adaptados vinculados à entidade educacional.',false),
(24,5,'desempenha unicamente tarefas em escolas especiais que atendam de forma exclusiva estudantes com deficiência auditiva severa.',false),

(25,1,'Ambos os atos são nulos de pleno direito se praticados pessoalmente pelo cidadão com deficiência, pois a curatela acarreta a incapacidade civil total.',false),
(25,2,'A deficiência e a existência de curatela não afetam a plena capacidade civil para casar-se ou constituir união estável, mantendo-se a autonomia existencial pessoal; contudo, a alienação do imóvel sujeita-se à curatela por se tratar de ato estritamente patrimonial e negocial.',true),
(25,3,'O casamento depende de prévia anuência do curador, ao passo que a alienação do imóvel pode ser feita livremente pelo curatelado por envolver patrimônio herdado.',false),
(25,4,'A celebração do casamento é obstada enquanto persistir a curatela, cabendo ao curador apenas autorizar a participação do indivíduo em união estável informal.',false),
(25,5,'A alienação do bem independe do curador caso o negócio societário traga lucro presumido, mas o casamento exige homologação judicial compulsória.',false),

(26,1,'ordinária e compulsória a todo portador de laudo médico de impedimento de longo prazo.',false),
(26,2,'punitiva e sancionatória, voltada a resguardar os herdeiros necessários contra dissipação patrimonial.',false),
(26,3,'protetiva extraordinária, proporcional às necessidades e circunstâncias de cada caso, devendo durar o menor tempo possível.',true),
(26,4,'irrevogável e definitiva a partir do trânsito em julgado da decisão de interdição.',false),
(26,5,'discricionária de polícia administrativa, aplicada diretamente por termo de compromisso perante a autoridade policial.',false),

(27,1,'podem ingressar licitamente na residência mesmo sem o consentimento do morador, pois a determinação judicial autoriza a entrada durante o dia.',true),
(27,2,'não podem ingressar no domicílio sem consentimento sob nenhuma hipótese durante o dia, cabendo o cumprimento do mandado apenas durante a noite.',false),
(27,3,'só poderiam ingressar no domicílio se o crime investigado fosse hediondo, sendo o mandado judicial ineficaz para apurar delitos patrimoniais comuns.',false),
(27,4,'necessitam de prévia autorização da chefia do Executivo local para validar a ordem emanada do Poder Judiciário.',false),
(27,5,'cometerão crime inafiançável de violação de domicílio caso ingressem no imóvel sem que haja concordância escrita de dois vizinhos presentes.',false),

(28,1,'juridicamente legítima, pois é assegurado a todos o acesso à informação e resguardado o sigilo da fonte, quando necessário ao exercício profissional.',true),
(28,2,'ilícita, pois o sigilo profissional sucumbe obrigatoriamente a qualquer apuração realizada em sede de inquérito policial.',false),
(28,3,'válida apenas se houver registro prévio da matéria em cartório de títulos e documentos antes de sua veiculação pública.',false),
(28,4,'ilegítima, visto que a Constituição Federal só confere sigilo profissional a advogados e médicos.',false),
(28,5,'nula, haja vista que a liberdade de informação veda terminantemente a utilização de dados repassados por pessoas não identificadas.',false),

(29,1,'a filiação a associações de caráter local é obrigatória para todos os proprietários de imóveis situados no perímetro urbano.',false),
(29,2,'ninguém poderá ser compelido a associar-se ou a permanecer associado.',true),
(29,3,'a obrigatoriedade associativa pode ser imposta por simples estatuto privado registrado em cartório de pessoas jurídicas.',false),
(29,4,'a desfiliação só pode ocorrer caso a assembleia geral dos demais associados a autorize por maioria absoluta.',false),
(29,5,'o direito de não permanecer associado restringe-se exclusivamente aos membros de partidos políticos constituídos.',false),

(30,1,'construir uma sociedade livre, justa e solidária.',false),
(30,2,'garantir o desenvolvimento nacional.',false),
(30,3,'promover o bem de todos, sem preconceitos de origem, raça, sexo, cor, idade e quaisquer outras formas de discriminação.',false),
(30,4,'a autodeterminação dos povos, princípio que rege as relações internacionais do Brasil.',false),
(30,5,'erradicar a pobreza e a marginalização e reduzir as desigualdades sociais e regionais.',true),

(31,1,'A autodeterminação dos povos constitui objetivo fundamental da República previsto no art. 3º, ao passo que a erradicação da pobreza orienta exclusivamente as relações diplomáticas externas do art. 4º.',false),
(31,2,'A promoção do bem de todos, sem preconceitos de origem, raça, sexo, cor, idade e quaisquer outras formas de discriminação, configura princípio das relações internacionais expressamente elencado no art. 4º.',false),
(31,3,'Todos os preceitos arrolados no art. 3º possuem natureza puramente programática externa, sem aplicabilidade às políticas públicas executivas em âmbito federativo interno.',false),
(31,4,'A autodeterminação dos povos rege a República Federativa do Brasil em suas relações internacionais (art. 4º, III), ao passo que a construção de uma sociedade livre, justa e solidária constitui objetivo fundamental interno da República (art. 3º, I).',true),
(31,5,'A redução das desigualdades sociais e regionais e a autodeterminação dos povos integram o mesmo inciso de metas do art. 3º da Carta Política.',false);

-- Precondicoes.
do $$
declare
  v_cnt int;
  v_dup int;
begin
  select count(*) into v_cnt from _lote_questoes;
  insert into _relatorio values ('staging_tem_31_questoes', v_cnt = 31, format('staging=%s (esperado 31)', v_cnt));

  select count(*) into v_dup
  from _lote_questoes lq
  where exists (select 1 from public.questoes q where q.enunciado = lq.enunciado);
  insert into _relatorio values ('sem_enunciado_identico_previo', v_dup = 0, format('%s enunciado(s) identicos ja existem no banco', v_dup));

  select count(*) into v_dup
  from _lote_questoes lq
  where not exists (select 1 from public.unidades_pedagogicas u where u.id = lq.unidade_id and u.ativa);
  insert into _relatorio values ('unidade_alvo_existe_e_ativa', v_dup = 0, format('%s linha(s) com unidade-alvo inexistente ou inativa', v_dup));

  select count(*) into v_dup
  from _lote_questoes lq
  join public.unidades_pedagogicas u on u.id = lq.unidade_id
  join public.curso_conteudos cc on cc.id = u.curso_conteudo_id
  where cc.assunto_id is distinct from lq.assunto_id;
  insert into _relatorio values ('assunto_id_compativel_com_unidade', v_dup = 0, format('%s linha(s) com assunto_id divergente da unidade-alvo', v_dup));

  select count(*) into v_dup from _lote_questoes where dificuldade not in ('facil','media','dificil');
  insert into _relatorio values ('dificuldade_dominio_valido', v_dup = 0, format('%s linha(s) com dificuldade fora do dominio', v_dup));

  insert into _relatorio values ('staging_cc70_6', (select count(*) from _lote_questoes where cc_id=70) = 6, 'cc70 deve ter 6 questoes no staging');
  insert into _relatorio values ('staging_cc71_1', (select count(*) from _lote_questoes where cc_id=71) = 1, 'cc71 deve ter 1 questao no staging');
  insert into _relatorio values ('staging_cc73_5', (select count(*) from _lote_questoes where cc_id=73) = 5, 'cc73 deve ter 5 questoes no staging');
  insert into _relatorio values ('staging_cc74_7', (select count(*) from _lote_questoes where cc_id=74) = 7, 'cc74 deve ter 7 questoes no staging');
  insert into _relatorio values ('staging_cc75_7', (select count(*) from _lote_questoes where cc_id=75) = 7, 'cc75 deve ter 7 questoes no staging');
  insert into _relatorio values ('staging_cc76_5', (select count(*) from _lote_questoes where cc_id=76) = 5, 'cc76 deve ter 5 questoes no staging');

  insert into _relatorio values ('cc70_estado_antes_esperado', (select cc70_uteis from _snapshot_antes) = 4, format('cc70_uteis=%s (esperado 4)', (select cc70_uteis from _snapshot_antes)));
  insert into _relatorio values ('cc71_estado_antes_esperado', (select cc71_uteis from _snapshot_antes) = 9, format('cc71_uteis=%s (esperado 9)', (select cc71_uteis from _snapshot_antes)));
  insert into _relatorio values ('cc73_estado_antes_esperado', (select cc73_uteis from _snapshot_antes) = 5, format('cc73_uteis=%s (esperado 5)', (select cc73_uteis from _snapshot_antes)));
  insert into _relatorio values ('cc74_estado_antes_esperado', (select cc74_uteis from _snapshot_antes) = 3, format('cc74_uteis=%s (esperado 3)', (select cc74_uteis from _snapshot_antes)));
  insert into _relatorio values ('cc75_estado_antes_esperado', (select cc75_uteis from _snapshot_antes) = 3, format('cc75_uteis=%s (esperado 3)', (select cc75_uteis from _snapshot_antes)));
  insert into _relatorio values ('cc76_estado_antes_esperado', (select cc76_uteis from _snapshot_antes) = 5, format('cc76_uteis=%s (esperado 5)', (select cc76_uteis from _snapshot_antes)));
end $$;

-- Insercao das questoes + alternativas.
create temporary table _mapa_ids (ordem int primary key, questao_id bigint) on commit drop;

do $$
declare r record; v_id bigint;
begin
  for r in select * from _lote_questoes order by ordem loop
    insert into public.questoes (materia_id, assunto_id, banca, concurso, ano, enunciado, dificuldade, explicacao, fonte, ativa, gerada_por_ia)
    values (11, r.assunto_id, 'Papiro', 'PAPIRO - Curadoria DH-AUT-01 - BM RS', 2026, r.enunciado, r.dificuldade,
            (select explicacao from _lote_explicacoes le where le.ordem = r.ordem),
            r.fonte, true, false)
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
    begin
      perform public.classificar_questao_unidade_admin(r.questao_id, r.unidade_id);
    exception when others then
      insert into _relatorio values ('rpc_sem_erro', false, format('erro ao classificar questao_id=%s: %s', r.questao_id, sqlerrm));
    end;
  end loop;
end $$;

-- Pos-condicoes.
do $$
declare
  v_novas_questoes int;
  v_novas_alternativas int;
  v_corretas_invalidas int;
  v_novos_vinculos int;
  v_multiunidade int;
  v_nao_autoral int;
  v_facil int; v_media int; v_dificil int;
  v_A int; v_B int; v_C int; v_D int; v_E int;
  v_cc70_uteis int; v_cc71_uteis int; v_cc73_uteis int; v_cc74_uteis int; v_cc75_uteis int; v_cc76_uteis int;
  v_cc70_real int; v_cc71_real int; v_cc73_real int; v_cc74_real int; v_cc75_real int; v_cc76_real int;
  v_dh_uteis_depois int;
  v_vinculo_errado int;
begin
  select count(*) into v_novas_questoes from public.questoes where id in (select questao_id from _mapa_ids);
  insert into _relatorio values ('31_questoes_criadas', v_novas_questoes = 31, format('questoes novas=%s (esperado 31)', v_novas_questoes));

  insert into _relatorio values ('materia_11', (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and materia_id <> 11) = 0, 'materia_id deve ser 11 nas 31');
  insert into _relatorio values ('assunto_ids_corretos', (select count(*) from public.questoes q join _mapa_ids m on m.questao_id = q.id join _lote_questoes lq on lq.ordem = m.ordem where q.assunto_id <> lq.assunto_id) = 0, 'assunto_id de cada questao deve bater com o staging');
  insert into _relatorio values ('ativas', (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and ativa is distinct from true) = 0, 'ativa deve ser true nas 31');

  select count(*) into v_nao_autoral from public.questoes where id in (select questao_id from _mapa_ids) and coalesce(lower(banca),'') not like '%papiro%';
  insert into _relatorio values ('sao_autoral_papiro', v_nao_autoral = 0, format('%s questao(oes) sem banca papiro (esperado 0)', v_nao_autoral));

  select count(*) into v_novas_alternativas from public.alternativas where questao_id in (select questao_id from _mapa_ids);
  insert into _relatorio values ('exatamente_155_alternativas', v_novas_alternativas = 155, format('alternativas novas=%s (esperado 155 = 31x5)', v_novas_alternativas));

  select count(*) into v_corretas_invalidas
  from (select questao_id, count(*) filter (where correta) as n from public.alternativas where questao_id in (select questao_id from _mapa_ids) group by questao_id having count(*) filter (where correta) <> 1) x;
  insert into _relatorio values ('1_correta_por_questao', v_corretas_invalidas = 0, format('%s questao(oes) sem exatamente 1 alternativa correta', v_corretas_invalidas));

  select count(*) into v_facil from public.questoes where id in (select questao_id from _mapa_ids) and dificuldade='facil';
  select count(*) into v_media from public.questoes where id in (select questao_id from _mapa_ids) and dificuldade='media';
  select count(*) into v_dificil from public.questoes where id in (select questao_id from _mapa_ids) and dificuldade='dificil';
  insert into _relatorio values ('dificuldade_9_15_7', v_facil=9 and v_media=15 and v_dificil=7, format('facil=%s media=%s dificil=%s (esperado 9/15/7)', v_facil, v_media, v_dificil));

  select count(*) into v_A from public.alternativas a join _mapa_ids m on a.questao_id=m.questao_id where a.correta and a.ordem=1;
  select count(*) into v_B from public.alternativas a join _mapa_ids m on a.questao_id=m.questao_id where a.correta and a.ordem=2;
  select count(*) into v_C from public.alternativas a join _mapa_ids m on a.questao_id=m.questao_id where a.correta and a.ordem=3;
  select count(*) into v_D from public.alternativas a join _mapa_ids m on a.questao_id=m.questao_id where a.correta and a.ordem=4;
  select count(*) into v_E from public.alternativas a join _mapa_ids m on a.questao_id=m.questao_id where a.correta and a.ordem=5;
  insert into _relatorio values ('gabaritos_6_7_6_6_6', v_A=6 and v_B=7 and v_C=6 and v_D=6 and v_E=6, format('A=%s B=%s C=%s D=%s E=%s (esperado 6/7/6/6/6)', v_A, v_B, v_C, v_D, v_E));

  select count(*) into v_novos_vinculos from public.questao_unidades_pedagogicas where questao_id in (select questao_id from _mapa_ids);
  insert into _relatorio values ('31_vinculos_criados', v_novos_vinculos = 31, format('vinculos novos=%s (esperado 31)', v_novos_vinculos));

  select count(*) into v_multiunidade
  from (select questao_id from public.questao_unidades_pedagogicas where questao_id in (select questao_id from _mapa_ids) group by questao_id having count(*) > 1) x;
  insert into _relatorio values ('sem_multiunidade', v_multiunidade = 0, format('%s questao(oes) com mais de 1 vinculo', v_multiunidade));

  select count(*) into v_vinculo_errado
  from _mapa_ids m
  join _lote_questoes lq on lq.ordem = m.ordem
  where not exists (
    select 1 from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    where qup.questao_id = m.questao_id and up.curso_conteudo_id = lq.cc_id
  );
  insert into _relatorio values ('vinculo_no_cc_correto', v_vinculo_errado = 0, format('%s questao(oes) nao vinculada(s) ao cc_id esperado do staging', v_vinculo_errado));

  select count(distinct qup.questao_id) into v_cc70_uteis from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id where up.curso_conteudo_id=70;
  select count(distinct qup.questao_id) into v_cc71_uteis from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id where up.curso_conteudo_id=71;
  select count(distinct qup.questao_id) into v_cc73_uteis from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id where up.curso_conteudo_id=73;
  select count(distinct qup.questao_id) into v_cc74_uteis from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id where up.curso_conteudo_id=74;
  select count(distinct qup.questao_id) into v_cc75_uteis from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id where up.curso_conteudo_id=75;
  select count(distinct qup.questao_id) into v_cc76_uteis from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id where up.curso_conteudo_id=76;

  insert into _relatorio values ('cc70_uteis_4_para_10', v_cc70_uteis = (select cc70_uteis from _snapshot_antes) + 6 and v_cc70_uteis = 10, format('cc70_uteis=%s', v_cc70_uteis));
  insert into _relatorio values ('cc71_uteis_9_para_10', v_cc71_uteis = (select cc71_uteis from _snapshot_antes) + 1 and v_cc71_uteis = 10, format('cc71_uteis=%s', v_cc71_uteis));
  insert into _relatorio values ('cc73_uteis_5_para_10', v_cc73_uteis = (select cc73_uteis from _snapshot_antes) + 5 and v_cc73_uteis = 10, format('cc73_uteis=%s', v_cc73_uteis));
  insert into _relatorio values ('cc74_uteis_3_para_10', v_cc74_uteis = (select cc74_uteis from _snapshot_antes) + 7 and v_cc74_uteis = 10, format('cc74_uteis=%s', v_cc74_uteis));
  insert into _relatorio values ('cc75_uteis_3_para_10', v_cc75_uteis = (select cc75_uteis from _snapshot_antes) + 7 and v_cc75_uteis = 10, format('cc75_uteis=%s', v_cc75_uteis));
  insert into _relatorio values ('cc76_uteis_5_para_10', v_cc76_uteis = (select cc76_uteis from _snapshot_antes) + 5 and v_cc76_uteis = 10, format('cc76_uteis=%s', v_cc76_uteis));

  select count(distinct qup.questao_id) into v_cc70_real from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id join public.questoes q on q.id=qup.questao_id where up.curso_conteudo_id=70 and coalesce(lower(q.banca),'') not like '%papiro%';
  select count(distinct qup.questao_id) into v_cc71_real from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id join public.questoes q on q.id=qup.questao_id where up.curso_conteudo_id=71 and coalesce(lower(q.banca),'') not like '%papiro%';
  select count(distinct qup.questao_id) into v_cc73_real from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id join public.questoes q on q.id=qup.questao_id where up.curso_conteudo_id=73 and coalesce(lower(q.banca),'') not like '%papiro%';
  select count(distinct qup.questao_id) into v_cc74_real from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id join public.questoes q on q.id=qup.questao_id where up.curso_conteudo_id=74 and coalesce(lower(q.banca),'') not like '%papiro%';
  select count(distinct qup.questao_id) into v_cc75_real from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id join public.questoes q on q.id=qup.questao_id where up.curso_conteudo_id=75 and coalesce(lower(q.banca),'') not like '%papiro%';
  select count(distinct qup.questao_id) into v_cc76_real from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id join public.questoes q on q.id=qup.questao_id where up.curso_conteudo_id=76 and coalesce(lower(q.banca),'') not like '%papiro%';

  insert into _relatorio values ('cc70_real_inalterado', v_cc70_real = (select cc70_real from _snapshot_antes), 'REAL de cc70 nao deve mudar (lote e 100% autoral)');
  insert into _relatorio values ('cc71_real_inalterado', v_cc71_real = (select cc71_real from _snapshot_antes), 'REAL de cc71 nao deve mudar');
  insert into _relatorio values ('cc73_real_inalterado', v_cc73_real = (select cc73_real from _snapshot_antes), 'REAL de cc73 nao deve mudar');
  insert into _relatorio values ('cc74_real_inalterado', v_cc74_real = (select cc74_real from _snapshot_antes), 'REAL de cc74 nao deve mudar');
  insert into _relatorio values ('cc75_real_inalterado', v_cc75_real = (select cc75_real from _snapshot_antes), 'REAL de cc75 nao deve mudar');
  insert into _relatorio values ('cc76_real_inalterado', v_cc76_real = (select cc76_real from _snapshot_antes), 'REAL de cc76 nao deve mudar');

  select count(distinct qup.questao_id) into v_dh_uteis_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.curso_conteudos cc on cc.id = up.curso_conteudo_id
    join public.assuntos a on a.id = cc.assunto_id
    where a.materia_id = 11;
  insert into _relatorio values ('dh_uteis_cresceu_31', v_dh_uteis_depois = (select dh_uteis from _snapshot_antes) + 31, format('dh_uteis=%s', v_dh_uteis_depois));

  insert into _relatorio values ('total_questoes_cresceu_31', (select count(*) from public.questoes) = (select total_questoes from _snapshot_antes) + 31, 'total de questoes deve crescer exatamente 31');
  insert into _relatorio values ('total_alternativas_cresceu_155', (select count(*) from public.alternativas) = (select total_alternativas from _snapshot_antes) + 155, 'total de alternativas deve crescer exatamente 155');
  insert into _relatorio values ('total_vinculos_cresceu_31', (select count(*) from public.questao_unidades_pedagogicas) = (select total_vinculos from _snapshot_antes) + 31, 'total de vinculos deve crescer exatamente 31');
  insert into _relatorio values ('unidades_pedagogicas_inalteradas', (select count(*) from public.unidades_pedagogicas) = (select total_unidades from _snapshot_antes), 'nenhuma unidade nova deve ser criada');
  insert into _relatorio values ('curso_conteudos_inalterado', (select count(*) from public.curso_conteudos) = (select total_conteudos from _snapshot_antes), 'curso_conteudos nao deve mudar');
  insert into _relatorio values ('curso_questoes_inalterado', (select count(*) from public.curso_questoes) = (select total_curso_questoes from _snapshot_antes), 'curso_questoes nao deve sofrer alteracao');
  insert into _relatorio values ('respostas_inalteradas', (select count(*) from public.respostas_usuarios) = (select total_respostas from _snapshot_antes), 'historico de respostas_usuarios nao deve mudar');
  insert into _relatorio values ('sessoes_inalteradas', (select count(*) from public.sessoes_estudo) = (select total_sessoes from _snapshot_antes), 'sessoes_estudo nao deve mudar');
end $$;

-- Relatorio final — nunca aborta a transacao; so relata.
do $$
declare
  v_tudo_ok boolean;
  r record;
begin
  select bool_and(ok) into v_tudo_ok from _relatorio;

  raise notice '=== RELATORIO DO TESTE (importar_dh_aut_01) ===';
  for r in select * from _relatorio order by etapa loop
    raise notice '% => % (%)', r.etapa, r.ok, r.detalhe;
  end loop;
  raise notice 'tudo_ok = %', coalesce(v_tudo_ok, false);
end $$;

-- SEMPRE desfaz — este arquivo nunca persiste nada.
rollback;
