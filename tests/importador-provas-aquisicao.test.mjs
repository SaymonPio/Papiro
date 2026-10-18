import assert from "node:assert/strict";
import test from "node:test";
import { hashManifesto, planejarAquisicao } from "../scripts/importador-provas/lib/aquisicao/planejar.mjs";
import { ErroAquisicao, executarAquisicao, montarRelatorioAquisicao } from "../scripts/importador-provas/lib/aquisicao/executor.mjs";

// PAPIRO — executor controlado de aquisição. Fixture 100% sintética:
// um repositório em memória com a mesma interface de repositorioPg.mjs,
// as mesmas constraints relevantes (hash_prova UNIQUE, (prova_id,
// numero_original) UNIQUE) e transação real (snapshot/restauração).

const HASH_PROVA = "a".repeat(64);
const HASH_GABARITO = "b".repeat(64);
const PORTUGUES = 6;
const MATEMATICA = 12;
const HISTORIA = 20;
const ASSUNTO_CRASE = 100;
const ASSUNTO_PORCENTAGEM = 200;
const CURSO_BM = "11111111-1111-1111-1111-111111111111";

function criarRepositorioMemoria({ falharNaQuestao = null } = {}) {
  const banco = {
    provas: [],
    prova_documentos: [],
    questoes: [],
    alternativas: [],
    curso_questoes: [],
    cursos: [{ id: CURSO_BM, slug: "brigada-militar-rs" }],
    curso_materias: [
      { curso_id: CURSO_BM, materia_id: PORTUGUES, nome: "Língua Portuguesa", peso: 20 },
      { curso_id: CURSO_BM, materia_id: MATEMATICA, nome: "Matemática", peso: 15 },
    ],
    curso_conteudos: [{ id: 1 }],
    materias: [
      { id: PORTUGUES, nome: "Língua Portuguesa", ativo: true },
      { id: MATEMATICA, nome: "Matemática", ativo: true },
      { id: HISTORIA, nome: "História", ativo: true },
    ],
    assuntos: [
      { id: ASSUNTO_CRASE, materia_id: PORTUGUES, nome: "Crase" },
      { id: ASSUNTO_PORCENTAGEM, materia_id: MATEMATICA, nome: "Porcentagem" },
    ],
  };
  let snapshot = null;
  let somenteLeitura = false;
  let insercoesDeQuestao = 0;
  const sequencial = { provas: 1, questoes: 1000 };
  const exigirEscrita = () => {
    if (!snapshot) throw new Error("fora de transação");
    if (somenteLeitura) throw new Error("cannot execute INSERT in a read-only transaction");
  };

  const repo = {
    banco,
    async iniciar(opcoes) {
      snapshot = structuredClone(banco);
      somenteLeitura = opcoes.somenteLeitura;
    },
    async confirmar() {
      snapshot = null;
    },
    async desfazer() {
      if (!snapshot) return;
      for (const chave of Object.keys(banco)) banco[chave] = snapshot[chave];
      snapshot = null;
    },
    async lerContexto({ hashProva, chaveNatural, slugsCursos, alternativas }) {
      const n = (v) => String(v ?? "").trim().toLowerCase();
      const porHash = banco.provas.find((p) => p.hash_prova === hashProva) ?? null;
      const porChave =
        banco.provas.find((p) => ["banca", "orgao", "cargo", "nome"].every((c) => n(p[c]) === n(chaveNatural[c])) && p.ano === chaveNatural.ano) ?? null;
      return {
        provaPorHash: porHash,
        provaPorChaveNatural: porChave,
        numerosJaImportados: new Map(banco.questoes.filter((q) => porHash && q.prova_id === porHash.id).map((q) => [q.numero_original, q.id])),
        documentosDaProva: porHash ? banco.prova_documentos.filter((d) => d.prova_id === porHash.id) : [],
        questoesGlobais: banco.questoes
          .filter((q) => q.usuario_id === null && (!porHash || q.prova_id !== porHash.id))
          .map((q) => ({ id: q.id, enunciado: q.enunciado, alternativas: banco.alternativas.filter((a) => a.questao_id === q.id).map((a) => ({ texto: a.texto })) })),
        materias: new Map(banco.materias.map((m) => [m.id, m])),
        assuntos: new Map(banco.assuntos.map((a) => [a.id, a])),
        sequenciaEmbutida: new Set(alternativas.filter((a) => /a\).*?b\).*?c\).*?d\)/i.test(a.texto)).map((a) => `${a.numero}:${a.letra}`)),
        cursos: banco.cursos
          .filter((c) => slugsCursos.includes(c.slug))
          .map((c) => ({
            id: c.id,
            slug: c.slug,
            materias: banco.curso_materias
              .filter((cm) => cm.curso_id === c.id)
              .map((cm) => ({ materia_id: cm.materia_id, nome_curso: cm.nome, nome_materia: banco.materias.find((m) => m.id === cm.materia_id).nome })),
          })),
      };
    },
    async inserirProva(prova) {
      exigirEscrita();
      if (banco.provas.some((p) => p.hash_prova === prova.hash_prova)) throw new Error("duplicate key provas_hash_prova_key");
      const id = sequencial.provas++;
      banco.provas.push({ ...prova, id });
      return id;
    },
    // Mesmas constraints de prova_documentos: (prova_id, tipo, ordem) e
    // (prova_id, hash_sha256) UNIQUE, hash obrigatório.
    async inserirDocumento(provaId, d) {
      exigirEscrita();
      if (!/^[0-9a-f]{64}$/.test(d.hash_sha256 ?? "")) throw new Error("check prova_documentos_hash_sha256_check");
      if (banco.prova_documentos.some((x) => x.prova_id === provaId && x.tipo === d.tipo && x.ordem === d.ordem)) throw new Error("duplicate key prova_documentos_posicao_key");
      if (banco.prova_documentos.some((x) => x.prova_id === provaId && x.hash_sha256 === d.hash_sha256)) throw new Error("duplicate key prova_documentos_hash_key");
      banco.prova_documentos.push({ prova_id: provaId, tipo: d.tipo, ordem: d.ordem, url: d.url, hash_sha256: d.hash_sha256 });
    },
    async inserirQuestao(q) {
      exigirEscrita();
      insercoesDeQuestao++;
      if (falharNaQuestao !== null && insercoesDeQuestao === falharNaQuestao) throw new Error("falha simulada no meio do lote");
      if (banco.questoes.some((x) => x.prova_id === q.prova_id && x.numero_original === q.numero_original)) throw new Error("duplicate key questoes_prova_numero_key");
      const id = sequencial.questoes++;
      banco.questoes.push({ ...q, id, usuario_id: null, ativa: true });
      return id;
    },
    async inserirAlternativas(questaoId, alternativas) {
      exigirEscrita();
      for (const a of alternativas) banco.alternativas.push({ ...a, questao_id: questaoId });
    },
    async inserirVinculo(cursoId, questaoId) {
      exigirEscrita();
      banco.curso_questoes.push({ curso_id: cursoId, questao_id: questaoId });
    },
    async lerEstadoPosCheck({ provaId, questaoIds }) {
      return {
        prova: banco.provas.find((p) => p.id === provaId) ?? null,
        documentos: banco.prova_documentos.filter((d) => d.prova_id === provaId),
        questoesDaProva: banco.questoes
          .filter((q) => q.prova_id === provaId)
          .map((q) => ({ ...q, alternativas: banco.alternativas.filter((a) => a.questao_id === q.id) })),
        vinculos: banco.curso_questoes.filter((v) => questaoIds.includes(v.questao_id)),
      };
    },
    async contagensMutaveis() {
      return { provas: banco.provas.length, prova_documentos: banco.prova_documentos.length, questoes: banco.questoes.length, alternativas: banco.alternativas.length, curso_questoes: banco.curso_questoes.length };
    },
    async contagensEstruturais() {
      return {
        cursos: banco.cursos.length,
        curso_materias: banco.curso_materias.length,
        curso_conteudos: banco.curso_conteudos.length,
        pesos_curso_materias: String(banco.curso_materias.reduce((s, cm) => s + cm.peso, 0)),
        materias: banco.materias.length,
        assuntos: banco.assuntos.length,
      };
    },
  };
  return repo;
}

