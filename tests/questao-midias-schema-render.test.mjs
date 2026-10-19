import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";
import { tratarRequisicao, TTL_SEGUNDOS, validarEntrada } from "../supabase/functions/_shared/questao-midias/handler.mjs";
import { aplicarUrlsAssinadas, interpretarMetadadosMidias, segmentarEnunciado } from "../components/questoes/midiasQuestao.ts";

// PAPIRO — mídias de questões: schema/permissões (leitura estática da migration; o comportamento real de RLS,
// triggers e bucket foi conferido contra o banco numa transação terminada em ROLLBACK), Edge de assinatura
// (regras de segurança com deps injetadas) e renderização (lógica pura + ligação na tela).

const MIGRATION = fs.readFileSync(new URL("../supabase/migrations/20261019120000_questao_midias.sql", import.meta.url), "utf8");
const comandos = MIGRATION.replace(/--.*$/gm, "");
const PAGINA = fs.readFileSync(new URL("../app/questoes/page.tsx", import.meta.url), "utf8");
const CSS = fs.readFileSync(new URL("../app/globals.css", import.meta.url), "utf8");
const EDGE = fs.readFileSync(new URL("../supabase/functions/assinar-questao-midias/index.ts", import.meta.url), "utf8");

test("SCHEMA) questao_midias: FK para questoes, 1:N com ordem e sha únicos por questão, hash obrigatório, path derivado do sha", () => {
  assert.match(comandos, /questao_id bigint not null references public\.questoes\(id\) on delete cascade/);
  assert.match(comandos, /sha256 text not null check \(sha256 ~ '\^\[0-9a-f\]\{64\}\$'\)/);
  assert.match(comandos, /unique \(questao_id, ordem\)/);
  assert.match(comandos, /unique \(questao_id, sha256\)/);
  assert.match(comandos, /storage_path = 'questoes\/' \|\| sha256 \|\|/);
  assert.match(comandos, /prova_id bigint references public\.provas\(id\) on delete restrict/);
  assert.match(comandos, /\(prova_id is null\) = \(pagina_origem is null\)/);
  assert.match(comandos, /alt_text text not null/);
  assert.match(comandos, /direito_uso text not null default 'REVISAO_DIREITOS' check \(direito_uso in \('OFICIAL_PROVA', 'LICENCIADO', 'REVISAO_DIREITOS'\)\)/);
  assert.match(comandos, /tipo in \('FIGURA', 'GRAFICO', 'TABELA', 'MAPA', 'CHARGE'\)/);
  assert.doesNotMatch(comandos, /alter table public\.questoes/, "questoes não ganha coluna");
});

test("SCHEMA) mídia removida não quebra questão em silêncio: triggers de proteção + questão ativa exige mídias publicáveis", () => {
  assert.match(comandos, /before insert or update or delete on public\.questao_midias/);
  assert.match(comandos, /desative-a antes de remover a mídia/);
  assert.match(comandos, /são imutáveis/);
  assert.match(comandos, /before update of ativa on public\.questoes/);
  assert.match(comandos, /when \(new\.ativa and not old\.ativa\)/);
});

test("K) RLS: nada para anon; aluno só lê mídia publicável de questão ativa visível; admin via eh_admin(); bucket privado SEM policy", () => {
  assert.match(comandos, /alter table public\.questao_midias enable row level security;/);
  assert.match(comandos, /revoke all on public\.questao_midias from anon, authenticated;/);
  assert.doesNotMatch(comandos, /grant[^;]*\bto anon\b/);
  const politicas = [...comandos.matchAll(/create policy[\s\S]*?;/g)].map((m) => m[0]);
  assert.equal(politicas.length, 2);
  assert.ok(politicas.some((p) => /for all/.test(p) && /using \(public\.eh_admin\(\)\)/.test(p) && /with check \(public\.eh_admin\(\)\)/.test(p)));
  const leitura = politicas.find((p) => /for select/.test(p));
  assert.match(leitura, /direito_uso in \('OFICIAL_PROVA', 'LICENCIADO'\)/);
  assert.match(leitura, /q\.ativa/);
  assert.match(leitura, /q\.usuario_id is null or q\.usuario_id = \(select auth\.uid\(\)\)/);
  assert.match(comandos, /values \('questao-midias', 'questao-midias', false, 2097152, array\['image\/png', 'image\/jpeg', 'image\/webp'\]\)/);
  assert.doesNotMatch(comandos, /on storage\.objects/, "nenhuma policy de storage: só service_role grava e assina");
});

