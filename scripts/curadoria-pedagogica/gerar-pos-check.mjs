#!/usr/bin/env node
// Gera supabase/pos_check_classificacao_unidades_<slug>.sql — Etapa 5 do
// pipeline (a última que este pipeline v1 automatiza — ver nota sobre
// "não gerar apply automático" no README).
//
// 100% somente leitura (só SELECT), reproduzindo exatamente as 7-8
// consultas já usadas em
// supabase/pos_check_classificacao_unidades_lei_drogas.sql,
// supabase/pos_check_classificacao_unidades_improbidade.sql e
// supabase/pos_check_classificacao_unidades_direitos_garantias_fundamentais.sql.
//
// Deriva os valores esperados de config/<slug>.unidades.json +
// config/<slug>.mapa.json — nenhum número é inventado aqui.
//
// DESDE A V1.1: os 4 totais estruturais da consulta 7 (curso_conteudos,
// unidades_pedagogicas, questoes, alternativas) já não são mais passados
// por flag manual — este script consulta o Supabase AO VIVO no momento da
// geração (única escrita no arquivo gerado continua sendo 0 — a consulta
// ao Supabase aqui é só leitura, feita em tempo de geração, não pelo SQL
// gerado). Precisa de SUPABASE_URL + SUPABASE_SERVICE_ROLE_KEY (ver
// .env.curadoria / env.curadoria.example neste mesmo diretório).
//
// O total de unidades_pedagogicas é ajustado pelo número de unidades NOVAS
// que esta curadoria específica ainda vai criar (unidades com ordem != 1
// em config/<slug>.unidades.json) — a unidade de ordem=1 sempre já existe,
// nunca é criada. Se a curadoria já tiver sido aplicada antes deste script
// rodar, o total lido ao vivo já reflete isso e o ajuste soma 0 a mais
// (idempotente, nunca conta a mesma unidade duas vezes — é só um ajuste
// aditivo sobre o estado já real do banco no momento da consulta).
//
// NUNCA executa SQL de escrita — só SELECT (para os totais) e escreve o
// arquivo .sql local. O próprio arquivo .sql gerado nunca contém nenhuma
// escrita.
//
// Uso: node gerar-pos-check.mjs <slug>

import {
  lerJson,
  escreverSql,
  caminhoConfigUnidades,
  caminhoConfigMapa,
  caminhoPosCheck,
  calcularDerivados,
  criarClienteSupabaseSomenteLeitura,
  consultarTotaisSistema,
} from "./lib/comum.mjs";

const slug = process.argv[2];
if (!slug) {
  console.error("Uso: node gerar-pos-check.mjs <slug>");
  process.exit(1);
}

