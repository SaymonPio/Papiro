// Manifesto do run (Fase 2A, Secao 6). O UNICO lugar deste modulo que
// chama `git` (via child_process, Node built-in — nenhuma dependencia
// nova). Nunca registra segredo nenhum (API keys, service role key,
// senha de banco, dado pessoal de aluno) — so metadados de execucao.

import crypto from "node:crypto";
import { execFileSync } from "node:child_process";
import { RAIZ_PROJETO } from "./artifact-writer.mjs";

const TOOL_VERSION = "0.1.0-fase2a";
const MANIFEST_SCHEMA_VERSION = 1;

export function gerarRunId() {
  return crypto.randomUUID();
}

function gitInfo() {
  try {
    const branch = execFileSync("git", ["rev-parse", "--abbrev-ref", "HEAD"], { cwd: RAIZ_PROJETO, encoding: "utf8" }).trim();
    const head = execFileSync("git", ["rev-parse", "HEAD"], { cwd: RAIZ_PROJETO, encoding: "utf8" }).trim();
    return { git_branch: branch, git_head: head };
  } catch {
    return { git_branch: null, git_head: null };
  }
}

/**
 * @param {{ runId: string, cursoId?: string|null, targetBankSize: number }} entrada
 * @returns {object} manifesto base, ainda sem status/arquivos_produzidos
 *   (o CLI completa esses campos no final da execucao)
 */
export function criarManifestoBase({ runId, cursoId = null, targetBankSize }) {
  const { git_branch, git_head } = gitInfo();
  return {
    schema_version: MANIFEST_SCHEMA_VERSION,
    run_id: runId,
    created_at: new Date().toISOString(),
    tool_version: TOOL_VERSION,
    git_branch,
    git_head,
    modo: "DRY_RUN",
    api_calls: 0,
    db_writes: 0,
    curso_id: cursoId,
    target_bank_size: targetBankSize,
    target_origin: "curadoria",
    status: "DISCOVERED",
    arquivos_produzidos: [],
  };
}

export function finalizarManifesto(manifestoBase, { status, arquivosProduzidos }) {
  return {
    ...manifestoBase,
    status,
    arquivos_produzidos: arquivosProduzidos,
    finished_at: new Date().toISOString(),
  };
}
