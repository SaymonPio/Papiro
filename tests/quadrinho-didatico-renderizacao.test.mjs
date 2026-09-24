import assert from "node:assert/strict";
import test from "node:test";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import path from "node:path";
import { ROTULOS_TIPO_COMPONENTE, normalizarQuadrinho } from "../components/teoria/tiposComponenteAula.ts";
import { prepararAulaImpressao, normalizarComponenteImpressao } from "../components/teoria/prepararAulaImpressao.ts";

// Fase Q3 — renderização do componente quadrinho_didatico (v1, SEM imagem)
// no aluno, no preview admin e no PDF. Segue o padrão do projeto: a parte de
// dados é testada executando os módulos .ts puros; a parte de JSX/CSS é
// verificada estruturalmente (leitura do código-fonte), porque este projeto
// não tem harness de DOM/React e nenhum foi adicionado.

const raiz = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const ler = (relativo) => readFileSync(path.join(raiz, relativo), "utf8");
const view = ler("components/teoria/ComponenteAulaView.tsx");
const impressao = ler("components/teoria/AulaImpressao.tsx");
const css = ler("app/globals.css");

function trecho(codigo, inicio, fim) {
  const i = codigo.indexOf(inicio);
  assert.ok(i > -1, `trecho inicial não encontrado: ${inicio}`);
  const f = codigo.indexOf(fim, i);
  assert.ok(f > i, `trecho final não encontrado: ${fim}`);
  return codigo.slice(i, f);
}

const viewQuadrinho = trecho(view, "function QuadrinhoDidaticoView", "// Fallback genérico");
const impressaoQuadrinho = trecho(impressao, 'case "quadrinho_didatico":', "// Nenhum tipo desaparece");
// Q12.24: o <li> de cada quadro (cena/falas/legenda) foi extraído para renderizarQuadroImpressao — reaproveitado
// pelas duas grades em que o case "quadrinho_didatico" agora divide os quadros (cabeçalho+1ª linha / restante,
// ver AulaImpressao.tsx) — por isso os testes que checam o conteúdo de UM quadro olham este trecho, não mais
// dentro de impressaoQuadrinho (que continua sendo só o wrapper/seção em si).
const impressaoQuadroItem = trecho(impressao, "function renderizarQuadroImpressao", "\nfunction renderizarComponente");

function quadro(extra = {}) {
  return { cena: "Um policial conversa com um morador.", falas: [{ emissor: "Policial", texto: "Ouvi gritos de socorro." }], legenda: "Socorro autoriza o ingresso.", ...extra };
}

function quadrinho(extra = {}) {
  return {
    tipo: "quadrinho_didatico",
    titulo: "Entrar ou não entrar?",
    quadros: [
      quadro({ cena: "Cena um." }),
      quadro({ cena: "Cena dois.", falas: [{ emissor: "Morador", texto: "Quem é?" }, { emissor: "Policial", texto: "Polícia." }] }),
      quadro({ cena: "Cena três.", falas: [], legenda: undefined }),
    ],
    fechamento: "Flagrante, desastre e socorro: a qualquer hora.",
    ...extra,
  };
}

// ---------- rótulo e registro ----------

test("Q3-1: label de quadrinho_didatico existe (Exemplo visual)", () => {
  assert.equal(ROTULOS_TIPO_COMPONENTE.quadrinho_didatico, "Exemplo visual");
});

test("Q3-2: VIEWS_POR_TIPO conhece quadrinho_didatico", () => {
  const mapa = trecho(view, "const VIEWS_POR_TIPO", "export default function ComponenteAulaView");
  assert.match(mapa, /quadrinho_didatico:\s*QuadrinhoDidaticoView/);
});

test("Q3-3: QuadrinhoDidaticoView existe e usa o kicker EXEMPLO VISUAL", () => {
  assert.match(view, /function QuadrinhoDidaticoView\(\{ c, artes, aoErroArte \}: \{ c: ComponenteAula; artes\?: MapaArtes; aoErroArte\?: \(\) => void \}\)/);
  assert.match(viewQuadrinho, /EXEMPLO VISUAL/);
});

// ---------- dados normalizados que alimentam o renderer da tela ----------

test("Q3-4: título é preservado e renderizado", () => {
  assert.equal(normalizarQuadrinho(quadrinho()).titulo, "Entrar ou não entrar?");
  assert.match(viewQuadrinho, /quadrinho\.titulo && <h3>/);
});

