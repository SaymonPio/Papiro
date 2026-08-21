#!/usr/bin/env node
// Validação final da estrutura gerada para um slug — Etapa 6 do pipeline.
//
// NÃO toca o Supabase. Só confere, no sistema de arquivos local:
//   - os 4 arquivos SQL esperados existem, com o nome exato da convenção
//     já usada nas 4 curadorias concluídas;
//   - nenhum arquivo "proibido" foi gerado (a versão de apply real que
//     termina em COMMIT — ver README: este pipeline v1 não gera esse
//     arquivo automaticamente, e não deveria aparecer sozinho);
//   - consistência entre config/<slug>.unidades.json e
//     config/<slug>.mapa.json (todo unidade_id referenciado no mapa existe
//     nas unidades; toda unidade tem pelo menos 1 questão, exceto se isso
//     for esperado);
//   - consistência entre o conteúdo dos arquivos .sql gerados e os números
//     derivados da configuração (grep simples pelos totais esperados).
//
// Uso: node validar-pipeline.mjs <slug>

import fs from "node:fs";
import {
  lerJson,
  caminhoConfigUnidades,
  caminhoConfigMapa,
  caminhoCuradoria,
  caminhoMapa,
  caminhoTesteRollback,
  caminhoPosCheck,
  caminhoApply,
  calcularDerivados,
  DIR_SUPABASE,
} from "./lib/comum.mjs";

const slug = process.argv[2];
if (!slug) {
  console.error("Uso: node validar-pipeline.mjs <slug>");
  process.exit(1);
}

const problemas = [];
const avisos = [];

function verificar(condicao, mensagem) {
  if (!condicao) problemas.push(mensagem);
}

// 1) Arquivos esperados existem, com o nome exato da convenção.
const esperados = {
  curadoria: caminhoCuradoria(slug),
  mapa: caminhoMapa(slug),
  testeRollback: caminhoTesteRollback(slug),
  posCheck: caminhoPosCheck(slug),
};

for (const [nome, caminho] of Object.entries(esperados)) {
  verificar(fs.existsSync(caminho), `Arquivo esperado ausente (${nome}): ${caminho}`);
}

// 2) Arquivo proibido nesta etapa: a versão de apply real (COMMIT) não é
// gerada por este pipeline v1 — se existir, precisa ter sido escrita à
// parte (revisão humana), nunca pelo pipeline automático. Isto NÃO é um
// erro por si só (o arquivo real de apply é esperado eventualmente, só não
// vem deste conjunto de scripts) — é só um aviso para conferência manual.
if (fs.existsSync(caminhoApply(slug))) {
  avisos.push(
    `supabase/classificar_questoes_unidades_${slug}.sql já existe — confirme que foi revisado por humano (este pipeline v1 nunca gera esse arquivo sozinho).`
  );
} else {
  avisos.push(
    `supabase/classificar_questoes_unidades_${slug}.sql ainda não existe — é esperado que só seja criado depois que o teste rollback for aprovado manualmente (ver README).`
  );
}

// 3) Nenhum outro arquivo de curadoria não relacionado a este slug foi
// criado/tocado por engano nesta rodada (checagem grosseira: lista tudo em
// supabase/ que contenha o slug e reporta para conferência visual).
const arquivosDoSlug = fs
  .readdirSync(DIR_SUPABASE)
  .filter((nome) => nome.includes(slug))
  .sort();

// 4) Consistência entre unidades.json e mapa.json.
let derivados = null;
try {
  const configUnidades = lerJson(caminhoConfigUnidades(slug));
  const configMapa = lerJson(caminhoConfigMapa(slug));
  derivados = calcularDerivados(configUnidades, configMapa);

  for (const u of derivados.contagemPorUnidade) {
    if (u.qtd_questoes === 0) {
      avisos.push(`Unidade ordem=${u.ordem} ("${u.titulo}") ficaria com 0 questões classificadas — confirme se é intencional.`);
    }
  }

  const totalCandidatas = configMapa.total_candidatas_ativas;
  const excluidas = (configMapa.questoes_excluidas || []).length;
  verificar(
    derivados.questoesDistintas + excluidas === totalCandidatas,
    `Inconsistência aritmética: questões classificadas (${derivados.questoesDistintas}) + excluídas (${excluidas}) deveria somar total_candidatas_ativas (${totalCandidatas}), mas não soma.`
  );
} catch (erro) {
  problemas.push(`Falha ao carregar/derivar config/${slug}.*.json: ${erro.message}`);
}

// 5) Consistência entre os números derivados e o que foi de fato escrito
// no arquivo de teste rollback gerado (checagem textual simples, não um
// parser SQL — só confirma que o arquivo não ficou desatualizado em
// relação ao mapa.json mais recente).
if (derivados && fs.existsSync(esperados.testeRollback)) {
  const conteudoRollback = fs.readFileSync(esperados.testeRollback, "utf8");
  verificar(
    conteudoRollback.includes(`total_vinculos_${derivados.totalVinculos}`),
    `classificar_questoes_unidades_${slug}_teste_rollback.sql não contém a checagem total_vinculos_${derivados.totalVinculos} esperada — arquivo pode estar desatualizado em relação ao mapa.json atual.`
  );
  verificar(
    conteudoRollback.trim().endsWith("rollback;"),
    `classificar_questoes_unidades_${slug}_teste_rollback.sql não termina em "rollback;" — verificação de segurança falhou.`
  );
}

// 6) Relatório final.
console.log(`Validação do pipeline para slug="${slug}"`);
console.log(`Arquivos relacionados encontrados em supabase/: ${arquivosDoSlug.join(", ") || "(nenhum)"}`);
console.log("");

if (avisos.length > 0) {
  console.log("Avisos (não bloqueiam, mas merecem atenção):");
  for (const a of avisos) console.log(` - ${a}`);
  console.log("");
}

if (problemas.length === 0) {
  console.log("RESULTADO: nenhum problema encontrado.");
  process.exit(0);
} else {
  console.log(`RESULTADO: ${problemas.length} problema(s) encontrado(s):`);
  for (const p of problemas) console.log(` - ${p}`);
  process.exit(1);
}
