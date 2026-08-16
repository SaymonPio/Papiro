#!/usr/bin/env node
// Deterministic Camada A/B/C deduplication of Lote 1 (86 questoes da Lei
// Maria da Penha, TEC Concursos) against a snapshot of the real Supabase
// `questoes` table. Read-only by design: never writes to the database or to
// the Lote 1 CSV, only classifies and reports.
//
// Usage:
//   node scripts/dedupe-lote1-vs-supabase.js <banco_snapshot.json>
//
// <banco_snapshot.json> must be an array of rows shaped like:
//   { id, fonte, enunciado, alternativas }
// pulled live via MCP (mcp__supabase__execute_sql) for the relevant
// assunto/conteudo before running this script -- this script does not talk
// to Supabase itself, it only compares two local snapshots so the
// comparison logic is auditable and reproducible run to run.
//
// Camada A: TEC ID exact match against the "fonte" free-text field
//   (pattern: "TEC Concursos — questão <ID> — ...").
// Camada B: enunciado normalizado exato (accent/case/whitespace-insensitive)
//   AND alternativas compatíveis (a text-identical "stub" enunciado with
//   totally different alternativas is NOT treated as the same question).
// Camada C: near-duplicate by Jaccard similarity over enunciado+alternativas
//   combined, threshold 0.35 -- flagged for manual review, NEVER
//   auto-resolved to JA_EXISTE.

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

function parseCsv(str) {
  const rows = [];
  let row = [], field = '', inQuotes = false;
  for (let i = 0; i < str.length; i++) {
    const c = str[i];
    if (inQuotes) {
      if (c === '"') { if (str[i + 1] === '"') { field += '"'; i++; } else inQuotes = false; }
      else field += c;
    } else {
      if (c === '"') inQuotes = true;
      else if (c === ',') { row.push(field); field = ''; }
      else if (c === '\r' && str[i + 1] === '\n') { row.push(field); rows.push(row); row = []; field = ''; i++; }
      else if (c === '\n') { row.push(field); rows.push(row); row = []; field = ''; }
      else field += c;
    }
  }
  if (field.length || row.length) { row.push(field); rows.push(row); }
  return rows.filter(r => !(r.length === 1 && r[0] === ''));
}

function loadCsv(filePath) {
  const rows = parseCsv(fs.readFileSync(filePath, 'utf8'));
  const header = rows[0];
  return rows.slice(1).map(r => Object.fromEntries(header.map((h, i) => [h, r[i]])));
}

