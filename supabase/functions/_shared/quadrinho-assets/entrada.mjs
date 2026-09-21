// Validação ESTRITA do corpo da Edge assinar-quadrinho-assets (Fase Q12.12). Função pura.
//
//   { "modo": "admin", "aulaVersaoId": "<uuid>" }
//   { "modo": "aluno", "aulaVersaoId": "<uuid>", "missaoId": "<uuid>" }
//
// Recusa: corpo que não seja objeto, modo desconhecido, UUID inválido, campo obrigatório ausente e QUALQUER campo
// a mais (o cliente não escolhe path, bucket, validade, status nem quadro: tudo isso vem do servidor).

const REGEX_UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

const CAMPOS_POR_MODO = {
  admin: ["modo", "aulaVersaoId"],
  aluno: ["modo", "aulaVersaoId", "missaoId"],
};

/** @returns {{ ok: true, valor: { modo: "admin" | "aluno", aulaVersaoId: string, missaoId: string | null } } | { ok: false, mensagem: string }} */
export function validarEntrada(corpo) {
  if (corpo === null || typeof corpo !== "object" || Array.isArray(corpo)) return { ok: false, mensagem: "Corpo inválido." };
  const modo = corpo.modo;
  if (typeof modo !== "string" || !Object.prototype.hasOwnProperty.call(CAMPOS_POR_MODO, modo)) return { ok: false, mensagem: "Modo inválido." };
  const permitidos = CAMPOS_POR_MODO[modo];
  const extra = Object.keys(corpo).find((campo) => !permitidos.includes(campo));
  if (extra) return { ok: false, mensagem: "Campo não permitido." };
  if (typeof corpo.aulaVersaoId !== "string" || !REGEX_UUID.test(corpo.aulaVersaoId)) return { ok: false, mensagem: "aulaVersaoId inválido." };
  if (modo === "aluno" && (typeof corpo.missaoId !== "string" || !REGEX_UUID.test(corpo.missaoId))) return { ok: false, mensagem: "missaoId inválido." };
  return { ok: true, valor: { modo, aulaVersaoId: corpo.aulaVersaoId.toLowerCase(), missaoId: modo === "aluno" ? corpo.missaoId.toLowerCase() : null } };
}
