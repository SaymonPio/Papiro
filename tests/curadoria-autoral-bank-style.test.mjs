// Fase 2C.3 + 2C.3.1 — testes do perfil de estilo de banca evidence-based,
// com o gate de proveniencia estrito (REAL_OFFICIAL_CONFIRMED /
// REAL_PROVENANCE_PARTIAL / REAL_UNCONFIRMED / NOT_REAL). Todas as
// fixtures de enunciado/alternativa sao SINTETICAS, escritas por mim para
// exercitar os padroes (nunca texto integral de prova REAL copiado — isso
// seria exatamente o que a Secao 9 do mandato probe persistir em artefato
// versionavel). Nenhum teste faz rede real.

import assert from "node:assert/strict";
import test from "node:test";
import {
  classificarComando,
  detectarTextoBase,
  detectarEstrutura,
  calcularComprimentos,
  extrairFeaturesQuestao,
} from "../scripts/curadoria-autoral/lib/bank-style-features.mjs";
import {
  normalizarBanca,
  pareceConcursoPolicialOuSegurancaPublica,
  temEvidenciaProvaOficial,
  temEvidenciaGabaritoOficial,
  classificarProveniencia,
  classificarTier,
  calcularConfianca,
  construirPerfilBanca,
  perfilarCorpus,
} from "../scripts/curadoria-autoral/lib/bank-style-profiler.mjs";
import { STATUS_FIDELIDADE_ESTILO, avaliarFidelidadeEstilo } from "../scripts/curadoria-autoral/lib/bank-style-fidelity.mjs";
import { calcularFingerprintAuditoria, calcularHashPerfilBanca } from "../scripts/curadoria-autoral/lib/audit-state.mjs";
import { montarPromptAuditorBlind, montarPromptAuditorCritic, sanitizarQuestaoParaBlindSolver } from "../scripts/curadoria-autoral/lib/openai-audit-provider.mjs";

// fonte no padrao "citacao direta" — a PROPRIA banca citando exame nomeado
// + numero de questao — a UNICA fonte que sozinha satisfaz as duas pernas
// de evidencia (prova oficial + gabarito oficial) simultaneamente.
function questaoRawFixture(overrides = {}) {
  return {
    id: 1,
    banca: "Fundatec",
    concurso: "Del Pol (PC RS)/PC RS/2025",
    ano: 2025,
    fonte: "Fundatec — Concurso teste — Questão 01",
    gerada_por_ia: false,
    ativa: true,
    materia_id: 6,
    assunto_id: 10,
    enunciado: "Assinale a alternativa correta quanto à concordância verbal na frase de teste.",
    alternativas: [{ texto: "a" }, { texto: "b" }, { texto: "c" }, { texto: "d" }, { texto: "e" }],
    ...overrides,
  };
}

// ==================== EVIDENCIA (duas pernas independentes) ====================

test("1a. temEvidenciaProvaOficial: citacao direta da banca OU agregador citando a banca contam; fonte generica ou ausente nao", () => {
  assert.equal(temEvidenciaProvaOficial(questaoRawFixture(), "Fundatec"), true);
  assert.equal(temEvidenciaProvaOficial(questaoRawFixture({ fonte: "TEC Concursos — questão 123 — FUNDATEC — posição 5 no conjunto de 1.000 questões" }), "Fundatec"), true);
  assert.equal(temEvidenciaProvaOficial(questaoRawFixture({ fonte: "Questão de prova real, ano 2025" }), "Fundatec"), false);
  assert.equal(temEvidenciaProvaOficial(questaoRawFixture({ fonte: null }), "Fundatec"), false);
});

test("1b. temEvidenciaGabaritoOficial: citacao direta da banca OU mencao explicita a gabarito oficial/definitivo contam; agregador terceiro sozinho NAO conta", () => {
  assert.equal(temEvidenciaGabaritoOficial(questaoRawFixture(), "Fundatec"), true);
  assert.equal(temEvidenciaGabaritoOficial(questaoRawFixture({ fonte: "Gabarito oficial definitivo confirmado pela banca" }), "Fundatec"), true);
  assert.equal(
    temEvidenciaGabaritoOficial(questaoRawFixture({ fonte: "TEC Concursos — questão 123 — FUNDATEC — posição 5 no conjunto de 1.000 questões" }), "Fundatec"),
    false,
    "agregador terceiro cita a prova, mas NAO confirma o gabarito oficial por si só"
  );
});

// ==================== PROVENIENCIA ESTRITA (Secao 3) ====================

