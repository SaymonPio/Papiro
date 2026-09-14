import assert from "node:assert/strict";
import test from "node:test";
import { prepararAulaImpressao, normalizarComponenteImpressao } from "../components/teoria/prepararAulaImpressao.ts";

// Fixture: exatamente os 11 componentes já publicados da aula real de Lei
// de Tortura (piloto do PDF) — usada só como dado de teste, nunca
// hardcoded na implementação (prepararAulaImpressao.ts não sabe o nome
// "Lei de Tortura" nem "HC 111.840").
const ESTRUTURA_LEI_TORTURA = {
  componentes: [
    { tipo: "diagnostico", titulo: "Antes de decorar: reconheça a tortura na prática",
      introducao: "Antes de entrar nos detalhes da lei...", pergunta: "Um agente utiliza violência...",
      resposta_esperada: "Sim. A tortura pode estar configurada quando..." },
    { tipo: "conceito", titulo: "O núcleo da Lei de Tortura", explicacao: "A Lei nº 9.455/1997 considera tortura...",
      exemplo: "Um agente ameaça uma pessoa...", ponto_de_prova: "Preste atenção à combinação...", pegadinha: "Não confunda tortura..." },
    { tipo: "conceito", titulo: "Consequências e circunstâncias relevantes", explicacao: "A pena básica...",
      exemplo: "Se um agente público pratica tortura...", ponto_de_prova: "Memorize a sequência...", pegadinha: "A condição de agente público..." },
    { tipo: "conceito", titulo: "Regime inicial (art. 1º, §7º)", explicacao: "O art. 1º, §7º, da Lei nº 9.455/1997...",
      exemplo: null, ponto_de_prova: "Grave a redação literal...", pegadinha: "Não afirme que \"o regime fechado é proibido\"..." },
    { tipo: "jurisprudencia_essencial", titulo: null, tribunal: "STF", identificacao_precedente: "HC 111.840",
      dispositivo_relacionado: "art. 1º, §7º, Lei nº 9.455/1997", entendimento: "O STF entende que a imposição do regime inicial fechado...",
      como_cai_na_prova: "Desconfie de alternativas que tratem o regime fechado como consequência obrigatória...", fonte: "STF, HC 111.840" },
    { tipo: "recall", dica: "Pense: o texto da lei continua existindo...", titulo: "O que o STF decidiu sobre o regime fechado automático?",
      pergunta: "O art. 1º, §7º, da Lei de Tortura prevê regime inicial fechado...", resposta: "Não. Segundo o STF (HC 111.840)..." },
    { tipo: "recall", dica: "Pense na sequência: informação/confissão; crime.", titulo: "Recupere os elementos antes de olhar a resposta",
      pergunta: "Quais são as duas finalidades específicas...", resposta: "Obter informação, declaração ou confissão..." },
    { tipo: "recall", dica: "Associe castigo à relação de guarda...", titulo: "Diferença que muda o enquadramento",
      pergunta: "Qual é a diferença central entre a tortura-castigo...", resposta: "Na tortura-castigo, a vítima está sob guarda..." },
    { tipo: "recall", dica: "Pense: reiteração + contexto doméstico...", titulo: "Inciso III é uma nova finalidade ou uma conduta própria?",
      pergunta: "Um homem submete, de forma reiterada...", resposta: "Sim. Trata-se da hipótese autônoma do art. 1º, III..." },
    { tipo: "questao_resolvida", gabarito: "B", enunciado: "Durante uma abordagem, um agente público utiliza grave ameaça...",
      pegadinha: "O ponto decisivo é separar finalidade de resultado.",
      raciocinio: "A alternativa B está correta. A forma principal de tortura exige...",
      alternativas: [
        { letra: "A", texto: "Não há tortura, porque a informação não foi efetivamente obtida." },
        { letra: "B", texto: "Pode haver tortura, pois a lei considera a finalidade de obter informação..." },
        { letra: "C", texto: "Só haveria tortura se a vítima estivesse presa ou submetida a medida de segurança." },
        { letra: "D", texto: "A conduta é apenas ameaça, porque agente público não pode praticar tortura..." },
      ] },
    { tipo: "resumo_visual", titulo: "Lei de Tortura — mapa para a prova",
      pontos: ["Forma principal: violência ou grave ameaça...", "Regime inicial (art. 1º, §7º): o texto prevê regime fechado..."] },
  ],
  artigos_abordados: ["art. 1º, I, \"a\"", "art. 1º, §7º", "art. 2º, caput"],
};

