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
import { referenciaTemDispositivoNormativo, referenciaTemPrecedenteJurisprudencial, referenciaPareceInstitucionalRastreavel } from "./eligibility.mjs";

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
 * @param {{ requiresNormativeDeviceReference?: boolean }} [contexto] — Reparo
 *   Lote 07 (Secao 7 do mandato "REPAIR PASS SEM NOVA API"): quando true
 *   (nascido de payload.source.legal_source_required, nunca de materia_id ou
 *   do nome da materia), fundamento.referencia precisa citar diploma E artigo
 *   identificaveis, sob pena de MISSING_NORMATIVE_DEVICE. Omitido/false
 *   preserva o comportamento anterior (usado por materias nao normativas
 *   como Portugues, e por chamadas antigas que nao passam este parametro).
 * @returns {{ ok: boolean, errors: Array<{codigo:string, mensagem:string}>, warnings: Array<{codigo:string, mensagem:string}> }}
 */
export function validarQuestaoGerada(dados, contexto = {}) {
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

  let referenciaFundamento = null;
  if (dados.fundamento === null || dados.fundamento === undefined) {
    errors.push(erro("MISSING_FUNDAMENTO", "fundamento ausente."));
  } else if (typeof dados.fundamento === "object" && !Array.isArray(dados.fundamento)) {
    if (!ehStringNaoVazia(dados.fundamento.descricao) && !ehStringNaoVazia(dados.fundamento.referencia)) {
      errors.push(erro("EMPTY_FUNDAMENTO", "fundamento presente mas sem referencia nem descricao preenchidas."));
    }
    referenciaFundamento = dados.fundamento.referencia;
  } else if (!ehStringNaoVazia(dados.fundamento)) {
    errors.push(erro("EMPTY_FUNDAMENTO", "fundamento presente mas vazio."));
  } else {
    referenciaFundamento = dados.fundamento;
  }

  // Reparo Lote 07 (Secao 7), com DISPATCH por tipo introduzido no Lote 09B
  // (mandato "EXTENSAO CONTROLADA DO CONTRATO DE FUNDAMENTO", Secoes 9-12):
  // so roda quando o contexto de geracao pede (fonte de alta confianca
  // exigida, nunca por heuristica de materia_id/nome). Fundamento.tipo
  // decide QUAL checagem de conteudo se aplica:
  //   - "regra_jurisprudencial" -> exige tribunal+identificador de
  //     precedente (NAO diploma+artigo — jurisprudencia nao e norma);
  //   - "fonte_pedagogica_oficial" -> exige citacao institucional
  //     rastreavel (NAO diploma+artigo — nem lei, nem jurisprudencia);
  //   - qualquer outro tipo (regra_normativa, regra_gramatical,
  //     dispositivo_normativo de fixtures legadas, tipo ausente) ->
  //     comportamento EXATO de antes (diploma+artigo via
  //     MISSING_NORMATIVE_DEVICE), sem nenhuma mudanca de superficie.
  // Nenhum dos tres ramos duplica MISSING_FUNDAMENTO/EMPTY_FUNDAMENTO —
  // so acrescentam erro quando ha algo em fundamento, mas sem o conteudo
  // minimo esperado para aquele tipo especifico.
  if (contexto.requiresNormativeDeviceReference && ehStringNaoVazia(referenciaFundamento)) {
    const tipoFundamento = dados.fundamento && typeof dados.fundamento === "object" ? dados.fundamento.tipo : undefined;

    if (tipoFundamento === "regra_jurisprudencial") {
      const { temTribunal, temIdentificador } = referenciaTemPrecedenteJurisprudencial(referenciaFundamento);
      if (!temTribunal || !temIdentificador) {
        errors.push(
          erro(
            "MISSING_JURISPRUDENTIAL_REFERENCE",
            "fonte exige precedente jurisprudencial rastreavel (tribunal + classe/tema/sumula identificaveis) em fundamento.referencia, mas nao foi encontrado."
          )
        );
      }
    } else if (tipoFundamento === "fonte_pedagogica_oficial") {
      const { temSegmentosSuficientes, tamanhoSuficiente } = referenciaPareceInstitucionalRastreavel(referenciaFundamento);
      if (!temSegmentosSuficientes || !tamanhoSuficiente) {
        errors.push(
          erro(
            "MISSING_OFFICIAL_PEDAGOGICAL_REFERENCE",
            "fonte exige citacao institucional rastreavel (instituicao + documento/material + localizacao, quando disponivel) em fundamento.referencia, mas a referencia parece vaga demais."
          )
        );
      }
    } else {
      const { temDiploma, temArtigo } = referenciaTemDispositivoNormativo(referenciaFundamento);
      if (!temDiploma || !temArtigo) {
        errors.push(
          erro(
            "MISSING_NORMATIVE_DEVICE",
            "fonte exige dispositivo normativo especifico (diploma + artigo identificaveis) em fundamento.referencia, mas nao foi encontrado."
          )
        );
      }
    }
  }

  // Guard defensivo (Lote 09A, Secao 21 do mandato de correcao do gerador):
  // alem de MISSING_NORMATIVE_DEVICE (que so olha o TEXTO de
  // fundamento.referencia), verifica tambem o campo fundamento.tipo
  // diretamente contra o UNICO valor sabidamente incompativel com fonte
  // legal exigida: "regra_gramatical" (o valor que o bug de prompt do
  // Lote09A vazou para questoes juridicas). Nao trava em "precisa ser
  // exatamente regra_normativa", porque o contrato mais amplo deste
  // validador (usado tambem fora do pipeline OpenAI) aceita outros valores
  // de tipo normativo ja em uso (ex.: "dispositivo_normativo", fixture do
  // reparo Lote07) — quem decide se o CONTEUDO da referencia e normativo o
  // suficiente e MISSING_NORMATIVE_DEVICE, nao este guard. Este guard so
  // bloqueia o caso especifico e inequivoco: tipo gramatical numa unidade
  // que exige fonte legal. Nao substitui MISSING_NORMATIVE_DEVICE (ambos
  // podem coexistir na mesma questao).
  if (
    contexto.requiresNormativeDeviceReference &&
    dados.fundamento &&
    typeof dados.fundamento === "object" &&
    !Array.isArray(dados.fundamento) &&
    dados.fundamento.tipo === "regra_gramatical"
  ) {
    errors.push(
      erro(
        "LEGAL_SOURCE_REQUIRES_NORMATIVE_FOUNDATION",
        'fonte exige fundamento normativo, mas fundamento.tipo="regra_gramatical" foi recebido — incompativel com unidade de fonte legal validada.'
      )
    );
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
