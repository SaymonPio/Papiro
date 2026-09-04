-- Harness de teste (SEMPRE termina em ROLLBACK) do Lote 1 REAL de Direitos
-- Humanos e Cidadania — 2 questoes novas (DPE-PR/FUNDATEC/2024 Q26 e
-- SEAP-BA/FGV/2024 Q80) + 10 alternativas + 2 vinculos, ambas destinadas a
-- "Sistema Interamericano de Direitos Humanos" (curso_conteudo_id=85,
-- assunto_id=86, unidade_id=d815fc1f-82d3-4411-9dc5-63dae5373d2b).
--
-- Fonte da verdade: scripts/curadoria-pedagogica/relatorios/
-- pacote_importacao_dh_real_lote1_sistema_interamericano.json.
--
-- Origem: REAL em ambas (Fundatec e FGV) — nunca AUTORAL_PAPIRO. Gabaritos
-- e explicacoes recalculados de forma independente a partir dos PDFs
-- oficiais das provas e gabaritos definitivos (nao apenas do historico da
-- conversa). Explicitamente EXCLUIDAS deste lote: ENAM/FGV Q34 (REAL fora
-- do escopo atual de cc82), SEAS-CE/UECE-CEV Q11 (gabarito so confirmado
-- como preliminar) e DPE-AP/FCC Q94 (fonte oficial nao recuperada).
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
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 85) as cc85_uteis,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.questoes q on q.id = qup.questao_id where up.curso_conteudo_id = 85 and lower(q.banca) not like '%papiro%') as cc85_real,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 82) as cc82_uteis,
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
(1, 'd815fc1f-82d3-4411-9dc5-63dae5373d2b', 86, 'Fundatec', 'Concurso Público nº 01/2024 - DPE-PR - Defensor Público Substituto', 2024,
 'FUNDATEC — DPE-PR, Concurso Público nº 01/2024, Defensor Público Substituto — Questão 26',
 'Sobre o Sistema Interamericano de Proteção dos Direitos Humanos, é correto afirmar que:'),
(2, 'd815fc1f-82d3-4411-9dc5-63dae5373d2b', 86, 'FGV', 'Concurso Público - Edital 02/2024 - SEAP-BA - Agente Penitenciário', 2024,
 'FGV — SEAP-BA, Concurso Público Edital 02/2024, Agente Penitenciário, Prova Tipo 1 - Branca — Questão 80',
 'Sobre o sistema interamericano de direitos humanos, assinale a opção correta.');

