"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import MarcaCarregando from "@/components/ui/MarcaCarregando";
import { createClient } from "@/utils/supabase/client";

type Objetivo = {
  id: number;
  concurso: string;
  cargo: string;
  banca: string | null;
  data_prova: string | null;
  horas_diarias: number;
};

function diasAte(data: string | null) {
  if (!data) return null;
  const hoje = new Date();
  hoje.setHours(0, 0, 0, 0);
  const prova = new Date(`${data}T00:00:00`);
  return Math.max(0, Math.ceil((prova.getTime() - hoje.getTime()) / 86_400_000));
}

export default function Painel() {
  const [nome, setNome] = useState("Aluno");
  const [objetivos, setObjetivos] = useState<Objetivo[]>([]);
  const [mensagem, setMensagem] = useState("");
  const [carregando, setCarregando] = useState(true);

  useEffect(() => {
    let ativo = true;

    async function carregarPainel() {
      const supabase = createClient();
      const { data: { user }, error: erroUsuario } = await supabase.auth.getUser();

      if (erroUsuario || !user) {
        window.location.replace("/login");
        return;
      }

      const { data, error } = await supabase
        .from("objetivos")
        .select("id, concurso, cargo, banca, data_prova, horas_diarias")
        .order("data_prova", { ascending: true });

      if (!ativo) return;
      setNome(user.user_metadata.nome || user.email?.split("@")[0] || "Aluno");
      setObjetivos((data as Objetivo[] | null) ?? []);
      setMensagem(error ? "Não foi possível carregar seus objetivos agora." : "");
      setCarregando(false);
    }

    carregarPainel();
    return () => { ativo = false; };
  }, []);

  async function sair() {
    const supabase = createClient();
    await supabase.auth.signOut();
    window.location.replace("/");
  }

  if (carregando) {
    return <main className="dashboard-loading"><MarcaCarregando texto="Carregando seu plano..." /></main>;
  }

  const objetivoPrincipal = objetivos[0];
  const diasRestantes = diasAte(objetivoPrincipal?.data_prova ?? null);

  return (
    <main className="dashboard-page">
      <aside className="dashboard-sidebar">
        <Link className="auth-brand" href="/">PAPIRO</Link>
        <nav aria-label="Menu do aluno">
          <Link className="active" href="/painel" title="Visão geral">
            <span className="dashboard-nav-icon" aria-hidden="true">⌂</span>
            <span className="dashboard-nav-label">Visão geral</span>
          </Link>
          <a href="#objetivos" title="Meus concursos">
            <span className="dashboard-nav-icon" aria-hidden="true">◎</span>
            <span className="dashboard-nav-label">Meus concursos</span>
          </a>
          <Link href="/cronograma" title="Cronograma">
            <span className="dashboard-nav-icon" aria-hidden="true">▦</span>
            <span className="dashboard-nav-label">Cronograma</span>
          </Link>
          <Link href="/questoes" title="Questões">
            <span className="dashboard-nav-icon" aria-hidden="true">☷</span>
            <span className="dashboard-nav-label">Questões</span>
          </Link>
          <Link href="/caderno-de-erros" title="Caderno de erros">
            <span className="dashboard-nav-icon" aria-hidden="true">!</span>
            <span className="dashboard-nav-label">Caderno de erros</span>
          </Link>
          <Link href="/editais" title="Enviar edital">
            <span className="dashboard-nav-icon" aria-hidden="true">⇧</span>
            <span className="dashboard-nav-label">Enviar edital</span>
          </Link>
          <Link href="/admin" title="Administração">
            <span className="dashboard-nav-icon" aria-hidden="true">⚙</span>
            <span className="dashboard-nav-label">Administração</span>
          </Link>
          <Link href="/estatisticas" title="Estatísticas">
            <span className="dashboard-nav-icon" aria-hidden="true">↗</span>
            <span className="dashboard-nav-label">Estatísticas</span>
          </Link>
        </nav>
        <button type="button" onClick={sair} title="Sair da conta">
          <span className="dashboard-nav-icon" aria-hidden="true">↪</span>
          <span className="dashboard-nav-label">Sair</span>
        </button>
      </aside>

      <section className="dashboard-content">
        <header className="dashboard-header">
          <div>
            <p className="dashboard-label">MISSÃO EM ANDAMENTO</p>
            <h1>Olá, {nome}</h1>
            <p>{objetivoPrincipal ? "Seu objetivo já está salvo. Vamos construir o plano." : "Defina seu primeiro objetivo para começar."}</p>
          </div>
          <span className="dashboard-status">{objetivoPrincipal ? "OBJETIVO ATIVO" : "CONFIGURAÇÃO PENDENTE"}</span>
        </header>

        {mensagem && <p className="dashboard-alert" role="alert">{mensagem}</p>}

        <section className="dashboard-cards" aria-label="Resumo do plano">
          <article>
            <span>Concurso principal</span>
            <strong className="dashboard-card-text">{objetivoPrincipal?.concurso ?? "Não definido"}</strong>
            <small>{objetivoPrincipal?.cargo ?? "Escolha seu concurso"}</small>
          </article>
          <article>
            <span>Dias restantes</span>
            <strong>{diasRestantes ?? "—"}</strong>
            <small>{objetivoPrincipal?.data_prova ? `Prova em ${new Date(`${objetivoPrincipal.data_prova}T00:00:00`).toLocaleDateString("pt-BR")}` : "Data ainda não informada"}</small>
          </article>
          <article>
            <span>Disponibilidade</span>
            <strong>{objetivoPrincipal ? `${objetivoPrincipal.horas_diarias}h` : "—"}</strong>
            <small>por dia para estudar</small>
          </article>
        </section>

        {objetivos.length > 0 ? (
          <section className="dashboard-objectives" id="objetivos">
            <div>
              <p className="dashboard-label">SEUS OBJETIVOS</p>
              <h2>Concursos selecionados</h2>
            </div>
            <div className="objective-list">
              {objetivos.map((objetivo) => (
                <article key={objetivo.id}>
                  <div><strong>{objetivo.concurso}</strong><span>{objetivo.cargo}</span></div>
                  <small>{objetivo.banca ?? "Banca a definir"}</small>
                </article>
              ))}
            </div>
            <Link className="dashboard-action" href="/configuracao">Editar objetivos</Link>
          </section>
        ) : (
          <section className="dashboard-mission">
            <p className="dashboard-label">PRÓXIMA MISSÃO</p>
            <h2>Configure seu objetivo</h2>
            <p>Informe o concurso, a data da prova e sua disponibilidade para criarmos seu plano de estudos.</p>
            <Link className="dashboard-action" href="/configuracao">Começar configuração</Link>
          </section>
        )}
      </section>
    </main>
  );
}
