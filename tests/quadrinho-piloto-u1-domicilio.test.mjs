import assert from "node:assert/strict";
import test from "node:test";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import path from "node:path";
import { validarRespostaGerador, QUADRINHO_LIMITES } from "../supabase/functions/_shared/gerar-aula/validador.mjs";
import { normalizarQuadrinho } from "../components/teoria/tiposComponenteAula.ts";
import { prepararAulaImpressao } from "../components/teoria/prepararAulaImpressao.ts";

// Piloto manual do quadrinho_didatico (U1 DGF / inviolabilidade do
// domicílio). Estes testes NÃO tocam o banco: validam o JSON do piloto
// embutido nos arquivos SQL preparados e a estrutura segura dos scripts.

const raiz = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const ler = (r) => readFileSync(path.join(raiz, r), "utf8");
const patch = ler("supabase/adicionar_quadrinho_piloto_dgf_u1_domicilio.sql");
const harness = ler("supabase/adicionar_quadrinho_piloto_dgf_u1_domicilio_teste_rollback.sql");

const UUID = "1f4065f2-8fda-4f7d-8826-45955230678d";
const AULA_VERSAO = "52756262-8be4-4fb2-a9f3-2f5a158ea1d4";
const ALVO = "f0614831-dbff-4c68-b7f9-b3d31425adb4";
const PROXIMO = "2b13bd2d-8042-4575-aefe-998b3f1f7b07";

function extrairQuadrinho(sql) {
  const m = sql.match(/\$QUADRINHO\$\s*([\s\S]*?)\s*\$QUADRINHO\$::jsonb/);
  assert.ok(m, "bloco $QUADRINHO$ não encontrado");
  return JSON.parse(m[1]);
}

const q = extrairQuadrinho(patch);

function semComentarios(sql) {
  return sql.split("\n").filter((l) => !/^\s*--/.test(l)).join("\n");
}

test("P1: o mesmo quadrinho (UUID fixo) está no patch e no harness", () => {
  assert.deepEqual(extrairQuadrinho(harness), q);
  assert.equal(q.id, UUID);
  assert.equal(q.tipo, "quadrinho_didatico");
  for (const sql of [patch, harness]) {
    assert.ok(sql.includes(UUID));
    assert.ok(sql.includes(AULA_VERSAO));
    assert.ok(sql.includes(ALVO));
    assert.ok(sql.includes(PROXIMO));
    assert.ok(sql.includes("e0559b2ef5b015bb2b2cbb9c8da2b1bc"), "hash baseline auditado");
  }
});

test("P2: o JSON do piloto cumpre o contrato V1 pelo validador REAL (sem o id, que é do servidor)", () => {
  const { id, ...semId } = q;
  const dados = {
    artigos_abordados: ["art. 5º, XI"],
    componentes: [
      { tipo: "diagnostico", titulo: "d", introducao: "i", pergunta: "p", resposta_esperada: "r" },
      { tipo: "conceito", titulo: "Inviolabilidade do domicílio", explicacao: "A casa é asilo inviolável e a regra é o consentimento do morador.", exemplo: null, ponto_de_prova: null, pegadinha: null },
      semId,
      { tipo: "recall", titulo: "r", pergunta: "p", resposta: "resposta completa do recall" },
      { tipo: "questao_resolvida", enunciado: "e", alternativas: [{ letra: "A", texto: "a" }, { letra: "B", texto: "b" }, { letra: "C", texto: "c" }, { letra: "D", texto: "d" }], gabarito: "A", raciocinio: "porque sim, com texto suficiente", pegadinha: null },
      { tipo: "resumo_visual", titulo: "r", pontos: ["ponto um relevante", "ponto dois relevante"] },
    ],
  };
  const r = validarRespostaGerador(dados);
  assert.equal(r.ok, true, r.erro);
  // e, como componente persistido, o id do piloto NÃO seria aceito vindo da IA:
  dados.componentes[2] = q;
  assert.equal(validarRespostaGerador(dados).ok, false);
});

