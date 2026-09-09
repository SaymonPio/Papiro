// Perfilador de estilo de banca — PURO, multi-banca (Fase 2C.3, Secoes
// 3-4, 10-11, 13). Nunca "if banca === 'Fundatec'": toda decisao especifica
// de Fundatec vem de DADOS (o corpus carregado), nunca de codigo
// hardcoded — a mesma funcao roda para qualquer banca/materia.
//
// Principio central (Secao 1): nada aqui pode nascer de conhecimento
// generico de IA sobre bancas. Toda classificacao vem de campos reais do
// banco (banca/concurso/ano/fonte/gerada_por_ia) ou de regex aplicada ao
// ENUNCIADO REAL — nunca de uma lista hardcoded de "a Fundatec costuma...".

import { extrairFeaturesQuestao } from "./bank-style-features.mjs";

export function normalizarBanca(banca) {
  return (banca || "").trim().toLowerCase();
}

// Heuristica por PALAVRA (nao substring livre) para identificar concursos
// policiais/de seguranca publica a partir do campo `concurso` real — nunca
// aplicada ao texto da questao, so aos metadados do concurso. Documentada
// como heuristica (Secao 19: "nao assumir... so porque parece plausivel"),
// nao como fato objetivo — cada padrao foi conferido contra os concursos
// reais observados no corpus desta sessao antes de ser incluido aqui.
const PADROES_POLICIAL_SEGURANCA = Object.freeze([
  /\bpol\b/i,
  /\bgm\b/i,
  /\bgcm\b/i,
  /guarda municipal/i,
  /brigada militar/i,
  /bombeiro/i,
  /per[ií]ci/i,
  /penitenci[aá]ri/i,
  /pol[ií]cia/i,
  /policial/i,
  /delegado/i,
  /escriv[aã]o/i,
  /socioeducativ/i,
  /seguran[cç]a p[uú]blica/i,
  /\bigp\b/i, // Instituto-Geral de Pericias (RS) — "Per Crim (IGP RS)", "Tec Per (IGP RS)"
  /\bper\s*crim\b/i, // "Per Crim" = Perito Criminal, abreviado sem "peric*"
]);

export function pareceConcursoPolicialOuSegurancaPublica(concursoTexto) {
  return PADROES_POLICIAL_SEGURANCA.some((padrao) => padrao.test(concursoTexto || ""));
}