create temporary table _lote_explicacoes (ordem int primary key, explicacao text) on commit drop;
insert into _lote_explicacoes (ordem, explicacao) values
(1, E'GABARITO: alternativa B\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nReproduz o art. 45, §1º, da Convenção Americana sobre Direitos Humanos (Pacto de San José da Costa Rica): todo Estado Parte pode, no momento do depósito do seu instrumento de ratificação ou adesão a esta Convenção, ou em qualquer momento posterior, declarar que reconhece a competência da Comissão para receber e examinar as comunicações em que um Estado Parte alegue haver outro Estado Parte incorrido em violações dos direitos humanos nela estabelecidos. Esse reconhecimento é FACULTATIVO e distinto da competência da Comissão para receber petições individuais (art. 44), que é automática para todo Estado Parte, sem necessidade de declaração adicional.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nAlternativa A: o art. 34 da CADH usa exatamente a expressão "pessoas de alta autoridade moral e de reconhecido saber em matéria de direitos humanos" para descrever os membros da Comissão, mas o número está errado — a Comissão é composta de 7 (sete) membros, não 11.\nAlternativa C: o art. 52 da CADH estabelece que a Corte é composta de 7 juízes nacionais dos Estados membros da OEA, mas exige expressamente que NÃO PODERÁ HAVER dois juízes da mesma nacionalidade — o oposto do que a alternativa afirma.\nAlternativa D: o art. 61 da CADH restringe a legitimidade para submeter caso à decisão da Corte aos Estados Partes e à própria Comissão — organizações internacionais de defesa dos direitos humanos não têm essa legitimidade; podem, no máximo, provocar a Comissão por meio de petição (art. 44).\nAlternativa E: o art. 67 da CADH estabelece que a sentença da Corte é definitiva e inapelável; não cabe recurso algum, muito menos em 10 dias — o artigo prevê apenas pedido de interpretação da sentença, em caso de divergência sobre seu sentido ou alcance, o que não é um recurso revisor do mérito.\n\nBIZU DE PROVA:\nComissão = 7 membros; Corte = 7 juízes (nunca 11 — essa é a troca numérica preferida da banca, "decore 7 e 7"); declarar competência da Comissão para queixas ENTRE ESTADOS é facultativo (art. 45), mas receber petição de indivíduo ou ONG é automático (art. 44); só Estado-Parte e Comissão podem levar caso à Corte (art. 61); sentença da Corte é definitiva e inapelável, só cabendo pedido de interpretação (art. 67).'),
(2, E'GABARITO: alternativa C\n\nPOR QUE A ALTERNATIVA CORRETA ESTÁ CORRETA:\nReproduz o art. 41, alínea "a", da Convenção Americana sobre Direitos Humanos: a Comissão Interamericana de Direitos Humanos tem como função principal promover a observância e a defesa dos direitos humanos e, no exercício do seu mandato, tem a função de estimular a consciência dos direitos humanos nos povos da América.\n\nPOR QUE AS DEMAIS ALTERNATIVAS ESTÃO INCORRETAS:\nAlternativa A: não existe "Corte internacional de direitos humanos" como órgão do sistema interamericano — o órgão correto é a Corte INTERAMERICANA de Direitos Humanos (CADH, art. 52), composta por 7 juízes eleitos a título pessoal dentre juristas da mais alta autoridade moral, e não "formada pelos Estados membros da OEA" diretamente.\nAlternativa B: a CADH foi de fato celebrada em San José da Costa Rica em 1969, mas o Brasil NÃO aderiu "nessa oportunidade" — o Brasil só depositou sua carta de adesão em 25/09/1992, mais de duas décadas depois, e desde então mantém reserva quanto ao reconhecimento automático da competência da Comissão em matéria de retenção de estrangeiro; a afirmação erra tanto o momento quanto a integralidade da adesão.\nAlternativa D: o art. 44 da CADH garante a QUALQUER pessoa, grupo de pessoas ou entidade não governamental legalmente reconhecida o direito de apresentar petição à Comissão, sem exigência de nacionalidade brasileira do peticionário.\nAlternativa E: o art. 52 da CADH estabelece que a Corte é composta de 7 (sete) juízes, não onze — mesma troca numérica clássica 7×11 encontrada na alternativa A da Q26/DPE-PR deste mesmo lote.\n\nBIZU DE PROVA:\nComissão "estimula a consciência dos direitos humanos" (art. 41-a) — função promocional, não apenas fiscalizatória; Brasil só aderiu à CADH em 1992, jamais em 1969; qualquer pessoa ou ONG pode peticionar à Comissão (art. 44), sem exigência de nacionalidade; a Corte tem sempre 7 juízes (nunca 11).');

create temporary table _lote_alternativas (
  ordem int,
  ordem_alt smallint,
  texto text,
  correta boolean
) on commit drop;