test("Q3-5/6: 3 quadros saem em ordem, cada um com sua cena", () => {
  const n = normalizarQuadrinho(quadrinho());
  assert.deepEqual(n.quadros.map((q) => q.numero), [1, 2, 3]);
  assert.deepEqual(n.quadros.map((q) => q.cena), ["Cena um.", "Cena dois.", "Cena três."]);
  assert.match(viewQuadrinho, /quadrinho\.quadros\.map/);
  assert.match(viewQuadrinho, /Quadro \{quadro\.numero\}/);
});

test("Q3-7/8/9: fala mostra emissor e texto; várias falas mantêm a ordem", () => {
  const n = normalizarQuadrinho(quadrinho());
  assert.deepEqual(n.quadros[1].falas, [{ emissor: "Morador", texto: "Quem é?" }, { emissor: "Policial", texto: "Polícia." }]);
  assert.match(viewQuadrinho, /<dt className="teoria-quadrinho-emissor">\{fala\.emissor\}<\/dt>/);
  assert.match(viewQuadrinho, /<dd className="teoria-quadrinho-fala-texto">/);
});

test("Q3-10: falas=[] não gera container de falas nem texto de 'sem falas'", () => {
  const n = normalizarQuadrinho(quadrinho());
  assert.deepEqual(n.quadros[2].falas, []);
  assert.match(viewQuadrinho, /quadro\.falas\.length > 0 && \(/);
  assert.doesNotMatch(viewQuadrinho, /sem falas/i);
});

test("Q3-11/12: legenda presente aparece; ausente/undefined vira null sem quebrar", () => {
  const n = normalizarQuadrinho(quadrinho());
  assert.equal(n.quadros[0].legenda, "Socorro autoriza o ingresso.");
  assert.equal(n.quadros[2].legenda, null);
  assert.match(viewQuadrinho, /quadro\.legenda && <p className="teoria-quadrinho-legenda">/);
});

test("Q3-13: fechamento aparece, com o destaque de bizu/regra de prova já existente", () => {
  assert.equal(normalizarQuadrinho(quadrinho()).fechamento, "Flagrante, desastre e socorro: a qualquer hora.");
  assert.match(viewQuadrinho, /className="teoria-bizu teoria-quadrinho-fechamento"/);
  assert.match(viewQuadrinho, /REGRA DE PROVA/);
});

test("Q3-14: dados estranhos/históricos nunca quebram a normalização", () => {
  for (const c of [
    { tipo: "quadrinho_didatico" },
    { tipo: "quadrinho_didatico", quadros: "x" },
    { tipo: "quadrinho_didatico", quadros: [null, 3, "a", [], {}, { cena: "  " }, { cena: "ok", falas: "x" }, { cena: "ok", falas: [null, { emissor: "A" }, { texto: "b" }, { emissor: "A", texto: "b" }] }] },
  ]) {
    const n = normalizarQuadrinho(c);
    assert.ok(Array.isArray(n.quadros));
  }
  const estranho = normalizarQuadrinho({ tipo: "quadrinho_didatico", quadros: [null, { cena: "ok", falas: [null, { emissor: "A" }, { emissor: "A", texto: "b" }] }] });
  assert.equal(estranho.quadros.length, 1);
  assert.equal(estranho.quadros[0].numero, 1);
  assert.deepEqual(estranho.quadros[0].falas, [{ emissor: "A", texto: "b" }]);
});

test("Q3-14b: aulas antigas seguem idênticas — os 6 tipos anteriores continuam no mapa e o genérico continua existindo", () => {
  const mapa = trecho(view, "const VIEWS_POR_TIPO", "export default function ComponenteAulaView");
  for (const tipo of ["diagnostico", "conceito", "jurisprudencia_essencial", "recall", "questao_resolvida", "resumo_visual"]) {
    assert.match(mapa, new RegExp(`${tipo}:\\s*\\w+View`));
  }
  assert.match(view, /Vista \? <Vista c=\{componente\} artes=\{artes\} aoErroArte=\{aoErroArte\} \/> : <ComponenteGenericoView componente=\{componente\} \/>/);
});

test("Q3-14c: aluno e preview admin usam o MESMO ComponenteAulaView (implementação única)", () => {
  for (const arquivo of ["app/teoria/page.tsx", "app/admin/aulas/page.tsx", "app/admin/aulas/preview/page.tsx"]) {
    assert.match(ler(arquivo), /<ComponenteAulaView\b/, arquivo);
  }
  assert.ok(!/QuadrinhoDidaticoView/.test(ler("app/admin/aulas/page.tsx")), "não deve existir renderer admin separado");
});

test("Q3-14d: a ordem dos componentes não é reorganizada (map direto sobre estrutura.componentes)", () => {
  assert.match(ler("app/teoria/page.tsx"), /componentes\.map\(\(componente, indice\) => \(\s*<ComponenteAulaView/);
});

// ---------- impressão / PDF ----------

test("Q3-15: a impressão reconhece quadrinho_didatico (não cai em 'desconhecido')", () => {
  const c = normalizarComponenteImpressao(quadrinho());
  assert.equal(c.tipo, "quadrinho_didatico");
  assert.match(impressaoQuadrinho, /Exemplo visual/);
});

test("Q3-16/17/18/19: o modelo de PDF preserva quadros em ordem, falas, legenda e fechamento", () => {
  const modelo = prepararAulaImpressao({
    unidadeTitulo: "U",
    aulaTitulo: "A",
    numeroVersao: 1,
    publicadoEm: null,
    estrutura: { componentes: [{ tipo: "conceito", titulo: "c", explicacao: "e" }, quadrinho(), { tipo: "recall", titulo: "r", pergunta: "p", resposta: "a" }] },
  });
  assert.deepEqual(modelo.componentes.map((c) => c.tipo), ["conceito", "quadrinho_didatico", "recall"]);
  const q = modelo.componentes[1];
  assert.equal(q.titulo, "Entrar ou não entrar?");
  assert.deepEqual(q.quadros.map((x) => x.cena), ["Cena um.", "Cena dois.", "Cena três."]);
  assert.deepEqual(q.quadros[1].falas.map((f) => `${f.emissor}: ${f.texto}`), ["Morador: Quem é?", "Policial: Polícia."]);
  assert.equal(q.quadros[0].legenda, "Socorro autoriza o ingresso.");
  assert.equal(q.quadros[2].legenda, null);
  assert.equal(q.fechamento, "Flagrante, desastre e socorro: a qualquer hora.");
  assert.match(impressaoQuadrinho, /Regra de prova/);
  assert.match(impressaoQuadroItem, /quadro\.legenda &&/);
  assert.match(impressaoQuadroItem, /<dt className="impressao-quadrinho-emissor">/);
});

test("Q3-16b: aula sem quadrinho gera o mesmo modelo de PDF de antes (nenhum componente extra)", () => {
  const modelo = prepararAulaImpressao({
    unidadeTitulo: "U",
    aulaTitulo: "A",
    numeroVersao: 1,
    publicadoEm: null,
    estrutura: { componentes: [{ tipo: "diagnostico", titulo: "d" }, { tipo: "resumo_visual", titulo: "r", pontos: ["a"] }] },
  });
  assert.deepEqual(modelo.componentes.map((c) => c.tipo), ["diagnostico", "resumo_visual"]);
});

// ---------- CSS e escopo ----------

test("Q3-20: o CSS necessário existe (tela e impressão)", () => {
  for (const classe of [
    "teoria-quadrinho-quadros", "teoria-quadrinho-quadro", "teoria-quadrinho-numero", "teoria-quadrinho-cena",
    "teoria-quadrinho-falas", "teoria-quadrinho-emissor", "teoria-quadrinho-fala-texto", "teoria-quadrinho-legenda",
    "teoria-quadrinho-fechamento", "impressao-quadrinho-quadros", "impressao-quadrinho-quadro",
    "impressao-quadrinho-emissor", "impressao-quadrinho-legenda",
  ]) {
    assert.match(css, new RegExp(`\\.${classe}\\b`), classe);
  }
});

test("Q3-20b: responsivo sem carrossel/JS e sem estouro (grade fluida com min(100%, …))", () => {
  assert.match(css, /\.teoria-quadrinho-quadros\s*\{[^}]*grid-template-columns:\s*repeat\(auto-fit,\s*minmax\(min\(100%,\s*250px\),\s*1fr\)\)/);
  assert.doesNotMatch(viewQuadrinho, /useState|useEffect|onClick/);
  assert.match(css, /\.impressao-quadrinho-quadro\s*\{[^}]*break-inside:\s*avoid/);
});

test("Q3-21: o PDF agora também pode ter imagem (Q12.21 — reaproveita a mesma arte aprovada), mas nem o PDF nem a tela chamam Supabase/Storage diretamente ou usam next/image", () => {
  // Até a Q12.20 o PDF era puramente textual. A partir da Q12.21 ele renderiza a MESMA arte aprovada, quando
  // existir, via app/teoria/imprimir/page.tsx + useArtesQuadrinho (cobertura completa em
  // tests/quadrinho-impressao-q1221.test.mjs). O que continua valendo aqui, em ambos os renderers: nenhum
  // acesso direto a Supabase/Storage, sem next/image, sem HTML injetado.
  const cssQuadrinho = css.replace(/\/\*[\s\S]*?\*\//g, "").match(/[^{}]*quadrinho[^{}]*\{[^}]*\}/g)?.join("\n");
  assert.ok(cssQuadrinho && cssQuadrinho.length > 0);
  for (const proibido of [/<Image\b/, /supabase/i, /storage/i, /dangerouslySetInnerHTML/]) {
    assert.doesNotMatch(impressaoQuadrinho.replace(/^\s*\/\/.*$/gm, ""), proibido, `pdf: ${proibido}`); // só código (comentários podem citar Q12.21/chave/assinatura)
  }
  for (const proibido of [/supabase/i, /storage/i]) assert.doesNotMatch(cssQuadrinho, proibido, `css: ${proibido}`);
  // Renderer da tela: sem cliente Supabase, sem storage_path/prompt_visual/scene_hash, sem HTML injetado.
  for (const proibido of [/<Image\b/, /supabase/i, /storage/i, /prompt_visual/, /scene_hash/, /createSignedUrl/, /dangerouslySetInnerHTML/]) {
    assert.doesNotMatch(view.replace(/^\s*\/\/.*$/gm, ""), proibido, `renderer: ${proibido}`); // só código (comentários podem citar Supabase)
  }
});

// ---------------------------------------------------------------------------
// Refinamento visual (layout 2x2, balões de fala, hierarquia, regra de prova)
// ---------------------------------------------------------------------------
const cssSemComentarios = css.replace(/\r\n/g, "\n").replace(/\/\*[\s\S]*?\*\//g, "");

test("Q7-1: renderer continua aceitando quadrinho_didatico e expõe a contagem de quadros ao CSS", () => {
  assert.match(view, /quadrinho_didatico:\s*QuadrinhoDidaticoView/);
  assert.match(viewQuadrinho, /<ol className="teoria-quadrinho-quadros" data-quadros=\{quadrinho\.quadros\.length\}>/);
  assert.match(impressaoQuadrinho, /<ol className="impressao-quadrinho-quadros" data-quadros=\{componente\.quadros\.length\}>/);
});

test("Q7-2: 4 quadros têm regra própria 2x2 no desktop e 1 coluna abaixo de 640px", () => {
  const media = cssSemComentarios.match(/@media \(min-width: 640px\)\s*\{[\s\S]*?\n\}\n/)?.[0] ?? "";
  assert.match(media, /\.teoria-quadrinho-quadros\[data-quadros="4"\]/);
  assert.match(media, /grid-template-columns:\s*repeat\(2,\s*minmax\(0,\s*1fr\)\)/);
  // A regra 2x2 só existe dentro do @media: no mobile vale a base (auto-fit → 1 coluna).
  const fora = cssSemComentarios.replace(media, "");
  assert.doesNotMatch(fora, /\.teoria-quadrinho-quadros\[data-quadros="4"\]/);
  assert.match(fora, /\.teoria-quadrinho-quadros\s*\{[^}]*repeat\(auto-fit,\s*minmax\(min\(100%,\s*250px\),\s*1fr\)\)/);
});

test("Q7-2b: 5 quadros fecham a última linha e 6 viram 3x2 em telas largas", () => {
  assert.match(cssSemComentarios, /\[data-quadros="5"\]\s*>\s*\.teoria-quadrinho-quadro:last-child\s*\{[^}]*grid-column:\s*1\s*\/\s*-1/);
  assert.match(cssSemComentarios, /@media \(min-width: 1100px\)\s*\{\s*\.teoria-quadrinho-quadros\[data-quadros="6"\]\s*\{[^}]*repeat\(3,/);
});

test("Q7-3: a regra de prova fica FORA da grade dos quadros e em largura total", () => {
  const iOl = viewQuadrinho.indexOf("</ol>");
  const iFech = viewQuadrinho.indexOf("teoria-quadrinho-fechamento");
  assert.ok(iOl > -1 && iFech > iOl, "fechamento deve vir depois do fechamento do <ol>");
  assert.match(viewQuadrinho, /REGRA DE PROVA/);
  assert.match(cssSemComentarios, /\.teoria-quadrinho-fechamento\s*\{[^}]*width:\s*100%/);
  const iOlPdf = impressaoQuadrinho.indexOf("</ol>");
  assert.ok(impressaoQuadrinho.indexOf('rotulo="Regra de prova"') > iOlPdf, "PDF: regra de prova fora da grade");
});

test("Q7-4: falas seguem em ordem (map direto) e a fala tem mais peso que a cena", () => {
  assert.match(viewQuadrinho, /quadro\.falas\.map\(\(fala, indice\)/);
  const tamanho = (seletor) => Number(cssSemComentarios.match(new RegExp(`${seletor.replace(/\./g, "\\.")}\\s*\\{[^}]*font-size:\\s*(\\d+)px`))?.[1]);
  assert.ok(tamanho(".teoria-quadrinho-fala-texto") > tamanho(".teoria-quadrinho-cena"), "fala maior que cena");
  assert.ok(tamanho(".teoria-quadrinho-cena") >= 12, "cena continua legível");
  // Fala como balão: borda arredondada assimétrica, alternando o lado.
  assert.match(cssSemComentarios, /\.teoria-quadrinho-falas > div\s*\{[^}]*border-radius:\s*14px 14px 14px 4px/);
  assert.match(cssSemComentarios, /\.teoria-quadrinho-falas > div:nth-child\(even\)/);
});

test("Q7-5: falas=[] e legenda opcional continuam condicionais (sem bloco artificial)", () => {
  assert.match(viewQuadrinho, /quadro\.falas\.length > 0 && \(/);
  assert.match(viewQuadrinho, /quadro\.legenda && <p className="teoria-quadrinho-legenda">/);
  assert.doesNotMatch(viewQuadrinho, /sem falas/i);
  assert.match(impressaoQuadroItem, /quadro\.falas\.length > 0 && \(/);
  assert.match(impressaoQuadroItem, /quadro\.legenda && <p className="impressao-quadrinho-legenda">/);
});

test("Q7-6: quadros sem alturas rígidas (só min-height) e o quadro se alonga com as falas", () => {
  const bloco = cssSemComentarios.match(/\.teoria-quadrinho-quadro\s*\{[^}]*\}/)?.[0] ?? "";
  assert.match(bloco, /min-height:/);
  assert.doesNotMatch(bloco, /(^|[^-])height:/);
  assert.match(cssSemComentarios, /\.teoria-quadrinho-falas\s*\{[^}]*flex:\s*1 1 auto/);
});

test("Q7-7: PDF mantém hierarquia (2 colunas só com 4+ quadros, quadro e fala sem quebrar entre páginas)", () => {
  assert.match(cssSemComentarios, /\.impressao-quadrinho-quadros\[data-quadros="4"\][\s\S]*?repeat\(2,/);
  assert.doesNotMatch(cssSemComentarios, /\.impressao-quadrinho-quadros\[data-quadros="3"\]/);
  assert.match(cssSemComentarios, /\.impressao-quadrinho-falas > div\s*\{[^}]*break-inside:\s*avoid/);
  // Ordem DENTRO de um quadro (número, cena, falas, legenda) — vive em renderizarQuadroImpressao desde a Q12.24.
  const ordemQuadro = ["Quadro {quadro.numero}", "quadro.cena", "quadro.falas", "quadro.legenda"].map((t) => impressaoQuadroItem.indexOf(t));
  assert.ok(ordemQuadro.every((i) => i > -1) && [...ordemQuadro].sort((a, b) => a - b).join() === ordemQuadro.join(), "ordem dentro do quadro: número, cena, falas, legenda");
  // Regra de prova continua vindo DEPOIS de toda a grade (cabeçalho+1ª linha e o restante), nunca entre quadros.
  const posRestante = impressaoQuadrinho.indexOf("restante.length > 0");
  const posRegraDeProva = impressaoQuadrinho.indexOf('rotulo="Regra de prova"');
  assert.ok(posRestante > -1 && posRegraDeProva > posRestante, "regra de prova vem depois da grade inteira dos quadros");
});

test("Q7-8: o refinamento não introduziu cor nova nem imagem no CSS do quadrinho", () => {
  const regras = cssSemComentarios.match(/[^{}]*quadrinho[^{}]*\{[^}]*\}/g)?.join("\n") ?? "";
  assert.doesNotMatch(regras, /\burl\(|<img|background-image|gradient/i);
});
