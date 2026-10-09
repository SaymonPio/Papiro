"use client";

import { useEffect, useMemo, useRef, useState } from "react";
import { createClient } from "@/utils/supabase/client";
import { montarLinkMissao, montarLinkTeoria } from "@/utils/missao-cronograma.mjs";
import {
  criarControladorSessaoTempo,
  type ContextoSessaoTempo,
  type ControladorSessaoTempo,
  type DepsControladorSessaoTempo,
  type EstadoPublicoSessaoTempo,
  type OrigemSessaoTempo,
  type SessaoAbertaEncontrada,
  type TipoAtividadeSessaoTempo,
} from "./sessaoTempoControlador";

// Hook React do motor de tempo líquido de estudo (Fase 2A). Só fala com o
// Supabase e com o DOM (visibilitychange, relógio) — toda a lógica de
// estados/transições vive em sessaoTempoControlador.ts (sem React), igual
// ao padrão já usado em components/teoria/useArtesQuadrinho.ts.
//
// O servidor é a única fonte de verdade para segundos: nunca envie segundos
// calculados, timestamps ou duração nas chamadas abaixo — só o id da
// sessão. `segundosLiquidos` devolvido por este hook já é interpolado
// localmente só para a UI parecer contínua entre heartbeats.

export type ParametrosSessaoTempo = {
  origem: OrigemSessaoTempo;
  tipoAtividade: TipoAtividadeSessaoTempo;
  /** Obrigatório para operar; `null` enquanto a matrícula ainda não foi resolvida mantém o hook ocioso (não chama nenhuma RPC). */
  matriculaId: string | null;
  missaoId?: string | null;
  sessaoEstudoId?: number | null;
  cursoConteudoId?: number | null;
  materiaId?: number | null;
  assuntoId?: number | null;
  unidadePedagogicaId?: string | null;
};

/** Contexto da sessão que está bloqueando o início (estado === "conflito"), já com o link pronto para "Retomar estudo anterior" quando reconstruível. */
export type ConflitoSessaoTempo = {
  origem: OrigemSessaoTempo;
  tipoAtividade: TipoAtividadeSessaoTempo;
  segundosLiquidos: number;
  /** null quando o contexto disponível não é suficiente para montar um link seguro (ex.: tipoAtividade ainda sem tela própria, como "leitura"/"revisao"). */
  linkRetomada: string | null;
};

export type UseSessaoTempoResultado = {
  estado: EstadoPublicoSessaoTempo["estado"];
  processando: boolean;
  segundosLiquidos: number;
  erro: string | null;
  conflito: ConflitoSessaoTempo | null;
  iniciarEstudo: () => void;
  pausarEstudo: () => void;
  retomarEstudo: () => void;
  /** Awaitable (nunca rejeita) — ver comentário em ControladorSessaoTempo.encerrarEstudo. */
  encerrarEstudo: () => Promise<void>;
  /** Encerra a sessão conflitante (nunca a atual) e, se der certo, já tenta iniciar a atividade atual — mesmo contrato de nunca rejeitar. */
  encerrarConflitoEIniciar: () => Promise<void>;
  /** id da sessão ativa/pausada/recém-encerrada — null fora desses estados. Ver comentário em EstadoPublicoSessaoTempo.sessaoId. */
  sessaoId: number | null;
  /** Cronômetro Livre: reseta de "encerrada" para "ociosa" sem navegar. No-op em qualquer outro estado. */
  voltarAoInicio: () => void;
};

const ESTADO_INICIAL: EstadoPublicoSessaoTempo = {
  estado: "ociosa",
  processando: false,
  segundosLiquidos: 0,
  baseLocalEm: null,
  erro: null,
  conflito: null,
  sessaoId: null,
};

