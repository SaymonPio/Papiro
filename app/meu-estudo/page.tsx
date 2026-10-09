"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import ConsistenciaTempo from "@/components/tempo-estudo/ConsistenciaTempo";
import CronometroLivre from "@/components/tempo-estudo/CronometroLivre";
import DistribuicaoTempoAtividade from "@/components/tempo-estudo/DistribuicaoTempoAtividade";
import MetaDiariaTempo from "@/components/tempo-estudo/MetaDiariaTempo";
import ResumoTempoEstudo from "@/components/tempo-estudo/ResumoTempoEstudo";
import { useSessaoTempoGlobal } from "@/components/tempo-estudo/SessaoTempoProvider";
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
  const [aba, setAba] = useState<"resumo" | "cronometro-livre">("resumo");

  // Mesmo padrão de proteção de página já usado em app/questoes/page.tsx
  // e app/teoria/page.tsx — inalterado.
  useEffect(() => {
    async function protegerPagina() {
      const { data: { user } } = await createClient().auth.getUser();
      if (!user) window.location.replace("/login");
    }
    protegerPagina();
  }, []);

  const dados = useDadosTempoEstudo(DIAS_HISTORICO_COMPLETO);

  // Horas Líquidas — Cronômetro Livre (estudo avulso, fora do Papiro).
  // A sessão vem do SessaoTempoProvider global (app/layout.tsx), nunca de
  // um useSessaoTempo próprio desta página — é a MESMA instância que
  // alimenta o widget flutuante em qualquer área autenticada, inclusive
  // fora de /meu-estudo. Ver SessaoTempoProvider.tsx para o porquê de
  // viver na raiz em vez de aqui.
  const sessaoAvulsa = useSessaoTempoGlobal();

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
          <div className="meu-estudo-titulo-bloco">
            <h1>Meu estudo.</h1>
            <span>Tempo líquido medido pelo cronômetro — independente de quantas sessões você concluiu.</span>
          </div>
        </div>
        <Link href="/painel">Voltar ao painel</Link>
      </header>

      <div className="meu-estudo-abas-contentor">
        <div className="meu-estudo-abas" role="tablist" aria-label="Seção de Meu estudo">
          <button type="button" role="tab" aria-selected={aba === "resumo"} className={aba === "resumo" ? "selected" : ""} onClick={() => setAba("resumo")}>
            Resumo
          </button>
          <button
            type="button"
            role="tab"
            aria-selected={aba === "cronometro-livre"}
            className={aba === "cronometro-livre" ? "selected" : ""}
            onClick={() => setAba("cronometro-livre")}
          >
            Cronômetro livre
          </button>
        </div>
      </div>

      {aba === "resumo" ? (
        <>
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
        </>
      ) : (
        <CronometroLivre sessao={sessaoAvulsa} />
      )}
    </main>
  );
}
