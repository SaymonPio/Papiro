import assert from "node:assert/strict";
import test from "node:test";
import { existsSync, readFileSync, readdirSync } from "node:fs";
import { fileURLToPath } from "node:url";
import path from "node:path";
import { validarRespostaGerador, QUADRINHO_LIMITES } from "../supabase/functions/_shared/gerar-aula/validador.mjs";
import { persistirAulaGerada } from "../supabase/functions/_shared/gerar-aula/persistirAulaGerada.mjs";
import { auditarEscopoArtigos } from "../supabase/functions/_shared/gerar-aula/escopo.mjs";
import { montarPromptContexto } from "../supabase/functions/_shared/gerar-aula/openaiResponses.mjs";
import { normalizarQuadrinho } from "../components/teoria/tiposComponenteAula.ts";
import { prepararAulaImpressao } from "../components/teoria/prepararAulaImpressao.ts";

// Fase Q5 — auditoria integrada (somente testes, nenhum código de produção
// alterado): prompt ↔ validador ↔ persistência ↔ renderer ↔ PDF, mais o
// grafo de imports das Edge Functions. Tudo local; nenhum banco, nenhuma
// rede, nenhuma chamada à OpenAI.

const raiz = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const ler = (relativo) => readFileSync(path.join(raiz, relativo), "utf8");
const sharedDir = path.join(raiz, "supabase/functions/_shared/gerar-aula");

// ---------- fixture completa ----------

function respostaDaIa() {
  return {
    artigos_abordados: ["art. 5º, XI"],
    componentes: [
      { tipo: "diagnostico", titulo: "O que você já sabe?", introducao: "Antes de decorar, pense na prática.", pergunta: "Pode entrar na casa à noite?", resposta_esperada: "Depende da situação." },
      { tipo: "conceito", titulo: "Inviolabilidade do domicílio", explicacao: "A casa é asilo inviolável; a regra é o consentimento do morador.", exemplo: "Incêndio permite entrar.", ponto_de_prova: "Só ordem judicial exige o dia.", pegadinha: "Ordem judicial não vale à noite." },
      {
        tipo: "quadrinho_didatico",
        titulo: "Socorro à noite",
        quadros: [
          { cena: "Agente passa em frente a uma residência à noite e ouve pedido de socorro.", falas: [{ emissor: "Voz", texto: "Socorro!" }, { emissor: "Agente", texto: "Quem está aí?" }], legenda: "Início da noite." },
          { cena: "O agente hesita por não ter ordem judicial.", falas: [] },
          { cena: "O agente entra para prestar socorro.", falas: [{ emissor: "Agente", texto: "Vou entrar para socorrer." }], legenda: null },
        ],
        fechamento: "Flagrante, desastre e socorro: a qualquer hora. Ordem judicial: só de dia.",
      },
      { tipo: "recall", titulo: "Recupere", pergunta: "Quais são as hipóteses?", resposta: "Flagrante, desastre, socorro e ordem judicial de dia.", dica: null },
      { tipo: "questao_resolvida", enunciado: "Assinale a correta.", alternativas: [{ letra: "A", texto: "a" }, { letra: "B", texto: "b" }, { letra: "C", texto: "c" }, { letra: "D", texto: "d" }], gabarito: "B", raciocinio: "B está correta.", pegadinha: null },
      { tipo: "resumo_visual", titulo: "Resumo", pontos: ["Casa: consentimento é a regra.", "Exceções: flagrante, desastre, socorro."] },
    ],
  };
}

function criarAdminMock(capturas) {
  const respostas = {
    "select:aulas": { data: null, error: null },
    "insert:aulas": { data: { id: "aula-1" }, error: null },
    "select:aula_versoes": { data: null, error: null },
    "insert:aula_versoes": { data: { id: "versao-1" }, error: null },
    "update:aula_geracoes": { data: null, error: null },
  };
  function builder(tabela, operacao, payload) {
    const resolver = () => {
      capturas.push({ tabela, operacao, payload });
      return respostas[`${operacao}:${tabela}`] ?? { data: null, error: null };
    };
    const c = {
      select() { return c; }, eq() { return c; }, order() { return c; }, limit() { return c; },
      async maybeSingle() { return resolver(); }, async single() { return resolver(); },
      then(ok, ko) { return Promise.resolve(resolver()).then(ok, ko); },
    };
    return c;
  }
  return {
    from(tabela) {
      return {
        select() { return builder(tabela, "select"); },
        insert(p) { return builder(tabela, "insert", p); },
        update(p) { return builder(tabela, "update", p); },
      };
    },
  };
}

