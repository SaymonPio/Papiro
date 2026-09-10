// Fase 2C.4 — testes do POLICE_DOMAIN_PROFILE (dimensao independente do
// BANK_STYLE_PROFILE). Fixtures SINTETICAS (nunca texto integral de prova
// REAL copiado). Nenhum teste faz rede real.

import assert from "node:assert/strict";
import test from "node:test";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { DOMAIN_CATEGORIES, classificarDominioPolicial } from "../scripts/curadoria-autoral/lib/police-domain-classifier.mjs";
import {
  REASONING_PATTERNS,
  SUBTEMAS_CONCORDANCIA_VERBAL,
  classificarPadraoRaciocinio,
  classificarSubtemaConcordanciaVerbal,
} from "../scripts/curadoria-autoral/lib/police-domain-features.mjs";
import {
  classificarQuestaoDominioPolicial,
  calcularConfiancaDominio,
  construirPerfilDominioPolicial,
} from "../scripts/curadoria-autoral/lib/police-domain-profiler.mjs";
import { STATUS_FIDELIDADE_DOMINIO, avaliarFidelidadeDominioPolicial } from "../scripts/curadoria-autoral/lib/police-domain-fidelity.mjs";
import { calcularHashPerfilBanca } from "../scripts/curadoria-autoral/lib/audit-state.mjs";

function questaoFixture(overrides = {}) {
  return {
    id: 1,
    banca: "Fundatec",
    concurso: "Brigada Militar RS - Soldado Nível III",
    ano: 2022,
    fonte: "Fundatec — BM RS Soldado Nível III 2022 — Questão 05",
    gerada_por_ia: false,
    ativa: true,
    materia_id: 6,
    assunto_id: 99,
    enunciado: "Assinale a alternativa correta.",
    ...overrides,
  };
}

// ==================== CLASSIFICACAO DE DOMINIO (multibanca) ====================

test("1. Fundatec policial (Brigada Militar) e classificada corretamente, com reason rastreavel", () => {
  const r = classificarDominioPolicial(questaoFixture());
  assert.equal(r.isPolice, true);
  assert.equal(r.category, "POLICIA_MILITAR");
  assert.ok(r.reason.includes("POLICIA_MILITAR"));
  assert.ok(DOMAIN_CATEGORIES.includes(r.category));
});

test("2. FGV policial (concurso sintetico de Polícia Civil) tambem e classificada — nunca depende da banca, so do concurso", () => {
  const r = classificarDominioPolicial({ banca: "FGV", concurso: "Delegado de Polícia Civil do Estado de Goiás/2026" });
  assert.equal(r.isPolice, true);
  assert.equal(r.category, "POLICIA_CIVIL");
});

test("3. banco especifico (banca) NUNCA contamina a classificacao de dominio — mesmo concurso policial, bancas diferentes, mesma categoria", () => {
  const a = classificarDominioPolicial({ banca: "Fundatec", concurso: "Corpo de Bombeiros Militar RS - Soldado" });
  const b = classificarDominioPolicial({ banca: "CEBRASPE", concurso: "Corpo de Bombeiros Militar RS - Soldado" });
  const c = classificarDominioPolicial({ banca: "FCC", concurso: "Corpo de Bombeiros Militar RS - Soldado" });
  assert.equal(a.category, "CORPO_DE_BOMBEIROS");
  assert.equal(b.category, "CORPO_DE_BOMBEIROS");
  assert.equal(c.category, "CORPO_DE_BOMBEIROS");
});

test("4. concurso NAO policial (mesmo de banca conhecida/policial-adjacente) NAO entra so por coincidencia de palavra", () => {
  const r1 = classificarDominioPolicial({ banca: "Fundatec", concurso: "Profis (Pref Viamão)/Pref Viamão/Magistério para Educação Infantil/2022" });
  assert.equal(r1.isPolice, false);
  assert.equal(r1.category, null);
  const r2 = classificarDominioPolicial({ banca: "Fundatec", concurso: "Arm (Pref Bagé)/Pref Bagé/2024" });
  assert.equal(r2.isPolice, false, "'Arm' sozinho e ambiguo demais para ser classificado policial sem mais contexto");
});

