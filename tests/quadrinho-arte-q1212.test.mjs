import assert from "node:assert/strict";
import test from "node:test";
import { mkdirSync, mkdtempSync, readFileSync, readdirSync, rmSync, writeFileSync, existsSync } from "node:fs";
import { fileURLToPath, pathToFileURL } from "node:url";
import path from "node:path";
import { createRequire } from "node:module";
import { normalizarQuadrinho } from "../components/teoria/tiposComponenteAula.ts";
import {
  ARTE_INTERVALO_MIN_RENOVACAO_MS, ARTE_LIMITE_RENOVACOES_POR_ERRO, ARTE_MARGEM_RENOVACAO_MS, ARTE_TTL_SEGUNDOS,
  chaveArte, idDoComponente, interpretarRespostaArtes, menorExpiracao, podeRenovar, proximaRenovacaoEmMs, textoAltArte,
} from "../components/teoria/arteQuadrinho.ts";
import { CORS, TTL_SEGUNDOS, tratarRequisicao } from "../supabase/functions/_shared/quadrinho-assets/handler.mjs";
import { validarEntrada } from "../supabase/functions/_shared/quadrinho-assets/entrada.mjs";

// Fase Q12.12 — integração das artes aprovadas do quadrinho no renderer (aluno e preview admin) + Edge
// `assinar-quadrinho-assets`. NENHUM teste acessa rede, banco, Storage ou OpenAI: tudo é mock/estático, e o
// fetch global é trocado por uma armadilha para provar isso.
const fetchOriginal = globalThis.fetch;
globalThis.fetch = () => { throw new Error("fetch REAL proibido nos testes da Q12.12"); };
test.after(() => { globalThis.fetch = fetchOriginal; });

const raiz = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const ler = (relativo) => readFileSync(path.join(raiz, relativo), "utf8");
const require = createRequire(import.meta.url);

// ------------------------------------------------------------------ fixtures
const AULA = "52756262-8be4-4fb2-a9f3-2f5a158ea1d4";
const COMP = "1f4065f2-8fda-4f7d-8826-45955230678d";
const MISSAO = "0d6c1c1e-6a0f-4d3e-9b6f-3f0a8f4f7a11";
const OUTRA_MISSAO = "9f1e5b1a-2b7a-4c0e-8d3b-6a4d2c9e0b22";
const AGORA = Date.parse("2026-09-21T12:00:00.000Z");
const expira = (ms = 900_000) => new Date(AGORA + ms).toISOString();
const urlAssinada = (i) => `https://liqybldxsjkygioxfmfh.supabase.co/storage/v1/object/sign/quadrinhos-aulas/arte-${i}.webp?token=t${i}`;

function quadro(cena, extra = {}) {
  return { cena, falas: [{ emissor: "Agente", texto: `Fala de ${cena}` }], legenda: `Legenda de ${cena}`, ...extra };
}
const componentePiloto = (quadros) => ({
  tipo: "quadrinho_didatico", id: COMP, titulo: "Pode entrar à noite?",
  quadros: quadros ?? [quadro("Cena A"), quadro("Cena B"), quadro("Cena C"), quadro("Cena D")],
  fechamento: "Regra de prova: socorro autoriza o ingresso.",
});
const mapaArtes = (indices) => Object.fromEntries(indices.map((i) => [chaveArte(COMP, i), { url: urlAssinada(i), expiraEm: AGORA + 900_000 }]));

// ================================================================== A. NORMALIZAÇÃO
test("Q12.12-1: normalizarQuadrinho preserva indiceOriginal (e o numero visual segue 1..N)", () => {
  const n = normalizarQuadrinho(componentePiloto());
  assert.deepEqual(n.quadros.map((q) => q.indiceOriginal), [0, 1, 2, 3]);
  assert.deepEqual(n.quadros.map((q) => q.numero), [1, 2, 3, 4]);
});

test("Q12.12-2: quadro vazio descartado NÃO desloca o mapeamento: numero visual renumera, indiceOriginal não", () => {
  const n = normalizarQuadrinho(componentePiloto([quadro("Cena A"), { cena: "", falas: [] }, quadro("Cena C")]));
  assert.deepEqual(n.quadros.map((q) => q.numero), [1, 2], "numero visual continua sequencial");
  assert.deepEqual(n.quadros.map((q) => q.indiceOriginal), [0, 2], "índice original preservado (é a chave da arte)");
  assert.deepEqual(n.quadros.map((q) => q.cena), ["Cena A", "Cena C"]);
  // entradas estranhas no meio (não-objeto) também não deslocam
  const n2 = normalizarQuadrinho(componentePiloto([null, quadro("X"), "lixo", quadro("Y")]));
  assert.deepEqual(n2.quadros.map((q) => q.indiceOriginal), [1, 3]);
});

// ================================================================== B. MAPEAMENTO (arteQuadrinho.ts)
test("Q12.12-3: chave = componente_id + quadro_indice; id do componente só vale se for uuid", () => {
  assert.equal(chaveArte(COMP, 2), `${COMP}:2`);
  assert.equal(idDoComponente({ id: COMP.toUpperCase() }), COMP);
  for (const ruim of [undefined, null, 7, "", "nao-e-uuid", `${COMP}x`]) assert.equal(idDoComponente({ id: ruim }), null);
  assert.equal(idDoComponente({}), null);
});

test("Q12.12-4: payload externo inválido é ignorado defensivamente (nunca lança)", () => {
  for (const ruim of [null, undefined, 5, "x", [], {}, { assets: null }, { assets: "x" }, { assets: {} }]) assert.deepEqual(interpretarRespostaArtes(ruim, AGORA), {});
  const bom = { componente_id: COMP, quadro_indice: 0, url: urlAssinada(0), expira_em: expira() };
  const ruins = [
    null, 7, "x", [], { ...bom, componente_id: "nao-uuid" }, { ...bom, componente_id: 5 }, { ...bom, quadro_indice: -1 }, { ...bom, quadro_indice: 6 },
    { ...bom, quadro_indice: 1.5 }, { ...bom, quadro_indice: "1" }, { ...bom, url: "http://inseguro.example/a.webp" }, { ...bom, url: "javascript:alert(1)" },
    { ...bom, url: "data:image/webp;base64,AAAA" }, { ...bom, url: "" }, { ...bom, url: 5 }, { ...bom, expira_em: "amanhã" }, { ...bom, expira_em: undefined },
    { ...bom, expira_em: new Date(AGORA - 1000).toISOString() },
  ];
  assert.deepEqual(interpretarRespostaArtes({ assets: ruins }, AGORA), {});
  const mapa = interpretarRespostaArtes({ assets: [...ruins, bom, { ...bom, url: urlAssinada(99) }] }, AGORA);
  assert.deepEqual(Object.keys(mapa), [chaveArte(COMP, 0)], "só o item válido; duplicado vale o primeiro");
  assert.equal(mapa[chaveArte(COMP, 0)].url, urlAssinada(0));
  assert.equal(mapa[chaveArte(COMP, 0)].expiraEm, AGORA + 900_000);
  const muitos = Array.from({ length: 60 }, (_, i) => ({ componente_id: `00000000-0000-4000-8000-${String(i).padStart(12, "0")}`, quadro_indice: 0, url: urlAssinada(i), expira_em: expira() }));
  assert.ok(Object.keys(interpretarRespostaArtes({ assets: muitos }, AGORA)).length <= 24, "limite de itens");
});

test("Q12.12-5: expiração — renovação preventiva agendada uma vez com folga; erro de imagem tem limite e intervalo mínimo (sem loop)", () => {
  assert.equal(ARTE_TTL_SEGUNDOS, 900);
  assert.equal(proximaRenovacaoEmMs({}, AGORA), null, "sem arte: nada a renovar");
  const mapa = mapaArtes([0, 1]);
  assert.equal(menorExpiracao(mapa), AGORA + 900_000);
  assert.equal(proximaRenovacaoEmMs(mapa, AGORA), 900_000 - ARTE_MARGEM_RENOVACAO_MS);
  assert.equal(proximaRenovacaoEmMs(mapa, AGORA + 899_000), 0, "já dentro da folga: renova já, nunca atraso negativo");
  // renovação por erro: no máximo N por carga, com intervalo mínimo
  let estado = { tentativas: 0, ultimaEm: null };
  let concedidas = 0;
  let relogio = AGORA;
  for (let i = 0; i < 50; i++) {
    if (podeRenovar(estado, relogio)) { concedidas += 1; estado = { tentativas: estado.tentativas + 1, ultimaEm: relogio }; }
    relogio += 1_000;
  }
  assert.equal(concedidas, ARTE_LIMITE_RENOVACOES_POR_ERRO, "50 erros em 50 s => no máximo o limite por carga (3), com 20 s entre elas");
  assert.equal(podeRenovar({ tentativas: 0, ultimaEm: AGORA }, AGORA + ARTE_INTERVALO_MIN_RENOVACAO_MS - 1), false);
  assert.equal(podeRenovar({ tentativas: 0, ultimaEm: AGORA }, AGORA + ARTE_INTERVALO_MIN_RENOVACAO_MS), true);
  assert.equal(podeRenovar({ tentativas: ARTE_LIMITE_RENOVACOES_POR_ERRO, ultimaEm: null }, AGORA + 10 * 60_000), false, "nunca passa do limite por carga");
});

