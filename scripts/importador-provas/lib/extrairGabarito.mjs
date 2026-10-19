// Extração do gabarito oficial a partir de texto já extraído (PDF textual
// ou .txt). Suporta três formatos, de forma genérica (sem nenhum ajuste
// específico de banca):
//   (a) lista linear, um "número -> resultado" por linha
//       ("1 - A", "1. A", "1) A", "2: ANULADA"...);
//   (b) tabela de N colunas repetidas na mesma linha, separadas por
//       espaço/tabulação, sem separador explícito entre número e letra
//       ("01\tD\t41\tA" — ACAFE/PC-SC 2008). Um par "número [separador
//       opcional] letra" é reconhecido onde quer que apareça na linha, e
//       TODOS os pares de uma linha são extraídos — generaliza para
//       qualquer número de colunas automaticamente.
//   (c) grade posicional: uma linha só com números, seguida da linha
//       imediatamente seguinte só com letras/"X", alinhadas por posição
//       ("1 2 3 ... 40" / "e c d ... x") — FEPESE/PMBC 2014. Pode haver
//       VÁRIOS blocos no mesmo documento (um gabarito cobrindo mais de
//       um cargo); cada bloco é identificado pela linha-rótulo
//       imediatamente anterior à linha de números (quando existir) e a
//       verificação de número duplicado é escopada POR BLOCO — dois
//       cargos diferentes podem legitimamente ter ambos uma "questão 1".
//
// Regra inegociável do produto: nunca inferir gabarito quando a linha/
// bloco for ambíguo. Qualquer linha sem nenhum par reconhecível vira
// "naoReconhecidas"; se a quantidade de números e de respostas de um
// bloco posicional não bater, o bloco inteiro é descartado (nunca
// pareado por aproximação) e suas linhas voltam a "naoReconhecidas".

// "*" no lugar da letra = anulada (legenda "(*) Questão anulada" — checado
// num gabarito real: Fundatec/Polícia Penal RS 2026, "17 - *").
const PAR_NUMERO_RESULTADO = /(\d{1,3})[ \t]*[-.):]?[ \t]*(ANULAD[AO]\b|DESERTA\b|[A-E]\b|\*(?=\s|$))/gi;

// Linha que é SÓ pares número-resultado (>= 2), nada além de espaço entre
// eles — uma linha de grade tabular ("01 - B 02 - E 03 - A"), nunca prosa
// que por acaso contém um "2015) e".
function linhaEhGradeTabular(linha, pares) {
  if (pares.length < 2) return false;
  let resto = linha;
  for (const par of pares) resto = resto.replace(par[0], " ");
  return resto.trim().length === 0;
}

function interpretarObservacao(resto) {
  const texto = resto.trim();
  if (texto.length === 0) return { alterada: false, observacao: null };
  const alterada = /alterad[ao]/i.test(texto);
  return { alterada, observacao: texto.replace(/^[-–—(),:\s]+/, "").trim() || null };
}

function tokensDaLinha(linha) {
  return linha.trim().split(/\s+/).filter(Boolean);
}

function linhaEhSomenteNumeros(linha) {
  const tokens = tokensDaLinha(linha);
  return tokens.length >= 2 && tokens.every((t) => /^\d{1,3}$/.test(t));
}

function linhaEhSomenteRespostas(linha, quantidadeEsperada) {
  const tokens = tokensDaLinha(linha);
  if (tokens.length !== quantidadeEsperada) return false;
  // "*" = anulada, como na grade tabular (legenda "*Questão anulada" —
  // checado num gabarito real: Fundatec/GM Porto Alegre 2025, faixas 21–40
  // e 41–60 com "*" eram descartadas inteiras).
  return tokens.every((t) => /^(?:[A-E]|X|\*)$/i.test(t));
}

