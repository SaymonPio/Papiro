#!/usr/bin/env node
// Fase 2T-C2 — Saneamento textual mínimo dos IDs 3 e 676, decorrente da Fase 2T-C
// (análise estrutural / auditoria de impacto). A recategorização do ID 3 foi
// descartada nessa auditoria (o curso "gm-alvorada" tem Direito Constitucional em seu
// currículo e NÃO tem Legislação Específica — mover a questão quebraria filtros,
// missões e reclassificaria retroativamente histórico real de respostas). Esta fase
// trata apenas dos dois defeitos textuais registrados naquela auditoria, sem tocar em
// matéria, assunto, gabarito ou qualquer outro campo.
//
// Escopo:
//   - id 3 (public.questoes.explicacao): remove o parágrafo residual "POR QUE A
//     ALTERNATIVA E ESTÁ INCORRETA: [...]" — a questão só tem 4 alternativas
//     cadastradas (não existe alternativa E); o parágrafo é resíduo de um template de
//     explicação de 5 alternativas aplicado indevidamente. materia_id, assunto_id,
//     ativa, enunciado, alternativas e gabarito permanecem intocados.
//   - id 676 (public.questoes.enunciado): corrige "Qual éesse órgão?" para "Qual é
//     esse órgão?" — ausência de espaço por defeito de importação. explicacao,
//     alternativas, gabarito, materia_id e assunto_id permanecem intocados.
//
// Referência (Fase 2T-C / 2T-C — auditoria de impacto já entregues nesta sessão).

import fs from 'fs';
import path from 'path';
import crypto from 'crypto';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const HARNESS_OUT_PATH = path.join(ROOT, 'supabase/fase2t-c2_saneamento_textual_correcoes_teste_rollback.sql');
const APPLY_OUT_PATH = path.join(ROOT, 'supabase/fase2t-c2_saneamento_textual_correcoes.sql');

function sqlStr(s) {
  return `'${String(s).replace(/'/g, "''")}'`;
}

function md5(s) {
  return crypto.createHash('md5').update(s, 'utf8').digest('hex');
}

// Fórmula da questão: md5(enunciado || '|' || fonte || '|' || banca || '|' || concurso || '|' || materia_id || '|' || assunto_id || '|' || ativa)
function hashQuestao({ enunciado, fonte, banca, concurso, materia_id, assunto_id, ativa }) {
  return md5(`${enunciado}|${fonte ?? ''}|${banca ?? ''}|${concurso ?? ''}|${materia_id}|${assunto_id ?? ''}|${ativa}`);
}

// Fórmula da explicação: md5(regexp_replace(explicacao, '\r\n', '\n', 'g'))
function hashExplicacao(explicacao) {
  return md5(explicacao.replace(/\r\n/g, '\n'));
}

// --------------------------------------------------------------------------
// Estado ATUAL (pré-apply) capturado ao vivo do banco de produção, sem drift
// confirmado nesta sessão (Fase 2T-C2, pré-check).
// --------------------------------------------------------------------------

const ID3 = {
  id: 3,
  enunciado: 'Nos termos da Constituição Federal, os municípios poderão constituir guardas municipais destinadas principalmente à proteção de quê?',
  fonte: null,
  banca: 'Papiro — estilo Fundatec',
  concurso: 'Guarda Municipal de Alvorada',
  materia_id: 3,
  assunto_id: 2,
  ativa: true,
};

const ID676 = {
  id: 676,
  fonte: 'TEC Concursos — questão 3792267 — FUNDATEC — posição 301 no conjunto de 1.000 questões',
  banca: 'Fundatec',
  concurso: 'GM (Pref Gravataí)/Pref Gravataí/2026',
  materia_id: 10,
  assunto_id: 17,
  ativa: true,
};

const HASH_QUESTAO_3_ANTES = '6dc229c0c4c99033e5ffe71821163c7a';
const HASH_EXPLICACAO_3_ANTES = '2a0470d04673953e5349fe8bcf98e2c7';
const HASH_QUESTAO_676_ANTES = 'a51abba0cd1544112efac2c5e8b6a9ae';
const HASH_EXPLICACAO_676_ANTES = '634dbc7309eb33f9656cb016254e5493';

