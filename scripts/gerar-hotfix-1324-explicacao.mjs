#!/usr/bin/env node
// Hotfix minimo e auditavel para UMA UNICA questao: id 1324 (Lei Maria da
// Penha, sub-lote 1, ja aplicado em producao). A explicacao original desse
// sub-lote tratava a decretacao de prisao preventiva "de oficio" (art. 20
// da Lei) como possibilidade vigente sem ressalva -- revisao juridica
// posterior (mesma rodada que corrigiu o sub-lote 2) identificou que essa
// leitura esta superada na pratica pelo art. 311 do CPP (Lei 13.964/2019)
// e por jurisprudencia do STJ, que veda a decretacao de oficio mesmo em
// violencia domestica. A correcao ja esta em
// scripts/sublote1-lei-maria-penha-explicacoes.mjs (id 1324) -- este script
// so gera o par de arquivos SQL para aplicar essa mesma correcao, isolada,
// diretamente em producao.
//
// So altera public.questoes.explicacao da linha id=1324. Nao toca
// enunciado, alternativas, fonte, banca, concurso, materia_id, assunto_id,
// ativa, nem vinculos em questao_unidades_pedagogicas/curso_questoes -- e
// prova isso com hash antes/depois, alem de GET DIAGNOSTICS confirmando
// que exatamente 1 linha foi afetada pelo UPDATE.
//
// Gera dois arquivos a partir do MESMO corpo SQL (verificado identico por
// comparacao de string), igual ao padrao dos sub-lotes:
//   supabase/corrigir_explicacao_1324_teste_rollback.sql  (BEGIN...ROLLBACK)
//   supabase/corrigir_explicacao_1324.sql                 (BEGIN...COMMIT)

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { explicacoes as sublote1 } from './sublote1-lei-maria-penha-explicacoes.mjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const HARNESS_OUT_PATH = path.join(ROOT, 'supabase/corrigir_explicacao_1324_teste_rollback.sql');
const APPLY_OUT_PATH = path.join(ROOT, 'supabase/corrigir_explicacao_1324.sql');

function sqlStr(s) {
  return `'${String(s).replace(/'/g, "''")}'`;
}

const ID = 1324;

const entry = sublote1.find(e => e.id === ID);
if (!entry) throw new Error(`id ${ID} nao encontrado em sublote1-lei-maria-penha-explicacoes.mjs`);
const explicacaoNova = entry.explicacao;

// Texto atual, confirmado ao vivo em producao via MCP read-only (Supabase)
// imediatamente antes de gerar este hotfix. Usado como precondicao: se a
// explicacao ao vivo nao bater EXATAMENTE com isto (ignorando so a
// diferenca CRLF/LF do copy-paste no SQL Editor -- ver normalizacao
// abaixo), o hotfix aborta em vez de sobrescrever um estado inesperado.
const explicacaoAntigaEsperada = `GABARITO: alternativa E

POR QUE A ALTERNATIVA E ESTÁ CORRETA:
O art. 6º dispõe que a violência doméstica e familiar contra a mulher constitui uma das formas de violação dos direitos humanos — fundamento aplicável ao "ciclo de violência" descrito na situação hipotética.

POR QUE A ALTERNATIVA A ESTÁ INCORRETA:
A coabitação não é requisito para a aplicação da Lei em relação íntima de afeto (art. 5º, III), ainda que o relacionamento tenha durado 12 anos sem coabitação.

POR QUE A ALTERNATIVA B ESTÁ INCORRETA:
O art. 15 estabelece o foro à escolha da OFENDIDA (domicílio/residência dela, lugar do fato ou domicílio do agressor) — a competência não é definida por opção do ofensor.

POR QUE A ALTERNATIVA C ESTÁ INCORRETA:
A prisão preventiva é decretada pelo juiz — de ofício, a requerimento do Ministério Público, ou mediante representação da autoridade policial (art. 20) — nunca diretamente pela autoridade policial.

POR QUE A ALTERNATIVA D ESTÁ INCORRETA:
A pena de cesta básica e os institutos despenalizadores da Lei 9.099/95 são vedados pela própria Lei Maria da Penha (arts. 17 e 41), não aplicáveis aos processos de sua competência.

BIZU DE PROVA:
O foro do art. 15 é escolha da ofendida, não do agressor; e só o juiz decreta prisão preventiva — a autoridade policial apenas representa por ela.`;

if (explicacaoNova === explicacaoAntigaEsperada) {
  throw new Error('Texto novo e texto antigo esperado sao identicos -- nada para corrigir, hotfix cancelado.');
}

