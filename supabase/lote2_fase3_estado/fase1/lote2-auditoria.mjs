#!/usr/bin/env node
// FASE 1 - AUDITORIA DO LOTE 2 (leitura/analise local apenas -- nao toca o Supabase)
// Le o inventario de 722 candidatas + 42 problemas, deduplica internamente,
// compara com as 117 questoes de Lei Maria da Penha ja existentes no banco
// (fingerprints extraidos via MCP/SQL, nunca transcritos a mao), e classifica
// cada candidata em NOVA_VALIDA / JA_EXISTE / DUPLICADA_NO_LOTE / PROBLEMATICA /
// DESATUALIZADA / DADOS_INSUFICIENTES.

import fs from 'fs';
import crypto from 'crypto';

const ROOT = 'C:/Users/User/Desktop/Papiro-corrigido/Papiro.com';
const SCRATCH = 'C:/Users/User/AppData/Local/Temp/claude/C--Users-User-Desktop-Papiro-corrigido-Papiro-com/05fe1ce8-5b6b-4a87-bae9-e09d32a28036/scratchpad';

const inventario = JSON.parse(fs.readFileSync(`${ROOT}/supabase/inventario_lei_maria_penha_tec_pdfs_v2.json`, 'utf8'));
const existentes = JSON.parse(fs.readFileSync(`${SCRATCH}/lote2_fingerprints_existentes.json`, 'utf8'));

const { questoes, problemas } = inventario;

// Mesma normalizacao usada na query SQL:
// md5(lower(regexp_replace(trim(enunciado), '\s+', ' ', 'g')))
function fingerprint(enunciado) {
  const norm = enunciado.trim().replace(/\s+/g, ' ').toLowerCase();
  return crypto.createHash('md5').update(norm, 'utf8').digest('hex');
}

const existentesSet = new Set(existentes.map(e => e.fingerprint));
const existentesPorFingerprint = new Map(existentes.map(e => [e.fingerprint, e]));

// --- Deteccao de contaminacao (footer/header/proxima questao vazando na
// ultima alternativa) -- mesmos padroes de assinatura ja identificados.
const CONTAMINACAO_PATTERNS = [
  /tecconcursos\.com\.br\/questoes/i,
  /Caderno Lei Maria da Penha/i,
  /\d{2}\/\d{2}\/\d{4},\s*\d{2}:\d{2}/,
  /QUEST[ÕO]ES/,
  /Ordena[çc][ãa]o:/i,
];
function temContaminacao(q) {
  // Varre enunciado + TODAS as alternativas -- o rodape/cabecalho do PDF pode
  // vazar tanto na ultima alternativa quanto no meio do enunciado (achado da
  // auditoria: 87 dos 119 casos reais vazam fora da ultima alternativa).
  const textoCompleto = q.enunciado + ' ' + q.alternativas.join(' ');
  return CONTAMINACAO_PATTERNS.some(re => re.test(textoCompleto));
}

// --- Validacao estrutural basica ---
function gabaritoValido(q) {
  if (q.gabarito == null) return false;
  const n = q.alternativas.length;
  if (q.gabarito === 'Certo' || q.gabarito === 'Errado') return n === 2;
  const idx = q.gabarito.charCodeAt(0) - 'A'.charCodeAt(0);
  return idx >= 0 && idx < n;
}
function alternativasNormais(q) {
  const n = q.alternativas.length;
  if (q.gabarito === 'Certo' || q.gabarito === 'Errado') return n === 2;
  return n === 4 || n === 5;
}
function temAlternativaVazia(q) {
  return q.alternativas.some(a => !a || a.trim().length === 0);
}

// --- Passo 1: computa fingerprint + flags estruturais para cada candidata ---
const enriched = questoes.map(q => ({
  ...q,
  fingerprint: fingerprint(q.enunciado),
  contaminada: temContaminacao(q),
  gabaritoValido: gabaritoValido(q),
  altNormal: alternativasNormais(q),
  altVazia: temAlternativaVazia(q),
}));

// --- Passo 2: duplicatas internas (mesmo fingerprint dentro do proprio lote) ---
const porFingerprint = new Map();
for (const q of enriched) {
  if (!porFingerprint.has(q.fingerprint)) porFingerprint.set(q.fingerprint, []);
  porFingerprint.get(q.fingerprint).push(q);
}
const gruposDuplicados = [...porFingerprint.values()].filter(g => g.length > 1);
const totalDuplicadasInternas = gruposDuplicados.reduce((acc, g) => acc + (g.length - 1), 0);

// --- Passo 3: classificacao final ---
const classificadas = [];
const vistosNoLote = new Set(); // fingerprints ja "aceitos" como representante de um grupo

