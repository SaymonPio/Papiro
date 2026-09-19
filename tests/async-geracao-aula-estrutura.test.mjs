import assert from "node:assert/strict";
import test from "node:test";
import { readFile } from "node:fs/promises";
import path from "node:path";

// Testes de INSPEÇÃO DE FONTE (não de execução) — confirmam propriedades
// arquiteturais da Fase 3A que não podem ser exercitadas sem Deno/rede/
// banco real: que a persistência saiu do iniciador, que o finalizador
// nunca aceita JWT de usuário, e que a UI nunca chama o finalizador nem a
// OpenAI diretamente e nunca dispara duas gerações para a mesma unidade.
// Mesmo princípio de "sem chamar OpenAI e sem banco LIVE" do mandato:
// aqui a fonte É o fixture, sem precisar mockar nada.

const RAIZ = path.resolve(import.meta.dirname, "..");
async function lerFonte(caminhoRelativo) {
  return readFile(path.join(RAIZ, caminhoRelativo), "utf8");
}

test("A) gerar-aula/index.ts (iniciador) não escreve mais em aulas/aula_versoes/aula_versao_fontes — persistência é só do finalizador", async () => {
  const fonte = await lerFonte("supabase/functions/gerar-aula/index.ts");
  assert.ok(!fonte.includes('.from("aulas")'), "iniciador não deve tocar na tabela aulas");
  assert.ok(!fonte.includes('.from("aula_versoes")'), "iniciador não deve tocar na tabela aula_versoes");
  assert.ok(!fonte.includes('.from("aula_versao_fontes")'), "iniciador não deve tocar na tabela aula_versao_fontes");
});

test("B) gerar-aula/index.ts submete em background:true e retorna 202 sem esperar a IA terminar", async () => {
  const fonte = await lerFonte("supabase/functions/gerar-aula/index.ts");
  assert.ok(fonte.includes("submeterResponseBackground"), "deve delegar a submissão ao helper de background");
  assert.match(fonte, /json\(\{ ok: true, async: true, geracaoId, status: "processando" \}, 202\)/, "deve responder 202 imediatamente após aceitar o job");
  assert.ok(!fonte.includes("buscarResponse"), "o iniciador nunca deve consultar o resultado — isso é exclusivo do finalizador");
});

test("C) gerar-aula/index.ts nunca altera o CHECK de status nem cria um status novo além dos 3 existentes", async () => {
  const fonte = await lerFonte("supabase/functions/gerar-aula/index.ts");
  // Checa USO real (status: "valor"), não menções em comentário/prosa —
  // o cabeçalho do arquivo cita "aguardando_ia" só para explicar a
  // decisão de NÃO criar esse status, o que é o comportamento correto.
  for (const statusProibido of ["aguardando_ia", "em_fila", "background"]) {
    assert.ok(!fonte.includes(`status: "${statusProibido}"`), `não deve ATRIBUIR o status "${statusProibido}" em nenhum lugar do código`);
  }
  assert.ok(fonte.includes('status: "processando"'));
  assert.ok(fonte.includes('status: "erro"'));
});

test("D) finalizar-geracao-aula/index.ts nunca usa JWT de usuário/eh_admin — autenticação é só o secret interno dedicado", async () => {
  const fonte = await lerFonte("supabase/functions/finalizar-geracao-aula/index.ts");
  // Checa CHAMADA real (.rpc("eh_admin")), não a menção em comentário que
  // explica por que esse fluxo foi deliberadamente evitado aqui.
  assert.ok(!fonte.includes('.rpc("eh_admin")'), "o finalizador não deve chamar eh_admin() — não é um fluxo de usuário");
  assert.ok(!fonte.includes("auth.getUser"), "o finalizador não deve validar sessão de usuário");
  assert.ok(fonte.includes("FINALIZAR_GERACAO_SECRET"), "deve usar um secret interno dedicado");
  assert.ok(fonte.includes("x-finalizador-secret"), "deve exigir o header dedicado");
  assert.match(fonte, /if \(!secretConfigurado\) return false;/, "fail-closed: sem secret configurado, recusa tudo");
});

