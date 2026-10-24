import assert from "node:assert/strict";
import test from "node:test";
import { extrairQuestoesDoTexto } from "../scripts/importador-provas/lib/extrairQuestoes.mjs";
import { normalizarQuestao } from "../scripts/importador-provas/lib/normalizar.mjs";
import { reconstruirTextoBase, referenciasAoTexto } from "../scripts/importador-provas/lib/textoBase.mjs";

// PAPIRO — texto-base compartilhado. Fixtures 100% sintéticas, escritas à
// mão para este teste — nenhum trecho vem de prova real.

const CABECALHO = "PROVA SINTETICA 0000 - CABECALHO CORRIDO";

function alternativas(prefixo) {
  return ["A", "B", "C", "D", "E"].map((l) => `${l}) ${prefixo} alternativa ${l}.`);
}

const TEXTO_LONGO = [
  "O farol de papel",
  "Autoria ficticia",
  "Era uma vez um farol feito de papel que iluminava uma cidade inventada para este teste.",
  "Os moradores acreditavam que a luz vinha das palavras escritas nas paredes do farol.",
  "Quando chovia, as palavras escorriam e a cidade ficava escura durante a noite inteira.",
  "Um dia, uma menina decidiu escrever as palavras por dentro, onde a chuva nao alcancava.",
  "Desde entao, o farol brilha mesmo nas tempestades, e ninguem lembra quem teve a ideia.",
];

// Três páginas com o mesmo cabeçalho corrido no topo (removido pelo
// extrator): a 2ª abre com o título de seção e traz o texto sem cabeçalho
// "Texto N"; a 3ª traz as questões.
function provaComTextoImplicito() {
  return extrairQuestoesDoTexto([
    { numero: 1, texto: [CABECALHO, "INSTRUCOES DA CAPA", "1. Leia com atencao.", "2. Use caneta azul."].join("\n") },
    { numero: 2, texto: [CABECALHO, "LÍNGUA PORTUGUESA", ...TEXTO_LONGO].join("\n") },
    {
      numero: 3,
      texto: [
        CABECALHO,
        "QUESTÃO 01 – Segundo o texto, a luz do farol vinha:",
        ...alternativas("q1"),
        "QUESTÃO 02 – Assinale a alternativa em que a palavra esta grafada corretamente.",
        ...alternativas("q2"),
        "QUESTÃO 03 – No texto, a decisao da menina significa que:",
        ...alternativas("q3"),
        "Para responder às questões 04 e 05, considere o seguinte fragmento do texto:",
        "“as palavras escorriam e a cidade ficava escura”.",
        "QUESTÃO 04 – No fragmento supracitado, o verbo “escorriam” indica:",
        ...alternativas("q4"),
        "QUESTÃO 05 – No fragmento supracitado, a conjunção “e” expressa:",
        ...alternativas("q5"),
        "INFORMÁTICA",
        "QUESTÃO 06 – Em um editor de texto, o atalho para salvar o documento e:",
        ...alternativas("q6"),
      ].join("\n"),
    },
  ]).questoes;
}

test("TB-A) um texto-base sem cabeçalho (logo abaixo do título de seção) -> várias questões que o citam", () => {
  const questoes = provaComTextoImplicito();
  const [q1, , q3] = questoes;
  assert.equal(q1.textos_base.length, 1);
  assert.equal(q1.textos_base[0].tipo, "implicito");
  assert.match(q1.textos_base[0].texto, /^O farol de papel\nAutoria ficticia\nEra uma vez/);
  assert.equal(q3.textos_base[0].id, q1.textos_base[0].id);
  assert.ok(!/LÍNGUA PORTUGUESA|CABECALHO/.test(q1.textos_base[0].texto), "título de seção e cabeçalho corrido não entram no texto");
});

test("TB-B) a questão normalizada é autossuficiente: texto-base + linha em branco + comando, sem duplicar nada", () => {
  const [q1] = provaComTextoImplicito();
  const normalizada = normalizarQuestao({ ...q1, gabarito: null, motivos_juncao: [] }, {}, { materia_id: null, assunto_id: null, confidence: "nenhuma", motivo: "" });
  assert.equal(normalizada.enunciado, `${TEXTO_LONGO.join("\n")}\n\nSegundo o texto, a luz do farol vinha:`);
  assert.equal(normalizada._interno.enunciado_comando, "Segundo o texto, a luz do farol vinha:");
  assert.equal(normalizada.enunciado.match(/O farol de papel/g).length, 1);
});

test("TB-C) questão dentro do bloco textual que não cita o texto: sem texto associado e com dependência incerta (revisão)", () => {
  const [, q2] = provaComTextoImplicito();
  assert.deepEqual(q2.textos_base, []);
  assert.match(q2.dependencia_texto_incerta, /sem citá-lo/);
});

