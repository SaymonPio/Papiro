-- Aplicacao AUTORAL do Lote DH-AUT-02 de Direitos Humanos e Cidadania — 33
-- questoes novas AUTORAL_PAPIRO + 165 alternativas + 33 vinculos, validado
-- pelo harness supabase/importar_dh_aut_02_teste_rollback.sql (tudo_ok =
-- true precisa ser confirmado antes de rodar este arquivo).
--
-- Fecha o deficit_para_10 de 5 unidades de Direitos Humanos e Cidadania
-- (cc77 PIDESC, cc78 Tratados com forca de EC, cc79 Convencao Interame-
-- ricana Prevenir/Punir Tortura, cc80 Entendimentos STF/STJ, cc81 Nocoes
-- de DH), levando cada uma a exatamente 10 uteis:
--   cc77: 3->10 (7 novas) | cc78: 3->10 (7 novas) | cc79: 3->10 (7 novas)
--   cc80: 3->10 (7 novas) | cc81: 5->10 (5 novas)
--
-- Origem: AUTORAL_PAPIRO em todas as 33 (banca='Papiro') — nunca REAL.
-- Conteudo integralmente auditado nesta sessao (DH-AUT-02 — auditoria
-- independente Claude + microauditoria final de consistencia), com
-- verificacao direta da legislacao/jurisprudencia oficial vigente para
-- cada dispositivo citado: Decreto 591/1992 - PIDESC (arts. 4,5,6,9,13,
-- 15), CF art.5 par.3 + RE 466.343/SP (fonte oficial stf.jus.br) +
-- Decreto Legislativo 1/2021 (Convencao Interamericana contra o Racismo)
-- + Decreto 9.522/2018 (Marraqueche) + Decreto 6.949/2009 (CDPD), Decreto
-- 98.386/1989 - Convencao Interamericana Prevenir/Punir Tortura (arts.
-- 2,3-a,4,5,6), Sumula Vinculante 11/STF + Tema 280 RG/STF (RE 603.616),
-- Declaracao de Viena 1993 par.5, Lei 13.675/2018 arts.42-A par.2 e 42-B
-- (incluidos pela Lei 14.531/2023).
--
-- Mecanismo de identificacao/idempotencia: cada uma das 33 e identificada
-- de forma inequivoca pelo texto EXATO do proprio enunciado. Se este
-- arquivo for executado uma segunda vez, a precondicao de "enunciado
-- identico" abortara a transacao inteira antes de qualquer insercao. O
-- rollback seguro pos-apply (se necessario no futuro) esta em
-- supabase/reverter_dh_aut_02.sql, que localiza e remove exclusivamente
-- estas 33 questoes pelo mesmo criterio de enunciado exato.
--
-- Diferenca deste arquivo para o harness: termina em COMMIT, e cada
-- precondicao/pos-condicao usa RAISE EXCEPTION. Usa a mesma RPC
-- administrativa oficial classificar_questao_unidade_admin.
--
-- NAO EXECUTADO neste turno — preparado para teste_rollback antes do
-- apply real.

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
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 77) as cc77_uteis,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.questoes q on q.id = qup.questao_id where up.curso_conteudo_id = 77 and coalesce(lower(q.banca),'') not like '%papiro%') as cc77_real,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 78) as cc78_uteis,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.questoes q on q.id = qup.questao_id where up.curso_conteudo_id = 78 and coalesce(lower(q.banca),'') not like '%papiro%') as cc78_real,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 79) as cc79_uteis,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.questoes q on q.id = qup.questao_id where up.curso_conteudo_id = 79 and coalesce(lower(q.banca),'') not like '%papiro%') as cc79_real,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 80) as cc80_uteis,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.questoes q on q.id = qup.questao_id where up.curso_conteudo_id = 80 and coalesce(lower(q.banca),'') not like '%papiro%') as cc80_real,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 81) as cc81_uteis,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.questoes q on q.id = qup.questao_id where up.curso_conteudo_id = 81 and coalesce(lower(q.banca),'') not like '%papiro%') as cc81_real,
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
(1,'cc77-01','f33221cc-f53c-4f91-88e4-a6d8440beca0',84,77,'facil','PAPIRO — DH-AUT-02 — cc77-01 — PIDESC art.5 item2',
 'O Estado "Alfa", parte do Pacto Internacional sobre Direitos Econômicos, Sociais e Culturais (PIDESC), possui em sua legislação interna a garantia de um direito fundamental com espectro de proteção mais amplo do que o previsto no próprio Pacto. O governo de "Alfa", desejando reduzir custos, tenta restringir esse direito, argumentando que o PIDESC exige um grau menor de proteção. Considerando as disposições do PIDESC, essa atitude do Estado "Alfa" é:'),
(2,'cc77-02','f33221cc-f53c-4f91-88e4-a6d8440beca0',84,77,'facil','PAPIRO — DH-AUT-02 — cc77-02 — PIDESC art.9',
 'Conforme as disposições do Pacto Internacional sobre Direitos Econômicos, Sociais e Culturais (PIDESC), os Estados Partes reconhecem o direito de toda pessoa à:'),
(3,'cc77-03','f33221cc-f53c-4f91-88e4-a6d8440beca0',84,77,'media','PAPIRO — DH-AUT-02 — cc77-03 — PIDESC art.15 item1 c',
 'De acordo com o Pacto Internacional sobre Direitos Econômicos, Sociais e Culturais (PIDESC), no que tange aos direitos culturais, os Estados Partes reconhecem o direito de toda pessoa de beneficiar-se da proteção dos interesses morais e materiais decorrentes de toda produção científica, literária ou artística:'),
(4,'cc77-04','f33221cc-f53c-4f91-88e4-a6d8440beca0',84,77,'media','PAPIRO — DH-AUT-02 — cc77-04 — PIDESC art.6 item2',
 'Em relação ao direito ao trabalho reconhecido no Pacto Internacional sobre Direitos Econômicos, Sociais e Culturais (PIDESC), assinale a alternativa que apresenta uma das medidas expressamente previstas que os Estados Partes devem adotar para assegurar o pleno exercício desse direito.'),
(5,'cc77-05','f33221cc-f53c-4f91-88e4-a6d8440beca0',84,77,'dificil','PAPIRO — DH-AUT-02 — cc77-05 — PIDESC art.4',
 'O Parlamento do Estado "Beta" aprovou uma lei que restringe determinados direitos econômicos reconhecidos no PIDESC. O propósito alegado na exposição de motivos da lei foi, exclusivamente, promover o bem-estar geral em uma sociedade democrática. As limitações impostas pela lei foram consideradas pelos tribunais locais como compatíveis com a natureza dos referidos direitos. Considerando a cláusula geral de limitações do PIDESC e a situação hipotética descrita, é correto afirmar que:'),
(6,'cc77-06','f33221cc-f53c-4f91-88e4-a6d8440beca0',84,77,'media','PAPIRO — DH-AUT-02 — cc77-06 — PIDESC arts.5/9/15 assertivas',
 E'Considere as seguintes assertivas sobre o Pacto Internacional sobre Direitos Econômicos, Sociais e Culturais (PIDESC):\n\nI. É proibida a restrição ou suspensão de direitos fundamentais vigentes em um Estado Parte, mediante leis ou convenções, sob o pretexto de que o PIDESC não os reconhece.\nII. Os Estados Partes reconhecem o direito de toda pessoa à previdência social, inclusive ao seguro social.\nIII. Os Estados Partes garantem proteção aos interesses materiais e morais resultantes de qualquer produção científica de que a pessoa detenha a propriedade, ainda que não seja a autora da obra.\n\nEstá correto o que se afirma em:'),
(7,'cc77-07','f33221cc-f53c-4f91-88e4-a6d8440beca0',84,77,'media','PAPIRO — DH-AUT-02 — cc77-07 — PIDESC art.6 item1 e art.13 item1',
 'O Pacto Internacional sobre Direitos Econômicos, Sociais e Culturais (PIDESC) estrutura diversos direitos fundamentais, entre os quais o direito ao trabalho e o direito à educação. Com base nas disposições do PIDESC, é correto afirmar que:'),
(8,'cc78-01','e996e440-4508-4878-8acd-c805b718b27c',99,78,'facil','PAPIRO — DH-AUT-02 — cc78-01 — CF art.5 par.3 Convencao Racismo',
 'O sistema normativo brasileiro incorpora os tratados de direitos humanos de forma diferenciada, a depender do quórum de aprovação parlamentar. Dentre os instrumentos internacionais que ostentam equivalência às emendas constitucionais no Brasil, encontra-se a:'),
(9,'cc78-02','e996e440-4508-4878-8acd-c805b718b27c',99,78,'media','PAPIRO — DH-AUT-02 — cc78-02 — CF art.5 par.3 Marraqueche',
 'O Tratado de Marraqueche para Facilitar o Acesso a Obras Publicadas às Pessoas Cegas, com Deficiência Visual ou com outras Dificuldades para Ter Acesso ao Texto Impresso foi ratificado e promulgado pelo Estado brasileiro com uma característica formal relevante. De acordo com a sistemática constitucional brasileira, esse Tratado possui:'),
(10,'cc78-03','e996e440-4508-4878-8acd-c805b718b27c',99,78,'facil','PAPIRO — DH-AUT-02 — cc78-03 — CF art.5 par.3 CDPD Protocolo',
 'No ordenamento jurídico brasileiro, a Convenção de Nova York sobre os Direitos das Pessoas com Deficiência possui posição hierárquica diferenciada. Assinale a alternativa que indica corretamente o instrumento normativo que, juntamente com a referida Convenção, foi aprovado sob a égide do artigo 5º, §3º, da Constituição Federal, ostentando equivalência de emenda constitucional.'),
