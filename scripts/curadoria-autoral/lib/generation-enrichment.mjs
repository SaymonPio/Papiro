// Enriquecimento local pos-IA (Fase 2B, Secoes 9, 17, 18). Puro — recebe o
// objeto ja parseado que o modelo devolveu para UM slot e devolve o objeto
// no formato CHAVES_QUESTAO_GERADA (schemas.mjs), com todo metadado
// trusted-side atribuido aqui, NUNCA aceito da IA.
//
// Principio de confianca (Secao 9): a IA nunca decide course_id,
// curso_conteudo_id, assunto_id, unidade_id, run_id, model, prompt_version,
// generated_at nem question_key definitivo — mesmo que o schema pedido ao
// modelo (openai-provider.mjs) nem inclua esses campos (Structured Outputs
// strict ja impede a IA de inventa-los), este modulo e a segunda linha de
// defesa: mesmo que um campo estranho aparecesse na resposta, ele e
// ignorado — só os campos explicitamente lidos abaixo entram na questão
// final.

import { ORIGEM_QUESTAO_FUTURA, QUESTION_SCHEMA_VERSION } from "./schemas.mjs";

/**
 * <run_id>:q0<slot> — deterministico, estavel, nunca um id de banco
 * (Secao 18).
 */
export function gerarQuestionKey(runId, slot) {
  return `${runId}:q0${slot}`;
}

/**
 * @param {{
 *   questaoBruta: object,   // um item de dados.questions[] vindo da IA (so os campos do schema de openai-provider.mjs)
 *   payload: object,        // payload canonico (payload-builder.mjs) desta unidade
 *   runId: string,
 *   model: string,
 *   promptVersion: string,
 *   generatedAt: string,    // ISO — atribuido pelo chamador (nao Date.now() aqui, para os testes serem deterministicos)
 * }}
 * @returns {object} no formato CHAVES_QUESTAO_GERADA
 */
export function enriquecerQuestaoGerada({ questaoBruta, payload, runId, model, promptVersion, generatedAt }) {
  if (!questaoBruta || typeof questaoBruta !== "object") throw new Error("questaoBruta invalida.");
  if (![1, 2].includes(questaoBruta.slot)) throw new Error(`slot invalido: ${questaoBruta.slot}`);

  return {
    schema_version: QUESTION_SCHEMA_VERSION,
    run_id: runId,
    question_key: gerarQuestionKey(runId, questaoBruta.slot),
    origem: ORIGEM_QUESTAO_FUTURA,

    // Campos decididos pela IA — copiados como vieram, sem reinterpretar.
    enunciado: questaoBruta.enunciado,
    alternativas: questaoBruta.alternativas,
    gabarito: questaoBruta.gabarito,
    explicacao: questaoBruta.explicacao,
    fundamento: questaoBruta.fundamento,
    dificuldade: questaoBruta.dificuldade,
    justificativa_aderencia: questaoBruta.justificativa_aderencia,
    riscos_identificados: Array.isArray(questaoBruta.riscos_identificados) ? questaoBruta.riscos_identificados : [],

    // Metadado trusted-side — SEMPRE do payload/runtime local, nunca da IA.
    banca_alvo: payload.bank.name,
    curso_id: payload.course.id,
    materia_id: payload.subject.id,
    conteudo_id: payload.content.subject_topic_id,
    curso_conteudo_id: payload.content.course_content_id,
    unidade_id: payload.unit.id,
    aula_id: payload.lesson?.id ?? null,
    fonte_utilizada: payload.source.validated_source_keys,
    status_inicial: null, // atribuido depois por generation-audit.mjs

    model,
    prompt_version: promptVersion,
    generated_at: generatedAt,
  };
}

/**
 * O slot (1 ou 2) e recuperavel deterministicamente do question_key
 * (`<run_id>:q0<slot>`) — usado pela Secao 22 (checar slot correto sem
 * inversao/duplicacao) sem precisar carregar um campo extra fora do
 * contrato CHAVES_QUESTAO_GERADA.
 */
export function extrairSlotDoQuestionKey(questionKey) {
  const match = /:q0([12])$/.exec(String(questionKey || ""));
  return match ? Number(match[1]) : null;
}
