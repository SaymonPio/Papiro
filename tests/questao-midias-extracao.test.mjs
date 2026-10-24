import assert from "node:assert/strict";
import test from "node:test";
import { inflateSync } from "node:zlib";
import { anexarMidias, codificarPng, comporFigura, resolverMidias } from "../scripts/importador-provas/lib/midias.mjs";
import { calcularStatus } from "../scripts/importador-provas/lib/score.mjs";

// PAPIRO — mídias de questões extraídas do PDF (lib/midias.mjs). Páginas 100% sintéticas no mesmo formato de
// lerPaginasVisuais: linhas de texto com geometria (y = linha de base, PDF com y para cima), objetos de imagem
// (caixa na página + pixels RGBA) e vetores pintados.

function imagem(id, pintura, [x0, y0, x1, y1], cor, { px = [40, 20], alfa = 255 } = {}) {
  const [pxL, pxA] = px;
  const rgba = new Uint8Array(pxL * pxA * 4);
  for (let i = 0; i < pxL * pxA; i++) rgba.set([...cor, alfa], i * 4);
  return { tipo: "imagem", id, pintura, x0, y0, x1, y1, pxL, pxA, rgba, clip: null, suportada: true, motivo: null };
}
const linha = (texto, y, x0 = 50, x1 = 520) => ({ texto, y, xInicio: x0, xFim: x1 });
const pagina = (numero, linhas, imagens, vetores = []) => ({ numero, largura: 595, altura: 842, linhas, imagens, vetores });
const ALTS = ["Primeira opção completa", "Segunda opção completa", "Terceira opção completa", "Quarta opção completa", "Quinta opção completa"];
const questao = (numero, enunciado, alternativas = ALTS, interno = {}) => ({
  numero_original: numero,
  enunciado,
  alternativas: alternativas.map((texto, i) => ({ letra: "ABCDE"[i], texto, correta: i === 1 })),
  _interno: { alternativa_faltante: false, motivos_juncao: [], gabarito_status: "ok", ...interno },
});
const linhasDeAlternativas = (yInicial) => ALTS.map((t, i) => linha(t, yInicial - i * 14));

// Q1 com Figura 1 entre o comando e a pergunta.
function cenarioFigura({ imagens, vetores = [], legenda = "Figura 1 – Painel sintético de testes", enunciado } = {}) {
  const texto = enunciado ?? `Observe a Figura 1 a seguir para responder à questão.\n${legenda}\nQual elemento aparece em evidência no painel?`;
  const q = questao(1, texto);
  const p = pagina(
    3,
    [linha("Observe a Figura 1 a seguir para responder à questão.", 720), linha(legenda, 590, 150, 420), linha("Qual elemento aparece em evidência no painel?", 570), ...linhasDeAlternativas(550)],
    imagens ?? [imagem("img1", 10, [150, 600, 350, 700], [10, 120, 200])],
    vetores,
  );
  return { q, p };
}

test("A) questão sem mídia e sem referência visual: nada muda (nem entra no resultado)", () => {
  const q = questao(1, "Qual é o prazo legal para o recurso administrativo comum?");
  const r = resolverMidias({ paginas: [pagina(2, [linha("Qual é o prazo legal para o recurso administrativo comum?", 700), ...linhasDeAlternativas(680)], [])], questoes: [q] });
  assert.equal(r.porQuestao.size, 0);
  assert.equal(r.arquivos.size, 0);
  const antes = JSON.stringify(q);
  anexarMidias(q, r.porQuestao.get(1));
  assert.equal(JSON.stringify(q), antes, "staging da questão sem mídia fica idêntico");
});

