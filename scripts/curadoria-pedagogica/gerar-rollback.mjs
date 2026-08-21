#!/usr/bin/env node
// Gera supabase/classificar_questoes_unidades_<slug>_teste_rollback.sql —
// Etapa 4 do pipeline.
//
// Deriva TUDO de config/<slug>.unidades.json + config/<slug>.mapa.json —
// nenhuma decisão nova é tomada aqui, só a mecânica de produzir o mesmo
// tipo de harness já usado em
// supabase/classificar_questoes_unidades_lei_drogas_teste_rollback.sql,
// supabase/classificar_questoes_unidades_improbidade_teste_rollback.sql e
// supabase/classificar_questoes_unidades_direitos_garantias_fundamentais_teste_rollback.sql:
// relatório booleano por checagem (nunca RAISE EXCEPTION), locks
// determinísticos via DO $$ ... PERFORM ... FOR UPDATE ... END $$ (nunca
// SELECT solto de nível superior — correção já aplicada na Lei de Drogas),
// aplicação via classificar_questao_unidade_admin com captura de exceção
// por linha, e SEMPRE termina em ROLLBACK.
//
// NUNCA executa SQL — só escreve o arquivo .sql local.
//
// Uso: node gerar-rollback.mjs <slug>

import {
  lerJson,
  escreverSql,
  caminhoConfigUnidades,
  caminhoConfigMapa,
  caminhoTesteRollback,
  escaparSql,
  calcularDerivados,
  ADMIN_USER_ID,
} from "./lib/comum.mjs";

const slug = process.argv[2];
if (!slug) {
  console.error("Uso: node gerar-rollback.mjs <slug>");
  process.exit(1);
}

const configUnidades = lerJson(caminhoConfigUnidades(slug));
const configMapa = lerJson(caminhoConfigMapa(slug));
const derivados = calcularDerivados(configUnidades, configMapa);

const materiaId = configUnidades.materia_id;
const assuntoId = configMapa.assunto_id;
const conteudoId = configUnidades.curso_conteudo_id;
const totalCandidatas = configMapa.total_candidatas_ativas;
const excluidas = configMapa.questoes_excluidas || [];

function linhasInsertMapa() {
  return [...configMapa.vinculos]
    .sort((a, b) => a.questao_id - b.questao_id || a.ordem_unidade - b.ordem_unidade)
    .map((v, i, arr) => {
      const virgula = i === arr.length - 1 ? "" : ",";
      return `  (${v.questao_id}, ${escaparSql(v.unidade_id)}, ${v.ordem_unidade}, ${escaparSql(v.confianca)})${virgula}`;
    })
    .join("\n");
}

function checagemUnidadesExistem() {
  const partes = derivados.unidades.map(
    (u) =>
      `    select exists (select 1 from public.unidades_pedagogicas where id = ${escaparSql(u.id)} and curso_conteudo_id = ${conteudoId} and ordem = ${u.ordem} and ativa) as ok`
  );
  const uniao = partes.join("\n    union all\n");
  return `
  select bool_and(x.ok) into v_unidades_ok from (
${uniao}
  ) x;

  insert into _relatorio values (
    'unidades_oficiais_existem',
    coalesce(v_unidades_ok, false),
    'todas as ${derivados.unidades.length} unidade(s) oficial(is) precisam existir, ativas, no conteudo ${conteudoId} — depende de curadoria_unidades_${slug}.sql ja aplicado'
  );`;
}

function checagemContagemPorUnidade() {
  return derivados.contagemPorUnidade
    .map(
      (u) => `
  select count(distinct qup.questao_id) into v_qtd_tmp
  from public.questao_unidades_pedagogicas qup
  where qup.unidade_pedagogica_id = ${escaparSql(u.unidade_id)};
  insert into _relatorio values ('u${u.ordem}_${u.qtd_questoes}_questoes', v_qtd_tmp = ${u.qtd_questoes}, format('u${u.ordem}_questoes=%s (esperado ${u.qtd_questoes})', v_qtd_tmp));`
    )
    .join("\n");
}

function checagemMultiunidade() {
  if (derivados.multiunidade.length === 0) {
    return `
  insert into _relatorio values ('nenhuma_multiunidade', v_multiunidade is null, format('multiunidade=%s (esperado nenhuma)', v_multiunidade));`;
  }
  const arr = `array[${derivados.multiunidade.join(",")}]::bigint[]`;
  return `
  insert into _relatorio values ('multiunidade_esperada', v_multiunidade is not distinct from ${arr}, format('multiunidade=%s (esperado {${derivados.multiunidade.join(
    ","
  )}})', v_multiunidade));`;
}

