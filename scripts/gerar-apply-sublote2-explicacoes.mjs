#!/usr/bin/env node
// Gera a aplicacao real (BEGIN...UPDATE...COMMIT) do SUB-LOTE 2, extraindo
// o corpo (staging + precondicoes + UPDATE) DIRETAMENTE do texto do harness
// ja validado no SQL Editor (supabase/sublote2_lei_maria_penha_explicacoes_
// teste_rollback.sql, resultado confirmado: "Success. No rows returned",
// sem nenhum ERROR) -- em vez de reescrever esse SQL do zero, o que
// arriscaria uma divergencia acidental de texto/comentarios entre o que foi
// validado e o que sera aplicado de verdade. So gera o arquivo -- nao toca
// o Supabase.

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const HARNESS_PATH = path.join(ROOT, 'supabase/sublote2_lei_maria_penha_explicacoes_teste_rollback.sql');
const APPLY_OUT_PATH = path.join(ROOT, 'supabase/sublote2_lei_maria_penha_explicacoes.sql');

const harnessSql = fs.readFileSync(HARNESS_PATH, 'utf8');

const START_MARKER = 'create temporary table _staging_explicacoes (';
const END_MARKER = 'where q.id = s.questao_id;';

const startIdx = harnessSql.indexOf(START_MARKER);
const endMarkerIdx = harnessSql.indexOf(END_MARKER);
if (startIdx === -1 || endMarkerIdx === -1) {
  throw new Error('Nao encontrei os marcadores de inicio/fim do corpo (staging..UPDATE) no harness -- arquivo mudou de formato?');
}
const endIdx = endMarkerIdx + END_MARKER.length;
const body = harnessSql.slice(startIdx, endIdx);

// Sanidade: confirma que o corpo extraido tem exatamente as 38 questoes
// esperadas (nenhuma a mais, nenhuma a menos -- prova que a extracao pegou
// o bloco certo e nao um trecho truncado) e nao inclui 1337/1340.
const idsNoStaging = [...body.matchAll(/^\s*\((\d+),/gm)].map(m => Number(m[1]));
if (idsNoStaging.length !== 38) {
  throw new Error(`Corpo extraido tem ${idsNoStaging.length} linhas de staging, esperado 38`);
}
if (idsNoStaging.includes(1337) || idsNoStaging.includes(1340)) {
  throw new Error('Corpo extraido inclui 1337 ou 1340 -- nao deveria, aplicacao abortada');
}
if (!body.includes("if v_total <> 38 then") || !body.includes('update public.questoes q')) {
  throw new Error('Corpo extraido nao contem as precondicoes/UPDATE esperados -- extracao suspeita');
}

const idsListaSql = idsNoStaging.join(', ');

// Unica alteracao de texto sobre o corpo extraido: o comentario que
// precede o UPDATE, no harness, descreve corretamente aquele contexto
// ("desfeita pelo ROLLBACK final"). Nesta versao (COMMIT), a mesma frase
// ficaria factualmente errada -- e a UNICA linha do corpo que e cosmetica
// o suficiente para trocar sem tocar em SQL executavel. Nenhuma outra
// linha do corpo (staging, precondicoes, UPDATE) e alterada.
const ESCRITA_COMMENT_HARNESS = '-- ESCRITA (dentro da transação de teste — desfeita pelo ROLLBACK final).';
const ESCRITA_COMMENT_APPLY = '-- ESCRITA REAL — única coluna alterada: questoes.explicacao. Persistida pelo COMMIT final.';
if (!body.includes(ESCRITA_COMMENT_HARNESS)) {
  throw new Error('Comentario de ESCRITA esperado nao encontrado no corpo extraido -- harness mudou de formato?');
}
const bodyParaApply = body.replace(ESCRITA_COMMENT_HARNESS, ESCRITA_COMMENT_APPLY);

const applySql = `-- ============================================================================
-- SUB-LOTE 2 — EXPLICAÇÕES PEDAGÓGICAS DA LEI MARIA DA PENHA (38 QUESTÕES)
-- APLICAÇÃO REAL — TERMINA EM COMMIT. Só rodar depois que
-- supabase/sublote2_lei_maria_penha_explicacoes_teste_rollback.sql tiver
-- rodado no SQL Editor com TODOS os asserts passando (confirmado: "Success.
-- No rows returned", sem nenhum ERROR).
-- ============================================================================
--
-- Gerado por scripts/gerar-apply-sublote2-explicacoes.mjs, que EXTRAI o
-- corpo abaixo (staging + precondições + UPDATE) diretamente do texto do
-- harness já validado — byte a byte idêntico ao que foi testado, sem
-- reescrita manual.
--
-- Questões: ${idsListaSql}
-- ids 1337 e 1340 excluídas (PROBLEMATICA/DESATUALIZADA — Tema Repetitivo
-- 1.186/STJ; ver cabeçalho do harness para a documentação completa).
-- Permanecem SEM_EXPLICACAO em produção, não entram no staging abaixo.
--
-- ÚNICA coluna alterada: public.questoes.explicacao. Enunciado,
-- alternativas (texto/correta/ordem), fonte, banca, concurso, materia_id,
-- assunto_id, ativa, e os vínculos em questao_unidades_pedagogicas e
-- curso_questoes permanecem exatamente como estavam.
--
-- MESMO staging, MESMAS 5 precondições revalidadas dentro da própria
-- transação (se o estado do banco mudou desde a validação do harness —
-- outra escrita concorrente, por exemplo — a transação aborta sozinha em
-- vez de gravar algo inconsistente), MESMO UPDATE. Sem tabelas de
-- assert/diagnóstico (isso já foi validado em separado pelo harness).
-- ============================================================================

BEGIN;

${bodyParaApply}

-- Confirma a escrita: 38 questões (id ${idsListaSql}) passam a ter
-- questoes.explicacao preenchida, sem nenhuma outra coluna ou tabela
-- tocada. ids 1337 e 1340 permanecem SEM_EXPLICACAO (não entram no
-- staging acima).
COMMIT;
`;

fs.writeFileSync(APPLY_OUT_PATH, applySql, 'utf8');
console.log(`Gerado: ${path.relative(ROOT, APPLY_OUT_PATH)}`);
console.log(`Corpo extraido do harness ja validado: ${path.relative(ROOT, HARNESS_PATH)}`);
console.log(`Questões: ${idsNoStaging.length} (${idsListaSql})`);
