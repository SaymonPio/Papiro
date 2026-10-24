// Planejador da aquisição — função PURA: recebe o staging aprovado
// (questoes_extraidas.json + proveniência do relatório), um retrato do
// banco lido pelo repositório e a aprovação explícita do admin, e devolve
// o MANIFESTO determinístico com a ação de cada questão. Nunca escreve,
// nunca lê nada sozinho — por isso é o mesmo código no dry-run, no apply
// (replanejado DENTRO da transação) e nos testes.
//
// Regra central: PROVENIÊNCIA != VÍNCULO PEDAGÓGICO. A origem da prova
// (órgão, banca, cargo) nunca é lida aqui para decidir curso. Um vínculo
// só nasce de (curso explicitamente pedido) × (matéria explicitamente
// aprovada para aquele curso) × (matéria presente na estrutura ATUAL do
// curso, curso_materias.materia_id). Nenhuma matéria, curso_conteudo,
// peso ou edital é criado.
//
// Gates de IMPORTAR reaproveitam as regras de importar_questoes_dry_run
// (supabase/importar_questoes_lote.sql): alternativas A-D obrigatórias e
// no máximo A-E, exatamente uma correta, enunciado obrigatório, matéria
// global existente, assunto global da mesma matéria, quebra de parsing
// via alternativa_tem_sequencia_embutida() (avaliada no banco pelo
// repositório). A deduplicação é a de deduplicar.mjs, agora contra o
// banco vivo em vez de snapshot.

import { createHash } from "node:crypto";
import { classificarDuplicidade, normalizarTexto } from "../deduplicar.mjs";
import { causasDeExtracao, causasDeMidia } from "../score.mjs";

export const MODOS = ["BASE_GLOBAL", "BASE_GLOBAL_COM_VINCULO"];
const LETRAS = ["A", "B", "C", "D", "E"];
export const VERSAO_MANIFESTO = 1;

// JSON canônico (chaves ordenadas) — base do hash do manifesto, para que
// dry-run e apply comparem conteúdo, nunca ordem de serialização.
export function jsonCanonico(valor) {
  if (Array.isArray(valor)) return `[${valor.map(jsonCanonico).join(",")}]`;
  if (valor && typeof valor === "object") {
    return `{${Object.keys(valor)
      .sort()
      .filter((chave) => valor[chave] !== undefined)
      .map((chave) => `${JSON.stringify(chave)}:${jsonCanonico(valor[chave])}`)
      .join(",")}}`;
  }
  return JSON.stringify(valor ?? null);
}

export function hashManifesto(manifesto) {
  return createHash("sha256").update(jsonCanonico(manifesto)).digest("hex");
}

// Hash do conteúdo que será gravado — liga o manifesto aprovado ao texto
// real: se o staging mudar entre o dry-run e o apply, o hash muda.
export function hashConteudoQuestao(questao) {
  return createHash("sha256")
    .update(
      jsonCanonico({
        enunciado: questao.enunciado ?? null,
        alternativas: (questao.alternativas ?? []).map((a) => ({ letra: a.letra, texto: a.texto, correta: a.correta === true })),
      }),
    )
    .digest("hex");
}

export function chaveSequencia(numero, letra) {
  return `${numero}:${letra}`;
}

function normalizarChave(valor) {
  return String(valor ?? "").trim().toLowerCase();
}

function mesmaProva(existente, prova) {
  return (
    ["banca", "orgao", "cargo", "nome"].every((campo) => normalizarChave(existente[campo]) === normalizarChave(prova[campo])) &&
    existente.ano === prova.ano &&
    existente.hash_gabarito === prova.hash_gabarito
  );
}

// Resolve cada matéria pedida contra a estrutura atual do curso — por id
// (preferido) ou por nome EXATO (trim) do curso_materias.nome ou do
// materias.nome. O que não estiver na estrutura vira "rejeitada", nunca
// um vínculo.
function resolverVinculos(pedidos, cursosNoBanco) {
  const vinculos = [];
  const bloqueios = [];
  for (const pedido of pedidos) {
    const curso = cursosNoBanco.find((c) => c.slug === pedido.curso);
    if (!curso) {
      bloqueios.push(`curso "${pedido.curso}" não existe`);
      continue;
    }
    if (!Array.isArray(pedido.materias) || pedido.materias.length === 0) {
      bloqueios.push(`vínculo com "${pedido.curso}" exige lista explícita de matérias aprovadas — vínculo implícito pela origem da prova é proibido`);
      continue;
    }
    const aprovadas = new Set();
    const rejeitadas = [];
    for (const valor of pedido.materias) {
      const comoId = typeof valor === "number" || /^\d+$/.test(String(valor).trim()) ? Number(valor) : null;
      const encontrada = curso.materias.find((m) =>
        comoId !== null ? m.materia_id === comoId : m.nome_curso.trim() === String(valor).trim() || m.nome_materia.trim() === String(valor).trim(),
      );
      if (encontrada) aprovadas.add(encontrada.materia_id);
      else rejeitadas.push({ valor, motivo: "matéria não faz parte da estrutura atual do curso — nenhum vínculo será criado" });
    }
    vinculos.push({
      curso_id: curso.id,
      curso_slug: curso.slug,
      materia_ids_aprovadas: [...aprovadas].sort((a, b) => a - b),
      materias_rejeitadas: rejeitadas,
    });
  }
  return { vinculos, bloqueios };
}