test("2. classificarProveniencia: banca+concurso+ano+fonte GENERICA (sozinhos) NAO bastam para OFFICIAL_CONFIRMED", () => {
  const generica = classificarProveniencia(questaoRawFixture({ fonte: "Questão de prova real, ano 2025" }), { bancaAlvoNormalizada: "fundatec" });
  assert.notEqual(generica, "REAL_OFFICIAL_CONFIRMED");
  assert.equal(generica, "REAL_PROVENANCE_PARTIAL");
});

test("3. classificarProveniencia: prova oficial SEM gabarito oficial (agregador terceiro) -> REAL_PROVENANCE_PARTIAL", () => {
  const resultado = classificarProveniencia(
    questaoRawFixture({ fonte: "TEC Concursos — questão 123 — FUNDATEC — posição 5 no conjunto de 1.000 questões" }),
    { bancaAlvoNormalizada: "fundatec" }
  );
  assert.equal(resultado, "REAL_PROVENANCE_PARTIAL");
});

test("4. classificarProveniencia: gabarito oficial SEM prova oficial nomeada -> REAL_PROVENANCE_PARTIAL", () => {
  const resultado = classificarProveniencia(questaoRawFixture({ fonte: "Gabarito oficial definitivo confirmado pela banca" }), { bancaAlvoNormalizada: "fundatec" });
  assert.equal(resultado, "REAL_PROVENANCE_PARTIAL");
});

test("5. classificarProveniencia (Fase 2C.3.2): citacao direta SOZINHA (sem manifesto curado) NAO e mais suficiente -> REAL_PROVENANCE_PARTIAL, nunca CONFIRMED", () => {
  assert.equal(classificarProveniencia(questaoRawFixture(), { bancaAlvoNormalizada: "fundatec" }), "REAL_PROVENANCE_PARTIAL");
});

test("5b. classificarProveniencia: com manifesto curado (idsComProvenienciaConfirmada) cobrindo o id -> REAL_OFFICIAL_CONFIRMED", () => {
  const idsCurados = new Set([1]);
  assert.equal(classificarProveniencia(questaoRawFixture({ id: 1 }), { bancaAlvoNormalizada: "fundatec", idsComProvenienciaConfirmada: idsCurados }), "REAL_OFFICIAL_CONFIRMED");
  // Mesmo texto de fonte, id DIFERENTE (fora do manifesto curado) continua so PARTIAL.
  assert.equal(classificarProveniencia(questaoRawFixture({ id: 2 }), { bancaAlvoNormalizada: "fundatec", idsComProvenienciaConfirmada: idsCurados }), "REAL_PROVENANCE_PARTIAL");
});

test("6. classificarProveniencia: nenhuma perna de evidencia nem fonte nenhuma -> REAL_UNCONFIRMED", () => {
  const resultado = classificarProveniencia(questaoRawFixture({ fonte: null, concurso: null, ano: null }), { bancaAlvoNormalizada: "fundatec" });
  assert.equal(resultado, "REAL_UNCONFIRMED");
});

test("7. classificarProveniencia: banca Papiro/autoral SEMPRE NOT_REAL, mesmo com citacao direta perfeita", () => {
  for (const bancaAutoral of ["Papiro", "PAPIRO", "Papiro - estilo Fundatec", "Papiro — estilo Fundatec"]) {
    const resultado = classificarProveniencia(questaoRawFixture({ banca: bancaAutoral }), { bancaAlvoNormalizada: "fundatec" });
    assert.equal(resultado, "NOT_REAL", `banca "${bancaAutoral}" deveria ser NOT_REAL`);
  }
  assert.equal(classificarProveniencia(questaoRawFixture({ gerada_por_ia: true }), { bancaAlvoNormalizada: "fundatec" }), "NOT_REAL");
});

test("8. normalizarBanca: casing/espaco nao importam para reconhecer a banca-alvo", () => {
  assert.equal(normalizarBanca("Fundatec"), normalizarBanca("FUNDATEC"));
  assert.equal(normalizarBanca("  Fundatec  "), "fundatec");
  const idsCurados = new Set([1]);
  assert.equal(
    classificarProveniencia(questaoRawFixture({ id: 1, banca: "FUNDATEC" }), { bancaAlvoNormalizada: normalizarBanca("Fundatec"), bancaAlvoOriginal: "FUNDATEC", idsComProvenienciaConfirmada: idsCurados }),
    "REAL_OFFICIAL_CONFIRMED"
  );
});

