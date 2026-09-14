// Jurisprudência essencial — entrada e montagem de prompt (Fase 1 desta
// evolução).
//
// Sem I/O, sem chamada de rede, sem dependência de Deno nem de Node —
// mesmo princípio de escopo.mjs/validador.mjs: arquivo .mjs puro para
// poder ser importado tanto pela Edge Function (Deno) quanto pelos testes
// deste projeto (Node, node:test), sem duplicar a lógica em dois lugares.
//
// Genérico e multi-curso de propósito: nada aqui sabe o nome de nenhuma
// unidade/matéria/curso/tribunal/precedente específico. Quem decide QUAIS
// jurisprudências são "previamente validadas" para uma geração é sempre o
// chamador (hoje, o admin no momento de gerar a aula — ver index.ts), nunca
// este módulo nem o modelo de IA.
//
// Regra central (proteção contra alucinação, Fase 1 seção 7 do mandato):
// jurisprudência ausente/vazia na entrada -> o prompt instrui
// explicitamente a NÃO criar nenhum componente "jurisprudencia_essencial"
// e a NÃO inventar nenhum precedente. O modelo nunca é instruído a
// "buscar" jurisprudência por conta própria.

const CAMPOS_OBRIGATORIOS_ENTRADA = [
  "tribunal",
  "identificacao",
  "dispositivo_relacionado",
  "entendimento_validado",
  "fonte_validada",
];

function ehStringNaoVazia(valor) {
  return typeof valor === "string" && valor.trim().length > 0;
}

/**
 * Valida a forma de `jurisprudenciasValidadas` recebida no corpo da
 * requisição do gerador. NUNCA lança exceção — sempre devolve
 * { ok, erro } ou { ok: true, itens }. Lista ausente/vazia é um estado
 * válido (significa "nenhuma jurisprudência validada para esta geração"),
 * nunca um erro.
 *
 * @param {unknown} entrada
 * @returns {{ ok: true, itens: Array<{tribunal:string, identificacao:string, dispositivo_relacionado:string, entendimento_validado:string, fonte_validada:string}> } | { ok: false, erro: string }}
 */
export function validarJurisprudenciasValidadasEntrada(entrada) {
  if (entrada === undefined || entrada === null) {
    return { ok: true, itens: [] };
  }
  if (!Array.isArray(entrada)) {
    return { ok: false, erro: "jurisprudenciasValidadas precisa ser um array." };
  }
  if (entrada.length > 6) {
    // Trava conservadora: uma aula não deveria carregar mais de um punhado
    // de precedentes-âncora. Nada mágico no número — só evita um payload
    // absurdo acidentalmente inflando o prompt.
    return { ok: false, erro: "jurisprudenciasValidadas contém mais itens do que o razoável para uma única aula (máx. 6)." };
  }

  const itens = [];
  for (let indice = 0; indice < entrada.length; indice += 1) {
    const item = entrada[indice];
    if (typeof item !== "object" || item === null || Array.isArray(item)) {
      return { ok: false, erro: `jurisprudenciasValidadas[${indice}] não é um objeto.` };
    }
    for (const campo of CAMPOS_OBRIGATORIOS_ENTRADA) {
      if (!ehStringNaoVazia(item[campo])) {
        return { ok: false, erro: `jurisprudenciasValidadas[${indice}].${campo} ausente ou vazio.` };
      }
    }
    itens.push({
      tribunal: item.tribunal.trim(),
      identificacao: item.identificacao.trim(),
      dispositivo_relacionado: item.dispositivo_relacionado.trim(),
      entendimento_validado: item.entendimento_validado.trim(),
      fonte_validada: item.fonte_validada.trim(),
    });
  }
  return { ok: true, itens };
}

/**
 * Monta o bloco de prompt sobre jurisprudência — mesma filosofia do bloco
 * de fontes já existente em index.ts (montarPromptContexto/linhaFontes):
 * quando há itens, lista exatamente o que foi validado e instrui fidelidade
 * estrita; quando não há, instrui explicitamente a NÃO criar o componente
 * e a NÃO inventar nada.
 *
 * @param {Array<{tribunal:string, identificacao:string, dispositivo_relacionado:string, entendimento_validado:string, fonte_validada:string}>} itens
 * @returns {string}
 */
export function montarBlocoJurisprudencia(itens) {
  if (!Array.isArray(itens) || itens.length === 0) {
    return `Nenhuma jurisprudência foi validada e fornecida para esta geração. Por isso, NÃO crie nenhum componente "jurisprudencia_essencial" nesta aula — não busque, não infira e não invente nenhum precedente, tribunal, número de processo, tema, súmula, tese, órgão julgador, data ou entendimento jurisprudencial. O conteúdo desta aula deve se apoiar apenas na lei/escopo/fontes já fornecidos acima.`;
  }

  const linhas = itens
    .map(
      (item, indice) =>
        `${indice + 1}. Tribunal: ${item.tribunal} | Identificação: ${item.identificacao} | Dispositivo relacionado: ${item.dispositivo_relacionado} | Entendimento validado: ${item.entendimento_validado} | Fonte: ${item.fonte_validada}`,
    )
    .join("\n");

  return `As seguintes jurisprudências foram PREVIAMENTE VALIDADAS pela curadoria humana e podem ser usadas nesta aula, cada uma no componente "jurisprudencia_essencial" (um componente por item abaixo, no máximo):
${linhas}

Regras estritas para o uso dessas jurisprudências:
- use SOMENTE tribunal, identificação, dispositivo relacionado, entendimento e fonte exatamente como fornecidos acima — nunca altere o número/identificação do precedente, nunca troque o tribunal, nunca amplie ou generalize o entendimento além do que foi validado;
- NÃO invente nenhuma jurisprudência além das listadas acima, mesmo que pareça relevante ou que você "saiba" de outro precedente sobre o tema;
- NÃO crie um componente "jurisprudencia_essencial" para um item que não esteja nesta lista;
- se uma jurisprudência validada acima não for relevante para o escopo autorizado desta aula específica, simplesmente não a use — não é obrigatório usar todas;
- o campo "entendimento" do componente deve explicar o entendimento validado de forma didática, mantendo fidelidade ao que foi fornecido — nunca reescrever a tese de um jeito que mude o sentido jurídico;
- o campo "como_cai_na_prova" deve indicar a consequência prática para o aluno (ex.: que tipo de afirmação incorreta costuma aparecer em prova sobre esse ponto), sem inventar dado novo além do entendimento validado.`;
}
