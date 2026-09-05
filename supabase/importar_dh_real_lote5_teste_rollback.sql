-- Harness de teste (SEMPRE termina em ROLLBACK) do Lote 5 REAL de Direitos
-- Humanos e Cidadania — 2 questoes novas + 9 alternativas + 2 vinculos:
--
-- Q-A: OAB/FGV/XXXIV Exame de Ordem Q18 (Tipo 1-Branca, 20/02/2022) ->
--      "Tratado de Marraqueche" (curso_conteudo_id=94, assunto_id=105,
--      unidade_id=389ff0e7-38f5-4fe5-b66d-4ebbbb5ee9bf). 4 alternativas
--      (A-D). Gabarito C.
-- Q-B: DPE-RO/CEBRASPE/2023 Q3 (caderno 783_DPE_RO_001_01, 22/01/2023) ->
--      "Comissão Interamericana de Direitos Humanos" (curso_conteudo_id=87,
--      assunto_id=92, unidade_id=1b84fd2f-93e4-46c1-868f-c8402e73bdf9).
--      5 alternativas (A-E). Gabarito C.
--
-- Fonte da verdade: scripts/curadoria-pedagogica/relatorios/
-- pacote_importacao_dh_real_lote5.json.
--
-- Origem: REAL em ambas — nunca AUTORAL_PAPIRO. Prova e gabarito
-- confirmados diretamente nos PDFs oficiais (s.oab.org.br,
-- arquivos.qconcursos.com para prova OAB; cdn.cebraspe.org.br para
-- DPE-RO) nesta sessao. Numero da questao da OAB reconfirmado como 18
-- (nao 17, que trata de Defensoria Publica/nacionalidade). Q-B destinada
-- a cc87 (Comissao), NAO a cc86 (OEA), apesar do comando citar "Carta da
-- OEA" — a habilidade determinante e a funcao especifica da Comissao,
-- ja textualmente presente no escopo de cc87. Explicitamente EXCLUIDAS
-- deste lote: PC-PB/CEBRASPE Q50 (gabarito do cargo exato nao localizado),
-- DPE-PI/CEBRASPE Q64 (gabarito nao localizado + reprovada na taxonomia
-- de cc89), ENAM/FGV Q37 (reprovada na taxonomia de cc86), DPE-BA/FCC
-- 2016 (sem fonte primaria) e OAB VI Q14 (gabarito definitivo primario
-- ainda pendente).
--
-- Termina SEMPRE em ROLLBACK — nada aqui persiste no banco. NAO EXECUTADO
-- neste turno (auditoria/preparacao apenas).

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
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 94) as cc94_uteis,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.questoes q on q.id = qup.questao_id where up.curso_conteudo_id = 94 and lower(q.banca) not like '%papiro%') as cc94_real,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 87) as cc87_uteis,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.questoes q on q.id = qup.questao_id where up.curso_conteudo_id = 87 and lower(q.banca) not like '%papiro%') as cc87_real,
  (select count(distinct qup.questao_id)
     from public.questao_unidades_pedagogicas qup
     join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
     join public.curso_conteudos cc on cc.id = up.curso_conteudo_id
     join public.assuntos a on a.id = cc.assunto_id
     where a.materia_id = 11) as dh_uteis;

create temporary table _relatorio (etapa text, ok boolean, detalhe text) on commit drop;

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
(1, '389ff0e7-38f5-4fe5-b66d-4ebbbb5ee9bf', 105, 'FGV', 'XXXIV Exame de Ordem Unificado - 1ª Fase Objetiva', 2022,
 'FGV — CFOAB, XXXIV Exame de Ordem Unificado, Tipo 1 - Branca, aplicada em 20/02/2022 — Questão 18',
 'Você está trabalhando, como advogada(o), para um grupo de estudantes universitários com deficiência visual. Eles relataram ter muita dificuldade para estudar, pois há pouquíssima disponibilidade de obras científicas com exemplar em formato acessível. Para preparar sua atuação no caso, você recorreu ao Tratado de Marraqueche para Facilitar o Acesso a Obras Publicadas às Pessoas Cegas, com Deficiência Visual ou com Outras Dificuldades para Ter Acesso ao Texto Impresso. Como ponto de partida do seu caso, exemplar em formato acessível, segundo o Tratado de Marraqueche, deve ser entendido como'),
