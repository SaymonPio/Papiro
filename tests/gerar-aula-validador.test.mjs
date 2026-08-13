import assert from "node:assert/strict";
import test from "node:test";
import { validarRespostaGerador } from "../supabase/functions/gerar-aula/validador.mjs";

// Nenhum destes testes chama a OpenAI — validam só a lógica pura de
// validação da resposta (já com JSON.parse aplicado), sem gastar nada.

function componenteDiagnostico(extra = {}) {
  return {
    tipo: "diagnostico",
    titulo: "O que você já sabe sobre X?",
    introducao: "Antes de explicar, pense no seguinte.",
    pergunta: "O que caracteriza esse instituto?",
    resposta_esperada: "Uma resposta esperada plausível.",
    ...extra,
  };
}

function componenteConceito(extra = {}) {
  return {
    tipo: "conceito",
    titulo: "O núcleo do conceito",
    explicacao: "Explicação em bloco curto sobre o conceito central.",
    exemplo: "Um exemplo prático.",
    ponto_de_prova: "Isso cai direto em prova.",
    pegadinha: "Cuidado com X.",
    ...extra,
  };
}

function componenteRecall(extra = {}) {
  return {
    tipo: "recall",
    titulo: "Vamos relembrar",
    pergunta: "Qual é o prazo?",
    resposta: "O prazo é de 30 dias.",
    dica: "Pense no procedimento comum.",
    ...extra,
  };
}

function componenteQuestaoResolvida(extra = {}) {
  return {
    tipo: "questao_resolvida",
    enunciado: "Assinale a alternativa correta sobre o tema.",
    alternativas: [
      { letra: "A", texto: "Primeira alternativa." },
      { letra: "B", texto: "Segunda alternativa." },
      { letra: "C", texto: "Terceira alternativa." },
      { letra: "D", texto: "Quarta alternativa." },
    ],
    gabarito: "B",
    raciocinio: "A alternativa B está correta porque...",
    pegadinha: "A alternativa A parece certa, mas troca um termo-chave.",
    ...extra,
  };
}

function componenteResumoVisual(extra = {}) {
  return {
    tipo: "resumo_visual",
    titulo: "O que fica da aula de hoje",
    pontos: ["Ponto 1 relevante.", "Ponto 2 relevante.", "Ponto 3 relevante."],
    ...extra,
  };
}

function respostaValida() {
  return {
    artigos_abordados: ["art. 5º", "art. 7º"],
    componentes: [
      componenteDiagnostico(),
      componenteConceito(),
      componenteRecall(),
      componenteQuestaoResolvida(),
      componenteResumoVisual(),
    ],
  };
}

test("aceita uma resposta completa e válida com os 5 tipos obrigatórios", () => {
  const resultado = validarRespostaGerador(respostaValida());
  assert.equal(resultado.ok, true);
  assert.equal(resultado.componentes.length, 5);
});

test("aceita mais de um componente do mesmo tipo, preservando a ordem", () => {
  const dados = {
    artigos_abordados: ["art. 5º"],
    componentes: [
      componenteDiagnostico(),
      componenteConceito({ titulo: "Conceito 1" }),
      componenteConceito({ titulo: "Conceito 2" }),
      componenteRecall(),
      componenteQuestaoResolvida(),
      componenteResumoVisual(),
    ],
  };
  const resultado = validarRespostaGerador(dados);
  assert.equal(resultado.ok, true);
  assert.equal(resultado.componentes.length, 6);
  assert.equal(resultado.componentes[1].titulo, "Conceito 1");
  assert.equal(resultado.componentes[2].titulo, "Conceito 2");
});

test("rejeita quando a raiz não é um objeto", () => {
  assert.equal(validarRespostaGerador(null).ok, false);
  assert.equal(validarRespostaGerador([]).ok, false);
  assert.equal(validarRespostaGerador("texto").ok, false);
});

test("rejeita quando componentes não é array", () => {
  const resultado = validarRespostaGerador({ componentes: "não é array" });
  assert.equal(resultado.ok, false);
});

test("rejeita quando componentes está vazio", () => {
  const resultado = validarRespostaGerador({ componentes: [] });
  assert.equal(resultado.ok, false);
});

test("rejeita quantidade de componentes fora do razoável (possível truncamento)", () => {
  const componentes = Array.from({ length: 41 }, () => componenteConceito());
  const resultado = validarRespostaGerador({ componentes });
  assert.equal(resultado.ok, false);
});

test("rejeita quando falta pelo menos um tipo obrigatório", () => {
  const dados = {
    artigos_abordados: [],
    componentes: [componenteDiagnostico(), componenteConceito(), componenteRecall(), componenteQuestaoResolvida()],
  };
  const resultado = validarRespostaGerador(dados);
  assert.equal(resultado.ok, false);
  assert.match(resultado.erro, /resumo_visual/);
});

