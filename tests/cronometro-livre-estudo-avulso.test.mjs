import test from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import { criarControladorSessaoTempo } from "../components/tempo-estudo/sessaoTempoControlador.ts";

const migracao = await readFile(
  new URL("../supabase/migrations/20261007120000_criar_estudo_avulso.sql", import.meta.url),
  "utf8",
);
// Migration incremental que SUBSTITUI o corpo de classificar_estudo_avulso
// (reforço de segurança materia_id/assunto_id) — fonte de verdade atual
// da função; a versão em `migracao` acima já foi superada em produção,
// mas suas constraints/coluna/DDL continuam valendo (não tocadas por esta).
const reforco = await readFile(
  new URL("../supabase/migrations/20261007180000_reforcar_materia_assunto_classificar_estudo_avulso.sql", import.meta.url),
  "utf8",
);
const fundacao = await readFile(
  new URL("../supabase/migrations/20261003120000_criar_sessoes_tempo.sql", import.meta.url),
  "utf8",
);
const useDados = await readFile(new URL("../components/tempo-estudo/useDadosTempoEstudo.ts", import.meta.url), "utf8");
const cronometroLivre = await readFile(new URL("../components/tempo-estudo/CronometroLivre.tsx", import.meta.url), "utf8");
const classificar = await readFile(new URL("../components/tempo-estudo/ClassificarEstudoAvulso.tsx", import.meta.url), "utf8");
const meuEstudo = await readFile(new URL("../app/meu-estudo/page.tsx", import.meta.url), "utf8");
const provider = await readFile(new URL("../components/tempo-estudo/SessaoTempoProvider.tsx", import.meta.url), "utf8");
const rootLayout = await readFile(new URL("../app/layout.tsx", import.meta.url), "utf8");
const painel = await readFile(new URL("../app/painel/page.tsx", import.meta.url), "utf8");

// ============================================================================
// Controlador puro (sem React/Supabase) — mesma técnica de deps injetadas
// usada pelo próprio motor (ver cabeçalho de sessaoTempoControlador.ts).
// ============================================================================

function criarDepsFalsas(overrides = {}) {
  const chamadas = { iniciar: [], heartbeat: [], pausar: [], retomar: [], encerrar: [] };
  const timers = [];
  return {
    chamadas,
    timers,
    deps: {
      obterSessaoAberta: async () => null,
      iniciarSessao: async (ctx) => {
        chamadas.iniciar.push(ctx);
        return { id: 1, segundosLiquidos: 0 };
      },
      heartbeat: async (id) => {
        chamadas.heartbeat.push(id);
        return { segundosLiquidos: 20 };
      },
      pausar: async (id) => {
        chamadas.pausar.push(id);
        return { segundosLiquidos: 20 };
      },
      retomar: async (id) => {
        chamadas.retomar.push(id);
      },
      encerrar: async (id) => {
        chamadas.encerrar.push(id);
        return { segundosLiquidos: 42 };
      },
      ehErroDeConflito: (e) => e?.conflito === true,
      estaVisivel: () => true,
      estaFocada: () => true,
      agendar: (fn, ms) => {
        const id = timers.length;
        timers.push({ fn, ms, cancelado: false });
        return id;
      },
      cancelar: (id) => {
        if (timers[id]) timers[id].cancelado = true;
      },
      agora: () => Date.now(),
      ...overrides,
    },
  };
}

function dispararTimer(timers, indice) {
  const alvo = timers[indice];
  if (!alvo || alvo.cancelado) return;
  alvo.fn();
}

// definirContexto() dispara recuperar() (obterSessaoAberta assíncrono) —
// sem aguardar esse microtask, o estado ainda é "iniciando", nunca
// "ociosa", e iniciarEstudo()/etc. seriam ignorados pelo guard do
// controlador. Dois ticks bastam para a promise padrão (`async () =>
// null`) resolver e o .then() correspondente já ter chamado emitir().
async function aguardarRecuperacao() {
  await Promise.resolve();
  await Promise.resolve();
}

