import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";
import { comporEnunciado } from "../scripts/importador-provas/lib/textoBase.mjs";
import { segmentarEnunciado } from "../components/questoes/midiasQuestao.ts";

// PAPIRO — schema de prova_documentos (permissões) e renderização do
// enunciado com texto-base. Leitura estática dos arquivos do repositório;
// o comportamento real das permissões foi conferido contra o banco numa
// transação terminada em ROLLBACK antes de aplicar a migration.

const MIGRATION = fs.readFileSync(new URL("../supabase/migrations/20261018140000_prova_documentos.sql", import.meta.url), "utf8");
const CSS = fs.readFileSync(new URL("../app/globals.css", import.meta.url), "utf8");
const PAGINA = fs.readFileSync(new URL("../app/questoes/page.tsx", import.meta.url), "utf8");
const comandos = MIGRATION.replace(/--.*$/gm, "");

test("DOC-SCHEMA) prova_documentos: FK para provas, hash obrigatório, posição e documento únicos por prova", () => {
  assert.match(comandos, /prova_id bigint not null references public\.provas\(id\) on delete cascade/);
  assert.match(comandos, /hash_sha256 text not null check \(hash_sha256 ~ '\^\[0-9a-f\]\{64\}\$'\)/);
  assert.match(comandos, /unique \(prova_id, tipo, ordem\)/);
  assert.match(comandos, /unique \(prova_id, hash_sha256\)/);
  assert.match(comandos, /tipo in \('GABARITO', 'RETIFICACAO'\)/);
  assert.doesNotMatch(comandos, /url text not null/, "url não é obrigatória nem identidade");
  assert.doesNotMatch(comandos, /alter table public\.provas/, "provas não é alterada");
});

test("DOC-G) aluno/anon sem permissão: RLS ligado, nada para anon, authenticated só via eh_admin()", () => {
  assert.match(comandos, /alter table public\.prova_documentos enable row level security;/);
  assert.match(comandos, /revoke all on public\.prova_documentos from anon, authenticated;/);
  assert.doesNotMatch(comandos, /grant[^;]*\bto anon\b/);
  const politicas = [...comandos.matchAll(/create policy[\s\S]*?;/g)].map((m) => m[0]);
  assert.equal(politicas.length, 1);
  assert.match(politicas[0], /to authenticated\s+using \(public\.eh_admin\(\)\)\s+with check \(public\.eh_admin\(\)\)/);
});

test("H) texto-base mantém quebra visual: o enunciado vai cru para o h1 do card, que preserva quebras e parágrafos", () => {
  const enunciado = comporEnunciado([{ texto: "Titulo\n\n[01] primeira linha\n[02] segunda linha" }], "Segundo o texto:");
  assert.equal(enunciado, "Titulo\n\n[01] primeira linha\n[02] segunda linha\n\nSegundo o texto:");
  // O h1 passa o enunciado ao EnunciadoComMidias: sem mídia ele devolve o texto cru; com mídia só intercala
  // figuras entre as linhas — o texto (e suas quebras) continua sem transformação.
  assert.match(PAGINA, /<article className="question-card">[\s\S]*?<h1>\s*<EnunciadoComMidias enunciado=\{questaoAtual\.enunciado\}/, "enunciado renderizado sem transformação");
  const COMPONENTE = fs.readFileSync(new URL("../components/questoes/EnunciadoComMidias.tsx", import.meta.url), "utf8");
  assert.match(COMPONENTE, /if \(midias\.length === 0\) return <>\{enunciado\}<\/>;/);
  const midia = { questaoId: 1, ordem: 1, tipo: "FIGURA", largura: 10, altura: 10, altText: "Figura 1", legenda: null, credito: null, ancoraTexto: "[02] segunda linha", url: null, expiraEm: null };
  const textos = segmentarEnunciado(enunciado, [midia]).filter((s) => s.tipo === "texto").map((s) => s.texto);
  assert.equal(textos.join("\n"), enunciado, "com mídia, os trechos de texto somados são o enunciado exato");
  const regra = CSS.match(/\n\.question-card h1 \{[^}]*\}/g).find((r) => /white-space/.test(r));
  assert.ok(regra, "regra .question-card h1 com white-space");
  assert.match(regra, /white-space: pre-line;/, "quebras de linha e linhas em branco preservadas; espaços repetidos do legado continuam colapsando");
  const outrasRegras = CSS.match(/\.question-card h1[^{]*\{[^}]*\}/g).filter((r) => r !== regra.trim());
  for (const r of outrasRegras) assert.doesNotMatch(r, /white-space/, "nenhuma outra regra do h1 desfaz o pre-line");
});
