// Escrita segura de artefatos locais (Fase 2A, Secao 26). Nunca escreve
// no banco — so arquivos, sempre write-temp-then-rename para nunca deixar
// um arquivo parcialmente escrito em caso de falha no meio da escrita.
//
// Localizacao: outputs/curadoria-autoral/<run_id>/ — CONFIRMADO via
// `git check-ignore` que outputs/ (regra "/outputs/" do .gitignore raiz)
// esta ignorado; relatorios/ na raiz NAO estava (so
// scripts/curadoria-pedagogica/relatorios/ estava), por isso outputs/ foi
// escolhido em vez de relatorios/curadoria-autoral/ (Secao 5).

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

// lib -> curadoria-autoral -> scripts -> raiz do projeto (Papiro.com)
export const RAIZ_PROJETO = path.resolve(__dirname, "..", "..", "..");
export const RAIZ_SAIDA = path.join(RAIZ_PROJETO, "outputs", "curadoria-autoral");

export function garantirDiretorio(caminho) {
  fs.mkdirSync(caminho, { recursive: true });
}

/**
 * Cria (e reserva) o diretorio de um run. Aborta se o run_id ja existe —
 * nunca sobrescreve silenciosamente um run anterior (Secao 26).
 */
export function prepararDiretorioRun(runId) {
  const dir = path.join(RAIZ_SAIDA, runId);
  if (fs.existsSync(dir)) {
    throw new Error(`Run ${runId} ja existe em ${dir} — abortando (nao sobrescrevo run existente).`);
  }
  garantirDiretorio(dir);
  garantirDiretorio(path.join(dir, "payloads"));
  return dir;
}

function escreverComRename(caminhoFinal, conteudo) {
  garantirDiretorio(path.dirname(caminhoFinal));
  const caminhoTemp = `${caminhoFinal}.tmp-${process.pid}-${Date.now()}`;
  fs.writeFileSync(caminhoTemp, conteudo, "utf8");
  fs.renameSync(caminhoTemp, caminhoFinal);
}

export function escreverArtefatoJson(caminho, dados) {
  escreverComRename(caminho, JSON.stringify(dados, null, 2) + "\n");
}

export function escreverArtefatoTexto(caminho, texto) {
  escreverComRename(caminho, texto.endsWith("\n") ? texto : texto + "\n");
}
