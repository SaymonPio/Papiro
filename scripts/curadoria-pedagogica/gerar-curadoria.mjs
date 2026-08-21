#!/usr/bin/env node
// Gera supabase/curadoria_unidades_<slug>.sql — Etapa 2 do pipeline.
//
// NUNCA decide título/escopo/artigos_esperados sozinho: lê tudo de
// config/<slug>.unidades.json, que precisa existir e ter sido preenchido
// por um humano (leitura do relatório de auditoria + julgamento
// pedagógico, ver docs/REGRAS_CURADORIA_PAPIRO.md, seções 2 e 3) ANTES de
// rodar este script.
//
// Reproduz a estrutura de supabase/curadoria_unidades_lei_drogas.sql (1
// unidade) e supabase/curadoria_unidades_improbidade.sql /
// curadoria_unidades_direitos_garantias_fundamentais.sql (2 unidades):
// sempre um único bloco `do $$ ... $$` dentro de BEGIN/COMMIT, precondição
// de conteúdo canônico, verificação do id da unidade padrão (ordem=1) já
// existente, UPDATE nela, e um INSERT ... ON CONFLICT DO UPDATE por
// unidade adicional.
//
// NUNCA executa SQL — só escreve o arquivo .sql local.
//
// Uso: node gerar-curadoria.mjs <slug>

import { lerJson, escreverSql, caminhoConfigUnidades, caminhoCuradoria, escaparSql, arrayPgTexto } from "./lib/comum.mjs";

const slug = process.argv[2];
if (!slug) {
  console.error("Uso: node gerar-curadoria.mjs <slug>");
  process.exit(1);
}

// Formato esperado de config/<slug>.unidades.json (ver
// config/lei_drogas.unidades.json para um exemplo real já aplicado):
// {
//   "curso_conteudo_id": 66,
//   "nome_assunto": "Lei de Drogas",
//   "materia_id": 10,
//   "curso_id": "7543be16-4c5b-4cb6-8724-8fbdfb96f2d4",
//   "unidades": [
//     { "id": "uuid-explicito", "ordem": 1, "titulo": "...", "escopo": "...",
//       "artigos_esperados": ["art. 28", "..."] | null }
//   ]
// }

const config = lerJson(caminhoConfigUnidades(slug));

function validarConfig(cfg) {
  const erros = [];
  if (!Number.isInteger(cfg.curso_conteudo_id)) erros.push("curso_conteudo_id ausente/invalido");
  if (!cfg.nome_assunto) erros.push("nome_assunto ausente");
  if (!Number.isInteger(cfg.materia_id)) erros.push("materia_id ausente/invalido");
  if (!cfg.curso_id) erros.push("curso_id ausente");
  if (!Array.isArray(cfg.unidades) || cfg.unidades.length === 0) erros.push("unidades ausente ou vazio");

  const ordensVistas = new Set();
  for (const u of cfg.unidades || []) {
    if (!u.id) erros.push(`unidade ordem=${u.ordem} sem id (UUID explicito e obrigatorio, nunca gen_random_uuid())`);
    if (!Number.isInteger(u.ordem) || u.ordem <= 0) erros.push(`unidade com ordem invalida: ${JSON.stringify(u)}`);
    if (ordensVistas.has(u.ordem)) erros.push(`ordem duplicada: ${u.ordem}`);
    ordensVistas.add(u.ordem);
    if (!u.titulo) erros.push(`unidade ordem=${u.ordem} sem titulo`);
    if (!u.escopo) erros.push(`unidade ordem=${u.ordem} sem escopo`);
  }
  if (!ordensVistas.has(1)) erros.push("a unidade de ordem=1 e obrigatoria (e sempre a unidade padrao ja existente)");

  if (erros.length > 0) {
    throw new Error(`config/${slug}.unidades.json invalido:\n - ${erros.join("\n - ")}`);
  }
}

validarConfig(config);

const unidadesOrdenadas = [...config.unidades].sort((a, b) => a.ordem - b.ordem);
const unidade1 = unidadesOrdenadas.find((u) => u.ordem === 1);
const outrasUnidades = unidadesOrdenadas.filter((u) => u.ordem !== 1);