for (const q of enriched) {
  let categoria;
  const motivos = [];

  const jaExiste = existentesSet.has(q.fingerprint);
  const duplicadaNoLote = porFingerprint.get(q.fingerprint).length > 1;
  const problemaEstrutural = q.contaminada || !q.gabaritoValido || !q.altNormal || q.altVazia;

  if (jaExiste) {
    categoria = 'JA_EXISTE';
    const ex = existentesPorFingerprint.get(q.fingerprint);
    motivos.push(`fingerprint identico ao id existente ${ex.id}`);
  } else if (problemaEstrutural) {
    categoria = 'DADOS_INSUFICIENTES';
    if (q.contaminada) motivos.push('ultima alternativa contaminada por rodape/cabecalho/proxima questao');
    if (!q.gabaritoValido) motivos.push('gabarito ausente ou fora do range de alternativas');
    if (!q.altNormal) motivos.push(`numero atipico de alternativas (${q.alternativas.length})`);
    if (q.altVazia) motivos.push('alternativa vazia');
  } else if (duplicadaNoLote) {
    if (!vistosNoLote.has(q.fingerprint)) {
      vistosNoLote.add(q.fingerprint);
      categoria = 'NOVA_VALIDA';
      motivos.push('primeira ocorrencia do grupo de duplicatas internas -- representante mantido');
    } else {
      categoria = 'DUPLICADA_NO_LOTE';
      motivos.push('fingerprint repetido dentro do proprio Lote 2');
    }
  } else {
    categoria = 'NOVA_VALIDA';
  }

  classificadas.push({ ...q, categoria, motivos });
}

// --- Passo 4: distribuicao por categoria ---
const distCategoria = {};
for (const q of classificadas) distCategoria[q.categoria] = (distCategoria[q.categoria] || 0) + 1;

// --- Passo 5: distribuicao por banca / concurso / ano (sobre o total de 722) ---
const distBanca = {};
const distAno = {};
for (const q of questoes) {
  distBanca[q.banca] = (distBanca[q.banca] || 0) + 1;
  const anoKey = q.ano ?? 'sem_ano';
  distAno[anoKey] = (distAno[anoKey] || 0) + 1;
}

// --- Passo 6: NOVA_VALIDA final -- estas sao as candidatas realmente novas e
// estruturalmente ok, pendentes apenas da revisao juridica (item 7) ---
const novasValidas = classificadas.filter(q => q.categoria === 'NOVA_VALIDA');

// --- saida ---
console.log('='.repeat(80));
console.log('LOTE 2 -- AUDITORIA FASE 1');
console.log('='.repeat(80));
console.log(`\nTotal de candidatas no inventario (questoes[]): ${questoes.length}`);
console.log(`Total em problemas[] (parser ja auto-sinalizou como nao aproveitavel): ${problemas.length}`);
console.log(`\n-- Duplicatas internas --`);
console.log(`Grupos com fingerprint repetido: ${gruposDuplicados.length}`);
console.log(`Total de linhas excedentes (duplicatas alem da 1a ocorrencia): ${totalDuplicadasInternas}`);

console.log(`\n-- Classificacao final (${classificadas.length} candidatas) --`);
for (const [cat, n] of Object.entries(distCategoria).sort((a, b) => b[1] - a[1])) {
  console.log(`  ${cat}: ${n}`);
}

console.log(`\n-- Distribuicao por banca (top 15 de ${Object.keys(distBanca).length}) --`);
for (const [banca, n] of Object.entries(distBanca).sort((a, b) => b[1] - a[1]).slice(0, 15)) {
  console.log(`  ${banca}: ${n}`);
}

console.log(`\n-- Distribuicao por ano --`);
for (const [ano, n] of Object.entries(distAno).sort((a, b) => String(a[0]).localeCompare(String(b[0])))) {
  console.log(`  ${ano}: ${n}`);
}

console.log(`\n-- Candidatas NOVA_VALIDA (estruturalmente ok, pendente revisao juridica): ${novasValidas.length} --`);

// Grava outputs para inspecao detalhada sem re-transcrever nada a mao
fs.writeFileSync(`${SCRATCH}/lote2_classificacao_completa.json`, JSON.stringify(classificadas.map(q => ({
  cadernoNumero: q.cadernoNumero, tecId: q.tecId, banca: q.banca, concurso: q.concurso, ano: q.ano,
  categoria: q.categoria, motivos: q.motivos, fingerprint: q.fingerprint,
  n_alternativas: q.alternativas.length, gabarito: q.gabarito,
})), null, 2), 'utf8');

fs.writeFileSync(`${SCRATCH}/lote2_novas_validas.json`, JSON.stringify(novasValidas, null, 2), 'utf8');

console.log(`\nArquivos gravados:`);
console.log(`  ${SCRATCH}/lote2_classificacao_completa.json (722 linhas, metadados+categoria)`);
console.log(`  ${SCRATCH}/lote2_novas_validas.json (conteudo completo das NOVA_VALIDA, p/ revisao juridica)`);
