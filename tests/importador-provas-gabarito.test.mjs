import assert from "node:assert/strict";
import test from "node:test";
import { textoDeGabaritoHtml } from "../scripts/importador-provas/lib/gabaritoHtml.mjs";
import { extrairGabaritoDoTexto } from "../scripts/importador-provas/lib/extrairGabarito.mjs";

// PAPIRO — PoC do importador de provas: extração do gabarito oficial.
// Fixture 100% sintética.

test("A) gabarito normal: 'N - LETRA' por linha, uma entrada por questão", () => {
  const texto = ["1 - A", "2 - B", "3 - C", "4 - D"].join("\n");
  const { gabaritos } = extrairGabaritoDoTexto(texto);
  assert.deepEqual(
    gabaritos.map((g) => [g.numero, g.alternativa_correta, g.anulada, g.status]),
    [
      [1, "A", false, "ok"],
      [2, "B", false, "ok"],
      [3, "C", false, "ok"],
      [4, "D", false, "ok"],
    ],
  );
});

test("B) aceita variações de separador ('.', ')', ':') e espaçamento", () => {
  const texto = ["1. A", "2) B", "3: C"].join("\n");
  const { gabaritos } = extrairGabaritoDoTexto(texto);
  assert.deepEqual(gabaritos.map((g) => g.alternativa_correta), ["A", "B", "C"]);
});

test("C) questão anulada: ANULADA/ANULADO nunca gera alternativa_correta — nunca inferido", () => {
  const texto = ["1 - A", "2 - ANULADA", "3 - B"].join("\n");
  const { gabaritos } = extrairGabaritoDoTexto(texto);
  const q2 = gabaritos.find((g) => g.numero === 2);
  assert.equal(q2.anulada, true);
  assert.equal(q2.alternativa_correta, null);
  assert.equal(q2.status, "ok");
});

test("D) questão alterada: observação é preservada e a flag 'alterada' é marcada", () => {
  const texto = ["1 - C (alterado de B para C conforme recurso)"].join("\n");
  const { gabaritos } = extrairGabaritoDoTexto(texto);
  const q1 = gabaritos[0];
  assert.equal(q1.alternativa_correta, "C");
  assert.equal(q1.alterada, true);
  assert.match(q1.observacao, /alterado de B para C/);
});

test("E) linha não reconhecida (ex.: cabeçalho) não gera gabarito, mas é registrada em naoReconhecidas", () => {
  const texto = ["GABARITO OFICIAL - PROVA DE TESTE", "1 - A"].join("\n");
  const { gabaritos, naoReconhecidas } = extrairGabaritoDoTexto(texto);
  assert.equal(gabaritos.length, 1);
  assert.ok(naoReconhecidas.some((linha) => linha.includes("GABARITO OFICIAL")));
});

test("F) número de gabarito duplicado no próprio documento é marcado revisao_manual, nunca escolhido arbitrariamente", () => {
  const texto = ["1 - A", "1 - B"].join("\n");
  const { gabaritos } = extrairGabaritoDoTexto(texto);
  const duplicada = gabaritos.find((g) => g.status === "revisao_manual");
  assert.ok(duplicada, "esperava alguma entrada marcada revisao_manual pelo número duplicado");
  assert.match(duplicada.observacao ?? "", /numero de gabarito duplicado/);
});

test("G) gabarito vazio/ausente devolve lista vazia, nunca lança erro", () => {
  const { gabaritos, naoReconhecidas } = extrairGabaritoDoTexto("");
  assert.deepEqual(gabaritos, []);
  assert.deepEqual(naoReconhecidas, []);
});

test("H) gabarito tabular de 2 colunas (sem separador explícito, tipo PDF-para-texto): cada linha gera 2 entradas", () => {
  const texto = ["N. Questão \tAlternativa \tN. Questão \tAlternativa", "01 \tD \t41 \tA", "09 \tB \t49 \tANULADA"].join("\n");
  const { gabaritos, naoReconhecidas } = extrairGabaritoDoTexto(texto);
  assert.equal(naoReconhecidas.length, 1, "o cabeçalho da tabela não tem nenhum par número/letra e deve ir para naoReconhecidas");
  assert.deepEqual(
    gabaritos.map((g) => [g.numero, g.alternativa_correta, g.anulada]),
    [
      [1, "D", false],
      [41, "A", false],
      [9, "B", false],
      [49, null, true],
    ],
  );
});

