// Decodificação base64 estrita e validação de WebP (Fase Q12.1). Sem I/O.
//
// Não confiamos no Content-Type nem no que a API "diz": validamos os BYTES reais.
// Não há transcodificação (sem sharp/libvips — a Edge hospedada não os suporta e a
// Image API já entrega WebP direto): imagem inválida ou grande demais simplesmente
// falha, sem upload.

import { MAX_BYTES_STORAGE } from "./config.mjs";

export class ErroImagem extends Error {
  /** @param {string} codigo @param {string} [detalhe] */
  constructor(codigo, detalhe) {
    super(detalhe ? `${codigo}: ${detalhe}` : codigo);
    this.name = "ErroImagem";
    this.codigo = codigo;
  }
}

const REGEX_BASE64 = /^[A-Za-z0-9+/]+={0,2}$/;

/**
 * @param {unknown} b64
 * @returns {Uint8Array}
 */
export function decodificarBase64Estrito(b64) {
  if (typeof b64 !== "string" || b64.length === 0) throw new ErroImagem("BASE64_INVALIDO", "vazio ou não-texto");
  const limpo = b64.replace(/\s+/g, "");
  if (limpo.length === 0 || limpo.length % 4 !== 0 || !REGEX_BASE64.test(limpo)) throw new ErroImagem("BASE64_INVALIDO", "formato");
  let binario;
  try {
    binario = atob(limpo);
  } catch {
    throw new ErroImagem("BASE64_INVALIDO", "atob");
  }
  const bytes = new Uint8Array(binario.length);
  for (let i = 0; i < binario.length; i++) bytes[i] = binario.charCodeAt(i);
  return bytes;
}

function ascii(bytes, inicio, fim) {
  return String.fromCharCode(...bytes.subarray(inicio, fim));
}

/**
 * Valida tamanho e assinatura RIFF....WEBP. Devolve os próprios bytes (para
 * encadeamento) ou lança ErroImagem com código estável.
 *
 * @param {Uint8Array} bytes
 * @param {{ maxBytes?: number }} [opcoes]
 * @returns {Uint8Array}
 */
export function validarWebp(bytes, opcoes) {
  const maxBytes = opcoes?.maxBytes ?? MAX_BYTES_STORAGE;
  if (!(bytes instanceof Uint8Array) || bytes.length === 0) throw new ErroImagem("IMAGEM_VAZIA");
  if (bytes.length > maxBytes) throw new ErroImagem("IMAGEM_EXCEDE_LIMITE_STORAGE", `${bytes.length} > ${maxBytes}`);
  if (bytes.length < 12 || ascii(bytes, 0, 4) !== "RIFF" || ascii(bytes, 8, 12) !== "WEBP") throw new ErroImagem("IMAGEM_NAO_E_WEBP");
  return bytes;
}
