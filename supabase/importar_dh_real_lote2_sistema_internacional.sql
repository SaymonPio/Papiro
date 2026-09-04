-- Aplicacao REAL do Lote 2 REAL de Direitos Humanos e Cidadania — 1
-- questao nova (SEAS-CE/UECE-CEV/2017 Q11, Socioeducador) + 4 alternativas
-- + 1 vinculo, validado pelo harness
-- supabase/importar_dh_real_lote2_sistema_internacional_teste_rollback.sql
-- (tudo_ok = true precisa ser confirmado antes de rodar este arquivo).
--
-- Fonte da verdade: scripts/curadoria-pedagogica/relatorios/
-- pacote_importacao_dh_real_lote2_sistema_internacional.json. Destino:
-- "Sistema Internacional de Proteção dos Direitos Humanos"
-- (curso_conteudo_id=82, assunto_id=83,
-- unidade_id=522f7c40-b95e-4c91-b0d6-cf4a6f012c16).
--
-- Pendencia documental anterior (so gabarito preliminar localizado) foi
-- RESOLVIDA: Comunicado no 47/2017-CEV/UECE, Anexo III, "Gabaritos
-- Oficiais Definitivos (apos recursos)", Nivel Medio - Socioeducador,
-- Gabarito 1, posicao 11 = A (identico ao preliminar, sem NULA/anulacao).
--
-- Origem: REAL (UECE-CEV) — nunca AUTORAL_PAPIRO. Prova original com
-- APENAS 4 alternativas (A-D) — nao criar alternativa E. Explicitamente
-- EXCLUIDAS deste lote: ENAM/FGV Q34 (REAL fora do escopo atual de cc82)
-- e DPE-AP/FCC Q94 (fonte oficial nao recuperada).
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
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 82) as cc82_uteis,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.questoes q on q.id = qup.questao_id where up.curso_conteudo_id = 82 and lower(q.banca) not like '%papiro%') as cc82_real,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 85) as cc85_uteis,
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
(1, '522f7c40-b95e-4c91-b0d6-cf4a6f012c16', 83, 'UECE-CEV', 'Edital nº 01/2017 - SEAS/SEPLAG - Socioeducador', 2017,
 'UECE-CEV — SEAS-CE, Edital nº 01/2017-SEAS/SEPLAG, Socioeducador — Questão 11 (Gabarito 1)',
 'Assinale a opção que apresenta somente documentos do sistema global de direitos humanos.');

create temporary table _lote_explicacoes (ordem int primary key, explicacao text) on commit drop;
insert into _lote_explicacoes (ordem, explicacao) values
(1, E'GABARITO: alternativa A\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nA Declaração Universal dos Direitos Humanos (1948) e os dois Pactos Internacionais de 1966 (Pacto Internacional sobre Direitos Civis e Políticos e Pacto Internacional sobre Direitos Econômicos, Sociais e Culturais) são os três instrumentos centrais do SISTEMA GLOBAL/UNIVERSAL de proteção dos direitos humanos, desenvolvido no âmbito da Organização das Nações Unidas. Nenhum dos três pertence a um sistema regional — a alternativa reúne exclusivamente documentos do sistema global.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nAlternativa B: mistura um instrumento do sistema GLOBAL (os Pactos de 1966) com um instrumento do sistema REGIONAL interamericano (a Convenção Americana sobre Direitos Humanos, Pacto de São José, celebrada no âmbito da OEA) — não é "somente" documentos do sistema global.\nAlternativa C: comete a mesma mistura — reúne a DUDH (sistema global) com a Convenção Americana/Pacto de São José (sistema regional interamericano).\nAlternativa D: reúne dois instrumentos exclusivamente do sistema REGIONAL interamericano (a Convenção Americana de Direitos Humanos e a Carta da Organização dos Estados Americanos) — nenhum dos dois pertence ao sistema global.\n\nBIZU DE PROVA:\nSistema GLOBAL/UNIVERSAL (ONU) = Declaração Universal (1948) + Pacto Internacional sobre Direitos Civis e Políticos (1966) + Pacto Internacional sobre Direitos Econômicos, Sociais e Culturais (1966). Sistema REGIONAL interamericano (OEA) = Carta da OEA + Convenção Americana/Pacto de São José (1969). Sempre que uma alternativa misturar um documento de cada "família", ela está errada; só está correta quando reúne exclusivamente documentos da mesma família.');

create temporary table _lote_alternativas (
  ordem int,
  ordem_alt smallint,
  texto text,
  correta boolean
) on commit drop;

insert into _lote_alternativas (ordem, ordem_alt, texto, correta) values
(1,1,'Declaração Universal dos Direitos Humanos, de 1948, e os Pactos sobre Direitos Civis e Políticos e sobre Direitos Econômicos, Sociais e Culturais, ambos de 1966.',true),
(1,2,'Convenção Americana de Direitos Humanos (Pacto de São José) e os Pactos sobre Direitos Civis e Políticos e sobre Direitos Econômicos, Sociais e Culturais, ambos de 1966.',false),
(1,3,'Declaração Universal dos Direitos Humanos, de 1948, e a Convenção Americana de Direitos Humanos (Pacto de São José).',false),
(1,4,'Convenção Americana de Direitos Humanos (Pacto de São José) e a Carta da Organização dos Estados Americanos (OEA).',false);

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

  if (select cc82_uteis from _snapshot_antes) <> 3 or (select cc82_real from _snapshot_antes) <> 0 then
    raise exception 'Precondicao falhou: cc82 nao esta no estado esperado (uteis=%, real=%; esperado 3/0)', (select cc82_uteis from _snapshot_antes), (select cc82_real from _snapshot_antes);
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
  v_cc82_uteis_depois int;
  v_cc82_real_depois int;
  v_cc82_autoral_depois int;
  v_cc85_uteis_depois int;
  v_dh_uteis_depois int;
