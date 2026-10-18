import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import { extrairGabaritoDoTexto, extrairMencoesDeAlteracao } from "../scripts/importador-provas/lib/extrairGabarito.mjs";
import { lerManifestoDeGabaritos, selecionarBloco } from "../scripts/importador-provas/lib/gabaritos.mjs";
import { aplicarRetificacoes } from "../scripts/importador-provas/lib/retificacoes.mjs";

// PAPIRO — gabarito base + 0..N retificações. Documentos 100% sintéticos.

const BASE = extrairGabaritoDoTexto(["01 - B 02 - E 03 - A 04 - * 05 - C"].join("\n")).gabaritos;

function retificacao(documento, ordem, texto) {
  return { documento, ordem, gabaritos: extrairGabaritoDoTexto(texto, { estrito: true }).gabaritos, mencoes: extrairMencoesDeAlteracao(texto) };
}

function porNumero(gabaritos) {
  return Object.fromEntries(gabaritos.map((g) => [g.numero, g]));
}

test("RT-A) sem retificação: gabarito final = base, com histórico sem alterações", () => {
  const { gabaritos, problemas } = aplicarRetificacoes(BASE, []);
  assert.deepEqual(problemas, []);
  const g = porNumero(gabaritos);
  assert.equal(g[1].alternativa_correta, "B");
  assert.equal(g[4].anulada, true);
  assert.equal(g[1].historico.resultado_original, "B");
  assert.equal(g[1].historico.resultado_final, "B");
  assert.deepEqual(g[1].historico.alteracoes, []);
});

test("RT-B) retificação anula uma questão e altera outra: resposta original, final, origem e status registrados", () => {
  const ret = retificacao("Edital ficticio 9/2099", 1, ["1.1. Anula-se a Questão nº 02.", "Questão Resposta Matéria", "2 * Portugues", "3 D Portugues"].join("\n"));
  const g = porNumero(aplicarRetificacoes(BASE, [ret]).gabaritos);
  assert.equal(g[2].anulada, true);
  assert.equal(g[2].alternativa_correta, null);
  assert.equal(g[2].historico.status_final, "anulada");
  assert.deepEqual(g[2].historico.alteracoes, [{ documento: "Edital ficticio 9/2099", ordem: 1, de: "E", para: "ANULADA" }]);
  assert.equal(g[3].alternativa_correta, "D");
  assert.equal(g[3].historico.resultado_original, "A");
  assert.equal(g[3].alterada, true);
  assert.equal(g[1].alternativa_correta, "B", "questão não citada fica como no base");
});

test("RT-C) ordem explícita decide (não a ordem da lista nem o nome do arquivo); retificação posterior pode desfazer anulação", () => {
  const anula = retificacao("z-primeira.pdf", 1, "2 * Portugues");
  const desfaz = retificacao("a-segunda.pdf", 2, "2 C Portugues");
  const g = porNumero(aplicarRetificacoes(BASE, [desfaz, anula]).gabaritos);
  assert.equal(g[2].anulada, false);
  assert.equal(g[2].alternativa_correta, "C");
  assert.deepEqual(g[2].historico.alteracoes.map((a) => [a.ordem, a.para]), [[1, "ANULADA"], [2, "C"]]);
});

test("RT-D) duas retificações conflitantes sem ordem confiável -> REVISAR a questão", () => {
  const semOrdem = retificacao("sem-ordem.pdf", undefined, "3 D Portugues");
  const outra = retificacao("outra.pdf", 1, "3 E Portugues");
  const { gabaritos, problemas } = aplicarRetificacoes(BASE, [semOrdem, outra]);
  assert.ok(problemas.some((p) => /sem ordem explícita/.test(p)));
  const g = porNumero(gabaritos);
  assert.equal(g[3].status, "revisao_manual");
  assert.equal(g[3].historico.status_final, "revisao_manual");

  const mesmaOrdem = aplicarRetificacoes(BASE, [retificacao("x.pdf", 1, "3 D Portugues"), retificacao("y.pdf", 1, "3 E Portugues")]);
  assert.ok(mesmaOrdem.problemas.some((p) => /mesma ordem 1/.test(p)));
  assert.equal(porNumero(mesmaOrdem.gabaritos)[3].status, "revisao_manual");
});

