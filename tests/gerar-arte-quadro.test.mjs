import assert from "node:assert/strict";
import test from "node:test";
import { readFileSync, readdirSync, existsSync } from "node:fs";
import { fileURLToPath } from "node:url";
import path from "node:path";
import { CORS, tratarRequisicao } from "../supabase/functions/_shared/quadrinho-imagem/handler.mjs";
import {
  IMAGE_MODEL_PADRAO, IMAGE_OUTPUT_COMPRESSION_PADRAO, IMAGE_PROMPT_VERSION, IMAGE_QUALITY_PADRAO, IMAGE_REQUEST_TIMEOUT_MS_PADRAO, IMAGE_SIZE_PADRAO,
  MAX_BYTES_STORAGE, resolverConfiguracaoImagem,
} from "../supabase/functions/_shared/quadrinho-imagem/config.mjs";
import { OPENAI_IMAGES_ENDPOINT, gerarImagemOpenAI, montarCorpoRequisicaoImagem } from "../supabase/functions/_shared/quadrinho-imagem/openaiImage.mjs";
import { REGRA_SEM_TEXTO_V1, STYLE_BIBLE_V3, extrairCenas, montarPromptVisual } from "../supabase/functions/_shared/quadrinho-imagem/prompt.mjs";
import { camposDeLogSeguros, sanitizarFalhaImagem } from "../supabase/functions/_shared/quadrinho-imagem/sanitizar.mjs";
import { ErroImagem, decodificarBase64Estrito, validarWebp } from "../supabase/functions/_shared/quadrinho-imagem/webp.mjs";
import { processarAsset } from "../supabase/functions/_shared/quadrinho-imagem/worker.mjs";

// Fase Q12.1 — Edge gerar-arte-quadro. NENHUM teste chama a OpenAI, o Storage ou o banco
// reais: tudo é mock. O fetch global é trocado por uma armadilha para provar isso.
const fetchOriginal = globalThis.fetch;
globalThis.fetch = () => { throw new Error("fetch REAL proibido nos testes da Q12.1"); };
test.after(() => { globalThis.fetch = fetchOriginal; });

const raiz = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const ler = (relativo) => readFileSync(path.join(raiz, relativo), "utf8");
const indexTs = ler("supabase/functions/gerar-arte-quadro/index.ts");
const DIR_SHARED = "supabase/functions/_shared/quadrinho-imagem";

// ---------------------------------------------------------------- fixtures
const AULA = "52756262-8be4-4fb2-a9f3-2f5a158ea1d4";
const COMP = "1f4065f2-8fda-4f7d-8826-45955230678d";
const TOKEN = "9e1bbb4f-b959-4d96-95ce-bfe30822109b";
const HASH = "852707e6a146ede5c081d47ecefc277813fe9e76297301528a19a5562ff94bbc";
const CHAVE = "sk-proj-ABCDEFGH1234567890abcdefXYZ";
const config = resolverConfiguracaoImagem(() => undefined);

const CENAS = [
  "Noite. Um agente público passa diante de uma residência e ouve um pedido claro de socorro vindo de dentro.",
  "O agente está diante da entrada da residência. Um colega questiona se é possível entrar sem mandado por ser noite.",
  "O agente entra na residência para prestar socorro.",
  "Em outra situação, um agente segura uma ordem judicial diante de uma residência, à noite.",
];
const FALAS_E_TEXTOS = ["Socorro!", "Tem alguém pedindo ajuda lá dentro.", "Precisamos identificar qual hipótese constitucional", "Socorro permite o ingresso sem consentimento", "REGRA DE PROVA-fechamento-secreto"];
const componente = (cenas = CENAS) => ({
  id: COMP, tipo: "quadrinho_didatico", titulo: "Pode entrar à noite?",
  quadros: cenas.map((cena, i) => ({ cena, falas: [{ emissor: "Agente", texto: FALAS_E_TEXTOS[i % 3] }], legenda: FALAS_E_TEXTOS[3] })),
  fechamento: FALAS_E_TEXTOS[4],
});
const claim = (i = 0) => ({
  asset_id: "fe0830e9-9c79-4a5b-b270-2e4e2df22125", aula_versao_id: AULA, componente_id: COMP, quadro_indice: i, scene_hash: HASH, cena: CENAS[i],
  tentativa: 1, claim_token: TOKEN, lease_ate: "2030-01-01T00:00:00Z", storage_path_esperado: `${AULA}/${COMP}/${i}/${HASH.slice(0, 10)}-${TOKEN}.webp`,
});

function webp(tamanho = 200) {
  const b = new Uint8Array(tamanho);
  b.set([0x52, 0x49, 0x46, 0x46], 0);
  new DataView(b.buffer).setUint32(4, tamanho - 8, true);
  b.set([0x57, 0x45, 0x42, 0x50], 8);
  return b;
}
const b64 = (bytes) => Buffer.from(bytes).toString("base64");
const respostaOk = (bytes) => new Response(JSON.stringify({ data: [{ b64_json: b64(bytes) }] }), { status: 200 });

// ---------------------------------------------------------------- config
test("Q12.1-1: config — padrões, sobrescritas válidas e fallback seguro para valores inválidos", () => {
  assert.deepEqual(config, {
    model: IMAGE_MODEL_PADRAO, size: "1536x1024", quality: "high", outputFormat: "webp", outputCompression: IMAGE_OUTPUT_COMPRESSION_PADRAO,
    promptVersion: "quadrinho-imagem-v3", timeoutMs: 110_000, maxBytes: 262_144,
  });
  assert.equal(IMAGE_PROMPT_VERSION, "quadrinho-imagem-v3");
  const env = { OPENAI_IMAGE_MODEL: " outro-modelo ", OPENAI_IMAGE_SIZE: "1024X1024", OPENAI_IMAGE_QUALITY: "MEDIUM", OPENAI_IMAGE_COMPRESSION: "55", OPENAI_IMAGE_TIMEOUT_MS: "200000" };
  const c = resolverConfiguracaoImagem((n) => env[n]);
  assert.deepEqual([c.model, c.size, c.quality, c.outputCompression, c.timeoutMs], ["outro-modelo", "1024x1024", "medium", 55, 200000]);
  const ruim = { OPENAI_IMAGE_SIZE: "1000x1000", OPENAI_IMAGE_QUALITY: "ultra", OPENAI_IMAGE_COMPRESSION: "101", OPENAI_IMAGE_TIMEOUT_MS: "5" };
  const r = resolverConfiguracaoImagem((n) => ruim[n]);
  assert.deepEqual([r.size, r.quality, r.outputCompression, r.timeoutMs], [IMAGE_SIZE_PADRAO, IMAGE_QUALITY_PADRAO, IMAGE_OUTPUT_COMPRESSION_PADRAO, IMAGE_REQUEST_TIMEOUT_MS_PADRAO]);
  // formato e limite de bytes NÃO são configuráveis (bucket só aceita webp/256 KiB)
  const tent = resolverConfiguracaoImagem((n) => ({ OPENAI_IMAGE_OUTPUT_FORMAT: "png", OPENAI_IMAGE_MAX_BYTES: "999999999" })[n]);
  assert.equal(tent.outputFormat, "webp");
  assert.equal(tent.maxBytes, MAX_BYTES_STORAGE);
});

