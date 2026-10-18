// Executor da aquisição — última etapa do pipeline do importador:
//   staging aprovado -> prova -> documentos do gabarito -> questões ->
//   alternativas -> vínculos
//   explicitamente aprovados -> pós-check -> relatório.
//
// Opera sobre um REPOSITÓRIO (repositorioPg.mjs em produção; um
// repositório em memória nos testes) para que gates, atomicidade e
// pós-check sejam o mesmo código nos dois casos.
//
// Modos de execução (nunca grava por padrão):
//   "dry-run"        transação READ ONLY; só planeja e devolve o manifesto.
//   "apply"          exige o hash do manifesto aprovado no dry-run; dentro
//                    de UMA transação: lock por hash_prova, REPLANEJA contra
//                    o estado atual, recusa se o hash mudou, grava, roda o
//                    pós-check e só então COMMIT. Qualquer erro: ROLLBACK.
//   "teste-rollback" idêntico ao apply, mas termina SEMPRE em ROLLBACK —
//                    valida o caminho de escrita real sem deixar rastro.

import { hashManifesto, planejarAquisicao } from "./planejar.mjs";
import { normalizarTexto } from "../deduplicar.mjs";

export class ErroAquisicao extends Error {
  constructor(mensagem, detalhes = {}) {
    super(mensagem);
    this.name = "ErroAquisicao";
    this.detalhes = detalhes;
  }
}

function textosParaChecarSequencia(questoes) {
  return questoes.flatMap((q) => (q.alternativas ?? []).map((a) => ({ numero: q.numero_original, letra: a.letra, texto: a.texto ?? "" })));
}

async function planejar(repo, entrada) {
  const prova = entrada.proveniencia?.prova ?? {};
  const contexto = await repo.lerContexto({
    hashProva: prova.hash_prova ?? null,
    chaveNatural: prova,
    slugsCursos: (entrada.aprovacao?.vinculos ?? []).map((v) => v.curso),
    alternativas: textosParaChecarSequencia(entrada.questoes),
  });
  contexto.hashesDivergentes = entrada.hashesDivergentes ?? null;
  const manifesto = planejarAquisicao({ ...entrada, contexto });
  return { manifesto, hash: hashManifesto(manifesto) };
}

function fonteCompativel(prova, numero) {
  return `${prova.banca} — ${prova.nome} — Questão ${String(numero).padStart(2, "0")}`;
}

