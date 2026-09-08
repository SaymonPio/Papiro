// Fase 2B — testes do provider OpenAI, enriquecimento de metadata e
// classificacao pos-geracao. NENHUM teste aqui faz rede real: chamarOpenAI
// e sempre exercitado com fetchImpl injetado (Section 28 do mandato exige
// isso explicitamente). Nenhum teste le OPENAI_API_KEY nem qualquer
// segredo real.

import assert from "node:assert/strict";
import test from "node:test";
import {
  QUESTION_GENERATION_JSON_SCHEMA,
  QUESTION_GENERATION_SCHEMA_NAME,
  chamarOpenAI,
  construirRequestOpenAI,
  ehErroModeloIndisponivel,
  extrairRespostaEstruturada,
  montarPromptGerador,
} from "../scripts/curadoria-autoral/lib/openai-provider.mjs";
import { enriquecerQuestaoGerada, extrairSlotDoQuestionKey, gerarQuestionKey } from "../scripts/curadoria-autoral/lib/generation-enrichment.mjs";
import { STATUS_PRE_AUDITORIA, classificarQuestaoPreAuditoria, textoCompletoParaTripwires, verificarCoberturaDeSlots } from "../scripts/curadoria-autoral/lib/generation-audit.mjs";
import { classificarDuplicidade, compararContraHashesExistentes, hashTextoNormalizado } from "../scripts/curadoria-autoral/lib/duplicate-utils.mjs";
import { validarQuestaoGerada } from "../scripts/curadoria-autoral/lib/validador-questoes.mjs";

function payloadFixture() {
  return {
    run_id: "run-teste-2b",
    course: { id: "curso-1", slug: "curso-teste", name: "Curso Teste" },
    bank: { name: "Fundatec", resolution_status: "RESOLVED" },
    subject: { id: "6", name: "Língua Portuguesa" },
    content: { course_content_id: "18", subject_topic_id: "14", name: "Concordância verbal" },
    unit: { id: "unidade-1", title: "Concordância verbal" },
    lesson: { id: null, exists: false },
    coverage: { missing: 6 },
    generation: {
      quantity: 2,
      origin: "AUTORAL_PAPIRO",
      pedagogical_objectives: [
        { slot: 1, nucleo: "contraste HAVER x EXISTIR", objetivo: "distinguir impessoal de pessoal", dificuldade_sugerida: "media" },
        { slot: 2, nucleo: "FAZER tempo decorrido", objetivo: "reconhecer 3a pessoa singular impessoal", dificuldade_sugerida: "media" },
      ],
    },
    references: { real_question_ids: [{ question_id: "116", banca: "Fundatec", dificuldade: "media" }] },
    pedagogical_context: { scope: "Concordância verbal: escopo de teste, sem PII." },
    source: { status: "SOURCE_VALIDATED", validated_source_keys: ["fonte-teste"] },
    constraints: {
      requirements: ["exatamente 5 alternativas A-E"],
      prohibitions: ["Não tratar o verbo existir como impessoal.", "Não afirmar que todo uso de haver é impessoal.", "Não afirmar que todo uso de fazer é impessoal."],
    },
  };
}

test("1. construirRequestOpenAI: store=false sempre", () => {
  const req = construirRequestOpenAI({ model: "gpt-5.6-sol", reasoningEffort: "medium", promptText: "prompt de teste" });
  assert.equal(req.store, false);
});

test("2. construirRequestOpenAI: text.format.type=json_schema com strict=true (nunca json_object)", () => {
  const req = construirRequestOpenAI({ model: "gpt-5.6-sol", reasoningEffort: "medium", promptText: "prompt de teste" });
  assert.equal(req.text.format.type, "json_schema");
  assert.equal(req.text.format.strict, true);
  assert.equal(req.text.format.name, QUESTION_GENERATION_SCHEMA_NAME);
  assert.deepEqual(req.text.format.schema, QUESTION_GENERATION_JSON_SCHEMA);
  assert.notEqual(req.text.format.type, "json_object");
});

