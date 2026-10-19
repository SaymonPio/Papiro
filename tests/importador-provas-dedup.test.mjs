import assert from "node:assert/strict";
import test from "node:test";
import { classificarDuplicidade, jaccard, normalizarTexto } from "../scripts/importador-provas/lib/deduplicar.mjs";

// PAPIRO — PoC do importador de provas: deduplicação contra um snapshot
// local de `questoes` (SOMENTE LEITURA — este módulo nunca grava nada).
// Mesmo algoritmo de scripts/dedupe-lote1-vs-supabase.js, vocabulário
// adaptado para esta fase (nova / provavel_duplicada / duplicada).

const BANCO_EXISTENTE = [
  {
    id: 501,
    enunciado: "Sobre a Lei Maria da Penha, assinale a alternativa correta.",
    alternativas: [
      { letra: "A", texto: "Texto da alternativa A já existente no banco." },
      { letra: "B", texto: "Texto da alternativa B já existente no banco." },
    ],
  },
];

test("A) questão sem nenhuma correspondência -> status 'nova'", () => {
  const resultado = classificarDuplicidade(
    { enunciado: "Uma questão completamente diferente, sobre outro assunto qualquer.", alternativas: [] },
    BANCO_EXISTENTE,
  );
  assert.equal(resultado.status, "nova");
  assert.equal(resultado.match_id, null);
});

test("B) enunciado idêntico (normalizado) + alternativas compatíveis -> 'duplicada', aponta o id existente", () => {
  const resultado = classificarDuplicidade(
    {
      enunciado: "sobre a lei maria da penha, assinale a alternativa correta.", // caixa/acentuação diferente, mesmo texto normalizado
      alternativas: [
        { letra: "A", texto: "Texto da alternativa A já existente no banco." },
        { letra: "B", texto: "Texto da alternativa B já existente no banco." },
      ],
    },
    BANCO_EXISTENTE,
  );
  assert.equal(resultado.status, "duplicada");
  assert.equal(resultado.match_id, 501);
});

test("C) mesmo enunciado 'stub', mas alternativas totalmente diferentes -> NÃO é 'duplicada' automaticamente", () => {
  const resultado = classificarDuplicidade(
    {
      enunciado: "Sobre a Lei Maria da Penha, assinale a alternativa correta.",
      alternativas: [
        { letra: "A", texto: "Algo completamente diferente do banco, sem nenhuma palavra em comum relevante." },
        { letra: "B", texto: "Outra alternativa totalmente distinta, sem sobreposição textual." },
      ],
    },
    BANCO_EXISTENTE,
  );
  assert.notEqual(resultado.status, "duplicada");
});

test("D) similaridade combinada moderada (>= 0.35) mas não exata -> 'provavel_duplicada', NUNCA resolvida sozinha para 'duplicada'", () => {
  const resultado = classificarDuplicidade(
    {
      enunciado: "Sobre a Lei Maria da Penha, assinale a alternativa correta e completa sobre o tema.",
      alternativas: [
        { letra: "A", texto: "Texto da alternativa A já existente no banco." },
        { letra: "B", texto: "Texto da alternativa B parecida mas não igual ao banco existente." },
      ],
    },
    BANCO_EXISTENTE,
  );
  assert.equal(resultado.status, "provavel_duplicada");
  assert.equal(resultado.match_id, 501);
});

test("E) similaridade baixa (< 0.35) -> 'nova', nunca falso positivo por coincidência fraca", () => {
  const resultado = classificarDuplicidade(
    { enunciado: "Pergunta totalmente distinta sobre Direito Constitucional e organização dos poderes.", alternativas: [] },
    BANCO_EXISTENTE,
  );
  assert.equal(resultado.status, "nova");
});

test("F) normalizarTexto ignora espaços, caixa e pontuação irrelevante", () => {
  assert.equal(normalizarTexto("  Sobre A Lei, Maria-da-Penha!!  "), normalizarTexto("sobre a lei maria da penha"));
});

test("G) jaccard de dois textos idênticos é 1; de textos sem palavras em comum é 0", () => {
  assert.equal(jaccard("texto igual", "texto igual"), 1);
  assert.equal(jaccard("abc def", "ghi jkl"), 0);
});

test("H) este módulo nunca modifica o snapshot do banco recebido (modo somente leitura)", () => {
  const copiaOriginal = JSON.parse(JSON.stringify(BANCO_EXISTENTE));
  classificarDuplicidade({ enunciado: "qualquer coisa", alternativas: [] }, BANCO_EXISTENTE);
  assert.deepEqual(BANCO_EXISTENTE, copiaOriginal);
});

