-- Aplicacao AUTORAL do Lote DH-AUT-05 de Direitos Humanos e Cidadania — 21
-- questoes novas AUTORAL_PAPIRO + 105 alternativas + 21 vinculos, validado
-- pelo harness supabase/importar_dh_aut_05_teste_rollback.sql (tudo_ok =
-- true precisa ser confirmado antes de rodar este arquivo).
--
-- Fecha o deficit_para_10 de 3 unidades de Direitos Humanos e Cidadania
-- (cc89 Convencao de Belem do Para, cc90 Casos do Brasil na Corte
-- Interamericana de Direitos Humanos, cc91 Direitos Humanos no Mercosul),
-- levando cada uma a exatamente 10 uteis:
--   cc89: 3->10 (7 novas) | cc90: 3->10 (7 novas) | cc91: 3->10 (7 novas)
--
-- Origem: AUTORAL_PAPIRO em todas as 21 (banca='Papiro') — nunca REAL.
-- Conteudo integralmente auditado nesta sessao (DH-AUT-05 — auditoria
-- independente Claude + microauditoria final), com verificacao de fontes
-- primarias/oficiais: Convencao Interamericana para Prevenir, Punir e
-- Erradicar a Violencia contra a Mulher — Convencao de Belem do Para
-- (Decreto no 1.973/1996, arts. 1 e 7 caput); sentencas da Corte
-- Interamericana de Direitos Humanos nos Casos Ximenes Lopes (04/07/2006),
-- Gomes Lund e outros "Guerrilha do Araguaia" (24/11/2010) e Herzog e
-- outros (15/03/2018); e instrumentos institucionais do MERCOSUL (Tratado
-- de Assuncao de 1991, Protocolo de Ushuaia de 1998, Protocolo de Assuncao
-- sobre Direitos Humanos de 2005, Decisao CMC no 40/04 — criacao da RAADH,
-- e Decisao CMC no 14/09 — criacao do IPPDH). As questoes Q147/Q148/Q149
-- (pre-existentes em cc90) tiveram apenas o campo explicacao saneado em
-- rodada tecnica anterior (commit da4ff04) — nao sao tocadas por este
-- arquivo.
--
-- Mecanismo de identificacao/idempotencia: cada uma das 21 e identificada
-- de forma inequivoca pelo texto EXATO do proprio enunciado. Se este
-- arquivo for executado uma segunda vez, a precondicao de "enunciado
-- identico" abortara a transacao inteira antes de qualquer insercao. O
-- rollback seguro pos-apply (se necessario no futuro) esta em
-- supabase/reverter_dh_aut_05.sql, que localiza e remove exclusivamente
-- estas 21 questoes pelo mesmo criterio de enunciado exato.
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
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 89) as cc89_uteis,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.questoes q on q.id = qup.questao_id where up.curso_conteudo_id = 89 and coalesce(lower(q.banca),'') not like '%papiro%') as cc89_real,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 90) as cc90_uteis,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.questoes q on q.id = qup.questao_id where up.curso_conteudo_id = 90 and coalesce(lower(q.banca),'') not like '%papiro%') as cc90_real,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 91) as cc91_uteis,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.questoes q on q.id = qup.questao_id where up.curso_conteudo_id = 91 and coalesce(lower(q.banca),'') not like '%papiro%') as cc91_real,
  (select count(distinct qup.questao_id)
     from public.questao_unidades_pedagogicas qup
     join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
     join public.curso_conteudos cc on cc.id = up.curso_conteudo_id
     join public.assuntos a on a.id = cc.assunto_id
     where a.materia_id = 11) as dh_uteis,
  (select md5(explicacao) from public.questoes where id = 147) as q147_hash,
  (select md5(explicacao) from public.questoes where id = 148) as q148_hash,
  (select md5(explicacao) from public.questoes where id = 149) as q149_hash;

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
(1,'cc89-01','a2d8b683-1a53-451e-9072-525a147fed01',107,89,'media','PAPIRO — DH-AUT-05 — cc89-01 — Belem do Para art.1 elemento genero',
 'O artigo 1º da Convenção Interamericana para Prevenir, Punir e Erradicar a Violência contra a Mulher (Convenção de Belém do Pará) apresenta o conceito normativo de violência contra a mulher. Para que um ato ou conduta seja subsumido a essa definição convencional, o texto exige que a violência seja:'),
(2,'cc89-02','a2d8b683-1a53-451e-9072-525a147fed01',107,89,'facil','PAPIRO — DH-AUT-05 — cc89-02 — Belem do Para art.1 resultados',
 'Nos termos do artigo 1º da Convenção Interamericana para Prevenir, Punir e Erradicar a Violência contra a Mulher, a violência contra a mulher é compreendida como qualquer ato ou conduta que tenha como resultado a:'),
(3,'cc89-03','a2d8b683-1a53-451e-9072-525a147fed01',107,89,'media','PAPIRO — DH-AUT-05 — cc89-03 — Belem do Para art.7 caput qualificadores',
 'O artigo 7º, caput, da Convenção de Belém do Pará estabelece diretrizes diretas para a atuação estatal. Ao assumirem o dever de adotar políticas destinadas a prevenir, punir e erradicar a violência contra a mulher, os Estados Partes convêm em implementar essa obrigação:'),
(4,'cc89-04','a2d8b683-1a53-451e-9072-525a147fed01',107,89,'facil','PAPIRO — DH-AUT-05 — cc89-04 — Belem do Para art.7 caput condenacao',
 'A Convenção de Belém do Pará impõe deveres aos Estados Partes no enfrentamento à violência contra a mulher. Segundo dispõe expressamente a primeira oração normativa do artigo 7º, caput, do referido tratado, os Estados Partes:'),
(5,'cc89-05','a2d8b683-1a53-451e-9072-525a147fed01',107,89,'dificil','PAPIRO — DH-AUT-05 — cc89-05 — Belem do Para art.1 aplicacao cumulativa',
 'Uma mulher foi alvo de agressões verbais sistemáticas e ameaças proferidas por seu ex-parceiro, o qual afirmava que ela deveria obedecer-lhe simplesmente pela sua condição de mulher. O caso ocorreu inteiramente no interior da residência da vítima, não havendo contato físico. Perícia atestou que a conduta resultou em grave dano e sofrimento psicológico. Analisando a situação à luz da definição do artigo 1º da Convenção Interamericana para Prevenir, Punir e Erradicar a Violência contra a Mulher, constata-se que a referida conduta:'),