test("3. construirRequestOpenAI: tools sempre vazio (nenhuma ferramenta habilitada)", () => {
  const req = construirRequestOpenAI({ model: "gpt-5.6-sol", reasoningEffort: "medium", promptText: "prompt de teste" });
  assert.deepEqual(req.tools, []);
});

test("4. construirRequestOpenAI: reasoning.effort reflete exatamente o parametro recebido", () => {
  const req = construirRequestOpenAI({ model: "gpt-5.6-sol", reasoningEffort: "medium", promptText: "prompt de teste" });
  assert.equal(req.reasoning.effort, "medium");
});

test("5. construirRequestOpenAI: model nunca hardcoded — exige parametro explicito", () => {
  assert.throws(() => construirRequestOpenAI({ model: "", reasoningEffort: "medium", promptText: "x" }));
  assert.throws(() => construirRequestOpenAI({ reasoningEffort: "medium", promptText: "x" }));
});

test("6. QUESTION_GENERATION_JSON_SCHEMA: additionalProperties=false em todos os niveis de objeto (compat Structured Outputs strict)", () => {
  assert.equal(QUESTION_GENERATION_JSON_SCHEMA.additionalProperties, false);
  assert.equal(QUESTION_GENERATION_JSON_SCHEMA.properties.questions.items.additionalProperties, false);
  assert.equal(QUESTION_GENERATION_JSON_SCHEMA.properties.questions.items.properties.alternativas.items.additionalProperties, false);
  assert.equal(QUESTION_GENERATION_JSON_SCHEMA.properties.questions.items.properties.fundamento.additionalProperties, false);
});

test("7. QUESTION_GENERATION_JSON_SCHEMA: questions minItems=maxItems=2, slot enum [1,2]", () => {
  assert.equal(QUESTION_GENERATION_JSON_SCHEMA.properties.questions.minItems, 2);
  assert.equal(QUESTION_GENERATION_JSON_SCHEMA.properties.questions.maxItems, 2);
  assert.deepEqual(QUESTION_GENERATION_JSON_SCHEMA.properties.questions.items.properties.slot.enum, [1, 2]);
});

test("8. QUESTION_GENERATION_JSON_SCHEMA: schema NUNCA pede metadado trusted-side a IA (curso_id/unidade_id/run_id/model/question_key)", () => {
  const chaves = Object.keys(QUESTION_GENERATION_JSON_SCHEMA.properties.questions.items.properties);
  for (const proibida of ["curso_id", "unidade_id", "run_id", "model", "prompt_version", "question_key", "id", "curso_conteudo_id", "assunto_id"]) {
    assert.equal(chaves.includes(proibida), false, `schema nao pode pedir "${proibida}" a IA — e metadado trusted-side (Secao 9)`);
  }
});

test("9. montarPromptGerador: contem os dois slots, sem inverter, e NUNCA contem enunciado de questao REAL (payload so tem metadados)", () => {
  const prompt = montarPromptGerador(payloadFixture());
  assert.match(prompt, /SLOT 1[\s\S]*contraste HAVER x EXISTIR/);
  assert.match(prompt, /SLOT 2[\s\S]*FAZER tempo decorrido/);
  assert.match(prompt, /Não tratar o verbo existir como impessoal\./);
  // payload de teste so tem question_id/banca/dificuldade — nenhum enunciado.
  assert.equal(prompt.toLowerCase().includes("enunciado da questão 116"), false);
});

test("10. montarPromptGerador: exige exatamente 2 pedagogical_objectives com slots 1 e 2", () => {
  const payload = payloadFixture();
  payload.generation.pedagogical_objectives = [payload.generation.pedagogical_objectives[0]];
  assert.throws(() => montarPromptGerador(payload));
});

