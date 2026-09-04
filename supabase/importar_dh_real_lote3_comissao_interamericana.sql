-- Aplicacao REAL do Lote 3 REAL de Direitos Humanos e Cidadania — 1
-- questao nova (PC-MG/FGV/2025, Delegado de Policia Substituto, Q61) + 5
-- alternativas + 1 vinculo, validado pelo harness
-- supabase/importar_dh_real_lote3_comissao_interamericana_teste_rollback.sql
-- (tudo_ok = true precisa ser confirmado antes de rodar este arquivo).
--
-- Fonte da verdade: scripts/curadoria-pedagogica/relatorios/
-- pacote_importacao_dh_real_lote3_comissao_interamericana.json. Destino:
-- "Comissão Interamericana de Direitos Humanos" (curso_conteudo_id=87,
-- assunto_id=92, unidade_id=1b84fd2f-93e4-46c1-868f-c8402e73bdf9).
--
-- Origem: REAL (FGV) — nunca AUTORAL_PAPIRO. Prova e gabarito definitivo
-- confirmados 3x nesta sessao contra os PDFs oficiais
-- (delegado-de-policia-substitutocns101-tipo-1.pdf +
-- gabaritodefinitivo_pcgmpdelegado.pdf, ambos conhecimento.fgv.br).
-- Explicitamente EXCLUIDAS deste lote: OAB/FGV Q14 (fonte primaria nao
-- localizada), MPT Q20 (suspeita de numero de concurso incorreto +
-- taxonomia hibrida), PC-SP/VUNESP Q06 (reprovada na taxonomia de Belem
-- do Para) e DPE-PR/FUNDATEC Q27 (anulada pela banca).
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
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 87) as cc87_uteis,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.questoes q on q.id = qup.questao_id where up.curso_conteudo_id = 87 and lower(q.banca) not like '%papiro%') as cc87_real,
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
(1, '1b84fd2f-93e4-46c1-868f-c8402e73bdf9', 92, 'FGV', 'Concurso Público - Edital nº 01/2024 - PC-MG - Delegado de Polícia Substituto', 2025,
 'FGV — PC-MG, Concurso Público Edital nº 01/2024, Delegado de Polícia Substituto, Prova Tipo 1 - Branca — Questão 61',
 'Sobre a Comissão Interamericana de Direitos Humanos, assinale a afirmativa correta.');

create temporary table _lote_explicacoes (ordem int primary key, explicacao text) on commit drop;
insert into _lote_explicacoes (ordem, explicacao) values
(1, E'GABARITO: alternativa D\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nReproduz o art. 37 da Convenção Americana sobre Direitos Humanos: os membros da Comissão serão eleitos por quatro anos e só poderão ser reeleitos uma vez, mas o mandato de três dos membros designados na primeira eleição expirará ao cabo de dois anos (mandatos escalonados, para renovação parcial e periódica da composição).\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nAlternativa A: o art. 38 da CADH estabelece que as vagas que ocorram por motivo diverso da expiração normal do mandato serão preenchidas pelo Conselho Permanente da Organização, ouvido o parecer da Comissão — não pelo Presidente da Comissão.\nAlternativa B: o art. 34 da CADH exige que os 7 membros sejam nacionais de Estados diferentes — não pode haver dois nacionais do mesmo país na Comissão, mesmo que indicados por governos distintos.\nAlternativa C: o art. 34 da CADH estabelece que a Comissão é composta por 7 (sete) membros, não onze — mesma troca numérica 7×11 já vista em outras questões desta matéria (Comissão e Corte).\nAlternativa E: o art. 36 da CADH permite que cada governo proponha até 3 (três) candidatos, não cinco.\n\nBIZU DE PROVA:\nComissão = sempre 7 membros (nunca 11 — decore "7 e 7", já que a Corte também tem 7 juízes). Mandato de 4 anos, uma reeleição possível, com escalonamento inicial (3 dos primeiros membros ficam só 2 anos, para não haver troca total simultânea). Vagas fora do prazo normal são preenchidas pelo Conselho Permanente da OEA, não pela própria Comissão. Cada governo indica até 3 candidatos, que podem ser de qualquer Estado-membro da OEA (não precisam ser do próprio país que indica) — mas nunca mais de um nacional do mesmo país pode efetivamente compor a Comissão ao mesmo tempo.');

