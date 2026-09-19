import assert from "node:assert/strict";
import test from "node:test";
import { expirarGeracoesOrfas } from "../supabase/functions/_shared/gerar-aula/expiracao.mjs";

// Fase 4 — auditoria final pré-deploy: prova comportamental (não só
// leitura de código) de que a expiração de 'processando' travado só
// alcança gerações ÓRFÃS/LEGADAS (sem openai_response_id), nunca uma
// geração async genuinamente em voo na OpenAI.
//
// O mock abaixo aplica DE VERDADE os filtros encadeados (.eq/.is/.lt)
// contra um array em memória — não reimplementa a regra sendo testada,
// só interpreta os predicados que o código real (expiracao.mjs) emite.
function criarAdminMock(linhas) {
  return {
    from(tabela) {
      assert.equal(tabela, "aula_geracoes");
      return {
        update(patch) {
          const filtros = [];
          const builder = {
            eq(coluna, valor) { filtros.push((linha) => linha[coluna] === valor); return builder; },
            is(coluna, valor) { filtros.push((linha) => linha[coluna] === valor); return builder; },
            lt(coluna, valor) { filtros.push((linha) => linha[coluna] < valor); return builder; },
            then(resolve) {
              for (const linha of linhas) {
                if (filtros.every((f) => f(linha))) Object.assign(linha, patch);
              }
              return Promise.resolve({ data: null, error: null }).then(resolve);
            },
          };
          return builder;
        },
      };
    },
  };
}

const AGORA = Date.now();
const HA_15_MIN = new Date(AGORA - 15 * 60_000).toISOString();
const HA_2_MIN = new Date(AGORA - 2 * 60_000).toISOString();

function linhaBase(overrides) {
  return {
    id: "linha-1",
    conteudo_id: 47,
    unidade_pedagogica_id: "unidade-1",
    status: "processando",
    openai_response_id: null,
    iniciado_em: HA_15_MIN,
    erro: null,
    finalizado_em: null,
    ...overrides,
  };
}

test("1) processando >10min + openai_response_id NULL (órfã/legada) → expira", async () => {
  const linha = linhaBase({});
  const admin = criarAdminMock([linha]);
  await expirarGeracoesOrfas({ admin, conteudoId: 47, unidadePedagogicaId: "unidade-1", minutosExpiracao: 10 });
  assert.equal(linha.status, "erro");
  assert.match(linha.erro, /Geração expirada/);
  assert.ok(linha.finalizado_em);
});

test("2) processando >10min + openai_response_id PREENCHIDO (async em voo) → NÃO expira", async () => {
  const linha = linhaBase({ openai_response_id: "resp_abc123" });
  const admin = criarAdminMock([linha]);
  await expirarGeracoesOrfas({ admin, conteudoId: 47, unidadePedagogicaId: "unidade-1", minutosExpiracao: 10 });
  assert.equal(linha.status, "processando", "uma geração async legítima em queued/in_progress na OpenAI nunca pode ser marcada erro só por tempo");
  assert.equal(linha.erro, null);
  assert.equal(linha.finalizado_em, null);
});

test("3) processando recente (< 10min), com ou sem response_id → NÃO expira", async () => {
  const semResponseId = linhaBase({ id: "recente-sem-response-id", openai_response_id: null, iniciado_em: HA_2_MIN });
  const comResponseId = linhaBase({ id: "recente-com-response-id", openai_response_id: "resp_xyz", iniciado_em: HA_2_MIN });
  const admin = criarAdminMock([semResponseId, comResponseId]);
  await expirarGeracoesOrfas({ admin, conteudoId: 47, unidadePedagogicaId: "unidade-1", minutosExpiracao: 10 });
  assert.equal(semResponseId.status, "processando");
  assert.equal(comResponseId.status, "processando");
});

test("4) só afeta a unidade/conteúdo pedidos — outra unidade travada não é tocada", async () => {
  const daUnidadeAlvo = linhaBase({ id: "alvo" });
  const deOutraUnidade = linhaBase({ id: "outra", unidade_pedagogica_id: "unidade-2" });
  const admin = criarAdminMock([daUnidadeAlvo, deOutraUnidade]);
  await expirarGeracoesOrfas({ admin, conteudoId: 47, unidadePedagogicaId: "unidade-1", minutosExpiracao: 10 });
  assert.equal(daUnidadeAlvo.status, "erro");
  assert.equal(deOutraUnidade.status, "processando");
});

test("5) já concluída/erro não é afetada mesmo se antiga e sem response_id", async () => {
  const concluida = linhaBase({ id: "concluida", status: "concluida" });
  const admin = criarAdminMock([concluida]);
  await expirarGeracoesOrfas({ admin, conteudoId: 47, unidadePedagogicaId: "unidade-1", minutosExpiracao: 10 });
  assert.equal(concluida.status, "concluida");
});
