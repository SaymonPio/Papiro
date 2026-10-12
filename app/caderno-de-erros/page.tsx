"use client";

import Link from "next/link";
import {
  BookOpen,
  CalendarDays,
  ChartNoAxesColumnIncreasing,
  ChevronDown,
  ChevronRight,
  Clock3,
  FileText,
  GraduationCap,
  Info,
  Play,
  Plus,
  Search,
  SlidersHorizontal,
  Target,
  TrendingUp,
} from "lucide-react";
import { useEffect, useMemo, useRef, useState } from "react";
import MarcaCarregando from "@/components/ui/MarcaCarregando";
import { createClient } from "@/utils/supabase/client";
import { montarLinkRevisao, montarLinkRevisaoPersonalizada } from "@/utils/missao-cronograma.mjs";

// Mesmo helper de data local duplicado em app/estatisticas e
// components/painel/WeeklyStatsCard — evita o viés de fuso de
// toISOString() ao comparar com agendada_para (date, sem hora).
function dataLocal(data: Date) {
  return `${data.getFullYear()}-${String(data.getMonth() + 1).padStart(2, "0")}-${String(data.getDate()).padStart(2, "0")}`;
}

type ErroAluno = {
  id: number;
  tipo_erro: string | null;
  motivo_provavel: string | null;
  corrigido: boolean;
  criado_em: string;
  enunciado: string | null;
  materia_nome: string | null;
  assunto_nome: string | null;
  revisoes: { agendada_para: string; ordem: number; status: string }[];
};

// Retorno de revisoes_do_curso_ativo() (supabase/consultas_curso_ativo.sql)
// — único lugar que expõe desempenho_pos_revisao, por isso é buscado em
// paralelo com erros_do_curso_ativo() (que não tem essa coluna no jsonb
// embutido). Mesma fonte já usada por app/painel e app/cronograma.
type RevisaoAluno = {
  status: string;
  agendada_para: string;
  desempenho_pos_revisao: number | string | null;
};

// Mesmos tipos/RPCs já usados em app/questoes/page.tsx (modo "Sessão
// personalizada") — reaproveitados aqui tal qual, sem duplicar a forma.
type MateriaCursoAtivo = { materia_id: number; materia_nome: string; total_questoes: number | string };
type AssuntoCursoAtivo = { assunto_id: number; assunto_nome: string; total_questoes: number | string };

type TipoErroFiltro = "" | "nao_sabia" | "duvida" | "chute" | "atencao" | "interpretacao";
type Situacao = "vencidas" | "hoje" | "proximas" | "todas";

const ROTULOS_TIPO_ERRO: Record<string, string> = {
  nao_sabia: "Não sabia",
  duvida: "Dúvida",
  chute: "Chute",
  atencao: "Atenção",
  interpretacao: "Interpretação",
  // Valores legados (classificar_erro só grava os 5 acima desde antes
  // desta tela existir, mas dados antigos podem ter um destes):
  falta_conhecimento: "Falta de conhecimento",
  confusao_conceitos: "Confusão de conceitos",
  desatencao: "Desatenção",
  esquecimento: "Esquecimento",
  calculo: "Erro de cálculo",
};

function rotuloTipoErro(tipo: string | null) {
  if (!tipo) return "Não classificado";
  return ROTULOS_TIPO_ERRO[tipo] ?? tipo.replaceAll("_", " ");
}

// Hotfix P2: "Revisar matéria" fixava situacao="vencidas" mesmo quando a
// matéria não tinha nenhuma revisão vencida (só "hoje"/"próximas"), levando
// a um "Nenhuma revisão encontrada" evitável. Mesma prioridade temporal já
// usada pelos indicadores desta tela (vencida > hoje > futura) — nunca cai
// em situacao="todas" por padrão, pra preservar o recorte temporal que o
// aluno espera ao clicar no card da matéria. null = matéria sem nenhuma
// pendência, botão não deve aparecer.
function obterSituacaoRevisaoMateria(materia: { vencidas: number; hoje: number; proximas: number }): Situacao | null {
  if (materia.vencidas > 0) return "vencidas";
  if (materia.hoje > 0) return "hoje";
  if (materia.proximas > 0) return "proximas";
  return null;
}

const OPCOES_SITUACAO: { valor: Situacao; rotulo: string }[] = [
  { valor: "vencidas", rotulo: "Vencidas" },
  { valor: "hoje", rotulo: "Hoje" },
  { valor: "proximas", rotulo: "Próximas" },
  { valor: "todas", rotulo: "Todas pendentes" },
];

