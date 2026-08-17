#!/usr/bin/env node
// Gera o harness transacional (BEGIN...ROLLBACK) de importacao do Lote 1 da
// Lei Maria da Penha a partir de supabase/lote_1_reclassificacao_supabase_86.csv.
// So le o CSV validado da rodada anterior (importar_agora = sim, 85 linhas,
// cadernos 950 e 999 ja excluidos na propria coluna) e escreve um .sql — nao
// toca o Supabase. Reaproveita o parser de CSV de
// scripts/dedupe-lote1-vs-supabase.js.
//
// Uso: node scripts/generate-lote1-import-harness.mjs

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const CSV_PATH = path.join(ROOT, 'supabase/lote_1_reclassificacao_supabase_86.csv');
const HARNESS_OUT_PATH = path.join(ROOT, 'supabase/importar_lote1_lei_maria_penha_teste_rollback.sql');
const APPLY_OUT_PATH = path.join(ROOT, 'supabase/importar_lote1_lei_maria_penha.sql');

const MATERIA_ID = 10;
const ASSUNTO_ID = 19;
const CONTEUDO_ID = 53;
const CURSO_ID = '7543be16-4c5b-4cb6-8724-8fbdfb96f2d4';
const ADMIN_USUARIO_ID = 'e5523807-6cc8-4867-8a56-77c17552e56e';

const UNIT_MAP = {
  U1: 'e260b54c-6a75-4398-97f6-7a432c405041',
  U2: 'ab29ba89-1dcc-46c2-9659-f5808be3d976',
  U3: '4d593bc4-6e4f-4c1f-8817-e41c78fe9491',
  U4: '7164d7f2-86f7-413e-b0fc-64070dd2e2f5',
  U5: '53dc06a1-cd16-4004-a76b-8201d95a91c4',
};

function parseCsv(str) {
  const rows = [];
  let row = [], field = '', inQuotes = false;
  for (let i = 0; i < str.length; i++) {
    const c = str[i];
    if (inQuotes) {
      if (c === '"') { if (str[i + 1] === '"') { field += '"'; i++; } else inQuotes = false; }
      else field += c;
    } else {
      if (c === '"') inQuotes = true;
      else if (c === ',') { row.push(field); field = ''; }
      else if (c === '\r' && str[i + 1] === '\n') { row.push(field); rows.push(row); row = []; field = ''; i++; }
      else if (c === '\n') { row.push(field); rows.push(row); row = []; field = ''; }
      else field += c;
    }
  }
  if (field.length || row.length) { row.push(field); rows.push(row); }
  return rows.filter(r => !(r.length === 1 && r[0] === ''));
}

function loadCsv(filePath) {
  const rows = parseCsv(fs.readFileSync(filePath, 'utf8'));
  const header = rows[0];
  return rows.slice(1).map(r => Object.fromEntries(header.map((h, i) => [h, r[i]])));
}

function sqlStr(s) {
  return `'${String(s).replace(/'/g, "''")}'`;
}

function sqlIntOrNull(s) {
  const n = parseInt(s, 10);
  return Number.isFinite(n) ? String(n) : 'null';
}

const data = loadCsv(CSV_PATH);
const sim = data.filter(d => d.importar_agora === 'sim');

if (sim.length !== 85) {
  throw new Error(`Esperado 85 linhas importar_agora=sim, encontrado ${sim.length}`);
}
for (const bloqueado of ['950', '999']) {
  if (sim.some(d => d.caderno_numero === bloqueado)) {
    throw new Error(`Caderno ${bloqueado} nao pode estar em importar_agora=sim`);
  }
}
const cadernoNumeros = new Set(sim.map(d => d.caderno_numero));
if (cadernoNumeros.size !== sim.length) {
  throw new Error('caderno_numero duplicado dentro do conjunto importar_agora=sim');
}

const questoesRows = [];
const alternativasRows = [];
const vinculosRows = [];
let totalAlternativas = 0;
let totalVinculos = 0;
let bancoGeralCount = 0;
let multiunidadeCount = 0;

