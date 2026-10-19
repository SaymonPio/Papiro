// Mídias de questões (figura, gráfico, charge...) extraídas do PDF oficial:
//   PDF -> objetos de imagem com posição -> figuras (objetos agrupados) ->
//   dono (questão) pela geometria do texto -> composição determinística ->
//   PNG -> sha256 (identidade) -> metadados para o staging.
//
// Sem OCR e sem renderizar a página: só os objetos de imagem nativos do
// PDF (pdfjs), recompostos pela posição X/Y. Na dúvida, NUNCA adivinha:
// a questão vai para revisão com a causa (códigos em CAUSAS_MIDIA).
//
// Tudo é puro, exceto lerPaginasVisuais (I/O do pdfjs) — os testes montam
// páginas sintéticas no mesmo formato.

import { createHash } from "node:crypto";
import { readFileSync } from "node:fs";
import zlib from "node:zlib";
import { normalizarTexto } from "./deduplicar.mjs";
import { referenciaDeMidia, temReferenciaDeDestaque } from "./extrairQuestoes.mjs";
import { lerItensDoPdf, reconstruirDocumentoPosicionado } from "./extrairTextoPdfPosicionado.mjs";

const FRACAO_FUNDO = 0.5; // imagem cobrindo metade da página = fundo/capa
const LADO_MINIMO_PT = 10; // menor que isso = ícone/marca
const PAGINAS_REPETIDA = 3; // mesma imagem em 3+ páginas = cabeçalho/rodapé
const FOLGA_AGRUPAR_PT = 2; // objetos que se tocam (ou quase) são a mesma figura
const DISTANCIA_LEGENDA_PT = 30;
const DISTANCIA_DONO_PT = 320;
const MAX_LADO_PX = 2400;
export const MAX_BYTES_MIDIA = 2 * 1024 * 1024;

const LEGENDA = /^(figura|gr[áa]fico|tabela|imagem|quadro|mapa|charge)\s*(?:n[ºo°.]?\s*)?(\d{1,2})?\b/i;
const CREDITO = /^(?:fonte|dispon[íi]vel em|cr[ée]dito|autor(?:ia)?|ilustra[çc][ãa]o)\b|https?:\/\/|©/i;
const PECA_DE_TERCEIRO = /\b(?:charge|cartum|cartuns|tirinhas?|quadrinhos?|hq|cartaz|meme|foto|fotografia|an[úu]ncio)\b/i;

const sha256 = (dados) => createHash("sha256").update(dados).digest("hex");

// ---------------------------------------------------------------- PNG ----

const TABELA_CRC = Array.from({ length: 256 }, (_, n) => {
  let c = n;
  for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
  return c >>> 0;
});
function crc32(buf) {
  let c = 0xffffffff;
  for (const byte of buf) c = TABELA_CRC[(c ^ byte) & 0xff] ^ (c >>> 8);
  return (c ^ 0xffffffff) >>> 0;
}
function bloco(tipo, dados) {
  const tamanho = Buffer.alloc(4);
  tamanho.writeUInt32BE(dados.length);
  const corpo = Buffer.concat([Buffer.from(tipo, "ascii"), dados]);
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(corpo));
  return Buffer.concat([tamanho, corpo, crc]);
}

// PNG RGB 8 bits, filtro 0, zlib nível 9 fixo — mesmos pixels, mesmos bytes.
export function codificarPng(largura, altura, rgb) {
  const bruto = Buffer.alloc((largura * 3 + 1) * altura);
  for (let y = 0; y < altura; y++) Buffer.from(rgb.buffer, rgb.byteOffset + y * largura * 3, largura * 3).copy(bruto, y * (largura * 3 + 1) + 1);
  const cabecalho = Buffer.alloc(13);
  cabecalho.writeUInt32BE(largura, 0);
  cabecalho.writeUInt32BE(altura, 4);
  cabecalho[8] = 8;
  cabecalho[9] = 2;
  return Buffer.concat([
    Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]),
    bloco("IHDR", cabecalho),
    bloco("IDAT", zlib.deflateSync(bruto, { level: 9 })),
    bloco("IEND", Buffer.alloc(0)),
  ]);
}

// ---------------------------------------------------------- geometria ----

const largura = (r) => r.x1 - r.x0;
const altura = (r) => r.y1 - r.y0;
const sobrepoeX = (a, b) => Math.min(a.x1, b.x1) - Math.max(a.x0, b.x0) > 0;
function interseccao(a, b) {
  const w = Math.min(a.x1, b.x1) - Math.max(a.x0, b.x0);
  const h = Math.min(a.y1, b.y1) - Math.max(a.y0, b.y0);
  return w > 0 && h > 0 ? w * h : 0;
}
function uniao(rets) {
  return { x0: Math.min(...rets.map((r) => r.x0)), y0: Math.min(...rets.map((r) => r.y0)), x1: Math.max(...rets.map((r) => r.x1)), y1: Math.max(...rets.map((r) => r.y1)) };
}
const tocam = (a, b, folga) => a.x0 <= b.x1 + folga && b.x0 <= a.x1 + folga && a.y0 <= b.y1 + folga && b.y0 <= a.y1 + folga;

function assinaturaPixels(img) {
  return img.rgba ? sha256(Buffer.concat([Buffer.from(`${img.pxL}x${img.pxA}:`), Buffer.from(img.rgba.buffer, img.rgba.byteOffset, img.rgba.byteLength)])) : `${img.pxL}x${img.pxA}`;
}

