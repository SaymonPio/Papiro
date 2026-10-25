import assert from "node:assert/strict";
import test from "node:test";
import { extrairQuestoesDoTexto } from "../scripts/importador-provas/lib/extrairQuestoes.mjs";
import { conferirDeclaracao, selecionarIntervalo } from "../scripts/importador-provas/lib/partes.mjs";

// PDF oficial que concatena cadernos (lib/partes.mjs): o recorte de páginas é DECLARADO no staging (metadata.parte ou
// metadata.caderno) e conferido contra o documento — nunca inferido do conteúdo. Páginas 100% sintéticas, no formato
// de extrairTextoPdf: { numero, texto }, uma questão por página, com o carimbo do caderno no topo.

// Sufixo só com letras: dígitos viram "#" na chave de linha corrida e as alternativas curtas sumiriam como cabeçalho.
const sufixo = (k) => String.fromCharCode(97 + Math.floor(k / 26), 97 + (k % 26));
function caderno(primeiraPagina, n, carimbo, { capa = false } = {}) {
  const paginas = capa ? [{ numero: primeiraPagina, texto: `Capa do caderno ${carimbo}\nLeia as instruções com atenção antes de começar.` }] : [];
  const inicio = primeiraPagina + (capa ? 1 : 0);
  for (let i = 0; i < n; i++) {
    const k = inicio + i;
    paginas.push({ numero: k, texto: [carimbo, `QUESTÃO ${String(i + 1).padStart(2, "0")} – Enunciado ${sufixo(k)}.`, ...["A", "B", "C", "D", "E"].map((l) => `${l}) ${l.toLowerCase()}${sufixo(k)}`)].join("\n") });
  }
  return paginas;
}
// P1: capa na p. 1 e 12 questões nas p. 2–13; P2: capa na p. 14 e 15 questões nas p. 15–29. Numeração 1..N repetida.
const P1 = caderno(1, 12, "PROVA_BASE_T1_P1", { capa: true });
const P2 = caderno(14, 15, "PROVA_BASE_T1_P2", { capa: true });
const PDF = [...P1, ...P2];
const TOTAL = PDF.length;

function extrairCom(metadata, { pdf = PDF, total = pdf.length, bloco = null } = {}) {
  const selecao = selecionarIntervalo(metadata, pdf, total);
  if (selecao.bloqueio) return { bloqueio: selecao.bloqueio };
  const r = extrairQuestoesDoTexto(selecao.paginas);
  if (r.bloqueio) return { bloqueio: r.bloqueio };
  const bloqueio = conferirDeclaracao({ ...selecao, todasAsPaginas: pdf, questoes: r.questoes, blocoGabarito: bloco });
  return { bloqueio, questoes: r.questoes, selecao };
}
const parte = (codigo, ordem, paginas, extra = {}) => ({ parte: { codigo, nome: `Parte ${ordem}`, ordem, paginas, ...extra } });

test("PARTES-A) PDF de um caderno, sem declaração: documento inteiro, comportamento inalterado", () => {
  const selecao = selecionarIntervalo({}, P2, P2.length);
  assert.equal(selecao.bloqueio, undefined);
  assert.equal(selecao.paginas, P2, "o mesmo array de páginas, sem cópia nem filtro");
  assert.equal(selecao.intervalo, null);
  assert.equal(conferirDeclaracao({ ...selecao, todasAsPaginas: P2, questoes: [], blocoGabarito: null }), null);
  assert.equal(extrairQuestoesDoTexto(selecao.paginas).questoes.length, 15);
});

test("PARTES-B/C) duas partes com intervalos explícitos e numeração 1..N repetida: cada parte só recebe as próprias questões", () => {
  const r1 = extrairCom(parte("P1", 1, [1, 13], { cabecalho: "PROVA_BASE_T1_P1", total_questoes: 12 }));
  const r2 = extrairCom(parte("P2", 2, [14, 29], { cabecalho: "PROVA_BASE_T1_P2", total_questoes: 15 }));
  assert.equal(r1.bloqueio, null);
  assert.equal(r2.bloqueio, null);
  assert.deepEqual(r1.questoes.map((q) => q.numero_impresso), Array.from({ length: 12 }, (_, i) => i + 1));
  assert.deepEqual(r2.questoes.map((q) => q.numero_impresso), Array.from({ length: 15 }, (_, i) => i + 1));
  assert.ok(r1.questoes.every((q) => q.pagina_origem >= 2 && q.pagina_origem <= 13), "P1 só com páginas da P1");
  assert.ok(r2.questoes.every((q) => q.pagina_origem >= 15 && q.pagina_origem <= 29), "P2 só com páginas da P2");
  // Mesmo número impresso, conteúdo diferente: Q1 da P1 ≠ Q1 da P2 — a identidade é documento + parte + número.
  assert.notEqual(r1.questoes[0].enunciado, r2.questoes[0].enunciado);
  // Sem declaração, o PDF inteiro continua bloqueado (nenhuma sequência escolhida entre cadernos).
  assert.match(extrairCom({}).bloqueio, /2 cadernos/);
});