function checagemExcluidas() {
  if (excluidas.length === 0) return "";
  return excluidas
    .map(
      (e) => `
  select exists (
    select 1 from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where u.curso_conteudo_id = ${conteudoId} and qup.questao_id = ${e.questao_id}
  ) into v_excluida_tmp;
  insert into _relatorio values ('${e.questao_id}_permanece_nao_classificada', not coalesce(v_excluida_tmp, false), 'a questao ${e.questao_id} (${e.motivo.replace(/'/g, "")}) nao deve ter sido classificada por este arquivo');`
    )
    .join("\n");
}

function checagemMapaNaoContemExcluidas() {
  if (excluidas.length === 0) return "";
  const ids = excluidas.map((e) => e.questao_id);
  return `
  select exists (select 1 from _mapa where questao_id in (${ids.join(",")})) into v_contem_excluida;
  insert into _relatorio values (
    'mapa_nao_contem_excluidas',
    not coalesce(v_contem_excluida, false),
    'as questoes excluidas intencionalmente (${ids.join(", ")}) nao devem constar no mapa'
  );`;
}

const sql = `-- Harness de teste (SEMPRE termina em ROLLBACK) da classificacao de
-- questoes de ${configUnidades.nome_assunto} (curso_conteudos.id = ${conteudoId})
-- nas ${derivados.unidades.length} unidade(s) pedagogica(s) aprovada(s). Gerado pelo
-- pipeline automatico (scripts/curadoria-pedagogica/gerar-rollback.mjs) a
-- partir de config/${slug}.unidades.json + config/${slug}.mapa.json. Aplica o
-- mapa aprovado usando a RPC administrativa oficial
-- classificar_questao_unidade_admin (nenhum INSERT direto em
-- questao_unidades_pedagogicas), valida pre-condicoes e pos-condicoes, e
-- desfaz tudo ao final — nada aqui persiste no banco.
--
-- PRE-REQUISITO: supabase/curadoria_unidades_${slug}.sql precisa ja ter sido
-- aplicado antes de este harness ser executado — senao a precondicao de
-- unidades abaixo falha e o relatorio final aponta tudo_ok = false.
--
-- Diferenca deste arquivo para classificar_questoes_unidades_${slug}.sql
-- (etapa de aplicacao real): aqui cada verificacao alimenta um relatorio
-- booleano (tudo_ok), nunca aborta a transacao sozinha. Termina SEMPRE em
-- ROLLBACK, independentemente do resultado.

begin;

set local request.jwt.claim.sub = ${escaparSql(ADMIN_USER_ID)};

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
${linhasInsertMapa()};

create temporary table _relatorio (
  etapa text,
  ok boolean,
  detalhe text
) on commit drop;

-- Lock deterministico das linhas envolvidas antes de revalidar.
do $$
begin
  perform 1 from public.unidades_pedagogicas
  where curso_conteudo_id = ${conteudoId}
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
  where cc.id = ${conteudoId};

  insert into _relatorio values (
    'conteudo_${conteudoId}_materia_assunto',
    v_materia_id is not distinct from ${materiaId} and v_assunto_id is not distinct from ${assuntoId},
    format('materia_id=%s assunto_id=%s (esperado ${materiaId}/${assuntoId})', v_materia_id, v_assunto_id)
  );
${checagemUnidadesExistem()}

  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = ${conteudoId}) <> ${derivados.unidades.length} then
    insert into _relatorio values ('exatamente_${derivados.unidades.length}_unidade_s', false,
      format('unidades do conteudo ${conteudoId} = %s (esperado ${derivados.unidades.length})', (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = ${conteudoId})));
  else
    insert into _relatorio values ('exatamente_${derivados.unidades.length}_unidade_s', true, 'ok');
  end if;

  select count(*) into v_total_candidatas
  from public.questoes q
  join public.curso_conteudos cc on cc.id = ${conteudoId}
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where q.ativa = true
    and q.materia_id = cm.materia_id
    and (cc.assunto_id is null or q.assunto_id = cc.assunto_id);

  insert into _relatorio values (
    'total_candidatas_${totalCandidatas}',
    v_total_candidatas = ${totalCandidatas},
    format('total_candidatas=%s (esperado ${totalCandidatas})', v_total_candidatas)
  );

  select count(*) into v_classificacoes_previas
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = ${conteudoId}
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
  where not (q.ativa = true and q.materia_id = ${materiaId} and q.assunto_id = ${assuntoId});

  insert into _relatorio values (
    'mapa_todas_questoes_validas',
    v_invalidas = 0,
    format('%s linha(s) apontam para questao fora de ativa=true/materia_id=${materiaId}/assunto_id=${assuntoId}', v_invalidas)
  );

  select count(*) into v_distintas from (select distinct questao_id from _mapa) x;
  insert into _relatorio values (
    'mapa_cobre_${derivados.questoesDistintas}_distintas',
    v_distintas = ${derivados.questoesDistintas},
    format('mapa cobre %s questoes distintas (esperado ${derivados.questoesDistintas})', v_distintas)
  );
${checagemMapaNaoContemExcluidas()}

  select count(*) into v_fora_do_candidato
  from _mapa m
  where not exists (
    select 1
    from public.questoes q
    join public.curso_conteudos cc on cc.id = ${conteudoId}
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where q.id = m.questao_id
      and q.ativa = true
      and q.materia_id = cm.materia_id
      and (cc.assunto_id is null or q.assunto_id = cc.assunto_id)
  );
  insert into _relatorio values (
    'mapa_sem_linhas_fora_do_candidato',
    v_fora_do_candidato = 0,
    format('%s linha(s) fora do conjunto candidato de ${totalCandidatas} ativas', v_fora_do_candidato)
  );

  select count(*) into v_unidade_fora
  from _mapa m
  where m.unidade_pedagogica_id not in (select id from public.unidades_pedagogicas where curso_conteudo_id = ${conteudoId});
  insert into _relatorio values (
    'mapa_unidades_pertencem_ao_conteudo',
    v_unidade_fora = 0,
    format('%s linha(s) referenciam unidade pedagogica fora do conteudo ${conteudoId}', v_unidade_fora)
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
  where u.curso_conteudo_id = ${conteudoId};
  insert into _relatorio values ('total_vinculos_${derivados.totalVinculos}', v_total_vinculos = ${derivados.totalVinculos}, format('total_vinculos=%s (esperado ${derivados.totalVinculos})', v_total_vinculos));

  select count(distinct qup.questao_id) into v_questoes_classificadas
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = ${conteudoId};
  insert into _relatorio values ('questoes_classificadas_${derivados.questoesDistintas}', v_questoes_classificadas = ${derivados.questoesDistintas}, format('questoes_classificadas=%s (esperado ${derivados.questoesDistintas})', v_questoes_classificadas));

  select count(*) into v_fora_do_mapa
  from public.questao_unidades_pedagogicas qup
  join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
  where u.curso_conteudo_id = ${conteudoId}
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
    where u.curso_conteudo_id = ${conteudoId}
    group by qup.questao_id
    having count(*) > 1
  ) x;
${checagemMultiunidade()}
${checagemContagemPorUnidade()}
${checagemExcluidas()}

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
  insert into _relatorio values ('vinculos_cresceram_exatamente_${derivados.totalVinculos}',
    (select count(*) from public.questao_unidades_pedagogicas) = (select total_vinculos from _snapshot_antes) + ${derivados.totalVinculos},
    'total de vinculos deve crescer exatamente ${derivados.totalVinculos} em relacao ao snapshot antes');
end $$;

-- Relatorio final — nunca aborta a transacao; so relata.
do $$
declare
  v_tudo_ok boolean;
  r record;
begin
  select bool_and(ok) into v_tudo_ok from _relatorio;

  raise notice '=== RELATORIO DO TESTE (classificar_questoes_unidades_${slug}) ===';
  for r in select * from _relatorio order by etapa loop
    raise notice '% => % (%)', r.etapa, r.ok, r.detalhe;
  end loop;
  raise notice 'tudo_ok = %', coalesce(v_tudo_ok, false);
end $$;

-- SEMPRE desfaz — este arquivo nunca persiste nada.
rollback;
`;

escreverSql(caminhoTesteRollback(slug), sql);
console.log(`Gerado: supabase/classificar_questoes_unidades_${slug}_teste_rollback.sql`);
console.log("Nada foi executado no Supabase. Rode manualmente no SQL Editor e cole o resultado para eu conferir.");
