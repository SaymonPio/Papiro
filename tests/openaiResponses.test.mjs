import assert from "node:assert/strict";
import test from "node:test";
import {
  classificarStatusOpenAI,
  resolverConfiguracaoModelo,
  submeterResponseBackground,
  buscarResponse,
  extrairTextoSaida,
  montarPromptContexto,
  PROMPT_VERSION,
} from "../supabase/functions/_shared/gerar-aula/openaiResponses.mjs";

// Cobre a máquina de estados da Responses API em background (queued/
// in_progress/completed/failed/cancelled/incomplete/desconhecido) e a
// resolução de configuração por env — sem chamar a OpenAI de verdade.
// submeterResponseBackground/buscarResponse são testados com um mock de
// globalThis.fetch (Node tem fetch nativo, então monkey-patch funciona
// igual em produção) — nenhuma rede real é usada.

test("A) classificarStatusOpenAI: queued/in_progress -> aguardando", () => {
  assert.equal(classificarStatusOpenAI("queued"), "aguardando");
  assert.equal(classificarStatusOpenAI("in_progress"), "aguardando");
});

test("B) classificarStatusOpenAI: failed/cancelled/incomplete -> erro_terminal", () => {
  assert.equal(classificarStatusOpenAI("failed"), "erro_terminal");
  assert.equal(classificarStatusOpenAI("cancelled"), "erro_terminal");
  assert.equal(classificarStatusOpenAI("incomplete"), "erro_terminal");
});

test("C) classificarStatusOpenAI: completed -> completar", () => {
  assert.equal(classificarStatusOpenAI("completed"), "completar");
});

test("D) classificarStatusOpenAI: status desconhecido/futuro/ausente -> desconhecido, nunca lança", () => {
  assert.equal(classificarStatusOpenAI("algum_status_novo_da_api"), "desconhecido");
  assert.equal(classificarStatusOpenAI(undefined), "desconhecido");
  assert.equal(classificarStatusOpenAI(null), "desconhecido");
});

test("E) resolverConfiguracaoModelo: usa os defaults quando nenhuma env está configurada", () => {
  const config = resolverConfiguracaoModelo(() => undefined);
  assert.equal(config.modelo, "gpt-5.6-luna");
  assert.equal(config.reasoningEffort, "high");
  assert.equal(config.maxOutputTokens, 12000);
});

test("F) resolverConfiguracaoModelo: respeita envs válidas", () => {
  const env = { OPENAI_MODEL: "gpt-6-astra", OPENAI_REASONING_EFFORT: "medium", OPENAI_MAX_OUTPUT_TOKENS: "9000" };
  const config = resolverConfiguracaoModelo((nome) => env[nome]);
  assert.equal(config.modelo, "gpt-6-astra");
  assert.equal(config.reasoningEffort, "medium");
  assert.equal(config.maxOutputTokens, 9000);
});

test("G) resolverConfiguracaoModelo: reasoning_effort inválido/fora do conjunto cai no default, nunca quebra", () => {
  const config = resolverConfiguracaoModelo((nome) => (nome === "OPENAI_REASONING_EFFORT" ? "turbo" : undefined));
  assert.equal(config.reasoningEffort, "high");
});

test("H) resolverConfiguracaoModelo: max_output_tokens fora da faixa [6000,128000] cai no default", () => {
  const abaixo = resolverConfiguracaoModelo((nome) => (nome === "OPENAI_MAX_OUTPUT_TOKENS" ? "100" : undefined));
  assert.equal(abaixo.maxOutputTokens, 12000);
  const acima = resolverConfiguracaoModelo((nome) => (nome === "OPENAI_MAX_OUTPUT_TOKENS" ? "999999" : undefined));
  assert.equal(acima.maxOutputTokens, 12000);
  const naoNumerico = resolverConfiguracaoModelo((nome) => (nome === "OPENAI_MAX_OUTPUT_TOKENS" ? "abc" : undefined));
  assert.equal(naoNumerico.maxOutputTokens, 12000);
});

test("I) extrairTextoSaida: extrai o output_text do formato real da Responses API", () => {
  const resultado = { output: [{ content: [{ type: "output_text", text: '{"componentes":[]}' }] }] };
  assert.equal(extrairTextoSaida(resultado), '{"componentes":[]}');
});

test("I) extrairTextoSaida: retorna null quando não há output_text (nunca lança)", () => {
  assert.equal(extrairTextoSaida({ output: [] }), null);
  assert.equal(extrairTextoSaida({}), null);
  assert.equal(extrairTextoSaida(null), null);
});

// ---------------------------------------------------------------------
// submeterResponseBackground / buscarResponse — fetch mockado.
// ---------------------------------------------------------------------

