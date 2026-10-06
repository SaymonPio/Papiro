"use client";

import Link from "next/link";
import { useCallback, useEffect, useMemo, useRef, useState, type ReactNode } from "react";
import ComentariosQuestao from "@/components/questoes/ComentariosQuestao";
import MarcaCarregando from "@/components/ui/MarcaCarregando";
import {
  lerMissaoCronograma,
  lerPraticaPapiro,
  podeIniciarMissaoAutomaticamente,
} from "@/utils/missao-cronograma.mjs";
import { createClient } from "@/utils/supabase/client";
import { useSessaoTempo, encerrarTeoriaAbertaDaMissao } from "@/components/tempo-estudo/useSessaoTempo";
import CronometroEstudo from "@/components/tempo-estudo/CronometroEstudo";

type MetaPreset = "minima" | "normal" | "ideal";
type NivelMeta = MetaPreset | "personalizada";
type Alternativa = { id: number; texto: string; ordem: number };
type IdQuestao = { questao_id: number };
type CausaErro = "nao_sabia" | "duvida" | "chute" | "atencao" | "interpretacao";
type Feedback = { acertou: boolean; explicacao: string | null; erroId: number | null };
type MateriaCursoAtivo = { materia_id: number; materia_nome: string; total_questoes: number | string };
type AssuntoCursoAtivo = { assunto_id: number; assunto_nome: string; total_questoes: number | string };
type SessaoMissao = {
  sessao_id: number | string;
  sessao_status: string;
  missao_status: string;
  questao_ids: Array<number | string>;
  recuperada: boolean;
};
// Retorno de iniciar_pratica_unidade/iniciar_missao_final (missao_pratica_
// papiro_rpc.sql) — mesmas 4 colunas realmente usadas nesta tela
// (sessao_id/sessao_status/questao_ids/recuperada); cada RPC devolve uma
// 5ª coluna própria (unidade_pedagogica_id ou missao_status) que esta tela
// não precisa ler.
type SessaoPratica = {
  sessao_id: number | string;
  sessao_status: string;
  questao_ids: Array<number | string>;
  recuperada: boolean;
};
type Questao = {
  id: number;
  enunciado: string;
  dificuldade: string;
  banca: string | null;
  concurso: string | null;
  ano: number | null;
  materias: { nome: string } | null;
  assuntos: { nome: string } | null;
  alternativas: Alternativa[];
};

// Retorno de iniciar_sessao_questoes_avulsa (meta diária e personalizada —
// supabase/migrations/20261004180000_sessao_avulsa_recuperavel.sql).
type SessaoAvulsaIniciada = {
  sessao_id: number | string;
  status: string;
  questao_ids: Array<number | string>;
  recuperada: boolean;
};

// Retorno de obter_sessao_questoes_avulsa — usado só na recuperação após
// F5/reabertura (?sessaoAvulsa=<id> na URL).
type SessaoAvulsaRecuperada = {
  sessao_id: number | string;
  status: string;
  nivel_meta: string;
  materia_id: number | null;
  assunto_id: number | null;
  questoes_planejadas: number;
  questao_ids: Array<number | string>;
};

type Resposta = { questao_id: number; acertou: boolean };

// Busca os detalhes completos (enunciado/alternativas) das questões já
// autorizadas por uma RPC (ids_questoes_para_usuario, direto ou via
// iniciar_sessao_questoes_avulsa/obter_sessao_questoes_avulsa) — nunca um
// fallback para o banco global. Preserva a ORDEM de `ids` (que é a ordem
// de prioridade da RPC, ou a ordem persistida em sessao_questoes_planejadas
// na recuperação). Usado pelos três pontos que hoje montam uma lista de
// questões em memória: iniciarSessao, iniciarSessaoPersonalizada, e a
// recuperação por ?sessaoAvulsa=.
async function buscarDetalhesQuestoes(
  supabase: ReturnType<typeof createClient>,
  ids: number[],
): Promise<Questao[] | null> {
  if (ids.length === 0) return null;
  const { data: bancoQuestoes, error } = await supabase
    .from("questoes")
    .select("id, enunciado, dificuldade, banca, concurso, ano, materias(nome), assuntos(nome), alternativas(id, texto, ordem)")
    .in("id", ids);
  if (error || !bancoQuestoes?.length) return null;
  const mapa = new Map((bancoQuestoes as unknown as Questao[]).map((questao) => [questao.id, questao]));
  const preparadas = ids
    .map((id) => mapa.get(id))
    .filter((questao): questao is Questao => Boolean(questao))
    .map((questao) => ({ ...questao, alternativas: [...questao.alternativas].sort((a, b) => a.ordem - b.ordem) }));
  return preparadas.length > 0 ? preparadas : null;
}

