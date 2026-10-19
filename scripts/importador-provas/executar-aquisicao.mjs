#!/usr/bin/env node
// Executor controlado de aquisição — grava no banco um staging JÁ
// APROVADO do importador (saída de cli.mjs), com proveniência, numa única
// transação. NUNCA grava por padrão.
//
// Uso:
//   1) dry-run (padrão — transação READ ONLY, nada é escrito):
//      node scripts/importador-provas/executar-aquisicao.mjs \
//        --staging <dir com questoes_extraidas.json + relatorio_importacao.json> \
//        --prova <prova.pdf> --gabarito <gabarito.pdf|.txt> (ou --gabaritos <manifesto.json>) \
//        --modo BASE_GLOBAL | BASE_GLOBAL_COM_VINCULO \
//        [--curso <slug> --vincular-materias "<id|nome>,<id|nome>"] \
//        [--aprovacao aprovacao.json] [--out <dir>]
//      -> grava <out>/manifesto.json (com o hash) e <out>/relatorio_aquisicao.json
//
//   2) apply (grava de verdade — mesmos argumentos + o manifesto aprovado):
//      ... --apply --manifesto <out>/manifesto.json
//
//   3) teste-rollback (caminho de escrita real, termina SEMPRE em ROLLBACK):
//      ... --teste-rollback --manifesto <out>/manifesto.json
//
// aprovacao.json (opcional; é o único lugar onde vínculo e classificação
// manual são aprovados):
//   {
//     "vinculos": [{ "curso": "brigada-militar-rs", "materias": [6, "Informática"] }],
//     "classificacao": { "21": { "materia_id": 12, "assunto_id": 345 } },
//     "liberacoes": [{ "numero_original": 10, "gate": "EXTRACAO_OK",
//                      "motivo": "dependencia_texto_incerta", "justificativa": "<revisão humana>" }]
//   }
// liberacoes: libera UMA causa conservadora de um gate do staging para UMA
// questão, depois de revisão humana (ver CAUSAS_LIBERAVEIS em planejar.mjs).
// Matéria sem estrutura no curso nunca vira vínculo; nada é criado em
// curso_materias/curso_conteudos/materias/editais.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { carregarEnvCuradoria } from "../curadoria-pedagogica/lib/comum.mjs";
import { calcularHashArquivo } from "./lib/proveniencia.mjs";
import { lerManifestoDeGabaritos } from "./lib/gabaritos.mjs";
import { hashManifesto } from "./lib/aquisicao/planejar.mjs";
import { ErroAquisicao, executarAquisicao, montarRelatorioAquisicao } from "./lib/aquisicao/executor.mjs";
import { criarRepositorioPg } from "./lib/aquisicao/repositorioPg.mjs";

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

function lerJson(caminho, descricao) {
  if (!caminho || !fs.existsSync(caminho)) throw new ErroAquisicao(`${descricao} não encontrado: ${caminho ?? "(não informado)"}`);
  return JSON.parse(fs.readFileSync(caminho, "utf8"));
}