insert into _lote_alternativas (ordem, ordem_alt, texto, correta) values
(1,1,'A Comissão Interamericana de Direitos Humanos é composta por 11 membros, que deverão ser pessoas de alta autoridade moral e de reconhecido saber em matéria de direitos humanos.',false),
(1,2,'Todo Estado parte pode, no momento do depósito do instrumento de ratificação ou adesão à Convenção Americana de Direitos Humanos, ou em qualquer momento posterior, declarar que reconhece a competência da Comissão para receber e examinar as comunicações em que um Estado parte alegue haver outro Estado parte incorrido em violações dos direitos humanos estabelecidos nessa Convenção.',true),
(1,3,'A Corte Interamericana é composta de 7 juízes nacionais dos Estados membros da Organização, podendo haver dois juízes da mesma nacionalidade.',false),
(1,4,'Somente os Estados parte, a Comissão e organizações internacionais de defesa dos direitos humanos têm direito de submeter caso à decisão da Corte.',false),
(1,5,'A sentença da Corte será definitiva, podendo contra ela ser interposto recurso no prazo de 10 dias.',false),
(2,1,'É composto pela Corte internacional de direitos humanos, formada pelos Estados membros da Organização dos Estados Americanos (OEA).',false),
(2,2,'A Convenção Americana sobre direitos humanos foi celebrada em 1969, oportunidade em que o Brasil aderiu sem reservas a este documento.',false),
(2,3,'Cabe à Comissão Interamericana de direitos humanos estimular a consciência dos direitos humanos nos povos da América.',true),
(2,4,'Apenas os cidadãos brasileiros poderão apresentar à Comissão petições que contenham denúncias ou queixas de violação desta Convenção pelo Estado brasileiro.',false),
(2,5,'A Corte interamericana compor-se-á de onze juízes, nacionais dos Estados membros da OEA, sorteados dentre juristas de reconhecida competência em matéria de direitos humanos.',false);

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

  insert into _relatorio values ('cc85_estado_antes_esperado',
    (select cc85_uteis from _snapshot_antes) = 3 and (select cc85_real from _snapshot_antes) = 0,
    format('cc85_uteis=%s cc85_real=%s (esperado 3/0)', (select cc85_uteis from _snapshot_antes), (select cc85_real from _snapshot_antes)));
end $$;

-- Insercao das questoes + alternativas (mapeamento ordem -> id real).
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
  v_nao_ativas int;
  v_nao_real int;
  v_cc85_uteis_depois int;
  v_cc85_real_depois int;
  v_cc85_autoral_depois int;
  v_cc82_uteis_depois int;
  v_dh_uteis_depois int;
