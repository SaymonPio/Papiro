// Avaliacao de contexto pedagogico, validacao de fonte, elegibilidade e
// prioridade (Fase 2A Secoes 12, 16, 30, 31, 32; Fase 2A.1 Secoes 2-6 —
// hardening que separa as duas perguntas que a Fase 2A original
// confundia). Puro — sem I/O, sem chamada de rede.
//
// Principio central (Fase 2A, Secao 11): aula publicada NUNCA bloqueia
// geracao — so vira warning. Principio central do hardening (Fase 2A.1):
// escopo/artigos_esperados NUNCA bloqueiam nem liberam sozinhos uma
// classificacao de FONTE — eles so respondem "sabemos o que ensinar?",
// nunca "a informacao esta documentalmente validada?". A segunda pergunta
// so pode ser respondida por lib/source-manifest.mjs (registro humano
// explicito).
//
// Politica de "isto e conteudo normativo/juridico?" (Secao 5/6/32): NUNCA
// decidida por materia_id hardcoded. Inferida do PROPRIO TEXTO do escopo
// (presenca de citacao tipo "art.", "lei n.", "decreto", "constituicao",
// "sumula") — extensivel, nao um if fixo por disciplina.

import { STATUS_BANCA, STATUS_CONTEXTO_PEDAGOGICO, STATUS_ELEGIBILIDADE, STATUS_VALIDACAO_FONTE } from "./schemas.mjs";

const PADRAO_ESCOPO_NORMATIVO = /\bart(igo)?s?\.?\s*\d|\blei\s+n[ºo°]?\.?\s*\d|\bdecreto\b|\bconstitui[cç][aã]o\b|\bsumula\b|\bsúmula\b/i;

/**
 * Heuristica extensivel (nao hardcoded por materia_id) para "este escopo
 * parece depender de uma norma/dispositivo especifico?". Usada so para
 * decidir se FALTAR fonte validada deve BLOQUEAR (juridico) ou apenas
 * AVISAR (Portugues/RLM/Informatica em geral).
 * @param {string} escopoTexto
 * @returns {boolean}
 */
export function materiaPareceNormativa(escopoTexto) {
  return PADRAO_ESCOPO_NORMATIVO.test(escopoTexto || "");
}

// Reparo Lote 07 (mandato "REPAIR PASS SEM NOVA API", Secao 7): a lacuna
// encontrada apos a geracao real foi que fundamento.referencia podia ficar
// preenchido com justificativa gramatical/semantica generica mesmo quando a
// fonte da unidade e uma norma (source.legal_source_required=true) — nada no
// guard exigia que a referencia citasse, de fato, um dispositivo. As duas
// heuristicas abaixo sao deliberadamente SEPARADAS (diploma vs artigo) e
// aplicadas apenas quando o payload/contexto de geracao sinaliza
// requiresNormativeDeviceReference=true (nascido de source.legal_source_required
// no payload, nunca de materia_id ou do nome da materia).
const PADRAO_ARTIGO_IDENTIFICAVEL = /\bart(igo)?s?\.?\s*\d/i;
// Reparo Lote 09B: generaliza TECH_DEBT_NORMATIVE_REFERENCE_CODE_NAME_REGEX
// (achado no Lote09A com "Código Tributário Nacional, art. 78") de forma
// NAO hardcoded a um unico codigo — qualquer diploma referido pelo nome
// popular "Código ..." (Código Tributário Nacional, Código Penal, Código
// de Processo Penal, Código Civil, Código de Trânsito Brasileiro, etc.)
// passa a ser reconhecido como diploma identificavel, com uma janela maior
// (nomes de codigo tendem a ser mais longos que "Lei nº X").
//
// Reparo Lote 09B (geração real): achado analogo ao do "Código X" acima,
// mas para "constituição" — o nome oficial completo "Constituição da
// República Federativa do Brasil de 1988" (uso corriqueiro e correto,
// nao um erro do modelo) tem ~38 caracteres entre a palavra-chave e o
// primeiro digito (o ano), o que excedia a janela de 30 usada por
// lei/decreto/constituição em conjunto — CF era a UNICA das palavras-chave
// deste grupo cujo nome por extenso rotineiramente ultrapassa 30
// caracteres (leis/decretos citados por numero ficam bem abaixo disso).
// Correcao generica (nao hardcoded a uma unica formulacao de CF):
// unifica a janela de constituição com a mesma janela de 60 ja usada
// para código, pela mesma razao (nome por extenso mais longo).
const PADRAO_DIPLOMA_IDENTIFICAVEL = /\b(lei\s+complementar|lei\s+(estadual|federal)|lei|decreto(\s+estadual)?)\b[^\n]{0,30}?\d|\b(c[oó]digo|constitui[çc][ãa]o)\b[^\n]{0,60}?\d/i;

