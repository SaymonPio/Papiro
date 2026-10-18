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

export function planejarAquisicao({ modo, proveniencia, questoes, contexto, aprovacao = {} }) {
  const bloqueios = [];
  if (!MODOS.includes(modo)) bloqueios.push(`modo inválido "${modo}" (use ${MODOS.join(" ou ")})`);

  const pedidos = aprovacao.vinculos ?? [];
  if (modo === "BASE_GLOBAL" && pedidos.length > 0) bloqueios.push("modo BASE_GLOBAL não aceita vínculos — use BASE_GLOBAL_COM_VINCULO");
  if (modo === "BASE_GLOBAL_COM_VINCULO" && pedidos.length === 0) bloqueios.push("modo BASE_GLOBAL_COM_VINCULO exige vínculos explícitos (curso + matérias aprovadas)");
  const { vinculos, bloqueios: bloqueiosVinculo } = resolverVinculos(modo === "BASE_GLOBAL_COM_VINCULO" ? pedidos : [], contexto.cursos ?? []);
  bloqueios.push(...bloqueiosVinculo);

  // ---- Prova ----
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

  // ---- Questões ----
  const overrides = aprovacao.classificacao ?? {};
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

    if (bloqueios.length > 0) {
      revisar("documento bloqueado — nenhuma questão é importada enquanto houver bloqueio da prova");
      return item;
    }
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
    if (!etapas.EXTRACAO_OK) revisar("EXTRACAO_OK=false no staging");
    if (!etapas.GABARITO_OK) revisar("GABARITO_OK=false no staging");
    if (!etapas.DEDUP_OK) revisar("DEDUP_OK=false no staging (snapshot)");
    if (!questao.enunciado || questao.enunciado.trim() === "") revisar("enunciado vazio");
    const problemaAlternativas = validarAlternativas(questao, contexto.sequenciaEmbutida ?? new Set());
    if (problemaAlternativas) revisar(problemaAlternativas);
    if (classificacao.motivo) revisar(classificacao.motivo);

    if (dedup.status === "duplicada") {
      if (item.acao === "IMPORTAR") ignorar(`duplicada de questoes.id=${dedup.match_id} já existente no banco`);
      else item.motivos.push(`duplicada de questoes.id=${dedup.match_id}`);
    } else if (dedup.status === "provavel_duplicada") {
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

  const conta = (filtro) => planejadas.filter(filtro).length;
  const resumo = {
    total_extraido: planejadas.length,
    importar: conta((q) => q.acao === "IMPORTAR"),
    revisar: conta((q) => q.acao === "REVISAR"),
    ignorar: conta((q) => q.acao === "IGNORAR"),
    duplicadas: conta((q) => q.status_deduplicacao === "duplicada" || q.status_deduplicacao === "provavel_duplicada"),
    ja_importadas: conta((q) => q.status_deduplicacao === "ja_importada"),
    anuladas: conta((q) => q.anulada),
    somente_globais: conta((q) => q.acao === "IMPORTAR" && q.curso_ids_aprovados.length === 0),
    vinculos_por_curso: Object.fromEntries(vinculos.map((v) => [v.curso_slug, conta((q) => q.curso_ids_aprovados.includes(v.curso_id))])),
  };

  return {
    versao: VERSAO_MANIFESTO,
    modo,
    prova: { ...prova, prova_id_existente: provaIdExistente, situacao: provaIdExistente !== null ? "EXISTENTE" : "NOVA" },
    bloqueios,
    vinculos,
    questoes: planejadas,
    resumo,
  };
}