(6,'cc89-06','a2d8b683-1a53-451e-9072-525a147fed01',107,89,'dificil','PAPIRO — DH-AUT-05 — cc89-06 — Belem do Para arts.1+7 caput conjugacao',
 'A Convenção de Belém do Pará estabelece obrigações diretas aos Estados Partes, vinculando o conceito material da violência aos deveres de ação estatal. Considerando a conjugação sistemática entre o artigo 1º e o caput do artigo 7º do diploma, o dever de adotar políticas destinadas a prevenir, punir e erradicar a violência contra a mulher:'),
(7,'cc89-07','a2d8b683-1a53-451e-9072-525a147fed01',107,89,'media','PAPIRO — DH-AUT-05 — cc89-07 — Belem do Para arts.1+7 caput assertivas',
 E'Com base nas disposições da Convenção Interamericana para Prevenir, Punir e Erradicar a Violência contra a Mulher (Convenção de Belém do Pará), analise as seguintes assertivas:\n\nI. A definição convencional de violência contra a mulher engloba os atos ou as condutas que tenham como resultado a morte, o dano ou o sofrimento físico, sexual ou psicológico.\nII. Para que a violência se enquadre no escopo de proteção do tratado, é requisito normativo que a conduta seja baseada no gênero.\nIII. Os Estados Partes condenam todas as formas de violência contra a mulher e convêm em adotar políticas destinadas a preveni-la e puni-la unicamente no âmbito da esfera pública estatal.\n\nEstá correto o que se afirma em:'),
(8,'cc90-01','420c8c2f-6f80-422a-9e63-d64aace51465',97,90,'media','PAPIRO — DH-AUT-05 — cc90-01 — Caso Ximenes Lopes fatos',
 'A jurisprudência da Corte Interamericana de Direitos Humanos engloba sentenças essenciais envolvendo a responsabilização do Estado brasileiro. O Caso Ximenes Lopes vs. Brasil, cuja sentença foi proferida em 4 de julho de 2006, teve como fatos centrais de responsabilização internacional:'),
(9,'cc90-02','420c8c2f-6f80-422a-9e63-d64aace51465',97,90,'facil','PAPIRO — DH-AUT-05 — cc90-02 — Caso Ximenes Lopes primeira condenacao',
 'O desenvolvimento da responsabilidade internacional do Brasil no âmbito da Organização dos Estados Americanos possui marcos institucionais relevantes em relação aos órgãos do continente. O Caso Ximenes Lopes vs. Brasil, julgado em 2006, é historicamente reconhecido por representar a:'),
(10,'cc90-03','420c8c2f-6f80-422a-9e63-d64aace51465',97,90,'dificil','PAPIRO — DH-AUT-05 — cc90-03 — Caso Gomes Lund Lei de Anistia',
 E'No julgamento do Caso Gomes Lund e outros ("Guerrilha do Araguaia") vs. Brasil, cuja sentença foi proferida em 24 de novembro de 2010, a Corte Interamericana de Direitos Humanos debruçou-se sobre a aplicação de normativas de direito interno. Na referida sentença internacional, a Corte deliberou especificamente sobre os efeitos jurídicos da Lei de Anistia (Lei nº 6.683/1979), assentando que:'),
(11,'cc90-04','420c8c2f-6f80-422a-9e63-d64aace51465',97,90,'dificil','PAPIRO — DH-AUT-05 — cc90-04 — Caso Gomes Lund competencia ratione temporis',
 E'O Estado brasileiro reconheceu a competência contenciosa da Corte Interamericana unicamente para fatos posteriores a 10 de dezembro de 1998. Contudo, no julgamento do Caso Gomes Lund ("Guerrilha do Araguaia"), os desaparecimentos das vítimas iniciaram-se ainda na década de 1970. No tocante à competência ratione temporis e aos marcos fáticos analisados nessa sentença de 2010, constata-se que a Corte:'),
(12,'cc90-05','420c8c2f-6f80-422a-9e63-d64aace51465',97,90,'media','PAPIRO — DH-AUT-05 — cc90-05 — Caso Herzog fatos',
 'O Caso Herzog e outros vs. Brasil, julgado e sentenciado pela Corte Interamericana de Direitos Humanos em 15 de março de 2018, expôs à comunidade internacional episódios violentos ocorridos no ano de 1975. O núcleo fático levado ao escrutínio da referida Corte que ensejou a responsabilização do Estado brasileiro envolveu a:'),
(13,'cc90-06','420c8c2f-6f80-422a-9e63-d64aace51465',97,90,'dificil','PAPIRO — DH-AUT-05 — cc90-06 — Caso Herzog crime contra a humanidade',
 'No texto sentencial do Caso Herzog e outros vs. Brasil (2018), a Corte Interamericana de Direitos Humanos delineou a natureza jurídica das violações sofridas pela vítima, impondo fortes restrições às teses de defesa estatais. A decisão determinou que as condutas perpetradas contra Vladimir Herzog estavam inseridas num contexto de:'),
(14,'cc90-07','420c8c2f-6f80-422a-9e63-d64aace51465',97,90,'media','PAPIRO — DH-AUT-05 — cc90-07 — tres casos combinados assertivas',
 E'A consolidação da jurisprudência da Corte Interamericana de Direitos Humanos que condenou o Estado brasileiro envolveu contextos díspares. Relacionando as decisões emblemáticas proferidas pela Corte, analise as assertivas a seguir:\n\nI. O Caso Ximenes Lopes representou a primeira condenação proferida contra o Estado brasileiro pela Corte IDH, debatendo condutas de maus-tratos, condições degradantes e morte em uma instituição de tratamento psiquiátrico.\nII. O Caso Gomes Lund e outros expôs fatos da Guerrilha do Araguaia e resultou no entendimento do tribunal de que as disposições da Lei de Anistia brasileira que impedem a investigação de graves violações de direitos humanos não podem produzir efeitos jurídicos.\nIII. O Caso Herzog e outros tratou da tortura e morte do jornalista no DOI-CODI; no entanto, a condenação foi afastada pela Corte por entender lícita a alegação brasileira de prescrição e de ne bis in idem.\n\nEstá correto o que se afirma em:'),
(15,'cc91-01','fec87f6c-c735-46f1-8bd1-7bbaf6f56e93',91,91,'media','PAPIRO — DH-AUT-05 — cc91-01 — Protocolo de Assuncao 2005 art.1',
 'O artigo 1º do Protocolo de Assunção sobre Compromisso com a Promoção e Proteção dos Direitos Humanos do Mercosul, adotado em 2005, prevê expressamente requisitos essenciais para a vigência e evolução do processo de integração. Trata-se do atendimento à:'),
