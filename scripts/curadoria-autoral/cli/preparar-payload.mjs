#!/usr/bin/env node
// CLI — preparar payload para UMA unidade (Fase 2A, Secao 30). READ-ONLY
// no Supabase, zero chamada a API de IA, zero escrita no banco. NUNCA
// envia nada a nenhum modelo — so monta e grava o JSON localmente.
//
// Uso:
//   node scripts/curadoria-autoral/cli/preparar-payload.mjs \
//     --curso-slug brigada-militar-rs --unidade-id <uuid> --quantidade 3 \
//     [--target-bank-size 10] [--banca "Fundatec"]

import { parseArgs } from "node:util";
import path from "node:path";
import { carregarDadosBrutosAutoDetectado, resolverCurso, resolverUnidadeNoCurso } from "../lib/context-resolver.mjs";
import { calcularCoberturaUnidade, classificarOrigemQuestoes, questoesUteisDaUnidade } from "../lib/coverage-scanner.mjs";
import { avaliarContextoPedagogico, avaliarElegibilidade, materiaPareceNormativa } from "../lib/eligibility.mjs";
import { avaliarValidacaoFonte, buscarFontesParaUnidade, carregarFontes } from "../lib/source-manifest.mjs";
import { resolverBanca } from "../lib/banca-resolver.mjs";
import { construirPayload } from "../lib/payload-builder.mjs";
import { criarManifestoBase, finalizarManifesto, gerarRunId } from "../lib/run-manifest.mjs";
import { escreverArtefatoJson, prepararDiretorioRun } from "../lib/artifact-writer.mjs";
import { STATUS_ELEGIBILIDADE } from "../lib/schemas.mjs";

