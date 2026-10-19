import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { tratarRequisicao } from "../_shared/questao-midias/handler.mjs";

// Assina (URL temporária) as mídias PUBLICÁVEIS das questões pedidas, para a tela de questões.
//
//   JWT do usuário -> auth.getUser -> SELECT em questao_midias com o client DO USUÁRIO (RLS decide o acesso)
//   -> só então service_role assina exatamente os paths devolvidos.
//
// DEPLOY: verify_jwt precisa ficar LIGADO (padrão do `supabase functions deploy`); nunca usar --no-verify-jwt.
//
// O bucket questao-midias é PRIVADO e sem policies: só esta Edge (service_role) assina e o importador grava.
// service_role NÃO decide acesso. Validade: 900 s. Nunca loga URL, token, Authorization, path nem resposta.

declare const Deno: { env: { get(nome: string): string | undefined }; serve(h: (req: Request) => Response | Promise<Response>): void };

const BUCKET = "questao-midias";

function registrar(evento: string, campos: Record<string, unknown>) {
  console.log(JSON.stringify({ fn: "assinar-questao-midias", evento, ...campos }));
}

Deno.serve((req) => {
  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
  const authorization = req.headers.get("Authorization");
  // client DO USUÁRIO: a RLS de questao_midias é aplicada com o auth.uid() dele, sem privilégio extra
  const usuario = authorization ? createClient(supabaseUrl, anonKey, { global: { headers: { Authorization: authorization } } }) : null;

  return tratarRequisicao(req, {
    autenticar: async (auth: string | null) => {
      if (!auth || !usuario) return { ok: false as const, status: 401 as const, mensagem: "Sessão não encontrada." };
      const { data: { user } } = await usuario.auth.getUser(auth.replace("Bearer ", ""));
      if (!user) return { ok: false as const, status: 401 as const, mensagem: "Sessão inválida." };
      return { ok: true as const };
    },

    carregarMidias: async (questaoIds: number[]) => {
      const { data, error } = await usuario!
        .from("questao_midias")
        .select("questao_id, ordem, tipo, storage_path, largura, altura, alt_text, legenda, credito, ancora_texto, direito_uso")
        .in("questao_id", questaoIds);
      if (error) throw new Error("leitura");
      return (data as any[] | null) ?? [];
    },

    // ÚNICO uso do service_role: assinar os paths que a leitura autorizada acima devolveu (em lote, sem N+1).
    assinar: async (paths: string[], ttlSegundos: number) => {
      const admin = createClient(supabaseUrl, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
      const { data, error } = await admin.storage.from(BUCKET).createSignedUrls(paths, ttlSegundos);
      if (error) throw new Error("assinatura");
      return (data ?? []).map((item: { path: string | null; signedUrl: string | null }) => ({ path: item.path ?? "", signedUrl: item.signedUrl ?? null }));
    },

    log: registrar,
  });
});
