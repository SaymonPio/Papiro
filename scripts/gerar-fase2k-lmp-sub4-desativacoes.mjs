#!/usr/bin/env node
// Fase 2K — sub-lote 4 (Lei Maria da Penha): desativa as 2 divergencias
// confirmadas na auditoria (auditoria/fase2k_lmp_sub4_resultado.json), por
// decisao de produto do usuario:
//
//   - id 1346: QUESTAO_DESATUALIZADA. O gabarito (alternativa C) e a
//     explicacao reproduzem a regra de "dispositivos de seguranca de
//     monitoramento custeados pelo agressor", que a explicacao atribui
//     por engano ao "art. 9º, §5º" -- o dispositivo real (art. 22, §5º,
//     Lei 15.125/2025) foi revogado pelo art. 5º da Lei 15.383/2026 (em
//     vigor desde 10/04/2026). Nenhuma das 5 alternativas descreve a
//     regra hoje vigente (custeio publico via FNSP) -- a questao ficou
//     sem resposta correta disponivel.
//   - id 1335: RESSALVA_JURIDICA. A alternativa marcada correta reproduz
//     literalmente o art. 20 da Lei (nunca alterado, ainda contem "de
//     oficio"), mas ha controversia doutrinaria e jurisprudencial REAL e
//     NAO PACIFICADA (STJ dividido, confirmado por busca) sobre se essa
//     previsao sobreviveu a reforma do art. 311 do CPP pelo Pacote
//     Anticrime (Lei 13.964/2019), que vedou a decretacao de oficio no
//     regime geral. A propria explicacao contem contradicao interna
//     (valida o gabarito com "de oficio" mas argumenta o oposto em
//     prosa). Decisao de produto: nao manter questao juridicamente
//     controvertida no fluxo ativo enquanto nao houver resolucao segura.
//
// Em AMBOS os casos: NAO reescrever gabarito historico da banca, NAO
// alterar explicacao, NAO alterar alternativas -- apenas desativar
// (ativa=false), preservando integralmente todo o conteudo e metadados
// historicos. Mesmo padrao ja usado para as questoes 1337/1340
// (Tema 1186/STJ) e para a questao 344 (Fase 2K sub-lote 1).
//
// So altera public.questoes.ativa, e SOMENTE nessas 2 linhas (1335 e
// 1346). Gera harness (ROLLBACK) e aplicacao real (COMMIT) do MESMO
// corpo.

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const HARNESS_OUT_PATH = path.join(ROOT, 'supabase/fase2k_lmp_sub4_desativacoes_teste_rollback.sql');
const APPLY_OUT_PATH = path.join(ROOT, 'supabase/fase2k_lmp_sub4_desativacoes.sql');

// Mesmo usuario admin usado nos harnesses anteriores desta materia.
const ADMIN_USER_ID = 'e5523807-6cc8-4867-8a56-77c17552e56e';

function sqlStr(s) {
  return `'${String(s).replace(/'/g, "''")}'`;
}

// Hash (md5) da linha inteira de public.questoes (enunciado|fonte|banca|
// concurso|materia_id|assunto_id|ativa) e da explicacao (CRLF normalizado
// para LF), capturados AO VIVO via MCP read-only imediatamente antes de
// gerar este script -- precondicao: se o estado mudou desde a auditoria,
// a transacao inteira aborta.
const HASH_QUESTAO_ANTES = {
  1335: '90bfc645116e23d0798ab5d592da3e15',
  1346: '40f46c0021fb951c2654f8318b3cba4c',
};
const HASH_EXPLICACAO_ANTES = {
  1335: '4bd09b5db310002b989b434f348210c8',
  1346: '8eebc8988f8de6d791a61e5e1e50fc72',
};

