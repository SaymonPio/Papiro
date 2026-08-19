#!/usr/bin/env node
// Validador de conformidade canônica das 100 explicações do Macro-Lote 100

import fs from 'fs';
import { explicacoes } from './macro-lote100-explicacoes.mjs';

const raw = JSON.parse(fs.readFileSync('C:/Users/User/.gemini/antigravity-cli/brain/2d2b6ae7-2a46-4595-b47e-5eefca5d453a/scratch/macro-lote100-raw.json', 'utf8'));

const LETRAS = ['A', 'B', 'C', 'D', 'E'];
const GABARITOS = {};
const IDS_ESPERADOS = [];

for (const q of raw) {
  IDS_ESPERADOS.push(q.id);
  const cIndex = q.alternativas.findIndex(a => a.correta);
  GABARITOS[q.id] = {
    correta: LETRAS[cIndex],
    totalAlt: q.alternativas.length
  };
}

let falhas = 0;
console.log(`Iniciando validação de ${explicacoes.length} explicações do Macro-Lote 100...`);

if (explicacoes.length !== 100) {
  console.error(`FALHA: esperado 100 explicações, encontrado ${explicacoes.length}`);
  falhas++;
}

const idsEncontrados = new Set();
for (const item of explicacoes) {
  const { id, explicacao } = item;
  if (!IDS_ESPERADOS.includes(id)) {
    console.error(`FALHA id ${id}: não pertence ao conjunto de IDs esperados`);
    falhas++;
  }
  if (idsEncontrados.has(id)) {
    console.error(`FALHA id ${id}: ID duplicado`);
    falhas++;
  }
  idsEncontrados.add(id);

  const gabEsperado = GABARITOS[id];
  if (!gabEsperado) {
    console.error(`FALHA id ${id}: sem configuração de gabarito`);
    falhas++;
    continue;
  }

  // 1) Gabarito anunciado
  const matchGabarito = explicacao.match(/GABARITO:\s*alternativa\s+([A-E])/i);
  if (!matchGabarito) {
    console.error(`FALHA id ${id}: formato de GABARITO inválido`);
    falhas++;
  } else if (matchGabarito[1].toUpperCase() !== gabEsperado.correta) {
    console.error(`FALHA id ${id}: gabarito anunciado (${matchGabarito[1]}) difere do esperado (${gabEsperado.correta})`);
    falhas++;
  }

  // 2) Bizu de prova
  if (!/BIZU DE PROVA:/i.test(explicacao)) {
    console.error(`FALHA id ${id}: falta seção BIZU DE PROVA`);
    falhas++;
  }

  // 3) Justificativa da correta
  const regexCorreta = new RegExp(`POR QUE A ALTERNATIVA ${gabEsperado.correta} ESTÁ CORRETA:`, 'i');
  if (!regexCorreta.test(explicacao)) {
    console.error(`FALHA id ${id}: falta seção 'POR QUE A ALTERNATIVA ${gabEsperado.correta} ESTÁ CORRETA'`);
    falhas++;
  }

  // 4) Justificativa das incorretas
  const letrasValidas = LETRAS.slice(0, gabEsperado.totalAlt);
  for (const letra of letrasValidas) {
    if (letra === gabEsperado.correta) continue;
    const regexIncorreta = new RegExp(`POR QUE A ALTERNATIVA ${letra} ESTÁ INCORRETA:`, 'i');
    if (!regexIncorreta.test(explicacao)) {
      console.error(`FALHA id ${id}: falta seção 'POR QUE A ALTERNATIVA ${letra} ESTÁ INCORRETA'`);
      falhas++;
    }
  }

  // 5) Menções canônicas de alternativas
  const totalMencoes = (explicacao.match(/POR QUE A ALTERNATIVA\s+[A-E]\s+EST[ÁA]\s+(CORRETA|INCORRETA)/gi) || []).length;
  if (totalMencoes < gabEsperado.totalAlt) {
    console.error(`FALHA id ${id}: total de menções (${totalMencoes}) menor que o número de alternativas (${gabEsperado.totalAlt})`);
    falhas++;
  }
}

if (falhas === 0) {
  console.log(`✅ SUCESSO: Todas as 100 explicações do Macro-Lote 100 foram validadas com 100% de conformidade canônica!`);
} else {
  console.error(`❌ Total de falhas encontradas: ${falhas}`);
  process.exit(1);
}
