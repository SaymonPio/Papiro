import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import { extrairGabaritoDoTexto, extrairMencoesDeAlteracao } from "../scripts/importador-provas/lib/extrairGabarito.mjs";
import { lerManifestoDeGabaritos, selecionarBloco } from "../scripts/importador-provas/lib/gabaritos.mjs";
import { aplicarRetificacoes } from "../scripts/importador-provas/lib/retificacoes.mjs";
import { planejarAquisicao } from "../scripts/importador-provas/lib/aquisicao/planejar.mjs";

// PAPIRO — estado final COMPOSTO do gabarito: o definitivo consolidado não
// é público, mas o estado de cada questão sai de documentos oficiais —
// preliminar (base) + justificativa dos recursos, POR CARGO + atos
// posteriores na ordem explícita. Documentos 100% sintéticos.

const PRELIMINAR = extrairGabaritoDoTexto("01 - E 02 - D 03 - A 04 - B 05 - C").gabaritos;

// Justificativa sintética com duas seções de cargo; o mesmo número (4)
// aparece nas duas, com decisões diferentes.
const JUSTIFICATIVA = [
  "JUSTIFICATIVA PARA MANUTENÇÃO OU ALTERAÇÃO DE GABARITOS PRELIMINARES",
  "MATÉRIA: LÍNGUA PORTUGUESA",
  "CARGO(S): CARGO FICTICIO UM",
  "QUESTÃO: 2 - MANTIDA alternativa 'D'. Texto de justificativa ficticio com 2015) e outros numeros 3 - A no meio.",
  "QUESTÃO: 4 - ANULADA. A questao ficticia possui duas respostas.",
  "MATÉRIA: LÍNGUA PORTUGUESA",
  "CARGO(S): CARGO FICTICIO DOIS, CARGO FICTICIO TRES,",
  "CARGO FICTICIO QUATRO",
  "QUESTÃO: 4 - ALTERA GABARITO DE ALTERNATIVA 'B' PARA ALTERNATIVA 'E'. Recurso acolhido.",
  "QUESTÃO: 5 - ANULADA. Outro cargo.",
].join("\n");

const justificativa = (bloco, texto = JUSTIFICATIVA, ordem = 1) => {
  const entradas = extrairGabaritoDoTexto(texto, { estrito: true, secoesDeCargo: true }).gabaritos;
  return { documento: "Justificativas ficticias", ordem, gabaritos: selecionarBloco(entradas, bloco, "a justificativa"), mencoes: extrairMencoesDeAlteracao(texto) };
};
const porNumero = (gabaritos) => Object.fromEntries(gabaritos.map((g) => [g.numero, g]));
const resultado = (g) => (g.anulada ? "*" : g.alternativa_correta);

test("GC-A) preliminar sem alteração posterior para a questão: a letra do preliminar se mantém", () => {
  const g = porNumero(aplicarRetificacoes(PRELIMINAR, [justificativa("Cargo Ficticio Um")]).gabaritos);
  assert.equal(resultado(g[1]), "E");
  assert.equal(resultado(g[3]), "A");
  assert.equal(g[2].status, "ok");
  assert.equal(resultado(g[2]), "D"); // MANTIDA 'D' confirma o preliminar
});

test("GC-B) decisão da seção do PRÓPRIO cargo anula/altera", () => {
  const um = porNumero(aplicarRetificacoes(PRELIMINAR, [justificativa("Cargo Ficticio Um")]).gabaritos);
  assert.equal(um[4].anulada, true);
  const dois = porNumero(aplicarRetificacoes(PRELIMINAR, [justificativa("CARGO FICTICIO DOIS")]).gabaritos);
  assert.equal(resultado(dois[4]), "E");
  assert.deepEqual(dois[4].historico.alteracoes, [{ documento: "Justificativas ficticias", ordem: 1, de: "B", para: "E" }]);
});

test("GC-C) mesmo número em outro cargo NÃO afeta; o cargo precisa casar exatamente um item da lista", () => {
  const um = porNumero(aplicarRetificacoes(PRELIMINAR, [justificativa("Cargo Ficticio Um")]).gabaritos);
  assert.equal(resultado(um[5]), "C"); // a anulação da 5 é de outro cargo
  assert.throws(() => justificativa("Cargo Ficticio"), /Nenhuma entrada/); // nome parcial nunca casa
  // prosa dentro da seção ("2015) e", "3 - A") nunca vira decisão
  assert.deepEqual(justificativa("Cargo Ficticio Um").gabaritos.map((x) => x.numero).sort(), [2, 4]);
});