for (const d of sim) {
  const caderno = parseInt(d.caderno_numero, 10);
  const isCertoErrado = d.gabarito === 'Certo' || d.gabarito === 'Errado';

  let enunciado = d.enunciado.trim();
  let alts;
  if (isCertoErrado) {
    // A extracao original deixou "alternativas" vazio para o formato
    // dicotomico (CEBRASPE/VUNESP "julgue o item") e concatenou "Certo
    // Errado" ao final do proprio enunciado. Confirmado em todas as 12
    // ocorrencias antes de gerar este harness (mesmo sufixo em todas).
    enunciado = enunciado.replace(/\s*Certo\s+Errado\s*$/i, '').trim();
    alts = [
      { texto: 'Certo', correta: d.gabarito === 'Certo' },
      { texto: 'Errado', correta: d.gabarito === 'Errado' },
    ];
  } else {
    const rawAlts = d.alternativas.split(' | ').map(a => a.trim().replace(/^[a-eA-E]\)\s*/, ''));
    const idx = 'ABCDE'.indexOf(d.gabarito);
    if (idx < 0 || idx >= rawAlts.length) {
      throw new Error(`Caderno ${d.caderno_numero}: gabarito "${d.gabarito}" fora do range de alternativas`);
    }
    alts = rawAlts.map((texto, i) => ({ texto, correta: i === idx }));
  }
  if (alts.filter(a => a.correta).length !== 1) {
    throw new Error(`Caderno ${d.caderno_numero}: nao ha exatamente 1 alternativa correta`);
  }

  const fonte = `TEC Concursos — questão ${d.tec_id} — ${d.banca} — ${d.concurso}`;

  questoesRows.push(
    `  (${caderno}, ${sqlIntOrNull(d.tec_id)}, ${sqlStr(d.banca)}, ${sqlStr(d.concurso)}, ` +
    `${sqlIntOrNull(d.ano)}, ${sqlStr(enunciado)}, ${sqlStr(fonte)})`
  );

  alts.forEach((a, i) => {
    alternativasRows.push(`  (${caderno}, ${i + 1}, ${sqlStr(a.texto)}, ${a.correta})`);
    totalAlternativas++;
  });

  const unidades = (d.unidades || '').split('+').map(u => u.trim()).filter(Boolean);
  if (unidades.length === 0) {
    bancoGeralCount++;
  } else {
    if (unidades.length > 1) multiunidadeCount++;
    for (const u of unidades) {
      const uuid = UNIT_MAP[u];
      if (!uuid) throw new Error(`Caderno ${d.caderno_numero}: unidade desconhecida "${u}"`);
      vinculosRows.push(`  (${caderno}, ${sqlStr(uuid)}::uuid)`);
      totalVinculos++;
    }
  }
}

if (bancoGeralCount !== 9) throw new Error(`Esperado 9 banco geral, encontrado ${bancoGeralCount}`);
if (multiunidadeCount !== 8) throw new Error(`Esperado 8 multiunidade, encontrado ${multiunidadeCount}`);

