import assert from "node:assert/strict";
import test from "node:test";
import { existsSync, readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import path from "node:path";

// Fase Q11.2 — pacote SQL do GC seguro de uploads órfãos (detecção + classificação +
// reconfirmação). O SQL NÃO é executado aqui (nem no LIVE nesta fase): estes testes
// garantem, estruturalmente, o contrato decidido, que o harness reutiliza EXATAMENTE
// as seções do apply/reverter, que as funções do Q10 só mudam na expressão do path e
// que nenhuma função remove objeto de Storage.

const raiz = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const ler = (relativo) => readFileSync(path.join(raiz, relativo), "utf8");

const apply = ler("supabase/camada_ilustrada_gc.sql");
const harness = ler("supabase/camada_ilustrada_gc_teste_rollback.sql");
const posCheck = ler("supabase/pos_check_camada_ilustrada_gc.sql");
const reverter = ler("supabase/reverter_camada_ilustrada_gc.sql");
const q10 = ler("supabase/camada_ilustrada_pipeline.sql");

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
const corpoBruto = secao(apply, "SECAO_CORPO");

function fnDe(sql, nome) {
  const ini = sql.indexOf(`function public.${nome}(`);
  assert.ok(ini > -1, `function ${nome}`);
  const fim = sql.indexOf("\n$$;", ini);
  assert.ok(fim > ini, `fim de ${nome}`);
  return sql.slice(ini, fim + 4);
}
const fn = (nome) => fnDe(corpo, nome);
const q10Fn = (nome) => "create " + fnDe(q10, nome);

const NOVAS = ["quadrinho_orphan_grace", "quadrinho_storage_path_claim", "quadrinho_path_canonico", "quadrinho_storage_path_protegido", "quadrinho_upload_orfao_motivo", "listar_quadrinho_uploads_orfaos", "confirmar_quadrinho_upload_orfao"];

test("Q11.2-1: apply em uma transação (BEGIN ... COMMIT); harness só BEGIN ... ROLLBACK", () => {
  assert.match(applySql, /^\s*begin;/i);
  assert.equal((applySql.match(/^\s*commit;\s*$/gim) ?? []).length, 1);
  assert.equal((applySql.match(/^\s*begin;\s*$/gim) ?? []).length, 1);
  assert.match(harnessSql, /^\s*BEGIN;/);
  assert.match(harnessSql.trimEnd(), /ROLLBACK;$/);
  assert.equal((harnessSql.match(/^\s*commit\s*;/gim) ?? []).length, 0);
  assert.equal((harnessSql.match(/^\s*BEGIN;\s*$/gm) ?? []).length, 1);
});

test("Q11.2-2: NENHUM SQL do pacote escreve em storage.objects nem usa Storage API/HTTP/cron/Vault", () => {
  for (const [nome, sql] of [["apply", applySql], ["reverter", reverterSql], ["harness", harnessSql], ["pos-check", posCheckSql]]) {
    assert.doesNotMatch(sql, /(insert into|update|delete from|truncate)\s+storage\./i, `${nome}: escrita em storage.*`);
    assert.doesNotMatch(sql, /\bdelete\b[^;]*\bstorage\b/i, `${nome}: delete tocando storage`);
    for (const proibido of [/net\.http/i, /pg_net/i, /cron\.(schedule|unschedule|alter_job)/i, /vault\.(create_secret|update_secret|delete_secret|decrypted_secrets)/i, /decrypted_secret/i, /functions\/v1/i, /api\.openai\.com/i, /images\/generations/i, /storage\/v1/i, /\bfetch\(/i, /allow_delete_query/i]) {
      assert.doesNotMatch(sql, proibido, `${nome}: ${proibido}`);
    }
  }
  // nas funções do GC não existe nenhum DELETE (nem em tabela alguma)
  for (const nome of NOVAS) assert.doesNotMatch(fn(nome), /\bdelete\b|\binsert\b|\bupdate\b/i, `${nome} só lê`);
});

test("Q11.2-3: seções PRECOND/CORPO/POSCOND do harness idênticas às do apply; REVERT_* idênticas às do reverter", () => {
  for (const nome of ["SECAO_PRECOND", "SECAO_CORPO", "SECAO_POSCOND"]) assert.equal(secao(harness, nome), secao(apply, nome), nome);
  for (const nome of ["SECAO_REVERT_GUARDA", "SECAO_REVERT_CORPO", "SECAO_REVERT_POSCOND"]) assert.equal(secao(harness, nome), secao(reverter, nome), nome);
});

test("Q11.2-4: precondições exigem Q9+Q10 EXATAS (19 colunas, 9 CHECKs, md5 das 18 funções, bucket) e nada do GC existente", () => {
  const pre = secaoSql(apply, "SECAO_PRECOND");
  assert.match(pre, /claim_token:uuid:YES,storage_path_anterior:text:YES/);
  assert.match(pre, /contype = 'c'\) <> 9/);
  for (const [nome, md5] of Object.entries({
    hash_cena_quadrinho: "2779b0d927b88a6946b31636dff13804", hash_cena_atual_quadrinho: "0fd391aacd21da2eb83ad06ec38db44b",
    carregar_quadrinho_assets_aula: "ee2c134d44bdbb00e45f0973eb20e33b", carregar_quadrinho_assets_admin: "4d6a052a6b05e49d585fe2c9360d3b84",
    quadrinho_asset_lease: "a76262802dbb1697663c383565e8140c", quadrinho_componente: "800ed4a3d4b69ae956dd3f6f0226e156",
    cena_atual_quadrinho: "d42813c97e079b7cc96bab6dd3fa513a", quadrinho_path_no_storage: "8c90f2e67adb8f3da8426c6aafcb05e9",
    quadrinho_asset_reiniciar: "0ac31e5664bb8d26f16002c2440aa332", reservar_quadrinho_asset: "96bd1dff900e00997df38fff61b4ef22",
    concluir_quadrinho_asset: "d2ebbc27f62bef833048e1137e99bb70", falhar_quadrinho_asset: "ea019a77c4663648de04437fe8c929fa",
    criar_jobs_quadrinho_admin: "6c834af49817ebf263fa07441ba139ef", aprovar_quadrinho_asset_admin: "9855caa6a1485dd2bd323c291feb8ea0",
    rejeitar_quadrinho_asset_admin: "99fc111dfd4d18e395d21ad987a8c307", regenerar_quadrinho_asset_admin: "237ec790d15cdfcf29310858cb953ad1",
    preparar_exclusao_quadrinho_asset_admin: "ab629c0ac18cdaecba7a32cacda68a9a", excluir_quadrinho_asset_admin: "3bad48fafb9b3a625a43732ee614f118",
  })) assert.ok(pre.includes(`('${nome}', '${md5}')`), `precondição do md5 de ${nome}`);
  assert.match(pre, /file_size_limit = 262144 and allowed_mime_types = array\['image\/webp'\]/);
  assert.match(pre, /raise exception 'PRECOND: %', v_problemas/);
  for (const n of NOVAS) assert.ok(pre.includes(`'${n}'`), `precondição lista ${n}`);
  assert.doesNotMatch(applySql.replace(/create or replace function public\.(reservar|concluir)_quadrinho_asset/g, ""), /create or replace|create table if not exists|drop table|drop function/i, "só reservar/concluir são substituídas");
});

test("Q11.2-5: fórmula do path centralizada, idêntica à do Q10, e reservar/concluir só trocaram essa expressão", () => {
  const h = fn("quadrinho_storage_path_claim");
  assert.match(h, /\(p_aula_versao_id uuid, p_componente_id uuid, p_quadro_indice smallint, p_scene_hash text, p_claim_token uuid\)\s+returns text\s+language sql\s+immutable\s+strict\s+set search_path to ''/);
  assert.ok(h.replace(/\s+/g, " ").includes("p_aula_versao_id::text || '/' || p_componente_id::text || '/' || p_quadro_indice::text || '/' || left(p_scene_hash, 10) || '-' || p_claim_token::text || '.webp'"));
  // O literal '.webp' só existe no helper (fonte única).
  assert.equal((corpo.match(/'\.webp'/g) ?? []).length, 1);
  // Cada função recriada = texto do Q10 com UMA expressão trocada (nada mais mudou).
  const orr = (t) => t.replace(/^create function /, "create or replace function ");
  const trocar = (t, de, para) => { const p = t.split(de); assert.equal(p.length, 2, "1 ocorrência da fórmula do Q10"); return p.join(para); };
  const reservarNovo = trocar(q10Fn("reservar_quadrinho_asset"),
    "    storage_path_esperado := v_row.aula_versao_id::text || '/' || v_row.componente_id::text || '/' || v_row.quadro_indice::text\n      || '/' || left(v_row.scene_hash, 10) || '-' || v_token::text || '.webp';",
    "    storage_path_esperado := public.quadrinho_storage_path_claim(v_row.aula_versao_id, v_row.componente_id, v_row.quadro_indice, v_row.scene_hash, v_token);");
  const concluirNovo = trocar(q10Fn("concluir_quadrinho_asset"),
    "  v_esperado := v_row.aula_versao_id::text || '/' || v_row.componente_id::text || '/' || v_row.quadro_indice::text\n    || '/' || left(v_row.scene_hash, 10) || '-' || p_claim_token::text || '.webp';",
    "  v_esperado := public.quadrinho_storage_path_claim(v_row.aula_versao_id, v_row.componente_id, v_row.quadro_indice, v_row.scene_hash, p_claim_token);");
  assert.ok(corpoBruto.includes(orr(reservarNovo)), "reservar recriada = Q10 + helper");
  assert.ok(corpoBruto.includes(orr(concluirNovo)), "concluir recriada = Q10 + helper");
  // O Q10 continua tendo a fórmula (ainda não modificado) e o GC é aditivo.
  assert.ok(q10.includes("|| '.webp';"));
});

test("Q11.2-6: reverter restaura o texto EXATO do Q10 (byte a byte) e valida por md5; remove só as 7 funções do GC; sem CASCADE", () => {
  const orr = (t) => t.replace(/^create function /, "create or replace function ");
  const c = secao(reverter, "SECAO_REVERT_CORPO");
  assert.ok(c.includes(orr(q10Fn("reservar_quadrinho_asset"))), "reservar original do Q10");
  assert.ok(c.includes(orr(q10Fn("concluir_quadrinho_asset"))), "concluir original do Q10");
  const pos = secaoSql(reverter, "SECAO_REVERT_POSCOND");
  assert.match(pos, /\('reservar_quadrinho_asset', '96bd1dff900e00997df38fff61b4ef22'\)/);
  assert.match(pos, /\('concluir_quadrinho_asset', 'd2ebbc27f62bef833048e1137e99bb70'\)/);
  assert.match(pos, /funcao nao voltou ao texto validado/);
  for (const nome of NOVAS) assert.match(secaoSql(reverter, "SECAO_REVERT_CORPO"), new RegExp(`drop function public\\.${nome}\\(`), `drop ${nome}`);
  assert.doesNotMatch(reverterSql, /\bcascade\b/i);
  assert.doesNotMatch(reverterSql, /drop table|alter table|storage\.buckets/i);
  const g = secaoSql(reverter, "SECAO_REVERT_GUARDA");
  assert.match(g, /GC ausente/);
  assert.match(g, /nao restaurar as cegas/);
  assert.ok(reverterSql.indexOf("SECAO_REVERT_GUARDA") < reverterSql.indexOf("drop function"), "guarda antes de qualquer DROP");
  assert.match(reverterSql, /^\s*begin;/i);
  assert.equal((reverterSql.match(/^\s*commit;\s*$/gim) ?? []).length, 1);
});

test("Q11.2-7: formato canônico — a regex do SQL aceita só UUID/UUID/0-5/10hex-UUID.webp (avaliada em JS)", () => {
  const f = fn("quadrinho_path_canonico");
  const regexSql = f.match(/p_path ~ '(\^[^']+\$)'/)?.[1];
  assert.ok(regexSql, "regex extraída");
  const re = new RegExp(regexSql.replace(/\\\./g, "\\."));
  const v = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee", c = "ffffffff-0000-1111-2222-333333333333", t = "11111111-2222-3333-4444-555555555555";
  const ok = (i) => `${v}/${c}/${i}/0123456789-${t}.webp`;
  for (let i = 0; i <= 5; i++) assert.ok(re.test(ok(i)), `índice ${i}`);
  for (const ruim of [ok(6), ok(9), ok(22), ok(0).toUpperCase(), "/" + ok(0), ok(0) + "x", ok(0).replace(".webp", ".png"), ok(0).replace(".webp", ""),
    ok(0).replace("0123456789", "012345678"), ok(0).replace("0123456789", "0123456789a"), ok(0).replace("0123456789", "0123456789".toUpperCase().replace(/[0-9]/g, "A")),
    "x/" + ok(0), ok(0) + "/extra", `${v}/${c}/0/0123456789-${t}.WEBP`, "_testes/q11-1/x.webp", `../${ok(0)}`, `${v}/../0/0123456789-${t}.webp`,
    "", "   ", ".emptyFolderPlaceholder", `${v.replace(/-/g, "")}/${c}/0/0123456789-${t}.webp`]) {
    assert.ok(!re.test(ruim), `deveria rejeitar: ${ruim}`);
  }
  // O path que o Q10 constrói (formula) é aceito pela regex para todos os índices válidos.
  assert.match(f, /coalesce\(\s+p_path ~ '/);
  assert.match(f, /false\)\s*\$\$;/);
});

test("Q11.2-8: proteção — storage_path, storage_path_anterior e claim_token ATUAL; independente de lease e de aprovação", () => {
  const f = fn("quadrinho_storage_path_protegido");
  assert.match(f, /exists \(select 1 from public\.aula_quadrinho_assets q where q\.storage_path = p_path\)/);
  assert.match(f, /exists \(select 1 from public\.aula_quadrinho_assets q where q\.storage_path_anterior = p_path\)/);
  assert.match(f, /q\.status = 'gerando' and q\.claim_token is not null/);
  assert.match(f, /public\.quadrinho_storage_path_claim\(q\.aula_versao_id, q\.componente_id, q\.quadro_indice, q\.scene_hash, q\.claim_token\) = p_path/);
  assert.doesNotMatch(f, /lease_ate|aprovad|now\(\)/i, "nem lease nem status de aprovação decidem proteção");
  assert.match(f, /returns boolean\s+language sql\s+stable\s+set search_path to ''/);
  assert.match(f, /p_path is not null and \(/);
});

test("Q11.2-9: classificador — ordem padrão → proteções → existência → grace; grace centralizado (30 min em UM lugar)", () => {
  const f = fn("quadrinho_upload_orfao_motivo");
  const ordem = ["quadrinho_path_canonico(p_path)", "quadrinho_storage_path_protegido(p_path)", "p_criado_em is null", "quadrinho_orphan_grace()"].map((t) => f.indexOf(t));
  assert.ok(ordem.every((i) => i > -1) && [...ordem].sort((a, b) => a - b).join() === ordem.join(), "ordem das checagens");
  for (const motivo of ["fora_do_padrao", "protegido_storage_path", "protegido_storage_path_anterior", "protegido_claim_atual", "objeto_inexistente", "recente", "orfao"]) assert.ok(f.includes(`'${motivo}'`), motivo);
  assert.match(f, /p_agora - p_criado_em < public\.quadrinho_orphan_grace\(\)/);
  assert.match(f, /p_agora is null then\s+raise exception/);
  assert.equal((corpo.match(/30 minutes/g) ?? []).length, 1, "o literal de 30 minutos existe só no helper");
  assert.match(fn("quadrinho_orphan_grace"), /returns interval\s+language sql\s+immutable\s+set search_path to ''\s+as \$\$ select interval '30 minutes' \$\$;/);
  // O timestamp explícito NÃO vaza para as RPCs de produção: listar/confirmar usam sempre now().
  assert.match(fn("listar_quadrinho_uploads_orfaos"), /v_agora timestamptz := now\(\);/);
  assert.match(fn("confirmar_quadrinho_upload_orfao"), /quadrinho_upload_orfao_motivo\(p_storage_path, v_criado, now\(\)\)/);
  assert.doesNotMatch(fn("listar_quadrinho_uploads_orfaos"), /p_agora|p_grace|grace timestamp/i);
});

test("Q11.2-10: listar — 1..100, só leitura, só candidatos 'orfao', bucket certo, colunas mínimas, mais antigos primeiro", () => {
  const f = fn("listar_quadrinho_uploads_orfaos");
  assert.match(f, /\(p_limite integer default 100\)/);
  assert.match(f, /returns table \(storage_path text, criado_em timestamptz, atualizado_em timestamptz, tamanho_bytes bigint, idade_segundos integer\)/);
  assert.match(f, /p_limite is null or p_limite < 1 or p_limite > 100/);
  assert.match(f, /raise exception 'p_limite deve estar entre 1 e 100'/);
  assert.match(f, /from storage\.objects o\s+where o\.bucket_id = 'quadrinhos-aulas'/);
  assert.match(f, /o\.is_delete_marker is not true/);
  assert.match(f, /quadrinho_upload_orfao_motivo\(o\.name, greatest\(o\.created_at, o\.updated_at\), v_agora\) = 'orfao'/);
  assert.match(f, /order by greatest\(o\.created_at, o\.updated_at\), o\.name\s+limit p_limite/);
  assert.match(f, /stable\s+security definer\s+set search_path to ''/);
  for (const proibido of [/aula_versoes/, /matriculas/, /usuario/i, /estrutura/, /prompt/i, /questoes/]) assert.doesNotMatch(f, proibido, String(proibido));
});

test("Q11.2-11: confirmar — repete padrão/proteções/existência/idade; orfao=true só se motivo='orfao'; sem escrita", () => {
  const f = fn("confirmar_quadrinho_upload_orfao");
  assert.match(f, /\(p_storage_path text\)\s+returns table \(orfao boolean, motivo text\)/);
  assert.match(f, /p_storage_path is null or length\(btrim\(p_storage_path\)\) = 0 then\s+raise exception 'p_storage_path obrigatorio'/);
  assert.match(f, /from storage\.objects o\s+where o\.bucket_id = 'quadrinhos-aulas' and o\.name = p_storage_path and o\.is_delete_marker is not true/);
  assert.match(f, /orfao := \(v_motivo = 'orfao'\);/);
  assert.match(f, /stable\s+security definer\s+set search_path to ''/);
});

test("Q11.2-12: grants — GC interno; listar/confirmar só service_role; classificador com timestamp nem service_role; anon/authenticated fora de tudo", () => {
  for (const [nome, args] of [["quadrinho_orphan_grace", ""], ["quadrinho_storage_path_claim", "uuid, uuid, smallint, text, uuid"], ["quadrinho_path_canonico", "text"], ["quadrinho_storage_path_protegido", "text"], ["listar_quadrinho_uploads_orfaos", "integer"], ["confirmar_quadrinho_upload_orfao", "text"]]) {
    assert.ok(corpo.includes(`revoke all on function public.${nome}(${args}) from public, anon, authenticated;`), `revoke ${nome}`);
  }
  assert.ok(corpo.includes("revoke all on function public.quadrinho_upload_orfao_motivo(text, timestamptz, timestamptz) from public, anon, authenticated, service_role;"));
  assert.ok(corpo.includes("grant execute on function public.listar_quadrinho_uploads_orfaos(integer) to service_role;"));
  assert.ok(corpo.includes("grant execute on function public.confirmar_quadrinho_upload_orfao(text) to service_role;"));
  assert.equal((corpo.match(/grant execute/g) ?? []).length, 2);
  assert.doesNotMatch(corpo, /\bgrant\b[^;]*\bto\b[^;]*\b(anon|authenticated|public)\b/i);
});

test("Q11.2-13: escopo — sem colunas, tabelas, policies, triggers, cron, status novos; bucket/RPC do aluno intactos", () => {
  assert.doesNotMatch(applySql, /alter table|create table|add column|create policy|create trigger|create index|create extension|cron\./i);
  assert.doesNotMatch(corpo, /storage\.buckets/i, "o bucket só é LIDO na PRECOND, nunca alterado");
  for (const q9 of ["carregar_quadrinho_assets_aula", "carregar_quadrinho_assets_admin", "hash_cena_quadrinho", "hash_cena_atual_quadrinho"]) {
    assert.doesNotMatch(corpo, new RegExp(`function public\\.${q9}\\(`), `${q9} não pode ser recriada`);
  }
  // Só reservar e concluir são recriadas; nenhuma outra função do Q10.
  const recriadas = [...corpo.matchAll(/create or replace function public\.(\w+)\(/g)].map((m) => m[1]);
  assert.deepEqual(recriadas.sort(), ["concluir_quadrinho_asset", "reservar_quadrinho_asset"]);
  assert.equal((corpo.match(/create function public\./g) ?? []).length, 7);
  assert.doesNotMatch(applySql, /(insert into|delete from)\s+public\.(aulas|aula_versoes|matriculas|perfis|objetivos)/i);
});

test("Q11.2-14: corrida listagem→reconfirmação→delete documentada com a justificativa do token único e do fencing", () => {
  const doc = apply.replace(/\n--\s?/g, " ").replace(/\s+/g, " ");
  for (const trecho of [
    "CORRIDA listagem -> reconfirmação -> delete", "gen_random_uuid() novos a cada reserva e nunca reutilizados",
    "só aceita o path calculado com o token ATUAL da linha", 'o estado "órfão" é absorvente',
    "uma falha de delete é inofensiva", "o token é a identidade do worker, o lease só mede tempo",
    "B) é o storage_path_anterior de algum asset (limpeza de regeneração é do fluxo admin)",
  ]) assert.ok(doc.includes(trecho), trecho);
});

test("Q11.2-15: pós-condições do apply cobrem reservar/concluir centralizadas, md5 das demais, grants e comportamento puro", () => {
  const pos = secaoSql(apply, "SECAO_POSCOND");
  for (const trecho of [
    /funcao alterada indevidamente/, /nao usa o helper de path/, /ainda contem a formula de path/, /has_function_privilege\('service_role'/,
    /o classificador com timestamp explicito nao pode ser executavel por service_role/, /quadrinho_orphan_grace\(\) <> interval '30 minutes'/, /POSCOND: formula do path/,
    /POSCOND: fora_do_padrao/, /POSCOND: recente/, /POSCOND: orfao/,
  ]) assert.match(pos, trecho, String(trecho));
});

test("Q11.2-16: harness cobre proteções A/B/C, lease expirado, token antigo, grace, fora do padrão, listar/confirmar, limites, regressão e reversão", () => {
  for (const chave of [
    "escopo_exatamente_7_funcoes_novas", "escopo_so_reservar_e_concluir_mudaram_entre_as_funcoes_existentes", "escopo_sem_novas_colunas_e_constraints_iguais",
    "path_helper_igual_a_formula_literal_do_Q10", "canonico_rejeita_variacoes_e_paths_fora_do_padrao", "grace_e_30_minutos",
    "authenticated_nao_executa_listar", "anon_nao_executa_confirmar", "service_role_nao_executa_classificador_com_timestamp_explicito", "service_role_executa_listar_bucket_vazio_retorna_zero",
    "classificador_fora_do_padrao_nunca_e_candidato_mesmo_antigo", "classificador_canonico_recente_nao_e_candidato", "classificador_grace_no_limite_exato", "classificador_canonico_antigo_sem_referencia_e_orfao",
    "listar_limite_zero_bloqueado", "listar_limite_101_bloqueado", "listar_limites_1_e_100_aceitos", "confirmar_fora_do_padrao_e_falso",
    "reservar_path_igual_ao_helper", "reservar_path_igual_a_formula_literal_do_Q10", "reservar_continua_retornando_as_10_colunas_do_contrato",
    "C_claim_atual_com_lease_valido_e_protegido", "D_claim_atual_com_lease_expirado_continua_protegido", "E_token_A_antigo_deixa_de_proteger_o_path_A",
    "E_path_A_dentro_do_grace_nao_e_candidato", "E_path_A_com_grace_vencido_e_candidato", "E_path_B_do_claim_atual_protegido",
    "fencing_concluir_token_A_recusado", "fencing_falhar_token_A_recusado", "concluir_aceita_o_path_do_helper", "concluir_com_path_do_token_A_e_recusado_para_o_claim_B",
    "A_storage_path_atual_protegido_mesmo_meses_depois", "B_storage_path_anterior_protegido_mesmo_meses_depois", "regenerar_move_o_path_atual_para_anterior",
    "tentativa_4_nunca_ocorre_e_lease_expirado_sem_tentativas_vira_erro", "falhar_1_de_3_volta_a_pendente_e_desprotege_o_path_do_claim",
    "rpcs_de_gc_nao_alteram_nenhuma_linha", "gc_nao_criou_nem_removeu_objetos_no_bucket",
    "reverter_restaura_funcoes_do_Q10_com_md5_exato_e_remove_as_7_do_GC", "old_final_colunas_e_constraints_da_tabela_iguais", "old_final_aula_versoes_aulas_cron_vault_grants_iguais",
  ]) assert.ok(harness.includes(`'${chave}'`), `harness sem o teste ${chave}`);
  assert.match(harnessSql, /raise exception 'HARNESS Q11\.2: testes com falha: %'/);
  // Fixtures só na tabela de assets; sem tocar aula_versoes/matrículas/perfis/objetivos; sem sub-blocos que alterem estrutura.
  assert.doesNotMatch(harnessSql, /(insert into|update|delete from)\s+public\.(aulas|aula_versoes|matriculas|perfis|objetivos|missoes)\b/i);
  // Limite assumido documentado (sem objetos em storage.objects).
  assert.match(harness, /LIMITE ASSUMIDO/);
});

test("Q11.2-17: pós-check é SOMENTE leitura, um único SELECT, cobrindo GC, Q9/Q10, grants, bucket, policies, cron e Vault", () => {
  assert.match(posCheckSql.trim(), /^select/i);
  assert.equal((posCheckSql.match(/;/g) ?? []).length, 1);
  assert.doesNotMatch(posCheckSql, /\b(insert|update|delete|create|alter|drop|grant|revoke|truncate|comment|call|do)\b\s/i);
  for (const coluna of [
    "sete_funcoes_gc_sem_duplicata", "colunas_inalteradas_19", "nove_checks_inalterados", "q9_e_q10_nao_substituidas_inalteradas", "reservar_usa_o_helper_de_path",
    "concluir_usa_o_helper_de_path", "formula_do_path", "formato_canonico", "grace_30_minutos", "gc_fechado_para_clientes", "service_role_executa_listar_e_confirmar",
    "classificador_com_timestamp_nem_service_role", "rpcs_definer_search_path_vazio", "helpers_search_path_vazio", "grants_do_worker_preservados", "rls_da_tabela_intacto",
    "tabela_sem_policy", "bucket_intacto", "sem_policy_de_storage_para_o_bucket", "policies_de_storage_inalteradas", "cron_inalterado", "vault_inalterado",
    "linhas_na_tabela", "objetos_no_bucket", "candidatos_a_orfao_agora",
  ]) assert.match(posCheckSql, new RegExp(`\\bas ${coluna}\\b`), coluna);
});

test("Q11.2-18: segurança e escopo — sem segredos; Edge de GC não existe; contrato da futura Edge documentado", () => {
  for (const [nome, sql] of [["apply", apply], ["harness", harness], ["pos-check", posCheck], ["reverter", reverter]]) {
    for (const padrao of [/eyJ[A-Za-z0-9_-]{15,}\.[A-Za-z0-9_-]{10,}\./, /sk-[A-Za-z0-9_-]{20,}/, /sbp_[A-Za-z0-9]{20,}/, /\/object\/sign\//, /[?&]token=/, /service_role_key\s*[:=]/i, /SUPABASE_SERVICE_ROLE_KEY\s*=/]) {
      assert.doesNotMatch(sql, padrao, `${nome}: ${padrao}`);
    }
  }
  // assinar-quadrinho-assets passou a existir na Q12.12 (coberta por tests/quadrinho-arte-q1212.test.mjs)
  for (const dir of ["limpar-uploads-orfaos-quadrinho"]) assert.ok(!existsSync(path.join(raiz, "supabase/functions", dir)), `Edge ${dir} não deve existir nesta fase`);
  assert.match(apply, /a remoção física é da futura Edge, por Storage API, path a path/);
});
