import assert from "node:assert/strict";
import test from "node:test";
import { aplicarExpressoesAoTexto, alertasDeExpressao, detectarExpressoes } from "../scripts/importador-provas/lib/expressoesPdf.mjs";
import { extrairQuestoesDoTexto } from "../scripts/importador-provas/lib/extrairQuestoes.mjs";
import { normalizarQuestao } from "../scripts/importador-provas/lib/normalizar.mjs";
import { calcularStatus } from "../scripts/importador-provas/lib/score.mjs";
import { CAUSAS_LIBERAVEIS } from "../scripts/importador-provas/lib/aquisicao/planejar.mjs";

// PAPIRO — sobrescrito pelo contexto tipográfico LOCAL e gate de expoente
// aparente não convertido (checado numa prova real: Fundatec/PC-RS 2025
// Escrivão-Inspetor, P2 TIPO 1 — fórmula em fonte maior que o corpo da
// página, expoente acima do limite "pequeno" da página e perdido em
// silêncio). Geometria 100% sintética: corpo da página 10 pt, fórmula 12 pt.

const BASE = 700;
function item(texto, x, y = BASE, altura = 10) {
  return { texto, x, y, largura: texto.length * (altura / 2), altura };
}
// Prosa que define o corpo da página (10 pt) + a linha da fórmula.
const PROSA = item("Texto corrido da pagina em corpo normal, longo o bastante para definir o corpo.", 40, 760);
const pagina = (...formula) => [PROSA, ...formula];
// "x" de 12 pt (largura 6, termina em 106) seguido de um item colado.
const x12 = () => item("x", 100, BASE, 12);
const expoente = (texto, altura, elevacao = 4.4, x = 106.5) => item(texto, x, BASE + elevacao, altura);
const resumo = (r) => ({ expressoes: r.expressoes.map((e) => [e.tipo, e.texto]), incertas: r.incertas.map((e) => [e.tipo, e.motivo]) });

test("SUP-A) base de 12 pt + '2' de 8,52 pt elevado e colado = sobrescrito (contexto local, acima do limite 'pequeno' da página)", () => {
  assert.deepEqual(resumo(detectarExpressoes(pagina(x12(), expoente("2", 8.52), item("+ 1", 112, BASE, 12)))), { expressoes: [["sobrescrito", "²"]], incertas: [] });
});

test("SUP-B) mesmo caso com 8,40 pt (pequeno também para a página) = sobrescrito", () => {
  assert.deepEqual(resumo(detectarExpressoes(pagina(x12(), expoente("2", 8.4), item("+ 1", 112, BASE, 12)))), { expressoes: [["sobrescrito", "²"]], incertas: [] });
});

test("SUP-C) texto pequeno de rodapé, sem base adjacente nem linha de base deslocada, não é expoente", () => {
  const r = detectarExpressoes(pagina(item("Fonte: nota sintética de rodapé em fonte menor.", 40, 100, 7), item("12", 300, 100, 7)));
  assert.deepEqual(resumo(r), { expressoes: [], incertas: [] });
});

test("SUP-D) número visualmente menor na MESMA linha de base não vira sobrescrito automaticamente", () => {
  assert.deepEqual(resumo(detectarExpressoes(pagina(x12(), expoente("2", 8.52, 0), item("+ 1", 112, BASE, 12)))), { expressoes: [], incertas: [] });
});

test("SUP-E) x² seguido de texto normal: a expressão entra no texto e o resto da linha fica intacto", () => {
  const { expressoes } = detectarExpressoes(pagina(x12(), expoente("2", 8.52), item("+ 1 e o restante da linha.", 112, BASE, 12)));
  const r = aplicarExpressoesAoTexto("Seja x2 + 1 e o restante da linha.\nOutra linha com 2 e x solto.", expressoes);
  assert.equal(r.texto, "Seja x² + 1 e o restante da linha.\nOutra linha com 2 e x solto.");
  assert.equal(r.naoAplicadas.length, 0);
});

test("SUP-F) x³ = sobrescrito", () => {
  assert.deepEqual(resumo(detectarExpressoes(pagina(x12(), expoente("3", 8.6), item("=", 112, BASE, 12)))).expressoes, [["sobrescrito", "³"]]);
});

