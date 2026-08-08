"use client";

import Link from "next/link";
import { useEffect, useMemo, useState } from "react";
import { createClient } from "@/utils/supabase/client";

type Objetivo = {
  concurso: string;
  cargo: string;
  data_prova: string | null;
  horas_diarias: number;
};

type Materia = {
  id: number;
  nome: string;
  peso_edital: number | null;
  frequencia_historica: number | null;
  percentual_acertos: number | null;
};

type EditalMateria = {
  id: number;
  materia: string;
  ordem: number;
};

type EditalAnalisado = {
  concurso: string | null;
  cargo: string | null;
  data_prova: string | null;
  edital_materias: EditalMateria[];
};

type Revisao = {
  agendada_para: string;
  status: string;
  erros_usuarios: {
    questoes: {
      materias: {
        nome: string;
      } | null;
    } | null;
  } | null;
};

type Sessao = {
  data_sessao: string;
  status: string;
};

type TipoBloco = "teoria" | "questoes" | "revisao";

type Bloco = {
  tipo: TipoBloco;
  titulo: string;
  detalhe: string;
  minutos: number;
};

type MateriaPriorizada = Materia & {
  prioridade: number;
  nivelPrioridade: "Muito alta" | "Alta" | "Média" | "Normal";
};

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
 * Evita valores menores que o mínimo ou maiores que o máximo.
 */
function limitarValor(valor: number, minimo: number, maximo: number) {
  return Math.min(maximo, Math.max(minimo, valor));
}

/**
 * Calcula a prioridade de uma matéria.
 *
 * Critérios:
 * 45% = frequência nas últimas provas
 * 40% = peso/pontuação da matéria no edital
 * 15% = dificuldade atual do aluno
 *
 * O resultado fica entre 0 e 100.
 */
function calcularPrioridade(materia: Materia, maiorPeso: number) {
  const frequencia = limitarValor(
    Number(materia.frequencia_historica ?? 0),
    0,
    100
  );

  const peso = Math.max(0, Number(materia.peso_edital ?? 1));

  const pesoNormalizado =
    maiorPeso > 0 ? limitarValor((peso / maiorPeso) * 100, 0, 100) : 0;

  const percentualAcertos = limitarValor(
    Number(materia.percentual_acertos ?? 50),
    0,
    100
  );

  const dificuldade = 100 - percentualAcertos;

  return (
    frequencia * 0.45 +
    pesoNormalizado * 0.4 +
    dificuldade * 0.15
  );
}

/**
 * Transforma a pontuação num nível visível.
 */
function obterNivelPrioridade(
  prioridade: number
): MateriaPriorizada["nivelPrioridade"] {
  if (prioridade >= 80) return "Muito alta";
  if (prioridade >= 65) return "Alta";
  if (prioridade >= 45) return "Média";

  return "Normal";
}

/**
 * Define quantas vezes uma matéria aparece na fila semanal.
 */
function obterRepeticoes(prioridade: number) {
  if (prioridade >= 80) return 4;
  if (prioridade >= 65) return 3;
  if (prioridade >= 45) return 2;

  return 1;
}

/**
 * Remove acentos e diferenças de letras maiúsculas para comparar nomes.
 */
function normalizarNome(nome: string) {
  return nome
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .trim()
    .toLowerCase();
}

