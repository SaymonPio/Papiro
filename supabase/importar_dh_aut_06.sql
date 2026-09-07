-- Aplicacao AUTORAL do Lote DH-AUT-06 de Direitos Humanos e Cidadania — 22
-- questoes novas AUTORAL_PAPIRO + 110 alternativas + 22 vinculos, validado
-- pelo harness supabase/importar_dh_aut_06_teste_rollback.sql (tudo_ok =
-- true precisa ser confirmado antes de rodar este arquivo).
--
-- Fecha o deficit_para_10 de 4 unidades de Direitos Humanos e Cidadania
-- (cc92 Protocolo de Assuncao sobre Direitos Humanos no Mercosul, cc93
-- Incorporacao de tratados de Direitos Humanos, cc94 Tratado de
-- Marraqueche, cc95 Direito a cidadania na Constituicao Federal), levando
-- cada uma a exatamente 10 uteis:
--   cc92: 4->10 (6 novas) | cc93: 5->10 (5 novas) | cc94: 4->10 (6 novas) | cc95: 5->10 (5 novas)
--
-- Origem: AUTORAL_PAPIRO em todas as 22 (banca='Papiro') — nunca REAL.
-- Conteudo integralmente auditado nesta sessao (DH-AUT-06 — auditoria
-- independente Claude + microauditoria final + errata editorial de
-- FUTURA-cc93-01), com verificacao de fontes primarias/oficiais: Decreto
-- no 7.225/2010 (Protocolo de Assuncao sobre Compromisso com a Promocao
-- e Protecao dos Direitos Humanos do Mercosul, arts. 1-6); art. 5o, §3o,
-- da CF e jurisprudencia do STF (RE 466.343/SP, RE 349.703, HC 87.585,
-- Sumula Vinculante 25); Decreto no 9.522/2018 e Decreto Legislativo no
-- 261/2015 (Tratado de Marraqueche, arts. 3-6); e art. 14 da CF, Lei no
-- 9.504/1997 (com redacao da Lei no 15.230/2025) e Lei no 9.709/1998.
-- A manutencao das explicacoes corrompidas de Q180/Q181/Q182 (cc92) e
-- Q189/Q190/Q191 (cc94) foi concluida em rodada tecnica anterior (commit
-- c9fdcff) e nao e tocada por este arquivo.
--
-- Mecanismo de identificacao/idempotencia: cada uma das 22 e identificada
-- de forma inequivoca pelo texto EXATO do proprio enunciado. Se este
-- arquivo for executado uma segunda vez, a precondicao de "enunciado
-- identico" abortara a transacao inteira antes de qualquer insercao. O
-- rollback seguro pos-apply (se necessario no futuro) esta em
-- supabase/reverter_dh_aut_06.sql, que localiza e remove exclusivamente
-- estas 22 questoes pelo mesmo criterio de enunciado exato.
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
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 92) as cc92_uteis,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.questoes q on q.id = qup.questao_id where up.curso_conteudo_id = 92 and coalesce(lower(q.banca),'') not like '%papiro%') as cc92_real,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 93) as cc93_uteis,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.questoes q on q.id = qup.questao_id where up.curso_conteudo_id = 93 and coalesce(lower(q.banca),'') not like '%papiro%') as cc93_real,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 94) as cc94_uteis,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.questoes q on q.id = qup.questao_id where up.curso_conteudo_id = 94 and coalesce(lower(q.banca),'') not like '%papiro%') as cc94_real,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 95) as cc95_uteis,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.questoes q on q.id = qup.questao_id where up.curso_conteudo_id = 95 and coalesce(lower(q.banca),'') not like '%papiro%') as cc95_real,
  (select count(distinct qup.questao_id)
     from public.questao_unidades_pedagogicas qup
     join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
     join public.curso_conteudos cc on cc.id = up.curso_conteudo_id
     join public.assuntos a on a.id = cc.assunto_id
     where a.materia_id = 11) as dh_uteis,
  (select md5(coalesce(explicacao,'')) from public.questoes where id = 180) as q180_hash,
  (select md5(coalesce(explicacao,'')) from public.questoes where id = 181) as q181_hash,
  (select md5(coalesce(explicacao,'')) from public.questoes where id = 182) as q182_hash,
  (select md5(coalesce(explicacao,'')) from public.questoes where id = 189) as q189_hash,
  (select md5(coalesce(explicacao,'')) from public.questoes where id = 190) as q190_hash,
  (select md5(coalesce(explicacao,'')) from public.questoes where id = 191) as q191_hash;

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
(1,'cc92-01','655700d6-b585-468f-8d98-8143090cbafb',93,92,'media','PAPIRO — DH-AUT-06 — cc92-01 — Protocolo de Assuncao art.2 cooperacao mutua',
 'O Protocolo de Assunção sobre Compromisso com a Promoção e Proteção dos Direitos Humanos do Mercosul (Decreto nº 7.225/2010) estabelece diretrizes fundamentais para o bloco regional. Nos termos do artigo 2º do referido Protocolo, a atuação dos Estados Partes no âmbito da promoção e proteção efetiva dos direitos humanos fundamenta-se:'),
(2,'cc92-02','655700d6-b585-468f-8d98-8143090cbafb',93,92,'dificil','PAPIRO — DH-AUT-06 — cc92-02 — Protocolo de Assuncao art.3 hipotese de aplicacao',
 'Considere a hipótese de que, em um Estado Parte do Mercosul, ocorram graves e sistemáticas violações dos direitos humanos e das liberdades fundamentais, no contexto de uma crise institucional que abala a normalidade das instituições do país. Diante desse quadro fático, e considerando exclusivamente o rito estabelecido no Protocolo de Assunção sobre Compromisso com a Promoção e Proteção dos Direitos Humanos do Mercosul, a primeira providência institucional aplicável é:'),
(3,'cc92-03','655700d6-b585-468f-8d98-8143090cbafb',93,92,'media','PAPIRO — DH-AUT-06 — cc92-03 — Protocolo de Assuncao art.4 medidas',
 'Durante o trâmite de verificação de violações sistemáticas a direitos fundamentais em um dos Estados Partes do Mercosul, o processo de consultas previsto no Protocolo de Assunção mostrou-se ineficaz, não resultando em qualquer mitigação das violações. Nessas circunstâncias, o artigo 4º do Protocolo estabelece que as demais Partes considerarão a natureza e o alcance das medidas a aplicar, tendo em vista a gravidade da situação. Dentre as medidas textualmente autorizadas pelo Protocolo para essa etapa, encontra-se a:'),
(4,'cc92-04','655700d6-b585-468f-8d98-8143090cbafb',93,92,'media','PAPIRO — DH-AUT-06 — cc92-04 — Protocolo de Assuncao art.5 procedimento decisorio',
 'Para que as medidas restritivas previstas no Protocolo de Assunção sobre Compromisso com a Promoção e Proteção dos Direitos Humanos do Mercosul sejam validamente adotadas e entrem em vigor, deve-se obedecer ao procedimento formal descrito em seu artigo 5º. Assinale a alternativa que apresenta corretamente esse rito procedimental.'),
(5,'cc92-05','655700d6-b585-468f-8d98-8143090cbafb',93,92,'media','PAPIRO — DH-AUT-06 — cc92-05 — Protocolo de Assuncao art.6 cessacao',
 'Após a imposição de medidas de suspensão de direitos a um Estado Parte do Mercosul, com fundamento no Protocolo de Assunção sobre Compromisso com a Promoção e Proteção dos Direitos Humanos, observa-se uma melhora significativa no cenário institucional daquele país. Segundo o regramento normativo próprio desse Protocolo, as medidas impostas cessarão:'),
(6,'cc92-06','655700d6-b585-468f-8d98-8143090cbafb',93,92,'facil','PAPIRO — DH-AUT-06 — cc92-06 — Decreto 7225/2010 incorporacao',
 'Para que os tratados internacionais tenham aplicabilidade no âmbito interno brasileiro, exige-se a observância de um rito complexo de internalização que envolve o Congresso Nacional e o Presidente da República. O Protocolo de Assunção sobre Compromisso com a Promoção e Proteção dos Direitos Humanos do Mercosul, assinado em 2005, foi devidamente incorporado ao ordenamento jurídico brasileiro mediante a aprovação parlamentar e a posterior promulgação executiva, consubstanciadas, respectivamente, no:'),
(7,'cc93-01','98b10517-14a2-4efe-8360-960cae263ad5',101,93,'media','PAPIRO — DH-AUT-06 — cc93-01 — Sumula Vinculante 25 depositario infiel',
 'Em importante julgamento sobre o status normativo dos tratados internacionais de direitos humanos no Brasil, o Supremo Tribunal Federal reconheceu o caráter supralegal do Pacto de San José da Costa Rica (Convenção Americana sobre Direitos Humanos). Essa constatação jurisprudencial gerou efeitos diretos no ordenamento jurídico brasileiro, cujo maior reflexo prático foi a edição da Súmula Vinculante nº 25. Assinale a alternativa que indica corretamente o impacto jurídico da referida supralegalidade:'),
