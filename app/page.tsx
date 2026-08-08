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
  ["01", "Escolha seu alvo", "Guarda Municipal, Polícia Militar ou Polícia Civil, cargo, banca e data da prova."],
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
    <main>
      <header className="site-header">
        <a className="brand" href="#inicio" aria-label="Papiro, página inicial">
          <span className="brand-mark" aria-hidden="true">
            P
          </span>
          <span>
            <strong>PAPIRO</strong>
            <small>PREPARAÇÃO POLICIAL</small>
          </span>
        </a>
        <nav aria-label="Navegação principal">
          <a href="#metodo">Como funciona</a>
          <a href="#recursos">Recursos</a>
          <a href="#taf">TAF</a>
          <a href="#planos">Planos</a>
        </nav>
        <div className="header-actions">
          <a className="login-link" href="/login">
            Entrar
          </a>
          <a className="button button-small" href="/cadastro">
            Começar agora
          </a>
        </div>
      </header>

      <section className="hero" id="inicio">
        <div className="hero-grid" aria-hidden="true" />
        <div className="hero-copy">
          <p className="eyebrow">
            <span /> FOCO • DISCIPLINA • APROVAÇÃO
          </p>
          <h1>
            SUA FARDA
            <br />
            COMEÇA <em>AQUI.</em>
          </h1>
          <p className="hero-lead">
  Transforme seu edital em uma estratégia de aprovação. Um plano
  inteligente para quem tem como alvo a{" "}
  <strong>Guarda Municipal</strong>, a{" "}
  <strong>Polícia Militar</strong> e a{" "}
  <strong>Polícia Civil</strong>.
</p>
          <div className="hero-actions">
            <a className="button" href="/cadastro">
              MONTAR MEU PLANO <span aria-hidden="true">→</span>
            </a>
            <a className="text-action" href="#metodo">
              CONHECER O MÉTODO <span aria-hidden="true">↓</span>
            </a>
          </div>
          <div className="trust-row">
            <div className="avatars" aria-hidden="true">
              <span>GM</span>
              <span>PM</span>
              <span>PC</span>
              <span>+</span>
            </div>
            <p>
              <strong>Preparação centralizada</strong>
              <br />
              Da primeira questão ao dia do TAF
            </p>
          </div>
        </div>

        <div className="hero-visual" aria-label="Exemplo do painel de desempenho do Papiro">
          <div className="radar-ring ring-one" />
          <div className="radar-ring ring-two" />
          <div className="dashboard-card">
            <div className="dash-top">
              <div>
                <small>MISSÃO ATUAL</small>
                <strong>GM • Porto Alegre</strong>
              </div>
              <span className="live-dot">PLANO ATIVO</span>
            </div>
            <div className="dash-progress">
              <div className="progress-main">
                <small>PROGRESSO DO EDITAL</small>
                <strong>68%</strong>
                <div className="progress-track">
                  <span />
                </div>
              </div>
              <div className="days-left">
                <strong>43</strong>
                <small>DIAS PARA A PROVA</small>
              </div>
            </div>
            <div className="today-plan">
              <div className="section-label">
                <span>PLANO DE HOJE</span>
                <small>2H 30MIN</small>
              </div>
              <div className="task done">
                <span className="check">✓</span>
                <div>
                  <strong>Direito Constitucional</strong>
                  <small>Direitos e garantias fundamentais</small>
                </div>
                <b>45 min</b>
              </div>
              <div className="task active">
                <span className="check">02</span>
                <div>
                  <strong>Legislação Especial</strong>
                  <small>Estatuto do Desarmamento</small>
                </div>
                <b>55 min</b>
              </div>
              <div className="task">
                <span className="check">03</span>
                <div>
                  <strong>Bloco de questões</strong>
                  <small>30 questões • Fundatec</small>
                </div>
                <b>50 min</b>
              </div>
            </div>
            <div className="dash-footer">
              <span>
                <small>APROVEITAMENTO</small>
                <strong>82%</strong>
              </span>
              <span>
                <small>QUESTÕES</small>
                <strong>1.284</strong>
              </span>
              <span>
                <small>SEQUÊNCIA</small>
                <strong>12 dias</strong>
              </span>
            </div>
          </div>
          <div className="floating-badge">
            <span>↑</span>
            <div>
              <small>EVOLUÇÃO SEMANAL</small>
              <strong>+14,2%</strong>
            </div>
          </div>
        </div>

        <div className="hero-index" aria-hidden="true">
          <span>01</span>
          <i />
          <span>05</span>
        </div>
      </section>

      <section className="proof-strip" aria-label="Principais recursos">
        <span>EDITAL COM IA</span>
        <i />
        <span>CRONOGRAMA INTELIGENTE</span>
        <i />
        <span>QUESTÕES E SIMULADOS</span>
        <i />
        <span>ACOMPANHAMENTO DO TAF</span>
      </section>

      <section className="section section-light" id="metodo">
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

      <section className="section section-dark" id="recursos">
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
              <a href="#planos" aria-label={`Conhecer ${feature.title}`}>EXPLORAR <span>↗</span></a>
            </article>
          ))}
        </div>
      </section>

      <section className="taf-section" id="taf">
        <div className="taf-visual">
          <div className="taf-number">05:18</div>
          <div className="track-lines" aria-hidden="true"><i /><i /><i /></div>
          <div className="taf-chart">
            <small>CORRIDA • 12 MIN</small>
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

      <section className="section section-light pricing" id="planos">
        <div className="pricing-heading">
          <p className="eyebrow dark"><span /> SEU PRÓXIMO PASSO</p>
          <h2>COMECE A CONSTRUIR<br />SUA <em>APROVAÇÃO.</em></h2>
          <p>Entre para a lista de acesso antecipado do Papiro.</p>
        </div>
        <div className="plan-card">
          <div className="plan-badge">ACESSO ANTECIPADO</div>
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
          <span className="button button-full button-disabled" aria-disabled="true">
            CADASTRO EM BREVE
          </span>
          <small className="plan-note">A LISTA DE ACESSO SERÁ LIBERADA NA PRÓXIMA ETAPA</small>
        </div>
      </section>

      <section className="faq-section">
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

      <section className="final-cta" id="acesso">
        <p className="eyebrow"><span /> PAPIRO</p>
        <h2>O EDITAL É O MESMO.<br /><em>SUA ESTRATÉGIA NÃO.</em></h2>
        <a className="button" href="/cadastro">COMEÇAR MINHA PREPARAÇÃO <span>→</span></a>
      </section>

      <section className="whatsapp-strip" aria-label="Contato pelo WhatsApp">
        <div className="whatsapp-intro">
          <span className="whatsapp-icon" aria-hidden="true">W</span>
          <div>
            <small>PRECISA DE AJUDA?</small>
            <strong>FALE COM A EQUIPE PAPIRO</strong>
          </div>
        </div>
        <p>Atendimento rápido para dúvidas sobre a plataforma e sua preparação.</p>
        <span className="whatsapp-demo" aria-disabled="true">
          <span>(51) 99754-1888</span>
          <small>WHATSAPP DEMONSTRATIVO</small>
        </span>
      </section>

      <footer>
        <a className="brand" href="#inicio">
          <span className="brand-mark">P</span>
          <span><strong>PAPIRO</strong><small>PREPARAÇÃO POLICIAL</small></span>
        </a>
        <p>Preparação inteligente para Guarda Municipal, Polícia Militar e Polícia Civil.</p>
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