(16,'cc91-02','fec87f6c-c735-46f1-8bd1-7bbaf6f56e93',91,91,'media','PAPIRO — DH-AUT-05 — cc91-02 — RAADH x IPPDH natureza institucional',
 'O Mercosul criou e consolidou instituições próprias para coordenar a temática dos direitos humanos na região. No que diz respeito aos órgãos de destaque, a Reunião de Altas Autoridades sobre Direitos Humanos (RAADH) e o Instituto de Políticas Públicas em Direitos Humanos (IPPDH) diferenciam-se essencialmente em sua natureza institucional, na medida em que a RAADH constitui:'),
(17,'cc91-03','fec87f6c-c735-46f1-8bd1-7bbaf6f56e93',91,91,'media','PAPIRO — DH-AUT-05 — cc91-03 — Ushuaia x Assuncao DH objeto',
 'O Mercosul expandiu seu corpo normativo para abrigar premissas e valores além da pauta comercial. Dentre os diplomas que impulsionaram as esferas institucionais e humanitárias, verifica-se uma distinção de objeto central entre dois pactos essenciais para a integração sociopolítica regional, firmando-se corretamente que o:'),
(18,'cc91-04','fec87f6c-c735-46f1-8bd1-7bbaf6f56e93',91,91,'facil','PAPIRO — DH-AUT-05 — cc91-04 — RAADH origem Decisao CMC 40/04',
 'O arranjo intergovernamental do Mercosul ganhou importante foro para a articulação de autoridades e elaboração de agendas conjuntas em matérias relativas às garantias fundamentais. A Reunião de Altas Autoridades sobre Direitos Humanos (RAADH) foi criada originariamente na estrutura do bloco através da:'),
(19,'cc91-05','fec87f6c-c735-46f1-8bd1-7bbaf6f56e93',91,91,'facil','PAPIRO — DH-AUT-05 — cc91-05 — IPPDH origem Decisao CMC 14/09',
 'Com o fito de promover e assegurar o aporte de pesquisas, articulação regional e assessoramento direto, a coordenação do Mercosul estabeleceu um instituto especializado em pesquisa, articulação regional e assessoramento técnico em direitos humanos. A criação do Instituto de Políticas Públicas em Direitos Humanos (IPPDH) foi formalizada mediante a:'),
(20,'cc91-06','fec87f6c-c735-46f1-8bd1-7bbaf6f56e93',91,91,'media','PAPIRO — DH-AUT-05 — cc91-06 — evolucao historica 1991-1998-2005',
 'O Mercosul registrou, ao longo de sua história, marcos institucionais que ampliaram seu escopo original de integração comercial e aduaneira para absorver também compromissos relacionados à democracia e aos direitos humanos. Entre os marcos institucionais desse processo, podem ser associados cronologicamente:'),
(21,'cc91-07','fec87f6c-c735-46f1-8bd1-7bbaf6f56e93',91,91,'dificil','PAPIRO — DH-AUT-05 — cc91-07 — assertivas integradas art.1+RAADH+IPPDH+historico',
 E'A promoção dos direitos humanos tornou-se matéria relevante da agenda e do ordenamento institucional do Mercado Comum do Sul (Mercosul). Com base nos instrumentos e marcos institucionais do MERCOSUL, julgue as seguintes assertivas:\n\nI. O artigo 1º do Protocolo de Assunção (2005) dispõe expressamente que a plena vigência das instituições democráticas, assim como o respeito aos direitos humanos e às liberdades fundamentais, constituem condições essenciais para a vigência e evolução do processo de integração.\nII. A consolidação dos valores no bloco indica uma evolução em estágios, partindo da forte orientação mercadológica e econômica no Tratado de Assunção de 1991, absorvendo expressamente o compromisso democrático em 1998 (Ushuaia) e o compromisso voltado à promoção dos direitos humanos em 2005.\nIII. A RAADH, criada pela Decisão CMC nº 40/04, constitui um foro de reuniões entre autoridades governamentais, ao passo que o IPPDH, criado pela Decisão CMC nº 14/09, constitui um instituto técnico voltado ao apoio à formulação de políticas públicas em direitos humanos.\n\nEstá correto o que se afirma em:');

