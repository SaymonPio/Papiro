import test from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import { lerRevisaoSolicitada, montarLinkRevisao } from "../utils/missao-cronograma.mjs";

// PAPIRO Beta 1 — revisão executável. Mesma técnica de
// tests/cronometro-livre-estudo-avulso.test.mjs: assert.match/doesNotMatch
// contra o texto REAL dos arquivos (migration SQL + páginas), nunca contra
// uma suposição. Este projeto não tem harness de banco nos testes — os
// cenários que só podem ser confirmados com Postgres real (RLS/constraints
// em execução, concorrência de verdade) estão marcados "[requer banco vivo]"
// e documentados como pendentes no relatório final, não fingidos aqui.
// migracao = fundação (schema aditivo em sessoes_estudo: nivel_meta/
// revisao_ids — nunca tocado pelo hotfix abaixo, continua fonte de
// verdade para isso). hotfix = CREATE OR REPLACE mais recente de
// iniciar_revisao/concluir_revisao (ambiguidade 42702 corrigida,
// 2026-10-10) — fonte de verdade ATUAL dos corpos das duas funções,
// mesmo padrão já usado em tests/cronometro-livre-estudo-avulso.test.mjs
// para migration + hotfix incremental.
const migracao = await readFile(
  new URL("../supabase/migrations/20261008120000_revisao_executavel.sql", import.meta.url),
  "utf8",
);
const hotfix = await readFile(
  new URL("../supabase/migrations/20261010120000_corrigir_ambiguidade_revisao.sql", import.meta.url),
  "utf8",
);
const questoesPage = await readFile(new URL("../app/questoes/page.tsx", import.meta.url), "utf8");
const resultadoPage = await readFile(new URL("../app/questoes/resultado/page.tsx", import.meta.url), "utf8");
const cadernoPage = await readFile(new URL("../app/caderno-de-erros/page.tsx", import.meta.url), "utf8");
const cronogramaPage = await readFile(new URL("../app/cronograma/page.tsx", import.meta.url), "utf8");

const corpoIniciar = hotfix.slice(
  hotfix.indexOf("function public.iniciar_revisao"),
  hotfix.indexOf("$function$;", hotfix.indexOf("function public.iniciar_revisao")),
);
const corpoConcluir = hotfix.slice(
  hotfix.indexOf("function public.concluir_revisao"),
  hotfix.indexOf("$function$;", hotfix.indexOf("function public.concluir_revisao")),
);

// ============================================================================
// 1/2/3. usuário sem revisão / com revisão pendente (futura) / vencida
// ============================================================================

test("1. usuário sem nenhuma revisão pendente/vencida recebe erro explícito do servidor (nunca uma sessão vazia)", () => {
  assert.match(corpoIniciar, /if coalesce\(cardinality\(v_revisao_ids\), 0\) = 0 then\s*\n\s*raise exception 'Nenhuma revisao pendente para hoje';/);
  // Frontend traduz essa mensagem específica para um texto amigável, sem inventar uma segunda regra:
  assert.match(questoesPage, /nenhuma revisao pendente/i);
  assert.match(questoesPage, /Você não tem nenhuma revisão pendente agora\./);
});

test("2. revisão futura (agendada_para > hoje) NÃO entra na seleção do servidor", () => {
  assert.match(corpoIniciar, /rv\.status = 'pendente'\s*\n\s*and rv\.agendada_para <= current_date/);
  // Mesma regra mirrorada em JS contra um dataset fake — testa o COMPORTAMENTO, não só a string:
  function elegivel(status, agendadaPara, hoje) {
    return status === "pendente" && agendadaPara <= hoje;
  }
  assert.equal(elegivel("pendente", "2026-10-09", "2026-10-08"), false, "revisão agendada para o futuro não é devida hoje");
});

test("3. revisão vencida (agendada_para < hoje) entra na seleção — \"<=\", nunca \"=\" estrito", () => {
  function elegivel(status, agendadaPara, hoje) {
    return status === "pendente" && agendadaPara <= hoje;
  }
  assert.equal(elegivel("pendente", "2026-10-01", "2026-10-08"), true, "revisão vencida há dias continua devida");
  assert.equal(elegivel("pendente", "2026-10-08", "2026-10-08"), true, "revisão devida hoje é incluída");
  assert.equal(elegivel("concluida", "2026-10-01", "2026-10-08"), false, "revisão já concluída nunca volta a aparecer");
});

