import assert from "node:assert/strict";
import test from "node:test";
import { reconstruirDocumentoPosicionado } from "../scripts/importador-provas/lib/extrairTextoPdfPosicionado.mjs";

// PAPIRO — Extração de PDF orientada por coordenadas X/Y. Fixtures 100%
// sintéticas (itens {texto,x,y,largura,altura} construídos à mão) —
// nenhum conteúdo de ACAFE/FEPESE real. Página típica = 580 de largura
// (próximo da largura real observada em A4 nos PDFs reais testados).

const LARGURA_PAGINA = 580;

// Jitter sub-pixel automático e crescente: dados reais de posição de
// PDF nunca repetem o mesmo float entre linhas diferentes (confirmado
// nos documentos reais testados). Sem isto, vários itens de teste com
// "o mesmo x" colapsariam num único valor ao deduplicar na detecção de
// colunas (clustersPorGap), subestimando artificialmente quantas linhas
// cada coluna tem — um artefato só do fixture, nunca da produção.
let contadorJitter = 0;
function item(texto, x, y, largura = texto.length * 6, altura = 10) {
  contadorJitter += 1;
  return { texto, x: x + contadorJitter * 0.001, y, largura, altura };
}

function pagina(numero, itens) {
  return { numero, larguraPagina: LARGURA_PAGINA, itens };
}

test("A) página de UMA coluna: linhas ficam na ordem simples de Y, sem nenhuma divisão", () => {
  const doc = [
    pagina(1, [
      item("Linha um", 50, 700),
      item("Linha dois", 50, 680),
      item("Linha tres", 50, 660),
    ]),
  ];
  const resultado = reconstruirDocumentoPosicionado(doc);
  assert.equal(resultado.deteccaoColunas.totalColunas, 1);
  assert.equal(resultado.paginas[0].texto, "Linha um\nLinha dois\nLinha tres");
});

test("B) DUAS COLUNAS perfeitas: coluna esquerda inteira antes da direita, mesmo com uma linha coincidindo em Y entre as colunas", () => {
  // Realista (como o documento real testado): a maioria das linhas de
  // cada coluna tem sua própria altura Y, só uma coincide entre as
  // colunas (ex.: ambas começam no topo da página). Suficientes linhas
  // de cada lado para confiança alta.
  const itens = [];
  for (let i = 0; i < 6; i++) itens.push(item(`Esquerda ${i}`, 50, 700 - i * 20));
  for (let i = 0; i < 6; i++) itens.push(item(`Direita ${i}`, 350, 700 - i * 22));
  const doc = [pagina(1, itens)];
  const resultado = reconstruirDocumentoPosicionado(doc);
  assert.equal(resultado.deteccaoColunas.totalColunas, 2);
  assert.equal(resultado.deteccaoColunas.confidence, "alta");
  const linhas = resultado.paginas[0].texto.split("\n");
  assert.deepEqual(linhas.slice(0, 6), ["Esquerda 0", "Esquerda 1", "Esquerda 2", "Esquerda 3", "Esquerda 4", "Esquerda 5"]);
  assert.deepEqual(linhas.slice(6), ["Direita 0", "Direita 1", "Direita 2", "Direita 3", "Direita 4", "Direita 5"]);
});

test("C) TÍTULO FULL-WIDTH + duas colunas: título sai primeiro, intacto, sem ser dividido entre colunas", () => {
  const itens = [item("Título do Documento Inteiro Bem Largo", 40, 740, 500)];
  for (let i = 0; i < 4; i++) {
    itens.push(item(`Esquerda ${i}`, 50, 700 - i * 20));
    itens.push(item(`Direita ${i}`, 350, 700 - i * 20));
  }
  const doc = [pagina(1, itens)];
  const resultado = reconstruirDocumentoPosicionado(doc);
  const linhas = resultado.paginas[0].texto.split("\n");
  assert.equal(linhas[0], "Título do Documento Inteiro Bem Largo");
  assert.ok(linhas.slice(1, 5).every((l) => l.startsWith("Esquerda")));
  assert.ok(linhas.slice(5).every((l) => l.startsWith("Direita")));
});

test("D) RODAPÉ FULL-WIDTH: aparece por último, depois das duas colunas", () => {
  const itens = [];
  for (let i = 0; i < 4; i++) {
    itens.push(item(`Esquerda ${i}`, 50, 700 - i * 20));
    itens.push(item(`Direita ${i}`, 350, 700 - i * 20));
  }
  itens.push(item("Rodapé Full Width Bem Largo Até o Fim", 40, 50, 500));
  const doc = [pagina(1, itens)];
  const resultado = reconstruirDocumentoPosicionado(doc);
  const linhas = resultado.paginas[0].texto.split("\n");
  assert.equal(linhas.at(-1), "Rodapé Full Width Bem Largo Até o Fim");
});