/**
 * Verifica se um texto de fundamento.referencia cita, de forma
 * identificavel, um diploma legal E um artigo — as duas exigencias minimas
 * do mandato de reparo do Lote 07 para "dispositivo normativo presente".
 * Nao valida paragrafo/inciso/alinea (isso fica para revisao humana
 * candidata a candidata, Secao 3 do mandato) nem confere se o dispositivo
 * citado realmente sustenta o conteudo da questao — so confere se HA uma
 * citacao identificavel.
 * @param {string} referencia
 * @returns {{ temDiploma: boolean, temArtigo: boolean }}
 */
export function referenciaTemDispositivoNormativo(referencia) {
  const texto = typeof referencia === "string" ? referencia : "";
  return {
    temDiploma: PADRAO_DIPLOMA_IDENTIFICAVEL.test(texto),
    temArtigo: PADRAO_ARTIGO_IDENTIFICAVEL.test(texto),
  };
}

// Reparo Lote 09B (mandato "EXTENSAO CONTROLADA DO CONTRATO DE
// FUNDAMENTO", Secoes 9-12): jurisprudencia e fonte pedagogica oficial NAO
// sao normas — exigir diploma+artigo delas seria tao desonesto quanto o
// problema que MISSING_NORMATIVE_DEVICE corrigiu no Lote07. Os dois
// padroes abaixo sao deliberadamente GENERICOS (nao hardcoded a
// STF/STJ/ENAP especificamente): qualquer tribunal brasileiro reconhecivel
// e qualquer classe processual/tema/sumula contam; qualquer fonte
// institucional com >=2 segmentos rastreaveis (instituicao, documento,
// localizacao) conta.
const PADRAO_TRIBUNAL_IDENTIFICAVEL = /\b(STF|STJ|TST|TSE|STM|TRF-?\d{0,2}|TJ[A-Z]{2}|TRT-?\d{1,2}|Tribunal\s+Pleno|\d[ªa]\s+(Turma|Se[cç][ãa]o|C[aâ]mara))\b/i;
const PADRAO_PRECEDENTE_IDENTIFICAVEL = /\b(ADPF|ADI|ADIN|ADC|ADO|RE|REsp|RExt|ARE|HC|MS|MI|RMS|AgRg|Tema|S[uú]mula(\s+Vinculante)?)\b/i;

/**
 * Verifica se um texto de fundamento.referencia cita, de forma
 * identificavel, um TRIBUNAL e um IDENTIFICADOR de precedente (classe
 * processual com/sem numero, ou tema/sumula) — as duas exigencias minimas
 * para "precedente jurisprudencial rastreavel" (Lote09B, analogo ao
 * diploma+artigo do Lote07 mas para fundamento.tipo="regra_jurisprudencial").
 * Nao confere se o precedente citado realmente sustenta o conteudo da
 * questao nem se a tese esta corretamente descrita — isso fica para
 * revisao humana/normative_validation candidata a candidata.
 * @param {string} referencia
 * @returns {{ temTribunal: boolean, temIdentificador: boolean }}
 */
export function referenciaTemPrecedenteJurisprudencial(referencia) {
  const texto = typeof referencia === "string" ? referencia : "";
  return {
    temTribunal: PADRAO_TRIBUNAL_IDENTIFICAVEL.test(texto),
    temIdentificador: PADRAO_PRECEDENTE_IDENTIFICAVEL.test(texto),
  };
}