test("Q12.1-2: timeout padrão cabe no limite mais restritivo do Supabase (150 s free) com folga; modelo só em UM lugar", () => {
  assert.ok(config.timeoutMs < 150_000 && config.timeoutMs >= 100_000);
  const arquivos = readdirSync(path.join(raiz, DIR_SHARED)).map((f) => `${DIR_SHARED}/${f}`).concat("supabase/functions/gerar-arte-quadro/index.ts");
  const comLiteral = arquivos.filter((f) => /gpt-image-/.test(ler(f)));
  assert.deepEqual(comLiteral.map((f) => path.basename(f)), ["config.mjs"], "literal do modelo só na config central");
  assert.ok(!/OPENAI_MODEL\b/.test(indexTs), "não reutiliza o OPENAI_MODEL das aulas");
});

// ---------------------------------------------------------------- prompt
test("Q12.1-3: prompt — determinístico, com style bible, regra SEM TEXTO e continuidade das 3–6 cenas", () => {
  const args = { cenaAtual: CENAS[1], quadroIndice: 1, cenas: CENAS };
  const a = montarPromptVisual(args), b = montarPromptVisual({ ...args });
  assert.equal(a, b);
  assert.ok(a.includes(STYLE_BIBLE_V3) && a.includes(REGRA_SEM_TEXTO_V1));
  for (const frase of ["NO visible text", "NO captions", "NO speech bubbles", "NO letters", "NO numbers", "NO legal articles", "NO readable signs", "NO logos", "NO watermarks", "NO badges with readable markings", "NO UI text"]) assert.ok(a.includes(frase), frase);
  for (const frase of ["not childish", "not anime", "not caricature", "no graphic violence", "deep green", "discreet gold", "NO official crests", "NO insignia", "NO corporation names"]) assert.match(a, new RegExp(frase, "i"), frase);
  CENAS.forEach((cena, i) => assert.ok(a.includes(`Panel ${i + 1}${i === 1 ? " (THE ONE TO DRAW)" : ""}: ${cena}`)));
  assert.ok(a.includes(`Illustrate ONLY panel 2 of 4: ${CENAS[1]}`));
  assert.ok(a.includes(`[STYLE — ${IMAGE_PROMPT_VERSION}]`));
  assert.notEqual(montarPromptVisual({ cenaAtual: CENAS[2], quadroIndice: 2, cenas: CENAS }), a);
  for (const n of [3, 4, 5, 6]) {
    const cenas = Array.from({ length: n }, (_, i) => `Cena ${i + 1}: algo acontece na rua.`);
    assert.ok(montarPromptVisual({ cenaAtual: cenas[n - 1], quadroIndice: n - 1, cenas }).includes(`panel ${n} of ${n}`));
  }
  assert.ok(a.length <= 8000);
});

test("Q12.1-4: prompt NUNCA leva falas, legendas, fechamento nem conteúdo jurídico — só cenas (extrairCenas descarta o resto)", () => {
  const cenas = extrairCenas(componente());
  assert.deepEqual(cenas, CENAS);
  const prompt = montarPromptVisual({ cenaAtual: cenas[0], quadroIndice: 0, cenas });
  for (const texto of FALAS_E_TEXTOS) assert.ok(!prompt.includes(texto), `não pode conter: ${texto}`);
  assert.ok(!/legenda|fechamento|regra de prova|art\.\s*\d|artigo|constitui/i.test(prompt));
  assert.match(prompt, /do not add legal explanations, symbols of law or interpretations/);
});

test("Q12.1-5: prompt — contexto inválido é recusado (menos de 3, mais de 6, índice fora, cena do claim divergente, cena vazia)", () => {
  assert.throws(() => montarPromptVisual({ cenaAtual: "a", quadroIndice: 0, cenas: ["a", "b"] }), /CONTEXTO_INVALIDO/);
  assert.throws(() => montarPromptVisual({ cenaAtual: "a", quadroIndice: 0, cenas: Array(7).fill("a") }), /CONTEXTO_INVALIDO/);
  assert.throws(() => montarPromptVisual({ cenaAtual: CENAS[0], quadroIndice: 4, cenas: CENAS }), /CONTEXTO_INVALIDO/);
  assert.throws(() => montarPromptVisual({ cenaAtual: "outra cena", quadroIndice: 0, cenas: CENAS }), /CONTEXTO_INVALIDO/);
  assert.throws(() => extrairCenas(componente(["a", "", "c"])), /quadro sem cena/);
  assert.throws(() => extrairCenas(componente(["a", "b"])), /esperado 3 a 6 quadros/);
  assert.throws(() => extrairCenas(null), /CONTEXTO_INVALIDO/);
  assert.throws(() => extrairCenas({ quadros: "x" }), /CONTEXTO_INVALIDO/);
});

// ---------------------------------------------------------------- OpenAI
test("Q12.1-6: payload da Image API — só parâmetros oficiais, webp na origem, n=1, sem moderation/background improvisados", () => {
  const corpo = montarCorpoRequisicaoImagem({ prompt: "P", config });
  assert.deepEqual(corpo, { model: IMAGE_MODEL_PADRAO, prompt: "P", size: "1536x1024", quality: "high", output_format: "webp", output_compression: 70, n: 1 });
  assert.equal(OPENAI_IMAGES_ENDPOINT, "https://api.openai.com/v1/images/generations");
  const custom = montarCorpoRequisicaoImagem({ prompt: "P", config: { ...config, outputCompression: 40, quality: "medium" } });
  assert.equal(custom.output_compression, 40);
  assert.equal(custom.quality, "medium");
  assert.equal(custom.output_format, "webp");
});

