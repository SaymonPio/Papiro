import assert from "node:assert/strict";
import test from "node:test";
import { extrairQuestoesDoTexto } from "../scripts/importador-provas/lib/extrairQuestoes.mjs";
import { normalizarQuestao } from "../scripts/importador-provas/lib/normalizar.mjs";
import { textoDaLinha } from "../scripts/importador-provas/lib/extrairTextoPdfPosicionado.mjs";
import { reconstruirTextoBase } from "../scripts/importador-provas/lib/textoBase.mjs";

// PAPIRO — linhas numeradas do texto-base quando a leitura posicional
// (multicoluna) é a representação da prova: a página não traz os itens
// soltos, mas as LINHAS já montadas pela leitura (coluna a coluna), e o
// texto-base precisa voltar com "[NN]" por linha — nunca virar parágrafo
// corrido com os números no meio ("... infracional 02 estão ..."). Quando
// a numeração não pode ser provada, o texto não é confiável (revisão).
// Fixtures 100% sintéticas, escritas à mão para este teste.

const ALTURA = 10;
function item(texto, x, y) {
  return { texto, x, y, largura: texto.length * 5, altura: ALTURA };
}
// Margem numerada em x=40 ("01" termina em 50); texto em x=67 (lacuna de
// 1,7 altura, como num PDF real) e x=92 na 1ª linha de cada parágrafo.
function linhaNumerada(numero, texto, y, recuo = false) {
  return { itens: [item(numero, 40, y), item(texto, recuo ? 92 : 67, y)] };
}
const textoDasLinhas = (linhas) => linhas.map((l) => l.itens.map((i) => i.texto).join(" ")).join("\n");
const numero = (n) => String(n).padStart(2, "0");

test("TBL-A) linhas sequenciais 01, 02, 03 pela leitura posicional -> [01], [02], [03] preservados", () => {
  const linhas = [linhaNumerada("01", "texto da linha A,", 700), linhaNumerada("02", "texto da linha B,", 688), linhaNumerada("03", "texto da linha C.", 676)];
  const resultado = reconstruirTextoBase([{ texto: textoDasLinhas(linhas), itens: null, linhas }]);
  assert.equal(resultado.confiavel, true, resultado.motivo);
  assert.equal(resultado.linhasNumeradas, true);
  assert.equal(resultado.texto, "[01] texto da linha A,\n[02] texto da linha B,\n[03] texto da linha C.");
});

test("TBL-B) mesmo conteúdo com quebra física diferente (palavra partida em itens; geometria solta x linhas montadas) -> mesma estrutura", () => {
  const conteudo = ["Primeira linha do texto,", "segunda linha do texto,", "terceira linha do texto,", "quarta linha do texto,", "quinta linha do texto."];
  const montadas = conteudo.map((t, i) => linhaNumerada(numero(i + 1), t, 700 - i * 12, i === 0));
  // A mesma página entregue em itens soltos, com a palavra "segunda" partida em dois itens colados ("seg" + "unda").
  const soltos = [];
  conteudo.forEach((t, i) => {
    const y = 700 - i * 12;
    soltos.push(item(numero(i + 1), 40, y));
    if (i === 1) soltos.push({ texto: "seg", x: 67, y, largura: 15, altura: ALTURA }, { texto: "unda linha do texto,", x: 82, y, largura: 100, altura: ALTURA });
    else soltos.push(item(t, i === 0 ? 92 : 67, y));
  });
  const porLinhas = reconstruirTextoBase([{ texto: textoDasLinhas(montadas), itens: null, linhas: montadas }]);
  const porItens = reconstruirTextoBase([{ texto: textoDasLinhas(montadas), itens: soltos }]);
  assert.equal(porLinhas.confiavel, true, porLinhas.motivo);
  assert.equal(porItens.confiavel, true, porItens.motivo);
  assert.equal(porLinhas.texto, porItens.texto);
  assert.equal(porLinhas.texto, conteudo.map((t, i) => `[${numero(i + 1)}] ${t}`).join("\n"));
});

test("TBL-C) \"Lei 12.594/2012\" no meio ou no começo de uma linha nunca vira número de linha", () => {
  const linhas = [
    { itens: [item("A Lei 12.594/2012 instituiu o sistema,", 40, 700)] },
    { itens: [item("12.594/2012", 40, 688), item("e outras normas completam o quadro.", 110, 688)] },
    { itens: [item("Fim do paragrafo ficticio.", 40, 676)] },
  ];
  const resultado = reconstruirTextoBase([{ texto: textoDasLinhas(linhas), itens: null, linhas }]);
  assert.equal(resultado.confiavel, true, resultado.motivo);
  assert.equal(resultado.linhasNumeradas, false);
  assert.doesNotMatch(resultado.texto, /\[\d+\]/);
  assert.match(resultado.texto, /A Lei 12\.594\/2012 instituiu o sistema,/);
});

