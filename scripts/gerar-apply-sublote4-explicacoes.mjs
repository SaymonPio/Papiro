#!/usr/bin/env node
// Gera a aplicacao real (BEGIN...UPDATE...COMMIT) do SUB-LOTE 4, extraindo
// o corpo (staging + precondicoes + ESCRITA) DIRETAMENTE do texto do
// harness ja validado no SQL Editor (supabase/sublote4_lei_maria_penha_
// explicacoes_teste_rollback.sql, resultado confirmado: "Success. No rows
// returned", sem nenhum ERROR) -- em vez de reescrever esse SQL do zero, o
// que arriscaria uma divergencia acidental de texto entre o que foi
// validado e o que sera aplicado de verdade (mesma tecnica usada nos
// sub-lotes 2 e 3). So gera o arquivo -- nao toca o Supabase.
//
// Diferenca em relacao a extracao dos sub-lotes 2/3: o bloco ESCRITA do
// sub-lote 4 e um `do $$ ... end $$;` (UPDATE + GET DIAGNOSTICS + checagem
// de linhas afetadas), nao um UPDATE solto -- por isso o marcador de fim
// da extracao precisa cobrir o bloco inteiro, nao so a clausula WHERE do
// UPDATE.

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const HARNESS_PATH = path.join(ROOT, 'supabase/sublote4_lei_maria_penha_explicacoes_teste_rollback.sql');
const APPLY_OUT_PATH = path.join(ROOT, 'supabase/sublote4_lei_maria_penha_explicacoes.sql');

const harnessSql = fs.readFileSync(HARNESS_PATH, 'utf8');

const START_MARKER = 'create temporary table _staging_explicacoes (';
const END_MARKER = `  if v_linhas_afetadas <> 31 then
    raise exception 'UPDATE afetou % linha(s), esperado exatamente 31 -- abortando', v_linhas_afetadas;
  end if;
end $$;`;

const startIdx = harnessSql.indexOf(START_MARKER);
const endMarkerIdx = harnessSql.indexOf(END_MARKER);
if (startIdx === -1 || endMarkerIdx === -1) {
  throw new Error('Nao encontrei os marcadores de inicio/fim do corpo (staging..ESCRITA) no harness -- arquivo mudou de formato?');
}
const endIdx = endMarkerIdx + END_MARKER.length;
const body = harnessSql.slice(startIdx, endIdx);