test("GC-D) duas alterações de cargos diferentes no mesmo documento: cada uma vai para o seu cargo (lista em várias linhas)", () => {
  const entradas = extrairGabaritoDoTexto(JUSTIFICATIVA, { estrito: true, secoesDeCargo: true }).gabaritos;
  const quatro = selecionarBloco(entradas, "Cargo Ficticio Quatro", "a justificativa");
  assert.deepEqual(quatro.map((x) => [x.numero, resultado(x)]), [[4, "E"], [5, "*"]]);
  const um = selecionarBloco(entradas, "Cargo Ficticio Um", "a justificativa");
  assert.deepEqual(um.map((x) => [x.numero, resultado(x)]), [[2, "D"], [4, "*"]]);
});

test("GC-E) fontes oficiais conflitantes no mesmo cargo/questão: GABARITO_OFICIAL_CONFLITANTE, nada escolhido", () => {
  // "MANTIDA 'A'" com o preliminar em 'D' e "ALTERA DE 'C'" com o vigente em 'B'
  const texto = ["CARGO(S): CARGO FICTICIO UM", "QUESTÃO: 2 - MANTIDA alternativa 'A'. Ficticio.", "QUESTÃO: 4 - ALTERA GABARITO DE ALTERNATIVA 'C' PARA ALTERNATIVA 'D'."].join("\n");
  const g = porNumero(aplicarRetificacoes(PRELIMINAR, [justificativa("Cargo Ficticio Um", texto)]).gabaritos);
  for (const n of [2, 4]) {
    assert.equal(g[n].status, "revisao_manual");
    assert.ok(g[n].historico.motivos.some((m) => /GABARITO_OFICIAL_CONFLITANTE/.test(m)), g[n].historico.motivos.join(" | "));
  }
  assert.equal(resultado(g[2]), "D"); // nada alterado por suposição
  // mesma questão com duas decisões diferentes na MESMA seção também é revisão
  const duplo = ["CARGO(S): CARGO FICTICIO UM", "QUESTÃO: 3 - ANULADA.", "QUESTÃO: 3 - MANTIDA alternativa 'A'."].join("\n");
  assert.equal(porNumero(aplicarRetificacoes(PRELIMINAR, [justificativa("Cargo Ficticio Um", duplo)]).gabaritos)[3].status, "revisao_manual");
});

test("GC-F) ato posterior (ordem maior) prevalece sobre a justificativa: mantida e depois anulada", () => {
  const posterior = { documento: "Edital ficticio posterior", ordem: 2, gabaritos: extrairGabaritoDoTexto("Questão Resposta Matéria\n2 * Portugues", { estrito: true }).gabaritos, mencoes: [] };
  const g = porNumero(aplicarRetificacoes(PRELIMINAR, [justificativa("Cargo Ficticio Um"), posterior]).gabaritos);
  assert.equal(g[2].anulada, true);
  assert.deepEqual(g[2].historico.alteracoes, [{ documento: "Edital ficticio posterior", ordem: 2, de: "D", para: "ANULADA" }]);
});

test("GC-G) escopo indeterminável ou decisão não reconhecida: bloqueio/revisão, nunca aplicação silenciosa", () => {
  // documento sem seção de cargo para o bloco pedido
  assert.throws(() => justificativa("Cargo Ficticio Um", "QUESTÃO: 2 - ANULADA."), /Nenhuma entrada/);
  // decisão que não se reconhece dentro da seção
  const estranho = ["CARGO(S): CARGO FICTICIO UM", "QUESTÃO: 3 - DECISÃO EM FORMATO DESCONHECIDO."].join("\n");
  const g = porNumero(aplicarRetificacoes(PRELIMINAR, [justificativa("Cargo Ficticio Um", estranho)]).gabaritos);
  assert.equal(g[3].status, "revisao_manual");
  assert.equal(resultado(g[3]), "A");
});

