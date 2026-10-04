"use client";

import { useEffect, useRef, useState } from "react";
import type { UseSessaoTempoResultado } from "./useSessaoTempo";

function formatarHMS(totalSegundos: number): string {
  const segundos = Math.max(0, Math.floor(totalSegundos));
  const h = Math.floor(segundos / 3600);
  const m = Math.floor((segundos % 3600) / 60);
  const s = segundos % 60;
  const dois = (n: number) => String(n).padStart(2, "0");
  return `${dois(h)}:${dois(m)}:${dois(s)}`;
}

const ICONE_POR_ESTADO: Record<string, string> = {
  iniciando: "⏱",
  ativa: "⏱",
  pausada: "⏸",
  encerrada: "⏱",
  conflito: "⚠",
  erro: "⚠",
};

// Fase 2B — só a apresentação muda: nenhuma chamada a useSessaoTempo é
// adicionada/alterada aqui, e a sessão continua vindo inteira de fora
// (a mesma máquina de estados da Fase 2A, sem nenhuma mudança de semântica).
export default function CronometroEstudo({
  sessao,
  contexto = null,
}: {
  sessao: UseSessaoTempoResultado;
  /** Nome da matéria/assunto em estudo, só para exibição no popover — não influencia nenhuma RPC. */
  contexto?: string | null;
}) {
  const { estado, processando, segundosLiquidos, erro } = sessao;

  const [clicado, setClicado] = useState(false);
  const [hoverGatilho, setHoverGatilho] = useState(false);
  const [hoverPopover, setHoverPopover] = useState(false);
  const aberto = clicado || hoverGatilho || hoverPopover;

  const raizRef = useRef<HTMLDivElement>(null);
  const gatilhoRef = useRef<HTMLButtonElement>(null);

  // Toque fora fecha (clique fora também, no desktop) — mousedown cobre os
  // dois sem depender de hover, que não existe de forma confiável em touch.
  useEffect(() => {
    if (!aberto) return;
    function aoClicarFora(evento: MouseEvent | TouchEvent) {
      if (!raizRef.current?.contains(evento.target as Node)) {
        setClicado(false);
        setHoverGatilho(false);
        setHoverPopover(false);
      }
    }
    document.addEventListener("mousedown", aoClicarFora);
    document.addEventListener("touchstart", aoClicarFora);
    return () => {
      document.removeEventListener("mousedown", aoClicarFora);
      document.removeEventListener("touchstart", aoClicarFora);
    };
  }, [aberto]);

  // Escape fecha e devolve o foco ao gatilho.
  useEffect(() => {
    if (!aberto) return;
    function aoTeclar(evento: KeyboardEvent) {
      if (evento.key === "Escape") {
        setClicado(false);
        setHoverGatilho(false);
        setHoverPopover(false);
        gatilhoRef.current?.focus();
      }
    }
    document.addEventListener("keydown", aoTeclar);
    return () => document.removeEventListener("keydown", aoTeclar);
  }, [aberto]);

  if (estado === "ociosa") return null;

  const icone = ICONE_POR_ESTADO[estado] ?? "⏱";
  const mostrarTempo = estado !== "iniciando" && estado !== "conflito";
  const rotuloEstado =
    estado === "ativa"
      ? "Estudando"
      : estado === "pausada"
        ? "Pausado"
        : estado === "encerrada"
          ? "Encerrado"
          : estado === "conflito"
            ? "Conflito"
            : estado === "erro"
              ? "Erro"
              : "Sincronizando";

  return (
    <div className="cronometro-estudo" ref={raizRef}>
      <button
        type="button"
        ref={gatilhoRef}
        className={`cronometro-estudo-gatilho cronometro-estudo-${estado}`}
        aria-haspopup="true"
        aria-expanded={aberto}
        aria-label={`Tempo de estudo: ${rotuloEstado}${mostrarTempo ? `, ${formatarHMS(segundosLiquidos)}` : ""}`}
        onClick={() => setClicado((atual) => !atual)}
        onMouseEnter={() => setHoverGatilho(true)}
        onMouseLeave={() => setHoverGatilho(false)}
      >
        <span aria-hidden="true">{icone}</span>
        {mostrarTempo && <span className="cronometro-estudo-gatilho-tempo">{formatarHMS(segundosLiquidos)}</span>}
      </button>

      {aberto && (
        <div
          className="cronometro-estudo-popover"
          role="dialog"
          aria-label="Tempo de estudo"
          onMouseEnter={() => setHoverPopover(true)}
          onMouseLeave={() => setHoverPopover(false)}
        >
          <p className="dashboard-label">TEMPO DE ESTUDO</p>

          {estado === "iniciando" && <p className="cronometro-estudo-mensagem">Sincronizando o cronômetro...</p>}

          {estado === "conflito" && (
            <p className="cronometro-estudo-mensagem" role="alert">
              Já existe outro estudo em andamento em outra aba ou tela.
            </p>
          )}

          {estado === "erro" && (
            <p className="cronometro-estudo-mensagem" role="alert">
              {erro ?? "Não foi possível medir o tempo agora."} Você pode continuar estudando normalmente.
            </p>
          )}

          {(estado === "ativa" || estado === "pausada" || estado === "encerrada") && (
            <>
              <p className="cronometro-estudo-tempo">{formatarHMS(segundosLiquidos)}</p>

              <p className="cronometro-estudo-status">
                <span aria-hidden="true">{estado === "pausada" ? "⏸" : "●"}</span>{" "}
                {estado === "encerrada" ? "Estudo encerrado" : estado === "pausada" ? "Pausado" : "Estudando"}
              </p>

              {contexto && estado !== "encerrada" && <p className="cronometro-estudo-contexto">{contexto}</p>}

              {(estado === "ativa" || estado === "pausada") && (
                <div className="cronometro-estudo-acoes">
                  {estado === "ativa" && (
                    <button type="button" onClick={sessao.pausarEstudo} disabled={processando}>
                      Pausar
                    </button>
                  )}
                  {estado === "pausada" && (
                    <button type="button" onClick={sessao.retomarEstudo} disabled={processando}>
                      Retomar
                    </button>
                  )}
                  <button type="button" onClick={sessao.encerrarEstudo} disabled={processando}>
                    Encerrar
                  </button>
                </div>
              )}
            </>
          )}
        </div>
      )}
    </div>
  );
}