test("11. chamarOpenAI: usa fetchImpl injetado, nunca rede real, nunca serializa a apiKey no corpo", async () => {
  let chamadaCapturada = null;
  const fetchFalso = async (url, opts) => {
    chamadaCapturada = { url, opts };
    return { ok: true, status: 200, json: async () => ({ id: "resp_1", status: "completed", output: [] }) };
  };
  const resultado = await chamarOpenAI({ apiKey: "sk-segredo-de-teste-nao-real", requestBody: { model: "gpt-5.6-sol" }, fetchImpl: fetchFalso });
  assert.equal(resultado.ok, true);
  assert.equal(chamadaCapturada.url, "https://api.openai.com/v1/responses");
  assert.equal(chamadaCapturada.opts.headers.Authorization, "Bearer sk-segredo-de-teste-nao-real");
  // a chave so pode aparecer no header Authorization — nunca no corpo serializado.
  assert.equal(chamadaCapturada.opts.body.includes("sk-segredo-de-teste-nao-real"), false);
});

test("12. extrairRespostaEstruturada: extrai metadata segura (nunca Authorization/apiKey) e faz parse do JSON estruturado", () => {
  const corpo = {
    id: "resp_123",
    status: "completed",
    model: "gpt-5.6-sol",
    created_at: 1700000000,
    service_tier: "default",
    usage: { input_tokens: 100, output_tokens: 50, total_tokens: 150 },
    output: [{ content: [{ type: "output_text", text: JSON.stringify({ questions: [] }) }] }],
  };
  const extraida = extrairRespostaEstruturada(corpo);
  assert.equal(extraida.response_id, "resp_123");
  assert.equal(extraida.usage.total_tokens, 150);
  assert.equal(extraida.jsonInvalido, false);
  assert.deepEqual(extraida.dados, { questions: [] });
  assert.equal("Authorization" in extraida, false);
  assert.equal("apiKey" in extraida, false);
});

test("13. extrairRespostaEstruturada: JSON invalido nao lanca excecao, so sinaliza jsonInvalido", () => {
  const corpo = {
    id: "resp_x",
    output: [{ content: [{ type: "output_text", text: "{isto nao e json valido" }] }],
  };
  const extraida = extrairRespostaEstruturada(corpo);
  assert.equal(extraida.jsonInvalido, true);
  assert.equal(extraida.motivo, "JSON_PARSE_FAILED");
});

test("14. extrairRespostaEstruturada: sem output_text sinaliza SEM_OUTPUT_TEXT", () => {
  const extraida = extrairRespostaEstruturada({ id: "resp_y", output: [] });
  assert.equal(extraida.jsonInvalido, true);
  assert.equal(extraida.motivo, "SEM_OUTPUT_TEXT");
});

test("15. ehErroModeloIndisponivel reconhece mensagens tipicas de modelo inexistente/sem acesso", () => {
  assert.equal(ehErroModeloIndisponivel("The model `gpt-9000` does not exist"), true);
  assert.equal(ehErroModeloIndisponivel("model_not_found"), true);
  assert.equal(ehErroModeloIndisponivel("Rate limit exceeded"), false);
});

test("16. gerarQuestionKey / extrairSlotDoQuestionKey: deterministico e reversivel, nunca id de banco", () => {
  assert.equal(gerarQuestionKey("run-abc", 1), "run-abc:q01");
  assert.equal(gerarQuestionKey("run-abc", 2), "run-abc:q02");
  assert.equal(extrairSlotDoQuestionKey("run-abc:q01"), 1);
  assert.equal(extrairSlotDoQuestionKey("run-abc:q02"), 2);
  assert.equal(extrairSlotDoQuestionKey("questao-banco-123"), null);
});

