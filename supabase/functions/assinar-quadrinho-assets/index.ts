import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { tratarRequisicao } from "../_shared/quadrinho-assets/handler.mjs";

// Fase Q12.12 — assina (URL temporária) as artes APROVADAS de uma aula-versão, para o renderer.
//
//   JWT do usuário -> auth.getUser -> RPC do PRÓPRIO usuário (eh_admin + carregar_quadrinho_assets_admin
//   | carregar_quadrinho_assets_aula) -> só então service_role assina exatamente os paths devolvidos.
//
// DEPLOY: verify_jwt precisa ficar LIGADO (padrão do `supabase functions deploy`); nunca usar --no-verify-jwt.
//
// O bucket quadrinhos-aulas continua PRIVADO e sem policies: só esta Edge (service_role) assina.
// service_role NÃO decide acesso: nenhuma consulta de autorização usa o client `admin` abaixo. Validade: 900 s.
// Nunca loga URL, token, Authorization, path nem resposta.

declare const Deno: { env: { get(nome: string): string | undefined }; serve(h: (req: Request) => Response | Promise<Response>): void };

const BUCKET = "quadrinhos-aulas";

function registrar(evento: string, campos: Record<string, unknown>) {
  console.log(JSON.stringify({ fn: "assinar-quadrinho-assets", evento, ...campos }));
}

Deno.serve((req) => {
  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
  const authorization = req.headers.get("Authorization");
  // client DO USUÁRIO: é ele que executa as RPCs de autorização (auth.uid() correto, sem privilégio extra)
  const usuario = authorization ? createClient(supabaseUrl, anonKey, { global: { headers: { Authorization: authorization } } }) : null;

  return tratarRequisicao(req, {
    autenticar: async (auth: string | null) => {
      if (!auth || !usuario) return { ok: false as const, status: 401 as const, mensagem: "Sessão não encontrada." };
      const { data: { user } } = await usuario.auth.getUser(auth.replace("Bearer ", ""));
      if (!user) return { ok: false as const, status: 401 as const, mensagem: "Sessão inválida." };
      return { ok: true as const };
    },

    ehAdmin: async () => {
      const { data } = await usuario!.rpc("eh_admin");
      return data === true;
    },

    carregarAssetsAdmin: async (aulaVersaoId: string) => {
      const { data, error } = await usuario!.rpc("carregar_quadrinho_assets_admin", { p_aula_versao_id: aulaVersaoId });
      if (error) throw new Error("rpc_admin");
      return (data as any[] | null) ?? [];
    },

    carregarAssetsAluno: async (missaoId: string, aulaVersaoId: string) => {
      const { data, error } = await usuario!.rpc("carregar_quadrinho_assets_aula", { p_missao_id: missaoId, p_aula_versao_id: aulaVersaoId });
      if (error) throw new Error("rpc_aluno");
      return (data as any[] | null) ?? [];
    },

    // ÚNICO uso do service_role: assinar os paths que as RPCs autorizadas acima devolveram (em lote, sem N+1).
    assinar: async (paths: string[], ttlSegundos: number) => {
      const admin = createClient(supabaseUrl, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
      const { data, error } = await admin.storage.from(BUCKET).createSignedUrls(paths, ttlSegundos);
      if (error) throw new Error("assinatura");
      return (data ?? []).map((item: { path: string | null; signedUrl: string | null }) => ({ path: item.path ?? "", signedUrl: item.signedUrl ?? null }));
    },

    log: registrar,
  });
});
