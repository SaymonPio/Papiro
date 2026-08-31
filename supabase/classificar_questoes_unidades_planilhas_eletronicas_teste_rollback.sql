-- Harness de teste (SEMPRE termina em ROLLBACK) da classificacao de
-- questoes de Planilhas eletrônicas (curso_conteudos.id = 37)
-- nas 1 unidade(s) pedagogica(s) aprovada(s). Gerado pelo
-- pipeline automatico (scripts/curadoria-pedagogica/gerar-rollback.mjs) a
-- partir de config/planilhas_eletronicas.unidades.json + config/planilhas_eletronicas.mapa.json. Aplica o
-- mapa aprovado usando a RPC administrativa oficial
-- classificar_questao_unidade_admin (nenhum INSERT direto em
-- questao_unidades_pedagogicas), valida pre-condicoes e pos-condicoes, e
-- desfaz tudo ao final — nada aqui persiste no banco.
--
-- PRE-REQUISITO: supabase/curadoria_unidades_planilhas_eletronicas.sql precisa ja ter sido
-- aplicado antes de este harness ser executado — senao a precondicao de
-- unidades abaixo falha e o relatorio final aponta tudo_ok = false.
--
-- Diferenca deste arquivo para classificar_questoes_unidades_planilhas_eletronicas.sql
-- (etapa de aplicacao real): aqui cada verificacao alimenta um relatorio
-- booleano (tudo_ok), nunca aborta a transacao sozinha. Termina SEMPRE em
-- ROLLBACK, independentemente do resultado.

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
  (select count(*) from public.questao_unidades_pedagogicas)  as total_vinculos;

create temporary table _mapa (
  questao_id bigint,
  unidade_pedagogica_id uuid,
  ordem_unidade int,
  confianca text
) on commit drop;

insert into _mapa (questao_id, unidade_pedagogica_id, ordem_unidade, confianca) values
  (33, 'd7635b99-48c1-4599-a014-68e8eb9ca3c2', 1, 'alta'),
  (62, 'd7635b99-48c1-4599-a014-68e8eb9ca3c2', 1, 'alta'),
  (93, 'd7635b99-48c1-4599-a014-68e8eb9ca3c2', 1, 'alta'),
  (97, 'd7635b99-48c1-4599-a014-68e8eb9ca3c2', 1, 'alta'),
  (105, 'd7635b99-48c1-4599-a014-68e8eb9ca3c2', 1, 'alta'),
  (109, 'd7635b99-48c1-4599-a014-68e8eb9ca3c2', 1, 'alta'),
  (340, 'd7635b99-48c1-4599-a014-68e8eb9ca3c2', 1, 'alta'),
  (492, 'd7635b99-48c1-4599-a014-68e8eb9ca3c2', 1, 'alta'),
  (493, 'd7635b99-48c1-4599-a014-68e8eb9ca3c2', 1, 'alta'),
  (498, 'd7635b99-48c1-4599-a014-68e8eb9ca3c2', 1, 'alta'),
  (637, 'd7635b99-48c1-4599-a014-68e8eb9ca3c2', 1, 'alta'),
  (638, 'd7635b99-48c1-4599-a014-68e8eb9ca3c2', 1, 'alta'),
  (834, 'd7635b99-48c1-4599-a014-68e8eb9ca3c2', 1, 'alta');

create temporary table _relatorio (
  etapa text,
  ok boolean,
  detalhe text
) on commit drop;

-- Lock deterministico das linhas envolvidas antes de revalidar.
do $$
begin
  perform 1 from public.unidades_pedagogicas
  where curso_conteudo_id = 37
  order by id
  for update;
end $$;

do $$
begin
  perform 1 from public.questoes
  where id in (select distinct questao_id from _mapa)
  order by id
  for update;
end $$;

-- Precondicoes.
do $$
declare
  v_materia_id bigint;
  v_assunto_id bigint;
  v_total_candidatas int;
  v_classificacoes_previas int;
  v_unidades_ok boolean;