// ==================== HARDENING DE PROVENIENCIA (Fase 2C.3.2) ====================
// Regex/padrao de texto (SOURCE_TEXT_PATTERN) NUNCA prova proveniencia
// (PROVENANCE_EVIDENCE) sozinho — so o manifesto curado por humano prova.

test("8b. agregador + banca (sinal de prova) sozinho -> NAO CONFIRMED", () => {
  const resultado = classificarProveniencia(
    questaoRawFixture({ fonte: "TEC Concursos — questão 123 — FUNDATEC — posição 5 no conjunto de 1.000 questões" }),
    { bancaAlvoNormalizada: "fundatec" }
  );
  assert.notEqual(resultado, "REAL_OFFICIAL_CONFIRMED");
  assert.equal(resultado, "REAL_PROVENANCE_PARTIAL");
});

test("8c. agregador + expressao explicita 'gabarito oficial' (as DUAS pernas de texto simultaneas) -> AINDA ASSIM NAO CONFIRMED sem manifesto curado", () => {
  const resultado = classificarProveniencia(questaoRawFixture({ fonte: "TEC Concursos — questão Fundatec — gabarito oficial" }), { bancaAlvoNormalizada: "fundatec" });
  assert.notEqual(resultado, "REAL_OFFICIAL_CONFIRMED", "regex batendo nas duas pernas de texto simultaneamente NAO e prova documental (Secao 5 do mandato 2C.3.2)");
  assert.equal(resultado, "REAL_PROVENANCE_PARTIAL");
});

test("8d. texto livre 'Fundatec — concurso X — Questão 10' (citacao direta bem formada) sem manifesto curado -> NAO promovido automaticamente a CONFIRMED", () => {
  const resultado = classificarProveniencia(questaoRawFixture({ fonte: "Fundatec — concurso X — Questão 10" }), { bancaAlvoNormalizada: "fundatec" });
  assert.notEqual(resultado, "REAL_OFFICIAL_CONFIRMED");
  assert.equal(resultado, "REAL_PROVENANCE_PARTIAL");
});

test("8e. evidencia canonica validada de prova + gabarito (manifesto curado cobre o id) -> CONFIRMED", () => {
  const idsCurados = new Set([42]);
  const resultado = classificarProveniencia(questaoRawFixture({ id: 42, fonte: "Fundatec — concurso X — Questão 10" }), { bancaAlvoNormalizada: "fundatec", idsComProvenienciaConfirmada: idsCurados });
  assert.equal(resultado, "REAL_OFFICIAL_CONFIRMED");
});

test("8f. autoral Papiro continua NOT_REAL mesmo se o id estivesse (hipoteticamente) num manifesto curado", () => {
  const idsCurados = new Set([1]);
  const resultado = classificarProveniencia(questaoRawFixture({ id: 1, banca: "Papiro" }), { bancaAlvoNormalizada: "fundatec", idsComProvenienciaConfirmada: idsCurados });
  assert.equal(resultado, "NOT_REAL");
});

test("8g. somente uma perna de evidencia de texto (sem manifesto curado) -> PARTIAL, nunca CONFIRMED nem UNCONFIRMED", () => {
  const soExame = classificarProveniencia(
    questaoRawFixture({ fonte: "TEC Concursos — questão 999 — FUNDATEC — posição 1 no conjunto de 1.000 questões" }),
    { bancaAlvoNormalizada: "fundatec" }
  );
  assert.equal(soExame, "REAL_PROVENANCE_PARTIAL");
  const soGabarito = classificarProveniencia(questaoRawFixture({ fonte: "Gabarito oficial definitivo, sem citação de exame" }), { bancaAlvoNormalizada: "fundatec" });
  assert.equal(soGabarito, "REAL_PROVENANCE_PARTIAL");
});

// ==================== TIERS ====================

test("9. classificarTier: policial+recente=TIER_1, policial+antigo=TIER_2, nao-policial=TIER_3 (nunca misturados)", () => {
  const params = { anoAtual: 2026, recentYearWindow: 6 };
  assert.equal(classificarTier(questaoRawFixture({ concurso: "Del Pol (PC RS)/2025", ano: 2025 }), params), "TIER_1");
  assert.equal(classificarTier(questaoRawFixture({ concurso: "Del Pol (PC RS)/2010", ano: 2010 }), params), "TIER_2");
  assert.equal(classificarTier(questaoRawFixture({ concurso: "Profis (Pref Viamão)/Magistério/2022", ano: 2022 }), params), "TIER_3");
});

