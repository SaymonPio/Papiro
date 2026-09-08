// Validador estrutural puro de uma questao gerada (Fase 2A, Secao 22).
//
// Sem I/O, sem chamada de rede, sem dependencia de Deno nem de Node alem
// de node:test para os proprios testes — mesmo principio de
// supabase/functions/gerar-aula/validador.mjs: um arquivo simples,
// importavel tanto por uma futura Edge Function quanto pelos testes deste
// projeto, sem duplicar logica em dois lugares.
//
// Diferenca deliberada frente a validador.mjs: aquele retorna um unico
// `erro` (string); este retorna `errors`/`warnings` como arrays de objetos
// {codigo, mensagem}, porque a Fase 2A pede reason_codes explicitos
// (Secao 22) para permitir que o audit-classifier decida REJEITADA vs
// REVISAR sem re-parsear mensagens de erro.

import { DIFICULDADES_VALIDAS, LETRAS_ALTERNATIVAS, ORIGEM_QUESTAO_FUTURA, QUESTION_SCHEMA_VERSION } from "./schemas.mjs";

function ehStringNaoVazia(valor) {
  return typeof valor === "string" && valor.trim().length > 0;
}

function erro(codigo, mensagem) {
  return { codigo, mensagem };
}

/**
 * Valida a estrutura de uma questao gerada contra o contrato da Fase 2A.
 * Nunca lanca excecao — sempre devolve { ok, errors, warnings }.
 *
 * @param {unknown} dados
 * @returns {{ ok: boolean, errors: Array<{codigo:string, mensagem:string}>, warnings: Array<{codigo:string, mensagem:string}> }}
 */
export function validarQuestaoGerada(dados) {
  const errors = [];
  const warnings = [];

  if (typeof dados !== "object" || dados === null || Array.isArray(dados)) {
    return { ok: false, errors: [erro("NOT_AN_OBJECT", "Resposta nao e um objeto JSON.")], warnings };
  }

  if (dados.schema_version !== QUESTION_SCHEMA_VERSION) {
    errors.push(erro("UNSUPPORTED_SCHEMA_VERSION", `schema_version ausente ou nao suportada (esperado ${QUESTION_SCHEMA_VERSION}).`));
  }

  if (!ehStringNaoVazia(dados.question_key)) {
    errors.push(erro("MISSING_QUESTION_KEY", "question_key ausente ou vazio."));
  }

  if (dados.origem !== ORIGEM_QUESTAO_FUTURA) {
    errors.push(erro("INVALID_ORIGEM", `origem precisa ser exatamente "${ORIGEM_QUESTAO_FUTURA}".`));
  }

  if (!ehStringNaoVazia(dados.enunciado)) {
    errors.push(erro("EMPTY_ENUNCIADO", "enunciado ausente ou vazio."));
  }

  if (!Array.isArray(dados.alternativas) || dados.alternativas.length !== 5) {
    errors.push(erro("WRONG_ALTERNATIVE_COUNT", "alternativas precisa ser um array com exatamente 5 itens."));
  } else {
    const letrasVistas = new Set();
    let algumaVazia = false;
    for (const alt of dados.alternativas) {
      if (typeof alt !== "object" || alt === null || Array.isArray(alt)) {
        errors.push(erro("INVALID_ALTERNATIVE_SHAPE", "uma alternativa nao e um objeto {letra, texto}."));
        continue;
      }
      if (!ehStringNaoVazia(alt.texto)) algumaVazia = true;
      if (ehStringNaoVazia(alt.letra)) letrasVistas.add(alt.letra.trim().toUpperCase());
    }
    if (algumaVazia) errors.push(erro("EMPTY_ALTERNATIVE_TEXT", "uma ou mais alternativas tem texto vazio."));

    const letrasEsperadas = new Set(LETRAS_ALTERNATIVAS);
    const letrasIguais =
      letrasVistas.size === LETRAS_ALTERNATIVAS.length && [...letrasVistas].every((l) => letrasEsperadas.has(l));
    if (!letrasIguais) {
      errors.push(erro("ALTERNATIVE_LETTERS_NOT_ABCDE", "as letras das alternativas precisam ser exatamente A, B, C, D, E, uma vez cada."));
    }
  }

  if (!ehStringNaoVazia(dados.gabarito) || !LETRAS_ALTERNATIVAS.includes(String(dados.gabarito).trim().toUpperCase())) {
    errors.push(erro("INVALID_GABARITO", "gabarito ausente ou fora de A-E."));
  } else if (Array.isArray(dados.alternativas)) {
    const gabarito = String(dados.gabarito).trim().toUpperCase();
    const correspondentes = dados.alternativas.filter(
      (alt) => alt && typeof alt.letra === "string" && alt.letra.trim().toUpperCase() === gabarito
    );
    if (correspondentes.length !== 1) {
      errors.push(erro("GABARITO_NOT_UNIQUE_MATCH", "gabarito precisa corresponder a exatamente uma alternativa existente."));
    }
  }

  if (!ehStringNaoVazia(dados.explicacao)) {
    errors.push(erro("EMPTY_EXPLICACAO", "explicacao ausente ou vazia."));
  }

  if (dados.fundamento === null || dados.fundamento === undefined) {
    errors.push(erro("MISSING_FUNDAMENTO", "fundamento ausente."));
  } else if (typeof dados.fundamento === "object" && !Array.isArray(dados.fundamento)) {
    if (!ehStringNaoVazia(dados.fundamento.descricao) && !ehStringNaoVazia(dados.fundamento.referencia)) {
      errors.push(erro("EMPTY_FUNDAMENTO", "fundamento presente mas sem referencia nem descricao preenchidas."));
    }
  } else if (!ehStringNaoVazia(dados.fundamento)) {
    errors.push(erro("EMPTY_FUNDAMENTO", "fundamento presente mas vazio."));
  }

  if (!DIFICULDADES_VALIDAS.includes(dados.dificuldade)) {
    errors.push(erro("INVALID_DIFICULDADE", `dificuldade precisa ser uma de: ${DIFICULDADES_VALIDAS.join(", ")}.`));
  }

  if (!ehStringNaoVazia(dados.curso_id)) errors.push(erro("MISSING_CURSO_ID", "curso_id ausente."));
  if (!ehStringNaoVazia(dados.unidade_id)) errors.push(erro("MISSING_UNIDADE_ID", "unidade_id ausente."));

  if (
    Object.prototype.hasOwnProperty.call(dados, "id") ||
    (dados.riscos_identificados && dados.riscos_identificados.some((r) => r && typeof r === "object" && "questao_id" in r))
  ) {
    errors.push(erro("BANK_ID_NOT_ALLOWED", "a questao nao pode trazer um id de questao do banco (question_key e local, nao um id de banco)."));
  }

  if (!Array.isArray(dados.riscos_identificados)) {
    errors.push(erro("RISCOS_NOT_ARRAY", "riscos_identificados precisa ser um array (mesmo vazio)."));
  }

  return { ok: errors.length === 0, errors, warnings };
}