test("I) gabarito tabular de 4 colunas (2 pares por linha, repetido) generaliza sem ajuste nenhum", () => {
  const texto = ["01 A 21 B 41 C 61 D", "02 B 22 C 42 D 62 A"].join("\n");
  const { gabaritos } = extrairGabaritoDoTexto(texto);
  assert.equal(gabaritos.length, 8);
  assert.deepEqual(gabaritos.map((g) => g.numero), [1, 21, 41, 61, 2, 22, 42, 62]);
});

test("J) linha tabular com múltiplos pares nunca gera observação/alterada (não há texto livre nesse formato)", () => {
  const texto = ["01 \tD \t41 \tA"].join("\n");
  const { gabaritos } = extrairGabaritoDoTexto(texto);
  for (const item of gabaritos) {
    assert.equal(item.alterada, false);
    assert.equal(item.observacao, null);
  }
});

test("K) grade posicional (linha de números + linha de respostas alinhada) é reconhecida — formato visto em prova real (FEPESE/PMBC 2014)", () => {
  const texto = ["1 2 3 4 5", "e c d b a"].join("\n");
  const { gabaritos } = extrairGabaritoDoTexto(texto);
  assert.deepEqual(
    gabaritos.map((g) => [g.numero, g.alternativa_correta, g.anulada]),
    [
      [1, "E", false],
      [2, "C", false],
      [3, "D", false],
      [4, "B", false],
      [5, "A", false],
    ],
  );
});

test("L) 'X' na linha de respostas da grade posicional significa anulada — nunca inferido como alternativa", () => {
  const texto = ["1 2 3", "a x c"].join("\n");
  const { gabaritos } = extrairGabaritoDoTexto(texto);
  const q2 = gabaritos.find((g) => g.numero === 2);
  assert.equal(q2.anulada, true);
  assert.equal(q2.alternativa_correta, null);
});

test("M) MÚLTIPLOS blocos posicionais no mesmo documento (dois cargos, cada um com sua própria grade 1..N) — números repetidos entre blocos NUNCA são tratados como duplicados", () => {
  const texto = ["GM - Guarda Municipal", "1 2 3", "a b c", "AR - Armeiro", "1 2 3", "c b a"].join("\n");
  const { gabaritos } = extrairGabaritoDoTexto(texto);
  assert.equal(gabaritos.length, 6);
  assert.ok(gabaritos.every((g) => g.status === "ok"), "números repetidos entre BLOCOS DIFERENTES não devem virar revisao_manual");
  const gm = gabaritos.filter((g) => g.bloco === "GM - Guarda Municipal");
  const ar = gabaritos.filter((g) => g.bloco === "AR - Armeiro");
  assert.deepEqual(gm.map((g) => g.alternativa_correta), ["A", "B", "C"]);
  assert.deepEqual(ar.map((g) => g.alternativa_correta), ["C", "B", "A"]);
});

test("N) quantidade de números e de respostas DIVERGENTE na grade posicional -> bloco inteiro não é pareado, linhas voltam para naoReconhecidas (nunca pareamento por aproximação)", () => {
  const texto = ["1 2 3 4 5", "a b c"].join("\n"); // 5 números, só 3 respostas
  const { gabaritos, naoReconhecidas } = extrairGabaritoDoTexto(texto);
  assert.equal(gabaritos.length, 0);
  assert.ok(naoReconhecidas.includes("1 2 3 4 5"));
});

test("O) resposta inválida na grade posicional (ex.: letra fora de A-E/X) impede o reconhecimento da linha como grade de respostas", () => {
  const texto = ["1 2 3", "a z c"].join("\n"); // "z" não é uma letra válida
  const { gabaritos, naoReconhecidas } = extrairGabaritoDoTexto(texto);
  assert.equal(gabaritos.length, 0);
  assert.ok(naoReconhecidas.includes("1 2 3"));
});

test("P) número duplicado DENTRO do mesmo bloco posicional é marcado revisao_manual (diferente de duplicado entre blocos distintos)", () => {
  const texto = ["1 1 2", "a b c"].join("\n");
  const { gabaritos } = extrairGabaritoDoTexto(texto);
  const duplicados = gabaritos.filter((g) => g.numero === 1);
  assert.equal(duplicados.length, 2);
  assert.ok(duplicados.some((g) => g.status === "revisao_manual"));
});

