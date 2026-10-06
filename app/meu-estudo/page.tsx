"use client";

import Link from "next/link";
import { useEffect } from "react";
import ConsistenciaTempo from "@/components/tempo-estudo/ConsistenciaTempo";
import DistribuicaoTempoAtividade from "@/components/tempo-estudo/DistribuicaoTempoAtividade";
import MetaDiariaTempo from "@/components/tempo-estudo/MetaDiariaTempo";
import ResumoTempoEstudo from "@/components/tempo-estudo/ResumoTempoEstudo";
import { useDadosTempoEstudo } from "@/components/tempo-estudo/useDadosTempoEstudo";
import MarcaCarregando from "@/components/ui/MarcaCarregando";
import { createClient } from "@/utils/supabase/client";

// Comportamento e tempo de estudo — deliberadamente SEPARADO de
// /estatisticas (desempenho acadêmico: questões, aproveitamento, erros,
// revisões). Três entradas levam aqui: painel (bloco Disponibilidade),
// CronometroEstudo ("Ver meu estudo"), e o resumo compacto em
// /estatisticas (ResumoTempoEstudoCompacto). 366 = máximo aceito por
// historico_tempo_estudo — a página completa usa a maior janela
// possível para um card "Últimos 366 dias" (nunca "Total"/lifetime,
// que nenhuma RPC hoje calcula) e um heatmap honestos; o resumo compacto usa
// uma janela menor (ver ResumoTempoEstudoCompacto/app/estatisticas).
const DIAS_HISTORICO_COMPLETO = 366;

export default function MeuEstudo() {
  // Mesmo padrão de proteção de página já usado em app/questoes/page.tsx
  // e app/teoria/page.tsx.
  useEffect(() => {
    async function protegerPagina() {
      const { data: { user } } = await createClient().auth.getUser();
      if (!user) window.location.replace("/login");
    }
    protegerPagina();
  }, []);

  const dados = useDadosTempoEstudo(DIAS_HISTORICO_COMPLETO);

  if (dados.carregando) {
    return (
      <main className="dashboard-loading">
        <MarcaCarregando texto="Carregando seu tempo de estudo..." />
      </main>
    );
  }

  return (
    <main className="stats-page meu-estudo-page meu-estudo-entrada">
      <header className="stats-header">
        <div>
          <p className="dashboard-label">COMPORTAMENTO DE ESTUDO</p>
          <h1>Meu estudo.</h1>
          <span>Tempo líquido medido pelo cronômetro — independente de quantas sessões você concluiu.</span>
        </div>
        <Link href="/painel">Voltar ao painel</Link>
      </header>

      <ResumoTempoEstudo dados={dados} />

      {/* Heatmap como painel grande à esquerda (domina visualmente);
          Meta diária + Distribuição empilhadas numa coluna lateral à
          direita — elimina o espaço vazio que ficava ao lado de "Onde
          o tempo foi" quando ela ocupava uma section própria. Em telas
          estreitas .stats-grid já colapsa para 1 coluna (ver
          globals.css), então a coluna lateral desempilha naturalmente
          depois do heatmap: Consistência, Meta diária, Onde o tempo foi. */}
      <section className="stats-grid">
        <ConsistenciaTempo dados={dados} />
        <div className="meu-estudo-coluna-lateral">
          <MetaDiariaTempo dados={dados} />
          <DistribuicaoTempoAtividade dados={dados} />
        </div>
      </section>
    </main>
  );
}
