#!/usr/bin/env node
// Valida as 50 explicações do Lote 1 de Direitos Humanos e Cidadania (materia_id 11)
// em conformidade com as regras do classificador canônico.

import { explicacoes } from './dh-lote1-explicacoes.mjs';

const IDS_ESPERADOS = [
  13, 28, 29, 30, 55, 56, 57, 58, 59,
  124, 125, 126, 127, 128, 130, 131, 138,
  139, 140, 141, 144, 145, 146, 147, 148,
  149, 150, 151, 152, 153, 154, 155, 156,
  157, 158, 159, 160, 161, 162, 163, 164,
  165, 166, 167, 168, 169, 170, 171, 172, 173
];

const GABARITOS = {
  13: { correta: 'A', totalAlt: 4 },
  28: { correta: 'A', totalAlt: 5 },
  29: { correta: 'A', totalAlt: 5 },
  30: { correta: 'A', totalAlt: 5 },
  55: { correta: 'A', totalAlt: 5 },
  56: { correta: 'C', totalAlt: 5 },
  57: { correta: 'D', totalAlt: 5 },
  58: { correta: 'B', totalAlt: 5 },
  59: { correta: 'E', totalAlt: 5 },
  124: { correta: 'B', totalAlt: 5 },
  125: { correta: 'A', totalAlt: 5 },
  126: { correta: 'C', totalAlt: 5 },
  127: { correta: 'D', totalAlt: 5 },
  128: { correta: 'C', totalAlt: 5 },
  130: { correta: 'B', totalAlt: 5 },
  131: { correta: 'D', totalAlt: 5 },
  138: { correta: 'A', totalAlt: 5 },
  139: { correta: 'C', totalAlt: 5 },
  140: { correta: 'B', totalAlt: 5 },
  141: { correta: 'E', totalAlt: 5 },
  144: { correta: 'B', totalAlt: 5 },
  145: { correta: 'B', totalAlt: 5 },
  146: { correta: 'E', totalAlt: 5 },
  147: { correta: 'A', totalAlt: 5 },
  148: { correta: 'A', totalAlt: 5 },
  149: { correta: 'A', totalAlt: 5 },
  150: { correta: 'A', totalAlt: 5 },
  151: { correta: 'A', totalAlt: 5 },
  152: { correta: 'A', totalAlt: 5 },
  153: { correta: 'A', totalAlt: 5 },
  154: { correta: 'A', totalAlt: 5 },
  155: { correta: 'A', totalAlt: 5 },
  156: { correta: 'A', totalAlt: 5 },
  157: { correta: 'A', totalAlt: 5 },
  158: { correta: 'A', totalAlt: 5 },
  159: { correta: 'A', totalAlt: 5 },
  160: { correta: 'A', totalAlt: 5 },
  161: { correta: 'A', totalAlt: 5 },
  162: { correta: 'A', totalAlt: 5 },
  163: { correta: 'A', totalAlt: 5 },
  164: { correta: 'A', totalAlt: 5 },
  165: { correta: 'A', totalAlt: 5 },
  166: { correta: 'A', totalAlt: 5 },
  167: { correta: 'A', totalAlt: 5 },
  168: { correta: 'A', totalAlt: 5 },
  169: { correta: 'A', totalAlt: 5 },
  170: { correta: 'A', totalAlt: 5 },
  171: { correta: 'A', totalAlt: 5 },
  172: { correta: 'A', totalAlt: 5 },
  173: { correta: 'A', totalAlt: 5 }
};

const LETRAS = ['A', 'B', 'C', 'D', 'E'];
let falhas = 0;

console.log(`Iniciando validação de ${explicacoes.length} explicações do Lote 1 de Direitos Humanos...`);

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