/**
 * Verifica se um texto de fundamento.referencia PARECE uma citacao
 * institucional rastreavel (instituicao + documento/material +,
 * idealmente, localizacao interna) para fundamento.tipo=
 * "fonte_pedagogica_oficial". Diferente do par diploma/artigo (regex de
 * palavras-chave fixas), aqui NAO existe um vocabulario fechado de nomes
 * de instituicao (ENAP hoje, outro orgao amanha) — hardcodear nomes de
 * instituicao especificos repetiria o erro que este mandato pede para
 * evitar. Em vez disso, exige uma heuristica estrutural minima: pelo
 * menos 2 segmentos separados por virgula/travessao, cada um com
 * conteudo real (>=3 caracteres), e comprimento total minimo — o
 * suficiente para distinguir "ENAP, Poderes da Administração e dos
 * Administradores, módulo 3" (rastreavel) de "doutrina administrativa"
 * ou "material da ENAP" (vago, nao auditavel).
 * @param {string} referencia
 * @returns {{ temSegmentosSuficientes: boolean, tamanhoSuficiente: boolean }}
 */
export function referenciaPareceInstitucionalRastreavel(referencia) {
  const texto = typeof referencia === "string" ? referencia.trim() : "";
  const segmentos = texto
    .split(/[,–—-]/)
    .map((s) => s.trim())
    .filter((s) => s.length >= 3);
  return {
    temSegmentosSuficientes: segmentos.length >= 2,
    tamanhoSuficiente: texto.length >= 20,
  };
}

/**
 * "Sabemos O QUE ensinar/cobrar nesta unidade?" — NUNCA prova fonte
 * factual validada, so completude do metadado pedagogico.
 *
 * @param {{
 *   escopoUnidade: string,
 *   artigosEsperadosUnidade: string[]|null,
 *   teoriaEscopoConteudo?: { escopo?: string, artigos_esperados?: string[]|null } | null,
 *   materialVersoesExistem: boolean,
 * }} entrada
 */
export function avaliarContextoPedagogico({ escopoUnidade, artigosEsperadosUnidade, teoriaEscopoConteudo = null, materialVersoesExistem = false }) {
  const escopoEfetivo = (teoriaEscopoConteudo?.escopo && teoriaEscopoConteudo.escopo.trim().length > 0)
    ? teoriaEscopoConteudo.escopo
    : escopoUnidade;

  const artigosEfetivos = Array.isArray(teoriaEscopoConteudo?.artigos_esperados) && teoriaEscopoConteudo.artigos_esperados.length > 0
    ? teoriaEscopoConteudo.artigos_esperados
    : (artigosEsperadosUnidade ?? null);

  const escopoVazio = !escopoEfetivo || escopoEfetivo.trim().length === 0;
  if (escopoVazio) {
    return {
      status: STATUS_CONTEXTO_PEDAGOGICO.PEDAGOGICAL_CONTEXT_INSUFFICIENT,
      reason: "EMPTY_SCOPE",
      escopo_efetivo: escopoEfetivo ?? "",
      artigos_esperados_efetivos: artigosEfetivos,
    };
  }

  const temArtigosEsperados = Array.isArray(artigosEfetivos) && artigosEfetivos.length > 0;
  if (temArtigosEsperados || materialVersoesExistem) {
    return {
      status: STATUS_CONTEXTO_PEDAGOGICO.PEDAGOGICAL_CONTEXT_COMPLETE,
      reason: temArtigosEsperados ? "artigos_esperados presentes (metadado pedagogico, NAO fonte validada)" : "material_versoes anexado (fonte de conteudo-base, ainda nao necessariamente validada)",
      escopo_efetivo: escopoEfetivo,
      artigos_esperados_efetivos: artigosEfetivos,
    };
  }

  return {
    status: STATUS_CONTEXTO_PEDAGOGICO.PEDAGOGICAL_CONTEXT_PARTIAL,
    reason: "escopo textual presente, sem artigos_esperados/material anexado",
    escopo_efetivo: escopoEfetivo,
    artigos_esperados_efetivos: artigosEfetivos,
  };
}

/**
 * @param {{
 *   unidadeAtiva: boolean,
 *   faltantes: number,
 *   quantidadeSolicitada?: number|null,
 *   pedagogicalContextStatus: string,
 *   sourceValidationStatus: string,
 *   requerFonteValidada: boolean,
 *   bancaStatus: string,
 *   aulaExiste: boolean,
 *   aulaPublicada: boolean,
 * }} entrada
 * @returns {{ status: string, blocking_reasons: string[], warnings: string[] }}
 */
