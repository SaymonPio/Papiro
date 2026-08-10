"use client";

import Link from "next/link";
import { useEffect, useMemo, useState, type ReactNode } from "react";
import { createClient } from "@/utils/supabase/client";

type NivelMeta = "minima" | "normal" | "ideal";
type Alternativa = { id: number; texto: string; ordem: number };
type IdQuestao = { questao_id: number };
type CausaErro = "nao_sabia" | "duvida" | "chute" | "atencao" | "interpretacao";
type Feedback = { acertou: boolean; explicacao: string | null; erroId: number | null };
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

const causasErro: { valor: CausaErro; rotulo: string; icone: ReactNode }[] = [
  {
    valor: "nao_sabia",
    rotulo: "Não sabia o conteúdo",
    icone: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
        <path d="M4 5c2.5-1 5-1 8 0v14c-3-1-5.5-1-8 0V5Z" />
        <path d="M20 5c-2.5-1-5-1-8 0v14c3-1 5.5-1 8 0V5Z" />
      </svg>
    ),
  },
  {
    valor: "duvida",
    rotulo: "Fiquei em dúvida",
    icone: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
        <circle cx="12" cy="12" r="9" />
        <path d="M9.5 9a2.5 2.5 0 0 1 4.6-1.4c.6.9.4 1.8-.4 2.5-.9.8-1.7 1.3-1.7 2.4" />
        <circle cx="12" cy="16.6" r="0.6" fill="currentColor" stroke="none" />
      </svg>
    ),
  },
  {
    valor: "chute",
    rotulo: "Chutei",
    icone: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
        <rect x="4" y="4" width="16" height="16" rx="3" />
        <circle cx="9" cy="9" r="1" fill="currentColor" stroke="none" />
        <circle cx="15" cy="15" r="1" fill="currentColor" stroke="none" />
      </svg>
    ),
  },
  {
    valor: "atencao",
    rotulo: "Erro de atenção",
    icone: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
        <path d="M12 4 21 20H3L12 4Z" strokeLinejoin="round" />
        <path d="M12 10v4" strokeLinecap="round" />
        <circle cx="12" cy="16.7" r="0.6" fill="currentColor" stroke="none" />
      </svg>
    ),
  },
  {
    valor: "interpretacao",
    rotulo: "Interpretei a questão errado",
    icone: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
        <path d="M4 8h13" />
        <path d="M14 5l3 3-3 3" />
        <path d="M20 16H7" />
        <path d="M10 13l-3 3 3 3" />
      </svg>
    ),
  },
];