function questaoStaging(numero, { materia = PORTUGUES, assunto = ASSUNTO_CRASE, confidence = "alta", anulada = false, etapas = {}, enunciado, alternativas } = {}) {
  return {
    numero_original: numero,
    enunciado: enunciado ?? `Enunciado sintético exclusivo número ${numero} sobre tema ${numero * 7} completamente distinto`,
    alternativas: alternativas ?? ["A", "B", "C", "D", "E"].map((letra) => ({ letra, texto: `opção ${letra} da questão ${numero} item${numero}${letra}`, correta: !anulada && letra === "B" })),
    materia_sugerida: materia,
    assunto_sugerido: assunto,
    confidence,
    etapas: { EXTRACAO_OK: true, GABARITO_OK: true, CLASSIFICACAO_OK: confidence === "alta", DEDUP_OK: true, PROVENIENCIA_OK: true, ...etapas },
    _interno: { gabarito_anulado: anulada },
  };
}

function proveniencia(overrides = {}) {
  return {
    completa: true,
    faltando: [],
    invalidos: [],
    prova: {
      banca: "Fundatec",
      orgao: "Brigada Militar RS (fictícia)",
      cargo: "Soldado",
      ano: 2099,
      nome: "Prova sintética BM 2099",
      fonte_url: "https://exemplo.org/prova.pdf",
      gabarito_url: "https://exemplo.org/gabarito.pdf",
      hash_prova: HASH_PROVA,
      hash_gabarito: HASH_GABARITO,
      ...overrides,
    },
  };
}

