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
  assert.match(view, /function QuadrinhoDidaticoView\(\{ c \}: \{ c: ComponenteAula \}\)/);
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
  assert.match(view, /Vista \? <Vista c=\{componente\} \/> : <ComponenteGenericoView componente=\{componente\} \/>/);
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
  assert.match(impressaoQuadrinho, /quadro\.legenda &&/);
  assert.match(impressaoQuadrinho, /<dt className="impressao-quadrinho-emissor">/);
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

test("Q3-21: nenhum código de imagem/asset foi introduzido no renderer, no PDF nem no CSS do quadrinho", () => {
  // Só regras reais: remove comentários /* … */ (que explicam "sem imagem").
  const cssQuadrinho = css.replace(/\/\*[\s\S]*?\*\//g, "").match(/[^{}]*quadrinho[^{}]*\{[^}]*\}/g)?.join("\n");
  assert.ok(cssQuadrinho && cssQuadrinho.length > 0);
  for (const proibido of [/<img\b/i, /<Image\b/, /\bsrc=/, /\balt=/, /\bimagem\b/i, /asset/i, /\burl\(/, /supabase/i, /storage/i]) {
    assert.doesNotMatch(viewQuadrinho, proibido, `renderer: ${proibido}`);
    assert.doesNotMatch(impressaoQuadrinho, proibido, `pdf: ${proibido}`);
    assert.doesNotMatch(cssQuadrinho, proibido, `css: ${proibido}`);
  }
  assert.doesNotMatch(viewQuadrinho, /dangerouslySetInnerHTML/);
});
