"use client";

import Link from "next/link";
import { ArrowUpRight } from "lucide-react";
import { useEffect, useMemo, useState } from "react";
import { createClient } from "@/utils/supabase/client";

type MetricaSemanal = "questoes" | "acertos";

type SessaoEstatistica = {
  data_sessao: string;
  status: string;
  questoes_respondidas: number;
  acertos: number;
};

type EstatisticasCurso = {
  sessoes?: SessaoEstatistica[];
};

type Ponto = {
  x: number;
  y: number;
};

function dataLocal(data: Date) {
  return `${data.getFullYear()}-${String(data.getMonth() + 1).padStart(2, "0")}-${String(data.getDate()).padStart(2, "0")}`;
}

function montarCaminhoSuave(pontos: Ponto[]) {
  if (pontos.length === 0) return "";

  return pontos.slice(1).reduce((caminho, ponto, indice) => {
    const anterior = pontos[indice];
    const meio = (anterior.x + ponto.x) / 2;
    return `${caminho} C ${meio} ${anterior.y}, ${meio} ${ponto.y}, ${ponto.x} ${ponto.y}`;
  }, `M ${pontos[0].x} ${pontos[0].y}`);
}

export function WeeklyStatsCard() {
  const [sessoes, setSessoes] = useState<SessaoEstatistica[]>([]);
  const [metrica, setMetrica] = useState<MetricaSemanal>("questoes");
  const [carregando, setCarregando] = useState(true);
  const [diaSelecionado, setDiaSelecionado] = useState(6);
  const [diaDestacado, setDiaDestacado] = useState<number | null>(null);

  useEffect(() => {
    let ativo = true;

    async function carregarEstatisticas() {
      const { data } = await createClient().rpc("estatisticas_do_curso_ativo");
      if (!ativo) return;

      const resultado = data as EstatisticasCurso | null;
      setSessoes(resultado?.sessoes ?? []);
      setCarregando(false);
    }

    void carregarEstatisticas();
    return () => {
      ativo = false;
    };
  }, []);

  const grafico = useMemo(() => {
    const concluidas = sessoes.filter((sessao) => sessao.status === "concluida");
    const dias = Array.from({ length: 7 }, (_, indice) => {
      const data = new Date();
      data.setDate(data.getDate() - (6 - indice));
      const chave = dataLocal(data);
      const sessoesDoDia = concluidas.filter(
        (sessao) => sessao.data_sessao.slice(0, 10) === chave,
      );

      return {
        chave,
        dataFormatada: data.toLocaleDateString("pt-BR", {
          day: "2-digit",
          month: "short",
        }),
        diaCompleto: data.toLocaleDateString("pt-BR", { weekday: "long" }),
        dia: data
          .toLocaleDateString("pt-BR", { weekday: "short" })
          .replace(".", ""),
        questoes: sessoesDoDia.reduce(
          (total, sessao) => total + Number(sessao.questoes_respondidas ?? 0),
          0,
        ),
        acertos: sessoesDoDia.reduce(
          (total, sessao) => total + Number(sessao.acertos ?? 0),
          0,
        ),
      };
    });

    const valores = dias.map((dia) => dia[metrica]);
    const maiorValor = Math.max(1, ...valores);
    const pontos = valores.map((valor, indice) => ({
      x: 18 + indice * 44,
      y: 55 - (valor / maiorValor) * 29,
    }));

    const caminho = montarCaminhoSuave(pontos);
    const primeiroPonto = pontos[0];
    const ultimoPonto = pontos[pontos.length - 1];

    return {
      caminho,
      area:
        caminho && primeiroPonto && ultimoPonto
          ? `${caminho} L ${ultimoPonto.x} 59 L ${primeiroPonto.x} 59 Z`
          : "",
      pontos: dias.map((dia, indice) => ({
        ...dia,
        valor: valores[indice],
        ...pontos[indice],
      })),
      total: valores.reduce((soma, valor) => soma + valor, 0),
    };
  }, [metrica, sessoes]);

  const rotuloMetrica = metrica === "questoes" ? "Questões" : "Acertos";
  const indiceAtivo = diaDestacado ?? diaSelecionado;
  const pontoAtivo = grafico.pontos[indiceAtivo];
  const larguraTooltip = 94;
  const tooltipX = pontoAtivo
    ? Math.min(
        300 - larguraTooltip - 4,
        Math.max(4, pontoAtivo.x - larguraTooltip / 2),
      )
    : 4;
  const tooltipY = pontoAtivo ? Math.max(3, pontoAtivo.y - 29) : 3;

  return (
    <article className="papiro-stats-quick-card">
      <header className="papiro-stats-quick-card__header">
        <Link href="/estatisticas">
          <span>
            <h3>Visão da semana</h3>
            <ArrowUpRight aria-hidden="true" size={15} strokeWidth={1.8} />
          </span>
          <small>
            {carregando
              ? "Sincronizando dados"
              : `${grafico.total} ${rotuloMetrica.toLocaleLowerCase("pt-BR")} na semana`}
          </small>
        </Link>
        <label>
          <span className="papiro-stats-quick-card__sr-only">
            Métrica do gráfico semanal
          </span>
          <select
            value={metrica}
            onChange={(evento) =>
              setMetrica(evento.target.value as MetricaSemanal)
            }
          >
            <option value="questoes">Questões</option>
            <option value="acertos">Acertos</option>
          </select>
        </label>
      </header>

      <div
        className="papiro-stats-quick-card__chart"
        role="group"
        aria-label={
          carregando
            ? "Carregando a visão semanal."
            : `${rotuloMetrica} nos últimos sete dias: ${grafico.total} no total. Selecione um dia para consultar o valor.`
        }
      >
        <svg viewBox="0 0 300 88">
          <path
            className="papiro-stats-quick-card__baseline"
            d="M 12 59 H 288"
          />
          <path
            className="papiro-stats-quick-card__area"
            d={grafico.area}
            key={`area-${metrica}`}
          />
          <path
            className="papiro-stats-quick-card__line"
            d={grafico.caminho}
            key={`linha-${metrica}`}
          />
          {pontoAtivo ? (
            <line
              className="papiro-stats-quick-card__guide"
              x1={pontoAtivo.x}
              x2={pontoAtivo.x}
              y1="12"
              y2="59"
            />
          ) : null}
          {grafico.pontos.map((ponto, indice) => {
            const ativo = indice === indiceAtivo;
            return (
              <g
                className={`papiro-stats-quick-card__interactive-point${ativo ? " is-active" : ""}`}
                key={ponto.chave}
                role="button"
                tabIndex={0}
                aria-label={`${ponto.diaCompleto}, ${ponto.dataFormatada}: ${ponto.valor} ${rotuloMetrica.toLocaleLowerCase("pt-BR")}`}
                onPointerEnter={() => setDiaDestacado(indice)}
                onPointerLeave={() => setDiaDestacado(null)}
                onFocus={() => setDiaDestacado(indice)}
                onBlur={() => setDiaDestacado(null)}
                onClick={() => setDiaSelecionado(indice)}
                onKeyDown={(evento) => {
                  if (evento.key !== "Enter" && evento.key !== " ") return;
                  evento.preventDefault();
                  setDiaSelecionado(indice);
                }}
              >
                <text
                  className="papiro-stats-quick-card__value"
                  x={ponto.x}
                  y={Math.max(10, ponto.y - 9)}
                  textAnchor="middle"
                >
                  {carregando ? "" : ponto.valor || "—"}
                </text>
                <circle
                  className="papiro-stats-quick-card__hit-area"
                  cx={ponto.x}
                  cy={ponto.y}
                  r="11"
                />
                {ativo ? (
                  <circle
                    className="papiro-stats-quick-card__active-ring"
                    cx={ponto.x}
                    cy={ponto.y}
                    r="6.2"
                  />
                ) : null}
                <circle
                  className={
                    ponto.valor
                      ? "papiro-stats-quick-card__point"
                      : "papiro-stats-quick-card__point papiro-stats-quick-card__point--empty"
                  }
                  cx={ponto.x}
                  cy={ponto.y}
                  r="3.2"
                />
                <text
                  className="papiro-stats-quick-card__day"
                  x={ponto.x}
                  y="80"
                  textAnchor="middle"
                >
                  {ponto.dia}
                </text>
              </g>
            );
          })}
          {pontoAtivo && !carregando ? (
            <g className="papiro-stats-quick-card__tooltip" aria-hidden="true">
              <rect
                x={tooltipX}
                y={tooltipY}
                width={larguraTooltip}
                height="20"
                rx="6"
              />
              <text
                x={tooltipX + larguraTooltip / 2}
                y={tooltipY + 13}
                textAnchor="middle"
              >
                {pontoAtivo.dia}: {pontoAtivo.valor} {metrica === "questoes" ? "quest." : "acertos"}
              </text>
            </g>
          ) : null}
        </svg>
      </div>
    </article>
  );
}