test("9b. pareceConcursoPolicialOuSegurancaPublica reconhece os padroes reais observados (Brigada Militar, Guarda Municipal, IGP, Polícia Penal)", () => {
  for (const concurso of ["Brigada Militar RS - Soldado", "GM (Pref Gravataí)/2025", "Per Crim (IGP RS)/2025", "Pol Pen (PP RS)/2022", "GCM (Uruguaiana)/2023"]) {
    assert.equal(pareceConcursoPolicialOuSegurancaPublica(concurso), true, `"${concurso}" deveria ser reconhecido como policial/seguranca publica`);
  }
  assert.equal(pareceConcursoPolicialOuSegurancaPublica("Profis (Pref Viamão)/Magistério para Educação Infantil"), false);
});

// ==================== FEATURES ====================

test("10. classificarComando: PREENCHIMENTO_LACUNAS detectado", () => {
  assert.equal(classificarComando("Assinale a alternativa que preenche corretamente as lacunas do trecho a seguir."), "PREENCHIMENTO_LACUNAS");
});

test("11. classificarComando: ASSINALE_INCORRETA (correta/incorreta + EXCETO) detectado", () => {
  assert.equal(classificarComando("Assinale a alternativa INCORRETA quanto à regência verbal."), "ASSINALE_INCORRETA");
  assert.equal(classificarComando("Todas as alternativas estão corretas, EXCETO:"), "ASSINALE_INCORRETA");
});

test("12. classificarComando: itens I/II/III detectados (ANALISE_AFIRMATIVAS quando fala em afirmações — singular OU plural; ITENS_I_II_III caso contrário)", () => {
  assert.equal(classificarComando("Avalie as afirmações a seguir: I. Primeira. II. Segunda. III. Terceira."), "ANALISE_AFIRMATIVAS");
  assert.equal(classificarComando("Avalie a afirmação a seguir: I. Primeira. II. Segunda."), "ANALISE_AFIRMATIVAS");
  assert.equal(classificarComando("Considere os itens: I. Primeiro item. II. Segundo item."), "ITENS_I_II_III");
});

test("13. detectarTextoBase: marcador de linha [NN] e enunciado longo detectados; item autocontido curto nao", () => {
  const comMarcador = detectarTextoBase("[01] Primeira linha do texto-base.\n[02] Segunda linha do texto-base.");
  assert.equal(comMarcador.usa_texto_base, true);
  assert.equal(comMarcador.autocontida, false);

  const curto = detectarTextoBase("Assinale a alternativa correta.");
  assert.equal(curto.usa_texto_base, false);
  assert.equal(curto.autocontida, true);
});

test("14. calcularComprimentos / extrairFeaturesQuestao: conta alternativas corretamente", () => {
  const features = extrairFeaturesQuestao({ enunciado: "Teste.", alternativas: [{ texto: "a" }, { texto: "bb" }, { texto: "ccc" }, { texto: "d" }, { texto: "e" }] });
  assert.equal(features.n_alternativas, 5);
  assert.equal(features.comprimentos.alternativa_chars.length, 5);
});

test("15. calcularConfianca: limiares HIGH>=30, MEDIUM 15-29, LOW 1-14, INSUFFICIENT=0", () => {
  assert.equal(calcularConfianca(30), "HIGH");
  assert.equal(calcularConfianca(29), "MEDIUM");
  assert.equal(calcularConfianca(15), "MEDIUM");
  assert.equal(calcularConfianca(14), "LOW");
  assert.equal(calcularConfianca(1), "LOW");
  assert.equal(calcularConfianca(0), "INSUFFICIENT");
});

// ==================== PERFIL AGREGADO ====================

function corpusSinteticoFixture() {
  const base = questaoRawFixture();
  return [
    { ...base, id: 1, enunciado: "Assinale a alternativa correta quanto à concordância." },
    { ...base, id: 2, enunciado: "Assinale a alternativa que preenche corretamente as lacunas: ___." },
    { ...base, id: 3, enunciado: "Assinale a alternativa que preenche corretamente as lacunas: ___." },
    { ...base, id: 4, banca: "Papiro", enunciado: "Questão autoral que NAO pode contaminar o perfil." },
    { ...base, id: 5, fonte: "TEC Concursos — questão 999 — FUNDATEC — posição 1 no conjunto de 1.000 questões", enunciado: "Questão com evidência parcial (agregador)." },
    { ...base, id: 6, ano: null, fonte: null, concurso: null, enunciado: "Questão sem metadado suficiente." },
  ];
}

