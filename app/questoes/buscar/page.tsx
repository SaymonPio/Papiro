"use client";

import { Search, X } from "lucide-react";
import { useRouter } from "next/navigation";
import { useEffect, useMemo, useRef, useState } from "react";
import { StudentAppShell } from "@/components/layout/StudentAppShell";
import MarcaCarregando from "@/components/ui/MarcaCarregando";
import { createClient } from "@/utils/supabase/client";

// PAPIRO — Pesquisa livre de questões. Camada de PESQUISA/PREPARAÇÃO só:
// filtra -> mostra quantidade real -> inicia sessão pelo motor já existente
// (iniciar_sessao_questoes_pesquisa cria a sessão no servidor; esta tela
// nunca calcula nem busca ids de questão no cliente). A sessão criada é
// consumida por /questoes?sessaoAvulsa=<id>, 100% nivel_meta-agnóstico —
// nenhuma lógica de execução (registrar_resposta, classificar_erro,
// cronômetro, conclusão) vive aqui.
type Situacao = "todas" | "nao_resolvidas" | "resolvidas" | "acertei" | "errei";
type MateriaCursoAtivo = { materia_id: number; materia_nome: string; total_questoes: number | string };
type AssuntoCursoAtivo = { assunto_id: number; assunto_nome: string; total_questoes: number | string };
type OpcoesPesquisa = { bancas: string[] | null; anos: number[] | null; dificuldades: string[] | null };
type SessaoIniciada = { sessao_id: number | string; status: string; questao_ids: Array<number | string>; recuperada: boolean };

const OPCOES_STATUS: { valor: Situacao; rotulo: string }[] = [
  { valor: "todas", rotulo: "Todas" },
  { valor: "nao_resolvidas", rotulo: "Não resolvidas" },
  { valor: "resolvidas", rotulo: "Resolvidas" },
  { valor: "acertei", rotulo: "Acertei" },
  { valor: "errei", rotulo: "Errei" },
];

const OPCOES_QUANTIDADE = [10, 20, 30, 50] as const;

const ROTULOS_DIFICULDADE: Record<string, string> = {
  facil: "Fácil",
  media: "Média",
  dificil: "Difícil",
};

function rotuloDificuldade(valor: string) {
  return ROTULOS_DIFICULDADE[valor] ?? valor;
}

// Debounce uniforme (~400ms) para TODA mudança de filtro antes de recontar
// — mesma técnica já usada em app/caderno-de-erros (contar_revisoes_
// personalizadas), com uma camada a mais: um número de sequência por
// requisição garante que uma resposta antiga (de um filtro já trocado)
// nunca sobrescreva o resultado de uma requisição mais nova que já voltou
// primeiro (proteção explícita contra race condition pedida nesta tarefa).
const DEBOUNCE_CONTAGEM_MS = 400;

