import assert from "node:assert/strict";
import test from "node:test";
import { readFile } from "node:fs/promises";

// Correção do bloqueio circular do botão "Gerar aula": a RPC
// listar_geracoes_conteudo_admin ganha um booleano `tem_response_id`
// (openai_response_id IS NOT NULL) para a UI distinguir geração async
// real de registro legado/órfão, sem nunca expor o identificador bruto
// da OpenAI ao cliente. Estes testes inspecionam os arquivos SQL desta
// fase (migration, reverter, harness) — não executam nada contra um
// banco real, mesmo princípio dos demais testes estruturais de SQL deste
// projeto (ex.: tests/unidades-pedagogicas.test.mjs).

const migracao = await readFile(new URL("../supabase/teoria_geracoes_admin_tem_response_id.sql", import.meta.url), "utf8");
const reverter = await readFile(new URL("../supabase/reverter_teoria_geracoes_admin_tem_response_id.sql", import.meta.url), "utf8");
const harness = await readFile(new URL("../supabase/teoria_geracoes_admin_tem_response_id_teste_rollback.sql", import.meta.url), "utf8");
const posCheck = await readFile(new URL("../supabase/pos_check_teoria_geracoes_admin_tem_response_id.sql", import.meta.url), "utf8");

test("migration só recria listar_geracoes_conteudo_admin — nenhuma tabela, RLS, índice ou dado é tocado", () => {
  assert.match(migracao, /drop function public\.listar_geracoes_conteudo_admin\(bigint\);/);
  assert.match(migracao, /create function public\.listar_geracoes_conteudo_admin\(p_conteudo_id bigint\)/);
  assert.ok(!/alter table/i.test(migracao), "não deve alterar nenhuma tabela");
  assert.ok(!/create index|drop index/i.test(migracao), "não deve tocar em índices");
  assert.ok(!/insert into|update\s+public\.|delete from/i.test(migracao), "não deve escrever em nenhum dado");
  assert.ok(!/create policy|alter policy|drop policy|enable row level security/i.test(migracao), "não deve tocar em RLS");
  assert.match(migracao, /^BEGIN;/m);
  assert.match(migracao, /^COMMIT;/m);
  assert.ok(!/^ROLLBACK;/m.test(migracao), "a migration real deve confirmar (COMMIT), nunca desfazer");
});

test("migration acrescenta tem_response_id boolean como 10ª coluna, preservando as 9 anteriores em nome/tipo/ordem", () => {
  assert.match(
    migracao,
    /returns table \(\s*geracao_id uuid,\s*status text,\s*iniciado_em timestamptz,\s*finalizado_em timestamptz,\s*aula_versao_id uuid,\s*erro text,\s*prompt_version text,\s*modelo text,\s*contexto jsonb,\s*tem_response_id boolean\s*\)/,
  );
});

test("migration calcula tem_response_id a partir de openai_response_id IS NOT NULL, nunca expõe o identificador bruto no SELECT de retorno", () => {
  assert.match(migracao, /\(g\.openai_response_id is not null\)/);
  // A única menção a "openai_response_id" no corpo da função deve ser
  // dentro dessa expressão booleana — nunca uma coluna própria "g.
  // openai_response_id" sendo devolvida sozinha no SELECT.
  const corpoFuncao = migracao.slice(migracao.indexOf("as $function$"), migracao.indexOf("$function$;", migracao.indexOf("as $function$") + 1));
  const linhasComResponseId = corpoFuncao.split("\n").filter((l) => l.includes("openai_response_id"));
  for (const linha of linhasComResponseId) {
    assert.ok(linha.includes("is not null"), `toda menção a openai_response_id no corpo da função deve estar dentro do "IS NOT NULL" — linha suspeita: ${linha}`);
  }
});

test("migration preserva LANGUAGE plpgsql, SECURITY DEFINER, search_path vazio e os mesmos GRANTs de antes", () => {
  assert.match(migracao, /language plpgsql/);
  assert.match(migracao, /security definer/);
  assert.match(migracao, /set search_path to ''/);
  assert.match(migracao, /revoke execute on function public\.listar_geracoes_conteudo_admin\(bigint\) from public;/);
  assert.match(migracao, /revoke execute on function public\.listar_geracoes_conteudo_admin\(bigint\) from anon;/);
  assert.match(migracao, /grant execute on function public\.listar_geracoes_conteudo_admin\(bigint\) to authenticated;/);
});