(8,'cc93-02','98b10517-14a2-4efe-8360-960cae263ad5',101,93,'facil','PAPIRO — DH-AUT-06 — cc93-02 — tratados com status de EC exemplos',
 'A Emenda Constitucional nº 45/2004 inseriu o §3º no artigo 5º da Constituição Federal, criando um rito especial de aprovação para que tratados e convenções internacionais sobre direitos humanos ingressem no ordenamento brasileiro com equivalência de emendas constitucionais. No cenário brasileiro, são exemplos concretos de tratados que efetivamente passaram por esse rito e são equivalentes às emendas constitucionais:'),
(9,'cc93-03','98b10517-14a2-4efe-8360-960cae263ad5',101,93,'media','PAPIRO — DH-AUT-06 — cc93-03 — art.5 par.3 restrito a tratados de DH',
 'Suponha que o Estado brasileiro tenha celebrado um tratado internacional estritamente de cooperação aduaneira e redução tarifária com um país vizinho. Por considerar o acordo de suma importância econômica, as mesas diretoras da Câmara dos Deputados e do Senado Federal submeteram-no à votação em dois turnos, obtendo, em ambas as Casas, a aprovação por mais de três quintos dos votos dos seus membros. Com base na Constituição Federal, esse tratado econômico ostentará hierarquia de emenda constitucional?'),
(10,'cc93-04','98b10517-14a2-4efe-8360-960cae263ad5',101,93,'dificil','PAPIRO — DH-AUT-06 — cc93-04 — supralegalidade efeito sobre lei infraconstitucional',
 'Em 2010, o Estado brasileiro internalizou um tratado internacional de direitos humanos valendo-se do procedimento legislativo ordinário, ou seja, aprovação por maioria simples no Congresso Nacional. Anos mais tarde, em 2018, foi promulgada uma lei federal ordinária estipulando uma regra procedimental diretamente conflitante com a norma protetiva daquele tratado. Diante desse conflito normativo e da jurisprudência consolidada do Supremo Tribunal Federal (STF), a solução aplicável é a de que a norma:'),
(11,'cc93-05','98b10517-14a2-4efe-8360-960cae263ad5',101,93,'media','PAPIRO — DH-AUT-06 — cc93-05 — celebracao x referendo de tratados',
 'O processo de internalização de tratados e convenções internacionais exige a atuação coordenada dos Poderes Executivo e Legislativo, de acordo com as atribuições outorgadas pela Constituição Federal de 1988. No que concerne à repartição de competências constitucionais para a incorporação dessas normas ao direito interno, é correto afirmar que:'),
(12,'cc94-01','389ff0e7-38f5-4fe5-b66d-4ebbbb5ee9bf',105,94,'media','PAPIRO — DH-AUT-06 — cc94-01 — Marraqueche art.3 categoria de beneficiario',
 E'O Tratado de Marraqueche, em seu artigo 3º, não restringe sua proteção jurídica apenas às pessoas cegas ou com deficiência visual típica. O diploma internacional expande explicitamente o conceito de "beneficiário" para tutelar o acesso à leitura de outros grupos vulneráveis. Desta forma, enquadra-se legalmente como beneficiário do Tratado também a pessoa que:'),
(13,'cc94-02','389ff0e7-38f5-4fe5-b66d-4ebbbb5ee9bf',105,94,'dificil','PAPIRO — DH-AUT-06 — cc94-02 — Marraqueche art.4 mecanismo central',
 'Para garantir o efetivo acesso à cultura, o Tratado de Marraqueche estabelece exceções ou limitações aos direitos de autor. Segundo o artigo 4º do diploma legal, uma entidade autorizada pode realizar a produção, obtenção e o fornecimento de exemplares em formato acessível a um beneficiário, independentemente de prévia autorização do titular dos direitos autorais. Contudo, essa faculdade está condicionada ao preenchimento cumulativo de rígidos critérios normativos, dentre os quais se destaca a necessidade de que:'),
(14,'cc94-03','389ff0e7-38f5-4fe5-b66d-4ebbbb5ee9bf',105,94,'media','PAPIRO — DH-AUT-06 — cc94-03 — Marraqueche art.5 intercambio transfronteirico',
 'Na dinâmica de fomento ao acesso universal à literatura, o Tratado de Marraqueche instituiu mecanismos que extrapolam as divisas nacionais, visando otimizar recursos e acervos. Sobre o instituto do intercâmbio transfronteiriço de exemplares em formato acessível, delineado no artigo 5º do Tratado, é correto afirmar que:'),
(15,'cc94-04','389ff0e7-38f5-4fe5-b66d-4ebbbb5ee9bf',105,94,'media','PAPIRO — DH-AUT-06 — cc94-04 — Marraqueche art.6 importacao',
 'Para além das remessas feitas por instituições (o intercâmbio transfronteiriço), o Tratado de Marraqueche tutela a capacidade de a própria base destinatária trazer o material adaptado ao seu país. De acordo com a disciplina do artigo 6º do Tratado no que tange à importação de exemplares em formato acessível, assinale a premissa correta:'),
(16,'cc94-05','389ff0e7-38f5-4fe5-b66d-4ebbbb5ee9bf',105,94,'facil','PAPIRO — DH-AUT-06 — cc94-05 — Decreto Legislativo 261/2015 aprovacao',
 'O Tratado de Marraqueche foi aprovado pelo Congresso Nacional em conformidade com o quórum qualificado do art. 5º,§3º, da Constituição, por se tratar de tratado de direitos humanos. Assinale a alternativa que indica o ato normativo por meio do qual o Congresso Nacional aprovou formalmente o referido Tratado:'),
(17,'cc94-06','389ff0e7-38f5-4fe5-b66d-4ebbbb5ee9bf',105,94,'facil','PAPIRO — DH-AUT-06 — cc94-06 — Decreto 9522/2018 promulgacao',
 'A incorporação de um tratado internacional ao direito brasileiro envolve, em regra, duas etapas: aprovação pelo Congresso Nacional e promulgação pelo Presidente da República. Embora o Tratado de Marraqueche tenha sido aprovado pelo Congresso Nacional por meio do Decreto Legislativo nº 261/2015, sua promulgação no ordenamento jurídico interno — conferindo-lhe obrigatoriedade na jurisdição brasileira — deu-se pela via do:'),
(18,'cc95-01','c80fe9be-da9c-4e28-b2a1-27a04be17bf7',100,95,'dificil','PAPIRO — DH-AUT-06 — cc95-01 — Lei 15230/2025 momento de afericao',
 'Considerando a disciplina do art. 11,§2º, da Lei nº 9.504/1997, com redação dada pela Lei nº 15.230/2025, sobre o momento de aferição da idade mínima exigida para candidaturas, e sem prejuízo das idades fixadas no art. 14,§3º,VI, da Constituição Federal, assinale a alternativa que descreve corretamente o momento de verificação da idade mínima para candidatos a cargos do Poder Executivo e para candidatos às Câmaras Municipais, respectivamente:'),
(19,'cc95-02','c80fe9be-da9c-4e28-b2a1-27a04be17bf7',100,95,'media','PAPIRO — DH-AUT-06 — cc95-02 — art.14 par.3 condicoes de elegibilidade',
 'Para que um cidadão adquira plenamente o direito de disputar mandatos eletivos (capacidade eleitoral passiva) na República Federativa do Brasil, ele deve reunir certos requisitos essenciais preestabelecidos pelo constituinte originário. Consoante dispõe expressamente o artigo 14,§3º, da Constituição Federal, consistem em condições cumulativas de elegibilidade:'),
(20,'cc95-03','c80fe9be-da9c-4e28-b2a1-27a04be17bf7',100,95,'media','PAPIRO — DH-AUT-06 — cc95-03 — plebiscito referendo iniciativa popular',
 'A Constituição de 1988 consagrou a soberania popular, prevendo que será exercida pelo sufrágio universal e pelo voto direto e secreto, além de outros institutos de participação direta da cidadania. Sobre o plebiscito, o referendo e a iniciativa popular, é correto afirmar que:'),
(21,'cc95-04','c80fe9be-da9c-4e28-b2a1-27a04be17bf7',100,95,'facil','PAPIRO — DH-AUT-06 — cc95-04 — idades minimas outros cargos',
 'A Constituição Federal fixa idades mínimas distintas conforme o cargo eletivo pretendido. Considerando que um cidadão brasileiro planeje candidatar-se primeiro à Câmara dos Deputados e, futuramente, ao Senado Federal, ele deverá alcançar, como condição de elegibilidade, as idades mínimas respectivas de:'),
(22,'cc95-05','c80fe9be-da9c-4e28-b2a1-27a04be17bf7',100,95,'media','PAPIRO — DH-AUT-06 — cc95-05 — sufragio ativo x passivo',
 'O exercício da democracia representativa depende da correta compreensão das dimensões ativa e passiva do sufrágio. De acordo com o sistema de direitos políticos delineado na Constituição Federal, a correta e direta distinção entre as modalidades de sufrágio expressa-se na seguinte formulação:');

