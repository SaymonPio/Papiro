// Motor de tempo líquido de estudo (Fase 2A) — máquina de estados pura, sem
// React e sem Supabase direto (recebe tudo via `deps`, testável com
// RPCs/timers/relógio simulados). O hook `useSessaoTempo` só liga isto ao
// React; a tela só consome o estado público. Mesma separação de
// responsabilidades de `criarControladorArtes` (components/teoria/
// useArtesQuadrinho.ts) — ver esse arquivo para o padrão geral.
//
// O servidor (supabase/migrations/20261003120000_criar_sessoes_tempo.sql) é
// a ÚNICA fonte de verdade para segundos. Este controlador nunca calcula
// nem envia segundos/timestamps/duração — só chama as RPCs da Fase 1 e
// guarda o último valor que o servidor devolveu.

export type OrigemSessaoTempo = "cronograma" | "estudo_livre" | "questoes" | "estudo_avulso";
export type TipoAtividadeSessaoTempo = "teoria" | "questoes" | "leitura" | "revisao" | "nao_classificado";

export type ContextoSessaoTempo = {
  chave: string;
  origem: OrigemSessaoTempo;
  tipoAtividade: TipoAtividadeSessaoTempo;
  matriculaId: string;
  missaoId: string | null;
  sessaoEstudoId: number | null;
  cursoConteudoId: number | null;
  materiaId: number | null;
  assuntoId: number | null;
  unidadePedagogicaId: string | null;
};

export type SessaoAbertaEncontrada = {
  id: number;
  origem: OrigemSessaoTempo;
  tipoAtividade: TipoAtividadeSessaoTempo;
  matriculaId: string;
  missaoId: string | null;
  segundosLiquidos: number;
  /**
   * Campos adicionais (Horas Líquidas 1.0) — não participam da
   * comparação de "mesmo contexto" em `recuperar` (que já usa só
   * origem/tipoAtividade/matriculaId/missaoId), só existem para a UI de
   * conflito conseguir mostrar contexto real e reconstruir um link de
   * "retomar estudo anterior" sem inventar nada.
   */
  sessaoEstudoId: number | null;
  cursoConteudoId: number | null;
  materiaId: number | null;
  assuntoId: number | null;
  unidadePedagogicaId: string | null;
};

export type DepsControladorSessaoTempo = {
  obterSessaoAberta: () => Promise<SessaoAbertaEncontrada | null>;
  iniciarSessao: (contexto: ContextoSessaoTempo) => Promise<{ id: number; segundosLiquidos: number }>;
  heartbeat: (id: number) => Promise<{ segundosLiquidos: number }>;
  pausar: (id: number) => Promise<{ segundosLiquidos: number }>;
  retomar: (id: number) => Promise<void>;
  encerrar: (id: number) => Promise<{ segundosLiquidos: number }>;
  /** true quando o erro é o conflito explícito 23505 (já existe sessão aberta em outro contexto). */
  ehErroDeConflito: (erro: unknown) => boolean;
  estaVisivel: () => boolean;
  estaFocada: () => boolean;
  agendar: (fn: () => void, ms: number) => unknown;
  cancelar: (id: unknown) => void;
  agora: () => number;
};

export type EstadoSessaoTempo = "ociosa" | "iniciando" | "ativa" | "pausada" | "conflito" | "erro" | "encerrada";

export type EstadoPublicoSessaoTempo = {
  estado: EstadoSessaoTempo;
  /** Uma ação manual (pausar/retomar/encerrar) está em voo — só para desabilitar botões, não muda `estado`. */
  processando: boolean;
  segundosLiquidos: number;
  /** deps.agora() no instante em que `segundosLiquidos` passou a valer — a UI usa isto só para interpolar o contador visual entre heartbeats, nunca para persistir nada. */
  baseLocalEm: number | null;
  erro: string | null;
  /** Só preenchido quando estado === "conflito" — a sessão de outro contexto que está bloqueando o início. */
  conflito: SessaoAbertaEncontrada | null;
  /**
   * id da sessão ativa/pausada/recém-encerrada (null em "ociosa"/"conflito"/
   * antes da primeira resposta do servidor) — Cronômetro Livre precisa
   * disto depois de encerrarEstudo() para classificar a sessão que acabou
   * de terminar (classificar_estudo_avulso exige o id). Nenhum outro fluxo
   * precisava ler isto antes, por isso não existia no estado público.
   */
  sessaoId: number | null;
};

