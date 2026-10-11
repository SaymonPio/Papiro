import assert from "node:assert/strict";
import test from "node:test";
import { readFile } from "node:fs/promises";

const home = await readFile(new URL("../app/page.tsx", import.meta.url), "utf8");
const styles = await readFile(
  new URL("../app/home.module.css", import.meta.url),
  "utf8",
);
const homeHeader = await readFile(
  new URL("../components/home/HomeHeader.tsx", import.meta.url),
  "utf8",
);

test("Gate Home A preserva o título original dentro da nova composição", () => {
  assert.match(home, /SUA FARDA/);
  assert.match(home, /COMEÇA <em>AQUI\.<\/em>/);
  assert.match(home, /Transforme seu edital em uma estratégia de aprovação/);
  assert.match(home, /FOCO • DISCIPLINA • APROVAÇÃO/);
  assert.match(home, /styles\.heroArtwork/);
  assert.match(home, /styles\.heroLead/);
  assert.doesNotMatch(home, /heroBenefits|styles\.heroActions|styles\.benefits/);
  assert.doesNotMatch(home, /Streamline|shadcnblocks|Get Template/i);
});

test("hero usa uma peça visual limpa em vez de miniatura carregada do painel", () => {
  for (const metric of ["68%", "1.284", "+14,2%", "12 dias"]) {
    assert.doesNotMatch(home, new RegExp(metric.replace(/[+.]/g, "\\$&")));
  }

  assert.match(home, /src="\/home-hero-relief\.png"/);
  assert.match(home, /styles\.reliefFrame/);
  assert.match(home, /styles\.reliefImage/);
  assert.doesNotMatch(home, /styles\.previewSidebar/);
  assert.doesNotMatch(home, /Seu plano está pronto para continuar\./);
  assert.doesNotMatch(home, /cursosDisponiveis/);
});

test("navegação e conteúdo da home correspondem a fluxos existentes", () => {
  for (const content of [
    "Edital com IA",
    "Cronograma inteligente",
    "Questões e simulados",
    "Acompanhamento do TAF",
  ]) {
    assert.match(home, new RegExp(content));
  }

  assert.match(homeHeader, /href="\/cadastro"/);
  assert.match(homeHeader, /href="\/login"/);
  assert.match(homeHeader, /aria-current=/);
  assert.match(homeHeader, /href={`#\$\{id\}`}/);
  assert.match(homeHeader, /\["metodo", "Como funciona"\]/);
  assert.match(home, /Guarda Municipal/);
  assert.match(home, /Polícia Militar/);
  assert.doesNotMatch(home, /Polícia Civil/);
  assert.match(home, /exclusivo em Guarda Municipal e Polícia Militar/);
});

test("estilos do Gate Home A ficam isolados e responsivos", () => {
  assert.match(styles, /\.home\s*\{/);
  assert.match(styles, /--home-canvas:\s*#06100d/);
  assert.match(styles, /--home-gold:\s*#d8ad4c/);
  assert.match(styles, /\.hero\s*\{[\s\S]*grid-template-columns:/);
  assert.match(styles, /\.header\s*\{[\s\S]*position:\s*fixed/);
  assert.match(
    styles,
    /\.navigation\s*\{[\s\S]*position:\s*absolute;[\s\S]*left:\s*50%;[\s\S]*transform:\s*translateX\(-50%\)/,
  );
  assert.match(
    styles,
    /\.navigation\s*\{[\s\S]*border:\s*0;[\s\S]*background:\s*transparent;[\s\S]*box-shadow:\s*none/,
  );
  assert.match(styles, /background-color:\s*transparent/);
  assert.doesNotMatch(styles, /scroll-margin-top/);
  assert.match(styles, /\.heroArtwork\s*\{/);
  assert.match(styles, /\.reliefFrame\s*\{/);
  assert.match(styles, /\.reliefImage\s*\{/);
  assert.match(styles, /\.careerStrip\s*\{/);
  assert.match(styles, /@media \(max-width: 1020px\)/);
  assert.match(styles, /@media \(max-width: 700px\)/);
  assert.match(styles, /prefers-reduced-motion: reduce/);
  assert.doesNotMatch(styles, /!important/);
});

test("cabeçalho fixo acompanha o tema e a seção visível", () => {
  assert.match(homeHeader, /document\.elementFromPoint/);
  assert.match(homeHeader, /getBoundingClientRect/);
  assert.match(homeHeader, /\[data-header-theme\]/);
  assert.match(homeHeader, /styles\.headerLight/);
  assert.match(homeHeader, /styles\.headerDark/);
  assert.match(homeHeader, /aria-expanded=\{menuOpen\}/);
  assert.match(homeHeader, /styles\.mobileMenuOpen/);
  assert.match(styles, /\.headerLight\s*\{/);
  assert.match(home, /data-header-theme="light"/);
  assert.match(home, /data-header-theme="dark"/);
});

test("landing usa somente ações reais e exemplos identificados", () => {
  assert.match(home, /EXEMPLO ILUSTRATIVO • CORRIDA/);
  assert.match(home, /href="\/cadastro"/);
  assert.match(home, /CRIAR MINHA CONTA/);
  assert.match(home, /CADASTRO ABERTO/);
  assert.doesNotMatch(home, />EXPLORAR/);
  assert.doesNotMatch(home, /CADASTRO EM BREVE/);
  assert.doesNotMatch(home, /99754-1888|WHATSAPP DEMONSTRATIVO/);
});
