"use client";

import Link from "next/link";
import { useEffect, useMemo, useState } from "react";
import { createClient } from "@/utils/supabase/client";

type CursoAtivo = {
  id: string;
  concurso: string;
  cargo: string;
  data_prova: string | null;
};

type TipoOrigemEvidencia =
  | "edital_atual"
  | "edital_anterior"
  | "prova_anterior"
  | "historico_banca"
  | "manual";

type Evidencia = {
  tipo_origem: TipoOrigemEvidencia;
  frequencia: number | null;
  descricao: string | null;
};

type EvidenciaBruta = Evidencia & {
  curso_conteudo_id: number | null;
  curso_materia_id: number | null;
};

type ConteudoBruto = {
  id: number;
  assunto_id: number;
  ordem: number;
  prioridade_estrategica: number | null;
  frequencia_historica: number | null;
  relevante_para_preparacao: boolean;
  assuntos: { nome: string } | null;
};

type MateriaCursoBruta = {
  id: number;
  nome: string;
  peso: number | null;
  prioridade_estrategica: number | null;
  frequencia_historica: number | null;
  relevante_para_preparacao: boolean;
  curso_conteudos: ConteudoBruto[];
};

type ConteudoCurso = {
  id: number;
  nome: string;
  ordem: number;
  prioridade_estrategica: number | null;
  frequencia_historica: number | null;
  evidencias: Evidencia[];
};

type MateriaCurso = {
  id: number;
  nome: string;
  prioridade_estrategica: number | null;
  frequencia_historica: number | null;
  evidencias: Evidencia[];
  conteudos: ConteudoCurso[];
};

type NivelPrioridade = "Muito alta" | "Alta" | "Média" | "Normal";

type ItemPriorizado = {
  tipo: "conteudo" | "materia_generica";
  materiaId: number;
  materiaNome: string;
  conteudoId: number | null;
  titulo: string;
  prioridade: number;
  nivelPrioridade: NivelPrioridade;
  frequenciaHistorica: number | null;
  origens: TipoOrigemEvidencia[];
};

type RevisaoRpc = {
  status: string;
  agendada_para: string;
  materia_nome: string | null;
  assunto_nome: string | null;
};

type Sessao = { data_sessao: string; status: string };

type TipoBloco = "teoria" | "questoes" | "revisao";

type Bloco = {
  tipo: TipoBloco;
  titulo: string;
  detalhe: string;
  minutos: number;
  conteudoId?: number;
  cursoMateriaId?: number;
};

// Bônus por presença de cada tipo de evidência — aprovado explicitamente.
// Não multiplica pela frequência, não soma frequências de origens diferentes.
const BONUS_EDITAL_ATUAL = 3;
const BONUS_PROVA_ANTERIOR = 2;
const BONUS_EDITAL_ANTERIOR = 1;
const BONUS_HISTORICO_BANCA = 1;
// manual = +0, não precisa somar.

// Valor neutro para curso_materias.prioridade_estrategica nulo (matéria ainda sem
// curadoria de peso próprio) — mantém a matéria na fila sem colocá-la artificialmente
// no topo. Provisório: calibrado pelo único intervalo real observado até agora
// (prioridade_estrategica entre 3 e 5); ajustável conforme mais curadoria acontecer.
const PRIORIDADE_NEUTRA = 3;

/**
 * Retorna uma data no formato YYYY-MM-DD.
 */
function chaveData(data: Date) {
  return `${data.getFullYear()}-${String(data.getMonth() + 1).padStart(
    2,
    "0"
  )}-${String(data.getDate()).padStart(2, "0")}`;
}

/**
 * Formata minutos para uma apresentação como:
 * 45 min
 * 1h
 * 1h 30min
 */
function formatarDuracao(minutos: number) {
  if (minutos < 60) {
    return `${minutos} min`;
  }

  const horas = Math.floor(minutos / 60);
  const restante = minutos % 60;

  return restante ? `${horas}h ${restante}min` : `${horas}h`;
}

/**
 * Soma o bônus de cada origem de evidência presente (por existência, não por
 * frequência) — nunca soma frequências de origens diferentes entre si.
 */
