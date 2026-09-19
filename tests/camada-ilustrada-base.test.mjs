import assert from "node:assert/strict";
import test from "node:test";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import path from "node:path";

// Fase Q9 — pacote SQL da fundação da camada ilustrada (tabela de assets,
// hash da cena, RPCs de leitura e bucket privado). O SQL NÃO é executado aqui
// (nem no LIVE nesta fase): estes testes garantem, estruturalmente, que o
// pacote preparado tem o contrato decidido, que o harness reutiliza EXATAMENTE
// as mesmas seções do apply/reverter e que nada perigoso entrou no pacote.

const raiz = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const ler = (relativo) => readFileSync(path.join(raiz, relativo), "utf8");

const apply = ler("supabase/camada_ilustrada_base.sql");
const harness = ler("supabase/camada_ilustrada_base_teste_rollback.sql");
const posCheck = ler("supabase/pos_check_camada_ilustrada_base.sql");
const reverter = ler("supabase/reverter_camada_ilustrada_base.sql");
const rpcLeituraAula = ler("supabase/unidades_pedagogicas_leitura_rpc.sql");

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

function trechoFuncao(sql, nome) {
  const ini = sql.indexOf(`create function public.${nome}(`);
  assert.ok(ini > -1, `create function ${nome}`);
  const fim = sql.indexOf("\n$$;", ini);
  assert.ok(fim > ini, `fim de ${nome}`);
  return sql.slice(ini, fim + 4);
}

const secaoSql = (texto, nome) => semComentarios(secao(texto, nome));
const corpo = secaoSql(apply, "SECAO_CORPO");

test("Q9-1: os quatro arquivos do pacote existem e o apply é uma única transação (BEGIN ... COMMIT)", () => {
  assert.match(applySql, /^\s*begin;/i);
  assert.equal((applySql.match(/^\s*commit;\s*$/gim) ?? []).length, 1);
  assert.equal((applySql.match(/^\s*begin;\s*$/gim) ?? []).length, 1);
  assert.ok(posCheck.length > 0 && reverter.length > 0 && harness.length > 0);
});