test("Q12.1-7: gerarImagemOpenAI — request correto (POST, Bearer, JSON, signal) e resposta b64 vira bytes", async () => {
  const chamadas = [];
  const fetchImpl = async (url, init) => { chamadas.push({ url, init }); return respostaOk(webp(300)); };
  const bytes = await gerarImagemOpenAI({ prompt: "PROMPT", config, apiKey: CHAVE, fetchImpl });
  assert.equal(bytes.length, 300);
  assert.equal(chamadas.length, 1);
  const { url, init } = chamadas[0];
  assert.equal(url, OPENAI_IMAGES_ENDPOINT);
  assert.equal(init.method, "POST");
  assert.equal(init.headers.Authorization, `Bearer ${CHAVE}`);
  assert.equal(init.headers["Content-Type"], "application/json");
  assert.ok(init.signal instanceof AbortSignal);
  assert.equal(JSON.parse(init.body).output_format, "webp");
  assert.equal(JSON.parse(init.body).prompt, "PROMPT");
});

test("Q12.1-8: gerarImagemOpenAI — falhas viram ErroImagem com código estável e SEM vazar chave/corpo", async () => {
  const falha = (fetchImpl, apiKey = CHAVE) => gerarImagemOpenAI({ prompt: "p", config, apiKey, fetchImpl }).then(() => null, (e) => e);
  const e401 = await falha(async () => new Response(JSON.stringify({ error: { message: `Incorrect API key provided: ${CHAVE}. Bearer abc.def` } }), { status: 401 }));
  assert.ok(e401 instanceof ErroImagem && e401.codigo === "OPENAI_HTTP_401");
  assert.ok(!e401.message.includes(CHAVE) && !e401.message.includes("ABCDEFGH"), "chave mascarada");
  assert.equal((await falha(async () => new Response("não é json", { status: 200 }))).codigo, "OPENAI_JSON_INVALIDO");
  assert.equal((await falha(async () => new Response(JSON.stringify({ data: [] }), { status: 200 }))).codigo, "OPENAI_RESPOSTA_SEM_IMAGEM");
  assert.equal((await falha(async () => new Response(JSON.stringify({ data: [{}] }), { status: 200 }))).codigo, "OPENAI_RESPOSTA_SEM_IMAGEM");
  assert.equal((await falha(async () => new Response(JSON.stringify({ data: [{ b64_json: "" }] }), { status: 200 }))).codigo, "OPENAI_RESPOSTA_SEM_IMAGEM");
  assert.equal((await falha(async () => new Response(JSON.stringify({ data: [{ b64_json: "a" }, { b64_json: "b" }] }), { status: 200 }))).codigo, "OPENAI_RESPOSTA_SEM_IMAGEM");
  assert.equal((await falha(async () => new Response(JSON.stringify({ data: [{ b64_json: "@@@nao-base64@@@" }] }), { status: 200 }))).codigo, "BASE64_INVALIDO");
  assert.equal((await falha(async () => { throw new TypeError(`falha de rede com ${CHAVE}`); })).codigo, "OPENAI_REDE");
  assert.equal((await falha(async () => respostaOk(webp()), "  ")).codigo, "OPENAI_KEY_AUSENTE");
});

test("Q12.1-9: timeout — fetch pendurado é abortado pelo AbortController e vira IMAGEM_TIMEOUT", async () => {
  let abortado = false;
  const fetchPendurado = (_url, init) => new Promise((_ok, rejeita) => {
    init.signal.addEventListener("abort", () => { abortado = true; rejeita(Object.assign(new Error("aborted"), { name: "AbortError" })); });
  });
  const erro = await gerarImagemOpenAI({ prompt: "p", config: { ...config, timeoutMs: 40 }, apiKey: CHAVE, fetchImpl: fetchPendurado }).then(() => null, (e) => e);
  assert.ok(erro instanceof ErroImagem);
  assert.equal(erro.codigo, "IMAGEM_TIMEOUT");
  assert.ok(abortado);
});

// ---------------------------------------------------------------- WebP / base64
test("Q12.1-10: WebP — aceita RIFF/WEBP válido; rejeita PNG, JPEG, vazio, curto; limite 262144 é inclusivo", () => {
  assert.equal(validarWebp(webp(200)).length, 200);
  assert.equal(validarWebp(webp(262_144)).length, 262_144, "exatamente 262144 aceito");
  const codigo = (bytes) => { try { validarWebp(bytes); return null; } catch (e) { return e.codigo; } };
  assert.equal(codigo(webp(262_145)), "IMAGEM_EXCEDE_LIMITE_STORAGE");
  assert.equal(codigo(new Uint8Array(0)), "IMAGEM_VAZIA");
  assert.equal(codigo(Uint8Array.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0, 0, 0, 0, 0, 0])), "IMAGEM_NAO_E_WEBP", "PNG");
  assert.equal(codigo(Uint8Array.from([0xff, 0xd8, 0xff, 0xe0, 0, 0x10, 0x4a, 0x46, 0x49, 0x46, 0, 1, 1, 0])), "IMAGEM_NAO_E_WEBP", "JPEG");
  assert.equal(codigo(Uint8Array.from([0x52, 0x49, 0x46, 0x46, 0, 0, 0, 0, 0x57, 0x41, 0x56, 0x45])), "IMAGEM_NAO_E_WEBP", "RIFF/WAVE");
  assert.equal(codigo(Uint8Array.from([0x52, 0x49, 0x46])), "IMAGEM_NAO_E_WEBP", "curto");
  assert.equal(codigo("nao-bytes"), "IMAGEM_VAZIA");
  assert.equal(codigo(webp(300).subarray(0, 0)), "IMAGEM_VAZIA");
});

