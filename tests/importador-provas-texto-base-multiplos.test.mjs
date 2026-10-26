import assert from "node:assert/strict";
import test from "node:test";
import { extrairQuestoesDoTexto } from "../scripts/importador-provas/lib/extrairQuestoes.mjs";
import { normalizarQuestao } from "../scripts/importador-provas/lib/normalizar.mjs";
import { causasDeExtracao } from "../scripts/importador-provas/lib/score.mjs";

// PAPIRO — vários textos-base independentes na mesma prova (e no mesmo
// bloco de disciplina), cada um SEM cabeçalho "Texto N": o que marca o
// início de um texto novo é a numeração de linhas que recomeça em 01 entre
// a última alternativa de uma questão e o marcador da seguinte. Sem isso,
// o texto novo grudava na alternativa E anterior e as questões seguintes
// recebiam o texto anterior, passando por todos os gates.
// Fixtures 100% sintéticas, escritas à mão para este teste.

const ALTURA = 10;
const item = (texto, x, y) => ({ texto, x, y, largura: texto.length * 5, altura: ALTURA });
const numero = (n) => String(n).padStart(2, "0");
const linhaNumerada = (n, texto, y, recuo = false) => ({ itens: [item(numero(n), 40, y), item(texto, recuo ? 92 : 67, y)] });
const linhaSimples = (texto, y, x = 40) => ({ itens: [item(texto, x, y)] });
const textoDasLinhas = (linhas) => linhas.map((l) => l.itens.map((i) => i.texto).join(" ")).join("\n");
const CABECALHO = "PROVA SINTETICA 0000 - CABECALHO CORRIDO";
const corrido = (y = 800) => linhaSimples(CABECALHO, y);

// Texto de alternativa único por questão SEM depender de dígitos: a detecção
// de cabeçalho/rodapé corrido troca dígitos por "#" e removeria
// "B) q1 ..."/"B) q2 ..." repetidos na borda de várias páginas.
const NOMES = ["zero", "um", "dois", "tres", "quatro", "cinco", "seis", "sete", "oito"];
const textoAlternativa = (n, letra) => `opcao ${letra} da questao ${NOMES[n]}.`;

// Corpo de um texto-base: abertura (título, subtítulo, autoria...) + linhas
// numeradas 01..N + fonte opcional, a partir de y.
function textoBase({ abertura = [], linhas, fonte = null, y = 780, rotulo }) {
  const saida = abertura.map((t, i) => linhaSimples(t, y - i * 12, 200));
  let atual = y - abertura.length * 12;
  for (let n = 1; n <= linhas; n++) {
    saida.push(linhaNumerada(n, `linha ${n} do texto ${rotulo} inventado para este teste sintetico,`, atual, n === 1));
    atual -= 12;
  }
  if (fonte) saida.push(linhaSimples(fonte, atual));
  return saida;
}

function questao(numeroQuestao, comando, y, { alternativas = null } = {}) {
  const alts = alternativas ?? ["A", "B", "C", "D", "E"].map((l) => `${l}) ${textoAlternativa(numeroQuestao, l)}`);
  return [linhaSimples(`QUESTÃO ${numero(numeroQuestao)} – ${comando}`, y), ...alts.map((a, i) => linhaSimples(a, y - 12 - i * 12))];
}

const paginas = (listas) => listas.map((linhas, i) => ({ numero: i + 1, texto: textoDasLinhas(linhas), linhas }));
const capa = () => [corrido(), linhaSimples("INSTRUCOES DA CAPA", 760)];
const textoA = (y = 760) => [linhaSimples("LÍNGUA PORTUGUESA", 780, 200), ...textoBase({ abertura: ["Titulo Ficticio A", "Por Autoria Ficticia"], linhas: 8, fonte: "(Fonte ficticia A, adaptado.)", y, rotulo: "A" })];