// ---- Edge assinar-questao-midias ----

function requisicao(corpo, { metodo = "POST", auth = "Bearer token-do-aluno" } = {}) {
  return new Request("https://edge.local/assinar-questao-midias", { method: metodo, headers: auth ? { Authorization: auth } : {}, body: metodo === "POST" ? JSON.stringify(corpo) : undefined });
}
const SHA = "a".repeat(64);
const linhaRls = (questaoId, ordem, extra = {}) => ({ questao_id: questaoId, ordem, tipo: "FIGURA", storage_path: `questoes/${SHA.slice(0, 63)}${ordem}.png`, largura: 300, altura: 80, alt_text: `Figura ${ordem}`, legenda: `Figura ${ordem} – Painel`, credito: null, ancora_texto: `Figura ${ordem} – Painel`, direito_uso: "OFICIAL_PROVA", ...extra });
function deps({ linhas = [linhaRls(10, 1)], assinar } = {}) {
  const chamadas = { leitura: [], assinadas: [] };
  return {
    chamadas,
    autenticar: async (auth) => (auth ? { ok: true } : { ok: false, status: 401, mensagem: "Sessão não encontrada." }),
    carregarMidias: async (ids) => {
      chamadas.leitura.push(ids);
      return linhas;
    },
    assinar:
      assinar ??
      (async (paths, ttl) => {
        chamadas.assinadas.push({ paths, ttl });
        return paths.map((p) => ({ path: p, signedUrl: `https://storage.local/assinado/${p}?token=x` }));
      }),
    agora: () => Date.parse("2026-10-19T12:00:00Z"),
  };
}

test("EDGE) sem sessão 401; método/corpo inválidos 400/405; ids validados (1..50 inteiros, sem repetição)", async () => {
  assert.equal((await tratarRequisicao(requisicao({ questaoIds: [1] }, { auth: null }), deps())).status, 401);
  assert.equal((await tratarRequisicao(requisicao(null, { metodo: "GET" }), deps())).status, 405);
  for (const corpo of [{}, { questaoIds: [] }, { questaoIds: ["1"] }, { questaoIds: [0] }, { questaoIds: Array.from({ length: 51 }, (_, i) => i + 1) }]) {
    assert.equal((await tratarRequisicao(requisicao(corpo), deps())).status, 400, JSON.stringify(corpo));
  }
  assert.deepEqual(validarEntrada({ questaoIds: [3, 3, 4] }).valor.questaoIds, [3, 4]);
});