// Reconstrói para onde "Retomar estudo anterior" deve levar, a partir só
// do contexto já persistido em sessoes_tempo — nunca inventa parâmetro
// ausente. Reaproveita montarLinkMissao/montarLinkTeoria (utils/missao-
// cronograma.mjs), as mesmas funções que já montam esses links no fluxo
// normal, em vez de duplicar a lógica de querystring.
function construirLinkRetomada(c: SessaoAbertaEncontrada): string | null {
  // Cronômetro Livre não tem tela própria por conteúdo (não tem
  // materiaId/missaoId para montar um link específico) — mas tem uma
  // única tela possível, /meu-estudo (aba "Cronômetro livre"), que
  // nunca precisa de nenhum parâmetro para recuperar a sessão (a
  // recuperação lê do servidor, não da URL).
  if (c.origem === "estudo_avulso") {
    return "/meu-estudo";
  }
  if (c.tipoAtividade === "questoes" && !c.missaoId && c.sessaoEstudoId !== null) {
    return `/questoes?sessaoAvulsa=${c.sessaoEstudoId}`;
  }
  if (!c.materiaId || !c.missaoId) return null;
  if (c.tipoAtividade === "teoria") {
    return montarLinkTeoria({
      cursoMateriaId: undefined,
      materiaId: c.materiaId,
      assuntoId: c.assuntoId ?? undefined,
      conteudoId: c.cursoConteudoId ?? undefined,
      missionId: c.missaoId,
    });
  }
  if (c.tipoAtividade === "questoes") {
    return montarLinkMissao({
      cursoMateriaId: undefined,
      materiaId: c.materiaId,
      assuntoId: c.assuntoId ?? undefined,
      conteudoId: c.cursoConteudoId ?? undefined,
      missionId: c.missaoId,
      unidadePedagogicaId: c.unidadePedagogicaId ?? undefined,
    });
  }
  // "leitura"/"revisao": ainda não têm tela própria no projeto — sem link seguro possível hoje.
  return null;
}

class ErroConflitoSessaoTempo extends Error {}

type ErroSupabaseRpc = { message: string; code?: string; details?: string | null; hint?: string | null };

function logFalha(operacao: string, error: ErroSupabaseRpc) {
  console.error(`[useSessaoTempo] Falha em ${operacao}:`, {
    message: error.message,
    code: error.code,
    details: error.details,
    hint: error.hint,
  });
}

type ClienteSupabase = ReturnType<typeof createClient>;

type RowObterAberta = {
  id: number;
  origem: string;
  tipo_atividade: string;
  matricula_id: string;
  missao_id: string | null;
  segundos_liquidos: number;
  sessao_estudo_id: number | null;
  curso_conteudo_id: number | null;
  materia_id: number | null;
  assunto_id: number | null;
  unidade_pedagogica_id: string | null;
};

type RowIniciar = { id: number; segundos_liquidos: number };
type RowComSegundos = { segundos_liquidos: number };