test("P3: limites V1 respeitados e nenhum campo reservado", () => {
  const L = QUADRINHO_LIMITES;
  assert.deepEqual(Object.keys(q).sort(), ["fechamento", "id", "quadros", "tipo", "titulo"]);
  assert.ok(q.titulo.length <= L.tituloMax);
  assert.equal(q.quadros.length, 4);
  assert.ok(q.fechamento.length <= L.fechamentoMax);
  for (const quadro of q.quadros) {
    assert.ok(Object.keys(quadro).every((k) => ["cena", "falas", "legenda"].includes(k)));
    assert.ok(quadro.cena.length <= L.cenaMax);
    assert.ok(quadro.falas.length <= L.falasPorQuadroMax);
    if ("legenda" in quadro) assert.ok(quadro.legenda.length <= L.legendaMax && quadro.legenda.trim().length > 0);
    for (const fala of quadro.falas) {
      assert.deepEqual(Object.keys(fala).sort(), ["emissor", "texto"]);
      assert.ok(fala.emissor.length <= L.emissorMax && fala.texto.length <= L.falaTextoMax);
    }
  }
  assert.doesNotMatch(JSON.stringify(q), /"(imagem|alt|asset_id|asset|url|html|fundamento|objetivo_pedagogico|ordem)"/);
  assert.doesNotMatch(JSON.stringify(q), /<[a-z/]/i);
});

test("P4: roteiro — cada quadro cumpre o papel pedagógico e o fechamento tem a regra completa", () => {
  const [q1, q2, q3, q4] = q.quadros;
  assert.match(q1.cena, /Noite/);
  assert.match(q1.cena, /pedido claro de socorro/);
  assert.match(q2.cena, /mandado/);
  assert.match(q2.cena, /noite/);
  assert.match(q3.cena, /prestar socorro/);
  assert.match(q3.legenda, /independentemente do horário/);
  assert.match(q4.cena, /ordem judicial/);
  assert.match(q4.cena, /à noite/);
  assert.match(q4.cena, /sem flagrante, desastre ou pedido de socorro/);
  assert.match(q4.falas.map((f) => f.texto).join(" "), /aguardar o período diurno/);
  for (const termo of ["Flagrante", "desastre", "socorro", "independentemente do horário", "determinação judicial", "durante o dia"]) {
    assert.ok(q.fechamento.includes(termo), termo);
  }
});

test("P5: conteúdo limitado ao art. 5º, XI — sem jurisprudência nem temas fora do conceito", () => {
  const tudo = JSON.stringify(q).toLowerCase();
  for (const proibido of [/\bstf\b/, /\bstj\b/, /súmula|sumula/, /jurisprudência/, /delegado/, /prova ilícita|prova ilicita/, /\bprazo\b/, /autorização posterior/, /conceito de casa/, /\bhc\b/, /\bre\b/, /\barex?\b/]) {
    assert.doesNotMatch(tudo, proibido, `não deveria citar: ${proibido}`);
  }
});

test("P6: situação original — não copia enunciados/expressões das questões de prática conhecidas", () => {
  const tudo = JSON.stringify(q);
  for (const copiado of [
    "Um policial civil está trabalhando", "gritos de socorro vindos do interior", "Ouvi gritos de socorro",
    "Mera suspeita", "Curiosidade administrativa", "guarda municipal", "após às 21h", "a casa está sendo inundada",
    "Flagrante delito.", "Ordem verbal de qualquer servidor",
  ]) {
    assert.ok(!tudo.includes(copiado), `cópia de questão: ${copiado}`);
  }
});