// Varre linha a linha procurando pares (linha-de-números, linha-de-
// respostas-na-posição-seguinte). Quando uma linha "rótulo" aparece
// imediatamente antes de uma linha de números (e não é ela mesma uma
// linha de números/respostas), ela nomeia o bloco atual. Devolve também
// o conjunto de índices de linha consumidos, para o scanner linear não
// reprocessá-los.
function extrairBlocosPosicionais(linhas) {
  const entradas = [];
  const indicesConsumidos = new Set();
  let blocoAtual = null;

  for (let i = 0; i < linhas.length; i++) {
    // Linha de respostas já pareada nunca é rótulo do bloco seguinte
    // (grade de várias faixas: "1..20"/letras, "21..40"/letras — checado
    // num gabarito real: FGV/PCPR 2026; sem isto as faixas 2..5 de cada
    // cargo ficavam "rotuladas" pela linha de letras anterior).
    if (indicesConsumidos.has(i)) continue;
    const linha = linhas[i].trim();
    if (linha.length === 0) continue;

    if (linhaEhSomenteNumeros(linha)) {
      const numeros = tokensDaLinha(linha).map(Number);
      const proximaLinha = linhas[i + 1] ?? "";
      if (linhaEhSomenteRespostas(proximaLinha, numeros.length)) {
        const respostas = tokensDaLinha(proximaLinha);
        const numerosVistosNoBloco = new Set();
        for (let j = 0; j < numeros.length; j++) {
          const numero = numeros[j];
          const letra = respostas[j].toUpperCase();
          const anulada = letra === "X" || letra === "*";
          const duplicadoNoBloco = numerosVistosNoBloco.has(numero);
          numerosVistosNoBloco.add(numero);
          entradas.push({
            numero,
            alternativa_correta: anulada ? null : letra,
            anulada,
            alterada: false,
            observacao: null,
            bloco: blocoAtual,
            status: duplicadoNoBloco ? "revisao_manual" : "ok",
          });
        }
        indicesConsumidos.add(i);
        indicesConsumidos.add(i + 1);
        continue;
      }
      // Linha só de números sem uma linha de respostas correspondente
      // (quantidade não bate, ou a linha seguinte não é só letras/X) —
      // nunca pareada por aproximação; some para naoReconhecidas no
      // scanner linear, revisão manual implícita.
    } else {
      // Linha "rótulo" candidata a nomear o próximo bloco: só conta
      // quando a PRÓXIMA linha não-vazia é mesmo uma linha de números
      // (evita marcar qualquer texto solto como rótulo de bloco).
      let k = i + 1;
      while (k < linhas.length && linhas[k].trim().length === 0) k++;
      if (k < linhas.length && linhaEhSomenteNumeros(linhas[k].trim())) {
        blocoAtual = linha;
      }
    }
  }

  return { entradas, indicesConsumidos };
}

// Modo estrito (documentos de RETIFICAÇÃO, que alteram respostas): só
// vale par em linha de grade ou par que ABRE a linha ("15 * Língua
// Portuguesa", "QUESTÃO: 15 - ANULADA"), com letra maiúscula — prosa
// como "...em 2015) e..." nunca vira uma alteração de gabarito.
const PAR_NO_INICIO_DA_LINHA = /^(?:quest(?:ão|ao)[ \t]*(?:n[º°o.]*)?[ \t]*:?[ \t]*)?\d{1,3}\b/i;

function parAceitoNoModoEstrito(linha, par, ehGrade) {
  if (ehGrade) return true;
  if (par.index !== linha.search(/\d/) || !PAR_NO_INICIO_DA_LINHA.test(linha)) return false;
  return /^(?:[A-E]|\*|ANULAD[AO]|DESERTA)$/.test(par[2]);
}

// "Anula-se a Questão nº 15", "Altera-se o gabarito da questão 12" —
// anúncio em prosa que precisa ser confirmado por uma entrada estruturada
// do mesmo documento (ver retificacoes.mjs).
const MENCAO_ALTERACAO = /\b(anul|alter|retific)[a-zà-ú-]*\b[^.\n]{0,60}?\bquest(?:ão|ao)[ \t]*(?:n[º°o.]*)?[ \t]*(\d{1,3})\b/gi;

export function extrairMencoesDeAlteracao(texto) {
  return [...(texto ?? "").matchAll(MENCAO_ALTERACAO)].map((m) => ({ numero: Number(m[2]), acao: m[1].toLowerCase() === "anul" ? "anula" : "altera" }));
}

