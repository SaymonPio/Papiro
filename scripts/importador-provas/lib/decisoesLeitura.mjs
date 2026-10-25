// Decisão de leitura por questão, DECLARADA no staging da prova
// (metadata.decisoes_leitura) — nunca inferida, nunca por texto. Quando o
// gate de ordem (integridade.mjs, ordem_leituras_divergente) acusa que a
// leitura escolhida e a posicional trazem o mesmo conteúdo em outra ordem,
// a representação de UMA questão só troca para a posicional por decisão
// humana presa à parte, ao tipo do caderno, ao número impresso e às
// assinaturas (sha256) da questão nas DUAS leituras (checado numa prova
// real: Fundatec/PC-RS 2025 Escrivão-Inspetor, P2 TIPO 1, ordem conferida
// no PDF oficial e no TIPO 2). Nenhuma palavra é alterada: só se escolhe
// qual leitura do PDF representa a questão.
//
// "decisoes_leitura": [{
//   "parte": "<código da parte>", "tipo_caderno": <tipo canônico>, "numero_original": <nº impresso>,
//   "leitura": "posicional",
//   "decisao": "ORDEM_OFICIAL_CONFIRMADA_POR_LEITURA_POSICIONAL",
//   "assinatura_escolhida": "<sha256 da questão na leitura escolhida>",
//   "assinatura_posicional": "<sha256 da questão na leitura posicional>",
//   "evidencias": ["..."]
// }]
//
// Qualquer descompasso BLOQUEIA o lote: decisão de outra parte/caderno,
// sem leitura posicional cruzada, para questão sem divergência de ordem
// (obsoleta), com assinatura que não bate (a extração mudou: reauditar) ou
// com palavras diferentes entre as leituras.

import { assinaturaDaQuestao, mesmasPalavras } from "./integridade.mjs";

const ASSINATURA = /^[0-9a-f]{64}$/;

function contextoDaProva(metadata) {
  const declaracao = metadata?.parte ?? metadata?.caderno ?? null;
  return { parte: metadata?.parte?.codigo ?? null, tipo_caderno: declaracao?.tipo_caderno_canonico ?? null };
}

function validar(decisao, i) {
  const rotulo = `metadata.decisoes_leitura[${i}]`;
  if (!decisao || typeof decisao !== "object") return `${rotulo} inválida`;
  if (!Number.isInteger(decisao.numero_original) || decisao.numero_original < 1) return `${rotulo}.numero_original inválido (${JSON.stringify(decisao.numero_original)})`;
  if (decisao.leitura !== "posicional") return `${rotulo}.leitura = ${JSON.stringify(decisao.leitura)} — só a leitura "posicional" (ordem visual da página) resolve divergência de ordem`;
  for (const campo of ["assinatura_escolhida", "assinatura_posicional"]) if (!ASSINATURA.test(decisao[campo] ?? "")) return `${rotulo}.${campo} inválida (sha256 hexadecimal)`;
  if (typeof decisao.decisao !== "string" || !decisao.decisao.trim()) return `${rotulo}.decisao ausente`;
  if (!Array.isArray(decisao.evidencias) || decisao.evidencias.length === 0) return `${rotulo}.evidencias ausentes — registre como a ordem foi confirmada`;
  return null;
}

// { questoes, aplicadas, bloqueio }. questoes: as da leitura escolhida, com
// cada questão decidida trocada pela da leitura posicional (decisao_leitura
// anotada). comparacoes: compararQuestoes(escolhidas, posicionais), ou null
// quando o cruzamento não foi aplicado.
export function aplicarDecisoesDeLeitura(metadata, { questoes, posicionais = null, comparacoes = null, referenciaPosicional = false }) {
  const decisoes = metadata?.decisoes_leitura;
  if (decisoes === undefined) return { questoes, aplicadas: [], bloqueio: null };
  if (!Array.isArray(decisoes) || decisoes.length === 0) return { questoes, aplicadas: [], bloqueio: "metadata.decisoes_leitura precisa ser uma lista não vazia" };
  if (!referenciaPosicional || !comparacoes || !posicionais) {
    return { questoes, aplicadas: [], bloqueio: "metadata.decisoes_leitura declarada, mas não há leitura posicional cruzada com a escolhida neste documento — nada a decidir" };
  }
  const contexto = contextoDaProva(metadata);
  const vistos = new Set();
  const porNumero = new Map(posicionais.map((q) => [q.numero_original, q]));
  const trocas = new Map();
  const aplicadas = [];
  for (const [i, decisao] of decisoes.entries()) {
    const invalida = validar(decisao, i);
    if (invalida) return { questoes, aplicadas: [], bloqueio: invalida };
    const rotulo = `decisão de leitura da questão ${decisao.numero_original}`;
    if (vistos.has(decisao.numero_original)) return { questoes, aplicadas: [], bloqueio: `${rotulo} declarada mais de uma vez` };
    vistos.add(decisao.numero_original);
    if ((decisao.parte ?? null) !== contexto.parte || (decisao.tipo_caderno ?? null) !== contexto.tipo_caderno) {
      return { questoes, aplicadas: [], bloqueio: `${rotulo} é da parte ${decisao.parte ?? "-"} / tipo ${decisao.tipo_caderno ?? "-"}, mas o staging lê a parte ${contexto.parte ?? "-"} / tipo ${contexto.tipo_caderno ?? "-"}` };
    }
    const escolhida = questoes.find((q) => q.numero_original === decisao.numero_original);
    const posicional = porNumero.get(decisao.numero_original);
    if (!escolhida || !posicional) return { questoes, aplicadas: [], bloqueio: `${rotulo}: questão ausente em uma das leituras` };
    const comparacao = comparacoes.get(decisao.numero_original);
    if (comparacao?.tipo === "divergente" || !(comparacao?.ordem || comparacao?.tipo === "reordenada")) {
      return { questoes, aplicadas: [], bloqueio: `${rotulo}: as leituras não têm divergência de ordem (${comparacao?.tipo ?? "sem comparação"}) — decisão obsoleta, reauditar` };
    }
    const assinaturas = { escolhida: assinaturaDaQuestao(escolhida), posicional: assinaturaDaQuestao(posicional) };
    if (assinaturas.escolhida !== decisao.assinatura_escolhida || assinaturas.posicional !== decisao.assinatura_posicional) {
      return { questoes, aplicadas: [], bloqueio: `${rotulo}: assinatura do conteúdo não confere (escolhida ${assinaturas.escolhida}, posicional ${assinaturas.posicional}) — a extração mudou, reauditar` };
    }
    if (!mesmasPalavras(escolhida, posicional)) return { questoes, aplicadas: [], bloqueio: `${rotulo}: as leituras não têm as mesmas palavras — decisão de ordem não troca conteúdo` };
    const registro = { leitura: decisao.leitura, decisao: decisao.decisao, assinatura_escolhida: decisao.assinatura_escolhida, assinatura_posicional: decisao.assinatura_posicional, evidencias: decisao.evidencias };
    trocas.set(decisao.numero_original, { ...posicional, decisao_leitura: registro });
    aplicadas.push({ numero: decisao.numero_original, ...registro });
  }
  return { questoes: questoes.map((q) => trocas.get(q.numero_original) ?? q), aplicadas, bloqueio: null };
}
