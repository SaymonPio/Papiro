import fs from 'fs';
import path from 'path';

const CAT_A_IDS = new Set([
  679, 680, 681, 682, 684, 685, 686, 687, 690, 691, 692, 693,
  744, 745, 746, 747, 748, 749, 750, 752, 753, 754, 755, 756, 757,
  762, 763, 765, 766, 767, 784, 785, 786, 806, 807, 808, 809, 811,
  872, 873, 874, 875, 877, 878, 880, 881, 882, 883, 884, 885, 886, 887, 890, 893
]);

const CAT_B_IDS = new Set([
  683, 688, 751, 759, 760, 761, 764, 787, 876, 879, 888, 889, 891, 892
]);

const CAT_C_IDS = new Set([
  758, 810, 894
]);

const rootDir = process.cwd();
const rollbackPath = path.join(rootDir, 'supabase', 'fase3b2a_portugues_correcoes_teste_rollback.sql');
const applyPath = path.join(rootDir, 'supabase', 'fase3b2a_portugues_correcoes.sql');

let errors = 0;

function assert(condition, message) {
  if (!condition) {
    console.error(`❌ ERRO: ${message}`);
    errors++;
  } else {
    console.log(`✅ ${message}`);
  }
}

console.log('=== VALIDADOR DA FASE 3B-2A (PORTUGUÊS - 54 QUESTÕES) ===\n');

// 1. Existência dos arquivos
assert(fs.existsSync(rollbackPath), `Arquivo de rollback existe: ${rollbackPath}`);
assert(fs.existsSync(applyPath), `Arquivo de apply existe: ${applyPath}`);

if (errors > 0) {
  console.error(`\nValidação abortada por ausência de arquivos. Total de erros: ${errors}`);
  process.exit(1);
}

const rollbackSql = fs.readFileSync(rollbackPath, 'utf8');
const applySql = fs.readFileSync(applyPath, 'utf8');

// 2. Paridade entre rollback e apply
assert(rollbackSql.includes('ROLLBACK;'), 'Harness termina com ROLLBACK;');
assert(applySql.includes('COMMIT;'), 'Apply termina com COMMIT;');

const normalizedRollback = rollbackSql
  .replace('TESTE COM ROLLBACK OBRIGATÓRIO', '')
  .replace('ROLLBACK;', '');
const normalizedApply = applySql
  .replace('APPLY DEFINITIVO (COMMIT)', '')
  .replace('COMMIT;', '');

assert(normalizedRollback.trim() === normalizedApply.trim(), 'Paridade total de lógica e dados entre harness e apply');

// 3. Extração e validação estrita dos IDs atualizados
const updateRegex = /UPDATE public\.questoes\s+SET enunciado = '[\s\S]*?'(?:,\s*atualizado_em = now\(\))?\s+WHERE id = (\d+);/g;

const rollbackMatches = [...rollbackSql.matchAll(updateRegex)].map(m => parseInt(m[1], 10));
const applyMatches = [...applySql.matchAll(updateRegex)].map(m => parseInt(m[1], 10));

assert(rollbackMatches.length === 54, `Harness contém exatamente 54 UPDATEs (encontrado: ${rollbackMatches.length})`);
assert(applyMatches.length === 54, `Apply contém exatamente 54 UPDATEs (encontrado: ${applyMatches.length})`);

const applyIdsSet = new Set(applyMatches);
assert(applyIdsSet.size === 54, `Apply contém exatamente 54 IDs únicos (encontrado: ${applyIdsSet.size})`);

// Validação dos IDs da Categoria A
let allInCatA = true;
let foreignIds = [];
for (const id of applyIdsSet) {
  if (!CAT_A_IDS.has(id)) {
    allInCatA = false;
    foreignIds.push(id);
  }
}
assert(allInCatA, `Todos os 54 IDs pertencem exclusivamente à Categoria A (estranhos: ${foreignIds.join(', ') || 'nenhum'})`);

// Validação de ausência estrita de IDs de Cat B e Cat C
let catBFound = [];
for (const id of applyIdsSet) {
  if (CAT_B_IDS.has(id)) catBFound.push(id);
}
assert(catBFound.length === 0, `Nenhum ID da Categoria B (14 IDs) está presente no lote (encontrados: ${catBFound.join(', ') || 'nenhum'})`);

let catCFound = [];
for (const id of applyIdsSet) {
  if (CAT_C_IDS.has(id)) catCFound.push(id);
}
assert(catCFound.length === 0, `Nenhum ID da Categoria C (3 IDs) está presente no lote (encontrados: ${catCFound.join(', ') || 'nenhum'})`);

// 4. Validação de ausência de literais de quebra de linha '\n' em strings SQL
// Checa se algum UPDATE contém a sequência literal '\n' no código fonte SQL gerado
const literalSlashNInUpdates = applyMatches.some(id => {
  const match = applySql.match(new RegExp(`UPDATE public\\.questoes[\\s\\S]*?WHERE id = ${id};`));
  if (!match) return false;
  // Se contiver a string literal '\n' (barra invertida seguida de 'n') dentro do corpo do UPDATE
  return match[0].includes('\\n') && !match[0].includes('position');
});
assert(!literalSlashNInUpdates, 'Ausência de sequências literais \\n nos enunciados SQL (quebras reais utilizadas)');

// 5. Validação da presença dos 8 Asserts no SQL
assert(applySql.includes('Assert 1 falhou: totais pós-migração incorretos'), 'Assert 1 presente (totais 915/907/8)');
assert(applySql.includes('Assert 2 falhou: uma ou mais questões de Língua Portuguesa tiveram status ativa alterado'), 'Assert 2 presente (162 ativas em LP)');
assert(applySql.includes('Assert 3 falhou: uma ou mais questões de Língua Portuguesa não possuem exatamente 1 alternativa correta'), 'Assert 3 presente (exatamente 1 alternativa correta por questão)');
assert(applySql.includes('Assert 4 falhou: divergência no gabarito oficial'), 'Assert 4 presente (preservação de gabaritos oficiais)');
assert(applySql.includes('Assert 5 falhou: questão % (fora do lote) foi modificada'), 'Assert 5 presente (108 questões fora do lote intocadas)');
assert(applySql.includes('Assert 6 falhou: explicação da questão % foi alterada'), 'Assert 6 presente (162 explicações intocadas byte a byte)');
assert(applySql.includes('Assert 7 falhou: uma ou mais questões da Categoria A ainda contêm texto longo'), 'Assert 7 presente (redução do texto-base)');
assert(applySql.includes('Assert 8 falhou: sequência literal \\n detectada'), 'Assert 8 presente (guarda contra \\n literal no banco)');

console.log('\n------------------------------------------------------------');
if (errors === 0) {
  console.log('🎉 TODOS OS TESTES PASSARAM COM SUCESSO! (0 erros)');
  process.exit(0);
} else {
  console.error(`💥 VALIDAÇÃO FALHOU COM ${errors} ERRO(S)!`);
  process.exit(1);
}