async function percorrerPipeline(resposta) {
  // 1) o que a Responses API devolve é TEXTO; o finalizador faz JSON.parse
  const dados = JSON.parse(JSON.stringify(resposta));
  // 2) validação real
  const validacao = validarRespostaGerador(dados);
  assert.equal(validacao.ok, true, validacao.erro);
  // 3) persistência real (persistirAulaGerada) contra um client simulado
  const capturas = [];
  const r = await persistirAulaGerada({
    admin: criarAdminMock(capturas),
    geracaoId: "g1", conteudoId: 47, unidadePedagogicaId: "u1", unidadeTitulo: "U", materiaisSelecionados: [],
    componentes: validacao.componentes, artigosAbordados: validacao.artigosAbordados, artigosEsperados: null,
    contextoSnapshot: {}, tokensEntrada: 1, tokensSaida: 1, auditarEscopoArtigos,
  });
  assert.equal(r.ok, true, r.erro);
  const insercao = capturas.find((c) => c.tabela === "aula_versoes" && c.operacao === "insert");
  // 4) ida e volta por jsonb (o banco devolve JSON, não os mesmos objetos)
  const estruturaDoBanco = JSON.parse(JSON.stringify(insercao.payload.estrutura));
  return { validacao, estruturaDoBanco };
}

// ---------- pipeline ----------

test("Q5-1: parse → validação → ids → persistência preserva o quadrinho integralmente", async () => {
  const original = respostaDaIa();
  const { validacao, estruturaDoBanco } = await percorrerPipeline(original);
  assert.deepEqual(validacao.componentes.map((c) => c.tipo), ["diagnostico", "conceito", "quadrinho_didatico", "recall", "questao_resolvida", "resumo_visual"]);
  const gravado = estruturaDoBanco.componentes[2];
  const { id, ...semId } = gravado;
  assert.match(id, /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/);
  assert.deepEqual(semId, original.componentes[2], "nenhum campo do quadrinho foi removido ou alterado");
  assert.equal(estruturaDoBanco.schema_version, 1);
});

test("Q5-2: id existe SOMENTE no componente — nunca em quadros nem em falas", async () => {
  const { estruturaDoBanco } = await percorrerPipeline(respostaDaIa());
  for (const componente of estruturaDoBanco.componentes) assert.ok(typeof componente.id === "string");
  const q = estruturaDoBanco.componentes[2];
  for (const quadro of q.quadros) {
    assert.ok(!("id" in quadro));
    for (const fala of quadro.falas) assert.ok(!("id" in fala));
  }
  assert.equal(new Set(estruturaDoBanco.componentes.map((c) => c.id)).size, estruturaDoBanco.componentes.length);
});

test("Q5-3: da estrutura gravada saem os MESMOS dados na tela e no PDF (nenhum campo perdido, ordem preservada)", async () => {
  const original = respostaDaIa();
  const { estruturaDoBanco } = await percorrerPipeline(original);
  const web = normalizarQuadrinho(estruturaDoBanco.componentes[2]);
  const pdf = prepararAulaImpressao({ unidadeTitulo: "U", aulaTitulo: "A", numeroVersao: 1, publicadoEm: null, estrutura: estruturaDoBanco })
    .componentes.find((c) => c.tipo === "quadrinho_didatico");
  const esperado = original.componentes[2];

  for (const modelo of [web, pdf]) {
    assert.equal(modelo.titulo, esperado.titulo);
    assert.equal(modelo.fechamento, esperado.fechamento);
    assert.deepEqual(modelo.quadros.map((q) => q.numero), [1, 2, 3]);
    assert.deepEqual(modelo.quadros.map((q) => q.cena), esperado.quadros.map((q) => q.cena));
    assert.deepEqual(modelo.quadros.map((q) => q.falas), esperado.quadros.map((q) => q.falas));
    assert.deepEqual(modelo.quadros.map((q) => q.legenda), esperado.quadros.map((q) => q.legenda ?? null));
  }
  const { tipo, ...pdfSemTipo } = pdf;
  assert.equal(tipo, "quadrinho_didatico");
  // Q12.12: a tela guarda `indiceOriginal` por quadro (chave da arte). Q12.21: o PDF passa a preservar o
  // MESMO indiceOriginal por quadro, além do `id` do componente (que só existe no nível do componente — nunca
  // em quadro/fala, ver Q5-2) — os dois juntos casam a arte aprovada ao quadro certo também na impressão.
  assert.deepEqual(web.quadros.map((q) => q.indiceOriginal), [0, 1, 2], "a tela preserva o índice original do quadro");
  assert.deepEqual(pdf.quadros.map((q) => q.indiceOriginal), [0, 1, 2], "o PDF preserva o MESMO índice original do quadro (Q12.21)");
  assert.equal(pdf.id, estruturaDoBanco.componentes[2].id, "o PDF preserva o id do componente (Q12.21)");
  const { id: pdfId, ...pdfSemId } = pdfSemTipo;
  assert.deepEqual(web, pdfSemId, "tela e PDF derivam exatamente do mesmo conteúdo (o PDF só acrescenta o id do componente)");
  assert.equal(web.quadros[0].falas.length, 2, "quadro com 2 falas");
  assert.equal(web.quadros[1].falas.length, 0, "quadro com falas=[]");
});