begin
  select count(*) into v_novas_questoes from public.questoes where id in (select questao_id from _mapa_ids);
  insert into _relatorio values ('2_questoes_criadas', v_novas_questoes = 2, format('questoes novas=%s (esperado 2)', v_novas_questoes));

  insert into _relatorio values ('ambas_materia_11',
    (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and materia_id <> 11) = 0, 'materia_id deve ser 11 em ambas');
  insert into _relatorio values ('ambas_assunto_86',
    (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and assunto_id <> 86) = 0, 'assunto_id deve ser 86 em ambas');
  insert into _relatorio values ('ambas_ativas',
    (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and ativa is distinct from true) = 0, 'ativa deve ser true em ambas');

  select count(*) into v_nao_real from public.questoes where id in (select questao_id from _mapa_ids) and lower(banca) like '%papiro%';
  insert into _relatorio values ('ambas_sao_real', v_nao_real = 0, format('%s questao(oes) com banca papiro (esperado 0 — Fundatec e FGV)', v_nao_real));

  select count(*) into v_novas_alternativas from public.alternativas where questao_id in (select questao_id from _mapa_ids);
  insert into _relatorio values ('10_alternativas_criadas', v_novas_alternativas = 10, format('alternativas novas=%s (esperado 10)', v_novas_alternativas));

  select count(*) into v_corretas_invalidas
  from (select questao_id, count(*) filter (where correta) as n from public.alternativas where questao_id in (select questao_id from _mapa_ids) group by questao_id having count(*) filter (where correta) <> 1) x;
  insert into _relatorio values ('1_correta_por_questao', v_corretas_invalidas = 0, format('%s questao(oes) sem exatamente 1 alternativa correta', v_corretas_invalidas));

  insert into _relatorio values ('gabaritos_B_e_C_nas_posicoes_certas',
    (select correta from public.alternativas a join _mapa_ids m on a.questao_id = m.questao_id where m.ordem = 1 and a.ordem = 2) is true
    and (select correta from public.alternativas a join _mapa_ids m on a.questao_id = m.questao_id where m.ordem = 2 and a.ordem = 3) is true,
    'Q26 (ordem 1) correta deve ser a alternativa de ordem 2 (B); Q80 (ordem 2) correta deve ser a de ordem 3 (C)');

  select count(*) into v_novos_vinculos from public.questao_unidades_pedagogicas where questao_id in (select questao_id from _mapa_ids);
  insert into _relatorio values ('2_vinculos_criados', v_novos_vinculos = 2, format('vinculos novos=%s (esperado 2)', v_novos_vinculos));

  select count(*) into v_multiunidade
  from (select questao_id from public.questao_unidades_pedagogicas where questao_id in (select questao_id from _mapa_ids) group by questao_id having count(*) > 1) x;
  insert into _relatorio values ('sem_multiunidade', v_multiunidade = 0, format('%s questao(oes) com mais de 1 vinculo', v_multiunidade));

  insert into _relatorio values ('ambos_vinculos_para_cc85',
    (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where qup.questao_id in (select questao_id from _mapa_ids) and up.curso_conteudo_id <> 85) = 0,
    'todos os vinculos novos devem apontar para cc85');

  select count(distinct qup.questao_id) into v_cc85_uteis_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    where up.curso_conteudo_id = 85;
  insert into _relatorio values ('cc85_uteis_3_para_5', v_cc85_uteis_depois = (select cc85_uteis from _snapshot_antes) + 2, format('cc85_uteis=%s', v_cc85_uteis_depois));

  select count(distinct qup.questao_id) into v_cc85_real_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.questoes q on q.id = qup.questao_id
    where up.curso_conteudo_id = 85 and lower(q.banca) not like '%papiro%';
  insert into _relatorio values ('cc85_real_0_para_2', v_cc85_real_depois = (select cc85_real from _snapshot_antes) + 2, format('cc85_real=%s', v_cc85_real_depois));

  select count(distinct qup.questao_id) into v_cc85_autoral_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.questoes q on q.id = qup.questao_id
    where up.curso_conteudo_id = 85 and lower(q.banca) like '%papiro%';
  insert into _relatorio values ('cc85_autoral_permanece_3', v_cc85_autoral_depois = 3, format('cc85_autoral=%s (esperado inalterado 3)', v_cc85_autoral_depois));

  select count(distinct qup.questao_id) into v_cc82_uteis_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    where up.curso_conteudo_id = 82;
  insert into _relatorio values ('cc82_nao_afetada', v_cc82_uteis_depois = (select cc82_uteis from _snapshot_antes), format('cc82_uteis=%s (nao deve mudar)', v_cc82_uteis_depois));

  select count(distinct qup.questao_id) into v_dh_uteis_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.curso_conteudos cc on cc.id = up.curso_conteudo_id
    join public.assuntos a on a.id = cc.assunto_id
    where a.materia_id = 11;
  insert into _relatorio values ('dh_uteis_124_para_126', v_dh_uteis_depois = (select dh_uteis from _snapshot_antes) + 2, format('dh_uteis=%s', v_dh_uteis_depois));

  insert into _relatorio values ('total_questoes_cresceu_2',
    (select count(*) from public.questoes) = (select total_questoes from _snapshot_antes) + 2, 'total de questoes deve crescer exatamente 2');
  insert into _relatorio values ('total_alternativas_cresceu_10',
    (select count(*) from public.alternativas) = (select total_alternativas from _snapshot_antes) + 10, 'total de alternativas deve crescer exatamente 10');
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

  raise notice '=== RELATORIO DO TESTE (importar_dh_real_lote1_sistema_interamericano) ===';
  for r in select * from _relatorio order by etapa loop
    raise notice '% => % (%)', r.etapa, r.ok, r.detalhe;
  end loop;
  raise notice 'tudo_ok = %', coalesce(v_tudo_ok, false);
end $$;

-- SEMPRE desfaz — este arquivo nunca persiste nada.
rollback;
