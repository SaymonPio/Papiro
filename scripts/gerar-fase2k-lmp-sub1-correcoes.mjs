#!/usr/bin/env node
// Fase 2K — sub-lote 1 (Lei Maria da Penha): fecha as duas divergencias
// confirmadas na auditoria (auditoria/fase2k_lmp_sub1_resultado.json):
//
//   - id 344: GABARITO_DESATUALIZADO. A assertiva III do enunciado
//     ("dispositivos de seguranca... custos ressarcidos pelo agressor") e
//     a explicacao citavam art. 9º, §5º -- na verdade o dispositivo real
//     era o art. 22, §5º (incluido pela Lei 15.125/2025), revogado pelo
//     art. 5º da Lei 15.383/2026 (em vigor desde 10/04/2026) e substituido
//     por um regime de monitoracao eletronica custeado com recursos
//     publicos (FNSP), sem ressarcimento pelo agressor. Decisao de
//     produto (usuario, 2026-08-19): NAO reescrever o gabarito historico
//     da banca nem atualizar a explicacao para a lei vigente -- apenas
//     desativar (ativa=false). Enunciado, alternativas, gabarito
//     original, banca, concurso, fonte, ano e a propria explicacao
//     permanecem intocados.
//   - id 739: CORRECAO_EXPLICACAO. A explicacao citava "Arthur", nome que
//     nao existe no enunciado desta questao (residuo herdado da questao
//     734, de fonte diferente). Corrige somente essa palavra no texto de
//     apoio; gabarito (C), artigo citado (art. 7º, III) e raciocinio
//     juridico permanecem os mesmos.
//
// So altera public.questoes.ativa (id 344) e public.questoes.explicacao
// (id 739), e SOMENTE nessas 2 linhas. Gera harness (ROLLBACK) e
// aplicacao real (COMMIT) do MESMO corpo, mesmo padrao dos hotfixes
// anteriores (1324, emendas2026, desativacao 1337/1340).

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const HARNESS_OUT_PATH = path.join(ROOT, 'supabase/fase2k_lmp_sub1_correcoes_teste_rollback.sql');
const APPLY_OUT_PATH = path.join(ROOT, 'supabase/fase2k_lmp_sub1_correcoes.sql');

// Mesmo usuario admin usado no harness de desativacao 1337/1340.
const ADMIN_USER_ID = 'e5523807-6cc8-4867-8a56-77c17552e56e';

function sqlStr(s) {
  return `'${String(s).replace(/'/g, "''")}'`;
}

// Hash (md5, CRLF normalizado para LF) da explicacao que estava em
// producao ANTES desta correcao, capturado ao vivo via MCP read-only
// imediatamente antes de gerar este script -- usado como precondicao: se
// o estado mudou desde a auditoria, a transacao inteira aborta.
const HASH_EXPLICACAO_ANTES = {
  344: '06ee268854e60f668d91db65dcac9630',
  739: '5c609d7890e01eed7f10795bbf6acda0',
};

const EXPLICACAO_NOVA_739 = "GABARITO: alternativa C\r\n\r\nPOR QUE A ALTERNATIVA C ESTÁ CORRETA:\r\nA conduta do marido — forçar a esposa ao aborto mediante ameaça de retirar apoio financeiro — configura violência sexual, nos termos do art. 7º, III, que expressamente prevê como violência sexual a conduta que force a mulher ao aborto mediante coação, chantagem, suborno ou manipulação. A Lei Maria da Penha é a legislação específica que protege a mulher nessa hipótese.\r\n\r\nPOR QUE A ALTERNATIVA A ESTÁ INCORRETA:\r\n\"Decreto-Lei 'João Traído'\" não existe como legislação brasileira — nome fantasioso.\r\n\r\nPOR QUE A ALTERNATIVA B ESTÁ INCORRETA:\r\n\"Lei da Vergonha Pública\" não existe como legislação brasileira — nome fantasioso.\r\n\r\nPOR QUE A ALTERNATIVA D ESTÁ INCORRETA:\r\n\"Código de Defesa Familiar\" não existe como legislação brasileira — nome fantasioso.\r\n\r\nPOR QUE A ALTERNATIVA E ESTÁ INCORRETA:\r\n\"Lei do Ventre Livre\" é uma lei histórica de 1871, sobre a condição dos filhos de mulheres escravizadas — não tem relação com a proteção da mulher contra violência doméstica.\r\n\r\nBIZU DE PROVA:\r\nForçar a mulher ao aborto, à gravidez, ao matrimônio ou impedi-la de usar método contraceptivo, mediante coação, chantagem, suborno ou manipulação, é violência SEXUAL pelo art. 7º, III — não pense automaticamente em violência física só porque envolve o corpo da vítima.";

