#!/usr/bin/env node
// scripts/validar-fase3a-informatica.mjs
// Teste local de consistência para a Fase 3A (Informática)

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const HARNESS_PATH = path.join(ROOT, 'supabase/fase3a_informatica_correcoes_teste_rollback.sql');
const APPLY_PATH = path.join(ROOT, 'supabase/fase3a_informatica_correcoes.sql');

let errors = 0;

console.log('Iniciando testes locais de consistência da Fase 3A (Informática)...');

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

// 3. Validação dos 12 IDs alterados
const IDS_ALTERADOS = [60, 64, 338, 341, 492, 493, 494, 495, 496, 497, 791, 831];
for (const id of IDS_ALTERADOS) {
  if (!applyContent.includes(`WHERE id = ${id};`)) {
    console.error(`ERRO: UPDATE para a questão ${id} não encontrado no SQL.`);
    errors++;
  }
}
console.log(`✅ 2. Todos os 12 UPDATEs do escopo estão presentes no arquivo SQL.`);

// 4. Verificação de conteúdos essenciais das correções
const checks = [
  { id: 60, needle: 'Barra de Ferramentas de Acesso Rápido' },
  { id: 64, needle: 'silhueta de pessoa acompanhada de um sinal de adição (+)' },
  { id: 338, needle: 'como é chamado o tipo de ícone utilizado comumente' },
  { id: 341, needle: 'Tachado.' },
  { id: 492, needle: '=SOMA(B4:D4)' },
  { id: 493, needle: 'Tabelas' },
  { id: 494, needle: 'aba que apresenta gráficos de utilização em tempo real' },
  { id: 495, needle: 'Formato numérico: moeda' },
  { id: 496, needle: 'caixa com uma seta apontando para cima e para fora' },
  { id: 497, needle: 'seta circular (acionável pelo atalho F5 ou Ctrl+R)' },
  { id: 791, needle: 'Ícone da Lupa com Página – Zoom.' },
  { id: 831, needle: 'símbolo de parágrafo ¶' }
];

for (const { id, needle } of checks) {
  if (!applyContent.includes(needle)) {
    console.error(`ERRO: Conteúdo esperado para ID ${id} ('${needle}') não encontrado no SQL.`);
    errors++;
  }
}
console.log(`✅ 3. Todos os 12 conteúdos higienizados e autossuficientes foram validados no SQL.`);

// 5. Verificação de ausência de resíduos proibidos
if (applyContent.includes('CONHECIMENTOS ESPECÍFICOS (DIREITOS HUMANOS E CIDADANIA)')) {
  console.error('ERRO: Cabeçalho espúrio ainda presente no SQL.');
  errors++;
} else {
  console.log('✅ 4. Ausência de cabeçalhos espúrios validada.');
}

if (errors === 0) {
  console.log('🎉 TODOS OS TESTES LOCAIS DE CONSISTÊNCIA DA FASE 3A PASSARAM!');
} else {
  console.error(`❌ Total de erros nos testes locais: ${errors}`);
  process.exit(1);
}
