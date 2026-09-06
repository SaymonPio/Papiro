-- Aplicacao AUTORAL do Lote DH-AUT-03 de Direitos Humanos e Cidadania — 22
-- questoes novas AUTORAL_PAPIRO + 110 alternativas + 22 vinculos, validado
-- pelo harness supabase/importar_dh_aut_03_teste_rollback.sql (tudo_ok =
-- true precisa ser confirmado antes de rodar este arquivo).
--
-- Fecha o deficit_para_10 de 4 unidades de Direitos Humanos e Cidadania
-- (cc82 Sistema Internacional de Protecao dos DH, cc83 Declaracao
-- Universal dos Direitos Humanos, cc84 Pactos Internacionais de Direitos
-- Humanos, cc85 Sistema Interamericano de Direitos Humanos), levando
-- cada uma a exatamente 10 uteis:
--   cc82: 4->10 (6 novas) | cc83: 6->10 (4 novas) | cc84: 3->10 (7 novas)
--   cc85: 5->10 (5 novas)
--
-- Origem: AUTORAL_PAPIRO em todas as 22 (banca='Papiro') — nunca REAL.
-- Conteudo integralmente auditado nesta sessao (DH-AUT-03 — auditoria
-- independente Claude + microauditoria final), com verificacao direta
-- da legislacao oficial vigente: Declaracao Universal dos Direitos
-- Humanos - DUDH (arts. 4, 5, 7, 18 — texto oficial ONU/OHCHR) e
-- Convencao Americana sobre Direitos Humanos - CADH / Pacto de San Jose
-- da Costa Rica (Decreto no 678/1992 — arts. 33, 44, 45, 46, 47, 61, 62,
-- 64, texto oficial planalto.gov.br), alem de verificacao historica
-- (Comissao Interamericana criada em 1959, antes da propria CADH de
-- 1969) que motivou a correcao critica de cc85-05.
--
-- Mecanismo de identificacao/idempotencia: cada uma das 22 e identificada
-- de forma inequivoca pelo texto EXATO do proprio enunciado. Se este
-- arquivo for executado uma segunda vez, a precondicao de "enunciado
-- identico" abortara a transacao inteira antes de qualquer insercao. O
-- rollback seguro pos-apply (se necessario no futuro) esta em
-- supabase/reverter_dh_aut_03.sql, que localiza e remove exclusivamente
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
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 82) as cc82_uteis,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.questoes q on q.id = qup.questao_id where up.curso_conteudo_id = 82 and coalesce(lower(q.banca),'') not like '%papiro%') as cc82_real,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 83) as cc83_uteis,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.questoes q on q.id = qup.questao_id where up.curso_conteudo_id = 83 and coalesce(lower(q.banca),'') not like '%papiro%') as cc83_real,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 84) as cc84_uteis,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.questoes q on q.id = qup.questao_id where up.curso_conteudo_id = 84 and coalesce(lower(q.banca),'') not like '%papiro%') as cc84_real,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 85) as cc85_uteis,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.questoes q on q.id = qup.questao_id where up.curso_conteudo_id = 85 and coalesce(lower(q.banca),'') not like '%papiro%') as cc85_real,
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
(1,'cc82-01','522f7c40-b95e-4c91-b0d6-cf4a6f012c16',83,82,'facil','PAPIRO — DH-AUT-03 — cc82-01 — Sistemas regionais x universal',
 'A proteção internacional dos direitos humanos desenvolveu-se por meio de diferentes instâncias para conferir maior efetividade aos compromissos assumidos pelos Estados. Dentre essas instâncias, operam sistemas com abrangência global e outros com escopo regional. Assinale a alternativa que indica corretamente três dos principais sistemas regionais consolidados, distinguindo-os do sistema universal gerido pela Organização das Nações Unidas (ONU).'),
(2,'cc82-02','522f7c40-b95e-4c91-b0d6-cf4a6f012c16',83,82,'media','PAPIRO — DH-AUT-03 — cc82-02 — DUDH marco central do sistema universal',
 'O processo de internacionalização dos direitos humanos ganhou força normativa e institucional no período pós-Segunda Guerra Mundial. No que se refere à organização arquitetônica desse complexo de proteção, o papel desempenhado pela Declaração Universal dos Direitos Humanos (DUDH) de 1948 consiste em:'),
(3,'cc82-03','522f7c40-b95e-4c91-b0d6-cf4a6f012c16',83,82,'dificil','PAPIRO — DH-AUT-03 — cc82-03 — Complementaridade aplicada a caso concreto',
 'Um cidadão do Estado "Alfa" teve um de seus direitos fundamentais violado por agentes públicos. Insatisfeito com a resposta obtida nas vias internas de seu país, decidiu acionar um órgão de proteção do sistema regional do qual seu Estado é signatário. Ao fazê-lo, argumentou que o direito internacional deveria substituir a justiça local na apreciação do caso. Considerando a relação estrutural entre os sistemas nacional, regional e universal de proteção dos direitos humanos, a perspectiva desse cidadão está:'),
(4,'cc82-04','522f7c40-b95e-4c91-b0d6-cf4a6f012c16',83,82,'facil','PAPIRO — DH-AUT-03 — cc82-04 — PIDCP/PIDESC no sistema universal',
 'O arranjo institucional de proteção aos direitos humanos conta com importantes diplomas normativos de diferentes escopos e vinculações territoriais. Ao se estudar a estrutura global desse arcabouço, observa-se que o Pacto Internacional sobre Direitos Civis e Políticos (PIDCP) e o Pacto Internacional sobre Direitos Econômicos, Sociais e Culturais (PIDESC) são instrumentos que:'),
(5,'cc82-05','522f7c40-b95e-4c91-b0d6-cf4a6f012c16',83,82,'media','PAPIRO — DH-AUT-03 — cc82-05 — Proteção nacional x internacional complementar',
 'O desenvolvimento do Direito Internacional dos Direitos Humanos promoveu a consolidação de mecanismos de proteção que ultrapassam as fronteiras estatais, permitindo que a comunidade internacional averigue violações cometidas internamente. Com base na interação orgânica entre os planos nacional e internacional, assinale a alternativa correta.'),
(6,'cc82-06','522f7c40-b95e-4c91-b0d6-cf4a6f012c16',83,82,'media','PAPIRO — DH-AUT-03 — cc82-06 — Assertivas ONU/DUDH/complementaridade',
 E'Considere as afirmativas a seguir a respeito da arquitetura estrutural do Sistema Internacional de Proteção dos Direitos Humanos:\n\nI. O sistema universal de proteção desenvolveu-se precipuamente no âmbito da Organização das Nações Unidas (ONU).\nII. A Declaração Universal dos Direitos Humanos (DUDH) desponta como o documento paradigmático que consolidou a gênese material desse sistema universal.\nIII. O sistema universal estabelece uma relação de hierarquia revogatória e substitutiva sobre as jurisdições nacionais, operando originariamente independentemente da atuação do Estado.\n\nEstá correto o que se afirma em:'),