(11,'cc78-04','e996e440-4508-4878-8acd-c805b718b27c',99,78,'dificil','PAPIRO — DH-AUT-02 — cc78-04 — RE466343 supralegalidade',
 'A jurisprudência do Supremo Tribunal Federal (STF) definiu o posicionamento hierárquico dos tratados internacionais de direitos humanos no ordenamento jurídico interno brasileiro. Considerando o entendimento firmado no julgamento do RE 466.343/SP, é correto afirmar que os tratados de direitos humanos incorporados ao Brasil antes da Emenda Constitucional nº 45/2004, ou aqueles que não foram aprovados com o quórum qualificado do art. 5º, §3º, da Constituição, possuem status normativo:'),
(12,'cc78-05','e996e440-4508-4878-8acd-c805b718b27c',99,78,'media','PAPIRO — DH-AUT-02 — cc78-05 — CF art.5 par.3 aplicacao',
 'O Brasil assinou recentemente um novo tratado internacional que cria diretrizes de proteção a grupos vulneráveis em tempos de crise. O Presidente da República encaminhou o texto ao Congresso Nacional, objetivando que o instrumento ganhe força normativa equivalente à das emendas constitucionais. Para que esse status jurídico seja alcançado, o Congresso Nacional deverá aprovar o tratado:'),
(13,'cc78-06','e996e440-4508-4878-8acd-c805b718b27c',99,78,'dificil','PAPIRO — DH-AUT-02 — cc78-06 — assertivas EC x supralegal',
 E'No tocante ao status hierárquico dos tratados internacionais de direitos humanos no Brasil, julgue os itens a seguir, considerando a jurisprudência do Supremo Tribunal Federal e os ritos de aprovação congressual:\n\nI. O Tratado de Marraqueche e a Convenção Interamericana contra o Racismo ostentam status equivalente ao das emendas constitucionais.\nII. O Pacto Internacional dos Direitos Civis e Políticos (PIDCP) foi incorporado com equivalência de emenda constitucional, figurando no mesmo patamar do Protocolo Facultativo à Convenção sobre os Direitos das Pessoas com Deficiência.\nIII. A Convenção Americana sobre Direitos Humanos (Pacto de San José da Costa Rica) possui status supralegal, situando-se abaixo da Constituição Federal e acima das leis ordinárias.\n\nEstá correto o que se afirma em:'),
(14,'cc78-07','e996e440-4508-4878-8acd-c805b718b27c',99,78,'media','PAPIRO — DH-AUT-02 — cc78-07 — distincao rito qualificado x ordinario',
 'Considerando o sistema constitucional brasileiro e a jurisprudência dominante do Supremo Tribunal Federal (STF) acerca da hierarquia dos tratados internacionais sobre direitos humanos, assinale a alternativa correta sobre as consequências formais de sua incorporação.'),
(15,'cc79-01','af995205-bb67-49e4-8ad1-151e339e892a',104,79,'media','PAPIRO — DH-AUT-02 — cc79-01 — Convencao Tortura art.2',
 'Conforme o disposto no artigo 2º da Convenção Interamericana para Prevenir e Punir a Tortura, para os efeitos da referida Convenção, a definição de tortura inclui sofrimentos físicos ou mentais aplicados com fins de investigação, punição ou intimidação. No entanto, o mesmo dispositivo faz uma ressalva expressa em relação ao conceito de tortura quanto às penas ou sofrimentos inerentes a medidas legais. Sobre esse ponto, é correto afirmar que:'),
(16,'cc79-02','af995205-bb67-49e4-8ad1-151e339e892a',104,79,'facil','PAPIRO — DH-AUT-02 — cc79-02 — Convencao Tortura art.4',
 'Um policial militar recém-formado, cumprindo determinações expressas de seu Capitão durante um interrogatório, aplica severos castigos físicos em um suspeito detido para forçar uma confissão. Ao ser responsabilizado criminalmente, o policial argumenta que não poderia desobedecer à ordem hierárquica superior. À luz da Convenção Interamericana para Prevenir e Punir a Tortura, essa alegação de obediência hierárquica é:'),
(17,'cc79-03','af995205-bb67-49e4-8ad1-151e339e892a',104,79,'dificil','PAPIRO — DH-AUT-02 — cc79-03 — Convencao Tortura art.3 a',
 'Durante uma rebelião em unidade prisional, o diretor do presídio, um funcionário público, presencia agentes penitenciários agredindo fisicamente os detentos com o objetivo deliberado de aplicar castigo pessoal. Embora tivesse plena capacidade operacional e autoridade para interromper imediatamente a violência, o diretor decide cruzar os braços e assistir passivamente, sem impedir os atos. Com base na Convenção Interamericana para Prevenir e Punir a Tortura (art. 3º), a conduta do diretor:'),
(18,'cc79-04','af995205-bb67-49e4-8ad1-151e339e892a',104,79,'dificil','PAPIRO — DH-AUT-02 — cc79-04 — Convencao Tortura art.2 2a parte',
 'Agentes estatais, durante interrogatórios prolongados de um suspeito de espionagem, não utilizaram agressões físicas, choques ou qualquer método que causasse dor física ou angústia psicológica severa imediata. Em vez disso, aplicaram drogas experimentais e técnicas de privação sensorial que anularam a personalidade da vítima e diminuíram significativamente sua capacidade mental consciente, com o fim de obter informações. À luz da Convenção Interamericana para Prevenir e Punir a Tortura, a conduta desses agentes:'),
(19,'cc79-05','af995205-bb67-49e4-8ad1-151e339e892a',104,79,'media','PAPIRO — DH-AUT-02 — cc79-05 — Convencao Tortura art.5',
 'O comandante de uma instalação prisional em um país signatário da Convenção Interamericana para Prevenir e Punir a Tortura determinou o uso de tortura contra um grupo de detentos altamente perigosos, líderes de uma facção criminosa. Após investigação, o comandante justificou seus atos formalmente, alegando a extrema periculosidade dos detidos e a grave insegurança do estabelecimento penitenciário, que ameaçava a vida dos próprios guardas. Com base na referida Convenção, a justificativa do comandante é:'),
(20,'cc79-06','af995205-bb67-49e4-8ad1-151e339e892a',104,79,'media','PAPIRO — DH-AUT-02 — cc79-06 — Convencao Tortura art.6',
 'Os Estados Partes da Convenção Interamericana para Prevenir e Punir a Tortura assumem diversas obrigações de natureza legislativa perante o sistema interamericano. Assinale a alternativa que descreve corretamente o dever assumido pelos Estados quanto ao tratamento do ato de tortura em seu ordenamento jurídico penal.'),
(21,'cc79-07','af995205-bb67-49e4-8ad1-151e339e892a',104,79,'facil','PAPIRO — DH-AUT-02 — cc79-07 — Convencao Tortura assertivas 3a/4/5',
 E'Com relação à responsabilização penal e às justificativas para a tortura na Convenção Interamericana, analise as assertivas abaixo:\n\nI. São responsabilizados pelo delito de tortura os empregados públicos que, podendo impedi-la, não o façam.\nII. O fato de o agente público ter agido sob ordens de um superior exime-o da responsabilidade penal, respondendo unicamente o superior hierárquico.\nIII. A suspensão de garantias constitucionais por estado de emergência não pode ser invocada como justificativa para a tortura.\n\nEstá correto o que se afirma em:'),
(22,'cc80-01','572c64ec-c7bb-412e-ab3d-94435ed7df12',96,80,'media','PAPIRO — DH-AUT-02 — cc80-01 — SV11 caso sem risco',
 'Durante o cumprimento de um mandado de prisão preventiva por crimes financeiros em desfavor de um empresário idoso, a equipe policial encontrou-o em sua residência. O alvo colaborou prontamente com os agentes, não apresentou qualquer resistência, não demonstrou sinais de fuga e não impôs qualquer risco ou perigo à integridade física própria ou alheia. Ainda assim, por determinação do delegado, ele foi algemado. À luz do entendimento sumulado do Supremo Tribunal Federal (Súmula Vinculante 11), o uso de algemas nesta situação foi:'),
(23,'cc80-02','572c64ec-c7bb-412e-ab3d-94435ed7df12',96,80,'media','PAPIRO — DH-AUT-02 — cc80-02 — SV11 caso com risco',
 'Agentes de segurança pública realizam a captura de um suspeito em flagrante delito por roubo à mão armada. O suspeito oferece violenta resistência e tenta se desvencilhar dos policiais, havendo evidente perigo à integridade física da própria guarnição e de transeuntes no local. Os agentes conseguem dominá-lo e aplicam as algemas para realizar o transporte seguro, formalizando posteriormente, por escrito, a excepcionalidade do uso. Considerando o teor da Súmula Vinculante 11, a conduta dos policiais:'),
(24,'cc80-03','572c64ec-c7bb-412e-ab3d-94435ed7df12',96,80,'dificil','PAPIRO — DH-AUT-02 — cc80-03 — Tema280 caso positivo',
 'Policiais em patrulhamento noturno sentem forte odor de entorpecentes vindos de uma residência. Pela fresta do muro baixo, observam nitidamente um indivíduo embalando grande quantidade de drogas sobre uma mesa. Diante da situação de flagrante delito em curso, os policiais ingressam forçadamente no domicílio, sem mandado judicial, e efetuam a prisão. Posteriormente, a equipe justifica o ingresso no domicílio com base nos elementos visuais que possuíam antes da entrada. À luz do Tema 280 da repercussão geral do STF, a ação policial foi:'),
(25,'cc80-04','572c64ec-c7bb-412e-ab3d-94435ed7df12',96,80,'dificil','PAPIRO — DH-AUT-02 — cc80-04 — Tema280 caso negativo denuncia anonima',
 'A polícia recebe uma ligação anônima informando genericamente que "na casa da esquina há pessoas traficando drogas". Sem realizar nenhuma diligência prévia, monitoramento ou constatar visualmente qualquer movimentação atípica que indicasse crime, a guarnição chega ao local, arromba a porta da residência e, por acaso, encontra pequena quantidade de drogas, prendendo o morador em flagrante. Analisando o caso sob a ótica da jurisprudência do STF (Tema 280), o ingresso no domicílio e as provas dele decorrentes são:'),
