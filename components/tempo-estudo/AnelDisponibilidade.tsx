"use client";

import { useEffect, useMemo, useState } from "react";
import { useResumoTempoHoje } from "./useDadosTempoEstudo";

// Formatação local (não a formatarHorasMinutos compartilhada): só este
// anel precisa do caso "Ymin" para metas sub-hora — "45min" em vez de
// "0h45". Puramente apresentação, nenhum cálculo novo.
function formatarMeta(segundos: number) {
  const minutosTotais = Math.floor(Math.max(0, segundos) / 60);
  const horas = Math.floor(minutosTotais / 60);
  const minutos = minutosTotais % 60;

  if (horas > 0 && minutos === 0) {
    return `${horas}h`;
  }

  if (horas > 0) {
    return `${horas}h${String(minutos).padStart(2, "0")}`;
  }

  return `${minutos}min`;
}

// Corpo visual COMPLETO do card Disponibilidade (app/painel/page.tsx)
// — só o anel, o valor da meta diária dentro dele e o percentual
// discreto abaixo. Sem Hoje/Restante/coluna lateral (removidos nesta
// rodada: poluíam o card). Self-contido: busca seus próprios dados via
// useResumoTempoHoje (mesma RPC resumo_tempo_estudo já usada por
// /meu-estudo, nenhuma chamada nova).
export function AnelDisponibilidade() {
  const { carregando, resumoTempo, percentualMeta } = useResumoTempoHoje();

  const [progressoAnimado, setProgressoAnimado] = useState(0);

  const metaSegundos = resumoTempo?.meta_diaria_segundos ?? 0;

  const percentual = Math.min(100, Math.max(0, percentualMeta ?? 0));

  const metaCumprida = metaSegundos > 0 && percentual >= 100;

  // Entrada suave: nasce em 0 e só no quadro seguinte vai ao percentual
  // real — a transição em si é CSS (ver painel.css) e já respeita
  // prefers-reduced-motion via a regra global existente.
  useEffect(() => {
    const frame = requestAnimationFrame(() => {
      setProgressoAnimado(percentual);
    });

    return () => cancelAnimationFrame(frame);
  }, [percentual]);

  const tamanho = 96;
  const centro = tamanho / 2;
  const raio = 36;

  const circunferencia = useMemo(() => 2 * Math.PI * raio, [raio]);

  const offset = circunferencia - (progressoAnimado / 100) * circunferencia;

  if (carregando) {
    return <div className="papiro-disponibilidade-ring papiro-disponibilidade-ring--loading" aria-hidden="true" />;
  }

  return (
    <div className="papiro-disponibilidade-ring">
      <div className="papiro-disponibilidade-ring__grafico">
        <svg viewBox={`0 0 ${tamanho} ${tamanho}`} className="papiro-disponibilidade-ring__svg" aria-hidden="true">
          <circle cx={centro} cy={centro} r={raio} className="papiro-disponibilidade-ring__trilho" />

          <circle
            cx={centro}
            cy={centro}
            r={raio}
            className={["papiro-disponibilidade-ring__progresso", metaCumprida ? "papiro-disponibilidade-ring__progresso--cumprida" : ""]
              .filter(Boolean)
              .join(" ")}
            strokeDasharray={circunferencia}
            strokeDashoffset={offset}
          />
        </svg>

        <div className="papiro-disponibilidade-ring__centro">
          <strong>{formatarMeta(metaSegundos)}</strong>
          <span>{metaCumprida ? "META CUMPRIDA" : "META DIÁRIA"}</span>
        </div>
      </div>

      <div className="papiro-disponibilidade-ring__percentual">
        {metaCumprida ? "100% concluído" : `${Math.round(percentual)}% concluído`}
      </div>
    </div>
  );
}