(7,'cc83-01','e7bef052-b882-4a2f-b1e6-88ce12740c26',88,83,'facil','PAPIRO — DH-AUT-03 — cc83-01 — DUDH art.4',
 'A Declaração Universal dos Direitos Humanos (DUDH) de 1948 garante valores fundamentais para a consolidação da dignidade humana no ordenamento internacional. Dentre as disposições materiais relativas à liberdade do ser humano, destaca-se a regra do artigo 4º, que consagra de forma absoluta:'),
(8,'cc83-02','e7bef052-b882-4a2f-b1e6-88ce12740c26',88,83,'media','PAPIRO — DH-AUT-03 — cc83-02 — DUDH art.7',
 'O princípio da igualdade constitui um dos pilares da Declaração Universal dos Direitos Humanos (DUDH). Ao estruturar o direito a não discriminação, a redação do artigo 7º do diploma não se limita a afirmar a igualdade formal de todos perante a lei, estendendo suas garantias. Assinale a alternativa que reflete corretamente o arcabouço desse dispositivo.'),
(9,'cc83-03','e7bef052-b882-4a2f-b1e6-88ce12740c26',88,83,'dificil','PAPIRO — DH-AUT-03 — cc83-03 — DUDH art.18',
 'Um cidadão decide renunciar à sua religião originária e passa a integrar uma nova comunidade de fé. Ao tentar realizar ritos abertos em uma praça com outros membros e ministrar ensinamentos aos recém-chegados, o Estado intervém. Por lei local, é permitido ter religião e cultuá-la apenas dentro de casa (modo privado), sendo expressamente proibido mudar a crença de nascimento e manifestá-la publicamente. À luz, estritamente, do artigo 18 da Declaração Universal dos Direitos Humanos (DUDH), a conduta do Estado:'),
(10,'cc83-04','e7bef052-b882-4a2f-b1e6-88ce12740c26',88,83,'media','PAPIRO — DH-AUT-03 — cc83-04 — DUDH art.5',
 'O Direito Internacional dos Direitos Humanos assenta-se na tutela da integridade e da dignidade física e moral do indivíduo. Refletindo essa diretriz, a Declaração Universal dos Direitos Humanos (DUDH) de 1948, em seu artigo 5º, proclama a regra de que:'),
(11,'cc84-01','7cfd81f6-49ab-4a15-b643-9a8a7b026deb',82,84,'dificil','PAPIRO — DH-AUT-03 — cc84-01 — DUDH declaracao x Pactos tratados',
 'A compreensão da normatividade no Direito Internacional dos Direitos Humanos perpassa pela análise da natureza jurídica dos instrumentos formulados no seio da ONU. Ao analisar a força vinculante e a estrutura formal dos documentos que compõem a International Bill of Human Rights (Carta Internacional dos Direitos Humanos), conclui-se que há uma distinção basilar entre a Declaração Universal de 1948 (DUDH) e os Pactos de 1966. Essa distinção reside no fato de que:'),
(12,'cc84-02','7cfd81f6-49ab-4a15-b643-9a8a7b026deb',82,84,'media','PAPIRO — DH-AUT-03 — cc84-02 — Pactos desenvolvem direitos da DUDH',
 'Os Pactos Internacionais de 1966 não foram idealizados em um vazio histórico; eles mantêm uma correlação umbilical com os valores universais sedimentados logo após a Segunda Guerra Mundial. Assinale a alternativa que descreve de forma fidedigna a relação normativa e histórica entre esses Pactos e a Declaração Universal dos Direitos Humanos (DUDH) de 1948.'),
(13,'cc84-03','7cfd81f6-49ab-4a15-b643-9a8a7b026deb',82,84,'dificil','PAPIRO — DH-AUT-03 — cc84-03 — DUDH e costume internacional',
 'Em discussões de alto nível no âmbito da diplomacia e do Direito Internacional, frequentemente surge o debate sobre a exigibilidade jurídica das normas de direitos humanos constantes da Declaração Universal dos Direitos Humanos (DUDH) contra Estados que não são partes de nenhum tratado sobre a matéria. Levando-se em conta a formação do direito das gentes e a natureza peculiar da referida Declaração aprovada em 1948, é juridicamente correto afirmar que:'),
(14,'cc84-04','7cfd81f6-49ab-4a15-b643-9a8a7b026deb',82,84,'media','PAPIRO — DH-AUT-03 — cc84-04 — Estado Parte ratificante caso concreto',
 'O Estado soberano "Beta" é membro histórico da Organização das Nações Unidas desde a proclamação da Declaração Universal dos Direitos Humanos (DUDH) de 1948. Mais recentemente, passou pelos trâmites internos e depositou formalmente a ratificação, tornando-se Estado Parte do Pacto Internacional sobre Direitos Civis e Políticos (PIDCP) e do Pacto Internacional sobre Direitos Econômicos, Sociais e Culturais (PIDESC). No tocante às responsabilidades internacionais que pesam sobre o Estado "Beta" no sistema universal, analise a diferença de densidade jurídica entre a DUDH e os Pactos e assinale a opção correta.'),
(15,'cc84-05','7cfd81f6-49ab-4a15-b643-9a8a7b026deb',82,84,'facil','PAPIRO — DH-AUT-03 — cc84-05 — Nomes PIDCP/PIDESC associação sigla',
 'Para traduzir os preceitos gerais da Declaração de 1948 em diplomas juridicamente vinculantes, o arcabouço da Organização das Nações Unidas aprovou, em 1966, dois grandes tratados, usualmente designados pelas siglas PIDCP e PIDESC. Assinale a alternativa que associa corretamente cada sigla à sua denominação oficial completa.'),
(16,'cc84-06','7cfd81f6-49ab-4a15-b643-9a8a7b026deb',82,84,'media','PAPIRO — DH-AUT-03 — cc84-06 — Pactos origem ONU x regionais',
 'Na arquitetura institucional do Direito Internacional, a origem do documento e a organização sob a qual foi adotado determinam a sua área de abrangência perante os Estados. Ao se constatar que um país ratificou o PIDCP (Pacto Internacional sobre Direitos Civis e Políticos) e o PIDESC (Pacto Internacional sobre Direitos Econômicos, Sociais e Culturais), deve-se inferir que esses instrumentos:'),
(17,'cc84-07','7cfd81f6-49ab-4a15-b643-9a8a7b026deb',82,84,'media','PAPIRO — DH-AUT-03 — cc84-07 — Assertivas combinadas DUDH/Pactos',
 E'Considere as afirmativas a seguir em relação ao arcabouço global de proteção e à intersecção material entre a Declaração de 1948 e os Pactos de 1966:\n\nI. O Pacto Internacional sobre Direitos Civis e Políticos (PIDCP) e o Pacto Internacional sobre Direitos Econômicos, Sociais e Culturais (PIDESC) foram idealizados no âmbito da Organização das Nações Unidas (ONU).\nII. Embora tanto a Declaração de 1948 quanto os Pactos de 1966 estruturem direitos da pessoa humana, a DUDH não ostenta a forma de um tratado ratificável, ao passo que os Pactos vinculam convencionalmente os seus respectivos Estados Partes.\nIII. Em decorrência do avanço normativo na ONU, a adoção dos Pactos extinguiu as funções da DUDH, revogando o seu conteúdo ético em todo o sistema universal.\n\nEstá correto o que se afirma em:'),