export default function Questoes() {
  const [nivel, setNivel] = useState<NivelMeta | null>(null);
  const [questoes, setQuestoes] = useState<Questao[]>([]);
  const [indice, setIndice] = useState(0);
  const [sessaoId, setSessaoId] = useState<number | null>(null);
  const [alternativaId, setAlternativaId] = useState<number | null>(null);
  const [feedback, setFeedback] = useState<Feedback | null>(null);
  const [acertos, setAcertos] = useState(0);
  const [mensagem, setMensagem] = useState("");
  const [carregando, setCarregando] = useState(false);
  const [causaErro, setCausaErro] = useState<CausaErro | null>(null);
  const [classificando, setClassificando] = useState(false);
  const [classificado, setClassificado] = useState(false);
  const [erroClassificacao, setErroClassificacao] = useState("");

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

    const { data: idsQuestoes, error: erroIds } = await supabase.rpc("ids_questoes_para_usuario", {
      p_limite: metas[meta].questoes,
    });

    if (erroIds) {
      console.error("ids_questoes_para_usuario falhou:", {
        message: erroIds.message,
        code: erroIds.code,
        details: erroIds.details,
        hint: erroIds.hint,
      });
      setMensagem("Não foi possível carregar as questões deste curso.");
      setCarregando(false);
      return;
    }

    const ids = ((idsQuestoes as IdQuestao[] | null) ?? []).map((item) => item.questao_id);

    if (ids.length === 0) {
      setMensagem("Ainda não há questões cadastradas para este curso.");
      setCarregando(false);
      return;
    }

    // Busca só os detalhes das questões já autorizadas pela RPC para o curso ativo —
    // nunca um fallback para o banco global nem para outro curso.
    const { data: bancoQuestoes, error: erroQuestoes } = await supabase
      .from("questoes")
      .select("id, enunciado, dificuldade, banca, materias(nome), assuntos(nome), alternativas(id, texto, ordem)")
      .in("id", ids);

    if (erroQuestoes || !bancoQuestoes?.length) {
      setMensagem("Ainda não há questões cadastradas para este curso.");
      setCarregando(false);
      return;
    }

    const mapaQuestoes = new Map(
      (bancoQuestoes as unknown as Questao[]).map((questao) => [questao.id, questao]),
    );

    // Preserva a ordem de prioridade retornada por ids_questoes_para_usuario.
    const preparadas = ids
      .map((id) => mapaQuestoes.get(id))
      .filter((questao): questao is Questao => Boolean(questao))
      .map((questao) => ({
        ...questao,
        alternativas: [...questao.alternativas].sort((a, b) => a.ordem - b.ordem),
      }));

    if (preparadas.length === 0) {
      setMensagem("Ainda não há questões cadastradas para este curso.");
      setCarregando(false);
      return;
    }

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
      if (error) {
        // Log temporário de diagnóstico — não afrouxa nenhuma validação, só expõe o erro real.
        console.error("registrar_resposta falhou:", {
          message: error.message,
          code: error.code,
          details: error.details,
          hint: error.hint,
        });
      }
      setMensagem("Não foi possível registrar a resposta.");
      setCarregando(false);
      return;
    }

    const resultado = data[0] as { acertou: boolean; explicacao: string | null; erro_id: number | string | null };
    if (resultado.acertou) setAcertos((valor) => valor + 1);
    setFeedback({
      acertou: resultado.acertou,
      explicacao: resultado.explicacao,
      // erro_id é bigint no banco; o PostgREST serializa bigint como string no
      // JSON. Convertido aqui para number, mesmo tratamento já aplicado a
      // outros bigints vindos de RPC neste projeto (ex.: app/cronograma).
      erroId: resultado.erro_id === null || resultado.erro_id === undefined ? null : Number(resultado.erro_id),
    });
    setCarregando(false);
  }

  async function classificarErro(causa: CausaErro) {
    if (!feedback?.erroId) return;
    setCausaErro(causa);
    setClassificando(true);
    setErroClassificacao("");

    const supabase = createClient();
    const { error } = await supabase.rpc("classificar_erro", {
      p_erro_id: feedback.erroId,
      p_tipo_erro: causa,
    });

    if (error) {
      console.error("classificar_erro falhou:", {
        message: error.message,
        code: error.code,
        details: error.details,
        hint: error.hint,
      });
      setErroClassificacao("Não foi possível salvar sua resposta. Tente novamente.");
      setClassificando(false);
      return;
    }

    setClassificando(false);
    setClassificado(true);
  }

  async function proxima() {
    if (!sessaoId) return;
    if (indice < questoes.length - 1) {
      setIndice((valor) => valor + 1);
      setAlternativaId(null);
      setFeedback(null);
      setCausaErro(null);
      setClassificando(false);
      setClassificado(false);
      setErroClassificacao("");
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
            <div className="answer-feedback-head">
              <strong>{feedback.acertou ? "Resposta correta" : "Resposta incorreta — adicionada ao caderno de erros"}</strong>
              <p>{feedback.explicacao ?? "A explicação detalhada será adicionada em breve."}</p>
            </div>

            {!feedback.acertou && (
              <div className="error-diagnosis">
                <p className="error-diagnosis-title">Por que você errou essa questão?</p>
                <div className="error-diagnosis-options">
                  {causasErro.map((causa) => (
                    <button
                      key={causa.valor}
                      type="button"
                      className={`error-diagnosis-option${causa.valor === "interpretacao" ? " span-2" : ""}${causaErro === causa.valor ? " selected" : ""}`}
                      onClick={() => classificarErro(causa.valor)}
                      disabled={classificando}
                    >
                      <span className="error-diagnosis-icon" aria-hidden="true">{causa.icone}</span>
                      <span>{causa.rotulo}</span>
                    </button>
                  ))}
                </div>
                {classificando && <p className="method-message error-diagnosis-status">Salvando...</p>}
                {erroClassificacao && <p className="method-message error-diagnosis-status" role="alert">{erroClassificacao}</p>}
              </div>
            )}

            <div className="answer-feedback-footer">
              <button type="button" className="answer-feedback-next" onClick={proxima} disabled={!feedback.acertou && !classificado}>
                <span>{indice === questoes.length - 1 ? "Ver resultado" : "Próxima questão"}</span>
                <span aria-hidden="true">→</span>
              </button>
            </div>
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