export default function Cronograma() {
  const [objetivo, setObjetivo] = useState<Objetivo | null>(null);
  const [materias, setMaterias] = useState<Materia[]>([]);
  const [revisoes, setRevisoes] = useState<Revisao[]>([]);
  const [sessoes, setSessoes] = useState<Sessao[]>([]);
  const [carregando, setCarregando] = useState(true);
  const [mensagem, setMensagem] = useState("");

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

        const hoje = chaveData(new Date());

        const fim = new Date();
        fim.setHours(0, 0, 0, 0);
        fim.setDate(fim.getDate() + 6);

        const resultado = await Promise.all([
          supabase
            .from("objetivos")
            .select("concurso, cargo, data_prova, horas_diarias")
            .order("data_prova", { ascending: true })
            .limit(1)
            .maybeSingle(),

          supabase
            .from("materias")
            .select(
              `
                id,
                nome,
                peso_edital,
                frequencia_historica,
                percentual_acertos
              `
            )
            .order("nome"),

          supabase
            .from("revisoes")
            .select(
              `
                agendada_para,
                status,
                erros_usuarios(
                  questoes(
                    materias(nome)
                  )
                )
              `
            )
            .eq("status", "pendente")
            .lte("agendada_para", chaveData(fim)),

          supabase
            .from("sessoes_estudo")
            .select("data_sessao, status")
            .gte("data_sessao", hoje)
            .lte("data_sessao", chaveData(fim)),

          supabase
            .from("editais")
            .select(
              `
                concurso,
                cargo,
                data_prova,
                edital_materias(
                  id,
                  materia,
                  ordem
                )
              `
            )
            .eq("status", "concluido")
            .order("atualizado_em", { ascending: false })
            .limit(1)
            .maybeSingle(),
        ]);

        const [resultadoObjetivo, resultadoMaterias, resultadoRevisoes, resultadoSessoes, resultadoEdital] =
          resultado;

        const objetivoSalvo =
          (resultadoObjetivo.data as Objetivo | null) ?? null;

        const edital =
          (resultadoEdital.data as unknown as EditalAnalisado | null) ?? null;

        const materiasBanco =
          (resultadoMaterias.data as Materia[] | null) ?? [];

        /*
         * Cria um mapa para localizar as estatísticas de cada matéria.
         */
        const estatisticasPorNome = new Map<string, Materia>();

        materiasBanco.forEach((materia) => {
          estatisticasPorNome.set(normalizarNome(materia.nome), materia);
        });

        /*
         * Matérias extraídas pela IA a partir do edital.
         *
         * Quando existe uma matéria correspondente na tabela "materias",
         * recuperamos peso, frequência histórica e desempenho do aluno.
         */
        const materiasExtraidas: Materia[] = (edital?.edital_materias ?? [])
          .slice()
          .sort((a, b) => a.ordem - b.ordem)
          .map((item) => {
            const estatistica = estatisticasPorNome.get(
              normalizarNome(item.materia)
            );

            return {
              id: item.id,
              nome: item.materia,
              peso_edital: estatistica?.peso_edital ?? 1,
              frequencia_historica:
                estatistica?.frequencia_historica ?? 0,
              percentual_acertos:
                estatistica?.percentual_acertos ?? 50,
            };
          });

        /*
         * Prioriza os dados do edital analisado.
         * Caso ainda não exista análise, usa as matérias cadastradas.
         */
        const materiasFinais =
          materiasExtraidas.length > 0
            ? materiasExtraidas
            : materiasBanco;

        setObjetivo(
          edital
            ? {
                concurso:
                  edital.concurso ||
                  objetivoSalvo?.concurso ||
                  "Concurso",

                cargo:
                  edital.cargo ||
                  objetivoSalvo?.cargo ||
                  "Cargo",

                data_prova:
                  edital.data_prova ||
                  objetivoSalvo?.data_prova ||
                  null,

                horas_diarias:
                  Number(objetivoSalvo?.horas_diarias ?? 1),
              }
            : objetivoSalvo
        );

        setMaterias(materiasFinais);

        setRevisoes(
          (resultadoRevisoes.data as unknown as Revisao[]) ?? []
        );

        setSessoes(
          (resultadoSessoes.data as Sessao[] | null) ?? []
        );

        const algumErro =
          resultadoObjetivo.error ||
          resultadoMaterias.error ||
          resultadoRevisoes.error ||
          resultadoSessoes.error ||
          resultadoEdital.error;

        if (algumErro) {
          console.error("Erro ao carregar cronograma:", {
            objetivo: resultadoObjetivo.error,
            materias: resultadoMaterias.error,
            revisoes: resultadoRevisoes.error,
            sessoes: resultadoSessoes.error,
            edital: resultadoEdital.error,
          });

          setMensagem(
            "Parte do cronograma não pôde ser sincronizada agora."
          );
        }
      } catch (erro) {
        console.error("Erro inesperado ao montar cronograma:", erro);

        setMensagem(
          "Não foi possível montar todo o cronograma neste momento."
        );
      } finally {
        setCarregando(false);
      }
    }

    carregar();
  }, []);

  /**
   * Ordena as matérias usando:
   * frequência histórica;
   * peso no edital;
   * dificuldade do aluno.
   */
  const materiasPriorizadas = useMemo<MateriaPriorizada[]>(() => {
    const materiasBase =
      materias.length > 0
        ? materias
        : [
            {
              id: 1,
              nome: "Português",
              peso_edital: 1,
              frequencia_historica: 60,
              percentual_acertos: 50,
            },
            {
              id: 2,
              nome: "Direito Penal",
              peso_edital: 1,
              frequencia_historica: 60,
              percentual_acertos: 50,
            },
            {
              id: 3,
              nome: "Informática",
              peso_edital: 1,
              frequencia_historica: 60,
              percentual_acertos: 50,
            },
          ];

    const maiorPeso = Math.max(
      1,
      ...materiasBase.map((materia) =>
        Number(materia.peso_edital ?? 1)
      )
    );

    return materiasBase
      .map((materia) => {
        const prioridade = calcularPrioridade(materia, maiorPeso);

        return {
          ...materia,
          prioridade,
          nivelPrioridade: obterNivelPrioridade(prioridade),
        };
      })
      .sort((a, b) => b.prioridade - a.prioridade);
  }, [materias]);

  /**
   * Cria uma fila ponderada.
   *
   * Matérias de maior prioridade aparecem mais vezes.
   */
  const filaMaterias = useMemo(() => {
    const fila: MateriaPriorizada[] = [];

    materiasPriorizadas.forEach((materia) => {
      const repeticoes = obterRepeticoes(materia.prioridade);

      for (let indice = 0; indice < repeticoes; indice += 1) {
        fila.push(materia);
      }
    });

    /*
     * Alterna a fila para evitar quatro dias seguidos
     * com exatamente a mesma matéria.
     */
    const filaAlternada: MateriaPriorizada[] = [];
    const materiasDisponiveis = [...materiasPriorizadas];

    let rodada = 0;

    while (filaAlternada.length < fila.length) {
      let adicionouMateria = false;

      materiasDisponiveis.forEach((materia) => {
        const repeticoes = obterRepeticoes(materia.prioridade);

        if (rodada < repeticoes) {
          filaAlternada.push(materia);
          adicionouMateria = true;
        }
      });

      if (!adicionouMateria) {
        break;
      }

      rodada += 1;
    }

    return filaAlternada.length > 0
      ? filaAlternada
      : materiasPriorizadas;
  }, [materiasPriorizadas]);

  /**
   * Monta o plano dos próximos sete dias.
   */
  const plano = useMemo(() => {
    const minutosDia = Math.max(
      30,
      Math.round(Number(objetivo?.horas_diarias ?? 1) * 60)
    );

    return Array.from({ length: 7 }, (_, indice) => {
      const data = new Date();

      data.setHours(0, 0, 0, 0);
      data.setDate(data.getDate() + indice);

      const chave = chaveData(data);

      /*
       * No dia atual, inclui revisões atrasadas.
       * Nos próximos dias, mostra somente revisões agendadas para aquele dia.
       */
      const revisoesDia = revisoes.filter((revisao) => {
        if (indice === 0) {
          return revisao.agendada_para <= chave;
        }

        return revisao.agendada_para === chave;
      });

      const materiaPrincipal =
        filaMaterias[indice % filaMaterias.length];

      const materiaSecundaria =
        filaMaterias[(indice + 1) % filaMaterias.length];

      const temRevisao = revisoesDia.length > 0;

      const minutosRevisao = temRevisao
        ? Math.min(30, Math.max(15, Math.round(minutosDia * 0.25)))
        : Math.min(15, Math.max(10, Math.round(minutosDia * 0.15)));

      /*
       * Matérias prioritárias recebem mais tempo de questões.
       */
      const percentualQuestoes =
        materiaPrincipal.prioridade >= 80
          ? 0.4
          : materiaPrincipal.prioridade >= 65
            ? 0.35
            : 0.3;

      const minutosQuestoes = Math.max(
        15,
        Math.round(minutosDia * percentualQuestoes)
      );

      const minutosTeoria = Math.max(
        20,
        minutosDia - minutosRevisao - minutosQuestoes
      );

      const revisaoMateria =
        revisoesDia[0]?.erros_usuarios?.questoes?.materias?.nome ??
        materiaSecundaria.nome;

      const frequencia = Number(
        materiaPrincipal.frequencia_historica ?? 0
      );

      const peso = Number(materiaPrincipal.peso_edital ?? 1);

      const detalhesPrioridade = [
        `${materiaPrincipal.nivelPrioridade} prioridade`,
        frequencia > 0
          ? `${frequencia.toLocaleString("pt-BR")}% de incidência`
          : null,
        peso > 0
          ? `peso ${peso.toLocaleString("pt-BR")}`
          : null,
      ]
        .filter(Boolean)
        .join(" · ");

      const blocos: Bloco[] = [
        {
          tipo: "revisao",
          titulo: revisaoMateria,
          detalhe: temRevisao
            ? `${revisoesDia.length} revisão(ões) programada(s)`
            : "Revisão rápida do conteúdo anterior",
          minutos: minutosRevisao,
        },
        {
          tipo: "teoria",
          titulo: materiaPrincipal.nome,
          detalhe: detalhesPrioridade,
          minutos: minutosTeoria,
        },
        {
          tipo: "questoes",
          titulo: materiaPrincipal.nome,
          detalhe:
            materiaPrincipal.prioridade >= 65
              ? "Bloco reforçado por incidência e pontuação"
              : "Fixação e registro dos erros",
          minutos: minutosQuestoes,
        },
      ];

      return {
        chave,
        hoje: indice === 0,

        concluido: sessoes.some(
          (sessao) =>
            sessao.data_sessao === chave &&
            sessao.status === "concluida"
        ),

        dia: data.toLocaleDateString("pt-BR", {
          weekday: "long",
        }),

        data: data
          .toLocaleDateString("pt-BR", {
            day: "2-digit",
            month: "short",
          })
          .replace(".", ""),

        prioridade: materiaPrincipal.nivelPrioridade,
        pontuacaoPrioridade: materiaPrincipal.prioridade,
        blocos,
      };
    });
  }, [objetivo, filaMaterias, revisoes, sessoes]);

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

  const prova = objetivo?.data_prova
    ? new Date(`${objetivo.data_prova}T00:00:00`)
    : null;

  const diasProva = prova
    ? Math.max(
        0,
        Math.ceil(
          (prova.getTime() - Date.now()) / 86_400_000
        )
      )
    : null;

  return (
    <main className="schedule-page">
      <header className="schedule-header">
        <div>
          <p className="dashboard-label">
            CRONOGRAMA INTELIGENTE
          </p>

          <h1>Sua próxima semana já tem direção.</h1>

          <span>
            {objetivo
              ? `${objetivo.concurso} · ${objetivo.cargo}`
              : "Configure seu concurso para personalizar ainda mais o plano."}
          </span>
        </div>

        <Link href="/painel">Voltar ao painel</Link>
      </header>

      <section className="schedule-overview">
        <article>
          <span>Ritmo diário</span>

          <strong>
            {Number(
              objetivo?.horas_diarias ?? 1
            ).toLocaleString("pt-BR")}
            h
          </strong>

          <small>divididas em blocos</small>
        </article>

        <article>
          <span>Até a prova</span>

          <strong>{diasProva ?? "—"}</strong>

          <small>
            {diasProva === null
              ? "data não definida"
              : "dias restantes"}
          </small>
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

      <section className="schedule-layout">
        <div className="schedule-days">
          {plano.map((dia) => (
            <article
              className={[
                "schedule-day",
                dia.hoje ? "today" : "",
                dia.concluido ? "completed" : "",
              ]
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
                  <div
                    className={`schedule-block ${bloco.tipo}`}
                    key={`${dia.chave}-${bloco.tipo}`}
                  >
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

              {dia.hoje && (
                <Link href="/questoes">Iniciar missão</Link>
              )}
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
                As matérias mais cobradas e com maior peso aparecem
                mais vezes.
              </span>
            </li>

            <li>
              <b>2</b>

              <span>
                <strong>Revisar</strong>
                Conteúdos errados ou próximos do esquecimento entram
                primeiro.
              </span>
            </li>

            <li>
              <b>3</b>

              <span>
                <strong>Praticar</strong>
                As matérias mais importantes recebem blocos maiores
                de questões.
              </span>
            </li>
          </ol>

          <p>
            A prioridade considera incidência nas últimas provas,
            pontuação no edital e seu desempenho em cada matéria.
          </p>

          <Link href="/configuracao">Ajustar objetivo</Link>
        </aside>
      </section>
    </main>
  );
}