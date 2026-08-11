const MARCADOR_RESIDUO_IMPORTACAO = /\b\d+_BASE_[A-Z0-9_]+\b/iu;
const SUFIXO_RESIDUO_IMPORTACAO = /\s+\d+_BASE_[A-Z0-9_]+\b[\s\S]*$/iu;

export function temResiduoImportacao(texto) {
  return typeof texto === "string" && MARCADOR_RESIDUO_IMPORTACAO.test(texto);
}

export function limparResiduoImportacao(texto) {
  if (typeof texto !== "string") return texto;
  return texto.replace(SUFIXO_RESIDUO_IMPORTACAO, "").trim();
}