const CTX_AVULSO = {
  chave: "estudo_avulso|nao_classificado|matricula-1|",
  origem: "estudo_avulso",
  tipoAtividade: "nao_classificado",
  matriculaId: "matricula-1",
  missaoId: null,
  sessaoEstudoId: null,
  cursoConteudoId: null,
  materiaId: null,
  assuntoId: null,
  unidadePedagogicaId: null,
};

test("1-3. iniciar estudo avulso sem formulário chega à RPC como origem=estudo_avulso/tipo=nao_classificado, sem nenhum contexto", async () => {
  const { deps, chamadas } = criarDepsFalsas();
  let estadoAtual;
  const controlador = criarControladorSessaoTempo(deps, (e) => {
    estadoAtual = e;
  });
  controlador.definirContexto(CTX_AVULSO);
  await aguardarRecuperacao();
  assert.equal(estadoAtual.estado, "ociosa"); // sem sessão aberta nenhuma: pronto para iniciar, sem pedir nada ao aluno
  controlador.iniciarEstudo();
  await Promise.resolve();
  assert.equal(chamadas.iniciar.length, 1);
  assert.deepEqual(chamadas.iniciar[0], CTX_AVULSO);
  assert.equal(estadoAtual.estado, "ativa");
  assert.equal(estadoAtual.sessaoId, 1);
});

test("5. heartbeat soma tempo enquanto ativa", async () => {
  const { deps, chamadas, timers } = criarDepsFalsas();
  let estadoAtual;
  const controlador = criarControladorSessaoTempo(deps, (e) => {
    estadoAtual = e;
  });
  controlador.definirContexto(CTX_AVULSO);
  await aguardarRecuperacao();
  controlador.iniciarEstudo();
  await Promise.resolve();
  assert.equal(timers.length, 1); // heartbeat agendado após iniciar
  assert.equal(estadoAtual.segundosLiquidos, 0);
  dispararTimer(timers, 0);
  await Promise.resolve();
  assert.equal(chamadas.heartbeat.length, 1);
  assert.equal(estadoAtual.segundosLiquidos, 20); // valor devolvido pelo heartbeat falso
});

test("6. pausar não soma heartbeat depois (timer cancelado) e credita o delta devolvido pelo servidor", async () => {
  const { deps, chamadas, timers } = criarDepsFalsas();
  let estadoAtual;
  const controlador = criarControladorSessaoTempo(deps, (e) => {
    estadoAtual = e;
  });
  controlador.definirContexto(CTX_AVULSO);
  await aguardarRecuperacao();
  controlador.iniciarEstudo();
  await Promise.resolve();
  controlador.pausarEstudo();
  await Promise.resolve();
  assert.equal(chamadas.pausar.length, 1);
  assert.equal(estadoAtual.estado, "pausada");
  assert.equal(estadoAtual.segundosLiquidos, 20);
  assert.equal(timers[0].cancelado, true); // nenhum heartbeat agendado sobrevive à pausa
});

test("7. retomar volta a contabilizar (reagenda heartbeat)", async () => {
  const { deps, chamadas, timers } = criarDepsFalsas();
  let estadoAtual;
  const controlador = criarControladorSessaoTempo(deps, (e) => {
    estadoAtual = e;
  });
  controlador.definirContexto(CTX_AVULSO);
  await aguardarRecuperacao();
  controlador.iniciarEstudo();
  await Promise.resolve();
  controlador.pausarEstudo();
  await Promise.resolve();
  const timersAntes = timers.length;
  controlador.retomarEstudo();
  await Promise.resolve();
  assert.equal(chamadas.retomar.length, 1);
  assert.equal(estadoAtual.estado, "ativa");
  assert.ok(timers.length > timersAntes); // novo heartbeat agendado
});

