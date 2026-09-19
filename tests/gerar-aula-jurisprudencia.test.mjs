import assert from "node:assert/strict";
import test from "node:test";
import {
  validarJurisprudenciasValidadasEntrada,
  montarBlocoJurisprudencia,
} from "../supabase/functions/_shared/gerar-aula/jurisprudencia.mjs";

// Nenhum destes testes chama a OpenAI nem o banco — validam só a lógica
// pura de entrada/prompt do módulo. O fixture HC 111.840 abaixo é usado
// SOMENTE como dado de teste (mandato "jurisprudência essencial", seção
// 18) — não altera nenhuma aula_versao real; a unidade "Lei de Tortura" só
// aparece aqui como rótulo de exemplo.
const FIXTURE_HC_111_840 = {
  tribunal: "STF",
  identificacao: "HC 111.840",
  dispositivo_relacionado: "art. 1º, §7º",
  entendimento_validado:
    "A imposição do regime inicial fechado não deve ocorrer automaticamente apenas pela literalidade do §7º, devendo ser observadas individualização da pena e fundamentação adequada.",
  fonte_validada: "STF, HC 111.840",
};

test("entrada ausente ou nula é um estado válido (nenhuma jurisprudência fornecida)", () => {
  assert.deepEqual(validarJurisprudenciasValidadasEntrada(undefined), { ok: true, itens: [] });
  assert.deepEqual(validarJurisprudenciasValidadasEntrada(null), { ok: true, itens: [] });
});

test("array vazio é um estado válido", () => {
  const resultado = validarJurisprudenciasValidadasEntrada([]);
  assert.equal(resultado.ok, true);
  assert.deepEqual(resultado.itens, []);
});

test("rejeita entrada que não é array", () => {
  const resultado = validarJurisprudenciasValidadasEntrada("HC 111.840");
  assert.equal(resultado.ok, false);
});

test("rejeita mais de 6 itens", () => {
  const item = { ...FIXTURE_HC_111_840 };
  const resultado = validarJurisprudenciasValidadasEntrada(Array.from({ length: 7 }, () => item));
  assert.equal(resultado.ok, false);
});

test("aceita o fixture HC 111.840 (dado já validado no projeto, usado só como teste)", () => {
  const resultado = validarJurisprudenciasValidadasEntrada([FIXTURE_HC_111_840]);
  assert.equal(resultado.ok, true);
  assert.equal(resultado.itens.length, 1);
  assert.equal(resultado.itens[0].tribunal, "STF");
  assert.equal(resultado.itens[0].identificacao, "HC 111.840");
});

test("rejeita item sem entendimento_validado", () => {
  const item = { ...FIXTURE_HC_111_840, entendimento_validado: "" };
  const resultado = validarJurisprudenciasValidadasEntrada([item]);
  assert.equal(resultado.ok, false);
  assert.match(resultado.erro, /entendimento_validado/);
});

test("rejeita item sem tribunal", () => {
  const item = { ...FIXTURE_HC_111_840, tribunal: "" };
  const resultado = validarJurisprudenciasValidadasEntrada([item]);
  assert.equal(resultado.ok, false);
  assert.match(resultado.erro, /tribunal/);
});

test("rejeita item que não é objeto", () => {
  const resultado = validarJurisprudenciasValidadasEntrada(["HC 111.840"]);
  assert.equal(resultado.ok, false);
});

test("montarBlocoJurisprudencia sem itens instrui a NÃO criar o componente e a NÃO inventar", () => {
  const bloco = montarBlocoJurisprudencia([]);
  assert.match(bloco, /NÃO crie nenhum componente "jurisprudencia_essencial"/);
  assert.match(bloco, /não invente/i);
});

test("montarBlocoJurisprudencia com o fixture HC 111.840 lista exatamente o item fornecido, sem inventar outro", () => {
  const bloco = montarBlocoJurisprudencia([FIXTURE_HC_111_840]);
  assert.match(bloco, /STF/);
  assert.match(bloco, /HC 111\.840/);
  assert.match(bloco, /art\. 1º, §7º/);
  assert.match(bloco, /NÃO invente nenhuma jurisprudência além das listadas acima/);
});

test("montarBlocoJurisprudencia sem itens instrui explicitamente a NÃO buscar jurisprudência por conta própria", () => {
  const semItens = montarBlocoJurisprudencia([]);
  assert.match(semItens, /não busque/i);
});
