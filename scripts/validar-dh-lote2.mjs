#!/usr/bin/env node
// Valida as 50 explicações do Lote 2 de Direitos Humanos e Cidadania (materia_id 11)
// em conformidade com as regras do classificador canônico.

import { explicacoes } from './dh-lote2-explicacoes.mjs';

const IDS_ESPERADOS = [
  174, 175, 176, 177, 178, 179, 180, 181, 182, 183,
  184, 185, 186, 187, 188, 189, 190, 191, 249, 250,
  251, 252, 253, 254, 255, 256, 257, 258, 259, 260,
  261, 262, 263, 264, 265, 266, 291, 292, 293, 342,
  343, 349, 351, 352, 353, 354, 623, 624, 625, 648
];

const GABARITOS = {
  174: { correta: 'A', totalAlt: 5 },
  175: { correta: 'A', totalAlt: 5 },
  176: { correta: 'A', totalAlt: 5 },
  177: { correta: 'A', totalAlt: 5 },
  178: { correta: 'A', totalAlt: 5 },
  179: { correta: 'A', totalAlt: 5 },
  180: { correta: 'A', totalAlt: 5 },
  181: { correta: 'A', totalAlt: 5 },
  182: { correta: 'A', totalAlt: 5 },
  183: { correta: 'A', totalAlt: 5 },
  184: { correta: 'A', totalAlt: 5 },
  185: { correta: 'A', totalAlt: 5 },
  186: { correta: 'A', totalAlt: 5 },
  187: { correta: 'A', totalAlt: 5 },
  188: { correta: 'A', totalAlt: 5 },
  189: { correta: 'A', totalAlt: 5 },
  190: { correta: 'A', totalAlt: 5 },
  191: { correta: 'A', totalAlt: 5 },
  249: { correta: 'A', totalAlt: 5 },
  250: { correta: 'A', totalAlt: 5 },
  251: { correta: 'A', totalAlt: 5 },
  252: { correta: 'A', totalAlt: 5 },
  253: { correta: 'A', totalAlt: 5 },
  254: { correta: 'A', totalAlt: 5 },
  255: { correta: 'A', totalAlt: 5 },
  256: { correta: 'A', totalAlt: 5 },
  257: { correta: 'A', totalAlt: 5 },
  258: { correta: 'A', totalAlt: 5 },
  259: { correta: 'A', totalAlt: 5 },
  260: { correta: 'A', totalAlt: 5 },
  261: { correta: 'A', totalAlt: 5 },
  262: { correta: 'A', totalAlt: 5 },
  263: { correta: 'A', totalAlt: 5 },
  264: { correta: 'A', totalAlt: 5 },
  265: { correta: 'A', totalAlt: 5 },
  266: { correta: 'A', totalAlt: 5 },
  291: { correta: 'A', totalAlt: 5 },
  292: { correta: 'A', totalAlt: 5 },
  293: { correta: 'A', totalAlt: 5 },
  342: { correta: 'C', totalAlt: 5 },
  343: { correta: 'E', totalAlt: 5 },
  349: { correta: 'D', totalAlt: 5 },
  351: { correta: 'B', totalAlt: 5 },
  352: { correta: 'B', totalAlt: 5 },
  353: { correta: 'A', totalAlt: 5 },
  354: { correta: 'D', totalAlt: 5 },
  623: { correta: 'B', totalAlt: 5 },
  624: { correta: 'B', totalAlt: 5 },
  625: { correta: 'C', totalAlt: 5 },
  648: { correta: 'E', totalAlt: 5 }
};

const LETRAS = ['A', 'B', 'C', 'D', 'E'];
let falhas = 0;

console.log(`Iniciando validação de ${explicacoes.length} explicações do Lote 2 de Direitos Humanos...`);

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
