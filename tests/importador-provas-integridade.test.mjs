import assert from "node:assert/strict";
import test from "node:test";
import { reconstruirDocumentoPosicionado, removerCarimbosDeMargem } from "../scripts/importador-provas/lib/extrairTextoPdfPosicionado.mjs";
import { detectarExpressoes, normalizarAlfanumericosMatematicos } from "../scripts/importador-provas/lib/expressoesPdf.mjs";
import { compararQuestoes, fragmentosDeMargem, problemasDeIntegridade } from "../scripts/importador-provas/lib/integridade.mjs";
import { extrairGabaritoDoTexto } from "../scripts/importador-provas/lib/extrairGabarito.mjs";
import { juntarQuestoesEGabarito } from "../scripts/importador-provas/lib/juncao.mjs";
import { calcularStatus } from "../scripts/importador-provas/lib/score.mjs";
import { anexarMidias, resolverMidias } from "../scripts/importador-provas/lib/midias.mjs";
import { temReferenciaDeDestaque } from "../scripts/importador-provas/lib/extrairQuestoes.mjs";

// PAPIRO — integridade da extração (as 5 falhas reproduzíveis de um caderno
// real de 1 coluna, Fundatec/GM Sant'Ana do Livramento 2025, e o gate que
// impede corrupção silenciosa). Fixtures 100% sintéticas — nenhum conteúdo
// de prova real.

let jitter = 0;
function item(texto, x, y, largura = texto.length * 6, altura = 10) {
  jitter += 1;
  return { texto, x: x + jitter * 0.001, y, largura, altura };
}
const pagina = (numero, itens, alturaPagina = 842) => ({ numero, larguraPagina: 595, alturaPagina, itens });
const PROVENIENCIA = { prova: {}, completa: true, faltando: [], invalidos: [] };

// ---------------------------------------------------------------- colunas ----

// Linha justificada que atravessa a página inteira: duas metades com espaço
// de palavra (< 0,8 altura) entre elas.
function linhaCorrida(esquerda, direita, y) {
  return [item(esquerda, 42, y, 330), item(direita, 378, y, 160)];
}

test("CAL-A) 1 coluna justificada com linhas recuadas à direita (autoria, fonte): sem calha = 1 coluna, e a continuação da linha do enunciado fica no enunciado, antes das alternativas", () => {
  const itens = [];
  let y = 780;
  for (let i = 0; i < 6; i++) itens.push(...linhaCorrida(`Texto corrido número ${i} que vai até`, `a margem direita ${i}`, (y -= 14)));
  itens.push(item("Por Fulano de Tal", 450, (y -= 14), 100));
  itens.push(item("(Fonte sintética, adaptado).", 400, (y -= 14), 150));
  itens.push(...linhaCorrida("QUESTÃO 01 – Assinale a alternativa que preenche, correta", "e respectivamente, as lacunas", (y -= 14)));
  itens.push(item("pontilhadas nas linhas 10, 16 e 30.", 42, (y -= 14), 180));
  for (const letra of "ABCDE") itens.push(item(`${letra}) opção ${letra}`, 42, (y -= 14), 80));
  itens.push(item("Assinatura sintética", 420, (y -= 14), 120));
  itens.push(item("Outra linha à direita", 430, (y -= 14), 120));
  const r = reconstruirDocumentoPosicionado([pagina(1, itens)]);
  assert.equal(r.deteccaoColunas.totalColunas, 1, "4 linhas recuadas não inventam uma coluna");
  const linhas = r.paginas[0].texto.split("\n");
  const enunciado = linhas.findIndex((l) => l.startsWith("QUESTÃO 01"));
  assert.match(linhas[enunciado], /correta\s+e respectivamente, as lacunas$/);
  assert.equal(linhas[enunciado + 1], "pontilhadas nas linhas 10, 16 e 30.");
  assert.equal(linhas[enunciado + 6], "E) opção E", "nada do enunciado vai parar depois da alternativa E");
});

