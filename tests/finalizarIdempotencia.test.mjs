import assert from "node:assert/strict";
import test from "node:test";
import { reivindicarGeracaoParaFinalizar, liberarLeaseFinalizacao, LEASE_FINALIZACAO_MINUTOS } from "../supabase/functions/_shared/gerar-aula/idempotencia.mjs";

// Fase 4.1 — auditoria final: substitui o claim baseado em `finalizado_em`
// (Fase 4) por uma LEASE recuperável dedicada (finalizacao_lease_ate).
// Prova comportamental de que (a) dois workers concorrentes nunca vencem
// a mesma reivindicação, (b) um worker que "morre" no meio do caminho
// nunca prende a geração para sempre — a lease vence sozinha.
//
// O mock reproduz a garantia real do Postgres: um UPDATE condicional
// avalia o WHERE (incluindo o `.or(...)` traduzido aqui de forma fiel ao
// formato PostgREST "campo.is.null,campo.lt.valor") contra o estado ATUAL
// da linha, aplicando a mudança só se casar — chamadas em sequência sobre
// o MESMO estado em memória modelam a serialização por lock de linha que
// o Postgres garante entre UPDATEs concorrentes na mesma linha.
function criarAdminMock(linha) {
  function avaliarOr(expressao, l) {
    // Formato emitido por idempotencia.mjs: "campo.is.null,campo.lt.ISO"
    return expressao.split(",").some((clausula) => {
      const [campo, operador, valor] = clausula.split(".");
      if (operador === "is" && valor === "null") return l[campo] === null || l[campo] === undefined;
      if (operador === "lt") return l[campo] != null && l[campo] < valor;
      throw new Error(`operador não suportado pelo mock: ${clausula}`);
    });
  }

  return {
    from(tabela) {
      assert.equal(tabela, "aula_geracoes");
      return {
        update(patch) {
          const filtros = [];
          const builder = {
            eq(coluna, valor) { filtros.push((l) => l[coluna] === valor); return builder; },
            is(coluna, valor) { filtros.push((l) => (valor === null ? l[coluna] === null || l[coluna] === undefined : l[coluna] === valor)); return builder; },
            or(expressao) { filtros.push((l) => avaliarOr(expressao, l)); return builder; },
            select() { return builder; },
            async maybeSingle() {
              if (!filtros.every((f) => f(linha))) return { data: null, error: null };
              Object.assign(linha, patch);
              return { data: { id: linha.id }, error: null };
            },
            then(resolve, reject) {
              // liberarLeaseFinalizacao faz um await direto, sem .select()/.maybeSingle().
              if (filtros.every((f) => f(linha))) Object.assign(linha, patch);
              return Promise.resolve({ data: null, error: null }).then(resolve, reject);
            },
          };
          return builder;
        },
      };
    },
  };
}

function geracaoElegivel(overrides) {
  return { id: "geracao-1", status: "processando", aula_versao_id: null, finalizado_em: null, finalizacao_lease_ate: null, ...overrides };
}

// ---------------------------------------------------------------------
// A) Reivindicação inicial
// ---------------------------------------------------------------------
test("A) reivindicação inicial numa geração elegível sempre sucede e grava lease no futuro", async () => {
  const linha = geracaoElegivel({});
  const admin = criarAdminMock(linha);
  const agora = new Date("2026-01-01T00:00:00.000Z");
  const ok = await reivindicarGeracaoParaFinalizar({ admin, geracaoId: "geracao-1", agora });
  assert.equal(ok, true);
  assert.equal(linha.finalizacao_lease_ate, new Date(agora.getTime() + LEASE_FINALIZACAO_MINUTOS * 60_000).toISOString());
  assert.equal(linha.finalizado_em, null, "a reivindicação NUNCA deve tocar finalizado_em — Fase 4.1 corrige exatamente isso");
});

// ---------------------------------------------------------------------
// B) Segundo worker bloqueado
// ---------------------------------------------------------------------
test("B) worker A reivindica; worker B, imediatamente depois, tenta a MESMA geração e é bloqueado (lease ainda no futuro)", async () => {
  const linha = geracaoElegivel({});
  const admin = criarAdminMock(linha);
  const agora = new Date("2026-01-01T00:00:00.000Z");

  const workerA = await reivindicarGeracaoParaFinalizar({ admin, geracaoId: "geracao-1", agora });
  const umSegundoDepois = new Date(agora.getTime() + 1000);
  const workerB = await reivindicarGeracaoParaFinalizar({ admin, geracaoId: "geracao-1", agora: umSegundoDepois });

  assert.equal(workerA, true);
  assert.equal(workerB, false, "worker B nunca pode reivindicar enquanto a lease de A ainda está no futuro");
});

// ---------------------------------------------------------------------
// C) Lease vencida recuperável
// ---------------------------------------------------------------------
test("C) depois que a lease vence, um novo worker consegue reivindicar de novo", async () => {
  const linha = geracaoElegivel({});
  const admin = criarAdminMock(linha);
  const agora = new Date("2026-01-01T00:00:00.000Z");

  const workerA = await reivindicarGeracaoParaFinalizar({ admin, geracaoId: "geracao-1", agora });
  assert.equal(workerA, true);

  const depoisDaExpiracao = new Date(agora.getTime() + (LEASE_FINALIZACAO_MINUTOS + 1) * 60_000);
  const workerC = await reivindicarGeracaoParaFinalizar({ admin, geracaoId: "geracao-1", agora: depoisDaExpiracao });
  assert.equal(workerC, true, "uma lease vencida deve permitir reivindicação normalmente, sem intervenção manual");
});

