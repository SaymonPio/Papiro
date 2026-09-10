// Avaliador de fidelidade de DOMINIO POLICIAL para UMA questao gerada
// (Fase 2C.4, Secao 16). Independente de bank-style-fidelity.mjs — a
// pergunta aqui NUNCA e "isso parece Fundatec", e sim "esse conteudo tem
// sustentacao real na area policial, de qualquer banca". Puro — nunca
// chama IA, nunca decide "aprovada".

import { classificarSubtemaConcordanciaVerbal } from "./police-domain-features.mjs";

export const STATUS_FIDELIDADE_DOMINIO = Object.freeze({
  POLICE_DOMAIN_MATCH: "POLICE_DOMAIN_MATCH",
  POLICE_DOMAIN_REVIEW: "POLICE_DOMAIN_REVIEW",
  POLICE_DOMAIN_MISMATCH: "POLICE_DOMAIN_MISMATCH",
  POLICE_DOMAIN_INSUFFICIENT_EVIDENCE: "POLICE_DOMAIN_INSUFFICIENT_EVIDENCE",
});

// Fase 2C.4, Secao 16: amostra canonica minima para arriscar um
// MATCH/REVIEW/MISMATCH por subtema — abaixo disso, qualquer veredito
// seria estatisticamente vazio (n=1 nao sustenta nem confirmar nem negar
// suporte a um subtema especifico). Limiar documentado, nunca implicito.
const AMOSTRA_MINIMA_SUBTEMA = 3;

/**
 * @param {{ enunciado: string }} questaoGerada
 * @param {object} perfilDominio — saida de police-domain-profiler.mjs#construirPerfilDominioPolicial
 */
export function avaliarFidelidadeDominioPolicial(questaoGerada, perfilDominio) {
  if (!perfilDominio || perfilDominio.confidence === "LOW" || perfilDominio.confidence === "INSUFFICIENT") {
    return {
      subtopic_classification: null,
      police_domain_status: STATUS_FIDELIDADE_DOMINIO.POLICE_DOMAIN_INSUFFICIENT_EVIDENCE,
      reason_codes: ["DOMAIN_CONFIDENCE_LOW_OR_EMPTY"],
    };
  }

  const cv = perfilDominio.concordancia_verbal;
  if (!cv || cv.canonical_questions < AMOSTRA_MINIMA_SUBTEMA) {
    return {
      subtopic_classification: null,
      police_domain_status: STATUS_FIDELIDADE_DOMINIO.POLICE_DOMAIN_INSUFFICIENT_EVIDENCE,
      reason_codes: ["CONCORDANCIA_VERBAL_CANONICAL_SAMPLE_TOO_SMALL"],
    };
  }

  const subtema = classificarSubtemaConcordanciaVerbal(questaoGerada.enunciado);
  const entradaSubtema = cv.subtopics.find((s) => s.subtopic === subtema);
  const reasonCodes = [];
  let status;
  if (entradaSubtema && entradaSubtema.count > 0) {
    status = STATUS_FIDELIDADE_DOMINIO.POLICE_DOMAIN_MATCH;
  } else if (cv.canonical_questions > 0) {
    reasonCodes.push("SUBTOPIC_UNSUPPORTED_BY_CANONICAL_POLICE_CORPUS");
    status = STATUS_FIDELIDADE_DOMINIO.POLICE_DOMAIN_REVIEW;
  } else {
    reasonCodes.push("NO_CANONICAL_POLICE_EVIDENCE_FOR_UNIT");
    status = STATUS_FIDELIDADE_DOMINIO.POLICE_DOMAIN_MISMATCH;
  }

  return {
    subtopic_classification: subtema,
    police_domain_status: status,
    reason_codes: reasonCodes,
  };
}
