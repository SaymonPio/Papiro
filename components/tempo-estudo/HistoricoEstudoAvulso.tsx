"use client";

import { useEffect, useState } from "react";
import { createClient } from "@/utils/supabase/client";
import ClassificarEstudoAvulso from "./ClassificarEstudoAvulso";
import { formatarDuracaoCurta, ROTULO_TIPO_ATIVIDADE } from "./useDadosTempoEstudo";

const MESES_ABREV = ["jan", "fev", "mar", "abr", "mai", "jun", "jul", "ago", "set", "out", "nov", "dez"];

function formatarDataAbreviada(iso: string): string {
  const data = new Date(iso);
  return `${String(data.getDate()).padStart(2, "0")} ${MESES_ABREV[data.getMonth()]}`;
}

type LinhaBruta = {
  id: number;
  tipo_atividade: string;
  segundos_liquidos: number;
  descricao_estudo: string | null;
  materia_id: number | null;
  assunto_id: number | null;
  iniciado_em: string;
  materias: { nome: string } | null;
  assuntos: { nome: string } | null;
};

const LIMITE_HISTORICO = 20;

async function buscarHistorico(): Promise<LinhaBruta[] | null> {
  const { data, error } = await createClient()
    .from("sessoes_tempo")
    .select("id, tipo_atividade, segundos_liquidos, descricao_estudo, materia_id, assunto_id, iniciado_em, materias(nome), assuntos(nome)")
    .eq("origem", "estudo_avulso")
    .eq("status", "encerrada")
    .order("iniciado_em", { ascending: false })
    .limit(LIMITE_HISTORICO);
  if (error) {
    console.error("[HistoricoEstudoAvulso] Falha ao carregar historico:", error);
    return null;
  }
  return (data as unknown as LinhaBruta[] | null) ?? [];
}

// Histórico de sessões do Cronômetro Livre (origem = estudo_avulso) — só
// essa origem tem esta lista própria; cronograma/questões já têm seu
// próprio histórico pedagógico em outras telas (missões concluídas,
// resultado de sessão), que esta lista nunca duplica. `chaveAtualizacao`
// (prop) força um refetch quando o pai sabe que algo mudou (nova sessão
// acabou de ser finalizada) sem precisar de polling.
export default function HistoricoEstudoAvulso({ chaveAtualizacao }: { chaveAtualizacao: number }) {
  const [linhas, setLinhas] = useState<LinhaBruta[] | null>(null);
  const [idClassificando, setIdClassificando] = useState<number | null>(null);

  useEffect(() => {
    let ativo = true;
    buscarHistorico().then((resultado) => {
      if (ativo) setLinhas(resultado ?? []);
    });
    return () => {
      ativo = false;
    };
  }, [chaveAtualizacao]);

  if (linhas === null) {
    return <p className="stats-empty">Carregando histórico...</p>;
  }

  if (linhas.length === 0) {
    return <p className="stats-empty">Nenhum estudo avulso registrado ainda.</p>;
  }

  return (
    <ul className="cronometro-livre-historico">
      {linhas.map((linha) => {
        const naoClassificado = linha.tipo_atividade === "nao_classificado";
        return (
          <li key={linha.id} className={naoClassificado ? "cronometro-livre-historico-item--pendente" : undefined}>
            <div className="cronometro-livre-historico-linha">
              <div>
                <strong>
                  {formatarDataAbreviada(linha.iniciado_em)} · {formatarDuracaoCurta(linha.segundos_liquidos)}
                </strong>
                <small>
                  {naoClassificado ? "Não classificado" : `${ROTULO_TIPO_ATIVIDADE[linha.tipo_atividade] ?? linha.tipo_atividade} · Estudo avulso`}
                </small>
                {(linha.materias?.nome || linha.assuntos?.nome) && (
                  <small className="cronometro-livre-historico-materia">
                    {linha.materias?.nome}
                    {linha.materias?.nome && linha.assuntos?.nome ? " · " : ""}
                    {linha.assuntos?.nome}
                  </small>
                )}
                {linha.descricao_estudo && <p className="cronometro-livre-historico-descricao">&ldquo;{linha.descricao_estudo}&rdquo;</p>}
              </div>
              {naoClassificado && idClassificando !== linha.id && (
                <button type="button" className="cronometro-livre-botao-classificar" onClick={() => setIdClassificando(linha.id)}>
                  Classificar
                </button>
              )}
            </div>

            {idClassificando === linha.id && (
              <ClassificarEstudoAvulso
                sessaoTempoId={linha.id}
                segundosLiquidos={linha.segundos_liquidos}
                materiaIdInicial={linha.materia_id}
                assuntoIdInicial={linha.assunto_id}
                descricaoInicial={linha.descricao_estudo}
                aoClassificar={() => {
                  setIdClassificando(null);
                  buscarHistorico().then((resultado) => setLinhas(resultado ?? []));
                }}
                aoFechar={() => setIdClassificando(null)}
              />
            )}
          </li>
        );
      })}
    </ul>
  );
}
