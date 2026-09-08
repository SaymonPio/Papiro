#!/usr/bin/env node
// CLI — diagnosticar cobertura multi-curso (Fase 2A, Secao 29). READ-ONLY
// no Supabase, zero chamada a API de IA, zero escrita no banco.
//
// Uso:
//   node scripts/curadoria-autoral/cli/diagnosticar-cobertura.mjs --all-courses
//   node scripts/curadoria-autoral/cli/diagnosticar-cobertura.mjs --curso-slug brigada-militar-rs
//   node scripts/curadoria-autoral/cli/diagnosticar-cobertura.mjs --curso-id <uuid> --target-bank-size 12

import { parseArgs } from "node:util";
import path from "node:path";
import { carregarDadosBrutosAutoDetectado, resolverCurso } from "../lib/context-resolver.mjs";
import { escanearCursoCompleto } from "../lib/coverage-scanner.mjs";
import { carregarFontes } from "../lib/source-manifest.mjs";
import { criarManifestoBase, finalizarManifesto, gerarRunId } from "../lib/run-manifest.mjs";
import { escreverArtefatoJson, escreverArtefatoTexto, prepararDiretorioRun } from "../lib/artifact-writer.mjs";
import { STATUS_CURSO_SEM_ANDAIME } from "../lib/schemas.mjs";

function gerarCoberturaMd(coberturaPorCurso) {
  const linhas = ["# Cobertura — Esteira Autoral (Fase 2A)", ""];

  for (const item of coberturaPorCurso) {
    linhas.push(`## Curso: ${item.curso.slug}`, "");
    linhas.push(`banca: ${item.curso.banca ?? "(nao resolvida)"}`);
    linhas.push(`status: ${item.status}`);
    if (item.status === STATUS_CURSO_SEM_ANDAIME) {
      linhas.push(`motivo: ${item.motivo}`, "");
      continue;
    }
    linhas.push(
      `unidades: ${item.unidades_relevantes} · completas: ${item.unidades_ge_target} · deficitarias: ${item.unidades_lt_target} · deficit total: ${item.deficit_total}`,
      ""
    );
    linhas.push(
      "| materia | conteudo | unidade | aula | banca | uteis | REAL | AUTORAL | IA | target | faltantes | contexto pedagogico | validacao de fonte | eligibility | prioridade | bloqueios |",
      "|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|"
    );
    for (const u of item.unidades) {
      linhas.push(
        `| ${u.materia_nome} | ${u.conteudo_id} | ${u.unidade_titulo} | ${u.aula_publicada ? "publicada" : u.aula_existe ? "rascunho" : "nao existe"} | ${u.banca_status} | ${u.questoes_uteis} | ${u.questoes_real} | ${u.questoes_autoral} | ${u.questoes_geradas_por_ia} | ${u.target_bank_size} | ${u.faltantes} | ${u.pedagogical_context_status} | ${u.source_validation_status} | ${u.generation_eligibility} | ${u.priority_label} | ${u.blocking_reasons.join(", ") || "-"} |`
      );
    }
    linhas.push("");
  }

  return linhas.join("\n");
}

async function main() {
  const { values } = parseArgs({
    options: {
      "curso-id": { type: "string" },
      "curso-slug": { type: "string" },
      "all-courses": { type: "boolean", default: false },
      "target-bank-size": { type: "string", default: "10" },
      output: { type: "string" },
    },
  });

  if (!values["curso-id"] && !values["curso-slug"] && !values["all-courses"]) {
    console.error("Informe --curso-id, --curso-slug ou --all-courses.");
    process.exit(1);
  }

  const targetBankSize = Number(values["target-bank-size"]);
  if (!Number.isInteger(targetBankSize) || targetBankSize <= 0) {
    console.error("--target-bank-size precisa ser um inteiro positivo.");
    process.exit(1);
  }

  const { canal, dados: dadosBrutos, pgSessionGuard } = await carregarDadosBrutosAutoDetectado();
  console.log(`Canal de leitura: ${canal}`);
  if (pgSessionGuard) console.log(`transaction_read_only: ${pgSessionGuard.transaction_read_only}`);

  const fontes = carregarFontes();
  console.log(`Fontes carregadas do manifesto local: ${fontes.length}`);

  let cursosAlvo;
  if (values["all-courses"]) {
    cursosAlvo = dadosBrutos.cursos;
  } else {
    const resolvido = resolverCurso(dadosBrutos, { cursoId: values["curso-id"], cursoSlug: values["curso-slug"] });
    if (!resolvido.ok) {
      console.error(`Curso nao resolvido: ${resolvido.motivo}`);
      process.exit(1);
    }
    cursosAlvo = [resolvido.curso];
  }

  const runId = gerarRunId();
  const manifestoBase = criarManifestoBase({
    runId,
    cursoId: values["all-courses"] ? null : cursosAlvo[0].id,
    targetBankSize,
  });

  const coberturaPorCurso = cursosAlvo.map((curso) => escanearCursoCompleto(dadosBrutos, { cursoId: curso.id, targetBankSize, fontes }));

  const dirRun = values.output ? values.output : prepararDiretorioRun(runId);
  const caminhoCoberturaJson = path.join(dirRun, "cobertura.json");
  const caminhoCoberturaMd = path.join(dirRun, "cobertura.md");
  const caminhoManifest = path.join(dirRun, "manifest.json");

  escreverArtefatoJson(caminhoCoberturaJson, {
    generated_at: new Date().toISOString(),
    schema_version: 1,
    target_bank_size: targetBankSize,
    courses: coberturaPorCurso,
  });
  escreverArtefatoTexto(caminhoCoberturaMd, gerarCoberturaMd(coberturaPorCurso));

  const manifesto = finalizarManifesto(manifestoBase, {
    status: "COVERAGE_READY",
    arquivosProduzidos: [caminhoCoberturaJson, caminhoCoberturaMd],
  });
  escreverArtefatoJson(caminhoManifest, manifesto);

  console.log(`Run: ${runId}`);
  console.log(`Artefatos escritos em: ${dirRun}`);
  for (const item of coberturaPorCurso) {
    if (item.status === STATUS_CURSO_SEM_ANDAIME) {
      console.log(`  ${item.curso.slug}: ${STATUS_CURSO_SEM_ANDAIME} (${item.motivo})`);
    } else {
      console.log(
        `  ${item.curso.slug}: ${item.unidades_relevantes} unidades, ${item.unidades_lt_target} deficitarias, deficit total ${item.deficit_total}`
      );
    }
  }
  console.log("db_writes: 0 · api_calls: 0");
}

main().catch((erro) => {
  console.error(erro.message);
  process.exit(1);
});
