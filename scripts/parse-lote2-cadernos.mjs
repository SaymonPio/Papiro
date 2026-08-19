#!/usr/bin/env node
// Parser corrigido dos 4 cadernos TEC Concursos (201-1000) da Lei Maria da
// Penha, direto do texto extraido dos PDFs originais (pdftotext -layout).
// So leitura/geracao de arquivos locais -- nunca toca o Supabase.
//
// Correcao central em relacao ao inventario antigo
// (supabase/inventario_lei_maria_penha_tec_pdfs.csv): a estrutura real do
// PDF tem o cabecalho (URL/TEC ID, depois banca/concurso/ano, depois topico)
// ANTES do enunciado de cada questao -- nao depois. O parser antigo
// aparentemente pareava o enunciado com o cabecalho SEGUINTE (do bloco de
// baixo), causando o deslocamento de -1 posicao documentado em
// supabase/lote_1_importacao_lei_maria_penha_tec.md. Este parser sempre
// associa cada questao ao cabecalho imediatamente ACIMA dela.
//
// Uso: node scripts/parse-lote2-cadernos.mjs

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const TXT_DIR = path.join(ROOT, 'supabase/_lote2_txt');

const FILES = [
  { arquivo: 'Caderno Lei Maria da Penha - 201 ao 400.pdf', txt: 'caderno_201 ao 400.txt' },
  { arquivo: 'Caderno Lei Maria da Penha - 401 ao 600.pdf', txt: 'caderno_401 ao 600.txt' },
  { arquivo: 'Caderno Lei Maria da Penha - 601 ao 800.pdf', txt: 'caderno_601 ao 800.txt' },
  { arquivo: 'Caderno Lei Maria da Penha - 800 ao 1000.pdf', txt: 'caderno_800 ao 1000.txt' },
];

const NOISE_PATTERNS = [
  /^\d{2}\/\d{2}\/\d{4},\s*\d{2}:\d{2}\s+Caderno Lei Maria da Penha/,
  /^\s*Lei Maria da Penha - \d+ QUEST[ÕO]ES\s*$/,
  /^\s*https:\/\/www\.tecconcursos\.com\.br\/s\/\S+\s*$/,
  /^\s*Ordena[çc][ãa]o: Por Mat[ée]ria e Assunto\s*$/,
  /^https:\/\/www\.tecconcursos\.com\.br\/questoes\/cadernos\/\d+\/imprimir/,
];

function stripNoise(raw) {
  return raw
    .split('\n')
    .filter(line => !NOISE_PATTERNS.some(re => re.test(line)))
    .join('\n');
}

function splitGabarito(text) {
  const idx = text.search(/^Gabarito\s*$/m);
  if (idx < 0) throw new Error('Secao Gabarito nao encontrada');
  return { corpo: text.slice(0, idx), gabaritoTexto: text.slice(idx) };
}

function parseGabarito(gabaritoTexto) {
  const map = new Map();
  const re = /(\d+)\)\s+(Certo|Errado|[A-E])\b/g;
  let m;
  while ((m = re.exec(gabaritoTexto))) {
    map.set(parseInt(m[1], 10), m[2]);
  }
  return map;
}

