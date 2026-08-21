#!/usr/bin/env node
// Orquestrador do pipeline de curadoria pedagógica automático.
//
// Uso:
//   node executar-pipeline.mjs <curso_conteudo_id>
//   node executar-pipeline.mjs --continuar <slug>
//   node executar-pipeline.mjs --fixture <slug>
//
// MODO 1 — node executar-pipeline.mjs 57:
//   Roda só auditar-conteudo.mjs e PARA. Não existe forma automática de ir
//   além disso, porque as etapas seguintes (definir unidades, montar o
//   mapa de classificação) exigem leitura humana do enunciado + todas as
//   alternativas de cada questão (ver docs/REGRAS_CURADORIA_PAPIRO.md,
//   seção 4) — este pipeline nunca inventa essa parte.
//
// MODO 2 — node executar-pipeline.mjs --continuar lei_drogas:
//   Depois que um humano já escreveu config/<slug>.unidades.json e
//   config/<slug>.mapa.json (a partir do relatório de auditoria e de
//   julgamento pedagógico), este modo roda em sequência:
//     gerar-curadoria.mjs → gerar-mapa.mjs → gerar-rollback.mjs →
//     gerar-pos-check.mjs → validar-pipeline.mjs
//   e imprime os próximos passos manuais (rodar o teste rollback no
//   Supabase Studio, revisar, só então decidir sobre o apply real). Este
//   modo TOCA o Supabase (só SELECT) via gerar-pos-check.mjs.
//
// MODO 3 — node executar-pipeline.mjs --fixture lei_drogas (novo na v1.1):
//   Simulação pura. NÃO toca o Supabase (não chama auditar-conteudo.mjs
//   nem gerar-pos-check.mjs) e NÃO escreve em supabase/ de verdade — os 3
//   geradores que não dependem do banco (curadoria/mapa/rollback) rodam
//   escrevendo num diretório temporário isolado (via a variável de
//   ambiente CURADORIA_SAIDA_DIR, lida por lib/comum.mjs). Depois compara
//   um conjunto de "fatos" extraídos (UUIDs, nomes de etapa de checagem,
//   ids de questão) entre o que foi gerado e o arquivo real já commitado
//   em supabase/ para o mesmo slug, reportando divergência ou "bate com o
//   padrão". Serve para validar o próprio pipeline sem qualquer risco.
//
// Em NENHUM modo este orquestrador cria migration ou faz commit — ele só
// chama os outros scripts deste mesmo diretório.

import { spawnSync } from "node:child_process";
import path from "node:path";
import fs from "node:fs";
import os from "node:os";
import { fileURLToPath } from "node:url";
import { caminhoConfigUnidades, caminhoConfigMapa, DIR_SUPABASE } from "./lib/comum.mjs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

function rodar(scriptRelativo, args, envExtra) {
  console.log(`\n--- ${scriptRelativo} ${args.join(" ")} ---`);
  const resultado = spawnSync(process.execPath, [path.join(__dirname, scriptRelativo), ...args], {
    stdio: "inherit",
    env: { ...process.env, ...envExtra },
  });
  if (resultado.status !== 0) {
    console.error(`\nFalhou em ${scriptRelativo} (codigo ${resultado.status}). Pipeline interrompido.`);
    process.exit(resultado.status ?? 1);
  }
}

const modo = process.argv[2];

