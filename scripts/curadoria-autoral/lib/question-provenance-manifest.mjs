// Manifesto de PROVENIENCIA CURADA por questao (Fase 2C.3.2, Secoes 4-5).
//
// Fecha a brecha da Fase 2C.3.1: ali, REAL_OFFICIAL_CONFIRMED podia ser
// obtido automaticamente so por um PADRAO DE TEXTO no campo `fonte` (regex
// batendo em "Fundatec — ... — Questão N" ou na frase "gabarito oficial").
// Isso e um SOURCE_TEXT_PATTERN — um sinal para descoberta/triagem — nunca
// PROVENANCE_EVIDENCE (prova documental real de que a prova é oficial e o
// gabarito é o definitivo). Nenhuma tabela do schema guarda evidencia
// documental por questao (investigado ao vivo, Fase 2C.3.2 Secao 3: a
// tabela `questoes` nao tem edital_id/gabarito_url/campo de validacao
// alguma; `curso_evidencias` e por curso_conteudo_id, nao por questao;
// o manifesto de fontes pedagogicas de source-manifest.mjs valida ESCOPO
// de conteudo por unidade, nunca autenticidade de uma questao/gabarito
// especifica) — entao a UNICA fonte de evidencia real e honesta possivel
// hoje e um registro CURADO POR HUMANO, deliberado, neste manifesto local,
// no mesmo espirito de scripts/curadoria-autoral/sources/*.json.
//
// Diretorio inexistente ou vazio = ZERO questoes confirmadas — estado
// NORMAL e honesto (nenhuma curadoria de proveniencia por questao foi
// feita ainda), nunca um erro. NUNCA inferido automaticamente de texto:
// so um arquivo aqui, escrito deliberadamente por um humano com
// validated:true, conta.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
export const RAIZ_PROVENIENCIA_CURADA = path.resolve(__dirname, "..", "sources", "question-provenance");

export const QUESTION_PROVENANCE_SCHEMA_VERSION = 1;

function validarFormaRegistro(registro, caminho) {
  const erros = [];
  if (registro.schema_version !== QUESTION_PROVENANCE_SCHEMA_VERSION) erros.push("schema_version ausente ou nao suportada");
  if (typeof registro.bank !== "string" || !registro.bank.trim()) erros.push("bank ausente");
  if (!Array.isArray(registro.question_ids) || registro.question_ids.length === 0 || !registro.question_ids.every((id) => Number.isInteger(id) && id > 0)) {
    erros.push("question_ids precisa ser array nao-vazio de inteiros positivos (ids reais de questoes.id)");
  }
  if (typeof registro.official_exam_evidence !== "string" || !registro.official_exam_evidence.trim()) {
    erros.push("official_exam_evidence precisa descrever como a prova oficial foi confirmada (nunca so um regex)");
  }
  if (typeof registro.official_key_evidence !== "string" || !registro.official_key_evidence.trim()) {
    erros.push("official_key_evidence precisa descrever como o gabarito oficial definitivo foi confirmado");
  }
  if (typeof registro.validated !== "boolean") erros.push("validated precisa ser boolean explicito (nunca inferido)");
  if (registro.validated === true && !registro.validated_by) erros.push('validated=true exige validated_by preenchido (ex.: "human")');
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
 * Reduz os registros carregados a um Set de question_ids VALIDADOS
 * (validated===true) para a banca-alvo — a unica entrada que
 * classificarProveniencia aceita como prova de REAL_OFFICIAL_CONFIRMED.
 *
 * @param {object[]} registros — saida de carregarProvenienciaCurada
 * @param {string} bancaAlvoNormalizada
 */
export function obterIdsComProvenienciaConfirmada(registros, bancaAlvoNormalizada) {
  const ids = new Set();
  for (const registro of registros) {
    if (registro.validated !== true) continue;
    if (registro.bank.trim().toLowerCase() !== bancaAlvoNormalizada) continue;
    for (const id of registro.question_ids) ids.add(id);
  }
  return ids;
}