test("Q) rótulo de bloco só é reconhecido quando IMEDIATAMENTE seguido de uma linha de números — texto solto não vira bloco por engano", () => {
  const texto = ["Isto é só um parágrafo qualquer de instruções.", "Mais texto livre aqui.", "1 2 3", "a b c"].join("\n");
  const { gabaritos } = extrairGabaritoDoTexto(texto);
  // "Mais texto livre aqui." é a linha IMEDIATAMENTE antes da grade —
  // só ela poderia virar rótulo; a primeira linha nunca é usada como tal.
  assert.deepEqual([...new Set(gabaritos.map((g) => g.bloco))], ["Mais texto livre aqui."]);
});

test("R) grade tabular de VÁRIOS cargos ('24 - Cargo X' + linhas '01 - B 02 - E'): cada cargo vira um bloco rotulado, '*' é anulada e pares acidentais da prosa ficam sem bloco — caso real Fundatec/PP-RS 2026", () => {
  const texto = [
    "Justificativa sintética: conforme a Lei 13.146/2015) e demais normas, mantém-se o gabarito.",
    "ANEXO II Gabaritos Definitivos",
    "23 - Cargo Sintético Um",
    "01 - B 02 - E 03 - A",
    "04 - C 05 - D 06 - A",
    "Assinatura Eletrônica: 123.45",
    "24 - Cargo Sintético Dois",
    "01 - C 02 - * 03 - D",
    "04 - E 05 - A 06 - *",
    "(*) Questão(ões) anulada(s) - a pontuação será revertida a todos os candidatos",
  ].join("\n");
  const { gabaritos } = extrairGabaritoDoTexto(texto);
  const dois = gabaritos.filter((g) => g.bloco === "24 - Cargo Sintético Dois");
  assert.deepEqual(
    dois.map((g) => [g.numero, g.alternativa_correta, g.anulada]),
    [[1, "C", false], [2, null, true], [3, "D", false], [4, "E", false], [5, "A", false], [6, null, true]],
  );
  assert.equal(gabaritos.filter((g) => g.bloco === "23 - Cargo Sintético Um").length, 6);
  assert.ok(gabaritos.filter((g) => g.bloco !== null).every((g) => g.status === "ok"), "números repetidos entre cargos diferentes não são duplicados");
  const soltos = gabaritos.filter((g) => g.bloco === null);
  assert.deepEqual(soltos.map((g) => g.numero), [], "o par acidental da prosa ('2015) e') nunca vira entrada");
});

test("S) grade tabular de UM cargo só, mesmo partida em duas corridas (quebra de página), continua bloco=null como antes", () => {
  const texto = ["GABARITO", "01 - B 02 - E", "-- 1 of 2 --", "03 - A 04 - C"].join("\n");
  const { gabaritos } = extrairGabaritoDoTexto(texto);
  assert.deepEqual(gabaritos.map((g) => [g.numero, g.bloco, g.status]), [[1, null, "ok"], [2, null, "ok"], [3, null, "ok"], [4, null, "ok"]]);
});

test("T) grade posicional com várias faixas por cargo: a linha de letras nunca vira rótulo da faixa seguinte — cada cargo recebe todas as questões", () => {
  const texto = ["CARGO X - TIPO 1", "1 2 3", "A B C", "4 5 6", "D E A", "CARGO Y - TIPO 1", "1 2 3", "E D C", "4 5 6", "B A E"].join("\n");
  const { gabaritos } = extrairGabaritoDoTexto(texto);
  const doBloco = (b) => gabaritos.filter((g) => g.bloco === b).map((g) => `${g.numero}${g.alternativa_correta}`);
  assert.deepEqual(doBloco("CARGO X - TIPO 1"), ["1A", "2B", "3C", "4D", "5E", "6A"]);
  assert.deepEqual(doBloco("CARGO Y - TIPO 1"), ["1E", "2D", "3C", "4B", "5A", "6E"]);
});

test("U) grade posicional com \"*\" (anulada) na linha de respostas: a faixa é lida inteira e o \"*\" vira anulada", () => {
  const { gabaritos } = extrairGabaritoDoTexto(["01 02 03", "A C E", "04 05 06", "B * D"].join("\n"));
  assert.deepEqual(gabaritos.map((g) => `${g.numero}${g.anulada ? "*" : g.alternativa_correta}`), ["1A", "2C", "3E", "4B", "5*", "6D"]);
});