function montarEntrada(args) {
  const questoes = lerJson(path.join(args.staging, "questoes_extraidas.json"), "questoes_extraidas.json do staging");
  const relatorio = lerJson(path.join(args.staging, "relatorio_importacao.json"), "relatorio_importacao.json do staging");
  const proveniencia = relatorio.documento?.proveniencia ?? null;

  // A proveniência do relatório é conferida contra os arquivos reais:
  // se o PDF/gabarito informado agora não é o que foi extraído, PARAR.
  // --gabaritos: o mesmo manifesto (base + retificações) usado no staging;
  // cada retificação é conferida por hash E ordem contra a proveniência.
  if (args.gabaritos && args.gabarito) throw new ErroAquisicao("use --gabarito OU --gabaritos, nunca os dois");
  let manifestoGabaritos = null;
  if (args.gabaritos) {
    try {
      manifestoGabaritos = lerManifestoDeGabaritos(args.gabaritos);
    } catch (erro) {
      throw new ErroAquisicao(erro.message);
    }
  }
  const gabaritoPath = manifestoGabaritos?.base.arquivo ?? args.gabarito;
  if (!args.prova || !gabaritoPath || !fs.existsSync(args.prova) || !fs.existsSync(gabaritoPath)) {
    throw new ErroAquisicao("informe --prova e --gabarito/--gabaritos (os mesmos arquivos usados no staging) — o hash é conferido de novo aqui");
  }
  const hashProva = calcularHashArquivo(args.prova);
  const hashGabarito = calcularHashArquivo(gabaritoPath);
  const divergentes = [];
  if (proveniencia?.prova?.hash_prova !== hashProva) divergentes.push("prova");
  if (proveniencia?.prova?.hash_gabarito !== hashGabarito) divergentes.push("gabarito");
  const esperadas = (proveniencia?.retificacoes ?? []).map((r) => `${r.ordem}:${r.hash}`).sort().join(",");
  const informadas = (manifestoGabaritos?.retificacoes ?? []).map((r) => `${r.ordem}:${calcularHashArquivo(r.arquivo)}`).sort().join(",");
  if (esperadas !== informadas) divergentes.push("retificações de gabarito");

  const aprovacao = args.aprovacao ? lerJson(args.aprovacao, "arquivo de aprovação") : {};
  if (args.curso || args["vincular-materias"]) {
    if (!args.curso || typeof args["vincular-materias"] !== "string") throw new ErroAquisicao("--curso e --vincular-materias precisam vir juntos");
    aprovacao.vinculos = [
      ...(aprovacao.vinculos ?? []),
      { curso: args.curso, materias: args["vincular-materias"].split(",").map((m) => m.trim()).filter(Boolean) },
    ];
  }

  return {
    modo: args.modo,
    proveniencia,
    questoes,
    aprovacao,
    hashesDivergentes: divergentes.length > 0 ? `hash de ${divergentes.join(" e ")} diverge do staging — os arquivos informados não são os extraídos` : null,
  };
}

function imprimirResumo(manifesto, hash, cabecalho) {
  const r = manifesto.resumo;
  console.log(`=== ${cabecalho} ===`);
  console.log(`Prova: ${manifesto.prova.nome ?? "(sem nome)"} [${manifesto.prova.situacao}${manifesto.prova.prova_id_existente ? ` id=${manifesto.prova.prova_id_existente}` : ""}]`);
  console.log(`  hash_prova: ${manifesto.prova.hash_prova ?? "-"}`);
  console.log(`Modo de aquisição: ${manifesto.modo}`);
  console.log(`Total extraído: ${r.total_extraido} | importar: ${r.importar} | revisar: ${r.revisar} | ignorar: ${r.ignorar}`);
  console.log(`Duplicadas exatas: ${r.duplicadas_exatas} | prováveis duplicadas: ${r.provaveis_duplicadas} | já importadas: ${r.ja_importadas} | anuladas: ${r.anuladas}`);
  for (const ret of manifesto.retificacoes_gabarito ?? []) console.log(`Retificação de gabarito aplicada (ordem ${ret.ordem}): ${ret.documento ?? "-"} [${ret.hash}]`);
  for (const doc of manifesto.documentos ?? []) console.log(`Documento ${doc.tipo} ordem ${doc.ordem}: ${doc.hash_sha256} [${doc.situacao}]`);
  console.log(`Ficariam somente globais: ${r.somente_globais}`);
  for (const q of manifesto.questoes.filter((x) => x.liberacoes_aplicadas)) {
    for (const l of q.liberacoes_aplicadas) console.log(`Liberação explícita nº ${q.numero_original}: ${l.gate}/${l.motivo} — ${l.justificativa}`);
  }
  for (const v of manifesto.vinculos) {
    console.log(`Vínculos com ${v.curso_slug}: ${r.vinculos_por_curso[v.curso_slug]} (matérias aprovadas: ${v.materia_ids_aprovadas.join(", ") || "nenhuma"})`);
    for (const rej of v.materias_rejeitadas) console.log(`  REJEITADA "${rej.valor}": ${rej.motivo}`);
  }
  for (const b of manifesto.bloqueios) console.log(`BLOQUEIO: ${b}`);
  for (const q of manifesto.questoes.filter((x) => x.acao !== "IMPORTAR")) console.log(`  nº ${q.numero_original} -> ${q.acao}: ${q.motivos.join("; ")}`);
  console.log(`Hash do manifesto: ${hash}`);
}

