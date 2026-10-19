// Calcula o status por etapa e o status final de cada questão normalizada
// (normalizar.mjs) + resultado da deduplicação (deduplicar.mjs). Só
// classifica/relata — nunca decide inserir nada.

// TODAS as causas de falha de extração, na ordem de gravidade — o gate
// reporta só a primeira, mas a liberação explícita (aquisicao/planejar.mjs)
// precisa ver todas: liberar uma causa nunca pode esconder outra.
export function causasDeExtracao(questao) {
  const interno = questao._interno ?? {};
  const causas = [];
  if (interno.alternativa_faltante) causas.push({ codigo: "alternativa_faltante", motivo: "alternativa faltante ou fora de ordem" });
  if ((questao.alternativas ?? []).length < 4) causas.push({ codigo: "menos_de_4_alternativas", motivo: "menos de 4 alternativas detectadas" });
  if (!questao.enunciado || questao.enunciado.trim().length === 0) causas.push({ codigo: "enunciado_vazio", motivo: "enunciado vazio" });
  if (interno.contagem_materia_divergente) {
    causas.push({ codigo: "contagem_materia_divergente", motivo: `contagem de questões do bloco "${interno.materia_detectada}" não bate com a declarada no cabeçalho` });
  }
  // Conteúdo ausente ou possivelmente corrompido nunca fica pronto: o
  // aluno precisa conseguir responder só com o que será gravado.
  const textoNaoConfiavel = (interno.textos_base ?? []).find((t) => !t.confiavel);
  if (textoNaoConfiavel) causas.push({ codigo: "texto_base_nao_confiavel", motivo: `texto-base ${textoNaoConfiavel.id} não reconstruído com fidelidade (${textoNaoConfiavel.motivo})` });
  if (interno.dependencia_texto_incerta) causas.push({ codigo: "dependencia_texto_incerta", motivo: `dependência de texto-base incerta: ${interno.dependencia_texto_incerta}` });
  if (interno.alternativa_suspeita) causas.push({ codigo: "alternativa_suspeita", motivo: interno.alternativa_suspeita });
  // Referência a peça visual resolvida por mídia extraída (MIDIA_OK) deixa
  // de ser falha de extração; destaque tipográfico nunca é resolvido assim.
  if (interno.referencia_visual && !interno.referencia_visual_resolvida) causas.push({ codigo: "referencia_visual", motivo: interno.referencia_visual });
  if ((interno.alertas_expressao ?? []).length > 0) {
    causas.push({
      codigo: "expressao_nao_reconstruida",
      motivo: `expressão matemática não reconstruída com confiança na página (${interno.alertas_expressao.map((a) => a.motivo).join("; ")})`,
    });
  }
  return causas;
}

// Causas de MIDIA_OK=false, gravadas no staging por lib/midias.mjs
// (resolverMidias -> anexarMidias). Questão sem dependência visual e sem
// figura não tem causa.
export function causasDeMidia(questao) {
  const interno = questao._interno ?? {};
  const causas = [...(interno.midias_causas ?? [])];
  if (interno.dependencia_midia && (interno.midias ?? []).length === 0 && causas.length === 0) {
    causas.push({ codigo: "midia_ausente", motivo: "a questão cita peça visual, mas nenhuma figura foi encontrada no PDF" });
  }
  return causas;
}

function avaliarExtracao(questao) {
  const [primeira] = causasDeExtracao(questao);
  return primeira ? { ok: false, motivo: primeira.motivo } : { ok: true, motivo: null };
}

function avaliarGabarito(questao) {
  const interno = questao._interno;
  if (interno.motivos_juncao.includes("questao_sem_gabarito")) return { ok: false, motivo: "gabarito ausente para esta questão" };
  if (interno.motivos_juncao.includes("alternativa_correta_inexistente")) return { ok: false, motivo: "gabarito aponta para uma alternativa que não existe na questão" };
  if (interno.gabarito_status === "revisao_manual") return { ok: false, motivo: "linha de gabarito ambígua (ex.: número duplicado no documento)" };
  return { ok: true, motivo: null };
}

function avaliarClassificacao(questao) {
  if (questao.confidence === "alta") return { ok: true, motivo: null };
  return { ok: false, motivo: `classificação automática não confirmada (confidence="${questao.confidence}")` };
}

function avaliarDedup(resultadoDedup) {
  if (resultadoDedup.status === "nova") return { ok: true, motivo: null };
  if (resultadoDedup.status === "duplicada") return { ok: false, motivo: `duplicada de questoes.id=${resultadoDedup.match_id}` };
  return { ok: false, motivo: `provável duplicidade com questoes.id=${resultadoDedup.match_id} — requer leitura manual` };
}

// Proveniência é obrigatória: sem o resultado de montarProveniencia()
// (proveniencia.mjs), ou com ele incompleto, a questão nunca fica pronta —
// questão nova do pipeline sem prova rastreável não entra no banco.
function avaliarProveniencia(proveniencia) {
  if (!proveniencia) return { ok: false, motivo: "proveniência da prova não informada" };
  if (proveniencia.completa) return { ok: true, motivo: null };
  const problemas = [
    ...proveniencia.faltando.map((campo) => `${campo} ausente`),
    ...proveniencia.invalidos.map((campo) => `${campo} inválido`),
  ];
  return { ok: false, motivo: `proveniência da prova incompleta: ${problemas.join(", ")}` };
}

export function calcularStatus(questao, resultadoDedup, bloqueiosGlobais, proveniencia) {
  const extracao = avaliarExtracao(questao);
  const gabarito = avaliarGabarito(questao);
  const classificacao = avaliarClassificacao(questao);
  const dedup = avaliarDedup(resultadoDedup);
  const origem = avaliarProveniencia(proveniencia);
  const [causaMidia] = causasDeMidia(questao);

  const bloqueiosDestaQuestao = bloqueiosGlobais.filter(
    (b) => b.numero === undefined || b.numero === questao.numero_original,
  );

  const etapas = {
    EXTRACAO_OK: extracao.ok,
    GABARITO_OK: gabarito.ok,
    CLASSIFICACAO_OK: classificacao.ok,
    DEDUP_OK: dedup.ok,
    PROVENIENCIA_OK: origem.ok,
    MIDIA_OK: !causaMidia,
  };

  const motivos = [extracao.motivo, gabarito.motivo, classificacao.motivo, dedup.motivo, origem.motivo, causaMidia?.motivo, ...bloqueiosDestaQuestao.map((b) => b.mensagem)].filter(Boolean);

  // CLASSIFICACAO_OK não bloqueia por si só (classificação incerta é
  // esperada e normal — vai para revisão, mas não torna a questão
  // "quebrada"). Extração, gabarito, deduplicação, proveniência e
  // qualquer bloqueio de junção, sim.
  const pronta = extracao.ok && gabarito.ok && dedup.ok && origem.ok && !causaMidia && bloqueiosDestaQuestao.length === 0;

  return {
    ...questao,
    dedup: resultadoDedup,
    etapas,
    status: pronta ? "PRONTA_PARA_REVISAO" : "REVISAO_MANUAL",
    motivos,
  };
}
