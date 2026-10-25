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

// Cabeçalho de grade com UMA célula impressa errada (checado num gabarito
// real: Fundatec/PC-RS 2025 Delegado, "61 ... 71 72 33 74 ... 80" nos dois
// editais e nos 4 tipos): o "33" viraria uma segunda resposta da questão
// 33 e a 73 ficaria sem gabarito. Só corrige quando é inequívoco — todas
// as outras células formam uma sequência +1 que determina o número da
// posição, há exatamente uma célula fora dela, e o número deduzido ainda
// não tem resposta no bloco. Fora disso, nada é deduzido. A célula
// corrigida leva o valor impresso e o deduzido (relatório).
function corrigirCelulaUnicaDaSequencia(numeros, numerosDoBloco) {
  if (numeros.length < 3) return null;
  const inicios = new Map();
  for (const [j, n] of numeros.entries()) inicios.set(n - j, (inicios.get(n - j) ?? 0) + 1);
  const [inicio, quantos] = [...inicios].sort((a, b) => b[1] - a[1])[0];
  if (quantos !== numeros.length - 1) return null;
  const j = numeros.findIndex((n, k) => n - k !== inicio);
  const deduzido = inicio + j;
  if (deduzido < 1 || numerosDoBloco.has(deduzido)) return null;
  return { posicao: j, impresso: numeros[j], deduzido };
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
  const numerosPorBloco = new Map();

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
        const numerosDoBloco = numerosPorBloco.get(blocoAtual) ?? new Set();
        numerosPorBloco.set(blocoAtual, numerosDoBloco);
        const correcao = corrigirCelulaUnicaDaSequencia(numeros, numerosDoBloco);
        const numerosVistosNoBloco = new Set();
        for (let j = 0; j < numeros.length; j++) {
          const numero = correcao?.posicao === j ? correcao.deduzido : numeros[j];
          const letra = respostas[j].toUpperCase();
          const anulada = letra === "X" || letra === "*";
          const duplicadoNoBloco = numerosVistosNoBloco.has(numero);
          numerosVistosNoBloco.add(numero);
          numerosDoBloco.add(numero);
          entradas.push({
            numero,
            alternativa_correta: anulada ? null : letra,
            anulada,
            alterada: false,
            observacao: correcao?.posicao === j ? `número impresso na grade "${correcao.impresso}"; deduzido ${correcao.deduzido} pela posição na sequência` : null,
            ...(correcao?.posicao === j ? { numero_deduzido: { impresso: correcao.impresso, deduzido: correcao.deduzido } } : {}),
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

function parAbreALinha(linha, par) {
  return par.index === linha.search(/\d/) && PAR_NO_INICIO_DA_LINHA.test(linha);
}

function parAceitoNoModoEstrito(linha, par, ehGrade) {
  if (ehGrade) return true;
  if (!parAbreALinha(linha, par)) return false;
  return /^(?:[A-E]|\*|ANULAD[AO]|DESERTA)$/.test(par[2]);
}

// Intervalo em prosa ("de 09 a 11/12/2025", "questões 1 a 10", "itens 2 e
// 3"): "a"/"e" minúsculo, sem separador entre número e letra, seguido de
// outro número — preposição/conjunção, nunca resposta.
function parEhIntervalo(linha, par) {
  if (!/^[ae]$/.test(par[2]) || /[-.):]/.test(par[0])) return false;
  return /^[ \t]+\d/.test(linha.slice(par.index + par[0].length));
}

// Modo normal (gabarito base): fora de linha de grade, par só vale com
// CONTEXTO ESTRUTURAL — abrindo a linha (lista "N - LETRA") ou numa linha em
// que os pares são a maior parte do conteúdo (grade com rótulo). Um par
// isolado no meio de prosa administrativa nunca é resposta (checado num
// gabarito real: Fundatec/GM Sant'Ana do Livramento 2025, "recursos
// interpostos ... durante o período de 09 a 11/12/2025" virava "Q9 = A", e
// a resposta verdadeira da grade ficava em conflito).
const PROPORCAO_MINIMA_PARES_NA_LINHA = 0.5;

function paresComContextoEstrutural(linha, pares, ehGrade) {
  const candidatos = pares.filter((par) => !parEhIntervalo(linha, par));
  if (ehGrade) return candidatos;
  const conteudo = linha.replace(/\s+/g, "").length;
  const dosPares = candidatos.reduce((soma, par) => soma + par[0].replace(/\s+/g, "").length, 0);
  if (candidatos.length >= 2 && dosPares >= conteudo * PROPORCAO_MINIMA_PARES_NA_LINHA) return candidatos;
  return candidatos.filter((par) => parAbreALinha(linha, par));
}

// Justificativas de recursos (modo estrito + secoesDeCargo): o documento é dividido em
// seções "CARGO(S): A, B, C" (lista que pode continuar na linha seguinte
// quando termina em vírgula) e cada decisão é uma linha "QUESTÃO: N -
// <decisão>" — MANTIDA (confirma a letra), ALTERA ... DE 'X' PARA 'Y' ou
// ANULADA. O MESMO número aparece em seções de cargos diferentes (checado
// num documento real: Fundatec, justificativas com a mesma questão anulada
// em duas seções e outra anulada só na seção de um cargo diferente), então
// toda decisão leva o escopo da seção (bloco + lista de cargos) e nada
// fora de uma decisão estruturada vale dentro da seção. Decisão que não
// se reconhece não é ignorada: vira revisão daquela questão.
const CABECALHO_CARGOS = /^CARGO\(S\)[ \t]*:[ \t]*(.*)$/i;
const DECISAO_JUSTIFICATIVA = /^quest(?:ão|ao)[ \t]*(?:n[º°o.]*)?[ \t]*:?[ \t]*(\d{1,3})[ \t]*[-–][ \t]*(.*)$/i;
const ASPA = "['’‘\"“”]?";
const DECISAO_MANTIDA = new RegExp(`^MANTID[AO][ \\t]+(?:a[ \\t]+)?alternativa[ \\t]+${ASPA}([A-E])${ASPA}(?![A-Za-z])`, "i");
const DECISAO_ALTERA = new RegExp(`^ALTERA[A-Z]*[ \\t]+(?:O[ \\t]+)?GABARITO[ \\t]+DE[ \\t]+(?:ALTERNATIVA[ \\t]+)?${ASPA}([A-E])${ASPA}[ \\t]+PARA[ \\t]+(?:A[ \\t]+)?(?:ALTERNATIVA[ \\t]+)?${ASPA}([A-E])${ASPA}(?![A-Za-z])`, "i");
const DECISAO_ANULADA = /^ANULAD[AO]\b/i;

function decisaoDeJustificativa(numero, texto, secao) {
  const escopo = { bloco: secao.rotulo, cargos: secao.cargos };
  const base = { numero, alterada: false, observacao: null, status: "ok", ...escopo };
  let m;
  if (DECISAO_ANULADA.test(texto)) return { ...base, alternativa_correta: null, anulada: true, decisao: "anulada" };
  if ((m = texto.match(DECISAO_MANTIDA))) return { ...base, alternativa_correta: m[1].toUpperCase(), anulada: false, decisao: "mantida" };
  if ((m = texto.match(DECISAO_ALTERA))) return { ...base, alternativa_correta: m[2].toUpperCase(), anulada: false, alterada: true, decisao: "alterada", de: m[1].toUpperCase() };
  return { ...base, alternativa_correta: null, anulada: false, status: "revisao_manual", decisao: "indeterminada", observacao: `decisão de justificativa não reconhecida: "${texto.slice(0, 60)}"` };
}

// "Anula-se a Questão nº 15", "Altera-se o gabarito da questão 12" —
// anúncio em prosa que precisa ser confirmado por uma entrada estruturada
// do mesmo documento (ver retificacoes.mjs).
const MENCAO_ALTERACAO = /\b(anul|alter|retific)[a-zà-ú-]*\b[^.\n]{0,60}?\bquest(?:ão|ao)[ \t]*(?:n[º°o.]*)?[ \t]*(\d{1,3})\b/gi;

export function extrairMencoesDeAlteracao(texto) {
  return [...(texto ?? "").matchAll(MENCAO_ALTERACAO)].map((m) => ({ numero: Number(m[2]), acao: m[1].toLowerCase() === "anul" ? "anula" : "altera" }));
}

// secoesDeCargo: só quando o manifesto declara a retificação como
// justificativa de recursos POR CARGO (gabaritos.mjs) — documentos sem essa
// declaração são lidos exatamente como antes, mesmo que tenham seções.
export function extrairGabaritoDoTexto(texto, opcoes = {}) {
  const estrito = opcoes.estrito === true;
  const secoesDeCargo = estrito && opcoes.secoesDeCargo === true;
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
  let secaoDeCargos = null;

  for (let i = 0; i < linhas.length; i++) {
    if (indicesConsumidos.has(i)) continue;
    const linha = linhas[i].trim();
    if (linha.length === 0) continue;

    if (secoesDeCargo) {
      const cabecalho = linha.match(CABECALHO_CARGOS);
      if (cabecalho) {
        let rotulo = cabecalho[1].trim();
        while (rotulo.endsWith(",") && i + 1 < linhas.length && linhas[i + 1].trim()) rotulo = `${rotulo} ${linhas[++i].trim()}`;
        rotulo = rotulo.replace(/\s+/g, " ").replace(/\s*,\s*/g, ", ").replace(/,$/, "").trim();
        secaoDeCargos = { rotulo, cargos: rotulo.split(",").map((c) => c.trim()).filter(Boolean) };
        corridaAtual = null;
        linhaAnterior = null;
        continue;
      }
      if (secaoDeCargos) {
        const decisao = linha.match(DECISAO_JUSTIFICATIVA);
        if (decisao) gabaritos.push(decisaoDeJustificativa(Number(decisao[1]), decisao[2], secaoDeCargos));
        else naoReconhecidas.push(linha);
        continue;
      }
    }

    const todosOsPares = [...linha.matchAll(PAR_NUMERO_RESULTADO)];
    const ehGrade = linhaEhGradeTabular(linha, todosOsPares);
    const pares = estrito ? todosOsPares.filter((par) => parAceitoNoModoEstrito(linha, par, ehGrade)) : paresComContextoEstrutural(linha, todosOsPares, ehGrade);
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
  // A mesma resposta repetida no mesmo documento (anulação listada nas
  // justificativas E na grade — "QUESTÃO: 49 - ANULADA" e "49 - *", checado
  // num gabarito real: Fundatec/GM Sant'Ana do Livramento 2025) é UMA
  // entrada; respostas diferentes para o mesmo número continuam conflito.
  const vistos = new Map();
  const repetidasIdenticas = new Set();
  for (const item of gabaritos) {
    if (item.status === "revisao_manual") continue; // já marcado (duplicado dentro do próprio bloco posicional)
    const chave = `${item.bloco ?? ""} ${item.numero}`;
    const anterior = vistos.get(chave);
    if (anterior && anterior.anulada === item.anulada && anterior.alternativa_correta === item.alternativa_correta && !item.numero_deduzido) {
      repetidasIdenticas.add(item);
      continue;
    }
    if (anterior) {
      item.status = "revisao_manual";
      item.observacao = [item.observacao, "numero de gabarito duplicado neste documento/bloco"].filter(Boolean).join(" — ");
    }
    if (!anterior) vistos.set(chave, item);
  }

  return { gabaritos: gabaritos.filter((g) => !repetidasIdenticas.has(g)), naoReconhecidas };
}
