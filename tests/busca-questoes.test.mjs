import test from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

// PAPIRO — Pesquisa livre de questões (/questoes/buscar). Mesma técnica do
// resto do projeto: assert.match/doesNotMatch contra o texto REAL da
// página/CSS, e mirror em JS da lógica pura (chips, status exclusivo,
// sequência anti-race-condition) quando o comportamento — não só a
// presença de texto — é o que importa.
const pagina = await readFile(new URL("../app/questoes/buscar/page.tsx", import.meta.url), "utf8");
const questoesPage = await readFile(new URL("../app/questoes/page.tsx", import.meta.url), "utf8");
const globalsCss = await readFile(new URL("../app/globals.css", import.meta.url), "utf8");

// ============================================================================
// 1. rota existe / 2. render do título
// ============================================================================

test("1. app/questoes/buscar/page.tsx existe e exporta a página default", () => {
  assert.match(pagina, /export default function BuscarQuestoes/);
});

test("2. título e subtítulo renderizados exatamente como especificado", () => {
  assert.match(pagina, /<h1>Questões<\/h1>/);
  assert.match(pagina, /<span>Encontre exatamente o que precisa praticar\.<\/span>/);
});

// ============================================================================
// 3/4. status — default e exclusividade
// ============================================================================

test("3. status default é 'todas'", () => {
  assert.match(pagina, /const \[status, setStatus\] = useState<Situacao>\("todas"\);/);
});

test("4. troca de status é exclusiva (role=tab/aria-selected, um clique troca o valor inteiro, nunca acumula)", () => {
  assert.match(pagina, /role="tablist" aria-label="Filtrar por status da questão"/);
  assert.match(pagina, /aria-selected=\{status === opcao\.valor\}/);
  assert.match(pagina, /onClick=\{\(\) => setStatus\(opcao\.valor\)\}/);
  // mirror: setStatus substitui o valor, nunca soma/alterna bits — único estado possível por vez
  const OPCOES_STATUS = ["todas", "nao_resolvidas", "resolvidas", "acertei", "errei"];
  let status = "todas";
  const setStatus = (valor) => { status = valor; };
  setStatus("errei");
  assert.equal(status, "errei");
  assert.equal(OPCOES_STATUS.filter((v) => v === status).length, 1);
});

// ============================================================================
// 5/6/7. matéria e assunto
// ============================================================================

test("5. matérias carregam via materias_do_curso_ativo (RPC já existente, nenhuma nova)", () => {
  assert.match(pagina, /supabase\.rpc\("materias_do_curso_ativo"\)/);
});

test("6. assunto depende da matéria: efeito só roda com materiaId definido, chama assuntos_do_curso_ativo", () => {
  const corpoEfeito = pagina.slice(pagina.indexOf("// Assunto depende de matéria"), pagina.indexOf("}, [materiaId]);") + 20);
  assert.match(corpoEfeito, /if \(!materiaId\) \{ setAssuntosCurso\(\[\]\); return; \}/);
  assert.match(corpoEfeito, /\.rpc\("assuntos_do_curso_ativo", \{ p_materia_id: materiaId \}\)/);
  assert.match(pagina, /\}, \[materiaId\]\);/);
});

test("7. trocar matéria limpa o assunto incompatível (setAssuntoId(null) no próprio onChange da matéria)", () => {
  const corpoSelectMateria = pagina.slice(pagina.indexOf('value={materiaId ?? ""}'), pagina.indexOf('value={assuntoId ?? ""}'));
  assert.match(corpoSelectMateria, /setMateriaId\(valor\);/);
  assert.match(corpoSelectMateria, /setAssuntoId\(null\);/);
});

test("sem matéria selecionada, o select de assunto fica desabilitado (estado neutro coerente)", () => {
  assert.match(pagina, /disabled=\{!materiaId \|\| carregandoAssuntos\}/);
});

// ============================================================================
// 8. banca/ano/dificuldade via opcoes_pesquisa_questoes (nunca SELECT global)
// ============================================================================

test("8. banca/ano/dificuldade carregam via opcoes_pesquisa_questoes — nunca SELECT direto em questoes", () => {
  assert.match(pagina, /supabase\.rpc\("opcoes_pesquisa_questoes"\)/);
  assert.doesNotMatch(pagina, /\.from\("questoes"\)/);
  assert.match(pagina, /\(opcoes\.bancas \?\? \[\]\)\.map/);
  assert.match(pagina, /\(opcoes\.anos \?\? \[\]\)\.map/);
  assert.match(pagina, /\(opcoes\.dificuldades \?\? \[\]\)\.map/);
});