(26,'cc80-05','572c64ec-c7bb-412e-ab3d-94435ed7df12',96,80,'dificil','PAPIRO — DH-AUT-02 — cc80-05 — CF art.5 XI x Tema280 densificacao',
 'A Constituição Federal consagra que "a casa é asilo inviolável do indivíduo, ninguém nela podendo penetrar sem consentimento do morador, salvo em caso de flagrante delito ou desastre, ou para prestar socorro, ou, durante o dia, por determinação judicial" (art. 5º, XI). Ao densificar e interpretar esse comando, o Supremo Tribunal Federal firmou tese vinculante (Tema 280 da repercussão geral) estipulando um requisito normativo não escrito expressamente no dispositivo constitucional, a ser observado pelas forças policiais para validar o ingresso por flagrante delito sem mandado. Esse requisito jurisprudencial adicional consiste na exigência de:'),
(27,'cc80-06','572c64ec-c7bb-412e-ab3d-94435ed7df12',96,80,'media','PAPIRO — DH-AUT-02 — cc80-06 — SV11 consequencias',
 'O descumprimento das regras relativas à excepcionalidade do uso de algemas acarreta severas consequências legais para o agente público e para a validade do ato. Assinale a alternativa que elenca adequadamente as consequências previstas na Súmula Vinculante 11 do STF para o uso indevido de algemas.'),
(28,'cc80-07','572c64ec-c7bb-412e-ab3d-94435ed7df12',96,80,'facil','PAPIRO — DH-AUT-02 — cc80-07 — distincao SV11 x Tema280',
 'Os precedentes e as súmulas do Supremo Tribunal Federal balizam a atuação das forças de segurança pública, impondo balizas para garantir o respeito aos direitos fundamentais. A respeito de dois entendimentos centrais da jurisprudência, assinale a alternativa que associa corretamente a tese fixada ao seu respectivo instituto garantidor.'),
(29,'cc81-01','df8d133f-ddd6-4b85-941d-60b4d4967c06',89,81,'dificil','PAPIRO — DH-AUT-02 — cc81-01 — universalidade x relativismo Viena1993',
 'Um Estado soberano decide punir oponentes políticos com a aplicação de castigos corporais que configuram tortura, fundamentando a prática em antigas tradições religiosas e no contexto cultural exclusivo de seu povo. Em fóruns internacionais, as autoridades daquele país invocam a defesa da soberania e afirmam que valores ocidentais não podem ser impostos a outras culturas. À luz do Direito Internacional dos Direitos Humanos e do paradigma estabelecido na Conferência de Viena de 1993, essa alegação de ordem cultural é juridicamente:'),
(30,'cc81-02','df8d133f-ddd6-4b85-941d-60b4d4967c06',89,81,'media','PAPIRO — DH-AUT-02 — cc81-02 — indivisibilidade interdependencia',
 'O governo de um determinado Estado decide suprimir severamente o repasse de verbas destinadas à educação básica pública, inviabilizando a alfabetização de parcela significativa de sua população mais vulnerável. Paralelamente, como reflexo da falta de instrução formal mínima, esses mesmos cidadãos não conseguem se registrar para votar e enfrentam extrema dificuldade para organizar petições contra as ações governamentais, sendo impedidos de participar do debate público (direito político). O fenômeno em que a violação de um direito econômico e social impacta diretamente o exercício de um direito civil ou político exemplifica a característica de direitos humanos denominada:'),
(31,'cc81-03','df8d133f-ddd6-4b85-941d-60b4d4967c06',89,81,'media','PAPIRO — DH-AUT-02 — cc81-03 — dignidade fundamento e limite',
 'Com o objetivo de combater uma escalada nos índices de criminalidade, o governo e a cúpula da segurança pública estudam aprovar uma medida de segurança que autoriza a marcação permanente da pele, por meio de ferros aquecidos, de indivíduos condenados em segunda instância por roubo qualificado, visando à fácil identificação social desses agentes. Sob a ótica do Direito Constitucional e dos Direitos Humanos, tal medida proposta é:'),
(32,'cc81-04','df8d133f-ddd6-4b85-941d-60b4d4967c06',89,81,'dificil','PAPIRO — DH-AUT-02 — cc81-04 — Lei13675 art.42-A par.2 I II III',
 'O recrudescimento da violência contra a própria vida entre profissionais de segurança pública motivou a edição da Lei nº 14.531/2023, que incluiu novos dispositivos na Lei nº 13.675/2018 (Sistema Único de Segurança Pública - SUSP). Segundo o art. 42-A, § 2º, a prevenção da violência autoprovocada e do suicídio dos profissionais da segurança deverá observar, entre outras, as seguintes diretrizes:'),
(33,'cc81-05','df8d133f-ddd6-4b85-941d-60b4d4967c06',89,81,'media','PAPIRO — DH-AUT-02 — cc81-05 — Lei13675 art.42-B I IV',
 'Além de focar na saúde mental, a Lei nº 13.675/2018 (SUSP), alterada pela Lei nº 14.531/2023, estabelece parâmetros cruciais relativos à proteção integral dos profissionais do sistema de segurança pública. Nos termos do art. 42-B, assinale a alternativa que contém diretrizes de promoção da proteção física e capacitação que devem ser seguidas pelas instituições.');