create temporary table _lote_explicacoes (ordem int primary key, explicacao text) on commit drop;
insert into _lote_explicacoes (ordem, explicacao) values
(1, E'A alternativa C está correta, pois reproduz a diretriz do art. 2º do Protocolo de Assunção (Decreto nº 7.225/2010), que preconiza a cooperação mútua entre as Partes para a promoção e a proteção efetiva dos direitos humanos por meio dos mecanismos institucionais estabelecidos no Mercosul. A alternativa A está incorreta, pois o Protocolo não prevê aplicação automática de sanções econômicas mediante mera denúncia. A alternativa B está incorreta, pois o Protocolo não institui um tribunal penal supranacional do Mercosul. A alternativa D está incorreta, pois o Protocolo não prevê suspensão imediata e irrevogável de obrigações comerciais como base de sua atuação cooperativa. A alternativa E está incorreta, pois a base do Protocolo é a cooperação mútua institucional, não a adoção de medidas unilaterais por um Estado Parte contra outro.'),
(2, E'A alternativa E está correta, pois, de acordo com o art. 3º do Protocolo de Assunção, o instrumento aplica-se quando se registrem graves e sistemáticas violações dos direitos humanos e das liberdades fundamentais em uma das Partes, em situações de crise institucional ou durante a vigência de estados de exceção previstos nos respectivos ordenamentos constitucionais — e, verificada essa hipótese, as demais Partes promoverão consultas entre si e com a Parte afetada, antes de adotarem medidas mais drásticas. Esse é o mecanismo primordial de solução institucional. A alternativa A está incorreta, pois o acionamento direto para bloqueio de fronteiras e intervenção militar não tem amparo normativo no Protocolo; a cláusula democrática stricto sensu remete ao Protocolo de Ushuaia, instrumento distinto. A alternativa B está incorreta, pois a expulsão imediata não é o mecanismo de acionamento inicial, desrespeitando a etapa de consultas. A alternativa C está incorreta, pois a Corte Interamericana de Direitos Humanos pertence ao Sistema Interamericano (OEA) e não atua como órgão de controle primário das consultas internas previstas no Protocolo de Assunção do Mercosul. A alternativa D está incorreta, pois a suspensão do direito de participar do processo de integração (medida do art. 4º) não é cautelar nem automática, tampouco antecede as consultas; somente pode ocorrer caso as consultas do art. 3º restem ineficazes.'),
(3, E'A alternativa A está correta. Nos termos do art. 4º do Protocolo de Assunção, quando as consultas se mostrarem ineficazes, as demais Partes considerarão a natureza e o alcance das medidas a aplicar, tendo em vista a gravidade da situação, medidas que abarcam desde a suspensão do direito de participar do processo de integração até a suspensão dos direitos e obrigações emergentes desse processo. A alternativa B está incorreta, pois o Protocolo não tem competência penal e não institui sanções penais contra chefes de Estado. A alternativa C está incorreta, pois o texto não prevê indenização automática ou instituição de fundo fiduciário de vítimas nessa fase. A alternativa D está incorreta, pois o Protocolo não prevê "expulsão definitiva", e sim medidas de suspensão temporária de direitos, obrigações e participação no processo de integração. A alternativa E está incorreta, pois não existe um "Tribunal de Justiça dos Direitos Humanos do Mercosul" instituído pelo Protocolo para assumir jurisdição compulsória.'),
(4, E'A alternativa D está correta, correspondendo ao art. 5º do Protocolo de Assunção, que dispõe que a adoção das medidas referidas no art. 4º far-se-á por consenso entre as Partes, cabendo destacar que a Parte afetada não participará do processo decisório, e que as medidas entrarão em vigor a partir do momento de sua comunicação formal à Parte afetada. A alternativa A está incorreta, pois o rito exige consenso, e não maioria absoluta, sendo expressamente excluída a participação da Parte afetada na votação. A alternativa B está incorreta, pois o procedimento é autônomo do Mercosul e não depende do envio à Corte Interamericana de Direitos Humanos. A alternativa C está incorreta, pois a Parte afetada não compõe o consenso decisório e não há necessidade de nova ratificação parlamentar para a vigência das medidas. A alternativa E está incorreta, pois a decisão não se dá por maioria simples, e a comunicação formal à Parte afetada é requisito essencial para o início da vigência da medida.'),
(5, E'A alternativa B está correta e reproduz a regra do art. 6º do Protocolo de Assunção: as medidas cessarão a partir da comunicação à Parte afetada de que as causas que motivaram as medidas foram sanadas, comunicação esta transmitida pelas Partes que adotaram as medidas. A alternativa A está incorreta, pois o mero reconhecimento unilateral da Parte afetada não é suficiente, por si só, para afastar as medidas — a constatação de que as causas foram sanadas e a respectiva comunicação cabem às Partes que as adotaram. A alternativa C está incorreta, pois o Protocolo não prevê prazo decadencial fixo (como 180 dias) para a vigência das medidas. A alternativa D está incorreta, pois a cessação decorre da comunicação, pelas Partes que adotaram as medidas, de que as causas foram sanadas — não exige nova decisão por consenso com participação da Parte afetada, que, aliás, nunca integra o processo decisório das medidas nem de sua cessação. A alternativa E está incorreta, pois a cessação das medidas é procedimento interno ao Mercosul e não depende de resolução de tribunal internacional.'),
(6, E'A alternativa A está correta. O Protocolo de Assunção foi aprovado internamente pelo Congresso Nacional por meio do Decreto Legislativo nº 592/2009 e, na sequência, promulgado pelo Presidente da República pelo Decreto Presidencial nº 7.225/2010. A alternativa B está incorreta, pois esses decretos (261/2015 e 9.522/2018) referem-se à internalização do Tratado de Marraqueche. A alternativa C está incorreta, pois refere-se à aprovação e promulgação da Convenção sobre os Direitos das Pessoas com Deficiência (CDPD). A alternativa D está incorreta, pois apresenta numerações fictícias ou não correspondentes ao Protocolo em questão. A alternativa E está incorreta ao misturar o Decreto Legislativo correto do Protocolo de Assunção (592/2009) com o Decreto de promulgação do Tratado de Marraqueche (9.522/2018).'),
(7, E'A alternativa B está correta. O STF, ao julgar o RE 466.343/SP, o RE 349.703 e o HC 87.585, sedimentou o entendimento de que os tratados de direitos humanos não aprovados pelo rito do art. 5º, §3º, da CF possuem status supralegal. Como o Pacto de San José proíbe a prisão civil por dívida (ressalvada a obrigação alimentar), sua supralegalidade tornou inaplicável a legislação infraconstitucional brasileira que previa a prisão do depositário infiel, paralisando sua eficácia. A Súmula Vinculante 25 pacificou a tese: "É ilícita a prisão civil de depositário infiel, qualquer que seja a modalidade do depósito". A alternativa A está incorreta, pois o tratado não revogou o texto constitucional, o qual ainda admite expressamente a prisão do devedor de alimentos. A alternativa C está incorreta, pois a Súmula Vinculante 25 é taxativa ao considerar ilícita a prisão em qualquer modalidade de depósito, sem exceções mercantis. A alternativa D está incorreta, pois a supralegalidade situa o tratado abaixo da Constituição, jamais revogando-a ou posicionando-se acima dela. A alternativa E está incorreta, visto que a tese proíbe a prisão independentemente da data do processo, dada a paralisação da eficácia da norma permissiva.'),
(8, E'A alternativa D está correta, pois identifica os tratados internacionais de direitos humanos que foram aprovados pelo Congresso Nacional em dois turnos, por três quintos dos votos dos membros de cada Casa: a Convenção sobre os Direitos das Pessoas com Deficiência (junto ao seu Protocolo Facultativo) e o Tratado de Marraqueche. A alternativa A está incorreta, pois o Pacto de San José ingressou antes da EC 45/2004 e a Carta da ONU não é tratado de direitos humanos aprovado por esse rito. As alternativas B, C e E estão incorretas, pois não apresentam os instrumentos que, na forma indicada na questão, foram efetivamente aprovados pelo procedimento do art. 5º, §3º.'),
(9, E'A alternativa C está correta, pois a literalidade do art. 5º, §3º, da Constituição Federal exige que a matéria do tratado seja, fundamentalmente, de direitos humanos para que, atendida a formalidade (dois turnos, três quintos dos votos em cada Casa), lhe seja atribuída a equivalência a emenda constitucional. Tratados de outra natureza, ainda que aprovados por esse mesmo quórum por conveniência política, não adquirem essa equivalência. A alternativa A está incorreta, pois o rito não confere status constitucional a qualquer tratado, exigindo-se que a matéria verse sobre direitos humanos. A alternativa B está incorreta pela mesma razão material; a promulgação não converte um acordo comercial em emenda constitucional. A alternativa D está incorreta, pois a supralegalidade é regra específica dos tratados de direitos humanos incorporados sem o rito especial, não se estendendo automaticamente a tratados de outra natureza. A alternativa E está incorreta, pois não há vedação de tramitação célere para acordos aduaneiros, nem atribuição automática de status de lei complementar a eles.'),
(10, E'A alternativa A está correta. Segundo o entendimento pacífico do STF (firmado no RE 466.343/SP e reiterado em julgados posteriores), tratados de direitos humanos não aprovados pelo rito qualificado do art. 5º,§3º (como ocorreu no caso hipotético de 2010) possuem status supralegal — situados hierarquicamente abaixo da Constituição, mas acima de qualquer legislação infraconstitucional, independentemente de a lei ser anterior ou posterior. Assim, a lei de 2018, no que contrariar o tratado, deixa de produzir efeitos nessa parte, por força dessa posição hierárquica intermediária. A alternativa B está incorreta, pois aplica a lógica de conflito de leis no tempo (lei ordinária revogando lei ordinária); tratados de direitos humanos não têm status de mera lei ordinária. A alternativa C está incorreta, pois o tratado não cumpriu o rito de aprovação qualificado (foi aprovado por maioria simples), logo não tem status constitucional. A alternativa D está incorreta, pois a teoria da supralegalidade confirma que o tratado permanece abaixo da Constituição Federal, jamais a revogando. A alternativa E está incorreta, uma vez que tratados internacionais de direitos humanos não aprovados pelo rito do art. 5º,§3º não são tratados pelo STF como simples leis ordinárias, possuindo status supralegal.'),
(11, E'A alternativa E está correta e reflete os artigos 84, VIII, e 49, I, da Constituição Federal: compete privativamente ao Presidente da República celebrar tratados, convenções e atos internacionais, sujeitos a referendo do Congresso Nacional; e compete exclusivamente ao Congresso Nacional resolver definitivamente sobre tratados, acordos ou atos internacionais que acarretem encargos ou compromissos gravosos ao patrimônio nacional. As alternativas A e C estão incorretas porque subvertem a ordem: o Congresso não celebra tratados, atribuição própria do Executivo. A alternativa B está incorreta porque quem resolve definitivamente é o Congresso Nacional, e o STF não possui função constitucional de promulgação de tratados. A alternativa D está incorreta porque o Congresso não publica decreto executivo final; o Congresso edita Decreto Legislativo, resolvendo definitivamente, mas a promulgação final (Decreto Presidencial) é feita pelo Presidente da República.'),
(12, E'A alternativa E está correta. Conforme estabelece o artigo 3º, "c", do Tratado de Marraqueche, também é beneficiária a pessoa que não pode, por deficiência física, segurar ou manipular um livro ou focar e mover os olhos apropriadamente para a leitura convencional. A alternativa A está incorreta, pois o Tratado foca em dificuldades perceptivas, visuais ou físicas atreladas ao ato da leitura, não incluindo, em sua redação explícita, a deficiência intelectual interpretativa. A alternativa B está incorreta, pois a deficiência auditiva, isoladamente, não integra as hipóteses do art. 3º. A alternativa C está incorreta, pois a deficiência física só se enquadra na hipótese da alínea "c" quando produzir a limitação relacionada ao manuseio do livro ou ao foco/movimento dos olhos — uma deficiência em membros inferiores não gera, por si só, essa limitação. A alternativa D está incorreta, pois o analfabetismo ou a barreira de idioma não se confundem com as deficiências tuteladas pelo Tratado de Marraqueche.'),
(13, E'A alternativa B está correta, pois reproduz os requisitos cumulativos do art. 4º,§2º, do Tratado de Marraqueche: a entidade autorizada deve ter acesso lícito à obra, não pode realizar alterações além das estritamente necessárias para a acessibilidade, e deve fornecer os exemplares, sem fins lucrativos, exclusivamente aos beneficiários do Tratado. A alternativa A está incorreta, pois o art. 4º,§2º não exige esse modelo de entidade com fins lucrativos e repasse obrigatório de royalties — o tema da eventual remuneração pelas limitações e exceções é deixado à disciplina da legislação nacional, nos termos do art. 4º,§5º, não ao formato descrito na alternativa. A alternativa C está incorreta, pois a exploração mercantil contraria a exigência de finalidade não lucrativa do art. 4º,§2º. A alternativa D está incorreta, pois o Tratado não exige alvará judicial prévio ou estúdio homologado pelo Estado como condição para a produção do exemplar acessível. A alternativa E está incorreta, pois o Tratado veda alterações que extrapolem o necessário para a acessibilidade, não autorizando modificação do enredo ou do conteúdo essencial da obra.'),
(14, E'A alternativa D está correta, reproduzindo a lógica do art. 5º,§1º, do Tratado de Marraqueche. O dispositivo assegura que, caso um exemplar em formato acessível seja elaborado com amparo em uma limitação autoral nacional, ele possa ser distribuído ou disponibilizado por uma entidade autorizada a outra entidade autorizada em outra Parte Contratante, ou diretamente a um beneficiário nessa outra Parte, nas condições do Tratado. A alternativa A está incorreta, pois o Tratado tem como um de seus propósitos centrais viabilizar esse intercâmbio entre países, não proibi-lo. A alternativa B está incorreta, pois o Tratado é de alcance universal, sem restrição a blocos geográficos ou continentais. A alternativa C está incorreta, pois o intercâmbio entre entidades autorizadas é expressamente previsto pelo art. 5º, ao lado da atuação direta do beneficiário, tratada no art. 6º. A alternativa E está incorreta, pois as regras de exceção já estão pactuadas no próprio Tratado, sem necessidade de licenciamento individual pela OMPI a cada transação.'),
(15, E'A alternativa A está correta, reproduzindo o disposto no art. 6º do Tratado de Marraqueche: se a legislação nacional permite a um beneficiário, a alguém atuando em seu nome, ou a uma entidade autorizada produzir um exemplar acessível, esse mesmo ordenamento deve também permitir a importação desse formato acessível do exterior, sem necessidade de autorização do titular dos direitos autorais. A alternativa B está incorreta, pois o art. 6º atribui o direito de importação também aos beneficiários e entidades autorizadas, não apenas ao Estado. A alternativa C está incorreta, pois o dispositivo não exige compensação financeira compulsória como requisito para a importação por beneficiários. A alternativa D está incorreta, pois a OMPI atua na gestão institucional do Tratado, não como agência expedidora de licenças de importação. A alternativa E está incorreta, pois o art. 6º não restringe a importação a entidades com fins comerciais, contemplando expressamente o beneficiário, alguém atuando em seu nome e a entidade autorizada como sujeitos habilitados a importar.'),
(16, E'A alternativa C está correta: o Tratado de Marraqueche, aprovado pelo procedimento do art. 5º,§3º por meio do Decreto Legislativo nº 261/2015, é equivalente às emendas constitucionais. A alternativa A está incorreta, pois o Decreto nº 9.522/2018 é o decreto presidencial de promulgação, ato distinto da aprovação legislativa. A alternativa B está incorreta, pois o Decreto Legislativo nº 186/2008 refere-se à aprovação da Convenção sobre os Direitos das Pessoas com Deficiência (CDPD), não do Tratado de Marraqueche. A alternativa D está incorreta, pois refere-se à promulgação do Protocolo de Assunção (Mercosul). A alternativa E está incorreta, pois a EC nº 45/2004 inseriu o §3º no art. 5º da CF, mas não é o ato legislativo específico de aprovação do Tratado de Marraqueche.'),
(17, E'A alternativa B está correta. O Decreto Presidencial nº 9.522/2018 é o ato normativo emitido pela Presidência da República que promulgou o Tratado de Marraqueche, tornando-o de cumprimento obrigatório no Brasil, após a aprovação pelo Congresso Nacional (Decreto Legislativo nº 261/2015). A alternativa A está incorreta, pois a Súmula Vinculante 25 versa sobre a prisão civil do depositário infiel e os reflexos do Pacto de San José da Costa Rica, tema estranho ao Tratado de Marraqueche. A alternativa C está incorreta, pois o Decreto Legislativo nº 186/2008 é o ato de aprovação da Convenção sobre os Direitos das Pessoas com Deficiência (CDPD), não do Tratado de Marraqueche. A alternativa D está incorreta, pois não cabe ao CNJ promulgar atos internacionais celebrados pelo Estado brasileiro. A alternativa E está incorreta, pois, no caso do Tratado de Marraqueche, o ato de promulgação foi o Decreto nº 9.522/2018 — uma portaria ministerial não corresponde ao ato indicado.'),
(18, E'A alternativa D está correta e reproduz a disciplina do art. 11,§2º, da Lei nº 9.504/1997, com a redação dada pela Lei nº 15.230/2025: a idade mínima exigida para candidatos a cargos do Poder Executivo deve estar implementada na data da posse; para candidatos às Câmaras Municipais, na data-limite fixada para o pedido de registro de candidatura. Para as demais Casas Legislativas, a lei considera a idade mínima implementada na data da posse presumida, esta considerada como ocorrida dentro do prazo de até 90 dias contado da eleição da respectiva Mesa Diretora, independentemente de norma regimental em sentido diverso, vedadas reduções ou prorrogações desse prazo. Em nenhuma dessas hipóteses a Lei nº 15.230/2025 alterou as idades mínimas fixadas no art. 14,§3º,VI, da Constituição Federal (35, 30, 21 ou 18 anos, conforme o cargo) — a novidade legislativa disciplina exclusivamente o momento em que essa idade deve estar atingida. A alternativa A está incorreta, pois ignora a distinção legal entre os marcos temporais aplicáveis a cada tipo de cargo. A alternativa B está incorreta, pois inverte os critérios: é para as Câmaras Municipais que se aplica a data-limite do pedido de registro, e para o Executivo, a data da posse. A alternativa C está incorreta, pois nem a diplomação nem a eleição da Mesa Diretora são, isoladamente, os marcos legais para essas duas hipóteses. A alternativa E está incorreta, pois a lei não unificou o critério; ao contrário, distinguiu-o conforme o cargo pretendido.'),
(19, E'A alternativa A está correta e reproduz os incisos I a VI do art. 14,§3º, da Constituição Federal: nacionalidade brasileira; pleno exercício dos direitos políticos; alistamento eleitoral; domicílio eleitoral na circunscrição; filiação partidária; e idade mínima. A alternativa B está incorreta, pois a Constituição não exige formação em ensino superior como condição de elegibilidade. A alternativa C está incorreta, pois o cumprimento do serviço militar não figura, isoladamente, entre as condições elencadas no §3º do art. 14. A alternativa D está incorreta, pois insere o casamento civil, requisito estranho ao rol constitucional das condições de elegibilidade. A alternativa E está incorreta, pois distorce três exigências do art. 14,§3º: o domicílio eleitoral deve ser na circunscrição pretendida, não há prazo mínimo de dez anos de filiação partidária, e a aferição da idade mínima segue disciplina própria da legislação eleitoral, não necessariamente a diplomação.'),
(20, E'A alternativa E está correta e reflete a disciplina do art. 14, CF, e dos arts. 13 e 14 da Lei nº 9.709/1998: o plebiscito é convocado com antecedência à edição do ato legislativo ou administrativo, permitindo aos cidadãos se manifestarem previamente; o referendo é convocado após a edição do ato, cabendo ao eleitorado ratificá-lo ou rejeitá-lo; e a iniciativa popular no âmbito federal, prevista no art. 61,§2º, da Constituição Federal, exige a apresentação de projeto de lei à Câmara dos Deputados subscrito por, no mínimo, 1% do eleitorado nacional, distribuído por pelo menos 5 Estados, com não menos de 0,3% dos eleitores de cada um deles. A alternativa A está incorreta, pois inverte a ordem cronológica de plebiscito e referendo e apresenta percentuais e número de Estados incompatíveis com o art. 61,§2º. A alternativa B está incorreta, pois nega a distinção temporal entre plebiscito e referendo e nega a exigência de subscrição mínima da iniciativa popular. A alternativa C está incorreta, pois restringe indevidamente a iniciativa popular a um único Estado, quando a Constituição exige distribuição por pelo menos 5 Estados, e inverte o momento do plebiscito, que é anterior, não sempre posterior, ao ato normativo. A alternativa D está incorreta, pois também inverte plebiscito e referendo e apresenta percentual (5%) e número de Estados (3) incompatíveis com a exigência constitucional (1% distribuído por 5 Estados).'),
(21, E'A alternativa C está correta. O art. 14,§3º,VI, da Constituição Federal fixa em trinta e cinco anos a idade mínima de elegibilidade para os cargos de Presidente da República, Vice-Presidente e Senador, e em vinte e um anos a idade mínima para os cargos de Deputado Federal, Deputado Estadual ou Distrital, Prefeito, Vice-Prefeito e Juiz de Paz. A alternativa A está incorreta, pois 30 anos é a idade exigida para Governador e Vice-Governador, não para Senador. A alternativa B está incorreta, pois a idade para Deputado Federal é de 21 anos, não 30. A alternativa D está incorreta porque inverte a relação entre os cargos e fixa idades incompatíveis com a Constituição. A alternativa E está incorreta, pois atribui indevidamente a idade de dezoito anos ao cargo de Deputado Federal, quando essa idade é exigida apenas para o cargo de Vereador.'),
(22, E'A alternativa B está correta. O direito político de alistar-se e exercer o voto configura a capacidade eleitoral ativa (sufrágio ativo); o preenchimento das condições que viabilizam uma candidatura e o consequente recebimento do voto dos concidadãos retrata a capacidade eleitoral passiva (sufrágio passivo/elegibilidade). A alternativa A está incorreta por inverter os conceitos: quem é votado é, na relação eleitoral, o objeto da escolha de terceiros, não o polo ativo (o eleitor). A alternativa C está incorreta, pois a divisão ativo/passivo não se vincula aos expedientes de consulta popular direta, mas sim aos verbos e polos da relação: votar (ativo) e ser votado (passivo) nos processos representativos em geral. A alternativa D está incorreta porque o sufrágio ativo (ir às urnas votar) não pressupõe filiação partidária; ao contrário, é o sufrágio passivo (ser votado) que, no Brasil, exige, dentre outras condições, a filiação partidária regular. A alternativa E está incorreta, pois as rubricas não dizem respeito à imperatividade do ato (voto obrigatório × voto facultativo), e sim às prerrogativas funcionais de eleger representantes versus figurar como candidato a ser escolhido.');