test("5. concurso ausente/vazio -> NAO policial (nunca adivinhado), com reason explicita", () => {
  const r = classificarDominioPolicial({ banca: "Fundatec", concurso: null });
  assert.equal(r.isPolice, false);
  assert.ok(r.reason.includes("ausente"));
});

test("6. categorias mais especificas vencem o catch-all generico (Corpo de Bombeiros nao vira SEGURANCA_PUBLICA_EQUIVALENTE)", () => {
  const r = classificarDominioPolicial({ concurso: "Corpo de Bombeiros Militar — segurança pública estadual" });
  assert.equal(r.category, "CORPO_DE_BOMBEIROS");
});

// ==================== PROVENIENCIA DE DOMINIO (reusa classificarProveniencia) ====================

test("7. autoral Papiro sempre NOT_POLICE_REAL, mesmo com concurso policial", () => {
  const r = classificarQuestaoDominioPolicial(questaoFixture({ banca: "Papiro" }), {});
  assert.equal(r.proveniencia, "NOT_POLICE_REAL");
});

test("8. questao policial SEM manifesto curado -> POLICE_REAL_PROVENANCE_PARTIAL (nunca CONFIRMED so por regex)", () => {
  const r = classificarQuestaoDominioPolicial(questaoFixture(), {});
  assert.equal(r.proveniencia, "POLICE_REAL_PROVENANCE_PARTIAL");
});

test("9. questao policial COM manifesto curado (id no Set) -> POLICE_REAL_OFFICIAL_CONFIRMED", () => {
  const r = classificarQuestaoDominioPolicial(questaoFixture({ id: 42 }), { idsComProvenienciaConfirmada: new Set([42]) });
  assert.equal(r.proveniencia, "POLICE_REAL_OFFICIAL_CONFIRMED");
});

test("10. questao NAO policial nunca vira CONFIRMED mesmo se o id (por erro) estiver no manifesto curado", () => {
  const r = classificarQuestaoDominioPolicial(questaoFixture({ id: 42, concurso: "Profis (Pref Viamão)/Magistério/2022" }), { idsComProvenienciaConfirmada: new Set([42]) });
  assert.equal(r.proveniencia, "NOT_POLICE_REAL");
});

// ==================== RACIOCINIO / SUBTEMAS ====================

test("11. classificarPadraoRaciocinio deriva de classificarComando (reuso, nao redetecao)", () => {
  assert.equal(classificarPadraoRaciocinio("Assinale a alternativa que preenche corretamente as lacunas do trecho a seguir."), "SENTENCE_COMPLETION");
  assert.equal(classificarPadraoRaciocinio("Avalie as afirmações a seguir: I. Primeira. II. Segunda."), "MULTI_STATEMENT");
  assert.ok(REASONING_PATTERNS.includes("SENTENCE_COMPLETION"));
});

test("12. subtemas de concordancia verbal: HAVER, EXISTIR, FAZER e cadeia sao distinguidos", () => {
  assert.equal(classificarSubtemaConcordanciaVerbal("Há muitos problemas a resolver nesta situação."), "HAVER_EXISTENCIAL");
  assert.equal(classificarSubtemaConcordanciaVerbal("Existem muitos problemas nesta situação, segundo o texto."), "EXISTIR_PESSOAL");
  assert.equal(classificarSubtemaConcordanciaVerbal("Faz dez anos que ocorreu o episódio narrado no texto."), "FAZER_TEMPORAL");
  assert.equal(
    classificarSubtemaConcordanciaVerbal("Caso a palavra fosse trocada, passássemos o sujeito para o plural, quantas outras alterações seriam necessárias?"),
    "CONCORDANCIA_EM_CADEIA"
  );
  assert.ok(SUBTEMAS_CONCORDANCIA_VERBAL.includes("HAVER_EXISTENCIAL"));
});

// ==================== PERFIL AGREGADO: CANONICAL vs DISCOVERY ====================