// Sanidade: os dados acima devem reproduzir os hashes pré-apply já auditados
if (hashQuestao(ID3) !== HASH_QUESTAO_3_ANTES) {
  throw new Error('Sanidade falhou: hash_questao recomputado do ID 3 não bate com o valor auditado pré-apply.');
}

const GABARITO = { 3: 1, 676: 3 }; // ordem da alternativa correta — inalterado nesta fase

// --------------------------------------------------------------------------
// Textos novos (intervenção mínima)
// --------------------------------------------------------------------------

const EXPLICACAO_NOVA_3 = `GABARITO: alternativa A\r
\r
POR QUE A ALTERNATIVA A ESTÁ CORRETA:\r
O Artigo 144, §8º, da Constituição Federal estabelece que os Municípios poderão constituir guardas municipais destinadas à proteção de seus BENS, SERVIÇOS E INSTALAÇÕES, conforme dispuser a lei.\r
\r
POR QUE A ALTERNATIVA B ESTÁ INCORRETA:\r
As guardas municipais não têm competência constitucional para exercer apuração penal geral privativa da polícia judiciária.\r
\r
POR QUE A ALTERNATIVA C ESTÁ INCORRETA:\r
A competência não abrange policiamento ostensivo rodoviário federal.\r
\r
POR QUE A ALTERNATIVA D ESTÁ INCORRETA:\r
Não atuam na fiscalização aduaneira ou controle de fronteiras privativo federal.\r
\r
BIZU DE PROVA:\r
Competência Constitucional das Guardas Municipais (Art. 144, §8º da CF/88):\r
Proteção de BENS, SERVIÇOS e INSTALAÇÕES do Município!`;

const ENUNCIADO_NOVO_676 = 'A Constituição Federal de 1988 instituiu a possibilidade de criação de um órgão responsável pela proteção dos bens, serviços e instalações dos municípios. Qual é esse órgão?';

// hashes pós-correção, computados programaticamente (evita transcrição manual)
const HASH_EXPLICACAO_3_DEPOIS = hashExplicacao(EXPLICACAO_NOVA_3);
const HASH_QUESTAO_676_DEPOIS = hashQuestao({ ...ID676, enunciado: ENUNCIADO_NOVO_676 });

// --------------------------------------------------------------------------