function entradaBase(questoes, extras = {}) {
  return { modo: "BASE_GLOBAL", proveniencia: proveniencia(), questoes, aprovacao: {}, ...extras };
}

async function dryRunEApply(repo, entrada, modo = "apply") {
  const plano = await executarAquisicao({ repo, entrada, modo: "dry-run" });
  return executarAquisicao({ repo, entrada, modo, hashManifestoAprovado: plano.hash });
}

test("A) prova nova em BASE_GLOBAL: cadastra prova, questões, alternativas e proveniência, sem nenhum vínculo", async () => {
  const repo = criarRepositorioMemoria();
  const resultado = await dryRunEApply(repo, entradaBase([questaoStaging(1), questaoStaging(2)]));
  assert.equal(resultado.gravado, true);
  assert.equal(repo.banco.provas.length, 1);
  assert.equal(repo.banco.questoes.length, 2);
  assert.equal(repo.banco.alternativas.length, 10);
  assert.equal(repo.banco.curso_questoes.length, 0);
  assert.deepEqual(repo.banco.questoes.map((q) => [q.prova_id, q.numero_original]), [[1, 1], [1, 2]]);
  assert.equal(repo.banco.questoes[0].fonte, "Fundatec — Prova sintética BM 2099 — Questão 01");
  assert.equal(repo.banco.alternativas.filter((a) => a.questao_id === repo.banco.questoes[0].id && a.correta).length, 1);
});

test("B) reexecutar o mesmo lote: 0 novas questões, todas 'já importada', prova reutilizada", async () => {
  const repo = criarRepositorioMemoria();
  const entrada = entradaBase([questaoStaging(1), questaoStaging(2)]);
  await dryRunEApply(repo, entrada);
  const segunda = await dryRunEApply(repo, entrada);
  assert.equal(segunda.inseridas.length, 0);
  assert.equal(segunda.prova_reutilizada, true);
  assert.equal(segunda.manifesto.resumo.ja_importadas, 2);
  assert.ok(segunda.manifesto.questoes.every((q) => q.acao === "IGNORAR"));
  assert.equal(repo.banco.questoes.length, 2);
  assert.equal(repo.banco.provas.length, 1);
});

test("C) prova já existente com questões novas: reutiliza prova_id e só insere os números que faltam", async () => {
  const repo = criarRepositorioMemoria();
  await dryRunEApply(repo, entradaBase([questaoStaging(1)]));
  const resultado = await dryRunEApply(repo, entradaBase([questaoStaging(1), questaoStaging(2)]));
  assert.equal(resultado.manifesto.prova.situacao, "EXISTENTE");
  assert.deepEqual(resultado.inseridas.map((i) => i.numero_original), [2]);
  assert.equal(repo.banco.provas.length, 1);
  assert.ok(repo.banco.questoes.every((q) => q.prova_id === 1));
});

test("D) hash conflitante: mesmo hash_prova com metadados/gabarito incompatíveis -> PARAR; mesma chave natural com outro hash -> PARAR", async () => {
  const repo = criarRepositorioMemoria();
  await dryRunEApply(repo, entradaBase([questaoStaging(1)]));

  const outroGabarito = await executarAquisicao({ repo, entrada: entradaBase([questaoStaging(2)], { proveniencia: proveniencia({ hash_gabarito: "c".repeat(64) }) }), modo: "dry-run" });
  assert.ok(outroGabarito.manifesto.bloqueios.some((b) => /hash_prova já cadastrado/.test(b)));
  await assert.rejects(
    () => executarAquisicao({ repo, entrada: entradaBase([questaoStaging(2)], { proveniencia: proveniencia({ hash_gabarito: "c".repeat(64) }) }), modo: "apply", hashManifestoAprovado: outroGabarito.hash }),
    /bloqueios/,
  );

  const outroHash = await executarAquisicao({ repo, entrada: entradaBase([questaoStaging(2)], { proveniencia: proveniencia({ hash_prova: "d".repeat(64) }) }), modo: "dry-run" });
  assert.ok(outroHash.manifesto.bloqueios.some((b) => /OUTRO hash/.test(b)));
  assert.equal(repo.banco.provas.length, 1);
  assert.equal(repo.banco.questoes.length, 1);
});

test("E) questão duplicada de outra prova/legado: IGNORAR, nunca inserida", async () => {
  const repo = criarRepositorioMemoria();
  await dryRunEApply(repo, entradaBase([questaoStaging(1)]));
  const repetida = questaoStaging(5, { enunciado: questaoStaging(1).enunciado, alternativas: questaoStaging(1).alternativas });
  const resultado = await dryRunEApply(repo, entradaBase([repetida], { proveniencia: proveniencia({ hash_prova: "e".repeat(64), nome: "Outra prova sintética" }) }));
  const item = resultado.manifesto.questoes[0];
  assert.equal(item.status_deduplicacao, "duplicada");
  assert.equal(item.acao, "IGNORAR");
  assert.equal(resultado.inseridas.length, 0);
  assert.equal(repo.banco.questoes.length, 1);
});