test("TBL-D) \"18 anos\" no começo da linha (espaço normal entre palavras) não é marcador de linha", () => {
  const linhas = [
    { itens: [item("A idade minima e de", 40, 700)] },
    { itens: [item("18", 40, 688), item("anos completos na data da posse.", 53, 688)] },
    { itens: [item("Nada mais se exige.", 40, 676)] },
  ];
  const resultado = reconstruirTextoBase([{ texto: textoDasLinhas(linhas), itens: null, linhas }]);
  assert.equal(resultado.confiavel, true, resultado.motivo);
  assert.doesNotMatch(resultado.texto, /\[18\]/);
  assert.match(resultado.texto, /^18 anos completos/m);
  // Sem geometria nenhuma, "18 anos" isolado também não é evidência de numeração.
  const semGeometria = reconstruirTextoBase([{ texto: textoDasLinhas(linhas), itens: null }]);
  assert.equal(semGeometria.confiavel, true);
});

test("TBL-E) margem com 01, 03, 07 (sequência incompleta) -> TEXTO_BASE_LINHAS_INDETERMINADAS, nada reconstruído por suposição", () => {
  const linhas = [linhaNumerada("01", "linha um,", 700), linhaNumerada("03", "linha tres,", 688), linhaNumerada("07", "linha sete.", 676)];
  const resultado = reconstruirTextoBase([{ texto: textoDasLinhas(linhas), itens: null, linhas }]);
  assert.equal(resultado.confiavel, false);
  assert.match(resultado.motivo, /TEXTO_BASE_LINHAS_INDETERMINADAS/);
  assert.doesNotMatch(resultado.texto, /\[0[137]\]/);
});

test("TBL-E2) lista \"1 / 2 / 3\" com linhas de continuação não numeradas não vira numeração de linha (revisão)", () => {
  const linhas = [
    linhaNumerada("1", "primeiro item da lista que continua", 700),
    { itens: [item("na linha de baixo.", 67, 688)] },
    linhaNumerada("2", "segundo item da lista.", 676),
    linhaNumerada("3", "terceiro item da lista.", 664),
  ];
  const resultado = reconstruirTextoBase([{ texto: textoDasLinhas(linhas), itens: null, linhas }]);
  assert.equal(resultado.confiavel, false);
  assert.match(resultado.motivo, /TEXTO_BASE_LINHAS_INDETERMINADAS/);
});

test("TBL-F) linhas 01–49 completas -> ordem integral preservada, uma linha por número", () => {
  const linhas = Array.from({ length: 49 }, (_, i) => linhaNumerada(numero(i + 1), `conteudo ficticio numero ${i + 1},`, 760 - i * 12, i % 10 === 0));
  const resultado = reconstruirTextoBase([{ texto: textoDasLinhas(linhas), itens: null, linhas }]);
  assert.equal(resultado.confiavel, true, resultado.motivo);
  const marcadores = [...resultado.texto.matchAll(/^\[(\d{2})\] conteudo ficticio numero (\d+),$/gm)];
  assert.equal(marcadores.length, 49);
  marcadores.forEach((m, i) => {
    assert.equal(Number(m[1]), i + 1);
    assert.equal(Number(m[2]), i + 1);
  });
});

test("TBL-F2) texto em duas colunas: as linhas montadas pela leitura (coluna a coluna) mantêm a ordem de leitura, não a altura", () => {
  // Coluna esquerda 01–03 e direita 04–06 nas MESMAS alturas: agrupar por Y misturaria as colunas.
  const esquerda = [1, 2, 3].map((n, i) => ({ ...linhaNumerada(numero(n), `esquerda ${n},`, 700 - i * 12), coluna: 0 }));
  const direita = [4, 5, 6].map((n, i) => ({ itens: [item(numero(n), 300, 700 - i * 12), item(`direita ${n},`, 327, 700 - i * 12)], coluna: 1 }));
  const linhas = [...esquerda, ...direita];
  const resultado = reconstruirTextoBase([{ texto: textoDasLinhas(linhas), itens: null, linhas }]);
  assert.equal(resultado.confiavel, true, resultado.motivo);
  assert.equal(resultado.texto, [1, 2, 3].map((n) => `[${numero(n)}] esquerda ${n},`).concat([4, 5, 6].map((n) => `[${numero(n)}] direita ${n},`)).join("\n"));
});

test("TBL-G) texto sem linhas numeradas -> comportamento anterior (com e sem geometria)", () => {
  const linhas = [{ itens: [item("Titulo Ficticio", 200, 724)] }, { itens: [item("Um paragrafo sem numeracao,", 40, 700)] }, { itens: [item("que continua aqui.", 40, 688)] }];
  const texto = textoDasLinhas(linhas);
  const comLinhas = reconstruirTextoBase([{ texto, itens: null, linhas }]);
  assert.equal(comLinhas.confiavel, true);
  assert.equal(comLinhas.texto, texto);
  const semGeometria = reconstruirTextoBase([{ texto, itens: null }]);
  assert.deepEqual(semGeometria, { texto, geometrico: false, confiavel: true, motivo: null });
});

test("TBL-H) sem geometria, mas o texto traz numeração sequencial de linhas -> não confiável (antes: parágrafo corrido 'confiável')", () => {
  const texto = ["Titulo Ficticio", "01 primeira linha,", "02 segunda linha,", "03 terceira linha,", "04 quarta linha."].join("\n");
  const resultado = reconstruirTextoBase([{ texto, itens: null }]);
  assert.equal(resultado.confiavel, false);
  assert.match(resultado.motivo, /TEXTO_BASE_LINHAS_INDETERMINADAS/);
});