begin
  select count(*) into v_novas_questoes from public.questoes where id in (select questao_id from _mapa_ids);
  if v_novas_questoes <> 1 then
    raise exception 'Pos-condicao falhou: questoes novas=% (esperado 1)', v_novas_questoes;
  end if;

  if (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and materia_id <> 11) <> 0 then
    raise exception 'Pos-condicao falhou: questao nao tem materia_id=11';
  end if;
  if (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and assunto_id <> 83) <> 0 then
    raise exception 'Pos-condicao falhou: questao nao tem assunto_id=83';
  end if;
  if (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and ativa is distinct from true) <> 0 then
    raise exception 'Pos-condicao falhou: questao nao esta ativa';
  end if;

  select count(*) into v_nao_real from public.questoes where id in (select questao_id from _mapa_ids) and lower(banca) like '%papiro%';
  if v_nao_real <> 0 then
    raise exception 'Pos-condicao falhou: % questao(oes) com banca papiro (esperado 0 — UECE-CEV)', v_nao_real;
  end if;

  select count(*) into v_novas_alternativas from public.alternativas where questao_id in (select questao_id from _mapa_ids);
  if v_novas_alternativas <> 4 then
    raise exception 'Pos-condicao falhou: alternativas novas=% (esperado 4 — prova original sem alternativa E)', v_novas_alternativas;
  end if;

  select count(*) into v_corretas_invalidas
  from (select questao_id, count(*) filter (where correta) as n from public.alternativas where questao_id in (select questao_id from _mapa_ids) group by questao_id having count(*) filter (where correta) <> 1) x;
  if v_corretas_invalidas <> 0 then
    raise exception 'Pos-condicao falhou: % questao(oes) sem exatamente 1 alternativa correta', v_corretas_invalidas;
  end if;

  select (correta) into v_gabarito_ok from public.alternativas a join _mapa_ids m on a.questao_id = m.questao_id where m.ordem = 1 and a.ordem = 1;
  if v_gabarito_ok is not true then
    raise exception 'Pos-condicao falhou: a alternativa correta nao e a de ordem 1 (A)';
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

  if (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where qup.questao_id in (select questao_id from _mapa_ids) and up.curso_conteudo_id <> 82) <> 0 then
    raise exception 'Pos-condicao falhou: o vinculo nao aponta para cc82';
  end if;

  select count(distinct qup.questao_id) into v_cc82_uteis_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    where up.curso_conteudo_id = 82;
  if v_cc82_uteis_depois <> (select cc82_uteis from _snapshot_antes) + 1 then
    raise exception 'Pos-condicao falhou: cc82_uteis=% (esperado %)', v_cc82_uteis_depois, (select cc82_uteis from _snapshot_antes) + 1;
  end if;

  select count(distinct qup.questao_id) into v_cc82_real_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.questoes q on q.id = qup.questao_id
    where up.curso_conteudo_id = 82 and lower(q.banca) not like '%papiro%';
  if v_cc82_real_depois <> (select cc82_real from _snapshot_antes) + 1 then
    raise exception 'Pos-condicao falhou: cc82_real=% (esperado %)', v_cc82_real_depois, (select cc82_real from _snapshot_antes) + 1;
  end if;

  select count(distinct qup.questao_id) into v_cc82_autoral_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.questoes q on q.id = qup.questao_id
    where up.curso_conteudo_id = 82 and lower(q.banca) like '%papiro%';
  if v_cc82_autoral_depois <> 3 then
    raise exception 'Pos-condicao falhou: cc82_autoral=% (esperado inalterado 3)', v_cc82_autoral_depois;
  end if;

  select count(distinct qup.questao_id) into v_cc85_uteis_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    where up.curso_conteudo_id = 85;
  if v_cc85_uteis_depois <> (select cc85_uteis from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: cc85_uteis=% (nao deveria mudar)', v_cc85_uteis_depois;
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
  if (select count(*) from public.alternativas) <> (select total_alternativas from _snapshot_antes) + 4 then
    raise exception 'Pos-condicao falhou: total de alternativas nao cresceu exatamente 4';
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

  raise notice 'Pos-condicoes OK: 1 questao REAL nova (UECE-CEV Q11) / 4 alternativas / 1 vinculo / cc82 uteis %->% real %->% / cc85 inalterada / DH uteis %->%.',
    (select cc82_uteis from _snapshot_antes), v_cc82_uteis_depois,
    (select cc82_real from _snapshot_antes), v_cc82_real_depois,
    (select dh_uteis from _snapshot_antes), v_dh_uteis_depois;
end $$;

commit;
