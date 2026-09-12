"use client";

import Image from "next/image";
import Link from "next/link";
import {
  ArrowRight,
  ArrowUpRight,
  CalendarDays,
  ChartNoAxesColumnIncreasing,
  Clock3,
  ListChecks,
  NotebookTabs,
  SlidersHorizontal,
  Target,
  type LucideIcon,
} from "lucide-react";
import { useEffect, useState } from "react";
import { StudentAppShell } from "@/components/layout/StudentAppShell";
import { WeeklyStatsCard } from "@/components/painel/WeeklyStatsCard";
import { ButtonLink } from "@/components/ui/Button";
import MarcaCarregando from "@/components/ui/MarcaCarregando";
import { Surface } from "@/components/ui/Surface";
import { encontrarCursoPorObjetivo } from "@/lib/cursos";
import { createClient } from "@/utils/supabase/client";

type FontCandidate = "geist" | "plex";

type Objetivo = {
  id: number;
  concurso: string;
  cargo: string;
  banca: string | null;
  data_prova: string | null;
  horas_diarias: number;
};

type RevisaoPendente = {
  status: string;
  agendada_para: string;
  materia_nome: string | null;
  assunto_nome: string | null;
};

type QuickAccess = {
  href: string;
  icon: LucideIcon;
  label: string;
  description: string;
};

const quickAccesses: QuickAccess[] = [
  {
    href: "/questoes",
    icon: ListChecks,
    label: "Questões",
    description: "Acesse suas opções de prática.",
  },
  {
    href: "/caderno-de-erros",
    icon: NotebookTabs,
    label: "Caderno de erros",
    description: "Abra seu caderno de erros.",
  },
  {
    href: "/estatisticas",
    icon: ChartNoAxesColumnIncreasing,
    label: "Estatísticas",
    description: "Consulte os resultados disponíveis.",
  },
];

const particulasDoNome = new Set(["da", "das", "de", "do", "dos", "e"]);

function formatarNomeNatural(valor: string) {
  const limpo = valor.trim().replace(/\s+/g, " ");
  if (!limpo) return "Aluno";

  const veioDeIdentificador = !limpo.includes(" ") && /[._]/.test(limpo);
  const base = veioDeIdentificador ? limpo.replace(/[._]+/g, " ") : limpo;
  const somenteMaiusculas =
    base === base.toLocaleUpperCase("pt-BR") && /\p{L}/u.test(base);

  if (!veioDeIdentificador && !somenteMaiusculas) return base;

  return base
    .toLocaleLowerCase("pt-BR")
    .split(" ")
    .map((parte, index) => {
      if (index > 0 && particulasDoNome.has(parte)) return parte;
      return `${parte.charAt(0).toLocaleUpperCase("pt-BR")}${parte.slice(1)}`;
    })
    .join(" ");
}

function diasAte(data: string | null) {
  if (!data) return null;
  const hoje = new Date();
  hoje.setHours(0, 0, 0, 0);
  const prova = new Date(`${data}T00:00:00`);
  return Math.max(
    0,
    Math.ceil((prova.getTime() - hoje.getTime()) / 86_400_000),
  );
}

function formatarData(data: string | null) {
  if (!data) return "Data a definir";
  return new Date(`${data}T00:00:00`).toLocaleDateString("pt-BR", {
    day: "2-digit",
    month: "short",
    year: "numeric",
  });
}

function prazoDaRevisao(data: string) {
  const hoje = new Date();
  hoje.setHours(0, 0, 0, 0);
  const agendada = new Date(`${data}T00:00:00`);
  const diferencaEmDias = Math.round(
    (agendada.getTime() - hoje.getTime()) / 86_400_000,
  );

  if (diferencaEmDias < 0) return "Revisão atrasada";
  if (diferencaEmDias === 0) return "Revisar hoje";
  if (diferencaEmDias === 1) return "Revisar amanhã";
  return `Revisar em ${formatarData(data)}`;
}

function detalheDaRevisao(revisao: RevisaoPendente) {
  const detalhes = [];
  if (
    revisao.materia_nome &&
    revisao.materia_nome !== revisao.assunto_nome
  ) {
    detalhes.push(revisao.materia_nome);
  }
  detalhes.push(prazoDaRevisao(revisao.agendada_para));
  return detalhes.join(" • ");
}