const INTERVALO_HEARTBEAT_MS = 20_000;

export type ControladorSessaoTempo = {
  definirContexto: (contexto: ContextoSessaoTempo | null) => void;
  /**
   * Atualiza SÓ o unidade_pedagogica_id do contexto já definido, sem
   * disparar `recuperar`/cancelar o heartbeat em curso. Existe porque, na
   * missão de teoria, a unidade pedagógica "atual" só fica conhecida depois
   * que a aula termina de carregar — DEPOIS que origem/tipoAtividade/
   * matrícula/missão (o que de fato identifica "mesmo contexto" nesta fase)
   * já estavam estáveis. Tratar unidade_pedagogica_id como parte da chave
   * de `definirContexto` refaria a recuperação a cada vez que o aluno
   * avança de unidade — nunca o que esta fase pede. Só afeta a PRÓXIMA
   * chamada de iniciarEstudo(); nunca uma sessão já ativa (não existe RPC
   * para atualizar o contexto de uma sessão em andamento).
   */
  atualizarUnidadePedagogicaId: (valor: string | null) => void;
  /**
   * Mesmo mecanismo de atualizarUnidadePedagogicaId, agora para
   * sessao_estudo_id (Fase 2C — questões da missão): em /questoes,
   * matricula_id (o que ativa o contexto) fica disponível ANTES de
   * sessao_estudo_id (que só existe depois que a RPC de iniciar questões
   * da missão responde) — tratar os dois como parte da mesma chave faria
   * `definirContexto` repetir a recuperação assim que a sessão de questões
   * terminasse de carregar, sem necessidade.
   */
  atualizarSessaoEstudoId: (valor: number | null) => void;
  iniciarEstudo: () => void;
  pausarEstudo: () => void;
  retomarEstudo: () => void;
  /**
   * Única ação do motor que o chamador pode precisar AGUARDAR (Fase 2C: a
   * transição teoria -> questões precisa confirmar o encerramento antes de
   * navegar, nunca só torcer pelo best-effort de desmontar()). Nunca
   * REJEITA — uma falha na RPC de encerrar vira `estado:"erro"` (tratado
   * como qualquer outro erro do cronômetro) e a promise ainda assim
   * resolve, porque erro de cronômetro nunca pode travar navegação
   * pedagógica. Não é async no sentido de "esperar o estado React
   * atualizar" — resolve assim que a chamada ao servidor terminar (sucesso
   * ou erro já tratado).
   */
  encerrarEstudo: () => Promise<void>;
  /**
   * Horas Líquidas 1.0 — seção "conflito". Encerra a sessão de OUTRO
   * contexto que está bloqueando o início (nunca a atual — não existe
   * uma "atual" ainda, é exatamente por isso que há conflito) e, se
   * tiver sucesso, tenta iniciar a atividade atual imediatamente depois
   * (mesmo contrato de nunca rejeitar de encerrarEstudo — um erro aqui
   * só deixa `erro` preenchido, nunca lança).
   */
  encerrarConflitoEIniciar: () => Promise<void>;
  /** Chamado pelo hook no visibilitychange: aba ficou oculta. */
  aoFicarOculta: () => void;
  /** Chamado pelo hook no visibilitychange: aba voltou a ficar visível. */
  aoFicarVisivel: () => void;
  /**
   * Cronômetro Livre — só a partir de "encerrada": volta para "ociosa"
   * sem navegar/desmontar, para o aluno poder iniciar um NOVO estudo
   * avulso na mesma visita à página (classificar ou fechar sem
   * classificar já persistiu tudo que precisava; esta chamada é só
   * reset de estado local, nenhuma RPC). Nenhum fluxo existente
   * (teoria/questões) precisa disto — ali "encerrada" é sempre seguida
   * de navegação para outra página, nunca de reuso da mesma instância.
   */
  voltarAoInicio: () => void;
  desmontar: () => void;
};