test("CAL-B) 2 colunas reais com calha: questão que quebra da coluna esquerda para a direita continua em ordem (coluna esquerda inteira, depois a direita)", () => {
  const itens = [];
  for (let i = 0; i < 8; i++) itens.push(item(`Esquerda linha ${i} do corpo`, 50, 760 - i * 14, 200));
  itens.push(item("QUESTÃO 02 – Comando que começa no pé da coluna", 50, 640, 200));
  itens.push(item("e continua no topo da coluna direita:", 330, 760, 200));
  for (const [i, letra] of [..."ABCDE"].entries()) itens.push(item(`${letra}) alternativa ${letra}`, 330, 746 - i * 14, 120));
  for (let i = 0; i < 4; i++) itens.push(item(`Direita linha ${i} do corpo`, 330, 660 - i * 14, 200));
  const r = reconstruirDocumentoPosicionado([pagina(1, itens)]);
  assert.equal(r.deteccaoColunas.totalColunas, 2, "calha confirmada: nenhuma linha atravessa a margem da coluna direita");
  const texto = r.paginas[0].texto;
  assert.ok(texto.indexOf("Comando que começa no pé da coluna") < texto.indexOf("e continua no topo da coluna direita:"));
  assert.ok(texto.indexOf("e continua no topo da coluna direita:") < texto.indexOf("A) alternativa A"));
});

// --------------------------------------------------------------- leituras ----

const questao = (numero, enunciado, alternativas) => ({ numero_original: numero, enunciado, alternativas: alternativas.map((texto, i) => ({ letra: "ABCDE"[i], texto })) });
const ALTS = ["Primeira.", "Segunda.", "Terceira.", "Quarta.", "Quinta."];

test("ORF) linha órfã deslocada: na outra leitura a última linha do enunciado da Q2 sai depois da E da Q1 — mesmas linhas em outra ordem = 'reordenada' (explicada pela geometria), sem problema de integridade", () => {
  const geometrica = [questao(1, "Comando da um?", ALTS), questao(2, "Comando da dois que continua\nna linha seguinte:", ALTS)];
  const linear = [questao(1, "Comando da um?", [...ALTS.slice(0, 4), "Quinta.\nna linha seguinte:"]), questao(2, "Comando da dois que continua", ALTS)];
  const comparacao = compararQuestoes(geometrica, linear);
  assert.equal(comparacao.get(1).tipo, "reordenada");
  assert.equal(comparacao.get(2).tipo, "reordenada");
  assert.deepEqual(problemasDeIntegridade(geometrica[1], { comparacao: comparacao.get(2) }), []);
});

test("DIV) leituras com CONTEÚDO diferente (linha que só existe numa delas) = 'divergente' -> problema de integridade (revisão), nunca resolvido por aproximação", () => {
  const escolhida = [questao(1, "Comando da um com valor 15?", ALTS)];
  const outra = [questao(1, "Comando da um com valor 51?", ALTS)];
  const comparacao = compararQuestoes(escolhida, outra);
  assert.equal(comparacao.get(1).tipo, "divergente");
  assert.deepEqual(problemasDeIntegridade(escolhida[0], { comparacao: comparacao.get(1) }).map((p) => p.codigo), ["divergencia_entre_leituras"]);
});

test("ALT-E) alternativa E que REALMENTE tem várias linhas: igual nas duas leituras, nenhum problema", () => {
  const alts = [...ALTS.slice(0, 4), "Quinta opção longa que ocupa\numa segunda linha inteira."];
  const comparacao = compararQuestoes([questao(1, "Comando?", alts)], [questao(1, "Comando?", alts)]);
  assert.equal(comparacao.get(1).tipo, "igual");
  assert.deepEqual(problemasDeIntegridade(questao(1, "Comando?", alts), { comparacao: comparacao.get(1) }), []);
});

// ------------------------------------------------------------------ gate ----

const paginasComMargem = (rodape, carimbo) => [1, 2, 3, 4].map((n) => ({ numero: n, texto: [`CADERNO SINTÉTICO ${carimbo}`, "conteúdo da página", "mais conteúdo", rodape.replace("#", String(n))].join("\n") }));