test("B) 1 imagem: dona pela geometria, legenda, âncora na linha da legenda, tipo, dimensões, sha256 e PNG válido", () => {
  const { q, p } = cenarioFigura();
  const r = resolverMidias({ paginas: [p], questoes: [q] });
  const res = r.porQuestao.get(1);
  assert.equal(res.status, "OK", JSON.stringify(res.causas));
  assert.equal(res.midias.length, 1);
  const m = res.midias[0];
  assert.equal(m.ordem, 1);
  assert.equal(m.tipo, "FIGURA");
  assert.equal(m.legenda, "Figura 1 – Painel sintético de testes");
  assert.equal(m.ancora_texto, "Figura 1 – Painel sintético de testes");
  assert.equal(m.pagina_origem, 3);
  assert.equal(m.storage_path, `questoes/${m.sha256}.png`);
  assert.equal(m.direito_uso, "OFICIAL_PROVA");
  const png = r.arquivos.get(m.sha256);
  assert.deepEqual([...png.subarray(0, 8)], [137, 80, 78, 71, 13, 10, 26, 10]);
  assert.equal(png.readUInt32BE(16), m.largura);
  assert.equal(png.readUInt32BE(20), m.altura);
  assert.deepEqual([m.largura, m.altura], [40, 20], "resolução nativa do objeto: nunca amplia artificialmente");
});

test("C) 2 imagens separadas e referenciadas: ordem determinística de cima para baixo, uma por legenda", () => {
  const texto = "Compare a Figura 1 e a Figura 2 a seguir com atenção.\nFigura 1 – Primeiro painel sintético\nFigura 2 – Segundo painel sintético\nQual das figuras mostra o painel maior?";
  const q = questao(1, texto);
  const p = pagina(
    5,
    [
      linha("Compare a Figura 1 e a Figura 2 a seguir com atenção.", 780),
      linha("Figura 1 – Primeiro painel sintético", 640, 150, 420),
      linha("Figura 2 – Segundo painel sintético", 520, 150, 420),
      linha("Qual das figuras mostra o painel maior?", 500),
      ...linhasDeAlternativas(480),
    ],
    [imagem("baixo", 20, [150, 530, 350, 600], [200, 0, 0]), imagem("cima", 10, [150, 650, 350, 760], [0, 0, 200])],
  );
  const res = resolverMidias({ paginas: [p], questoes: [q] }).porQuestao.get(1);
  assert.equal(res.status, "OK", JSON.stringify(res.causas));
  assert.deepEqual(res.midias.map((m) => [m.ordem, m.componentes[0], m.legenda]), [
    [1, "cima", "Figura 1 – Primeiro painel sintético"],
    [2, "baixo", "Figura 2 – Segundo painel sintético"],
  ]);
});

test("D) figura composta (print + overlay RGBA + traço vetorial): reconstruída pela posição, determinística", () => {
  const print = imagem("print", 10, [150, 600, 350, 700], [255, 255, 255], { px: [200, 100] });
  const sombra = imagem("sombra", 11, [320, 640, 360, 690], [0, 0, 0], { px: [20, 25], alfa: 64 });
  const anel = { tipo: "vetor", id: "vetor12", pintura: 12, x0: 325, y0: 645, x1: 355, y1: 685, subcaminhos: [[325, 645, 355, 645, 355, 685, 325, 685, 325, 645]], traca: true, preenche: false, parImpar: false, corTraco: "#ff0000", corFundo: "#000000", larguraTraco: 2, clip: null, suportada: true, motivo: null };
  const { q, p } = cenarioFigura({ imagens: [print, sombra], vetores: [anel] });
  const r1 = resolverMidias({ paginas: [p], questoes: [q] });
  const r2 = resolverMidias({ paginas: [structuredClone(p)], questoes: [structuredClone(q)] });
  const m = r1.porQuestao.get(1).midias[0];
  assert.equal(r1.porQuestao.get(1).status, "OK", JSON.stringify(r1.porQuestao.get(1).causas));
  assert.deepEqual(m.componentes, ["print", "sombra", "vetor12"]);
  assert.equal(m.sha256, r2.porQuestao.get(1).midias[0].sha256, "mesma entrada, mesmo hash");
  assert.match(m.origem_descricao, /2 objeto\(s\) de imagem.*1 traço\(s\) vetorial\(is\), compostos pela posição/);
  // pixels: fundo do print branco, sombra misturada (alfa 64) e anel vermelho no contorno
  const composta = comporFigura([print, sombra, anel]);
  const px = (xPt, yPt) => {
    const x = Math.floor((xPt - composta.caixa.x0) * (composta.largura / (composta.caixa.x1 - composta.caixa.x0)));
    const y = Math.floor((composta.caixa.y1 - yPt) * (composta.altura / (composta.caixa.y1 - composta.caixa.y0)));
    return [...composta.rgb.subarray((y * composta.largura + x) * 3, (y * composta.largura + x) * 3 + 3)];
  };
  assert.deepEqual(px(200, 650), [255, 255, 255]);
  assert.deepEqual(px(340, 665), [191, 191, 191], "sombra preta com alfa 64 sobre branco");
  assert.deepEqual(px(325, 665), [255, 0, 0], "traço vetorial vermelho reproduzido");
});