function primeiroNome(nome: string) {
  return formatarNomeNatural(nome).split(" ")[0] || "Aluno";
}

function saudacaoAgora() {
  const hora = new Date().getHours();
  if (hora < 12) return "Bom dia";
  if (hora < 18) return "Boa tarde";
  return "Boa noite";
}

export default function Painel() {
  const [email, setEmail] = useState("");
  const [nome, setNome] = useState("Aluno");
  const [objetivos, setObjetivos] = useState<Objetivo[]>([]);
  const [proximaRevisao, setProximaRevisao] =
    useState<RevisaoPendente | null>(null);
  const [revisoesIndisponiveis, setRevisoesIndisponiveis] = useState(false);
  const [mensagem, setMensagem] = useState("");
  const [carregando, setCarregando] = useState(true);
  const [fontCandidate, setFontCandidate] =
    useState<FontCandidate>("geist");

  useEffect(() => {
    let ativo = true;

    async function carregarPainel() {
      const supabase = createClient();
      const {
        data: { user },
        error: erroUsuario,
      } = await supabase.auth.getUser();

      if (erroUsuario || !user) {
        window.location.replace("/login");
        return;
      }

      const [resultadoObjetivos, resultadoRevisoes] = await Promise.all([
        supabase
          .from("objetivos")
          .select("id, concurso, cargo, banca, data_prova, horas_diarias")
          .order("data_prova", { ascending: true }),
        supabase.rpc("revisoes_do_curso_ativo"),
      ]);

      if (!ativo) return;
      const revisoesPendentes = (
        (resultadoRevisoes.data as RevisaoPendente[] | null) ?? []
      )
        .filter((revisao) => revisao.status === "pendente")
        .sort((a, b) => a.agendada_para.localeCompare(b.agendada_para));
      const nomeReal =
        user.user_metadata.nome || user.email?.split("@")[0] || "Aluno";
      setEmail(user.email || "");
      setNome(formatarNomeNatural(nomeReal));
      setObjetivos((resultadoObjetivos.data as Objetivo[] | null) ?? []);
      setProximaRevisao(revisoesPendentes[0] ?? null);
      setRevisoesIndisponiveis(Boolean(resultadoRevisoes.error));
      setMensagem(
        resultadoObjetivos.error
          ? "Não foi possível carregar seus objetivos agora."
          : "",
      );
      if (resultadoRevisoes.error) {
        console.error("revisoes_do_curso_ativo falhou no painel:", {
          message: resultadoRevisoes.error.message,
          code: resultadoRevisoes.error.code,
          details: resultadoRevisoes.error.details,
          hint: resultadoRevisoes.error.hint,
        });
      }
      setCarregando(false);
    }

    void carregarPainel();
    return () => {
      ativo = false;
    };
  }, []);

  async function sair() {
    const supabase = createClient();
    await supabase.auth.signOut();
    window.location.replace("/");
  }

  if (carregando) {
    return (
      <main className="papiro-next papiro-panel-loading" data-font="geist">
        <MarcaCarregando texto="Carregando seu plano..." />
      </main>
    );
  }

  const objetivoPrincipal = objetivos[0];
  const diasRestantes = diasAte(objetivoPrincipal?.data_prova ?? null);
  const cursoPrincipal = objetivoPrincipal
    ? encontrarCursoPorObjetivo(
        objetivoPrincipal.concurso,
        objetivoPrincipal.cargo,
      )
    : null;
  const nomeCurto = primeiroNome(nome);

  return (
    <StudentAppShell
      currentHref="/painel"
      fontCandidate={fontCandidate}
      userEmail={email}
      userName={nome}
      onSignOut={sair}
    >
      <div
        id="conteudo-principal"
        className="papiro-panel-view"
        tabIndex={-1}
      >
        <header className="papiro-panel-topbar">
          <div className="papiro-panel-breadcrumb">
            <span aria-hidden="true">
              <Target size={17} strokeWidth={1.8} />
            </span>
            <p>
              Área do aluno <i aria-hidden="true">/</i> <strong>Visão geral</strong>
            </p>
          </div>

          <div
            className="papiro-font-review"
            role="group"
            aria-label="Comparação tipográfica"
          >
            <span>Fonte em revisão</span>
            <div>
              <button
                type="button"
                aria-pressed={fontCandidate === "geist"}
                onClick={() => setFontCandidate("geist")}
              >
                Geist
              </button>
              <button
                type="button"
                aria-pressed={fontCandidate === "plex"}
                onClick={() => setFontCandidate("plex")}
              >
                IBM Plex
              </button>
            </div>
          </div>
        </header>

        <section className="papiro-panel-intro" aria-labelledby="saudacao-painel">
          <p className="papiro-eyebrow">Sua mesa de estudo</p>
          <h1 id="saudacao-painel">
            {saudacaoAgora()}, {nomeCurto}.
          </h1>
          <p>Seu próximo passo está aqui.</p>
        </section>

        {mensagem ? (
          <p className="papiro-inline-alert" role="alert">
            {mensagem}
          </p>
        ) : null}

        {objetivoPrincipal ? (
          <div className="papiro-panel-primary-grid">
            <Surface
              as="section"
              level="raised"
              padding="none"
              border="strong"
              radius="lg"
              className="papiro-focus-card"
              aria-labelledby="proximo-passo-titulo"
            >
              <div className="papiro-focus-card__content">
                <p className="papiro-focus-card__label">
                  <span aria-hidden="true">
                    <CalendarDays size={18} strokeWidth={1.8} />
                  </span>
                  Próximo passo
                </p>
                <h2 id="proximo-passo-titulo">
                  Seu plano está pronto para continuar.
                </h2>
                <p>
                  O cronograma continua sendo a fonte das prioridades e das
                  ações de estudo.
                </p>
                <ButtonLink
                  href="/cronograma"
                  size="lg"
                  trailingIcon={<ArrowRight size={18} strokeWidth={2} />}
                >
                  Ver cronograma
                </ButtonLink>
              </div>

              <Link
                className="papiro-focus-card__plan"
                href="/configuracao"
                aria-label={`Escolher ou trocar o curso. Curso atual: ${objetivoPrincipal.concurso}`}
              >
                {cursoPrincipal ? (
                  <div className="papiro-focus-card__media">
                    <Image
                      className="papiro-focus-card__image"
                      src={cursoPrincipal.imagem}
                      alt={`Capa do curso ${cursoPrincipal.concurso}`}
                      fill
                      unoptimized
                      sizes="(max-width: 680px) calc(100vw - 72px), (max-width: 1240px) 40vw, 260px"
                    />
                    <span className="papiro-live-status papiro-focus-card__media-status">
                      <i aria-hidden="true" />
                      Objetivo cadastrado
                    </span>
                  </div>
                ) : null}

                <div className="papiro-focus-card__plan-body">
                  <span className="papiro-focus-card__plan-action">
                    <SlidersHorizontal
                      aria-hidden="true"
                      size={15}
                      strokeWidth={1.9}
                    />
                    Escolher curso
                  </span>
                  {!cursoPrincipal ? (
                    <span className="papiro-live-status">
                      <i aria-hidden="true" />
                      Objetivo cadastrado
                    </span>
                  ) : null}
                  <div className="papiro-focus-card__course-copy">
                    <small>Concurso</small>
                    <strong>{objetivoPrincipal.concurso}</strong>
                    <span>{objetivoPrincipal.cargo}</span>
                  </div>
                  <dl>
                    <div>
                      <dt>Banca</dt>
                      <dd>{objetivoPrincipal.banca ?? "A definir"}</dd>
                    </div>
                    <div>
                      <dt>Prova</dt>
                      <dd>{formatarData(objetivoPrincipal.data_prova)}</dd>
                    </div>
                  </dl>
                </div>
              </Link>
            </Surface>

            <Surface
              as="aside"
              level="base"
              padding="none"
              border="subtle"
              radius="lg"
              className="papiro-plan-card"
              aria-labelledby="resumo-plano-titulo"
            >
              <div className="papiro-plan-card__header">
                <div>
                  <p className="papiro-eyebrow">Planejamento</p>
                  <h2 id="resumo-plano-titulo">Resumo do objetivo</h2>
                </div>
                <Target aria-hidden="true" size={21} strokeWidth={1.7} />
              </div>
              <dl className="papiro-plan-card__metrics">
                <div>
                  <dt>
                    <CalendarDays aria-hidden="true" size={17} strokeWidth={1.8} />
                    Dias restantes
                  </dt>
                  <dd>{diasRestantes ?? "—"}</dd>
                  <span>
                    {objetivoPrincipal.data_prova
                      ? `Prova em ${formatarData(objetivoPrincipal.data_prova)}`
                      : "Data ainda não informada"}
                  </span>
                </div>
                <div>
                  <dt>
                    <Clock3 aria-hidden="true" size={17} strokeWidth={1.8} />
                    Disponibilidade
                  </dt>
                  <dd>{objetivoPrincipal.horas_diarias}h</dd>
                  <span>por dia para estudar</span>
                </div>
              </dl>
            </Surface>
          </div>
        ) : (
          <Surface
            as="section"
            level="raised"
            padding="none"
            border="strong"
            radius="lg"
            className="papiro-empty-focus"
            aria-labelledby="configurar-objetivo-titulo"
          >
            <span className="papiro-empty-focus__icon" aria-hidden="true">
              <Target size={26} strokeWidth={1.7} />
            </span>
            <div>
              <p className="papiro-eyebrow">Primeiro passo</p>
              <h2 id="configurar-objetivo-titulo">Defina seu objetivo.</h2>
              <p>
                Informe o concurso, a data da prova e sua disponibilidade para
                o Papiro organizar seu plano.
              </p>
            </div>
            <ButtonLink
              href="/configuracao"
              size="lg"
              trailingIcon={<ArrowRight size={18} strokeWidth={2} />}
            >
              Configurar objetivo
            </ButtonLink>
          </Surface>
        )}

        <section className="papiro-panel-section" aria-labelledby="acessos-rapidos-titulo">
          <div className="papiro-section-heading">
            <div>
              <p className="papiro-eyebrow">Ferramentas</p>
              <h2 id="acessos-rapidos-titulo">Acessos rápidos</h2>
            </div>
            <p>Fluxos que já fazem parte da sua área de estudo.</p>
          </div>

          <div className="papiro-quick-grid">
            {quickAccesses.map((access) => {
              if (access.href === "/estatisticas") {
                return <WeeklyStatsCard key={access.href} />;
              }

              const Icon = access.icon;
              if (access.href === "/caderno-de-erros") {
                const titulo =
                  proximaRevisao?.assunto_nome ??
                  proximaRevisao?.materia_nome ??
                  (revisoesIndisponiveis
                    ? "Revisão indisponível"
                    : "Nenhuma revisão pendente");
                const detalhe = proximaRevisao
                  ? detalheDaRevisao(proximaRevisao)
                  : revisoesIndisponiveis
                    ? "Abra o caderno para consultar suas revisões."
                    : "Seu próximo conteúdo aparecerá aqui quando uma revisão for agendada.";

                return (
                  <Link
                    className="papiro-quick-card papiro-review-quick-card"
                    href={access.href}
                    key={access.href}
                  >
                    <span className="papiro-quick-card__icon" aria-hidden="true">
                      <Icon size={20} strokeWidth={1.8} />
                    </span>
                    <span className="papiro-quick-card__copy">
                      <span className="papiro-quick-card__eyebrow">
                        Próxima revisão
                      </span>
                      <strong>{titulo}</strong>
                      <small>{detalhe}</small>
                    </span>
                    <ArrowUpRight
                      className="papiro-quick-card__arrow"
                      aria-hidden="true"
                      size={18}
                      strokeWidth={1.8}
                    />
                  </Link>
                );
              }

              return (
                <Link
                  className="papiro-quick-card"
                  href={access.href}
                  key={access.href}
                >
                  <span className="papiro-quick-card__icon" aria-hidden="true">
                    <Icon size={20} strokeWidth={1.8} />
                  </span>
                  <span className="papiro-quick-card__copy">
                    <strong>{access.label}</strong>
                    <small>{access.description}</small>
                  </span>
                  <ArrowUpRight
                    className="papiro-quick-card__arrow"
                    aria-hidden="true"
                    size={18}
                    strokeWidth={1.8}
                  />
                </Link>
              );
            })}
          </div>
        </section>

      </div>
    </StudentAppShell>
  );
}
