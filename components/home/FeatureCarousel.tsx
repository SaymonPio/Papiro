"use client";

import { useEffect, useRef, type PointerEvent as ReactPointerEvent, type MouseEvent as ReactMouseEvent } from "react";
import { ChartNoAxesColumnIncreasing, CalendarDays, FileText, Footprints } from "lucide-react";
import styles from "../../app/home.module.css";

type Feature = { number: string; title: string; text: string; tag: string };
const icons = [FileText, CalendarDays, ChartNoAxesColumnIncreasing, Footprints];

// Velocidade alvo do marquee, em px/s. A duração da animação é calculada a partir da
// largura real de um conjunto de cards (medida no DOM), então a velocidade PERCEBIDA fica
// aproximadamente igual em qualquer largura de tela — não é uma duração fixa em segundos.
const MARQUEE_SPEED_PX_S = 46;
const MARQUEE_MIN_S = 18;
const MARQUEE_MAX_S = 60;

// Deslocamento mínimo (px) para diferenciar um clique de um arraste real.
const DRAG_THRESHOLD_PX = 6;

type DragState = {
  pointerId: number;
  anim: Animation;
  startX: number;
  baseTime: number;
  durationMs: number;
  distancePx: number;
  dragging: boolean;
};

function Card({ feature, index, clone }: { feature: Feature; index: number; clone?: boolean }) {
  const Icon = icons[index];
  return (
    <article
      className={`feature-card ${styles.carouselCard}`}
      aria-hidden={clone ? "true" : undefined}
    >
      <div className="feature-top"><span>{feature.number}</span><small>{feature.tag}</small></div>
      <Icon className={styles.resourceIcon} size={42} strokeWidth={1.35} aria-hidden="true" />
      <h3>{feature.title}</h3><p>{feature.text}</p>
    </article>
  );
}