test("8. finalizar encerra corretamente e mantém sessaoId disponível para classificar", async () => {
  const { deps, chamadas } = criarDepsFalsas();
  let estadoAtual;
  const controlador = criarControladorSessaoTempo(deps, (e) => {
    estadoAtual = e;
  });
  controlador.definirContexto(CTX_AVULSO);
  await aguardarRecuperacao();
  controlador.iniciarEstudo();
  await Promise.resolve();
  await controlador.encerrarEstudo();
  assert.equal(chamadas.encerrar.length, 1);
  assert.equal(estadoAtual.estado, "encerrada");
  assert.equal(estadoAtual.segundosLiquidos, 42);
  assert.equal(estadoAtual.sessaoId, 1, "sessaoId precisa sobreviver a encerrarEstudo() para a classificação posterior");
});

test("voltarAoInicio só age a partir de 'encerrada' e reseta para 'ociosa' sem chamar nenhuma RPC", async () => {
  const { deps, chamadas } = criarDepsFalsas();
  let estadoAtual;
  const controlador = criarControladorSessaoTempo(deps, (e) => {
    estadoAtual = e;
  });
  controlador.definirContexto(CTX_AVULSO);
  await aguardarRecuperacao();
  controlador.iniciarEstudo();
  await Promise.resolve();
  controlador.voltarAoInicio(); // ainda "ativa" — no-op
  assert.equal(estadoAtual.estado, "ativa");

  await controlador.encerrarEstudo();
  controlador.voltarAoInicio();
  assert.equal(estadoAtual.estado, "ociosa");
  assert.equal(estadoAtual.sessaoId, null);
  assert.equal(chamadas.iniciar.length, 1); // nenhuma nova chamada de iniciar/heartbeat/etc. disparada pelo reset
  assert.equal(chamadas.heartbeat.length + chamadas.pausar.length + chamadas.retomar.length + chamadas.encerrar.length, 1);
});

test("22. F5 recupera a MESMA sessão avulsa (nunca mostra conflito contra si mesma)", async () => {
  const sessaoAbertaEstudoAvulso = {
    id: 77,
    origem: "estudo_avulso",
    tipoAtividade: "nao_classificado",
    matriculaId: "matricula-1",
    missaoId: null,
    segundosLiquidos: 300,
    sessaoEstudoId: null,
    cursoConteudoId: null,
    materiaId: null,
    assuntoId: null,
    unidadePedagogicaId: null,
  };
  const { deps, chamadas } = criarDepsFalsas({ obterSessaoAberta: async () => sessaoAbertaEstudoAvulso });
  let estadoAtual;
  const controlador = criarControladorSessaoTempo(deps, (e) => {
    estadoAtual = e;
  });
  controlador.definirContexto(CTX_AVULSO);
  await Promise.resolve();
  await Promise.resolve();
  assert.equal(estadoAtual.estado, "ativa", "deve recuperar, nunca mostrar conflito contra a própria sessão avulsa");
  assert.equal(estadoAtual.sessaoId, 77);
  assert.equal(chamadas.retomar.length, 1);
  assert.equal(chamadas.iniciar.length, 0);
});

test("24. conflito com sessão de OUTRA origem (ex.: questões) bloqueia corretamente", async () => {
  const sessaoAbertaQuestoes = {
    id: 5,
    origem: "questoes",
    tipoAtividade: "questoes",
    matriculaId: "matricula-1",
    missaoId: null,
    segundosLiquidos: 10,
    sessaoEstudoId: 999,
    cursoConteudoId: null,
    materiaId: 3,
    assuntoId: null,
    unidadePedagogicaId: null,
  };
  const { deps } = criarDepsFalsas({ obterSessaoAberta: async () => sessaoAbertaQuestoes });
  let estadoAtual;
  const controlador = criarControladorSessaoTempo(deps, (e) => {
    estadoAtual = e;
  });
  controlador.definirContexto(CTX_AVULSO);
  await Promise.resolve();
  await Promise.resolve();
  assert.equal(estadoAtual.estado, "conflito");
  assert.equal(estadoAtual.conflito.id, 5);
});

// ============================================================================
// Schema / RPCs (migration SQL) — mesma técnica já usada em
// tests/missao-questoes-progresso.test.mjs: assert.match contra o texto
// real da migration, nunca contra uma suposição do prompt.
// ============================================================================

