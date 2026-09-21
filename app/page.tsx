import Image from "next/image";
import { FeatureCarousel } from "@/components/home/FeatureCarousel";
import { HeroParticlesCanvas } from "@/components/home/HeroParticlesCanvas";
import { SlideTextLink } from "@/components/home/SlideTextLink";
import { Target, CalendarDays, ChartNoAxesColumnIncreasing } from "lucide-react";
import { HomeHeader } from "@/components/home/HomeHeader";
import styles from "./home.module.css";

const features = [
  {
    number: "01",
    title: "Edital organizado",
    text: "O Papiro organiza o conteúdo do concurso, prioridades e etapas em uma jornada clara de execução.",
    tag: "ANÁLISE COM IA",
  },
  {
    number: "02",
    title: "Rota diária de estudos",
    text: "Um cronograma que se ajusta ao seu tempo, ao seu desempenho e à data da prova.",
    tag: "PLANO ADAPTATIVO",
  },
  {
    number: "03",
    title: "Simulado sob controle",
    text: "Registre respostas, identifique seus erros e transforme cada falha em uma revisão objetiva.",
    tag: "DESEMPENHO REAL",
  },
  {
    number: "04",
    title: "Preparação para o TAF",
    text: "Acompanhe corrida, barra, flexão, abdominal e os índices específicos do seu edital.",
    tag: "EVOLUÇÃO FÍSICA",
  },
];

const steps = [
  ["01", "Escolha seu alvo", "Guarda Municipal ou Polícia Militar, cargo, banca e data da prova."],
  ["02", "Receba sua rota de estudos", "O Papiro organiza sua preparação em um plano claro e executável."],
  ["03", "Execute a missão", "Estude, resolva questões, revise e acompanhe sua evolução todos os dias."],
];

const stepIcons = [Target, CalendarDays, ChartNoAxesColumnIncreasing];

const faq = [
  [
    "O Papiro serve para qualquer concurso?",
    "O foco é exclusivo em Guarda Municipal e Polícia Militar. Assim, toda a experiência, os conteúdos e as análises são pensados para essas duas carreiras.",
  ],
  [
    "A plataforma cria meu cronograma?",
    "Sim. O plano considera a data da prova, sua disponibilidade, o peso das disciplinas e o desempenho registrado nas questões.",
  ],
  [
    "Posso acompanhar o TAF?",
    "Sim. Você poderá cadastrar os índices do edital e acompanhar sua evolução em corrida, barra, flexão, abdominal e outros exercícios exigidos.",
  ],
  [
    "O Papiro corrige simulados?",
    "A proposta inclui análise de provas e simulados, comparação com gabarito, relatório por disciplina e criação automática de revisões a partir dos erros.",
  ],
];