test("migration preserva o mesmo filtro e a mesma ordenação da versão anterior", () => {
  assert.match(migracao, /where g\.conteudo_id = p_conteudo_id/);
  assert.match(migracao, /order by g\.iniciado_em desc/);
});

test("reverter restaura exatamente a versão anterior (9 colunas, sem tem_response_id) e nunca é executado automaticamente", () => {
  assert.match(reverter, /NÃO EXECUTAR AGORA/);
  assert.match(
    reverter,
    /returns table \(\s*geracao_id uuid,\s*status text,\s*iniciado_em timestamptz,\s*finalizado_em timestamptz,\s*aula_versao_id uuid,\s*erro text,\s*prompt_version text,\s*modelo text,\s*contexto jsonb\s*\)/,
  );
  // "tem_response_id" pode aparecer em comentário (explicando o que este
  // arquivo restaura) — o que não pode existir é a coluna real na
  // definição da função (fora de linhas de comentário).
  const linhasDeCodigo = reverter.split("\n").filter((linha) => !linha.trim().startsWith("--"));
  assert.ok(!linhasDeCodigo.some((linha) => linha.includes("tem_response_id")), "a versão restaurada pelo reverter não deve ter a coluna tem_response_id");
  assert.match(reverter, /^BEGIN;/m);
  assert.match(reverter, /^COMMIT;/m);
});

test("harness de rollback nunca usa SAVEPOINT como comando solto (lição da fase anterior) e sempre termina em ROLLBACK, nunca COMMIT", () => {
  const linhasDeComando = harness.split("\n").filter((linha) => !linha.trim().startsWith("--"));
  const usoRealDeSavepoint = linhasDeComando.some((linha) => /\bsavepoint\b/i.test(linha));
  assert.ok(!usoRealDeSavepoint, "não pode existir um comando SAVEPOINT/ROLLBACK TO SAVEPOINT real");
  assert.match(harness, /^BEGIN;/m);
  assert.match(harness, /^ROLLBACK;/m);
  assert.ok(!/^COMMIT;/m.test(harness), "o harness de teste nunca deve confirmar (COMMIT) — só o rollback real, futuro, faz isso");
});

test("harness cobre as letras A-I do mandato: existência, coluna nova, tipo, não-exposição, NULL->false, expressão/estrutural, contagem estável, ordenação, isolamento de dados alheios", () => {
  for (const chave of [
    "a_funcao_existe",
    "dez_colunas",
    "nove_campos_antigos_preservados",
    "b_tem_response_id_decima_coluna",
    "c_tem_response_id_boolean",
    "d_openai_response_id_nao_exposto",
    "e_response_id_null_vira_false",
    "f_expressao_correta_estrutural",
    "g_contagem_de_linhas_estavel",
    "h_ordenacao_preservada",
    "i_nenhuma_linha_alheia_alterada",
  ]) {
    assert.ok(harness.includes(chave), `o harness deve conter a validação "${chave}"`);
  }
  assert.match(harness, /NAO_HA_FIXTURE_REAL_COM_RESPONSE_ID/, "deve tratar explicitamente o caso de não existir nenhuma linha real com response_id, sem inserir fixture só para isso");
});

test("harness nunca insere fixture com status='processando' (evita colidir com o índice único de trava real)", () => {
  const insercoesFixture = harness.split("insert into public.aula_geracoes").slice(1);
  for (const trecho of insercoesFixture) {
    const ateFechamento = trecho.slice(0, 300);
    assert.ok(!ateFechamento.includes("'processando'"), "fixture de teste nunca deve usar status='processando'");
  }
});

test("pós-check é somente leitura (nenhum INSERT/UPDATE/DELETE/DDL)", () => {
  assert.ok(!/insert into|update\s+public\.|delete from|create function|drop function|alter table/i.test(posCheck), "o pós-check deve ser inteiramente read-only");
  assert.match(posCheck, /pg_get_function_identity_arguments/);
});