create temporary table _lote_explicacoes (ordem int primary key, explicacao text) on commit drop;
insert into _lote_explicacoes (ordem, explicacao) values
(1, E'A alternativa C reflete a exigência do artigo 1º da Convenção de Belém do Pará, que estipula que a violência contra a mulher abrange qualquer ato ou conduta "baseada no gênero" — elemento definidor central do tratado. As demais alternativas inserem requisitos não previstos na definição normativa, como motivação patrimonial (A), restrição à autoria estatal (B), uso de arma (D) ou base racial (E).'),
(2, E'A alternativa A reproduz o rol de resultados do art. 1º: "qualquer ato ou conduta baseada no gênero, que cause morte, dano ou sofrimento físico, sexual ou psicológico à mulher". As demais restringem indevidamente a proteção: excluem danos psicológicos (C), exigem sequela permanente (B), restringem ao âmbito público (D) ou reduzem a prejuízos patrimoniais e atos estatais (E).'),
(3, E'A alternativa E apresenta os qualificadores corretos do caput do art. 7º: "convêm em adotar, por todos os meios apropriados e sem demora, políticas destinadas a prevenir, punir e erradicar a referida violência". As demais criam exceções e condições inexistentes na Convenção: cláusula orçamentária (A), penas exclusivas de prisão (B), prazos/restrição federativa (C) ou suspensão da exigibilidade imediata até a adaptação da legislação interna (D) — a obrigação deve ser cumprida sem demora, independentemente do estágio de adaptação normativa doméstica.'),
(4, E'A alternativa B reproduz a redação inicial do caput do art. 7º: "Os Estados Partes condenam todas as formas de violência contra a mulher...". Essa condenação é ampla e incondicional, sem as restrições indevidas presentes nas demais alternativas: limitação à autoria estatal (A), restrição à esfera pública (C), exigência de dano físico comprovado (D) ou condicionamento a prévia tipificação penal interna (E).'),
(5, E'A alternativa D está correta por identificar os elementos da definição convencional do art. 1º presentes no caso: (1) conduta baseada no gênero ("obedecer pela condição de mulher"); (2) resultado de sofrimento psicológico atestado por perícia. O fato de a conduta ter ocorrido inteiramente na esfera privada não afasta a incidência da definição, pois o art. 1º abrange expressamente condutas ocorridas "tanto na esfera pública como na privada" — trata-se do alcance da definição, não de um terceiro requisito a ser comprovado. As alternativas A e E exigem, indevidamente, dano físico ou equiparação hierárquica do sofrimento psicológico ao dano físico; a B exige indevidamente reiteração sistemática da conduta; a C afirma falsamente que a Convenção se restringe ao ambiente público.'),
(6, E'A alternativa A demonstra o alcance pleno da Convenção. O art. 1º define que a violência abrange condutas "tanto na esfera pública como na privada"; o dever estatal do caput do art. 7º incide sobre toda a extensão dessa definição. As alternativas B e C restringem indevidamente o alcance subjetivo/material da norma; a D restringe indevidamente o conteúdo do dever estatal, que não se limita à esfera legislativa, mas abrange também prevenção e punição; a E acrescenta uma condição de notoriedade pública inexistente no tratado.'),
(7, E'A assertiva I está correta (art. 1º). A assertiva II está correta (art. 1º, elemento de gênero). A assertiva III está incorreta: ao aludir ao art. 7º, caput, insere restrição inexistente, afirmando que a prevenção e punição incidem "unicamente no âmbito da esfera pública estatal", quando a proteção abrange tanto a esfera pública quanto a privada. Logo, o gabarito é B.'),
(8, E'A alternativa D aponta os fatos nucleares do Caso Ximenes Lopes vs. Brasil (2006): a morte de Damião Ximenes Lopes devido a maus-tratos e condições degradantes durante internação em instituição psiquiátrica conveniada ao SUS, no Ceará. As demais alternativas descrevem cenários que não correspondem a esse caso: desaparecimento de guerrilheiros na Amazônia (A), tortura e morte de jornalista em dependências militares (B), rebeliões em presídios superlotados (C) e desocupação forçada de povos indígenas para construção de hidrelétricas (E).'),
(9, E'O Caso Ximenes Lopes (2006) foi a primeira sentença de condenação exarada contra o Estado brasileiro pela Corte IDH. As demais alternativas confundem o marco histórico com outros institutos: litígios interestatais inexistentes para o Brasil (A), medidas cautelares (B), ou petições/controle de emendas perante fóruns da ONU (D, E), que não guardam pertinência com a relevância do caso.'),
(10, E'A alternativa B reflete o entendimento da condenação no Caso Gomes Lund. A Corte determinou que "as disposições da Lei de Anistia brasileira que impedem a investigação e sanção de graves violações de direitos humanos são incompatíveis com a Convenção Americana, carecem de efeitos jurídicos e não podem seguir representando um obstáculo para a investigação dos fatos". As alternativas A e C afirmam o oposto; a D inventa uma permuta cível-penal inexistente; a E afirma incorretamente que a Corte não examinou a Lei de Anistia, quando este foi um dos pontos centrais da sentença.'),
(11, E'A Corte IDH manteve o respeito ao marco de 10/12/1998 estipulado pelo Brasil, não reconhecendo competência para fatos integralmente consumados antes dessa data. Contudo, admitiu examinar a situação de desaparecimento forçado justamente porque essa violação, por sua natureza, tem caráter permanente ou continuado — persistindo enquanto a pessoa desaparecida não for localizada. Como a situação de desaparecimento das vítimas permanecia após 10/12/1998, essa violação continuada estava sob a competência temporal da Corte nesse período. As alternativas A e D sugerem falsa retroatividade irrestrita; a B rejeita indevidamente a competência da Corte; a C inventa uma renúncia estatal que não ocorreu.'),
(12, E'A alternativa A descreve os fatos centrais do Caso Herzog: a detenção, a tortura e a morte do jornalista Vladimir Herzog em 1975, no interior das dependências do Destacamento de Operações de Informação – Centro de Operações de Defesa Interna (DOI-CODI), em São Paulo. A alternativa B relaciona-se ao contexto da Guerrilha do Araguaia, tema do Caso Gomes Lund. A alternativa D descreve um cenário de maus-tratos em instituição de saúde mental, aproximando-se dos fatos do Caso Ximenes Lopes. As alternativas C e E descrevem cenários que simplesmente não correspondem aos fatos do Caso Herzog.'),
(13, E'A alternativa D está de acordo com os fundamentos da sentença do Caso Herzog (2018). A Corte considerou que o homicídio e a tortura de Herzog se inseriram em contexto de ataque sistemático contra a população civil promovido pelo aparato estatal durante a ditadura militar, qualificando os fatos como crime contra a humanidade para fins de responsabilização internacional do Estado. Em decorrência dessa qualificação, concluiu que o Brasil não poderia invocar a Lei de Anistia, a prescrição, o ne bis in idem ou obstáculos equivalentes para se eximir do dever de investigar e punir os responsáveis. As demais alternativas requalificam indevidamente os fatos e admitem a validade de obstáculos que a Corte rejeitou.'),
(14, E'A assertiva I está correta, associando o marco histórico ao fato central do Caso Ximenes Lopes (2006). A assertiva II está correta, associando o Caso Gomes Lund (2010) à incompatibilidade das disposições da Lei de Anistia que impedem a investigação e punição de graves violações. A assertiva III é falsa: a Corte, no Caso Herzog (2018), não afastou a condenação e concluiu exatamente o contrário — o Estado não poderia invocar prescrição nem ne bis in idem, por se tratar de crime contra a humanidade. Como apenas I e II estão corretas, o gabarito é C.'),
(15, E'A alternativa A reproduz o art. 1º do Protocolo de Assunção de 2005: "A plena vigência das instituições democráticas e o respeito dos direitos humanos e das liberdades fundamentais são condições essenciais para a vigência e evolução do processo de integração entre as Partes." As demais alternativas substituem esse conteúdo por elementos de integração comercial ou institucional do bloco — uniformização eleitoral e poder de veto parlamentar (B), padronização normativa e tarifária (C), mecanismos eleitorais e cotas partidárias (D) ou livre circulação econômica (E) — nenhum dos quais corresponde ao teor do art. 1º.'),
(16, E'A alternativa E expressa a dualidade correta: a RAADH é um foro de diálogo e coordenação política intergovernamental; o IPPDH é uma instância técnica voltada à pesquisa, assistência técnica e coordenação no desenho de políticas públicas em direitos humanos. As demais alternativas invertem essa distribuição de papéis (A), atribuem a ambos os órgãos uma natureza exclusivamente política (B) ou exclusivamente técnica (C), ou confundem as funções de formulação, aprovação e referendo das políticas entre os dois órgãos (D).'),
(17, E'A alternativa C reflete corretamente o objeto central de cada norma. O Protocolo de Ushuaia (1998) celebrizou a "cláusula democrática" entre os Estados Partes; o Protocolo de Assunção (2005) firmou o compromisso específico com a promoção e proteção dos direitos humanos. As demais alternativas invertem os objetos dos dois Protocolos (A), confundem o Protocolo de Ushuaia com o conteúdo econômico do Tratado de Assunção de 1991 (B), trocam as datas atribuídas a cada instrumento (D) ou combinam uma data incorreta com um objeto igualmente incorreto (E).'),
(18, E'A alternativa D aponta a origem correta: a RAADH foi criada pela Decisão do Conselho do Mercado Comum (CMC) nº 40, de 2004. As demais alternativas atribuem a criação da RAADH a outros atos reais do ecossistema MERCOSUL, mas que não correspondem à sua origem: a Decisão CMC nº 14/09, que criou o IPPDH (A); uma resolução de órgão hierarquicamente inferior ao CMC (B); o Protocolo de Ushuaia de 1998, sobre compromisso democrático (C); e o Protocolo de Assunção sobre Direitos Humanos de 2005, posterior à criação da RAADH (E).'),
(19, E'A alternativa B é exata: o IPPDH foi criado pela Decisão do Conselho do Mercado Comum (CMC) nº 14/09, no ano de 2009. A alternativa A desloca a fundação erroneamente para a gênese econômica de 1991; a C atribui ao IPPDH a Decisão CMC nº 40/04, que na verdade criou a RAADH; a D e a E atribuem a criação do IPPDH a instrumentos reais do Mercosul (Protocolo de Ushuaia e Protocolo de Assunção sobre Direitos Humanos) que não correspondem ao ato específico de sua fundação.'),
(20, E'A alternativa A associa corretamente os marcos institucionais em sua sequência cronológica: o Tratado de Assunção (1991), voltado à integração econômica e aduaneira; o Protocolo de Ushuaia (1998), que incorporou o compromisso democrático ao arcabouço do bloco; e o Protocolo de Assunção sobre Direitos Humanos (2005), que estabeleceu o compromisso específico com a promoção e proteção dos direitos humanos. Essa sequência não significa que direitos humanos ou preocupações sociais inexistissem antes de 2005 nos ordenamentos internos dos Estados-Partes — apenas que o bloco regional passou a incorporá-los formalmente em sua arquitetura institucional ao longo do tempo. As demais alternativas invertem ou trocam as datas e os temas atribuídos a cada instrumento.'),
(21, E'A assertiva I reproduz corretamente a condição do art. 1º do Protocolo de Assunção sobre DH, incluindo a dupla exigência de vigência e evolução do processo de integração. A assertiva II descreve corretamente o percurso histórico do Mercosul, com as datas e a natureza de cada um dos três instrumentos (1991 – econômico; 1998 – compromisso democrático; 2005 – direitos humanos). A assertiva III distingue corretamente a natureza institucional e os atos de criação da RAADH (Decisão CMC nº 40/04) e do IPPDH (Decisão CMC nº 14/09). Estando as três corretas, a alternativa correta é E.');

