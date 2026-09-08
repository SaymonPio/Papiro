// Nucleo puro de calculo de cobertura (Fase 2A, Secoes 9, 10, 14, 15, 16).
// Recebe SEMPRE dados ja carregados (arrays simples, formato espelhando
// as colunas reais do Postgres) — nunca fala com o Supabase diretamente.
// Isso e o que permite testar toda a logica de "util"/"selecionavel"/
// "deficit" sem tocar o banco (ver context-resolver.mjs para quem
// realmente busca os dados).
//
// Definicao de "util" (Secao 9, derivada da Fase 1 — corpo real de
// selecionar_candidatas_unidade_pedagogica + iniciar_pratica_unidade):
//   questoes.ativa=true
//   + vinculo em questao_unidades_pedagogicas para esta unidade
//   + unidades_pedagogicas.ativa=true
//   + curso_conteudos.relevante_para_preparacao=true
//   + curso_materias.relevante_para_preparacao=true
//   + linha em curso_questoes para o curso correspondente
//   contado por COUNT DISTINCT questao_id.
//
// Definicao de "selecionavel operacionalmente" (Secao 10): tudo acima +
// aulas.ativa=true + pelo menos uma aula_versoes.status='publicada' para
// aquela unidade. Gates de progresso individual do aluno (missao/
// matricula) sao runtime, nao propriedade fixa da unidade — nao entram
// aqui (documentado, nao calculado).

import { STATUS_CURSO_SEM_ANDAIME } from "./schemas.mjs";
import { avaliarContextoPedagogico, avaliarElegibilidade, calcularPrioridade, materiaPareceNormativa } from "./eligibility.mjs";
import { avaliarValidacaoFonte, buscarFontesParaUnidade } from "./source-manifest.mjs";
import { resolverBanca } from "./banca-resolver.mjs";

/**
 * Resolve a cadeia unidade -> curso_conteudo -> curso_materia a partir dos
 * dados brutos. Retorna null se qualquer elo estiver quebrado/ausente —
 * nunca inventa uma relacao.
 */
export function resolverCadeiaUnidade(dadosBrutos, unidadeId) {
  const unidade = dadosBrutos.unidadesPedagogicas.find((u) => u.id === unidadeId);
  if (!unidade) return null;
  const cursoConteudo = dadosBrutos.cursoConteudos.find((c) => c.id === unidade.curso_conteudo_id);
  if (!cursoConteudo) return null;
  const cursoMateria = dadosBrutos.cursoMaterias.find((m) => m.id === cursoConteudo.curso_materia_id);
  if (!cursoMateria) return null;
  return { unidade, cursoConteudo, cursoMateria };
}

/**
 * COUNT DISTINCT questao_id uteis para uma unidade, dentro de um curso
 * especifico. Retorna um Set (nunca conta a mesma questao duas vezes).
 */
export function questoesUteisDaUnidade(dadosBrutos, unidadeId, cursoId) {
  const cadeia = resolverCadeiaUnidade(dadosBrutos, unidadeId);
  if (!cadeia) return new Set();
  const { unidade, cursoConteudo, cursoMateria } = cadeia;
  if (!unidade.ativa || !cursoConteudo.relevante_para_preparacao || !cursoMateria.relevante_para_preparacao) {
    return new Set();
  }

  const questoesPorId = new Map(dadosBrutos.questoes.map((q) => [q.id, q]));
  const vinculadas = dadosBrutos.questaoUnidadesPedagogicas
    .filter((v) => v.unidade_pedagogica_id === unidadeId)
    .map((v) => v.questao_id);

  const cursoQuestoesSet = new Set(
    dadosBrutos.cursoQuestoes.filter((cq) => cq.curso_id === cursoId).map((cq) => cq.questao_id)
  );

  const uteis = new Set();
  for (const questaoId of vinculadas) {
    const questao = questoesPorId.get(questaoId);
    if (!questao || !questao.ativa) continue;
    if (!cursoQuestoesSet.has(questaoId)) continue;
    uteis.add(questaoId);
  }
  return uteis;
}

