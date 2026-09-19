import assert from "node:assert/strict";
import test from "node:test";
import { existsSync, readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import path from "node:path";

// Fase Q10.1 — pacote SQL do pipeline de jobs dos assets (claim/lease/fencing,
// concluir/falhar, aprovar/rejeitar/regenerar, exclusão em 2 fases). O SQL NÃO é
// executado aqui (nem no LIVE nesta fase): estes testes garantem, estruturalmente,
// o contrato decidido, que o harness reutiliza EXATAMENTE as seções do apply e do
// reverter, e que nada perigoso (Image API, Edge, Storage, segredos) entrou.

const raiz = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const ler = (relativo) => readFileSync(path.join(raiz, relativo), "utf8");

const apply = ler("supabase/camada_ilustrada_pipeline.sql");
const harness = ler("supabase/camada_ilustrada_pipeline_teste_rollback.sql");
const posCheck = ler("supabase/pos_check_camada_ilustrada_pipeline.sql");
const reverter = ler("supabase/reverter_camada_ilustrada_pipeline.sql");
const baseQ9 = ler("supabase/camada_ilustrada_base.sql");

const semComentarios = (sql) => sql.replace(/\/\*[\s\S]*?\*\//g, "").replace(/^\s*--.*$/gm, "").replace(/[ \t]+--.*$/gm, "");
const applySql = semComentarios(apply);
const harnessSql = semComentarios(harness);
const reverterSql = semComentarios(reverter);
const posCheckSql = semComentarios(posCheck);

function secao(texto, nome) {
  const ini = texto.indexOf(`-- >>> ${nome}`);
  const fimMarca = `-- <<< ${nome}`;
  const fim = texto.indexOf(fimMarca);
  assert.ok(ini > -1 && fim > ini, `seção ${nome} não encontrada`);
  return texto.slice(ini, fim + fimMarca.length);
}
const secaoSql = (texto, nome) => semComentarios(secao(texto, nome));
const corpo = secaoSql(apply, "SECAO_CORPO");

function fn(nome) {
  const ini = corpo.indexOf(`create function public.${nome}(`);
  assert.ok(ini > -1, `create function ${nome}`);
  const fim = corpo.indexOf("\n$$;", ini);
  assert.ok(fim > ini, `fim de ${nome}`);
  return corpo.slice(ini, fim + 4);
}

const WORKER = ["reservar_quadrinho_asset", "concluir_quadrinho_asset", "falhar_quadrinho_asset"];
const ADMIN = ["criar_jobs_quadrinho_admin", "aprovar_quadrinho_asset_admin", "rejeitar_quadrinho_asset_admin", "regenerar_quadrinho_asset_admin", "preparar_exclusao_quadrinho_asset_admin", "excluir_quadrinho_asset_admin"];
const HELPERS = ["quadrinho_asset_lease", "quadrinho_componente", "cena_atual_quadrinho", "quadrinho_path_no_storage", "quadrinho_asset_reiniciar"];

test("Q10-1: pacote completo; apply em uma transação (BEGIN ... COMMIT) e harness só BEGIN ... ROLLBACK", () => {
  assert.match(applySql, /^\s*begin;/i);
  assert.equal((applySql.match(/^\s*commit;\s*$/gim) ?? []).length, 1);
  assert.equal((applySql.match(/^\s*begin;\s*$/gim) ?? []).length, 1);
  assert.match(harnessSql, /^\s*BEGIN;/);
  assert.match(harnessSql.trimEnd(), /ROLLBACK;$/);
  assert.equal((harnessSql.match(/^\s*commit\s*;/gim) ?? []).length, 0, "harness sem COMMIT");
  assert.equal((harnessSql.match(/^\s*BEGIN;\s*$/gm) ?? []).length, 1);
});

test("Q10-2: harness não faz nada externo — sem HTTP, cron, Vault, Edge, Image API nem escrita em storage.objects", () => {
  for (const proibido of [/net\.http/i, /pg_net/i, /cron\.schedule/i, /cron\.unschedule/i, /vault\.(create_secret|update_secret|delete_secret|decrypted_secrets)/i, /decrypted_secret/i, /functions\/v1/i, /api\.openai\.com/i, /images\/generations/i, /\bfetch\(/i, /\bconcurrently\b/i, /\bvacuum\b/i]) {
    assert.doesNotMatch(harnessSql, proibido, String(proibido));
    assert.doesNotMatch(applySql, proibido, `apply: ${proibido}`);
  }
  // storage.objects só é LIDO; nenhum objeto criado/removido.
  for (const sql of [harnessSql, applySql, reverterSql]) {
    assert.doesNotMatch(sql, /(insert into|update|delete from)\s+storage\.objects/i);
  }
  // Vault: só se LÊ o NOME dos segredos (hash agregado) para provar que nada mudou; nunca valores.
  assert.doesNotMatch(harnessSql, /select[^;]*\bsecret\b[^;]*from vault\.secrets/i);
});

test("Q10-3: seções PRECOND/CORPO/POSCOND do harness idênticas às do apply; REVERT_* idênticas às do reverter", () => {
  for (const nome of ["SECAO_PRECOND", "SECAO_CORPO", "SECAO_POSCOND"]) assert.equal(secao(harness, nome), secao(apply, nome), nome);
  for (const nome of ["SECAO_REVERT_GUARDA", "SECAO_REVERT_CORPO", "SECAO_REVERT_POSCOND"]) assert.equal(secao(harness, nome), secao(reverter, nome), nome);
});

test("Q10-4: precondições exigem a fundação Q9 EXATA (colunas, md5 das 4 funções, bucket) e nada do pacote existente", () => {
  const pre = secaoSql(apply, "SECAO_PRECOND");
  for (const trecho of [
    /to_regclass\('public\.aula_quadrinho_assets'\) is null/,
    /colunas da tabela divergem da fundacao Q9/,
    /contype = 'c'\) <> 7/,
    /'2779b0d927b88a6946b31636dff13804'/, /'0fd391aacd21da2eb83ad06ec38db44b'/, /'ee2c134d44bdbb00e45f0973eb20e33b'/, /'4d6a052a6b05e49d585fe2c9360d3b84'/,
    /file_size_limit = 262144 and allowed_mime_types = array\['image\/webp'\]/,
    /column_name in \('claim_token', 'storage_path_anterior'\)/,
    /aula_quadrinho_assets_claim_coerente_check/, /aula_quadrinho_assets_path_anterior_check/, /aula_quadrinho_assets_path_anterior_key/,
    /status = 'gerando' or lease_ate is not null/,
    /raise exception 'PRECOND: %', v_problemas/,
  ]) assert.match(pre, trecho, String(trecho));
  for (const nome of [...WORKER, ...ADMIN, ...HELPERS]) assert.ok(pre.includes(`'${nome}'`), `precondição lista ${nome}`);
  // O md5 esperado das funções Q9 é o mesmo em precondição e pós-condição e no pós-check.
  for (const md5 of ["2779b0d927b88a6946b31636dff13804", "4d6a052a6b05e49d585fe2c9360d3b84"]) {
    assert.ok(secao(apply, "SECAO_POSCOND").includes(md5) && posCheck.includes(md5));
  }
  assert.doesNotMatch(applySql, /create or replace function|create table if not exists|drop table|drop function|on conflict do update/i, "nunca sobrescreve objeto existente");
});

test("Q10-5: schema — só 2 colunas novas (claim_token para fencing/path por geração; storage_path_anterior contra órfão silencioso)", () => {
  assert.match(corpo, /alter table public\.aula_quadrinho_assets\s+add column claim_token uuid null,\s+add column storage_path_anterior text null;/);
  assert.doesNotMatch(applySql, /generation_id|tentativa_geracao|brief|prompt_brief/i);
  assert.match(corpo, /aula_quadrinho_assets_claim_coerente_check check \(\s*\(status = 'gerando' and claim_token is not null and lease_ate is not null\)\s+or \(status <> 'gerando' and claim_token is null and lease_ate is null\)\s*\)/);
  assert.match(corpo, /aula_quadrinho_assets_path_anterior_check check \(\s*storage_path_anterior is null\s+or \(length\(btrim\(storage_path_anterior\)\) > 0 and storage_path_anterior !~ '\(\^\/\|\\\.\\\.\)' and storage_path_anterior is distinct from storage_path\)\s*\)/);
  assert.match(corpo, /create unique index aula_quadrinho_assets_path_anterior_key\s+on public\.aula_quadrinho_assets \(storage_path_anterior\)\s+where storage_path_anterior is not null;/);
  // Status preservados: nenhum status novo.
  assert.doesNotMatch(applySql, /alter table[^;]*status_check|drop constraint aula_quadrinho_assets_status_check/i);
  // Q9 não é recriada nem alterada.
  for (const q9 of ["hash_cena_quadrinho", "hash_cena_atual_quadrinho", "carregar_quadrinho_assets_aula", "carregar_quadrinho_assets_admin"]) {
    assert.doesNotMatch(corpo, new RegExp(`create function public\\.${q9}\\(`), `${q9} não pode ser recriada`);
  }
  assert.doesNotMatch(corpo, /storage\.buckets|create policy|alter table public\.(aulas|aula_versoes)/i);
});

test("Q10-6: lease centralizado em UM ponto (10 minutos) e reutilizado pelo claim", () => {
  const f = fn("quadrinho_asset_lease");
  assert.match(f, /returns interval\s+language sql\s+immutable\s+set search_path to ''\s+as \$\$ select interval '10 minutes' \$\$;/);
  assert.equal((corpo.match(/interval '\d+ minutes?'/g) ?? []).length, 1, "o único literal de intervalo é o do helper");
  assert.match(fn("reservar_quadrinho_asset"), /public\.quadrinho_asset_lease\(\)/);
  assert.match(apply, /LEASE: quadrinho_asset_lease\(\) = 10 minutos/);
});

test("Q10-7: claim — SKIP LOCKED, pendente/gerando-expirado, máx. 3 tentativas, token novo a cada reserva, sem dados extras", () => {
  const f = fn("reservar_quadrinho_asset");
  assert.match(f, /for update skip locked/);
  assert.match(f, /q\.tentativas < 3/);
  assert.match(f, /\(q\.status = 'pendente' or \(q\.status = 'gerando' and q\.lease_ate < now\(\)\)\)/);
  assert.match(f, /v_token := gen_random_uuid\(\);/);
  assert.match(f, /set status = 'gerando', tentativas = q\.tentativas \+ 1, claim_token = v_token, lease_ate = v_lease_ate, atualizado_em = now\(\)/);
  // lease expirado sem tentativas restantes => erro (nunca trancado); cena mudou => erro (nunca gera)
  assert.match(f, /x\.status = 'gerando' and x\.lease_ate < now\(\) and x\.tentativas >= 3/);
  assert.match(f, /set status = 'erro', erro_sanitizado = 'tempo limite excedido sem tentativas restantes'/);
  assert.match(f, /public\.hash_cena_quadrinho\(v_cena\) is distinct from v_row\.scene_hash/);
  assert.match(f, /set status = 'erro', erro_sanitizado = 'cena alterada; sincronize os jobs do componente'/);
  // Contrato mínimo do worker (10 colunas) e NADA de aula inteira/questões/gabarito/dados pessoais.
  assert.match(f, /returns table \(\s+asset_id uuid,\s+aula_versao_id uuid,\s+componente_id uuid,\s+quadro_indice smallint,\s+scene_hash text,\s+cena text,\s+tentativa smallint,\s+claim_token uuid,\s+lease_ate timestamptz,\s+storage_path_esperado text\s+\)/);
  for (const proibido of [/questoes/i, /gabarito/i, /estrutura/i, /usuario/i, /matricula/i, /perfis/i, /prompt_visual/i]) assert.doesNotMatch(f, proibido, String(proibido));
  assert.match(f, /volatile\s+security definer\s+set search_path to ''/);
});

test("Q10-8: path esperado carrega o claim_token (nenhuma tentativa sobrescreve o arquivo de outra)", () => {
  const esperado = "aula_versao_id::text || '/' || v_row.componente_id::text || '/' || v_row.quadro_indice::text\n    || '/' || left(v_row.scene_hash, 10) || '-' ";
  assert.ok(fn("reservar_quadrinho_asset").replace(/\s+/g, " ").includes("left(v_row.scene_hash, 10) || '-' || v_token::text || '.webp'"), esperado);
  assert.ok(fn("concluir_quadrinho_asset").replace(/\s+/g, " ").includes("left(v_row.scene_hash, 10) || '-' || p_claim_token::text || '.webp'"));
});

test("Q10-9: concluir — FENCING por claim_token, resultado obsoleto recusado, idempotente, auditável, nunca aprova", () => {
  const f = fn("concluir_quadrinho_asset");
  assert.match(f, /\(\s+p_asset_id uuid, p_claim_token uuid, p_scene_hash text, p_storage_path text,\s+p_modelo text, p_prompt_version text, p_prompt_visual text\s+\)/);
  assert.match(f, /returns table \(aceito boolean, motivo text, status_final text\)/);
  assert.match(f, /v_row\.status <> 'gerando' or v_row\.claim_token is distinct from p_claim_token/);
  assert.match(f, /motivo := 'claim_invalido'/);
  assert.match(f, /v_row\.status = 'gerada' and v_row\.storage_path = p_storage_path/);
  assert.match(f, /motivo := 'ja_concluido'/);
  assert.match(f, /p_scene_hash is distinct from v_row\.scene_hash/);
  assert.match(f, /p_storage_path <> v_esperado/);
  assert.match(f, /public\.hash_cena_quadrinho\(v_cena\) is distinct from v_row\.scene_hash/);
  assert.match(f, /motivo := 'cena_alterada'/);
  assert.match(f, /select q\.\* into v_row from public\.aula_quadrinho_assets q where q\.id = p_asset_id for update;/);
  assert.match(f, /length\(p_prompt_visual\) > 8000/);
  const upd = f.match(/set status = 'gerada', storage_path = p_storage_path[\s\S]*?where q\.id = p_asset_id;/)?.[0] ?? "";
  assert.ok(upd.length > 0);
  for (const trecho of [/modelo = p_modelo/, /prompt_version = p_prompt_version/, /prompt_visual = p_prompt_visual/, /lease_ate = null/, /claim_token = null/, /erro_sanitizado = null/, /atualizado_em = now\(\)/]) assert.match(upd, trecho, String(trecho));
  assert.doesNotMatch(upd, /aprovad/i, "concluir NUNCA aprova");
});

test("Q10-10: falhar — fencing, erro sanitizado (chave/Bearer/JWT/base64/quebra de linha, 300 chars), retry até 3 tentativas", () => {
  const f = fn("falhar_quadrinho_asset");
  assert.match(f, /v_row\.status <> 'gerando' or v_row\.claim_token is distinct from p_claim_token/);
  for (const re of [/sk-\[A-Za-z0-9_-\]\{8,\}/, /Bearer\\s\+/, /eyJ\[A-Za-z0-9_-\]\{10,\}/, /\[A-Za-z0-9\+\/\]\{80,\}/, /\[\\r\\n\]\+/, /left\(v_erro, 300\)/]) assert.match(f, re, String(re));
  assert.match(f, /v_final := case when v_row\.tentativas < 3 then 'pendente' else 'erro' end;/);
  assert.match(f, /set status = v_final, erro_sanitizado = v_erro, lease_ate = null, claim_token = null, atualizado_em = now\(\)/);
  for (const proibido of [/resposta/i, /headers?\b/i, /stack/i]) assert.doesNotMatch(f, proibido, String(proibido));
});

test("Q10-11: criar jobs — admin primeiro, 3..6 quadros, cenas validadas antes de escrever, idempotente, invalida sem apagar", () => {
  const f = fn("criar_jobs_quadrinho_admin");
  assert.ok(f.indexOf("public.eh_admin()") > -1 && f.indexOf("public.eh_admin()") < f.indexOf("aula_versoes av where av.id"), "eh_admin antes de qualquer leitura");
  assert.match(f, /v_n < 3 or v_n > 6/);
  assert.match(f, /public\.quadrinho_componente\(p_aula_versao_id, p_componente_id\)/);
  assert.ok(f.indexOf("sem cena valida") < f.indexOf("insert into public.aula_quadrinho_assets"), "valida todas as cenas antes do primeiro INSERT");
  assert.match(f, /on conflict on constraint aula_quadrinho_assets_chave_key do nothing/);
  assert.match(f, /acao := 'criado'/); assert.match(f, /acao := 'inalterado'/); assert.match(f, /acao := 'invalidado'/); assert.match(f, /acao := 'fora_do_array'/);
  assert.match(f, /if v_row\.scene_hash = v_hash then/);
  assert.match(f, /v_row\.status = 'gerando' and v_row\.lease_ate > now\(\)/);
  assert.match(f, /perform public\.quadrinho_asset_reiniciar\(v_row\.id, v_hash\)/);
  assert.doesNotMatch(f, /\bdelete\b/i, "sincronizar nunca apaga");
  assert.doesNotMatch(f, /update public\.aula_versoes|insert into public\.aula_versoes|status = 'publicada'/i, "não publica nem altera a aula");
  assert.doesNotMatch(f, /storage\.objects/);
});

test("Q10-12: reiniciar/regenerar — path atual vai para storage_path_anterior; nunca apaga arquivo; recusa se o anterior ainda existir", () => {
  const h = fn("quadrinho_asset_reiniciar");
  assert.match(h, /public\.quadrinho_path_no_storage\(v_ant\)/);
  assert.match(h, /raise exception 'LIMPEZA_PENDENTE/);
  assert.match(h, /storage_path_anterior = coalesce\(v_atual, q\.storage_path_anterior\),\s+storage_path = null,/);
  for (const trecho of [/status = 'pendente'/, /tentativas = 0/, /lease_ate = null/, /claim_token = null/, /erro_sanitizado = null/, /aprovado_por = null/, /aprovado_em = null/, /modelo = null/, /prompt_version = null/, /prompt_visual = null/, /atualizado_em = now\(\)/]) assert.match(h, trecho, String(trecho));
  const r = fn("regenerar_quadrinho_asset_admin");
  assert.match(r, /v_row\.status = 'gerando' and v_row\.lease_ate > now\(\)/);
  assert.match(r, /Asset em geracao \(lease ativo\)/);
  assert.match(r, /public\.hash_cena_atual_quadrinho\(v_row\.aula_versao_id, v_row\.componente_id, v_row\.quadro_indice\)/);
  assert.match(r, /returns table \(asset_id uuid, status_final text, hash_cena text, path_anterior text\)/);
  assert.doesNotMatch(h + r, /\bdelete\b|storage\.objects\s*where[^)]*delete/i);
});

test("Q10-13: aprovar exige `gerada` + storage_path + hash atual; grava aprovado_por = auth.uid(); rejeitar limpa aprovação sem apagar arquivo", () => {
  const a = fn("aprovar_quadrinho_asset_admin");
  assert.match(a, /v_row\.status <> 'gerada'/);
  assert.match(a, /v_row\.storage_path is null/);
  assert.match(a, /v_hash_atual is distinct from v_row\.scene_hash/);
  assert.match(a, /CENA_ALTERADA/);
  assert.match(a, /set status = 'aprovada', aprovado_por = auth\.uid\(\), aprovado_em = now\(\), atualizado_em = now\(\)/);
  const j = fn("rejeitar_quadrinho_asset_admin");
  assert.match(j, /v_row\.status not in \('gerada', 'aprovada'\)/);
  assert.match(j, /set status = 'rejeitada', aprovado_por = null, aprovado_em = null, atualizado_em = now\(\)/);
  assert.doesNotMatch(j, /storage_path = null|delete/i, "arquivo permanece");
});

test("Q10-14: exclusão em 2 fases — preparar tira de circulação; excluir só apaga a linha se NENHUM path existir em storage.objects", () => {
  const p = fn("preparar_exclusao_quadrinho_asset_admin");
  assert.match(p, /set status = 'rejeitada', aprovado_por = null, aprovado_em = null, atualizado_em = now\(\)/);
  assert.match(p, /path_atual := v_row\.storage_path; path_anterior := v_row\.storage_path_anterior/);
  assert.doesNotMatch(p, /\bdelete\b/i);
  const e = fn("excluir_quadrinho_asset_admin");
  assert.match(e, /public\.quadrinho_path_no_storage\(v_row\.storage_path\)/);
  assert.match(e, /public\.quadrinho_path_no_storage\(v_row\.storage_path_anterior\)/);
  assert.equal((e.match(/ARQUIVO_AINDA_EXISTE/g) ?? []).length, 2);
  assert.ok(e.indexOf("ARQUIVO_AINDA_EXISTE") < e.indexOf("delete from public.aula_quadrinho_assets"), "verifica o Storage antes de apagar a linha");
  const s = fn("quadrinho_path_no_storage");
  assert.match(s, /from storage\.objects o where o\.bucket_id = 'quadrinhos-aulas' and o\.name = p_path/);
  assert.doesNotMatch(s, /\bdelete\b|\binsert\b|\bupdate\b/i, "helper só lê");
});

test("Q10-15: SECURITY DEFINER + search_path vazio nas 9 RPCs; eh_admin() é a primeira instrução das 6 admin", () => {
  for (const nome of [...WORKER, ...ADMIN]) assert.match(fn(nome), /security definer\s+set search_path to ''/, nome);
  for (const nome of HELPERS) assert.match(fn(nome), /set search_path to ''/, nome);
  for (const nome of ADMIN) {
    const f = fn(nome);
    const corpoFn = f.slice(f.indexOf("begin"));
    assert.match(corpoFn, /^begin\s+if not public\.eh_admin\(\) then\s+raise exception 'Apenas administradores/, `${nome}: eh_admin() primeiro`);
  }
  for (const nome of WORKER) assert.doesNotMatch(fn(nome), /eh_admin|auth\.uid/, `${nome}: worker não depende de usuário`);
});

test("Q10-16: TODO update da tabela atualiza atualizado_em = now() explicitamente (sem trigger)", () => {
  const partes = corpo.split(/update public\.aula_quadrinho_assets/).slice(1);
  assert.ok(partes.length >= 11, `esperado ≥11 updates, encontrado ${partes.length}`);
  for (const p of partes) {
    const stmt = p.slice(0, p.search(/\bwhere\b/));
    assert.match(stmt, /atualizado_em = now\(\)/, `update sem atualizado_em: ${stmt.slice(0, 80)}`);
  }
  assert.doesNotMatch(applySql, /create trigger/i);
});

test("Q10-17: grants — worker só service_role; helpers fechados; admin só authenticated; anon revogado em tudo", () => {
  for (const nome of WORKER) {
    assert.match(corpo, new RegExp(`revoke all on function public\\.${nome}\\([^)]*\\) from public, anon, authenticated;`), `revoke ${nome}`);
    assert.match(corpo, new RegExp(`grant execute on function public\\.${nome}\\([^)]*\\) to service_role;`), `grant service_role ${nome}`);
    assert.doesNotMatch(corpo, new RegExp(`grant execute on function public\\.${nome}\\([^)]*\\) to (authenticated|anon|public)`), `${nome} não pode ir a clientes`);
  }
  for (const nome of HELPERS) assert.match(corpo, new RegExp(`revoke all on function public\\.${nome}\\([^)]*\\) from public, anon, authenticated;`), `revoke ${nome}`);
  for (const nome of ADMIN) {
    assert.match(corpo, new RegExp(`revoke all on function public\\.${nome}\\([^)]*\\) from public, anon;`), `revoke ${nome}`);
    assert.match(corpo, new RegExp(`grant execute on function public\\.${nome}\\([^)]*\\) to authenticated;`), `grant ${nome}`);
  }
  assert.equal((corpo.match(/grant execute/g) ?? []).length, 9);
  assert.doesNotMatch(corpo, /\bgrant\b[^;]*\bto\b[^;]*\b(anon|public)\b/i);
});

test("Q10-18: pós-condições do apply cobrem colunas, CHECKs, índice, fundação Q9 intacta, grants e lease", () => {
  const pos = secaoSql(apply, "SECAO_POSCOND");
  for (const trecho of [
    /claim_token:uuid:YES,storage_path_anterior:text:YES/, /contype = 'c'\) <> 9/, /aula_quadrinho_assets_path_anterior_key/,
    /has_table_privilege\(v_papel, v_rel, v_priv\)/, /funcao da Q9 alterada/, /bucket'/,
    /has_function_privilege\('service_role', v_fn::regprocedure, 'execute'\)/, /position\('public\.eh_admin\(\)' in pg_get_functiondef/,
    /quadrinho_asset_lease\(\) <> interval '10 minutes'/,
  ]) assert.match(pos, trecho, String(trecho));
});

test("Q10-19: harness cobre fencing, lease, tentativas, sanitização, aprovação, rejeição, regeneração, sincronização e exclusão", () => {
  for (const chave of [
    "claims_sequenciais_obtem_4_assets_distintos", "claim_5_nao_recebe_nada_lease_valido_nao_e_roubado",
    "concluir_token_errado_recusado_sem_tocar_na_linha", "concluir_claim_atual_aceito", "concluir_duas_vezes_mesmo_path_e_idempotente",
    "lease_expirado_e_recuperavel_com_novo_token_e_tentativa_2", "worker_antigo_nao_conclui_apos_perder_o_claim", "worker_antigo_nao_falha_a_linha_do_novo_dono",
    "novo_dono_do_claim_conclui", "tentativa_4_nunca_ocorre_e_lease_expirado_sem_tentativas_vira_erro", "nenhuma_tentativa_passa_de_3_em_nenhuma_linha",
    "falhar_1_de_3_volta_a_pendente_para_retry", "falhar_guarda_apenas_erro_sanitizado", "falhar_na_3a_tentativa_vira_erro_terminal",
    "claim_com_cena_alterada_nao_gera_e_marca_erro", "concluir_com_cena_alterada_recusa_resultado_obsoleto",
    "criar_gera_exatamente_4_linhas_pendentes", "criar_idempotente_nao_duplica", "criar_menos_de_3_quadros_bloqueado", "criar_mais_de_6_quadros_bloqueado",
    "admin_nao_admin_bloqueado_nas_6_rpcs", "admin_sem_autenticacao_bloqueado_nas_6_rpcs",
    "aprovar_asset_em_erro_bloqueado", "aprovar_com_cena_alterada_bloqueado_e_nao_aprova", "aprovar_gerada_com_hash_atual",
    "rejeitar_aprovada_limpa_aprovacao_e_mantem_arquivo", "regenerar_rejeitada_novo_ciclo_e_devolve_path_anterior",
    "regenerar_com_lease_valido_bloqueado", "regenerar_aprovada_remove_aprovacao_e_move_atual_para_anterior",
    "sincronizar_cena_alterada_invalida_e_arquiva_arquivo_sem_apagar", "sincronizar_bloqueada_com_lease_valido",
    "preparar_exclusao_devolve_paths_e_deixa_de_servir", "excluir_apaga_a_linha_quando_o_arquivo_nao_existe_mais_no_storage", "excluir_com_lease_valido_bloqueado",
    "authenticated_nao_executa_reservar", "authenticated_nao_executa_concluir", "authenticated_nao_executa_falhar", "anon_nao_executa_rpc_admin",
    "service_role_executa_reservar_sem_jobs_retorna_vazio", "authenticated_nao_admin_bloqueado_via_eh_admin",
    "check_gerando_exige_token_e_lease", "check_nao_gerando_nao_pode_ter_token", "check_path_anterior_diferente_do_atual", "unique_parcial_path_anterior",
    "escopo_unica_relacao_nova_e_o_indice", "escopo_funcoes_novas_exatas", "escopo_funcoes_q9_e_rpcs_existentes_intactas", "escopo_nenhuma_policy_nova_ou_removida",
    "old_final_colunas_da_tabela_como_na_Q9", "old_final_aula_versoes_e_aulas_identicas", "old_final_relacoes_e_funcoes_iguais_ao_snapshot",
    "nenhum_objeto_no_bucket_durante_todo_o_teste",
  ]) assert.ok(harness.includes(`'${chave}'`), `harness sem o teste ${chave}`);
  assert.match(harnessSql, /raise exception 'HARNESS Q10: testes com falha: %'/);
  // Fixtures só em aula_quadrinho_assets; sem tocar matrículas/perfis/objetivos; mutações da estrutura só em sub-blocos desfeitos.
  assert.doesNotMatch(harnessSql, /(insert into|update|delete from)\s+public\.(matriculas|perfis|objetivos|missoes|aulas)\b/i);
  assert.ok((harness.match(/raise exception 'q10_desfazer'/g) ?? []).length >= 6, "mutações de estrutura desfeitas por sub-bloco");
});

test("Q10-20: reverter fail-safe — aborta com worker em andamento ou ponteiro de arquivo; sem CASCADE; não toca a Q9", () => {
  const g = secaoSql(reverter, "SECAO_REVERT_GUARDA");
  assert.match(g, /status = 'gerando' or claim_token is not null/);
  assert.match(g, /if v_n > 0 then\s+raise exception 'REVERT: % linha\(s\) em geracao/);
  assert.match(g, /storage_path_anterior is not null/);
  assert.match(g, /REVERT: pipeline ausente/);
  assert.doesNotMatch(reverterSql, /\bcascade\b/i);
  const c = secaoSql(reverter, "SECAO_REVERT_CORPO");
  for (const nome of [...WORKER, ...ADMIN, ...HELPERS]) assert.match(c, new RegExp(`drop function public\\.${nome}\\(`), `drop ${nome}`);
  assert.match(c, /drop index public\.aula_quadrinho_assets_path_anterior_key;/);
  assert.match(c, /drop column claim_token,\s+drop column storage_path_anterior;/);
  assert.doesNotMatch(reverterSql, /drop table|storage\.buckets|drop function public\.(hash_cena|carregar_quadrinho)|delete from/i);
  assert.ok(reverterSql.indexOf("SECAO_REVERT_GUARDA") < reverterSql.indexOf("drop function"), "guarda antes de qualquer DROP");
  assert.equal((reverterSql.match(/^\s*commit;\s*$/gim) ?? []).length, 1);
});

test("Q10-21: pós-check é SOMENTE leitura, um único SELECT, cobrindo colunas, grants, fundação Q9, bucket, policies, cron e Vault", () => {
  assert.match(posCheckSql.trim(), /^select/i);
  assert.equal((posCheckSql.match(/;/g) ?? []).length, 1);
  assert.doesNotMatch(posCheckSql, /\b(insert|update|delete|create|alter|drop|grant|revoke|truncate|comment|call|do)\b\s/i);
  for (const coluna of [
    "colunas_corretas", "nove_checks", "check_claim_coerente", "check_path_anterior", "indice_unico_path_anterior", "q9_pk_unique_indices", "q9_rls_habilitado",
    "q9_tabela_sem_policy", "q9_clientes_sem_acesso_direto", "q9_funcoes_inalteradas", "bucket_intacto", "sem_policy_de_storage_para_o_bucket",
    "policies_de_storage_inalteradas", "quatorze_funcoes_sem_duplicata", "helpers_fechados_para_clientes", "worker_fechado_para_clientes",
    "worker_service_role_executa", "admin_rpcs_authenticated_definer", "worker_rpcs_definer_search_path_vazio", "lease_10_minutos", "cron_inalterado",
    "vault_inalterado", "linhas_na_tabela", "objetos_no_bucket",
  ]) assert.match(posCheckSql, new RegExp(`\\bas ${coluna}\\b`), coluna);
});

test("Q10-22: escopo — nenhuma Edge, Image API, OpenAI, upload, cron novo, Vault, policy ou alteração de aula/frontend nesta fase", () => {
  for (const [nome, sql] of [["apply", applySql], ["reverter", reverterSql], ["pos-check", posCheckSql]]) {
    assert.doesNotMatch(sql, /cron\.schedule|net\.http|vault\.(create_secret|update_secret|delete_secret|decrypted_secrets)|create policy|create trigger|api\.openai\.com|images\/generations/i, nome);
    assert.doesNotMatch(sql, /\b(insert into|update|delete from)\s+public\.(aulas|aula_versoes|aula_geracoes|unidades_pedagogicas|matriculas|missoes)\b/i, nome);
  }
  assert.doesNotMatch(applySql, /1f4065f2|52756262|33a2dcd4/, "o SQL de apply não conhece o piloto");
  for (const dir of ["gerar-arte-quadro", "assinar-quadrinho-assets"]) assert.ok(!existsSync(path.join(raiz, "supabase/functions", dir)), `Edge ${dir} não deve existir nesta fase`);
});

test("Q10-23: segurança — nenhum segredo, JWT, chave, URL assinada ou valor de Vault em nenhum arquivo do pacote", () => {
  for (const [nome, sql] of [["apply", apply], ["harness", harness], ["pos-check", posCheck], ["reverter", reverter]]) {
    for (const padrao of [/eyJ[A-Za-z0-9_-]{15,}\.[A-Za-z0-9_-]{10,}\./, /sk-[A-Za-z0-9_-]{20,}/, /sbp_[A-Za-z0-9]{20,}/, /\/object\/sign\//, /[?&]token=/, /decrypted_secret/, /service_role_key\s*[:=]/i, /SUPABASE_SERVICE_ROLE_KEY\s*=/]) {
      assert.doesNotMatch(sql, padrao, `${nome}: ${padrao}`);
    }
  }
});

test("Q10-24: compatível com a RPC do aluno da Q9 (inalterada) e com a futura Edge de assinatura", () => {
  // A RPC do aluno só serve status='aprovada' + storage_path + hash atual (Q9). O pipeline termina exatamente nisso.
  assert.match(baseQ9, /and q\.status = 'aprovada'/);
  assert.match(baseQ9, /q\.scene_hash = public\.hash_cena_atual_quadrinho/);
  assert.match(baseQ9, /select q\.id, q\.componente_id, q\.quadro_indice, q\.storage_path, q\.scene_hash/, "só storage_path atual é servido (nunca storage_path_anterior/claim_token)");
  assert.doesNotMatch(baseQ9, /storage_path_anterior|claim_token/);
  // O pipeline escreve o hash pela MESMA função da Q9 e a aprovação exige hash atual: nada obsoleto chega ao aluno.
  assert.match(fn("criar_jobs_quadrinho_admin"), /public\.hash_cena_quadrinho\(/);
  assert.match(fn("aprovar_quadrinho_asset_admin"), /public\.hash_cena_atual_quadrinho\(/);
  // Nenhuma policy de Storage: a assinatura continua server-side.
  assert.doesNotMatch(applySql, /create policy/i);
});
