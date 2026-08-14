import test from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

const rpc = await readFile(new URL("../supabase/unidades_pedagogicas_progresso_rpc.sql", import.meta.url), "utf8");
const pagina = await readFile(new URL("../app/teoria/page.tsx", import.meta.url), "utf8");
const estilos = await readFile(new URL("../app/globals.css", import.meta.url), "utf8");

test("progresso por unidade é autorizado e calculado no servidor", () => {
  assert.match(rpc, /registrar_unidade_teoria_concluida\(/);
  assert.match(rpc, /v_usuario_id := auth\.uid\(\)/);
  assert.match(rpc, /m\.usuario_id = v_usuario_id/);
  assert.match(rpc, /for update of ms/);
  assert.match(rpc, /a\.conteudo_id = v_conteudo_id/);
  assert.match(rpc, /av\.status = 'publicada'/);
});

test("progresso V2 guarda unidade e versão publicada", () => {
  assert.match(rpc, /'schema_version', 2/);
  assert.match(rpc, /'unidade_pedagogica_id'/);
  assert.match(rpc, /'aula_versao_id'/);
  assert.match(rpc, /v_total_concluidas = v_total_unidades/);
  assert.match(rpc, /status = v_novo_status/);
  assert.match(rpc, /teoria_concluida_em = v_novo_teoria_concluida_em/);
});

test("RPC não concede escrita direta e só authenticated pode executar", () => {
  assert.match(rpc, /security definer/);
  assert.match(rpc, /revoke execute .* from public/);
  assert.match(rpc, /revoke execute .* from anon/);
  assert.match(rpc, /grant execute .* to authenticated/);
});

test("aluno conclui a unidade antes de avançar", () => {
  assert.match(pagina, /registrar_unidade_teoria_concluida/);
  assert.match(pagina, /Concluir unidade e avançar/);
  assert.match(pagina, /Concluir teoria e ir para as questões/);
  assert.match(pagina, /Salvando progresso\.\.\./);
  assert.match(pagina, /obterIdsUnidadesConcluidas/);
});

test("trilha diferencia unidade concluída e andamento", () => {
  assert.match(pagina, /concluida \? "✓"/);
  assert.match(pagina, /"Concluída"/);
  assert.match(pagina, /"Em andamento"/);
  assert.match(estilos, /button\.concluida/);
  assert.match(estilos, /\.teoria-progresso-mensagem/);
});