test("Q5-4: a ordem dos componentes na tela/PDF é a do array (quadrinho entre conceito e recall)", async () => {
  const { estruturaDoBanco } = await percorrerPipeline(respostaDaIa());
  const modelo = prepararAulaImpressao({ unidadeTitulo: "U", aulaTitulo: "A", numeroVersao: 1, publicadoEm: null, estrutura: estruturaDoBanco });
  assert.deepEqual(modelo.componentes.map((c) => c.tipo), ["diagnostico", "conceito", "quadrinho_didatico", "recall", "questao_resolvida", "resumo_visual"]);
});

test("Q5-5: aula antiga (sem quadrinho) valida, persiste, normaliza e imprime como antes", async () => {
  const antiga = respostaDaIa();
  antiga.componentes.splice(2, 1);
  const { estruturaDoBanco } = await percorrerPipeline(antiga);
  assert.equal(estruturaDoBanco.componentes.length, 5);
  const modelo = prepararAulaImpressao({ unidadeTitulo: "U", aulaTitulo: "A", numeroVersao: 1, publicadoEm: null, estrutura: estruturaDoBanco });
  assert.deepEqual(modelo.componentes.map((c) => c.tipo), ["diagnostico", "conceito", "recall", "questao_resolvida", "resumo_visual"]);
});

test("Q5-6: quadrinho conta no limite global de 40 e o uso previsto (até 3) cabe com folga numa aula densa", () => {
  const densa = respostaDaIa();
  const conceito = densa.componentes[1];
  const quadrinho = densa.componentes[2];
  densa.componentes = [densa.componentes[0]];
  for (let i = 0; i < 12; i += 1) densa.componentes.push({ ...conceito, titulo: `Conceito ${i}` });
  densa.componentes.push(quadrinho, quadrinho, quadrinho);
  densa.componentes.push(respostaDaIa().componentes[3], respostaDaIa().componentes[4], respostaDaIa().componentes[5]);
  assert.equal(densa.componentes.length, 19);
  assert.equal(validarRespostaGerador(densa).ok, true);
  assert.ok(40 - densa.componentes.length >= 20, "margem ampla até o limite global");
});

// ---------- contract drift ----------

function camposDoValidador(nomeConstante) {
  const m = ler("supabase/functions/_shared/gerar-aula/validador.mjs").match(new RegExp(`const ${nomeConstante} = new Set\\(\\[([^\\]]*)\\]\\)`));
  assert.ok(m, nomeConstante);
  return [...m[1].matchAll(/"(\w+)"/g)].map((x) => x[1]);
}