create temporary table _lote_explicacoes (ordem int primary key, explicacao text) on commit drop;
insert into _lote_explicacoes (ordem, explicacao) values
(1, E'GABARITO: alternativa A\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO art. 5º, item 2, do PIDESC (Decreto 591/1992) estabelece a cláusula pro homine: não se admitirá qualquer restrição ou suspensão dos direitos humanos fundamentais reconhecidos ou vigentes em virtude de leis, convenções, regulamentos ou costumes, sob pretexto de que o Pacto não os reconheça ou os reconheça em menor grau — a alternativa A está de acordo com esse dispositivo.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nB inverte a regra protetiva. C inventa exceção de estado de sítio não prevista. D está incorreta porque o PIDESC estabelece piso mínimo, não teto máximo, de proteção. E inventa exigência de autorização do Conselho de Segurança da ONU, inexistente no texto.'),
(2, E'GABARITO: alternativa B\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO art. 9º do PIDESC dispõe: "Os Estados Partes do presente Pacto reconhecem o direito de toda pessoa à previdência social, inclusive ao seguro social" — a alternativa B corresponde ao texto da norma, sem acréscimos.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA adiciona requisito de "atividades de risco" inexistente. C acrescenta "independentemente de contribuição", pegadinha clássica não prevista no Pacto. D troca previdência por assistência social e restringe a natos. E limita indevidamente a trabalhadores urbanos e rurais.'),
(3, E'GABARITO: alternativa C\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO art. 15, item 1, "c", do PIDESC reconhece o direito de toda pessoa de beneficiar-se da proteção dos interesses morais e materiais decorrentes de produção científica, literária ou artística de que seja autora. A alternativa C corresponde a esse recorte.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA, B, D e E desvirtuam o dispositivo, estendendo a proteção a obras de terceiros, cessionários ou finalidades coletivas/históricas não previstas — o Pacto protege especificamente o autor.'),
(4, E'GABARITO: alternativa D\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO art. 6º, item 2, do PIDESC dispõe que as medidas para assegurar o pleno exercício do direito ao trabalho deverão incluir a orientação e formação técnica e profissional, a elaboração de programas, normas e técnicas apropriadas. A alternativa D reflete essa determinação.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA, B, C e E inserem políticas públicas não previstas no Pacto (estatização, salário-desemprego vitalício, cotas para estrangeiros, limitação salarial).'),
(5, E'GABARITO: alternativa E\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO art. 4º do PIDESC estabelece que os Estados Partes só poderão submeter os direitos a limitações determinadas por lei, na medida em que forem compatíveis com a natureza desses direitos e exclusivamente com o propósito de promover o bem-estar geral em sociedade democrática. A alternativa E reúne os três elementos exigidos: determinação legal, compatibilidade material e finalidade de bem-estar geral.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA está incorreta porque o Pacto admite limitações. B contraria a justificativa legítima do próprio Pacto. C exige forma (decreto) não prevista — é exigida lei. D restringe indevidamente a hipóteses de guerra, não previstas no art. 4º.'),
(6, E'GABARITO: alternativa B\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nA assertiva I está de acordo com o art. 5º, item 2. A assertiva II corresponde ao texto do art. 9º.\n\nPOR QUE A ASSERTIVA III ESTÁ INCORRETA:\nO art. 15, item 1, "c", protege os interesses de quem SEJA autora da obra, não de mera detentora de propriedade de obra de terceiro. Logo, apenas I e II estão corretas.'),
(7, E'GABARITO: alternativa D\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO art. 6º, item 1, reconhece o direito de toda pessoa de ganhar a vida por meio de trabalho livremente escolhido ou aceito. O art. 13, item 1, dispõe que a educação deverá visar ao pleno desenvolvimento da personalidade humana e do sentido de sua dignidade, fortalecendo o respeito pelos direitos humanos e liberdades fundamentais. A alternativa D reúne corretamente os dois dispositivos, sem extrapolar para o item 2 do art. 13 (obrigatoriedade/gratuidade do ensino primário, não exigido nesta questão).\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA, B, C e E distorcem o conteúdo de cada direito.'),
(8, E'GABARITO: alternativa C\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nA Convenção Interamericana contra o Racismo, a Discriminação Racial e Formas Correlatas de Intolerância foi aprovada pelo rito do art. 5º, §3º, da Constituição Federal (Decreto Legislativo nº 1/2021, promulgada pelo Decreto nº 10.932/2022), adquirindo equivalência de emenda constitucional.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nAs demais alternativas listam tratados de direitos humanos incorporados sem esse rito qualificado, possuindo status supralegal segundo a jurisprudência do STF.'),
(9, E'GABARITO: alternativa E\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO Tratado de Marraqueche (Decreto nº 9.522/2018) versa sobre direitos humanos e foi aprovado pelo rito do art. 5º, §3º da CF, adquirindo status de emenda constitucional.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA, B, C e D subestimam ou negam essa estatura normativa.'),
(10, E'GABARITO: alternativa A\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nA Convenção sobre os Direitos das Pessoas com Deficiência e seu Protocolo Facultativo foram aprovados no Brasil pelo rito do art. 5º, §3º da CF (Decreto Legislativo 186/2008, Decreto 6.949/2009).\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nB, C, D e E citam pactos, declarações e regras/protocolos sem status de emenda constitucional.'),
(11, E'GABARITO: alternativa B\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nNo RE 466.343/SP (fonte oficial: stf.jus.br), o STF consolidou que tratados de direitos humanos que NÃO passam pelo rito do art. 5º, §3º ingressam com status supralegal — abaixo da Constituição, acima das leis infraconstitucionais. A alternativa B corresponde a essa tese.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA, C, D e E distorcem a posição hierárquica correta.'),
(12, E'GABARITO: alternativa D\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO art. 5º, §3º, da CF exige que os tratados de direitos humanos sejam aprovados em cada Casa do Congresso Nacional, em dois turnos, por três quintos dos votos dos respectivos membros, para equivalerem a emendas constitucionais. A alternativa D reúne os três requisitos cumulativos exigidos.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA, B, C e E apresentam quóruns, procedimentos ou casas legislativas divergentes do texto constitucional.'),
(13, E'GABARITO: alternativa A\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO item I está correto: Marraqueche e Convenção contra o Racismo passaram pelo rito do art. 5º, §3º. O item III está correto: o Pacto de San José, incorporado antes da EC 45/2004 sem o rito especial, possui status supralegal (RE 466.343).\n\nPOR QUE O ITEM II ESTÁ INCORRETO:\nO PIDCP possui status supralegal, não figurando no mesmo patamar do Protocolo da CDPD (que é EC). Portanto, apenas I e III estão corretos.'),
(14, E'GABARITO: alternativa E\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nA distinção dogmática funciona de forma bipartida para tratados de direitos humanos: aprovados sob o rito do art. 5º, §3º, ganham equivalência de emenda constitucional; aprovados sem esse rito, ingressam com status supralegal (RE 466.343). A alternativa E enuncia corretamente essa dualidade.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA, B, C e D distorcem essa distribuição hierárquica.'),
(15, E'GABARITO: alternativa B\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO art. 2º, em sua parte final, dispõe: "não estarão compreendidos no conceito de tortura as penas ou sofrimentos físicos ou mentais que sejam unicamente consequência de medidas legais ou inerentes a elas, contanto que não incluam a realização dos atos ou aplicação dos métodos a que se refere este artigo". A exclusão é, portanto, CONDICIONADA — não basta a medida ser legal; ela não pode incluir os próprios atos/métodos de tortura descritos no artigo. A alternativa B preserva essa condição completa.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA, C e D erram ao tratar toda consequência de medida legal como tortura automática ou presumida. E restringe indevidamente a penas corporais.'),
(16, E'GABARITO: alternativa C\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO art. 4º da Convenção dispõe que o fato de haver agido por ordens superiores não eximirá da responsabilidade penal correspondente — vedação absoluta.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA, B e D admitem indevidamente exclusão de responsabilidade. E inventa exceção de emergência inexistente.'),
(17, E'GABARITO: alternativa E\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO art. 3º, alínea "a", responsabiliza os funcionários públicos que ordenem, instiguem ou induzam a tortura, a cometam diretamente ou, podendo impedi-la, não o façam. A conduta omissiva do diretor subsome-se a essa última modalidade.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA, B, C e D limitam ou desclassificam indevidamente a responsabilidade.'),
(18, E'GABARITO: alternativa A\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO art. 2º, em sua segunda parte, prevê que também se entenderá como tortura a aplicação, sobre uma pessoa, de métodos tendentes a anular a personalidade da vítima, ou a diminuir sua capacidade física ou mental, embora não causem dor física ou angústia psíquica. A alternativa A é a única correta.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nB e C exigem indevidamente dor física/angústia severa. D inventa exceção para inteligência estatal. E cria requisito de dano permanente inexistente.'),
(19, E'GABARITO: alternativa D\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO art. 5º estabelece, em conjunto, que nem a existência de circunstâncias excepcionais (guerra, estado de sítio, comoção interna etc.) nem a periculosidade do detido ou a insegurança do estabelecimento carcerário podem justificar a tortura. A alternativa D está de acordo com essa vedação absoluta.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA, B, C e E admitem indevidamente atenuantes ou exceções vedadas.'),
(20, E'GABARITO: alternativa B\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO art. 6º estabelece que os Estados Partes assegurar-se-ão de que todos os atos de tortura constituam delitos em sua legislação penal, com penas severas que levem em conta sua gravidade. A alternativa B está de acordo com esse mandato de criminalização.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA, C e D atenuam ou transferem a competência; E limita indevidamente a proteção a determinados grupos.'),
(21, E'GABARITO: alternativa C\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nA assertiva I está de acordo com o art. 3º, "a". A assertiva III está de acordo com o art. 5º.\n\nPOR QUE A ASSERTIVA II ESTÁ INCORRETA:\nO art. 4º afirma exatamente o oposto — ordens superiores NÃO eximem da responsabilidade penal. Portanto, apenas I e III estão corretas.'),
(22, E'GABARITO: alternativa D\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nA Súmula Vinculante 11 dispõe que só é lícito o uso de algemas em casos de resistência e de fundado receio de fuga ou de perigo à integridade física própria ou alheia. Como o preso era colaborador, sem risco, resistência ou perigo, o uso foi ilícito. A alternativa D reflete corretamente as exigências da SV 11 e suas consequências.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nAs demais justificam uso discricionário indevido ou mitigam os efeitos da súmula.'),
(23, E'GABARITO: alternativa E\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO uso de algemas, excepcionalmente, exige resistência, fundado receio de fuga ou perigo à integridade física, além de justificativa escrita da excepcionalidade (SV 11). O cenário atendeu a todos esses requisitos.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nAs demais criam proibições absolutas ou requisitos inexistentes na súmula.'),
(24, E'GABARITO: alternativa A\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nNo Tema 280 (RE 603.616/RO), o STF fixou a tese de que a entrada forçada em domicílio sem mandado judicial só é lícita, mesmo em período noturno, quando amparada em fundadas razões, devidamente justificadas a posteriori, que indiquem situação de flagrante delito no interior. No caso, os policiais tinham elementos objetivos prévios ao ingresso (odor e visualização direta).\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nAs demais inventam exceções contrárias ao Tema.'),
(25, E'GABARITO: alternativa C\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nÀ luz do standard fixado no Tema 280 e de sua aplicação pela jurisprudência do STF, a denúncia anônima isolada, sem diligências ou elementos concretos prévios que configurem fundadas razões, não legitima o ingresso forçado; a descoberta posterior do flagrante não convalida a diligência inicialmente arbitrária.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA admite indevidamente validação retroativa da invasão pelo resultado obtido; B atribui à denúncia anônima, isoladamente, força que ela não possui; D e E criam regras (exigência de crime hediondo; distinção dia/noite) inexistentes na tese fixada.'),
(26, E'GABARITO: alternativa B\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO Tema 280 densificou o art. 5º, XI, exigindo que o agente que ingresse em domicílio sem mandado para prender em flagrante possua fundadas razões, devidamente justificadas a posteriori, que indiquem previamente a situação de flagrante no interior — standard probatório cunhado pelo STF, não constante literalmente do texto constitucional.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA, C, D e E impõem regras não estipuladas no Tema 280.'),
(27, E'GABARITO: alternativa D\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nA Súmula Vinculante 11 prevê, ao final: "sob pena de responsabilidade disciplinar, civil e penal do agente ou da autoridade e de nulidade da prisão ou do ato processual a que se refere, sem prejuízo da responsabilidade civil do Estado". A alternativa D reproduz esse conjunto sancionatório.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA e B atenuam as punições; C e E extrapolam o texto sumular.'),
(28, E'GABARITO: alternativa A\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nA alternativa A aplica cada regra ao instituto correto: fundadas razões (Tema 280) para ingresso domiciliar; fundado receio de fuga/perigo (SV 11) para algemas.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nB, C, D e E misturam ou trocam os institutos.'),
(29, E'GABARITO: alternativa C\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nA Declaração e Programa de Ação de Viena (1993), §5, assenta que todos os direitos humanos são universais e que a natureza universal desses direitos não admite dúvidas, cabendo aos Estados, independentemente de seus sistemas políticos, econômicos e culturais, promover e proteger todos os direitos humanos, sem prejuízo de se considerarem as particularidades nacionais e regionais como contexto — não como justificativa para violação. A alternativa C está de acordo com esse paradigma.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA e B admitem indevidamente que o relativismo cultural autorize violação a direitos humanos. D isenta indevidamente o Estado de responsabilização. E limita sem base normativa a universalidade a apenas uma categoria de direitos.'),
(30, E'GABARITO: alternativa E\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nA interdependência e a indivisibilidade apontam que os direitos humanos formam um complexo único: a violação a direitos sociais compromete a fruição de direitos civis e políticos. A alternativa E aponta as características corretas.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA e B são características reais mas sem relação com o enunciado; C e D afirmam o falso.'),
(31, E'GABARITO: alternativa B\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nA dignidade da pessoa humana (CF, art. 1º, III) é, a um só tempo, fundamento da República e limite da atuação estatal, vedando a imposição de penas cruéis ou tratamentos desumanos/degradantes. A alternativa B expressa esse duplo papel, tornando a marcação física ilegítima.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA e C admitem indevidamente poder estatal ilimitado ou perda da dignidade por condenação. D e E buscam, de forma irreal, legalizar a prática.'),
(32, E'GABARITO: alternativa D\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO art. 42-A, §2º, da Lei 13.675/2018 (incluído pela Lei 14.531/2023) elenca, entre outras, as seguintes diretrizes: inciso I — perspectiva multiprofissional na abordagem; inciso II — atendimento e escuta multidisciplinar e de proximidade; inciso III — discrição e respeito à intimidade nos atendimentos. A alternativa D atribui corretamente cada conteúdo ao seu respectivo inciso.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA afasta a multiprofissionalidade exigida. B subverte o sigilo, colocando a queixa sob hierarquia indevida. C cria regra de 90 dias inexistente no texto legal. E ignora o dever de discrição.'),
(33, E'GABARITO: alternativa A\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO art. 42-B, inciso I, prevê a adequação das leis e regulamentos disciplinares que versam sobre direitos e deveres dos profissionais à Constituição Federal e aos instrumentos internacionais de direitos humanos. O inciso IV prevê o acesso a equipamentos de proteção individual e coletiva em quantidade e qualidade adequadas, com instrução e treinamento continuado quanto ao uso correto e reposição permanente, considerados o desgaste e os prazos de validade. A alternativa A reúne integralmente esses dois incisos.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nB, C, D e E contêm precarização deliberada ou excessos não previstos no texto legal. O inciso III do art. 42-B permanece VETADO, não tendo sido atribuído a ele nenhum conteúdo.');