function body(mode) {
  return `-- ============================================================================
-- FASE 2T-C2 — SANEAMENTO TEXTUAL MÍNIMO (ID 3 explicacao / ID 676 enunciado)
-- Modo: ${mode === 'rollback' ? 'TESTE COM ROLLBACK OBRIGATÓRIO' : 'APPLY DEFINITIVO COM COMMIT'}
-- ============================================================================

BEGIN;

SET TRANSACTION READ WRITE;

DO $$
DECLARE
  v_total_questoes integer;
  v_total_ativas integer;
  v_total_inativas integer;
  v_explicacao_check text;
  v_enunciado_check text;
BEGIN
  -- --------------------------------------------------------------------------
  -- 1. PRECONDIÇÕES E GUARDAS CONTRA DRIFT (ESTADO PRÉ-APPLY)
  -- --------------------------------------------------------------------------

  SELECT count(*),
         count(*) FILTER (WHERE ativa = true),
         count(*) FILTER (WHERE ativa = false)
    INTO v_total_questoes, v_total_ativas, v_total_inativas
    FROM public.questoes;

  IF v_total_questoes <> 915 OR v_total_ativas <> 907 OR v_total_inativas <> 8 THEN
    RAISE EXCEPTION 'Precondição falhou: totais globais divergentes. Esperado 915/907/8, obtido %/%/%',
      v_total_questoes, v_total_ativas, v_total_inativas;
  END IF;

  -- Precondição: hash da questão e da explicação do ID 3 (estado pré-apply)
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 3) <> '${HASH_QUESTAO_3_ANTES}' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 3 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g')) FROM public.questoes WHERE id = 3) <> '${HASH_EXPLICACAO_3_ANTES}' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 3 divergiu do estado auditado.';
  END IF;

  -- Precondição: hash da questão e da explicação do ID 676 (estado pré-apply)
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 676) <> '${HASH_QUESTAO_676_ANTES}' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão 676 divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g')) FROM public.questoes WHERE id = 676) <> '${HASH_EXPLICACAO_676_ANTES}' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão 676 divergiu do estado auditado.';
  END IF;

  -- Precondição: ambas ativas, com materia_id/assunto_id e estrutura de alternativas esperados
  IF NOT EXISTS (SELECT 1 FROM public.questoes WHERE id = 3 AND ativa = true AND materia_id = 3 AND assunto_id = 2) THEN
    RAISE EXCEPTION 'Precondição falhou: questão 3 divergente do estado esperado (ativa/materia_id/assunto_id).';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.questoes WHERE id = 676 AND ativa = true AND materia_id = 10 AND assunto_id = 17) THEN
    RAISE EXCEPTION 'Precondição falhou: questão 676 divergente do estado esperado (ativa/materia_id/assunto_id).';
  END IF;

  IF (SELECT count(*) FROM public.alternativas WHERE questao_id = 3) <> 4 OR
     (SELECT count(*) FROM public.alternativas WHERE questao_id = 3 AND correta = true) <> 1 OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 3 AND ordem = 1 AND correta = true) THEN
    RAISE EXCEPTION 'Precondição falhou: estrutura de alternativas da questão 3 divergente do esperado (4 alternativas, 1 correta na ordem 1).';
  END IF;
  IF (SELECT count(*) FROM public.alternativas WHERE questao_id = 676) <> 5 OR
     (SELECT count(*) FROM public.alternativas WHERE questao_id = 676 AND correta = true) <> 1 OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 676 AND ordem = 3 AND correta = true) THEN
    RAISE EXCEPTION 'Precondição falhou: estrutura de alternativas da questão 676 divergente do esperado (5 alternativas, 1 correta na ordem 3).';
  END IF;

  -- --------------------------------------------------------------------------
  -- 2. ATUALIZAÇÕES DO ESCOPO — CADA QUESTÃO EM SOMENTE UM CAMPO
  -- --------------------------------------------------------------------------

  UPDATE public.questoes SET explicacao = ${sqlStr(EXPLICACAO_NOVA_3)} WHERE id = 3;
  UPDATE public.questoes SET enunciado = ${sqlStr(ENUNCIADO_NOVO_676)} WHERE id = 676;

  -- --------------------------------------------------------------------------
  -- 3. ASSERTS PÓS-UPDATE
  -- --------------------------------------------------------------------------

  -- Assert 1: Totais globais inalterados
  SELECT count(*),
         count(*) FILTER (WHERE ativa = true),
         count(*) FILTER (WHERE ativa = false)
    INTO v_total_questoes, v_total_ativas, v_total_inativas
    FROM public.questoes;

  IF v_total_questoes <> 915 OR v_total_ativas <> 907 OR v_total_inativas <> 8 THEN
    RAISE EXCEPTION 'Assert 1 falhou: totais pós-migração incorretos (%/%/%), esperado 915/907/8',
      v_total_questoes, v_total_ativas, v_total_inativas;
  END IF;

  -- Assert 2: ID 3 continua ativa, materia_id=3, assunto_id=2
  IF NOT EXISTS (SELECT 1 FROM public.questoes WHERE id = 3 AND ativa = true AND materia_id = 3 AND assunto_id = 2) THEN
    RAISE EXCEPTION 'Assert 2 falhou: questão 3 teve ativa/materia_id/assunto_id alterados indevidamente';
  END IF;

  -- Assert 3: ID 676 continua ativa, materia_id=10, assunto_id=17
  IF NOT EXISTS (SELECT 1 FROM public.questoes WHERE id = 676 AND ativa = true AND materia_id = 10 AND assunto_id = 17) THEN
    RAISE EXCEPTION 'Assert 3 falhou: questão 676 teve ativa/materia_id/assunto_id alterados indevidamente';
  END IF;

  -- Assert 4: alternativas e gabarito de ambas as questões inalterados (estrutura e ordem correta)
  IF (SELECT count(*) FROM public.alternativas WHERE questao_id = 3) <> 4 OR
     (SELECT count(*) FROM public.alternativas WHERE questao_id = 3 AND correta = true) <> 1 OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 3 AND ordem = 1 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: alternativas/gabarito da questão 3 foram alterados indevidamente';
  END IF;
  IF (SELECT count(*) FROM public.alternativas WHERE questao_id = 676) <> 5 OR
     (SELECT count(*) FROM public.alternativas WHERE questao_id = 676 AND correta = true) <> 1 OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = 676 AND ordem = 3 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 4 falhou: alternativas/gabarito da questão 676 foram alterados indevidamente';
  END IF;

  -- Assert 5: ID 3 — enunciado (hash_questao) permanece EXATAMENTE IGUAL (só explicacao mudou)
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 3) <> '${HASH_QUESTAO_3_ANTES}' THEN
    RAISE EXCEPTION 'Assert 5 falhou: hash da questão 3 (enunciado/metadados) foi alterado indevidamente — só a explicação deveria mudar';
  END IF;

  -- Assert 6: ID 676 — explicação (hash_explicacao) permanece EXATAMENTE IGUAL (só enunciado mudou)
  IF (SELECT md5(regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g')) FROM public.questoes WHERE id = 676) <> '${HASH_EXPLICACAO_676_ANTES}' THEN
    RAISE EXCEPTION 'Assert 6 falhou: hash da explicação da questão 676 foi alterado indevidamente — só o enunciado deveria mudar';
  END IF;

  -- Assert 7: ID 3 — explicação nova confere com o hash esperado e não contém mais o
  -- resíduo da "alternativa E" inexistente
  SELECT explicacao INTO v_explicacao_check FROM public.questoes WHERE id = 3;
  IF md5(regexp_replace(v_explicacao_check, E'\\r\\n', E'\\n', 'g')) <> '${HASH_EXPLICACAO_3_DEPOIS}' THEN
    RAISE EXCEPTION 'Assert 7 falhou: hash da explicação pós-correção da questão 3 não confere com o esperado';
  END IF;
  IF v_explicacao_check ILIKE '%ALTERNATIVA E%' THEN
    RAISE EXCEPTION 'Assert 7 falhou: explicação da questão 3 ainda contém referência à alternativa E inexistente';
  END IF;

  -- Assert 8: ID 676 — enunciado novo confere com o hash esperado, contém "é esse" e
  -- não contém mais "éesse"
  SELECT enunciado INTO v_enunciado_check FROM public.questoes WHERE id = 676;
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = 676) <> '${HASH_QUESTAO_676_DEPOIS}' THEN
    RAISE EXCEPTION 'Assert 8 falhou: hash da questão pós-correção da questão 676 não confere com o esperado';
  END IF;
  IF v_enunciado_check NOT ILIKE '%é esse órgão%' OR v_enunciado_check ILIKE '%éesse%' THEN
    RAISE EXCEPTION 'Assert 8 falhou: enunciado da questão 676 ainda contém "éesse" ou não contém "é esse órgão"';
  END IF;

  RAISE NOTICE 'TODOS OS ASSERTS DA FASE 2T-C2 (SANEAMENTO TEXTUAL ID 3 / ID 676) PASSARAM COM SUCESSO!';
END $$;

${mode === 'rollback' ? 'ROLLBACK;' : 'COMMIT;'}`;
}

const harnessSql = body('rollback');
const applySql = body('apply');

fs.writeFileSync(HARNESS_OUT_PATH, harnessSql, 'utf8');
fs.writeFileSync(APPLY_OUT_PATH, applySql, 'utf8');

console.log(`Arquivos gerados com sucesso:`);
console.log(` - ${HARNESS_OUT_PATH}`);
console.log(` - ${APPLY_OUT_PATH}`);
console.log('');
console.log('Hashes pós-correção computados:');
console.log(`  ID 3   hash_explicacao_depois = ${HASH_EXPLICACAO_3_DEPOIS}`);
console.log(`  ID 676 hash_questao_depois    = ${HASH_QUESTAO_676_DEPOIS}`);
