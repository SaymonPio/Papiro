// Fase 2C — testes da auditoria independente (Blind Solver + Full
// Critic). NENHUM teste aqui faz rede real. Nenhum teste le OPENAI_API_KEY
// nem qualquer segredo real.

import assert from "node:assert/strict";
import test from "node:test";
import {
  BLIND_SOLVER_JSON_SCHEMA,
  FULL_CRITIC_JSON_SCHEMA,
  NOMES_CHECKS_CRITIC,
  montarPromptAuditorBlind,
  montarPromptAuditorCritic,
  sanitizarQuestaoParaBlindSolver,
} from "../scripts/curadoria-autoral/lib/openai-audit-provider.mjs";
import {
  STATUS_AUDITORIA_FINAL,
  agregarResultadoAuditoria,
  compararRespostaBlind,
  validarRespostaBlindLocalmente,
  validarRespostaCriticLocalmente,
} from "../scripts/curadoria-autoral/lib/audit-orchestrator.mjs";
import { construirRequestOpenAI } from "../scripts/curadoria-autoral/lib/openai-provider.mjs";

function payloadFixture() {
  return {
    run_id: "run-audit-teste",
    course: { id: "curso-1", slug: "curso-teste", name: "Curso Teste" },
    bank: { name: "Fundatec" },
    subject: { name: "Língua Portuguesa" },
    unit: { title: "Concordância verbal" },
    pedagogical_context: { scope: "Escopo de teste, sem PII, sem gabarito." },
    source: { validated_source_keys: ["fonte-teste"] },
  };
}

function questaoCompletaFixture(slot, gabarito) {
  return {
    question_key: `run-audit-teste:q0${slot}`,
    slot,
    enunciado: `Enunciado de teste do slot ${slot}.`,
    alternativas: [
      { letra: "A", texto: "a" },
      { letra: "B", texto: "b" },
      { letra: "C", texto: "c" },
      { letra: "D", texto: "d" },
      { letra: "E", texto: "e" },
    ],
    gabarito,
    explicacao: `Explicação de teste do slot ${slot}.`,
    fundamento: { tipo: "regra_gramatical", referencia: "x", descricao: "y" },
    dificuldade: "media",
    justificativa_aderencia: "adere",
    riscos_identificados: [],
    status_pre_auditoria: "STRUCTURALLY_VALID_FOR_AUDIT",
  };
}

function criticChecksTodosPass() {
  return NOMES_CHECKS_CRITIC.map((check) => ({ check, status: "PASS", severity: "NONE", reason: "ok" }));
}

test("1. sanitizarQuestaoParaBlindSolver: NUNCA inclui gabarito/explicacao/fundamento/justificativa_aderencia/riscos/status", () => {
  const completa = questaoCompletaFixture(1, "B");
  const sanitizada = sanitizarQuestaoParaBlindSolver(completa, 1);
  for (const chave of ["gabarito", "explicacao", "fundamento", "justificativa_aderencia", "riscos_identificados", "status_pre_auditoria"]) {
    assert.equal(chave in sanitizada, false, `campo proibido "${chave}" vazou para o payload do Auditor A`);
  }
  assert.equal(sanitizada.enunciado, completa.enunciado);
  assert.deepEqual(sanitizada.alternativas, completa.alternativas);
  assert.equal(sanitizada.dificuldade, completa.dificuldade);
});

test("2. montarPromptAuditorBlind: prompt NAO contem gabarito/explicacao/fundamento das questoes", () => {
  const q1 = questaoCompletaFixture(1, "B");
  const q2 = questaoCompletaFixture(2, "C");
  const sanitizadas = [sanitizarQuestaoParaBlindSolver(q1, 1), sanitizarQuestaoParaBlindSolver(q2, 2)];
  const prompt = montarPromptAuditorBlind(payloadFixture(), sanitizadas);
  // O prompt PODE instruir o modelo dizendo que ele "não recebeu gabarito"
  // (framing legítimo) — o que nunca pode acontecer é o VALOR do gabarito
  // aparecer associado a uma questao (ex.: "Gabarito declarado: B", o
  // mesmo formato usado no prompt do critic).
  assert.equal(/gabarito\s*(declarado)?\s*:\s*[A-E]\b/i.test(prompt), false, "prompt do blind solver nao pode revelar o VALOR do gabarito de nenhuma questao");
  assert.equal(prompt.includes(q1.explicacao), false);
  assert.equal(prompt.includes(q2.explicacao), false);
  assert.equal(prompt.includes(JSON.stringify(q1.fundamento)), false);
  assert.match(prompt, /QUESTÃO 1/);
  assert.match(prompt, /QUESTÃO 2/);
});