export function avaliarElegibilidade({
  unidadeAtiva,
  faltantes,
  quantidadeSolicitada = null,
  pedagogicalContextStatus,
  sourceValidationStatus,
  requerFonteValidada,
  bancaStatus,
  aulaExiste,
  aulaPublicada,
}) {
  const blocking = [];
  const warnings = [];

  if (!unidadeAtiva) blocking.push("UNIT_INACTIVE");
  if (!(faltantes > 0)) blocking.push("NO_DEFICIT");
  if (pedagogicalContextStatus === STATUS_CONTEXTO_PEDAGOGICO.PEDAGOGICAL_CONTEXT_INSUFFICIENT) blocking.push("PEDAGOGICAL_CONTEXT_INSUFFICIENT");
  if (bancaStatus !== STATUS_BANCA.RESOLVED) blocking.push(bancaStatus === STATUS_BANCA.BLOCKED_NO_BANK ? "BLOCKED_NO_BANK" : bancaStatus);
  if (quantidadeSolicitada !== null && quantidadeSolicitada !== undefined) {
    if (!(quantidadeSolicitada > 0)) blocking.push("QUANTITY_MUST_BE_POSITIVE");
    if (quantidadeSolicitada > faltantes) blocking.push("QUANTITY_EXCEEDS_DEFICIT");
  }

  const fonteValidada = sourceValidationStatus === STATUS_VALIDACAO_FONTE.SOURCE_VALIDATED;
  if (!fonteValidada) {
    if (requerFonteValidada) {
      // Conteudo normativo/juridico: falta de fonte documentalmente
      // validada BLOQUEIA geracao automatica (Fase 2A.1, Secao 5).
      blocking.push("LEGAL_SOURCE_NOT_DOCUMENTALLY_VALIDATED");
    } else {
      // Outras materias: contexto pedagogico pode bastar — falta de fonte
      // validada vira warning, nao bloqueio (Secao 6).
      warnings.push(sourceValidationStatus);
    }
  } else if (sourceValidationStatus === STATUS_VALIDACAO_FONTE.SOURCE_PARTIAL) {
    warnings.push("SOURCE_PARTIAL_COVERAGE");
  }

  if (pedagogicalContextStatus === STATUS_CONTEXTO_PEDAGOGICO.PEDAGOGICAL_CONTEXT_PARTIAL) warnings.push("PEDAGOGICAL_CONTEXT_PARTIAL");
  if (!aulaExiste) warnings.push("LESSON_DOES_NOT_EXIST");
  else if (!aulaPublicada) warnings.push("LESSON_NOT_PUBLISHED");

  return {
    status: blocking.length === 0 ? STATUS_ELEGIBILIDADE.ELIGIBLE_FOR_GENERATION : STATUS_ELEGIBILIDADE.BLOCKED,
    blocking_reasons: blocking,
    warnings,
  };
}

/**
 * Ranking simples e explicavel — nunca calculado por IA (Secao 16).
 * Precedencia fixa, sempre documentada via reason_codes:
 *   1) bloqueado -> BLOCKED
 *   2) deficit pequeno (<=2) -> P3
 *   3) fonte REALMENTE validada, sem warnings -> P0
 *   4) fonte validada, com warnings -> P1
 *   5) elegivel sem exigir fonte validada (materia nao normativa) -> P2
 *
 * @param {{ elegibilidade: {status:string, blocking_reasons:string[], warnings:string[]}, faltantes: number, sourceValidationStatus: string }} entrada
 */
export function calcularPrioridade({ elegibilidade, faltantes, sourceValidationStatus }) {
  if (elegibilidade.status === STATUS_ELEGIBILIDADE.BLOCKED) {
    return { prioridade: "BLOCKED", reason_codes: elegibilidade.blocking_reasons };
  }

  if (faltantes <= 2) {
    return { prioridade: "P3", reason_codes: ["LOW_ABSOLUTE_DEFICIT"] };
  }

  const fonteValidada = sourceValidationStatus === STATUS_VALIDACAO_FONTE.SOURCE_VALIDATED;
  if (fonteValidada && elegibilidade.warnings.length === 0) {
    return { prioridade: "P0", reason_codes: ["SOURCE_VALIDATED", "NO_WARNINGS"] };
  }
  if (fonteValidada) {
    return { prioridade: "P1", reason_codes: ["SOURCE_VALIDATED", ...elegibilidade.warnings] };
  }

  return { prioridade: "P2", reason_codes: [sourceValidationStatus, ...elegibilidade.warnings] };
}