async function main() {
  const { values } = parseArgs({
    options: {
      "curso-id": { type: "string" },
      "curso-slug": { type: "string" },
      "unidade-id": { type: "string" },
      quantidade: { type: "string" },
      "target-bank-size": { type: "string", default: "10" },
      banca: { type: "string" },
    },
  });

  if (!values["unidade-id"]) {
    console.error("Informe --unidade-id.");
    process.exit(1);
  }
  const quantidade = Number(values.quantidade);
  if (!Number.isInteger(quantidade) || quantidade <= 0) {
    console.error("Informe --quantidade como inteiro positivo.");
    process.exit(1);
  }
  const targetBankSize = Number(values["target-bank-size"]);
  if (!Number.isInteger(targetBankSize) || targetBankSize <= 0) {
    console.error("--target-bank-size precisa ser um inteiro positivo.");
    process.exit(1);
  }

  const { canal, dados: dadosBrutos, pgSessionGuard } = await carregarDadosBrutosAutoDetectado();
  console.log(`Canal de leitura: ${canal}`);
  if (pgSessionGuard) console.log(`transaction_read_only: ${pgSessionGuard.transaction_read_only}`);

  const fontes = carregarFontes();

  const cursoResolvido = resolverCurso(dadosBrutos, { cursoId: values["curso-id"], cursoSlug: values["curso-slug"] });
  if (!cursoResolvido.ok) {
    console.error(`Curso nao resolvido: ${cursoResolvido.motivo}`);
    process.exit(1);
  }
  const curso = cursoResolvido.curso;

  const unidadeResolvida = resolverUnidadeNoCurso(dadosBrutos, { unidadeId: values["unidade-id"], cursoId: curso.id });
  if (!unidadeResolvida.ok) {
    console.error(`ABORTADO: ${unidadeResolvida.motivo}`);
    process.exit(1);
  }
  const { unidade, cursoConteudo, cursoMateria } = unidadeResolvida;

  const editalDoCurso = dadosBrutos.editais.find((e) => e.id === curso.edital_id) ?? null;

  const cobertura = calcularCoberturaUnidade(dadosBrutos, {
    unidadeId: unidade.id,
    cursoId: curso.id,
    targetBankSize,
    bancaCurso: curso.banca ?? null,
    editalBanca: editalDoCurso?.banca ?? null,
    fontes,
  });

  const banca = resolverBanca({ cursoBanca: curso.banca ?? null, editalBanca: editalDoCurso?.banca ?? null, override: values.banca ?? null });

  const teoriaEscopo = dadosBrutos.teoriaEscoposConteudo.find((t) => t.curso_conteudo_id === cursoConteudo.id) ?? null;
  const contexto = avaliarContextoPedagogico({
    escopoUnidade: unidade.escopo,
    artigosEsperadosUnidade: unidade.artigos_esperados,
    teoriaEscopoConteudo: teoriaEscopo,
    materialVersoesExistem: cobertura.aula_existe && dadosBrutos.aulaVersaoFontes.length > 0,
  });
  const fontesDaUnidade = buscarFontesParaUnidade(fontes, unidade.id);
  const validacaoFonte = avaliarValidacaoFonte({ fontesDaUnidade, artigosEsperados: contexto.artigos_esperados_efetivos });
  const requerFonteValidada = materiaPareceNormativa(contexto.escopo_efetivo);

  const elegibilidade = avaliarElegibilidade({
    unidadeAtiva: unidade.ativa,
    faltantes: cobertura.faltantes,
    quantidadeSolicitada: quantidade,
    pedagogicalContextStatus: contexto.status,
    sourceValidationStatus: validacaoFonte.status,
    requerFonteValidada,
    bancaStatus: banca.status,
    aulaExiste: cobertura.aula_existe,
    aulaPublicada: cobertura.aula_publicada,
  });

  const runId = gerarRunId();
  const manifestoBase = criarManifestoBase({ runId, cursoId: curso.id, targetBankSize });
  const dirRun = prepararDiretorioRun(runId);
  const caminhoManifest = path.join(dirRun, "manifest.json");

  if (elegibilidade.status !== STATUS_ELEGIBILIDADE.ELIGIBLE_FOR_GENERATION) {
    const manifesto = finalizarManifesto(manifestoBase, { status: "BLOCKED", arquivosProduzidos: [caminhoManifest] });
    escreverArtefatoJson(caminhoManifest, { ...manifesto, blocking_reasons: elegibilidade.blocking_reasons });
    console.error(`BLOCKED: ${elegibilidade.blocking_reasons.join(", ")}`);
    console.log(`Run: ${runId} (nenhum payload gerado)`);
    process.exit(1);
  }

  const uteis = questoesUteisDaUnidade(dadosBrutos, unidade.id, curso.id);
  const origem = classificarOrigemQuestoes(dadosBrutos, uteis);
  const questoesRealDaUnidade = origem.real.map((id) => {
    const q = dadosBrutos.questoes.find((x) => x.id === id);
    return { question_id: id, banca: q?.banca ?? null, ano: null, dificuldade: null, nucleo: null };
  });

  const cursoEvidenciaIds = dadosBrutos.cursoEvidencias
    .filter((e) => e.curso_conteudo_id === cursoConteudo.id || e.curso_materia_id === cursoMateria.id)
    .map((e) => e.id);

  const materiaGlobal = dadosBrutos.materias.find((m) => m.id === cursoMateria.materia_id) ?? null;

  const payload = construirPayload({
    runId,
    curso: { id: curso.id, slug: curso.slug, concurso: curso.concurso },
    banca,
    materia: { id: cursoMateria.materia_id, nome: materiaGlobal?.nome ?? cursoMateria.nome },
    conteudo: { curso_conteudo_id: cursoConteudo.id, assunto_id: cursoConteudo.assunto_id, nome: unidade.titulo, escopo: contexto.escopo_efetivo },
    unidade,
    licao: { id: cobertura.aula_id, exists: cobertura.aula_existe, published: cobertura.aula_publicada, version_id: cobertura.aula_versao_id },
    cobertura: {
      uteis_atual: cobertura.questoes_uteis,
      real_atual: cobertura.questoes_real,
      autoral_atual: cobertura.questoes_autoral,
      gerada_por_ia_atual: cobertura.questoes_geradas_por_ia,
      target_bank_size: targetBankSize,
      faltantes: cobertura.faltantes,
    },
    geracao: { quantidade, origem: "AUTORAL_PAPIRO", dificuldades: [] },
    referenciasReal: questoesRealDaUnidade,
    cursoEvidenciaIds,
    contextoPedagogico: contexto,
    validacaoFonte,
    requerFonteValidada,
    constraints: {
      requisitos: ["exatamente 5 alternativas A-E", "1 gabarito", "explicacao e fundamento preenchidos"],
      proibicoes: ["nao citar artigo/dispositivo sem fonte validada em source.validated_source_keys", "nao usar banca como fonte normativa"],
    },
    auditPolicy: { hard_gates: true, soft_gates: true },
  });

  const caminhoPayload = path.join(dirRun, "payloads", `${unidade.id}.json`);
  escreverArtefatoJson(caminhoPayload, payload);

  const manifesto = finalizarManifesto(manifestoBase, {
    status: "PAYLOAD_READY",
    arquivosProduzidos: [caminhoManifest, caminhoPayload],
  });
  escreverArtefatoJson(caminhoManifest, manifesto);

  console.log(`Run: ${runId}`);
  console.log(`Payload escrito em: ${caminhoPayload}`);
  console.log(`Unidade: ${unidade.titulo} · faltantes: ${cobertura.faltantes} · contexto: ${contexto.status} · fonte: ${validacaoFonte.status} · banca: ${banca.status}`);
  if (elegibilidade.warnings.length > 0) console.log(`Warnings: ${elegibilidade.warnings.join(", ")}`);
  console.log("API chamada: NAO · db_writes: 0");
}

main().catch((erro) => {
  console.error(erro.message);
  process.exit(1);
});
