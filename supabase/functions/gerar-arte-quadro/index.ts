import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { tratarRequisicao } from "../_shared/quadrinho-imagem/handler.mjs";
import { resolverConfiguracaoImagem } from "../_shared/quadrinho-imagem/config.mjs";
import { gerarImagemOpenAI } from "../_shared/quadrinho-imagem/openaiImage.mjs";
import { sanitizarFalhaImagem } from "../_shared/quadrinho-imagem/sanitizar.mjs";
import { processarAsset } from "../_shared/quadrinho-imagem/worker.mjs";

// Fase Q12.1 — gera a arte (WebP) de UM quadro de quadrinho_didatico por invocação.
//
//   admin (JWT) -> eh_admin() -> reservar_quadrinho_asset (claim, RPC do Q10)
//     -> responde 202 -> EdgeRuntime.waitUntil(processamento):
//        prompt determinístico -> OpenAI Image API -> valida WebP -> upload (upsert:false)
//        -> concluir_quadrinho_asset | falhar_quadrinho_asset (a RPC decide retry/erro).
//
// DEPLOY: verify_jwt precisa ficar LIGADO (o padrão do `supabase functions deploy`); nunca
// usar --no-verify-jwt. Não há supabase/config.toml no repositório, então o padrão é a
// única garantia — além da checagem explícita de sessão + eh_admin() abaixo.
//
// Só o service_role (client `admin`) chama as RPCs de worker e o Storage; o browser nunca
// recebe credencial. A autorização usa o client do PRÓPRIO usuário (auth.uid() correto).
// A lógica de estado (claim, lease, tentativas, fencing) vive no SQL — aqui não há mutex.
// Processo morto de forma abrupta: lease + retry + GC de uploads órfãos (Q11) cobrem.

declare const EdgeRuntime: { waitUntil(tarefa: Promise<unknown>): void };

const BUCKET = "quadrinhos-aulas";

function registrar(evento: string, campos: Record<string, unknown>) {
  // `campos` já passou pela lista branca (camposDeLogSeguros); nada de token/prompt/path/base64.
  console.log(JSON.stringify({ fn: "gerar-arte-quadro", evento, ...campos }));
}

// Segurança de processo: rejeição não tratada em background nunca deve vazar detalhe bruto.
addEventListener("unhandledrejection", (ev: any) => {
  ev.preventDefault?.();
  registrar("rejeicao_nao_tratada", { erro: sanitizarFalhaImagem(ev?.reason) });
});
addEventListener("beforeunload", (ev: any) => {
  registrar("shutdown", { motivo: String(ev?.detail?.reason ?? "desconhecido") });
});

Deno.serve((req) => {
  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const openaiKey = Deno.env.get("OPENAI_API_KEY");
  const config = resolverConfiguracaoImagem((nome: string) => Deno.env.get(nome));
  const admin = createClient(supabaseUrl, serviceKey);

  const rpc = async (nome: string, args: Record<string, unknown>) => {
    const { data, error } = await admin.rpc(nome, args);
    if (error) throw new Error(error.message);
    return data;
  };

  const falhar = ({ assetId, claimToken, erro }: { assetId: string; claimToken: string; erro: string }) =>
    rpc("falhar_quadrinho_asset", { p_asset_id: assetId, p_claim_token: claimToken, p_erro: erro });

  return tratarRequisicao(req, {
    autorizarAdmin: async (authorization: string | null) => {
      if (!authorization) return { ok: false, status: 401, mensagem: "Sessão não encontrada." };
      const auth = createClient(supabaseUrl, anonKey, { global: { headers: { Authorization: authorization } } });
      const { data: { user } } = await auth.auth.getUser(authorization.replace("Bearer ", ""));
      if (!user) return { ok: false, status: 401, mensagem: "Sessão inválida." };
      const { data: souAdmin } = await auth.rpc("eh_admin");
      if (!souAdmin) return { ok: false, status: 403, mensagem: "Apenas administradores podem gerar a arte dos quadros." };
      return { ok: true };
    },

    reservar: async (aulaVersaoId: string | null) => {
      // Sem chave não reservamos: evita consumir tentativa de um job que não pode ser gerado.
      if (!openaiKey) throw new Error("OPENAI_API_KEY ausente");
      const linhas = await rpc("reservar_quadrinho_asset", aulaVersaoId ? { p_aula_versao_id: aulaVersaoId } : {});
      return Array.isArray(linhas) && linhas.length > 0 ? linhas[0] : null;
    },

    processar: (claim: any) =>
      processarAsset({
        claim,
        config,
        deps: {
          // Só as CENAS do componente são usadas (extrairCenas descarta falas/legendas/fechamento).
          obterComponente: (aulaVersaoId: string, componenteId: string) => rpc("quadrinho_componente", { p_aula_versao_id: aulaVersaoId, p_componente_id: componenteId }),
          gerarImagem: ({ prompt, config: cfg }: { prompt: string; config: unknown }) => gerarImagemOpenAI({ prompt, config: cfg, apiKey: openaiKey }),
          // upsert:false — nunca sobrescreve; o path é EXATAMENTE o storage_path_esperado do claim.
          uploadWebp: ({ path, bytes }: { path: string; bytes: Uint8Array }) => admin.storage.from(BUCKET).upload(path, bytes, { contentType: "image/webp", upsert: false }),
          removerObjeto: (path: string) => admin.storage.from(BUCKET).remove([path]),
          concluir: async (a: { assetId: string; claimToken: string; sceneHash: string; storagePath: string; modelo: string; promptVersion: string; promptVisual: string }) => {
            const linhas = await rpc("concluir_quadrinho_asset", {
              p_asset_id: a.assetId,
              p_claim_token: a.claimToken,
              p_scene_hash: a.sceneHash,
              p_storage_path: a.storagePath,
              p_modelo: a.modelo,
              p_prompt_version: a.promptVersion,
              p_prompt_visual: a.promptVisual,
            });
            return Array.isArray(linhas) ? linhas[0] : linhas;
          },
          falhar,
          log: registrar,
        },
      }),

    // EdgeRuntime.waitUntil: o processamento longo segue depois do 202 (limites de wall-clock do Supabase valem).
    agendar: (tarefa: Promise<unknown>) => EdgeRuntime.waitUntil(tarefa),

    liberarClaim: (claim: any, erro: string) => falhar({ assetId: claim.asset_id, claimToken: claim.claim_token, erro }),
    log: registrar,
  });
});
