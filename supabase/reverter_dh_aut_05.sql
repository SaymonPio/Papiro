-- Reversao segura, POS-APPLY, do lote AUTORAL DH-AUT-05 de Direitos
-- Humanos e Cidadania (21 questoes AUTORAL_PAPIRO / 105 alternativas /
-- 21 vinculos, cc89/cc90/cc91).
--
-- NAO EXECUTAR agora. Este arquivo so devera ser usado se, no futuro,
-- for necessario desfazer o apply ja confirmado (commit) de
-- supabase/importar_dh_aut_05.sql.
--
-- Mecanismo de identificacao: as 21 questoes sao localizadas
-- exclusivamente pelo texto EXATO do enunciado (a mesma chave usada nas
-- precondicoes do apply para garantir idempotencia). NAO usa DELETE
-- amplo por materia_id, assunto_id, banca ou origem — atinge
-- exclusivamente as 21 linhas cujo enunciado bate com um dos textos
-- abaixo, respeitando a ordem de FKs (vinculo -> alternativas -> questao).
-- NAO toca em Q147/Q148/Q149 (pre-existentes, apenas com explicacao
-- saneada em rodada tecnica anterior) nem em qualquer outra questao.
--
-- Termina em COMMIT. So deve ser executado apos autorizacao humana
-- explicita, e apos novo teste_rollback proprio (nao incluido aqui,
-- pois este arquivo e de uso excepcional/pos-apply, nao parte do fluxo
-- normal de importacao).

begin;

set local request.jwt.claim.sub = 'e5523807-6cc8-4867-8a56-77c17552e56e';

