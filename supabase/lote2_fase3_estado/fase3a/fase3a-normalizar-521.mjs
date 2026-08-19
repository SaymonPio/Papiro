#!/usr/bin/env node
// FASE 3A -- passo 2: aplica normalizacao SOMENTE de artefatos de parser/OCR
// ja identificados durante a Fase 2, sobre os 521 registros montados por
// fase3a-preparar-521.mjs. Erros de conteudo do proprio exame original
// (numero de lei errado, artigo errado citado pela banca) NAO sao tocados --
// ficam documentados em `motivo_ressalva` (herdado do manifesto) para a
// explicacao pedagogica futura lidar com isso.

import fs from 'fs';

const SCRATCH = 'C:/Users/User/AppData/Local/Temp/claude/C--Users-User-Desktop-Papiro-corrigido-Papiro-com/05fe1ce8-5b6b-4a87-bae9-e09d32a28036/scratchpad';
const registros = JSON.parse(fs.readFileSync(`${SCRATCH}/fase3a_registros_pre_normalizacao.json`, 'utf8'));
const porTecId = new Map(registros.map(r => [r.tecId, r]));

function aplica(tecId, campo, indice, find, replace, motivo) {
  const r = porTecId.get(tecId);
  if (!r) throw new Error(`Normalizacao apontando para tecId ${tecId}, que nao esta nos 521 aprovados -- abortando`);
  const alvo = campo === 'alternativas' ? r.alternativas[indice] : r[campo];
  if (!alvo.includes(find)) {
    throw new Error(`tecId ${tecId}: texto esperado "${find}" nao encontrado em ${campo}${campo==='alternativas'?'['+indice+']':''} -- abortando para nao aplicar cega`);
  }
  const novo = alvo.replace(find, replace);
  if (campo === 'alternativas') r.alternativas[indice] = novo;
  else r[campo] = novo;
  r.limpeza_aplicada.push({ campo: campo + (campo==='alternativas' ? `[${indice}]` : ''), tipo: motivo, de: find, para: replace });
}

// --- Passo A: 9 correcoes pontuais de artefato de OCR/parser (identificadas
// individualmente durante a auditoria da Fase 2, uma a uma, com verificacao
// de que o texto-alvo exato existe antes de aplicar) -----------------------

// caderno 394 -- algarismos romanos II/III grafados "Il"/"llI" pelo OCR
aplica(2718877, 'enunciado', null, 'Il. no âmbito da família', 'II. no âmbito da família', 'OCR: numeral romano II lido como "Il"');
aplica(2718877, 'alternativas', 0, 'Il e IlI, apenas.', 'II e III, apenas.', 'OCR: numerais romanos II/III lidos como "Il"/"IlI"');
aplica(2718877, 'alternativas', 1, 'I e ll, apenas.', 'I e II, apenas.', 'OCR: numeral romano II lido como "ll"');
aplica(2718877, 'alternativas', 2, 'I e lll, apenas.', 'I e III, apenas.', 'OCR: numeral romano III lido como "lll"');
aplica(2718877, 'alternativas', 3, 'I, Il e llI.', 'I, II e III.', 'OCR: numerais romanos II/III lidos como "Il"/"llI"');

// caderno 238 -- prefixo "( )" residual de formatacao em todas as alternativas
aplica(3453660, 'alternativas', 0, '( ) moral', 'moral', 'Parser: prefixo "( )" residual de checkbox do PDF');
aplica(3453660, 'alternativas', 1, '( ) física', 'física', 'Parser: prefixo "( )" residual de checkbox do PDF');
aplica(3453660, 'alternativas', 2, '( ) psicológica', 'psicológica', 'Parser: prefixo "( )" residual de checkbox do PDF');
aplica(3453660, 'alternativas', 3, '( ) patrimonial', 'patrimonial', 'Parser: prefixo "( )" residual de checkbox do PDF');

// caderno 319 -- digito solto "8" (residuo de rodape/numeracao) no fim da alternativa
aplica(3392823, 'alternativas', 0, 'Violência psicológica e física. 8', 'Violência psicológica e física.', 'Parser: digito solto "8" residual de rodape/paginacao');

// caderno 917 -- "1.340" faltando o "1" inicial de "11.340"
aplica(579386, 'enunciado', null, 'Lei nº 1.340/2006', 'Lei nº 11.340/2006', 'OCR: digito "1" inicial de "11.340" perdido');

