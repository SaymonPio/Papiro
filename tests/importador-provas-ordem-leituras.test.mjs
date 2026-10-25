import assert from "node:assert/strict";
import test from "node:test";
import { assinaturaDaQuestao, compararQuestoes, divergenciaDeOrdem, problemasDeIntegridade } from "../scripts/importador-provas/lib/integridade.mjs";
import { aplicarDecisoesDeLeitura } from "../scripts/importador-provas/lib/decisoesLeitura.mjs";

// PAPIRO — divergência de ORDEM entre as leituras linear e posicional do
// mesmo PDF (checado numa prova real: Fundatec/PC-RS 2025 Escrivão-Inspetor,
// P2 TIPO 1 — a frase que explica a fórmula saiu, na leitura linear, depois
// do comando da pergunta, e passou como "reordenada" sem problema) e a
// decisão de leitura declarada no staging. Fixtures 100% sintéticas —
// nenhum conteúdo de prova real.

const ALTS = ["Primeira opção.", "Segunda opção.", "Terceira opção.", "Quarta opção.", "Quinta opção."];
const questao = (numero, enunciado, extras = {}) => ({ numero_original: numero, enunciado, alternativas: ALTS.map((texto, i) => ({ letra: "ABCDE"[i], texto })), ...extras });

const A = "Considere o cenário sintético descrito pelo examinador neste item.";
const B = "Nesse cenário, cada servidor atende exatamente três pedidos por dia.";
const C = "Com base nessas informações, é correto afirmar que:";

// Linear escolhida, posicional como referência: a mesma comparação que o cli faz.
function problemasDaEscolhida(escolhida, posicional) {
  const comparacao = compararQuestoes([escolhida], [posicional]).get(escolhida.numero_original);
  return problemasDeIntegridade(escolhida, { comparacao, referenciaPosicional: true }).map((p) => p.codigo);
}

test("ORD-A) mesma ordem nas duas leituras (A B C × A B C) = OK", () => {
  const q = questao(1, [A, B, C].join("\n"));
  assert.equal(divergenciaDeOrdem(q, questao(1, [A, B, C].join("\n"))), null);
  assert.deepEqual(problemasDaEscolhida(q, questao(1, [A, B, C].join("\n"))), []);
});

test("ORD-B) linear A C B × posicional A B C = ordem_leituras_divergente (revisão), com o trecho deslocado", () => {
  const linear = questao(1, [A, C, B].join("\n"));
  const posicional = questao(1, [A, B, C].join("\n"));
  const ordem = divergenciaDeOrdem(linear, posicional);
  assert.ok(ordem && ordem.deslocadas > 0);
  assert.equal(ordem.cobertura, 1, "mesmo conteúdo: todas as palavras existem nas duas leituras");
  assert.deepEqual(problemasDaEscolhida(linear, posicional), ["ordem_leituras_divergente"]);
});

test("ORD-C) mesma frase quebrada em linhas diferentes = OK", () => {
  const linear = questao(1, "Considere o cenário sintético\ndescrito pelo examinador neste item. Nesse cenário, cada servidor\natende exatamente três pedidos por dia.");
  const posicional = questao(1, "Considere o cenário sintético descrito pelo\nexaminador neste item. Nesse cenário,\ncada servidor atende exatamente três pedidos\npor dia.");
  assert.equal(divergenciaDeOrdem(linear, posicional), null);
  assert.deepEqual(problemasDaEscolhida(linear, posicional), []);
});

test("ORD-D) diferença só de espaços, pontuação tipográfica e hífen de quebra de linha = OK", () => {
  const linear = questao(1, "Considere  o cenário — “sintético” — descrito pelo exami-\nnador neste item; é correto afirmar que:");
  const posicional = questao(1, "Considere o cenário - \"sintético\" - descrito pelo examinador neste item: é correto afirmar que...");
  assert.equal(divergenciaDeOrdem(linear, posicional), null);
  assert.deepEqual(problemasDaEscolhida(linear, posicional), []);
});

test("ORD-E) fórmula + explicação + pergunta × fórmula + pergunta + explicação = revisão", () => {
  const formula = "O modelo sintético do exemplo é dado por:\ny = 2 + 0,8x";
  const explicacao = "Aqui, x indica a quantidade de turnos cumpridos e y, o total previsto de chamados.";
  const pergunta = "Supondo os dados fictícios acima, assinale a alternativa verdadeira:";
  const linear = questao(1, [formula, pergunta, explicacao].join("\n"));
  const posicional = questao(1, [formula, explicacao, pergunta].join("\n"));
  const ordem = divergenciaDeOrdem(linear, posicional);
  assert.ok(ordem, "a explicação da fórmula mudou de lugar");
  assert.deepEqual(problemasDaEscolhida(linear, posicional), ["ordem_leituras_divergente"]);
});

