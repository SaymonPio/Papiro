"use client";

import { useEffect, useMemo, useState } from "react";
import { createClient } from "@/utils/supabase/client";

// Horas Líquidas — fonte de dados compartilhada entre /meu-estudo (página
// completa de comportamento/tempo de estudo) e o resumo compacto em
// /estatisticas (desempenho acadêmico). Independente da camada de
// desempenho em questões: resumo_tempo_estudo/historico_tempo_estudo
// (supabase/migrations/20261003120000_criar_sessoes_tempo.sql) e, para o
// breakdown por tipo_atividade (origem ≠ tipo_atividade, nunca misturar
// as duas dimensões), uma leitura direta de sessoes_tempo — RLS já
// permite SELECT das próprias linhas, sem precisar de RPC nova. Nenhuma
// dessas chamadas depende de curso ativo/matrícula (auth.uid() já
// basta), então este hook nunca precisa validar contexto de curso — só
// a própria página (ex.: app/meu-estudo/page.tsx) protege contra usuário
// não autenticado.

export type ResumoTempoEstudo = {
  segundos_hoje: number;
  segundos_semana: number;
  segundos_mes: number;
  meta_diaria_segundos: number;
};
export type DiaHistoricoTempo = { dia: string; segundos_liquidos: number };
export type LinhaTipoAtividade = { tipo_atividade: string; segundos_liquidos: number };

export const ROTULO_TIPO_ATIVIDADE: Record<string, string> = {
  teoria: "Teoria",
  questoes: "Questões",
  leitura: "Leitura",
  revisao: "Revisão",
  // Estudo avulso (Cronômetro Livre) ainda sem classificação — os
  // segundos já contam normalmente aqui (esta tela nunca os esconde nem
  // os remarca como outra atividade), só com este rótulo discreto em vez
  // do valor técnico "nao_classificado" cru.
  nao_classificado: "Não classificado",
};

export function formatarHorasMinutos(totalSegundos: number): string {
  const segundos = Math.max(0, Math.floor(totalSegundos));
  const h = Math.floor(segundos / 3600);
  const m = Math.floor((segundos % 3600) / 60);
  return m > 0 ? `${h}h${String(m).padStart(2, "0")}` : `${h}h`;
}

// "42min" para menos de 1h, "1h"/"1h30" a partir de 1h — usado onde uma
// duração sub-hora precisa ficar legível sem o "0h" na frente (Cronômetro
// Livre: tempo realizado de uma sessão avulsa, histórico). Diferente de
// formatarHorasMinutos (que sempre mostra as horas, mesmo "0h"), que
// continua a formatação padrão do resto de /meu-estudo.
export function formatarDuracaoCurta(totalSegundos: number): string {
  const minutosTotais = Math.floor(Math.max(0, totalSegundos) / 60);
  const h = Math.floor(minutosTotais / 60);
  const m = minutosTotais % 60;
  if (h > 0 && m === 0) return `${h}h`;
  if (h > 0) return `${h}h${String(m).padStart(2, "0")}`;
  return `${m}min`;
}

// Única fórmula de "percentual da meta diária" do projeto — usada tanto
// pelo hook completo (useDadosTempoEstudo, abaixo) quanto pelo resumo
// leve (useResumoTempoHoje, para o anel de Disponibilidade no painel).
// Nunca reimplementada em paralelo: limitada a 100 de propósito (a UI
// decide separadamente se exibe texto além de 100%).
export function calcularPercentualMeta(resumoTempo: ResumoTempoEstudo | null): number | null {
  if (!resumoTempo || resumoTempo.meta_diaria_segundos <= 0) return null;
  return Math.min(100, Math.round((resumoTempo.segundos_hoje / resumoTempo.meta_diaria_segundos) * 100));
}

function dataLocal(data: Date): string {
  return `${data.getFullYear()}-${String(data.getMonth() + 1).padStart(2, "0")}-${String(data.getDate()).padStart(2, "0")}`;
}

