import test from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

const assoc = await readFile(new URL("../supabase/questao_unidades_pedagogicas.sql", import.meta.url), "utf8");
const rpc = await readFile(new URL("../supabase/missao_pratica_papiro_rpc.sql", import.meta.url), "utf8");
const harness = await readFile(new URL("../supabase/missao_pratica_papiro_teste_rollback.sql", import.meta.url), "utf8");
const teoria = await readFile(new URL("../app/teoria/page.tsx", import.meta.url), "utf8");
const questoes = await readFile(new URL("../app/questoes/page.tsx", import.meta.url), "utf8");
const resultado = await readFile(new URL("../app/questoes/resultado/page.tsx", import.meta.url), "utf8");
const cronograma = await readFile(new URL("../utils/missao-cronograma.mjs", import.meta.url), "utf8");

// Nenhum destes testes chama o banco ou a OpenAI — validam só o texto real
// das migrations/RPCs/telas (mesmo padrão já usado em
// missao-questoes-progresso.test.mjs e unidades-pedagogicas-progresso.test.mjs
// deste projeto).

// O harness embute uma cópia do corpo das 2 migrations (sem o COMMIT final)
// para poder recriá-las dentro de BEGIN/ROLLBACK. Essa cópia já ficou
// desatualizada uma vez (assinatura antiga de selecionar_candidatas_
// unidade_pedagogica_id, sem p_missao_id) depois que a migration real foi
// alterada, causando SQLSTATE 42883 (function does not exist) direto no
// Supabase — nenhum teste local pegou isso porque nenhum dos testes acima
// compara o CONTEÚDO da cópia embutida com o arquivo real, só padrões
// isolados. Estas duas funções/testes existem para nunca mais deixar as
// cópias divergirem silenciosamente: extraem o corpo real (entre BEGIN; e
// COMMIT;) e o corpo embutido (entre os marcadores "CORPO DE ..." do
// harness) e comparam IGUALDADE EXATA, não só presença de trechos.
function extrairCorpoReal(sqlDaMigration) {
  const inicioMarcador = "\nBEGIN;\n";
  const fimMarcador = "\nCOMMIT;";
  const inicio = sqlDaMigration.indexOf(inicioMarcador);
  const fim = sqlDaMigration.lastIndexOf(fimMarcador);
  assert.ok(inicio !== -1 && fim !== -1 && fim > inicio, "migration real deveria ter BEGIN;/COMMIT; delimitando o corpo");
  return sqlDaMigration.slice(inicio + inicioMarcador.length, fim).trim();
}

function extrairCorpoEmbutido(marcadorInicio, marcadorFim) {
  const inicio = harness.indexOf(marcadorInicio);
  const fim = harness.indexOf(marcadorFim);
  assert.ok(inicio !== -1 && fim !== -1 && fim > inicio, `harness deveria conter os marcadores "${marcadorInicio.trim()}" e "${marcadorFim.trim()}"`);
  return harness.slice(inicio + marcadorInicio.length, fim).trim();
}

test("cópia embutida de questao_unidades_pedagogicas.sql no harness é idêntica ao arquivo real", () => {
  const corpoReal = extrairCorpoReal(assoc);
  const corpoEmbutido = extrairCorpoEmbutido(
    "-- CORPO DE supabase/questao_unidades_pedagogicas.sql (sem o COMMIT final)\n-- ============================================================================\n\n",
    "\n-- ============================================================================\n-- CORPO DE supabase/missao_pratica_papiro_rpc.sql",
  );
  assert.equal(corpoEmbutido, corpoReal);
});

test("cópia embutida de missao_pratica_papiro_rpc.sql no harness é idêntica ao arquivo real", () => {
  const corpoReal = extrairCorpoReal(rpc);
  const corpoEmbutido = extrairCorpoEmbutido(
    "-- CORPO DE supabase/missao_pratica_papiro_rpc.sql (sem o COMMIT final)\n-- ============================================================================\n\n",
    "\n-- ============================================================================\n-- FIM DO CORPO DAS 2 MIGRATIONS",
  );
  assert.equal(corpoEmbutido, corpoReal);
});

