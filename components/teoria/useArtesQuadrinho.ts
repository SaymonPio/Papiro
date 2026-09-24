"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { createClient } from "@/utils/supabase/client";
import { interpretarRespostaArtes, podeRenovar, type EstadoRenovacao, type MapaArtes } from "./arteQuadrinho";

// Busca as URLs ASSINADAS (temporárias) das artes aprovadas de UMA aula-versão, chamando a Edge
// `assinar-quadrinho-assets` (bucket privado; service_role só existe lá, nunca aqui).
//
// Estrutura: a lógica vive em `criarControladorArtes` (sem React, testável com timers/relógio/promessas
// simulados); o hook só liga o controlador ao React.
//
// Regras:
//  - UMA chamada por contexto válido (modo + aula-versão + missão). Nada de N+1.
//  - Não bloqueia a renderização: começa vazio (= fallback textual) e só preenche se der certo.
//  - Qualquer falha da Edge (rede, 401/403, payload estranho) mantém o fallback textual e NÃO agenda retry.
//  - RENOVAÇÃO RELATIVA AO RECEBIMENTO: a URL assinada vale 900 s (definido na Edge); renovamos
//    SIGNED_URL_REFRESH_MS (10 min) depois de receber uma resposta com arte. O relógio absoluto do cliente NUNCA
//    decide o atraso (`expira_em` não controla o timer): relógio adiantado/atrasado não muda nada.
//  - No máximo UM timer de renovação por vez; ele é cancelado ao trocar de contexto e ao desmontar.
//  - Cada requisição tem identidade: só a DONA da marca "em voo" a libera; requisição antiga nunca mexe no estado
//    da nova (nem no mapa, nem no timer, nem no "em voo").
//  - Erro de carregamento da imagem: renovação controlada (no máximo 3 por contexto, intervalo mínimo entre elas).
//  - Nunca loga URL/token/resposta.

/** Renova a assinatura 10 min depois de receber uma resposta com arte (TTL da URL = 15 min): folga de ~5 min. */
export const SIGNED_URL_REFRESH_MS = 10 * 60 * 1000;

const MAPA_VAZIO: MapaArtes = Object.freeze({}) as MapaArtes;

export type ContextoArtes = {
  chave: string;
  modo: "admin" | "aluno";
  aulaVersaoId: string;
  missaoId: string | null;
};

export type DepsControladorArtes = {
  /** Chama a Edge para o contexto; deve REJEITAR em qualquer erro. */
  buscar: (contexto: ContextoArtes) => Promise<unknown>;
  aoMudarArtes: (chave: string, mapa: MapaArtes) => void;
  /** Sinaliza só "a consulta INICIAL deste contexto já terminou" — nunca vira `false` de novo por renovação. */
  aoMudarConcluida: (chave: string, concluida: boolean) => void;
  agendar: (fn: () => void, ms: number) => unknown;
  cancelar: (id: unknown) => void;
  agora: () => number;
};

export type ControladorArtes = {
  definirContexto: (contexto: ContextoArtes | null) => void;
  renovarPorErroImagem: () => void;
  destruir: () => void;
};

