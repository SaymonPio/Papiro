-- Aplicacao REAL do Lote 4 REAL de Direitos Humanos e Cidadania — 3
-- questoes novas + 15 alternativas + 3 vinculos, validado pelo harness
-- supabase/importar_dh_real_lote4_teste_rollback.sql (tudo_ok = true
-- precisa ser confirmado antes de rodar este arquivo).
--
-- Q-A: PMERJ/FGV/CFSD-2024 Q23 (Tipo 1, 09/04/2024) -> "Incorporação de
--      tratados de Direitos Humanos" (curso_conteudo_id=93, assunto_id=101,
--      unidade_id=98b10517-14a2-4efe-8360-960cae263ad5). Gabarito E.
-- Q-B: TJ-RS/FGV/Edital 14/2025-DDP-RECSEL Q27 (Área Administrativa, Tipo 1,
--      23/11/2025) -> mesma unidade de Q-A. Gabarito A.
-- Q-C: PMERJ/FGV/CFSD-2024 Q27 (Tipo 1, 09/04/2024) -> "Prevenção da
--      tortura" (curso_conteudo_id=99, assunto_id=26,
--      unidade_id=1c05566b-5c71-4baa-b965-3577b8ffdc17). Gabarito E.
--
-- Fonte da verdade: scripts/curadoria-pedagogica/relatorios/
-- pacote_importacao_dh_real_lote4.json.
--
-- Origem: REAL (FGV) em todas as 3 — nunca AUTORAL_PAPIRO. Provas e
-- gabaritos definitivos confirmados diretamente nos PDFs oficiais
-- (conhecimento.fgv.br) nesta sessao. Data de aplicacao do CFSD/2024
-- reconfirmada como 09/04/2024 (nao 07/04/2024) diretamente no cabecalho
-- do gabarito oficial. Numero da questao do TJ-RS reconfirmado como 27
-- (nao 30) na prova correta de Area Administrativa. Explicitamente
-- EXCLUIDAS deste lote: PMERJ CFO Q78 e PGE-SP Q93 (ambas REPROVADAS na
-- taxonomia de "Casos do Brasil na Corte Interamericana", cc90 — escopo
-- atual so cobre Ximenes Lopes/Araguaia/Herzog) e OAB/FGV Q14 (fonte
-- primaria nao localizada).
--
-- Diferenca deste arquivo para o harness: termina em COMMIT, e cada
-- precondicao/pos-condicao usa RAISE EXCEPTION — qualquer divergencia
-- aborta a transacao inteira antes de confirmar. Usa a mesma RPC
-- administrativa oficial classificar_questao_unidade_admin.
--
-- NAO EXECUTADO neste turno — preparado apenas para auditoria/decisao
-- humana antes do apply.

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
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 93) as cc93_uteis,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.questoes q on q.id = qup.questao_id where up.curso_conteudo_id = 93 and lower(q.banca) not like '%papiro%') as cc93_real,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 99) as cc99_uteis,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.questoes q on q.id = qup.questao_id where up.curso_conteudo_id = 99 and lower(q.banca) not like '%papiro%') as cc99_real,
  (select count(distinct qup.questao_id)
     from public.questao_unidades_pedagogicas qup
     join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
     join public.curso_conteudos cc on cc.id = up.curso_conteudo_id
     join public.assuntos a on a.id = cc.assunto_id
     where a.materia_id = 11) as dh_uteis;

create temporary table _lote_questoes (
  ordem int primary key,
  unidade_id uuid,
  assunto_id bigint,
  banca text,
  concurso text,
  ano int,
  fonte text,
  enunciado text
) on commit drop;

insert into _lote_questoes (ordem, unidade_id, assunto_id, banca, concurso, ano, fonte, enunciado) values
(1, '98b10517-14a2-4efe-8360-960cae263ad5', 101, 'FGV', 'CFSD/2024 - PMERJ - Soldado Policial Militar Classe C', 2024,
 'FGV — PMERJ, CFSD/2024, Soldado Policial Militar Classe C, Prova Tipo 1 - Branca, aplicada em 09/04/2024 — Questão 23',
 'Com o advento da Emenda Constitucional nº 45 de 2004, ocorreu a alteração do regramento sobre a internalização de normas internacionais de direitos humanos. Nesse sentido, com relação ao atual entendimento do Supremo Tribunal Federal sobre o assunto, é correto afirmar que:'),