test("H) questão com texto-base incorporado: comparada pelo comando — o texto longo não esconde a mesma questão gravada sem ele (provável, nunca exata)", () => {
  const banco = [
    {
      id: 777,
      enunciado: "No fragmento supracitado, o pronome lhes retoma qual termo da frase?",
      alternativas: [{ texto: "Protetores." }, { texto: "Objetivos." }, { texto: "Pessoas." }, { texto: "Elas." }],
    },
  ];
  const textoLongo = Array.from({ length: 60 }, (_, i) => `palavra${i} ficticia${i} do texto${i}`).join(" ");
  const comando = "No fragmento supracitado, o pronome lhes retoma qual termo da frase?";
  const questao = {
    enunciado: `${textoLongo}\n\n${comando}`,
    alternativas: [{ texto: "Protetores." }, { texto: "Objetivos." }, { texto: "Pessoas." }, { texto: "Elas." }],
    _interno: { enunciado_comando: comando },
  };
  assert.equal(classificarDuplicidade({ ...questao, _interno: {} }, banco).status, "nova", "só pelo enunciado completo, o texto diluiria a duplicata");
  const resultado = classificarDuplicidade(questao, banco);
  assert.equal(resultado.status, "provavel_duplicada");
  assert.equal(resultado.match_id, 777);
  assert.match(resultado.motivo, /sem o texto-base compartilhado/);
});

// ---- Texto-base compartilhado x comando ----

const TEXTO_BASE = Array.from({ length: 80 }, (_, i) => `termo${i} narrativa${i % 7} ficticia`).join(" ");
function comTexto(comando, alternativas, texto = TEXTO_BASE) {
  return { enunciado: `${texto}

${comando}`, alternativas: alternativas.map((texto) => ({ texto })), _interno: { enunciado_comando: comando } };
}
const ALTS_1 = ["Primeira opção sobre pontuação.", "Segunda opção sobre pontuação.", "Terceira opção sobre pontuação.", "Quarta opção sobre pontuação."];
const ALTS_2 = ["Sentido de causa.", "Sentido de concessão.", "Sentido de tempo.", "Sentido de condição."];

test("TB-DEDUP-A) mesmo texto-base + comandos diferentes -> NÃO é duplicata (nem provável)", () => {
  const existente = comTexto("Sobre a pontuação empregada no texto, assinale a correta.", ALTS_1);
  const nova = comTexto("A conjunção destacada no segundo parágrafo expressa ideia de:", ALTS_2);
  assert.equal(classificarDuplicidade(nova, [{ id: 1, enunciado: existente.enunciado, alternativas: existente.alternativas }]).status, "nova");
});

test("TB-DEDUP-B) mesmo texto-base + mesmo comando -> duplicata exata", () => {
  const existente = comTexto("Sobre a pontuação empregada no texto, assinale a correta.", ALTS_1);
  const r = classificarDuplicidade(comTexto("Sobre a pontuação empregada no texto, assinale a correta.", ALTS_1), [{ id: 2, enunciado: existente.enunciado, alternativas: existente.alternativas }]);
  assert.equal(r.status, "duplicada");
  assert.equal(r.match_id, 2);
});

test("TB-DEDUP-C) textos diferentes + comando igual -> provável, nunca exata", () => {
  const outroTexto = Array.from({ length: 80 }, (_, i) => `palavra${i} cronica${i % 5} inventada`).join(" ");
  const existente = comTexto("Sobre a pontuação empregada no texto, assinale a correta.", ALTS_1, outroTexto);
  const r = classificarDuplicidade(comTexto("Sobre a pontuação empregada no texto, assinale a correta.", ALTS_1), [{ id: 3, enunciado: existente.enunciado, alternativas: existente.alternativas }]);
  assert.equal(r.status, "provavel_duplicada");
  assert.equal(r.match_id, 3);
});

test("TB-DEDUP-D) questão sem texto-base: algoritmo de sempre (enunciado idêntico + alternativas compatíveis = exata)", () => {
  const q = { enunciado: "Qual é o prazo legal ficticio para o recurso?", alternativas: ALTS_2.map((texto) => ({ texto })), _interno: { enunciado_comando: "Qual é o prazo legal ficticio para o recurso?" } };
  assert.equal(classificarDuplicidade(q, [{ id: 4, enunciado: q.enunciado, alternativas: q.alternativas }]).status, "duplicada");
  assert.equal(classificarDuplicidade(q, [{ id: 5, enunciado: "Outra pergunta completamente diferente e sem relação alguma.", alternativas: [{ texto: "x" }] }]).status, "nova");
});

test("TB-DEDUP-E) legado autossuficiente (texto embutido no enunciado, formatação diferente): a mesma questão vira provável; outra questão do mesmo texto não", () => {
  const legado = { id: 6, enunciado: `${TEXTO_BASE.replace(/ /g, "  ")} Sobre a pontuação empregada no texto assinale a correta`, alternativas: ALTS_1.map((texto) => ({ texto })) };
  assert.equal(classificarDuplicidade(comTexto("Sobre a pontuação empregada no texto, assinale a correta.", ALTS_1), [legado]).status, "duplicada", "mesmo texto e comando, só espaços/pontuação diferentes = exata (normalização)");
  const legadoReescrito = { ...legado, enunciado: `${TEXTO_BASE} Quanto à pontuação usada pelo autor no texto, marque a alternativa correta` };
  assert.equal(classificarDuplicidade(comTexto("Sobre a pontuação empregada no texto, assinale a correta.", ALTS_1), [legadoReescrito]).status, "provavel_duplicada");
  assert.equal(classificarDuplicidade(comTexto("A conjunção destacada no segundo parágrafo expressa ideia de:", ALTS_2), [legadoReescrito]).status, "nova");
});