test("questao_unidades_pedagogicas associa sem duplicar a questão e é fechada por RLS", () => {
  assert.match(assoc, /create table public\.questao_unidades_pedagogicas/);
  assert.match(assoc, /primary key \(questao_id, unidade_pedagogica_id\)/);
  assert.match(assoc, /references public\.questoes\(id\) on delete cascade/);
  assert.match(assoc, /references public\.unidades_pedagogicas\(id\) on delete cascade/);
  assert.match(assoc, /alter table public\.questao_unidades_pedagogicas enable row level security/);
  assert.match(assoc, /revoke all on public\.questao_unidades_pedagogicas from anon, authenticated/);
});

test("classificação de questão por unidade respeita materia/assunto via trigger, nunca por texto/regex", () => {
  assert.match(assoc, /create function public\.validar_questao_unidade_pedagogica/);
  assert.match(assoc, /v_materia_questao <> v_materia_unidade/);
  assert.match(assoc, /v_assunto_questao <> v_assunto_unidade/);
  assert.match(assoc, /before insert or update on public\.questao_unidades_pedagogicas/);
  // Nenhuma classificação automática: só existe via RPC gated por eh_admin().
  assert.match(assoc, /create function public\.classificar_questao_unidade_admin/);
  assert.match(assoc, /if not public\.eh_admin\(\) then/);
  assert.doesNotMatch(assoc, /regexp_match/i);
});

test("progresso_questoes e sessoes_estudo ganham colunas aditivas, sem índice único que impeça refazer", () => {
  assert.match(assoc, /alter table public\.missoes\s*\n\s*add column progresso_questoes jsonb/);
  assert.match(assoc, /add column unidade_pedagogica_id uuid null/);
  assert.match(assoc, /add column tipo_pratica text null/);
  assert.match(assoc, /tipo_pratica in \('unidade', 'missao_final'\)/);
  // De propósito: sem "create unique index" sobre (missao_id, unidade_pedagogica_id)
  // nem sobre missao_id where tipo_pratica='missao_final' — refazer precisa
  // de mais de uma sessão para a mesma unidade/missão final ao longo do tempo.
  assert.doesNotMatch(assoc, /create unique index[^;]*unidade_pedagogica_id/);
});

test("algoritmo de seleção prioriza inéditas, depois erradas, depois mais antigas, nunca ids do cliente", () => {
  assert.match(rpc, /create function public\.selecionar_candidatas_unidade_pedagogica/);
  assert.match(rpc, /coalesce\(hist\.vezes_respondida, 0\) = 0\) desc/);
  assert.match(rpc, /coalesce\(hist\.ja_errou, false\) desc/);
  assert.match(rpc, /coalesce\(hist\.ultima_vez, '-infinity'::timestamptz\) asc/);
  assert.match(rpc, /bool_or\(not ru\.acertou\) as ja_errou/);
  assert.match(rpc, /max\(ru\.respondida_em\) as ultima_vez/);
  assert.match(rpc, /not \(q\.id = any\(coalesce\(p_excluir, '\{\}'::bigint\[\]\)\)\)/);
  assert.match(rpc, /revoke execute on function public\.selecionar_candidatas_unidade_pedagogica\(uuid, uuid, uuid, integer, bigint\[\], uuid\)\s*\n\s*from public, anon, authenticated/);
});

test("algoritmo tem 3 tiers: inédita > vista fora da janela de repetição > repetição especialmente recente", () => {
  const bloco = rpc.slice(rpc.indexOf("create function public.selecionar_candidatas_unidade_pedagogica"), rpc.indexOf("create function public.selecionar_candidatas_conteudo"));
  assert.match(bloco, /v_janela_repeticao constant interval := interval '24 hours'/);
  assert.match(bloco, /usada_na_missao_atual/);
  assert.match(bloco, /s\.tipo_pratica = 'unidade'/);
  assert.match(bloco, /p_missao_id uuid default null/);
  // A separação de tier (visto-fora-da-janela vs visto-recente) tem que vir
  // ANTES do desempate por ja_errou/ultima_vez na ORDER BY — senão um erro
  // de segundos furaria a frente de uma vista antiga.
  const ordemBy = bloco.slice(bloco.indexOf("order by"));
  const idxTier = ordemBy.indexOf("v_janela_repeticao");
  const idxJaErrou = ordemBy.indexOf("coalesce(hist.ja_errou, false) desc");
  assert.ok(idxTier > -1 && idxJaErrou > -1 && idxTier < idxJaErrou, "separação de tier deve vir antes do desempate por ja_errou na ORDER BY");
});

