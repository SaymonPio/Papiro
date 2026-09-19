import assert from "node:assert/strict";
import test from "node:test";
import { persistirAulaGerada } from "../supabase/functions/_shared/gerar-aula/persistirAulaGerada.mjs";
import { auditarEscopoArtigos } from "../supabase/functions/_shared/gerar-aula/escopo.mjs";

// Mock mínimo do client Supabase (service_role), cobrindo exatamente a
// cadeia de métodos que persistirAulaGerada.mjs usa. `respostas` é um
// mapa "operacao:tabela" -> { data, error } (ou uma função, para poder
// inspecionar o payload recebido). Cada chamada terminal
// (.maybeSingle()/.single()/await direto do builder) resolve olhando
// esse mapa — sem nenhuma rede real, sem nenhum banco real.
function criarAdminMock(respostas, chamadas) {
  function builder(tabela, operacaoInicial, payloadInicial) {
    const estado = { tabela, operacao: operacaoInicial, payload: payloadInicial };
    const chainable = {
      select() { return chainable; },
      eq() { return chainable; },
      order() { return chainable; },
      limit() { return chainable; },
      async maybeSingle() { return resolver(); },
      async single() { return resolver(); },
      then(resolve, reject) {
        // Permite `await admin.from(...).insert([...])` sem .select()
        // encadeado (caso de aula_versao_fontes).
        return Promise.resolve(resolver()).then(resolve, reject);
      },
    };
    function resolver() {
      chamadas.push({ tabela: estado.tabela, operacao: estado.operacao, payload: estado.payload });
      const chave = `${estado.operacao}:${estado.tabela}`;
      const resposta = respostas[chave];
      if (typeof resposta === "function") return resposta(estado.payload);
      if (resposta) return resposta;
      return { data: null, error: null };
    }
    return chainable;
  }

  return {
    from(tabela) {
      return {
        select() { return builder(tabela, "select"); },
        insert(payload) { return builder(tabela, "insert", payload); },
        update(payload) { return builder(tabela, "update", payload); },
      };
    },
  };
}

const COMPONENTES_VALIDOS = [
  { tipo: "diagnostico", titulo: "T", introducao: "I", pergunta: "P?", resposta_esperada: "R" },
];
const ARTIGOS_ABORDADOS = ["art. 5º, XI"];

test("A) cria aula nova (nenhuma aula_versao anterior) quando a unidade ainda não tem aula", async () => {
  const chamadas = [];
  const admin = criarAdminMock({
    "select:aulas": { data: null, error: null }, // aula ainda não existe
    "insert:aulas": { data: { id: "aula-nova" }, error: null },
    "select:aula_versoes": { data: null, error: null }, // nenhuma versão anterior
    "insert:aula_versoes": { data: { id: "versao-1" }, error: null },
    "insert:aula_versao_fontes": { data: null, error: null },
    "update:aula_geracoes": { data: null, error: null },
  }, chamadas);

  const resultado = await persistirAulaGerada({
    admin,
    geracaoId: "geracao-1",
    conteudoId: 47,
    unidadePedagogicaId: "unidade-1",
    unidadeTitulo: "Direitos Individuais e Coletivos Fundamentais",
    materiaisSelecionados: [{ id: "material-versao-1" }],
    componentes: COMPONENTES_VALIDOS,
    artigosAbordados: ARTIGOS_ABORDADOS,
    artigosEsperados: null,
    contextoSnapshot: { conteudo_id: 47 },
    tokensEntrada: 1000,
    tokensSaida: 2000,
    auditarEscopoArtigos,
  });

  assert.equal(resultado.ok, true);
  assert.equal(resultado.aulaId, "aula-nova");
  assert.equal(resultado.aulaVersaoId, "versao-1");
  assert.equal(resultado.numeroVersao, 1);

  const insertAulas = chamadas.find((c) => c.tabela === "aulas" && c.operacao === "insert");
  assert.equal(insertAulas.payload.conteudo_id, 47);
  assert.equal(insertAulas.payload.unidade_pedagogica_id, "unidade-1");

  const insertVersao = chamadas.find((c) => c.tabela === "aula_versoes" && c.operacao === "insert");
  assert.equal(insertVersao.payload.numero_versao, 1);
  assert.equal(insertVersao.payload.status, "rascunho");
  assert.ok(insertVersao.payload.estrutura.componentes[0].id, "IA nunca decide o id — servidor gera aqui");

  const updateGeracao = chamadas.find((c) => c.tabela === "aula_geracoes" && c.operacao === "update");
  assert.equal(updateGeracao.payload.status, "concluida");
  assert.equal(updateGeracao.payload.aula_versao_id, "versao-1");
  assert.equal(updateGeracao.payload.tokens_entrada, 1000);
  assert.equal(updateGeracao.payload.tokens_saida, 2000);
});

