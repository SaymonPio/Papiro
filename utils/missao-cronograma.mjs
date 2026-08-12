const inteiroPositivo = (valor) => {
  const numero = Number(valor);
  return Number.isInteger(numero) && numero > 0 ? numero : null;
};

// Validação básica de formato (não consulta o banco) — suficiente pra
// descartar um parâmetro "missao" ausente/vazio/malformado na URL sem
// adicionar nenhuma dependência nova.
const UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

const uuidValido = (valor) => (typeof valor === "string" && UUID_REGEX.test(valor) ? valor : null);

function montarParametrosMissao({ cursoMateriaId, conteudoId, materiaId, assuntoId, quantidade = 10, missionId }) {
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

  return parametros;
}

export function montarLinkMissao({
  cursoMateriaId,
  conteudoId,
  materiaId,
  assuntoId,
  quantidade = 10,
  missionId,
}) {
  if (!materiaId) return "/questoes";
  return `/questoes?${montarParametrosMissao({ cursoMateriaId, conteudoId, materiaId, assuntoId, quantidade, missionId }).toString()}`;
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
}) {
  if (!materiaId) return "/questoes";
  return `/teoria?${montarParametrosMissao({ cursoMateriaId, conteudoId, materiaId, assuntoId, quantidade, missionId }).toString()}`;
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
