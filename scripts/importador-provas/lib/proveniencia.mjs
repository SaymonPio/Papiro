// Monta e valida a proveniência do DOCUMENTO (uma prova oficial) no
// formato de public.provas (supabase/migrations/20261018120000_
// proveniencia_provas.sql). Nenhuma questão do pipeline pode ficar
// PRONTA_PARA_REVISAO sem proveniência completa — score.mjs usa o
// resultado daqui como etapa bloqueante (PROVENIENCIA_OK).
//
// Os hashes vêm SEMPRE dos arquivos efetivamente lidos pelo cli.mjs
// (calcularHashArquivo), nunca do manifest do coletor: o manifest
// descreve o que foi baixado, o hash aqui descreve o que foi extraído.
// A URL nunca é identidade do documento — só o hash é (UNIQUE no
// banco); a URL é registrada para auditoria.

import fs from "node:fs";
import { createHash } from "node:crypto";

const REGEX_HASH = /^[0-9a-f]{64}$/;
const REGEX_URL = /^https?:\/\//;

export function calcularHashArquivo(caminho) {
  return createHash("sha256").update(fs.readFileSync(caminho)).digest("hex");
}

function texto(valor) {
  return typeof valor === "string" && valor.trim() !== "" ? valor.trim() : null;
}

// retificacoes (opcional): documentos que alteram o gabarito base, na
// ordem explícita em que foram aplicados — [{ ordem, documento, url,
// hash }]. Ficam FORA de `prova` (que espelha as colunas de
// public.provas): o schema atual não tem onde gravá-las, mas elas entram
// no manifesto (e no hash dele) e são conferidas de novo pelo executor.
// gabaritoTipo: "definitivo" (padrão) ou "preliminar" (antes dos recursos —
// o planejador bloqueia o apply).
export function montarProveniencia(metadata, { hashProva, hashGabarito, retificacoes = [], gabaritoTipo = "definitivo" }) {
  const ano = Number.isInteger(metadata?.ano) ? metadata.ano : null;
  const prova = {
    banca: texto(metadata?.banca),
    orgao: texto(metadata?.orgao),
    cargo: texto(metadata?.cargo),
    ano: ano !== null && ano >= 1900 && ano <= 2200 ? ano : null,
    nome: texto(metadata?.nome_prova),
    fonte_url: texto(metadata?.fonte_url),
    gabarito_url: texto(metadata?.gabarito_url),
    hash_prova: hashProva ?? null,
    hash_gabarito: hashGabarito ?? null,
  };

  const faltando = ["banca", "orgao", "cargo", "ano", "nome", "fonte_url", "hash_prova", "hash_gabarito"].filter((campo) => prova[campo] === null);
  const invalidos = [];
  if (prova.fonte_url !== null && !REGEX_URL.test(prova.fonte_url)) invalidos.push("fonte_url");
  // gabarito_url é opcional (gabarito pode vir de .txt local), mas se
  // vier precisa ser uma URL de verdade.
  if (prova.gabarito_url !== null && !REGEX_URL.test(prova.gabarito_url)) invalidos.push("gabarito_url");
  if (prova.hash_prova !== null && !REGEX_HASH.test(prova.hash_prova)) invalidos.push("hash_prova");
  if (prova.hash_gabarito !== null && !REGEX_HASH.test(prova.hash_gabarito)) invalidos.push("hash_gabarito");

  const retificacoesGabarito = retificacoes.map((r) => ({ ordem: r.ordem, documento: texto(r.documento), url: texto(r.url), hash: r.hash ?? null }));
  for (const r of retificacoesGabarito) {
    const rotulo = `retificacao[${r.ordem}]`;
    if (r.url === null) faltando.push(`${rotulo}.url`);
    else if (!REGEX_URL.test(r.url)) invalidos.push(`${rotulo}.url`);
    if (r.hash === null) faltando.push(`${rotulo}.hash`);
    else if (!REGEX_HASH.test(r.hash)) invalidos.push(`${rotulo}.hash`);
  }

  return { prova, retificacoes: retificacoesGabarito, gabarito_tipo: gabaritoTipo, completa: faltando.length === 0 && invalidos.length === 0, faltando, invalidos };
}
