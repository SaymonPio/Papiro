"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { Menu, X } from "lucide-react";
import styles from "../../app/home.module.css";

type HeaderTheme = "dark" | "light";

const navigation = [
  ["inicio", "Início"],
  ["metodo", "Como funciona"],
  ["recursos", "Recursos"],
  ["taf", "TAF"],
  ["planos", "Planos"],
] as const;

export function HomeHeader() {
  const [headerState, setHeaderState] = useState<{
    theme: HeaderTheme;
    activeSection: string | null;
  }>({ theme: "dark", activeSection: "inicio" });
  const [menuOpen, setMenuOpen] = useState(false);

  useEffect(() => {
    let frame = 0;

    const updateHeader = () => {
      frame = 0;
      const themedSections = Array.from(
        document.querySelectorAll<HTMLElement>("[data-header-theme]"),
      );
      const themeSection = themedSections.find((candidate) => {
        const rect = candidate.getBoundingClientRect();
        return rect.top <= 39 && rect.bottom > 39;
      });
      const probe = document.elementFromPoint(window.innerWidth / 2, 96);
      const section = probe?.closest<HTMLElement>("[data-header-theme]");
      const theme = themeSection?.dataset.headerTheme === "light" ? "light" : "dark";
      const detectedSection = navigation.some(([id]) => id === section?.id)
        ? section?.id ?? "inicio"
        : null;

      setHeaderState((current) => {
        const activeSection = detectedSection;
        if (current.theme === theme && current.activeSection === activeSection) {
          return current;
        }

        return { theme, activeSection };
      });
    };

    const scheduleUpdate = () => {
      if (frame === 0) {
        frame = window.requestAnimationFrame(updateHeader);
      }
    };

    updateHeader();
    window.addEventListener("scroll", scheduleUpdate, { passive: true });
    window.addEventListener("resize", scheduleUpdate);

    return () => {
      window.removeEventListener("scroll", scheduleUpdate);
      window.removeEventListener("resize", scheduleUpdate);
      if (frame !== 0) window.cancelAnimationFrame(frame);
    };
  }, []);

  useEffect(() => {
    if (!menuOpen) return;

    const closeOnEscape = (event: KeyboardEvent) => {
      if (event.key === "Escape") setMenuOpen(false);
    };

    document.addEventListener("keydown", closeOnEscape);
    return () => document.removeEventListener("keydown", closeOnEscape);
  }, [menuOpen]);

  return (
    <header
      className={`${styles.header} ${headerState.theme === "light" ? styles.headerLight : styles.headerDark}`}
      data-theme={headerState.theme}
    >
      <Link className={styles.brand} href="#inicio" aria-label="Papiro, página inicial">
        <span className={styles.brandMark} aria-hidden="true">
          <b>P</b>
        </span>
        <span className={styles.brandCopy}>
          <strong>PAPIRO</strong>
          <small>PREPARAÇÃO POLICIAL</small>
        </span>
      </Link>

      <nav className={styles.navigation} aria-label="Navegação principal">
        {navigation.map(([id, label]) => (
          <a
            className={headerState.activeSection === id ? styles.navigationActive : undefined}
            href={`#${id}`}
            aria-current={headerState.activeSection === id ? "location" : undefined}
            key={id}
          >
            {label}
          </a>
        ))}
      </nav>

      <div className={styles.headerActions}>
        <Link className={styles.loginLink} href="/login">
          Entrar
        </Link>
        <Link className={styles.headerCta} href="/cadastro">
          Começar agora
        </Link>
      </div>

      <button
        className={styles.mobileMenuButton}
        type="button"
        aria-label={menuOpen ? "Fechar menu" : "Abrir menu"}
        aria-controls="mobile-navigation"
        aria-expanded={menuOpen}
        onClick={() => setMenuOpen((open) => !open)}
      >
        {menuOpen ? <X aria-hidden="true" size={18} /> : <Menu aria-hidden="true" size={18} />}
      </button>

      <nav
        className={`${styles.mobileMenu} ${menuOpen ? styles.mobileMenuOpen : ""}`}
        id="mobile-navigation"
        aria-label="Navegação móvel"
      >
        {navigation.map(([id, label]) => (
          <a
            className={headerState.activeSection === id ? styles.mobileMenuActive : undefined}
            href={`#${id}`}
            aria-current={headerState.activeSection === id ? "location" : undefined}
            key={id}
            onClick={() => setMenuOpen(false)}
          >
            {label}
          </a>
        ))}
        <Link href="/login" onClick={() => setMenuOpen(false)}>
          Entrar
        </Link>
      </nav>
    </header>
  );
}