test("TB-D) bloco \"Para responder às questões 04 e 05\" é cortado da alternativa E anterior e vai só para 04 e 05", () => {
  const questoes = provaComTextoImplicito();
  const [, , q3, q4, q5] = questoes;
  assert.equal(q3.alternativas.at(-1).texto, "q3 alternativa E.");
  assert.equal(q3.alternativa_suspeita, null);
  for (const q of [q4, q5]) {
    assert.equal(q.textos_base.length, 1, `questão ${q.numero_original}`);
    assert.equal(q.textos_base[0].tipo, "apoio");
    assert.match(q.textos_base[0].texto, /^Para responder às questões 04 e 05[\s\S]*cidade ficava escura”\.$/);
    assert.equal(q.dependencia_texto_incerta, null);
  }
});

test("TB-E) questão sem texto-base (outra seção, \"editor de texto\"): nada associado, nada sinalizado", () => {
  const q6 = provaComTextoImplicito()[5];
  assert.equal(q6.materia_detectada, "INFORMÁTICA");
  assert.deepEqual(q6.textos_base, []);
  assert.equal(q6.texto_base_id, null);
  assert.equal(q6.dependencia_texto_incerta, null);
});

test("TB-F) dois textos-base na mesma prova: cada questão recebe o texto que cita; \"textos 1 e 2\" recebe os dois; \"segundo o texto\" sem número recebe o mais recente", () => {
  const { questoes } = extrairQuestoesDoTexto([
    {
      numero: 1,
      texto: [
        "Texto 1 - Primeiro texto ficticio",
        "Conteudo do primeiro texto, inventado para o teste.",
        "",
        "1. Segundo o texto 1, o conteudo e:",
        "a) um", "b) dois", "c) tres", "d) quatro",
        "Texto 2 - Segundo texto ficticio",
        "Conteudo do segundo texto, tambem inventado.",
        "",
        "2. De acordo com o texto 2, o conteudo e:",
        "a) um", "b) dois", "c) tres", "d) quatro",
        "3. Considerando os textos 1 e 2, ambos:",
        "a) um", "b) dois", "c) tres", "d) quatro",
        "4. Segundo o texto, a palavra final e:",
        "a) um", "b) dois", "c) tres", "d) quatro",
      ].join("\n"),
    },
  ]);
  const [q1, q2, q3, q4] = questoes;
  assert.deepEqual(q1.textos_base.map((t) => t.id), ["TB1"]);
  assert.equal(q1.alternativas.at(-1).texto, "quatro", "o Texto 2 não fica grudado na alternativa D da questão 1");
  assert.deepEqual(q2.textos_base.map((t) => t.id), ["TB2"]);
  assert.deepEqual(q3.textos_base.map((t) => t.id).sort(), ["TB1", "TB2"]);
  assert.deepEqual(q4.textos_base.map((t) => t.id), ["TB2"]);
  assert.match(q2.textos_base[0].texto, /^Texto 2 - Segundo texto ficticio\nConteudo do segundo texto/);
});

test("TB-G) texto-base atravessando página: as duas partes entram em ordem, sem o cabeçalho corrido", () => {
  const { questoes } = extrairQuestoesDoTexto([
    { numero: 1, texto: [CABECALHO, "Texto 1 - Texto longo", "Primeira parte do texto, na pagina 1."].join("\n") },
    { numero: 2, texto: [CABECALHO, "Segunda parte do texto, na pagina 2.", "", "1. Segundo o texto, as partes sao:", "a) um", "b) dois", "c) tres", "d) quatro"].join("\n") },
    { numero: 3, texto: [CABECALHO, "2. Outra questao qualquer de outro assunto.", "a) um", "b) dois", "c) tres", "d) quatro"].join("\n") },
  ]);
  assert.equal(questoes[0].textos_base[0].texto, "Texto 1 - Texto longo\nPrimeira parte do texto, na pagina 1.\nSegunda parte do texto, na pagina 2.");
});

test("TB-H) referências: \"segundo o texto\", \"l. 34-35\", \"linhas 10 e 11\", \"trecho\" contam; \"texto-base\" e ausência de referência não", () => {
  assert.equal(referenciasAoTexto("Segundo o texto, é correto:").texto, true);
  assert.equal(referenciasAoTexto("o fragmento (l. 34-35)").linhas, true);
  assert.equal(referenciasAoTexto("Os travessões das linhas 10 e 11").linhas, true);
  assert.equal(referenciasAoTexto("No trecho a seguir").indireta, true);
  assert.deepEqual([...referenciasAoTexto("Considerando os textos 1 e 2").numeros], [1, 2]);
  const semReferencia = referenciasAoTexto("Segunda questao, sem nenhum texto-base novo.");
  assert.equal(semReferencia.texto || semReferencia.linhas || semReferencia.indireta, false);
});

// Geometria sintética: margem numerada em x=40, texto em x=67 (x=92 na
// 1ª linha de cada parágrafo), 12 pontos entre linhas.
function item(texto, x, y) {
  return { texto, x, y, largura: texto.length * 5, altura: 10 };
}
const LINHAS = ["Primeira linha do paragrafo um,", "segunda linha do paragrafo um.", "Primeira linha do paragrafo dois,", "segunda linha do paragrafo dois,", "terceira linha do paragrafo dois."];
function itensNumerados() {
  const itens = [item("Titulo Ficticio", 200, 724)];
  LINHAS.forEach((linha, i) => {
    const y = 700 - i * 12;
    itens.push(item(String(i + 1).padStart(2, "0"), 40, y), item(linha, i === 0 || i === 2 ? 92 : 67, y));
  });
  return itens;
}