test("17. enriquecerQuestaoGerada: TODO metadado trusted-side vem do payload/runtime, NUNCA da IA (mesmo se a IA tentar injetar)", () => {
  const payload = payloadFixture();
  const questaoBrutaComTentativaDeInjecao = {
    slot: 1,
    enunciado: "Assinale a alternativa correta quanto à concordância.",
    alternativas: [{ letra: "A", texto: "x" }, { letra: "B", texto: "y" }, { letra: "C", texto: "z" }, { letra: "D", texto: "w" }, { letra: "E", texto: "v" }],
    gabarito: "A",
    explicacao: "explicação de teste",
    fundamento: { tipo: "regra_gramatical", referencia: "concordância verbal", descricao: "descrição de teste" },
    dificuldade: "media",
    justificativa_aderencia: "adere ao slot 1",
    riscos_identificados: [],
    // campos que a IA NAO deveria conseguir controlar (Structured Outputs strict ja bloqueia isso,
    // mas o teste prova que MESMO SE aparecessem, enriquecerQuestaoGerada os ignora):
    curso_id: "CURSO-FALSO-INJETADO-PELA-IA",
    unidade_id: "UNIDADE-FALSA-INJETADA-PELA-IA",
    run_id: "run-falso-injetado",
    id: 999999,
  };

  const enriquecida = enriquecerQuestaoGerada({
    questaoBruta: questaoBrutaComTentativaDeInjecao,
    payload,
    runId: "run-real-do-pipeline",
    model: "gpt-5.6-sol",
    promptVersion: "papiro-question-generator-v1",
    generatedAt: "2026-09-08T00:00:00Z",
  });

  assert.equal(enriquecida.run_id, "run-real-do-pipeline");
  assert.equal(enriquecida.curso_id, payload.course.id);
  assert.equal(enriquecida.unidade_id, payload.unit.id);
  assert.equal(enriquecida.question_key, "run-real-do-pipeline:q01");
  assert.equal("id" in enriquecida, false, "id de banco nunca pode aparecer na questao enriquecida");
  assert.notEqual(enriquecida.curso_id, "CURSO-FALSO-INJETADO-PELA-IA");
  assert.notEqual(enriquecida.unidade_id, "UNIDADE-FALSA-INJETADA-PELA-IA");
});

test("18. enriquecerQuestaoGerada + validarQuestaoGerada: uma questao bem formada passa no validador estrutural local", () => {
  const payload = payloadFixture();
  const questaoBruta = {
    slot: 2,
    enunciado: "Assinale a alternativa correta.",
    alternativas: [{ letra: "A", texto: "a" }, { letra: "B", texto: "b" }, { letra: "C", texto: "c" }, { letra: "D", texto: "d" }, { letra: "E", texto: "e" }],
    gabarito: "B",
    explicacao: "explicação suficiente",
    fundamento: { tipo: "regra_gramatical", referencia: "fazer impessoal", descricao: "descrição suficiente" },
    dificuldade: "media",
    justificativa_aderencia: "adere ao slot 2",
    riscos_identificados: [],
  };
  const enriquecida = enriquecerQuestaoGerada({ questaoBruta, payload, runId: "run-x", model: "gpt-5.6-sol", promptVersion: "v1", generatedAt: "2026-09-08T00:00:00Z" });
  const validacao = validarQuestaoGerada(enriquecida);
  assert.equal(validacao.ok, true, JSON.stringify(validacao.errors));
});

test("19. classificarQuestaoPreAuditoria: hard gate estrutural falho -> REJECTED_PRE_AUDIT (nunca APROVADA)", () => {
  const validacaoEstrutural = { ok: false, errors: [{ codigo: "EMPTY_ENUNCIADO", mensagem: "x" }], warnings: [] };
  const questaoEnriquecida = { question_key: "run:q01", enunciado: "", alternativas: [], explicacao: "", fundamento: {} };
  const resultado = classificarQuestaoPreAuditoria({ questaoEnriquecida, validacaoEstrutural, slotEsperado: 1 });
  assert.equal(resultado.status, STATUS_PRE_AUDITORIA.REJECTED_PRE_AUDIT);
  assert.ok(resultado.reason_codes.includes("EMPTY_ENUNCIADO"));
});