begin
  select cm.materia_id, cc.assunto_id into v_materia_id, v_assunto_id
  from public.curso_conteudos cc
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where cc.id = 37;

  insert into _relatorio values (
    'conteudo_37_materia_assunto',
    v_materia_id is not distinct from 9 and v_assunto_id is not distinct from 29,
    format('materia_id=%s assunto_id=%s (esperado 9/29)', v_materia_id, v_assunto_id)
  );

  select bool_and(x.ok) into v_unidades_ok from (
    select exists (select 1 from public.unidades_pedagogicas where id = 'd7635b99-48c1-4599-a014-68e8eb9ca3c2' and curso_conteudo_id = 37 and ordem = 1 and ativa) as ok
  ) x;

  insert into _relatorio values (
    'unidades_oficiais_existem',
    coalesce(v_unidades_ok, false),
    'todas as 1 unidade(s) oficial(is) precisam existir, ativas, no conteudo 37 — depende de curadoria_unidades_planilhas_eletronicas.sql ja aplicado'
  );

  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 37) <> 1 then
    insert into _relatorio values ('exatamente_1_unidade_s', false,
      format('unidades do conteudo 37 = %s (esperado 1)', (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = 37)));
  else
    insert into _relatorio values ('exatamente_1_unidade_s', true, 'ok');
  end if;

  select count(*) into v_total_candidatas
  from public.questoes q
  join public.curso_conteudos cc on cc.id = 37
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where q.ativa = true
    and q.materia_id = cm.materia_id
    and (cc.assunto_id is null or q.assunto_id = cc.assunto_id);

  insert into _relatorio values (
    'total_candidatas_15',
    v_total_candidatas = 15,
    format('total_candidatas=%s (esperado 15)', v_total_candidatas)
  );

  select count(*) into v_classificacoes_previas
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 37
    and qup.questao_id in (select questao_id from _mapa);

  insert into _relatorio values (
    'sem_classificacao_previa',
    v_classificacoes_previas = 0,
    format('classificacoes_previas=%s (esperado 0)', v_classificacoes_previas)
  );
end $$;

-- Validacao do mapa em si.
do $$
declare
  v_invalidas int;
  v_fora_do_candidato int;
  v_unidade_fora int;
  v_distintas int;
  v_contem_excluida boolean;
begin
  select count(*) into v_invalidas
  from _mapa m
  join public.questoes q on q.id = m.questao_id
  where not (q.ativa = true and q.materia_id = 9 and q.assunto_id = 29);

  insert into _relatorio values (
    'mapa_todas_questoes_validas',
    v_invalidas = 0,
    format('%s linha(s) apontam para questao fora de ativa=true/materia_id=9/assunto_id=29', v_invalidas)
  );

  select count(*) into v_distintas from (select distinct questao_id from _mapa) x;
  insert into _relatorio values (
    'mapa_cobre_13_distintas',
    v_distintas = 13,
    format('mapa cobre %s questoes distintas (esperado 13)', v_distintas)
  );

  select exists (select 1 from _mapa where questao_id in (495,499)) into v_contem_excluida;
  insert into _relatorio values (
    'mapa_nao_contem_excluidas',
    not coalesce(v_contem_excluida, false),
    'as questoes excluidas intencionalmente (495, 499) nao devem constar no mapa'
  );

  select count(*) into v_fora_do_candidato
  from _mapa m
  where not exists (
    select 1
    from public.questoes q
    join public.curso_conteudos cc on cc.id = 37
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where q.id = m.questao_id
      and q.ativa = true
      and q.materia_id = cm.materia_id
      and (cc.assunto_id is null or q.assunto_id = cc.assunto_id)
  );
  insert into _relatorio values (
    'mapa_sem_linhas_fora_do_candidato',
    v_fora_do_candidato = 0,
    format('%s linha(s) fora do conjunto candidato de 15 ativas', v_fora_do_candidato)
  );

  select count(*) into v_unidade_fora
  from _mapa m
  where m.unidade_pedagogica_id not in (select id from public.unidades_pedagogicas where curso_conteudo_id = 37);
  insert into _relatorio values (
    'mapa_unidades_pertencem_ao_conteudo',
    v_unidade_fora = 0,
    format('%s linha(s) referenciam unidade pedagogica fora do conteudo 37', v_unidade_fora)
  );
end $$;

-- Aplicacao via RPC oficial (so prossegue com efeito real se as unidades
-- existirem — se a precondicao acima falhou, este loop simplesmente nao
-- encontra o que classificar corretamente e o relatorio final reprova).
do $$
declare r record;
begin
  for r in select questao_id, unidade_pedagogica_id from _mapa order by questao_id, unidade_pedagogica_id loop
    begin
      perform public.classificar_questao_unidade_admin(r.questao_id, r.unidade_pedagogica_id);
    exception when others then
      insert into _relatorio values (
        'aplicacao_rpc_sem_erro',
        false,
        format('erro ao classificar questao_id=%s unidade=%s: %s', r.questao_id, r.unidade_pedagogica_id, sqlerrm)
      );
    end;
  end loop;