create temporary table _lote_alternativas (
  ordem int,
  ordem_alt smallint,
  texto text,
  correta boolean
) on commit drop;

insert into _lote_alternativas (ordem, ordem_alt, texto, correta) values
(1,1,'na aplicação automática de sanções econômicas severas a qualquer Estado Parte que sofra denúncia internacional de violação de direitos fundamentais.',false),
(1,2,'na criação imediata de um tribunal penal supranacional com jurisdição sobre os cidadãos de todos os países membros.',false),
(1,3,'na cooperação mútua entre as Partes, implementada por meio dos mecanismos institucionais estabelecidos no Mercosul.',true),
(1,4,'na suspensão imediata e irrevogável de todos os direitos e obrigações comerciais do Estado onde for relatada qualquer violação aos direitos humanos.',false),
(1,5,'na adoção de medidas unilaterais por um Estado Parte contra outro, independentemente de consultas prévias aos órgãos do bloco.',false),

(2,1,'o acionamento direto da cláusula democrática para o bloqueio de fronteiras e a intervenção militar conjunta.',false),
(2,2,'a determinação da expulsão imediata do Estado infrator dos quadros do bloco econômico.',false),
(2,3,'o ajuizamento de ação perante a Corte Interamericana de Direitos Humanos, na qualidade de órgão primário de controle do Mercosul.',false),
(2,4,'suspensão cautelar e automática do direito de participar do processo de integração, antes da conclusão das consultas.',false),
(2,5,'a promoção de consultas entre as Partes e o Estado Parte afetado, buscando regularizar a situação no âmbito da cooperação regional.',true),

