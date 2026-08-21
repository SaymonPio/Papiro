#!/usr/bin/env node
// Auditoria somente-leitura de um curso_conteudo — Etapa 1 do pipeline de
// curadoria pedagógica automático.
//
// Reproduz exatamente o tipo de levantamento já feito manualmente nas 4
// curadorias concluídas (Lei Maria da Penha, Direitos e Garantias
// Fundamentais, Improbidade Administrativa, Lei de Drogas): identidade do
// conteúdo/matéria/assunto/curso, unidades pedagógicas já existentes, aulas
// publicadas, classificações já feitas, e o banco de questões ativas com
// contagem de alternativas/corretas.
//
// Sinaliza dois tipos de problema MECANICAMENTE detectáveis:
//   - duplicata exata (enunciado + alternativas byte-idênticos, mesmo
//     padrão que identificou 137/857 e 143/869);
//   - estrutura anômala (menos de 4 ou mais de 5 alternativas, ou número
//     de alternativas corretas diferente de 1).
//
// NÃO tenta detectar questão fora de escopo (como a 674 da Lei de Drogas)
// nem decide tema/unidade — isso exige leitura humana do enunciado
// completo (ver docs/REGRAS_CURADORIA_PAPIRO.md, seção 4 e 5). Este script
// só reúne os dados brutos que essa leitura precisa.
//
// NUNCA escreve no banco — é a única etapa deste pipeline que sequer
// consulta o Supabase, e só com SELECT.
//
// Uso: node auditar-conteudo.mjs <curso_conteudo_id>

import {
  criarClienteSupabaseSomenteLeitura,
  normalizarSlug,
  escreverJson,
  caminhoRelatorioAuditoria,
} from "./lib/comum.mjs";

const cursoConteudoId = Number(process.argv[2]);
if (!Number.isInteger(cursoConteudoId) || cursoConteudoId <= 0) {
  console.error("Uso: node auditar-conteudo.mjs <curso_conteudo_id>");
  process.exit(1);
}

function assinaturaQuestao(questao) {
  const alternativas = (questao.alternativas || [])
    .slice()
    .sort((a, b) => a.ordem - b.ordem)
    .map((a) => ({ texto: a.texto.trim(), correta: a.correta }));
  return JSON.stringify({ enunciado: questao.enunciado.trim(), alternativas });
}