test("GC-H) planejador: preliminar bloqueia; composto completo segue; composto com questão indeterminada bloqueia", () => {
  const contexto = { materias: new Map(), assuntos: new Map(), cursos: [], questoesGlobais: [], numerosJaImportados: new Map(), sequenciaEmbutida: new Set() };
  const prov = (gabarito_tipo) => ({ completa: true, faltando: [], invalidos: [], gabarito_tipo, retificacoes: [], prova: { banca: "B", orgao: "O", cargo: "C", ano: 2099, nome: "N", fonte_url: "https://x.org/p.pdf", gabarito_url: "https://x.org/g", hash_prova: "a".repeat(64), hash_gabarito: "b".repeat(64) } });
  const questao = (numero, etapas = {}) => ({ numero_original: numero, enunciado: `Enunciado ficticio ${numero} distinto ${numero * 13}`, alternativas: ["A", "B", "C", "D", "E"].map((l) => ({ letra: l, texto: `opcao ${l} ${numero}`, correta: l === "A" })), etapas: { EXTRACAO_OK: true, GABARITO_OK: true, DEDUP_OK: true, PROVENIENCIA_OK: true, ...etapas }, _interno: { gabarito_anulado: false } });
  const plano = (tipo, questoes) => planejarAquisicao({ modo: "BASE_GLOBAL", proveniencia: prov(tipo), questoes, contexto });
  assert.ok(plano("preliminar", [questao(1)]).bloqueios.some((b) => /PRELIMINAR/.test(b)));
  const completo = plano("composto", [questao(1), questao(2)]);
  assert.ok(!completo.bloqueios.some((b) => /PRELIMINAR|GABARITO_FINAL_COMPOSTO/.test(b)), completo.bloqueios.join(" | "));
  const incompleto = plano("composto", [questao(1), questao(2, { GABARITO_OK: false })]);
  assert.ok(incompleto.bloqueios.some((b) => /GABARITO_FINAL_COMPOSTO incompleto.*questões 2/.test(b)), incompleto.bloqueios.join(" | "));
});

test("GC-I) manifesto: composto exige base preliminar e justificativa_recursos com o cargo; o preliminar continua preliminar", () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "gab-composto-"));
  for (const f of ["preliminar.txt", "justificativa.txt", "edital.txt"]) fs.writeFileSync(path.join(dir, f), "x");
  const escrever = (conteudo) => {
    const p = path.join(dir, "gabaritos.json");
    fs.writeFileSync(p, JSON.stringify(conteudo));
    return p;
  };
  const just = { tipo: "retificacao", ordem: 1, natureza: "justificativa_recursos", bloco: "Cargo Ficticio Um", arquivo: "justificativa.txt", url: "https://x.org/j.pdf" };
  const ok = lerManifestoDeGabaritos(escrever({ estado_final: "composto", gabaritos: [{ tipo: "preliminar", arquivo: "preliminar.txt" }, just, { tipo: "retificacao", ordem: 2, arquivo: "edital.txt" }] }));
  assert.equal(ok.estadoFinal, "composto");
  assert.equal(ok.base.tipo, "preliminar");
  assert.equal(ok.retificacoes[0].natureza, "justificativa_recursos");
  assert.equal(ok.retificacoes[1].natureza, undefined);
  assert.throws(() => lerManifestoDeGabaritos(escrever({ estado_final: "composto", gabaritos: [{ tipo: "definitivo", arquivo: "preliminar.txt" }, just] })), /preliminar/);
  assert.throws(() => lerManifestoDeGabaritos(escrever({ estado_final: "composto", gabaritos: [{ tipo: "preliminar", arquivo: "preliminar.txt" }, { ...just, natureza: undefined }] })), /justificativa_recursos/);
  assert.throws(() => lerManifestoDeGabaritos(escrever({ estado_final: "composto", gabaritos: [{ tipo: "preliminar", arquivo: "preliminar.txt" }, { ...just, bloco: null }] })), /sem escopo/);
  assert.throws(() => lerManifestoDeGabaritos(escrever({ estado_final: "outro", gabaritos: [{ tipo: "preliminar", arquivo: "preliminar.txt" }] })), /estado_final desconhecido/);
  // sem estado_final, nada muda: o manifesto é lido exatamente como antes
  const antigo = lerManifestoDeGabaritos(escrever({ gabaritos: [{ tipo: "definitivo", arquivo: "preliminar.txt" }, { tipo: "retificacao", ordem: 1, arquivo: "edital.txt" }] }));
  assert.equal(antigo.estadoFinal, undefined);
  assert.deepEqual(Object.keys(antigo.retificacoes[0]).sort(), ["arquivo", "bloco", "documento", "ordem", "url"]);
});

test("GC-J) sem a declaração de justificativa por cargo, o documento é lido exatamente como antes (seções ignoradas)", () => {
  const antes = extrairGabaritoDoTexto(JUSTIFICATIVA, { estrito: true }).gabaritos;
  assert.ok(antes.every((g) => g.bloco === null && g.cargos === undefined && g.decisao === undefined));
  assert.deepEqual(antes.map((g) => [g.numero, resultado(g)]), [[4, "*"], [5, "*"]]); // só as linhas "QUESTÃO: N - ANULADA", como sempre
});
