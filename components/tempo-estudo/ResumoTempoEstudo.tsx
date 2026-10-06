"use client";

import { formatarHorasMinutos, type DadosTempoEstudo } from "./useDadosTempoEstudo";

// Cards "Hoje/Semana/Mês/Últimos N dias" — página completa /meu-estudo.
// O resumo compacto de /estatisticas usa ResumoTempoEstudoCompacto (só
// Hoje/Semana/Sequência), não este. Meta diária NÃO é mais um card
// aqui — ganhou seu próprio painel de progresso (MetaDiariaTempo), que
// precisa de mais espaço (barra + texto) do que esta fileira compacta
// comporta sem desalinhar a altura dos outros 4 cards.
//
// O card de "Últimos N dias" NUNCA deve se chamar "Total": é a soma de
// historico_tempo_estudo(p_dias=366) — o máximo que essa RPC aceita —
// não um total desde o início/lifetime (não existe RPC para isso hoje).
export default function ResumoTempoEstudo({ dados }: { dados: DadosTempoEstudo }) {
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
        <small>{dados.percentualMeta !== null ? `${dados.percentualMeta}% da meta diária` : "meta diária não configurada"}</small>
      </article>
      <article className="meu-estudo-card">
        <span>Semana</span>
        <strong>{formatarHorasMinutos(dados.resumoTempo?.segundos_semana ?? 0)}</strong>
        <small>últimos 7 dias</small>
      </article>
      <article className="meu-estudo-card">
        <span>Mês</span>
        <strong>{formatarHorasMinutos(dados.resumoTempo?.segundos_mes ?? 0)}</strong>
        <small>mês corrente</small>
      </article>
      <article className="meu-estudo-card">
        <span>Últimos {dados.diasHistorico} dias</span>
        <strong>{formatarHorasMinutos(dados.totalPeriodoSegundos)}</strong>
        <small>soma do período, não é total acumulado</small>
      </article>
    </section>
  );
}