const FONTES_EXEMPLO = [
  { material_titulo: "Lei nº 9.455/1997", material_tipo: "lei", titulo_versao: "Texto vigente", material_versao_id: "x" },
];

function prepararFixtureLeiTortura() {
  return prepararAulaImpressao({
    materiaNome: "Direitos Humanos e Cidadania",
    conteudoNome: "Lei de Tortura",
    unidadeTitulo: "Lei de Tortura",
    aulaTitulo: "Lei de Tortura",
    cursoNome: "Brigada Militar RS",
    numeroVersao: 1,
    publicadoEm: "2026-09-14T09:23:56.895541+00:00",
    estrutura: ESTRUTURA_LEI_TORTURA,
    fontes: FONTES_EXEMPLO,
  });
}

test("A) Lei de Tortura possui 11 componentes na entrada", () => {
  assert.equal(ESTRUTURA_LEI_TORTURA.componentes.length, 11);
});

test("B) todos os 11 componentes são representados na saída (nenhum descartado)", () => {
  const modelo = prepararFixtureLeiTortura();
  assert.equal(modelo.componentes.length, 11);
});

test("C) jurisprudencia_essencial aparece no modelo de impressão", () => {
  const modelo = prepararFixtureLeiTortura();
  const juris = modelo.componentes.find((c) => c.tipo === "jurisprudencia_essencial");
  assert.ok(juris, "componente jurisprudencia_essencial deveria estar presente");
});

test("D) STF e HC 111.840 aparecem intactos no componente de jurisprudência", () => {
  const modelo = prepararFixtureLeiTortura();
  const juris = modelo.componentes.find((c) => c.tipo === "jurisprudencia_essencial");
  assert.equal(juris.tribunal, "STF");
  assert.equal(juris.identificacaoPrecedente, "HC 111.840");
  assert.equal(juris.dispositivoRelacionado, "art. 1º, §7º, Lei nº 9.455/1997");
});

test("E/F) recall contém pergunta, dica e resposta, sempre juntas (sem estado de revelar)", () => {
  const modelo = prepararFixtureLeiTortura();
  const recalls = modelo.componentes.filter((c) => c.tipo === "recall");
  assert.equal(recalls.length, 4);
  for (const r of recalls) {
    assert.ok(r.pergunta, "recall deveria ter pergunta");
    assert.ok(r.dica, "recall deveria ter dica");
    assert.ok(r.resposta, "recall deveria ter resposta sempre visível");
  }
});

test("F) diagnóstico contém resposta_esperada sempre visível (sem estado de revelar)", () => {
  const modelo = prepararFixtureLeiTortura();
  const diagnostico = modelo.componentes.find((c) => c.tipo === "diagnostico");
  assert.ok(diagnostico.respostaEsperada, "diagnostico deveria ter respostaEsperada preenchida");
});

test("G) questao_resolvida contém alternativas + gabarito marcado + explicação (raciocínio)", () => {
  const modelo = prepararFixtureLeiTortura();
  const questao = modelo.componentes.find((c) => c.tipo === "questao_resolvida");
  assert.equal(questao.alternativas.length, 4);
  const corretas = questao.alternativas.filter((a) => a.correta);
  assert.equal(corretas.length, 1);
  assert.equal(corretas[0].letra, "B");
  assert.equal(questao.gabarito, "B");
  assert.ok(questao.raciocinio, "questao_resolvida deveria ter raciocinio (explicação)");
});

test("K) o modelo nunca inclui campos de progresso/resposta pessoal do aluno", () => {
  const modelo = prepararFixtureLeiTortura();
  const chavesTopo = Object.keys(modelo);
  for (const proibida of ["progresso", "respostas", "erros", "revisoes", "usuario", "matricula"]) {
    assert.ok(!chavesTopo.some((k) => k.toLowerCase().includes(proibida)), `chave de topo não deveria conter "${proibida}"`);
  }
});