(2, '98b10517-14a2-4efe-8360-960cae263ad5', 101, 'FGV', 'Edital nº 14/2025-DDP-SELEÇÃO-RECSEL - TJ-RS - Analista do Poder Judiciário - Área Administrativa', 2025,
 'FGV — TJ-RS, Edital nº 14/2025-DDP-SELEÇÃO-RECSEL, Analista do Poder Judiciário - Área Administrativa, Tipo 1 - Branca, Turno Tarde, aplicada em 23/11/2025 — Questão 27',
 'Após legítima articulação efetivada pelo Poder Executivo, o tratado internacional Alfa, que versa sobre direitos humanos, foi aprovado, na Câmara dos Deputados e no Senado Federal, em dois turnos, por três quintos dos votos dos membros das Casas Legislativas. Nesse cenário, considerando as disposições da Constituição Federal, é correto afirmar que o tratado internacional Alfa será equivalente a uma'),
(3, '1c05566b-5c71-4baa-b965-3577b8ffdc17', 26, 'FGV', 'CFSD/2024 - PMERJ - Soldado Policial Militar Classe C', 2024,
 'FGV — PMERJ, CFSD/2024, Soldado Policial Militar Classe C, Prova Tipo 1 - Branca, aplicada em 09/04/2024 — Questão 27',
 'No ano de 2010, o Rio de Janeiro foi o primeiro estado da federação a instituir um sistema estadual de prevenção e combate à tortura no âmbito do Poder Legislativo, com a constituição de um comitê estadual e um mecanismo estadual de prevenção e combate à tortura. Sobre o Sistema Nacional de Prevenção e Combate à Tortura (SNPCT), é correto afirmar que:');

