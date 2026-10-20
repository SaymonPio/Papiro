import assert from "node:assert/strict";
import test from "node:test";
import { createHash } from "node:crypto";
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

// midias: liga questao_midias + bucket. O bucket (Map path -> bytes) fica FORA do snapshot transacional,
// como o Storage real: ROLLBACK do banco não desfaz objeto enviado.
function criarRepositorioMemoria({ falharNaQuestao = null, midias = false, bucket = new Map() } = {}) {
  const banco = {
    ...(midias ? { questao_midias: [] } : {}),
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
        infraMidias: midias,
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
    ...(midias
      ? {
          bucket,
          locks: 0,
          // Mesmas constraints de questao_midias: (questao_id, ordem) e (questao_id, sha256) únicos, path = sha.
          async inserirMidia(m) {
            exigirEscrita();
            if (m.storage_path !== `questoes/${m.sha256}.png`) throw new Error("check questao_midias_path_check");
            if (banco.questao_midias.some((x) => x.questao_id === m.questao_id && (x.ordem === m.ordem || x.sha256 === m.sha256))) throw new Error("duplicate key questao_midias");
            banco.questao_midias.push({ ...m });
          },
          async objetosMidia(paths) {
            return new Map(paths.filter((p) => bucket.has(p)).map((p) => [p, bucket.get(p).length]));
          },
          async midiaReferenciada(sha) {
            return banco.questao_midias.some((m) => m.sha256 === sha);
          },
          async bloquearMidias() {
            this.locks++;
          },
          async liberarMidias() {
            this.locks--;
          },
        }
      : {}),
    async lerEstadoPosCheck({ provaId, questaoIds }) {
      return {
        ...(midias ? { midias: banco.questao_midias.filter((m) => questaoIds.includes(m.questao_id)) } : {}),
        prova: banco.provas.find((p) => p.id === provaId) ?? null,
        documentos: banco.prova_documentos.filter((d) => d.prova_id === provaId),
        questoesDaProva: banco.questoes
          .filter((q) => q.prova_id === provaId)
          .map((q) => ({ ...q, alternativas: banco.alternativas.filter((a) => a.questao_id === q.id) })),
        vinculos: banco.curso_questoes.filter((v) => questaoIds.includes(v.questao_id)),
      };
    },
    async contagensMutaveis() {
      return {
        provas: banco.provas.length,
        prova_documentos: banco.prova_documentos.length,
        questoes: banco.questoes.length,
        alternativas: banco.alternativas.length,
        curso_questoes: banco.curso_questoes.length,
        ...(midias ? { questao_midias: banco.questao_midias.length } : {}),
      };
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

// ---- Liberação explícita de gate conservador ----

function comInterno(questao, interno) {
  questao._interno = { ...questao._interno, ...interno };
  questao.etapas.EXTRACAO_OK = false;
  return questao;
}
const JUSTIFICATIVA = "revisão humana: a frase analisada está citada por inteiro no enunciado";
const liberar = (numero, motivo, extras = {}) => ({ numero_original: numero, gate: "EXTRACAO_OK", motivo, justificativa: JUSTIFICATIVA, ...extras });

test("LIB-A) dependência de texto incerta: sem liberação é REVISAR; liberada explicitamente vira IMPORTAR, grava e entra no hash", async () => {
  const lote = () => [comInterno(questaoStaging(1), { dependencia_texto_incerta: "questão dentro do bloco do texto" }), questaoStaging(2)];
  const sem = await executarAquisicao({ repo: criarRepositorioMemoria(), entrada: entradaBase(lote()), modo: "dry-run" });
  assert.equal(sem.manifesto.questoes[0].acao, "REVISAR", "nunca libera implicitamente");
  assert.deepEqual(sem.manifesto.questoes[0].motivos, ["EXTRACAO_OK=false no staging"]);

  const repo = criarRepositorioMemoria();
  const entrada = entradaBase(lote(), { aprovacao: { liberacoes: [liberar(1, "dependencia_texto_incerta")] } });
  const resultado = await dryRunEApply(repo, entrada);
  assert.equal(resultado.manifesto.questoes[0].acao, "IMPORTAR");
  assert.deepEqual(resultado.manifesto.questoes[0].liberacoes_aplicadas, [{ gate: "EXTRACAO_OK", motivo: "dependencia_texto_incerta", justificativa: JUSTIFICATIVA }]);
  assert.equal(resultado.manifesto.resumo.liberadas_explicitamente, 1);
  assert.deepEqual(repo.banco.questoes.map((q) => q.numero_original), [1, 2]);
  assert.notEqual(resultado.hash, sem.hash);

  const outraJustificativa = entradaBase(lote(), { aprovacao: { liberacoes: [liberar(1, "dependencia_texto_incerta", { justificativa: `${JUSTIFICATIVA} (revisada)` })] } });
  const { hash } = await executarAquisicao({ repo: criarRepositorioMemoria(), entrada: outraJustificativa, modo: "dry-run" });
  assert.notEqual(hash, resultado.hash, "a justificativa aprovada faz parte do manifesto");
});

test("LIB-B) liberar uma causa nunca esconde outra: dependência liberada + referência visual pendente continua REVISAR", async () => {
  const q = comInterno(questaoStaging(1), { dependencia_texto_incerta: "bloco do texto", referencia_visual: 'cita elemento visual ("Figura 1")' });
  const { manifesto } = await executarAquisicao({ repo: criarRepositorioMemoria(), entrada: entradaBase([q], { aprovacao: { liberacoes: [liberar(1, "dependencia_texto_incerta")] } }), modo: "dry-run" });
  assert.equal(manifesto.questoes[0].acao, "REVISAR");
  assert.ok(manifesto.questoes[0].motivos.some((m) => /não cobre: referencia_visual/.test(m)));
  assert.equal(manifesto.questoes[0].liberacoes_aplicadas.length, 1, "a liberação usada continua registrada");
});

test("LIB-C) causa não liberável ou desconhecida nunca é liberada: texto-base não confiável e EXTRACAO_OK=false sem causa identificável", async () => {
  const corrompida = comInterno(questaoStaging(1), { textos_base: [{ id: "T1", confiavel: false, motivo: "ordem trocada" }], dependencia_texto_incerta: "x" });
  const semCausa = questaoStaging(2, { etapas: { EXTRACAO_OK: false } });
  const entrada = entradaBase([corrompida, semCausa], { aprovacao: { liberacoes: [liberar(1, "dependencia_texto_incerta"), liberar(2, "dependencia_texto_incerta")] } });
  const { manifesto } = await executarAquisicao({ repo: criarRepositorioMemoria(), entrada, modo: "dry-run" });
  assert.deepEqual(manifesto.questoes.map((q) => q.acao), ["REVISAR", "REVISAR"]);
  assert.ok(manifesto.questoes[0].motivos.some((m) => /não cobre: texto_base_nao_confiavel/.test(m)));
  assert.ok(manifesto.questoes[1].motivos.some((m) => /causa não identificada/.test(m)));
  assert.equal(manifesto.bloqueios.length, 0);
});

test("LIB-D) aprovação malformada bloqueia o documento: gate não liberável, motivo não liberável, número fora do lote, justificativa curta, repetida", async () => {
  const q = comInterno(questaoStaging(1), { dependencia_texto_incerta: "x" });
  const casos = [
    [{ ...liberar(1, "dependencia_texto_incerta"), gate: "GABARITO_OK" }, /não admite liberação/],
    [liberar(1, "texto_base_nao_confiavel"), /não é liberável/],
    [liberar(99, "dependencia_texto_incerta"), /não existe no lote/],
    [liberar(1, "dependencia_texto_incerta", { justificativa: "ok" }), /justificativa/],
  ];
  for (const [liberacao, padrao] of casos) {
    const { manifesto } = await executarAquisicao({ repo: criarRepositorioMemoria(), entrada: entradaBase([comInterno(questaoStaging(1), { dependencia_texto_incerta: "x" })], { aprovacao: { liberacoes: [liberacao] } }), modo: "dry-run" });
    assert.ok(manifesto.bloqueios.some((b) => padrao.test(b)), `esperado bloqueio ${padrao}`);
    assert.equal(manifesto.resumo.importar, 0);
  }
  const repetida = await executarAquisicao({ repo: criarRepositorioMemoria(), entrada: entradaBase([q], { aprovacao: { liberacoes: [liberar(1, "dependencia_texto_incerta"), liberar(1, "dependencia_texto_incerta")] } }), modo: "dry-run" });
  assert.ok(repetida.manifesto.bloqueios.some((b) => /repetida/.test(b)));
  const naoLista = await executarAquisicao({ repo: criarRepositorioMemoria(), entrada: entradaBase([q], { aprovacao: { liberacoes: { 1: "EXTRACAO_OK" } } }), modo: "dry-run" });
  assert.ok(naoLista.manifesto.bloqueios.some((b) => /precisa ser uma lista/.test(b)));
});

test("LIB-E) liberação sem causa pendente é aprovação desatualizada (REVISAR); depois do apply a mesma aprovação não atrapalha a reexecução", async () => {
  const desatualizada = await executarAquisicao({ repo: criarRepositorioMemoria(), entrada: entradaBase([questaoStaging(1)], { aprovacao: { liberacoes: [liberar(1, "alternativa_suspeita")] } }), modo: "dry-run" });
  assert.equal(desatualizada.manifesto.questoes[0].acao, "REVISAR");
  assert.ok(desatualizada.manifesto.questoes[0].motivos.some((m) => /sem causa pendente correspondente/.test(m)));

  const repo = criarRepositorioMemoria();
  const entrada = () => entradaBase([comInterno(questaoStaging(1), { dependencia_texto_incerta: "x" })], { aprovacao: { liberacoes: [liberar(1, "dependencia_texto_incerta")] } });
  await dryRunEApply(repo, entrada());
  const { manifesto } = await executarAquisicao({ repo, entrada: entrada(), modo: "dry-run" });
  assert.equal(manifesto.bloqueios.length, 0);
  assert.equal(manifesto.resumo.importar, 0);
  assert.equal(manifesto.resumo.ja_importadas, 1);
});

// Banco com a legada 1 e uma questão parecida (provável duplicada, nunca exata) no lote.
function cenarioProvavelDuplicada() {
  const repo = criarRepositorioMemoria();
  const legada = questaoStaging(9);
  repo.banco.questoes.push({ id: 1, enunciado: legada.enunciado, usuario_id: null, prova_id: null, numero_original: null, ativa: true });
  for (const [i, a] of legada.alternativas.entries()) repo.banco.alternativas.push({ questao_id: 1, texto: a.texto, ordem: i + 1, correta: a.correta });
  const parecida = () =>
    questaoStaging(2, {
      enunciado: `${legada.enunciado} com um complemento diferente`,
      alternativas: legada.alternativas.map((a) => ({ ...a, texto: `${a.texto} variada` })),
      etapas: { DEDUP_OK: false },
    });
  return { repo, parecida };
}
const JUSTIFICATIVA_DEDUP = "revisão humana: comparada com a legada, outro comando e outras alternativas";
const liberarDedup = (numero, questaoId, extras = {}) => ({ numero_original: numero, gate: "DEDUP_OK", motivo: "provavel_duplicada", questao_id: questaoId, justificativa: JUSTIFICATIVA_DEDUP, ...extras });
const comMatchStaging = (questao, matchId) => ({ ...questao, dedup: { status: "provavel_duplicada", match_id: matchId } });

test("LIB-DEDUP-A) provável duplicada descartada na revisão: liberada para a questao_id comparada vira IMPORTAR e entra no hash", async () => {
  const { repo, parecida } = cenarioProvavelDuplicada();
  const sem = await executarAquisicao({ repo, entrada: entradaBase([comMatchStaging(parecida(), 1)]), modo: "dry-run" });
  assert.equal(sem.manifesto.questoes[0].acao, "REVISAR");

  const entrada = entradaBase([comMatchStaging(parecida(), 1)], { aprovacao: { liberacoes: [liberarDedup(2, 1)] } });
  const resultado = await dryRunEApply(repo, entrada);
  const item = resultado.manifesto.questoes[0];
  assert.equal(item.acao, "IMPORTAR");
  assert.equal(item.status_deduplicacao, "provavel_duplicada", "o status de dedup continua registrado");
  assert.deepEqual(item.liberacoes_aplicadas, [{ gate: "DEDUP_OK", motivo: "provavel_duplicada", questao_id: 1, justificativa: JUSTIFICATIVA_DEDUP }]);
  assert.notEqual(resultado.hash, sem.hash);
  assert.equal(repo.banco.questoes.length, 2, "legada preservada + nova inserida");
});

test("LIB-DEDUP-B) candidato de dedup mudou (liberação aponta OUTRA questao_id): volta a REVISAR; duplicada exata nunca é liberada", async () => {
  const { repo, parecida } = cenarioProvavelDuplicada();
  const outra = await executarAquisicao({ repo, entrada: entradaBase([comMatchStaging(parecida(), 1)], { aprovacao: { liberacoes: [liberarDedup(2, 77)] } }), modo: "dry-run" });
  assert.equal(outra.manifesto.questoes[0].acao, "REVISAR");
  assert.ok(outra.manifesto.questoes[0].motivos.some((m) => /sem causa pendente correspondente/.test(m)));

  const legada = questaoStaging(9);
  const exata = { ...questaoStaging(3, { enunciado: legada.enunciado, alternativas: legada.alternativas, etapas: { DEDUP_OK: false } }), dedup: { status: "duplicada", match_id: 1 } };
  const { manifesto } = await executarAquisicao({ repo, entrada: entradaBase([exata], { aprovacao: { liberacoes: [liberarDedup(3, 1)] } }), modo: "dry-run" });
  assert.notEqual(manifesto.questoes[0].acao, "IMPORTAR");
  assert.equal(manifesto.questoes[0].status_deduplicacao, "duplicada");
});

test("LIB-DEDUP-C) DEDUP_OK sem questao_id bloqueia o documento; questao_id em outro gate também", async () => {
  const { repo, parecida } = cenarioProvavelDuplicada();
  const casos = [
    [{ ...liberarDedup(2, 1), questao_id: undefined }, /exige questao_id/],
    [liberar(2, "dependencia_texto_incerta", { questao_id: 1 }), /só se aplica a DEDUP_OK/],
  ];
  for (const [liberacao, padrao] of casos) {
    const { manifesto } = await executarAquisicao({ repo, entrada: entradaBase([comMatchStaging(parecida(), 1)], { aprovacao: { liberacoes: [liberacao] } }), modo: "dry-run" });
    assert.ok(manifesto.bloqueios.some((b) => padrao.test(b)), `esperado bloqueio ${padrao}`);
    assert.equal(manifesto.resumo.importar, 0);
  }
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

test("PRE-A) gabarito PRELIMINAR bloqueia o documento inteiro (nada importável), mas a ação potencial de cada questão fica medida", async () => {
  const repo = criarRepositorioMemoria();
  const entrada = entradaBase([questaoStaging(1), questaoStaging(2, { confidence: "baixa" }), questaoStaging(3, { anulada: true })], {
    proveniencia: { ...proveniencia(), gabarito_tipo: "preliminar" },
  });
  const plano = await executarAquisicao({ repo, entrada, modo: "dry-run" });
  assert.ok(plano.manifesto.bloqueios.some((b) => /gabarito PRELIMINAR/.test(b)));
  assert.ok(plano.manifesto.questoes.every((q) => q.acao === "REVISAR"));
  assert.deepEqual(plano.manifesto.questoes.map((q) => q.acao_potencial), ["IMPORTAR", "REVISAR", "IGNORAR"]);
  assert.equal(plano.manifesto.resumo.importar, 0);
  assert.equal(plano.manifesto.resumo.importar_potencial, 1);
  await assert.rejects(() => executarAquisicao({ repo, entrada, modo: "apply", hashManifestoAprovado: plano.hash }), /bloqueios/);
  assert.equal(repo.banco.provas.length, 0);
});

// ---- Mídias (questao_midias + bucket questao-midias) ----

const shaDe = (bytes) => createHash("sha256").update(bytes).digest("hex");
const PNG_A = Buffer.from("png-sintetico-da-figura-A");
const PNG_B = Buffer.from("png-sintetico-da-figura-B");

function midiaStaging(bytes, { ordem = 1, direito = "OFICIAL_PROVA", tipo = "FIGURA" } = {}) {
  const sha = shaDe(bytes);
  return { ordem, tipo, sha256: sha, mime_type: "image/png", arquivo: `midias/${sha}.png`, storage_path: `questoes/${sha}.png`, largura: 120, altura: 60, pagina_origem: 7, ancora_texto: "Figura 1 – Painel", legenda: "Figura 1 – Painel", alt_text: "Figura 1 – Painel", credito: null, direito_uso: direito, origem_descricao: "PDF da prova, página 7: 1 objeto(s) de imagem (img_p6_1)" };
}
function questaoComMidia(numero, midias, { etapas = {}, interno = {} } = {}) {
  const q = questaoStaging(numero, { etapas: { MIDIA_OK: true, ...etapas } });
  q._interno = { ...q._interno, dependencia_midia: true, midias, ...interno };
  return q;
}
function entradaComMidias(questoes, extras = {}) {
  const midiasVerificadas = new Map();
  const midiasArquivos = new Map();
  for (const bytes of [PNG_A, PNG_B]) {
    midiasVerificadas.set(`midias/${shaDe(bytes)}.png`, shaDe(bytes));
    midiasArquivos.set(shaDe(bytes), bytes);
  }
  return { ...entradaBase(questoes), midiasVerificadas, midiasArquivos, ...extras };
}
function criarStorageMemoria(bucket, { falharEnvio = false } = {}) {
  return {
    enviados: [],
    removidos: [],
    async enviar(path, bytes) {
      if (falharEnvio) throw new Error("Storage: envio falhou (HTTP 500)");
      if (bucket.has(path)) throw new Error("Storage: objeto já existe (x-upsert false)");
      bucket.set(path, Buffer.from(bytes));
      this.enviados.push(path);
    },
    async baixar(path) {
      return bucket.get(path);
    },
    async remover(path) {
      bucket.delete(path);
      this.removidos.push(path);
    },
  };
}

test("MID-A) questão com mídia: objeto enviado ANTES das linhas, questao_midias gravada, pós-check confere bucket e linhas", async () => {
  const repo = criarRepositorioMemoria({ midias: true });
  const storage = criarStorageMemoria(repo.bucket);
  const entrada = entradaComMidias([questaoComMidia(1, [midiaStaging(PNG_A)]), questaoStaging(2)]);
  const plano = await executarAquisicao({ repo, entrada, modo: "dry-run" });
  assert.deepEqual(plano.manifesto.questoes.map((q) => q.acao), ["IMPORTAR", "IMPORTAR"]);
  assert.equal(plano.manifesto.questoes[0].midias[0].sha256, shaDe(PNG_A), "a mídia faz parte do manifesto");
  assert.equal(plano.manifesto.questoes[1].midias, undefined, "questão sem mídia não ganha campo novo no manifesto");
  const r = await executarAquisicao({ repo, entrada, modo: "apply", hashManifestoAprovado: plano.hash, storage });
  assert.equal(r.pos_check.ok, true);
  assert.deepEqual(storage.enviados, [`questoes/${shaDe(PNG_A)}.png`]);
  assert.equal(repo.banco.questao_midias.length, 1);
  assert.deepEqual(
    (({ questao_id, prova_id, ordem, sha256, storage_path, direito_uso, pagina_origem }) => ({ questao_id, prova_id, ordem, sha256, storage_path, direito_uso, pagina_origem }))(repo.banco.questao_midias[0]),
    { questao_id: repo.banco.questoes[0].id, prova_id: 1, ordem: 1, sha256: shaDe(PNG_A), storage_path: `questoes/${shaDe(PNG_A)}.png`, direito_uso: "OFICIAL_PROVA", pagina_origem: 7 },
  );
  assert.equal(repo.locks, 0, "lock de mídias liberado");
});

test("MID-HASH) a mídia participa do hash: outro arquivo = outro manifesto; apply com o manifesto antigo é recusado", async () => {
  const repo = criarRepositorioMemoria({ midias: true });
  const comA = await executarAquisicao({ repo, entrada: entradaComMidias([questaoComMidia(1, [midiaStaging(PNG_A)])]), modo: "dry-run" });
  const comB = entradaComMidias([questaoComMidia(1, [midiaStaging(PNG_B)])]);
  const planoB = await executarAquisicao({ repo, entrada: comB, modo: "dry-run" });
  assert.notEqual(comA.hash, planoB.hash);
  await assert.rejects(() => executarAquisicao({ repo, entrada: comB, modo: "apply", hashManifestoAprovado: comA.hash, storage: criarStorageMemoria(repo.bucket) }), /difere do manifesto aprovado/);
  assert.equal(repo.bucket.size, 0, "nada enviado");
});

test("MID-F) hash divergente: arquivo do staging diferente do registrado -> REVISAR; bytes adulterados no apply -> recusado antes de gravar", async () => {
  const repo = criarRepositorioMemoria({ midias: true });
  const q = questaoComMidia(1, [midiaStaging(PNG_A)]);
  const adulterado = entradaComMidias([q], { midiasVerificadas: new Map([[`midias/${shaDe(PNG_A)}.png`, "f".repeat(64)]]) });
  const plano = await executarAquisicao({ repo, entrada: adulterado, modo: "dry-run" });
  assert.equal(plano.manifesto.questoes[0].acao, "REVISAR");
  assert.ok(plano.manifesto.questoes[0].motivos.some((m) => /hash divergente/.test(m)));

  const entrada = entradaComMidias([q]);
  const aprovado = await executarAquisicao({ repo, entrada, modo: "dry-run" });
  entrada.midiasArquivos.set(shaDe(PNG_A), Buffer.from("bytes trocados depois do dry-run"));
  await assert.rejects(() => executarAquisicao({ repo, entrada, modo: "apply", hashManifestoAprovado: aprovado.hash, storage: criarStorageMemoria(repo.bucket) }), /hash diferente do manifesto/);
  assert.equal(repo.banco.questoes.length, 0);
  assert.equal(repo.bucket.size, 0);
});

test("MID-I) reexecução idempotente; mesma mídia em outra questão reaproveita o objeto (sem reenvio)", async () => {
  const repo = criarRepositorioMemoria({ midias: true });
  const storage = criarStorageMemoria(repo.bucket);
  const entrada = entradaComMidias([questaoComMidia(1, [midiaStaging(PNG_A)])]);
  const plano1 = await executarAquisicao({ repo, entrada, modo: "dry-run" });
  await executarAquisicao({ repo, entrada, modo: "apply", hashManifestoAprovado: plano1.hash, storage });
  assert.equal(repo.banco.questao_midias.length, 1);
  const deNovo = await executarAquisicao({ repo, entrada, modo: "dry-run" });
  assert.equal(deNovo.manifesto.resumo.importar, 0);
  assert.equal(deNovo.manifesto.resumo.ja_importadas, 1);

  const outra = entradaComMidias([questaoComMidia(1, [midiaStaging(PNG_A)]), questaoComMidia(2, [midiaStaging(PNG_A)])]);
  const plano2 = await executarAquisicao({ repo, entrada: outra, modo: "dry-run" });
  const r = await executarAquisicao({ repo, entrada: outra, modo: "apply", hashManifestoAprovado: plano2.hash, storage });
  assert.deepEqual(r.midias.enviadas, []);
  assert.deepEqual(r.midias.reaproveitadas, [`questoes/${shaDe(PNG_A)}.png`]);
  assert.equal(storage.enviados.length, 1, "um único envio no total");
  assert.equal(repo.banco.questao_midias.length, 2);
});

test("MID-J) falha no meio do lote depois do envio: ROLLBACK + remove SÓ o objeto criado nesta execução; objeto pré-existente fica", async () => {
  const bucket = new Map([[`questoes/${shaDe(PNG_B)}.png`, PNG_B]]); // B já estava no bucket (outra questão/lote)
  const repo = criarRepositorioMemoria({ midias: true, bucket, falharNaQuestao: 2 });
  const storage = criarStorageMemoria(bucket);
  const entrada = entradaComMidias([questaoComMidia(1, [midiaStaging(PNG_A)]), questaoComMidia(2, [midiaStaging(PNG_B)])]);
  const plano = await executarAquisicao({ repo, entrada, modo: "dry-run" });
  const erro = await executarAquisicao({ repo, entrada, modo: "apply", hashManifestoAprovado: plano.hash, storage }).catch((e) => e);
  assert.ok(erro instanceof Error && /falha simulada/.test(erro.message));
  assert.equal(repo.banco.questoes.length, 0);
  assert.equal(repo.banco.questao_midias.length, 0);
  assert.deepEqual(storage.removidos, [`questoes/${shaDe(PNG_A)}.png`], "só o objeto criado agora");
  assert.ok(bucket.has(`questoes/${shaDe(PNG_B)}.png`), "pré-existente nunca é apagado");
  assert.equal(repo.locks, 0);
});

test("MID-J2) teste-rollback percorre envio + linhas + pós-check e depois limpa o que criou; envio que falha não grava nada", async () => {
  const repo = criarRepositorioMemoria({ midias: true });
  const storage = criarStorageMemoria(repo.bucket);
  const entrada = entradaComMidias([questaoComMidia(1, [midiaStaging(PNG_A)])]);
  const plano = await executarAquisicao({ repo, entrada, modo: "dry-run" });
  const r = await executarAquisicao({ repo, entrada, modo: "teste-rollback", hashManifestoAprovado: plano.hash, storage });
  assert.equal(r.contagens_na_transacao.depois.questao_midias - r.contagens_na_transacao.antes.questao_midias, 1);
  assert.deepEqual(r.midias.limpeza.removidos, [`questoes/${shaDe(PNG_A)}.png`]);
  assert.equal(repo.bucket.size, 0);
  assert.equal(repo.banco.questoes.length, 0);

  const falhando = criarStorageMemoria(repo.bucket, { falharEnvio: true });
  await assert.rejects(() => executarAquisicao({ repo, entrada, modo: "apply", hashManifestoAprovado: plano.hash, storage: falhando }), /envio falhou/);
  assert.equal(repo.banco.questoes.length, 0);
  assert.equal(repo.locks, 0);
});

test("MID-STORAGE) apply com mídia sem Storage configurado é recusado antes de gravar qualquer coisa", async () => {
  const repo = criarRepositorioMemoria({ midias: true });
  const entrada = entradaComMidias([questaoComMidia(1, [midiaStaging(PNG_A)])]);
  const plano = await executarAquisicao({ repo, entrada, modo: "dry-run" });
  await assert.rejects(() => executarAquisicao({ repo, entrada, modo: "apply", hashManifestoAprovado: plano.hash }), /exige o Storage configurado/);
  assert.equal(repo.banco.provas.length, 0);
});

test("MID-INFRA) banco sem questao_midias/bucket: questão com mídia fica em REVISAR; as sem mídia seguem normalmente", async () => {
  const repo = criarRepositorioMemoria();
  const plano = await executarAquisicao({ repo, entrada: entradaComMidias([questaoComMidia(1, [midiaStaging(PNG_A)]), questaoStaging(2)]), modo: "dry-run" });
  assert.deepEqual(plano.manifesto.questoes.map((q) => q.acao), ["REVISAR", "IMPORTAR"]);
  assert.ok(plano.manifesto.questoes[0].motivos.some((m) => /infraestrutura de mídias ausente/.test(m)));
});

test("MID-M) mídia REVISAO_DIREITOS nunca importa; só decisão explícita (questão + sha + justificativa) libera; decisão malformada bloqueia", async () => {
  const repo = criarRepositorioMemoria({ midias: true });
  const q = () => questaoComMidia(1, [midiaStaging(PNG_A, { direito: "REVISAO_DIREITOS", tipo: "CHARGE" })]);
  const pendente = await executarAquisicao({ repo, entrada: entradaComMidias([q()]), modo: "dry-run" });
  assert.equal(pendente.manifesto.questoes[0].acao, "REVISAR");
  assert.ok(pendente.manifesto.questoes[0].motivos.some((m) => /REVISAO_DIREITOS/.test(m)));

  const decisao = { numero_original: 1, sha256: shaDe(PNG_A), direito_uso: "LICENCIADO", justificativa: "licença de reprodução obtida do autor em contrato" };
  const liberada = await executarAquisicao({ repo, entrada: entradaComMidias([q()], { aprovacao: { direitos_midia: [decisao] } }), modo: "dry-run" });
  assert.equal(liberada.manifesto.questoes[0].acao, "IMPORTAR");
  assert.equal(liberada.manifesto.questoes[0].midias[0].direito_uso, "LICENCIADO");
  assert.notEqual(liberada.hash, pendente.hash, "a decisão entra no hash");

  for (const [ruim, padrao] of [
    [{ ...decisao, direito_uso: "REVISAO_DIREITOS" }, /direito_uso/],
    [{ ...decisao, justificativa: "ok" }, /justificativa/],
    [{ ...decisao, sha256: "x" }, /sha256/],
  ]) {
    const r = await executarAquisicao({ repo, entrada: entradaComMidias([q()], { aprovacao: { direitos_midia: [ruim] } }), modo: "dry-run" });
    assert.ok(r.manifesto.bloqueios.some((b) => padrao.test(b)), String(padrao));
  }
  const semMidia = await executarAquisicao({ repo, entrada: entradaComMidias([q()], { aprovacao: { direitos_midia: [{ ...decisao, sha256: shaDe(PNG_B) }] } }), modo: "dry-run" });
  assert.ok(semMidia.manifesto.questoes[0].motivos.some((m) => /sem mídia correspondente/.test(m)));
});

test("MID-LIB) MIDIA_OK=false: 'mídia sem referência' só passa com liberação explícita; 'mídia ausente' nunca é liberável", async () => {
  const repo = criarRepositorioMemoria({ midias: true });
  const semReferencia = () => questaoComMidia(1, [midiaStaging(PNG_A)], { etapas: { MIDIA_OK: false }, interno: { dependencia_midia: undefined, midias_causas: [{ codigo: "midia_sem_referencia", motivo: "figura sem referência" }] } });
  const bloqueada = await executarAquisicao({ repo, entrada: entradaComMidias([semReferencia()]), modo: "dry-run" });
  assert.equal(bloqueada.manifesto.questoes[0].acao, "REVISAR");
  assert.ok(bloqueada.manifesto.questoes[0].motivos.some((m) => /^MIDIA_OK=false/.test(m)));
  const liberar = { numero_original: 1, gate: "MIDIA_OK", motivo: "midia_sem_referencia", justificativa: "revisão humana: a figura é o diagrama citado pela questão" };
  const liberada = await executarAquisicao({ repo, entrada: entradaComMidias([semReferencia()], { aprovacao: { liberacoes: [liberar] } }), modo: "dry-run" });
  assert.equal(liberada.manifesto.questoes[0].acao, "IMPORTAR");

  const ausente = await executarAquisicao({ repo, entrada: entradaComMidias([questaoStaging(1)], { aprovacao: { liberacoes: [{ ...liberar, motivo: "midia_ausente" }] } }), modo: "dry-run" });
  assert.ok(ausente.manifesto.bloqueios.some((b) => /não é liberável/.test(b)));
});
