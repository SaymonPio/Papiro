#!/usr/bin/env node
// Valida as 50 explicações do Lote 1 de Língua Portuguesa (materia_id 6)
// em DUAS camadas independentes:
//
// 1) Confere integridade estrutural (GABARITO, justificativa por alternativa, BIZU DE PROVA).
// 2) Confere que cada alternativa da questão tem sua seção correspondente.
// 3) Confere que todos os 50 IDs esperados estão presentes sem duplicatas.

import { explicacoes } from './portugues-lote1-explicacoes.mjs';

const IDS_ESPERADOS = [
  6, 16, 17, 18, 34, 65, 66, 67, 68, 69, 70, 71, 72, 73, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123,
  216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241
];

// Dados dos gabaritos esperados (conferidos via MCP read-only no banco)
const GABARITOS = {
  6: { correta: 'A', totalAlt: 4 },
  16: { correta: 'A', totalAlt: 4 },
  17: { correta: 'A', totalAlt: 5 },
  18: { correta: 'A', totalAlt: 5 },
  34: { correta: 'C', totalAlt: 4 },
  65: { correta: 'C', totalAlt: 5 },
  66: { correta: 'E', totalAlt: 5 },
  67: { correta: 'B', totalAlt: 5 },
  68: { correta: 'C', totalAlt: 5 },
  69: { correta: 'C', totalAlt: 5 },
  70: { correta: 'D', totalAlt: 5 },
  71: { correta: 'E', totalAlt: 5 },
  72: { correta: 'A', totalAlt: 5 },
  73: { correta: 'A', totalAlt: 5 },
  114: { correta: 'C', totalAlt: 5 },
  115: { correta: 'A', totalAlt: 5 },
  116: { correta: 'E', totalAlt: 5 },
  117: { correta: 'D', totalAlt: 5 },
  118: { correta: 'A', totalAlt: 5 },
  119: { correta: 'A', totalAlt: 5 },
  120: { correta: 'A', totalAlt: 5 },
  121: { correta: 'B', totalAlt: 5 },
  122: { correta: 'D', totalAlt: 5 },
  123: { correta: 'A', totalAlt: 5 },
  216: { correta: 'A', totalAlt: 5 },
  217: { correta: 'A', totalAlt: 5 },
  218: { correta: 'A', totalAlt: 5 },
  219: { correta: 'A', totalAlt: 5 },
  220: { correta: 'A', totalAlt: 5 },
  221: { correta: 'A', totalAlt: 5 },
  222: { correta: 'A', totalAlt: 5 },
  223: { correta: 'A', totalAlt: 5 },
  224: { correta: 'A', totalAlt: 5 },
  225: { correta: 'A', totalAlt: 5 },
  226: { correta: 'A', totalAlt: 5 },
  227: { correta: 'A', totalAlt: 5 },
  228: { correta: 'A', totalAlt: 5 },
  229: { correta: 'A', totalAlt: 5 },
  230: { correta: 'A', totalAlt: 5 },
  231: { correta: 'A', totalAlt: 5 },
  232: { correta: 'A', totalAlt: 5 },
  233: { correta: 'A', totalAlt: 5 },
  234: { correta: 'A', totalAlt: 5 },
  235: { correta: 'A', totalAlt: 5 },
  236: { correta: 'A', totalAlt: 5 },
  237: { correta: 'A', totalAlt: 5 },
  238: { correta: 'A', totalAlt: 5 },
  239: { correta: 'A', totalAlt: 5 },
  240: { correta: 'A', totalAlt: 5 },
  241: { correta: 'A', totalAlt: 5 }
};

const LETRAS = ['A', 'B', 'C', 'D', 'E'];
let falhas = 0;

console.log(`Iniciando validação de ${explicacoes.length} explicações do Lote 1 de Língua Portuguesa...`);

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

  // 5) Classificador canônico SQL simulado
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
