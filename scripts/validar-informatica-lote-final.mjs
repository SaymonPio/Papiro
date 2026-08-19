#!/usr/bin/env node
// Valida as 39 explicações do Lote Final de Informática (materia_id 9)
// em conformidade com as regras do classificador canônico.

import { explicacoes } from './informatica-lote-final-explicacoes.mjs';

const IDS_ESPERADOS = [
  633, 634, 635, 636, 637, 638, 639,
  640, 641, 642, 643, 644, 645, 698,
  699, 700, 701, 702, 703, 704, 705,
  706, 707, 708, 709, 710, 711, 768,
  769, 770, 791, 792, 830, 831, 832,
  833, 834, 835, 836
];

const GABARITOS = {
  633: { correta: 'C', totalAlt: 5 },
  634: { correta: 'E', totalAlt: 5 },
  635: { correta: 'C', totalAlt: 5 },
  636: { correta: 'E', totalAlt: 5 },
  637: { correta: 'B', totalAlt: 5 },
  638: { correta: 'D', totalAlt: 5 },
  639: { correta: 'D', totalAlt: 5 },
  640: { correta: 'D', totalAlt: 5 },
  641: { correta: 'E', totalAlt: 5 },
  642: { correta: 'C', totalAlt: 5 },
  643: { correta: 'C', totalAlt: 5 },
  644: { correta: 'A', totalAlt: 5 },
  645: { correta: 'B', totalAlt: 5 },
  698: { correta: 'D', totalAlt: 5 },
  699: { correta: 'E', totalAlt: 5 },
  700: { correta: 'A', totalAlt: 5 },
  701: { correta: 'E', totalAlt: 5 },
  702: { correta: 'D', totalAlt: 5 },
  703: { correta: 'A', totalAlt: 5 },
  704: { correta: 'B', totalAlt: 5 },
  705: { correta: 'C', totalAlt: 5 },
  706: { correta: 'B', totalAlt: 5 },
  707: { correta: 'C', totalAlt: 5 },
  708: { correta: 'E', totalAlt: 5 },
  709: { correta: 'C', totalAlt: 5 },
  710: { correta: 'A', totalAlt: 5 },
  711: { correta: 'E', totalAlt: 5 },
  768: { correta: 'C', totalAlt: 5 },
  769: { correta: 'D', totalAlt: 5 },
  770: { correta: 'E', totalAlt: 5 },
  791: { correta: 'B', totalAlt: 5 },
  792: { correta: 'E', totalAlt: 5 },
  830: { correta: 'A', totalAlt: 5 },
  831: { correta: 'B', totalAlt: 5 },
  832: { correta: 'C', totalAlt: 5 },
  833: { correta: 'D', totalAlt: 5 },
  834: { correta: 'C', totalAlt: 5 },
  835: { correta: 'C', totalAlt: 5 },
  836: { correta: 'B', totalAlt: 5 }
};

const LETRAS = ['A', 'B', 'C', 'D', 'E'];
let falhas = 0;

console.log(`Iniciando validação de ${explicacoes.length} explicações do Lote Final de Informática...`);

if (explicacoes.length !== 39) {
  console.error(`FALHA: esperado 39 explicações, encontrado ${explicacoes.length}`);
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
  console.log(`✅ SUCESSO: Todas as 39 explicações foram validadas com 100% de conformidade canônica!`);
} else {
  console.error(`❌ Total de falhas encontradas: ${falhas}`);
  process.exit(1);
}