function body(mode) {
  return `-- ============================================================================
-- FASE 2K — sub-lote 4: desativação das questões 1335 e 1346
-- ${mode === 'rollback' ? 'HARNESS TRANSACIONAL — TERMINA SEMPRE EM ROLLBACK, NADA PERSISTE.' : 'APLICAÇÃO REAL — TERMINA EM COMMIT.'}
-- ============================================================================
--
-- id 1346 (QUESTAO_DESATUALIZADA): gabarito e explicação reproduzem regra
-- de custeio de dispositivos de monitoramento pelo agressor, revogada
-- pelo art. 5º da Lei 15.383/2026 (em vigor desde 10/04/2026). Nenhuma
-- das 5 alternativas descreve a regra hoje vigente.
--
-- id 1335 (RESSALVA_JURIDICA): alternativa marcada correta reproduz
-- literalmente o art. 20 da Lei ("de ofício"), mas há controvérsia real e
-- não pacificada (STJ dividido) sobre a subsistência dessa previsão após
-- a reforma do art. 311 do CPP pelo Pacote Anticrime (Lei 13.964/2019).
-- Decisão de produto: desativar em vez de manter questão controvertida
-- ativa.
--
-- Evidência completa: auditoria/fase2k_lmp_sub4_resultado.json
--
-- Em AMBOS os casos: NÃO se reescreve gabarito, explicação ou
-- alternativas — só ativa=false. Nenhuma outra questão é tocada —
-- provado abaixo por GET DIAGNOSTICS (exatamente 2 linhas) e por
-- comparação jsonb byte-a-byte de todas as demais colunas antes/depois,
-- mesmo padrão do harness de desativação de 1337/1340 e da questão 344.
-- ============================================================================

BEGIN;

set local request.jwt.claim.sub = ${sqlStr(ADMIN_USER_ID)};

-- ----------------------------------------------------------------------------
-- Snapshot ANTES — linha inteira das 2 questões-alvo (exceto ativa e
-- atualizado_em, os únicos campos autorizados a mudar).
-- ----------------------------------------------------------------------------
create temporary table _f2k4_snap_questoes on commit drop as
select id, ativa, (to_jsonb(q) - 'ativa' - 'atualizado_em') as dados_imutaveis
from public.questoes q
where q.id in (1335, 1346);

create temporary table _f2k4_snap_alternativas on commit drop as
select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
from public.alternativas a
where a.questao_id in (1335, 1346)
group by questao_id;

create temporary table _f2k4_snap_global on commit drop as
select
  (select count(*) from public.questoes) as total_questoes_antes,
  (select count(*) from public.questoes where ativa) as total_ativas_antes;

create temporary table _f2k4_staging (
  questao_id bigint primary key,
  hash_questao_esperado text,
  hash_explicacao_esperado text
) on commit drop;

insert into _f2k4_staging (questao_id, hash_questao_esperado, hash_explicacao_esperado) values
  (1335, ${sqlStr(HASH_QUESTAO_ANTES[1335])}, ${sqlStr(HASH_EXPLICACAO_ANTES[1335])}),
  (1346, ${sqlStr(HASH_QUESTAO_ANTES[1346])}, ${sqlStr(HASH_EXPLICACAO_ANTES[1346])});

create temporary table _f2k4_asserts (ordem serial primary key, descricao text, ok boolean) on commit drop;

-- ----------------------------------------------------------------------------
-- PRECONDIÇÕES — abortam tudo antes de qualquer escrita se o estado
-- divergir do auditado.
-- ----------------------------------------------------------------------------
do $$
declare
  v_qtd int;
  v_divergentes int;
begin
  select count(*) into v_qtd from _f2k4_staging;
  if v_qtd <> 2 then
    raise exception 'PRECONDICAO FALHOU: staging nao tem exatamente 2 questoes (tem %)', v_qtd;
  end if;

  select count(*) into v_divergentes
  from public.questoes q
  join _f2k4_staging s on s.questao_id = q.id
  where q.ativa is distinct from true
     or md5(q.enunciado || '|' || coalesce(q.fonte,'') || '|' || coalesce(q.banca,'') || '|' || coalesce(q.concurso,'') || '|' || q.materia_id::text || '|' || coalesce(q.assunto_id::text,'') || '|' || q.ativa::text) <> s.hash_questao_esperado
     or md5(regexp_replace(q.explicacao, E'\\r\\n', E'\\n', 'g')) <> s.hash_explicacao_esperado;
  if v_divergentes > 0 then
    raise exception 'PRECONDICAO FALHOU: % questao(oes) nao esta(ao) mais no estado auditado -- abortando por seguranca', v_divergentes;
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ESCRITA (única) — desativa exclusivamente as 2 questões-alvo. Gabarito,
-- enunciado, alternativas, explicação, banca, concurso, fonte: intocados.
-- ----------------------------------------------------------------------------
do $$
declare
  v_linhas int;
begin
  update public.questoes
  set ativa = false, atualizado_em = now()
  where id in (1335, 1346);
  get diagnostics v_linhas = row_count;
  if v_linhas <> 2 then
    raise exception 'ESCRITA FALHOU: esperado UPDATE de exatamente 2 linhas, afetou %', v_linhas;
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ASSERTS pós-escrita.
-- ----------------------------------------------------------------------------
do $$
begin
  insert into _f2k4_asserts (descricao, ok)
  select '1335 e 1346 estao ativa = false',
    (select count(*) from public.questoes where id in (1335,1346) and ativa = false) = 2;

  insert into _f2k4_asserts (descricao, ok)
  select 'nenhuma coluna alem de ativa/atualizado_em mudou em 1335/1346 (comparacao jsonb byte-a-byte, inclui explicacao)',
    not exists (
      select 1 from public.questoes q
      join _f2k4_snap_questoes s on s.id = q.id
      where (to_jsonb(q) - 'ativa' - 'atualizado_em') <> s.dados_imutaveis
    );

  insert into _f2k4_asserts (descricao, ok)
  select 'alternativas de 1335/1346 (texto/ordem/correta — gabarito) continuam byte-identicas',
    not exists (
      select 1
      from _f2k4_snap_alternativas s
      join (
        select questao_id, jsonb_agg(to_jsonb(a) order by a.ordem) as alternativas
        from public.alternativas a
        where a.questao_id in (1335, 1346)
        group by questao_id
      ) d on d.questao_id = s.questao_id
      where d.alternativas <> s.alternativas
    );

  insert into _f2k4_asserts (descricao, ok)
  select 'nenhuma linha foi criada/excluida em questoes (contagem total inalterada)',
    (select count(*) from public.questoes) = (select total_questoes_antes from _f2k4_snap_global);

  insert into _f2k4_asserts (descricao, ok)
  select 'total global de questoes ativas caiu exatamente em 2 (nenhuma outra linha teve ativa alterado)',
    (select count(*) from public.questoes where ativa = true) = (select total_ativas_antes - 2 from _f2k4_snap_global);

  insert into _f2k4_asserts (descricao, ok)
  select '1335 e 1346 preservam explicacao/gabarito historico da banca (nao foram reescritos)',
    (select count(*) from public.questoes q join _f2k4_staging s on s.questao_id = q.id
     where md5(regexp_replace(q.explicacao, E'\\r\\n', E'\\n', 'g')) = s.hash_explicacao_esperado) = 2;
end $$;

do $$
declare v_total integer; v_ok integer;
begin
  select count(*), count(*) filter (where ok) into v_total, v_ok from _f2k4_asserts;
  raise notice '=== RESUMO: % / % asserts passaram ===', v_ok, v_total;
  if v_ok <> v_total then
    raise exception 'Fase 2K sub-lote 4 (desativacoes) falhou: nem todos os asserts passaram (ver RESUMO acima).';
  end if;
end $$;

${mode === 'rollback'
    ? `-- Nada commitado: staging, UPDATE de teste e tabelas de assert — tudo\n-- desfeito abaixo. Nenhuma escrita real em produção acontece aqui.\nROLLBACK;\n`
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
