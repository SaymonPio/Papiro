// Camada HTTP da Edge gerar-arte-quadro (Fase Q12.1), sem Deno: autenticação, claim e
// agendamento entram por `deps`, então "responde 202 ANTES do trabalho terminar" e
// "exatamente uma task por claim" são testáveis sem o runtime real.
//
// Contrato:
//   405 método != POST | 401 sem sessão | 403 não-admin | 400 corpo inválido
//   200 {accepted:false} nenhum job elegível (nada agendado)
//   202 {accepted:true, asset_id, quadro_indice, tentativa} job reservado, trabalho em background
//   500 falha antes do agendamento (o claim, se existiu, é devolvido via falhar)
// Nunca devolvemos claim_token, prompt, path, base64, resposta da OpenAI ou credencial.

import { sanitizarFalhaImagem } from "./sanitizar.mjs";

export const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const REGEX_UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

// O cliente só pode (opcionalmente) restringir o claim a uma versão de aula; tudo o mais vem do servidor.
const CAMPOS_PROIBIDOS = ["asset_id", "assetId", "claim_token", "claimToken", "storage_path", "storagePath", "scene_hash", "sceneHash", "tentativas", "tentativa", "prompt", "modelo", "model"];

/**
 * @param {Request} req
 * @param {{
 *   autorizarAdmin: (authorization: string | null) => Promise<{ ok: true } | { ok: false, status: 401 | 403, mensagem: string }>,
 *   reservar: (aulaVersaoId: string | null) => Promise<null | { asset_id: string, quadro_indice: number, tentativa: number, claim_token: string, storage_path_esperado: string }>,
 *   processar: (claim: any) => Promise<unknown>,
 *   agendar: (tarefa: Promise<unknown>) => void,
 *   liberarClaim: (claim: any, erro: string) => Promise<unknown>,
 *   log?: (evento: string, campos: Record<string, unknown>) => void,
 * }} deps
 */
export async function tratarRequisicao(req, deps) {
  const json = (corpo, status = 200) => new Response(JSON.stringify(corpo), { status, headers: { ...CORS, "Content-Type": "application/json" } });

  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json({ error: "Método não permitido." }, 405);

  let auth;
  try {
    auth = await deps.autorizarAdmin(req.headers.get("Authorization"));
  } catch {
    return json({ error: "Falha ao autorizar." }, 500);
  }
  if (!auth.ok) return json({ error: auth.mensagem }, auth.status);

  let aulaVersaoId = null;
  try {
    const texto = await req.text();
    const corpo = texto.trim() === "" ? {} : JSON.parse(texto);
    if (corpo === null || typeof corpo !== "object" || Array.isArray(corpo)) return json({ error: "Corpo inválido." }, 400);
    const proibido = CAMPOS_PROIBIDOS.find((campo) => campo in corpo);
    if (proibido) return json({ error: `Campo não permitido: ${proibido}.` }, 400);
    if (corpo.aulaVersaoId !== undefined) {
      if (typeof corpo.aulaVersaoId !== "string" || !REGEX_UUID.test(corpo.aulaVersaoId)) return json({ error: "aulaVersaoId inválido." }, 400);
      aulaVersaoId = corpo.aulaVersaoId;
    }
  } catch {
    return json({ error: "Corpo inválido." }, 400);
  }

  // Claim: SÓ pela RPC do Q10 (SKIP LOCKED + claim_token + lease). Nenhum mutex em memória.
  let claim;
  try {
    claim = await deps.reservar(aulaVersaoId);
  } catch (erro) {
    deps.log?.("reserva_falhou", { erro: sanitizarFalhaImagem(erro) });
    return json({ error: "Falha ao reservar o quadro." }, 500);
  }
  if (!claim) return json({ accepted: false, motivo: "sem_job_elegivel" }, 200);

  // Exatamente UMA task por claim; o worker nunca rejeita (e o catch abaixo é só cinto e suspensório).
  try {
    const tarefa = Promise.resolve()
      .then(() => deps.processar(claim))
      .catch((erro) => deps.log?.("processamento_rejeitado", { erro: sanitizarFalhaImagem(erro, { literais: [claim.claim_token, claim.storage_path_esperado] }) }));
    deps.agendar(tarefa);
  } catch (erro) {
    // Não conseguimos agendar: devolve o job imediatamente (retry pela RPC) em vez de deixá-lo `gerando` até o lease vencer.
    try {
      await deps.liberarClaim(claim, sanitizarFalhaImagem(erro, { literais: [claim.claim_token, claim.storage_path_esperado] }));
    } catch {
      /* lease + retry cobrem */
    }
    return json({ error: "Falha ao iniciar a geração." }, 500);
  }

  return json({ accepted: true, asset_id: claim.asset_id, quadro_indice: claim.quadro_indice, tentativa: claim.tentativa }, 202);
}