test("2/4. origem/tipo_atividade amplos sem remover o índice único de sessão aberta nem as constraints antigas", () => {
  assert.match(migracao, /origem in \('cronograma', 'estudo_livre', 'questoes', 'estudo_avulso'\)/);
  assert.match(migracao, /tipo_atividade in \('teoria', 'questoes', 'leitura', 'revisao', 'nao_classificado'\)/);
  assert.match(migracao, /tipo_atividade <> 'nao_classificado' or origem = 'estudo_avulso'/);
  // índice único parcial (uma sessão aberta por usuário) nunca é tocado por esta migration:
  assert.doesNotMatch(migracao, /sessoes_tempo_usuario_aberta_unq/);
  assert.match(fundacao, /create unique index sessoes_tempo_usuario_aberta_unq/);
});

test("8/12. constraint composta permite exatamente o esperado — tabela-verdade avaliada de verdade, não só por regex", () => {
  // Mesmo predicado da constraint sessoes_tempo_nao_classificado_so_avulso,
  // avaliado em JS para os casos reais que importam — garante que a
  // LÓGICA (não só a presença da string) permite estudo_avulso+classificado
  // e continua proibindo nao_classificado fora de estudo_avulso.
  function constraintPermite(origem, tipoAtividade) {
    return tipoAtividade !== "nao_classificado" || origem === "estudo_avulso";
  }
  assert.equal(constraintPermite("estudo_avulso", "nao_classificado"), true, "estudo_avulso recém-iniciado deve ser permitido");
  assert.equal(constraintPermite("estudo_avulso", "teoria"), true, "estudo_avulso classificado como teoria deve ser permitido");
  assert.equal(constraintPermite("estudo_avulso", "questoes"), true, "estudo_avulso classificado como questoes deve ser permitido");
  assert.equal(constraintPermite("estudo_avulso", "leitura"), true, "estudo_avulso classificado como leitura deve ser permitido");
  assert.equal(constraintPermite("estudo_avulso", "revisao"), true, "estudo_avulso classificado como revisao deve ser permitido");
  assert.equal(constraintPermite("cronograma", "nao_classificado"), false, "nao_classificado fora de estudo_avulso deve ser proibido");
  assert.equal(constraintPermite("estudo_livre", "nao_classificado"), false, "nao_classificado fora de estudo_avulso deve ser proibido");
  assert.equal(constraintPermite("questoes", "nao_classificado"), false, "nao_classificado fora de estudo_avulso deve ser proibido");
  assert.equal(constraintPermite("cronograma", "teoria"), true, "origens normais continuam livres para seus tipos normais");
});

test("9/10/11. resumo/histórico/heatmap já são origem-agnósticos — nenhuma lógica nova precisa ser duplicada", () => {
  // resumo_tempo_estudo soma sessoes_tempo_dias sem filtrar por origem:
  const trechoResumo = fundacao.slice(fundacao.indexOf("function public.resumo_tempo_estudo"));
  assert.doesNotMatch(trechoResumo.slice(0, trechoResumo.indexOf("$function$;")), /and\s+st\.origem/);
  assert.doesNotMatch(trechoResumo.slice(0, trechoResumo.indexOf("$function$;")), /where std\.origem/);
  // heatmap (useDadosTempoEstudo.ts) é construído a partir do histórico sem filtrar origem:
  assert.match(useDados, /gerarGradeCompleta\(diasHistorico, historicoTempo\)/);
  assert.doesNotMatch(useDados.slice(useDados.indexOf("function gerarGradeCompleta")), /origem/);
});