async function main() {
  const supabase = await criarClienteSupabaseSomenteLeitura();

  const { data: conteudo, error: erroConteudo } = await supabase
    .from("curso_conteudos")
    .select(
      "id, assunto_id, curso_materia_id, curso_materias(materia_id, curso_id, nome, peso, cursos(slug)), assuntos(nome)"
    )
    .eq("id", cursoConteudoId)
    .maybeSingle();

  if (erroConteudo) throw erroConteudo;
  if (!conteudo) throw new Error(`curso_conteudo_id ${cursoConteudoId} nao encontrado.`);

  const materia = conteudo.curso_materias;
  const assunto = conteudo.assuntos;
  const slugSugerido = normalizarSlug(assunto.nome);

  const { data: unidades, error: erroUnidades } = await supabase
    .from("unidades_pedagogicas")
    .select("id, ordem, titulo, escopo, artigos_esperados, ativa")
    .eq("curso_conteudo_id", cursoConteudoId)
    .order("ordem");
  if (erroUnidades) throw erroUnidades;

  const idsUnidades = unidades.map((u) => u.id);

  const { data: aulas } = idsUnidades.length
    ? await supabase
        .from("aulas")
        .select("id, unidade_pedagogica_id, ativa, titulo, aula_versoes(id, numero_versao, status)")
        .in("unidade_pedagogica_id", idsUnidades)
    : { data: [] };

  const { data: questoes, error: erroQuestoes } = await supabase
    .from("questoes")
    .select("id, ativa, enunciado, alternativas(ordem, texto, correta)")
    .eq("assunto_id", conteudo.assunto_id);
  if (erroQuestoes) throw erroQuestoes;

  const { data: classificacoes } = idsUnidades.length
    ? await supabase
        .from("questao_unidades_pedagogicas")
        .select("questao_id, unidade_pedagogica_id")
        .in("unidade_pedagogica_id", idsUnidades)
    : { data: [] };

  const ativas = questoes.filter((q) => q.ativa);

  const assinaturas = new Map();
  for (const q of ativas) {
    const chave = assinaturaQuestao(q);
    if (!assinaturas.has(chave)) assinaturas.set(chave, []);
    assinaturas.get(chave).push(q.id);
  }
  const duplicatasPossiveis = [...assinaturas.values()]
    .filter((ids) => ids.length > 1)
    .map((ids) => ids.sort((a, b) => a - b));

  const estruturaAnomala = ativas
    .filter((q) => {
      const alts = q.alternativas || [];
      const corretas = alts.filter((a) => a.correta).length;
      return alts.length < 4 || alts.length > 5 || corretas !== 1;
    })
    .map((q) => ({
      questao_id: q.id,
      qtd_alternativas: (q.alternativas || []).length,
      qtd_corretas: (q.alternativas || []).filter((a) => a.correta).length,
    }));

  const relatorio = {
    curso_conteudo_id: cursoConteudoId,
    assunto_id: conteudo.assunto_id,
    materia_id: materia.materia_id,
    curso_materia_id: conteudo.curso_materia_id,
    curso_id: materia.curso_id,
    curso_slug: materia.cursos?.slug ?? null,
    peso_materia: materia.peso,
    titulo_atual: assunto.nome,
    slug_sugerido: slugSugerido,
    _nota_slug:
      "slug_sugerido e so um ponto de partida mecanico — os 3 slugs reais ja em uso " +
      "(direitos_garantias_fundamentais, improbidade, lei_drogas) nao batem com o que esta " +
      "funcao produziria a partir do nome do assunto. O slug definitivo e uma decisao humana, " +
      "feita ao nomear os arquivos config/<slug>.unidades.json e config/<slug>.mapa.json.",
    unidades_existentes: unidades,
    aulas_existentes: aulas || [],
    total_questoes: questoes.length,
    total_ativas: ativas.length,
    total_inativas: questoes.length - ativas.length,
    total_classificadas_distintas: new Set((classificacoes || []).map((c) => c.questao_id)).size,
    total_vinculos_classificacao: (classificacoes || []).length,
    questoes_ativas: ativas.map((q) => ({
      id: q.id,
      enunciado: q.enunciado,
      qtd_alternativas: (q.alternativas || []).length,
      qtd_corretas: (q.alternativas || []).filter((a) => a.correta).length,
    })),
    possiveis_problemas: {
      duplicatas_exatas: duplicatasPossiveis,
      estrutura_anomala: estruturaAnomala,
      nota:
        "Nenhuma questao fora de escopo e detectada automaticamente — isso exige leitura humana " +
        "do enunciado completo (ver docs/REGRAS_CURADORIA_PAPIRO.md, secao 5). Revise " +
        "questoes_ativas manualmente antes de escrever config/<slug>.unidades.json e " +
        "config/<slug>.mapa.json.",
    },
    gerado_em: new Date().toISOString(),
  };

  const destino = caminhoRelatorioAuditoria(slugSugerido);
  escreverJson(destino, relatorio);

  console.log(`Auditoria concluida para curso_conteudo_id=${cursoConteudoId} ("${assunto.nome}").`);
  console.log(`Relatorio salvo em: ${destino}`);
  console.log(
    `Questoes ativas: ${ativas.length} | Unidades existentes: ${unidades.length} | Ja classificadas: ${relatorio.total_classificadas_distintas}`
  );
  if (duplicatasPossiveis.length > 0) {
    console.log(
      `ATENCAO: ${duplicatasPossiveis.length} grupo(s) de possivel duplicata exata: ${JSON.stringify(duplicatasPossiveis)}`
    );
  }
  if (estruturaAnomala.length > 0) {
    console.log(`Nota: ${estruturaAnomala.length} questao(oes) com estrutura fora do padrao 5 alternativas/1 correta (nem sempre e erro).`);
  }
  console.log("Proximo passo: revisar o relatorio e escrever config/<slug>.unidades.json + config/<slug>.mapa.json antes de gerar-curadoria.mjs.");
}

main().catch((erro) => {
  console.error("Falha na auditoria:", erro.message);
  process.exit(1);
});
