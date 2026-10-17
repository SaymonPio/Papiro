import assert from "node:assert/strict";
import test from "node:test";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import path from "node:path";

// PAPIRO — Fechamento visual de /estatisticas: (1) "Seu ritmo recente"
// ocupando a linha inteira da grade; (2) rótulos de "Padrões de erro" com
// acentuação correta, via mapping só de apresentação (nunca altera o valor
// canônico agrupado/armazenado). Testes estáticos, sem pixel exato.

const raizProjeto = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const estatisticasPage = readFileSync(path.join(raizProjeto, "app/estatisticas/page.tsx"), "utf8");
const questoesPage = readFileSync(path.join(raizProjeto, "app/questoes/page.tsx"), "utf8");
const globalsCss = readFileSync(path.join(raizProjeto, "app/globals.css"), "utf8");

// ============================================================================
// 1. "Seu ritmo recente" ocupa a linha inteira
// ============================================================================

test("A) .tempo-estudo-compacto-panel ganha grid-column: 1 / -1 SÓ escopado em .central-estatisticas — nunca afeta /meu-estudo", () => {
  const blocoEscopado = globalsCss.match(/\.central-estatisticas \.tempo-estudo-compacto-panel \{[\s\S]*?\}/)?.[0];
  assert.ok(blocoEscopado, "esperava a regra escopada .central-estatisticas .tempo-estudo-compacto-panel");
  assert.match(blocoEscopado, /grid-column:\s*1\s*\/\s*-1/);
});

test("B) a regra .tempo-estudo-compacto-panel original (transition/border-color, sem escopo) não ganhou grid-column — só a nova regra escopada define isso", () => {
  const blocoOriginal = globalsCss.match(/(?<!\.central-estatisticas )\.tempo-estudo-compacto-panel \{[\s\S]*?\}/)?.[0];
  assert.ok(blocoOriginal, "esperava encontrar a regra .tempo-estudo-compacto-panel original (sem escopo)");
  assert.doesNotMatch(blocoOriginal, /grid-column/, "a regra sem escopo não deveria definir grid-column (afetaria /meu-estudo)");
  assert.match(blocoOriginal, /transition:\s*border-color/);
  // só existe UMA ocorrência textual de "grid-column" ligada a este seletor em todo o arquivo, e é a escopada:
  assert.equal((globalsCss.match(/\.tempo-estudo-compacto-panel[\s\S]{0,40}grid-column/g) ?? []).length, 1);
});

test("C) ResumoTempoEstudoCompacto continua usando className=\"stats-panel tempo-estudo-compacto-panel\" — nenhum JSX novo, só CSS", () => {
  const componente = readFileSync(path.join(raizProjeto, "components/tempo-estudo/ResumoTempoEstudoCompacto.tsx"), "utf8");
  assert.match(componente, /className="stats-panel tempo-estudo-compacto-panel"/);
  assert.doesNotMatch(componente, /style=\{\{[^}]*grid-column/i, "largura total deve vir do CSS escopado, não de style inline");
});

// ============================================================================
// 2. Rótulos de "Padrões de erro"
// ============================================================================

test("D) ROTULOS_ERRO_CLASSIFICACAO usa exatamente as 5 chaves canônicas de classificar_erro (nao_sabia/duvida/chute/atencao/interpretacao) + o sentinela local nao_classificado — com acentuação correta", () => {
  const bloco = estatisticasPage.slice(
    estatisticasPage.indexOf("const ROTULOS_ERRO_CLASSIFICACAO"),
    estatisticasPage.indexOf("function rotuloErroClassificacao"),
  );
  const mapaEsperado = {
    nao_sabia: "Não sabia",
    duvida: "Dúvida",
    chute: "Chute",
    atencao: "Atenção",
    interpretacao: "Interpretação",
    nao_classificado: "Não classificado",
  };
  for (const [chave, rotulo] of Object.entries(mapaEsperado)) {
    assert.match(bloco, new RegExp(`${chave}:\\s*"${rotulo}"`), `esperava "${chave}: \\"${rotulo}\\""`);
  }
  // nenhuma chave nova/inventada além dessas 6:
  const chaves = [...bloco.matchAll(/^\s*([a-z_]+):\s*"/gm)].map((m) => m[1]);
  assert.deepEqual(new Set(chaves), new Set(Object.keys(mapaEsperado)));
});

test("E) as 5 chaves canônicas do mapping batem exatamente com CausaErro em app/questoes/page.tsx (classificação de erro não foi alterada em nenhum dos dois arquivos)", () => {
  assert.match(questoesPage, /type CausaErro = "nao_sabia" \| "duvida" \| "chute" \| "atencao" \| "interpretacao";/);
});

test("F) o agrupamento/contagem usa o valor CANÔNICO (erro.tipo_erro bruto, ou o sentinela \"nao_classificado\") como chave do Map — nunca um texto já traduzido/humanizado", () => {
  const linha = estatisticasPage.split("\n").find((l) => l.includes("tipos.set(tipo"));
  assert.ok(linha, "esperava encontrar a linha de agrupamento por tipo de erro");
  assert.match(linha, /const tipo = erro\.tipo_erro \?\? "nao_classificado";/);
  assert.doesNotMatch(linha, /replaceAll/, "agrupamento não deve mais depender de transformação de texto (replaceAll) — só o valor canônico");
});

test("G) a renderização aplica rotuloErroClassificacao(erro.tipo) — exibição traduzida, sem mudar o que é contado/agrupado", () => {
  assert.match(estatisticasPage, /<span>\{rotuloErroClassificacao\(erro\.tipo\)\}<\/span>/);
});

test("H) nenhuma lógica de classificação/RPC/filtro/consulta foi tocada — estatisticas_do_curso_ativo e o resto dos cards continuam intocados", () => {
  assert.match(estatisticasPage, /supabase\.rpc\("estatisticas_do_curso_ativo"\)/);
  for (const termo of ["stats-summary", "performance-panel", "consistency-panel", "reviews-panel", "metric-track"]) {
    assert.match(estatisticasPage, new RegExp(termo), `${termo} deveria continuar presente e intocado`);
  }
});