test("E) finalizar-geracao-aula/index.ts respeita o máximo de 2 tentativas de IA por geração", async () => {
  const fonte = await lerFonte("supabase/functions/finalizar-geracao-aula/index.ts");
  assert.match(fonte, /geracao\.tentativa_ia >= 2/, "deve checar o teto de tentativas antes de submeter uma nova correção");
  assert.ok(fonte.includes("tentativa_ia: 2"), "a correção deve marcar tentativa_ia=2, nunca 3");
  assert.ok(!fonte.includes("tentativa_ia: 3"), "nunca deve existir uma 3ª tentativa");
});

test("F) finalizar-geracao-aula/index.ts guarda idempotência antes de persistir (Fase 4.1: reivindicação por LEASE, não mais um SELECT separado nem finalizado_em — ver também testes O/Q/R)", async () => {
  const fonte = await lerFonte("supabase/functions/finalizar-geracao-aula/index.ts");
  assert.ok(fonte.includes("reivindicarGeracaoParaFinalizar("), "deve reivindicar atomicamente antes de processar");
  assert.ok(fonte.includes('"ja_reivindicada_por_outro_worker"'), "deve abortar silenciosamente quando outra execução já detém a lease");
});

test("G) app/admin/aulas/page.tsx: botão de gerar fica desabilitado e o clique é bloqueado enquanto existe geração ATIVA (nunca um registro legado/órfão — correção pós-tem_response_id)", async () => {
  const fonte = await lerFonte("app/admin/aulas/page.tsx");
  assert.ok(fonte.includes('from "./geracao-guard"'), "deve importar o guard extraído (testável com node --test, ver tests/admin-aulas-geracao-guard.test.mjs)");
  assert.ok(fonte.includes("existeGeracaoAtiva"), "deve existir uma única fonte de verdade derivada de geracaoBloqueiaNovaGeracao");
  assert.match(fonte, /disabled=\{gerando \|\| existeGeracaoAtiva\}/, "o botão deve refletir o mesmo guard no disabled");
  assert.match(fonte, /if \(!conteudoId \|\| !unidadeId \|\| gerando \|\| existeGeracaoAtiva\) return;/, "gerarAula() deve abortar cedo com o mesmo guard, mesmo se o botão for clicado via evento sintético");
  assert.ok(!fonte.includes("existeGeracaoProcessando"), "o nome antigo (que tratava qualquer 'processando' como bloqueante, inclusive órfãos) não pode sobrar");
});

test("H) app/admin/aulas/page.tsx: polling usa setInterval com limpeza no unmount/dependência", async () => {
  const fonte = await lerFonte("app/admin/aulas/page.tsx");
  assert.ok(fonte.includes("window.setInterval"), "deve fazer polling periódico");
  assert.match(fonte, /return \(\) => window\.clearInterval\(intervalo\);/, "o efeito deve limpar o interval — nunca deixar polling vazando entre navegações");
});

test("I) app/admin/aulas/page.tsx: só invoca gerar-aula — nunca finalizar-geracao-aula nem a OpenAI diretamente", async () => {
  const fonte = await lerFonte("app/admin/aulas/page.tsx");
  assert.ok(fonte.includes('functions.invoke("gerar-aula"'), "deve continuar chamando só o iniciador");
  // Checa INVOCAÇÃO real do finalizador, não a menção em comentário que
  // só situa onde o finalizador vive, para contexto de quem lê o código.
  assert.ok(!fonte.includes('invoke("finalizar-geracao-aula"'), "o browser nunca deve invocar o finalizador");
  assert.ok(!fonte.includes("api.openai.com"), "o browser nunca deve falar direto com a OpenAI");
  assert.ok(!fonte.includes("jurisprudenciasValidadas"), "este piloto continua sem enviar esse campo (comportamento inalterado)");
});

