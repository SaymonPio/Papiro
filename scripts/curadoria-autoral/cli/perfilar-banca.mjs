#!/usr/bin/env node
// CLI — perfil de estilo de banca evidence-based (Fase 2C.3). Zero
// chamada de IA/rede externa, zero escrita no banco. So leitura via canal
// PG_READ_ONLY (sessao travada e verificada antes de qualquer SELECT,
// mesmo mecanismo endurecido na Fase 2A.1). Multi-banca por desenho — o
// CLI recebe --bank/--materia-id/--subject como parametros, nunca
// hardcoded.
//
// Uso:
//   node scripts/curadoria-autoral/cli/perfilar-banca.mjs \
//     --bank Fundatec --materia-id 6 --subject "Língua Portuguesa" \
//     [--recent-year-window 6]

import { parseArgs } from "node:util";
import path from "node:path";
import fs from "node:fs";
import { carregarCorpusMateriaViaPg } from "../lib/bank-corpus-loader.mjs";
import { normalizarBanca, perfilarCorpus } from "../lib/bank-style-profiler.mjs";
import { carregarProvenienciaCurada, obterIdsComProvenienciaConfirmada } from "../lib/question-provenance-manifest.mjs";
import { RAIZ_SAIDA, escreverArtefatoJson, garantirDiretorio } from "../lib/artifact-writer.mjs";

const PADRAO_ESTRITO = "strict_official_confirmed_curated_evidence";

async function main() {
  const { values } = parseArgs({
    options: {
      bank: { type: "string" },
      "materia-id": { type: "string" },
      subject: { type: "string" },
      "recent-year-window": { type: "string", default: "6" },
    },
  });

  if (!values.bank || !values["materia-id"] || !values.subject) {
    console.error("Informe --bank, --materia-id e --subject.");
    process.exit(1);
  }
  const materiaId = Number(values["materia-id"]);
  if (!Number.isInteger(materiaId) || materiaId <= 0) {
    console.error("--materia-id precisa ser um inteiro positivo.");
    process.exit(1);
  }
  const recentYearWindow = Number(values["recent-year-window"]);
  if (!Number.isInteger(recentYearWindow) || recentYearWindow <= 0) {
    console.error("--recent-year-window precisa ser um inteiro positivo.");
    process.exit(1);
  }
  const anoAtual = new Date().getFullYear();

  const { canal, transactionReadOnly, questoes } = await carregarCorpusMateriaViaPg({ materiaId });
  console.log(`Canal de leitura: ${canal}`);
  console.log(`transaction_read_only: ${transactionReadOnly}`);
  console.log(`ano_atual_referencia: ${anoAtual} · recent_year_window: ${recentYearWindow}`);
  console.log(`total candidatos (materia_id=${materiaId}, ativas, qualquer banca): ${questoes.length}`);

  const bancaAlvoNormalizada = normalizarBanca(values.bank);

  // Fase 2C.3.2: unico caminho para REAL_OFFICIAL_CONFIRMED — manifesto
  // local curado por humano, nunca inferencia por regex sobre `fonte`.
  // Leitura de arquivo local, zero rede, zero DB write.
  const registrosProvenienciaCurada = carregarProvenienciaCurada();
  const idsComProvenienciaConfirmada = obterIdsComProvenienciaConfirmada(registrosProvenienciaCurada, bancaAlvoNormalizada);
  console.log(`registros de proveniencia curada (sources/question-provenance/*.json): ${registrosProvenienciaCurada.length}`);
  console.log(`ids confirmados por curadoria humana para "${values.bank}": ${idsComProvenienciaConfirmada.size}`);

  const { perfil, questoesClassificadas } = perfilarCorpus({
    bank: values.bank,
    subject: values.subject,
    bancaAlvoNormalizada,
    questoesRaw: questoes,
    recentYearWindow,
    anoAtual,
    idsComProvenienciaConfirmada,
  });

  const resumoProveniencia = questoesClassificadas.reduce((acc, q) => {
    acc[q.proveniencia] = (acc[q.proveniencia] ?? 0) + 1;
    return acc;
  }, {});

  console.log("--- PROVENIENCIA ---");
  console.log(JSON.stringify(resumoProveniencia));
  console.log("--- PERFIL (resumo) ---");
  console.log(JSON.stringify({ sample: perfil.sample, confidence: perfil.confidence, format_distribution: perfil.format_distribution, alternative_count_distribution: perfil.alternative_count_distribution }, null, 2));

  const dirPerfis = path.join(RAIZ_SAIDA, "bank-profiles");
  garantirDiretorio(dirPerfis);
  const nomeBase = `${values.bank.toLowerCase().trim().replace(/\s+/g, "-")}-${values.subject
    .toLowerCase()
    .trim()
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .replace(/\s+/g, "-")}`;

  // Fase 2C.3.1 Secao 12 / Fase 2C.3.2 Secao 8: NUNCA sobrescrever um
  // perfil existente. Detecta a maior versao ja escrita (vN); se seu
  // provenance_standard for diferente do padrao ATUAL (a regra mudou —
  // seja a introducao do padrao estrito na 2C.3.1, seja o fechamento da
  // brecha de regex-como-prova na 2C.3.2), marca essa versao anterior
  // como superseded IN PLACE (nunca apagada) e escreve v(N+1), que passa
  // a ser o canonico. Generico: funciona para qualquer numero de rodadas
  // futuras, sem nomes de arquivo hardcoded.
  const versoesExistentes = fs.existsSync(dirPerfis)
    ? fs
        .readdirSync(dirPerfis)
        .map((f) => f.match(new RegExp(`^${nomeBase.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}-v(\\d+)\\.json$`)))
        .filter(Boolean)
        .map((m) => Number(m[1]))
    : [];
  const maiorVersaoExistente = versoesExistentes.length > 0 ? Math.max(...versoesExistentes) : 0;
  const novaVersao = maiorVersaoExistente + 1;
  const caminhoAnterior = maiorVersaoExistente > 0 ? path.join(dirPerfis, `${nomeBase}-v${maiorVersaoExistente}.json`) : null;
  const caminhoNovo = path.join(dirPerfis, `${nomeBase}-v${novaVersao}.json`);

  if (caminhoAnterior && fs.existsSync(caminhoAnterior)) {
    const perfilAnterior = JSON.parse(fs.readFileSync(caminhoAnterior, "utf8"));
    if (perfilAnterior.provenance_standard !== PADRAO_ESTRITO && perfilAnterior.status !== "PROFILE_PROVENANCE_SUPERSEDED" && perfilAnterior.status !== "PROFILE_PROVENANCE_NOT_STRICT") {
      escreverArtefatoJson(caminhoAnterior, { ...perfilAnterior, status: "PROFILE_PROVENANCE_SUPERSEDED", superseded_by: `${nomeBase}-v${novaVersao}.json`, superseded_at: new Date().toISOString() });
      console.log(`Perfil anterior (padrao de proveniencia desatualizado) marcado PROFILE_PROVENANCE_SUPERSEDED e preservado em: ${caminhoAnterior}`);
    }
  }

  escreverArtefatoJson(caminhoNovo, perfil);

  console.log(`Perfil (padrao estrito) escrito em: ${caminhoNovo}`);
  console.log("db_writes: 0 · api_calls: 0 · rede_externa: 0");
}

main().catch((erro) => {
  console.error(erro.message);
  process.exit(1);
});
