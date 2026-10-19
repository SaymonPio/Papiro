#!/usr/bin/env node
// Saneamento de quebras de linha artificiais nos ENUNCIADOS de uma prova
// já importada (lib/quebrasDeLinha.mjs — mesma regra que a normalização
// aplica aos lotes novos). Só o enunciado muda, e só em espaço em branco:
// alternativas, gabarito, matéria, assunto, prova_id, numero_original e
// vínculos ficam intactos (conferido no pós-check, dentro da transação).
//
// Uso:
//   node scripts/importador-provas/sanear-quebras.mjs --prova-id <id>            (dry-run: READ ONLY)
//   node scripts/importador-provas/sanear-quebras.mjs --prova-id <id> --apply    (grava numa transação)
//
// Qualquer mudança que não seja só espaço em branco, ou qualquer falha no
// pós-check: nada é gravado (ROLLBACK).

import { createHash } from "node:crypto";
import { carregarEnvCuradoria } from "../curadoria-pedagogica/lib/comum.mjs";
import { juntarQuebrasArtificiais, soMudouEspacoEmBranco } from "./lib/quebrasDeLinha.mjs";

function lerArgumentos(argv) {
  const args = {};
  for (let i = 0; i < argv.length; i++) {
    if (!argv[i].startsWith("--")) continue;
    const valor = argv[i + 1] && !argv[i + 1].startsWith("--") ? argv[i + 1] : true;
    args[argv[i].slice(2)] = valor;
    if (valor !== true) i++;
  }
  return args;
}

async function lerEstado(client, provaId, { travar }) {
  const { rows: questoes } = await client.query(
    `select id, numero_original, prova_id, materia_id, assunto_id, usuario_id, ativa, enunciado from public.questoes
      where prova_id = $1 order by numero_original ${travar ? "for update" : ""}`,
    [provaId],
  );
  const ids = questoes.map((q) => q.id);
  const { rows: alternativas } = await client.query(
    "select id, questao_id, ordem, texto, correta from public.alternativas where questao_id = any($1::bigint[]) order by questao_id, ordem",
    [ids],
  );
  const { rows: vinculos } = await client.query("select curso_id, questao_id from public.curso_questoes where questao_id = any($1::bigint[]) order by 1, 2", [ids]);
  const { rows: [totais] } = await client.query(
    `select (select count(*) from public.questoes)::int questoes, (select count(*) from public.alternativas)::int alternativas,
            (select count(*) from public.curso_questoes)::int curso_questoes, (select count(*) from public.provas)::int provas,
            (select count(*) from public.prova_documentos)::int prova_documentos`,
  );
  return { questoes, alternativas, vinculos, totais };
}

// Tudo o que NÃO pode mudar, num hash só.
function assinaturaInvariante(estado) {
  const dados = {
    questoes: estado.questoes.map(({ enunciado, ...resto }) => ({ ...resto, id: String(resto.id), prova_id: String(resto.prova_id), materia_id: String(resto.materia_id), assunto_id: String(resto.assunto_id) })),
    alternativas: estado.alternativas.map((a) => ({ ...a, id: String(a.id), questao_id: String(a.questao_id) })),
    vinculos: estado.vinculos.map((v) => ({ curso_id: v.curso_id, questao_id: String(v.questao_id) })),
    totais: estado.totais,
  };
  return createHash("sha256").update(JSON.stringify(dados)).digest("hex");
}

async function main() {
  const args = lerArgumentos(process.argv.slice(2));
  const provaId = Number(args["prova-id"]);
  if (!Number.isInteger(provaId) || provaId < 1) throw new Error("informe --prova-id <id>");
  const aplicar = args.apply === true;

  carregarEnvCuradoria();
  const connectionString = process.env.SUPABASE_DB_URL || process.env.DATABASE_URL;
  if (!connectionString) throw new Error("defina SUPABASE_DB_URL em scripts/curadoria-pedagogica/.env.curadoria");
  const { default: pg } = await import("pg");
  const client = new pg.Client({ connectionString });
  await client.connect();

  try {
    await client.query(aplicar ? "begin" : "begin transaction read only");
    const antes = await lerEstado(client, provaId, { travar: aplicar });
    if (antes.questoes.length === 0) throw new Error(`nenhuma questão com prova_id=${provaId}`);

    const plano = [];
    for (const q of antes.questoes) {
      const novo = juntarQuebrasArtificiais(q.enunciado);
      if (novo === q.enunciado) continue;
      if (!soMudouEspacoEmBranco(q.enunciado, novo)) throw new Error(`questão ${q.id} (nº ${q.numero_original}): mudança além de espaço em branco — saneamento recusado inteiro`);
      plano.push({ id: q.id, numero_original: q.numero_original, antes: q.enunciado, depois: novo, linhas: [q.enunciado.split("\n").length, novo.split("\n").length] });
    }

    console.log(`prova_id=${provaId}: ${antes.questoes.length} questões, ${plano.length} com quebras artificiais`);
    for (const p of plano) console.log(`  nº ${p.numero_original} (id ${p.id}): ${p.linhas[0]} -> ${p.linhas[1]} linhas`);

    if (!aplicar || plano.length === 0) {
      await client.query("rollback");
      console.log(aplicar ? "nada a gravar" : "DRY-RUN — nada gravado");
      return;
    }

    const invarianteAntes = assinaturaInvariante(antes);
    for (const p of plano) await client.query("update public.questoes set enunciado = $1 where id = $2 and prova_id = $3", [p.depois, p.id, provaId]);
    const depois = await lerEstado(client, provaId, { travar: false });

    const falhas = [];
    if (assinaturaInvariante(depois) !== invarianteAntes) falhas.push("ids/numero_original/prova_id/matéria/assunto/alternativas/gabaritos/vínculos/totais mudaram");
    for (const q of depois.questoes) {
      const original = antes.questoes.find((x) => x.id === q.id);
      const esperado = plano.find((p) => p.id === q.id)?.depois ?? original.enunciado;
      if (q.enunciado !== esperado) falhas.push(`questão ${q.id}: enunciado gravado diferente do planejado`);
      if (!soMudouEspacoEmBranco(original.enunciado, q.enunciado)) falhas.push(`questão ${q.id}: mudança além de espaço em branco`);
    }
    if (falhas.length > 0) {
      await client.query("rollback");
      throw new Error(`pós-check falhou — ROLLBACK: ${falhas.join("; ")}`);
    }
    await client.query("commit");
    console.log(`APPLY — COMMIT: ${plano.length} enunciados saneados; pós-check OK (invariantes ${invarianteAntes.slice(0, 12)}… preservadas)`);
  } catch (erro) {
    await client.query("rollback").catch(() => {});
    throw erro;
  } finally {
    await client.end();
  }
}

main().catch((erro) => {
  console.error(`BLOQUEADO: ${erro.message}`);
  process.exitCode = 1;
});
