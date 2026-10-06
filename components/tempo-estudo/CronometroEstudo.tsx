"use client";

import Link from "next/link";
import { useEffect, useLayoutEffect, useRef, useState } from "react";
import { createClient } from "@/utils/supabase/client";
import type { UseSessaoTempoResultado } from "./useSessaoTempo";

function formatarHMS(totalSegundos: number): string {
  const segundos = Math.max(0, Math.floor(totalSegundos));
  const h = Math.floor(segundos / 3600);
  const m = Math.floor((segundos % 3600) / 60);
  const s = segundos % 60;
  const dois = (n: number) => String(n).padStart(2, "0");
  return `${dois(h)}:${dois(m)}:${dois(s)}`;
}

// "1h42" — usado para hoje/semana/meta no popover (formato mais compacto
// que HH:MM:SS, adequado a um resumo, não a um cronômetro rodando).
function formatarHorasMinutos(totalSegundos: number): string {
  const segundos = Math.max(0, Math.floor(totalSegundos));
  const h = Math.floor(segundos / 3600);
  const m = Math.floor((segundos % 3600) / 60);
  return m > 0 ? `${h}h${String(m).padStart(2, "0")}` : `${h}h`;
}

function rotuloAtividade(origem: string, tipoAtividade: string): string {
  if (tipoAtividade === "teoria") return "Teoria";
  if (tipoAtividade === "questoes") return origem === "cronograma" ? "Questões da missão" : "Questões";
  if (tipoAtividade === "leitura") return "Leitura";
  if (tipoAtividade === "revisao") return "Revisão";
  return "Estudo";
}

const ICONE_POR_ESTADO: Record<string, string> = {
  iniciando: "⏱",
  ativa: "⏱",
  pausada: "⏸",
  encerrada: "⏱",
  conflito: "⚠",
  erro: "⚠",
};

const CHAVE_POSICAO = "papiro:cronometro:posicao:v1";
const MARGEM_PX = 10;

type PosicaoPx = { left: number; top: number };
type PosicaoFracionaria = { xFrac: number; yFrac: number };

function medirWidget(el: HTMLElement | null): { largura: number; altura: number } {
  return { largura: el?.offsetWidth || 150, altura: el?.offsetHeight || 34 };
}

function clampPx(left: number, top: number, el: HTMLElement | null): PosicaoPx {
  const { largura, altura } = medirWidget(el);
  const maxLeft = Math.max(MARGEM_PX, window.innerWidth - largura - MARGEM_PX);
  const maxTop = Math.max(MARGEM_PX, window.innerHeight - altura - MARGEM_PX);
  return {
    left: Math.min(Math.max(left, MARGEM_PX), maxLeft),
    top: Math.min(Math.max(top, MARGEM_PX), maxTop),
  };
}

function fracParaPx(frac: PosicaoFracionaria, el: HTMLElement | null): PosicaoPx {
  const { largura, altura } = medirWidget(el);
  const maxLeft = Math.max(MARGEM_PX, window.innerWidth - largura - MARGEM_PX);
  const maxTop = Math.max(MARGEM_PX, window.innerHeight - altura - MARGEM_PX);
  return {
    left: MARGEM_PX + frac.xFrac * (maxLeft - MARGEM_PX),
    top: MARGEM_PX + frac.yFrac * (maxTop - MARGEM_PX),
  };
}

function pxParaFrac(pos: PosicaoPx, el: HTMLElement | null): PosicaoFracionaria {
  const { largura, altura } = medirWidget(el);
  const maxLeft = Math.max(1, window.innerWidth - largura - 2 * MARGEM_PX);
  const maxTop = Math.max(1, window.innerHeight - altura - 2 * MARGEM_PX);
  return {
    xFrac: Math.min(1, Math.max(0, (pos.left - MARGEM_PX) / maxLeft)),
    yFrac: Math.min(1, Math.max(0, (pos.top - MARGEM_PX) / maxTop)),
  };
}

// Canto inferior direito — posição padrão antes de qualquer arraste do
// aluno, e o que "Restaurar posição" devolve.
const POSICAO_PADRAO: PosicaoFracionaria = { xFrac: 1, yFrac: 1 };

function lerPosicaoSalva(): PosicaoFracionaria {
  try {
    const bruto = window.localStorage.getItem(CHAVE_POSICAO);
    if (!bruto) return POSICAO_PADRAO;
    const valor = JSON.parse(bruto) as Partial<PosicaoFracionaria>;
    if (typeof valor.xFrac !== "number" || typeof valor.yFrac !== "number") return POSICAO_PADRAO;
    return { xFrac: Math.min(1, Math.max(0, valor.xFrac)), yFrac: Math.min(1, Math.max(0, valor.yFrac)) };
  } catch {
    return POSICAO_PADRAO;
  }
}

