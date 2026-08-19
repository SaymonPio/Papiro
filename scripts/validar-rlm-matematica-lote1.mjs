#!/usr/bin/env node
// Valida as 38 explicações do Lote 1 de RLM e Matemática (materia_id 12 e 18)
// em conformidade com as regras do classificador canônico.

import { explicacoes } from './rlm-matematica-lote1-explicacoes.mjs';

const IDS_ESPERADOS = [
  14, 25, 26, 27, 74, 75, 76, 77, 78,
  79, 80, 81, 82, 83, 84, 85, 86, 87,
  88, 89, 90, 246, 247, 248, 285, 286, 287,
  288, 289, 290, 309, 310, 311, 312, 313, 314,
  315, 337
];

const GABARITOS = {
  14: { correta: 'A', totalAlt: 4 },
  25: { correta: 'A', totalAlt: 5 },
  26: { correta: 'A', totalAlt: 5 },
  27: { correta: 'A', totalAlt: 5 },
  74: { correta: 'D', totalAlt: 5 },
  75: { correta: 'C', totalAlt: 5 },
  76: { correta: 'B', totalAlt: 5 },
  77: { correta: 'A', totalAlt: 5 },
  78: { correta: 'B', totalAlt: 5 },
  79: { correta: 'E', totalAlt: 5 },
  80: { correta: 'D', totalAlt: 5 },
  81: { correta: 'C', totalAlt: 5 },
  82: { correta: 'C', totalAlt: 5 },
  83: { correta: 'A', totalAlt: 5 },
  84: { correta: 'C', totalAlt: 5 },
  85: { correta: 'E', totalAlt: 5 },
  86: { correta: 'B', totalAlt: 5 },
  87: { correta: 'E', totalAlt: 5 },
  88: { correta: 'B', totalAlt: 5 },
  89: { correta: 'D', totalAlt: 5 },
  90: { correta: 'D', totalAlt: 5 },
  246: { correta: 'D', totalAlt: 5 },
  247: { correta: 'A', totalAlt: 5 },
  248: { correta: 'A', totalAlt: 5 },
  285: { correta: 'A', totalAlt: 5 },
  286: { correta: 'A', totalAlt: 5 },
  287: { correta: 'A', totalAlt: 5 },
  288: { correta: 'A', totalAlt: 5 },
  289: { correta: 'A', totalAlt: 5 },
  290: { correta: 'A', totalAlt: 5 },
  309: { correta: 'A', totalAlt: 5 },
  310: { correta: 'A', totalAlt: 5 },
  311: { correta: 'A', totalAlt: 5 },
  312: { correta: 'A', totalAlt: 5 },
  313: { correta: 'A', totalAlt: 5 },
  314: { correta: 'A', totalAlt: 5 },
  315: { correta: 'A', totalAlt: 5 },
  337: { correta: 'B', totalAlt: 5 }
};

const LETRAS = ['A', 'B', 'C', 'D', 'E'];
let falhas = 0;

console.log(`Iniciando validação de ${explicacoes.length} explicações do Lote 1 de RLM e Matemática...`);

if (explicacoes.length !== 38) {
  console.error(`FALHA: esperado 38 explicações, encontrado ${explicacoes.length}`);
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
  console.log(`✅ SUCESSO: Todas as 38 explicações foram validadas com 100% de conformidade canônica!`);
} else {
  console.error(`❌ Total de falhas encontradas: ${falhas}`);
  process.exit(1);
}
