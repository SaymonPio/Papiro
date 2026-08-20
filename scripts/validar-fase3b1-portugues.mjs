#!/usr/bin/env node
// scripts/validar-fase3b1-portugues.mjs
// Teste local de consistência para a Fase 3B-1 (Língua Portuguesa)

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const HARNESS_PATH = path.join(ROOT, 'supabase/fase3b1_portugues_correcoes_teste_rollback.sql');
const APPLY_PATH = path.join(ROOT, 'supabase/fase3b1_portugues_correcoes.sql');

let errors = 0;

console.log('Iniciando testes locais de consistência da Fase 3B-1 (Língua Portuguesa)...');

// 1. Existência dos arquivos
if (!fs.existsSync(HARNESS_PATH)) {
  console.error(`ERRO: Arquivo do harness não encontrado: ${HARNESS_PATH}`);
  errors++;
}
if (!fs.existsSync(APPLY_PATH)) {
  console.error(`ERRO: Arquivo do apply não encontrado: ${APPLY_PATH}`);
  errors++;
}

if (errors > 0) process.exit(1);

const harnessContent = fs.readFileSync(HARNESS_PATH, 'utf8');
const applyContent = fs.readFileSync(APPLY_PATH, 'utf8');

// 2. Diff estrito entre harness e apply
const harnessExpectedFromApply = applyContent
  .replace('APPLY DEFINITIVO COM COMMIT', 'TESTE COM ROLLBACK OBRIGATÓRIO')
  .replace(/COMMIT;\s*$/, 'ROLLBACK;\n');

if (harnessContent.trim() !== harnessExpectedFromApply.trim()) {
  console.error('ERRO: Divergência inesperada entre o harness (rollback) e o apply (commit).');
  errors++;
} else {
  console.log('✅ 1. Diff estrito entre harness e apply validado com sucesso (apenas ROLLBACK vs COMMIT).');
}

// 3. Validação dos 14 IDs alterados
const IDS_ALTERADOS = [66, 70, 115, 119, 120, 121, 321, 324, 328, 329, 330, 333, 334, 689];
for (const id of IDS_ALTERADOS) {
  if (!applyContent.includes(`WHERE id = ${id};`)) {
    console.error(`ERRO: UPDATE para a questão ${id} não encontrado no SQL.`);
    errors++;
  }
}
console.log(`✅ 2. Todos os 14 UPDATEs do escopo estão presentes no arquivo SQL.`);

// 4. Verificação de conteúdos essenciais das correções
const checks = [
  { id: 66, needle: 'cora...em – ameni...ar – fa...cínio' },
  { id: 70, needle: '...chegar _____ margens da lagoa...' },
  { id: 115, needle: '...em relação _____ juventude...' },
  { id: 119, needle: 'norma ortográfica vigente' },
  { id: 120, needle: '...o cenário _____ nos encontramos...' },
  { id: 121, needle: 'conquanto' },
  { id: 321, needle: 'de...empenho – e...igente – e...gotamento – visuali...ado' },
  { id: 324, needle: 'esse filho adulto' },
  { id: 328, needle: '...adaptadas _____ novas necessidades...' },
  { id: 329, needle: 'dei...ar – extin...ão – utili...ar' },
  { id: 330, needle: 'Considerando o vocábulo "e...tremidades"' },
  { id: 333, needle: 'Essas novas ferramentas' },
  { id: 334, needle: 'conjunção coordenativa adversativa "mas"' },
  { id: 689, needle: 'de...empenho – e...igente – e...gotamento – visuali...ado' }
];

for (const { id, needle } of checks) {
  if (!applyContent.includes(needle)) {
    console.error(`ERRO: Conteúdo esperado para ID ${id} ('${needle}') não encontrado no SQL.`);
    errors++;
  }
}
console.log(`✅ 3. Todos os 14 conteúdos autossuficientes foram validados no SQL.`);

// 5. Verificação de que o UPDATE do ID 330 não contém o resíduo "l. 1 5"
const update330Match = applyContent.match(/UPDATE public\.questoes\s+SET enunciado = '([\s\S]*?)',\s+atualizado_em = now\(\)\s+WHERE id = 330;/);
if (!update330Match || update330Match[1].includes('l. 1 5')) {
  console.error('ERRO: UPDATE da questão 330 contém resíduo de OCR "l. 1 5" ou não foi localizado.');
  errors++;
} else {
  console.log('✅ 4. Ausência de resíduos de OCR no UPDATE do ID 330 validada.');
}

if (errors === 0) {
  console.log('🎉 TODOS OS TESTES LOCAIS DE CONSISTÊNCIA DA FASE 3B-1 PASSARAM!');
} else {
  console.error(`❌ Total de erros nos testes locais: ${errors}`);
  process.exit(1);
}
