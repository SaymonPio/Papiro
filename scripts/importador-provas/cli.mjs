#!/usr/bin/env node
// PoC do importador automático de provas — orquestrador dry-run.
//
// Uso:
//   node scripts/importador-provas/cli.mjs \
//     --prova caminho/prova.pdf \
//     --gabarito caminho/gabarito.pdf (ou .txt) \
//     --metadata caminho/metadata.json \
//     [--snapshot-questoes caminho/questoes.json] \
//     [--snapshot-taxonomia caminho/taxonomia.json] \
//     [--bloco-gabarito "<texto>"] \
//     [--estrategia-pdf linear|posicional|auto] \
//     [--out caminho/saida]
//
// --estrategia-pdf (default "linear"): "linear" preserva a ordem bruta
// do pdf-parse (correta para 1 coluna); "posicional" reconstrói a ordem
// de leitura via coordenadas X/Y dos itens de texto (necessário para
// PDFs de 2+ colunas); "auto" decide a partir da própria estrutura
// geométrica do documento, nunca por banca — só usa "posicional" quando
// a detecção de colunas é confiante (2+ colunas, confidence alta),
// senão usa "linear" (nunca adivinha).
//
// NUNCA escreve no banco. NUNCA faz INSERT/UPDATE/DELETE. Os snapshots
// (quando fornecidos) são lidos uma vez, em memória, só para comparação —
// mesmo padrão já usado em scripts/dedupe-lote1-vs-supabase.js.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { extrairTextoPdf } from "./lib/extrairTextoPdf.mjs";
import { extrairQuestoesDoTexto } from "./lib/extrairQuestoes.mjs";
import { extrairGabaritoDoTexto } from "./lib/extrairGabarito.mjs";
import { juntarQuestoesEGabarito } from "./lib/juncao.mjs";
import { classificarMateriaAssunto } from "./lib/classificar.mjs";
import { classificarDuplicidade } from "./lib/deduplicar.mjs";
import { normalizarQuestao } from "./lib/normalizar.mjs";
import { calcularStatus } from "./lib/score.mjs";
import { gerarRelatorio } from "./lib/relatorio.mjs";

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

function lerJsonSeExistir(caminho, padrao) {
  if (!caminho) return padrao;
  if (!fs.existsSync(caminho)) {
    console.warn(`Aviso: snapshot "${caminho}" não encontrado — seguindo sem ele (dedup/classificação ficam mais fracos).`);
    return padrao;
  }
  return JSON.parse(fs.readFileSync(caminho, "utf8"));
}

// Gabarito sempre usa a estratégia "linear", independente do que foi
// escolhido para a prova. Um gabarito é uma tabela/grade (lista linear,
// tabela de N colunas no mesmo registro, ou grade posicional número+
// resposta) — nunca prosa em colunas de leitura. A detecção de colunas
// geométrica pode identificar erroneamente uma tabela lado a lado (ex.:
// "N. Questão | Alternativa | N. Questão | Alternativa", visto num
// gabarito real da ACAFE) como "2 colunas de leitura" e reordenar cada
// metade da tabela separadamente — isso destrói o pareamento número<->
// letra DENTRO da mesma linha, que depende de os dois blocos
// permanecerem na mesma linha física. extrairGabarito.mjs já resolve os
// três formatos reais conhecidos (linear, tabular, grade posicional) a
// partir do texto entregue pela estratégia linear — nenhuma necessidade
// de reconstrução por coordenadas aqui.
async function extrairTextoDeGabarito(caminho) {
  const extensao = path.extname(caminho).toLowerCase();
  if (extensao === ".txt") return fs.readFileSync(caminho, "utf8");
  if (extensao === ".pdf") {
    const { paginas } = await extrairTextoPdf(caminho, { estrategia: "linear" });
    return paginas.map((p) => p.texto).join("\n");
  }
  throw new Error(`Extensão de gabarito não suportada: "${extensao}" (use .pdf ou .txt)`);
}