// Fundos, marcas minúsculas e cabeçalho/rodapé repetido nunca são mídia de questão.
export function filtrarDecorativas(paginas) {
  const paginasPorAssinatura = new Map();
  for (const p of paginas) for (const img of p.imagens) {
    img.assinatura ??= assinaturaPixels(img);
    const set = paginasPorAssinatura.get(img.assinatura) ?? new Set();
    set.add(p.numero);
    paginasPorAssinatura.set(img.assinatura, set);
  }
  const ignoradas = [];
  const filtradas = paginas.map((p) => ({
    ...p,
    imagens: p.imagens.filter((img) => {
      const motivo =
        largura(img) * altura(img) > FRACAO_FUNDO * p.largura * p.altura ? "fundo/capa (cobre mais de metade da página)"
        : largura(img) < LADO_MINIMO_PT || altura(img) < LADO_MINIMO_PT ? "marca/ícone pequeno demais"
        : paginasPorAssinatura.get(img.assinatura).size >= PAGINAS_REPETIDA ? "repetida em várias páginas (cabeçalho/rodapé)"
        : null;
      if (motivo) ignoradas.push({ pagina: p.numero, id: img.id, motivo });
      return !motivo;
    }),
  }));
  return { paginas: filtradas, ignoradas };
}

// Objetos que se sobrepõem ou se tocam formam UMA figura (ex.: print + anel de destaque).
export function agruparEmFiguras(imagens) {
  const pai = imagens.map((_, i) => i);
  const raiz = (i) => (pai[i] === i ? i : (pai[i] = raiz(pai[i])));
  for (let i = 0; i < imagens.length; i++) for (let j = i + 1; j < imagens.length; j++) if (tocam(imagens[i], imagens[j], FOLGA_AGRUPAR_PT)) pai[raiz(i)] = raiz(j);
  const grupos = new Map();
  imagens.forEach((img, i) => grupos.set(raiz(i), [...(grupos.get(raiz(i)) ?? []), img]));
  return [...grupos.values()].map((componentes) => componentes.sort((a, b) => a.pintura - b.pintura));
}

// --------------------------------------------------------- composição ----

const MAX_VETORES_POR_FIGURA = 400;

function corRgb(hex) {
  const m = /^#([0-9a-f]{6})$/i.exec(hex ?? "");
  return m ? [0, 2, 4].map((i) => parseInt(m[1].slice(i, i + 2), 16)) : null;
}

function distanciaAoSegmento(px, py, ax, ay, bx, by) {
  const dx = bx - ax;
  const dy = by - ay;
  const t = dx === 0 && dy === 0 ? 0 : Math.max(0, Math.min(1, ((px - ax) * dx + (py - ay) * dy) / (dx * dx + dy * dy)));
  return Math.hypot(px - (ax + t * dx), py - (ay + t * dy));
}

function dentroDoCaminho(px, py, subcaminhos, parImpar) {
  let voltas = 0;
  for (const pontos of subcaminhos) {
    for (let i = 0; i + 3 < pontos.length + 2; i += 2) {
      const ax = pontos[i];
      const ay = pontos[i + 1];
      const bx = pontos[(i + 2) % pontos.length];
      const by = pontos[(i + 3) % pontos.length];
      if (ay <= py && by > py && (bx - ax) * (py - ay) - (px - ax) * (by - ay) > 0) voltas++;
      else if (ay > py && by <= py && (bx - ax) * (py - ay) - (px - ax) * (by - ay) < 0) voltas--;
    }
  }
  return parImpar ? voltas % 2 !== 0 : voltas !== 0;
}

function pintar(rgb, d, cor, alfa) {
  for (let k = 0; k < 3; k++) rgb[d + k] = alfa >= 1 ? cor[k] : Math.round(cor[k] * alfa + rgb[d + k] * (1 - alfa));
}