(2, '1b84fd2f-93e4-46c1-868f-c8402e73bdf9', 92, 'CEBRASPE', 'V Concurso Público - DPE-RO - Defensor Público Substituto', 2023,
 'CEBRASPE — DPE-RO, V Concurso Público, Defensor Público Substituto, aplicada em 22/01/2023 — Questão 3',
 'Conforme a Carta da Organização dos Estados Americanos, promover a observância e a defesa dos direitos humanos nas Américas é a função principal');

create temporary table _lote_explicacoes (ordem int primary key, explicacao text) on commit drop;
insert into _lote_explicacoes (ordem, explicacao) values
(1, E'GABARITO: alternativa C\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO Tratado de Marraqueche (art. 2, alínea "b") define "exemplar em formato acessível" como a reprodução de uma obra de uma maneira ou forma alternativa que dá aos beneficiários acesso à obra, incluindo permitir que a pessoa tenha acesso de maneira tão prática e cômoda como uma pessoa sem deficiência visual ou sem outras dificuldades para ter acesso ao texto impresso. É uma definição FUNCIONAL/FINALÍSTICA — o que importa é o RESULTADO (acesso equivalente), não um formato específico predeterminado.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nAlternativa A: restringe indevidamente o conceito a um único formato (Braille) e a locais específicos (centros especializados) — o Tratado não limita "formato acessível" a nenhum método específico; Braille é apenas um exemplo possível entre vários (áudio, texto ampliado, arquivos digitais acessíveis etc.).\nAlternativa B: inventa um mecanismo de venda subsidiada com teto de preço (30%) e isenções tributárias — isso não consta do Tratado, que trata de limitações e exceções ao direito autoral para produção e disponibilização, não de um regime de comercialização com desconto regulado.\nAlternativa D: restringe o conceito à disponibilidade de ledores em bibliotecas durante o horário de funcionamento — isso descreve um serviço de leitura assistida pontual, não o conceito amplo e permanente de "exemplar em formato acessível" que o Tratado define.\n\nBIZU DE PROVA:\n"Exemplar em formato acessível" no Tratado de Marraqueche = definição pelo RESULTADO (acesso tão prático e cômodo quanto o de quem não tem a deficiência), não pelo MEIO específico. Não amarre o conceito a Braille, ledores ou qualquer tecnologia/formato único — o Tratado é neutro quanto ao meio, desde que o efeito de equivalência de acesso seja alcançado.'),
(2, E'GABARITO: alternativa C\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nA Carta da OEA (art. 53, "e") lista a Comissão Interamericana de Direitos Humanos como um dos órgãos por meio dos quais a Organização realiza seus fins, e o art. 106 da própria Carta atribui a essa Comissão a função principal de promover a observância e a defesa dos direitos humanos e de servir como órgão consultivo da Organização em tal matéria — disposição reforçada pelo art. 41, caput, da Convenção Americana sobre Direitos Humanos.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nAlternativa A: o Conselho Permanente é órgão executivo/administrativo da OEA entre os períodos de sessão da Assembleia Geral (preenchimento de vagas, questões político-diplomáticas), sem a função específica de promoção/defesa dos direitos humanos.\nAlternativa B: o Conselho Interamericano de Desenvolvimento Integral trata de cooperação técnica para desenvolvimento econômico e social dos Estados-membros — matéria de desenvolvimento, não de direitos humanos especificamente.\nAlternativa D: a Assembleia Geral é o órgão supremo/deliberativo geral da OEA (decide a política geral da Organização), mas não é ela quem exerce especificamente a função de promoção/defesa dos direitos humanos — essa é atribuição textual da Comissão.\nAlternativa E: "Comissão Geral" não é um órgão autônomo da OEA com essa atribuição — é, quando muito, uma comissão interna de trabalho da Assembleia Geral, sem a função descrita.\n\nBIZU DE PROVA:\nSempre que a questão perguntar "qual órgão da OEA promove/defende os direitos humanos", a resposta é a COMISSÃO INTERAMERICANA DE DIREITOS HUMANOS (art. 106 da Carta da OEA) — não confundir com Conselho Permanente (administrativo), CIDI (desenvolvimento), Assembleia Geral (deliberação geral) ou "Comissão Geral" (inexistente como órgão autônomo).');