async function main() {
  const args = lerArgumentos(process.argv.slice(2));
  const provaPath = args.prova;
  const gabaritoPath = args.gabarito;
  const metadataPath = args.metadata;
  const diretorioDoScript = path.dirname(fileURLToPath(import.meta.url));
  const outDir = args.out ?? path.join(diretorioDoScript, "output");

  if (!provaPath || !gabaritoPath || !metadataPath || !fs.existsSync(provaPath) || !fs.existsSync(gabaritoPath) || !fs.existsSync(metadataPath)) {
    console.log("FORNEÇA O PDF OFICIAL DA PROVA E O GABARITO");
    console.log("");
    console.log("Uso: node scripts/importador-provas/cli.mjs --prova <prova.pdf> --gabarito <gabarito.pdf|.txt> --metadata <metadata.json>");
    console.log("Este importador não baixa nada por conta própria — os três arquivos (prova, gabarito, metadata.json) precisam ser fornecidos localmente.");
    process.exitCode = 1;
    return;
  }

  const metadata = JSON.parse(fs.readFileSync(metadataPath, "utf8"));
  const snapshotQuestoes = lerJsonSeExistir(args["snapshot-questoes"], []);
  const snapshotTaxonomia = lerJsonSeExistir(args["snapshot-taxonomia"], { materias: [], assuntos: [] });
  const estrategiaPdf = args["estrategia-pdf"] ?? "linear";
  if (!["linear", "posicional", "auto"].includes(estrategiaPdf)) {
    console.error(`--estrategia-pdf inválida: "${estrategiaPdf}" (use "linear", "posicional" ou "auto")`);
    process.exitCode = 1;
    return;
  }

  const { paginas, requerOcr, totalPaginas } = await extrairTextoPdf(provaPath, { estrategia: estrategiaPdf });

  if (requerOcr) {
    console.warn("ATENÇÃO: o PDF da prova parece ser escaneado (pouco ou nenhum texto extraível). requires_ocr=true — nenhuma tentativa de OCR foi feita nesta PoC.");
  }

  const { questoes, numerosIgnorados } = extrairQuestoesDoTexto(paginas);
  const textoGabarito = await extrairTextoDeGabarito(gabaritoPath);
  const { gabaritos: gabaritosBrutos, naoReconhecidas } = extrairGabaritoDoTexto(textoGabarito);

  // Um gabarito pode conter mais de um BLOCO (ex.: um cargo por bloco,
  // cada um com sua própria grade posicional 1..N — visto numa prova
  // real: FEPESE/PMBC 2014, gabarito único cobrindo "GM" e "AR"). Nunca
  // combina blocos diferentes silenciosamente: sem --bloco-gabarito e
  // com mais de um bloco distinto, para explicitamente em vez de
  // adivinhar qual bloco corresponde à prova sendo importada.
  const blocosDistintos = [...new Set(gabaritosBrutos.map((g) => g.bloco).filter(Boolean))];
  let gabaritos = gabaritosBrutos;
  if (args["bloco-gabarito"]) {
    const alvo = String(args["bloco-gabarito"]).toLowerCase();
    gabaritos = gabaritosBrutos.filter((g) => !g.bloco || g.bloco.toLowerCase().includes(alvo));
    if (gabaritos.length === 0) {
      console.error(`Nenhuma entrada de gabarito bate com --bloco-gabarito "${args["bloco-gabarito"]}". Blocos disponíveis: ${blocosDistintos.join(" | ") || "(nenhum bloco rotulado encontrado)"}`);
      process.exitCode = 1;
      return;
    }
  } else if (blocosDistintos.length > 1) {
    console.error(
      `O gabarito tem ${blocosDistintos.length} blocos distintos (${blocosDistintos.join(" | ")}) — ` +
        `informe --bloco-gabarito "<texto>" para escolher um. Nunca combinamos blocos diferentes automaticamente ` +
        `(números podem se repetir entre blocos de cargos diferentes, e misturá-los corromperia o pareamento).`,
    );
    process.exitCode = 1;
    return;
  }

  const { juntadas, bloqueios } = juntarQuestoesEGabarito(questoes, gabaritos);

  const questoesFinais = juntadas.map((juntada) => {
    const classificacao = classificarMateriaAssunto(juntada, snapshotTaxonomia, juntada.materia_detectada);
    const normalizada = normalizarQuestao(juntada, metadata, classificacao);
    if (requerOcr) normalizada._interno.requires_ocr = true;
    const dedup = classificarDuplicidade(normalizada, snapshotQuestoes);
    return calcularStatus(normalizada, dedup, bloqueios);
  });

  const questoesRevisao = questoesFinais.filter((q) => q.status === "REVISAO_MANUAL");
  const duplicadas = questoesFinais.filter((q) => q.dedup.status !== "nova");

  const relatorio = gerarRelatorio(questoesFinais, {
    prova: provaPath,
    gabarito: gabaritoPath,
    metadata: metadataPath,
    estrategia_pdf: estrategiaPdf,
    total_paginas: totalPaginas,
    requires_ocr: requerOcr,
    numeros_de_questao_ignorados: numerosIgnorados,
    linhas_de_gabarito_nao_reconhecidas: naoReconhecidas,
    bloqueios_globais: bloqueios,
  });

  fs.mkdirSync(outDir, { recursive: true });
  fs.writeFileSync(path.join(outDir, "questoes_extraidas.json"), JSON.stringify(questoesFinais, null, 2));
  fs.writeFileSync(path.join(outDir, "questoes_revisao.json"), JSON.stringify(questoesRevisao, null, 2));
  fs.writeFileSync(path.join(outDir, "duplicadas.json"), JSON.stringify(duplicadas, null, 2));
  fs.writeFileSync(path.join(outDir, "relatorio_importacao.json"), JSON.stringify(relatorio, null, 2));

  console.log("=== Relatório da PoC (dry-run — nada foi escrito no banco) ===");
  console.log(JSON.stringify(relatorio, null, 2));
  console.log(`\nArquivos gravados em: ${outDir}`);
}

main().catch((erro) => {
  console.error("Falha na PoC:", erro);
  process.exitCode = 1;
});