// caderno 872 -- "Artigo 50" (simbolo de grau "º" lido como "0") + espaco solto em "11 .340"
aplica(496087, 'enunciado', null, 'O Artigo 50 da Lei nº 11 .340,', 'O Artigo 5º da Lei nº 11.340,', 'OCR: simbolo de grau "º" lido como "0"; espaco solto antes do ponto em "11.340"');

// caderno 519 -- "Lei Marinha da Penha" (nome da lei distorcido)
aplica(2432000, 'enunciado', null, 'Pela Lei Marinha da Penha,', 'Pela Lei Maria da Penha,', 'OCR/parser: "Maria" lido como "Marinha"');

// caderno 566 -- ano da lei errado "2016" em vez de "2006"
aplica(2180185, 'enunciado', null, 'Lei no 11.340/2016', 'Lei no 11.340/2006', 'OCR: digito do ano "0" lido como "1" (2006 -> 2016)');

// caderno 588 -- "aos recursos economicos" em vez de "ou recursos economicos" (definicao literal de patrimonial)
aplica(2233844, 'enunciado', null, 'bens, valores e direitos aos recursos econômicos', 'bens, valores e direitos ou recursos econômicos', 'OCR: "ou" lido como "aos"');

// caderno 505 -- "Lei no 741" faltando o "10." inicial de "10.741" (alternativa distratora, nao e o gabarito)
aplica(2257406, 'alternativas', 1, 'Lei nº 741, de 01 de outubro de 2003.', 'Lei nº 10.741, de 01 de outubro de 2003.', 'OCR: prefixo "10." de "10.741" perdido');

console.log('9 correcoes pontuais de OCR/parser aplicadas com sucesso (verificadas uma a uma antes de cada substituicao).');

// --- Passo B: limpeza generica do campo `topico` contaminado com rodape/
// cabecalho de PDF (mesmo padrao em todos os casos: timestamp + nome do
// caderno + contagem de questoes, sempre colado ANTES do texto real do topico)
const PADRAO_TOPICO_CONTAMINADO = /\d{2}\/\d{2}\/\d{4},?\s*\d{2}:\d{2}\s+Caderno Lei Maria da Penha\s*-\s*\d+\s*QUEST[ÕO]ES\s*/i;
let topicosLimpos = 0;
for (const r of registros) {
  if (PADRAO_TOPICO_CONTAMINADO.test(r.topico)) {
    const antes = r.topico;
    r.topico = r.topico.replace(PADRAO_TOPICO_CONTAMINADO, '').trim();
    r.limpeza_aplicada.push({ campo: 'topico', tipo: 'Parser: rodape do PDF (timestamp + nome do caderno + contagem de questoes) vazado no campo topico', de: antes, para: r.topico });
    topicosLimpos++;
  }
}
console.log(`Campo "topico" limpo em ${topicosLimpos} registros (esperado 12).`);

// --- Passo C: reverificacao final -- confirma que NENHUM padrao de
// contaminacao sobrevive em enunciado/alternativas/topico apos a limpeza ---
const PADROES_CONTAMINACAO = [
  /\d{2}\/\d{2}\/\d{4},?\s*\d{2}:\d{2}/,
  /Caderno Lei Maria da Penha(\s*-\s*\d+\s*QUEST[ÕO]ES)?/i,
  /www\.tecconcursos\.com\.br\/(questoes|s)\/\S+/i,
  /Ordena[çc][ãa]o:\s*Por\s*Mat[ée]ria/i,
];
let sobrouContaminacao = 0;
for (const r of registros) {
  const campos = [r.enunciado, r.topico, ...r.alternativas];
  for (const c of campos) if (PADROES_CONTAMINACAO.some(re => re.test(c))) sobrouContaminacao++;
}
console.log(`Contaminacao residual apos limpeza: ${sobrouContaminacao} (esperado 0).`);

const registrosComLimpeza = registros.filter(r => r.limpeza_aplicada.length > 0);
console.log(`\nRegistros que precisaram de alguma limpeza: ${registrosComLimpeza.length} de ${registros.length}`);

fs.writeFileSync(`${SCRATCH}/lote2_fase3a_candidatas_limpas_521.json`, JSON.stringify(registros, null, 2), 'utf8');
console.log('\nGravado: lote2_fase3a_candidatas_limpas_521.json');