// Decide "mesmo contexto" para sessões SEM missão (toda sessão avulsa —
// meta diária e personalizada). A identidade real de uma execução avulsa
// é a sessão pedagógica (sessoes_estudo), nunca origem/tipoAtividade
// sozinhos (iguais para QUALQUER par de sessões avulsas, já cobertos por
// baseIgual em recuperar()).
function identidadeAvulsaCompativel(aberta: SessaoAbertaEncontrada, ctx: ContextoSessaoTempo): boolean {
  // estudo_avulso (Cronômetro Livre) nunca carrega identidade própria por
  // desenho — matéria/assunto só são preenchidos pela classificação
  // posterior, numa sessão já ENCERRADA, nunca enquanto ela está
  // ativa/pausada. O índice único parcial (sessoes_tempo_usuario_aberta_unq)
  // já garante no banco que só pode existir UMA sessão aberta por usuário,
  // então "aberta.origem === 'estudo_avulso'" só é possível aqui se for
  // exatamente a mesma sessão que este contexto está tentando recuperar
  // (ex.: F5 em /meu-estudo, ou /painel montando o espelho do widget) —
  // nunca duas sessões avulsas distintas competindo. Por isso é sempre
  // compatível, sem cair no fallback de matéria/assunto abaixo (que
  // sempre daria falso aqui, já que os dois lados têm tudo null).
  if (aberta.origem === "estudo_avulso" && ctx.origem === "estudo_avulso") {
    return true;
  }

  // Caminho principal: os dois lados já sabem a que sessão pedagógica
  // pertencem — comparação direta e definitiva.
  if (aberta.sessaoEstudoId !== null && ctx.sessaoEstudoId !== null) {
    return aberta.sessaoEstudoId === ctx.sessaoEstudoId;
  }

  // Fallback: ctx.sessaoEstudoId ainda é null porque a recuperação roda
  // ANTES de iniciar_sessao_questoes_avulsa resolver (é essa RPC que
  // cria o sessaoEstudoId) — acontece em toda primeira tentativa de uma
  // sessão avulsa nova, não é caso raro. Só conta como "mesmo contexto"
  // quando existe um campo realmente identificador E IGUAL dos dois
  // lados (aberta.materiaId !== null): null-contra-null (ex.: meta
  // diária, que nunca tem matéria) NUNCA é tratado como prova de
  // igualdade — isso reintroduziria para meta diária o mesmo bug que
  // esta correção resolve para personalizada. Preferir conflito a
  // reancorar silenciosamente a sessão errada.
  return (
    aberta.materiaId !== null &&
    aberta.materiaId === ctx.materiaId &&
    aberta.assuntoId === ctx.assuntoId &&
    aberta.cursoConteudoId === ctx.cursoConteudoId &&
    aberta.unidadePedagogicaId === ctx.unidadePedagogicaId
  );
}

