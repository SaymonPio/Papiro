#!/usr/bin/env node
// Gera supabase/aplicar_le1a_direitos_garantias_fundamentais_teste_rollback.sql
// a partir de scripts/le1a-direitos-garantias-fundamentais-explicacoes.mjs.
// NAO editar o .sql gerado a mao -- editar a fonte e regerar.

import fs from 'fs';
import { explicacoes } from './le1a-direitos-garantias-fundamentais-explicacoes.mjs';

const IDS_ESPERADOS = [46, 112, 298, 326, 657, 658, 660, 661, 662, 663, 723, 724, 725, 726, 727, 775, 797, 846, 847, 848, 849];
const OUT_PATH = 'supabase/aplicar_le1a_direitos_garantias_fundamentais_teste_rollback.sql';
const ADMIN_USUARIO_ID = 'e5523807-6cc8-4867-8a56-77c17552e56e';

if (explicacoes.length !== 21) throw new Error(`esperado 21 explicacoes, encontrado ${explicacoes.length}`);
const idsArquivo = explicacoes.map(e => e.id).sort((a, b) => a - b);
const idsEsperadosOrdenados = [...IDS_ESPERADOS].sort((a, b) => a - b);
if (JSON.stringify(idsArquivo) !== JSON.stringify(idsEsperadosOrdenados)) {
  throw new Error(`ids do arquivo nao batem com os esperados. arquivo=${idsArquivo} esperado=${idsEsperadosOrdenados}`);
}
if (idsArquivo.includes(659)) throw new Error('id 659 nao pode estar no arquivo de explicacoes');

function sqlString(s) {
  return `'${String(s).replace(/'/g, "''")}'`;
}

const idsLiteralArray = `ARRAY[${IDS_ESPERADOS.join(',')}]::bigint[]`;
const idsLiteralList = IDS_ESPERADOS.join(',');

const valuesRows = explicacoes
  .map(e => `(${e.id}, ${sqlString(e.explicacao)})`)
  .join(',\n');

