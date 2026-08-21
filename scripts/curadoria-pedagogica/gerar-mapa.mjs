#!/usr/bin/env node
// Gera supabase/mapa_classificacao_<slug>.sql — Etapa 3 do pipeline.
//
// NUNCA classifica questão nenhuma sozinho: lê o mapa já decidido em
// config/<slug>.mapa.json, produto obrigatório da leitura humana do
// enunciado + TODAS as alternativas de cada questão candidata (ver
// docs/REGRAS_CURADORIA_PAPIRO.md, seção 4) — nunca por ID, banca,
// concurso ou palavra-chave isolada. Este script só formata essa decisão
// já tomada no formato SQL somente-leitura já usado em
// supabase/mapa_classificacao_lei_drogas.sql,
// supabase/mapa_classificacao_improbidade.sql e
// supabase/mapa_classificacao_unidades_direitos_garantias_fundamentais.sql.
//
// O arquivo gerado nunca escreve nada — é a fonte de verdade que
// gerar-rollback.mjs e o apply real devem replicar.
//
// Uso: node gerar-mapa.mjs <slug>

import {
  lerJson,
  escreverSql,
  caminhoConfigUnidades,
  caminhoConfigMapa,
  caminhoMapa,
  escaparSql,
  calcularDerivados,
} from "./lib/comum.mjs";

const slug = process.argv[2];
if (!slug) {
  console.error("Uso: node gerar-mapa.mjs <slug>");
  process.exit(1);
}

// Formato esperado de config/<slug>.mapa.json (ver
// config/lei_drogas.mapa.json para um exemplo real já aplicado):
// {
//   "total_candidatas_ativas": 16,
//   "questoes_excluidas": [ { "questao_id": 674, "motivo": "..." } ],
//   "vinculos": [
//     { "questao_id": 143, "unidade_id": "uuid", "ordem_unidade": 1,
//       "tema": "...", "justificativa": "...", "confianca": "alta" }
//   ]
// }

const configUnidades = lerJson(caminhoConfigUnidades(slug));
const configMapa = lerJson(caminhoConfigMapa(slug));

function validarMapa(cfgMapa, cfgUnidades) {
  const erros = [];
  if (!Number.isInteger(cfgMapa.total_candidatas_ativas)) erros.push("total_candidatas_ativas ausente/invalido");
  if (!Array.isArray(cfgMapa.vinculos) || cfgMapa.vinculos.length === 0) erros.push("vinculos ausente ou vazio");
  const idsUnidades = new Set(cfgUnidades.unidades.map((u) => u.id));
  for (const v of cfgMapa.vinculos || []) {
    if (!Number.isInteger(v.questao_id)) erros.push(`vinculo com questao_id invalido: ${JSON.stringify(v)}`);
    if (!idsUnidades.has(v.unidade_id)) erros.push(`vinculo aponta unidade_id ${v.unidade_id}, que nao esta em config/${slug}.unidades.json`);
    if (!v.justificativa) erros.push(`vinculo questao_id=${v.questao_id} sem justificativa`);
    if (!v.confianca) erros.push(`vinculo questao_id=${v.questao_id} sem confianca (alta/media)`);
  }
  for (const excl of cfgMapa.questoes_excluidas || []) {
    if (!excl.motivo) erros.push(`questao excluida ${excl.questao_id} sem motivo documentado`);
    if ((cfgMapa.vinculos || []).some((v) => v.questao_id === excl.questao_id)) {
      erros.push(`questao_id ${excl.questao_id} esta em questoes_excluidas E em vinculos ao mesmo tempo`);
    }
  }
  if (erros.length > 0) {
    throw new Error(`config/${slug}.mapa.json invalido:\n - ${erros.join("\n - ")}`);
  }
}

validarMapa(configMapa, configUnidades);

const derivados = calcularDerivados(configUnidades, configMapa);

const unidadesPorId = new Map(configUnidades.unidades.map((u) => [u.id, u]));
const listaUnidadesOficiais = derivados.unidades
  .map((u) => `--   U${u.ordem} ${u.id}  ordem ${u.ordem}  ${u.titulo}`)
  .join("\n");