create temporary table _lote_alternativas (
  ordem int,
  ordem_alt smallint,
  texto text,
  correta boolean
) on commit drop;

insert into _lote_alternativas (ordem, ordem_alt, texto, correta) values
(1,1,'disponibilização da obra no sistema de escrita e leitura tátil baseada em símbolos em relevo, conhecido como método Braille. Tal disponibilização deve se dar em centros governamentais ou não governamentais especializados em apoio às pessoas com deficiência visual.',false),
(1,2,'venda ou reprodução de obras literárias, artísticas ou científicas por preços de no máximo 30% do valor de mercado destinada exclusivamente às pessoas com deficiência visual. As empresas editoriais contarão com isenções tributárias para compensar o custo de produção.',false),
(1,3,'reprodução de uma obra de uma maneira ou forma alternativa que dá aos beneficiários acesso à obra, inclusive para permitir que a pessoa tenha acesso de maneira tão prática e cômoda como uma pessoa sem deficiência visual ou sem outras dificuldades para ter acesso ao texto impresso.',true),
(1,4,'exemplar disponível para as pessoas com deficiência visual em bibliotecas que tenham ledores disponíveis durante todo o seu horário de funcionamento.',false),
(2,1,'do Conselho Permanente.',false),
(2,2,'do Conselho Interamericano de Desenvolvimento Integral.',false),
(2,3,'da Comissão Interamericana de Direitos Humanos.',true),
(2,4,'da Assembleia Geral.',false),
(2,5,'da Comissão Geral.',false);

-- Precondicoes.
do $$
declare
  v_cnt int;
  v_dup int;
begin
  select count(*) into v_cnt from _lote_questoes;
  insert into _relatorio values ('staging_tem_2_questoes', v_cnt = 2, format('staging=%s (esperado 2)', v_cnt));

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

  insert into _relatorio values ('cc94_estado_antes_esperado',
    (select cc94_uteis from _snapshot_antes) = 3 and (select cc94_real from _snapshot_antes) = 0,
    format('cc94_uteis=%s cc94_real=%s (esperado 3/0)', (select cc94_uteis from _snapshot_antes), (select cc94_real from _snapshot_antes)));
  insert into _relatorio values ('cc87_estado_antes_esperado',
    (select cc87_uteis from _snapshot_antes) = 4 and (select cc87_real from _snapshot_antes) = 1,
    format('cc87_uteis=%s cc87_real=%s (esperado 4/1)', (select cc87_uteis from _snapshot_antes), (select cc87_real from _snapshot_antes)));
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
  v_nao_real int;
  v_gabA boolean;
  v_gabB boolean;
  v_cc94_uteis_depois int;
  v_cc94_real_depois int;
  v_cc94_autoral_depois int;
  v_cc87_uteis_depois int;
  v_cc87_real_depois int;
  v_cc87_autoral_depois int;
  v_dh_uteis_depois int;
