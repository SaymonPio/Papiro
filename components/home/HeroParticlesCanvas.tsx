"use client";

import { useEffect, useRef } from "react";

/*
 * Enxame de partículas douradas do hero.
 *
 * As trajetórias vivem nas coordenadas da arte (1672x941) e são mapeadas para o canvas
 * com a mesma regra de "object-fit: cover" + "object-position" da imagem de fundo, então
 * o fluxo continua alinhado ao caminho dourado e ao portal em qualquer tamanho de tela.
 *
 * Camadas:
 *  - fundo: micropartículas que seguem as mesmas faixas de partículas já presentes na arte;
 *  - massas: bandos que entram pela esquerda, respiram, se deformam, dispersam e reconvergem;
 *    parte de cada bando é "capturada" pelo caminho e conduzida ao portal;
 *  - caminho: micropartículas em ondas de brilho rumo ao portal;
 *  - portal: espiral de absorção + halo discreto que reage às chegadas;
 *  - frente: poucas partículas maiores e desfocadas, com parallax leve.
 *
 * O brilho nasce da soma de muitas partículas pequenas (adensamento), não de pontos isolados.
 */

const ART_W = 1672;
const ART_H = 941;
const PORTAL: Pt = [1313, 300];

type Pt = [number, number];

const TAIL: Pt[] = [[1215, 470], [1300, 432], [1350, 398], [1322, 345], [1313, 302]];
const FLOW_MAIN: Pt[] = [
  [140, 215], [300, 175], [470, 150], [590, 215], [650, 290],
  [760, 338], [860, 362], [940, 432], [1030, 436], [1110, 458], ...TAIL,
];
const FLOW_LOW: Pt[] = [
  [0, 820], [200, 760], [450, 715], [700, 695], [900, 675],
  [1060, 625], [1160, 548], ...TAIL,
];
const TRAIL: Pt[] = [
  [640, 800], [860, 745], [1050, 695], [1200, 668], [1315, 640],
  [1345, 598], [1300, 560], [1230, 535], [1196, 505], ...TAIL,
];

interface Curve {
  x: Float32Array;
  y: Float32Array;
  nx: Float32Array;
  ny: Float32Array;
  /** parâmetro (0..1) do ponto em que o fluxo encontra a trilha */
  junction: number;
}

function buildCurve(points: Pt[], junctionIndex: number, steps = 280): Curve {
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
  return { x, y, nx, ny, junction: junctionIndex / (n - 1) };
}

const rand = (a: number, b: number) => a + Math.random() * (b - a);
const clamp01 = (v: number) => (v < 0 ? 0 : v > 1 ? 1 : v);
const smooth = (a: number, b: number, v: number) => {
  const t = clamp01((v - a) / (b - a));
  return t * t * (3 - 2 * t);
};
const gauss = () => (Math.random() + Math.random() + Math.random() - 1.5) / 1.5;

/** 0 = dourado, 1 = âmbar, 2 = highlight quente (raro) */
const pickTone = () => {
  const r = Math.random();
  return r < 0.58 ? 0 : r < 0.94 ? 1 : 2;
};

/** leitura de ponto/normal da curva sem alocar objetos */
const S = { x: 0, y: 0, nx: 0, ny: 0 };
function sample(c: Curve, u: number) {
  const idx = clamp01(u) * (c.x.length - 1);
  const i = Math.min(c.x.length - 2, Math.floor(idx));
  const f = idx - i;
  S.x = c.x[i] + (c.x[i + 1] - c.x[i]) * f;
  S.y = c.y[i] + (c.y[i + 1] - c.y[i]) * f;
  S.nx = c.nx[i];
  S.ny = c.ny[i];
}

interface Cluster {
  curve: number;
  s: number;
  speed: number;
  r0: number;
  phase: number;
  period: number;
  dispPeriod: number;
  dispPhase: number;
  rot: number;
  gen: number;
  // derivados por quadro
  cx: number;
  cy: number;
  ang: number;
  cos: number;
  sin: number;
  radius: number;
  env: number;
  disp: number;
  bright: number;
  dissolve: number;
  split: number;
}

interface Flow {
  cl: number;
  ox: number;
  oy: number;
  lobe: number;
  z: number;
  size: number;
  alpha: number;
  f1: number;
  f2: number;
  ph1: number;
  ph2: number;
  tw: number;
  tone: number;
  cap: boolean;
  capAt: number;
  rate: number;
  state: 0 | 1 | 2;
  gen: number;
  q: number;
  q0: number;
  dx0: number;
  dy0: number;
}

