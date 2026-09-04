-- Aplicacao REAL do Lote 1 REAL de Direitos Humanos e Cidadania — 2
-- questoes novas (DPE-PR/FUNDATEC/2024 Q26 e SEAP-BA/FGV/2024 Q80) + 10
-- alternativas + 2 vinculos, validado pelo harness
-- supabase/importar_dh_real_lote1_sistema_interamericano_teste_rollback.sql
-- (tudo_ok = true precisa ser confirmado antes de rodar este arquivo).
--
-- Fonte da verdade: scripts/curadoria-pedagogica/relatorios/
-- pacote_importacao_dh_real_lote1_sistema_interamericano.json. Destino:
-- "Sistema Interamericano de Direitos Humanos" (curso_conteudo_id=85,
-- assunto_id=86, unidade_id=d815fc1f-82d3-4411-9dc5-63dae5373d2b).
--
-- Origem: REAL em ambas (Fundatec e FGV) — nunca AUTORAL_PAPIRO. Gabaritos
-- e explicacoes recalculados de forma independente a partir dos PDFs
-- oficiais das provas e gabaritos definitivos. Explicitamente EXCLUIDAS
-- deste lote: ENAM/FGV Q34 (REAL fora do escopo atual de cc82),
-- SEAS-CE/UECE-CEV Q11 (gabarito so confirmado como preliminar) e
-- DPE-AP/FCC Q94 (fonte oficial nao recuperada) — nenhuma delas aparece em
-- nenhuma linha abaixo.
--
-- Diferenca deste arquivo para o harness: termina em COMMIT, e cada
-- precondicao/pos-condicao usa RAISE EXCEPTION (nao apenas relatorio
-- booleano) — qualquer divergencia aborta a transacao inteira antes de
-- confirmar. Usa a mesma RPC administrativa oficial
-- classificar_questao_unidade_admin (nenhum INSERT direto em
-- questao_unidades_pedagogicas).
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
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 85) as cc85_uteis,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join public.questoes q on q.id = qup.questao_id where up.curso_conteudo_id = 85 and lower(q.banca) not like '%papiro%') as cc85_real,
  (select count(distinct qup.questao_id) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where up.curso_conteudo_id = 82) as cc82_uteis,
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
  if v_cnt <> 2 then
    raise exception 'Precondicao falhou: staging tem % questoes (esperado 2)', v_cnt;
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

  if (select cc85_uteis from _snapshot_antes) <> 3 or (select cc85_real from _snapshot_antes) <> 0 then
    raise exception 'Precondicao falhou: cc85 nao esta no estado esperado (uteis=%, real=%; esperado 3/0)', (select cc85_uteis from _snapshot_antes), (select cc85_real from _snapshot_antes);
  end if;
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
  v_cc85_uteis_depois int;
  v_cc85_real_depois int;
  v_cc85_autoral_depois int;
  v_cc82_uteis_depois int;
  v_dh_uteis_depois int;
  v_gab1 boolean;
  v_gab2 boolean;
