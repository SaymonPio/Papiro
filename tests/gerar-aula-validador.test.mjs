import assert from "node:assert/strict";
import test from "node:test";
import { validarRespostaGerador, QUADRINHO_LIMITES, TIPOS_COMPONENTE_OBRIGATORIOS, TIPOS_COMPONENTE_OPCIONAIS } from "../supabase/functions/_shared/gerar-aula/validador.mjs";

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

function componenteJurisprudencia(extra = {}) {
  return {
    tipo: "jurisprudencia_essencial",
    titulo: null,
    tribunal: "STF",
    identificacao_precedente: "HC 111.840",
    dispositivo_relacionado: "art. 1º, §7º",
    entendimento: "A imposição do regime inicial fechado não deve ocorrer automaticamente apenas pela literalidade do §7º, devendo ser observadas individualização da pena e fundamentação adequada.",
    como_cai_na_prova: "Alternativas podem afirmar, incorretamente, que o regime fechado é consequência automática.",
    fonte: "STF, HC 111.840",
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

// --- jurisprudencia_essencial: componente nativo OPCIONAL -----------------

test("aceita uma resposta com os 5 tipos obrigatórios e SEM jurisprudencia_essencial (não é obrigatório para nenhuma matéria)", () => {
  const resultado = validarRespostaGerador(respostaValida());
  assert.equal(resultado.ok, true);
  assert.ok(!resultado.componentes.some((c) => c.tipo === "jurisprudencia_essencial"));
});

test("aceita uma resposta válida que inclui jurisprudencia_essencial além dos 5 obrigatórios", () => {
  const dados = respostaValida();
  dados.componentes.splice(2, 0, componenteJurisprudencia());
  const resultado = validarRespostaGerador(dados);
  assert.equal(resultado.ok, true);
  assert.equal(resultado.componentes.length, 6);
  assert.ok(resultado.componentes.some((c) => c.tipo === "jurisprudencia_essencial"));
});

test("rejeita jurisprudencia_essencial sem entendimento", () => {
  const dados = respostaValida();
  dados.componentes.push(componenteJurisprudencia({ entendimento: "" }));
  const resultado = validarRespostaGerador(dados);
  assert.equal(resultado.ok, false);
  assert.match(resultado.erro, /entendimento/);
});

test("rejeita jurisprudencia_essencial sem tribunal", () => {
  const dados = respostaValida();
  dados.componentes.push(componenteJurisprudencia({ tribunal: "" }));
  const resultado = validarRespostaGerador(dados);
  assert.equal(resultado.ok, false);
  assert.match(resultado.erro, /tribunal/);
});

test("rejeita jurisprudencia_essencial estruturalmente inválida (dispositivo_relacionado ausente)", () => {
  const dados = respostaValida();
  const invalida = componenteJurisprudencia();
  delete invalida.dispositivo_relacionado;
  dados.componentes.push(invalida);
  const resultado = validarRespostaGerador(dados);
  assert.equal(resultado.ok, false);
  assert.match(resultado.erro, /dispositivo_relacionado/);
});

test("aceita jurisprudencia_essencial com titulo null (rótulo visual é sempre fixo)", () => {
  const dados = respostaValida();
  dados.componentes.push(componenteJurisprudencia({ titulo: null }));
  const resultado = validarRespostaGerador(dados);
  assert.equal(resultado.ok, true);
});

test("continua rejeitando tipo desconhecido mesmo com jurisprudencia_essencial reconhecido", () => {
  const dados = respostaValida();
  dados.componentes.push(componenteJurisprudencia());
  dados.componentes.push({ tipo: "video_aula", titulo: "x" });
  const resultado = validarRespostaGerador(dados);
  assert.equal(resultado.ok, false);
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

// ---------------------------------------------------------------------
// quadrinho_didatico (Fase Q2) — componente OPCIONAL, só roteiro.
// ---------------------------------------------------------------------

function quadro(extra = {}) {
  return {
    cena: "Um policial conversa com um morador na porta de casa, à noite.",
    falas: [{ emissor: "Policial", texto: "Ouvi gritos de socorro aí dentro." }],
    legenda: "Socorro autoriza o ingresso a qualquer hora.",
    ...extra,
  };
}

function componenteQuadrinho(extra = {}) {
  return {
    tipo: "quadrinho_didatico",
    titulo: "Entrar ou não entrar?",
    quadros: [quadro(), quadro({ falas: [] }), quadro({ legenda: undefined })],
    fechamento: "Flagrante, desastre e socorro: a qualquer hora. Ordem judicial: só de dia.",
    ...extra,
  };
}

function comQuadrinho(...quadrinhos) {
  const dados = respostaValida();
  dados.componentes.splice(2, 0, ...quadrinhos);
  return dados;
}

function nQuadros(n) {
  return Array.from({ length: n }, (_, i) => quadro({ cena: `Cena ${i + 1} do quadrinho.` }));
}

test("Q2-1: aula antiga sem quadrinho_didatico continua válida", () => {
  const r = validarRespostaGerador(respostaValida());
  assert.equal(r.ok, true);
  assert.equal(r.componentes.some((c) => c.tipo === "quadrinho_didatico"), false);
});

test("Q2-2: quadrinho válido com 3 quadros é aceito e preserva a posição", () => {
  const r = validarRespostaGerador(comQuadrinho(componenteQuadrinho()));
  assert.equal(r.ok, true);
  assert.equal(r.componentes[2].tipo, "quadrinho_didatico");
});

test("Q2-3: quadrinho válido com 6 quadros é aceito", () => {
  const r = validarRespostaGerador(comQuadrinho(componenteQuadrinho({ quadros: nQuadros(6) })));
  assert.equal(r.ok, true);
});

test("Q2-4: dois quadrinhos válidos na mesma aula são aceitos", () => {
  const r = validarRespostaGerador(comQuadrinho(componenteQuadrinho(), componenteQuadrinho({ titulo: "Outro caso" })));
  assert.equal(r.ok, true);
  assert.equal(r.componentes.filter((c) => c.tipo === "quadrinho_didatico").length, 2);
});

test("Q2-5: menos de 3 quadros é inválido", () => {
  for (const n of [0, 1, 2]) {
    const r = validarRespostaGerador(comQuadrinho(componenteQuadrinho({ quadros: nQuadros(n) })));
    assert.equal(r.ok, false);
    assert.match(r.erro, /quadros precisa ter de 3 a 6/);
  }
});

test("Q2-6: mais de 6 quadros é inválido", () => {
  const r = validarRespostaGerador(comQuadrinho(componenteQuadrinho({ quadros: nQuadros(7) })));
  assert.equal(r.ok, false);
  assert.match(r.erro, /quadros precisa ter de 3 a 6/);
});

test("Q2-7: titulo ausente ou vazio é inválido", () => {
  for (const titulo of [undefined, "", "   ", null, 5]) {
    const r = validarRespostaGerador(comQuadrinho(componenteQuadrinho({ titulo })));
    assert.equal(r.ok, false);
    assert.match(r.erro, /titulo/);
  }
});

test("Q2-8/9: cena ausente ou vazia é inválida", () => {
  for (const cena of [undefined, "", "  "]) {
    const quadros = nQuadros(3);
    quadros[1] = quadro({ cena });
    const r = validarRespostaGerador(comQuadrinho(componenteQuadrinho({ quadros })));
    assert.equal(r.ok, false);
    assert.match(r.erro, /quadros\[1\]\.cena/);
  }
});

test("Q2-10: falas ausente (ou não-array) é inválido", () => {
  for (const falas of [undefined, null, "oi"]) {
    const quadros = nQuadros(3);
    quadros[0] = quadro({ falas });
    const r = validarRespostaGerador(comQuadrinho(componenteQuadrinho({ quadros })));
    assert.equal(r.ok, false);
    assert.match(r.erro, /falas precisa ser um array/);
  }
});

test("Q2-11: falas=[] é válido", () => {
  const quadros = nQuadros(3).map((q) => ({ ...q, falas: [] }));
  assert.equal(validarRespostaGerador(comQuadrinho(componenteQuadrinho({ quadros }))).ok, true);
});

test("Q2-12: mais de 3 falas em um quadro é inválido (3 é aceito)", () => {
  const fala = (i) => ({ emissor: "A", texto: `Fala ${i}` });
  const ok = nQuadros(3);
  ok[0] = quadro({ falas: [fala(1), fala(2), fala(3)] });
  assert.equal(validarRespostaGerador(comQuadrinho(componenteQuadrinho({ quadros: ok }))).ok, true);
  const ruim = nQuadros(3);
  ruim[0] = quadro({ falas: [fala(1), fala(2), fala(3), fala(4)] });
  const r = validarRespostaGerador(comQuadrinho(componenteQuadrinho({ quadros: ruim })));
  assert.equal(r.ok, false);
  assert.match(r.erro, /mais de 3 falas/);
});

test("Q2-13: emissor ausente ou vazio em fala é inválido", () => {
  for (const emissor of [undefined, "", "  "]) {
    const quadros = nQuadros(3);
    quadros[0] = quadro({ falas: [{ emissor, texto: "Oi." }] });
    const r = validarRespostaGerador(comQuadrinho(componenteQuadrinho({ quadros })));
    assert.equal(r.ok, false);
    assert.match(r.erro, /falas\[0\]\.emissor/);
  }
});

test("Q2-14: texto ausente ou vazio em fala é inválido", () => {
  for (const texto of [undefined, "", "  "]) {
    const quadros = nQuadros(3);
    quadros[0] = quadro({ falas: [{ emissor: "A", texto }] });
    const r = validarRespostaGerador(comQuadrinho(componenteQuadrinho({ quadros })));
    assert.equal(r.ok, false);
    assert.match(r.erro, /falas\[0\]\.texto/);
  }
});

test("Q2-15: legenda ausente ou null é válida; legenda vazia é inválida", () => {
  for (const legenda of [undefined, null]) {
    const quadros = nQuadros(3).map((q) => ({ ...q, legenda }));
    assert.equal(validarRespostaGerador(comQuadrinho(componenteQuadrinho({ quadros }))).ok, true);
  }
  const quadros = nQuadros(3);
  quadros[2] = quadro({ legenda: "  " });
  const r = validarRespostaGerador(comQuadrinho(componenteQuadrinho({ quadros })));
  assert.equal(r.ok, false);
  assert.match(r.erro, /legenda/);
});

test("Q2-16: fechamento ausente ou vazio é inválido", () => {
  for (const fechamento of [undefined, "", "  "]) {
    const r = validarRespostaGerador(comQuadrinho(componenteQuadrinho({ fechamento })));
    assert.equal(r.ok, false);
    assert.match(r.erro, /fechamento/);
  }
});

test("Q2-17: id enviado pela IA continua proibido no quadrinho", () => {
  const r = validarRespostaGerador(comQuadrinho(componenteQuadrinho({ id: "11111111-1111-4111-8111-111111111111" })));
  assert.equal(r.ok, false);
  assert.match(r.erro, /"id"/);
});

test("Q2-18: campos reservados (imagem, asset_id, url, html, alt, fundamento, objetivo_pedagogico, ordem) são rejeitados no componente", () => {
  for (const campo of ["imagem", "asset_id", "url", "html", "alt", "fundamento", "objetivo_pedagogico", "ordem"]) {
    const r = validarRespostaGerador(comQuadrinho(componenteQuadrinho({ [campo]: "x" })));
    assert.equal(r.ok, false, campo);
    assert.match(r.erro, new RegExp(`campo não permitido: "${campo}"`));
  }
});

test("Q2-18b: campos reservados também são rejeitados dentro de quadro e de fala", () => {
  const q1 = nQuadros(3);
  q1[0] = quadro({ imagem: "x" });
  assert.match(validarRespostaGerador(comQuadrinho(componenteQuadrinho({ quadros: q1 }))).erro, /quadros\[0\] tem campo não permitido: "imagem"/);
  const q2 = nQuadros(3);
  q2[0] = quadro({ ordem: 1 });
  assert.equal(validarRespostaGerador(comQuadrinho(componenteQuadrinho({ quadros: q2 }))).ok, false);
  const q3 = nQuadros(3);
  q3[0] = quadro({ falas: [{ emissor: "A", texto: "Oi.", url: "x" }] });
  assert.match(validarRespostaGerador(comQuadrinho(componenteQuadrinho({ quadros: q3 }))).erro, /falas\[0\] tem campo não permitido: "url"/);
});

test("Q2-19: tipo desconhecido continua inválido com quadrinho_didatico reconhecido", () => {
  const dados = comQuadrinho(componenteQuadrinho());
  dados.componentes.push({ tipo: "quadrinho", titulo: "x" });
  assert.equal(validarRespostaGerador(dados).ok, false);
});

test("Q2-20: quadrinho conta para o limite global de 40 componentes", () => {
  const base = respostaValida();
  const completar = (total) => {
    const dados = { ...base, componentes: [...base.componentes] };
    while (dados.componentes.length < total) dados.componentes.push(componenteQuadrinho());
    return dados;
  };
  assert.equal(validarRespostaGerador(completar(40)).ok, true);
  const r = validarRespostaGerador(completar(41));
  assert.equal(r.ok, false);
  assert.match(r.erro, /quantidade de componentes fora do razoável/);
});

test("Q2-21: campos acima dos limites de tamanho são inválidos (no limite é válido)", () => {
  const L = QUADRINHO_LIMITES;
  const nos = (n) => "x".repeat(n);
  const casos = [
    ["titulo", (n) => componenteQuadrinho({ titulo: nos(n) }), L.tituloMax, /titulo excede/],
    ["cena", (n) => componenteQuadrinho({ quadros: [quadro({ cena: nos(n) }), quadro(), quadro()] }), L.cenaMax, /cena excede/],
    ["emissor", (n) => componenteQuadrinho({ quadros: [quadro({ falas: [{ emissor: nos(n), texto: "Oi." }] }), quadro(), quadro()] }), L.emissorMax, /emissor excede/],
    ["texto da fala", (n) => componenteQuadrinho({ quadros: [quadro({ falas: [{ emissor: "A", texto: nos(n) }] }), quadro(), quadro()] }), L.falaTextoMax, /texto excede/],
    ["legenda", (n) => componenteQuadrinho({ quadros: [quadro({ legenda: nos(n) }), quadro(), quadro()] }), L.legendaMax, /legenda excede/],
    ["fechamento", (n) => componenteQuadrinho({ fechamento: nos(n) }), L.fechamentoMax, /fechamento excede/],
  ];
  for (const [nome, montar, max, padrao] of casos) {
    assert.equal(validarRespostaGerador(comQuadrinho(montar(max))).ok, true, `${nome} no limite`);
    const r = validarRespostaGerador(comQuadrinho(montar(max + 1)));
    assert.equal(r.ok, false, `${nome} acima do limite`);
    assert.match(r.erro, padrao);
  }
});

test("Q2-22: quadrinho_didatico é OPCIONAL (fora dos obrigatórios) e quadro não-objeto é rejeitado", () => {
  assert.equal(TIPOS_COMPONENTE_OBRIGATORIOS.includes("quadrinho_didatico"), false);
  assert.equal(TIPOS_COMPONENTE_OPCIONAIS.includes("quadrinho_didatico"), true);
  const quadros = nQuadros(3);
  quadros[1] = "cena solta";
  const r = validarRespostaGerador(comQuadrinho(componenteQuadrinho({ quadros })));
  assert.equal(r.ok, false);
  assert.match(r.erro, /quadros\[1\] não é um objeto/);
});