create temporary table _lote_explicacoes (ordem int primary key, explicacao text) on commit drop;
insert into _lote_explicacoes (ordem, explicacao) values
(1, E'GABARITO: alternativa E\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nReproduz o entendimento consolidado pelo STF no julgamento do RE 466.343/SP (Rel. Min. Cezar Peluso, Tribunal Pleno, 2008): os tratados e convenções internacionais sobre direitos humanos, quando incorporados pelo procedimento ordinário (sem o rito do art. 5º, §3º, da CF, incluído pela EC nº 45/2004), possuem status SUPRALEGAL — abaixo da Constituição, mas acima da legislação ordinária. Quando, porém, o mesmo tratado é aprovado em cada Casa do Congresso Nacional, em dois turnos, por três quintos dos votos dos respectivos membros (rito especial do art. 5º, §3º), ele passa a ser EQUIVALENTE À EMENDA CONSTITUCIONAL.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nAlternativa A: tratados de direitos humanos nunca têm mero status de lei ordinária — mesmo pelo rito comum, já são supralegais, hierarquicamente superiores à legislação ordinária.\nAlternativa B: não existe incorporação automática com status constitucional — a equivalência a emenda constitucional depende do rito qualificado específico do art. 5º, §3º (dois turnos, três quintos, em cada Casa); sem esse rito, o tratado não tem hierarquia constitucional.\nAlternativa C: descreve um procedimento inexistente — não há "chefe do Congresso Nacional" com poder de revogar assinatura do Presidente da República; a ratificação de tratados segue o rito constitucional (art. 84, VIII, e art. 49, I, da CF), não essa figura fictícia.\nAlternativa D: inverte a lógica hierárquica — tratados de direitos humanos (mesmo com status supralegal ou de EC) não podem contrariar cláusulas pétreas da Constituição, mas a formulação da alternativa, ao dizer que eles simplesmente "não prevalecem" sobre normas constitucionais anteriores, não corresponde ao teste da questão sobre o status hierárquico correto (supralegalidade vs. equivalência a EC).\n\nBIZU DE PROVA:\nTratado de DH SEM rito do art. 5º §3º = SUPRALEGAL (acima de lei, abaixo da CF). Tratado de DH COM rito do art. 5º §3º (2 Casas + 2 turnos + 3/5 dos votos) = EQUIVALENTE A EMENDA CONSTITUCIONAL. Nunca confundir com "incorporação automática" (não existe) nem com "mera lei ordinária" (nunca é só isso, mesmo no rito comum).'),
(2, E'GABARITO: alternativa A\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nReproduz literalmente o art. 5º, §3º, da Constituição Federal (incluído pela EC nº 45/2004): os tratados e convenções internacionais sobre direitos humanos que forem aprovados, em cada Casa do Congresso Nacional, em dois turnos, por três quintos dos votos dos respectivos membros, serão equivalentes às emendas constitucionais. O enunciado descreve exatamente esse rito (Câmara + Senado, dois turnos, três quintos dos votos) — logo, o tratado "Alfa" é equivalente a emenda constitucional.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nAlternativa B: medida provisória é ato do Poder Executivo com força de lei, editado em casos de relevância e urgência (art. 62 CF) — não tem relação alguma com o rito de incorporação de tratados pelo Legislativo.\nAlternativa C: lei complementar exige apenas maioria absoluta (não dois turnos nem três quintos) e trata de matérias reservadas constitucionalmente — não é a consequência do rito descrito.\nAlternativa D: lei ordinária é o patamar mais baixo, aprovada por maioria simples — mas o tratado descrito passou por um rito muito mais qualificado (dois turnos, três quintos), que confere hierarquia máxima (equivalência a EC), não a de lei ordinária.\nAlternativa E: lei delegada é elaborada pelo Presidente da República mediante delegação do Congresso Nacional (art. 68 CF) — não tem qualquer relação com o procedimento de aprovação de tratados internacionais.\n\nBIZU DE PROVA:\nTratado de Direitos Humanos + aprovado em cada Casa do Congresso + dois turnos + três quintos dos votos = EQUIVALENTE A EMENDA CONSTITUCIONAL (art. 5º §3º CF). Essa é a única combinação de requisitos que gera esse efeito — qualquer variação (maioria simples, um turno só, etc.) resulta apenas em status supralegal.'),
(3, E'GABARITO: alternativa E\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nReproduz o art. 2º da Lei nº 12.847/2013, que instituiu o Sistema Nacional de Prevenção e Combate à Tortura (SNPCT): o Sistema é composto pelo Comitê Nacional de Prevenção e Combate à Tortura (CNPCT), pelo Mecanismo Nacional de Prevenção e Combate à Tortura (MNPCT), pelo Conselho Nacional de Política Criminal e Penitenciária (CNPCP) e pelo órgão do Ministério da Justiça responsável pelo sistema penitenciário nacional. O SNPCT é a estrutura doméstica brasileira que implementa o Protocolo Facultativo à Convenção da ONU contra a Tortura (OPCAT), promulgado pelo Decreto nº 6.085/2007.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nAlternativa A: corregedorias e ouvidorias de polícia PODEM integrar o SNPCT como órgãos colaboradores/articulados — a lei não as exclui; a alternativa inventa uma vedação inexistente.\nAlternativa B: nenhuma diretriz do SNPCT autoriza relativizar os direitos das pessoas privadas de liberdade em favor das vítimas — a proteção da integridade física e mental de pessoas custodiadas é justamente o núcleo do sistema, sem hierarquização entre direitos de vítimas e de custodiados.\nAlternativa C: o SNPCT não atua "em preponderância" às demais esferas de governo — atua de forma articulada e cooperativa (caráter de monitoramento e prevenção), sem subordinar ou se sobrepor às competências dos demais entes federativos e poderes.\nAlternativa D: o SNPCT e o OPCAT são inteiramente incompatíveis com qualquer forma de tortura, inclusive "vigiada por médicos" — a proibição da tortura é absoluta (não admite exceção para obtenção de prova), de modo que a alternativa inverte o sentido do sistema, que existe exatamente para PREVENIR esse tipo de prática, não para permiti-la sob supervisão médica.\n\nBIZU DE PROVA:\nSNPCT (Lei 12.847/2013) = CNPCT + MNPCT + CNPCP + órgão do MJ do sistema penitenciário — quatro peças, decore "C-M-C-M" (Comitê, Mecanismo, Conselho, Ministério). O sistema implementa o OPCAT no Brasil por meio de visitas regulares a locais de privação de liberdade, sem jamais admitir qualquer forma de tortura, ainda que sob pretexto de investigação ou produção de prova — a proibição é absoluta.');

create temporary table _lote_alternativas (
  ordem int,
  ordem_alt smallint,
  texto text,
  correta boolean
) on commit drop;

