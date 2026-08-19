#!/usr/bin/env node
// Deriva supabase/desativar_659_nao_recuperavel.sql (APPLY REAL, termina em
// COMMIT) DIRETAMENTE do texto do harness ja validado
// (supabase/desativar_659_nao_recuperavel_teste_rollback.sql), nao de uma
// fonte separada -- isso garante, por construcao, que o corpo transacional
// (snapshots + precondicoes + escrita + asserts) fica byte-a-byte identico
// entre harness e apply. So o cabecalho/rodape de comentario e a instrucao
// final (ROLLBACK -> COMMIT) mudam. Mesmo padrao de
// scripts/generate-le1a-apply.mjs.

import fs from 'fs';

const HARNESS_PATH = 'supabase/desativar_659_nao_recuperavel_teste_rollback.sql';
const APPLY_PATH = 'supabase/desativar_659_nao_recuperavel.sql';

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
-- DESATIVACAO DE QUESTAO PROBLEMATICA -- NAO_RECUPERAVEL / FONTE_NAO_CONFIRMADA
-- ID 659 -- Direitos e Garantias Fundamentais (assunto_id 71, materia_id 10)
-- APLICACAO REAL -- TERMINA EM COMMIT. So rodar depois que
-- supabase/desativar_659_nao_recuperavel_teste_rollback.sql tiver rodado no
-- SQL Editor com TODOS os asserts passando (RESUMO N/N) -- confirmado pelo
-- usuario: "Success. No rows returned".
-- Mantem TODOS os mesmos asserts do harness (nao removidos) -- eles rodam
-- de novo aqui, dentro da MESMA transacao que efetivamente persiste, como
-- ultima revalidacao antes do COMMIT.
-- ============================================================================
--
-- Gerado automaticamente por scripts/generate-desativar-659-apply.mjs
-- DIRETAMENTE a partir do texto do harness ja validado -- garante por
-- construcao que o corpo transacional e byte-a-byte identico entre harness
-- e apply. NAO editar este arquivo a mao -- editar
-- supabase/desativar_659_nao_recuperavel_teste_rollback.sql, validar de
-- novo no SQL Editor, e so entao regerar este apply.
--
-- Contexto: a questao 659 tem registro real de banca/concurso "FUNDATEC —
-- GM (Pref Gravataí)/Pref Gravataí/2026" -- confirmado no proprio banco e
-- preservado sem alteracao por este apply. No momento da decisao de
-- desativar (2026-08-18), o enunciado estava truncado/corrompido e a
-- alternativa A tinha fragmento de numeracao duplicado. Uma investigacao
-- externa anterior, feita por engano contra o concurso errado ("GM
-- Araquari/2026", nao o real "GM Gravataí/2026"), NAO fundamenta esta
-- decisao -- foi descartada por nao ter checado a prova certa.
-- Classificacao operacional definida pelo usuario: PROBLEMATICA —
-- NAO_RECUPERAVEL / FONTE_NAO_CONFIRMADA. Decisao de produto: nao
-- reconstruir o enunciado, nao alterar
-- alternativas/gabarito/banca/concurso/ano/fonte, nao escrever explicacao
-- -- apenas desativar (ativa = false), preservando todo o historico
-- integralmente.
--
-- ATUALIZACAO (2026-08-18, apos a desativacao ja aplicada): uma nova
-- investigacao, desta vez contra o concurso correto (GM Gravataí/2026),
-- localizou a prova oficial e o gabarito definitivo da FUNDATEC
-- (fundatec.org.br, concurso 1021) e confirmou a Questão 48 dessa prova
-- como a fonte real: enunciado e alternativas C/D/E batem integralmente
-- com o banco, e o gabarito oficial (B) confere com o gabarito ja marcado
-- no banco -- sem divergencia. A alternativa A e o corte do enunciado tem
-- explicacao: residuo de formatacao do PDF original ("garantido(a) o(a)"
-- colado com o marcador de lista da alternativa A). Classificacao
-- corrigida para RECUPERAVEL_COM_FONTE_OFICIAL. Esta atualizacao e apenas
-- documentacao -- nenhuma correcao de texto nem reativacao foi executada a
-- partir daqui; fica para uma decisao e harness futuros, separados deste.
--
-- Escopo estrito: altera SOMENTE \`ativa\` (+ \`atualizado_em\`) para
-- exatamente o id 659. Sem objetos permanentes: apenas CREATE TEMPORARY
-- TABLE ... ON COMMIT DROP e blocos DO $$ ... $$ inline.
--
-- ESTE ARQUIVO TERMINA EM COMMIT. Rodar apenas com role de ESCRITA (nao
-- funciona via MCP read-only).
-- ============================================================================

`;

const footer = `

-- Todos os asserts acima passaram (senao a transacao ja teria abortado por
-- RAISE EXCEPTION) -- confirma a escrita real: questao 659 desativada
-- (ativa=false), enunciado/alternativas/gabarito/banca/concurso/ano/fonte/
-- materia/assunto/explicacao preservados integralmente, nenhuma outra
-- questao tocada, assunto 71 com 21/21 EXPLICACAO_COMPLETA, contagens
-- globais batendo (908 ativas, 316 completas, 592 pendencias).
COMMIT;
`;

const applySql = header + body + footer;
fs.writeFileSync(APPLY_PATH, applySql, 'utf8');
console.log(`Apply gerado: ${APPLY_PATH}`);
console.log(`Corpo extraido do harness: ${body.length} caracteres (BEGIN; ... ultimo end $$;)`);