test("E2) duplicata de questão LEGADA (prova_id NULL) com prova nova: detectada — regressão do filtro NULL do dedup vivo", async () => {
  const repo = criarRepositorioMemoria();
  const legada = questaoStaging(9);
  repo.banco.questoes.push({ id: 1, enunciado: legada.enunciado, usuario_id: null, prova_id: null, numero_original: null, ativa: true });
  for (const [i, a] of legada.alternativas.entries()) repo.banco.alternativas.push({ questao_id: 1, texto: a.texto, ordem: i + 1, correta: a.correta });
  const { manifesto } = await executarAquisicao({ repo, entrada: entradaBase([questaoStaging(3, { enunciado: legada.enunciado, alternativas: legada.alternativas })]), modo: "dry-run" });
  assert.equal(manifesto.questoes[0].status_deduplicacao, "duplicada");
  assert.equal(manifesto.questoes[0].questao_id_existente, 1);
  assert.equal(manifesto.questoes[0].acao, "IGNORAR");
});

test("F) questão de prova da BM em BASE_GLOBAL fica só global — curso_ids_aprovados vazio por padrão", async () => {
  const repo = criarRepositorioMemoria();
  const resultado = await dryRunEApply(repo, entradaBase([questaoStaging(1)]));
  assert.deepEqual(resultado.manifesto.questoes[0].curso_ids_aprovados, []);
  assert.equal(resultado.manifesto.resumo.somente_globais, 1);
  assert.equal(repo.banco.curso_questoes.length, 0);
});

test("G) vínculo explícito: matéria aprovada para o curso e presente na estrutura -> vincula", async () => {
  const repo = criarRepositorioMemoria();
  const entrada = entradaBase([questaoStaging(1)], {
    modo: "BASE_GLOBAL_COM_VINCULO",
    aprovacao: { vinculos: [{ curso: "brigada-militar-rs", materias: [PORTUGUES] }] },
  });
  const resultado = await dryRunEApply(repo, entrada);
  assert.deepEqual(resultado.manifesto.questoes[0].curso_ids_aprovados, [CURSO_BM]);
  assert.deepEqual(repo.banco.curso_questoes, [{ curso_id: CURSO_BM, questao_id: resultado.inseridas[0].questao_id }]);
});

test("H) matéria fora da estrutura do curso: rejeitada no manifesto, questão entra só global, nada criado no curso", async () => {
  const repo = criarRepositorioMemoria();
  const entrada = entradaBase([questaoStaging(1, { materia: HISTORIA, assunto: null })], {
    modo: "BASE_GLOBAL_COM_VINCULO",
    aprovacao: { vinculos: [{ curso: "brigada-militar-rs", materias: ["História"] }] },
  });
  const resultado = await dryRunEApply(repo, entrada);
  assert.equal(resultado.manifesto.vinculos[0].materias_rejeitadas[0].valor, "História");
  assert.deepEqual(resultado.manifesto.vinculos[0].materia_ids_aprovadas, []);
  assert.equal(resultado.manifesto.questoes[0].acao, "IMPORTAR");
  assert.equal(repo.banco.curso_questoes.length, 0);
  assert.equal(repo.banco.curso_materias.length, 2, "nenhuma matéria nova no curso");
});

test("I) falha no meio do lote: ROLLBACK total — nem prova, nem questões, nem alternativas ficam", async () => {
  const repo = criarRepositorioMemoria({ falharNaQuestao: 2 });
  const entrada = entradaBase([questaoStaging(1), questaoStaging(2), questaoStaging(3)]);
  const plano = await executarAquisicao({ repo, entrada, modo: "dry-run" });
  await assert.rejects(() => executarAquisicao({ repo, entrada, modo: "apply", hashManifestoAprovado: plano.hash }), /falha simulada/);
  assert.equal(repo.banco.provas.length, 0);
  assert.equal(repo.banco.questoes.length, 0);
  assert.equal(repo.banco.alternativas.length, 0);
});

test("J) anulada: IGNORAR com status_gabarito ANULADA — nunca importada como se tivesse correta", async () => {
  const repo = criarRepositorioMemoria();
  const resultado = await dryRunEApply(repo, entradaBase([questaoStaging(1), questaoStaging(2, { anulada: true })]));
  const anulada = resultado.manifesto.questoes.find((q) => q.numero_original === 2);
  assert.equal(anulada.acao, "IGNORAR");
  assert.equal(anulada.status_gabarito, "ANULADA");
  assert.equal(resultado.manifesto.resumo.anuladas, 1);
  assert.deepEqual(repo.banco.questoes.map((q) => q.numero_original), [1]);
});

