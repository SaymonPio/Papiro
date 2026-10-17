import assert from "node:assert/strict";
import test from "node:test";
import { validarPdfBuffer, calcularHashSha256 } from "../scripts/importador-provas/collectors/fepese/lib/validacao.mjs";

test("A) buffer vazio é rejeitado explicitamente, nunca tratado como PDF válido", () => {
  const resultado = validarPdfBuffer(Buffer.alloc(0));
  assert.equal(resultado.valido, false);
  assert.match(resultado.motivo, /vazio/);
});

test("B) documento não-PDF (ex.: HTML de página de erro) é rejeitado pela assinatura", () => {
  const html = Buffer.from("<html><body>Página não encontrada</body></html>", "utf8");
  const resultado = validarPdfBuffer(html);
  assert.equal(resultado.valido, false);
  assert.match(resultado.motivo, /assinatura/);
});

test("C) buffer com assinatura %PDF- válida é aceito", () => {
  const pdfFalso = Buffer.from("%PDF-1.4\n%% resto do arquivo nao importa para esta checagem\n", "utf8");
  const resultado = validarPdfBuffer(pdfFalso);
  assert.equal(resultado.valido, true);
});

test("D) buffer menor que a própria assinatura (ex.: 2 bytes) é rejeitado sem lançar erro", () => {
  const resultado = validarPdfBuffer(Buffer.from("%P", "ascii"));
  assert.equal(resultado.valido, false);
});

test("E) calcularHashSha256 é determinístico (mesmo conteúdo -> mesmo hash) e sensível a qualquer byte diferente", () => {
  const a = Buffer.from("conteudo identico", "utf8");
  const b = Buffer.from("conteudo identico", "utf8");
  const c = Buffer.from("conteudo diferente", "utf8");
  assert.equal(calcularHashSha256(a), calcularHashSha256(b));
  assert.notEqual(calcularHashSha256(a), calcularHashSha256(c));
  assert.equal(calcularHashSha256(a).length, 64); // sha256 hex = 64 chars
});
