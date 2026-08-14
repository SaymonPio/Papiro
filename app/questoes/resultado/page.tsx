"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import MarcaCarregando from "@/components/ui/MarcaCarregando";
import { createClient } from "@/utils/supabase/client";

type Resultado = { questoes_respondidas: number; acertos: number; nivel_meta: string; minutos_revisao: number; missao_id: string | null };

export default function ResultadoQuestoes() {
  const [resultado, setResultado] = useState<Resultado | null>(null);
  const [erro, setErro] = useState("");

  useEffect(() => {
    async function carregar() {
      const sessao = new URLSearchParams(window.location.search).get("sessao");
      if (!sessao) { setErro("Sessão não encontrada."); return; }
      const { data: { user } } = await createClient().auth.getUser();
      if (!user) { window.location.replace("/login"); return; }
      const { data, error } = await createClient().from("sessoes_estudo")
        .select("questoes_respondidas, acertos, nivel_meta, minutos_revisao, missao_id")
        .eq("id", sessao).single();
      if (error) setErro("Não foi possível carregar o resultado.");
      else setResultado(data as Resultado);
    }
    carregar();
  }, []);

  if (erro) return <main className="method-page result-page"><p className="method-message">{erro}</p><Link href="/painel">Voltar ao painel</Link></main>;
  if (!resultado) return <main className="dashboard-loading"><MarcaCarregando texto="Calculando seu resultado..." /></main>;

  const percentual = resultado.questoes_respondidas ? Math.round((resultado.acertos / resultado.questoes_respondidas) * 100) : 0;
  return (
    <main className="method-page result-page">
      <section className="result-card">
        <p className="dashboard-label">{resultado.missao_id ? "MISSÃO CONCLUÍDA" : "SESSÃO CONCLUÍDA"}</p>
        <h1>{resultado.missao_id ? "Missão cumprida." : "Consistência registrada."}</h1>
        <p>{resultado.missao_id ? "Teoria e questões concluídas com sucesso." : "Você avançou mais um dia no Método Papiro."}</p>
        <div className="result-stats">
          <span><strong>{resultado.questoes_respondidas}</strong>Respondidas</span>
          <span><strong>{resultado.acertos}</strong>Acertos</span>
          <span><strong>{percentual}%</strong>Aproveitamento</span>
          <span><strong>{resultado.minutos_revisao} min</strong>Revisão prevista</span>
        </div>
        <div className="result-actions">
          <Link href="/caderno-de-erros">Revisar meus erros</Link>
          <Link href="/painel">Voltar ao painel</Link>
        </div>
      </section>
    </main>
  );
}