(18,'cc85-01','d815fc1f-82d3-4411-9dc5-63dae5373d2b',86,85,'dificil','PAPIRO — DH-AUT-03 — cc85-01 — Peticao Comissao x jurisdicao contenciosa Corte',
 'O Sistema Interamericano de Direitos Humanos fundamenta-se num mecanismo institucional de proteção, supervisão e responsabilização, operado por seus dois grandes órgãos institucionais, que mantêm relações procedimentais específicas com os Estados e com os indivíduos do continente. A respeito do acesso a esses órgãos e do alcance de suas prerrogativas sob a ótica da Convenção Americana de Direitos Humanos, assinale a opção que traça corretamente a distinção formal entre a atuação contenciosa da Corte e o recebimento de petições pela Comissão.'),
(19,'cc85-02','d815fc1f-82d3-4411-9dc5-63dae5373d2b',86,85,'media','PAPIRO — DH-AUT-03 — cc85-02 — Funcao consultiva da Corte',
 'A Corte Interamericana de Direitos Humanos, além de atuar em casos submetidos nos termos da Convenção Americana contra Estados sujeitos à sua jurisdição contenciosa, recebe do arcabouço normativo interamericano uma segunda competência de relevo para a estabilização jurisprudencial no continente. No tocante a essa competência da Corte, é correto afirmar que:'),
(20,'cc85-03','d815fc1f-82d3-4411-9dc5-63dae5373d2b',86,85,'dificil','PAPIRO — DH-AUT-03 — cc85-03 — Esgotamento recursos internos e excecoes',
 'Determinada pessoa, nacional de um Estado Parte da Convenção Americana sobre Direitos Humanos, alega ter sofrido violação de direito protegido pela Convenção em razão de ato de agente estatal. Desejando levar o caso à Comissão Interamericana, é advertida sobre um requisito procedimental básico de admissibilidade. Ao buscar as instâncias nacionais e examinar a legislação pátria, constata-se que não existe, no Estado em questão, o devido processo legal para a proteção do direito alegadamente violado. Sobre essa situação em face das regras de admissibilidade da Comissão Interamericana, assinale a opção correta.'),
(21,'cc85-04','d815fc1f-82d3-4411-9dc5-63dae5373d2b',86,85,'media','PAPIRO — DH-AUT-03 — cc85-04 — CADH instrumento central do SIDH',
 'O Sistema Interamericano de Direitos Humanos é composto por diferentes instrumentos normativos, nem todos com natureza de tratado — é o caso da Declaração Americana dos Direitos e Deveres do Homem (1948). Assinale a alternativa que indica o tratado que constitui o instrumento central do sistema convencional interamericano de proteção dos direitos humanos, consagrando deveres jurídicos vinculantes para os Estados Partes no continente.'),
(22,'cc85-05','d815fc1f-82d3-4411-9dc5-63dae5373d2b',86,85,'facil','PAPIRO — DH-AUT-03 — cc85-05 — CADH art.33 orgaos',
 'O art. 33 da Convenção Americana sobre Direitos Humanos elenca os órgãos competentes para conhecer dos assuntos relacionados com o cumprimento dos compromissos assumidos pelos Estados Partes nessa Convenção. Assinale a alternativa que apresenta, correta e exclusivamente, o par de órgãos expressamente previsto nesse dispositivo.');

