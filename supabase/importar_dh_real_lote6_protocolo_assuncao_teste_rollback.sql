-- Harness de teste (SEMPRE termina em ROLLBACK) do Lote 6 REAL de Direitos
-- Humanos e Cidadania — 1 questao nova + 5 alternativas + 1 vinculo:
--
-- Q-A: DPE-TO/CEBRASPE/2022 Q12 (caderno 661_DPETO_001_01, IV Concurso
--      Publico, Defensor Publico Substituto, aplicada em 06/03/2022) ->
--      "Protocolo de Assuncao sobre Direitos Humanos no Mercosul"
--      (curso_conteudo_id=92, assunto_id=93,
--      unidade_id=655700d6-b585-468f-8d98-8143090cbafb). 5 alternativas
--      (A-E). Gabarito B.
--
-- Fonte da verdade: auditoria LIVE read-only DH-REAL-05 (etapa 2).
--
-- Origem: REAL — nunca AUTORAL_PAPIRO. Prova e gabarito definitivo
-- confirmados diretamente nos PDFs oficiais do dominio cdn.cebraspe.org.br
-- nesta sessao:
--   prova:  https://cdn.cebraspe.org.br/concursos/DPE_TO_21_DEFENSOR/arquivos/661_DPETO_001_01.PDF
--   gabarito definitivo: https://cdn.cebraspe.org.br/concursos/DPE_TO_21_DEFENSOR/arquivos/GAB_DEFINITIVO_661_DPETO_001_01.PDF
-- Questao 12, gabarito definitivo B, sem marca de anulacao. Destinada a
-- cc92 — a habilidade determinante exige o texto especifico do Protocolo
-- de Assuncao sobre Compromisso com a Promocao e Protecao dos Direitos
-- Humanos do MERCOSUL (Decreto no 7.225/2010), distinguindo-o do
-- Protocolo de Ushuaia (apenas mencionado na alternativa correta, sem
-- ser o objeto testado), do Tratado de Assuncao, de Ouro Preto e de
-- Olivos.
--
-- Demais candidatas do lote DH-REAL-05 (OAB VI/FGV/2012, ENAM/FGV/2024.1,
-- PC-SC/FEPESE/2017, DPE-BA/FCC/2016) NAO fazem parte deste pacote —
-- reprovadas/pendentes/EXIGE_DECISAO_PEDAGOGICA na auditoria da etapa 2.
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
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 92) as cc92_uteis,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.questoes q on q.id = qup.questao_id where up.curso_conteudo_id = 92 and lower(q.banca) not like '%papiro%') as cc92_real,
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
(1, '655700d6-b585-468f-8d98-8143090cbafb', 93, 'CEBRASPE', 'IV Concurso Público - DPE-TO - Defensor Público Substituto', 2022,
 'CEBRASPE — DPE-TO, IV Concurso Público, Defensor Público Substituto, Edital nº 1 – DPE/TO de 17/12/2021, aplicada em 06/03/2022 — Questão 12 (caderno 661_DPETO_001_01)',
 'No que tange ao Protocolo de Assunção, instrumento de promoção e proteção dos direitos humanos no MERCOSUL, assinale a opção correta.');

create temporary table _lote_explicacoes (ordem int primary key, explicacao text) on commit drop;
insert into _lote_explicacoes (ordem, explicacao) values
(1, E'GABARITO: alternativa B\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nO Protocolo de Assunção sobre Compromisso com a Promoção e Proteção dos Direitos Humanos do MERCOSUL (Decreto nº 7.225/2010) estabelece, já em seu art. 1º, que a plena vigência das instituições democráticas é condição essencial para a vigência e evolução do processo de integração do bloco, articulando expressamente essa referência às instituições democráticas com a promoção e proteção dos direitos humanos. Esse compromisso complementa outros instrumentos regionais do MERCOSUL voltados à cláusula democrática, como o Protocolo de Ushuaia.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nAlternativa A: o Protocolo de Assunção não tem aplicação indistinta a qualquer violação de direitos humanos; sua hipótese de incidência é a ocorrência de graves e sistemáticas violações aos direitos humanos, tal qual outros mecanismos regionais análogos — não se distingue deles por prescindir dessa gravidade/sistematicidade.\nAlternativa C: o protocolo não afasta sua aplicação em situações de crise institucional ou de estado de exceção previsto nos ordenamentos internos (como o Estado de Sítio brasileiro); ao contrário, é precisamente nesses cenários de ruptura ou ameaça institucional que o mecanismo se destina a atuar.\nAlternativa D: entre as medidas cabíveis estão a suspensão do direito de participar do processo de integração e a suspensão de outros direitos e obrigações decorrentes desse processo — mas o protocolo não prevê indenização pecuniária às vítimas e a seus familiares como medida contra o Estado-parte.\nAlternativa E: o protocolo não cria nenhum órgão denominado "Conselho de Direitos Humanos do Cone Sul"; não há previsão de tal estrutura de monitoramento no texto normativo.\n\nBIZU DE PROVA:\nProtocolo de Assunção sobre DH no MERCOSUL (Decreto 7.225/2010) = democracia como condição essencial (art. 1º), complementar ao Protocolo de Ushuaia. Incide apenas sobre violações GRAVES e SISTEMÁTICAS (não qualquer violação) e se aplica justamente nas crises institucionais/estados de exceção (não se afasta delas). Suas medidas são suspensão de participação no processo de integração e de outros direitos/obrigações — nunca indenização pecuniária individual. Não confundir com o Tratado de Assunção (1991, econômico), o Protocolo de Ouro Preto (estrutura institucional) ou o Protocolo de Olivos (solução de controvérsias) — nenhum deles trata do compromisso específico com direitos humanos, que é objeto exclusivo do Protocolo de Assunção sobre DH.');

