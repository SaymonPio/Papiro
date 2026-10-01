"use client";

import { useEffect, useRef } from "react";
import styles from "../../app/home.module.css";

// Velocidade alvo do marquee da faixa, em px/s. A duração real é recalculada a partir da
// distância real (medida no DOM) até o primeiro item do grupo duplicado, então a
// velocidade percebida fica ~constante em qualquer largura de tela.
const STRIP_SPEED_PX_S = 65;
const STRIP_MIN_S = 10;
const STRIP_MAX_S = 20;

function Item({ text, clone }: { text: string; clone?: boolean }) {
  return (
    <span className={styles.careerStripItem} aria-hidden={clone ? "true" : undefined}>
      {text}
      <i aria-hidden="true" />
    </span>
  );
}

export function CareerStrip({ items }: { items: string[] }) {
  const track = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const element = track.current;
    if (!element) return;

    // Mesma lógica do FeatureCarousel: a distância até o primeiro item do grupo
    // duplicado (não 50%) evita o meio-gap de salto no reinício, já que o `gap` do
    // flexbox torna a largura total assimétrica em relação a 2x um grupo.
    const recalc = () => {
      const nodes = Array.from(element.children) as HTMLElement[];
      const half = Math.floor(nodes.length / 2);
      if (half <= 0) return;
      const first = nodes[0];
      const firstOfSecondGroup = nodes[half];
      const distance = firstOfSecondGroup.offsetLeft - first.offsetLeft;
      if (distance <= 0) return;
      const seconds = Math.min(STRIP_MAX_S, Math.max(STRIP_MIN_S, distance / STRIP_SPEED_PX_S));
      element.style.setProperty("--strip-distance", `-${distance}px`);
      element.style.setProperty("--strip-duration", `${seconds.toFixed(2)}s`);
    };

    recalc();
    const observer = new ResizeObserver(recalc);
    observer.observe(element);
    return () => observer.disconnect();
  }, [items]);

  return (
    <div className={styles.careerStrip} aria-label="Principais recursos">
      <div ref={track} className={styles.careerStripTrack}>
        {items.map((text) => (
          <Item key={`a-${text}`} text={text} />
        ))}
        {items.map((text) => (
          <Item key={`b-${text}`} text={text} clone />
        ))}
      </div>
    </div>
  );
}
