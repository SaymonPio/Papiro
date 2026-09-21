// Arte (imagem) dos quadros do quadrinho didático — lógica PURA (sem JSX, sem React, sem Supabase), para
// poder ser testada com node --test como tiposComponenteAula.ts.
//
// De onde vem: a Edge `assinar-quadrinho-assets` devolve, por aula-versão, só os assets APROVADOS e com a
// cena atual, já com URL ASSINADA e temporária (o bucket quadrinhos-aulas continua privado). Aqui o payload
// externo é tratado como NÃO CONFIÁVEL: qualquer item fora do formato é ignorado, nunca lança.
//
// Chave: componente_id + quadro_indice, onde quadro_indice é o índice ORIGINAL do quadro em
// componente.quadros (QuadroQuadrinho.indiceOriginal), nunca a posição depois de descartar quadros vazios.
//
// Nada aqui guarda/loga storage_path, prompt_visual ou scene_hash: a Edge nem os envia.

export type ArteQuadrinho = { url: string; expiraEm: number };
export type MapaArtes = Record<string, ArteQuadrinho>;

export const ARTE_TTL_SEGUNDOS = 900;
// Renova antes de expirar, com folga (uma vez por carga, sem timer agressivo).
export const ARTE_MARGEM_RENOVACAO_MS = 60_000;
// Renovação após erro de carregamento da imagem: limitada, nunca em loop.
export const ARTE_LIMITE_RENOVACOES_POR_ERRO = 3;
export const ARTE_INTERVALO_MIN_RENOVACAO_MS = 20_000;

const MAX_ARTES = 24;
const MAX_INDICE_QUADRO = 5; // camada ilustrada: quadro_indice entre 0 e 5
const MAX_TAMANHO_URL = 4096;
const REGEX_UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

export function chaveArte(componenteId: string, quadroIndice: number): string {
  return `${componenteId}:${quadroIndice}`;
}

/** id do componente (uuid) quando existir e for válido; senão null (aula antiga/sem id: sem arte, só texto). */
export function idDoComponente(componente: { [chave: string]: unknown }): string | null {
  const id = componente.id;
  return typeof id === "string" && REGEX_UUID.test(id) ? id.toLowerCase() : null;
}

function urlAssinadaSegura(valor: unknown): valor is string {
  if (typeof valor !== "string" || valor.length === 0 || valor.length > MAX_TAMANHO_URL) return false;
  try {
    return new URL(valor).protocol === "https:";
  } catch {
    return false;
  }
}

/**
 * Converte a resposta da Edge em mapa por chave. Defensivo: ignora item inválido, duplicado (vale o primeiro),
 * URL que não seja https, indice fora de 0..5, uuid inválido e artes já expiradas.
 */
export function interpretarRespostaArtes(payload: unknown, agoraMs: number = Date.now()): MapaArtes {
  const mapa: MapaArtes = {};
  if (typeof payload !== "object" || payload === null || Array.isArray(payload)) return mapa;
  const lista = (payload as { assets?: unknown }).assets;
  if (!Array.isArray(lista)) return mapa;
  let total = 0;
  for (const bruto of lista) {
    if (total >= MAX_ARTES) break;
    if (typeof bruto !== "object" || bruto === null || Array.isArray(bruto)) continue;
    const item = bruto as Record<string, unknown>;
    const { componente_id: componenteId, quadro_indice: quadroIndice, url, expira_em: expiraEmBruto } = item;
    if (typeof componenteId !== "string" || !REGEX_UUID.test(componenteId)) continue;
    if (typeof quadroIndice !== "number" || !Number.isInteger(quadroIndice) || quadroIndice < 0 || quadroIndice > MAX_INDICE_QUADRO) continue;
    if (!urlAssinadaSegura(url)) continue;
    if (typeof expiraEmBruto !== "string") continue;
    const expiraEm = Date.parse(expiraEmBruto);
    if (!Number.isFinite(expiraEm) || expiraEm <= agoraMs) continue;
    const chave = chaveArte(componenteId.toLowerCase(), quadroIndice);
    if (chave in mapa) continue;
    mapa[chave] = { url, expiraEm };
    total += 1;
  }
  return mapa;
}

/** Menor expiração do mapa, ou null se não há arte. */
export function menorExpiracao(mapa: MapaArtes): number | null {
  let menor: number | null = null;
  for (const chave of Object.keys(mapa)) {
    const valor = mapa[chave].expiraEm;
    if (menor === null || valor < menor) menor = valor;
  }
  return menor;
}

/** Atraso (ms) até a renovação preventiva; null se não há arte. Nunca negativo. */
export function proximaRenovacaoEmMs(mapa: MapaArtes, agoraMs: number, margemMs: number = ARTE_MARGEM_RENOVACAO_MS): number | null {
  const menor = menorExpiracao(mapa);
  if (menor === null) return null;
  return Math.max(0, menor - margemMs - agoraMs);
}

export type EstadoRenovacao = { tentativas: number; ultimaEm: number | null };

/** Renovação por erro de imagem: no máximo N por carga e com intervalo mínimo — sem retry infinito. */
export function podeRenovar(estado: EstadoRenovacao, agoraMs: number): boolean {
  if (estado.tentativas >= ARTE_LIMITE_RENOVACOES_POR_ERRO) return false;
  if (estado.ultimaEm !== null && agoraMs - estado.ultimaEm < ARTE_INTERVALO_MIN_RENOVACAO_MS) return false;
  return true;
}

/** Alt curto: rótulo do quadro + título do quadrinho (sem repetir a cena, que já aparece como texto). */
export function textoAltArte(numero: number, titulo: string | null): string {
  const limpo = (titulo ?? "").replace(/\*+/g, "").replace(/\s+/g, " ").trim();
  return limpo ? `Ilustração do quadro ${numero}: ${limpo}` : `Ilustração do quadro ${numero}`;
}