test("ORD-F) texto-base com linhas numeradas [nn] na linear e parágrafo contínuo na posicional, mesma sequência = não bloqueia só por isso", () => {
  const numerado = "[01] Primeira linha sintética do texto-base que segue\n[02] na segunda linha e termina a ideia,\n[03] enquanto a terceira linha encerra o parágrafo.";
  const continuo = "Primeira linha sintética do texto-base que segue na segunda linha e termina a ideia, enquanto a terceira linha encerra o parágrafo.";
  const inline = "01\tPrimeira linha sintética do texto-base que segue 02 na segunda linha e termina a ideia, 03 enquanto a terceira linha encerra o parágrafo.";
  const agrupado = "01\n02\n03\nPrimeira linha sintética do texto-base que segue\nna segunda linha e termina a ideia,\nenquanto a terceira linha encerra o parágrafo.";
  const comTexto = (texto) => questao(1, C, { textos_base: [{ id: "TB1", texto }] });
  assert.equal(divergenciaDeOrdem(comTexto(numerado), comTexto(continuo)), null, "número de linha que só existe numa leitura não pesa na ordem");
  assert.equal(divergenciaDeOrdem(comTexto(numerado), comTexto(inline)), null, "número de linha no mesmo lugar, agrupado no parágrafo");
  assert.equal(divergenciaDeOrdem(comTexto(agrupado), comTexto(numerado)), null, "coluna de números de linha agrupada antes do texto");
  assert.deepEqual(problemasDaEscolhida(comTexto(numerado), comTexto(continuo)), []);
});

test("ORD-G) texto-base com dois parágrafos trocados entre as leituras = revisão (o texto-base entra na comparação de ordem)", () => {
  const p1 = "Primeiro parágrafo sintético com a tese central do autor sobre o tema.";
  const p2 = "Segundo parágrafo sintético com o contra-argumento e a conclusão final.";
  const comTexto = (texto) => questao(1, C, { textos_base: [{ id: "TB1", texto }] });
  assert.deepEqual(problemasDaEscolhida(comTexto(`${p2}\n${p1}`), comTexto(`${p1}\n${p2}`)), ["ordem_leituras_divergente"]);
});

test("ORD-H) palavra que muda de parte (fim do enunciado indo para a alternativa A) conta como deslocada", () => {
  const linear = { ...questao(1, A), alternativas: [{ letra: "A", texto: `${C} ${ALTS[0]}` }, ...questao(1, A).alternativas.slice(1)] };
  const posicional = questao(1, `${A}\n${C}`);
  assert.ok(divergenciaDeOrdem(linear, posicional));
});

test("ORD-I) leitura que PERDEU conteúdo não é divergência de ordem (fica com o gate de conteúdo, sem motivo duplicado)", () => {
  const linear = questao(1, A);
  const posicional = questao(1, [A, B, C].join("\n"));
  assert.equal(divergenciaDeOrdem(linear, posicional), null, "cobertura abaixo do mínimo: não compara ordem");
  assert.deepEqual(problemasDaEscolhida(linear, posicional), ["divergencia_entre_leituras"]);
});

test("ORD-J) escolhida JÁ posicional (a outra é a linear): ordem do stream da outra é explicada pela geometria, sem problema; linhas trocadas com a vizinha só viram problema quando a referência é a posicional", () => {
  const posicional = [questao(1, "Comando da um?"), questao(2, "Comando da dois que continua\nna linha seguinte:")];
  const linear = [{ ...questao(1, "Comando da um?"), alternativas: [...questao(1, "").alternativas.slice(0, 4), { letra: "E", texto: `${ALTS[4]}\nna linha seguinte:` }] }, questao(2, "Comando da dois que continua")];
  const geometricaEscolhida = compararQuestoes(posicional, linear);
  assert.deepEqual(problemasDeIntegridade(posicional[1], { comparacao: geometricaEscolhida.get(2), referenciaPosicional: false }), []);
  const linearEscolhida = compararQuestoes(linear, posicional);
  assert.equal(linearEscolhida.get(2).tipo, "reordenada");
  for (const q of linear) assert.deepEqual(problemasDeIntegridade(q, { comparacao: linearEscolhida.get(q.numero_original), referenciaPosicional: true }).map((p) => p.codigo), ["ordem_leituras_divergente"]);
});

// ------------------------------------------------------------ decisões ----

