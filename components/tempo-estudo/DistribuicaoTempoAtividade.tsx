"use client";

import { formatarHorasMinutos, ROTULO_TIPO_ATIVIDADE, type DadosTempoEstudo } from "./useDadosTempoEstudo";

// Breakdown por tipo_atividade (teoria/questões/leitura/revisão) —
// origem ≠ tipo_atividade, nunca misturar as duas dimensões. Reutilizado
// por /meu-estudo.
export default function DistribuicaoTempoAtividade({ dados }: { dados: DadosTempoEstudo }) {
  return (
    <article className="stats-panel tipo-atividade-panel">
      <div className="stats-title">
        <div>
          <p className="dashboard-label">POR TIPO DE ATIVIDADE</p>
          <h2>Onde o tempo foi</h2>
        </div>
      </div>
      {dados.porTipoAtividade.length === 0 ? (
        <p className="stats-empty">Ainda não há tempo registrado por tipo de atividade.</p>
      ) : (
        dados.porTipoAtividade.map((item) => (
          <div className="metric-row tempo-atividade-linha" key={item.tipo_atividade}>
            <div>
              <strong>{ROTULO_TIPO_ATIVIDADE[item.tipo_atividade] ?? item.tipo_atividade}</strong>
              <small>{formatarHorasMinutos(item.segundos_liquidos)}</small>
            </div>
            <div className="metric-track">
              <span style={{ width: `${item.percentual}%` }} />
            </div>
            <b>{item.percentual}%</b>
          </div>
        ))
      )}
    </article>
  );
}
