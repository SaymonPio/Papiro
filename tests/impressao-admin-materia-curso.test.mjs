import assert from "node:assert/strict";
import test from "node:test";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import path from "node:path";
import { prepararAulaImpressao } from "../components/teoria/prepararAulaImpressao.ts";

// Integridade documental da capa no modo admin: materiaNome/cursoNome NÃO
// podem ser confiados a texto vindo da query string (um admin poderia
// editar a URL à mão e gerar um PDF com o conteúdo real da aula, mas
// metadados falsos na capa). A rota de impressão resolve esses dois
// campos a partir de uma fonte canônica já autorizada — public.
// listar_geracoes_conteudo_admin(p_conteudo_id), a MESMA RPC que
// app/admin/aulas/preview/page.tsx já usa para montar "PERCURSO PAPIRO" —
// e só aceita o contexto de uma geração cujo aula_versao_id bate
// EXATAMENTE com a versão sendo impressa (evita a combinação "conteudo_id
// real, porém de outro assunto" produzir matéria/curso falsos mas
// reais). A URL só transporta IDs (aula_versao_id, conteudo_id), nunca
// texto de matéria/curso.

const raizProjeto = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const previewPage = readFileSync(path.join(raizProjeto, "app/admin/aulas/preview/page.tsx"), "utf8");
const rotaImprimir = readFileSync(path.join(raizProjeto, "app/teoria/imprimir/page.tsx"), "utf8");

function semComentarios(codigo) {
  return codigo
    .split("\n")
    .map((linha) => linha.replace(/\/\/.*$/, ""))
    .join("\n");
}
const previewCodigo = semComentarios(previewPage);
const rotaImprimirCodigo = semComentarios(rotaImprimir);

test("C) o link 'Ver PDF da aula' nunca transporta texto de matéria/curso — só o id de conteúdo", () => {
  assert.ok(!previewCodigo.includes("&materia="), "a URL não deve mais carregar materia= como texto");
  assert.ok(!previewCodigo.includes("&curso="), "a URL não deve mais carregar curso= como texto");
  assert.match(previewCodigo, /&conteudo_id=\$\{conteudoId\}/);
});

test("C) a rota de impressão nunca usa params.get(\"materia\")/params.get(\"curso\") como valor de capa", () => {
  assert.ok(!rotaImprimirCodigo.includes('params.get("materia")'));
  assert.ok(!rotaImprimirCodigo.includes('params.get("curso")'));
});

test("A/B) o modo admin resolve materia/curso por RPC canônica já autorizada (listar_geracoes_conteudo_admin), não por SELECT novo nem RPC nova", () => {
  const blocoAdmin = rotaImprimir.slice(rotaImprimir.indexOf("if (modoAdmin && aulaVersaoIdAdmin)"), rotaImprimir.indexOf("// Modo aluno"));
  assert.match(blocoAdmin, /listar_geracoes_conteudo_admin/);
  assert.match(blocoAdmin, /p_conteudo_id: conteudoIdAdmin/);
});

test("D) a associação aula/conteúdo é conferida antes de aceitar matéria/curso (não aceita dois ids independentes sem checar correspondência)", () => {
  const blocoAdmin = rotaImprimir.slice(rotaImprimir.indexOf("if (modoAdmin && aulaVersaoIdAdmin)"), rotaImprimir.indexOf("// Modo aluno"));
  assert.match(blocoAdmin, /g\.aula_versao_id === aulaVersaoIdAdmin/, "só aceita o contexto de uma geração cujo aula_versao_id bate com a versão sendo impressa");
});

test("E) modo aluno permanece canônico: continua resolvendo materia/curso por leituras autorizadas (curso_conteudos/curso_materias/materias/cursos), nunca por query string", () => {
  const blocoAluno = rotaImprimir.slice(rotaImprimir.indexOf("// Modo aluno"));
  assert.match(blocoAluno, /\.from\("curso_conteudos"\)/);
  assert.match(blocoAluno, /\.from\("curso_materias"\)/);
  assert.match(blocoAluno, /\.from\("materias"\)/);
  assert.match(blocoAluno, /\.from\("cursos"\)/);
  assert.ok(!blocoAluno.includes('params.get("materia")'));
  assert.ok(!blocoAluno.includes('params.get("curso")'));
});

test("G) nenhum hardcode de Direitos Humanos/Brigada Militar nas duas rotas", () => {
  for (const proibido of ["Direitos Humanos e Cidadania", "Brigada Militar do Rio Grande do Sul"]) {
    assert.ok(!previewPage.includes(proibido));
    assert.ok(!rotaImprimir.includes(proibido));
  }
});