test("GATE) lixo de página: carimbo de data e hora da borda dentro do texto-base e rodapé corrido como linha de alternativa viram problema; o mesmo nome em texto legítimo não", () => {
  const margem = fragmentosDeMargem(paginasComMargem("GUARDA SINTÉTICA MUNICIPAL Página #", "07/03/2024 14:05:09"));
  const comCarimbo = { ...questao(1, "Comando?", ALTS), textos_base: [{ id: "TB1", texto: "Texto base 07/03/2024 14:05:09 continua aqui" }] };
  assert.deepEqual(problemasDeIntegridade(comCarimbo, { margem }).map((p) => p.codigo), ["lixo_de_pagina"]);
  const comRodape = questao(2, "Comando?", [...ALTS.slice(0, 4), "Quinta.\nGUARDA SINTÉTICA MUNICIPAL Página 3"]);
  assert.deepEqual(problemasDeIntegridade(comRodape, { margem }).map((p) => p.codigo), ["lixo_de_pagina"]);
  const legitima = questao(3, "A Guarda Sintética Municipal atua conforme a lei. Em 07/03/2024 houve reunião.", ALTS);
  assert.deepEqual(problemasDeIntegridade(legitima, { margem }), []);
});

test("GATE) cabeçalho de páginas ALTERNADAS (ímpar/par) grudado na alternativa vira problema; abertura de questão que só aparece no meio das páginas não", () => {
  const paginas = [1, 2, 3, 4, 5, 6].map((n) => ({
    numero: n,
    // conteúdo sem dígitos e diferente em cada página, como numa prova real
    texto: [
      n % 2 ? "Órgão Sintético das Ímpares" : "Secretaria Sintética das Pares",
      ...Array.from({ length: 6 }, (_, i) => `trecho ${"ABCDEFG"[n]}${"abcdefg"[i]} do corpo`),
      "Leia o texto a seguir:",
      ...Array.from({ length: 6 }, (_, i) => `final ${"ABCDEFG"[n]}${"abcdefg"[i]} do corpo`),
    ].join("\n"),
  }));
  const margem = fragmentosDeMargem(paginas);
  assert.deepEqual(problemasDeIntegridade(questao(1, "Comando?", [...ALTS.slice(0, 4), "Quinta.\nÓrgão Sintético das Ímpares"]), { margem }).map((p) => p.codigo), ["lixo_de_pagina"]);
  assert.deepEqual(problemasDeIntegridade(questao(2, "Leia o texto a seguir:\nComando?", ALTS), { margem }), []);
});

test("GATE) igualdade truncada ('f(x) =' sem o lado direito) e glifo matemático solto viram problema; igualdade completa não", () => {
  assert.deepEqual(problemasDeIntegridade(questao(1, "Qual é o domínio de f(x) =\n?", ALTS)).map((p) => p.codigo), ["igualdade_truncada"]);
  assert.deepEqual(problemasDeIntegridade(questao(2, "Considere 𝑥 maior que 5.", ALTS)).map((p) => p.codigo), ["glifo_matematico"]);
  assert.deepEqual(problemasDeIntegridade(questao(3, "Qual é o domínio de f(x) = (√(2x−6))/(x−5) ?", ALTS)), []);
});

test("GATE) causa de integridade derruba EXTRACAO_OK no score e não é liberável por motivo conhecido", () => {
  const q = { ...questao(1, "Comando?", ALTS), _interno: { alternativa_faltante: false, motivos_juncao: [], gabarito_status: "ok", integridade: [{ codigo: "lixo_de_pagina", motivo: "E contém fragmento de rodapé" }] } };
  const r = calcularStatus(q, { status: "nova", match_id: null }, [], PROVENIENCIA);
  assert.equal(r.etapas.EXTRACAO_OK, false);
  assert.match(r.motivos[0], /fragmento de rodapé/);
});

// --------------------------------------------------------------- carimbo ----

