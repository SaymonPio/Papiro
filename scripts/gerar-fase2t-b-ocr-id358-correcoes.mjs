#!/usr/bin/env node
// Fase 2T-B — Saneamento estrutural/OCR da questão ID 358 (Atos administrativos):
// remoção de quebra de linha (LF) residual de importação de PDF, presente no meio da
// frase em todas as 5 alternativas da questão, mais correção de um espaço espúrio antes
// de hífen ("respeitar -se" -> "respeitar-se") na alternativa de ordem 5. Correção
// deliberadamente mínima: nenhuma palavra, pontuação ou conteúdo jurídico foi reescrito —
// apenas o caractere de quebra de linha foi eliminado (preservando o espaço que já existia
// antes dele) e o espaço espúrio antes do hífen foi removido na alternativa 5.
//
// Escopo exclusivo: public.alternativas.texto das 5 alternativas da questão 358
// (alt_id 1767-1771). Nenhuma outra coluna de `alternativas`, nenhuma coluna de
// `questoes` (enunciado, explicacao, ativa, materia_id, assunto_id) e nenhuma outra
// tabela são tocadas. O gabarito (alt_id 1767 / ordem 1) permanece inalterado.
//
// Referência (Fase 2T-B, microanálise estrutural + pré-check já entregues nesta sessão):
//   Defeito confirmado como quebra de linha residual de importação de PDF em colunas de
//   largura fixa (mesmo padrão observado em outras questões da mesma prova — Fundatec CBMRS
//   Soldado de Primeira Classe 2025 —, registradas como candidatas a lote OCR futuro: 336,
//   342, 348, 349, 351, 352, 353, 357, 367, 370 — fora do escopo desta fase).

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const HARNESS_OUT_PATH = path.join(ROOT, 'supabase/fase2t-b_ocr_id358_correcoes_teste_rollback.sql');
const APPLY_OUT_PATH = path.join(ROOT, 'supabase/fase2t-b_ocr_id358_correcoes.sql');

function sqlStr(s) {
  return `'${String(s).replace(/'/g, "''")}'`;
}

const QUESTAO_ID = 358;

// Hashes da questão 358 (nível public.questoes) — não incluem o texto das alternativas,
// portanto devem permanecer EXATAMENTE IGUAIS antes e depois desta correção.
const HASH_QUESTAO_358 = 'd611777f82de1ff74e95dfdad03dd254';
const HASH_EXPLICACAO_358 = '273a9827fbf14eec3710507434412db1';

// Hashes (md5) do texto ATUAL de cada alternativa, capturados ao vivo do banco de produção
// antes desta migração (Fase 2T-B, pré-check reconfirmado sem drift).
const HASH_TEXTO_ANTES = {
  1767: '730239911c4f1c2a6b1ac301ba4a5238',
  1768: '89716adbba5b76b3b384cab43f43a8f3',
  1769: 'ae1099ad6ed1f8d75984f2852c416982',
  1770: 'cdd0a8d9d017897cd2e1a13d7ebaae82',
  1771: 'be10579e1371a4af2474abe0c4e162b8',
};

// Hashes (md5) do texto NOVO (pós-correção) de cada alternativa — usados como asserts pós.
const HASH_TEXTO_DEPOIS = {
  1767: '9b2ef1d9d2c500d8c63ca2338ebcfc01',
  1768: '76ddd9be6d24e6d4ff316ac4eb6396bd',
  1769: '968a16fac95136d2fa2d4b485a840c90',
  1770: '50c41ffaba10430a07a40c7e018c18b3',
  1771: '371b5efcf4043f5fba6704e6197ce15b',
};

const ORDEM = { 1767: 1, 1768: 2, 1769: 3, 1770: 4, 1771: 5 };
const CORRETA = { 1767: true, 1768: false, 1769: false, 1770: false, 1771: false };

// --------------------------------------------------------------------------
// Textos novos das alternativas (LF residual removido; alt 1771 também com o
// espaço espúrio antes do hífen corrigido: "respeitar -se" -> "respeitar-se")
// --------------------------------------------------------------------------