test("SUP-G) unidades m², cm³ e km² em fonte de fórmula = sobrescritos", () => {
  const r = detectarExpressoes(pagina(item("m", 100, BASE, 12), expoente("2", 8.6), item("cm", 160, BASE, 12), expoente("3", 8.6, 4.4, 172.5), item("km", 220, BASE, 12), expoente("2", 8.6, 4.4, 232.5)));
  assert.deepEqual(resumo(r), { expressoes: [["sobrescrito", "²"], ["sobrescrito", "³"], ["sobrescrito", "²"]], incertas: [] });
});

test("SUP-H) geometria ambígua = incerta (expressao_incerta), nunca texto corrido: elevação entre linha e expoente; glifo do mesmo tamanho elevado como expoente", () => {
  const ambigua = detectarExpressoes(pagina(x12(), expoente("2", 8.6, 2.4), item("+ 1", 112, BASE, 12)));
  assert.deepEqual(ambigua.expressoes, []);
  assert.match(ambigua.incertas[0]?.motivo ?? "", /ambíguo/);
  const semFonteMenor = detectarExpressoes(pagina(x12(), expoente("2", 12, 4.4), item("+ 1", 112, BASE, 12)));
  assert.deepEqual(semFonteMenor.expressoes, []);
  assert.match(semFonteMenor.incertas[0]?.motivo ?? "", /expoente aparente sem fonte menor/);
});

test("SUP-I) 'x2' realmente escrito na mesma linha de base e no mesmo tamanho fica 'x2' (nada detectado, itens intactos)", () => {
  const itens = pagina(x12(), expoente("2", 12, 0), item("+ 1", 112, BASE, 12));
  const r = detectarExpressoes(itens);
  assert.deepEqual(resumo(r), { expressoes: [], incertas: [] });
  assert.equal(r.itens, itens);
});

test("SUP-J) a MESMA expressão repetida (x² nos itens I e III) é aplicada em grupo; contagem diferente da forma linear continua não aplicada", () => {
  const linha = (y) => [item("x", 100, y, 12), item("2", 106.5, y + 4.4, 8.52), item("+ 1", 112, y, 12)];
  const { expressoes } = detectarExpressoes(pagina(...linha(BASE), ...linha(BASE - 28)));
  assert.deepEqual(expressoes.map((e) => e.texto), ["²", "²"], "cada linha com a própria base (a de cima não rouba o expoente da de baixo)");
  const certo = aplicarExpressoesAoTexto("I. x2 + 1 ≤ 2.\nII. y < 1.\nIII. x2 + 1 ≥ 2.", expressoes);
  assert.equal(certo.texto, "I. x² + 1 ≤ 2.\nII. y < 1.\nIII. x² + 1 ≥ 2.");
  const aMais = aplicarExpressoesAoTexto("I. x2 + 1.\nII. x2 + 1.\nIII. x2 + 1.", expressoes);
  assert.equal(aMais.texto, "I. x2 + 1.\nII. x2 + 1.\nIII. x2 + 1.", "3 formas lineares para 2 expressões: nada trocado");
  assert.equal(aMais.naoAplicadas.length, 2);
});

test("SUP-K) gate: expoente incerto derruba EXTRACAO_OK (expressao_nao_reconstruida) e NÃO é liberável — nem por aprovação de extração nem por liberação de dedup", () => {
  const incerta = detectarExpressoes(pagina(x12(), expoente("2", 12, 4.4), item("+ 1", 112, BASE, 12))).incertas;
  const { questoes } = extrairQuestoesDoTexto([{ numero: 1, texto: ["1. Calcule x2 + 1 para x = 1.", "a) um", "b) dois", "c) tres", "d) quatro"].join("\n"), alertas: alertasDeExpressao(1, incerta) }]);
  const normalizada = normalizarQuestao({ ...questoes[0], gabarito: { alternativa_correta: "B", anulada: false, status: "ok" }, motivos_juncao: [] }, {}, { materia_id: 1, assunto_id: null, confidence: "alta", motivo: "" });
  const resultado = calcularStatus(normalizada, { status: "nova" }, [], { completa: true, faltando: [], invalidos: [] });
  assert.equal(resultado.etapas.EXTRACAO_OK, false);
  assert.equal(resultado.status, "REVISAO_MANUAL");
  assert.ok(!Object.values(CAUSAS_LIBERAVEIS).flat().includes("expressao_nao_reconstruida"));
});