const linhasMapa = [...configMapa.vinculos]
  .sort((a, b) => a.questao_id - b.questao_id || a.ordem_unidade - b.ordem_unidade)
  .map((v, indice, arr) => {
    const virgula = indice === arr.length - 1 ? "" : ",";
    return `    (${v.questao_id}, ${escaparSql(v.unidade_id)}::uuid, ${v.ordem_unidade}, ${escaparSql(v.tema || "")}, ${escaparSql(
      v.justificativa
    )}, ${escaparSql(v.confianca)})${virgula}`;
  })
  .join("\n");

const listaClassificadas = [...new Set(configMapa.vinculos.map((v) => v.questao_id))].sort((a, b) => a - b).join(",");
const listaMultiunidade = derivados.multiunidade.length > 0 ? derivados.multiunidade.join(", ") : "nenhuma";
const listaExcluidas =
  (configMapa.questoes_excluidas || []).length > 0
    ? configMapa.questoes_excluidas.map((e) => `${e.questao_id} (${e.motivo})`).join("; ")
    : "nenhuma";

const coberturaPorUnidade = derivados.contagemPorUnidade
  .map((u) => `-- U${u.ordem} ${u.titulo}: ${u.qtd_questoes} questoes distintas`)
  .join("\n");

const sql = `-- Mapa de classificacao semantica das questoes validas de ${configUnidades.nome_assunto}
-- (curso_conteudos.id = ${configUnidades.curso_conteudo_id}, assunto_id = ${configMapa.assunto_id ?? "?"},
-- materia_id = ${configUnidades.materia_id}), gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-mapa.mjs) a partir de
-- config/${slug}.mapa.json — produto de leitura humana do enunciado + TODAS
-- as alternativas de cada questao (nunca por ID, banca, concurso ou
-- palavra-chave isolada). Mesmo metodo de
-- supabase/mapa_classificacao_improbidade.sql.
--
-- SOMENTE LEITURA. Este arquivo nao escreve nada — e a fonte unica de
-- verdade (mapa aprovado) que
--   classificar_questoes_unidades_${slug}_teste_rollback.sql
--   classificar_questoes_unidades_${slug}.sql
-- devem replicar byte a byte na tabela temporaria _mapa antes de aplicar.
--
-- Unidades oficiais do conteudo ${configUnidades.curso_conteudo_id} (apos curadoria_unidades_${slug}.sql):
${listaUnidadesOficiais}
--
-- Resultado da curadoria: ${derivados.questoesDistintas}/${configMapa.total_candidatas_ativas} questoes ativas
-- classificadas, multiunidade: ${listaMultiunidade}, excluidas: ${listaExcluidas}.

-- ============================================================================
-- 1) MAPA — uma linha por vinculo (questao multiunidade = mais de uma linha).
-- ============================================================================
with mapa (questao_id, unidade_pedagogica_id, ordem_unidade, tema, justificativa, confianca) as (
  values
${linhasMapa}
)
select * from mapa order by questao_id, ordem_unidade;

-- ============================================================================
-- 2) LISTAS EXPLICITAS.
-- ============================================================================

-- 2a) Questoes classificadas (${derivados.questoesDistintas}/${configMapa.total_candidatas_ativas}).
-- ${listaClassificadas}

-- 2b) Questoes multiunidade: ${listaMultiunidade}

-- 2c) Questoes excluidas intencionalmente (fora de escopo/pendente de saneamento): ${listaExcluidas}

-- ============================================================================
-- 3) Cobertura por unidade (questoes distintas). NAO forca nenhuma unidade
--    a atingir 10; unidades fracas sao GAP REAL DO BANCO, nao erro tecnico.
-- ============================================================================
${coberturaPorUnidade}
-- Total de vinculos esperados: ${derivados.totalVinculos} (${derivados.questoesDistintas} questoes distintas
-- + ${derivados.totalVinculos - derivados.questoesDistintas} vinculo(s) extra(s) de multiunidade).
`;

escreverSql(caminhoMapa(slug), sql);
console.log(`Gerado: supabase/mapa_classificacao_${slug}.sql`);
console.log(`Questoes distintas: ${derivados.questoesDistintas} | Vinculos: ${derivados.totalVinculos} | Multiunidade: ${listaMultiunidade}`);