test("1/2/3 (CTA caderno de erros): só aparece quando existe revisão pendente com agendada_para <= hoje — mesma regra de 'vencida' já usada em app/estatisticas/app/cronograma, sem critério novo", () => {
  assert.match(cadernoPage, /function dataLocal\(data: Date\)/);
  assert.match(cadernoPage, /erro\.revisoes\.some\(\(revisao\) => revisao\.status === "pendente" && revisao\.agendada_para <= hojeChave\)/);

  // Mirror da mesma regra, avaliada em JS para os casos que importam:
  function existeRevisaoDevida(erros, hoje) {
    return erros.some((erro) => erro.revisoes.some((r) => r.status === "pendente" && r.agendada_para <= hoje));
  }
  assert.equal(existeRevisaoDevida([], "2026-10-08"), false, "sem erros, CTA não aparece");
  assert.equal(
    existeRevisaoDevida([{ revisoes: [{ status: "pendente", agendada_para: "2026-10-09" }] }], "2026-10-08"),
    false,
    "só revisão futura, CTA não aparece",
  );
  assert.equal(
    existeRevisaoDevida([{ revisoes: [{ status: "pendente", agendada_para: "2026-10-01" }] }], "2026-10-08"),
    true,
    "revisão vencida faz o CTA aparecer",
  );
  assert.equal(
    existeRevisaoDevida([{ revisoes: [{ status: "concluida", agendada_para: "2026-10-01" }] }], "2026-10-08"),
    false,
    "revisão já concluída não conta",
  );
});

// ============================================================================
// 4. iniciar revisão — identidade 100% server-side, nenhum id vindo do cliente
// ============================================================================