function calcularBonusEvidencias(evidencias: Evidencia[]) {
  const origens = new Set(evidencias.map((evidencia) => evidencia.tipo_origem));
  let bonus = 0;

  if (origens.has("edital_atual")) bonus += BONUS_EDITAL_ATUAL;
  if (origens.has("prova_anterior")) bonus += BONUS_PROVA_ANTERIOR;
  if (origens.has("edital_anterior")) bonus += BONUS_EDITAL_ANTERIOR;
  if (origens.has("historico_banca")) bonus += BONUS_HISTORICO_BANCA;

  return bonus;
}

/**
 * Prioridade = prioridade_estrategica (ou valor neutro, se nula) + bônus por
 * presença de evidência. frequencia_historica não entra aqui — só desempata.
 */
function calcularPrioridadeItem(base: number | null, evidencias: Evidencia[]) {
  const prioridadeBase = base ?? PRIORIDADE_NEUTRA;
  return prioridadeBase + calcularBonusEvidencias(evidencias);
}

/**
 * Transforma a pontuação num nível visível.
 * Limiares provisórios, calibrados pela única faixa real observada até agora
 * (prioridade_estrategica 3-5 + bônus até +7) — ajustáveis com mais dados.
 */
function obterNivelPrioridade(prioridade: number): NivelPrioridade {
  if (prioridade >= 9) return "Muito alta";
  if (prioridade >= 7) return "Alta";
  if (prioridade >= 5) return "Média";

  return "Normal";
}

/**
 * Define quantas vezes um item (conteúdo ou matéria genérica) aparece na fila semanal.
 */
function obterRepeticoes(prioridade: number) {
  if (prioridade >= 9) return 4;
  if (prioridade >= 7) return 3;
  if (prioridade >= 5) return 2;

  return 1;
}

/**
 * Descreve a origem mais forte disponível, em linguagem que nunca afirma
 * "confirmado no edital" quando a única evidência é histórico de banca.
 */
function descreverOrigens(origens: TipoOrigemEvidencia[]): string | null {
  if (origens.includes("edital_atual")) return "presente no edital atual";
  if (origens.includes("prova_anterior")) return "recorrente em provas anteriores";
  if (origens.includes("edital_anterior")) return "presente em edital anterior";
  if (origens.includes("historico_banca")) return "prioridade estratégica pelo histórico da banca";
  if (origens.includes("manual")) return "incluído pela curadoria do Papiro";

  return null;
}

