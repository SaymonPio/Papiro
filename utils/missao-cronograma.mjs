const inteiroPositivo = (valor) => {
  const numero = Number(valor);
  return Number.isInteger(numero) && numero > 0 ? numero : null;
};

// Validação básica de formato (não consulta o banco) — suficiente pra
// descartar um parâmetro "missao" ausente/vazio/malformado na URL sem
// adicionar nenhuma dependência nova.
const UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

const uuidValido = (valor) => (typeof valor === "string" && UUID_REGEX.test(valor) ? valor : null);

/**
 * @param {{
 *   cursoMateriaId?: number | null,
 *   conteudoId?: number | null,
 *   materiaId: number,
 *   assuntoId?: number | null,
 *   quantidade?: number,
 *   missionId?: string | null,
 *   refazer?: boolean,
 *   unidadePedagogicaId?: string | null,
 *   missaoFinal?: boolean,
 * }} opcoes
 */
function montarParametrosMissao({
  cursoMateriaId,
  conteudoId,
  materiaId,
  assuntoId,
  quantidade = 10,
  missionId,
  refazer = false,
  unidadePedagogicaId = undefined,
  missaoFinal = false,
}) {
  const parametros = new URLSearchParams({
    origem: "cronograma",
    materia: String(materiaId),
    quantidade: String(Math.max(1, Math.min(100, quantidade))),
  });

  if (assuntoId) parametros.set("assunto", String(assuntoId));
  if (cursoMateriaId) parametros.set("cursoMateria", String(cursoMateriaId));
  if (conteudoId) parametros.set("conteudo", String(conteudoId));
  // Ausente/vazio -> não inclui "missao" na URL, mantendo compatibilidade
  // com quem ainda não tem um mission_id (ex.: chamadas antigas dos testes).
  if (missionId) parametros.set("missao", String(missionId));
  if (refazer) parametros.set("refazer", "1");
  // Modo Papiro por unidades pedagógicas (Fase 2J-F): "unidade" identifica
  // qual das 10-questões-por-unidade praticar; "missaoFinal" pede as 30
  // questões finais do conteúdo. Nunca os dois ao mesmo tempo — quem monta
  // o link decide qual dos dois faz sentido no momento.
  if (unidadePedagogicaId) parametros.set("unidade", String(unidadePedagogicaId));
  if (missaoFinal) parametros.set("missaoFinal", "1");

  return parametros;
}

/**
 * @param {{
 *   cursoMateriaId?: number | null,
 *   conteudoId?: number | null,
 *   materiaId: number | null,
 *   assuntoId?: number | null,
 *   quantidade?: number,
 *   missionId?: string | null,
 *   refazer?: boolean,
 *   unidadePedagogicaId?: string | null,
 *   missaoFinal?: boolean,
 * }} opcoes
 */
export function montarLinkMissao({
  cursoMateriaId,
  conteudoId,
  materiaId,
  assuntoId,
  quantidade = 10,
  missionId,
  refazer = false,
  unidadePedagogicaId = undefined,
  missaoFinal = false,
}) {
  if (!materiaId) return "/questoes";
  return `/questoes?${montarParametrosMissao({ cursoMateriaId, conteudoId, materiaId, assuntoId, quantidade, missionId, refazer, unidadePedagogicaId, missaoFinal }).toString()}`;
}

// Mesmos parâmetros e mesma missão de montarLinkMissao — só muda o destino.
// A missão agora abre pela Teoria primeiro; o botão "Ir para as questões" ao
// final da Teoria usa montarLinkMissao (acima) para seguir para a mesma
// matéria/assunto/cursoMateria/conteúdo, preservando o contexto da missão.
// missionId (mission_id retornado por iniciar_ou_recuperar_missao_diaria) é
// a identidade canônica a partir desta etapa — os demais parâmetros
// continuam na URL por compatibilidade/contexto, mas não a substituem.
export function montarLinkTeoria({
  cursoMateriaId,
  conteudoId,
  materiaId,
  assuntoId,
  quantidade = 10,
  missionId,
  refazer = false,
}) {
  if (!materiaId) return "/questoes";
  return `/teoria?${montarParametrosMissao({ cursoMateriaId, conteudoId, materiaId, assuntoId, quantidade, missionId, refazer }).toString()}`;
}

export function lerMissaoCronograma(busca) {
  const parametros = new URLSearchParams(busca);
  if (parametros.get("origem") !== "cronograma") return null;

  const materiaId = inteiroPositivo(parametros.get("materia"));
  if (!materiaId) return null;

  return {
    materiaId,
    assuntoId: inteiroPositivo(parametros.get("assunto")),
    cursoMateriaId: inteiroPositivo(parametros.get("cursoMateria")),
    conteudoId: inteiroPositivo(parametros.get("conteudo")),
    quantidade: inteiroPositivo(parametros.get("quantidade")) ?? 10,
    missionId: uuidValido(parametros.get("missao")),
    refazer: parametros.get("refazer") === "1",
  };
}