// Corpus maior, so para os testes que dependem de confidence >= MEDIUM/HIGH
// (avaliarFidelidadeEstilo e montarBlocoEstiloBanca so usam o perfil de
// verdade quando confidence != LOW/INSUFFICIENT). Fase 2C.3.2: o texto de
// `fonte` (citacao direta) NAO basta mais sozinho — os testes que precisam
// de CONFIRMED de verdade devem passar idsComProvenienciaConfirmada com os
// ids retornados aqui, simulando um manifesto curado por humano.
function corpusGrandeFixture({ nLacunas = 20, nCorreta = 15 } = {}) {
  const base = questaoRawFixture();
  const lista = [];
  let id = 1000;
  for (let i = 0; i < nLacunas; i++) {
    lista.push({ ...base, id: id++, enunciado: `Assinale a alternativa que preenche corretamente as lacunas do item sintético ${i}: ___.` });
  }
  for (let i = 0; i < nCorreta; i++) {
    lista.push({ ...base, id: id++, enunciado: `Assinale a alternativa correta quanto à regência verbal no item sintético ${i}.` });
  }
  return lista;
}

function idsCuradosDoCorpus(corpus) {
  return new Set(corpus.map((q) => q.id));
}

test("16. construirPerfilBanca/perfilarCorpus: SO REAL_OFFICIAL_CONFIRMED (com manifesto curado) entra nas metricas principais (partial/unconfirmed/autoral ficam fora)", () => {
  // Ids 1,2,3 tem o manifesto curado (simula um humano que ja verificou
  // prova+gabarito oficiais para essas 3 questoes especificas); id 5 tem
  // so o padrao de texto do agregador, SEM curadoria -> PARTIAL, mesmo
  // tendo um sinal textual real.
  const idsComProvenienciaConfirmada = new Set([1, 2, 3]);
  const { perfil, questoesClassificadas } = perfilarCorpus({
    bank: "Fundatec",
    subject: "Língua Portuguesa",
    bancaAlvoNormalizada: "fundatec",
    questoesRaw: corpusSinteticoFixture(),
    recentYearWindow: 6,
    anoAtual: 2026,
    idsComProvenienciaConfirmada,
  });
  assert.equal(perfil.sample.real_official_confirmed, 3); // ids 1,2,3 (curados)
  assert.equal(perfil.sample.real_provenance_partial, 1); // id 5 (agregador, sem curadoria)
  assert.equal(perfil.sample.real_unconfirmed, 1); // id 6 (nada)
  assert.equal(questoesClassificadas.find((q) => q.id === 4).proveniencia, "NOT_REAL");
  const totalFormatos = Object.values(perfil.format_distribution).reduce((s, v) => s + v, 0);
  assert.equal(totalFormatos, 3, "format_distribution so pode contar as 3 REAL_OFFICIAL_CONFIRMED");
});

test("16b. perfilarCorpus SEM manifesto curado algum: mesmo com todas as fontes 'parecendo' oficiais, real_official_confirmed=0", () => {
  const { perfil } = perfilarCorpus({
    bank: "Fundatec",
    subject: "Língua Portuguesa",
    bancaAlvoNormalizada: "fundatec",
    questoesRaw: corpusSinteticoFixture(),
    recentYearWindow: 6,
    anoAtual: 2026,
    // idsComProvenienciaConfirmada omitido -> default Set vazio.
  });
  assert.equal(perfil.sample.real_official_confirmed, 0);
  assert.equal(perfil.confidence, "INSUFFICIENT");
});

test("17. percentis/comando/alternativas NUNCA incluem PARTIAL/UNCONFIRMED — mesmo perfil com/sem eles produz metricas principais identicas", () => {
  const idsComProvenienciaConfirmada = new Set([1, 2, 3]);
  const comApenasConfirmadas = perfilarCorpus({
    bank: "Fundatec", subject: "Língua Portuguesa", bancaAlvoNormalizada: "fundatec",
    questoesRaw: corpusSinteticoFixture().filter((q) => [1, 2, 3].includes(q.id)),
    recentYearWindow: 6, anoAtual: 2026, idsComProvenienciaConfirmada,
  }).perfil;
  const comTodas = perfilarCorpus({
    bank: "Fundatec", subject: "Língua Portuguesa", bancaAlvoNormalizada: "fundatec",
    questoesRaw: corpusSinteticoFixture(),
    recentYearWindow: 6, anoAtual: 2026, idsComProvenienciaConfirmada,
  }).perfil;
  assert.equal(comTodas.sample.real_official_confirmed, 3, "sanity check — precisa haver CONFIRMED de fato para este teste ser significativo");
  assert.deepEqual(comApenasConfirmadas.format_distribution, comTodas.format_distribution);
  assert.deepEqual(comApenasConfirmadas.length_profile, comTodas.length_profile);
  assert.deepEqual(comApenasConfirmadas.alternative_count_distribution, comTodas.alternative_count_distribution);
  assert.equal(comApenasConfirmadas.confidence, comTodas.confidence, "confidence depende so do numero de CONFIRMED, nunca do total bruto");
});