create temporary table _lote_alternativas (
  ordem int,
  ordem_alt smallint,
  texto text,
  correta boolean
) on commit drop;

insert into _lote_alternativas (ordem, ordem_alt, texto, correta) values
(1,1,'vedada, pois não se admite restrição ou suspensão de direitos humanos fundamentais já reconhecidos em virtude de leis ou convenções sob o pretexto de que o Pacto não os reconhece ou os reconhece em menor grau.',true),
(1,2,'permitida, desde que o Estado promova o bem-estar geral e a restrição seja autorizada por lei aprovada no parlamento.',false),
(1,3,'vedada, exceto se a restrição for temporária e decorrer de estado de sítio ou de defesa devidamente decretado.',false),
(1,4,'permitida, pois os tratados internacionais de direitos humanos estabelecem o teto máximo de proteção exigível dos Estados Partes.',false),
(1,5,'vedada, salvo se houver autorização expressa do Conselho de Segurança da Organização das Nações Unidas.',false),

(2,1,'previdência social, desde que comprove tempo mínimo de serviço em atividades de risco.',false),
(2,2,'previdência social, inclusive ao seguro social.',true),
(2,3,'previdência social, independentemente de contribuição ao sistema securitário.',false),
(2,4,'assistência social ampla, incluindo seguro social para todos os cidadãos natos.',false),
(2,5,'previdência social, garantida apenas aos trabalhadores urbanos e rurais.',false),

(3,1,'pertencente ao patrimônio cultural do Estado em que reside, mesmo que de autoria difusa.',false),
(3,2,'independentemente de autoria, desde que os interesses materiais sejam revertidos à coletividade.',false),
(3,3,'de que seja autora.',true),
(3,4,'de que seja proprietária ou cessionária dos direitos de exploração econômica.',false),
(3,5,'que promova a preservação dos valores históricos e culturais de sua respectiva nação.',false),

(4,1,'A estatização dos meios de produção voltados aos setores básicos da economia.',false),
(4,2,'A garantia de salário-desemprego vitalício para trabalhadores substituídos pela automação.',false),
(4,3,'A implementação de cotas compulsórias para estrangeiros em empresas privadas.',false),
(4,4,'A orientação e formação técnica e profissional, além da elaboração de programas e normas.',true),
(4,5,'A imposição de limites máximos à remuneração dos empregados da iniciativa privada para garantir a igualdade material.',false),

(5,1,'a limitação é ilegal, pois o PIDESC não admite qualquer restrição aos direitos nele consagrados.',false),
(5,2,'a limitação é inválida, uma vez que o propósito de promover o bem-estar geral não justifica restrições de direitos econômicos.',false),
(5,3,'a limitação só seria válida se fosse determinada por decreto do Poder Executivo, para garantir agilidade na promoção do bem-estar social.',false),
(5,4,'a limitação é inválida, pois as restrições só são permitidas em situações de guerra ou emergência nacional declarada.',false),
(5,5,'a limitação é compatível com o PIDESC, pois ocorreu mediante lei, respeitou a natureza dos direitos e teve o fim exclusivo de promover o bem-estar geral em sociedade democrática.',true),

(6,1,'I, apenas.',false),
(6,2,'I e II, apenas.',true),
(6,3,'II e III, apenas.',false),
(6,4,'I e III, apenas.',false),
(6,5,'I, II e III.',false),

(7,1,'o direito à educação restringe-se à alfabetização básica, não alcançando o pleno desenvolvimento da personalidade humana.',false),
(7,2,'o direito ao trabalho pressupõe a escolha compulsória da atividade profissional pelo Estado, conforme critérios de utilidade pública.',false),
(7,3,'o direito à educação limita-se a fortalecer o respeito às autoridades constituídas, sem relação com direitos humanos ou liberdades fundamentais.',false),
(7,4,'o direito ao trabalho compreende o direito de toda pessoa de ganhar a vida por um trabalho livremente escolhido ou aceito, ao passo que o direito à educação deve visar ao pleno desenvolvimento da personalidade humana e do sentido de sua dignidade, fortalecendo o respeito pelos direitos humanos e liberdades fundamentais.',true),
(7,5,'o direito ao trabalho e o direito à educação, segundo o PIDESC, dizem respeito exclusivamente à qualificação para cargos públicos, excluindo a iniciativa privada.',false),

(8,1,'Convenção Americana sobre Direitos Humanos (Pacto de San José da Costa Rica).',false),
(8,2,'Convenção sobre a Eliminação de Todas as Formas de Discriminação contra a Mulher (CEDAW).',false),
(8,3,'Convenção Interamericana contra o Racismo, a Discriminação Racial e Formas Correlatas de Intolerância.',true),
(8,4,'Convenção contra a Tortura e Outros Tratamentos ou Penas Cruéis, Desumanos ou Degradantes (ONU).',false),
(8,5,'Convenção Interamericana para Prevenir e Punir a Tortura.',false),

(9,1,'status de lei ordinária federal, uma vez que trata de direitos autorais e questões de acessibilidade.',false),
(9,2,'status de lei complementar, por exigir regulamentação infraconstitucional de escopo nacional.',false),
(9,3,'status supralegal, pois, embora verse sobre direitos humanos, não foi aprovado pelo quórum qualificado em ambas as Casas do Congresso Nacional.',false),
(9,4,'força de recomendação internacional, possuindo eficácia meramente persuasiva no ordenamento jurídico interno.',false),
(9,5,'equivalência a emenda constitucional, uma vez que foi aprovado pelo Congresso Nacional sob o rito do art. 5º, § 3º, da Constituição Federal.',true),

(10,1,'O Protocolo Facultativo à Convenção sobre os Direitos das Pessoas com Deficiência.',true),
(10,2,'O Pacto Internacional dos Direitos Civis e Políticos.',false),
(10,3,'A Declaração Universal dos Direitos Humanos.',false),
(10,4,'As Regras de Mandela sobre o Tratamento de Presos.',false),
(10,5,'O Protocolo de Istambul sobre Investigação de Tortura.',false),

(11,1,'idêntico ao das leis ordinárias, revogando normas anteriores em sentido contrário, mas sujeitos ao controle de constitucionalidade amplo.',false),
(11,2,'de supralegalidade, situando-se abaixo da Constituição Federal, mas acima da legislação infraconstitucional, paralisando a eficácia das leis que com eles conflitem.',true),
(11,3,'de bloco de constitucionalidade amplo, possuindo força de emenda constitucional pelo simples fato de versarem sobre direitos humanos, independentemente do rito de votação.',false),
(11,4,'constitucional imediato, de forma que qualquer lei posterior que os contrarie será inconstitucional, mesmo que não tenham passado pelo crivo das duas Casas em dois turnos.',false),
(11,5,'infraconstitucional e infralegal, servindo apenas como diretrizes interpretativas de última ratio para o poder Judiciário.',false),

(12,1,'em sessão conjunta, em turno único de votação, por maioria absoluta dos votos de deputados e senadores.',false),
(12,2,'na Câmara dos Deputados e no Senado Federal, em turno único, por maioria simples de seus membros.',false),
(12,3,'em cada Casa do Congresso Nacional, em dois turnos, pela maioria absoluta dos votos dos respectivos membros.',false),
(12,4,'em cada Casa do Congresso Nacional, em dois turnos, por três quintos dos votos dos respectivos membros.',true),
(12,5,'no Senado Federal, com exclusividade, em três turnos, por dois terços dos votos favoráveis.',false),

(13,1,'I e III, apenas.',true),
(13,2,'II, apenas.',false),
(13,3,'I e II, apenas.',false),
(13,4,'II e III, apenas.',false),
(13,5,'I, II e III.',false),

(14,1,'Todo e qualquer tratado de direitos humanos incorporado ao ordenamento adquire status de emenda constitucional, independentemente do rito de votação no Congresso Nacional.',false),
(14,2,'Os tratados incorporados sem o rito qualificado assumem valor de lei complementar, possuindo eficácia paralisante apenas em matéria tributária.',false),
(14,3,'A aprovação segundo o rito qualificado confere ao tratado força supralegal, ao passo que a aprovação ordinária lhe confere força de lei ordinária.',false),
(14,4,'A incorporação de tratados sem o rito qualificado os equipara, em qualquer hipótese, a emendas constitucionais tácitas, integrando o bloco de constitucionalidade estrito.',false),
(14,5,'A aprovação pelo rito qualificado confere equivalência às emendas constitucionais, enquanto a incorporação sem tal rito confere status supralegal.',true),