test("PARTES-D) recorte que invade o caderno vizinho bloqueia (cadernos concatenados no intervalo, ou páginas sem o carimbo)", () => {
  assert.match(extrairCom(parte("P1", 1, [1, 29])).bloqueio, /2 cadernos/);
  // Invasão curta (capa + 2 questões da P2): o extrator ignora a sequência 1–2 do vizinho e gruda o texto na última
  // alternativa da P1 — o detector de cadernos não alcança, o carimbo sim.
  const curto = extrairCom(parte("P1", 1, [1, 16], { cabecalho: "PROVA_BASE_T1_P1" }));
  assert.match(curto.bloqueio, /texto de página sem o carimbo \(p\. 14, 15, 16\) entrou numa questão/);
  // Capa e rascunho do PRÓPRIO caderno dentro do intervalo, sem vazar para questão, são aceitos.
  assert.equal(extrairCom(parte("P1", 1, [1, 13], { cabecalho: "PROVA_BASE_T1_P1" })).bloqueio, null);
  // parte e caderno declarados juntos: recorte ambíguo.
  assert.match(extrairCom({ ...parte("P1", 1, [1, 13]), caderno: { paginas: [1, 13] } }).bloqueio, /declarados juntos/);
});

test("PARTES-E) intervalo fora do PDF ou malformado bloqueia", () => {
  for (const paginas of [[1, TOTAL + 1], [0, 5], [10, 2], [3], "1-13", [1.5, 4]]) {
    assert.match(extrairCom(parte("P1", 1, paginas)).bloqueio, /metadata\.parte\.paginas inválido/, JSON.stringify(paginas));
  }
  assert.match(extrairCom({ caderno: { paginas: [1, 99] } }).bloqueio, /metadata\.caderno\.paginas inválido/);
});

test("PARTES-F) PDF multicaderno sem a declaração obrigatória bloqueia; intervalo curto demais (carimbo fora do intervalo) também", () => {
  assert.match(extrairCom({}).bloqueio, /declare a parte a extrair/);
  const curto = extrairCom(parte("P2", 2, [14, 25], { cabecalho: "PROVA_BASE_T1_P2" }));
  assert.match(curto.bloqueio, /aparece fora do intervalo 14–25 \(p\. 26, 27, 28, 29\)/);
  const contagem = extrairCom(parte("P2", 2, [14, 29], { total_questoes: 16 }));
  assert.match(contagem.bloqueio, /total_questoes = 16, mas foram extraídas 15/);
});

test("PARTES-G) cabeçalho declarado conflitante com o documento bloqueia", () => {
  const trocado = extrairCom(parte("P2", 2, [14, 29], { cabecalho: "PROVA_BASE_T1_P1" }));
  assert.match(trocado.bloqueio, /aparece fora do intervalo|ausente em página/);
  assert.match(extrairCom(parte("P2", 2, [14, 29], { cabecalho: "OUTRA_PROVA_XYZ" })).bloqueio, /ausente em página\(s\) com questão/);
  assert.match(extrairCom(parte("P2", 2, [14, 29], { cabecalho: "ab" })).bloqueio, /cabecalho inválido/);
});

test("PARTES-H) gabarito de outra parte/caderno nunca é associado em silêncio", () => {
  const meta = parte("P2", 2, [14, 29], { gabarito_bloco: "PROVA (P2) – TIPO 1" });
  assert.equal(extrairCom(meta, { bloco: "PROVA (P2) – TIPO 1" }).bloqueio, null);
  assert.match(extrairCom(meta, { bloco: "PROVA (P1) – TIPO 1" }).bloqueio, /gabarito de outra parte\/caderno/);
  assert.match(extrairCom(meta, { bloco: null }).bloqueio, /gabarito de outra parte\/caderno/);
});

test("CADERNO) metadata.caderno recorta o tipo canônico (versões da MESMA prova) com os mesmos gates", () => {
  const tipos = [...caderno(1, 12, "BASE_TIPO 1"), ...caderno(13, 12, "BASE_TIPO 2")];
  const ok = extrairCom({ caderno: { paginas: [1, 12], cabecalho: "BASE_TIPO 1", total_questoes: 12, gabarito_bloco: "TIPO 1" } }, { pdf: tipos, bloco: "TIPO 1" });
  assert.equal(ok.bloqueio, null);
  assert.equal(ok.questoes.length, 12);
  assert.equal(ok.selecao.origem, "metadata.caderno");
  assert.match(extrairCom({ caderno: { paginas: [1, 12], cabecalho: "BASE_TIPO 2" } }, { pdf: tipos }).bloqueio, /fora do intervalo|ausente em página/);
});