(3,1,'suspensão do direito de participar do processo de integração, podendo alcançar, ainda, a suspensão dos direitos e obrigações emergentes desse processo.',true),
(3,2,'aplicação de sanções de natureza penal aos chefes de Estado envolvidos diretamente nas violações.',false),
(3,3,'condenação automática ao pagamento de indenizações pecuniárias diretas às vítimas, por meio de um fundo fiduciário do bloco.',false),
(3,4,'expulsão definitiva e irretratável do Estado Parte afetado do bloco econômico.',false),
(3,5,'transferência coercitiva de competência judicial para o Tribunal de Justiça dos Direitos Humanos do Mercosul, criado especificamente para esse fim.',false),

(4,1,'A decisão requer maioria absoluta, contabilizado obrigatoriamente o voto do Estado afetado para garantir o direito de defesa, entrando em vigor de imediato.',false),
(4,2,'A deliberação deve ser remetida à Corte Interamericana de Direitos Humanos, cuja sentença servirá como título executivo imediato para o bloco.',false),
(4,3,'A adoção ocorre por consenso de todas as Partes e da Parte afetada, mas as medidas só adquirem vigência após ratificação por todos os parlamentos nacionais.',false),
(4,4,'A adoção é feita por consenso das Partes, excluída a participação da Parte afetada, e as medidas entram em vigor a partir do momento de sua comunicação à Parte afetada.',true),
(4,5,'A aprovação das medidas se dá por maioria simples das Partes não afetadas, entrando em vigor imediatamente no ato da votação, sendo dispensada a comunicação formal à Parte afetada.',false),

(5,1,'automaticamente, no momento em que a Parte afetada emitir um decreto reconhecendo o retorno à normalidade democrática.',false),
(5,2,'a partir da comunicação à Parte afetada de que as causas que as motivaram foram sanadas, sendo tal comunicação transmitida pelas Partes que adotaram as medidas.',true),
(5,3,'mediante o decurso do prazo decadencial de cento e oitenta dias de sua aplicação, salvo renovação unânime.',false),
(5,4,'somente após nova decisão por consenso, com participação da Parte afetada, ainda que já tenha sido comunicado o saneamento das causas.',false),
(5,5,'por meio de uma resolução anulatória expedida por um tribunal internacional de direitos humanos com jurisdição contenciosa sobre o bloco.',false),