test("Q12.12-6: alt curto (rótulo do quadro + título), sem repetir a cena e sem marcação **", () => {
  assert.equal(textoAltArte(2, "Pode **entrar** à noite?"), "Ilustração do quadro 2: Pode entrar à noite?");
  assert.equal(textoAltArte(1, null), "Ilustração do quadro 1");
  assert.equal(textoAltArte(3, "   "), "Ilustração do quadro 3");
});

// ================================================================== C. RENDERER (renderização real com react-dom/server)
// O projeto não tem harness de DOM; aqui o TSX é transpilado com o `typescript` do projeto para uma pasta temporária
// dentro do repositório (ignorada pelo git: .sites-runtime/) e renderizado com react-dom/server.
let renderView;
let pastaTmp;
test.before(async () => {
  const ts = require("typescript");
  const base = path.join(raiz, ".sites-runtime");
  mkdirSync(base, { recursive: true });
  pastaTmp = mkdtempSync(path.join(base, "tst-q1212-"));
  const compilar = (arquivo, saida, jsx) => {
    let codigo = ler(arquivo);
    const { outputText } = ts.transpileModule(codigo, { compilerOptions: { module: ts.ModuleKind.ESNext, target: ts.ScriptTarget.ES2022, jsx: jsx ? ts.JsxEmit.ReactJSX : ts.JsxEmit.None } });
    writeFileSync(path.join(pastaTmp, saida), outputText.replace(/from "\.\/tiposComponenteAula"/g, 'from "./tiposComponenteAula.mjs"').replace(/from "\.\/arteQuadrinho"/g, 'from "./arteQuadrinho.mjs"'));
  };
  compilar("components/teoria/tiposComponenteAula.ts", "tiposComponenteAula.mjs", false);
  compilar("components/teoria/arteQuadrinho.ts", "arteQuadrinho.mjs", false);
  compilar("components/teoria/ComponenteAulaView.tsx", "ComponenteAulaView.mjs", true);
  const React = (await import("react")).default;
  const { renderToStaticMarkup } = await import("react-dom/server");
  const { default: View } = await import(pathToFileURL(path.join(pastaTmp, "ComponenteAulaView.mjs")).href);
  renderView = (componente, artes, aoErroArte) => renderToStaticMarkup(React.createElement(View, { componente, artes, aoErroArte }));
});
test.after(() => { if (pastaTmp) rmSync(pastaTmp, { recursive: true, force: true }); });

const imgs = (html) => [...html.matchAll(/<img\b[^>]*>/g)].map((m) => m[0]);
const itens = (html) => html.split('<li class="teoria-quadrinho-quadro">').slice(1);

test("Q12.12-7: SEM arte (prop ausente ou mapa vazio) -> nenhum <img> e o cartão textual completo de sempre", () => {
  for (const html of [renderView(componentePiloto()), renderView(componentePiloto(), {}), renderView(componentePiloto(), mapaArtes([]))]) {
    assert.equal(imgs(html).length, 0);
    assert.ok(!html.includes("teoria-quadrinho-arte"));
    for (const t of ["Quadro 1", "Quadro 4", "Cena A", "Fala de Cena B", "Legenda de Cena C", "Regra de prova: socorro autoriza o ingresso.", "EXEMPLO VISUAL", "Pode entrar à noite?"]) assert.ok(html.includes(t), t);
  }
  assert.equal(renderView(componentePiloto(), mapaArtes([])), renderView(componentePiloto()), "mapa vazio == sem a prop");
});

test("Q12.12-8: 4 artes -> 4 imagens, cada uma no quadro certo, acima do texto; loading lazy, 1536x1024, alt curto", () => {
  const html = renderView(componentePiloto(), mapaArtes([0, 1, 2, 3]));
  assert.equal(imgs(html).length, 4);
  const cartoes = itens(html);
  assert.equal(cartoes.length, 4);
  cartoes.forEach((cartao, i) => {
    assert.ok(cartao.includes(urlAssinada(i).replace(/&/g, "&amp;")), `quadro ${i + 1} tem a URL do índice ${i}`);
    for (let j = 0; j < 4; j++) if (j !== i) assert.ok(!cartao.includes(`arte-${j}.webp`), `quadro ${i + 1} não contém a arte ${j}`);
    assert.ok(cartao.indexOf("<img") < cartao.indexOf("teoria-quadrinho-cena"), "imagem vem antes da cena/falas");
    assert.ok(cartao.includes(`Cena ${"ABCD"[i]}`) && cartao.includes(`Fala de Cena ${"ABCD"[i]}`) && cartao.includes(`Legenda de Cena ${"ABCD"[i]}`), "texto pedagógico continua em HTML");
  });
  for (const tag of imgs(html)) {
    assert.match(tag, /loading="lazy"/);
    assert.match(tag, /width="1536"/);
    assert.match(tag, /height="1024"/);
    assert.match(tag, /decoding="async"/);
    assert.match(tag, /referrerPolicy="no-referrer"|referrerpolicy="no-referrer"/i);
    assert.match(tag, /alt="Ilustração do quadro \d: Pode entrar à noite\?"/);
  }
  assert.ok(html.includes("Regra de prova: socorro autoriza o ingresso."), "fechamento continua em HTML");
});

test("Q12.12-9: arte parcial -> só os quadros correspondentes têm imagem; os outros ficam só com texto", () => {
  const html = renderView(componentePiloto(), mapaArtes([1, 3]));
  const cartoes = itens(html);
  assert.deepEqual(cartoes.map((c) => c.includes("<img")), [false, true, false, true]);
  assert.equal(imgs(html).length, 2);
  for (const c of cartoes) assert.ok(c.includes("Cena"), "todo quadro mantém o texto");
});

test("Q12.12-10: a arte é casada pelo ÍNDICE ORIGINAL — quadro vazio removido não faz a imagem cair no quadro errado", () => {
  const comp = componentePiloto([quadro("Cena A"), { cena: "", falas: [] }, quadro("Cena C")]);
  const html = renderView(comp, mapaArtes([2]));
  const cartoes = itens(html);
  assert.equal(cartoes.length, 2, "dois quadros visíveis");
  assert.ok(!cartoes[0].includes("<img"), "Quadro 1 (índice 0) sem arte");
  assert.ok(cartoes[1].includes("<img") && cartoes[1].includes("arte-2.webp") && cartoes[1].includes("Cena C"), "Quadro 2 visual = índice ORIGINAL 2");
  // a arte do índice 1 (o quadro descartado) não aparece em lugar nenhum
  assert.equal(imgs(renderView(comp, mapaArtes([1]))).length, 0);
});

test("Q12.12-11: componente sem id válido, arte de OUTRO componente ou outros tipos -> sem imagem, sem quebrar", () => {
  const { id, ...semId } = componentePiloto();
  assert.equal(imgs(renderView(semId, mapaArtes([0, 1, 2, 3]))).length, 0);
  const outro = { ...componentePiloto(), id: "6c3f9d0e-1a2b-4c3d-8e4f-5a6b7c8d9e0f" };
  assert.equal(imgs(renderView(outro, mapaArtes([0, 1, 2, 3]))).length, 0);
  for (const tipo of ["conceito", "diagnostico", "recall", "resumo_visual", "tipo_desconhecido"]) {
    assert.doesNotThrow(() => renderView({ tipo, id: COMP, titulo: "T" }, mapaArtes([0, 1, 2, 3])), tipo);
  }
});

test("Q12.12-12: o texto jurídico nunca vai para dentro da imagem/alt: cena, falas, legenda e fechamento ficam em HTML", () => {
  const html = renderView(componentePiloto(), mapaArtes([0, 1, 2, 3]));
  for (const tag of imgs(html)) {
    for (const juridico of ["Cena", "Fala de", "Legenda de", "Regra de prova", "socorro"]) assert.ok(!tag.includes(juridico), `alt não repete o texto (${juridico})`);
  }
  assert.match(html, /class="teoria-quadrinho-legenda"/);
  assert.match(html, /class="teoria-bizu teoria-quadrinho-fechamento"/);
});