/**
 * Selecionaveis operacionalmente = uteis, SE a unidade tiver aula ativa
 * com pelo menos uma versao publicada; caso contrario, conjunto vazio
 * (nao "parcialmente selecionavel" — e um gate de unidade, nao de
 * questao individual).
 */
export function questoesSelecionaveisDaUnidade(dadosBrutos, unidadeId, uteisSet) {
  const aula = dadosBrutos.aulas.find((a) => a.unidade_pedagogica_id === unidadeId && a.ativa);
  if (!aula) return new Set();
  const temPublicada = dadosBrutos.aulaVersoes.some((v) => v.aula_id === aula.id && v.status === "publicada");
  return temPublicada ? new Set(uteisSet) : new Set();
}

/**
 * Classifica um conjunto de questao_ids em REAL vs AUTORAL (convencao
 * atual do projeto: banca normalizada contem "papiro" — nao ha enum
 * confiavel, ver Fase 1 Secao 9/14) e conta separadamente gerada_por_ia,
 * que NUNCA e tratado como sinonimo de AUTORAL_PAPIRO porque o historico
 * real esta inconsistente (confirmado na Fase 1: lotes DH-AUT antigos
 * setaram, lotes INFO/LEG-AUT desta sessao nao setaram).
 */
export function classificarOrigemQuestoes(dadosBrutos, questaoIds) {
  const questoesPorId = new Map(dadosBrutos.questoes.map((q) => [q.id, q]));
  const real = [];
  const autoral = [];
  let geradaPorIaCount = 0;
  let origemDesconhecidaCount = 0;

  for (const id of questaoIds) {
    const questao = questoesPorId.get(id);
    if (!questao) {
      origemDesconhecidaCount += 1;
      continue;
    }
    const bancaNormalizada = (questao.banca || "").trim().toLowerCase();
    if (bancaNormalizada.includes("papiro")) {
      autoral.push(id);
    } else {
      real.push(id);
    }
    if (questao.gerada_por_ia === true) geradaPorIaCount += 1;
  }

  return {
    real,
    autoral,
    gerada_por_ia_count: geradaPorIaCount,
    origem_desconhecida_count: origemDesconhecidaCount,
    origin_classification_method: 'banca normalizada contem "papiro" (convencao do projeto, sem enum formal)',
  };
}

export function calcularDeficit(nUteis, targetBankSize) {
  return Math.max(targetBankSize - nUteis, 0);
}

/**
 * Verifica se existe pelo menos um material_versao anexado a QUALQUER
 * versao da aula desta unidade (sinal de fonte validada — Secao 12).
 */
function materialVersoesExistemParaUnidade(dadosBrutos, unidadeId) {
  const aula = dadosBrutos.aulas.find((a) => a.unidade_pedagogica_id === unidadeId);
  if (!aula) return false;
  const versaoIds = new Set(dadosBrutos.aulaVersoes.filter((v) => v.aula_id === aula.id).map((v) => v.id));
  return dadosBrutos.aulaVersaoFontes.some((f) => versaoIds.has(f.aula_versao_id));
}

/**
 * Monta o objeto de cobertura de UMA unidade (Secao 15 — todos os campos
 * pedidos). Nao decide elegibilidade sozinho (isso e eligibility.mjs) mas
 * ja inclui os sinais que a elegibilidade/prioridade precisam.
 *
 * `fontes` (Fase 2A.1): lista ja carregada por
 * source-manifest.mjs#carregarFontes() — passada de fora para que esta
 * funcao continue pura/testavel sem tocar o filesystem.
 */
