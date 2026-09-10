// Manifesto de PROVENIENCIA CURADA por questao (Fase 2C.3.2, Secoes 4-5;
// schema estendido na Fase 2C.3.3, Secoes 8-14).
//
// Fecha a brecha da Fase 2C.3.1: ali, REAL_OFFICIAL_CONFIRMED podia ser
// obtido automaticamente so por um PADRAO DE TEXTO no campo `fonte` (regex
// batendo em "Fundatec — ... — Questão N" ou na frase "gabarito oficial").
// Isso e um SOURCE_TEXT_PATTERN — um sinal para descoberta/triagem — nunca
// PROVENANCE_EVIDENCE (prova documental real de que a prova é oficial e o
// gabarito é o definitivo). Nenhuma tabela do schema guarda evidencia
// documental por questao (investigado ao vivo, Fase 2C.3.2 Secao 3) —
// entao a UNICA fonte de evidencia real e honesta possivel hoje e um
// registro CURADO POR HUMANO, por PROVA/LOTE, neste manifesto local, no
// mesmo espirito de scripts/curadoria-autoral/sources/*.json.
//
// Fase 2C.3.3 (Secoes 8-14): um registro agora cobre UMA prova oficial
// inteira (evidencia da prova + evidencia do gabarito definitivo, cada
// uma com publisher/reference/url/document_hash/verified) e uma lista de
// QUESTOES individualmente mapeadas, cada uma com:
//   - match_status: o quanto o texto armazenado no Papiro corresponde ao
//     conteudo da questao oficial (EXACT/STRONG/AMBIGUOUS/NO_MATCH);
//   - key_status: se o gabarito armazenado no Papiro bate com o gabarito
//     oficial definitivo daquela questao especifica.
// Uma questao SO conta como REAL_OFFICIAL_CONFIRMED (Secao 14) quando: a
// prova E o gabarito oficiais do LOTE estao verified=true, o registro
// inteiro esta validated=true, E a questao individual tem match_status
// EXACT ou STRONG E key_status OFFICIAL_KEY_MATCH. Qualquer outra
// combinacao (AMBIGUOUS, NO_MATCH, MISMATCH, KEY_UNAVAILABLE, evidencia
// do lote nao verificada) e automaticamente excluida aqui — nunca decidida
// so no perfilador.
//
// Diretorio inexistente ou vazio = ZERO questoes confirmadas — estado
// NORMAL e honesto (nenhuma curadoria documental foi feita ainda), nunca
// um erro. NUNCA inferido automaticamente de texto: so um arquivo aqui,
// escrito deliberadamente por um humano com validated:true, conta.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
export const RAIZ_PROVENIENCIA_CURADA = path.resolve(__dirname, "..", "sources", "question-provenance");

export const QUESTION_PROVENANCE_SCHEMA_VERSION = 2;

export const MATCH_STATUS = Object.freeze({
  EXACT: "OFFICIAL_MATCH_EXACT",
  STRONG: "OFFICIAL_MATCH_STRONG",
  AMBIGUOUS: "OFFICIAL_MATCH_AMBIGUOUS",
  NO_MATCH: "NO_OFFICIAL_MATCH",
});

export const KEY_STATUS = Object.freeze({
  MATCH: "OFFICIAL_KEY_MATCH",
  MISMATCH: "OFFICIAL_KEY_MISMATCH",
  UNAVAILABLE: "OFFICIAL_KEY_UNAVAILABLE",
});

// Fase 2C.3.4, Secao 7: tipos de documento EXPLICITOS — nunca rotular
// automaticamente um documento como se fosse literalmente o caderno de
// prova quando na verdade e um julgamento de recursos, uma nota de
// resultado, ou outro documento oficial que so INCIDENTALMENTE reproduz
// conteudo suficiente para match. "official_exam" generico/ambiguo fica
// deliberadamente FORA da lista — forcar o curador a escolher um rotulo
// honesto sobre o documento real.
export const EXAM_EVIDENCE_SOURCE_TYPES = Object.freeze([
  "official_exam_booklet", // o proprio caderno de prova, digitalizado/publicado pela banca ou pelo orgao
  "official_appeal_decision", // julgamento de recursos que reproduz conteudo da questao suficiente para match
  "official_contest_document", // outro documento oficial do concurso que reproduz conteudo suficiente para match
]);