test("Q5-7: contrato campo a campo — validador = prompt = normalização web = modelo do PDF", () => {
  const validador = {
    componente: camposDoValidador("CAMPOS_QUADRINHO"),
    quadro: camposDoValidador("CAMPOS_QUADRO"),
    fala: camposDoValidador("CAMPOS_FALA"),
  };
  assert.deepEqual(validador.componente, ["tipo", "titulo", "quadros", "fechamento"]);
  assert.deepEqual(validador.quadro, ["cena", "falas", "legenda"]);
  assert.deepEqual(validador.fala, ["emissor", "texto"]);

  // prompt: chaves do objeto JSON de exemplo do quadrinho
  const prompt = montarPromptContexto({ concurso: "X", cargo: "Y", banca: "Z", materiaNome: "M", conteudoNome: "C" }, [], [], [], { temMetadata: true, escopoAutorizado: "e", partesIrmasTitulos: [] }, "j");
  const formato = prompt.match(/\{ "tipo": "quadrinho_didatico"[^\n]*?"fechamento": "" \}/)[0];
  const chavesPrompt = new Set([...formato.matchAll(/"(\w+)":/g)].map((x) => x[1]));
  assert.deepEqual([...chavesPrompt].sort(), ["cena", "emissor", "falas", "fechamento", "legenda", "quadros", "texto", "tipo", "titulo"]);
  assert.deepEqual([...chavesPrompt].sort(), [...new Set([...validador.componente, ...validador.quadro, ...validador.fala])].sort());

  // frontend e PDF: cada campo do contrato é efetivamente lido
  const web = ler("components/teoria/tiposComponenteAula.ts");
  const pdf = ler("components/teoria/prepararAulaImpressao.ts");
  for (const [nome, codigo] of [["web", web], ["pdf", pdf]]) {
    for (const campo of ["titulo", "quadros", "fechamento", "cena", "falas", "legenda", "emissor", "texto"]) {
      assert.ok(new RegExp(`\\b${campo}\\b`).test(codigo), `${nome} não lê "${campo}"`);
    }
  }
  assert.match(web, /componente\.quadros/);
  assert.match(web, /componente\.fechamento/);
  assert.match(pdf, /componente\.quadros/);
  assert.match(pdf, /componente\.fechamento/);
});

test("Q5-8: drift de limites — cada limite do validador aparece no texto do prompt", () => {
  const prompt = montarPromptContexto({ concurso: "X", cargo: "Y", banca: "Z", materiaNome: "M", conteudoNome: "C" }, [], [], [], { temMetadata: true, escopoAutorizado: "e", partesIrmasTitulos: [] }, "j");
  assert.deepEqual(QUADRINHO_LIMITES, {
    quadrosMin: 3, quadrosMax: 6, falasPorQuadroMax: 3, tituloMax: 120, cenaMax: 300, emissorMax: 40, falaTextoMax: 140, legendaMax: 160, fechamentoMax: 400,
  });
  for (const valor of [120, 300, 40, 140, 160, 400]) assert.ok(prompt.includes(`até ${valor} caracteres`), `limite ${valor}`);
  assert.ok(prompt.includes("de 3 a 6 quadros"));
  assert.ok(prompt.includes("de 0 a 3 por quadro"));
});

// ---------- grafo de imports / Edge Functions ----------

function importsDe(arquivoAbsoluto) {
  const codigo = readFileSync(arquivoAbsoluto, "utf8");
  return [...codigo.matchAll(/^import\s[^;]*?from\s+"([^"]+)"/gm)].map((m) => m[1]);
}

function resolverLocal(deArquivo, especificador) {
  if (!especificador.startsWith(".")) return null; // esm.sh / npm etc.
  return path.resolve(path.dirname(deArquivo), especificador);
}

function fechamentoTransitivo(inicial) {
  const visitados = new Set();
  const pilha = [inicial];
  while (pilha.length) {
    const atual = pilha.pop();
    if (visitados.has(atual)) continue;
    visitados.add(atual);
    for (const esp of importsDe(atual)) {
      const alvo = resolverLocal(atual, esp);
      if (alvo) {
        assert.ok(existsSync(alvo), `import não resolve: ${esp} em ${path.relative(raiz, atual)}`);
        assert.match(esp, /\.(mjs|ts)$/, `import sem extensão explícita (obrigatória no Deno): ${esp}`);
        pilha.push(alvo);
      }
    }
  }
  return visitados;
}

function temCiclo(inicial) {
  const estado = new Map();
  function visita(no) {
    if (estado.get(no) === 1) return true;
    if (estado.get(no) === 2) return false;
    estado.set(no, 1);
    for (const esp of importsDe(no)) {
      const alvo = resolverLocal(no, esp);
      if (alvo && visita(alvo)) return true;
    }
    estado.set(no, 2);
    return false;
  }
  return visita(inicial);
}