// Recompõe imagens E vetores sólidos em ordem de pintura, na resolução do
// componente de imagem mais denso, sobre fundo branco (a página impressa),
// respeitando clip retangular. Mesma entrada, mesmos bytes. Qualquer coisa
// fora do suportado recusa a composição — nunca publica figura incompleta.
export function comporFigura(componentes) {
  const naoSuportado = componentes.find((c) => !c.suportada);
  if (naoSuportado) return { erro: `objeto ${naoSuportado.id}: ${naoSuportado.motivo ?? "não suportado"}` };
  if (componentes.some((c) => c.clip === "complexo")) return { erro: "recorte (clip) não retangular sobre a figura" };
  if (componentes.filter((c) => c.tipo === "vetor").length > MAX_VETORES_POR_FIGURA) return { erro: "desenho vetorial complexo demais" };
  const imagens = componentes.filter((c) => c.tipo !== "vetor");
  if (imagens.length === 0) return { erro: "figura só vetorial (sem imagem de referência de resolução)" };
  const caixa = uniao(
    componentes.map((c) => {
      const f = c.tipo === "vetor" ? (c.larguraTraco ?? 0) / 2 : 0;
      const r = { x0: c.x0 - f, y0: c.y0 - f, x1: c.x1 + f, y1: c.y1 + f };
      return c.clip ? { x0: Math.max(r.x0, c.clip.x0), y0: Math.max(r.y0, c.clip.y0), x1: Math.min(r.x1, c.clip.x1), y1: Math.min(r.y1, c.clip.y1) } : r;
    }),
  );
  const escala = Math.max(...imagens.map((c) => Math.max(c.pxL / largura(c), c.pxA / altura(c))));
  const L = Math.round(largura(caixa) * escala);
  const A = Math.round(altura(caixa) * escala);
  if (L < 1 || A < 1) return { erro: "figura sem área" };
  if (L > MAX_LADO_PX || A > MAX_LADO_PX) return { erro: `figura grande demais (${L}x${A} px)` };
  const rgb = new Uint8Array(L * A * 3).fill(255);
  const paraPagina = (x, y) => [caixa.x0 + (x + 0.5) / escala, caixa.y1 - (y + 0.5) / escala];
  const limites = (c, folga = 0) => {
    const r = c.clip ? { x0: Math.max(c.x0 - folga, c.clip.x0), y0: Math.max(c.y0 - folga, c.clip.y0), x1: Math.min(c.x1 + folga, c.clip.x1), y1: Math.min(c.y1 + folga, c.clip.y1) } : { x0: c.x0 - folga, y0: c.y0 - folga, x1: c.x1 + folga, y1: c.y1 + folga };
    return {
      xIni: Math.max(0, Math.floor((r.x0 - caixa.x0) * escala)),
      xFim: Math.min(L, Math.ceil((r.x1 - caixa.x0) * escala)),
      yIni: Math.max(0, Math.floor((caixa.y1 - r.y1) * escala)),
      yFim: Math.min(A, Math.ceil((caixa.y1 - r.y0) * escala)),
    };
  };
  for (const c of [...componentes].sort((a, b) => a.pintura - b.pintura)) {
    const { xIni, xFim, yIni, yFim } = limites(c, c.tipo === "vetor" ? (c.larguraTraco ?? 0) : 0);
    if (c.tipo === "vetor") {
      const corTraco = corRgb(c.corTraco);
      const corFundo = corRgb(c.corFundo);
      const meioTracoPx = Math.max(((c.larguraTraco ?? 1) * escala) / 2, 0.5);
      for (let y = yIni; y < yFim; y++) for (let x = xIni; x < xFim; x++) {
        const [px, py] = paraPagina(x, y);
        const d = (y * L + x) * 3;
        if (c.preenche && dentroDoCaminho(px, py, c.subcaminhos, c.parImpar)) pintar(rgb, d, corFundo, 1);
        if (c.traca) {
          let menor = Infinity;
          for (const pontos of c.subcaminhos) for (let i = 0; i + 3 < pontos.length; i += 2) menor = Math.min(menor, distanciaAoSegmento(px, py, pontos[i], pontos[i + 1], pontos[i + 2], pontos[i + 3]));
          const alfa = Math.max(0, Math.min(1, meioTracoPx - menor * escala + 0.5));
          if (alfa > 0) pintar(rgb, d, corTraco, alfa);
        }
      }
      continue;
    }
    const dx0 = Math.round((c.x0 - caixa.x0) * escala);
    const dy0 = Math.round((caixa.y1 - c.y1) * escala);
    const dw = Math.max(1, Math.round(largura(c) * escala));
    const dh = Math.max(1, Math.round(altura(c) * escala));
    for (let y = Math.max(yIni, dy0); y < Math.min(yFim, dy0 + dh); y++) {
      const sy = Math.min(c.pxA - 1, Math.floor(((y - dy0) * c.pxA) / dh));
      for (let x = Math.max(xIni, dx0); x < Math.min(xFim, dx0 + dw); x++) {
        const sx = Math.min(c.pxL - 1, Math.floor(((x - dx0) * c.pxL) / dw));
        const s = (sy * c.pxL + sx) * 4;
        const a = c.rgba[s + 3];
        if (a === 0) continue;
        const d = (y * L + x) * 3;
        for (let k = 0; k < 3; k++) rgb[d + k] = a === 255 ? c.rgba[s + k] : Math.floor((c.rgba[s + k] * a + rgb[d + k] * (255 - a) + 127) / 255);
      }
    }
  }
  return { largura: L, altura: A, rgb, caixa };
}

// Vetores PINTADOS que são parte da figura (≥ metade da própria área dentro
// dela e não muito maiores que ela). Vetor só parcialmente sobre a figura
// = composição incerta.
function vetoresDaFigura(vetores, caixa) {
  const incluidos = [];
  let parcial = null;
  for (const v of vetores ?? []) {
    const folga = (v.larguraTraco ?? 0) / 2;
    const r = { x0: v.x0 - folga, y0: v.y0 - folga, x1: v.x1 + folga, y1: v.y1 + folga };
    const area = Math.max(largura(r), 0.5) * Math.max(altura(r), 0.5);
    if (area >= 2 * largura(caixa) * altura(caixa)) continue;
    const fracao = interseccao(r, caixa) / area;
    if (fracao >= 0.5) incluidos.push(v);
    else if (fracao > 0) parcial ??= v;
  }
  return { incluidos, parcial };
}

// ------------------------------------------------------- dono e posição ----