// gabarito PRELIMINAR nunca confirma (Secao 6: "Se apenas preliminar
// estiver disponível: NÃO promover") — por isso nao entra nesta lista;
// so o gabarito ja incorporado ao julgamento final/definitivo conta.
export const KEY_EVIDENCE_SOURCE_TYPES = Object.freeze(["official_final_answer_key", "official_appeal_decision"]);

const MATCH_STATUS_VALIDOS = new Set(Object.values(MATCH_STATUS));
const KEY_STATUS_VALIDOS = new Set(Object.values(KEY_STATUS));
const MATCH_STATUS_ELEGIVEIS_PARA_CONFIRMACAO = new Set([MATCH_STATUS.EXACT, MATCH_STATUS.STRONG]);
const EXAM_EVIDENCE_SOURCE_TYPES_VALIDOS = new Set(EXAM_EVIDENCE_SOURCE_TYPES);
const KEY_EVIDENCE_SOURCE_TYPES_VALIDOS = new Set(KEY_EVIDENCE_SOURCE_TYPES);

const PADRAO_HASH_SHA256 = /^[a-f0-9]{64}$/i;

function validarBlocoEvidencia(bloco, nomeCampo, tiposValidos, erros) {
  if (!bloco || typeof bloco !== "object") {
    erros.push(`${nomeCampo} precisa ser um objeto`);
    return;
  }
  if (!tiposValidos.has(bloco.source_type)) {
    erros.push(`${nomeCampo}.source_type invalido ou generico demais (esperado um de: ${[...tiposValidos].join(", ")}) — nunca rotular como "official_exam" sem dizer que tipo de documento realmente e`);
  }
  if (typeof bloco.publisher !== "string" || !bloco.publisher.trim()) erros.push(`${nomeCampo}.publisher ausente`);
  if (typeof bloco.reference !== "string" || !bloco.reference.trim()) erros.push(`${nomeCampo}.reference ausente`);
  if (typeof bloco.verified !== "boolean") erros.push(`${nomeCampo}.verified precisa ser boolean explicito`);
  // Secao 12-13 (Fase 2C.3.3): se marcado verified=true, exige
  // rastreabilidade real — url OU document_hash sozinho nao basta como
  // prova de que o documento foi de fato inspecionado; exigimos os dois
  // quando verified=true. Um hash malformado/ausente com verified=true e
  // tratado como evidencia INCOMPATIVEL — nunca aceito silenciosamente.
  if (bloco.verified === true) {
    if (typeof bloco.url !== "string" || !bloco.url.trim()) erros.push(`${nomeCampo}.url exigido quando verified=true`);
    if (typeof bloco.document_hash !== "string" || !PADRAO_HASH_SHA256.test(bloco.document_hash)) {
      erros.push(`${nomeCampo}.document_hash precisa ser um sha256 hex valido (64 chars) quando verified=true — hash ausente/malformado e evidencia incompatível`);
    }
  }
}

function validarFormaRegistro(registro, caminho) {
  const erros = [];
  if (registro.schema_version !== QUESTION_PROVENANCE_SCHEMA_VERSION) erros.push("schema_version ausente ou nao suportada");
  if (typeof registro.bank !== "string" || !registro.bank.trim()) erros.push("bank ausente");
  if (typeof registro.contest !== "string" || !registro.contest.trim()) erros.push("contest ausente");
  if (typeof registro.role !== "string" || !registro.role.trim()) erros.push("role ausente");
  if (!Number.isInteger(registro.year)) erros.push("year precisa ser inteiro");

  validarBlocoEvidencia(registro.official_exam_evidence, "official_exam_evidence", EXAM_EVIDENCE_SOURCE_TYPES_VALIDOS, erros);
  validarBlocoEvidencia(registro.official_key_evidence, "official_key_evidence", KEY_EVIDENCE_SOURCE_TYPES_VALIDOS, erros);

  if (typeof registro.validated !== "boolean") erros.push("validated precisa ser boolean explicito (nunca inferido)");
  if (registro.validated === true && !registro.validated_by) erros.push('validated=true exige validated_by preenchido (ex.: "human_documentary_curation")');

  if (!Array.isArray(registro.questions) || registro.questions.length === 0) {
    erros.push("questions precisa ser array nao-vazio");
  } else {
    registro.questions.forEach((q, i) => {
      if (!Number.isInteger(q.question_id) || q.question_id <= 0) erros.push(`questions[${i}].question_id precisa ser inteiro positivo (id real de questoes.id)`);
      if (!Number.isInteger(q.official_question_number) || q.official_question_number <= 0) erros.push(`questions[${i}].official_question_number precisa ser inteiro positivo`);
      if (!MATCH_STATUS_VALIDOS.has(q.match_status)) erros.push(`questions[${i}].match_status invalido (esperado um de: ${[...MATCH_STATUS_VALIDOS].join(", ")})`);
      if (!KEY_STATUS_VALIDOS.has(q.key_status)) erros.push(`questions[${i}].key_status invalido (esperado um de: ${[...KEY_STATUS_VALIDOS].join(", ")})`);
    });
  }

  if (erros.length > 0) {
    throw new Error(`Registro de proveniencia curada invalido em ${caminho}: ${erros.join("; ")}`);
  }
}