// Documentos que determinaram o gabarito final (public.prova_documentos):
// GABARITO na ordem 0 + cada retificação na sua ordem explícita. Prova
// nova: todos NOVO. Prova já cadastrada: o conjunto registrado precisa ser
// EXATAMENTE o mesmo (tipo, ordem, hash) — documento com outro hash, a
// mais ou a menos é bloqueio, nunca correção silenciosa (uma retificação
// nova para prova já importada mudaria gabaritos já gravados, e isso é
// saneamento, não aquisição).
export function chaveDocumento(documento) {
  return `${documento.tipo}:${documento.ordem}`;
}

function resolverDocumentos(prova, retificacoes, existentes, provaExiste) {
  const bloqueios = [];
  const esperados = [
    { tipo: "GABARITO", ordem: 0, url: prova.gabarito_url ?? null, hash_sha256: prova.hash_gabarito ?? null },
    ...retificacoes.map((r) => ({ tipo: "RETIFICACAO", ordem: r.ordem, url: r.url ?? null, hash_sha256: r.hash ?? null })),
  ];
  for (const doc of esperados) {
    if (doc.tipo === "RETIFICACAO" && (!Number.isInteger(doc.ordem) || doc.ordem < 1 || doc.ordem > 99)) bloqueios.push(`retificação com ordem inválida (${doc.ordem}) — ordem explícita 1..99 é obrigatória`);
    if (!/^[0-9a-f]{64}$/.test(doc.hash_sha256 ?? "")) bloqueios.push(`documento ${chaveDocumento(doc)} sem hash SHA-256 válido`);
  }
  const posicoes = esperados.map(chaveDocumento);
  if (new Set(posicoes).size !== posicoes.length) bloqueios.push("duas retificações com a mesma ordem no manifesto");
  const hashes = esperados.map((d) => d.hash_sha256);
  if (new Set(hashes).size !== hashes.length) bloqueios.push("o mesmo documento (hash) aparece mais de uma vez entre gabarito e retificações");

  const registrados = new Map((existentes ?? []).map((d) => [chaveDocumento(d), d]));
  const documentos = esperados.map((doc) => {
    const registrado = registrados.get(chaveDocumento(doc));
    if (registrado && registrado.hash_sha256 !== doc.hash_sha256) {
      bloqueios.push(`documento ${chaveDocumento(doc)} já registrado para a prova com OUTRO hash (${registrado.hash_sha256.slice(0, 12)}…) — PARAR, nunca sobrescrever`);
    }
    return { ...doc, situacao: registrado ? "JA_REGISTRADO" : "NOVO" };
  });
  for (const [chave] of registrados) {
    if (!posicoes.includes(chave)) bloqueios.push(`documento ${chave} registrado para a prova não está no manifesto atual — PARAR`);
  }
  if (provaExiste && documentos.some((d) => d.situacao === "NOVO")) {
    bloqueios.push(`prova já cadastrada com outro conjunto de documentos de gabarito (novos: ${documentos.filter((d) => d.situacao === "NOVO").map(chaveDocumento).join(", ")}) — gabaritos já gravados exigiriam saneamento, não aquisição`);
  }
  return { documentos, bloqueios };
}

// Parte da prova (public.prova_partes): P1/P2 de um mesmo documento
// oficial, cada uma com numeração própria. numero_original continua sendo
// o número impresso; "já importada" e unicidade valem DENTRO da parte.
// Nunca mistura os modelos: prova com questões sem parte não recebe
// partes, e prova organizada em partes não recebe questão sem parte. A
// mesma parte reaparecendo precisa ter o mesmo nome e ordem.
function resolverParte(parte, contexto, provaExiste) {
  const bloqueios = [];
  const partesDaProva = provaExiste ? contexto.partesDaProva ?? [] : [];
  if (!parte) {
    if (provaExiste && (contexto.questoesComParteNaProva ?? 0) > 0) bloqueios.push("prova organizada em partes (prova_partes) — o staging precisa declarar a parte (metadata.parte)");
    return { parte: null, bloqueios };
  }
  if (!contexto.temTabelaPartes) bloqueios.push("o staging declara a parte da prova, mas o banco não tem public.prova_partes — aplicar a migration antes");
  if (provaExiste && (contexto.questoesSemParteNaProva ?? 0) > 0) bloqueios.push("prova já cadastrada com questões sem parte — não misturar o modelo com partes e o sem partes");
  const existente = partesDaProva.find((p) => p.codigo === parte.codigo) ?? null;
  if (existente && (existente.nome !== parte.nome || existente.ordem !== parte.ordem)) {
    bloqueios.push(`parte ${parte.codigo} já cadastrada com outro nome/ordem (prova_partes.id=${existente.id}) — PARAR, nunca sobrescrever`);
  }
  if (!existente && partesDaProva.some((p) => p.ordem === parte.ordem)) bloqueios.push(`ordem ${parte.ordem} já usada por outra parte desta prova`);
  return {
    parte: { codigo: parte.codigo, nome: parte.nome, ordem: parte.ordem, prova_parte_id_existente: existente?.id ?? null, situacao: existente ? "EXISTENTE" : "NOVA" },
    bloqueios,
  };
}