// ================================================================== D. EDGE assinar-quadrinho-assets (handler com mocks)
function linhaAdmin(i, extra = {}) {
  return { id: `asset-${i}`, aula_versao_id: AULA, componente_id: COMP, quadro_indice: i, scene_hash: `hash${i}`, scene_hash_atual: `hash${i}`, asset_atual: true, status: "aprovada", storage_path: `${AULA}/${COMP}/${i}/abc-${i}.webp`, modelo: "gpt-image-2.5-sunburst", prompt_version: "quadrinho-imagem-v3", prompt_visual: `PROMPT-SECRETO-${i}`, tentativas: 1, erro_sanitizado: null, aprovado_por: "u", aprovado_em: "x", criado_em: "x", atualizado_em: "x", ...extra };
}
const linhaAluno = (i) => ({ asset_id: `asset-${i}`, componente_id: COMP, quadro_indice: i, storage_path: `${AULA}/${COMP}/${i}/abc-${i}.webp`, scene_hash: `hash${i}` });

function montar(sobrescritas = {}) {
  const chamadas = [];
  const logs = [];
  const deps = {
    autenticar: async () => { chamadas.push("autenticar"); return { ok: true }; },
    ehAdmin: async () => { chamadas.push("ehAdmin"); return true; },
    carregarAssetsAdmin: async (versao) => { chamadas.push(["carregarAssetsAdmin", versao]); return [0, 1, 2, 3].map((i) => linhaAdmin(i)); },
    carregarAssetsAluno: async (missao, versao) => { chamadas.push(["carregarAssetsAluno", missao, versao]); return [0, 1, 2, 3].map(linhaAluno); },
    assinar: async (paths, ttl) => { chamadas.push(["assinar", paths, ttl]); return paths.map((p) => ({ path: p, signedUrl: `https://x.supabase.co/sign/${encodeURIComponent(p)}?token=T` })); },
    agora: () => AGORA,
    log: (evento, campos) => logs.push([evento, campos]),
    ...sobrescritas,
  };
  return { deps, chamadas, logs };
}
const req = (corpo, { metodo = "POST", auth = "Bearer JWT-DO-USUARIO" } = {}) =>
  new Request("http://edge.local/assinar-quadrinho-assets", { method: metodo, headers: auth ? { Authorization: auth } : {}, body: metodo === "POST" ? (typeof corpo === "string" ? corpo : JSON.stringify(corpo)) : undefined });
const admin = (extra = {}) => ({ modo: "admin", aulaVersaoId: AULA, ...extra });
const aluno = (extra = {}) => ({ modo: "aluno", aulaVersaoId: AULA, missaoId: MISSAO, ...extra });
const assinou = (chamadas) => chamadas.some((c) => Array.isArray(c) && c[0] === "assinar");

test("Q12.12-13: entrada — método, CORS, modo desconhecido, UUID inválido, campos ausentes e campos EXTRAS são recusados sem tocar em nada", async () => {
  const { deps, chamadas } = montar();
  assert.equal((await tratarRequisicao(req(null, { metodo: "GET" }), deps)).status, 405);
  const opt = await tratarRequisicao(req(null, { metodo: "OPTIONS" }), deps);
  assert.equal(opt.status, 200);
  assert.equal(opt.headers.get("Access-Control-Allow-Methods"), "POST, OPTIONS");
  assert.deepEqual(Object.keys(CORS).sort(), ["Access-Control-Allow-Headers", "Access-Control-Allow-Methods", "Access-Control-Allow-Origin"]);
  const invalidos = [
    "{nao json", "[]", "null", "", {}, { modo: "professor", aulaVersaoId: AULA }, { modo: "ADMIN", aulaVersaoId: AULA }, { modo: 5, aulaVersaoId: AULA }, { aulaVersaoId: AULA },
    admin({ aulaVersaoId: "nao-uuid" }), admin({ aulaVersaoId: undefined }), { modo: "admin" },
    aluno({ missaoId: undefined }), aluno({ missaoId: "nao-uuid" }), aluno({ aulaVersaoId: 5 }),
    admin({ storage_path: "x" }), admin({ bucket: "quadrinhos-aulas" }), admin({ expiresIn: 999999 }), admin({ missaoId: MISSAO }), aluno({ status: "aprovada" }), aluno({ asset_id: "x" }),
    { modo: "__proto__", aulaVersaoId: AULA }, { modo: "constructor", aulaVersaoId: AULA },
  ];
  for (const corpo of invalidos) {
    const r = await tratarRequisicao(req(corpo), deps);
    assert.equal(r.status, 400, JSON.stringify(corpo));
    assert.ok(!(await r.text()).includes(AULA));
  }
  assert.ok(!chamadas.some((c) => c !== "autenticar"), "nada além da autenticação foi chamado (nem RPC, nem assinatura)");
});

test("Q12.12-14: sem sessão / sessão inválida = 401; não autenticado nunca chega à RPC nem à assinatura", async () => {
  for (const modo of [admin(), aluno()]) {
    const { deps, chamadas } = montar({ autenticar: async (h) => { return h ? { ok: false, status: 401, mensagem: "Sessão inválida." } : { ok: false, status: 401, mensagem: "Sessão não encontrada." }; } });
    const r = await tratarRequisicao(req(modo, { auth: null }), deps);
    assert.equal(r.status, 401);
    assert.deepEqual(chamadas, [], "sem RPC e sem assinatura");
    assert.equal((await tratarRequisicao(req(modo), deps)).status, 401);
  }
  const quebrada = montar({ autenticar: async () => { throw new Error("auth fora Bearer abc"); } });
  const r = await tratarRequisicao(req(admin()), quebrada.deps);
  assert.equal(r.status, 500);
  assert.ok(!(await r.text()).includes("Bearer"));
});

test("Q12.12-15: usuário comum pedindo modo admin = 403; nenhuma RPC de assets e nenhuma assinatura", async () => {
  const { deps, chamadas } = montar({ ehAdmin: async () => { chamadas.push("ehAdmin"); return false; } });
  const r = await tratarRequisicao(req(admin()), deps);
  assert.equal(r.status, 403);
  assert.deepEqual(chamadas, ["autenticar", "ehAdmin"]);
  const semRetorno = montar({ ehAdmin: async () => undefined });
  assert.equal((await tratarRequisicao(req(admin()), semRetorno.deps)).status, 403, "só `true` estrito autoriza");
});

test("Q12.12-16: admin em versão de RASCUNHO recebe as artes aprovadas (autorização pelo client do usuário) e o service_role só assina", async () => {
  const { deps, chamadas } = montar();
  const r = await tratarRequisicao(req(admin()), deps);
  assert.equal(r.status, 200);
  const corpo = await r.json();
  assert.deepEqual(corpo.assets.map((a) => a.quadro_indice), [0, 1, 2, 3]);
  assert.ok(corpo.assets.every((a) => a.componente_id === COMP && a.url.startsWith("https://") && a.expira_em === new Date(AGORA + 900_000).toISOString()));
  assert.deepEqual(Object.keys(corpo.assets[0]).sort(), ["componente_id", "expira_em", "quadro_indice", "url"]);
  assert.deepEqual(chamadas.map((c) => (Array.isArray(c) ? c[0] : c)), ["autenticar", "ehAdmin", "carregarAssetsAdmin", "assinar"], "ordem: autentica, admin, RPC, só então assina");
  assert.equal(r.headers.get("Cache-Control"), "no-store");
});

test("Q12.12-17: admin NÃO recebe asset não aprovado nem com cena desatualizada (asset_atual=false), nem sem path", async () => {
  const linhas = [
    linhaAdmin(0), linhaAdmin(1, { status: "gerada" }), linhaAdmin(2, { asset_atual: false }), linhaAdmin(3, { status: "rejeitada" }),
    linhaAdmin(4, { status: "pendente" }), linhaAdmin(5, { status: "erro" }), linhaAdmin(1, { status: "aprovada", storage_path: null, id: "sem-path" }),
    linhaAdmin(0, { aula_versao_id: "6c3f9d0e-1a2b-4c3d-8e4f-5a6b7c8d9e0f", id: "outra-versao", quadro_indice: 2 }),
  ];
  const { deps, chamadas } = montar({ carregarAssetsAdmin: async () => linhas });
  const corpo = await (await tratarRequisicao(req(admin()), deps)).json();
  assert.deepEqual(corpo.assets.map((a) => a.quadro_indice), [0]);
  const assinados = chamadas.find((c) => Array.isArray(c) && c[0] === "assinar")[1];
  assert.deepEqual(assinados, [`${AULA}/${COMP}/0/abc-0.webp`]);
  const nenhum = montar({ carregarAssetsAdmin: async () => [linhaAdmin(0, { status: "gerada" }), linhaAdmin(1, { asset_atual: false })] });
  assert.deepEqual(await (await tratarRequisicao(req(admin()), nenhum.deps)).json(), { assets: [] });
  assert.ok(!assinou(nenhum.chamadas), "sem arte válida nada é assinado");
});

