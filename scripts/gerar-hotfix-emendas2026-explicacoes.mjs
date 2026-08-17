#!/usr/bin/env node
// Hotfix de precisao juridica para 10 questoes ja em producao (sub-lote 1 e
// sub-lote 2 da Lei Maria da Penha), cujas explicacoes citavam pontos da
// Lei 11.340/2006 que foram alterados por emendas de 2024-2026 posteriores
// ao corte de conhecimento do Claude (janeiro/2026):
//
//   - "5 modalidades" de violencia (art. 7º) -> agora sao 6, com a
//     violencia vicaria (art. 7º, VI, incluido pela Lei 15.384/2026).
//     ids: 1300, 1313, 1325 (sub-lote 1); 1331, 1332, 1339, 1354 (sub-lote 2).
//   - criterio de risco do art. 12-C (afastamento do agressor) -> ampliado
//     de "vida ou integridade fisica ou psicologica" para tambem incluir
//     sexual, moral e patrimonial (Lei 15.411/2026). ids: 1349, 1367
//     (sub-lote 2).
//   - pena do art. 24-A (descumprimento de medida protetiva) -> de
//     detencao de 3 meses a 2 anos para reclusao de 2 a 5 anos e multa
//     (Lei 14.994/2024). id: 1311 (sub-lote 1).
//
// Todas as 10 correcoes foram verificadas contra o texto oficial
// consolidado da Lei 11.340/2006 (fonte: Centro de Documentacao e
// Informacao da Camara dos Deputados, "norma atualizada"). Em nenhum caso
// o gabarito da questao original mudou -- so o texto de apoio da
// explicacao (por que a alternativa correta/incorreta) foi ajustado para
// nao ensinar como atual um estado de direito ja superado.
//
// So altera public.questoes.explicacao, e SOMENTE nestas 10 linhas. Gera
// harness (ROLLBACK) e aplicacao real (COMMIT) do MESMO corpo, igual ao
// padrao do hotfix da questao 1324.

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { explicacoes as sublote1 } from './sublote1-lei-maria-penha-explicacoes.mjs';
import { explicacoes as sublote2 } from './sublote2-lei-maria-penha-explicacoes.mjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const HARNESS_OUT_PATH = path.join(ROOT, 'supabase/corrigir_explicacoes_emendas2026_teste_rollback.sql');
const APPLY_OUT_PATH = path.join(ROOT, 'supabase/corrigir_explicacoes_emendas2026.sql');

function sqlStr(s) {
  return `'${String(s).replace(/'/g, "''")}'`;
}

// Hash (md5, CRLF normalizado para LF) do texto que estava em producao
// ANTES desta correcao, capturado ao vivo via MCP read-only imediatamente
// antes de gerar este hotfix -- usado como precondicao por linha: se o
// estado mudou desde entao, aquela linha especifica aborta a transacao
// inteira em vez de sobrescrever um estado inesperado.
const HASH_ANTES = {
  1300: '37d45bb65a862d61c25f0d01c64527d1',
  1311: '40fab55ae405f04e5b909e65214acebd',
  1313: '915a5ab3c7f2e309536a43b10984eb27',
  1325: 'e4a4f49adaae8f11cc6239f8294c3f04',
  1331: 'bd9242c988594beb65d076493b8a5d2b',
  1332: '43ae8a808dc07ac12e80d019eb5381c8',
  1339: '22854d30551d72c18028d24c601224fa',
  1349: '1e06a92f66a2359bd02ff3f0ccf12edd',
  1354: 'a017ec6c355ab9670b983205308f6a1b',
  1367: '58f8c3375c45c30f94339f8c2f669199',
};

const IDS = Object.keys(HASH_ANTES).map(Number).sort((a, b) => a - b);
if (IDS.length !== 10) throw new Error(`Esperado 10 ids, encontrado ${IDS.length}`);

const todasExplicacoes = new Map([...sublote1, ...sublote2].map(e => [e.id, e.explicacao]));
for (const id of IDS) {
  if (!todasExplicacoes.has(id)) throw new Error(`id ${id} nao encontrado em sublote1/sublote2 -- fonte da verdade incompleta`);
}

