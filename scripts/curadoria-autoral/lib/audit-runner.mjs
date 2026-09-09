// Executor de UMA etapa de auditoria (Blind OU Critic) com persistencia
// imediata (Fase 2C.1, Secoes 1, 6-9). Usado pelas duas etapas — nunca
// duplicado entre elas — para garantir a MESMA disciplina de erro/
// persistencia em ambas: chamar -> classificar erro (se houver) ->
// validar localmente -> persistir atomicamente -> confirmar releitura ->
// so entao devolver sucesso. Qualquer falha em qualquer ponto interrompe
// aqui, com bookkeeping estruturado, sem nunca cair num catch generico
// (achado real da tentativa anterior: um "fetch failed" sem tratamento
// especifico fez a Call A bem-sucedida ser perdida).

import fs from "node:fs";
import { chamarOpenAI, extrairRespostaEstruturada } from "./openai-provider.mjs";
import { escreverArtefatoJson } from "./artifact-writer.mjs";

export const STATUS_ETAPA = Object.freeze({
  PERSISTED: "PERSISTED",
  HTTP_ERROR: "HTTP_ERROR",
  NETWORK_ERROR: "NETWORK_ERROR",
  SCHEMA_ERROR: "SCHEMA_ERROR",
  LOCAL_VALIDATION_ERROR: "LOCAL_VALIDATION_ERROR",
  PERSISTENCE_ERROR: "PERSISTENCE_ERROR",
});

function bookkeepingVazio() {
  return {
    request_attempted: false,
    response_received: false,
    response_id: null,
    usage: null,
    status: null,
    error_type: null,
    error_message: null,
  };
}

/**
 * @param {{
 *   apiKey: string,
 *   requestBody: object,
 *   caminhoArtefato: string,
 *   fingerprint: string,
 *   validarLocalmente: (dados: unknown) => { ok: boolean, errors: string[] },
 *   montarConteudoArtefato: (args: { extraida: object, dadosValidados: object, fingerprint: string }) => object,
 *   fetchImpl?: typeof fetch,
 * }} entrada
 * @returns {Promise<{ status: string, bookkeeping: object, dados: object|null, conteudoArtefato?: object, mensagemErro?: string }>}
 */
export async function executarEtapaAuditoria({ apiKey, requestBody, caminhoArtefato, fingerprint, validarLocalmente, montarConteudoArtefato, fetchImpl = fetch }) {
  const bookkeeping = bookkeepingVazio();
  bookkeeping.request_attempted = true;

  let respostaHttp;
  try {
    respostaHttp = await chamarOpenAI({ apiKey, requestBody, fetchImpl });
  } catch (erro) {
    // Excecao de rede (fetch lancou, nunca chegou a existir uma resposta
    // HTTP) — categoria PROPRIA, nunca um catch generico (Secao 8).
    bookkeeping.response_received = false;
    bookkeeping.status = STATUS_ETAPA.NETWORK_ERROR;
    bookkeeping.error_type = "NETWORK_ERROR";
    bookkeeping.error_message = erro.message;
    return { status: STATUS_ETAPA.NETWORK_ERROR, bookkeeping, dados: null };
  }

  bookkeeping.response_received = true;

  if (!respostaHttp.ok) {
    const mensagem = respostaHttp.corpo?.error?.message || JSON.stringify(respostaHttp.corpo).slice(0, 300);
    bookkeeping.status = STATUS_ETAPA.HTTP_ERROR;
    bookkeeping.error_type = "HTTP_ERROR";
    bookkeeping.error_message = mensagem;
    bookkeeping.http_status = respostaHttp.status;
    return { status: STATUS_ETAPA.HTTP_ERROR, bookkeeping, dados: null, mensagemErro: mensagem };
  }

  const extraida = extrairRespostaEstruturada(respostaHttp.corpo);
  bookkeeping.response_id = extraida.response_id;
  bookkeeping.usage = extraida.usage;

  if (extraida.jsonInvalido) {
    bookkeeping.status = STATUS_ETAPA.SCHEMA_ERROR;
    bookkeeping.error_type = "SCHEMA_ERROR";
    bookkeeping.error_message = extraida.motivo;
    return { status: STATUS_ETAPA.SCHEMA_ERROR, bookkeeping, dados: null };
  }

  const validacao = validarLocalmente(extraida.dados);
  if (!validacao.ok) {
    bookkeeping.status = STATUS_ETAPA.LOCAL_VALIDATION_ERROR;
    bookkeeping.error_type = "LOCAL_VALIDATION_ERROR";
    bookkeeping.error_message = validacao.errors.join("; ");
    return { status: STATUS_ETAPA.LOCAL_VALIDATION_ERROR, bookkeeping, dados: null };
  }

  const conteudoArtefato = montarConteudoArtefato({ extraida, dadosValidados: extraida.dados, fingerprint });
  try {
    escreverArtefatoJson(caminhoArtefato, conteudoArtefato);
    // Confirmar arquivo legivel (Secao 6/7, item 7) — releitura real do
    // disco, nunca so confiar que a escrita "deve" ter funcionado.
    const confirmacao = JSON.parse(fs.readFileSync(caminhoArtefato, "utf8"));
    if (confirmacao.audit_input_fingerprint !== fingerprint) {
      throw new Error("fingerprint gravado nao confere na releitura de confirmacao apos persistir.");
    }
  } catch (erroPersistencia) {
    bookkeeping.status = STATUS_ETAPA.PERSISTENCE_ERROR;
    bookkeeping.error_type = "PERSISTENCE_ERROR";
    bookkeeping.error_message = erroPersistencia.message;
    return { status: STATUS_ETAPA.PERSISTENCE_ERROR, bookkeeping, dados: null };
  }

  bookkeeping.status = STATUS_ETAPA.PERSISTED;
  return { status: STATUS_ETAPA.PERSISTED, bookkeeping, dados: extraida.dados, conteudoArtefato };
}