// Resolve a matrícula ativa do curso ativo do usuário — mesma consulta
// (perfis.curso_ativo_id -> matriculas) já feita em 3 lugares deste
// arquivo (iniciarSessao, iniciarSessaoPersonalizada, e a recuperação
// por ?sessaoAvulsa=); aqui sem distinguir as duas mensagens de erro
// específicas que iniciarSessao/iniciarSessaoPersonalizada mostram, pois
// a recuperação não tem onde exibi-las.
async function buscarMatriculaAtiva(
  supabase: ReturnType<typeof createClient>,
  usuarioId: string,
): Promise<string | null> {
  const { data: perfil } = await supabase.from("perfis").select("curso_ativo_id").eq("usuario_id", usuarioId).maybeSingle();
  if (!perfil?.curso_ativo_id) return null;
  const { data: matricula } = await supabase
    .from("matriculas")
    .select("id")
    .eq("usuario_id", usuarioId)
    .eq("curso_id", perfil.curso_ativo_id)
    .eq("status", "ativa")
    .maybeSingle();
  return matricula?.id ?? null;
}

// Grava/atualiza ?sessaoAvulsa=<id> na URL sem recarregar a página — é
// esse parâmetro que permite reconstruir a mesma execução depois de um
// F5. Nome escolhido para NUNCA colidir com o ?sessao=<sessoes_estudo.id>
// já usado por /questoes/resultado (mesmo espaço de ids, propósito
// diferente — ver auditoria desta fase).
function atualizarUrlSessaoAvulsa(sessaoId: number) {
  if (typeof window === "undefined") return;
  const url = new URL(window.location.href);
  url.searchParams.set("sessaoAvulsa", String(sessaoId));
  window.history.replaceState(null, "", url.toString());
}

function removerUrlSessaoAvulsa() {
  if (typeof window === "undefined") return;
  const url = new URL(window.location.href);
  url.searchParams.delete("sessaoAvulsa");
  window.history.replaceState(null, "", url.toString());
}