test("3. montarPromptAuditorCritic: prompt tem gabarito/explicacao/fundamento, mas NUNCA menciona resultado do Auditor A", () => {
  const q1 = questaoCompletaFixture(1, "B");
  const q2 = questaoCompletaFixture(2, "C");
  const prompt = montarPromptAuditorCritic(payloadFixture(), [q1, q2]);
  assert.match(prompt, /Gabarito declarado: B/);
  assert.match(prompt, /Gabarito declarado: C/);
  assert.match(prompt, new RegExp(q1.explicacao));
  // nada que sugira o output do blind solver (independent_answer, ambiguity, blind, auditor a, etc.)
  for (const termoProibido of ["independent_answer", "blind solver", "auditor a", "blind_", "unique_answer"]) {
    assert.equal(prompt.toLowerCase().includes(termoProibido), false, `prompt do critic nao pode mencionar "${termoProibido}" (vazamento do Auditor A)`);
  }
});

test("4. schemas Structured Outputs: additionalProperties=false em todos os niveis, exatamente 2 itens, 12 checks", () => {
  assert.equal(BLIND_SOLVER_JSON_SCHEMA.additionalProperties, false);
  assert.equal(BLIND_SOLVER_JSON_SCHEMA.properties.answers.minItems, 2);
  assert.equal(BLIND_SOLVER_JSON_SCHEMA.properties.answers.maxItems, 2);
  assert.equal(BLIND_SOLVER_JSON_SCHEMA.properties.answers.items.additionalProperties, false);

  assert.equal(FULL_CRITIC_JSON_SCHEMA.additionalProperties, false);
  assert.equal(FULL_CRITIC_JSON_SCHEMA.properties.audits.items.properties.checks.minItems, 12);
  assert.equal(FULL_CRITIC_JSON_SCHEMA.properties.audits.items.properties.checks.maxItems, 12);
  assert.equal(FULL_CRITIC_JSON_SCHEMA.properties.audits.items.properties.checks.items.additionalProperties, false);
});

test("5. construirRequestOpenAI aceita schema/schemaName customizados (reuso do provider da Fase 2B, sem duplicar)", () => {
  const req = construirRequestOpenAI({ model: "gpt-5.6-sol", reasoningEffort: "high", promptText: "x", schemaName: "custom_schema", schema: { type: "object" } });
  assert.equal(req.text.format.name, "custom_schema");
  assert.deepEqual(req.text.format.schema, { type: "object" });
  assert.equal(req.store, false);
  assert.deepEqual(req.tools, []);
});

test("6. validarRespostaBlindLocalmente: exige exatamente 2 respostas com slots {1,2} e enums validos", () => {
  const boa = { answers: [
    { slot: 1, independent_answer: "B", unique_answer: true, ambiguity: "NONE", rule_applied: "x", reasoning_summary: "y", difficulty_observed: "media", confidence: "HIGH", issues: [] },
    { slot: 2, independent_answer: "C", unique_answer: true, ambiguity: "NONE", rule_applied: "x", reasoning_summary: "y", difficulty_observed: "media", confidence: "HIGH", issues: [] },
  ]};
  assert.equal(validarRespostaBlindLocalmente(boa).ok, true);

  const slotsRepetidos = { answers: [boa.answers[0], boa.answers[0]] };
  assert.equal(validarRespostaBlindLocalmente(slotsRepetidos).ok, false);

  const enumInvalido = { answers: [{ ...boa.answers[0], independent_answer: "Z" }, boa.answers[1]] };
  assert.equal(validarRespostaBlindLocalmente(enumInvalido).ok, false);
});

