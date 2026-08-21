// Helpers compartilhados do pipeline de curadoria pedagógica automático.
// Nenhuma função aqui executa SQL de escrita nem toca o Supabase, exceto
// criarClienteSupabaseSomenteLeitura (usada só por auditar-conteudo.mjs,
// e só com SELECT).

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

// scripts/curadoria-pedagogica/lib -> scripts/curadoria-pedagogica -> scripts -> raiz do projeto (Papiro.com)
export const RAIZ_PIPELINE = path.resolve(__dirname, "..");
export const RAIZ_PROJETO = path.resolve(RAIZ_PIPELINE, "..", "..");
export const DIR_SUPABASE = path.join(RAIZ_PROJETO, "supabase");
export const DIR_CONFIG = path.join(RAIZ_PIPELINE, "config");
export const DIR_RELATORIOS = path.join(RAIZ_PIPELINE, "relatorios");
export const CAMINHO_ENV_CURADORIA = path.join(RAIZ_PIPELINE, ".env.curadoria");

// Override de diretório de saída — usado SOMENTE pelo modo de simulação
// `node executar-pipeline.mjs --fixture <slug>` (ver executar-pipeline.mjs),
// para que os arquivos gerados nunca caiam em supabase/ de verdade durante
// um teste. Fora do modo --fixture, esta variável nunca é definida e todo
// arquivo continua indo para supabase/ normalmente.
function dirSaida() {
  return process.env.CURADORIA_SAIDA_DIR || DIR_SUPABASE;
}

// Mesmo usuário admin fixo reaproveitado em todas as curadorias já
// concluídas (Lei Maria da Penha, Direitos e Garantias Fundamentais,
// Improbidade Administrativa, Lei de Drogas) e nos scripts
// scripts/gerar-fase2k-lmp-*.mjs — nunca inventado por este pipeline.
export const ADMIN_USER_ID = "e5523807-6cc8-4867-8a56-77c17552e56e";

export function normalizarSlug(titulo) {
  return titulo
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "_")
    .replace(/^_+|_+$/g, "");
}

// Mesma regra de escape usada em todos os scripts gerar-*-correcoes.mjs já
// existentes: aspas simples duplicadas, nada além disso (não é entrada de
// usuário final, é texto jurídico já revisado por humano antes de chegar
// aqui).
export function escaparSql(valor) {
  return `'${String(valor).replace(/'/g, "''")}'`;
}

export function arrayPgTexto(valores) {
  if (!valores || valores.length === 0) return "null";
  return "array[" + valores.map(escaparSql).join(",") + "]";
}

export function garantirDiretorio(caminho) {
  fs.mkdirSync(caminho, { recursive: true });
}

export function lerJson(caminho) {
  if (!fs.existsSync(caminho)) {
    throw new Error(`Arquivo de configuração não encontrado: ${caminho}`);
  }
  return JSON.parse(fs.readFileSync(caminho, "utf8"));
}

export function escreverJson(caminho, dados) {
  garantirDiretorio(path.dirname(caminho));
  fs.writeFileSync(caminho, JSON.stringify(dados, null, 2) + "\n", "utf8");
}

export function escreverSql(caminho, conteudo) {
  garantirDiretorio(path.dirname(caminho));
  fs.writeFileSync(caminho, conteudo, "utf8");
}

// Carrega scripts/curadoria-pedagogica/.env.curadoria para process.env, se o
// arquivo existir. Esse arquivo NUNCA é versionado (já coberto pela regra
// ".env*" do .gitignore raiz do projeto — confirmado com
// `git check-ignore`). Usa a API nativa do Node (disponível desde a v20.12/
// v21.7, e o projeto já exige Node >=22.13 em package.json); se por algum
// motivo não existir nesta instalação de Node, cai num parser manual
// minimalista, só para não quebrar o pipeline por causa disso.
export function carregarEnvCuradoria() {
  if (!fs.existsSync(CAMINHO_ENV_CURADORIA)) return;

  if (typeof process.loadEnvFile === "function") {
    try {
      process.loadEnvFile(CAMINHO_ENV_CURADORIA);
      return;
    } catch {
      // cai no parser manual abaixo
    }
  }

  const conteudo = fs.readFileSync(CAMINHO_ENV_CURADORIA, "utf8");
  for (const linhaBruta of conteudo.split("\n")) {
    const linha = linhaBruta.trim();
    if (!linha || linha.startsWith("#")) continue;
    const igual = linha.indexOf("=");
    if (igual === -1) continue;
    const chave = linha.slice(0, igual).trim();
    let valor = linha.slice(igual + 1).trim();
    if (
      (valor.startsWith('"') && valor.endsWith('"')) ||
      (valor.startsWith("'") && valor.endsWith("'"))
    ) {
      valor = valor.slice(1, -1);
    }
    if (chave && process.env[chave] === undefined) process.env[chave] = valor;
  }
}

