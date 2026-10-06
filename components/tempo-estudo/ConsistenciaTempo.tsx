"use client";

import { useEffect, useMemo, useRef, useState, type FocusEvent, type KeyboardEvent, type MouseEvent } from "react";
import type { DadosTempoEstudo } from "./useDadosTempoEstudo";

type CelulaHeatmap = DadosTempoEstudo["heatmap"][number];
type Semana = Array<CelulaHeatmap | null>;
type Periodo = "7d" | "30d" | "90d" | "1a";
type CelulaAtiva = { dia: string; segundosLiquidos: number; left: number; top: number; abrirParaCima: boolean };

const ROTULOS_MES = [
  "jan", "fev", "mar", "abr", "mai", "jun", "jul", "ago", "set", "out", "nov", "dez",
];
const MESES_TOOLTIP = [
  "JAN", "FEV", "MAR", "ABR", "MAI", "JUN", "JUL", "AGO", "SET", "OUT", "NOV", "DEZ",
];
// Índice = Date.getDay() (0 = domingo, nativo do JS).
const ROTULOS_DIA_SEMANA = ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb"];

const PERIODOS: Array<{ valor: Periodo; rotulo: string; dias: number }> = [
  { valor: "7d", rotulo: "7D", dias: 7 },
  { valor: "30d", rotulo: "30D", dias: 30 },
  { valor: "90d", rotulo: "90D", dias: 90 },
  { valor: "1a", rotulo: "1 ANO", dias: 366 },
];

// ---------------------------------------------------------------------
// Formatação pura (nenhuma função abaixo calcula nada novo — só lê
// segundos_liquidos/dia, já presentes em cada célula do heatmap).
// ---------------------------------------------------------------------

function dataLocalHoje(): string {
  const hoje = new Date();
  return `${hoje.getFullYear()}-${String(hoje.getMonth() + 1).padStart(2, "0")}-${String(hoje.getDate()).padStart(2, "0")}`;
}

// Alvo padrão do roving tabindex: o dia de hoje quando está dentro do
// período exibido, senão a última célula real (mais recente) do
// período — nunca a primeira, para abrir a navegação já perto do
// presente. Usado nos 4 modos (barras/linha/heatmap), já que todos
// operam sobre o mesmo array cronológico plano (heatmapRecortado).
function calcularFocoPadrao(heatmap: CelulaHeatmap[]): string | null {
  if (heatmap.length === 0) return null;
  const hojeChave = dataLocalHoje();
  return heatmap.some((d) => d.dia === hojeChave) ? hojeChave : heatmap[heatmap.length - 1].dia;
}

// "04 OUT 2026"
function formatarDataTooltip(dia: string): string {
  const data = new Date(`${dia}T00:00:00`);
  return `${String(data.getDate()).padStart(2, "0")} ${MESES_TOOLTIP[data.getMonth()]} ${data.getFullYear()}`;
}

// "11 min estudados" / "1h23 estudados" / "Nenhum tempo registrado" —
// linguagem de tooltip compartilhada por barras, linha e heatmap.
function formatarTempoTooltip(segundos: number): string {
  if (segundos <= 0) return "Nenhum tempo registrado";
  const horas = Math.floor(segundos / 3600);
  const minutos = Math.floor((segundos % 3600) / 60);
  if (horas > 0) return `${horas}h${String(minutos).padStart(2, "0")} estudados`;
  return `${minutos} min estudados`;
}

// "8 min" / "1h23" — usado só na faixa de insights (melhor dia/média),
// que pede "min" explicitamente em vez do formato "Xh" do resto da
// página.
function formatarMinutosLegivel(segundos: number): string {
  const minutos = Math.round(segundos / 60);
  if (minutos < 60) return `${minutos} min`;
  const horas = Math.floor(minutos / 60);
  const resto = minutos % 60;
  return resto > 0 ? `${horas}h${String(resto).padStart(2, "0")}` : `${horas}h`;
}