test("4. iniciar_revisao() não recebe nenhum parâmetro do cliente — toda seleção (curso/matrícula/revisões/questões) é resolvida a partir de auth.uid()", () => {
  assert.match(migracao, /create or replace function public\.iniciar_revisao\(\)/);
  assert.match(questoesPage, /supabase\.rpc\("iniciar_revisao"\)/);
  // nunca com um segundo argumento de parâmetros, ao contrário das outras RPCs de início (que recebem p_missao_id/p_materia_id/etc.):
  assert.doesNotMatch(questoesPage, /supabase\.rpc\("iniciar_revisao",/);
  assert.match(corpoIniciar, /v_usuario_id uuid := auth\.uid\(\)/);
  assert.match(corpoIniciar, /if v_usuario_id is null then\s*\n\s*raise exception 'Usuario nao autenticado';/);
});

test("4. iniciar revisão nunca mistura com os parâmetros de missão (origem=cronograma/unidade/missaoFinal) — rota própria, exclusiva", () => {
  assert.equal(lerRevisaoSolicitada("revisao=1"), true);
  assert.equal(lerRevisaoSolicitada(""), false);
  assert.equal(lerRevisaoSolicitada("origem=cronograma&materia=7"), false);
  assert.equal(montarLinkRevisao(), "/questoes?revisao=1");
});

// ============================================================================
// 5/6/7. responder corretamente / incorretamente / classificar erro —
// motor de questões 100% reaproveitado, nenhum mecanismo paralelo.
// ============================================================================

test("5/6. responder() chama registrar_resposta sem nenhuma ramificação por nivel — revisão usa exatamente o mesmo caminho de missão/avulsa/unidade", () => {
  const corpoResponder = questoesPage.slice(questoesPage.indexOf("async function responder()"), questoesPage.indexOf("function alternarAlternativaEliminada"));
  assert.match(corpoResponder, /supabase\.rpc\("registrar_resposta", \{/);
  assert.doesNotMatch(corpoResponder, /nivel === "revisao"/, "registrar_resposta nao pode ter um ramo especial para revisao — reuso tem que ser total");
});

test("7. diagnóstico obrigatório ao errar continua bloqueando \"Próxima\"/\"Ver resultado\" também na revisão (mesmo gate, sem exceção por nivel)", () => {
  assert.match(questoesPage, /disabled=\{!feedback\.acertou && !classificado\}/);
  const corpoClassificar = questoesPage.slice(questoesPage.indexOf("async function classificarErro"), questoesPage.indexOf("async function proxima()"));
  assert.match(corpoClassificar, /supabase\.rpc\("classificar_erro", \{/);
  assert.doesNotMatch(corpoClassificar, /nivel === "revisao"/, "classificar_erro nao pode ter um ramo especial para revisao — reuso tem que ser total");
});

// ============================================================================
// 8. reload durante revisão — recuperação idempotente (servidor) + ?sessaoAvulsa= (cliente)
// ============================================================================

test("8. iniciar_revisao() é idempotente: recupera a sessão em_andamento existente ANTES de considerar criar uma nova (trava a linha, nunca duplica)", () => {
  assert.match(corpoIniciar, /and s\.status = 'em_andamento'\s*\n\s*and s\.nivel_meta = 'revisao'/);
  assert.match(corpoIniciar, /for update;/);
  assert.match(corpoIniciar, /if v_sessao_id is not null then/);
  // a recuperação devolve ANTES do bloco que seleciona revisões pendentes e insere uma sessão nova:
  const indiceRecuperacao = corpoIniciar.indexOf("if v_sessao_id is not null then");
  const indiceInsert = corpoIniciar.indexOf("insert into public.sessoes_estudo");
  assert.ok(indiceRecuperacao > -1 && indiceInsert > -1 && indiceRecuperacao < indiceInsert, "recuperacao idempotente precisa vir antes do INSERT de uma sessao nova");
});

test("8. após criar/recuperar, a sessão de revisão entra no MESMO mecanismo de recuperação por ?sessaoAvulsa= usado por toda sessão avulsa (nenhum mecanismo de F5 próprio)", () => {
  assert.match(questoesPage, /atualizarUrlSessaoAvulsa\(Number\(linha\.sessao_id\)\)/);
  assert.match(questoesPage, /function atualizarUrlSessaoAvulsa\(sessaoId: number\)/);
});

// ============================================================================
// 9/10. conclusão normal / tentativa de concluir de novo (idempotência)
// ============================================================================

test("9. concluir_revisao() exige TODAS as questões planejadas respondidas antes de concluir — cobertura REAL por questão, não contagem agregada (corrigido na auditoria pré-apply)", () => {
  assert.match(
    corpoConcluir,
    /if exists \(\s*\n\s*select 1\s*\n\s*from public\.sessao_questoes_planejadas sq\s*\n\s*where sq\.sessao_id = p_sessao_id\s*\n\s*and not exists \(\s*\n\s*select 1\s*\n\s*from public\.respostas_usuarios ru\s*\n\s*where ru\.sessao_id = sq\.sessao_id\s*\n\s*and ru\.usuario_id = v_usuario_id\s*\n\s*and ru\.questao_id = sq\.questao_id\s*\n\s*\)\s*\n\s*\) then\s*\n\s*raise exception 'Responda todas as questoes planejadas antes de concluir a revisao';/,
  );
  // a contagem agregada antiga (COUNT(*) comparando totais) nao existe mais:
  assert.doesNotMatch(corpoConcluir, /v_total_respondidas/);
  assert.doesNotMatch(corpoConcluir, /v_total_planejadas/);
});

test("10. concluir_revisao() chamada numa sessão já concluída não reabre nem reprocessa — só devolve o resultado já gravado", () => {
  assert.match(corpoConcluir, /if v_sessao\.status = 'concluida' then/);
  const trechoIdempotente = corpoConcluir.slice(corpoConcluir.indexOf("if v_sessao.status = 'concluida' then"), corpoConcluir.indexOf("return;", corpoConcluir.indexOf("if v_sessao.status = 'concluida' then")));
  assert.doesNotMatch(trechoIdempotente, /update public\.revisoes/, "conclusao repetida nao pode reprocessar revisoes");
  assert.doesNotMatch(trechoIdempotente, /update public\.sessoes_estudo/, "conclusao repetida nao pode reabrir/reescrever a sessao");
});

// ============================================================================
// 11/12. isolamento — revisão de outro usuário / matrícula inativa
// ============================================================================

test("11. concluir_revisao() só encontra a sessão se usuario_id = auth.uid() — revisão/sessão de outro usuário é recusada (não encontrada, nunca um erro de permissão que confirme a existência)", () => {
  assert.match(corpoConcluir, /where s\.id = p_sessao_id\s*\n\s*and s\.usuario_id = v_usuario_id\s*\n\s*and s\.nivel_meta = 'revisao'/);
  assert.match(corpoConcluir, /if not found then\s*\n\s*raise exception 'Sessao de revisao nao encontrada';/);
});

test("11. o UPDATE em public.revisoes dentro do loop também é filtrado por usuario_id — defesa em profundidade, não só a leitura inicial", () => {
  assert.match(corpoConcluir, /update public\.revisoes as rv\s*\n\s*set status = 'concluida',\s*\n\s*concluida_em = now\(\),\s*\n\s*desempenho_pos_revisao = case when v_acertou then 1 else 0 end\s*\n\s*where rv\.id = v_revisao_id\s*\n\s*and rv\.usuario_id = v_usuario_id\s*\n\s*and rv\.status = 'pendente'/);
});

test("12. matrícula inativa (ou curso ativo sem matrícula 'ativa') é recusada antes de qualquer seleção de revisão", () => {
  assert.match(corpoIniciar, /and m\.status = 'ativa';/);
  assert.match(corpoIniciar, /if v_matricula_id is null then\s*\n\s*raise exception 'Matricula ativa no curso ativo nao encontrada';/);
  // essa checagem vem ANTES de qualquer leitura de public.revisoes:
  const indiceMatricula = corpoIniciar.indexOf("Matricula ativa no curso ativo nao encontrada");
  const indiceRevisoes = corpoIniciar.indexOf("from public.revisoes");
  assert.ok(indiceMatricula < indiceRevisoes);
});

// ============================================================================
// 13/14. horas líquidas — reaproveitamento total do motor existente
// ============================================================================

test("13. tempo líquido da revisão é contabilizado com tipoAtividade='revisao' (TipoAtividadeSessaoTempo já aceitava este valor antes desta feature)", () => {
  assert.match(questoesPage, /tipoAtividade: nivel === "revisao" \? "revisao" : "questoes"/);
  assert.doesNotMatch(questoesPage, /useSessaoTempo\(\{[^}]*tipoAtividade: "revisao"/s, "tipoAtividade nao pode ser fixo 'revisao' — so quando nivel realmente for revisao, nunca para as demais sessoes de questoes");
});

test("14. a sessão de tempo é encerrada (encerrarEstudo) ANTES do redirect, especificamente dentro do ramo de conclusão da revisão", () => {
  const ramoRevisao = questoesPage.slice(questoesPage.indexOf('if (nivel === "revisao") {'), questoesPage.indexOf('if (missionId) {', questoesPage.indexOf('if (nivel === "revisao") {')));
  assert.match(ramoRevisao, /await sessaoTempo\.encerrarEstudo\(\);/);
  const indiceEncerrar = ramoRevisao.indexOf("sessaoTempo.encerrarEstudo()");
  const indiceRedirect = ramoRevisao.indexOf("window.location.replace");
  assert.ok(indiceEncerrar > -1 && indiceRedirect > -1 && indiceEncerrar < indiceRedirect, "encerrarEstudo precisa rodar antes do redirect, nunca depois");
});

test("13/14. nenhum outro cronômetro foi criado — useSessaoTempo continua sendo chamado uma única vez em app/questoes/page.tsx", () => {
  assert.equal((questoesPage.match(/\buseSessaoTempo\(/g) ?? []).length, 1);
});

// ============================================================================
// 15/16/17/18. regressão — nada que já funcionava foi tocado
// ============================================================================

test("15. estatísticas/consultas existentes (erros_do_curso_ativo, revisoes_do_curso_ativo, estatisticas_do_curso_ativo) não foram redefinidas por esta migration — continuam lendo revisoes genericamente e refletem as conclusões automaticamente", () => {
  for (const fn of ["erros_do_curso_ativo", "revisoes_do_curso_ativo", "estatisticas_do_curso_ativo"]) {
    assert.doesNotMatch(migracao, new RegExp(`create or replace function public\\.${fn}`));
  }
});

test("15/16. registrar_resposta e classificar_erro não foram tocados — a migration nem os menciona como DEFINIÇÃO (só reaproveita o resultado de registrar_resposta na leitura de respostas_usuarios)", () => {
  assert.doesNotMatch(migracao, /create or replace function public\.registrar_resposta/);
  assert.doesNotMatch(migracao, /create or replace function public\.classificar_erro/);
});

test("17. questões avulsas (iniciar_sessao_questoes_avulsa) continuam presentes e intocadas — nenhuma RPC paralela substituiu seu uso", () => {
  assert.match(questoesPage, /supabase\.rpc\("iniciar_sessao_questoes_avulsa", \{/);
});

test("18. missão diária e missão final (iniciar_questoes_da_missao, concluir_questoes_da_missao, iniciar_missao_final, concluir_missao_final) continuam presentes e intocadas", () => {
  for (const rpc of ["iniciar_questoes_da_missao", "concluir_questoes_da_missao", "iniciar_missao_final", "concluir_missao_final"]) {
    assert.match(questoesPage, new RegExp(`"${rpc}"`));
  }
});

test("prática por unidade (iniciar_pratica_unidade/concluir_pratica_unidade) continua presente e intocada", () => {
  assert.match(questoesPage, /"iniciar_pratica_unidade"/);
  assert.match(questoesPage, /"concluir_pratica_unidade"/);
});

test("rollback documentado no cabeçalho da migration é reversível e não é executado por ela (só comentário)", () => {
  const cabecalho = migracao.slice(0, migracao.indexOf("-- 1) Schema aditivo"));
  assert.match(cabecalho, /drop function if exists public\.concluir_revisao\(bigint\);/);
  assert.match(cabecalho, /drop function if exists public\.iniciar_revisao\(\);/);
  assert.match(cabecalho, /alter table public\.sessoes_estudo drop column if exists revisao_ids;/);
  // as linhas de rollback estão comentadas (prefixo "--"), nunca executadas:
  for (const linha of cabecalho.split("\n")) {
    if (linha.includes("drop function") || linha.includes("drop column") || linha.includes("drop constraint")) {
      assert.match(linha, /^--/, `linha de rollback deve estar comentada: ${linha}`);
    }
  }
});

test("grants: iniciar_revisao/concluir_revisao são authenticated-only, nunca public/anon", () => {
  assert.match(migracao, /revoke all on function public\.iniciar_revisao\(\) from public, anon;/);
  assert.match(migracao, /grant execute on function public\.iniciar_revisao\(\) to authenticated;/);
  assert.match(migracao, /revoke all on function public\.concluir_revisao\(bigint\) from public, anon;/);
  assert.match(migracao, /grant execute on function public\.concluir_revisao\(bigint\) to authenticated;/);
});

test("ambas as RPCs são SECURITY DEFINER com search_path travado (mesmo endurecimento das demais RPCs do projeto)", () => {
  for (const corpo of [corpoIniciar, corpoConcluir]) {
    assert.match(corpo, /security definer/);
    assert.match(corpo, /set search_path to ''/);
  }
});

// ============================================================================
// Tela de resultado — estado dedicado "revisão já concluída"
// ============================================================================

test("resultado de revisão tem ramo dedicado (nivel_meta='revisao'), nunca cai no genérico MISSÃO/SESSÃO CONCLUÍDA, e volta ao caderno de erros", () => {
  assert.match(resultadoPage, /resultado\.nivel_meta === "revisao"/);
  assert.match(resultadoPage, /REVISÃO CONCLUÍDA/);
  const ramoRevisao = resultadoPage.slice(resultadoPage.indexOf('if (resultado.nivel_meta === "revisao")'), resultadoPage.indexOf("return (\n    <main", resultadoPage.indexOf('if (resultado.nivel_meta === "revisao")') + 1));
  assert.match(ramoRevisao, /href="\/caderno-de-erros"/);
});

test("nivel_meta já era lido pela query existente — nenhuma mudança de schema/tipo foi necessária nesta página", () => {
  assert.match(resultadoPage, /questoes_respondidas, acertos, nivel_meta, minutos_revisao, missao_id, unidade_pedagogica_id, tipo_pratica/);
});

// ============================================================================
// Entradas — cronograma: CTA só no bloco de HOJE, nunca em dias futuros
// ============================================================================

test("cronograma: CTA 'Iniciar revisão' só é marcado no bloco do dia de HOJE (indice 0) quando há revisão devida — dias futuros do plano nunca ganham o CTA (são só planejamento)", () => {
  assert.match(cronogramaPage, /temRevisaoExecutavel: indice === 0 && temRevisao,/);
  assert.match(cronogramaPage, /bloco\.temRevisaoExecutavel && \(/);
  assert.match(cronogramaPage, /href=\{montarLinkRevisao\(\)\}/);
});

// ============================================================================
// CORREÇÃO PRÉ-APPLY — os 7 testes obrigatórios pedidos na auditoria antes
// do primeiro db push (numeração própria desta seção, 1-7, independente da
// numeração 1-18 do Beta 1 original).
// ============================================================================

test("correção 1. 2 questões planejadas, 2 respostas duplicadas da questão A, nenhuma resposta da B → a cobertura REAL (mirror em JS do NOT EXISTS) reprova, mesmo com respondidas >= planejadas em contagem agregada", () => {
  // Mirror fiel do predicado SQL: para cada questao_id planejada, precisa
  // existir ao menos 1 resposta do usuário NESTA sessão.
  function todasPlanejadasRespondidas(planejadas, respostas) {
    return planejadas.every((p) => respostas.some((r) => r.questao_id === p.questao_id));
  }

  const planejadas = [{ questao_id: "A" }, { questao_id: "B" }];
  const respostasComDuplicataEBFaltando = [
    { questao_id: "A", respondida_em: "2026-10-10T10:00:00Z" },
    { questao_id: "A", respondida_em: "2026-10-10T10:01:00Z" }, // 2ª resposta da MESMA questão A
  ];
  // Contagem agregada (regra antiga, removida): 2 respostas >= 2 planejadas passaria.
  assert.equal(respostasComDuplicataEBFaltando.length >= planejadas.length, true, "contagem agregada antiga teria deixado passar");
  // Cobertura real (regra nova): B nunca foi respondida — reprova.
  assert.equal(todasPlanejadasRespondidas(planejadas, respostasComDuplicataEBFaltando), false, "B nunca respondida — concluir_revisao deve falhar");

  const respostasCompletas = [
    { questao_id: "A", respondida_em: "2026-10-10T10:00:00Z" },
    { questao_id: "B", respondida_em: "2026-10-10T10:02:00Z" },
  ];
  assert.equal(todasPlanejadasRespondidas(planejadas, respostasCompletas), true, "com as duas respondidas, a cobertura real aprova normalmente");
});

test("correção 2. questão planejada sem resposta: a exception da cobertura vem ANTES do loop/UPDATE — nenhuma revisão desta sessão muda de status (falha atômica, não parcial)", () => {
  const indiceCobertura = corpoConcluir.indexOf("raise exception 'Responda todas as questoes planejadas antes de concluir a revisao'");
  const indiceLoop = corpoConcluir.indexOf("foreach v_revisao_id in array v_sessao.revisao_ids loop");
  const indiceUpdateRevisoes = corpoConcluir.lastIndexOf("update public.revisoes");
  assert.ok(indiceCobertura > -1 && indiceLoop > -1 && indiceUpdateRevisoes > -1, "todas as 3 âncoras precisam existir no corpo de concluir_revisao");
  assert.ok(
    indiceCobertura < indiceLoop && indiceLoop < indiceUpdateRevisoes,
    "a checagem de cobertura precisa abortar a FUNÇÃO (e a transação) antes de qualquer UPDATE em public.revisoes — uma exception em plpgsql aborta a chamada inteira, nunca so uma revisao",
  );
});

test("correção 3. desempenho_pos_revisao nunca herda valor da iteração anterior do loop — v_questao_id/v_acertou são reiniciados a NULL a cada volta, com exception se a busca não encontrar nada", () => {
  const corpoLoop = corpoConcluir.slice(corpoConcluir.indexOf("foreach v_revisao_id"), corpoConcluir.indexOf("end loop;"));
  assert.match(corpoLoop, /v_questao_id := null;\s*\n\s*v_acertou := null;/);
  assert.match(corpoLoop, /if v_questao_id is null then\s*\n\s*raise exception 'Revisao % sem questao associada \(erro_id invalido\)', v_revisao_id;/);
  assert.match(corpoLoop, /if v_acertou is null then\s*\n\s*raise exception 'Questao % da revisao % sem resposta registrada nesta sessao', v_questao_id, v_revisao_id;/);
  // o reset vem ANTES das duas buscas (senão reiniciaria o valor que a própria busca desta iteração acabou de achar):
  const indiceReset = corpoLoop.indexOf("v_questao_id := null;");
  const indiceBuscaQuestao = corpoLoop.indexOf("select eu.questao_id into v_questao_id");
  const indiceBuscaAcertou = corpoLoop.indexOf("select ru.acertou into v_acertou");
  assert.ok(indiceReset < indiceBuscaQuestao && indiceBuscaQuestao < indiceBuscaAcertou);
});

test("correção 4. iniciar_revisao serializa a ABERTURA (não só a recuperação): pg_advisory_xact_lock é adquirido ANTES da leitura de sessão existente e ANTES do INSERT de uma nova — [parte requer banco vivo: duas transações concorrentes reais]", () => {
  assert.match(corpoIniciar, /perform pg_advisory_xact_lock\(\s*\n\s*hashtextextended\('revisao:' \|\| v_usuario_id::text \|\| ':' \|\| v_matricula_id::text, 0\)\s*\n\s*\);/);
  const indiceLock = corpoIniciar.indexOf("perform pg_advisory_xact_lock(");
  const indiceRecuperacao = corpoIniciar.indexOf("select s.id, s.status");
  const indiceInsert = corpoIniciar.indexOf("insert into public.sessoes_estudo");
  assert.ok(indiceLock > -1 && indiceRecuperacao > -1 && indiceInsert > -1);
  assert.ok(indiceLock < indiceRecuperacao && indiceRecuperacao < indiceInsert, "o lock precisa cobrir tanto a releitura quanto o INSERT — travar só depois de ja ter lido nao serializa nada");
  // nenhum índice/constraint global novo foi criado para isso (pedido explícito — não afetar outros nivel_meta):
  assert.doesNotMatch(migracao, /create unique index/);
});

test("correção 5. retry após sessão já criada continua recuperando a MESMA sessão (recuperada=true) mesmo com o lock novo — idempotência preservada", () => {
  const indiceRecuperacao = corpoIniciar.indexOf("if v_sessao_id is not null then");
  const indiceSelecaoRevisoesPendentes = corpoIniciar.indexOf("from public.revisoes rv");
  assert.ok(indiceRecuperacao > -1 && indiceSelecaoRevisoesPendentes > -1);
  const trechoRecuperacao = corpoIniciar.slice(indiceRecuperacao, indiceSelecaoRevisoesPendentes);
  assert.match(trechoRecuperacao, /return query select v_sessao_id, v_status, v_questao_ids, true;/);
  // o lock está ANTES deste bloco (testado na correção 4) — aqui só confirma que o bloco de recuperação em si não foi alterado pela correção.
});

test("correção 6. revisão criada DURANTE a sessão (erro novo registrado por registrar_resposta) permanece fora de revisao_ids — nunca recalculado após a criação da sessão", () => {
  // revisao_ids só é escrito UMA vez, no INSERT de iniciar_revisao — nenhum UPDATE em sessoes_estudo.revisao_ids em lugar nenhum da migration:
  assert.doesNotMatch(migracao, /update public\.sessoes_estudo\s*\n\s*set[^;]*revisao_ids/s);
  assert.equal((migracao.match(/revisao_ids/g) ?? []).length > 0, true);
  // a única escrita de revisao_ids é a coluna no INSERT de iniciar_revisao:
  assert.match(corpoIniciar, /insert into public\.sessoes_estudo as se \(\s*\n\s*usuario_id, matricula_id, nivel_meta, status,\s*\n\s*inicio_em, minutos_revisao, questoes_planejadas, revisao_ids/);
});

test("decisão confirmada (opção B): a seleção usa 'distinct on (rv.erro_id) ... order by rv.erro_id, rv.ordem' — no máximo 1 marco por erro entra na sessão, os demais continuam pendentes", () => {
  assert.match(corpoIniciar, /select distinct on \(rv\.erro_id\) rv\.id/);
  assert.match(corpoIniciar, /order by rv\.erro_id, rv\.ordem/);
  // a seleção continua filtrando pendente + vencida, só que agora dentro dessa subquery:
  assert.match(corpoIniciar, /select distinct on \(rv\.erro_id\) rv\.id[\s\S]*?where rv\.usuario_id = v_usuario_id[\s\S]*?and rv\.status = 'pendente'[\s\S]*?and rv\.agendada_para <= current_date/);
});

test("decisão confirmada (opção B): mirror em JS — 3 marcos vencidos do MESMO erro geram só 1 selecionado (o de menor ordem); os outros 2 continuam pendentes para uma próxima sessão", () => {
  // Mesma técnica de "distinct on ... order by" avaliada em JS contra um dataset fake.
  function selecionarUmMarcoPorErro(revisoes, hoje) {
    const elegiveis = revisoes.filter((r) => r.status === "pendente" && r.agendada_para <= hoje);
    const porErro = new Map();
    for (const r of elegiveis) {
      const atual = porErro.get(r.erro_id);
      if (!atual || r.ordem < atual.ordem) porErro.set(r.erro_id, r);
    }
    return [...porErro.values()];
  }

  const tresMarcosMesmoErroTodosVencidos = [
    { erro_id: "E1", ordem: 1, agendada_para: "2026-09-10", status: "pendente" },
    { erro_id: "E1", ordem: 2, agendada_para: "2026-09-16", status: "pendente" },
    { erro_id: "E1", ordem: 3, agendada_para: "2026-10-09", status: "pendente" },
  ];
  const selecionados = selecionarUmMarcoPorErro(tresMarcosMesmoErroTodosVencidos, "2026-10-10");
  assert.equal(selecionados.length, 1, "só 1 marco do erro E1 deve entrar nesta sessão, mesmo com os 3 vencidos");
  assert.equal(selecionados[0].ordem, 1, "o marco escolhido é o de menor ordem (o mais antigo vencido)");

  // erro já parcialmente revisado (ordem 1 concluída antes) — escolhe o próximo pendente (ordem 2), nunca reabre a ordem 1:
  const ordem1JaConcluida = [
    { erro_id: "E1", ordem: 1, agendada_para: "2026-09-10", status: "concluida" },
    { erro_id: "E1", ordem: 2, agendada_para: "2026-09-16", status: "pendente" },
    { erro_id: "E1", ordem: 3, agendada_para: "2026-10-09", status: "pendente" },
  ];
  const selecionados2 = selecionarUmMarcoPorErro(ordem1JaConcluida, "2026-10-10");
  assert.equal(selecionados2.length, 1);
  assert.equal(selecionados2[0].ordem, 2, "com ordem 1 já concluída, o próximo marco pendente (ordem 2) é o escolhido");

  // dois erros DIFERENTES, cada um contribuindo seu próprio marco — nenhum colapso entre erros distintos nesta etapa:
  const doisErrosDistintos = [
    { erro_id: "E1", ordem: 1, agendada_para: "2026-10-01", status: "pendente" },
    { erro_id: "E2", ordem: 1, agendada_para: "2026-10-05", status: "pendente" },
  ];
  assert.equal(selecionarUmMarcoPorErro(doisErrosDistintos, "2026-10-10").length, 2, "erros diferentes nunca colapsam entre si nesta etapa — o colapso por questao_id repetida acontece depois, na etapa seguinte");
});

test("correção 7. conclusão repetida continua idempotente após as correções (bloco de early-return não foi tocado)", () => {
  assert.match(corpoConcluir, /if v_sessao\.status = 'concluida' then/);
  const trechoIdempotente = corpoConcluir.slice(corpoConcluir.indexOf("if v_sessao.status = 'concluida' then"), corpoConcluir.indexOf("return;", corpoConcluir.indexOf("if v_sessao.status = 'concluida' then")));
  assert.doesNotMatch(trechoIdempotente, /update public\.revisoes/);
  assert.doesNotMatch(trechoIdempotente, /update public\.sessoes_estudo/);
});

// ============================================================================
// HOTFIX 42702 — "column reference \"status\" is ambiguous". RETURNS TABLE
// declara sessao_id/status/questao_ids/recuperada (iniciar_revisao) e
// sessao_id/status/revisoes_concluidas (concluir_revisao) como variáveis de
// saída visíveis em toda a função — qualquer "status" sem qualificação de
// tabela/alias colide com elas. Os 3 testes abaixo fixam exatamente os 3
// pontos corrigidos (nenhum outro foi tocado) e travam contra a regressão
// óbvia: a forma ANTIGA, sem alias, não pode reaparecer em nenhum dos dois
// corpos.
// ============================================================================

test("hotfix 42702 (1/3): INSERT...RETURNING de iniciar_revisao() usa alias 'se' e qualifica se.id/se.status — nunca 'status' sem qualificação na RETURNING", () => {
  assert.match(corpoIniciar, /insert into public\.sessoes_estudo as se \(/);
  assert.match(corpoIniciar, /returning se\.id, se\.status into v_sessao_id, v_status;/);
  assert.doesNotMatch(corpoIniciar, /\)\s*returning id, status into/, "a forma antiga (sem alias) nao pode reaparecer");
});

test("hotfix 42702 (2/3): SELECT COUNT do ramo idempotente de concluir_revisao() usa alias 'rv' e qualifica rv.id/rv.status", () => {
  assert.match(corpoConcluir, /from public\.revisoes rv\s*\n\s*where rv\.id = any\(v_sessao\.revisao_ids\) and rv\.status = 'concluida';/);
  assert.doesNotMatch(corpoConcluir, /from public\.revisoes\s*\n\s*where id = any\(v_sessao\.revisao_ids\) and status = 'concluida';/, "a forma antiga (sem alias) nao pode reaparecer");
});

test("hotfix 42702 (3/3): UPDATE dentro do loop de concluir_revisao() usa alias 'rv' na tabela-alvo e qualifica toda a WHERE — SET permanece sem alias (sintaxe fixa do UPDATE, nunca foi ambígua)", () => {
  assert.match(corpoConcluir, /update public\.revisoes as rv\s*\n\s*set status = 'concluida',/);
  assert.match(corpoConcluir, /where rv\.id = v_revisao_id\s*\n\s*and rv\.usuario_id = v_usuario_id\s*\n\s*and rv\.status = 'pendente';/);
  assert.doesNotMatch(corpoConcluir, /update public\.revisoes\s*\n\s*set status = 'concluida',[\s\S]*?where id = v_revisao_id/, "a forma antiga (sem alias) nao pode reaparecer");
});

// ============================================================================
// [requer banco vivo] — não verificável nesta sessão (Supabase MCP
// desconectado; sem harness de Postgres nos testes deste projeto). Listado
// explicitamente para constar no relatório final, não varrido para debaixo
// do tapete.
// ============================================================================

test("[requer banco vivo] concorrência REAL de iniciar_revisao (duas transações Postgres de fato simultâneas) só pode ser confirmada contra um banco vivo — aqui só a posição do lock no texto é verificada (correção 4)", () => {
  assert.match(corpoIniciar, /pg_advisory_xact_lock/); // mecanismo existe e está posicionado corretamente (ver correção 4); a serialização de verdade exige 2 conexões reais.
});
