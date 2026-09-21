// Adaptador isolado da OpenAI Image API (Fase Q12.1).
//
// fetch direto (nenhuma dependência nova). POST /v1/images/generations — geração
// from-scratch por texto; cada quadro é independente, então não usamos a Responses API
// (nada de estado de conversa). Só parâmetros da documentação oficial atual:
// model, prompt, size, quality, output_format, output_compression, n. WebP direto na
// origem (sem transcodificação local). Resposta: data[0].b64_json.
//
// O corpo/base64 NUNCA é logado nem persistido; erros HTTP só carregam status e uma
// mensagem curta já mascarada. Timeout central por AbortController.

import { sanitizarFalhaImagem } from "./sanitizar.mjs";
import { decodificarBase64Estrito, ErroImagem } from "./webp.mjs";

export const OPENAI_IMAGES_ENDPOINT = "https://api.openai.com/v1/images/generations";

/**
 * @param {{ prompt: string, config: { model: string, size: string, quality: string, outputFormat: string, outputCompression: number } }} entrada
 */
export function montarCorpoRequisicaoImagem({ prompt, config }) {
  return {
    model: config.model,
    prompt,
    size: config.size,
    quality: config.quality,
    output_format: config.outputFormat,
    output_compression: config.outputCompression,
    n: 1,
  };
}

async function lerMensagemDeErro(resposta) {
  try {
    const texto = (await resposta.text()).slice(0, 600);
    try {
      const json = JSON.parse(texto);
      return typeof json?.error?.message === "string" ? json.error.message : texto;
    } catch {
      return texto;
    }
  } catch {
    return "";
  }
}

/**
 * @param {{ prompt: string, config: any, apiKey: string | undefined, fetchImpl?: typeof fetch }} entrada
 * @returns {Promise<Uint8Array>} bytes decodificados (ainda NÃO validados como WebP)
 */
export async function gerarImagemOpenAI({ prompt, config, apiKey, fetchImpl = globalThis.fetch }) {
  if (typeof apiKey !== "string" || apiKey.trim() === "") throw new ErroImagem("OPENAI_KEY_AUSENTE");

  const controlador = new AbortController();
  const timer = setTimeout(() => controlador.abort(), config.timeoutMs);
  let resposta;
  try {
    resposta = await fetchImpl(OPENAI_IMAGES_ENDPOINT, {
      method: "POST",
      headers: { "Content-Type": "application/json", Authorization: `Bearer ${apiKey}` },
      body: JSON.stringify(montarCorpoRequisicaoImagem({ prompt, config })),
      signal: controlador.signal,
    });

    if (!resposta.ok) {
      const bruta = await lerMensagemDeErro(resposta);
      throw new ErroImagem(`OPENAI_HTTP_${resposta.status}`, sanitizarFalhaImagem(bruta, { literais: [apiKey] }));
    }

    let json;
    try {
      json = await resposta.json();
    } catch {
      throw new ErroImagem("OPENAI_JSON_INVALIDO");
    }
    if (!json || !Array.isArray(json.data) || json.data.length !== 1) throw new ErroImagem("OPENAI_RESPOSTA_SEM_IMAGEM", "esperada exatamente 1 imagem");
    const b64 = json.data[0]?.b64_json;
    if (typeof b64 !== "string" || b64.length === 0) throw new ErroImagem("OPENAI_RESPOSTA_SEM_IMAGEM", "b64_json ausente");
    return decodificarBase64Estrito(b64);
  } catch (erro) {
    if (erro instanceof ErroImagem) throw erro;
    if (controlador.signal.aborted) throw new ErroImagem("IMAGEM_TIMEOUT", `sem resposta em ${config.timeoutMs} ms`);
    throw new ErroImagem("OPENAI_REDE", sanitizarFalhaImagem(erro, { literais: [apiKey] }));
  } finally {
    clearTimeout(timer);
  }
}