test("P7: tela e PDF recebem o piloto sem perder nada, na posição certa", () => {
  const web = normalizarQuadrinho(q);
  assert.equal(web.quadros.length, 4);
  assert.deepEqual(web.quadros.map((x) => x.numero), [1, 2, 3, 4]);
  assert.deepEqual(web.quadros.map((x) => x.legenda), [null, null, q.quadros[2].legenda, q.quadros[3].legenda]);
  const estrutura = { componentes: [
    { id: ALVO, tipo: "conceito", titulo: "Inviolabilidade do domicílio", explicacao: "x" },
    q,
    { id: PROXIMO, tipo: "conceito", titulo: "Sigilo de correspondência e comunicações", explicacao: "y" },
  ] };
  const pdf = prepararAulaImpressao({ unidadeTitulo: "U", aulaTitulo: "A", numeroVersao: 1, publicadoEm: null, estrutura });
  assert.deepEqual(pdf.componentes.map((c) => c.tipo), ["conceito", "quadrinho_didatico", "conceito"]);
  const pdfQ = pdf.componentes[1];

  // 1) Conteúdo PEDAGÓGICO idêntico entre tela e PDF — título, cena, falas, legenda e fechamento — nenhuma
  // palavra se perde na impressão. Comparado campo a campo (não por deepEqual do objeto inteiro), porque a
  // partir da Q12.21 o PDF passa a carregar dois campos A MAIS que a tela não expõe da mesma forma (ver 2).
  assert.equal(pdfQ.titulo, web.titulo);
  assert.equal(pdfQ.fechamento, web.fechamento);
  assert.deepEqual(pdfQ.quadros.map((x) => x.numero), web.quadros.map((x) => x.numero));
  assert.deepEqual(pdfQ.quadros.map((x) => x.cena), web.quadros.map((x) => x.cena));
  assert.deepEqual(pdfQ.quadros.map((x) => x.falas), web.quadros.map((x) => x.falas));
  assert.deepEqual(pdfQ.quadros.map((x) => x.legenda), web.quadros.map((x) => x.legenda));

  // 2) Q12.21: o PDF passa a preservar ADICIONALMENTE o id do componente e o indiceOriginal de cada quadro
  // — não é perda de conteúdo, é o dado extra necessário para casar a arte aprovada (Storage) com o quadro
  // certo na impressão (chaveArte(id, indiceOriginal)). A tela já guardava indiceOriginal desde a Q12.12;
  // agora o PDF guarda os dois, sem substituir nem remover nenhum campo pedagógico por causa disso.
  assert.deepEqual(web.quadros.map((x) => x.indiceOriginal), [0, 1, 2, 3]);
  assert.deepEqual(pdfQ.quadros.map((x) => x.indiceOriginal), [0, 1, 2, 3]);

  // 3) Validação explícita contra os IDs reais do piloto (LIVE confirmado na Q13.5): o id do componente no
  // PDF é exatamente o UUID fixo do quadrinho — a mesma chave que assinar-quadrinho-assets usa para casar
  // este componente com suas 4 artes aprovadas.
  assert.equal(pdfQ.id, UUID);
});

// ---------- segurança dos scripts ----------

test("P8: harness — BEGIN no início, ROLLBACK como última instrução, nenhum COMMIT, sem SAVEPOINT nem DDL", () => {
  const codigo = semComentarios(harness).trim();
  assert.match(codigo, /^begin;/i);
  assert.match(codigo, /rollback;\s*$/i);
  assert.doesNotMatch(codigo, /(^|\n)\s*commit\s*;/i);
  assert.doesNotMatch(codigo, /\bsavepoint\b/i);
  assert.doesNotMatch(codigo, /\b(create|alter|drop|truncate)\s+(?!temporary table _)(table|function|index|trigger|policy)/i);
  for (const passo of ["_snapshot_old_quadrinho_piloto", "PRECONDICOES", "APPLY", "POSCONDICOES", "REVERT", "OLD_FINAL"]) {
    assert.ok(harness.includes(passo), passo);
  }
  assert.ok(harness.indexOf("-- ================= REVERT") > harness.indexOf("-- ================= POSCONDICOES"));
  assert.ok(harness.indexOf("-- ================= OLD_FINAL") > harness.indexOf("-- ================= REVERT"));
});

test("P9: patch real — termina em COMMIT, mesmo corpo do harness até as pós-condições, só toca aula_versoes", () => {
  const codigo = semComentarios(patch).trim();
  assert.match(codigo, /^begin;/i);
  assert.match(codigo, /commit;\s*$/i);
  const corpoPatch = codigo.replace(/\s*commit;\s*$/i, "").trim();
  const corpoHarness = semComentarios(harness).split("update public.aula_versoes av\nset estrutura = t.estrutura")[0].trim();
  assert.equal(corpoPatch, corpoHarness, "patch e harness devem compartilhar exatamente o mesmo corpo");
  for (const proibido of [/insert\s+into/i, /delete\s+from/i, /update\s+public\.(?!aula_versoes)/i, /public\.aulas\s+set/i, /status\s*=\s*'publicada'/i]) {
    assert.doesNotMatch(codigo, proibido);
  }
});

