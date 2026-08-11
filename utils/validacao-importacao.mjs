// Detecta o padrão de corrupção observado nas questões 877/882/889/890:
// o importador tratou os primeiros itens a)/b)/c)/d) de uma enumeração
// interna do texto-base (ex.: uma lista legal citada no enunciado) como se
// fossem as alternativas da questão, truncando o enunciado e concatenando
// o restante do texto-base + comando + alternativas reais numa única
// alternativa (tipicamente a E).

function normalizarTexto(valor) {
  return typeof valor === "string" ? valor : "";
}

// "Completa": os quatro marcadores aparecem na ordem certa no mesmo campo —
// sinal forte por si só (uma alternativa legítima nunca precisa conter
// a)/b)/c)/d) em sequência).
const SEQUENCIA_COMPLETA = /a\)[\s\S]*?b\)[\s\S]*?c\)[\s\S]*?d\)/i;

// "Parcial": só três dos quatro marcadores em sequência (a-b-c ou b-c-d).
// Mais fraco isoladamente — uma referência jurídica pode conter "a)" e,
// raramente, também "b)" próximos sem ser o mesmo defeito.
const SEQUENCIA_PARCIAL_ABC = /a\)[\s\S]*?b\)[\s\S]*?c\)/i;
const SEQUENCIA_PARCIAL_BCD = /b\)[\s\S]*?c\)[\s\S]*?d\)/i;

export function detectaSequenciaAlternativasEmbutida(texto) {
  const valor = normalizarTexto(texto);
  if (!valor) {
    return { completa: false, parcial: false };
  }
  const completa = SEQUENCIA_COMPLETA.test(valor);
  const parcial = completa || SEQUENCIA_PARCIAL_ABC.test(valor) || SEQUENCIA_PARCIAL_BCD.test(valor);
  return { completa, parcial };
}

const LIMITE_TAMANHO_ITEM_ENUMERACAO = 120;

function pareceItemDeEnumeracao(texto) {
  const valor = normalizarTexto(texto).trim();
  if (!valor || valor.length > LIMITE_TAMANHO_ITEM_ENUMERACAO) return false;
  const primeiraLetra = valor.charAt(0);
  const comecaMinuscula =
    primeiraLetra !== "" &&
    primeiraLetra === primeiraLetra.toLowerCase() &&
    primeiraLetra !== primeiraLetra.toUpperCase();
  return comecaMinuscula && valor.endsWith(";");
}

function enunciadoIntroduzEnumeracao(enunciado) {
  return normalizarTexto(enunciado).trim().endsWith(":");
}

function alternativaEAnormalmenteLonga(alternativaA, alternativaB, alternativaC, alternativaD, alternativaE) {
  const tamanhoE = normalizarTexto(alternativaE).trim().length;
  if (tamanhoE === 0) return false;
  const tamanhos = [alternativaA, alternativaB, alternativaC, alternativaD]
    .map((texto) => normalizarTexto(texto).trim().length)
    .filter((tamanho) => tamanho > 0);
  if (tamanhos.length === 0) return tamanhoE > 300;
  const media = tamanhos.reduce((soma, tamanho) => soma + tamanho, 0) / tamanhos.length;
  return tamanhoE > 300 && tamanhoE > media * 3;
}

// linha: { enunciado, alternativa_a, alternativa_b, alternativa_c, alternativa_d, alternativa_e }
export function validarLinhaImportacao(linha) {
  const enunciado = normalizarTexto(linha?.enunciado);
  const alternativaA = normalizarTexto(linha?.alternativa_a);
  const alternativaB = normalizarTexto(linha?.alternativa_b);
  const alternativaC = normalizarTexto(linha?.alternativa_c);
  const alternativaD = normalizarTexto(linha?.alternativa_d);
  const alternativaE = normalizarTexto(linha?.alternativa_e);

  const alternativasNomeadas = [
    ["A", alternativaA],
    ["B", alternativaB],
    ["C", alternativaC],
    ["D", alternativaD],
    ["E", alternativaE],
  ];

  const erros = [];
  const avisos = [];

  // Sinal forte: procura em TODAS as alternativas (não só E) porque o
  // campo onde o excesso de texto acaba pode variar.
  let letraComSequenciaCompleta = null;
  let letraComSequenciaParcial = null;
  for (const [letra, texto] of alternativasNomeadas) {
    const { completa, parcial } = detectaSequenciaAlternativasEmbutida(texto);
    if (completa && !letraComSequenciaCompleta) letraComSequenciaCompleta = letra;
    if (parcial && !letraComSequenciaParcial) letraComSequenciaParcial = letra;
  }

  // Sinais fracos — corroboram o sinal forte, mas nunca bloqueiam sozinhos.
  const enunciadoPareceIntroduzirLista = enunciadoIntroduzEnumeracao(enunciado);
  const quantosItensParecemEnumeracao = [alternativaA, alternativaB, alternativaC, alternativaD].filter(
    pareceItemDeEnumeracao,
  ).length;
  const alternativasParecemEnumeracao = quantosItensParecemEnumeracao >= 3;
  const alternativaELonga = alternativaEAnormalmenteLonga(
    alternativaA,
    alternativaB,
    alternativaC,
    alternativaD,
    alternativaE,
  );

  if (letraComSequenciaCompleta) {
    // Padrão forte sozinho já basta: uma alternativa com a)...b)...c)...d)
    // em sequência não tem explicação legítima plausível.
    erros.push(
      `Possível quebra de parsing: a alternativa ${letraComSequenciaCompleta} contém uma sequência completa de marcadores a)/b)/c)/d), indicando que texto-base e alternativas podem ter sido concatenados.`,
    );
  } else if (
    letraComSequenciaParcial &&
    (enunciadoPareceIntroduzirLista || alternativasParecemEnumeracao || alternativaELonga)
  ) {
    // Padrão forte parcial precisa de corroboração para virar bloqueio.
    erros.push(
      `Possível quebra de parsing: a alternativa ${letraComSequenciaParcial} contém uma sequência parcial de marcadores a)/b)/c)/d) (ex.: a)...b)...c)), combinada com outros sinais de enumeração no enunciado/alternativas A-D — texto-base e alternativas podem ter sido concatenados.`,
    );
  } else if (letraComSequenciaParcial) {
    avisos.push(
      `Aviso: a alternativa ${letraComSequenciaParcial} contém uma possível sequência parcial de marcadores (ex.: a)...b)...c)) — verifique se o campo não mistura texto-base com a alternativa real.`,
    );
  }

  // Sinais fracos isolados (sem sequência nenhuma) só geram aviso.
  if (!letraComSequenciaCompleta && !letraComSequenciaParcial) {
    if (enunciadoPareceIntroduzirLista) {
      avisos.push(
        'Aviso: o enunciado termina introduzindo uma enumeração (":") — confirme se as alternativas A-D não são, na verdade, itens dessa lista.',
      );
    }
    if (alternativasParecemEnumeracao) {
      avisos.push(
        'Aviso: as alternativas A-D têm formato de itens de uma lista/enumeração (frases curtas, começando em minúscula, terminando em ";") — confirme se não pertencem ao texto-base em vez de serem as alternativas reais.',
      );
    }
    if (alternativaELonga) {
      avisos.push(
        "Aviso: a alternativa E está muito mais longa que as demais — verifique se não contém texto-base/comando concatenados.",
      );
    }
  }

  return {
    bloqueante: erros.length > 0,
    erros,
    avisos,
  };
}