const dadosComentario = `-- Gerado automaticamente por scripts/generate-lote1-import-harness.mjs a
-- partir de supabase/lote_1_reclassificacao_supabase_86.csv
-- (importar_agora = 'sim', 85 linhas). NAO editar este arquivo a mao — editar
-- o CSV/gerador e regerar, para manter os dois em sincronia. Fonte da
-- verdade da classificacao/auditoria: supabase/lote_1_reclassificacao_supabase_86.md.
--
-- Caderno 950 (colisao de tec_id, PROBLEMATICA) e caderno 999 (sem metadados
-- confirmaveis) permanecem FORA — nao aparecem em nenhuma linha abaixo,
-- confirmado por assert antes de qualquer escrita.
--
-- Achados de qualidade de dados tratados nesta geracao (ver .md do Lote 1
-- para o restante da auditoria):
--   - 12 questoes formato CEBRASPE/VUNESP "julgue o item" (gabarito Certo/
--     Errado) vieram com a coluna "alternativas" vazia — a extracao original
--     colou "Certo Errado" ao final do proprio enunciado. Corrigido aqui:
--     sufixo removido do enunciado, alternativas geradas como texto="Certo"/
--     "Errado" (o par literal do proprio formato, correta = gabarito).
--   - As 73 restantes vinham com prefixo de letra ("a) ", "b) "...) dentro do
--     texto de cada alternativa — removido para bater com o formato ja usado
--     pelas questoes reais existentes (nenhuma tem prefixo de letra
--     armazenado; a letra e responsabilidade da UI, nao do dado).
--   - Confirmado por consulta direta ao Supabase (MCP, so leitura) antes de
--     gerar este arquivo: nenhum dos 85 tec_id ja aparece em questoes.fonte
--     em NENHUMA materia/curso — sem risco de duplicata cega.
--
-- Composicao: ${sim.length} questoes novas, ${totalAlternativas} alternativas,
-- ${bancoGeralCount} sem vinculo de unidade (banco geral, elegiveis so a
-- Missao Final apos o patch de selecionar_candidatas_conteudo — commit
-- 027a3f6), ${sim.length - bancoGeralCount} com vinculo (${multiunidadeCount}
-- delas multiunidade), ${totalVinculos} linhas de vinculo ao todo.
--
-- Usa a MESMA RPC administrativa do app para os vinculos
-- (public.classificar_questao_unidade_admin), no MESMO padrao de
-- supabase/classificar_questoes_unidades_lei_maria_penha_teste_rollback.sql:
-- como esta sessao roda como "postgres" via MCP/SQL Editor (sem sessao real
-- de auth), simula a claim JWT do unico administrador cadastrado com "set
-- local" — efeito restrito a esta transacao, nunca contorna eh_admin().
--
-- Precisa rodar com um role de ESCRITA (nao funciona via MCP read-only).`;