test("iniciar_pratica_unidade libera por unidade (não exige as demais) e seleciona no servidor", () => {
  assert.match(rpc, /create function public\.iniciar_pratica_unidade/);
  assert.match(rpc, /v_quantidade constant integer := 10/);
  assert.match(rpc, /Conclua a teoria desta unidade antes de iniciar as questoes/);
  assert.match(rpc, /select array_agg\(x\.questao_id\)\s*\n\s*into v_ids\s*\n\s*from public\.selecionar_candidatas_unidade_pedagogica/);
  assert.doesNotMatch(rpc, /iniciar_pratica_unidade\([^)]*p_questao_ids/);
});

test("concluir_pratica_unidade nunca conclui a missão inteira", () => {
  assert.match(rpc, /create function public\.concluir_pratica_unidade/);
  assert.match(rpc, /missao_final_liberada/);
  const bloco = rpc.slice(rpc.indexOf("create function public.concluir_pratica_unidade"), rpc.indexOf("create function public.iniciar_missao_final"));
  // Fecha a SESSÃO da unidade (sessoes_estudo.status='concluida') — isso é
  // esperado — mas nunca escreve missoes.status, só missoes.progresso_questoes.
  assert.match(bloco, /update public\.sessoes_estudo\s*\n\s*set status = 'concluida'/);
  assert.doesNotMatch(bloco, /update public\.missoes\s*\n\s*set status/);
  assert.match(bloco, /update public\.missoes\s*\n\s*set progresso_questoes = v_progresso_questoes/);
});

test("iniciar_missao_final só libera com todas as unidades (teoria + prática) concluídas, e representa todas", () => {
  const bloco = rpc.slice(rpc.indexOf("create function public.iniciar_missao_final"), rpc.indexOf("create function public.concluir_missao_final"));
  assert.match(bloco, /v_quantidade constant integer := 30/);
  assert.match(bloco, /Conclua a teoria e a pratica de todas as unidades antes da Missao Final/);
  assert.match(bloco, /coalesce\(v_total_teoria_concluida, 0\) <> v_total_unidades/);
  assert.match(bloco, /coalesce\(v_total_praticadas, 0\) <> v_total_unidades/);
  assert.match(bloco, /order by u\.ordem/);
  assert.match(bloco, /selecionar_candidatas_conteudo/);
});

test("concluir_missao_final é o único ponto que fecha a missão do Modo Papiro", () => {
  const bloco = rpc.slice(rpc.indexOf("create function public.concluir_missao_final"));
  assert.match(bloco, /status = 'concluida'/);
  assert.match(bloco, /concluida_em = coalesce\(concluida_em, now\(\)\)/);
});

test("todas as RPCs novas são SECURITY DEFINER com search_path vazio e GRANT só para authenticated", () => {
  for (const nome of ["iniciar_pratica_unidade", "concluir_pratica_unidade", "iniciar_missao_final", "concluir_missao_final"]) {
    const bloco = rpc.slice(rpc.indexOf(`create function public.${nome}`));
    assert.match(bloco.slice(0, bloco.indexOf("$function$")), /security definer/, `${nome} deveria ser SECURITY DEFINER`);
    assert.match(bloco.slice(0, bloco.indexOf("$function$")), /set search_path to ''/, `${nome} deveria ter search_path vazio`);
  }
  assert.match(rpc, /grant execute on function public\.iniciar_pratica_unidade\(uuid, uuid, boolean\) to authenticated/);
  assert.match(rpc, /grant execute on function public\.concluir_pratica_unidade\(uuid, bigint\) to authenticated/);
  assert.match(rpc, /grant execute on function public\.iniciar_missao_final\(uuid, boolean\) to authenticated/);
  assert.match(rpc, /grant execute on function public\.concluir_missao_final\(uuid, bigint\) to authenticated/);
});

