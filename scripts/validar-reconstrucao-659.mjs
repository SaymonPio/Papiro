#!/usr/bin/env node
// Valida a explicacao reconstruida da questao 659 nas mesmas DUAS camadas
// dos demais validadores deste projeto (ex.: validar-le1a-...mjs):
//   1) Fidelidade ao gabarito real do banco (B = correta=true; A, C, D, E
//      = correta=false), a partir de um raw json exportado via MCP.
//   2) A MESMA regra estrutural deterministica de
//      supabase/classificar_explicacoes_questoes.sql.
// So leitura de arquivos locais -- nao escreve nada, nao toca no Supabase.

import { explicacao } from './reconstrucao-659-gravatai.mjs';

const alternativas = [
  { letra: 'A', correta: false },
  { letra: 'B', correta: true },
  { letra: 'C', correta: false },
  { letra: 'D', correta: false },
  { letra: 'E', correta: false },
];

const problemas = [];

const gabaritoMatch = explicacao.match(/GABARITO\s*:\s*alternativa\s+([A-E])/i);
const corretaLetra = alternativas.find(a => a.correta).letra;
if (!gabaritoMatch) problemas.push('sem marcador GABARITO: alternativa X');
else if (gabaritoMatch[1].toUpperCase() !== corretaLetra) {
  problemas.push(`GABARITO diz ${gabaritoMatch[1]} mas o banco marca correta=${corretaLetra}`);
}

const mencionadas = new Map();
const re = /POR QUE A ALTERNATIVA\s+([A-E])\s+EST[ÁA]\s+(CORRETA|INCORRETA)/gi;
let m;
while ((m = re.exec(explicacao))) {
  mencionadas.set(m[1].toUpperCase(), m[2].toUpperCase());
}
const letrasReais = alternativas.map(a => a.letra);
for (const letra of letrasReais) {
  if (!mencionadas.has(letra)) problemas.push(`falta comentario para a alternativa ${letra}`);
}
for (const letra of mencionadas.keys()) {
  if (!letrasReais.includes(letra)) problemas.push(`comenta alternativa ${letra}, que nao existe`);
}
for (const a of alternativas) {
  const status = mencionadas.get(a.letra);
  if (!status) continue;
  const esperado = a.correta ? 'CORRETA' : 'INCORRETA';
  if (status !== esperado) problemas.push(`alternativa ${a.letra} comentada como ${status}, esperado ${esperado}`);
}

if (!/BIZU DE PROVA/i.test(explicacao)) problemas.push('sem BIZU DE PROVA');

const passaClassificadorCanonico =
  /GABARITO\s*:/i.test(explicacao) &&
  /BIZU DE PROVA/i.test(explicacao) &&
  mencionadas.size >= alternativas.length;

console.log('=== Validação da explicação reconstruída — questão 659 ===');
console.log('Gabarito no texto:', gabaritoMatch ? gabaritoMatch[1] : '(nenhum)');
console.log('Alternativas comentadas:', [...mencionadas.entries()].map(([l, s]) => `${l}=${s}`).join(', '));
console.log('Passaria como EXPLICACAO_COMPLETA no classificador canônico?', passaClassificadorCanonico);

if (problemas.length > 0) {
  console.log('\n=== PROBLEMAS ===');
  for (const p of problemas) console.log(' -', p);
  process.exit(1);
} else {
  console.log('\nAPROVADA: gabarito bate com o banco, as 5 alternativas estão comentadas com status correto, BIZU DE PROVA presente, estrutura EXPLICACAO_COMPLETA confirmada.');
}