// Modo Papiro por unidades pedagógicas (Fase 2J-F): lê "unidade"/
// "missaoFinal" ISOLADAMENTE de lerMissaoCronograma (que tem forma fixa,
// testada por igualdade estrita em outros lugares) — usado por /questoes
// para decidir se chama iniciar_pratica_unidade, iniciar_missao_final, ou o
// fluxo antigo iniciar_questoes_da_missao (nenhum dos dois novos parâmetros
// presente).
export function lerPraticaPapiro(busca) {
  const parametros = new URLSearchParams(busca);
  return {
    unidadePedagogicaId: uuidValido(parametros.get("unidade")),
    missaoFinal: parametros.get("missaoFinal") === "1",
  };
}

// Lê SOMENTE o mission_id da querystring, independente de origem/materia —
// usado por /teoria, onde missao=<uuid> já é suficiente pra identificar a
// missão (o resto do contexto acadêmico vem de public.missoes, não da URL).
// Diferente de lerMissaoCronograma, não exige origem=cronograma nem materia
// — reaproveita a mesma validação de formato (uuidValido), sem duplicar a
// regex.
export function lerMissionId(busca) {
  const parametros = new URLSearchParams(busca);
  return uuidValido(parametros.get("missao"));
}

// PAPIRO Beta 1 — revisão executável. "revisao=1" é um parâmetro próprio,
// NUNCA combinado com origem=cronograma/unidade/missaoFinal (a revisão não é
// uma missão: identidade/seleção de questões são 100% resolvidas no servidor
// por iniciar_revisao(), sem nenhum id vindo da URL — ver
// supabase/migrations/20261008120000_revisao_executavel.sql).
export function montarLinkRevisao() {
  return "/questoes?revisao=1";
}

export function lerRevisaoSolicitada(busca) {
  const parametros = new URLSearchParams(busca);
  return parametros.get("revisao") === "1";
}

// PAPIRO Beta 1.1 — Central de Revisões: revisão PERSONALIZADA (filtros),
// irmã de montarLinkRevisao()/lerRevisaoSolicitada() acima — "revisaoP=1" é
// um parâmetro próprio, nunca combinado com "revisao=1" nem com os
// parâmetros de missão. Os filtros em si (materia/assunto/tipoErro/
// situacao/quantidade) são só CONTEXTO de UI na URL — iniciar_revisao_
// personalizada() revalida tudo server-side (pertencimento ao curso
// ativo, valores permitidos); nenhum deles é tratado como identidade.
const SITUACOES_VALIDAS = new Set(["vencidas", "hoje", "proximas", "todas"]);
const TIPOS_ERRO_VALIDOS = new Set(["nao_sabia", "duvida", "chute", "atencao", "interpretacao"]);

/**
 * @param {{
 *   materiaId?: number | null,
 *   assuntoId?: number | null,
 *   tipoErro?: string | null,
 *   situacao?: string,
 *   quantidade?: number,
 * }} [filtros]
 */
export function montarLinkRevisaoPersonalizada({
  materiaId = null,
  assuntoId = null,
  tipoErro = null,
  situacao = "vencidas",
  quantidade = 20,
} = {}) {
  const parametros = new URLSearchParams({ revisaoP: "1" });
  if (materiaId) parametros.set("materia", String(materiaId));
  if (assuntoId) parametros.set("assunto", String(assuntoId));
  if (tipoErro) parametros.set("tipoErro", String(tipoErro));
  if (situacao) parametros.set("situacao", String(situacao));
  if (quantidade) parametros.set("quantidade", String(Math.max(1, Math.min(50, quantidade))));
  return `/questoes?${parametros.toString()}`;
}

export function lerRevisaoPersonalizadaSolicitada(busca) {
  const parametros = new URLSearchParams(busca);
  if (parametros.get("revisaoP") !== "1") return null;

  const materiaId = inteiroPositivo(parametros.get("materia"));
  const assuntoId = inteiroPositivo(parametros.get("assunto"));
  const tipoErroBruto = parametros.get("tipoErro");
  const situacaoBruta = parametros.get("situacao");
  const quantidadeBruta = inteiroPositivo(parametros.get("quantidade"));

  return {
    materiaId,
    assuntoId: materiaId ? assuntoId : null,
    tipoErro: tipoErroBruto && TIPOS_ERRO_VALIDOS.has(tipoErroBruto) ? tipoErroBruto : null,
    situacao: situacaoBruta && SITUACOES_VALIDAS.has(situacaoBruta) ? situacaoBruta : "vencidas",
    quantidade: quantidadeBruta ? Math.max(1, Math.min(50, quantidadeBruta)) : 20,
  };
}

export function podeIniciarMissaoAutomaticamente({
  origemCronograma,
  jaIniciada,
  materiaId,
  materiasDisponiveis,
  carregandoMaterias,
  carregandoAssuntos,
  assuntoPendente,
}) {
  return Boolean(
    origemCronograma &&
      !jaIniciada &&
      materiaId &&
      !carregandoMaterias &&
      !carregandoAssuntos &&
      !assuntoPendente &&
      materiasDisponiveis.includes(materiaId),
  );
}