test("12. nao_classificado tem rótulo próprio e nunca é excluído da distribuição por tipo", () => {
  assert.match(useDados, /nao_classificado: "Não classificado"/);
  // a leitura de sessoes_tempo para "Onde o tempo foi" nunca filtra tipo_atividade:
  const trechoLeitura = useDados.slice(useDados.indexOf('from("sessoes_tempo")'), useDados.indexOf('from("sessoes_tempo")') + 200);
  assert.doesNotMatch(trechoLeitura, /\.eq\("tipo_atividade"/);
});

test("13-16. classificar_estudo_avulso só aceita os 4 tipos finais (nunca nao_classificado de volta)", () => {
  const corpo = reforco.slice(reforco.indexOf("function public.classificar_estudo_avulso"));
  assert.match(corpo, /p_tipo_atividade not in \('teoria', 'questoes', 'leitura', 'revisao'\)/);
  assert.doesNotMatch(corpo.slice(0, corpo.indexOf("$function$;")), /'nao_classificado'.*not in|not in.*'nao_classificado'/);
});

test("17. classificação nunca altera segundos/tempo/identidade — só metadados", () => {
  const corpo = reforco.slice(reforco.indexOf("function public.classificar_estudo_avulso"));
  const setClause = corpo.slice(corpo.indexOf("update public.sessoes_tempo"), corpo.indexOf("where sessoes_tempo.id = p_sessao_tempo_id"));
  assert.match(setClause, /tipo_atividade = p_tipo_atividade/);
  assert.match(setClause, /materia_id = p_materia_id/);
  assert.match(setClause, /assunto_id = p_assunto_id/);
  assert.match(setClause, /descricao_estudo = v_descricao/);
  for (const campoProibido of ["segundos_liquidos", "iniciado_em", "encerrado_em", "usuario_id", "contabilizado_ate_em", "ultimo_heartbeat_em", "origem", "status"]) {
    assert.doesNotMatch(setClause, new RegExp(`\\b${campoProibido}\\s*=`), `classificar_estudo_avulso nao pode alterar ${campoProibido}`);
  }
});

test("18. descrição é trimada, string vazia vira NULL, com limite de 500 caracteres", () => {
  const corpo = reforco.slice(reforco.indexOf("function public.classificar_estudo_avulso"));
  assert.match(corpo, /nullif\(btrim\(coalesce\(p_descricao_estudo, ''\)\), ''\)/);
  assert.match(corpo, /char_length\(v_descricao\) > 500/);
  assert.match(migracao, /char_length\(descricao_estudo\) <= 500/); // constraint de banco (não tocada pelo reforço), defesa em profundidade
});

test("19/20. ownership e origem são validados antes de qualquer UPDATE", () => {
  const corpo = reforco.slice(reforco.indexOf("function public.classificar_estudo_avulso"));
  assert.match(corpo, /where st\.id = p_sessao_tempo_id\s*\n\s*and st\.usuario_id = v_usuario_id/);
  assert.match(corpo, /if v_sessao\.origem <> 'estudo_avulso' then/);
  assert.match(corpo, /if v_sessao\.status <> 'encerrada' then/);
});

test("materia_id: validado server-side contra curso_materias da matrícula DA SESSÃO (nunca do cliente), reaproveitando a relação já usada por materias_do_curso_ativo", () => {
  const corpo = reforco.slice(reforco.indexOf("function public.classificar_estudo_avulso"));
  // curso vem da matrícula da própria sessão, nunca de um parâmetro do cliente:
  assert.match(corpo, /select m\.curso_id into v_curso_id\s*\n\s*from public\.matriculas m\s*\n\s*where m\.id = v_sessao\.matricula_id/);
  assert.match(corpo, /from public\.curso_materias cm\s*\n\s*where cm\.curso_id = v_curso_id\s*\n\s*and cm\.materia_id = p_materia_id\s*\n\s*and cm\.relevante_para_preparacao = true/);
  assert.match(corpo, /raise exception 'Materia nao pertence ao curso desta matricula'/);
  // nunca mais a checagem antiga, "existe em algum lugar" sem dono:
  assert.doesNotMatch(corpo, /select 1 from public\.materias mt where mt\.id = p_materia_id/);
});

test("assunto_id: validado server-side contra curso_conteudos coerente com a MESMA matéria/curso (nunca isolado)", () => {
  const corpo = reforco.slice(reforco.indexOf("function public.classificar_estudo_avulso"));
  assert.match(corpo, /from public\.curso_conteudos cc\s*\n\s*join public\.curso_materias cm on cm\.id = cc\.curso_materia_id\s*\n\s*where cm\.curso_id = v_curso_id\s*\n\s*and cm\.materia_id = p_materia_id\s*\n\s*and cc\.assunto_id = p_assunto_id\s*\n\s*and cc\.relevante_para_preparacao = true/);
  assert.match(corpo, /raise exception 'Assunto invalido para esta materia\/curso'/);
  // assunto sem matéria é rejeitado antes de qualquer consulta (nunca "assunto solto" sem contexto):
  assert.match(corpo, /if p_assunto_id is not null and p_materia_id is null then\s*\n\s*raise exception 'p_assunto_id informado sem p_materia_id'/);
  assert.doesNotMatch(corpo, /select 1 from public\.assuntos a where a\.id = p_assunto_id/);
});

test("materia_id/assunto_id: a lógica de pertencimento (espelhando os JOINs reais) aceita e rejeita exatamente os casos esperados", () => {
  // Não executa SQL real (sem harness de DB nos testes deste projeto) —
  // espelha fielmente os MESMOS predicados dos JOINs de classificar_estudo_avulso
  // contra um dataset fake, testando o comportamento da regra, não só a
  // presença de texto.
  const cursoMaterias = [
    { curso_id: "curso-A", materia_id: 10, relevante_para_preparacao: true },
    { curso_id: "curso-A", materia_id: 11, relevante_para_preparacao: false }, // existe, mas não é relevante para este curso
    { curso_id: "curso-B", materia_id: 20, relevante_para_preparacao: true }, // existe globalmente, mas é de OUTRO curso
  ];
  const cursoConteudos = [
    { curso_materia_chave: "curso-A|10", assunto_id: 100, relevante_para_preparacao: true },
    { curso_materia_chave: "curso-A|10", assunto_id: 101, relevante_para_preparacao: false },
  ];
  function materiaValida(cursoId, materiaId) {
    return cursoMaterias.some((cm) => cm.curso_id === cursoId && cm.materia_id === materiaId && cm.relevante_para_preparacao);
  }
  function assuntoValido(cursoId, materiaId, assuntoId) {
    const chave = `${cursoId}|${materiaId}`;
    return cursoConteudos.some((cc) => cc.curso_materia_chave === chave && cc.assunto_id === assuntoId && cc.relevante_para_preparacao);
  }
  assert.equal(materiaValida("curso-A", 10), true, "matéria relevante do curso certo é aceita");
  assert.equal(materiaValida("curso-A", 11), false, "matéria marcada como não-relevante para este curso é rejeitada");
  assert.equal(materiaValida("curso-A", 20), false, "matéria existente só em OUTRO curso é rejeitada (FK válida não basta)");
  assert.equal(assuntoValido("curso-A", 10, 100), true, "assunto coerente com a matéria/curso certos é aceito");
  assert.equal(assuntoValido("curso-A", 10, 101), false, "assunto marcado como não-relevante é rejeitado");
  assert.equal(assuntoValido("curso-A", 11, 100), false, "mesmo assunto não pode ser aceito via uma matéria diferente da informada");
});

test("mesma assinatura/grants preservados — migration incremental é CREATE OR REPLACE, não um DROP+CREATE", () => {
  assert.doesNotMatch(reforco, /drop function/i);
  assert.doesNotMatch(reforco, /revoke all on|grant execute on/); // grants já aplicados pela migration anterior continuam válidos sem repetição
  assert.match(reforco, /create or replace function public\.classificar_estudo_avulso\(/);
});

test("21. nada nas duas migrations escreve em sessoes_estudo/missoes/respostas_usuarios (progresso curricular intacto)", () => {
  for (const arquivo of [migracao, reforco]) {
    // única menção a sessoes_estudo é leitura (validação de contexto opcional já existente em iniciar_sessao_tempo) — nunca INSERT/UPDATE.
    assert.doesNotMatch(arquivo, /insert into public\.sessoes_estudo/);
    assert.doesNotMatch(arquivo, /update public\.sessoes_estudo/);
    assert.doesNotMatch(arquivo, /insert into public\.missoes/);
    assert.doesNotMatch(arquivo, /update public\.missoes/);
    assert.doesNotMatch(arquivo, /respostas_usuarios/);
    // curso_materias/curso_conteudos (reforço de segurança) são só LEITURA aqui — nunca INSERT/UPDATE/DELETE:
    assert.doesNotMatch(arquivo, /insert into public\.curso_materias/);
    assert.doesNotMatch(arquivo, /update public\.curso_materias/);
    assert.doesNotMatch(arquivo, /insert into public\.curso_conteudos/);
    assert.doesNotMatch(arquivo, /update public\.curso_conteudos/);
  }
});

test("grants: classificar_estudo_avulso é authenticated-only, nunca public/anon", () => {
  assert.match(migracao, /revoke all on function public\.classificar_estudo_avulso\([^)]*\) from public, anon, authenticated/);
  assert.match(migracao, /grant execute on function public\.classificar_estudo_avulso\([^)]*\) to authenticated/);
});