test("18. perfil NUNCA persiste texto integral de enunciado/alternativa REAL — so metadados/estatisticas", () => {
  const corpus = corpusSinteticoFixture();
  const { perfil } = perfilarCorpus({
    bank: "Fundatec",
    subject: "Língua Portuguesa",
    bancaAlvoNormalizada: "fundatec",
    questoesRaw: corpus,
    recentYearWindow: 6,
    anoAtual: 2026,
  });
  const serializado = JSON.stringify(perfil);
  for (const q of corpus) {
    assert.equal(serializado.includes(q.enunciado), false, `perfil nao pode conter o enunciado integral "${q.enunciado}"`);
  }
});

// ==================== FIDELIDADE DE ESTILO ====================

test("19. avaliarFidelidadeEstilo e determinístico (mesma entrada -> mesma saida) e nao muta a questao gerada", () => {
  const corpusGrande = corpusGrandeFixture();
  const { perfil } = perfilarCorpus({
    bank: "Fundatec",
    subject: "Língua Portuguesa",
    bancaAlvoNormalizada: "fundatec",
    questoesRaw: corpusGrande,
    recentYearWindow: 6,
    anoAtual: 2026,
    idsComProvenienciaConfirmada: idsCuradosDoCorpus(corpusGrande),
  });
  const questaoGerada = { enunciado: "Assinale a alternativa que preenche corretamente as lacunas: ___.", alternativas: [{ texto: "a" }, { texto: "b" }, { texto: "c" }, { texto: "d" }, { texto: "e" }] };
  const antes = JSON.stringify(questaoGerada);
  const r1 = avaliarFidelidadeEstilo(questaoGerada, perfil);
  const r2 = avaliarFidelidadeEstilo(questaoGerada, perfil);
  assert.deepEqual(r1, r2);
  assert.equal(JSON.stringify(questaoGerada), antes, "avaliarFidelidadeEstilo nao pode alterar a questao recebida");
});

test("20. avaliarFidelidadeEstilo: formato SEM nenhum suporte no corpus -> BANK_STYLE_MISMATCH; perfil ausente/LOW/INSUFFICIENT -> BANK_STYLE_INSUFFICIENT_EVIDENCE", () => {
  const corpusGrande = corpusGrandeFixture();
  const { perfil } = perfilarCorpus({
    bank: "Fundatec",
    subject: "Língua Portuguesa",
    bancaAlvoNormalizada: "fundatec",
    questoesRaw: corpusGrande,
    recentYearWindow: 6,
    anoAtual: 2026,
    idsComProvenienciaConfirmada: idsCuradosDoCorpus(corpusGrande),
  });
  const questaoReescrita = { enunciado: "Assinale a alternativa que apresenta uma reescrita adequada do trecho a seguir.", alternativas: [{ texto: "a" }, { texto: "b" }, { texto: "c" }, { texto: "d" }, { texto: "e" }] };
  const resultado = avaliarFidelidadeEstilo(questaoReescrita, perfil);
  assert.equal(resultado.style_fidelity_status, STATUS_FIDELIDADE_ESTILO.BANK_STYLE_MISMATCH);
  assert.ok(resultado.reason_codes.includes("COMMAND_FORMAT_UNSUPPORTED_BY_CORPUS"));

  const semPerfil = avaliarFidelidadeEstilo(questaoReescrita, null);
  assert.equal(semPerfil.style_fidelity_status, STATUS_FIDELIDADE_ESTILO.BANK_STYLE_INSUFFICIENT_EVIDENCE);

  // Perfil com 0 CONFIRMED (so PARTIAL/UNCONFIRMED) -> INSUFFICIENT, nunca MATCH por inércia.
  const perfilSoParcial = perfilarCorpus({
    bank: "Fundatec", subject: "Língua Portuguesa", bancaAlvoNormalizada: "fundatec",
    questoesRaw: [{ ...questaoRawFixture(), fonte: "TEC Concursos — questão 1 — FUNDATEC — posição 1 no conjunto de 1.000 questões" }],
    recentYearWindow: 6, anoAtual: 2026,
  }).perfil;
  assert.equal(perfilSoParcial.confidence, "INSUFFICIENT");
  const comSoParcial = avaliarFidelidadeEstilo(questaoReescrita, perfilSoParcial);
  assert.equal(comSoParcial.style_fidelity_status, STATUS_FIDELIDADE_ESTILO.BANK_STYLE_INSUFFICIENT_EVIDENCE);
});