async function main() {
  const configUnidades = lerJson(caminhoConfigUnidades(slug));
  const configMapa = lerJson(caminhoConfigMapa(slug));
  const derivados = calcularDerivados(configUnidades, configMapa);

  const conteudoId = configUnidades.curso_conteudo_id;
  const materiaId = configUnidades.materia_id;
  const assuntoId = configMapa.assunto_id;
  const excluidas = configMapa.questoes_excluidas || [];

  const supabase = await criarClienteSupabaseSomenteLeitura();
  const totaisAoVivo = await consultarTotaisSistema(supabase);

  // Quantas unidades desta curadoria ainda NÃO existem no banco agora —
  // se a curadoria já foi aplicada antes de rodar este script, isso dá 0
  // (idempotente); se ainda não foi aplicada, soma as unidades extras
  // (ordem != 1) que curadoria_unidades_<slug>.sql vai criar.
  const unidadesJaExistentes = new Set(
    (await supabase
      .from("unidades_pedagogicas")
      .select("id")
      .in(
        "id",
        configUnidades.unidades.map((u) => u.id)
      )
    ).data?.map((u) => u.id) ?? []
  );
  const unidadesAindaNaoCriadas = configUnidades.unidades.filter((u) => !unidadesJaExistentes.has(u.id)).length;

  const totalUnidadesEsperado = totaisAoVivo.totalUnidadesSistema + unidadesAindaNaoCriadas;

  const linhasContagemEsperada = derivados.contagemPorUnidade
    .map((u) => `--    ordem ${u.ordem} (${u.titulo}) = ${u.qtd_questoes}`)
    .join("\n");

  const linhaMultiunidade =
    derivados.multiunidade.length > 0
      ? `apenas a(s) questao(oes) ${derivados.multiunidade.join(", ")}`
      : derivados.unidades.length === 1
      ? "nenhuma (impossivel com 1 unica unidade)"
      : "nenhuma";

  const notaExcluidas =
    excluidas.length > 0
      ? `-- 8) Notas de saneamento pendente (nao verificadas por esta consulta, so
--    documentadas): ${excluidas.map((e) => `questao ${e.questao_id} (${e.motivo})`).join("; ")}.
--    Nenhuma delas e um erro deste pos-check — sao saneamentos de banco de
--    questoes adiados para etapa separada.
`
      : "";

  const consultaSemClassificacao =
    excluidas.length > 0
      ? `-- 5) Questoes ativas do conteudo que ficaram SEM nenhuma classificacao.
--    Esperado: exatamente ${excluidas.length} linha(s) — ${excluidas
          .map((e) => `a questao ${e.questao_id}`)
          .join(", ")} (excluida(s) de proposito, ver mapa_classificacao_${slug}.sql).`
      : `-- 5) Questoes ativas do conteudo que ficaram SEM nenhuma classificacao.
--    Esperado: 0 linhas.`;

  const sql = `-- Pos-check SOMENTE LEITURA da classificacao de questoes de ${configUnidades.nome_assunto}
-- (curso_conteudos.id = ${conteudoId}) — gerado pelo pipeline automatico
-- (scripts/curadoria-pedagogica/gerar-pos-check.mjs) em ${new Date().toISOString()}.
-- A rodar depois de classificar_questoes_unidades_${slug}.sql (a versao que
-- termina em COMMIT, escrita/revisada a parte — ver README deste pipeline)
-- ter sido aplicada de fato.
--
-- Nenhuma escrita. Cada consulta abaixo tem o valor esperado indicado no
-- comentario; qualquer divergencia deve ser reportada, nao corrigida aqui.

-- 1) A(s) ${derivados.unidades.length} unidade(s) pedagogica(s) do conteudo ${conteudoId}, com
--    titulo/escopo/artigos aplicados pela curadoria. Esperado: ${derivados.unidades.length} linha(s),
--    ordem ${derivados.unidades.map((u) => u.ordem).join("/")}, todas ativas.
select id, ordem, titulo, escopo, artigos_esperados, ativa
from public.unidades_pedagogicas
where curso_conteudo_id = ${conteudoId}
order by ordem;

-- 2) Contagem de questoes classificadas por unidade. Esperado:
${linhasContagemEsperada}
select u.ordem, u.titulo, count(distinct qup.questao_id) as questoes_classificadas
from public.unidades_pedagogicas u
left join public.questao_unidades_pedagogicas qup on qup.unidade_pedagogica_id = u.id
where u.curso_conteudo_id = ${conteudoId}
group by u.ordem, u.titulo
order by u.ordem;

-- 3) Total de vinculos e questoes distintas classificadas no conteudo.
--    Esperado: total_vinculos = ${derivados.totalVinculos}, questoes_distintas = ${derivados.questoesDistintas}.
select count(*) as total_vinculos, count(distinct qup.questao_id) as questoes_distintas
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = ${conteudoId};

-- 4) Questoes multiunidade (vinculadas a mais de uma unidade do conteudo).
--    Esperado: ${linhaMultiunidade}.
select qup.questao_id, array_agg(u.ordem order by u.ordem) as unidades
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
where u.curso_conteudo_id = ${conteudoId}
group by qup.questao_id
having count(*) > 1;

${consultaSemClassificacao}
select q.id, q.enunciado
from public.questoes q
where q.ativa = true
  and q.materia_id = ${materiaId}
  and q.assunto_id = ${assuntoId}
  and not exists (
    select 1
    from public.questao_unidades_pedagogicas qup
    join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
    where qup.questao_id = q.id and u.curso_conteudo_id = ${conteudoId}
  );

-- 6) Confirma que nenhuma classificacao vazou de/para outro conteudo —
--    todo vinculo de uma unidade do conteudo ${conteudoId} aponta para questao
--    com materia_id/assunto_id compativeis (a trigger
--    validar_questao_unidade_pedagogica ja impede isso na escrita; aqui e
--    so confirmacao). Esperado: 0 linhas.
select qup.questao_id, qup.unidade_pedagogica_id
from public.questao_unidades_pedagogicas qup
join public.unidades_pedagogicas u on u.id = qup.unidade_pedagogica_id
join public.curso_conteudos cc on cc.id = u.curso_conteudo_id
join public.curso_materias cm on cm.id = cc.curso_materia_id
join public.questoes q on q.id = qup.questao_id
where u.curso_conteudo_id = ${conteudoId}
  and (q.materia_id <> cm.materia_id or (cc.assunto_id is not null and q.assunto_id <> cc.assunto_id));

-- 7) Estado geral de outras tabelas nao deveria ter mudado por esta
--    operacao. Totais consultados AO VIVO no momento da geracao deste
--    arquivo (${new Date().toISOString()}), com unidades_pedagogicas ja
--    ajustado por ${unidadesAindaNaoCriadas} unidade(s) que esta curadoria
--    ainda vai criar (0 se a curadoria ja tiver sido aplicada antes desta
--    geracao): curso_conteudos=${totaisAoVivo.totalConteudos},
--    unidades_pedagogicas=${totalUnidadesEsperado} (ao vivo: ${totaisAoVivo.totalUnidadesSistema}),
--    questoes=${totaisAoVivo.totalQuestoesSistema}, alternativas=${totaisAoVivo.totalAlternativasSistema}.
--    Se muito tempo se passar entre esta geracao e a aplicacao real, revalide
--    contra o banco antes de confiar cegamente nestes numeros.
select
  (select count(*) from public.curso_conteudos) as total_conteudos,
  (select count(*) from public.unidades_pedagogicas) as total_unidades_sistema,
  (select count(*) from public.questoes) as total_questoes_sistema,
  (select count(*) from public.alternativas) as total_alternativas_sistema;

${notaExcluidas}`;

  escreverSql(caminhoPosCheck(slug), sql);
  console.log(`Gerado: supabase/pos_check_classificacao_unidades_${slug}.sql`);
  console.log(
    `Totais consultados ao vivo: curso_conteudos=${totaisAoVivo.totalConteudos}, unidades_pedagogicas=${totaisAoVivo.totalUnidadesSistema} (esperado apos curadoria: ${totalUnidadesEsperado}), questoes=${totaisAoVivo.totalQuestoesSistema}, alternativas=${totaisAoVivo.totalAlternativasSistema}.`
  );
}

main().catch((erro) => {
  console.error("Falha ao gerar pos-check:", erro.message);
  process.exit(1);
});