test("E) linhas desalinhadas alguns pixels (ex.: 1-2pt de diferença de baseline) ainda agrupam na mesma linha visual", () => {
  const itens = [
    item("Parte A", 50, 700.0, 42),
    item("Parte B", 100, 701.5, 42), // 1.5pt de diferença de Y (baseline) — dentro da tolerância proporcional à altura; gap X normal de palavra, não de coluna
  ];
  const doc = [pagina(1, itens)];
  const resultado = reconstruirDocumentoPosicionado(doc);
  assert.equal(resultado.paginas[0].texto, "Parte A Parte B");
});

test("F) palavras fragmentadas em vários itens são reconstruídas com espaçamento correto, sem juntar nem separar demais", () => {
  const itens = [
    item("O", 50, 700, 6),
    item(" ", 56, 700, 3),
    item("rato", 59, 700, 20),
    item(" ", 79, 700, 3),
    item("roeu", 82, 700, 22),
    item(" ", 104, 700, 3),
    item("a", 107, 700, 6),
    item(" ", 113, 700, 3),
    item("roupa", 116, 700, 28),
  ];
  const doc = [pagina(1, itens)];
  const resultado = reconstruirDocumentoPosicionado(doc);
  assert.equal(resultado.paginas[0].texto, "O rato roeu a roupa");
});

test("G) coluna esquerda mais longa que a direita: direita termina, mas a ordem de leitura continua correta", () => {
  const itens = [];
  for (let i = 0; i < 6; i++) itens.push(item(`Esquerda ${i}`, 50, 700 - i * 20));
  // Y numa faixa própria (não coincide com a esquerda) — só 2 linhas,
  // mas suficientes/distinguíveis para a direita ser reconhecida como
  // coluna própria.
  for (let i = 0; i < 2; i++) itens.push(item(`Direita ${i}`, 350, 500 - i * 20));
  const doc = [pagina(1, itens)];
  const resultado = reconstruirDocumentoPosicionado(doc);
  const linhas = resultado.paginas[0].texto.split("\n");
  assert.equal(linhas.length, 8);
  assert.deepEqual(linhas.slice(0, 6), ["Esquerda 0", "Esquerda 1", "Esquerda 2", "Esquerda 3", "Esquerda 4", "Esquerda 5"]);
  assert.deepEqual(linhas.slice(6), ["Direita 0", "Direita 1"]);
});

test("H) coluna direita mais longa que a esquerda: mesma garantia, na direção oposta", () => {
  const itens = [];
  for (let i = 0; i < 2; i++) itens.push(item(`Esquerda ${i}`, 50, 700 - i * 20));
  for (let i = 0; i < 6; i++) itens.push(item(`Direita ${i}`, 350, 700 - i * 20));
  const doc = [pagina(1, itens)];
  const resultado = reconstruirDocumentoPosicionado(doc);
  const linhas = resultado.paginas[0].texto.split("\n");
  assert.equal(linhas.length, 8);
  assert.deepEqual(linhas.slice(0, 2), ["Esquerda 0", "Esquerda 1"]);
  assert.deepEqual(linhas.slice(2), ["Direita 0", "Direita 1", "Direita 2", "Direita 3", "Direita 4", "Direita 5"]);
});

test("I) lista numerada DENTRO do enunciado (ex.: '1. ... 2. ... 3. ...' na mesma coluna) nunca é confundida com conteúdo de outra coluna", () => {
  const itens = [
    item("8. Analise as afirmativas:", 50, 700, 150),
    item("1. Primeira afirmativa.", 50, 680, 140),
    item("2. Segunda afirmativa.", 50, 660, 140),
    item("3. Terceira afirmativa.", 50, 640, 140),
    // A maioria das linhas da direita fica numa faixa de Y própria (como
    // no documento real) — só a primeira coincide com a esquerda, para
    // também cobrir o caso de uma linha fundida em meio a outras não
    // fundidas.
    item("Direita 0", 350, 700),
    item("Direita 1", 350, 500),
    item("Direita 2", 350, 480),
    item("Direita 3", 350, 460),
  ];
  const doc = [pagina(1, itens)];
  const resultado = reconstruirDocumentoPosicionado(doc);
  const linhas = resultado.paginas[0].texto.split("\n");
  // As 4 primeiras linhas (questão 8 + sua lista interna) ficam juntas,
  // na própria coluna — nunca misturadas com "Direita 0"/"Direita 1".
  assert.deepEqual(linhas.slice(0, 4), [
    "8. Analise as afirmativas:",
    "1. Primeira afirmativa.",
    "2. Segunda afirmativa.",
    "3. Terceira afirmativa.",
  ]);
});

test("J) questão atravessando página: cada página é reconstruída independentemente, mas o texto concatenado preserva a continuidade", () => {
  const doc = [
    pagina(1, [item("9. Esta questão começa aqui e continua", 50, 700, 300)]),
    pagina(2, [item("na página seguinte, sem se perder.", 50, 740, 300)]),
  ];
  const resultado = reconstruirDocumentoPosicionado(doc);
  assert.equal(resultado.paginas.length, 2);
  assert.equal(resultado.paginas[0].texto, "9. Esta questão começa aqui e continua");
  assert.equal(resultado.paginas[1].texto, "na página seguinte, sem se perder.");
});