test("Q9-2: o harness NUNCA faz COMMIT, começa com BEGIN e termina obrigatoriamente com ROLLBACK", () => {
  assert.equal((harnessSql.match(/^\s*commit\s*;/gim) ?? []).length, 0);
  assert.match(harnessSql, /^\s*BEGIN;/);
  assert.match(harnessSql.trimEnd(), /ROLLBACK;$/);
  assert.equal((harnessSql.match(/^\s*BEGIN;\s*$/gm) ?? []).length, 1);
  // Nenhuma operação não transacional: sem CREATE/DROP DATABASE|INDEX CONCURRENTLY, VACUUM, cron, HTTP, storage upload.
  for (const proibido of [/\bconcurrently\b/i, /\bvacuum\b/i, /cron\.schedule/i, /net\.http/i, /vault\./i, /storage\.objects\s+\(/i]) {
    assert.doesNotMatch(harnessSql, proibido, String(proibido));
  }
});

test("Q9-3: as seções PRECOND/CORPO/POSCOND do harness são idênticas às do apply (byte a byte)", () => {
  for (const nome of ["SECAO_PRECOND", "SECAO_CORPO", "SECAO_POSCOND"]) {
    assert.equal(secao(harness, nome), secao(apply, nome), nome);
  }
});

test("Q9-4: as seções REVERT do harness são idênticas às do reverter real", () => {
  for (const nome of ["SECAO_REVERT_GUARDA", "SECAO_REVERT_CORPO", "SECAO_REVERT_POSCOND"]) {
    assert.equal(secao(harness, nome), secao(reverter, nome), nome);
  }
});

test("Q9-5: tabela aula_quadrinho_assets com o schema mínimo decidido", () => {
  const t = corpo.match(/create table public\.aula_quadrinho_assets \(([\s\S]*?)\n\);/)?.[1] ?? "";
  assert.ok(t.length > 0);
  for (const linha of [
    /id uuid primary key default gen_random_uuid\(\)/,
    /aula_versao_id uuid not null references public\.aula_versoes\(id\) on delete cascade/,
    /componente_id uuid not null,/,
    /quadro_indice smallint not null,/,
    /scene_hash text not null,/,
    /status text not null default 'pendente',/,
    /storage_path text null,/,
    /modelo text null,/,
    /prompt_version text null,/,
    /prompt_visual text null,/,
    /tentativas smallint not null default 0,/,
    /lease_ate timestamptz null,/,
    /erro_sanitizado text null,/,
    /aprovado_por uuid null,/,
    /aprovado_em timestamptz null,/,
    /criado_em timestamptz not null default now\(\),/,
    /atualizado_em timestamptz not null default now\(\),/,
  ]) {
    assert.match(t, linha, String(linha));
  }
  // Campos que NÃO devem existir (nada "por precaução").
  for (const extra of ["width", "height", "mime_type", "checksum", "tamanho"]) {
    assert.doesNotMatch(t, new RegExp(`\\b${extra}\\b`), extra);
  }
  // Sem FK em componente_id (UUID interno do JSON) nem em aprovado_por.
  assert.doesNotMatch(t, /componente_id uuid not null references/);
  assert.doesNotMatch(t, /aprovado_por uuid null references/);
  assert.equal((t.match(/references/g) ?? []).length, 1, "só a FK para aula_versoes");
});

test("Q9-6: constraints — UNIQUE da chave, CHECKs de faixa/hash/status/tentativas e coerência de status", () => {
  assert.match(corpo, /constraint aula_quadrinho_assets_chave_key unique \(aula_versao_id, componente_id, quadro_indice\)/);
  assert.match(corpo, /check \(quadro_indice between 0 and 5\)/);
  assert.match(corpo, /check \(scene_hash ~ '\^\[0-9a-f\]\{64\}\$'\)/);
  assert.match(corpo, /check \(status in \('pendente', 'gerando', 'gerada', 'aprovada', 'rejeitada', 'erro'\)\)/);
  assert.match(corpo, /check \(tentativas between 0 and 3\)/);
  assert.match(corpo, /check \(status not in \('gerada', 'aprovada'\) or storage_path is not null\)/);
  assert.match(corpo, /check \(status <> 'aprovada' or aprovado_em is not null\)/);
  // Sem máquina de estados rígida: nada de check ligando status a lease/tentativas/erro.
  assert.doesNotMatch(corpo, /check \([^)]*(lease_ate|erro_sanitizado|prompt_visual)[^)]*\)/);
  // UNIQUE parcial de storage_path (dois assets nunca compartilham arquivo).
  assert.match(corpo, /create unique index aula_quadrinho_assets_storage_path_key\s+on public\.aula_quadrinho_assets \(storage_path\)\s+where storage_path is not null;/);
  // Caminho seguro: rejeita '..' e caminho absoluto.
  assert.match(corpo, /storage_path !~ '\(\^\/\|\\\.\\\.\)'/);
});

test("Q9-7: RLS habilitado, sem policies, e revoke total para anon/authenticated (padrão de aulas/aula_versoes)", () => {
  assert.match(corpo, /alter table public\.aula_quadrinho_assets enable row level security;/);
  assert.match(corpo, /revoke all on table public\.aula_quadrinho_assets from public, anon, authenticated;/);
  assert.doesNotMatch(applySql, /create policy/i);
  assert.doesNotMatch(applySql, /grant\s+(select|insert|update|delete|all)[^;]*on\s+(table\s+)?public\.aula_quadrinho_assets/i);
});

test("Q9-8: hash canônico — SHA-256 hex de NFC(trim(cena)), IMMUTABLE, search_path vazio, rejeita NULL/vazio", () => {
  const f = trechoFuncao(corpo, "hash_cena_quadrinho");
  assert.match(f, /returns text\s+language plpgsql\s+immutable\s+set search_path to ''/);
  assert.match(f, /normalize\(btrim\(p_cena, E' \\t\\r\\n'\), NFC\)/);
  assert.match(f, /encode\(sha256\(convert_to\(v_norm, 'UTF8'\)\), 'hex'\)/);
  assert.match(f, /if p_cena is null then\s+raise exception/);
  assert.match(f, /if length\(v_norm\) = 0 then\s+raise exception/);
  assert.doesNotMatch(f, /auth\.uid|current_user|session_user|now\(\)|random/i, "determinística e independente de usuário");
});