// historico_tempo_estudo só devolve uma linha por dia que REALMENTE tem
// sessoes_tempo_dias (esparso) — nunca os `diasHistorico` dias inteiros
// zero-preenchidos. O heatmap precisa da malha completa (um quadrado por
// dia do período, mesmo sem estudo) para comunicar visualmente "últimos
// N dias" — isso é só preenchimento de apresentação (dias ausentes
// recebem segundos_liquidos: 0, que é a verdade: não houve estudo nesse
// dia), nunca inventa uma sessão.
function gerarGradeCompleta(dias: number, historico: DiaHistoricoTempo[]): DiaHistoricoTempo[] {
  const porDia = new Map(historico.map((d) => [d.dia, d.segundos_liquidos]));
  const grade: DiaHistoricoTempo[] = [];
  const cursor = new Date();
  cursor.setDate(cursor.getDate() - (dias - 1));
  for (let i = 0; i < dias; i++) {
    const chave = dataLocal(cursor);
    grade.push({ dia: chave, segundos_liquidos: porDia.get(chave) ?? 0 });
    cursor.setDate(cursor.getDate() + 1);
  }
  return grade;
}

// Sequência de dias com TEMPO líquido registrado (sessoes_tempo_dias) —
// deliberadamente separada de qualquer streak pedagógica (que usa
// conclusão de sessoes_estudo, calculada em app/estatisticas/page.tsx).
// As duas podem divergir e é esperado que divirjam; nunca combinadas.
function calcularSequenciaTempo(dias: DiaHistoricoTempo[]): number {
  const comTempo = new Set(dias.filter((d) => d.segundos_liquidos > 0).map((d) => d.dia));
  const cursor = new Date();
  if (!comTempo.has(dataLocal(cursor))) cursor.setDate(cursor.getDate() - 1);
  let sequencia = 0;
  while (comTempo.has(dataLocal(cursor))) {
    sequencia += 1;
    cursor.setDate(cursor.getDate() - 1);
  }
  return sequencia;
}

export type DadosTempoEstudo = {
  carregando: boolean;
  resumoTempo: ResumoTempoEstudo | null;
  percentualMeta: number | null;
  sequenciaTempo: number;
  heatmap: Array<DiaHistoricoTempo & { intensidade: number }>;
  porTipoAtividade: Array<LinhaTipoAtividade & { percentual: number }>;
  /** Soma de segundos_liquidos sobre a janela pedida (diasHistorico) — não é
   *  um total "desde o início" (nenhuma RPC devolve isso hoje), por isso é
   *  sempre exibido junto com diasHistorico, nunca como "total" sem rótulo. */
  totalPeriodoSegundos: number;
  diasHistorico: number;
};