export function FeatureCarousel({ features }: { features: Feature[] }) {
  const track = useRef<HTMLDivElement>(null);
  const distanceRef = useRef(0);
  const dragRef = useRef<DragState | null>(null);
  const justDraggedRef = useRef(false);

  useEffect(() => {
    const element = track.current;
    if (!element) return;

    // A animação (translate3d via @keyframes) já roda com uma duração-padrão só de CSS;
    // aqui recalculamos duas coisas a partir da largura real dos cards (montagem + resize):
    // 1) --marquee-distance: a distância exata (em px) até o primeiro card do conjunto
    //    duplicado. Não é 50% do track porque o `gap` do flexbox faz a costura entre os dois
    //    conjuntos não ser simetricamente metade da largura total — usar -50% deixaria um
    //    salto de meio-gap a cada reinício do loop. Medindo o offset real do clone, o
    //    reinício cai exatamente onde o primeiro conjunto começou, sem salto.
    // 2) --marquee-duration: mantém a velocidade percebida ~constante em qualquer largura.
    // Isso não move nada por quadro — só ajusta variáveis CSS ocasionalmente; o movimento
    // em si continua no compositor. distanceRef guarda o mesmo valor em px para o drag.
    const recalc = () => {
      const cards = Array.from(element.children) as HTMLElement[];
      const half = Math.floor(cards.length / 2);
      if (half <= 0) return;
      const first = cards[0];
      const firstOfSecondSet = cards[half];
      const distance = firstOfSecondSet.offsetLeft - first.offsetLeft;
      if (distance <= 0) return;
      const seconds = Math.min(MARQUEE_MAX_S, Math.max(MARQUEE_MIN_S, distance / MARQUEE_SPEED_PX_S));
      element.style.setProperty("--marquee-distance", `-${distance}px`);
      element.style.setProperty("--marquee-duration", `${seconds.toFixed(2)}s`);
      distanceRef.current = distance;
    };

    recalc();
    const observer = new ResizeObserver(recalc);
    observer.observe(element);
    return () => observer.disconnect();
  }, [features]);

  // Drag manual sobre a animação existente (Web Animations API), sem estado React por
  // frame: no pointerdown guardamos a animação e a posição inicial; só ao ultrapassar um
  // pequeno threshold é que ela é pausada (currentTime congelado) e passa a ser controlada
  // diretamente pelo deslocamento do ponteiro; no pointerup ela retoma o autoplay exatamente
  // de onde parou (mesmo currentTime, mesma direção), sem salto. O tempo é sempre "wrapped"
  // dentro de [0, duration) — como o loop já não tem costura, dá pra arrastar indefinidamente.
  const onPointerDown = (e: ReactPointerEvent<HTMLDivElement>) => {
    if (e.pointerType === "mouse" && e.button !== 0) return;
    const element = track.current;
    if (!element) return;
    const anim = element.getAnimations()[0];
    if (!anim) return; // reduced-motion: sem animação ativa, não há o que arrastar aqui
    element.setPointerCapture(e.pointerId);
    dragRef.current = {
      pointerId: e.pointerId,
      anim,
      startX: e.clientX,
      baseTime: 0,
      durationMs: 0,
      distancePx: distanceRef.current,
      dragging: false,
    };
  };

  const onPointerMove = (e: ReactPointerEvent<HTMLDivElement>) => {
    const drag = dragRef.current;
    if (!drag || e.pointerId !== drag.pointerId) return;

    if (!drag.dragging) {
      if (Math.abs(e.clientX - drag.startX) < DRAG_THRESHOLD_PX) return;
      drag.dragging = true;
      drag.anim.pause();
      drag.baseTime = typeof drag.anim.currentTime === "number" ? drag.anim.currentTime : 0;
      drag.durationMs = Number(drag.anim.effect?.getTiming().duration) || 0;
      drag.startX = e.clientX; // rebaseline: o delta passa a contar a partir do engajamento do drag
      track.current?.classList.add(styles.carouselDragging);
      return;
    }

    if (drag.durationMs <= 0 || drag.distancePx <= 0) return;
    const deltaX = e.clientX - drag.startX;
    // arrastar para a esquerda (deltaX negativo) deve avançar o tempo da animação (cards
    // seguem para a esquerda, mesmo sentido do autoplay) — daí o sinal invertido.
    const deltaTime = -(deltaX / drag.distancePx) * drag.durationMs;
    let t = (drag.baseTime + deltaTime) % drag.durationMs;
    if (t < 0) t += drag.durationMs;
    drag.anim.currentTime = t;
  };

  const endDrag = (e: ReactPointerEvent<HTMLDivElement>) => {
    const drag = dragRef.current;
    if (!drag || e.pointerId !== drag.pointerId) return;
    const element = track.current;
    if (element?.hasPointerCapture(e.pointerId)) element.releasePointerCapture(e.pointerId);
    if (drag.dragging) {
      drag.anim.play();
      element?.classList.remove(styles.carouselDragging);
      justDraggedRef.current = true;
    }
    dragRef.current = null;
  };

  // Evita que um clique acidental dispare logo após um arraste real (defensivo — os cards
  // hoje não têm links/botões internos, mas isso preserva o comportamento se algum dia tiverem).
  const onClickCapture = (e: ReactMouseEvent<HTMLDivElement>) => {
    if (justDraggedRef.current) {
      justDraggedRef.current = false;
      e.preventDefault();
      e.stopPropagation();
    }
  };

  return (
    <div className={styles.carousel} role="region" aria-label="Recursos da preparação">
      <div
        ref={track}
        className={styles.carouselTrack}
        onPointerDown={onPointerDown}
        onPointerMove={onPointerMove}
        onPointerUp={endDrag}
        onPointerCancel={endDrag}
        onClickCapture={onClickCapture}
      >
        {features.map((feature, index) => (
          <Card key={`a-${feature.number}`} feature={feature} index={index} />
        ))}
        {/* Conjunto duplicado: dá continuidade ao loop (o track percorre exatamente a
            largura de um conjunto e "reinicia" dentro do duplicado, sem salto visível).
            Oculto de leitores de tela para não duplicar o conteúdo semanticamente. */}
        {features.map((feature, index) => (
          <Card key={`b-${feature.number}`} feature={feature} index={index} clone />
        ))}
      </div>
    </div>
  );
}