test("B) reaproveita aula existente e cria a PRÓXIMA versão (regeneração) — nunca sobrescreve numero_versao", async () => {
  const chamadas = [];
  const admin = criarAdminMock({
    "select:aulas": { data: { id: "aula-existente" }, error: null },
    "select:aula_versoes": { data: { numero_versao: 2 }, error: null }, // já existe v1 e v2
    "insert:aula_versoes": { data: { id: "versao-3" }, error: null },
    "insert:aula_versao_fontes": { data: null, error: null },
    "update:aula_geracoes": { data: null, error: null },
  }, chamadas);

  const resultado = await persistirAulaGerada({
    admin,
    geracaoId: "geracao-2",
    conteudoId: 47,
    unidadePedagogicaId: "unidade-1",
    unidadeTitulo: "Título",
    materiaisSelecionados: [],
    componentes: COMPONENTES_VALIDOS,
    artigosAbordados: ARTIGOS_ABORDADOS,
    artigosEsperados: null,
    contextoSnapshot: {},
    tokensEntrada: null,
    tokensSaida: null,
    auditarEscopoArtigos,
  });

  assert.equal(resultado.ok, true);
  assert.equal(resultado.aulaId, "aula-existente");
  assert.equal(resultado.numeroVersao, 3);
  assert.ok(!chamadas.some((c) => c.tabela === "aulas" && c.operacao === "insert"), "não deve criar uma segunda linha em aulas");
});

test("C) sem materiaisSelecionados, nunca chama aula_versao_fontes", async () => {
  const chamadas = [];
  const admin = criarAdminMock({
    "select:aulas": { data: { id: "aula-existente" }, error: null },
    "select:aula_versoes": { data: null, error: null },
    "insert:aula_versoes": { data: { id: "versao-1" }, error: null },
    "update:aula_geracoes": { data: null, error: null },
  }, chamadas);

  await persistirAulaGerada({
    admin, geracaoId: "g", conteudoId: 1, unidadePedagogicaId: "u", unidadeTitulo: "T",
    materiaisSelecionados: [], componentes: COMPONENTES_VALIDOS, artigosAbordados: [], artigosEsperados: null,
    contextoSnapshot: {}, tokensEntrada: null, tokensSaida: null, auditarEscopoArtigos,
  });

  assert.ok(!chamadas.some((c) => c.tabela === "aula_versao_fontes"), "sem fontes selecionadas, não deve inserir vínculo nenhum");
});

test("D) erro ao criar aula_versao é propagado como { ok:false }, nunca lança", async () => {
  const admin = criarAdminMock({
    "select:aulas": { data: { id: "aula-1" }, error: null },
    "select:aula_versoes": { data: null, error: null },
    "insert:aula_versoes": { data: null, error: { message: "falha simulada" } },
  }, []);

  const resultado = await persistirAulaGerada({
    admin, geracaoId: "g", conteudoId: 1, unidadePedagogicaId: "u", unidadeTitulo: "T",
    materiaisSelecionados: [], componentes: COMPONENTES_VALIDOS, artigosAbordados: [], artigosEsperados: null,
    contextoSnapshot: {}, tokensEntrada: null, tokensSaida: null, auditarEscopoArtigos,
  });

  assert.equal(resultado.ok, false);
  assert.match(resultado.erro, /versão da aula/);
});

test("E) erro ao concluir aula_geracoes (mesmo com aula/versão já criadas) é reportado, nunca retorna ok:true silenciosamente", async () => {
  const admin = criarAdminMock({
    "select:aulas": { data: { id: "aula-1" }, error: null },
    "select:aula_versoes": { data: null, error: null },
    "insert:aula_versoes": { data: { id: "versao-1" }, error: null },
    "update:aula_geracoes": { data: null, error: { message: "falha ao concluir" } },
  }, []);

  const resultado = await persistirAulaGerada({
    admin, geracaoId: "g", conteudoId: 1, unidadePedagogicaId: "u", unidadeTitulo: "T",
    materiaisSelecionados: [], componentes: COMPONENTES_VALIDOS, artigosAbordados: [], artigosEsperados: null,
    contextoSnapshot: {}, tokensEntrada: null, tokensSaida: null, auditarEscopoArtigos,
  });

  assert.equal(resultado.ok, false);
  assert.match(resultado.erro, /não foi possível concluir o registro da geração/i);
});

test("F) validacao_escopo entra no contexto final quando artigosEsperados é fornecido", async () => {
  const chamadas = [];
  const admin = criarAdminMock({
    "select:aulas": { data: { id: "aula-1" }, error: null },
    "select:aula_versoes": { data: null, error: null },
    "insert:aula_versoes": { data: { id: "versao-1" }, error: null },
    "update:aula_geracoes": { data: null, error: null },
  }, chamadas);

  await persistirAulaGerada({
    admin, geracaoId: "g", conteudoId: 1, unidadePedagogicaId: "u", unidadeTitulo: "T",
    materiaisSelecionados: [], componentes: COMPONENTES_VALIDOS,
    // A auditoria compara só o número-base do artigo (não o inciso): "art.
    // 6º" abordado não bate com nenhum artigo-base de ["art. 5º, caput"] -> alerta.
    artigosAbordados: ["art. 6º"], artigosEsperados: ["art. 5º, caput"],
    contextoSnapshot: { marcador: "x" }, tokensEntrada: null, tokensSaida: null, auditarEscopoArtigos,
  });

  const updateGeracao = chamadas.find((c) => c.tabela === "aula_geracoes" && c.operacao === "update");
  assert.equal(updateGeracao.payload.contexto.marcador, "x", "contexto original preservado (merge aditivo)");
  assert.equal(updateGeracao.payload.contexto.validacao_escopo.executada, true);
  assert.equal(updateGeracao.payload.contexto.validacao_escopo.tem_alerta, true);
});