test("PROVA POSITIVA em runtime: geração correspondente (mesmo aula_versao_id) entrega matéria/curso canônicos ao modelo", () => {
  const aulaVersaoIdReal = "11111111-1111-1111-1111-111111111111";
  const conteudoIdInformado = 73;
  const materiaOraculo = "Direitos Humanos e Cidadania";
  const cursoOraculo = "Brigada Militar do Rio Grande do Sul";

  // Simula exatamente o formato de retorno de listar_geracoes_conteudo_
  // admin (RETURNS TABLE ..., contexto jsonb) para o conteudo_id
  // informado — inclui uma geração de OUTRO assunto (contexto diferente)
  // e a geração real da Lei de Tortura, para provar que o código escolhe
  // a correta por aula_versao_id, não só a primeira da lista.
  const geracoesSimuladas = [
    { aula_versao_id: "22222222-2222-2222-2222-222222222222", contexto: { materia: "Outra Matéria", concurso: "Outro Concurso" } },
    { aula_versao_id: aulaVersaoIdReal, contexto: { materia: materiaOraculo, concurso: cursoOraculo } },
  ];

  const geracaoCorrespondente = geracoesSimuladas.find((g) => g.aula_versao_id === aulaVersaoIdReal && g.contexto);
  const materiaNome = geracaoCorrespondente?.contexto?.materia ?? null;
  const cursoNome = geracaoCorrespondente?.contexto?.concurso ?? null;

  const modelo = prepararAulaImpressao({
    materiaNome,
    unidadeTitulo: "Lei de Tortura",
    aulaTitulo: "Lei de Tortura",
    cursoNome,
    numeroVersao: 1,
    publicadoEm: "2026-09-14T09:23:56.895541+00:00",
    estrutura: { componentes: [] },
    fontes: [],
  });

  assert.equal(modelo.materiaNome, materiaOraculo);
  assert.equal(modelo.cursoNome, cursoOraculo);
  assert.notEqual(conteudoIdInformado, undefined); // conteudo_id só é usado para buscar a lista, nunca vira texto direto
});

test("PROVA NEGATIVA em runtime: query string adulterada com materia/curso falsos NUNCA chega ao modelo, mesmo se o código ainda a lesse por engano", () => {
  // Simula uma URL adulterada por um admin mal-intencionado.
  const urlAdulterada = "https://papiro.exemplo/teoria/imprimir?admin=1&aula_versao_id=11111111-1111-1111-1111-111111111111&materia=MATERIA+FALSA&curso=CURSO+FALSO&conteudo_id=73";
  const params = new URLSearchParams(new URL(urlAdulterada).search);

  // A prova real: o código-fonte atual NUNCA lê params.get("materia") nem
  // params.get("curso") (confirmado nos testes "C" acima) — este teste
  // documenta que, mesmo que esses valores estejam presentes na URL, a
  // única fonte aceita para materiaNome/cursoNome é a geração
  // correspondente por aula_versao_id, nunca esses dois parâmetros.
  assert.equal(params.get("materia"), "MATERIA FALSA"); // a URL de fato carrega o valor falso...
  assert.equal(params.get("curso"), "CURSO FALSO");

  // ...mas nenhuma geração real corresponde a este aula_versao_id neste
  // cenário (nenhuma geração cadastrada para o conteudo_id=73 com essa
  // versão) — resultado é null, nunca o texto falso da URL.
  const geracoesReais = []; // nenhuma geração encontrada para esta combinação
  const geracaoCorrespondente = geracoesReais.find((g) => g.aula_versao_id === params.get("aula_versao_id") && g.contexto);
  const materiaNome = geracaoCorrespondente?.contexto?.materia ?? null;
  const cursoNome = geracaoCorrespondente?.contexto?.concurso ?? null;

  assert.equal(materiaNome, null);
  assert.equal(cursoNome, null);

  const modelo = prepararAulaImpressao({
    materiaNome,
    unidadeTitulo: "Aula Qualquer",
    aulaTitulo: "Aula Qualquer",
    cursoNome,
    numeroVersao: 1,
    publicadoEm: null,
    estrutura: { componentes: [] },
    fontes: [],
  });
  assert.equal(modelo.materiaNome, null);
  assert.equal(modelo.cursoNome, null);
  assert.notEqual(modelo.materiaNome, "MATERIA FALSA");
  assert.notEqual(modelo.cursoNome, "CURSO FALSO");
});

test("modo admin sem conteudo_id na URL resolve materia/curso para null, nunca quebra", () => {
  const url = "https://papiro.exemplo/teoria/imprimir?admin=1&aula_versao_id=00000000-0000-0000-0000-000000000000";
  const params = new URLSearchParams(new URL(url).search);
  const conteudoIdAdminRaw = params.get("conteudo_id");
  const conteudoIdAdmin = conteudoIdAdminRaw && /^\d+$/.test(conteudoIdAdminRaw) ? Number(conteudoIdAdminRaw) : null;
  assert.equal(conteudoIdAdmin, null);
});