test("Q9-9: hash da cena atual localiza o componente pelo id, exige quadrinho_didatico, valida o índice e lê a cena", () => {
  const f = trechoFuncao(corpo, "hash_cena_atual_quadrinho");
  assert.match(f, /lower\(c\.value->>'id'\) = p_componente_id::text/);
  assert.match(f, /c\.value->>'tipo' = 'quadrinho_didatico'/);
  assert.match(f, /p_quadro_indice >= jsonb_array_length\(v_comp->'quadros'\)/);
  assert.match(f, /p_quadro_indice < 0/);
  assert.match(f, /jsonb_typeof\(v_quadro->'cena'\) is distinct from 'string'/);
  assert.match(f, /return public\.hash_cena_quadrinho\(v_cena\);/);
  assert.match(f, /set search_path to ''/);
  assert.doesNotMatch(f, /security definer/i);
});

test("Q9-10: RPC do aluno reproduz a autorização de carregar_aula_publicada_da_missao (mesmos predicados)", () => {
  const f = trechoFuncao(corpo, "carregar_quadrinho_assets_aula");
  assert.match(f, /\(p_missao_id uuid, p_aula_versao_id uuid\)/);
  assert.match(f, /security definer\s+set search_path to ''/);
  // Trechos-chave da RPC real que entrega o texto (repositório) precisam existir nas duas.
  const real = rpcLeituraAula.replace(/\s+/g, " ");
  const nova = f.replace(/\s+/g, " ");
  const pares = [
    ["v_usuario_id := auth.uid();", "v_usuario_id := auth.uid();"],
    ["if v_usuario_id is null then raise exception 'Usuario nao autenticado'; end if;", "if v_usuario_id is null then raise exception 'Usuario nao autenticado'; end if;"],
    ["from public.missoes ms join public.matriculas m on m.id=ms.matricula_id", "from public.missoes ms join public.matriculas m on m.id = ms.matricula_id"],
    ["where ms.id=p_missao_id and m.usuario_id=v_usuario_id and m.status='ativa'", "where ms.id = p_missao_id and m.usuario_id = v_usuario_id and m.status = 'ativa'"],
    ["raise exception 'Missao nao encontrada, nao pertence ao usuario autenticado, ou a matricula nao esta ativa'", "raise exception 'Missao nao encontrada, nao pertence ao usuario autenticado, ou a matricula nao esta ativa'"],
    ["join public.aulas a on a.unidade_pedagogica_id=u.id and a.ativa", "join public.aulas a on a.unidade_pedagogica_id = u.id and a.ativa"],
    ["join public.aula_versoes av on av.aula_id=a.id and av.status='publicada'", "join public.aula_versoes av on av.aula_id = a.id and av.status = 'publicada'"],
    ["where u.curso_conteudo_id=v_conteudo_id and u.ativa order by u.ordem limit 1", "where u.curso_conteudo_id = v_conteudo_id and u.ativa order by u.ordem limit 1"],
  ];
  for (const [noReal, naNova] of pares) {
    assert.ok(real.includes(noReal), `RPC real deveria conter: ${noReal}`);
    assert.ok(nova.includes(naNova), `RPC de assets deveria conter: ${naNova}`);
  }
  // A versão pedida precisa ser exatamente a acessível àquela missão; senão, nada é retornado.
  assert.match(f, /p_aula_versao_id is distinct from v_versao_acessivel/);
  assert.match(f, /if v_versao_acessivel is null or p_aula_versao_id is distinct from v_versao_acessivel then\s+return;/);
  // Não basta matrícula no curso: nada de usuario_pode_comentar_aula / curso_id.
  assert.doesNotMatch(f, /usuario_pode_comentar_aula|curso_materias|m\.curso_id/);
});