insert into _lote_alternativas (ordem, ordem_alt, texto, correta) values
(1,1,'os tratados internacionais de direitos humanos têm natureza de lei ordinária federal;',false),
(1,2,'as normas internacionais que versam sobre direitos humanos têm o mesmo status das normas constitucionais, sendo incorporadas automaticamente ao âmbito interno;',false),
(1,3,'as convenções internacionais de direitos humanos são ratificadas pelo chefe do Congresso Nacional, que poderá revogar a assinatura firmada pelo presidente da República;',false),
(1,4,'as normas internacionais de direitos humanos não prevalecem sobre os direitos previstos nas normas constitucionais vigentes anteriormente à sua ratificação e aprovação pelo Congresso Nacional;',false),
(1,5,'as convenções e os tratados internacionais de direitos humanos têm natureza supralegal, salvo na hipótese de serem equivalentes às emendas constitucionais, uma vez aprovadas pelo mesmo rito especial.',true),
(2,1,'emenda constitucional.',true),
(2,2,'medida provisória.',false),
(2,3,'lei complementar.',false),
(2,4,'lei ordinária.',false),
(2,5,'lei delegada.',false),
(3,1,'as corregedorias e ouvidorias de polícia não poderão integrar o SNPCT, uma vez que serão fiscalizadas pelo referido sistema e deverão prestar informações quando requisitadas;',false),
(3,2,'uma de suas diretrizes é o respeito aos direitos humanos, mas os das pessoas privadas de liberdade devem ser relativizados, inclusive com prevalência dos direitos das vítimas;',false),
(3,3,'o SNPCT atuará em preponderância às demais esferas de governo e de poder, responsáveis pela segurança pública, pela custódia de pessoas privadas de liberdade, por locais de internação de longa permanência e pela proteção de direitos humanos;',false),
(3,4,'está em desacordo com o Protocolo Facultativo à Convenção das Nações Unidas contra a Tortura e Outros Tratamentos ou Penas Cruéis, Desumanos ou Degradantes, promulgado pelo Decreto nº 6.085, de 19 de abril de 2007, pois permite tortura vigiada por médicos nos casos de imprescindível obtenção de prova de crime;',false),
(3,5,'é composto pelo Comitê Nacional de Prevenção e Combate à Tortura (CNPCT), pelo Mecanismo Nacional de Prevenção e Combate à Tortura (MNPCT), pelo Conselho Nacional de Política Criminal e Penitenciária (CNPCP) e pelo órgão do Ministério da Justiça responsável pelo sistema penitenciário nacional.',true);

-- Precondicoes.
do $$
declare
  v_cnt int;
  v_dup int;
begin
  select count(*) into v_cnt from _lote_questoes;
  if v_cnt <> 3 then
    raise exception 'Precondicao falhou: staging tem % questoes (esperado 3)', v_cnt;
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

  if (select cc93_uteis from _snapshot_antes) <> 3 or (select cc93_real from _snapshot_antes) <> 0 then
    raise exception 'Precondicao falhou: cc93 nao esta no estado esperado (uteis=%, real=%; esperado 3/0)', (select cc93_uteis from _snapshot_antes), (select cc93_real from _snapshot_antes);
  end if;
  if (select cc99_uteis from _snapshot_antes) <> 3 or (select cc99_real from _snapshot_antes) <> 0 then
    raise exception 'Precondicao falhou: cc99 nao esta no estado esperado (uteis=%, real=%; esperado 3/0)', (select cc99_uteis from _snapshot_antes), (select cc99_real from _snapshot_antes);
  end if;
end $$;

-- Insercao das questoes + alternativas.
create temporary table _mapa_ids (ordem int primary key, questao_id bigint) on commit drop;