test("7. validarRespostaCriticLocalmente: exige exatamente 12 checks distintas por questao", () => {
  const boa = { audits: [
    { slot: 1, checks: criticChecksTodosPass(), critical_findings: [], recommended_action: "PASS_TO_HUMAN", summary: "ok" },
    { slot: 2, checks: criticChecksTodosPass(), critical_findings: [], recommended_action: "PASS_TO_HUMAN", summary: "ok" },
  ]};
  assert.equal(validarRespostaCriticLocalmente(boa).ok, true);

  const checksFaltando = { audits: [
    { slot: 1, checks: criticChecksTodosPass().slice(0, 10), critical_findings: [], recommended_action: "PASS_TO_HUMAN", summary: "ok" },
    boa.audits[1],
  ]};
  assert.equal(validarRespostaCriticLocalmente(checksFaltando).ok, false);

  const checkDuplicada = { audits: [
    { slot: 1, checks: [...criticChecksTodosPass().slice(0, 11), criticChecksTodosPass()[0]], critical_findings: [], recommended_action: "PASS_TO_HUMAN", summary: "ok" },
    boa.audits[1],
  ]};
  assert.equal(validarRespostaCriticLocalmente(checkDuplicada).ok, false);
});

test("8. compararRespostaBlind: match/mismatch/ambiguidade/confidence/unicidade, tudo calculado localmente", () => {
  const match = compararRespostaBlind({ independentAnswer: "B", gabaritoDeclarado: "B", ambiguity: "NONE", confidence: "HIGH", uniqueAnswer: true });
  assert.equal(match.match, true);
  assert.deepEqual(match.reason_codes, ["BLIND_KEY_MATCH"]);

  const mismatch = compararRespostaBlind({ independentAnswer: "A", gabaritoDeclarado: "B", ambiguity: "NONE", confidence: "HIGH", uniqueAnswer: true });
  assert.equal(mismatch.match, false);
  assert.ok(mismatch.reason_codes.includes("BLIND_KEY_MISMATCH"));

  const ambiguo = compararRespostaBlind({ independentAnswer: "B", gabaritoDeclarado: "B", ambiguity: "MATERIAL", confidence: "HIGH", uniqueAnswer: true });
  assert.ok(ambiguo.reason_codes.includes("BLIND_AMBIGUITY_MATERIAL"));

  const baixaConfianca = compararRespostaBlind({ independentAnswer: "B", gabaritoDeclarado: "B", ambiguity: "NONE", confidence: "LOW", uniqueAnswer: true });
  assert.ok(baixaConfianca.reason_codes.includes("BLIND_CONFIDENCE_LOW"));

  const naoUnica = compararRespostaBlind({ independentAnswer: "B", gabaritoDeclarado: "B", ambiguity: "NONE", confidence: "HIGH", uniqueAnswer: false });
  assert.equal(naoUnica.unique, false);
});

test("9. agregarResultadoAuditoria: BLIND_KEY_MISMATCH => AUDIT_REJECTED", () => {
  const blindComparison = compararRespostaBlind({ independentAnswer: "A", gabaritoDeclarado: "B", ambiguity: "NONE", confidence: "HIGH", uniqueAnswer: true });
  const resultado = agregarResultadoAuditoria({ blindComparison, criticChecks: criticChecksTodosPass(), criticalFindings: [], recommendedAction: "PASS_TO_HUMAN" });
  assert.equal(resultado.status, STATUS_AUDITORIA_FINAL.AUDIT_REJECTED);
  assert.ok(resultado.reason_codes.includes("AGGREGATION_BLIND_MISMATCH"));
});

