#!/usr/bin/env node
// CLI — auditoria independente das questoes ja geradas (Fase 2C + Fase
// 2C.1 hardening). NO MAXIMO 2 chamadas de rede POR EXECUCAO deste
// arquivo (Auditor A e Auditor B) — mas cada chamada bem-sucedida e
// persistida IMEDIATAMENTE, antes de tentar a proxima, e uma reexecucao
// consulta primeiro o resume planner (lib/audit-state.mjs) para nunca
// repetir uma chamada cujo resultado ja esta salvo e valido para o MESMO
// input (fingerprint). Zero escrita no Supabase. Zero alteracao do
// conteudo das questoes ja congeladas.
//
// Uso:
//   node scripts/curadoria-autoral/cli/auditar-questoes.mjs \
//     --payload outputs/curadoria-autoral/<run_id>/payloads/<unidade_id>.json \
//     --model gpt-5.6-sol --reasoning-effort high [--dry-run]

import { parseArgs } from "node:util";
import path from "node:path";
import fs from "node:fs";
import { carregarEnvCuradoria } from "../../curadoria-pedagogica/lib/comum.mjs";
import {
  BLIND_SOLVER_JSON_SCHEMA,
  BLIND_SOLVER_SCHEMA_NAME,
  FULL_CRITIC_JSON_SCHEMA,
  FULL_CRITIC_SCHEMA_NAME,
  construirRequestOpenAI,
  montarPromptAuditorBlind,
  montarPromptAuditorCritic,
  sanitizarQuestaoParaBlindSolver,
} from "../lib/openai-audit-provider.mjs";
import { STATUS_ETAPA, executarEtapaAuditoria } from "../lib/audit-runner.mjs";
import { ACOES_RETOMADA, calcularFingerprintAuditoria, lerEstadoAuditoria, planejarRetomada } from "../lib/audit-state.mjs";
import { agregarResultadoAuditoria, compararRespostaBlind, validarRespostaBlindLocalmente, validarRespostaCriticLocalmente } from "../lib/audit-orchestrator.mjs";
import { extrairSlotDoQuestionKey } from "../lib/generation-enrichment.mjs";
import { escreverArtefatoJson } from "../lib/artifact-writer.mjs";

const CHAVES_PROIBIDAS_NO_BLIND = ["gabarito", "explicacao", "fundamento", "justificativa_aderencia", "riscos_identificados", "status_pre_auditoria"];

function confirmarSemVazamentoParaBlind(questaoSanitizada) {
  for (const chave of CHAVES_PROIBIDAS_NO_BLIND) {
    if (Object.prototype.hasOwnProperty.call(questaoSanitizada, chave)) {
      throw new Error(`ABORTADO: questao sanitizada para o Auditor A contem campo proibido "${chave}".`);
    }
  }
}

function registrarTentativaNoManifest(caminhoManifest, entrada) {
  const anterior = fs.existsSync(caminhoManifest) ? JSON.parse(fs.readFileSync(caminhoManifest, "utf8")) : {};
  const audit_attempts = anterior.audit_attempts || [];
  audit_attempts.push({ recorded_at: new Date().toISOString(), phase: "Fase 2C.1", ...entrada });
  escreverArtefatoJson(caminhoManifest, { ...anterior, audit_attempts });
}

