#!/usr/bin/env node
// Executor local seguro de arquivos .sql de supabase/ contra o banco real
// do Supabase — substitui "copiar para o SQL Editor do Studio e clicar
// Run". Ver README (seção "Executor SQL local") para o fluxo completo.
//
// Uso:
//   node executar-sql.mjs <arquivo.sql> [--apply] [--dry-run]
//
// Classificação automática do arquivo — pelo NOME e pela ÚLTIMA instrução
// real do arquivo (nunca só pelo nome, para não confiar cegamente numa
// convenção de nomenclatura):
//   *_teste_rollback.sql, terminando em ROLLBACK  -> roda sem --apply
//   pos_check_*.sql, sem nenhuma palavra de escrita -> roda sem --apply
//   qualquer outro arquivo terminando em COMMIT      -> EXIGE --apply
//   qualquer coisa que não se encaixe com segurança  -> EXIGE --apply
//
// NUNCA imprime a connection string, usuário ou senha — só host/porta/nome
// do banco (informação não sensível, já visível no painel do próprio
// projeto Supabase).
//
// --dry-run: valida arquivo, localização, classificação e presença da
// credencial — NUNCA abre conexão de rede, NUNCA executa SQL.

import fs from "node:fs";
import path from "node:path";
import { DIR_SUPABASE, carregarEnvCuradoria } from "./lib/comum.mjs";

function uso() {
  console.error("Uso: node executar-sql.mjs <arquivo.sql> [--apply] [--dry-run]");
  console.error("  <arquivo.sql> precisa estar dentro de supabase/ (caminho relativo ou absoluto).");
  process.exit(1);
}

const argumentos = process.argv.slice(2);
const flags = new Set(argumentos.filter((a) => a.startsWith("--")));
const posicionais = argumentos.filter((a) => !a.startsWith("--"));
const modoDryRun = flags.has("--dry-run");
const modoApply = flags.has("--apply");

if (posicionais.length !== 1) uso();

const caminhoArgumento = posicionais[0];

// ============================================================================
// 1) Resolução e trava de caminho.
// ============================================================================
const caminhoAbsoluto = path.resolve(process.cwd(), caminhoArgumento);
const dirSupabaseComBarra = DIR_SUPABASE.endsWith(path.sep) ? DIR_SUPABASE : DIR_SUPABASE + path.sep;

// Bloqueio explícito de segmentos proibidos — defesa em profundidade,
// mesmo que a checagem de prefixo abaixo já torne isso estruturalmente
// impossível na prática (nenhum desses caminhos fica dentro de supabase/).
const segmentos = caminhoAbsoluto.split(path.sep);
for (const proibido of [".agents", ".claude", ".mcp.json"]) {
  if (segmentos.includes(proibido)) {
    console.error(`BLOQUEADO: caminho contém segmento proibido "${proibido}".`);
    process.exit(1);
  }
}

if (!caminhoAbsoluto.startsWith(dirSupabaseComBarra)) {
  console.error(`BLOQUEADO: o arquivo precisa estar dentro de ${DIR_SUPABASE}`);
  console.error(`Caminho recebido resolveu para: ${caminhoAbsoluto}`);
  process.exit(1);
}

if (!fs.existsSync(caminhoAbsoluto) || !fs.statSync(caminhoAbsoluto).isFile()) {
  console.error(`Arquivo não encontrado: ${caminhoAbsoluto}`);
  process.exit(1);
}

const nomeArquivo = path.basename(caminhoAbsoluto);
const conteudoSql = fs.readFileSync(caminhoAbsoluto, "utf8");

// ============================================================================
// 2) Classificação do tipo de operação.
// ============================================================================
function removerComentarios(sql) {
  return sql.replace(/--[^\n]*/g, "");
}

function extrairUltimaInstrucao(sql) {
  const partes = removerComentarios(sql)
    .split(";")
    .map((p) => p.trim())
    .filter(Boolean);
  if (partes.length === 0) return null;
  return partes[partes.length - 1].toLowerCase();
}

function classificar(nome, sql) {
  const bruta = extrairUltimaInstrucao(sql);
  const terminaEm = bruta === "commit" ? "commit" : bruta === "rollback" ? "rollback" : bruta;

  if (/_teste_rollback\.sql$/.test(nome)) {
    if (terminaEm === "rollback") return { tipo: "teste_rollback", exigeApply: false, terminaEm };
    return {
      tipo: "teste_rollback_suspeito",
      exigeApply: true,
      terminaEm,
      motivo: `nomeado como teste_rollback, mas a última instrução é "${terminaEm}", não ROLLBACK`,
    };
  }

  if (/^pos_check_/.test(nome)) {
    const temEscrita = /\b(insert|update|delete|create|drop|alter|truncate|grant|revoke)\b/i.test(removerComentarios(sql));
    if (!temEscrita) return { tipo: "pos_check", exigeApply: false, terminaEm };
    return {
      tipo: "pos_check_suspeito",
      exigeApply: true,
      terminaEm,
      motivo: "nomeado como pos_check, mas contém palavra-chave de escrita (insert/update/delete/create/drop/alter/truncate/grant/revoke)",
    };
  }

  if (terminaEm === "commit") return { tipo: "apply", exigeApply: true, terminaEm };

  return { tipo: "desconhecido", exigeApply: true, terminaEm };
}

