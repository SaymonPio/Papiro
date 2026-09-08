// Tripwires gramaticais especificos do piloto Concordancia verbal (Fase
// 2A.2.1 + Fase 2B, Secao 21). Extraido do arquivo de teste para o mesmo
// guard poder ser reutilizado tanto pelos testes quanto pelo pipeline real
// de geracao (cli/gerar-questoes.mjs), evitando duas copias divergentes da
// mesma regra de seguranca pedagogica.
//
// Achado real desta sessao: um resumo autoral (nunca o escopo oficial do
// banco) chegou a agrupar "haver/existir/fazer" sob um unico rotulo de
// impessoalidade — impreciso, pois EXISTIR e verbo PESSOAL. Estes guards
// existem para que nenhuma questao gerada (nem nenhum manifesto/resumo
// futuro) repita esse erro, sem depender so de casar a frase exata.
//
// Metodo: divide o texto em clausulas (por . ; ou quebra de linha) e
// analisa cada clausula isoladamente — assim uma descricao correta e
// qualificada de HAVER numa clausula nao e contaminada por uma mencao a
// "impessoal" em outra clausula sobre outro verbo.

function dividirEmClausulas(textoMinusculo) {
  return textoMinusculo
    .split(/[.;\n]/)
    .map((c) => c.trim())
    .filter(Boolean);
}

// Fase 2B.1 — achado real na primeira geracao: uma explicacao correta pode
// estabelecer a condicao de HAVER/FAZER numa clausula ("haver, quando com
// sentido de existir/ocorrer/acontecer, e impessoal") e RETOMAR essa mesma
// condicao por anafora na clausula seguinte ("essa impessoalidade alcanca
// o auxiliar da locucao"), sem repetir "existir/ocorrer/acontecer" ali.
// Isso e valido — nao e uma nova generalizacao, e continuacao da mesma
// frase. Os marcadores abaixo reconhecem essa retomada.
const MARCADORES_ANAFORICOS_IMPESSOALIDADE = [
  "essa impessoalidade",
  "essa mesma impessoalidade",
  "tal impessoalidade",
  "esse uso",
  "esse mesmo uso",
  "essa construção",
  "essa construcao",
  "nessa construção",
  "nessa construcao",
  "esse sentido",
  "esse mesmo sentido",
  "essa condição",
  "essa condicao",
];

/**
 * Falha quando EXISTIR aparece classificado como impessoal — direta ou por
 * agrupamento numa enumeracao contigua com haver/fazer sem qualificar
 * existir como pessoal na mesma clausula.
 */
export function contemAgrupamentoIndevidoExistirImpessoal(texto) {
  const minusculo = (texto || "").toLowerCase();

  const padroesDiretos = [
    /existir\s+(é|eh|e)\s+(um\s+verbo\s+)?impessoal/i,
    /haver,?\s*\/?\s*existir\s*\/?\s*,?\s*(e\s+)?fazer\s+(s[aã]o|e)\s*(verbos\s+)?impessoa(l|is)/i,
  ];
  if (padroesDiretos.some((regex) => regex.test(minusculo))) return true;

  const enumeracaoTresVerbos = /\b(haver|existir|fazer)\b[\s,/]+\b(haver|existir|fazer)\b[\s,/]+(?:e\s+)?\b(haver|existir|fazer)\b/i;
  for (const clausula of dividirEmClausulas(minusculo)) {
    const match = enumeracaoTresVerbos.exec(clausula);
    if (!match) continue;
    const verbosEncontrados = new Set([match[1], match[2], match[3]]);
    if (verbosEncontrados.size !== 3) continue; // precisa ser haver+existir+fazer, sem repeticao
    if (!/\bimpessoa/.test(clausula)) continue;
    const temPessoalExplicito = /(?<!im)pessoal\b/.test(clausula);
    if (!temPessoalExplicito) return true;
  }
  return false;
}

/**
 * Falha quando o verbo (haver/fazer) e apresentado como impessoal sem a
 * condicao que legitima essa classificacao aparecer perto o bastante — a
 * assinatura de "todo uso do verbo e impessoal".
 *
 * "Perto o bastante" e rastreado como uma cadeia que persiste atraves de
 * clausulas NEUTRAS (que nao mencionam impessoalidade nenhuma — ex.: "e
 * permanece na terceira pessoa do singular"), para acompanhar explicacoes
 * reais de varias frases sem exigir que o verbo seja repetido em toda
 * clausula. A cadeia so e cortada quando uma clausula menciona
 * impessoalidade SEM retomar por anafora ("essa impessoalidade"/"esse
 * uso"/etc.) uma condicao ja aberta — o caso mais comum sendo outro verbo
 * (ex.: fazer) sendo descrito no meio do texto, o que nao pode emprestar
 * sua propria condicao para haver (ou vice-versa).
 */