interface Trail {
  u: number;
  speed: number;
  off: number;
  wob: number;
  f: number;
  ph: number;
  size: number;
  alpha: number;
  tone: number;
}

interface Orbit {
  r: number;
  rMax: number;
  a: number;
  spin: number;
  fall: number;
  size: number;
  alpha: number;
  ph: number;
  tone: number;
}

/** partícula guiada: nasce à esquerda, é puxada para o caminho e segue a trilha até o portal */
interface Guided {
  curve: number;
  u: number;
  speed: number;
  off0: number;
  wob: number;
  f: number;
  ph: number;
  size: number;
  alpha: number;
  tone: number;
}

/** micropartícula de fundo: segue uma faixa da arte (curve >= 0) ou deriva livre (curve = -1) */
interface Back {
  curve: number;
  u: number;
  speed: number;
  lat: number;
  x: number;
  y: number;
  vx: number;
  amp: number;
  f: number;
  ph: number;
  size: number;
  alpha: number;
  tw: number;
  z: number;
  tone: number;
}

interface Front {
  x: number;
  y: number;
  vx: number;
  amp: number;
  f: number;
  ph: number;
  size: number;
  alpha: number;
  tw: number;
  z: number;
}

/** sprites com falloff curto (pouco bloom individual) em tons de dourado quente */
function makeSprite(core: string, mid: string, edge: string) {
  const size = 64;
  const c = document.createElement("canvas");
  c.width = c.height = size;
  const g = c.getContext("2d");
  if (!g) return c;
  const grad = g.createRadialGradient(size / 2, size / 2, 0, size / 2, size / 2, size / 2);
  grad.addColorStop(0, core);
  grad.addColorStop(0.2, mid);
  grad.addColorStop(0.48, edge);
  grad.addColorStop(1, "rgba(180, 100, 24, 0)");
  g.fillStyle = grad;
  g.fillRect(0, 0, size, size);
  return c;
}