test("E) mesma mídia em duas questões (texto-base compartilhado): as duas recebem a figura, mesmo sha256", () => {
  const textoBase = "O gráfico abaixo apresenta os registros mensais de ocorrências.\nFonte dos dados municipais consolidados no período.";
  const q1 = questao(1, `${textoBase}\nDe acordo com o gráfico, o mês com mais registros foi:`, ALTS, { enunciado_comando: "De acordo com o gráfico, o mês com mais registros foi:" });
  const q2 = questao(2, `${textoBase}\nSegundo o gráfico, a tendência no período foi de:`, ["Alta contínua", "Queda contínua", "Estabilidade", "Oscilação", "Nenhuma"], { enunciado_comando: "Segundo o gráfico, a tendência no período foi de:" });
  const p = pagina(2, [
    linha("O gráfico abaixo apresenta os registros mensais de ocorrências.", 760),
    linha("Fonte dos dados municipais consolidados no período.", 600),
    linha("De acordo com o gráfico, o mês com mais registros foi:", 560),
  ], [imagem("grafico", 5, [100, 620, 400, 740], [0, 150, 0])]);
  const r = resolverMidias({ paginas: [p], questoes: [q1, q2] });
  const [m1, m2] = [r.porQuestao.get(1), r.porQuestao.get(2)];
  assert.equal(m1.status, "OK", JSON.stringify(m1.causas));
  assert.equal(m2.status, "OK", JSON.stringify(m2.causas));
  assert.equal(m1.midias[0].sha256, m2.midias[0].sha256);
  assert.equal(r.arquivos.size, 1, "um arquivo só (conteúdo-endereçado)");
  assert.equal(m1.midias[0].tipo, "GRAFICO");
  assert.equal(m1.midias[0].ancora_texto, "Fonte dos dados municipais consolidados no período.");
});

test("G) referência visual sem mídia no PDF -> MIDIA_OK=false (midia_ausente) e questão em revisão", () => {
  const q = questao(1, "Analise o gráfico a seguir sobre a evolução das ocorrências.\nQual foi a tendência observada?", ALTS, { referencia_visual: 'cita elemento visual ("gráfico a seguir")' });
  const r = resolverMidias({ paginas: [pagina(4, [linha("Analise o gráfico a seguir sobre a evolução das ocorrências.", 700), ...linhasDeAlternativas(650)], [])], questoes: [q] });
  const res = r.porQuestao.get(1);
  assert.equal(res.status, "REVISAO");
  assert.deepEqual(res.causas.map((c) => c.codigo), ["midia_ausente"]);
  anexarMidias(q, res);
  const status = calcularStatus(q, { status: "nova", match_id: null }, [], { prova: {}, completa: true, faltando: [], invalidos: [] });
  assert.equal(status.etapas.MIDIA_OK, false);
  assert.equal(status.etapas.EXTRACAO_OK, false, "referência visual não resolvida continua falha de extração");
  assert.equal(status.status, "REVISAO_MANUAL");
});

test("H) mídia na região da questão sem referência no texto -> midia_sem_referencia (liberável só por revisão humana)", () => {
  const { q, p } = cenarioFigura({ enunciado: "Considere a situação descrita para responder à questão.\nQual elemento aparece em evidência no painel?" });
  p.linhas = [linha("Considere a situação descrita para responder à questão.", 720), linha("Qual elemento aparece em evidência no painel?", 570), ...linhasDeAlternativas(550)];
  const res = resolverMidias({ paginas: [p], questoes: [q] }).porQuestao.get(1);
  assert.equal(res.status, "REVISAO");
  assert.ok(res.causas.some((c) => c.codigo === "midia_sem_referencia"));
});

