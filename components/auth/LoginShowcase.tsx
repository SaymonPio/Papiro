import { InteractiveLoginVideo } from "./InteractiveLoginVideo";
import styles from "../../app/login/login.module.css";

// Coluna direita da tela de login: só posiciona o painel (margens externas, altura) e
// delega toda a mecânica de vídeo/capítulos para InteractiveLoginVideo, que fica
// reutilizável independente de onde for encaixado.
export function LoginShowcase() {
  return (
    <aside className={styles.showcase} aria-label="Apresentação do Papiro">
      <InteractiveLoginVideo />
    </aside>
  );
}
