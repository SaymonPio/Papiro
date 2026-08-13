// Validador puro da resposta da OpenAI para o gerador de aula (Fase 2J-A).
//
// Sem I/O, sem chamada de rede, sem dependência de Deno nem de Node —
// arquivo .mjs simples para poder ser importado tanto pela Edge Function
// (Deno, import relativo "./validador.mjs") quanto pelos testes deste
// projeto (Node, node:test), sem duplicar a lógica em dois lugares.
//
// Contrato V1 dos 5 tipos de componente (Fase 2J-A, seção 3) — a IA NUNCA
// deve mandar "id": os UUIDs são gerados no servidor DEPOIS desta
// validação passar (ver index.ts). Qualquer componente com "id" já
// presente na resposta da IA é tratado como resposta INVÁLIDA — nunca
// removido e confiado silenciosamente.

export const TIPOS_COMPONENTE = [
  "diagnostico",
  "conceito",
  "recall",
  "questao_resolvida",
  "resumo_visual",
];

function ehStringNaoVazia(valor) {
  return typeof valor === "string" && valor.trim().length > 0;
}

function ehStringOuNull(valor) {
  return valor === null || valor === undefined || ehStringNaoVazia(valor);
}

function validarDiagnostico(c) {
  if (!ehStringNaoVazia(c.titulo)) return "diagnostico.titulo ausente ou vazio";
  if (!ehStringNaoVazia(c.introducao)) return "diagnostico.introducao ausente ou vazia";
  if (!ehStringNaoVazia(c.pergunta)) return "diagnostico.pergunta ausente ou vazia";
  if (!ehStringNaoVazia(c.resposta_esperada)) return "diagnostico.resposta_esperada ausente ou vazia";
  return null;
}

function validarConceito(c) {
  if (!ehStringNaoVazia(c.titulo)) return "conceito.titulo ausente ou vazio";
  if (!ehStringNaoVazia(c.explicacao)) return "conceito.explicacao ausente ou vazia";
  if (!ehStringOuNull(c.exemplo)) return "conceito.exemplo precisa ser string ou null";
  if (!ehStringOuNull(c.ponto_de_prova)) return "conceito.ponto_de_prova precisa ser string ou null";
  if (!ehStringOuNull(c.pegadinha)) return "conceito.pegadinha precisa ser string ou null";
  return null;
}

function validarRecall(c) {
  if (!ehStringNaoVazia(c.titulo)) return "recall.titulo ausente ou vazio";
  if (!ehStringNaoVazia(c.pergunta)) return "recall.pergunta ausente ou vazia";
  if (!ehStringNaoVazia(c.resposta)) return "recall.resposta ausente ou vazia";
  if (!ehStringOuNull(c.dica)) return "recall.dica precisa ser string ou null";
  return null;
}

function validarQuestaoResolvida(c) {
  if (!ehStringNaoVazia(c.enunciado)) return "questao_resolvida.enunciado ausente ou vazio";
  if (!Array.isArray(c.alternativas) || c.alternativas.length !== 4) {
    return "questao_resolvida.alternativas precisa ser um array com exatamente 4 itens";
  }

  const letras = new Set();
  for (const alt of c.alternativas) {
    if (typeof alt !== "object" || alt === null || Array.isArray(alt)) {
      return "questao_resolvida.alternativas contém um item que não é objeto";
    }
    if (!ehStringNaoVazia(alt.letra)) return "questao_resolvida.alternativas contém letra ausente ou vazia";
    if (!ehStringNaoVazia(alt.texto)) return "questao_resolvida.alternativas contém texto ausente ou vazio";
    const letra = alt.letra.trim().toUpperCase();
    if (letras.has(letra)) return `questao_resolvida.alternativas tem letra duplicada (${letra})`;
    letras.add(letra);
  }

  if (!ehStringNaoVazia(c.gabarito)) return "questao_resolvida.gabarito ausente ou vazio";
  if (!letras.has(c.gabarito.trim().toUpperCase())) {
    return "questao_resolvida.gabarito não corresponde a nenhuma alternativa existente";
  }

  if (!ehStringNaoVazia(c.raciocinio)) return "questao_resolvida.raciocinio ausente ou vazio";
  if (!ehStringOuNull(c.pegadinha)) return "questao_resolvida.pegadinha precisa ser string ou null";
  return null;
}

function validarResumoVisual(c) {
  if (!ehStringNaoVazia(c.titulo)) return "resumo_visual.titulo ausente ou vazio";
  if (!Array.isArray(c.pontos) || c.pontos.length < 1) {
    return "resumo_visual.pontos precisa ser um array com pelo menos 1 item (ideal: 3 a 7)";
  }
  for (const ponto of c.pontos) {
    if (!ehStringNaoVazia(ponto)) return "resumo_visual.pontos contém um item vazio ou que não é string";
  }
  return null;
}