// Sanidade: confirma que o corpo extraido tem exatamente as 31 questoes
// esperadas, nao inclui 738, e contem a regra exata de composicao
// (28 ativas + 3 inativas) e o UPDATE com GET DIAGNOSTICS.
const idsNoStaging = [...body.matchAll(/^\s*\((\d+),/gm)].map(m => Number(m[1]));
if (idsNoStaging.length !== 31) {
  throw new Error(`Corpo extraido tem ${idsNoStaging.length} linhas de staging, esperado 31`);
}
if (idsNoStaging.includes(738)) {
  throw new Error('Corpo extraido inclui 738 -- nao deveria, aplicacao abortada');
}
if (!body.includes('esperado exatamente 28 questoes ATIVAS') || !body.includes('esperado exatamente 3 questoes INATIVAS')) {
  throw new Error('Corpo extraido nao contem a regra de composicao 28 ativas + 3 inativas -- extracao suspeita');
}
if (!body.includes('as 3 inativas devem ser exatamente 863, 864, 865')) {
  throw new Error('Corpo extraido nao contem a checagem nomeada de 863/864/865 -- extracao suspeita');
}
if (!body.includes('update public.questoes q') || !body.includes('get diagnostics v_linhas_afetadas = row_count')) {
  throw new Error('Corpo extraido nao contem o UPDATE/GET DIAGNOSTICS esperados -- extracao suspeita');
}

const idsListaSql = idsNoStaging.join(', ');

// Unica alteracao de texto sobre o corpo extraido: o comentario que
// precede o bloco ESCRITA, no harness, descreve corretamente aquele
// contexto ("desfeita pelo ROLLBACK final"). Nesta versao (COMMIT), a
// mesma frase ficaria factualmente errada -- e a UNICA linha do corpo que
// e cosmetica o suficiente para trocar sem tocar em SQL executavel.
// Nenhuma outra linha do corpo (staging, precondicoes, UPDATE, GET
// DIAGNOSTICS) e alterada.
const ESCRITA_COMMENT_HARNESS = '-- ESCRITA (dentro da transação de teste — desfeita pelo ROLLBACK final).';
const ESCRITA_COMMENT_APPLY = '-- ESCRITA REAL — única coluna alterada: questoes.explicacao. Persistida pelo COMMIT final.';
if (!body.includes(ESCRITA_COMMENT_HARNESS)) {
  throw new Error('Comentario de ESCRITA esperado nao encontrado no corpo extraido -- harness mudou de formato?');
}
const bodyParaApply = body.replace(ESCRITA_COMMENT_HARNESS, ESCRITA_COMMENT_APPLY);

const applySql = `-- ============================================================================
-- SUB-LOTE 4 — EXPLICAÇÕES PEDAGÓGICAS DA LEI MARIA DA PENHA (31 QUESTÕES)
-- APLICAÇÃO REAL — TERMINA EM COMMIT. Só rodar depois que
-- supabase/sublote4_lei_maria_penha_explicacoes_teste_rollback.sql tiver
-- rodado no SQL Editor com TODOS os asserts passando (confirmado: "Success.
-- No rows returned", sem nenhum ERROR).
-- ============================================================================
--
-- Gerado por scripts/gerar-apply-sublote4-explicacoes.mjs, que EXTRAI o
-- corpo abaixo (staging + precondições + ESCRITA) diretamente do texto do
-- harness já validado — byte a byte idêntico ao que foi testado, sem
-- reescrita manual.
--
-- Questões: ${idsListaSql}
-- 31 questões de Lei Maria da Penha já existentes no banco, fora do Lote 1
-- de importação, que estavam classificadas EXPLICACAO_INCOMPLETA. id 738
-- excluído (PROBLEMATICA/FUNDAMENTO INCERTO), não entra nesta aplicação.
--
-- Composição exigida (precondição preservada do harness): exatamente 28
-- questões ATIVAS + exatamente 3 INATIVAS, e essas 3 têm que ser
-- especificamente 863, 864 e 865 (gêmeas idênticas de 134, 129 e 133,
-- respectivamente). O UPDATE não altera o campo ativa de nenhuma das 31 —
-- 863/864/865 continuam inativas depois da aplicação real, só o texto de
-- explicação muda.
--
-- ÚNICA coluna alterada: public.questoes.explicacao. Enunciado,
-- alternativas (texto/correta/ordem), fonte, banca, concurso, materia_id,
-- assunto_id, ativa, e os vínculos em questao_unidades_pedagogicas e
-- curso_questoes permanecem exatamente como estavam.
--
-- MESMO staging, MESMAS precondições (31 questões, sem 738, composição
-- exata 28+3) revalidadas dentro da própria transação (se o estado do
-- banco mudou desde a validação do harness — outra escrita concorrente,
-- por exemplo — a transação aborta sozinha em vez de gravar algo
-- inconsistente), MESMO UPDATE com MESMA checagem de GET DIAGNOSTICS.
-- Sem tabelas de assert/diagnóstico adicionais (isso já foi validado em
-- separado pelo harness).
-- ============================================================================

BEGIN;

${bodyParaApply}

-- Confirma a escrita: 31 questões (id ${idsListaSql}) passam a ter
-- questoes.explicacao no padrão pedagógico completo, sem nenhuma outra
-- coluna ou tabela tocada. 863, 864 e 865 permanecem ativa=false.
COMMIT;
`;

fs.writeFileSync(APPLY_OUT_PATH, applySql, 'utf8');
console.log(`Gerado: ${path.relative(ROOT, APPLY_OUT_PATH)}`);
console.log(`Corpo extraido do harness ja validado: ${path.relative(ROOT, HARNESS_PATH)}`);
console.log(`Questões: ${idsNoStaging.length} (${idsListaSql})`);