test("RT-E) anúncio em prosa sem entrada estruturada que o confirme -> REVISAR (nunca aplicado por inferência)", () => {
  const ret = retificacao("so-prosa.pdf", 1, "Anula-se a Questão nº 05, conforme justificativa.");
  const g = porNumero(aplicarRetificacoes(BASE, [ret]).gabaritos);
  assert.equal(g[5].status, "revisao_manual");
  assert.equal(g[5].alternativa_correta, "C", "nada alterado");
  assert.ok(g[5].historico.motivos.some((m) => /sem entrada de gabarito/.test(m)));
});

test("RT-F) mesmo documento com valores diferentes para a mesma questão -> REVISAR; valores repetidos iguais são a mesma informação", () => {
  const conflito = porNumero(aplicarRetificacoes(BASE, [retificacao("c.pdf", 1, ["3 D Portugues", "3 E Portugues"].join("\n"))]).gabaritos);
  assert.equal(conflito[3].status, "revisao_manual");
  const repetido = porNumero(aplicarRetificacoes(BASE, [retificacao("r.pdf", 1, ["QUESTÃO: 02 - ANULADA", "2 * Portugues"].join("\n"))]).gabaritos);
  assert.equal(repetido[2].status, "ok");
  assert.equal(repetido[2].anulada, true);
});

test("RT-G) modo estrito: par acidental na prosa (\"em 2015) e\") nunca vira alteração de gabarito", () => {
  const texto = ["A lei publicada em 2015) e alterada depois.", "Questão Resposta", "1 B Portugues"].join("\n");
  assert.ok(extrairGabaritoDoTexto(texto).gabaritos.some((g) => g.numero === 15), "modo normal pega o par acidental");
  assert.deepEqual(extrairGabaritoDoTexto(texto, { estrito: true }).gabaritos.map((g) => g.numero), [1]);
});

test("RT-H) manifesto de gabaritos: 1 base obrigatório, caminhos relativos, ordem e documento preservados; bloco de retificação multi-cargo exige escolha", () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "papiro-gabaritos-"));
  fs.writeFileSync(path.join(dir, "base.txt"), "01 - A 02 - B");
  fs.writeFileSync(path.join(dir, "ret.txt"), "1 C Portugues");
  fs.writeFileSync(
    path.join(dir, "gabaritos.json"),
    JSON.stringify({ gabaritos: [{ tipo: "definitivo", arquivo: "base.txt", bloco: "Cargo X" }, { tipo: "retificacao", ordem: 1, arquivo: "ret.txt", documento: "Edital ficticio", url: "https://exemplo.org/r.pdf" }] }),
  );
  const manifesto = lerManifestoDeGabaritos(path.join(dir, "gabaritos.json"));
  assert.equal(manifesto.base.arquivo, path.join(dir, "base.txt"));
  assert.equal(manifesto.base.bloco, "Cargo X");
  assert.deepEqual(manifesto.retificacoes.map((r) => [r.ordem, r.documento, r.url]), [[1, "Edital ficticio", "https://exemplo.org/r.pdf"]]);

  fs.writeFileSync(path.join(dir, "sem-base.json"), JSON.stringify({ gabaritos: [{ tipo: "retificacao", ordem: 1, arquivo: "ret.txt" }] }));
  assert.throws(() => lerManifestoDeGabaritos(path.join(dir, "sem-base.json")), /exatamente 1 gabarito base/);

  const multi = [{ numero: 1, bloco: "Cargo X" }, { numero: 1, bloco: "Cargo Y" }];
  assert.throws(() => selecionarBloco(multi, null, "a retificação"), /2 blocos distintos/);
  assert.deepEqual(selecionarBloco(multi, "Cargo Y", "a retificação"), [{ numero: 1, bloco: "Cargo Y" }]);
});