create temporary table _lote_alternativas (
  ordem int,
  ordem_alt smallint,
  texto text,
  correta boolean
) on commit drop;

insert into _lote_alternativas (ordem, ordem_alt, texto, correta) values
(1,1,'As vagas que ocorrerem na Comissão que não se devam à expiração normal do mandato serão preenchidas por pessoa indicada pelo Presidente da Comissão, desde que tenha reconhecido saber em matéria de direitos humanos.',false),
(1,2,'Pode fazer parte da Comissão mais de um nacional de um mesmo país, desde que indicado por mais de um dos governos dos Estados-membros.',false),
(1,3,'A Comissão Interamericana de Direitos Humanos compor-se-á de onze membros, que deverão ser pessoas de alta autoridade moral e de reconhecido saber em matéria de direitos humanos.',false),
(1,4,'Os membros da Comissão serão eleitos por quatro anos e só poderão ser reeleitos uma vez, porém o mandato de três dos membros designados na primeira eleição expirará ao cabo de dois anos.',true),
(1,5,'Cada um dos governos dos Estados-membros pode propor até cinco candidatos, nacionais do Estado que os propuser ou de qualquer outro Estado-membro da Organização dos Estados Americanos.',false);

-- Precondicoes.
do $$
declare
  v_cnt int;
  v_dup int;
begin
  select count(*) into v_cnt from _lote_questoes;
  if v_cnt <> 1 then
    raise exception 'Precondicao falhou: staging tem % questoes (esperado 1)', v_cnt;
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

  if (select cc87_uteis from _snapshot_antes) <> 3 or (select cc87_real from _snapshot_antes) <> 0 then
    raise exception 'Precondicao falhou: cc87 nao esta no estado esperado (uteis=%, real=%; esperado 3/0)', (select cc87_uteis from _snapshot_antes), (select cc87_real from _snapshot_antes);
  end if;
end $$;

-- Insercao da questao + alternativas.
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

-- Vinculo via RPC oficial.
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
  v_gabarito_ok boolean;
  v_cc87_uteis_depois int;
  v_cc87_real_depois int;
  v_cc87_autoral_depois int;
  v_dh_uteis_depois int;