function criarDeps(supabase: ClienteSupabase): Omit<DepsControladorSessaoTempo, "estaVisivel" | "estaFocada" | "agendar" | "cancelar" | "agora"> {
  return {
    async obterSessaoAberta(): Promise<SessaoAbertaEncontrada | null> {
      const { data, error } = await supabase.rpc("obter_sessao_tempo_aberta");
      if (error) {
        logFalha("obter_sessao_tempo_aberta", error);
        throw new Error("Nao foi possivel verificar o cronometro de estudo.");
      }
      const linha = ((data as RowObterAberta[] | null) ?? [])[0];
      if (!linha) return null;
      return {
        id: linha.id,
        origem: linha.origem as OrigemSessaoTempo,
        tipoAtividade: linha.tipo_atividade as TipoAtividadeSessaoTempo,
        matriculaId: linha.matricula_id,
        missaoId: linha.missao_id,
        segundosLiquidos: linha.segundos_liquidos,
        sessaoEstudoId: linha.sessao_estudo_id,
        cursoConteudoId: linha.curso_conteudo_id,
        materiaId: linha.materia_id,
        assuntoId: linha.assunto_id,
        unidadePedagogicaId: linha.unidade_pedagogica_id,
      };
    },

    async iniciarSessao(contexto: ContextoSessaoTempo) {
      const { data, error } = await supabase.rpc("iniciar_sessao_tempo", {
        p_origem: contexto.origem,
        p_matricula_id: contexto.matriculaId,
        p_tipo_atividade: contexto.tipoAtividade,
        p_missao_id: contexto.missaoId,
        p_sessao_estudo_id: contexto.sessaoEstudoId,
        p_curso_conteudo_id: contexto.cursoConteudoId,
        p_materia_id: contexto.materiaId,
        p_assunto_id: contexto.assuntoId,
        p_unidade_pedagogica_id: contexto.unidadePedagogicaId,
      });
      if (error) {
        logFalha("iniciar_sessao_tempo", error);
        if (error.code === "23505") {
          throw new ErroConflitoSessaoTempo("Ja existe um estudo em andamento em outro contexto.");
        }
        throw new Error("Nao foi possivel iniciar o cronometro de estudo.");
      }
      const linha = ((data as RowIniciar[] | null) ?? [])[0];
      if (!linha) throw new Error("Nao foi possivel iniciar o cronometro de estudo.");
      return { id: linha.id, segundosLiquidos: linha.segundos_liquidos };
    },

    async heartbeat(id: number) {
      const { data, error } = await supabase.rpc("heartbeat_sessao_tempo", { p_sessao_tempo_id: id });
      if (error) {
        logFalha("heartbeat_sessao_tempo", error);
        throw new Error("Falha no heartbeat do cronometro de estudo.");
      }
      const linha = ((data as RowComSegundos[] | null) ?? [])[0];
      if (!linha) throw new Error("Falha no heartbeat do cronometro de estudo.");
      return { segundosLiquidos: linha.segundos_liquidos };
    },

    async pausar(id: number) {
      const { data, error } = await supabase.rpc("pausar_sessao_tempo", { p_sessao_tempo_id: id });
      if (error) {
        logFalha("pausar_sessao_tempo", error);
        throw new Error("Nao foi possivel pausar o cronometro de estudo.");
      }
      const linha = ((data as RowComSegundos[] | null) ?? [])[0];
      if (!linha) throw new Error("Nao foi possivel pausar o cronometro de estudo.");
      return { segundosLiquidos: linha.segundos_liquidos };
    },

    async retomar(id: number) {
      const { error } = await supabase.rpc("retomar_sessao_tempo", { p_sessao_tempo_id: id });
      if (error) {
        logFalha("retomar_sessao_tempo", error);
        throw new Error("Nao foi possivel retomar o cronometro de estudo.");
      }
    },

    async encerrar(id: number) {
      const { data, error } = await supabase.rpc("encerrar_sessao_tempo", { p_sessao_tempo_id: id });
      if (error) {
        logFalha("encerrar_sessao_tempo", error);
        throw new Error("Nao foi possivel encerrar o cronometro de estudo.");
      }
      const linha = ((data as RowComSegundos[] | null) ?? [])[0];
      if (!linha) throw new Error("Nao foi possivel encerrar o cronometro de estudo.");
      return { segundosLiquidos: linha.segundos_liquidos };
    },

    ehErroDeConflito(e: unknown) {
      return e instanceof ErroConflitoSessaoTempo;
    },
  };
}

/**
 * Fase 2C — defesa específica da transição teoria -> questões da mesma
 * missão. app/teoria/page.tsx já aguarda encerrarEstudo() antes de
 * navegar (ver concluirUnidade), então no caminho normal isto não
 * encontra nada para fazer. Existe para o caminho NÃO normal: se esse
 * encerramento falhou, ou o aluno chegou em /questoes sem passar por lá
 * (ex.: back/forward do navegador, link direto), ainda pode haver uma
 * sessão de TEORIA aberta desta MESMA missão quando /questoes monta — sem
 * isto, o hook de questões (tipoAtividade="questoes") veria essa sessão
 * de teoria como "mesmo contexto"? NÃO: tipoAtividade diferente já é
 * conflito por definição (ver recuperar() em sessaoTempoControlador.ts e
 * o conflito explícito 23505 em iniciar_sessao_tempo) — sem este
 * pre-flight, o aluno veria "conflito" na tela de questões por causa de
 * uma teoria esquecida, em vez de seguir normalmente.
 *
 * Só age quando a sessão aberta é de teoria da MESMA missão — qualquer
 * outro caso (sessão de outra missão, já é de questões, ou não há
 * nenhuma) é deixado para o fluxo padrão do hook resolver (recuperação
 * normal ou "conflito"), nunca aqui. Nunca lança: na pior hipótese, não
 * faz nada e o fluxo padrão segue (podendo mostrar "conflito").
 */