// Único ponto de contato com o Supabase em todo o pipeline — e só leitura.
// Os geradores de SQL que trabalham sobre config/ (curadoria/mapa/rollback)
// NUNCA chamam isto. auditar-conteudo.mjs e gerar-pos-check.mjs chamam,
// porque genuinamente precisam ler o estado real do banco.
export async function criarClienteSupabaseSomenteLeitura() {
  carregarEnvCuradoria();

  const { createClient } = await import("@supabase/supabase-js");
  const url = process.env.SUPABASE_URL || process.env.NEXT_PUBLIC_SUPABASE_URL;
  const chave = process.env.SUPABASE_SERVICE_ROLE_KEY;
  const faltando = [];
  if (!url) faltando.push("SUPABASE_URL");
  if (!chave) faltando.push("SUPABASE_SERVICE_ROLE_KEY");

  if (faltando.length > 0) {
    throw new Error(
      `Variavel(is) de ambiente ausente(s): ${faltando.join(", ")}.\n` +
        `Crie o arquivo ${CAMINHO_ENV_CURADORIA} (copie de env.curadoria.example, que fica no mesmo diretorio) ` +
        `com SUPABASE_URL e SUPABASE_SERVICE_ROLE_KEY preenchidos, ou exporte essas variaveis na sessao do terminal. ` +
        "Esse arquivo nunca deve ser versionado (ja coberto pela regra '.env*' do .gitignore raiz do projeto). " +
        "A chave de servico (service role) e necessaria porque unidades_pedagogicas e questao_unidades_pedagogicas " +
        "tem RLS fechado para anon/authenticated (ver supabase/unidades_pedagogicas.sql e " +
        "supabase/questao_unidades_pedagogicas.sql) — a chave anon nao consegue ler essas tabelas."
    );
  }
  return createClient(url, chave, { auth: { persistSession: false } });
}

// Consulta, ao vivo, os 4 totais estruturais usados na consulta 7 do
// pos-check (curso_conteudos, unidades_pedagogicas, questoes, alternativas)
// — mesmos 4 números que antes precisavam ser passados manualmente por
// flag de linha de comando para gerar-pos-check.mjs. Só leitura.
export async function consultarTotaisSistema(supabase) {
  const [conteudos, unidades, questoes, alternativas] = await Promise.all([
    supabase.from("curso_conteudos").select("id", { count: "exact", head: true }),
    supabase.from("unidades_pedagogicas").select("id", { count: "exact", head: true }),
    supabase.from("questoes").select("id", { count: "exact", head: true }),
    supabase.from("alternativas").select("id", { count: "exact", head: true }),
  ]);

  for (const [nome, resultado] of [
    ["curso_conteudos", conteudos],
    ["unidades_pedagogicas", unidades],
    ["questoes", questoes],
    ["alternativas", alternativas],
  ]) {
    if (resultado.error) throw new Error(`Falha ao consultar total de ${nome}: ${resultado.error.message}`);
  }

  return {
    totalConteudos: conteudos.count,
    totalUnidadesSistema: unidades.count,
    totalQuestoesSistema: questoes.count,
    totalAlternativasSistema: alternativas.count,
  };
}

export function caminhoConfigUnidades(slug) {
  return path.join(DIR_CONFIG, `${slug}.unidades.json`);
}
export function caminhoConfigMapa(slug) {
  return path.join(DIR_CONFIG, `${slug}.mapa.json`);
}
export function caminhoRelatorioAuditoria(slug) {
  return path.join(DIR_RELATORIOS, `relatorio_auditoria_${slug}.json`);
}
export function caminhoOrdemCuradoria() {
  return path.join(DIR_CONFIG, "ordem-curadoria.json");
}
export function caminhoRelatorioGeral() {
  return path.join(DIR_RELATORIOS, "relatorio_curadoria_geral.json");
}
export function caminhoCuradoria(slug) {
  return path.join(dirSaida(), `curadoria_unidades_${slug}.sql`);
}
export function caminhoMapa(slug) {
  return path.join(dirSaida(), `mapa_classificacao_${slug}.sql`);
}
export function caminhoTesteRollback(slug) {
  return path.join(dirSaida(), `classificar_questoes_unidades_${slug}_teste_rollback.sql`);
}
export function caminhoApply(slug) {
  return path.join(dirSaida(), `classificar_questoes_unidades_${slug}.sql`);
}
export function caminhoPosCheck(slug) {
  return path.join(dirSaida(), `pos_check_classificacao_unidades_${slug}.sql`);
}