// diasHistorico: janela pedida a historico_tempo_estudo (clamp 1-366 no
// próprio banco) — 30 para o resumo compacto (barato, cobre uma
// sequência razoável), 366 (o máximo permitido) para a página completa,
// que precisa de um "total" e de um heatmap honestos sobre o maior
// período realmente disponível.
export function useDadosTempoEstudo(diasHistorico: number): DadosTempoEstudo {
  const [carregando, setCarregando] = useState(true);
  const [resumoTempo, setResumoTempo] = useState<ResumoTempoEstudo | null>(null);
  const [historicoTempo, setHistoricoTempo] = useState<DiaHistoricoTempo[]>([]);
  const [tempoPorTipoAtividade, setTempoPorTipoAtividade] = useState<LinhaTipoAtividade[]>([]);

  useEffect(() => {
    let ativo = true;
    // Nenhum dos dois callsites atuais (30 em /estatisticas, 366 em
    // /meu-estudo) muda diasHistorico depois do mount, então o efeito só
    // roda uma vez — carregando já começa true via useState acima, sem
    // precisar resetar aqui (evitaria o aviso de lint set-state-in-effect
    // sem motivo real hoje).
    async function carregar() {
      const supabase = createClient();
      const [resumoResultado, historicoResultado, tempoPorTipoResultado] = await Promise.all([
        supabase.rpc("resumo_tempo_estudo"),
        supabase.rpc("historico_tempo_estudo", { p_dias: diasHistorico }),
        supabase.from("sessoes_tempo").select("tipo_atividade, segundos_liquidos"),
      ]);
      if (!ativo) return;

      if (!resumoResultado.error && resumoResultado.data) {
        setResumoTempo(resumoResultado.data as ResumoTempoEstudo);
      }
      if (!historicoResultado.error && historicoResultado.data) {
        setHistoricoTempo(historicoResultado.data as DiaHistoricoTempo[]);
      }
      if (!tempoPorTipoResultado.error && tempoPorTipoResultado.data) {
        const porTipo = new Map<string, number>();
        (tempoPorTipoResultado.data as LinhaTipoAtividade[]).forEach((linha) => {
          porTipo.set(linha.tipo_atividade, (porTipo.get(linha.tipo_atividade) ?? 0) + linha.segundos_liquidos);
        });
        setTempoPorTipoAtividade(
          [...porTipo.entries()].map(([tipo_atividade, segundos_liquidos]) => ({ tipo_atividade, segundos_liquidos })),
        );
      }
      setCarregando(false);
    }
    carregar();

    return () => {
      ativo = false;
    };
  }, [diasHistorico]);

  return useMemo(() => {
    const percentualMeta = calcularPercentualMeta(resumoTempo);
    const maximoDia = Math.max(1, ...historicoTempo.map((d) => d.segundos_liquidos));
    const porTipoOrdenado = [...tempoPorTipoAtividade].sort((a, b) => b.segundos_liquidos - a.segundos_liquidos);
    const totalPorTipo = porTipoOrdenado.reduce((soma, item) => soma + item.segundos_liquidos, 0);
    const totalPeriodoSegundos = historicoTempo.reduce((soma, d) => soma + d.segundos_liquidos, 0);
    return {
      carregando,
      resumoTempo,
      percentualMeta,
      sequenciaTempo: calcularSequenciaTempo(historicoTempo),
      heatmap: gerarGradeCompleta(diasHistorico, historicoTempo).map((d) => ({
        ...d,
        intensidade: d.segundos_liquidos === 0 ? 0 : Math.max(1, Math.ceil((d.segundos_liquidos / maximoDia) * 4)),
      })),
      porTipoAtividade: porTipoOrdenado.map((item) => ({
        ...item,
        percentual: totalPorTipo > 0 ? Math.round((item.segundos_liquidos / totalPorTipo) * 100) : 0,
      })),
      totalPeriodoSegundos,
      diasHistorico,
    };
  }, [carregando, resumoTempo, historicoTempo, tempoPorTipoAtividade, diasHistorico]);
}

export type ResumoTempoHoje = { carregando: boolean; resumoTempo: ResumoTempoEstudo | null; percentualMeta: number | null };

// Versão leve de useDadosTempoEstudo para quem só precisa de
// hoje/meta (ex.: o anel de progresso no card Disponibilidade do
// painel) — chama só resumo_tempo_estudo (mesma RPC, nenhuma nova),
// nunca o historico_tempo_estudo de 366 dias nem a leitura de
// sessoes_tempo que useDadosTempoEstudo também faz. percentualMeta usa
// a MESMA calcularPercentualMeta acima, nunca uma fórmula paralela.
export function useResumoTempoHoje(): ResumoTempoHoje {
  const [carregando, setCarregando] = useState(true);
  const [resumoTempo, setResumoTempo] = useState<ResumoTempoEstudo | null>(null);

  useEffect(() => {
    let ativo = true;
    async function carregar() {
      const { data, error } = await createClient().rpc("resumo_tempo_estudo");
      if (!ativo) return;
      if (!error && data) setResumoTempo(data as ResumoTempoEstudo);
      setCarregando(false);
    }
    carregar();
    return () => {
      ativo = false;
    };
  }, []);

  return { carregando, resumoTempo, percentualMeta: calcularPercentualMeta(resumoTempo) };
}