// "04 out" — rótulo curto de data (insights, eixo X da linha/área).
function formatarDataCurta(dia: string): string {
  const data = new Date(`${dia}T00:00:00`);
  return `${String(data.getDate()).padStart(2, "0")} ${ROTULOS_MES[data.getMonth()]}`;
}

// "04/10" — rótulo de eixo X da linha/área (mais compacto que "04 out").
function formatarDataEixoX(dia: string): string {
  const data = new Date(`${dia}T00:00:00`);
  return `${String(data.getDate()).padStart(2, "0")}/${String(data.getMonth() + 1).padStart(2, "0")}`;
}

// Agrupa a malha diária (já zero-preenchida por useDadosTempoEstudo, e
// já recortada pelo período selecionado) em semanas de 7 colunas
// (segunda a domingo — mesma convenção de início de semana já usada em
// app/estatisticas/page.tsx para dados.diasSemana), no estilo
// calendário/heatmap de contribuição: cada semana é UMA coluna, os 7
// dias da semana são as linhas. Linhas de preenchimento (null) cobrem
// os dias antes do primeiro/depois do último dia real da janela, para
// a primeira/última semana ficarem alinhadas no grid.
function agruparPorSemana(heatmap: CelulaHeatmap[]): { semanas: Semana[]; rotulosMes: Array<{ coluna: number; rotulo: string }> } {
  if (heatmap.length === 0) return { semanas: [], rotulosMes: [] };

  const primeiraData = new Date(`${heatmap[0].dia}T00:00:00`);
  const diaSemanaInicial = (primeiraData.getDay() + 6) % 7; // 0 = segunda

  const semanas: Semana[] = [];
  const rotulosMes: Array<{ coluna: number; rotulo: string }> = [];
  let semanaAtual: Semana = new Array(7).fill(null);
  let indiceNaSemana = diaSemanaInicial;
  let ultimoMes = -1;

  heatmap.forEach((dia) => {
    const data = new Date(`${dia.dia}T00:00:00`);
    const mes = data.getMonth();
    if (mes !== ultimoMes) {
      rotulosMes.push({ coluna: semanas.length, rotulo: ROTULOS_MES[mes] });
      ultimoMes = mes;
    }
    semanaAtual[indiceNaSemana] = dia;
    indiceNaSemana += 1;
    if (indiceNaSemana === 7) {
      semanas.push(semanaAtual);
      semanaAtual = new Array(7).fill(null);
      indiceNaSemana = 0;
    }
  });
  if (indiceNaSemana !== 0) semanas.push(semanaAtual);

  return { semanas, rotulosMes };
}

// Dias ativos / média por dia ativo / melhor dia — as 3 métricas da
// faixa de insights, TODAS derivadas aqui, num único local coerente, a
// partir só do array já recortado pelo período (nenhum cálculo
// espalhado pelo JSX, nenhuma chamada nova ao banco).
type InsightsPeriodo = {
  diasAtivos: number;
  mediaSegundosPorDiaAtivo: number | null;
  melhorDia: { dia: string; segundosLiquidos: number } | null;
};
function calcularInsightsPeriodo(heatmap: CelulaHeatmap[]): InsightsPeriodo {
  const diasAtivos = heatmap.filter((d) => d.segundos_liquidos > 0).length;
  const totalPeriodo = heatmap.reduce((soma, d) => soma + d.segundos_liquidos, 0);
  const melhorDia = heatmap.reduce<CelulaHeatmap | null>(
    (melhor, atual) => (melhor === null || atual.segundos_liquidos > melhor.segundos_liquidos ? atual : melhor),
    null,
  );
  return {
    diasAtivos,
    mediaSegundosPorDiaAtivo: diasAtivos > 0 ? totalPeriodo / diasAtivos : null,
    melhorDia: melhorDia && melhorDia.segundos_liquidos > 0 ? { dia: melhorDia.dia, segundosLiquidos: melhorDia.segundos_liquidos } : null,
  };
}