// Liberação explícita de gate conservador (aprovacao.liberacoes): depois
// de revisão humana, uma CAUSA heurística de um gate do staging pode ser
// liberada para UMA questão — nunca o gate inteiro, nunca implicitamente.
//   { "numero_original": 10, "gate": "EXTRACAO_OK",
//     "motivo": "dependencia_texto_incerta", "justificativa": "...",
//     "conteudo_hash": "<sha256 opcional do candidato revisado>" }
// Com conteudo_hash, a liberação só vale para aquele conteúdo
// (hashConteudoQuestao): se o candidato mudar, ela caduca e a questão
// volta a REVISAR.
// Só causas em que o conteúdo gravado está íntegro e a dúvida se resolve
// lendo a questão. Conteúdo faltante/corrompido (alternativa faltante,
// texto-base ou expressão não reconstruídos...) nunca é liberável: exige
// corrigir o staging.
export const CAUSAS_LIBERAVEIS = {
  EXTRACAO_OK: ["dependencia_texto_incerta", "alternativa_suspeita", "referencia_visual"],
  // Figura achada na região da questão sem o texto citá-la: a revisão
  // humana confirma que ela pertence à questão. Mídia ausente, posse
  // ambígua, composição ou posição incertas exigem corrigir o staging.
  MIDIA_OK: ["midia_sem_referencia"],
  // Similaridade que a revisão humana comparou e descartou: a liberação
  // nomeia a questão do banco comparada (questao_id) e só vale para ela.
  // Duplicada exata nunca é liberável.
  DEDUP_OK: ["provavel_duplicada"],
};
const CAUSAS_POR_GATE = { EXTRACAO_OK: causasDeExtracao, MIDIA_OK: causasDeMidia };
const JUSTIFICATIVA_MINIMA = 20;

function validarLiberacoes(liberacoes, numerosDoLote) {
  const bloqueios = [];
  const porNumero = new Map();
  if (liberacoes === undefined) return { porNumero, bloqueios };
  if (!Array.isArray(liberacoes)) return { porNumero, bloqueios: ["aprovacao.liberacoes precisa ser uma lista"] };
  const vistas = new Set();
  for (const [indice, l] of liberacoes.entries()) {
    const rotulo = `liberação #${indice + 1}`;
    const motivosDoGate = CAUSAS_LIBERAVEIS[l?.gate];
    if (!Number.isInteger(l?.numero_original) || !numerosDoLote.has(l.numero_original)) bloqueios.push(`${rotulo}: numero_original ${l?.numero_original} não existe no lote`);
    else if (!motivosDoGate) bloqueios.push(`${rotulo}: gate "${l?.gate}" não admite liberação explícita (liberáveis: ${Object.keys(CAUSAS_LIBERAVEIS).join(", ")})`);
    else if (!motivosDoGate.includes(l.motivo)) bloqueios.push(`${rotulo}: motivo "${l.motivo}" não é liberável em ${l.gate} (liberáveis: ${motivosDoGate.join(", ")})`);
    else if (l.gate === "DEDUP_OK" && !(Number.isInteger(l.questao_id) && l.questao_id > 0)) bloqueios.push(`${rotulo}: DEDUP_OK exige questao_id da questão do banco comparada`);
    else if (l.gate !== "DEDUP_OK" && l.questao_id !== undefined) bloqueios.push(`${rotulo}: questao_id só se aplica a DEDUP_OK`);
    else if (typeof l.justificativa !== "string" || l.justificativa.trim().length < JUSTIFICATIVA_MINIMA) bloqueios.push(`${rotulo}: justificativa da revisão humana ausente ou curta demais`);
    else if (l.conteudo_hash !== undefined && !(typeof l.conteudo_hash === "string" && /^[0-9a-f]{64}$/.test(l.conteudo_hash))) bloqueios.push(`${rotulo}: conteudo_hash precisa ser o sha256 (64 hex) do conteúdo revisado`);
    else if (vistas.has(`${l.numero_original}:${l.gate}:${l.motivo}:${l.questao_id ?? ""}`)) bloqueios.push(`${rotulo}: liberação repetida para nº ${l.numero_original} ${l.gate}/${l.motivo}`);
    else {
      vistas.add(`${l.numero_original}:${l.gate}:${l.motivo}:${l.questao_id ?? ""}`);
      const lista = porNumero.get(l.numero_original) ?? [];
      lista.push({
        gate: l.gate,
        motivo: l.motivo,
        ...(l.gate === "DEDUP_OK" ? { questao_id: l.questao_id } : {}),
        ...(l.conteudo_hash !== undefined ? { conteudo_hash: l.conteudo_hash } : {}),
        justificativa: l.justificativa.trim(),
      });
      porNumero.set(l.numero_original, lista);
    }
  }
  return { porNumero, bloqueios };
}