create temporary table _lote_alternativas (
  ordem int,
  ordem_alt smallint,
  texto text,
  correta boolean
) on commit drop;

insert into _lote_alternativas (ordem, ordem_alt, texto, correta) values
(1,1,'motivada por disputa patrimonial na esfera doméstica.',false),
(1,2,'perpetrada exclusivamente por agente de Estado no exercício de suas funções.',false),
(1,3,'baseada no gênero.',true),
(1,4,'praticada com emprego de arma de fogo ou assemelhado.',false),
(1,5,'resultante de discriminação racial ou étnica explícita.',false),

(2,1,'morte, o dano ou o sofrimento físico, sexual ou psicológico.',true),
(2,2,'lesão corporal exclusivamente com sequela física permanente.',false),
(2,3,'morte ou a tortura física, excluídos do diploma os danos puramente psicológicos.',false),
(2,4,'dor física ou a privação de liberdade, desde que ocorridas na esfera pública.',false),
(2,5,'perda patrimonial ou o sofrimento moral restritos aos atos estatais.',false),

(3,1,'de maneira progressiva, condicionados estritamente à disponibilidade orçamentária do momento.',false),
(3,2,'exclusivamente por meio de sanções penais de caráter privativo de liberdade.',false),
(3,3,'em prazo razoável, priorizando a adequação legislativa apenas nas esferas federais.',false),
(3,4,'somente após a conclusão do processo de adaptação da legislação interna ao tratado, afastando-se o dever de atuação imediata previsto no artigo.',false),
(3,5,'por todos os meios apropriados e sem demora.',true),

(4,1,'condenam a violência apenas quando praticada ou tolerada por agentes do Estado no exercício de suas funções.',false),
(4,2,'condenam todas as formas de violência contra a mulher.',true),
(4,3,'condenam exclusivamente a violência ocorrida no âmbito da esfera pública, excluindo o espaço doméstico.',false),
(4,4,'condenam a violência somente quando dela resulte dano físico comprovado, excluindo o sofrimento psicológico.',false),
(4,5,'condenam a violência na medida em que a conduta já esteja previamente tipificada como crime pela legislação penal interna do Estado.',false),

(5,1,'não configura violência nos termos da Convenção, visto que é exigida a ocorrência de agressão ou dano físico visível.',false),
(5,2,'não configura violência baseada no gênero, pois a conduta decorreu de um conflito pontual entre o casal, sem relação com uma prática reiterada e sistemática de discriminação.',false),
(5,3,'não se amolda ao conceito convencional, pois a proteção do tratado restringe-se aos atos cometidos ou tolerados pelo Estado na esfera pública.',false),
(5,4,'configura violência contra a mulher, pois consistiu em conduta baseada no gênero, que resultou em sofrimento psicológico, sendo irrelevante ter ocorrido na esfera privada.',true),
(5,5,'não configura violência nos termos da Convenção, pois o sofrimento psicológico, ainda que comprovado por perícia, não é juridicamente equiparado ao dano físico para fins de proteção.',false),

(6,1,'aplica-se independentemente de a violência ocorrer na esfera pública ou privada.',true),
(6,2,'restringe-se exclusivamente aos atos praticados ou tolerados por autoridades estatais em locais de acesso público.',false),
(6,3,'incide apenas nas relações interpessoais domésticas, excluindo o ambiente de trabalho e os espaços políticos.',false),
(6,4,'circunscreve-se ao dever de promover alterações legislativas, não abrangendo medidas de prevenção ou de punição direta dos agressores.',false),
(6,5,'atrai a responsabilidade do Estado somente se a vítima demonstrar que a agressão na esfera privada obteve repercussão pública notória.',false),

(7,1,'I, apenas.',false),
(7,2,'I e II, apenas.',true),
(7,3,'II e III, apenas.',false),
(7,4,'I e III, apenas.',false),
(7,5,'I, II e III.',false),

(8,1,'a ausência de investigação do desaparecimento de guerrilheiros durante as operações militares no interior da região amazônica.',false),
(8,2,'a tortura e a morte de um jornalista em dependências militares durante o regime de exceção no país.',false),
(8,3,'a falta de segurança em presídios superlotados que resultaram em rebeliões com mortes de adolescentes sob tutela do Estado.',false),
(8,4,'as condições degradantes, os maus-tratos e a morte de um paciente submetido a tratamento e internação em instituição psiquiátrica.',true),
(8,5,'a desocupação forçada de povos indígenas de suas terras tradicionais para a construção de usinas hidrelétricas.',false),

