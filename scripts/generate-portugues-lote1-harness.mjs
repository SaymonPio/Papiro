#!/usr/bin/env node
// Gera supabase/aplicar_portugues_lote1_teste_rollback.sql
// a partir de scripts/portugues-lote1-explicacoes.mjs.

import fs from 'fs';
import { explicacoes } from './portugues-lote1-explicacoes.mjs';

const IDS_ESPERADOS = [
  6, 16, 17, 18, 34, 65, 66, 67, 68, 69, 70, 71, 72, 73, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123,
  216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241
];
const OUT_PATH = 'supabase/aplicar_portugues_lote1_teste_rollback.sql';
const ADMIN_USUARIO_ID = 'e5523807-6cc8-4867-8a56-77c17552e56e';

if (explicacoes.length !== 50) throw new Error(`esperado 50 explicacoes, encontrado ${explicacoes.length}`);
const idsArquivo = explicacoes.map(e => e.id).sort((a, b) => a - b);
const idsEsperadosOrdenados = [...IDS_ESPERADOS].sort((a, b) => a - b);
if (JSON.stringify(idsArquivo) !== JSON.stringify(idsEsperadosOrdenados)) {
  throw new Error(`ids do arquivo nao batem com os esperados.`);
}

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
-- Staging: id -> nova explicacao (fonte: scripts/portugues-lote1-explicacoes.mjs).
-- ----------------------------------------------------------------------------
create temporary table _lp1_novas_explicacoes (id bigint primary key, explicacao text) on commit drop;
insert into _lp1_novas_explicacoes (id, explicacao) values
${valuesRows};

-- ----------------------------------------------------------------------------
-- Snapshot ANTES.
-- ----------------------------------------------------------------------------
-- 1) linha inteira das 50 (exceto explicacao/atualizado_em).
create temporary table _lp1_snap_questoes on commit drop as
select id, (to_jsonb(q) - 'explicacao' - 'atualizado_em') as dados_imutaveis
from public.questoes q
where q.id in (${idsLiteralList});

-- 2) alternativas completas das 50.
create temporary table _lp1_snap_alternativas on commit drop as
select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
from public.alternativas a
where a.questao_id in (${idsLiteralList})
group by questao_id;

-- 3) hash de explicacao de TODAS as questoes do banco.
create temporary table _lp1_snap_hash_todas on commit drop as
select id, md5(coalesce(explicacao, '')) as hash_explicacao
from public.questoes;

-- 4) contagens globais.
create temporary table _lp1_snap_global on commit drop as
select
  (select count(*) from public.questoes)            as total_questoes_antes,
  (select count(*) from public.questoes where ativa) as total_ativas_antes;

create temporary table _lp1_asserts (ordem serial primary key, descricao text, ok boolean) on commit drop;

-- ----------------------------------------------------------------------------
-- Precondicoes.
-- ----------------------------------------------------------------------------
do $$
declare
  v_qtd int;
begin
  if (select count(*) from _lp1_novas_explicacoes) <> 50 then
    raise exception 'PRECONDICAO FALHOU: staging nao tem exatamente 50 explicacoes';
  end if;

  select count(*) into v_qtd from public.questoes where id in (select id from _lp1_novas_explicacoes);
  if v_qtd <> 50 then
    raise exception 'PRECONDICAO FALHOU: esperado 50 questoes no banco, encontrado %', v_qtd;
  end if;

  if exists (
    select 1 from public.questoes q
    join _lp1_novas_explicacoes s on s.id = q.id
    where q.materia_id is distinct from 6 or q.ativa is distinct from true
  ) then
    raise exception 'PRECONDICAO FALHOU: alguma das 50 nao esta mais no estado auditado (materia_id=6, ativa=true)';
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ESCRITA: atualiza explicacao + atualizado_em das 50.
-- ----------------------------------------------------------------------------
create temporary table _lp1_ids_afetados (id bigint primary key) on commit drop;

do $$
declare
  v_linhas int;