function body(mode) {
  return `-- ============================================================================
-- FASE 2K — sub-lote 1 (Lei Maria da Penha): 1 desativação + 1 correção de
-- explicação
-- ${mode === 'rollback' ? 'HARNESS TRANSACIONAL — TERMINA SEMPRE EM ROLLBACK, NADA PERSISTE.' : 'APLICAÇÃO REAL — TERMINA EM COMMIT.'}
-- ============================================================================
--
-- id 344 (GABARITO_DESATUALIZADO): a assertiva III do enunciado
-- ("dispositivos de segurança... custos ressarcidos pelo agressor") e a
-- explicação citavam art. 9º, §5º — na verdade o dispositivo real era o
-- art. 22, §5º (incluído pela Lei 15.125/2025), revogado pelo art. 5º da
-- Lei 15.383/2026 (em vigor desde 10/04/2026) e substituído por regime de
-- monitoração eletrônica custeado com recursos públicos (FNSP), sem
-- ressarcimento pelo agressor. Decisão de produto (usuário, 2026-08-19):
-- NÃO reescrever o gabarito histórico da banca nem atualizar a explicação
-- para a lei vigente — apenas desativar (ativa=false). Enunciado,
-- alternativas, gabarito original, banca, concurso, fonte, ano e a
-- própria explicação permanecem intocados.
--
-- id 739 (CORRECAO_EXPLICACAO): a explicação citava "Arthur", nome que
-- não existe no enunciado desta questão (resíduo herdado da questão 734,
-- de fonte diferente). Corrige somente essa palavra no texto de apoio;
-- gabarito (C), artigo citado (art. 7º, III) e raciocínio jurídico
-- permanecem os mesmos.
--
-- Evidência completa: auditoria/fase2k_lmp_sub1_resultado.json
--
-- ÚNICAS colunas alteradas: public.questoes.ativa (id 344) e
-- public.questoes.explicacao (id 739) — e SOMENTE nessas 2 linhas.
-- Nenhuma outra questão é tocada — provado abaixo por GET DIAGNOSTICS
-- (exatamente 1 linha afetada por UPDATE) e por comparação jsonb
-- byte-a-byte de todas as demais colunas antes/depois (mesmo padrão do
-- harness de desativação de 1337/1340).
-- ============================================================================

BEGIN;

set local request.jwt.claim.sub = ${sqlStr(ADMIN_USER_ID)};

-- ----------------------------------------------------------------------------
-- Snapshot ANTES.
-- ----------------------------------------------------------------------------
create temporary table _f2k_snap_344 on commit drop as
select id, ativa, (to_jsonb(q) - 'ativa' - 'atualizado_em') as dados_imutaveis
from public.questoes q where q.id = 344;

create temporary table _f2k_snap_739 on commit drop as
select id, explicacao, (to_jsonb(q) - 'explicacao' - 'atualizado_em') as dados_imutaveis
from public.questoes q where q.id = 739;

create temporary table _f2k_snap_alt on commit drop as
select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
from public.alternativas a where a.questao_id in (344, 739) group by questao_id;

create temporary table _f2k_snap_global on commit drop as
select (select count(*) from public.questoes) as total_questoes_antes;

create temporary table _f2k_asserts (ordem serial primary key, descricao text, ok boolean) on commit drop;

-- ----------------------------------------------------------------------------
-- PRECONDIÇÕES — abortam tudo antes de qualquer escrita se o estado
-- divergir do auditado.
-- ----------------------------------------------------------------------------
do $$
begin
  if not exists (select 1 from public.questoes where id = 344 and ativa = true
      and md5(regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g')) = ${sqlStr(HASH_EXPLICACAO_ANTES[344])}) then
    raise exception 'PRECONDICAO FALHOU: questao 344 nao esta mais no estado auditado (ativa=true, explicacao com hash esperado)';
  end if;

  if not exists (select 1 from public.questoes where id = 739 and ativa = true
      and md5(regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g')) = ${sqlStr(HASH_EXPLICACAO_ANTES[739])}) then
    raise exception 'PRECONDICAO FALHOU: questao 739 nao esta mais no estado auditado (ativa=true, explicacao com hash esperado)';
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ESCRITA 1 — desativa exclusivamente a questão 344. Gabarito, enunciado,
-- alternativas, banca, concurso, fonte, explicação: intocados.
-- ----------------------------------------------------------------------------
do $$
declare v_linhas int;
begin
  update public.questoes set ativa = false, atualizado_em = now() where id = 344;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then
    raise exception 'ESCRITA 1 FALHOU: esperado UPDATE de exatamente 1 linha (344), afetou %', v_linhas;
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ESCRITA 2 — corrige exclusivamente a explicação da questão 739.
-- Gabarito, enunciado, alternativas, banca, concurso, fonte, ativa:
-- intocados.
-- ----------------------------------------------------------------------------
do $$
declare v_linhas int;
begin
  update public.questoes set explicacao = ${sqlStr(EXPLICACAO_NOVA_739)} where id = 739;
  get diagnostics v_linhas = row_count;
  if v_linhas <> 1 then
    raise exception 'ESCRITA 2 FALHOU: esperado UPDATE de exatamente 1 linha (739), afetou %', v_linhas;
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ASSERTS pós-escrita.
-- ----------------------------------------------------------------------------
do $$
begin
  insert into _f2k_asserts (descricao, ok)
  select 'nenhuma questao criada/removida (total_questoes inalterado)',
    (select count(*) from public.questoes) = (select total_questoes_antes from _f2k_snap_global);

  insert into _f2k_asserts (descricao, ok)
  select '344 esta ativa = false',
    (select ativa from public.questoes where id = 344) = false;

  insert into _f2k_asserts (descricao, ok)
  select '344: nenhuma coluna alem de ativa/atualizado_em mudou (comparacao jsonb byte-a-byte, inclui explicacao)',
    not exists (
      select 1 from public.questoes q join _f2k_snap_344 s on s.id = q.id
      where (to_jsonb(q) - 'ativa' - 'atualizado_em') <> s.dados_imutaveis
    );

  insert into _f2k_asserts (descricao, ok)
  select '739 continua ativa = true',
    (select ativa from public.questoes where id = 739) = true;

  insert into _f2k_asserts (descricao, ok)
  select '739: nenhuma coluna alem de explicacao/atualizado_em mudou (comparacao jsonb byte-a-byte, inclui ativa)',
    not exists (
      select 1 from public.questoes q join _f2k_snap_739 s on s.id = q.id
      where (to_jsonb(q) - 'explicacao' - 'atualizado_em') <> s.dados_imutaveis
    );

  insert into _f2k_asserts (descricao, ok)
  select '739: explicacao foi atualizada para o texto corrigido exato',
    (select regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g') from public.questoes where id = 739)
    = regexp_replace(${sqlStr(EXPLICACAO_NOVA_739)}, E'\\r\\n', E'\\n', 'g');

  insert into _f2k_asserts (descricao, ok)
  select '739: explicacao nao ficou vazia',
    (select explicacao is not null and btrim(explicacao) <> '' from public.questoes where id = 739);

  insert into _f2k_asserts (descricao, ok)
  select 'alternativas (texto/ordem/correta — gabarito) de 344 e 739 permanecem byte-identicas',
    not exists (
      select 1 from _f2k_snap_alt s
      join (
        select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
        from public.alternativas a where a.questao_id in (344, 739) group by questao_id
      ) d on d.questao_id = s.questao_id
      where d.alternativas <> s.alternativas
    );
end $$;

do $$
declare v_total integer; v_ok integer;
begin
  select count(*), count(*) filter (where ok) into v_total, v_ok from _f2k_asserts;
  raise notice '=== RESUMO: % / % asserts passaram ===', v_ok, v_total;
  if v_ok <> v_total then
    raise exception 'Fase 2K sub-lote 1 falhou: nem todos os asserts passaram (ver RESUMO acima).';
  end if;
end $$;

${mode === 'rollback'
    ? `-- Nada commitado: staging, UPDATEs de teste e tabelas de assert — tudo\n-- desfeito abaixo. Nenhuma escrita real em produção acontece aqui.\nROLLBACK;\n`
    : `-- Escrita real confirmada pelos asserts acima — persistida agora.\nCOMMIT;\n`}`;
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
  throw new Error('Harness e apply divergem fora do bloco esperado (modo/rollback-commit) — gerar novamente.');
}

fs.writeFileSync(HARNESS_OUT_PATH, harnessSql, 'utf8');
fs.writeFileSync(APPLY_OUT_PATH, applySql, 'utf8');
console.log(`Gerado: ${path.relative(ROOT, HARNESS_OUT_PATH)}`);
console.log(`Gerado: ${path.relative(ROOT, APPLY_OUT_PATH)}`);
console.log('Harness e apply verificados: identicos exceto pelo modo (ROLLBACK vs COMMIT).');
