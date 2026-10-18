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

test("H) questão com texto-base incorporado: comparada também só pelo comando — o texto longo não esconde uma duplicata gravada sem ele", () => {
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
  assert.equal(resultado.status, "duplicada");
  assert.equal(resultado.match_id, 777);
  assert.match(resultado.motivo, /só o comando/);
});