async function main() {
  const args = lerArgumentos(process.argv.slice(2));
  const modoExecucao = args.apply ? "apply" : args["teste-rollback"] ? "teste-rollback" : "dry-run";
  if (args.apply && args["teste-rollback"]) throw new ErroAquisicao("use --apply OU --teste-rollback, nunca os dois");
  if (!args.staging) throw new ErroAquisicao("informe --staging <dir> (saída do cli.mjs)");

  const entrada = montarEntrada(args);

  let hashAprovado = null;
  if (modoExecucao !== "dry-run") {
    const aprovado = lerJson(args.manifesto, "--manifesto (gerado pelo dry-run)");
    if (hashManifesto(aprovado.manifesto) !== aprovado.hash) throw new ErroAquisicao("manifesto.json corrompido ou editado — o hash gravado não confere com o conteúdo");
    hashAprovado = aprovado.hash;
  }

  carregarEnvCuradoria();
  const connectionString = process.env.SUPABASE_DB_URL || process.env.DATABASE_URL;
  if (!connectionString) throw new ErroAquisicao("defina SUPABASE_DB_URL em scripts/curadoria-pedagogica/.env.curadoria");
  const { default: pg } = await import("pg");
  const client = new pg.Client({ connectionString });
  await client.connect();

  try {
    const resultado = await executarAquisicao({ repo: criarRepositorioPg(client), entrada, modo: modoExecucao, hashManifestoAprovado: hashAprovado });
    const diretorioDoScript = path.dirname(fileURLToPath(import.meta.url));
    const outDir = args.out ?? path.join(diretorioDoScript, "output", "aquisicao", (resultado.manifesto.prova.hash_prova ?? "sem-hash").slice(0, 12));
    fs.mkdirSync(outDir, { recursive: true });

    const relatorio = montarRelatorioAquisicao(resultado);
    if (modoExecucao === "dry-run") {
      fs.writeFileSync(path.join(outDir, "manifesto.json"), JSON.stringify({ hash: resultado.hash, manifesto: resultado.manifesto }, null, 2));
      fs.writeFileSync(path.join(outDir, "relatorio_aquisicao.json"), JSON.stringify(relatorio, null, 2));
      imprimirResumo(resultado.manifesto, resultado.hash, "DRY-RUN — nada foi escrito no banco");
      console.log(`\nManifesto: ${path.join(outDir, "manifesto.json")}`);
      console.log("Para gravar: repita os mesmos argumentos com --apply --manifesto <manifesto.json>.");
    } else {
      fs.writeFileSync(path.join(outDir, `relatorio_${modoExecucao}.json`), JSON.stringify(relatorio, null, 2));
      imprimirResumo(resultado.manifesto, resultado.hash, modoExecucao === "apply" ? "APPLY — COMMIT realizado" : "TESTE-ROLLBACK — pós-check OK, ROLLBACK realizado");
      console.log(`Prova id: ${resultado.prova_id} (${resultado.prova_reutilizada ? "reutilizada" : "nova"}) | inseridas: ${resultado.inseridas.length}`);
      console.log(`Relatório: ${path.join(outDir, `relatorio_${modoExecucao}.json`)}`);
    }
  } finally {
    await client.end();
  }
}

main().catch((erro) => {
  console.error(`BLOQUEADO: ${erro.message}`);
  if (erro.detalhes && Object.keys(erro.detalhes).length > 0) console.error(JSON.stringify(erro.detalhes, null, 2));
  process.exitCode = 1;
});
