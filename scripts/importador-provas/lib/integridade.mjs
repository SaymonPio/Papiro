// Integridade da extração: checagem INDEPENDENTE depois de extrair, para
// que corrupção de texto nunca passe em silêncio (checado numa prova real:
// Fundatec/GM Sant'Ana do Livramento 2025 — linha de enunciado grudada na
// alternativa E, carimbo de página dentro do texto-base e fórmula perdida
// depois de "f(x) =" passaram por todos os gates).
//
// Duas leituras do mesmo PDF — a linear (ordem do stream de conteúdo) e a
// geométrica (posição X/Y) — são comparadas QUESTÃO A QUESTÃO por conteúdo
// estrutural normalizado (só letras e dígitos: ruído tipográfico, espaço e
// pontuação não contam). Por página não serve: as duas leituras quebram as
// linhas de jeitos diferentes. Mesma linha em outra ordem é explicada pela
// geometria ("reordenada"); linha que existe numa leitura e não na outra,
// ou trecho de questão que muda, é divergência material — a questão vai
// para revisão, nunca é "resolvida" por aproximação.

import { createHash } from "node:crypto";
import { chavesDeLinhasCorridas } from "./extrairQuestoes.mjs";

const normalizar = (texto) => (texto ?? "").normalize("NFKC").toLowerCase().replace(/[^\p{L}\p{N}]+/gu, "");

function multiconjunto(linhas) {
  const contagem = new Map();
  for (const linha of linhas) if (linha) contagem.set(linha, (contagem.get(linha) ?? 0) + 1);
  return contagem;
}

function mesmoMulticonjunto(a, b) {
  if (a.size !== b.size) return false;
  for (const [chave, n] of a) if (b.get(chave) !== n) return false;
  return true;
}

const partesDaQuestao = (q) => [["enunciado", q.enunciado], ...q.alternativas.map((a) => [a.letra, a.texto])];

// Ordem entre as leituras: o cruzamento por conteúdo (compararQuestoes)
// não vê a MESMA sequência de palavras em outra ordem (checado numa prova
// real: Fundatec/PC-RS 2025 Escrivão-Inspetor, P2 TIPO 1 — a frase que
// explica a fórmula saiu, na leitura linear, depois do comando da pergunta,
// e a questão passou como "reordenada", sem problema). Compara a sequência
// de palavras significativas (letras e dígitos; espaço, quebra de linha,
// hífen de quebra e pontuação não contam) da questão inteira — texto-base,
// enunciado e cada alternativa, com a fronteira entre as partes — pela
// maior subsequência comum: palavra que só existe numa leitura (número de
// linha, rodapé) não pesa na ordem; palavra comum às duas que fica fora da
// subsequência comum foi deslocada. Só vale quando as duas leituras
// recuperam substancialmente o mesmo conteúdo — perda de conteúdo é dos
// gates de conteúdo.
const COBERTURA_MINIMA_ORDEM = 0.9;
const PALAVRAS_DO_TRECHO = 12;

const partesComTextoBase = (q) => [...(q.textos_base ?? []).map((t) => [`texto-base ${t.id}`, t.texto]), ...partesDaQuestao(q)];

function palavrasSignificativas(texto) {
  const corrido = (texto ?? "").normalize("NFKC").toLowerCase().replace(/(\p{L})-[ \t]*\n[ \t]*(\p{L})/gu, "$1$2");
  return corrido.match(/[\p{L}\p{N}]+/gu) ?? [];
}

// Número de linha de texto-base no começo da linha ("[01] ...", "01\t...",
// "01" sozinho): uma leitura pode agrupar a coluna de números antes do
// texto (checado numa prova real: Fundatec/IGP-RS 2025, linear com 01..36
// em sequência e só depois as linhas) sem mudar a ordem do texto.
// Dívida conhecida: um número de 1–3 dígitos que abre linha de texto-base
// por ser enumeração real ("1 Primeiro passo") também sai da comparação de
// ordem — em tese pode mascarar a troca de itens enumerados.
const NUMERO_DE_LINHA = /^[ \t]*(?:\[\d{1,3}\]|\d{1,3}(?=[ \t]|$))/gm;

// Fronteira de parte ("§enunciado", "§A"): nunca colide com uma palavra
// (só letras e dígitos), e palavra que muda de parte conta como deslocada.
const sequenciaDaQuestao = (q) =>
  partesComTextoBase(q).flatMap(([rotulo, texto]) => [`§${rotulo}`, ...palavrasSignificativas(rotulo.startsWith("texto-base") ? (texto ?? "").replace(NUMERO_DE_LINHA, "") : texto)]);

