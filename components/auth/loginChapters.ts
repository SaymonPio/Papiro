// Caminho do vídeo final da tela de login. O arquivo ainda não existe no projeto —
// ver o fallback (poster + gradiente) em InteractiveLoginVideo.tsx, que assume o controle
// automaticamente via onError caso este caminho não resolva. Quando o vídeo definitivo
// estiver pronto, basta colocá-lo em public/videos/login-papiro.mp4 (criando a pasta
// public/videos/) — nenhuma outra alteração de código é necessária.
export const LOGIN_VIDEO_SRC = "/videos/login-papiro.mp4";

// Imagem usada como poster do <video> e também como fallback visual completo (fundo +
// leitura dos capítulos) caso o vídeo não exista ou falhe ao carregar. Reaproveita a arte
// já aprovada do hero da landing — mesma identidade visual, zero asset novo.
export const LOGIN_VIDEO_FALLBACK_POSTER = "/home-hero-particles.webp";

export type LoginChapter = {
  id: string;
  label: string;
  /** Timestamp (segundos) onde o capítulo começa no vídeo final. Temporário — ajustar
   *  quando o vídeo definitivo for adicionado. */
  start: number;
  headline: [string, string];
};

// Timestamps ajustados à duração real do clipe placeholder atual (public/videos/
// login-papiro.mp4, ~6s, gerado via Higgsfield/Veo 3.1 Lite como demonstração). Quando o
// vídeo final (mais longo, com cortes reais por cena) for adicionado, redistribuir esses
// `start` para os timestamps reais de cada cena — a estrutura/UI não muda, só os valores.
export const LOGIN_CHAPTERS: LoginChapter[] = [
  { id: "preparacao", label: "Preparação", start: 0, headline: ["DISCIPLINA HOJE.", "APROVAÇÃO AMANHÃ."] },
  { id: "plano", label: "Plano", start: 1.2, headline: ["SEU ESTUDO", "COM DIREÇÃO."] },
  { id: "questoes", label: "Questões", start: 2.4, headline: ["TREINE O QUE", "REALMENTE CAI."] },
  { id: "evolucao", label: "Evolução", start: 3.6, headline: ["SAIBA ONDE VOCÊ", "ESTÁ MELHORANDO."] },
  { id: "aprovacao", label: "Aprovação", start: 4.8, headline: ["MENOS DÚVIDA.", "MAIS DIREÇÃO."] },
];