test("CAR) carimbo 'data hora' na faixa de margem some antes da reconstrução (timestamp qualquer); data/hora no corpo da página nunca é tocada", () => {
  const itens = [item("CADERNO_X_99", 42, 800, 100, 8), item("15/11/2023 23:59:58", 460, 800, 90, 8), item("Reunião em 15/11/2023 23:59:58 no corpo.", 42, 400, 250), item("15/11/2023 23:59:58", 42, 380, 90)];
  const restantes = removerCarimbosDeMargem(itens, 842).map((i) => i.texto);
  assert.deepEqual(restantes, ["CADERNO_X_99", "Reunião em 15/11/2023 23:59:58 no corpo.", "15/11/2023 23:59:58"]);
  assert.deepEqual(removerCarimbosDeMargem(itens, null).length, 4, "sem altura de página não há faixa de margem");
});

// --------------------------------------------------------------- fórmula ----

// "f(x) = √(2x−6)/(x−5) ?" de editor de equação: numerador e denominador em
// fonte de corpo, barra de fração e traço do radical como VETORES.
function formula({ comTracoDoRadical = true } = {}) {
  const itens = [item("Qual é o domínio de f(x) =", 42, 700, 140), item("√2𝑥−6", 189.2, 708.6, 36.2, 11.5), item("𝑥−5", 196.1, 691.8, 22.3, 11.5), item("?", 230.2, 700, 5.5), item("Linha de corpo seguinte do enunciado.", 42, 680, 200)];
  const regras = [{ x0: 189.2, x1: 225.4, y: 704.5 }, ...(comTracoDoRadical ? [{ x0: 196.9, x1: 225.7, y: 718.8 }] : [])];
  return { itens, regras };
}

test("FRM) fração de corpo com radical: barra e traço vetoriais reconstroem '(√(2x−6))/(x−5)' fielmente, no lugar da linha de base", () => {
  const { itens, regras } = formula();
  const r = detectarExpressoes(itens, regras);
  assert.deepEqual(r.incertas, []);
  assert.deepEqual(r.expressoes.map((e) => e.texto), ["(√(2x−6))/(x−5)"]);
  const sintetico = r.itens.find((i) => i.sintetico === "fracao");
  assert.equal(sintetico.y, 700, "a expressão fica na linha de base do enunciado");
  assert.ok(!r.itens.some((i) => i.texto === "√2𝑥−6" || i.texto === "𝑥−5"), "numerador e denominador viram um item só");
});

test("FRM) radical SEM traço que delimite o radicando: incerto (revisão), itens originais preservados — nunca adivinha √(2x−6) x √2·x−6", () => {
  const { itens, regras } = formula({ comTracoDoRadical: false });
  const r = detectarExpressoes(itens, regras);
  assert.deepEqual(r.expressoes, []);
  assert.equal(r.incertas.length, 1);
  assert.match(r.incertas[0].motivo, /radical sem traço/);
  assert.ok(r.itens.some((i) => i.texto === "√2𝑥−6") && r.itens.some((i) => i.texto === "𝑥−5"));
});

test("FRM) traço curto de um '√2' no meio da frase não transforma a linha de cima em numerador", () => {
  const itens = [item("Linha de cima larga do enunciado inteiro aqui.", 42, 716, 420), item("(considere", 42, 702, 60), item("√2 = 1,73)", 105, 702, 55)];
  const r = detectarExpressoes(itens, [{ x0: 112, x1: 118, y: 711 }]);
  assert.deepEqual(r.expressoes, []);
  assert.deepEqual(r.incertas, []);
  assert.equal(r.itens, itens, "nada detectado: itens intactos");
});

// --------------------------------------------------------------- gabarito ----

const GRADE = ["01 - A 02 - B 03 - C 04 - D 05 - * 06 - A 07 - B 08 - C 09 - D 10 - E"];

test("GAB-A) par isolado em prosa administrativa ('período de 09 a 11/12/2025', 'questões 1 a 10') nunca vira resposta: só a grade conta", () => {
  const texto = ["1.1. Recursos interpostos durante o período de 09 a 11/12/2025, conforme o edital.", "Questões 1 a 10 de Língua Portuguesa", ...GRADE].join("\n");
  const { gabaritos } = extrairGabaritoDoTexto(texto);
  assert.equal(gabaritos.length, 10);
  assert.deepEqual(gabaritos.filter((g) => g.numero === 9).map((g) => [g.alternativa_correta, g.status]), [["D", "ok"]]);
  assert.deepEqual(gabaritos.filter((g) => g.numero === 1).map((g) => g.alternativa_correta), ["A"]);
});

