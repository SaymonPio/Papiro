"use client";

import { useEffect, useRef, useState } from "react";
import { HeroParticlesCanvas } from "./HeroParticlesCanvas";

/*
 * V5 EXPERIMENTAL — menos é mais, WebGL2 nativo (sem three.js, sem dependência nova).
 *
 * As versões V3/V4/V4.1 já tinham a arquitetura certa (massas com centro/forma próprios,
 * captura por campo normal+tangencial, funil só no fim), mas com muita partícula por cima de
 * uma arte que já é densa: virava "névoa granulada" competindo com o fundo. A V5 não muda a
 * arquitetura — reduz fortemente a densidade e reorganiza a hierarquia visual:
 *
 *  - só 2 massas (não 3): uma PRINCIPAL (prominence 1.0) e uma SECUNDÁRIA bem mais discreta
 *    (prominence ~0.4, menos brilho e tamanho) — nunca "3 nuvens" competindo;
 *  - a maioria das partículas (~78%) é a camada "atmosfera": micropartículas pequenas e
 *    discretas, não ligadas a massa alguma (mesma lógica de fluxo ambiente da V4.1, só que
 *    agora é o grosso da população, não um extra);
 *  - a camada "meio" (partículas de massa) cai para ~18% do total — poucas o bastante para
 *    ler como fios finos com vazios entre eles, não um bloco;
 *  - ~4% "frente", raras e um pouco maiores — os poucos pontos especiais/brilhantes;
 *  - dentro de cada massa, só 2 lóbulos (era 4) e uma máscara de segmentos que apaga uma
 *    fração deles por vez, girando devagar — quebra a corrente em 2–4 fios separados por
 *    espaços vazios, em vez de uma faixa contínua;
 *  - turbulência geral reduzida (campo de fluxo com amplitude menor) — a cena deriva/ondula
 *    sem "ferver";
 *  - máscara espacial simples ao redor do portal: a camada de atmosfera fica um pouco mais
 *    fraca bem em cima da faixa de anéis já densos da própria arte, para não empilhar
 *    partícula dinâmica exatamente onde a imagem já é mais cheia.
 *
 * O ciclo de cada massa (livre -> contato/captura -> canalização -> portal, com captura por
 * campo normal+tangencial e funil só nos últimos ~10-12%) é o mesmo desde a V4/V4.1 — só a
 * quantidade, a forma interna (lóbulos+vazios) e o brilho médio mudaram nesta rodada.
 *
 * Robustez: se WebGL2 não existir, ou os shaders não compilarem/linkarem, o componente cai
 * de volta para <HeroParticlesCanvas /> (V1) automaticamente — sem lançar erro no console.
 */

const ART_W = 1672;
const ART_H = 941;
// A posição do portal (1313,300) é usada só dentro do shader (const vec2 PORTAL em VERT_SRC);
// halo e vórtice do portal são calculados inteiramente lá, sem precisar do valor aqui no JS.

type Pt = [number, number];

const TAIL: Pt[] = [[1215, 470], [1300, 432], [1350, 398], [1322, 345], [1313, 302]];
const TRAIL: Pt[] = [
  [640, 800], [860, 745], [1050, 695], [1200, 668], [1315, 640],
  [1345, 598], [1300, 560], [1230, 535], [1196, 505], ...TAIL,
];

interface CurveSamples {
  x: Float32Array;
  y: Float32Array;
  nx: Float32Array;
  ny: Float32Array;
}

/** Catmull-Rom — a mesma curva do V1/V2 (idêntica em forma), reamostrada aqui em N passos. */
function buildCurve(points: Pt[], steps: number): CurveSamples {
  const n = points.length;
  const x = new Float32Array(steps + 1);
  const y = new Float32Array(steps + 1);
  const at = (i: number) => points[Math.max(0, Math.min(n - 1, i))];
  for (let s = 0; s <= steps; s++) {
    const f = (s / steps) * (n - 1);
    const i = Math.min(n - 2, Math.floor(f));
    const t = f - i;
    const p0 = at(i - 1), p1 = at(i), p2 = at(i + 1), p3 = at(i + 2);
    const t2 = t * t, t3 = t2 * t;
    x[s] = 0.5 * (2 * p1[0] + (-p0[0] + p2[0]) * t + (2 * p0[0] - 5 * p1[0] + 4 * p2[0] - p3[0]) * t2 + (-p0[0] + 3 * p1[0] - 3 * p2[0] + p3[0]) * t3);
    y[s] = 0.5 * (2 * p1[1] + (-p0[1] + p2[1]) * t + (2 * p0[1] - 5 * p1[1] + 4 * p2[1] - p3[1]) * t2 + (-p0[1] + 3 * p1[1] - 3 * p2[1] + p3[1]) * t3);
  }
  const nx = new Float32Array(steps + 1);
  const ny = new Float32Array(steps + 1);
  for (let s = 0; s <= steps; s++) {
    const a = Math.max(0, s - 1), b = Math.min(steps, s + 1);
    const dx = x[b] - x[a], dy = y[b] - y[a];
    const len = Math.hypot(dx, dy) || 1;
    nx[s] = -dy / len;
    ny[s] = dx / len;
  }
  return { x, y, nx, ny };
}