// Tipo pela palavra que ABRE a legenda ("Figura 1 – Mapa..." é FIGURA);
// sem legenda, pelo sinal visual do texto da questão.
const TIPO_DA_PALAVRA = [
  [/^(?:charge|cartum|cartuns|tirinhas?|quadrinhos?|hq)$/, "CHARGE"],
  [/^(?:grafico|infografico)$/, "GRAFICO"],
  [/^(?:tabela|quadro)$/, "TABELA"],
  [/^mapa$/, "MAPA"],
];
function tipoDaMidia(legenda, sinal) {
  const palavraLegenda = legenda ? normalizarTexto(legenda.match(LEGENDA)?.[1] ?? "") : "";
  if (palavraLegenda) return TIPO_DA_PALAVRA.find(([re]) => re.test(palavraLegenda))?.[1] ?? "FIGURA";
  const palavras = normalizarTexto(sinal ?? "").split(" ");
  for (const palavra of palavras) {
    const tipo = TIPO_DA_PALAVRA.find(([re]) => re.test(palavra))?.[1];
    if (tipo) return tipo;
  }
  return "FIGURA";
}

const ROTULO_TIPO = { FIGURA: "Figura", GRAFICO: "Gráfico", TABELA: "Tabela", MAPA: "Mapa", CHARGE: "Charge" };

// Texto alternativo NUNCA usa o texto das alternativas: é a legenda (já
// visível no enunciado) ou um rótulo genérico — e a legenda é descartada
// se contiver o texto de alguma alternativa.
export function gerarAltText({ tipo, legenda, numero, alternativas }) {
  const alts = (alternativas ?? []).map((a) => normalizarTexto(a.texto ?? a)).filter((t) => t.length >= 3);
  const legendaSegura = legenda && !alts.some((t) => normalizarTexto(legenda).includes(t)) ? legenda : null;
  return (legendaSegura ?? `${ROTULO_TIPO[tipo] ?? "Figura"} da questão ${numero}`).slice(0, 300);
}

function linhasDaQuestao(q) {
  const comando = q._interno?.enunciado_comando ?? q.enunciado;
  const alternativas = (q.alternativas ?? []).map((a) => a.texto ?? "").join(" ");
  return {
    q,
    completo: normalizarTexto(`${q.enunciado} ${alternativas}`),
    alternativas: normalizarTexto(alternativas),
    enunciado: normalizarTexto(q.enunciado),
    linhasEnunciado: q.enunciado.split("\n").map((l) => l.trim()).filter(Boolean),
    referencia: referenciaDeMidia(`${q.enunciado}\n${alternativas}`),
    comando: normalizarTexto(comando),
  };
}

// Linha distintiva (3+ palavras, 15+ caracteres) que está no texto de
// questão(ões). Mais de uma dona só vale se a linha for do texto-base
// COMPARTILHADO (fora do comando e das alternativas de todas elas) —
// linha genérica ("Guarda Municipal de Porto Alegre") não indica posse.
function donosDaLinha(linha, infos) {
  const n = normalizarTexto(linha.texto);
  if (n.length < 15 || n.split(" ").length < 3) return null;
  const donas = infos.filter((i) => i.completo.includes(n));
  if (donas.length === 0) return null;
  if (donas.length > 1 && donas.some((i) => i.comando.includes(n) || i.alternativas.includes(n))) return null;
  return new Set(donas.map((i) => i.q.numero_original));
}

const LINHAS_CONFIRMACAO = 2;
const JANELA_CONFIRMACAO_PT = 120;

function primeiraComDono(linhas, infos) {
  for (const l of linhas) {
    const donos = donosDaLinha(l, infos);
    if (donos) return { linha: l, donos };
  }
  return null;
}

// Linha do enunciado ANTES da qual a mídia aparece (null = depois do
// enunciado, antes das alternativas).
function ancoraNoEnunciado(info, linhaAbaixo) {
  if (!linhaAbaixo) return { erro: "nada abaixo da figura nesta coluna/página — posição incerta" };
  const nL = normalizarTexto(linhaAbaixo.texto);
  if (nL.length < 4) return { erro: "linha abaixo da figura curta demais para ancorar" };
  if (info.alternativas.includes(nL) && !info.enunciado.includes(nL)) return { ancora: null };
  const candidatas = info.linhasEnunciado.filter((linha) => {
    const nE = normalizarTexto(linha);
    return nE.length >= 4 && (nE.startsWith(nL) || nL.startsWith(nE));
  });
  if (candidatas.length === 1) return { ancora: candidatas[0] };
  if (candidatas.length > 1) return { erro: "mais de uma linha do enunciado casa com o texto abaixo da figura" };
  if (info.enunciado.includes(nL)) return { erro: "a figura cai no meio de um parágrafo do enunciado" };
  return { erro: "o texto abaixo da figura não pertence ao enunciado desta questão" };
}

function descreverOrigem(f) {
  const imagens = f.componentes.filter((id) => !/^(vetor|sombreamento)/.test(id));
  const vetores = f.componentes.length - imagens.length;
  const partes = [`${imagens.length} objeto(s) de imagem (${imagens.join(", ")})`];
  if (vetores > 0) partes.push(`${vetores} traço(s) vetorial(is)`);
  return `PDF da prova, página ${f.pagina}: ${partes.join(" + ")}${f.componentes.length > 1 ? ", compostos pela posição" : ""}`;
}

