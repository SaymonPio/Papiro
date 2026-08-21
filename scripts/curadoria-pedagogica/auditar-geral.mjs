#!/usr/bin/env node
// Auditoria geral, somente leitura, de toda a fila de curadoria pedagógica
// (config/ordem-curadoria.json) — complementa auditar-conteudo.mjs (que
// audita 1 conteúdo por vez) com uma visão agregada de todos os 93.
//
// Uso: node auditar-geral.mjs
//
// Saída: relatorios/relatorio_curadoria_geral.json
//
// Validações aplicadas antes de consultar o banco (ver
// lib/comum.mjs#validarOrdemCuradoria): curso_conteudo_id duplicado, ordem
// duplicada e status inválido interrompem a execução com erro. Depois de
// consultar o banco, qualquer curso_conteudo_id da fila que não exista de
// fato em public.curso_conteudos TAMBÉM interrompe a execução com erro
// ("conteúdo inexistente") — nunca é ignorado silenciosamente.
//
// NUNCA escreve no banco — só SELECT, em lotes (nunca 1 consulta por
// conteúdo), via criarClienteSupabaseSomenteLeitura (precisa de
// SUPABASE_URL + SUPABASE_SERVICE_ROLE_KEY — ver .env.curadoria).

import {
  lerJson,
  escreverJson,
  caminhoOrdemCuradoria,
  caminhoRelatorioGeral,
  validarOrdemCuradoria,
  criarClienteSupabaseSomenteLeitura,
} from "./lib/comum.mjs";

async function main() {
  const fila = lerJson(caminhoOrdemCuradoria());
  validarOrdemCuradoria(fila);

  const supabase = await criarClienteSupabaseSomenteLeitura();

  const ids = fila.map((item) => item.curso_conteudo_id);

  const { data: conteudosReais, error: erroConteudos } = await supabase
    .from("curso_conteudos")
    .select("id, assunto_id")
    .in("id", ids);
  if (erroConteudos) throw erroConteudos;

  const conteudoPorId = new Map(conteudosReais.map((c) => [c.id, c]));
  const idsInexistentes = ids.filter((id) => !conteudoPorId.has(id));
  if (idsInexistentes.length > 0) {
    throw new Error(
      `Conteudo(s) inexistente(s) em public.curso_conteudos, mas listado(s) em config/ordem-curadoria.json: ${idsInexistentes.join(", ")}`
    );
  }

  const assuntoIds = [...new Set(conteudosReais.map((c) => c.assunto_id))];

  const { data: questoesAtivas, error: erroQuestoes } = await supabase
    .from("questoes")
    .select("id, assunto_id")
    .in("assunto_id", assuntoIds)
    .eq("ativa", true);
  if (erroQuestoes) throw erroQuestoes;

  const questoesPorAssunto = new Map();
  for (const q of questoesAtivas) {
    questoesPorAssunto.set(q.assunto_id, (questoesPorAssunto.get(q.assunto_id) ?? 0) + 1);
  }

  const { data: unidades, error: erroUnidades } = await supabase
    .from("unidades_pedagogicas")
    .select("id, curso_conteudo_id")
    .in("curso_conteudo_id", ids);
  if (erroUnidades) throw erroUnidades;

  const unidadesPorConteudo = new Map();
  const conteudoPorUnidadeId = new Map();
  for (const u of unidades) {
    if (!unidadesPorConteudo.has(u.curso_conteudo_id)) unidadesPorConteudo.set(u.curso_conteudo_id, []);
    unidadesPorConteudo.get(u.curso_conteudo_id).push(u.id);
    conteudoPorUnidadeId.set(u.id, u.curso_conteudo_id);
  }

  const todosOsIdsDeUnidade = unidades.map((u) => u.id);
  let classificacoesPorConteudo = new Map();
  if (todosOsIdsDeUnidade.length > 0) {
    const { data: vinculos, error: erroVinculos } = await supabase
      .from("questao_unidades_pedagogicas")
      .select("questao_id, unidade_pedagogica_id")
      .in("unidade_pedagogica_id", todosOsIdsDeUnidade);
    if (erroVinculos) throw erroVinculos;

    const questoesDistintasPorConteudo = new Map();
    for (const v of vinculos) {
      const conteudoId = conteudoPorUnidadeId.get(v.unidade_pedagogica_id);
      if (!questoesDistintasPorConteudo.has(conteudoId)) questoesDistintasPorConteudo.set(conteudoId, new Set());
      questoesDistintasPorConteudo.get(conteudoId).add(v.questao_id);
    }
    classificacoesPorConteudo = new Map([...questoesDistintasPorConteudo].map(([k, v]) => [k, v.size]));
  }

  const conteudosDetalhados = fila.map((item) => {
    const real = conteudoPorId.get(item.curso_conteudo_id);
    return {
      curso_conteudo_id: item.curso_conteudo_id,
      nome: item.nome,
      materia: item.materia,
      status: item.status,
      prioridade: item.prioridade,
      questoes_ativas: questoesPorAssunto.get(real.assunto_id) ?? 0,
      unidades_pedagogicas: (unidadesPorConteudo.get(item.curso_conteudo_id) ?? []).length,
      questoes_classificadas: classificacoesPorConteudo.get(item.curso_conteudo_id) ?? 0,
    };
  });

  const totalConteudos = fila.length;
  const concluidos = fila.filter((i) => i.status === "concluido").length;
  const pendentes = fila.filter((i) => i.status === "pendente").length;
  const percentualConclusao = Number(((concluidos / totalConteudos) * 100).toFixed(1));

  const relatorio = {
    curso: "Brigada Militar RS",
    gerado_em: new Date().toISOString(),
    total_conteudos: totalConteudos,
    concluidos,
    pendentes,
    percentual_conclusao: percentualConclusao,
    conteudos: conteudosDetalhados,
  };

  escreverJson(caminhoRelatorioGeral(), relatorio);

  console.log(`Relatorio geral salvo em: relatorios/relatorio_curadoria_geral.json`);
  console.log(`Total: ${totalConteudos} | Concluidos: ${concluidos} | Pendentes: ${pendentes} | Progresso: ${percentualConclusao}%`);
}

main().catch((erro) => {
  console.error("Falha na auditoria geral:", erro.message);
  process.exit(1);
});