(9,1,'primeira vez que o Estado brasileiro atuou como demandante contra outro país sul-americano.',false),
(9,2,'primeira medida cautelar deferida a favor do país pela Comissão Interamericana.',false),
(9,3,'primeira condenação proferida contra o Estado brasileiro pela Corte Interamericana de Direitos Humanos.',true),
(9,4,'primeira petição internacional formalmente enviada pelo Brasil perante fóruns de tribunais penais da ONU.',false),
(9,5,'primeira decisão em que a Corte Interamericana declarou a inconstitucionalidade de uma emenda brasileira.',false),

(10,1,'a Lei de Anistia brasileira possui validade convencional absoluta, resguardando o país de qualquer dever de investigação perante o sistema interamericano.',false),
(10,2,'as disposições ou interpretações da referida lei que impeçam a investigação e a punição de graves violações de direitos humanos são incompatíveis com a Convenção Americana e não podem produzir esse efeito jurídico.',true),
(10,3,'a aplicação da referida norma anistiadora foi um mecanismo legítimo e definitivo de justiça de transição chancelado pela Corte.',false),
(10,4,'as disposições da anistia são convencionalmente válidas desde que haja reparação financeira correspondente pelas instâncias cíveis, extinguindo-se a via penal.',false),
(10,5,'a Lei de Anistia não foi objeto de exame pela Corte, que se restringiu a analisar unicamente o dever genérico de indenizar as vítimas.',false),

(11,1,'declarou a retroatividade plena de sua competência para abranger qualquer conduta estatal no Brasil desde o ano de 1969, anulando o limite temporal.',false),
(11,2,'extinguiu o processo sem resolução de mérito, uma vez que todos os fatos atinentes aos desaparecimentos se consumaram antes de 1998.',false),
(11,3,'processou o caso sob o entendimento de que o Brasil autorizou a supressão do limite de 1998 expressamente durante a instrução processual do caso.',false),
(11,4,'considerou que os direitos humanos possuem índole supra-histórica, de modo que todo dever de investigar gera competência retroativa ilimitada ao tribunal.',false),
(11,5,'pôde examinar os desaparecimentos forçados porque a situação permanecia depois de 10 de dezembro de 1998, em razão do caráter permanente ou continuado dessa violação, preservando a irretroatividade quanto a situações já consumadas.',true),

(12,1,'detenção, tortura e morte do jornalista Vladimir Herzog nas dependências do DOI-CODI.',true),
(12,2,'expedição de ordens de expulsão sumária de grupos camponeses durante a Guerrilha do Araguaia.',false),
(12,3,'morte por asfixia de dezenas de detentos em uma penitenciária sob gestão estadual, devido à superlotação.',false),
(12,4,'aplicação de maus-tratos sistêmicos a pacientes mantidos em isolamento em instituições de saúde mental do interior do Ceará.',false),
(12,5,'paralisação na demarcação de terras, gerando conflitos armados com vítimas fatais nas comunidades quilombolas do nordeste.',false),

(13,1,'crimes de guerra, pelo que caberia ao Estado brasileiro alegar a prescrição regulamentada pela Convenção de Genebra de 1949.',false),
(13,2,'delitos comuns de homicídio, de modo que o princípio do ne bis in idem impedia a reabertura de processos antes arquivados pela justiça militar.',false),
(13,3,'crimes de responsabilidade política, autorizando-se o emprego da lei de anistia por se tratar de infração ideológica de caráter perdoável no regime democrático.',false),
(13,4,'crime contra a humanidade, motivo pelo qual o Estado não poderia invocar anistia, prescrição, ne bis in idem ou obstáculos equivalentes para afastar o dever de investigar e punir os responsáveis.',true),
(13,5,'infrações disciplinares militares graves, exigindo do Estado o encerramento da via penal para promover puramente a indenização patrimonial internacional aos herdeiros.',false),

(14,1,'I, apenas.',false),
(14,2,'II e III, apenas.',false),
(14,3,'I e II, apenas.',true),
(14,4,'III, apenas.',false),
(14,5,'I, II e III.',false),

(15,1,'plena vigência das instituições democráticas, do respeito aos direitos humanos e do respeito às liberdades fundamentais.',true),
(15,2,'unificação obrigatória dos sistemas eleitorais nacionais, associada à criação de um parlamento com poder de veto sobre leis internas dos Estados-Partes.',false),
(15,3,'padronização dos códigos civis e penais, associada à uniformização tarifária externa comum.',false),
(15,4,'eleição direta para o Parlamento do Mercosul, juntamente com a fixação de cotas obrigatórias de representação partidária.',false),
(15,5,'livre circulação de bens, serviços e fatores produtivos entre os Estados-Partes, como condição essencial para a vigência e evolução do processo de integração.',false),

(16,1,'um instituto técnico de pesquisa e assessoramento em políticas públicas, ao passo que o IPPDH constitui o foro de reunião de autoridades governamentais do bloco.',false),
(16,2,'um foro de negociação política entre chanceleres, assim como o IPPDH também opera como espaço de reunião política entre autoridades governamentais, sem funções técnicas próprias.',false),
(16,3,'uma instância técnica de elaboração de estudos e diagnósticos, da mesma forma que o IPPDH atua exclusivamente como órgão técnico de pesquisa, sem qualquer função de articulação política entre os governos.',false),
(16,4,'o órgão que formula e aprova diretamente as políticas públicas de direitos humanos dos Estados-Partes, enquanto o IPPDH apenas referenda formalmente essas decisões em reuniões periódicas.',false),
(16,5,'um foro e reunião de representantes e autoridades governamentais, enquanto o IPPDH atua como um instituto focado no apoio técnico para a formulação de políticas públicas do bloco.',true),

(17,1,'Protocolo de Ushuaia (1998) firmou o compromisso específico com a promoção e proteção dos direitos humanos, ao passo que o Protocolo de Assunção (2005) estabeleceu a cláusula democrática do bloco.',false),
(17,2,'Protocolo de Ushuaia (1998) consolidou a integração econômica e aduaneira iniciada pelo Tratado de Assunção de 1991, enquanto o Protocolo de Assunção de 2005 reafirmou exclusivamente essa mesma pauta comercial.',false),
(17,3,'Protocolo de Ushuaia (1998) formalizou o compromisso democrático no bloco, ao passo que o Protocolo de Assunção (2005) firmou um compromisso voltado de maneira específica com a promoção e proteção dos direitos humanos.',true),
(17,4,'Protocolo de Ushuaia, de 2005, formalizou o compromisso democrático, enquanto o Protocolo de Assunção sobre Direitos Humanos, de 1998, tratou da promoção e proteção dos direitos humanos.',false),
(17,5,'Protocolo de Ushuaia (1998) tratou da promoção e proteção dos direitos humanos, enquanto o Protocolo de Assunção sobre Direitos Humanos foi concluído apenas em 2010, ampliando o rol de direitos sociais do bloco.',false),

