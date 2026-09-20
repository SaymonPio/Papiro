import assert from "node:assert/strict";
import test from "node:test";
import { readFileSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

// Q12.3-SEC — testes ESTÁTICOS do pacote de hardening de eh_admin() (nada é executado contra o banco).
const raiz = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const ler = (f) => readFileSync(path.join(raiz, "supabase", f), "utf8");
const apply = ler("hardening_eh_admin_sessao.sql");
const harness = ler("hardening_eh_admin_sessao_teste_rollback.sql");
const revert = ler("reverter_hardening_eh_admin_sessao.sql");
const pos = ler("pos_check_hardening_eh_admin_sessao.sql");
const secao = (sql, nome) => sql.match(new RegExp(`-- >>> ${nome}[^\\n]*\\n([\\s\\S]*?)-- <<< ${nome}`))?.[1] ?? "";
const semComentarios = (s) => s.replace(/^\s*--.*$/gm, "");

test("Q12.3-SEC-1: o corpo do harness é idêntico ao do apply", () => {
  assert.ok(secao(apply, "SECAO_CORPO").length > 200);
  assert.equal(secao(harness, "SECAO_CORPO"), secao(apply, "SECAO_CORPO"));
});

test("Q12.3-SEC-2: eh_admin novo exige uid + regra de admin atual + session_id + sessão viva do mesmo usuário; propriedades mantidas", () => {
  const corpo = secao(apply, "SECAO_CORPO");
  for (const trecho of ["returns boolean", "language sql", "stable", "security definer", "set search_path to ''", "auth.uid() is not null",
    "from public.administradores a", "a.usuario_id = auth.uid()", "auth.jwt() ->> 'session_id'", "from auth.sessions s",
    "s.id::text = (auth.jwt() ->> 'session_id')", "s.user_id = auth.uid()", "s.not_after is null or s.not_after > now()"]) assert.ok(corpo.includes(trecho), trecho);
  assert.doesNotMatch(corpo, /::uuid/, "comparação por texto: session_id malformado não pode gerar erro de cast");
  assert.doesNotMatch(semComentarios(apply), /\b(grant|revoke|alter function|drop function|alter table|create policy)\b/i, "sem mexer em grants/policies/objetos");
});

test("Q12.3-SEC-3: o apply só roda sobre a definição legada e o rollback restaura exatamente a legada", () => {
  assert.match(apply, /select exists \( select 1 from public\.administradores where usuario_id = auth\.uid\(\) \);/);
  assert.match(revert, /13a7f536a885cf02c754249b0a1060ce/);
  assert.match(pos, /13a7f536a885cf02c754249b0a1060ce/);
  const legado = revert.match(/as \$\$([\s\S]*?)\$\$;/)?.[1].replace(/\s+/g, " ").trim();
  assert.equal(legado, "select exists ( select 1 from public.administradores where usuario_id = auth.uid() );");
});

test("Q12.3-SEC-4: harness cobre ativa, revogada, expirada, sem claim, malformada, legado, sem sub, não-admin, sessão alheia, dependente e ACL; termina em ROLLBACK", () => {
  for (const caso of ["sessao ativa => true", "sessao revogada => false", "sessao expirada", "sem session_id", "malformado", "legado", "sem sub", "nao-admin", "session_id de outro usuario", "carregar_quadrinho_assets_admin", "ACL inalteradas"]) assert.ok(harness.includes(caso), caso);
  assert.match(harness.trim(), /rollback;$/);
  assert.doesNotMatch(semComentarios(harness), /\bcommit\b(?! drop)/i);
  assert.doesNotMatch(harness, /eyJ[A-Za-z0-9_-]{15,}/, "sem token real");
});

test("Q12.3-SEC-5: sem segredos em nenhum arquivo do pacote e o pós-check é somente leitura", () => {
  for (const s of [apply, harness, revert, pos]) assert.doesNotMatch(s, /eyJ[A-Za-z0-9_-]{15,}\.|sk-[A-Za-z0-9_-]{20,}|sbp_[A-Za-z0-9]{20,}/);
  assert.doesNotMatch(semComentarios(pos), /\b(insert|update|delete|create|drop|alter|grant|revoke|truncate)\b/i);
});