test("TBL-I) prova pela leitura posicional (páginas com linhas montadas): o enunciado normalizado mantém [NN] por linha", () => {
  const corpo = Array.from({ length: 8 }, (_, i) => `linha ficticia numero ${i + 1} do texto-base inventado para este teste sintetico,`);
  // Três páginas com o mesmo cabeçalho corrido (removido pelo extrator): a 2ª
  // abre com o título de seção e traz o texto; a 3ª traz as questões.
  const corrido = { itens: [item("PROVA SINTETICA 0000 - CABECALHO CORRIDO", 40, 800)] };
  const capa = [corrido, { itens: [item("INSTRUCOES DA CAPA", 40, 760)] }];
  const paginaTexto = [
    corrido,
    { itens: [item("LÍNGUA PORTUGUESA", 200, 780)] },
    { itens: [item("Instrução: As questões de números 01 a 02 referem-se ao texto abaixo.", 40, 760)] },
    { itens: [item("Titulo Ficticio", 200, 740)] },
    ...corpo.map((t, i) => linhaNumerada(numero(i + 1), t, 712 - i * 12, i === 0)),
  ];
  const paginaQuestoes = [
    corrido,
    { itens: [item("QUESTÃO 01 – De acordo com a l. 02, o texto afirma que:", 40, 760)] },
    ...["A", "B", "C", "D"].map((l, i) => ({ itens: [item(`${l}) q1 alternativa ${l}.`, 40, 748 - i * 12)] })),
    { itens: [item("QUESTÃO 02 – Segundo o texto, a oitava linha termina com:", 40, 680)] },
    ...["A", "B", "C", "D"].map((l, i) => ({ itens: [item(`${l}) q2 alternativa ${l}.`, 40, 668 - i * 12)] })),
    { itens: [item("INFORMÁTICA", 200, 600)] },
    { itens: [item("QUESTÃO 03 – Em um editor de planilhas ficticio, o atalho para salvar e:", 40, 580)] },
    ...["A", "B", "C", "D"].map((l, i) => ({ itens: [item(`${l}) q3 alternativa ${l}.`, 40, 568 - i * 12)] })),
  ];
  const paginas = [capa, paginaTexto, paginaQuestoes].map((linhas, i) => ({ numero: i + 1, texto: textoDasLinhas(linhas), linhas }));
  const { questoes } = extrairQuestoesDoTexto(paginas);
  assert.equal(questoes.length, 3);
  const [primeira] = questoes;
  assert.equal(primeira.textos_base.length, 1);
  assert.equal(primeira.textos_base[0].confiavel, true, primeira.textos_base[0].motivo);
  assert.equal(primeira.textos_base[0].linhas_numeradas, true);
  const normalizada = normalizarQuestao({ ...primeira, gabarito: null, motivos_juncao: [] }, {}, { materia_id: null, assunto_id: null, confidence: "nenhuma", motivo: "" });
  for (const [i, t] of corpo.entries()) assert.match(normalizada.enunciado, new RegExp(`^\\[${numero(i + 1)}\\] ${t.replace(/[.,]/g, "\\$&")}$`, "m"));
  assert.doesNotMatch(normalizada.enunciado, /texto, 0\d /);
});

test("TBL-J) linha JUSTIFICADA (todos os espaços largos e parecidos) não é fronteira de coluna; espaço isolado destoante continua recusado", () => {
  // Linha 04 justificada: 4 espaços de ~2,8 alturas entre as palavras.
  const justificada = { itens: [item("04", 40, 664), item("palavras", 67, 664), item("bem", 135, 664), item("afastadas", 178, 664), item("aqui", 251, 664)] };
  const outras = [1, 2, 3, 5].map((n) => linhaNumerada(numero(n), `linha comum numero ${n},`, 700 - (n - 1) * 12));
  const linhas = [...outras.slice(0, 3), justificada, outras[3]];
  const resultado = reconstruirTextoBase([{ texto: textoDasLinhas(linhas), itens: null, linhas }]);
  assert.equal(resultado.confiavel, true, resultado.motivo);
  // O espaço largo vira "\t" na linha reconstruída (a normalização o reduz a espaço).
  assert.match(resultado.texto, /^\[04\] palavras\s+bem\s+afastadas\s+aqui$/m);
  // Mesma linha com espaços normais e UM espaço de 5 alturas no meio: possível segunda coluna.
  const destoante = { itens: [item("04", 40, 664), item("coluna", 67, 664), item("um", 100, 664), item("coluna", 160, 664), item("dois", 193, 664)] };
  const recusado = reconstruirTextoBase([{ texto: textoDasLinhas([...outras.slice(0, 3), destoante, outras[3]]), itens: null, linhas: [...outras.slice(0, 3), destoante, outras[3]] }]);
  assert.equal(recusado.confiavel, false);
  assert.match(recusado.motivo, /lacuna horizontal interna/);
});
