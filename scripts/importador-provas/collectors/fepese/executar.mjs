#!/usr/bin/env node
// Orquestração ponta a ponta do coletor FEPESE: descoberta (índice local)
// -> listagem -> pareamento -> download -> staging -> (opcional) chamada
// ao importador JÁ EXISTENTE (cli.mjs), sem duplicar nenhuma lógica de
// parsing de PDF aqui.
//
// Uso:
//   node scripts/importador-provas/collectors/fepese/executar.mjs \
//     --slug guardabc [--cargo "Guarda Municipal"] [--dry-run-importador]
//
// Sem --slug, usa o primeiro concurso do índice que bater nos critérios
// padrão de buscarConcursos(). Sem --cargo, prefere o par de confidence
// "alta"; narra claramente quando a confidence não é "alta" (não aborta
// por si só — staging continua disponível para inspeção manual, só o
// dry-run do importador deveria, na prática, esperar por confirmação
// humana antes de uma importação real).

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { execFileSync } from "node:child_process";
import * as fepese from "./index.mjs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const RAIZ_IMPORTADOR = path.resolve(__dirname, "..", "..");

function lerArgumentos(argv) {
  const args = {};
  for (let i = 0; i < argv.length; i++) {
    if (argv[i].startsWith("--")) {
      const chave = argv[i].slice(2);
      const valor = argv[i + 1] && !argv[i + 1].startsWith("--") ? argv[i + 1] : true;
      args[chave] = valor;
      if (valor !== true) i++;
    }
  }
  return args;
}

function slugificar(texto) {
  return texto
    .toLowerCase()
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/(^-|-$)/g, "");
}

async function main() {
  const args = lerArgumentos(process.argv.slice(2));

  const concursos = fepese.buscarConcursos({});
  const concurso = args.slug ? concursos.find((c) => c.slug === args.slug) : concursos[0];
  if (!concurso) {
    console.error(`Nenhum concurso encontrado no índice${args.slug ? ` com slug "${args.slug}"` : ""}.`);
    process.exitCode = 1;
    return;
  }
  console.log(`Concurso selecionado: ${concurso.titulo}`);
  console.log(`URL: ${concurso.url}`);
  console.log(`Descoberto via: ${concurso.descobertoVia} (verificado=${concurso.verificado})`);

  const pares = await fepese.obterDocumentos(concurso);
  console.log(`\nDocumentos pareados (${pares.length}):`);
  for (const par of pares) {
    console.log(`  - "${par.prova.cargo ?? par.prova.rotulo}" <-> ${par.gabarito ? `"${par.gabarito.rotulo}"` : "(sem gabarito pareado)"} [confidence: ${par.confidence}]`);
    console.log(`    motivo: ${par.motivo}`);
  }

  const parEscolhido = args.cargo
    ? pares.find((p) => (p.prova.cargo ?? "").toLowerCase().includes(String(args.cargo).toLowerCase()))
    : (pares.find((p) => p.confidence === "alta") ?? pares[0]);

  if (!parEscolhido) {
    console.error("\nNenhum par prova/gabarito disponível para staging.");
    process.exitCode = 1;
    return;
  }
  if (!parEscolhido.gabarito) {
    console.error(`\nPar escolhido ("${parEscolhido.prova.cargo ?? parEscolhido.prova.rotulo}") não tem gabarito pareado — abortando staging.`);
    process.exitCode = 1;
    return;
  }
  if (parEscolhido.confidence !== "alta") {
    console.warn(
      `\nAVISO: confidence de pareamento = "${parEscolhido.confidence}" (não "alta"). ` +
        `Por regra do produto, só confidence "alta" pode seguir automaticamente para importação real. ` +
        `Prosseguindo só para staging/inspeção — qualquer dry-run a partir daqui exige revisão humana antes de confirmar.`,
    );
  }

  const slugProva = slugificar(parEscolhido.prova.cargo ?? parEscolhido.prova.arquivo);
  const dirStaging = path.join(RAIZ_IMPORTADOR, "staging", "fepese", `${concurso.slug}-${slugProva}`);

  const provaDestino = path.join(dirStaging, "prova.pdf");
  const gabaritoDestino = path.join(dirStaging, "gabarito.pdf");

  const resultadoProva = await fepese.baixarProva(parEscolhido, provaDestino);
  const resultadoGabarito = await fepese.baixarGabarito(parEscolhido, gabaritoDestino);

  const { metadata, confidence: confidenceMetadata, camposFaltando } = fepese.montarMetadata(parEscolhido);
  fs.writeFileSync(path.join(dirStaging, "metadata.json"), JSON.stringify(metadata, null, 2));

  const confiancaDescoberta = concurso.verificado ? "media" : "baixa"; // índice pré-descoberto, nunca "alta" nesta fase (nunca crawler automático confirmado)

  const manifest = {
    coletor: "fepese",
    versaoColetor: "0.1.0-poc",
    geradoEm: new Date().toISOString(),
    concurso: { slug: concurso.slug, url: concurso.url, descobertoVia: concurso.descobertoVia },
    prova: { url: parEscolhido.prova.url, arquivo: parEscolhido.prova.arquivo, ...resultadoProva },
    gabarito: { url: parEscolhido.gabarito.url, arquivo: parEscolhido.gabarito.arquivo, ...resultadoGabarito },
    confiancaDescoberta,
    confiancaPareamento: parEscolhido.confidence,
    confiancaMetadata: confidenceMetadata,
    camposMetadataFaltando: camposFaltando,
    motivoPareamento: parEscolhido.motivo,
  };
  fs.writeFileSync(path.join(dirStaging, "manifest.json"), JSON.stringify(manifest, null, 2));

  console.log(`\nStaging completo em: ${dirStaging}`);
  console.log(JSON.stringify(manifest, null, 2));

  if (args["dry-run-importador"]) {
    console.log("\n=== Chamando o importador já existente (cli.mjs) — nenhuma lógica de PDF duplicada aqui ===");
    execFileSync(
      process.execPath,
      [
        path.join(RAIZ_IMPORTADOR, "cli.mjs"),
        "--prova", provaDestino,
        "--gabarito", gabaritoDestino,
        "--metadata", path.join(dirStaging, "metadata.json"),
        "--out", path.join(dirStaging, "output"),
      ],
      { stdio: "inherit" },
    );
  }
}

main().catch((erro) => {
  console.error("Falha no coletor FEPESE:", erro.message);
  process.exitCode = 1;
});
