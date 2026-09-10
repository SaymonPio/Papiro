#!/usr/bin/env node
// CLI — perfil de DOMINIO POLICIAL multibanca (Fase 2C.4). Zero chamada
// de IA/rede externa, zero escrita no banco. So leitura via canal
// PG_READ_ONLY (mesma trava endurecida da Fase 2A.1, reaproveitada via
// bank-corpus-loader.mjs — nunca reimplementada). Nunca hardcoda banca:
// o corpus pode conter qualquer banca real presente no materia_id
// consultado.
//
// Uso:
//   node scripts/curadoria-autoral/cli/perfilar-dominio-policial.mjs \
//     --subject "Língua Portuguesa" --materia-id 6 \
//     [--recent-year-window 6] [--assunto-nome "Concordância verbal"]

import { parseArgs } from "node:util";
import path from "node:path";
import { carregarCorpusMateriaViaPg } from "../lib/bank-corpus-loader.mjs";
import { construirPerfilDominioPolicial } from "../lib/police-domain-profiler.mjs";
import { carregarProvenienciaCurada, obterProvenienciaConfirmadaTodasBancas } from "../lib/question-provenance-manifest.mjs";
import { RAIZ_SAIDA, escreverArtefatoJson, garantirDiretorio } from "../lib/artifact-writer.mjs";
import { carregarEnvCuradoria } from "../../curadoria-pedagogica/lib/comum.mjs";

async function resolverAssuntoIdPorNome(nomeAssunto, materiaId) {
  if (!nomeAssunto) return null;
  carregarEnvCuradoria();
  const connectionString = process.env.SUPABASE_DB_URL || process.env.DATABASE_URL;
  if (!connectionString) throw new Error("Nem SUPABASE_URL/SUPABASE_SERVICE_ROLE_KEY nem SUPABASE_DB_URL/DATABASE_URL estao configurados.");
  const { Client } = await import("pg");
  const client = new Client({ connectionString });
  await client.connect();
  try {
    // Leitura pontual e read-only (SELECT simples) — a trava formal de
    // sessao ja foi verificada por carregarCorpusMateriaViaPg no mesmo
    // processo; aqui reaproveitamos a MESMA conexao pg padrao, apenas
    // para resolver um id a partir de um nome, nunca para escrever.
    const { rows } = await client.query(`select id, nome from public.assuntos where materia_id = $1 and nome ilike $2 limit 1`, [materiaId, nomeAssunto]);
    return rows[0]?.id ?? null;
  } finally {
    await client.end().catch(() => {});
  }
}

async function main() {
  const { values } = parseArgs({
    options: {
      subject: { type: "string" },
      "materia-id": { type: "string" },
      "recent-year-window": { type: "string", default: "6" },
      "assunto-nome": { type: "string", default: "Concordância verbal" },
    },
  });

  if (!values.subject || !values["materia-id"]) {
    console.error("Informe --subject e --materia-id.");
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

  // Fase 2C.4, Secao 3: NUNCA filtra por banca-alvo — carrega manifestos
  // curados de QUALQUER banca presente em sources/question-provenance/.
  const registrosProvenienciaCurada = carregarProvenienciaCurada();
  const provenienciaConfirmadaPorId = obterProvenienciaConfirmadaTodasBancas(registrosProvenienciaCurada);
  const idsComProvenienciaConfirmada = new Set(provenienciaConfirmadaPorId.keys());
  console.log(`registros de proveniencia curada (sources/question-provenance/*.json, qualquer banca): ${registrosProvenienciaCurada.length}`);
  console.log(`ids confirmados por curadoria humana (qualquer banca): ${idsComProvenienciaConfirmada.size}`);

  const assuntoConcordanciaVerbalId = await resolverAssuntoIdPorNome(values["assunto-nome"], materiaId);
  console.log(`assunto "${values["assunto-nome"]}" resolvido para assunto_id: ${assuntoConcordanciaVerbalId ?? "NAO ENCONTRADO"}`);

  const { perfil, classificadas } = construirPerfilDominioPolicial({
    subject: values.subject,
    materiaId,
    questoesRaw: questoes,
    recentYearWindow,
    anoAtual,
    idsComProvenienciaConfirmada,
    provenienciaConfirmadaPorId,
    assuntoConcordanciaVerbalId,
  });

  const resumoProveniencia = classificadas.reduce((acc, q) => {
    acc[q.proveniencia] = (acc[q.proveniencia] ?? 0) + 1;
    return acc;
  }, {});
  console.log("--- PROVENIENCIA DE DOMINIO ---");
  console.log(JSON.stringify(resumoProveniencia));
  console.log("--- PERFIL DE DOMINIO POLICIAL (resumo) ---");
  console.log(
    JSON.stringify(
      {
        canonical_sample: perfil.canonical_sample,
        discovery_sample: perfil.discovery_sample,
        incidence: perfil.incidence,
        confidence: perfil.confidence,
        concordancia_verbal: perfil.concordancia_verbal,
        difficulty: perfil.difficulty,
        reasoning_patterns: perfil.reasoning_patterns,
      },
      null,
      2
    )
  );

  const dirPerfis = path.join(RAIZ_SAIDA, "domain-profiles");
  garantirDiretorio(dirPerfis);
  const nomeArquivo = `police-${values.subject
    .toLowerCase()
    .trim()
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .replace(/\s+/g, "-")}-v1.json`;
  const caminho = path.join(dirPerfis, nomeArquivo);
  escreverArtefatoJson(caminho, perfil);
  console.log(`Perfil de dominio policial escrito em: ${caminho}`);
  console.log("db_writes: 0 · api_calls: 0 · rede_externa: 0");
}

main().catch((erro) => {
  console.error(erro.message);
  process.exit(1);
});