const LINEAR = [questao(1, A), questao(2, [A, C, B].join("\n")), questao(3, B)];
const POSICIONAL = [questao(1, A), questao(2, [A, B, C].join("\n")), questao(3, B)];
const METADATA_PARTE = { parte: { codigo: "P2", tipo_caderno_canonico: 1 } };
const decisao = (extras = {}) => ({
  parte: "P2",
  tipo_caderno: 1,
  numero_original: 2,
  leitura: "posicional",
  decisao: "ORDEM_OFICIAL_CONFIRMADA_POR_LEITURA_POSICIONAL",
  assinatura_escolhida: assinaturaDaQuestao(LINEAR[1]),
  assinatura_posicional: assinaturaDaQuestao(POSICIONAL[1]),
  evidencias: ["PDF oficial sintético", "outro tipo sintético"],
  ...extras,
});
const aplicar = (decisoes, opcoes = {}) =>
  aplicarDecisoesDeLeitura({ ...METADATA_PARTE, decisoes_leitura: decisoes }, { questoes: LINEAR, posicionais: POSICIONAL, comparacoes: compararQuestoes(LINEAR, POSICIONAL), referenciaPosicional: true, ...opcoes });

test("DEC-A) sem decisões declaradas: nada muda", () => {
  const r = aplicarDecisoesDeLeitura(METADATA_PARTE, { questoes: LINEAR, posicionais: POSICIONAL, comparacoes: compararQuestoes(LINEAR, POSICIONAL), referenciaPosicional: true });
  assert.equal(r.bloqueio, null);
  assert.equal(r.questoes, LINEAR);
});

test("DEC-B) decisão presa à parte, ao tipo, ao número e às duas assinaturas troca SÓ aquela questão pela leitura posicional, sem alterar palavra, e anota a decisão", () => {
  const r = aplicar([decisao()]);
  assert.equal(r.bloqueio, null);
  assert.equal(r.questoes[0], LINEAR[0]);
  assert.equal(r.questoes[2], LINEAR[2]);
  assert.equal(r.questoes[1].enunciado, POSICIONAL[1].enunciado);
  assert.equal(r.questoes[1].decisao_leitura.decisao, "ORDEM_OFICIAL_CONFIRMADA_POR_LEITURA_POSICIONAL");
  assert.deepEqual(r.aplicadas.map((d) => d.numero), [2]);
  const depois = compararQuestoes(r.questoes, POSICIONAL);
  assert.deepEqual(problemasDeIntegridade(r.questoes[1], { comparacao: depois.get(2), referenciaPosicional: true }), [], "depois da decisão, a ordem é a da posicional");
});

test("DEC-C) qualquer descompasso BLOQUEIA: assinatura, parte/tipo, questão sem divergência (obsoleta), duplicada, leitura não posicional, sem evidência, sem leitura posicional cruzada", () => {
  assert.match(aplicar([decisao({ assinatura_escolhida: "0".repeat(64) })]).bloqueio, /assinatura do conteúdo não confere/);
  assert.match(aplicar([decisao({ assinatura_posicional: "f".repeat(64) })]).bloqueio, /assinatura do conteúdo não confere/);
  assert.match(aplicar([decisao({ parte: "P1" })]).bloqueio, /parte P1/);
  assert.match(aplicar([decisao({ tipo_caderno: 2 })]).bloqueio, /tipo 2/);
  assert.match(aplicar([decisao({ numero_original: 1, assinatura_escolhida: assinaturaDaQuestao(LINEAR[0]), assinatura_posicional: assinaturaDaQuestao(POSICIONAL[0]) })]).bloqueio, /decisão obsoleta/);
  assert.match(aplicar([decisao(), decisao()]).bloqueio, /mais de uma vez/);
  assert.match(aplicar([decisao({ leitura: "linear" })]).bloqueio, /só a leitura "posicional"/);
  assert.match(aplicar([decisao({ evidencias: [] })]).bloqueio, /evidencias ausentes/);
  assert.match(aplicar([decisao()], { referenciaPosicional: false }).bloqueio, /não há leitura posicional cruzada/);
  assert.match(aplicar([]).bloqueio, /lista não vazia/);
});

test("DEC-D) decisão de ordem nunca troca conteúdo: linha que mudou de QUESTÃO (palavras diferentes na questão) bloqueia mesmo com assinaturas certas", () => {
  const linear = [{ ...questao(1, A), alternativas: [...questao(1, "").alternativas.slice(0, 4), { letra: "E", texto: `${ALTS[4]}\n${C}` }] }, questao(2, B)];
  const posicional = [questao(1, A), questao(2, `${B}\n${C}`)];
  const comparacoes = compararQuestoes(linear, posicional);
  assert.equal(comparacoes.get(2).tipo, "reordenada");
  const r = aplicarDecisoesDeLeitura(
    { ...METADATA_PARTE, decisoes_leitura: [decisao({ assinatura_escolhida: assinaturaDaQuestao(linear[1]), assinatura_posicional: assinaturaDaQuestao(posicional[1]) })] },
    { questoes: linear, posicionais: posicional, comparacoes, referenciaPosicional: true },
  );
  assert.match(r.bloqueio, /não têm as mesmas palavras/);
});
