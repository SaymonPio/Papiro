#!/usr/bin/env node
// Valida as 50 explicações do Lote 2 de Língua Portuguesa (materia_id 6)
// em conformidade com as regras do classificador canônico.

import { explicacoes } from './portugues-lote2-explicacoes.mjs';

const IDS_ESPERADOS = [
  242, 243, 244, 245, 273, 274, 275, 276, 277, 278, 279, 280, 281, 282, 283, 284, 304, 305, 306, 307, 308, 316, 317, 318, 319, 320, 321, 322, 323, 324, 325, 328, 329, 330, 331, 332, 333, 334, 335, 336, 679, 680, 681, 682, 683, 684, 685, 686, 687, 688
];

// Gabaritos esperados (conferidos via MCP read-only no banco Supabase)
const GABARITOS = {
  242: { correta: 'A', totalAlt: 5 },
  243: { correta: 'A', totalAlt: 5 },
  244: { correta: 'A', totalAlt: 5 },
  245: { correta: 'A', totalAlt: 5 },
  273: { correta: 'A', totalAlt: 5 },
  274: { correta: 'A', totalAlt: 5 },
  275: { correta: 'A', totalAlt: 5 },
  276: { correta: 'A', totalAlt: 5 },
  277: { correta: 'A', totalAlt: 5 },
  278: { correta: 'A', totalAlt: 5 },
  279: { correta: 'A', totalAlt: 5 },
  280: { correta: 'A', totalAlt: 5 },
  281: { correta: 'A', totalAlt: 5 },
  282: { correta: 'A', totalAlt: 5 },
  283: { correta: 'A', totalAlt: 5 },
  284: { correta: 'A', totalAlt: 5 },
  304: { correta: 'A', totalAlt: 5 },
  305: { correta: 'A', totalAlt: 5 },
  306: { correta: 'A', totalAlt: 5 },
  307: { correta: 'A', totalAlt: 5 },
  308: { correta: 'A', totalAlt: 5 },
  316: { correta: 'D', totalAlt: 5 },
  317: { correta: 'C', totalAlt: 5 },
  318: { correta: 'B', totalAlt: 5 },
  319: { correta: 'A', totalAlt: 5 },
  320: { correta: 'E', totalAlt: 5 },
  321: { correta: 'B', totalAlt: 5 },
  322: { correta: 'D', totalAlt: 5 },
  323: { correta: 'C', totalAlt: 5 },
  324: { correta: 'E', totalAlt: 5 },
  325: { correta: 'E', totalAlt: 5 },
  328: { correta: 'D', totalAlt: 5 },
  329: { correta: 'C', totalAlt: 5 },
  330: { correta: 'E', totalAlt: 5 },
  331: { correta: 'A', totalAlt: 5 },
  332: { correta: 'D', totalAlt: 5 },
  333: { correta: 'D', totalAlt: 5 },
  334: { correta: 'C', totalAlt: 5 },
  335: { correta: 'C', totalAlt: 5 },
  336: { correta: 'B', totalAlt: 5 },
  679: { correta: 'A', totalAlt: 5 },
  680: { correta: 'D', totalAlt: 5 },
  681: { correta: 'D', totalAlt: 5 },
  682: { correta: 'E', totalAlt: 5 },
  683: { correta: 'D', totalAlt: 5 },
  684: { correta: 'A', totalAlt: 5 },
  685: { correta: 'D', totalAlt: 5 },
  686: { correta: 'C', totalAlt: 5 },
  687: { correta: 'C', totalAlt: 5 },
  688: { correta: 'E', totalAlt: 5 }
};

const LETRAS = ['A', 'B', 'C', 'D', 'E'];
let falhas = 0;

console.log(`Iniciando validação de ${explicacoes.length} explicações do Lote 2 de Língua Portuguesa...`);

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
