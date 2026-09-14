import assert from "node:assert/strict";
import test from "node:test";
import {
  resolverAulaVersaoDaUnidade,
  resolverInfoConteudo,
  resolverTituloPercurso,
} from "../app/admin/aulas/preview/percurso.ts";

// Fixtures espelhando exatamente o formato real de contexto persistido por
// contextoSnapshot em supabase/functions/gerar-aula/index.ts e devolvido
// por public.listar_geracoes_conteudo_admin (já ordenado por iniciado_em
// desc, replicado aqui na mesma ordem).

// Lei de Tortura (curso_conteudo_id 73) — estado LIVE real: 1 única
// geração concluída, aula_versao_id a3464ad9-... (rascunho, com o
// componente jurisprudencia_essencial aplicado em rodada anterior).
const GERACOES_LEI_TORTURA = [
  {
    status: "concluida",
    aula_versao_id: "a3464ad9-ca13-4adf-a6f6-262ad1576f73",
    contexto: {
      unidade_pedagogica_id: "392fd9fe-a3d2-4062-b912-0a299b414429",
      unidade_pedagogica: "Lei de Tortura",
      conteudo: "Lei de Tortura",
      materia: "Direitos Humanos",
      concurso: "Brigada Militar RS - Soldado de Primeira Classe",
      cargo: "Soldado",
      banca: "Fundatec",
    },
  },
];

// Lei Maria da Penha (curso_conteudo_id 53) — estado LIVE real: 5
// unidades, 2 delas com mais de uma geração concluída (regeneração) —
// a RPC já devolve por iniciado_em desc, então o PRIMEIRO match de cada
// unidade já é o mais recente.
const GERACOES_LMP = [
  { status: "concluida", aula_versao_id: "49810ea3-20c3-4222-891c-20a3cab5aac8",
    contexto: { unidade_pedagogica_id: "4d593bc4-6e4f-4c1f-8817-e41c78fe9491", conteudo: "Lei Maria da Penha" } },
  { status: "concluida", aula_versao_id: "dc5b3e4f-a7cc-4244-9bac-9389cb0057b8",
    contexto: { unidade_pedagogica_id: "53dc06a1-cd16-4004-a76b-8201d95a91c4", conteudo: "Lei Maria da Penha" } },
  { status: "concluida", aula_versao_id: "141b5e3f-0e34-4850-a3ff-b9145667f689",
    contexto: { unidade_pedagogica_id: "7164d7f2-86f7-413e-b0fc-64070dd2e2f5", conteudo: "Lei Maria da Penha" } },
  // regeneração mais recente de "Prevenção e assistência à mulher" (deve vencer a mais antiga abaixo)
  { status: "concluida", aula_versao_id: "cfd879d2-4bb0-41b3-9da1-32ae3533966a",
    contexto: { unidade_pedagogica_id: "ab29ba89-1dcc-46c2-9659-f5808be3d976", conteudo: "Lei Maria da Penha" } },
  { status: "concluida", aula_versao_id: "6e586ac8-0696-42ac-8f23-c11f63cd92d0",
    contexto: { unidade_pedagogica_id: "ab29ba89-1dcc-46c2-9659-f5808be3d976", conteudo: "Lei Maria da Penha" } },
  // regeneração mais recente de "Fundamentos e campo de aplicação"
  { status: "concluida", aula_versao_id: "9b430867-7595-4600-a2a8-7a769661cb5e",
    contexto: { unidade_pedagogica_id: "e260b54c-6a75-4398-97f6-7a432c405041", conteudo: "Lei Maria da Penha" } },
  { status: "concluida", aula_versao_id: "8cfde0f2-4257-48d2-bfe1-463fe3d28ddf",
    contexto: null }, // geração antiga, sem contexto (migração de contexto veio depois)
  { status: "erro", aula_versao_id: null, contexto: null },
];

