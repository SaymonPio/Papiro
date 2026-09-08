// Camada de acesso a dados (Fase 2A). E a UNICA parte deste modulo novo
// que fala com o Supabase — sempre so leitura (SELECT), nunca
// INSERT/UPDATE/DELETE/RPC de escrita, em qualquer um dos dois canais
// abaixo.
//
// Dois canais de credencial existem hoje neste projeto (Fase 1, Secao 7):
//   1. SUPABASE_URL + SUPABASE_SERVICE_ROLE_KEY -> REST via
//      @supabase/supabase-js, usado por criarClienteSupabaseSomenteLeitura
//      (scripts/curadoria-pedagogica/lib/comum.mjs) — canal PREFERIDO e
//      documentado pelo mandato desta fase.
//   2. SUPABASE_DB_URL -> Postgres direto via `pg`, o mesmo canal que
//      executar-sql.mjs usa (e que esta sessao inteira de curadoria
//      manual usou). Neste ambiente especifico, .env.curadoria so tem
//      SUPABASE_DB_URL configurado (SUPABASE_URL/SERVICE_ROLE_KEY estao
//      comentados) — por isso este modulo tenta o canal 1 primeiro e cai
//      para o canal 2 automaticamente, documentando qual foi usado.
//
// Retorna sempre arrays simples (linhas cruas), para que toda a logica de
// negocio fique em coverage-scanner.mjs/eligibility.mjs/banca-resolver.mjs
// — puros, testaveis sem rede.

import { carregarEnvCuradoria, criarClienteSupabaseSomenteLeitura } from "../../curadoria-pedagogica/lib/comum.mjs";

const TAMANHO_PAGINA = 1000;

/**
 * Busca TODAS as linhas de uma tabela, paginando em blocos de 1000 (limite
 * padrao do PostgREST) — necessario porque `questoes`/`alternativas`/
 * `curso_questoes` ja passam de 1000 linhas hoje.
 */
async function buscarTudo(supabase, tabela, colunas) {
  const linhas = [];
  let inicio = 0;
  for (;;) {
    const { data, error } = await supabase.from(tabela).select(colunas).range(inicio, inicio + TAMANHO_PAGINA - 1);
    if (error) throw new Error(`Falha ao ler ${tabela}: ${error.message}`);
    linhas.push(...data);
    if (data.length < TAMANHO_PAGINA) break;
    inicio += TAMANHO_PAGINA;
  }
  return linhas;
}

/**
 * Carrega, em paralelo, todas as tabelas relevantes para diagnostico de
 * cobertura multi-curso. So SELECT. Retorna um objeto plano — ver
 * coverage-scanner.mjs para o formato esperado de cada chave.
 *
 * @param {object} supabase cliente ja criado por criarClienteSupabaseSomenteLeitura()
 */
export async function carregarDadosBrutos(supabase) {
  const [
    cursos,
    cursoMaterias,
    cursoConteudos,
    unidadesPedagogicas,
    aulas,
    aulaVersoes,
    aulaVersaoFontes,
    teoriaEscoposConteudo,
    cursoEvidencias,
    questoes,
    questaoUnidadesPedagogicas,
    cursoQuestoes,
    editais,
    materias,
  ] = await Promise.all([
    buscarTudo(supabase, "cursos", "id, slug, carreira, concurso, cargo, banca, status, edital_id, publicado"),
    buscarTudo(supabase, "curso_materias", "id, curso_id, nome, materia_id, relevante_para_preparacao"),
    buscarTudo(supabase, "curso_conteudos", "id, curso_materia_id, assunto_id, relevante_para_preparacao"),
    buscarTudo(supabase, "unidades_pedagogicas", "id, curso_conteudo_id, titulo, escopo, artigos_esperados, ativa"),
    buscarTudo(supabase, "aulas", "id, conteudo_id, unidade_pedagogica_id, ativa"),
    buscarTudo(supabase, "aula_versoes", "id, aula_id, status"),
    buscarTudo(supabase, "aula_versao_fontes", "aula_versao_id, material_versao_id"),
    buscarTudo(supabase, "teoria_escopos_conteudo", "curso_conteudo_id, grupo_id, parte_ordem, escopo, artigos_esperados"),
    buscarTudo(supabase, "curso_evidencias", "id, curso_materia_id, curso_conteudo_id, tipo_origem"),
    buscarTudo(supabase, "questoes", "id, ativa, banca, gerada_por_ia, materia_id, assunto_id"),
    buscarTudo(supabase, "questao_unidades_pedagogicas", "questao_id, unidade_pedagogica_id"),
    buscarTudo(supabase, "curso_questoes", "curso_id, questao_id"),
    buscarTudo(supabase, "editais", "id, banca"),
    buscarTudo(supabase, "materias", "id, nome"),
  ]);

  return {
    cursos,
    cursoMaterias,
    cursoConteudos,
    unidadesPedagogicas,
    aulas,
    aulaVersoes,
    aulaVersaoFontes,
    teoriaEscoposConteudo,
    cursoEvidencias,
    questoes,
    questaoUnidadesPedagogicas,
    cursoQuestoes,
    editais,
    materias,
  };
}