test("GRADE-SEQ) célula única impressa errada no cabeçalho da grade ('72 33 74'): número deduzido pela posição, com registro; a questão 33 não ganha segunda resposta", () => {
  const linhas = (de, letras) => [Array.from({ length: 20 }, (_, i) => de + i).join(" "), letras.join(" ")];
  const L = (s) => s.split("");
  const texto = [
    "BLOCO SINTÉTICO – TIPO 1",
    ...linhas(1, L("ABCDEABCDEABCDEABCDE")),
    ...linhas(21, L("BCDEABCDEABCDEABCDEA")),
    ...linhas(41, L("CDEABCDEABCDEABCDEAB")),
    "61 62 63 64 65 66 67 68 69 70 71 72 33 74 75 76 77 78 79 80",
    "D E A B C D E A B C D E A B C D E A B *",
  ].join("\n");
  const { gabaritos } = extrairGabaritoDoTexto(texto);
  const g = (n) => gabaritos.filter((x) => x.numero === n);
  assert.equal(g(33).length, 1);
  assert.equal(g(33)[0].alternativa_correta, "D");
  assert.equal(g(73).length, 1);
  assert.equal(g(73)[0].alternativa_correta, "A");
  assert.equal(g(73)[0].status, "ok");
  assert.deepEqual(g(73)[0].numero_deduzido, { impresso: 33, deduzido: 73 });
  assert.match(g(73)[0].observacao, /impresso na grade "33"; deduzido 73/);
  assert.equal(gabaritos.length, 80);
});

test("GRADE-SEQ2) sem dedução quando não é inequívoco: duas células fora da sequência, ou número deduzido já respondido no bloco", () => {
  const duas = extrairGabaritoDoTexto(["X", "1 2 9 4 8 6", "A B C D E A"].join("\n")).gabaritos;
  assert.deepEqual(duas.map((x) => x.numero), [1, 2, 9, 4, 8, 6]);
  assert.ok(duas.every((x) => !x.numero_deduzido));
  // A posição pede o 3, que já tem resposta no bloco: nada deduzido, o "77" fica como impresso.
  const jaExiste = extrairGabaritoDoTexto(["X", "3 4 5 6", "A B C D", "1 2 77 4", "A B C D"].join("\n")).gabaritos;
  assert.ok(jaExiste.every((x) => !x.numero_deduzido));
  assert.equal(jaExiste.filter((x) => x.numero === 77).length, 1);
});

// ------------------------------------------------ gabarito em página HTML ----

test("HTML-A) página de gabarito (Latin-1, tabela de leiaute aninhada, entidades, script): texto determinístico, uma linha por <tr> folha, anulada '*' preservada", () => {
  const html = [
    "<html><head><script>var x = '<tr><td>99 A</td></tr>';</script><style>td{}</style></head><body>",
    "<table><tr><td>",
    "<table>",
    "<tr><td>Concurso Sint&eacute;tico n&ordm; 01</td></tr>",
    "<tr><td>Quest&atilde;o</td><td>Respostas</td><td>Componente</td></tr>",
    "<tr><td>1</td><td>C</td><td>L&iacute;ngua Portuguesa</td></tr>",
    "<tr><td>2</td><td>*</td><td>Inform&aacute;tica</td></tr>",
    "<tr><td>3</td><td>E</td><td>Racioc&#237;nio L&#xF3;gico</td></tr>",
    "</table>",
    "</td></tr></table><!-- <tr><td>4 A</td></tr> --></body></html>",
  ].join("\n");
  const bytes = Buffer.from(html, "latin1");
  const texto = textoDeGabaritoHtml(bytes);
  assert.equal(texto, ["Concurso Sintético nº 01", "Questão Respostas Componente", "1 C Língua Portuguesa", "2 * Informática", "3 E Raciocínio Lógico", ""].join("\n"));
  assert.equal(textoDeGabaritoHtml(Buffer.from(html, "latin1")), texto, "mesmos bytes -> mesmo texto");
  const { gabaritos } = extrairGabaritoDoTexto(texto);
  assert.deepEqual(gabaritos.map((g) => [g.numero, g.anulada ? "*" : g.alternativa_correta]), [[1, "C"], [2, "*"], [3, "E"]]);
});

test("HTML-B) charset UTF-8 declarado é respeitado; bytes inválidos em UTF-8 sem declaração caem para Latin-1", () => {
  const utf8 = Buffer.from('<meta charset="utf-8"><table><tr><td>7</td><td>B</td><td>Matemática</td></tr></table>', "utf8");
  assert.equal(textoDeGabaritoHtml(utf8), "7 B Matemática\n");
  const latin1 = Buffer.from("<table><tr><td>8</td><td>D</td><td>Física</td></tr></table>", "latin1");
  assert.equal(textoDeGabaritoHtml(latin1), "8 D Física\n");
});