export function extrairGabaritoDoTexto(texto, opcoes = {}) {
  const estrito = opcoes.estrito === true;
  const linhas = (texto ?? "").split(/\r?\n/);

  const { entradas: entradasPosicionais, indicesConsumidos } = extrairBlocosPosicionais(linhas);

  const gabaritos = [...entradasPosicionais];
  const naoReconhecidas = [];

  // Grade tabular com vários cargos (checado num gabarito real: Fundatec/
  // Polícia Penal RS 2026 — "24 - Policial Penal" seguido de linhas
  // "01 - B 02 - E ..."): cada sequência de linhas de grade consecutivas
  // é uma "corrida", rotulada pela linha não-vazia imediatamente anterior
  // — mesmo papel do rótulo da grade posicional. O rótulo só vira bloco
  // quando algum número se repete entre corridas diferentes (vários
  // cargos no mesmo documento); com um cargo só, tudo continua bloco=null
  // exatamente como antes (uma quebra de página no meio da grade nunca
  // inventa um bloco novo).
  const corridas = [];
  let corridaAtual = null;
  let linhaAnterior = null;

  for (let i = 0; i < linhas.length; i++) {
    if (indicesConsumidos.has(i)) continue;
    const linha = linhas[i].trim();
    if (linha.length === 0) continue;

    const todosOsPares = [...linha.matchAll(PAR_NUMERO_RESULTADO)];
    const ehGrade = linhaEhGradeTabular(linha, todosOsPares);
    const pares = estrito ? todosOsPares.filter((par) => parAceitoNoModoEstrito(linha, par, ehGrade)) : todosOsPares;
    if (ehGrade && !linhaAnterior?.ehGrade) corridas.push((corridaAtual = { rotulo: linhaAnterior?.texto ?? null, entradas: [] }));
    if (!ehGrade) corridaAtual = null;
    linhaAnterior = { texto: linha, ehGrade };

    if (pares.length === 0) {
      naoReconhecidas.push(linha);
      continue;
    }

    for (const par of pares) {
      const numero = Number(par[1]);
      const resultado = par[2].toUpperCase();
      const anulada = resultado === "ANULADA" || resultado === "ANULADO" || resultado === "DESERTA" || resultado === "*";
      const alternativaCorreta = anulada ? null : resultado;

      // Observação/"alterada" só têm sentido numa linha com UM único par
      // (formato linear "N - LETRA (observação)"): numa linha tabular com
      // vários pares, o texto entre um par e o próximo já É o próximo
      // par, não uma observação de ninguém.
      let alterada = false;
      let observacao = null;
      if (pares.length === 1) {
        const resto = linha.slice(par.index + par[0].length);
        ({ alterada, observacao } = interpretarObservacao(resto));
      }

      const entrada = {
        numero,
        alternativa_correta: alternativaCorreta,
        anulada,
        alterada,
        observacao,
        bloco: null,
        status: "ok",
      };
      gabaritos.push(entrada);
      if (ehGrade) corridaAtual.entradas.push(entrada);
    }
  }

  const corridaDoNumero = new Map();
  let numerosRepetemEntreCorridas = false;
  for (const [indice, corrida] of corridas.entries()) {
    for (const entrada of corrida.entradas) {
      if (corridaDoNumero.has(entrada.numero) && corridaDoNumero.get(entrada.numero) !== indice) numerosRepetemEntreCorridas = true;
      corridaDoNumero.set(entrada.numero, indice);
    }
  }
  if (numerosRepetemEntreCorridas) {
    for (const [indice, corrida] of corridas.entries()) {
      for (const entrada of corrida.entradas) entrada.bloco = corrida.rotulo ?? `grade tabular ${indice + 1}`;
    }
  }

  // Duplicidade escopada por bloco (chave = bloco + número): dois blocos
  // diferentes (ex.: cargos distintos no mesmo gabarito) podem
  // legitimamente ter ambos uma "questão 1" — isso nunca é um erro. O
  // formato linear/tabular de um cargo só tem bloco=null, preservando o
  // comportamento de antes (chave vira só o número).
  const vistos = new Set();
  for (const item of gabaritos) {
    if (item.status === "revisao_manual") continue; // já marcado (duplicado dentro do próprio bloco posicional)
    const chave = `${item.bloco ?? ""} ${item.numero}`;
    if (vistos.has(chave)) {
      item.status = "revisao_manual";
      item.observacao = [item.observacao, "numero de gabarito duplicado neste documento/bloco"].filter(Boolean).join(" — ");
    }
    vistos.add(chave);
  }

  return { gabaritos, naoReconhecidas };
}