// Gate falhando é liberado só se TODA causa presente estiver liberada
// explicitamente; causa desconhecida (gate falso sem causa identificável)
// nunca é liberada.
function avaliarLiberacao(questao, gate, liberacoesDaQuestao) {
  const doGate = liberacoesDaQuestao.filter((l) => l.gate === gate);
  if (doGate.length === 0) return { liberado: false, aplicadas: [], pendentes: null };
  const causas = (CAUSAS_POR_GATE[gate]?.(questao) ?? []).map((c) => c.codigo);
  const pendentes = causas.filter((c) => !doGate.some((l) => l.motivo === c));
  const aplicadas = doGate.filter((l) => causas.includes(l.motivo));
  return { liberado: causas.length > 0 && pendentes.length === 0, aplicadas, pendentes: causas.length > 0 ? pendentes : ["causa não identificada"] };
}

// DEDUP_OK: cada suspeita (staging e banco vivo) é uma questao_id; só
// libera se TODAS forem prováveis duplicadas com liberação para aquele
// id. Suspeita sem id (duplicada exata, staging sem match) nunca libera.
function avaliarLiberacaoDedup(questao, dedup, liberacoesDaQuestao) {
  const suspeitas = new Set();
  if (questao.etapas?.DEDUP_OK === false) suspeitas.add(questao.dedup?.status === "provavel_duplicada" ? (questao.dedup.match_id ?? null) : null);
  if (dedup.status === "provavel_duplicada") suspeitas.add(dedup.match_id ?? null);
  const aplicadas = liberacoesDaQuestao.filter((l) => l.gate === "DEDUP_OK" && suspeitas.has(l.questao_id));
  const liberado = suspeitas.size > 0 && [...suspeitas].every((id) => id !== null && aplicadas.some((l) => l.questao_id === id));
  return { liberado, aplicadas };
}

// Direito de uso de mídia (aprovacao.direitos_midia): a extração marca
// peça de terceiro (charge, foto, cartaz, crédito...) como
// REVISAO_DIREITOS; só uma decisão humana explícita, por questão E por
// arquivo (sha256), a libera. Crédito nunca é permissão.
//   { "numero_original": 2, "sha256": "<64 hex>", "direito_uso": "LICENCIADO",
//     "justificativa": "..." }
export const TIPOS_MIDIA = ["FIGURA", "GRAFICO", "TABELA", "MAPA", "CHARGE"];
const DIREITOS_DECIDIVEIS = ["OFICIAL_PROVA", "LICENCIADO"];

function validarDecisoesDeDireito(decisoes, numerosDoLote) {
  const bloqueios = [];
  const porNumero = new Map();
  if (decisoes === undefined) return { porNumero, bloqueios };
  if (!Array.isArray(decisoes)) return { porNumero, bloqueios: ["aprovacao.direitos_midia precisa ser uma lista"] };
  const vistas = new Set();
  for (const [indice, d] of decisoes.entries()) {
    const rotulo = `decisão de direito #${indice + 1}`;
    if (!Number.isInteger(d?.numero_original) || !numerosDoLote.has(d.numero_original)) bloqueios.push(`${rotulo}: numero_original ${d?.numero_original} não existe no lote`);
    else if (!/^[0-9a-f]{64}$/.test(d.sha256 ?? "")) bloqueios.push(`${rotulo}: sha256 da mídia ausente ou inválido`);
    else if (!DIREITOS_DECIDIVEIS.includes(d.direito_uso)) bloqueios.push(`${rotulo}: direito_uso "${d.direito_uso}" inválido (use ${DIREITOS_DECIDIVEIS.join(" ou ")})`);
    else if (typeof d.justificativa !== "string" || d.justificativa.trim().length < JUSTIFICATIVA_MINIMA) bloqueios.push(`${rotulo}: justificativa ausente ou curta demais`);
    else if (vistas.has(`${d.numero_original}:${d.sha256}`)) bloqueios.push(`${rotulo}: decisão repetida`);
    else {
      vistas.add(`${d.numero_original}:${d.sha256}`);
      porNumero.set(d.numero_original, [...(porNumero.get(d.numero_original) ?? []), { sha256: d.sha256, direito_uso: d.direito_uso, justificativa: d.justificativa.trim() }]);
    }
  }
  return { porNumero, bloqueios };
}