const checagemUnidadesExtras =
  outrasUnidades.length === 0
    ? `
  -- Decisao aprovada: manter 1 unica unidade — nenhuma outra pode existir
  -- para este conteudo (execucao repetida nao deveria encontrar uma ordem
  -- criada por engano em outra etapa).
  if exists (
    select 1 from public.unidades_pedagogicas
    where curso_conteudo_id = v_conteudo_id and ordem <> 1
  ) then
    raise exception 'Existe unidade com ordem diferente de 1 para o conteudo ${config.curso_conteudo_id} — decisao aprovada foi manter unidade unica';
  end if;`
    : outrasUnidades
        .map(
          (u) => `
  -- Garante que nenhuma outra unidade ja ocupa ordem=${u.ordem} para este
  -- conteudo (execucao repetida nao deveria criar duplicata silenciosa).
  if exists (
    select 1 from public.unidades_pedagogicas
    where curso_conteudo_id = v_conteudo_id and ordem = ${u.ordem} and id <> ${escaparSql(u.id)}
  ) then
    raise exception 'Ja existe uma unidade ordem=${u.ordem} diferente da esperada para o conteudo ${config.curso_conteudo_id}';
  end if;`
        )
        .join("\n");

const blocoInsertsOutrasUnidades = outrasUnidades
  .map(
    (u) => `
  insert into public.unidades_pedagogicas
    (id, curso_conteudo_id, titulo, ordem, escopo, artigos_esperados, ativa)
  values
    (${escaparSql(u.id)}, v_conteudo_id, ${escaparSql(u.titulo)}, ${u.ordem},
     ${escaparSql(u.escopo)},
     ${arrayPgTexto(u.artigos_esperados)},
     true)
  on conflict (curso_conteudo_id, ordem) do update set
    titulo = excluded.titulo,
    escopo = excluded.escopo,
    artigos_esperados = excluded.artigos_esperados,
    ativa = excluded.ativa;`
  )
  .join("\n");

const listaUnidades = unidadesOrdenadas.map((u) => `--   Unidade ${u.ordem}: ${u.titulo}`).join("\n");

const sql = `-- Curadoria das unidades pedagogicas de ${config.nome_assunto}
-- (curso_conteudos.id = ${config.curso_conteudo_id}), gerado pelo pipeline
-- automatico (scripts/curadoria-pedagogica/gerar-curadoria.mjs) a partir de
-- config/${slug}.unidades.json, revisado e aprovado por humano. Segue o
-- mesmo padrao de supabase/curadoria_unidades_lei_drogas.sql,
-- supabase/curadoria_unidades_improbidade.sql e
-- supabase/curadoria_unidades_direitos_garantias_fundamentais.sql.
--
-- Um unico curso_conteudos (id ${config.curso_conteudo_id}, assunto "${config.nome_assunto}")
-- e ${unidadesOrdenadas.length} recorte(s) pedagogico(s):
${listaUnidades}
--
-- Nao publica nem gera aulas automaticamente. Nao altera nenhuma questao,
-- alternativa ou vinculo de curso_questoes. Nao escreve em
-- questao_unidades_pedagogicas — isso e feito exclusivamente pelos
-- arquivos classificar_questoes_unidades_${slug}*.sql, via a RPC oficial
-- classificar_questao_unidade_admin.

begin;

do $$
declare
  v_conteudo_id constant bigint := ${config.curso_conteudo_id};
  v_unidade_1_id constant uuid := ${escaparSql(unidade1.id)};
  v_unidade_padrao uuid;
begin
  -- Precondicao: o conteudo canonico e realmente "${config.nome_assunto}",
  -- na materia/curso esperados.
  if not exists (
    select 1 from public.curso_conteudos cc
    join public.assuntos a on a.id = cc.assunto_id
    join public.curso_materias cm on cm.id = cc.curso_materia_id
    where cc.id = v_conteudo_id
      and a.nome = ${escaparSql(config.nome_assunto)}
      and cm.materia_id = ${config.materia_id}
      and cm.curso_id = ${escaparSql(config.curso_id)}
  ) then
    raise exception 'Conteudo canonico de ${config.nome_assunto} nao confere';
  end if;

  select id into v_unidade_padrao
  from public.unidades_pedagogicas
  where curso_conteudo_id = v_conteudo_id and ordem = 1;

  if v_unidade_padrao is null then
    raise exception 'Unidade padrao do conteudo ${config.curso_conteudo_id} nao encontrada';
  end if;

  if v_unidade_padrao <> v_unidade_1_id then
    raise exception 'Id da unidade padrao (%) diverge do id esperado (%) — script precisa ser atualizado antes de aplicar', v_unidade_padrao, v_unidade_1_id;
  end if;
${checagemUnidadesExtras}

  update public.unidades_pedagogicas set
    titulo = ${escaparSql(unidade1.titulo)},
    escopo = ${escaparSql(unidade1.escopo)},
    artigos_esperados = ${arrayPgTexto(unidade1.artigos_esperados)},
    ativa = true
  where id = v_unidade_1_id;
${blocoInsertsOutrasUnidades}
end;
$$;

commit;
`;

escreverSql(caminhoCuradoria(slug), sql);
console.log(`Gerado: supabase/curadoria_unidades_${slug}.sql`);
console.log("Nada foi executado no Supabase. Revise o arquivo antes de aplicar manualmente.");