begin
  select count(*) into v_novas_questoes from public.questoes where id in (select questao_id from _mapa_ids);
  insert into _relatorio values ('2_questoes_criadas', v_novas_questoes = 2, format('questoes novas=%s (esperado 2)', v_novas_questoes));

  insert into _relatorio values ('materia_11',
    (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and materia_id <> 11) = 0, 'materia_id deve ser 11 nas 2');
  insert into _relatorio values ('assunto_ids_corretos',
    (select count(*) from public.questoes q join _mapa_ids m on m.questao_id = q.id join _lote_questoes lq on lq.ordem = m.ordem where q.assunto_id <> lq.assunto_id) = 0,
    'assunto_id de cada questao deve bater com o assunto_id do staging (Q-A=105, Q-B=92)');
  insert into _relatorio values ('ativas',
    (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and ativa is distinct from true) = 0, 'ativa deve ser true nas 2');

  select count(*) into v_nao_real from public.questoes where id in (select questao_id from _mapa_ids) and lower(banca) like '%papiro%';
  insert into _relatorio values ('sao_real', v_nao_real = 0, format('%s questao(oes) com banca papiro (esperado 0)', v_nao_real));

  select count(*) into v_novas_alternativas from public.alternativas where questao_id in (select questao_id from _mapa_ids);
  insert into _relatorio values ('exatamente_9_alternativas', v_novas_alternativas = 9, format('alternativas novas=%s (esperado 9 = 4+5)', v_novas_alternativas));

  select count(*) into v_corretas_invalidas
  from (select questao_id, count(*) filter (where correta) as n from public.alternativas where questao_id in (select questao_id from _mapa_ids) group by questao_id having count(*) filter (where correta) <> 1) x;
  insert into _relatorio values ('1_correta_por_questao', v_corretas_invalidas = 0, format('%s questao(oes) sem exatamente 1 alternativa correta', v_corretas_invalidas));

  select (correta) into v_gabA from public.alternativas a join _mapa_ids m on a.questao_id = m.questao_id where m.ordem = 1 and a.ordem = 3;
  select (correta) into v_gabB from public.alternativas a join _mapa_ids m on a.questao_id = m.questao_id where m.ordem = 2 and a.ordem = 3;
  insert into _relatorio values ('gabaritos_corretos',
    coalesce(v_gabA,false) and coalesce(v_gabB,false),
    'Q-A correta=ordem3(C); Q-B correta=ordem3(C)');

  select count(*) into v_novos_vinculos from public.questao_unidades_pedagogicas where questao_id in (select questao_id from _mapa_ids);
  insert into _relatorio values ('2_vinculos_criados', v_novos_vinculos = 2, format('vinculos novos=%s (esperado 2)', v_novos_vinculos));

  select count(*) into v_multiunidade
  from (select questao_id from public.questao_unidades_pedagogicas where questao_id in (select questao_id from _mapa_ids) group by questao_id having count(*) > 1) x;
  insert into _relatorio values ('sem_multiunidade', v_multiunidade = 0, format('%s questao(oes) com mais de 1 vinculo', v_multiunidade));

  insert into _relatorio values ('QA_vinculo_cc94',
    exists (select 1 from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join _mapa_ids m on m.questao_id = qup.questao_id where m.ordem = 1 and up.curso_conteudo_id = 94),
    'Q-A deve estar vinculada a cc94');
  insert into _relatorio values ('QB_vinculo_cc87',
    exists (select 1 from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join _mapa_ids m on m.questao_id = qup.questao_id where m.ordem = 2 and up.curso_conteudo_id = 87),
    'Q-B deve estar vinculada a cc87');
  insert into _relatorio values ('QB_nao_vinculada_cc86',
    not exists (select 1 from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join _mapa_ids m on m.questao_id = qup.questao_id where m.ordem = 2 and up.curso_conteudo_id = 86),
    'Q-B NAO deve estar vinculada a cc86/OEA');

  select count(distinct qup.questao_id) into v_cc94_uteis_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    where up.curso_conteudo_id = 94;
  insert into _relatorio values ('cc94_uteis_3_para_4', v_cc94_uteis_depois = (select cc94_uteis from _snapshot_antes) + 1, format('cc94_uteis=%s', v_cc94_uteis_depois));

  select count(distinct qup.questao_id) into v_cc94_real_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.questoes q on q.id = qup.questao_id
    where up.curso_conteudo_id = 94 and lower(q.banca) not like '%papiro%';
  insert into _relatorio values ('cc94_real_0_para_1', v_cc94_real_depois = (select cc94_real from _snapshot_antes) + 1, format('cc94_real=%s', v_cc94_real_depois));

  select count(distinct qup.questao_id) into v_cc94_autoral_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.questoes q on q.id = qup.questao_id
    where up.curso_conteudo_id = 94 and lower(q.banca) like '%papiro%';
  insert into _relatorio values ('cc94_autoral_permanece_3', v_cc94_autoral_depois = 3, format('cc94_autoral=%s (esperado inalterado 3)', v_cc94_autoral_depois));

  select count(distinct qup.questao_id) into v_cc87_uteis_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    where up.curso_conteudo_id = 87;
  insert into _relatorio values ('cc87_uteis_4_para_5', v_cc87_uteis_depois = (select cc87_uteis from _snapshot_antes) + 1, format('cc87_uteis=%s', v_cc87_uteis_depois));

  select count(distinct qup.questao_id) into v_cc87_real_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.questoes q on q.id = qup.questao_id
    where up.curso_conteudo_id = 87 and lower(q.banca) not like '%papiro%';
  insert into _relatorio values ('cc87_real_1_para_2', v_cc87_real_depois = (select cc87_real from _snapshot_antes) + 1, format('cc87_real=%s', v_cc87_real_depois));

  select count(distinct qup.questao_id) into v_cc87_autoral_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.questoes q on q.id = qup.questao_id
    where up.curso_conteudo_id = 87 and lower(q.banca) like '%papiro%';
  insert into _relatorio values ('cc87_autoral_permanece_3', v_cc87_autoral_depois = 3, format('cc87_autoral=%s (esperado inalterado 3)', v_cc87_autoral_depois));

  select count(distinct qup.questao_id) into v_dh_uteis_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.curso_conteudos cc on cc.id = up.curso_conteudo_id
    join public.assuntos a on a.id = cc.assunto_id
    where a.materia_id = 11;
  insert into _relatorio values ('dh_uteis_131_para_133', v_dh_uteis_depois = (select dh_uteis from _snapshot_antes) + 2, format('dh_uteis=%s', v_dh_uteis_depois));

  insert into _relatorio values ('total_questoes_cresceu_2',
    (select count(*) from public.questoes) = (select total_questoes from _snapshot_antes) + 2, 'total de questoes deve crescer exatamente 2');
  insert into _relatorio values ('total_alternativas_cresceu_9',
    (select count(*) from public.alternativas) = (select total_alternativas from _snapshot_antes) + 9, 'total de alternativas deve crescer exatamente 9');
  insert into _relatorio values ('total_vinculos_cresceu_2',
    (select count(*) from public.questao_unidades_pedagogicas) = (select total_vinculos from _snapshot_antes) + 2, 'total de vinculos deve crescer exatamente 2');
  insert into _relatorio values ('unidades_pedagogicas_inalteradas',
    (select count(*) from public.unidades_pedagogicas) = (select total_unidades from _snapshot_antes), 'nenhuma unidade nova deve ser criada');
  insert into _relatorio values ('curso_conteudos_inalterado',
    (select count(*) from public.curso_conteudos) = (select total_conteudos from _snapshot_antes), 'curso_conteudos nao deve mudar');
  insert into _relatorio values ('curso_questoes_inalterado',
    (select count(*) from public.curso_questoes) = (select total_curso_questoes from _snapshot_antes), 'curso_questoes nao deve sofrer alteracao');
  insert into _relatorio values ('respostas_inalteradas',
    (select count(*) from public.respostas_usuarios) = (select total_respostas from _snapshot_antes), 'historico de respostas_usuarios nao deve mudar');
  insert into _relatorio values ('sessoes_inalteradas',
    (select count(*) from public.sessoes_estudo) = (select total_sessoes from _snapshot_antes), 'sessoes_estudo nao deve mudar');
end $$;

-- Relatorio final — nunca aborta a transacao; so relata.
do $$
declare
  v_tudo_ok boolean;
  r record;
begin
  select bool_and(ok) into v_tudo_ok from _relatorio;

  raise notice '=== RELATORIO DO TESTE (importar_dh_real_lote5) ===';
  for r in select * from _relatorio order by etapa loop
    raise notice '% => % (%)', r.etapa, r.ok, r.detalhe;
  end loop;
  raise notice 'tudo_ok = %', coalesce(v_tudo_ok, false);
end $$;

-- SEMPRE desfaz — este arquivo nunca persiste nada.
rollback;
