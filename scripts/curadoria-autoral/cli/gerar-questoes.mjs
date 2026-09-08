#!/usr/bin/env node
// CLI — primeira geracao real via OpenAI (Fase 2B). UMA unica chamada de
// rede possivel neste arquivo inteiro (chamarOpenAI, dentro de
// lib/openai-provider.mjs) — nenhuma outra parte deste CLI fala com a
// internet. Zero escrita no Supabase em qualquer caminho de execucao.
//
// Uso:
//   node scripts/curadoria-autoral/cli/gerar-questoes.mjs \
//     --payload outputs/curadoria-autoral/<run_id>/payloads/<unidade_id>.json \
//     --model gpt-5.6-sol --reasoning-effort medium \
//     [--prompt-version papiro-question-generator-v1]
//
// Sem OPENAI_API_KEY configurada (.env.curadoria ou ambiente real), o CLI
// monta e valida a requisicao (dry-run, Secao 29), reporta tudo que pode
// reportar SEM segredo, e para com exit code 2 e a mensagem
// PAPIRO_ESTEIRA_AUTORAL_API_FASE2B_OPENAI_KEY_AUSENTE — nunca chama a API.

import { parseArgs } from "node:util";
import path from "node:path";
import crypto from "node:crypto";
import fs from "node:fs";
import { carregarEnvCuradoria } from "../../curadoria-pedagogica/lib/comum.mjs";
import {
  chamarOpenAI,
  construirRequestOpenAI,
  ehErroModeloIndisponivel,
  extrairRespostaEstruturada,
  montarPromptGerador,
} from "../lib/openai-provider.mjs";
import { enriquecerQuestaoGerada, extrairSlotDoQuestionKey } from "../lib/generation-enrichment.mjs";
import { validarQuestaoGerada } from "../lib/validador-questoes.mjs";
import { STATUS_PRE_AUDITORIA, classificarQuestaoPreAuditoria, textoCompletoParaTripwires, verificarCoberturaDeSlots } from "../lib/generation-audit.mjs";
import { classificarDuplicidade, compararContraHashesExistentes } from "../lib/duplicate-utils.mjs";
import { escreverArtefatoJson } from "../lib/artifact-writer.mjs";
import { STATUS_VALIDACAO_FONTE } from "../lib/schemas.mjs";

function hashPayload(payload) {
  return crypto.createHash("sha256").update(JSON.stringify(payload)).digest("hex");
}

function validarChecklistEntrada(payload) {
  const problemas = [];
  if (payload.generation?.quantity !== 2) problemas.push(`generation.quantity esperado 2, encontrado ${payload.generation?.quantity}`);
  if (payload.source?.status !== STATUS_VALIDACAO_FONTE.SOURCE_VALIDATED) problemas.push(`source.status esperado SOURCE_VALIDATED, encontrado ${payload.source?.status}`);
  if (payload.bank?.resolution_status !== "RESOLVED") problemas.push(`bank.resolution_status esperado RESOLVED, encontrado ${payload.bank?.resolution_status}`);
  if (!(payload.coverage?.missing > 0)) problemas.push(`coverage.missing precisa ser > 0, encontrado ${payload.coverage?.missing}`);

  const objetivos = payload.generation?.pedagogical_objectives ?? [];
  const slots = new Set(objetivos.map((o) => o.slot));
  if (objetivos.length !== 2 || !slots.has(1) || !slots.has(2)) {
    problemas.push("generation.pedagogical_objectives precisa ter exatamente os slots 1 e 2");
  }
  return problemas;
}