// Props comuns aos 3 modos de visualização — cada um só renderiza o
// marcador focável/hoverável de um jeito visual diferente; a tooltip,
// o roving tabindex e a navegação por teclado são exatamente os mesmos
// (ver aoTeclarCelula/moverFoco/aoAtivarCelula no componente principal).
type PropsModoGrafico = {
  heatmap: CelulaHeatmap[];
  focoAtivo: string | null;
  celulaAtiva: CelulaAtiva | null;
  indiceDeDia: Map<string, number>;
  registrarRef: (dia: string, el: HTMLElement | null) => void;
  onAtivar: (evento: MouseEvent<HTMLElement> | FocusEvent<HTMLElement>, dia: CelulaHeatmap) => void;
  onDesativar: () => void;
  onTeclar: (evento: KeyboardEvent<HTMLElement>, indice: number) => void;
};

// ---------------------------------------------------------------------
// 7D — barras diárias
// ---------------------------------------------------------------------
function GraficoBarras({ heatmap, focoAtivo, celulaAtiva, indiceDeDia, registrarRef, onAtivar, onDesativar, onTeclar }: PropsModoGrafico) {
  const maximoLocal = Math.max(1, ...heatmap.map((d) => d.segundos_liquidos));

  // Entrada suave: cada barra nasce em 0% e só no quadro seguinte vai à
  // altura real — mesma técnica já usada em MetaDiariaTempo (useState +
  // requestAnimationFrame), nunca uma lib de animação nova.
  const [alturas, setAlturas] = useState<number[]>(() => heatmap.map(() => 0));
  useEffect(() => {
    const quadro = requestAnimationFrame(() => setAlturas(heatmap.map((d) => (d.segundos_liquidos / maximoLocal) * 100)));
    return () => cancelAnimationFrame(quadro);
  }, [heatmap, maximoLocal]);

  return (
    <div className="barras-tempo">
      {heatmap.map((dia, indice) => {
        const data = new Date(`${dia.dia}T00:00:00`);
        return (
          <div className="barras-tempo-coluna" key={dia.dia}>
            <div
              ref={(el) => registrarRef(dia.dia, el)}
              tabIndex={dia.dia === focoAtivo ? 0 : -1}
              className={`barras-tempo-trilho${celulaAtiva?.dia === dia.dia ? " barras-tempo-ativa" : ""}`}
              aria-label={`${formatarDataTooltip(dia.dia)}: ${formatarTempoTooltip(dia.segundos_liquidos)}`}
              onMouseEnter={(evento) => onAtivar(evento, dia)}
              onMouseLeave={onDesativar}
              onFocus={(evento) => onAtivar(evento, dia)}
              onBlur={onDesativar}
              onKeyDown={(evento) => onTeclar(evento, indiceDeDia.get(dia.dia) ?? indice)}
            >
              <span className="barras-tempo-valor" style={{ height: `${alturas[indice] ?? 0}%` }} />
            </div>
            <small>{ROTULOS_DIA_SEMANA[data.getDay()]}</small>
          </div>
        );
      })}
    </div>
  );
}

// ---------------------------------------------------------------------
// 30D/90D — linha + área (SVG puro, sem biblioteca de gráficos)
// ---------------------------------------------------------------------
const LARGURA_SVG = 600;
const ALTURA_SVG = 160;
const PAD_INFERIOR_SVG = 4;