test("J) supabase/functions/_shared/gerar-aula/ existe como convenção nova de código compartilhado (sem duplicar validador/escopo/jurisprudencia)", async () => {
  const { readdir } = await import("node:fs/promises");
  const arquivos = await readdir(path.join(RAIZ, "supabase/functions/_shared/gerar-aula"));
  for (const nomeEsperado of ["validador.mjs", "escopo.mjs", "jurisprudencia.mjs", "sanitizarErro.mjs", "openaiResponses.mjs", "persistirAulaGerada.mjs"]) {
    assert.ok(arquivos.includes(nomeEsperado), `${nomeEsperado} deve estar em _shared/gerar-aula/`);
  }
  const antigos = await readdir(path.join(RAIZ, "supabase/functions/gerar-aula")).catch(() => []);
  assert.ok(!antigos.includes("validador.mjs"), "não deve sobrar uma cópia duplicada de validador.mjs no diretório antigo");
  assert.ok(!antigos.includes("escopo.mjs"), "não deve sobrar uma cópia duplicada de escopo.mjs no diretório antigo");
  assert.ok(!antigos.includes("jurisprudencia.mjs"), "não deve sobrar uma cópia duplicada de jurisprudencia.mjs no diretório antigo");
});

test("K) migration real (async_geracao_aula.sql) só ACRESCENTA duas colunas — nunca toca no CHECK de status nem no índice de trava", async () => {
  const fonte = await lerFonte("supabase/async_geracao_aula.sql");
  assert.ok(fonte.includes("ADD COLUMN openai_response_id"));
  assert.ok(fonte.includes("ADD COLUMN tentativa_ia"));
  assert.ok(!/DROP\s+CONSTRAINT.*status/i.test(fonte), "não deve alterar o CHECK de status");
  assert.ok(!/DROP\s+INDEX/i.test(fonte), "não deve derrubar nenhum índice, inclusive o de trava existente");
  assert.match(fonte, /CHECK \(tentativa_ia BETWEEN 1 AND 2\)/);
});

test("L) Cron NÃO foi habilitado nesta fase — o artefato preparado está inteiramente comentado", async () => {
  const fonte = await lerFonte("supabase/preparar_cron_finalizar_geracao_aula.sql");
  const linhasComComandoReal = fonte
    .split("\n")
    .filter((linha) => linha.trim().length > 0)
    .filter((linha) => !linha.trim().startsWith("--"));
  assert.equal(linhasComComandoReal.length, 0, "todo o arquivo deve ser comentário — nada aqui pode ser um comando SQL executável");
});

// ---------------------------------------------------------------------
// Fase 4 — auditoria final pré-deploy (expiração/idempotência/tokens).
// ---------------------------------------------------------------------

test("M) gerar-aula/index.ts usa o expirador compartilhado (nunca mais o UPDATE de expiração solto/sem o filtro openai_response_id)", async () => {
  const fonte = await lerFonte("supabase/functions/gerar-aula/index.ts");
  assert.ok(fonte.includes('from "../_shared/gerar-aula/expiracao.mjs"'), "deve importar o expirador compartilhado");
  assert.ok(fonte.includes("expirarGeracoesOrfas("), "deve chamar o expirador em vez de montar o UPDATE inline");
});

test("N) expiracao.mjs só expira geração SEM openai_response_id — nunca uma async genuinamente em voo", async () => {
  const fonte = await lerFonte("supabase/functions/_shared/gerar-aula/expiracao.mjs");
  assert.match(fonte, /\.is\("openai_response_id",\s*null\)/, "o UPDATE de expiração precisa filtrar openai_response_id IS NULL");
});

test("O) finalizar-geracao-aula/index.ts reivindica atomicamente antes de persistir (nunca mais SELECT-depois-decide)", async () => {
  const fonte = await lerFonte("supabase/functions/finalizar-geracao-aula/index.ts");
  assert.ok(fonte.includes('from "../_shared/gerar-aula/idempotencia.mjs"'), "deve importar o reivindicador atômico compartilhado");
  assert.ok(fonte.includes("reivindicarGeracaoParaFinalizar("), "deve reivindicar antes de chamar persistirAulaGerada");
  assert.ok(!fonte.includes('.select("status, aula_versao_id")'), "não pode sobrar o SELECT antigo (TOCTOU) que só lia o estado sem reivindicar atomicamente");
});