test("21. avaliarFidelidadeEstilo: formato bem representado no corpus CONFIRMADO -> BANK_STYLE_MATCH", () => {
  const corpusGrande = corpusGrandeFixture();
  const { perfil } = perfilarCorpus({
    bank: "Fundatec",
    subject: "Língua Portuguesa",
    bancaAlvoNormalizada: "fundatec",
    questoesRaw: corpusGrande,
    recentYearWindow: 6,
    anoAtual: 2026,
    idsComProvenienciaConfirmada: idsCuradosDoCorpus(corpusGrande),
  });
  const questaoLacunas = { enunciado: "Assinale a alternativa que preenche corretamente as lacunas do item sintético 5: ___.", alternativas: [{ texto: "a" }, { texto: "b" }, { texto: "c" }, { texto: "d" }, { texto: "e" }] };
  const resultado = avaliarFidelidadeEstilo(questaoLacunas, perfil);
  assert.equal(resultado.style_fidelity_status, STATUS_FIDELIDADE_ESTILO.BANK_STYLE_MATCH, JSON.stringify(resultado));
});

// ==================== FINGERPRINT + INTEGRACAO COM AUDITORIA ====================

function fingerprintBaseArgs(bankStyleProfileHash) {
  return {
    questoesGeradasRaw: "{}",
    runId: "run-teste",
    questionKeys: ["run-teste:q01", "run-teste:q02"],
    model: "gpt-5.6-sol",
    blindPromptVersion: "v1",
    criticPromptVersion: "v1",
    escopo: "escopo",
    fontesValidadas: [],
    bankStyleProfileHash,
  };
}

test("22. bank_style_profile_hash entra no audit_input_fingerprint: ausencia (null) x presenca ja mudam o fingerprint", () => {
  const semPerfil = calcularFingerprintAuditoria(fingerprintBaseArgs(null));
  const comPerfil = calcularFingerprintAuditoria(fingerprintBaseArgs("hash-abc"));
  assert.notEqual(semPerfil, comPerfil);
});

test("23. profile hash muda quando a COMPOSICAO do corpus CONFIRMADO muda (mais questoes com manifesto curado) — e isso muda o audit fingerprint", () => {
  const corpusMenor = corpusGrandeFixture({ nLacunas: 20, nCorreta: 15 });
  const corpusMaior = corpusGrandeFixture({ nLacunas: 20, nCorreta: 16 }); // 1 questao real a mais
  const perfilMenor = perfilarCorpus({ bank: "Fundatec", subject: "Língua Portuguesa", bancaAlvoNormalizada: "fundatec", questoesRaw: corpusMenor, recentYearWindow: 6, anoAtual: 2026, idsComProvenienciaConfirmada: idsCuradosDoCorpus(corpusMenor) }).perfil;
  const perfilMaior = perfilarCorpus({ bank: "Fundatec", subject: "Língua Portuguesa", bancaAlvoNormalizada: "fundatec", questoesRaw: corpusMaior, recentYearWindow: 6, anoAtual: 2026, idsComProvenienciaConfirmada: idsCuradosDoCorpus(corpusMaior) }).perfil;
  assert.equal(perfilMenor.sample.real_official_confirmed, 35);
  assert.equal(perfilMaior.sample.real_official_confirmed, 36);

  const hashMenor = calcularHashPerfilBanca(perfilMenor);
  const hashMaior = calcularHashPerfilBanca(perfilMaior);
  assert.notEqual(hashMenor, hashMaior);
  assert.notEqual(calcularFingerprintAuditoria(fingerprintBaseArgs(hashMenor)), calcularFingerprintAuditoria(fingerprintBaseArgs(hashMaior)));
});

test("24. Blind Solver NUNCA recebe bank_style_profile — assinatura nao aceita e prompt nunca menciona estatisticas de banca", () => {
  assert.equal(montarPromptAuditorBlind.length, 2, "montarPromptAuditorBlind so pode aceitar (payload, questoesSanitizadas) — sem parametro de perfil");
  const payload = {
    course: { name: "Curso Teste", slug: "curso-teste" },
    bank: { name: "Fundatec" },
    subject: { name: "Língua Portuguesa" },
    unit: { title: "Concordância verbal" },
    pedagogical_context: { scope: "escopo de teste" },
    source: { validated_source_keys: [] },
  };
  const questoes = [sanitizarQuestaoParaBlindSolver({ enunciado: "x", alternativas: [{ letra: "A", texto: "a" }], dificuldade: "media" }, 1), sanitizarQuestaoParaBlindSolver({ enunciado: "y", alternativas: [{ letra: "A", texto: "a" }], dificuldade: "media" }, 2)];
  const prompt = montarPromptAuditorBlind(payload, questoes);
  for (const termo of ["real_official_confirmed", "command_patterns", "bank_style_profile", "PERFIL DE ESTILO"]) {
    assert.equal(prompt.includes(termo), false, `prompt do blind solver nao pode mencionar "${termo}"`);
  }
});