test("K) questão para revisão (classificação incerta, gabarito/extração com falha, 2 corretas, quebra de parsing): REVISAR, nunca inserida", async () => {
  const repo = criarRepositorioMemoria();
  const duasCorretas = questaoStaging(4);
  duasCorretas.alternativas[0].correta = true;
  const quebra = questaoStaging(5);
  quebra.alternativas[2].texto = "texto a) um b) dois c) três d) quatro";
  const questoes = [
    questaoStaging(1, { confidence: "baixa" }),
    questaoStaging(2, { etapas: { GABARITO_OK: false } }),
    questaoStaging(3, { etapas: { EXTRACAO_OK: false } }),
    duasCorretas,
    quebra,
    questaoStaging(6),
  ];
  const resultado = await dryRunEApply(repo, entradaBase(questoes));
  const acoes = Object.fromEntries(resultado.manifesto.questoes.map((q) => [q.numero_original, q.acao]));
  assert.deepEqual(acoes, { 1: "REVISAR", 2: "REVISAR", 3: "REVISAR", 4: "REVISAR", 5: "REVISAR", 6: "IMPORTAR" });
  assert.ok(resultado.manifesto.questoes[4].motivos.some((m) => /quebra de parsing/.test(m)));
  assert.deepEqual(repo.banco.questoes.map((q) => q.numero_original), [6]);
});

test("K2) override de classificação no arquivo de aprovação libera questão incerta, mas assunto de outra matéria é recusado", async () => {
  const repo = criarRepositorioMemoria();
  const entrada = entradaBase([questaoStaging(1, { confidence: "baixa" }), questaoStaging(2, { confidence: "baixa" })], {
    aprovacao: {
      classificacao: {
        1: { materia_id: MATEMATICA, assunto_id: ASSUNTO_PORCENTAGEM },
        2: { materia_id: MATEMATICA, assunto_id: ASSUNTO_CRASE },
      },
    },
  });
  const { manifesto } = await executarAquisicao({ repo, entrada, modo: "dry-run" });
  assert.equal(manifesto.questoes[0].acao, "IMPORTAR");
  assert.equal(manifesto.questoes[0].status_classificacao, "override");
  assert.equal(manifesto.questoes[1].acao, "REVISAR");
  assert.ok(manifesto.questoes[1].motivos.some((m) => /não pertence à matéria/.test(m)));
});

test("L) vínculo implícito pela origem é proibido: COM_VINCULO sem matérias, COM_VINCULO sem vínculos e BASE_GLOBAL com vínculos bloqueiam", async () => {
  const repo = criarRepositorioMemoria();
  const q = [questaoStaging(1)];
  const semMaterias = await executarAquisicao({ repo, entrada: entradaBase(q, { modo: "BASE_GLOBAL_COM_VINCULO", aprovacao: { vinculos: [{ curso: "brigada-militar-rs" }] } }), modo: "dry-run" });
  assert.ok(semMaterias.manifesto.bloqueios.some((b) => /vínculo implícito/.test(b)));
  const semVinculo = await executarAquisicao({ repo, entrada: entradaBase(q, { modo: "BASE_GLOBAL_COM_VINCULO" }), modo: "dry-run" });
  assert.ok(semVinculo.manifesto.bloqueios.some((b) => /exige vínculos explícitos/.test(b)));
  const globalComVinculo = await executarAquisicao({ repo, entrada: entradaBase(q, { aprovacao: { vinculos: [{ curso: "brigada-militar-rs", materias: [PORTUGUES] }] } }), modo: "dry-run" });
  assert.ok(globalComVinculo.manifesto.bloqueios.length > 0);
  await assert.rejects(() => executarAquisicao({ repo, entrada: entradaBase(q, { modo: "BASE_GLOBAL_COM_VINCULO" }), modo: "apply", hashManifestoAprovado: semVinculo.hash }), /bloqueios/);
  assert.equal(repo.banco.questoes.length, 0);
});

test("BM fictícia com Português e Matemática, manifesto aprova só Português: ambas globais, só Português vincula à BM (mesmo com Matemática na estrutura do curso)", async () => {
  const repo = criarRepositorioMemoria();
  const entrada = entradaBase([questaoStaging(1, { materia: PORTUGUES, assunto: ASSUNTO_CRASE }), questaoStaging(21, { materia: MATEMATICA, assunto: ASSUNTO_PORCENTAGEM })], {
    modo: "BASE_GLOBAL_COM_VINCULO",
    aprovacao: { vinculos: [{ curso: "brigada-militar-rs", materias: ["Língua Portuguesa"] }] },
  });
  const resultado = await dryRunEApply(repo, entrada);
  assert.equal(repo.banco.questoes.length, 2, "ambas entram na base global");
  const portugues = repo.banco.questoes.find((q) => q.numero_original === 1);
  const matematica = repo.banco.questoes.find((q) => q.numero_original === 21);
  assert.equal(matematica.prova_id, portugues.prova_id, "mesma proveniência");
  assert.deepEqual(repo.banco.curso_questoes, [{ curso_id: CURSO_BM, questao_id: portugues.id }]);
  assert.equal(resultado.manifesto.resumo.vinculos_por_curso["brigada-militar-rs"], 1);
  assert.equal(resultado.manifesto.resumo.somente_globais, 1);
  const relatorio = montarRelatorioAquisicao(resultado, "2099-01-01T00:00:00.000Z");
  assert.deepEqual(relatorio.efetivado, { questoes_inseridas: 2, vinculadas_por_curso: { "brigada-militar-rs": 1 }, somente_globais: 1 });
});