test("P) finalizar-geracao-aula/index.ts agrega tokens entre tentativas (nunca sobrescreve o total da tentativa 1 ao avaliar a tentativa 2)", async () => {
  const fonte = await lerFonte("supabase/functions/finalizar-geracao-aula/index.ts");
  assert.ok(fonte.includes('from "../_shared/gerar-aula/tokens.mjs"'), "deve importar o agregador de tokens compartilhado");
  assert.match(fonte, /agregarTokens\(geracao\.tokens_entrada,/, "deve agregar com o total já gravado na linha, lido do próprio SELECT da geração");
  assert.match(fonte, /agregarTokens\(geracao\.tokens_saida,/);
  assert.ok(fonte.includes("tokens_entrada, tokens_saida") || fonte.includes("tokens_entrada,tokens_saida") || /select\(.*tokens_entrada.*tokens_saida/.test(fonte), "o SELECT inicial precisa trazer os tokens já acumulados para poder agregar");
});

// ---------------------------------------------------------------------
// Fase 4.1 — lease recuperável (substitui o claim em finalizado_em).
// ---------------------------------------------------------------------

test("Q) finalizar-geracao-aula/index.ts reivindica por LEASE antes de qualquer trabalho — inclusive antes de consultar a OpenAI", async () => {
  const fonte = await lerFonte("supabase/functions/finalizar-geracao-aula/index.ts");
  assert.ok(fonte.includes('from "../_shared/gerar-aula/idempotencia.mjs"'));
  assert.ok(fonte.includes("reivindicarGeracaoParaFinalizar(") && fonte.includes("liberarLeaseFinalizacao("), "deve importar/usar tanto a reivindicação quanto a liberação da lease");
  const posicaoReivindicacao = fonte.indexOf("reivindicarGeracaoParaFinalizar({ admin, geracaoId: geracao.id })");
  const posicaoBuscarResponse = fonte.indexOf("await buscarResponse(");
  assert.ok(posicaoReivindicacao > -1 && posicaoBuscarResponse > -1 && posicaoReivindicacao < posicaoBuscarResponse, "a reivindicação precisa acontecer ANTES da primeira chamada à OpenAI, protegendo a execução inteira, não só o instante do persist");
});

test("R) finalizar-geracao-aula/index.ts nunca mais usa finalizado_em como marcador de reivindicação (Fase 4 corrigida)", async () => {
  const fonte = await lerFonte("supabase/functions/finalizar-geracao-aula/index.ts");
  assert.ok(!fonte.includes('.is("finalizado_em", null)'), "o filtro antigo baseado em finalizado_em não pode sobrar");
  assert.ok(!fonte.includes("finalizado_em: new Date().toISOString() }).eq(\"id\", geracao.id).eq(\"status\", \"processando\")\n    .is(\"aula_versao_id\""), "não pode sobrar a reivindicação antiga inline");
});

test("S) todo caminho que marca status='erro' também limpa a lease (finalizacao_lease_ate: null) — nunca deixa uma linha terminal com lease pendurada", async () => {
  const fonte = await lerFonte("supabase/functions/finalizar-geracao-aula/index.ts");
  const blocosDeErro = fonte.split(/status: "erro"/).slice(1); // cada elemento começa logo após um `status: "erro"`
  assert.ok(blocosDeErro.length >= 6, "deve haver múltiplos caminhos de erro no arquivo (consulta, provider, sem texto, tentativa 2, submissão de correção, persistência, catch-all)");
  for (const bloco of blocosDeErro) {
    const ateProximoUpdate = bloco.slice(0, 400);
    assert.ok(ateProximoUpdate.includes("finalizacao_lease_ate: null"), `um bloco que marca status='erro' não está limpando a lease: ...${ateProximoUpdate.slice(0, 120)}...`);
  }
});

test("T) queued/in_progress e status desconhecido liberam a lease explicitamente (nunca esperam a lease vencer sozinha)", async () => {
  const fonte = await lerFonte("supabase/functions/finalizar-geracao-aula/index.ts");
  assert.match(fonte, /categoria === "aguardando"\) \{\s*\n\s*await liberarLeaseFinalizacao/, "queued/in_progress devem liberar a lease");
  assert.match(fonte, /categoria === "desconhecido"\) \{[\s\S]{0,500}await liberarLeaseFinalizacao/, "status desconhecido também deve liberar a lease");
});

test("U) correção background (tentativa_ia=1→2) NÃO preenche finalizado_em e libera a lease", async () => {
  const fonte = await lerFonte("supabase/functions/finalizar-geracao-aula/index.ts");
  const trechoCorrecaoSubmetida = fonte.slice(fonte.indexOf("tentativa_ia: 2, tokens_entrada"), fonte.indexOf("tentativa_ia: 2, tokens_entrada") + 200);
  assert.ok(trechoCorrecaoSubmetida.includes("finalizacao_lease_ate: null"), "a atualização de tentativa_ia=2 deve liberar a lease");
  assert.ok(!trechoCorrecaoSubmetida.includes("finalizado_em"), "a atualização de tentativa_ia=2 nunca deve preencher finalizado_em — não é um estado terminal");
});

test("V) persistirAulaGerada.mjs limpa a lease no UPDATE final de sucesso (status='concluida')", async () => {
  const fonte = await lerFonte("supabase/functions/_shared/gerar-aula/persistirAulaGerada.mjs");
  const trechoConclusao = fonte.slice(fonte.indexOf('status: "concluida"'), fonte.indexOf('status: "concluida"') + 800);
  assert.ok(trechoConclusao.includes("finalizacao_lease_ate: null"), "o UPDATE que marca 'concluida' deve limpar a lease");
  assert.ok(trechoConclusao.includes("finalizado_em"), "e continuar preenchendo finalizado_em normalmente (estado terminal real)");
});

test("W) migration nova (async_finalizacao_lease.sql) só adiciona finalizacao_lease_ate — nunca toca na migration async já aplicada nem em status/índice/constraints existentes", async () => {
  const fonte = await lerFonte("supabase/async_finalizacao_lease.sql");
  assert.match(fonte, /ADD COLUMN finalizacao_lease_ate timestamptz NULL/);
  assert.ok(!fonte.includes("openai_response_id"), "não deve tocar na coluna da migration anterior");
  assert.ok(!fonte.includes("tentativa_ia"), "não deve tocar na coluna/constraint da migration anterior");
  assert.ok(!/DROP\s+/i.test(fonte), "não deve derrubar nada");
  // O comentário explicativo pode mencionar "status" em prosa (contexto do
  // problema que motivou a migration) — o que não pode existir é uma DDL
  // real tocando a coluna/constraint de status.
  assert.ok(!/ALTER\s+(TABLE[\s\S]{0,60})?COLUMN\s+status\b/i.test(fonte), "não deve alterar a coluna status");
  assert.ok(!/status_check/i.test(fonte), "não deve tocar na constraint de status");
});

test("X) reverter_async_finalizacao_lease.sql recusa remover a coluna se existir uma lease genuinamente ativa", async () => {
  const fonte = await lerFonte("supabase/reverter_async_finalizacao_lease.sql");
  assert.match(fonte, /finalizacao_lease_ate > now\(\)/);
  assert.match(fonte, /raise exception/i);
  assert.match(fonte, /DROP COLUMN IF EXISTS finalizacao_lease_ate/);
});

test("Y) harness de rollback da lease não repete o erro de SAVEPOINT dentro de DO (lição da fase anterior)", async () => {
  const fonte = await lerFonte("supabase/async_finalizacao_lease_teste_rollback.sql");
  // A palavra "SAVEPOINT" pode aparecer em prosa explicando a lição
  // aprendida — o que não pode existir é o COMANDO real (savepoint x; ou
  // rollback to savepoint x;) fora de comentário.
  const linhasDeComando = fonte
    .split("\n")
    .filter((linha) => !linha.trim().startsWith("--"));
  const usoRealDeSavepoint = linhasDeComando.some((linha) => /\bsavepoint\b/i.test(linha));
  assert.ok(!usoRealDeSavepoint, "não pode existir um comando SAVEPOINT/ROLLBACK TO SAVEPOINT real — não é necessário para esta migration (sem constraint para testar) e já causou um erro real de sintaxe na fase anterior");
  assert.match(fonte, /^BEGIN;/m);
  assert.match(fonte, /^ROLLBACK;/m);
});