test("20. classificarQuestaoPreAuditoria: tripwire gramatical falho -> REJECTED_PRE_AUDIT (nao negociavel por revisao leve)", () => {
  const validacaoEstrutural = { ok: true, errors: [], warnings: [] };
  const questaoEnriquecida = {
    question_key: "run:q01",
    enunciado: "Sobre concordância: existir é impessoal.",
    alternativas: [{ texto: "a" }],
    explicacao: "explicação",
    fundamento: { descricao: "x" },
  };
  const resultado = classificarQuestaoPreAuditoria({ questaoEnriquecida, validacaoEstrutural, slotEsperado: 1 });
  assert.equal(resultado.status, STATUS_PRE_AUDITORIA.REJECTED_PRE_AUDIT);
  assert.ok(resultado.reason_codes.includes("EXISTIR_TRATADO_COMO_IMPESSOAL"));
  assert.equal(resultado.tripwires.existir, "FAIL");
});

test("21. classificarQuestaoPreAuditoria: estrutura+tripwires OK e slot correto -> STRUCTURALLY_VALID_FOR_AUDIT (nunca APROVADA_FINAL)", () => {
  const validacaoEstrutural = { ok: true, errors: [], warnings: [] };
  const questaoEnriquecida = {
    question_key: "run:q01",
    enunciado: "Em \"Há problemas.\" o haver (sentido de existir/ocorrer) é impessoal; em \"Existem problemas.\" o existir é pessoal.",
    alternativas: [{ texto: "a" }],
    explicacao: "explicação suficiente",
    fundamento: { descricao: "descrição suficiente" },
  };
  const resultado = classificarQuestaoPreAuditoria({ questaoEnriquecida, validacaoEstrutural, slotEsperado: 1 });
  assert.equal(resultado.status, STATUS_PRE_AUDITORIA.STRUCTURALLY_VALID_FOR_AUDIT);
  assert.deepEqual(resultado.reason_codes, []);
  assert.notEqual(resultado.status, "APROVADA_FINAL");
});

test("22. classificarQuestaoPreAuditoria: slot trocado -> REVIEW_REQUIRED_PRE_AUDIT", () => {
  const validacaoEstrutural = { ok: true, errors: [], warnings: [] };
  const questaoEnriquecida = { question_key: "run:q01", enunciado: "texto neutro sem verbos sensiveis", alternativas: [{ texto: "a" }], explicacao: "e", fundamento: { descricao: "d" } };
  const resultado = classificarQuestaoPreAuditoria({ questaoEnriquecida, validacaoEstrutural, slotEsperado: 2 });
  assert.equal(resultado.status, STATUS_PRE_AUDITORIA.REVIEW_REQUIRED_PRE_AUDIT);
  assert.ok(resultado.reason_codes.includes("SLOT_MISMATCH"));
});

test("23. verificarCoberturaDeSlots: cobre {1,2} sem repeticao -> ok; repeticao/ausencia -> nao ok", () => {
  assert.equal(verificarCoberturaDeSlots([{ question_key: "r:q01" }, { question_key: "r:q02" }]).ok, true);
  assert.equal(verificarCoberturaDeSlots([{ question_key: "r:q01" }, { question_key: "r:q01" }]).ok, false);
});

test("24. compararContraHashesExistentes: deteccao por hash contra baseline sem exigir texto bruto do candidato", () => {
  const textoExistenteReal = "Assinale a frase correta.";
  const baseline = [{ id: 116, texto_normalizado_hash: hashTextoNormalizado(textoExistenteReal) }];
  const identico = compararContraHashesExistentes(textoExistenteReal, baseline);
  assert.equal(identico.codigo, "EXACT_TEXT_DUPLICATE");
  assert.equal(identico.camada_3_indisponivel, true);

  const diferente = compararContraHashesExistentes("Um enunciado completamente diferente sobre outro tema.", baseline);
  assert.equal(diferente.codigo, null);
});

