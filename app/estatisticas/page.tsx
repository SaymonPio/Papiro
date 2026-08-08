"use client";

import Link from "next/link";
import { useEffect, useMemo, useState } from "react";
import { createClient } from "@/utils/supabase/client";

type Resposta = {
  acertou: boolean;
  respondida_em: string;
  questoes: { banca: string | null; materias: { nome: string } | null; assuntos: { nome: string } | null } | null;
};
type Sessao = { data_sessao: string; status: string; questoes_respondidas: number; acertos: number };
type Revisao = { status: string; agendada_para: string };
type Erro = { tipo_erro: string | null; corrigido: boolean; questoes: { materias: { nome: string } | null; assuntos: { nome: string } | null } | null };

function dataLocal(data: Date) {
  return `${data.getFullYear()}-${String(data.getMonth() + 1).padStart(2, "0")}-${String(data.getDate()).padStart(2, "0")}`;
}

function calcularSequencia(datas: string[]) {
  const conjunto = new Set(datas);
  const cursor = new Date();
  if (!conjunto.has(dataLocal(cursor))) cursor.setDate(cursor.getDate() - 1);
  let sequencia = 0;
  while (conjunto.has(dataLocal(cursor))) { sequencia += 1; cursor.setDate(cursor.getDate() - 1); }
  return sequencia;
}