(6,1,'Decreto Legislativo nº 592/2009 e no Decreto nº 7.225/2010.',true),
(6,2,'Decreto Legislativo nº 261/2015 e no Decreto nº 9.522/2018.',false),
(6,3,'Decreto Legislativo nº 186/2008 e no Decreto nº 6.949/2009.',false),
(6,4,'Decreto Legislativo nº 10/2011 e no Decreto nº 19.859/2012.',false),
(6,5,'Decreto Legislativo nº 592/2009 e no Decreto nº 9.522/2018.',false),

(7,1,'Revogação de todo o texto constitucional que versava sobre prisão por dívida alimentar, equalizando a Constituição ao tratado internacional.',false),
(7,2,'Reconhecimento da ilicitude de qualquer prisão civil de depositário infiel, independentemente da modalidade de depósito, por paralisar a eficácia da legislação infraconstitucional que a previa.',true),
(7,3,'Restrição da prisão do depositário infiel apenas aos casos de depósito comercial, mantendo-se íntegra a prisão nas hipóteses de alienação fiduciária.',false),
(7,4,'Cancelamento das regras constitucionais, passando o Pacto de San José a ter força hierárquica superior à própria Constituição Federal.',false),
(7,5,'Autorização para que juízes de primeira instância aplicassem a prisão do depositário infiel somente nos processos iniciados antes de 1992, data da promulgação do Pacto no Brasil.',false),

(8,1,'o Pacto de San José da Costa Rica e a Carta das Nações Unidas.',false),
(8,2,'a Convenção contra a Tortura e o Estatuto de Roma do Tribunal Penal Internacional.',false),
(8,3,'o Protocolo de Assunção e a Convenção de Viena sobre o Direito dos Tratados.',false),
(8,4,'a Convenção sobre os Direitos das Pessoas com Deficiência (e seu Protocolo Facultativo) e o Tratado de Marraqueche.',true),
(8,5,'a Convenção sobre os Direitos da Criança e a Convenção para a Eliminação de Todas as Formas de Discriminação contra a Mulher (CEDAW).',false),

(9,1,'Sim, pois o rito de aprovação qualificado (dois turnos e quórum de três quintos) confere automaticamente status constitucional a qualquer tratado internacional.',false),
(9,2,'Sim, desde que o tratado, após a aprovação legislativa, seja imediatamente promulgado pelo Presidente da República, configurando o aceite internacional.',false),
(9,3,'Não, porque o reconhecimento com equivalência a emenda constitucional, decorrente desse quórum específico, destina-se exclusivamente aos tratados e convenções internacionais que versem sobre direitos humanos.',true),
(9,4,'Não, pois a jurisprudência estabelece que todos os tratados internacionais, independentemente do tema ou rito, possuem status supralegal no Brasil.',false),
(9,5,'Não, uma vez que tratados de cunho tarifário ou aduaneiro estão taxativamente proibidos de tramitar com preferência no Legislativo, restando sempre com status de lei complementar.',false),

(10,1,'infraconstitucional superveniente (lei de 2018) terá sua eficácia paralisada naquilo que conflitar com o tratado, pois este ostenta status supralegal, posicionando-se acima das leis e abaixo da Constituição.',true),
(10,2,'da lei federal ordinária (2018) prevalece na aplicação sobre o tratado de 2010, em estrita observância ao princípio lex posterior derogat legi priori, já que ambos ostentam status de lei ordinária.',false),
(10,3,'do tratado internacional, por possuir automaticamente status de emenda constitucional, autoriza a declaração imediata de inconstitucionalidade da lei de 2018 por violação direta ao art. 5º, §3º.',false),
(10,4,'do tratado de direitos humanos revoga as normas constitucionais conflitantes, de modo que a lei de 2018, ao espelhar uma Constituição desatualizada, será nula de pleno direito perante a Corte Interamericana.',false),
(10,5,'legislativa de 2018 e o tratado internacional de 2010 possuem exato mesmo patamar, devendo o juiz resolver o conflito exclusivamente pelo princípio da especialidade.',false),

(11,1,'compete privativamente ao Congresso Nacional celebrar os tratados internacionais, e ao Presidente da República emitir o decreto legislativo de ratificação interna.',false),
(11,2,'cabe ao Presidente da República a prerrogativa de resolver definitivamente sobre os atos internacionais, ao passo que o Supremo Tribunal Federal atua na fase de promulgação.',false),
(11,3,'o Congresso Nacional é o único responsável pela celebração e pela promulgação definitiva dos tratados internacionais, dispensando-se o envolvimento do Poder Executivo em todas as fases.',false),
(11,4,'a competência para a celebração do tratado é do Presidente da República, cabendo ao Congresso Nacional a mera publicação do decreto executivo final.',false),
(11,5,'compete privativamente ao Presidente da República celebrar tratados, convenções e atos internacionais, sujeitos a referendo do Congresso Nacional; e compete exclusivamente ao Congresso Nacional resolver definitivamente sobre tratados, acordos ou atos internacionais que acarretem encargos ou compromissos gravosos ao patrimônio nacional.',true),

(12,1,'comprove grave deficiência intelectual que a impeça de interpretar adequadamente obras científicas e literárias.',false),
(12,2,'sofra de deficiência auditiva limitante, inviabilizando a fruição autônoma de audiolivros musicais.',false),
(12,3,'possua qualquer espécie de deficiência física motora em membros inferiores, independentemente do impacto no ato da leitura.',false),
(12,4,'não tenha proficiência ou compreensão fluente no idioma nativo em que a obra escrita foi originalmente impressa.',false),
(12,5,'esteja, devido a uma deficiência física, incapacitada de segurar ou manipular um livro, ou de focar e mover os olhos na medida em que isso seria normalmente aceitável para a leitura.',true),

(13,1,'a entidade seja de cunho governamental com fins lucrativos e repasse, obrigatoriamente, parte dos royalties oriundos da venda direta aos autores.',false),
(13,2,'a entidade tenha acesso lícito à obra, não introduza alterações além das estritamente necessárias para torná-la acessível e, sem fins lucrativos, forneça o exemplar exclusivamente a beneficiários.',true),
(13,3,'a entidade promova aviso público da adaptação e comunique o autor em prazo razoável, sendo permitida a exploração mercantil se destinada a sustentar as despesas de conversão.',false),
(13,4,'a entidade obtenha prévia e expressa chancela mediante alvará judicial, e que o formato acessível seja confeccionado em estúdio homologado pelo Estado.',false),
(13,5,'a entidade possua liberdade criativa para modificar o enredo e o conteúdo essencial da obra, contanto que o material alterado seja distribuído aos beneficiários gratuitamente.',false),

(14,1,'tal prática é estritamente proibida, uma vez que o direito autoral impõe limites territoriais intransponíveis de mercado.',false),
(14,2,'é autorizada tão somente entre países que estejam situados no mesmo continente, evitando o repasse a blocos econômicos de línguas divergentes.',false),
(14,3,'o cruzamento de fronteiras com obras transcritas só pode ser realizado diretamente pelos próprios beneficiários, sendo vedado o trânsito por vias institucionais.',false),
(14,4,'a norma prevê que o exemplar confeccionado ao abrigo de uma limitação legal possa ser distribuído ou disponibilizado por uma entidade autorizada diretamente a um beneficiário ou a outra entidade autorizada localizada em outra Parte Contratante.',true),
(14,5,'toda e qualquer operação de permuta transfronteiriça depende, sob pena de nulidade, da emissão de licença prévia e individualizada pela Organização Mundial de Propriedade Intelectual (OMPI).',false),

(15,1,'O texto garante que, caso a legislação nacional permita a um beneficiário, a alguém atuando em seu nome, ou a uma entidade autorizada produzir exemplar acessível, deverá permitir também a importação desse exemplar em proveito dos beneficiários, sem necessidade de autorização do titular dos direitos.',true),
(15,2,'A prerrogativa de importação recai com exclusividade sobre o Estado-membro, sendo proibida a atuação alfandegária direta por parte das entidades autorizadas e dos beneficiários individuais.',false),
(15,3,'Os beneficiários pessoas físicas podem, de forma excepcional, realizar a importação, desde que recolham previamente um percentual compensatório (taxa) em prol do autor originário da obra.',false),
(15,4,'A internalização do exemplar importado só pode se perfectibilizar caso o importador detenha uma licença de uso provisória expedida e avalizada pela OMPI.',false),
(15,5,'Apenas entidades constituídas com fins eminentemente comerciais podem promover a importação em escala das obras adaptadas.',false),

(16,1,'Decreto nº 9.522/2018.',false),
(16,2,'Decreto Legislativo nº 186/2008.',false),
(16,3,'Decreto Legislativo nº 261/2015.',true),
(16,4,'Decreto nº 7.225/2010.',false),
(16,5,'Emenda Constitucional nº 45/2004.',false),

(17,1,'entendimento exarado pela Súmula Vinculante 25, dotado de eficácia erga omnes.',false),
(17,2,'Decreto Presidencial nº 9.522/2018.',true),
(17,3,'Decreto Legislativo nº 186/2008, que chancelou a redação complementar.',false),
(17,4,'normativo derivado por Resolução do Conselho Nacional de Justiça.',false),
(17,5,'ato administrativo direto por meio de Portaria do Ministério dos Direitos Humanos.',false),

