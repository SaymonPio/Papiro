import Image from "next/image";
import { HomeHeader } from "@/components/home/HomeHeader";
import styles from "./home.module.css";

const features = [
  {
    number: "01",
    title: "Edital decodificado",
    text: "Envie o PDF. O Papiro organiza disciplinas, pesos, requisitos e etapas em um mapa simples de executar.",
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
  ["02", "Envie o edital", "A plataforma transforma o documento em um plano claro de preparação."],
  ["03", "Execute a missão", "Estude, resolva questões, revise e acompanhe sua evolução todos os dias."],
];

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
        </div>

        <div className={styles.heroArtwork} aria-hidden="true">
          <div className={styles.reliefFrame}>
            <Image
              className={styles.reliefImage}
              src="/home-hero-relief.png"
              alt=""
              fill
              priority
              unoptimized
              sizes="(max-width: 700px) calc(100vw - 40px), (max-width: 1020px) calc(100vw - 96px), 520px"
            />
          </div>
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
          {steps.map(([number, title, text]) => (
            <article className="step-card" key={number}>
              <span>{number}</span>
              <h3>{title}</h3>
              <p>{text}</p>
              <i aria-hidden="true">→</i>
            </article>
          ))}
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
        <div className="features-grid">
          {features.map((feature) => (
            <article className="feature-card" key={feature.number}>
              <div className="feature-top">
                <span>{feature.number}</span>
                <small>{feature.tag}</small>
              </div>
              <div className={`feature-icon feature-icon-${feature.number}`} aria-hidden="true">
                <i />
                <b />
              </div>
              <h3>{feature.title}</h3>
              <p>{feature.text}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="taf-section" id="taf" data-header-theme="dark">
        <div className="taf-visual">
          <div className="taf-number">05:18</div>
          <div className="track-lines" aria-hidden="true"><i /><i /><i /></div>
          <div className="taf-chart">
            <small>EXEMPLO ILUSTRATIVO • CORRIDA • 12 MIN</small>
            <strong>2.340 m</strong>
            <span>Meta do edital: 2.400 m</span>
            <div className="chart-line" />
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
          <a className="button" href="#planos">ACOMPANHAR MEU TAF <span>→</span></a>
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
          <a className="button button-full" href="/cadastro">
            CRIAR MINHA CONTA
          </a>
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
              <summary><span>0{index + 1}</span>{question}<b>+</b></summary>
              <p>{answer}</p>
            </details>
          ))}
        </div>
      </section>

      <section className="final-cta" id="acesso" data-header-theme="dark">
        <p className="eyebrow"><span /> PAPIRO</p>
        <h2>O EDITAL É O MESMO.<br /><em>SUA ESTRATÉGIA NÃO.</em></h2>
        <a className="button" href="/cadastro">COMEÇAR MINHA PREPARAÇÃO <span>→</span></a>
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