export default function Cronograma() {
  const [cursoAtivo, setCursoAtivo] = useState<CursoAtivo | null>(null);
  const [horasDiarias, setHorasDiarias] = useState(1);
  const [materiasCurso, setMateriasCurso] = useState<MateriaCurso[]>([]);
  const [revisoes, setRevisoes] = useState<RevisaoRpc[]>([]);
  const [sessoes, setSessoes] = useState<Sessao[]>([]);
  const [carregando, setCarregando] = useState(true);
  const [mensagem, setMensagem] = useState("");
  const [semContexto, setSemContexto] = useState(false);

  useEffect(() => {
    async function carregar() {
      try {
        const supabase = createClient();

        const {
          data: { user },
        } = await supabase.auth.getUser();

        if (!user) {
          window.location.replace("/login");
          return;
        }

        const { data: perfil } = await supabase
          .from("perfis")
          .select("curso_ativo_id")
          .eq("usuario_id", user.id)
          .maybeSingle();

        if (!perfil?.curso_ativo_id) {
          setMensagem("Selecione um curso ativo para ver seu cronograma.");
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

        const hoje = chaveData(new Date());

        const fim = new Date();
        fim.setHours(0, 0, 0, 0);
        fim.setDate(fim.getDate() + 6);

        const [
          resultadoConfig,
          resultadoCurso,
          resultadoMateriasCurso,
          resultadoSessoes,
          resultadoRevisoes,
        ] = await Promise.all([
          supabase
            .from("configuracoes_estudo")
            .select("horas_diarias")
            .eq("matricula_id", matricula.id)
            .maybeSingle(),

          supabase
            .from("cursos")
            .select("concurso, cargo, data_prova")
            .eq("id", perfil.curso_ativo_id)
            .maybeSingle(),

          supabase
            .from("curso_materias")
            .select(
              `
                id,
                nome,
                peso,
                prioridade_estrategica,
                frequencia_historica,
                relevante_para_preparacao,
                curso_conteudos (
                  id,
                  assunto_id,
                  ordem,
                  prioridade_estrategica,
                  frequencia_historica,
                  relevante_para_preparacao,
                  assuntos ( nome )
                )
              `
            )
            .eq("curso_id", perfil.curso_ativo_id)
            .eq("relevante_para_preparacao", true)
            .order("nome"),

          supabase
            .from("sessoes_estudo")
            .select("data_sessao, status")
            .eq("matricula_id", matricula.id)
            .gte("data_sessao", hoje)
            .lte("data_sessao", chaveData(fim)),

          supabase.rpc("revisoes_do_curso_ativo"),
        ]);

        const materiasCursoBruto =
          (resultadoMateriasCurso.data as unknown as MateriaCursoBruta[] | null) ?? [];

        const conteudoIds = materiasCursoBruto.flatMap((materia) =>
          (materia.curso_conteudos ?? [])
            .filter((conteudo) => conteudo.relevante_para_preparacao)
            .map((conteudo) => conteudo.id)
        );

        const materiaIds = materiasCursoBruto.map((materia) => materia.id);

        const [resultadoEvidenciasConteudo, resultadoEvidenciasMateria] = await Promise.all([
          conteudoIds.length
            ? supabase
                .from("curso_evidencias")
                .select("tipo_origem, frequencia, descricao, curso_conteudo_id")
                .in("curso_conteudo_id", conteudoIds)
            : Promise.resolve({ data: [] as EvidenciaBruta[], error: null }),

          materiaIds.length
            ? supabase
                .from("curso_evidencias")
                .select("tipo_origem, frequencia, descricao, curso_materia_id")
                .in("curso_materia_id", materiaIds)
            : Promise.resolve({ data: [] as EvidenciaBruta[], error: null }),
        ]);

        const evidenciasPorConteudo = new Map<number, Evidencia[]>();
        ((resultadoEvidenciasConteudo.data as EvidenciaBruta[] | null) ?? []).forEach((evidencia) => {
          if (evidencia.curso_conteudo_id == null) return;
          const lista = evidenciasPorConteudo.get(evidencia.curso_conteudo_id) ?? [];
          lista.push({
            tipo_origem: evidencia.tipo_origem,
            frequencia: evidencia.frequencia,
            descricao: evidencia.descricao,
          });
          evidenciasPorConteudo.set(evidencia.curso_conteudo_id, lista);
        });

        const evidenciasPorMateria = new Map<number, Evidencia[]>();
        ((resultadoEvidenciasMateria.data as EvidenciaBruta[] | null) ?? []).forEach((evidencia) => {
          if (evidencia.curso_materia_id == null) return;
          const lista = evidenciasPorMateria.get(evidencia.curso_materia_id) ?? [];
          lista.push({
            tipo_origem: evidencia.tipo_origem,
            frequencia: evidencia.frequencia,
            descricao: evidencia.descricao,
          });
          evidenciasPorMateria.set(evidencia.curso_materia_id, lista);
        });

        const materiasCursoMontadas: MateriaCurso[] = materiasCursoBruto.map((materia) => ({
          id: materia.id,
          nome: materia.nome,
          prioridade_estrategica: materia.prioridade_estrategica,
          frequencia_historica: materia.frequencia_historica,
          evidencias: evidenciasPorMateria.get(materia.id) ?? [],
          conteudos: (materia.curso_conteudos ?? [])
            .filter((conteudo) => conteudo.relevante_para_preparacao)
            .sort((a, b) => a.ordem - b.ordem)
            .map((conteudo) => ({
              id: conteudo.id,
              nome: conteudo.assuntos?.nome ?? "Conteúdo sem nome",
              ordem: conteudo.ordem,
              prioridade_estrategica: conteudo.prioridade_estrategica,
              frequencia_historica: conteudo.frequencia_historica,
              evidencias: evidenciasPorConteudo.get(conteudo.id) ?? [],
            })),
        }));

        const configEstudo = resultadoConfig.data as { horas_diarias: number } | null;
        const curso = resultadoCurso.data as
          | { concurso: string | null; cargo: string | null; data_prova: string | null }
          | null;

        setCursoAtivo(
          curso
            ? {
                id: perfil.curso_ativo_id,
                concurso: curso.concurso ?? "Concurso",
                cargo: curso.cargo ?? "Cargo",
                data_prova: curso.data_prova,
              }
            : null
        );

        setHorasDiarias(Number(configEstudo?.horas_diarias ?? 1));
        setMateriasCurso(materiasCursoMontadas);
        setSessoes((resultadoSessoes.data as Sessao[] | null) ?? []);

        if (resultadoRevisoes.error) {
          console.error("revisoes_do_curso_ativo falhou:", {
            message: resultadoRevisoes.error.message,
            code: resultadoRevisoes.error.code,
            details: resultadoRevisoes.error.details,
            hint: resultadoRevisoes.error.hint,
          });
        }

        const revisoesCurso = (resultadoRevisoes.data as RevisaoRpc[] | null) ?? [];
        setRevisoes(
          revisoesCurso.filter(
            (revisao) => revisao.status === "pendente" && revisao.agendada_para <= chaveData(fim)
          )
        );

        const algumErro =
          resultadoConfig.error ||
          resultadoCurso.error ||
          resultadoMateriasCurso.error ||
          resultadoSessoes.error ||
          resultadoRevisoes.error ||
          resultadoEvidenciasConteudo.error ||
          resultadoEvidenciasMateria.error;

        if (algumErro) {
          console.error("Erro ao carregar cronograma:", {
            config: resultadoConfig.error,
            curso: resultadoCurso.error,
            materiasCurso: resultadoMateriasCurso.error,
            sessoes: resultadoSessoes.error,
            revisoes: resultadoRevisoes.error,
            evidenciasConteudo: resultadoEvidenciasConteudo.error,
            evidenciasMateria: resultadoEvidenciasMateria.error,
          });

          setMensagem("Parte do cronograma não pôde ser sincronizada agora.");
        }
      } catch (erro) {
        console.error("Erro inesperado ao montar cronograma:", erro);

        setMensagem("Não foi possível montar todo o cronograma neste momento.");
      } finally {
        setCarregando(false);
      }
    }

    carregar();
  }, []);

  /**
   * Um item por conteúdo (curso_conteudos), quando a matéria já tiver curadoria.
   * Fallback: um único item genérico por matéria, enquanto ela não tiver
   * curso_conteudos relevantes — nunca remove a matéria do cronograma por
   * falta de curadoria, e nunca substitui uma matéria por outra.
   */
  const itensPriorizados = useMemo<ItemPriorizado[]>(() => {
    const itens: ItemPriorizado[] = [];

    materiasCurso.forEach((materia) => {
      if (materia.conteudos.length > 0) {
        materia.conteudos.forEach((conteudo) => {
          const prioridade = calcularPrioridadeItem(
            conteudo.prioridade_estrategica,
            conteudo.evidencias
          );

          itens.push({
            tipo: "conteudo",
            materiaId: materia.id,
            materiaNome: materia.nome,
            conteudoId: conteudo.id,
            titulo: conteudo.nome,
            prioridade,
            nivelPrioridade: obterNivelPrioridade(prioridade),
            frequenciaHistorica: conteudo.frequencia_historica,
            origens: conteudo.evidencias.map((evidencia) => evidencia.tipo_origem),
          });
        });
      } else {
        const prioridade = calcularPrioridadeItem(
          materia.prioridade_estrategica,
          materia.evidencias
        );

        itens.push({
          tipo: "materia_generica",
          materiaId: materia.id,
          materiaNome: materia.nome,
          conteudoId: null,
          titulo: materia.nome,
          prioridade,
          nivelPrioridade: obterNivelPrioridade(prioridade),
          frequenciaHistorica: materia.frequencia_historica,
          origens: materia.evidencias.map((evidencia) => evidencia.tipo_origem),
        });
      }
    });

    return itens.sort((a, b) => {
      if (b.prioridade !== a.prioridade) return b.prioridade - a.prioridade;
      return Number(b.frequenciaHistorica ?? 0) - Number(a.frequenciaHistorica ?? 0);
    });
  }, [materiasCurso]);

  /**
   * Cria uma fila ponderada e alternada — mesma lógica de antes, agora operando
   * sobre itens (conteúdo ou matéria genérica) em vez de matérias inteiras.
   */
  const filaItens = useMemo(() => {
    const fila: ItemPriorizado[] = [];

    itensPriorizados.forEach((item) => {
      const repeticoes = obterRepeticoes(item.prioridade);

      for (let indice = 0; indice < repeticoes; indice += 1) {
        fila.push(item);
      }
    });

    const filaAlternada: ItemPriorizado[] = [];
    let rodada = 0;

    while (filaAlternada.length < fila.length) {
      let adicionouItem = false;

      itensPriorizados.forEach((item) => {
        const repeticoes = obterRepeticoes(item.prioridade);

        if (rodada < repeticoes) {
          filaAlternada.push(item);
          adicionouItem = true;
        }
      });

      if (!adicionouItem) {
        break;
      }

      rodada += 1;
    }

    return filaAlternada.length > 0 ? filaAlternada : itensPriorizados;
  }, [itensPriorizados]);

  /**
   * Monta o plano dos próximos sete dias.
   */
  const plano = useMemo(() => {
    if (filaItens.length === 0) return [];

    const minutosDia = Math.max(30, Math.round(horasDiarias * 60));

    return Array.from({ length: 7 }, (_, indice) => {
      const data = new Date();

      data.setHours(0, 0, 0, 0);
      data.setDate(data.getDate() + indice);

      const chave = chaveData(data);

      const revisoesDia = revisoes.filter((revisao) => {
        if (indice === 0) {
          return revisao.agendada_para <= chave;
        }

        return revisao.agendada_para === chave;
      });

      const itemPrincipal = filaItens[indice % filaItens.length];
      const itemSecundario = filaItens[(indice + 1) % filaItens.length];

      const temRevisao = revisoesDia.length > 0;

      const minutosRevisao = temRevisao
        ? Math.min(30, Math.max(15, Math.round(minutosDia * 0.25)))
        : Math.min(15, Math.max(10, Math.round(minutosDia * 0.15)));

      const percentualQuestoes =
        itemPrincipal.prioridade >= 9 ? 0.4 : itemPrincipal.prioridade >= 7 ? 0.35 : 0.3;

      const minutosQuestoes = Math.max(15, Math.round(minutosDia * percentualQuestoes));

      const minutosTeoria = Math.max(20, minutosDia - minutosRevisao - minutosQuestoes);

      const revisaoTitulo =
        revisoesDia[0]?.assunto_nome ??
        revisoesDia[0]?.materia_nome ??
        itemSecundario.titulo;

      const descricaoOrigem = descreverOrigens(itemPrincipal.origens);

      const detalhesPrioridade = [
        itemPrincipal.materiaNome,
        `${itemPrincipal.nivelPrioridade} prioridade`,
        descricaoOrigem,
      ]
        .filter(Boolean)
        .join(" · ");

      const blocos: Bloco[] = [
        {
          tipo: "revisao",
          titulo: revisaoTitulo,
          detalhe: temRevisao
            ? `${revisoesDia.length} revisão(ões) programada(s)`
            : "Revisão rápida do conteúdo anterior",
          minutos: minutosRevisao,
        },
        {
          tipo: "teoria",
          titulo: itemPrincipal.titulo,
          detalhe: detalhesPrioridade,
          minutos: minutosTeoria,
          ...(itemPrincipal.conteudoId ? { conteudoId: itemPrincipal.conteudoId } : {}),
          cursoMateriaId: itemPrincipal.materiaId,
        },
        {
          tipo: "questoes",
          titulo: itemPrincipal.titulo,
          detalhe:
            itemPrincipal.prioridade >= 7
              ? "Bloco reforçado por prioridade estratégica"
              : "Fixação e registro dos erros",
          minutos: minutosQuestoes,
          ...(itemPrincipal.conteudoId ? { conteudoId: itemPrincipal.conteudoId } : {}),
          cursoMateriaId: itemPrincipal.materiaId,
        },
      ];

      return {
        chave,
        hoje: indice === 0,

        concluido: sessoes.some(
          (sessao) => sessao.data_sessao === chave && sessao.status === "concluida"
        ),

        dia: data.toLocaleDateString("pt-BR", { weekday: "long" }),

        data: data
          .toLocaleDateString("pt-BR", { day: "2-digit", month: "short" })
          .replace(".", ""),

        prioridade: itemPrincipal.nivelPrioridade,
        pontuacaoPrioridade: itemPrincipal.prioridade,
        blocos,
      };
    });
  }, [horasDiarias, filaItens, revisoes, sessoes]);

  const diasConcluidos = useMemo(() => {
    return plano.filter((dia) => dia.concluido).length;
  }, [plano]);

  if (carregando) {
    return (
      <main className="dashboard-loading">
        <p>Montando sua semana...</p>
      </main>
    );
  }

  const prova = cursoAtivo?.data_prova ? new Date(`${cursoAtivo.data_prova}T00:00:00`) : null;

  const diasProva = prova
    ? Math.max(0, Math.ceil((prova.getTime() - Date.now()) / 86_400_000))
    : null;

  return (
    <main className="schedule-page">
      <header className="schedule-header">
        <div>
          <p className="dashboard-label">CRONOGRAMA INTELIGENTE</p>

          <h1>Sua próxima semana já tem direção.</h1>

          <span>
            {cursoAtivo
              ? `${cursoAtivo.concurso} · ${cursoAtivo.cargo}`
              : "Configure seu concurso para personalizar ainda mais o plano."}
          </span>
        </div>

        <Link href="/painel">Voltar ao painel</Link>
      </header>

      {semContexto ? (
        <p className="method-message" role="alert">
          {mensagem}
        </p>
      ) : (
        <>
          <section className="schedule-overview">
            <article>
              <span>Ritmo diário</span>

              <strong>{horasDiarias.toLocaleString("pt-BR")}h</strong>

              <small>divididas em blocos</small>
            </article>

            <article>
              <span>Até a prova</span>

              <strong>{diasProva ?? "—"}</strong>

              <small>{diasProva === null ? "data não definida" : "dias restantes"}</small>
            </article>

            <article>
              <span>Revisões na fila</span>

              <strong>{revisoes.length}</strong>

              <small>nos próximos 7 dias</small>
            </article>

            <article>
              <span>Progresso semanal</span>

              <strong>{diasConcluidos}/7</strong>

              <small>dias concluídos</small>
            </article>
          </section>

          {mensagem && (
            <p className="method-message" role="alert">
              {mensagem}
            </p>
          )}

          {plano.length === 0 ? (
            <section className="empty-method-state">
              <h2>Ainda não há base programática para este curso</h2>
              <p>Assim que a curadoria de matérias e conteúdos for feita, seu cronograma aparecerá aqui.</p>
            </section>
          ) : (
            <section className="schedule-layout">
              <div className="schedule-days">
                {plano.map((dia) => (
                  <article
                    className={["schedule-day", dia.hoje ? "today" : "", dia.concluido ? "completed" : ""]
                      .filter(Boolean)
                      .join(" ")}
                    key={dia.chave}
                  >
                    <div className="schedule-date">
                      <small>{dia.hoje ? "HOJE" : dia.dia}</small>

                      <strong>{dia.data}</strong>

                      {dia.concluido && <span>Concluído</span>}
                    </div>

                    <div className="schedule-blocks">
                      {dia.blocos.map((bloco) => (
                        <div className={`schedule-block ${bloco.tipo}`} key={`${dia.chave}-${bloco.tipo}`}>
                          <i />

                          <div>
                            <small>{bloco.tipo}</small>
                            <strong>{bloco.titulo}</strong>
                            <span>{bloco.detalhe}</span>
                          </div>

                          <b>{formatarDuracao(bloco.minutos)}</b>
                        </div>
                      ))}
                    </div>

                    {dia.hoje && <Link href="/questoes">Iniciar missão</Link>}
                  </article>
                ))}
              </div>

              <aside className="schedule-rules">
                <p className="dashboard-label">LÓGICA PAPIRO</p>

                <h2>Um plano guiado pelo que mais gera pontos.</h2>

                <ol>
                  <li>
                    <b>1</b>

                    <span>
                      <strong>Priorizar</strong>
                      Os conteúdos com maior prioridade estratégica e mais evidências
                      aparecem mais vezes.
                    </span>
                  </li>

                  <li>
                    <b>2</b>

                    <span>
                      <strong>Revisar</strong>
                      Conteúdos errados ou próximos do esquecimento entram primeiro.
                    </span>
                  </li>

                  <li>
                    <b>3</b>

                    <span>
                      <strong>Praticar</strong>
                      Os conteúdos mais importantes recebem blocos maiores de questões.
                    </span>
                  </li>
                </ol>

                <p>
                  A prioridade considera a base programática do curso, evidências de
                  edital e histórico da banca, e seu desempenho em cada conteúdo.
                </p>

                <Link href="/configuracao">Ajustar objetivo</Link>
              </aside>
            </section>
          )}
        </>
      )}
    </main>
  );
}