// Pós-check DENTRO da transação, antes do COMMIT — qualquer falha aqui
// derruba a aquisição inteira (ROLLBACK).
function avaliarPosCheck({ estado, estruturaAntes, estruturaDepois, mutaveisAntes, mutaveisDepois, provaNova, prova, inseridas, vinculosEsperados, totalAntes, documentosEsperados, documentosNovos }) {
  const falhas = [];
  const deltasEsperados = {
    provas: provaNova ? 1 : 0,
    prova_documentos: documentosNovos,
    questoes: inseridas.length,
    alternativas: inseridas.reduce((soma, i) => soma + i.total_alternativas, 0),
    curso_questoes: vinculosEsperados.length,
  };
  // Documentos persistidos da prova = exatamente os do manifesto aprovado
  // (mesma posição, mesmo hash), nem um a mais.
  const persistidos = new Map((estado.documentos ?? []).map((d) => [`${d.tipo}:${d.ordem}`, d.hash_sha256]));
  if (persistidos.size !== documentosEsperados.length) falhas.push(`prova_documentos: ${persistidos.size} registrados, esperado ${documentosEsperados.length}`);
  for (const d of documentosEsperados) {
    if (persistidos.get(`${d.tipo}:${d.ordem}`) !== d.hash_sha256) falhas.push(`documento ${d.tipo}:${d.ordem} persistido com hash diferente do manifesto`);
  }
  if (estado.prova && documentosEsperados.find((d) => d.tipo === "GABARITO")?.hash_sha256 !== estado.prova.hash_gabarito) falhas.push("documento GABARITO não bate com provas.hash_gabarito");
  for (const [tabela, esperado] of Object.entries(deltasEsperados)) {
    const real = mutaveisDepois[tabela] - mutaveisAntes[tabela];
    if (real !== esperado) falhas.push(`${tabela}: cresceu ${real}, esperado ${esperado}`);
  }
  if (!estado.prova || estado.prova.hash_prova !== prova.hash_prova) falhas.push("prova não encontrada pelo hash após a gravação");

  const daProva = estado.questoesDaProva;
  if (daProva.length !== totalAntes + inseridas.length) {
    falhas.push(`questões da prova: esperado ${totalAntes + inseridas.length}, encontrado ${daProva.length}`);
  }
  const numeros = daProva.map((q) => q.numero_original);
  if (new Set(numeros).size !== numeros.length) falhas.push("numero_original duplicado dentro da prova");
  const enunciados = daProva.map((q) => normalizarTexto(q.enunciado));
  if (new Set(enunciados).size !== enunciados.length) falhas.push("enunciado duplicado dentro da prova");

  for (const esperada of inseridas) {
    const real = daProva.find((q) => q.id === esperada.questao_id);
    if (!real) {
      falhas.push(`questão nº ${esperada.numero_original} não encontrada com proveniência`);
      continue;
    }
    if (real.numero_original !== esperada.numero_original) falhas.push(`questão ${real.id}: numero_original divergente`);
    if (real.usuario_id !== null) falhas.push(`questão ${real.id}: não é global`);
    if (real.alternativas.length !== esperada.total_alternativas) falhas.push(`questão ${real.id}: ${real.alternativas.length} alternativas, esperado ${esperada.total_alternativas}`);
    if (real.alternativas.filter((a) => a.correta).length !== 1) falhas.push(`questão ${real.id}: não tem exatamente 1 alternativa correta`);
  }

  const chave = (v) => `${v.curso_id}|${v.questao_id}`;
  const esperados = new Set(vinculosEsperados.map(chave));
  const reais = new Set(estado.vinculos.map(chave));
  for (const v of esperados) if (!reais.has(v)) falhas.push(`vínculo esperado ausente: ${v}`);
  for (const v of reais) if (!esperados.has(v)) falhas.push(`vínculo INESPERADO: ${v}`);

  for (const tabela of Object.keys(estruturaAntes)) {
    if (estruturaAntes[tabela] !== estruturaDepois[tabela]) falhas.push(`estrutura alterada em ${tabela}: ${estruturaAntes[tabela]} -> ${estruturaDepois[tabela]}`);
  }
  return falhas;
}

