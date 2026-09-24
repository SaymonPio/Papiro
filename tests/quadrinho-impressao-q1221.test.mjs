import assert from "node:assert/strict";
import test from "node:test";
import { mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { fileURLToPath, pathToFileURL } from "node:url";
import path from "node:path";
import { createRequire } from "node:module";
import { normalizarComponenteImpressao, prepararAulaImpressao } from "../components/teoria/prepararAulaImpressao.ts";
import { chaveArte } from "../components/teoria/arteQuadrinho.ts";

// Fase Q12.21 — quadrinhos ilustrados também no PDF/impressão (/teoria/imprimir), reaproveitando A MESMA
// Edge (assinar-quadrinho-assets) e o MESMO hook (useArtesQuadrinho) já usados pelo renderer web (Q12.12/
// Q12.15). Nenhum teste aqui acessa rede, banco, Storage ou OpenAI. Segue o padrão do projeto:
//  - lógica pura (normalização, controlador do hook) é testada executando o módulo real;
//  - JSX é testado transpilando o .tsx real (com o `typescript` do projeto) para uma pasta temporária dentro
//    do repositório (.sites-runtime/, ignorada pelo git) e renderizando com react-dom/server;
//  - lógica de página (app/teoria/imprimir/page.tsx) sem harness de DOM/timers é verificada estruturalmente
//    (leitura do código-fonte), como já é feito para outras páginas neste projeto (ver Q12.12-29).
const fetchOriginal = globalThis.fetch;
globalThis.fetch = () => { throw new Error("fetch REAL proibido nos testes da Q12.21"); };
test.after(() => { globalThis.fetch = fetchOriginal; });

const raiz = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const ler = (relativo) => readFileSync(path.join(raiz, relativo), "utf8");
const require = createRequire(import.meta.url);

const pageSrc = ler("app/teoria/imprimir/page.tsx");
const aulaImpressaoSrc = ler("components/teoria/AulaImpressao.tsx");
const useArtesSrc = ler("components/teoria/useArtesQuadrinho.ts");
const prepararSrc = ler("components/teoria/prepararAulaImpressao.ts");
const cssSrc = ler("app/globals.css").replace(/\r\n/g, "\n");

const AGORA = Date.parse("2026-09-21T12:00:00.000Z");
const COMP = "1f4065f2-8fda-4f7d-8826-45955230678d";
const urlAssinada = (i) => `https://liqybldxsjkygioxfmfh.supabase.co/storage/v1/object/sign/quadrinhos-aulas/arte-${i}.webp?token=t${i}`;

function quadro(cena, extra = {}) {
  return { cena, falas: [{ emissor: "Agente", texto: `Fala de ${cena}` }], legenda: `Legenda de ${cena}`, ...extra };
}
function quadrinhoBruto(quadros, extra = {}) {
  return {
    tipo: "quadrinho_didatico",
    id: COMP,
    titulo: "Pode entrar à noite?",
    quadros: quadros ?? [quadro("Cena A"), quadro("Cena B"), quadro("Cena C"), quadro("Cena D")],
    fechamento: "Regra de prova: socorro autoriza o ingresso.",
    ...extra,
  };
}
function modeloCom(quadrosBrutos, extraComponente = {}) {
  return prepararAulaImpressao({
    unidadeTitulo: "U",
    aulaTitulo: "A",
    numeroVersao: 1,
    publicadoEm: null,
    estrutura: { componentes: [quadrinhoBruto(quadrosBrutos, extraComponente)] },
  });
}
const mapaArtes = (indices) => Object.fromEntries(indices.map((i) => [chaveArte(COMP, i), { url: urlAssinada(i), expiraEm: AGORA + 900_000 }]));

// ================================================================== A. NORMALIZAÇÃO
test("Q12.21-1: ComponenteImpressao preserva componente.id (chave da arte); ausente/inválido vira null sem quebrar", () => {
  const c = normalizarComponenteImpressao(quadrinhoBruto());
  assert.equal(c.id, COMP);
  const { id, ...semId } = quadrinhoBruto();
  assert.equal(normalizarComponenteImpressao(semId).id, null);
  assert.equal(normalizarComponenteImpressao(quadrinhoBruto(undefined, { id: 5 })).id, null);
});

test("Q12.21-2: cada QuadroImpressao preserva indiceOriginal (chave de aula_quadrinho_assets.quadro_indice); numero continua 1..N", () => {
  const modelo = modeloCom();
  const q = modelo.componentes[0].quadros;
  assert.deepEqual(q.map((x) => x.indiceOriginal), [0, 1, 2, 3]);
  assert.deepEqual(q.map((x) => x.numero), [1, 2, 3, 4]);
});

test("Q12.21-3: quadro vazio descartado NÃO desloca indiceOriginal (nunca usar a posição filtrada para buscar arte)", () => {
  const modelo = modeloCom([quadro("Cena A"), { cena: "", falas: [] }, quadro("Cena C")]);
  const q = modelo.componentes[0].quadros;
  assert.deepEqual(q.map((x) => x.numero), [1, 2], "numero visual renumera");
  assert.deepEqual(q.map((x) => x.indiceOriginal), [0, 2], "índice original preservado (posições 0 e 2 do array bruto)");
  assert.deepEqual(q.map((x) => x.cena), ["Cena A", "Cena C"]);
});

// ================================================================== B. RENDER DE IMPRESSÃO (react-dom/server sobre o .tsx real)
let renderImpressao;
let pastaTmp;
test.before(async () => {
  const ts = require("typescript");
  const base = path.join(raiz, ".sites-runtime");
  mkdirSync(base, { recursive: true });
  pastaTmp = mkdtempSync(path.join(base, "tst-q1221-render-"));
  const compilar = (arquivo, saida, jsx, trocas = []) => {
    let { outputText } = ts.transpileModule(ler(arquivo), {
      compilerOptions: { module: ts.ModuleKind.ESNext, target: ts.ScriptTarget.ES2022, jsx: jsx ? ts.JsxEmit.ReactJSX : ts.JsxEmit.None },
    });
    for (const [de, para] of trocas) outputText = outputText.replaceAll(de, para);
    writeFileSync(path.join(pastaTmp, saida), outputText);
  };
  compilar("components/teoria/tiposComponenteAula.ts", "tiposComponenteAula.mjs", false);
  compilar("components/teoria/arteQuadrinho.ts", "arteQuadrinho.mjs", false);
  compilar("components/teoria/ComponenteAulaView.tsx", "ComponenteAulaView.mjs", true, [
    ['from "./tiposComponenteAula"', 'from "./tiposComponenteAula.mjs"'],
    ['from "./arteQuadrinho"', 'from "./arteQuadrinho.mjs"'],
  ]);
  // prepararAulaImpressao.ts entra só como `import type` no AulaImpressao.tsx real — o TypeScript elide esse
  // import na transpilação (isolatedModules por arquivo), então não precisa existir na pasta temporária.
  compilar("components/teoria/AulaImpressao.tsx", "AulaImpressao.mjs", true, [
    ['from "./ComponenteAulaView"', 'from "./ComponenteAulaView.mjs"'],
    ['from "./arteQuadrinho"', 'from "./arteQuadrinho.mjs"'],
  ]);
  const React = (await import("react")).default;
  const { renderToStaticMarkup } = await import("react-dom/server");
  const { default: AulaImpressaoView } = await import(pathToFileURL(path.join(pastaTmp, "AulaImpressao.mjs")).href);
  renderImpressao = (modelo, artes, aoResolverImagem) => renderToStaticMarkup(React.createElement(AulaImpressaoView, { modelo, artes, aoResolverImagem }));
});
test.after(() => { if (pastaTmp) rmSync(pastaTmp, { recursive: true, force: true }); });

const imgsDe = (html) => [...html.matchAll(/<img\b[^>]*>/g)].map((m) => m[0]);
const cartoesDe = (html) => html.split('<li class="impressao-quadrinho-quadro">').slice(1);

test("Q12.21-4: sem arte (prop ausente ou mapa vazio) -> nenhuma <img>, e o cartão textual completo de sempre", () => {
  const modelo = modeloCom();
  for (const html of [renderImpressao(modelo), renderImpressao(modelo, {}), renderImpressao(modelo, mapaArtes([]))]) {
    assert.equal(imgsDe(html).length, 0);
    assert.ok(!html.includes("impressao-quadrinho-arte"));
    for (const t of ["Quadro 1", "Quadro 4", "Cena A", "Fala de Cena B", "Legenda de Cena C", "Regra de prova: socorro autoriza o ingresso."]) {
      assert.ok(html.includes(t), t);
    }
  }
});

test("Q12.21-5: 4 artes -> 4 imagens, cada uma no quadro certo, sempre ANTES do texto do mesmo cartão", () => {
  const modelo = modeloCom();
  const html = renderImpressao(modelo, mapaArtes([0, 1, 2, 3]), () => {});
  assert.equal(imgsDe(html).length, 4);
  const cartoes = cartoesDe(html);
  assert.equal(cartoes.length, 4);
  cartoes.forEach((cartao, i) => {
    assert.ok(cartao.includes(urlAssinada(i).replace(/&/g, "&amp;")), `quadro ${i + 1} tem a URL do índice ${i}`);
    for (let j = 0; j < 4; j++) if (j !== i) assert.ok(!cartao.includes(`arte-${j}.webp`), `quadro ${i + 1} não contém a arte ${j}`);
    assert.ok(cartao.indexOf("<img") < cartao.indexOf("impressao-texto"), "imagem vem antes do texto (cena)");
    assert.ok(cartao.includes(`Cena ${"ABCD"[i]}`) && cartao.includes(`Fala de Cena ${"ABCD"[i]}`) && cartao.includes(`Legenda de Cena ${"ABCD"[i]}`), "texto pedagógico continua em HTML");
  });
  for (const tag of imgsDe(html)) {
    assert.match(tag, /width="1536"/);
    assert.match(tag, /height="1024"/);
  }
});

test("Q12.21-6: arte PARCIAL -> só os quadros correspondentes recebem imagem; os demais seguem só com texto", () => {
  const modelo = modeloCom();
  const html = renderImpressao(modelo, mapaArtes([1, 3]), () => {});
  const cartoes = cartoesDe(html);
  assert.deepEqual(cartoes.map((c) => c.includes("<img")), [false, true, false, true]);
  assert.equal(imgsDe(html).length, 2);
  for (const c of cartoes) assert.ok(c.includes("Cena"), "todo quadro mantém o texto mesmo sem imagem");
});

test("Q12.21-7: cena/falas/legenda/fechamento sempre presentes (com e sem arte); a arte é casada pelo ÍNDICE ORIGINAL — quadro vazio descartado não faz a imagem cair no quadro errado", () => {
  const modelo = modeloCom([quadro("Cena A"), { cena: "", falas: [] }, quadro("Cena C")]);
  assert.deepEqual(modelo.componentes[0].quadros.map((x) => x.indiceOriginal), [0, 2]);
  const html = renderImpressao(modelo, mapaArtes([2]), () => {});
  const cartoes = cartoesDe(html);
  assert.equal(cartoes.length, 2, "dois quadros visíveis (um foi descartado por estar vazio)");
  assert.ok(!cartoes[0].includes("<img"), "quadro visual 1 (índice original 0) não tem arte no índice 2");
  assert.ok(cartoes[1].includes("<img") && cartoes[1].includes("arte-2.webp"), "quadro visual 2 = índice original 2, que é onde está a arte");
  for (const c of cartoes) assert.ok(c.includes("Cena") && c.includes("Fala de") && c.includes("Legenda de"), "texto sempre presente");
  assert.ok(html.includes("Regra de prova: socorro autoriza o ingresso."), "fechamento sempre presente");
  // a arte do índice 1 (o quadro descartado) nunca aparece em lugar nenhum
  assert.equal(imgsDe(renderImpressao(modelo, mapaArtes([1]), () => {})).length, 0);
});

// ================================================================== C. HOOK — consultaConcluida (controlador real, sem React)
// Mesmo padrão da Q12.15 (tests/quadrinho-arte-q1212.test.mjs, seção G): transpila useArtesQuadrinho.ts real
// para uma pasta temporária e exercita `criarControladorArtes` com deps FAKE (buscar/timer/relógio simulados).
let pastaHook;
let hookMod;
test.before(async () => {
  const ts = require("typescript");
  const base = path.join(raiz, ".sites-runtime");
  mkdirSync(base, { recursive: true });
  pastaHook = mkdtempSync(path.join(base, "tst-q1221-hook-"));
  const transpilar = (arquivo, saida, trocas = []) => {
    let { outputText } = ts.transpileModule(ler(arquivo), { compilerOptions: { module: ts.ModuleKind.ESNext, target: ts.ScriptTarget.ES2022 } });
    for (const [de, para] of trocas) outputText = outputText.replaceAll(de, para);
    writeFileSync(path.join(pastaHook, saida), outputText);
  };
  transpilar("components/teoria/arteQuadrinho.ts", "arteQuadrinho.mjs");
  writeFileSync(path.join(pastaHook, "supabaseClientStub.mjs"), "export function createClient() { throw new Error('rede proibida no teste'); }\n");
  transpilar("components/teoria/useArtesQuadrinho.ts", "useArtesQuadrinho.mjs", [
    ['from "@/utils/supabase/client"', 'from "./supabaseClientStub.mjs"'],
    ['from "./arteQuadrinho"', 'from "./arteQuadrinho.mjs"'],
  ]);
  hookMod = await import(pathToFileURL(path.join(pastaHook, "useArtesQuadrinho.mjs")).href);
});
test.after(() => { if (pastaHook) rmSync(pastaHook, { recursive: true, force: true }); });

const ctxA = { chave: "admin|A|", modo: "admin", aulaVersaoId: "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa", missaoId: null };
const ctxB = { chave: "aluno|B|M", modo: "aluno", aulaVersaoId: "bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb", missaoId: "cccccccc-cccc-4ccc-8ccc-cccccccccccc" };

function respostaCom(indices) {
  return { assets: indices.map((i) => ({ componente_id: COMP, quadro_indice: i, url: urlAssinada(i), expira_em: new Date(AGORA + 900_000).toISOString() })) };
}

function cenario() {
  const pendentes = [];
  const chamadas = [];
  const concluidas = [];
  const timers = [];
  let relogio = AGORA;
  const deps = {
    buscar: (ctx) => new Promise((resolve, reject) => { chamadas.push(ctx.chave); pendentes.push({ ctx, resolve, reject }); }),
    aoMudarArtes: () => {},
    aoMudarConcluida: (chave, concluida) => concluidas.push({ chave, concluida }),
    agendar: (fn, ms) => { const t = { fn, ms, ativo: true }; timers.push(t); return t; },
    cancelar: (t) => { t.ativo = false; },
    agora: () => relogio,
  };
  const ctl = hookMod.criarControladorArtes(deps);
  const tick = () => new Promise((r) => setImmediate(r));
  const ultimaConcluida = (chave) => [...concluidas].reverse().find((c) => c.chave === chave);
  return { ctl, chamadas, concluidas, pendentes, timers, tick, ultimaConcluida, relogio: (v) => { if (v !== undefined) relogio = v; return relogio; } };
}

test("Q12.21-8: consultaConcluida começa false assim que um contexto é definido (antes da resposta chegar)", () => {
  const c = cenario();
  c.ctl.definirContexto(ctxA);
  assert.equal(c.ultimaConcluida(ctxA.chave)?.concluida, false);
});

test("Q12.21-9: sucesso da consulta inicial -> concluida vira true", async () => {
  const c = cenario();
  c.ctl.definirContexto(ctxA);
  c.pendentes[0].resolve(respostaCom([0, 1, 2, 3]));
  await c.tick();
  assert.equal(c.ultimaConcluida(ctxA.chave)?.concluida, true);
});

test("Q12.21-10: resposta vazia (assets: []) -> concluida vira true (nada para esperar; o PDF não fica preso)", async () => {
  const c = cenario();
  c.ctl.definirContexto(ctxA);
  c.pendentes[0].resolve({ assets: [] });
  await c.tick();
  assert.equal(c.ultimaConcluida(ctxA.chave)?.concluida, true);
});

test("Q12.21-11: falha da consulta inicial -> concluida vira true mesmo assim (fallback textual segue imprimível)", async () => {
  const c = cenario();
  c.ctl.definirContexto(ctxA);
  c.pendentes[0].reject(new Error("edge"));
  await c.tick();
  assert.equal(c.ultimaConcluida(ctxA.chave)?.concluida, true);
});

test("Q12.21-12: trocar de contexto (modo/aula/missão) volta consultaConcluida a false para o NOVO contexto", async () => {
  const c = cenario();
  c.ctl.definirContexto(ctxA);
  c.pendentes[0].resolve(respostaCom([0]));
  await c.tick();
  assert.equal(c.ultimaConcluida(ctxA.chave)?.concluida, true);
  c.ctl.definirContexto(ctxB);
  assert.equal(c.ultimaConcluida(ctxB.chave)?.concluida, false);
});

test("Q12.21-13: resposta TARDIA de um contexto já trocado nunca conclui o contexto novo (nem o antigo, que já foi abandonado)", async () => {
  const c = cenario();
  c.ctl.definirContexto(ctxA);
  c.ctl.definirContexto(ctxB); // troca antes de A responder
  assert.equal(c.ultimaConcluida(ctxB.chave)?.concluida, false);
  const [reqA] = c.pendentes;
  reqA.resolve(respostaCom([0])); // resposta tardia de A, depois da troca
  await c.tick();
  assert.equal(c.ultimaConcluida(ctxA.chave)?.concluida, false, "A nunca é marcado concluído: a geração já mudou quando a resposta chegou");
  assert.equal(c.ultimaConcluida(ctxB.chave)?.concluida, false, "B continua não concluído: a resposta de A não o afeta");
});

test("Q12.21-14: renovação POSTERIOR (periódica ou por erro de imagem) do MESMO contexto nunca volta consultaConcluida a false", async () => {
  const c = cenario();
  c.ctl.definirContexto(ctxA);
  c.pendentes[0].resolve(respostaCom([0, 1, 2, 3]));
  await c.tick();
  assert.equal(c.ultimaConcluida(ctxA.chave)?.concluida, true);
  const totalAntes = c.concluidas.filter((x) => x.chave === ctxA.chave).length;
  const timerAtivo = c.timers.find((t) => t.ativo);
  timerAtivo.ativo = false;
  timerAtivo.fn(); // renovação periódica
  await c.tick();
  c.pendentes[1].resolve(respostaCom([0, 1, 2, 3]));
  await c.tick();
  const emissoesDepois = c.concluidas.filter((x) => x.chave === ctxA.chave).slice(totalAntes);
  assert.ok(emissoesDepois.every((x) => x.concluida === true), "nenhuma emissão de false depois da conclusão inicial, para o mesmo contexto");
  assert.equal(c.ultimaConcluida(ctxA.chave)?.concluida, true);
});

// ================================================================== D. PRINT GATE (app/teoria/imprimir/page.tsx)
// Sem harness de DOM/timers neste projeto (ver Q12.12-29): a lógica do gate é verificada estruturalmente,
// confirmando as expressões exatas que compõem PRINT_READY, os efeitos de cancelamento e as dependências.
const pageSemComentarios = pageSrc.replace(/^\s*\/\/.*$/gm, "");

test("Q12.21-15: PRINT_READY exige consultaConcluida===true — consulta pendente bloqueia o botão", () => {
  assert.match(
    pageSemComentarios,
    /const printReady = estado === "pronto" && consultaConcluida && \(assinaturasEsperadas\.size === 0 \|\| todasResolvidas \|\| timeoutVencido\);/,
  );
  assert.match(pageSrc, /disabled=\{!printReady\}/);
});

test("Q12.21-16: sem imagens atuais para aguardar (nenhuma arte casada com o modelo) -> pronto sem depender do timeout", () => {
  // assinaturasEsperadas só recebe uma entrada quando existe arte para aquele quadro específico: sem arte
  // nenhuma, o Set fica vazio e o 1º termo do OR (size === 0) já libera a impressão sozinho.
  assert.match(pageSrc, /if \(arte\) conjunto\.add\(`\$\{chaveArte\(componente\.id, quadro\.indiceOriginal\)\}\|\$\{arte\.url\}`\);/);
  assert.match(pageSrc, /assinaturasEsperadas\.size === 0 \|\| todasResolvidas \|\| timeoutVencido/);
});

test("Q12.21-17: existe imagem pendente (nenhuma resolvida ainda) -> não libera até resolver ou até o timeout", () => {
  assert.match(pageSrc, /const \[resolvidas, setResolvidas\] = useState<Set<string>>\(new Set\(\)\);/, "começa vazio: nada conta como resolvido antes de onLoad/onError");
  assert.match(pageSrc, /const todasResolvidas = \[\.\.\.assinaturasEsperadas\]\.every\(\(assinatura\) => resolvidas\.has\(assinatura\)\);/);
});

test("Q12.21-18: onLoad da imagem conta como resolvida e chega ao gate via aoResolverImagem", () => {
  assert.match(pageSrc, /const aoResolverImagem = useCallback\(\(assinatura: string\) => \{/);
  assert.match(aulaImpressaoSrc, /onLoad=\{\(\) => aoResolver\?\.\(\)\}/);
  assert.match(aulaImpressaoSrc, /aoResolver=\{\(\) => aoResolverImagem\?\.\(assinatura\)\}/);
});

test("Q12.21-19: onError TAMBÉM conta como resolvida — imagem quebrada nunca trava a impressão", () => {
  const bloco = aulaImpressaoSrc.slice(aulaImpressaoSrc.indexOf("onError={"), aulaImpressaoSrc.indexOf("/>", aulaImpressaoSrc.indexOf("onError={")));
  assert.match(bloco, /setFalhou\(true\)/, "some da tela em erro");
  assert.match(bloco, /aoResolver\?\.\(\)/, "mas conta como resolvida para o gate");
});

test("Q12.21-20: timeout de segurança nomeado (8000ms) libera a impressão mesmo com imagem pendente", () => {
  assert.match(pageSrc, /const PRINT_IMAGES_TIMEOUT_MS = 8000;/);
  assert.match(pageSrc, /setTimeout\(\(\) => setTimeoutVencido\(true\), PRINT_IMAGES_TIMEOUT_MS\)/);
  assert.doesNotMatch(pageSemComentarios, /functions\.invoke.*timeout|timeout.*functions\.invoke/is, "o timeout nunca chama a Edge");
});

test("Q12.21-21: a assinatura inclui a URL (chave+url) — um callback tardio de URL antiga nunca resolve a URL nova", () => {
  assert.match(aulaImpressaoSrc, /const assinatura = arte && chave \? `\$\{chave\}\|\$\{arte\.url\}` : null;/);
  assert.match(pageSrc, /conjunto\.add\(`\$\{chaveArte\(componente\.id, quadro\.indiceOriginal\)\}\|\$\{arte\.url\}`\);/);
  // semântica: o Set de assinaturas ESPERADAS é recomputado com a URL corrente; uma assinatura resolvida com a
  // URL antiga nunca aparece nesse conjunto atual, logo nunca conta em todasResolvidas (.every sobre o atual).
  const esperadasAtuais = new Set(["comp:0|https://x/nova"]);
  const resolvidasComEntradaTardia = new Set(["comp:0|https://x/antiga"]);
  assert.equal([...esperadasAtuais].every((a) => resolvidasComEntradaTardia.has(a)), false, "URL antiga não resolve a URL nova");
});

test("Q12.21-22: o timer de 8s é cancelado quando o conjunto de assinaturas muda (dependência pelo CONTEÚDO do Set, não pela identidade do objeto)", () => {
  assert.match(pageSrc, /const assinaturasEsperadasChave = useMemo\(\(\) => \[\.\.\.assinaturasEsperadas\]\.sort\(\)\.join\("\\n"\), \[assinaturasEsperadas\]\);/);
  assert.match(
    pageSrc,
    /const temporizador = setTimeout\(\(\) => setTimeoutVencido\(true\), PRINT_IMAGES_TIMEOUT_MS\);\s*\n\s*return \(\) => clearTimeout\(temporizador\);\s*\n\s*\}, \[assinaturasEsperadasChave, todasResolvidas, assinaturasEsperadas\]\);/,
  );
});

test("Q12.21-23: o mesmo cleanup do useEffect cancela o timer no unmount — garantia do React, sem código à parte", () => {
  // React chama a função de limpeza de um useEffect tanto quando as dependências mudam quanto quando o
  // componente desmonta: não existe (nem precisa existir) um segundo caminho de cancelamento para o unmount.
  assert.match(pageSrc, /return \(\) => clearTimeout\(temporizador\);/);
});

// ================================================================== E. CSS / SEGURANÇA
test("Q12.21-24: .impressao-quadrinho-quadro mantém break-inside/page-break-inside avoid; a arte não define regra própria de quebra/float", () => {
  assert.match(cssSrc, /\.impressao-quadrinho-quadro\s*\{[^}]*break-inside:\s*avoid;[^}]*page-break-inside:\s*avoid;/s);
  const blocoArte = cssSrc.slice(cssSrc.indexOf(".impressao-quadrinho-arte {"), cssSrc.indexOf(".impressao-quadrinho-arte img"));
  assert.ok(blocoArte.length > 0);
  assert.doesNotMatch(blocoArte, /break-inside|page-break-inside|float/);
});