// Causas de MIDIA_OK=false (códigos estáveis — liberáveis só os listados
// em planejar.mjs CAUSAS_LIBERAVEIS).
export const CAUSAS_MIDIA = {
  midia_ausente: "a questão cita peça visual, mas nenhuma figura foi encontrada no PDF",
  midia_quantidade_inconsistente: "quantidade de figuras diferente das referenciadas",
  midia_sem_referencia: "figura encontrada na região da questão sem referência visual no texto",
  midia_posse_ambigua: "figura entre questões diferentes, sem como decidir a dona",
  midia_composicao_incerta: "composição da figura não confiável",
  midia_posicao_incerta: "posição da figura no enunciado incerta",
};
const causa = (codigo, detalhe) => ({ codigo, motivo: detalhe ? `${CAUSAS_MIDIA[codigo]} (${detalhe})` : CAUSAS_MIDIA[codigo] });

/**
 * @param {{ paginas: Array<{numero, largura, altura, linhas, imagens, vetores?}>, questoes: object[] }} entrada
 * @returns {{ porQuestao: Map<number, {dependencia, status, causas, midias}>, arquivos: Map<string, Buffer>, ignoradas: object[] }}
 */
export function resolverMidias({ paginas, questoes }) {
  const infos = questoes.map(linhasDaQuestao);
  const infoPorNumero = new Map(infos.map((i) => [i.q.numero_original, i]));
  const { paginas: uteis, ignoradas } = filtrarDecorativas(paginas);
  const arquivos = new Map();
  const achados = new Map(infos.map((i) => [i.q.numero_original, { figuras: [], causas: [] }]));

  for (const pagina of uteis) {
    for (const componentes of agruparEmFiguras(pagina.imagens)) {
      const caixa = uniao(componentes);
      const naColuna = pagina.linhas.filter((l) => sobrepoeX({ x0: l.xInicio, x1: l.xFim }, caixa));
      const acima = naColuna.filter((l) => l.y > caixa.y1 - 1 && l.y - caixa.y1 < DISTANCIA_DONO_PT).sort((a, b) => a.y - b.y);
      const abaixo = naColuna.filter((l) => l.y < caixa.y0 + 1 && caixa.y0 - l.y < DISTANCIA_DONO_PT).sort((a, b) => b.y - a.y);
      const sobre = naColuna.filter((l) => l.y > caixa.y0 + 2 && l.y < caixa.y1 - 2);
      const perto = [...acima, ...abaixo].filter((l) => Math.min(Math.abs(l.y - caixa.y1), Math.abs(caixa.y0 - l.y)) <= DISTANCIA_LEGENDA_PT);
      const linhaLegenda = perto.find((l) => LEGENDA.test(l.texto.trim()));
      const linhaCredito = perto.find((l) => CREDITO.test(l.texto.trim()));
      const rotulo = linhaLegenda ? normalizarTexto(`${linhaLegenda.texto.trim().match(LEGENDA)[1]} ${linhaLegenda.texto.trim().match(LEGENDA)[2] ?? ""}`) : null;

      const cima = primeiraComDono(acima, infos);
      const baixo = primeiraComDono(abaixo, infos);
      let donos = cima && baixo ? new Set([...cima.donos].filter((n) => baixo.donos.has(n))) : (cima ?? baixo)?.donos ?? new Set();
      let ambigua = false;
      if (cima && baixo && donos.size === 0) {
        const candidatas = [...new Set([...cima.donos, ...baixo.donos])].filter((n) => infoPorNumero.get(n).referencia);
        const porRotulo = rotulo ? candidatas.filter((n) => infoPorNumero.get(n).referencia.rotulos.includes(rotulo)) : candidatas;
        if (porRotulo.length === 1) donos = new Set(porRotulo);
        else {
          donos = new Set(candidatas.length > 0 ? candidatas : [...cima.donos, ...baixo.donos]);
          ambigua = true;
        }
      }
      const pertoDaFigura = [...acima, ...abaixo].filter((l) => Math.min(Math.abs(l.y - caixa.y1), Math.abs(caixa.y0 - l.y)) <= JANELA_CONFIRMACAO_PT);
      const confirmacoes = pertoDaFigura.filter((l) => [...(donosDaLinha(l, infos) ?? [])].some((n) => donos.has(n))).length;
      if (donos.size > 0 && confirmacoes < LINHAS_CONFIRMACAO) {
        ignoradas.push({ pagina: pagina.numero, id: componentes.map((c) => c.id).join("+"), motivo: `posse sem confirmação (${confirmacoes} linha da questão perto da figura)` });
        continue;
      }
      if (donos.size === 0) {
        ignoradas.push({ pagina: pagina.numero, id: componentes.map((c) => c.id).join("+"), motivo: "figura fora de qualquer questão" });
        continue;
      }

      // Composição: imagens + vetores sólidos da figura. Vetor parcial,
      // texto sobre a figura ou objeto não suportado = não confiável.
      const { incluidos, parcial } = vetoresDaFigura(pagina.vetores, caixa);
      const composicao = comporFigura([...componentes, ...incluidos]);
      const erroComposicao =
        composicao.erro ??
        (parcial ? "desenho vetorial só parcialmente sobre a figura" : sobre.length > 0 ? `texto sobre a figura não é reproduzido ("${sobre[0].texto.slice(0, 40)}")` : null);
      if (incluidos.length > 0) componentes.push(...incluidos);

      let png = null;
      let hash = null;
      if (!erroComposicao) {
        png = codificarPng(composicao.largura, composicao.altura, composicao.rgb);
        hash = sha256(png);
      }
      const figura = {
        pagina: pagina.numero,
        caixa,
        componentes: componentes.map((c) => c.id),
        legenda: linhaLegenda ? linhaLegenda.texto.trim().replace(/\s+/g, " ") : null,
        rotulo,
        credito: linhaCredito ? linhaCredito.texto.trim().replace(/\s+/g, " ") : null,
        linhaAbaixo: abaixo[0] ?? null,
        ambigua,
        erroComposicao: erroComposicao ?? (png && png.length > MAX_BYTES_MIDIA ? `arquivo grande demais (${png.length} bytes)` : null),
        png,
        hash,
        largura: composicao.largura,
        altura: composicao.altura,
      };
      for (const n of donos) achados.get(n).figuras.push(figura);
    }
  }

  const porQuestao = new Map();
  for (const info of infos) {
    const numero = info.q.numero_original;
    const { figuras } = achados.get(numero);
    const causas = [];
    const dependencia = info.referencia;
    if (dependencia && figuras.length === 0) causas.push(causa("midia_ausente", dependencia.sinal));
    if (!dependencia && figuras.length > 0) causas.push(causa("midia_sem_referencia", `página ${figuras[0].pagina}`));
    if (dependencia && dependencia.rotulos.length > 0 && figuras.length > 0) {
      const rotulosFiguras = figuras.map((f) => f.rotulo).filter(Boolean);
      const faltando = dependencia.rotulos.filter((r) => !rotulosFiguras.includes(r));
      if (figuras.length !== dependencia.rotulos.length || faltando.length > 0) {
        causas.push(causa("midia_quantidade_inconsistente", `${figuras.length} figura(s) para ${dependencia.rotulos.join(", ")}`));
      }
    }
    figuras.sort((a, b) => a.pagina - b.pagina || b.caixa.y1 - a.caixa.y1 || a.caixa.x0 - b.caixa.x0);
    const midias = figuras.map((f, indice) => {
      if (f.ambigua) causas.push(causa("midia_posse_ambigua", `página ${f.pagina}`));
      if (f.erroComposicao) causas.push(causa("midia_composicao_incerta", f.erroComposicao));
      const ancora = ancoraNoEnunciado(info, f.linhaAbaixo);
      if (ancora.erro) causas.push(causa("midia_posicao_incerta", ancora.erro));
      const tipo = tipoDaMidia(f.legenda, dependencia?.sinal);
      const terceiro = tipo === "CHARGE" || PECA_DE_TERCEIRO.test(dependencia?.sinal ?? "") || Boolean(f.credito);
      if (f.png) arquivos.set(f.hash, f.png);
      return {
        ordem: indice + 1,
        tipo,
        sha256: f.hash,
        mime_type: "image/png",
        arquivo: f.hash ? `midias/${f.hash}.png` : null,
        storage_path: f.hash ? `questoes/${f.hash}.png` : null,
        largura: f.largura ?? null,
        altura: f.altura ?? null,
        pagina_origem: f.pagina,
        caixa_pdf: [f.caixa.x0, f.caixa.y0, f.caixa.x1, f.caixa.y1].map((v) => Math.round(v * 100) / 100),
        componentes: f.componentes,
        legenda: f.legenda,
        ancora_texto: ancora.erro ? null : ancora.ancora,
        alt_text: gerarAltText({ tipo, legenda: f.legenda, numero, alternativas: info.q.alternativas }),
        credito: f.credito,
        direito_uso: terceiro ? "REVISAO_DIREITOS" : "OFICIAL_PROVA",
        origem_descricao: descreverOrigem(f),
      };
    });
    if (!dependencia && midias.length === 0) continue;
    porQuestao.set(numero, { dependencia: Boolean(dependencia), status: causas.length === 0 ? "OK" : "REVISAO", causas, midias });
  }
  return { porQuestao, arquivos, ignoradas };
}

