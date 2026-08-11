"use client";

import Link from "next/link";
import { useEffect, useMemo, useRef, useState, type ReactNode } from "react";
import { lerMissaoCronograma } from "@/utils/missao-cronograma.mjs";
import { createClient } from "@/utils/supabase/client";

type MetaPreset = "minima" | "normal" | "ideal";
type NivelMeta = MetaPreset | "personalizada";
type Alternativa = { id: number; texto: string; ordem: number };
type IdQuestao = { questao_id: number };
type CausaErro = "nao_sabia" | "duvida" | "chute" | "atencao" | "interpretacao";
type Feedback = { acertou: boolean; explicacao: string | null; erroId: number | null };
type MateriaCursoAtivo = { materia_id: number; materia_nome: string; total_questoes: number | string };
type AssuntoCursoAtivo = { assunto_id: number; assunto_nome: string; total_questoes: number | string };
type Questao = {
  id: number;
  enunciado: string;
  dificuldade: string;
  banca: string | null;
  concurso: string | null;
  ano: number | null;
  fonte: string | null;
  materias: { nome: string } | null;
  assuntos: { nome: string } | null;
  alternativas: Alternativa[];
};

// Identificação visual da origem: questão real (banca preenchida e não
// autoral) mostra banca • concurso • ano, com a fonte (quando útil para achar
// o número da questão original) numa linha menor abaixo. Sem banca, ou banca
// começando com "papiro" (ex.: "Papiro - Teste", "Papiro - estilo Fundatec")
// = questão autoral Papiro — não existe outro campo no banco para marcar isso
// explicitamente, então esse prefixo é o próprio sinal.
function descreverOrigemQuestao(questao: Questao): { linha: string; detalhe: string | null } {
  const banca = questao.banca?.trim();
  const autoral = !banca || banca.toLowerCase().startsWith("papiro");
  if (autoral) {
    return { linha: "PAPIRO • ESTILO FUNDATEC", detalhe: null };
  }
  const partes = [banca, questao.concurso?.trim(), questao.ano ? String(questao.ano) : null].filter(
    (parte): parte is string => Boolean(parte),
  );
  const fonte = questao.fonte?.trim();
  return { linha: partes.join(" • "), detalhe: fonte || null };
}

