"use client";

import { Search, X } from "lucide-react";
import { useEffect, useMemo, useRef, useState } from "react";
import MarcaCarregando from "@/components/ui/MarcaCarregando";
import { createClient } from "@/utils/supabase/client";

// PAPIRO — Central Única de Questões: UI da aba "Sessão personalizada",
// extraída de app/questoes/buscar/page.tsx (Fase de fusão). Mesma lógica de
// filtros/debounce/chips/contador/criação de sessão de lá — só a casca de
// página (StudentAppShell, saudação, logout, cabeçalho "Questões") foi
// removida, porque este componente agora vive DENTRO de /questoes, que já
// tem seu próprio header/shell. Continua filtra -> mostra quantidade real
// -> inicia sessão pelo motor já existente (iniciar_sessao_questoes_
// pesquisa cria a sessão no servidor; este componente nunca calcula nem
// busca ids de questão no cliente, e nunca monta a lista da sessão sozinho
// — devolve só o sessao_id ao pai via onSessaoIniciada, que reusa o MESMO
// mecanismo de recuperação por ?sessaoAvulsa= que já existe em
// app/questoes/page.tsx, o mesmo caminho de uma reabertura por F5).
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

// Debounce uniforme (~400ms), mesma técnica/justificativa de app/caderno-de-
// erros (contar_revisoes_personalizadas): número de sequência por
// requisição garante que uma resposta antiga (de um filtro já trocado)
// nunca sobrescreva o resultado de uma requisição mais nova que já voltou
// primeiro (proteção contra race condition).
const DEBOUNCE_CONTAGEM_MS = 400;

export default function SessaoPersonalizadaBusca({
  onSessaoIniciada,
}: {
  onSessaoIniciada: (sessaoId: number) => void;
}) {
  const [carregandoInicial, setCarregandoInicial] = useState(true);
  const [semContexto, setSemContexto] = useState(false);
  const [mensagemContexto, setMensagemContexto] = useState("");

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
        console.error("materias_do_curso_ativo falhou em SessaoPersonalizadaBusca:", {
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
        console.error("assuntos_do_curso_ativo falhou em SessaoPersonalizadaBusca:", { message: error.message, code: error.code });
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

    // Não busca detalhes nem monta a lista aqui — devolve só o id ao pai,
    // que navega para ?sessaoAvulsa=<id> e deixa o mecanismo de
    // recuperação já existente (o mesmo de F5) reconstruir a sessão.
    onSessaoIniciada(Number(linha.sessao_id));
  }

  if (carregandoInicial) {
    return <MarcaCarregando texto="Preparando sua pesquisa..." />;
  }

  if (semContexto) {
    return <p className="method-message" role="alert">{mensagemContexto}</p>;
  }

  return (
    <div className="busca-questoes" aria-label="Sessão personalizada">
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

      {/* Linha 1: Matéria | Assunto — Linha 2: Banca | Ano | Dificuldade. */}
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

      {/* Filtros aplicados — faixa discreta integrada, sem painel lateral. */}
      <div className="bq-chips-area" aria-label="Filtros aplicados">
        <p className="bq-bloco-titulo">Filtros aplicados</p>
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
      </div>

      {/* Rodapé único: quantidade (esquerda) + contador (centro) + ações (direita). */}
      <div className="bq-rodape">
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

        <div className="bq-rodape-acoes">
          <button type="button" className="bq-limpar" onClick={limparFiltros}>Limpar filtros</button>
          <button type="button" className="bq-cta" disabled={!podeBuscar} onClick={iniciarSessao}>
            {iniciandoSessao ? "Preparando sessão..." : "Iniciar sessão"}
          </button>
        </div>
      </div>

      {zeroResultados && (
        <p className="method-message bq-zero-resultados">
          Nenhuma questão encontrada com esses filtros. Tente remover ou alterar algum filtro.
        </p>
      )}
      {erroSessao && <p className="method-message" role="alert">{erroSessao}</p>}
    </div>
  );
}