test("25. Full Critic RECEBE o profile CONFIRMADO quando fornecido — prompt contem evidencia real, nunca so a instrucao generica antiga", () => {
  const corpusGrande = corpusGrandeFixture();
  const { perfil } = perfilarCorpus({
    bank: "Fundatec",
    subject: "Língua Portuguesa",
    bancaAlvoNormalizada: "fundatec",
    questoesRaw: corpusGrande,
    recentYearWindow: 6,
    anoAtual: 2026,
    idsComProvenienciaConfirmada: idsCuradosDoCorpus(corpusGrande),
  });
  const payload = {
    course: { name: "Curso Teste", slug: "curso-teste" },
    bank: { name: "Fundatec" },
    subject: { name: "Língua Portuguesa" },
    unit: { title: "Concordância verbal" },
    pedagogical_context: { scope: "escopo de teste" },
    source: { validated_source_keys: [] },
  };
  const questaoCompleta = { slot: 1, enunciado: "x", alternativas: [{ letra: "A", texto: "a" }], gabarito: "A", explicacao: "e", fundamento: {}, dificuldade: "media" };

  const semPerfil = montarPromptAuditorCritic(payload, [questaoCompleta, { ...questaoCompleta, slot: 2 }]);
  assert.match(semPerfil, /Não há perfil de estilo de banca evidence-based/);

  const comPerfil = montarPromptAuditorCritic(payload, [questaoCompleta, { ...questaoCompleta, slot: 2 }], perfil);
  assert.match(comPerfil, /PERFIL DE ESTILO DA BANCA/);
  assert.match(comPerfil, /REAL_OFFICIAL_CONFIRMED/);

  // Perfil so com PARTIAL/UNCONFIRMED (confidence INSUFFICIENT) cai no fallback generico, igual a sem perfil nenhum.
  const perfilSoParcial = perfilarCorpus({
    bank: "Fundatec", subject: "Língua Portuguesa", bancaAlvoNormalizada: "fundatec",
    questoesRaw: [{ ...questaoRawFixture(), fonte: "TEC Concursos — questão 1 — FUNDATEC — posição 1 no conjunto de 1.000 questões" }],
    recentYearWindow: 6, anoAtual: 2026,
  }).perfil;
  const comPerfilInsuficiente = montarPromptAuditorCritic(payload, [questaoCompleta, { ...questaoCompleta, slot: 2 }], perfilSoParcial);
  assert.match(comPerfilInsuficiente, /Não há perfil de estilo de banca evidence-based/);
});

test("26. nenhum segredo aparece no perfil serializado nem nos prompts que o incluem", () => {
  const { perfil } = perfilarCorpus({
    bank: "Fundatec",
    subject: "Língua Portuguesa",
    bancaAlvoNormalizada: "fundatec",
    questoesRaw: corpusGrandeFixture(),
    recentYearWindow: 6,
    anoAtual: 2026,
  });
  const payload = {
    course: { name: "Curso Teste", slug: "curso-teste" },
    bank: { name: "Fundatec" },
    subject: { name: "Língua Portuguesa" },
    unit: { title: "Concordância verbal" },
    pedagogical_context: { scope: "escopo de teste" },
    source: { validated_source_keys: [] },
  };
  const questaoCompleta = { slot: 1, enunciado: "x", alternativas: [{ letra: "A", texto: "a" }], gabarito: "A", explicacao: "e", fundamento: {}, dificuldade: "media" };
  const prompt = montarPromptAuditorCritic(payload, [questaoCompleta, { ...questaoCompleta, slot: 2 }], perfil);
  const serializado = (JSON.stringify(perfil) + prompt).toLowerCase();
  for (const termoProibido of ["openai_api_key", "authorization", "bearer ", "sk-", "service_role", "supabase_db_url"]) {
    assert.equal(serializado.includes(termoProibido), false, `estrutura nao pode conter "${termoProibido}"`);
  }
});
