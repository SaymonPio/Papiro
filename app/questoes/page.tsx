"use client";

import Link from "next/link";
import { useEffect, useMemo, useState } from "react";
import { createClient } from "@/utils/supabase/client";

type NivelMeta = "minima" | "normal" | "ideal";
type Alternativa = { id: number; texto: string; ordem: number };
type Questao = {
  id: number;
  enunciado: string;
  dificuldade: string;
  banca: string | null;
  materias: { nome: string } | null;
  assuntos: { nome: string } | null;
  alternativas: Alternativa[];
};

const metas: Record<NivelMeta, { titulo: string; questoes: number; revisao: number; descricao: string }> = {
  minima: { titulo: "Meta mínima", questoes: 5, revisao: 10, descricao: "Para manter a caminhada nos dias difíceis." },
  normal: { titulo: "Meta normal", questoes: 30, revisao: 15, descricao: "A rotina recomendada para avançar com consistência." },
  ideal: { titulo: "Meta ideal", questoes: 60, revisao: 20, descricao: "Para os dias com maior disponibilidade." },
};

export default function Questoes() {
  const [nivel, setNivel] = useState<NivelMeta | null>(null);
  const [questoes, setQuestoes] = useState<Questao[]>([]);
  const [indice, setIndice] = useState(0);
  const [sessaoId, setSessaoId] = useState<number | null>(null);
  const [alternativaId, setAlternativaId] = useState<number | null>(null);
  const [feedback, setFeedback] = useState<{ acertou: boolean; explicacao: string | null } | null>(null);
  const [acertos, setAcertos] = useState(0);
  const [mensagem, setMensagem] = useState("");
  const [carregando, setCarregando] = useState(false);

  useEffect(() => {
    async function protegerPagina() {
      const { data: { user } } = await createClient().auth.getUser();
      if (!user) window.location.replace("/login");
    }
    protegerPagina();
  }, []);

  const questaoAtual = questoes[indice];
  const progresso = useMemo(() => questoes.length ? Math.round(((indice + (feedback ? 1 : 0)) / questoes.length) * 100) : 0, [indice, feedback, questoes.length]);

  async function iniciarSessao(meta: NivelMeta) {
    setCarregando(true);
    setMensagem("");
    const supabase = createClient();
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) { window.location.replace("/login"); return; }

    const { data: perfil } = await supabase
      .from("perfis")
      .select("curso_ativo_id")
      .eq("usuario_id", user.id)
      .maybeSingle();

    if (!perfil?.curso_ativo_id) {
      setMensagem("Selecione um curso ativo para iniciar uma sessão.");
      setCarregando(false);
      return;
    }

    const { data: matricula } = await supabase
      .from("matriculas")
      .select("id")
      .eq("usuario_id", user.id)
      .eq("curso_id", perfil.curso_ativo_id)
      .eq("status", "ativa")
      .maybeSingle();

    if (!matricula) {
      setMensagem("Sua matrícula no curso ativo não está disponível no momento.");
      setCarregando(false);
      return;
    }

    const { data: bancoQuestoes, error: erroQuestoes } = await supabase
      .from("questoes")
      .select("id, enunciado, dificuldade, banca, materias(nome), assuntos(nome), alternativas(id, texto, ordem)")
      .eq("ativa", true)
      .limit(metas[meta].questoes);

    if (erroQuestoes || !bancoQuestoes?.length) {
      setMensagem("Ainda não há questões publicadas para iniciar esta sessão.");
      setCarregando(false);
      return;
    }

    const preparadas = (bancoQuestoes as unknown as Questao[]).map((questao) => ({
      ...questao,
      alternativas: [...questao.alternativas].sort((a, b) => a.ordem - b.ordem),
    }));

    const { data: sessao, error: erroSessao } = await supabase
      .from("sessoes_estudo")
      .insert({
        usuario_id: user.id,
        matricula_id: matricula.id,
        nivel_meta: meta,
        status: "em_andamento",
        inicio_em: new Date().toISOString(),
        minutos_revisao: metas[meta].revisao,
        questoes_planejadas: preparadas.length,
      })
      .select("id")
      .single();

    if (erroSessao || !sessao) {
      setMensagem("Não foi possível iniciar a sessão. Tente novamente.");
      setCarregando(false);
      return;
    }

    setNivel(meta);
    setQuestoes(preparadas);
    setSessaoId(sessao.id);
    setCarregando(false);
  }

  async function responder() {
    if (!alternativaId || !questaoAtual || !sessaoId) return;
    setCarregando(true);
    const supabase = createClient();
    const { data, error } = await supabase.rpc("registrar_resposta", {
      p_questao_id: questaoAtual.id,
      p_alternativa_id: alternativaId,
      p_sessao_id: sessaoId,
      p_tempo_segundos: null,
    });

    if (error || !data?.[0]) {
      setMensagem("Não foi possível registrar a resposta.");
      setCarregando(false);
      return;
    }

    const resultado = data[0] as { acertou: boolean; explicacao: string | null };
    if (resultado.acertou) setAcertos((valor) => valor + 1);
    setFeedback(resultado);
    setCarregando(false);
  }

  async function proxima() {
    if (!sessaoId) return;
    if (indice < questoes.length - 1) {
      setIndice((valor) => valor + 1);
      setAlternativaId(null);
      setFeedback(null);
      setMensagem("");
      return;
    }

    await createClient().from("sessoes_estudo").update({
      status: "concluida",
      fim_em: new Date().toISOString(),
    }).eq("id", sessaoId);
    window.location.replace(`/questoes/resultado?sessao=${sessaoId}`);
  }

  if (!nivel) {
    return (
      <main className="method-page">
        <header className="method-header">
          <Link href="/painel">← Voltar ao painel</Link>
          <p className="dashboard-label">MÉTODO PAPIRO</p>
          <h1>Escolha a missão de hoje</h1>
          <span>O importante é não interromper a caminhada.</span>
        </header>
        <section className="goal-grid" aria-label="Níveis de meta diária">
          {(Object.keys(metas) as NivelMeta[]).map((meta) => (
            <button key={meta} type="button" onClick={() => iniciarSessao(meta)} disabled={carregando}>
              <small>{metas[meta].titulo}</small>
              <strong>{metas[meta].questoes} questões</strong>
              <span>+ {metas[meta].revisao} min de revisão</span>
              <p>{metas[meta].descricao}</p>
            </button>
          ))}
        </section>
        {mensagem && <p className="method-message" role="alert">{mensagem}</p>}
      </main>
    );
  }

  return (
    <main className="method-page question-session">
      <header className="session-topbar">
        <Link href="/painel">PAPIRO</Link>
        <div><span>{metas[nivel].titulo}</span><strong>{indice + 1} de {questoes.length}</strong></div>
      </header>
      <div className="session-progress" aria-label={`${progresso}% concluído`}><span style={{ width: `${progresso}%` }} /></div>

      <article className="question-card">
        <div className="question-meta">
          <span>{questaoAtual.materias?.nome ?? "Matéria geral"}</span>
          <span>{questaoAtual.assuntos?.nome ?? "Assunto geral"}</span>
          {questaoAtual.banca && <span>{questaoAtual.banca}</span>}
        </div>
        <h1>{questaoAtual.enunciado}</h1>
        <div className="answer-list">
          {questaoAtual.alternativas.map((alternativa) => (
            <button
              key={alternativa.id}
              type="button"
              className={alternativaId === alternativa.id ? "selected" : ""}
              onClick={() => !feedback && setAlternativaId(alternativa.id)}
              disabled={Boolean(feedback)}
            >
              <b>{String.fromCharCode(64 + alternativa.ordem)}</b>
              <span>{alternativa.texto}</span>
            </button>
          ))}
        </div>

        {feedback ? (
          <section className={`answer-feedback ${feedback.acertou ? "correct" : "wrong"}`}>
            <strong>{feedback.acertou ? "Resposta correta" : "Resposta incorreta — adicionada ao caderno de erros"}</strong>
            <p>{feedback.explicacao ?? "A explicação detalhada será adicionada em breve."}</p>
            <button type="button" onClick={proxima}>{indice === questoes.length - 1 ? "Ver resultado" : "Próxima questão"}</button>
          </section>
        ) : (
          <button className="answer-submit" type="button" onClick={responder} disabled={!alternativaId || carregando}>
            {carregando ? "Registrando..." : "Confirmar resposta"}
          </button>
        )}
        {mensagem && <p className="method-message" role="alert">{mensagem}</p>}
      </article>
      <aside className="session-score">Acertos nesta sessão: <strong>{acertos}</strong></aside>
    </main>
  );
}