create temporary table _lote_explicacoes (ordem int primary key, explicacao text) on commit drop;
insert into _lote_explicacoes (ordem, explicacao) values
(1, E'GABARITO: alternativa A\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nA proteção internacional de direitos humanos divide-se em um sistema universal (no âmbito da ONU) e em sistemas regionais de proteção. Três dos principais sistemas regionais são o Interamericano (OEA), o Europeu (Conselho da Europa) e o Africano (União Africana), cada qual com instâncias e instrumentos próprios.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nB, C, D e E misturam esses sistemas com blocos econômicos (Mercosul), alianças militares históricas (Pacto de Varsóvia) ou atribuem a eles subordinação, substituição ou jurisdição sobre a ONU que não correspondem à arquitetura real do sistema internacional de proteção.'),
(2, E'GABARITO: alternativa C\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nA DUDH é reconhecida como o documento basilar (marco normativo e ético) do qual emanou o Sistema Universal de Proteção dos Direitos Humanos da ONU. A alternativa C descreve corretamente esse papel central.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nAs demais atribuem a DUDH a sistemas regionais (A e E), afirmam que substitui ordenamentos nacionais (B, o que fere a complementaridade), ou confundem-na com o Estatuto de Roma/TPI (D).'),
(3, E'GABARITO: alternativa E\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nA alternativa E reflete o princípio da subsidiariedade (complementaridade) que rege o Direito Internacional dos Direitos Humanos. O dever primário de proteção recai sobre o Estado, enquanto os mecanismos internacionais coexistem com a tutela interna e podem atuar de maneira complementar segundo as regras próprias de cada sistema. Isso não transforma os sistemas internacionais em instâncias recursais automáticas nem em substitutos gerais da jurisdição nacional.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA e B erram ao pregar substituição ou jurisdição originária/recursal automática. C erra ao afirmar que o Estado não pode integrar simultaneamente os sistemas regional e universal (podem coexistir). D exige renúncia formal à soberania inexistente no direito internacional dos direitos humanos.'),
(4, E'GABARITO: alternativa B\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO PIDCP e o PIDESC são os dois principais tratados que, ao lado da DUDH, compõem a Carta Internacional dos Direitos Humanos (International Bill of Human Rights). Foram aprovados pela Assembleia Geral da ONU em 1966, integrando o sistema universal de proteção.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA, C e D limitam-nos equivocadamente a sistemas regionais; a E nega seu caráter internacional.'),
(5, E'GABARITO: alternativa D\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO Direito Internacional dos Direitos Humanos baseia-se na complementaridade (subsidiariedade). Os Estados têm a obrigação primária de tutelar os direitos humanos; o sistema internacional funciona como salvaguarda complementar à proteção interna, sem substituí-la automaticamente.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA, B e C descrevem formas de substituição/supressão de soberania inexistentes. A alternativa E também está incorreta: a existência de mecanismos internacionais de proteção não impede que a ordem interna estabeleça proteção mais favorável aos direitos humanos.'),
(6, E'GABARITO: alternativa A\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO item I está correto: o sistema universal opera sob os auspícios da ONU. O item II está correto: a DUDH é o documento inaugural desse arranjo.\n\nPOR QUE O ITEM III ESTÁ INCORRETO:\nO sistema universal não estabelece hierarquia revogatória nem substituição automática da jurisdição doméstica; a proteção nacional e a internacional coexistem e se articulam dentro da arquitetura internacional de proteção. Logo, apenas I e II — alternativa A.'),
(7, E'GABARITO: alternativa B\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nA alternativa B reflete o art. 4º da DUDH: "Ninguém será mantido em escravidão ou servidão; a escravidão e o tráfico de escravos serão proibidos em todas as suas formas" — vedação ampla e irrestrita, confirmada no texto oficial da ONU.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nAs demais opções inserem temas penais, laborais ou de extradição estranhos ao art. 4º; a E relativiza indevidamente a proibição.'),
(8, E'GABARITO: alternativa D\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nA alternativa D está alinhada ao art. 7º da DUDH ("Todos são iguais perante a lei e têm direito, sem qualquer distinção, a igual proteção da lei. Todos têm direito a igual proteção contra qualquer discriminação que viole a presente Declaração e contra qualquer incitamento a tal discriminação"), texto confirmado na versão oficial da ONU.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nAs demais inserem restrições infundadas (exclusão de apátridas, tolerância a incitamento, impunidade cultural) estranhas ao dispositivo.'),
(9, E'GABARITO: alternativa C\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nA alternativa C reproduz as garantias do art. 18 da DUDH: toda pessoa tem direito à liberdade de pensamento, consciência e religião, incluindo a liberdade de mudar de religião ou crença e de manifestá-la pelo ensino, prática, culto e observância, isolada ou coletivamente, em público ou em particular (texto confirmado na versão oficial da ONU). A lei local hipotética viola a Declaração ao proibir a mudança de crença e ao restringir o culto ao ambiente privado.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA alternativa A também é incorreta, pois o art. 18 expressamente reconhece a manifestação pública e coletiva, não a limitando ao foro íntimo. B, D e E validam restrições que igualmente contrariam o conteúdo expresso do art. 18.'),
(10, E'GABARITO: alternativa E\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nA alternativa E está de acordo com o artigo 5º da DUDH, que não comporta qualquer exceção legal, judicial, temporal (paz ou guerra) ou de excepcionalidade (segurança do Estado, conflitos armados, operações de inteligência) à vedação da tortura e de tratamentos ou castigos cruéis, desumanos ou degradantes.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nO texto do art. 5º não prevê as exceções inventadas pelos distratores A, B, C e D.'),
(11, E'GABARITO: alternativa B\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nA DUDH foi aprovada como Resolução (217 A III) da Assembleia Geral da ONU, não possuindo a conformação técnica de um tratado sujeito a ratificação, embora dotada de peso moral e político imenso. O PIDCP e o PIDESC nasceram com formato jurídico de tratado e, após as ratificações, criaram obrigações normativas exigíveis para os respectivos Estados Partes.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA, C, D e E distorcem a natureza ou o âmbito de aplicação dos diplomas.'),
(12, E'GABARITO: alternativa E\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nA adoção da DUDH em 1948 foi um primeiro passo declaratório. O PIDCP e o PIDESC desenvolveram, em forma convencional, muitos dos direitos proclamados na DUDH e estabeleceram obrigações jurídicas internacionais para seus respectivos Estados Partes.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA DUDH não perdeu sua força (A), não virou tratado unificado (B), os Pactos não restringem direitos em favor da soberania (C), tampouco são sancionadores de votação pretérita (D).'),
(13, E'GABARITO: alternativa A\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nA DUDH é uma resolução da Assembleia Geral, não um tratado. Contudo, em Direito Internacional, a reiteração contínua de condutas estatais combinada com a opinio juris (consciência de obrigatoriedade) pode dar origem ao costume internacional. Devido à sua ampla influência e reiterada invocação pela prática dos Estados, considera-se hoje que determinadas normas proclamadas na DUDH refletem ou adquiriram esse caráter costumeiro, independentemente de ratificação. A alternativa A está corretamente redigida e de forma cautelosa ("determinadas normas", sem generalizar).\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nB e D radicalizam (texto inteiro virou costume/convenção tácita); C nega o fenômeno real do costume; E propõe mecanismo de controle pelo Conselho de Segurança inexistente.'),
(14, E'GABARITO: alternativa C\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nA alternativa C traça corretamente as fronteiras institucionais: a DUDH possui natureza declaratória e não convencional, servindo como paradigma axiológico fundante, ao passo que a ratificação do PIDCP e do PIDESC faz surgir para o Estado "Beta" obrigações convencionais vinculantes previstas nos respectivos Pactos.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA (falsa revogação da DUDH), B (mesma origem/conversão bilateral), D (DUDH já era obrigação convencional) e E (ratificação blinda contra monitoramento) contrariam os postulados do Sistema Global de Direitos Humanos.'),
(15, E'GABARITO: alternativa D\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nA alternativa D associa corretamente as siglas às denominações oficiais: PIDCP — Pacto Internacional sobre Direitos Civis e Políticos; PIDESC — Pacto Internacional sobre Direitos Econômicos, Sociais e Culturais.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA alternativa B troca "Internacional" por "Interamericano", sugerindo indevidamente um sistema regional; A, C e E atribuem denominações fictícias ou incompletas aos dois diplomas.'),
(16, E'GABARITO: alternativa B\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nA ONU tem vocação e escopo universais, o que define a essência estrutural de seus órgãos e das convenções adotadas sob seus auspícios. O PIDCP e o PIDESC emanaram e foram adotados pela Assembleia Geral da ONU, inserindo-se, portanto, no sistema universal de proteção.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nAs demais alternativas contrastam com restrições falsas a continentes, ONGs, Conselho da Europa ou ao continente americano.'),
(17, E'GABARITO: alternativa A\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nA assertiva I está correta quanto à nomenclatura e à origem universal (ONU) de ambos os diplomas. A assertiva II sintetiza corretamente a diferença formal: a DUDH é resolução/declaração e os Pactos são tratados vinculantes para os Estados que os ratificam.\n\nPOR QUE A ASSERTIVA III ESTÁ INCORRETA:\nA edição dos Pactos desenvolveu, em forma convencional, muitos dos direitos proclamados na DUDH e estabeleceu obrigações para os respectivos Estados Partes, mas jamais extinguiu ou revogou o peso moral e axiológico da Declaração. Gabarito A (I e II, apenas).'),
(18, E'GABARITO: alternativa D\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nA alternativa D está de acordo com a CADH. Pelo art. 44, qualquer pessoa, grupo de pessoas ou entidade não governamental legalmente reconhecida em um ou mais Estados-Membros da OEA pode apresentar à Comissão petições contendo denúncias ou queixas de violação da Convenção — os indivíduos não submetem ações diretamente à Corte. Já o art. 62 estabelece que a jurisdição contenciosa da Corte para julgar casos relativos à interpretação ou aplicação da Convenção depende do prévio reconhecimento dessa competência pelo Estado-Parte (nos termos do art. 61, apenas os Estados-Partes e a própria Comissão têm o direito de submeter um caso à Corte, após esgotados os processos perante a Comissão previstos nos arts. 48 a 50).\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA erra ao admitir ação direta de indivíduos perante a Corte. B erra ao subordinar a Comissão à Assembleia Geral da ONU (a Comissão é órgão da OEA). C erra ao equiparar o regime das comunicações interestatais (art. 45, que exige declaração específica de reconhecimento) ao das petições individuais do art. 44, que independem dessa declaração. E inverte as naturezas dos órgãos.'),
(19, E'GABARITO: alternativa A\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nA alternativa A descreve com precisão a competência consultiva do art. 64 da CADH: os Estados-Membros (e os órgãos da OEA enumerados no capítulo X de sua Carta, dentro de suas competências) podem consultar a Corte sobre a interpretação da CADH e de outros tratados concernentes a direitos humanos nos Estados americanos, podendo o Estado pedir ainda parecer sobre a compatibilidade de lei interna com esses instrumentos.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nAs demais alternativas inventam atribuições irreais para a função consultiva.'),
(20, E'GABARITO: alternativa B\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nConforme o art. 46 da CADH, a admissibilidade de uma petição pela Comissão exige, como regra geral, que hajam sido interpostos e esgotados os recursos da jurisdição interna, de acordo com os princípios de Direito Internacional geralmente reconhecidos (art. 46.1.a). Essa exigência não se aplica quando não existir, na legislação interna, o devido processo legal para a proteção do direito alegadamente violado (art. 46.2.a), entre outras hipóteses do art. 46.2. A alternativa B alia corretamente a regra geral à exceção verificada no caso, sem afirmar admissão automática — a Comissão ainda examina os demais requisitos de admissibilidade (art. 46.1, b-d) e as causas de inadmissibilidade do art. 47.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA e C consagram posições absolutas opostas e igualmente incorretas. D e E inserem exigências inexistentes no sistema interamericano.'),
(21, E'GABARITO: alternativa E\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nA Convenção Americana sobre Direitos Humanos, o Pacto de San José da Costa Rica (1969), é o instrumento central do sistema convencional interamericano de proteção dos direitos humanos, dela emanando, entre outros, os mandatos específicos da Comissão e da Corte fixados no art. 33. Isso não retira a relevância de outros diplomas do arcabouço interamericano, como a Declaração Americana de 1948 (sem natureza de tratado) ou a Carta da OEA.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nA Carta Africana, o PIDCP, o Estatuto de Roma e a Convenção Europeia pertencem a outros sistemas ou organismos.'),
(22, E'GABARITO: alternativa C\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO art. 33 da CADH dispõe que são competentes para conhecer dos assuntos relacionados com o cumprimento dos compromissos assumidos pelos Estados Partes nessa Convenção exclusivamente: a) a Comissão Interamericana de Direitos Humanos; e b) a Corte Interamericana de Direitos Humanos (texto confirmado no Decreto nº 678/1992). A alternativa C é a única que reproduz esse par exato.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nAs demais combinam corretamente um dos dois órgãos do art. 33 com uma segunda instituição real, porém estranha a esse dispositivo específico: a Assembleia Geral e o Conselho Permanente são órgãos políticos da OEA, não mencionados no art. 33; a Corte Internacional de Justiça é órgão da ONU, sem relação com a CADH; o Comitê de Direitos Humanos é órgão de tratado do sistema universal (PIDCP), estranho ao sistema interamericano.');