const metas: Record<MetaPreset, { titulo: string; questoes: number; revisao: number; descricao: string }> = {
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

  const [modoInicio, setModoInicio] = useState<"metas" | "personalizada">("metas");
  const [materiasCurso, setMateriasCurso] = useState<MateriaCursoAtivo[]>([]);
  const [carregandoMaterias, setCarregandoMaterias] = useState(false);
  const [assuntosCurso, setAssuntosCurso] = useState<AssuntoCursoAtivo[]>([]);
  const [carregandoAssuntos, setCarregandoAssuntos] = useState(false);
  const [materiaSelecionada, setMateriaSelecionada] = useState<number | null>(null);
  const [assuntoSelecionado, setAssuntoSelecionado] = useState<number | null>(null);
  const [quantidadePersonalizada, setQuantidadePersonalizada] = useState(10);
  const [carregandoPersonalizada, setCarregandoPersonalizada] = useState(false);
  const [mensagemPersonalizada, setMensagemPersonalizada] = useState("");
  const [origemCronograma, setOrigemCronograma] = useState(false);
  const assuntoInicialMissao = useRef<number | null>(null);

  useEffect(() => {
    const agendamento = window.setTimeout(() => {
      const missao = lerMissaoCronograma(window.location.search);
      if (!missao) return;

      setOrigemCronograma(true);
      setModoInicio("personalizada");
      setMateriaSelecionada(missao.materiaId);
      assuntoInicialMissao.current = missao.assuntoId;
      setQuantidadePersonalizada(Math.max(1, Math.min(100, missao.quantidade)));
    }, 0);

    return () => window.clearTimeout(agendamento);
  }, []);

  useEffect(() => {
    async function protegerPagina() {
      const { data: { user } } = await createClient().auth.getUser();
      if (!user) window.location.replace("/login");
    }
    protegerPagina();
  }, []);

  useEffect(() => {
    if (modoInicio !== "personalizada" || materiasCurso.length > 0 || carregandoMaterias) return;
    async function carregarMaterias() {
      setCarregandoMaterias(true);
      const { data, error } = await createClient().rpc("materias_do_curso_ativo");
      if (error) {
        console.error("materias_do_curso_ativo falhou:", {
          message: error.message,
          code: error.code,
          details: error.details,
          hint: error.hint,
        });
        setMensagemPersonalizada("Não foi possível carregar as matérias deste curso.");
      } else {
        setMateriasCurso((data as MateriaCursoAtivo[] | null) ?? []);
      }
      setCarregandoMaterias(false);
    }
    carregarMaterias();
  }, [modoInicio, materiasCurso.length, carregandoMaterias]);

  useEffect(() => {
    if (!materiaSelecionada) return;

    async function carregarAssuntos() {
      setCarregandoAssuntos(true);
      const { data, error } = await createClient().rpc("assuntos_do_curso_ativo", {
        p_materia_id: materiaSelecionada,
      });
      if (error) {
        console.error("assuntos_do_curso_ativo falhou:", {
          message: error.message,
          code: error.code,
          details: error.details,
          hint: error.hint,
        });
        setMensagemPersonalizada("Não foi possível carregar os assuntos dessa matéria.");
      } else {
        const assuntosRecebidos = (data as AssuntoCursoAtivo[] | null) ?? [];
        setAssuntosCurso(assuntosRecebidos);
        const assuntoDaMissao = assuntoInicialMissao.current;
        if (
          assuntoDaMissao &&
          assuntosRecebidos.some((assunto) => assunto.assunto_id === assuntoDaMissao)
        ) {
          setAssuntoSelecionado(assuntoDaMissao);
        }
        assuntoInicialMissao.current = null;
      }
      setCarregandoAssuntos(false);
    }
    carregarAssuntos();
  }, [materiaSelecionada]);

  const questaoAtual = questoes[indice];
  const progresso = useMemo(() => questoes.length ? Math.round(((indice + (feedback ? 1 : 0)) / questoes.length) * 100) : 0, [indice, feedback, questoes.length]);

  async function iniciarSessao(meta: MetaPreset) {
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
      .select("id, enunciado, dificuldade, banca, concurso, ano, fonte, materias(nome), assuntos(nome), alternativas(id, texto, ordem)")
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

  async function iniciarSessaoPersonalizada() {
    if (!materiaSelecionada) {
      setMensagemPersonalizada("Escolha uma matéria para iniciar.");
      return;
    }
    setCarregandoPersonalizada(true);
    setMensagemPersonalizada("");
    const supabase = createClient();
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) { window.location.replace("/login"); return; }

    const { data: perfil } = await supabase
      .from("perfis")
      .select("curso_ativo_id")
      .eq("usuario_id", user.id)
      .maybeSingle();

    if (!perfil?.curso_ativo_id) {
      setMensagemPersonalizada("Selecione um curso ativo para iniciar uma sessão.");
      setCarregandoPersonalizada(false);
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
      setMensagemPersonalizada("Sua matrícula no curso ativo não está disponível no momento.");
      setCarregandoPersonalizada(false);
      return;
    }

    const { data: idsQuestoes, error: erroIds } = await supabase.rpc("ids_questoes_para_usuario", {
      p_limite: quantidadePersonalizada,
      p_materia_id: materiaSelecionada,
      p_assunto_id: assuntoSelecionado,
    });

    if (erroIds) {
      console.error("ids_questoes_para_usuario (personalizada) falhou:", {
        message: erroIds.message,
        code: erroIds.code,
        details: erroIds.details,
        hint: erroIds.hint,
      });
      setMensagemPersonalizada("Não foi possível carregar as questões para esse filtro.");
      setCarregandoPersonalizada(false);
      return;
    }

    const ids = ((idsQuestoes as IdQuestao[] | null) ?? []).map((item) => item.questao_id);

    if (ids.length === 0) {
      setMensagemPersonalizada("Não há questões disponíveis para esse filtro.");
      setCarregandoPersonalizada(false);
      return;
    }

    // Mesma busca por detalhes só dos IDs já autorizados pela RPC — nunca um
    // fallback para o banco global nem para outro curso (mesmo padrão de
    // iniciarSessao).
    const { data: bancoQuestoes, error: erroQuestoes } = await supabase
      .from("questoes")
      .select("id, enunciado, dificuldade, banca, concurso, ano, fonte, materias(nome), assuntos(nome), alternativas(id, texto, ordem)")
      .in("id", ids);

    if (erroQuestoes || !bancoQuestoes?.length) {
      setMensagemPersonalizada("Não há questões disponíveis para esse filtro.");
      setCarregandoPersonalizada(false);
      return;
    }

    const mapaQuestoes = new Map(
      (bancoQuestoes as unknown as Questao[]).map((questao) => [questao.id, questao]),
    );

    const preparadas = ids
      .map((id) => mapaQuestoes.get(id))
      .filter((questao): questao is Questao => Boolean(questao))
      .map((questao) => ({
        ...questao,
        alternativas: [...questao.alternativas].sort((a, b) => a.ordem - b.ordem),
      }));

    if (preparadas.length === 0) {
      setMensagemPersonalizada("Não há questões disponíveis para esse filtro.");
      setCarregandoPersonalizada(false);
      return;
    }

    const { data: sessao, error: erroSessao } = await supabase
      .from("sessoes_estudo")
      .insert({
        usuario_id: user.id,
        matricula_id: matricula.id,
        nivel_meta: "personalizada",
        status: "em_andamento",
        inicio_em: new Date().toISOString(),
        minutos_revisao: 0,
        questoes_planejadas: preparadas.length,
      })
      .select("id")
      .single();

    if (erroSessao || !sessao) {
      setMensagemPersonalizada("Não foi possível iniciar a sessão. Tente novamente.");
      setCarregandoPersonalizada(false);
      return;
    }

    if (preparadas.length < quantidadePersonalizada) {
      setMensagem(
        `Só há ${preparadas.length} questão${preparadas.length === 1 ? "" : "ões"} disponível${preparadas.length === 1 ? "" : "eis"} para esse filtro — sessão iniciada com ${preparadas.length}.`
      );
    }

    setNivel("personalizada");
    setQuestoes(preparadas);
    setSessaoId(sessao.id);
    setCarregandoPersonalizada(false);
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
          <Link href={origemCronograma ? "/cronograma" : "/painel"}>
            {origemCronograma ? "← Voltar ao cronograma" : "← Voltar ao painel"}
          </Link>
          <p className="dashboard-label">MÉTODO PAPIRO</p>
          <h1>{origemCronograma ? "Prepare a missão do cronograma" : "Escolha a missão de hoje"}</h1>
          <span>
            {origemCronograma
              ? "A matéria e o assunto de hoje já estão selecionados."
              : "O importante é não interromper a caminhada."}
          </span>
        </header>

        {!origemCronograma && <div className="session-mode-tabs" role="tablist" aria-label="Modo de início da sessão">
          <button type="button" role="tab" aria-selected={modoInicio === "metas"} className={modoInicio === "metas" ? "selected" : ""} onClick={() => setModoInicio("metas")}>
            Meta diária
          </button>
          <button type="button" role="tab" aria-selected={modoInicio === "personalizada"} className={modoInicio === "personalizada" ? "selected" : ""} onClick={() => setModoInicio("personalizada")}>
            Sessão personalizada
          </button>
        </div>}

        {modoInicio === "metas" ? (
          <>
            <section className="goal-grid" aria-label="Níveis de meta diária">
              {(Object.keys(metas) as MetaPreset[]).map((meta) => (
                <button key={meta} type="button" onClick={() => iniciarSessao(meta)} disabled={carregando}>
                  <small>{metas[meta].titulo}</small>
                  <strong>{metas[meta].questoes} questões</strong>
                  <span>+ {metas[meta].revisao} min de revisão</span>
                  <p>{metas[meta].descricao}</p>
                </button>
              ))}
            </section>
            {mensagem && <p className="method-message" role="alert">{mensagem}</p>}
          </>
        ) : (
          <section className="custom-session" aria-label="Sessão personalizada">
            <div className="custom-session-field">
              <label htmlFor="materia-select">Matéria</label>
              <select
                id="materia-select"
                value={materiaSelecionada ?? ""}
                onChange={(evento) => {
                  setMateriaSelecionada(evento.target.value ? Number(evento.target.value) : null);
                  setAssuntoSelecionado(null);
                  setAssuntosCurso([]);
                  assuntoInicialMissao.current = null;
                }}
                disabled={carregandoMaterias}
              >
                <option value="">{carregandoMaterias ? "Carregando..." : "Selecione uma matéria"}</option>
                {materiasCurso.map((materia) => (
                  <option key={materia.materia_id} value={materia.materia_id}>
                    {materia.materia_nome} ({Number(materia.total_questoes)} questões)
                  </option>
                ))}
              </select>
            </div>

            <div className="custom-session-field">
              <label htmlFor="assunto-select">Assunto (opcional)</label>
              <select
                id="assunto-select"
                value={assuntoSelecionado ?? ""}
                onChange={(evento) => setAssuntoSelecionado(evento.target.value ? Number(evento.target.value) : null)}
                disabled={!materiaSelecionada || carregandoAssuntos}
              >
                <option value="">{carregandoAssuntos ? "Carregando..." : "Todos os assuntos da matéria"}</option>
                {assuntosCurso.map((assunto) => (
                  <option key={assunto.assunto_id} value={assunto.assunto_id}>
                    {assunto.assunto_nome} ({Number(assunto.total_questoes)} questões)
                  </option>
                ))}
              </select>
            </div>

            <div className="custom-session-field">
              <label htmlFor="quantidade-input">Quantidade de questões</label>
              <input
                id="quantidade-input"
                type="number"
                min={1}
                max={100}
                value={quantidadePersonalizada}
                onChange={(evento) => setQuantidadePersonalizada(Math.max(1, Math.min(100, Number(evento.target.value) || 1)))}
              />
            </div>

            <button type="button" className="answer-submit" onClick={iniciarSessaoPersonalizada} disabled={!materiaSelecionada || carregandoPersonalizada}>
              {carregandoPersonalizada ? "Preparando..." : origemCronograma ? "Iniciar missão" : "Iniciar sessão"}
            </button>

            {mensagemPersonalizada && <p className="method-message" role="alert">{mensagemPersonalizada}</p>}
          </section>
        )}
      </main>
    );
  }

  const tituloSessaoAtual = nivel === "personalizada" ? "Sessão personalizada" : metas[nivel].titulo;
  const origemQuestao = descreverOrigemQuestao(questaoAtual);

  return (
    <main className="method-page question-session">
      <header className="session-topbar">
        <Link href="/painel">PAPIRO</Link>
        <div><span>{tituloSessaoAtual}</span><strong>{indice + 1} de {questoes.length}</strong></div>
      </header>
      <div className="session-progress" aria-label={`${progresso}% concluído`}><span style={{ width: `${progresso}%` }} /></div>

      <article className="question-card">
        <div className="question-origin">
          <span className="question-origin-main">{origemQuestao.linha}</span>
          {origemQuestao.detalhe && <span className="question-origin-detail">{origemQuestao.detalhe}</span>}
        </div>
        <div className="question-meta">
          <span>{questaoAtual.materias?.nome ?? "Matéria geral"}</span>
          <span>{questaoAtual.assuntos?.nome ?? "Assunto geral"}</span>
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