test("K) confiança baixa quando um lado do split tem poucas linhas — nunca força split pouco confiável como se fosse definitivo", () => {
  // Y's separados (nunca coincidem) para que cada lado contribua seu
  // próprio início de linha ao conjunto de detecção — só 1 linha de
  // cada lado, abaixo do mínimo para confiança alta.
  const itens = [item("Esquerda unica", 50, 700), item("Direita unica", 350, 500)];
  const doc = [pagina(1, itens)];
  const resultado = reconstruirDocumentoPosicionado(doc);
  assert.equal(resultado.deteccaoColunas.totalColunas, 2);
  assert.equal(resultado.deteccaoColunas.confidence, "baixa");
});

test("L) debug opcional expõe coluna/ordem por linha, sem versionar nenhum conteúdo real", () => {
  const itens = [];
  for (let i = 0; i < 3; i++) itens.push(item(`Esquerda ${i}`, 50, 700 - i * 20));
  for (let i = 0; i < 3; i++) itens.push(item(`Direita ${i}`, 350, 500 - i * 20)); // faixa de Y totalmente separada da esquerda — nunca coincide
  const doc = [pagina(1, itens)];
  const resultado = reconstruirDocumentoPosicionado(doc, { debug: true });
  assert.ok(Array.isArray(resultado.debug));
  assert.equal(resultado.debug[0].linhas.length, 6);
  assert.ok(resultado.debug[0].linhas.every((l) => typeof l.coluna === "number" && typeof l.ordem === "number"));
});

test("PB-A) layout \"ponte\" (inícios recuados/centralizados entre as colunas + rótulo isolado na borda): colunas por picos, título centralizado na coluna direita e cabeçalho de margem inteiros", () => {
  const itens = [item("CABECALHO ESQUERDO", 40, 820), item("LOGO DA BANCA", 470, 820)];
  for (let i = 0; i < 12; i++) {
    const y = 760 - i * 12;
    // Coluna esquerda mais curta: abaixo dela, a direita começa linhas sozinha (como nas provas reais).
    if (i < 6) itens.push(item(`esquerda linha ${i + 1}`, 40, y));
    itens.push(item(`direita linha ${i + 1}`, 310, y));
  }
  // Inícios intermediários (títulos centralizados/recuos) que formavam a "ponte".
  [70, 130, 160, 190, 220, 250, 280].forEach((x, i) => itens.push(item(`recuo ${i + 1}`, x, 600 - i * 12)));
  // Título centralizado na coluna direita, na mesma altura de texto da esquerda.
  itens.push(item("titulo do texto esquerdo", 100, 780), item("Titulo Centralizado Direita", 360, 780));
  const paginas = [1, 2, 3].map((n) => ({ numero: n, larguraPagina: LARGURA_PAGINA, alturaPagina: 842, itens: itens.map((i) => ({ ...i, x: i.x + n * 0.0001 })) }));
  const { paginas: saida, deteccaoColunas } = reconstruirDocumentoPosicionado(paginas);
  assert.equal(deteccaoColunas.totalColunas, 2);
  const linhas = saida[0].texto.split("\n");
  assert.match(linhas[0], /^CABECALHO ESQUERDO\s+LOGO DA BANCA$/, "linha de margem não é dividida por coluna");
  const posicao = (t) => linhas.findIndex((l) => l.includes(t));
  assert.ok(posicao("esquerda linha 6") < posicao("Titulo Centralizado Direita"), "título da direita vem depois de toda a coluna esquerda");
  assert.ok(posicao("Titulo Centralizado Direita") < posicao("direita linha 1"));
  assert.ok(!linhas.some((l) => /esquerda linha .*direita linha/.test(l)), "nenhuma linha mistura as duas colunas");
});

test("PB-B) linha só de espaço não vira linha em branco no meio do texto", () => {
  const { paginas } = reconstruirDocumentoPosicionado([pagina(1, [item("primeira parte da frase", 40, 700), item(" ", 40, 688, 3), item("continua aqui", 40, 676)])]);
  assert.equal(paginas[0].texto, "primeira parte da frase\ncontinua aqui");
});

test("PB-C) leitura forçada em 1 coluna: ordem estritamente de cima para baixo, mesmo com inícios de linha espalhados", () => {
  const itens = [item("terceira linha", 300, 676), item("primeira linha", 40, 700), item("segunda linha", 200, 688)];
  const { paginas } = reconstruirDocumentoPosicionado([pagina(1, itens)], { umaColuna: true });
  assert.equal(paginas[0].texto, "primeira linha\nsegunda linha\nterceira linha");
});