test("resolve a aula_versao_id da unidade Lei de Tortura (caso de 1 única geração)", () => {
  const resolvido = resolverAulaVersaoDaUnidade(GERACOES_LEI_TORTURA, "392fd9fe-a3d2-4062-b912-0a299b414429");
  assert.equal(resolvido, "a3464ad9-ca13-4adf-a6f6-262ad1576f73");
});

test("resolve null quando a unidade não tem nenhuma geração concluída", () => {
  const resolvido = resolverAulaVersaoDaUnidade(GERACOES_LEI_TORTURA, "id-de-unidade-inexistente");
  assert.equal(resolvido, null);
});

test("resolve a versão MAIS RECENTE quando a unidade tem mais de uma geração (regeneração)", () => {
  const resolvidoPrevencao = resolverAulaVersaoDaUnidade(GERACOES_LMP, "ab29ba89-1dcc-46c2-9659-f5808be3d976");
  assert.equal(resolvidoPrevencao, "cfd879d2-4bb0-41b3-9da1-32ae3533966a"); // não a antiga 6e586ac8

  const resolvidoFundamentos = resolverAulaVersaoDaUnidade(GERACOES_LMP, "e260b54c-6a75-4398-97f6-7a432c405041");
  assert.equal(resolvidoFundamentos, "9b430867-7595-4600-a2a8-7a769661cb5e"); // não a antiga 8cfde0f2
});

test("resolve corretamente as 5 unidades de Lei Maria da Penha (regressão obrigatória)", () => {
  const mapa = {
    "e260b54c-6a75-4398-97f6-7a432c405041": "9b430867-7595-4600-a2a8-7a769661cb5e",
    "ab29ba89-1dcc-46c2-9659-f5808be3d976": "cfd879d2-4bb0-41b3-9da1-32ae3533966a",
    "4d593bc4-6e4f-4c1f-8817-e41c78fe9491": "49810ea3-20c3-4222-891c-20a3cab5aac8",
    "7164d7f2-86f7-413e-b0fc-64070dd2e2f5": "141b5e3f-0e34-4850-a3ff-b9145667f689",
    "53dc06a1-cd16-4004-a76b-8201d95a91c4": "dc5b3e4f-a7cc-4244-9bac-9389cb0057b8",
  };
  for (const [unidadeId, aulaVersaoIdEsperada] of Object.entries(mapa)) {
    assert.equal(resolverAulaVersaoDaUnidade(GERACOES_LMP, unidadeId), aulaVersaoIdEsperada);
  }
});

test("resolverInfoConteudo lê nome/materia/banca do contexto da geração mais recente com contexto", () => {
  const info = resolverInfoConteudo(GERACOES_LEI_TORTURA);
  assert.equal(info.conteudo, "Lei de Tortura");
  assert.equal(info.materia, "Direitos Humanos");
  assert.equal(info.banca, "Fundatec");
});

test("resolverInfoConteudo devolve tudo null quando não há nenhuma geração com contexto", () => {
  const info = resolverInfoConteudo([{ status: "erro", aula_versao_id: null, contexto: null }]);
  assert.equal(info.conteudo, null);
  assert.equal(info.materia, null);
});

test("resolverTituloPercurso prefere o nome real do contexto sobre o fallback da query string", () => {
  const info = resolverInfoConteudo(GERACOES_LEI_TORTURA);
  assert.equal(resolverTituloPercurso(info, "Nome Antigo Passado Na URL", 73), "Lei de Tortura");
});

test("resolverTituloPercurso usa o fallback da query string quando não há geração ainda", () => {
  const info = resolverInfoConteudo([]);
  assert.equal(resolverTituloPercurso(info, "Lei de Tortura", 73), "Lei de Tortura");
});

test("resolverTituloPercurso usa rótulo genérico com o id quando não há nome nenhum disponível", () => {
  const info = resolverInfoConteudo([]);
  assert.equal(resolverTituloPercurso(info, null, 73), "Conteúdo #73");
});
