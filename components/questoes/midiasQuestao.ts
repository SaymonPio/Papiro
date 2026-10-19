// Mídias das questões (figura, gráfico, charge...) — lógica PURA (sem JSX, sem React, sem Supabase), testável
// com node --test como components/teoria/arteQuadrinho.ts.
//
// Duas fontes, nunca confiadas às cegas:
//   1) metadados: SELECT em questao_midias com o client do aluno — a RLS só devolve mídia publicável de questão
//      ativa e visível. É a FONTE DE VERDADE de quais mídias a questão tem;
//   2) URLs: Edge assinar-questao-midias (URL assinada e temporária; bucket privado).
// Mídia que existe nos metadados mas ficou sem URL (Edge fora, assinatura falhou, URL expirada) NUNCA some em
// silêncio: vira "indisponível" na tela, com o texto alternativo.
//
// Posição semântica: ancora_texto = linha do enunciado ANTES da qual a mídia aparece (gravada pelo importador a
// partir da geometria do PDF). Sem âncora, ou âncora que não bate mais com o enunciado: depois do enunciado,
// antes das alternativas — nunca descartada.

export type MidiaQuestao = {
  questaoId: number;
  ordem: number;
  tipo: string;
  largura: number;
  altura: number;
  altText: string;
  legenda: string | null;
  credito: string | null;
  ancoraTexto: string | null;
  url: string | null;
  expiraEm: number | null;
};

export type SegmentoEnunciado = { tipo: "texto"; texto: string } | { tipo: "midia"; midia: MidiaQuestao };

const MAX_TAMANHO_URL = 4096;
const textoOuNull = (v: unknown): string | null => (typeof v === "string" && v.trim() !== "" ? v : null);

function inteiroPositivo(v: unknown): number | null {
  const n = typeof v === "string" && /^\d+$/.test(v) ? Number(v) : v;
  return typeof n === "number" && Number.isInteger(n) && n > 0 ? n : null;
}

function urlHttps(valor: unknown): string | null {
  if (typeof valor !== "string" || valor.length === 0 || valor.length > MAX_TAMANHO_URL) return null;
  try {
    return new URL(valor).protocol === "https:" ? valor : null;
  } catch {
    return null;
  }
}

/** Metadados (linhas de questao_midias via RLS) -> mapa questão -> mídias ordenadas, ainda sem URL. Defensivo. */
export function interpretarMetadadosMidias(linhas: unknown): Map<number, MidiaQuestao[]> {
  const mapa = new Map<number, MidiaQuestao[]>();
  if (!Array.isArray(linhas)) return mapa;
  for (const bruta of linhas) {
    if (typeof bruta !== "object" || bruta === null) continue;
    const l = bruta as Record<string, unknown>;
    const questaoId = inteiroPositivo(l.questao_id);
    const ordem = inteiroPositivo(l.ordem);
    const largura = inteiroPositivo(l.largura);
    const altura = inteiroPositivo(l.altura);
    const altText = textoOuNull(l.alt_text);
    if (!questaoId || !ordem || !largura || !altura || !altText) continue;
    const lista = mapa.get(questaoId) ?? [];
    if (lista.some((m) => m.ordem === ordem)) continue;
    lista.push({
      questaoId,
      ordem,
      tipo: textoOuNull(l.tipo) ?? "FIGURA",
      largura,
      altura,
      altText,
      legenda: textoOuNull(l.legenda),
      credito: textoOuNull(l.credito),
      ancoraTexto: textoOuNull(l.ancora_texto),
      url: null,
      expiraEm: null,
    });
    mapa.set(questaoId, lista);
  }
  for (const lista of mapa.values()) lista.sort((a, b) => a.ordem - b.ordem);
  return mapa;
}

/** Junta as URLs da Edge aos metadados por (questão, ordem). URL inválida/expirada = sem URL ("indisponível"). */
export function aplicarUrlsAssinadas(mapa: Map<number, MidiaQuestao[]>, payload: unknown, agoraMs: number = Date.now()): Map<number, MidiaQuestao[]> {
  const urls = new Map<string, { url: string; expiraEm: number }>();
  const lista = typeof payload === "object" && payload !== null && !Array.isArray(payload) ? (payload as { midias?: unknown }).midias : null;
  if (Array.isArray(lista)) {
    for (const bruto of lista) {
      if (typeof bruto !== "object" || bruto === null) continue;
      const item = bruto as Record<string, unknown>;
      const questaoId = inteiroPositivo(item.questao_id);
      const ordem = inteiroPositivo(item.ordem);
      const url = urlHttps(item.url);
      const expiraEm = typeof item.expira_em === "string" ? Date.parse(item.expira_em) : NaN;
      if (!questaoId || !ordem || !url || !Number.isFinite(expiraEm) || expiraEm <= agoraMs) continue;
      urls.set(`${questaoId}:${ordem}`, { url, expiraEm });
    }
  }
  const resultado = new Map<number, MidiaQuestao[]>();
  for (const [questaoId, midias] of mapa) {
    resultado.set(
      questaoId,
      midias.map((m) => {
        const assinada = urls.get(`${questaoId}:${m.ordem}`);
        return { ...m, url: assinada?.url ?? null, expiraEm: assinada?.expiraEm ?? null };
      }),
    );
  }
  return resultado;
}

/**
 * Enunciado -> segmentos de texto e mídia, na posição semântica. A âncora casa com a linha do enunciado
 * (comparação sem espaços nas pontas); mídias da mesma âncora mantêm a ordem. Nada é descartado.
 */
export function segmentarEnunciado(enunciado: string, midias: MidiaQuestao[]): SegmentoEnunciado[] {
  const linhas = enunciado.split("\n");
  const antesDaLinha = new Map<number, MidiaQuestao[]>();
  const noFim: MidiaQuestao[] = [];
  for (const midia of [...midias].sort((a, b) => a.ordem - b.ordem)) {
    const indice = midia.ancoraTexto ? linhas.findIndex((linha) => linha.trim() === midia.ancoraTexto!.trim()) : -1;
    if (indice >= 0) antesDaLinha.set(indice, [...(antesDaLinha.get(indice) ?? []), midia]);
    else noFim.push(midia);
  }
  const segmentos: SegmentoEnunciado[] = [];
  let buffer: string[] = [];
  const descarregar = () => {
    if (buffer.length > 0) segmentos.push({ tipo: "texto", texto: buffer.join("\n") });
    buffer = [];
  };
  linhas.forEach((linha, indice) => {
    const aqui = antesDaLinha.get(indice);
    if (aqui) {
      descarregar();
      for (const midia of aqui) segmentos.push({ tipo: "midia", midia });
    }
    buffer.push(linha);
  });
  descarregar();
  for (const midia of noFim) segmentos.push({ tipo: "midia", midia });
  return segmentos;
}

/** Menor expiração entre as URLs presentes (para renovar antes de vencer); null se nenhuma. */
export function menorExpiracaoMidias(mapa: Map<number, MidiaQuestao[]>): number | null {
  let menor: number | null = null;
  for (const lista of mapa.values()) for (const m of lista) if (m.expiraEm !== null && (menor === null || m.expiraEm < menor)) menor = m.expiraEm;
  return menor;
}