function provaDeTres({ textoB, textoC }) {
  return paginas([
    capa(),
    [corrido(), ...textoA()],
    [corrido(), ...questao(1, "De acordo com a l. 02 do texto, e correto afirmar:", 760), ...questao(2, "Segundo o texto, a ideia central e:", 670)],
    [corrido(), ...textoB, ...questao(3, "Segundo o texto, a terceira linha trata de:", 560), ...questao(4, "No texto, a palavra final da l. 05 e:", 470)],
    [corrido(), ...textoC, ...questao(5, "Conforme o texto, a l. 06 apresenta:", 560), ...questao(6, "Segundo o texto, e correto:", 470)],
  ]);
}
const textoB = () => textoBase({ abertura: ["Titulo Ficticio B", "Subtitulo Ficticio B", "Por Outra Autoria"], linhas: 6, fonte: "(Fonte ficticia B.)", rotulo: "B" });
const textoC = () => textoBase({ abertura: ["Titulo Ficticio C"], linhas: 7, rotulo: "C" });
const ids = (q) => q.textos_base.map((t) => t.id);
const conteudo = (q) => q.textos_base.map((t) => t.texto).join("\n");

test("MTB-A) um único texto-base: nada muda (texto abaixo do título de seção, sem inconsistência registrada)", () => {
  const { questoes } = extrairQuestoesDoTexto(
    paginas([capa(), [corrido(), ...textoA()], [corrido(), ...questao(1, "De acordo com a l. 02 do texto, e correto:", 760), ...questao(2, "Segundo o texto:", 670), ...questao(3, "No texto, a l. 05 diz:", 580)]]),
  );
  assert.equal(questoes.length, 3);
  for (const q of questoes) {
    assert.deepEqual(ids(q), ["TB1"]);
    assert.equal(q.textos_base[0].confiavel, true, q.textos_base[0].motivo);
    assert.equal(q.alternativas.at(-1).texto, textoAlternativa(q.numero_impresso, "E"));
    assert.equal("inconsistencias_texto_base" in q, false);
  }
});

test("MTB-B/K) dois textos com linhas recomeçando em 01: separados, cada questão recebe o seu, nada concatenado", () => {
  const { questoes } = extrairQuestoesDoTexto(provaDeTres({ textoB: textoB(), textoC: textoC() }));
  assert.equal(questoes.length, 6);
  const [q1, , q3, q4] = questoes;
  assert.deepEqual(ids(q1), ["TB1"]);
  assert.deepEqual(ids(q3), ["TB2"]);
  assert.deepEqual(ids(q4), ["TB2"]);
  assert.match(conteudo(q3), /^Titulo Ficticio B$/m);
  assert.match(conteudo(q3), /^\[01\] linha 1 do texto B/m);
  assert.doesNotMatch(conteudo(q3), /texto A/);
  // O texto A continua com as SUAS 8 linhas — nunca 8 + 6.
  assert.equal([...conteudo(q1).matchAll(/^\[\d{2}\]/gm)].length, 8);
  assert.equal([...conteudo(q3).matchAll(/^\[\d{2}\]/gm)].length, 6);
  for (const q of questoes) assert.equal(q.textos_base.every((t) => t.confiavel), true);
});

test("MTB-C) três textos-base: três blocos independentes, na ordem do documento", () => {
  const { questoes } = extrairQuestoesDoTexto(provaDeTres({ textoB: textoB(), textoC: textoC() }));
  assert.deepEqual(questoes.map((q) => ids(q).join("+")), ["TB1", "TB1", "TB2", "TB2", "TB3", "TB3"]);
  assert.match(conteudo(questoes[4]), /^Titulo Ficticio C$/m);
  assert.equal([...conteudo(questoes[4]).matchAll(/^\[\d{2}\]/gm)].length, 7);
});

test("MTB-D) texto novo no topo da página seguinte à alternativa E: a alternativa não recebe nada do texto", () => {
  const { questoes } = extrairQuestoesDoTexto(provaDeTres({ textoB: textoB(), textoC: textoC() }));
  for (const q of [questoes[1], questoes[3]]) {
    assert.equal(q.alternativas.at(-1).texto, textoAlternativa(q.numero_impresso, "E"));
    assert.equal(q.alternativa_suspeita, null);
  }
});

