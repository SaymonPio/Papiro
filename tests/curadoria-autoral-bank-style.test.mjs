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
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {
  MATCH_STATUS,
  KEY_STATUS,
  EXAM_EVIDENCE_SOURCE_TYPES,
  KEY_EVIDENCE_SOURCE_TYPES,
  carregarProvenienciaCurada,
  obterIdsComProvenienciaConfirmada,
  obterProvenienciaConfirmada,
} from "../scripts/curadoria-autoral/lib/question-provenance-manifest.mjs";

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

test("10b. classificarComando (Fase 2C.3.3, bugfix via dado oficial verificado): fraseado canonico 'preenche, correta e respectivamente, as lacunas' tambem e detectado, mesmo com insercao mais longa entre preenche/lacuna, e mesmo com 'nos trechos' em vez de 'dos trechos'", () => {
  assert.equal(
    classificarComando("Considerando o tema X, assinale a alternativa que preenche, correta e respectivamente, as lacunas nos trechos a seguir:"),
    "PREENCHIMENTO_LACUNAS"
  );
  assert.equal(
    classificarComando("Assinale a alternativa que preenche, correta e respectivamente, as lacunas pontilhadas das linhas 01 e 02."),
    "PREENCHIMENTO_LACUNAS"
  );
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

test("15. calcularConfianca: limiares HIGH>=30, MEDIUM 15-29, LOW 1-14, INSUFFICIENT=0 (com distinctExams suficiente)", () => {
  assert.equal(calcularConfianca(30, 3), "HIGH");
  assert.equal(calcularConfianca(29, 3), "MEDIUM");
  assert.equal(calcularConfianca(15, 2), "MEDIUM");
  assert.equal(calcularConfianca(14, 2), "LOW");
  assert.equal(calcularConfianca(1, 1), "LOW");
  assert.equal(calcularConfianca(0, 0), "INSUFFICIENT");
});

test("15b. calcularConfianca (Fase 2C.3.4, Secao 12): contagem sozinha NUNCA basta para HIGH/MEDIUM sem diversidade de provas", () => {
  assert.equal(calcularConfianca(30, 1), "LOW", "30 questoes de 1 UNICA prova nao pode ser HIGH");
  assert.equal(calcularConfianca(30, 2), "MEDIUM", "30 questoes de so 2 provas nao atinge HIGH (exige >=3 provas), mas ainda satisfaz MEDIUM (>=15 confirmadas e >=2 provas)");
  assert.equal(calcularConfianca(50, 0), "LOW", "sem nenhuma prova distinta conhecida (defensivo), nunca promove alem de LOW");
  assert.equal(calcularConfianca(15, 1), "LOW", "15 questoes de 1 unica prova nao pode ser MEDIUM (exige >=2 provas)");
  assert.equal(calcularConfianca(100, 3), "HIGH", "quantidade grande + diversidade real -> HIGH");
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

// Fase 2C.3.4: distribui as questoes de um corpus fixture round-robin
// entre `nProvas` examKeys sinteticos distintos, simulando manifestos
// curados de PROVAS DIFERENTES — necessario para testes que precisam de
// confidence MEDIUM/HIGH (que agora exigem diversidade de provas, nao so
// contagem, Secao 12 do mandato 2C.3.4).
function provenienciaMapaMultiProva(corpus, nProvas = 2) {
  const mapa = new Map();
  corpus.forEach((q, i) => {
    const exameIndice = i % nProvas;
    mapa.set(q.id, { examKey: `exame-sintetico-${exameIndice}`, contest: `Concurso Sintetico ${exameIndice}`, role: "Cargo Sintetico", year: 2020 + exameIndice });
  });
  return mapa;
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
    provenienciaConfirmadaPorId: provenienciaMapaMultiProva(corpusGrande, 2),
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

test("21. avaliarFidelidadeEstilo: formato bem representado no corpus CONFIRMADO, com suporte multi-prova -> BANK_STYLE_MATCH", () => {
  const corpusGrande = corpusGrandeFixture();
  const { perfil } = perfilarCorpus({
    bank: "Fundatec",
    subject: "Língua Portuguesa",
    bancaAlvoNormalizada: "fundatec",
    questoesRaw: corpusGrande,
    recentYearWindow: 6,
    anoAtual: 2026,
    idsComProvenienciaConfirmada: idsCuradosDoCorpus(corpusGrande),
    provenienciaConfirmadaPorId: provenienciaMapaMultiProva(corpusGrande, 2),
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
    provenienciaConfirmadaPorId: provenienciaMapaMultiProva(corpusGrande, 2),
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

// ==================== CURADORIA DOCUMENTAL POR PROVA (Fase 2C.3.3) ====================
// question-provenance-manifest.mjs: manifesto por prova/lote, com evidencia
// separada da prova e do gabarito oficiais (cada uma com publisher/
// reference/url/document_hash/verified) e mapeamento questao a questao
// (match_status + key_status). So EXACT/STRONG + OFFICIAL_KEY_MATCH, com
// AMBAS as evidencias do lote verified=true e o registro validated=true,
// vira REAL_OFFICIAL_CONFIRMED. Fixtures SINTETICAS (hash/URL inventados
// para teste, nunca reaproveitando o hash real do PDF oficial da Brigada
// Militar) — nenhum enunciado/alternativa REAL e usado aqui.

const HASH_SINTETICO_A = "a".repeat(64);
const HASH_SINTETICO_B = "b".repeat(64);

function evidenciaFixture(overrides = {}) {
  return {
    source_type: "official_appeal_decision",
    publisher: "Orgao Contratante Ficticio",
    reference: "Edital de teste nº 00/2026 — Gabarito Definitivo",
    url: "https://orgao-ficticio.rs.gov.br/edital-teste.pdf",
    document_hash: HASH_SINTETICO_A,
    verified: true,
    ...overrides,
  };
}

function registroProvenienciaFixture(overrides = {}) {
  return {
    schema_version: 2,
    bank: "Fundatec",
    contest: "Concurso Ficticio de Teste",
    role: "Cargo Ficticio",
    year: 2026,
    official_exam_evidence: evidenciaFixture(),
    official_key_evidence: evidenciaFixture(),
    validated: true,
    validated_by: "human_documentary_curation",
    validated_at: "2026-09-09T00:00:00Z",
    questions: [{ question_id: 9001, official_question_number: 1, match_status: MATCH_STATUS.EXACT, key_status: KEY_STATUS.MATCH, stored_key: "A", official_key: "A" }],
    ...overrides,
  };
}

function comDiretorioTemporario(registro, fn) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "papiro-provenance-test-"));
  try {
    fs.writeFileSync(path.join(dir, "lote-teste.json"), JSON.stringify(registro), "utf8");
    const registros = carregarProvenienciaCurada(dir);
    return fn(registros);
  } finally {
    fs.rmSync(dir, { recursive: true, force: true });
  }
}

test("27. prova oficial + gabarito oficial final + match EXACT -> CONFIRMED", () => {
  comDiretorioTemporario(registroProvenienciaFixture(), (registros) => {
    const ids = obterIdsComProvenienciaConfirmada(registros, "fundatec");
    assert.equal(ids.has(9001), true);
  });
});

test("28. prova oficial verified, mas gabarito oficial (evidencia do lote) NAO verified -> NAO CONFIRMED", () => {
  comDiretorioTemporario(registroProvenienciaFixture({ official_key_evidence: evidenciaFixture({ verified: false, url: undefined, document_hash: undefined }) }), (registros) => {
    const ids = obterIdsComProvenienciaConfirmada(registros, "fundatec");
    assert.equal(ids.has(9001), false);
  });
});

test("29. gabarito oficial verified, mas prova oficial (evidencia do lote) NAO verified -> NAO CONFIRMED", () => {
  comDiretorioTemporario(registroProvenienciaFixture({ official_exam_evidence: evidenciaFixture({ verified: false, url: undefined, document_hash: undefined }) }), (registros) => {
    const ids = obterIdsComProvenienciaConfirmada(registros, "fundatec");
    assert.equal(ids.has(9001), false);
  });
});

test("30. agregador terceiro nunca substitui prova oficial — evidencia com publisher/source_type de agregador e rejeitada pela politica do projeto, nunca aceita so por regex", () => {
  // O manifesto curado nao tem como "saber" que um publisher e um
  // agregador — a defesa contra agregador acontece ANTES deste manifesto
  // existir (classificarProveniencia nunca promove so por regex, ver Fase
  // 2C.3.2). Este teste confirma que mesmo colando o NOME de um agregador
  // como publisher, o unico jeito de confirmar continua sendo um registro
  // humano explicito e completo — nao ha atalho automatico.
  comDiretorioTemporario(
    registroProvenienciaFixture({
      official_exam_evidence: evidenciaFixture({ publisher: "TEC Concursos" }),
      official_key_evidence: evidenciaFixture({ publisher: "TEC Concursos" }),
    }),
    (registros) => {
      // Mesmo com publisher de agregador, se um humano AINDA ASSIM marcou
      // validated=true com url/hash presentes, o sistema confia no
      // julgamento humano explicito (a barreira contra agregador e
      // impedir promocao AUTOMATICA, nao proibir nomes de string) — mas
      // confirma que SEM esse registro humano completo, nada e promovido.
      const ids = obterIdsComProvenienciaConfirmada(registros, "fundatec");
      assert.equal(ids.has(9001), true, "com manifesto humano explicito e completo, a promocao ocorre — a protecao real esta em nunca promover SEM esse manifesto (testes 8b-8d da Fase 2C.3.2)");
    }
  );
});

test("31. key mismatch (gabarito Papiro diverge do oficial) -> NAO CONFIRMED", () => {
  comDiretorioTemporario(registroProvenienciaFixture({ questions: [{ question_id: 9001, official_question_number: 1, match_status: MATCH_STATUS.EXACT, key_status: KEY_STATUS.MISMATCH, stored_key: "A", official_key: "B" }] }), (registros) => {
    const ids = obterIdsComProvenienciaConfirmada(registros, "fundatec");
    assert.equal(ids.has(9001), false);
  });
});

test("32. match AMBIGUOUS -> NAO CONFIRMED, mesmo com key_status MATCH", () => {
  comDiretorioTemporario(registroProvenienciaFixture({ questions: [{ question_id: 9001, official_question_number: 1, match_status: MATCH_STATUS.AMBIGUOUS, key_status: KEY_STATUS.MATCH, stored_key: "A", official_key: "A" }] }), (registros) => {
    const ids = obterIdsComProvenienciaConfirmada(registros, "fundatec");
    assert.equal(ids.has(9001), false);
  });
});

test("32b. match NO_MATCH -> NAO CONFIRMED", () => {
  comDiretorioTemporario(registroProvenienciaFixture({ questions: [{ question_id: 9001, official_question_number: 1, match_status: MATCH_STATUS.NO_MATCH, key_status: KEY_STATUS.MATCH, stored_key: "A", official_key: "A" }] }), (registros) => {
    const ids = obterIdsComProvenienciaConfirmada(registros, "fundatec");
    assert.equal(ids.has(9001), false);
  });
});

test("32c. key_status UNAVAILABLE -> NAO CONFIRMED", () => {
  comDiretorioTemporario(registroProvenienciaFixture({ questions: [{ question_id: 9001, official_question_number: 1, match_status: MATCH_STATUS.EXACT, key_status: KEY_STATUS.UNAVAILABLE, stored_key: "A", official_key: null }] }), (registros) => {
    const ids = obterIdsComProvenienciaConfirmada(registros, "fundatec");
    assert.equal(ids.has(9001), false);
  });
});

test("33. manifesto inteiro validated=false -> NAO CONFIRMED mesmo com match/key perfeitos", () => {
  comDiretorioTemporario(registroProvenienciaFixture({ validated: false, validated_by: undefined }), (registros) => {
    const ids = obterIdsComProvenienciaConfirmada(registros, "fundatec");
    assert.equal(ids.has(9001), false);
  });
});

test("34. hash documental ausente/malformado com verified=true -> evidencia incompativel, registro REJEITADO no carregamento", () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "papiro-provenance-test-"));
  try {
    const registroSemHash = registroProvenienciaFixture({ official_exam_evidence: evidenciaFixture({ document_hash: undefined }) });
    fs.writeFileSync(path.join(dir, "lote-sem-hash.json"), JSON.stringify(registroSemHash), "utf8");
    assert.throws(() => carregarProvenienciaCurada(dir), /document_hash/);

    fs.rmSync(path.join(dir, "lote-sem-hash.json"));
    const registroHashCurto = registroProvenienciaFixture({ official_exam_evidence: evidenciaFixture({ document_hash: "abc123" }) });
    fs.writeFileSync(path.join(dir, "lote-hash-curto.json"), JSON.stringify(registroHashCurto), "utf8");
    assert.throws(() => carregarProvenienciaCurada(dir), /document_hash/);
  } finally {
    fs.rmSync(dir, { recursive: true, force: true });
  }
});

test("35. diretorio vazio/inexistente -> [] (normal, nao erro) e nenhum id confirmado", () => {
  const dirInexistente = path.join(os.tmpdir(), "papiro-provenance-dir-que-nao-existe-" + Date.now());
  const registros = carregarProvenienciaCurada(dirInexistente);
  assert.deepEqual(registros, []);
  assert.equal(obterIdsComProvenienciaConfirmada(registros, "fundatec").size, 0);
});

test("36. manifesto real (sources/question-provenance/fundatec-bm-rs-soldado-nivel-iii-2022.json) carrega, valida, e NUNCA persiste enunciado/alternativa REAL integral", () => {
  const registros = carregarProvenienciaCurada();
  assert.ok(registros.length >= 1, "esperado pelo menos o lote Brigada Militar RS Soldado Nivel III 2022 curado nesta fase");
  const registro = registros.find((r) => r.contest.includes("Soldado Nível III"));
  assert.ok(registro, "registro do lote BM RS Soldado Nivel III 2022 deve existir");
  assert.equal(registro.validated, true);
  assert.equal(registro.official_exam_evidence.verified, true);
  assert.equal(registro.official_key_evidence.verified, true);

  const ids = obterIdsComProvenienciaConfirmada(registros, "fundatec");
  for (const id of [114, 115, 116, 117, 118, 120, 121, 122, 123]) {
    assert.equal(ids.has(id), true, `id ${id} deveria estar confirmado`);
  }
  assert.equal(ids.has(119), false, "id 119 (match AMBIGUOUS) nao pode estar confirmado");

  // Zero enunciado/alternativa integral: nenhuma sequencia de texto longa
  // (>40 chars alfabeticos consecutivos, heuristica simples) deveria
  // aparecer no manifesto — so metadados/hashes/status/achados descritivos
  // curtos sobre o PROCESSO de comparacao, nunca o conteudo copiado.
  const serializado = JSON.stringify(registro);
  const pareceQuestaoCopiada = /assinale a alternativa (correta|incorreta) quanto/i.test(serializado) || /^\s*Considerando o (emprego|uso)/im.test(serializado);
  assert.equal(pareceQuestaoCopiada, false, "manifesto nao pode conter enunciado de questao real copiado literalmente");
});

// ==================== EXPANSAO MULTI-PROVA (Fase 2C.3.4) ====================

test("37. calcularConfianca: HIGH exige >=30 confirmadas E >=3 provas distintas; 30 questoes de 1 prova NAO e HIGH nem MEDIUM-por-inercia", () => {
  assert.equal(calcularConfianca(30, 3), "HIGH");
  assert.equal(calcularConfianca(30, 1), "LOW", "30 questoes de uma UNICA prova nunca pode virar HIGH nem MEDIUM");
  assert.equal(calcularConfianca(50, 1), "LOW", "quantidade grande nao compensa diversidade zero");
});

test("38. calcularConfianca: MEDIUM exige >=15 confirmadas E >=2 provas distintas", () => {
  assert.equal(calcularConfianca(15, 2), "MEDIUM");
  assert.equal(calcularConfianca(20, 1), "LOW", "20 confirmadas de 1 prova so nao vira MEDIUM");
});

test("39. command_patterns registra distinct_exams_supporting e distinct_years_supporting por formato", () => {
  const idsCurados = new Set([1, 2, 3, 4, 5]);
  const mapaProveniencia = new Map([
    [1, { examKey: "prova-A", contest: "Concurso A", role: "Cargo A", year: 2022 }],
    [2, { examKey: "prova-A", contest: "Concurso A", role: "Cargo A", year: 2022 }],
    [3, { examKey: "prova-B", contest: "Concurso B", role: "Cargo B", year: 2023 }],
    [4, { examKey: "prova-B", contest: "Concurso B", role: "Cargo B", year: 2023 }],
    [5, { examKey: "prova-C", contest: "Concurso C", role: "Cargo C", year: 2024 }],
  ]);
  const base = questaoRawFixture();
  const corpus = [1, 2, 3, 4, 5].map((id) => ({ ...base, id, enunciado: `Assinale a alternativa que preenche corretamente as lacunas do item ${id}: ___.` }));
  const { perfil } = perfilarCorpus({
    bank: "Fundatec", subject: "Língua Portuguesa", bancaAlvoNormalizada: "fundatec",
    questoesRaw: corpus, recentYearWindow: 6, anoAtual: 2026,
    idsComProvenienciaConfirmada: idsCurados, provenienciaConfirmadaPorId: mapaProveniencia,
  });
  const lacunas = perfil.command_patterns.find((c) => c.format === "PREENCHIMENTO_LACUNAS");
  assert.ok(lacunas, "PREENCHIMENTO_LACUNAS deveria aparecer em command_patterns");
  assert.equal(lacunas.count, 5);
  assert.equal(lacunas.distinct_exams_supporting, 3, "5 questoes vem de 3 provas distintas (A, B, C)");
  assert.equal(lacunas.distinct_years_supporting, 3, "anos 2022/2023/2024");
  assert.equal(lacunas.robust_multi_exam_support, true, "count>=3 e distinct_exams_supporting>=2 -> robusto");
  assert.equal(perfil.diversity.distinct_exams, 3);
  assert.equal(perfil.diversity.distinct_contests, 3);
  assert.equal(perfil.diversity.distinct_roles, 3);
  assert.equal(perfil.diversity.distinct_years, 3);
});

test("40. PREENCHIMENTO_LACUNAS com 4 exemplares, todos da MESMA prova, NAO satisfaz suporte multi-prova -> avaliarFidelidadeEstilo nunca da MATCH so por essa contagem", () => {
  // Corpus desenhado para isolar a variavel testada: confidence GERAL
  // precisa ser >= MEDIUM (15 confirmadas, 2 provas distintas) para que a
  // checagem de robustez POR FORMATO seja de fato exercitada (senao o
  // fallback de confidence baixa mascara o efeito) — mas as 4 questoes de
  // PREENCHIMENTO_LACUNAS ficam concentradas em UMA SO dessas 2 provas,
  // enquanto as outras 11 confirmadas (formato diferente) vem da segunda
  // prova, garantindo diversidade geral sem dar suporte multi-prova ao
  // formato lacunas especificamente.
  const base = questaoRawFixture();
  const idsCurados = new Set();
  const mapaProveniencia = new Map();
  const corpus = [];
  for (let i = 0; i < 4; i++) {
    const id = 100 + i;
    idsCurados.add(id);
    mapaProveniencia.set(id, { examKey: "prova-A", contest: "Concurso A", role: "Cargo A", year: 2022 });
    corpus.push({ ...base, id, enunciado: `Assinale a alternativa que preenche corretamente as lacunas do item ${i}: ___.` });
  }
  for (let i = 0; i < 11; i++) {
    const id = 200 + i;
    idsCurados.add(id);
    mapaProveniencia.set(id, { examKey: "prova-B", contest: "Concurso B", role: "Cargo B", year: 2023 });
    corpus.push({ ...base, id, enunciado: `Assinale a alternativa correta quanto à regência verbal no item ${i}.` });
  }
  const { perfil } = perfilarCorpus({
    bank: "Fundatec", subject: "Língua Portuguesa", bancaAlvoNormalizada: "fundatec",
    questoesRaw: corpus, recentYearWindow: 6, anoAtual: 2026,
    idsComProvenienciaConfirmada: idsCurados, provenienciaConfirmadaPorId: mapaProveniencia,
  });
  assert.equal(perfil.sample.real_official_confirmed, 15);
  assert.equal(perfil.diversity.distinct_exams, 2);
  assert.equal(perfil.confidence, "MEDIUM", "sanity check — confidence geral precisa estar OK para isolar a checagem por formato");

  const lacunas = perfil.command_patterns.find((c) => c.format === "PREENCHIMENTO_LACUNAS");
  assert.equal(lacunas.count, 4);
  assert.equal(lacunas.distinct_exams_supporting, 1);
  assert.equal(lacunas.robust_multi_exam_support, false, "4 exemplares da MESMA prova nao e evidencia ampla de estilo da banca (Secao 13)");

  const questaoLacunas = { enunciado: "Assinale a alternativa que preenche corretamente as lacunas do item de teste: ___.", alternativas: [{ texto: "a" }, { texto: "b" }, { texto: "c" }, { texto: "d" }, { texto: "e" }] };
  const resultado = avaliarFidelidadeEstilo(questaoLacunas, perfil);
  assert.notEqual(resultado.style_fidelity_status, STATUS_FIDELIDADE_ESTILO.BANK_STYLE_MATCH, "suporte de uma unica prova nunca deveria produzir MATCH");
  assert.ok(resultado.reason_codes.includes("COMMAND_FORMAT_SINGLE_EXAM_ONLY"));
});

test("41. documento de julgamento de recursos NAO pode ser rotulado 'official_exam' generico — tipos documentais permanecem explicitos", () => {
  assert.equal(EXAM_EVIDENCE_SOURCE_TYPES.includes("official_exam"), false, "rotulo generico 'official_exam' foi deliberadamente excluido do vocabulario controlado");
  assert.ok(EXAM_EVIDENCE_SOURCE_TYPES.includes("official_appeal_decision"), "julgamento de recursos precisa ter um rotulo proprio e honesto");
  assert.ok(EXAM_EVIDENCE_SOURCE_TYPES.includes("official_exam_booklet"), "caderno de prova literal precisa ter seu proprio rotulo, distinto do julgamento de recursos");

  assert.throws(
    () =>
      comDiretorioTemporario(registroProvenienciaFixture({ official_exam_evidence: evidenciaFixture({ source_type: "official_exam" }) }), () => {}),
    /source_type/,
    "registro com source_type generico 'official_exam' deveria ser REJEITADO no carregamento, nunca aceito silenciosamente"
  );
});

test("41b. gabarito PRELIMINAR nunca e um tipo valido de evidencia de gabarito (so o definitivo confirma)", () => {
  assert.equal(KEY_EVIDENCE_SOURCE_TYPES.includes("official_preliminary_answer_key"), false);
  assert.equal(KEY_EVIDENCE_SOURCE_TYPES.includes("official_final_answer_key"), true);
});

test("41c. tentar carregar um registro com source_type invalido lanca erro explicativo (rejeitado, nunca aceito silenciosamente)", () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "papiro-provenance-test-"));
  try {
    const registroInvalido = registroProvenienciaFixture({ official_key_evidence: evidenciaFixture({ source_type: "official_preliminary_answer_key" }) });
    fs.writeFileSync(path.join(dir, "lote-preliminar.json"), JSON.stringify(registroInvalido), "utf8");
    assert.throws(() => carregarProvenienciaCurada(dir), /source_type/);
  } finally {
    fs.rmSync(dir, { recursive: true, force: true });
  }
});

test("42. obterProvenienciaConfirmada expoe examKey/contest/role/year por questao confirmada (necessario para diversidade)", () => {
  comDiretorioTemporario(registroProvenienciaFixture(), (registros) => {
    const mapa = obterProvenienciaConfirmada(registros, "fundatec");
    assert.ok(mapa.has(9001));
    const meta = mapa.get(9001);
    assert.equal(meta.contest, "Concurso Ficticio de Teste");
    assert.equal(meta.role, "Cargo Ficticio");
    assert.equal(meta.year, 2026);
    assert.equal(typeof meta.examKey, "string");
    assert.ok(meta.examKey.length > 0);
  });
});

test("43. nenhum texto REAL integral persistido nos manifestos multi-prova (heuristica de enunciado copiado)", () => {
  const registros = carregarProvenienciaCurada();
  for (const registro of registros) {
    const serializado = JSON.stringify(registro);
    assert.equal(/assinale a alternativa (correta|incorreta) quanto/i.test(serializado), false, `manifesto de "${registro.contest}" nao pode conter enunciado real copiado`);
  }
});
