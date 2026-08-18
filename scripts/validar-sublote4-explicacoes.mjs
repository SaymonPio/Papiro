#!/usr/bin/env node
// Mesma validação de duas camadas dos sub-lotes anteriores (ver
// scripts/validar-sublote1-explicacoes.mjs), aplicada ao sub-lote 4.

import fs from 'fs';
import { explicacoes } from './sublote4-lei-maria-penha-explicacoes.mjs';

const RAW_PATH = 'C:/Users/User/AppData/Local/Temp/claude/C--Users-User-Desktop-Papiro-corrigido-Papiro-com/05fe1ce8-5b6b-4a87-bae9-e09d32a28036/scratchpad/lote1_sublote4_raw.json';
const raw = JSON.parse(fs.readFileSync(RAW_PATH, 'utf8'));
const porId = new Map(raw.map(q => [q.id, q]));
const LETRAS = 'ABCDE';

let falhas = 0;
const relatorio = [];

// Confirma que nao ha ID duplicado no array-fonte (o proprio erro de
// contagem que motivou a reconciliacao anterior).
const idsVistos = new Set();
for (const { id } of explicacoes) {
  if (idsVistos.has(id)) {
    console.error(`FALHA: id ${id} aparece mais de uma vez no array-fonte`);
    falhas++;
  }
  idsVistos.add(id);
}
if (idsVistos.size !== 31) {
  console.error(`FALHA: array-fonte tem ${idsVistos.size} ids unicos, esperado 31`);
  falhas++;
}
if ([...idsVistos].includes(738)) {
  console.error('FALHA: id 738 nao deveria estar neste sub-lote (PROBLEMATICA/FUNDAMENTO INCERTO)');
  falhas++;
}

for (const { id, explicacao } of explicacoes) {
  const q = porId.get(id);
  if (!q) { console.error(`FALHA ${id}: nao encontrada no raw json`); falhas++; continue; }

  const nAlt = q.alternativas.length;
  const ehCE = nAlt === 2 && q.alternativas.every(a => ['certo', 'errado'].includes(a.texto.trim().toLowerCase()));
  const problemas = [];

  if (ehCE) {
    const corretaTexto = q.alternativas.find(a => a.correta).texto.trim().toUpperCase();
    const gabaritoMatch = explicacao.match(/GABARITO\s*:\s*(CERTO|ERRADO)/i);
    if (!gabaritoMatch) problemas.push('sem marcador GABARITO: CERTO/ERRADO');
    else if (gabaritoMatch[1].toUpperCase() !== corretaTexto.toUpperCase()) {
      problemas.push(`GABARITO diz ${gabaritoMatch[1]} mas o banco marca correta=${corretaTexto}`);
    }
    if (!/POR QUE\s*:/i.test(explicacao)) problemas.push('sem marcador POR QUE:');
    if (!/BIZU DE PROVA/i.test(explicacao)) problemas.push('sem BIZU DE PROVA');
  } else {
    const corretas = q.alternativas.filter(a => a.correta);
    if (corretas.length !== 1) {
      problemas.push(`questao tem ${corretas.length} alternativas corretas, esperado exatamente 1 (gabarito ambiguo -- nao deveria estar neste sub-lote)`);
    }
    const corretaOrdem = corretas[0]?.ordem;
    const letraCorreta = corretaOrdem ? LETRAS[corretaOrdem - 1] : null;
    const gabaritoMatch = explicacao.match(/GABARITO\s*:\s*alternativa\s+([A-E])/i);
    if (!gabaritoMatch) problemas.push('sem marcador GABARITO: alternativa X');
    else if (letraCorreta && gabaritoMatch[1].toUpperCase() !== letraCorreta) {
      problemas.push(`GABARITO diz ${gabaritoMatch[1]} mas o banco marca correta=${letraCorreta} (ordem ${corretaOrdem})`);
    }
    if (!/BIZU DE PROVA/i.test(explicacao)) problemas.push('sem BIZU DE PROVA');

    const mencionadas = new Set();
    const statusPorLetra = new Map();
    const re = /POR QUE A ALTERNATIVA\s+([A-E])\s+EST[ÁA]\s+(CORRETA|INCORRETA)/gi;
    let m;
    while ((m = re.exec(explicacao))) {
      const letra = m[1].toUpperCase();
      mencionadas.add(letra);
      statusPorLetra.set(letra, m[2].toUpperCase());
    }
    const letrasReais = q.alternativas.map(a => LETRAS[a.ordem - 1]);
    for (const letra of letrasReais) {
      if (!mencionadas.has(letra)) problemas.push(`falta comentario para a alternativa ${letra} (existe no banco)`);
    }
    for (const letra of mencionadas) {
      if (!letrasReais.includes(letra)) problemas.push(`comenta alternativa ${letra}, que NAO existe nesta questao (so tem ${letrasReais.join(',')})`);
    }
    for (const letra of letrasReais) {
      const status = statusPorLetra.get(letra);
      if (!status) continue;
      const esperado = letra === letraCorreta ? 'CORRETA' : 'INCORRETA';
      if (status !== esperado) problemas.push(`alternativa ${letra} comentada como ${status}, esperado ${esperado}`);
    }
  }

  if (problemas.length > 0) {
    falhas++;
    relatorio.push({ id, ehCE, problemas });
  } else {
    relatorio.push({ id, ehCE, problemas: [] });
  }
}

// Confirma reaproveitamento identico nos 3 pares.
const porIdExpl = new Map(explicacoes.map(e => [e.id, e.explicacao]));
const pares = [[129, 864], [133, 865], [134, 863]];
for (const [a, b] of pares) {
  if (porIdExpl.get(a) !== porIdExpl.get(b)) {
    console.error(`FALHA: explicacao de ${a} e ${b} deveriam ser identicas (par duplicado) e nao sao`);
    falhas++;
  }
}

console.log(`Total processado: ${explicacoes.length}`);
console.log(`Aprovadas: ${explicacoes.length - falhas >= 0 ? explicacoes.length - relatorio.filter(r => r.problemas.length > 0).length : 'N/A'}`);
console.log(`Reprovadas: ${relatorio.filter(r => r.problemas.length > 0).length}`);
if (falhas > 0) {
  console.log('\n=== FALHAS ===');
  for (const r of relatorio.filter(r => r.problemas.length > 0)) {
    console.log(`  questao ${r.id}: ${r.problemas.join(' | ')}`);
  }
  process.exit(1);
} else {
  console.log(`\nTodas as ${explicacoes.length} aprovadas: gabarito bate com o banco, todas as alternativas comentadas, estrutura completa, pares 129/864, 133/865 e 134/863 idênticos, 738 confirmado ausente.`);
}
