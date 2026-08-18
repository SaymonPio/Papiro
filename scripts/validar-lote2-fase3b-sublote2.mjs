#!/usr/bin/env node
// LOTE 2 — FASE 3B — SUB-LOTE 2: validação estrutural das 38 explicações.
// Mesmo esquema de validação do sub-lote 1 (ver validar-lote2-fase3b-
// sublote1.mjs): fonte de verdade é fase3b_sublote2_conteudo.json.

import fs from 'fs';
import { explicacoes } from './lote2-fase3b-sublote2-explicacoes.mjs';

const SCRATCH = 'C:/Users/User/AppData/Local/Temp/claude/C--Users-User-Desktop-Papiro-corrigido-Papiro-com/05fe1ce8-5b6b-4a87-bae9-e09d32a28036/scratchpad';
const sublote = JSON.parse(fs.readFileSync(`${SCRATCH}/fase3b_sublote2_conteudo.json`, 'utf8'));
const porTecId = new Map(sublote.map(q => [q.tecId, q]));
const LETRAS = 'ABCDE';

let falhas = 0;
const relatorio = [];

// --- Reconciliação de IDs -----------------------------------------------
const idsExplicacoes = explicacoes.map(e => e.tecId);
const idsUnicos = new Set(idsExplicacoes);
console.log('=== Reconciliação de IDs ===');
console.log('Registros no sub-lote 2 (fonte):', sublote.length, '(esperado 38)');
console.log('Explicações escritas:', explicacoes.length, '(esperado 38)');
console.log('tecIds únicos nas explicações:', idsUnicos.size, '(esperado 38)');
if (idsExplicacoes.length !== idsUnicos.size) {
  console.error('FALHA: ha tecId duplicado no array de explicacoes');
  falhas++;
}
const idsSublote = new Set(sublote.map(q => q.tecId));
const faltandoExplicacao = [...idsSublote].filter(id => !idsUnicos.has(id));
const sobrandoExplicacao = [...idsUnicos].filter(id => !idsSublote.has(id));
console.log('Questoes do sub-lote sem explicacao:', faltandoExplicacao.length, JSON.stringify(faltandoExplicacao));
console.log('Explicacoes sem questao correspondente no sub-lote:', sobrandoExplicacao.length, JSON.stringify(sobrandoExplicacao));
if (faltandoExplicacao.length > 0 || sobrandoExplicacao.length > 0) falhas++;

// --- Cobertura estrutural -------------------------------------------------
for (const { tecId, cadernoNumero, explicacao } of explicacoes) {
  const q = porTecId.get(tecId);
  if (!q) { console.error(`FALHA ${tecId}: nao encontrada em fase3b_sublote2_conteudo.json`); falhas++; continue; }
  if (q.cadernoNumero !== cadernoNumero) {
    console.error(`FALHA ${tecId}: cadernoNumero divergente (explicacao diz ${cadernoNumero}, fonte diz ${q.cadernoNumero})`);
    falhas++;
  }

  const nAlt = q.alternativas.length;
  const ehCE = nAlt === 2 && q.alternativas.every(a => ['certo', 'errado'].includes(a.trim().toLowerCase()));
  const problemas = [];

  if (ehCE) {
    const gabaritoMatch = explicacao.match(/GABARITO\s*:\s*(CERTO|ERRADO)/i);
    if (!gabaritoMatch) problemas.push('sem marcador GABARITO: CERTO/ERRADO');
    else if (gabaritoMatch[1].toUpperCase() !== q.gabarito.toUpperCase()) {
      problemas.push(`GABARITO diz ${gabaritoMatch[1]} mas a fonte marca gabarito=${q.gabarito}`);
    }
    if (!/POR QUE\s*:/i.test(explicacao)) problemas.push('sem marcador POR QUE:');
    if (!/BIZU DE PROVA/i.test(explicacao)) problemas.push('sem BIZU DE PROVA');
    if (!/PEGADINHA/i.test(explicacao)) problemas.push('sem PEGADINHA (recomendado para C/E)');
  } else {
    const letraCorreta = q.gabarito.trim().toUpperCase();
    const gabaritoMatch = explicacao.match(/GABARITO\s*:\s*alternativa\s+([A-E])/i);
    if (!gabaritoMatch) problemas.push('sem marcador GABARITO: alternativa X');
    else if (gabaritoMatch[1].toUpperCase() !== letraCorreta) {
      problemas.push(`GABARITO diz ${gabaritoMatch[1]} mas a fonte marca gabarito=${letraCorreta}`);
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
    const letrasReais = q.alternativas.map((_, i) => LETRAS[i]);
    for (const letra of letrasReais) {
      if (!mencionadas.has(letra)) problemas.push(`falta comentario para a alternativa ${letra} (existe na fonte)`);
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
    relatorio.push({ tecId, cadernoNumero, ehCE, problemas });
  } else {
    relatorio.push({ tecId, cadernoNumero, ehCE, problemas: [] });
  }
}

console.log('\n=== Cobertura estrutural ===');
console.log(`Total processado: ${explicacoes.length}`);
console.log(`Aprovadas: ${relatorio.filter(r => r.problemas.length === 0).length}`);
console.log(`Reprovadas: ${relatorio.filter(r => r.problemas.length > 0).length}`);
if (relatorio.some(r => r.problemas.length > 0)) {
  console.log('\n=== FALHAS ===');
  for (const r of relatorio.filter(r => r.problemas.length > 0)) {
    console.log(`  caderno ${r.cadernoNumero} (tecId ${r.tecId}): ${r.problemas.join(' | ')}`);
  }
}

// --- Contagem de VALIDA_COM_RESSALVA -------------------------------------
const comRessalva = sublote.filter(q => q.classificacao_final === 'VALIDA_COM_RESSALVA').map(q => q.cadernoNumero);
console.log('\n=== VALIDA_COM_RESSALVA no sub-lote 2 ===');
console.log('Cadernos:', JSON.stringify(comRessalva), `(${comRessalva.length} no total -- inclui a 309, upgrade desta rodada)`);

if (falhas > 0) {
  console.log(`\n${falhas} FALHA(S) DETECTADA(S).`);
  process.exit(1);
} else {
  console.log(`\nTodas as ${explicacoes.length} aprovadas: gabarito bate com a fonte, todas as alternativas comentadas, estrutura completa, ${explicacoes.length}/${sublote.length} reconciliados sem falta nem sobra.`);
}
