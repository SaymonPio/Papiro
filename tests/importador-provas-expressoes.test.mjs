import assert from "node:assert/strict";
import test from "node:test";
import { aplicarExpressoesAoTexto, alertasDeExpressao, detectarExpressoes } from "../scripts/importador-provas/lib/expressoesPdf.mjs";
import { reconstruirDocumentoPosicionado } from "../scripts/importador-provas/lib/extrairTextoPdfPosicionado.mjs";
import { extrairQuestoesDoTexto } from "../scripts/importador-provas/lib/extrairQuestoes.mjs";
import { normalizarQuestao } from "../scripts/importador-provas/lib/normalizar.mjs";
import { calcularStatus } from "../scripts/importador-provas/lib/score.mjs";

// PAPIRO — expressões matemáticas posicionais. Geometria 100% sintética:
// corpo de 10 pt; numerador/denominador em 7 pt, 5,5 pt acima/abaixo da
// linha de base (mesma relação observada numa prova real, mas números e
// textos inventados).

const BASE = 700;
function item(texto, x, y = BASE, altura = 10) {
  return { texto, x, y, largura: texto.length * (altura / 2), altura };
}

// "Valor: 1/2 , fim" com 1 sobre 2.
// Espaço com altura de corpo, como o extrator posicional entrega (altura
// 0 do PDF vira 10).
function itensFracao(numerador, denominador) {
  return [item("Valor:", 40), { texto: " ", x: 70, y: BASE, largura: 3, altura: 10 }, item(numerador, 75, BASE + 5.5, 7), item(denominador, 75, BASE - 5.5, 7), item(",", 82), item("fim", 92)];
}

test("EX-A) 1/2 empilhado vira uma fração na linha de base (item sintético)", () => {
  const { expressoes, incertas, itens } = detectarExpressoes(itensFracao("1", "2"));
  assert.equal(incertas.length, 0);
  assert.deepEqual(expressoes.map((e) => [e.tipo, e.texto]), [["fracao", "1/2"]]);
  const sintetico = itens.find((i) => i.sintetico === "fracao");
  assert.equal(sintetico.texto, "1/2");
  assert.equal(sintetico.y, BASE);
  assert.ok(!itens.some((i) => i.texto === "1" || i.texto === "2"), "numerador e denominador originais saem dos itens");
});

test("EX-B) 7/2: a forma linear \"7\\n2\" é substituída no texto linear da página; a reconstrução posicional também sai certa", () => {
  const { expressoes, itens } = detectarExpressoes(itensFracao("7", "2"));
  assert.equal(expressoes[0].texto, "7/2");
  const { texto, aplicadas, naoAplicadas } = aplicarExpressoesAoTexto("Valor: 7\n2 , fim", expressoes);
  assert.equal(texto, "Valor: 7/2 , fim");
  assert.equal(aplicadas.length, 1);
  assert.equal(naoAplicadas.length, 0);
  const { paginas } = reconstruirDocumentoPosicionado([{ numero: 1, larguraPagina: 600, itens }]);
  assert.match(paginas[0].texto, /Valor: 7\/2 ?, fim/);
});

test("EX-C) fração dentro de sequência (\"–7, 7/2, –14, 7, X\")", () => {
  const itens = [item("–7,", 40), item("7", 62, BASE + 5.5, 7), item("2", 62, BASE - 5.5, 7), item(",", 67), item("–14, 7, X", 73)];
  const { expressoes } = detectarExpressoes(itens);
  assert.deepEqual(expressoes.map((e) => e.texto), ["7/2"]);
  const { texto } = aplicarExpressoesAoTexto("–7, 7\n2 , –14, 7, X", expressoes);
  assert.equal(texto, "–7, 7/2 , –14, 7, X");
});

test("EX-D) potência/sobrescrito não é fração: x² e 10³ viram sobrescrito Unicode; ordinal 1º também", () => {
  const itens = [item("x", 40), item("2", 45, BASE + 4, 7), item("+ 10", 52), item("3", 72, BASE + 4, 7), item("no dia 1", 90), item("o", 130, BASE + 4, 7), item("de maio", 136)];
  const { expressoes, incertas } = detectarExpressoes(itens);
  assert.equal(incertas.length, 0);
  assert.deepEqual(expressoes.map((e) => [e.tipo, e.texto]), [["sobrescrito", "²"], ["sobrescrito", "³"], ["sobrescrito", "º"]]);
  assert.ok(!expressoes.some((e) => e.tipo === "fracao"));
});

test("EX-E) duas linhas próximas de corpo normal NÃO são fração (nada detectado, itens intactos)", () => {
  const itens = [item("7", 40, 700), item("2", 40, 690), item("linha de cima", 50, 700), item("linha de baixo", 50, 690)];
  const resultado = detectarExpressoes(itens);
  assert.deepEqual(resultado.expressoes, []);
  assert.deepEqual(resultado.incertas, []);
  assert.equal(resultado.itens, itens);
});

test("EX-F) texto pequeno sem vizinho de corpo normal (nota/fonte) não é expressão", () => {
  const itens = [item("Texto normal do corpo da pagina.", 40, 700), item("Fonte: nota de rodape em fonte menor.", 40, 100, 7)];
  assert.deepEqual(detectarExpressoes(itens).expressoes, []);
});

test("EX-G) sem confiança -> incerta/não aplicada, nunca texto alterado; a questão da página vai para REVISAO_MANUAL", () => {
  const conteudoComplexo = detectarExpressoes([
    item("Valor:", 40),
    item("abc def ghi jkl mno", 75, BASE + 5.5, 7),
    item("2", 75, BASE - 5.5, 7),
    item("fim", 180),
    item("Linha de corpo normal, longa o bastante para ser o corpo da pagina.", 40, 650),
  ]);
  assert.equal(conteudoComplexo.expressoes.length, 0);
  assert.equal(conteudoComplexo.incertas.length, 1);

  const { expressoes } = detectarExpressoes(itensFracao("7", "2"));
  const ambiguo = aplicarExpressoesAoTexto("Valor: 7\n2 , fim\nValor: 7\n2 , fim", expressoes);
  assert.equal(ambiguo.texto, "Valor: 7\n2 , fim\nValor: 7\n2 , fim", "texto intacto quando a forma linear não é única");
  assert.equal(ambiguo.naoAplicadas.length, 1);

  const { questoes } = extrairQuestoesDoTexto([
    {
      numero: 1,
      texto: ["1. Calcule: Valor: 7", "2 , fim", "a) um", "b) dois", "c) tres", "d) quatro"].join("\n"),
      alertas: alertasDeExpressao(1, ambiguo.naoAplicadas),
    },
  ]);
  assert.equal(questoes[0].alertas_expressao.length, 1);
  const normalizada = normalizarQuestao({ ...questoes[0], gabarito: { alternativa_correta: "A", anulada: false, status: "ok" }, motivos_juncao: [] }, {}, { materia_id: 1, assunto_id: null, confidence: "alta", motivo: "" });
  const proveniencia = { completa: true, faltando: [], invalidos: [] };
  const resultado = calcularStatus(normalizada, { status: "nova" }, [], proveniencia);
  assert.equal(resultado.etapas.EXTRACAO_OK, false);
  assert.equal(resultado.status, "REVISAO_MANUAL");
  assert.ok(resultado.motivos.some((m) => /expressão matemática/.test(m)));
});