export function criarControladorArtes(deps: DepsControladorArtes): ControladorArtes {
  let geracao = 0; // muda a cada troca de contexto e ao destruir: invalida tudo o que ficou para trás
  let sequencia = 0; // identidade de cada requisição
  let contexto: ContextoArtes | null = null;
  let emVoo: number | null = null; // id da requisição DONA da marca "em voo"
  let timer: unknown = null;
  let temTimer = false;
  let renovacao: EstadoRenovacao = { tentativas: 0, ultimaEm: null };

  function cancelarTimer() {
    if (temTimer) deps.cancelar(timer);
    timer = null;
    temTimer = false;
  }

  function agendarRenovacao(geracaoDoTimer: number) {
    cancelarTimer(); // no máximo UM timer
    temTimer = true;
    timer = deps.agendar(() => {
      timer = null;
      temTimer = false;
      if (geracaoDoTimer !== geracao) return; // timer de um contexto que já foi trocado/destruído
      void buscar();
    }, SIGNED_URL_REFRESH_MS);
  }

  async function buscar(): Promise<void> {
    if (!contexto || emVoo !== null) return; // sem contexto, ou já há uma chamada em voo: nunca duplica
    const ctx = contexto;
    const minhaGeracao = geracao;
    const meuId = ++sequencia;
    emVoo = meuId;
    try {
      const data = await deps.buscar(ctx);
      if (minhaGeracao !== geracao) return; // contexto mudou/desmontou enquanto esperava
      // 0 = não filtrar por expiração usando o relógio do cliente (a Edge só devolve URL recém-assinada)
      const mapa = interpretarRespostaArtes(data, 0);
      const temArte = Object.keys(mapa).length > 0;
      deps.aoMudarArtes(ctx.chave, temArte ? mapa : MAPA_VAZIO);
      if (temArte) agendarRenovacao(minhaGeracao);
      else cancelarTimer(); // sem arte: nada a renovar, nada de consulta periódica
    } catch {
      // sem arte / falha da Edge: a aula segue só com o texto; sem retry automático
    } finally {
      if (emVoo === meuId) emVoo = null; // só a dona libera a marca (requisição antiga não toca na da nova)
      // "concluída" só se ainda for o contexto atual: resposta de um contexto trocado nunca conclui o novo.
      // Vale para a busca inicial E para renovações (periódica/erro) do MESMO contexto — nesse caso já era
      // true e permanece true (nunca volta a false fora de definirContexto).
      if (minhaGeracao === geracao) deps.aoMudarConcluida(ctx.chave, true);
    }
  }

  return {
    definirContexto(novo) {
      const chaveNova = novo ? novo.chave : null;
      const chaveAtual = contexto ? contexto.chave : null;
      if (chaveNova === chaveAtual) return; // mesmo contexto: nada a fazer (sem chamada duplicada)
      geracao += 1; // invalida requisições e timers do contexto anterior
      cancelarTimer();
      emVoo = null; // a requisição antiga deixa de ser dona; a nova começa limpa
      renovacao = { tentativas: 0, ultimaEm: null };
      contexto = novo;
      deps.aoMudarArtes(chaveNova ?? "", MAPA_VAZIO); // nunca sobra arte do contexto anterior
      deps.aoMudarConcluida(chaveNova ?? "", false); // nova consulta inicial: ainda não concluída
      if (novo) void buscar();
    },

    renovarPorErroImagem() {
      if (!contexto || emVoo !== null) return; // sem contexto ou já renovando: não empilha chamadas
      const agora = deps.agora();
      if (!podeRenovar(renovacao, agora)) return; // limite por contexto + intervalo mínimo (usa só diferenças do relógio)
      renovacao = { tentativas: renovacao.tentativas + 1, ultimaEm: agora };
      void buscar();
    },

    destruir() {
      geracao += 1; // qualquer resposta/timer pendente vira no-op
      cancelarTimer();
      emVoo = null;
      contexto = null;
    },
  };
}

async function buscarNaEdge(ctx: ContextoArtes): Promise<unknown> {
  const corpo = ctx.modo === "aluno"
    ? { modo: ctx.modo, aulaVersaoId: ctx.aulaVersaoId, missaoId: ctx.missaoId }
    : { modo: ctx.modo, aulaVersaoId: ctx.aulaVersaoId };
  const { data, error } = await createClient().functions.invoke("assinar-quadrinho-assets", { body: corpo });
  if (error) throw new Error("edge");
  return data;
}

type Parametros = {
  modo: "admin" | "aluno";
  aulaVersaoId: string | null;
  missaoId?: string | null;
};

export function useArtesQuadrinho({
  modo,
  aulaVersaoId,
  missaoId = null,
}: Parametros): { artes: MapaArtes; aoErroArte: () => void; consultaConcluida: boolean } {
  const habilitado = Boolean(aulaVersaoId) && (modo === "admin" || Boolean(missaoId));
  const chave = habilitado ? `${modo}|${aulaVersaoId}|${modo === "aluno" ? missaoId : ""}` : null;

  const [estado, setEstado] = useState<{ chave: string; mapa: MapaArtes }>({ chave: "", mapa: MAPA_VAZIO });
  // Aditivo à Q12.15: só diz se a consulta INICIAL do contexto atual já terminou (sucesso, vazio ou erro) — nunca
  // um "loading" genérico, e nunca volta a false por renovação periódica/erro de imagem do MESMO contexto.
  const [concluida, setConcluida] = useState<{ chave: string; concluida: boolean }>({ chave: "", concluida: false });
  const controladorRef = useRef<ControladorArtes | null>(null);
  if (controladorRef.current === null) {
    controladorRef.current = criarControladorArtes({
      buscar: buscarNaEdge,
      aoMudarArtes: (c, m) => setEstado({ chave: c, mapa: m }),
      aoMudarConcluida: (c, done) => setConcluida({ chave: c, concluida: done }),
      agendar: (fn, ms) => setTimeout(fn, ms),
      cancelar: (id) => clearTimeout(id as ReturnType<typeof setTimeout>),
      agora: () => Date.now(),
    });
  }
  const controlador = controladorRef.current;

  useEffect(() => {
    controlador.definirContexto(chave && aulaVersaoId ? { chave, modo, aulaVersaoId, missaoId } : null);
  }, [controlador, chave, modo, aulaVersaoId, missaoId]);

  useEffect(() => () => controlador.destruir(), [controlador]);

  const aoErroArte = useCallback(() => controlador.renovarPorErroImagem(), [controlador]);

  // Só entrega a arte do contexto ATUAL: durante uma troca de aula, mesmo por um instante, nunca aparece arte da anterior.
  const artes = chave !== null && estado.chave === chave ? estado.mapa : MAPA_VAZIO;
  const consultaConcluida = chave !== null && concluida.chave === chave ? concluida.concluida : false;
  return { artes, aoErroArte, consultaConcluida };
}