(15,1,'são considerados tortura os sofrimentos decorrentes de qualquer medida legal de privação de liberdade, por violação do princípio da dignidade.',false),
(15,2,'não estarão compreendidas no conceito de tortura as penas ou sofrimentos físicos ou mentais que sejam unicamente consequência de medidas legais ou inerentes a elas, desde que não incluam a realização dos atos ou a aplicação dos métodos vedados por esse mesmo dispositivo.',true),
(15,3,'a aplicação de medidas legais penais, quando superiores a dez anos de privação de liberdade, é considerada tortura presumida.',false),
(15,4,'o isolamento celular preventivo determinado por juiz constitui tortura, não sendo protegido pela excludente de medidas legais.',false),
(15,5,'apenas as penas corporais previstas na legislação interna dos Estados Partes estão fora do conceito de tortura.',false),

(16,1,'válida, pois transfere a responsabilidade penal exclusivamente ao oficial que emanou a ordem.',false),
(16,2,'válida, servindo como causa de exclusão da ilicitude do ato de tortura.',false),
(16,3,'inválida, pois o fato de ter agido sob ordens de um superior não eximirá da responsabilidade penal correspondente.',true),
(16,4,'parcialmente válida, eximindo a responsabilidade penal, mas mantendo a responsabilização civil e disciplinar.',false),
(16,5,'inválida, exceto se a ordem for dada em estado de emergência decretado nacionalmente.',false),

(17,1,'caracteriza responsabilização apenas administrativa, pois o crime de tortura exige conduta comissiva (ação direta).',false),
(17,2,'não gera responsabilização criminal internacional, uma vez que ele não instigou nem induziu a prática dos atos.',false),
(17,3,'caracteriza responsabilidade penal, mas limitada exclusivamente à modalidade de instigação ou indução, já que era superior hierárquico.',false),
(17,4,'não gera responsabilidade por tortura, configurando apenas crime de prevaricação segundo as leis internas do Estado Parte.',false),
(17,5,'gera responsabilização penal como agente de tortura, uma vez que a Convenção pune não apenas quem ordena ou comete diretamente, mas também quem, podendo impedir o ato, não o faz.',true),

(18,1,'configura tortura, pois o conceito convencional abrange a aplicação de métodos sobre a pessoa destinados a anular sua personalidade ou diminuir sua capacidade mental, mesmo que não causem dor física ou angústia psíquica.',true),
(18,2,'não configura tortura, uma vez que a Convenção exige cumulativamente a provocação de dor física ou sofrimento mental agudo.',false),
(18,3,'configura tratamentos degradantes, mas não alcança o status jurídico de tortura devido à ausência de dor física comprovada.',false),
(18,4,'não configura tortura, pois a aplicação de substâncias químicas em contexto de inteligência de Estado é ressalvada pelo documento internacional.',false),
(18,5,'configura tortura apenas se for comprovado que a substância experimental resultou em dano cerebral permanente na vítima.',false),

(19,1,'válida como atenuante da pena a ser imposta ao comandante pelo tribunal competente.',false),
(19,2,'lícita, pois o risco à integridade física dos agentes de Estado atua como excludente de culpabilidade na legislação internacional.',false),
(19,3,'legítima, tendo em vista que a segurança institucional se sobrepõe temporariamente às garantias individuais dos detentos.',false),
(19,4,'inválida, pois a Convenção estipula expressamente que não se pode invocar a periculosidade do detido nem a insegurança do estabelecimento como justificativa para a tortura.',true),
(19,5,'válida apenas sob a condição de prévia decretação formal de estado de sítio ou suspensão de garantias pelo poder Legislativo do país.',false),

(20,1,'O Estado deve adotar leis que considerem a tortura como contravenção penal ou delito de menor potencial ofensivo, sujeito a medidas alternativas à prisão.',false),
(20,2,'O Estado deve tornar a tortura um delito de acordo com sua legislação penal e estabelecer para ele penas severas que levem em conta a sua gravidade.',true),
(20,3,'O Estado deve prever punições unicamente de caráter administrativo, militar e disciplinar para os agentes públicos envolvidos.',false),
(20,4,'O Estado deve submeter os casos de tortura diretamente à Corte Interamericana, dispensando a tipificação do crime na legislação interna.',false),
(20,5,'O Estado deve aplicar penas severas unicamente se a vítima de tortura pertencer a algum grupo socialmente vulnerável reconhecido por comitês de direitos humanos.',false),

(21,1,'I, apenas.',false),
(21,2,'I e II, apenas.',false),
(21,3,'I e III, apenas.',true),
(21,4,'II e III, apenas.',false),
(21,5,'I, II e III.',false),

(22,1,'lícito, pois a gravidade do crime de colarinho branco torna o uso de algemas obrigatório para qualquer preso.',false),
(22,2,'lícito, já que o uso de algemas é discricionário e independe de risco de fuga ou resistência no momento da prisão.',false),
(22,3,'ilícito, devendo a prisão ser mantida intacta, havendo apenas responsabilização civil por danos morais para o Estado.',false),
(22,4,'ilícito, pois só é lícito o uso de algemas em casos de resistência e de fundado receio de fuga ou de perigo à integridade física própria ou alheia, sob pena de responsabilidade e nulidade da prisão.',true),
(22,5,'ilícito, salvo se o delegado justificar oralmente a medida na delegacia para evitar constrangimento à imagem pública do empresário.',false),

(23,1,'violou a Súmula Vinculante, pois as algemas não podem ser utilizadas durante transporte em via pública, sob qualquer pretexto.',false),
(23,2,'gerou nulidade da prisão em flagrante, pois o uso de algemas demandava autorização judicial prévia, mesmo em situação de resistência.',false),
(23,3,'caracteriza abuso de autoridade absoluto, já que a súmula proibiu o uso de algemas em todo o território nacional.',false),
(23,4,'foi regular na rua, porém a justificativa por escrito é considerada ato nulo, devendo a comprovação ser feita por testemunhas civis no inquérito.',false),
(23,5,'observou estritamente os comandos da Súmula, que admite o uso de algemas em caso de resistência, fundado receio de fuga ou perigo à integridade, desde que justificada a excepcionalidade por escrito.',true),

(24,1,'lícita, pois a entrada forçada em domicílio sem mandado judicial, a qualquer hora do dia ou da noite, é legítima se amparada em fundadas razões, devidamente justificadas a posteriori, que indiquem situação de flagrante delito no interior.',true),
(24,2,'ilícita, visto que o ingresso noturno só pode ocorrer com consentimento do morador, independentemente da situação de flagrante delito visível.',false),
(24,3,'lícita temporariamente, mas sujeita à convalidação exclusiva por um juiz de garantias no prazo de 24 horas, sob pena de trancamento da ação penal.',false),
(24,4,'ilícita, pois o STF exige que o flagrante seja de crimes hediondos contra a vida para flexibilizar a inviolabilidade de domicílio durante a noite.',false),
(24,5,'lícita, mas restrita à apreensão da droga, sendo nula a prisão do agente pela ausência de mandado de busca e apreensão.',false),

(25,1,'lícitos, pois a confirmação do flagrante (encontro da droga) legitima de forma retroativa o arrombamento e convalida a ação policial.',false),
(25,2,'lícitos, uma vez que a denúncia anônima supre, por si só, o requisito de fundadas razões exigido constitucionalmente.',false),
(25,3,'ilícitos, pois a entrada forçada exige fundadas razões amparadas em elementos prévios objetivos, não sendo suficiente a mera denúncia anônima desacompanhada de diligências prévias.',true),
(25,4,'lícitos exclusivamente se o crime for classificado como hediondo, hipótese na qual o Supremo Tribunal Federal dispensa a exigência de justa causa para a invasão.',false),
(25,5,'ilícitos durante o período noturno, mas se a invasão ocorreu durante o dia, os atos e provas são plenamente lícitos e aproveitáveis pela acusação.',false),

(26,1,'oitiva imediata de testemunhas civis previamente à entrada forçada.',false),
(26,2,'amparo em fundadas razões, devidamente justificadas a posteriori, que indiquem previamente a situação de flagrante no interior.',true),
(26,3,'prévia manifestação de concordância pelo Ministério Público local em plantão judiciário.',false),
(26,4,'uso obrigatório de câmeras corporais para atestar a materialidade do desastre ou prestação de socorro.',false),
(26,5,'consentimento do morador colhido exclusivamente mediante assinatura em termo físico ou gravação audiovisual antes do ingresso.',false),

(27,1,'Responsabilidade apenas administrativa do agente e demissão a bem do serviço público do chefe da operação policial.',false),
(27,2,'Responsabilidade disciplinar, civil e penal do agente, sem afetar, contudo, a validade da prisão efetuada, prestigiando a ordem pública.',false),
(27,3,'Nulidade absoluta de todos os atos do inquérito policial e transferência de jurisdição para a Justiça Federal.',false),
(27,4,'Responsabilidade disciplinar, civil e penal do agente ou da autoridade, nulidade da prisão ou do ato processual, sem prejuízo da responsabilidade civil do Estado.',true),
(27,5,'Exclusão dos quadros da corporação de imediato, responsabilidade subsidiária do ente federativo e perda automática do cargo público.',false),

(28,1,'A exigência de fundadas razões, justificadas posteriormente, aplica-se ao ingresso forçado em domicílio sem mandado, ao passo que a exigência de fundado receio de fuga ou perigo à integridade restringe o uso de algemas.',true),
(28,2,'O Tema 280 do STF proíbe categoricamente o uso de algemas, enquanto a Súmula Vinculante 11 cuida unicamente da busca domiciliar baseada em denúncia anônima.',false),
(28,3,'A Súmula Vinculante 11 impõe restrições ao ingresso em domicílio para o cumprimento de mandados noturnos, enquanto o Tema 280 determina o uso de algemas em flagrante.',false),
(28,4,'A exigência de fundadas razões, justificadas por escrito, é um requisito da Súmula Vinculante 11 para entrar em domicílios sem mandado, sob pena de nulidade processual.',false),
(28,5,'A inviolabilidade do domicílio é regulada unicamente pela Súmula Vinculante 11, e o uso de algemas foi definido no Tema 280 como prática sempre admissível à noite.',false),