test("Q12.1-11: base64 estrito — decodifica o válido e recusa vazio, alfabeto errado, tamanho errado e lixo", () => {
  assert.deepEqual([...decodificarBase64Estrito(b64(Uint8Array.from([1, 2, 3, 4, 5])))], [1, 2, 3, 4, 5]);
  assert.deepEqual([...decodificarBase64Estrito("AQID\nBAU=")], [1, 2, 3, 4, 5], "quebras de linha toleradas");
  for (const ruim of ["", "   ", null, undefined, 123, "abc", "@@@@", "AQID=BAU=", "AQ=D"]) assert.throws(() => decodificarBase64Estrito(ruim), (e) => e.codigo === "BASE64_INVALIDO", String(ruim));
});

// ---------------------------------------------------------------- sanitização
test("Q12.1-12: sanitização — chave, Bearer, JWT, base64, literais do runtime, quebras de linha e 300 caracteres", () => {
  const jwt = ["e", "yJhbGciOiJIUzI1NiJ9", ".e", "yJzdWIiOiJ4In0", ".assinatura"].join("");
  const bruto = `Incorrect API key ${CHAVE}\nAuthorization: Bearer abc.def-123 ${jwt} token=${TOKEN} path=${claim().storage_path_esperado} ${"QUJD".repeat(40)} ${"x ".repeat(300)}`;
  const s = sanitizarFalhaImagem(bruto, { literais: [TOKEN, claim().storage_path_esperado] });
  assert.ok(s.length <= 300);
  for (const proibido of [CHAVE, "ABCDEFGH", "abc.def-123", "eyJ", TOKEN, "QUJDQUJD", "\n"]) assert.ok(!s.includes(proibido), `vazou: ${proibido}`);
  assert.equal(sanitizarFalhaImagem(null), "erro inesperado");
  assert.equal(sanitizarFalhaImagem(new ErroImagem("IMAGEM_EXCEDE_LIMITE_STORAGE", "300000 > 262144")), "IMAGEM_EXCEDE_LIMITE_STORAGE: 300000 > 262144");
});

test("Q12.1-13: log — lista branca de campos: claim_token, prompt, path, base64 e headers nunca passam", () => {
  const seguro = camposDeLogSeguros({ asset_id: "a", quadro_indice: 1, resultado: "ok", claim_token: TOKEN, prompt: "P", storage_path: "x", b64_json: "AAAA", authorization: `Bearer ${CHAVE}`, erro: `falha ${CHAVE}`, duracao_ms: 5 });
  assert.deepEqual(Object.keys(seguro).sort(), ["asset_id", "duracao_ms", "erro", "quadro_indice", "resultado"]);
  assert.ok(!JSON.stringify(seguro).includes(CHAVE));
});

// ---------------------------------------------------------------- worker (mocks)
function montarDeps(sobrescritas = {}) {
  const chamadas = [];
  const logs = [];
  const deps = {
    obterComponente: async (aula, comp) => { chamadas.push(["obterComponente", aula, comp]); return componente(); },
    gerarImagem: async ({ prompt }) => { chamadas.push(["gerarImagem", prompt]); return webp(4000); },
    uploadWebp: async ({ path: p, bytes }) => { chamadas.push(["uploadWebp", p, bytes.length]); return { error: null }; },
    removerObjeto: async (p) => { chamadas.push(["removerObjeto", p]); return { error: null }; },
    concluir: async (a) => { chamadas.push(["concluir", a]); return { aceito: true, motivo: "concluido" }; },
    falhar: async (a) => { chamadas.push(["falhar", a]); return { aceito: true }; },
    agora: (() => { let t = 1000; return () => (t += 250); })(),
    log: (evento, campos) => logs.push({ evento, campos }),
    ...sobrescritas,
  };
  return { deps, chamadas, logs };
}
const nomes = (chamadas) => chamadas.map((c) => c[0]);

test("Q12.1-14: sucesso — claim → prompt → OpenAI → WebP → upload (path do claim) → concluir aceito; nada de falhar/remover", async () => {
  const { deps, chamadas, logs } = montarDeps();
  const r = await processarAsset({ claim: claim(1), config, deps });
  assert.equal(r.resultado, "concluido");
  assert.deepEqual(nomes(chamadas), ["obterComponente", "gerarImagem", "uploadWebp", "concluir"]);
  const upload = chamadas.find((c) => c[0] === "uploadWebp");
  assert.equal(upload[1], claim(1).storage_path_esperado, "upload usa EXATAMENTE o path do claim");
  const [, args] = chamadas.find((c) => c[0] === "concluir");
  const promptEnviado = chamadas.find((c) => c[0] === "gerarImagem")[1];
  assert.deepEqual(args, { assetId: claim(1).asset_id, claimToken: TOKEN, sceneHash: HASH, storagePath: claim(1).storage_path_esperado, modelo: config.model, promptVersion: "quadrinho-imagem-v3", promptVisual: promptEnviado });
  assert.ok(promptEnviado.includes(`Illustrate ONLY panel 2 of 4: ${CENAS[1]}`));
  assert.ok(logs.some((l) => l.evento === "asset_concluido"));
  const tudo = JSON.stringify(logs);
  for (const proibido of [TOKEN, claim(1).storage_path_esperado, "Illustrate ONLY", "RIFF"]) assert.ok(!tudo.includes(proibido), `log vazou: ${proibido}`);
});

test("Q12.1-15: falha da OpenAI — falhar_quadrinho_asset com erro sanitizado e SEM upload", async () => {
  const { deps, chamadas } = montarDeps({ gerarImagem: async () => { throw new ErroImagem("OPENAI_HTTP_500", `erro do servidor ${CHAVE}`); } });
  const r = await processarAsset({ claim: claim(), config, deps });
  assert.equal(r.resultado, "falhou");
  assert.deepEqual(nomes(chamadas), ["obterComponente", "falhar"]);
  const [, f] = chamadas.find((c) => c[0] === "falhar");
  assert.deepEqual(Object.keys(f).sort(), ["assetId", "claimToken", "erro"]);
  assert.equal(f.claimToken, TOKEN);
  assert.ok(f.erro.startsWith("OPENAI_HTTP_500") && !f.erro.includes(CHAVE));
});

