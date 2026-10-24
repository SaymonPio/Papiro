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
//     (ou, no lugar de --gabarito/--bloco-gabarito: --gabaritos manifesto.json
//      com o gabarito base + retificações em ordem explícita — lib/gabaritos.mjs) \
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
import { extrairGabaritoDoTexto, extrairMencoesDeAlteracao } from "./lib/extrairGabarito.mjs";
import { lerManifestoDeGabaritos, selecionarBloco } from "./lib/gabaritos.mjs";
import { aplicarRetificacoes } from "./lib/retificacoes.mjs";
import { juntarQuestoesEGabarito } from "./lib/juncao.mjs";
import { compararQuestoes, fragmentosDeMargem, problemasDeIntegridade } from "./lib/integridade.mjs";
import { sha256DoTexto, textoDeGabaritoHtml } from "./lib/gabaritoHtml.mjs";
import { classificarMateriaAssunto } from "./lib/classificar.mjs";
import { classificarDuplicidade } from "./lib/deduplicar.mjs";
import { normalizarQuestao } from "./lib/normalizar.mjs";
import { calcularStatus } from "./lib/score.mjs";
import { anexarMidias, lerPaginasVisuais, resolverMidias } from "./lib/midias.mjs";
import { calcularHashArquivo, montarProveniencia } from "./lib/proveniencia.mjs";
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
// Documentos de gabarito publicados como página HTML: o hash registrado é
// o do HTML (documento oficial); o texto derivado (lib/gabaritoHtml.mjs)
// fica anotado à parte no relatório, nunca no lugar do original.
const textosDerivadosDeHtml = [];

async function extrairTextoDeGabarito(caminho) {
  const extensao = path.extname(caminho).toLowerCase();
  if (extensao === ".txt") return fs.readFileSync(caminho, "utf8");
  if (extensao === ".html" || extensao === ".htm") {
    const texto = textoDeGabaritoHtml(fs.readFileSync(caminho));
    textosDerivadosDeHtml.push({ arquivo: path.basename(caminho), sha256_html_oficial: calcularHashArquivo(caminho), sha256_texto_derivado: sha256DoTexto(texto), conversao: "lib/gabaritoHtml.mjs (determinística)" });
    return texto;
  }
  if (extensao === ".pdf") {
    const { paginas } = await extrairTextoPdf(caminho, { estrategia: "linear" });
    return paginas.map((p) => p.texto).join("\n");
  }
  throw new Error(`Extensão de gabarito não suportada: "${extensao}" (use .pdf, .html ou .txt)`);
}