const classificacao = classificar(nomeArquivo, conteudoSql);

// ============================================================================
// 3) Credencial — SUPABASE_DB_URL ou DATABASE_URL em .env.curadoria.
//    NUNCA impressa: só um resumo não sensível (host/porta/banco).
// ============================================================================
carregarEnvCuradoria();
const connectionString = process.env.SUPABASE_DB_URL || process.env.DATABASE_URL;

function mascarar(url) {
  if (!url) return null;
  try {
    const u = new URL(url);
    return {
      host: u.hostname,
      porta: u.port || "5432",
      banco: u.pathname.replace(/^\//, "") || "(padrão)",
      usuario: u.username ? "***" : "(nenhum)",
      senha_configurada: Boolean(u.password),
    };
  } catch {
    return { aviso: "connection string presente, mas não foi possível interpretar o formato (nunca será impressa crua)" };
  }
}

const destinoMascarado = mascarar(connectionString);

// ============================================================================
// 4) Relatório — sempre mostrado, mesmo em --dry-run, antes de qualquer
//    tentativa de execução.
// ============================================================================
console.log("=== Executor SQL — supabase/ ===");
console.log(`Arquivo: supabase/${path.relative(DIR_SUPABASE, caminhoAbsoluto)}`);
const terminaEmResumido =
  classificacao.terminaEm && classificacao.terminaEm.length > 60
    ? classificacao.terminaEm.slice(0, 60).replace(/\s+/g, " ") + "…"
    : classificacao.terminaEm;
console.log(`Tipo detectado: ${classificacao.tipo} (última instrução: ${terminaEmResumido ?? "nenhuma"})`);
console.log(`Exige --apply: ${classificacao.exigeApply ? "sim" : "não"}${modoApply ? " (fornecida)" : ""}`);
console.log(`Destino do banco: ${destinoMascarado ? JSON.stringify(destinoMascarado) : "NÃO CONFIGURADO"}`);
console.log(`Modo: ${modoDryRun ? "--dry-run (nenhum SQL será executado, nenhuma conexão de rede será aberta)" : "execução real"}`);
if (classificacao.motivo) console.log(`Aviso de classificação: ${classificacao.motivo}`);

// ============================================================================
// 5) Trava: operação de escrita exige --apply explícito.
// ============================================================================
if (classificacao.exigeApply && !modoApply) {
  console.error("");
  console.error(`BLOQUEADO: este arquivo é classificado como "${classificacao.tipo}" e precisa da flag --apply explícita para rodar de verdade.`);
  console.error("Rode novamente com --apply se você realmente pretende aplicar esta escrita.");
  process.exit(1);
}

// ============================================================================
// 6) --dry-run termina aqui — nunca abre socket, nunca executa SQL.
// ============================================================================
if (modoDryRun) {
  console.log("");
  if (!connectionString) {
    console.log("DRY-RUN: SUPABASE_DB_URL/DATABASE_URL não configurada — a execução real falharia neste ponto.");
    process.exit(1);
  }
  console.log("DRY-RUN: configuração presente, arquivo encontrado e válido, tipo de operação reconhecido. Nenhum SQL foi executado, nenhuma conexão foi aberta.");
  process.exit(0);
}

if (!connectionString) {
  console.error("");
  console.error(`Defina SUPABASE_DB_URL (ou DATABASE_URL) em ${path.join("scripts", "curadoria-pedagogica", ".env.curadoria")} antes de executar de verdade.`);
  process.exit(1);
}

// ============================================================================
// 7) Execução real via pg (node-postgres) — captura NOTICE (onde o
//    _relatorio dos harnesses de teste rollback aparece, via RAISE NOTICE)
//    e o resultado de SELECTs (pos-check).
// ============================================================================
const { Client } = await import("pg");
const client = new Client({ connectionString });

const avisos = [];
client.on("notice", (msg) => {
  avisos.push(msg.message);
  console.log(`NOTICE: ${msg.message}`);
});

let sucesso = true;

try {
  await client.connect();
  const resultado = await client.query(conteudoSql);
  const resultados = Array.isArray(resultado) ? resultado : [resultado];
  for (const r of resultados) {
    if (r && Array.isArray(r.rows) && r.rows.length > 0) {
      console.log(`--- resultado (${r.rows.length} linha(s)) ---`);
      console.table(r.rows);
    }
  }
} catch (erro) {
  sucesso = false;
  console.error(`ERRO SQL: ${erro.message}`);
} finally {
  await client.end().catch(() => {});
}

const houveFalhaLogica = avisos.some((a) => /tudo_ok\s*=\s*false/i.test(a));

console.log("");
console.log(
  `=== Resultado: ${
    sucesso ? (houveFalhaLogica ? "SQL executou sem erro, mas o relatório interno reportou tudo_ok = false" : "OK") : "FALHOU"
  } ===`
);

// Exit codes: 0 = sucesso completo; 1 = erro de execução SQL (ou bloqueio
// anterior); 2 = SQL rodou sem erro, mas o próprio relatório (RAISE NOTICE
// 'tudo_ok = false') indica que a validação lógica não passou — distinção
// que não existia antes e que ajuda quem chamar este script a diferenciar
// "quebrou" de "rodou, mas achou divergência".
process.exit(sucesso ? (houveFalhaLogica ? 2 : 0) : 1);
