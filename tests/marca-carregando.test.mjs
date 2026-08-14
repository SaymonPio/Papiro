import test from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

const componente=await readFile(new URL("../components/ui/MarcaCarregando.tsx",import.meta.url),"utf8");
const estilos=await readFile(new URL("../app/globals.css",import.meta.url),"utf8");
const telas=[
  "admin/page.tsx",
  "admin/aulas/page.tsx",
  "admin/importar-questoes/page.tsx",
  "caderno-de-erros/page.tsx",
  "cronograma/page.tsx",
  "estatisticas/page.tsx",
  "painel/page.tsx",
  "questoes/page.tsx",
  "questoes/resultado/page.tsx",
  "teoria/page.tsx",
  "editais/resultado/page.tsx",
];

test("marca de carregamento reutiliza o losango do Papiro e preserva acessibilidade",()=>{
  assert.match(componente,/brand-mark marca-carregando-simbolo/);
  assert.match(componente,/>P<\/span>/);
  assert.match(componente,/role="status"/);
  assert.match(componente,/aria-live="polite"/);
});

test("animação é sutil e respeita preferência por movimento reduzido",()=>{
  assert.match(estilos,/@keyframes marca-papiro-pulso/);
  assert.match(estilos,/animation: marca-papiro-pulso 1\.8s ease-in-out infinite/);
  assert.match(estilos,/@media \(prefers-reduced-motion: reduce\)/);
});

test("todas as telas de espera usam o componente compartilhado",async()=>{
  for(const tela of telas){
    const pagina=await readFile(new URL(`../app/${tela}`,import.meta.url),"utf8");
    assert.match(pagina,/import MarcaCarregando/);
    assert.match(pagina,/<MarcaCarregando texto=/);
  }
});