const stagingRows = IDS
  .map(id => `  (${id}, ${sqlStr(todasExplicacoes.get(id))}, ${sqlStr(HASH_ANTES[id])})`)
  .join(',\n');

const idsListaSql = IDS.join(', ');

function body(mode) {
  return `-- ============================================================================
-- HOTFIX — 10 explicações da Lei Maria da Penha desatualizadas por emendas
-- de 2024-2026 (sub-lote 1 e sub-lote 2, JÁ EM PRODUÇÃO)
-- ${mode === 'rollback' ? 'HARNESS TRANSACIONAL — TERMINA SEMPRE EM ROLLBACK, NADA PERSISTE.' : 'APLICAÇÃO REAL — TERMINA EM COMMIT.'}
-- ============================================================================
--
-- Motivo: revisão contra o texto oficial consolidado da Lei 11.340/2006
-- (Câmara dos Deputados, "norma atualizada") encontrou 3 pontos citados nas
-- explicações que ficaram desatualizados:
--
--   1) "5 modalidades" de violência (art. 7º) — a Lei 15.384/2026 acrescentou
--      o inciso VI (violência vicária), hoje são 6. ids 1300, 1313, 1325,
--      1331, 1332, 1339, 1354. Em nenhum desses casos o gabarito da questão
--      dependia do número de modalidades — é só texto de apoio da
--      explicação, corrigido sem tocar no gabarito.
--
--   2) Critério de risco do art. 12-C (afastamento emergencial do agressor)
--      — a Lei 15.411/2026 ampliou de "vida ou integridade física ou
--      psicológica" para também incluir sexual, moral e patrimonial.
--      ids 1349, 1367. O gabarito de ambas as questões reproduz a redação
--      histórica (é o texto da própria alternativa do exame, que não pode
--      ser alterado) — a explicação agora deixa claro que a redação vigente
--      é mais ampla, sem contrariar a alternativa correta.
--
--   3) Pena do art. 24-A (descumprimento de medida protetiva) — a
--      Lei 14.994/2024 mudou de detenção de 3 meses a 2 anos para reclusão
--      de 2 a 5 anos e multa. id 1311. O gabarito não depende do valor exato
--      da pena (só de que descumprir configura crime) — texto de apoio
--      corrigido.
--
-- Questões: ${idsListaSql}
--
-- ÚNICA coluna alterada: public.questoes.explicacao, e SOMENTE nestas 10
-- linhas. Nenhuma outra questão é tocada — provado abaixo por GET
-- DIAGNOSTICS (exatamente 10 linhas afetadas pelo UPDATE) e por hash
-- antes/depois dos campos que não podem mudar (enunciado, alternativas —
-- inclui o gabarito —, fonte, banca, concurso, materia_id, assunto_id,
-- ativa, vínculos de unidade pedagógica e de curso_questoes).
--
-- Comparações de texto normalizam CRLF/LF antes de comparar (mesmo motivo
-- do hotfix da questão 1324: o valor em produção usa CRLF e o copy/paste no
-- SQL Editor pode alterar a convenção de quebra de linha do arquivo sem
-- alterar o conteúdo).
-- ============================================================================

BEGIN;

-- ----------------------------------------------------------------------------
-- Snapshot ANTES — hash por questão dos campos protegidos + contador
-- agregado.
-- ----------------------------------------------------------------------------
create temporary table _hotfix2026_antes on commit drop as
select
  q.id,
  md5(q.enunciado || '|' || coalesce(q.fonte,'') || '|' || coalesce(q.banca,'') || '|' || coalesce(q.concurso,'') || '|' || q.materia_id::text || '|' || coalesce(q.assunto_id::text,'') || '|' || q.ativa::text) as hash_questao,
  (
    select md5(string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '|' order by a.ordem))
    from public.alternativas a where a.questao_id = q.id
  ) as hash_alternativas,
  (
    select md5(coalesce(string_agg(qup.unidade_pedagogica_id::text, ',' order by qup.unidade_pedagogica_id), ''))
    from public.questao_unidades_pedagogicas qup where qup.questao_id = q.id
  ) as hash_vinculos_unidade,
  (
    select md5(coalesce(string_agg(cq.curso_id::text, ',' order by cq.curso_id), ''))
    from public.curso_questoes cq where cq.questao_id = q.id
  ) as hash_vinculos_curso
from public.questoes q
where q.id in (${idsListaSql});

create temporary table _hotfix2026_agregado_antes on commit drop as
select (select count(*) from public.questoes) as total_questoes;

-- ----------------------------------------------------------------------------
-- Staging: as 10 explicações corrigidas + hash esperado do texto atual
-- (precondição de que nada mudou desde a auditoria).
-- ----------------------------------------------------------------------------
create temporary table _staging_hotfix2026 (
  questao_id bigint primary key,
  explicacao_nova text,
  hash_esperado_antes text
) on commit drop;

insert into _staging_hotfix2026 (questao_id, explicacao_nova, hash_esperado_antes) values
${stagingRows};

-- ----------------------------------------------------------------------------
-- PRECONDIÇÕES — abortam tudo (RAISE EXCEPTION) antes de qualquer escrita.
-- ----------------------------------------------------------------------------
do $$
declare
  v_total int;
  v_divergentes int;
begin
  select count(*) into v_total from _staging_hotfix2026;
  if v_total <> 10 then
    raise exception 'Precondicao falhou: staging nao tem exatamente 10 questoes (tem %)', v_total;
  end if;

  select count(*) into v_divergentes
  from public.questoes q
  join _staging_hotfix2026 s on s.questao_id = q.id
  where md5(regexp_replace(q.explicacao, E'\\r\\n', E'\\n', 'g')) <> s.hash_esperado_antes;
  if v_divergentes > 0 then
    raise exception 'Precondicao falhou: % questao(oes) tem explicacao atual diferente do esperado -- pode ter mudado desde a auditoria. Hotfix abortado por seguranca.', v_divergentes;
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ESCRITA — altera SOMENTE explicacao, SOMENTE nas 10 linhas do staging.
-- ----------------------------------------------------------------------------
do $$
declare
  v_linhas_afetadas int;
begin
  update public.questoes q
  set explicacao = s.explicacao_nova
  from _staging_hotfix2026 s
  where q.id = s.questao_id;

  get diagnostics v_linhas_afetadas = row_count;
  if v_linhas_afetadas <> 10 then
    raise exception 'UPDATE afetou % linha(s), esperado exatamente 10 -- abortando', v_linhas_afetadas;
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ASSERTS
-- ----------------------------------------------------------------------------
create table hotfix_2026_asserts (ordem serial primary key, descricao text, ok boolean);

create procedure hotfix_2026_assert(p_descricao text, p_ok boolean)
language plpgsql
as $assert$
begin
  insert into hotfix_2026_asserts (descricao, ok) values (p_descricao, p_ok);
  if p_ok then
    raise notice 'OK: %', p_descricao;
  else
    raise exception 'FALHOU: %', p_descricao;
  end if;
end;
$assert$;

do $$
declare
  v_agregado_antes record;
  v_total_questoes int;
  v_diferentes_enunciado_ou_metadado int;
  v_diferentes_alternativas int;
  v_diferentes_vinculo_unidade int;
  v_diferentes_vinculo_curso int;
  v_nao_atualizadas int;
  v_vazia int;
begin
  select * into v_agregado_antes from _hotfix2026_agregado_antes;

  select count(*) into v_total_questoes from public.questoes;
  call hotfix_2026_assert('nenhuma questao criada/removida (total_questoes inalterado)', v_total_questoes = v_agregado_antes.total_questoes);

  select count(*) into v_diferentes_enunciado_ou_metadado
  from _hotfix2026_antes ant
  join public.questoes q on q.id = ant.id
  where md5(q.enunciado || '|' || coalesce(q.fonte,'') || '|' || coalesce(q.banca,'') || '|' || coalesce(q.concurso,'') || '|' || q.materia_id::text || '|' || coalesce(q.assunto_id::text,'') || '|' || q.ativa::text) <> ant.hash_questao;
  call hotfix_2026_assert('enunciado/fonte/banca/concurso/materia_id/assunto_id/ativa idênticos nas 10 (hash bate)', v_diferentes_enunciado_ou_metadado = 0);

  select count(*) into v_diferentes_alternativas
  from _hotfix2026_antes ant
  where (
    select md5(string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '|' order by a.ordem))
    from public.alternativas a where a.questao_id = ant.id
  ) <> ant.hash_alternativas;
  call hotfix_2026_assert('alternativas (texto/correta/ordem, ou seja, o gabarito) idênticas nas 10 (hash bate)', v_diferentes_alternativas = 0);

  select count(*) into v_diferentes_vinculo_unidade
  from _hotfix2026_antes ant
  where (
    select md5(coalesce(string_agg(qup.unidade_pedagogica_id::text, ',' order by qup.unidade_pedagogica_id), ''))
    from public.questao_unidades_pedagogicas qup where qup.questao_id = ant.id
  ) <> ant.hash_vinculos_unidade;
  call hotfix_2026_assert('vinculos de unidade pedagogica idênticos nas 10 (hash bate)', v_diferentes_vinculo_unidade = 0);

  select count(*) into v_diferentes_vinculo_curso
  from _hotfix2026_antes ant
  where (
    select md5(coalesce(string_agg(cq.curso_id::text, ',' order by cq.curso_id), ''))
    from public.curso_questoes cq where cq.questao_id = ant.id
  ) <> ant.hash_vinculos_curso;
  call hotfix_2026_assert('vinculos de curso_questoes idênticos nas 10 (hash bate)', v_diferentes_vinculo_curso = 0);

  select count(*) into v_vazia
  from public.questoes q
  join _staging_hotfix2026 s on s.questao_id = q.id
  where q.explicacao is null or btrim(q.explicacao) = '';
  call hotfix_2026_assert('nenhuma das 10 ficou com explicacao vazia', v_vazia = 0);

  select count(*) into v_nao_atualizadas
  from public.questoes q
  join _staging_hotfix2026 s on s.questao_id = q.id
  where regexp_replace(q.explicacao, E'\\r\\n', E'\\n', 'g') <> regexp_replace(s.explicacao_nova, E'\\r\\n', E'\\n', 'g');
  call hotfix_2026_assert('todas as 10 explicacoes foram atualizadas para o texto corrigido exato', v_nao_atualizadas = 0);
end $$;

do $$
declare
  v_total integer;
  v_ok integer;
begin
  select count(*), count(*) filter (where ok) into v_total, v_ok from hotfix_2026_asserts;
  raise notice '=== RESUMO: % / % asserts passaram ===', v_ok, v_total;
  if v_ok <> v_total then
    raise exception 'Hotfix falhou: nem todos os asserts passaram (ver RESUMO acima).';
  end if;
end $$;

${mode === 'rollback'
    ? `-- Nada commitado: staging, UPDATE de teste e tabelas de assert -- tudo\n-- desfeito abaixo. Nenhuma escrita real em produção acontece aqui.\nROLLBACK;\n`
    : `-- Escrita real confirmada pelos asserts acima -- persistida agora.\nCOMMIT;\n`}`;
}

const harnessSql = body('rollback');
const applySql = body('commit');

const harnessCore = harnessSql
  .replace('HARNESS TRANSACIONAL — TERMINA SEMPRE EM ROLLBACK, NADA PERSISTE.', '')
  .replace(/-- Nada commitado:[\s\S]*ROLLBACK;\n$/, '');
const applyCore = applySql
  .replace('APLICAÇÃO REAL — TERMINA EM COMMIT.', '')
  .replace(/-- Escrita real confirmada[\s\S]*COMMIT;\n$/, '');
if (harnessCore !== applyCore) {
  throw new Error('Harness e apply divergem fora do bloco esperado (modo/rollback-commit) -- gerar novamente.');
}

fs.writeFileSync(HARNESS_OUT_PATH, harnessSql, 'utf8');
fs.writeFileSync(APPLY_OUT_PATH, applySql, 'utf8');
console.log(`Gerado: ${path.relative(ROOT, HARNESS_OUT_PATH)}`);
console.log(`Gerado: ${path.relative(ROOT, APPLY_OUT_PATH)}`);
console.log('Harness e apply verificados: identicos exceto pelo modo (ROLLBACK vs COMMIT).');
console.log(`Questões: ${idsListaSql}`);
