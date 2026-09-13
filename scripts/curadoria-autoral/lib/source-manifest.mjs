// Manifesto de fontes LOCAL e rastreavel (Fase 2A.1, Secoes 4, 7, 8).
// Objetivo: separar "existe metadado pedagogico" (escopo/artigos_esperados
// — ver eligibility.mjs) de "existe fonte factual/normativa REALMENTE
// validada por um humano". NUNCA infere validated=true a partir de texto
// existente — so um arquivo com validated:true, escrito deliberadamente,
// conta.
//
// Localizacao: scripts/curadoria-autoral/sources/*.json — VERSIONADO
// (diferente de outputs/curadoria-autoral/, que e efemero/gitignored).
// Isso e conhecimento de curadoria durave, no mesmo espirito de
// scripts/curadoria-pedagogica/config/ordem-curadoria.json.
//
// Leitura pura de arquivos locais — nao fala com o Supabase, nao chama
// nenhuma API externa.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { CHAVES_FONTE_MANIFESTO, SOURCE_MANIFEST_SCHEMA_VERSION, STATUS_VALIDACAO_FONTE, TIPOS_FONTE } from "./schemas.mjs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
export const RAIZ_FONTES = path.resolve(__dirname, "..", "sources");

function validarFormaFonte(registro, caminho) {
  const erros = [];
  if (registro.schema_version !== SOURCE_MANIFEST_SCHEMA_VERSION) erros.push("schema_version ausente ou nao suportada");
  if (typeof registro.source_key !== "string" || !registro.source_key.trim()) erros.push("source_key ausente");
  if (!TIPOS_FONTE.includes(registro.type)) erros.push(`type invalido (esperado um de: ${TIPOS_FONTE.join(", ")})`);
  if (typeof registro.validated !== "boolean") erros.push("validated precisa ser boolean explicito (nunca inferido)");
  if (!Array.isArray(registro.applies_to_unit_ids)) erros.push("applies_to_unit_ids precisa ser array (mesmo vazio)");
  if (registro.validated === true && !registro.validated_by) erros.push('validated=true exige validated_by preenchido (ex.: "human")');
  if (erros.length > 0) {
    throw new Error(`Fonte invalida em ${caminho}: ${erros.join("; ")}`);
  }
}

/**
 * Carrega todos os registros de fonte de um diretorio (default:
 * scripts/curadoria-autoral/sources/). Diretorio inexistente ou vazio
 * retorna [] — isso e um estado NORMAL (nenhuma fonte foi validada ainda),
 * nunca um erro.
 */
export function carregarFontes(diretorio = RAIZ_FONTES) {
  if (!fs.existsSync(diretorio)) return [];
  const arquivos = fs.readdirSync(diretorio).filter((f) => f.endsWith(".json"));
  return arquivos.map((arquivo) => {
    const caminho = path.join(diretorio, arquivo);
    const registro = JSON.parse(fs.readFileSync(caminho, "utf8"));
    validarFormaFonte(registro, caminho);
    return registro;
  });
}

export function buscarFontesParaUnidade(fontes, unidadeId) {
  return fontes.filter((f) => f.applies_to_unit_ids.includes(unidadeId));
}

// Reparo Lote 07 (mandato "COMPLEMENTO FINAL DA LOB", Secoes 8-9): o
// invariante "validated=true" sozinho NUNCA foi suficiente para fontes
// JURIDICAS (type=official_law) — precisa, alem disso, de sign-off humano
// EXPLICITO e AUTORIZADO, nunca so pesquisa/validacao feita por IA. Fontes
// NAO juridicas preservam o comportamento anterior (CASO F): so
// validated=true, sem exigir human_source_signoff (campo que nem existe em
// varios manifestos pedagogicos mais antigos, legitimamente).
//
// "Compativel com operador/curadoria humana autorizada" e verificado pelo
// PREFIXO "human_" em validated_by — convencao ja em uso por TODOS os
// manifestos deste projeto (human_operator_explicit_signoff_*,
// human_curated_project_context). Um validated_by como "openai_websearch"
// ou "ia_pesquisa_secundaria" NUNCA bate nesse padrao, entao nunca conta
// como sign-off humano (CASO D).
const PADRAO_VALIDATED_BY_HUMANO = /^human[_-]/i;

