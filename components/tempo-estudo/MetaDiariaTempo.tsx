"use client";

import { useEffect, useState } from "react";
import type { DadosTempoEstudo } from "./useDadosTempoEstudo";

// "Xh00" sempre com minutos, mesmo em zero — só para alinhar visualmente
// o "tempo hoje / meta" num formato "0h11 / 2h00" (formatarHorasMinutos,
// usado no resto da página, omite os minutos quando são zero: "2h").
// Formatação pura, nenhum cálculo novo — os números em si (segundos_hoje,
// meta_diaria_segundos, percentualMeta) continuam vindo só do hook.
function formatarComMinutos(totalSegundos: number): string {
  const segundos = Math.max(0, Math.floor(totalSegundos));
  const h = Math.floor(segundos / 3600);
  const m = Math.floor((segundos % 3600) / 60);
  return `${h}h${String(m).padStart(2, "0")}`;
}

// Meta diária como progresso de execução (tempo hoje vs. meta
// configurada), não só o valor configurado. percentualMeta já vem
// calculado e limitado a 100 pelo hook (useDadosTempoEstudo) — usado
// tal como está, tanto no texto quanto na barra, sem recalcular nada
// aqui (ver auditoria desta fase: não criar cálculo concorrente).
export default function MetaDiariaTempo({ dados }: { dados: DadosTempoEstudo }) {
  const segundosHoje = dados.resumoTempo?.segundos_hoje ?? 0;
  const metaSegundos = dados.resumoTempo?.meta_diaria_segundos ?? 0;
  const percentual = dados.percentualMeta ?? 0;
  const cumprida = dados.percentualMeta !== null && dados.percentualMeta >= 100;

  // A barra monta em 0% e só no quadro seguinte vai para o percentual
  // real — é essa mudança de valor (0 -> percentual) que dá à transição
  // CSS (width, ver globals.css) algo para animar na entrada. Reage
  // também a mudanças depois da montagem (ex.: percentual mudou),
  // sempre reanimando a partir do valor anterior exibido, nunca de um
  // novo cálculo.
  const [larguraExibida, setLarguraExibida] = useState(0);
  useEffect(() => {
    const quadro = requestAnimationFrame(() => setLarguraExibida(percentual));
    return () => cancelAnimationFrame(quadro);
  }, [percentual]);

  return (
    <article className={`stats-panel meta-diaria-painel${cumprida ? " meta-diaria-cumprida" : ""}`}>
      <div className="stats-title">
        <div>
          <p className="dashboard-label">META DIÁRIA</p>
          <h2>
            {formatarComMinutos(segundosHoje)}
            {metaSegundos > 0 ? ` / ${formatarComMinutos(metaSegundos)}` : ""}
          </h2>
        </div>
        {dados.percentualMeta !== null && <strong>{cumprida ? "✓" : `${dados.percentualMeta}%`}</strong>}
      </div>
      {metaSegundos > 0 ? (
        <>
          <div className="metric-track meta-diaria-track">
            <span style={{ width: `${larguraExibida}%` }} />
          </div>
          <small>{cumprida ? "Meta cumprida" : `${dados.percentualMeta}% concluída`}</small>
        </>
      ) : (
        <p className="stats-empty">Configure sua disponibilidade diária em Configurações para acompanhar aqui.</p>
      )}
    </article>
  );
}
