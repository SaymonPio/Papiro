// Fingerprint determinístico do input da auditoria + leitura do estado
// persistido + resume planner (Fase 2C.1, Secoes 4-5). Le arquivos locais
// (audit_blind.json/audit_critic.json/audit_result.json) — nunca fala com
// a OpenAI nem com o Supabase.

import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";
import { validarRespostaBlindLocalmente, validarRespostaCriticLocalmente } from "./audit-orchestrator.mjs";

/**
 * Hash determinístico do "input logico" da auditoria — dois runs com o
 * MESMO conteudo de questoes/contexto/modelo/versoes de prompt produzem o
 * mesmo fingerprint; qualquer diferenca muda o hash. Usado para nunca
 * reaproveitar um artefato parcial de um input diferente (Secao 4).
 *
 * @param {{
 *   questoesGeradasRaw: string,
 *   runId: string,
 *   questionKeys: string[],
 *   model: string,
 *   blindPromptVersion: string,
 *   criticPromptVersion: string,
 *   escopo: string,
 *   fontesValidadas: string[],
 * }} entrada
 */
export function calcularFingerprintAuditoria({ questoesGeradasRaw, runId, questionKeys, model, blindPromptVersion, criticPromptVersion, escopo, fontesValidadas }) {
  const base = {
    questoes_hash: crypto.createHash("sha256").update(questoesGeradasRaw, "utf8").digest("hex"),
    run_id: runId,
    question_keys: [...questionKeys].sort(),
    model,
    blind_prompt_version: blindPromptVersion,
    critic_prompt_version: criticPromptVersion,
    escopo_hash: crypto.createHash("sha256").update(escopo || "", "utf8").digest("hex"),
    fontes_validadas: [...(fontesValidadas || [])].sort(),
  };
  return crypto.createHash("sha256").update(JSON.stringify(base), "utf8").digest("hex");
}

function lerJsonSeExiste(caminho) {
  if (!fs.existsSync(caminho)) return null;
  try {
    return JSON.parse(fs.readFileSync(caminho, "utf8"));
  } catch {
    return { __parse_error__: true };
  }
}

/**
 * Le o estado persistido de um run (os 3 artefatos possiveis), validando
 * localmente cada um contra seu proprio contrato. Nunca lanca — arquivo
 * ausente vira `null`; arquivo ilegivel ou reprovado na validacao vira
 * `{ existe:true, valido:false, ... }`.
 */
export function lerEstadoAuditoria(dirRun) {
  const blindRaw = lerJsonSeExiste(path.join(dirRun, "audit_blind.json"));
  const criticRaw = lerJsonSeExiste(path.join(dirRun, "audit_critic.json"));
  const resultRaw = lerJsonSeExiste(path.join(dirRun, "audit_result.json"));

  function avaliar(raw, validador) {
    if (!raw) return null;
    if (raw.__parse_error__) return { existe: true, valido: false, audit_input_fingerprint: null, dados: null, motivo_invalido: "JSON_PARSE_ERROR" };
    const validacao = validador ? validador(raw) : { ok: true, errors: [] };
    return {
      existe: true,
      valido: validacao.ok,
      audit_input_fingerprint: raw.audit_input_fingerprint ?? null,
      dados: raw,
      motivo_invalido: validacao.ok ? null : validacao.errors.join("; "),
    };
  }

  return {
    blind: avaliar(blindRaw, validarRespostaBlindLocalmente),
    critic: avaliar(criticRaw, validarRespostaCriticLocalmente),
    result: avaliar(resultRaw, null),
  };
}

export const ACOES_RETOMADA = Object.freeze({
  RUN_BLIND_THEN_CRITIC: "RUN_BLIND_THEN_CRITIC",
  RUN_CRITIC_ONLY: "RUN_CRITIC_ONLY",
  AGGREGATE_ONLY: "AGGREGATE_ONLY",
  AUDIT_ALREADY_COMPLETE: "AUDIT_ALREADY_COMPLETE",
  BLOCKED_INCOMPATIBLE_PARTIAL: "BLOCKED_INCOMPATIBLE_PARTIAL",
});

/**
 * Decide deterministicamente a proxima acao (Secao 5). Prioridade 1,
 * SEMPRE checada primeiro: qualquer artefato EXISTENTE (blind/critic/
 * result) cujo fingerprint divirja do atual, ou que exista mas reprove a
 * validacao local, BLOQUEIA — nunca e silenciosamente ignorado nem
 * sobrescrito.
 *
 * @param {{ fingerprintAtual: string, blindPersistido: object|null, criticPersistido: object|null, resultPersistido: object|null }} entrada
 */
export function planejarRetomada({ fingerprintAtual, blindPersistido, criticPersistido, resultPersistido }) {
  for (const [nome, artefato] of [
    ["blind", blindPersistido],
    ["critic", criticPersistido],
    ["result", resultPersistido],
  ]) {
    if (!artefato) continue;
    if (artefato.audit_input_fingerprint !== fingerprintAtual) {
      return {
        action: ACOES_RETOMADA.BLOCKED_INCOMPATIBLE_PARTIAL,
        reason: `${nome}: fingerprint divergente do input atual (existente=${artefato.audit_input_fingerprint ?? "ausente"}, atual=${fingerprintAtual}) — nunca reutilizado silenciosamente`,
      };
    }
    if (!artefato.valido) {
      return {
        action: ACOES_RETOMADA.BLOCKED_INCOMPATIBLE_PARTIAL,
        reason: `${nome}: arquivo existe mas reprovou validacao local (${artefato.motivo_invalido}) — requer limpeza manual, nunca sobrescrita silenciosa`,
      };
    }
  }

  if (resultPersistido) return { action: ACOES_RETOMADA.AUDIT_ALREADY_COMPLETE, reason: "audit_result.json ja existe e e valido para este input." };
  if (blindPersistido && criticPersistido) return { action: ACOES_RETOMADA.AGGREGATE_ONLY, reason: "blind e critic ja validos para este input; falta so agregar (zero API)." };
  if (blindPersistido) return { action: ACOES_RETOMADA.RUN_CRITIC_ONLY, reason: "blind ja valido para este input; Call A NAO sera repetida." };
  return { action: ACOES_RETOMADA.RUN_BLIND_THEN_CRITIC, reason: "nenhum blind valido encontrado para este input — Call A precisa rodar." };
}