end $$;

-- Pos-condicoes.
do $$
declare
  v_total_vinculos int;
  v_questoes_classificadas int;
  v_fora_do_mapa int;
  v_faltando int;
  v_multiunidade bigint[];
  v_qtd_tmp int;
  v_excluida_tmp boolean;
begin
  select count(*) into v_total_vinculos
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 37;
  insert into _relatorio values ('total_vinculos_13', v_total_vinculos = 13, format('total_vinculos=%s (esperado 13)', v_total_vinculos));

  select count(distinct qup.questao_id) into v_questoes_classificadas
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 37;
  insert into _relatorio values ('questoes_classificadas_13', v_questoes_classificadas = 13, format('questoes_classificadas=%s (esperado 13)', v_questoes_classificadas));

  select count(*) into v_fora_do_mapa
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = 37
    and not exists (select 1 from _mapa m where m.questao_id = qup.questao_id and m.unidade_pedagogica_id = qup.unidade_pedagogica_id);
  insert into _relatorio values ('sem_vinculo_fora_do_mapa', v_fora_do_mapa = 0, format('%s vinculo(s) fora do mapa aprovado', v_fora_do_mapa));

  select count(*) into v_faltando
  from _mapa m
  where not exists (select 1 from public.questao_unidades_pedagogicas qup where qup.questao_id = m.questao_id and qup.unidade_pedagogica_id = m.unidade_pedagogica_id);
  insert into _relatorio values ('mapa_aplicado_integralmente', v_faltando = 0, format('%s linha(s) do mapa nao foram aplicadas', v_faltando));

  select array_agg(questao_id order by questao_id) into v_multiunidade
  from (
    select qup.questao_id
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where u.curso_conteudo_id = 37
    group by qup.questao_id
    having count(*) > 1
  ) x;

  insert into _relatorio values ('nenhuma_multiunidade', v_multiunidade is null, format('multiunidade=%s (esperado nenhuma)', v_multiunidade));

  select count(distinct qup.questao_id) into v_qtd_tmp
  from public.questao_unidades_pedagogicas qup
  where qup.unidade_pedagogica_id = 'd7635b99-48c1-4599-a014-68e8eb9ca3c2';
  insert into _relatorio values ('u1_13_questoes', v_qtd_tmp = 13, format('u1_questoes=%s (esperado 13)', v_qtd_tmp));

  select exists (
    select 1 from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where u.curso_conteudo_id = 37 and qup.questao_id = 495
  ) into v_excluida_tmp;
  insert into _relatorio values ('495_permanece_nao_classificada', not coalesce(v_excluida_tmp, false), 'a questao 495 (PROBLEMA_DE_FIDELIDADE_IMAGEM_Q495 — CONFIRMADO POR FONTE PRIMÁRIA. Localizada e consultada a prova original (Fundatec, Guarda Municipal de Imbé/RS, concurso 01/2023, Questão 17 do caderno de Informática, mesmo PDF já usado para confirmar Q791 na ordem 79), que mostra que a tabela da questão (Figura 2) foi corretamente preservada em Markdown no Papiro (valores conferidos matematicamente: =SOMA(A1:C3)=290, não 50, batendo com a explicação armazenada), mas as assertivas II e III originalmente dependiam de ÍCONES GRÁFICOS SEM RÓTULO ("clique na opção [ícone]"; "a opção com a imagem [ícone] tem como funcionalidade inserir uma anotação") que o Papiro substituiu por descrições textuais nomeadas (ex.: "botão Formato numérico: moeda (ou Adicionar casa decimal)"; "ícone de balão de diálogo"), entregando ao aluno a informação que ele deveria reconhecer visualmente e alterando a habilidade nuclear de RECONHECIMENTO VISUAL DO ÍCONE para ASSOCIAÇÃO DE FUNÇÃO A UM ÍCONE JÁ DESCRITO POR ESCRITO. Q495 permanece ATIVA, INTACTA e SEM vínculo — não reconstruída, sem invenção de mídia, sem alteração de enunciado. Continua sendo evidência de INCIDÊNCIA REAL histórica (LibreOffice Calc e reconhecimento de ícones/funções foram efetivamente cobrados pela Fundatec), mas não pode ser prática específica vinculada enquanto a fidelidade visual estiver comprometida.) nao deve ter sido classificada por este arquivo');

  select exists (
    select 1 from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where u.curso_conteudo_id = 37 and qup.questao_id = 499
  ) into v_excluida_tmp;
  insert into _relatorio values ('499_permanece_nao_classificada', not coalesce(v_excluida_tmp, false), 'a questao 499 (DUPLICATA_DE_FONTE_REFORMULADA (canônica: Q105). Localizada e consultada a prova original (Fundatec, SUSEPE/Polícia Penal RS 01/2022, Questão 26 do caderno de Informática, PDF oficial via qconcursos), que confirma, palavra por palavra, o enunciado de Q499 ("A Figura 1 abaixo apresenta uma planilha no Microsoft Excel 2016: Assinale a alternativa cuja fórmula pode ser utilizada na célula C2 para exibir o maior número entre os valores das células A2 e B2") e as mesmas 5 alternativas (idênticas, mesma ordem, mesmo gabarito D = SE(A2>B2;A2;B2)) armazenadas tanto em Q105 quanto em Q499. Q105 e Q499 derivam da MESMA questão-fonte: Q499 preserva literalmente a moldura original ("A Figura 1 abaixo apresenta..."), com a figura efetivamente ausente no Papiro (perda de fidelidade adicional, não a razão principal da exclusão); Q105 é uma reformulação autossuficiente do mesmo enunciado, removendo a referência pendente à figura ausente, sem alterar alternativas, gabarito ou habilidade cognitiva testada. PRECEDENTE METODOLÓGICO: esta deduplicação só foi aprovada por haver evidência forte de mesma questão-fonte (mesma prova/questão numerada, alternativas idênticas, mesmo gabarito, mesma tarefa cognitiva) — reformulação de enunciado NÃO é motivo suficiente, por si só, para deduplicar; não generalizar para casos futuros que apenas cobrem a mesma função/fórmula ou pertencem à mesma prova sem essa evidência forte. Q499 permanece ATIVA, INTACTA e SEM vínculo — não editada, não transformada em nova questão, não contabilizada como segunda incidência histórica independente.) nao deve ter sido classificada por este arquivo');

  insert into _relatorio values ('unidades_pedagogicas_inalteradas_em_qtd',
    (select count(*) from public.unidades_pedagogicas) = (select total_unidades from _snapshot_antes),
    'esperado: nenhuma unidade nova criada por este arquivo (curadoria e um arquivo separado)');
  insert into _relatorio values ('questoes_inalteradas',
    (select count(*) from public.questoes) = (select total_questoes from _snapshot_antes), 'contagem de questoes nao deve mudar');
  insert into _relatorio values ('alternativas_inalteradas',
    (select count(*) from public.alternativas) = (select total_alternativas from _snapshot_antes), 'contagem de alternativas nao deve mudar');
  insert into _relatorio values ('conteudos_inalterados',
    (select count(*) from public.curso_conteudos) = (select total_conteudos from _snapshot_antes), 'contagem de curso_conteudos nao deve mudar');
  insert into _relatorio values ('curso_questoes_inalterado',
    (select count(*) from public.curso_questoes) = (select total_curso_questoes from _snapshot_antes), 'curso_questoes nao deve sofrer alteracao');
  insert into _relatorio values ('respostas_inalteradas',
    (select count(*) from public.respostas_usuarios) = (select total_respostas from _snapshot_antes), 'historico de respostas_usuarios nao deve mudar');
  insert into _relatorio values ('sessoes_inalteradas',
    (select count(*) from public.sessoes_estudo) = (select total_sessoes from _snapshot_antes), 'sessoes_estudo nao deve mudar');
  insert into _relatorio values ('vinculos_cresceram_exatamente_13',
    (select count(*) from public.questao_unidades_pedagogicas) = (select total_vinculos from _snapshot_antes) + 13,
    'total de vinculos deve crescer exatamente 13 em relacao ao snapshot antes');
end $$;

-- Relatorio final — nunca aborta a transacao; so relata.
do $$
declare
  v_tudo_ok boolean;
  r record;
begin
  select bool_and(ok) into v_tudo_ok from _relatorio;

  raise notice '=== RELATORIO DO TESTE (classificar_questoes_unidades_planilhas_eletronicas) ===';
  for r in select * from _relatorio order by etapa loop
    raise notice '% => % (%)', r.etapa, r.ok, r.detalhe;
  end loop;
  raise notice 'tudo_ok = %', coalesce(v_tudo_ok, false);
end $$;

-- SEMPRE desfaz — este arquivo nunca persiste nada.
rollback;