test("MTB-D2) texto novo na MESMA página, logo depois da alternativa E encerrada: abertura e linhas vão para o texto, não para a alternativa", () => {
  const { questoes } = extrairQuestoesDoTexto(
    paginas([
      capa(),
      [corrido(), ...textoA()],
      [
        corrido(),
        ...questao(1, "Segundo o texto:", 760),
        ...textoBase({ abertura: ["Titulo Ficticio B", "Por Outra Autoria"], linhas: 6, y: 670, rotulo: "B" }),
        ...questao(2, "Segundo o texto, a l. 03 diz:", 560),
        ...questao(3, "No texto, a l. 06 diz:", 470),
      ],
    ]),
  );
  const [q1, q2] = questoes;
  assert.equal(q1.alternativas.at(-1).texto, textoAlternativa(1, "E"));
  assert.deepEqual(ids(q2), ["TB2"]);
  assert.equal(q2.textos_base[0].confiavel, true, q2.textos_base[0].motivo);
  assert.match(conteudo(q2), /^Titulo Ficticio B$/m);
});

test("MTB-E/F) texto sem autoria e sem fonte: reconhecido pela estrutura (linhas 01..N)", () => {
  const semNada = textoBase({ linhas: 6, rotulo: "B" });
  const { questoes } = extrairQuestoesDoTexto(provaDeTres({ textoB: semNada, textoC: textoBase({ abertura: ["Titulo Ficticio C"], linhas: 6, rotulo: "C" }) }));
  assert.deepEqual(ids(questoes[2]), ["TB2"]);
  assert.match(conteudo(questoes[2]), /^\[01\] linha 1 do texto B/m);
  assert.equal(questoes[1].alternativas.at(-1).texto, textoAlternativa(2, "E"));
});

test("MTB-E2) numeração em bloco separado (como a leitura linear entrega: 01, 02... sozinhos, depois o texto) também abre texto novo", () => {
  const linhasB = Array.from({ length: 6 }, (_, i) => `linha ${i + 1} do texto B inventado para este teste sintetico,`);
  const pagina4 = [CABECALHO, "Titulo Ficticio B", ...linhasB.map((_, i) => numero(i + 1)), ...linhasB, "QUESTÃO 03 – Segundo o texto:", ..."ABCDE".split("").map((l) => `${l}) ${textoAlternativa(3, l)}`)].join("\n");
  const base = provaDeTres({ textoB: textoB(), textoC: textoC() }).slice(0, 3);
  const { questoes } = extrairQuestoesDoTexto([...base.map(({ numero: n, texto }) => ({ numero: n, texto })), { numero: 4, texto: pagina4 }]);
  assert.equal(questoes.length, 3);
  assert.equal(questoes[1].alternativas.at(-1).texto, textoAlternativa(2, "E"));
  assert.deepEqual(ids(questoes[2]), ["TB2"]);
  assert.match(conteudo(questoes[2]), /Titulo Ficticio B/);
});

test("MTB-G) lista numerada DENTRO da questão (1, 2, 3...) não vira texto-base nem é cortada", () => {
  const lista = [1, 2, 3, 4, 5, 6].map((n, i) => linhaSimples(`${n} item ${NOMES[n]} da lista do enunciado,`, 658 - i * 12));
  const { questoes } = extrairQuestoesDoTexto(
    paginas([
      capa(),
      [corrido(), ...textoA()],
      [
        corrido(),
        ...questao(1, "Segundo o texto:", 760),
        linhaSimples("QUESTÃO 02 – Ordene os itens:", 670),
        ...lista,
        ...["A", "B", "C", "D", "E"].map((l, i) => linhaSimples(`${l}) ${textoAlternativa(2, l)}`, 580 - i * 12)),
        ...questao(3, "No texto, a l. 04 diz:", 510),
      ],
    ]),
  );
  const [q1, q2] = questoes;
  assert.equal(questoes.length, 3);
  assert.equal(q1.alternativas.at(-1).texto, textoAlternativa(1, "E"));
  assert.match(q2.enunciado, /^6 item seis da lista do enunciado,$/m);
  assert.equal(questoes.flatMap((q) => q.textos_base).some((t) => t.id === "TB2"), false);
});

