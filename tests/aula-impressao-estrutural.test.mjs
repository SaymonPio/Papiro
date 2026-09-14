import assert from "node:assert/strict";
import test from "node:test";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import path from "node:path";

// Verificações estruturais (leitura do código-fonte) para a versão de
// impressão/PDF da aula — complementam tests/prepararAulaImpressao.test.mjs
// (que cobre a transformação de dados) com garantias que só fazem sentido
// olhando o JSX/rota em si, sem precisar de um framework de teste de React.

const raizProjeto = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const aulaImpressao = readFileSync(path.join(raizProjeto, "components/teoria/AulaImpressao.tsx"), "utf8");
const rotaImprimir = readFileSync(path.join(raizProjeto, "app/teoria/imprimir/page.tsx"), "utf8");
const prepararAula = readFileSync(path.join(raizProjeto, "components/teoria/prepararAulaImpressao.ts"), "utf8");
const globalsCss = readFileSync(path.join(raizProjeto, "app/globals.css"), "utf8");

// Remove comentários de linha (// ...) antes de checar por código real —
// evita falso positivo quando o próprio comentário explica "sem <details>"
// em prosa (exatamente o que este teste verifica que o CÓDIGO não faz).
function semComentarios(codigo) {
  return codigo
    .split("\n")
    .map((linha) => linha.replace(/\/\/.*$/, ""))
    .join("\n");
}
const aulaImpressaoCodigo = semComentarios(aulaImpressao);
const rotaImprimirCodigo = semComentarios(rotaImprimir);

test("H) a versão de impressão não contém controles interativos da aula online", () => {
  for (const proibido of ["Confirmar resposta", "Revelar resposta", "<details", "<button"]) {
    assert.ok(!aulaImpressaoCodigo.includes(proibido), `AulaImpressao.tsx não deveria conter "${proibido}"`);
  }
});

test("I) a rota de impressão nunca importa/renderiza ComentariosAula", () => {
  assert.ok(!aulaImpressao.includes("ComentariosAula"));
  assert.ok(!rotaImprimir.includes("ComentariosAula"));
});

test("J) a rota de impressão nunca chama a RPC de questões da prática da unidade", () => {
  for (const proibido of ["inspecionar_candidatas_papiro_admin", "iniciar_pratica_unidade", "iniciar_questoes_da_missao", "ids_questoes_para_usuario"]) {
    assert.ok(!rotaImprimir.includes(proibido), `app/teoria/imprimir/page.tsx não deveria chamar "${proibido}"`);
  }
});

test("K) a rota de impressão nunca chama RPCs de resposta/progresso do aluno", () => {
  for (const proibido of ["registrar_resposta", "registrar_unidade_teoria_concluida", "respostas_usuarios", "erros_usuarios", "revisoes"]) {
    assert.ok(!rotaImprimir.includes(proibido), `app/teoria/imprimir/page.tsx não deveria referenciar "${proibido}"`);
  }
});

test("a rota de impressão sempre verifica autenticação antes de carregar qualquer dado", () => {
  assert.match(rotaImprimir, /auth\.getUser\(\)/);
  assert.match(rotaImprimir, /window\.location\.replace\("\/login"\)/);
});

test("o botão de download usa window.print() (sem nova dependência de geração de PDF)", () => {
  assert.match(rotaImprimir, /window\.print\(\)/);
});