test("Q12.1-16: imagem grande demais / não-WebP — falhar sem upload (IMAGEM_EXCEDE_LIMITE_STORAGE)", async () => {
  for (const [bytes, codigo] of [[webp(MAX_BYTES_STORAGE + 1), "IMAGEM_EXCEDE_LIMITE_STORAGE"], [Uint8Array.from([0x89, 0x50, 0x4e, 0x47, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]), "IMAGEM_NAO_E_WEBP"], [new Uint8Array(0), "IMAGEM_VAZIA"]]) {
    const { deps, chamadas } = montarDeps({ gerarImagem: async () => bytes });
    const r = await processarAsset({ claim: claim(), config, deps });
    assert.equal(r.resultado, "falhou");
    assert.ok(!nomes(chamadas).includes("uploadWebp") && !nomes(chamadas).includes("removerObjeto"));
    assert.ok(chamadas.find((c) => c[0] === "falhar")[1].erro.startsWith(codigo), codigo);
  }
});

test("Q12.1-17: falha no upload (erro retornado OU lançado) — falhar; NUNCA concluir e NUNCA remover objeto alheio", async () => {
  for (const uploadWebp of [async () => ({ error: new Error("Duplicate: The resource already exists") }), async () => { throw new Error("rede"); }]) {
    const { deps, chamadas } = montarDeps({ uploadWebp });
    const r = await processarAsset({ claim: claim(), config, deps });
    assert.equal(r.resultado, "falhou");
    assert.equal(r.etapa, "upload");
    assert.deepEqual(nomes(chamadas), ["obterComponente", "gerarImagem", "falhar"]);
  }
});

test("Q12.1-18: concluir recusado (stale/claim perdido/cena alterada) — remove SÓ o objeto recém-enviado, não chama falhar", async () => {
  for (const motivo of ["claim_invalido", "cena_alterada"]) {
    const ctx = montarDeps();
    const { deps, chamadas } = ctx;
    deps.concluir = async (a) => { chamadas.push(["concluir", a]); return { aceito: false, motivo }; };
    const r = await processarAsset({ claim: claim(2), config, deps });
    assert.equal(r.resultado, "stale_limpo");
    assert.equal(r.motivo, motivo);
    assert.deepEqual(nomes(chamadas), ["obterComponente", "gerarImagem", "uploadWebp", "concluir", "removerObjeto"]);
    assert.equal(chamadas.filter((c) => c[0] === "removerObjeto").length, 1);
    assert.equal(chamadas.find((c) => c[0] === "removerObjeto")[1], claim(2).storage_path_esperado, "remove exatamente o path que subiu");
  }
});

test("Q12.1-19: cleanup falha após concluir recusado — não apaga outro path, não mascara, log sanitizado (o GC Q11 resolve)", async () => {
  const { deps, chamadas, logs } = montarDeps({
    concluir: async () => ({ aceito: false, motivo: "claim_invalido" }),
    removerObjeto: async (p) => { chamadas.push(["removerObjeto", p]); return { error: new Error(`storage indisponível para ${p} ${CHAVE}`) }; },
  });
  const r = await processarAsset({ claim: claim(), config, deps });
  assert.equal(r.resultado, "stale_limpeza_falhou");
  assert.deepEqual(chamadas.filter((c) => c[0] === "removerObjeto").map((c) => c[1]), [claim().storage_path_esperado], "só o path desta execução, uma única tentativa");
  assert.ok(logs.some((l) => l.evento === "cleanup_falhou"));
  const tudo = JSON.stringify(logs);
  assert.ok(!tudo.includes(CHAVE) && !tudo.includes(TOKEN));
  assert.ok(!nomes(chamadas).includes("falhar"), "o estado novo pertence a outro worker");
});

test("Q12.1-20: concluir lança por transporte — repete (idempotente) antes de decidir; se ainda falhar NÃO remove e registra falhar", async () => {
  let n = 0;
  const { deps, chamadas } = montarDeps({ concluir: async (a) => { chamadas.push(["concluir", a]); n += 1; if (n === 1) throw new Error("timeout de rede"); return { aceito: true, motivo: "ja_concluido" }; } });
  const r1 = await processarAsset({ claim: claim(), config, deps });
  assert.equal(r1.resultado, "concluido");
  assert.equal(chamadas.filter((c) => c[0] === "concluir").length, 2);
  assert.ok(!nomes(chamadas).includes("removerObjeto") && !nomes(chamadas).includes("falhar"));

  const b = montarDeps({ concluir: async () => { throw new Error("rede fora"); } });
  const r2 = await processarAsset({ claim: claim(), config, deps: b.deps });
  assert.equal(r2.resultado, "concluir_indeterminado");
  assert.ok(!nomes(b.chamadas).includes("removerObjeto"), "estado desconhecido: o objeto pode estar referenciado");
  assert.ok(nomes(b.chamadas).includes("falhar"));
});

test("Q12.1-21: contexto inválido (componente sumiu/cenas fora de 3–6/cena divergente) — falhar sem tocar OpenAI nem Storage", async () => {
  for (const comp of [null, componente(["a", "b"]), componente(Array(7).fill("x")), componente(["outra", ...CENAS.slice(1)])]) {
    const { deps, chamadas } = montarDeps({ obterComponente: async () => comp });
    const r = await processarAsset({ claim: claim(0), config, deps });
    assert.equal(r.resultado, "falhou");
    assert.deepEqual(nomes(chamadas), ["falhar"]);
    assert.ok(chamadas[0][1].erro.startsWith("CONTEXTO_INVALIDO"));
  }
});

test("Q12.1-22: o worker nunca lança — nem se falhar_quadrinho_asset ou o log falharem", async () => {
  const { deps } = montarDeps({ gerarImagem: async () => { throw new Error("boom"); }, falhar: async () => { throw new Error("rpc fora"); }, log: () => { throw new Error("log fora"); } });
  const r = await processarAsset({ claim: claim(), config, deps });
  assert.equal(r.resultado, "falhou_sem_registro");
});

// ---------------------------------------------------------------- handler HTTP / waitUntil
const req = (metodo = "POST", corpo, headers = { Authorization: "Bearer jwt-do-admin" }) =>
  new Request("http://edge.local/gerar-arte-quadro", { method: metodo, headers, body: metodo === "POST" || metodo === "PUT" ? (typeof corpo === "string" ? corpo : JSON.stringify(corpo ?? {})) : undefined });