(18,1,'ambos devem completar a idade mínima na data do primeiro turno das eleições, sem qualquer distinção entre os cargos.',false),
(18,2,'candidatos ao Poder Executivo devem completá-la na data-limite para o pedido de registro de candidatura, e candidatos às Câmaras Municipais, na data da posse.',false),
(18,3,'candidatos ao Poder Executivo devem completá-la na data da diplomação, e candidatos às Câmaras Municipais, na data da eleição da Mesa Diretora.',false),
(18,4,'candidatos ao Poder Executivo devem completá-la na data da posse, e candidatos às Câmaras Municipais, na data-limite para o pedido de registro de candidatura.',true),
(18,5,'a Lei nº 15.230/2025 unificou o momento de aferição em todos os casos para a data da posse, inclusive para candidatos às Câmaras Municipais.',false),

(19,1,'a nacionalidade brasileira, o pleno exercício dos direitos políticos, o alistamento eleitoral, o domicílio eleitoral na circunscrição, a filiação partidária e a idade mínima constitucionalmente prevista.',true),
(19,2,'a nacionalidade brasileira, a comprovação de conclusão do ensino superior completo, o alistamento eleitoral e a submissão prévia à filiação partidária por mais de dois anos.',false),
(19,3,'o pleno exercício dos direitos políticos, o comprovado cumprimento do serviço militar obrigatório, a filiação partidária e o domicílio eleitoral na respectiva circunscrição do pleito.',false),
(19,4,'o alistamento eleitoral, a capacidade civil decorrente do casamento, a nacionalidade brasileira e o engajamento partidário atestado pelo estatuto siglar.',false),
(19,5,'o domicílio eleitoral em qualquer circunscrição do território nacional, independentemente do cargo pretendido, a filiação partidária exercida por prazo superior a dez anos e a idade mínima aferida na data da diplomação.',false),

(20,1,'o referendo antecede o ato legislativo, o plebiscito o sucede, e a iniciativa popular federal exige subscrição de 2% do eleitorado nacional, distribuído por pelo menos 10 Estados.',false),
(20,2,'o plebiscito e o referendo são convocados sempre no mesmo momento processual, distinguindo-se apenas pelo quórum de aprovação no Congresso Nacional, e a iniciativa popular dispensa qualquer subscrição mínima de eleitores.',false),
(20,3,'a iniciativa popular federal exige subscrição de 1% do eleitorado de um único Estado-membro, dispensada a distribuição nacional, ao passo que o plebiscito é sempre posterior ao ato legislativo.',false),
(20,4,'o plebiscito é convocado após a edição do ato normativo, ao passo que o referendo antecede sua elaboração, sendo a iniciativa popular federal exercida mediante subscrição de 5% do eleitorado nacional, distribuído em pelo menos 3 Estados.',false),
(20,5,'o plebiscito antecede o ato legislativo ou administrativo, o referendo é convocado após sua edição, e a iniciativa popular federal exige projeto de lei subscrito por, no mínimo, 1% do eleitorado nacional, distribuído por pelo menos 5 Estados, com não menos de 0,3% dos eleitores de cada um deles.',true),

(21,1,'trinta anos de idade para concorrer a Senador e vinte e um anos de idade para Deputado Federal.',false),
(21,2,'trinta e cinco anos de idade para concorrer a Senador e trinta anos de idade para Deputado Federal.',false),
(21,3,'trinta e cinco anos de idade para concorrer a Senador e vinte e um anos de idade para Deputado Federal.',true),
(21,4,'vinte e um anos de idade para concorrer a Senador e dezoito anos de idade para Deputado Federal.',false),
(21,5,'trinta e cinco anos de idade para concorrer a Senador e dezoito anos de idade para Deputado Federal.',false),

(22,1,'O sufrágio ativo consiste no direito inalienável do cidadão de ser votado nos pleitos representativos; o passivo consiste na aptidão e obrigação de exercer o voto.',false),
(22,2,'O sufrágio ativo corresponde à capacidade eleitoral do cidadão de votar; o sufrágio passivo representa a capacidade eleitoral de ser votado (elegibilidade).',true),
(22,3,'O sufrágio ativo é aquele cujos efeitos recaem exclusivamente sobre processos de aprovação de plebiscitos; o sufrágio passivo circunscreve-se à participação nas consultas de referendo.',false),
(22,4,'O sufrágio ativo pressupõe como condição incontornável a prévia filiação partidária ativa do cidadão; já o sufrágio passivo demanda apenas o regular alistamento em zona eleitoral competente.',false),
(22,5,'O sufrágio ativo diz respeito às situações nas quais a Constituição impõe a modalidade de voto obrigatório e incontornável; já o passivo engloba o campo do voto facultativo aos idosos e analfabetos.',false);

-- Precondicoes.
do $$
declare
  v_cnt int;
  v_dup int;
begin
  select count(*) into v_cnt from _lote_questoes;
  if v_cnt <> 22 then
    raise exception 'Precondicao falhou: staging tem % questoes (esperado 22)', v_cnt;
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

  if (select count(*) from _lote_questoes where cc_id=92) <> 6 then raise exception 'Precondicao falhou: staging cc92 <> 6'; end if;
  if (select count(*) from _lote_questoes where cc_id=93) <> 5 then raise exception 'Precondicao falhou: staging cc93 <> 5'; end if;
  if (select count(*) from _lote_questoes where cc_id=94) <> 6 then raise exception 'Precondicao falhou: staging cc94 <> 6'; end if;
  if (select count(*) from _lote_questoes where cc_id=95) <> 5 then raise exception 'Precondicao falhou: staging cc95 <> 5'; end if;

  if (select cc92_uteis from _snapshot_antes) <> 4 then raise exception 'Precondicao falhou: cc92_uteis=% (esperado 4)', (select cc92_uteis from _snapshot_antes); end if;
  if (select cc93_uteis from _snapshot_antes) <> 5 then raise exception 'Precondicao falhou: cc93_uteis=% (esperado 5)', (select cc93_uteis from _snapshot_antes); end if;
  if (select cc94_uteis from _snapshot_antes) <> 4 then raise exception 'Precondicao falhou: cc94_uteis=% (esperado 4)', (select cc94_uteis from _snapshot_antes); end if;
  if (select cc95_uteis from _snapshot_antes) <> 5 then raise exception 'Precondicao falhou: cc95_uteis=% (esperado 5)', (select cc95_uteis from _snapshot_antes); end if;

  if (select q180_hash from _snapshot_antes) <> 'c189e7cb437586cc94cae1de61903cae' then
    raise exception 'Precondicao falhou: Q180 explicacao divergiu do estado saneado esperado (manutencao anterior)';
  end if;
  if (select q181_hash from _snapshot_antes) <> '950ddb18cfb2857907c09b7297751cf8' then
    raise exception 'Precondicao falhou: Q181 explicacao divergiu do estado saneado esperado (manutencao anterior)';
  end if;
  if (select q182_hash from _snapshot_antes) <> 'a6033d457b0f9e24528ba2245d3fdb38' then
    raise exception 'Precondicao falhou: Q182 explicacao divergiu do estado saneado esperado (manutencao anterior)';
  end if;
  if (select q189_hash from _snapshot_antes) <> '214e0ec3a8ee94a22e39e16abd5398c5' then
    raise exception 'Precondicao falhou: Q189 explicacao divergiu do estado saneado esperado (manutencao anterior)';
  end if;
  if (select q190_hash from _snapshot_antes) <> '5f0a106956022042a6a212904b4ff65b' then
    raise exception 'Precondicao falhou: Q190 explicacao divergiu do estado saneado esperado (manutencao anterior)';
  end if;
  if (select q191_hash from _snapshot_antes) <> '06d4e174f2db3310fec46b97c14e69d6' then
    raise exception 'Precondicao falhou: Q191 explicacao divergiu do estado saneado esperado (manutencao anterior)';
  end if;
end $$;

-- Insercao das questoes + alternativas.
create temporary table _mapa_ids (ordem int primary key, questao_id bigint) on commit drop;