async function main() {
  const { values } = parseArgs({
    options: {
      payload: { type: "string" },
      model: { type: "string" },
      "reasoning-effort": { type: "string", default: "high" },
      "blind-prompt-version": { type: "string", default: "papiro-question-blind-solver-v1" },
      "critic-prompt-version": { type: "string", default: "papiro-question-full-critic-v1" },
      "dry-run": { type: "boolean", default: false },
    },
  });

  if (!values.payload) {
    console.error("Informe --payload <caminho/para/payload.json>.");
    process.exit(1);
  }
  const caminhoPayload = path.resolve(values.payload);
  if (!fs.existsSync(caminhoPayload)) {
    console.error(`Payload nao encontrado: ${caminhoPayload}`);
    process.exit(1);
  }
  const payload = JSON.parse(fs.readFileSync(caminhoPayload, "utf8"));

  const dirRun = path.dirname(path.dirname(caminhoPayload));
  const caminhoQuestoes = path.join(dirRun, "questoes_geradas.json");
  const caminhoManifest = path.join(dirRun, "manifest.json");
  const caminhoBlind = path.join(dirRun, "audit_blind.json");
  const caminhoCritic = path.join(dirRun, "audit_critic.json");
  const caminhoResult = path.join(dirRun, "audit_result.json");

  if (!fs.existsSync(caminhoQuestoes)) {
    console.error(`questoes_geradas.json nao encontrado em: ${caminhoQuestoes}`);
    process.exit(1);
  }
  const questoesGeradasRaw = fs.readFileSync(caminhoQuestoes, "utf8");
  const questoesGeradas = JSON.parse(questoesGeradasRaw);

  if (questoesGeradas.questoes.length !== 2) {
    console.error(`ABORTADO: esperado exatamente 2 questoes, encontrado ${questoesGeradas.questoes.length}.`);
    process.exit(1);
  }
  for (const q of questoesGeradas.questoes) {
    if (q.status_pre_auditoria !== "STRUCTURALLY_VALID_FOR_AUDIT") {
      console.error(`ABORTADO: ${q.question_key} nao esta STRUCTURALLY_VALID_FOR_AUDIT (esta: ${q.status_pre_auditoria}).`);
      process.exit(1);
    }
  }

  const model = values.model || process.env.OPENAI_MODEL;
  if (!model) {
    console.error("Informe --model (ou configure OPENAI_MODEL) — o modelo nunca e hardcoded na arquitetura.");
    process.exit(1);
  }
  const reasoningEffort = values["reasoning-effort"];
  const blindPromptVersion = values["blind-prompt-version"];
  const criticPromptVersion = values["critic-prompt-version"];

  const questoesComSlot = questoesGeradas.questoes.map((q) => ({ ...q, slot: extrairSlotDoQuestionKey(q.question_key) }));

  const fingerprint = calcularFingerprintAuditoria({
    questoesGeradasRaw,
    runId: payload.run_id,
    questionKeys: questoesComSlot.map((q) => q.question_key),
    model,
    blindPromptVersion,
    criticPromptVersion,
    escopo: payload.pedagogical_context.scope,
    fontesValidadas: payload.source.validated_source_keys,
  });

  const estado = lerEstadoAuditoria(dirRun);
  const plano = planejarRetomada({ fingerprintAtual: fingerprint, blindPersistido: estado.blind, criticPersistido: estado.critic, resultPersistido: estado.result });

  console.log("--- ESTADO / RESUME PLANNER ---");
  console.log(`resume_action: ${plano.action}`);
  console.log(`reason: ${plano.reason}`);
  console.log(`fingerprint: ${fingerprint}`);
  console.log(`blind_present: ${Boolean(estado.blind)} (valido: ${estado.blind?.valido ?? "-"})`);
  console.log(`critic_present: ${Boolean(estado.critic)} (valido: ${estado.critic?.valido ?? "-"})`);
  console.log(`result_present: ${Boolean(estado.result)} (valido: ${estado.result?.valido ?? "-"})`);
  console.log(`model: ${model} · blind_prompt_version: ${blindPromptVersion} · critic_prompt_version: ${criticPromptVersion}`);

  if (values["dry-run"]) {
    console.log("--dry-run: nenhuma acao adicional executada.");
    process.exit(0);
  }

  if (plano.action === ACOES_RETOMADA.BLOCKED_INCOMPATIBLE_PARTIAL) {
    console.error(`STOP: ${plano.reason}`);
    console.error("PAPIRO_ESTEIRA_AUTORAL_API_FASE2C1_BLOCKED_INCOMPATIBLE_PARTIAL");
    process.exit(1);
  }

  if (plano.action === ACOES_RETOMADA.AUDIT_ALREADY_COMPLETE) {
    console.log("AUDIT_ALREADY_COMPLETE — zero chamada de API. Resultado ja persistido:");
    for (const r of estado.result.dados.resultados) {
      console.log(`${r.question_key} · ${r.status} · reason_codes: ${r.reason_codes.join(", ") || "-"}`);
    }
    process.exit(0);
  }

  const questoesSanitizadas = questoesComSlot.map((q) => sanitizarQuestaoParaBlindSolver(q, q.slot));
  for (const s of questoesSanitizadas) confirmarSemVazamentoParaBlind(s);

  const precisaDeChamada = plano.action === ACOES_RETOMADA.RUN_BLIND_THEN_CRITIC || plano.action === ACOES_RETOMADA.RUN_CRITIC_ONLY;
  let apiKey = null;
  if (precisaDeChamada) {
    carregarEnvCuradoria();
    apiKey = process.env.OPENAI_API_KEY;
    console.log(`OPENAI_API_KEY: ${apiKey ? "PRESENTE" : "AUSENTE"}`);
    if (!apiKey) {
      registrarTentativaNoManifest(caminhoManifest, { status: "BLOCKED_OPENAI_KEY_AUSENTE", resume_action: plano.action });
      console.error("STOP: OPENAI_API_KEY ausente.\nPAPIRO_ESTEIRA_AUTORAL_API_FASE2C1_INFRA_BLOQUEADA");
      process.exit(2);
    }
  }

  let blindDados = estado.blind?.dados?.answers ? estado.blind.dados : null;

  // ==================== CALL A (so quando o plano manda) ====================
  if (plano.action === ACOES_RETOMADA.RUN_BLIND_THEN_CRITIC) {
    const promptBlind = montarPromptAuditorBlind(payload, questoesSanitizadas);
    const requestBlind = construirRequestOpenAI({ model, reasoningEffort, promptText: promptBlind, schemaName: BLIND_SOLVER_SCHEMA_NAME, schema: BLIND_SOLVER_JSON_SCHEMA });

    const resultadoBlind = await executarEtapaAuditoria({
      apiKey,
      requestBody: requestBlind,
      caminhoArtefato: caminhoBlind,
      fingerprint,
      validarLocalmente: validarRespostaBlindLocalmente,
      montarConteudoArtefato: ({ extraida, dadosValidados, fingerprint: fp }) => ({
        schema_version: 1,
        run_id: payload.run_id,
        generated_at: new Date().toISOString(),
        model: extraida.model_returned || model,
        prompt_version: blindPromptVersion,
        response_id: extraida.response_id,
        usage: extraida.usage,
        audit_input_fingerprint: fp,
        answers: dadosValidados.answers,
      }),
    });

    console.log(`[Auditor A] status: ${resultadoBlind.status}`);
    registrarTentativaNoManifest(caminhoManifest, { etapa: "blind", ...resultadoBlind.bookkeeping });

    if (resultadoBlind.status !== STATUS_ETAPA.PERSISTED) {
      console.error(`STOP: Auditor A nao persistiu (${resultadoBlind.status}: ${resultadoBlind.bookkeeping.error_message}). NAO executando Call B.`);
      console.error("PAPIRO_ESTEIRA_AUTORAL_API_FASE2C1_INFRA_BLOQUEADA");
      process.exit(3);
    }
    console.log(`audit_blind.json persistido e confirmado legivel em: ${caminhoBlind}`);
    blindDados = resultadoBlind.conteudoArtefato;
  }

  // ==================== CALL B (quando o plano manda RUN_BLIND_THEN_CRITIC ou RUN_CRITIC_ONLY) ====================
  let criticDados = estado.critic?.dados?.audits ? estado.critic.dados : null;
  if (plano.action === ACOES_RETOMADA.RUN_BLIND_THEN_CRITIC || plano.action === ACOES_RETOMADA.RUN_CRITIC_ONLY) {
    const promptCritic = montarPromptAuditorCritic(payload, questoesComSlot);
    const requestCritic = construirRequestOpenAI({ model, reasoningEffort, promptText: promptCritic, schemaName: FULL_CRITIC_SCHEMA_NAME, schema: FULL_CRITIC_JSON_SCHEMA });

    const resultadoCritic = await executarEtapaAuditoria({
      apiKey,
      requestBody: requestCritic,
      caminhoArtefato: caminhoCritic,
      fingerprint,
      validarLocalmente: validarRespostaCriticLocalmente,
      montarConteudoArtefato: ({ extraida, dadosValidados, fingerprint: fp }) => ({
        schema_version: 1,
        run_id: payload.run_id,
        generated_at: new Date().toISOString(),
        model: extraida.model_returned || model,
        prompt_version: criticPromptVersion,
        response_id: extraida.response_id,
        usage: extraida.usage,
        audit_input_fingerprint: fp,
        audits: dadosValidados.audits,
      }),
    });

    console.log(`[Auditor B] status: ${resultadoCritic.status}`);
    registrarTentativaNoManifest(caminhoManifest, { etapa: "critic", ...resultadoCritic.bookkeeping });

    if (resultadoCritic.status !== STATUS_ETAPA.PERSISTED) {
      console.error(`STOP: Auditor B nao persistiu (${resultadoCritic.status}: ${resultadoCritic.bookkeeping.error_message}).`);
      console.error("PAPIRO_ESTEIRA_AUTORAL_API_FASE2C1_INFRA_BLOQUEADA");
      console.error(`Nota: audit_blind.json permanece persistido e valido em ${caminhoBlind} — uma proxima execucao fara RUN_CRITIC_ONLY, sem repetir a Call A.`);
      process.exit(4);
    }
    console.log(`audit_critic.json persistido e confirmado legivel em: ${caminhoCritic}`);
    criticDados = resultadoCritic.conteudoArtefato;
  }

  // ==================== AGREGACAO LOCAL (zero API) ====================
  const respostasBlindPorSlot = new Map(blindDados.answers.map((a) => [a.slot, a]));
  const auditoriasPorSlot = new Map(criticDados.audits.map((a) => [a.slot, a]));

  const resultadosFinais = questoesComSlot.map((q) => {
    const blind = respostasBlindPorSlot.get(q.slot);
    const critic = auditoriasPorSlot.get(q.slot);
    const comparacaoBlind = compararRespostaBlind({
      independentAnswer: blind.independent_answer,
      gabaritoDeclarado: q.gabarito,
      ambiguity: blind.ambiguity,
      confidence: blind.confidence,
      uniqueAnswer: blind.unique_answer,
    });
    const agregado = agregarResultadoAuditoria({
      blindComparison: comparacaoBlind,
      criticChecks: critic.checks,
      criticalFindings: critic.critical_findings,
      recommendedAction: critic.recommended_action,
    });
    return {
      question_key: q.question_key,
      slot: q.slot,
      blind_independent_answer: blind.independent_answer,
      declared_gabarito: q.gabarito,
      blind_match: comparacaoBlind.match,
      blind_unique: comparacaoBlind.unique,
      blind_ambiguity: blind.ambiguity,
      blind_confidence: blind.confidence,
      critic_recommended_action: critic.recommended_action,
      critic_checks: critic.checks,
      critic_critical_findings: critic.critical_findings,
      critic_summary: critic.summary,
      status: agregado.status,
      reason_codes: agregado.reason_codes,
    };
  });

  escreverArtefatoJson(caminhoResult, {
    schema_version: 1,
    run_id: payload.run_id,
    generated_at: new Date().toISOString(),
    audit_input_fingerprint: fingerprint,
    resultados: resultadosFinais,
  });
  const confirmacaoResult = JSON.parse(fs.readFileSync(caminhoResult, "utf8"));
  if (confirmacaoResult.audit_input_fingerprint !== fingerprint) {
    console.error("STOP: audit_result.json nao confirmou fingerprint na releitura apos persistir.");
    console.error("PAPIRO_ESTEIRA_AUTORAL_API_FASE2C1_INFRA_BLOQUEADA");
    process.exit(5);
  }
  console.log(`audit_result.json persistido e confirmado legivel em: ${caminhoResult}`);

  registrarTentativaNoManifest(caminhoManifest, { status: "AUDIT_COMPLETE", resume_action_executado: plano.action, audit_input_fingerprint: fingerprint });

  console.log("--- RESULTADO ---");
  for (const r of resultadosFinais) {
    console.log(`${r.question_key} · ${r.status} · reason_codes: ${r.reason_codes.join(", ") || "-"}`);
  }
  console.log("db_writes: 0");
}

main().catch((erro) => {
  console.error(erro.message);
  process.exit(1);
});