begin
  select count(*) into v_novas_questoes from public.questoes where id in (select questao_id from _mapa_ids);
  if v_novas_questoes <> 1 then
    raise exception 'Pos-condicao falhou: questoes novas=% (esperado 1)', v_novas_questoes;
  end if;

  if (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and materia_id <> 11) <> 0 then
    raise exception 'Pos-condicao falhou: questao nao tem materia_id=11';
  end if;
  if (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and assunto_id <> 92) <> 0 then
    raise exception 'Pos-condicao falhou: questao nao tem assunto_id=92';
  end if;
  if (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and ativa is distinct from true) <> 0 then
    raise exception 'Pos-condicao falhou: questao nao esta ativa';
  end if;

  select count(*) into v_nao_real from public.questoes where id in (select questao_id from _mapa_ids) and lower(banca) like '%papiro%';
  if v_nao_real <> 0 then
    raise exception 'Pos-condicao falhou: % questao(oes) com banca papiro (esperado 0 — FGV)', v_nao_real;
  end if;

  select count(*) into v_novas_alternativas from public.alternativas where questao_id in (select questao_id from _mapa_ids);
  if v_novas_alternativas <> 5 then
    raise exception 'Pos-condicao falhou: alternativas novas=% (esperado 5)', v_novas_alternativas;
  end if;

  select count(*) into v_corretas_invalidas
  from (select questao_id, count(*) filter (where correta) as n from public.alternativas where questao_id in (select questao_id from _mapa_ids) group by questao_id having count(*) filter (where correta) <> 1) x;
  if v_corretas_invalidas <> 0 then
    raise exception 'Pos-condicao falhou: % questao(oes) sem exatamente 1 alternativa correta', v_corretas_invalidas;
  end if;

  select (correta) into v_gabarito_ok from public.alternativas a join _mapa_ids m on a.questao_id = m.questao_id where m.ordem = 1 and a.ordem = 4;
  if v_gabarito_ok is not true then
    raise exception 'Pos-condicao falhou: a alternativa correta nao e a de ordem 4 (D)';
  end if;

  select count(*) into v_novos_vinculos from public.questao_unidades_pedagogicas where questao_id in (select questao_id from _mapa_ids);
  if v_novos_vinculos <> 1 then
    raise exception 'Pos-condicao falhou: vinculos novos=% (esperado 1)', v_novos_vinculos;
  end if;

  select count(*) into v_multiunidade
  from (select questao_id from public.questao_unidades_pedagogicas where questao_id in (select questao_id from _mapa_ids) group by questao_id having count(*) > 1) x;
  if v_multiunidade <> 0 then
    raise exception 'Pos-condicao falhou: % questao(oes) com mais de 1 vinculo', v_multiunidade;
  end if;

  if (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where qup.questao_id in (select questao_id from _mapa_ids) and up.curso_conteudo_id <> 87) <> 0 then
    raise exception 'Pos-condicao falhou: o vinculo nao aponta para cc87';
  end if;

  select count(distinct qup.questao_id) into v_cc87_uteis_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    where up.curso_conteudo_id = 87;
  if v_cc87_uteis_depois <> (select cc87_uteis from _snapshot_antes) + 1 then
    raise exception 'Pos-condicao falhou: cc87_uteis=% (esperado %)', v_cc87_uteis_depois, (select cc87_uteis from _snapshot_antes) + 1;
  end if;

  select count(distinct qup.questao_id) into v_cc87_real_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.questoes q on q.id = qup.questao_id
    where up.curso_conteudo_id = 87 and lower(q.banca) not like '%papiro%';
  if v_cc87_real_depois <> (select cc87_real from _snapshot_antes) + 1 then
    raise exception 'Pos-condicao falhou: cc87_real=% (esperado %)', v_cc87_real_depois, (select cc87_real from _snapshot_antes) + 1;
  end if;

  select count(distinct qup.questao_id) into v_cc87_autoral_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.questoes q on q.id = qup.questao_id
    where up.curso_conteudo_id = 87 and lower(q.banca) like '%papiro%';
  if v_cc87_autoral_depois <> 3 then
    raise exception 'Pos-condicao falhou: cc87_autoral=% (esperado inalterado 3)', v_cc87_autoral_depois;
  end if;

  select count(distinct qup.questao_id) into v_dh_uteis_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.curso_conteudos cc on cc.id = up.curso_conteudo_id
    join public.assuntos a on a.id = cc.assunto_id
    where a.materia_id = 11;
  if v_dh_uteis_depois <> (select dh_uteis from _snapshot_antes) + 1 then
    raise exception 'Pos-condicao falhou: dh_uteis=% (esperado %)', v_dh_uteis_depois, (select dh_uteis from _snapshot_antes) + 1;
  end if;

  if (select count(*) from public.questoes) <> (select total_questoes from _snapshot_antes) + 1 then
    raise exception 'Pos-condicao falhou: total de questoes nao cresceu exatamente 1';
  end if;
  if (select count(*) from public.alternativas) <> (select total_alternativas from _snapshot_antes) + 5 then
    raise exception 'Pos-condicao falhou: total de alternativas nao cresceu exatamente 5';
  end if;
  if (select count(*) from public.questao_unidades_pedagogicas) <> (select total_vinculos from _snapshot_antes) + 1 then
    raise exception 'Pos-condicao falhou: total de vinculos nao cresceu exatamente 1';
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

  raise notice 'Pos-condicoes OK: 1 questao REAL nova (FGV/PC-MG Q61) / 5 alternativas / 1 vinculo / cc87 uteis %->% real %->% / DH uteis %->%.',
    (select cc87_uteis from _snapshot_antes), v_cc87_uteis_depois,
    (select cc87_real from _snapshot_antes), v_cc87_real_depois,
    (select dh_uteis from _snapshot_antes), v_dh_uteis_depois;
end $$;

commit;