// resolução maior que a V4 (era 31): tangentes mais suaves perto do portal, onde a curva
// original tem trechos mais fechados — evita mudanças bruscas de direção entre segmentos.
const CURVE_SAMPLES = 63; // uCurve[64] no shader (0..63)

function buildTrailUniform(): Float32Array {
  const cv = buildCurve(TRAIL, CURVE_SAMPLES);
  const out = new Float32Array((CURVE_SAMPLES + 1) * 4);
  for (let i = 0; i <= CURVE_SAMPLES; i++) {
    out[i * 4] = cv.x[i];
    out[i * 4 + 1] = cv.y[i];
    out[i * 4 + 2] = cv.nx[i];
    out[i * 4 + 3] = cv.ny[i];
  }
  return out;
}

// ---------------------------------------------------------------------------------------
// Layout do buffer (um único VBO, um único par de shaders):
//   [0 .. MAIN_MAX)              partículas de densidade variável: atmosfera (~78%, a maioria
//                                 — micropartículas discretas, não ligadas a massa alguma),
//                                 meio (~18%, pertencem a uma das 2 massas — o(s) fio(s) vivo(s))
//                                 e frente (~4%, raras, um pouco maiores/mais especiais),
//                                 intercaladas aleatoriamente para que QUALQUER prefixo
//                                 (density() ou o governor de desempenho) continue proporcional.
//   [MAIN_MAX .. +SHADOW_COUNT)  1 ponto de sombra por massa — sempre desenhado, blend
//                                 multiplicativo à parte, nunca aditivo.
//   [.. +TAIL_COUNT)             pequeno vórtice fixo do portal + 1 ponto de halo.
// ---------------------------------------------------------------------------------------

const MASS_COUNT = 2; // 1 corrente principal + 1 secundária bem mais discreta (nunca "3 nuvens")
const MAIN_MAX = 16000; // desktop; bem menor que a V4 (40k) — mais espaço vazio, menos névoa
const SHADOW_COUNT = MASS_COUNT;
const ORBIT_COUNT = 10; // vórtice fixo do portal, reduzido junto com o resto
const TAIL_COUNT = ORBIT_COUNT + 1; // + 1 halo
const STRIDE = 7; // aSeed0,aSeed1,aSeed2,aSeed3,aMassId,aPlane,aTone

function buildAttributes(): Float32Array {
  const total = MAIN_MAX + SHADOW_COUNT + TAIL_COUNT;
  const data = new Float32Array(total * STRIDE);
  let o = 0;

  // atmosfera (~78%, hierarquia dominante — micro, discreta), meio (~18%, o(s) fio(s)
  // vivo(s)), frente (~4%, raras/especiais) — intercalados.
  for (let i = 0; i < MAIN_MAX; i++) {
    const planeRoll = Math.random();
    const plane = planeRoll < 0.78 ? 0 : planeRoll < 0.96 ? 1 : 2;
    const massId = Math.floor(Math.random() * MASS_COUNT);
    // a grande maioria fica no tom dourado/âmbar; branco-dourado é raríssimo
    const toneRoll = Math.random();
    const tone = toneRoll < 0.62 ? 0 : toneRoll < 0.985 ? 1 : 2;
    data[o++] = Math.random();
    data[o++] = Math.random();
    data[o++] = Math.random();
    data[o++] = Math.random();
    data[o++] = plane === 1 ? massId : Math.random() * MASS_COUNT;
    data[o++] = plane;
    data[o++] = tone;
  }
  // uma sombra por massa
  for (let m = 0; m < SHADOW_COUNT; m++) {
    data[o++] = Math.random();
    data[o++] = Math.random();
    data[o++] = Math.random();
    data[o++] = Math.random();
    data[o++] = m;
    data[o++] = 3;
    data[o++] = 0;
  }
  // vórtice fixo do portal
  for (let i = 0; i < ORBIT_COUNT; i++) {
    data[o++] = Math.random();
    data[o++] = Math.random();
    data[o++] = Math.random();
    data[o++] = Math.random();
    data[o++] = 0;
    data[o++] = 4;
    data[o++] = Math.random() < 0.9 ? 0 : 1;
  }
  // halo
  data[o++] = Math.random(); data[o++] = 0; data[o++] = 0; data[o++] = 0;
  data[o++] = 0; data[o++] = 5; data[o++] = 1;
  return data;
}