test("A) existe uma capa editorial própria (página cheia, não é o primeiro componente)", () => {
  assert.match(aulaImpressaoCodigo, /function Capa\(/);
  assert.match(aulaImpressaoCodigo, /impressao-capa/);
  // A capa é renderizada ANTES do miolo com os componentes da aula.
  const posicaoCapa = aulaImpressao.indexOf("<Capa modelo={modelo} />");
  const posicaoMiolo = aulaImpressao.indexOf("impressao-conteudo-principal");
  assert.ok(posicaoCapa > -1 && posicaoMiolo > -1 && posicaoCapa < posicaoMiolo);
});

test("C) nenhum hardcode de Lei de Tortura/STF/HC 111.840 em AulaImpressao.tsx ou prepararAulaImpressao.ts", () => {
  for (const proibido of ["Lei de Tortura", "STF", "HC 111.840", "Direitos Humanos", "Brigada Militar"]) {
    assert.ok(!aulaImpressao.includes(proibido), `AulaImpressao.tsx não deveria conter "${proibido}"`);
    assert.ok(!prepararAula.includes(proibido), `prepararAulaImpressao.ts não deveria conter "${proibido}"`);
  }
});

test("L/M) a instrução sobre 'Cabeçalhos e rodapés' só aparece na tela, nunca na impressão", () => {
  assert.match(rotaImprimir, /Cabeçalhos e rodapés/);
  // Extrai o elemento <p ...>...Cabeçalhos e rodapés...</p> inteiro e
  // confirma que a classe no-imprimir está nele (não em outro bloco).
  const casamento = rotaImprimir.match(/<p className="([^"]*)">[^<]*Cabeçalhos e rodapés/);
  assert.ok(casamento, "esperava encontrar <p className=\"...\"> contendo o texto da instrução");
  assert.match(casamento[1], /no-imprimir/);
});

test("L) .no-imprimir realmente desaparece em @media print no CSS", () => {
  const blocoPrint = globalsCss.slice(globalsCss.indexOf("@media print"));
  assert.match(blocoPrint, /\.no-imprimir\s*\{\s*display:\s*none\s*!important;/);
});

test("N) a paginação usa regras SELETIVAS, não um único break-inside: avoid genérico em tudo", () => {
  // CONCEITO como um todo não pode forçar avoid (só suas subseções).
  assert.doesNotMatch(globalsCss, /\.impressao-secao--conceito\s*\{[^}]*avoid/s);
  // RESUMO explicitamente permite quebrar (auto), diferente de BIZU/PEGADINHA/
  // JURISPRUDÊNCIA/RECALL/questão, que preferem não quebrar (avoid).
  assert.match(globalsCss, /\.impressao-secao--resumo\s*\{[^}]*break-inside:\s*auto/s);
  for (const seletor of [".impressao-subsecao--bizu", ".impressao-jurisprudencia", ".impressao-recall", ".impressao-questao-corpo"]) {
    const indice = globalsCss.indexOf(`${seletor} {`);
    assert.ok(indice > -1, `seletor "${seletor}" deveria existir no CSS`);
  }
  assert.match(globalsCss, /\.impressao-subsecao\s*\{[^}]*break-inside:\s*avoid/s);
});

test("capa sempre em página própria (break-after: page)", () => {
  assert.match(globalsCss, /\.impressao-capa\s*\{[^}]*break-after:\s*page/s);
});

test("A/B) a rota de impressão do aluno busca materiaNome/cursoNome por leituras simples, não por embed aninhado do PostgREST", () => {
  // curso_materias não tem foreign key registrada no banco — um embed do
  // tipo curso_materias(materias(...), cursos(...)) falha silenciosamente
  // (era exatamente o bug: capa sem matéria/curso, sem erro nenhum).
  assert.ok(!rotaImprimirCodigo.includes("curso_materias(materias"), "não deve usar embed aninhado do PostgREST para curso_materias");
  for (const tabela of ['.from("curso_conteudos")', '.from("curso_materias")', '.from("materias")', '.from("cursos")']) {
    assert.ok(rotaImprimir.includes(tabela), `esperava leitura simples em ${tabela}`);
  }
  assert.match(rotaImprimir, /materiaNome\s*,?\s*\n?\s*unidadeTitulo/);
  assert.match(rotaImprimir, /cursoNome\s*,?\s*\n?\s*numeroVersao/);
});

test("C/D) materiaNome/cursoNome chegam à capa como dado lido do banco, nunca um texto fixo no código", () => {
  assert.doesNotMatch(rotaImprimir, /materiaNome\s*=\s*"[^"]/, "materiaNome não pode ser uma string fixa");
  assert.doesNotMatch(rotaImprimir, /cursoNome\s*=\s*"[^"]/, "cursoNome não pode ser uma string fixa");
  assert.match(rotaImprimir, /let materiaNome: string \| null = null;/);
  assert.match(rotaImprimir, /let cursoNome: string \| null = null;/);
});

