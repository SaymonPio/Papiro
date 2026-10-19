import assert from "node:assert/strict";
import test from "node:test";
import { juntarQuebrasArtificiais, soMudouEspacoEmBranco } from "../scripts/importador-provas/lib/quebrasDeLinha.mjs";

// PAPIRO — quebras de linha artificiais do PDF. Textos 100% sintéticos.

const LONGA = "Considere que o arquivo ficticio.docx, criado no editor de textos, esta armazenado na unidade";

test("QL-A) continuação da mesma frase (linha cheia, sem pontuação final) é juntada com um espaço", () => {
  const texto = `${LONGA} local de um computador qualquer, qual\nopção de configuração corresponde ao recurso?`;
  assert.equal(juntarQuebrasArtificiais(texto), `${LONGA} local de um computador qualquer, qual opção de configuração corresponde ao recurso?`);
});

test("QL-B) continuação que começa com maiúscula ou aspas (nome próprio, citação) também é juntada", () => {
  const texto = `${LONGA} quando o usuario abre o\nExcel do pacote, e a palavra “pessoas” for substituída por\n“um indivíduo”, o que ocorre?`;
  assert.equal(juntarQuebrasArtificiais(texto), `${LONGA} quando o usuario abre o Excel do pacote, e a palavra “pessoas” for substituída por “um indivíduo”, o que ocorre?`);
});

test("QL-C) linhas numeradas [NN] nunca são tocadas; parágrafos (linha em branco) ficam", () => {
  const texto = [`[01] ${LONGA}`, "[02] segunda linha numerada sem ponto final", "", `${LONGA} e continua`, "aqui."].join("\n");
  const resultado = juntarQuebrasArtificiais(texto);
  assert.equal(resultado, [`[01] ${LONGA}`, "[02] segunda linha numerada sem ponto final", "", `${LONGA} e continua aqui.`].join("\n"));
});

test("QL-D) listas (I., II., 1), a), recuo) e quebra depois de dois-pontos ficam", () => {
  const texto = [`${LONGA} e analise as assertivas a seguir:`, "I. Primeira assertiva ficticia", "II. Segunda assertiva ficticia", " “Fragmento recuado de lista um”.", "a) item com letra", `${LONGA} Quais estão corretas?`].join("\n");
  assert.equal(juntarQuebrasArtificiais(texto), texto);
});

test("QL-E) título e autoria curtos e expressão isolada não são juntados", () => {
  const titulo = ["Titulo Ficticio do Texto", "Por Autoria Inventada", `${LONGA} fim.`].join("\n");
  assert.equal(juntarQuebrasArtificiais(titulo), titulo);
  const expressao = [`${LONGA} na sequência a seguir:`, "–7, 7/2 , –14, 7, X", "O número que substitui o X é:"].join("\n");
  assert.equal(juntarQuebrasArtificiais(expressao), expressao);
});

test("QL-F) quebra depois de ponto final é preservada (ambígua: pode ser parágrafo)", () => {
  const texto = `${LONGA} e o arquivo fica salvo.\nDepois disso, o usuario fecha o programa.`;
  assert.equal(juntarQuebrasArtificiais(texto), texto);
});

test("QL-G) hífen no fim da linha: dentro de URL junta sem espaço (mantém o hífen); fora de URL (separação silábica) a quebra fica", () => {
  const silabica = `${LONGA} quando o condutor for surpreendido por uma auto-
ridade de trânsito qualquer.`;
  assert.equal(juntarQuebrasArtificiais(silabica), silabica);
  const texto = `(Disponível em: https://exemplo.org/ciencia/2099/01/uma-materia-ficticia-sobre-o-cerebro-\nquando-procrastinamos – texto adaptado para esta prova).`;
  assert.equal(juntarQuebrasArtificiais(texto), "(Disponível em: https://exemplo.org/ciencia/2099/01/uma-materia-ficticia-sobre-o-cerebro-quando-procrastinamos – texto adaptado para esta prova).");
});

test("QL-H) só espaço em branco muda; idempotente; texto sem quebra é devolvido igual", () => {
  const texto = `${LONGA} local de um computador qualquer, qual\nopção de configuração corresponde ao recurso?`;
  const uma = juntarQuebrasArtificiais(texto);
  assert.equal(soMudouEspacoEmBranco(texto, uma), true);
  assert.equal(juntarQuebrasArtificiais(uma), uma);
  assert.equal(juntarQuebrasArtificiais("Enunciado de uma linha só."), "Enunciado de uma linha só.");
  assert.equal(soMudouEspacoEmBranco("a b", "a c"), false);
});

test("QL-I) maiúscula na linha seguinte só junta depois de vírgula/palavra de ligação: subtítulo e fonte ficam separados do texto", () => {
  const subtitulo = `${LONGA} e o que fazer se for vítima\nO golpe ficticio tem se tornado comum.`;
  assert.equal(juntarQuebrasArtificiais(subtitulo), subtitulo);
  const fonte = `https://exemplo.org/noticias/uma-materia-ficticia-muito-longa-sobre-cultura acesso em 16.8.26\nNa construção da coesão do texto ficticio, assinale:`;
  assert.equal(juntarQuebrasArtificiais(fonte), fonte);
  assert.equal(juntarQuebrasArtificiais(`${LONGA} no computador, com o\nExcel aberto.`), `${LONGA} no computador, com o Excel aberto.`);
  assert.equal(juntarQuebrasArtificiais(`${LONGA} de Ana,\nCarol e Luiz.`), `${LONGA} de Ana, Carol e Luiz.`);
});