test("MTB-H) artigos de lei (Art. 1º, Art. 2º...) e itens \"1.\"/\"2.\" entre questões não viram linhas de texto-base", () => {
  const lei = ["Art. 1º Disposicao ficticia primeira.", "Art. 2º Disposicao ficticia segunda.", "Art. 3º Disposicao ficticia terceira.", "1. item ficticio um", "2. item ficticio dois", "3. item ficticio tres", "4. item ficticio quatro", "5. item ficticio cinco"];
  const { questoes } = extrairQuestoesDoTexto(
    paginas([
      capa(),
      [corrido(), ...textoA()],
      [corrido(), ...questao(1, "Segundo o texto:", 760), ...lei.map((l, i) => linhaSimples(l, 670 - i * 12)), ...questao(2, "Segundo o texto, e correto:", 560), ...questao(3, "No texto, a l. 03 diz:", 470)],
    ]),
  );
  assert.equal(questoes.length, 3);
  assert.deepEqual(ids(questoes[1]), ["TB1"]);
  assert.equal(questoes.flatMap((q) => q.textos_base).some((t) => t.id === "TB2"), false);
});

test("MTB-I/J) referência a linha inexistente no texto anexado -> REFERENCIA_LINHA_FORA_DO_TEXTO_BASE; linha existente passa", () => {
  const { questoes } = extrairQuestoesDoTexto(
    paginas([
      capa(),
      [corrido(), ...textoA()],
      [corrido(), ...questao(1, "De acordo com a linha 35 do texto, e correto:", 760), ...questao(2, "Segundo o texto, a l. 08 diz:", 670), ...questao(3, "No texto, as linhas 01 e 02 dizem:", 580)],
    ]),
  );
  const [q1, q2, q3] = questoes;
  assert.deepEqual(q1.inconsistencias_texto_base?.map((x) => x.codigo), ["referencia_linha_fora_do_texto_base"]);
  assert.match(q1.inconsistencias_texto_base[0].motivo, /linha 35/);
  assert.equal("inconsistencias_texto_base" in q2, false);
  assert.equal("inconsistencias_texto_base" in q3, false);
  const normalizada = normalizarQuestao({ ...q1, gabarito: null, motivos_juncao: [] }, {}, { materia_id: null, assunto_id: null, confidence: "nenhuma", motivo: "" });
  assert.ok(causasDeExtracao(normalizada).some((c) => c.codigo === "referencia_linha_fora_do_texto_base"));
});

test("MTB-I2) trecho citado com a linha \"(l. N)\" que não está naquela linha do texto anexado -> CITACAO_AUSENTE_DO_TEXTO_BASE; trecho certo passa", () => {
  const { questoes } = extrairQuestoesDoTexto(
    paginas([
      capa(),
      [corrido(), ...textoA()],
      [
        corrido(),
        ...questao(1, "Em “linha 2 do texto A” (l. 02), segundo o texto, e correto:", 760),
        ...questao(2, "Em “linha 2 do texto B” (l. 02), segundo o texto, e correto:", 670),
        ...questao(3, "Em “linha 3 do texto A inventado” (l. 2-3), segundo o texto:", 580),
      ],
    ]),
  );
  const [q1, q2, q3] = questoes;
  assert.equal("inconsistencias_texto_base" in q1, false);
  assert.deepEqual(q2.inconsistencias_texto_base?.map((x) => x.codigo), ["citacao_ausente_do_texto_base"]);
  assert.equal("inconsistencias_texto_base" in q3, false);
});

