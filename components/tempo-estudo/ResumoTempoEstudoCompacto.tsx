"use client";

import Link from "next/link";
import { formatarHorasMinutos, type DadosTempoEstudo } from "./useDadosTempoEstudo";

// Resumo compacto de tempo de estudo para /estatisticas (que continua
// focada em desempenho acadêmico: questões, aproveitamento, matéria,
// erros, revisões). Só Hoje/Semana/Sequência + link para a página
// completa — o detalhe (Mês/Últimos 366 dias/Meta diária/heatmap/distribuição por
// tipo de atividade) vive só em /meu-estudo, nunca duplicado aqui.
export default function ResumoTempoEstudoCompacto({ dados }: { dados: DadosTempoEstudo }) {
  return (
    <article className="stats-panel tempo-estudo-compacto-panel">
      <div className="stats-title">
        <div>
          <p className="dashboard-label">TEMPO DE ESTUDO</p>
          <h2>Seu ritmo recente</h2>
        </div>
      </div>
      <div className="tempo-estudo-compacto-metrics">
        <div>
          <span>Hoje</span>
          <strong>{formatarHorasMinutos(dados.resumoTempo?.segundos_hoje ?? 0)}</strong>
        </div>
        <div>
          <span>Semana</span>
          <strong>{formatarHorasMinutos(dados.resumoTempo?.segundos_semana ?? 0)}</strong>
        </div>
        <div>
          <span>Sequência</span>
          <strong>{dados.sequenciaTempo} dias</strong>
        </div>
      </div>
      <Link href="/meu-estudo" className="tempo-estudo-compacto-link">
        Ver meu estudo <span className="tempo-estudo-compacto-seta" aria-hidden="true">→</span>
      </Link>
    </article>
  );
}