function depsHttp(sobrescritas = {}) {
  const estado = { agendadas: [], reservas: [], liberados: [], logs: [], processadas: 0 };
  const deps = {
    autorizarAdmin: async () => ({ ok: true }),
    reservar: async (aulaVersaoId) => { estado.reservas.push(aulaVersaoId); return claim(); },
    processar: async () => { estado.processadas += 1; },
    agendar: (tarefa) => { estado.agendadas.push(tarefa); },
    liberarClaim: async (c, erro) => { estado.liberados.push([c.asset_id, erro]); },
    log: (evento, campos) => estado.logs.push([evento, campos]),
    ...sobrescritas,
  };
  return { deps, estado };
}

test("Q12.1-23: HTTP — 405, OPTIONS/CORS, 401 sem sessão, 403 não-admin (nada é reservado nem agendado)", async () => {
  const { deps, estado } = depsHttp();
  assert.equal((await tratarRequisicao(req("GET"), deps)).status, 405);
  const opt = await tratarRequisicao(req("OPTIONS"), deps);
  assert.equal(opt.status, 200);
  assert.equal(opt.headers.get("Access-Control-Allow-Methods"), "POST, OPTIONS");
  assert.deepEqual(Object.keys(CORS).sort(), ["Access-Control-Allow-Headers", "Access-Control-Allow-Methods", "Access-Control-Allow-Origin"]);
  const semSessao = depsHttp({ autorizarAdmin: async (h) => (h ? { ok: true } : { ok: false, status: 401, mensagem: "Sessão não encontrada." }) });
  assert.equal((await tratarRequisicao(req("POST", {}, {}), semSessao.deps)).status, 401);
  const naoAdmin = depsHttp({ autorizarAdmin: async () => ({ ok: false, status: 403, mensagem: "Apenas administradores." }) });
  assert.equal((await tratarRequisicao(req(), naoAdmin.deps)).status, 403);
  for (const e of [estado, semSessao.estado, naoAdmin.estado]) assert.deepEqual([e.reservas.length, e.agendadas.length], [0, 0]);
  const quebrada = depsHttp({ autorizarAdmin: async () => { throw new Error("auth fora"); } });
  assert.equal((await tratarRequisicao(req(), quebrada.deps)).status, 500);
  assert.equal(quebrada.estado.reservas.length, 0);
});

test("Q12.1-24: HTTP — corpo inválido/campos proibidos/UUID ruim = 400 sem reservar; o cliente NÃO força asset, token, path, hash nem tentativas", async () => {
  for (const corpo of ["{não json", "[]", "null", { asset_id: AULA }, { claim_token: TOKEN }, { storagePath: "x" }, { sceneHash: HASH }, { tentativas: 0 }, { model: "x" }, { aulaVersaoId: "nao-uuid" }, { aulaVersaoId: 5 }]) {
    const { deps, estado } = depsHttp();
    const r = await tratarRequisicao(req("POST", corpo), deps);
    assert.equal(r.status, 400, JSON.stringify(corpo));
    assert.equal(estado.reservas.length + estado.agendadas.length, 0);
  }
  const { deps, estado } = depsHttp();
  assert.equal((await tratarRequisicao(req("POST", ""), deps)).status, 202, "corpo vazio é permitido");
  await tratarRequisicao(req("POST", { aulaVersaoId: AULA }), deps);
  assert.deepEqual(estado.reservas, [null, AULA], "só aulaVersaoId restringe o claim");
});

test("Q12.1-25: HTTP — sem job elegível responde 200 e NÃO agenda nada", async () => {
  const { deps, estado } = depsHttp({ reservar: async () => null });
  const r = await tratarRequisicao(req(), deps);
  assert.equal(r.status, 200);
  assert.deepEqual(await r.json(), { accepted: false, motivo: "sem_job_elegivel" });
  assert.equal(estado.agendadas.length, 0);
});

test("Q12.1-26: waitUntil — responde 202 ANTES do trabalho terminar; exatamente UMA task agendada por claim; corpo sem segredos", async () => {
  let liberar;
  const trabalho = new Promise((ok) => { liberar = ok; });
  let terminou = false;
  const { deps, estado } = depsHttp({ processar: async () => { await trabalho; terminou = true; } });
  const r = await tratarRequisicao(req(), deps);
  assert.equal(r.status, 202);
  assert.equal(terminou, false, "a resposta HTTP não espera o trabalho");
  assert.equal(estado.agendadas.length, 1, "exatamente uma task");
  const corpo = await r.json();
  assert.deepEqual(corpo, { accepted: true, asset_id: claim().asset_id, quadro_indice: 0, tentativa: 1 });
  const texto = JSON.stringify(corpo);
  for (const proibido of [TOKEN, "claim_token", "storage_path", HASH, "prompt", "b64", "service_role", "sk-", "Bearer"]) assert.ok(!texto.includes(proibido), `resposta vazou: ${proibido}`);
  liberar();
  await estado.agendadas[0];
  assert.equal(terminou, true);
  assert.equal(estado.processadas, 0, "processar substituído acima; contador só conta o padrão");
});

test("Q12.1-27: HTTP — reserva que falha = 500 sem agendar; agendamento que falha = 500 e devolve o claim via falhar (não fica `gerando` até o lease)", async () => {
  const a = depsHttp({ reservar: async () => { throw new Error(`RPC fora ${CHAVE}`); } });
  const ra = await tratarRequisicao(req(), a.deps);
  assert.equal(ra.status, 500);
  assert.ok(!(await ra.text()).includes(CHAVE));
  assert.equal(a.estado.agendadas.length, 0);
  assert.ok(!JSON.stringify(a.estado.logs).includes(CHAVE));

  const b = depsHttp({ agendar: () => { throw new Error("waitUntil indisponível"); } });
  const rb = await tratarRequisicao(req(), b.deps);
  assert.equal(rb.status, 500);
  assert.deepEqual(b.estado.liberados.map((x) => x[0]), [claim().asset_id]);
});

test("Q12.1-28: dois cliques — cada invocação depende só do claim da RPC; a task nunca rejeita e um claim vazio do segundo clique não agenda", async () => {
  let n = 0;
  const { deps, estado } = depsHttp({ reservar: async () => (n++ === 0 ? claim(0) : null), processar: async () => { throw new Error("worker rejeitou"); } });
  const [r1, r2] = await Promise.all([tratarRequisicao(req(), deps), tratarRequisicao(req(), deps)]);
  assert.deepEqual([r1.status, r2.status].sort(), [200, 202]);
  assert.equal(estado.agendadas.length, 1);
  await estado.agendadas[0];
  assert.ok(estado.logs.some(([e]) => e === "processamento_rejeitado"));
});

