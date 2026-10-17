import assert from "node:assert/strict";
import test from "node:test";
import { extrairQuestoesDoTexto } from "../scripts/importador-provas/lib/extrairQuestoes.mjs";

// PAPIRO — PoC do importador de provas: extração de questões a partir de
// texto já extraído de PDF. Fixture 100% sintética, escrita à mão para
// este teste — nenhum trecho vem do QConcursos ou de qualquer prova real.

const PAGINA_1 = [
  "PROVA DE TESTE SINTETICA - NAO E CONTEUDO REAL DE CONCURSO",
  "Texto 1 para responder as questoes de 1 a 2.",
  "Lorem ipsum ficticio de teste, sem relacao com nenhuma prova real.",
  "",
  "1. Primeira questao de teste com enunciado",
  "em multiplas linhas antes da primeira alternativa.",
  "a) alternativa A da questao 1",
  "b) alternativa B da questao 1",
  "c) alternativa C da questao 1",
  "d) alternativa D da questao 1",
  "e) alternativa E da questao 1",
  "",
  "2. Segunda questao, ainda associada ao mesmo texto-base.",
  "a) alternativa A da questao 2",
  "b) alternativa B da questao 2",
  "c) alternativa C da questao 2",
  "d) alternativa D da questao 2",
  "",
  "3. Terceira questao comeca aqui no fim da pagina 1 e continua",
].join("\n");

const PAGINA_2 = [
  "na pagina 2 com o resto do enunciado antes das alternativas.",
  "a) alternativa A da questao 3",
  "b) alternativa B da questao 3",
  "c) alternativa C da questao 3",
  "d) alternativa D da questao 3",
  "",
  "4. Quarta questao tem so 3 alternativas de proposito, para testar alternativa faltante.",
  "a) alternativa A da questao 4",
  "b) alternativa B da questao 4",
  "c) alternativa C da questao 4",
].join("\n");

function extrairFixturePadrao() {
  return extrairQuestoesDoTexto([
    { numero: 1, texto: PAGINA_1 },
    { numero: 2, texto: PAGINA_2 },
  ]);
}

test("A) detecta as 4 questões na ordem certa, numeradas 1-4", () => {
  const { questoes } = extrairFixturePadrao();
  assert.deepEqual(questoes.map((q) => q.numero_original), [1, 2, 3, 4]);
});

test("B) prova normal A-E: questão 1 tem 5 alternativas, letras corretas, sem alternativa faltante", () => {
  const { questoes } = extrairFixturePadrao();
  const q1 = questoes[0];
  assert.deepEqual(q1.alternativas.map((a) => a.letra), ["A", "B", "C", "D", "E"]);
  assert.equal(q1.alternativas[0].texto, "alternativa A da questao 1");
  assert.equal(q1.alternativa_faltante, false);
});

test("C) questão multiline: enunciado da questão 1 junta as duas linhas antes da primeira alternativa", () => {
  const { questoes } = extrairFixturePadrao();
  const q1 = questoes[0];
  assert.match(q1.enunciado, /Primeira questao de teste com enunciado\nem multiplas linhas antes da primeira alternativa\./);
});

test("D) texto-base: questões 1 e 2 compartilham o mesmo texto_base_id, com o conteúdo do texto associado", () => {
  const { questoes } = extrairFixturePadrao();
  const [q1, q2] = questoes;
  assert.ok(q1.texto_base_id, "esperava texto_base_id preenchido na questão 1");
  assert.equal(q1.texto_base_id, q2.texto_base_id);
  assert.match(q1.texto_base, /Texto 1 para responder as questoes de 1 a 2\./);
  assert.match(q1.texto_base, /Lorem ipsum/);
});

test("E) texto-base não se propaga para além do intervalo declarado (\"questões de 1 a 2\") — questão 3 não tem texto_base_id", () => {
  const { questoes } = extrairFixturePadrao();
  const q3 = questoes[2];
  assert.equal(q3.texto_base_id, null);
});