function comFetchMockado(respostaMock, fn) {
  const original = globalThis.fetch;
  let ultimaChamada = null;
  globalThis.fetch = async (url, init) => {
    ultimaChamada = { url, init };
    return {
      ok: respostaMock.ok,
      status: respostaMock.status ?? (respostaMock.ok ? 200 : 400),
      json: async () => respostaMock.corpo,
    };
  };
  try {
    return fn(() => ultimaChamada);
  } finally {
    globalThis.fetch = original;
  }
}

test("J) submeterResponseBackground: sucesso — envia background:true/store:true e devolve o response.id", async () => {
  await comFetchMockado({ ok: true, corpo: { id: "resp_abc123", status: "queued" } }, async (getUltimaChamada) => {
    const resultado = await submeterResponseBackground({
      openaiKey: "sk-fake",
      modelo: "gpt-6-astra",
      reasoningEffort: "high",
      maxOutputTokens: 12000,
      textoPrompt: "prompt de teste",
      anexos: [],
    });
    assert.equal(resultado.ok, true);
    assert.equal(resultado.responseId, "resp_abc123");
    assert.equal(resultado.statusInicial, "queued");

    const chamada = getUltimaChamada();
    const corpoEnviado = JSON.parse(chamada.init.body);
    assert.equal(corpoEnviado.background, true);
    assert.equal(corpoEnviado.store, true);
    assert.equal(corpoEnviado.model, "gpt-6-astra");
    assert.equal(corpoEnviado.reasoning.effort, "high");
    assert.equal(corpoEnviado.max_output_tokens, 12000);
    assert.ok(chamada.init.headers.Authorization.includes("Bearer sk-fake"));
  });
});

test("K) submeterResponseBackground: inclui previous_response_id quando fornecido (correção encadeada)", async () => {
  await comFetchMockado({ ok: true, corpo: { id: "resp_correcao", status: "queued" } }, async (getUltimaChamada) => {
    await submeterResponseBackground({
      openaiKey: "sk-fake",
      modelo: "gpt-6-astra",
      reasoningEffort: "high",
      maxOutputTokens: 12000,
      textoPrompt: "prompt de correção",
      anexos: [],
      previousResponseId: "resp_original",
    });
    const corpoEnviado = JSON.parse(getUltimaChamada().init.body);
    assert.equal(corpoEnviado.previous_response_id, "resp_original");
  });
});

test("L) submeterResponseBackground: erro da OpenAI (ex.: chave inválida) devolve ok:false com o erro bruto, nunca lança", async () => {
  await comFetchMockado({ ok: false, status: 401, corpo: { error: { message: "Incorrect API key provided: sk-proj-XXXXXXXXXXXXXXXXXXXXm50A." } } }, async () => {
    const resultado = await submeterResponseBackground({
      openaiKey: "sk-invalida",
      modelo: "gpt-6-astra",
      reasoningEffort: "high",
      maxOutputTokens: 12000,
      textoPrompt: "prompt",
      anexos: [],
    });
    assert.equal(resultado.ok, false);
    assert.equal(resultado.erroBruto.status, 401);
  });
});

test("M) buscarResponse: sucesso devolve o resultado completo (status queued/in_progress/completed etc.)", async () => {
  await comFetchMockado({ ok: true, corpo: { id: "resp_abc123", status: "completed", output: [] } }, async (getUltimaChamada) => {
    const resultado = await buscarResponse({ openaiKey: "sk-fake", responseId: "resp_abc123" });
    assert.equal(resultado.ok, true);
    assert.equal(resultado.resultado.status, "completed");
    assert.match(getUltimaChamada().url, /\/v1\/responses\/resp_abc123$/);
  });
});

test("N) buscarResponse: erro HTTP devolve ok:false, nunca lança", async () => {
  await comFetchMockado({ ok: false, status: 404, corpo: { error: { message: "Response não encontrada." } } }, async () => {
    const resultado = await buscarResponse({ openaiKey: "sk-fake", responseId: "resp_inexistente" });
    assert.equal(resultado.ok, false);
    assert.equal(resultado.erroBruto.status, 404);
  });
});

test("O) montarPromptContexto continua produzindo o mesmo formato/contrato de JSON esperado (regressão pós-mudança de local do arquivo)", () => {
  const prompt = montarPromptContexto(
    { concurso: "X", cargo: "Y", banca: "Z", materiaNome: "Matéria", conteudoNome: "Unidade" },
    [],
    [],
    [],
    { temMetadata: true, escopoAutorizado: "escopo", partesIrmasTitulos: [] },
    "bloco de jurisprudência",
  );
  assert.match(prompt, /Responda SOMENTE em JSON válido/);
  assert.match(prompt, /"componentes"/);
  assert.match(prompt, /"artigos_abordados"/);
  assert.equal(typeof PROMPT_VERSION, "string");
});