test("Q9-11: RPC do aluno só devolve aprovada + storage_path + scene_hash igual ao hash da cena ATUAL, sem dados internos", () => {
  const f = trechoFuncao(corpo, "carregar_quadrinho_assets_aula");
  assert.match(f, /returns table \(\s+asset_id uuid,\s+componente_id uuid,\s+quadro_indice smallint,\s+storage_path text,\s+scene_hash text\s+\)/);
  assert.match(f, /and q\.status = 'aprovada'/);
  assert.match(f, /and q\.storage_path is not null/);
  assert.match(f, /and q\.scene_hash = public\.hash_cena_atual_quadrinho\(q\.aula_versao_id, q\.componente_id, q\.quadro_indice\)/);
  assert.match(f, /order by q\.componente_id, q\.quadro_indice/);
  const select = f.match(/return query\s+select ([\s\S]*?)\s+from public\.aula_quadrinho_assets q/)?.[1] ?? "";
  for (const interno of ["prompt_visual", "modelo", "erro_sanitizado", "aprovado_por", "lease_ate", "tentativas", "prompt_version"]) {
    assert.doesNotMatch(select, new RegExp(interno), `aluno não pode receber ${interno}`);
  }
});

test("Q9-12: RPC admin — eh_admin() primeiro, todos os status, scene_hash_atual/asset_atual, não exclui nada", () => {
  const f = trechoFuncao(corpo, "carregar_quadrinho_assets_admin");
  assert.match(f, /\(p_aula_versao_id uuid\)/);
  assert.match(f, /security definer\s+set search_path to ''/);
  const iAdmin = f.indexOf("if not public.eh_admin() then");
  assert.ok(iAdmin > -1 && iAdmin < f.indexOf("return query"), "guarda de admin antes de qualquer leitura");
  assert.match(f, /raise exception 'Apenas administradores podem visualizar assets de quadrinhos'/);
  assert.doesNotMatch(f, /q\.status\s*(=|<>|in)/, "admin recebe todos os status");
  assert.match(f, /h\.hash_atual is not null and h\.hash_atual = q\.scene_hash/);
  for (const coluna of ["scene_hash_atual", "asset_atual", "prompt_visual", "modelo", "prompt_version", "tentativas", "erro_sanitizado", "aprovado_por", "aprovado_em", "criado_em", "atualizado_em", "storage_path"]) {
    assert.match(f, new RegExp(`\\b${coluna}\\b`), coluna);
  }
  assert.doesNotMatch(f, /\b(delete|update|insert)\b/i, "leitura pura");
});

test("Q9-13: grants — helpers fechados; RPCs só para authenticated; anon revogado", () => {
  assert.match(corpo, /revoke all on function public\.hash_cena_quadrinho\(text\) from public, anon, authenticated;/);
  assert.match(corpo, /revoke all on function public\.hash_cena_atual_quadrinho\(uuid, uuid, smallint\) from public, anon, authenticated;/);
  assert.match(corpo, /revoke all on function public\.carregar_quadrinho_assets_aula\(uuid, uuid\) from public, anon;/);
  assert.match(corpo, /revoke all on function public\.carregar_quadrinho_assets_admin\(uuid\) from public, anon;/);
  assert.match(corpo, /grant execute on function public\.carregar_quadrinho_assets_aula\(uuid, uuid\) to authenticated;/);
  assert.match(corpo, /grant execute on function public\.carregar_quadrinho_assets_admin\(uuid\) to authenticated;/);
  assert.equal((corpo.match(/grant execute/g) ?? []).length, 2, "nenhum outro grant de função");
  assert.doesNotMatch(corpo, /to anon|to public/i);
});

test("Q9-14: bucket privado, só WebP, 256 KiB, INSERT simples (nunca reconfigura bucket alheio) e SEM policies de storage", () => {
  assert.match(corpo, /insert into storage\.buckets \(id, name, public, file_size_limit, allowed_mime_types\)\s+values \('quadrinhos-aulas', 'quadrinhos-aulas', false, 262144, array\['image\/webp'\]\);/);
  assert.doesNotMatch(corpo, /on conflict/i);
  for (const sql of [applySql, harnessSql]) {
    assert.doesNotMatch(sql, /create policy[^;]*storage\.objects/i);
    assert.doesNotMatch(sql, /drop policy/i);
  }
  assert.doesNotMatch(applySql, /(insert into|update|delete from)\s+storage\.objects/i);
});