// Posições de a e de b que entram na maior subsequência comum (prefixo e
// sufixo iguais saem antes da tabela: questão igual não custa nada).
function subsequenciaComum(a, b) {
  const casadasA = new Uint8Array(a.length);
  const casadasB = new Uint8Array(b.length);
  let inicio = 0;
  while (inicio < a.length && inicio < b.length && a[inicio] === b[inicio]) casadasA[inicio] = casadasB[inicio++] = 1;
  let fimA = a.length;
  let fimB = b.length;
  while (fimA > inicio && fimB > inicio && a[fimA - 1] === b[fimB - 1]) casadasA[--fimA] = casadasB[--fimB] = 1;
  const n = fimA - inicio;
  const m = fimB - inicio;
  if (n === 0 || m === 0) return { casadasA, casadasB };
  const largura = m + 1;
  const tabela = new Uint32Array((n + 1) * largura);
  for (let i = n - 1; i >= 0; i--) {
    for (let j = m - 1; j >= 0; j--) {
      tabela[i * largura + j] = a[inicio + i] === b[inicio + j] ? tabela[(i + 1) * largura + j + 1] + 1 : Math.max(tabela[(i + 1) * largura + j], tabela[i * largura + j + 1]);
    }
  }
  for (let i = 0, j = 0; i < n && j < m; ) {
    if (a[inicio + i] === b[inicio + j]) {
      casadasA[inicio + i++] = 1;
      casadasB[inicio + j++] = 1;
    } else if (tabela[(i + 1) * largura + j] >= tabela[i * largura + j + 1]) i++;
    else j++;
  }
  return { casadasA, casadasB };
}

// As duas leituras têm exatamente as mesmas palavras (só a ordem pode mudar).
export function mesmasPalavras(a, b) {
  return mesmoMulticonjunto(multiconjunto(partesComTextoBase(a).flatMap(([, t]) => palavrasSignificativas(t))), multiconjunto(partesComTextoBase(b).flatMap(([, t]) => palavrasSignificativas(t))));
}

// Assinatura (sha256) do conteúdo de uma questão numa leitura: cada parte
// com o espaço normalizado, na ordem em que a leitura a entregou.
export function assinaturaDaQuestao(q) {
  const partes = partesComTextoBase(q).map(([rotulo, texto]) => [rotulo, (texto ?? "").normalize("NFC").replace(/\s+/g, " ").trim()]);
  return createHash("sha256").update(JSON.stringify(partes), "utf8").digest("hex");
}

// null quando a ordem é a mesma (ou quando o conteúdo diverge demais para
// comparar ordem); senão { deslocadas, cobertura, trecho } — trecho: o
// primeiro bloco de palavras deslocadas, como está na leitura escolhida.
export function divergenciaDeOrdem(escolhida, referencia) {
  const a = sequenciaDaQuestao(escolhida);
  const b = sequenciaDaQuestao(referencia);
  const contagemB = multiconjunto(b);
  let comuns = 0;
  for (const [palavra, n] of multiconjunto(a)) comuns += Math.min(n, contagemB.get(palavra) ?? 0);
  const cobertura = comuns / Math.max(a.length, b.length, 1);
  if (cobertura < COBERTURA_MINIMA_ORDEM) return null;
  const { casadasA, casadasB } = subsequenciaComum(a, b);
  const sobraB = multiconjunto(b.filter((_, j) => !casadasB[j]));
  const deslocadas = [];
  a.forEach((palavra, i) => {
    if (casadasA[i] || !sobraB.get(palavra)) return;
    sobraB.set(palavra, sobraB.get(palavra) - 1);
    deslocadas.push(i);
  });
  if (deslocadas.length === 0) return null;
  const bloco = [];
  for (const i of deslocadas) {
    if (bloco.length > 0 && i !== bloco.at(-1) + 1) break;
    bloco.push(i);
  }
  const trecho = bloco
    .slice(0, PALAVRAS_DO_TRECHO)
    .map((i) => (a[i].startsWith("§") ? `[${a[i].slice(1)}]` : a[i]))
    .join(" ");
  return { deslocadas: deslocadas.length, cobertura: Math.round(cobertura * 1000) / 1000, trecho: bloco.length > PALAVRAS_DO_TRECHO ? `${trecho} …` : trecho };
}