function violaGeneralizacaoImpessoalDoVerbo(texto, verbo, qualificadores) {
  const minusculo = (texto || "").toLowerCase();
  const regexVerbo = new RegExp(`\\b${verbo}\\b`);

  let condicaoEstabelecida = false;

  for (const clausula of dividirEmClausulas(minusculo)) {
    const temImpessoa = /\bimpessoa/.test(clausula);
    if (!temImpessoa) continue; // clausula neutra: nao abre nem fecha a cadeia

    const temVerbo = regexVerbo.test(clausula);
    const retomaAnafora = MARCADORES_ANAFORICOS_IMPESSOALIDADE.some((m) => clausula.includes(m));

    if (temVerbo) {
      const temQualificadorAqui = qualificadores.some((q) => clausula.includes(q));
      if (temQualificadorAqui) {
        condicaoEstabelecida = true;
        continue;
      }
      if (retomaAnafora && condicaoEstabelecida) continue; // retomada legitima da cadeia ja aberta
      return true; // verbo + impessoal sem qualificador nem retomada valida
    }

    // Clausula fala de impessoalidade mas NAO menciona o verbo desta
    // checagem: so mantem a cadeia viva se for uma retomada anaforica
    // explicita (ex.: a MESMA cadeia continuando sem repetir o verbo);
    // caso contrario, presume-se que e sobre outro verbo e fecha a cadeia
    // — nunca deixa uma condicao antiga "vazar" para um assunto novo.
    if (!(retomaAnafora && condicaoEstabelecida)) {
      condicaoEstabelecida = false;
    }
  }

  return false;
}

/**
 * Falha quando HAVER e apresentado como impessoal sem a condicao que
 * legitima essa classificacao (sentido de existir/ocorrer/acontecer)
 * aparecer perto o bastante (mesma clausula, ou retomada anaforica
 * explicita da clausula anterior).
 */
export function violaGeneralizacaoHaverImpessoal(texto) {
  return violaGeneralizacaoImpessoalDoVerbo(texto, "haver", ["existir", "ocorrer", "acontecer"]);
}

/**
 * Falha quando FAZER e apresentado como impessoal sem a condicao que
 * legitima essa classificacao (tempo decorrido/fenomeno atmosferico ou
 * climatico) aparecer perto o bastante (mesma clausula, ou retomada
 * anaforica explicita da clausula anterior).
 */
export function violaGeneralizacaoFazerImpessoal(texto) {
  return violaGeneralizacaoImpessoalDoVerbo(texto, "fazer", [
    "tempo decorrido",
    "fenômeno atmosférico",
    "fenomeno atmosferico",
    "fenômeno climático",
    "fenomeno climatico",
  ]);
}

/**
 * Roda os 3 tripwires de uma vez contra um texto (enunciado+explicacao+
 * fundamento de UMA questao, ou o manifesto/payload inteiro). Usado tanto
 * pelos testes quanto por cli/gerar-questoes.mjs (Secao 21 do mandato da
 * Fase 2B) — nenhuma questao gerada pode virar STRUCTURALLY_VALID_FOR_AUDIT
 * se qualquer um destes falhar.
 *
 * @param {string} textoCompleto
 * @returns {{ existir: "PASS"|"FAIL", haver: "PASS"|"FAIL", fazer: "PASS"|"FAIL", ok: boolean, motivos: string[] }}
 */
export function verificarTripwiresGramaticais(textoCompleto) {
  const existirFalhou = contemAgrupamentoIndevidoExistirImpessoal(textoCompleto);
  const haverFalhou = violaGeneralizacaoHaverImpessoal(textoCompleto);
  const fazerFalhou = violaGeneralizacaoFazerImpessoal(textoCompleto);

  const motivos = [];
  if (existirFalhou) motivos.push("EXISTIR_TRATADO_COMO_IMPESSOAL");
  if (haverFalhou) motivos.push("HAVER_GENERALIZADO_COMO_SEMPRE_IMPESSOAL");
  if (fazerFalhou) motivos.push("FAZER_GENERALIZADO_COMO_SEMPRE_IMPESSOAL");

  return {
    existir: existirFalhou ? "FAIL" : "PASS",
    haver: haverFalhou ? "FAIL" : "PASS",
    fazer: fazerFalhou ? "FAIL" : "PASS",
    ok: motivos.length === 0,
    motivos,
  };
}