const VERT_SRC = `#version 300 es
precision highp float;

in float aSeed0;
in float aSeed1;
in float aSeed2;
in float aSeed3;
in float aMassId;
in float aPlane;
in float aTone;

uniform float uTime;
uniform vec2 uOffset;
uniform float uArtScale;
uniform vec2 uCanvasSize;
uniform vec4 uTextRect;
uniform float uSizeK;
uniform vec4 uCurve[64];

out float vAlpha;
out vec3 vColor;
out float vType;

const vec2 PORTAL = vec2(1313.0, 300.0);

float hash1(float n) { return fract(sin(n) * 43758.5453123); }

// campo de fluxo orgânico: senos combinados (domain warping) + um vórtice lento.
// partículas vizinhas (mesma "home"/massa) usam o mesmo campo, então tendem a se mover
// de forma relacionada em vez de tremerem cada uma por conta própria (jitter individual).
// Amplitude reduzida em relação à V4 (fator ~0,68): a cena deriva/ondula sem "ferver" —
// a tela inteira não deve parecer estar em ebulição.
vec2 flowOffset(vec2 home, float t, float seed) {
  float px = home.x * 0.01 + seed * 6.2831;
  float py = home.y * 0.01 + seed * 6.2831;
  float vx = sin(py * 0.85 + t * 0.32) * 34.0
           + sin((px + py) * 1.6 - t * 0.20 + seed * 3.0) * 22.0
           + sin(px * 0.45 + t * 0.12 + 1.05) * 16.0;
  float vy = cos(px * 0.85 - t * 0.32 + seed * 2.0) * 30.0
           + cos((px - py) * 1.6 + t * 0.20) * 19.0
           + cos(py * 0.45 - t * 0.12 + 0.6) * 14.0;
  float vortAngle = t * 0.05 + seed * 4.0;
  float vr = 20.0 + 13.0 * sin(t * 0.03 + seed * 2.0);
  vx += cos(vortAngle) * vr * 0.4;
  vy += sin(vortAngle) * vr * 0.4;
  return vec2(vx, vy);
}

// máscara espacial simples: a arte de fundo já é densa numa faixa de anéis ao redor do
// portal; a atmosfera fica um pouco mais fraca bem nessa faixa, pra não empilhar partícula
// dinâmica onde a imagem já é mais cheia. Não afeta as partículas de massa/fio (essas
// convergindo para o portal são o efeito pretendido).
float ringAvoid(vec2 p) {
  float d = distance(p, PORTAL);
  float inner = smoothstep(80.0, 190.0, d);
  float outer = 1.0 - smoothstep(300.0, 420.0, d);
  return mix(1.0, 0.5, inner * outer);
}

vec4 sampleCurve(float u) {
  float f = clamp(u, 0.0, 1.0) * 63.0;
  int i = int(floor(f));
  int i2 = min(i + 1, 63);
  return mix(uCurve[i], uCurve[i2], f - float(i));
}

// --- parâmetros de cada massa, derivados só do id (sem uniforms extras) ---
vec2 massHome(float id) {
  if (id < 0.5) return vec2(260.0, 330.0);
  return vec2(560.0, 560.0);
}
float massSpeedOf(float id) { return 0.052 + hash1(id * 13.7 + 4.0) * 0.026; }
// fases explicitamente espaçadas (não por hash cru): garante que as 2 massas nunca fiquem
// ambas numa janela de baixa atividade (livre + respiração fraca) ao mesmo tempo — sempre
// há pelo menos uma em transição/captura/canalização, perceptivelmente viva.
float massPhaseOf(float id) { return id / 2.0 + hash1(id * 11.0 + 2.0) * 0.16; }
float massBreatheRate(float id) { return 0.10 + hash1(id * 7.1 + 2.0) * 0.09; }
// proeminência visual: a massa 0 é a corrente PRINCIPAL (bem visível); a massa 1 é a
// SECUNDÁRIA, deliberadamente bem mais discreta (menos brilho e tamanho) — nunca duas
// correntes competindo com o mesmo peso.
float massProminenceOf(float id) { return id < 0.5 ? 1.0 : 0.42; }

// centro/orientação atual da massa — usado tanto pela partícula (com a forma local) quanto
// pela sombra (só o centro, num ponto grande e suave).
// Centro/orientação atuais da massa. Em vez de misturar (lerp) a posição livre direto com um
// ponto da curva — o que podia fazer a massa "atravessar" o caminho em linha reta — o
// deslocamento em relação à curva é decomposto em componente NORMAL (distância lateral até a
// reta local do caminho) e TANGENCIAL (adiantamento/atraso ao longo dele). A força normal age
// primeiro (a massa encosta e se dobra na direção do caminho); só depois a tangencial cresce
// (ela passa a correr pela trilha).
vec2 computeMass(float id, out vec2 tangent, out vec2 normal, out float pathT, out float massLife, out float compress, out float tangentialPull) {
  float mSpeed = massSpeedOf(id);
  float mPhase = massPhaseOf(id);
  massLife = fract(uTime * mSpeed + mPhase);

  // 0–32% vida livre; 32–70% contato/captura (a rota não fica evidente logo no início);
  // 70–96% canalização; 96–100% portal.
  pathT = smoothstep(0.32, 0.70, massLife);
  tangentialPull = smoothstep(0.5, 1.0, pathT); // a força tangencial só cresce depois da normal

  vec2 home = massHome(id);
  vec2 freeOff = flowOffset(home, uTime * 0.6, mPhase) * (0.9 + 0.25 * sin(uTime * 0.05 + mPhase * 4.0));
  vec2 freeCenter = home + freeOff;

  float uRaw = clamp((massLife - 0.5) / 0.5, 0.0, 1.0);
  float uEase = smoothstep(0.0, 1.0, uRaw) * 0.88;
  float u;
  if (massLife < 0.96) {
    u = uEase;
  } else {
    float t2 = (massLife - 0.96) / 0.04;
    u = 0.88 + 0.12 * (1.0 - pow(1.0 - t2, 3.0)); // desaceleração real: derivada -> 0 perto do portal
  }
  vec4 cv = sampleCurve(u);
  vec2 curvePos = cv.xy;
  vec2 curveNormalV = cv.zw;
  vec2 curveTangentV = vec2(cv.w, -cv.z);

  // decompõe o deslocamento livre em relação à reta local da curva nesse ponto
  float normalOffset = dot(freeCenter - curvePos, curveNormalV);
  float tangentOffset = dot(freeCenter - curvePos, curveTangentV);
  float remainingNormal = normalOffset * (1.0 - pathT);
  float remainingTangent = tangentOffset * (1.0 - tangentialPull);
  vec2 center = curvePos + curveNormalV * remainingNormal + curveTangentV * remainingTangent;

  float freeAngle = uTime * 0.045 + mPhase * 6.2831;
  vec2 freeTangent = vec2(cos(freeAngle), sin(freeAngle));
  vec2 freeNormal = vec2(-sin(freeAngle), cos(freeAngle));
  tangent = normalize(mix(freeTangent, curveTangentV, tangentialPull));
  normal = normalize(mix(freeNormal, curveNormalV, pathT));

  compress = smoothstep(0.9, 1.0, massLife); // compressão/esmaecimento final (absorção)
  return center;
}

void main() {
  float t = uTime;
  vec2 posArt;
  float sizeMul = 1.0;
  float alphaMul = 1.0;
  vType = 0.0;

  if (aPlane > 3.5) {
    // cauda fixa: pequeno vórtice de absorção ao redor do portal + halo
    float life = fract(t * 0.09 * aSeed3 + aSeed0);
    float r = mix(140.0, 5.0, pow(life, 0.6));
    float dir = aSeed1 < 0.5 ? 1.0 : -1.0;
    float ang = aSeed1 * 6.2831 + t * (0.6 + aSeed2 * 0.8) * dir + life * 8.0;
    posArt = PORTAL + vec2(cos(ang) * r * 1.1, sin(ang) * r * 0.85);
    alphaMul = (1.0 - life) * 0.75;
    sizeMul = 0.75;
    vType = 1.0;
    if (aPlane > 4.5) {
      // halo: um único ponto grande e suave, pulso lento + pulso rápido (nunca um flash)
      float pulse = 0.5 + 0.5 * sin(t * 1.1);
      float slowPulse = 0.5 + 0.5 * sin(t * 0.07 + 1.3);
      posArt = PORTAL;
      alphaMul = 0.05 + 0.045 * pulse + 0.03 * slowPulse;
      sizeMul = 130.0;
      vType = 2.0;
    }
  } else if (aPlane > 2.5) {
    // sombra sutil atrás de cada massa: separa o movimento dinâmico da textura estática
    // da arte sem escurecer nada de forma perceptível isoladamente (alpha bem baixo,
    // blend multiplicativo é aplicado no lado JS para este intervalo do buffer).
    vec2 tangent, normal; float pathT, massLife, compress, tangentialPull;
    posArt = computeMass(aMassId, tangent, normal, pathT, massLife, compress, tangentialPull);
    sizeMul = 190.0 * (1.0 - compress * 0.5);
    alphaMul = 0.07 * massProminenceOf(aMassId);
    vType = 2.0; // usa o mesmo falloff largo e suave do halo
  } else if (aPlane < 0.5) {
    // atmosfera: a hierarquia dominante (~78% do total) — micropartículas pequenas e bem
    // discretas, não ligadas a massa alguma. Sempre presentes (garante que a cena nunca
    // pareça parada), com leve tendência à região central e ao caminho, e um pouco mais
    // fracas bem sobre a faixa de anéis já densa da própria arte (ringAvoid).
    vec2 uniformHome = vec2(aSeed0 * 1672.0, aSeed1 * 941.0);
    vec4 anchorCv = sampleCurve(aSeed3);
    vec2 pathHome = anchorCv.xy + anchorCv.zw * (aSeed2 - 0.5) * 260.0;
    vec2 home = mix(uniformHome, pathHome, 0.45);
    float amWave = 0.5 + 0.5 * sin(t * 0.05 + aSeed2 * 6.2831); // varia devagar, nunca some
    posArt = home + flowOffset(home, t * 0.3, aSeed2) * 0.7;
    sizeMul = 0.42;
    alphaMul = mix(0.09, 0.2, amWave) * ringAvoid(home);
  } else if (aPlane > 1.5) {
    // frente: raras (~4%) e um pouco maiores/mais suaves — os poucos pontos especiais
    // (parallax leve, blur "óptico" via ponto grande, nunca em quantidade).
    vec2 home = vec2(aSeed0 * 1672.0, aSeed1 * 941.0);
    posArt = home + flowOffset(home, t * 0.55, aSeed2) * 0.9;
    sizeMul = 2.2;
    alphaMul = 0.06;
  } else {
    // meio: só ~18% do total — o(s) fio(s) vivo(s), não um bloco.
    vec2 tangent, normal; float pathT, massLife, compress, tangentialPull;
    vec2 center = computeMass(aMassId, tangent, normal, pathT, massLife, compress, tangentialPull);
    float prominence = massProminenceOf(aMassId);

    // deformação orgânica independente da captura: respiração, torção e um ciclo lento de
    // dispersão/reconvergência — sempre ativos, inclusive na fase livre (amplitude reduzida
    // em relação à V4, para não "ferver").
    float breathe = 0.78 + 0.22 * sin(t * massBreatheRate(aMassId) * 6.2831 + aMassId * 5.0 + aSeed2 * 1.5);
    float disp = smoothstep(0.4, 1.0, 0.5 + 0.5 * sin(t * 0.045 + aMassId * 7.0 + aSeed3 * 0.6));
    float twist = sin(t * 0.07 + aMassId * 3.0 + aSeed2 * 2.0) * 0.4 * (1.0 - pathT * 0.6);

    // só 2 lóbulos internos por massa (era 4): menos preenchimento, mais vazio entre eles.
    float lobeId = floor(hash1(aSeed2 * 37.0 + aMassId * 11.0 + 5.0) * 1.999);
    float lobeAngle = hash1(lobeId * 19.0 + aMassId * 23.0 + 7.0) * 6.2831;
    float lobeDist = mix(0.3, 0.85, hash1(lobeId * 31.0 + aMassId * 5.0 + 3.0));
    vec2 lobeCenter = vec2(cos(lobeAngle), sin(lobeAngle)) * lobeDist;

    // cauda suave sem borda dura (amostragem exponencial, não um disco uniforme), mais curta
    // que a V4 — falloff mais agressivo, dá pra distinguir partícula por partícula.
    float rr = -log(1.0 - aSeed0 * 0.97) * 0.3 * (1.0 + disp * 0.5);
    float aa = aSeed1 * 6.2831 + twist;
    // harmônicos angulares: quebram o lóbulo num contorno irregular, não um círculo perfeito
    float lobeWobble = 1.0 + 0.32 * sin(aa * 3.0 + lobeId * 2.1 + aMassId * 1.3)
                            + 0.18 * sin(aa * 5.0 - lobeId * 1.7 + t * 0.1);
    vec2 jitter = vec2(cos(aa), sin(aa)) * rr;
    vec2 local = lobeCenter * lobeWobble + jitter;
    float distFalloff = exp(-dot(local, local) * 1.7); // mais agressivo que a V4 (era 1,1)

    // segmentação ao longo do fio: cada partícula pertence a um de 6 segmentos; um grupo de
    // segmentos vizinhos fica bem mais fraco por vez (a "posição" desse grupo gira devagar),
    // quebrando a corrente em 2-4 fios separados por vazios — nunca uma faixa contínua.
    float segId = floor(hash1(aSeed3 * 41.0 + aMassId * 17.0 + lobeId * 5.0) * 5.999);
    float segCursor = fract(t * 0.015 + aMassId * 0.37) * 6.0;
    float segDist = abs(segId - segCursor);
    segDist = min(segDist, 6.0 - segDist); // distância circular (0..3)
    float segGap = smoothstep(0.35, 1.4, segDist);

    // viés espacial: o lado da massa mais próximo do caminho (local.x > 0, sentido de avanço)
    // deforma um pouco antes do lado oposto — transição espacial, não uma troca brusca.
    float leadBias = clamp(local.x * 0.16, -0.16, 0.16);
    float pathTLocal = clamp(pathT + leadBias * (1.0 - pathT), 0.0, 1.0);
    float tangPullLocal = clamp(tangentialPull + leadBias * (1.0 - tangentialPull), 0.0, 1.0);
    float elongLocal = smoothstep(0.0, 1.0, tangPullLocal);

    // afunilamento progressivo: nuvem -> filamento largo -> corrente -> funil -> portal.
    // o estreitamento forte (funil) só acontece nos últimos ~10% do trajeto da massa; antes
    // disso a largura transversal fica preservada, evitando o jato/coluna fina da V4.
    float funnel = smoothstep(0.88, 1.0, massLife);
    float radius = mix(150.0, 230.0, hash1(aMassId + 1.0)) * breathe * (1.0 - compress * 0.8);
    float tangScale = 1.0 + elongLocal * 1.7; // alongamento moderado — evita faixa/parede sólida
    float normScale = mix(1.0 - pathTLocal * 0.32, 0.22, funnel);
    vec2 shaped = vec2(local.x * tangScale, local.y * normScale) * radius;

    // corrente interna contínua ao longo do eixo principal — as partículas continuam vivas
    // mesmo quando o centro da massa se desloca, sem ser ruído aleatório quadro a quadro.
    // Só se apaga de fato dentro do funil final, para não formar uma linha reta e fina.
    float current = sin(local.x * 4.0 - t * 1.2 + aMassId * 2.0) * 0.045 * radius;
    shaped.y += current * (1.0 - funnel * 0.75);

    // giro sutil (vórtice curto) só na reta final, ao entrar no portal, com raio que cai
    // conforme se aproxima (o próprio "shaped" já encolhe via funnel/portalConverge)
    float endT = smoothstep(0.94, 1.0, massLife);
    float spinA = endT * 7.0;
    vec2 spun = vec2(shaped.x * cos(spinA) - shaped.y * sin(spinA), shaped.x * sin(spinA) + shaped.y * cos(spinA));

    // convergência final: nos últimos ~3% do trajeto, o deslocamento em relação ao centro
    // (tangencial E normal) é levado a zero — a partícula termina exatamente no centro
    // luminoso da chave, nunca atravessando para o outro lado nem sumindo por corte.
    float portalConverge = 1.0 - smoothstep(0.97, 1.0, massLife);

    posArt = center + (tangent * spun.x + normal * spun.y) * portalConverge;
    alphaMul = mix(0.28, 0.48, breathe) * (1.0 - compress * 0.7) * distFalloff * segGap * prominence;
    sizeMul = mix(0.72, 0.95, hash1(aSeed3 * 11.0 + aMassId)) * mix(0.85, 1.0, prominence);
  }

  vec2 devicePx = uOffset + posArt * uArtScale;
  vec2 clip = devicePx / uCanvasSize * 2.0 - 1.0;
  clip.y = -clip.y;
  gl_Position = vec4(clip, 0.0, 1.0);

  float baseSize = mix(2.6, 5.0, hash1(aSeed0 * 97.0 + aSeed1 * 13.0)) * sizeMul;
  // piso mínimo de tamanho: pontos pequenos demais rasterizam poucos fragmentos e o
  // brilho suave (falloff) do fragment shader fica sem amostras perto do centro.
  gl_PointSize = clamp(baseSize * uSizeK, 3.2, 200.0);

  float dx = max(uTextRect.x - devicePx.x, max(0.0, devicePx.x - uTextRect.z));
  float dy = max(uTextRect.y - devicePx.y, max(0.0, devicePx.y - uTextRect.w));
  float d = length(vec2(dx, dy));
  float textFactor = 0.3 + 0.7 * smoothstep(0.0, 110.0 * uArtScale, d);

  vAlpha = clamp(alphaMul, 0.0, 3.0) * textFactor;
  vColor = aTone < 0.5 ? vec3(1.0, 0.816, 0.463) : (aTone < 1.5 ? vec3(0.980, 0.698, 0.322) : vec3(1.0, 0.941, 0.816));
}
`;