create temporary table _lote_alternativas (
  ordem int,
  ordem_alt smallint,
  texto text,
  correta boolean
) on commit drop;

insert into _lote_alternativas (ordem, ordem_alt, texto, correta) values
(1,1,'O tratado tem plena aplicação, independentemente da intensidade da violação; assim, distingue-se de outros mecanismos, ao não se restringir à ocorrência de graves e sistemáticas violações aos direitos humanos.',false),
(1,2,'A referência às instituições democráticas como instrumento de assegurar os direitos humanos é um dos pontos mais importantes do tratado, complementando outros instrumentos regionais, como o Protocolo de Ushuaia.',true),
(1,3,'Esse tratado não se aplica em situações de crise institucional ou durante a vigência de estados de exceção previstos nos ordenamentos constitucionais, como, por exemplo, no Brasil, o Estado de Sítio.',false),
(1,4,'Entre as medidas previstas e cabíveis em caso de violação dos direitos humanos incluem-se a suspensão do direito a participar do processo de integração; a suspensão de outros direitos e obrigações; e a indenização pecuniária para as vítimas e seus familiares.',false),
(1,5,'De acordo com esse protocolo, monitoramento dos direitos humanos se dará por meio da criação do Conselho de Direitos Humanos do Cone Sul, órgão composto com representantes de todos os Estados-membros e associados.',false);

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
  where exists (
    select 1 from public.questoes q
    where q.materia_id = 11
      and coalesce(lower(q.banca), '') not like '%papiro%'
      and (q.enunciado ilike '%Protocolo de Assunção%' or q.enunciado ilike '%Protocolo de Assuncao%')
  );
  insert into _relatorio values ('sem_quase_duplicata_protocolo_assuncao', v_dup = 0, format('%s ocorrencia(s) previa(s) de questao REAL sobre Protocolo de Assuncao em DH', v_dup));

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

  insert into _relatorio values ('cc92_estado_antes_esperado',
    (select cc92_uteis from _snapshot_antes) = 3 and (select cc92_real from _snapshot_antes) = 0,
    format('cc92_uteis=%s cc92_real=%s (esperado 3/0)', (select cc92_uteis from _snapshot_antes), (select cc92_real from _snapshot_antes)));
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
  v_gabA boolean;
  v_cc92_uteis_depois int;
  v_cc92_real_depois int;
  v_cc92_autoral_depois int;
  v_dh_uteis_depois int;