test("harness roda dentro de BEGIN/ROLLBACK e cobre os cenários obrigatórios", () => {
  assert.match(harness, /^BEGIN;/m);
  assert.match(harness, /^ROLLBACK;/m);
  assert.match(harness, /unidade_so_recebe_suas_questoes/);
  assert.match(harness, /ineditas_priorizadas/);
  assert.match(harness, /fallback_com_menos_de_dez_ineditas/);
  assert.match(harness, /erro_anterior_aumenta_prioridade/);
  assert.match(harness, /sem_duplicata_na_selecao/);
  assert.match(harness, /sessao_recuperada_mesmos_ids/);
  assert.match(harness, /unidades_tem_sessoes_diferentes/);
  assert.match(harness, /concluir_unidade_nao_conclui_missao/);
  assert.match(harness, /missao_final_bloqueada_sem_todas_unidades/);
  assert.match(harness, /missao_final_representa_todas_unidades/);
  assert.match(harness, /sessao_livre_continua_funcionando/);
  assert.match(harness, /outro_usuario_bloqueado/);
  assert.match(harness, /refazer_preserva_historico/);
  // Fixtures de histórico nascem 'em_andamento' e só viram 'concluida'
  // DEPOIS do INSERT em respostas_usuarios — a trigger respostas_valida_
  // sessao exige status='em_andamento' no momento do INSERT, inclusive
  // para INSERT direto (não passa pela RPC registrar_resposta).
  assert.match(harness, /historico_fixture_bloco2_ok/);
  assert.match(harness, /historico_fixture_janela_ok/);
  assert.doesNotMatch(harness, /'personalizada', 'concluida',/);
  // public.missoes tem UNIQUE(matricula_id, conteudo_id, data_missao) — a
  // missão fixture nunca pode usar uma data fixa (colide com missão real
  // já existente para a mesma matrícula/conteúdo); tem que buscar uma data
  // livre dinamicamente e nunca reaproveitar/atualizar uma linha real.
  assert.match(harness, /missao_fixture_bloco4_usa_data_livre/);
  assert.match(harness, /missao_fixture_janela_usa_data_livre/);
  assert.doesNotMatch(harness, /insert into public\.missoes \(matricula_id, conteudo_id, data_missao, status, progresso_teoria\)\s*\n\s*values \(v_matricula_id, v_conteudo_id, \(timezone/);
  // Isolamento de dados reais (não depende do estado do banco de produção).
  assert.match(harness, /isolamento_total_unidades_exatamente_dois/);
  assert.match(harness, /update public\.unidades_pedagogicas\s*\n\s*set ativa = false/);
  // Tiers de prioridade / janela de repetição imediata.
  assert.match(harness, /unidade_janela_ineditas_ainda_vencem_tudo/);
  assert.match(harness, /errada_recente_nao_vence_vista_antiga/);
  assert.match(harness, /recente_entra_quando_necessaria/);
  assert.match(harness, /missao_final_evita_questoes_da_propria_missao/);
  assert.match(harness, /missao_final_reutiliza_se_banco_insuficiente/);
});

test("SET LOCAL ROLE authenticated nunca envolve acesso direto às tabelas de asserção/estado do harness", () => {
  // teste_papiro_resultados/teste_papiro_contexto pertencem ao role do SQL
  // Editor, não a authenticated — um INSERT/UPDATE/SELECT direto nelas (ou
  // nas tabelas de estado que as RPCs administram) enquanto o harness ainda
  // está simulando o aluno já quebrou em produção com SQLSTATE 42501
  // ("permission denied for table teste_papiro_resultados"). Só chamadas de
  // RPC podem existir entre "set local role authenticated;" e o "reset
  // role;" que a encerra — todo acesso direto tem que vir DEPOIS do reset.
  const tabelasProibidasSobAuthenticated = [
    "teste_papiro_resultados",
    "teste_papiro_contexto",
    "public.missoes",
    "public.sessoes_estudo",
    "public.respostas_usuarios",
    "public.sessao_questoes_planejadas",
    "public.alternativas",
  ];
  const marcadorInicio = "set local role authenticated;";
  const marcadorFim = "reset role;";
  let posicao = 0;
  let trechosAuditados = 0;
  while (true) {
    const inicio = harness.indexOf(marcadorInicio, posicao);
    if (inicio === -1) break;
    const fim = harness.indexOf(marcadorFim, inicio);
    assert.ok(fim !== -1, `"set local role authenticated;" na posição ${inicio} não tem um "reset role;" correspondente depois`);
    // Remove comentários "-- ..." antes de checar: eles podem citar o nome
    // da tabela só como explicação (ex.: "RESET ROLE antes de ler
    // public.alternativas"), o que não é um acesso real.
    const trecho = harness
      .slice(inicio + marcadorInicio.length, fim)
      .replace(/--[^\n]*/g, "");
    for (const tabela of tabelasProibidasSobAuthenticated) {
      const regexTabela = new RegExp(`\\b${tabela.replace(".", "\\.")}\\b`);
      assert.doesNotMatch(
        trecho,
        regexTabela,
        `trecho sob authenticated (harness offset ${inicio}) acessa "${tabela}" diretamente antes do reset role — mova esse acesso para depois do reset role`,
      );
    }
    trechosAuditados += 1;
    posicao = fim + marcadorFim.length;
  }
  // Não deixa o teste passar "por vazio" se o padrão de nomes mudar algum dia.
  assert.ok(trechosAuditados >= 10, `esperava auditar pelo menos 10 trechos "set local role authenticated" no harness, encontrou ${trechosAuditados}`);
});

test("app/teoria/page.tsx oferece a Missão Final direto ao aluno que já praticou todas as unidades", () => {
  assert.match(teoria, /obterIdsUnidadesPraticadas/);
  assert.match(teoria, /missaoFinalLiberada/);
  assert.match(teoria, /missaoFinal: true/);
  assert.match(teoria, /Fazer a Missão Final Papiro/);
});

test("app/teoria/page.tsx só muda de fluxo quando há mais de uma unidade publicada", () => {
  assert.match(teoria, /unidadesPublicadas\.length > 1/);
  assert.match(teoria, /unidadePedagogicaId: aulaAtual\.unidade_pedagogica_id/);
  // Conteúdo com 1 única unidade preserva o destino antigo (mesmo bloco
  // final inalterado, sem unidadePedagogicaId).
  const semUnidade = teoria.slice(teoria.lastIndexOf("window.location.assign(montarLinkMissao({"));
  assert.doesNotMatch(semUnidade, /unidadePedagogicaId/);
});

test("app/questoes/page.tsx nunca envia p_questao_ids para as RPCs do Modo Papiro", () => {
  assert.match(questoes, /iniciar_pratica_unidade/);
  assert.match(questoes, /iniciar_missao_final/);
  assert.match(questoes, /concluir_pratica_unidade/);
  assert.match(questoes, /concluir_missao_final/);
  const blocoUnidade = questoes.slice(questoes.indexOf('rpc("iniciar_pratica_unidade"'), questoes.indexOf('rpc("iniciar_pratica_unidade"') + 300);
  assert.doesNotMatch(blocoUnidade, /p_questao_ids/);
  const blocoFinal = questoes.slice(questoes.indexOf('rpc("iniciar_missao_final"'), questoes.indexOf('rpc("iniciar_missao_final"') + 300);
  assert.doesNotMatch(blocoFinal, /p_questao_ids/);
  // Fluxo antigo (missionId) continua chamando ids_questoes_para_usuario
  // ANTES de iniciar_questoes_da_missao — não removido, só ficou num "else".
  assert.match(questoes, /iniciar_questoes_da_missao/);
});

test("app/questoes/resultado nunca chama a unidade concluída de MISSÃO CONCLUÍDA", () => {
  assert.match(resultado, /UNIDADE CONCLUÍDA/);
  assert.match(resultado, /TODAS AS UNIDADES CONCLUÍDAS/);
  assert.match(resultado, /Seguir para a próxima unidade/);
  assert.match(resultado, /Fazer a Missão Final Papiro/);
  // Comportamento antigo (sem "proximo" na URL) inalterado.
  assert.match(resultado, /MISSÃO CONCLUÍDA/);
  assert.match(resultado, /resultado\.missao_id \? "\/cronograma" : "\/painel"/);
  assert.match(resultado, /resultado\.missao_id \? "Voltar ao cronograma" : "Voltar ao painel"/);
});

test("utils/missao-cronograma.mjs nunca inclui unidade e missaoFinal ao mesmo tempo por acidente", () => {
  assert.match(cronograma, /export function lerPraticaPapiro/);
  assert.match(cronograma, /unidadePedagogicaId: uuidValido\(parametros\.get\("unidade"\)\)/);
  assert.match(cronograma, /missaoFinal: parametros\.get\("missaoFinal"\) === "1"/);
});
