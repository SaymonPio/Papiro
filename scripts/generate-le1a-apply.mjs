#!/usr/bin/env node
// Deriva supabase/aplicar_le1a_direitos_garantias_fundamentais.sql (APPLY
// REAL, termina em COMMIT) DIRETAMENTE do texto do harness ja validado
// (supabase/aplicar_le1a_direitos_garantias_fundamentais_teste_rollback.sql),
// nao a partir da fonte .mjs de novo -- isso garante, por construcao, que o
// corpo transacional (staging + snapshots + precondicoes + escrita +
// asserts) fica byte-a-byte identico entre harness e apply. So o
// cabecalho/rodape de comentario e a instrucao final (ROLLBACK -> COMMIT)
// mudam.

import fs from 'fs';

const HARNESS_PATH = 'supabase/aplicar_le1a_direitos_garantias_fundamentais_teste_rollback.sql';
const APPLY_PATH = 'supabase/aplicar_le1a_direitos_garantias_fundamentais.sql';

const harnessSql = fs.readFileSync(HARNESS_PATH, 'utf8');

const beginIdx = harnessSql.indexOf('BEGIN;');
if (beginIdx === -1) throw new Error('BEGIN; nao encontrado no harness');

const lastEndMarker = 'end $$;';
const lastEndIdx = harnessSql.lastIndexOf(lastEndMarker);
if (lastEndIdx === -1) throw new Error('end $$; nao encontrado no harness');

const bodyEndIdx = lastEndIdx + lastEndMarker.length;
const body = harnessSql.slice(beginIdx, bodyEndIdx);

if (!body.startsWith('BEGIN;')) throw new Error('corpo extraido nao comeca com BEGIN;');
if (!body.trimEnd().endsWith('end $$;')) throw new Error('corpo extraido nao termina com end $$;');

const header = `-- ============================================================================
-- AUDITORIA GLOBAL -- PRIORIDADE 1 (LEGISLACAO ESPECIFICA) -- LE-1a
-- Aplicacao de 21 explicacoes pedagogicas -- Direitos e Garantias
-- Fundamentais (assunto_id 71, materia_id 10)
-- IDs: 46,112,298,326,657,658,660,661,662,663,723,724,725,726,727,775,797,846,847,848,849
-- APLICACAO REAL -- TERMINA EM COMMIT. So rodar depois que
-- supabase/aplicar_le1a_direitos_garantias_fundamentais_teste_rollback.sql
-- tiver rodado no SQL Editor com TODOS os asserts passando (RESUMO N/N) --
-- confirmado pelo usuario: "Success. No rows returned".
-- Mantem TODOS os mesmos asserts do harness (nao removidos) -- eles rodam
-- de novo aqui, dentro da MESMA transacao que efetivamente persiste, como
-- ultima revalidacao antes do COMMIT.
-- ============================================================================
--
-- Gerado automaticamente por scripts/generate-le1a-apply.mjs DIRETAMENTE a
-- partir do texto do harness ja validado (nao da fonte .mjs de novo) --
-- garante por construcao que o corpo transacional e byte-a-byte identico
-- entre harness e apply. NAO editar este arquivo a mao -- editar a fonte
-- (scripts/le1a-direitos-garantias-fundamentais-explicacoes.mjs), regerar o
-- harness, validar de novo no SQL Editor, e so entao regerar este apply.
--
-- Contexto: primeiro sublote (LE-1a) da Prioridade 1 (Legislacao Especifica)
-- da auditoria global de explicacoes do Papiro. Das 22 questoes do assunto
-- "Direitos e Garantias Fundamentais", 21 foram auditadas juridicamente e
-- classificadas VALIDA. A questao id 659 foi classificada PROBLEMATICA
-- (enunciado truncado/corrompido) e fica INTEIRAMENTE FORA deste apply --
-- nao recebe explicacao, nao e tocada de forma alguma.
--
-- Escopo estrito: altera SOMENTE \`explicacao\` (+ \`atualizado_em\`) para
-- exatamente os 21 ids listados acima. Sem objetos permanentes: apenas
-- CREATE TEMPORARY TABLE ... ON COMMIT DROP e blocos DO $$ ... $$ inline.
--
-- ESTE ARQUIVO TERMINA EM COMMIT. Rodar apenas com role de ESCRITA (nao
-- funciona via MCP read-only).
-- ============================================================================

`;

const footer = `

-- Todos os asserts acima passaram (senao a transacao ja teria abortado por
-- RAISE EXCEPTION) -- confirma a escrita real: as 21 questoes de Direitos e
-- Garantias Fundamentais listadas no cabecalho receberam explicacao
-- pedagogica completa (EXPLICACAO_COMPLETA), enunciado/alternativas/
-- gabarito/materia/assunto/ativa/banca/concurso/ano/fonte preservados, e a
-- questao 659 permanece totalmente intocada.
COMMIT;
`;

const applySql = header + body + footer;
fs.writeFileSync(APPLY_PATH, applySql, 'utf8');
console.log(`Apply gerado: ${APPLY_PATH}`);
console.log(`Corpo extraido do harness: ${body.length} caracteres (BEGIN; ... ultimo end $$;)`);