const body = `BEGIN;

set local request.jwt.claim.sub = '${ADMIN_USUARIO_ID}';

-- ----------------------------------------------------------------------------
-- Snapshot ANTES — prova de ausencia de efeito colateral fora do esperado.
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- Staging: 85 questoes (chave local = caderno_numero, nunca usado como id
-- real — o id real vem do IDENTITY de public.questoes no INSERT abaixo).
-- ----------------------------------------------------------------------------
create temporary table _lote1_questoes (
  caderno_numero int primary key,
  tec_id bigint,
  banca text,
  concurso text,
  ano int,
  enunciado text,
  fonte text
) on commit drop;

insert into _lote1_questoes (caderno_numero, tec_id, banca, concurso, ano, enunciado, fonte) values
${questoesRows.join(',\n')};

create temporary table _lote1_alternativas (
  caderno_numero int,
  ordem smallint,
  texto text,
  correta boolean
) on commit drop;

insert into _lote1_alternativas (caderno_numero, ordem, texto, correta) values
${alternativasRows.join(',\n')};

create temporary table _lote1_vinculos (
  caderno_numero int,
  unidade_pedagogica_id uuid
) on commit drop;

insert into _lote1_vinculos (caderno_numero, unidade_pedagogica_id) values
${vinculosRows.join(',\n')};

-- ----------------------------------------------------------------------------
-- Revalidacao de premissas dentro da propria transacao antes de qualquer
-- escrita real (RAISE EXCEPTION aborta tudo automaticamente).
-- ----------------------------------------------------------------------------
do $$
declare
  v_materia_id bigint;
  v_assunto_id bigint;
begin
  if (select count(*) from _lote1_questoes) <> 85 then
    raise exception 'Precondicao falhou: staging nao tem exatamente 85 questoes';
  end if;
  if exists (select 1 from _lote1_questoes where caderno_numero in (950, 999)) then
    raise exception 'Precondicao falhou: caderno 950 ou 999 presente no staging';
  end if;

  select cm.materia_id, cc.assunto_id into v_materia_id, v_assunto_id
  from public.curso_conteudos cc
  join public.curso_materias cm on cm.id = cc.curso_materia_id
  where cc.id = ${CONTEUDO_ID};

  if v_materia_id is distinct from ${MATERIA_ID} or v_assunto_id is distinct from ${ASSUNTO_ID} then
    raise exception 'Precondicao falhou: conteudo ${CONTEUDO_ID} materia_id=% assunto_id=% (esperado ${MATERIA_ID}/${ASSUNTO_ID})', v_materia_id, v_assunto_id;
  end if;

  if (select count(*) from public.unidades_pedagogicas where curso_conteudo_id = ${CONTEUDO_ID} and ativa = true) <> 5 then
    raise exception 'Precondicao falhou: nao ha exatamente 5 unidades pedagogicas ativas para o conteudo ${CONTEUDO_ID}';
  end if;

  if exists (
    select 1 from public.questoes q
    join _lote1_questoes l on q.fonte like '%' || l.tec_id::text || '%'
  ) then
    raise exception 'Precondicao falhou: algum tec_id do Lote 1 ja existe em questoes.fonte (possivel duplicata)';
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ESCRITA 1 — questoes (loop explicito para mapear caderno_numero -> id real
-- de forma inequivoca, sem depender de ordem implicita de RETURNING).
-- ----------------------------------------------------------------------------
create temporary table _lote1_ids (caderno_numero int primary key, questao_id bigint) on commit drop;

do $$
declare
  r record;
  v_id bigint;
begin
  for r in select * from _lote1_questoes order by caderno_numero loop
    insert into public.questoes (materia_id, assunto_id, banca, concurso, enunciado, fonte, ano, ativa)
    values (${MATERIA_ID}, ${ASSUNTO_ID}, r.banca, r.concurso, r.enunciado, r.fonte, r.ano, true)
    returning id into v_id;

    insert into _lote1_ids (caderno_numero, questao_id) values (r.caderno_numero, v_id);
  end loop;
end $$;

-- ----------------------------------------------------------------------------
-- ESCRITA 2 — alternativas.
-- ----------------------------------------------------------------------------
insert into public.alternativas (questao_id, texto, correta, ordem)
select m.questao_id, a.texto, a.correta, a.ordem
from _lote1_alternativas a
join _lote1_ids m using (caderno_numero);

-- ----------------------------------------------------------------------------
-- ESCRITA 3 — curso_questoes (todas as 85 no mesmo curso do conteudo 53,
-- mesmo curso ja usado pelas 27 questoes reais existentes deste assunto).
-- ----------------------------------------------------------------------------
insert into public.curso_questoes (curso_id, questao_id)
select '${CURSO_ID}'::uuid, questao_id
from _lote1_ids;

-- ----------------------------------------------------------------------------
-- ESCRITA 4 — vinculos de unidade pedagogica, via RPC oficial (mesma usada
-- pelo app), nunca INSERT direto em questao_unidades_pedagogicas.
-- ----------------------------------------------------------------------------
do $$
declare
  r record;
begin
  for r in
    select m.questao_id, v.unidade_pedagogica_id
    from _lote1_vinculos v
    join _lote1_ids m using (caderno_numero)
  loop
    perform public.classificar_questao_unidade_admin(r.questao_id, r.unidade_pedagogica_id);
  end loop;
end $$;`;