function validarAlternativas(questao, sequenciaEmbutida) {
  const alternativas = questao.alternativas ?? [];
  if (alternativas.length < 4) return "menos de 4 alternativas (A-D são obrigatórias)";
  if (alternativas.length > LETRAS.length) return `mais de ${LETRAS.length} alternativas (o banco só aceita A-E)`;
  for (const [indice, alternativa] of alternativas.entries()) {
    if (alternativa.letra !== LETRAS[indice]) return `alternativas fora de ordem (esperado ${LETRAS[indice]}, veio ${alternativa.letra})`;
    if (!alternativa.texto || alternativa.texto.trim() === "") return `alternativa ${alternativa.letra} vazia`;
    if (sequenciaEmbutida.has(chaveSequencia(questao.numero_original, alternativa.letra))) {
      return `possível quebra de parsing — a alternativa ${alternativa.letra} contém uma sequência a)/b)/c)/d)`;
    }
  }
  const corretas = alternativas.filter((a) => a.correta === true).length;
  if (corretas !== 1) return `${corretas} alternativas corretas (exigido exatamente 1)`;
  return null;
}

function resolverClassificacao(questao, override, contexto) {
  let materiaId = null;
  let assuntoId = null;
  let status;
  if (override) {
    materiaId = override.materia_id ?? null;
    assuntoId = override.assunto_id ?? null;
    status = "override";
  } else if (questao.confidence === "alta") {
    materiaId = questao.materia_sugerida ?? null;
    assuntoId = questao.assunto_sugerido ?? null;
    status = "alta";
  } else {
    status = "incerta";
  }

  if (materiaId === null) return { materiaId, assuntoId, status, motivo: "matéria não confirmada (classificação automática incerta e sem aprovação manual)" };
  const materia = contexto.materias.get(materiaId);
  if (!materia) return { materiaId, assuntoId, status, motivo: `materia_id ${materiaId} não existe como matéria global` };
  if (materia.ativo === false) return { materiaId, assuntoId, status, motivo: `materia_id ${materiaId} está inativa` };
  if (assuntoId !== null) {
    const assunto = contexto.assuntos.get(assuntoId);
    if (!assunto) return { materiaId, assuntoId, status, motivo: `assunto_id ${assuntoId} não existe como assunto global` };
    if (assunto.materia_id !== materiaId) return { materiaId, assuntoId, status, motivo: `assunto_id ${assuntoId} não pertence à matéria ${materiaId}` };
  }
  return { materiaId, assuntoId, status, motivo: null };
}