async function main() {
  const args = lerArgumentos(process.argv.slice(2));
  const provaPath = args.prova;
  const metadataPath = args.metadata;

  // --gabaritos <manifesto.json>: gabarito base + retificações ordenadas
  // (ver lib/gabaritos.mjs). --gabarito/--bloco-gabarito continuam
  // valendo para o caso de um documento só.
  if (args.gabaritos && args.gabarito) {
    console.error("use --gabarito OU --gabaritos, nunca os dois");
    process.exitCode = 1;
    return;
  }
  let manifestoGabaritos = null;
  if (args.gabaritos) {
    try {
      manifestoGabaritos = lerManifestoDeGabaritos(args.gabaritos);
    } catch (erro) {
      console.error(erro.message);
      process.exitCode = 1;
      return;
    }
  }
  const gabaritoPath = manifestoGabaritos?.base.arquivo ?? args.gabarito;
  const blocoBase = manifestoGabaritos ? manifestoGabaritos.base.bloco ?? args["bloco-gabarito"] ?? null : args["bloco-gabarito"] ?? null;
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

  const { paginas: todasAsPaginas, requerOcr, totalPaginas, estrategiaEscolhida, leituraAlternativa } = await extrairTextoPdf(provaPath, { estrategia: estrategiaPdf });

  if (requerOcr) {
    console.warn("ATENÇÃO: o PDF da prova parece ser escaneado (pouco ou nenhum texto extraível). requires_ocr=true — nenhuma tentativa de OCR foi feita nesta PoC.");
  }

  // Parte de uma prova cujo PDF oficial junta vários cadernos (metadata.parte
  // = { codigo, nome, ordem, paginas: [inicio, fim] }): só as páginas da
  // parte declarada são lidas; o hash continua sendo o do PDF oficial
  // inteiro, e numero_original continua sendo o número impresso.
  const intervalo = metadata.parte?.paginas;
  if (metadata.parte && !(Array.isArray(intervalo) && intervalo.length === 2 && intervalo.every(Number.isInteger) && intervalo[0] >= 1 && intervalo[0] <= intervalo[1] && intervalo[1] <= totalPaginas)) {
    console.error(`metadata.parte.paginas inválido (${JSON.stringify(intervalo)}): use [início, fim] dentro de 1..${totalPaginas}`);
    process.exitCode = 1;
    return;
  }
  const paginas = intervalo ? todasAsPaginas.filter((p) => p.numero >= intervalo[0] && p.numero <= intervalo[1]) : todasAsPaginas;

  const { questoes, numerosIgnorados, avisos: avisosExtracao, bloqueio: bloqueioExtracao } = extrairQuestoesDoTexto(paginas, { composicao: metadata.composicao });
  if (bloqueioExtracao) {
    console.error(`BLOQUEADO: ${bloqueioExtracao}`);
    process.exitCode = 1;
    return;
  }

  // Integridade (lib/integridade.mjs): a outra leitura do mesmo PDF só serve
  // de referência quando recupera exatamente as mesmas questões — uma
  // leitura linear que perde a sequência (ordem do stream quebrada) não é
  // referência de nada. Sem referência, valem só as checagens de conteúdo.
  const integridade = { estrategia_escolhida: estrategiaEscolhida ?? estrategiaPdf, leitura_alternativa: leituraAlternativa?.estrategia ?? null, cruzamento_aplicado: false, motivo: null };
  let comparacoes = null;
  if (leituraAlternativa) {
    const paginasAlternativas = intervalo ? leituraAlternativa.paginas.filter((p) => p.numero >= intervalo[0] && p.numero <= intervalo[1]) : leituraAlternativa.paginas;
    const alternativas = extrairQuestoesDoTexto(paginasAlternativas, { composicao: metadata.composicao }).questoes;
    const mesmas = alternativas.length === questoes.length && alternativas.every((q, i) => q.numero_original === questoes[i].numero_original);
    if (mesmas) {
      comparacoes = compararQuestoes(questoes, alternativas);
      integridade.cruzamento_aplicado = true;
    } else {
      integridade.motivo = `leitura ${leituraAlternativa.estrategia} recupera ${alternativas.length} questão(ões) contra ${questoes.length} — não serve de referência`;
    }
  } else {
    integridade.motivo = "só há uma leitura confiável deste documento (multicoluna) — valem as checagens de conteúdo";
  }
  const margem = fragmentosDeMargem(paginas);
  for (const questao of questoes) {
    questao.problemas_integridade = problemasDeIntegridade(questao, { comparacao: comparacoes?.get(questao.numero_original) ?? null, margem });
  }
  integridade.reordenadas = comparacoes ? [...comparacoes].filter(([, c]) => c.tipo === "reordenada").map(([n]) => n) : [];
  integridade.questoes_com_problema = questoes.filter((q) => q.problemas_integridade.length > 0).map((q) => ({ numero: q.numero_original, problemas: q.problemas_integridade.map((p) => p.codigo) }));
  const textoGabarito = await extrairTextoDeGabarito(gabaritoPath);
  const { gabaritos: gabaritosBrutos, naoReconhecidas } = extrairGabaritoDoTexto(textoGabarito);

  // Um gabarito pode conter mais de um BLOCO (ex.: um cargo por bloco,
  // cada um com sua própria grade posicional 1..N — visto numa prova
  // real: FEPESE/PMBC 2014, gabarito único cobrindo "GM" e "AR"). Nunca
  // combina blocos diferentes silenciosamente: sem bloco escolhido e com
  // mais de um bloco distinto, para explicitamente em vez de adivinhar
  // qual bloco corresponde à prova sendo importada. Com bloco escolhido,
  // só entradas DO bloco: um par fora de qualquer bloco rotulado não tem
  // dono conhecido (num gabarito real de vários cargos — Fundatec/PP-RS
  // 2026 — eram pares acidentais da prosa das justificativas, ex. "2015)
  // e") e misturá-lo ao bloco seria combinar documentos silenciosamente.
  let gabaritosBase;
  const retificacoesLidas = [];
  try {
    gabaritosBase = selecionarBloco(gabaritosBrutos, blocoBase, "o gabarito");
    for (const retificacao of manifestoGabaritos?.retificacoes ?? []) {
      const texto = await extrairTextoDeGabarito(retificacao.arquivo);
      const { gabaritos: entradas } = extrairGabaritoDoTexto(texto, { estrito: true });
      retificacoesLidas.push({
        ...retificacao,
        hash: calcularHashArquivo(retificacao.arquivo),
        gabaritos: selecionarBloco(entradas, retificacao.bloco, `a retificação "${retificacao.documento}"`),
        mencoes: extrairMencoesDeAlteracao(texto),
      });
    }
  } catch (erro) {
    console.error(erro.message);
    process.exitCode = 1;
    return;
  }

  // Gabarito final = base -> retificação 1 -> retificação 2 -> ...
  const { gabaritos, problemas: problemasRetificacao, avisos: avisosRetificacao } = aplicarRetificacoes(gabaritosBase, retificacoesLidas);

  const { juntadas, bloqueios } = juntarQuestoesEGabarito(questoes, gabaritos);

  // Hash dos arquivos efetivamente lidos aqui — nunca do manifest.
  const proveniencia = montarProveniencia(metadata, {
    hashProva: calcularHashArquivo(provaPath),
    hashGabarito: calcularHashArquivo(gabaritoPath),
    retificacoes: retificacoesLidas.map((r) => ({ ordem: r.ordem, documento: r.documento, url: r.url, hash: r.hash })),
    gabaritoTipo: manifestoGabaritos?.base.tipo ?? "definitivo",
    parte: metadata.parte ? { codigo: metadata.parte.codigo, nome: metadata.parte.nome, ordem: metadata.parte.ordem } : null,
  });
  if (!proveniencia.completa) {
    console.warn(
      `ATENÇÃO: proveniência incompleta (faltando: ${proveniencia.faltando.join(", ") || "-"}; inválidos: ${proveniencia.invalidos.join(", ") || "-"}) — nenhuma questão ficará PRONTA_PARA_REVISAO.`,
    );
  }

  const normalizadas = juntadas.map((juntada) => {
    const classificacao = classificarMateriaAssunto(juntada, snapshotTaxonomia, juntada.materia_detectada);
    const normalizada = normalizarQuestao(juntada, metadata, classificacao);
    if (requerOcr) normalizada._interno.requires_ocr = true;
    return normalizada;
  });

  // Mídias (figuras/charges): objetos de imagem do PDF associados às
  // questões pela geometria; PNG em <out>/midias/<sha256>.png. Falha de
  // leitura visual nunca derruba o lote — quem cita peça visual fica sem
  // mídia (MIDIA_OK=false) e o aviso vai para o relatório.
  let paginasVisuais = [];
  const avisosMidia = [];
  try {
    paginasVisuais = await lerPaginasVisuais(provaPath);
  } catch (erro) {
    avisosMidia.push(`leitura visual do PDF falhou: ${erro.message}`);
  }
  const midias = resolverMidias({ paginas: paginasVisuais, questoes: normalizadas });
  for (const normalizada of normalizadas) anexarMidias(normalizada, midias.porQuestao.get(normalizada.numero_original));

  const questoesFinais = normalizadas.map((normalizada) => {
    const dedup = classificarDuplicidade(normalizada, snapshotQuestoes);
    return calcularStatus(normalizada, dedup, bloqueios, proveniencia);
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
    avisos_extracao: avisosExtracao,
    integridade_extracao: integridade,
    linhas_de_gabarito_nao_reconhecidas: naoReconhecidas,
    ...(textosDerivadosDeHtml.length > 0 ? { gabarito_textos_derivados_de_html: textosDerivadosDeHtml } : {}),
    gabarito_numeros_deduzidos: gabaritos.filter((g) => g.numero_deduzido).map((g) => ({ bloco: g.bloco, ...g.numero_deduzido, resposta: g.anulada ? "ANULADA" : g.alternativa_correta })),
    ...(metadata.parte ? { parte: metadata.parte } : {}),
    retificacoes_gabarito: {
      documentos: retificacoesLidas.map((r) => ({ ordem: r.ordem, documento: r.documento, url: r.url, hash: r.hash, entradas: r.gabaritos.length, mencoes: r.mencoes })),
      problemas: problemasRetificacao,
      avisos: avisosRetificacao,
      questoes_alteradas: gabaritos.filter((g) => g.historico?.alteracoes.length > 0).map((g) => ({ numero: g.numero, ...g.historico })),
    },
    bloqueios_globais: bloqueios,
    proveniencia,
    midias: {
      arquivos: [...midias.arquivos.keys()].map((sha) => `midias/${sha}.png`),
      questoes: [...midias.porQuestao].map(([numero, r]) => ({ numero, status: r.status, causas: r.causas.map((c) => c.codigo), midias: r.midias.map((m) => m.sha256) })),
      ignoradas: midias.ignoradas,
      avisos: avisosMidia,
    },
  });

  fs.mkdirSync(outDir, { recursive: true });
  if (midias.arquivos.size > 0) {
    fs.mkdirSync(path.join(outDir, "midias"), { recursive: true });
    for (const [sha, png] of midias.arquivos) fs.writeFileSync(path.join(outDir, "midias", `${sha}.png`), png);
  }
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
