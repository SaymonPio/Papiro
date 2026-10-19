// Camada HTTP da Edge assinar-questao-midias, sem Deno: autenticação, leitura AUTORIZADA (client do PRÓPRIO
// usuário, sob RLS de questao_midias) e assinatura entram por `deps` — as regras de segurança são testáveis
// sem o runtime. Mesmo desenho da Edge assinar-quadrinho-assets.
//
// Contrato (POST, verify_jwt ligado):
//   { "questaoIds": [123, 456] }                 (1..50 ids inteiros positivos, sem repetição)
//   200 { "midias": [ { questao_id, ordem, tipo, largura, altura, alt_text, legenda, credito, ancora_texto,
//                       url, expira_em } ] }      ("midias": [] = nenhuma mídia; NÃO é erro)
//         url = null quando a assinatura daquele arquivo falhou — o app mostra "imagem indisponível",
//         nunca some com a mídia em silêncio.
//   400 corpo inválido | 401 sem sessão | 405 método | 500 falha interna
//
// AUTORIZAÇÃO (nunca pelo service_role): a RLS "Midias publicaveis de questoes visiveis" só devolve mídia
// OFICIAL_PROVA/LICENCIADO de questão ATIVA e visível ao usuário (global ou própria) — REVISAO_DIREITOS nunca
// sai daqui. O service_role só assina exatamente os paths que essa leitura devolveu.
//
// A resposta NUNCA contém storage_path, sha256, direito_uso, token nem credencial. Erros são genéricos.

export const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

export const TTL_SEGUNDOS = 900;
export const MAX_QUESTOES = 50;
const MAX_MIDIAS = 200;
const PUBLICAVEIS = new Set(["OFICIAL_PROVA", "LICENCIADO"]);
const PATH_VALIDO = /^questoes\/[0-9a-f]{64}\.(png|jpg|webp)$/;

export function validarEntrada(corpo) {
  if (corpo === null || typeof corpo !== "object" || Array.isArray(corpo)) return { ok: false, mensagem: "Corpo inválido." };
  const ids = corpo.questaoIds;
  if (!Array.isArray(ids) || ids.length === 0 || ids.length > MAX_QUESTOES) return { ok: false, mensagem: `Informe de 1 a ${MAX_QUESTOES} questões.` };
  if (!ids.every((id) => Number.isSafeInteger(id) && id > 0)) return { ok: false, mensagem: "Ids de questão inválidos." };
  return { ok: true, valor: { questaoIds: [...new Set(ids)] } };
}

const textoOuNull = (v) => (typeof v === "string" && v.trim() !== "" ? v : null);

function candidatoValido(linha, pedidos) {
  if (linha === null || typeof linha !== "object") return null;
  const questaoId = Number(linha.questao_id);
  const ordem = Number(linha.ordem);
  if (!pedidos.has(questaoId) || !Number.isInteger(ordem) || ordem < 1) return null;
  if (!PUBLICAVEIS.has(linha.direito_uso)) return null; // defesa extra: a RLS já filtra
  if (typeof linha.storage_path !== "string" || !PATH_VALIDO.test(linha.storage_path)) return null;
  const largura = Number(linha.largura);
  const altura = Number(linha.altura);
  if (!Number.isInteger(largura) || !Number.isInteger(altura) || largura < 1 || altura < 1) return null;
  const altText = textoOuNull(linha.alt_text);
  if (!altText) return null;
  return {
    storagePath: linha.storage_path,
    publico: { questao_id: questaoId, ordem, tipo: String(linha.tipo ?? "FIGURA"), largura, altura, alt_text: altText, legenda: textoOuNull(linha.legenda), credito: textoOuNull(linha.credito), ancora_texto: textoOuNull(linha.ancora_texto) },
  };
}

/**
 * @param {Request} req
 * @param {{
 *   autenticar: (authorization: string | null) => Promise<{ ok: true } | { ok: false, status: 401, mensagem: string }>,
 *   carregarMidias: (questaoIds: number[]) => Promise<any[]>,
 *   assinar: (paths: string[], ttlSegundos: number) => Promise<Array<{ path: string, signedUrl: string | null }>>,
 *   agora?: () => number,
 *   log?: (evento: string, campos: Record<string, unknown>) => void,
 * }} deps
 */
export async function tratarRequisicao(req, deps) {
  const agora = deps.agora ?? Date.now;
  const json = (corpo, status = 200) => new Response(JSON.stringify(corpo), { status, headers: { ...CORS, "Content-Type": "application/json", "Cache-Control": "no-store" } });
  const log = (evento, campos) => {
    try {
      deps.log?.(evento, campos);
    } catch {
      /* log nunca derruba o fluxo */
    }
  };

  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json({ error: "Método não permitido." }, 405);

  let auth;
  try {
    auth = await deps.autenticar(req.headers.get("Authorization"));
  } catch {
    return json({ error: "Falha ao autenticar." }, 500);
  }
  if (!auth.ok) return json({ error: auth.mensagem }, auth.status);

  let entrada;
  try {
    const texto = await req.text();
    entrada = validarEntrada(texto.trim() === "" ? null : JSON.parse(texto));
  } catch {
    return json({ error: "Corpo inválido." }, 400);
  }
  if (!entrada.ok) return json({ error: entrada.mensagem }, 400);
  const pedidos = new Set(entrada.valor.questaoIds);

  let linhas;
  try {
    linhas = await deps.carregarMidias(entrada.valor.questaoIds);
  } catch {
    log("leitura_falhou", { total_pedidos: pedidos.size });
    return json({ error: "Falha ao carregar as mídias." }, 500);
  }

  const vistos = new Set();
  const candidatos = [];
  for (const linha of Array.isArray(linhas) ? linhas : []) {
    const c = candidatoValido(linha, pedidos);
    if (!c) continue;
    const chave = `${c.publico.questao_id}:${c.publico.ordem}`;
    if (vistos.has(chave)) continue;
    vistos.add(chave);
    candidatos.push(c);
    if (candidatos.length >= MAX_MIDIAS) break;
  }
  if (candidatos.length === 0) return json({ midias: [] });

  // ---- service_role SÓ AQUI: assinar exatamente os paths que a leitura autorizada devolveu ----
  let assinados = [];
  try {
    assinados = await deps.assinar([...new Set(candidatos.map((c) => c.storagePath))], TTL_SEGUNDOS);
  } catch {
    log("assinatura_falhou", { total_validos: candidatos.length });
    assinados = []; // segue com url null: o app mostra "indisponível" em vez de esconder a mídia
  }
  const urlPorPath = new Map();
  for (const item of Array.isArray(assinados) ? assinados : []) {
    if (item && typeof item.path === "string" && typeof item.signedUrl === "string" && item.signedUrl.startsWith("https://")) urlPorPath.set(item.path, item.signedUrl);
  }
  const expiraEm = new Date(agora() + TTL_SEGUNDOS * 1000).toISOString();
  const midias = candidatos
    .map((c) => {
      const url = urlPorPath.get(c.storagePath) ?? null;
      return { ...c.publico, url, expira_em: url ? expiraEm : null };
    })
    .sort((a, b) => a.questao_id - b.questao_id || a.ordem - b.ordem);
  log("assinado", { total_validos: candidatos.length, total_assinados: midias.filter((m) => m.url).length });
  return json({ midias });
}