create temporary table _lote_alternativas (
  ordem int,
  ordem_alt smallint,
  texto text,
  correta boolean
) on commit drop;

insert into _lote_alternativas (ordem, ordem_alt, texto, correta) values
(1,1,'O Sistema Interamericano, o Sistema Europeu e o Sistema Africano, que possuem instâncias e instrumentos próprios para seus continentes, diferindo do sistema universal da ONU.',true),
(1,2,'O Sistema Interamericano, o Sistema do Mercosul e o Sistema Asiático, que operam sob a coordenação direta do Conselho de Segurança da ONU.',false),
(1,3,'O Sistema Asiático, o Sistema Europeu e o Sistema do Pacto de Varsóvia, atuando como câmaras recursais exclusivas para decisões do sistema universal.',false),
(1,4,'O Sistema Africano, o Sistema Interamericano e o Sistema da Liga Árabe, que substituíram integralmente as funções de proteção universal da ONU.',false),
(1,5,'O Sistema Europeu, o Sistema Mundial e o Sistema Transnacional, que possuem jurisdição global sobre o sistema das Nações Unidas.',false),

(2,1,'inaugurar o sistema interamericano de direitos humanos, vinculando exclusivamente os países do continente americano à sua jurisdição material.',false),
(2,2,'substituir integralmente os ordenamentos jurídicos nacionais, operando como uma constituição global para os países membros das Nações Unidas.',false),
(2,3,'constituir o marco normativo central e o alicerce ético que estruturou a formação do sistema universal de proteção gerido pela Organização das Nações Unidas.',true),
(2,4,'estabelecer uma corte penal internacional subsidiária, com o objetivo de julgar diretamente indivíduos acusados de crimes de guerra, sem intervenção estatal.',false),
(2,5,'atuar como o primeiro tratado regional de direitos humanos da Europa, fundamentando a criação posterior do Tribunal Europeu.',false),

(3,1,'correta, pois a partir da criação da ONU, o sistema universal e os sistemas regionais assumiram a jurisdição originária sobre qualquer violação de direitos fundamentais.',false),
(3,2,'correta, uma vez que o sistema regional possui a prerrogativa de anular automaticamente qualquer decisão dos tribunais nacionais, operando como quarta instância ordinária.',false),
(3,3,'equivocada, pois os sistemas regional e universal são mutuamente excludentes, sendo vedado a um Estado pertencer a ambos simultaneamente, obrigando a escolha exclusiva do fórum.',false),
(3,4,'equivocada, pois a proteção internacional só pode ser acionada se o Estado "Alfa" renunciar formalmente à sua soberania jurisdicional em tratado específico para cada caso.',false),
(3,5,'equivocada, pois o acionamento da proteção internacional possui natureza subsidiária e complementar, não substituindo automaticamente os tribunais internos, os quais detêm a primazia na garantia dos direitos.',true),

(4,1,'pertencem de modo exclusivo ao Sistema Interamericano, não produzindo efeitos para Estados fora das Américas.',false),
(4,2,'integram o sistema universal de proteção, tendo sido formulados e adotados no âmbito da Organização das Nações Unidas (ONU).',true),
(4,3,'foram concebidos pelo Conselho da Europa para compor, junto com a Convenção Europeia, o sistema regional europeu de proteção.',false),
(4,4,'compõem a base normativa primária do Sistema Africano de Direitos Humanos, vinculando a União Africana.',false),
(4,5,'compõem um sistema de direito interno não internacional, servindo apenas como orientação sem foro no sistema universal.',false),

(5,1,'A criação dos órgãos internacionais acarretou a caducidade dos sistemas judiciários nacionais nas matérias relativas a direitos humanos, que passaram à jurisdição exclusiva da ONU.',false),
(5,2,'A intervenção do sistema universal é pautada pelo princípio da substituição imediata, cabendo aos órgãos da ONU avocar processos judiciais internos a qualquer momento.',false),
(5,3,'A proteção internacional universal anula a vigência das Constituições nacionais no que tange aos direitos fundamentais, estipulando um rol impositivo fechado.',false),
(5,4,'A proteção internacional atua de forma complementar à nacional, sendo a jurisdição do próprio Estado a via primária para a garantia e reparação dos direitos humanos.',true),
(5,5,'A existência do sistema internacional universal proíbe a criação de regras nacionais mais benéficas, visando garantir a uniformidade normativa global.',false),