test("Q9-15: fail-safe — o apply aborta se algo do pacote já existir ou se a autorização da RPC de leitura mudou", () => {
  const pre = secaoSql(apply, "SECAO_PRECOND");
  for (const trecho of [
    /to_regclass\('public\.aula_quadrinho_assets'\) is not null/,
    /from storage\.buckets where id = 'quadrinhos-aulas' or name = 'quadrinhos-aulas'/,
    /p\.proname in \('hash_cena_quadrinho', 'hash_cena_atual_quadrinho', 'carregar_quadrinho_assets_aula', 'carregar_quadrinho_assets_admin'\)/,
    /like '%quadrinhos-aulas%'/,
    /position\('m\.status=''ativa''' in v_def\) = 0/,
    /position\('av\.status=''publicada''' in v_def\) = 0/,
    /normalize\(chr\(97\) \|\| chr\(769\), NFC\) is distinct from chr\(225\)/,
    /raise exception 'PRECOND: %', v_problemas/,
  ]) {
    assert.match(pre, trecho, String(trecho));
  }
  assert.doesNotMatch(applySql, /create or replace function|create table if not exists|drop table|drop function|on conflict/i, "nunca sobrescreve objeto existente");
});

test("Q9-16: pós-condições do apply cobrem colunas, RLS, privilégios, FK, UNIQUE, CHECKs, funções, bucket e vetores de hash", () => {
  const pos = secaoSql(apply, "SECAO_POSCOND");
  for (const trecho of [
    /v_colunas is distinct from v_esperado/,
    /relrowsecurity/,
    /has_table_privilege\(v_papel, v_rel, v_priv\)/,
    /confrelid = 'public\.aula_versoes'::regclass and confdeltype = 'c'/,
    /aula_quadrinho_assets_chave_key/,
    /contype = 'c'\) <> 7/,
    /aula_quadrinho_assets_storage_path_key/,
    /prosecdef/,
    /proconfig @> array\['search_path=""'\]/,
    /v_bucket\.public is distinct from false/,
    /file_size_limit is distinct from 262144/,
    /allowed_mime_types is distinct from array\['image\/webp'\]/,
    /ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad/,
    /Jose' \|\| chr\(769\)/,
  ]) {
    assert.match(pos, trecho, String(trecho));
  }
});