export function criarControladorSessaoTempo(
  deps: DepsControladorSessaoTempo,
  aoMudarEstado: (estado: EstadoPublicoSessaoTempo) => void,
): ControladorSessaoTempo {
  let geracao = 0; // muda a cada troca de contexto e ao desmontar: invalida respostas/timers do que ficou atrás
  let contexto: ContextoSessaoTempo | null = null;
  let sessaoId: number | null = null;
  let estado: EstadoSessaoTempo = "ociosa";
  let processando = false;
  let segundosLiquidos = 0;
  let baseLocalEm: number | null = null;
  let erro: string | null = null;
  let conflito: SessaoAbertaEncontrada | null = null;
  let heartbeatTimer: unknown = null;
  let temHeartbeatTimer = false;

  function emitir() {
    aoMudarEstado({ estado, processando, segundosLiquidos, baseLocalEm, erro, conflito, sessaoId });
  }

  function cancelarHeartbeat() {
    if (temHeartbeatTimer) deps.cancelar(heartbeatTimer);
    heartbeatTimer = null;
    temHeartbeatTimer = false;
  }

  function marcarSegundos(valor: number) {
    segundosLiquidos = valor;
    baseLocalEm = deps.agora();
  }

  function agendarProximoHeartbeat(minhaGeracao: number) {
    cancelarHeartbeat(); // no máximo UM timer de heartbeat por vez
    temHeartbeatTimer = true;
    heartbeatTimer = deps.agendar(() => {
      heartbeatTimer = null;
      temHeartbeatTimer = false;
      tickHeartbeat(minhaGeracao);
    }, INTERVALO_HEARTBEAT_MS);
  }

  function tickHeartbeat(minhaGeracao: number) {
    if (minhaGeracao !== geracao || estado !== "ativa" || sessaoId === null) return; // contexto/sessão trocou enquanto esperava

    // Visível+focada é condição de ENVIO, não de existência do timer: pula o
    // heartbeat deste ciclo mas continua agendando o próximo normalmente —
    // se ficar oculta por mais de 60s o próprio heartbeat_sessao_tempo (teto
    // no servidor) cuida de não creditar o período, sem o cliente precisar
    // fazer nada especial aqui além de não insistir em mandar heartbeat às
    // escuras.
    if (!(deps.estaVisivel() && deps.estaFocada())) {
      agendarProximoHeartbeat(minhaGeracao);
      return;
    }

    const minhaSessao = sessaoId;
    void deps
      .heartbeat(minhaSessao)
      .then((r) => {
        if (minhaGeracao !== geracao || estado !== "ativa") return; // pausado/encerrado manualmente enquanto o heartbeat estava em voo
        marcarSegundos(r.segundosLiquidos);
        emitir();
        agendarProximoHeartbeat(minhaGeracao);
      })
      .catch((e) => {
        if (minhaGeracao !== geracao) return;
        // Para o heartbeat em erro (não insiste sozinho) — mas nunca impede
        // a leitura/navegação da missão; só o cronômetro fica em erro.
        estado = "erro";
        erro = String(e instanceof Error ? e.message : e);
        emitir();
      });
  }

  function recuperar(minhaGeracao: number) {
    const ctx = contexto;
    if (!ctx) return;
    void deps
      .obterSessaoAberta()
      .then((aberta) => {
        if (minhaGeracao !== geracao) return;

        if (!aberta) {
          estado = "ociosa";
          sessaoId = null;
          conflito = null;
          emitir();
          return;
        }

        // Hotfix (Horas Líquidas 1.0 — conflito de sessão avulsa): origem +
        // tipo_atividade + matrícula + missão identificam o grão correto
        // SÓ quando há missão (cronograma) — ali é a missão inteira que
        // conta, nunca cada unidade pedagógica isoladamente dela (navegar
        // entre unidades da MESMA missão não deve virar conflito nem
        // reiniciar a sessão — ver comentário de app/teoria/page.tsx na
        // chamada deste hook). Sem missão (toda sessão avulsa — meta
        // diária/personalizada), missaoId é SEMPRE null para os dois
        // lados, então parar a comparação aqui tornaria QUALQUER par de
        // sessões avulsas "mesmo contexto" — o bug real de conflito
        // auditado nesta fase. Por isso a identidade avulsa é decidida
        // por identidadeAvulsaCompativel() abaixo.
        const baseIgual =
          aberta.origem === ctx.origem &&
          aberta.tipoAtividade === ctx.tipoAtividade &&
          aberta.matriculaId === ctx.matriculaId &&
          aberta.missaoId === ctx.missaoId;

        const mesmoContexto =
          baseIgual && (ctx.missaoId !== null || identidadeAvulsaCompativel(aberta, ctx));

        if (!mesmoContexto) {
          estado = "conflito";
          sessaoId = null;
          conflito = aberta;
          emitir();
          return;
        }

        conflito = null;
        sessaoId = aberta.id;
        marcarSegundos(aberta.segundosLiquidos);
        executarRetomada(minhaGeracao, aberta.id);
      })
      .catch((e) => {
        if (minhaGeracao !== geracao) return;
        estado = "erro";
        erro = String(e instanceof Error ? e.message : e);
        emitir();
      });
  }

  // Compartilhado por: recuperação no mount, botão Retomar, e retorno de
  // aba oculta — nos três casos o contrato é idêntico (reancorar sem
  // creditar, só então religar o heartbeat). `retomar_sessao_tempo` aceita
  // tanto pausada->ativa quanto ativa->ativa (ver comentário da função no
  // banco) — por isso é seguro chamar mesmo quando o estado local já diz
  // "ativa" (ex.: navegador ficou suspenso em background sem o evento
  // hidden disparar a tempo).
  function executarRetomada(minhaGeracao: number, id: number) {
    // Chamado só com estado já "iniciando" (fluxo de recuperação), "ativa"
    // ou "pausada" (retomarEstudo/aoFicarVisivel) — por isso não precisa
    // forçar nenhuma transição aqui: o que já está em `estado` continua
    // valendo (com `processando=true`) até a resposta chegar.
    processando = true;
    emitir();
    void deps
      .retomar(id)
      .then(() => {
        if (minhaGeracao !== geracao) return;
        estado = "ativa";
        baseLocalEm = deps.agora();
        processando = false;
        emitir();
        agendarProximoHeartbeat(minhaGeracao);
      })
      .catch((e) => {
        if (minhaGeracao !== geracao) return;
        estado = "erro";
        erro = String(e instanceof Error ? e.message : e);
        processando = false;
        emitir();
      });
  }

  function executarPausa(minhaGeracao: number, id: number) {
    cancelarHeartbeat();
    processando = true;
    emitir();
    void deps
      .pausar(id)
      .then((r) => {
        if (minhaGeracao !== geracao) return;
        marcarSegundos(r.segundosLiquidos);
        estado = "pausada";
        processando = false;
        emitir();
      })
      .catch((e) => {
        if (minhaGeracao !== geracao) return;
        estado = "erro";
        erro = String(e instanceof Error ? e.message : e);
        processando = false;
        emitir();
      });
  }

  // Compartilhado por iniciarEstudo() e encerrarConflitoEIniciar() — depois
  // de encerrar a sessão conflitante, tentar iniciar a atual é exatamente a
  // mesma operação que o botão normal de iniciar faz a partir de "ociosa".
  function executarIniciarEstudo(minhaGeracao: number) {
    if (!contexto || estado !== "ociosa") return;
    const ctx = contexto;
    estado = "iniciando";
    emitir();
    void deps
      .iniciarSessao(ctx)
      .then((r) => {
        if (minhaGeracao !== geracao) return;
        sessaoId = r.id;
        marcarSegundos(r.segundosLiquidos);
        estado = "ativa";
        conflito = null;
        emitir();
        agendarProximoHeartbeat(minhaGeracao);
      })
      .catch((e) => {
        if (minhaGeracao !== geracao) return;
        if (!deps.ehErroDeConflito(e)) {
          estado = "erro";
          erro = String(e instanceof Error ? e.message : e);
          emitir();
          return;
        }
        // Conflito explícito (23505): iniciar_sessao_tempo não devolve a
        // sessão conflitante no próprio erro, então busca ela separado só
        // para a UI conseguir mostrar contexto real — nunca inventado.
        estado = "conflito";
        erro = String(e instanceof Error ? e.message : e);
        emitir();
        void deps.obterSessaoAberta().then((aberta) => {
          if (minhaGeracao !== geracao || estado !== "conflito") return;
          conflito = aberta;
          emitir();
        });
      });
  }

  return {
    definirContexto(novo) {
      const chaveNova = novo?.chave ?? null;
      const chaveAtual = contexto?.chave ?? null;
      if (chaveNova === chaveAtual) return; // mesmo contexto: nunca reinicia a verificação

      geracao += 1; // invalida qualquer resposta/timer do contexto anterior
      cancelarHeartbeat();
      contexto = novo;
      sessaoId = null;
      segundosLiquidos = 0;
      baseLocalEm = null;
      erro = null;
      conflito = null;
      processando = false;

      if (!novo) {
        estado = "ociosa";
        emitir();
        return;
      }

      estado = "iniciando";
      emitir();
      recuperar(geracao);
    },

    atualizarUnidadePedagogicaId(valor) {
      if (contexto) contexto = { ...contexto, unidadePedagogicaId: valor };
    },

    atualizarSessaoEstudoId(valor) {
      if (contexto) contexto = { ...contexto, sessaoEstudoId: valor };
    },

    iniciarEstudo() {
      if (!contexto || estado !== "ociosa" || processando) return; // só inicia a partir de ociosa — nunca duplica uma sessão existente
      executarIniciarEstudo(geracao);
    },

    pausarEstudo() {
      if (sessaoId === null || estado !== "ativa" || processando) return;
      executarPausa(geracao, sessaoId);
    },

    retomarEstudo() {
      if (sessaoId === null || estado !== "pausada" || processando) return;
      executarRetomada(geracao, sessaoId);
    },

    encerrarEstudo() {
      // Nada para encerrar (já ociosa/encerrada/conflito/erro, ou uma ação
      // já em voo): resolve na hora — o chamador (ex.: concluirUnidade em
      // app/teoria/page.tsx) nunca deve ficar bloqueado esperando algo que
      // não vai acontecer.
      if (sessaoId === null || (estado !== "ativa" && estado !== "pausada") || processando) {
        return Promise.resolve();
      }
      cancelarHeartbeat();
      const id = sessaoId;
      const minhaGeracao = geracao;
      processando = true;
      emitir();
      return deps
        .encerrar(id)
        .then((r) => {
          if (minhaGeracao !== geracao) return;
          marcarSegundos(r.segundosLiquidos);
          estado = "encerrada";
          processando = false;
          emitir();
        })
        .catch((e) => {
          if (minhaGeracao !== geracao) return;
          // Erro tratado aqui (nunca propagado): o cronômetro mostra
          // "erro", mas a promise ainda resolve — uma falha de RPC de tempo
          // nunca pode travar a navegação pedagógica de quem chamou isto.
          estado = "erro";
          erro = String(e instanceof Error ? e.message : e);
          processando = false;
          emitir();
        });
    },

    encerrarConflitoEIniciar() {
      if (estado !== "conflito" || !conflito || processando) return Promise.resolve();
      const idConflitante = conflito.id;
      const minhaGeracao = geracao;
      processando = true;
      emitir();
      return deps
        .encerrar(idConflitante)
        .then(() => {
          if (minhaGeracao !== geracao) return;
          processando = false;
          estado = "ociosa";
          conflito = null;
          erro = null;
          emitir();
          executarIniciarEstudo(minhaGeracao);
        })
        .catch((e) => {
          if (minhaGeracao !== geracao) return;
          // Não resolveu o conflito: permanece em "conflito" (não "erro")
          // para a UI continuar oferecendo as mesmas duas ações, só que
          // agora também com uma mensagem de erro visível.
          erro = String(e instanceof Error ? e.message : e);
          processando = false;
          emitir();
        });
    },

    aoFicarOculta() {
      // Mesma condição do botão Pausar (só faz sentido partindo de 'ativa');
      // best-effort — se a aba for descartada antes da resposta chegar, o
      // próximo retomar_sessao_tempo (ver aoFicarVisivel/recuperação) é quem
      // garante a integridade, nunca este caminho.
      if (sessaoId === null || estado !== "ativa" || processando) return;
      executarPausa(geracao, sessaoId);
    },

    voltarAoInicio() {
      if (estado !== "encerrada") return;
      geracao += 1; // invalida qualquer timer/resposta pendente da sessão que acabou de encerrar
      sessaoId = null;
      segundosLiquidos = 0;
      baseLocalEm = null;
      erro = null;
      conflito = null;
      processando = false;
      estado = "ociosa";
      emitir();
    },

    aoFicarVisivel() {
      // Ignorado durante uma ação manual em voo (ex.: o próprio aoFicarOculta
      // ainda não respondeu) — ver comentário em executarRetomada/executarPausa
      // sobre essa janela de corrida ser aceitável (nunca credita tempo
      // indevido; na pior hipótese o aluno precisa clicar Retomar).
      if (sessaoId === null || processando) return;
      if (estado !== "ativa" && estado !== "pausada") return;
      // Nunca manda heartbeat direto aqui — sempre reancora primeiro, mesmo
      // se o estado local já disser 'ativa' (ver comentário de
      // executarRetomada: cobre o navegador suspenso em background).
      executarRetomada(geracao, sessaoId);
    },

    desmontar() {
      geracao += 1;
      cancelarHeartbeat();
      // Best-effort: tenta creditar o tempo até agora antes de desmontar.
      // Fire-and-forget de propósito (cleanup do React é síncrono, não dá
      // pra aguardar) — se falhar ou não chegar a tempo (ex.: navegação de
      // página inteira via window.location.assign), a próxima recuperação
      // desta sessão reancora normalmente sem creditar o período perdido.
      if (sessaoId !== null && estado === "ativa") {
        void deps.pausar(sessaoId).catch(() => {});
      }
      contexto = null;
      sessaoId = null;
    },
  };
}
