import fs from 'fs';
import path from 'path';

const rootDir = process.cwd();
const rollbackPath = path.join(rootDir, 'supabase', 'fase3b2b_rl_correcoes_teste_rollback.sql');
const applyPath = path.join(rootDir, 'supabase', 'fase3b2b_rl_correcoes.sql');

let errors = 0;

function assert(condition, message) {
  if (!condition) {
    console.error(`❌ ERRO: ${message}`);
    errors++;
  } else {
    console.log(`✅ ${message}`);
  }
}

console.log('=== VALIDADOR DA FASE 3B-2B-RL (RACIOCÍNIO LÓGICO - QUESTÃO 337) ===\n');

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

// 3. Extração e validação estrita dos comandos UPDATE
const updateQuestaoRegex = /UPDATE public\.questoes\s+SET enunciado = '[\s\S]*?'(?:,\s*atualizado_em = now\(\))?\s+WHERE id = (\d+);/g;
const updateAltRegex = /UPDATE public\.alternativas\s+SET texto = '[\s\S]*?'\s+WHERE questao_id = (\d+)\s+AND ordem = (\d+);/g;

const rollbackQuestaoMatches = [...rollbackSql.matchAll(updateQuestaoRegex)].map(m => parseInt(m[1], 10));
const applyQuestaoMatches = [...applySql.matchAll(updateQuestaoRegex)].map(m => parseInt(m[1], 10));

const rollbackAltMatches = [...rollbackSql.matchAll(updateAltRegex)].map(m => ({ questao_id: parseInt(m[1], 10), ordem: parseInt(m[2], 10) }));
const applyAltMatches = [...applySql.matchAll(updateAltRegex)].map(m => ({ questao_id: parseInt(m[1], 10), ordem: parseInt(m[2], 10) }));

assert(rollbackQuestaoMatches.length === 1 && rollbackQuestaoMatches[0] === 337, 'Harness atualiza exclusivamente o enunciado da questão 337');
assert(applyQuestaoMatches.length === 1 && applyQuestaoMatches[0] === 337, 'Apply atualiza exclusivamente o enunciado da questão 337');

assert(rollbackAltMatches.length === 1 && rollbackAltMatches[0].questao_id === 337 && rollbackAltMatches[0].ordem === 5, 'Harness atualiza exclusivamente a alternativa 5 da questão 337');
assert(applyAltMatches.length === 1 && applyAltMatches[0].questao_id === 337 && applyAltMatches[0].ordem === 5, 'Apply atualiza exclusivamente a alternativa 5 da questão 337');

// 4. Validação de ausência de cabeçalho residual e ausência de \\n literal nos textos SQL
assert(!applySql.includes('CIÊNCIAS NATURAIS'), 'Ausência de cabeçalho residual "CIÊNCIAS NATURAIS" no SQL gerado');

// 5. Validação da presença dos 8 Asserts no SQL
assert(applySql.includes('Assert 1 falhou: totais pós-migração incorretos'), 'Assert 1 presente (totais 915/907/8)');
assert(applySql.includes('Assert 2 falhou: uma ou mais questões de Raciocínio Lógico tiveram status ativa alterado'), 'Assert 2 presente (34 ativas em RL)');
assert(applySql.includes('Assert 3 falhou: uma ou mais questões de Raciocínio Lógico não possuem exatamente 1 alternativa correta'), 'Assert 3 presente (exatamente 1 alternativa correta por questão)');
assert(applySql.includes('Assert 4 falhou: divergência no gabarito oficial da questão % de Raciocínio Lógico'), 'Assert 4 presente (preservação de gabaritos oficiais)');
assert(applySql.includes('Assert 5 falhou: questão % de RL (fora do lote) foi modificada'), 'Assert 5 presente (33 questões fora do lote intocadas)');
assert(applySql.includes('Assert 6 falhou: explicação da questão % de RL foi alterada'), 'Assert 6 presente (34 explicações intocadas byte a byte)');
assert(applySql.includes('Assert 7 falhou: enunciado da questão 337 não corresponde ao texto saneado esperado'), 'Assert 7 presente (saneamento da questão 337)');
assert(applySql.includes('Assert 8 falhou: resíduo de cabeçalho ou \\n literal detectado'), 'Assert 8 presente (guarda contra resíduos e \\n literal)');

console.log('\n------------------------------------------------------------');
if (errors === 0) {
  console.log('🎉 TODOS OS TESTES LOCAIS PASSARAM COM SUCESSO! (0 erros)');
  process.exit(0);
} else {
  console.error(`💥 VALIDAÇÃO FALHOU COM ${errors} ERRO(S)!`);
  process.exit(1);
}