// Grava o resultado no _interno da questão normalizada (staging). Só toca
// questões com dependência visual ou figura — as demais ficam idênticas.
// A referência visual só deixa de ser falha de extração quando TODAS as
// mídias foram resolvidas e não há destaque tipográfico (que imagem não
// resolve).
export function anexarMidias(questao, resultado) {
  if (!resultado) return questao;
  const interno = questao._interno;
  if (resultado.dependencia) interno.dependencia_midia = true;
  if (resultado.midias.length > 0) interno.midias = resultado.midias;
  if (resultado.causas.length > 0) interno.midias_causas = resultado.causas;
  const texto = `${questao.enunciado}\n${(questao.alternativas ?? []).map((a) => a.texto).join("\n")}`;
  if (resultado.status === "OK" && resultado.dependencia && interno.referencia_visual && !temReferenciaDeDestaque(texto)) interno.referencia_visual_resolvida = true;
  return questao;
}

// ---------------------------------------------------------------- I/O ----

function multiplicar(a, b) {
  return [a[0] * b[0] + a[2] * b[1], a[1] * b[0] + a[3] * b[1], a[0] * b[2] + a[2] * b[3], a[1] * b[2] + a[3] * b[3], a[0] * b[4] + a[2] * b[5] + a[4], a[1] * b[4] + a[3] * b[5] + a[5]];
}
function aplicar(m, x, y) {
  return [m[0] * x + m[2] * y + m[4], m[1] * x + m[3] * y + m[5]];
}