const body = `BEGIN;

set local request.jwt.claim.sub = '${ADMIN_USUARIO_ID}';

-- ----------------------------------------------------------------------------
-- Staging: id -> nova explicacao (fonte: scripts/le1a-direitos-garantias-fundamentais-explicacoes.mjs).
-- ----------------------------------------------------------------------------
create temporary table _le1a_novas_explicacoes (id bigint primary key, explicacao text) on commit drop;
insert into _le1a_novas_explicacoes (id, explicacao) values
${valuesRows};

-- ----------------------------------------------------------------------------
-- Snapshot ANTES.
-- ----------------------------------------------------------------------------
-- 1) linha inteira das 21 (exceto explicacao/atualizado_em -- os unicos
-- campos autorizados a mudar).
create temporary table _le1a_snap_questoes on commit drop as
select id, (to_jsonb(q) - 'explicacao' - 'atualizado_em') as dados_imutaveis
from public.questoes q
where q.id in (${idsLiteralList});

-- 2) alternativas completas das 21.
create temporary table _le1a_snap_alternativas on commit drop as
select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
from public.alternativas a
where a.questao_id in (${idsLiteralList})
group by questao_id;

-- 3) controle negativo -- linha COMPLETA (inclusive explicacao/atualizado_em)
-- e alternativas da questao 659, que NAO deve ser tocada por este harness
-- em hipotese alguma.
create temporary table _le1a_snap_659 on commit drop as
select to_jsonb(q) as linha_completa
from public.questoes q where q.id = 659;

create temporary table _le1a_snap_659_alt on commit drop as
select jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
from public.alternativas a where a.questao_id = 659;

-- 4) hash de explicacao de TODAS as questoes do banco, para provar depois
-- que nenhuma linha fora das 21 teve explicacao alterada.
create temporary table _le1a_snap_hash_todas on commit drop as
select id, md5(coalesce(explicacao, '')) as hash_explicacao
from public.questoes;

-- 5) contagens globais.
create temporary table _le1a_snap_global on commit drop as
select
  (select count(*) from public.questoes)            as total_questoes_antes,
  (select count(*) from public.questoes where ativa) as total_ativas_antes;

create temporary table _le1a_asserts (ordem serial primary key, descricao text, ok boolean) on commit drop;

-- ----------------------------------------------------------------------------
-- Precondicoes.
-- ----------------------------------------------------------------------------
do $$
declare
  v_qtd int;
begin
  if (select count(*) from _le1a_novas_explicacoes) <> 21 then
    raise exception 'PRECONDICAO FALHOU: staging nao tem exatamente 21 explicacoes';
  end if;

  select count(*) into v_qtd from public.questoes where id in (select id from _le1a_novas_explicacoes);
  if v_qtd <> 21 then
    raise exception 'PRECONDICAO FALHOU: esperado 21 questoes no banco, encontrado %', v_qtd;
  end if;

  if exists (
    select 1 from public.questoes q
    join _le1a_novas_explicacoes s on s.id = q.id
    where q.assunto_id is distinct from 71 or q.materia_id is distinct from 10 or q.ativa is distinct from true
  ) then
    raise exception 'PRECONDICAO FALHOU: alguma das 21 nao esta mais no estado auditado (assunto_id=71, materia_id=10, ativa=true)';
  end if;

  if not exists (select 1 from public.questoes where id = 659) then
    raise exception 'PRECONDICAO FALHOU: questao 659 nao encontrada -- o controle negativo depende dela existir';
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ESCRITA (unica): atualiza explicacao + atualizado_em das 21, capturando os
-- ids efetivamente afetados. Questao 659 nunca aparece em _le1a_novas_explicacoes,
-- logo nunca pode ser tocada por este UPDATE.
-- ----------------------------------------------------------------------------
create temporary table _le1a_ids_afetados (id bigint primary key) on commit drop;

do $$
declare
  v_linhas int;
begin
  with atualizado as (
    update public.questoes q
    set explicacao = s.explicacao, atualizado_em = now()
    from _le1a_novas_explicacoes s
    where q.id = s.id
    returning q.id
  )
  insert into _le1a_ids_afetados (id) select id from atualizado;

  get diagnostics v_linhas = row_count;
  if v_linhas <> 21 then
    raise exception 'ESCRITA FALHOU: esperado UPDATE de exatamente 21 linhas, afetou %', v_linhas;
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ASSERTS pos-escrita.
-- ----------------------------------------------------------------------------
do $$
declare
  v_completas int;
  v_total_depois int;
  v_ativas_depois int;
  v_sem_correta int;
begin
  insert into _le1a_asserts (descricao, ok)
  select 'exatamente 21 questoes afetadas pelo UPDATE', (select count(*) from _le1a_ids_afetados) = 21;

  insert into _le1a_asserts (descricao, ok)
  select 'os ids afetados sao exatamente os 21 esperados',
    (select array_agg(id order by id) from _le1a_ids_afetados) = ${idsLiteralArray};

  insert into _le1a_asserts (descricao, ok)
  select 'questao 659 nao foi alterada (linha inteira identica, inclusive explicacao/atualizado_em)',
    (select to_jsonb(q) from public.questoes q where q.id = 659) = (select linha_completa from _le1a_snap_659);

  insert into _le1a_asserts (descricao, ok)
  select 'alternativas da questao 659 continuam identicas',
    (select jsonb_agg(to_jsonb(a) order by a.ordem) from public.alternativas a where a.questao_id = 659) = (select alternativas from _le1a_snap_659_alt);

  insert into _le1a_asserts (descricao, ok)
  select 'enunciado/alternativas-relacao/gabarito/materia/assunto/ativa/banca/concurso/ano/fonte preservados nas 21 (comparacao jsonb byte-a-byte, exceto explicacao/atualizado_em)',
    not exists (
      select 1 from public.questoes q
      join _le1a_snap_questoes s on s.id = q.id
      where (to_jsonb(q) - 'explicacao' - 'atualizado_em') <> s.dados_imutaveis
    );

  insert into _le1a_asserts (descricao, ok)
  select 'alternativas das 21 continuam byte-identicas (texto/correta/ordem)',
    not exists (
      select 1
      from _le1a_snap_alternativas s
      join (
        select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
        from public.alternativas a
        where a.questao_id in (select id from _le1a_novas_explicacoes)
        group by questao_id
      ) d on d.questao_id = s.questao_id
      where d.alternativas <> s.alternativas
    );

  select count(*) into v_sem_correta
  from _le1a_novas_explicacoes s
  where (select count(*) from public.alternativas a where a.questao_id = s.id and a.correta) <> 1;
  insert into _le1a_asserts (descricao, ok) values ('as 21 continuam com exatamente 1 alternativa correta cada', v_sem_correta = 0);

  -- Classificacao EXPLICACAO_COMPLETA das 21 apos o UPDATE (mesma logica de
  -- supabase/classificar_explicacoes_questoes.sql).
  with alt_stats as (
    select q.id as questao_id, count(a.id) as n_alt, count(a.id) filter (where a.correta) as n_corretas,
      bool_and(lower(btrim(a.texto)) in ('certo', 'errado')) and count(a.id) = 2 as eh_certo_errado
    from public.questoes q
    left join public.alternativas a on a.questao_id = q.id
    where q.id in (select id from _le1a_novas_explicacoes)
    group by q.id
  ),
  classificado as (
    select q.id,
      case
        when q.explicacao is null or btrim(q.explicacao) = '' then 'SEM_EXPLICACAO'
        when s.n_corretas <> 1 or s.n_alt = 0 then 'PROBLEMATICA'
        when s.eh_certo_errado then
          case
            when q.explicacao ~* 'GABARITO\\s*:\\s*(CERTO|ERRADO)' and q.explicacao ~* 'POR QUE\\s*:' and q.explicacao ~* 'BIZU DE PROVA'
              then 'EXPLICACAO_COMPLETA'
            else 'OUTRO'
          end
        else
          case
            when q.explicacao ~* 'GABARITO\\s*:' and q.explicacao ~* 'BIZU DE PROVA'
             and (select count(distinct m[1]) from regexp_matches(q.explicacao, 'POR QUE A ALTERNATIVA\\s+([A-E])\\s+EST[ÁA]\\s+(CORRETA|INCORRETA)', 'gi') as m) >= s.n_alt
              then 'EXPLICACAO_COMPLETA'
            else 'OUTRO'
          end
      end as status
    from public.questoes q
    join alt_stats s on s.questao_id = q.id
    where q.id in (select id from _le1a_novas_explicacoes)
  )
  select count(*) filter (where status = 'EXPLICACAO_COMPLETA') into v_completas from classificado;
  insert into _le1a_asserts (descricao, ok) values ('as 21 passam no classificador canonico como EXPLICACAO_COMPLETA', v_completas = 21);

  insert into _le1a_asserts (descricao, ok)
  select 'nenhuma outra questao do banco teve explicacao alterada',
    not exists (
      select 1 from public.questoes q
      join _le1a_snap_hash_todas s on s.id = q.id
      where md5(coalesce(q.explicacao, '')) <> s.hash_explicacao
        and q.id <> ALL(${idsLiteralArray})
    );

  select count(*) into v_total_depois from public.questoes;
  insert into _le1a_asserts (descricao, ok) values ('total de questoes no banco inalterado (nenhuma criada/excluida)', v_total_depois = (select total_questoes_antes from _le1a_snap_global));

  select count(*) into v_ativas_depois from public.questoes where ativa = true;
  insert into _le1a_asserts (descricao, ok) values ('total de questoes ATIVAS do Papiro inalterado', v_ativas_depois = (select total_ativas_antes from _le1a_snap_global));
end $$;

-- Percorre os asserts na ordem em que foram inseridos, reportando cada um
-- (RAISE NOTICE) e abortando a transacao inteira no primeiro que falhar
-- (RAISE EXCEPTION). A tabela _le1a_asserts desaparece sozinha ao fim da
-- transacao (ON COMMIT DROP).
do $$
declare
  r record;
  v_total integer;
  v_ok integer;
begin
  for r in select descricao, ok from _le1a_asserts order by ordem loop
    if r.ok then
      raise notice 'OK: %', r.descricao;
    else
      raise exception 'FALHOU: %', r.descricao;
    end if;
  end loop;

  select count(*), count(*) filter (where ok) into v_total, v_ok from _le1a_asserts;
  raise notice '=== RESUMO: % / % asserts passaram ===', v_ok, v_total;
  if v_ok <> v_total then
    raise exception 'Harness falhou: nem todos os asserts passaram (ver RESUMO acima).';
  end if;
end $$;
`;