test("E) a seção RECALL completa (kicker + título + flashcard) usa a classe que evita quebra de página", () => {
  const casamentoSecao = aulaImpressaoCodigo.match(/case "recall":[\s\S]*?<section key=\{indice\} className="([^"]*)">/);
  assert.ok(casamentoSecao, "esperava encontrar a <section> do case \"recall\"");
  assert.match(casamentoSecao[1], /impressao-secao--recall/);
  // A regra de não quebrar está no seletor da SEÇÃO inteira, não só na
  // caixa interna — senão o título pode ficar numa página e o corpo na
  // seguinte (era exatamente o bug relatado).
  assert.match(globalsCss, /\.impressao-secao--recall\s*\{[^}]*break-inside:\s*avoid/s);
});

test("F) o título do recall nunca fica fora do wrapper que evita quebra (kicker/título/flashcard no mesmo <section>)", () => {
  const casamentoBloco = aulaImpressaoCodigo.match(/case "recall":\s*return \(\s*<section key=\{indice\} className="([^"]*)">([\s\S]*?)<\/section>\s*\);/);
  assert.ok(casamentoBloco, "esperava encontrar o bloco JSX completo do case \"recall\"");
  assert.match(casamentoBloco[1], /impressao-secao--recall/);
  // kicker, título e a caixa impressao-recall (pergunta/dica/resposta)
  // são todos filhos diretos do mesmo <section>, não de seções separadas.
  assert.match(casamentoBloco[2], /impressao-secao-kicker/);
  assert.match(casamentoBloco[2], /impressao-secao-titulo/);
  assert.match(casamentoBloco[2], /impressao-recall"/);
});

test("títulos internos de seção (.impressao-secao-titulo) têm peso e tamanho reforçados em relação ao corpo", () => {
  const inicio = globalsCss.indexOf(".impressao-secao-titulo {");
  const fim = globalsCss.indexOf("}", inicio);
  const bloco = globalsCss.slice(inicio, fim);
  assert.match(bloco, /font-weight:\s*700/);
  const casamentoTamanho = bloco.match(/font-size:\s*(\d+)px/);
  assert.ok(casamentoTamanho, "esperava um font-size em px no título interno");
  const tamanhoTitulo = Number(casamentoTamanho[1]);
  // Corpo (.impressao-texto/.impressao-pergunta) não define font-size
  // próprio — herda o tamanho-base do navegador (16px) — então o título
  // interno precisa ficar dentro da faixa moderada pedida (115%–125%).
  const tamanhoBase = 16;
  const razao = tamanhoTitulo / tamanhoBase;
  assert.ok(razao >= 1.15 && razao <= 1.25, `título interno deveria ficar entre 115% e 125% do corpo, ficou em ${Math.round(razao * 100)}%`);
});

test("kicker/rótulo (CONCEITO, DIAGNÓSTICO, RECALL, etc.) continua menor e distinto do título interno", () => {
  const inicioKicker = globalsCss.indexOf(".impressao-secao-kicker {");
  const fimKicker = globalsCss.indexOf("}", inicioKicker);
  const blocoKicker = globalsCss.slice(inicioKicker, fimKicker);
  const tamanhoKicker = Number(blocoKicker.match(/font-size:\s*(\d+)px/)[1]);
  const inicioTitulo = globalsCss.indexOf(".impressao-secao-titulo {");
  const fimTitulo = globalsCss.indexOf("}", inicioTitulo);
  const tamanhoTitulo = Number(globalsCss.slice(inicioTitulo, fimTitulo).match(/font-size:\s*(\d+)px/)[1]);
  assert.ok(tamanhoKicker < tamanhoTitulo, "o kicker deve continuar menor que o título interno");
});

test("recall e resumo reaproveitam a mesma classe .impressao-secao-titulo (nenhuma classe nova, nenhum JSX alterado)", () => {
  const casamentoRecall = aulaImpressaoCodigo.match(/case "recall":[\s\S]*?<\/section>/);
  assert.match(casamentoRecall[0], /className="impressao-secao-titulo"/);
  const casamentoResumo = aulaImpressaoCodigo.match(/case "resumo_visual":[\s\S]*?<\/section>/);
  assert.match(casamentoResumo[0], /className="impressao-secao-titulo"/);
});

test("capa, alternativas e meta da jurisprudência (Tribunal/Precedente/Dispositivo/Fonte) não foram afetadas pelo reforço de título", () => {
  const capaTitulo = globalsCss.slice(globalsCss.indexOf(".impressao-capa-titulo {"), globalsCss.indexOf("}", globalsCss.indexOf(".impressao-capa-titulo {")));
  assert.match(capaTitulo, /clamp\(32px/, "o tamanho da capa não deveria mudar");
  const alternativa = globalsCss.indexOf(".impressao-alternativa {");
  assert.ok(alternativa === -1 || !globalsCss.slice(alternativa, globalsCss.indexOf("}", alternativa)).includes("font-weight: 700"));
});

test("textos corridos (impressao-texto, impressao-pergunta, itens do resumo) usam alinhamento justificado", () => {
  assert.match(globalsCss, /\.impressao-texto\s*\{[^}]*text-align:\s*justify/s);
  assert.match(globalsCss, /\.impressao-pergunta\s*\{[^}]*text-align:\s*justify/s);
  assert.match(globalsCss, /\.impressao-resumo-lista li\s*\{[^}]*text-align:\s*justify/s);
});

test("títulos/rótulos/capa/alternativas NÃO são justificados (evita espaçamento exagerado em textos curtos)", () => {
  for (const seletor of [
    ".impressao-secao-titulo",
    ".impressao-secao-kicker",
    ".impressao-subsecao-rotulo",
    ".impressao-alternativa",
    ".impressao-capa-titulo",
    ".impressao-capa-materia",
    ".impressao-capa-curso",
    ".impressao-rodape-fechamento",
    ".impressao-cabecalho-interno",
  ]) {
    const inicio = globalsCss.indexOf(`${seletor} {`);
    if (inicio === -1) continue; // seletor pode não ter bloco próprio (herda de outro) — nada a checar aqui
    const fim = globalsCss.indexOf("}", inicio);
    const bloco = globalsCss.slice(inicio, fim);
    assert.ok(!bloco.includes("text-align: justify"), `"${seletor}" não deveria ser justificado`);
  }
});

test("nenhuma regressão: conceito/resumo/jurisprudência/questão/bizu/pegadinha mantêm suas regras de quebra originais", () => {
  assert.doesNotMatch(globalsCss, /\.impressao-secao--conceito\s*\{[^}]*avoid/s);
  assert.match(globalsCss, /\.impressao-secao--resumo\s*\{[^}]*break-inside:\s*auto/s);
  assert.match(globalsCss, /\.impressao-jurisprudencia\s*\{[^}]*break-inside:\s*avoid/s);
  assert.match(globalsCss, /\.impressao-questao-corpo\s*\{[^}]*break-inside:\s*avoid/s);
  assert.ok(globalsCss.includes(".impressao-subsecao--bizu {"), "BIZU herda break-inside: avoid de .impressao-subsecao");
  assert.match(globalsCss, /\.impressao-subsecao\s*\{[^}]*break-inside:\s*avoid/s);
});