(6,1,'I e II, apenas.',true),
(6,2,'I, apenas.',false),
(6,3,'II e III, apenas.',false),
(6,4,'I e III, apenas.',false),
(6,5,'I, II e III.',false),

(7,1,'o direito incondicional à liberdade provisória para todos os cidadãos, independentemente da gravidade da conduta penal praticada.',false),
(7,2,'a proibição de manter qualquer pessoa em escravidão ou servidão, sendo vedados a escravatura e o tráfico de escravos em todas as suas formas.',true),
(7,3,'a garantia de repouso remunerado para trabalhadores rurais, a fim de evitar as consequências da exploração do trabalho análogo à servidão moderna.',false),
(7,4,'a vedação de extradição por crime político, quando o requerente for refugiado que fuja de regimes que institucionalizam o trabalho escravo.',false),
(7,5,'a proibição exclusiva do tráfico transatlântico de pessoas para fins laborais, admitindo a servidão em caso de dívidas civis contraídas licitamente.',false),

(8,1,'Todos são iguais perante a lei civil, admitindo-se tratamentos desiguais unicamente no campo dos direitos econômicos para equalizar disparidades de renda.',false),
(8,2,'O direito a igual proteção da lei aplica-se exclusivamente aos cidadãos natos ou naturalizados de um Estado, excluindo do texto os apátridas e os refugiados.',false),
(8,3,'A proteção restringe-se a vedações de ações diretas do Estado, sendo tolerado, contudo, o incitamento ao ódio feito no exercício da liberdade de expressão privada.',false),
(8,4,'Todos têm direito, sem qualquer distinção, a igual proteção da lei, bem como a igual proteção contra qualquer discriminação que viole a Declaração e contra qualquer incitamento a tal discriminação.',true),
(8,5,'A igualdade perante a lei assegura a impunidade em delitos de menor potencial ofensivo que sejam decorrentes de manifestações culturais de minorias sub-representadas.',false),

(9,1,'encontra amparo na Declaração, pois o artigo 18 protege apenas a liberdade de pensamento e consciência no foro íntimo, não reconhecendo o direito de manifestar a religião ou crença de forma pública ou coletiva.',false),
(9,2,'é parcialmente alinhada à Declaração, pois, embora não se possa proibir a mudança de crença, o culto e a prática estão restritos ao âmbito estritamente privado de cada indivíduo.',false),
(9,3,'viola a Declaração, pois o direito abrange a liberdade de mudar de religião ou crença, bem como a de manifestá-la pelo ensino, prática, culto e observância, tanto isolada quanto coletivamente, de forma pública ou privada.',true),
(9,4,'viola a Declaração unicamente por impedir a mudança de crença, mas age de forma lícita ao restringir o ensino e a prática religiosa ao ambiente doméstico e individual.',false),
(9,5,'encontra amparo na Declaração, uma vez que as normas de direitos humanos autorizam os Estados a limitarem o direito de mudar de religião, em respeito à cultura original da respectiva população.',false),

(10,1,'ninguém será submetido a castigos degradantes, ressalvada a possibilidade de tortura para obtenção de informações em situações de risco iminente à vida de terceiros.',false),
(10,2,'ninguém será submetido a tortura, salvo mediante autorização judicial fundamentada em investigações de crimes contra a segurança do Estado.',false),
(10,3,'ninguém será submetido a penas cruéis ou desumanas em tempos de paz, sendo tolerados castigos físicos equivalentes em conflitos armados.',false),
(10,4,'ninguém será submetido a tratamento desumano em estabelecimentos civis, sendo admitida a tortura em operações de inteligência militar.',false),
(10,5,'ninguém será submetido a tortura, nem a tratamento ou castigo cruel, desumano ou degradante.',true),

(11,1,'a DUDH é um tratado internacional impositivo ratificado originalmente por todos os membros da ONU, enquanto os Pactos de 1966 são meras recomendações éticas sem força obrigatória.',false),
(11,2,'a DUDH foi adotada sob a forma de resolução da Assembleia Geral da ONU, não possuindo a conformação técnica de um tratado, ao passo que o PIDCP e o PIDESC são tratados internacionais que geram obrigações jurídicas vinculantes para os Estados que os ratificam.',true),
(11,3,'a DUDH atua como documento normativo interno da sede da ONU, ao passo que os Pactos são declarações filosóficas aplicáveis apenas em conflitos armados internacionais.',false),
(11,4,'ambos possuem a idêntica natureza de tratados internacionais plenos, sendo a diferença entre eles estritamente voltada aos órgãos competentes para realizar a jurisdição perante a Corte Internacional de Justiça.',false),
(11,5,'a DUDH é um tratado vinculante exclusivamente para os Estados do continente europeu que a propuseram, enquanto os Pactos vinculam compulsoriamente os países em desenvolvimento.',false),

(12,1,'Os Pactos anularam e substituíram formalmente a DUDH, que perdeu todo o seu valor moral e referencial na comunidade internacional após 1966.',false),
(12,2,'A DUDH, por força de norma cogente global, foi transformada, ao longo dos anos 1960, em um único tratado internacional obrigatório para todo o globo, dispensando a ratificação dos Pactos.',false),
(12,3,'Os Pactos restringiram as garantias previstas na DUDH para conferir maior soberania e blindagem aos Estados contra intervenções da ONU em seu direito doméstico.',false),
(12,4,'Os Pactos criaram obrigações internacionais apenas para os países que haviam votado contra a adoção da DUDH, agindo como um instrumento sancionador.',false),
(12,5,'Os Pactos desenvolveram os direitos inicialmente proclamados na DUDH, estruturando-os juridicamente na forma de tratados internacionais que estabelecem obrigações vinculantes para seus respectivos Estados Partes.',true),

(13,1,'o fato de a DUDH não possuir, em sua origem, a forma de um tratado não impede que determinadas normas nela proclamadas reflitam, na atualidade, ou tenham adquirido o caráter e a força de direito internacional costumeiro, independentemente de ratificação.',true),
(13,2,'a doutrina e a jurisprudência internacionais são unânimes em classificar o texto integral da DUDH como costume internacional imediato, impondo todas as suas diretrizes de modo absoluto e automático sobre todos os ordenamentos pátrios.',false),
(13,3,'como a DUDH nasceu na forma de mera resolução da Assembleia Geral, é terminantemente impossível que qualquer um dos seus postulados integre os costumes internacionais, pois o costume exige chancela formal de Cortes Regionais.',false),
(13,4,'a Assembleia Geral da ONU editou resolução subsequente transformando automaticamente a DUDH em uma convenção assinada e ratificada tacitamente pelos 193 Estados-membros contemporâneos.',false),
(13,5,'os direitos humanos presentes na DUDH só adquirem exigibilidade no cenário global caso sejam submetidos anualmente à confirmação e ratificação pelo Conselho de Segurança da ONU.',false),