export function HeroParticlesCanvas() {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    const host = canvas?.parentElement;
    const ctx = canvas?.getContext("2d");
    if (!canvas || !host || !ctx) return;

    const reduceQuery = window.matchMedia("(prefers-reduced-motion: reduce)");
    const curves = [buildCurve(FLOW_MAIN, 10), buildCurve(FLOW_LOW, 7), buildCurve(TRAIL, 9)];
    const trailCurve = curves[2];
    const sprites = [
      makeSprite("rgba(255, 208, 118, 1)", "rgba(244, 176, 72, 0.78)", "rgba(206, 128, 34, 0.14)"), // dourado
      makeSprite("rgba(250, 178, 82, 1)", "rgba(230, 140, 44, 0.78)", "rgba(190, 100, 24, 0.14)"), // âmbar
      makeSprite("rgba(255, 240, 208, 1)", "rgba(255, 206, 128, 0.8)", "rgba(230, 150, 50, 0.16)"), // highlight
    ];
    const haze = sprites[1];

    let width = 0;
    let height = 0;
    let dpr = 1;
    let scale = 1;
    let offX = 0;
    let offY = 0;
    let raf = 0;
    let running = false;
    let visible = true;
    let last = 0;
    let clock = 0;
    let budget = 1;
    let ema = 8;
    let slowFor = 0;
    let energy = 0;
    let ptrX = 0;
    let ptrY = 0;
    let ptrTX = 0;
    let ptrTY = 0;
    // zona do texto, em px do canvas
    let tx0 = 0, ty0 = 0, tx1 = 0, ty1 = 0;

    let clusters: Cluster[] = [];
    let flows: Flow[] = [];
    let trails: Trail[] = [];
    let orbits: Orbit[] = [];
    let guided: Guided[] = [];
    let backs: Back[] = [];
    let fronts: Front[] = [];

    const density = () => (width < 700 ? 0.32 : width < 1021 ? 0.6 : 1);

    const resetCluster = (c: Cluster, first: boolean, k: number, total: number) => {
      c.curve = Math.random() < 0.68 ? 0 : 1;
      c.s = first ? -0.08 + (k / total) * 1.15 + rand(-0.03, 0.03) : rand(-0.22, -0.1);
      c.speed = rand(0.05, 0.075);
      c.r0 = rand(48, 92);
      c.phase = rand(0, Math.PI * 2);
      c.period = rand(6.5, 11);
      c.dispPeriod = rand(11, 17);
      c.dispPhase = rand(0, Math.PI * 2);
      c.rot = rand(0, Math.PI * 2);
      c.gen++;
    };

    const populate = () => {
      const d = density();
      const K = 6;
      const M = Math.round(340 * d);
      clusters = [];
      for (let k = 0; k < K; k++) {
        const c = { gen: 0 } as Cluster;
        resetCluster(c, true, k, K);
        c.gen = 0;
        clusters.push(c);
      }
      flows = [];
      for (let m = 0; m < M; m++) {
        for (let k = 0; k < K; k++) {
          const ang = rand(0, Math.PI * 2);
          const rad = Math.sqrt(Math.random());
          const lobe = Math.random() < 0.5 ? -1 : 1;
          flows.push({
            cl: k,
            ox: Math.cos(ang) * rad * 0.62 + gauss() * 0.26 + lobe * 0.16,
            oy: Math.sin(ang) * rad * 0.62 + gauss() * 0.26,
            lobe,
            z: Math.random(),
            size: rand(0.9, 2.0),
            alpha: rand(0.8, 1),
            f1: rand(0.35, 1.1),
            f2: rand(0.35, 1.1),
            ph1: rand(0, Math.PI * 2),
            ph2: rand(0, Math.PI * 2),
            tw: rand(0.6, 1.6),
            tone: pickTone(),
            cap: Math.random() < 0.4,
            capAt: rand(0.4, 0.88),
            rate: Math.random(),
            state: 0,
            gen: 0,
            q: 0, q0: 0, dx0: 0, dy0: 0,
          });
        }
      }
      trails = [];
      for (let i = 0; i < Math.round(380 * d); i++) {
        trails.push({
          u: Math.random(),
          speed: rand(0.06, 0.12),
          off: rand(-10, 10),
          wob: rand(1, 6),
          f: rand(0.6, 1.6),
          ph: rand(0, Math.PI * 2),
          size: rand(0.7, 1.35),
          alpha: rand(0.65, 1),
          tone: pickTone(),
        });
      }
      orbits = [];
      for (let i = 0; i < Math.round(150 * d); i++) {
        const rMax = rand(60, 170);
        orbits.push({
          r: Math.random() * rMax,
          rMax,
          a: rand(0, Math.PI * 2),
          spin: rand(0.5, 1.3) * (Math.random() < 0.5 ? 1 : -1),
          fall: rand(0.12, 0.3),
          size: rand(0.5, 1.0),
          alpha: rand(0.5, 0.95),
          ph: rand(0, Math.PI * 2),
          tone: pickTone(),
        });
      }
      guided = [];
      for (let i = 0; i < Math.round(170 * d); i++) {
        guided.push({
          curve: Math.random() < 0.66 ? 0 : 1,
          u: Math.random(),
          speed: rand(0.055, 0.085),
          off0: gauss() * 85,
          wob: rand(6, 20),
          f: rand(0.5, 1.2),
          ph: rand(0, Math.PI * 2),
          size: rand(0.95, 1.8),
          alpha: rand(0.75, 1),
          tone: pickTone(),
        });
      }
      backs = [];
      for (let i = 0; i < Math.round(560 * d); i++) {
        // ~70% seguem as faixas de partículas que já existem na arte; o resto deriva livre
        const follow = Math.random() < 0.7;
        backs.push({
          curve: follow ? (Math.random() < 0.6 ? 0 : 1) : -1,
          u: Math.random(),
          speed: rand(0.008, 0.02),
          lat: gauss() * 80,
          x: Math.random(), y: Math.random(), vx: rand(0.004, 0.012),
          amp: rand(4, 20), f: rand(0.1, 0.4), ph: rand(0, Math.PI * 2),
          size: rand(0.55, 1.1), alpha: rand(0.3, 0.6), tw: rand(0.4, 1.1), z: Math.random() * 0.4,
          tone: pickTone(),
        });
      }
      fronts = [];
      for (let i = 0; i < Math.max(5, Math.round(16 * d)); i++) {
        fronts.push({
          x: Math.random(), y: Math.random(), vx: rand(0.014, 0.034),
          amp: rand(12, 40), f: rand(0.08, 0.22), ph: rand(0, Math.PI * 2),
          size: rand(4, 9), alpha: rand(0.04, 0.1), tw: rand(0.3, 0.7), z: rand(0.8, 1),
        });
      }
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
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0);

      // mesma regra do object-fit: cover + object-position da imagem de fundo
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
      scale = Math.max(width / ART_W, height / ART_H);
      offX = (width - ART_W * scale) * px;
      offY = (height - ART_H * scale) * py;

      // zona de texto (eyebrow, headline, subtítulo e CTA) para proteger a legibilidade
      const copy = host.parentElement?.querySelector("h1")?.parentElement;
      if (copy) {
        const c = copy.getBoundingClientRect();
        const h = host.getBoundingClientRect();
        tx0 = c.left - h.left - 28;
        ty0 = c.top - h.top - 28;
        tx1 = c.right - h.left + 28;
        ty1 = c.bottom - h.top + 28;
      } else {
        tx0 = ty0 = tx1 = ty1 = -1e4;
      }
      populate();
    };

    /** 1 fora da zona do texto; ~0.3 sobre ela, com transição suave */
    const textFactor = (x: number, y: number) => {
      const dx = Math.max(tx0 - x, 0, x - tx1);
      const dy = Math.max(ty0 - y, 0, y - ty1);
      const d = Math.hypot(dx, dy);
      return 0.3 + 0.7 * smooth(0, 110, d);
    };

    const plot = (x: number, y: number, r: number, a: number, tone: number) => {
      if (a < 0.012) return;
      ctx.globalAlpha = a > 0.9 ? 0.9 : a;
      const s = r * 3;
      ctx.drawImage(sprites[tone], x - s / 2, y - s / 2, s, s);
    };

    const draw = (dt: number) => {
      clock += dt;
      const t = clock;
      const sizeK = Math.max(0.85, Math.min(1.5, scale * 1.15));
      ptrX += (ptrTX - ptrX) * Math.min(1, dt * 3);
      ptrY += (ptrTY - ptrY) * Math.min(1, dt * 3);
      energy = Math.min(1.2, energy * Math.exp(-dt * 1.3));

      ctx.clearRect(0, 0, width, height);
      ctx.globalCompositeOperation = "lighter";

      const portalX = offX + PORTAL[0] * scale;
      const portalY = offY + PORTAL[1] * scale;

      // --- fundo: micropartículas guiadas pelas faixas da arte
      const nBack = Math.ceil(backs.length * budget);
      for (let i = 0; i < nBack; i++) {
        const p = backs[i];
        let x: number;
        let y: number;
        let env = 1;
        if (p.curve >= 0) {
          const cv = curves[p.curve];
          p.u += p.speed * dt;
          if (p.u > 1) { p.u = 0; p.lat = gauss() * 80; }
          sample(cv, p.u * cv.junction);
          const lat = p.lat + Math.sin(t * p.f + p.ph) * p.amp;
          x = offX + (S.x + S.nx * lat) * scale;
          y = offY + (S.y + S.ny * lat) * scale;
          env = smooth(0, 0.1, p.u) * (1 - smooth(0.9, 1, p.u));
        } else {
          p.x += p.vx * dt;
          if (p.x > 1.02) { p.x = -0.02; p.y = Math.random(); }
          x = p.x * width;
          y = p.y * height + Math.sin(t * p.f + p.ph) * p.amp;
        }
        x -= ptrX * (p.z - 0.5) * 20;
        y -= ptrY * (p.z - 0.5) * 14;
        const tw = 0.7 + 0.3 * Math.sin(t * p.tw + p.ph);
        plot(x, y, p.size * sizeK * 1.5, p.alpha * env * tw * textFactor(x, y), p.tone === 2 ? 0 : p.tone);
      }

      // --- massas: estado dos bandos
      for (let k = 0; k < clusters.length; k++) {
        const c = clusters[k];
        c.s += c.speed * dt;
        if (c.s > 1.15) resetCluster(c, false, k, clusters.length);
        const cv = curves[c.curve];
        sample(cv, clamp01(c.s) * cv.junction);
        c.cx = S.x;
        c.cy = S.y;
        c.ang = Math.atan2(-S.nx, S.ny);
        if (c.s > 1) {
          c.cx += Math.cos(c.ang) * (c.s - 1) * 260;
          c.cy += Math.sin(c.ang) * (c.s - 1) * 260;
        }
        const a = c.ang + c.rot * 0.3 + 0.5 * Math.sin(t * 0.3 + c.phase);
        c.cos = Math.cos(a);
        c.sin = Math.sin(a);
        const breathe = 0.5 + 0.5 * Math.sin((t * Math.PI * 2) / c.period + c.phase);
        c.disp = smooth(0.4, 1, 0.5 + 0.5 * Math.sin((t * Math.PI * 2) / c.dispPeriod + c.dispPhase));
        c.dissolve = smooth(0.75, 1.12, c.s);
        c.env = smooth(-0.05, 0.12, c.s) * (1 - smooth(0.8, 1.12, c.s));
        c.radius = c.r0 * (0.55 + 0.6 * breathe) * (1 + 0.9 * c.disp) * (1 + 1.4 * c.dissolve);
        c.bright = 1.15 - 0.5 * breathe - 0.25 * c.disp;
        // o bando se parte em dois lóbulos e volta a se juntar
        c.split = Math.sin(t * 0.35 + c.phase) * (0.35 + 0.5 * c.disp);
        // névoa do bando: o brilho coletivo cresce quando a massa está compacta e ao entrar no caminho
        const gx = offX + c.cx * scale;
        const gy = offY + c.cy * scale;
        const gs = c.radius * scale * 3.4;
        const compact = clamp01(c.bright - 0.35);
        const entering = 1 + 0.9 * smooth(0.5, 0.75, c.s) * (1 - smooth(0.9, 1.05, c.s));
        ctx.globalAlpha = 0.5 * c.env * compact * entering * textFactor(gx, gy);
        ctx.drawImage(haze, gx - gs / 2, gy - gs / 2, gs, gs);
      }

      // --- massas: partículas
      const nFlow = Math.ceil(flows.length * budget);
      for (let i = 0; i < nFlow; i++) {
        const p = flows[i];
        const c = clusters[p.cl];
        if (p.gen !== c.gen && p.state !== 1) {
          p.gen = c.gen;
          p.state = 0;
          p.cap = Math.random() < (c.curve === 0 ? 0.4 : 0.28);
          p.capAt = rand(0.4, 0.88);
        }
        if (p.state === 2) continue;
        const cv = curves[c.curve];
        let x: number;
        let y: number;
        let a: number;
        let r = p.size * sizeK * (0.7 + 0.7 * p.z);

        if (p.state === 0) {
          if (c.env < 0.01) continue;
          // campo coletivo: vizinhos compartilham a mesma onda; só um leve tremor é individual
          const jit = 1.5 + 8 * c.disp + 22 * c.dissolve;
          const waveA = Math.sin(p.oy * 2.4 + t * 0.75 + c.phase) * c.radius * 0.24;
          const waveB = Math.sin(p.ox * 2.0 - t * 0.6 + c.dispPhase) * c.radius * 0.18;
          const squeeze = 1 - 0.28 * Math.sin(p.ox * 1.7 + t * 0.5 + c.phase);
          const lx = (p.ox * squeeze + p.lobe * c.split) * c.radius * 2.0 + waveA;
          const ly = p.oy * squeeze * c.radius + waveB;
          const wx = c.cx + lx * c.cos - ly * c.sin + Math.sin(t * p.f1 + p.ph1) * jit;
          const wy = c.cy + lx * c.sin + ly * c.cos + Math.cos(t * p.f2 + p.ph2) * jit;
          a = p.alpha * c.env * c.bright * 1.25;
          if (p.cap && c.s >= p.capAt && c.s < 1) {
            p.state = 1;
            p.q0 = clamp01(c.s) * cv.junction;
            p.q = p.q0;
            sample(cv, p.q0);
            p.dx0 = wx - S.x;
            p.dy0 = wy - S.y;
          }
          x = offX + wx * scale;
          y = offY + wy * scale;
        } else {
          p.q += dt * (0.05 + 0.09 * p.rate) * (1 + 2.2 * p.q);
          const qb = clamp01((p.q - p.q0) / (1 - p.q0));
          const f = 1 - smooth(0, 1, qb);
          sample(cv, p.q);
          const wx = S.x + p.dx0 * f;
          const wy = S.y + p.dy0 * f;
          a = p.alpha * (0.8 + 0.9 * qb * qb);
          r *= 1 + 0.25 * qb;
          x = offX + wx * scale;
          y = offY + wy * scale;
          if (p.q >= 1) {
            p.state = 2;
            energy += 0.05;
          }
        }
        const tw = 0.78 + 0.22 * Math.sin(t * p.tw + p.ph1);
        x -= ptrX * (p.z - 0.5) * 8;
        y -= ptrY * (p.z - 0.5) * 6;
        plot(x, y, r, a * tw * textFactor(x, y), p.tone);
      }

      // --- caminho dourado
      const nTrail = Math.ceil(trails.length * budget);
      for (let i = 0; i < nTrail; i++) {
        const p = trails[i];
        p.u += p.speed * (1 + 1.4 * p.u * p.u) * dt;
        if (p.u >= 1) {
          p.u = 0;
          p.off = rand(-10, 10);
          energy += 0.008;
        }
        sample(trailCurve, p.u);
        const near = smooth(0.6, 1, p.u);
        const lat = (p.off + Math.sin(t * p.f + p.ph) * p.wob) * (1 - 0.75 * near);
        const x = offX + (S.x + S.nx * lat) * scale;
        const y = offY + (S.y + S.ny * lat) * scale;
        // ondas de brilho que sobem o caminho
        const wave = 0.5 + 0.5 * Math.sin((p.u * 2.2 - t * 0.14) * Math.PI * 2);
        const a = p.alpha * (0.3 + 0.7 * wave) * (1 + 1.0 * near) * smooth(0, 0.12, p.u) * (1 - smooth(0.96, 1, p.u));
        plot(x, y, p.size * sizeK * (1 + 0.35 * near), a * textFactor(x, y), p.tone);
      }

      // --- partículas guiadas: nascem à esquerda, são puxadas para o caminho e seguem até o portal
      const nGuided = Math.ceil(guided.length * budget);
      for (let i = 0; i < nGuided; i++) {
        const p = guided[i];
        const cv = curves[p.curve];
        const j = cv.junction;
        // ritmo: deriva lenta na esquerda, aceleração ao ser puxada e disparada ao se aproximar do portal
        p.u += dt * p.speed * (1 + 1.5 * smooth(0.28, j, p.u)) * (1 + 2.4 * smooth(0.84, 1, p.u));
        if (p.u >= 1) {
          p.u = 0;
          p.off0 = gauss() * 85;
          p.curve = Math.random() < 0.66 ? 0 : 1;
          energy += 0.02;
        }
        const u = p.u;
        const born = smooth(0, 0.09, u);
        const absorbed = 1 - smooth(0.95, 1, u);
        // reforço breve ao entrar na trilha e mais brilho perto do portal
        const capture = Math.exp(-(((u - j) / 0.05) ** 2));
        const gain = (1 + 0.55 * capture + 1.0 * smooth(0.8, 0.97, u)) * born * absorbed;
        const dk = 0.011 * (1 + 1.6 * smooth(0.8, 1, u));
        for (let g = 0; g < 4; g++) {
          const uu = u - g * dk;
          if (uu < 0) break;
          sample(cv, uu);
          // o desvio lateral se fecha até o ponto de captura: as partículas convergem para a trilha
          const pull = smooth(j * 0.45, j, uu);
          const lat = p.off0 * (1 - pull) + Math.sin(t * p.f + p.ph - g * 0.25) * p.wob * (1 - 0.88 * pull);
          const x = offX + (S.x + S.nx * lat) * scale;
          const y = offY + (S.y + S.ny * lat) * scale;
          const tf = 0.55 + 0.45 * ((textFactor(x, y) - 0.3) / 0.7);
          const fade = g === 0 ? 1 : g === 1 ? 0.5 : g === 2 ? 0.28 : 0.14;
          const r = p.size * sizeK * (0.55 + 0.45 * born) * (1 - 0.5 * smooth(0.95, 1, u)) * (g === 0 ? 1 : 0.9 - g * 0.06);
          plot(x, y, r, p.alpha * gain * fade * tf, u > 0.88 && g === 0 ? 2 : p.tone);
        }
      }

      // --- portal: absorção em espiral (micropartículas que se concentram)
      const nOrbit = Math.ceil(orbits.length * budget);
      for (let i = 0; i < nOrbit; i++) {
        const p = orbits[i];
        p.r -= p.fall * (p.rMax * 0.45 + 0.6 * p.r) * dt;
        p.a += p.spin * (0.5 + 70 / (p.r + 40)) * dt;
        if (p.r < 5) {
          p.r = p.rMax;
          p.a = rand(0, Math.PI * 2);
          energy += 0.004;
        }
        const k = p.r / p.rMax;
        const x = portalX + Math.cos(p.a) * p.r * 1.15 * scale;
        const y = portalY + Math.sin(p.a) * p.r * 0.9 * scale;
        const tw = 0.78 + 0.22 * Math.sin(t * 1.3 + p.ph);
        const a = p.alpha * (1 - k) * smooth(0, 0.08, k) * tw * 0.85;
        plot(x, y, p.size * sizeK * (0.8 + 0.5 * (1 - k)), a, p.tone);
      }

      // --- portal: pulso suave e pequeno ganho de luminância a cada chegada (sem esconder a chave)
      const pulse = 0.5 + 0.5 * Math.sin(t * 1.1);
      const e = Math.min(1, 0.2 + 0.16 * pulse + energy * 1.4);
      ctx.globalAlpha = 0.03 + 0.1 * e;
      const hs = (190 + 70 * e) * scale * 2;
      ctx.drawImage(haze, portalX - hs / 2, portalY - hs / 2, hs, hs);

      // --- frente: poucas partículas maiores e desfocadas
      const nFront = Math.ceil(fronts.length * Math.max(budget, 0.6));
      for (let i = 0; i < nFront; i++) {
        const p = fronts[i];
        p.x += p.vx * dt;
        if (p.x > 1.05) { p.x = -0.05; p.y = Math.random(); }
        const x = p.x * width - ptrX * (p.z - 0.5) * 34;
        const y = p.y * height + Math.sin(t * p.f + p.ph) * p.amp - ptrY * (p.z - 0.5) * 22;
        const tw = 0.7 + 0.3 * Math.sin(t * p.tw + p.ph);
        plot(x, y, p.size * sizeK, p.alpha * tw * textFactor(x, y), 1);
      }

      ctx.globalAlpha = 1;
      ctx.globalCompositeOperation = "source-over";
    };

    const frame = (now: number) => {
      if (!running) return;
      const raw = now - last;
      const dt = Math.min(0.05, raw / 1000);
      last = now;
      draw(dt);
      // proteção de performance: se o quadro ficar pesado, reduz a densidade aos poucos
      ema = ema * 0.95 + Math.min(raw, 100) * 0.05;
      slowFor = ema > 26 ? slowFor + dt : 0;
      if (slowFor > 1.5 && budget > 0.35) {
        budget *= 0.8;
        slowFor = 0;
      }
      raf = requestAnimationFrame(frame);
    };

    const start = () => {
      if (running || reduceQuery.matches || !visible || document.hidden) return;
      running = true;
      last = performance.now();
      raf = requestAnimationFrame(frame);
    };
    const stop = () => {
      running = false;
      cancelAnimationFrame(raf);
    };
    const sync = () => {
      if (reduceQuery.matches) {
        stop();
        ctx.clearRect(0, 0, width, height);
      } else {
        start();
      }
    };

    resize();
    sync();

    const ro = new ResizeObserver(() => {
      resize();
      if (!running) ctx.clearRect(0, 0, width, height);
    });
    ro.observe(host);
    const io = new IntersectionObserver(([entry]) => {
      visible = entry.isIntersecting;
      if (visible) start();
      else stop();
    });
    io.observe(host);
    const onVisibility = () => (document.hidden ? stop() : start());
    const onPointer = (e: PointerEvent) => {
      ptrTX = (e.clientX / window.innerWidth) * 2 - 1;
      ptrTY = (e.clientY / window.innerHeight) * 2 - 1;
    };
    document.addEventListener("visibilitychange", onVisibility);
    window.addEventListener("pointermove", onPointer, { passive: true });
    reduceQuery.addEventListener("change", sync);

    return () => {
      stop();
      ro.disconnect();
      io.disconnect();
      document.removeEventListener("visibilitychange", onVisibility);
      window.removeEventListener("pointermove", onPointer);
      reduceQuery.removeEventListener("change", sync);
    };
  }, []);

  return (
    <canvas
      ref={canvasRef}
      aria-hidden="true"
      style={{ position: "absolute", inset: 0, width: "100%", height: "100%", pointerEvents: "none" }}
    />
  );
}