function body(mode) {
  return `-- ============================================================================
-- HOTFIX — questoes.id = 1324 (Lei Maria da Penha, sub-lote 1, JA EM PRODUÇÃO)
-- ${mode === 'rollback' ? 'HARNESS TRANSACIONAL — TERMINA SEMPRE EM ROLLBACK, NADA PERSISTE.' : 'APLICAÇÃO REAL — TERMINA EM COMMIT.'}
-- ============================================================================
--
-- Motivo: a explicação da questão 1324, aplicada junto com o restante do
-- sub-lote 1, tratava a prisão preventiva "de ofício" (art. 20 da Lei) como
-- possibilidade vigente sem ressalva. Revisão jurídica posterior (mesma
-- rodada que corrigiu o sub-lote 2) identificou que essa leitura está
-- superada na prática: o art. 311 do CPP, na redação da Lei 13.964/2019
-- (Pacote Anticrime), exige sempre provocação, e o STJ já decidiu que o
-- juiz não pode decretar prisão preventiva de ofício, inclusive em
-- violência doméstica. Este hotfix corrige SOMENTE o parágrafo "POR QUE A
-- ALTERNATIVA C ESTÁ INCORRETA" (e o BIZU, que também citava "de ofício"
-- em outra questão do sub-lote 2 — aqui não, o BIZU de 1324 não menciona
-- "de ofício" e permanece igual). GABARITO, alternativa correta (E) e
-- todo o restante do texto ficam inalterados.
--
-- ÚNICA coluna alterada: public.questoes.explicacao, e SOMENTE na linha
-- id = 1324. Nenhuma outra questão é tocada — provado abaixo por
-- GET DIAGNOSTICS (exatamente 1 linha afetada pelo UPDATE) e por hash
-- antes/depois dos campos que não podem mudar (enunciado, alternativas —
-- inclui o gabarito —, fonte, banca, concurso, materia_id, assunto_id,
-- ativa, vínculos de unidade pedagógica e de curso_questoes).
--
-- Comparações de texto normalizam CRLF/LF (regexp_replace ... E'\\r\\n' ->
-- E'\\n') antes de comparar, porque o valor já em produção usa CRLF e o
-- copy/paste no SQL Editor pode alterar a convenção de quebra de linha do
-- arquivo sem alterar o conteúdo — a normalização evita falso negativo por
-- esse motivo puramente cosmético, sem enfraquecer a checagem de conteúdo.
-- ============================================================================

BEGIN;

-- ----------------------------------------------------------------------------
-- Snapshot ANTES — hash da linha 1324 (prova de que só explicacao muda) +
-- contador agregado (prova de ausência de efeito colateral em outras
-- questões).
-- ----------------------------------------------------------------------------
create temporary table _hotfix1324_antes on commit drop as
select
  q.id,
  q.explicacao as explicacao_antes,
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
where q.id = 1324;

create temporary table _hotfix1324_agregado_antes on commit drop as
select (select count(*) from public.questoes) as total_questoes;

-- ----------------------------------------------------------------------------
-- PRECONDIÇÕES — abortam tudo (RAISE EXCEPTION) antes de qualquer escrita.
-- ----------------------------------------------------------------------------
do $$
declare
  v_existe int;
  v_explicacao_atual text;
  v_explicacao_esperada text := ${sqlStr(explicacaoAntigaEsperada)};
begin
  select count(*) into v_existe from public.questoes where id = 1324;
  if v_existe <> 1 then
    raise exception 'Precondicao falhou: questao id=1324 nao encontrada (existe(m) %)', v_existe;
  end if;

  select explicacao into v_explicacao_atual from public.questoes where id = 1324;
  if regexp_replace(coalesce(v_explicacao_atual,''), E'\\r\\n', E'\\n', 'g')
     <> regexp_replace(v_explicacao_esperada, E'\\r\\n', E'\\n', 'g') then
    raise exception 'Precondicao falhou: explicacao atual de id=1324 nao bate com o texto esperado antes da correcao -- pode ter mudado desde a auditoria. Hotfix abortado por seguranca.';
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ESCRITA — altera SOMENTE explicacao, SOMENTE na linha id=1324.
-- ----------------------------------------------------------------------------
do $$
declare
  v_linhas_afetadas int;
begin
  update public.questoes
  set explicacao = ${sqlStr(explicacaoNova)}
  where id = 1324;

  get diagnostics v_linhas_afetadas = row_count;
  if v_linhas_afetadas <> 1 then
    raise exception 'UPDATE afetou % linha(s), esperado exatamente 1 -- abortando', v_linhas_afetadas;
  end if;
end $$;

-- ----------------------------------------------------------------------------
-- ASSERTS
-- ----------------------------------------------------------------------------
create table hotfix_1324_asserts (ordem serial primary key, descricao text, ok boolean);

create procedure hotfix_1324_assert(p_descricao text, p_ok boolean)
language plpgsql
as $assert$
begin
  insert into hotfix_1324_asserts (descricao, ok) values (p_descricao, p_ok);
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
  v_agregado_antes record;
  v_explicacao_nova_esperada text := ${sqlStr(explicacaoNova)};
  v_explicacao_nova_real text;
  v_total_questoes int;
  v_hash_questao_depois text;
  v_hash_alternativas_depois text;
  v_hash_vinculos_unidade_depois text;
  v_hash_vinculos_curso_depois text;
begin
  select * into v_antes from _hotfix1324_antes;
  select * into v_agregado_antes from _hotfix1324_agregado_antes;

  select explicacao into v_explicacao_nova_real from public.questoes where id = 1324;
  call hotfix_1324_assert(
    'explicacao da questao 1324 foi atualizada para o texto corrigido exato (gabarito E mantido, so o paragrafo da alternativa C mudou)',
    regexp_replace(v_explicacao_nova_real, E'\\r\\n', E'\\n', 'g') = regexp_replace(v_explicacao_nova_esperada, E'\\r\\n', E'\\n', 'g')
  );

  select count(*) into v_total_questoes from public.questoes;
  call hotfix_1324_assert('nenhuma questao criada/removida (total_questoes inalterado)', v_total_questoes = v_agregado_antes.total_questoes);

  select md5(q.enunciado || '|' || coalesce(q.fonte,'') || '|' || coalesce(q.banca,'') || '|' || coalesce(q.concurso,'') || '|' || q.materia_id::text || '|' || coalesce(q.assunto_id::text,'') || '|' || q.ativa::text)
    into v_hash_questao_depois
    from public.questoes q where q.id = 1324;
  call hotfix_1324_assert('enunciado/fonte/banca/concurso/materia_id/assunto_id/ativa da questao 1324 inalterados (hash bate)', v_hash_questao_depois = v_antes.hash_questao);

  select md5(string_agg(a.ordem::text || ':' || a.texto || ':' || a.correta::text, '|' order by a.ordem))
    into v_hash_alternativas_depois
    from public.alternativas a where a.questao_id = 1324;
  call hotfix_1324_assert('alternativas da questao 1324 (texto/correta/ordem, ou seja, o gabarito) inalteradas (hash bate)', v_hash_alternativas_depois = v_antes.hash_alternativas);

  select md5(coalesce(string_agg(qup.unidade_pedagogica_id::text, ',' order by qup.unidade_pedagogica_id), ''))
    into v_hash_vinculos_unidade_depois
    from public.questao_unidades_pedagogicas qup where qup.questao_id = 1324;
  call hotfix_1324_assert('vinculos de unidade pedagogica da questao 1324 inalterados (hash bate)', v_hash_vinculos_unidade_depois = v_antes.hash_vinculos_unidade);

  select md5(coalesce(string_agg(cq.curso_id::text, ',' order by cq.curso_id), ''))
    into v_hash_vinculos_curso_depois
    from public.curso_questoes cq where cq.questao_id = 1324;
  call hotfix_1324_assert('vinculos de curso_questoes da questao 1324 inalterados (hash bate)', v_hash_vinculos_curso_depois = v_antes.hash_vinculos_curso);
end $$;

do $$
declare
  v_total integer;
  v_ok integer;
begin
  select count(*), count(*) filter (where ok) into v_total, v_ok from hotfix_1324_asserts;
  raise notice '=== RESUMO: % / % asserts passaram ===', v_ok, v_total;
  if v_ok <> v_total then
    raise exception 'Hotfix falhou: nem todos os asserts passaram (ver RESUMO acima).';
  end if;
end $$;

${mode === 'rollback'
    ? `-- Nada commitado: UPDATE de teste e tabelas de assert -- tudo desfeito\n-- abaixo. Nenhuma escrita real em produção acontece aqui.\nROLLBACK;\n`
    : `-- Escrita real confirmada pelos asserts acima -- persistida agora.\nCOMMIT;\n`}`;
}

const harnessSql = body('rollback');
const applySql = body('commit');

// Verificacao: os dois arquivos devem ser identicos exceto pelo bloco de
// modo (comentario do titulo + ROLLBACK/COMMIT final), igual ao padrao dos
// sub-lotes.
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