test("Q9-17: harness cobre o TARGET (hash, constraints, RPC aluno/admin, papéis reais, escopo e reversão)", () => {
  for (const chave of [
    "hash_vetor_sha256_abc", "hash_trim_equivalente", "hash_nfc_composto_igual_decomposto", "hash_rejeita_null", "hash_rejeita_vazio",
    "check_quadro_indice_maximo_5", "check_quadro_indice_minimo_0", "check_scene_hash_rejeita_maiuscula", "check_scene_hash_rejeita_tamanho",
    "check_status_invalido", "check_tentativas_maximo_3", "coerencia_gerada_exige_storage_path", "coerencia_aprovada_exige_aprovado_em",
    "unique_chave_aula_componente_indice", "unique_parcial_storage_path", "fk_aula_versao_id_existente",
    "cena_atual_indice_fora_do_array_nulo", "cena_atual_componente_nao_quadrinho_nulo",
    "admin_ve_todos_os_status", "admin_asset_atual_false_quando_cena_mudou", "admin_nao_exclui_asset_obsoleto", "admin_rpc_bloqueia_nao_admin",
    "aluno_recebe_somente_aprovada_com_hash_atual", "aluno_retorna_apenas_5_colunas_sem_dados_internos", "aluno_versao_rascunho_nao_retorna_assets",
    "aluno_versao_de_outra_aula_nao_retorna_assets", "aluno_missao_de_outro_usuario_bloqueada", "aluno_sem_autenticacao_bloqueado",
    "aluno_cena_mudou_asset_obsoleto_nao_retorna", "aluno_reordenacao_de_quadros_invalida_asset",
    "authenticated_sem_select_direto_na_tabela", "anon_sem_select_direto_na_tabela", "anon_nao_executa_rpc_aluno",
    "authenticated_executa_rpc_aluno_via_security_definer", "storage_sem_policy_para_quadrinhos_aulas", "bucket_privado_webp_256kib",
    "escopo_relacoes_novas_exatas", "escopo_funcoes_novas_exatas", "escopo_nenhuma_policy_nova", "escopo_aula_versoes_intactas",
    "escopo_rpcs_existentes_intactas", "reverter_restaura_relacoes_funcoes_e_buckets",
    "old_final_matriculas_restauradas", "old_final_missoes_intactas", "old_final_aula_versoes_identicas", "old_final_aulas_identicas",
    "old_final_contagens_iguais", "old_final_rpcs_existentes_identicas", "old_final_policies_iguais_ao_baseline", "old_final_grants_iguais_ao_baseline",
  ]) {
    assert.ok(harness.includes(`'${chave}'`), `harness sem o teste ${chave}`);
  }
  assert.match(harnessSql, /'aluno_matricula_' \|\| v_st \|\| '_bloqueada'/);
  assert.match(harnessSql, /array\['cancelada', 'expirada'\]/);
  // Fixtures só na transação: nada de commit/savepoint solto e a tabela de resultados é temporária.
  // OLD_FINAL vem depois do REVERT e antes do ROLLBACK, e restaura as fixtures dentro da transação.
  assert.ok(harness.indexOf("-- OLD_FINAL") > harness.indexOf("SECAO_REVERT_POSCOND"));
  assert.ok(harness.indexOf("-- OLD_FINAL") < harness.lastIndexOf("ROLLBACK;"));
  assert.match(harnessSql, /update public.matriculas m set status = o.status from _q9_old_matriculas o/);
  assert.match(harnessSql, /update public.aula_versoes av set estrutura = o.estrutura from _q9_old_versoes o/);
  assert.match(harnessSql, /create temporary table teste_q9/);
  assert.match(harnessSql, /raise exception 'HARNESS Q9: testes com falha: %'/);
});

test("Q9-18: reverter é fail-safe — aborta com linhas na tabela, objetos no bucket ou policy; sem CASCADE; bucket só vazio", () => {
  const g = secaoSql(reverter, "SECAO_REVERT_GUARDA");
  assert.match(g, /if v_linhas > 0 then\s+raise exception/);
  assert.match(g, /from storage\.objects where bucket_id = 'quadrinhos-aulas'/);
  assert.match(g, /if v_objetos > 0 then\s+raise exception/);
  assert.match(g, /like '%quadrinhos-aulas%'/);
  const c = secaoSql(reverter, "SECAO_REVERT_CORPO");
  assert.match(c, /drop function public\.carregar_quadrinho_assets_aula\(uuid, uuid\);/);
  assert.match(c, /drop function public\.carregar_quadrinho_assets_admin\(uuid\);/);
  assert.match(c, /drop function public\.hash_cena_atual_quadrinho\(uuid, uuid, smallint\);/);
  assert.match(c, /drop function public\.hash_cena_quadrinho\(text\);/);
  assert.match(c, /drop table public\.aula_quadrinho_assets;/);
  assert.match(c, /set_config\('storage\.allow_delete_query', 'true', true\)/, "flag SÓ local (is_local = true)");
  assert.match(c, /delete from storage\.buckets where id = 'quadrinhos-aulas';/);
  assert.match(c, /set_config\('storage\.allow_delete_query', 'false', true\)/);
  assert.doesNotMatch(reverterSql, /\bcascade\b/i);
  assert.doesNotMatch(reverterSql, /delete from storage\.objects/i, "imagens nunca são apagadas");
  assert.match(reverterSql, /^\s*begin;/i);
  assert.equal((reverterSql.match(/^\s*commit;\s*$/gim) ?? []).length, 1);
  // A guarda vem ANTES de qualquer DROP.
  assert.ok(reverterSql.indexOf("SECAO_REVERT_GUARDA") < reverterSql.indexOf("drop function"));
});

