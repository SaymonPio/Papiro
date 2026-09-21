// Configuração central da geração de arte dos quadrinhos (Fase Q12.1).
//
// Só constantes/validação — sem I/O, sem Deno, sem Node: .mjs puro, importável
// pela Edge Function (Deno) e pelos testes (node:test), mesmo padrão de
// ../gerar-aula/openaiResponses.mjs. NENHUM valor de modelo/tamanho/qualidade é
// espalhado pelo código: tudo passa por aqui. Não é a mesma configuração das
// aulas (OPENAI_MODEL): as variáveis de imagem têm prefixo próprio.
//
// Fonte dos parâmetros (documentação oficial da OpenAI, guia image-generation,
// consultada na Q12.1): POST /v1/images/generations; model, prompt, size,
// quality (low|medium|high|xhigh|max|auto), output_format (png|jpeg|webp),
// output_compression (0-100, jpeg/webp), n; resposta data[].b64_json.

/** Modelo padrão (prioridade do Papiro: qualidade > latência). Sobrescrevível por OPENAI_IMAGE_MODEL. */
export const IMAGE_MODEL_PADRAO = "gpt-image-2.5-sunburst";

/** 3:2 — tamanho paisagem recomendado pela documentação (1536x1024). */
export const IMAGE_SIZE_PADRAO = "1536x1024";

export const IMAGE_QUALITY_PADRAO = "high";
const QUALIDADES_VALIDAS = new Set(["low", "medium", "high", "xhigh", "max", "auto"]);

/** O bucket quadrinhos-aulas só aceita image/webp: o formato NÃO é configurável. */
export const IMAGE_OUTPUT_FORMAT = "webp";

/**
 * Compressão WebP inicial. É um PONTO DE PARTIDA a calibrar no piloto, não uma
 * garantia: o bucket limita cada objeto a 262144 bytes e a Edge SEMPRE valida o
 * tamanho real (ver webp.mjs) — imagem acima do limite falha sem upload.
 */
export const IMAGE_OUTPUT_COMPRESSION_PADRAO = 70;

/** Versão do prompt visual gravada em aula_quadrinho_assets.prompt_version. */
export const IMAGE_PROMPT_VERSION = "quadrinho-imagem-v3";

/**
 * Timeout da chamada de imagem. A documentação de limites do Supabase Edge
 * Functions dá wall-clock de 150 s (free) / 400 s (paid); a documentação da
 * OpenAI cita "até 2 minutos" para prompts complexos. 110 s cabe DENTRO do
 * limite mais restritivo (free, 150 s) deixando ~40 s para decodificar, validar,
 * subir o WebP e chamar a RPC de conclusão/falha. Em plano pago pode-se subir
 * via OPENAI_IMAGE_TIMEOUT_MS (teto de segurança abaixo).
 */
export const IMAGE_REQUEST_TIMEOUT_MS_PADRAO = 110_000;
const TIMEOUT_MIN_MS = 10_000;
const TIMEOUT_MAX_MS = 300_000;

/** Limite do bucket quadrinhos-aulas (file_size_limit = 262144 = 256 KiB). */
export const MAX_BYTES_STORAGE = 262_144;

/** Quantidade de quadros que o contrato de quadrinho_didatico permite. */
export const MIN_QUADROS = 3;
export const MAX_QUADROS = 6;

/** Teto do prompt_visual aceito por concluir_quadrinho_asset (SQL: length <= 8000). */
export const MAX_PROMPT_VISUAL_CHARS = 8000;

const REGEX_TAMANHO = /^(\d{3,4})x(\d{3,4})$/;

function tamanhoValido(valor) {
  const m = REGEX_TAMANHO.exec(valor);
  if (!m) return false;
  const [l, a] = [Number(m[1]), Number(m[2])];
  const total = l * a;
  const razao = l / a;
  // Restrições documentadas: múltiplos de 16, razão entre 1:3 e 3:1, borda <= 3840,
  // total de pixels entre 655.360 e 8.294.400.
  return l % 16 === 0 && a % 16 === 0 && l <= 3840 && a <= 3840 && razao >= 1 / 3 && razao <= 3 && total >= 655_360 && total <= 8_294_400;
}

/**
 * @param {(nome: string) => string | undefined} getEnv
 * @returns {{ model: string, size: string, quality: string, outputFormat: "webp", outputCompression: number, promptVersion: string, timeoutMs: number, maxBytes: number }}
 */
export function resolverConfiguracaoImagem(getEnv) {
  const model = getEnv("OPENAI_IMAGE_MODEL")?.trim() || IMAGE_MODEL_PADRAO;

  const sizeRaw = getEnv("OPENAI_IMAGE_SIZE")?.trim().toLowerCase();
  const size = sizeRaw && tamanhoValido(sizeRaw) ? sizeRaw : IMAGE_SIZE_PADRAO;

  const qualityRaw = getEnv("OPENAI_IMAGE_QUALITY")?.trim().toLowerCase();
  const quality = qualityRaw && QUALIDADES_VALIDAS.has(qualityRaw) ? qualityRaw : IMAGE_QUALITY_PADRAO;

  const compressaoRaw = getEnv("OPENAI_IMAGE_COMPRESSION");
  const compressaoNum = compressaoRaw == null || compressaoRaw.trim() === "" ? NaN : Number(compressaoRaw);
  const outputCompression = Number.isInteger(compressaoNum) && compressaoNum >= 0 && compressaoNum <= 100 ? compressaoNum : IMAGE_OUTPUT_COMPRESSION_PADRAO;

  const timeoutRaw = getEnv("OPENAI_IMAGE_TIMEOUT_MS");
  const timeoutNum = timeoutRaw == null || timeoutRaw.trim() === "" ? NaN : Number(timeoutRaw);
  const timeoutMs = Number.isInteger(timeoutNum) && timeoutNum >= TIMEOUT_MIN_MS && timeoutNum <= TIMEOUT_MAX_MS ? timeoutNum : IMAGE_REQUEST_TIMEOUT_MS_PADRAO;

  return { model, size, quality, outputFormat: IMAGE_OUTPUT_FORMAT, outputCompression, promptVersion: IMAGE_PROMPT_VERSION, timeoutMs, maxBytes: MAX_BYTES_STORAGE };
}