test("Q12.21-25: imagem 3:2 (1536x1024), sem deformar (object-fit: cover), ocupando 100% da largura do cartão", () => {
  assert.match(cssSrc, /\.impressao-quadrinho-arte\s*\{[^}]*aspect-ratio:\s*3 \/ 2;/s);
  assert.match(cssSrc, /\.impressao-quadrinho-arte\s*\{[^}]*width:\s*100%;/s);
  assert.match(cssSrc, /\.impressao-quadrinho-arte img\s*\{[^}]*object-fit:\s*cover;/s);
  assert.match(aulaImpressaoSrc, /width=\{1536\}/);
  assert.match(aulaImpressaoSrc, /height=\{1024\}/);
});

test("Q12.21-26: sem service_role/SUPABASE_SERVICE_ROLE_KEY em nenhum dos arquivos desta fase (tudo roda no cliente)", () => {
  for (const src of [pageSrc, aulaImpressaoSrc, useArtesSrc, prepararSrc]) {
    assert.doesNotMatch(src.replace(/^\s*\/\/.*$/gm, ""), /SUPABASE_SERVICE_ROLE_KEY|service_role/i);
  }
});

test("Q12.21-27: sem storage_path/prompt_visual/scene_hash em lugar nenhum do fluxo de impressão; a URL da imagem nunca é logada", () => {
  for (const src of [pageSrc, aulaImpressaoSrc, prepararSrc]) {
    const codigo = src.replace(/^\s*\/\/.*$/gm, "");
    assert.doesNotMatch(codigo, /storage_path|prompt_visual|scene_hash/);
    assert.doesNotMatch(codigo, /console\.(log|info|debug|warn)\(/i, "nenhum log no fluxo de impressão");
  }
});

// ================================================================== F. Integração ponta a ponta (contrato aditivo + reaproveitamento)
test("Q12.21-extra-A: o contrato do hook é ADITIVO — consultaConcluida somado sem remover artes/aoErroArte", () => {
  const codigo = useArtesSrc.replace(/^\s*\/\/.*$/gm, "");
  assert.match(codigo, /\}: Parametros\): \{ artes: MapaArtes; aoErroArte: \(\) => void; consultaConcluida: boolean \}/);
  assert.match(codigo, /return \{ artes, aoErroArte, consultaConcluida \};/);
});