do $$
declare r record; v_id bigint;
begin
  for r in select * from _lote_questoes order by ordem loop
    insert into public.questoes (materia_id, assunto_id, banca, concurso, ano, enunciado, dificuldade, explicacao, fonte, ativa, gerada_por_ia)
    values (11, r.assunto_id, 'Papiro', 'PAPIRO - Curadoria DH-AUT-06 - BM RS', 2026, r.enunciado, r.dificuldade,
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
  v_cc92_uteis int; v_cc93_uteis int; v_cc94_uteis int; v_cc95_uteis int;
  v_cc92_real int; v_cc93_real int; v_cc94_real int; v_cc95_real int;
  v_dh_uteis_depois int;
  v_q180_hash text; v_q181_hash text; v_q182_hash text;
  v_q189_hash text; v_q190_hash text; v_q191_hash text;
begin
  select count(*) into v_novas_questoes from public.questoes where id in (select questao_id from _mapa_ids);
  if v_novas_questoes <> 22 then
    raise exception 'Pos-condicao falhou: questoes novas=% (esperado 22)', v_novas_questoes;
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
  if v_novas_alternativas <> 110 then
    raise exception 'Pos-condicao falhou: alternativas novas=% (esperado 110 = 22x5)', v_novas_alternativas;
  end if;

  select count(*) into v_corretas_invalidas
  from (select questao_id, count(*) filter (where correta) as n from public.alternativas where questao_id in (select questao_id from _mapa_ids) group by questao_id having count(*) filter (where correta) <> 1) x;
  if v_corretas_invalidas <> 0 then
    raise exception 'Pos-condicao falhou: % questao(oes) sem exatamente 1 alternativa correta', v_corretas_invalidas;
  end if;

  select count(*) into v_facil from public.questoes where id in (select questao_id from _mapa_ids) and dificuldade='facil';
  select count(*) into v_media from public.questoes where id in (select questao_id from _mapa_ids) and dificuldade='media';
  select count(*) into v_dificil from public.questoes where id in (select questao_id from _mapa_ids) and dificuldade='dificil';
  if v_facil <> 5 or v_media <> 13 or v_dificil <> 4 then
    raise exception 'Pos-condicao falhou: distribuicao dificuldade facil=%/media=%/dificil=% (esperado 5/13/4)', v_facil, v_media, v_dificil;
  end if;

  select count(*) into v_A from public.alternativas a join _mapa_ids m on a.questao_id=m.questao_id where a.correta and a.ordem=1;
  select count(*) into v_B from public.alternativas a join _mapa_ids m on a.questao_id=m.questao_id where a.correta and a.ordem=2;
  select count(*) into v_C from public.alternativas a join _mapa_ids m on a.questao_id=m.questao_id where a.correta and a.ordem=3;
  select count(*) into v_D from public.alternativas a join _mapa_ids m on a.questao_id=m.questao_id where a.correta and a.ordem=4;
  select count(*) into v_E from public.alternativas a join _mapa_ids m on a.questao_id=m.questao_id where a.correta and a.ordem=5;
  if v_A <> 5 or v_B <> 5 or v_C <> 4 or v_D <> 4 or v_E <> 4 then
    raise exception 'Pos-condicao falhou: gabaritos A=%/B=%/C=%/D=%/E=% (esperado 5/5/4/4/4)', v_A, v_B, v_C, v_D, v_E;
  end if;

  select count(*) into v_novos_vinculos from public.questao_unidades_pedagogicas where questao_id in (select questao_id from _mapa_ids);
  if v_novos_vinculos <> 22 then
    raise exception 'Pos-condicao falhou: vinculos novos=% (esperado 22)', v_novos_vinculos;
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

  select count(distinct qup.questao_id) into v_cc92_uteis from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id where up.curso_conteudo_id=92;
  select count(distinct qup.questao_id) into v_cc93_uteis from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id where up.curso_conteudo_id=93;
  select count(distinct qup.questao_id) into v_cc94_uteis from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id where up.curso_conteudo_id=94;
  select count(distinct qup.questao_id) into v_cc95_uteis from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id where up.curso_conteudo_id=95;

  if v_cc92_uteis <> (select cc92_uteis from _snapshot_antes) + 6 then raise exception 'Pos-condicao falhou: cc92_uteis=% (esperado %)', v_cc92_uteis, (select cc92_uteis from _snapshot_antes)+6; end if;
  if v_cc93_uteis <> (select cc93_uteis from _snapshot_antes) + 5 then raise exception 'Pos-condicao falhou: cc93_uteis=% (esperado %)', v_cc93_uteis, (select cc93_uteis from _snapshot_antes)+5; end if;
  if v_cc94_uteis <> (select cc94_uteis from _snapshot_antes) + 6 then raise exception 'Pos-condicao falhou: cc94_uteis=% (esperado %)', v_cc94_uteis, (select cc94_uteis from _snapshot_antes)+6; end if;
  if v_cc95_uteis <> (select cc95_uteis from _snapshot_antes) + 5 then raise exception 'Pos-condicao falhou: cc95_uteis=% (esperado %)', v_cc95_uteis, (select cc95_uteis from _snapshot_antes)+5; end if;

  if v_cc92_uteis <> 10 or v_cc93_uteis <> 10 or v_cc94_uteis <> 10 or v_cc95_uteis <> 10 then
    raise exception 'Pos-condicao falhou: alguma unidade nao atingiu exatamente 10 uteis (cc92=%,cc93=%,cc94=%,cc95=%)', v_cc92_uteis, v_cc93_uteis, v_cc94_uteis, v_cc95_uteis;
  end if;

  select count(distinct qup.questao_id) into v_cc92_real from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id join public.questoes q on q.id=qup.questao_id where up.curso_conteudo_id=92 and coalesce(lower(q.banca),'') not like '%papiro%';
  select count(distinct qup.questao_id) into v_cc93_real from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id join public.questoes q on q.id=qup.questao_id where up.curso_conteudo_id=93 and coalesce(lower(q.banca),'') not like '%papiro%';
  select count(distinct qup.questao_id) into v_cc94_real from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id join public.questoes q on q.id=qup.questao_id where up.curso_conteudo_id=94 and coalesce(lower(q.banca),'') not like '%papiro%';
  select count(distinct qup.questao_id) into v_cc95_real from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id join public.questoes q on q.id=qup.questao_id where up.curso_conteudo_id=95 and coalesce(lower(q.banca),'') not like '%papiro%';

  if v_cc92_real <> (select cc92_real from _snapshot_antes) or v_cc93_real <> (select cc93_real from _snapshot_antes)
     or v_cc94_real <> (select cc94_real from _snapshot_antes) or v_cc95_real <> (select cc95_real from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: contagem REAL de alguma unidade mudou indevidamente (deveria permanecer inalterada, pois este lote e 100%% autoral)';
  end if;

  select count(distinct qup.questao_id) into v_dh_uteis_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.curso_conteudos cc on cc.id = up.curso_conteudo_id
    join public.assuntos a on a.id = cc.assunto_id
    where a.materia_id = 11;
  if v_dh_uteis_depois <> (select dh_uteis from _snapshot_antes) + 22 then
    raise exception 'Pos-condicao falhou: dh_uteis=% (esperado %)', v_dh_uteis_depois, (select dh_uteis from _snapshot_antes) + 22;
  end if;

  select md5(coalesce(explicacao,'')) into v_q180_hash from public.questoes where id = 180;
  select md5(coalesce(explicacao,'')) into v_q181_hash from public.questoes where id = 181;
  select md5(coalesce(explicacao,'')) into v_q182_hash from public.questoes where id = 182;
  select md5(coalesce(explicacao,'')) into v_q189_hash from public.questoes where id = 189;
  select md5(coalesce(explicacao,'')) into v_q190_hash from public.questoes where id = 190;
  select md5(coalesce(explicacao,'')) into v_q191_hash from public.questoes where id = 191;
  if v_q180_hash <> (select q180_hash from _snapshot_antes) then raise exception 'Pos-condicao falhou: Q180 explicacao foi alterada indevidamente por este lote'; end if;
  if v_q181_hash <> (select q181_hash from _snapshot_antes) then raise exception 'Pos-condicao falhou: Q181 explicacao foi alterada indevidamente por este lote'; end if;
  if v_q182_hash <> (select q182_hash from _snapshot_antes) then raise exception 'Pos-condicao falhou: Q182 explicacao foi alterada indevidamente por este lote'; end if;
  if v_q189_hash <> (select q189_hash from _snapshot_antes) then raise exception 'Pos-condicao falhou: Q189 explicacao foi alterada indevidamente por este lote'; end if;
  if v_q190_hash <> (select q190_hash from _snapshot_antes) then raise exception 'Pos-condicao falhou: Q190 explicacao foi alterada indevidamente por este lote'; end if;
  if v_q191_hash <> (select q191_hash from _snapshot_antes) then raise exception 'Pos-condicao falhou: Q191 explicacao foi alterada indevidamente por este lote'; end if;

  if (select count(*) from public.questoes) <> (select total_questoes from _snapshot_antes) + 22 then
    raise exception 'Pos-condicao falhou: total de questoes nao cresceu exatamente 22';
  end if;
  if (select count(*) from public.alternativas) <> (select total_alternativas from _snapshot_antes) + 110 then
    raise exception 'Pos-condicao falhou: total de alternativas nao cresceu exatamente 110';
  end if;
  if (select count(*) from public.questao_unidades_pedagogicas) <> (select total_vinculos from _snapshot_antes) + 22 then
    raise exception 'Pos-condicao falhou: total de vinculos nao cresceu exatamente 22';
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

  raise notice 'Pos-condicoes OK: 22 questoes AUTORAL_PAPIRO novas / 110 alternativas / 22 vinculos / facil=% media=% dificil=% / gabaritos A=%,B=%,C=%,D=%,E=% / cc92..cc95 todas em 10 uteis / DH uteis %->%.',
    v_facil, v_media, v_dificil, v_A, v_B, v_C, v_D, v_E,
    (select dh_uteis from _snapshot_antes), v_dh_uteis_depois;
end $$;

commit;