test("Q12.12-18: aluno com versão em RASCUNHO recebe {assets: []} (RPC devolve vazio) e nada é assinado", async () => {
  const { deps, chamadas } = montar({ carregarAssetsAluno: async (m, v) => { chamadas.push(["carregarAssetsAluno", m, v]); return []; } });
  const r = await tratarRequisicao(req(aluno()), deps);
  assert.equal(r.status, 200);
  assert.deepEqual(await r.json(), { assets: [] });
  assert.ok(!assinou(chamadas));
  assert.ok(!chamadas.includes("ehAdmin"), "o caminho do aluno nem consulta admin");
});

test("Q12.12-19: aluno com versão PUBLICADA e acessível recebe as artes (RPC do aluno com missão + versão, sem bypass)", async () => {
  const { deps, chamadas } = montar();
  const r = await tratarRequisicao(req(aluno()), deps);
  assert.equal(r.status, 200);
  assert.deepEqual((await r.json()).assets.map((a) => a.quadro_indice), [0, 1, 2, 3]);
  assert.deepEqual(chamadas.find((c) => Array.isArray(c) && c[0] === "carregarAssetsAluno"), ["carregarAssetsAluno", MISSAO, AULA]);
  assert.deepEqual(chamadas.map((c) => (Array.isArray(c) ? c[0] : c)), ["autenticar", "carregarAssetsAluno", "assinar"]);
  assert.ok(!chamadas.includes("ehAdmin") && !chamadas.some((c) => Array.isArray(c) && c[0] === "carregarAssetsAdmin"), "aluno nunca passa pelo caminho admin");
});

test("Q12.12-20: aluno sem matrícula/missão válida (a RPC levanta exceção) = 403 genérico, sem arte, sem assinatura, sem vazar a mensagem do banco", async () => {
  const { deps, chamadas, logs } = montar({ carregarAssetsAluno: async () => { throw new Error("Missao nao encontrada, nao pertence ao usuario autenticado, ou a matricula nao esta ativa"); } });
  const r = await tratarRequisicao(req(aluno({ missaoId: OUTRA_MISSAO })), deps);
  assert.equal(r.status, 403);
  const texto = await r.text();
  assert.ok(!/matricula|Missao|banco|storage/i.test(texto), "sem detalhe interno");
  assert.ok(!assinou(chamadas));
  assert.ok(!JSON.stringify(logs).includes("Missao nao encontrada"));
});

test("Q12.12-21: aluno não obtém arte NÃO aprovada nem de outra estrutura — filtro defensivo mesmo sobre o retorno da RPC", async () => {
  const { deps } = montar({ carregarAssetsAluno: async () => [linhaAluno(0), { ...linhaAluno(1), status: "gerada" }, { ...linhaAluno(2), componente_id: "nao-uuid" }, { ...linhaAluno(3), storage_path: "../fora.webp" }, { ...linhaAluno(3), quadro_indice: 9 }, null] });
  assert.deepEqual((await (await tratarRequisicao(req(aluno()), deps)).json()).assets.map((a) => a.quadro_indice), [0]);
});

test("Q12.12-22: a resposta NÃO contém storage_path, storage_path_anterior, prompt_visual, scene_hash, modelo, token nem credencial", async () => {
  const { deps } = montar({ carregarAssetsAdmin: async () => [linhaAdmin(0, { storage_path_anterior: "PATH-ANTIGO-SECRETO" }), linhaAdmin(1)] });
  for (const corpo of [admin(), aluno()]) {
    const r = await tratarRequisicao(req(corpo), deps);
    const texto = await r.text();
    for (const proibido of ["storage_path", "storage_path_anterior", "prompt_visual", "PROMPT-SECRETO", "scene_hash", "hash0", "modelo", "gpt-image", "prompt_version", "PATH-ANTIGO-SECRETO", "claim_token", "JWT-DO-USUARIO", "Authorization", "service_role", "abc-0.webp"]) {
      // a URL assinada é opaca ao cliente: o path aparece codificado dentro da URL do Storage, mas nunca como campo
      if (proibido === "abc-0.webp") continue;
      assert.ok(!texto.includes(proibido), `vazou: ${proibido}`);
    }
    for (const a of JSON.parse(texto).assets) assert.deepEqual(Object.keys(a).sort(), ["componente_id", "expira_em", "quadro_indice", "url"]);
  }
});

test("Q12.12-23: a assinatura é feita SÓ dos paths devolvidos pela RPC autorizada, em lote (1 chamada), com validade de 900 s", async () => {
  assert.equal(TTL_SEGUNDOS, 900);
  const { deps, chamadas } = montar();
  await tratarRequisicao(req(admin()), deps);
  const assinaturas = chamadas.filter((c) => Array.isArray(c) && c[0] === "assinar");
  assert.equal(assinaturas.length, 1, "lote: uma chamada, sem N+1");
  assert.deepEqual(assinaturas[0][1], [0, 1, 2, 3].map((i) => `${AULA}/${COMP}/${i}/abc-${i}.webp`), "exatamente os paths que a RPC devolveu");
  assert.equal(assinaturas[0][2], 900);
  // um path que o CLIENTE tente injetar nunca chega à assinatura: corpo com campo extra é 400
  const inj = montar();
  assert.equal((await tratarRequisicao(req(admin({ paths: ["x/y.webp"] })), inj.deps)).status, 400);
  assert.ok(!assinou(inj.chamadas));
  // duplicados na RPC viram uma assinatura só
  const dup = montar({ carregarAssetsAdmin: async () => [linhaAdmin(0), linhaAdmin(0, { id: "dup" })] });
  await tratarRequisicao(req(admin()), dup.deps);
  assert.equal(dup.chamadas.find((c) => Array.isArray(c) && c[0] === "assinar")[1].length, 1);
});

test("Q12.12-24: falhas de infraestrutura são genéricas e nunca viram vazamento; assinatura parcial devolve só o que foi assinado", async () => {
  const rpcCaiu = montar({ carregarAssetsAdmin: async () => { throw new Error("password authentication failed for user postgres"); } });
  const r1 = await tratarRequisicao(req(admin()), rpcCaiu.deps);
  assert.equal(r1.status, 500);
  assert.ok(!(await r1.text()).includes("postgres"));
  assert.ok(!JSON.stringify(rpcCaiu.logs).includes("postgres"));
  const assinaturaCaiu = montar({ assinar: async () => { throw new Error("SUPABASE_SERVICE_ROLE_KEY invalida eyJhbGciOi"); } });
  const r2 = await tratarRequisicao(req(admin()), assinaturaCaiu.deps);
  assert.equal(r2.status, 500);
  const t2 = await r2.text();
  assert.ok(!t2.includes("SERVICE_ROLE") && !t2.includes("eyJ"));
  const parcial = montar({ assinar: async (paths) => paths.map((p, i) => ({ path: p, signedUrl: i % 2 === 0 ? `https://x.supabase.co/sign/${i}` : null })) });
  assert.deepEqual((await (await tratarRequisicao(req(admin()), parcial.deps)).json()).assets.map((a) => a.quadro_indice), [0, 2]);
  const insegura = montar({ assinar: async (paths) => paths.map((p) => ({ path: p, signedUrl: "http://sem-https.example/x" })) });
  assert.deepEqual(await (await tratarRequisicao(req(admin()), insegura.deps)).json(), { assets: [] }, "URL não-https é descartada");
  const verboso = montar({ log: () => { throw new Error("log fora"); } });
  assert.equal((await tratarRequisicao(req(admin()), verboso.deps)).status, 200, "log nunca derruba o fluxo");
});

test("Q12.12-25: validarEntrada — contrato exato (normaliza uuid para minúsculas; missaoId só no modo aluno)", () => {
  assert.deepEqual(validarEntrada({ modo: "admin", aulaVersaoId: AULA.toUpperCase() }), { ok: true, valor: { modo: "admin", aulaVersaoId: AULA, missaoId: null } });
  assert.deepEqual(validarEntrada({ modo: "aluno", aulaVersaoId: AULA, missaoId: MISSAO }), { ok: true, valor: { modo: "aluno", aulaVersaoId: AULA, missaoId: MISSAO } });
  assert.equal(validarEntrada({ modo: "admin", aulaVersaoId: AULA, missaoId: MISSAO }).ok, false);
  assert.equal(validarEntrada(undefined).ok, false);
});

