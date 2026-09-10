// Perfilador de DOMINIO POLICIAL — PURO, multibanca, multi-curso (Fase
// 2C.4). Dimensao INDEPENDENTE de bank-style-profiler.mjs: aqui a
// pergunta e "o que e cobrado na area policial, seja qual for a banca",
// nunca "como a Fundatec formata suas questoes" (isso continua exclusivo
// de bank-style-profiler.mjs — Secao 0-1 do mandato 2C.4, nunca
// misturado).
//
// Reaproveita DELIBERADAMENTE a logica ja testada de
// bank-style-profiler.mjs (normalizarBanca, classificarProveniencia) —
// nunca reimplementa exclusao de autoral/inativa/banca-alvo do zero.
// O truque para tornar classificarProveniencia multibanca sem alterar sua
// assinatura: passamos bancaAlvoNormalizada = a PROPRIA banca da questao,
// entao a checagem "bancaNormalizada !== bancaAlvoNormalizada" nunca
// rejeita uma banca REAL por nao ser uma banca-alvo fixa — so as
// exclusoes genuinas (Papiro/autoral, inativa) continuam se aplicando.

import { normalizarBanca, classificarProveniencia } from "./bank-style-profiler.mjs";
import { classificarDominioPolicial } from "./police-domain-classifier.mjs";
import { classificarPadraoRaciocinio, classificarSubtemaConcordanciaVerbal } from "./police-domain-features.mjs";

const MAPA_PROVENIENCIA_DOMINIO = Object.freeze({
  REAL_OFFICIAL_CONFIRMED: "POLICE_REAL_OFFICIAL_CONFIRMED",
  REAL_PROVENANCE_PARTIAL: "POLICE_REAL_PROVENANCE_PARTIAL",
  REAL_UNCONFIRMED: "POLICE_REAL_UNCONFIRMED",
  NOT_REAL: "NOT_POLICE_REAL",
});

/**
 * Classifica UMA questao nas duas dimensoes independentes exigidas pela
 * Secao 5 do mandato: dominio (e policial? qual categoria?) e proveniencia
 * (POLICE_REAL_OFFICIAL_CONFIRMED / _PARTIAL / _UNCONFIRMED / NOT_POLICE_REAL).
 * Uma questao NAO-policial e sempre NOT_POLICE_REAL, independentemente de
 * sua proveniencia documental (nunca precisa ser avaliada quanto a isso).
 *
 * @param {object} questaoRaw
 * @param {{ idsComProvenienciaConfirmada?: Set<number> }} opcoes
 *   idsComProvenienciaConfirmada — Set MULTIBANCA (ver
 *   obterProvenienciaConfirmadaTodasBancas em question-provenance-manifest.mjs),
 *   nunca restrito a uma unica banca-alvo.
 */
export function classificarQuestaoDominioPolicial(questaoRaw, { idsComProvenienciaConfirmada = new Set() } = {}) {
  const dominio = classificarDominioPolicial(questaoRaw);
  if (!dominio.isPolice) {
    return { proveniencia: "NOT_POLICE_REAL", dominio };
  }
  const bancaNormalizada = normalizarBanca(questaoRaw.banca);
  const provenienciaBase = classificarProveniencia(questaoRaw, {
    bancaAlvoNormalizada: bancaNormalizada,
    bancaAlvoOriginal: questaoRaw.banca,
    idsComProvenienciaConfirmada,
  });
  return { proveniencia: MAPA_PROVENIENCIA_DOMINIO[provenienciaBase], dominio };
}

// Fase 2C.4, Secao 13: confidence PROPRIO do dominio policial — nunca
// reaproveita cegamente os limiares de calcularConfianca (bank style).
// Exige tambem diversidade TEMPORAL (distinctYears), nao so provas —
// "diversidade de provas" + "diversidade temporal" sao criterios
// distintos e explicitos no mandato (Secao 13-A).
export function calcularConfiancaDominio({ confirmed, distinctExams, distinctYears }) {
  if (confirmed >= 30 && distinctExams >= 3 && distinctYears >= 3) return "HIGH";
  if (confirmed >= 15 && distinctExams >= 2 && distinctYears >= 2) return "MEDIUM";
  if (confirmed >= 1) return "LOW";
  return "INSUFFICIENT";
}