test("Q5-9: openaiResponses.mjs → validador.mjs resolve, tem extensão, export existe e não há ciclo", () => {
  const prompt = path.join(sharedDir, "openaiResponses.mjs");
  const validador = path.join(sharedDir, "validador.mjs");
  assert.deepEqual(importsDe(prompt), ["./validador.mjs"]);
  assert.deepEqual(importsDe(validador), [], "validador.mjs é folha (sem imports)");
  assert.match(readFileSync(validador, "utf8"), /export const QUADRINHO_LIMITES\b/);
  for (const arquivo of readdirSync(sharedDir).filter((f) => f.endsWith(".mjs"))) {
    assert.equal(temCiclo(path.join(sharedDir, arquivo)), false, `ciclo a partir de ${arquivo}`);
  }
});

test("Q5-10: as duas Edge Functions alcançam validador.mjs e openaiResponses.mjs (por isso as duas precisam de redeploy)", () => {
  const gerar = fechamentoTransitivo(path.join(raiz, "supabase/functions/gerar-aula/index.ts"));
  const finalizar = fechamentoTransitivo(path.join(raiz, "supabase/functions/finalizar-geracao-aula/index.ts"));
  const nome = (conjunto) => new Set([...conjunto].map((p) => path.basename(p)));
  assert.ok(nome(gerar).has("openaiResponses.mjs") && nome(gerar).has("validador.mjs"), "gerar-aula alcança validador só via openaiResponses");
  assert.ok(!importsDe(path.join(raiz, "supabase/functions/gerar-aula/index.ts")).some((e) => e.endsWith("validador.mjs")), "gerar-aula NÃO importa o validador diretamente");
  for (const n of ["openaiResponses.mjs", "validador.mjs", "persistirAulaGerada.mjs"]) assert.ok(nome(finalizar).has(n), `finalizar-geracao-aula alcança ${n}`);
  assert.ok(!nome(gerar).has("persistirAulaGerada.mjs"), "só o finalizador persiste");
});

// ---------- segurança e tamanho ----------

test("Q5-11: sem HTML cru, sem imagem/URL/asset — nada do quadrinho vira HTML", () => {
  for (const arquivo of ["components/teoria/ComponenteAulaView.tsx", "components/teoria/AulaImpressao.tsx"]) {
    // só código real: os comentários explicam justamente que NÃO usam HTML cru
    const codigo = ler(arquivo).replace(/^\s*\/\/.*$/gm, "");
    assert.doesNotMatch(codigo, /dangerouslySetInnerHTML|innerHTML|outerHTML|insertAdjacentHTML/, arquivo);
  }
  const web = ler("components/teoria/tiposComponenteAula.ts");
  const pdf = ler("components/teoria/prepararAulaImpressao.ts");
  for (const codigo of [web, pdf]) {
    const trechoQuadrinho = codigo.slice(codigo.search(/normalizar(Quadrinho|Quadros)/));
    assert.doesNotMatch(trechoQuadrinho.replace(/\/\/.*$/gm, ""), /\bimagem\b|\bassetId\b|\bhtml\b|\bhref\b|\bsrc\b/i);
  }
  // renderizarComDestaque só produz texto e <strong>
  assert.match(ler("components/teoria/ComponenteAulaView.tsx"), /indice % 2 === 1 \? <strong key=\{indice\}>\{parte\}<\/strong> : parte/);
});

test("Q5-12: tamanho do prompt — o bloco do quadrinho é uma fração razoável do total", () => {
  const prompt = montarPromptContexto({ concurso: "X", cargo: "Y", banca: "Z", materiaNome: "M", conteudoNome: "C" }, [], [], [], { temMetadata: true, escopoAutorizado: "e", partesIrmasTitulos: [] }, "j");
  const inicio = prompt.indexOf('QUADRINHO DIDÁTICO ("quadrinho_didatico")');
  const fim = prompt.indexOf("Responda SOMENTE em JSON válido");
  const bloco = prompt.slice(inicio, fim).length;
  const extras = bloco + prompt.match(/, \{ "tipo": "quadrinho_didatico"[^\n]*?"fechamento": "" \}/)[0].length;
  console.log(`# prompt total: ${prompt.length} caracteres; bloco do quadrinho: ${bloco}; acréscimo total estimado (bloco + formato): ${extras}`);
  assert.ok(prompt.length < 25000, "prompt cresceu de forma suspeita");
  assert.ok(bloco < 5000, "bloco do quadrinho grande demais");
});