test("M) dry-run nunca escreve (transação somente leitura) e apply exige o hash do manifesto aprovado", async () => {
  const repo = criarRepositorioMemoria();
  const entrada = entradaBase([questaoStaging(1)]);
  const plano = await executarAquisicao({ repo, entrada, modo: "dry-run" });
  assert.equal(plano.gravado, false);
  assert.equal(repo.banco.questoes.length, 0);
  await assert.rejects(() => executarAquisicao({ repo, entrada, modo: "apply" }), ErroAquisicao);
  await assert.rejects(() => executarAquisicao({ repo, entrada, modo: "apply", hashManifestoAprovado: "f".repeat(64) }), /difere do manifesto aprovado/);
  assert.equal(repo.banco.questoes.length, 0);
});

test("N) manifesto determinístico: mesmo staging e mesmo banco -> mesmo hash; staging alterado -> hash diferente", async () => {
  const repo = criarRepositorioMemoria();
  const a = await executarAquisicao({ repo, entrada: entradaBase([questaoStaging(2), questaoStaging(1)]), modo: "dry-run" });
  const b = await executarAquisicao({ repo, entrada: entradaBase([questaoStaging(1), questaoStaging(2)]), modo: "dry-run" });
  assert.equal(a.hash, b.hash);
  const alterada = questaoStaging(1);
  alterada.alternativas[1].texto = "texto trocado depois do dry-run";
  const c = await executarAquisicao({ repo, entrada: entradaBase([alterada, questaoStaging(2)]), modo: "dry-run" });
  assert.notEqual(a.hash, c.hash);
  assert.equal(hashManifesto(a.manifesto), a.hash);
});

test("O) teste-rollback percorre o caminho de escrita e o pós-check, mas não deixa nada gravado", async () => {
  const repo = criarRepositorioMemoria();
  const resultado = await dryRunEApply(repo, entradaBase([questaoStaging(1)]), "teste-rollback");
  assert.equal(resultado.gravado, false);
  assert.equal(resultado.pos_check.ok, true);
  assert.equal(resultado.inseridas.length, 1);
  assert.equal(repo.banco.questoes.length, 0);
  assert.equal(repo.banco.provas.length, 0);
});

test("P) proveniência incompleta ou arquivos divergentes do staging bloqueiam o documento inteiro", () => {
  const contexto = { materias: new Map(), assuntos: new Map(), cursos: [], questoesGlobais: [], numerosJaImportados: new Map(), sequenciaEmbutida: new Set() };
  const incompleta = planejarAquisicao({ modo: "BASE_GLOBAL", proveniencia: { completa: false, faltando: ["hash_gabarito"], invalidos: [], prova: {} }, questoes: [questaoStaging(1)], contexto });
  assert.ok(incompleta.bloqueios.some((b) => /hash_gabarito/.test(b)));
  assert.equal(incompleta.questoes[0].acao, "REVISAR");
  const divergente = planejarAquisicao({ modo: "BASE_GLOBAL", proveniencia: proveniencia(), questoes: [], contexto: { ...contexto, hashesDivergentes: "hash de prova diverge do staging" } });
  assert.ok(divergente.bloqueios.includes("hash de prova diverge do staging"));
});

test("Q) relatório separa duplicadas exatas de prováveis — nunca soma as duas; provável continua bloqueando a importação", async () => {
  const repo = criarRepositorioMemoria();
  const legada = questaoStaging(9);
  repo.banco.questoes.push({ id: 1, enunciado: legada.enunciado, usuario_id: null, prova_id: null, numero_original: null, ativa: true });
  for (const [i, a] of legada.alternativas.entries()) repo.banco.alternativas.push({ questao_id: 1, texto: a.texto, ordem: i + 1, correta: a.correta });
  const parecida = questaoStaging(2, { enunciado: `${legada.enunciado} com um complemento diferente`, alternativas: legada.alternativas.map((a) => ({ ...a, texto: `${a.texto} variada` })) });
  const distinta = questaoStaging(3, {
    enunciado: "Quanto vale o dobro de quarenta e dois mais oito?",
    alternativas: ["90", "92", "84", "100", "76"].map((texto, i) => ({ letra: "ABCDE"[i], texto, correta: i === 1 })),
  });
  const { manifesto } = await executarAquisicao({ repo, entrada: entradaBase([parecida, distinta]), modo: "dry-run" });
  assert.equal(manifesto.resumo.duplicadas_exatas, 0);
  assert.equal(manifesto.resumo.provaveis_duplicadas, 1);
  assert.equal(manifesto.resumo.duplicadas, undefined, "campo somado antigo não existe mais");
  assert.equal(manifesto.questoes.find((q) => q.numero_original === 2).acao, "REVISAR");
  assert.equal(manifesto.questoes.find((q) => q.numero_original === 3).acao, "IMPORTAR");
});