test("dificuldade é exibida de forma amigável (Fácil/Média/Difícil) mas o valor enviado ao backend é o técnico", () => {
  assert.match(pagina, /facil: "Fácil",/);
  assert.match(pagina, /media: "Média",/);
  assert.match(pagina, /dificil: "Difícil",/);
  assert.match(pagina, /<option key=\{valor\} value=\{valor\}>\{rotuloDificuldade\(valor\)\}<\/option>/);
});

// ============================================================================
// 9/10. busca + debounce
// ============================================================================

test("9. busca textual (buscaInput) é dependência do efeito que recalcula a contagem", () => {
  const efeito = pagina.slice(pagina.indexOf("// Contador — debounce"), pagina.indexOf("}, [carregandoInicial, semContexto, status"));
  assert.match(efeito, /buscaInput/);
  assert.match(pagina, /\}, \[carregandoInicial, semContexto, status, materiaId, assuntoId, banca, ano, dificuldade, buscaInput\]\);/);
});

test("10. debounce de ~400ms (dentro de 300-500ms) antes de chamar a RPC — nunca uma chamada por tecla", () => {
  assert.match(pagina, /const DEBOUNCE_CONTAGEM_MS = 400;/);
  assert.match(pagina, /window\.setTimeout\(async \(\) => \{/);
  assert.match(pagina, /\}, DEBOUNCE_CONTAGEM_MS\);/);
  assert.match(pagina, /return \(\) => window\.clearTimeout\(agendamento\);/);
  assert.ok(400 >= 300 && 400 <= 500, "debounce deve estar entre 300 e 500ms");
});

// ============================================================================
// 11. contagem reflete exatamente os filtros atuais
// ============================================================================

test("11. contar_questoes_pesquisa é chamada com os 7 filtros atuais (nunca quantidade, que não é filtro de elegibilidade)", () => {
  const chamada = pagina.slice(pagina.indexOf('rpc("contar_questoes_pesquisa"'), pagina.indexOf('rpc("contar_questoes_pesquisa"') + 400);
  for (const param of ["p_materia_id: materiaId", "p_assunto_id: assuntoId", "p_banca: banca", "p_ano: ano", "p_dificuldade: dificuldade", "p_busca: buscaNormalizada", "p_status: status"]) {
    assert.ok(chamada.includes(param), `contar_questoes_pesquisa deveria enviar ${param}`);
  }
  assert.doesNotMatch(chamada, /p_quantidade/, "contagem nunca deve considerar quantidade — quantidade não é filtro de elegibilidade");
});

test("busca é normalizada (trim; vazio vira null) antes de ir para a RPC — mesma regra do backend", () => {
  assert.match(pagina, /const buscaNormalizada = buscaInput\.trim\(\) \|\| null;/g);
});

// ============================================================================
// 12/13. zero resultados
// ============================================================================

test("12. zero resultados mostra mensagem amigável específica", () => {
  assert.match(pagina, /const zeroResultados = contagem === 0 && !carregandoContagem && !erroContagem;/);
  assert.match(pagina, /Nenhuma questão encontrada com esses filtros\. Tente remover ou alterar algum filtro\./);
});

test("13. botão 'Buscar questões' fica desabilitado quando a contagem é zero (ou ainda carregando/com erro)", () => {
  assert.match(pagina, /const podeBuscar = !carregandoContagem && !erroContagem && !iniciandoSessao && \(contagem \?\? 0\) > 0;/);
  assert.match(pagina, /<button type="button" className="bq-cta" disabled=\{!podeBuscar\} onClick=\{iniciarSessao\}>/);
});

// ============================================================================
// 14/15/16. chips / remover / limpar tudo
// ============================================================================

function construirChips({ status, materiaId, assuntoId, banca, ano, dificuldade, buscaAtiva, materiaNome, assuntoNome }) {
  const lista = [];
  if (status !== "todas") lista.push({ chave: "status", rotulo: status });
  if (materiaId !== null) lista.push({ chave: "materia", rotulo: materiaNome });
  if (assuntoId !== null) lista.push({ chave: "assunto", rotulo: assuntoNome });
  if (banca) lista.push({ chave: "banca", rotulo: banca });
  if (ano !== null) lista.push({ chave: "ano", rotulo: String(ano) });
  if (dificuldade) lista.push({ chave: "dificuldade", rotulo: dificuldade });
  if (buscaAtiva) lista.push({ chave: "busca", rotulo: `"${buscaAtiva}"` });
  return lista;
}