test("MTB-L) fronteira ambígua (alternativa E sem fechamento + linhas de abertura antes do 01 na mesma página): candidato descartado, extração como antes do detector", () => {
  const altsAbertas = ["A", "B", "C", "D"].map((l) => `${l}) ${textoAlternativa(1, l)}`).concat(["E) opcao E da questao um sem ponto final"]);
  const { questoes } = extrairQuestoesDoTexto(
    paginas([
      capa(),
      [corrido(), ...textoA()],
      [
        corrido(),
        ...questao(1, "Segundo o texto:", 760, { alternativas: altsAbertas }),
        ...textoBase({ abertura: ["Titulo Ficticio B"], linhas: 6, y: 670, rotulo: "B" }),
        ...questao(2, "Segundo o texto:", 560),
        ...questao(3, "No texto, a l. 02 diz:", 470),
      ],
    ]),
  );
  const [q1, q2] = questoes;
  // Sem fronteira provada, nada muda: nenhum texto novo, nenhum corte na
  // alternativa E e nenhum gate novo — o comportamento de antes do detector.
  assert.equal(questoes.flatMap((q) => q.textos_base).some((t) => t.id === "TB2"), false);
  assert.deepEqual(ids(q2), ["TB1"]);
  assert.match(q1.alternativas.at(-1).texto, /^opcao E da questao um sem ponto final\nTitulo Ficticio B\n/);
  assert.equal("inconsistencias_texto_base" in q1, false);
});

test("MTB-M) questão que cita várias partes/textos quando há mais de um texto ativo e só um foi associado -> dependência incerta", () => {
  const prova = provaDeTres({ textoB: textoB(), textoC: textoC() });
  prova[4] = { ...prova[4], texto: prova[4].texto.replace("Segundo o texto, e correto:", "As tres partes do texto constituem um unico texto, cujo objetivo e:") };
  const { questoes } = extrairQuestoesDoTexto(prova);
  assert.match(questoes[5].dependencia_texto_incerta ?? "", /mais de um texto/);
  assert.equal(questoes[4].dependencia_texto_incerta, null);
});

test("MTB-N) recomeço em 01 sozinho não basta: tabela curta numerada 01..06 entre questões (sem corpo de texto) não vira texto-base", () => {
  const tabela = [1, 2, 3, 4, 5, 6].map((n, i) => linhaNumerada(n, `codigo ${NOMES[n]}`, 670 - i * 12));
  const { questoes } = extrairQuestoesDoTexto(
    paginas([capa(), [corrido(), ...textoA()], [corrido(), ...questao(1, "Segundo o texto:", 760), ...tabela, ...questao(2, "Segundo o texto, e correto:", 560), ...questao(3, "No texto, a l. 03 diz:", 470)]]),
  );
  assert.equal(questoes.flatMap((q) => q.textos_base).some((t) => t.id === "TB2"), false);
  assert.deepEqual(ids(questoes[1]), ["TB1"]);
});

test("MTB-N2) numeração que recomeça em 01 mas não forma sequência (01, 02, 04, 07, 08, 09) não abre texto-base", () => {
  const quebrada = [1, 2, 4, 7, 8, 9].map((n, i) => linhaNumerada(n, `linha ${NOMES[n] ?? "nove"} de um bloco ficticio sem sequencia valida de numeracao de linhas para este teste,`, 670 - i * 12));
  const { questoes } = extrairQuestoesDoTexto(
    paginas([capa(), [corrido(), ...textoA()], [corrido(), ...questao(1, "Segundo o texto:", 760), ...quebrada, ...questao(2, "Segundo o texto, e correto:", 560), ...questao(3, "No texto, a l. 03 diz:", 470)]]),
  );
  assert.equal(questoes.flatMap((q) => q.textos_base).some((t) => t.id === "TB2"), false);
});

