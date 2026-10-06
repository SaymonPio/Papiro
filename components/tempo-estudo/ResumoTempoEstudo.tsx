"use client";

import { formatarHorasMinutos, type DadosTempoEstudo } from "./useDadosTempoEstudo";

const MESES_COMPLETOS = [
  "Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho",
  "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro",
];
const MESES_ABREV = ["jan", "fev", "mar", "abr", "mai", "jun", "jul", "ago", "set", "out", "nov", "dez"];

// "06 de outubro" — subtexto do card Hoje.
function formatarDataExtensa(dia: string): string {
  const data = new Date(`${dia}T00:00:00`);
  return `${String(data.getDate()).padStart(2, "0")} de ${MESES_COMPLETOS[data.getMonth()].toLowerCase()}`;
}

// "06 out" — ponta final do subtexto do card do ano vigente.
function formatarDataAbreviada(dia: string): string {
  const data = new Date(`${dia}T00:00:00`);
  return `${String(data.getDate()).padStart(2, "0")} ${MESES_ABREV[data.getMonth()]}`;
}

// Soma client-side de segundos_liquidos do ano informado, dentro da
// malha de até 366 dias já carregada por useDadosTempoEstudo — nunca
// uma chamada nova ao banco. Correta por construção: a janela de 366
// dias (hoje - 365 até hoje) sempre cobre integralmente "01/jan do ano
// corrente até hoje" (no máximo 366 dias de distância), nunca uma soma
// diferente da de "Últimos 366 dias" por coincidência, porque os dois
// filtros são deliberadamente diferentes (ano calendário vs. janela
// móvel) e só convergiriam num caso extremo (today = 31/dez, quando a
// janela de 366 dias passa a cobrir o ano inteiro de ponta a ponta).
function somarAno(heatmap: DadosTempoEstudo["heatmap"], ano: number): number {
  const prefixo = `${ano}-`;
  return heatmap.reduce((soma, dia) => (dia.dia.startsWith(prefixo) ? soma + dia.segundos_liquidos : soma), 0);
}

// Cards "Hoje / Semana / <Mês vigente> / <Ano vigente>" — página
// completa /meu-estudo. "Últimos 366 dias" NÃO é mais exibido como KPI
// aqui (continua existindo em dados.heatmap/diasHistorico/
// totalPeriodoSegundos no hook, só não vira card — o heatmap/modo 1
// ANO de ConsistenciaTempo continua usando a malha de 366 dias
// integralmente). Meta diária não é mais um card aqui — tem seu próprio
// painel de progresso (MetaDiariaTempo).
//
// "Hoje" (a data de referência) vem do ÚLTIMO dia da própria malha de
// useDadosTempoEstudo — a mesma referência temporal que o resto do
// sistema já usa para zero-preencher o heatmap (America/Sao_Paulo via
// o relógio do navegador, nunca um new Date() paralelo e
// potencialmente desalinhado). ResumoTempoEstudo só monta depois que
// dados.carregando já é false (gate em app/meu-estudo/page.tsx) — isto
// nunca roda durante SSR/primeiro render, então não há risco de
// hydration mismatch mesmo lendo datas aqui.
export default function ResumoTempoEstudo({ dados }: { dados: DadosTempoEstudo }) {
  const hojeChave = dados.heatmap.length > 0 ? dados.heatmap[dados.heatmap.length - 1].dia : null;
  const hojeData = hojeChave ? new Date(`${hojeChave}T00:00:00`) : null;
  const anoAtual = hojeData ? hojeData.getFullYear() : null;
  const nomeMesAtual = hojeData ? MESES_COMPLETOS[hojeData.getMonth()] : "Mês";
  const somaAnoAtual = anoAtual !== null ? somarAno(dados.heatmap, anoAtual) : 0;

  return (
    <section className="stats-summary">
      {/* .meu-estudo-card: hover/foco sutil escopado só a estes 4 cards
          (não ao .stats-summary article compartilhado com /estatisticas
          pedagógico) — nenhuma ação real nesses cards, então sem
          tabIndex/cursor:pointer, só reação visual no :hover (ver
          globals.css). */}
      <article className="meu-estudo-card">
        <span>Hoje</span>
        <strong>{formatarHorasMinutos(dados.resumoTempo?.segundos_hoje ?? 0)}</strong>
        <small>{hojeChave ? formatarDataExtensa(hojeChave) : "—"}</small>
      </article>
      <article className="meu-estudo-card">
        <span>Semana</span>
        <strong>{formatarHorasMinutos(dados.resumoTempo?.segundos_semana ?? 0)}</strong>
        <small>últimos 7 dias</small>
      </article>
      <article className="meu-estudo-card">
        <span>{nomeMesAtual}</span>
        <strong>{formatarHorasMinutos(dados.resumoTempo?.segundos_mes ?? 0)}</strong>
        <small>mês vigente</small>
      </article>
      <article className="meu-estudo-card">
        <span>{anoAtual ?? "Ano"}</span>
        <strong>{formatarHorasMinutos(somaAnoAtual)}</strong>
        <small>{hojeChave ? `01 jan — ${formatarDataAbreviada(hojeChave)}` : "—"}</small>
      </article>
    </section>
  );
}