(29,1,'válida, pois o relativismo cultural absoluto foi consagrado pela ONU como escudo frente a interferências estrangeiras, prevalecendo sobre os direitos humanos individuais.',false),
(29,2,'válida, já que as particularidades nacionais e regionais autorizam a violação do núcleo essencial dos direitos humanos em prol da identidade do povo.',false),
(29,3,'inválida, pois a Declaração de Viena assentou a universalidade dos direitos humanos, não cabendo ao Estado, a pretexto de suas particularidades culturais, furtar-se à obrigação de promover os direitos fundamentais.',true),
(29,4,'inválida, mas os órgãos de direitos humanos devem abster-se de condenar o Estado, pois a soberania e a autodeterminação dos povos são absolutas.',false),
(29,5,'válida apenas em matéria de direitos civis e políticos, não servindo como escusa para os direitos econômicos, sociais e culturais.',false),

(30,1,'imprescritibilidade, que proíbe a perda dos direitos com o passar do tempo.',false),
(30,2,'inexauribilidade, que prevê a criação infinita de novos direitos sociais pelo Estado.',false),
(30,3,'relatividade, que permite ao Estado escolher quais direitos podem ser ignorados por ausência de recursos.',false),
(30,4,'renunciabilidade, que permite que a população vulnerável abdique de sua instrução em favor do voto.',false),
(30,5,'interdependência e indivisibilidade, que demonstram a conexão orgânica entre os direitos e a impossibilidade de os fruir plenamente de forma isolada.',true),

(31,1,'legítima, pois o poder punitivo do Estado é ilimitado em casos de grande comoção social.',false),
(31,2,'ilegítima, pois a dignidade da pessoa humana constitui fundamento e limite da atuação estatal, vedando a imposição de penas ou tratamentos cruéis, desumanos ou degradantes.',true),
(31,3,'legítima, tendo em vista que, para condenados por crimes violentos, a dignidade humana deixa de ser um direito inerente e passa a ser condicional ao bom comportamento.',false),
(31,4,'ilegítima exclusivamente por falta de previsão expressa nas leis eleitorais do país, dependendo de plebiscito para validar a marcação permanente.',false),
(31,5,'ilegítima, salvo se a marcação for realizada sob supervisão médica, em ambiente hospitalar seguro, neutralizando a tortura física do procedimento.',false),

(32,1,'o tratamento do profissional por meio exclusivo de psiquiatria, dispensando o suporte de outras categorias de saúde por razões de confidencialidade tática.',false),
(32,2,'a imposição de subordinação direta das queixas de sofrimento psíquico ao comando hierárquico, priorizando a estabilidade da tropa e a disciplina militar acima do sigilo médico.',false),
(32,3,'a aplicação de afastamento remunerado obrigatório de noventa dias logo no primeiro relato de angústia mental, independentemente de laudo profissional.',false),
(32,4,'a perspectiva multiprofissional na abordagem (inciso I), o atendimento e a escuta multidisciplinar e de proximidade (inciso II), e a discrição e o respeito à intimidade nos atendimentos (inciso III).',true),
(32,5,'a inclusão de avaliações psicológicas coletivas e abertas na tropa para aumentar a coesão social, renunciando o direito à intimidade frente ao grupo.',false),

(33,1,'A adequação das leis e dos regulamentos disciplinares que versam sobre direitos e deveres dos profissionais de segurança pública e defesa social à Constituição Federal e aos instrumentos internacionais de direitos humanos, e o acesso a equipamentos de proteção individual e coletiva em quantidade e qualidade adequadas, garantindo a instrução e o treinamento continuado quanto ao uso correto dos equipamentos e a sua reposição permanente, considerados o desgaste e os prazos de validade.',true),
(33,2,'A manutenção de normas disciplinares estritas herdadas da caserna, dispensando-se a adequação a tratados internacionais de direitos humanos, e o acesso facultativo aos equipamentos de proteção quando o ente federativo possuir viabilidade fiscal comprovada.',false),
(33,3,'A proibição de revisão dos regulamentos disciplinares em vigor, a fim de garantir a segurança jurídica, e o oferecimento obrigatório de blindagem integral para os veículos de uso privado dos policiais que exercem atividade de risco.',false),
(33,4,'A obrigatoriedade de aquisição de armamento bélico de uso exclusivo do Exército para patrulhamento ordinário urbano, em adequação imediata aos tratados de defesa internacional americanos.',false),
(33,5,'A imposição de treinamento de tiro exclusivamente semestral e a substituição de equipamentos de proteção individual antigos por material doado de outras forças, dispensando parâmetros técnicos.',false);

-- Precondicoes.
do $$
declare
  v_cnt int;
  v_dup int;
begin
  select count(*) into v_cnt from _lote_questoes;
  if v_cnt <> 33 then
    raise exception 'Precondicao falhou: staging tem % questoes (esperado 33)', v_cnt;
  end if;

  select count(*) into v_dup
  from _lote_questoes lq
  where exists (select 1 from public.questoes q where q.enunciado = lq.enunciado);
  if v_dup <> 0 then
    raise exception 'Precondicao falhou: % enunciado(s) identicos ja existem no banco', v_dup;
  end if;

  select count(*) into v_dup
  from _lote_questoes lq
  where not exists (select 1 from public.unidades_pedagogicas u where u.id = lq.unidade_id and u.ativa);
  if v_dup <> 0 then
    raise exception 'Precondicao falhou: % unidade(s)-alvo inexistente(s) ou inativa(s)', v_dup;
  end if;

  select count(*) into v_dup
  from _lote_questoes lq
  join public.unidades_pedagogicas u on u.id = lq.unidade_id
  join public.curso_conteudos cc on cc.id = u.curso_conteudo_id
  where cc.assunto_id is distinct from lq.assunto_id;
  if v_dup <> 0 then
    raise exception 'Precondicao falhou: % linha(s) com assunto_id divergente da unidade-alvo', v_dup;
  end if;

  select count(*) into v_dup from _lote_questoes where dificuldade not in ('facil','media','dificil');
  if v_dup <> 0 then
    raise exception 'Precondicao falhou: % linha(s) com dificuldade fora do dominio permitido', v_dup;
  end if;

  if (select count(*) from _lote_questoes where cc_id=77) <> 7 then raise exception 'Precondicao falhou: staging cc77 <> 7'; end if;
  if (select count(*) from _lote_questoes where cc_id=78) <> 7 then raise exception 'Precondicao falhou: staging cc78 <> 7'; end if;
  if (select count(*) from _lote_questoes where cc_id=79) <> 7 then raise exception 'Precondicao falhou: staging cc79 <> 7'; end if;
  if (select count(*) from _lote_questoes where cc_id=80) <> 7 then raise exception 'Precondicao falhou: staging cc80 <> 7'; end if;
  if (select count(*) from _lote_questoes where cc_id=81) <> 5 then raise exception 'Precondicao falhou: staging cc81 <> 5'; end if;

  if (select cc77_uteis from _snapshot_antes) <> 3 then raise exception 'Precondicao falhou: cc77_uteis=% (esperado 3)', (select cc77_uteis from _snapshot_antes); end if;
  if (select cc78_uteis from _snapshot_antes) <> 3 then raise exception 'Precondicao falhou: cc78_uteis=% (esperado 3)', (select cc78_uteis from _snapshot_antes); end if;
  if (select cc79_uteis from _snapshot_antes) <> 3 then raise exception 'Precondicao falhou: cc79_uteis=% (esperado 3)', (select cc79_uteis from _snapshot_antes); end if;
  if (select cc80_uteis from _snapshot_antes) <> 3 then raise exception 'Precondicao falhou: cc80_uteis=% (esperado 3)', (select cc80_uteis from _snapshot_antes); end if;
  if (select cc81_uteis from _snapshot_antes) <> 5 then raise exception 'Precondicao falhou: cc81_uteis=% (esperado 5)', (select cc81_uteis from _snapshot_antes); end if;
end $$;

-- Insercao das questoes + alternativas.
create temporary table _mapa_ids (ordem int primary key, questao_id bigint) on commit drop;