function corpusMultiBancaFixture() {
  return [
    // 3 policiais confirmadas (Fundatec, Brigada Militar) — CANONICAL
    questaoFixture({ id: 101, ano: 2022 }),
    questaoFixture({ id: 102, ano: 2023 }),
    questaoFixture({ id: 103, ano: 2024, concurso: "Corpo de Bombeiros Militar RS - Soldado" }),
    // 1 policial de OUTRA banca, confirmada — prova que nao contamina/depende de banca fixa
    questaoFixture({ id: 104, banca: "FGV", concurso: "Delegado de Polícia Civil/2025", ano: 2025 }),
    // 2 policiais SEM manifesto curado -> discovery/partial
    questaoFixture({ id: 105, ano: 2021 }),
    questaoFixture({ id: 106, ano: 2020 }),
    // 1 autoral Papiro, policial no texto do concurso -> sempre NOT_POLICE_REAL
    questaoFixture({ id: 107, banca: "Papiro" }),
    // 1 REAL nao policial -> NOT_POLICE_REAL
    questaoFixture({ id: 108, concurso: "Profis (Pref Viamão)/Magistério/2022" }),
  ];
}

test("13. canonical e discovery sao separados; discovery NUNCA alimenta metricas canonicas", () => {
  const idsCurados = new Set([101, 102, 103, 104]);
  const { perfil } = construirPerfilDominioPolicial({
    subject: "Língua Portuguesa",
    materiaId: 6,
    questoesRaw: corpusMultiBancaFixture(),
    recentYearWindow: 6,
    anoAtual: 2026,
    idsComProvenienciaConfirmada: idsCurados,
  });
  assert.equal(perfil.canonical_sample.questions, 4);
  assert.equal(perfil.discovery_sample.partial, 2);
  assert.equal(perfil.incidence.total_not_police, 2); // Papiro + Profis
});

test("14. distinct banks e distinct exams sao contados corretamente a partir do canonical, incluindo banca diferente de Fundatec", () => {
  const idsCurados = new Set([101, 102, 103, 104]);
  const mapaProveniencia = new Map([
    [101, { examKey: "exame-A", bank: "Fundatec", contest: "BM RS Nivel III", role: "Soldado", year: 2022 }],
    [102, { examKey: "exame-A", bank: "Fundatec", contest: "BM RS Nivel III", role: "Soldado", year: 2022 }],
    [103, { examKey: "exame-B", bank: "Fundatec", contest: "CBM RS", role: "Soldado", year: 2024 }],
    [104, { examKey: "exame-C", bank: "FGV", contest: "Del Pol GO", role: "Delegado", year: 2025 }],
  ]);
  const { perfil } = construirPerfilDominioPolicial({
    subject: "Língua Portuguesa",
    materiaId: 6,
    questoesRaw: corpusMultiBancaFixture(),
    recentYearWindow: 6,
    anoAtual: 2026,
    idsComProvenienciaConfirmada: idsCurados,
    provenienciaConfirmadaPorId: mapaProveniencia,
  });
  assert.equal(perfil.canonical_sample.exams, 3, "3 examKeys distintos: A, B, C");
  assert.deepEqual(perfil.canonical_sample.banks, ["FGV", "Fundatec"]);
});

test("15. funciona sem banca-alvo fixa: corpus com banca=null/omitida ainda e classificado por dominio", () => {
  const corpus = [questaoFixture({ id: 201, banca: "Fundatec" }), questaoFixture({ id: 202, banca: undefined, concurso: "Guarda Municipal de Esteio/RS" })];
  const { classificadas } = construirPerfilDominioPolicial({
    subject: "Língua Portuguesa",
    materiaId: 6,
    questoesRaw: corpus,
    recentYearWindow: 6,
    anoAtual: 2026,
  });
  const q202 = classificadas.find((q) => q.id === 202);
  assert.equal(q202.categoria, "GUARDA_MUNICIPAL", "classificacao de dominio nao depende de banca estar presente");
});