// Por questão, entre a leitura ESCOLHIDA e a outra leitura do mesmo PDF:
// cada parte (enunciado e cada alternativa) precisa ter o mesmo conteúdo
// normalizado. Quando difere, a janela da questão com as vizinhas decide:
// as mesmas linhas em outra ordem = a outra leitura só segue a ordem do
// stream ("reordenada", explicada pela geometria); qualquer outra
// diferença = "divergente". "ordem": a divergência de ordem das palavras
// da questão, texto-base incluído (divergenciaDeOrdem), ou null.
export function compararQuestoes(escolhidas, outras) {
  const porNumero = new Map(outras.map((q) => [q.numero_original, q]));
  const indice = new Map(escolhidas.map((q, i) => [q.numero_original, i]));
  const linhasDe = (q) => (q ? partesDaQuestao(q).flatMap(([, t]) => (t ?? "").split("\n")).map(normalizar).filter(Boolean) : []);
  const resultado = new Map();
  for (const q of escolhidas) {
    const outra = porNumero.get(q.numero_original);
    if (!outra) {
      resultado.set(q.numero_original, { tipo: "divergente", partes: ["questão ausente na outra leitura"], ordem: null });
      continue;
    }
    const diferentes = partesDaQuestao(q)
      .filter(([rotulo, texto]) => normalizar(texto) !== normalizar(partesDaQuestao(outra).find(([r]) => r === rotulo)?.[1]))
      .map(([rotulo]) => rotulo);
    const ordem = divergenciaDeOrdem(q, outra);
    if (diferentes.length === 0) {
      resultado.set(q.numero_original, { tipo: "igual", partes: [], ordem });
      continue;
    }
    const i = indice.get(q.numero_original);
    const janela = [escolhidas[i - 1], q, escolhidas[i + 1]].filter(Boolean);
    const janelaOutra = janela.map((x) => porNumero.get(x.numero_original));
    const reordenada = janelaOutra.every(Boolean) && mesmoMulticonjunto(multiconjunto(janela.flatMap(linhasDe)), multiconjunto(janelaOutra.flatMap(linhasDe)));
    resultado.set(q.numero_original, { tipo: reordenada ? "reordenada" : "divergente", partes: diferentes, ordem });
  }
  return resultado;
}

// Fragmentos de margem (cabeçalho/rodapé) do documento: as linhas corridas
// pelo MESMO critério da remoção (extrairQuestoes.mjs — metade das páginas
// ou extremo de páginas consecutivas; "Leia o texto a seguir:" abrindo
// algumas páginas não é rodapé) e os carimbos de data e hora da borda da
// página. Achados DENTRO de uma questão = lixo de página que escapou.
const LINHAS_BORDA = 4;
const TAMANHO_MINIMO_FRAGMENTO = 6; // letras, sem os números
const DATA_HORA = /\d{1,2}\/\d{1,2}\/\d{2,4}[ \t]+\d{1,2}:\d{2}(?::\d{2})?/g;

// Cabeçalho de páginas ALTERNADAS (ímpar/par) — a mesma linha como primeira
// (ou última) de 3+ páginas, sem chegar à metade nem ser consecutiva, escapa
// da remoção (checado numa prova real: FEPESE/PMBC 2014, "Prefeitura
// Municipal de Balneário Camboriú" nas ímpares e "Secretaria de Gestão
// Administrativa" nas pares, grudados na alternativa E). Abertura de
// questão ("Leia o texto a seguir:") nunca é a primeira linha da página.
const MINIMO_PAGINAS_EXTREMO = 3;

function chavesDeExtremos(paginas) {
  const contagem = new Map();
  for (const pagina of paginas) {
    const linhas = (pagina.texto ?? "").split("\n").map((l) => l.trim()).filter(Boolean);
    for (const chave of new Set([linhas[0], linhas.at(-1)].filter(Boolean).map((l) => l.replace(/\d+/g, "#")))) contagem.set(chave, (contagem.get(chave) ?? 0) + 1);
  }
  return [...contagem].filter(([, n]) => n >= MINIMO_PAGINAS_EXTREMO).map(([chave]) => chave);
}