test("10. agregarResultadoAuditoria: ambiguity MATERIAL => AUDIT_REJECTED mesmo com match", () => {
  const blindComparison = compararRespostaBlind({ independentAnswer: "B", gabaritoDeclarado: "B", ambiguity: "MATERIAL", confidence: "HIGH", uniqueAnswer: true });
  const resultado = agregarResultadoAuditoria({ blindComparison, criticChecks: criticChecksTodosPass(), criticalFindings: [], recommendedAction: "PASS_TO_HUMAN" });
  assert.equal(resultado.status, STATUS_AUDITORIA_FINAL.AUDIT_REJECTED);
  assert.ok(resultado.reason_codes.includes("AGGREGATION_MATERIAL_AMBIGUITY"));
});

test("11. agregarResultadoAuditoria: match + tudo PASS + confidence HIGH => AUDIT_PASS_TO_HUMAN (nunca aprovada final)", () => {
  const blindComparison = compararRespostaBlind({ independentAnswer: "B", gabaritoDeclarado: "B", ambiguity: "NONE", confidence: "HIGH", uniqueAnswer: true });
  const resultado = agregarResultadoAuditoria({ blindComparison, criticChecks: criticChecksTodosPass(), criticalFindings: [], recommendedAction: "PASS_TO_HUMAN" });
  assert.equal(resultado.status, STATUS_AUDITORIA_FINAL.AUDIT_PASS_TO_HUMAN);
  assert.notEqual(resultado.status, "APROVADA_FINAL");
});

test("12. agregarResultadoAuditoria: check CORRECAO_FATUAL_GRAMATICAL FAIL (qualquer severidade) => AUDIT_REJECTED", () => {
  const blindComparison = compararRespostaBlind({ independentAnswer: "B", gabaritoDeclarado: "B", ambiguity: "NONE", confidence: "HIGH", uniqueAnswer: true });
  const checks = criticChecksTodosPass().map((c) => (c.check === "CORRECAO_FATUAL_GRAMATICAL" ? { ...c, status: "FAIL", severity: "LOW" } : c));
  const resultado = agregarResultadoAuditoria({ blindComparison, criticChecks: checks, criticalFindings: [], recommendedAction: "PASS_TO_HUMAN" });
  assert.equal(resultado.status, STATUS_AUDITORIA_FINAL.AUDIT_REJECTED);
  assert.ok(resultado.reason_codes.includes("CRITIC_FAIL_CORRECAO_FATUAL_GRAMATICAL"));
});

test("13. agregarResultadoAuditoria: check qualquer FAIL severity CRITICAL => AUDIT_REJECTED", () => {
  const blindComparison = compararRespostaBlind({ independentAnswer: "B", gabaritoDeclarado: "B", ambiguity: "NONE", confidence: "HIGH", uniqueAnswer: true });
  const checks = criticChecksTodosPass().map((c) => (c.check === "ESTILO_BANCA_COMPATIVEL" ? { ...c, status: "FAIL", severity: "CRITICAL" } : c));
  const resultado = agregarResultadoAuditoria({ blindComparison, criticChecks: checks, criticalFindings: [], recommendedAction: "PASS_TO_HUMAN" });
  assert.equal(resultado.status, STATUS_AUDITORIA_FINAL.AUDIT_REJECTED);
});

test("14. agregarResultadoAuditoria: check REVIEW ou FAIL severity HIGH (nao critico) => AUDIT_REVIEW_REQUIRED, nunca reject", () => {
  const blindComparison = compararRespostaBlind({ independentAnswer: "B", gabaritoDeclarado: "B", ambiguity: "NONE", confidence: "HIGH", uniqueAnswer: true });
  const checksReview = criticChecksTodosPass().map((c) => (c.check === "DISTRATORES_DEFENSAVEIS" ? { ...c, status: "REVIEW", severity: "LOW" } : c));
  const resultadoReview = agregarResultadoAuditoria({ blindComparison, criticChecks: checksReview, criticalFindings: [], recommendedAction: "PASS_TO_HUMAN" });
  assert.equal(resultadoReview.status, STATUS_AUDITORIA_FINAL.AUDIT_REVIEW_REQUIRED);

  const checksHighFail = criticChecksTodosPass().map((c) => (c.check === "ESTILO_BANCA_COMPATIVEL" ? { ...c, status: "FAIL", severity: "HIGH" } : c));
  const resultadoHigh = agregarResultadoAuditoria({ blindComparison, criticChecks: checksHighFail, criticalFindings: [], recommendedAction: "PASS_TO_HUMAN" });
  assert.equal(resultadoHigh.status, STATUS_AUDITORIA_FINAL.AUDIT_REVIEW_REQUIRED);
});