export { criarClienteSupabaseSomenteLeitura };

const TABELAS_PARA_PG = [
  ["cursos", "id, slug, carreira, concurso, cargo, banca, status, edital_id, publicado"],
  ["curso_materias", "id, curso_id, nome, materia_id, relevante_para_preparacao"],
  ["curso_conteudos", "id, curso_materia_id, assunto_id, relevante_para_preparacao"],
  ["unidades_pedagogicas", "id, curso_conteudo_id, titulo, escopo, artigos_esperados, ativa"],
  ["aulas", "id, conteudo_id, unidade_pedagogica_id, ativa"],
  ["aula_versoes", "id, aula_id, status"],
  ["aula_versao_fontes", "aula_versao_id, material_versao_id"],
  ["teoria_escopos_conteudo", "curso_conteudo_id, grupo_id, parte_ordem, escopo, artigos_esperados"],
  ["curso_evidencias", "id, curso_materia_id, curso_conteudo_id, tipo_origem"],
  ["questoes", "id, ativa, banca, gerada_por_ia, materia_id, assunto_id"],
  ["questao_unidades_pedagogicas", "questao_id, unidade_pedagogica_id"],
  ["curso_questoes", "curso_id, questao_id"],
  ["editais", "id, banca"],
  ["materias", "id, nome"],
];

const CHAVES_RESULTADO = [
  "cursos",
  "cursoMaterias",
  "cursoConteudos",
  "unidadesPedagogicas",
  "aulas",
  "aulaVersoes",
  "aulaVersaoFontes",
  "teoriaEscoposConteudo",
  "cursoEvidencias",
  "questoes",
  "questaoUnidadesPedagogicas",
  "cursoQuestoes",
  "editais",
  "materias",
];

// Fase 2A.1, Risco 2: o canal `pg` era read-only so "por convencao" (o
// codigo so escrevia SELECT, nada tecnicamente impedia um UPDATE). Agora a
// propria sessao Postgres e travada em modo leitura antes de qualquer
// SELECT rodar, e essa trava e VERIFICADA (nao so assumida) — se a
// verificacao nao confirmar 'on', a funcao aborta sem executar nenhuma
// query de dados.
export const CODIGO_ABORTO_SESSAO_NAO_READONLY = "PG_SESSION_NOT_READ_ONLY";

export async function travarSessaoSomenteLeituraOuAbortar(client) {
  await client.query("SET default_transaction_read_only = on");
  const { rows } = await client.query("SHOW transaction_read_only");
  const valor = rows?.[0]?.transaction_read_only;
  if (valor !== "on") {
    throw new Error(`${CODIGO_ABORTO_SESSAO_NAO_READONLY}: SHOW transaction_read_only retornou "${valor}" (esperado "on"). Nenhuma query de dados foi executada.`);
  }
  return valor;
}

/**
 * Carrega os mesmos dados de carregarDadosBrutos(), mas via conexao
 * direta Postgres (`pg`), usando SUPABASE_DB_URL — canal alternativo
 * quando SUPABASE_URL/SUPABASE_SERVICE_ROLE_KEY nao estao configurados
 * neste ambiente. Uma unica conexao, fechada ao final mesmo em caso de
 * erro. Read-only e IMPOSTO tecnicamente (nao so por convencao do
 * codigo): a sessao e travada com `SET default_transaction_read_only = on`
 * e essa trava e confirmada via `SHOW transaction_read_only` antes de
 * qualquer SELECT de dados — ver travarSessaoSomenteLeituraOuAbortar.
 * Nenhuma das colunas/tabelas em TABELAS_PARA_PG vem de input do operador:
 * a lista e um array interno fixo, nunca string-concatenada a partir de
 * argumento de CLI (Secao 14 do mandato de hardening).
 */
