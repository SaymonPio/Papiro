#!/usr/bin/env node
// Valida as 50 explicações do Lote 3 de Língua Portuguesa (materia_id 6)
// em conformidade com as regras do classificador canônico.

import { explicacoes } from './portugues-lote3-explicacoes.mjs';

const IDS_ESPERADOS = [
  689, 690, 691, 692, 693, 744, 745, 746, 747, 748, 749, 750, 751, 752, 753, 754, 755, 756, 757, 758, 759, 760, 761, 762, 763, 764, 765, 766, 767, 784, 785, 786, 787, 806, 807, 808, 809, 810, 811, 872, 873, 874, 875, 876, 877, 878, 879, 880, 881, 882
];

// Gabaritos esperados (conferidos via MCP read-only no banco Supabase)
const GABARITOS = {
  689: { correta: 'B', totalAlt: 5 },
  690: { correta: 'A', totalAlt: 5 },
  691: { correta: 'A', totalAlt: 5 },
  692: { correta: 'E', totalAlt: 5 },
  693: { correta: 'C', totalAlt: 5 },
  744: { correta: 'E', totalAlt: 5 },
  745: { correta: 'B', totalAlt: 5 },
  746: { correta: 'E', totalAlt: 5 },
  747: { correta: 'C', totalAlt: 5 },
  748: { correta: 'D', totalAlt: 5 },
  749: { correta: 'A', totalAlt: 5 },
  750: { correta: 'D', totalAlt: 5 },
  751: { correta: 'C', totalAlt: 5 },
  752: { correta: 'A', totalAlt: 5 },
  753: { correta: 'A', totalAlt: 5 },
  754: { correta: 'C', totalAlt: 5 },
  755: { correta: 'C', totalAlt: 5 },
  756: { correta: 'C', totalAlt: 5 },
  757: { correta: 'E', totalAlt: 5 },
  758: { correta: 'E', totalAlt: 5 },
  759: { correta: 'E', totalAlt: 5 },
  760: { correta: 'E', totalAlt: 5 },
  761: { correta: 'A', totalAlt: 5 },
  762: { correta: 'C', totalAlt: 5 },
  763: { correta: 'B', totalAlt: 5 },
  764: { correta: 'E', totalAlt: 5 },
  765: { correta: 'E', totalAlt: 5 },
  766: { correta: 'D', totalAlt: 5 },
  767: { correta: 'C', totalAlt: 5 },
  784: { correta: 'B', totalAlt: 5 },
  785: { correta: 'C', totalAlt: 5 },
  786: { correta: 'A', totalAlt: 5 },
  787: { correta: 'E', totalAlt: 5 },
  806: { correta: 'A', totalAlt: 5 },
  807: { correta: 'A', totalAlt: 5 },
  808: { correta: 'B', totalAlt: 5 },
  809: { correta: 'C', totalAlt: 5 },
  810: { correta: 'D', totalAlt: 5 },
  811: { correta: 'B', totalAlt: 5 },
  872: { correta: 'D', totalAlt: 5 },
  873: { correta: 'C', totalAlt: 5 },
  874: { correta: 'B', totalAlt: 5 },
  875: { correta: 'C', totalAlt: 5 },
  876: { correta: 'A', totalAlt: 5 },
  877: { correta: 'D', totalAlt: 4 },
  878: { correta: 'A', totalAlt: 5 },
  879: { correta: 'E', totalAlt: 5 },
  880: { correta: 'C', totalAlt: 5 },
  881: { correta: 'C', totalAlt: 5 },
  882: { correta: 'B', totalAlt: 4 }
};

const LETRAS = ['A', 'B', 'C', 'D', 'E'];
let falhas = 0;

console.log(`Iniciando validação de ${explicacoes.length} explicações do Lote 3 de Língua Portuguesa...`);

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
