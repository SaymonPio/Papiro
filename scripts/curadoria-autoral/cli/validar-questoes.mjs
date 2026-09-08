#!/usr/bin/env node
// CLI — validar estrutura de questoes (Fase 2A). Le um array JSON de
// questoes candidatas (SEMPRE fixture/teste nesta fase — nenhuma geracao
// real acontece ate a Fase 2B) e roda validador estrutural + dedup
// deterministico + classificacao. Nunca chama IA, nunca escreve no banco.
//
// Deliberadamente NAO usa run-manifest/artifact-writer: este utilitario e
// standalone (entrada e saida sao arquivos explicitos passados por flag),
// para nunca ser confundido com um run real de cobertura/payload (Secao 5:
// "fixtures de teste devem permanecer separadas dos artefatos reais").
//
// Uso:
//   node scripts/curadoria-autoral/cli/validar-questoes.mjs --input <arquivo.json> [--output <arquivo.json>] [--referencias <arquivo.json>]

import { parseArgs } from "node:util";
import fs from "node:fs";
import { validarQuestaoGerada } from "../lib/validador-questoes.mjs";
import { classificarDeterministico } from "../lib/audit-classifier.mjs";
import { classificarDuplicidade } from "../lib/duplicate-utils.mjs";

function ehStringUtilizavel(v) {
  return typeof v === "string" && v.trim().length > 0;
}

function main() {
  const { values } = parseArgs({
    options: {
      input: { type: "string" },
      output: { type: "string" },
      referencias: { type: "string" },
    },
  });

  if (!values.input) {
    console.error("Informe --input <arquivo.json com um array de questoes candidatas>.");
    process.exit(1);
  }

  const candidatas = JSON.parse(fs.readFileSync(values.input, "utf8"));
  if (!Array.isArray(candidatas)) {
    console.error("--input precisa ser um array JSON de questoes.");
    process.exit(1);
  }

  const referenciasExternas = values.referencias
    ? JSON.parse(fs.readFileSync(values.referencias, "utf8")).map((r) => ({ id: r.id, texto: r.enunciado, mesmaUnidade: false }))
    : [];

  const resultados = candidatas.map((questao, indice) => {
    const validacaoEstrutural = validarQuestaoGerada(questao);

    const candidatosParaDedup = [
      ...referenciasExternas,
      ...candidatas
        .filter((_, i) => i !== indice)
        .map((outra) => ({ id: outra.question_key ?? `indice_${indice}`, texto: outra.enunciado ?? "", mesmaUnidade: outra.unidade_id === questao.unidade_id })),
    ];
    const duplicidade = ehStringUtilizavel(questao.enunciado)
      ? classificarDuplicidade(questao.enunciado, candidatosParaDedup)
      : { codigo: null, similaridade: null, candidato_id: null };

    const classificacao = classificarDeterministico({ validacaoEstrutural, duplicidade });

    return {
      question_key: questao.question_key ?? `indice_${indice}`,
      validacao_estrutural: validacaoEstrutural,
      duplicidade,
      status: classificacao.status,
      reason_codes: classificacao.reason_codes,
    };
  });

  const resumo = resultados.reduce((acc, r) => {
    acc[r.status] = (acc[r.status] ?? 0) + 1;
    return acc;
  }, {});

  console.log("Resumo:", resumo);
  for (const r of resultados) {
    console.log(`${r.question_key}\t${r.status}\t${r.reason_codes.join(", ") || "-"}`);
  }

  if (values.output) {
    fs.writeFileSync(values.output, JSON.stringify({ generated_at: new Date().toISOString(), resumo, resultados }, null, 2) + "\n", "utf8");
    console.log(`Resultado detalhado salvo em ${values.output}`);
  }

  console.log("API chamada: NAO · db_writes: 0");
}

main();