test("GAB-B) anulação repetida no mesmo documento (justificativa 'QUESTÃO: 05 - ANULADA' + grade '05 - *') é UMA entrada; respostas diferentes para o mesmo número continuam conflito", () => {
  const repetida = extrairGabaritoDoTexto(["QUESTÃO: 05 - ANULADA. Justificativa sintética.", ...GRADE].join("\n")).gabaritos;
  assert.deepEqual(repetida.filter((g) => g.numero === 5).map((g) => [g.anulada, g.status]), [[true, "ok"]]);
  assert.equal(repetida.length, 10);
  const conflito = extrairGabaritoDoTexto(["QUESTÃO: 04 - B", ...GRADE].join("\n")).gabaritos;
  assert.deepEqual(conflito.filter((g) => g.numero === 4).map((g) => [g.alternativa_correta, g.status]), [["B", "ok"], ["D", "revisao_manual"]]);
});

test("GAB-C) gate: gabarito com MAIS respostas do que questões derruba GABARITO_OK do lote inteiro", () => {
  const questoes = [1, 2].map((n) => ({ numero_original: n, enunciado: "Comando?", alternativas: ALTS.map((texto, i) => ({ letra: "ABCDE"[i], texto })) }));
  const gabaritos = [1, 2, 3].map((numero) => ({ numero, alternativa_correta: "A", anulada: false, status: "ok" }));
  const { juntadas, bloqueios } = juntarQuestoesEGabarito(questoes, gabaritos);
  assert.ok(bloqueios.some((b) => b.tipo === "gabarito_excedente"));
  const q = { ...juntadas[0], _interno: { alternativa_faltante: false, motivos_juncao: juntadas[0].motivos_juncao, gabarito_status: "ok" } };
  const r = calcularStatus(q, { status: "nova", match_id: null }, bloqueios, PROVENIENCIA);
  assert.equal(r.etapas.GABARITO_OK, false);
  assert.match(r.motivos.join(" "), /mais respostas do que questões/);
});

// ----------------------------------------------------------------- mídia ----

function imagem(id, [x0, y0, x1, y1]) {
  const [pxL, pxA] = [40, 20];
  const rgba = new Uint8Array(pxL * pxA * 4);
  for (let i = 0; i < pxL * pxA; i++) rgba.set([20, 90, 160, 255], i * 4);
  return { tipo: "imagem", id, pintura: 5, x0, y0, x1, y1, pxL, pxA, rgba, clip: null, suportada: true, motivo: null };
}
const linha = (texto, y, x0 = 50, x1 = 520) => ({ texto, y, xInicio: x0, xFim: x1 });

test("MID) figura centralizada entre o enunciado e 'A) 80.' (alternativa curta, na margem, sem sobrepor a figura em X): âncora confiável antes das alternativas, MIDIA_OK pelo mecanismo normal", () => {
  const alternativas = ["80.", "84.", "88.", "92.", "96."];
  const enunciado = "Na figura abaixo, as retas sintéticas são paralelas e cortadas por transversais.\nOs pontos destacados na figura marcam as interseções; o valor de x é igual a:";
  const q = { numero_original: 1, enunciado, alternativas: alternativas.map((texto, i) => ({ letra: "ABCDE"[i], texto, correta: i === 4 })), _interno: { alternativa_faltante: false, motivos_juncao: [], gabarito_status: "ok", referencia_visual: 'cita elemento visual ("destacados")' } };
  const p = {
    numero: 11,
    largura: 595,
    altura: 842,
    linhas: [
      linha("Na figura abaixo, as retas sintéticas são paralelas e cortadas por transversais.", 720),
      linha("Os pontos destacados na figura marcam as interseções; o valor de x é igual a:", 706),
      ...alternativas.map((t, i) => linha(`${"ABCDE"[i]}) ${t}`, 540 - i * 14, 42, 70)),
    ],
    imagens: [imagem("fig", [150, 560, 450, 690])],
    vetores: [],
  };
  const res = resolverMidias({ paginas: [p], questoes: [q] }).porQuestao.get(1);
  assert.equal(res.status, "OK", JSON.stringify(res.causas));
  assert.equal(res.midias[0].ancora_texto, null, "figura depois do enunciado, antes das alternativas");
  anexarMidias(q, res);
  const r = calcularStatus(q, { status: "nova", match_id: null }, [], PROVENIENCIA);
  assert.deepEqual([r.etapas.MIDIA_OK, r.etapas.EXTRACAO_OK], [true, true], r.motivos.join(" | "));
});