test("R) retificações de gabarito entram no manifesto (e no hash); anulada por retificação é IGNORAR", async () => {
  const repo = criarRepositorioMemoria();
  const retificacoes = [{ ordem: 1, documento: "Edital ficticio 9/2099", url: "https://exemplo.org/ret.pdf", hash: "f".repeat(64) }];
  const comRetificacao = await executarAquisicao({
    repo,
    entrada: entradaBase([questaoStaging(1), questaoStaging(2, { anulada: true })], { proveniencia: { ...proveniencia(), retificacoes } }),
    modo: "dry-run",
  });
  assert.deepEqual(comRetificacao.manifesto.retificacoes_gabarito, retificacoes);
  assert.equal(comRetificacao.manifesto.questoes.find((q) => q.numero_original === 2).acao, "IGNORAR");
  const semRetificacao = await executarAquisicao({ repo, entrada: entradaBase([questaoStaging(1), questaoStaging(2, { anulada: true })]), modo: "dry-run" });
  assert.notEqual(comRetificacao.hash, semRetificacao.hash);
});

// ---- Documentos do gabarito (public.prova_documentos) ----

const HASH_RET1 = "1".repeat(64);
const HASH_RET2 = "2".repeat(64);
function comRetificacoes(retificacoes) {
  return { proveniencia: { ...proveniencia(), retificacoes } };
}
const RET1 = { ordem: 1, documento: "Edital ficticio 1", url: "https://exemplo.org/r1.pdf", hash: HASH_RET1 };
const RET2 = { ordem: 2, documento: "Edital ficticio 2", url: "https://exemplo.org/r2.pdf", hash: HASH_RET2 };
const docs = (repo) => repo.banco.prova_documentos.map((d) => [d.tipo, d.ordem, d.hash_sha256]);

test("DOC-A) prova sem retificação: registra só o GABARITO (ordem 0) com o hash de provas.hash_gabarito", async () => {
  const repo = criarRepositorioMemoria();
  const resultado = await dryRunEApply(repo, entradaBase([questaoStaging(1)]));
  assert.deepEqual(docs(repo), [["GABARITO", 0, HASH_GABARITO]]);
  assert.equal(repo.banco.prova_documentos[0].url, "https://exemplo.org/gabarito.pdf");
  assert.equal(resultado.manifesto.resumo.documentos_novos, 1);
});

test("DOC-B) prova com 1 retificação: GABARITO + RETIFICACAO ordem 1", async () => {
  const repo = criarRepositorioMemoria();
  await dryRunEApply(repo, entradaBase([questaoStaging(1)], comRetificacoes([RET1])));
  assert.deepEqual(docs(repo), [["GABARITO", 0, HASH_GABARITO], ["RETIFICACAO", 1, HASH_RET1]]);
});

test("DOC-C) múltiplas retificações: registradas na ordem explícita (não na ordem da lista); ordem repetida bloqueia", async () => {
  const repo = criarRepositorioMemoria();
  await dryRunEApply(repo, entradaBase([questaoStaging(1)], comRetificacoes([RET2, RET1])));
  assert.deepEqual(
    docs(repo).sort((a, b) => a[1] - b[1]),
    [["GABARITO", 0, HASH_GABARITO], ["RETIFICACAO", 1, HASH_RET1], ["RETIFICACAO", 2, HASH_RET2]],
  );
  const repetida = await executarAquisicao({ repo: criarRepositorioMemoria(), entrada: entradaBase([questaoStaging(1)], comRetificacoes([RET1, { ...RET2, ordem: 1 }])), modo: "dry-run" });
  assert.ok(repetida.manifesto.bloqueios.some((b) => /mesma ordem/.test(b)));
});

test("DOC-D) reexecução idempotente: documentos JA_REGISTRADO, nada duplicado", async () => {
  const repo = criarRepositorioMemoria();
  const entrada = entradaBase([questaoStaging(1)], comRetificacoes([RET1]));
  await dryRunEApply(repo, entrada);
  const segunda = await dryRunEApply(repo, entrada);
  assert.ok(segunda.manifesto.documentos.every((d) => d.situacao === "JA_REGISTRADO"));
  assert.equal(segunda.manifesto.resumo.documentos_novos, 0);
  assert.equal(repo.banco.prova_documentos.length, 2);
  assert.equal(segunda.pos_check.ok, true);
});