const assertsAndRollback = `
-- ----------------------------------------------------------------------------
-- ASSERTS
-- ----------------------------------------------------------------------------
create table teste_lote1_asserts (ordem serial primary key, descricao text, ok boolean);

create procedure teste_lote1_assert(p_descricao text, p_ok boolean)
language plpgsql
as $assert$
begin
  insert into teste_lote1_asserts (descricao, ok) values (p_descricao, p_ok);
  if p_ok then
    raise notice 'OK: %', p_descricao;
  else
    raise exception 'FALHOU: %', p_descricao;
  end if;
end;
$assert$;

do $$
declare
  v_antes record;
  v_depois record;
  v_sem_correta int;
  v_multi_correta int;
  v_banco_geral_com_vinculo int;
  v_faltando_vinculo int;
  v_multiunidade_com_2 int;
  v_missao_final bigint[];
  v_ids_banco_geral bigint[];
  v_ids_unidade bigint[];
  v_banco_geral_na_missao int;
  v_unidade_na_missao int;
  v_banco_geral_vazando_u1 int;
begin
  select * into v_antes from _snapshot_antes;
  select
    (select count(*) from public.questoes)                     as total_questoes,
    (select count(*) from public.alternativas)                 as total_alternativas,
    (select count(*) from public.unidades_pedagogicas)          as total_unidades,
    (select count(*) from public.curso_conteudos)               as total_conteudos,
    (select count(*) from public.curso_questoes)                as total_curso_questoes,
    (select count(*) from public.respostas_usuarios)            as total_respostas,
    (select count(*) from public.sessoes_estudo)                as total_sessoes,
    (select count(*) from public.questao_unidades_pedagogicas)  as total_vinculos
  into v_depois;

  call teste_lote1_assert('questoes +85', v_depois.total_questoes = v_antes.total_questoes + 85);
  call teste_lote1_assert('alternativas +${totalAlternativas}', v_depois.total_alternativas = v_antes.total_alternativas + ${totalAlternativas});
  call teste_lote1_assert('curso_questoes +85', v_depois.total_curso_questoes = v_antes.total_curso_questoes + 85);
  call teste_lote1_assert('questao_unidades_pedagogicas +${totalVinculos}', v_depois.total_vinculos = v_antes.total_vinculos + ${totalVinculos});
  call teste_lote1_assert('unidades_pedagogicas inalterada (nenhuma unidade criada/removida)', v_depois.total_unidades = v_antes.total_unidades);
  call teste_lote1_assert('curso_conteudos inalterada', v_depois.total_conteudos = v_antes.total_conteudos);
  call teste_lote1_assert('respostas_usuarios inalterada', v_depois.total_respostas = v_antes.total_respostas);
  call teste_lote1_assert('sessoes_estudo inalterada', v_depois.total_sessoes = v_antes.total_sessoes);

  select count(*) into v_sem_correta
  from _lote1_ids m
  where (select count(*) from public.alternativas a where a.questao_id = m.questao_id and a.correta) <> 1;
  call teste_lote1_assert('todas as 85 questoes tem exatamente 1 alternativa correta', v_sem_correta = 0);

  select count(*) into v_banco_geral_com_vinculo
  from _lote1_ids m
  where m.caderno_numero not in (select caderno_numero from _lote1_vinculos)
    and exists (select 1 from public.questao_unidades_pedagogicas qup where qup.questao_id = m.questao_id);
  call teste_lote1_assert('as 9 banco geral nao ganharam nenhum vinculo de unidade', v_banco_geral_com_vinculo = 0);

  select count(*) into v_faltando_vinculo
  from (select distinct caderno_numero from _lote1_vinculos) c
  join _lote1_ids m using (caderno_numero)
  where not exists (select 1 from public.questao_unidades_pedagogicas qup where qup.questao_id = m.questao_id);
  call teste_lote1_assert('as 76 questoes com unidade no CSV tem pelo menos 1 vinculo real', v_faltando_vinculo = 0);

  select count(*) into v_multiunidade_com_2
  from (
    select caderno_numero, count(*) as n from _lote1_vinculos group by caderno_numero having count(*) > 1
  ) multi
  join _lote1_ids m using (caderno_numero)
  where (select count(*) from public.questao_unidades_pedagogicas qup where qup.questao_id = m.questao_id) <> multi.n;
  call teste_lote1_assert('as 8 questoes multiunidade tem exatamente 2 vinculos cada', v_multiunidade_com_2 = 0);

  -- Ponta a ponta: confirma que o patch de selecionar_candidatas_conteudo
  -- (commit 027a3f6) + esta importacao juntos tornam as 9 banco geral
  -- elegiveis na Missao Final, sem tocar a pratica de unidade.
  select array_agg(m.questao_id) into v_ids_banco_geral
  from _lote1_ids m
  where m.caderno_numero not in (select caderno_numero from _lote1_vinculos);

  select array_agg(x.questao_id) into v_missao_final
  from public.selecionar_candidatas_conteudo(
    '${ADMIN_USUARIO_ID}'::uuid, ${CONTEUDO_ID}::bigint, '${CURSO_ID}'::uuid, 500, '{}'::bigint[], null
  ) x(questao_id);

  select count(*) into v_banco_geral_na_missao
  from unnest(v_ids_banco_geral) qid where qid = any(v_missao_final);

  call teste_lote1_assert(
    'todas as 9 banco geral novas aparecem na Missao Final (conteudo ${CONTEUDO_ID})',
    v_banco_geral_na_missao = 9
  );

  select array_agg(m.questao_id) into v_ids_unidade
  from _lote1_ids m
  where m.caderno_numero in (select caderno_numero from _lote1_vinculos);

  select count(*) into v_unidade_na_missao
  from unnest(v_ids_unidade) qid where qid = any(v_missao_final);

  call teste_lote1_assert(
    'todas as 76 questoes vinculadas tambem aparecem na Missao Final (conteudo ${CONTEUDO_ID})',
    v_unidade_na_missao = 76
  );

  select count(*) into v_banco_geral_vazando_u1
  from unnest(v_ids_banco_geral) qid
  where qid = any(array(
    select x.questao_id from public.selecionar_candidatas_unidade_pedagogica(
      '${ADMIN_USUARIO_ID}'::uuid, '${UNIT_MAP.U1}'::uuid, '${CURSO_ID}'::uuid, 500, '{}'::bigint[], null
    ) x(questao_id)
  ));

  call teste_lote1_assert(
    'nenhuma das 9 banco geral aparece na pratica da unidade U1',
    v_banco_geral_vazando_u1 = 0
  );
end $$;

do $$
declare
  v_total integer;
  v_ok integer;
begin
  select count(*), count(*) filter (where ok) into v_total, v_ok from teste_lote1_asserts;
  raise notice '=== RESUMO: % / % asserts passaram ===', v_ok, v_total;
  if v_ok <> v_total then
    raise exception 'Harness falhou: nem todos os asserts passaram (ver RESUMO acima).';
  end if;
end $$;

-- Nada commitado: staging, questoes, alternativas, curso_questoes, vinculos e
-- as tabelas de assert — tudo desfeito abaixo.
ROLLBACK;
`;

