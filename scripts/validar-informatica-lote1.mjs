#!/usr/bin/env node
// Valida as 50 explicações do Lote 1 de Informática (materia_id 9)
// em conformidade com as regras do classificador canônico.

import { explicacoes } from './informatica-lote1-explicacoes.mjs';

const IDS_ESPERADOS = [
  11, 15, 31, 32, 33, 60, 61, 62, 63, 64,
  91, 92, 93, 94, 95, 96, 97, 98, 99, 100,
  101, 102, 103, 104, 105, 106, 107, 108, 109, 110,
  294, 338, 339, 340, 341, 492, 493, 494, 495, 496,
  497, 498, 499, 626, 627, 628, 629, 630, 631, 632
];

const GABARITOS = {
  11: { correta: 'A', totalAlt: 4 },
  15: { correta: 'A', totalAlt: 4 },
  31: { correta: 'A', totalAlt: 5 },
  32: { correta: 'A', totalAlt: 5 },
  33: { correta: 'A', totalAlt: 5 },
  60: { correta: 'E', totalAlt: 5 },
  61: { correta: 'C', totalAlt: 5 },
  62: { correta: 'B', totalAlt: 5 },
  63: { correta: 'A', totalAlt: 5 },
  64: { correta: 'D', totalAlt: 5 },
  91: { correta: 'C', totalAlt: 5 },
  92: { correta: 'B', totalAlt: 5 },
  93: { correta: 'C', totalAlt: 5 },
  94: { correta: 'A', totalAlt: 5 },
  95: { correta: 'E', totalAlt: 5 },
  96: { correta: 'E', totalAlt: 5 },
  97: { correta: 'C', totalAlt: 5 },
  98: { correta: 'B', totalAlt: 5 },
  99: { correta: 'E', totalAlt: 5 },
  100: { correta: 'C', totalAlt: 5 },
  101: { correta: 'B', totalAlt: 5 },
  102: { correta: 'D', totalAlt: 5 },
  103: { correta: 'A', totalAlt: 5 },
  104: { correta: 'D', totalAlt: 5 },
  105: { correta: 'D', totalAlt: 5 },
  106: { correta: 'C', totalAlt: 5 },
  107: { correta: 'C', totalAlt: 5 },
  108: { correta: 'E', totalAlt: 5 },
  109: { correta: 'B', totalAlt: 5 },
  110: { correta: 'A', totalAlt: 5 },
  294: { correta: 'A', totalAlt: 5 },
  338: { correta: 'C', totalAlt: 5 },
  339: { correta: 'A', totalAlt: 5 },
  340: { correta: 'B', totalAlt: 5 },
  341: { correta: 'E', totalAlt: 5 },
  492: { correta: 'B', totalAlt: 5 },
  493: { correta: 'A', totalAlt: 5 },
  494: { correta: 'B', totalAlt: 5 },
  495: { correta: 'D', totalAlt: 5 },
  496: { correta: 'E', totalAlt: 5 },
  497: { correta: 'D', totalAlt: 5 },
  498: { correta: 'B', totalAlt: 5 },
  499: { correta: 'D', totalAlt: 5 },
  626: { correta: 'D', totalAlt: 5 },
  627: { correta: 'D', totalAlt: 5 },
  628: { correta: 'B', totalAlt: 5 },
  629: { correta: 'A', totalAlt: 5 },
  630: { correta: 'E', totalAlt: 5 },
  631: { correta: 'B', totalAlt: 5 },
  632: { correta: 'A', totalAlt: 5 }
};

const LETRAS = ['A', 'B', 'C', 'D', 'E'];
let falhas = 0;

console.log(`Iniciando validação de ${explicacoes.length} explicações do Lote 1 de Informática...`);

if (explicacoes.length !== 50) {
  console.error(`FALHA: esperado 50 explicações, encontrado ${explicacoes.length}`);
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
  console.log(`✅ SUCESSO: Todas as 50 explicações foram validadas com 100% de conformidade canônica!`);
} else {
  console.error(`❌ Total de falhas encontradas: ${falhas}`);
  process.exit(1);
}