// ================================================================== E. index.ts da Edge: service_role só assina
test("Q12.12-26: index.ts — autorização SÓ pelo client do usuário; service_role aparece uma vez, dentro de `assinar`; bucket privado; verify_jwt documentado", () => {
  const index = ler("supabase/functions/assinar-quadrinho-assets/index.ts");
  assert.match(index, /const BUCKET = "quadrinhos-aulas"/);
  assert.match(index, /createClient\(supabaseUrl, anonKey, \{ global: \{ headers: \{ Authorization: authorization \} \} \}\)/);
  assert.match(index, /usuario!\.rpc\("eh_admin"\)/);
  assert.match(index, /usuario!\.rpc\("carregar_quadrinho_assets_admin", \{ p_aula_versao_id: aulaVersaoId \}\)/);
  assert.match(index, /usuario!\.rpc\("carregar_quadrinho_assets_aula", \{ p_missao_id: missaoId, p_aula_versao_id: aulaVersaoId \}\)/);
  assert.match(index, /usuario\.auth\.getUser\(/);
  assert.equal((index.match(/SUPABASE_SERVICE_ROLE_KEY/g) ?? []).length, 1, "service_role referenciado uma única vez");
  const corpoAssinar = index.slice(index.indexOf("assinar: async"), index.indexOf("log: registrar"));
  assert.ok(corpoAssinar.includes("SUPABASE_SERVICE_ROLE_KEY") && corpoAssinar.includes("createSignedUrls(paths, ttlSegundos)"), "service_role só dentro de `assinar`, em lote");
  const fora = index.replace(corpoAssinar, "");
  assert.ok(!fora.includes("SUPABASE_SERVICE_ROLE_KEY") && !/\badmin\b\s*\.\s*(rpc|from)\(/.test(fora), "nenhuma decisão/leitura fora de `assinar` usa o service_role");
  assert.doesNotMatch(index.replace(/^\s*\/\/.*$/gm, ""), /\.from\("aula_quadrinho_assets"\)|\.select\(|\.upload\(|\.remove\(|getPublicUrl|createSignedUrl\(/, "sem leitura direta da tabela, sem upload/remove, sem URL pública");
  assert.doesNotMatch(index, /console\.log\([^)]*(url|signedUrl|token|Authorization|authorization|path)/i);
  assert.match(index, /verify_jwt precisa ficar LIGADO/);
  assert.doesNotMatch(index, /eyJ[A-Za-z0-9_-]{15,}|sk-[A-Za-z0-9_-]{20,}/);
});

test("Q12.12-27: closure da Edge — só módulos do pacote (+ supabase-js via esm.sh); sem gerar-aula, sem frontend, sem ciclo", () => {
  const base = path.join(raiz, "supabase/functions/assinar-quadrinho-assets");
  const visitado = new Set();
  const externos = new Set();
  const visitar = (arquivo) => {
    if (visitado.has(arquivo)) return;
    visitado.add(arquivo);
    const src = readFileSync(arquivo, "utf8").replace(/\/\*[\s\S]*?\*\//g, "").replace(/^\s*\/\/.*$/gm, "");
    for (const m of src.matchAll(/(?:^|\n)\s*import\s[^;'"]*?from\s+["']([^"']+)["']/g)) {
      if (!m[1].startsWith(".")) { externos.add(m[1]); continue; }
      const alvo = path.resolve(path.dirname(arquivo), m[1]);
      assert.ok(existsSync(alvo), `import inexistente: ${m[1]}`);
      visitar(alvo);
    }
  };
  visitar(path.join(base, "index.ts"));
  assert.deepEqual([...externos], ["https://esm.sh/@supabase/supabase-js@2"]);
  const arquivos = [...visitado].map((f) => path.relative(raiz, f).replaceAll("\\", "/"));
  assert.deepEqual(arquivos.sort(), ["supabase/functions/_shared/quadrinho-assets/entrada.mjs", "supabase/functions/_shared/quadrinho-assets/handler.mjs", "supabase/functions/assinar-quadrinho-assets/index.ts"]);
  assert.deepEqual(readdirSync(path.join(raiz, "supabase/functions/_shared/quadrinho-assets")).sort(), ["entrada.mjs", "handler.mjs"]);
});

// ================================================================== F. HOOK, PÁGINAS e VAZAMENTOS (estático)
test("Q12.12-28: hook — uma chamada por contexto, sem bloquear, falha = fallback sem retry, sem loop, sem log de URL/token (estrutura pós Q12.15: controlador + casca do hook)", () => {
  const hook = ler("components/teoria/useArtesQuadrinho.ts");
  const codigo = hook.replace(/\/\*[\s\S]*?\*\//g, "").replace(/^\s*\/\/.*$/gm, "");
  assert.match(codigo, /functions\.invoke\("assinar-quadrinho-assets", \{ body: corpo \}\)/);
  assert.match(codigo, /useState<\{ chave: string; mapa: MapaArtes \}>\(\{ chave: "", mapa: MAPA_VAZIO \}\)/, "começa vazio (= fallback textual), não bloqueia a renderização");
  assert.match(codigo, /catch \{/, "exceção não propaga");
  assert.match(codigo, /if \(minhaGeracao !== geracao\) return;/, "descarta resposta de aula antiga/desmontada");
  assert.match(codigo, /if \(emVoo === meuId\) emVoo = null;/, "só a requisição dona libera a marca");
  assert.match(codigo, /podeRenovar\(renovacao, agora\)/, "renovação por erro de imagem é limitada");
  assert.equal((codigo.match(/setTimeout\(/g) ?? []).length, 1, "um único ponto de timer");
  assert.ok(!/setInterval/.test(codigo), "sem timer agressivo");
  assert.match(codigo, /clearTimeout\(/);
  assert.doesNotMatch(codigo, /console\./, "nenhum log");
  assert.doesNotMatch(codigo, /SERVICE_ROLE|service_role|storage_path|prompt_visual|scene_hash/);
});

test("Q12.12-29: páginas — aluno usa modo aluno com missao.id; preview admin usa modo admin só após confirmar admin; ambos antes dos retornos antecipados; PDF intocado", () => {
  const aluno = ler("app/teoria/page.tsx");
  const iHook = aluno.indexOf('useArtesQuadrinho({ modo: "aluno"');
  assert.ok(iHook > 0);
  assert.ok(iHook < aluno.indexOf('if (carregando) return <main className="dashboard-loading">'), "hook antes do primeiro retorno antecipado (regra dos hooks)");
  assert.match(aluno, /aulaVersaoId: aulaVersaoIdArte, missaoId: missao\?\.id \?\? null/);
  assert.match(aluno, /estadoAula === "disponivel"/);
  assert.match(aluno, /artes=\{artesQuadrinho\} aoErroArte=\{aoErroArte\}/);
  const preview = ler("app/admin/aulas/preview/page.tsx");
  assert.match(preview, /useArtesQuadrinho\(\{ modo: "admin", aulaVersaoId: admin && !ehMissaoFinal \? aulaVersaoIdAtual : null \}\)/);
  assert.ok(preview.indexOf('useArtesQuadrinho({ modo: "admin"') < preview.indexOf("if (verificando) return"), "hook antes dos retornos antecipados");
  assert.match(preview, /artes=\{artesQuadrinho\} aoErroArte=\{aoErroArte\}/);
  // Até a Q12.20 o PDF era puramente textual (nenhum destes três arquivos tocava em arte/hook). A Q12.21
  // reaproveita DELIBERADAMENTE o mesmo hook/Edge no PDF (ver tests/quadrinho-impressao-q1221.test.mjs para a
  // cobertura completa dessa integração) — aqui só resta confirmar que a página de impressão não abriu um
  // caminho PARALELO: continua usando o hook existente, nunca chamando a Edge nem o cliente Supabase por conta própria.
  const paginaImpressao = ler("app/teoria/imprimir/page.tsx");
  assert.match(paginaImpressao, /useArtesQuadrinho\(contextoArte\)/, "reaproveita o hook existente");
  assert.doesNotMatch(paginaImpressao.replace(/^\s*\/\/.*$/gm, ""), /functions\.invoke|assinar-quadrinho-assets/, "sem chamada paralela à Edge");
});

test("Q12.12-30: vazamentos — sem service_role no app/components/lib, sem storage_path/prompt_visual/scene_hash/console de URL no cliente; CSS da arte sem url()", () => {
  const pastas = ["app", "components", "lib"].map((p) => path.join(raiz, p));
  const arquivos = [];
  const varrer = (dir) => {
    for (const e of readdirSync(dir, { withFileTypes: true })) {
      const p = path.join(dir, e.name);
      if (e.isDirectory()) varrer(p);
      else if (/\.(ts|tsx|mjs|js|css)$/.test(e.name)) arquivos.push(p);
    }
  };
  pastas.forEach(varrer);
  assert.ok(arquivos.length > 10);
  for (const f of arquivos) {
    const src = readFileSync(f, "utf8").replace(/\/\*[\s\S]*?\*\//g, "").replace(/^\s*\/\/.*$/gm, ""); // só código: comentários podem explicar que o service_role fica na Edge
    assert.doesNotMatch(src, /SUPABASE_SERVICE_ROLE_KEY|service_role/i, `service_role no cliente: ${path.relative(raiz, f)}`);
  }
  const cliente = ["components/teoria/ComponenteAulaView.tsx", "components/teoria/arteQuadrinho.ts", "components/teoria/useArtesQuadrinho.ts"].map(ler).join("\n").replace(/^\s*\/\/.*$/gm, "");
  assert.doesNotMatch(cliente, /storage_path|prompt_visual|scene_hash|createSignedUrl|console\.(log|info|debug)\([^)]*(url|token|Authorization)/i);
  const css = ler("app/globals.css").replace(/\r\n/g, "\n");
  const bloco = css.slice(css.indexOf(".teoria-quadrinho-arte {"), css.indexOf("/* Cena = contexto"));
  assert.match(bloco, /aspect-ratio:\s*3 \/ 2/);
  assert.match(bloco, /object-fit:\s*cover/);
  assert.match(bloco, /border-radius:\s*8px/);
  assert.doesNotMatch(bloco, /url\(/);
});

test("Q12.12-31: sem SQL novo, sem policy pública e sem Edge de GC; as Edges de geração não foram tocadas por esta fase", () => {
  const sqls = readdirSync(path.join(raiz, "supabase")).filter((f) => f.endsWith(".sql"));
  for (const f of sqls) {
    const src = ler(`supabase/${f}`);
    assert.doesNotMatch(src.replace(/^\s*--.*$/gm, ""), /assinar-quadrinho-assets/, `${f}: SQL não conhece a Edge de assinatura`);
  }
  assert.ok(!existsSync(path.join(raiz, "supabase/functions/limpar-uploads-orfaos-quadrinho")));
  assert.ok(!existsSync(path.join(raiz, "supabase/assinar_quadrinho_assets.sql")), "nenhum SQL novo para esta fase");
});

// ================================================================== G. Q12.15 — hook: timer relativo ao recebimento + concorrência
// O controlador (criarControladorArtes) é a lógica REAL do hook, sem React: o teste transpila useArtesQuadrinho.ts
// para uma pasta temporária (ignorada pelo git), troca só os imports que o Node não resolve (alias @/ e ./arteQuadrinho)
// e o exercita com timers, relógio e promessas SIMULADOS. Nenhuma chamada de rede.

let pastaHook;
let hookMod;
test.before(async () => {
  const ts = require("typescript");
  const base = path.join(raiz, ".sites-runtime");
  mkdirSync(base, { recursive: true });
  pastaHook = mkdtempSync(path.join(base, "tst-q1215-"));
  const transpilar = (arquivo, saida, trocas = []) => {
    let { outputText } = ts.transpileModule(ler(arquivo), { compilerOptions: { module: ts.ModuleKind.ESNext, target: ts.ScriptTarget.ES2022 } });
    for (const [de, para] of trocas) outputText = outputText.replaceAll(de, para);
    writeFileSync(path.join(pastaHook, saida), outputText);
  };
  transpilar("components/teoria/arteQuadrinho.ts", "arteQuadrinho.mjs");
  writeFileSync(path.join(pastaHook, "supabaseClientStub.mjs"), "export function createClient() { throw new Error('rede proibida no teste'); }\n");
  transpilar("components/teoria/useArtesQuadrinho.ts", "useArtesQuadrinho.mjs", [
    ['from "@/utils/supabase/client"', 'from "./supabaseClientStub.mjs"'],
    ['from "./arteQuadrinho"', 'from "./arteQuadrinho.mjs"'],
  ]);
  hookMod = await import(pathToFileURL(path.join(pastaHook, "useArtesQuadrinho.mjs")).href);
});
test.after(() => { if (pastaHook) rmSync(pastaHook, { recursive: true, force: true }); });

const ctxA = { chave: "admin|A|", modo: "admin", aulaVersaoId: "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa", missaoId: null };
const ctxB = { chave: "aluno|B|M", modo: "aluno", aulaVersaoId: "bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb", missaoId: "cccccccc-cccc-4ccc-8ccc-cccccccccccc" };
const COMP_B = "dddddddd-dddd-4ddd-8ddd-dddddddddddd";

function respostaCom(indices, { componente = COMP, expiraEm = new Date(AGORA + 900_000).toISOString(), prefixo = "a" } = {}) {
  return { assets: indices.map((i) => ({ componente_id: componente, quadro_indice: i, url: `https://x.supabase.co/sign/${prefixo}${i}?token=t`, expira_em: expiraEm })) };
}

function cenario() {
  const timers = [];
  const pendentes = [];
  const mudancas = [];
  const chamadas = [];
  const concluidas = []; // Q12.21: aoMudarConcluida — aditivo, testado à parte na seção H
  let relogio = AGORA;
  const deps = {
    buscar: (ctx) => new Promise((resolve, reject) => { chamadas.push(ctx.chave); pendentes.push({ ctx, resolve, reject }); }),
    aoMudarArtes: (chave, mapa) => mudancas.push({ chave, mapa }),
    aoMudarConcluida: (chave, concluida) => concluidas.push({ chave, concluida }),
    agendar: (fn, ms) => { const t = { fn, ms, ativo: true }; timers.push(t); return t; },
    cancelar: (t) => { t.ativo = false; },
    agora: () => relogio,
  };
  const ctl = hookMod.criarControladorArtes(deps);
  const ultimo = () => mudancas[mudancas.length - 1];
  const ultimaConcluida = () => concluidas[concluidas.length - 1];
  const timersAtivos = () => timers.filter((t) => t.ativo);
  // dispara o timer ativo mais recente (o que o setTimeout real faria ao vencer)
  const dispararTimer = () => { const t = timersAtivos().pop(); assert.ok(t, "há timer ativo"); t.ativo = false; t.fn(); };
  const tick = () => new Promise((r) => setImmediate(r));
  return { ctl, timers, timersAtivos, pendentes, mudancas, chamadas, concluidas, ultimo, ultimaConcluida, dispararTimer, tick, relogio: (v) => { if (v !== undefined) relogio = v; return relogio; } };
}

test("Q12.15-1: renovação é RELATIVA ao recebimento e nomeada (SIGNED_URL_REFRESH_MS = 10 min < TTL de 15 min); nada de timer por expira_em", () => {
  assert.equal(hookMod.SIGNED_URL_REFRESH_MS, 600_000);
  assert.ok(hookMod.SIGNED_URL_REFRESH_MS < ARTE_TTL_SEGUNDOS * 1000, "renova antes de expirar");
  const codigo = ler("components/teoria/useArtesQuadrinho.ts").replace(/\/\*[\s\S]*?\*\//g, "").replace(/^\s*\/\/.*$/gm, "");
  assert.match(codigo, /export const SIGNED_URL_REFRESH_MS = 10 \* 60 \* 1000;/);
  assert.match(codigo, /deps\.agendar\([\s\S]*?\}, SIGNED_URL_REFRESH_MS\);/, "o timer usa SÓ a constante");
  assert.doesNotMatch(codigo, /proximaRenovacaoEmMs|menorExpiracao|ARTE_MARGEM_RENOVACAO_MS|Date\.parse|new Date\(|expiraEm|expira_em/, "expira_em/relógio absoluto não controla mais o timer");
  assert.equal((codigo.match(/deps\.agendar\(/g) ?? []).length, 1, "um único ponto de agendamento");
});

test("Q12.15-2: relógio NORMAL — resposta válida => um único timer de 10 min; ao vencer, uma (e só uma) nova chamada e um novo timer", async () => {
  const c = cenario();
  c.ctl.definirContexto(ctxA);
  assert.deepEqual(c.chamadas, ["admin|A|"], "uma chamada inicial");
  c.pendentes[0].resolve(respostaCom([0, 1, 2, 3]));
  await c.tick();
  assert.equal(Object.keys(c.ultimo().mapa).length, 4);
  assert.equal(c.ultimo().chave, ctxA.chave);
  assert.equal(c.timersAtivos().length, 1, "um único timer");
  assert.equal(c.timersAtivos()[0].ms, 600_000);
  c.dispararTimer();
  await c.tick();
  assert.equal(c.chamadas.length, 2, "renovou uma vez");
  c.pendentes[1].resolve(respostaCom([0, 1, 2, 3], { prefixo: "n" }));
  await c.tick();
  assert.equal(c.timersAtivos().length, 1, "sempre no máximo um timer");
  assert.equal(c.timersAtivos()[0].ms, 600_000);
  assert.equal(c.chamadas.length, 2, "sem chamadas extras enquanto o timer não vence");
  assert.ok(c.ultimo().mapa[chaveArte(COMP, 0)].url.includes("/n0"), "mapa substituído pelas URLs novas");
});

test("Q12.15-3: cliente 14 MIN ADIANTADO (bug original) — NÃO agenda 0 ms, NÃO entra em loop; mesma política de 10 min", async (t) => {
  // relógio do cliente = servidor + 14 min; expira_em = servidor + 900 s (o que a Edge realmente devolve)
  const relogioCliente = AGORA + 14 * 60_000;
  t.mock.method(Date, "now", () => relogioCliente);
  const c = cenario();
  c.relogio(relogioCliente);
  c.ctl.definirContexto(ctxA);
  c.pendentes[0].resolve(respostaCom([0, 1, 2, 3], { expiraEm: new Date(AGORA + 900_000).toISOString() }));
  await c.tick();
  assert.equal(Object.keys(c.ultimo().mapa).length, 4);
  assert.equal(c.timersAtivos().length, 1);
  assert.equal(c.timersAtivos()[0].ms, 600_000, "atraso relativo, não 0 ms");
  // "loop" = muitas chamadas sem o timer vencer: aqui NADA acontece sozinho
  for (let i = 0; i < 20; i++) await c.tick();
  assert.equal(c.chamadas.length, 1, "nenhuma chamada extra sem o timer vencer");
  c.dispararTimer(); await c.tick();
  c.pendentes[1].resolve(respostaCom([0, 1, 2, 3])); await c.tick();
  assert.equal(c.chamadas.length, 2);
  assert.equal(c.timersAtivos()[0].ms, 600_000, "após renovar, de novo 10 min (não 0)");
});

test("Q12.15-4: cliente 15 MIN (e 30 MIN) ADIANTADO — as artes NÃO são descartadas por skew local e não há loop", async (t) => {
  for (const skewMin of [15, 16, 30, 120]) {
    const relogioCliente = AGORA + skewMin * 60_000;
    const m = t.mock.method(Date, "now", () => relogioCliente);
    const c = cenario();
    c.relogio(relogioCliente);
    c.ctl.definirContexto(ctxA);
    c.pendentes[0].resolve(respostaCom([0, 1, 2, 3], { expiraEm: new Date(AGORA + 900_000).toISOString() }));
    await c.tick();
    assert.equal(Object.keys(c.ultimo().mapa).length, 4, `skew +${skewMin} min: arte preservada`);
    assert.equal(c.timersAtivos().length, 1);
    assert.equal(c.timersAtivos()[0].ms, 600_000);
    for (let i = 0; i < 10; i++) await c.tick();
    assert.equal(c.chamadas.length, 1, `skew +${skewMin} min: sem loop`);
    m.mock.restore();
  }
});

test("Q12.15-5: cliente ATRASADO — política continua relativa (10 min), independente do relógio absoluto e do valor de expira_em", async (t) => {
  const atraos = [];
  for (const [skewMin, expiraEm] of [[-5, new Date(AGORA + 900_000).toISOString()], [-30, new Date(AGORA + 900_000).toISOString()], [0, "2099-01-01T00:00:00.000Z"], [0, "2020-01-01T00:00:00.000Z"], [0, new Date(AGORA - 3_600_000).toISOString()]]) {
    const relogioCliente = AGORA + skewMin * 60_000;
    const m = t.mock.method(Date, "now", () => relogioCliente);
    const c = cenario();
    c.relogio(relogioCliente);
    c.ctl.definirContexto(ctxA);
    c.pendentes[0].resolve(respostaCom([0], { expiraEm }));
    await c.tick();
    assert.equal(Object.keys(c.ultimo().mapa).length, 1);
    atraos.push(c.timersAtivos()[0].ms);
    m.mock.restore();
  }
  assert.deepEqual(atraos, [600_000, 600_000, 600_000, 600_000, 600_000], "mockar Date.now()/expira_em não muda o atraso escolhido");
});

test("Q12.15-6: RACE A→B — A começa, contexto muda, B começa, A resolve depois: A não limpa o 'em voo' de B, não altera o mapa de B, e só B fica visível", async () => {
  const c = cenario();
  c.ctl.definirContexto(ctxA);                       // 1. A começa
  c.ctl.definirContexto(ctxB);                       // 2-3. muda e B começa
  assert.deepEqual(c.chamadas, ["admin|A|", "aluno|B|M"]);
  const [reqA, reqB] = c.pendentes;
  const antes = c.mudancas.length;
  reqA.resolve(respostaCom([0, 1, 2, 3], { prefixo: "A" })); // 4. A resolve depois
  await c.tick();
  assert.equal(c.mudancas.length, antes, "A não altera o mapa (nem dispara mudança alguma)");
  assert.equal(c.timersAtivos().length, 0, "A não agenda timer");
  // 5. o 'em voo' de B continua de pé: renovar por erro de imagem agora NÃO pode abrir uma segunda chamada
  c.ctl.renovarPorErroImagem();
  await c.tick();
  assert.equal(c.chamadas.length, 2, "finally de A não liberou a marca de B: nenhuma chamada duplicada");
  reqB.resolve(respostaCom([0, 1], { componente: COMP_B, prefixo: "B" })); // 7. B resolve
  await c.tick();
  const u = c.ultimo();
  assert.equal(u.chave, ctxB.chave);
  assert.deepEqual(Object.keys(u.mapa).sort(), [chaveArte(COMP_B, 0), chaveArte(COMP_B, 1)].sort(), "8. só a arte de B");
  assert.ok(Object.values(u.mapa).every((a) => a.url.includes("/B")));
  assert.equal(c.timersAtivos().length, 1);
});

test("Q12.15-7: RACE com REJEIÇÃO — A falha depois de B começar: nada muda, B segue dono do 'em voo'", async () => {
  const c = cenario();
  c.ctl.definirContexto(ctxA);
  c.ctl.definirContexto(ctxB);
  const [reqA, reqB] = c.pendentes;
  const antes = c.mudancas.length;
  reqA.reject(new Error("rede"));
  await c.tick();
  assert.equal(c.mudancas.length, antes);
  c.ctl.renovarPorErroImagem(); await c.tick();
  assert.equal(c.chamadas.length, 2, "B ainda em voo: sem chamada duplicada");
  reqB.resolve(respostaCom([2], { componente: COMP_B, prefixo: "B" })); await c.tick();
  assert.deepEqual(Object.keys(c.ultimo().mapa), [chaveArte(COMP_B, 2)]);
});

test("Q12.15-8: troca de contexto limpa a arte anterior na hora, cancela o timer e inicia UMA chamada; contexto repetido/nulo não chama", async () => {
  const c = cenario();
  c.ctl.definirContexto(ctxA);
  c.pendentes[0].resolve(respostaCom([0, 1]));
  await c.tick();
  const timerA = c.timersAtivos()[0];
  assert.ok(timerA);
  c.ctl.definirContexto(ctxB);
  assert.equal(timerA.ativo, false, "timer do contexto anterior cancelado");
  assert.equal(c.timersAtivos().length, 0);
  assert.deepEqual(c.ultimo(), { chave: ctxB.chave, mapa: {} }, "mapa limpo para o novo contexto: nada de arte da aula A na B");
  assert.equal(c.chamadas.length, 2, "uma chamada para o novo contexto");
  c.ctl.definirContexto({ ...ctxB });   // mesmo contexto de novo (re-render)
  c.ctl.definirContexto({ ...ctxB });
  assert.equal(c.chamadas.length, 2, "contexto repetido não chama de novo");
  const nulo = cenario();
  nulo.ctl.definirContexto(null);
  assert.equal(nulo.chamadas.length, 0, "sem contexto válido: nenhuma chamada");
});

test("Q12.15-9: timer ANTIGO após mudança de aula não executa (cancelado; e, mesmo disparado à força, é no-op)", async () => {
  const c = cenario();
  c.ctl.definirContexto(ctxA);
  c.pendentes[0].resolve(respostaCom([0])); await c.tick();
  const timerA = c.timersAtivos()[0];
  c.ctl.definirContexto(ctxB);
  timerA.fn(); // simula um timer que já estava na fila do navegador quando a aula mudou
  await c.tick();
  assert.equal(c.chamadas.length, 2, "o timer de A não gerou chamada");
  assert.ok(!c.chamadas.slice(2).length);
});

test("Q12.15-10: UNMOUNT durante a requisição — resposta tardia vira no-op (sem mapa, sem timer); timer pendente é cancelado", async () => {
  const c = cenario();
  c.ctl.definirContexto(ctxA);
  const antes = c.mudancas.length;
  c.ctl.destruir();
  c.pendentes[0].resolve(respostaCom([0, 1, 2, 3])); await c.tick();
  assert.equal(c.mudancas.length, antes, "nenhum setState depois de desmontar");
  assert.equal(c.timers.length, 0, "nenhum timer criado");
  // unmount com timer já agendado
  const d = cenario();
  d.ctl.definirContexto(ctxA);
  d.pendentes[0].resolve(respostaCom([0])); await d.tick();
  const t = d.timersAtivos()[0];
  d.ctl.destruir();
  assert.equal(t.ativo, false, "timer limpo no unmount");
  t.fn(); await d.tick();
  assert.equal(d.chamadas.length, 1, "mesmo forçado, não chama depois de destruído");
  // e o controlador pode ser reutilizado (StrictMode monta/desmonta/monta): recomeça limpo
  d.ctl.definirContexto(ctxA); await d.tick();
  assert.equal(d.chamadas.length, 2);
});

test("Q12.15-11: duas renovações simultâneas (erro de imagem x2, ou erro + timer) geram UMA chamada só", async () => {
  const c = cenario();
  c.ctl.definirContexto(ctxA);
  c.pendentes[0].resolve(respostaCom([0, 1])); await c.tick();
  c.relogio(AGORA + 60_000);
  c.ctl.renovarPorErroImagem();
  c.ctl.renovarPorErroImagem();
  c.ctl.renovarPorErroImagem();
  assert.equal(c.chamadas.length, 2, "3 pedidos de renovação no mesmo instante => 1 chamada");
  // o timer vence enquanto a renovação por erro ainda está em voo: também não duplica
  const t = c.timersAtivos()[0];
  if (t) { t.ativo = false; t.fn(); }
  await c.tick();
  assert.equal(c.chamadas.length, 2);
  c.pendentes[1].resolve(respostaCom([0, 1], { prefixo: "n" })); await c.tick();
  assert.equal(c.timersAtivos().length, 1, "um timer só depois da renovação");
});

test("Q12.15-12: assets vazios — sem timer, sem consulta periódica, mapa vazio (fallback textual)", async () => {
  const c = cenario();
  c.ctl.definirContexto(ctxA);
  c.pendentes[0].resolve({ assets: [] }); await c.tick();
  assert.deepEqual(c.ultimo(), { chave: ctxA.chave, mapa: {} });
  assert.equal(c.timers.length, 0, "nenhum timer criado");
  for (let i = 0; i < 20; i++) await c.tick();
  assert.equal(c.chamadas.length, 1, "sem loop");
  // renovação que passa a devolver vazio cancela o timer e esvazia o mapa
  const d = cenario();
  d.ctl.definirContexto(ctxA);
  d.pendentes[0].resolve(respostaCom([0])); await d.tick();
  d.dispararTimer(); await d.tick();
  d.pendentes[1].resolve({ assets: [] }); await d.tick();
  assert.deepEqual(d.ultimo().mapa, {});
  assert.equal(d.timersAtivos().length, 0);
});

test("Q12.15-13: erro/payload inválido da Edge — fallback mantido, SEM retry automático e SEM timer", async () => {
  for (const falha of [(p) => p.reject(new Error("401")), (p) => p.resolve(null), (p) => p.resolve("lixo"), (p) => p.resolve({ assets: "x" }), (p) => p.resolve({ assets: [{ url: "http://inseguro" }] })]) {
    const c = cenario();
    c.ctl.definirContexto(ctxA);
    falha(c.pendentes[0]);
    await c.tick();
    for (let i = 0; i < 20; i++) await c.tick();
    assert.equal(c.chamadas.length, 1, "nenhum retry");
    assert.equal(c.timers.length, 0, "nenhum timer");
    assert.ok(c.mudancas.every((m) => Object.keys(m.mapa).length === 0), "nenhuma arte exibida");
  }
  // erro numa RENOVAÇÃO: mantém a arte que já havia e não agenda retry
  const d = cenario();
  d.ctl.definirContexto(ctxA);
  d.pendentes[0].resolve(respostaCom([0, 1])); await d.tick();
  d.dispararTimer(); await d.tick();
  const antes = d.mudancas.length;
  d.pendentes[1].reject(new Error("edge fora")); await d.tick();
  assert.equal(d.mudancas.length, antes, "mapa anterior preservado");
  assert.equal(d.timersAtivos().length, 0, "sem retry automático");
});

test("Q12.15-14: erro de imagem — renovação LIMITADA (3 por contexto, com intervalo mínimo), nunca ilimitada", async () => {
  const c = cenario();
  c.ctl.definirContexto(ctxA);
  c.pendentes[0].resolve(respostaCom([0])); await c.tick();
  let relogio = AGORA;
  for (let i = 0; i < 40; i++) {
    relogio += ARTE_INTERVALO_MIN_RENOVACAO_MS + 1_000; // sempre além do intervalo mínimo
    c.relogio(relogio);
    c.ctl.renovarPorErroImagem();
    const p = c.pendentes[c.pendentes.length - 1];
    p.resolve(respostaCom([0], { prefixo: `r${i}` })); await c.tick();
  }
  assert.equal(c.chamadas.length - 1, ARTE_LIMITE_RENOVACOES_POR_ERRO, "no máximo o limite por contexto");
  // 50 erros em rajada (sem passar o intervalo mínimo) => no máximo 1 renovação
  const d = cenario();
  d.ctl.definirContexto(ctxA);
  d.pendentes[0].resolve(respostaCom([0])); await d.tick();
  for (let i = 0; i < 50; i++) { d.ctl.renovarPorErroImagem(); if (d.pendentes.length > 1) d.pendentes[d.pendentes.length - 1].resolve(respostaCom([0])); await d.tick(); }
  assert.equal(d.chamadas.length - 1, 1, "rajada de erros => 1 renovação");
  // trocar de contexto zera o orçamento (é outro contexto)
  d.ctl.definirContexto(ctxB);
  assert.equal(d.chamadas.length, 3, "novo contexto: chamada inicial normal");
});

test("Q12.15-15: o hook entrega SÓ a arte do contexto atual (nunca a da aula anterior, nem por um render) e limpa tudo no unmount", () => {
  const codigo = ler("components/teoria/useArtesQuadrinho.ts").replace(/^\s*\/\/.*$/gm, "");
  assert.match(codigo, /const artes = chave !== null && estado\.chave === chave \? estado\.mapa : MAPA_VAZIO;/, "gating por chave do contexto");
  assert.match(codigo, /useEffect\(\(\) => \(\) => controlador\.destruir\(\), \[controlador\]\)/, "unmount destrói controlador (timer + requisição)");
  assert.match(codigo, /controlador\.definirContexto\(chave && aulaVersaoId \? \{ chave, modo, aulaVersaoId, missaoId \} : null\)/);
  assert.match(codigo, /\[controlador, chave, modo, aulaVersaoId, missaoId\]/, "troca de modo/aula/missão reexecuta o efeito");
  assert.match(codigo, /const habilitado = Boolean\(aulaVersaoId\) && \(modo === "admin" \|\| Boolean\(missaoId\)\)/, "sem ids válidos não há contexto (nem chamada)");
  assert.doesNotMatch(codigo, /console\.|setInterval/);
  assert.doesNotMatch(codigo, /SERVICE_ROLE|service_role|storage_path|prompt_visual|scene_hash/);
});

test("Q12.15-16: primeira renderização do hook (SSR) — não chama a Edge, devolve mapa vazio e não lança", async () => {
  const React = (await import("react")).default;
  const { renderToStaticMarkup } = await import("react-dom/server");
  function Sonda(props) { const r = hookMod.useArtesQuadrinho(props); return React.createElement("i", { "data-n": Object.keys(r.artes).length, "data-f": typeof r.aoErroArte }); }
  for (const props of [{ modo: "admin", aulaVersaoId: AULA }, { modo: "aluno", aulaVersaoId: AULA, missaoId: MISSAO }, { modo: "aluno", aulaVersaoId: AULA, missaoId: null }, { modo: "admin", aulaVersaoId: null }]) {
    assert.equal(renderToStaticMarkup(React.createElement(Sonda, props)), '<i data-n="0" data-f="function"></i>');
  }
});

test("Q12.15-17: corpo enviado à Edge só tem os campos do contrato (aluno: modo, aulaVersaoId, missaoId; admin: modo, aulaVersaoId)", () => {
  const codigo = ler("components/teoria/useArtesQuadrinho.ts").replace(/^\s*\/\/.*$/gm, "");
  assert.match(codigo, /const corpo = ctx\.modo === "aluno"\s*\? \{ modo: ctx\.modo, aulaVersaoId: ctx\.aulaVersaoId, missaoId: ctx\.missaoId \}\s*: \{ modo: ctx\.modo, aulaVersaoId: ctx\.aulaVersaoId \};/);
  assert.match(codigo, /functions\.invoke\("assinar-quadrinho-assets", \{ body: corpo \}\)/);
  assert.match(codigo, /if \(error\) throw new Error\("edge"\);/, "erro da Edge vira rejeição interna sem mensagem bruta");
});