test("F) questão atravessando página: questão 3 começa na página 1 e termina na página 2", () => {
  const { questoes } = extrairFixturePadrao();
  const q3 = questoes[2];
  assert.equal(q3.pagina_origem, 1);
  assert.equal(q3.atravessa_pagina, true);
  assert.match(q3.enunciado, /Terceira questao comeca aqui no fim da pagina 1 e continua\nna pagina 2 com o resto do enunciado antes das alternativas\./);
  assert.deepEqual(q3.alternativas.map((a) => a.letra), ["A", "B", "C", "D"]);
});

test("G) questão que não atravessa página (questão 1, inteira na página 1) marca atravessa_pagina=false", () => {
  const { questoes } = extrairFixturePadrao();
  const q1 = questoes[0];
  assert.equal(q1.pagina_origem, 1);
  assert.equal(q1.atravessa_pagina, false);
});

test("H) alternativa faltante: questão 4 tem só 3 alternativas (A-C) e é marcada alternativa_faltante=true", () => {
  const { questoes } = extrairFixturePadrao();
  const q4 = questoes[3];
  assert.deepEqual(q4.alternativas.map((a) => a.letra), ["A", "B", "C"]);
  assert.equal(q4.alternativa_faltante, true);
  assert.equal(q4.pagina_origem, 2);
});

test("I) letras minúsculas (a/b/c) são normalizadas para maiúsculas na saída", () => {
  const { questoes } = extrairFixturePadrao();
  for (const questao of questoes) {
    for (const alternativa of questao.alternativas) {
      assert.equal(alternativa.letra, alternativa.letra.toUpperCase());
    }
  }
});

test("J) uma letra ausente (ex.: A, C, D, sem B) é tratada como alternativa faltante — as letras encontradas são extraídas normalmente, nunca descartadas", () => {
  const { questoes } = extrairQuestoesDoTexto([
    {
      numero: 1,
      texto: ["1. Questao com uma letra faltando.", "a) alternativa A", "c) alternativa C (sem B no meio)", "d) alternativa D"].join("\n"),
    },
  ]);
  const q1 = questoes[0];
  assert.deepEqual(q1.alternativas.map((a) => a.letra), ["A", "C", "D"]);
  assert.equal(q1.alternativa_faltante, true);
});

test("K) números fora da sequência (ex.: um artigo de lei citado no enunciado) nunca são tratados como questão nova", () => {
  const { questoes, numerosIgnorados } = extrairQuestoesDoTexto([
    {
      numero: 1,
      texto: [
        "1. Questao que cita o artigo 5 da lei fictícia de teste, sem relação com nenhum artigo real.",
        "a) alternativa A",
        "b) alternativa B",
        "c) alternativa C",
        "d) alternativa D",
        "",
        "2. Segunda questao normal.",
        "a) alternativa A",
        "b) alternativa B",
        "c) alternativa C",
        "d) alternativa D",
      ].join("\n"),
    },
  ]);
  assert.deepEqual(questoes.map((q) => q.numero_original), [1, 2]);
  // "artigo 5" não está no início de linha, então nunca chega a ser
  // candidato — nem precisa ser filtrado como número ignorado.
  assert.ok(!numerosIgnorados.includes(5));
});

test("L) um número candidato que não encaixa em nenhuma sequência válida aparece em numerosIgnorados, mas não gera questão", () => {
  const { questoes, numerosIgnorados } = extrairQuestoesDoTexto([
    {
      numero: 1,
      texto: [
        "1. Primeira questao normal.",
        "a) alternativa A",
        "b) alternativa B",
        "c) alternativa C",
        "d) alternativa D",
        "",
        "7. Número solto no início de linha, sem sequência que o conecte a questão nenhuma.",
        "",
        "2. Segunda questao normal, continuando a sequência real (1, depois 2).",
        "a) alternativa A",
        "b) alternativa B",
        "c) alternativa C",
        "d) alternativa D",
      ].join("\n"),
    },
  ]);
  assert.deepEqual(questoes.map((q) => q.numero_original), [1, 2]);
  assert.ok(numerosIgnorados.includes(7));
});