(14,1,'A ratificação dos Pactos desobriga o Estado "Beta" das balizas éticas da DUDH, pois os tratados internacionais substituem as resoluções da Assembleia Geral para fins de anulação retroativa de direitos.',false),
(14,2,'Tanto a DUDH quanto os referidos Pactos possuem exatamente a mesma origem, pois a ratificação de um acarreta a imediata conversão do outro na categoria de tratado bilateral.',false),
(14,3,'A DUDH possui natureza declaratória e atua como paradigma axiológico fundante; já a ratificação dos Pactos submete o Estado "Beta", sob o ponto de vista estrito do Direito dos Tratados, a obrigações convencionais de natureza vinculante perante a comunidade internacional.',true),
(14,4,'Como a DUDH estabelece obrigações convencionais sancionáveis desde 1948 para o Estado "Beta", o depósito e ratificação do PIDCP e do PIDESC possuem efeitos meramente simbólicos no campo diplomático.',false),
(14,5,'A condição de Estado Parte dos Pactos impede o Estado "Beta" de ser monitorado pelo sistema universal, pois a adesão formal confere blindagem contra a ingerência de comitês internacionais de supervisão.',false),

(15,1,'Protocolo Internacional de Defesa Civil e Política; Protocolo Internacional de Direitos Econômicos e Sociais Compulsórios.',false),
(15,2,'Pacto Interamericano de Direitos Civis e Políticos; Pacto Interamericano de Direitos Econômicos, Sociais e Culturais.',false),
(15,3,'Pacto Internacional sobre Direitos Coletivos e Populares; Pacto Internacional sobre Direitos Econômicos, Sociais e Coletivos.',false),
(15,4,'Pacto Internacional sobre Direitos Civis e Políticos; Pacto Internacional sobre Direitos Econômicos, Sociais e Culturais.',true),
(15,5,'Pacto Internacional sobre Direitos Civis e Penais; Pacto Internacional sobre Direitos Econômicos, Sindicais e Culturais.',false),

(16,1,'representam marcos do sistema regional europeu de proteção, sendo geridos diretamente pelo Conselho da Europa com aplicação subsidiária em outras regiões.',false),
(16,2,'foram adotados no seio da Organização das Nações Unidas, inserindo-se, portanto, no mecanismo universal de proteção, o que os diferencia de convenções e cartas concebidas em foros meramente regionais.',true),
(16,3,'atuam como o regulamento central do Tribunal Penal Internacional para a América Latina, vinculando somente os países de língua ibérica, sem correlação orgânica com instâncias mundiais.',false),
(16,4,'nasceram sob a coordenação exclusiva de Organizações Não Governamentais transnacionais, operando fora dos canais institucionais oficiais e das organizações intergovernamentais.',false),
(16,5,'compõem a base principal da Organização dos Estados Americanos (OEA), sendo a assinatura de ambos pré-requisito indispensável para integrar o sistema interamericano de garantias individuais.',false),

(17,1,'I e II, apenas.',true),
(17,2,'II e III, apenas.',false),
(17,3,'I, apenas.',false),
(17,4,'II, apenas.',false),
(17,5,'I, II e III.',false),

(18,1,'Indivíduos podem propor ações diretas na Corte Interamericana para requerer o julgamento condenatório de seus governos, enquanto a Comissão detém a prerrogativa restrita de arbitrar tratados de paz.',false),
(18,2,'A jurisdição da Corte sobre denúncias interindividuais é originária e ampla, ao passo que a Comissão somente atua no continente mediante prévia autorização da Assembleia Geral das Nações Unidas.',false),
(18,3,'A competência para receber toda e qualquer petição interestatal (Estado denunciando Estado) opera, no âmbito da Comissão, sob o mesmo regime amplo da denúncia feita por indivíduos, não exigindo declaração especial.',false),
(18,4,'A Comissão pode receber petições individuais contendo queixas ou denúncias de violação dos direitos consagrados na Convenção, ao passo que a submissão de um caso à jurisdição contenciosa da Corte Interamericana depende de prévio reconhecimento, pelo Estado, dessa competência jurisdicional.',true),
(18,5,'A Comissão funciona como instância judicial recursal que pode revisar condenações aplicadas pelos governos, enquanto a Corte Interamericana funciona essencialmente como uma agência investigativa policial e administrativa.',false),

(19,1,'a Corte possui função consultiva, podendo emitir, a pedido dos Estados membros da OEA, pareceres sobre a interpretação da Convenção, de outros tratados concernentes à proteção nos Estados americanos, bem como sobre a compatibilidade de suas leis internas com esses instrumentos.',true),
(19,2,'a competência consultiva da Corte limita-se à emissão de declarações de guerra e manutenção da paz entre nações sul-americanas, não englobando a análise prévia de normas ou interpretação de convenções materiais.',false),
(19,3,'diferentemente de sua atuação processual punitiva, a função consultiva só pode ser instaurada por requisição formal e conjunta do Presidente da República do Brasil e do Comitê de Direitos Humanos da ONU.',false),
(19,4,'a Corte, por meio de sua competência consultiva, anula e revoga em caráter definitivo e originário as leis aprovadas pelos parlamentos nacionais do hemisfério antes mesmo que elas entrem em vigor.',false),
(19,5,'no exercício de pareceres, a Corte Interamericana funciona como tribunal criminal auxiliar para julgamento privado de indivíduos processados por genocídio nas Américas.',false),

(20,1,'A Comissão rejeitará inevitavelmente a petição, uma vez que o esgotamento dos recursos internos constitui exigência absoluta e que jamais comporta qualquer relativização, sob nenhuma hipótese prevista no sistema interamericano.',false),
(20,2,'A regra geral de admissibilidade exige que os recursos da jurisdição interna tenham sido interpostos e esgotados; contudo, essa exigência não se aplica quando demonstrado que não existe, na legislação interna, o devido processo legal para a proteção do direito alegadamente violado, sem prejuízo da análise dos demais requisitos de admissibilidade previstos na Convenção.',true),
(20,3,'A petição deve ser considerada liminarmente aceita independentemente do que ocorra no âmbito nacional, pois a Corte e a Comissão interamericanas adotaram a regra da competência primária, dispensando na atualidade a necessidade de esgotamento.',false),
(20,4,'O sistema interamericano impõe que, diante da falta de recursos internos adequados, o indivíduo deve formular requerimento ao Conselho da Europa para atestar o fato e, somente então, remeter a certidão de falha à OEA.',false),
(20,5,'A regra estipula que as exceções ao esgotamento dos recursos internos só operam se o prejuízo imposto ao cidadão ultrapassar a marca monetária de um milhão de dólares, critério objetivo para ingresso na pauta internacional.',false),