function normalize(s) {
  return (s || '')
    .toLowerCase()
    .normalize('NFD').replace(/[̀-ͯ]/g, '') // strip accents
    .replace(/[^a-z0-9 ]+/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

function jaccard(a, b) {
  const setA = new Set(normalize(a).split(' ').filter(Boolean));
  const setB = new Set(normalize(b).split(' ').filter(Boolean));
  if (setA.size === 0 || setB.size === 0) return 0;
  let inter = 0;
  for (const w of setA) if (setB.has(w)) inter++;
  const union = setA.size + setB.size - inter;
  return union === 0 ? 0 : inter / union;
}

function extractTecIdFromFonte(fonte) {
  if (!fonte) return null;
  const m = fonte.match(/quest[aã]o\s+(\d{4,8})/i) || fonte.match(/questoes\/(\d{4,8})/i);
  return m ? m[1] : null;
}

const SIMILARITY_THRESHOLD = 0.35;

function classify(lote1Row, bancoRows, bancoByTecId) {
  const tecId = lote1Row.tec_id;
  const enunciado = lote1Row.enunciado;
  const alternativas = lote1Row.alternativas || '';

  // Caderno 999 is excluded from Lote 1 by definition (no confirmable
  // metadata against the PDF) -- guard here too in case it leaks in.
  if (lote1Row.caderno_numero === '999') {
    return { status: 'PROBLEMATICA', motivo: 'caderno 999 excluido do Lote 1 por falta de metadados confirmaveis no PDF', match: null };
  }

  // Camada A: TEC ID exact match.
  if (bancoByTecId.has(tecId)) {
    const match = bancoByTecId.get(tecId);
    return { status: 'JA_EXISTE', motivo: `Camada A: TEC ID ${tecId} ja registrado em fonte (questoes.id=${match.id})`, match };
  }

  // Camada B: enunciado normalizado exato + alternativas compativeis.
  const normEnun = normalize(enunciado);
  for (const row of bancoRows) {
    if (normalize(row.enunciado) === normEnun) {
      const altSim = jaccard(alternativas, row.alternativas || '');
      if (altSim >= 0.6) {
        return { status: 'JA_EXISTE', motivo: `Camada B: enunciado identico e alternativas compativeis (questoes.id=${row.id})`, match: row };
      }
      // Same enunciado "stub" but different alternativas: NOT the same
      // question, do not short-circuit -- fall through to Camada C.
    }
  }

  // Camada C: near-duplicate por similaridade combinada, nunca resolvido
  // automaticamente.
  let best = null;
  for (const row of bancoRows) {
    const combinedLote1 = enunciado + ' ' + alternativas;
    const combinedBanco = (row.enunciado || '') + ' ' + (row.alternativas || '');
    const sim = jaccard(combinedLote1, combinedBanco);
    if (sim >= SIMILARITY_THRESHOLD && (!best || sim > best.sim)) best = { row, sim };
  }
  if (best) {
    return {
      status: 'NEAR_DUPLICATE_REVISAR',
      motivo: `Camada C: similaridade Jaccard ${best.sim.toFixed(2)} com questoes.id=${best.row.id} -- requer leitura manual completa antes de decidir NOVA vs. JA_EXISTE`,
      match: best.row,
    };
  }

  return { status: 'NOVA_CONFIRMADA', motivo: 'Nenhum match em TEC ID, enunciado exato ou similaridade >= 0.35', match: null };
}

function main() {
  const snapshotPath = process.argv[2];
  if (!snapshotPath) {
    console.error('Uso: node scripts/dedupe-lote1-vs-supabase.js <banco_snapshot.json>');
    console.error('O snapshot precisa ser gerado antes, via MCP (execute_sql), com um SELECT');
    console.error('read-only em public.questoes para o assunto/conteudo da Lei Maria da Penha.');
    process.exit(1);
  }

  const lote1Path = path.join(__dirname, '..', 'supabase', 'lote_1_importacao_lei_maria_penha_tec.csv');
  const lote1 = loadCsv(lote1Path);
  const bancoRows = JSON.parse(fs.readFileSync(snapshotPath, 'utf8'));
  const bancoByTecId = new Map();
  for (const row of bancoRows) {
    const tecId = extractTecIdFromFonte(row.fonte);
    if (tecId) bancoByTecId.set(tecId, row);
  }

  const results = lote1.map(row => ({ ...row, ...classify(row, bancoRows, bancoByTecId) }));

  const counts = { NOVA_CONFIRMADA: 0, JA_EXISTE: 0, NEAR_DUPLICATE_REVISAR: 0, PROBLEMATICA: 0 };
  results.forEach(r => counts[r.status]++);

  console.log('=== Classificacao Lote 1 (Camadas A/B/C) ===');
  console.log(`Total de linhas no CSV (inclui 999): ${lote1.length}`);
  console.log(`Total classificado (exclui 999): ${lote1.length - (counts.PROBLEMATICA > 0 ? results.filter(r => r.caderno_numero === '999').length : 0)}`);
  console.log(counts);
  console.log(`Soma: ${Object.values(counts).reduce((a, b) => a + b, 0)} (esperado: 87, sendo 86 utilizaveis + 1 caderno 999)`);
  console.log();
  results.forEach(r => {
    console.log(`${r.caderno_numero}\t${r.tec_id}\t${r.status}\t${r.motivo}`);
  });

  const outPath = path.join(__dirname, '..', 'supabase', 'lote_1_classificacao_supabase.json');
  fs.writeFileSync(outPath, JSON.stringify(results, null, 2));
  console.log(`\nResultado detalhado salvo em ${outPath}`);
}

main();
