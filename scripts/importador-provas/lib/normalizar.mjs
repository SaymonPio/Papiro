// Monta o objeto normalizado por questão, no formato pedido (conceitualmente
// compatível com questoes/alternativas/curso_questoes do Papiro, mas isto
// NUNCA é um INSERT — é só a estrutura que, depois de revisão humana,
// poderia alimentar um importador real).

import { juntarQuebrasArtificiais } from "./quebrasDeLinha.mjs";
import { comporEnunciado } from "./textoBase.mjs";

// O enunciado normalizado é o que seria PERSISTIDO: questão
// autossuficiente, com o(s) texto(s)-base de que ela depende incorporados
// antes do comando (mesma convenção do legado — o schema não tem tabela
// de textos). O comando puro fica em _interno.enunciado_comando. Quebras
// de linha do PDF no meio da frase são juntadas (quebrasDeLinha.mjs) —
// só espaço em branco muda.
export function normalizarQuestao(juntada, metadata, classificacao) {
  const gabarito = juntada.gabarito;
  const textosBase = juntada.textos_base ?? (juntada.texto_base ? [{ id: juntada.texto_base_id, tipo: "cabecalho", texto: juntada.texto_base, confiavel: true, motivo: null }] : []);
  const letraCorreta = gabarito && !gabarito.anulada ? gabarito.alternativa_correta : null;

  const alternativas = juntada.alternativas.map((alternativa) => ({
    letra: alternativa.letra,
    texto: alternativa.texto,
    correta: letraCorreta !== null && alternativa.letra === letraCorreta,
  }));

  return {
    numero_original: juntada.numero_original,
    enunciado: juntarQuebrasArtificiais(comporEnunciado(textosBase, juntada.enunciado)),
    alternativas,
    banca: metadata?.banca ?? null,
    ano: metadata?.ano ?? null,
    orgao: metadata?.orgao ?? null,
    cargo: metadata?.cargo ?? null,
    prova: metadata?.nome_prova ?? null,
    fonte_url: metadata?.fonte_url ?? null,
    fonte_tipo: metadata?.fonte_tipo ?? null,
    pagina_origem: juntada.pagina_origem,
    materia_sugerida: classificacao.materia_id,
    assunto_sugerido: classificacao.assunto_id,
    confidence: classificacao.confidence,

    // Campos internos de auditoria da PoC (não fazem parte do contrato
    // mínimo pedido, mas sustentam o relatório e a revisão humana).
    _interno: {
      atravessa_pagina: juntada.atravessa_pagina,
      texto_base_id: juntada.texto_base_id,
      texto_base: juntada.texto_base,
      enunciado_comando: juntarQuebrasArtificiais(juntada.enunciado),
      textos_base: textosBase.map((t) => ({ id: t.id, tipo: t.tipo, confiavel: t.confiavel, motivo: t.motivo, caracteres: t.texto.length, linhas_numeradas: t.linhas_numeradas ?? false })),
      dependencia_texto_incerta: juntada.dependencia_texto_incerta ?? null,
      alternativa_suspeita: juntada.alternativa_suspeita ?? null,
      referencia_visual: juntada.referencia_visual ?? null,
      alertas_expressao: juntada.alertas_expressao ?? [],
      expressoes: juntada.expressoes ?? [],
      gabarito_historico: gabarito?.historico ?? null,
      alternativa_faltante: juntada.alternativa_faltante,
      numero_impresso: juntada.numero_impresso ?? juntada.numero_original,
      materia_detectada: juntada.materia_detectada ?? null,
      contagem_materia_divergente: juntada.contagem_materia_divergente ?? false,
      gabarito_anulado: gabarito?.anulada ?? null,
      gabarito_alterado: gabarito?.alterada ?? null,
      gabarito_observacao: gabarito?.observacao ?? null,
      gabarito_status: gabarito?.status ?? "ausente",
      motivos_juncao: juntada.motivos_juncao,
      motivo_classificacao: classificacao.motivo,
      materia_id_candidato: classificacao.materia_id_candidato ?? null,
      assunto_id_candidato: classificacao.assunto_id_candidato ?? null,
    },
  };
}