test("25. nenhum segredo aparece serializado em nenhuma estrutura produzida por este modulo (payload/prompt/request/resposta extraida)", () => {
  const payload = payloadFixture();
  const prompt = montarPromptGerador(payload);
  const req = construirRequestOpenAI({ model: "gpt-5.6-sol", reasoningEffort: "medium", promptText: prompt });
  const extraida = extrairRespostaEstruturada({ id: "resp_z", output: [{ content: [{ type: "output_text", text: JSON.stringify({ questions: [] }) }] }] });

  const serializado = JSON.stringify({ payload, prompt, req, extraida }).toLowerCase();
  for (const termoProibido of ["openai_api_key", "authorization", "bearer ", "sk-", "service_role", "supabase_db_url"]) {
    assert.equal(serializado.includes(termoProibido), false, `estrutura nao pode conter "${termoProibido}"`);
  }
});

// Fase 2B.1 (Secao 4) — achado real na primeira geracao: cli/gerar-questoes.mjs
// comparava as 2 questoes irmas passando `mesmaUnidade: true` para
// classificarDuplicidade, o que e tautologico (duas questoes do MESMO
// payload SEMPRE sao da mesma unidade) e fazia TODO par de irmas cair em
// SEMANTIC_REVIEW_REQUIRED, mesmo cobrindo nucleos pedagogicos
// completamente distintos (HAVERxEXISTIR vs FAZER). A correcao: parar de
// passar `mesmaUnidade` na comparacao entre irmas — sobra so o sinal
// lexical real (hash exato/normalizado ou Jaccard >= limiar), exigido pelo
// mandato como "sinal adicional".

test("26. siblings da MESMA unidade, sem overlap lexical relevante, NAO geram review automatico (correcao Fase 2B.1)", () => {
  const textoIrmaSemMesmaUnidade = (id, texto) => ({ id, texto }); // sem `mesmaUnidade` — exatamente como o CLI corrigido chama agora

  // Textos reais gerados na primeira execucao (Q1: HAVER x EXISTIR; Q2: FAZER tempo decorrido) —
  // nucleos pedagogicos distintos, sem duplicidade textual real.
  const textoQ1 =
    'De acordo com a norma-padrão, assinale a alternativa que preenche corretamente as lacunas da frase: "Na avaliação da comissão, ainda ______ falhas no plano, mas também ______ alternativas viáveis para corrigi-las." ' +
    "Em \"pode haver falhas\", o verbo haver tem sentido de existir e, por isso, é impessoal.";
  const textoQ2 =
    'Assinale a alternativa que preenche corretamente as lacunas da frase: "Pelos registros, ______ quatro meses que terminou a última capacitação; desde então, os instrutores ______ atividades de revisão semanalmente." ' +
    "Na primeira oração, fazer indica tempo decorrido e é impessoal.";

  const resultado = classificarDuplicidade(textoQ1, [textoIrmaSemMesmaUnidade("q02", textoQ2)]);
  assert.equal(resultado.codigo, null, "nucleos pedagogicos distintos (HAVERxEXISTIR vs FAZER) nao podem gerar SEMANTIC_REVIEW_REQUIRED so por serem da mesma unidade");
});

test("27. siblings COM overlap lexical real continuam sinalizados (a correcao nao afrouxa demais)", () => {
  const textoA = "Assinale a alternativa correta quanto à concordância verbal do verbo haver no sentido existencial.";
  const textoB = "Assinale a alternativa correta quanto à concordância verbal do verbo haver no sentido existencial, com outro exemplo.";
  const resultado = classificarDuplicidade(textoA, [{ id: "irma", texto: textoB }]);
  assert.ok(["EXACT_TEXT_DUPLICATE", "NORMALIZED_TEXT_DUPLICATE", "HIGH_LEXICAL_SIMILARITY"].includes(resultado.codigo), "overlap lexical alto real precisa continuar sinalizado");
});