const FRAG_SRC = `#version 300 es
precision highp float;
in float vAlpha;
in vec3 vColor;
in float vType;
out vec4 outColor;
void main() {
  vec2 d = gl_PointCoord - 0.5;
  float r = length(d) * 2.0;
  float a;
  if (vType > 1.5) {
    // halo e sombra: falloff largo e suave, sem núcleo forte (evita flash/estouro)
    a = smoothstep(1.0, 0.0, r) * vAlpha;
  } else {
    // gradiente do centro (1) até a borda (0), cobrindo todo o disco — mesmo um ponto
    // pequeno, com poucos fragmentos amostrados longe do centro exato, continua visível.
    float falloff = smoothstep(1.0, 0.0, r);
    float core = smoothstep(0.55, 0.0, r) * 0.55;
    a = (falloff * 0.7 + core) * vAlpha;
  }
  if (a <= 0.001) discard;
  outColor = vec4(vColor, a);
}
`;

function compileShader(gl: WebGL2RenderingContext, type: number, src: string): WebGLShader | null {
  const sh = gl.createShader(type);
  if (!sh) return null;
  gl.shaderSource(sh, src);
  gl.compileShader(sh);
  if (!gl.getShaderParameter(sh, gl.COMPILE_STATUS)) {
    gl.deleteShader(sh);
    return null;
  }
  return sh;
}