do $$
declare r record; v_id bigint;
begin
  for r in select * from _lote_questoes order by ordem loop
    insert into public.questoes (materia_id, assunto_id, banca, concurso, ano, enunciado, dificuldade, explicacao, fonte, ativa, gerada_por_ia)
    values (11, r.assunto_id, 'Papiro', 'PAPIRO - Curadoria DH-AUT-02 - BM RS', 2026, r.enunciado, r.dificuldade,
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

-- Pos-condicoes ENDURECIDAS.
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
  v_cc77_uteis int; v_cc78_uteis int; v_cc79_uteis int; v_cc80_uteis int; v_cc81_uteis int;
  v_cc77_real int; v_cc78_real int; v_cc79_real int; v_cc80_real int; v_cc81_real int;
  v_dh_uteis_depois int;
begin
  select count(*) into v_novas_questoes from public.questoes where id in (select questao_id from _mapa_ids);
  if v_novas_questoes <> 33 then
    raise exception 'Pos-condicao falhou: questoes novas=% (esperado 33)', v_novas_questoes;
  end if;

  if (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and materia_id <> 11) <> 0 then
    raise exception 'Pos-condicao falhou: alguma questao nao tem materia_id=11';
  end if;
  if (select count(*) from public.questoes q join _mapa_ids m on m.questao_id = q.id join _lote_questoes lq on lq.ordem = m.ordem where q.assunto_id <> lq.assunto_id) <> 0 then
    raise exception 'Pos-condicao falhou: alguma questao tem assunto_id divergente do esperado';
  end if;
  if (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and ativa is distinct from true) <> 0 then
    raise exception 'Pos-condicao falhou: alguma questao nao esta ativa';
  end if;

  select count(*) into v_nao_autoral from public.questoes where id in (select questao_id from _mapa_ids) and coalesce(lower(banca),'') not like '%papiro%';
  if v_nao_autoral <> 0 then
    raise exception 'Pos-condicao falhou: % questao(oes) sem banca papiro (esperado 0 — todas AUTORAL_PAPIRO)', v_nao_autoral;
  end if;

  select count(*) into v_novas_alternativas from public.alternativas where questao_id in (select questao_id from _mapa_ids);
  if v_novas_alternativas <> 165 then
    raise exception 'Pos-condicao falhou: alternativas novas=% (esperado 165 = 33x5)', v_novas_alternativas;
  end if;

  select count(*) into v_corretas_invalidas
  from (select questao_id, count(*) filter (where correta) as n from public.alternativas where questao_id in (select questao_id from _mapa_ids) group by questao_id having count(*) filter (where correta) <> 1) x;
  if v_corretas_invalidas <> 0 then
    raise exception 'Pos-condicao falhou: % questao(oes) sem exatamente 1 alternativa correta', v_corretas_invalidas;
  end if;

  select count(*) into v_facil from public.questoes where id in (select questao_id from _mapa_ids) and dificuldade='facil';
  select count(*) into v_media from public.questoes where id in (select questao_id from _mapa_ids) and dificuldade='media';
  select count(*) into v_dificil from public.questoes where id in (select questao_id from _mapa_ids) and dificuldade='dificil';
  if v_facil <> 7 or v_media <> 16 or v_dificil <> 10 then
    raise exception 'Pos-condicao falhou: distribuicao dificuldade facil=%/media=%/dificil=% (esperado 7/16/10)', v_facil, v_media, v_dificil;
  end if;

  select count(*) into v_A from public.alternativas a join _mapa_ids m on a.questao_id=m.questao_id where a.correta and a.ordem=1;
  select count(*) into v_B from public.alternativas a join _mapa_ids m on a.questao_id=m.questao_id where a.correta and a.ordem=2;
  select count(*) into v_C from public.alternativas a join _mapa_ids m on a.questao_id=m.questao_id where a.correta and a.ordem=3;
  select count(*) into v_D from public.alternativas a join _mapa_ids m on a.questao_id=m.questao_id where a.correta and a.ordem=4;
  select count(*) into v_E from public.alternativas a join _mapa_ids m on a.questao_id=m.questao_id where a.correta and a.ordem=5;
  if v_A <> 7 or v_B <> 7 or v_C <> 6 or v_D <> 7 or v_E <> 6 then
    raise exception 'Pos-condicao falhou: gabaritos A=%/B=%/C=%/D=%/E=% (esperado 7/7/6/7/6)', v_A, v_B, v_C, v_D, v_E;
  end if;

  select count(*) into v_novos_vinculos from public.questao_unidades_pedagogicas where questao_id in (select questao_id from _mapa_ids);
  if v_novos_vinculos <> 33 then
    raise exception 'Pos-condicao falhou: vinculos novos=% (esperado 33)', v_novos_vinculos;
  end if;

  select count(*) into v_multiunidade
  from (select questao_id from public.questao_unidades_pedagogicas where questao_id in (select questao_id from _mapa_ids) group by questao_id having count(*) > 1) x;
  if v_multiunidade <> 0 then
    raise exception 'Pos-condicao falhou: % questao(oes) com mais de 1 vinculo', v_multiunidade;
  end if;

  if exists (
    select 1 from _mapa_ids m
    join _lote_questoes lq on lq.ordem = m.ordem
    where not exists (
      select 1 from public.questao_unidades_pedagogicas qup
      join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
      where qup.questao_id = m.questao_id and up.curso_conteudo_id = lq.cc_id
    )
  ) then
    raise exception 'Pos-condicao falhou: alguma questao nao esta vinculada ao cc_id esperado do staging';
  end if;

  select count(distinct qup.questao_id) into v_cc77_uteis from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id where up.curso_conteudo_id=77;
  select count(distinct qup.questao_id) into v_cc78_uteis from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id where up.curso_conteudo_id=78;
  select count(distinct qup.questao_id) into v_cc79_uteis from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id where up.curso_conteudo_id=79;
  select count(distinct qup.questao_id) into v_cc80_uteis from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id where up.curso_conteudo_id=80;
  select count(distinct qup.questao_id) into v_cc81_uteis from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id where up.curso_conteudo_id=81;

  if v_cc77_uteis <> (select cc77_uteis from _snapshot_antes) + 7 then raise exception 'Pos-condicao falhou: cc77_uteis=% (esperado %)', v_cc77_uteis, (select cc77_uteis from _snapshot_antes)+7; end if;
  if v_cc78_uteis <> (select cc78_uteis from _snapshot_antes) + 7 then raise exception 'Pos-condicao falhou: cc78_uteis=% (esperado %)', v_cc78_uteis, (select cc78_uteis from _snapshot_antes)+7; end if;
  if v_cc79_uteis <> (select cc79_uteis from _snapshot_antes) + 7 then raise exception 'Pos-condicao falhou: cc79_uteis=% (esperado %)', v_cc79_uteis, (select cc79_uteis from _snapshot_antes)+7; end if;
  if v_cc80_uteis <> (select cc80_uteis from _snapshot_antes) + 7 then raise exception 'Pos-condicao falhou: cc80_uteis=% (esperado %)', v_cc80_uteis, (select cc80_uteis from _snapshot_antes)+7; end if;
  if v_cc81_uteis <> (select cc81_uteis from _snapshot_antes) + 5 then raise exception 'Pos-condicao falhou: cc81_uteis=% (esperado %)', v_cc81_uteis, (select cc81_uteis from _snapshot_antes)+5; end if;

  if v_cc77_uteis <> 10 or v_cc78_uteis <> 10 or v_cc79_uteis <> 10 or v_cc80_uteis <> 10 or v_cc81_uteis <> 10 then
    raise exception 'Pos-condicao falhou: alguma unidade nao atingiu exatamente 10 uteis (cc77=%,cc78=%,cc79=%,cc80=%,cc81=%)', v_cc77_uteis, v_cc78_uteis, v_cc79_uteis, v_cc80_uteis, v_cc81_uteis;
  end if;

  select count(distinct qup.questao_id) into v_cc77_real from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id join public.questoes q on q.id=qup.questao_id where up.curso_conteudo_id=77 and coalesce(lower(q.banca),'') not like '%papiro%';
  select count(distinct qup.questao_id) into v_cc78_real from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id join public.questoes q on q.id=qup.questao_id where up.curso_conteudo_id=78 and coalesce(lower(q.banca),'') not like '%papiro%';
  select count(distinct qup.questao_id) into v_cc79_real from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id join public.questoes q on q.id=qup.questao_id where up.curso_conteudo_id=79 and coalesce(lower(q.banca),'') not like '%papiro%';
  select count(distinct qup.questao_id) into v_cc80_real from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id join public.questoes q on q.id=qup.questao_id where up.curso_conteudo_id=80 and coalesce(lower(q.banca),'') not like '%papiro%';
  select count(distinct qup.questao_id) into v_cc81_real from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id join public.questoes q on q.id=qup.questao_id where up.curso_conteudo_id=81 and coalesce(lower(q.banca),'') not like '%papiro%';

  if v_cc77_real <> (select cc77_real from _snapshot_antes) or v_cc78_real <> (select cc78_real from _snapshot_antes)
     or v_cc79_real <> (select cc79_real from _snapshot_antes) or v_cc80_real <> (select cc80_real from _snapshot_antes)
     or v_cc81_real <> (select cc81_real from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: contagem REAL de alguma unidade mudou indevidamente (deveria permanecer inalterada, pois este lote e 100%% autoral)';
  end if;

  select count(distinct qup.questao_id) into v_dh_uteis_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.curso_conteudos cc on cc.id = up.curso_conteudo_id
    join public.assuntos a on a.id = cc.assunto_id
    where a.materia_id = 11;
  if v_dh_uteis_depois <> (select dh_uteis from _snapshot_antes) + 33 then
    raise exception 'Pos-condicao falhou: dh_uteis=% (esperado %)', v_dh_uteis_depois, (select dh_uteis from _snapshot_antes) + 33;
  end if;

  if (select count(*) from public.questoes) <> (select total_questoes from _snapshot_antes) + 33 then
    raise exception 'Pos-condicao falhou: total de questoes nao cresceu exatamente 33';
  end if;
  if (select count(*) from public.alternativas) <> (select total_alternativas from _snapshot_antes) + 165 then
    raise exception 'Pos-condicao falhou: total de alternativas nao cresceu exatamente 165';
  end if;
  if (select count(*) from public.questao_unidades_pedagogicas) <> (select total_vinculos from _snapshot_antes) + 33 then
    raise exception 'Pos-condicao falhou: total de vinculos nao cresceu exatamente 33';
  end if;
  if (select count(*) from public.unidades_pedagogicas) <> (select total_unidades from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: quantidade de unidades pedagogicas mudou';
  end if;
  if (select count(*) from public.curso_conteudos) <> (select total_conteudos from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: quantidade de curso_conteudos mudou';
  end if;
  if (select count(*) from public.curso_questoes) <> (select total_curso_questoes from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: curso_questoes sofreu alteracao indevida';
  end if;
  if (select count(*) from public.respostas_usuarios) <> (select total_respostas from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: historico de respostas_usuarios mudou';
  end if;
  if (select count(*) from public.sessoes_estudo) <> (select total_sessoes from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: sessoes_estudo mudou';
  end if;

  raise notice 'Pos-condicoes OK: 33 questoes AUTORAL_PAPIRO novas / 165 alternativas / 33 vinculos / facil=% media=% dificil=% / gabaritos A=%,B=%,C=%,D=%,E=% / cc77..cc81 todas em 10 uteis / DH uteis %->%.',
    v_facil, v_media, v_dificil, v_A, v_B, v_C, v_D, v_E,
    (select dh_uteis from _snapshot_antes), v_dh_uteis_depois;
end $$;

commit;