do $$
declare r record; v_id bigint;
begin
  for r in select * from _lote_questoes order by ordem loop
    insert into public.questoes (materia_id, assunto_id, banca, concurso, ano, enunciado, dificuldade, explicacao, fonte, ativa, gerada_por_ia)
    values (11, r.assunto_id, r.banca, r.concurso, r.ano, r.enunciado, 'media',
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
    perform public.classificar_questao_unidade_admin(r.questao_id, r.unidade_id);
  end loop;
end $$;

-- Pos-condicoes ENDURECIDAS: RAISE EXCEPTION em qualquer divergencia — so
-- chega ao COMMIT final se passar tudo.
do $$
declare
  v_novas_questoes int;
  v_novas_alternativas int;
  v_corretas_invalidas int;
  v_novos_vinculos int;
  v_multiunidade int;
  v_nao_real int;
  v_gabA boolean;
  v_gabB boolean;
  v_gabC boolean;
  v_cc93_uteis_depois int;
  v_cc93_real_depois int;
  v_cc93_autoral_depois int;
  v_cc99_uteis_depois int;
  v_cc99_real_depois int;
  v_cc99_autoral_depois int;
  v_dh_uteis_depois int;
begin
  select count(*) into v_novas_questoes from public.questoes where id in (select questao_id from _mapa_ids);
  if v_novas_questoes <> 3 then
    raise exception 'Pos-condicao falhou: questoes novas=% (esperado 3)', v_novas_questoes;
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

  select count(*) into v_nao_real from public.questoes where id in (select questao_id from _mapa_ids) and lower(banca) like '%papiro%';
  if v_nao_real <> 0 then
    raise exception 'Pos-condicao falhou: % questao(oes) com banca papiro (esperado 0 — FGV)', v_nao_real;
  end if;

  select count(*) into v_novas_alternativas from public.alternativas where questao_id in (select questao_id from _mapa_ids);
  if v_novas_alternativas <> 15 then
    raise exception 'Pos-condicao falhou: alternativas novas=% (esperado 15)', v_novas_alternativas;
  end if;

  select count(*) into v_corretas_invalidas
  from (select questao_id, count(*) filter (where correta) as n from public.alternativas where questao_id in (select questao_id from _mapa_ids) group by questao_id having count(*) filter (where correta) <> 1) x;
  if v_corretas_invalidas <> 0 then
    raise exception 'Pos-condicao falhou: % questao(oes) sem exatamente 1 alternativa correta', v_corretas_invalidas;
  end if;

  select (correta) into v_gabA from public.alternativas a join _mapa_ids m on a.questao_id = m.questao_id where m.ordem = 1 and a.ordem = 5;
  select (correta) into v_gabB from public.alternativas a join _mapa_ids m on a.questao_id = m.questao_id where m.ordem = 2 and a.ordem = 1;
  select (correta) into v_gabC from public.alternativas a join _mapa_ids m on a.questao_id = m.questao_id where m.ordem = 3 and a.ordem = 5;
  if v_gabA is not true or v_gabB is not true or v_gabC is not true then
    raise exception 'Pos-condicao falhou: gabaritos nao batem (Q-A deve ser ordem5=E, Q-B ordem1=A, Q-C ordem5=E)';
  end if;

  select count(*) into v_novos_vinculos from public.questao_unidades_pedagogicas where questao_id in (select questao_id from _mapa_ids);
  if v_novos_vinculos <> 3 then
    raise exception 'Pos-condicao falhou: vinculos novos=% (esperado 3)', v_novos_vinculos;
  end if;

  select count(*) into v_multiunidade
  from (select questao_id from public.questao_unidades_pedagogicas where questao_id in (select questao_id from _mapa_ids) group by questao_id having count(*) > 1) x;
  if v_multiunidade <> 0 then
    raise exception 'Pos-condicao falhou: % questao(oes) com mais de 1 vinculo', v_multiunidade;
  end if;

  if not exists (select 1 from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join _mapa_ids m on m.questao_id = qup.questao_id where m.ordem = 1 and up.curso_conteudo_id = 93) then
    raise exception 'Pos-condicao falhou: Q-A nao esta vinculada a cc93';
  end if;
  if not exists (select 1 from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join _mapa_ids m on m.questao_id = qup.questao_id where m.ordem = 2 and up.curso_conteudo_id = 93) then
    raise exception 'Pos-condicao falhou: Q-B nao esta vinculada a cc93';
  end if;
  if not exists (select 1 from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join _mapa_ids m on m.questao_id = qup.questao_id where m.ordem = 3 and up.curso_conteudo_id = 99) then
    raise exception 'Pos-condicao falhou: Q-C nao esta vinculada a cc99';
  end if;

  select count(distinct qup.questao_id) into v_cc93_uteis_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    where up.curso_conteudo_id = 93;
  if v_cc93_uteis_depois <> (select cc93_uteis from _snapshot_antes) + 2 then
    raise exception 'Pos-condicao falhou: cc93_uteis=% (esperado %)', v_cc93_uteis_depois, (select cc93_uteis from _snapshot_antes) + 2;
  end if;

  select count(distinct qup.questao_id) into v_cc93_real_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.questoes q on q.id = qup.questao_id
    where up.curso_conteudo_id = 93 and lower(q.banca) not like '%papiro%';
  if v_cc93_real_depois <> (select cc93_real from _snapshot_antes) + 2 then
    raise exception 'Pos-condicao falhou: cc93_real=% (esperado %)', v_cc93_real_depois, (select cc93_real from _snapshot_antes) + 2;
  end if;

  select count(distinct qup.questao_id) into v_cc93_autoral_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.questoes q on q.id = qup.questao_id
    where up.curso_conteudo_id = 93 and lower(q.banca) like '%papiro%';
  if v_cc93_autoral_depois <> 3 then
    raise exception 'Pos-condicao falhou: cc93_autoral=% (esperado inalterado 3)', v_cc93_autoral_depois;
  end if;

  select count(distinct qup.questao_id) into v_cc99_uteis_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    where up.curso_conteudo_id = 99;
  if v_cc99_uteis_depois <> (select cc99_uteis from _snapshot_antes) + 1 then
    raise exception 'Pos-condicao falhou: cc99_uteis=% (esperado %)', v_cc99_uteis_depois, (select cc99_uteis from _snapshot_antes) + 1;
  end if;

  select count(distinct qup.questao_id) into v_cc99_real_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.questoes q on q.id = qup.questao_id
    where up.curso_conteudo_id = 99 and lower(q.banca) not like '%papiro%';
  if v_cc99_real_depois <> (select cc99_real from _snapshot_antes) + 1 then
    raise exception 'Pos-condicao falhou: cc99_real=% (esperado %)', v_cc99_real_depois, (select cc99_real from _snapshot_antes) + 1;
  end if;

  select count(distinct qup.questao_id) into v_cc99_autoral_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.questoes q on q.id = qup.questao_id
    where up.curso_conteudo_id = 99 and lower(q.banca) like '%papiro%';
  if v_cc99_autoral_depois <> 3 then
    raise exception 'Pos-condicao falhou: cc99_autoral=% (esperado inalterado 3)', v_cc99_autoral_depois;
  end if;

  select count(distinct qup.questao_id) into v_dh_uteis_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.curso_conteudos cc on cc.id = up.curso_conteudo_id
    join public.assuntos a on a.id = cc.assunto_id
    where a.materia_id = 11;
  if v_dh_uteis_depois <> (select dh_uteis from _snapshot_antes) + 3 then
    raise exception 'Pos-condicao falhou: dh_uteis=% (esperado %)', v_dh_uteis_depois, (select dh_uteis from _snapshot_antes) + 3;
  end if;

  if (select count(*) from public.questoes) <> (select total_questoes from _snapshot_antes) + 3 then
    raise exception 'Pos-condicao falhou: total de questoes nao cresceu exatamente 3';
  end if;
  if (select count(*) from public.alternativas) <> (select total_alternativas from _snapshot_antes) + 15 then
    raise exception 'Pos-condicao falhou: total de alternativas nao cresceu exatamente 15';
  end if;
  if (select count(*) from public.questao_unidades_pedagogicas) <> (select total_vinculos from _snapshot_antes) + 3 then
    raise exception 'Pos-condicao falhou: total de vinculos nao cresceu exatamente 3';
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

  raise notice 'Pos-condicoes OK: 3 questoes REAL novas (PMERJ Q23, TJ-RS Q27, PMERJ Q27) / 15 alternativas / 3 vinculos / cc93 uteis %->% real %->% / cc99 uteis %->% real %->% / DH uteis %->%.',
    (select cc93_uteis from _snapshot_antes), v_cc93_uteis_depois,
    (select cc93_real from _snapshot_antes), v_cc93_real_depois,
    (select cc99_uteis from _snapshot_antes), v_cc99_uteis_depois,
    (select cc99_real from _snapshot_antes), v_cc99_real_depois,
    (select dh_uteis from _snapshot_antes), v_dh_uteis_depois;
end $$;

commit;
