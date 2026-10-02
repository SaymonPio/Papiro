"use client";

import { useEffect, useRef, useState } from "react";
import { Pause, Play, Volume2, VolumeX } from "lucide-react";
import {
  LOGIN_CHAPTERS,
  LOGIN_VIDEO_FALLBACK_POSTER,
  LOGIN_VIDEO_SRC,
} from "./loginChapters";
import styles from "../../app/login/login.module.css";

function chapterIndexForTime(time: number): number {
  let index = 0;
  for (let i = 0; i < LOGIN_CHAPTERS.length; i++) {
    if (time >= LOGIN_CHAPTERS[i].start) index = i;
  }
  return index;
}

export function InteractiveLoginVideo() {
  const video = useRef<HTMLVideoElement>(null);
  const progressFill = useRef<HTMLDivElement>(null);
  const activeChapterRef = useRef(0);

  const [activeChapter, setActiveChapter] = useState(0);
  const [isPlaying, setIsPlaying] = useState(true);
  const [isMuted, setIsMuted] = useState(true);
  const [hasError, setHasError] = useState(false);

  // Progresso e capítulo ativo são atualizados aqui, fora do ciclo de render do React na
  // parte que importa performance: a barra de progresso é escrita direto no DOM via ref
  // (sem setState por frame); só o índice do capítulo ativo vira estado — e só quando
  // realmente muda — porque alimenta o aria-current/estilo dos botões, que troca raramente.
  const onTimeUpdate = () => {
    const el = video.current;
    if (!el || !el.duration) return;
    const pct = Math.min(100, (el.currentTime / el.duration) * 100);
    if (progressFill.current) progressFill.current.style.width = `${pct}%`;

    const index = chapterIndexForTime(el.currentTime);
    if (index !== activeChapterRef.current) {
      activeChapterRef.current = index;
      setActiveChapter(index);
    }
  };

  const goToChapter = (index: number) => {
    const el = video.current;
    activeChapterRef.current = index;
    setActiveChapter(index);
    if (!el || hasError) return;
    el.currentTime = LOGIN_CHAPTERS[index].start;
    el.play().catch(() => {});
  };

  const togglePlay = () => {
    const el = video.current;
    if (!el) return;
    if (el.paused) el.play().catch(() => {});
    else el.pause();
  };

  const toggleMute = () => {
    const el = video.current;
    if (!el) return;
    el.muted = !el.muted;
    setIsMuted(el.muted);
  };

  // play/pause/error são eventos de mídia que não fazem bubble — por isso são anexados
  // diretamente no elemento via addEventListener (não via prop onError/onPlay do React),
  // que depende de delegação e não os captura de forma confiável neste projeto. O
  // navegador já começa a carregar o `src` durante o commit síncrono, antes deste efeito
  // rodar — então num 404 muito rápido (ex.: localhost) o erro pode disparar e terminar
  // antes do addEventListener ser anexado; por isso também checamos `el.error`
  // sincronamente logo abaixo, cobrindo o caso em que o erro já aconteceu.
  useEffect(() => {
    const el = video.current;
    if (!el) return;
    const onPlay = () => setIsPlaying(true);
    const onPause = () => setIsPlaying(false);
    const onError = () => setHasError(true);
    el.addEventListener("play", onPlay);
    el.addEventListener("pause", onPause);
    el.addEventListener("error", onError);
    if (el.error) setHasError(true);
    return () => {
      el.removeEventListener("play", onPlay);
      el.removeEventListener("pause", onPause);
      el.removeEventListener("error", onError);
    };
  }, []);

  const chapter = LOGIN_CHAPTERS[activeChapter];

  return (
    <div className={styles.showcasePanel}>
      {!hasError ? (
        <video
          ref={video}
          className={styles.showcaseVideo}
          src={LOGIN_VIDEO_SRC}
          poster={LOGIN_VIDEO_FALLBACK_POSTER}
          autoPlay
          muted
          loop
          playsInline
          preload="metadata"
          onTimeUpdate={onTimeUpdate}
        />
      ) : (
        // Fallback: o vídeo final ainda não existe (ou falhou ao carregar). A experiência
        // continua inteira — capítulos e headline seguem navegáveis/legíveis — só não há
        // playback real para controlar.
        <div
          className={styles.showcaseFallback}
          style={{ backgroundImage: `url(${LOGIN_VIDEO_FALLBACK_POSTER})` }}
          aria-hidden="true"
        />
      )}

      <div className={styles.showcaseScrim} aria-hidden="true" />

      <div className={styles.showcaseHeadline} key={chapter.id}>
        <span>{chapter.headline[0]}</span>
        <span>{chapter.headline[1]}</span>
      </div>

      <div className={styles.showcaseControls}>
        <div className={styles.showcaseProgress} aria-hidden="true">
          <div ref={progressFill} className={styles.showcaseProgressFill} />
        </div>

        <div className={styles.showcaseBar}>
          {!hasError && (
            <button
              type="button"
              className={styles.showcaseIconButton}
              onClick={togglePlay}
              aria-label={isPlaying ? "Pausar vídeo" : "Reproduzir vídeo"}
            >
              {isPlaying ? <Pause size={16} aria-hidden="true" /> : <Play size={16} aria-hidden="true" />}
            </button>
          )}

          <nav className={styles.showcaseChapters} aria-label="Capítulos do vídeo">
            {LOGIN_CHAPTERS.map((item, index) => (
              <button
                key={item.id}
                type="button"
                className={styles.showcaseChapter}
                aria-current={index === activeChapter ? "true" : undefined}
                onClick={() => goToChapter(index)}
              >
                <span>{String(index + 1).padStart(2, "0")}</span>
                {item.label}
              </button>
            ))}
          </nav>

          {!hasError && (
            <button
              type="button"
              className={styles.showcaseIconButton}
              onClick={toggleMute}
              aria-label={isMuted ? "Ativar som" : "Silenciar vídeo"}
            >
              {isMuted ? <VolumeX size={16} aria-hidden="true" /> : <Volume2 size={16} aria-hidden="true" />}
            </button>
          )}
        </div>
      </div>
    </div>
  );
}