/**
 * Carrega todos os registros de proveniencia curada de um diretorio
 * (default: scripts/curadoria-autoral/sources/question-provenance/).
 * Diretorio inexistente ou vazio retorna [] — normal, nao erro.
 */
export function carregarProvenienciaCurada(diretorio = RAIZ_PROVENIENCIA_CURADA) {
  if (!fs.existsSync(diretorio)) return [];
  const arquivos = fs.readdirSync(diretorio).filter((f) => f.endsWith(".json"));
  return arquivos.map((arquivo) => {
    const caminho = path.join(diretorio, arquivo);
    const registro = JSON.parse(fs.readFileSync(caminho, "utf8"));
    validarFormaRegistro(registro, caminho);
    return registro;
  });
}

/**
 * Reduz os registros carregados a um Map de question_id -> metadados de
 * proveniencia (examKey/contest/role/year) para TODAS as questoes que
 * satisfazem os criterios da Secao 14 do mandato 2C.3.3 para a
 * banca-alvo:
 *   1. registro.validated === true;
 *   2. official_exam_evidence.verified === true;
 *   3. official_key_evidence.verified === true;
 *   4. a questao individual tem match_status EXACT ou STRONG;
 *   5. a questao individual tem key_status OFFICIAL_KEY_MATCH.
 * Qualquer falha em qualquer um desses pontos exclui a questao — nunca
 * promovida por inercia ou por estar "quase" completa.
 *
 * examKey (Fase 2C.3.4, Secao 12) identifica a PROVA fisica de origem —
 * usa o document_hash da evidencia da prova, que identifica unicamente o
 * documento fisico inspecionado (duas questoes do mesmo documento
 * compartilham o mesmo examKey; nunca inferido do texto de contest/role/
 * year, que poderiam colidir por coincidencia de nomenclatura).
 *
 * @param {object[]} registros — saida de carregarProvenienciaCurada
 * @param {string} bancaAlvoNormalizada
 * @returns {Map<number, { examKey: string, contest: string, role: string, year: number }>}
 */
export function obterProvenienciaConfirmada(registros, bancaAlvoNormalizada) {
  const mapa = new Map();
  for (const registro of registros) {
    if (registro.validated !== true) continue;
    if (registro.bank.trim().toLowerCase() !== bancaAlvoNormalizada) continue;
    if (registro.official_exam_evidence.verified !== true) continue;
    if (registro.official_key_evidence.verified !== true) continue;
    const examKey = registro.official_exam_evidence.document_hash;
    for (const q of registro.questions) {
      if (!MATCH_STATUS_ELEGIVEIS_PARA_CONFIRMACAO.has(q.match_status)) continue;
      if (q.key_status !== KEY_STATUS.MATCH) continue;
      mapa.set(q.question_id, { examKey, contest: registro.contest, role: registro.role, year: registro.year });
    }
  }
  return mapa;
}

/**
 * Compatibilidade: Set de question_ids confirmados (sem os metadados de
 * diversidade), derivado de obterProvenienciaConfirmada. Usado por
 * classificarProveniencia, que so precisa de `.has(id)`.
 *
 * @param {object[]} registros — saida de carregarProvenienciaCurada
 * @param {string} bancaAlvoNormalizada
 */
export function obterIdsComProvenienciaConfirmada(registros, bancaAlvoNormalizada) {
  return new Set(obterProvenienciaConfirmada(registros, bancaAlvoNormalizada).keys());
}