(18,1,'Decisão do Conselho do Mercado Comum (CMC) nº 14/09, expedida em 2009.',false),
(18,2,'Resolução do Grupo Mercado Comum (GMC), órgão executivo do bloco, sem posterior deliberação pelo Conselho do Mercado Comum (CMC).',false),
(18,3,'Protocolo de Ushuaia sobre Compromisso Democrático, de 1998.',false),
(18,4,'Decisão do Conselho do Mercado Comum (CMC) nº 40/04, expedida em 2004.',true),
(18,5,'Protocolo de Assunção sobre Compromisso com a Promoção e Proteção dos Direitos Humanos, de 2005.',false),

(19,1,'chancela e assinatura obrigatória do Tratado de Assunção original, ainda em 1991.',false),
(19,2,'Decisão do Conselho do Mercado Comum (CMC) nº 14/09, expedida em 2009.',true),
(19,3,'Decisão do Conselho do Mercado Comum (CMC) nº 40/04, expedida em 2004.',false),
(19,4,'Protocolo de Ushuaia sobre Compromisso Democrático, de 1998.',false),
(19,5,'Protocolo de Assunção sobre Compromisso com a Promoção e Proteção dos Direitos Humanos, de 2005.',false),

(20,1,'a origem da integração econômica pelo Tratado de Assunção (1991), seguida da incorporação institucional do compromisso democrático pelo Protocolo de Ushuaia (1998) e da afirmação do compromisso específico com a promoção e proteção de direitos humanos por meio do Protocolo de Assunção (2005).',true),
(20,2,'o compromisso democrático estabelecido já em 1991 pelo Tratado de Assunção, seguido da integração econômica plena em 1998 pelo Protocolo de Ushuaia, culminando na criação da União Aduaneira em 2005.',false),
(20,3,'a integração econômica e aduaneira instituída em 1998 pelo Protocolo de Ushuaia, seguida do compromisso democrático em 2005 pelo Protocolo de Assunção, sem qualquer instrumento anterior a 1998.',false),
(20,4,'o compromisso com os direitos humanos estabelecido originalmente em 1991 pelo Tratado de Assunção, seguido da integração econômica em 1998 e do compromisso democrático apenas em 2005.',false),
(20,5,'a integração econômica pelo Tratado de Assunção em 1991, seguida diretamente do compromisso com os direitos humanos em 1998, sem que houvesse cláusula democrática autônoma no bloco.',false),

(21,1,'I e II, apenas.',false),
(21,2,'II e III, apenas.',false),
(21,3,'I, apenas.',false),
(21,4,'III, apenas.',false),
(21,5,'I, II e III.',true);

-- Precondicoes.
do $$
declare
  v_cnt int;
  v_dup int;
begin
  select count(*) into v_cnt from _lote_questoes;
  if v_cnt <> 21 then
    raise exception 'Precondicao falhou: staging tem % questoes (esperado 21)', v_cnt;
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

  if (select count(*) from _lote_questoes where cc_id=89) <> 7 then raise exception 'Precondicao falhou: staging cc89 <> 7'; end if;
  if (select count(*) from _lote_questoes where cc_id=90) <> 7 then raise exception 'Precondicao falhou: staging cc90 <> 7'; end if;
  if (select count(*) from _lote_questoes where cc_id=91) <> 7 then raise exception 'Precondicao falhou: staging cc91 <> 7'; end if;

  if (select cc89_uteis from _snapshot_antes) <> 3 then raise exception 'Precondicao falhou: cc89_uteis=% (esperado 3)', (select cc89_uteis from _snapshot_antes); end if;
  if (select cc90_uteis from _snapshot_antes) <> 3 then raise exception 'Precondicao falhou: cc90_uteis=% (esperado 3)', (select cc90_uteis from _snapshot_antes); end if;
  if (select cc91_uteis from _snapshot_antes) <> 3 then raise exception 'Precondicao falhou: cc91_uteis=% (esperado 3)', (select cc91_uteis from _snapshot_antes); end if;

  if (select q147_hash from _snapshot_antes) <> 'b0c2c84e52e2ca7bdcbed957467fda6e' then
    raise exception 'Precondicao falhou: Q147 explicacao divergiu do estado saneado esperado';
  end if;
  if (select q148_hash from _snapshot_antes) <> '7ac4306a25cc846e97c80a4215a553fa' then
    raise exception 'Precondicao falhou: Q148 explicacao divergiu do estado saneado esperado';
  end if;
  if (select q149_hash from _snapshot_antes) <> 'd8dd965a249edbdd3f74e72919ed1fba' then
    raise exception 'Precondicao falhou: Q149 explicacao divergiu do estado saneado esperado';
  end if;
end $$;

-- Insercao das questoes + alternativas.
create temporary table _mapa_ids (ordem int primary key, questao_id bigint) on commit drop;