test("REF) referência resolvida por mídia deixa de ser falha de extração; destaque tipográfico não é resolvido por imagem", () => {
  const { q, p } = cenarioFigura();
  q._interno.referencia_visual = 'cita elemento visual ("Figura 1 a seguir")';
  anexarMidias(q, resolverMidias({ paginas: [p], questoes: [q] }).porQuestao.get(1));
  const ok = calcularStatus(q, { status: "nova", match_id: null }, [], { prova: {}, completa: true, faltando: [], invalidos: [] });
  assert.deepEqual([ok.etapas.EXTRACAO_OK, ok.etapas.MIDIA_OK, ok.status], [true, true, "PRONTA_PARA_REVISAO"]);

  const { q: q2, p: p2 } = cenarioFigura({ enunciado: "Observe a Figura 1 a seguir para responder à questão.\nFigura 1 – Painel sintético de testes\nQual elemento aparece sublinhado no painel?" });
  p2.linhas[2] = linha("Qual elemento aparece sublinhado no painel?", 570);
  q2._interno.referencia_visual = 'cita elemento visual ("sublinhado")';
  anexarMidias(q2, resolverMidias({ paginas: [p2], questoes: [q2] }).porQuestao.get(1));
  assert.equal(calcularStatus(q2, { status: "nova", match_id: null }, [], { prova: {}, completa: true, faltando: [], invalidos: [] }).etapas.EXTRACAO_OK, false);
});

test("DECOR) fundo de página, logo repetido em 3 páginas e ícone minúsculo nunca viram mídia de questão", () => {
  const logo = (pg) => imagem("logo", 1, [40, 790, 120, 830], [9, 9, 9]);
  const paginas = [1, 2, 3].map((n) => pagina(n, [linha("Texto institucional qualquer da prova", 760)], [logo(n), ...(n === 1 ? [imagem("fundo", 0, [0, 0, 595, 842], [240, 240, 240]), imagem("icone", 2, [300, 300, 306, 306], [0, 0, 0])] : [])]));
  const r = resolverMidias({ paginas, questoes: [questao(1, "Qual é o prazo legal para o recurso administrativo comum?")] });
  assert.equal(r.porQuestao.size, 0);
  assert.deepEqual(new Set(r.ignoradas.map((i) => i.id)), new Set(["fundo", "icone", "logo"]));
});

test("AMB) figura entre duas questões que citam figura, sem legenda que decida -> posse ambígua nas duas", () => {
  const q1 = questao(1, "Observe a imagem a seguir sobre o primeiro tema da prova.\nQual é a resposta do primeiro tema?", ["Resposta alfa um", "Resposta beta um", "Resposta gama um", "Resposta delta um", "Resposta épsilon um"]);
  const q2 = questao(2, "Observe a imagem abaixo sobre o segundo tema da prova.\nQual é a resposta do segundo tema?", ["Resposta alfa dois", "Resposta beta dois", "Resposta gama dois", "Resposta delta dois", "Resposta épsilon dois"]);
  const p = pagina(6, [
    linha("Resposta épsilon um", 700), linha("Resposta delta um", 714), linha("Resposta gama um", 728),
    linha("Observe a imagem abaixo sobre o segundo tema da prova.", 560), linha("Qual é a resposta do segundo tema?", 546),
  ], [imagem("solta", 3, [150, 580, 350, 680], [50, 50, 50])]);
  const r = resolverMidias({ paginas: [p], questoes: [q1, q2] });
  for (const n of [1, 2]) assert.ok(r.porQuestao.get(n).causas.some((c) => c.codigo === "midia_posse_ambigua"), `Q${n}`);
});

