import assert from "node:assert/strict";
import test from "node:test";
import { geracaoBloqueiaNovaGeracao, LIMITE_GERACAO_SEM_RESPONSE_MS } from "../app/admin/aulas/geracao-guard.ts";

// Correção do bloqueio circular do botão "Gerar aula": a RPC
// listar_geracoes_conteudo_admin (LIVE, supabase/teoria_geracoes_admin_
// tem_response_id.sql) agora expõe `tem_response_id boolean` — nunca o
// openai_response_id bruto. Estes testes usam um `agora` injetável (nunca
// o relógio real) para serem determinísticos, mesmo princípio de
// tests/admin-aulas-banco-unidade.test.mjs para a outra função pura
// extraída desta mesma tela.

const AGORA = new Date("2026-09-17T12:00:00.000Z").getTime();
const HA_2_MIN = new Date(AGORA - 2 * 60_000).toISOString();
const HA_11_MIN = new Date(AGORA - 11 * 60_000).toISOString();
const HA_EXATAMENTE_10_MIN = new Date(AGORA - LIMITE_GERACAO_SEM_RESPONSE_MS).toISOString();
const HA_MAIS_DE_10_MIN = new Date(AGORA - 15 * 60_000).toISOString();

test("A) processando + tem_response_id=true + idade >10min → BLOQUEIA (geração async real pode legitimamente durar mais de 10min)", () => {
  const geracao = { status: "processando", tem_response_id: true, iniciado_em: HA_MAIS_DE_10_MIN };
  assert.equal(geracaoBloqueiaNovaGeracao(geracao, AGORA), true);
});

test("B) processando + tem_response_id=false + idade 2min → BLOQUEIA (pode estar entre criar a linha e persistir o response_id)", () => {
  const geracao = { status: "processando", tem_response_id: false, iniciado_em: HA_2_MIN };
  assert.equal(geracaoBloqueiaNovaGeracao(geracao, AGORA), true);
});

test("C) processando + tem_response_id=false + idade 11min → NÃO BLOQUEIA (registro órfão do fluxo síncrono antigo)", () => {
  const geracao = { status: "processando", tem_response_id: false, iniciado_em: HA_11_MIN };
  assert.equal(geracaoBloqueiaNovaGeracao(geracao, AGORA), false);
});

test("D) processando + tem_response_id=false + idade exatamente 10min → NÃO BLOQUEIA (limite é exclusivo: idade < limite bloqueia, idade >= limite não)", () => {
  const geracao = { status: "processando", tem_response_id: false, iniciado_em: HA_EXATAMENTE_10_MIN };
  assert.equal(geracaoBloqueiaNovaGeracao(geracao, AGORA), false);
});

test("E) concluida → NÃO BLOQUEIA, mesmo com tem_response_id=true e recente", () => {
  const geracao = { status: "concluida", tem_response_id: true, iniciado_em: HA_2_MIN };
  assert.equal(geracaoBloqueiaNovaGeracao(geracao, AGORA), false);
});

test("F) erro → NÃO BLOQUEIA, mesmo com tem_response_id=true e recente", () => {
  const geracao = { status: "erro", tem_response_id: true, iniciado_em: HA_2_MIN };
  assert.equal(geracaoBloqueiaNovaGeracao(geracao, AGORA), false);
});

test("G) processando + tem_response_id=false + iniciado_em inválido → BLOQUEIA por fail-safe", () => {
  const geracao = { status: "processando", tem_response_id: false, iniciado_em: "data-invalida" };
  assert.equal(geracaoBloqueiaNovaGeracao(geracao, AGORA), true);
});

test("H) o registro legado real da unidade alvo (0c5d1d64-...), tem_response_id=false e iniciado há mais de 10min, não bloqueia mais o botão", () => {
  // Estado real confirmado em produção (id f2a0d24c-9a2d-4adc-ad09-680e686bb31a):
  // status='processando', openai_response_id=NULL (⇒ tem_response_id=false),
  // iniciado_em='2026-09-14T22:54:01Z' — várias horas antes de qualquer
  // `agora` razoável.
  const registroLegado = { status: "processando", tem_response_id: false, iniciado_em: "2026-09-14T22:54:01.898Z" };
  assert.equal(geracaoBloqueiaNovaGeracao(registroLegado, AGORA), false, "o registro legado não pode mais travar o botão — é exatamente o bug que esta correção resolve");
});

test("usa o relógio real por padrão quando `agora` não é injetado (comportamento de produção)", () => {
  const geracaoAntiga = { status: "processando", tem_response_id: false, iniciado_em: "2020-01-01T00:00:00.000Z" };
  assert.equal(geracaoBloqueiaNovaGeracao(geracaoAntiga), false);
});
