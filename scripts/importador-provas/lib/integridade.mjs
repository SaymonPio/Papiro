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

// Por questão, entre a leitura ESCOLHIDA e a outra leitura do mesmo PDF:
// cada parte (enunciado e cada alternativa) precisa ter o mesmo conteúdo
// normalizado. Quando difere, a janela da questão com as vizinhas decide:
// as mesmas linhas em outra ordem = a outra leitura só segue a ordem do
// stream ("reordenada", explicada pela geometria); qualquer outra
// diferença = "divergente".
export function compararQuestoes(escolhidas, outras) {
  const porNumero = new Map(outras.map((q) => [q.numero_original, q]));
  const indice = new Map(escolhidas.map((q, i) => [q.numero_original, i]));
  const linhasDe = (q) => (q ? partesDaQuestao(q).flatMap(([, t]) => (t ?? "").split("\n")).map(normalizar).filter(Boolean) : []);
  const resultado = new Map();
  for (const q of escolhidas) {
    const outra = porNumero.get(q.numero_original);
    if (!outra) {
      resultado.set(q.numero_original, { tipo: "divergente", partes: ["questão ausente na outra leitura"] });
      continue;
    }
    const diferentes = partesDaQuestao(q)
      .filter(([rotulo, texto]) => normalizar(texto) !== normalizar(partesDaQuestao(outra).find(([r]) => r === rotulo)?.[1]))
      .map(([rotulo]) => rotulo);
    if (diferentes.length === 0) {
      resultado.set(q.numero_original, { tipo: "igual", partes: [] });
      continue;
    }
    const i = indice.get(q.numero_original);
    const janela = [escolhidas[i - 1], q, escolhidas[i + 1]].filter(Boolean);
    const janelaOutra = janela.map((x) => porNumero.get(x.numero_original));
    const reordenada = janelaOutra.every(Boolean) && mesmoMulticonjunto(multiconjunto(janela.flatMap(linhasDe)), multiconjunto(janelaOutra.flatMap(linhasDe)));
    resultado.set(q.numero_original, { tipo: reordenada ? "reordenada" : "divergente", partes: diferentes });
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

// Problemas de integridade de UMA questão já extraída (sem texto-base:
// enunciado_comando + alternativas). comparacao: resultado de
// compararQuestoes para esta questão (ou null quando só há uma leitura).
export function problemasDeIntegridade(questao, { comparacao = null, margem = { corridas: [], carimbos: [] } } = {}) {
  const problemas = [];
  if (comparacao?.tipo === "divergente") {
    problemas.push({ codigo: "divergencia_entre_leituras", motivo: `leituras linear e geométrica do PDF divergem em ${comparacao.partes.join(", ")}` });
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
  }
  return problemas;
}