test("P10: proteção contra reexecução e checagens de posição/isolamento presentes", () => {
  for (const trecho of [
    "esperado 14 componentes", "hash da estrutura diverge do baseline", "ja existe quadrinho_didatico", "UUID fixo do piloto ja existe",
    "esperado exatamente 1 conceito alvo", "posicao 5 (indice 4)", "componente seguinte ao alvo divergiu",
    "esperado exatamente 1 linha atualizada", "esperado 15 componentes", "esperado exatamente 1 quadrinho_didatico",
    "os 14 componentes originais nao estao identicos", "outras aula_versoes mudaram", "total de aulas mudou", "total de aula_versoes mudou",
    "artigos_abordados deveria continuar com 16",
  ]) {
    assert.ok(patch.includes(trecho), `patch sem: ${trecho}`);
  }
  assert.match(patch, /status <> 'rascunho'/);
  assert.match(patch, /numero_versao esperado 1/);
});

// ---------- Q6.3b: verificação do fechamento sem diferenciar maiúsculas ----------

// Extrai, do SQL, os termos exigidos e as DUAS expressões comparadas pelo
// check do fechamento — assim o teste olha a estrutura da comparação, não
// uma string solta.
function checkDoFechamento(sql) {
  const codigo = semComentarios(sql);
  const termos = codigo.match(/foreach\s+v_texto_total\s+in\s+array\s+array\[([^\]]*)\]\s+loop/i);
  assert.ok(termos, "laço de termos do fechamento não encontrado");
  const comparacao = codigo.match(/if\s+position\((.+?)\s+in\s+(.+?)\)\s*=\s*0\s+then\s+raise\s+exception\s+'POSCOND: fechamento sem/i);
  assert.ok(comparacao, "comparação do fechamento não encontrada");
  return {
    termos: [...termos[1].matchAll(/'([^']+)'/g)].map((m) => m[1]),
    agulha: comparacao[1].trim(),
    palheiro: comparacao[2].trim(),
  };
}

test("P11: o check do fechamento é case-insensitive nos dois lados, igual no patch e no harness", () => {
  const p = checkDoFechamento(patch);
  const h = checkDoFechamento(harness);
  assert.deepEqual(p, h, "patch e harness com a MESMA correção");
  assert.match(p.agulha, /^lower\(v_texto_total\)$/);
  assert.match(p.palheiro, /^lower\(\(?v_quadrinho->>'fechamento'\)?\)$/);
});

test("P12: os seis termos continuam exigidos e o fechamento os satisfaz ignorando caixa", () => {
  const { termos } = checkDoFechamento(patch);
  assert.deepEqual(termos, ["flagrante", "desastre", "socorro", "independentemente do horário", "determinação judicial", "durante o dia"]);
  const fechamento = q.fechamento;
  for (const termo of termos) assert.ok(fechamento.toLowerCase().includes(termo.toLowerCase()), termo);
  // o conteúdo traz "Flagrante delito" com F maiúsculo, o caso que quebrou o rollback-test
  assert.match(fechamento, /Flagrante delito/);
  assert.ok(fechamento.toLowerCase().includes("flagrante delito"));
});

test("P13: uma comparação puramente case-sensitive NÃO passa neste teste (regressão do bug anterior)", () => {
  const { termos } = checkDoFechamento(patch);
  const semCaixa = (agulha, palheiro) => palheiro.toLowerCase().includes(agulha.toLowerCase());
  const comCaixa = (agulha, palheiro) => palheiro.includes(agulha);
  assert.ok(termos.every((t) => semCaixa(t, q.fechamento)));
  assert.equal(termos.every((t) => comCaixa(t, q.fechamento)), false, "a versão antiga (case-sensitive) reprovaria o conteúdo real");
  // e o próprio SQL não pode voltar a comparar sem lower() em algum dos lados
  for (const sql of [patch, harness]) {
    assert.doesNotMatch(semComentarios(sql), /position\(v_texto_total\s+in\s+\(?v_quadrinho->>'fechamento'\)?\)/);
  }
});