export async function executarAquisicao({ repo, entrada, modo = "dry-run", hashManifestoAprovado = null }) {
  if (!["dry-run", "apply", "teste-rollback"].includes(modo)) throw new ErroAquisicao(`modo de execução inválido "${modo}"`);

  if (modo === "dry-run") {
    await repo.iniciar({ somenteLeitura: true });
    try {
      return { modo, ...(await planejar(repo, entrada)), gravado: false };
    } finally {
      await repo.desfazer();
    }
  }

  if (!hashManifestoAprovado) throw new ErroAquisicao("apply exige o hash do manifesto aprovado no dry-run");

  await repo.iniciar({ somenteLeitura: false, chaveLock: entrada.proveniencia?.prova?.hash_prova ?? "sem-hash" });
  try {
    const { manifesto, hash } = await planejar(repo, entrada);
    if (hash !== hashManifestoAprovado) {
      throw new ErroAquisicao("o plano atual difere do manifesto aprovado (staging ou banco mudaram desde o dry-run) — rode o dry-run de novo", { hashAtual: hash });
    }
    if (manifesto.bloqueios.length > 0) throw new ErroAquisicao("manifesto com bloqueios — nada gravado", { bloqueios: manifesto.bloqueios });

    const estruturaAntes = await repo.contagensEstruturais();
    const mutaveisAntes = await repo.contagensMutaveis();
    const prova = manifesto.prova;
    const provaId = prova.prova_id_existente ?? (await repo.inserirProva(entrada.proveniencia.prova));
    // Documentos que determinaram o gabarito final — só os NOVO; os já
    // registrados foram conferidos por hash no planejamento.
    const documentosNovos = manifesto.documentos.filter((d) => d.situacao === "NOVO");
    for (const documento of documentosNovos) await repo.inserirDocumento(provaId, documento);
    const totalAntes = (await repo.lerEstadoPosCheck({ provaId, questaoIds: [] })).questoesDaProva.length;

    const porNumero = new Map(entrada.questoes.map((q) => [q.numero_original, q]));
    const inseridas = [];
    const vinculosEsperados = [];
    for (const item of manifesto.questoes.filter((q) => q.acao === "IMPORTAR")) {
      const questao = porNumero.get(item.numero_original);
      const questaoId = await repo.inserirQuestao({
        materia_id: item.materia_id,
        assunto_id: item.assunto_id,
        banca: prova.banca,
        concurso: `${prova.orgao} - ${prova.cargo}`,
        ano: prova.ano,
        enunciado: questao.enunciado.trim(),
        fonte: fonteCompativel(prova, item.numero_original),
        prova_id: provaId,
        numero_original: item.numero_original,
      });
      await repo.inserirAlternativas(
        questaoId,
        questao.alternativas.map((a, indice) => ({ texto: a.texto.trim(), ordem: indice + 1, correta: a.correta === true })),
      );
      for (const cursoId of item.curso_ids_aprovados) {
        await repo.inserirVinculo(cursoId, questaoId);
        vinculosEsperados.push({ curso_id: cursoId, questao_id: questaoId });
      }
      inseridas.push({ numero_original: item.numero_original, questao_id: questaoId, total_alternativas: questao.alternativas.length, curso_ids: item.curso_ids_aprovados });
    }

    const estado = await repo.lerEstadoPosCheck({ provaId, questaoIds: inseridas.map((i) => i.questao_id) });
    const estruturaDepois = await repo.contagensEstruturais();
    const mutaveisDepois = await repo.contagensMutaveis();
    const falhas = avaliarPosCheck({
      estado,
      estruturaAntes,
      estruturaDepois,
      mutaveisAntes,
      mutaveisDepois,
      provaNova: prova.prova_id_existente === null,
      prova,
      inseridas,
      vinculosEsperados,
      totalAntes,
      documentosEsperados: manifesto.documentos,
      documentosNovos: documentosNovos.length,
    });
    if (falhas.length > 0) throw new ErroAquisicao("pós-check falhou — ROLLBACK", { falhas });

    if (modo === "teste-rollback") await repo.desfazer();
    else await repo.confirmar();

    return {
      modo,
      manifesto,
      hash,
      gravado: modo === "apply",
      prova_id: provaId,
      prova_reutilizada: prova.prova_id_existente !== null,
      inseridas,
      pos_check: { ok: true, falhas: [] },
      // Contagens DENTRO da transação (antes de gravar / depois de gravar,
      // antes do COMMIT ou ROLLBACK) — no teste-rollback mostram o que
      // teria sido gravado.
      contagens_na_transacao: { antes: mutaveisAntes, depois: mutaveisDepois },
    };
  } catch (erro) {
    await repo.desfazer();
    throw erro;
  }
}

// Relatório de auditoria (gravado pelo CLI em output/): qual prova, qual
// hash, quando, e o destino de cada questão.
export function montarRelatorioAquisicao(resultado, geradoEm = new Date().toISOString()) {
  const { manifesto } = resultado;
  const inseridas = resultado.inseridas ?? [];
  const porCurso = {};
  for (const v of manifesto.vinculos) porCurso[v.curso_slug] = inseridas.filter((i) => i.curso_ids.includes(v.curso_id)).length;
  return {
    gerado_em: geradoEm,
    modo_execucao: resultado.modo,
    gravado: resultado.gravado,
    hash_manifesto: resultado.hash,
    modo_aquisicao: manifesto.modo,
    prova: {
      id: resultado.prova_id ?? manifesto.prova.prova_id_existente,
      situacao: manifesto.prova.situacao,
      nome: manifesto.prova.nome,
      hash_prova: manifesto.prova.hash_prova,
      hash_gabarito: manifesto.prova.hash_gabarito,
    },
    documentos: manifesto.documentos,
    bloqueios: manifesto.bloqueios,
    previsto: manifesto.resumo,
    efetivado: resultado.inseridas
      ? { questoes_inseridas: inseridas.length, vinculadas_por_curso: porCurso, somente_globais: inseridas.filter((i) => i.curso_ids.length === 0).length }
      : null,
    pos_check: resultado.pos_check ?? null,
    contagens_na_transacao: resultado.contagens_na_transacao ?? null,
  };
}