function ehRecente(ano, anoAtual, recentYearWindow) {
  return ano !== null && ano !== undefined && anoAtual - ano < recentYearWindow;
}

/**
 * Pipeline completo: recebe linhas cruas (enunciado/alternativas em
 * memoria, NUNCA persistidas — Secao 20) + parametros, devolve o perfil
 * sanitizado (so metadados/estatisticas) pronto para escrever em disco.
 *
 * @param {{
 *   subject: string, materiaId: number,
 *   questoesRaw: object[],
 *   recentYearWindow: number, anoAtual: number,
 *   idsComProvenienciaConfirmada?: Set<number>,
 *   provenienciaConfirmadaPorId?: Map<number, { examKey: string, bank: string, contest: string, role: string, year: number }>,
 *   assuntoConcordanciaVerbalId?: number|null,
 * }} entrada
 */
export function construirPerfilDominioPolicial({
  subject,
  materiaId,
  questoesRaw,
  recentYearWindow,
  anoAtual,
  idsComProvenienciaConfirmada = new Set(),
  provenienciaConfirmadaPorId = new Map(),
  assuntoConcordanciaVerbalId = null,
}) {
  const classificadas = questoesRaw.map((q) => {
    const { proveniencia, dominio } = classificarQuestaoDominioPolicial(q, { idsComProvenienciaConfirmada });
    const meta = provenienciaConfirmadaPorId.get(q.id);
    const ehAssuntoConcordanciaVerbal = assuntoConcordanciaVerbalId != null && q.assunto_id === assuntoConcordanciaVerbalId;
    return {
      id: q.id,
      proveniencia,
      categoria: dominio.category,
      dominioReason: dominio.reason,
      banca: q.banca,
      bank: meta?.bank ?? q.banca,
      concurso: q.concurso ?? null,
      ano: q.ano ?? null,
      assuntoId: q.assunto_id ?? null,
      ehAssuntoConcordanciaVerbal,
      recente: ehRecente(q.ano, anoAtual, recentYearWindow),
      raciocinio: classificarPadraoRaciocinio(q.enunciado),
      subtemaConcordanciaVerbal: ehAssuntoConcordanciaVerbal ? classificarSubtemaConcordanciaVerbal(q.enunciado) : null,
      examKey: meta?.examKey ?? null,
      dificuldade: q.dificuldade ?? null,
    };
  });

  const canonical = classificadas.filter((q) => q.proveniencia === "POLICE_REAL_OFFICIAL_CONFIRMED");
  const discoveryPartial = classificadas.filter((q) => q.proveniencia === "POLICE_REAL_PROVENANCE_PARTIAL");
  const discoveryUnconfirmed = classificadas.filter((q) => q.proveniencia === "POLICE_REAL_UNCONFIRMED");
  const notPolice = classificadas.filter((q) => q.proveniencia === "NOT_POLICE_REAL");

  // Secao 6: CANONICAL_CORPUS alimenta TODAS as metricas abaixo;
  // DISCOVERY_CORPUS (partial + unconfirmed) NUNCA contamina estatisticas
  // canonicas — so aparece em discovery_sample, para orientar curadoria futura.
  const examKeysCanonical = new Set(canonical.map((q) => q.examKey).filter(Boolean));
  const contestsCanonical = new Set(canonical.map((q) => q.concurso).filter(Boolean));
  const banksCanonical = new Set(canonical.map((q) => q.bank).filter(Boolean));
  const yearsCanonical = new Set(canonical.map((q) => q.ano).filter((a) => a !== null && a !== undefined));

  const categoriaCount = {};
  for (const q of canonical) categoriaCount[q.categoria] = (categoriaCount[q.categoria] ?? 0) + 1;

  const raciocinioCount = {};
  for (const q of canonical) raciocinioCount[q.raciocinio] = (raciocinioCount[q.raciocinio] ?? 0) + 1;

  const subtemaCount = {};
  const canonicalConcordanciaVerbal = canonical.filter((q) => q.ehAssuntoConcordanciaVerbal);
  for (const q of canonicalConcordanciaVerbal) {
    if (q.subtemaConcordanciaVerbal) subtemaCount[q.subtemaConcordanciaVerbal] = (subtemaCount[q.subtemaConcordanciaVerbal] ?? 0) + 1;
  }

  const dificuldadeCount = {};
  for (const q of canonical) {
    const d = q.dificuldade ?? "desconhecida";
    dificuldadeCount[d] = (dificuldadeCount[d] ?? 0) + 1;
  }

  const recentesCanonical = canonical.filter((q) => q.recente).length;

  const confidence = calcularConfiancaDominio({ confirmed: canonical.length, distinctExams: examKeysCanonical.size, distinctYears: yearsCanonical.size });

  const limitations = [];
  const dificuldadesDistintas = new Set(canonical.map((q) => q.dificuldade)).size;
  if (canonical.length > 0 && dificuldadesDistintas <= 1) {
    limitations.push(
      `Campo "dificuldade" nao apresenta variancia no corpus canonico (${dificuldadesDistintas} valor(es) distinto(s): ${[...new Set(canonical.map((q) => q.dificuldade))].join(", ")}) — nao pode ser usado como sinal discriminativo de dificuldade real; nenhuma heuristica de dificuldade foi inventada a partir do texto.`
    );
  }
  limitations.push(
    `Corpus canonico atual cobre ${banksCanonical.size} banca(s) distinta(s) (${[...banksCanonical].join(", ") || "nenhuma"}) — a arquitetura e multibanca por desenho, mas os dados reais disponiveis ainda nao exercitam mais de uma banca; nada foi inventado para simular diversidade.`
  );
  limitations.push(
    `discovery_sample (${discoveryPartial.length + discoveryUnconfirmed.length} questoes: ${discoveryPartial.length} PARTIAL + ${discoveryUnconfirmed.length} UNCONFIRMED) NUNCA alimenta estatisticas canonicas acima — serve apenas para localizar onde ha material policial a curar documentalmente no futuro.`
  );
  if (canonicalConcordanciaVerbal.length > 0 && canonicalConcordanciaVerbal.length < 5) {
    limitations.push(
      `Amostra canonica de Concordancia verbal e muito pequena (${canonicalConcordanciaVerbal.length} questao(oes)) para sustentar incidencia de subtema estatisticamente robusta — reportada apenas como diagnostico pontual, nunca como distribuicao representativa.`
    );
  }

  const perfil = {
    schema_version: 1,
    domain: "POLICE_PUBLIC_SAFETY",
    subject,
    materia_id: materiaId,
    generated_at: new Date().toISOString(),
    recent_year_window: recentYearWindow,
    ano_atual_referencia: anoAtual,

    canonical_sample: {
      questions: canonical.length,
      exams: examKeysCanonical.size,
      contests: contestsCanonical.size,
      banks: [...banksCanonical].sort(),
      years: [...yearsCanonical].sort((a, b) => a - b),
      recent: recentesCanonical,
      historical: canonical.length - recentesCanonical,
    },

    discovery_sample: {
      partial: discoveryPartial.length,
      unconfirmed: discoveryUnconfirmed.length,
      total: discoveryPartial.length + discoveryUnconfirmed.length,
    },

    incidence: {
      by_category: categoriaCount,
      total_candidates_police: canonical.length + discoveryPartial.length + discoveryUnconfirmed.length,
      total_not_police: notPolice.length,
    },

    concordancia_verbal: {
      assunto_id: assuntoConcordanciaVerbalId,
      canonical_questions: canonicalConcordanciaVerbal.length,
      exams: new Set(canonicalConcordanciaVerbal.map((q) => q.examKey).filter(Boolean)).size,
      banks: [...new Set(canonicalConcordanciaVerbal.map((q) => q.bank).filter(Boolean))].sort(),
      years: [...new Set(canonicalConcordanciaVerbal.map((q) => q.ano).filter((a) => a !== null && a !== undefined))].sort((a, b) => a - b),
      subtopics: Object.entries(subtemaCount).map(([subtopic, count]) => ({
        subtopic,
        count,
        percent: canonicalConcordanciaVerbal.length > 0 ? Math.round((count / canonicalConcordanciaVerbal.length) * 1000) / 10 : 0,
      })),
    },

    difficulty: dificuldadeCount,

    reasoning_patterns: raciocinioCount,

    confidence,

    limitations,
  };

  return { perfil, classificadas };
}