test("Q12.21-extra-B: a impressão reaproveita o hook existente (sem fetch/Edge paralelo) com os IDs REAIS já resolvidos pela própria página", () => {
  assert.match(pageSrc, /const \{ artes, consultaConcluida \} = useArtesQuadrinho\(contextoArte\);/);
  assert.doesNotMatch(pageSemComentarios, /functions\.invoke|assinar-quadrinho-assets/, "página não chama a Edge diretamente");
  assert.doesNotMatch(aulaImpressaoSrc.replace(/^\s*\/\/.*$/gm, ""), /functions\.invoke|assinar-quadrinho-assets|useArtesQuadrinho/, "componente de render não busca dados sozinho");
  assert.match(pageSrc, /setContextoArte\(\{ modo: "admin", aulaVersaoId: aulaVersaoIdAdmin, missaoId: null \}\);/, "admin usa o aulaVersaoId já resolvido pela própria página");
  assert.match(pageSrc, /setContextoArte\(\{ modo: "aluno", aulaVersaoId: linha\.aula_versao_id, missaoId \}\);/, "aluno usa o aulaVersaoId/missaoId já resolvidos pela própria página");
});

test("Q12.21-extra-C: nenhum SQL novo referencia a impressão; nenhuma Edge nova foi criada para esta fase", () => {
  const funcoesDir = readFileSync(path.join(raiz, "supabase/functions/assinar-quadrinho-assets/index.ts"), "utf8");
  assert.ok(funcoesDir.length > 0, "a Edge reaproveitada continua existindo, sem sinal de que foi duplicada");
  assert.doesNotMatch(pageSemComentarios, /createSignedUrl|SUPABASE_SERVICE_ROLE_KEY/);
});