test("rejeita tipo desconhecido", () => {
  const dados = respostaValida();
  dados.componentes.push({ tipo: "video_aula", titulo: "x" });
  const resultado = validarRespostaGerador(dados);
  assert.equal(resultado.ok, false);
});

test('rejeita qualquer componente que já venha com "id" — a IA não pode decidir ids', () => {
  const dados = respostaValida();
  dados.componentes[0] = { ...dados.componentes[0], id: "11111111-1111-1111-1111-111111111111" };
  const resultado = validarRespostaGerador(dados);
  assert.equal(resultado.ok, false);
  assert.match(resultado.erro, /id/);
});

test("rejeita diagnostico com campo obrigatório ausente", () => {
  const dados = respostaValida();
  dados.componentes[0] = componenteDiagnostico({ pergunta: "" });
  const resultado = validarRespostaGerador(dados);
  assert.equal(resultado.ok, false);
  assert.match(resultado.erro, /pergunta/);
});

test("aceita conceito com campos opcionais null", () => {
  const dados = respostaValida();
  dados.componentes[1] = componenteConceito({ exemplo: null, ponto_de_prova: null, pegadinha: null });
  const resultado = validarRespostaGerador(dados);
  assert.equal(resultado.ok, true);
});

test("rejeita conceito com campo opcional em tipo errado (não string, não null)", () => {
  const dados = respostaValida();
  dados.componentes[1] = componenteConceito({ exemplo: 123 });
  const resultado = validarRespostaGerador(dados);
  assert.equal(resultado.ok, false);
  assert.match(resultado.erro, /exemplo/);
});

test("aceita questao_resolvida com exatamente 4 alternativas válidas", () => {
  const dados = respostaValida();
  const resultado = validarRespostaGerador(dados);
  assert.equal(resultado.ok, true);
});

test("rejeita questao_resolvida com 2 alternativas", () => {
  const dados = respostaValida();
  dados.componentes[3] = componenteQuestaoResolvida({
    alternativas: [
      { letra: "A", texto: "primeira" },
      { letra: "B", texto: "segunda" },
    ],
    gabarito: "A",
  });
  const resultado = validarRespostaGerador(dados);
  assert.equal(resultado.ok, false);
  assert.match(resultado.erro, /exatamente 4/);
});

test("rejeita questao_resolvida com 3 alternativas", () => {
  const dados = respostaValida();
  dados.componentes[3] = componenteQuestaoResolvida({
    alternativas: [
      { letra: "A", texto: "primeira" },
      { letra: "B", texto: "segunda" },
      { letra: "C", texto: "terceira" },
    ],
    gabarito: "A",
  });
  const resultado = validarRespostaGerador(dados);
  assert.equal(resultado.ok, false);
  assert.match(resultado.erro, /exatamente 4/);
});

test("rejeita questao_resolvida com 5 alternativas", () => {
  const dados = respostaValida();
  dados.componentes[3] = componenteQuestaoResolvida({
    alternativas: [
      { letra: "A", texto: "primeira" },
      { letra: "B", texto: "segunda" },
      { letra: "C", texto: "terceira" },
      { letra: "D", texto: "quarta" },
      { letra: "E", texto: "quinta" },
    ],
    gabarito: "A",
  });
  const resultado = validarRespostaGerador(dados);
  assert.equal(resultado.ok, false);
  assert.match(resultado.erro, /exatamente 4/);
});

test("rejeita questao_resolvida com letra vazia em uma das 4 alternativas", () => {
  const dados = respostaValida();
  dados.componentes[3] = componenteQuestaoResolvida({
    alternativas: [
      { letra: "A", texto: "primeira" },
      { letra: "", texto: "segunda" },
      { letra: "C", texto: "terceira" },
      { letra: "D", texto: "quarta" },
    ],
    gabarito: "A",
  });
  const resultado = validarRespostaGerador(dados);
  assert.equal(resultado.ok, false);
  assert.match(resultado.erro, /letra ausente/);
});

test("rejeita questao_resolvida com texto vazio em uma das 4 alternativas", () => {
  const dados = respostaValida();
  dados.componentes[3] = componenteQuestaoResolvida({
    alternativas: [
      { letra: "A", texto: "primeira" },
      { letra: "B", texto: "   " },
      { letra: "C", texto: "terceira" },
      { letra: "D", texto: "quarta" },
    ],
    gabarito: "A",
  });
  const resultado = validarRespostaGerador(dados);
  assert.equal(resultado.ok, false);
  assert.match(resultado.erro, /texto ausente/);
});