function paraRgba(img) {
  const { width: w, height: h, data, kind } = img;
  if (!data) return null;
  if (kind === 3) return new Uint8Array(data.buffer, data.byteOffset, w * h * 4);
  const out = new Uint8Array(w * h * 4);
  if (kind === 2) {
    for (let i = 0; i < w * h; i++) {
      out[i * 4] = data[i * 3];
      out[i * 4 + 1] = data[i * 3 + 1];
      out[i * 4 + 2] = data[i * 3 + 2];
      out[i * 4 + 3] = 255;
    }
    return out;
  }
  if (kind === 1) {
    const porLinha = (w + 7) >> 3;
    for (let y = 0; y < h; y++) for (let x = 0; x < w; x++) {
      const v = (data[y * porLinha + (x >> 3)] >> (7 - (x & 7))) & 1 ? 255 : 0;
      out.set([v, v, v, 255], (y * w + x) * 4);
    }
    return out;
  }
  return null;
}

// Imagem usada em várias páginas fica em commonObjs (id "g_..."), não em
// objs. Prazo máximo: objeto que não chega vira imagem não suportada (a
// figura cai em revisão) — uma Promise pendurada esvaziaria o event loop e
// o processo sairia em silêncio, sem staging.
const PRAZO_OBJETO_MS = 15000;
function objetoDeImagem(page, id) {
  const repositorio = id.startsWith("g_") ? page.commonObjs : page.objs;
  return new Promise((ok) => {
    const timer = setTimeout(() => ok(null), PRAZO_OBJETO_MS);
    const entregar = (obj) => {
      clearTimeout(timer);
      ok(obj ?? null);
    };
    try {
      if (repositorio.has(id)) entregar(repositorio.get(id));
      else repositorio.get(id, entregar);
    } catch {
      entregar(null);
    }
  });
}