test("L) funciona para uma aula genérica qualquer, sem nenhum hardcode de Lei de Tortura", () => {
  const modelo = prepararAulaImpressao({
    conteudoNome: "Matéria Fictícia Qualquer",
    unidadeTitulo: "Unidade Genérica de Teste",
    aulaTitulo: "Aula Genérica",
    numeroVersao: 3,
    publicadoEm: null,
    estrutura: {
      componentes: [
        { tipo: "diagnostico", titulo: "T", introducao: "I", pergunta: "P?", resposta_esperada: "R" },
        { tipo: "conceito", titulo: "T2", explicacao: "E", exemplo: null, ponto_de_prova: null, pegadinha: null },
        { tipo: "recall", titulo: "T3", pergunta: "P2?", dica: null, resposta: "R2" },
        { tipo: "questao_resolvida", enunciado: "Enun", gabarito: "A", raciocinio: "Rac", pegadinha: null,
          alternativas: [{ letra: "A", texto: "x" }, { letra: "B", texto: "y" }, { letra: "C", texto: "z" }, { letra: "D", texto: "w" }] },
        { tipo: "resumo_visual", titulo: "Resumo", pontos: ["p1", "p2"] },
      ],
    },
    fontes: [],
  });
  assert.equal(modelo.componentes.length, 5);
  assert.equal(modelo.unidadeTitulo, "Unidade Genérica de Teste");
  assert.equal(modelo.numeroVersao, 3);
  assert.equal(modelo.publicadoEm, null);
});

test("tipo de componente desconhecido nunca desaparece — cai no bloco 'desconhecido' com os campos preservados", () => {
  const resultado = normalizarComponenteImpressao({ tipo: "video_aula", titulo: "Algo novo", url: "https://exemplo" });
  assert.equal(resultado.tipo, "desconhecido");
  assert.equal(resultado.tipoOriginal, "video_aula");
  assert.ok(resultado.campos.some((c) => c.chave === "titulo" && c.valor === "Algo novo"));
  assert.ok(resultado.campos.some((c) => c.chave === "url"));
});

test("aula sem fontes cadastradas devolve array de fontes vazio, não quebra", () => {
  const modelo = prepararAulaImpressao({
    unidadeTitulo: "U", aulaTitulo: "A", numeroVersao: 1, publicadoEm: null,
    estrutura: { componentes: [] }, fontes: null,
  });
  assert.deepEqual(modelo.fontes, []);
  assert.deepEqual(modelo.componentes, []);
});

test("B) a capa recebe dados dinâmicos (matéria/curso), nunca fixos no código", () => {
  const modelo = prepararFixtureLeiTortura();
  assert.equal(modelo.materiaNome, "Direitos Humanos e Cidadania");
  assert.equal(modelo.cursoNome, "Brigada Militar RS");
  assert.equal(modelo.conteudoNome, "Lei de Tortura");
  assert.equal(modelo.numeroVersao, 1);
});

test("B) materiaNome/cursoNome ausentes na entrada resolvem para null, nunca quebram nem inventam texto", () => {
  const modelo = prepararAulaImpressao({
    unidadeTitulo: "U", aulaTitulo: "A", numeroVersao: 1, publicadoEm: null,
    estrutura: { componentes: [] }, fontes: [],
  });
  assert.equal(modelo.materiaNome, null);
  assert.equal(modelo.cursoNome, null);
});

test("O) nenhuma transformação autoral: os textos chegam byte-a-byte idênticos ao dado de entrada", () => {
  const modelo = prepararFixtureLeiTortura();
  const conceitoNucleo = modelo.componentes.find(
    (c) => c.tipo === "conceito" && c.titulo === "O núcleo da Lei de Tortura",
  );
  assert.equal(conceitoNucleo.explicacao, "A Lei nº 9.455/1997 considera tortura...");
  const juris = modelo.componentes.find((c) => c.tipo === "jurisprudencia_essencial");
  // Byte-a-byte igual ao dado de entrada, inclusive as reticências de
  // truncamento do fixture — nada é resumido, completado ou "corrigido".
  assert.equal(
    juris.entendimento,
    "O STF entende que a imposição do regime inicial fechado...",
  );
});

test("normalizarAlternativas marca apenas a alternativa cujo letra bate com o gabarito (case-insensitive)", () => {
  const questao = normalizarComponenteImpressao({
    tipo: "questao_resolvida",
    enunciado: "x",
    gabarito: "c",
    alternativas: [
      { letra: "a", texto: "1" },
      { letra: "b", texto: "2" },
      { letra: "c", texto: "3" },
    ],
  });
  const corretas = questao.alternativas.filter((a) => a.correta);
  assert.equal(corretas.length, 1);
  assert.equal(corretas[0].letra, "C");
});
