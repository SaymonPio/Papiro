import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const cors = { "Access-Control-Allow-Origin": "*", "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type" };

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  const json = (body: unknown, status = 200) => new Response(JSON.stringify(body), { status, headers: { ...cors, "Content-Type": "application/json" } });
  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  let editalId = "";
  try {
    const openaiKey = Deno.env.get("OPENAI_API_KEY");
    const authorization = req.headers.get("Authorization");
    if (!openaiKey) return json({ error: "Chave da OpenAI não configurada." }, 500);
    if (!authorization) return json({ error: "Sessão não encontrada." }, 401);
    const auth = createClient(supabaseUrl, Deno.env.get("SUPABASE_ANON_KEY")!);
    const { data: { user } } = await auth.auth.getUser(authorization.replace("Bearer ", ""));
    if (!user) return json({ error: "Sessão inválida." }, 401);
    ({ editalId } = await req.json());
    if (!editalId) return json({ error: "Edital não informado." }, 400);

    const admin = createClient(supabaseUrl, serviceKey);
    const { data: edital } = await admin.from("editais").select("id, usuario_id, arquivo_nome, arquivo_path").eq("id", editalId).eq("usuario_id", user.id).single();
    if (!edital) return json({ error: "Edital não encontrado." }, 404);
    await admin.from("editais").update({ status: "processando", erro_processamento: null, atualizado_em: new Date().toISOString() }).eq("id", editalId);
    const { data: assinatura, error: erroAssinatura } = await admin.storage.from("editais").createSignedUrl(edital.arquivo_path, 600);
    if (erroAssinatura || !assinatura?.signedUrl) throw new Error("Não foi possível acessar o PDF.");

    const api = await fetch("https://api.openai.com/v1/responses", { method: "POST", headers: { "Authorization": `Bearer ${openaiKey}`, "Content-Type": "application/json" }, body: JSON.stringify({
      model: "gpt-5.6-luna", text: { format: { type: "json_object" } },
      input: [{ role: "user", content: [
        { type: "input_text", text: `Você é o analista de editais do Método Papiro. Leia integralmente o PDF e responda somente em JSON válido: {"concurso":"", "cargo":"", "banca":"", "data_prova":"AAAA-MM-DD ou null", "resumo":"", "materias":[{"materia":"", "conteudo_programatico":[""], "peso":null, "ordem":1}]}. Não invente informações. Preserve todos os tópicos do conteúdo programático e use português do Brasil.` },
        { type: "input_file", file_url: assinatura.signedUrl, detail: "low" }
      ] }]
    }) });
    const resultado = await api.json();
    if (!api.ok) throw new Error(resultado?.error?.message || "Falha na leitura pela IA.");
    const texto = resultado.output?.flatMap((item: any) => item.content || []).find((item: any) => item.type === "output_text")?.text;
    if (!texto) throw new Error("A IA não retornou o conteúdo esperado.");
    const dados = JSON.parse(texto);
    await admin.from("edital_materias").delete().eq("edital_id", editalId);
    if (Array.isArray(dados.materias) && dados.materias.length) await admin.from("edital_materias").insert(dados.materias.map((m: any, i: number) => ({ edital_id: editalId, materia: m.materia, conteudo_programatico: Array.isArray(m.conteudo_programatico) ? m.conteudo_programatico : [], peso: m.peso ?? null, ordem: m.ordem ?? i + 1 })));
    await admin.from("editais").update({ status: "concluido", concurso: dados.concurso || null, cargo: dados.cargo || null, banca: dados.banca || null, data_prova: dados.data_prova || null, resumo: dados.resumo || null, atualizado_em: new Date().toISOString() }).eq("id", editalId);
    return json({ ok: true });
  } catch (erro) {
    if (editalId) await createClient(supabaseUrl, serviceKey).from("editais").update({ status: "erro", erro_processamento: erro instanceof Error ? erro.message : "Erro inesperado", atualizado_em: new Date().toISOString() }).eq("id", editalId);
    return json({ error: erro instanceof Error ? erro.message : "Erro inesperado" }, 500);
  }
});
