-- Harness de teste (SEMPRE termina em ROLLBACK) do Lote 2 REAL de Direitos
-- Humanos e Cidadania — 1 questao nova (SEAS-CE/UECE-CEV/2017 Q11,
-- Socioeducador) + 4 alternativas + 1 vinculo, destinada a "Sistema
-- Internacional de Proteção dos Direitos Humanos" (curso_conteudo_id=82,
-- assunto_id=83, unidade_id=522f7c40-b95e-4c91-b0d6-cf4a6f012c16).
--
-- Fonte da verdade: scripts/curadoria-pedagogica/relatorios/
-- pacote_importacao_dh_real_lote2_sistema_internacional.json.
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
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 82) as cc82_uteis,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.questoes q on q.id = qup.questao_id where up.curso_conteudo_id = 82 and lower(q.banca) not like '%papiro%') as cc82_real,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 85) as cc85_uteis,
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
  insert into _relatorio values ('staging_tem_1_questao', v_cnt = 1, format('staging=%s (esperado 1)', v_cnt));

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

  insert into _relatorio values ('cc82_estado_antes_esperado',
    (select cc82_uteis from _snapshot_antes) = 3 and (select cc82_real from _snapshot_antes) = 0,
    format('cc82_uteis=%s cc82_real=%s (esperado 3/0)', (select cc82_uteis from _snapshot_antes), (select cc82_real from _snapshot_antes)));
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
  v_gabarito_ok boolean;
  v_cc82_uteis_depois int;
  v_cc82_real_depois int;
  v_cc82_autoral_depois int;
  v_cc85_uteis_depois int;
  v_dh_uteis_depois int;
begin
  select count(*) into v_novas_questoes from public.questoes where id in (select questao_id from _mapa_ids);
  insert into _relatorio values ('1_questao_criada', v_novas_questoes = 1, format('questoes novas=%s (esperado 1)', v_novas_questoes));

  insert into _relatorio values ('materia_11',
    (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and materia_id <> 11) = 0, 'materia_id deve ser 11');
  insert into _relatorio values ('assunto_83',
    (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and assunto_id <> 83) = 0, 'assunto_id deve ser 83');
  insert into _relatorio values ('ativa',
    (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and ativa is distinct from true) = 0, 'ativa deve ser true');

  select count(*) into v_nao_real from public.questoes where id in (select questao_id from _mapa_ids) and lower(banca) like '%papiro%';
  insert into _relatorio values ('e_real', v_nao_real = 0, format('%s questao(oes) com banca papiro (esperado 0 — UECE-CEV)', v_nao_real));

  select count(*) into v_novas_alternativas from public.alternativas where questao_id in (select questao_id from _mapa_ids);
  insert into _relatorio values ('exatamente_4_alternativas', v_novas_alternativas = 4, format('alternativas novas=%s (esperado 4 — prova original sem alternativa E)', v_novas_alternativas));

  select count(*) into v_corretas_invalidas
  from (select questao_id, count(*) filter (where correta) as n from public.alternativas where questao_id in (select questao_id from _mapa_ids) group by questao_id having count(*) filter (where correta) <> 1) x;
  insert into _relatorio values ('1_correta', v_corretas_invalidas = 0, format('%s questao(oes) sem exatamente 1 alternativa correta', v_corretas_invalidas));

  select (correta) into v_gabarito_ok from public.alternativas a join _mapa_ids m on a.questao_id = m.questao_id where m.ordem = 1 and a.ordem = 1;
  insert into _relatorio values ('gabarito_A_ordem_1', coalesce(v_gabarito_ok, false), 'a correta deve ser a alternativa de ordem 1 (A)');

  select count(*) into v_novos_vinculos from public.questao_unidades_pedagogicas where questao_id in (select questao_id from _mapa_ids);
  insert into _relatorio values ('1_vinculo_criado', v_novos_vinculos = 1, format('vinculos novos=%s (esperado 1)', v_novos_vinculos));

  select count(*) into v_multiunidade
  from (select questao_id from public.questao_unidades_pedagogicas where questao_id in (select questao_id from _mapa_ids) group by questao_id having count(*) > 1) x;
  insert into _relatorio values ('sem_multiunidade', v_multiunidade = 0, format('%s questao(oes) com mais de 1 vinculo', v_multiunidade));

  insert into _relatorio values ('vinculo_para_cc82',
    (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where qup.questao_id in (select questao_id from _mapa_ids) and up.curso_conteudo_id <> 82) = 0,
    'o vinculo novo deve apontar para cc82');

  select count(distinct qup.questao_id) into v_cc82_uteis_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    where up.curso_conteudo_id = 82;
  insert into _relatorio values ('cc82_uteis_3_para_4', v_cc82_uteis_depois = (select cc82_uteis from _snapshot_antes) + 1, format('cc82_uteis=%s', v_cc82_uteis_depois));

  select count(distinct qup.questao_id) into v_cc82_real_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.questoes q on q.id = qup.questao_id
    where up.curso_conteudo_id = 82 and lower(q.banca) not like '%papiro%';
  insert into _relatorio values ('cc82_real_0_para_1', v_cc82_real_depois = (select cc82_real from _snapshot_antes) + 1, format('cc82_real=%s', v_cc82_real_depois));

  select count(distinct qup.questao_id) into v_cc82_autoral_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.questoes q on q.id = qup.questao_id
    where up.curso_conteudo_id = 82 and lower(q.banca) like '%papiro%';
  insert into _relatorio values ('cc82_autoral_permanece_3', v_cc82_autoral_depois = 3, format('cc82_autoral=%s (esperado inalterado 3)', v_cc82_autoral_depois));

  select count(distinct qup.questao_id) into v_cc85_uteis_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    where up.curso_conteudo_id = 85;
  insert into _relatorio values ('cc85_nao_afetada', v_cc85_uteis_depois = (select cc85_uteis from _snapshot_antes), format('cc85_uteis=%s (nao deve mudar, era %s)', v_cc85_uteis_depois, (select cc85_uteis from _snapshot_antes)));

  select count(distinct qup.questao_id) into v_dh_uteis_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.curso_conteudos cc on cc.id = up.curso_conteudo_id
    join public.assuntos a on a.id = cc.assunto_id
    where a.materia_id = 11;
  insert into _relatorio values ('dh_uteis_126_para_127', v_dh_uteis_depois = (select dh_uteis from _snapshot_antes) + 1, format('dh_uteis=%s', v_dh_uteis_depois));

  insert into _relatorio values ('total_questoes_cresceu_1',
    (select count(*) from public.questoes) = (select total_questoes from _snapshot_antes) + 1, 'total de questoes deve crescer exatamente 1');
  insert into _relatorio values ('total_alternativas_cresceu_4',
    (select count(*) from public.alternativas) = (select total_alternativas from _snapshot_antes) + 4, 'total de alternativas deve crescer exatamente 4');
  insert into _relatorio values ('total_vinculos_cresceu_1',
    (select count(*) from public.questao_unidades_pedagogicas) = (select total_vinculos from _snapshot_antes) + 1, 'total de vinculos deve crescer exatamente 1');
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

  raise notice '=== RELATORIO DO TESTE (importar_dh_real_lote2_sistema_internacional) ===';
  for r in select * from _relatorio order by etapa loop
    raise notice '% => % (%)', r.etapa, r.ok, r.detalhe;
  end loop;
  raise notice 'tudo_ok = %', coalesce(v_tudo_ok, false);
end $$;

-- SEMPRE desfaz — este arquivo nunca persiste nada.
rollback;
