#!/usr/bin/env node
// Valida as 21 explicações do LE-1a (Direitos e Garantias Fundamentais,
// assunto_id 71) em DUAS camadas independentes, antes de qualquer SQL ser
// gerado -- mesmo padrão de scripts/validar-sublote1-explicacoes.mjs:
//
//   1) Fidelidade aos dados REAIS do banco (le1a_raw.json, exportado via
//      MCP nesta sessão, sem retranscrição manual do texto das
//      alternativas -- só letra/correta, que é o que a validação
//      estrutural precisa): confere que a letra do "GABARITO:" bate com a
//      alternativa marcada correta=true no banco, e que toda alternativa
//      realmente existente na questão tem uma seção "POR QUE A
//      ALTERNATIVA <letra> ESTÁ (CORRETA|INCORRETA)" -- nem faltando, nem
//      sobrando letra, com o status (CORRETA/INCORRETA) batendo com o
//      campo correta do banco.
//   2) A MESMA regra estrutural determinística usada na auditoria
//      (supabase/classificar_explicacoes_questoes.sql), reimplementada em
//      JS para não depender de round-trip com o banco nesta etapa --
//      confirma que cada texto seria classificado EXPLICACAO_COMPLETA.
//
// Não escreve nada -- só leitura de arquivos locais. Sai com exit code 1 se
// qualquer questão falhar em qualquer uma das duas camadas.
//
// Questão 659 (PROBLEMATICA, texto truncado/corrompido) foi INTENCIONALMENTE
// excluída de scripts/le1a-direitos-garantias-fundamentais-explicacoes.mjs
// -- este validador confere isso explicitamente no final.

import fs from 'fs';
import { explicacoes } from './le1a-direitos-garantias-fundamentais-explicacoes.mjs';

const RAW_PATH = 'C:/Users/User/AppData/Local/Temp/claude/C--Users-User-Desktop-Papiro-corrigido-Papiro-com/05fe1ce8-5b6b-4a87-bae9-e09d32a28036/scratchpad/le1a_raw.json';
const raw = JSON.parse(fs.readFileSync(RAW_PATH, 'utf8'));
const porId = new Map(raw.map(q => [q.id, q]));

const IDS_ESPERADOS = [46, 112, 298, 326, 657, 658, 660, 661, 662, 663, 723, 724, 725, 726, 727, 775, 797, 846, 847, 848, 849];

let falhas = 0;
const relatorio = [];

// 0) Confere o conjunto de IDs processados: exatamente os 21 esperados,
// sem duplicata, sem faltar nenhum, e SEM o 659.
{
  const idsArquivo = explicacoes.map(e => e.id);
  const setArquivo = new Set(idsArquivo);
  if (idsArquivo.length !== setArquivo.size) {
    console.error('FALHA GLOBAL: ha id duplicado no arquivo de explicacoes');
    falhas++;
  }
  const faltando = IDS_ESPERADOS.filter(id => !setArquivo.has(id));
  const sobrando = idsArquivo.filter(id => !IDS_ESPERADOS.includes(id));
  if (faltando.length) { console.error('FALHA GLOBAL: faltam ids esperados:', faltando); falhas++; }
  if (sobrando.length) { console.error('FALHA GLOBAL: ha ids nao esperados (fora do lote de 21):', sobrando); falhas++; }
  if (setArquivo.has(659)) { console.error('FALHA GLOBAL: id 659 (PROBLEMATICA) nao deveria estar neste arquivo'); falhas++; }
}

for (const { id, explicacao } of explicacoes) {
  const q = porId.get(id);
  if (!q) { console.error(`FALHA ${id}: nao encontrada no raw json`); falhas++; continue; }

  const alts = q.alternativas;
  const nAlt = alts.length;
  const problemas = [];

  // Camada 1: fidelidade ao banco real.
  const corretaLetra = alts.find(a => a.correta).letra;
  const gabaritoMatch = explicacao.match(/GABARITO\s*:\s*alternativa\s+([A-E])/i);
  if (!gabaritoMatch) problemas.push('sem marcador GABARITO: alternativa X');
  else if (gabaritoMatch[1].toUpperCase() !== corretaLetra) {
    problemas.push(`GABARITO diz ${gabaritoMatch[1]} mas o banco marca correta=${corretaLetra}`);
  }

  const mencionadas = new Map(); // letra -> status (CORRETA|INCORRETA)
  const re = /POR QUE A ALTERNATIVA\s+([A-E])\s+EST[ÁA]\s+(CORRETA|INCORRETA)/gi;
  let m;
  while ((m = re.exec(explicacao))) {
    mencionadas.set(m[1].toUpperCase(), m[2].toUpperCase());
  }
  const letrasReais = alts.map(a => a.letra);
  for (const letra of letrasReais) {
    if (!mencionadas.has(letra)) problemas.push(`falta comentario para a alternativa ${letra} (existe no banco)`);
  }
  for (const letra of mencionadas.keys()) {
    if (!letrasReais.includes(letra)) problemas.push(`comenta alternativa ${letra}, que NAO existe nesta questao (so tem ${letrasReais.join(',')})`);
  }
  for (const a of alts) {
    const status = mencionadas.get(a.letra);
    if (!status) continue;
    const esperado = a.correta ? 'CORRETA' : 'INCORRETA';
    if (status !== esperado) problemas.push(`alternativa ${a.letra} comentada como ${status}, mas banco marca correta=${a.correta} (esperado ${esperado})`);
  }

  if (!/BIZU DE PROVA/i.test(explicacao)) problemas.push('sem BIZU DE PROVA');

  // Camada 2: mesma regra estrutural do classificador SQL canonico
  // (supabase/classificar_explicacoes_questoes.sql) para múltipla escolha
  // (nenhuma destas 21 é Certo/Errado).
  const passaClassificador =
    /GABARITO\s*:/i.test(explicacao) &&
    /BIZU DE PROVA/i.test(explicacao) &&
    mencionadas.size >= nAlt;
  if (!passaClassificador) problemas.push('NAO passaria como EXPLICACAO_COMPLETA no classificador canonico');

  if (problemas.length > 0) {
    falhas++;
    relatorio.push({ id, problemas });
  } else {
    relatorio.push({ id, problemas: [] });
  }
}

console.log(`Total processado: ${explicacoes.length}`);
console.log(`Aprovadas: ${explicacoes.length - relatorio.filter(r => r.problemas.length > 0).length}`);
console.log(`Reprovadas: ${relatorio.filter(r => r.problemas.length > 0).length}`);
if (falhas > 0) {
  console.log('\n=== FALHAS ===');
  for (const r of relatorio.filter(r => r.problemas.length > 0)) {
    console.log(`  questao ${r.id}: ${r.problemas.join(' | ')}`);
  }
  process.exit(1);
} else {
  console.log('\nTodas as 21 aprovadas: gabarito bate com o banco, todas as alternativas comentadas com status correto, BIZU presente, estrutura EXPLICACAO_COMPLETA confirmada. Questao 659 confirmada FORA do lote.');
}