test("TB-I) reconstrução geométrica: ordem linear trocada e numeração solta -> linhas na ordem da página, numeradas e com parágrafos", () => {
  // Como a extração linear real entregou: números num bloco separado e
  // uma linha fora do lugar.
  const linear = ["Titulo Ficticio", "01", "02", "03", "04", "05", LINHAS[0], LINHAS[1], LINHAS[3], LINHAS[2], LINHAS[4]].join("\n");
  const resultado = reconstruirTextoBase([{ texto: linear, itens: itensNumerados() }]);
  assert.equal(resultado.confiavel, true);
  assert.equal(resultado.geometrico, true);
  assert.equal(
    resultado.texto,
    ["Titulo Ficticio", "", `[01] ${LINHAS[0]}`, `[02] ${LINHAS[1]}`, "", `[03] ${LINHAS[2]}`, `[04] ${LINHAS[3]}`, `[05] ${LINHAS[4]}`].join("\n"),
  );
});

test("TB-J) reconstrução geométrica que não reproduz as palavras do texto linear é recusada (não confiável)", () => {
  const linear = ["Titulo Ficticio", "01", "02", "03", "04", "05", ...LINHAS, "palavra que nao existe na geometria"].join("\n");
  const resultado = reconstruirTextoBase([{ texto: linear, itens: itensNumerados() }]);
  assert.equal(resultado.confiavel, false);
  assert.match(resultado.motivo, /mesmas palavras/);
});

// Número de linha que o PDF entrega partido em glifos: "0" + "4" colados
// (lacuna ~0) na mesma linha de base e com a mesma altura.
function itensComNumeroPartido(lacunaEntreDigitos) {
  const itens = [item("Titulo Ficticio", 200, 724)];
  LINHAS.forEach((linha, i) => {
    const y = 700 - i * 12;
    const numero = String(i + 1).padStart(2, "0");
    if (i === 3) itens.push({ texto: numero[0], x: 40, y, largura: 5, altura: 10 }, { texto: numero[1], x: 45 + lacunaEntreDigitos, y, largura: 5, altura: 10 });
    else itens.push(item(numero, 40, y));
    itens.push(item(linha, i === 0 || i === 2 ? 92 : 67, y));
  });
  return itens;
}

test("TB-N) número de linha partido em glifos COLADOS ('0' + '4') é um número só: sequência e parágrafos preservados, sem falsa 'lacuna interna'", () => {
  const linear = ["Titulo Ficticio", "01", "02", "03", "04", "05", ...LINHAS].join("\n");
  const resultado = reconstruirTextoBase([{ texto: linear, itens: itensComNumeroPartido(0) }]);
  assert.equal(resultado.confiavel, true, resultado.motivo);
  assert.equal(resultado.linhasNumeradas, true);
  assert.equal(
    resultado.texto,
    ["Titulo Ficticio", "", `[01] ${LINHAS[0]}`, `[02] ${LINHAS[1]}`, "", `[03] ${LINHAS[2]}`, `[04] ${LINHAS[3]}`, `[05] ${LINHAS[4]}`].join("\n"),
  );
});

test("TB-O) dígitos AFASTADOS na margem ('0'   '4') são ambíguos: nunca viram número por concatenação — reconstrução recusada (revisão)", () => {
  const linear = ["Titulo Ficticio", "01", "02", "03", "0", "4", "05", ...LINHAS].join("\n");
  const resultado = reconstruirTextoBase([{ texto: linear, itens: itensComNumeroPartido(6) }]);
  assert.equal(resultado.confiavel, false);
  assert.doesNotMatch(resultado.texto, /\[04\]/);
});

test("TB-K) questão que cita destaque tipográfico ou imagem fica sinalizada; alternativa anormalmente longa também", () => {
  const { questoes } = extrairQuestoesDoTexto([
    {
      numero: 1,
      texto: [
        "1. A palavra destacada em negrito na frase exerce funcao de:",
        "a) um", "b) dois", "c) tres", "d) quatro",
        "2. Analise a charge a seguir e assinale a correta.",
        "a) um", "b) dois", "c) tres", "d) quatro",
        "3. Questao comum sem nada de especial.",
        "a) um", "b) dois", "c) tres",
        `d) quatro ${"texto de rodape grudado na alternativa ".repeat(8)}`,
      ].join("\n"),
    },
  ]);
  assert.match(questoes[0].referencia_visual, /destacada/);
  assert.match(questoes[1].referencia_visual, /charge a seguir/);
  assert.equal(questoes[2].referencia_visual, null);
  assert.match(questoes[2].alternativa_suspeita, /alternativa D/);
});