test("CONF) composição não confiável vira revisão: vetor só parcialmente sobre a figura, texto sobre a figura, imagem rotacionada", () => {
  const parcial = { tipo: "vetor", id: "seta", pintura: 11, x0: 300, y0: 650, x1: 500, y1: 660, subcaminhos: [[300, 655, 500, 655]], traca: true, preenche: false, corTraco: "#000000", larguraTraco: 1, clip: null, suportada: true };
  const casos = [
    [cenarioFigura({ vetores: [parcial] }), /parcialmente/],
    [(() => { const c = cenarioFigura(); c.p.linhas.push(linha("Rótulo escrito sobre a figura", 650, 160, 340)); return c; })(), /texto sobre a figura/],
    [cenarioFigura({ imagens: [{ ...imagem("girada", 10, [150, 600, 350, 700], [1, 2, 3]), suportada: false, motivo: "imagem rotacionada/espelhada" }] }), /rotacionada/],
  ];
  for (const [{ q, p }, padrao] of casos) {
    const res = resolverMidias({ paginas: [p], questoes: [q] }).porQuestao.get(1);
    assert.equal(res.status, "REVISAO");
    assert.ok(res.causas.some((c) => c.codigo === "midia_composicao_incerta" && padrao.test(c.motivo)), JSON.stringify(res.causas));
    assert.equal(res.midias[0].sha256, null, "nada é gerado quando a composição não é confiável");
  }
});

test("POS) figura no meio de um parágrafo do enunciado -> posição incerta (nunca chuta)", () => {
  const enunciado = "Observe a Figura 1 a seguir e leia com atenção o parágrafo que continua logo depois dela até o fim da frase.\nQual elemento aparece em evidência no painel?";
  const { q, p } = cenarioFigura({ enunciado });
  p.linhas = [linha("Observe a Figura 1 a seguir e leia com atenção o parágrafo", 720), linha("que continua logo depois dela até o fim da frase.", 590), linha("Qual elemento aparece em evidência no painel?", 570), ...linhasDeAlternativas(550)];
  const res = resolverMidias({ paginas: [p], questoes: [q] }).porQuestao.get(1);
  assert.ok(res.causas.some((c) => c.codigo === "midia_posicao_incerta" && /meio de um parágrafo/.test(c.motivo)), JSON.stringify(res.causas));
});

test("M) peça de terceiro (charge, ou crédito/fonte junto da figura) entra como REVISAO_DIREITOS; crédito não é permissão", () => {
  const charge = cenarioFigura({ enunciado: "Analise a charge a seguir e responda.\nQual crítica a charge apresenta?", legenda: "Qual crítica a charge apresenta?" });
  charge.p.linhas = [linha("Analise a charge a seguir e responda.", 720), linha("Qual crítica a charge apresenta?", 590), ...linhasDeAlternativas(570)];
  const mCharge = resolverMidias({ paginas: [charge.p], questoes: [charge.q] }).porQuestao.get(1).midias[0];
  assert.equal(mCharge.tipo, "CHARGE");
  assert.equal(mCharge.direito_uso, "REVISAO_DIREITOS");

  const comFonte = cenarioFigura();
  comFonte.p.linhas.push(linha("Fonte: jornal regional, edição de domingo", 596, 150, 420));
  const mFonte = resolverMidias({ paginas: [comFonte.p], questoes: [comFonte.q] }).porQuestao.get(1).midias[0];
  assert.equal(mFonte.direito_uso, "REVISAO_DIREITOS");
  assert.equal(mFonte.credito, "Fonte: jornal regional, edição de domingo");
});

test("L) alt_text: usa a legenda (já visível) ou rótulo genérico — nunca o texto de uma alternativa", () => {
  const { q, p } = cenarioFigura({ legenda: "Figura 1 – Segunda opção completa em destaque", enunciado: "Observe a Figura 1 a seguir para responder à questão.\nFigura 1 – Segunda opção completa em destaque\nQual elemento aparece em evidência no painel?" });
  const m = resolverMidias({ paginas: [p], questoes: [q] }).porQuestao.get(1).midias[0];
  assert.equal(m.alt_text, "Figura da questão 1");
  for (const alt of ALTS) assert.ok(!m.alt_text.toLowerCase().includes(alt.toLowerCase()));
  const normal = resolverMidias({ paginas: [cenarioFigura().p], questoes: [cenarioFigura().q] }).porQuestao.get(1).midias[0];
  assert.equal(normal.alt_text, "Figura 1 – Painel sintético de testes");
});

