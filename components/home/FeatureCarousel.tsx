"use client";

import { useEffect, useRef, useState } from "react";
import { ArrowLeft, ArrowRight, ChartNoAxesColumnIncreasing, CalendarDays, FileText, Footprints } from "lucide-react";
import styles from "../../app/home.module.css";

type Feature = { number: string; title: string; text: string; tag: string };
const icons = [FileText, CalendarDays, ChartNoAxesColumnIncreasing, Footprints];

export function FeatureCarousel({ features }: { features: Feature[] }) {
  const track = useRef<HTMLDivElement>(null);
  const [active, setActive] = useState(0);

  useEffect(() => {
    const element = track.current;
    if (!element) return;
    const sync = () => {
      const cards = Array.from(element.children) as HTMLElement[];
      const nearest = cards.reduce((best, card, index) =>
        Math.abs(card.offsetLeft - element.scrollLeft) < Math.abs(cards[best].offsetLeft - element.scrollLeft) ? index : best, 0);
      setActive(nearest);
    };
    element.addEventListener("scroll", sync, { passive: true });
    const observer = new ResizeObserver(sync);
    observer.observe(element);
    return () => { element.removeEventListener("scroll", sync); observer.disconnect(); };
  }, []);

  const goTo = (index: number) => {
    const element = track.current;
    const card = element?.children[index] as HTMLElement | undefined;
    if (!element || !card) return;
    element.scrollTo({ left: card.offsetLeft, behavior: window.matchMedia("(prefers-reduced-motion: reduce)").matches ? "instant" : "smooth" });
  };

  return (
    <div className={styles.carousel} role="region" aria-roledescription="carrossel" aria-label="Recursos da preparação">
      <div ref={track} id="preparation-carousel" className={styles.carouselTrack} tabIndex={0}
        aria-label="Cards de recursos. Use as setas para navegar."
        onKeyDown={(event) => {
          const next = event.key === "ArrowRight" ? Math.min(active + 1, features.length - 1)
            : event.key === "ArrowLeft" ? Math.max(active - 1, 0)
            : event.key === "Home" ? 0 : event.key === "End" ? features.length - 1 : null;
          if (next !== null) { event.preventDefault(); goTo(next); }
        }}>
        {features.map((feature, index) => {
          const Icon = icons[index];
          return (
            <article key={feature.number} className={`feature-card ${styles.carouselCard} ${active === index ? styles.cardActive : ""}`}
              role="group" aria-roledescription="slide" aria-label={`${index + 1} de ${features.length}: ${feature.title}`}>
              <div className="feature-top"><span>{feature.number}</span><small>{feature.tag}</small></div>
              <Icon className={styles.resourceIcon} size={42} strokeWidth={1.35} aria-hidden="true" />
              <h3>{feature.title}</h3><p>{feature.text}</p>
            </article>
          );
        })}
      </div>
      <div className={styles.carouselControls}>
        <button type="button" aria-label="Recurso anterior" aria-controls="preparation-carousel" disabled={active === 0} onClick={() => goTo(active - 1)}><ArrowLeft size={19} aria-hidden="true" /></button>
        <div className={styles.carouselDots}>
          {features.map((feature, index) => <button key={feature.number} type="button" aria-label={`Mostrar ${feature.title}`} aria-controls="preparation-carousel" aria-current={active === index ? "true" : undefined} onClick={() => goTo(index)}><span /></button>)}
        </div>
        <button type="button" aria-label="Próximo recurso" aria-controls="preparation-carousel" disabled={active === features.length - 1} onClick={() => goTo(active + 1)}><ArrowRight size={19} aria-hidden="true" /></button>
      </div>
      <p className={styles.srOnly} aria-live="polite" aria-atomic="true">Recurso {active + 1} de {features.length}: {features[active].title}</p>
    </div>
  );
}