test("MID) 'destacados na figura' é destaque DENTRO da peça visual; 'destacada no texto', sublinhado e negrito continuam destaque tipográfico", () => {
  assert.equal(temReferenciaDeDestaque("Os pontos destacados na figura são as interseções."), false);
  assert.equal(temReferenciaDeDestaque("As áreas hachuradas no gráfico somam 30%."), false);
  assert.equal(temReferenciaDeDestaque("A palavra destacada no texto é um advérbio."), true);
  assert.equal(temReferenciaDeDestaque("O termo sublinhado exerce a função de sujeito."), true);
});

// ------------------------------------------------- glifos matemáticos ----

test("MAT-A) itálico/negrito/sem serifa matemáticos viram a letra comum; operadores lógicos e de conjunto ficam intactos", () => {
  const entrada = "(𝑃 → ~𝑄) ∨ (¬𝑅 ↔ 𝐒) ∧ ∀𝑥 ∈ A, ∃𝑦: 𝑥 + 𝟐 > 𝗓 · ℎ · 𝜋";
  assert.equal(normalizarAlfanumericosMatematicos(entrada), "(P → ~Q) ∨ (¬R ↔ S) ∧ ∀x ∈ A, ∃y: x + 2 > z · h · π");
  for (const operador of ["¬", "∧", "∨", "→", "↔", "∀", "∃", "∈", "~"]) assert.ok(normalizarAlfanumericosMatematicos(entrada).includes(operador), operador);
  assert.equal(normalizarAlfanumericosMatematicos("texto sem nada matemático"), "texto sem nada matemático");
});

test("MAT-B) script, fraktur e double-struck (podem denotar conjuntos) NÃO são normalizados e continuam apontados pelo gate", () => {
  const entrada = "x ∈ 𝔸 ou 𝒜 ou 𝔄 ou ℝ";
  assert.equal(normalizarAlfanumericosMatematicos(entrada), entrada);
  const q = { enunciado: `Seja ${entrada}. Assinale:`, alternativas: ["1", "2", "3", "4", "5"].map((t, i) => ({ letra: "ABCDE"[i], texto: t })) };
  assert.ok(problemasDeIntegridade(q).some((p) => p.codigo === "glifo_matematico"));
  const normalizada = { ...q, enunciado: normalizarAlfanumericosMatematicos("A sentença 𝑃 → ~𝑄 é:") };
  assert.equal(problemasDeIntegridade(normalizada).some((p) => p.codigo === "glifo_matematico"), false, "itálico normalizado não é mais glifo solto");
});

// ------------------------------------------------- tabela linearizada ----

test("TAB) tabela-verdade convertida em texto corrido vira problema (não liberável); alternativas 'V – F – V.' e uma linha solta de valores não", () => {
  const alternativas = ["V – V – V.", "V – F – V.", "F – F – V.", "F – V – F.", "F – F – F."].map((texto, i) => ({ letra: "ABCDE"[i], texto }));
  const tabela = { enunciado: "Complete a tabela:\np q p ∧ q\nV V V\nV F\nF V F\nF F F\nOs valores que faltam são:", alternativas };
  assert.ok(problemasDeIntegridade(tabela).some((p) => p.codigo === "tabela_linearizada"));
  const r = calcularStatus({ numero_original: 1, ...tabela, _interno: { alternativa_faltante: false, motivos_juncao: [], gabarito_status: "ok", integridade: problemasDeIntegridade(tabela) } }, { status: "nova", match_id: null }, [], PROVENIENCIA);
  assert.equal(r.etapas.EXTRACAO_OK, false);
  const semTabela = { enunciado: "Se p é V e q é F, o valor de p ∧ q, q ∨ p e p → q é:\nV F V", alternativas };
  assert.equal(problemasDeIntegridade(semTabela).some((p) => p.codigo === "tabela_linearizada"), false);
});

