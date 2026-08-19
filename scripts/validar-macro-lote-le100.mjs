#!/usr/bin/env node
// Validador Canônico do Macro-Lote de Legislação Específica (100 questões)
// Validação canônica estrita baseada em supabase/classificar_explicacoes_questoes.sql

import fs from 'fs';
import { explicacoes } from './macro-lote-le100-explicacoes.mjs';

const rawPath = 'C:/Users/User/.gemini/antigravity-cli/brain/2d2b6ae7-2a46-4595-b47e-5eefca5d453a/scratch/macro-lote-le100-raw.json';
const raw = JSON.parse(fs.readFileSync(rawPath, 'utf8'));

console.log(`Iniciando validação de ${explicacoes.length} explicações do Macro-Lote de Legislação Específica (100 questões)...`);

if (explicacoes.length !== 100) {
  console.error(`❌ ERRO: Esperado 100 explicações, encontrado ${explicacoes.length}`);
  process.exit(1);
}

const mapRaw = new Map();
raw.forEach(q => mapRaw.set(q.id, q));

const letters = ['A', 'B', 'C', 'D', 'E'];
let erros = 0;

explicacoes.forEach((item, index) => {
  const q = mapRaw.get(item.id);
  if (!q) {
    console.error(`[ID ${item.id}] Não encontrado no RAW!`);
    erros++;
    return;
  }

  const exp = item.explicacao;
  const n_alt = q.alternativas.length;
  const correctIndex = q.alternativas.findIndex(a => a.correta);
  const correctLetter = letters[correctIndex];

  // 1. Gabarito
  const matchGab = exp.match(/GABARITO:\s*alternativa\s+([A-E])/i);
  if (!matchGab) {
    console.error(`[ID ${item.id}] Linha GABARITO não encontrada ou formato inválido.`);
    erros++;
  } else if (matchGab[1].toUpperCase() !== correctLetter) {
    console.error(`[ID ${item.id}] GABARITO divergente! RAW: ${correctLetter}, Explicação: ${matchGab[1].toUpperCase()}`);
    erros++;
  }

  // 2. Bizu de Prova
  if (!exp.includes('BIZU DE PROVA:')) {
    console.error(`[ID ${item.id}] Seção BIZU DE PROVA não encontrada.`);
    erros++;
  }

  // 3. Justificativa da correta
  const matchCorreta = exp.match(new RegExp(`POR QUE A ALTERNATIVA ${correctLetter} ESTÁ CORRETA:`, 'i'));
  if (!matchCorreta) {
    console.error(`[ID ${item.id}] Justificativa da alternativa correta (${correctLetter}) não encontrada.`);
    erros++;
  }

  // 4. Justificativa das incorretas
  for (let i = 0; i < n_alt; i++) {
    const l = letters[i];
    if (l !== correctLetter) {
      const matchInc = exp.match(new RegExp(`POR QUE A ALTERNATIVA ${l} ESTÁ INCORRETA:`, 'i'));
      if (!matchInc) {
        console.error(`[ID ${item.id}] Justificativa da alternativa incorreta (${l}) não encontrada.`);
        erros++;
      }
    }
  }

  // 5. Total de seções de alternativas
  const matches = [...exp.matchAll(/POR QUE A ALTERNATIVA\s+([A-E])\s+EST[ÁA]\s+(CORRETA|INCORRETA)/gi)];
  const distinctLetters = new Set(matches.map(m => m[1].toUpperCase()));
  if (distinctLetters.size < n_alt) {
    console.error(`[ID ${item.id}] Menções de alternativas insuficientes: ${distinctLetters.size} de ${n_alt}`);
    erros++;
  }
});

if (erros > 0) {
  console.error(`❌ FALHA: Foram encontrados ${erros} erros na validação.`);
  process.exit(1);
} else {
  console.log(`✅ SUCESSO: Todas as 100 explicações do Macro-Lote de Legislação Específica foram validadas com 100% de conformidade canônica!`);
}