const TEXTO_NOVO = {
  1767: 'Segundo a presunção de legitimidade, o ato administrativo é considerado válido, até prova em sentido contrário.',
  1768: 'O atributo da imperatividade significa que o ato administrativo pode criar bilateralmente obrigações aos particulares, com sua anuência.',
  1769: 'A exigibilidade consiste no atributo que permite à Administração aplicar punições aos particulares por violação da ordem jurídica, com a necessária intervenção judicial.',
  1770: 'A autoexecutoriedade permite que a Administração Pública realize a execução material dos atos administrativos ou de dispositivos legais, usando a força física se preciso for para desconstituir situação violadora da ordem jurídica, exclusivamente quando autorizada pelo Poder Judiciário.',
  1771: 'A exequibilidade diz respeito à necessidade de respeitar-se a finalidade específica definida na lei para cada espécie de ato administrativo.',
};

// --------------------------------------------------------------------------

function body(mode) {
  return `-- ============================================================================
-- FASE 2T-B — SANEAMENTO OCR DA QUESTÃO ID 358 (ATOS ADMINISTRATIVOS)
-- Remoção de LF residual em 5 alternativas + correção de espaço espúrio (ordem 5)
-- Modo: ${mode === 'rollback' ? 'TESTE COM ROLLBACK OBRIGATÓRIO' : 'APPLY DEFINITIVO COM COMMIT'}
-- ============================================================================

BEGIN;

SET TRANSACTION READ WRITE;

DO $$
DECLARE
  v_total_questoes integer;
  v_total_ativas integer;
  v_total_inativas integer;
  v_texto_check text;
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

  -- Precondição: hash da questão 358 (não inclui texto de alternativas — deve
  -- permanecer inalterado antes e depois desta migração)
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = ${QUESTAO_ID}) <> '${HASH_QUESTAO_358}' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da questão ${QUESTAO_ID} divergiu do estado auditado.';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g')) FROM public.questoes WHERE id = ${QUESTAO_ID}) <> '${HASH_EXPLICACAO_358}' THEN
    RAISE EXCEPTION 'Precondição falhou: hash da explicação da questão ${QUESTAO_ID} divergiu do estado auditado.';
  END IF;

  -- Precondição: questão 358 ativa, com 5 alternativas e exatamente 1 correta na ordem 1
  IF NOT EXISTS (SELECT 1 FROM public.questoes WHERE id = ${QUESTAO_ID} AND ativa = true) THEN
    RAISE EXCEPTION 'Precondição falhou: questão ${QUESTAO_ID} não está ativa.';
  END IF;
  IF (SELECT count(*) FROM public.alternativas WHERE questao_id = ${QUESTAO_ID}) <> 5 OR
     (SELECT count(*) FROM public.alternativas WHERE questao_id = ${QUESTAO_ID} AND correta = true) <> 1 OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE questao_id = ${QUESTAO_ID} AND ordem = 1 AND correta = true) THEN
    RAISE EXCEPTION 'Precondição falhou: estrutura de alternativas da questão ${QUESTAO_ID} divergente do esperado (5 alternativas, 1 correta na ordem 1).';
  END IF;

  -- Precondição: cada alternativa com id, questao_id, ordem, correta e hash do texto exatos
${Object.entries(HASH_TEXTO_ANTES).map(([id, hash]) => `  IF NOT EXISTS (
    SELECT 1 FROM public.alternativas
     WHERE id = ${id} AND questao_id = ${QUESTAO_ID} AND ordem = ${ORDEM[id]} AND correta = ${CORRETA[id]}
       AND md5(texto) = '${hash}'
  ) THEN
    RAISE EXCEPTION 'Precondição falhou: alternativa ${id} (ordem ${ORDEM[id]}) divergiu do estado auditado (id/questao_id/ordem/correta/hash do texto).';
  END IF;`).join('\n')}

  -- --------------------------------------------------------------------------
  -- 2. ATUALIZAÇÕES DO ESCOPO (5 ALTERNATIVAS) — SOMENTE O CAMPO TEXTO
  -- --------------------------------------------------------------------------

${Object.entries(TEXTO_NOVO).map(([id, texto]) => `  UPDATE public.alternativas SET texto = ${sqlStr(texto)} WHERE id = ${id};`).join('\n')}

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

  -- Assert 2: hash da questão 358 e da explicação permanecem EXATAMENTE IGUAIS
  -- (prova de que nada em public.questoes foi tocado)
  IF (SELECT md5(enunciado || '|' || coalesce(fonte,'') || '|' || coalesce(banca,'') || '|' || coalesce(concurso,'') || '|' || materia_id::text || '|' || coalesce(assunto_id::text,'') || '|' || ativa::text) FROM public.questoes WHERE id = ${QUESTAO_ID}) <> '${HASH_QUESTAO_358}' THEN
    RAISE EXCEPTION 'Assert 2 falhou: hash da questão ${QUESTAO_ID} foi alterado indevidamente — esta migração não deveria tocar public.questoes';
  END IF;
  IF (SELECT md5(regexp_replace(explicacao, E'\\r\\n', E'\\n', 'g')) FROM public.questoes WHERE id = ${QUESTAO_ID}) <> '${HASH_EXPLICACAO_358}' THEN
    RAISE EXCEPTION 'Assert 2 falhou: hash da explicação da questão ${QUESTAO_ID} foi alterado indevidamente — esta migração não deveria tocar public.questoes';
  END IF;

  -- Assert 3: questão 358 continua ativa, com 5 alternativas, 1 correta, na ordem 1
  IF NOT EXISTS (SELECT 1 FROM public.questoes WHERE id = ${QUESTAO_ID} AND ativa = true) THEN
    RAISE EXCEPTION 'Assert 3 falhou: questão ${QUESTAO_ID} não está mais ativa';
  END IF;
  IF (SELECT count(*) FROM public.alternativas WHERE questao_id = ${QUESTAO_ID}) <> 5 OR
     (SELECT count(*) FROM public.alternativas WHERE questao_id = ${QUESTAO_ID} AND correta = true) <> 1 OR
     NOT EXISTS (SELECT 1 FROM public.alternativas WHERE id = 1767 AND questao_id = ${QUESTAO_ID} AND ordem = 1 AND correta = true) THEN
    RAISE EXCEPTION 'Assert 3 falhou: estrutura de alternativas da questão ${QUESTAO_ID} divergente do esperado após a correção';
  END IF;

  -- Assert 4: ordem, questao_id e correta preservados em cada alternativa (nada além do texto mudou)
${Object.entries(ORDEM).map(([id, ordem]) => `  IF NOT EXISTS (SELECT 1 FROM public.alternativas WHERE id = ${id} AND questao_id = ${QUESTAO_ID} AND ordem = ${ordem} AND correta = ${CORRETA[id]}) THEN
    RAISE EXCEPTION 'Assert 4 falhou: alternativa ${id} teve ordem, questao_id ou correta alterados indevidamente';
  END IF;`).join('\n')}

  -- Assert 5: hash do texto NOVO de cada alternativa confere com o esperado
${Object.entries(HASH_TEXTO_DEPOIS).map(([id, hash]) => `  IF (SELECT md5(texto) FROM public.alternativas WHERE id = ${id}) <> '${hash}' THEN
    RAISE EXCEPTION 'Assert 5 falhou: hash do texto pós-correção da alternativa ${id} não confere com o esperado';
  END IF;`).join('\n')}

  -- Assert 6: nenhuma das 5 alternativas contém LF ou CR residual no texto
  IF EXISTS (
    SELECT 1 FROM public.alternativas
     WHERE id IN (1767, 1768, 1769, 1770, 1771)
       AND (texto ~ E'\\n' OR texto ~ E'\\r')
  ) THEN
    RAISE EXCEPTION 'Assert 6 falhou: ao menos uma alternativa ainda contém caractere de quebra de linha (LF/CR) residual';
  END IF;

  -- Assert 7: alternativa 1771 não contém mais "respeitar -se" e passa a conter "respeitar-se"
  SELECT texto INTO v_texto_check FROM public.alternativas WHERE id = 1771;
  IF v_texto_check ILIKE '%respeitar -se%' OR v_texto_check NOT ILIKE '%respeitar-se%' THEN
    RAISE EXCEPTION 'Assert 7 falhou: alternativa 1771 ainda contém o espaço espúrio antes do hífen ou não contém "respeitar-se"';
  END IF;

  RAISE NOTICE 'TODOS OS ASSERTS DA FASE 2T-B (SANEAMENTO OCR ID 358) PASSARAM COM SUCESSO!';
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