begin
  with atualizado as (
    update public.questoes q
    set explicacao = s.explicacao, atualizado_em = now()
    from _lp1_novas_explicacoes s
    where q.id = s.id
    returning q.id
  )
  insert into _lp1_ids_afetados (id) select id from atualizado;

  get diagnostics v_linhas = row_count;
  if v_linhas <> 50 then
    raise exception 'ESCRITA FALHOU: esperado UPDATE de exatamente 50 linhas, afetou %', v_linhas;
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
  insert into _lp1_asserts (descricao, ok)
  select 'exatamente 50 questoes afetadas pelo UPDATE', (select count(*) from _lp1_ids_afetados) = 50;

  insert into _lp1_asserts (descricao, ok)
  select 'os ids afetados sao exatamente os 50 esperados',
    (select array_agg(id order by id) from _lp1_ids_afetados) = ${idsLiteralArray};

  insert into _lp1_asserts (descricao, ok)
  select 'enunciado/alternativas-relacao/gabarito/materia/assunto/ativa/banca/concurso/ano/fonte preservados nas 50 (comparacao jsonb byte-a-byte, exceto explicacao/atualizado_em)',
    not exists (
      select 1 from public.questoes q
      join _lp1_snap_questoes s on s.id = q.id
      where (to_jsonb(q) - 'explicacao' - 'atualizado_em') <> s.dados_imutaveis
    );

  insert into _lp1_asserts (descricao, ok)
  select 'alternativas das 50 continuam byte-identicas (texto/correta/ordem)',
    not exists (
      select 1
      from _lp1_snap_alternativas s
      join (
        select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
        from public.alternativas a
        where a.questao_id in (select id from _lp1_novas_explicacoes)
        group by questao_id
      ) d on d.questao_id = s.questao_id
      where d.alternativas <> s.alternativas
    );

  select count(*) into v_sem_correta
  from _lp1_novas_explicacoes s
  where (select count(*) from public.alternativas a where a.questao_id = s.id and a.correta) <> 1;
  insert into _lp1_asserts (descricao, ok) values ('as 50 continuam com exatamente 1 alternativa correta cada', v_sem_correta = 0);

  -- Classificacao EXPLICACAO_COMPLETA das 50 apos o UPDATE
  with alt_stats as (
    select q.id as questao_id, count(a.id) as n_alt, count(a.id) filter (where a.correta) as n_corretas,
      bool_and(lower(btrim(a.texto)) in ('certo', 'errado')) and count(a.id) = 2 as eh_certo_errado
    from public.questoes q
    left join public.alternativas a on a.questao_id = q.id
    where q.id in (select id from _lp1_novas_explicacoes)
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
    where q.id in (select id from _lp1_novas_explicacoes)
  )
  select count(*) filter (where status = 'EXPLICACAO_COMPLETA') into v_completas from classificado;
  insert into _lp1_asserts (descricao, ok) values ('as 50 passam no classificador canonico como EXPLICACAO_COMPLETA', v_completas = 50);

  insert into _lp1_asserts (descricao, ok)
  select 'nenhuma outra questao do banco teve explicacao alterada',
    not exists (
      select 1 from public.questoes q
      join _lp1_snap_hash_todas s on s.id = q.id
      where md5(coalesce(q.explicacao, '')) <> s.hash_explicacao
        and q.id <> ALL(${idsLiteralArray})
    );

  select count(*) into v_total_depois from public.questoes;
  insert into _lp1_asserts (descricao, ok) values ('total de questoes no banco inalterado (nenhuma criada/excluida)', v_total_depois = (select total_questoes_antes from _lp1_snap_global));

  select count(*) into v_ativas_depois from public.questoes where ativa = true;
  insert into _lp1_asserts (descricao, ok) values ('total de questoes ATIVAS do Papiro inalterado', v_ativas_depois = (select total_ativas_antes from _lp1_snap_global));
end $$;

-- Relatorio de asserts
do $$
declare
  r record;
  v_total integer;
  v_ok integer;
begin
  for r in select descricao, ok from _lp1_asserts order by ordem loop
    if r.ok then
      raise notice 'OK: %', r.descricao;
    else
      raise exception 'FALHOU: %', r.descricao;
    end if;
  end loop;

  select count(*), count(*) filter (where ok) into v_total, v_ok from _lp1_asserts;
  raise notice '=== RESUMO: % / % asserts passaram ===', v_ok, v_total;
  if v_ok <> v_total then
    raise exception 'Harness falhou: nem todos os asserts passaram.';
  end if;
end $$;
`;

const header = `-- ============================================================================
-- AUDITORIA GLOBAL -- LÍNGUA PORTUGUESA -- LOTE 1 (50 QUESTÕES)
-- Aplicação de 50 explicações pedagógicas (materia_id 6)
-- IDs: ${idsLiteralList}
-- HARNESS TRANSACIONAL -- TERMINA SEMPRE EM ROLLBACK, NADA PERSISTE.
-- ============================================================================
--
-- Gerado automaticamente por scripts/generate-portugues-lote1-harness.mjs a partir de
-- scripts/portugues-lote1-explicacoes.mjs.
-- ============================================================================

`;

const footer = `
-- Nada commitado: tudo desfeito abaixo.
ROLLBACK;
`;

const fullSql = header + body + footer;
fs.writeFileSync(OUT_PATH, fullSql, 'utf8');
console.log(`Harness gerado: ${OUT_PATH}`);