begin
  select count(*) into v_novas_questoes from public.questoes where id in (select questao_id from _mapa_ids);
  insert into _relatorio values ('1_questao_criada', v_novas_questoes = 1, format('questoes novas=%s (esperado 1)', v_novas_questoes));

  insert into _relatorio values ('materia_11',
    (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and materia_id <> 11) = 0, 'materia_id deve ser 11');
  insert into _relatorio values ('assunto_id_correto',
    (select count(*) from public.questoes q join _mapa_ids m on m.questao_id = q.id join _lote_questoes lq on lq.ordem = m.ordem where q.assunto_id <> lq.assunto_id) = 0,
    'assunto_id da questao deve bater com o assunto_id do staging (Q-A=93)');
  insert into _relatorio values ('ativa',
    (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and ativa is distinct from true) = 0, 'ativa deve ser true');

  select count(*) into v_nao_real from public.questoes where id in (select questao_id from _mapa_ids) and lower(banca) like '%papiro%';
  insert into _relatorio values ('e_real', v_nao_real = 0, format('%s questao(oes) com banca papiro (esperado 0)', v_nao_real));

  select count(*) into v_novas_alternativas from public.alternativas where questao_id in (select questao_id from _mapa_ids);
  insert into _relatorio values ('exatamente_5_alternativas', v_novas_alternativas = 5, format('alternativas novas=%s (esperado 5)', v_novas_alternativas));

  select count(*) into v_corretas_invalidas
  from (select questao_id, count(*) filter (where correta) as n from public.alternativas where questao_id in (select questao_id from _mapa_ids) group by questao_id having count(*) filter (where correta) <> 1) x;
  insert into _relatorio values ('1_correta_por_questao', v_corretas_invalidas = 0, format('%s questao(oes) sem exatamente 1 alternativa correta', v_corretas_invalidas));

  select (correta) into v_gabA from public.alternativas a join _mapa_ids m on a.questao_id = m.questao_id where m.ordem = 1 and a.ordem = 2;
  insert into _relatorio values ('gabarito_correto',
    coalesce(v_gabA,false),
    'Q-A correta=ordem2(B)');

  select count(*) into v_novos_vinculos from public.questao_unidades_pedagogicas where questao_id in (select questao_id from _mapa_ids);
  insert into _relatorio values ('1_vinculo_criado', v_novos_vinculos = 1, format('vinculos novos=%s (esperado 1)', v_novos_vinculos));

  select count(*) into v_multiunidade
  from (select questao_id from public.questao_unidades_pedagogicas where questao_id in (select questao_id from _mapa_ids) group by questao_id having count(*) > 1) x;
  insert into _relatorio values ('sem_multiunidade', v_multiunidade = 0, format('%s questao(oes) com mais de 1 vinculo', v_multiunidade));

  insert into _relatorio values ('QA_vinculo_cc92',
    exists (select 1 from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join _mapa_ids m on m.questao_id = qup.questao_id where m.ordem = 1 and up.curso_conteudo_id = 92),
    'Q-A deve estar vinculada a cc92');

  select count(distinct qup.questao_id) into v_cc92_uteis_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    where up.curso_conteudo_id = 92;
  insert into _relatorio values ('cc92_uteis_3_para_4', v_cc92_uteis_depois = (select cc92_uteis from _snapshot_antes) + 1, format('cc92_uteis=%s', v_cc92_uteis_depois));

  select count(distinct qup.questao_id) into v_cc92_real_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.questoes q on q.id = qup.questao_id
    where up.curso_conteudo_id = 92 and lower(q.banca) not like '%papiro%';
  insert into _relatorio values ('cc92_real_0_para_1', v_cc92_real_depois = (select cc92_real from _snapshot_antes) + 1, format('cc92_real=%s', v_cc92_real_depois));

  select count(distinct qup.questao_id) into v_cc92_autoral_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.questoes q on q.id = qup.questao_id
    where up.curso_conteudo_id = 92 and lower(q.banca) like '%papiro%';
  insert into _relatorio values ('cc92_autoral_permanece_3', v_cc92_autoral_depois = 3, format('cc92_autoral=%s (esperado inalterado 3)', v_cc92_autoral_depois));

  select count(distinct qup.questao_id) into v_dh_uteis_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.curso_conteudos cc on cc.id = up.curso_conteudo_id
    join public.assuntos a on a.id = cc.assunto_id
    where a.materia_id = 11;
  insert into _relatorio values ('dh_uteis_133_para_134', v_dh_uteis_depois = (select dh_uteis from _snapshot_antes) + 1, format('dh_uteis=%s', v_dh_uteis_depois));

  insert into _relatorio values ('total_questoes_cresceu_1',
    (select count(*) from public.questoes) = (select total_questoes from _snapshot_antes) + 1, 'total de questoes deve crescer exatamente 1');
  insert into _relatorio values ('total_alternativas_cresceu_5',
    (select count(*) from public.alternativas) = (select total_alternativas from _snapshot_antes) + 5, 'total de alternativas deve crescer exatamente 5');
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

  raise notice '=== RELATORIO DO TESTE (importar_dh_real_lote6_protocolo_assuncao) ===';
  for r in select * from _relatorio order by etapa loop
    raise notice '% => % (%)', r.etapa, r.ok, r.detalhe;
  end loop;
  raise notice 'tudo_ok = %', coalesce(v_tudo_ok, false);
end $$;

-- SEMPRE desfaz — este arquivo nunca persiste nada.
rollback;
