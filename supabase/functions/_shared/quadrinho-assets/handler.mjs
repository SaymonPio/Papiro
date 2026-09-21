// Camada HTTP da Edge assinar-quadrinho-assets (Fase Q12.12), sem Deno: autenticação, autorização (RPCs do
// PRÓPRIO usuário) e assinatura entram por `deps`, então as regras de segurança são testáveis sem o runtime.
//
// Contrato (POST, verify_jwt ligado):
//   admin: { "modo": "admin", "aulaVersaoId": "<uuid>" }
//   aluno: { "modo": "aluno", "aulaVersaoId": "<uuid>", "missaoId": "<uuid>" }
//   200 { "assets": [ { componente_id, quadro_indice, url, expira_em } ] }   ("assets": [] = sem arte; NÃO é erro)
//   400 corpo inválido | 401 sem sessão | 403 não-admin / sem acesso | 405 método | 500 falha interna
//
// AUTORIZAÇÃO (nunca pelo service_role):
//   - admin: eh_admin() com o client do usuário, depois carregar_quadrinho_assets_admin com o client do usuário;
//     a Edge filtra status='aprovada' + asset_atual=true + storage_path presente (a RPC admin devolve tudo).
//   - aluno: carregar_quadrinho_assets_aula(missao, versao) com o client do usuário — a RPC já impõe matrícula
//     ativa, missão do usuário, versão PUBLICADA e acessível, asset aprovado e scene_hash atual. Sem bypass.
//   O service_role só assina os paths que essas RPCs devolveram (deps.assinar), nunca decide acesso.
//
// A resposta NUNCA contém storage_path, storage_path_anterior, prompt_visual, scene_hash, modelo, token nem
// credencial. Erros são genéricos (nada de mensagem bruta do banco/Storage).

import { validarEntrada } from "./entrada.mjs";

export const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

export const TTL_SEGUNDOS = 900;
const MAX_ASSETS = 24;
const MAX_QUADRO_INDICE = 5;
const REGEX_UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

function candidatoValido(linha) {
  if (linha === null || typeof linha !== "object") return null;
  const { componente_id: componenteId, quadro_indice: quadroIndice, storage_path: storagePath } = linha;
  if (typeof componenteId !== "string" || !REGEX_UUID.test(componenteId)) return null;
  const indice = typeof quadroIndice === "string" && /^\d+$/.test(quadroIndice) ? Number(quadroIndice) : quadroIndice;
  if (typeof indice !== "number" || !Number.isInteger(indice) || indice < 0 || indice > MAX_QUADRO_INDICE) return null;
  if (typeof storagePath !== "string" || storagePath.trim() === "" || storagePath.startsWith("/") || storagePath.includes("..")) return null;
  return { componenteId: componenteId.toLowerCase(), quadroIndice: indice, storagePath };
}

/**
 * @param {Request} req
 * @param {{
 *   autenticar: (authorization: string | null) => Promise<{ ok: true } | { ok: false, status: 401, mensagem: string }>,
 *   ehAdmin: () => Promise<boolean>,
 *   carregarAssetsAdmin: (aulaVersaoId: string) => Promise<any[]>,
 *   carregarAssetsAluno: (missaoId: string, aulaVersaoId: string) => Promise<any[]>,
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
  const { modo, aulaVersaoId, missaoId } = entrada.valor;

  // ---- autorização + leitura pelas RPCs do PRÓPRIO usuário ----
  let linhas;
  if (modo === "admin") {
    let admin = false;
    try {
      admin = (await deps.ehAdmin()) === true;
    } catch {
      return json({ error: "Falha ao verificar permissão." }, 500);
    }
    if (!admin) return json({ error: "Apenas administradores." }, 403);
    try {
      const todas = await deps.carregarAssetsAdmin(aulaVersaoId);
      // a RPC admin devolve TODOS os status: só arte aprovada e com a cena atual sai daqui
      linhas = (Array.isArray(todas) ? todas : []).filter(
        (l) => l && l.status === "aprovada" && l.asset_atual === true && (l.aula_versao_id === undefined || l.aula_versao_id === aulaVersaoId),
      );
    } catch {
      log("rpc_admin_falhou", { modo });
      return json({ error: "Falha ao carregar as artes." }, 500);
    }
  } else {
    try {
      const devolvidas = await deps.carregarAssetsAluno(missaoId, aulaVersaoId);
      // a RPC do aluno já devolve só aprovado + versão publicada + scene_hash atual; nenhum filtro é afrouxado aqui
      linhas = (Array.isArray(devolvidas) ? devolvidas : []).filter((l) => l && (l.status === undefined || l.status === "aprovada"));
    } catch {
      // missão/matrícula inválidas levantam exceção na RPC: sem acesso, sem detalhe
      log("rpc_aluno_recusada", { modo });
      return json({ error: "Sem acesso às artes desta aula." }, 403);
    }
  }

  // ---- normaliza, remove duplicados e limita ----
  const vistos = new Set();
  const candidatos = [];
  for (const linha of linhas) {
    const c = candidatoValido(linha);
    if (!c) continue;
    const chave = `${c.componenteId}:${c.quadroIndice}`;
    if (vistos.has(chave)) continue;
    vistos.add(chave);
    candidatos.push(c);
    if (candidatos.length >= MAX_ASSETS) break;
  }
  if (candidatos.length === 0) {
    log("sem_arte", { modo, total_rpc: linhas.length });
    return json({ assets: [] });
  }

  // ---- service_role SÓ AQUI: assinar exatamente os paths que a RPC autorizada devolveu ----
  let assinados;
  try {
    assinados = await deps.assinar(candidatos.map((c) => c.storagePath), TTL_SEGUNDOS);
  } catch {
    log("assinatura_falhou", { modo, total_validos: candidatos.length });
    return json({ error: "Falha ao assinar as artes." }, 500);
  }
  const urlPorPath = new Map();
  for (const item of Array.isArray(assinados) ? assinados : []) {
    if (item && typeof item.path === "string" && typeof item.signedUrl === "string" && item.signedUrl.startsWith("https://")) urlPorPath.set(item.path, item.signedUrl);
  }
  const expiraEm = new Date(agora() + TTL_SEGUNDOS * 1000).toISOString();
  const assets = [];
  for (const c of candidatos) {
    const url = urlPorPath.get(c.storagePath);
    if (url) assets.push({ componente_id: c.componenteId, quadro_indice: c.quadroIndice, url, expira_em: expiraEm });
  }
  log("assinado", { modo, total_rpc: linhas.length, total_validos: candidatos.length, total_assinados: assets.length });
  return json({ assets });
}