test("15. agregarResultadoAuditoria: recommended_action=REJECT da IA, SEM base local, so escala para REVIEW (Secao 15 — IA nunca decide sozinha)", () => {
  const blindComparison = compararRespostaBlind({ independentAnswer: "B", gabaritoDeclarado: "B", ambiguity: "NONE", confidence: "HIGH", uniqueAnswer: true });
  const resultado = agregarResultadoAuditoria({ blindComparison, criticChecks: criticChecksTodosPass(), criticalFindings: [], recommendedAction: "REJECT" });
  assert.equal(resultado.status, STATUS_AUDITORIA_FINAL.AUDIT_REVIEW_REQUIRED, "recommended_action sozinho nao pode produzir AUDIT_REJECTED sem check/blind concreto");
  assert.ok(resultado.reason_codes.includes("CRITIC_RECOMMENDED_REJECT_WITHOUT_LOCAL_BASIS"));
});

test("16. agregarResultadoAuditoria: recommended_action=REJECT COM base local real => reforca o reject (nao ignorado)", () => {
  const blindComparison = compararRespostaBlind({ independentAnswer: "A", gabaritoDeclarado: "B", ambiguity: "NONE", confidence: "HIGH", uniqueAnswer: true });
  const resultado = agregarResultadoAuditoria({ blindComparison, criticChecks: criticChecksTodosPass(), criticalFindings: [], recommendedAction: "REJECT" });
  assert.equal(resultado.status, STATUS_AUDITORIA_FINAL.AUDIT_REJECTED);
  assert.ok(resultado.reason_codes.includes("CRITIC_RECOMMENDED_REJECT"));
});

test("17. agregarResultadoAuditoria: critical_findings nao vazio => AUDIT_REJECTED", () => {
  const blindComparison = compararRespostaBlind({ independentAnswer: "B", gabaritoDeclarado: "B", ambiguity: "NONE", confidence: "HIGH", uniqueAnswer: true });
  const resultado = agregarResultadoAuditoria({ blindComparison, criticChecks: criticChecksTodosPass(), criticalFindings: ["problema grave achado"], recommendedAction: "PASS_TO_HUMAN" });
  assert.equal(resultado.status, STATUS_AUDITORIA_FINAL.AUDIT_REJECTED);
});

test("18. nenhum segredo aparece serializado nos prompts/requests da auditoria", () => {
  const payload = payloadFixture();
  const q1 = questaoCompletaFixture(1, "B");
  const q2 = questaoCompletaFixture(2, "C");
  const promptBlind = montarPromptAuditorBlind(payload, [sanitizarQuestaoParaBlindSolver(q1, 1), sanitizarQuestaoParaBlindSolver(q2, 2)]);
  const promptCritic = montarPromptAuditorCritic(payload, [q1, q2]);
  const reqBlind = construirRequestOpenAI({ model: "gpt-5.6-sol", reasoningEffort: "high", promptText: promptBlind, schemaName: "s", schema: {} });
  const reqCritic = construirRequestOpenAI({ model: "gpt-5.6-sol", reasoningEffort: "high", promptText: promptCritic, schemaName: "s", schema: {} });

  const serializado = JSON.stringify({ promptBlind, promptCritic, reqBlind, reqCritic }).toLowerCase();
  for (const termoProibido of ["openai_api_key", "authorization", "bearer ", "sk-", "service_role", "supabase_db_url"]) {
    assert.equal(serializado.includes(termoProibido), false, `estrutura nao pode conter "${termoProibido}"`);
  }
});