export function fragmentosDeMargem(paginas) {
  const carimbos = new Set();
  for (const pagina of paginas) {
    const linhas = (pagina.texto ?? "").split("\n").map((l) => l.trim()).filter(Boolean);
    for (const linha of [...linhas.slice(0, LINHAS_BORDA), ...linhas.slice(-LINHAS_BORDA)]) for (const m of linha.matchAll(DATA_HORA)) carimbos.add(m[0]);
  }
  // Linha corrida só conta como lixo quando ocupa uma LINHA INTEIRA da
  // questão — o rodapé "GUARDA CIVIL MUNICIPAL" não pode marcar um
  // enunciado que fala da "Guarda Civil Municipal".
  const corridas = [...new Set([...chavesDeLinhasCorridas(paginas), ...chavesDeExtremos(paginas)])]
    .filter((linha) => linha.replace(/[#\s\W]/g, "").length >= TAMANHO_MINIMO_FRAGMENTO)
    .map((linha) => new RegExp(`^[ \\t]*${linha.split("#").map((p) => p.trim().replace(/[.*+?^${}()|[\]\\]/g, "\\$&").replace(/\s+/g, "\\s+")).join("\\s*\\d+\\s*")}[ \\t]*$`, "m"));
  return { corridas, carimbos: [...carimbos] };
}

// Glifo matemático alfanumérico (𝑥, 𝑦... U+1D400–U+1D7FF) que sobrou no
// texto = expressão de editor de equação que não foi reconstruída.
const GLIFO_MATEMATICO = /[\u{1D400}-\u{1D7FF}]/u;
// "f(x) =" seguido só de "?"/":"/fim: o lado direito da igualdade sumiu.
const IGUALDADE_TRUNCADA = /=\s*(?:[?:]|$)/m;

// Tabela-verdade linearizada: linhas seguidas feitas só de células de valor
// lógico ("V V F F V F"). O texto corrido não guarda as colunas — com
// célula em branco, nem dá para saber qual coluna falta (checado numa
// prova real: Fundatec/PP-RS 2022, tabela-verdade incompleta). Não é
// reconstruída nem liberável: precisa de estrutura confiável, de mídia ou
// de revisão.
const LINHA_DE_CELULAS_LOGICAS = /^[ \t]*[VF](?:[ \t]+[VF])+[ \t]*$/; // 2+ células: linha incompleta também conta
const MINIMO_LINHAS_TABELA = 3;

function temTabelaLinearizada(texto) {
  let seguidas = 0;
  for (const linha of (texto ?? "").split("\n")) {
    seguidas = LINHA_DE_CELULAS_LOGICAS.test(linha) ? seguidas + 1 : 0;
    if (seguidas >= MINIMO_LINHAS_TABELA) return true;
  }
  return false;
}

// Itens enumerados vazios: 2+ linhas SEGUIDAS só com o marcador, em
// sequência ("I." "II." "III.", "1)" "2)", "a)" "b)") — a lista sobreviveu
// e o conteúdo dos itens se perdeu (era imagem; checado numa prova real:
// Fundatec/PP-RS 2022 Técnico, questão 79, sentenças I–IV). Citação de
// itens ("Estão corretas I, II e III") nunca é linha só de marcador, e
// placeholder do documento ("I. ______", "II. (   )") é conteúdo. Não é
// liberável e não depende de mídia: posse de figura não recupera o item.
const LINHA_SO_MARCADOR = /^[ \t]*([IVXivx]{1,6}|\d{1,2}|[A-Za-z])[ \t]*([.)])[ \t]*$/;
const MINIMO_ITENS_VAZIOS = 2;
const ROMANOS = { i: 1, v: 5, x: 10 };

function valorRomano(s) {
  if (!/^[ivx]+$/i.test(s)) return null;
  const d = [...s.toLowerCase()].map((c) => ROMANOS[c]);
  return d.reduce((t, v, i) => t + (v < (d[i + 1] ?? 0) ? -v : v), 0);
}

// cur é o item seguinte a prev na mesma família (romano, número ou letra),
// com a mesma caixa e a mesma pontuação.
function itemSeguinte([prev, pPrev], [cur, pCur]) {
  if (pPrev !== pCur || (prev === prev.toUpperCase()) !== (cur === cur.toUpperCase())) return false;
  const romanos = [valorRomano(prev), valorRomano(cur)];
  if (romanos.every((v) => v !== null) && romanos[1] === romanos[0] + 1) return true;
  if (/^\d+$/.test(prev) && /^\d+$/.test(cur)) return Number(cur) === Number(prev) + 1;
  return prev.length === 1 && cur.length === 1 && /[a-z]/i.test(prev) && cur.toLowerCase().charCodeAt(0) === prev.toLowerCase().charCodeAt(0) + 1;
}

// Primeira sequência de itens vazios (marcadores, ex. ["I.", "II."]) ou null.
export function itensEnumeradosVazios(texto) {
  let seguidos = [];
  for (const linha of [...(texto ?? "").split("\n"), "fim"]) {
    if (!linha.trim()) continue;
    const m = linha.match(LINHA_SO_MARCADOR);
    const item = m ? [m[1], m[2]] : null;
    if (item && seguidos.length > 0 && itemSeguinte(seguidos.at(-1), item)) {
      seguidos.push(item);
      continue;
    }
    if (seguidos.length >= MINIMO_ITENS_VAZIOS) return seguidos.map(([marcador, pontuacao]) => marcador + pontuacao);
    seguidos = item ? [item] : [];
  }
  return null;
}

// Problemas de integridade de UMA questão já extraída (sem texto-base:
// enunciado_comando + alternativas). comparacao: resultado de
// compararQuestoes para esta questão (ou null quando só há uma leitura).
// referenciaPosicional: a OUTRA leitura é a posicional — a ordem visual da
// página. Aí o conteúdo igual em outra ordem (palavras deslocadas na
// questão, ou linhas trocadas com a vizinha: "reordenada") quer dizer que a
// leitura ESCOLHIDA pode ter perdido a ordem do PDF: revisão, nunca
// correção silenciosa. Quando a escolhida já é a posicional, a diferença é
// da ordem do stream da outra (explicada pela geometria). Conteúdo
// divergente fica só com divergencia_entre_leituras (sem motivo duplicado).
export function problemasDeIntegridade(questao, { comparacao = null, margem = { corridas: [], carimbos: [] }, referenciaPosicional = false } = {}) {
  const problemas = [];
  if (comparacao?.tipo === "divergente") {
    problemas.push({ codigo: "divergencia_entre_leituras", motivo: `leituras linear e geométrica do PDF divergem em ${comparacao.partes.join(", ")}` });
  } else if (referenciaPosicional && (comparacao?.ordem || comparacao?.tipo === "reordenada")) {
    const detalhe = comparacao.ordem
      ? `${comparacao.ordem.deslocadas} palavra(s) deslocada(s), a partir de "${comparacao.ordem.trecho}"`
      : "linhas trocadas com a questão vizinha";
    problemas.push({ codigo: "ordem_leituras_divergente", motivo: `mesmo conteúdo em outra ordem na leitura posicional do PDF (${detalhe})` });
  }
  const textosBase = (questao.textos_base ?? []).map((t) => [`texto-base ${t.id}`, t.texto]);
  for (const [rotulo, texto] of textosBase) {
    const carimbo = margem.carimbos.find((c) => (texto ?? "").includes(c));
    const corrida = margem.corridas.find((re) => re.test(texto ?? ""));
    if (carimbo || corrida) problemas.push({ codigo: "lixo_de_pagina", motivo: `${rotulo} contém fragmento de cabeçalho/rodapé da página ("${carimbo ?? texto.match(corrida)[0].trim()}")` });
  }
  for (const [rotulo, texto] of partesDaQuestao(questao)) {
    if (!texto) continue;
    const carimbo = margem.carimbos.find((c) => texto.includes(c));
    const corrida = margem.corridas.find((re) => re.test(texto));
    if (carimbo || corrida) problemas.push({ codigo: "lixo_de_pagina", motivo: `${rotulo} contém fragmento de cabeçalho/rodapé da página ("${carimbo ?? texto.match(corrida)[0].trim()}")` });
    if (GLIFO_MATEMATICO.test(texto)) problemas.push({ codigo: "glifo_matematico", motivo: `${rotulo} contém glifo matemático de expressão não reconstruída` });
    if (IGUALDADE_TRUNCADA.test(texto)) problemas.push({ codigo: "igualdade_truncada", motivo: `${rotulo} termina uma igualdade sem o lado direito (expressão possivelmente perdida depois de "=")` });
    if (temTabelaLinearizada(texto)) problemas.push({ codigo: "tabela_linearizada", motivo: `${rotulo} contém tabela-verdade convertida em texto corrido — a estrutura de colunas não é preservada` });
    const vazios = itensEnumeradosVazios(texto);
    if (vazios) problemas.push({ codigo: "item_enumerado_vazio", motivo: `${rotulo} tem itens enumerados sem conteúdo (${vazios.join(" ")}) — o conteúdo dos itens se perdeu na extração` });
  }
  return problemas;
}