test("Q9-19: pós-check é SOMENTE leitura e cobre tabela, constraints, grants, RLS, funções, bucket, policies e duplicatas", () => {
  assert.match(posCheckSql.trim(), /^select/i);
  assert.equal((posCheckSql.match(/;/g) ?? []).length, 1, "um único SELECT");
  assert.doesNotMatch(posCheckSql, /\b(insert|update|delete|create|alter|drop|grant|revoke|truncate|comment|call|do)\b\s/i);
  for (const coluna of [
    "tabela_existe", "colunas_corretas", "pk_unica", "fk_aula_versoes_cascade", "unique_chave", "sete_checks", "indice_unico_storage_path",
    "rls_habilitado", "tabela_sem_policy", "anon_sem_acesso_direto", "authenticated_sem_acesso_direto", "quatro_funcoes_sem_duplicata",
    "helpers_fechados_para_clientes", "rpc_aluno_definer_search_path_vazio", "rpc_admin_definer_search_path_vazio", "rpc_aluno_grants",
    "rpc_admin_grants", "hash_immutable", "hash_vetores_ok", "bucket_unico", "bucket_privado", "bucket_limite_256kib", "bucket_somente_webp",
    "sem_policy_de_storage_para_o_bucket", "policies_de_storage_inalteradas", "linhas_na_tabela", "objetos_no_bucket",
  ]) {
    assert.match(posCheckSql, new RegExp(`\\bas ${coluna}\\b`), coluna);
  }
});

test("Q9-20: escopo — nada de jobs de geração, aprovação, exclusão ou claim nesta fase; nada toca aulas/aula_versoes/piloto", () => {
  for (const sql of [applySql, reverterSql]) {
    assert.doesNotMatch(sql, /create function public\.(reservar|concluir|falhar|aprovar|rejeitar|excluir|criar_jobs)/i);
    assert.doesNotMatch(sql, /\b(insert into|update|delete from)\s+public\.(aulas|aula_versoes|aula_geracoes|unidades_pedagogicas|matriculas|missoes)\b/i);
  }
  assert.doesNotMatch(applySql, /alter table public\.aula_versoes|alter table public\.aulas/i);
  assert.doesNotMatch(applySql, /1f4065f2|52756262|33a2dcd4/, "o SQL de apply não conhece o piloto");
});

test("Q9-21: segurança — nenhum segredo, JWT, URL assinada ou valor de Vault em nenhum arquivo do pacote", () => {
  for (const [nome, sql] of [["apply", apply], ["harness", harness], ["pos-check", posCheck], ["reverter", reverter]]) {
    for (const padrao of [/eyJ[A-Za-z0-9_-]{15,}/, /sk-[A-Za-z0-9_-]{20,}/, /sbp_[A-Za-z0-9]{20,}/, /\/object\/sign\//, /[?&]token=/, /decrypted_secret/, /vault\./i, /service_role_key\s*[:=]/i, /SUPABASE_SERVICE_ROLE_KEY\s*=/]) {
      assert.doesNotMatch(sql, padrao, `${nome}: ${padrao}`);
    }
  }
});

test("Q9-22: compatível com a futura Edge de assinatura (JWT do usuário → RPC autoriza → service_role assina em lote)", () => {
  // A RPC do aluno devolve só o necessário para assinar (paths) e é executável com o JWT do usuário.
  const f = trechoFuncao(corpo, "carregar_quadrinho_assets_aula");
  assert.match(f, /storage_path text/);
  assert.match(corpo, /grant execute on function public\.carregar_quadrinho_assets_aula\(uuid, uuid\) to authenticated;/);
  // Nenhum acesso direto do cliente ao Storage é criado (a assinatura é server-side).
  assert.doesNotMatch(applySql, /create policy/i);
  assert.match(apply, /assinatura de URLs será server-side/);
});