export function calcularCoberturaUnidade(dadosBrutos, { unidadeId, cursoId, targetBankSize, bancaCurso, editalBanca, fontes = [] }) {
  const cadeia = resolverCadeiaUnidade(dadosBrutos, unidadeId);
  if (!cadeia) throw new Error(`Unidade ${unidadeId} nao resolve cadeia curso_conteudo/curso_materia.`);
  const { unidade, cursoConteudo, cursoMateria } = cadeia;

  const materiaGlobal = dadosBrutos.materias?.find((m) => m.id === cursoMateria.materia_id) ?? null;

  const uteis = questoesUteisDaUnidade(dadosBrutos, unidadeId, cursoId);
  const selecionaveis = questoesSelecionaveisDaUnidade(dadosBrutos, unidadeId, uteis);
  const origem = classificarOrigemQuestoes(dadosBrutos, uteis);
  const faltantes = calcularDeficit(uteis.size, targetBankSize);

  const aula = dadosBrutos.aulas.find((a) => a.unidade_pedagogica_id === unidadeId) ?? null;
  const aulaVersaoPublicada = aula ? dadosBrutos.aulaVersoes.find((v) => v.aula_id === aula.id && v.status === "publicada") : null;

  const teoriaEscopo = dadosBrutos.teoriaEscoposConteudo?.find((t) => t.curso_conteudo_id === cursoConteudo.id) ?? null;

  // Pergunta 1: sabemos O QUE ensinar? (metadado pedagogico — NUNCA prova fonte)
  const contexto = avaliarContextoPedagogico({
    escopoUnidade: unidade.escopo,
    artigosEsperadosUnidade: unidade.artigos_esperados,
    teoriaEscopoConteudo: teoriaEscopo,
    materialVersoesExistem: materialVersoesExistemParaUnidade(dadosBrutos, unidadeId),
  });

  // Pergunta 2: a informacao esta documentalmente validada? (SOMENTE o
  // manifesto local de fontes decide isso — nunca escopo/artigos_esperados)
  const fontesDaUnidade = buscarFontesParaUnidade(fontes, unidadeId);
  const validacaoFonte = avaliarValidacaoFonte({
    fontesDaUnidade,
    artigosEsperados: contexto.artigos_esperados_efetivos,
  });

  // Conteudo normativo/juridico (inferido do TEXTO do escopo, nunca de
  // materia_id hardcoded) exige fonte validada para poder gerar; outras
  // materias apenas avisam quando a fonte nao esta validada.
  const requerFonteValidada = materiaPareceNormativa(contexto.escopo_efetivo);

  const banca = resolverBanca({ cursoBanca: bancaCurso, editalBanca });

  const elegibilidade = avaliarElegibilidade({
    unidadeAtiva: unidade.ativa,
    faltantes,
    pedagogicalContextStatus: contexto.status,
    sourceValidationStatus: validacaoFonte.status,
    requerFonteValidada,
    bancaStatus: banca.status,
    aulaExiste: Boolean(aula),
    aulaPublicada: Boolean(aulaVersaoPublicada),
  });

  const prioridade = calcularPrioridade({ elegibilidade, faltantes, sourceValidationStatus: validacaoFonte.status });

  return {
    materia_id: cursoMateria.materia_id ?? null,
    materia_nome: materiaGlobal?.nome ?? cursoMateria.nome,
    curso_materia_id: cursoMateria.id,
    conteudo_id: cursoConteudo.assunto_id,
    curso_conteudo_id: cursoConteudo.id,
    unidade_id: unidade.id,
    unidade_titulo: unidade.titulo,
    escopo: unidade.escopo,
    artigos_esperados: unidade.artigos_esperados ?? null,
    aula_id: aula?.id ?? null,
    aula_existe: Boolean(aula),
    aula_publicada: Boolean(aulaVersaoPublicada),
    aula_versao_id: aulaVersaoPublicada?.id ?? null,
    banca_status: banca.status,
    banca_resolvida: banca.banca_resolvida,
    questoes_vinculadas: dadosBrutos.questaoUnidadesPedagogicas.filter((v) => v.unidade_pedagogica_id === unidadeId).length,
    questoes_uteis: uteis.size,
    questoes_selecionaveis: selecionaveis.size,
    questoes_real: origem.real.length,
    questoes_autoral: origem.autoral.length,
    questoes_geradas_por_ia: origem.gerada_por_ia_count,
    target_bank_size: targetBankSize,
    faltantes,
    pedagogical_context_status: contexto.status,
    pedagogical_context_reason: contexto.reason,
    legal_source_required: requerFonteValidada,
    source_validation_status: validacaoFonte.status,
    source_validation_reason: validacaoFonte.reason,
    source_validated_keys: validacaoFonte.validated_sources,
    generation_eligibility: elegibilidade.status,
    blocking_reasons: elegibilidade.blocking_reasons,
    warnings: elegibilidade.warnings,
    priority_score: null,
    priority_label: prioridade.prioridade,
    priority_reason_codes: prioridade.reason_codes,
  };
}