test("28. REGRESSAO real: Q1 e Q2 da primeira geracao (Fase 2B) — apos as correcoes, ambas ficam STRUCTURALLY_VALID_FOR_AUDIT", () => {
  const q1 = {
    question_key: "bf102ce7-4abb-4d2f-b4fb-47fac3b156ab:q01",
    enunciado:
      'De acordo com a norma-padrão, assinale a alternativa que preenche corretamente as lacunas da frase: "Na avaliação da comissão, ainda ______ falhas no plano, mas também ______ alternativas viáveis para corrigi-las."',
    alternativas: [
      { letra: "A", texto: "podem haver — pode existir" },
      { letra: "B", texto: "pode haver — podem existir" },
      { letra: "C", texto: "podem haver — podem existir" },
      { letra: "D", texto: "pode haver — pode existir" },
      { letra: "E", texto: "podem haver — podem existirem" },
    ],
    explicacao:
      'Em "pode haver falhas", o verbo haver tem sentido de existir e, por isso, é impessoal. Ele permanece na terceira pessoa do singular, e essa impessoalidade alcança o auxiliar da locução: "pode haver", e não "podem haver". Já existir é verbo pessoal e concorda normalmente com seu sujeito.',
    fundamento: {
      descricao:
        "Haver, quando empregado com sentido de existir, ocorrer ou acontecer, é impessoal e permanece na terceira pessoa do singular, inclusive quanto ao auxiliar de uma locução verbal. Existir é verbo pessoal e concorda normalmente com o núcleo de seu sujeito.",
    },
  };
  const q2 = {
    question_key: "bf102ce7-4abb-4d2f-b4fb-47fac3b156ab:q02",
    enunciado:
      'Assinale a alternativa que preenche corretamente as lacunas da frase: "Pelos registros, ______ quatro meses que terminou a última capacitação; desde então, os instrutores ______ atividades de revisão semanalmente."',
    alternativas: [
      { letra: "A", texto: "devem fazer — fazem" },
      { letra: "B", texto: "deve fazer — fazem" },
      { letra: "C", texto: "deve fazer — faz" },
      { letra: "D", texto: "devem fazer — faz" },
      { letra: "E", texto: "fazem — fazem" },
    ],
    explicacao:
      'Na primeira oração, fazer indica tempo decorrido e é impessoal. Assim, permanece na terceira pessoa do singular. Na locução "deve fazer", o auxiliar também fica no singular; "quatro meses" expressa o tempo transcorrido e não funciona como sujeito. Na segunda oração, fazer apresenta uso pessoal: o sujeito é "os instrutores".',
    fundamento: {
      descricao: "Fazer é impessoal quando indica tempo decorrido ou fenômeno atmosférico, permanecendo na terceira pessoa do singular. Em outros sentidos, pode ser pessoal e deve concordar normalmente com seu sujeito.",
    },
  };
  const validacaoEstrutural = { ok: true, errors: [], warnings: [] };

  const textoQ1 = textoCompletoParaTripwires(q1);
  const textoQ2 = textoCompletoParaTripwires(q2);
  const dupQ1vsQ2 = classificarDuplicidade(textoQ1, [{ id: q2.question_key, texto: textoQ2 }]);
  const dupQ2vsQ1 = classificarDuplicidade(textoQ2, [{ id: q1.question_key, texto: textoQ1 }]);

  const resultadoQ1 = classificarQuestaoPreAuditoria({
    questaoEnriquecida: q1,
    validacaoEstrutural,
    slotEsperado: 1,
    duplicidadeContraIrma: dupQ1vsQ2,
  });
  const resultadoQ2 = classificarQuestaoPreAuditoria({
    questaoEnriquecida: q2,
    validacaoEstrutural,
    slotEsperado: 2,
    duplicidadeContraIrma: dupQ2vsQ1,
  });

  assert.equal(resultadoQ1.status, STATUS_PRE_AUDITORIA.STRUCTURALLY_VALID_FOR_AUDIT, `Q1 deveria passar apos a correcao; motivos: ${resultadoQ1.reason_codes}`);
  assert.equal(resultadoQ2.status, STATUS_PRE_AUDITORIA.STRUCTURALLY_VALID_FOR_AUDIT, `Q2 deveria passar apos a correcao; motivos: ${resultadoQ2.reason_codes}`);
});