test("rejeita questao_resolvida com letras duplicadas entre as 4 alternativas", () => {
  const dados = respostaValida();
  dados.componentes[3] = componenteQuestaoResolvida({
    alternativas: [
      { letra: "A", texto: "primeira" },
      { letra: "A", texto: "segunda" },
      { letra: "C", texto: "terceira" },
      { letra: "D", texto: "quarta" },
    ],
    gabarito: "A",
  });
  const resultado = validarRespostaGerador(dados);
  assert.equal(resultado.ok, false);
  assert.match(resultado.erro, /duplicada/);
});

test("rejeita questao_resolvida cujo gabarito não existe entre as alternativas", () => {
  const dados = respostaValida();
  dados.componentes[3] = componenteQuestaoResolvida({ gabarito: "Z" });
  const resultado = validarRespostaGerador(dados);
  assert.equal(resultado.ok, false);
  assert.match(resultado.erro, /gabarito/);
});

test("rejeita resumo_visual sem pontos", () => {
  const dados = respostaValida();
  dados.componentes[4] = componenteResumoVisual({ pontos: [] });
  const resultado = validarRespostaGerador(dados);
  assert.equal(resultado.ok, false);
});

test("rejeita resumo_visual com ponto vazio", () => {
  const dados = respostaValida();
  dados.componentes[4] = componenteResumoVisual({ pontos: ["Ponto válido", "   "] });
  const resultado = validarRespostaGerador(dados);
  assert.equal(resultado.ok, false);
});

test("aceita artigos_abordados válido (não vazio) e devolve artigosAbordados", () => {
  const dados = respostaValida();
  const resultado = validarRespostaGerador(dados);
  assert.equal(resultado.ok, true);
  assert.deepEqual(resultado.artigosAbordados, ["art. 5º", "art. 7º"]);
});

test("aceita artigos_abordados vazio quando nenhum artigo foi citado", () => {
  const dados = respostaValida();
  dados.artigos_abordados = [];
  const resultado = validarRespostaGerador(dados);
  assert.equal(resultado.ok, true);
  assert.deepEqual(resultado.artigosAbordados, []);
});

test('rejeita quando "artigos_abordados" está ausente', () => {
  const dados = respostaValida();
  delete dados.artigos_abordados;
  const resultado = validarRespostaGerador(dados);
  assert.equal(resultado.ok, false);
  assert.match(resultado.erro, /artigos_abordados/);
});

test("rejeita quando artigos_abordados não é array", () => {
  const dados = respostaValida();
  dados.artigos_abordados = "art. 5º";
  const resultado = validarRespostaGerador(dados);
  assert.equal(resultado.ok, false);
  assert.match(resultado.erro, /artigos_abordados/);
});

test("rejeita quando artigos_abordados contém item vazio", () => {
  const dados = respostaValida();
  dados.artigos_abordados = ["art. 5º", "   "];
  const resultado = validarRespostaGerador(dados);
  assert.equal(resultado.ok, false);
  assert.match(resultado.erro, /artigos_abordados/);
});

test("rejeita quando artigos_abordados contém item não-string", () => {
  const dados = respostaValida();
  dados.artigos_abordados = ["art. 5º", 7];
  const resultado = validarRespostaGerador(dados);
  assert.equal(resultado.ok, false);
  assert.match(resultado.erro, /artigos_abordados/);
});

test("rejeita quando artigos_abordados tem duplicata exata", () => {
  const dados = respostaValida();
  dados.artigos_abordados = ["art. 5º", "art. 5º"];
  const resultado = validarRespostaGerador(dados);
  assert.equal(resultado.ok, false);
  assert.match(resultado.erro, /duplicata/);
});

test("rejeita resposta minúscula demais (sinal de truncamento)", () => {
  // Estrutura formalmente válida mas com conteúdo trivial demais.
  const minimo = () => ({
    artigos_abordados: [],
    componentes: [
      { tipo: "diagnostico", titulo: "a", introducao: "b", pergunta: "c", resposta_esperada: "d" },
      { tipo: "conceito", titulo: "a", explicacao: "b", exemplo: null, ponto_de_prova: null, pegadinha: null },
      { tipo: "recall", titulo: "a", pergunta: "b", resposta: "c", dica: null },
      { tipo: "questao_resolvida", enunciado: "a", alternativas: [{ letra: "A", texto: "b" }, { letra: "B", texto: "c" }, { letra: "C", texto: "d" }, { letra: "D", texto: "e" }], gabarito: "A", raciocinio: "d", pegadinha: null },
      { tipo: "resumo_visual", titulo: "a", pontos: ["b"] },
    ],
  });
  const resultado = validarRespostaGerador(minimo());
  assert.equal(resultado.ok, false);
  assert.match(resultado.erro, /truncada/);
});