export function planejarAquisicao({ modo, proveniencia, questoes, contexto, aprovacao = {}, midiasVerificadas = null }) {
  const bloqueios = [];
  if (!MODOS.includes(modo)) bloqueios.push(`modo inválido "${modo}" (use ${MODOS.join(" ou ")})`);

  const pedidos = aprovacao.vinculos ?? [];
  if (modo === "BASE_GLOBAL" && pedidos.length > 0) bloqueios.push("modo BASE_GLOBAL não aceita vínculos — use BASE_GLOBAL_COM_VINCULO");
  if (modo === "BASE_GLOBAL_COM_VINCULO" && pedidos.length === 0) bloqueios.push("modo BASE_GLOBAL_COM_VINCULO exige vínculos explícitos (curso + matérias aprovadas)");
  const { vinculos, bloqueios: bloqueiosVinculo } = resolverVinculos(modo === "BASE_GLOBAL_COM_VINCULO" ? pedidos : [], contexto.cursos ?? []);
  bloqueios.push(...bloqueiosVinculo);

  // ---- Prova ----
  // Gabarito preliminar (antes dos recursos) nunca é importável: respostas
  // ainda podem mudar ou ser anuladas.
  if (proveniencia?.gabarito_tipo === "preliminar") bloqueios.push("gabarito PRELIMINAR — aguardar o gabarito definitivo (pós-recursos) antes de qualquer apply");
  if (!proveniencia?.completa) {
    bloqueios.push(`proveniência incompleta (faltando: ${(proveniencia?.faltando ?? []).join(", ") || "-"}; inválidos: ${(proveniencia?.invalidos ?? []).join(", ") || "-"})`);
  }
  if (contexto.hashesDivergentes) bloqueios.push(contexto.hashesDivergentes);
  const prova = proveniencia?.prova ?? {};
  let provaIdExistente = null;
  if (contexto.provaPorHash) {
    if (mesmaProva(contexto.provaPorHash, prova)) provaIdExistente = contexto.provaPorHash.id;
    else bloqueios.push(`hash_prova já cadastrado (provas.id=${contexto.provaPorHash.id}) com metadados ou gabarito incompatíveis — PARAR, nunca sobrescrever`);
  } else if (contexto.provaPorChaveNatural) {
    bloqueios.push(
      `já existe prova com a mesma banca/órgão/cargo/ano/nome e OUTRO hash (provas.id=${contexto.provaPorChaveNatural.id}) — mesmo exame, documento diferente: PARAR`,
    );
  }

  const { documentos, bloqueios: bloqueiosDocumentos } = resolverDocumentos(prova, proveniencia?.retificacoes ?? [], contexto.documentosDaProva ?? [], provaIdExistente !== null);
  bloqueios.push(...bloqueiosDocumentos);
  const { parte, bloqueios: bloqueiosParte } = resolverParte(proveniencia?.parte ?? null, contexto, provaIdExistente !== null);
  bloqueios.push(...bloqueiosParte);

  // ---- Questões ----
  const overrides = aprovacao.classificacao ?? {};
  const { porNumero: liberacoesPorNumero, bloqueios: bloqueiosLiberacao } = validarLiberacoes(aprovacao.liberacoes, new Set(questoes.map((q) => q.numero_original)));
  bloqueios.push(...bloqueiosLiberacao);
  const { porNumero: direitosPorNumero, bloqueios: bloqueiosDireitos } = validarDecisoesDeDireito(aprovacao.direitos_midia, new Set(questoes.map((q) => q.numero_original)));
  bloqueios.push(...bloqueiosDireitos);
  const contagemNumeros = new Map();
  for (const q of questoes) contagemNumeros.set(q.numero_original, (contagemNumeros.get(q.numero_original) ?? 0) + 1);
  const enunciadosDoLote = new Map();
  const ordenadas = [...questoes].sort((a, b) => (a.numero_original ?? 0) - (b.numero_original ?? 0));

  const planejadas = ordenadas.map((questao) => {
    const numero = questao.numero_original;
    const etapas = questao.etapas ?? {};
    const anulada = questao._interno?.gabarito_anulado === true;
    const classificacao = resolverClassificacao(questao, overrides[String(numero)], contexto);
    const jaImportadaId = contexto.numerosJaImportados?.get(numero) ?? null;
    const dedup = jaImportadaId !== null ? { status: "ja_importada", match_id: jaImportadaId } : classificarDuplicidade(questao, contexto.questoesGlobais ?? []);

    const item = {
      numero_original: numero,
      materia_id: classificacao.materiaId,
      assunto_id: classificacao.assuntoId,
      status_extracao: etapas.EXTRACAO_OK ? "OK" : "FALHA",
      status_gabarito: anulada ? "ANULADA" : etapas.GABARITO_OK ? "OK" : "FALHA",
      status_deduplicacao: dedup.status,
      status_classificacao: classificacao.status,
      anulada,
      acao: "IMPORTAR",
      motivos: [],
      curso_ids_aprovados: [],
      questao_id_existente: dedup.match_id ?? null,
      conteudo_hash: hashConteudoQuestao(questao),
    };
    const revisar = (motivo) => {
      item.acao = "REVISAR";
      item.motivos.push(motivo);
    };
    const ignorar = (motivo) => {
      item.acao = "IGNORAR";
      item.motivos.push(motivo);
    };

    if (!Number.isInteger(numero) || numero < 1 || numero > 999) {
      revisar(`numero_original inválido (${numero})`);
      return item;
    }
    if (contagemNumeros.get(numero) > 1) {
      revisar(`numero_original ${numero} aparece mais de uma vez no lote`);
      return item;
    }
    if (dedup.status === "ja_importada") {
      ignorar(`já importada desta prova (questoes.id=${jaImportadaId})`);
      return item;
    }
    // O schema atual não representa questão anulada (toda questão tem
    // exatamente 1 alternativa correta) — anulada nunca é importada como
    // se tivesse gabarito.
    if (anulada) {
      ignorar("questão anulada pela banca — o banco atual não representa anulada; não importada");
      return item;
    }
    if (!etapas.PROVENIENCIA_OK) revisar("PROVENIENCIA_OK=false no staging");
    // Liberação revisada sobre outro conteúdo caducou: não libera nada.
    const caducas = (liberacoesPorNumero.get(numero) ?? []).filter((l) => l.conteudo_hash !== undefined && l.conteudo_hash !== item.conteudo_hash);
    if (caducas.length > 0) revisar(`liberação explícita revisada sobre outro conteúdo (${caducas.map((l) => `${l.gate}/${l.motivo}`).join(", ")}: conteudo_hash ${caducas[0].conteudo_hash.slice(0, 12)}… ≠ candidato ${item.conteudo_hash.slice(0, 12)}…) — o candidato mudou depois da revisão humana; revisar o aprovacao.json`);
    const liberacoesDaQuestao = (liberacoesPorNumero.get(numero) ?? []).filter((l) => !caducas.includes(l));
    const aplicadas = [];
    // MIDIA_OK ausente (staging anterior ao suporte a mídias) = sem mídia.
    for (const gate of ["EXTRACAO_OK", "MIDIA_OK"]) {
      const falhou = gate === "EXTRACAO_OK" ? !etapas.EXTRACAO_OK : etapas.MIDIA_OK === false;
      if (!falhou) continue;
      const liberacao = avaliarLiberacao(questao, gate, liberacoesDaQuestao);
      aplicadas.push(...liberacao.aplicadas);
      if (!liberacao.liberado) revisar(liberacao.pendentes ? `${gate}=false no staging — liberação explícita não cobre: ${liberacao.pendentes.join(", ")}` : `${gate}=false no staging${gate === "MIDIA_OK" ? ` (${causasDeMidia(questao).map((c) => c.motivo).join("; ")})` : ""}`);
    }
    const liberacaoDedup = avaliarLiberacaoDedup(questao, dedup, liberacoesDaQuestao);
    aplicadas.push(...liberacaoDedup.aplicadas);
    // Liberação sem causa pendente correspondente = aprovação desatualizada
    // (staging mudou depois da revisão humana): nunca é ignorada em silêncio.
    const semUso = liberacoesDaQuestao.filter((l) => !aplicadas.includes(l));
    if (semUso.length > 0) revisar(`liberação explícita sem causa pendente correspondente (${semUso.map((l) => `${l.gate}/${l.motivo}`).join(", ")}) — revisar o aprovacao.json`);
    if (aplicadas.length > 0) item.liberacoes_aplicadas = aplicadas;
    if (!etapas.GABARITO_OK) revisar("GABARITO_OK=false no staging");
    if (!etapas.DEDUP_OK && !liberacaoDedup.liberado) revisar("DEDUP_OK=false no staging (snapshot)");
    if (!questao.enunciado || questao.enunciado.trim() === "") revisar("enunciado vazio");
    const problemaAlternativas = validarAlternativas(questao, contexto.sequenciaEmbutida ?? new Set());
    if (problemaAlternativas) revisar(problemaAlternativas);
    if (classificacao.motivo) revisar(classificacao.motivo);

    // Mídias: o arquivo no staging precisa ter EXATAMENTE o hash
    // registrado; direito de publicação precisa estar resolvido; o banco
    // precisa ter a infraestrutura (questao_midias + bucket).
    const midiasStaging = questao._interno?.midias ?? [];
    if (midiasStaging.length > 0) {
      const decisoes = direitosPorNumero.get(numero) ?? [];
      item.midias = midiasStaging.map((m) => {
        const decisao = decisoes.find((d) => d.sha256 === m.sha256);
        return {
          ordem: m.ordem,
          tipo: m.tipo,
          sha256: m.sha256 ?? null,
          mime_type: m.mime_type,
          storage_path: m.storage_path ?? null,
          arquivo: m.arquivo ?? null,
          largura: m.largura,
          altura: m.altura,
          pagina_origem: m.pagina_origem,
          ancora_texto: m.ancora_texto ?? null,
          legenda: m.legenda ?? null,
          alt_text: m.alt_text,
          credito: m.credito ?? null,
          direito_uso: decisao?.direito_uso ?? m.direito_uso,
          origem_descricao: m.origem_descricao ?? null,
        };
      });
      for (const m of item.midias) {
        if (!m.sha256 || !m.arquivo) revisar(`mídia ${m.ordem}: sem arquivo/hash no staging`);
        else if (midiasVerificadas?.get(m.arquivo) !== m.sha256) revisar(`mídia ${m.ordem}: arquivo ausente ou hash divergente do registrado no staging`);
        if (!TIPOS_MIDIA.includes(m.tipo)) revisar(`mídia ${m.ordem}: tipo "${m.tipo}" inválido`);
        if (m.direito_uso === "REVISAO_DIREITOS") revisar(`mídia ${m.ordem} (${m.tipo}) sem direito de publicação (REVISAO_DIREITOS) — decisão explícita em aprovacao.direitos_midia`);
      }
      if (!contexto.infraMidias) revisar("infraestrutura de mídias ausente no banco (questao_midias / bucket questao-midias) — aplicar a migration antes");
    }
    for (const d of direitosPorNumero.get(numero) ?? []) {
      if (!midiasStaging.some((m) => m.sha256 === d.sha256)) revisar(`decisão de direito de uso sem mídia correspondente (${d.sha256.slice(0, 12)}…) — revisar o aprovacao.json`);
    }

    if (dedup.status === "duplicada") {
      if (item.acao === "IMPORTAR") ignorar(`duplicada de questoes.id=${dedup.match_id} já existente no banco`);
      else item.motivos.push(`duplicada de questoes.id=${dedup.match_id}`);
    } else if (dedup.status === "provavel_duplicada" && !liberacaoDedup.liberado) {
      revisar(dedup.motivo);
    }

    const chaveEnunciado = normalizarTexto(questao.enunciado);
    if (chaveEnunciado && enunciadosDoLote.has(chaveEnunciado)) revisar(`enunciado idêntico ao da questão ${enunciadosDoLote.get(chaveEnunciado)} do mesmo lote`);
    else if (chaveEnunciado) enunciadosDoLote.set(chaveEnunciado, numero);

    if (item.acao === "IMPORTAR") {
      item.curso_ids_aprovados = vinculos.filter((v) => v.materia_ids_aprovadas.includes(item.materia_id)).map((v) => v.curso_id).sort();
      // Questão vinculada entra em missões por assunto — sem assunto
      // ela ficaria órfã dentro do curso.
      if (item.curso_ids_aprovados.length > 0 && item.assunto_id === null) {
        item.curso_ids_aprovados = [];
        revisar("assunto obrigatório para vínculo com curso (aprovação de matéria sem assunto confirmado)");
      }
    }
    return item;
  });

  // Bloqueio do documento vence qualquer questão: nada é importado. A ação
  // que a questão teria sem o bloqueio fica em acao_potencial — só para
  // medir qualidade (ex.: lote com gabarito ainda preliminar).
  if (bloqueios.length > 0) {
    for (const item of planejadas) {
      item.acao_potencial = item.acao;
      item.acao = "REVISAR";
      item.curso_ids_aprovados = [];
      item.motivos.unshift("documento bloqueado — nenhuma questão é importada enquanto houver bloqueio da prova");
    }
  }

  const conta = (filtro) => planejadas.filter(filtro).length;
  const resumo = {
    total_extraido: planejadas.length,
    importar: conta((q) => q.acao === "IMPORTAR"),
    revisar: conta((q) => q.acao === "REVISAR"),
    ignorar: conta((q) => q.acao === "IGNORAR"),
    // Nunca somadas: exata = mesma questão já no banco; provável =
    // similaridade que exige leitura manual (continua bloqueando a
    // importação automática até ser aprovada/rejeitada).
    duplicadas_exatas: conta((q) => q.status_deduplicacao === "duplicada"),
    provaveis_duplicadas: conta((q) => q.status_deduplicacao === "provavel_duplicada"),
    ja_importadas: conta((q) => q.status_deduplicacao === "ja_importada"),
    anuladas: conta((q) => q.anulada),
    somente_globais: conta((q) => q.acao === "IMPORTAR" && q.curso_ids_aprovados.length === 0),
    documentos_novos: documentos.filter((d) => d.situacao === "NOVO").length,
    ...(liberacoesPorNumero.size > 0 ? { liberadas_explicitamente: conta((q) => (q.liberacoes_aplicadas ?? []).length > 0) } : {}),
    ...(planejadas.some((q) => q.midias) ? { com_midia: conta((q) => Boolean(q.midias)), midias_importar: planejadas.filter((q) => q.acao === "IMPORTAR").reduce((s, q) => s + (q.midias?.length ?? 0), 0) } : {}),
    ...(bloqueios.length > 0 ? { importar_potencial: conta((q) => q.acao_potencial === "IMPORTAR"), revisar_potencial: conta((q) => q.acao_potencial === "REVISAR"), ignorar_potencial: conta((q) => q.acao_potencial === "IGNORAR") } : {}),
    vinculos_por_curso: Object.fromEntries(vinculos.map((v) => [v.curso_slug, conta((q) => q.curso_ids_aprovados.includes(v.curso_id))])),
  };

  return {
    versao: VERSAO_MANIFESTO,
    modo,
    // A parte só entra no manifesto quando o staging a declara — sem parte,
    // o manifesto (e o hash) é exatamente o de antes.
    prova: { ...prova, prova_id_existente: provaIdExistente, situacao: provaIdExistente !== null ? "EXISTENTE" : "NOVA", ...(parte ? { parte } : {}) },
    // Documentos que alteraram o gabarito base — fazem parte do hash do
    // manifesto aprovado (o schema de provas ainda não os grava).
    retificacoes_gabarito: proveniencia?.retificacoes ?? [],
    documentos,
    bloqueios,
    vinculos,
    // Revisão humana que liberou gates — no hash do manifesto aprovado
    // (ausente quando não há liberação, para não mudar hashes antigos).
    ...(aprovacao.liberacoes !== undefined ? { liberacoes_aprovadas: aprovacao.liberacoes } : {}),
    ...(aprovacao.direitos_midia !== undefined ? { direitos_midia_aprovados: aprovacao.direitos_midia } : {}),
    questoes: planejadas,
    resumo,
  };
}