function GraficoLinhaArea({ heatmap, focoAtivo, celulaAtiva, indiceDeDia, registrarRef, onAtivar, onDesativar, onTeclar }: PropsModoGrafico) {
  const n = heatmap.length;
  const { pontos, maximo } = useMemo(() => {
    const maximoLocal = Math.max(1, ...heatmap.map((d) => d.segundos_liquidos));
    const alturaUtil = ALTURA_SVG - PAD_INFERIOR_SVG;
    const lista = heatmap.map((d, i) => ({
      x: n > 1 ? (i / (n - 1)) * LARGURA_SVG : LARGURA_SVG / 2,
      y: ALTURA_SVG - PAD_INFERIOR_SVG - (d.segundos_liquidos / maximoLocal) * alturaUtil,
      dia: d.dia,
      segundosLiquidos: d.segundos_liquidos,
    }));
    return { pontos: lista, maximo: maximoLocal };
  }, [heatmap, n]);

  const caminhoLinha = pontos.map((p, i) => `${i === 0 ? "M" : "L"}${p.x.toFixed(1)},${p.y.toFixed(1)}`).join(" ");
  const caminhoArea =
    pontos.length > 0
      ? `${caminhoLinha} L${pontos[pontos.length - 1].x.toFixed(1)},${ALTURA_SVG} L${pontos[0].x.toFixed(1)},${ALTURA_SVG} Z`
      : "";

  const pontoAtivo = celulaAtiva ? pontos.find((p) => p.dia === celulaAtiva.dia) : undefined;

  // Varredura contínua do mouse sobre a área do gráfico — acha o ponto
  // mais próximo pela posição X, sem depender de acertar um alvo fino
  // por célula. Nunca muda focoAtivo (isso é só para teclado/Tab); só
  // ativa a mesma tooltip compartilhada.
  function aoMoverMouse(evento: MouseEvent<HTMLDivElement>) {
    if (pontos.length === 0) return;
    const rect = evento.currentTarget.getBoundingClientRect();
    const fracao = Math.min(1, Math.max(0, (evento.clientX - rect.left) / rect.width));
    const indice = Math.round(fracao * (pontos.length - 1));
    const dia = heatmap[indice];
    if (dia) onAtivar(evento, dia);
  }

  const rotulosX = useMemo(() => {
    if (pontos.length === 0) return [];
    const quantidade = Math.min(5, pontos.length);
    const indices = Array.from({ length: quantidade }, (_, i) =>
      Math.round((i / Math.max(1, quantidade - 1)) * (pontos.length - 1)),
    );
    return [...new Set(indices)].map((i) => ({ x: pontos[i].x, rotulo: formatarDataEixoX(pontos[i].dia) }));
  }, [pontos]);

  return (
    <div className="linha-tempo">
      <div className="linha-tempo-eixo-y" aria-hidden="true">
        <span>{formatarMinutosLegivel(maximo)}</span>
        <span>{formatarMinutosLegivel(maximo / 2)}</span>
        <span>0h</span>
      </div>
      <div className="linha-tempo-corpo">
        <div className="linha-tempo-svg-wrap" onMouseMove={aoMoverMouse} onMouseLeave={onDesativar}>
          <svg viewBox={`0 0 ${LARGURA_SVG} ${ALTURA_SVG}`} preserveAspectRatio="none" className="linha-tempo-svg" aria-hidden="true">
            {caminhoArea && <path d={caminhoArea} className="linha-tempo-area" />}
            {caminhoLinha && <path d={caminhoLinha} className="linha-tempo-linha" fill="none" />}
            {pontoAtivo && (
              <>
                <line x1={pontoAtivo.x} x2={pontoAtivo.x} y1={0} y2={ALTURA_SVG} className="linha-tempo-guia" />
                <circle cx={pontoAtivo.x} cy={pontoAtivo.y} r={4} className="linha-tempo-ponto" />
              </>
            )}
          </svg>
          {/* Alvos focáveis por teclado (roving tabindex) — invisíveis,
              pointer-events:none (o hover real é feito por varredura
              contínua acima, não por acertar essas faixas finas). */}
          <div className="linha-tempo-alvos">
            {heatmap.map((dia, indice) => (
              <span
                key={dia.dia}
                ref={(el) => registrarRef(dia.dia, el)}
                tabIndex={dia.dia === focoAtivo ? 0 : -1}
                className="linha-tempo-alvo"
                style={{ left: `${n > 1 ? (indice / (n - 1)) * 100 : 50}%` }}
                aria-label={`${formatarDataTooltip(dia.dia)}: ${formatarTempoTooltip(dia.segundos_liquidos)}`}
                onFocus={(evento) => onAtivar(evento, dia)}
                onBlur={onDesativar}
                onKeyDown={(evento) => onTeclar(evento, indiceDeDia.get(dia.dia) ?? indice)}
              />
            ))}
          </div>
        </div>
        <div className="linha-tempo-eixo-x" aria-hidden="true">
          {rotulosX.map(({ x, rotulo }) => (
            <span key={x} style={{ left: `${(x / LARGURA_SVG) * 100}%` }}>
              {rotulo}
            </span>
          ))}
        </div>
      </div>
    </div>
  );
}