const VALIDADORES_POR_TIPO = {
  diagnostico: validarDiagnostico,
  conceito: validarConceito,
  recall: validarRecall,
  questao_resolvida: validarQuestaoResolvida,
  resumo_visual: validarResumoVisual,
};

/**
 * Valida a resposta bruta da IA (já com JSON.parse aplicado) contra o
 * contrato V1 de estrutura.componentes. Nunca lança exceção — sempre
 * devolve { ok, erro } ou { ok: true, componentes, artigosAbordados }.
 *
 * @param {unknown} dados
 * @returns {{ ok: true, componentes: Array<Record<string, unknown>>, artigosAbordados: string[] } | { ok: false, erro: string }}
 */
export function validarRespostaGerador(dados) {
  if (typeof dados !== "object" || dados === null || Array.isArray(dados)) {
    return { ok: false, erro: "Resposta da IA não é um objeto JSON." };
  }

  if (!Array.isArray(dados.componentes)) {
    return { ok: false, erro: 'Resposta da IA não possui "componentes" como array.' };
  }

  // artigos_abordados: metadado de auditoria (Fase 2J-A, escopo fechado por
  // parte) — NÃO é uma trava jurídica, só registra o que a própria aula
  // efetivamente citou/ensinou. Obrigatório e sempre array, mesmo quando
  // vazio (nenhum artigo citado nesta aula é uma resposta válida).
  if (!Array.isArray(dados.artigos_abordados)) {
    return { ok: false, erro: 'Resposta da IA não possui "artigos_abordados" como array.' };
  }
  const artigosVistos = new Set();
  for (const artigo of dados.artigos_abordados) {
    if (!ehStringNaoVazia(artigo)) {
      return { ok: false, erro: "artigos_abordados contém um item vazio ou que não é string." };
    }
    if (artigosVistos.has(artigo)) {
      return { ok: false, erro: `artigos_abordados contém uma duplicata exata: ${JSON.stringify(artigo)}.` };
    }
    artigosVistos.add(artigo);
  }

  // Tamanho minimamente razoável: nem vazio, nem uma quantidade absurda que
  // sugere resposta corrompida/repetida.
  if (dados.componentes.length === 0) {
    return { ok: false, erro: "Resposta da IA não contém nenhum componente." };
  }
  if (dados.componentes.length > 40) {
    return { ok: false, erro: "Resposta da IA contém uma quantidade de componentes fora do razoável (possível truncamento/corrupção)." };
  }

  const tiposEncontrados = new Set();
  const componentesValidados = [];

  for (let indice = 0; indice < dados.componentes.length; indice += 1) {
    const c = dados.componentes[indice];

    if (typeof c !== "object" || c === null || Array.isArray(c)) {
      return { ok: false, erro: `Componente #${indice} não é um objeto JSON.` };
    }

    // A IA NUNCA deve decidir o id — resposta com "id" já presente é
    // tratada como inválida, nunca "corrigida" silenciosamente.
    if (Object.prototype.hasOwnProperty.call(c, "id")) {
      return { ok: false, erro: `Componente #${indice} veio com um campo "id" — a IA não pode decidir ids.` };
    }

    if (!ehStringNaoVazia(c.tipo) || !TIPOS_COMPONENTE.includes(c.tipo)) {
      return { ok: false, erro: `Componente #${indice} tem "tipo" ausente ou desconhecido: ${JSON.stringify(c.tipo)}.` };
    }

    const erroDoTipo = VALIDADORES_POR_TIPO[c.tipo](c);
    if (erroDoTipo) {
      return { ok: false, erro: `Componente #${indice} (${c.tipo}): ${erroDoTipo}.` };
    }

    tiposEncontrados.add(c.tipo);
    componentesValidados.push(c);
  }

  const tiposFaltando = TIPOS_COMPONENTE.filter((tipo) => !tiposEncontrados.has(tipo));
  if (tiposFaltando.length > 0) {
    return { ok: false, erro: `Faltam componentes obrigatórios dos tipos: ${tiposFaltando.join(", ")}.` };
  }

  // Sinal simples de truncamento óbvio: uma resposta "válida" na forma mas
  // com conteúdo minúsculo demais para ser uma aula real. 600 caracteres
  // foi calibrado para ficar acima do que os 5 tipos obrigatórios ocupam
  // só com nomes de campo + conteúdo de 1 caractere cada (~486 chars) —
  // qualquer aula com frases reais fica bem acima disso.
  const tamanhoTotal = JSON.stringify(componentesValidados).length;
  if (tamanhoTotal < 600) {
    return { ok: false, erro: "Resposta da IA parece truncada ou vazia demais para ser uma aula real." };
  }

  return { ok: true, componentes: componentesValidados, artigosAbordados: dados.artigos_abordados };
}