// ------------------------------------------------ itens enumerados vazios ----

const ALTS_ITENS = ["Apenas I e II.", "Apenas III e IV.", "Apenas I, III e IV.", "Apenas II, III e IV.", "I, II, III e IV."].map((texto, i) => ({ letra: "ABCDE"[i], texto, correta: i === 3 }));
const vazio = (enunciado) => problemasDeIntegridade({ enunciado, alternativas: ALTS_ITENS }).filter((p) => p.codigo === "item_enumerado_vazio");
const statusDe = (enunciado, { interno = {}, dedup = { status: "nova", match_id: null } } = {}) =>
  calcularStatus({ numero_original: 1, enunciado, alternativas: ALTS_ITENS, confidence: "alta", _interno: { alternativa_faltante: false, motivos_juncao: [], gabarito_status: "ok", integridade: problemasDeIntegridade({ enunciado, alternativas: ALTS_ITENS }), ...interno } }, dedup, [], PROVENIENCIA);
const PERDIDOS = "Considere o cenário sintético de teste e as sentenças:\nI.\nII.\nIII.\nIV.\nQuais sentenças são verdadeiras?";

test("ENUM-A/B/C) só os marcadores sobreviveram (I. II. III. IV., 1) 2) 3), a) b) c), I) II), a. b.) -> item_enumerado_vazio e REVISAR", () => {
  assert.match(vazio(PERDIDOS)[0]?.motivo ?? "", /\(I\. II\. III\. IV\.\)/);
  for (const lista of ["1)\n2)\n3)", "a)\nb)\nc)", "I)\nII)\nIII)", "a.\nb.\nc.", "1.\n2.\n3."]) {
    const enunciado = `Analise os itens a seguir:\n${lista}\nQuais estão corretos?`;
    assert.equal(vazio(enunciado).length, 1, lista);
    const r = statusDe(enunciado);
    assert.deepEqual([r.etapas.EXTRACAO_OK, r.status], [false, "REVISAO_MANUAL"], lista);
  }
});

test("ENUM-D/E/F/I) itens com conteúdo, fórmulas, placeholders do documento e citação de itens não bloqueiam", () => {
  for (const enunciado of [
    "Analise as assertivas:\nI. primeira afirmação\nII. segunda afirmação\nQuais estão corretas?",
    "Estão corretas I, II e III.",
    "Considere os itens I e II.",
    "A alternativa correta é II.",
    "I e III são verdadeiras.",
    "Segundo os itens I, II e IV, assinale a correta.",
    "Considere as proposições:\nI. P ∧ Q\nII. ¬P\nIII. x > 2",
    "Complete:\nI. ______\nII. (   )\nIII. ?",
    "Analise as assertivas:\nI.\nprimeira afirmação em outra linha\nII.\nsegunda afirmação em outra linha",
    "O prazo terminou em 2020.\n3.",
  ]) {
    assert.deepEqual(vazio(enunciado), [], enunciado);
    assert.equal(statusDe(enunciado).etapas.EXTRACAO_OK, true, enunciado);
  }
});

test("ENUM-G/H) item vazio continua REVISAR com mídia associada (MIDIA_OK) e com dedup OK", () => {
  const comMidia = statusDe(PERDIDOS, { interno: { dependencia_midia: true, midias: [{ ordem: 1, sha256: "a".repeat(64) }] } });
  assert.deepEqual([comMidia.etapas.MIDIA_OK, comMidia.etapas.EXTRACAO_OK, comMidia.status], [true, false, "REVISAO_MANUAL"]);
  const r = statusDe(PERDIDOS);
  assert.deepEqual(Object.entries(r.etapas).filter(([, v]) => !v).map(([k]) => k), ["EXTRACAO_OK"], "só a extração trava — DEDUP_OK e os demais estão OK");
  assert.equal(r.status, "REVISAO_MANUAL");
});