export default function BuscarQuestoes() {
  const router = useRouter();

  const [carregandoInicial, setCarregandoInicial] = useState(true);
  const [semContexto, setSemContexto] = useState(false);
  const [mensagemContexto, setMensagemContexto] = useState("");
  const [email, setEmail] = useState("");
  const [nome, setNome] = useState("Aluno");

  const [materiasCurso, setMateriasCurso] = useState<MateriaCursoAtivo[]>([]);
  const [assuntosCurso, setAssuntosCurso] = useState<AssuntoCursoAtivo[]>([]);
  const [carregandoAssuntos, setCarregandoAssuntos] = useState(false);
  const [opcoes, setOpcoes] = useState<OpcoesPesquisa>({ bancas: [], anos: [], dificuldades: [] });
  const [erroOpcoes, setErroOpcoes] = useState("");

  const [status, setStatus] = useState<Situacao>("todas");
  const [materiaId, setMateriaId] = useState<number | null>(null);
  const [assuntoId, setAssuntoId] = useState<number | null>(null);
  const [banca, setBanca] = useState<string | null>(null);
  const [ano, setAno] = useState<number | null>(null);
  const [dificuldade, setDificuldade] = useState<string | null>(null);
  const [buscaInput, setBuscaInput] = useState("");
  const [quantidade, setQuantidade] = useState<number>(10);

  const [contagem, setContagem] = useState<number | null>(null);
  const [carregandoContagem, setCarregandoContagem] = useState(false);
  const [erroContagem, setErroContagem] = useState("");
  const sequenciaContagemRef = useRef(0);

  const [iniciandoSessao, setIniciandoSessao] = useState(false);
  const [erroSessao, setErroSessao] = useState("");

  useEffect(() => {
    async function carregar() {
      const supabase = createClient();
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) { window.location.replace("/login"); return; }

      setEmail(user.email || "");
      setNome(user.user_metadata.nome || user.email?.split("@")[0] || "Aluno");

      const { data: perfil } = await supabase
        .from("perfis")
        .select("curso_ativo_id")
        .eq("usuario_id", user.id)
        .maybeSingle();

      if (!perfil?.curso_ativo_id) {
        setMensagemContexto("Selecione um curso ativo para pesquisar questões.");
        setSemContexto(true);
        setCarregandoInicial(false);
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
        setMensagemContexto("Sua matrícula no curso ativo não está disponível no momento.");
        setSemContexto(true);
        setCarregandoInicial(false);
        return;
      }

      const [resultadoMaterias, resultadoOpcoes] = await Promise.all([
        supabase.rpc("materias_do_curso_ativo"),
        supabase.rpc("opcoes_pesquisa_questoes"),
      ]);

      if (resultadoMaterias.error) {
        console.error("materias_do_curso_ativo falhou em /questoes/buscar:", {
          message: resultadoMaterias.error.message,
          code: resultadoMaterias.error.code,
        });
      } else {
        setMateriasCurso((resultadoMaterias.data as MateriaCursoAtivo[] | null) ?? []);
      }

      if (resultadoOpcoes.error) {
        console.error("opcoes_pesquisa_questoes falhou:", {
          message: resultadoOpcoes.error.message,
          code: resultadoOpcoes.error.code,
        });
        setErroOpcoes("Não foi possível carregar banca, ano e dificuldade agora.");
      } else {
        const linha = ((resultadoOpcoes.data as OpcoesPesquisa[] | null) ?? [])[0];
        setOpcoes({
          bancas: linha?.bancas ?? [],
          anos: linha?.anos ?? [],
          dificuldades: linha?.dificuldades ?? [],
        });
      }

      setCarregandoInicial(false);
    }
    carregar();
  }, []);

  // Assunto depende de matéria — mesmo efeito/RPC já usado em app/questoes
  // e app/caderno-de-erros para esta mesma finalidade.
  useEffect(() => {
    if (!materiaId) { setAssuntosCurso([]); return; }
    let ativo = true;
    async function carregarAssuntos() {
      setCarregandoAssuntos(true);
      const { data, error } = await createClient().rpc("assuntos_do_curso_ativo", { p_materia_id: materiaId });
      if (!ativo) return;
      if (error) {
        console.error("assuntos_do_curso_ativo falhou em /questoes/buscar:", { message: error.message, code: error.code });
      } else {
        setAssuntosCurso((data as AssuntoCursoAtivo[] | null) ?? []);
      }
      setCarregandoAssuntos(false);
    }
    carregarAssuntos();
    return () => { ativo = false; };
  }, [materiaId]);

  // Contador — debounce uniforme + número de sequência: a resposta só é
  // aplicada se, quando ela chega, nenhuma requisição mais nova já foi
  // disparada (evita que uma resposta atrasada de um filtro antigo
  // sobrescreva o resultado de um filtro já trocado).
  useEffect(() => {
    if (carregandoInicial || semContexto) return;
    const agendamento = window.setTimeout(async () => {
      const minhaSequencia = ++sequenciaContagemRef.current;
      setCarregandoContagem(true);
      setErroContagem("");
      const buscaNormalizada = buscaInput.trim() || null;
      const { data, error } = await createClient().rpc("contar_questoes_pesquisa", {
        p_materia_id: materiaId,
        p_assunto_id: assuntoId,
        p_banca: banca,
        p_ano: ano,
        p_dificuldade: dificuldade,
        p_busca: buscaNormalizada,
        p_status: status,
      });
      if (minhaSequencia !== sequenciaContagemRef.current) return;
      setCarregandoContagem(false);
      if (error) {
        console.error("contar_questoes_pesquisa falhou:", { message: error.message, code: error.code });
        setErroContagem("Não foi possível calcular quantas questões combinam com esses filtros.");
        setContagem(null);
        return;
      }
      setContagem(typeof data === "number" ? data : Number(data) || 0);
    }, DEBOUNCE_CONTAGEM_MS);
    return () => window.clearTimeout(agendamento);
  }, [carregandoInicial, semContexto, status, materiaId, assuntoId, banca, ano, dificuldade, buscaInput]);

  const materiaNomeAtual = materiasCurso.find((materia) => materia.materia_id === materiaId)?.materia_nome ?? null;
  const assuntoNomeAtual = assuntosCurso.find((assunto) => assunto.assunto_id === assuntoId)?.assunto_nome ?? null;
  const buscaAtiva = buscaInput.trim();

  const chips = useMemo(() => {
    const lista: { chave: string; rotulo: string; remover: () => void }[] = [];
    if (status !== "todas") {
      const info = OPCOES_STATUS.find((opcao) => opcao.valor === status);
      lista.push({ chave: "status", rotulo: info?.rotulo ?? status, remover: () => setStatus("todas") });
    }
    if (materiaId !== null) {
      lista.push({
        chave: "materia",
        rotulo: materiaNomeAtual ?? "Matéria",
        remover: () => { setMateriaId(null); setAssuntoId(null); },
      });
    }
    if (assuntoId !== null) {
      lista.push({ chave: "assunto", rotulo: assuntoNomeAtual ?? "Assunto", remover: () => setAssuntoId(null) });
    }
    if (banca) lista.push({ chave: "banca", rotulo: banca, remover: () => setBanca(null) });
    if (ano !== null) lista.push({ chave: "ano", rotulo: String(ano), remover: () => setAno(null) });
    if (dificuldade) {
      lista.push({ chave: "dificuldade", rotulo: rotuloDificuldade(dificuldade), remover: () => setDificuldade(null) });
    }
    if (buscaAtiva) lista.push({ chave: "busca", rotulo: `"${buscaAtiva}"`, remover: () => setBuscaInput("") });
    return lista;
  }, [status, materiaId, assuntoId, banca, ano, dificuldade, buscaAtiva, materiaNomeAtual, assuntoNomeAtual]);

  function limparFiltros() {
    setStatus("todas");
    setMateriaId(null);
    setAssuntoId(null);
    setBanca(null);
    setAno(null);
    setDificuldade(null);
    setBuscaInput("");
    // quantidade é preferência da sessão, não filtro acadêmico — preservada.
  }

  const zeroResultados = contagem === 0 && !carregandoContagem && !erroContagem;
  const podeBuscar = !carregandoContagem && !erroContagem && !iniciandoSessao && (contagem ?? 0) > 0;

  async function iniciarSessao() {
    if (!podeBuscar || iniciandoSessao) return;
    setIniciandoSessao(true);
    setErroSessao("");
    const buscaNormalizada = buscaInput.trim() || null;
    const supabase = createClient();
    const { data, error } = await supabase.rpc("iniciar_sessao_questoes_pesquisa", {
      p_quantidade: quantidade,
      p_materia_id: materiaId,
      p_assunto_id: assuntoId,
      p_banca: banca,
      p_ano: ano,
      p_dificuldade: dificuldade,
      p_busca: buscaNormalizada,
      p_status: status,
    });
    const linha = ((data as SessaoIniciada[] | null) ?? [])[0];

    if (error || !linha) {
      console.error("iniciar_sessao_questoes_pesquisa falhou:", {
        message: error?.message,
        code: error?.code,
        details: error?.details,
        hint: error?.hint,
      });
      const mensagemErro = error?.message?.toLowerCase() ?? "";
      setErroSessao(
        mensagemErro.includes("matricula ativa")
          ? "Sua matrícula no curso ativo não está disponível no momento."
          : mensagemErro.includes("nenhuma questao encontrada")
            ? "Nenhuma questão encontrada com esses filtros. Tente remover ou alterar algum filtro."
            : "Não foi possível iniciar a pesquisa agora. Tente novamente.",
      );
      setIniciandoSessao(false);
      return;
    }

    router.push(`/questoes?sessaoAvulsa=${linha.sessao_id}`);
  }

  async function sair() {
    const supabase = createClient();
    await supabase.auth.signOut();
    window.location.replace("/");
  }

  if (carregandoInicial) {
    return (
      <StudentAppShell currentHref="/questoes/buscar" fontCandidate="geist" userEmail={email} userName={nome} onSignOut={sair}>
        <main className="dashboard-loading">
          <MarcaCarregando texto="Preparando sua pesquisa..." />
        </main>
      </StudentAppShell>
    );
  }

  return (
    <StudentAppShell currentHref="/questoes/buscar" fontCandidate="geist" userEmail={email} userName={nome} onSignOut={sair}>
      <div id="conteudo-principal" className="method-page busca-questoes" tabIndex={-1}>
        <header className="bq-cabecalho">
          <p className="dashboard-label">QUESTÕES</p>
          <h1>Questões</h1>
          <span>Encontre exatamente o que precisa praticar.</span>
        </header>

        {semContexto ? (
          <p className="method-message" role="alert">{mensagemContexto}</p>
        ) : (
          <div className="bq-layout">
            <section className="bq-principal" aria-label="Filtros de pesquisa">
              <div className="bq-status" role="tablist" aria-label="Filtrar por status da questão">
                {OPCOES_STATUS.map((opcao) => (
                  <button
                    key={opcao.valor}
                    type="button"
                    role="tab"
                    aria-selected={status === opcao.valor}
                    onClick={() => setStatus(opcao.valor)}
                  >
                    {opcao.rotulo}
                  </button>
                ))}
              </div>

              <div className="bq-bloco">
                <label className="bq-bloco-titulo" htmlFor="bq-busca-input">Buscar por palavra-chave</label>
                <div className="bq-busca">
                  <Search size={16} strokeWidth={2} aria-hidden="true" />
                  <input
                    id="bq-busca-input"
                    type="search"
                    value={buscaInput}
                    onChange={(evento) => setBuscaInput(evento.target.value)}
                    placeholder="Ex.: violência doméstica, improbidade, crase..."
                  />
                </div>
              </div>

              <div className="bq-bloco">
                <p className="bq-bloco-titulo">Filtros principais</p>
                <div className="bq-filtros-grade bq-filtros-grade--2">
                  <label>
                    Matéria
                    <select
                      value={materiaId ?? ""}
                      onChange={(evento) => {
                        const valor = evento.target.value ? Number(evento.target.value) : null;
                        setMateriaId(valor);
                        setAssuntoId(null);
                      }}
                    >
                      <option value="">Todas</option>
                      {materiasCurso.map((materia) => (
                        <option key={materia.materia_id} value={materia.materia_id}>{materia.materia_nome}</option>
                      ))}
                    </select>
                  </label>

                  <label>
                    Assunto
                    <select
                      value={assuntoId ?? ""}
                      onChange={(evento) => setAssuntoId(evento.target.value ? Number(evento.target.value) : null)}
                      disabled={!materiaId || carregandoAssuntos}
                    >
                      <option value="">{carregandoAssuntos ? "Carregando..." : "Todos"}</option>
                      {assuntosCurso.map((assunto) => (
                        <option key={assunto.assunto_id} value={assunto.assunto_id}>{assunto.assunto_nome}</option>
                      ))}
                    </select>
                  </label>
                </div>
              </div>

              <div className="bq-bloco">
                <p className="bq-bloco-titulo">Outros filtros</p>
                {erroOpcoes && <p className="method-message" role="alert">{erroOpcoes}</p>}
                <div className="bq-filtros-grade bq-filtros-grade--3">
                  <label>
                    Banca
                    <select value={banca ?? ""} onChange={(evento) => setBanca(evento.target.value || null)}>
                      <option value="">Todas</option>
                      {(opcoes.bancas ?? []).map((valor) => (
                        <option key={valor} value={valor}>{valor}</option>
                      ))}
                    </select>
                  </label>

                  <label>
                    Ano
                    <select
                      value={ano ?? ""}
                      onChange={(evento) => setAno(evento.target.value ? Number(evento.target.value) : null)}
                    >
                      <option value="">Todos</option>
                      {(opcoes.anos ?? []).map((valor) => (
                        <option key={valor} value={valor}>{valor}</option>
                      ))}
                    </select>
                  </label>

                  <label>
                    Dificuldade
                    <select value={dificuldade ?? ""} onChange={(evento) => setDificuldade(evento.target.value || null)}>
                      <option value="">Todas</option>
                      {(opcoes.dificuldades ?? []).map((valor) => (
                        <option key={valor} value={valor}>{rotuloDificuldade(valor)}</option>
                      ))}
                    </select>
                  </label>
                </div>
              </div>

              <div className="bq-quantidade">
                <span className="bq-quantidade-rotulo">Quantidade de questões</span>
                <div className="bq-quantidade-opcoes" role="group" aria-label="Quantidade de questões">
                  {OPCOES_QUANTIDADE.map((valor) => (
                    <button
                      key={valor}
                      type="button"
                      aria-pressed={quantidade === valor}
                      onClick={() => setQuantidade(valor)}
                    >
                      {valor}
                    </button>
                  ))}
                </div>
              </div>

              <div className="bq-rodape">
                <button type="button" className="bq-limpar" onClick={limparFiltros}>Limpar filtros</button>

                <div className="bq-contador" role="status">
                  {erroContagem ? (
                    <strong className="bq-contador-erro">{erroContagem}</strong>
                  ) : carregandoContagem ? (
                    <strong>Carregando...</strong>
                  ) : (
                    <strong>
                      {contagem === 0
                        ? "Nenhuma questão encontrada"
                        : `${contagem} questõe${contagem === 1 ? "" : "s"} disponíve${contagem === 1 ? "l" : "is"}`}
                    </strong>
                  )}
                </div>

                <button type="button" className="bq-cta" disabled={!podeBuscar} onClick={iniciarSessao}>
                  {iniciandoSessao ? "Preparando questões..." : "Buscar questões"}
                </button>
              </div>

              {zeroResultados && (
                <p className="method-message bq-zero-resultados">
                  Nenhuma questão encontrada com esses filtros. Tente remover ou alterar algum filtro.
                </p>
              )}
              {erroSessao && <p className="method-message" role="alert">{erroSessao}</p>}
            </section>

            <aside className="bq-lateral" aria-label="Filtros aplicados">
              <div className="bq-lateral-cabecalho">
                <p className="dashboard-label">Filtros aplicados</p>
                {chips.length > 0 && (
                  <button type="button" onClick={limparFiltros}>Limpar tudo</button>
                )}
              </div>

              {chips.length === 0 ? (
                <p className="bq-sem-filtros">Nenhum filtro aplicado.</p>
              ) : (
                <ul className="bq-chips">
                  {chips.map((chip) => (
                    <li key={chip.chave}>
                      <button type="button" onClick={chip.remover} aria-label={`Remover filtro ${chip.rotulo}`}>
                        {chip.rotulo}
                        <X size={12} strokeWidth={2.5} aria-hidden="true" />
                      </button>
                    </li>
                  ))}
                </ul>
              )}
            </aside>
          </div>
        )}
      </div>
    </StudentAppShell>
  );
}