// Reparo Lote 09B (mandato "EXTENSAO CONTROLADA DO CONTRATO DE
// FUNDAMENTO", Secao 8): o rigor estrito de sign-off humano do CASO A-F
// abaixo nasceu pensado so para "official_law", mas jurisprudencia
// (official_jurisprudence) e material didatico institucional oficial
// (official_pedagogical) sao igualmente sensiveis — nenhum dos tres deve
// virar SOURCE_VALIDATED so por ter validated=true escrito por IA/pesquisa
// automatica. Generalizado para um SET nomeado (nao um encadeamento de
// if por tipo) para que um futuro quarto tipo de alta confianca baste
// adicionar aqui, sem tocar a logica de decisao.
const TIPOS_FONTE_EXIGEM_SIGNOFF_HUMANO_ESTRITO = new Set(["official_law", "official_jurisprudence", "official_pedagogical"]);

/**
 * CASO A-F do mandato "COMPLEMENTO FINAL DA LOB" (Secao 9), generalizado
 * no Lote09B: decide se uma fonte JA TEM sign-off humano autorizado o
 * suficiente para contar como "validada" na agregacao de
 * avaliarValidacaoFonte. Fontes de ALTA CONFIANCA (official_law,
 * official_jurisprudence, official_pedagogical) exigem o rigor estrito
 * (CASO B-E); as demais so precisam de validated=true (CASO F).
 * @param {object} fonte
 * @returns {boolean}
 */
export function fonteTemSignoffHumanoAutorizado(fonte) {
  if (fonte?.validated !== true) return false; // CASO A
  if (!TIPOS_FONTE_EXIGEM_SIGNOFF_HUMANO_ESTRITO.has(fonte.type)) return true; // CASO F
  if (fonte.human_source_signoff !== "APPROVED") return false; // CASO B (ausente) / CASO C (PENDING)
  return typeof fonte.validated_by === "string" && PADRAO_VALIDATED_BY_HUMANO.test(fonte.validated_by.trim()); // CASO D (false) / CASO E (true)
}

/**
 * Decide o STATUS_VALIDACAO_FONTE de uma unidade a partir SOMENTE das
 * fontes que ja a referenciam (buscarFontesParaUnidade). Nunca olha
 * escopo/artigos_esperados — isso e responsabilidade de
 * avaliarContextoPedagogico em eligibility.mjs.
 *
 * @param {{ fontesDaUnidade: object[], artigosEsperados?: string[]|null }} entrada
 */
export function avaliarValidacaoFonte({ fontesDaUnidade, artigosEsperados = null }) {
  if (!fontesDaUnidade || fontesDaUnidade.length === 0) {
    return { status: STATUS_VALIDACAO_FONTE.SOURCE_MISSING, reason: "nenhuma fonte no manifesto local referencia esta unidade", validated_sources: [] };
  }

  const validadas = fontesDaUnidade.filter((f) => fonteTemSignoffHumanoAutorizado(f));
  if (validadas.length === 0) {
    return {
      status: STATUS_VALIDACAO_FONTE.SOURCE_REQUIRES_HUMAN_VALIDATION,
      reason: `${fontesDaUnidade.length} fonte(s) candidata(s) registrada(s), nenhuma com validated=true ainda`,
      validated_sources: [],
    };
  }

  const artigosEsperadosSet = new Set(artigosEsperados ?? []);
  const cobreTudo = validadas.some((f) => {
    if (!Array.isArray(f.covers_articles) || artigosEsperadosSet.size === 0) return true; // sem declaracao = assume cobertura total
    return [...artigosEsperadosSet].every((artigo) => f.covers_articles.includes(artigo));
  });

  if (cobreTudo) {
    return { status: STATUS_VALIDACAO_FONTE.SOURCE_VALIDATED, reason: "fonte validada cobre o escopo esperado", validated_sources: validadas.map((f) => f.source_key) };
  }

  return {
    status: STATUS_VALIDACAO_FONTE.SOURCE_PARTIAL,
    reason: "fonte(s) validada(s) existem, mas nao declaram cobertura de todos os artigos_esperados desta unidade",
    validated_sources: validadas.map((f) => f.source_key),
  };
}

export { CHAVES_FONTE_MANIFESTO };
