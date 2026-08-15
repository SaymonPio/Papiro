"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import MarcaCarregando from "@/components/ui/MarcaCarregando";
import { createClient } from "@/utils/supabase/client";

type Resultado = {
  questoes_respondidas: number;
  acertos: number;
  nivel_meta: string;
  minutos_revisao: number;
  missao_id: string | null;
  // Modo Papiro por unidades pedagógicas (Fase 2J-F) — colunas aditivas de
  // sessoes_estudo (questao_unidades_pedagogicas.sql). Ambas null para toda
  // sessão livre/personalizada e para o fluxo antigo de missão de conteúdo
  // com uma única unidade.
  unidade_pedagogica_id: string | null;
  tipo_pratica: string | null;
};

export default function ResultadoQuestoes() {
  const [resultado, setResultado] = useState<Resultado | null>(null);
  const [erro, setErro] = useState("");
  // "proximo" vem da URL (definido por app/questoes/page.tsx ao concluir
  // concluir_pratica_unidade): "unidade" = ainda faltam unidades a praticar;
  // "missaoFinal" = esta era a última, a Missão Final já está liberada.
  // Ausente = comportamento antigo (fim de uma missão inteira ou de uma
  // sessão livre) — nunca alterado.
  const [proximo, setProximo] = useState<"unidade" | "missaoFinal" | null>(null);
  const [linkMissaoFinal, setLinkMissaoFinal] = useState<string | null>(null);

  useEffect(() => {
    async function carregar() {
      const parametros = new URLSearchParams(window.location.search);
      const sessao = parametros.get("sessao");
      const proximoParam = parametros.get("proximo");
      if (proximoParam === "unidade" || proximoParam === "missaoFinal") setProximo(proximoParam);

      if (!sessao) { setErro("Sessão não encontrada."); return; }
      const { data: { user } } = await createClient().auth.getUser();
      if (!user) { window.location.replace("/login"); return; }

      const { data, error } = await createClient().from("sessoes_estudo")
        .select("questoes_respondidas, acertos, nivel_meta, minutos_revisao, missao_id, unidade_pedagogica_id, tipo_pratica")
        .eq("id", sessao).single();
      if (error || !data) { setErro("Não foi possível carregar o resultado."); return; }
      setResultado(data as Resultado);

      // Só monta o link da Missão Final quando ela acabou de ser liberada —
      // exige materiaId (contrato de lerMissaoCronograma/montarLinkMissao),
      // resolvido aqui a partir da própria missão (RLS já concede SELECT
      // para o aluno em missoes/curso_conteudos/curso_materias).
      if (proximoParam === "missaoFinal" && data.missao_id) {
        const { data: missao } = await createClient()
          .from("missoes")
          .select("conteudo_id, curso_conteudos(curso_materia_id, curso_materias(materia_id))")
          .eq("id", data.missao_id)
          .maybeSingle();
        const materiaId = (
          missao as { curso_conteudos: { curso_materias: { materia_id: number | null } | null } | null } | null
        )?.curso_conteudos?.curso_materias?.materia_id;
        if (materiaId) {
          const link = new URLSearchParams({
            origem: "cronograma",
            materia: String(materiaId),
            quantidade: "30",
            missao: data.missao_id,
            missaoFinal: "1",
          });
          setLinkMissaoFinal(`/questoes?${link.toString()}`);
        }
      }
    }
    carregar();
  }, []);

  if (erro) return <main className="method-page result-page"><p className="method-message">{erro}</p><Link href="/painel">Voltar ao painel</Link></main>;
  if (!resultado) return <main className="dashboard-loading"><MarcaCarregando texto="Calculando seu resultado..." /></main>;

  const percentual = resultado.questoes_respondidas ? Math.round((resultado.acertos / resultado.questoes_respondidas) * 100) : 0;

  // Modo Papiro por unidades pedagógicas: resultado de UMA unidade (nunca
  // a missão inteira) — título/CTA próprios, discretos, sem reaproveitar
  // "MISSÃO CONCLUÍDA" (seria falso: as demais unidades/a Missão Final
  // ainda não foram feitas).
  if (proximo === "unidade" || proximo === "missaoFinal") {
    return (
      <main className="method-page result-page">
        <section className="result-card">
          <p className="dashboard-label">{proximo === "missaoFinal" ? "TODAS AS UNIDADES CONCLUÍDAS" : "UNIDADE CONCLUÍDA"}</p>
          <h1>{proximo === "missaoFinal" ? "Hora da Missão Final Papiro." : "Mais uma unidade no bolso."}</h1>
          <p>
            {proximo === "missaoFinal"
              ? "Você concluiu a teoria e a prática de todas as unidades. Agora é hora de misturar tudo na Missão Final."
              : "Continue para a próxima unidade da aula quando estiver pronto."}
          </p>
          <div className="result-stats">
            <span><strong>{resultado.questoes_respondidas}</strong>Respondidas</span>
            <span><strong>{resultado.acertos}</strong>Acertos</span>
            <span><strong>{percentual}%</strong>Aproveitamento</span>
          </div>
          <div className="result-actions">
            <Link href="/caderno-de-erros">Revisar meus erros</Link>
            {proximo === "missaoFinal" ? (
              linkMissaoFinal
                ? <Link href={linkMissaoFinal}>Fazer a Missão Final Papiro</Link>
                : <Link href="/cronograma">Voltar ao cronograma</Link>
            ) : (
              <Link href={`/teoria?missao=${resultado.missao_id}`}>Seguir para a próxima unidade</Link>
            )}
          </div>
        </section>
      </main>
    );
  }

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
          <Link href={resultado.missao_id ? "/cronograma" : "/painel"}>
            {resultado.missao_id ? "Voltar ao cronograma" : "Voltar ao painel"}
          </Link>
        </div>
      </section>
    </main>
  );
}