function parseBlocks(corpo) {
  const lines = corpo.split('\n');
  const headerIdx = [];
  for (let i = 0; i < lines.length; i++) {
    if (/^www\.tecconcursos\.com\.br\/questoes\/(\d+)\s*$/.test(lines[i])) {
      headerIdx.push(i);
    }
  }

  const questoes = [];
  const problemas = [];

  for (let b = 0; b < headerIdx.length; b++) {
    const start = headerIdx[b];
    const end = b + 1 < headerIdx.length ? headerIdx[b + 1] : lines.length;
    const block = lines.slice(start, end);

    const tecId = parseInt(block[0].match(/questoes\/(\d+)/)[1], 10);

    let i = 1;
    while (i < block.length && block[i].trim() === '') i++;
    if (i >= block.length) { problemas.push({ tecId, motivo: 'bloco vazio apos cabecalho' }); continue; }
    const bancaLinha = block[i].trim();
    i++;

    // Zero ou mais linhas de topico, possivelmente separadas por linhas em
    // branco extras (formatacao inconsistente do PDF entre bancas) --
    // acumula tudo que nao for o marcador "NNN)" nem esteja em branco.
    let topico = '';
    while (i < block.length && !/^\d+\)/.test(block[i].trim())) {
      const t = block[i].trim();
      if (t !== '') topico += (topico ? ' ' : '') + t;
      i++;
    }

    if (i >= block.length) {
      problemas.push({ tecId, motivo: 'marcador de questao "NNN)" nao encontrado apos topico', bancaLinha, topico });
      continue;
    }
    const qMatch = block[i].trim().match(/^(\d+)\)\s*(.*)$/);
    const cadernoNumero = parseInt(qMatch[1], 10);
    let enunciado = qMatch[2];
    i++;

    const isAltLine = (l) => /^\s{4,}([a-eA-E])\)\s?(.*)$/.test(l) || /^\s{4,}(Certo|Errado)\s*$/.test(l);

    while (i < block.length && !isAltLine(block[i])) {
      const t = block[i].trim();
      if (t !== '') enunciado += (enunciado.endsWith(' ') || enunciado === '' ? '' : ' ') + t;
      i++;
    }
    enunciado = enunciado.trim();

    const alternativas = [];
    while (i < block.length) {
      const l = block[i];
      const altM = l.match(/^\s{4,}([a-eA-E])\)\s?(.*)$/);
      const ceM = l.match(/^\s{4,}(Certo|Errado)\s*$/);
      if (altM) {
        alternativas.push({ letra: altM[1].toLowerCase(), texto: altM[2].trim() });
        i++;
      } else if (ceM) {
        alternativas.push({ letra: null, texto: ceM[1] });
        i++;
      } else if (l.trim() === '') {
        i++;
      } else if (alternativas.length > 0) {
        // continuacao (linha indentada sem marcador de letra) da ultima alternativa
        alternativas[alternativas.length - 1].texto += ' ' + l.trim();
        i++;
      } else {
        i++;
      }
    }

    if (alternativas.length === 0) {
      problemas.push({ tecId, cadernoNumero, motivo: 'nenhuma alternativa encontrada', enunciado: enunciado.slice(0, 80) });
      continue;
    }

    const bancaSplit = bancaLinha.split(' - ');
    const banca = bancaSplit[0].trim();
    const concurso = bancaSplit.slice(1).join(' - ').trim();
    const anoMatch = concurso.match(/(\d{4})\s*$/);
    const ano = anoMatch ? parseInt(anoMatch[1], 10) : null;

    questoes.push({
      cadernoNumero, tecId, banca, concurso, ano, topico, enunciado,
      alternativas: alternativas.map(a => a.texto.replace(/\s+/g, ' ').trim()),
    });
  }

  return { questoes, problemas };
}

const allQuestoes = [];
const allProblemas = [];

for (const f of FILES) {
  const raw = fs.readFileSync(path.join(TXT_DIR, f.txt), 'utf8').replace(/\r\n/g, '\n').replace(/\x0C/g, '');
  const semRuido = stripNoise(raw);
  const { corpo, gabaritoTexto } = splitGabarito(semRuido);
  const gabaritoMap = parseGabarito(gabaritoTexto);
  const { questoes, problemas } = parseBlocks(corpo);

  for (const q of questoes) {
    q.arquivoOrigem = f.arquivo;
    q.gabarito = gabaritoMap.has(q.cadernoNumero) ? gabaritoMap.get(q.cadernoNumero) : null;
    if (q.gabarito === null) {
      allProblemas.push({ ...q, motivo: 'gabarito nao encontrado na grade para este caderno_numero' });
    } else {
      allQuestoes.push(q);
    }
  }
  for (const p of problemas) {
    allProblemas.push({ ...p, arquivoOrigem: f.arquivo });
  }

  console.log(`${f.txt}: ${questoes.length} blocos parseados, gabarito com ${gabaritoMap.size} entradas`);
}

allQuestoes.sort((a, b) => a.cadernoNumero - b.cadernoNumero);

const OUT_PATH = path.join(ROOT, 'supabase/inventario_lei_maria_penha_tec_pdfs_v2.json');
fs.writeFileSync(OUT_PATH, JSON.stringify({ questoes: allQuestoes, problemas: allProblemas }, null, 2), 'utf8');

console.log(`\nTotal questoes parseadas com sucesso: ${allQuestoes.length}`);
console.log(`Total problemas/blocos incompletos: ${allProblemas.length}`);
console.log(`Escrito: ${path.relative(ROOT, OUT_PATH)}`);
