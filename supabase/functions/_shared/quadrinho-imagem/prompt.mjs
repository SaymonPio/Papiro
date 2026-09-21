// Prompt visual determinístico dos quadros (Fase Q12.1).
//
// Função PURA: mesma entrada => exatamente o mesmo texto. O texto retornado é o
// que é enviado à Image API E o que é persistido em aula_quadrinho_assets.
// prompt_visual (auditável). Sem chamada extra de LLM: o "brief" compartilhado é
// só a style bible fixa + as cenas do MESMO quadrinho como continuidade visual.
//
// REGRA DO PRODUTO: a imagem NÃO contém texto jurídico. Só as CENAS entram no
// prompt — nunca falas, legendas, fechamento, artigos ou qualquer conteúdo
// textual da aula; tudo isso continua em HTML no renderer. Este módulo também
// NÃO interpreta lei: apenas converte cena pedagógica já aprovada em descrição
// visual.

import { IMAGE_PROMPT_VERSION, MAX_PROMPT_VISUAL_CHARS, MAX_QUADROS, MIN_QUADROS } from "./config.mjs";

// v3 (Q12.5): a v1 saiu fotográfica ("realistic", "natural anatomy" empurravam para live-action) e a
// v2 (STYLE_BIBLE_V2, já gravada em prompt_version quadrinho-imagem-v2) saiu ilustrada, porém escura
// demais, com personagem e fundo se misturando e uma figura humana enevoada. A v3 mantém os bloqueios de
// fotografia e acrescenta: definição de formas, contornos discretos e seletivos, separação sujeito/fundo,
// meios-tons levantados (sem pretos esmagados), contraste de temperatura frio/quente e legibilidade
// obrigatória de qualquer figura humana. Conteúdo pedagógico, regra SEM TEXTO e "só o painel N" não mudam.
export const STYLE_BIBLE_V3 = [
  "Adult editorial graphic-novel illustration for professional education (Brazilian public-safety exam preparation): a premium contemporary graphic novel, clearly drawn and painted by an illustrator.",
  "Rendering: semi-realistic digital painting with slightly simplified forms, discreet selective ink-like contour lines on key edges only, controlled stylized graphic shadows, visible brush and paper texture; painted volumes that are NOT photographic; adult natural anatomy and realistic proportions; credible setting.",
  "Clarity: strong separation between characters and background through value contrast, rim light and clean readable silhouettes; the action must read instantly at thumbnail size; lifted mid-tones, deepest darks kept slightly open; every important figure is an unmistakably human, fully legible character with a visible face, clear posture and a clear gesture.",
  "Color and light: restrained sober Papiro palette, a subtle deep green and cool blue-grey exteriors against warm golden interior light; discreet gold accents only where they fit the scene; the cool/warm temperature contrast organizes the composition.",
  "It must look ILLUSTRATED, never photographic: NO photorealism, NO photography, NO DSLR look, NO live-action still, NO movie still, NO hyperreal rendering, NO photographic skin texture, NO photographic depth of field or lens bokeh.",
  "Also avoid: horror aesthetic, ghostly figure, fog-obscured face, muddy shadows, crushed blacks, low subject-background separation, thick comic outlines.",
  "Not childish, not cartoon, not anime, not caricature, no cel shading, not superhero comics, no exaggeration, no graphic violence, no gore, no thriller excess.",
  "Clothing is plain and generic. If public agents appear, use generic dark uniforms with NO official crests, NO insignia, NO corporation names, NO logos and NO badges with readable markings, clearly separated from the background.",
].join("\n");

export const REGRA_SEM_TEXTO_V1 = [
  "NO visible text. NO captions. NO speech bubbles. NO letters. NO numbers.",
  "NO legal articles. NO readable signs. NO logos. NO watermarks.",
  "NO badges with readable markings. NO UI text.",
  "The image is only the illustration layer: every word of the lesson is rendered outside the image.",
].join("\n");

/**
 * Extrai SOMENTE as cenas de um componente quadrinho_didatico. Falas, legendas,
 * fechamento e qualquer outro campo são descartados aqui, de propósito.
 *
 * @param {unknown} componente
 * @returns {string[]}
 */
export function extrairCenas(componente) {
  if (!componente || typeof componente !== "object" || !Array.isArray(componente.quadros)) {
    throw new Error("CONTEXTO_INVALIDO: componente sem lista de quadros");
  }
  const cenas = componente.quadros.map((quadro) => (quadro && typeof quadro === "object" && typeof quadro.cena === "string" ? quadro.cena.trim() : ""));
  if (cenas.length < MIN_QUADROS || cenas.length > MAX_QUADROS) {
    throw new Error(`CONTEXTO_INVALIDO: esperado ${MIN_QUADROS} a ${MAX_QUADROS} quadros, encontrado ${cenas.length}`);
  }
  if (cenas.some((c) => c.length === 0)) throw new Error("CONTEXTO_INVALIDO: quadro sem cena");
  return cenas;
}

/**
 * @param {{ cenaAtual: string, quadroIndice: number, cenas: string[], promptVersion?: string }} entrada
 * @returns {string} texto EXATO enviado à API (e persistido em prompt_visual)
 */
export function montarPromptVisual({ cenaAtual, quadroIndice, cenas, promptVersion = IMAGE_PROMPT_VERSION }) {
  if (!Array.isArray(cenas) || cenas.length < MIN_QUADROS || cenas.length > MAX_QUADROS) {
    throw new Error(`CONTEXTO_INVALIDO: esperado ${MIN_QUADROS} a ${MAX_QUADROS} cenas`);
  }
  if (!Number.isInteger(quadroIndice) || quadroIndice < 0 || quadroIndice >= cenas.length) {
    throw new Error("CONTEXTO_INVALIDO: quadro_indice fora do intervalo das cenas");
  }
  // A cena do claim (fonte da verdade, já verificada por scene_hash no banco) precisa
  // ser a mesma do componente lido agora; senão o contexto de continuidade está velho.
  if (typeof cenaAtual !== "string" || cenaAtual.trim() !== cenas[quadroIndice].trim()) {
    throw new Error("CONTEXTO_INVALIDO: cena do claim difere da cena do componente");
  }

  const continuidade = cenas.map((cena, i) => `Panel ${i + 1}${i === quadroIndice ? " (THE ONE TO DRAW)" : ""}: ${cena.trim()}`).join("\n");
  const numero = quadroIndice + 1;

  const prompt = [
    `[STYLE — ${promptVersion}]`,
    STYLE_BIBLE_V3,
    "",
    "[ABSOLUTE RULE — NO TEXT IN THE IMAGE]",
    REGRA_SEM_TEXTO_V1,
    "",
    "[CONTINUITY] The scene descriptions below are in Brazilian Portuguese and belong to the same short story: keep the same characters, clothing, setting and time of day across panels.",
    continuidade,
    "",
    "[TASK]",
    `Illustrate ONLY panel ${numero} of ${cenas.length}: ${cenas[quadroIndice].trim()}`,
    "Draw one single landscape frame: no panel borders, no collage, no multiple panels.",
    "Depict only what the scene describes; do not add legal explanations, symbols of law or interpretations.",
  ].join("\n");

  if (prompt.length > MAX_PROMPT_VISUAL_CHARS) throw new Error("CONTEXTO_INVALIDO: prompt visual excede o limite de auditoria");
  return prompt;
}