function linkProgram(gl: WebGL2RenderingContext): WebGLProgram | null {
  const vs = compileShader(gl, gl.VERTEX_SHADER, VERT_SRC);
  const fs = compileShader(gl, gl.FRAGMENT_SHADER, FRAG_SRC);
  if (!vs || !fs) {
    if (vs) gl.deleteShader(vs);
    if (fs) gl.deleteShader(fs);
    return null;
  }
  const prog = gl.createProgram();
  if (!prog) return null;
  gl.attachShader(prog, vs);
  gl.attachShader(prog, fs);
  gl.linkProgram(prog);
  gl.deleteShader(vs);
  gl.deleteShader(fs);
  if (!gl.getProgramParameter(prog, gl.LINK_STATUS)) {
    gl.deleteProgram(prog);
    return null;
  }
  return prog;
}

const ATTR_NAMES = ["aSeed0", "aSeed1", "aSeed2", "aSeed3", "aMassId", "aPlane", "aTone"] as const;

export function HeroParticlesWebGL() {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const [fallback, setFallback] = useState(false);

  useEffect(() => {
    if (fallback) return;
    const canvas = canvasRef.current;
    const host = canvas?.parentElement;
    if (!canvas || !host) return;

    const gl = canvas.getContext("webgl2", {
      alpha: true,
      antialias: false,
      premultipliedAlpha: false,
      // true: garante que a última cena desenhada continue legível por leituras/capturas
      // fora do próprio laço de renderização (devtools, screenshot); custo desprezível
      // para um canvas decorativo deste tamanho.
      preserveDrawingBuffer: true,
      powerPreference: "low-power",
    });
    if (!gl) {
      setFallback(true);
      return;
    }

    const reduceQuery = window.matchMedia("(prefers-reduced-motion: reduce)");
    let program: WebGLProgram | null = null;
    let buffer: WebGLBuffer | null = null;
    let raf = 0;
    let running = false;
    let visible = true;
    let last = 0;
    let clock = 0;
    let ema = 8;
    let slowFor = 0;
    let mainDrawCount = 0;
    let width = 0;
    let height = 0;
    let dpr = 1;
    let destroyed = false;
    const attribLoc: Record<string, number> = {};
    let uTime: WebGLUniformLocation | null = null;
    let uOffset: WebGLUniformLocation | null = null;
    let uArtScale: WebGLUniformLocation | null = null;
    let uCanvasSize: WebGLUniformLocation | null = null;
    let uTextRect: WebGLUniformLocation | null = null;
    let uSizeK: WebGLUniformLocation | null = null;
    let uCurve: WebGLUniformLocation | null = null;

    // desktop 16000; tablet ~8960 (56%); mobile ~4320 (27%) — dentro das faixas pedidas
    const density = () => (width < 700 ? 0.27 : width < 1021 ? 0.56 : 1);

    const init = (): boolean => {
      program = linkProgram(gl);
      if (!program) return false;
      gl.useProgram(program);

      const attrs = buildAttributes();
      buffer = gl.createBuffer();
      gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
      gl.bufferData(gl.ARRAY_BUFFER, attrs, gl.STATIC_DRAW);
      const stride = STRIDE * 4;
      for (let i = 0; i < ATTR_NAMES.length; i++) {
        const loc = gl.getAttribLocation(program, ATTR_NAMES[i]);
        attribLoc[ATTR_NAMES[i]] = loc;
        if (loc < 0) continue;
        gl.enableVertexAttribArray(loc);
        gl.vertexAttribPointer(loc, 1, gl.FLOAT, false, stride, i * 4);
      }

      uTime = gl.getUniformLocation(program, "uTime");
      uOffset = gl.getUniformLocation(program, "uOffset");
      uArtScale = gl.getUniformLocation(program, "uArtScale");
      uCanvasSize = gl.getUniformLocation(program, "uCanvasSize");
      uTextRect = gl.getUniformLocation(program, "uTextRect");
      uSizeK = gl.getUniformLocation(program, "uSizeK");
      uCurve = gl.getUniformLocation(program, "uCurve[0]");

      gl.uniform4fv(uCurve, buildTrailUniform());

      gl.disable(gl.DEPTH_TEST);
      gl.enable(gl.BLEND);
      return true;
    };

    const resize = () => {
      const rect = host.getBoundingClientRect();
      width = Math.max(1, Math.round(rect.width));
      height = Math.max(1, Math.round(rect.height));
      dpr = Math.min(window.devicePixelRatio || 1, width < 700 ? 1.25 : 1.5);
      canvas.width = Math.round(width * dpr);
      canvas.height = Math.round(height * dpr);
      canvas.style.width = `${width}px`;
      canvas.style.height = `${height}px`;
      gl.viewport(0, 0, canvas.width, canvas.height);

      let px = 0.5;
      let py = 0.5;
      const img = host.querySelector("img");
      if (img) {
        const [ox, oy] = getComputedStyle(img).objectPosition.split(" ");
        const fx = parseFloat(ox);
        const fy = parseFloat(oy);
        if (ox?.endsWith("%") && !Number.isNaN(fx)) px = fx / 100;
        if (oy?.endsWith("%") && !Number.isNaN(fy)) py = fy / 100;
      }
      const baseScale = Math.max(width / ART_W, height / ART_H);
      const artScale = baseScale * dpr;
      const offX = (width - ART_W * baseScale) * px * dpr;
      const offY = (height - ART_H * baseScale) * py * dpr;
      const sizeK = Math.max(0.85, Math.min(1.5, baseScale * 1.15)) * dpr;

      let tx0 = -1e4, ty0 = -1e4, tx1 = -1e4, ty1 = -1e4;
      const copy = host.parentElement?.querySelector("h1")?.parentElement;
      if (copy) {
        const c = copy.getBoundingClientRect();
        const h = host.getBoundingClientRect();
        tx0 = (c.left - h.left - 28) * dpr;
        ty0 = (c.top - h.top - 28) * dpr;
        tx1 = (c.right - h.left + 28) * dpr;
        ty1 = (c.bottom - h.top + 28) * dpr;
      }

      if (!program) return;
      gl.useProgram(program);
      gl.uniform2f(uOffset, offX, offY);
      gl.uniform1f(uArtScale, artScale);
      gl.uniform2f(uCanvasSize, canvas.width, canvas.height);
      gl.uniform1f(uSizeK, sizeK);
      gl.uniform4f(uTextRect, tx0, ty0, tx1, ty1);

      mainDrawCount = Math.round(MAIN_MAX * density());
    };

    const frame = (now: number) => {
      if (!running || destroyed) return;
      const raw = now - last;
      const dt = Math.min(0.05, raw / 1000);
      last = now;
      clock += dt;

      gl.clearColor(0, 0, 0, 0);
      gl.clear(gl.COLOR_BUFFER_BIT);
      if (program) {
        gl.useProgram(program);
        gl.uniform1f(uTime, clock);

        // 1) sombras (uma por massa): escurece minimamente a arte estática atrás de cada
        // massa, ANTES das partículas brilhantes — blend multiplicativo, não aditivo.
        gl.blendFunc(gl.ZERO, gl.ONE_MINUS_SRC_ALPHA);
        gl.drawArrays(gl.POINTS, MAIN_MAX, SHADOW_COUNT);

        // 2) campo principal + cauda do portal: aditivo (o brilho "lighter").
        // RGB acumula aditivamente; o alpha do PRÓPRIO canvas acumula em separado, de forma
        // linear — do contrário quase não teria opacidade em áreas com pouca sobreposição,
        // e o navegador composta o canvas quase invisível sobre a arte de fundo.
        gl.blendFuncSeparate(gl.SRC_ALPHA, gl.ONE, gl.ONE, gl.ONE);
        gl.drawArrays(gl.POINTS, 0, mainDrawCount);
        gl.drawArrays(gl.POINTS, MAIN_MAX + SHADOW_COUNT, TAIL_COUNT);
      }

      ema = ema * 0.95 + Math.min(raw, 100) * 0.05;
      slowFor = ema > 20 ? slowFor + dt : 0;
      if (slowFor > 1.5 && mainDrawCount > MAIN_MAX * 0.35) {
        mainDrawCount = Math.round(mainDrawCount * 0.85);
        slowFor = 0;
      }
      raf = requestAnimationFrame(frame);
    };

    const start = () => {
      if (running || destroyed || reduceQuery.matches || !visible || document.hidden) return;
      running = true;
      last = performance.now();
      raf = requestAnimationFrame(frame);
    };
    const stop = () => {
      running = false;
      cancelAnimationFrame(raf);
      if (gl && !gl.isContextLost()) {
        gl.clearColor(0, 0, 0, 0);
        gl.clear(gl.COLOR_BUFFER_BIT);
      }
    };
    const sync = () => {
      if (reduceQuery.matches) stop();
      else start();
    };

    const onContextLost = (e: Event) => {
      e.preventDefault();
      stop();
      program = null;
    };
    const onContextRestored = () => {
      if (destroyed) return;
      if (!init()) {
        setFallback(true);
        return;
      }
      resize();
      sync();
    };
    canvas.addEventListener("webglcontextlost", onContextLost, false);
    canvas.addEventListener("webglcontextrestored", onContextRestored, false);

    if (!init()) {
      setFallback(true);
      return;
    }
    resize();
    sync();

    const ro = new ResizeObserver(resize);
    ro.observe(host);
    const io = new IntersectionObserver(([entry]) => {
      visible = entry.isIntersecting;
      if (visible) start();
      else stop();
    });
    io.observe(host);
    const onVisibility = () => (document.hidden ? stop() : start());
    document.addEventListener("visibilitychange", onVisibility);
    reduceQuery.addEventListener("change", sync);

    return () => {
      destroyed = true;
      stop();
      ro.disconnect();
      io.disconnect();
      document.removeEventListener("visibilitychange", onVisibility);
      reduceQuery.removeEventListener("change", sync);
      canvas.removeEventListener("webglcontextlost", onContextLost);
      canvas.removeEventListener("webglcontextrestored", onContextRestored);
      if (!gl.isContextLost()) {
        if (buffer) gl.deleteBuffer(buffer);
        if (program) gl.deleteProgram(program);
      }
    };
  }, [fallback]);

  if (fallback) return <HeroParticlesCanvas />;

  return (
    <canvas
      ref={canvasRef}
      aria-hidden="true"
      style={{ position: "absolute", inset: 0, width: "100%", height: "100%", pointerEvents: "none" }}
    />
  );
}