export async function carregarDadosBrutosViaPg() {
  carregarEnvCuradoria();
  const connectionString = process.env.SUPABASE_DB_URL || process.env.DATABASE_URL;
  if (!connectionString) {
    throw new Error("Nem SUPABASE_URL/SUPABASE_SERVICE_ROLE_KEY nem SUPABASE_DB_URL/DATABASE_URL estao configurados.");
  }

  const { Client } = await import("pg");
  const client = new Client({ connectionString });
  await client.connect();
  try {
    const transactionReadOnly = await travarSessaoSomenteLeituraOuAbortar(client);

    const resultado = {};
    for (const [tabela, colunas] of TABELAS_PARA_PG) {
      const { rows } = await client.query(`select ${colunas} from public.${tabela}`);
      resultado[tabela] = rows;
    }
    const porChave = {};
    TABELAS_PARA_PG.forEach(([tabela], indice) => {
      porChave[CHAVES_RESULTADO[indice]] = resultado[tabela];
    });
    porChave.__pgSessionGuard = { transaction_read_only: transactionReadOnly };
    return porChave;
  } finally {
    await client.end().catch(() => {});
  }
}

/**
 * Escolhe automaticamente o canal disponivel: tenta REST
 * (criarClienteSupabaseSomenteLeitura + carregarDadosBrutos), e so cai
 * para Postgres direto (carregarDadosBrutosViaPg) se as credenciais REST
 * realmente nao estiverem configuradas. Retorna tambem qual canal foi
 * usado, para o CLI poder registrar isso no manifesto/console
 * (transparencia, nunca escondido). Rotulos exatos (Fase 2A.1, Secao 8):
 * "REST" ou "PG_READ_ONLY" — nunca "rest"/"pg" em minusculas.
 */
export async function carregarDadosBrutosAutoDetectado() {
  carregarEnvCuradoria();
  const temRest = Boolean((process.env.SUPABASE_URL || process.env.NEXT_PUBLIC_SUPABASE_URL) && process.env.SUPABASE_SERVICE_ROLE_KEY);
  if (temRest) {
    const supabase = await criarClienteSupabaseSomenteLeitura();
    return { canal: "REST", dados: await carregarDadosBrutos(supabase) };
  }
  const dados = await carregarDadosBrutosViaPg();
  const guard = dados.__pgSessionGuard;
  delete dados.__pgSessionGuard;
  return { canal: "PG_READ_ONLY", pgSessionGuard: guard, dados };
}

/**
 * Resolve e VALIDA um curso pelo slug ou id. Nunca escolhe um curso
 * default silenciosamente.
 */
export function resolverCurso(dadosBrutos, { cursoId, cursoSlug }) {
  if (!cursoId && !cursoSlug) return { ok: false, motivo: "informe --curso-id ou --curso-slug (ou --all-courses)" };
  const curso = cursoId
    ? dadosBrutos.cursos.find((c) => c.id === cursoId)
    : dadosBrutos.cursos.find((c) => c.slug === cursoSlug);
  if (!curso) return { ok: false, motivo: `curso nao encontrado (cursoId=${cursoId ?? "-"}, cursoSlug=${cursoSlug ?? "-"})` };
  return { ok: true, curso };
}

/**
 * Resolve e VALIDA que uma unidade pertence de fato ao curso informado —
 * nunca confia cegamente em ids fornecidos pelo operador (Secao 17). Se a
 * unidade existir mas pertencer a outro curso, retorna ok:false (ABORTAR
 * no chamador), nunca uma resposta parcial.
 */
export function resolverUnidadeNoCurso(dadosBrutos, { unidadeId, cursoId }) {
  const unidade = dadosBrutos.unidadesPedagogicas.find((u) => u.id === unidadeId);
  if (!unidade) return { ok: false, motivo: `unidade ${unidadeId} nao encontrada` };
  const cursoConteudo = dadosBrutos.cursoConteudos.find((c) => c.id === unidade.curso_conteudo_id);
  if (!cursoConteudo) return { ok: false, motivo: `unidade ${unidadeId} sem curso_conteudo resolvivel` };
  const cursoMateria = dadosBrutos.cursoMaterias.find((m) => m.id === cursoConteudo.curso_materia_id);
  if (!cursoMateria) return { ok: false, motivo: `unidade ${unidadeId} sem curso_materia resolvivel` };
  if (cursoMateria.curso_id !== cursoId) {
    return { ok: false, motivo: `unidade ${unidadeId} pertence ao curso ${cursoMateria.curso_id}, nao a ${cursoId}` };
  }
  return { ok: true, unidade, cursoConteudo, cursoMateria };
}