test("16. incidencia por categoria e recencia (recent/historical) sao calculadas a partir do canonical", () => {
  const idsCurados = new Set([101, 102, 103, 104]);
  const { perfil } = construirPerfilDominioPolicial({
    subject: "Língua Portuguesa",
    materiaId: 6,
    questoesRaw: corpusMultiBancaFixture(),
    recentYearWindow: 6,
    anoAtual: 2026,
    idsComProvenienciaConfirmada: idsCurados,
  });
  assert.equal(perfil.incidence.by_category.POLICIA_MILITAR, 2); // 101, 102
  assert.equal(perfil.incidence.by_category.CORPO_DE_BOMBEIROS, 1); // 103
  assert.equal(perfil.incidence.by_category.POLICIA_CIVIL, 1); // 104
  assert.equal(perfil.canonical_sample.recent, 4, "todos dentro da janela de 6 anos de 2026 (2022-2025)");
  assert.equal(perfil.canonical_sample.historical, 0);
});

test("17. subtema de concordancia verbal so e contado quando assunto_id bate com o assunto-alvo resolvido", () => {
  const corpus = [
    questaoFixture({ id: 301, assunto_id: 14, enunciado: "Há muitos problemas a resolver, segundo o texto-base." }),
    questaoFixture({ id: 302, assunto_id: 999, enunciado: "Há muitos problemas a resolver, segundo o texto-base." }), // assunto diferente, nao deve contar
  ];
  const idsCurados = new Set([301, 302]);
  const { perfil } = construirPerfilDominioPolicial({
    subject: "Língua Portuguesa",
    materiaId: 6,
    questoesRaw: corpus,
    recentYearWindow: 6,
    anoAtual: 2026,
    idsComProvenienciaConfirmada: idsCurados,
    assuntoConcordanciaVerbalId: 14,
  });
  assert.equal(perfil.concordancia_verbal.canonical_questions, 1);
  assert.equal(perfil.concordancia_verbal.subtopics[0].subtopic, "HAVER_EXISTENCIAL");
});

// ==================== CONFIDENCE ====================

test("18. calcularConfiancaDominio e deterministico e exige diversidade real (nao so contagem)", () => {
  assert.equal(calcularConfiancaDominio({ confirmed: 30, distinctExams: 3, distinctYears: 3 }), "HIGH");
  assert.equal(calcularConfiancaDominio({ confirmed: 30, distinctExams: 1, distinctYears: 1 }), "LOW", "30 questoes de 1 unica prova/ano nao pode ser HIGH nem MEDIUM");
  assert.equal(calcularConfiancaDominio({ confirmed: 15, distinctExams: 2, distinctYears: 2 }), "MEDIUM");
  assert.equal(calcularConfiancaDominio({ confirmed: 14, distinctExams: 2, distinctYears: 2 }), "LOW");
  assert.equal(calcularConfiancaDominio({ confirmed: 0, distinctExams: 0, distinctYears: 0 }), "INSUFFICIENT");
  // mesma entrada -> mesma saida
  assert.equal(calcularConfiancaDominio({ confirmed: 24, distinctExams: 3, distinctYears: 3 }), calcularConfiancaDominio({ confirmed: 24, distinctExams: 3, distinctYears: 3 }));
});

// ==================== FIDELIDADE (Q1/Q2 style, generico) ====================

test("19. avaliarFidelidadeDominioPolicial: amostra canonica pequena (<3) -> INSUFFICIENT_EVIDENCE, nunca MATCH por inercia", () => {
  const perfilPequeno = { confidence: "MEDIUM", concordancia_verbal: { canonical_questions: 1, subtopics: [{ subtopic: "CONCORDANCIA_EM_CADEIA", count: 1, percent: 100 }] } };
  const r = avaliarFidelidadeDominioPolicial({ enunciado: "Há muitos motivos para isso." }, perfilPequeno);
  assert.equal(r.police_domain_status, STATUS_FIDELIDADE_DOMINIO.POLICE_DOMAIN_INSUFFICIENT_EVIDENCE);
  assert.ok(r.reason_codes.includes("CONCORDANCIA_VERBAL_CANONICAL_SAMPLE_TOO_SMALL"));
});

