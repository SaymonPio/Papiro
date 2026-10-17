import assert from "node:assert/strict";
import test from "node:test";
import { classificarMateriaAssunto } from "../scripts/importador-provas/lib/classificar.mjs";

// PAPIRO — PoC do importador de provas: classificação (sugestão de
// materia_id/assunto_id). Nunca cria matéria/assunto — só tenta casar
// contra uma taxonomia já existente (snapshot sintético aqui).

const TAXONOMIA = {
  materias: [{ id: 10, nome: "Direito Processual Penal" }, { id: 11, nome: "Português" }],
  assuntos: [{ id: 100, materia_id: 10, nome: "Lei Maria da Penha - Lei nº 11.340 de 2006" }],
};

test("A) cabeçalho de disciplina com correspondência EXATA a uma matéria conhecida -> confidence 'alta', materia_id preenchido", () => {
  const resultado = classificarMateriaAssunto({ enunciado: "qualquer coisa" }, TAXONOMIA, "Direito Processual Penal");
  assert.equal(resultado.confidence, "alta");
  assert.equal(resultado.materia_id, 10);
});

test("B) nenhum cabeçalho, mas o nome do assunto aparece como substring no enunciado -> confidence 'baixa', materia_id/assunto_id ficam NULL no resultado oficial", () => {
  const resultado = classificarMateriaAssunto(
    { enunciado: "Sobre a Lei Maria da Penha - Lei nº 11.340 de 2006, assinale a alternativa correta." },
    TAXONOMIA,
  );
  assert.equal(resultado.confidence, "baixa");
  assert.equal(resultado.materia_id, null, "confidence baixa nunca deve preencher materia_id no resultado oficial");
  assert.equal(resultado.assunto_id, null);
  // O candidato fica disponível só para auditoria/revisão manual, nunca
  // como valor "oficial" de classificação.
  assert.equal(resultado.materia_id_candidato, 10);
  assert.equal(resultado.assunto_id_candidato, 100);
});

test("C) nenhum sinal de classificação -> confidence 'nenhuma', tudo null", () => {
  const resultado = classificarMateriaAssunto({ enunciado: "Um enunciado qualquer sem relação com a taxonomia." }, TAXONOMIA);
  assert.equal(resultado.confidence, "nenhuma");
  assert.equal(resultado.materia_id, null);
  assert.equal(resultado.assunto_id, null);
});

test("D) nunca cria matéria/assunto novo — a função só lê a taxonomia recebida, nunca a modifica", () => {
  const taxonomiaOriginal = JSON.parse(JSON.stringify(TAXONOMIA));
  classificarMateriaAssunto({ enunciado: "Sobre a Lei Maria da Penha - Lei nº 11.340 de 2006." }, TAXONOMIA);
  assert.deepEqual(TAXONOMIA, taxonomiaOriginal);
});

test("E) cabeçalho de disciplina sem correspondência exata não força confidence 'alta' — cai para o heurístico fraco", () => {
  const resultado = classificarMateriaAssunto(
    { enunciado: "Sobre a Lei Maria da Penha - Lei nº 11.340 de 2006." },
    TAXONOMIA,
    "Disciplina Que Não Existe Na Taxonomia",
  );
  assert.notEqual(resultado.confidence, "alta");
});