test("EDGE) assina SÓ o que a leitura autorizada (RLS) devolveu; nunca expõe storage_path/sha/direito; descarta linha suspeita", async () => {
  const d = deps({
    linhas: [
      linhaRls(10, 2),
      linhaRls(10, 1),
      linhaRls(99, 1), // questão não pedida
      linhaRls(10, 3, { direito_uso: "REVISAO_DIREITOS" }), // defesa extra: a RLS já não devolveria
      linhaRls(10, 4, { storage_path: "../../editais/x.pdf" }),
      linhaRls(10, 5, { alt_text: "" }),
    ],
  });
  const resposta = await tratarRequisicao(requisicao({ questaoIds: [10] }), d);
  assert.equal(resposta.status, 200);
  const { midias } = await resposta.json();
  assert.deepEqual(midias.map((m) => [m.questao_id, m.ordem]), [[10, 1], [10, 2]]);
  assert.equal(d.chamadas.assinadas[0].ttl, TTL_SEGUNDOS);
  assert.equal(d.chamadas.assinadas[0].paths.length, 2);
  for (const m of midias) {
    assert.equal(m.storage_path, undefined);
    assert.equal(m.sha256, undefined);
    assert.equal(m.direito_uso, undefined);
    assert.match(m.url, /^https:\/\//);
    assert.equal(m.expira_em, "2026-10-19T12:15:00.000Z");
  }
});

test("EDGE) assinatura falhou: mídias continuam na resposta com url=null (o app mostra indisponível, não esconde)", async () => {
  const resposta = await tratarRequisicao(requisicao({ questaoIds: [10] }), deps({ assinar: async () => { throw new Error("storage fora"); } }));
  const { midias } = await resposta.json();
  assert.equal(midias.length, 1);
  assert.equal(midias[0].url, null);
});

test("EDGE) index.ts: autorização pelo client DO USUÁRIO (RLS) e service_role só para assinar", () => {
  assert.match(EDGE, /usuario!\s*\.from\("questao_midias"\)/);
  assert.match(EDGE, /createSignedUrls\(paths, ttlSegundos\)/);
  assert.equal((EDGE.match(/SUPABASE_SERVICE_ROLE_KEY/g) ?? []).length, 1);
});

// ---- Renderização ----

const AGORA = Date.parse("2026-10-19T12:00:00Z");
const meta = (ordem, ancora, extra = {}) => ({ questao_id: 7, ordem, tipo: "FIGURA", largura: 301, altura: 83, alt_text: `Figura ${ordem} – Botão`, legenda: `Figura ${ordem} – Botão`, credito: null, ancora_texto: ancora, ...extra });

test("RENDER) mídia antes da linha-âncora; sem âncora (ou âncora que não bate) depois do enunciado — nunca descartada", () => {
  const enunciado = "Assinale a função do botão ilustrado na Figura 1 abaixo.\nFigura 1 – Botão do Google Chrome";
  const mapa = interpretarMetadadosMidias([meta(1, "Figura 1 – Botão do Google Chrome"), meta(2, null), meta(3, "linha que não existe mais")]);
  const segmentos = segmentarEnunciado(enunciado, mapa.get(7));
  assert.deepEqual(segmentos.map((s) => (s.tipo === "texto" ? `T:${s.texto}` : `M:${s.midia.ordem}`)), [
    "T:Assinale a função do botão ilustrado na Figura 1 abaixo.",
    "M:1",
    "T:Figura 1 – Botão do Google Chrome",
    "M:2",
    "M:3",
  ]);
  assert.deepEqual(segmentarEnunciado(enunciado, []), [{ tipo: "texto", texto: enunciado }]);
});

test("RENDER) URLs da Edge: só https e não expirada; sem URL = indisponível (url null), metadados são a fonte de verdade", () => {
  const mapa = interpretarMetadadosMidias([meta(1, null), meta(2, null), { questao_id: 7, ordem: 3 }]);
  assert.equal(mapa.get(7).length, 2, "linha sem alt_text/dimensões é descartada");
  const com = aplicarUrlsAssinadas(mapa, { midias: [{ questao_id: 7, ordem: 1, url: "https://x/1", expira_em: "2026-10-19T12:15:00Z" }, { questao_id: 7, ordem: 2, url: "http://inseguro/2", expira_em: "2026-10-19T12:15:00Z" }] }, AGORA);
  assert.deepEqual(com.get(7).map((m) => m.url), ["https://x/1", null]);
  const expirada = aplicarUrlsAssinadas(mapa, { midias: [{ questao_id: 7, ordem: 1, url: "https://x/1", expira_em: "2026-10-19T11:59:00Z" }] }, AGORA);
  assert.equal(expirada.get(7)[0].url, null);
  assert.deepEqual(aplicarUrlsAssinadas(mapa, "lixo", AGORA).get(7).map((m) => m.url), [null, null], "Edge fora: tudo indisponível, nada some");
});

test("RENDER) tela /questoes: enunciado via EnunciadoComMidias, metadados por RLS sem storage_path, URLs pela Edge", () => {
  assert.match(PAGINA, /<EnunciadoComMidias enunciado=\{questaoAtual\.enunciado\} midias=\{midiasPorQuestao\.get\(questaoAtual\.id\) \?\? \[\]\}/);
  const select = PAGINA.match(/\.from\("questao_midias"\)\s*\.select\("([^"]+)"\)/)[1];
  assert.doesNotMatch(select, /storage_path|sha256|direito_uso/);
  assert.match(PAGINA, /functions\.invoke\("assinar-questao-midias"/);
  assert.match(PAGINA, /podeRenovar\(renovacaoMidias\.current, agora\)/, "renovação após erro limitada (sem laço)");
});

test("RENDER) CSS: imagem responsiva que nunca estica (max-width 100% + height auto) e crédito discreto", () => {
  assert.match(CSS, /\.question-card \.question-media img \{[^}]*max-width: 100%;[^}]*height: auto;/);
  assert.match(CSS, /\.question-card \.question-media-credit \{[^}]*font-size: 12px;/);
  assert.match(CSS, /\.question-card \.question-media-unavailable \{/);
  const componente = fs.readFileSync(new URL("../components/questoes/EnunciadoComMidias.tsx", import.meta.url), "utf8");
  assert.match(componente, /width=\{segmento\.midia\.largura\}/);
  assert.match(componente, /height=\{segmento\.midia\.altura\}/);
  assert.match(componente, /alt=\{segmento\.midia\.altText\}/);
  assert.match(componente, /Imagem indisponível no momento/);
});