// ---------------------------------------------------------------------
// D) Worker crash recuperável (CRASH_RECOVERY_LEASE_OK)
// ---------------------------------------------------------------------
test("D) worker morre logo após reivindicar — status/aula_versao_id/finalizado_em nunca mudam; lease protege até vencer, depois libera recuperação", async () => {
  const linha = geracaoElegivel({});
  const admin = criarAdminMock(linha);
  const agora = new Date("2026-01-01T00:00:00.000Z");

  // 1) worker A reivindica.
  const workerA = await reivindicarGeracaoParaFinalizar({ admin, geracaoId: "geracao-1", agora });
  assert.equal(workerA, true);

  // 2) "morte" simulada: nenhuma chamada adicional acontece — nem
  // persistirAulaGerada, nem UPDATE de erro. É exatamente essa ausência
  // de qualquer follow-up que o teste precisa provar que NÃO prende a
  // geração para sempre.
  assert.equal(linha.status, "processando", "3) status continua processando");
  assert.equal(linha.aula_versao_id, null, "4) aula_versao_id continua NULL");
  assert.equal(linha.finalizado_em, null, "5) finalizado_em continua NULL — nunca foi tocado pela reivindicação");
  assert.ok(linha.finalizacao_lease_ate, "6) lease fica preenchida");

  // 7) ANTES da expiração, outro worker não entra.
  const antesDaExpiracao = new Date(agora.getTime() + 2 * 60_000);
  const workerBAntes = await reivindicarGeracaoParaFinalizar({ admin, geracaoId: "geracao-1", agora: antesDaExpiracao });
  assert.equal(workerBAntes, false);

  // 8) DEPOIS da expiração, outro worker entra — recuperação bem-sucedida.
  const depoisDaExpiracao = new Date(agora.getTime() + (LEASE_FINALIZACAO_MINUTOS + 1) * 60_000);
  const workerCDepois = await reivindicarGeracaoParaFinalizar({ admin, geracaoId: "geracao-1", agora: depoisDaExpiracao });
  assert.equal(workerCDepois, true);
});
// CRASH_RECOVERY_LEASE_OK = SIM (provado pelo teste D acima).

// ---------------------------------------------------------------------
// E) liberarLeaseFinalizacao — usado por queued/in_progress/correção
// ---------------------------------------------------------------------
test("E) liberarLeaseFinalizacao zera a lease sem tocar em status/aula_versao_id/finalizado_em", async () => {
  const linha = geracaoElegivel({ finalizacao_lease_ate: "2026-01-01T00:05:00.000Z" });
  const admin = criarAdminMock(linha);
  await liberarLeaseFinalizacao({ admin, geracaoId: "geracao-1" });
  assert.equal(linha.finalizacao_lease_ate, null);
  assert.equal(linha.status, "processando");
  assert.equal(linha.finalizado_em, null);
  assert.equal(linha.aula_versao_id, null);
});

test("F) depois de liberarLeaseFinalizacao, um novo worker pode reivindicar imediatamente — não precisa esperar a lease vencer", async () => {
  const linha = geracaoElegivel({});
  const admin = criarAdminMock(linha);
  const agora = new Date("2026-01-01T00:00:00.000Z");

  await reivindicarGeracaoParaFinalizar({ admin, geracaoId: "geracao-1", agora });
  await liberarLeaseFinalizacao({ admin, geracaoId: "geracao-1" });

  const umSegundoDepois = new Date(agora.getTime() + 1000);
  const proximoWorker = await reivindicarGeracaoParaFinalizar({ admin, geracaoId: "geracao-1", agora: umSegundoDepois });
  assert.equal(proximoWorker, true, "liberação explícita da lease permite reivindicação imediata, sem esperar LEASE_FINALIZACAO_MINUTOS");
});

// ---------------------------------------------------------------------
// G) geração já finalizada (aula_versao_id preenchido) nunca é reivindicada de novo
// ---------------------------------------------------------------------
test("G) geração já concluída (aula_versao_id preenchido) nunca é reivindicada, mesmo sem lease ativa", async () => {
  const linha = { id: "geracao-2", status: "concluida", aula_versao_id: "versao-ja-existente", finalizado_em: "2026-01-01T00:00:00Z", finalizacao_lease_ate: null };
  const admin = criarAdminMock(linha);
  const ok = await reivindicarGeracaoParaFinalizar({ admin, geracaoId: "geracao-2" });
  assert.equal(ok, false, "duas finalizações simultâneas não podem gerar duas versões — esta é a garantia final contra duplicação");
});

test("H) geração já marcada 'erro' nunca é reivindicada", async () => {
  const linha = { id: "geracao-3", status: "erro", aula_versao_id: null, finalizado_em: "2026-01-01T00:00:00Z", finalizacao_lease_ate: null };
  const admin = criarAdminMock(linha);
  const ok = await reivindicarGeracaoParaFinalizar({ admin, geracaoId: "geracao-3" });
  assert.equal(ok, false);
});

test("I) erro do banco na reivindicação nunca é tratado como sucesso (fail-closed)", async () => {
  const admin = {
    from() {
      return {
        update() {
          return {
            eq() { return this; },
            is() { return this; },
            or() { return this; },
            select() { return this; },
            async maybeSingle() { return { data: null, error: { message: "falha simulada de rede" } }; },
          };
        },
      };
    },
  };
  const ok = await reivindicarGeracaoParaFinalizar({ admin, geracaoId: "geracao-4" });
  assert.equal(ok, false);
});

test("J) liberarLeaseFinalizacao nunca lança mesmo se o admin.from() falhar (best-effort)", async () => {
  const admin = { from() { throw new Error("falha simulada"); } };
  await assert.doesNotReject(() => liberarLeaseFinalizacao({ admin, geracaoId: "geracao-5" }));
});
