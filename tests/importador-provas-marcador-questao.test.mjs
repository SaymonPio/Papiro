import assert from "node:assert/strict";
import test from "node:test";
import { extrairQuestoesDoTexto } from "../scripts/importador-provas/lib/extrairQuestoes.mjs";
import { conferirDeclaracao, selecionarIntervalo } from "../scripts/importador-provas/lib/partes.mjs";

// Marcador explícito impresso "QUESTÂO" (Â no lugar de Ã) — erro de impressão
// da banca (Fundatec/SEJUSP-MG 2022, Q43 e Q45 do TIPO 1). Só o marcador
// estrutural "QUESTÂO <número> –" no início da linha inicia questão; o texto
// bruto nunca é reescrito. Páginas 100% sintéticas, uma questão por página.

// Sufixo só com letras: dígitos viram "#" na chave de linha corrida e as alternativas curtas sumiriam como cabeçalho.
const sufixo = (k) => String.fromCharCode(97 + Math.floor(k / 26), 97 + (k % 26));
function paginas(marcadores, { primeiraPagina = 1, carimbo = "PROVA_SINTETICA_T1", enunciado = () => "" } = {}) {
  return marcadores.map((marcador, i) => {
    const k = primeiraPagina + i;
    const extra = enunciado(i);
    return { numero: k, texto: [carimbo, `${marcador} – Enunciado ${sufixo(k)}.`, ...(extra ? [extra] : []), ...["A", "B", "C", "D", "E"].map((l) => `${l}) ${l.toLowerCase()}${sufixo(k)}`)].join("\n") };
  });
}
const numeros = (r) => r.questoes.map((q) => q.numero_impresso);

test("MARCADOR-A) QUESTÃO 1 continua reconhecido normalmente", () => {
  const r = extrairQuestoesDoTexto(paginas(["QUESTÃO 01", "QUESTÃO 02", "QUESTÃO 03"]));
  assert.equal(r.bloqueio, null);
  assert.deepEqual(numeros(r), [1, 2, 3]);
});

test("MARCADOR-B) QUESTÂO 2 (e Questâo) é reconhecido como início de questão", () => {
  const r = extrairQuestoesDoTexto(paginas(["QUESTÃO 01", "QUESTÂO 02", "Questâo 03", "QUESTÃO 04"]));
  assert.deepEqual(numeros(r), [1, 2, 3, 4]);
  assert.ok(r.questoes.every((q) => q.alternativas.length === 5));
  // O marcador sai do enunciado como o "QUESTÃO" correto: nada de "QUESTÂO" grudado na alternativa anterior.
  assert.ok(r.questoes.every((q) => !/QUEST[ÃÂ]O|Questâo/.test(`${q.enunciado}\n${q.alternativas.map((a) => a.texto).join("\n")}`)));
});

test("MARCADOR-C) QUESTÃO 42 seguida de QUESTÂO 43: duas questões distintas", () => {
  const marcadores = Array.from({ length: 45 }, (_, i) => `${i === 42 || i === 44 ? "QUESTÂO" : "QUESTÃO"} ${String(i + 1).padStart(2, "0")}`);
  const r = extrairQuestoesDoTexto(paginas(marcadores));
  assert.deepEqual(numeros(r), Array.from({ length: 45 }, (_, i) => i + 1));
  const [q42, q43] = [r.questoes[41], r.questoes[42]];
  assert.notEqual(q42.enunciado, q43.enunciado);
  assert.equal(q42.alternativas.length, 5);
  assert.ok(!q42.alternativas.at(-1).texto.includes("Enunciado"), "a Q43 não gruda na última alternativa da Q42");
});

test("MARCADOR-D) 'questâo' em prosa comum não cria questão e é preservada como está", () => {
  const prosa = (i) => (i === 1 ? "Observe que essa questâo foi discutida em sala.\nQuestâo 7 foi anulada no ano anterior" : "");
  const r = extrairQuestoesDoTexto(paginas(["QUESTÃO 01", "QUESTÃO 02", "QUESTÃO 03"], { enunciado: prosa }));
  assert.deepEqual(numeros(r), [1, 2, 3]);
  assert.match(r.questoes[1].enunciado, /essa questâo foi discutida em sala\./);
  assert.match(r.questoes[1].enunciado, /Questâo 7 foi anulada no ano anterior/);
});

test("MARCADOR-E) QUESTÂO sem número válido não cria questão; variantes não comprovadas continuam fora", () => {
  // A página 2 traz o marcador inválido; a Q2 real é a da página 3. Aceito, o marcador quebraria a sequência 1, 2, 3.
  for (const invalido of ["QUESTÂO", "QUESTÂO XX", "QUESTÂO 1234", "QUESTÄO 02", "QESTÃO 02", "QUESTON 02"]) {
    const r = extrairQuestoesDoTexto(paginas(["QUESTÃO 01", invalido, "QUESTÃO 02", "QUESTÃO 03"]));
    assert.deepEqual(numeros(r), [1, 2, 3], invalido);
    assert.equal(r.questoes[1].pagina_origem, 3, invalido);
    assert.ok(!r.questoes.some((q) => q.pagina_origem === 2), invalido);
  }
});

test("MARCADOR-F) numeração repetida em outro caderno continua dependendo de metadata.parte/caderno", () => {
  const marcadores = (n) => Array.from({ length: n }, (_, i) => `${i % 2 ? "QUESTÂO" : "QUESTÃO"} ${String(i + 1).padStart(2, "0")}`);
  const pdf = [...paginas(marcadores(12), { carimbo: "BASE_TIPO 1" }), ...paginas(marcadores(12), { primeiraPagina: 13, carimbo: "BASE_TIPO 2" })];
  assert.match(extrairQuestoesDoTexto(pdf).bloqueio, /2 cadernos/);
  const selecao = selecionarIntervalo({ caderno: { paginas: [13, 24], cabecalho: "BASE_TIPO 2", total_questoes: 12 } }, pdf, pdf.length);
  const r = extrairQuestoesDoTexto(selecao.paginas);
  assert.equal(conferirDeclaracao({ ...selecao, todasAsPaginas: pdf, questoes: r.questoes, blocoGabarito: null }), null);
  assert.deepEqual(numeros(r), Array.from({ length: 12 }, (_, i) => i + 1));
  assert.ok(r.questoes.every((q) => q.pagina_origem >= 13), "nenhuma questão do TIPO 1");
});