test("O) referência minúscula a 'texto N' DENTRO do enunciado (ex.: '...segundo o\\ntexto 2.', quebra de linha incidental do PDF) nunca é tratada como um novo texto-base — só 'Texto'/'TEXTO' capitalizado conta como cabeçalho", () => {
  const { questoes } = extrairQuestoesDoTexto([
    {
      numero: 1,
      texto: [
        "Texto 1 - Titulo do texto-base real.",
        "Conteudo fictício do texto-base de teste.",
        "",
        "1. Assinale a alternativa correta, segundo o",
        "texto 1.",
        "a) alternativa A",
        "b) alternativa B",
        "c) alternativa C",
        "d) alternativa D",
        "",
        "2. Segunda questao qualquer, sem nenhum texto-base novo.",
        "a) alternativa A",
        "b) alternativa B",
        "c) alternativa C",
        "d) alternativa D",
      ].join("\n"),
    },
  ]);
  const [q1, q2] = questoes;
  assert.equal(q1.texto_base_id, "TB1");
  assert.match(q1.enunciado, /segundo o\ntexto 1\./);
  // Sem faixa declarada no cabeçalho ("Texto 1 - Titulo..." não diz
  // "para as questões X a Y"), o padrão é conservador: só a questão 1
  // (onde o cabeçalho foi encontrado) herda o texto-base — nunca se
  // propaga indefinidamente para a frente.
  assert.equal(q2.texto_base_id, null);
});

test("N) alternativas em DUAS COLUNAS na mesma linha física (A/C numa linha, B/D na linha de baixo, separadas por tab) são extraídas e reordenadas corretamente — mesmo a extração do PDF entregando a ordem A, C, B, D", () => {
  const { questoes } = extrairQuestoesDoTexto([
    {
      numero: 1,
      texto: [
        "1. Questao com alternativas em duas colunas, como em algumas provas reais.",
        "A ⇒ texto da alternativa A.\tC ⇒ texto da alternativa C.",
        "B ⇒ texto da alternativa B.\tD ⇒ texto da alternativa D.",
      ].join("\n"),
    },
  ]);
  const q1 = questoes[0];
  // Apresentação final sempre em ordem alfabética, mesmo com extração
  // em ordem A, C, B, D.
  assert.deepEqual(q1.alternativas.map((a) => a.letra), ["A", "B", "C", "D"]);
  assert.equal(q1.alternativas[0].texto, "texto da alternativa A.");
  assert.equal(q1.alternativas[1].texto, "texto da alternativa B.");
  assert.equal(q1.alternativas[2].texto, "texto da alternativa C.");
  assert.equal(q1.alternativas[3].texto, "texto da alternativa D.");
  assert.equal(q1.alternativa_faltante, false);
});

test("P) alternativa no formato 'letra. ( ) texto' / 'letra. ( X ) texto' (checkbox) é reconhecida — formato visto em prova real (FEPESE/PMBC 2014)", () => {
  const { questoes } = extrairQuestoesDoTexto([
    {
      numero: 1,
      texto: [
        "1. Questão com formato de caixa de marcação.",
        "a. ( \t) primeira alternativa",
        "b. ( X ) segunda alternativa, marcada como correta",
        "c. ( \t) terceira alternativa",
        "d. ( \t) quarta alternativa",
      ].join("\n"),
    },
  ]);
  const q1 = questoes[0];
  assert.deepEqual(q1.alternativas.map((a) => a.letra), ["A", "B", "C", "D"]);
  assert.equal(q1.alternativas[0].texto, "primeira alternativa");
  assert.equal(q1.alternativa_faltante, false);
});