// Carrega unidades.json + mapa.json e calcula, a partir SÓ dos dados já
// aprovados (nunca inventando nada novo), tudo que gerar-rollback.mjs,
// gerar-apply.mjs e gerar-pos-check.mjs precisam: totais, distribuição por
// unidade e conjunto de questões multiunidade — exatamente os números que,
// nas 4 curadorias manuais, foram calculados à mão e depois conferidos.
export function calcularDerivados(configUnidades, configMapa) {
  const unidades = [...configUnidades.unidades].sort((a, b) => a.ordem - b.ordem);
  const vinculos = configMapa.vinculos;

  const porQuestao = new Map();
  for (const v of vinculos) {
    if (!porQuestao.has(v.questao_id)) porQuestao.set(v.questao_id, []);
    porQuestao.get(v.questao_id).push(v.unidade_id);
  }

  const multiunidade = [...porQuestao.entries()]
    .filter(([, unidadeIds]) => unidadeIds.length > 1)
    .map(([questaoId]) => questaoId)
    .sort((a, b) => a - b);

  const porUnidade = new Map(unidades.map((u) => [u.id, new Set()]));
  for (const v of vinculos) {
    if (!porUnidade.has(v.unidade_id)) {
      throw new Error(`Vinculo aponta para unidade_id ${v.unidade_id}, que nao existe em unidades.json`);
    }
    porUnidade.get(v.unidade_id).add(v.questao_id);
  }

  return {
    unidades,
    totalVinculos: vinculos.length,
    questoesDistintas: porQuestao.size,
    multiunidade,
    contagemPorUnidade: unidades.map((u) => ({
      unidade_id: u.id,
      ordem: u.ordem,
      titulo: u.titulo,
      qtd_questoes: porUnidade.get(u.id).size,
    })),
  };
}

// Status válidos para cada item de config/ordem-curadoria.json — usado
// pelas validações abaixo e por auditar-geral.mjs/status-curadoria.mjs.
export const STATUS_VALIDOS_ORDEM_CURADORIA = ["concluido", "pendente"];

// Validações locais (sem tocar o Supabase) de config/ordem-curadoria.json:
// curso_conteudo_id duplicado, ordem duplicada e status inválido. A
// checagem de "conteúdo inexistente" (contra o banco real) não é feita
// aqui de propósito — exige SELECT no Supabase e por isso vive em
// auditar-geral.mjs, a única etapa que já tem essa responsabilidade.
export function validarOrdemCuradoria(lista) {
  const erros = [];

  if (!Array.isArray(lista) || lista.length === 0) {
    throw new Error("config/ordem-curadoria.json invalido: esperado um array nao vazio.");
  }

  const idsVistos = new Map();
  const ordensVistas = new Map();

  for (const item of lista) {
    if (!Number.isInteger(item.curso_conteudo_id)) {
      erros.push(`item com curso_conteudo_id ausente/invalido: ${JSON.stringify(item)}`);
      continue;
    }
    if (!Number.isInteger(item.ordem)) {
      erros.push(`curso_conteudo_id=${item.curso_conteudo_id} com ordem ausente/invalida`);
    } else if (ordensVistas.has(item.ordem)) {
      erros.push(`ordem duplicada: ${item.ordem} (curso_conteudo_id=${item.curso_conteudo_id} e curso_conteudo_id=${ordensVistas.get(item.ordem)})`);
    } else {
      ordensVistas.set(item.ordem, item.curso_conteudo_id);
    }

    if (idsVistos.has(item.curso_conteudo_id)) {
      erros.push(`curso_conteudo_id duplicado: ${item.curso_conteudo_id} (ordens ${idsVistos.get(item.curso_conteudo_id)} e ${item.ordem})`);
    } else {
      idsVistos.set(item.curso_conteudo_id, item.ordem);
    }

    if (!STATUS_VALIDOS_ORDEM_CURADORIA.includes(item.status)) {
      erros.push(
        `curso_conteudo_id=${item.curso_conteudo_id} com status invalido: "${item.status}" (esperado um de: ${STATUS_VALIDOS_ORDEM_CURADORIA.join(", ")})`
      );
    }
  }

  if (erros.length > 0) {
    throw new Error(`config/ordem-curadoria.json invalido:\n - ${erros.join("\n - ")}`);
  }
}
