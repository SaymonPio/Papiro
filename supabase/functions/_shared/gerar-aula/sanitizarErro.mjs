// Sanitização canônica de mensagens de erro antes de persistência/retorno
// ao cliente (Fase 3A) — achado de segurança confirmado em produção: duas
// gerações reais (conteudo_id=57, 2026-09-14) gravaram em
// aula_geracoes.erro, e devolveram ao browser, a mensagem BRUTA da OpenAI
// para "Incorrect API key provided", que inclui prefixo/sufixo da própria
// chave ("sk-proj-...m50A"). Isso nunca pode voltar a acontecer.
//
// Sem I/O, sem chamada de rede, sem dependência de Deno nem de Node —
// mesmo princípio de validador.mjs/escopo.mjs/jurisprudencia.mjs: arquivo
// .mjs puro, importável tanto pela Edge Function (Deno) quanto pelos
// testes deste projeto (Node, node:test).
//
// Princípio de design: a detecção de segredo é por FORMATO (qualquer
// substring que pareça uma API key da OpenAI), nunca por comparação com
// o valor real do secret configurado — assim continua funcionando mesmo
// que a chave mude, e nunca precisa "saber" qual é o valor atual do
// OPENAI_API_KEY para conseguir mascará-lo. Aplicado numa cópia
// TEXTUAL da mensagem, nunca no objeto de erro original (que continua
// disponível para quem precisar investigar via log estruturado
// server-side — este módulo só decide o que é seguro PERSISTIR/DEVOLVER).
//
// Chaves da OpenAI seguem o formato "sk-" + variantes de prefixo
// (sk-proj-, sk-svcacct-, sk-admin-, ou nenhum sufixo — chaves legadas)
// + um corpo alfanumérico longo (tipicamente 20+ caracteres, podendo
// incluir "_"/"-"). O regex é deliberadamente permissivo (prefere
// mascarar demais a vazar por engano) e cobre DUAS formas observadas na
// prática:
//   1. chave "crua", nunca tocada: "sk-" + 10+ caracteres de token
//      válido (ex.: "sk-proj-abc123...xyz");
//   2. chave já PARCIALMENTE mascarada pela própria OpenAI dentro da
//      mensagem de erro (formato real observado em produção:
//      "sk-proj-****...****m50A", prefixo curto + longa sequência de
//      asteriscos + sufixo curto) — sem esta segunda forma, o prefixo
//      "sk-proj-" (só 5 caracteres depois de "sk-") e o sufixo "m50A"
//      ficariam abaixo do limiar de 10 caracteres da forma 1 e
//      sobreviveriam à máscara, exatamente o problema que motivou este
//      módulo (aula_geracoes.erro histórico com fragmento de chave
//      visível).
const REGEX_CHAVE_OPENAI = /sk-[A-Za-z0-9_-]+\*{3,}[A-Za-z0-9_-]*|sk-[A-Za-z0-9_-]{10,}/g;

const MASCARA = "sk-***REDACTED***";

/**
 * Remove/mascara qualquer trecho que pareça uma API key da OpenAI dentro
 * de uma string livre. Nunca lança exceção. Idempotente (aplicar duas
 * vezes não piora nada).
 *
 * @param {unknown} texto
 * @returns {string}
 */
export function mascararSegredos(texto) {
  if (typeof texto !== "string") return "";
  return texto.replace(REGEX_CHAVE_OPENAI, MASCARA);
}

/**
 * Sanitiza um erro (Error, string, ou o corpo de erro cru da OpenAI)
 * para uma mensagem segura de PERSISTIR em aula_geracoes.erro e de
 * DEVOLVER na resposta HTTP ao admin. Preserva categoria/status/código
 * quando disponíveis (úteis para diagnóstico), nunca o texto bruto do
 * provedor sem passar pela máscara.
 *
 * @param {unknown} erro - Error, string, ou objeto { status, code, type, message } vindo da API da OpenAI.
 * @param {{ etapa?: string }} [opcoes] - rótulo opcional da etapa onde o erro ocorreu (ex.: "chamada_inicial", "finalizacao", "correcao").
 * @returns {{ mensagem: string, categoria: string | null, httpStatus: number | null, codigo: string | null }}
 */
export function sanitizarErro(erro, opcoes) {
  const etapa = opcoes?.etapa;

  let mensagemBruta = "Erro inesperado";
  let categoria = null;
  let httpStatus = null;
  let codigo = null;

  if (erro instanceof Error) {
    mensagemBruta = erro.message;
  } else if (typeof erro === "string") {
    mensagemBruta = erro;
  } else if (erro && typeof erro === "object") {
    // Formato de erro da OpenAI: { error: { message, type, code } } ou já
    // desembrulhado { message, type, code }. Aceita os dois sem lançar.
    const corpo = "error" in erro && erro.error && typeof erro.error === "object" ? erro.error : erro;
    if (typeof corpo.message === "string") mensagemBruta = corpo.message;
    if (typeof corpo.type === "string") categoria = corpo.type;
    if (typeof corpo.code === "string") codigo = corpo.code;
    if (typeof erro.status === "number") httpStatus = erro.status;
  }

  // Detecção adicional por CONTEÚDO da mensagem (não só o objeto
  // estruturado): a categoria "erro de autenticação" é atribuída sempre
  // que a mensagem mascarada ainda contém a marca de credencial
  // mascarada — sinal de que a mensagem ORIGINAL trazia uma chave, o que
  // por si só já classifica o problema como autenticação, mesmo sem um
  // "type"/"code" estruturado vindo da API.
  const mensagemMascarada = mascararSegredos(mensagemBruta);
  if (!categoria && mensagemMascarada.includes(MASCARA)) {
    categoria = "auth_error";
  }

  const prefixoEtapa = etapa ? `[${etapa}] ` : "";
  const mensagem = `${prefixoEtapa}${mensagemMascarada}`.trim();

  return { mensagem, categoria, httpStatus, codigo };
}
