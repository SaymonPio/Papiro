// Storage do executor (bucket privado questao-midias) via Storage API do
// Supabase com a chave service_role — só o importador a tem; nunca vai
// para o app nem para log. Mesma interface do storage em memória dos
// testes: enviar / baixar / remover.
//
// enviar usa x-upsert: false — objeto existente NUNCA é sobrescrito (o
// path é o próprio sha256; o executor confere o conteúdo baixando de volta).

const BUCKET = "questao-midias";

export function criarStorageSupabase({ url, chaveServico, fetch: fetchImpl = globalThis.fetch }) {
  if (!url || !chaveServico) throw new Error("Storage: SUPABASE_URL e SUPABASE_SERVICE_ROLE_KEY são obrigatórias");
  const base = `${url.replace(/\/+$/, "")}/storage/v1/object`;
  const cabecalhos = { Authorization: `Bearer ${chaveServico}`, apikey: chaveServico };
  const caminho = (path) => {
    if (!/^questoes\/[0-9a-f]{64}\.(png|jpg|webp)$/.test(path)) throw new Error(`Storage: path fora do padrão conteúdo-endereçado (${path})`);
    return `${base}/${BUCKET}/${path}`;
  };
  const falha = async (acao, resposta) => {
    const corpo = await resposta.text().catch(() => "");
    return new Error(`Storage: ${acao} falhou (HTTP ${resposta.status}) ${corpo.slice(0, 200)}`);
  };

  return {
    async enviar(path, bytes, mimeType) {
      const resposta = await fetchImpl(caminho(path), {
        method: "POST",
        headers: { ...cabecalhos, "Content-Type": mimeType, "x-upsert": "false", "Cache-Control": "max-age=31536000, immutable" },
        body: bytes,
      });
      if (!resposta.ok) throw await falha("envio", resposta);
    },
    async baixar(path) {
      const resposta = await fetchImpl(caminho(path), { headers: cabecalhos });
      if (!resposta.ok) throw await falha("download", resposta);
      return Buffer.from(await resposta.arrayBuffer());
    },
    async remover(path) {
      const resposta = await fetchImpl(`${base}/${BUCKET}`, {
        method: "DELETE",
        headers: { ...cabecalhos, "Content-Type": "application/json" },
        body: JSON.stringify({ prefixes: [caminho(path).slice(`${base}/${BUCKET}/`.length)] }),
      });
      if (!resposta.ok) throw await falha("remoção", resposta);
    },
  };
}