async function main() {
  const { values } = parseArgs({
    options: {
      payload: { type: "string" },
      model: { type: "string" },
      "reasoning-effort": { type: "string", default: "medium" },
      "prompt-version": { type: "string", default: "papiro-question-generator-v1" },
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

  const problemas = validarChecklistEntrada(payload);
  if (problemas.length > 0) {
    console.error("ABORTADO — payload nao passa no checklist de entrada (Secao 1):");
    for (const p of problemas) console.error(`  - ${p}`);
    process.exit(1);
  }

  const runId = payload.run_id;
  const dirRun = path.dirname(path.dirname(caminhoPayload)); // .../<run_id>/payloads/x.json -> .../<run_id>
  const caminhoManifest = path.join(dirRun, "manifest.json");
  const caminhoBaseline = path.join(dirRun, "dedup_baseline.json");
  const caminhoQuestoesGeradas = path.join(dirRun, "questoes_geradas.json");

  const model = values.model || process.env.OPENAI_MODEL;
  if (!model) {
    console.error("Informe --model (ou configure OPENAI_MODEL) — o modelo nunca e hardcoded na arquitetura.");
    process.exit(1);
  }
  const reasoningEffort = values["reasoning-effort"];
  const promptVersion = values["prompt-version"];

  const promptText = montarPromptGerador(payload);
  const requestBody = construirRequestOpenAI({ model, reasoningEffort, promptText });

  console.log("--- DRY RUN (pre-chamada, Secao 29) ---");
  console.log(`model: ${requestBody.model}`);
  console.log(`store: ${requestBody.store}`);
  console.log(`reasoning_effort: ${requestBody.reasoning.effort}`);
  console.log("structured_output: SIM");
  console.log(`schema_name: ${requestBody.text.format.name}`);
  console.log(`strict: ${requestBody.text.format.strict}`);
  console.log(`quantity: ${payload.generation.quantity}`);
  console.log(`tools: ${requestBody.tools.length}`);
  console.log(`input_payload_hash: ${hashPayload(payload)}`);
  console.log(`curso: ${payload.course.slug} · unidade: ${payload.unit.title} · banca: ${payload.bank.name}`);

  carregarEnvCuradoria();
  const apiKey = process.env.OPENAI_API_KEY;
  console.log(`OPENAI_API_KEY: ${apiKey ? "PRESENTE" : "AUSENTE"}`);

  if (!apiKey) {
    const manifestoAnterior = fs.existsSync(caminhoManifest) ? JSON.parse(fs.readFileSync(caminhoManifest, "utf8")) : {};
    escreverArtefatoJson(caminhoManifest, {
      ...manifestoAnterior,
      api_calls: 0,
      model,
      prompt_version: promptVersion,
      usage: null,
      generation_status: "BLOCKED_OPENAI_KEY_AUSENTE",
    });
    console.error("STOP: OPENAI_API_KEY ausente. Provider e testes ja implementados; nenhuma chamada foi feita.");
    console.error("PAPIRO_ESTEIRA_AUTORAL_API_FASE2B_OPENAI_KEY_AUSENTE");
    process.exit(2);
  }

  // ==================== A PARTIR DAQUI: 1 UNICA CHAMADA DE REDE ====================
  const respostaHttp = await chamarOpenAI({ apiKey, requestBody });

  if (!respostaHttp.ok) {
    const mensagem = respostaHttp.corpo?.error?.message || JSON.stringify(respostaHttp.corpo).slice(0, 300);
    const manifestoAnterior = fs.existsSync(caminhoManifest) ? JSON.parse(fs.readFileSync(caminhoManifest, "utf8")) : {};
    escreverArtefatoJson(caminhoManifest, { ...manifestoAnterior, api_calls: 1, model, prompt_version: promptVersion, usage: null, generation_status: "ERRO_HTTP", erro: mensagem });

    if (ehErroModeloIndisponivel(mensagem)) {
      console.error(`STOP: modelo "${model}" indisponivel para esta chave/projeto. NAO trocando de modelo silenciosamente.`);
      console.error("OPENAI_PILOT_MODEL_UNAVAILABLE");
      process.exit(3);
    }
    console.error(`STOP: chamada a OpenAI falhou (status ${respostaHttp.status}): ${mensagem}`);
    process.exit(4);
  }

  const extraida = extrairRespostaEstruturada(respostaHttp.corpo);
  console.log(`response_id: ${extraida.response_id} · status: ${extraida.status} · model_returned: ${extraida.model_returned}`);
  console.log(`usage: input=${extraida.usage.input_tokens} output=${extraida.usage.output_tokens} total=${extraida.usage.total_tokens}`);

  const manifestoBaseAtualizado = {
    ...(fs.existsSync(caminhoManifest) ? JSON.parse(fs.readFileSync(caminhoManifest, "utf8")) : {}),
    api_calls: 1,
    model: extraida.model_returned || model,
    prompt_version: promptVersion,
    usage: extraida.usage,
    response_id: extraida.response_id,
    response_status: extraida.status,
  };

  if (extraida.jsonInvalido) {
    escreverArtefatoJson(caminhoManifest, { ...manifestoBaseAtualizado, generation_status: `ERRO_${extraida.motivo}` });
    console.error(`STOP: resposta estruturada invalida (${extraida.motivo}).`);
    process.exit(5);
  }

  const questionsBrutas = extraida.dados?.questions ?? [];
  if (questionsBrutas.length !== 2) {
    escreverArtefatoJson(caminhoManifest, { ...manifestoBaseAtualizado, generation_status: "ERRO_QUANTIDADE_INESPERADA" });
    console.error(`STOP: esperado exatamente 2 questoes, recebido ${questionsBrutas.length}.`);
    process.exit(6);
  }

  const generatedAt = new Date().toISOString();
  const questoesEnriquecidas = questionsBrutas.map((bruta) =>
    enriquecerQuestaoGerada({ questaoBruta: bruta, payload, runId, model: extraida.model_returned || model, promptVersion, generatedAt })
  );

  const baseline = fs.existsSync(caminhoBaseline) ? JSON.parse(fs.readFileSync(caminhoBaseline, "utf8")) : null;
  const candidatosBaseline = baseline?.questoes_existentes ?? [];

  const resultados = questoesEnriquecidas.map((questao, indice) => {
    const validacaoEstrutural = validarQuestaoGerada(questao);
    const slotEsperado = extrairSlotDoQuestionKey(questao.question_key);

    const textoParaDedup = textoCompletoParaTripwires(questao);
    const duplicidadeContraBaseline = compararContraHashesExistentes(textoParaDedup, candidatosBaseline);

    // Fase 2B.1 (Secao 4): "mesma unidade" sozinha NAO justifica
    // SEMANTIC_REVIEW_REQUIRED entre irmas do mesmo lote — isso e
    // tautologico (duas questoes do mesmo payload SEMPRE sao da mesma
    // unidade), tornaria o sinal inutil, e conflita com slots pedagogicos
    // deliberadamente distintos (Secao 5/6 do payload). Por isso
    // `mesmaUnidade` NAO e passado aqui — so sobra o sinal lexical real
    // (hash exato/normalizado ou Jaccard >= limiar), que e o sinal
    // adicional exigido pelo mandato.
    const outraQuestao = questoesEnriquecidas[indice === 0 ? 1 : 0];
    const duplicidadeContraIrma = classificarDuplicidade(textoParaDedup, [
      { id: outraQuestao.question_key, texto: textoCompletoParaTripwires(outraQuestao) },
    ]);

    const classificacao = classificarQuestaoPreAuditoria({
      questaoEnriquecida: questao,
      validacaoEstrutural,
      slotEsperado,
      duplicidadeContraBaseline,
      duplicidadeContraIrma,
    });

    return { questao, validacaoEstrutural, duplicidadeContraBaseline, duplicidadeContraIrma, classificacao };
  });

  const coberturaSlots = verificarCoberturaDeSlots(questoesEnriquecidas);
  if (!coberturaSlots.ok) {
    for (const r of resultados) {
      if (r.classificacao.status === STATUS_PRE_AUDITORIA.STRUCTURALLY_VALID_FOR_AUDIT) {
        r.classificacao = { status: STATUS_PRE_AUDITORIA.REVIEW_REQUIRED_PRE_AUDIT, reason_codes: ["SLOT_COVERAGE_MISMATCH"], tripwires: r.classificacao.tripwires };
      }
    }
  }

  const saida = {
    schema_version: 1,
    run_id: runId,
    generated_at: generatedAt,
    model: extraida.model_returned || model,
    prompt_version: promptVersion,
    cobertura_slots: coberturaSlots,
    questoes: resultados.map((r) => ({
      ...r.questao,
      validacao_estrutural: r.validacaoEstrutural,
      duplicidade_contra_baseline: r.duplicidadeContraBaseline,
      duplicidade_contra_irma: r.duplicidadeContraIrma,
      tripwires_gramaticais: r.classificacao.tripwires,
      status_pre_auditoria: r.classificacao.status,
      reason_codes: r.classificacao.reason_codes,
    })),
  };
  escreverArtefatoJson(caminhoQuestoesGeradas, saida);

  const resumoStatus = saida.questoes.reduce((acc, q) => {
    acc[q.status_pre_auditoria] = (acc[q.status_pre_auditoria] ?? 0) + 1;
    return acc;
  }, {});
  escreverArtefatoJson(caminhoManifest, { ...manifestoBaseAtualizado, generation_status: "GENERATED", resumo_status_pre_auditoria: resumoStatus });

  console.log("--- RESULTADO ---");
  for (const q of saida.questoes) {
    console.log(`${q.question_key} · status_pre_auditoria: ${q.status_pre_auditoria} · reason_codes: ${q.reason_codes.join(", ") || "-"}`);
  }
  console.log(`Artefato: ${caminhoQuestoesGeradas}`);
  console.log("API chamada: 1 · db_writes: 0");
}

main().catch((erro) => {
  console.error(erro.message);
  process.exit(1);
});
