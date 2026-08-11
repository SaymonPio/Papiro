import assert from "node:assert/strict";
import test from "node:test";
import {
  detectaSequenciaAlternativasEmbutida,
  validarLinhaImportacao,
} from "../utils/validacao-importacao.mjs";

const ENUNCIADO_TRUNCADO_ECA =
  "O Estatuto da Criança e do Adolescente prevê que, verificada a prática de ato infracional, a autoridade competente poderá aplicar ao adolescente as seguintes medidassocioeducativas:";

const ALTERNATIVA_A_ECA = "advertência;";
const ALTERNATIVA_B_ECA = "obrigação de reparar o dano;";
const ALTERNATIVA_C_ECA = "prestação de serviços à comunidade;";
const ALTERNATIVA_D_ECA = "liberdade assistida;";

test("detectaSequenciaAlternativasEmbutida: identifica sequência completa a)/b)/c)/d)", () => {
  const texto =
    "inserção em regime de semiliberdade; f) internação em estabelecimento educacional, entre outras. Assinale a alternativa que apresenta a quantidade correta de medidas previstas: a) 5. b) 6. c) 7. d) 8.";
  const resultado = detectaSequenciaAlternativasEmbutida(texto);
  assert.equal(resultado.completa, true);
  assert.equal(resultado.parcial, true);
});

test("detectaSequenciaAlternativasEmbutida: identifica sequência completa com alternativas textuais", () => {
  const texto =
    "inserção em regime de semiliberdade; f) internação em estabelecimento educacional, entre outras. Assinale o movimento correspondente: a) Movimento para dentro. b) Negação. c) Separação. d) Concomitância.";
  const resultado = detectaSequenciaAlternativasEmbutida(texto);
  assert.equal(resultado.completa, true);
});

test("detectaSequenciaAlternativasEmbutida: identifica sequência parcial (a-b-c, sem d)", () => {
  const texto = "Nos termos do art. 10, incisos: a) primeiro; b) segundo; c) terceiro.";
  const resultado = detectaSequenciaAlternativasEmbutida(texto);
  assert.equal(resultado.completa, false);
  assert.equal(resultado.parcial, true);
});

test("detectaSequenciaAlternativasEmbutida: alternativa legítima não é detectada", () => {
  const resultado = detectaSequenciaAlternativasEmbutida("Movimento para dentro.");
  assert.equal(resultado.completa, false);
  assert.equal(resultado.parcial, false);
});

test("detectaSequenciaAlternativasEmbutida: referência jurídica isolada ('alínea a)') não é detectada", () => {
  const texto =
    "Conforme o art. 5º, alínea a), da Lei nº 8.112/90, é vedado ao servidor valer-se do cargo para lograr proveito pessoal, em detrimento da dignidade da função pública.";
  const resultado = detectaSequenciaAlternativasEmbutida(texto);
  assert.equal(resultado.completa, false);
  assert.equal(resultado.parcial, false);
});

test("validarLinhaImportacao: A) caso corrompido equivalente à questão 877 é bloqueante", () => {
  const resultado = validarLinhaImportacao({
    enunciado: ENUNCIADO_TRUNCADO_ECA,
    alternativa_a: ALTERNATIVA_A_ECA,
    alternativa_b: ALTERNATIVA_B_ECA,
    alternativa_c: ALTERNATIVA_C_ECA,
    alternativa_d: ALTERNATIVA_D_ECA,
    alternativa_e:
      "inserção em regime de semiliberdade; f) internação em estabelecimento educacional, entre outras. Assinale a alternativa que apresenta a quantidade correta de medidas previstas: a) 5. b) 6. c) 7. d) 8.",
  });

  assert.equal(resultado.bloqueante, true);
  assert.ok(resultado.erros.length >= 1);
  assert.match(resultado.erros[0], /alternativa E/);
});

test("validarLinhaImportacao: B) mesmo padrão com alternativas textuais (equivalente à questão 882) é bloqueante", () => {
  const resultado = validarLinhaImportacao({
    enunciado: ENUNCIADO_TRUNCADO_ECA,
    alternativa_a: ALTERNATIVA_A_ECA,
    alternativa_b: ALTERNATIVA_B_ECA,
    alternativa_c: ALTERNATIVA_C_ECA,
    alternativa_d: ALTERNATIVA_D_ECA,
    alternativa_e:
      "inserção em regime de semiliberdade; f) internação em estabelecimento educacional, entre outras. Assinale o movimento correspondente: a) Movimento para dentro. b) Negação. c) Separação. d) Concomitância.",
  });

  assert.equal(resultado.bloqueante, true);
  assert.ok(resultado.erros.length >= 1);
});

test("validarLinhaImportacao: C) alternativa normal isolada não é detectada como lista embutida", () => {
  const resultado = detectaSequenciaAlternativasEmbutida("Movimento para dentro.");
  assert.equal(resultado.completa, false);
  assert.equal(resultado.parcial, false);
});

test("validarLinhaImportacao: D) questão normal com 4 alternativas não é bloqueante", () => {
  const resultado = validarLinhaImportacao({
    enunciado: "Qual é a capital da França?",
    alternativa_a: "Paris",
    alternativa_b: "Londres",
    alternativa_c: "Madri",
    alternativa_d: "Roma",
    alternativa_e: "",
  });

  assert.equal(resultado.bloqueante, false);
  assert.deepEqual(resultado.erros, []);
});

test("validarLinhaImportacao: E) questão normal com 5 alternativas não é bloqueante", () => {
  const resultado = validarLinhaImportacao({
    enunciado: "Assinale a alternativa correta sobre o sistema solar.",
    alternativa_a: "Mercúrio é o planeta mais próximo do Sol.",
    alternativa_b: "Vênus é o planeta mais quente do sistema solar.",
    alternativa_c: "Marte é conhecido como o planeta vermelho.",
    alternativa_d: "Júpiter é o maior planeta do sistema solar.",
    alternativa_e: "Saturno possui um sistema de anéis muito visível.",
  });

  assert.equal(resultado.bloqueante, false);
  assert.deepEqual(resultado.erros, []);
});

test("validarLinhaImportacao: F) alternativa jurídica longa com uma única referência 'a)' não é bloqueante (evita falso positivo)", () => {
  const resultado = validarLinhaImportacao({
    enunciado: "Assinale a alternativa correta acerca dos deveres do servidor público.",
    alternativa_a:
      "Conforme o art. 5º, alínea a), da Lei nº 8.112/90, é vedado ao servidor valer-se do cargo para lograr proveito pessoal, em detrimento da dignidade da função pública.",
    alternativa_b: "O servidor deve exercer com zelo e dedicação as atribuições do cargo.",
    alternativa_c: "É dever do servidor guardar sigilo sobre assunto da repartição.",
    alternativa_d: "O servidor deve ser leal às instituições a que servir.",
    alternativa_e: "Nenhuma das anteriores está incorreta.",
  });

  assert.equal(resultado.bloqueante, false);
  assert.deepEqual(resultado.erros, []);
});
