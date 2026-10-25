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

import { createHash } from "node:crypto";
import { hashManifesto, planejarAquisicao } from "./planejar.mjs";
import { chaveDeConteudo } from "../deduplicar.mjs";

// MÍDIAS (Storage x transação SQL — o Storage NÃO participa do BEGIN):
//   - objeto conteúdo-endereçado (questoes/<sha256>.png): sem identidade
//     fora do hash, reenvio idempotente, compartilhável entre questões;
//   - lock consultivo de SESSÃO "questao-midias" do envio até a limpeza:
//     applies concorrentes (e o GC futuro) nunca se cruzam;
//   - envio ANTES das linhas, com a transação aberta; cada objeto é
//     baixado de volta e conferido por hash;
//   - pós-check DENTRO da transação confere storage.objects (existe, com o
//     tamanho dos bytes do manifesto) e as linhas de questao_midias;
//   - falha ou teste-rollback: ROLLBACK e, depois, remoção SÓ dos objetos
//     criados nesta execução que nenhuma linha referencia. Objeto que já
//     existia nunca é apagado. Se a própria limpeza falhar, sobra um
//     objeto privado sem linha (nunca servido) — o relatório lista o path.
const sha256 = (dados) => createHash("sha256").update(dados).digest("hex");

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
    parteCodigo: entrada.proveniencia?.parte?.codigo ?? null,
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
function avaliarPosCheck({ estado, estruturaAntes, estruturaDepois, mutaveisAntes, mutaveisDepois, provaNova, prova, parteId = null, inseridas, vinculosEsperados, totalAntes, documentosEsperados, documentosNovos, midiasEsperadas = [], objetosMidia = null }) {
  const falhas = [];
  const parte = prova.parte ?? null;
  const deltasEsperados = {
    provas: provaNova ? 1 : 0,
    ...("prova_partes" in mutaveisAntes ? { prova_partes: parte?.situacao === "NOVA" ? 1 : 0 } : {}),
    prova_documentos: documentosNovos,
    questoes: inseridas.length,
    alternativas: inseridas.reduce((soma, i) => soma + i.total_alternativas, 0),
    curso_questoes: vinculosEsperados.length,
    ...("questao_midias" in mutaveisAntes ? { questao_midias: midiasEsperadas.length } : {}),
  };
  // Cada mídia gravada = exatamente a do manifesto (questão, ordem, hash,
  // path, direito) e com o objeto presente no bucket com o tamanho certo.
  const chaveMidia = (m) => `${m.questao_id}|${m.ordem}|${m.sha256}|${m.storage_path}|${m.direito_uso}`;
  const midiasReais = new Set((estado.midias ?? []).map(chaveMidia));
  for (const m of midiasEsperadas) {
    if (!midiasReais.has(chaveMidia(m))) falhas.push(`mídia da questão ${m.questao_id} ordem ${m.ordem} ausente ou divergente do manifesto`);
    const tamanho = objetosMidia?.get(m.storage_path);
    if (tamanho === undefined) falhas.push(`objeto ${m.storage_path} ausente no bucket`);
    else if (tamanho !== m.bytes) falhas.push(`objeto ${m.storage_path} com ${tamanho} bytes, esperado ${m.bytes}`);
  }
  if ((estado.midias ?? []).length !== midiasEsperadas.length) falhas.push(`questao_midias das questões inseridas: ${(estado.midias ?? []).length}, esperado ${midiasEsperadas.length}`);
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
  if (parte) {
    const gravada = estado.parte ?? null;
    if (!gravada || gravada.id !== parteId || gravada.codigo !== parte.codigo || gravada.nome !== parte.nome || gravada.ordem !== parte.ordem) falhas.push(`parte ${parte.codigo} não encontrada na prova com o código/nome/ordem do manifesto`);
    for (const q of estado.questoesDaProva) if (q.prova_parte_id !== parteId) falhas.push(`questão ${q.id}: prova_parte_id ${q.prova_parte_id}, esperado ${parteId}`);
  }

  const daProva = estado.questoesDaProva;
  if (daProva.length !== totalAntes + inseridas.length) {
    falhas.push(`questões da prova: esperado ${totalAntes + inseridas.length}, encontrado ${daProva.length}`);
  }
  const numeros = daProva.map((q) => q.numero_original);
  if (new Set(numeros).size !== numeros.length) falhas.push("numero_original duplicado dentro da prova");
  // Mesma questão duas vezes na prova = mesmo conteúdo (enunciado +
  // alternativas); comando genérico igual entre questões diferentes não é.
  const conteudos = daProva.map(chaveDeConteudo);
  if (new Set(conteudos).size !== conteudos.length) falhas.push("conteúdo (enunciado e alternativas) duplicado dentro da prova");

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

export async function executarAquisicao({ repo, entrada, modo = "dry-run", hashManifestoAprovado = null, storage = null }) {
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

  // Objetos criados NESTA execução (só eles podem ser limpos) e o lock de
  // mídias (sessão) — liberado no finally, depois da limpeza.
  const criados = [];
  let lockMidias = false;
  const limparCriados = async () => {
    const limpeza = { removidos: [], mantidos: [], falhas: [] };
    for (const objeto of criados) {
      try {
        if (await repo.midiaReferenciada(objeto.sha256)) limpeza.mantidos.push(objeto.storage_path);
        else {
          await storage.remover(objeto.storage_path);
          limpeza.removidos.push(objeto.storage_path);
        }
      } catch (erro) {
        limpeza.falhas.push({ storage_path: objeto.storage_path, erro: erro.message });
      }
    }
    return limpeza;
  };

  await repo.iniciar({ somenteLeitura: false, chaveLock: entrada.proveniencia?.prova?.hash_prova ?? "sem-hash" });
  try {
    const { manifesto, hash } = await planejar(repo, entrada);
    if (hash !== hashManifestoAprovado) {
      throw new ErroAquisicao("o plano atual difere do manifesto aprovado (staging ou banco mudaram desde o dry-run) — rode o dry-run de novo", { hashAtual: hash });
    }
    if (manifesto.bloqueios.length > 0) throw new ErroAquisicao("manifesto com bloqueios — nada gravado", { bloqueios: manifesto.bloqueios });

    const importar = manifesto.questoes.filter((q) => q.acao === "IMPORTAR");

    // ---- mídias: enviar (ou reconferir) os objetos ANTES das linhas ----
    const objetos = new Map();
    for (const item of importar) for (const m of item.midias ?? []) objetos.set(m.sha256, m);
    if (objetos.size > 0) {
      if (!storage) throw new ErroAquisicao("apply com mídia exige o Storage configurado (SUPABASE_URL e SUPABASE_SERVICE_ROLE_KEY) — nada gravado");
      await repo.bloquearMidias();
      lockMidias = true;
      const existentes = await repo.objetosMidia([...objetos.values()].map((m) => m.storage_path));
      for (const m of objetos.values()) {
        const bytes = entrada.midiasArquivos?.get(m.sha256);
        if (!bytes || sha256(bytes) !== m.sha256) throw new ErroAquisicao(`bytes da mídia ${m.sha256.slice(0, 12)}… ausentes ou com hash diferente do manifesto — nada gravado`);
        if (!existentes.has(m.storage_path)) {
          await storage.enviar(m.storage_path, bytes, m.mime_type);
          criados.push({ storage_path: m.storage_path, sha256: m.sha256 });
        }
        const devolvido = await storage.baixar(m.storage_path);
        if (sha256(devolvido) !== m.sha256) throw new ErroAquisicao(`objeto ${m.storage_path} no bucket não confere com o hash da mídia`);
      }
    }

    const estruturaAntes = await repo.contagensEstruturais();
    const mutaveisAntes = await repo.contagensMutaveis();
    const prova = manifesto.prova;
    const provaId = prova.prova_id_existente ?? (await repo.inserirProva(entrada.proveniencia.prova));
    // Documentos que determinaram o gabarito final — só os NOVO; os já
    // registrados foram conferidos por hash no planejamento.
    const documentosNovos = manifesto.documentos.filter((d) => d.situacao === "NOVO");
    for (const documento of documentosNovos) await repo.inserirDocumento(provaId, documento);
    // Parte da prova (P1/P2): numeração e pós-check valem dentro dela.
    const parte = prova.parte ?? null;
    const parteId = parte ? (parte.prova_parte_id_existente ?? (await repo.inserirParte(provaId, parte))) : null;
    const totalAntes = (await repo.lerEstadoPosCheck({ provaId, parteId, questaoIds: [] })).questoesDaProva.length;

    const porNumero = new Map(entrada.questoes.map((q) => [q.numero_original, q]));
    const inseridas = [];
    const vinculosEsperados = [];
    const midiasEsperadas = [];
    for (const item of importar) {
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
        ...(parteId !== null ? { prova_parte_id: parteId } : {}),
        numero_original: item.numero_original,
      });
      await repo.inserirAlternativas(
        questaoId,
        questao.alternativas.map((a, indice) => ({ texto: a.texto.trim(), ordem: indice + 1, correta: a.correta === true })),
      );
      for (const m of item.midias ?? []) {
        const linha = { questao_id: questaoId, prova_id: provaId, ...m };
        await repo.inserirMidia(linha);
        midiasEsperadas.push({ ...linha, bytes: entrada.midiasArquivos.get(m.sha256).length });
      }
      for (const cursoId of item.curso_ids_aprovados) {
        await repo.inserirVinculo(cursoId, questaoId);
        vinculosEsperados.push({ curso_id: cursoId, questao_id: questaoId });
      }
      inseridas.push({ numero_original: item.numero_original, questao_id: questaoId, total_alternativas: questao.alternativas.length, curso_ids: item.curso_ids_aprovados, midias: (item.midias ?? []).length });
    }

    const estado = await repo.lerEstadoPosCheck({ provaId, parteId, questaoIds: inseridas.map((i) => i.questao_id) });
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
      parteId,
      inseridas,
      vinculosEsperados,
      totalAntes,
      documentosEsperados: manifesto.documentos,
      documentosNovos: documentosNovos.length,
      midiasEsperadas,
      objetosMidia: midiasEsperadas.length > 0 ? await repo.objetosMidia(midiasEsperadas.map((m) => m.storage_path)) : null,
    });
    if (falhas.length > 0) throw new ErroAquisicao("pós-check falhou — ROLLBACK", { falhas });

    let limpeza = null;
    if (modo === "teste-rollback") {
      await repo.desfazer();
      limpeza = await limparCriados();
    } else await repo.confirmar();

    return {
      modo,
      manifesto,
      hash,
      gravado: modo === "apply",
      prova_id: provaId,
      ...(parteId !== null ? { prova_parte_id: parteId } : {}),
      prova_reutilizada: prova.prova_id_existente !== null,
      inseridas,
      pos_check: { ok: true, falhas: [] },
      midias: { enviadas: criados.map((c) => c.storage_path), reaproveitadas: [...objetos.values()].map((m) => m.storage_path).filter((p) => !criados.some((c) => c.storage_path === p)), limpeza },
      // Contagens DENTRO da transação (antes de gravar / depois de gravar,
      // antes do COMMIT ou ROLLBACK) — no teste-rollback mostram o que
      // teria sido gravado.
      contagens_na_transacao: { antes: mutaveisAntes, depois: mutaveisDepois },
    };
  } catch (erro) {
    await repo.desfazer();
    if (criados.length > 0) {
      const limpeza = await limparCriados();
      if (erro instanceof ErroAquisicao) erro.detalhes = { ...erro.detalhes, limpeza_midias: limpeza };
    }
    throw erro;
  } finally {
    if (lockMidias) await repo.liberarMidias();
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
      ...(manifesto.prova.parte ? { parte: { ...manifesto.prova.parte, id: resultado.prova_parte_id ?? manifesto.prova.parte.prova_parte_id_existente } } : {}),
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
