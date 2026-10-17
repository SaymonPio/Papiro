import { createHash } from "node:crypto";

const ASSINATURA_PDF = Buffer.from("%PDF-", "ascii");

export function validarPdfBuffer(buffer) {
  if (!buffer || buffer.length === 0) {
    return { valido: false, motivo: "arquivo vazio" };
  }
  if (buffer.length < ASSINATURA_PDF.length || !buffer.subarray(0, ASSINATURA_PDF.length).equals(ASSINATURA_PDF)) {
    return { valido: false, motivo: "assinatura PDF (%PDF-) ausente no início do arquivo — não é um PDF válido" };
  }
  return { valido: true, motivo: null };
}

export function calcularHashSha256(buffer) {
  return createHash("sha256").update(buffer).digest("hex");
}
