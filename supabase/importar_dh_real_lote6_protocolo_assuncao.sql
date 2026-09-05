-- Aplicacao REAL do Lote 6 REAL de Direitos Humanos e Cidadania — 1
-- questao nova + 5 alternativas + 1 vinculo, validado pelo harness
-- supabase/importar_dh_real_lote6_protocolo_assuncao_teste_rollback.sql
-- (tudo_ok = true precisa ser confirmado antes de rodar este arquivo).
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
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 92) as cc92_uteis,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.questoes q on q.id = qup.questao_id where up.curso_conteudo_id = 92 and lower(q.banca) not like '%papiro%') as cc92_real,
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
  where exists (
    select 1 from public.questoes q
    where q.materia_id = 11
      and coalesce(lower(q.banca), '') not like '%papiro%'
      and (q.enunciado ilike '%Protocolo de Assunção%' or q.enunciado ilike '%Protocolo de Assuncao%')
  );
  if v_dup <> 0 then
    raise exception 'Precondicao falhou: ja existe questao REAL sobre Protocolo de Assuncao em DH (possivel quase-duplicata)';
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

  if (select cc92_uteis from _snapshot_antes) <> 3 or (select cc92_real from _snapshot_antes) <> 0 then
    raise exception 'Precondicao falhou: cc92 nao esta no estado esperado (uteis=%, real=%; esperado 3/0)', (select cc92_uteis from _snapshot_antes), (select cc92_real from _snapshot_antes);
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
  v_gabA boolean;
  v_cc92_uteis_depois int;
  v_cc92_real_depois int;
  v_cc92_autoral_depois int;
  v_dh_uteis_depois int;
begin
  select count(*) into v_novas_questoes from public.questoes where id in (select questao_id from _mapa_ids);
  if v_novas_questoes <> 1 then
    raise exception 'Pos-condicao falhou: questoes novas=% (esperado 1)', v_novas_questoes;
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
    raise exception 'Pos-condicao falhou: % questao(oes) com banca papiro (esperado 0)', v_nao_real;
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

  select (correta) into v_gabA from public.alternativas a join _mapa_ids m on a.questao_id = m.questao_id where m.ordem = 1 and a.ordem = 2;
  if v_gabA is not true then
    raise exception 'Pos-condicao falhou: gabarito nao bate (Q-A deve ser ordem2=B)';
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

  if not exists (select 1 from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join _mapa_ids m on m.questao_id = qup.questao_id where m.ordem = 1 and up.curso_conteudo_id = 92) then
    raise exception 'Pos-condicao falhou: Q-A nao esta vinculada a cc92';
  end if;

  select count(distinct qup.questao_id) into v_cc92_uteis_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    where up.curso_conteudo_id = 92;
  if v_cc92_uteis_depois <> (select cc92_uteis from _snapshot_antes) + 1 then
    raise exception 'Pos-condicao falhou: cc92_uteis=% (esperado %)', v_cc92_uteis_depois, (select cc92_uteis from _snapshot_antes) + 1;
  end if;

  select count(distinct qup.questao_id) into v_cc92_real_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.questoes q on q.id = qup.questao_id
    where up.curso_conteudo_id = 92 and lower(q.banca) not like '%papiro%';
  if v_cc92_real_depois <> (select cc92_real from _snapshot_antes) + 1 then
    raise exception 'Pos-condicao falhou: cc92_real=% (esperado %)', v_cc92_real_depois, (select cc92_real from _snapshot_antes) + 1;
  end if;

  select count(distinct qup.questao_id) into v_cc92_autoral_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.questoes q on q.id = qup.questao_id
    where up.curso_conteudo_id = 92 and lower(q.banca) like '%papiro%';
  if v_cc92_autoral_depois <> 3 then
    raise exception 'Pos-condicao falhou: cc92_autoral=% (esperado inalterado 3)', v_cc92_autoral_depois;
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

  raise notice 'Pos-condicoes OK: 1 questao REAL nova (DPE-TO Q12) / 5 alternativas / 1 vinculo / cc92 uteis %->% real %->% / DH uteis %->%.',
    (select cc92_uteis from _snapshot_antes), v_cc92_uteis_depois,
    (select cc92_real from _snapshot_antes), v_cc92_real_depois,
    (select dh_uteis from _snapshot_antes), v_dh_uteis_depois;
end $$;

commit;
