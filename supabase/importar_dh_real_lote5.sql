-- Aplicacao REAL do Lote 5 REAL de Direitos Humanos e Cidadania — 2
-- questoes novas + 9 alternativas + 2 vinculos, validado pelo harness
-- supabase/importar_dh_real_lote5_teste_rollback.sql (tudo_ok = true
-- precisa ser confirmado antes de rodar este arquivo).
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
-- (nao 17). Q-B destinada a cc87 (Comissao), NAO a cc86 (OEA), apesar do
-- comando citar "Carta da OEA" — a habilidade determinante e a funcao
-- especifica da Comissao, ja textualmente presente no escopo de cc87.
-- Explicitamente EXCLUIDAS deste lote: PC-PB/CEBRASPE Q50, DPE-PI/CEBRASPE
-- Q64, ENAM/FGV Q37, DPE-BA/FCC 2016 e OAB VI Q14.
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

  if (select cc94_uteis from _snapshot_antes) <> 3 or (select cc94_real from _snapshot_antes) <> 0 then
    raise exception 'Precondicao falhou: cc94 nao esta no estado esperado (uteis=%, real=%; esperado 3/0)', (select cc94_uteis from _snapshot_antes), (select cc94_real from _snapshot_antes);
  end if;
  if (select cc87_uteis from _snapshot_antes) <> 4 or (select cc87_real from _snapshot_antes) <> 1 then
    raise exception 'Precondicao falhou: cc87 nao esta no estado esperado (uteis=%, real=%; esperado 4/1)', (select cc87_uteis from _snapshot_antes), (select cc87_real from _snapshot_antes);
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
  v_cc94_uteis_depois int;
  v_cc94_real_depois int;
  v_cc94_autoral_depois int;
  v_cc87_uteis_depois int;
  v_cc87_real_depois int;
  v_cc87_autoral_depois int;
  v_dh_uteis_depois int;
begin
  select count(*) into v_novas_questoes from public.questoes where id in (select questao_id from _mapa_ids);
  if v_novas_questoes <> 2 then
    raise exception 'Pos-condicao falhou: questoes novas=% (esperado 2)', v_novas_questoes;
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
  if v_novas_alternativas <> 9 then
    raise exception 'Pos-condicao falhou: alternativas novas=% (esperado 9)', v_novas_alternativas;
  end if;

  select count(*) into v_corretas_invalidas
  from (select questao_id, count(*) filter (where correta) as n from public.alternativas where questao_id in (select questao_id from _mapa_ids) group by questao_id having count(*) filter (where correta) <> 1) x;
  if v_corretas_invalidas <> 0 then
    raise exception 'Pos-condicao falhou: % questao(oes) sem exatamente 1 alternativa correta', v_corretas_invalidas;
  end if;

  select (correta) into v_gabA from public.alternativas a join _mapa_ids m on a.questao_id = m.questao_id where m.ordem = 1 and a.ordem = 3;
  select (correta) into v_gabB from public.alternativas a join _mapa_ids m on a.questao_id = m.questao_id where m.ordem = 2 and a.ordem = 3;
  if v_gabA is not true or v_gabB is not true then
    raise exception 'Pos-condicao falhou: gabaritos nao batem (Q-A e Q-B devem ser ordem3=C)';
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

  if not exists (select 1 from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join _mapa_ids m on m.questao_id = qup.questao_id where m.ordem = 1 and up.curso_conteudo_id = 94) then
    raise exception 'Pos-condicao falhou: Q-A nao esta vinculada a cc94';
  end if;
  if not exists (select 1 from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join _mapa_ids m on m.questao_id = qup.questao_id where m.ordem = 2 and up.curso_conteudo_id = 87) then
    raise exception 'Pos-condicao falhou: Q-B nao esta vinculada a cc87';
  end if;
  if exists (select 1 from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id join _mapa_ids m on m.questao_id = qup.questao_id where m.ordem = 2 and up.curso_conteudo_id = 86) then
    raise exception 'Pos-condicao falhou: Q-B foi indevidamente vinculada a cc86/OEA';
  end if;

  select count(distinct qup.questao_id) into v_cc94_uteis_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    where up.curso_conteudo_id = 94;
  if v_cc94_uteis_depois <> (select cc94_uteis from _snapshot_antes) + 1 then
    raise exception 'Pos-condicao falhou: cc94_uteis=% (esperado %)', v_cc94_uteis_depois, (select cc94_uteis from _snapshot_antes) + 1;
  end if;

  select count(distinct qup.questao_id) into v_cc94_real_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.questoes q on q.id = qup.questao_id
    where up.curso_conteudo_id = 94 and lower(q.banca) not like '%papiro%';
  if v_cc94_real_depois <> (select cc94_real from _snapshot_antes) + 1 then
    raise exception 'Pos-condicao falhou: cc94_real=% (esperado %)', v_cc94_real_depois, (select cc94_real from _snapshot_antes) + 1;
  end if;

  select count(distinct qup.questao_id) into v_cc94_autoral_depois
    from public.questao_unidades_pedagogicas qup join public.unidades_pedagogicas up on up.id = qup.unidade_pedagogica_id
    join public.questoes q on q.id = qup.questao_id
    where up.curso_conteudo_id = 94 and lower(q.banca) like '%papiro%';
  if v_cc94_autoral_depois <> 3 then
    raise exception 'Pos-condicao falhou: cc94_autoral=% (esperado inalterado 3)', v_cc94_autoral_depois;
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
  if v_dh_uteis_depois <> (select dh_uteis from _snapshot_antes) + 2 then
    raise exception 'Pos-condicao falhou: dh_uteis=% (esperado %)', v_dh_uteis_depois, (select dh_uteis from _snapshot_antes) + 2;
  end if;

  if (select count(*) from public.questoes) <> (select total_questoes from _snapshot_antes) + 2 then
    raise exception 'Pos-condicao falhou: total de questoes nao cresceu exatamente 2';
  end if;
  if (select count(*) from public.alternativas) <> (select total_alternativas from _snapshot_antes) + 9 then
    raise exception 'Pos-condicao falhou: total de alternativas nao cresceu exatamente 9';
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

  raise notice 'Pos-condicoes OK: 2 questoes REAL novas (OAB Q18, DPE-RO Q3) / 9 alternativas / 2 vinculos / cc94 uteis %->% real %->% / cc87 uteis %->% real %->% / DH uteis %->%.',
    (select cc94_uteis from _snapshot_antes), v_cc94_uteis_depois,
    (select cc94_real from _snapshot_antes), v_cc94_real_depois,
    (select cc87_uteis from _snapshot_antes), v_cc87_uteis_depois,
    (select cc87_real from _snapshot_antes), v_cc87_real_depois,
    (select dh_uteis from _snapshot_antes), v_dh_uteis_depois;
end $$;

commit;