function salvarPosicao(frac: PosicaoFracionaria) {
  try {
    window.localStorage.setItem(CHAVE_POSICAO, JSON.stringify(frac));
  } catch {
    // localStorage indisponível (modo privado, bloqueio de site, etc.) —
    // só perde a persistência entre sessões, nunca quebra o cronômetro.
  }
}

type ResumoTempoEstudo = { segundos_hoje: number; segundos_semana: number; meta_diaria_segundos: number };

// Horas Líquidas 1.0 — widget flutuante/arrastável (desktop) com posição
// persistida em localStorage, popover com resumo hoje/semana/meta e
// tratamento rico de conflito. Nenhuma lógica de tempo/estado vive aqui —
// tudo isso continua em useSessaoTempo/sessaoTempoControlador; este
// arquivo só apresenta e só lê (resumo_tempo_estudo é leitura pura).
export default function CronometroEstudo({
  sessao,
  contexto = null,
}: {
  sessao: UseSessaoTempoResultado;
  /** Nome da matéria/assunto em estudo, só para exibição no popover — não influencia nenhuma RPC. */
  contexto?: string | null;
}) {
  const { estado, processando, segundosLiquidos, erro, conflito } = sessao;

  const [clicado, setClicado] = useState(false);
  const [hoverGatilho, setHoverGatilho] = useState(false);
  const [hoverPopover, setHoverPopover] = useState(false);
  const aberto = clicado || hoverGatilho || hoverPopover;

  const raizRef = useRef<HTMLDivElement>(null);
  const gatilhoRef = useRef<HTMLButtonElement>(null);

  // --- posicionamento flutuante ---------------------------------------
  const [posicao, setPosicao] = useState<PosicaoPx | null>(null);
  const [arrastando, setArrastando] = useState(false);
  const moveuDeVerdadeRef = useRef(false);
  const posicaoAtualRef = useRef<PosicaoPx>({ left: 0, top: 0 });

  // Posição real só pode ser calculada no cliente (depende de
  // window/localStorage e do tamanho real do widget) — useLayoutEffect
  // para resolver ANTES da primeira pintura visível, evitando um salto.
  useLayoutEffect(() => {
    const posInicial = fracParaPx(lerPosicaoSalva(), raizRef.current);
    posicaoAtualRef.current = posInicial;
    setPosicao(posInicial);
  }, []);

  // Reclampa ao redimensionar a janela — "recalcular/clamp ao viewport ao
  // restaurar" vale também para resize, não só para o carregamento inicial.
  useEffect(() => {
    function aoRedimensionar() {
      setPosicao((atual) => {
        if (!atual) return atual;
        const ajustada = clampPx(atual.left, atual.top, raizRef.current);
        posicaoAtualRef.current = ajustada;
        return ajustada;
      });
    }
    window.addEventListener("resize", aoRedimensionar);
    return () => window.removeEventListener("resize", aoRedimensionar);
  }, []);

  function aoPressionarPonteiro(evento: React.PointerEvent<HTMLButtonElement>) {
    // Mobile/touch (seção 12): sem arraste nesta versão — clique curto
    // continua funcionando normalmente via onClick, sem nenhum listener extra.
    if (evento.pointerType !== "mouse" || !posicao) return;

    const inicio = { x: evento.clientX, y: evento.clientY, left: posicao.left, top: posicao.top };
    moveuDeVerdadeRef.current = false;

    function aoMover(e: PointerEvent) {
      const dx = e.clientX - inicio.x;
      const dy = e.clientY - inicio.y;
      if (!moveuDeVerdadeRef.current && Math.hypot(dx, dy) > 5) {
        moveuDeVerdadeRef.current = true;
        setArrastando(true);
      }
      if (!moveuDeVerdadeRef.current) return;
      const nova = clampPx(inicio.left + dx, inicio.top + dy, raizRef.current);
      posicaoAtualRef.current = nova;
      setPosicao(nova);
    }

    function aoSoltar() {
      window.removeEventListener("pointermove", aoMover);
      window.removeEventListener("pointerup", aoSoltar);
      if (moveuDeVerdadeRef.current) {
        salvarPosicao(pxParaFrac(posicaoAtualRef.current, raizRef.current));
        setArrastando(false);
      }
      // moveuDeVerdadeRef continua true por mais um instante de propósito
      // — é isso que faz o onClick sintético que o navegador dispara a
      // seguir (pointerup -> click) ser ignorado, sem abrir/fechar o
      // popover só porque o aluno estava arrastando.
    }

    window.addEventListener("pointermove", aoMover);
    window.addEventListener("pointerup", aoSoltar);
  }

  function aoClicarGatilho() {
    if (moveuDeVerdadeRef.current) {
      moveuDeVerdadeRef.current = false;
      return;
    }
    setClicado((atual) => !atual);
  }

  function restaurarPosicao() {
    const padrao = fracParaPx(POSICAO_PADRAO, raizRef.current);
    posicaoAtualRef.current = padrao;
    setPosicao(padrao);
    salvarPosicao(POSICAO_PADRAO);
  }

  // --- resumo hoje/semana/meta (resumo_tempo_estudo) -------------------
  const [resumo, setResumo] = useState<ResumoTempoEstudo | null>(null);
  useEffect(() => {
    if (!aberto) return;
    let ativo = true;
    createClient()
      .rpc("resumo_tempo_estudo")
      .then(({ data, error: erroResumo }) => {
        if (!ativo || erroResumo || !data) return;
        setResumo(data as ResumoTempoEstudo);
      });
    return () => {
      ativo = false;
    };
  }, [aberto]);

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

  if (estado === "ociosa" || !posicao) return null;

  // Decide de qual lado abrir o popover para nunca sair da viewport —
  // acima/abaixo e à esquerda/direita conforme o espaço real disponível
  // a partir da posição atual do widget (que pode estar em QUALQUER
  // canto, já que agora é arrastável).
  const abrirParaCima = posicao.top > window.innerHeight * 0.6;
  const abrirParaEsquerda = posicao.left > window.innerWidth * 0.6;

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
    <div
      className={`cronometro-estudo${arrastando ? " cronometro-estudo-arrastando" : ""}`}
      ref={raizRef}
      style={{ left: posicao.left, top: posicao.top }}
    >
      <button
        type="button"
        ref={gatilhoRef}
        className={`cronometro-estudo-gatilho cronometro-estudo-${estado}`}
        aria-haspopup="true"
        aria-expanded={aberto}
        aria-label={`Tempo de estudo: ${rotuloEstado}${mostrarTempo ? `, ${formatarHMS(segundosLiquidos)}` : ""}. Arraste para mover.`}
        onPointerDown={aoPressionarPonteiro}
        onClick={aoClicarGatilho}
        onMouseEnter={() => setHoverGatilho(true)}
        onMouseLeave={() => setHoverGatilho(false)}
      >
        <span aria-hidden="true">{icone}</span>
        {mostrarTempo && <span className="cronometro-estudo-gatilho-tempo">{formatarHMS(segundosLiquidos)}</span>}
      </button>

      {aberto && (
        <div
          className={`cronometro-estudo-popover${abrirParaCima ? " cronometro-estudo-popover-cima" : ""}${abrirParaEsquerda ? " cronometro-estudo-popover-esquerda" : ""}`}
          role="dialog"
          aria-label="Tempo de estudo"
          onMouseEnter={() => setHoverPopover(true)}
          onMouseLeave={() => setHoverPopover(false)}
        >
          <p className="dashboard-label">TEMPO DE ESTUDO</p>

          {estado === "iniciando" && <p className="cronometro-estudo-mensagem">Sincronizando o cronômetro...</p>}

          {estado === "conflito" && (
            <div className="cronometro-estudo-conflito-bloco">
              <p className="cronometro-estudo-mensagem" role="alert">OUTRO ESTUDO EM ANDAMENTO</p>
              {conflito && (
                <>
                  <p className="cronometro-estudo-contexto">{rotuloAtividade(conflito.origem, conflito.tipoAtividade)}</p>
                  <p className="cronometro-estudo-tempo">{formatarHMS(conflito.segundosLiquidos)}</p>
                </>
              )}
              <div className="cronometro-estudo-acoes">
                {conflito?.linkRetomada && (
                  <Link href={conflito.linkRetomada} className="cronometro-estudo-link-retomar">
                    Retomar estudo
                  </Link>
                )}
                <button type="button" onClick={() => void sessao.encerrarConflitoEIniciar()} disabled={processando}>
                  Encerrar estudo anterior
                </button>
              </div>
            </div>
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

              {resumo && (
                <p className="cronometro-estudo-resumo">
                  Hoje: {formatarHorasMinutos(resumo.segundos_hoje)}
                  {resumo.meta_diaria_segundos > 0 && ` / ${formatarHorasMinutos(resumo.meta_diaria_segundos)}`}
                  <br />
                  Semana: {formatarHorasMinutos(resumo.segundos_semana)}
                </p>
              )}

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

          <div className="cronometro-estudo-rodape">
            <Link href="/meu-estudo" className="cronometro-estudo-ver-meu-estudo">
              Ver meu estudo →
            </Link>
            <button type="button" className="cronometro-estudo-restaurar" onClick={restaurarPosicao}>
              Restaurar posição
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