// ---------------------------------------------------------------- index.ts + escopo
test("Q12.1-29: index.ts — waitUntil, service_role só no worker, admin via eh_admin, RPCs Q10 reais, upsert:false, image/webp, bucket certo", () => {
  assert.match(indexTs, /EdgeRuntime\.waitUntil\(tarefa\)/);
  assert.match(indexTs, /declare const EdgeRuntime/);
  assert.match(indexTs, /auth\.auth\.getUser\(/);
  assert.match(indexTs, /auth\.rpc\("eh_admin"\)/);
  assert.match(indexTs, /createClient\(supabaseUrl, anonKey, \{ global: \{ headers: \{ Authorization: authorization \} \} \}\)/);
  assert.match(indexTs, /createClient\(supabaseUrl, serviceKey\)/);
  assert.match(indexTs, /upsert: false/);
  assert.doesNotMatch(indexTs, /upsert: true/);
  assert.match(indexTs, /contentType: "image\/webp"/);
  assert.match(indexTs, /const BUCKET = "quadrinhos-aulas"/);
  assert.match(indexTs, /\.remove\(\[path\]\)/);
  assert.match(indexTs, /verify_jwt precisa ficar LIGADO/);
  assert.match(indexTs, /OPENAI_API_KEY/);
  // chamada real à OpenAI só no adaptador; index nunca faz fetch próprio
  assert.doesNotMatch(indexTs, /\bfetch\(/);
  assert.doesNotMatch(indexTs, /api\.openai\.com/);
  assert.match(indexTs, /if \(!openaiKey\) throw/, "sem chave não reserva");
});

test("Q12.1-30: index.ts usa EXATAMENTE as assinaturas reais das RPCs do Q10 (nomes de parâmetros conferidos no SQL versionado)", () => {
  const sql = ler("supabase/camada_ilustrada_pipeline.sql");
  const assinatura = (nome) => sql.match(new RegExp(`create function public\\.${nome}\\(([\\s\\S]*?)\\)\\s*returns`))?.[1].replace(/\s+/g, " ") ?? "";
  const argsUsados = (nome) => {
    const bloco = indexTs.match(new RegExp(`"${nome}", \\{([^}]*)\\}`))?.[1] ?? "";
    return [...bloco.matchAll(/(p_[a-z_]+)/g)].map((m) => m[1]);
  };
  assert.match(indexTs, /"reservar_quadrinho_asset", aulaVersaoId \? \{ p_aula_versao_id: aulaVersaoId \} : \{\}/);
  assert.match(sql, /function public\.reservar_quadrinho_asset\(\s*p_aula_versao_id uuid/);
  for (const nome of ["concluir_quadrinho_asset", "falhar_quadrinho_asset", "quadrinho_componente"]) {
    const sig = nome === "quadrinho_componente" ? "p_aula_versao_id uuid, p_componente_id uuid" : assinatura(nome);
    const usados = argsUsados(nome);
    assert.ok(usados.length > 0, `${nome} chamada no index`);
    for (const p of usados) assert.ok(sig.includes(p), `${nome}: parâmetro ${p} não existe na assinatura (${sig})`);
  }
  assert.equal(argsUsados("concluir_quadrinho_asset").length, 7);
  assert.equal(argsUsados("falhar_quadrinho_asset").length, 3);
  // quadrinho_componente é helper do Q10 — confirmado no SQL versionado
  assert.match(sql, /create function public\.quadrinho_componente\(p_aula_versao_id uuid, p_componente_id uuid\)/);
});

test("Q12.1-31: import closure — só imports relativos do pacote (+ supabase-js via esm.sh), sem ciclos, sem sharp/libvips, sem frontend", () => {
  const base = path.join(raiz, "supabase/functions/gerar-arte-quadro");
  const visitado = new Map();
  const externos = new Set();
  const visitar = (arquivo) => {
    if (visitado.has(arquivo)) return;
    const src = readFileSync(arquivo, "utf8").replace(/\/\*[\s\S]*?\*\//g, "").replace(/^\s*\/\/.*$/gm, "");
    const deps = [];
    for (const m of src.matchAll(/(?:^|\n)\s*import\s[^;'"]*?from\s+["']([^"']+)["']/g)) {
      const spec = m[1];
      if (!spec.startsWith(".")) { externos.add(spec); continue; }
      assert.match(spec, /\.(mjs|ts)$/, `import sem extensão explícita: ${spec}`);
      deps.push(path.resolve(path.dirname(arquivo), spec));
    }
    visitado.set(arquivo, deps);
    for (const d of deps) { assert.ok(existsSync(d), `import inexistente: ${d}`); visitar(d); }
  };
  visitar(path.join(base, "index.ts"));
  // ciclos
  const estado = new Map();
  const dfs = (n, pilha) => { estado.set(n, 1); for (const d of visitado.get(n) ?? []) { assert.notEqual(estado.get(d), 1, `ciclo: ${[...pilha, n, d].map((x) => path.basename(x)).join(" -> ")}`); if (!estado.get(d)) dfs(d, [...pilha, n]); } estado.set(n, 2); };
  dfs(path.join(base, "index.ts"), []);
  assert.deepEqual([...externos], ["https://esm.sh/@supabase/supabase-js@2"]);
  const arquivos = [...visitado.keys()].map((f) => path.relative(raiz, f).replaceAll("\\", "/"));
  for (const f of arquivos) {
    assert.ok(f.startsWith("supabase/functions/"), `fora de supabase/functions: ${f}`);
    const semComentarios = readFileSync(path.join(raiz, f), "utf8").replace(/\/\*[\s\S]*?\*\//g, "").replace(/^\s*\/\/.*$/gm, "");
    assert.doesNotMatch(semComentarios, /\b(sharp|libvips)\b|from ["'](react|next\/|@\/)/i, `import proibido em ${f}`);
  }
  assert.ok(arquivos.length >= 8, `closure = ${arquivos.length} arquivos`);
});

test("Q12.1-32: escopo — sem SQL novo, sem segredo hardcoded, sem OpenAI/Storage/Edge de GC, gerar-aula e frontend intactos", () => {
  for (const f of readdirSync(path.join(raiz, DIR_SHARED))) {
    const src = ler(`${DIR_SHARED}/${f}`);
    assert.doesNotMatch(src, /eyJ[A-Za-z0-9_-]{15,}\.[A-Za-z0-9_-]{10,}\.|sk-[A-Za-z0-9_-]{20,}|sbp_[A-Za-z0-9]{20,}|SERVICE_ROLE_KEY\s*=/, f);
    assert.doesNotMatch(src.replace(/\/\*[\s\S]*?\*\//g, "").replace(/^\s*\/\/.*$/gm, ""), /\b(sharp|libvips)\b/i, f);
  }
  assert.doesNotMatch(indexTs, /eyJ[A-Za-z0-9_-]{15,}\.[A-Za-z0-9_-]{10,}\.|sk-[A-Za-z0-9_-]{20,}/);
  assert.ok(!existsSync(path.join(raiz, "supabase/functions/limpar-uploads-orfaos-quadrinho")), "Edge de GC fica para fase posterior");
  assert.ok(!existsSync(path.join(raiz, "supabase/gerar_arte_quadro.sql")), "sem SQL novo");
  // Somente UM módulo referencia a API de imagem (adaptador isolado)
  const comEndpoint = readdirSync(path.join(raiz, DIR_SHARED)).filter((f) => ler(`${DIR_SHARED}/${f}`).includes("api.openai.com"));
  assert.deepEqual(comEndpoint, ["openaiImage.mjs"]);
  // A pasta nova só tem os módulos esperados
  assert.deepEqual(readdirSync(path.join(raiz, DIR_SHARED)).sort(), ["config.mjs", "handler.mjs", "openaiImage.mjs", "prompt.mjs", "sanitizar.mjs", "webp.mjs", "worker.mjs"]);
});


// ---------------------------------------------------------------- Q12.5 (direção artística v3)
test("Q12.5-1: style bible v3 — mantém os bloqueios de fotografia da v2 e acrescenta definição, separação sujeito/fundo, luz frio/quente e legibilidade humana", () => {
  const prompt = montarPromptVisual({ cenaAtual: CENAS[0], quadroIndice: 0, cenas: CENAS });
  // ilustração editorial / graphic novel adulta, semi-realista, desenhada e pintada
  for (const exigido of ["graphic-novel illustration", "premium contemporary graphic novel", "drawn and painted by an illustrator", "semi-realistic digital painting", "slightly simplified forms", "discreet selective ink-like contour lines", "controlled stylized graphic shadows", "visible brush and paper texture", "NOT photographic", "adult natural anatomy", "ILLUSTRATED, never photographic"]) {
    assert.ok(prompt.includes(exigido), "falta diretriz de ilustração: " + exigido);
  }
  // clareza / separação / luz — o que a v2 não entregou
  for (const exigido of ["strong separation between characters and background", "value contrast", "rim light", "clean readable silhouettes", "thumbnail size", "lifted mid-tones", "unmistakably human", "fully legible", "visible face", "clear gesture", "cool blue-grey exteriors", "warm golden interior light", "temperature contrast", "deep green", "discreet gold"]) {
    assert.ok(prompt.includes(exigido), "falta diretriz de clareza/luz: " + exigido);
  }
  // bloqueios (fotografia + defeitos observados na v2)
  for (const bloqueio of ["NO photorealism", "NO photography", "NO DSLR look", "NO live-action still", "NO movie still", "NO hyperreal rendering", "NO photographic skin texture", "NO photographic depth of field",
    "horror aesthetic", "ghostly figure", "fog-obscured face", "muddy shadows", "crushed blacks", "low subject-background separation", "thick comic outlines"]) {
    assert.ok(prompt.includes(bloqueio), "falta bloqueio: " + bloqueio);
  }
  for (const evitar of ["not cartoon", "not anime", "not childish", "not caricature", "no cel shading", "not superhero comics", "no thriller excess"]) assert.ok(prompt.toLowerCase().includes(evitar), evitar);
  // instrução positiva da v1 que empurrava para live-action não volta
  assert.doesNotMatch(STYLE_BIBLE_V3, /Realistic illustrated style|Everyday realistic clothing|photorealistic style|cinematic photograph/i);
  // uniformes genéricos, sem brasão, separados do fundo
  assert.ok(prompt.includes("NO official crests") && prompt.includes("NO insignia") && prompt.includes("clearly separated from the background"));
  // regras que NÃO mudam
  assert.ok(prompt.includes(REGRA_SEM_TEXTO_V1));
  assert.ok(prompt.includes("Illustrate ONLY panel 1 of 4: " + CENAS[0]));
  assert.ok(prompt.includes("Draw one single landscape frame: no panel borders, no collage, no multiple panels."));
  assert.ok(prompt.includes("do not add legal explanations, symbols of law or interpretations"));
  for (const texto of FALAS_E_TEXTOS) assert.ok(!prompt.includes(texto));
  // versão nova, sem sobrescrever a identificação da v2
  assert.equal(IMAGE_PROMPT_VERSION, "quadrinho-imagem-v3");
  assert.ok(prompt.includes("[STYLE — quadrinho-imagem-v3]"));
  assert.ok(prompt.length < 4000, "prompt continua bem abaixo do limite de auditoria de 8000");
});

test("Q12.5-2: o conteúdo da cena e o prompt-base por painel são idênticos entre painéis (só muda o painel a desenhar); v3 é determinística", () => {
  const p0 = montarPromptVisual({ cenaAtual: CENAS[0], quadroIndice: 0, cenas: CENAS });
  const p0b = montarPromptVisual({ cenaAtual: CENAS[0], quadroIndice: 0, cenas: CENAS });
  const p1 = montarPromptVisual({ cenaAtual: CENAS[1], quadroIndice: 1, cenas: CENAS });
  assert.equal(p0, p0b);
  assert.ok(p0.includes(STYLE_BIBLE_V3) && p1.includes(STYLE_BIBLE_V3), "mesma style bible em todos os painéis");
  assert.notEqual(p0, p1);
});