const harnessSql = `-- ============================================================================
-- LOTE 1 — IMPORTACAO DAS 85 QUESTOES VALIDAS DA LEI MARIA DA PENHA
-- HARNESS TRANSACIONAL — TERMINA SEMPRE EM ROLLBACK, NADA PERSISTE.
-- ============================================================================
--
${dadosComentario}
-- ============================================================================

${body}
${assertsAndRollback}`;

const applySql = `-- ============================================================================
-- LOTE 1 — IMPORTACAO DAS 85 QUESTOES VALIDAS DA LEI MARIA DA PENHA
-- APLICACAO REAL — TERMINA EM COMMIT. So rodar depois que
-- supabase/importar_lote1_lei_maria_penha_teste_rollback.sql tiver rodado no
-- SQL Editor com TODOS os asserts passando (RESUMO N/N).
-- ============================================================================
--
${dadosComentario}
--
-- Sem tabelas de assert/RAISE NOTICE de diagnostico (isso ja foi validado
-- pelo harness em separado) — mas as revalidacoes de precondicao dentro da
-- transacao permanecem: se o estado do banco mudou entre a validacao do
-- harness e esta aplicacao (ex.: alguem desativou uma unidade, ou um dos
-- tec_id foi importado por outro caminho nesse meio-tempo), a transacao
-- aborta sozinha em vez de escrever dado inconsistente.
-- ============================================================================

${body}

-- Confirma as escritas: 85 questoes, ${totalAlternativas} alternativas,
-- 85 vinculos de curso_questoes, ${totalVinculos} vinculos de unidade
-- pedagogica (RPC classificar_questao_unidade_admin).
COMMIT;
`;

fs.writeFileSync(HARNESS_OUT_PATH, harnessSql, 'utf8');
fs.writeFileSync(APPLY_OUT_PATH, applySql, 'utf8');
console.log(`Gerado: ${path.relative(ROOT, HARNESS_OUT_PATH)}`);
console.log(`Gerado: ${path.relative(ROOT, APPLY_OUT_PATH)}`);
console.log(`Questoes: ${sim.length} | Alternativas: ${totalAlternativas} | Banco geral: ${bancoGeralCount} | Vinculos: ${totalVinculos} (multiunidade: ${multiunidadeCount})`);