const OPCOES_TIPO_ERRO: { valor: TipoErroFiltro; rotulo: string }[] = [
  { valor: "", rotulo: "Todos" },
  { valor: "nao_sabia", rotulo: "Não sabia" },
  { valor: "duvida", rotulo: "Dúvida" },
  { valor: "chute", rotulo: "Chute" },
  { valor: "atencao", rotulo: "Atenção" },
  { valor: "interpretacao", rotulo: "Interpretação" },
];

const OPCOES_QUANTIDADE = [10, 20, 50] as const;

// Só 3 matérias ficam como card em destaque (a 4ª posição é sempre o
// convite "Outras matérias") — "Ver todas" expande o restante abaixo.
const MATERIAS_EM_DESTAQUE = 3;

export default function CadernoDeErros() {
  const [erros, setErros] = useState<ErroAluno[]>([]);
  const [revisoes, setRevisoes] = useState<RevisaoAluno[]>([]);
  const [carregando, setCarregando] = useState(true);
  const [mensagem, setMensagem] = useState("");
  const [semContexto, setSemContexto] = useState(false);
  const [mostrarTodasMaterias, setMostrarTodasMaterias] = useState(false);
  const painelFiltrosRef = useRef<HTMLDivElement | null>(null);

  // Interatividade (sem nenhuma biblioteca nova — CSS transitions + estado
  // simples, mesmo espírito do resto do projeto):
  // - barrasProntas: as barras nascem em 0% e crescem até o valor real
  //   assim que os dados chegam (transição de width), em vez de aparecer
  //   já no tamanho final.
  // - materiaExpandida: clicar num card de matéria revela o diagnóstico
  //   completo (todos os assuntos, não só os 3 do resumo) sem navegar.
  // - mostrarTodosErros/buscaErro: a lista completa de erros no fim da
  //   página começa recolhida e tem busca client-side (sem RPC nova).
  const [barrasProntas, setBarrasProntas] = useState(false);
  const [materiaExpandida, setMateriaExpandida] = useState<string | null>(null);
  const [mostrarTodosErros, setMostrarTodosErros] = useState(false);
  const [buscaErro, setBuscaErro] = useState("");

  // Filtros da revisão personalizada (Beta 1.1) — mesmo padrão de estado
  // controlado já usado em app/questoes/page.tsx (modo "Sessão
  // personalizada"): matéria escolhida recarrega os assuntos daquela
  // matéria; nenhum filtro é obrigatório.
  const [materiasCurso, setMateriasCurso] = useState<MateriaCursoAtivo[]>([]);
  const [assuntosCurso, setAssuntosCurso] = useState<AssuntoCursoAtivo[]>([]);
  const [carregandoAssuntos, setCarregandoAssuntos] = useState(false);
  const [filtroMateriaId, setFiltroMateriaId] = useState<number | null>(null);
  const [filtroAssuntoId, setFiltroAssuntoId] = useState<number | null>(null);
  const [filtroTipoErro, setFiltroTipoErro] = useState<TipoErroFiltro>("");
  const [filtroSituacao, setFiltroSituacao] = useState<Situacao>("vencidas");
  const [filtroQuantidade, setFiltroQuantidade] = useState(20);
  const [quantidadeDisponivel, setQuantidadeDisponivel] = useState<number | null>(null);
  const [carregandoContagem, setCarregandoContagem] = useState(false);
  const [erroContagem, setErroContagem] = useState("");

  useEffect(() => {
    async function carregarCentral() {
      const supabase = createClient();
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) { window.location.replace("/login"); return; }

      const { data: perfil } = await supabase
        .from("perfis")
        .select("curso_ativo_id")
        .eq("usuario_id", user.id)
        .maybeSingle();

      if (!perfil?.curso_ativo_id) {
        setMensagem("Selecione um curso ativo para ver sua central de revisões.");
        setSemContexto(true);
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
        setSemContexto(true);
        setCarregando(false);
        return;
      }

      const [resultadoErros, resultadoRevisoes, resultadoMaterias] = await Promise.all([
        supabase.rpc("erros_do_curso_ativo"),
        supabase.rpc("revisoes_do_curso_ativo"),
        supabase.rpc("materias_do_curso_ativo"),
      ]);

      if (resultadoErros.error) {
        console.error("erros_do_curso_ativo falhou:", {
          message: resultadoErros.error.message,
          code: resultadoErros.error.code,
          details: resultadoErros.error.details,
          hint: resultadoErros.error.hint,
        });
        setMensagem("Não foi possível carregar seu caderno de erros.");
      } else {
        setErros((resultadoErros.data as ErroAluno[] | null) ?? []);
      }

      if (resultadoRevisoes.error) {
        console.error("revisoes_do_curso_ativo falhou na central de revisões:", {
          message: resultadoRevisoes.error.message,
          code: resultadoRevisoes.error.code,
        });
      } else {
        setRevisoes((resultadoRevisoes.data as RevisaoAluno[] | null) ?? []);
      }

      if (!resultadoMaterias.error) {
        setMateriasCurso((resultadoMaterias.data as MateriaCursoAtivo[] | null) ?? []);
      }

      setCarregando(false);
    }
    carregarCentral();
  }, []);

  // Dispara a animação de "crescer" das barras um instante depois dos
  // dados carregarem — nunca no mesmo frame (senão o navegador não tem
  // como animar a transição de width 0% -> valor real).
  useEffect(() => {
    if (carregando) return;
    const agendamento = window.setTimeout(() => setBarrasProntas(true), 60);
    return () => window.clearTimeout(agendamento);
  }, [carregando]);

  // Mesmo efeito/RPC já usado em app/questoes/page.tsx para popular o
  // seletor de assunto a partir da matéria escolhida.
  useEffect(() => {
    if (!filtroMateriaId) { setAssuntosCurso([]); return; }
    let ativo = true;
    async function carregarAssuntos() {
      setCarregandoAssuntos(true);
      const { data, error } = await createClient().rpc("assuntos_do_curso_ativo", { p_materia_id: filtroMateriaId });
      if (!ativo) return;
      if (error) {
        console.error("assuntos_do_curso_ativo falhou na central de revisões:", { message: error.message, code: error.code });
      } else {
        setAssuntosCurso((data as AssuntoCursoAtivo[] | null) ?? []);
      }
      setCarregandoAssuntos(false);
    }
    carregarAssuntos();
    return () => { ativo = false; };
  }, [filtroMateriaId]);

  // Preview "N questões disponíveis" — mesma regra server-side de
  // iniciar_revisao_personalizada (contar_revisoes_personalizadas só lê,
  // nunca cria sessão). Debounce simples: só conta 300ms depois da última
  // mudança de filtro, pra não disparar uma chamada por tecla/clique.
  useEffect(() => {
    const agendamento = window.setTimeout(async () => {
      setCarregandoContagem(true);
      setErroContagem("");
      const { data, error } = await createClient().rpc("contar_revisoes_personalizadas", {
        p_materia_id: filtroMateriaId,
        p_assunto_id: filtroAssuntoId,
        p_tipo_erro: filtroTipoErro || null,
        p_situacao: filtroSituacao,
      });
      setCarregandoContagem(false);
      if (error) {
        console.error("contar_revisoes_personalizadas falhou:", { message: error.message, code: error.code });
        setErroContagem("Não foi possível calcular quantas revisões combinam com esses filtros.");
        setQuantidadeDisponivel(null);
        return;
      }
      setQuantidadeDisponivel(typeof data === "number" ? data : Number(data) || 0);
    }, 300);
    return () => window.clearTimeout(agendamento);
  }, [filtroMateriaId, filtroAssuntoId, filtroTipoErro, filtroSituacao]);

  const hojeChave = dataLocal(new Date());

  // PAPIRO Beta 1 — revisão executável: "devida hoje" usa a mesma regra de
  // "vencida" já adotada em app/estatisticas e app/cronograma (pendente e
  // agendada_para <= hoje local), sem inventar um novo critério.
  const existeRevisaoDevida = erros.some((erro) =>
    erro.revisoes.some((revisao) => revisao.status === "pendente" && revisao.agendada_para <= hojeChave)
  );

  const indicadores = useMemo(() => {
    const pendentes = revisoes.filter((r) => r.status === "pendente");
    const vencidas = pendentes.filter((r) => r.agendada_para < hojeChave);
    const concluidasComDesempenho = revisoes.filter(
      (r) => r.status === "concluida" && r.desempenho_pos_revisao !== null && r.desempenho_pos_revisao !== undefined
    );
    const recuperadas = concluidasComDesempenho.filter((r) => Number(r.desempenho_pos_revisao) >= 1);
    // Sem dados suficientes = null (nunca inventa 0%/100% — ver auditoria:
    // hoje as 2 únicas revisões concluídas no banco têm desempenho_pos_
    // revisao nulo, herdado de um fluxo anterior a concluir_revisao()).
    const taxaRecuperacao = concluidasComDesempenho.length > 0
      ? Math.round((recuperadas.length / concluidasComDesempenho.length) * 100)
      : null;

    return { pendentes: pendentes.length, vencidas: vencidas.length, taxaRecuperacao };
  }, [revisoes, hojeChave]);

  const distribuicaoTipoErro = useMemo(() => {
    const total = erros.length;
    if (total === 0) return [] as { chave: string; rotulo: string; contagem: number; percentual: number }[];
    const contagem = new Map<string, number>();
    for (const erro of erros) {
      const chave = erro.tipo_erro ?? "__nao_classificado__";
      contagem.set(chave, (contagem.get(chave) ?? 0) + 1);
    }
    return [...contagem.entries()]
      .map(([chave, valor]) => ({
        chave,
        rotulo: chave === "__nao_classificado__" ? "Não classificado" : rotuloTipoErro(chave),
        contagem: valor,
        percentual: Math.round((valor / total) * 100),
      }))
      .sort((a, b) => b.contagem - a.contagem);
  }, [erros]);

  const principalErro = distribuicaoTipoErro[0] ?? null;

  const materiaIdPorNome = useMemo(() => {
    const mapa = new Map<string, number>();
    for (const materia of materiasCurso) mapa.set(materia.materia_nome, materia.materia_id);
    return mapa;
  }, [materiasCurso]);

  const porMateria = useMemo(() => {
    const grupos = new Map<string, ErroAluno[]>();
    for (const erro of erros) {
      const nome = erro.materia_nome ?? "Matéria geral";
      const lista = grupos.get(nome) ?? [];
      lista.push(erro);
      grupos.set(nome, lista);
    }
    return [...grupos.entries()]
      .map(([nome, errosDaMateria]) => {
        const todasRevisoes = errosDaMateria.flatMap((e) => e.revisoes);
        const pendentes = todasRevisoes.filter((r) => r.status === "pendente");
        const vencidas = pendentes.filter((r) => r.agendada_para < hojeChave);
        // Mesma partição de "situacao" usada server-side em contar_revisoes_
        // personalizadas/iniciar_revisao_personalizada (vencidas: <, hoje: =,
        // proximas: >) — necessária aqui para o botão "Revisar matéria" poder
        // escolher a situação coerente com as pendências reais da matéria
        // (hotfix P2: antes fixava "vencidas" mesmo sem nenhuma vencida).
        const hoje = pendentes.filter((r) => r.agendada_para === hojeChave);
        const proximas = pendentes.filter((r) => r.agendada_para > hojeChave);

        const contagemTipo = new Map<string, number>();
        for (const erro of errosDaMateria) {
          const chave = erro.tipo_erro ?? "__nao_classificado__";
          contagemTipo.set(chave, (contagemTipo.get(chave) ?? 0) + 1);
        }
        const [tipoMaisComumChave, tipoMaisComumContagem] =
          [...contagemTipo.entries()].sort((a, b) => b[1] - a[1])[0] ?? [null, 0];
        const tipoMaisComum = tipoMaisComumChave
          ? {
              rotulo: tipoMaisComumChave === "__nao_classificado__" ? "Não classificado" : rotuloTipoErro(tipoMaisComumChave),
              percentual: Math.round((tipoMaisComumContagem / errosDaMateria.length) * 100),
            }
          : null;

        const contagemAssunto = new Map<string, number>();
        for (const erro of errosDaMateria) {
          const nomeAssunto = erro.assunto_nome ?? "Assunto geral";
          contagemAssunto.set(nomeAssunto, (contagemAssunto.get(nomeAssunto) ?? 0) + 1);
        }
        const assuntosOrdenados = [...contagemAssunto.entries()]
          .sort((a, b) => b[1] - a[1])
          .map(([nomeAssunto, contagem]) => ({ nome: nomeAssunto, contagem }));

        return {
          nome,
          materiaId: materiaIdPorNome.get(nome) ?? null,
          totalErros: errosDaMateria.length,
          pendentes: pendentes.length,
          vencidas: vencidas.length,
          hoje: hoje.length,
          proximas: proximas.length,
          tipoMaisComum,
          // Resumo (card recolhido) vs. diagnóstico completo (card
          // expandido via "Ver diagnóstico") — mesma lista, só o corte
          // muda, nenhuma chamada nova ao banco.
          assuntosProblematicos: assuntosOrdenados.slice(0, 3),
          todosAssuntos: assuntosOrdenados,
        };
      })
      .sort((a, b) => b.vencidas - a.vencidas || b.totalErros - a.totalErros);
  }, [erros, hojeChave, materiaIdPorNome]);

  const materiaMaisVencida = porMateria.find((materia) => materia.vencidas > 0) ?? null;
  const materiasVisiveis = mostrarTodasMaterias ? porMateria : porMateria.slice(0, MATERIAS_EM_DESTAQUE);

  // "Ver diagnóstico" alterna o painel expandido INLINE (não navega, não
  // rola a página) e, em paralelo, já deixa essa matéria pré-selecionada
  // no painel de filtros mais abaixo — se o aluno descer até lá, já
  // encontra o filtro certo aplicado.
  function alternarDiagnosticoMateria(nome: string, materiaId: number) {
    setMateriaExpandida((atual) => (atual === nome ? null : nome));
    setFiltroMateriaId(materiaId);
    setFiltroAssuntoId(null);
  }

  const errosFiltrados = useMemo(() => {
    const termo = buscaErro.trim().toLocaleLowerCase("pt-BR");
    if (!termo) return erros;
    return erros.filter((erro) =>
      (erro.enunciado ?? "").toLocaleLowerCase("pt-BR").includes(termo) ||
      (erro.materia_nome ?? "").toLocaleLowerCase("pt-BR").includes(termo) ||
      (erro.assunto_nome ?? "").toLocaleLowerCase("pt-BR").includes(termo) ||
      rotuloTipoErro(erro.tipo_erro).toLocaleLowerCase("pt-BR").includes(termo)
    );
  }, [erros, buscaErro]);

  const linkRevisaoPersonalizada = montarLinkRevisaoPersonalizada({
    materiaId: filtroMateriaId,
    assuntoId: filtroAssuntoId,
    tipoErro: filtroTipoErro || null,
    situacao: filtroSituacao,
    quantidade: filtroQuantidade,
  });
  const podeIniciarPersonalizada = !carregandoContagem && !erroContagem && (quantidadeDisponivel ?? 0) > 0;

  if (carregando) return <main className="dashboard-loading"><MarcaCarregando texto="Abrindo sua central de revisões..." /></main>;

  return (
    <main className="method-page error-notebook central-revisoes">
      <div className="cr-topo">
        <Link href="/painel" className="cr-voltar">← Voltar ao painel</Link>
        <div className="cr-topo-grade">
          <div className="cr-intro">
            <p className="dashboard-label">CENTRAL DE REVISÕES</p>
            <h1>Transforme seus erros em domínio.</h1>
            <span>Entenda o motivo, corrija a falha e consolide o assunto.</span>
          </div>

          {existeRevisaoDevida && (
            <div className="cr-hero">
              <span className="cr-hero-icone" aria-hidden="true"><CalendarDays size={22} strokeWidth={1.8} /></span>
              <div className="cr-hero-corpo">
                <strong>{indicadores.vencidas} revisõe{indicadores.vencidas === 1 ? "" : "s"} vencida{indicadores.vencidas === 1 ? "" : "s"}</strong>
                <p>Resolva primeiro o que já está atrasado.</p>
                <Link className="cr-hero-cta" href={montarLinkRevisao()}>
                  <Play size={14} strokeWidth={2} fill="currentColor" /> Revisar pendências de hoje
                </Link>
              </div>
            </div>
          )}
        </div>
      </div>

      {semContexto ? (
        <p className="method-message" role="alert">{mensagem}</p>
      ) : (
        <>
          {mensagem && <p className="method-message" role="alert">{mensagem}</p>}

          {erros.length === 0 ? (
            <section className="empty-method-state"><h2>Nenhum erro registrado</h2><p>Quando você errar uma questão, ela aparecerá aqui com as revisões programadas.</p><Link href="/questoes">Iniciar sessão</Link></section>
          ) : (
            <>
              <section className="cr-indicadores" aria-label="Indicadores principais">
                <div className="cr-indicador">
                  <span className="cr-indicador-icone cr-icone-verde" aria-hidden="true"><FileText size={18} strokeWidth={1.8} /></span>
                  <small>PENDENTES</small>
                  <strong>{indicadores.pendentes}</strong>
                  <em>revisões agendadas</em>
                </div>
                <div className="cr-indicador cr-indicador--alerta">
                  <span className="cr-indicador-icone cr-icone-vermelho" aria-hidden="true"><Clock3 size={18} strokeWidth={1.8} /></span>
                  <small>VENCIDAS</small>
                  <strong>{indicadores.vencidas}</strong>
                  <em>precisam da sua atenção</em>
                </div>
                <div className="cr-indicador">
                  <span className="cr-indicador-icone cr-icone-verde" aria-hidden="true"><ChartNoAxesColumnIncreasing size={18} strokeWidth={1.8} /></span>
                  <small>
                    RECUPERAÇÃO
                    <Info size={12} strokeWidth={2} tabIndex={0} aria-label="O que é a taxa de recuperação?" />
                    <span className="cr-tooltip" role="tooltip">Revisões concluídas em que você acertou a questão, entre as que já têm desempenho registrado.</span>
                  </small>
                  <strong>{indicadores.taxaRecuperacao === null ? "—" : `${indicadores.taxaRecuperacao}%`}</strong>
                  <em>{indicadores.taxaRecuperacao === null ? "ainda sem revisões concluídas suficientes" : "das suas revisões concluídas"}</em>
                </div>
                <div className="cr-indicador">
                  <span className="cr-indicador-icone cr-icone-dourado" aria-hidden="true"><Target size={18} strokeWidth={1.8} /></span>
                  <small>PRINCIPAL ERRO</small>
                  <strong>{principalErro ? principalErro.rotulo : "—"}</strong>
                  <em>{principalErro ? `${principalErro.percentual}% dos seus erros` : "sem dados ainda"}</em>
                </div>
              </section>

              <section className="cr-duas-colunas">
                {distribuicaoTipoErro.length > 0 && (
                  <div className="cr-diagnostico">
                    <p className="dashboard-label"><SlidersHorizontal size={14} strokeWidth={2} aria-hidden="true" /> ONDE VOCÊ ESTÁ ERRANDO</p>
                    <span className="cr-subtitulo">Distribuição dos tipos de erro nos seus erros registrados.</span>
                    <div className="central-revisoes-barras">
                      {distribuicaoTipoErro.map((item) => (
                        <div key={item.chave} className="central-revisoes-barra">
                          <span>{item.rotulo}</span>
                          <div className="central-revisoes-barra-trilha">
                            <div className="central-revisoes-barra-preenchimento" style={{ width: barrasProntas ? `${item.percentual}%` : "0%" }} />
                          </div>
                          <strong>{item.percentual}%</strong>
                        </div>
                      ))}
                    </div>
                  </div>
                )}

                <aside className="cr-leitura-rapida">
                  <p className="dashboard-label"><BookOpen size={14} strokeWidth={2} aria-hidden="true" /> LEITURA RÁPIDA</p>
                  <ul>
                    {materiaMaisVencida && (
                      <li>
                        <span className="cr-leitura-icone" aria-hidden="true"><BookOpen size={16} strokeWidth={1.8} /></span>
                        <div>
                          <p>Sua maior dificuldade está em <strong>{materiaMaisVencida.nome}</strong></p>
                          <span>{materiaMaisVencida.vencidas} revisõe{materiaMaisVencida.vencidas === 1 ? "" : "s"} vencida{materiaMaisVencida.vencidas === 1 ? "" : "s"}</span>
                        </div>
                      </li>
                    )}
                    {principalErro && (
                      <li>
                        <span className="cr-leitura-icone" aria-hidden="true"><Target size={16} strokeWidth={1.8} /></span>
                        <div>
                          <p><strong>{principalErro.rotulo}</strong> é o tipo de erro mais frequente</p>
                          <span>{principalErro.percentual}% dos seus erros</span>
                        </div>
                      </li>
                    )}
                    <li>
                      <span className="cr-leitura-icone" aria-hidden="true"><TrendingUp size={16} strokeWidth={1.8} /></span>
                      <div>
                        {indicadores.taxaRecuperacao === null ? (
                          <>
                            <p>Você ainda não tem dados suficientes para a taxa de recuperação</p>
                            <span>Complete mais revisões para ver sua evolução.</span>
                          </>
                        ) : (
                          <>
                            <p>Sua taxa de recuperação é de <strong>{indicadores.taxaRecuperacao}%</strong></p>
                            <span>Considerando as revisões já concluídas.</span>
                          </>
                        )}
                      </div>
                    </li>
                  </ul>
                </aside>
              </section>

              <section className="cr-materias" aria-label="Matérias">
                <p className="dashboard-label"><GraduationCap size={14} strokeWidth={2} aria-hidden="true" /> ESCOLHA UMA MATÉRIA PARA REVISAR</p>
                <span className="cr-subtitulo">Veja suas matérias com mais erros e revisões pendentes. Clique em uma para personalizar a revisão.</span>
                <div className="cr-materias-grade">
                  {materiasVisiveis.map((materia) => {
                    const expandida = materiaExpandida === materia.nome;
                    const situacaoRevisaoMateria = obterSituacaoRevisaoMateria(materia);
                    return (
                      <article
                        key={materia.nome}
                        className={`cr-materia-card${materia.materiaId !== null && materia.materiaId === filtroMateriaId ? " cr-materia-card--selecionada" : ""}${expandida ? " cr-materia-card--expandida" : ""}`}
                      >
                        <span className="cr-materia-icone" aria-hidden="true"><GraduationCap size={18} strokeWidth={1.8} /></span>
                        <h3>{materia.nome}</h3>
                        <p>{materia.totalErros} erro{materia.totalErros === 1 ? "" : "s"}</p>
                        {materia.vencidas > 0 && <p className="cr-materia-vencidas">{materia.vencidas} revisõe{materia.vencidas === 1 ? "" : "s"} vencida{materia.vencidas === 1 ? "" : "s"}</p>}

                        {materia.tipoMaisComum && (
                          <div className="cr-materia-tipo">
                            <small>Principal tipo de erro</small>
                            <div className="cr-materia-tipo-linha">
                              <span>{materia.tipoMaisComum.rotulo}</span>
                              <strong>{materia.tipoMaisComum.percentual}%</strong>
                            </div>
                            <div className="central-revisoes-barra-trilha">
                              <div className="central-revisoes-barra-preenchimento" style={{ width: barrasProntas ? `${materia.tipoMaisComum.percentual}%` : "0%" }} />
                            </div>
                          </div>
                        )}

                        {materia.assuntosProblematicos.length > 0 && (
                          <div className="cr-materia-assuntos">
                            <small>Assuntos mais críticos</small>
                            <ul>
                              {(expandida ? materia.todosAssuntos : materia.assuntosProblematicos).map((assunto) => (
                                <li key={assunto.nome}><span>{assunto.nome}</span><strong>{assunto.contagem}</strong></li>
                              ))}
                            </ul>
                            {expandida && materia.materiaId !== null && (
                              <button
                                type="button"
                                className="cr-materia-ir-para-filtros"
                                onClick={() => painelFiltrosRef.current?.scrollIntoView({ behavior: "smooth", block: "start" })}
                              >
                                Personalizar com estes filtros <ChevronRight size={12} strokeWidth={2.5} />
                              </button>
                            )}
                          </div>
                        )}

                        <div className="cr-materia-acoes">
                          {materia.materiaId !== null && situacaoRevisaoMateria !== null && (
                            <Link
                              className="cr-materia-revisar"
                              href={montarLinkRevisaoPersonalizada({ materiaId: materia.materiaId, situacao: situacaoRevisaoMateria })}
                            >
                              Revisar matéria <ChevronRight size={14} strokeWidth={2.5} />
                            </Link>
                          )}
                          {materia.materiaId !== null && (
                            <button
                              type="button"
                              className="cr-materia-diagnostico"
                              aria-expanded={expandida}
                              onClick={() => alternarDiagnosticoMateria(materia.nome, materia.materiaId!)}
                            >
                              Ver diagnóstico <ChevronDown size={13} strokeWidth={2.5} className="cr-chevron" />
                            </button>
                          )}
                        </div>
                      </article>
                    );
                  })}

                  {!mostrarTodasMaterias && porMateria.length > MATERIAS_EM_DESTAQUE && (
                    <article className="cr-materia-card cr-materia-card--mais">
                      <span className="cr-materia-icone" aria-hidden="true"><Plus size={18} strokeWidth={1.8} /></span>
                      <h3>Outras matérias</h3>
                      <p>Explore todas as suas matérias com revisões pendentes.</p>
                      <button type="button" className="cr-materia-revisar" onClick={() => setMostrarTodasMaterias(true)}>
                        Ver todas as matérias <ChevronRight size={14} strokeWidth={2.5} />
                      </button>
                    </article>
                  )}
                </div>
              </section>

              <section className="cr-personalizar" aria-label="Personalizar revisão" ref={painelFiltrosRef}>
                <div className="cr-personalizar-cabecalho">
                  <div>
                    <p className="dashboard-label"><SlidersHorizontal size={14} strokeWidth={2} aria-hidden="true" /> PERSONALIZAR REVISÃO</p>
                    <span className="cr-subtitulo">Selecione os filtros para montar uma revisão do seu jeito.</span>
                  </div>
                  <div className="cr-personalizar-contagem">
                    <FileText size={18} strokeWidth={1.8} aria-hidden="true" />
                    <div role="status">
                      <strong>
                        {erroContagem
                          ? "—"
                          : carregandoContagem
                            ? "Calculando..."
                            : `${quantidadeDisponivel ?? 0} questõe${quantidadeDisponivel === 1 ? "" : "s"} disponíve${quantidadeDisponivel === 1 ? "l" : "is"}`}
                      </strong>
                      <span>{erroContagem ? erroContagem : "com os filtros selecionados"}</span>
                    </div>
                  </div>
                </div>

                <div className="cr-personalizar-filtros">
                  <label>
                    Matéria
                    <select
                      value={filtroMateriaId ?? ""}
                      onChange={(evento) => {
                        const valor = evento.target.value ? Number(evento.target.value) : null;
                        setFiltroMateriaId(valor);
                        setFiltroAssuntoId(null);
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
                      value={filtroAssuntoId ?? ""}
                      onChange={(evento) => setFiltroAssuntoId(evento.target.value ? Number(evento.target.value) : null)}
                      disabled={!filtroMateriaId || carregandoAssuntos}
                    >
                      <option value="">{carregandoAssuntos ? "Carregando..." : "Todos"}</option>
                      {assuntosCurso.map((assunto) => (
                        <option key={assunto.assunto_id} value={assunto.assunto_id}>{assunto.assunto_nome}</option>
                      ))}
                    </select>
                  </label>

                  <label>
                    Tipo de erro
                    <select value={filtroTipoErro} onChange={(evento) => setFiltroTipoErro(evento.target.value as TipoErroFiltro)}>
                      {OPCOES_TIPO_ERRO.map((opcao) => <option key={opcao.valor} value={opcao.valor}>{opcao.rotulo}</option>)}
                    </select>
                  </label>

                  <label>
                    Situação
                    <select value={filtroSituacao} onChange={(evento) => setFiltroSituacao(evento.target.value as Situacao)}>
                      {OPCOES_SITUACAO.map((opcao) => <option key={opcao.valor} value={opcao.valor}>{opcao.rotulo}</option>)}
                    </select>
                  </label>

                  <label>
                    Quantidade
                    <select value={filtroQuantidade} onChange={(evento) => setFiltroQuantidade(Number(evento.target.value))}>
                      {OPCOES_QUANTIDADE.map((quantidade) => (
                        <option key={quantidade} value={quantidade}>{quantidade === 50 ? "Todas" : quantidade}</option>
                      ))}
                    </select>
                  </label>

                  <button
                    type="button"
                    className="cr-personalizar-cta"
                    disabled={!podeIniciarPersonalizada}
                    onClick={() => { if (podeIniciarPersonalizada) window.location.assign(linkRevisaoPersonalizada); }}
                  >
                    <Play size={14} strokeWidth={2} fill="currentColor" /> Iniciar revisão personalizada
                  </button>
                </div>
              </section>
            </>
          )}

          {erros.length > 0 && (
            <section className="error-list cr-lista-completa" aria-label="Todos os erros registrados">
              <button
                type="button"
                className="cr-lista-completa-toggle"
                aria-expanded={mostrarTodosErros}
                onClick={() => setMostrarTodosErros((atual) => !atual)}
              >
                <p className="dashboard-label">TODOS OS SEUS ERROS ({erros.length})</p>
                <ChevronDown size={16} strokeWidth={2.5} className="cr-chevron" aria-hidden="true" />
              </button>

              {mostrarTodosErros && (
                <div className="cr-lista-completa-corpo">
                  <label className="cr-busca-erro">
                    <Search size={15} strokeWidth={2} aria-hidden="true" />
                    <input
                      type="search"
                      placeholder="Buscar por matéria, assunto, enunciado ou tipo de erro..."
                      value={buscaErro}
                      onChange={(evento) => setBuscaErro(evento.target.value)}
                    />
                  </label>

                  {errosFiltrados.length === 0 ? (
                    <p className="method-message">Nenhum erro encontrado para "{buscaErro}".</p>
                  ) : (
                    errosFiltrados.map((erro) => (
                      <article key={erro.id}>
                        <div className="error-heading"><span>{erro.materia_nome ?? "Matéria geral"}</span><small>{new Date(erro.criado_em).toLocaleDateString("pt-BR")}</small></div>
                        <h2>{erro.assunto_nome ?? "Assunto geral"}</h2>
                        <p>{erro.enunciado}</p>
                        <div className="review-dates">
                          {[...erro.revisoes].sort((a, b) => a.ordem - b.ordem).map((revisao) => <span key={revisao.ordem}>{revisao.ordem}ª revisão <strong>{new Date(`${revisao.agendada_para}T00:00:00`).toLocaleDateString("pt-BR")}</strong></span>)}
                        </div>
                        <small className="error-type">{rotuloTipoErro(erro.tipo_erro)}</small>
                      </article>
                    ))
                  )}
                </div>
              )}
            </section>
          )}
        </>
      )}
    </main>
  );
}
