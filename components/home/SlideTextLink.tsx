import styles from "../../app/home.module.css";

export function SlideTextLink({ href, children, full = false }: { href: string; children: string; full?: boolean }) {
  return (
    <a className={`button ${styles.slideButton}${full ? " button-full" : ""}`} href={href}>
      <span className={styles.slideViewport}>
        <span className={styles.slideText}>{children}</span>
        <span className={styles.slideDuplicate} aria-hidden="true">{children}</span>
      </span>
      <span aria-hidden="true">→</span>
    </a>
  );
}