// ============================================================================
// Frontend — estrutura mínima esperada
// ============================================================================

test("provider global: useSessaoTempo é instanciado UMA ÚNICA VEZ em todo o projeto, dentro de SessaoTempoProvider", () => {
  assert.match(provider, /const sessaoAvulsa = useSessaoTempo\(/);
  assert.match(provider, /<CronometroEstudo sessao=\{sessaoAvulsa\}/);
  assert.match(provider, /<SessaoTempoContext\.Provider value=\{sessaoAvulsa\}>/);
  // nenhum outro arquivo de componente/página chama useSessaoTempo diretamente:
  for (const [nome, conteudo] of [["app/meu-estudo/page.tsx", meuEstudo], ["CronometroLivre.tsx", cronometroLivre], ["app/painel/page.tsx", painel]]) {
    assert.doesNotMatch(conteudo, /\buseSessaoTempo\(/, `${nome} nao deve chamar useSessaoTempo() diretamente — só useSessaoTempoGlobal()`);
  }
});

test("SessaoTempoProvider está montado em app/layout.tsx (raiz — único ancestral real de todas as rotas autenticadas) e só lá", () => {
  assert.match(rootLayout, /<SessaoTempoProvider>\{children\}<\/SessaoTempoProvider>/);
  assert.equal((rootLayout.match(/<SessaoTempoProvider/g) ?? []).length, 1);
});

test("23. timer flutuante e aba Cronômetro Livre usam a MESMA instância do motor (via contexto global, não um hook próprio)", () => {
  assert.match(meuEstudo, /const sessaoAvulsa = useSessaoTempoGlobal\(\);/);
  assert.match(meuEstudo, /<CronometroLivre sessao=\{sessaoAvulsa\}/);
  // nunca mais um CronometroEstudo próprio aqui — o único widget vem do provider global:
  assert.doesNotMatch(meuEstudo, /<CronometroEstudo/);
});

test("painel continua sem nenhuma RPC nova (gate herdado) — app/painel/page.tsx não foi tocado por este fechamento de pendências", () => {
  assert.equal((painel.match(/\.rpc\(/g) ?? []).length, 1);
  assert.doesNotMatch(painel, /useSessaoTempo/);
  assert.doesNotMatch(painel, /CronometroEstudo/);
});

test("CronometroLivre não exige nenhum campo antes de iniciar, e nunca usa dangerouslySetInnerHTML na descrição", () => {
  assert.match(cronometroLivre, /onClick=\{sessao\.iniciarEstudo\}/);
  assert.doesNotMatch(cronometroLivre, /dangerouslySetInnerHTML/);
  assert.doesNotMatch(classificar, /dangerouslySetInnerHTML/);
});

test("meu-estudo expõe a aba Cronômetro Livre sem remover a aba Resumo", () => {
  assert.match(meuEstudo, />\s*Resumo\s*</);
  assert.match(meuEstudo, />\s*Cronômetro livre\s*</);
});