begin
  select count(*) into v_novas_questoes from public.questoes where id in (select questao_id from _mapa_ids);
  if v_novas_questoes <> 2 then
    raise exception 'Pos-condicao falhou: questoes novas=% (esperado 2)', v_novas_questoes;
  end if;

  if (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and materia_id <> 11) <> 0 then
    raise exception 'Pos-condicao falhou: alguma questao nao tem materia_id=11';
  end if;
  if (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and assunto_id <> 86) <> 0 then
    raise exception 'Pos-condicao falhou: alguma questao nao tem assunto_id=86';
  end if;
  if (select count(*) from public.questoes where id in (select questao_id from _mapa_ids) and ativa is distinct from true) <> 0 then
    raise exception 'Pos-condicao falhou: alguma questao nao esta ativa';
  end if;

  select count(*) into v_nao_real from public.questoes where id in (select questao_id from _mapa_ids) and lower(banca) like '%papiro%';
  if v_nao_real <> 0 then
    raise exception 'Pos-condicao falhou: % questao(oes) com banca papiro (esperado 0 — Fundatec e FGV)', v_nao_real;
  end if;

  select count(*) into v_novas_alternativas from public.alternativas where questao_id in (select questao_id from _mapa_ids);
  if v_novas_alternativas <> 10 then
    raise exception 'Pos-condicao falhou: alternativas novas=% (esperado 10)', v_novas_alternativas;
  end if;

  select count(*) into v_corretas_invalidas
  from (select questao_id, count(*) filter (where correta) as n from public.alternativas where questao_id in (select questao_id from _mapa_ids) group by questao_id having count(*) filter (where correta) <> 1) x;
  if v_corretas_invalidas <> 0 then
    raise exception 'Pos-condicao falhou: % questao(oes) sem exatamente 1 alternativa correta', v_corretas_invalidas;
  end if;

  select (correta) into v_gab1 from public.alternativas a join _mapa_ids m on a.questao_id = m.questao_id where m.ordem = 1 and a.ordem = 2;
  select (correta) into v_gab2 from public.alternativas a join _mapa_ids m on a.questao_id = m.questao_id where m.ordem = 2 and a.ordem = 3;
  if v_gab1 is not true or v_gab2 is not true then
    raise exception 'Pos-condicao falhou: gabaritos nao batem (Q26 deveria ser a alternativa B=ordem 2; Q80 deveria ser a alternativa C=ordem 3)';
  end if;

  select count(*) into v_novos_vinculos from public.questao_unidades_pedagogicas where questao_id in (select questao_id from _mapa_ids);
  if v_novos_vinculos <> 2 then
    raise exception 'Pos-condicao falhou: vinculos novos=% (esperado 2)', v_novos_vinculos;
  end if;

  select count(*) into v_multiunidade
  from (select questao_id from public.questao_unidades_pedagogicas where questao_id in (select questao_id from _mapa_ids) group by questao_id having count(*) > 1) x;
  if v_multiunidade <> 0 then
    raise exception 'Pos-condicao falhou: % questao(oes) com mais de 1 vinculo', v_multiunidade;
  end if;

  if (select count(*) from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id where qup.questao_id in (select questao_id from _mapa_ids) and up.curso_conteudo_id <> 85) <> 0 then
    raise exception 'Pos-condicao falhou: algum vinculo nao aponta para cc85';
  end if;

  select count(distinct qup.questao_id) into v_cc85_uteis_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    where up.curso_conteudo_id = 85;
  if v_cc85_uteis_depois <> (select cc85_uteis from _snapshot_antes) + 2 then
    raise exception 'Pos-condicao falhou: cc85_uteis=% (esperado %)', v_cc85_uteis_depois, (select cc85_uteis from _snapshot_antes) + 2;
  end if;

  select count(distinct qup.questao_id) into v_cc85_real_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.questoes q on q.id = qup.questao_id
    where up.curso_conteudo_id = 85 and lower(q.banca) not like '%papiro%';
  if v_cc85_real_depois <> (select cc85_real from _snapshot_antes) + 2 then
    raise exception 'Pos-condicao falhou: cc85_real=% (esperado %)', v_cc85_real_depois, (select cc85_real from _snapshot_antes) + 2;
  end if;

  select count(distinct qup.questao_id) into v_cc85_autoral_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.questoes q on q.id = qup.questao_id
    where up.curso_conteudo_id = 85 and lower(q.banca) like '%papiro%';
  if v_cc85_autoral_depois <> 3 then
    raise exception 'Pos-condicao falhou: cc85_autoral=% (esperado inalterado 3)', v_cc85_autoral_depois;
  end if;

  select count(distinct qup.questao_id) into v_cc82_uteis_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    where up.curso_conteudo_id = 82;
  if v_cc82_uteis_depois <> (select cc82_uteis from _snapshot_antes) then
    raise exception 'Pos-condicao falhou: cc82_uteis=% (nao deveria mudar)', v_cc82_uteis_depois;
  end if;

  select count(distinct qup.questao_id) into v_dh_uteis_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.curso_conteudos cc on cc.id = up.curso_conteudo_id
    join public.assuntos a on a.id = cc.assunto_id
    where a.materia_id = 11;
  if v_dh_uteis_depois <> (select dh_uteis from _snapshot_antes) + 2 then
    raise exception 'Pos-condicao falhou: dh_uteis=% (esperado %)', v_dh_uteis_depois, (select dh_uteis from _snapshot_antes) + 2;
  end if;

  if (select count(*) from public.questoes) <> (select total_questoes from _snapshot_antes) + 2 then
    raise exception 'Pos-condicao falhou: total de questoes nao cresceu exatamente 2';
  end if;
  if (select count(*) from public.alternativas) <> (select total_alternativas from _snapshot_antes) + 10 then
    raise exception 'Pos-condicao falhou: total de alternativas nao cresceu exatamente 10';
  end if;
  if (select count(*) from public.questao_unidades_pedagogicas) <> (select total_vinculos from _snapshot_antes) + 2 then
    raise exception 'Pos-condicao falhou: total de vinculos nao cresceu exatamente 2';
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

  raise notice 'Pos-condicoes OK: 2 questoes REAL novas (Fundatec Q26 + FGV Q80) / 10 alternativas / 2 vinculos / 0 multiunidade / cc85 uteis %->% real %->% / cc82 inalterada / DH uteis %->%.',
    (select cc85_uteis from _snapshot_antes), v_cc85_uteis_depois,
    (select cc85_real from _snapshot_antes), v_cc85_real_depois,
    (select dh_uteis from _snapshot_antes), v_dh_uteis_depois;
end $$;

commit;