/**
 * Escaneia um curso inteiro. Se nao houver NENHUMA unidade elegivel
 * (curso_materias sem curso_conteudos, ou sem unidades ativas sob eles),
 * retorna status BLOCKED_NO_PEDAGOGICAL_SCAFFOLD com deficit_total=0 —
 * NUNCA inventa uma unidade sintetica para "preencher" o calculo
 * (Secao 8).
 */
export function escanearCursoCompleto(dadosBrutos, { cursoId, targetBankSize, fontes = [] }) {
  const curso = dadosBrutos.cursos.find((c) => c.id === cursoId);
  if (!curso) throw new Error(`Curso ${cursoId} nao encontrado nos dados brutos.`);

  const materiaIds = new Set(
    dadosBrutos.cursoMaterias.filter((m) => m.curso_id === cursoId && m.relevante_para_preparacao).map((m) => m.id)
  );
  const conteudoIds = new Set(
    dadosBrutos.cursoConteudos
      .filter((c) => materiaIds.has(c.curso_materia_id) && c.relevante_para_preparacao)
      .map((c) => c.id)
  );
  const unidadeIds = dadosBrutos.unidadesPedagogicas
    .filter((u) => conteudoIds.has(u.curso_conteudo_id) && u.ativa)
    .map((u) => u.id);

  const editalDoCurso = dadosBrutos.editais?.find((e) => e.id === curso.edital_id) ?? null;

  if (unidadeIds.length === 0) {
    return {
      curso: { id: curso.id, slug: curso.slug, banca: curso.banca ?? null },
      status: STATUS_CURSO_SEM_ANDAIME,
      motivo: "sem curso_conteudos/unidades_pedagogicas relevantes sob este curso",
      unidades: [],
      unidades_relevantes: 0,
      unidades_ge_target: 0,
      unidades_lt_target: 0,
      deficit_total: 0,
    };
  }

  const unidades = unidadeIds.map((unidadeId) =>
    calcularCoberturaUnidade(dadosBrutos, {
      unidadeId,
      cursoId,
      targetBankSize,
      bancaCurso: curso.banca ?? null,
      editalBanca: editalDoCurso?.banca ?? null,
      fontes,
    })
  );

  return {
    curso: { id: curso.id, slug: curso.slug, banca: curso.banca ?? null },
    status: "OK",
    motivo: null,
    unidades,
    unidades_relevantes: unidades.length,
    unidades_ge_target: unidades.filter((u) => u.faltantes === 0).length,
    unidades_lt_target: unidades.filter((u) => u.faltantes > 0).length,
    deficit_total: unidades.reduce((soma, u) => soma + u.faltantes, 0),
  };
}

/** COUNT DISTINCT questao_id util em TODO o curso (uniao de todas as unidades — uma questao em 2 unidades conta 1 vez). */
export function distintasUteisCurso(dadosBrutos, cursoId, unidadeIds) {
  const uniao = new Set();
  for (const unidadeId of unidadeIds) {
    for (const questaoId of questoesUteisDaUnidade(dadosBrutos, unidadeId, cursoId)) uniao.add(questaoId);
  }
  return uniao;
}
