#!/usr/bin/env node
// FASE 3A -- prepara as 521 candidatas APROVADA_PARA_PROXIMA_FASE=true para a
// proxima etapa. So leitura/normalizacao local -- nao toca o Supabase.
//
// Fonte de verdade para QUAIS candidatas entram: lote2_manifesto_fase2_533.json
// (campo APROVADA_PARA_PROXIMA_FASE). Fonte do CONTEUDO completo (enunciado,
// alternativas, gabarito, topico): lote2_fase2_pool_533.json (mesmo dado usado
// durante toda a Fase 2, extraido programaticamente do inventario original,
// nunca retranscrito a mao).
//
// Normalizacao: SOMENTE artefatos de extracao de PDF/OCR ja identificados
// durante a Fase 2 (rodape/cabecalho vazado, caracteres soltos, digitos
// perdidos). Erros de conteudo do proprio exame original (numero de lei errado
// citado pela banca, artigo errado citado pela banca) NAO sao alterados --
// permanecem como a fonte historica realmente diz, e ficam documentados no
// metadado de ressalva para a futura explicacao pedagogica lidar com isso.

import fs from 'fs';

const SCRATCH = 'C:/Users/User/AppData/Local/Temp/claude/C--Users-User-Desktop-Papiro-corrigido-Papiro-com/05fe1ce8-5b6b-4a87-bae9-e09d32a28036/scratchpad';

const manifesto = JSON.parse(fs.readFileSync(`${SCRATCH}/lote2_manifesto_fase2_533.json`, 'utf8'));
const pool = JSON.parse(fs.readFileSync(`${SCRATCH}/lote2_fase2_pool_533.json`, 'utf8'));
const poolPorTecId = new Map(pool.map(q => [q.tecId, q]));

// --- Passo 1: filtra pelo manifesto (fonte de verdade) -------------------
const aprovadas = manifesto.filter(m => m.APROVADA_PARA_PROXIMA_FASE === true);
const reprovadasIds = new Set(manifesto.filter(m => !m.APROVADA_PARA_PROXIMA_FASE).map(m => m.tecId));

console.log('Aprovadas no manifesto (fonte de verdade):', aprovadas.length, '(esperado 521)');
console.log('Reprovadas no manifesto:', reprovadasIds.size, '(esperado 12)');

// --- Passo 2: junta com o conteudo completo do pool -----------------------
const registros = aprovadas.map(m => {
  const conteudo = poolPorTecId.get(m.tecId);
  if (!conteudo) throw new Error(`tecId ${m.tecId} aprovado no manifesto mas ausente do pool -- integridade quebrada`);
  if (conteudo.cadernoNumero !== m.cadernoNumero) throw new Error(`cadernoNumero divergente para tecId ${m.tecId}`);
  return {
    tecId: m.tecId,
    cadernoNumero: m.cadernoNumero,
    banca: conteudo.banca,
    concurso: conteudo.concurso,
    ano: conteudo.ano,
    topico: conteudo.topico,
    enunciado: conteudo.enunciado,
    alternativas: [...conteudo.alternativas],
    gabarito: conteudo.gabarito,
    arquivoOrigem: conteudo.arquivoOrigem,
    fingerprint: conteudo.fingerprint,
    classificacao_final: m.classificacao_final,
    motivo_ressalva: m.motivo_ressalva,
    sublote_origem: m.sublote_origem,
    limpeza_aplicada: [],
  };
});

// --- Passo 3: padroes de contaminacao de rodape/cabecalho do PDF ----------
const PADROES_CONTAMINACAO = [
  /\d{2}\/\d{2}\/\d{4},?\s*\d{2}:\d{2}/,               // timestamp "dd/mm/aaaa, hh:mm"
  /Caderno Lei Maria da Penha(\s*-\s*\d+\s*QUEST[ÕO]ES)?/i,
  /www\.tecconcursos\.com\.br\/(questoes|s)\/\S+/i,
  /Ordena[çc][ãa]o:\s*Por\s*Mat[ée]ria/i,
  /https:\/\/www\.tecconcursos\.com\.br\/questoes\/cadernos\/\d+\/imprimir/i,
];
function contaminado(texto) {
  return PADROES_CONTAMINACAO.some(re => re.test(texto));
}

// --- Passo 4: reverificacao sistemica de contaminacao em TODOS os campos --
// (enunciado, alternativas, topico) para as 521 -- nao confia so nas notas
// feitas durante a Fase 2, reescaneia programaticamente agora.
const achadosContaminacao = { enunciado: [], alternativas: [], topico: [] };
for (const r of registros) {
  if (contaminado(r.enunciado)) achadosContaminacao.enunciado.push(r.tecId);
  r.alternativas.forEach((a, i) => { if (contaminado(a)) achadosContaminacao.alternativas.push({ tecId: r.tecId, indice: i }); });
  if (contaminado(r.topico)) achadosContaminacao.topico.push(r.tecId);
}
console.log('\n--- Reverificacao sistemica de contaminacao (rodape/cabecalho) nas 521 ---');
console.log('Enunciado contaminado:', achadosContaminacao.enunciado.length, JSON.stringify(achadosContaminacao.enunciado));
console.log('Alternativa contaminada:', achadosContaminacao.alternativas.length, JSON.stringify(achadosContaminacao.alternativas));
console.log('Topico contaminado:', achadosContaminacao.topico.length, JSON.stringify(achadosContaminacao.topico));

// --- Passo 5: alternativas quebradas/vazias/anomalas ----------------------
const alternativasQuebradas = [];
for (const r of registros) {
  r.alternativas.forEach((a, i) => {
    const t = (a || '').trim();
    if (t.length === 0) alternativasQuebradas.push({ tecId: r.tecId, indice: i, motivo: 'vazia' });
    else if (t.length < 3) alternativasQuebradas.push({ tecId: r.tecId, indice: i, motivo: 'texto residual (<3 caracteres): ' + JSON.stringify(t) });
  });
}
console.log('\n--- Alternativas vazias/residuais nas 521 ---');
console.log(alternativasQuebradas.length, JSON.stringify(alternativasQuebradas));

fs.writeFileSync(`${SCRATCH}/fase3a_diagnostico_bruto.json`, JSON.stringify({ achadosContaminacao, alternativasQuebradas }, null, 2), 'utf8');
console.log('\nGravado diagnostico bruto: fase3a_diagnostico_bruto.json');
console.log('\nTotal de registros montados (antes de normalizar):', registros.length);
fs.writeFileSync(`${SCRATCH}/fase3a_registros_pre_normalizacao.json`, JSON.stringify(registros, null, 2), 'utf8');