// Uma passada pelo PDF: linhas de texto com geometria (a mesma reconstrução
// do extrator posicional) + objetos de imagem com a caixa na página +
// caixas dos desenhos vetoriais.
export async function lerPaginasVisuais(caminhoArquivoOuBuffer) {
  const dados = typeof caminhoArquivoOuBuffer === "string" ? readFileSync(caminhoArquivoOuBuffer) : caminhoArquivoOuBuffer;
  const paginasDeItens = await lerItensDoPdf(dados);
  const { debug } = reconstruirDocumentoPosicionado(paginasDeItens, { debug: true });
  const pdfjs = await import("pdfjs-dist/legacy/build/pdf.mjs");
  const doc = await pdfjs.getDocument({ data: new Uint8Array(dados), useWorkerFetch: false, isEvalSupported: false, disableFontFace: true, verbosity: 0 }).promise;
  const paginas = [];
  for (let numero = 1; numero <= doc.numPages; numero++) {
    const page = await doc.getPage(numero);
    const viewport = page.getViewport({ scale: 1 });
    const ops = await page.getOperatorList();
    const imagens = [];
    const vetores = [];
    const O = pdfjs.OPS;
    const PINTURA = {
      [O.stroke]: { traca: true }, [O.closeStroke]: { traca: true },
      [O.fill]: { preenche: true }, [O.eoFill]: { preenche: true, parImpar: true },
      [O.fillStroke]: { preenche: true, traca: true }, [O.eoFillStroke]: { preenche: true, traca: true, parImpar: true },
      [O.closeFillStroke]: { preenche: true, traca: true }, [O.closeEOFillStroke]: { preenche: true, traca: true, parImpar: true },
    };
    // Estado gráfico mínimo: CTM, cores sólidas, espessura, tracejado,
    // padrão/sombreamento e clip (retângulo ou "complexo").
    let g = { ctm: [1, 0, 0, 1, 0, 0], corFundo: "#000000", corTraco: "#000000", largura: 1, tracejado: false, padrao: false, clip: null };
    const pilha = [];
    let proximoEhClip = false;
    const escalaDe = (m) => Math.sqrt(Math.abs(m[0] * m[3] - m[1] * m[2]));
    for (let i = 0; i < ops.fnArray.length; i++) {
      const fn = ops.fnArray[i];
      const args = ops.argsArray[i];
      if (fn === O.save) pilha.push({ ...g });
      else if (fn === O.restore) g = pilha.pop() ?? g;
      else if (fn === O.transform) g.ctm = multiplicar(g.ctm, args);
      else if (fn === O.paintFormXObjectBegin) {
        pilha.push({ ...g });
        if (Array.isArray(args?.[0]) || ArrayBuffer.isView(args?.[0])) g.ctm = multiplicar(g.ctm, [...args[0]]);
      } else if (fn === O.paintFormXObjectEnd) g = pilha.pop() ?? g;
      else if (fn === O.setFillRGBColor) [g.corFundo, g.padrao] = [args[0], false];
      else if (fn === O.setStrokeRGBColor) [g.corTraco, g.padrao] = [args[0], false];
      else if (fn === O.setFillColorN || fn === O.setStrokeColorN) g.padrao = true;
      else if (fn === O.setLineWidth) g.largura = args[0] || 1;
      else if (fn === O.setDash) g.tracejado = Array.isArray(args?.[0]) && args[0].length > 0;
      else if (fn === O.clip || fn === O.eoClip) proximoEhClip = true;
      else if (fn === O.shadingFill) vetores.push({ tipo: "vetor", id: `sombreamento${i}`, pintura: i, ...(g.clip && g.clip !== "complexo" ? g.clip : { x0: 0, y0: 0, x1: viewport.width, y1: viewport.height }), subcaminhos: [], suportada: false, motivo: "sombreamento (degradê) não suportado" });
      else if (fn === O.constructPath) {
        // Achata o caminho (curvas em 16 segmentos) já em coordenadas da página.
        const subcaminhos = [];
        let atual = null;
        let reto = true;
        const d = args?.[1]?.[0] ?? [];
        for (let k = 0; k < d.length; ) {
          const op = d[k];
          if (op === 0) { atual = [...aplicar(g.ctm, d[k + 1], d[k + 2])]; subcaminhos.push(atual); k += 3; }
          else if (op === 1) { atual?.push(...aplicar(g.ctm, d[k + 1], d[k + 2])); k += 3; }
          else if (op === 2) {
            reto = false;
            const [x0, y0] = atual ? atual.slice(-2) : [0, 0];
            const [c1x, c1y] = aplicar(g.ctm, d[k + 1], d[k + 2]);
            const [c2x, c2y] = aplicar(g.ctm, d[k + 3], d[k + 4]);
            const [x3, y3] = aplicar(g.ctm, d[k + 5], d[k + 6]);
            for (let s = 1; s <= 16; s++) {
              const t = s / 16;
              const u = 1 - t;
              atual?.push(u * u * u * x0 + 3 * u * u * t * c1x + 3 * u * t * t * c2x + t * t * t * x3, u * u * u * y0 + 3 * u * u * t * c1y + 3 * u * t * t * c2y + t * t * t * y3);
            }
            k += 7;
          } else if (op === 3) { if (atual && atual.length >= 2) atual.push(atual[0], atual[1]); k += 1; }
          else { reto = false; k = d.length; }
        }
        const xs = subcaminhos.flatMap((p) => p.filter((_, j) => j % 2 === 0));
        const ys = subcaminhos.flatMap((p) => p.filter((_, j) => j % 2 === 1));
        if (xs.length === 0) { proximoEhClip = false; continue; }
        const caixa = { x0: Math.min(...xs), y0: Math.min(...ys), x1: Math.max(...xs), y1: Math.max(...ys) };
        if (proximoEhClip) {
          // Clip retangular (4 cantos alinhados) vira retângulo; o resto é "complexo".
          const pontos = subcaminhos.length === 1 ? subcaminhos[0] : [];
          const retangulo = reto && pontos.length <= 10 && pontos.every((v, j) => (j % 2 === 0 ? v === caixa.x0 || v === caixa.x1 : v === caixa.y0 || v === caixa.y1));
          const anterior = g.clip;
          g.clip = !retangulo || anterior === "complexo" ? "complexo" : anterior ? { x0: Math.max(anterior.x0, caixa.x0), y0: Math.max(anterior.y0, caixa.y0), x1: Math.min(anterior.x1, caixa.x1), y1: Math.min(anterior.y1, caixa.y1) } : caixa;
          proximoEhClip = false;
        }
        const pintura = PINTURA[args[0]];
        if (pintura) {
          const motivo = g.padrao ? "cor por padrão/sombreamento não suportada" : g.tracejado && pintura.traca ? "traço tracejado não suportado" : null;
          vetores.push({
            tipo: "vetor", id: `vetor${i}`, pintura: i, ...caixa, subcaminhos,
            traca: Boolean(pintura.traca), preenche: Boolean(pintura.preenche), parImpar: Boolean(pintura.parImpar),
            corTraco: g.corTraco, corFundo: g.corFundo, larguraTraco: g.largura * escalaDe(g.ctm),
            clip: g.clip, suportada: !motivo, motivo,
          });
        }
      } else if (fn === O.paintImageXObject || fn === O.paintInlineImageXObject) {
        const id = typeof args[0] === "string" ? args[0] : `inline${i}`;
        const img = typeof args[0] === "string" ? await objetoDeImagem(page, args[0]) : args[0];
        const alinhada = Math.abs(g.ctm[1]) < 1e-6 && Math.abs(g.ctm[2]) < 1e-6 && g.ctm[0] > 0 && g.ctm[3] > 0;
        const rgba = img ? paraRgba(img) : null;
        const [x0, y0] = aplicar(g.ctm, 0, 0);
        const [x1, y1] = aplicar(g.ctm, 1, 1);
        imagens.push({
          tipo: "imagem",
          id,
          pintura: i,
          x0: Math.min(x0, x1), y0: Math.min(y0, y1), x1: Math.max(x0, x1), y1: Math.max(y0, y1),
          pxL: img?.width ?? 0,
          pxA: img?.height ?? 0,
          rgba,
          clip: g.clip,
          suportada: alinhada && Boolean(rgba),
          motivo: !alinhada ? "imagem rotacionada/espelhada" : !rgba ? "formato de pixel não suportado" : null,
        });
      }
    }
    const linhas = (debug.find((d) => d.pagina === numero)?.linhas ?? []).map((l) => ({ texto: l.texto, y: l.y, xInicio: l.xInicio, xFim: l.xFim, coluna: l.coluna }));
    paginas.push({ numero, largura: viewport.width, altura: viewport.height, linhas, imagens, vetores });
  }
  await doc.destroy();
  return paginas;
}