export default function Estatisticas() {
  const [respostas, setRespostas] = useState<Resposta[]>([]);
  const [sessoes, setSessoes] = useState<Sessao[]>([]);
  const [revisoes, setRevisoes] = useState<Revisao[]>([]);
  const [erros, setErros] = useState<Erro[]>([]);
  const [carregando, setCarregando] = useState(true);
  const [mensagem, setMensagem] = useState("");

  useEffect(() => {
    async function carregar() {
      const supabase = createClient();
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) { window.location.replace("/login"); return; }
      const desde = new Date(); desde.setDate(desde.getDate() - 90);
      const [r, s, rv, e] = await Promise.all([
        supabase.from("respostas_usuarios").select("acertou, respondida_em, questoes(banca, materias(nome), assuntos(nome))").gte("respondida_em", desde.toISOString()).order("respondida_em"),
        supabase.from("sessoes_estudo").select("data_sessao, status, questoes_respondidas, acertos").gte("data_sessao", dataLocal(desde)).order("data_sessao"),
        supabase.from("revisoes").select("status, agendada_para").order("agendada_para"),
        supabase.from("erros_usuarios").select("tipo_erro, corrigido, questoes(materias(nome), assuntos(nome))"),
      ]);
      if (r.error || s.error || rv.error || e.error) setMensagem("Alguns indicadores não puderam ser carregados agora.");
      setRespostas((r.data as unknown as Resposta[]) ?? []);
      setSessoes((s.data as Sessao[]) ?? []);
      setRevisoes((rv.data as Revisao[]) ?? []);
      setErros((e.data as unknown as Erro[]) ?? []);
      setCarregando(false);
    }
    carregar();
  }, []);

  const dados = useMemo(() => {
    const total = respostas.length;
    const acertos = respostas.filter((r) => r.acertou).length;
    const aproveitamento = total ? Math.round((acertos / total) * 100) : 0;
    const concluidas = sessoes.filter((s) => s.status === "concluida");
    const diasUnicos = [...new Set(concluidas.map((s) => s.data_sessao))];
    const hoje = new Date(); const inicioSemana = new Date(hoje); inicioSemana.setDate(hoje.getDate() - ((hoje.getDay() + 6) % 7)); inicioSemana.setHours(0, 0, 0, 0);
    const diasSemana = diasUnicos.filter((data) => new Date(`${data}T00:00:00`) >= inicioSemana).length;
    const atrasadas = revisoes.filter((r) => r.status === "pendente" && r.agendada_para < dataLocal(hoje)).length;
    const pendentes = revisoes.filter((r) => r.status === "pendente" && r.agendada_para >= dataLocal(hoje)).length;
    const corrigidos = erros.filter((e) => e.corrigido).length;

    const porMateria = new Map<string, { total: number; acertos: number }>();
    respostas.forEach((resposta) => { const nome = resposta.questoes?.materias?.nome ?? "Geral"; const atual = porMateria.get(nome) ?? { total: 0, acertos: 0 }; atual.total += 1; if (resposta.acertou) atual.acertos += 1; porMateria.set(nome, atual); });
    const materias = [...porMateria.entries()].map(([nome, valor]) => ({ nome, ...valor, percentual: Math.round((valor.acertos / valor.total) * 100) })).sort((a, b) => b.total - a.total);

    const tipos = new Map<string, number>();
    erros.forEach((erro) => { const tipo = erro.tipo_erro?.replaceAll("_", " ") ?? "não classificado"; tipos.set(tipo, (tipos.get(tipo) ?? 0) + 1); });
    const errosPorTipo = [...tipos.entries()].map(([tipo, totalTipo]) => ({ tipo, total: totalTipo })).sort((a, b) => b.total - a.total);

    const ultimosSete = Array.from({ length: 7 }, (_, indice) => { const data = new Date(); data.setDate(data.getDate() - (6 - indice)); const chave = dataLocal(data); return { chave, dia: data.toLocaleDateString("pt-BR", { weekday: "short" }).replace(".", ""), estudou: diasUnicos.includes(chave) }; });
    return { total, acertos, aproveitamento, diasSemana, sequencia: calcularSequencia(diasUnicos), pendentes, atrasadas, corrigidos, materias, errosPorTipo, ultimosSete, abandonadas: sessoes.filter((s) => s.status === "abandonada").length };
  }, [respostas, sessoes, revisoes, erros]);

  if (carregando) return <main className="dashboard-loading"><p>Calculando sua evolução...</p></main>;

  return (
    <main className="stats-page">
      <header className="stats-header">
        <div><p className="dashboard-label">EVOLUÇÃO NO MÉTODO PAPIRO</p><h1>Consistência que pode ser medida.</h1><span>Indicadores dos últimos 90 dias.</span></div>
        <Link href="/painel">Voltar ao painel</Link>
      </header>
      {mensagem && <p className="method-message" role="alert">{mensagem}</p>}

      <section className="stats-summary">
        <article><span>Questões respondidas</span><strong>{dados.total}</strong><small>{dados.acertos} acertos</small></article>
        <article><span>Aproveitamento</span><strong>{dados.aproveitamento}%</strong><small>nos últimos 90 dias</small></article>
        <article><span>Dias estudados</span><strong>{dados.diasSemana}<b>/7</b></strong><small>nesta semana</small></article>
        <article><span>Sequência atual</span><strong>{dados.sequencia}</strong><small>dias consecutivos</small></article>
      </section>

      <section className="stats-grid">
        <article className="stats-panel performance-panel">
          <div className="stats-title"><div><p className="dashboard-label">DESEMPENHO</p><h2>Por matéria</h2></div><strong>{dados.aproveitamento}% geral</strong></div>
          {dados.materias.length === 0 ? <p className="stats-empty">Responda suas primeiras questões para comparar matérias.</p> : dados.materias.map((materia) => <div className="metric-row" key={materia.nome}><div><strong>{materia.nome}</strong><small>{materia.total} questões</small></div><div className="metric-track"><span style={{ width: `${materia.percentual}%` }} /></div><b>{materia.percentual}%</b></div>)}
        </article>

        <article className="stats-panel consistency-panel">
          <div className="stats-title"><div><p className="dashboard-label">CONSISTÊNCIA</p><h2>Últimos 7 dias</h2></div></div>
          <div className="week-grid">{dados.ultimosSete.map((dia) => <span className={dia.estudou ? "done" : ""} key={dia.chave}><i>{dia.estudou ? "✓" : "—"}</i><small>{dia.dia}</small></span>)}</div>
          <div className="consistency-notes"><span>Sessões abandonadas <strong>{dados.abandonadas}</strong></span><span>Meta da semana <strong>{dados.diasSemana >= 5 ? "atingida" : `${5 - dados.diasSemana} dias restantes`}</strong></span></div>
        </article>

        <article className="stats-panel reviews-panel">
          <div className="stats-title"><div><p className="dashboard-label">REVISÕES</p><h2>Fila de consolidação</h2></div></div>
          <div className="review-summary"><span><strong>{dados.pendentes}</strong>Programadas</span><span className={dados.atrasadas ? "warning" : ""}><strong>{dados.atrasadas}</strong>Atrasadas</span><span><strong>{dados.corrigidos}</strong>Erros corrigidos</span></div>
          <Link href="/caderno-de-erros">Abrir caderno de erros</Link>
        </article>

        <article className="stats-panel errors-panel">
          <div className="stats-title"><div><p className="dashboard-label">PADRÕES DE ERRO</p><h2>O que precisa de atenção</h2></div></div>
          {dados.errosPorTipo.length === 0 ? <p className="stats-empty">Os tipos de erro aparecerão após a classificação.</p> : dados.errosPorTipo.map((erro) => <div className="error-stat" key={erro.tipo}><span>{erro.tipo}</span><strong>{erro.total}</strong></div>)}
        </article>
      </section>
    </main>
  );
}
