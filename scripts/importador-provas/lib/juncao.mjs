// Cruza questões extraídas (extrairQuestoes.mjs) com o gabarito extraído
// (extrairGabarito.mjs) pelo número da questão. Nunca grava nada — só
// classifica e bloqueia o que estiver inconsistente, para a etapa de
// score (score.mjs) decidir o status final.

function contarRepeticoes(numeros) {
  const contagem = new Map();
  for (const numero of numeros) contagem.set(numero, (contagem.get(numero) ?? 0) + 1);
  return [...contagem.entries()].filter(([, quantidade]) => quantidade > 1).map(([numero]) => numero);
}

export function juntarQuestoesEGabarito(questoes, gabaritos) {
  const bloqueios = [];

  const numerosQuestoesDuplicados = contarRepeticoes(questoes.map((q) => q.numero_original));
  for (const numero of numerosQuestoesDuplicados) {
    bloqueios.push({ tipo: "numero_duplicado", numero, mensagem: `questão nº ${numero} aparece mais de uma vez na extração` });
  }

  const mapaGabarito = new Map();
  for (const gabarito of gabaritos) {
    if (!mapaGabarito.has(gabarito.numero)) mapaGabarito.set(gabarito.numero, gabarito);
  }

  const numerosQuestoes = new Set(questoes.map((q) => q.numero_original));
  const numerosGabarito = new Set(gabaritos.map((g) => g.numero));

  for (const numero of numerosGabarito) {
    if (!numerosQuestoes.has(numero)) {
      bloqueios.push({ tipo: "gabarito_sem_questao", numero, mensagem: `gabarito tem o nº ${numero}, mas nenhuma questão extraída com esse número` });
    }
  }

  if (questoes.length > 0 && gabaritos.length > 0 && questoes.length !== gabaritos.length) {
    bloqueios.push({
      tipo: "quantidade_incompativel",
      mensagem: `${questoes.length} questão(ões) extraída(s) vs. ${gabaritos.length} entrada(s) no gabarito`,
    });
  }

  const juntadas = questoes.map((questao) => {
    const gabarito = mapaGabarito.get(questao.numero_original) ?? null;
    const motivosLinha = [];

    if (!gabarito) {
      motivosLinha.push("questao_sem_gabarito");
    } else if (!gabarito.anulada && gabarito.status === "ok") {
      const letrasDisponiveis = new Set(questao.alternativas.map((a) => a.letra));
      if (gabarito.alternativa_correta && !letrasDisponiveis.has(gabarito.alternativa_correta)) {
        motivosLinha.push("alternativa_correta_inexistente");
      }
    }

    return {
      ...questao,
      gabarito,
      motivos_juncao: motivosLinha,
    };
  });

  return { juntadas, bloqueios };
}