export default function Home() {
  return (
    <main className={styles.home}>
      <HomeHeader />

      <section className={styles.hero} id="inicio" data-header-theme="dark">
        <div className={styles.heroCopy}>
          <p className={styles.eyebrow}>
            FOCO • DISCIPLINA • APROVAÇÃO
          </p>
          <h1 className={styles.heroTitle}>
            SUA FARDA
            <br />
            COMEÇA <em>AQUI.</em>
          </h1>
          <p className={styles.heroLead}>
            Transforme seu edital em uma estratégia de aprovação. Um plano
            inteligente para quem tem como alvo a <strong>Guarda Municipal</strong> e a{" "}
            <strong>Polícia Militar</strong>.
          </p>
          <div className={styles.heroAction}><SlideTextLink href="/cadastro">COMECE SUA PREPARAÇÃO AGORA</SlideTextLink></div>
        </div>

        <div className={styles.heroArtwork} aria-hidden="true">
          <Image className={styles.heroBackground} src="/home-hero-particles.webp" alt="" fill priority unoptimized sizes="100vw" />
          <HeroParticlesCanvas />
        </div>

        <div className={styles.careerStrip} aria-label="Principais recursos">
          <div>
            <span>Edital com IA</span>
            <i aria-hidden="true" />
            <span>Cronograma inteligente</span>
            <i aria-hidden="true" />
            <span>Questões e simulados</span>
            <i aria-hidden="true" />
            <span>Acompanhamento do TAF</span>
          </div>
        </div>
      </section>

      <section className="section section-light" id="metodo" data-header-theme="light">
        <div className="section-heading">
          <div>
            <p className="eyebrow dark"><span /> MÉTODO PAPIRO</p>
            <h2>MENOS DÚVIDA.<br /><em>MAIS DIREÇÃO.</em></h2>
          </div>
          <p>
            Você não precisa de mais conteúdo solto. Precisa saber o que estudar,
            quando revisar e onde melhorar. O Papiro organiza a missão.
          </p>
        </div>
        <div className="steps-grid">
          {steps.map(([number, title, text], index) => {
            const Icon = stepIcons[index];
            return (
            <article className="step-card" key={number}>
              <span>{number}</span>
              <Icon className={styles.stepIcon} size={34} strokeWidth={1.5} aria-hidden="true" />
              <h3>{title}</h3>
              <p>{text}</p>
              <i aria-hidden="true">→</i>
            </article>
          ); })}
        </div>
      </section>

      <section className="section section-dark" id="recursos" data-header-theme="dark">
        <div className="section-heading inverse">
          <div>
            <p className="eyebrow"><span /> TUDO EM UM SÓ LUGAR</p>
            <h2>PREPARAÇÃO<br /><em>SEM PONTO CEGO.</em></h2>
          </div>
          <p>
            Uma visão completa da sua preparação teórica, do seu desempenho e
            da evolução física até o dia da prova.
          </p>
        </div>
        <FeatureCarousel features={features} />
      </section>

      <section className="taf-section" id="taf" data-header-theme="dark">
        <div className="taf-visual">
          <Image className={styles.tafBackground} src="/home-taf-runner.webp" alt="" fill unoptimized sizes="(max-width: 760px) 100vw, 50vw" />
          <div className="taf-number" aria-hidden="true">05:18</div>
          <div className="track-lines" aria-hidden="true"><i /><i /><i /></div>
          <div className="taf-chart">
            <small>EXEMPLO ILUSTRATIVO • CORRIDA • 12 MIN</small>
            <strong>2.340 m</strong>
            <span>Meta do edital: 2.400 m</span>
            <svg className={styles.tafGraph} viewBox="0 0 360 70" aria-hidden="true" focusable="false">
              <path d="M0 61 L42 55 L83 59 L126 42 L168 48 L213 27 L260 33 L305 12 L360 3 L360 70 L0 70Z" fill="currentColor" opacity=".1" />
              <path d="M0 61 L42 55 L83 59 L126 42 L168 48 L213 27 L260 33 L305 12 L360 3" fill="none" stroke="currentColor" strokeWidth="2" />
            </svg>
          </div>
        </div>
        <div className="taf-copy">
          <p className="eyebrow"><span /> ALÉM DA PROVA OBJETIVA</p>
          <h2>O TAF TAMBÉM<br />FAZ PARTE DA <em>MISSÃO.</em></h2>
          <p>
            Registre seus resultados, acompanhe a evolução e veja exatamente
            quanto falta para alcançar cada índice exigido no edital.
          </p>
          <ul>
            <li><span>✓</span> Metas específicas por concurso</li>
            <li><span>✓</span> Histórico de corrida, barra, flexão e abdominal</li>
            <li><span>✓</span> Alertas para índices abaixo do mínimo</li>
          </ul>
          <SlideTextLink href="#planos">ACOMPANHAR MEU TAF</SlideTextLink>
        </div>
      </section>

      <section className="section section-light pricing" id="planos" data-header-theme="light">
        <div className="pricing-heading">
          <p className="eyebrow dark"><span /> SEU PRÓXIMO PASSO</p>
          <h2>COMECE A CONSTRUIR<br />SUA <em>APROVAÇÃO.</em></h2>
          <p>Crie sua conta e comece a organizar sua preparação no Papiro.</p>
        </div>
        <div className="plan-card">
          <div className="plan-badge">CADASTRO ABERTO</div>
          <div className="plan-title">
            <span className="brand-mark">P</span>
            <div>
              <small>PLANO</small>
              <strong>FUNDADOR</strong>
            </div>
          </div>
          <p>Seja um dos primeiros candidatos a testar a plataforma e ajudar a construir o Papiro.</p>
          <ul>
            <li><span>✓</span> Cronograma inteligente</li>
            <li><span>✓</span> Dashboard de desempenho</li>
            <li><span>✓</span> Controle de questões e simulados</li>
            <li><span>✓</span> Acompanhamento do TAF</li>
          </ul>
          <SlideTextLink href="/cadastro" full>CRIAR MINHA CONTA</SlideTextLink>
          <small className="plan-note">CRIE SUA CONTA E COMECE A CONFIGURAR SEU OBJETIVO</small>
        </div>
      </section>

      <section className="faq-section" data-header-theme="dark">
        <div>
          <p className="eyebrow"><span /> DÚVIDAS FREQUENTES</p>
          <h2>ANTES DE<br /><em>COMEÇAR.</em></h2>
        </div>
        <div className="faq-list">
          {faq.map(([question, answer], index) => (
            <details key={question}>
              <summary><span>0{index + 1}</span>{question}<b aria-hidden="true">+</b></summary>
              <p>{answer}</p>
            </details>
          ))}
        </div>
      </section>

      <section className="final-cta" id="acesso" data-header-theme="dark">
        <p className="eyebrow"><span /> PAPIRO</p>
        <h2>O EDITAL É O MESMO.<br /><em>SUA ESTRATÉGIA NÃO.</em></h2>
        <SlideTextLink href="/cadastro">COMEÇAR MINHA PREPARAÇÃO</SlideTextLink>
      </section>

      <section className="whatsapp-strip" aria-label="Contato pelo WhatsApp" data-header-theme="dark">
        <div className="whatsapp-intro">
          <span className="whatsapp-icon" aria-hidden="true">W</span>
          <div>
            <small>PRECISA DE AJUDA?</small>
            <strong>FALE COM A EQUIPE PAPIRO</strong>
          </div>
        </div>
        <p>Atendimento rápido para dúvidas sobre a plataforma e sua preparação.</p>
        <span className="whatsapp-demo" aria-disabled="true">
          <span>CANAL EM PREPARAÇÃO</span>
          <small>O CONTATO OFICIAL SERÁ DIVULGADO AQUI</small>
        </span>
      </section>

      <footer data-header-theme="dark">
        <a className="brand" href="#inicio">
          <span className="brand-mark">P</span>
          <span><strong>PAPIRO</strong><small>PREPARAÇÃO POLICIAL</small></span>
        </a>
        <p>Preparação inteligente para Guarda Municipal e Polícia Militar.</p>
        <div>
          <a href="#recursos">Recursos</a>
          <a href="#taf">TAF</a>
          <a href="#planos">Planos</a>
        </div>
        <small>© 2026 Papiro. Todos os direitos reservados.</small>
      </footer>
    </main>
  );
}