(21,1,'A Carta Africana dos Direitos Humanos e dos Povos.',false),
(21,2,'O Pacto Internacional sobre Direitos Civis e Políticos da ONU.',false),
(21,3,'O Estatuto de Roma de Criação do Tribunal Penal Internacional.',false),
(21,4,'A Convenção Europeia dos Direitos do Homem de Roma.',false),
(21,5,'A Convenção Americana sobre Direitos Humanos (Pacto de San José da Costa Rica).',true),

(22,1,'Comissão Interamericana de Direitos Humanos e Assembleia Geral da Organização dos Estados Americanos.',false),
(22,2,'Corte Interamericana de Direitos Humanos e Conselho Permanente da Organização dos Estados Americanos.',false),
(22,3,'Comissão Interamericana de Direitos Humanos e Corte Interamericana de Direitos Humanos.',true),
(22,4,'Comissão Interamericana de Direitos Humanos e Corte Internacional de Justiça.',false),
(22,5,'Corte Interamericana de Direitos Humanos e Comitê de Direitos Humanos da ONU.',false);

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

  if (select count(*) from _lote_questoes where cc_id=82) <> 6 then raise exception 'Precondicao falhou: staging cc82 <> 6'; end if;
  if (select count(*) from _lote_questoes where cc_id=83) <> 4 then raise exception 'Precondicao falhou: staging cc83 <> 4'; end if;
  if (select count(*) from _lote_questoes where cc_id=84) <> 7 then raise exception 'Precondicao falhou: staging cc84 <> 7'; end if;
  if (select count(*) from _lote_questoes where cc_id=85) <> 5 then raise exception 'Precondicao falhou: staging cc85 <> 5'; end if;

  if (select cc82_uteis from _snapshot_antes) <> 4 then raise exception 'Precondicao falhou: cc82_uteis=% (esperado 4)', (select cc82_uteis from _snapshot_antes); end if;
  if (select cc83_uteis from _snapshot_antes) <> 6 then raise exception 'Precondicao falhou: cc83_uteis=% (esperado 6)', (select cc83_uteis from _snapshot_antes); end if;
  if (select cc84_uteis from _snapshot_antes) <> 3 then raise exception 'Precondicao falhou: cc84_uteis=% (esperado 3)', (select cc84_uteis from _snapshot_antes); end if;
  if (select cc85_uteis from _snapshot_antes) <> 5 then raise exception 'Precondicao falhou: cc85_uteis=% (esperado 5)', (select cc85_uteis from _snapshot_antes); end if;
end $$;

-- Insercao das questoes + alternativas.
create temporary table _mapa_ids (ordem int primary key, questao_id bigint) on commit drop;

do $$
declare r record; v_id bigint;
begin
  for r in select * from _lote_questoes order by ordem loop
    insert into public.questoes (materia_id, assunto_id, banca, concurso, ano, enunciado, dificuldade, explicacao, fonte, ativa, gerada_por_ia)
    values (11, r.assunto_id, 'Papiro', 'PAPIRO - Curadoria DH-AUT-03 - BM RS', 2026, r.enunciado, r.dificuldade,
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
  v_cc82_uteis int; v_cc83_uteis int; v_cc84_uteis int; v_cc85_uteis int;
  v_cc82_real int; v_cc83_real int; v_cc84_real int; v_cc85_real int;
  v_dh_uteis_depois int;
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
  if v_facil <> 5 or v_media <> 11 or v_dificil <> 6 then
    raise exception 'Pos-condicao falhou: distribuicao dificuldade facil=%/media=%/dificil=% (esperado 5/11/6)', v_facil, v_media, v_dificil;
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

  select count(distinct qup.questao_id) into v_cc82_uteis from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id where up.curso_conteudo_id=82;
  select count(distinct qup.questao_id) into v_cc83_uteis from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id where up.curso_conteudo_id=83;
  select count(distinct qup.questao_id) into v_cc84_uteis from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id where up.curso_conteudo_id=84;
  select count(distinct qup.questao_id) into v_cc85_uteis from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id where up.curso_conteudo_id=85;

  if v_cc82_uteis <> (select cc82_uteis from _snapshot_antes) + 6 then raise exception 'Pos-condicao falhou: cc82_uteis=% (esperado %)', v_cc82_uteis, (select cc82_uteis from _snapshot_antes)+6; end if;
  if v_cc83_uteis <> (select cc83_uteis from _snapshot_antes) + 4 then raise exception 'Pos-condicao falhou: cc83_uteis=% (esperado %)', v_cc83_uteis, (select cc83_uteis from _snapshot_antes)+4; end if;
  if v_cc84_uteis <> (select cc84_uteis from _snapshot_antes) + 7 then raise exception 'Pos-condicao falhou: cc84_uteis=% (esperado %)', v_cc84_uteis, (select cc84_uteis from _snapshot_antes)+7; end if;
  if v_cc85_uteis <> (select cc85_uteis from _snapshot_antes) + 5 then raise exception 'Pos-condicao falhou: cc85_uteis=% (esperado %)', v_cc85_uteis, (select cc85_uteis from _snapshot_antes)+5; end if;

  if v_cc82_uteis <> 10 or v_cc83_uteis <> 10 or v_cc84_uteis <> 10 or v_cc85_uteis <> 10 then
    raise exception 'Pos-condicao falhou: alguma unidade nao atingiu exatamente 10 uteis (cc82=%,cc83=%,cc84=%,cc85=%)', v_cc82_uteis, v_cc83_uteis, v_cc84_uteis, v_cc85_uteis;
  end if;

  select count(distinct qup.questao_id) into v_cc82_real from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id join public.questoes q on q.id=qup.questao_id where up.curso_conteudo_id=82 and coalesce(lower(q.banca),'') not like '%papiro%';
  select count(distinct qup.questao_id) into v_cc83_real from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id join public.questoes q on q.id=qup.questao_id where up.curso_conteudo_id=83 and coalesce(lower(q.banca),'') not like '%papiro%';
  select count(distinct qup.questao_id) into v_cc84_real from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id join public.questoes q on q.id=qup.questao_id where up.curso_conteudo_id=84 and coalesce(lower(q.banca),'') not like '%papiro%';
  select count(distinct qup.questao_id) into v_cc85_real from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id join public.questoes q on q.id=qup.questao_id where up.curso_conteudo_id=85 and coalesce(lower(q.banca),'') not like '%papiro%';

  if v_cc82_real <> (select cc82_real from _snapshot_antes) or v_cc83_real <> (select cc83_real from _snapshot_antes)
     or v_cc84_real <> (select cc84_real from _snapshot_antes) or v_cc85_real <> (select cc85_real from _snapshot_antes) then
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

  raise notice 'Pos-condicoes OK: 22 questoes AUTORAL_PAPIRO novas / 110 alternativas / 22 vinculos / facil=% media=% dificil=% / gabaritos A=%,B=%,C=%,D=%,E=% / cc82..cc85 todas em 10 uteis / DH uteis %->%.',
    v_facil, v_media, v_dificil, v_A, v_B, v_C, v_D, v_E,
    (select dh_uteis from _snapshot_antes), v_dh_uteis_depois;
end $$;

commit;