create temporary table _dh_aut_05_enunciados (enunciado text) on commit drop;
insert into _dh_aut_05_enunciados (enunciado) values
('O artigo 1º da Convenção Interamericana para Prevenir, Punir e Erradicar a Violência contra a Mulher (Convenção de Belém do Pará) apresenta o conceito normativo de violência contra a mulher. Para que um ato ou conduta seja subsumido a essa definição convencional, o texto exige que a violência seja:'),
('Nos termos do artigo 1º da Convenção Interamericana para Prevenir, Punir e Erradicar a Violência contra a Mulher, a violência contra a mulher é compreendida como qualquer ato ou conduta que tenha como resultado a:'),
('O artigo 7º, caput, da Convenção de Belém do Pará estabelece diretrizes diretas para a atuação estatal. Ao assumirem o dever de adotar políticas destinadas a prevenir, punir e erradicar a violência contra a mulher, os Estados Partes convêm em implementar essa obrigação:'),
('A Convenção de Belém do Pará impõe deveres aos Estados Partes no enfrentamento à violência contra a mulher. Segundo dispõe expressamente a primeira oração normativa do artigo 7º, caput, do referido tratado, os Estados Partes:'),
('Uma mulher foi alvo de agressões verbais sistemáticas e ameaças proferidas por seu ex-parceiro, o qual afirmava que ela deveria obedecer-lhe simplesmente pela sua condição de mulher. O caso ocorreu inteiramente no interior da residência da vítima, não havendo contato físico. Perícia atestou que a conduta resultou em grave dano e sofrimento psicológico. Analisando a situação à luz da definição do artigo 1º da Convenção Interamericana para Prevenir, Punir e Erradicar a Violência contra a Mulher, constata-se que a referida conduta:'),
('A Convenção de Belém do Pará estabelece obrigações diretas aos Estados Partes, vinculando o conceito material da violência aos deveres de ação estatal. Considerando a conjugação sistemática entre o artigo 1º e o caput do artigo 7º do diploma, o dever de adotar políticas destinadas a prevenir, punir e erradicar a violência contra a mulher:'),
(E'Com base nas disposições da Convenção Interamericana para Prevenir, Punir e Erradicar a Violência contra a Mulher (Convenção de Belém do Pará), analise as seguintes assertivas:\n\nI. A definição convencional de violência contra a mulher engloba os atos ou as condutas que tenham como resultado a morte, o dano ou o sofrimento físico, sexual ou psicológico.\nII. Para que a violência se enquadre no escopo de proteção do tratado, é requisito normativo que a conduta seja baseada no gênero.\nIII. Os Estados Partes condenam todas as formas de violência contra a mulher e convêm em adotar políticas destinadas a preveni-la e puni-la unicamente no âmbito da esfera pública estatal.\n\nEstá correto o que se afirma em:'),
('A jurisprudência da Corte Interamericana de Direitos Humanos engloba sentenças essenciais envolvendo a responsabilização do Estado brasileiro. O Caso Ximenes Lopes vs. Brasil, cuja sentença foi proferida em 4 de julho de 2006, teve como fatos centrais de responsabilização internacional:'),
('O desenvolvimento da responsabilidade internacional do Brasil no âmbito da Organização dos Estados Americanos possui marcos institucionais relevantes em relação aos órgãos do continente. O Caso Ximenes Lopes vs. Brasil, julgado em 2006, é historicamente reconhecido por representar a:'),
(E'No julgamento do Caso Gomes Lund e outros ("Guerrilha do Araguaia") vs. Brasil, cuja sentença foi proferida em 24 de novembro de 2010, a Corte Interamericana de Direitos Humanos debruçou-se sobre a aplicação de normativas de direito interno. Na referida sentença internacional, a Corte deliberou especificamente sobre os efeitos jurídicos da Lei de Anistia (Lei nº 6.683/1979), assentando que:'),
(E'O Estado brasileiro reconheceu a competência contenciosa da Corte Interamericana unicamente para fatos posteriores a 10 de dezembro de 1998. Contudo, no julgamento do Caso Gomes Lund ("Guerrilha do Araguaia"), os desaparecimentos das vítimas iniciaram-se ainda na década de 1970. No tocante à competência ratione temporis e aos marcos fáticos analisados nessa sentença de 2010, constata-se que a Corte:'),
('O Caso Herzog e outros vs. Brasil, julgado e sentenciado pela Corte Interamericana de Direitos Humanos em 15 de março de 2018, expôs à comunidade internacional episódios violentos ocorridos no ano de 1975. O núcleo fático levado ao escrutínio da referida Corte que ensejou a responsabilização do Estado brasileiro envolveu a:'),
('No texto sentencial do Caso Herzog e outros vs. Brasil (2018), a Corte Interamericana de Direitos Humanos delineou a natureza jurídica das violações sofridas pela vítima, impondo fortes restrições às teses de defesa estatais. A decisão determinou que as condutas perpetradas contra Vladimir Herzog estavam inseridas num contexto de:'),
(E'A consolidação da jurisprudência da Corte Interamericana de Direitos Humanos que condenou o Estado brasileiro envolveu contextos díspares. Relacionando as decisões emblemáticas proferidas pela Corte, analise as assertivas a seguir:\n\nI. O Caso Ximenes Lopes representou a primeira condenação proferida contra o Estado brasileiro pela Corte IDH, debatendo condutas de maus-tratos, condições degradantes e morte em uma instituição de tratamento psiquiátrico.\nII. O Caso Gomes Lund e outros expôs fatos da Guerrilha do Araguaia e resultou no entendimento do tribunal de que as disposições da Lei de Anistia brasileira que impedem a investigação de graves violações de direitos humanos não podem produzir efeitos jurídicos.\nIII. O Caso Herzog e outros tratou da tortura e morte do jornalista no DOI-CODI; no entanto, a condenação foi afastada pela Corte por entender lícita a alegação brasileira de prescrição e de ne bis in idem.\n\nEstá correto o que se afirma em:'),
('O artigo 1º do Protocolo de Assunção sobre Compromisso com a Promoção e Proteção dos Direitos Humanos do Mercosul, adotado em 2005, prevê expressamente requisitos essenciais para a vigência e evolução do processo de integração. Trata-se do atendimento à:'),
('O Mercosul criou e consolidou instituições próprias para coordenar a temática dos direitos humanos na região. No que diz respeito aos órgãos de destaque, a Reunião de Altas Autoridades sobre Direitos Humanos (RAADH) e o Instituto de Políticas Públicas em Direitos Humanos (IPPDH) diferenciam-se essencialmente em sua natureza institucional, na medida em que a RAADH constitui:'),
('O Mercosul expandiu seu corpo normativo para abrigar premissas e valores além da pauta comercial. Dentre os diplomas que impulsionaram as esferas institucionais e humanitárias, verifica-se uma distinção de objeto central entre dois pactos essenciais para a integração sociopolítica regional, firmando-se corretamente que o:'),
('O arranjo intergovernamental do Mercosul ganhou importante foro para a articulação de autoridades e elaboração de agendas conjuntas em matérias relativas às garantias fundamentais. A Reunião de Altas Autoridades sobre Direitos Humanos (RAADH) foi criada originariamente na estrutura do bloco através da:'),
('Com o fito de promover e assegurar o aporte de pesquisas, articulação regional e assessoramento direto, a coordenação do Mercosul estabeleceu um instituto especializado em pesquisa, articulação regional e assessoramento técnico em direitos humanos. A criação do Instituto de Políticas Públicas em Direitos Humanos (IPPDH) foi formalizada mediante a:'),
('O Mercosul registrou, ao longo de sua história, marcos institucionais que ampliaram seu escopo original de integração comercial e aduaneira para absorver também compromissos relacionados à democracia e aos direitos humanos. Entre os marcos institucionais desse processo, podem ser associados cronologicamente:'),
(E'A promoção dos direitos humanos tornou-se matéria relevante da agenda e do ordenamento institucional do Mercado Comum do Sul (Mercosul). Com base nos instrumentos e marcos institucionais do MERCOSUL, julgue as seguintes assertivas:\n\nI. O artigo 1º do Protocolo de Assunção (2005) dispõe expressamente que a plena vigência das instituições democráticas, assim como o respeito aos direitos humanos e às liberdades fundamentais, constituem condições essenciais para a vigência e evolução do processo de integração.\nII. A consolidação dos valores no bloco indica uma evolução em estágios, partindo da forte orientação mercadológica e econômica no Tratado de Assunção de 1991, absorvendo expressamente o compromisso democrático em 1998 (Ushuaia) e o compromisso voltado à promoção dos direitos humanos em 2005.\nIII. A RAADH, criada pela Decisão CMC nº 40/04, constitui um foro de reuniões entre autoridades governamentais, ao passo que o IPPDH, criado pela Decisão CMC nº 14/09, constitui um instituto técnico voltado ao apoio à formulação de políticas públicas em direitos humanos.\n\nEstá correto o que se afirma em:');

do $$
declare
  v_cnt int;
begin
  select count(*) into v_cnt from public.questoes where enunciado in (select enunciado from _dh_aut_05_enunciados);
  if v_cnt <> 21 then
    raise exception 'Abortado: % questao(oes) encontrada(s) pelo criterio de enunciado exato (esperado exatamente 21) — nao reverter as cegas', v_cnt;
  end if;
end $$;

delete from public.questao_unidades_pedagogicas
where questao_id in (select id from public.questoes where enunciado in (select enunciado from _dh_aut_05_enunciados));

delete from public.alternativas
where questao_id in (select id from public.questoes where enunciado in (select enunciado from _dh_aut_05_enunciados));

delete from public.questoes
where enunciado in (select enunciado from _dh_aut_05_enunciados);

commit;