test("14. chips mostram só os filtros REALMENTE ativos — status 'todas' nunca vira chip", () => {
  assert.match(pagina, /if \(status !== "todas"\) \{/);
  const semFiltro = construirChips({ status: "todas", materiaId: null, assuntoId: null, banca: null, ano: null, dificuldade: null, buscaAtiva: "" });
  assert.equal(semFiltro.length, 0);
  const comFiltros = construirChips({ status: "errei", materiaId: 6, assuntoId: null, banca: "FUNDATEC", ano: 2025, dificuldade: "media", buscaAtiva: "crase", materiaNome: "Português" });
  assert.deepEqual(comFiltros.map((c) => c.chave), ["status", "materia", "banca", "ano", "dificuldade", "busca"]);
});

test("sem nenhum filtro, a lateral mostra 'Nenhum filtro aplicado.'", () => {
  assert.match(pagina, /Nenhum filtro aplicado\./);
  assert.match(pagina, /chips\.length === 0 \?/);
});

test("15. remover um chip só afeta aquele filtro — remover matéria também limpa o assunto (incompatível), os demais chips sobrevivem", () => {
  assert.match(pagina, /remover: \(\) => \{ setMateriaId\(null\); setAssuntoId\(null\); \},/);
  assert.match(pagina, /remover: \(\) => setBanca\(null\)/);
  assert.match(pagina, /remover: \(\) => setAno\(null\)/);
  assert.match(pagina, /remover: \(\) => setDificuldade\(null\)/);
  assert.match(pagina, /remover: \(\) => setBuscaInput\(""\)/);
});

test("16. 'Limpar filtros'/'Limpar tudo' zeram os 6 filtros acadêmicos, mas preservam a quantidade (preferência da sessão)", () => {
  const corpoLimpar = pagina.slice(pagina.indexOf("function limparFiltros()"), pagina.indexOf("const zeroResultados ="));
  for (const chamada of ['setStatus("todas")', "setMateriaId(null)", "setAssuntoId(null)", "setBanca(null)", "setAno(null)", "setDificuldade(null)", 'setBuscaInput("")']) {
    assert.ok(corpoLimpar.includes(chamada), `limparFiltros deveria chamar ${chamada}`);
  }
  assert.doesNotMatch(corpoLimpar, /setQuantidade/, "quantidade não deve ser resetada por 'Limpar filtros'");
  // o mesmo handler é usado tanto no rodapé quanto no 'Limpar tudo' da lateral:
  assert.equal((pagina.match(/onClick=\{limparFiltros\}/g) ?? []).length, 2);
});

// ============================================================================
// 17/18. quantidade
// ============================================================================

test("17. quantidade oferece 10/20/30/50 na UI (backend aceita até 100, mas esta UI inicial só oferece opções simples)", () => {
  assert.match(pagina, /const OPCOES_QUANTIDADE = \[10, 20, 30, 50\] as const;/);
  assert.match(pagina, /aria-pressed=\{quantidade === valor\}/);
});

test("18. iniciar sessão envia TODOS os filtros atuais + quantidade — mesma assinatura da RPC auditada", () => {
  const chamada = pagina.slice(pagina.indexOf('rpc("iniciar_sessao_questoes_pesquisa"'), pagina.indexOf('rpc("iniciar_sessao_questoes_pesquisa"') + 400);
  for (const param of ["p_quantidade: quantidade", "p_materia_id: materiaId", "p_assunto_id: assuntoId", "p_banca: banca", "p_ano: ano", "p_dificuldade: dificuldade", "p_busca: buscaNormalizada", "p_status: status"]) {
    assert.ok(chamada.includes(param), `iniciar_sessao_questoes_pesquisa deveria enviar ${param}`);
  }
});

// ============================================================================
// 19. navegação para sessaoAvulsa — nunca filtros na URL, nunca ids calculados no cliente
// ============================================================================

test("19. ao obter sessão, navega para /questoes?sessaoAvulsa=<id> — nunca envia filtros pela URL, nunca busca ids no cliente", () => {
  assert.match(pagina, /router\.push\(`\/questoes\?sessaoAvulsa=\$\{linha\.sessao_id\}`\);/);
  const corpoIniciar = pagina.slice(pagina.indexOf("async function iniciarSessao()"), pagina.indexOf("async function sair()"));
  assert.doesNotMatch(corpoIniciar, /materiaId=|assuntoId=|banca=|status=/, "filtros nunca podem ir na querystring da navegação");
  assert.doesNotMatch(corpoIniciar, /\.from\("questoes"\)|ids_questoes_para_usuario/, "esta tela nunca calcula/busca ids de questão — a sessão do servidor é a fonte de verdade");
});

// ============================================================================
// 20. loading do CTA / duplo clique
// ============================================================================

test("20. CTA mostra 'Preparando questões...' e fica desabilitado durante a criação — nunca permite duplo submit", () => {
  assert.match(pagina, /if \(!podeBuscar \|\| iniciandoSessao\) return;/);
  assert.match(pagina, /setIniciandoSessao\(true\);/);
  assert.match(pagina, /\{iniciandoSessao \? "Preparando questões\.\.\." : "Buscar questões"\}/);
  // podeBuscar já exige !iniciandoSessao, então o botão fica disabled sozinho durante a criação:
  assert.match(pagina, /!iniciandoSessao && \(contagem \?\? 0\) > 0;/);
});

// ============================================================================
// 21. erros controlados — nunca alert(), nunca mensagem bruta do Postgres
// ============================================================================

test("21. erros de RPC usam mensagens controladas no padrão Papiro — nunca alert(), nunca a mensagem bruta do Postgres exposta ao aluno", () => {
  assert.doesNotMatch(pagina, /\balert\(/);
  assert.match(pagina, /mensagemErro\.includes\("matricula ativa"\)/);
  assert.match(pagina, /"Sua matrícula no curso ativo não está disponível no momento\."/);
  assert.match(pagina, /mensagemErro\.includes\("nenhuma questao encontrada"\)/);
  assert.match(pagina, /"Nenhuma questão encontrada com esses filtros\. Tente remover ou alterar algum filtro\."/);
  assert.match(pagina, /"Não foi possível iniciar a pesquisa agora\. Tente novamente\."/);
  // detalhe técnico só no console, nunca em texto renderizado:
  assert.match(pagina, /console\.error\("iniciar_sessao_questoes_pesquisa falhou:"/);
});

test("usuário sem curso ativo/matrícula ativa recebe mensagem controlada (mesmo padrão de app/caderno-de-erros)", () => {
  assert.match(pagina, /"Selecione um curso ativo para pesquisar questões\."/);
  assert.match(pagina, /"Sua matrícula no curso ativo não está disponível no momento\."/);
  assert.match(pagina, /setSemContexto\(true\);/);
});

// ============================================================================
// 22. proteção contra race condition da contagem
// ============================================================================

test("22. contagem usa número de sequência para descartar respostas desatualizadas (race condition)", () => {
  assert.match(pagina, /const sequenciaContagemRef = useRef\(0\);/);
  assert.match(pagina, /const minhaSequencia = \+\+sequenciaContagemRef\.current;/);
  assert.match(pagina, /if \(minhaSequencia !== sequenciaContagemRef\.current\) return;/);

  // mirror: requisição A inicia, filtro muda (B inicia e incrementa a ref),
  // B responde primeiro, DEPOIS A responde — A não pode sobrescrever B.
  const sequenciaRef = { current: 0 };
  let contagemAplicada = null;
  function dispara(valorFinal) {
    const minhaSequencia = ++sequenciaRef.current;
    return () => {
      if (minhaSequencia !== sequenciaRef.current) return; // resposta desatualizada, descartada
      contagemAplicada = valorFinal;
    };
  }
  const resolverA = dispara(27); // request A: 27 resultados (filtro antigo)
  const resolverB = dispara(5); // request B: filtro mudou, 5 resultados
  resolverB(); // B (mais novo) responde primeiro
  resolverA(); // A (mais antigo) responde depois — deve ser ignorado
  assert.equal(contagemAplicada, 5, "a resposta mais antiga (A) nunca pode sobrescrever a mais nova (B) que já respondeu");
});

// ============================================================================
// 23. fluxos contextuais de /questoes não foram alterados
// ============================================================================

test("23. o link de pesquisa livre só aparece no modo livre (!origemCronograma) — nunca interfere em missão/revisão/unidade/Missão Final", () => {
  const inicioBloco = questoesPage.indexOf("{!origemCronograma && (");
  const blocoModoLivre = questoesPage.slice(inicioBloco, inicioBloco + 1200);
  assert.match(blocoModoLivre, /href="\/questoes\/buscar"/);
  assert.match(blocoModoLivre, /Pesquisar questões por banca, ano e dificuldade/);
  // o link vive dentro do MESMO guard condicional que já protegia as abas
  // (session-mode-tabs) — nunca renderiza quando origemCronograma é true:
  assert.match(questoesPage, /\{!origemCronograma && \(\s*\n\s*<>/);
});

test("fluxos de missão/unidade/Missão Final/revisão automática/revisão personalizada continuam com as mesmas RPCs de antes — nenhuma redefinida por esta tarefa", () => {
  for (const rpc of [
    "iniciar_pratica_unidade",
    "iniciar_missao_final",
    "iniciar_questoes_da_missao",
    "concluir_pratica_unidade",
    "concluir_missao_final",
    "concluir_questoes_da_missao",
    "iniciar_revisao",
    "iniciar_revisao_personalizada",
    "concluir_revisao",
    "registrar_resposta",
    "classificar_erro",
  ]) {
    assert.match(questoesPage, new RegExp(`"${rpc}"`), `${rpc} deveria continuar presente e intocada em /questoes`);
  }
});

test("app/questoes/page.tsx: único outro ponto tocado por esta tarefa é o suporte a nivel='pesquisa' no título (já validado em gate anterior)", () => {
  assert.match(questoesPage, /nivel === "pesquisa" \? "Pesquisa de questões"/);
});

// ============================================================================
// Acessibilidade
// ============================================================================

test("acessibilidade: labels reais (não decorativos), botões reais (não div clicável), aria em toggles/listas", () => {
  assert.match(pagina, /<label className="bq-bloco-titulo" htmlFor="bq-busca-input">Buscar por palavra-chave<\/label>/);
  assert.match(pagina, /id="bq-busca-input"/);
  assert.doesNotMatch(pagina, /<div[^>]*onClick=/, "nenhum div clicável substituindo um button real");
  assert.match(pagina, /role="group" aria-label="Quantidade de questões"/);
  assert.match(pagina, /aria-label="Filtros de pesquisa"/);
  assert.match(pagina, /aria-label="Filtros aplicados"/);
  assert.match(pagina, /aria-label=\{`Remover filtro \$\{chip\.rotulo\}`\}/);
});

test("estados de foco visíveis (:focus-visible com outline dourado) nos controles interativos novos", () => {
  assert.match(globalsCss, /\.bq-status button:focus-visible \{/);
  assert.match(globalsCss, /\.bq-quantidade-opcoes button:focus-visible \{/);
  assert.match(globalsCss, /\.bq-cta:focus-visible \{/);
  assert.match(globalsCss, /\.bq-chips li button:focus-visible \{/);
  assert.match(globalsCss, /\.bq-filtros-grade select:focus-visible,\s*\n\s*\.bq-busca input:focus-visible \{/);
});

// ============================================================================
// Identidade visual — reuso de tokens, nenhum token novo, nenhum cruzamento
// de sistema (.papiro-next vs .method-page, mesma regra já documentada
// para painel.css).
// ============================================================================

test("reusa tokens existentes (--papiro-gold/--papiro-panel/--papiro-elevar/--papiro-sheen/--papiro-line) — nenhum token de cor novo criado", () => {
  const blocoCss = globalsCss.slice(globalsCss.indexOf(".busca-questoes {"), globalsCss.indexOf("/* Configuração de objetivos */"));
  assert.match(blocoCss, /var\(--papiro-gold\)/);
  assert.match(blocoCss, /var\(--papiro-panel\)/);
  assert.match(blocoCss, /var\(--papiro-elevar\)/);
  assert.match(blocoCss, /var\(--papiro-sheen\)/);
  assert.match(blocoCss, /var\(--papiro-line\)/);
  assert.doesNotMatch(blocoCss, /--papiro-color-/, "nunca reaproveitar os tokens --papiro-color-* do sistema V2 do painel (sistemas paralelos, nunca cruzados)");
});

test("página usa StudentAppShell + reestabelece o escopo .method-page localmente para herdar os tokens V2 (mesma técnica documentada no cabeçalho do CSS)", () => {
  assert.match(pagina, /<StudentAppShell currentHref="\/questoes\/buscar"/);
  assert.match(pagina, /className="method-page busca-questoes"/);
});

test("layout principal+lateral colapsa em telas menores (painel lateral vai para baixo, não quebra mobile)", () => {
  assert.match(globalsCss, /@media \(max-width: 1080px\) \{\s*\n\s*\.bq-layout \{ grid-template-columns: 1fr; \}/);
  assert.match(globalsCss, /@media \(max-width: 720px\) \{\s*\n\s*\.bq-filtros-grade--2,/);
});

// ============================================================================
// Escopo — nada fora do aprovado foi implementado nesta fase.
// ============================================================================

test("nada fora do escopo aprovado: sem lista navegável de questões, sem seleção manual, sem paginação, sem modal de questão", () => {
  assert.doesNotMatch(pagina, /\.map\(\(questao\)/i);
  assert.doesNotMatch(pagina, /modal/i);
  assert.doesNotMatch(pagina, /pagina(cao|ção)/i);
  assert.doesNotMatch(pagina, /favorito/i);
  assert.doesNotMatch(pagina, /simulado/i);
});