test("PNG) codificação determinística e decodificável (RGB 8 bits, filtro 0)", () => {
  const rgb = new Uint8Array([255, 0, 0, 0, 255, 0, 0, 0, 255, 9, 9, 9]);
  const a = codificarPng(2, 2, rgb);
  assert.deepEqual(a, codificarPng(2, 2, rgb));
  const idat = a.subarray(a.indexOf("IDAT") + 4, a.indexOf("IEND") - 8);
  assert.deepEqual([...inflateSync(idat)], [0, 255, 0, 0, 0, 255, 0, 0, 0, 0, 255, 9, 9, 9]);
});

// Diagrama/fluxograma/esquema com contexto visual explícito exigem mídia (checado numa prova real: Fundatec/
// Araquari 2025, questão 15 — "diagrama lógico abaixo" passava com todas as etapas OK e sem figura).
const STATUS_LIMPO = [{ status: "nova", match_id: null }, [], { prova: {}, completa: true, faltando: [], invalidos: [] }];
function semMidia(enunciado) {
  const q = { ...questao(1, `${enunciado}\nQual é o resultado indicado?`), confidence: "alta" };
  const res = resolverMidias({ paginas: [pagina(6, [linha(enunciado, 700), linha("Qual é o resultado indicado?", 686), ...linhasDeAlternativas(660)], [])], questoes: [q] }).porQuestao.get(1);
  anexarMidias(q, res);
  return { q, res, status: calcularStatus(q, ...STATUS_LIMPO) };
}

for (const [rotulo, enunciado] of [["VIS-A", "Considere o diagrama abaixo."], ["VIS-B", "De acordo com o fluxograma a seguir, responda."], ["VIS-C", "Observe o esquema apresentado abaixo."]]) {
  test(`${rotulo}) "${enunciado}" sem mídia -> midia_ausente, MIDIA_OK=false e REVISAO mesmo com as demais etapas OK`, () => {
    const { res, status } = semMidia(enunciado);
    assert.deepEqual(res.causas.map((c) => c.codigo), ["midia_ausente"]);
    assert.equal(status.etapas.MIDIA_OK, false);
    assert.deepEqual(Object.entries(status.etapas).filter(([k, v]) => k !== "MIDIA_OK" && !v), [], "só a mídia trava a questão");
    assert.equal(status.status, "REVISAO_MANUAL");
  });
}

test("VIS-D) diagrama com figura associada pela legenda -> MIDIA_OK", () => {
  const legenda = "Figura 1 – Diagrama sintético de operações";
  const { q, p } = cenarioFigura({ legenda, enunciado: `Considere o diagrama abaixo para responder à questão.\n${legenda}\nQual elemento aparece em evidência no painel?` });
  p.linhas[0] = linha("Considere o diagrama abaixo para responder à questão.", 720);
  q._interno.referencia_visual = 'cita elemento visual ("diagrama abaixo")';
  const res = resolverMidias({ paginas: [p], questoes: [q] }).porQuestao.get(1);
  assert.equal(res.status, "OK", JSON.stringify(res.causas));
  anexarMidias(q, res);
  const status = calcularStatus(q, ...STATUS_LIMPO);
  assert.deepEqual([status.etapas.EXTRACAO_OK, status.etapas.MIDIA_OK, status.status], [true, true, "PRONTA_PARA_REVISAO"]);
});

test("VIS-E) \"esquema\" narrativo, sem contexto visual, não exige mídia", () => {
  for (const enunciado of ["O esquema de corrupção apresentado pelo Ministério Público envolvia servidores.", "O esquema tático dado pelo treinador foi criticado."]) {
    const q = questao(1, enunciado);
    const r = resolverMidias({ paginas: [pagina(2, [linha(enunciado, 700), ...linhasDeAlternativas(680)], [])], questoes: [q] });
    assert.equal(r.porQuestao.size, 0, enunciado);
  }
});
