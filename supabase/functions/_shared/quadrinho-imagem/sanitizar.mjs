// Sanitização de falhas e de logs da geração de arte (Fase Q12.1). Sem I/O.
//
// Reaproveita a máscara de chave da OpenAI já em produção (gerar-aula) e acrescenta
// o que é específico desta Edge: Authorization/Bearer, JWT, blocos base64 grandes e
// valores literais conhecidos em runtime (claim_token e o path, que carrega o token).
// O texto persistido em aula_quadrinho_assets.erro_sanitizado (via falhar_quadrinho_asset)
// e o que vai para log passam SEMPRE por aqui — a RPC ainda repete uma defesa própria.

import { mascararSegredos } from "../gerar-aula/sanitizarErro.mjs";
import { ErroImagem } from "./webp.mjs";

const MAX_CHARS = 300;

/**
 * @param {unknown} erro
 * @param {{ literais?: Array<string | null | undefined> }} [opcoes] valores exatos a redigir (ex.: claim_token, storage_path)
 * @returns {string} mensagem curta, sem segredos, sem quebras de linha
 */
export function sanitizarFalhaImagem(erro, opcoes) {
  let texto;
  if (erro instanceof ErroImagem) texto = erro.message;
  else if (erro instanceof Error) texto = erro.message;
  else if (typeof erro === "string") texto = erro;
  else texto = "erro inesperado";

  texto = mascararSegredos(texto);
  for (const literal of opcoes?.literais ?? []) {
    if (typeof literal === "string" && literal.length >= 6) texto = texto.split(literal).join("[redigido]");
  }
  texto = texto
    .replace(/Bearer\s+[A-Za-z0-9._~+/=-]+/gi, "Bearer [token]")
    .replace(/eyJ[A-Za-z0-9_-]{10,}(\.[A-Za-z0-9_-]+)*/g, "[jwt]")
    .replace(/[A-Za-z0-9+/]{80,}={0,2}/g, "[dados]")
    .replace(/[\r\n]+/g, " ")
    .trim();
  return (texto || "erro inesperado").slice(0, MAX_CHARS);
}

const CAMPOS_LOG_PERMITIDOS = new Set(["asset_id", "quadro_indice", "tentativa", "resultado", "motivo", "duracao_ms", "codigo", "erro", "aceito", "etapa", "bytes"]);

/**
 * Lista branca de campos de log: qualquer outra chave (claim_token, prompt, path,
 * base64, headers...) é descartada, mesmo que alguém a passe por engano.
 *
 * @param {Record<string, unknown>} campos
 * @param {{ literais?: Array<string | null | undefined> }} [opcoes]
 */
export function camposDeLogSeguros(campos, opcoes) {
  const seguro = {};
  for (const [chave, valor] of Object.entries(campos ?? {})) {
    if (!CAMPOS_LOG_PERMITIDOS.has(chave)) continue;
    seguro[chave] = typeof valor === "string" ? sanitizarFalhaImagem(valor, opcoes) : valor;
  }
  return seguro;
}