test("MTB-I3) trecho com lacuna (“pala__ra” (l. 02)) citando linha que também tem lacuna (\"______\"): não verificável, nada é sinalizado", () => {
  const textoComLacuna = [linhaSimples("LÍNGUA PORTUGUESA", 780, 200), linhaSimples("Titulo Ficticio A", 768, 200)];
  for (let n = 1; n <= 6; n++) textoComLacuna.push(linhaNumerada(n, n === 2 ? "a ________ inventada desta linha ficticia de teste," : `linha ${n} do texto A inventado para este teste sintetico,`, 756 - (n - 1) * 12, n === 1));
  const { questoes } = extrairQuestoesDoTexto(
    paginas([
      capa(),
      [corrido(), ...textoComLacuna],
      [corrido(), ...questao(1, "Segundo o texto, qual palavra substituiria “pala__ra” (l. 02)?", 760), ...questao(2, "Segundo o texto, a l. 03 diz:", 670), ...questao(3, "No texto, a l. 04 diz:", 580)],
    ]),
  );
  assert.equal("inconsistencias_texto_base" in questoes[0], false);
});

// O detector de texto numerado implícito só SEPARA um texto novo de um
// texto-base ainda ativo — o que seria herdado indevidamente pelas questões
// seguintes se o bloco novo não fosse reconhecido. Não é ele que descobre o
// primeiro texto-base de uma prova.
const semCitar = (n, y) => questao(n, "Assinale a alternativa ficticia correta:", y);

test("MTB-O1) texto-base ativo + nova parte numerada com fronteira provada: nova parte detectada", () => {
  const { questoes } = extrairQuestoesDoTexto(provaDeTres({ textoB: textoB(), textoC: textoC() }));
  // Q2 cita o texto A: ele está ativo quando o texto B aparece antes da Q3.
  assert.deepEqual(ids(questoes[1]), ["TB1"]);
  assert.deepEqual(ids(questoes[2]), ["TB2"]);
  assert.equal(questoes[2].textos_base[0].confiavel, true, questoes[2].textos_base[0].motivo);
  assert.equal(questoes[1].alternativas.at(-1).texto, textoAlternativa(2, "E"));
});

test("MTB-O2) nenhum texto-base ativo + primeiro texto numerado implícito: o detector não interfere", () => {
  const { questoes } = extrairQuestoesDoTexto(
    paginas([capa(), [corrido(), ...semCitar(1, 760)], [corrido(), ...textoB(), ...questao(2, "Segundo o texto, a l. 03 diz:", 560), ...questao(3, "No texto, a l. 05 diz:", 470)]]),
  );
  assert.equal(questoes.length, 3);
  assert.equal(questoes.flatMap((q) => q.textos_base).length, 0);
  // Comportamento de antes do detector: nada cortado da Q1, nenhum texto associado à Q2.
  assert.match(questoes[0].alternativas.at(-1).texto, /^opcao E da questao um\.\n[^]*linha 1 do texto B/);
  assert.match(questoes[1].dependencia_texto_incerta ?? "", /nenhum texto-base foi associado/);
});

test("MTB-O3) texto-base antigo que já saiu do bloco (mais de 3 questões sem citá-lo): o detector não interfere", () => {
  const { questoes } = extrairQuestoesDoTexto(
    paginas([
      capa(),
      [corrido(), ...textoA()],
      [corrido(), ...questao(1, "Segundo o texto, e correto:", 760), ...semCitar(2, 670), ...semCitar(3, 580)],
      [corrido(), ...semCitar(4, 760), ...semCitar(5, 670)],
      [corrido(), ...textoB(), ...questao(6, "Segundo o texto, a l. 03 diz:", 560), ...questao(7, "No texto, a l. 05 diz:", 470)],
    ]),
  );
  assert.equal(questoes.length, 7);
  assert.equal(questoes.flatMap((q) => q.textos_base).some((t) => t.id === "TB2"), false);
  assert.match(questoes[4].alternativas.at(-1).texto, /^opcao E da questao cinco\.\n[^]*linha 1 do texto B/);
  assert.match(questoes[5].dependencia_texto_incerta ?? "", /nenhum texto-base foi associado/);
});