// Fase 2C.3.1 (Secao 0): banca+concurso+ano+fonte preenchidos NUNCA prova,
// por si so, "questao original de prova oficial + gabarito oficial
// definitivo".
//
// Fase 2C.3.2 (Secoes 1, 5): a Fase 2C.3.1 ainda deixava uma brecha —
// tratava um PADRAO DE TEXTO batendo no campo `fonte` (regex) como se
// fosse PROVA documental. Nao e. As duas funcoes abaixo (temEvidencia...)
// sao SOURCE_TEXT_PATTERN — sinais uteis para descoberta/triagem, jamais
// suficientes sozinhos para REAL_OFFICIAL_CONFIRMED (ver
// PADRAO_GABARITO_OFICIAL_EXPLICITO etc. mais abaixo, e a investigacao ao
// vivo documentada em question-provenance-manifest.mjs: nenhuma tabela do
// schema guarda evidencia documental por questao). A UNICA fonte de
// PROVENANCE_EVIDENCE real e o manifesto curado por humano em
// question-provenance-manifest.mjs — ver classificarProveniencia abaixo.
// Os padroes de texto usados vieram da leitura real do campo `fonte` dos
// 111 registros Fundatec/Portugues desta sessao (nunca inventados):
//
//   "Fundatec — <concurso> — Questão N" (a PROPRIA banca citando um exame
//     nomeado + numero de questao especifico): sinal FORTE de descoberta,
//     mas ainda so um padrao de texto — pode ter sido digitado por
//     qualquer processo de importacao, sem verificacao humana contra o
//     documento oficial.
//   "TEC Concursos — questão <id> — <BANCA> — posição N..." (agregador
//     terceiro que cita a banca): sinal mais fraco, mesmo problema.
//   Mencao explicita a "gabarito oficial"/"gabarito definitivo": idem —
//     e so texto, nao verificacao.
function escaparRegex(texto) {
  return (texto || "").replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

const PADRAO_GABARITO_OFICIAL_EXPLICITO = /gabarito\s+(oficial|definitivo)/i;

/**
 * SOURCE_TEXT_PATTERN (nao PROVENANCE_EVIDENCE): sinal de que o campo
 * `fonte` PARECE citar qual prova originou a questao — citacao direta da
 * propria banca (com numero de questao) OU agregador terceiro que cite a
 * banca. Usado apenas para alimentar REAL_PROVENANCE_PARTIAL/diagnostico
 * — nunca decide REAL_OFFICIAL_CONFIRMED sozinho (Fase 2C.3.2, Secao 5).
 */
export function temEvidenciaProvaOficial(questaoRaw, bancaAlvoOriginal) {
  const fonte = (questaoRaw.fonte || "").toString().trim();
  if (!fonte) return false;
  const bancaEscapada = escaparRegex(bancaAlvoOriginal);
  const citaBancaComQuestao = bancaEscapada ? new RegExp(`^${bancaEscapada}\\s*—.*—\\s*Quest[ãa]o\\s+\\d+`, "i").test(fonte) : false;
  const citaAgregadorComBanca = /^TEC\s+Concursos/i.test(fonte) && (bancaEscapada ? new RegExp(bancaEscapada, "i").test(fonte) : false);
  return citaBancaComQuestao || citaAgregadorComBanca;
}

/**
 * SOURCE_TEXT_PATTERN (nao PROVENANCE_EVIDENCE): sinal de que o campo
 * `fonte` PARECE indicar que o gabarito e oficial/definitivo — citacao
 * direta da propria banca (mesmo padrao acima) OU mencao explicita a
 * "gabarito oficial"/"gabarito definitivo". So diagnostico/PARTIAL, nunca
 * decide REAL_OFFICIAL_CONFIRMED sozinho (Fase 2C.3.2, Secao 5).
 */
export function temEvidenciaGabaritoOficial(questaoRaw, bancaAlvoOriginal) {
  const fonte = (questaoRaw.fonte || "").toString().trim();
  if (!fonte) return false;
  const bancaEscapada = escaparRegex(bancaAlvoOriginal);
  const citaBancaComQuestao = bancaEscapada ? new RegExp(`^${bancaEscapada}\\s*—.*—\\s*Quest[ãa]o\\s+\\d+`, "i").test(fonte) : false;
  return citaBancaComQuestao || PADRAO_GABARITO_OFICIAL_EXPLICITO.test(fonte);
}

/**
 * Classifica a proveniencia de UMA questao com a regra ESTRITA da Fase
 * 2C.3.1/2C.3.2 (Secao 3 / Secoes 1-5). So REAL_OFFICIAL_CONFIRMED entra
 * nas metricas principais do perfil — nunca gerada_por_ia sozinho decide
 * (campo com inconsistencia historica conhecida), e nunca banca+concurso+
 * ano+fonte SOZINHOS bastam.
 *
 * Fase 2C.3.2 (Secoes 1, 5-6): a Fase 2C.3.1 promovia a CONFIRMED so por
 * um PADRAO DE TEXTO no campo `fonte` (regex) — isso e SOURCE_TEXT_PATTERN,
 * nunca PROVENANCE_EVIDENCE (regex nao e proveniencia). Fechada: agora
 * REAL_OFFICIAL_CONFIRMED SO e possivel para ids presentes em
 * idsComProvenienciaConfirmada — um Set alimentado exclusivamente pelo
 * manifesto curado por humano (question-provenance-manifest.mjs). Sem
 * registro curado, o teto e REAL_PROVENANCE_PARTIAL, nao importa quao
 * "oficial" o texto da fonte pareca (mesmo citacao direta da banca, mesmo
 * a frase literal "gabarito oficial").
 *
 * @param {object} questaoRaw
 * @param {{ bancaAlvoNormalizada: string, bancaAlvoOriginal?: string, idsComProvenienciaConfirmada?: Set<number> }} opcoes
 *   bancaAlvoOriginal preserva a grafia original (ex.: "Fundatec") para
 *   comparar contra o inicio literal do campo `fonte` — a normalizacao
 *   (minuscula) nao importa para esse match especifico, mas a grafia
 *   exata da banca sim. idsComProvenienciaConfirmada default = Set vazio
 *   (postura segura: sem manifesto curado, nada e auto-confirmado).
 */
export function classificarProveniencia(questaoRaw, { bancaAlvoNormalizada, bancaAlvoOriginal, idsComProvenienciaConfirmada = new Set() }) {
  const bancaNormalizada = normalizarBanca(questaoRaw.banca);
  if (bancaNormalizada.includes("papiro")) return "NOT_REAL";
  if (questaoRaw.gerada_por_ia === true) return "NOT_REAL";
  if (questaoRaw.ativa === false) return "NOT_REAL";
  if (bancaNormalizada !== bancaAlvoNormalizada) return "NOT_REAL";

  const bancaOriginal = bancaAlvoOriginal ?? questaoRaw.banca;
  const examEvidence = temEvidenciaProvaOficial(questaoRaw, bancaOriginal);
  const keyEvidence = temEvidenciaGabaritoOficial(questaoRaw, bancaOriginal);
  const temConcurso = Boolean(questaoRaw.concurso && String(questaoRaw.concurso).trim());
  const temAno = questaoRaw.ano !== null && questaoRaw.ano !== undefined;
  const temFonte = Boolean(questaoRaw.fonte && String(questaoRaw.fonte).trim());
  const temProvenienciaCurada = idsComProvenienciaConfirmada.has(questaoRaw.id);

  if (temProvenienciaCurada && temConcurso && temAno) {
    // UNICO caminho para CONFIRMED: evidencia curada por humano, nunca
    // regex sozinho (Fase 2C.3.2, Secao 5).
    return "REAL_OFFICIAL_CONFIRMED";
  }
  if ((examEvidence || keyEvidence || temFonte) && (temConcurso || temAno)) {
    // Padrao de texto forte (ou fraco) sem manifesto curado: indicio real,
    // nunca confirmacao direta — nunca promovido para nao inflar a
    // amostra (Secao 5 da Fase 2C.3.1: "Nao promover PARTIAL para
    // aumentar artificialmente a amostra"; Secao 6 da Fase 2C.3.2: "texto
    // livre... sem proveniencia confiavel -> NAO promover automaticamente
    // se isso nao for distinguivel").
    return "REAL_PROVENANCE_PARTIAL";
  }
  return "REAL_UNCONFIRMED";
}

/**
 * Classifica o TIER (Secao 4-5). recentYearWindow e SEMPRE um parametro
 * explicito (nunca um peso inventado); anoAtual tambem e passado pelo
 * chamador (nunca Date.now() direto aqui, para a funcao continuar pura e
 * testavel deterministicamente).
 */
export function classificarTier(questaoRaw, { anoAtual, recentYearWindow }) {
  const ehPolicial = pareceConcursoPolicialOuSegurancaPublica(questaoRaw.concurso);
  if (!ehPolicial) return "TIER_3";
  const ano = questaoRaw.ano;
  const anoConhecidoERecente = ano !== null && ano !== undefined && anoAtual - ano < recentYearWindow;
  return anoConhecidoERecente ? "TIER_1" : "TIER_2";
}

// Fase 2C.3.1, Secao 5 — limiares atualizados: LOW deixa de ser "tudo
// abaixo de 15" e passa a exigir pelo menos 1 questao REAL_OFFICIAL_CONFIRMED;
// zero confirmadas e INSUFFICIENT, um estado distinto e mais honesto do
// que classificar como "LOW" (que ainda sugeria alguma base).
export function calcularConfianca(nOfficialConfirmed) {
  if (nOfficialConfirmed >= 30) return "HIGH";
  if (nOfficialConfirmed >= 15) return "MEDIUM";
  if (nOfficialConfirmed >= 1) return "LOW";
  return "INSUFFICIENT";
}

function calcularPercentis(valores) {
  if (!valores || valores.length === 0) return { min: null, p25: null, mediana: null, p75: null, max: null };
  const ordenados = [...valores].sort((a, b) => a - b);
  function percentil(p) {
    const idx = (p / 100) * (ordenados.length - 1);
    const lo = Math.floor(idx);
    const hi = Math.ceil(idx);
    if (lo === hi) return ordenados[lo];
    return ordenados[lo] + (ordenados[hi] - ordenados[lo]) * (idx - lo);
  }
  return {
    min: ordenados[0],
    p25: Math.round(percentil(25)),
    mediana: Math.round(percentil(50)),
    p75: Math.round(percentil(75)),
    max: ordenados[ordenados.length - 1],
  };
}

/**
 * Monta o perfil completo (Secao 10) a partir de questoes JA classificadas
 * (proveniencia + tier + features). NUNCA recebe/persiste enunciado ou
 * alternativas — so os campos ja reduzidos a numero/categoria (Secao 12).
 *
 * @param {{
 *   bank: string, subject: string,
 *   questoesClassificadas: Array<{ id: number, proveniencia: string, tier: string, ano: number|null, features: object }>,
 *   recentYearWindow: number, anoAtual: number,
 * }} entrada
 */
export function construirPerfilBanca({ bank, subject, questoesClassificadas, recentYearWindow, anoAtual }) {
  const highConfidence = questoesClassificadas.filter((q) => q.proveniencia === "REAL_OFFICIAL_CONFIRMED");
  const provenancePartial = questoesClassificadas.filter((q) => q.proveniencia === "REAL_PROVENANCE_PARTIAL");
  const unconfirmed = questoesClassificadas.filter((q) => q.proveniencia === "REAL_UNCONFIRMED");

  const porTier = { TIER_1: [], TIER_2: [], TIER_3: [] };
  for (const q of highConfidence) porTier[q.tier]?.push(q);

  // Secao 6: relatar confirmed/partial/unconfirmed separadamente POR TIER
  // (secundario — nunca alimenta metricas principais/percentis/command_patterns,
  // so o relatorio de transparencia).
  const porTierPartial = { TIER_1: 0, TIER_2: 0, TIER_3: 0 };
  for (const q of provenancePartial) if (porTierPartial[q.tier] !== undefined) porTierPartial[q.tier] += 1;
  const porTierUnconfirmed = { TIER_1: 0, TIER_2: 0, TIER_3: 0 };
  for (const q of unconfirmed) if (porTierUnconfirmed[q.tier] !== undefined) porTierUnconfirmed[q.tier] += 1;

  const anos = highConfidence.map((q) => q.ano).filter((a) => a !== null && a !== undefined);

  // format_distribution + command_patterns (com quebra por tier — Secao 4: "nao misturar tiers silenciosamente")
  const contagemComando = {};
  const porTierComando = { TIER_1: {}, TIER_2: {}, TIER_3: {} };
  for (const q of highConfidence) {
    const comando = q.features.comando;
    contagemComando[comando] = (contagemComando[comando] ?? 0) + 1;
    porTierComando[q.tier][comando] = (porTierComando[q.tier][comando] ?? 0) + 1;
  }
  const total = highConfidence.length;
  const commandPatterns = Object.entries(contagemComando)
    .sort((a, b) => b[1] - a[1])
    .map(([formato, contagem]) => ({
      format: formato,
      count: contagem,
      percent: total > 0 ? Math.round((contagem / total) * 1000) / 10 : 0,
      by_tier: { TIER_1: porTierComando.TIER_1[formato] ?? 0, TIER_2: porTierComando.TIER_2[formato] ?? 0, TIER_3: porTierComando.TIER_3[formato] ?? 0 },
    }));

  // alternative_count_distribution
  const contagemAlternativas = {};
  for (const q of highConfidence) {
    const n = q.features.n_alternativas;
    contagemAlternativas[n] = (contagemAlternativas[n] ?? 0) + 1;
  }

  // base_text_usage
  const baseTextUsage = { autocontida: 0, usa_texto_base: 0, usa_referencia_linhas: 0, usa_fragmento: 0, depende_imagem_tabela: 0 };
  for (const q of highConfidence) {
    for (const chave of Object.keys(baseTextUsage)) {
      if (q.features.texto_base[chave]) baseTextUsage[chave] += 1;
    }
  }

  // length_profile
  const enunciadoChars = highConfidence.map((q) => q.features.comprimentos.enunciado_chars);
  const alternativaCharsFlat = highConfidence.flatMap((q) => q.features.comprimentos.alternativa_chars);

  const confidence = calcularConfianca(highConfidence.length);

  const observedCharacteristics = [];
  const unsupportedClaims = [];

  const contagem5 = contagemAlternativas[5] ?? 0;
  if (total > 0) {
    observedCharacteristics.push(
      `${contagem5}/${total} questões REAL_OFFICIAL_CONFIRMED (${Math.round((contagem5 / total) * 100)}%) têm exatamente 5 alternativas — formato dominante.`
    );
  }
  const lacunasInfo = commandPatterns.find((c) => c.format === "PREENCHIMENTO_LACUNAS");
  if (lacunasInfo) {
    observedCharacteristics.push(
      `Formato PREENCHIMENTO_LACUNAS confirmado em ${lacunasInfo.count}/${total} questões (${lacunasInfo.percent}%) — tiers: T1=${lacunasInfo.by_tier.TIER_1}, T2=${lacunasInfo.by_tier.TIER_2}, T3=${lacunasInfo.by_tier.TIER_3}.`
    );
  } else if (total > 0) {
    unsupportedClaims.push("Nenhuma questão REAL_OFFICIAL_CONFIRMED deste corpus usa o formato PREENCHIMENTO_LACUNAS — não presumir que esse formato é representativo sem essa evidência.");
  }
  if (baseTextUsage.usa_texto_base > 0) {
    observedCharacteristics.push(`${baseTextUsage.usa_texto_base}/${total} questões dependem de texto-base longo (marcador de linha ou enunciado extenso).`);
  }
  unsupportedClaims.push("Posição/distribuição do gabarito (A-E) não é usada para inferir nem influenciar geração futura — apenas diagnóstico, nunca peso (Secao 8-F do mandato).");
  unsupportedClaims.push("Nenhuma diferenciação por sub-habilidade linguística (gramática x interpretação) foi feita nesta versão do perfil — apenas formato/estrutura.");
  unsupportedClaims.push(
    `${provenancePartial.length} questões REAL_PROVENANCE_PARTIAL e ${unconfirmed.length} REAL_UNCONFIRMED existem no corpus bruto, mas NÃO alimentam nenhuma métrica principal — Secao 4 do mandato (nunca promovidas para aumentar a amostra).`
  );
  unsupportedClaims.push(
    "REAL_OFFICIAL_CONFIRMED exige registro curado por humano em sources/question-provenance/*.json (Fase 2C.3.2) — padrão de texto no campo `fonte` (citação direta da banca, agregador, ou a frase 'gabarito oficial') NUNCA basta sozinho, mesmo quando parece uma referência oficial legítima."
  );

  return {
    schema_version: 2,
    provenance_standard: "strict_official_confirmed_curated_evidence",
    bank,
    subject,
    generated_at: new Date().toISOString(),
    recent_year_window: recentYearWindow,
    ano_atual_referencia: anoAtual,

    sample: {
      real_official_confirmed: highConfidence.length,
      real_provenance_partial: provenancePartial.length,
      real_unconfirmed: unconfirmed.length,
      tier_1: porTier.TIER_1.length,
      tier_2: porTier.TIER_2.length,
      tier_3: porTier.TIER_3.length,
      year_min: anos.length > 0 ? Math.min(...anos) : null,
      year_max: anos.length > 0 ? Math.max(...anos) : null,
    },

    // Secao 6: relatorio secundario de transparencia — NUNCA alimenta
    // percentis/format_distribution/command_patterns acima.
    secondary_provenance_report: {
      real_provenance_partial_by_tier: porTierPartial,
      real_unconfirmed_by_tier: porTierUnconfirmed,
    },

    confidence,

    format_distribution: contagemComando,
    alternative_count_distribution: contagemAlternativas,
    base_text_usage: baseTextUsage,
    command_patterns: commandPatterns,

    length_profile: {
      enunciado_chars: calcularPercentis(enunciadoChars),
      alternativa_chars: calcularPercentis(alternativaCharsFlat),
    },

    observed_characteristics: observedCharacteristics,
    unsupported_claims: unsupportedClaims,
  };
}

/**
 * Pipeline completo: recebe as linhas cruas (com enunciado/alternativas em
 * memoria, NUNCA persistidas) + parametros, devolve o perfil sanitizado
 * pronto para escrever em disco (so metadados/estatisticas — Secao 12).
 */
export function perfilarCorpus({ bank, subject, bancaAlvoNormalizada, questoesRaw, recentYearWindow, anoAtual, idsComProvenienciaConfirmada = new Set() }) {
  const questoesClassificadas = questoesRaw.map((q) => ({
    id: q.id,
    proveniencia: classificarProveniencia(q, { bancaAlvoNormalizada, bancaAlvoOriginal: bank, idsComProvenienciaConfirmada }),
    tier: classificarTier(q, { anoAtual, recentYearWindow }),
    ano: q.ano ?? null,
    features: extrairFeaturesQuestao(q),
  }));

  const perfil = construirPerfilBanca({ bank, subject, questoesClassificadas, recentYearWindow, anoAtual });
  return { perfil, questoesClassificadas };
}