do $$
declare r record; v_id bigint;
begin
  for r in select * from _lote_questoes order by ordem loop
    insert into public.questoes (materia_id, assunto_id, banca, concurso, ano, enunciado, dificuldade, explicacao, fonte, ativa, gerada_por_ia)
    values (11, r.assunto_id, 'Papiro', 'PAPIRO - Curadoria DH-AUT-05 - BM RS', 2026, r.enunciado, r.dificuldade,
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
  v_cc89_uteis int; v_cc90_uteis int; v_cc91_uteis int;
  v_cc89_real int; v_cc90_real int; v_cc91_real int;
  v_dh_uteis_depois int;
  v_q147_hash text; v_q148_hash text; v_q149_hash text;
begin
  select count(*) into v_novas_questoes from public.questoes where id in (select questao_id from _mapa_ids);
  if v_novas_questoes <> 21 then
    raise exception 'Pos-condicao falhou: questoes novas=% (esperado 21)', v_novas_questoes;
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
  if v_novas_alternativas <> 105 then
    raise exception 'Pos-condicao falhou: alternativas novas=% (esperado 105 = 21x5)', v_novas_alternativas;
  end if;

  select count(*) into v_corretas_invalidas
  from (select questao_id, count(*) filter (where correta) as n from public.alternativas where questao_id in (select questao_id from _mapa_ids) group by questao_id having count(*) filter (where correta) <> 1) x;
  if v_corretas_invalidas <> 0 then
    raise exception 'Pos-condicao falhou: % questao(oes) sem exatamente 1 alternativa correta', v_corretas_invalidas;
  end if;

  select count(*) into v_facil from public.questoes where id in (select questao_id from _mapa_ids) and dificuldade='facil';
  select count(*) into v_media from public.questoes where id in (select questao_id from _mapa_ids) and dificuldade='media';
  select count(*) into v_dificil from public.questoes where id in (select questao_id from _mapa_ids) and dificuldade='dificil';
  if v_facil <> 5 or v_media <> 10 or v_dificil <> 6 then
    raise exception 'Pos-condicao falhou: distribuicao dificuldade facil=%/media=%/dificil=% (esperado 5/10/6)', v_facil, v_media, v_dificil;
  end if;

  select count(*) into v_A from public.alternativas a join _mapa_ids m on a.questao_id=m.questao_id where a.correta and a.ordem=1;
  select count(*) into v_B from public.alternativas a join _mapa_ids m on a.questao_id=m.questao_id where a.correta and a.ordem=2;
  select count(*) into v_C from public.alternativas a join _mapa_ids m on a.questao_id=m.questao_id where a.correta and a.ordem=3;
  select count(*) into v_D from public.alternativas a join _mapa_ids m on a.questao_id=m.questao_id where a.correta and a.ordem=4;
  select count(*) into v_E from public.alternativas a join _mapa_ids m on a.questao_id=m.questao_id where a.correta and a.ordem=5;
  if v_A <> 5 or v_B <> 4 or v_C <> 4 or v_D <> 4 or v_E <> 4 then
    raise exception 'Pos-condicao falhou: gabaritos A=%/B=%/C=%/D=%/E=% (esperado 5/4/4/4/4)', v_A, v_B, v_C, v_D, v_E;
  end if;

  select count(*) into v_novos_vinculos from public.questao_unidades_pedagogicas where questao_id in (select questao_id from _mapa_ids);
  if v_novos_vinculos <> 21 then
    raise exception 'Pos-condicao falhou: vinculos novos=% (esperado 21)', v_novos_vinculos;
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

  select count(distinct qup.questao_id) into v_cc89_uteis from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id where up.curso_conteudo_id=89;
  select count(distinct qup.questao_id) into v_cc90_uteis from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id where up.curso_conteudo_id=90;
  select count(distinct qup.questao_id) into v_cc91_uteis from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id where up.curso_conteudo_id=91;

  if v_cc89_uteis <> (select cc89_uteis from _snapshot_antes) + 7 then raise exception 'Pos-condicao falhou: cc89_uteis=% (esperado %)', v_cc89_uteis, (select cc89_uteis from _snapshot_antes)+7; end if;
  if v_cc90_uteis <> (select cc90_uteis from _snapshot_antes) + 7 then raise exception 'Pos-condicao falhou: cc90_uteis=% (esperado %)', v_cc90_uteis, (select cc90_uteis from _snapshot_antes)+7; end if;
  if v_cc91_uteis <> (select cc91_uteis from _snapshot_antes) + 7 then raise exception 'Pos-condicao falhou: cc91_uteis=% (esperado %)', v_cc91_uteis, (select cc91_uteis from _snapshot_antes)+7; end if;

  if v_cc89_uteis <> 10 or v_cc90_uteis <> 10 or v_cc91_uteis <> 10 then
    raise exception 'Pos-condicao falhou: alguma unidade nao atingiu exatamente 10 uteis (cc89=%,cc90=%,cc91=%)', v_cc89_uteis, v_cc90_uteis, v_cc91_uteis;
  end if;

  select count(distinct qup.questao_id) into v_cc89_real from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id join public.questoes q on q.id=qup.questao_id where up.curso_conteudo_id=89 and coalesce(lower(q.banca),'') not like '%papiro%';
  select count(distinct qup.questao_id) into v_cc90_real from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id join public.questoes q on q.id=qup.questao_id where up.curso_conteudo_id=90 and coalesce(lower(q.banca),'') not like '%papiro%';
  select count(distinct qup.questao_id) into v_cc91_real from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id=qup.unidade_pedagogica_id join public.questoes q on q.id=qup.questao_id where up.curso_conteudo_id=91 and coalesce(lower(q.banca),'') not like '%papiro%';

  if v_cc89_real <> (select cc89_real from _snapshot_antes) or v_cc90_real <> (select cc90_real from _snapshot_antes)
     or v_cc91_real <> (select cc91_real from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: contagem REAL de alguma unidade mudou indevidamente (deveria permanecer inalterada, pois este lote e 100%% autoral)';
  end if;

  select count(distinct qup.questao_id) into v_dh_uteis_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.curso_conteudos cc on cc.id = up.curso_conteudo_id
    join public.assuntos a on a.id = cc.assunto_id
    where a.materia_id = 11;
  if v_dh_uteis_depois <> (select dh_uteis from _snapshot_antes) + 21 then
    raise exception 'Pos-condicao falhou: dh_uteis=% (esperado %)', v_dh_uteis_depois, (select dh_uteis from _snapshot_antes) + 21;
  end if;

  select md5(explicacao) into v_q147_hash from public.questoes where id = 147;
  select md5(explicacao) into v_q148_hash from public.questoes where id = 148;
  select md5(explicacao) into v_q149_hash from public.questoes where id = 149;
  if v_q147_hash <> (select q147_hash from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: Q147 explicacao foi alterada indevidamente por este lote';
  end if;
  if v_q148_hash <> (select q148_hash from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: Q148 explicacao foi alterada indevidamente por este lote';
  end if;
  if v_q149_hash <> (select q149_hash from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: Q149 explicacao foi alterada indevidamente por este lote';
  end if;

  if (select count(*) from public.questoes) <> (select total_questoes from _snapshot_antes) + 21 then
    raise exception 'Pos-condicao falhou: total de questoes nao cresceu exatamente 21';
  end if;
  if (select count(*) from public.alternativas) <> (select total_alternativas from _snapshot_antes) + 105 then
    raise exception 'Pos-condicao falhou: total de alternativas nao cresceu exatamente 105';
  end if;
  if (select count(*) from public.questao_unidades_pedagogicas) <> (select total_vinculos from _snapshot_antes) + 21 then
    raise exception 'Pos-condicao falhou: total de vinculos nao cresceu exatamente 21';
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

  raise notice 'Pos-condicoes OK: 21 questoes AUTORAL_PAPIRO novas / 105 alternativas / 21 vinculos / facil=% media=% dificil=% / gabaritos A=%,B=%,C=%,D=%,E=% / cc89..cc91 todas em 10 uteis / DH uteis %->%.',
    v_facil, v_media, v_dificil, v_A, v_B, v_C, v_D, v_E,
    (select dh_uteis from _snapshot_antes), v_dh_uteis_depois;
end $$;

commit;