// ============================================================================
// MODO 3 — simulação (--fixture)
// ============================================================================
if (modo === "--fixture") {
  const slug = process.argv[3];
  if (!slug) {
    console.error("Uso: node executar-pipeline.mjs --fixture <slug>");
    process.exit(1);
  }
  if (!fs.existsSync(caminhoConfigUnidades(slug)) || !fs.existsSync(caminhoConfigMapa(slug))) {
    console.error(`config/${slug}.unidades.json e config/${slug}.mapa.json precisam existir para simular (ver config/lei_drogas.*.json como exemplo).`);
    process.exit(1);
  }

  const dirTemporario = fs.mkdtempSync(path.join(os.tmpdir(), `curadoria-fixture-${slug}-`));
  console.log(`Simulando em diretorio isolado (nunca em supabase/ real): ${dirTemporario}`);

  const envFixture = { CURADORIA_SAIDA_DIR: dirTemporario };
  rodar("gerar-curadoria.mjs", [slug], envFixture);
  rodar("gerar-mapa.mjs", [slug], envFixture);
  rodar("gerar-rollback.mjs", [slug], envFixture);
  // gerar-pos-check.mjs e validar-pipeline.mjs NÃO rodam aqui: o primeiro
  // toca o Supabase (proibido neste modo); o segundo lê supabase/ real
  // (DIR_SUPABASE fixo, não respeita o override), o que não faria sentido
  // comparar contra arquivos que ainda nem existem para um slug novo.

  const arquivosParaComparar = [
    `curadoria_unidades_${slug}.sql`,
    `mapa_classificacao_${slug}.sql`,
    `classificar_questoes_unidades_${slug}_teste_rollback.sql`,
  ];

  function extrairFatos(texto) {
    const uuids = new Set(
      [...texto.matchAll(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/gi)].map((m) => m[0].toLowerCase())
    );
    const etapas = new Set([...texto.matchAll(/insert into _relatorio values\s*\(\s*'([a-z0-9_]+)'/gi)].map((m) => m[1]));
    const questaoIds = new Set(
      [...texto.matchAll(/\(\s*(\d+),\s*'[0-9a-f-]{36}'/gi)].map((m) => Number(m[1]))
    );
    return { uuids, etapas, questaoIds };
  }

  function compararConjunto(rotulo, gerado, real) {
    if (gerado.size === 0 && real.size === 0) return null;
    const faltando = [...real].filter((x) => !gerado.has(x));
    const extra = [...gerado].filter((x) => !real.has(x));
    return { rotulo, ok: faltando.length === 0 && extra.length === 0, faltando, extra };
  }

  let tudoBateu = true;
  let houveComparacao = false;

  for (const nomeArquivo of arquivosParaComparar) {
    const caminhoGerado = path.join(dirTemporario, nomeArquivo);
    const caminhoReal = path.join(DIR_SUPABASE, nomeArquivo);

    if (!fs.existsSync(caminhoGerado)) {
      console.log(`\n[${nomeArquivo}] NAO FOI GERADO — falha do pipeline.`);
      tudoBateu = false;
      continue;
    }
    if (!fs.existsSync(caminhoReal)) {
      console.log(`\n[${nomeArquivo}] gerado com sucesso; sem arquivo real equivalente em supabase/ para comparar (slug novo, ok).`);
      continue;
    }

    houveComparacao = true;
    const fatosGerado = extrairFatos(fs.readFileSync(caminhoGerado, "utf8"));
    const fatosReal = extrairFatos(fs.readFileSync(caminhoReal, "utf8"));

    console.log(`\n[${nomeArquivo}] comparando com padrao real (supabase/${nomeArquivo}):`);
    for (const [rotulo, chave] of [
      ["UUIDs", "uuids"],
      ["etapas de checagem (_relatorio)", "etapas"],
      ["ids de questao no mapa", "questaoIds"],
    ]) {
      const resultado = compararConjunto(rotulo, fatosGerado[chave], fatosReal[chave]);
      if (!resultado) continue;
      if (resultado.ok) {
        console.log(`  OK — ${rotulo}: bate exatamente com o padrao real (${fatosReal[chave].size} item(ns)).`);
      } else {
        tudoBateu = false;
        console.log(`  DIVERGENCIA — ${rotulo}:`);
        if (resultado.faltando.length > 0) console.log(`    faltando no gerado (presentes no real): ${resultado.faltando.join(", ")}`);
        if (resultado.extra.length > 0) console.log(`    a mais no gerado (ausentes no real): ${resultado.extra.join(", ")}`);
      }
    }
  }

  console.log(`\n=== Simulacao concluida para "${slug}" ===`);
  console.log(`Diretorio temporario (nada em supabase/ real foi tocado): ${dirTemporario}`);
  if (houveComparacao) {
    console.log(tudoBateu ? "RESULTADO: os arquivos gerados batem com o padrao real." : "RESULTADO: ha divergencia — revisar antes de confiar no pipeline para este caso.");
  } else {
    console.log("RESULTADO: geracao sem erros, mas nao havia arquivo real para comparar (slug ainda nao tem curadoria commitada).");
  }
  process.exit(tudoBateu ? 0 : 1);
}

// ============================================================================
// MODO 2 — continuar após config/ já escrito por humano
// ============================================================================
if (modo === "--continuar") {
  const slug = process.argv[3];
  if (!slug) {
    console.error("Uso: node executar-pipeline.mjs --continuar <slug>");
    process.exit(1);
  }
  if (!fs.existsSync(caminhoConfigUnidades(slug))) {
    console.error(`config/${slug}.unidades.json nao encontrado. Escreva-o (a partir do relatorio de auditoria e de julgamento pedagogico humano) antes de continuar.`);
    process.exit(1);
  }
  if (!fs.existsSync(caminhoConfigMapa(slug))) {
    console.error(`config/${slug}.mapa.json nao encontrado. Escreva-o (leitura humana de cada questao) antes de continuar.`);
    process.exit(1);
  }

  rodar("gerar-curadoria.mjs", [slug]);
  rodar("gerar-mapa.mjs", [slug]);
  rodar("gerar-rollback.mjs", [slug]);
  rodar("gerar-pos-check.mjs", [slug]);
  rodar("validar-pipeline.mjs", [slug]);

  console.log(`
=== Pipeline preparou os arquivos para "${slug}" ===

Arquivos gerados em supabase/:
  curadoria_unidades_${slug}.sql
  mapa_classificacao_${slug}.sql
  classificar_questoes_unidades_${slug}_teste_rollback.sql
  pos_check_classificacao_unidades_${slug}.sql (totais de sistema ja consultados ao vivo)

NADA foi executado no Supabase alem das leituras acima. Proximos passos,
todos com aprovacao humana:
  1. Revisar os 4 arquivos gerados.
  2. Rodar manualmente classificar_questoes_unidades_${slug}_teste_rollback.sql
     no SQL Editor do Supabase Studio e conferir tudo_ok = true.
  3. Escrever/revisar classificar_questoes_unidades_${slug}.sql (versao real,
     que termina em COMMIT) — este pipeline v1 nao gera esse arquivo
     automaticamente (ver README deste pipeline).
  4. Aplicar de fato, so depois de aprovacao explicita.
  5. Rodar pos_check_classificacao_unidades_${slug}.sql — se muito tempo
     passar entre a geracao e a aplicacao, regenere-o antes (os totais da
     consulta 7 sao um retrato do momento da geracao).
  6. Commit/push — sempre etapa separada e aprovada.
`);
  process.exit(0);
}

// ============================================================================
// MODO 1 — auditoria inicial
// ============================================================================
const cursoConteudoId = Number(modo);
if (!Number.isInteger(cursoConteudoId) || cursoConteudoId <= 0) {
  console.error("Uso:");
  console.error("  node executar-pipeline.mjs <curso_conteudo_id>");
  console.error("  node executar-pipeline.mjs --continuar <slug>");
  console.error("  node executar-pipeline.mjs --fixture <slug>");
  process.exit(1);
}

rodar("auditar-conteudo.mjs", [String(cursoConteudoId)]);

console.log(`
=== Auditoria concluida para curso_conteudo_id=${cursoConteudoId} ===

Este pipeline PARA aqui de proposito. Antes de continuar, um humano precisa:
  1. Ler o relatorio de auditoria (relatorios/relatorio_auditoria_<slug>.json).
  2. Ler o enunciado + TODAS as alternativas de cada questao ativa listada.
  3. Decidir a granularidade (1 unidade ou dividir) — ver
     docs/REGRAS_CURADORIA_PAPIRO.md, secoes 2 e 3.
  4. Escrever config/<slug>.unidades.json com titulo/escopo/artigos_esperados
     de cada unidade decidida.
  5. Escrever config/<slug>.mapa.json com o vinculo questao->unidade de cada
     questao, com justificativa e nivel de confianca.

Depois disso, rode:
  node executar-pipeline.mjs --continuar <slug>
`);