// ---------------------------------------------------------------------
// 1 ANO — heatmap de contribuição (lógica preservada da rodada
// anterior; só a apresentação ganhou dias da semana + legenda).
// ---------------------------------------------------------------------
function GraficoHeatmapAnual({ heatmap, focoAtivo, celulaAtiva, indiceDeDia, registrarRef, onAtivar, onDesativar, onTeclar }: PropsModoGrafico) {
  const { semanas, rotulosMes } = useMemo(() => agruparPorSemana(heatmap), [heatmap]);

  return (
    <>
      {/* heatmap-tempo-dias-semana fica FORA de heatmap-tempo-scroll de
          propósito — é uma coluna fixa que nunca rola, só meses+células
          (heatmap-tempo-grade) participam do overflow-x. Isso corrige o
          clipping visual que os rótulos tinham quando estavam dentro do
          próprio container que rola (ver auditoria desta fase). */}
      <div className="heatmap-tempo-corpo">
        <div className="heatmap-tempo-dias-semana" aria-hidden="true">
          <span style={{ gridRowStart: 1 }}>Seg</span>
          <span style={{ gridRowStart: 3 }}>Qua</span>
          <span style={{ gridRowStart: 5 }}>Sex</span>
        </div>
        <div className="heatmap-tempo-scroll">
          <div className="heatmap-tempo-grade">
            <div className="heatmap-tempo-meses" aria-hidden="true">
              {rotulosMes.map(({ coluna, rotulo }) => (
                <span key={coluna} style={{ gridColumnStart: coluna + 1 }}>
                  {rotulo}
                </span>
              ))}
            </div>
            <div className="heatmap-tempo" role="img" aria-label={`Mapa de calor dos últimos ${heatmap.length} dias de tempo estudado`}>
              {semanas.map((semana, indiceSemana) =>
                semana.map((dia, indiceDiaSemana) =>
                  dia ? (
                    <span
                      key={dia.dia}
                      ref={(el) => registrarRef(dia.dia, el)}
                      tabIndex={dia.dia === focoAtivo ? 0 : -1}
                      className={`heatmap-celula nivel-${dia.intensidade}${celulaAtiva?.dia === dia.dia ? " heatmap-celula-ativa" : ""}`}
                      aria-label={`${formatarDataTooltip(dia.dia)}: ${formatarTempoTooltip(dia.segundos_liquidos)}`}
                      onMouseEnter={(evento) => onAtivar(evento, dia)}
                      onMouseLeave={onDesativar}
                      onFocus={(evento) => onAtivar(evento, dia)}
                      onBlur={onDesativar}
                      onKeyDown={(evento) => onTeclar(evento, indiceDeDia.get(dia.dia) ?? 0)}
                    />
                  ) : (
                    <span key={`vazio-${indiceSemana}-${indiceDiaSemana}`} className="heatmap-celula heatmap-celula-vazia" aria-hidden="true" />
                  ),
                ),
              )}
            </div>
          </div>
        </div>
      </div>
      <div className="heatmap-legenda" aria-hidden="true">
        <span>Menos</span>
        <span className="heatmap-celula nivel-0" />
        <span className="heatmap-celula nivel-1" />
        <span className="heatmap-celula nivel-2" />
        <span className="heatmap-celula nivel-3" />
        <span className="heatmap-celula nivel-4" />
        <span>Mais</span>
      </div>
    </>
  );
}