const header = `-- ============================================================================
-- AUDITORIA GLOBAL -- PRIORIDADE 1 (LEGISLACAO ESPECIFICA) -- LE-1a
-- Aplicacao de 21 explicacoes pedagogicas -- Direitos e Garantias
-- Fundamentais (assunto_id 71, materia_id 10)
-- IDs: ${idsLiteralList}
-- HARNESS TRANSACIONAL -- TERMINA SEMPRE EM ROLLBACK, NADA PERSISTE.
-- ============================================================================
--
-- Gerado automaticamente por scripts/generate-le1a-harness.mjs a partir de
-- scripts/le1a-direitos-garantias-fundamentais-explicacoes.mjs. NAO editar
-- este arquivo a mao -- editar a fonte e regerar.
--
-- Contexto: primeiro sublote (LE-1a) da Prioridade 1 (Legislacao Especifica)
-- da auditoria global de explicacoes do Papiro. Das 22 questoes do assunto
-- "Direitos e Garantias Fundamentais", 21 foram auditadas juridicamente e
-- classificadas VALIDA (texto do art. 5o e art. 1o da CF/88 conferido
-- dispositivo a dispositivo; nenhuma Emenda Constitucional entre 2023-2026
-- alterou os incisos testados). A questao id 659 foi classificada
-- PROBLEMATICA (enunciado truncado/corrompido: termina em "...e garantido("
-- com parenteses nao fechado) e fica INTEIRAMENTE FORA deste harness --
-- nao recebe explicacao, nao e tocada de forma alguma.
--
-- Escopo estrito: altera SOMENTE \`explicacao\` (+ \`atualizado_em\` -- esta
-- tabela nao tem trigger de auto-atualizacao, por isso e setado
-- explicitamente) para exatamente os 21 ids listados acima. Nenhuma outra
-- coluna, nenhuma outra linha, nenhuma tabela relacionada (alternativas,
-- curso_questoes, questao_unidades_pedagogicas) e tocada. Os asserts abaixo
-- provam isso por comparacao jsonb byte-a-byte (incluindo um controle
-- negativo explicito sobre a questao 659) e por hash de explicacao de TODAS
-- as questoes do banco, nao so pela leitura do UPDATE em si.
--
-- Sem objetos permanentes: todo o rastreio de asserts usa apenas CREATE
-- TEMPORARY TABLE ... ON COMMIT DROP e blocos DO $$ ... $$ inline (sem
-- CREATE FUNCTION/PROCEDURE), mesmo padrao adotado na Fase 3C e na
-- desativacao das questoes 1337/1340.
--
-- Usa a MESMA simulacao de claim JWT do admin cadastrado (via "set local"),
-- restrita a esta transacao, no mesmo padrao ja usado nos harnesses
-- anteriores. Precisa rodar com um role de ESCRITA (nao funciona via MCP
-- read-only).
--
-- ESTE ARQUIVO TERMINA SEMPRE EM ROLLBACK. Nenhuma alteracao real e
-- persistida ao rodar este arquivo -- e apenas o harness de validacao.
-- ============================================================================

`;

const footer = `
-- Nada commitado: staging, snapshots e o UPDATE em si -- tudo desfeito abaixo.
ROLLBACK;
`;

const fullSql = header + body + footer;

fs.writeFileSync(OUT_PATH, fullSql, 'utf8');
console.log(`Harness gerado: ${OUT_PATH}`);
console.log(`21 explicacoes embutidas, ids: ${idsLiteralList}`);
console.log(`Tamanho do arquivo: ${fullSql.length} caracteres`);