test("20. avaliarFidelidadeDominioPolicial: amostra suficiente + subtema presente -> MATCH; subtema ausente -> REVIEW", () => {
  const perfil = {
    confidence: "MEDIUM",
    concordancia_verbal: {
      canonical_questions: 5,
      subtopics: [
        { subtopic: "HAVER_EXISTENCIAL", count: 3, percent: 60 },
        { subtopic: "CONCORDANCIA_EM_CADEIA", count: 2, percent: 40 },
      ],
    },
  };
  const comSuporte = avaliarFidelidadeDominioPolicial({ enunciado: "Há muitos problemas a resolver, segundo o texto." }, perfil);
  assert.equal(comSuporte.police_domain_status, STATUS_FIDELIDADE_DOMINIO.POLICE_DOMAIN_MATCH);

  const semSuporte = avaliarFidelidadeDominioPolicial({ enunciado: "Existem muitos problemas a resolver, segundo o texto." }, perfil);
  assert.equal(semSuporte.police_domain_status, STATUS_FIDELIDADE_DOMINIO.POLICE_DOMAIN_REVIEW);
  assert.ok(semSuporte.reason_codes.includes("SUBTOPIC_UNSUPPORTED_BY_CANONICAL_POLICE_CORPUS"));
});

test("21. avaliarFidelidadeDominioPolicial: domain confidence LOW/INSUFFICIENT/ausente -> INSUFFICIENT_EVIDENCE e nao muta a questao", () => {
  const questao = { enunciado: "Há muitos motivos para isso." };
  const antes = JSON.stringify(questao);
  assert.equal(avaliarFidelidadeDominioPolicial(questao, null).police_domain_status, STATUS_FIDELIDADE_DOMINIO.POLICE_DOMAIN_INSUFFICIENT_EVIDENCE);
  assert.equal(avaliarFidelidadeDominioPolicial(questao, { confidence: "LOW" }).police_domain_status, STATUS_FIDELIDADE_DOMINIO.POLICE_DOMAIN_INSUFFICIENT_EVIDENCE);
  assert.equal(JSON.stringify(questao), antes, "avaliarFidelidadeDominioPolicial nao pode alterar a questao recebida");
});

// ==================== HASH / PERSISTENCIA ====================

test("22. hash do perfil de dominio e deterministico (mesmo conteudo -> mesmo hash) e muda quando o conteudo muda", () => {
  const idsCurados = new Set([101, 102, 103, 104]);
  const perfilA = construirPerfilDominioPolicial({
    subject: "Língua Portuguesa", materiaId: 6, questoesRaw: corpusMultiBancaFixture(), recentYearWindow: 6, anoAtual: 2026, idsComProvenienciaConfirmada: idsCurados,
  }).perfil;
  // remove o campo nao deterministico antes de comparar (generated_at muda a cada chamada)
  const semTimestamp = (p) => { const c = { ...p }; delete c.generated_at; return c; };
  const hashA1 = calcularHashPerfilBanca(semTimestamp(perfilA));
  const hashA2 = calcularHashPerfilBanca(semTimestamp(perfilA));
  assert.equal(hashA1, hashA2);

  const idsCuradosMaior = new Set([101, 102, 103, 104, 105]);
  const perfilB = construirPerfilDominioPolicial({
    subject: "Língua Portuguesa", materiaId: 6, questoesRaw: corpusMultiBancaFixture(), recentYearWindow: 6, anoAtual: 2026, idsComProvenienciaConfirmada: idsCuradosMaior,
  }).perfil;
  const hashB = calcularHashPerfilBanca(semTimestamp(perfilB));
  assert.notEqual(hashA1, hashB, "hash muda quando a composicao do corpus canonico muda");
});

test("23. perfil de dominio NUNCA persiste texto integral de enunciado REAL — so metadados/estatisticas/classificacoes", () => {
  const idsCurados = new Set([101, 102, 103, 104]);
  const corpus = corpusMultiBancaFixture();
  const { perfil } = construirPerfilDominioPolicial({
    subject: "Língua Portuguesa", materiaId: 6, questoesRaw: corpus, recentYearWindow: 6, anoAtual: 2026, idsComProvenienciaConfirmada: idsCurados,
  });
  const serializado = JSON.stringify(perfil);
  for (const q of corpus) {
    assert.equal(serializado.includes(q.enunciado), false, `perfil de dominio nao pode conter o enunciado integral "${q.enunciado}"`);
  }
});