// Sequência + gráfico de tempo líquido adaptativo por período —
// 7D em barras, 30D/90D em linha+área, 1 ANO em heatmap de
// contribuição. Deliberadamente separado de qualquer streak/heatmap
// pedagógico (que mede conclusão de sessoes_estudo, não tempo).
// Reutilizado por /meu-estudo.
export default function ConsistenciaTempo({ dados }: { dados: DadosTempoEstudo }) {
  const [periodo, setPeriodo] = useState<Periodo>("1a");
  const [celulaAtiva, setCelulaAtiva] = useState<CelulaAtiva | null>(null);

  // Recorte 100% client-side da malha já carregada (até 366 dias) — o
  // seletor de período NUNCA refaz a chamada ao Supabase, só corta o
  // array que useDadosTempoEstudo já devolveu.
  const diasSelecionados = PERIODOS.find((p) => p.valor === periodo)?.dias ?? dados.diasHistorico;
  const heatmapRecortado = useMemo(
    () => dados.heatmap.slice(-Math.min(diasSelecionados, dados.diasHistorico)),
    [dados.heatmap, diasSelecionados, dados.diasHistorico],
  );

  const insights = useMemo(() => calcularInsightsPeriodo(heatmapRecortado), [heatmapRecortado]);

  // Índice cronológico (0..N-1) de cada dia dentro de heatmapRecortado —
  // é o que ArrowLeft/Right/Up/Down usam para navegar (±1 dia, ±7
  // dias), igual nos 3 modos de visualização (todos operam sobre o
  // mesmo array plano, só a apresentação visual muda).
  const indiceDeDia = useMemo(() => {
    const mapa = new Map<string, number>();
    heatmapRecortado.forEach((d, i) => mapa.set(d.dia, i));
    return mapa;
  }, [heatmapRecortado]);

  // Roving tabindex: só a célula de focoAtivo tem tabIndex=0 (todas as
  // outras -1), nos 3 modos — Tab entra no gráfico uma vez e Tab de
  // novo sai dele, em vez de parar em até 366 elementos. Recalculado
  // (nunca focado de verdade sozinho) sempre que o período/modo muda —
  // reset durante o render (padrão recomendado pela própria
  // documentação do React para "ajustar estado quando uma prop
  // muda"), não num useEffect: nunca chama .focus() aqui, então trocar
  // de período nunca rouba o foco real dos botões 7D/30D/90D/1 ANO que
  // o aluno acabou de clicar.
  const [heatmapRecortadoAnterior, setHeatmapRecortadoAnterior] = useState(heatmapRecortado);
  const [focoAtivo, setFocoAtivo] = useState<string | null>(() => calcularFocoPadrao(heatmapRecortado));
  if (heatmapRecortado !== heatmapRecortadoAnterior) {
    setHeatmapRecortadoAnterior(heatmapRecortado);
    setFocoAtivo(calcularFocoPadrao(heatmapRecortado));
  }

  const celulaRefs = useRef<Record<string, HTMLElement | null>>({});
  function registrarRef(dia: string, el: HTMLElement | null) {
    celulaRefs.current[dia] = el;
  }

  function moverFoco(indiceDesejado: number) {
    if (heatmapRecortado.length === 0) return;
    const indiceClamp = Math.max(0, Math.min(heatmapRecortado.length - 1, indiceDesejado));
    const novoDia = heatmapRecortado[indiceClamp].dia;
    setFocoAtivo(novoDia);
    celulaRefs.current[novoDia]?.focus();
  }

  function aoTeclarCelula(evento: KeyboardEvent<HTMLElement>, indiceAtual: number) {
    switch (evento.key) {
      case "ArrowRight":
        evento.preventDefault();
        moverFoco(indiceAtual + 1);
        break;
      case "ArrowLeft":
        evento.preventDefault();
        moverFoco(indiceAtual - 1);
        break;
      case "ArrowDown":
        evento.preventDefault();
        moverFoco(indiceAtual + 7);
        break;
      case "ArrowUp":
        evento.preventDefault();
        moverFoco(indiceAtual - 7);
        break;
      default:
        break;
    }
  }

  function aoAtivarCelula(evento: MouseEvent<HTMLElement> | FocusEvent<HTMLElement>, dia: CelulaHeatmap) {
    const rect = evento.currentTarget.getBoundingClientRect();
    const abrirParaCima = rect.top > 120;
    const margem = 90;
    setCelulaAtiva({
      dia: dia.dia,
      segundosLiquidos: dia.segundos_liquidos,
      left: Math.min(Math.max(rect.left + rect.width / 2, margem), window.innerWidth - margem),
      top: abrirParaCima ? rect.top : rect.bottom,
      abrirParaCima,
    });
  }
  function aoDesativarCelula() {
    setCelulaAtiva(null);
  }

  const propsModo: PropsModoGrafico = {
    heatmap: heatmapRecortado,
    focoAtivo,
    celulaAtiva,
    indiceDeDia,
    registrarRef,
    onAtivar: aoAtivarCelula,
    onDesativar: aoDesativarCelula,
    onTeclar: aoTeclarCelula,
  };

  return (
    <article className="stats-panel heatmap-panel">
      <div className="stats-title consistencia-cabecalho">
        <div>
          <p className="dashboard-label">CONSISTÊNCIA</p>
          <div className="consistencia-titulo-linha">
            <h2>Consistência de estudo</h2>
            <div className="heatmap-periodo-seletor" role="group" aria-label="Período do gráfico">
              {PERIODOS.map((p) => (
                <button
                  key={p.valor}
                  type="button"
                  className={p.valor === periodo ? "ativo" : ""}
                  aria-pressed={p.valor === periodo}
                  onClick={() => setPeriodo(p.valor)}
                >
                  {p.rotulo}
                </button>
              ))}
            </div>
          </div>
          <p className="consistencia-subtexto">Veja como seu ritmo de estudo evolui.</p>
        </div>
        <strong>{dados.sequenciaTempo} dias de sequência</strong>
      </div>

      {heatmapRecortado.length === 0 ? (
        <p className="stats-empty">Comece uma sessão de teoria ou questões para ver seu histórico aqui.</p>
      ) : (
        <div className="consistencia-grafico-entrada" key={periodo}>
          {periodo === "7d" && <GraficoBarras {...propsModo} />}
          {(periodo === "30d" || periodo === "90d") && <GraficoLinhaArea {...propsModo} />}
          {periodo === "1a" && <GraficoHeatmapAnual {...propsModo} />}
        </div>
      )}

      <div className="consistencia-insights">
        <div>
          <span>Dias ativos</span>
          <strong>{insights.diasAtivos > 0 ? insights.diasAtivos : "—"}</strong>
        </div>
        <div>
          <span>Média em dias estudados</span>
          <strong>{insights.mediaSegundosPorDiaAtivo !== null ? formatarMinutosLegivel(insights.mediaSegundosPorDiaAtivo) : "—"}</strong>
        </div>
        <div>
          <span>Melhor dia</span>
          {insights.melhorDia ? (
            <>
              <strong>{formatarMinutosLegivel(insights.melhorDia.segundosLiquidos)}</strong>
              <small>{formatarDataCurta(insights.melhorDia.dia)}</small>
            </>
          ) : (
            <strong>—</strong>
          )}
        </div>
      </div>

      {celulaAtiva && (
        <div
          className={`heatmap-tooltip${celulaAtiva.abrirParaCima ? " heatmap-tooltip-cima" : ""}`}
          style={{ left: celulaAtiva.left, top: celulaAtiva.top }}
          role="tooltip"
        >
          <strong>{formatarDataTooltip(celulaAtiva.dia)}</strong>
          <span>{formatarTempoTooltip(celulaAtiva.segundosLiquidos)}</span>
        </div>
      )}
    </article>
  );
}