test("DOC-E) documento já registrado com hash diferente -> bloqueio, nada gravado", async () => {
  const repo = criarRepositorioMemoria();
  await dryRunEApply(repo, entradaBase([questaoStaging(1)], comRetificacoes([RET1])));
  const outra = entradaBase([questaoStaging(1), questaoStaging(2)], comRetificacoes([{ ...RET1, hash: "9".repeat(64) }]));
  const plano = await executarAquisicao({ repo, entrada: outra, modo: "dry-run" });
  assert.ok(plano.manifesto.bloqueios.some((b) => /RETIFICACAO:1 já registrado para a prova com OUTRO hash/.test(b)));
  await assert.rejects(() => executarAquisicao({ repo, entrada: outra, modo: "apply", hashManifestoAprovado: plano.hash }), /bloqueios/);
  assert.equal(repo.banco.prova_documentos.length, 2);
  assert.equal(repo.banco.questoes.length, 1);
});

test("DOC-F) documento do manifesto aprovado ausente no apply -> recusado; documento registrado ausente do manifesto atual -> bloqueio", async () => {
  const repo = criarRepositorioMemoria();
  const aprovado = await executarAquisicao({ repo, entrada: entradaBase([questaoStaging(1)], comRetificacoes([RET1])), modo: "dry-run" });
  await assert.rejects(
    () => executarAquisicao({ repo, entrada: entradaBase([questaoStaging(1)]), modo: "apply", hashManifestoAprovado: aprovado.hash }),
    /difere do manifesto aprovado/,
  );
  assert.equal(repo.banco.provas.length, 0);

  await dryRunEApply(repo, entradaBase([questaoStaging(1)], comRetificacoes([RET1])));
  const semRetificacao = await executarAquisicao({ repo, entrada: entradaBase([questaoStaging(1)]), modo: "dry-run" });
  assert.ok(semRetificacao.manifesto.bloqueios.some((b) => /RETIFICACAO:1 registrado para a prova não está no manifesto/.test(b)));
  const novaRetificacao = await executarAquisicao({ repo, entrada: entradaBase([questaoStaging(1)], comRetificacoes([RET1, RET2])), modo: "dry-run" });
  assert.ok(novaRetificacao.manifesto.bloqueios.some((b) => /outro conjunto de documentos/.test(b)));
});

test("DOC-G) pós-check: documento persistido com hash diferente do manifesto derruba o apply (ROLLBACK)", async () => {
  const repo = criarRepositorioMemoria();
  const original = repo.inserirDocumento;
  repo.inserirDocumento = (provaId, d) => original(provaId, d.tipo === "RETIFICACAO" ? { ...d, hash_sha256: "8".repeat(64) } : d);
  await assert.rejects(() => dryRunEApply(repo, entradaBase([questaoStaging(1)], comRetificacoes([RET1]))), /pós-check falhou/);
  assert.equal(repo.banco.prova_documentos.length, 0);
  assert.equal(repo.banco.provas.length, 0);
});

test("DOC-H) prova já cadastrada SEM nenhum documento (registro anterior a prova_documentos): bloqueio — documentos não são reconstruídos por inferência", async () => {
  const repo = criarRepositorioMemoria();
  repo.banco.provas.push({ ...proveniencia().prova, id: 50 });
  const { manifesto } = await executarAquisicao({ repo, entrada: entradaBase([questaoStaging(1)]), modo: "dry-run" });
  assert.equal(manifesto.prova.situacao, "EXISTENTE");
  assert.ok(manifesto.bloqueios.some((b) => /outro conjunto de documentos/.test(b)));
  assert.equal(repo.banco.prova_documentos.length, 0);
});

test("DOC-I) falha no meio do lote depois dos documentos gravados: ROLLBACK não deixa prova_documentos parciais", async () => {
  const repo = criarRepositorioMemoria({ falharNaQuestao: 2 });
  const entrada = entradaBase([questaoStaging(1), questaoStaging(2)], comRetificacoes([RET1, RET2]));
  const plano = await executarAquisicao({ repo, entrada, modo: "dry-run" });
  await assert.rejects(() => executarAquisicao({ repo, entrada, modo: "apply", hashManifestoAprovado: plano.hash }), /falha simulada/);
  assert.equal(repo.banco.prova_documentos.length, 0);
  assert.equal(repo.banco.provas.length, 0);
  assert.equal(repo.banco.questoes.length, 0);
});

test("DOC-J) teste-rollback expõe o que seria gravado (1 prova, 1 GABARITO, N retificações, questões) e não deixa nada", async () => {
  const repo = criarRepositorioMemoria();
  const resultado = await dryRunEApply(repo, entradaBase([questaoStaging(1), questaoStaging(2)], comRetificacoes([RET1])), "teste-rollback");
  const { antes, depois } = resultado.contagens_na_transacao;
  assert.deepEqual(
    Object.fromEntries(Object.keys(antes).map((t) => [t, depois[t] - antes[t]])),
    { provas: 1, prova_documentos: 2, questoes: 2, alternativas: 10, curso_questoes: 0 },
  );
  assert.equal(repo.banco.prova_documentos.length, 0);
  assert.equal(repo.banco.provas.length, 0);
});