test("Q) cabeçalho de bloco/matéria ('Nome N questões') reinicia a numeração IMPRESSA em 1, mas numero_original continua uma posição GLOBAL corrida — caso real FEPESE/PMBC 2014", () => {
  const { questoes } = extrairQuestoesDoTexto([
    {
      numero: 1,
      texto: [
        "Estudos Sociais \t5 questões",
        "4. Questão de Estudos Sociais.",
        "a) alt A",
        "b) alt B",
        "c) alt C",
        "d) alt D",
        "5. Outra questão de Estudos Sociais.",
        "a) alt A",
        "b) alt B",
        "c) alt C",
        "d) alt D",
        "Português \t5 questões",
        "1. Primeira questão de Português.",
        "a) alt A",
        "b) alt B",
        "c) alt C",
        "d) alt D",
        "2. Segunda questão de Português.",
        "a) alt A",
        "b) alt B",
        "c) alt C",
        "d) alt D",
      ].join("\n"),
    },
  ]);
  assert.equal(questoes.length, 4);
  // numero_impresso reinicia por matéria; numero_original é a posição
  // corrida real (1, 2, 3, 4), nunca o número impresso bruto.
  assert.deepEqual(
    questoes.map((q) => [q.numero_original, q.numero_impresso, q.materia_detectada]),
    [
      [1, 4, "Estudos Sociais"],
      [2, 5, "Estudos Sociais"],
      [3, 1, "Português"],
      [4, 2, "Português"],
    ],
  );
});

test("R) documento SEM nenhum cabeçalho de bloco nunca tem materia_detectada preenchida — numero_original === numero_impresso sempre (caso ACAFE)", () => {
  const { questoes } = extrairQuestoesDoTexto([
    {
      numero: 1,
      texto: ["1. Primeira questão.", "a) alt A", "b) alt B", "c) alt C", "d) alt D"].join("\n"),
    },
  ]);
  assert.equal(questoes[0].materia_detectada, null);
  assert.equal(questoes[0].numero_original, questoes[0].numero_impresso);
});

test("S) contagem declarada no cabeçalho ('3 questões') diferente da quantidade efetivamente reconhecida no bloco marca contagem_materia_divergente=true em TODAS as questões desse bloco — nunca desloca a numeração global dos blocos seguintes", () => {
  const { questoes } = extrairQuestoesDoTexto([
    {
      numero: 1,
      texto: [
        "Bloco Incompleto \t3 questões",
        "1. Só uma questão neste bloco, mas o cabeçalho prometeu 3.",
        "a) alt A",
        "b) alt B",
        "c) alt C",
        "d) alt D",
        "Bloco Seguinte \t1 questões",
        "1. Única questão do bloco seguinte.",
        "a) alt A",
        "b) alt B",
        "c) alt C",
        "d) alt D",
      ].join("\n"),
    },
  ]);
  assert.equal(questoes.length, 2);
  assert.equal(questoes[0].contagem_materia_divergente, true);
  // O bloco seguinte, cuja contagem BATE (1 declarada, 1 encontrada),
  // não é afetado pela divergência do bloco anterior — nem na flag, nem
  // na numeração global (continua 1, 2 corridos, sem buraco).
  assert.equal(questoes[1].contagem_materia_divergente, false);
  assert.deepEqual(questoes.map((q) => q.numero_original), [1, 2]);
});

test("M) alternativas com marcador de seta ('A ⇒', 'B →') são reconhecidas, mesmo sem parênteses — formato visto em prova real (ACAFE)", () => {
  const { questoes } = extrairQuestoesDoTexto([
    {
      numero: 1,
      texto: [
        "1. Questão com marcador de seta em vez de parênteses.",
        "A ⇒ alternativa A de teste",
        "B ⇒ alternativa B de teste",
        "C → alternativa C de teste (seta diferente, mesmo formato)",
        "D ⇒ alternativa D de teste",
      ].join("\n"),
    },
  ]);
  const q1 = questoes[0];
  assert.deepEqual(q1.alternativas.map((a) => a.letra), ["A", "B", "C", "D"]);
  assert.equal(q1.alternativas[0].texto, "alternativa A de teste");
  assert.equal(q1.alternativa_faltante, false);
});