export async function encerrarTeoriaAbertaDaMissao(missaoId: string): Promise<void> {
  const supabase = createClient();
  try {
    const { data, error } = await supabase.rpc("obter_sessao_tempo_aberta");
    if (error) {
      logFalha("obter_sessao_tempo_aberta (pre-flight questoes)", error);
      return;
    }
    const linha = ((data as RowObterAberta[] | null) ?? [])[0];
    if (!linha || linha.missao_id !== missaoId || linha.tipo_atividade !== "teoria") return;

    const { error: erroEncerrar } = await supabase.rpc("encerrar_sessao_tempo", {
      p_sessao_tempo_id: linha.id,
    });
    if (erroEncerrar) logFalha("encerrar_sessao_tempo (pre-flight questoes)", erroEncerrar);
  } catch (e) {
    console.error("[useSessaoTempo] Falha no pre-flight teoria->questoes:", e);
  }
}

export function useSessaoTempo(parametros: ParametrosSessaoTempo): UseSessaoTempoResultado {
  const {
    origem,
    tipoAtividade,
    matriculaId,
    missaoId = null,
    sessaoEstudoId = null,
    cursoConteudoId = null,
    materiaId = null,
    assuntoId = null,
    unidadePedagogicaId = null,
  } = parametros;

  const [estadoPublico, setEstadoPublico] = useState<EstadoPublicoSessaoTempo>(ESTADO_INICIAL);

  const supabaseRef = useRef<ClienteSupabase | null>(null);
  if (!supabaseRef.current) supabaseRef.current = createClient();

  const controladorRef = useRef<ControladorSessaoTempo | null>(null);
  if (!controladorRef.current) {
    const depsBase = criarDeps(supabaseRef.current);
    const deps: DepsControladorSessaoTempo = {
      ...depsBase,
      estaVisivel: () => document.visibilityState === "visible",
      estaFocada: () => document.hasFocus(),
      agendar: (fn, ms) => setTimeout(fn, ms),
      cancelar: (id) => clearTimeout(id as ReturnType<typeof setTimeout>),
      agora: () => Date.now(),
    };
    controladorRef.current = criarControladorSessaoTempo(deps, setEstadoPublico);
  }
  const controlador = controladorRef.current;

  // unidade_pedagogica_id E sessao_estudo_id ficam DE FORA desta chave de
  // propósito — ver comentário de `atualizarUnidadePedagogicaId`/
  // `atualizarSessaoEstudoId` no controlador. O que identifica "mesmo
  // contexto" nesta fase é origem/tipoAtividade/matrícula/missão/
  // conteúdo/matéria/assunto.
  const chave = matriculaId
    ? [
        origem,
        tipoAtividade,
        matriculaId,
        missaoId ?? "",
        cursoConteudoId ?? "",
        materiaId ?? "",
        assuntoId ?? "",
      ].join("|")
    : null;

  useEffect(() => {
    controlador.definirContexto(
      chave && matriculaId
        ? {
            chave,
            origem,
            tipoAtividade,
            matriculaId,
            missaoId,
            sessaoEstudoId,
            cursoConteudoId,
            materiaId,
            assuntoId,
            unidadePedagogicaId,
          }
        : null,
    );
    // chave já deriva dos campos individuais relevantes — eles não precisam repetir na lista de dependências.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [controlador, chave]);

  // Mantém unidade_pedagogica_id/sessao_estudo_id sincronizados sem refazer
  // a recuperação/heartbeat (ver comentário de atualizarUnidadePedagogicaId/
  // atualizarSessaoEstudoId no controlador).
  useEffect(() => {
    controlador.atualizarUnidadePedagogicaId(unidadePedagogicaId);
  }, [controlador, unidadePedagogicaId]);

  useEffect(() => {
    controlador.atualizarSessaoEstudoId(sessaoEstudoId);
  }, [controlador, sessaoEstudoId]);

  useEffect(() => () => controlador.desmontar(), [controlador]);

  useEffect(() => {
    function aoMudarVisibilidade() {
      if (document.visibilityState === "hidden") controlador.aoFicarOculta();
      else controlador.aoFicarVisivel();
    }
    document.addEventListener("visibilitychange", aoMudarVisibilidade);
    return () => document.removeEventListener("visibilitychange", aoMudarVisibilidade);
  }, [controlador]);

  // Contador visual: só interpola a exibição entre heartbeats (1x/s) — nunca
  // persiste nada nem é lido por nenhuma chamada ao Supabase.
  const [agoraLocal, setAgoraLocal] = useState(() => Date.now());
  useEffect(() => {
    if (estadoPublico.estado !== "ativa") return;
    const id = setInterval(() => setAgoraLocal(Date.now()), 1000);
    return () => clearInterval(id);
  }, [estadoPublico.estado]);

  const ultimoExibidoRef = useRef(0);
  const segundosExibidos = useMemo(() => {
    let valor = estadoPublico.segundosLiquidos;
    if (estadoPublico.estado === "ativa" && estadoPublico.baseLocalEm !== null) {
      valor = estadoPublico.segundosLiquidos + Math.max(0, Math.floor((agoraLocal - estadoPublico.baseLocalEm) / 1000));
    }
    if (estadoPublico.estado === "ativa" || estadoPublico.estado === "pausada") {
      // Nunca exibe menos do que já foi mostrado enquanto a sessão continua ativa/pausada — diferenças de
      // arredondamento entre o relógio local e o floor() do servidor não devem parecer "perder tempo" na tela.
      valor = Math.max(valor, ultimoExibidoRef.current);
    }
    ultimoExibidoRef.current = valor;
    return valor;
  }, [estadoPublico.estado, estadoPublico.baseLocalEm, estadoPublico.segundosLiquidos, agoraLocal]);

  const conflito = useMemo<ConflitoSessaoTempo | null>(() => {
    if (!estadoPublico.conflito) return null;
    const c = estadoPublico.conflito;
    return {
      origem: c.origem,
      tipoAtividade: c.tipoAtividade,
      segundosLiquidos: c.segundosLiquidos,
      linkRetomada: construirLinkRetomada(c),
    };
  }, [estadoPublico.conflito]);

  // Único método acrescentado nesta fase (Cronômetro Livre) ao objeto
  // devolvido pelo hook: em vez de ler `controlador.voltarAoInicio`
  // diretamente no corpo do return (que leria `controladorRef.current`
  // durante a renderização — mesmo padrão pré-existente já usado por
  // iniciarEstudo/pausarEstudo/etc. acima, intocado nesta rodada), esta
  // função só acessa o ref dentro do próprio corpo, quando efetivamente
  // CHAMADA por quem a invoca (sempre um clique/efeito, nunca durante o
  // render) — exatamente o padrão de "handler" que a regra
  // react-hooks/refs recomenda.
  function voltarAoInicio() {
    controladorRef.current?.voltarAoInicio();
  }

  return {
    estado: estadoPublico.estado,
    processando: estadoPublico.processando,
    segundosLiquidos: segundosExibidos,
    erro: estadoPublico.erro,
    conflito,
    iniciarEstudo: controlador.iniciarEstudo,
    pausarEstudo: controlador.pausarEstudo,
    retomarEstudo: controlador.retomarEstudo,
    encerrarEstudo: controlador.encerrarEstudo,
    encerrarConflitoEIniciar: controlador.encerrarConflitoEIniciar,
    sessaoId: estadoPublico.sessaoId,
    voltarAoInicio,
  };
}