// Identificação visual da origem: questão real (banca preenchida e não
// autoral) mostra apenas banca • concurso • ano. Metadados internos da fonte,
// como número e posição no conjunto importado, nunca são enviados ao aluno.
// Sem banca, ou banca
// começando com "papiro" (ex.: "Papiro - Teste", "Papiro - estilo Fundatec")
// = questão autoral Papiro — não existe outro campo no banco para marcar isso
// explicitamente, então esse prefixo é o próprio sinal.
function descreverOrigemQuestao(questao: Questao): string {
  const banca = questao.banca?.trim();
  const autoral = !banca || banca.toLowerCase().startsWith("papiro");
  if (autoral) {
    return "PAPIRO • ESTILO FUNDATEC";
  }
  const partes = [banca, questao.concurso?.trim(), questao.ano ? String(questao.ano) : null].filter(
    (parte): parte is string => Boolean(parte),
  );
  return partes.join(" • ");
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
  const [alternativasEliminadas, setAlternativasEliminadas] = useState<Set<number>>(()=>new Set());
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
  const [missionId, setMissionId] = useState<string | null>(null);
  const [refazerMissao, setRefazerMissao] = useState(false);
  const [unidadePedagogicaId, setUnidadePedagogicaId] = useState<string | null>(null);
  const [missaoFinal, setMissaoFinal] = useState(false);
  const [autoInicioSolicitado, setAutoInicioSolicitado] = useState(false);
  const assuntoInicialMissao = useRef<number | null>(null);
  const autoInicioExecutado = useRef(false);

  // Fase 2C (horas líquidas) — contexto só preenchido/usado no fluxo de
  // questões DA MISSÃO (quando missionId existe). matriculaId é promovido
  // a estado aqui (antes só existia como variável local dentro de
  // iniciarSessaoPersonalizada) especificamente para alimentar
  // useSessaoTempo; cursoConteudoId vem de lerMissaoCronograma, que já
  // lia esse campo mas a tela nunca o guardava.
  const [matriculaId, setMatriculaId] = useState<string | null>(null);
  const [cursoConteudoId, setCursoConteudoId] = useState<number | null>(null);
  // true quando a checagem de sessão de teoria esquecida (ver
  // encerrarTeoriaAbertaDaMissao) já terminou — só então o contexto de
  // useSessaoTempo é habilitado, pra garantir que ela rode ANTES da
  // própria recuperação automática do hook ver essa sessão de teoria.
  const [preFlightTempoConcluido, setPreFlightTempoConcluido] = useState(false);

  useEffect(() => {
    const agendamento = window.setTimeout(() => {
      const missao = lerMissaoCronograma(window.location.search);
      if (!missao) return;

      const pratica = lerPraticaPapiro(window.location.search);

      setOrigemCronograma(true);
      setMissionId(missao.missionId);
      setRefazerMissao(missao.refazer);
      setUnidadePedagogicaId(pratica.unidadePedagogicaId);
      setMissaoFinal(pratica.missaoFinal);
      setModoInicio("personalizada");
      setMateriaSelecionada(missao.materiaId);
      setCursoConteudoId(missao.conteudoId);
      assuntoInicialMissao.current = missao.assuntoId;
      setQuantidadePersonalizada(Math.max(1, Math.min(100, missao.quantidade)));
    }, 0);

    return () => window.clearTimeout(agendamento);
  }, []);

  // Horas Líquidas 1.0 — recuperação de sessão avulsa/personalizada após
  // F5/reabertura via ?sessaoAvulsa=<sessoes_estudo.id>. Roda uma vez no
  // mount; nunca ativa junto com o fluxo de missão (parâmetros
  // mutuamente exclusivos). obter_sessao_questoes_avulsa já valida
  // ownership (usuario_id = auth.uid()) dentro da própria RPC — o id da
  // URL nunca é confiado por si só.
  //
  // O estado inicial é SEMPRE false, igual no servidor e no primeiro
  // render do cliente — nunca um valor calculado a partir de
  // `typeof window !== "undefined"` dentro do inicializador do
  // useState. Essa variante (já tentada e revertida) fazia o SSR
  // sempre renderizar "false" (sem window) enquanto o primeiro render
  // do cliente, com ?sessaoAvulsa= na URL, calculava "true" — a própria
  // árvore de JSX divergia (tela de escolha vs. tela de carregamento),
  // causando o hydration mismatch real reportado nesta auditoria. A
  // leitura de verdade da URL só acontece aqui dentro, depois do mount.
  const [recuperandoSessaoAvulsa, setRecuperandoSessaoAvulsa] = useState(false);
  useEffect(() => {
    const id = Number(new URLSearchParams(window.location.search).get("sessaoAvulsa"));
    if (!Number.isInteger(id) || id <= 0) return;

    // Setado aqui (dentro do efeito, depois do mount), não no
    // inicializador do useState — é exatamente essa diferença que
    // resolve o mismatch acima sem escondê-lo: o primeiro render fica
    // idêntico nos dois lados, e só depois de montado é que a tela
    // troca para o loading de recuperação. Dispara o aviso de lint
    // react-hooks/set-state-in-effect — aceito deliberadamente aqui,
    // na mesma categoria de trade-off já documentada para
    // react-hooks/refs neste arquivo: a alternativa (ler no
    // inicializador) é o próprio bug de hydration.
    setRecuperandoSessaoAvulsa(true);

    let ativo = true;

    (async () => {
      const supabase = createClient();
      const { data: { user } } = await supabase.auth.getUser();
      if (!ativo) return;
      if (!user) { window.location.replace("/login"); return; }

      const { data, error } = await supabase.rpc("obter_sessao_questoes_avulsa", { p_sessao_id: id });
      if (!ativo) return;

      const linha = ((data as SessaoAvulsaRecuperada[] | null) ?? [])[0];
      if (error || !linha) {
        // Sessão não encontrada/não pertence a este usuário: remove o
        // parâmetro inválido e segue para a tela normal de escolha —
        // nunca trava a navegação por causa de um link velho/alterado.
        removerUrlSessaoAvulsa();
        setRecuperandoSessaoAvulsa(false);
        return;
      }

      if (linha.status === "concluida") {
        window.location.replace(`/questoes/resultado?sessao=${linha.sessao_id}`);
        return;
      }

      const ids = linha.questao_ids.map(Number).filter(Number.isInteger);
      const preparadas = await buscarDetalhesQuestoes(supabase, ids);
      if (!ativo) return;
      if (!preparadas) {
        removerUrlSessaoAvulsa();
        setRecuperandoSessaoAvulsa(false);
        return;
      }

      const matriculaAtiva = await buscarMatriculaAtiva(supabase, user.id);
      if (!ativo) return;

      const { data: respostas } = await supabase
        .from("respostas_usuarios")
        .select("questao_id, acertou")
        .eq("sessao_id", linha.sessao_id);
      if (!ativo) return;

      const jaRespondidas = new Set((respostas as Resposta[] | null ?? []).map((r) => r.questao_id));
      const acertosRecuperados = ((respostas as Resposta[] | null) ?? []).filter((r) => r.acertou).length;
      const indicePendente = ids.findIndex((idQuestao) => !jaRespondidas.has(idQuestao));

      if (matriculaAtiva) setMatriculaId(matriculaAtiva);
      setModoInicio("personalizada");
      setMateriaSelecionada(linha.materia_id);
      setAssuntoSelecionado(linha.assunto_id);
      setNivel(linha.nivel_meta as NivelMeta);
      setQuestoes(preparadas);
      setSessaoId(Number(linha.sessao_id));
      setAcertos(acertosRecuperados);
      setIndice(indicePendente === -1 ? Math.max(0, ids.length - 1) : indicePendente);
      setRecuperandoSessaoAvulsa(false);
    })();

    return () => {
      ativo = false;
    };
  }, []);

  // Defesa contra sessão de teoria aberta antiga (Fase 2C, seção 6, regra
  // A) — roda uma vez por missão, antes de habilitar o contexto de tempo
  // de questões abaixo. Nunca lança (ver encerrarTeoriaAbertaDaMissao);
  // "concluído" fica true mesmo se a checagem falhar internamente, para
  // nunca travar o fluxo de questões por causa disto.
  useEffect(() => {
    if (!missionId) return;
    let ativo = true;
    encerrarTeoriaAbertaDaMissao(missionId).finally(() => {
      if (ativo) setPreFlightTempoConcluido(true);
    });
    return () => {
      ativo = false;
    };
  }, [missionId]);

  // Motor de tempo líquido de estudo — cobre os dois casos deste arquivo:
  // questões DA MISSÃO (origem='cronograma', missaoId real; matriculaId só
  // passa depois do pre-flight de teoria concluir — preFlightTempoConcluido
  // acima) e questões AVULSAS/PERSONALIZADAS (Fase 2C.1: origem='questoes',
  // missaoId sempre null, sem pre-flight — não há teoria de nenhuma missão
  // pra limpar antes). sessaoId é a MESMA sessão pedagógica de questões já
  // criada pelo fluxo existente (iniciar_pratica_unidade/iniciar_missao_
  // final/iniciar_questoes_da_missao/INSERT em sessoes_estudo) — nunca uma
  // sessoes_estudo nova só para o cronômetro. curso_conteudo_id e
  // unidade_pedagogica_id ficam null nos dois fluxos avulsos (nunca têm um
  // vínculo real); materia_id/assunto_id só nascem preenchidos na
  // personalizada avulsa, quando o aluno de fato escolheu um filtro — a
  // meta diária nunca seta materiaSelecionada/assuntoSelecionado, então
  // ambos continuam null nesse caso, sem nenhuma inferência.
  const tempoHabilitado = missionId ? preFlightTempoConcluido : true;
  const sessaoTempo = useSessaoTempo({
    origem: missionId ? "cronograma" : "questoes",
    tipoAtividade: "questoes",
    matriculaId: tempoHabilitado ? matriculaId : null,
    missaoId: missionId,
    sessaoEstudoId: sessaoId,
    cursoConteudoId,
    materiaId: materiaSelecionada,
    assuntoId: assuntoSelecionado,
    unidadePedagogicaId,
  });

  // Momento escolhido para iniciar a contagem: quando a sessão de questões
  // (de missão OU avulsa) já existe de fato (sessaoId real) E a lista já
  // carregou — nunca por questão individual (iniciarEstudo() é idempotente,
  // só age a partir de "ociosa").
  useEffect(() => {
    if (matriculaId && sessaoId && questoes.length > 0) {
      sessaoTempo.iniciarEstudo();
    }
  }, [matriculaId, sessaoId, questoes.length, sessaoTempo.iniciarEstudo]);

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
        const materiasRecebidas = (data as MateriaCursoAtivo[] | null) ?? [];
        setMateriasCurso(materiasRecebidas);
        if (materiasRecebidas.length === 0) {
          setMensagemPersonalizada("Não há matérias com questões disponíveis neste curso.");
        } else if (
          materiaSelecionada &&
          !materiasRecebidas.some((materia) => materia.materia_id === materiaSelecionada)
        ) {
          setMensagemPersonalizada("A matéria desta missão não possui questões disponíveis no curso ativo.");
        }
      }
      setCarregandoMaterias(false);
    }
    carregarMaterias();
  }, [modoInicio, materiasCurso.length, carregandoMaterias, materiaSelecionada]);

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
        } else if (assuntoDaMissao) {
          setMensagemPersonalizada(
            "O assunto específico ainda não possui questões vinculadas. A missão usará questões de toda a matéria."
          );
        }
      }
      assuntoInicialMissao.current = null;
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

    // Promovido a estado aqui especificamente para useSessaoTempo (sessão
    // avulsa de meta diária) — nada mudou no resto desta função.
    setMatriculaId(matricula.id);

    // Horas Líquidas 1.0: criação/recuperação atômica (idempotente — um
    // retry/double-click/refresh nunca cria uma segunda sessoes_estudo) e
    // persistência da lista+ordem das questões, tudo numa única RPC —
    // substitui o INSERT direto em sessoes_estudo de antes, que nunca
    // gravava a lista em sessao_questoes_planejadas.
    const { data, error } = await supabase.rpc("iniciar_sessao_questoes_avulsa", {
      p_nivel_meta: meta,
      p_quantidade: metas[meta].questoes,
    });

    const linha = ((data as SessaoAvulsaIniciada[] | null) ?? [])[0];
    if (error || !linha) {
      console.error("iniciar_sessao_questoes_avulsa (meta) falhou:", {
        message: error?.message,
        code: error?.code,
        details: error?.details,
        hint: error?.hint,
      });
      setMensagem("Não foi possível iniciar a sessão. Tente novamente.");
      setCarregando(false);
      return;
    }

    const ids = linha.questao_ids.map(Number).filter(Number.isInteger);
    const preparadas = await buscarDetalhesQuestoes(supabase, ids);
    if (!preparadas) {
      setMensagem("Ainda não há questões cadastradas para este curso.");
      setCarregando(false);
      return;
    }

    setNivel(meta);
    setQuestoes(preparadas);
    setSessaoId(Number(linha.sessao_id));
    atualizarUrlSessaoAvulsa(Number(linha.sessao_id));
    setCarregando(false);
  }

  const iniciarSessaoPersonalizada = useCallback(async () => {
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

    // Fase 2C: promovido a estado aqui especificamente para useSessaoTempo
    // (fluxo de questões da missão) — nada mudou no resto desta função.
    setMatriculaId(matricula.id);

    let ids: number[] = [];
    let sessaoDaMissao: SessaoMissao | SessaoPratica | null = null;
    let sessaoAvulsaId: number | null = null;

    // Modo Papiro por unidades pedagógicas (Fase 2J-F): quando a URL pede
    // uma unidade específica ou a Missão Final, a seleção é INTEIRA
    // responsabilidade do servidor — nenhum id de questão é calculado no
    // cliente nem enviado como entrada (diferente do fluxo antigo abaixo,
    // que só valida ids computados no cliente). unidadePedagogicaId e
    // missaoFinal nunca coexistem (lerPraticaPapiro nunca devolve os dois).
    if (unidadePedagogicaId) {
      const { data, error } = await supabase.rpc("iniciar_pratica_unidade", {
        p_missao_id: missionId,
        p_unidade_pedagogica_id: unidadePedagogicaId,
        p_refazer: refazerMissao,
      });
      const linha = ((data as SessaoPratica[] | null) ?? [])[0] ?? null;

      if (error || !linha) {
        setMensagemPersonalizada(
          error?.message.toLowerCase().includes("teoria")
            ? "Conclua a teoria desta unidade antes de iniciar as questões."
            : "Não foi possível iniciar a prática desta unidade.",
        );
        setCarregandoPersonalizada(false);
        return;
      }

      if (linha.sessao_status === "concluida") {
        window.location.replace(`/questoes/resultado?sessao=${linha.sessao_id}`);
        return;
      }

      sessaoDaMissao = linha;
      ids = linha.questao_ids.map(Number).filter(Number.isInteger);
    } else if (missaoFinal) {
      const { data, error } = await supabase.rpc("iniciar_missao_final", {
        p_missao_id: missionId,
        p_refazer: refazerMissao,
      });
      const linha = ((data as SessaoPratica[] | null) ?? [])[0] ?? null;

      if (error || !linha) {
        setMensagemPersonalizada(
          error?.message.toLowerCase().includes("missao final") || error?.message.toLowerCase().includes("pratica")
            ? "Conclua a teoria e a prática de todas as unidades antes da Missão Final."
            : "Não foi possível iniciar a Missão Final.",
        );
        setCarregandoPersonalizada(false);
        return;
      }

      if (linha.sessao_status === "concluida") {
        window.location.replace(`/questoes/resultado?sessao=${linha.sessao_id}`);
        return;
      }

      sessaoDaMissao = linha;
      ids = linha.questao_ids.map(Number).filter(Number.isInteger);
    } else if (missionId) {
      // Missão sem unidade pedagógica/Missão Final: seleção calculada no
      // cliente, validada e fechada dentro de iniciar_questoes_da_missao
      // (fluxo antigo, inalterado).
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

      ids = ((idsQuestoes as IdQuestao[] | null) ?? []).map((item) => item.questao_id);

      if (ids.length === 0) {
        setMensagemPersonalizada("Não há questões disponíveis para esse filtro.");
        setCarregandoPersonalizada(false);
        return;
      }

      const { data, error } = await supabase.rpc("iniciar_questoes_da_missao", {
        p_missao_id: missionId,
        p_questao_ids: ids,
        p_refazer: refazerMissao,
      });
      const linhaMissao = ((data as SessaoMissao[] | null) ?? [])[0] ?? null;
      sessaoDaMissao = linhaMissao;

      if (error || !linhaMissao) {
        setMensagemPersonalizada(
          error?.message.toLowerCase().includes("teoria")
            ? "Conclua todas as unidades da teoria antes de iniciar as questões."
            : "Não foi possível iniciar as questões desta missão.",
        );
        setCarregandoPersonalizada(false);
        return;
      }

      if (linhaMissao.sessao_status === "concluida") {
        window.location.replace(`/questoes/resultado?sessao=${linhaMissao.sessao_id}`);
        return;
      }

      ids = linhaMissao.questao_ids.map(Number).filter(Number.isInteger);
    } else {
      // Horas Líquidas 1.0 — sessão AVULSA/PERSONALIZADA de verdade (sem
      // missão): uma única RPC atômica e idempotente faz tudo —
      // seleciona as questões, cria OU recupera a sessão compatível, e
      // PERSISTE a lista+ordem em sessao_questoes_planejadas (antes isso
      // nunca era gravado; é o que agora permite sobreviver a um F5).
      const { data, error } = await supabase.rpc("iniciar_sessao_questoes_avulsa", {
        p_nivel_meta: "personalizada",
        p_quantidade: quantidadePersonalizada,
        p_materia_id: materiaSelecionada,
        p_assunto_id: assuntoSelecionado,
      });

      const linha = ((data as SessaoAvulsaIniciada[] | null) ?? [])[0];
      if (error || !linha) {
        console.error("iniciar_sessao_questoes_avulsa (personalizada) falhou:", {
          message: error?.message,
          code: error?.code,
          details: error?.details,
          hint: error?.hint,
        });
        setMensagemPersonalizada("Não foi possível carregar as questões para esse filtro.");
        setCarregandoPersonalizada(false);
        return;
      }

      ids = linha.questao_ids.map(Number).filter(Number.isInteger);
      sessaoAvulsaId = Number(linha.sessao_id);
    }

    // Mesma busca por detalhes só dos IDs já autorizados pela RPC — nunca um
    // fallback para o banco global nem para outro curso (mesmo padrão de
    // iniciarSessao).
    const preparadas = await buscarDetalhesQuestoes(supabase, ids);
    if (!preparadas) {
      setMensagemPersonalizada("Não há questões disponíveis para esse filtro.");
      setCarregandoPersonalizada(false);
      return;
    }

    // Missão: id já veio de iniciar_pratica_unidade/iniciar_missao_final/
    // iniciar_questoes_da_missao. Avulsa: id já veio de
    // iniciar_sessao_questoes_avulsa. Nenhum dos dois caminhos faz mais
    // nenhum INSERT aqui.
    const sessaoIdAtual = sessaoDaMissao ? Number(sessaoDaMissao.sessao_id) : sessaoAvulsaId;
    if (!sessaoIdAtual) {
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
    setSessaoId(sessaoIdAtual);
    if (!sessaoDaMissao) atualizarUrlSessaoAvulsa(sessaoIdAtual);
    setCarregandoPersonalizada(false);
  }, [assuntoSelecionado, materiaSelecionada, missionId, quantidadePersonalizada, refazerMissao, unidadePedagogicaId, missaoFinal]);

  useEffect(() => {
    const podeIniciar = podeIniciarMissaoAutomaticamente({
      origemCronograma,
      jaIniciada: autoInicioExecutado.current,
      materiaId: materiaSelecionada,
      materiasDisponiveis: materiasCurso.map((materia) => materia.materia_id),
      carregandoMaterias,
      carregandoAssuntos,
      assuntoPendente: assuntoInicialMissao.current !== null,
    });

    if (!podeIniciar) return;

    autoInicioExecutado.current = true;
    setAutoInicioSolicitado(true);
    void iniciarSessaoPersonalizada();
  }, [
    carregandoAssuntos,
    carregandoMaterias,
    iniciarSessaoPersonalizada,
    materiaSelecionada,
    materiasCurso,
    origemCronograma,
  ]);

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

  function alternarAlternativaEliminada(id:number) {
    if(feedback) return;
    setAlternativasEliminadas(atuais=>{
      const proximas=new Set(atuais);
      if(proximas.has(id)) proximas.delete(id);
      else proximas.add(id);
      return proximas;
    });
    if(alternativaId===id) setAlternativaId(null);
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
      setAlternativasEliminadas(new Set());
      setFeedback(null);
      setCausaErro(null);
      setClassificando(false);
      setClassificado(false);
      setErroClassificacao("");
      setMensagem("");
      return;
    }

    // Modo Papiro por unidades pedagógicas: cada tipo de prática fecha sua
    // própria RPC e decide seu próprio destino — nunca reaproveita
    // concluir_questoes_da_missao (que fecha a MISSÃO inteira, não uma
    // unidade isolada).
    if (unidadePedagogicaId) {
      const { data, error } = await createClient().rpc("concluir_pratica_unidade", {
        p_missao_id: missionId,
        p_sessao_id: sessaoId,
      });
      if (error) {
        setMensagem("Não foi possível concluir a prática desta unidade. Confira se todas as questões foram respondidas e tente novamente.");
        return;
      }
      const resultado = ((data as { missao_final_liberada: boolean }[] | null) ?? [])[0];
      const proximaEtapa = resultado?.missao_final_liberada ? "missaoFinal" : "unidade";
      // Fase 2C: encerra o cronômetro de questões (uma vez por execução,
      // nunca por questão) antes de navegar — nunca bloqueia: erro aqui só
      // deixa o cronômetro em "erro" (ver encerrarEstudo em
      // sessaoTempoControlador.ts), a navegação pedagógica segue sempre.
      await sessaoTempo.encerrarEstudo();
      window.location.replace(`/questoes/resultado?sessao=${sessaoId}&proximo=${proximaEtapa}`);
      return;
    }

    if (missaoFinal) {
      const { error } = await createClient().rpc("concluir_missao_final", {
        p_missao_id: missionId,
        p_sessao_id: sessaoId,
      });
      if (error) {
        setMensagem("Não foi possível concluir a Missão Final. Confira se todas as questões foram respondidas e tente novamente.");
        return;
      }
      await sessaoTempo.encerrarEstudo();
      window.location.replace(`/questoes/resultado?sessao=${sessaoId}`);
      return;
    }

    if (missionId) {
      const { error } = await createClient().rpc("concluir_questoes_da_missao", {
        p_missao_id: missionId,
        p_sessao_id: sessaoId,
      });
      if (error) {
        setMensagem("Não foi possível concluir a missão. Confira se todas as questões foram respondidas e tente novamente.");
        return;
      }
    } else {
      const { error } = await createClient().from("sessoes_estudo").update({
        status: "concluida",
        fim_em: new Date().toISOString(),
      }).eq("id", sessaoId);
      if (error) {
        setMensagem("Não foi possível concluir a sessão.");
        return;
      }
    }
    // Fase 2C.1: este ramo agora cobre tanto missão (if acima) quanto as
    // duas sessões avulsas (else acima) — encerrarEstudo() já sabe não
    // fazer nada se por algum motivo o cronômetro nunca chegou a
    // "ativa"/"pausada".
    await sessaoTempo.encerrarEstudo();
    window.location.replace(`/questoes/resultado?sessao=${sessaoId}`);
  }

  const materiaDaMissaoDisponivel = Boolean(
    materiaSelecionada &&
      materiasCurso.some((materia) => materia.materia_id === materiaSelecionada),
  );

  if (recuperandoSessaoAvulsa) {
    return (
      <main className="dashboard-loading">
        <MarcaCarregando texto="Recuperando sua sessão..." />
      </main>
    );
  }

  if (
    origemCronograma &&
    !nivel &&
    ((!autoInicioSolicitado &&
      (!mensagemPersonalizada || materiaDaMissaoDisponivel)) ||
      carregandoMaterias ||
      carregandoAssuntos ||
      carregandoPersonalizada)
  ) {
    return (
      <main className="dashboard-loading">
        <MarcaCarregando texto="Preparando sua missão..." />
      </main>
    );
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
              ? "A matéria e, quando disponível, o assunto de hoje já estão selecionados."
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

  const materiaNomeAtual = materiasCurso.find((materia) => materia.materia_id === materiaSelecionada)?.materia_nome ?? null;
  const assuntoNomeAtual = assuntosCurso.find((assunto) => assunto.assunto_id === assuntoSelecionado)?.assunto_nome ?? null;

  return (
    <main className="method-page question-session">
    <div className="questoes-area">
      <header className="session-topbar">
        <Link
          href="/painel"
          onClick={(evento) => {
            // Fase 2C: saída manual durante a sessão — encerra o cronômetro
            // ANTES de navegar (mesmo padrão de concluirUnidade em
            // app/teoria/page.tsx), por isso troca a navegação client-side
            // do Link por um window.location.assign após o await.
            evento.preventDefault();
            void sessaoTempo.encerrarEstudo().then(() => window.location.assign("/painel"));
          }}
        >
          PAPIRO
        </Link>
        <div><span>{tituloSessaoAtual}</span><strong>{indice + 1} de {questoes.length}</strong></div>
      </header>
      <div className="session-progress" aria-label={`${progresso}% concluído`}><span style={{ width: `${progresso}%` }} /></div>

      {/* Horas Líquidas 1.0: widget flutuante (position:fixed) — não
          depende mais de coluna lateral/compacta; CronometroEstudo já
          retorna null em estado "ociosa". */}
      <CronometroEstudo sessao={sessaoTempo} contexto={assuntoNomeAtual || materiaNomeAtual} />

      <article className="question-card">
        <div className="question-origin">
          <span className="question-origin-main">{origemQuestao}</span>
        </div>
        <div className="question-meta">
          <span>{questaoAtual.materias?.nome ?? "Matéria geral"}</span>
          <span>{questaoAtual.assuntos?.nome ?? "Assunto geral"}</span>
        </div>
        <h1>{questaoAtual.enunciado}</h1>
        <div className="answer-list">
          {questaoAtual.alternativas.map((alternativa) => {
            const eliminada=alternativasEliminadas.has(alternativa.id);
            return <div key={alternativa.id} className={`answer-option-row${eliminada?" eliminated":""}`}>
              <button
                type="button"
                className={`answer-choice${alternativaId === alternativa.id ? " selected" : ""}`}
                onClick={() => !feedback&&!eliminada&&setAlternativaId(alternativa.id)}
                disabled={Boolean(feedback)||eliminada}
              >
                <b>{String.fromCharCode(64 + alternativa.ordem)}</b>
                <span>{alternativa.texto}</span>
              </button>
              <button
                type="button"
                className="answer-cut"
                aria-pressed={eliminada}
                aria-label={`${eliminada?"Restaurar":"Riscar"} alternativa ${String.fromCharCode(64 + alternativa.ordem)}`}
                onClick={()=>alternarAlternativaEliminada(alternativa.id)}
                disabled={Boolean(feedback)}
              ><span aria-hidden="true">✂</span><span>{eliminada?"Restaurar":"Riscar"}</span></button>
            </div>;
          })}
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
      <ComentariosQuestao key={questaoAtual.id} questaoId={questaoAtual.id} />
      <aside className="session-score">Acertos nesta sessão: <strong>{acertos}</strong></aside>
    </div>
    </main>
  );
}
